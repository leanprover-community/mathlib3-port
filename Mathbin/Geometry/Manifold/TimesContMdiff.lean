import Mathbin.Geometry.Manifold.Mfderiv 
import Mathbin.Geometry.Manifold.LocalInvariantProperties

/-!
# Smooth functions between smooth manifolds

We define `Cⁿ` functions between smooth manifolds, as functions which are `Cⁿ` in charts, and prove
basic properties of these notions.

## Main definitions and statements

Let `M ` and `M'` be two smooth manifolds, with respect to model with corners `I` and `I'`. Let
`f : M → M'`.

* `times_cont_mdiff_within_at I I' n f s x` states that the function `f` is `Cⁿ` within the set `s`
  around the point `x`.
* `times_cont_mdiff_at I I' n f x` states that the function `f` is `Cⁿ` around `x`.
* `times_cont_mdiff_on I I' n f s` states that the function `f` is `Cⁿ` on the set `s`
* `times_cont_mdiff I I' n f` states that the function `f` is `Cⁿ`.
* `times_cont_mdiff_on.comp` gives the invariance of the `Cⁿ` property under composition
* `times_cont_mdiff_on.times_cont_mdiff_on_tangent_map_within` states that the bundled derivative
  of a `Cⁿ` function in a domain is `Cᵐ` when `m + 1 ≤ n`.
* `times_cont_mdiff.times_cont_mdiff_tangent_map` states that the bundled derivative
  of a `Cⁿ` function is `Cᵐ` when `m + 1 ≤ n`.
* `times_cont_mdiff_iff_times_cont_diff` states that, for functions between vector spaces,
  manifold-smoothness is equivalent to usual smoothness.

We also give many basic properties of smooth functions between manifolds, following the API of
smooth functions between vector spaces.

## Implementation details

Many properties follow for free from the corresponding properties of functions in vector spaces,
as being `Cⁿ` is a local property invariant under the smooth groupoid. We take advantage of the
general machinery developed in `local_invariant_properties.lean` to get these properties
automatically. For instance, the fact that being `Cⁿ` does not depend on the chart one considers
is given by `lift_prop_within_at_indep_chart`.

For this to work, the definition of `times_cont_mdiff_within_at` and friends has to
follow definitionally the setup of local invariant properties. Still, we recast the definition
in terms of extended charts in `times_cont_mdiff_on_iff` and `times_cont_mdiff_iff`.
-/


open Set Function Filter ChartedSpace SmoothManifoldWithCorners

open_locale TopologicalSpace Manifold

/-! ### Definition of smooth functions between manifolds -/


variable{𝕜 :
    Type
      _}[NondiscreteNormedField
      𝕜]{E :
    Type
      _}[NormedGroup
      E][NormedSpace 𝕜
      E]{H :
    Type
      _}[TopologicalSpace
      H](I :
    ModelWithCorners 𝕜 E
      H){M :
    Type
      _}[TopologicalSpace
      M][ChartedSpace H
      M][Is :
    SmoothManifoldWithCorners I
      M]{E' :
    Type
      _}[NormedGroup
      E'][NormedSpace 𝕜
      E']{H' :
    Type
      _}[TopologicalSpace
      H'](I' :
    ModelWithCorners 𝕜 E'
      H'){M' :
    Type
      _}[TopologicalSpace
      M'][ChartedSpace H'
      M'][I's :
    SmoothManifoldWithCorners I'
      M']{F :
    Type
      _}[NormedGroup
      F][NormedSpace 𝕜
      F]{G :
    Type
      _}[TopologicalSpace
      G]{J :
    ModelWithCorners 𝕜 F
      G}{N :
    Type
      _}[TopologicalSpace
      N][ChartedSpace G
      N][Js :
    SmoothManifoldWithCorners J
      N]{F' :
    Type
      _}[NormedGroup
      F'][NormedSpace 𝕜
      F']{G' :
    Type
      _}[TopologicalSpace
      G']{J' :
    ModelWithCorners 𝕜 F'
      G'}{N' :
    Type
      _}[TopologicalSpace
      N'][ChartedSpace G'
      N'][J's : SmoothManifoldWithCorners J' N']{f f₁ : M → M'}{s s₁ t : Set M}{x : M}{m n : WithTop ℕ}

/-- Property in the model space of a model with corners of being `C^n` within at set at a point,
when read in the model vector space. This property will be lifted to manifolds to define smooth
functions between manifolds. -/
def TimesContDiffWithinAtProp (n : WithTop ℕ) f s x : Prop :=
  TimesContDiffWithinAt 𝕜 n (I' ∘ f ∘ I.symm) (range I ∩ I.symm ⁻¹' s) (I x)

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Being `Cⁿ` in the model space is a local property, invariant under smooth maps. Therefore,
it will lift nicely to manifolds. -/
theorem times_cont_diff_within_at_local_invariant_prop
(n : with_top exprℕ()) : (times_cont_diff_groupoid «expr∞»() I).local_invariant_prop (times_cont_diff_groupoid «expr∞»() I') (times_cont_diff_within_at_prop I I' n) :=
{ is_local := begin
    assume [binders (s x u f u_open xu)],
    have [] [":", expr «expr = »(«expr ∩ »(range I, «expr ⁻¹' »(I.symm, «expr ∩ »(s, u))), «expr ∩ »(«expr ∩ »(range I, «expr ⁻¹' »(I.symm, s)), «expr ⁻¹' »(I.symm, u)))] [],
    by simp [] [] ["only"] ["[", expr inter_assoc, ",", expr preimage_inter, "]"] [] [],
    rw ["[", expr times_cont_diff_within_at_prop, ",", expr times_cont_diff_within_at_prop, ",", expr this, "]"] [],
    symmetry,
    apply [expr times_cont_diff_within_at_inter],
    have [] [":", expr «expr ∈ »(u, expr𝓝() (I.symm (I x)))] [],
    by { rw ["[", expr model_with_corners.left_inv, "]"] [],
      exact [expr is_open.mem_nhds u_open xu] },
    apply [expr continuous_at.preimage_mem_nhds I.continuous_symm.continuous_at this]
  end,
  right_invariance := begin
    assume [binders (s x f e he hx h)],
    rw [expr times_cont_diff_within_at_prop] ["at", ident h, "⊢"],
    have [] [":", expr «expr = »(I x, «expr ∘ »(I, «expr ∘ »(e.symm, I.symm)) (I (e x)))] [],
    by simp [] [] ["only"] ["[", expr hx, "]"] ["with", ident mfld_simps] [],
    rw [expr this] ["at", ident h],
    have [] [":", expr «expr ∈ »(I (e x), «expr ∩ »(«expr ⁻¹' »(I.symm, e.target), range «expr⇑ »(I)))] [],
    by simp [] [] ["only"] ["[", expr hx, "]"] ["with", ident mfld_simps] [],
    have [] [] [":=", expr ((mem_groupoid_of_pregroupoid.2 he).2.times_cont_diff_within_at this).of_le le_top],
    convert [] [expr h.comp' _ this] ["using", 1],
    { ext [] [ident y] [],
      simp [] [] ["only"] [] ["with", ident mfld_simps] [] },
    { mfld_set_tac }
  end,
  congr := begin
    assume [binders (s x f g h hx hf)],
    apply [expr hf.congr],
    { assume [binders (y hy)],
      simp [] [] ["only"] [] ["with", ident mfld_simps] ["at", ident hy],
      simp [] [] ["only"] ["[", expr h, ",", expr hy, "]"] ["with", ident mfld_simps] [] },
    { simp [] [] ["only"] ["[", expr hx, "]"] ["with", ident mfld_simps] [] }
  end,
  left_invariance := begin
    assume [binders (s x f e' he' hs hx h)],
    rw [expr times_cont_diff_within_at_prop] ["at", ident h, "⊢"],
    have [ident A] [":", expr «expr ∈ »(«expr ∘ »(I', «expr ∘ »(f, I.symm)) (I x), «expr ∩ »(«expr ⁻¹' »(I'.symm, e'.source), range I'))] [],
    by simp [] [] ["only"] ["[", expr hx, "]"] ["with", ident mfld_simps] [],
    have [] [] [":=", expr ((mem_groupoid_of_pregroupoid.2 he').1.times_cont_diff_within_at A).of_le le_top],
    convert [] [expr this.comp _ h _] [],
    { ext [] [ident y] [],
      simp [] [] ["only"] [] ["with", ident mfld_simps] [] },
    { assume [binders (y hy)],
      simp [] [] ["only"] [] ["with", ident mfld_simps] ["at", ident hy],
      simpa [] [] ["only"] ["[", expr hy, "]"] ["with", ident mfld_simps] ["using", expr hs hy.2] }
  end }

theorem times_cont_diff_within_at_local_invariant_prop_mono (n : WithTop ℕ) ⦃s x t⦄ ⦃f : H → H'⦄ (hts : t ⊆ s)
  (h : TimesContDiffWithinAtProp I I' n f s x) : TimesContDiffWithinAtProp I I' n f t x :=
  by 
    apply h.mono fun y hy => _ 
    simp' only with mfld_simps  at hy 
    simp' only [hy, hts _] with mfld_simps

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem times_cont_diff_within_at_local_invariant_prop_id
(x : H) : times_cont_diff_within_at_prop I I «expr∞»() id univ x :=
begin
  simp [] [] [] ["[", expr times_cont_diff_within_at_prop, "]"] [] [],
  have [] [":", expr times_cont_diff_within_at 𝕜 «expr∞»() id (range I) (I x)] [":=", expr times_cont_diff_id.times_cont_diff_at.times_cont_diff_within_at],
  apply [expr this.congr (λ y hy, _)],
  { simp [] [] ["only"] [] ["with", ident mfld_simps] [] },
  { simp [] [] ["only"] ["[", expr model_with_corners.right_inv I hy, "]"] ["with", ident mfld_simps] [] }
end

/-- A function is `n` times continuously differentiable within a set at a point in a manifold if
it is continuous and it is `n` times continuously differentiable in this set around this point, when
read in the preferred chart at this point. -/
def TimesContMdiffWithinAt (n : WithTop ℕ) (f : M → M') (s : Set M) (x : M) :=
  lift_prop_within_at (TimesContDiffWithinAtProp I I' n) f s x

/-- Abbreviation for `times_cont_mdiff_within_at I I' ⊤ f s x`. See also documentation for `smooth`.
-/
@[reducible]
def SmoothWithinAt (f : M → M') (s : Set M) (x : M) :=
  TimesContMdiffWithinAt I I' ⊤ f s x

/-- A function is `n` times continuously differentiable at a point in a manifold if
it is continuous and it is `n` times continuously differentiable around this point, when
read in the preferred chart at this point. -/
def TimesContMdiffAt (n : WithTop ℕ) (f : M → M') (x : M) :=
  TimesContMdiffWithinAt I I' n f univ x

/-- Abbreviation for `times_cont_mdiff_at I I' ⊤ f x`. See also documentation for `smooth`. -/
@[reducible]
def SmoothAt (f : M → M') (x : M) :=
  TimesContMdiffAt I I' ⊤ f x

/-- A function is `n` times continuously differentiable in a set of a manifold if it is continuous
and, for any pair of points, it is `n` times continuously differentiable on this set in the charts
around these points. -/
def TimesContMdiffOn (n : WithTop ℕ) (f : M → M') (s : Set M) :=
  ∀ x (_ : x ∈ s), TimesContMdiffWithinAt I I' n f s x

/-- Abbreviation for `times_cont_mdiff_on I I' ⊤ f s`. See also documentation for `smooth`. -/
@[reducible]
def SmoothOn (f : M → M') (s : Set M) :=
  TimesContMdiffOn I I' ⊤ f s

/-- A function is `n` times continuously differentiable in a manifold if it is continuous
and, for any pair of points, it is `n` times continuously differentiable in the charts
around these points. -/
def TimesContMdiff (n : WithTop ℕ) (f : M → M') :=
  ∀ x, TimesContMdiffAt I I' n f x

/-- Abbreviation for `times_cont_mdiff I I' ⊤ f`.
Short note to work with these abbreviations: a lemma of the form `times_cont_mdiff_foo.bar` will
apply fine to an assumption `smooth_foo` using dot notation or normal notation.
If the consequence `bar` of the lemma involves `times_cont_diff`, it is still better to restate
the lemma replacing `times_cont_diff` with `smooth` both in the assumption and in the conclusion,
to make it possible to use `smooth` consistently.
This also applies to `smooth_at`, `smooth_on` and `smooth_within_at`.-/
@[reducible]
def Smooth (f : M → M') :=
  TimesContMdiff I I' ⊤ f

/-! ### Basic properties of smooth functions between manifolds -/


variable{I I'}

theorem TimesContMdiff.smooth (h : TimesContMdiff I I' ⊤ f) : Smooth I I' f :=
  h

theorem Smooth.times_cont_mdiff (h : Smooth I I' f) : TimesContMdiff I I' ⊤ f :=
  h

theorem TimesContMdiffOn.smooth_on (h : TimesContMdiffOn I I' ⊤ f s) : SmoothOn I I' f s :=
  h

theorem SmoothOn.times_cont_mdiff_on (h : SmoothOn I I' f s) : TimesContMdiffOn I I' ⊤ f s :=
  h

theorem TimesContMdiffAt.smooth_at (h : TimesContMdiffAt I I' ⊤ f x) : SmoothAt I I' f x :=
  h

theorem SmoothAt.times_cont_mdiff_at (h : SmoothAt I I' f x) : TimesContMdiffAt I I' ⊤ f x :=
  h

theorem TimesContMdiffWithinAt.smooth_within_at (h : TimesContMdiffWithinAt I I' ⊤ f s x) : SmoothWithinAt I I' f s x :=
  h

theorem SmoothWithinAt.times_cont_mdiff_within_at (h : SmoothWithinAt I I' f s x) :
  TimesContMdiffWithinAt I I' ⊤ f s x :=
  h

theorem TimesContMdiff.times_cont_mdiff_at (h : TimesContMdiff I I' n f) : TimesContMdiffAt I I' n f x :=
  h x

theorem Smooth.smooth_at (h : Smooth I I' f) : SmoothAt I I' f x :=
  TimesContMdiff.times_cont_mdiff_at h

theorem times_cont_mdiff_within_at_univ : TimesContMdiffWithinAt I I' n f univ x ↔ TimesContMdiffAt I I' n f x :=
  Iff.rfl

theorem smooth_at_univ : SmoothWithinAt I I' f univ x ↔ SmoothAt I I' f x :=
  times_cont_mdiff_within_at_univ

theorem times_cont_mdiff_on_univ : TimesContMdiffOn I I' n f univ ↔ TimesContMdiff I I' n f :=
  by 
    simp only [TimesContMdiffOn, TimesContMdiff, times_cont_mdiff_within_at_univ, forall_prop_of_true, mem_univ]

theorem smooth_on_univ : SmoothOn I I' f univ ↔ Smooth I I' f :=
  times_cont_mdiff_on_univ

/-- One can reformulate smoothness within a set at a point as continuity within this set at this
point, and smoothness in the corresponding extended chart. -/
theorem times_cont_mdiff_within_at_iff :
  TimesContMdiffWithinAt I I' n f s x ↔
    ContinuousWithinAt f s x ∧
      TimesContDiffWithinAt 𝕜 n (extChartAt I' (f x) ∘ f ∘ (extChartAt I x).symm)
        ((extChartAt I x).Target ∩ (extChartAt I x).symm ⁻¹' (s ∩ f ⁻¹' (extChartAt I' (f x)).Source))
        (extChartAt I x x) :=
  by 
    rw [TimesContMdiffWithinAt, lift_prop_within_at, TimesContDiffWithinAtProp]
    congr 3
    mfldSetTac

/-- One can reformulate smoothness within a set at a point as continuity within this set at this
point, and smoothness in the corresponding extended chart. This form states smoothness of `f`
written in the `ext_chart_at`s within the set `(ext_chart_at I x).symm ⁻¹' s ∩ range I`. This set
is larger than the set
`(ext_chart_at I x).target ∩ (ext_chart_at I x).symm ⁻¹' (s ∩ f ⁻¹' (ext_chart_at I' (f x)).source)`
used in `times_cont_mdiff_within_at_iff` but their germs at `ext_chart_at I x x` are equal. It may
be useful to rewrite using `times_cont_mdiff_within_at_iff''` in the *assumptions* of a lemma and
using `times_cont_mdiff_within_at_iff` in the goal. -/
theorem times_cont_mdiff_within_at_iff'' :
  TimesContMdiffWithinAt I I' n f s x ↔
    ContinuousWithinAt f s x ∧
      TimesContDiffWithinAt 𝕜 n (writtenInExtChartAt I I' x f) ((extChartAt I x).symm ⁻¹' s ∩ range I)
        (extChartAt I x x) :=
  by 
    rw [times_cont_mdiff_within_at_iff, And.congr_right_iff]
    set e := extChartAt I x 
    set e' := extChartAt I' (f x)
    refine' fun hc => times_cont_diff_within_at_congr_nhds _ 
    rw [←e.image_source_inter_eq', ←ext_chart_at_map_nhds_within_eq_image, ←ext_chart_at_map_nhds_within, inter_comm,
      nhds_within_inter_of_mem]
    exact hc (ext_chart_at_source_mem_nhds _ _)

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- One can reformulate smoothness within a set at a point as continuity within this set at this
point, and smoothness in the corresponding extended chart in the target. -/
theorem times_cont_mdiff_within_at_iff_target : «expr ↔ »(times_cont_mdiff_within_at I I' n f s x, «expr ∧ »(continuous_within_at f s x, times_cont_mdiff_within_at I «expr𝓘( , )»(𝕜, E') n «expr ∘ »(ext_chart_at I' (f x), f) «expr ∩ »(s, «expr ⁻¹' »(f, (ext_chart_at I' (f x)).source)) x)) :=
begin
  rw ["[", expr times_cont_mdiff_within_at, ",", expr times_cont_mdiff_within_at, ",", expr lift_prop_within_at, ",", expr lift_prop_within_at, ",", "<-", expr and_assoc, "]"] [],
  have [ident cont] [":", expr «expr ↔ »(«expr ∧ »(continuous_within_at f s x, continuous_within_at «expr ∘ »(«expr ∘ »(I', chart_at H' (f x)), f) «expr ∩ »(s, «expr ⁻¹' »(f, (chart_at H' (f x)).to_local_equiv.source)) x), continuous_within_at f s x)] [],
  { refine [expr ⟨λ h, h.1, λ h, ⟨h, _⟩⟩],
    have [ident h₁] [":", expr continuous_within_at _ univ (chart_at H' (f x) (f x))] [],
    { exact [expr (model_with_corners.continuous I').continuous_within_at] },
    have [ident h₂] [] [":=", expr (chart_at H' (f x)).continuous_to_fun.continuous_within_at (mem_chart_source _ _)],
    convert [] [expr (h₁.comp' h₂).comp' h] [],
    simp [] [] [] [] [] [] },
  simp [] [] [] ["[", expr cont, ",", expr times_cont_diff_within_at_prop, "]"] [] []
end

theorem smooth_within_at_iff :
  SmoothWithinAt I I' f s x ↔
    ContinuousWithinAt f s x ∧
      TimesContDiffWithinAt 𝕜 ∞ (extChartAt I' (f x) ∘ f ∘ (extChartAt I x).symm)
        ((extChartAt I x).Target ∩ (extChartAt I x).symm ⁻¹' (s ∩ f ⁻¹' (extChartAt I' (f x)).Source))
        (extChartAt I x x) :=
  times_cont_mdiff_within_at_iff

theorem smooth_within_at_iff_target :
  SmoothWithinAt I I' f s x ↔
    ContinuousWithinAt f s x ∧
      SmoothWithinAt I 𝓘(𝕜, E') (extChartAt I' (f x) ∘ f) (s ∩ f ⁻¹' (extChartAt I' (f x)).Source) x :=
  times_cont_mdiff_within_at_iff_target

theorem times_cont_mdiff_at_ext_chart_at : TimesContMdiffAt I 𝓘(𝕜, E) n (extChartAt I x) x :=
  by 
    rw [TimesContMdiffAt, times_cont_mdiff_within_at_iff]
    refine' ⟨(ext_chart_at_continuous_at _ _).ContinuousWithinAt, _⟩
    refine' times_cont_diff_within_at_id.congr _ _ <;>
      simp' (config := { contextual := Bool.true.0 }) only with mfld_simps

include Is I's

/-- One can reformulate smoothness within a set at a point as continuity within this set at this
point, and smoothness in the corresponding extended chart. -/
theorem times_cont_mdiff_within_at_iff' {x' : M} {y : M'} (hx : x' ∈ (chart_at H x).Source)
  (hy : f x' ∈ (chart_at H' y).Source) :
  TimesContMdiffWithinAt I I' n f s x' ↔
    ContinuousWithinAt f s x' ∧
      TimesContDiffWithinAt 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
        ((extChartAt I x).Target ∩ (extChartAt I x).symm ⁻¹' (s ∩ f ⁻¹' (extChartAt I' y).Source))
        (extChartAt I x x') :=
  by 
    refine'
      ((times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_indep_chart
            (StructureGroupoid.chart_mem_maximal_atlas _ x) hx (StructureGroupoid.chart_mem_maximal_atlas _ y) hy).trans
        _ 
    rw [TimesContDiffWithinAtProp, iff_eq_eq]
    congr 2
    mfldSetTac

omit I's

theorem times_cont_mdiff_at_ext_chart_at' {x' : M} (h : x' ∈ (chart_at H x).Source) :
  TimesContMdiffAt I 𝓘(𝕜, E) n (extChartAt I x) x' :=
  by 
    refine' (times_cont_mdiff_within_at_iff' h (mem_chart_source _ _)).2 _ 
    refine' ⟨(ext_chart_at_continuous_at' _ _ _).ContinuousWithinAt, _⟩
    ·
      rwa [ext_chart_at_source]
    refine' times_cont_diff_within_at_id.congr' _ _ <;>
      simp' (config := { contextual := Bool.true.0 }) only [h] with mfld_simps

include I's

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- One can reformulate smoothness on a set as continuity on this set, and smoothness in any
extended chart. -/
theorem times_cont_mdiff_on_iff : «expr ↔ »(times_cont_mdiff_on I I' n f s, «expr ∧ »(continuous_on f s, ∀
  (x : M)
  (y : M'), times_cont_diff_on 𝕜 n «expr ∘ »(ext_chart_at I' y, «expr ∘ »(f, (ext_chart_at I x).symm)) «expr ∩ »((ext_chart_at I x).target, «expr ⁻¹' »((ext_chart_at I x).symm, «expr ∩ »(s, «expr ⁻¹' »(f, (ext_chart_at I' y).source)))))) :=
begin
  split,
  { assume [binders (h)],
    refine [expr ⟨λ x hx, (h x hx).1, λ x y z hz, _⟩],
    simp [] [] ["only"] [] ["with", ident mfld_simps] ["at", ident hz],
    let [ident w] [] [":=", expr (ext_chart_at I x).symm z],
    have [] [":", expr «expr ∈ »(w, s)] [],
    by simp [] [] ["only"] ["[", expr w, ",", expr hz, "]"] ["with", ident mfld_simps] [],
    specialize [expr h w this],
    have [ident w1] [":", expr «expr ∈ »(w, (chart_at H x).source)] [],
    by simp [] [] ["only"] ["[", expr w, ",", expr hz, "]"] ["with", ident mfld_simps] [],
    have [ident w2] [":", expr «expr ∈ »(f w, (chart_at H' y).source)] [],
    by simp [] [] ["only"] ["[", expr w, ",", expr hz, "]"] ["with", ident mfld_simps] [],
    convert [] [expr (((times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_indep_chart (structure_groupoid.chart_mem_maximal_atlas _ x) w1 (structure_groupoid.chart_mem_maximal_atlas _ y) w2).1 h).2] ["using", 1],
    { mfld_set_tac },
    { simp [] [] ["only"] ["[", expr w, ",", expr hz, "]"] ["with", ident mfld_simps] [] } },
  { rintros ["⟨", ident hcont, ",", ident hdiff, "⟩", ident x, ident hx],
    refine [expr ⟨hcont x hx, _⟩],
    have [ident Z] [] [":=", expr hdiff x (f x) (ext_chart_at I x x) (by simp [] [] ["only"] ["[", expr hx, "]"] ["with", ident mfld_simps] [])],
    dsimp [] ["[", expr times_cont_diff_within_at_prop, "]"] [] [],
    convert [] [expr Z] ["using", 1],
    mfld_set_tac }
end

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- One can reformulate smoothness on a set as continuity on this set, and smoothness in any
extended chart in the target. -/
theorem times_cont_mdiff_on_iff_target : «expr ↔ »(times_cont_mdiff_on I I' n f s, «expr ∧ »(continuous_on f s, ∀
  y : M', times_cont_mdiff_on I «expr𝓘( , )»(𝕜, E') n «expr ∘ »(ext_chart_at I' y, f) «expr ∩ »(s, «expr ⁻¹' »(f, (ext_chart_at I' y).source)))) :=
begin
  inhabit [expr E'] [],
  simp [] [] ["only"] ["[", expr times_cont_mdiff_on_iff, ",", expr model_with_corners.source_eq, ",", expr chart_at_self_eq, ",", expr local_homeomorph.refl_local_equiv, ",", expr local_equiv.refl_trans, ",", expr ext_chart_at.equations._eqn_1, ",", expr set.preimage_univ, ",", expr set.inter_univ, ",", expr and.congr_right_iff, "]"] [] [],
  intros [ident h],
  split,
  { refine [expr λ h' y, ⟨_, λ x _, h' x y⟩],
    have [ident h''] [":", expr continuous_on _ univ] [":=", expr (model_with_corners.continuous I').continuous_on],
    convert [] [expr (h''.comp' (chart_at H' y).continuous_to_fun).comp' h] [],
    simp [] [] [] [] [] [] },
  { exact [expr λ h' x y, (h' y).2 x (default E')] }
end

theorem smooth_on_iff :
  SmoothOn I I' f s ↔
    ContinuousOn f s ∧
      ∀ (x : M) (y : M'),
        TimesContDiffOn 𝕜 ⊤ (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
          ((extChartAt I x).Target ∩ (extChartAt I x).symm ⁻¹' (s ∩ f ⁻¹' (extChartAt I' y).Source)) :=
  times_cont_mdiff_on_iff

theorem smooth_on_iff_target :
  SmoothOn I I' f s ↔
    ContinuousOn f s ∧ ∀ (y : M'), SmoothOn I 𝓘(𝕜, E') (extChartAt I' y ∘ f) (s ∩ f ⁻¹' (extChartAt I' y).Source) :=
  times_cont_mdiff_on_iff_target

/-- One can reformulate smoothness as continuity and smoothness in any extended chart. -/
theorem times_cont_mdiff_iff :
  TimesContMdiff I I' n f ↔
    Continuous f ∧
      ∀ (x : M) (y : M'),
        TimesContDiffOn 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
          ((extChartAt I x).Target ∩ (extChartAt I x).symm ⁻¹' (f ⁻¹' (extChartAt I' y).Source)) :=
  by 
    simp [←times_cont_mdiff_on_univ, times_cont_mdiff_on_iff, continuous_iff_continuous_on_univ]

/-- One can reformulate smoothness as continuity and smoothness in any extended chart in the
target. -/
theorem times_cont_mdiff_iff_target :
  TimesContMdiff I I' n f ↔
    Continuous f ∧ ∀ (y : M'), TimesContMdiffOn I 𝓘(𝕜, E') n (extChartAt I' y ∘ f) (f ⁻¹' (extChartAt I' y).Source) :=
  by 
    rw [←times_cont_mdiff_on_univ, times_cont_mdiff_on_iff_target]
    simp [continuous_iff_continuous_on_univ]

theorem smooth_iff :
  Smooth I I' f ↔
    Continuous f ∧
      ∀ (x : M) (y : M'),
        TimesContDiffOn 𝕜 ⊤ (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
          ((extChartAt I x).Target ∩ (extChartAt I x).symm ⁻¹' (f ⁻¹' (extChartAt I' y).Source)) :=
  times_cont_mdiff_iff

theorem smooth_iff_target :
  Smooth I I' f ↔
    Continuous f ∧ ∀ (y : M'), SmoothOn I 𝓘(𝕜, E') (extChartAt I' y ∘ f) (f ⁻¹' (extChartAt I' y).Source) :=
  times_cont_mdiff_iff_target

omit Is I's

/-! ### Deducing smoothness from higher smoothness -/


theorem TimesContMdiffWithinAt.of_le (hf : TimesContMdiffWithinAt I I' n f s x) (le : m ≤ n) :
  TimesContMdiffWithinAt I I' m f s x :=
  ⟨hf.1, hf.2.of_le le⟩

theorem TimesContMdiffAt.of_le (hf : TimesContMdiffAt I I' n f x) (le : m ≤ n) : TimesContMdiffAt I I' m f x :=
  TimesContMdiffWithinAt.of_le hf le

theorem TimesContMdiffOn.of_le (hf : TimesContMdiffOn I I' n f s) (le : m ≤ n) : TimesContMdiffOn I I' m f s :=
  fun x hx => (hf x hx).of_le le

theorem TimesContMdiff.of_le (hf : TimesContMdiff I I' n f) (le : m ≤ n) : TimesContMdiff I I' m f :=
  fun x => (hf x).of_le le

/-! ### Deducing smoothness from smoothness one step beyond -/


theorem TimesContMdiffWithinAt.of_succ {n : ℕ} (h : TimesContMdiffWithinAt I I' n.succ f s x) :
  TimesContMdiffWithinAt I I' n f s x :=
  h.of_le (WithTop.coe_le_coe.2 (Nat.le_succₓ n))

theorem TimesContMdiffAt.of_succ {n : ℕ} (h : TimesContMdiffAt I I' n.succ f x) : TimesContMdiffAt I I' n f x :=
  TimesContMdiffWithinAt.of_succ h

theorem TimesContMdiffOn.of_succ {n : ℕ} (h : TimesContMdiffOn I I' n.succ f s) : TimesContMdiffOn I I' n f s :=
  fun x hx => (h x hx).of_succ

theorem TimesContMdiff.of_succ {n : ℕ} (h : TimesContMdiff I I' n.succ f) : TimesContMdiff I I' n f :=
  fun x => (h x).of_succ

/-! ### Deducing continuity from smoothness-/


theorem TimesContMdiffWithinAt.continuous_within_at (hf : TimesContMdiffWithinAt I I' n f s x) :
  ContinuousWithinAt f s x :=
  hf.1

theorem TimesContMdiffAt.continuous_at (hf : TimesContMdiffAt I I' n f x) : ContinuousAt f x :=
  (continuous_within_at_univ _ _).1$ TimesContMdiffWithinAt.continuous_within_at hf

theorem TimesContMdiffOn.continuous_on (hf : TimesContMdiffOn I I' n f s) : ContinuousOn f s :=
  fun x hx => (hf x hx).ContinuousWithinAt

theorem TimesContMdiff.continuous (hf : TimesContMdiff I I' n f) : Continuous f :=
  continuous_iff_continuous_at.2$ fun x => (hf x).ContinuousAt

/-! ### Deducing differentiability from smoothness -/


theorem TimesContMdiffWithinAt.mdifferentiable_within_at (hf : TimesContMdiffWithinAt I I' n f s x) (hn : 1 ≤ n) :
  MdifferentiableWithinAt I I' f s x :=
  by 
    suffices h : MdifferentiableWithinAt I I' f (s ∩ f ⁻¹' (extChartAt I' (f x)).Source) x
    ·
      rwa [mdifferentiable_within_at_inter'] at h 
      apply hf.1.preimage_mem_nhds_within 
      exact IsOpen.mem_nhds (ext_chart_at_open_source I' (f x)) (mem_ext_chart_source I' (f x))
    rw [mdifferentiable_within_at_iff]
    exact
      ⟨hf.1.mono (inter_subset_left _ _),
        (hf.2.DifferentiableWithinAt hn).mono
          (by 
            mfldSetTac)⟩

theorem TimesContMdiffAt.mdifferentiable_at (hf : TimesContMdiffAt I I' n f x) (hn : 1 ≤ n) :
  MdifferentiableAt I I' f x :=
  mdifferentiable_within_at_univ.1$ TimesContMdiffWithinAt.mdifferentiable_within_at hf hn

theorem TimesContMdiffOn.mdifferentiable_on (hf : TimesContMdiffOn I I' n f s) (hn : 1 ≤ n) :
  MdifferentiableOn I I' f s :=
  fun x hx => (hf x hx).MdifferentiableWithinAt hn

theorem TimesContMdiff.mdifferentiable (hf : TimesContMdiff I I' n f) (hn : 1 ≤ n) : Mdifferentiable I I' f :=
  fun x => (hf x).MdifferentiableAt hn

theorem Smooth.mdifferentiable (hf : Smooth I I' f) : Mdifferentiable I I' f :=
  TimesContMdiff.mdifferentiable hf le_top

theorem Smooth.mdifferentiable_at (hf : Smooth I I' f) : MdifferentiableAt I I' f x :=
  hf.mdifferentiable x

theorem Smooth.mdifferentiable_within_at (hf : Smooth I I' f) : MdifferentiableWithinAt I I' f s x :=
  hf.mdifferentiable_at.mdifferentiable_within_at

/-! ### `C^∞` smoothness -/


theorem times_cont_mdiff_within_at_top : SmoothWithinAt I I' f s x ↔ ∀ (n : ℕ), TimesContMdiffWithinAt I I' n f s x :=
  ⟨fun h n => ⟨h.1, times_cont_diff_within_at_top.1 h.2 n⟩,
    fun H => ⟨(H 0).1, times_cont_diff_within_at_top.2 fun n => (H n).2⟩⟩

theorem times_cont_mdiff_at_top : SmoothAt I I' f x ↔ ∀ (n : ℕ), TimesContMdiffAt I I' n f x :=
  times_cont_mdiff_within_at_top

theorem times_cont_mdiff_on_top : SmoothOn I I' f s ↔ ∀ (n : ℕ), TimesContMdiffOn I I' n f s :=
  ⟨fun h n => h.of_le le_top, fun h x hx => times_cont_mdiff_within_at_top.2 fun n => h n x hx⟩

theorem times_cont_mdiff_top : Smooth I I' f ↔ ∀ (n : ℕ), TimesContMdiff I I' n f :=
  ⟨fun h n => h.of_le le_top, fun h x => times_cont_mdiff_within_at_top.2 fun n => h n x⟩

theorem times_cont_mdiff_within_at_iff_nat :
  TimesContMdiffWithinAt I I' n f s x ↔ ∀ (m : ℕ), (m : WithTop ℕ) ≤ n → TimesContMdiffWithinAt I I' m f s x :=
  by 
    refine' ⟨fun h m hm => h.of_le hm, fun h => _⟩
    cases n
    ·
      exact times_cont_mdiff_within_at_top.2 fun n => h n le_top
    ·
      exact h n (le_reflₓ _)

/-! ### Restriction to a smaller set -/


theorem TimesContMdiffWithinAt.mono (hf : TimesContMdiffWithinAt I I' n f s x) (hts : t ⊆ s) :
  TimesContMdiffWithinAt I I' n f t x :=
  StructureGroupoid.LocalInvariantProp.lift_prop_within_at_mono
    (times_cont_diff_within_at_local_invariant_prop_mono I I' n) hf hts

theorem TimesContMdiffAt.times_cont_mdiff_within_at (hf : TimesContMdiffAt I I' n f x) :
  TimesContMdiffWithinAt I I' n f s x :=
  TimesContMdiffWithinAt.mono hf (subset_univ _)

theorem SmoothAt.smooth_within_at (hf : SmoothAt I I' f x) : SmoothWithinAt I I' f s x :=
  TimesContMdiffAt.times_cont_mdiff_within_at hf

theorem TimesContMdiffOn.mono (hf : TimesContMdiffOn I I' n f s) (hts : t ⊆ s) : TimesContMdiffOn I I' n f t :=
  fun x hx => (hf x (hts hx)).mono hts

theorem TimesContMdiff.times_cont_mdiff_on (hf : TimesContMdiff I I' n f) : TimesContMdiffOn I I' n f s :=
  fun x hx => (hf x).TimesContMdiffWithinAt

theorem Smooth.smooth_on (hf : Smooth I I' f) : SmoothOn I I' f s :=
  TimesContMdiff.times_cont_mdiff_on hf

theorem times_cont_mdiff_within_at_inter' (ht : t ∈ 𝓝[s] x) :
  TimesContMdiffWithinAt I I' n f (s ∩ t) x ↔ TimesContMdiffWithinAt I I' n f s x :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_inter' ht

theorem times_cont_mdiff_within_at_inter (ht : t ∈ 𝓝 x) :
  TimesContMdiffWithinAt I I' n f (s ∩ t) x ↔ TimesContMdiffWithinAt I I' n f s x :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_inter ht

theorem TimesContMdiffWithinAt.times_cont_mdiff_at (h : TimesContMdiffWithinAt I I' n f s x) (ht : s ∈ 𝓝 x) :
  TimesContMdiffAt I I' n f x :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_at_of_lift_prop_within_at h ht

theorem SmoothWithinAt.smooth_at (h : SmoothWithinAt I I' f s x) (ht : s ∈ 𝓝 x) : SmoothAt I I' f x :=
  TimesContMdiffWithinAt.times_cont_mdiff_at h ht

include Is

theorem times_cont_mdiff_on_ext_chart_at : TimesContMdiffOn I 𝓘(𝕜, E) n (extChartAt I x) (chart_at H x).Source :=
  fun x' hx' => (times_cont_mdiff_at_ext_chart_at' hx').TimesContMdiffWithinAt

include I's

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- A function is `C^n` within a set at a point, for `n : ℕ`, if and only if it is `C^n` on
a neighborhood of this point. -/
theorem times_cont_mdiff_within_at_iff_times_cont_mdiff_on_nhds
{n : exprℕ()} : «expr ↔ »(times_cont_mdiff_within_at I I' n f s x, «expr∃ , »((u «expr ∈ » «expr𝓝[ ] »(insert x s, x)), times_cont_mdiff_on I I' n f u)) :=
begin
  split,
  { assume [binders (h)],
    obtain ["⟨", ident o, ",", ident o_open, ",", ident xo, ",", ident ho, ",", ident h'o, "⟩", ":", expr «expr∃ , »((o : set M), «expr ∧ »(is_open o, «expr ∧ »(«expr ∈ »(x, o), «expr ∧ »(«expr ⊆ »(o, (chart_at H x).source), «expr ⊆ »(«expr ∩ »(o, s), «expr ⁻¹' »(f, (chart_at H' (f x)).source))))))],
    { have [] [":", expr «expr ∈ »((chart_at H' (f x)).source, expr𝓝() (f x))] [":=", expr is_open.mem_nhds (local_homeomorph.open_source _) (mem_chart_source H' (f x))],
      rcases [expr mem_nhds_within.1 (h.1.preimage_mem_nhds_within this), "with", "⟨", ident u, ",", ident u_open, ",", ident xu, ",", ident hu, "⟩"],
      refine [expr ⟨«expr ∩ »(u, (chart_at H x).source), _, ⟨xu, mem_chart_source _ _⟩, _, _⟩],
      { exact [expr is_open.inter u_open (local_homeomorph.open_source _)] },
      { assume [binders (y hy)],
        exact [expr hy.2] },
      { assume [binders (y hy)],
        exact [expr hu ⟨hy.1.1, hy.2⟩] } },
    have [ident h'] [":", expr times_cont_mdiff_within_at I I' n f «expr ∩ »(s, o) x] [":=", expr h.mono (inter_subset_left _ _)],
    simp [] [] ["only"] ["[", expr times_cont_mdiff_within_at, ",", expr lift_prop_within_at, ",", expr times_cont_diff_within_at_prop, "]"] [] ["at", ident h'],
    rcases [expr h.2.times_cont_diff_on (le_refl _), "with", "⟨", ident u, ",", ident u_nhds, ",", ident u_subset, ",", ident hu, "⟩"],
    let [ident v] [] [":=", expr «expr ∩ »(«expr ∩ »(insert x s, o), «expr ⁻¹' »(ext_chart_at I x, u))],
    have [ident v_incl] [":", expr «expr ⊆ »(v, (chart_at H x).source)] [":=", expr λ y hy, ho hy.1.2],
    have [ident v_incl'] [":", expr ∀ y «expr ∈ » v, «expr ∈ »(f y, (chart_at H' (f x)).source)] [],
    { assume [binders (y hy)],
      rcases [expr hy.1.1, "with", ident rfl, "|", ident h'],
      { simp [] [] ["only"] [] ["with", ident mfld_simps] [] },
      { apply [expr h'o ⟨hy.1.2, h'⟩] } },
    refine [expr ⟨v, _, _⟩],
    show [expr «expr ∈ »(v, «expr𝓝[ ] »(insert x s, x))],
    { rw [expr nhds_within_restrict _ xo o_open] [],
      refine [expr filter.inter_mem self_mem_nhds_within _],
      suffices [] [":", expr «expr ∈ »(u, «expr𝓝[ ] »(«expr '' »(ext_chart_at I x, «expr ∩ »(insert x s, o)), ext_chart_at I x x))],
      from [expr (ext_chart_at_continuous_at I x).continuous_within_at.preimage_mem_nhds_within' this],
      apply [expr nhds_within_mono _ _ u_nhds],
      rw [expr image_subset_iff] [],
      assume [binders (y hy)],
      rcases [expr hy.1, "with", ident rfl, "|", ident h'],
      { simp [] [] ["only"] ["[", expr mem_insert_iff, "]"] ["with", ident mfld_simps] [] },
      { simp [] [] ["only"] ["[", expr mem_insert_iff, ",", expr ho hy.2, ",", expr h', ",", expr h'o ⟨hy.2, h'⟩, "]"] ["with", ident mfld_simps] [] } },
    show [expr times_cont_mdiff_on I I' n f v],
    { assume [binders (y hy)],
      apply [expr ((times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_indep_chart (structure_groupoid.chart_mem_maximal_atlas _ x) (v_incl hy) (structure_groupoid.chart_mem_maximal_atlas _ (f x)) (v_incl' y hy)).2],
      split,
      { apply [expr (((ext_chart_at_continuous_on_symm I' (f x) _ _).comp' (hu _ hy.2).continuous_within_at).comp' (ext_chart_at_continuous_on I x _ _)).congr_mono],
        { assume [binders (z hz)],
          simp [] [] ["only"] ["[", expr v_incl hz, ",", expr v_incl' z hz, "]"] ["with", ident mfld_simps] [] },
        { assume [binders (z hz)],
          simp [] [] ["only"] ["[", expr v_incl hz, ",", expr v_incl' z hz, "]"] ["with", ident mfld_simps] [],
          exact [expr hz.2] },
        { simp [] [] ["only"] ["[", expr v_incl hy, ",", expr v_incl' y hy, "]"] ["with", ident mfld_simps] [] },
        { simp [] [] ["only"] ["[", expr v_incl hy, ",", expr v_incl' y hy, "]"] ["with", ident mfld_simps] [] },
        { simp [] [] ["only"] ["[", expr v_incl hy, "]"] ["with", ident mfld_simps] [] } },
      { apply [expr hu.mono],
        { assume [binders (z hz)],
          simp [] [] ["only"] ["[", expr v, "]"] ["with", ident mfld_simps] ["at", ident hz],
          have [] [":", expr «expr ∈ »(I (chart_at H x ((chart_at H x).symm (I.symm z))), u)] [],
          by simp [] [] ["only"] ["[", expr hz, "]"] [] [],
          simpa [] [] ["only"] ["[", expr hz, "]"] ["with", ident mfld_simps] ["using", expr this] },
        { have [ident exty] [":", expr «expr ∈ »(I (chart_at H x y), u)] [":=", expr hy.2],
          simp [] [] ["only"] ["[", expr v_incl hy, ",", expr v_incl' y hy, ",", expr exty, ",", expr hy.1.1, ",", expr hy.1.2, "]"] ["with", ident mfld_simps] [] } } } },
  { rintros ["⟨", ident u, ",", ident u_nhds, ",", ident hu, "⟩"],
    have [] [":", expr times_cont_mdiff_within_at I I' «expr↑ »(n) f «expr ∩ »(insert x s, u) x] [],
    { have [] [":", expr «expr ∈ »(x, insert x s)] [":=", expr mem_insert x s],
      exact [expr hu.mono (inter_subset_right _ _) _ ⟨this, mem_of_mem_nhds_within this u_nhds⟩] },
    rw [expr times_cont_mdiff_within_at_inter' u_nhds] ["at", ident this],
    exact [expr this.mono (subset_insert x s)] }
end

/-- A function is `C^n` at a point, for `n : ℕ`, if and only if it is `C^n` on
a neighborhood of this point. -/
theorem times_cont_mdiff_at_iff_times_cont_mdiff_on_nhds {n : ℕ} :
  TimesContMdiffAt I I' n f x ↔ ∃ (u : _)(_ : u ∈ 𝓝 x), TimesContMdiffOn I I' n f u :=
  by 
    simp [←times_cont_mdiff_within_at_univ, times_cont_mdiff_within_at_iff_times_cont_mdiff_on_nhds, nhds_within_univ]

omit Is I's

/-! ### Congruence lemmas -/


theorem TimesContMdiffWithinAt.congr (h : TimesContMdiffWithinAt I I' n f s x) (h₁ : ∀ y (_ : y ∈ s), f₁ y = f y)
  (hx : f₁ x = f x) : TimesContMdiffWithinAt I I' n f₁ s x :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_congr h h₁ hx

theorem times_cont_mdiff_within_at_congr (h₁ : ∀ y (_ : y ∈ s), f₁ y = f y) (hx : f₁ x = f x) :
  TimesContMdiffWithinAt I I' n f₁ s x ↔ TimesContMdiffWithinAt I I' n f s x :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_congr_iff h₁ hx

theorem TimesContMdiffWithinAt.congr_of_eventually_eq (h : TimesContMdiffWithinAt I I' n f s x) (h₁ : f₁ =ᶠ[𝓝[s] x] f)
  (hx : f₁ x = f x) : TimesContMdiffWithinAt I I' n f₁ s x :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_congr_of_eventually_eq h h₁ hx

theorem Filter.EventuallyEq.times_cont_mdiff_within_at_iff (h₁ : f₁ =ᶠ[𝓝[s] x] f) (hx : f₁ x = f x) :
  TimesContMdiffWithinAt I I' n f₁ s x ↔ TimesContMdiffWithinAt I I' n f s x :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_congr_iff_of_eventually_eq h₁ hx

theorem TimesContMdiffAt.congr_of_eventually_eq (h : TimesContMdiffAt I I' n f x) (h₁ : f₁ =ᶠ[𝓝 x] f) :
  TimesContMdiffAt I I' n f₁ x :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_at_congr_of_eventually_eq h h₁

theorem Filter.EventuallyEq.times_cont_mdiff_at_iff (h₁ : f₁ =ᶠ[𝓝 x] f) :
  TimesContMdiffAt I I' n f₁ x ↔ TimesContMdiffAt I I' n f x :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_at_congr_iff_of_eventually_eq h₁

theorem TimesContMdiffOn.congr (h : TimesContMdiffOn I I' n f s) (h₁ : ∀ y (_ : y ∈ s), f₁ y = f y) :
  TimesContMdiffOn I I' n f₁ s :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_on_congr h h₁

theorem times_cont_mdiff_on_congr (h₁ : ∀ y (_ : y ∈ s), f₁ y = f y) :
  TimesContMdiffOn I I' n f₁ s ↔ TimesContMdiffOn I I' n f s :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_on_congr_iff h₁

/-! ### Locality -/


/-- Being `C^n` is a local property. -/
theorem times_cont_mdiff_on_of_locally_times_cont_mdiff_on
  (h : ∀ x (_ : x ∈ s), ∃ u, IsOpen u ∧ x ∈ u ∧ TimesContMdiffOn I I' n f (s ∩ u)) : TimesContMdiffOn I I' n f s :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_on_of_locally_lift_prop_on h

theorem times_cont_mdiff_of_locally_times_cont_mdiff_on (h : ∀ x, ∃ u, IsOpen u ∧ x ∈ u ∧ TimesContMdiffOn I I' n f u) :
  TimesContMdiff I I' n f :=
  (times_cont_diff_within_at_local_invariant_prop I I' n).lift_prop_of_locally_lift_prop_on h

/-! ### Smoothness of the composition of smooth functions between manifolds -/


section Composition

variable{E'' :
    Type
      _}[NormedGroup
      E''][NormedSpace 𝕜
      E'']{H'' :
    Type
      _}[TopologicalSpace
      H'']{I'' : ModelWithCorners 𝕜 E'' H''}{M'' : Type _}[TopologicalSpace M''][ChartedSpace H'' M'']

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The composition of `C^n` functions within domains at points is `C^n`. -/
theorem times_cont_mdiff_within_at.comp
{t : set M'}
{g : M' → M''}
(x : M)
(hg : times_cont_mdiff_within_at I' I'' n g t (f x))
(hf : times_cont_mdiff_within_at I I' n f s x)
(st : maps_to f s t) : times_cont_mdiff_within_at I I'' n «expr ∘ »(g, f) s x :=
begin
  rw [expr times_cont_mdiff_within_at_iff''] ["at", ident hg, ident hf, "⊢"],
  refine [expr ⟨hg.1.comp hf.1 st, _⟩],
  set [] [ident e] [] [":="] [expr ext_chart_at I x] [],
  set [] [ident e'] [] [":="] [expr ext_chart_at I' (f x)] [],
  set [] [ident e''] [] [":="] [expr ext_chart_at I'' (g (f x))] [],
  have [] [":", expr «expr = »(e' (f x), written_in_ext_chart_at I I' x f (e x))] [],
  by simp [] [] ["only"] ["[", expr e, ",", expr e', "]"] ["with", ident mfld_simps] [],
  rw [expr this] ["at", ident hg],
  have [ident A] [":", expr «expr∀ᶠ in , »((y), «expr𝓝[ ] »(«expr ∩ »(«expr ⁻¹' »(e.symm, s), range I), e x), «expr ∧ »(«expr ∈ »(y, e.target), «expr ∧ »(«expr ∈ »(f (e.symm y), t), «expr ∧ »(«expr ∈ »(f (e.symm y), e'.source), «expr ∈ »(g (f (e.symm y)), e''.source)))))] [],
  { simp [] [] ["only"] ["[", "<-", expr ext_chart_at_map_nhds_within, ",", expr eventually_map, "]"] [] [],
    filter_upwards ["[", expr hf.1.tendsto (ext_chart_at_source_mem_nhds I' (f x)), ",", expr (hg.1.comp hf.1 st).tendsto (ext_chart_at_source_mem_nhds I'' (g (f x))), ",", expr inter_mem_nhds_within s (ext_chart_at_source_mem_nhds I x), "]"] [],
    rintros [ident x', "(", ident hfx', ":", expr «expr ∈ »(f x', _), ")", "(", ident hgfx', ":", expr «expr ∈ »(g (f x'), _), ")", "⟨", ident hx's, ",", ident hx', "⟩"],
    simp [] [] ["only"] ["[", expr e.map_source hx', ",", expr true_and, ",", expr e.left_inv hx', ",", expr st hx's, ",", "*", "]"] [] [] },
  refine [expr ((hg.2.comp _ (hf.2.mono (inter_subset_right _ _)) (inter_subset_left _ _)).mono_of_mem (inter_mem _ self_mem_nhds_within)).congr_of_eventually_eq _ _],
  { filter_upwards ["[", expr A, "]"] [],
    rintro [ident x', "⟨", ident hx', ",", ident ht, ",", ident hfx', ",", ident hgfx', "⟩"],
    simp [] [] ["only"] ["[", "*", ",", expr mem_preimage, ",", expr written_in_ext_chart_at, ",", expr («expr ∘ »), ",", expr mem_inter_eq, ",", expr e'.left_inv, ",", expr true_and, "]"] [] [],
    exact [expr mem_range_self _] },
  { filter_upwards ["[", expr A, "]"] [],
    rintro [ident x', "⟨", ident hx', ",", ident ht, ",", ident hfx', ",", ident hgfx', "⟩"],
    simp [] [] ["only"] ["[", "*", ",", expr («expr ∘ »), ",", expr written_in_ext_chart_at, ",", expr e'.left_inv, "]"] [] [] },
  { simp [] [] ["only"] ["[", expr written_in_ext_chart_at, ",", expr («expr ∘ »), ",", expr mem_ext_chart_source, ",", expr e.left_inv, ",", expr e'.left_inv, "]"] [] [] }
end

/-- The composition of `C^n` functions on domains is `C^n`. -/
theorem TimesContMdiffOn.comp {t : Set M'} {g : M' → M''} (hg : TimesContMdiffOn I' I'' n g t)
  (hf : TimesContMdiffOn I I' n f s) (st : s ⊆ f ⁻¹' t) : TimesContMdiffOn I I'' n (g ∘ f) s :=
  fun x hx => (hg _ (st hx)).comp x (hf x hx) st

/-- The composition of `C^n` functions on domains is `C^n`. -/
theorem TimesContMdiffOn.comp' {t : Set M'} {g : M' → M''} (hg : TimesContMdiffOn I' I'' n g t)
  (hf : TimesContMdiffOn I I' n f s) : TimesContMdiffOn I I'' n (g ∘ f) (s ∩ f ⁻¹' t) :=
  hg.comp (hf.mono (inter_subset_left _ _)) (inter_subset_right _ _)

/-- The composition of `C^n` functions is `C^n`. -/
theorem TimesContMdiff.comp {g : M' → M''} (hg : TimesContMdiff I' I'' n g) (hf : TimesContMdiff I I' n f) :
  TimesContMdiff I I'' n (g ∘ f) :=
  by 
    rw [←times_cont_mdiff_on_univ] at hf hg⊢
    exact hg.comp hf subset_preimage_univ

/-- The composition of `C^n` functions within domains at points is `C^n`. -/
theorem TimesContMdiffWithinAt.comp' {t : Set M'} {g : M' → M''} (x : M)
  (hg : TimesContMdiffWithinAt I' I'' n g t (f x)) (hf : TimesContMdiffWithinAt I I' n f s x) :
  TimesContMdiffWithinAt I I'' n (g ∘ f) (s ∩ f ⁻¹' t) x :=
  hg.comp x (hf.mono (inter_subset_left _ _)) (inter_subset_right _ _)

/-- `g ∘ f` is `C^n` within `s` at `x` if `g` is `C^n` at `f x` and
`f` is `C^n` within `s` at `x`. -/
theorem TimesContMdiffAt.comp_times_cont_mdiff_within_at {g : M' → M''} (x : M) (hg : TimesContMdiffAt I' I'' n g (f x))
  (hf : TimesContMdiffWithinAt I I' n f s x) : TimesContMdiffWithinAt I I'' n (g ∘ f) s x :=
  hg.comp x hf (maps_to_univ _ _)

/-- The composition of `C^n` functions at points is `C^n`. -/
theorem TimesContMdiffAt.comp {g : M' → M''} (x : M) (hg : TimesContMdiffAt I' I'' n g (f x))
  (hf : TimesContMdiffAt I I' n f x) : TimesContMdiffAt I I'' n (g ∘ f) x :=
  hg.comp x hf (maps_to_univ _ _)

theorem TimesContMdiff.comp_times_cont_mdiff_on {f : M → M'} {g : M' → M''} {s : Set M} (hg : TimesContMdiff I' I'' n g)
  (hf : TimesContMdiffOn I I' n f s) : TimesContMdiffOn I I'' n (g ∘ f) s :=
  hg.times_cont_mdiff_on.comp hf Set.subset_preimage_univ

theorem Smooth.comp_smooth_on {f : M → M'} {g : M' → M''} {s : Set M} (hg : Smooth I' I'' g) (hf : SmoothOn I I' f s) :
  SmoothOn I I'' (g ∘ f) s :=
  hg.smooth_on.comp hf Set.subset_preimage_univ

end Composition

/-! ### Atlas members are smooth -/


section Atlas

variable{e : LocalHomeomorph M H}

include Is

/-- An atlas member is `C^n` for any `n`. -/
theorem times_cont_mdiff_on_of_mem_maximal_atlas (h : e ∈ maximal_atlas I M) : TimesContMdiffOn I I n e e.source :=
  TimesContMdiffOn.of_le
    ((times_cont_diff_within_at_local_invariant_prop I I ∞).lift_prop_on_of_mem_maximal_atlas
      (times_cont_diff_within_at_local_invariant_prop_id I) h)
    le_top

/-- The inverse of an atlas member is `C^n` for any `n`. -/
theorem times_cont_mdiff_on_symm_of_mem_maximal_atlas (h : e ∈ maximal_atlas I M) :
  TimesContMdiffOn I I n e.symm e.target :=
  TimesContMdiffOn.of_le
    ((times_cont_diff_within_at_local_invariant_prop I I ∞).lift_prop_on_symm_of_mem_maximal_atlas
      (times_cont_diff_within_at_local_invariant_prop_id I) h)
    le_top

theorem times_cont_mdiff_on_chart : TimesContMdiffOn I I n (chart_at H x) (chart_at H x).Source :=
  times_cont_mdiff_on_of_mem_maximal_atlas ((timesContDiffGroupoid ⊤ I).chart_mem_maximal_atlas x)

theorem times_cont_mdiff_on_chart_symm : TimesContMdiffOn I I n (chart_at H x).symm (chart_at H x).Target :=
  times_cont_mdiff_on_symm_of_mem_maximal_atlas ((timesContDiffGroupoid ⊤ I).chart_mem_maximal_atlas x)

end Atlas

/-! ### The identity is smooth -/


section id

theorem times_cont_mdiff_id : TimesContMdiff I I n (id : M → M) :=
  TimesContMdiff.of_le
    ((times_cont_diff_within_at_local_invariant_prop I I ∞).lift_prop_id
      (times_cont_diff_within_at_local_invariant_prop_id I))
    le_top

theorem smooth_id : Smooth I I (id : M → M) :=
  times_cont_mdiff_id

theorem times_cont_mdiff_on_id : TimesContMdiffOn I I n (id : M → M) s :=
  times_cont_mdiff_id.TimesContMdiffOn

theorem smooth_on_id : SmoothOn I I (id : M → M) s :=
  times_cont_mdiff_on_id

theorem times_cont_mdiff_at_id : TimesContMdiffAt I I n (id : M → M) x :=
  times_cont_mdiff_id.TimesContMdiffAt

theorem smooth_at_id : SmoothAt I I (id : M → M) x :=
  times_cont_mdiff_at_id

theorem times_cont_mdiff_within_at_id : TimesContMdiffWithinAt I I n (id : M → M) s x :=
  times_cont_mdiff_at_id.TimesContMdiffWithinAt

theorem smooth_within_at_id : SmoothWithinAt I I (id : M → M) s x :=
  times_cont_mdiff_within_at_id

end id

/-! ### Constants are smooth -/


section id

variable{c : M'}

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem times_cont_mdiff_const : times_cont_mdiff I I' n (λ x : M, c) :=
begin
  assume [binders (x)],
  refine [expr ⟨continuous_within_at_const, _⟩],
  simp [] [] ["only"] ["[", expr times_cont_diff_within_at_prop, ",", expr («expr ∘ »), "]"] [] [],
  exact [expr times_cont_diff_within_at_const]
end

@[toAdditive]
theorem times_cont_mdiff_one [HasOne M'] : TimesContMdiff I I' n (1 : M → M') :=
  by 
    simp only [Pi.one_def, times_cont_mdiff_const]

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem smooth_const : smooth I I' (λ x : M, c) := times_cont_mdiff_const

@[toAdditive]
theorem smooth_one [HasOne M'] : Smooth I I' (1 : M → M') :=
  by 
    simp only [Pi.one_def, smooth_const]

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem times_cont_mdiff_on_const : times_cont_mdiff_on I I' n (λ x : M, c) s :=
times_cont_mdiff_const.times_cont_mdiff_on

@[toAdditive]
theorem times_cont_mdiff_on_one [HasOne M'] : TimesContMdiffOn I I' n (1 : M → M') s :=
  times_cont_mdiff_one.TimesContMdiffOn

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem smooth_on_const : smooth_on I I' (λ x : M, c) s := times_cont_mdiff_on_const

@[toAdditive]
theorem smooth_on_one [HasOne M'] : SmoothOn I I' (1 : M → M') s :=
  times_cont_mdiff_on_one

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem times_cont_mdiff_at_const : times_cont_mdiff_at I I' n (λ x : M, c) x :=
times_cont_mdiff_const.times_cont_mdiff_at

@[toAdditive]
theorem times_cont_mdiff_at_one [HasOne M'] : TimesContMdiffAt I I' n (1 : M → M') x :=
  times_cont_mdiff_one.TimesContMdiffAt

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem smooth_at_const : smooth_at I I' (λ x : M, c) x := times_cont_mdiff_at_const

@[toAdditive]
theorem smooth_at_one [HasOne M'] : SmoothAt I I' (1 : M → M') x :=
  times_cont_mdiff_at_one

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem times_cont_mdiff_within_at_const : times_cont_mdiff_within_at I I' n (λ x : M, c) s x :=
times_cont_mdiff_at_const.times_cont_mdiff_within_at

@[toAdditive]
theorem times_cont_mdiff_within_at_one [HasOne M'] : TimesContMdiffWithinAt I I' n (1 : M → M') s x :=
  times_cont_mdiff_at_const.TimesContMdiffWithinAt

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem smooth_within_at_const : smooth_within_at I I' (λ x : M, c) s x := times_cont_mdiff_within_at_const

@[toAdditive]
theorem smooth_within_at_one [HasOne M'] : SmoothWithinAt I I' (1 : M → M') s x :=
  times_cont_mdiff_within_at_one

end id

theorem times_cont_mdiff_of_support {f : M → F}
  (hf : ∀ x (_ : x ∈ Closure (support f)), TimesContMdiffAt I 𝓘(𝕜, F) n f x) : TimesContMdiff I 𝓘(𝕜, F) n f :=
  by 
    intro x 
    byCases' hx : x ∈ Closure (support f)
    ·
      exact hf x hx
    ·
      refine' TimesContMdiffAt.congr_of_eventually_eq _ (eventually_eq_zero_nhds.2 hx)
      exact times_cont_mdiff_at_const

/-! ### Equivalence with the basic definition for functions between vector spaces -/


section Module

theorem times_cont_mdiff_within_at_iff_times_cont_diff_within_at {f : E → E'} {s : Set E} {x : E} :
  TimesContMdiffWithinAt 𝓘(𝕜, E) 𝓘(𝕜, E') n f s x ↔ TimesContDiffWithinAt 𝕜 n f s x :=
  by 
    simp' (config := { contextual := Bool.true.0 }) only [TimesContMdiffWithinAt, lift_prop_within_at,
      TimesContDiffWithinAtProp, iff_def] with mfld_simps 
    exact TimesContDiffWithinAt.continuous_within_at

alias times_cont_mdiff_within_at_iff_times_cont_diff_within_at ↔ TimesContMdiffWithinAt.times_cont_diff_within_at
  TimesContDiffWithinAt.times_cont_mdiff_within_at

theorem times_cont_mdiff_at_iff_times_cont_diff_at {f : E → E'} {x : E} :
  TimesContMdiffAt 𝓘(𝕜, E) 𝓘(𝕜, E') n f x ↔ TimesContDiffAt 𝕜 n f x :=
  by 
    rw [←times_cont_mdiff_within_at_univ, times_cont_mdiff_within_at_iff_times_cont_diff_within_at,
      times_cont_diff_within_at_univ]

alias times_cont_mdiff_at_iff_times_cont_diff_at ↔ TimesContMdiffAt.times_cont_diff_at
  TimesContDiffAt.times_cont_mdiff_at

theorem times_cont_mdiff_on_iff_times_cont_diff_on {f : E → E'} {s : Set E} :
  TimesContMdiffOn 𝓘(𝕜, E) 𝓘(𝕜, E') n f s ↔ TimesContDiffOn 𝕜 n f s :=
  forall_congrₓ$
    by 
      simp [times_cont_mdiff_within_at_iff_times_cont_diff_within_at]

alias times_cont_mdiff_on_iff_times_cont_diff_on ↔ TimesContMdiffOn.times_cont_diff_on
  TimesContDiffOn.times_cont_mdiff_on

theorem times_cont_mdiff_iff_times_cont_diff {f : E → E'} : TimesContMdiff 𝓘(𝕜, E) 𝓘(𝕜, E') n f ↔ TimesContDiff 𝕜 n f :=
  by 
    rw [←times_cont_diff_on_univ, ←times_cont_mdiff_on_univ, times_cont_mdiff_on_iff_times_cont_diff_on]

alias times_cont_mdiff_iff_times_cont_diff ↔ TimesContMdiff.times_cont_diff TimesContDiff.times_cont_mdiff

end Module

/-! ### The tangent map of a smooth function is smooth -/


section tangentMap

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If a function is `C^n` with `1 ≤ n` on a domain with unique derivatives, then its bundled
derivative is continuous. In this auxiliary lemma, we prove this fact when the source and target
space are model spaces in models with corners. The general fact is proved in
`times_cont_mdiff_on.continuous_on_tangent_map_within`-/
theorem times_cont_mdiff_on.continuous_on_tangent_map_within_aux
{f : H → H'}
{s : set H}
(hf : times_cont_mdiff_on I I' n f s)
(hn : «expr ≤ »(1, n))
(hs : unique_mdiff_on I s) : continuous_on (tangent_map_within I I' f s) «expr ⁻¹' »(tangent_bundle.proj I H, s) :=
begin
  suffices [ident h] [":", expr continuous_on (λ
    p : «expr × »(H, E), (f p.fst, (fderiv_within 𝕜 (written_in_ext_chart_at I I' p.fst f) «expr ∩ »(«expr ⁻¹' »(I.symm, s), range I) (ext_chart_at I p.fst p.fst) : «expr →L[ ] »(E, 𝕜, E')) p.snd)) «expr ⁻¹' »(prod.fst, s)],
  { have [ident A] [] [":=", expr (tangent_bundle_model_space_homeomorph H I).continuous],
    rw [expr continuous_iff_continuous_on_univ] ["at", ident A],
    have [ident B] [] [":=", expr ((tangent_bundle_model_space_homeomorph H' I').symm.continuous.comp_continuous_on h).comp' A],
    have [] [":", expr «expr = »(«expr ∩ »(univ, «expr ⁻¹' »(«expr⇑ »(tangent_bundle_model_space_homeomorph H I), «expr ⁻¹' »(prod.fst, s))), «expr ⁻¹' »(tangent_bundle.proj I H, s))] [],
    by { ext [] ["⟨", ident x, ",", ident v, "⟩"] [],
      simp [] [] ["only"] [] ["with", ident mfld_simps] [] },
    rw [expr this] ["at", ident B],
    apply [expr B.congr],
    rintros ["⟨", ident x, ",", ident v, "⟩", ident hx],
    dsimp [] ["[", expr tangent_map_within, "]"] [] [],
    ext [] [] [],
    { refl },
    simp [] [] ["only"] [] ["with", ident mfld_simps] [],
    apply [expr congr_fun],
    apply [expr congr_arg],
    rw [expr mdifferentiable_within_at.mfderiv_within (hf.mdifferentiable_on hn x hx)] [],
    refl },
  suffices [ident h] [":", expr continuous_on (λ
    p : «expr × »(H, E), (fderiv_within 𝕜 «expr ∘ »(I', «expr ∘ »(f, I.symm)) «expr ∩ »(«expr ⁻¹' »(I.symm, s), range I) (I p.fst) : «expr →L[ ] »(E, 𝕜, E')) p.snd) «expr ⁻¹' »(prod.fst, s)],
  { dsimp [] ["[", expr written_in_ext_chart_at, ",", expr ext_chart_at, "]"] [] [],
    apply [expr continuous_on.prod (continuous_on.comp hf.continuous_on continuous_fst.continuous_on (subset.refl _))],
    apply [expr h.congr],
    assume [binders (p hp)],
    refl },
  suffices [ident h] [":", expr continuous_on (fderiv_within 𝕜 «expr ∘ »(I', «expr ∘ »(f, I.symm)) «expr ∩ »(«expr ⁻¹' »(I.symm, s), range I)) «expr '' »(I, s)],
  { have [ident C] [] [":=", expr continuous_on.comp h I.continuous_to_fun.continuous_on (subset.refl _)],
    have [ident A] [":", expr continuous (λ
      q : «expr × »(«expr →L[ ] »(E, 𝕜, E'), E), q.1 q.2)] [":=", expr is_bounded_bilinear_map_apply.continuous],
    have [ident B] [":", expr continuous_on (λ
      p : «expr × »(H, E), (fderiv_within 𝕜 «expr ∘ »(I', «expr ∘ »(f, I.symm)) «expr ∩ »(«expr ⁻¹' »(I.symm, s), range I) (I p.1), p.2)) «expr ⁻¹' »(prod.fst, s)] [],
    { apply [expr continuous_on.prod _ continuous_snd.continuous_on],
      refine [expr (continuous_on.comp C continuous_fst.continuous_on _ : _)],
      exact [expr preimage_mono (subset_preimage_image _ _)] },
    exact [expr A.comp_continuous_on B] },
  rw [expr times_cont_mdiff_on_iff] ["at", ident hf],
  let [ident x] [":", expr H] [":=", expr I.symm (0 : E)],
  let [ident y] [":", expr H'] [":=", expr I'.symm (0 : E')],
  have [ident A] [] [":=", expr hf.2 x y],
  simp [] [] ["only"] ["[", expr I.image_eq, ",", expr inter_comm, "]"] ["with", ident mfld_simps] ["at", ident A, "⊢"],
  apply [expr A.continuous_on_fderiv_within _ hn],
  convert [] [expr hs.unique_diff_on_target_inter x] ["using", 1],
  simp [] [] ["only"] ["[", expr inter_comm, "]"] ["with", ident mfld_simps] []
end

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If a function is `C^n` on a domain with unique derivatives, then its bundled derivative is
`C^m` when `m+1 ≤ n`. In this auxiliary lemma, we prove this fact when the source and target space
are model spaces in models with corners. The general fact is proved in
`times_cont_mdiff_on.times_cont_mdiff_on_tangent_map_within` -/
theorem times_cont_mdiff_on.times_cont_mdiff_on_tangent_map_within_aux
{f : H → H'}
{s : set H}
(hf : times_cont_mdiff_on I I' n f s)
(hmn : «expr ≤ »(«expr + »(m, 1), n))
(hs : unique_mdiff_on I s) : times_cont_mdiff_on I.tangent I'.tangent m (tangent_map_within I I' f s) «expr ⁻¹' »(tangent_bundle.proj I H, s) :=
begin
  have [ident m_le_n] [":", expr «expr ≤ »(m, n)] [],
  { apply [expr le_trans _ hmn],
    have [] [":", expr «expr ≤ »(«expr + »(m, 0), «expr + »(m, 1))] [":=", expr add_le_add_left (zero_le _) _],
    simpa [] [] ["only"] ["[", expr add_zero, "]"] [] ["using", expr this] },
  have [ident one_le_n] [":", expr «expr ≤ »(1, n)] [],
  { apply [expr le_trans _ hmn],
    change [expr «expr ≤ »(«expr + »(0, 1), «expr + »(m, 1))] [] [],
    exact [expr add_le_add_right (zero_le _) _] },
  have [ident U'] [":", expr unique_diff_on 𝕜 «expr ∩ »(range I, «expr ⁻¹' »(I.symm, s))] [],
  { assume [binders (y hy)],
    simpa [] [] ["only"] ["[", expr unique_mdiff_on, ",", expr unique_mdiff_within_at, ",", expr hy.1, ",", expr inter_comm, "]"] ["with", ident mfld_simps] ["using", expr hs (I.symm y) hy.2] },
  have [ident U] [":", expr unique_diff_on 𝕜 (set.prod «expr ∩ »(range I, «expr ⁻¹' »(I.symm, s)) (univ : set E))] [":=", expr U'.prod unique_diff_on_univ],
  rw [expr times_cont_mdiff_on_iff] [],
  refine [expr ⟨hf.continuous_on_tangent_map_within_aux one_le_n hs, λ p q, _⟩],
  have [ident A] [":", expr «expr = »(«expr ∩ »((range I).prod univ, «expr ⁻¹' »(«expr ∘ »((equiv.sigma_equiv_prod H E).symm, λ
       p : «expr × »(E, E), (I.symm p.fst, p.snd)), «expr ⁻¹' »(tangent_bundle.proj I H, s))), set.prod «expr ∩ »(range I, «expr ⁻¹' »(I.symm, s)) univ)] [],
  by { ext [] ["⟨", ident x, ",", ident v, "⟩"] [],
    simp [] [] ["only"] [] ["with", ident mfld_simps] [] },
  suffices [ident h] [":", expr times_cont_diff_on 𝕜 m «expr ∘ »(«expr ∘ »(λ
     p : «expr × »(H', E'), (I' p.fst, p.snd), equiv.sigma_equiv_prod H' E'), «expr ∘ »(tangent_map_within I I' f s, «expr ∘ »((equiv.sigma_equiv_prod H E).symm, λ
      p : «expr × »(E, E), (I.symm p.fst, p.snd)))) («expr ∩ »(range «expr⇑ »(I), «expr ⁻¹' »(«expr⇑ »(I.symm), s)).prod univ)],
  by simpa [] [] [] ["[", expr A, "]"] [] ["using", expr h],
  change [expr times_cont_diff_on 𝕜 m (λ
    p : «expr × »(E, E), ((I' (f (I.symm p.fst)), (mfderiv_within I I' f s (I.symm p.fst) : E → E') p.snd) : «expr × »(E', E'))) (set.prod «expr ∩ »(range I, «expr ⁻¹' »(I.symm, s)) univ)] [] [],
  have [ident hf'] [] [":=", expr times_cont_mdiff_on_iff.1 hf],
  have [ident A] [":", expr times_cont_diff_on 𝕜 m «expr ∘ »(I', «expr ∘ »(f, I.symm)) «expr ∩ »(range I, «expr ⁻¹' »(I.symm, s))] [":=", expr by simpa [] [] ["only"] [] ["with", ident mfld_simps] ["using", expr (hf'.2 (I.symm 0) (I'.symm 0)).of_le m_le_n]],
  have [ident B] [":", expr times_cont_diff_on 𝕜 m «expr ∘ »(«expr ∘ »(I', «expr ∘ »(f, I.symm)), prod.fst) (set.prod «expr ∩ »(range I, «expr ⁻¹' »(I.symm, s)) (univ : set E))] [":=", expr A.comp times_cont_diff_fst.times_cont_diff_on (prod_subset_preimage_fst _ _)],
  suffices [ident C] [":", expr times_cont_diff_on 𝕜 m (λ
    p : «expr × »(E, E), (fderiv_within 𝕜 «expr ∘ »(I', «expr ∘ »(f, I.symm)) «expr ∩ »(«expr ⁻¹' »(I.symm, s), range I) p.1 : _) p.2) (set.prod «expr ∩ »(range I, «expr ⁻¹' »(I.symm, s)) univ)],
  { apply [expr times_cont_diff_on.prod B _],
    apply [expr C.congr (λ p hp, _)],
    simp [] [] ["only"] [] ["with", ident mfld_simps] ["at", ident hp],
    simp [] [] ["only"] ["[", expr mfderiv_within, ",", expr hf.mdifferentiable_on one_le_n _ hp.2, ",", expr hp.1, ",", expr dif_pos, "]"] ["with", ident mfld_simps] [] },
  have [ident D] [":", expr times_cont_diff_on 𝕜 m (λ
    x, fderiv_within 𝕜 «expr ∘ »(I', «expr ∘ »(f, I.symm)) «expr ∩ »(«expr ⁻¹' »(I.symm, s), range I) x) «expr ∩ »(range I, «expr ⁻¹' »(I.symm, s))] [],
  { have [] [":", expr times_cont_diff_on 𝕜 n «expr ∘ »(I', «expr ∘ »(f, I.symm)) «expr ∩ »(range I, «expr ⁻¹' »(I.symm, s))] [":=", expr by simpa [] [] ["only"] [] ["with", ident mfld_simps] ["using", expr hf'.2 (I.symm 0) (I'.symm 0)]],
    simpa [] [] ["only"] ["[", expr inter_comm, "]"] [] ["using", expr this.fderiv_within U' hmn] },
  have [] [] [":=", expr D.comp times_cont_diff_fst.times_cont_diff_on (prod_subset_preimage_fst _ _)],
  have [] [] [":=", expr times_cont_diff_on.prod this times_cont_diff_snd.times_cont_diff_on],
  exact [expr is_bounded_bilinear_map_apply.times_cont_diff.comp_times_cont_diff_on this]
end

include Is I's

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If a function is `C^n` on a domain with unique derivatives, then its bundled derivative
is `C^m` when `m+1 ≤ n`. -/
theorem times_cont_mdiff_on.times_cont_mdiff_on_tangent_map_within
(hf : times_cont_mdiff_on I I' n f s)
(hmn : «expr ≤ »(«expr + »(m, 1), n))
(hs : unique_mdiff_on I s) : times_cont_mdiff_on I.tangent I'.tangent m (tangent_map_within I I' f s) «expr ⁻¹' »(tangent_bundle.proj I M, s) :=
begin
  have [ident m_le_n] [":", expr «expr ≤ »(m, n)] [],
  { apply [expr le_trans _ hmn],
    have [] [":", expr «expr ≤ »(«expr + »(m, 0), «expr + »(m, 1))] [":=", expr add_le_add_left (zero_le _) _],
    simpa [] [] ["only"] ["[", expr add_zero, "]"] [] [] },
  have [ident one_le_n] [":", expr «expr ≤ »(1, n)] [],
  { apply [expr le_trans _ hmn],
    change [expr «expr ≤ »(«expr + »(0, 1), «expr + »(m, 1))] [] [],
    exact [expr add_le_add_right (zero_le _) _] },
  refine [expr times_cont_mdiff_on_of_locally_times_cont_mdiff_on (λ p hp, _)],
  have [ident hf'] [] [":=", expr times_cont_mdiff_on_iff.1 hf],
  simp [] [] [] ["[", expr tangent_bundle.proj, "]"] [] ["at", ident hp],
  let [ident l] [] [":=", expr chart_at H p.1],
  set [] [ident Dl] [] [":="] [expr chart_at (model_prod H E) p] ["with", ident hDl],
  let [ident r] [] [":=", expr chart_at H' (f p.1)],
  let [ident Dr] [] [":=", expr chart_at (model_prod H' E') (tangent_map_within I I' f s p)],
  let [ident il] [] [":=", expr chart_at (model_prod H E) (tangent_map I I l p)],
  let [ident ir] [] [":=", expr chart_at (model_prod H' E') (tangent_map I I' «expr ∘ »(r, f) p)],
  let [ident s'] [] [":=", expr «expr ∩ »(«expr ∩ »(«expr ⁻¹' »(f, r.source), s), l.source)],
  let [ident s'_lift] [] [":=", expr «expr ⁻¹' »(tangent_bundle.proj I M, s')],
  let [ident s'l] [] [":=", expr «expr ∩ »(l.target, «expr ⁻¹' »(l.symm, s'))],
  let [ident s'l_lift] [] [":=", expr «expr ⁻¹' »(tangent_bundle.proj I H, s'l)],
  rcases [expr continuous_on_iff'.1 hf'.1 r.source r.open_source, "with", "⟨", ident o, ",", ident o_open, ",", ident ho, "⟩"],
  suffices [ident h] [":", expr times_cont_mdiff_on I.tangent I'.tangent m (tangent_map_within I I' f s) s'_lift],
  { refine [expr ⟨«expr ⁻¹' »(tangent_bundle.proj I M, «expr ∩ »(o, l.source)), _, _, _⟩],
    show [expr is_open «expr ⁻¹' »(tangent_bundle.proj I M, «expr ∩ »(o, l.source))],
    from [expr (is_open.inter o_open l.open_source).preimage (tangent_bundle_proj_continuous _ _)],
    show [expr «expr ∈ »(p, «expr ⁻¹' »(tangent_bundle.proj I M, «expr ∩ »(o, l.source)))],
    { simp [] [] [] ["[", expr tangent_bundle.proj, "]"] [] ["at", "⊢"],
      have [] [":", expr «expr ∈ »(p.1, «expr ∩ »(«expr ⁻¹' »(f, r.source), s))] [],
      by simp [] [] [] ["[", expr hp, "]"] [] [],
      rw [expr ho] ["at", ident this],
      exact [expr this.1] },
    { have [] [":", expr «expr = »(«expr ∩ »(«expr ⁻¹' »(tangent_bundle.proj I M, s), «expr ⁻¹' »(tangent_bundle.proj I M, «expr ∩ »(o, l.source))), s'_lift)] [],
      { dsimp ["only"] ["[", expr s'_lift, ",", expr s', "]"] [] [],
        rw ["[", expr ho, "]"] [],
        mfld_set_tac },
      rw [expr this] [],
      exact [expr h] } },
  have [ident U'] [":", expr unique_mdiff_on I s'] [],
  { apply [expr unique_mdiff_on.inter _ l.open_source],
    rw ["[", expr ho, ",", expr inter_comm, "]"] [],
    exact [expr hs.inter o_open] },
  have [ident U'l] [":", expr unique_mdiff_on I s'l] [":=", expr U'.unique_mdiff_on_preimage (mdifferentiable_chart _ _)],
  have [ident diff_f] [":", expr times_cont_mdiff_on I I' n f s'] [":=", expr hf.mono (by mfld_set_tac)],
  have [ident diff_r] [":", expr times_cont_mdiff_on I' I' n r r.source] [":=", expr times_cont_mdiff_on_chart],
  have [ident diff_rf] [":", expr times_cont_mdiff_on I I' n «expr ∘ »(r, f) s'] [],
  { apply [expr times_cont_mdiff_on.comp diff_r diff_f (λ x hx, _)],
    simp [] [] ["only"] ["[", expr s', "]"] ["with", ident mfld_simps] ["at", ident hx],
    simp [] [] ["only"] ["[", expr hx, "]"] ["with", ident mfld_simps] [] },
  have [ident diff_l] [":", expr times_cont_mdiff_on I I n l.symm s'l] [],
  { have [ident A] [":", expr times_cont_mdiff_on I I n l.symm l.target] [":=", expr times_cont_mdiff_on_chart_symm],
    exact [expr A.mono (by mfld_set_tac)] },
  have [ident diff_rfl] [":", expr times_cont_mdiff_on I I' n «expr ∘ »(r, «expr ∘ »(f, l.symm)) s'l] [],
  { apply [expr times_cont_mdiff_on.comp diff_rf diff_l],
    mfld_set_tac },
  have [ident diff_rfl_lift] [":", expr times_cont_mdiff_on I.tangent I'.tangent m (tangent_map_within I I' «expr ∘ »(r, «expr ∘ »(f, l.symm)) s'l) s'l_lift] [":=", expr diff_rfl.times_cont_mdiff_on_tangent_map_within_aux hmn U'l],
  have [ident diff_irrfl_lift] [":", expr times_cont_mdiff_on I.tangent I'.tangent m «expr ∘ »(ir, tangent_map_within I I' «expr ∘ »(r, «expr ∘ »(f, l.symm)) s'l) s'l_lift] [],
  { have [ident A] [":", expr times_cont_mdiff_on I'.tangent I'.tangent m ir ir.source] [":=", expr times_cont_mdiff_on_chart],
    exact [expr times_cont_mdiff_on.comp A diff_rfl_lift (λ
      p hp, by simp [] [] ["only"] ["[", expr ir, "]"] ["with", ident mfld_simps] [])] },
  have [ident diff_Drirrfl_lift] [":", expr times_cont_mdiff_on I.tangent I'.tangent m «expr ∘ »(Dr.symm, «expr ∘ »(ir, tangent_map_within I I' «expr ∘ »(r, «expr ∘ »(f, l.symm)) s'l)) s'l_lift] [],
  { have [ident A] [":", expr times_cont_mdiff_on I'.tangent I'.tangent m Dr.symm Dr.target] [":=", expr times_cont_mdiff_on_chart_symm],
    apply [expr times_cont_mdiff_on.comp A diff_irrfl_lift (λ p hp, _)],
    simp [] [] ["only"] ["[", expr s'l_lift, ",", expr tangent_bundle.proj, "]"] ["with", ident mfld_simps] ["at", ident hp],
    simp [] [] ["only"] ["[", expr ir, ",", expr @local_equiv.refl_coe (model_prod H' E'), ",", expr hp, "]"] ["with", ident mfld_simps] [] },
  have [ident diff_DrirrflilDl] [":", expr times_cont_mdiff_on I.tangent I'.tangent m «expr ∘ »(Dr.symm, «expr ∘ »(«expr ∘ »(ir, tangent_map_within I I' «expr ∘ »(r, «expr ∘ »(f, l.symm)) s'l), «expr ∘ »(il.symm, Dl))) s'_lift] [],
  { have [ident A] [":", expr times_cont_mdiff_on I.tangent I.tangent m Dl Dl.source] [":=", expr times_cont_mdiff_on_chart],
    have [ident A'] [":", expr times_cont_mdiff_on I.tangent I.tangent m Dl s'_lift] [],
    { apply [expr A.mono (λ p hp, _)],
      simp [] [] ["only"] ["[", expr s'_lift, ",", expr tangent_bundle.proj, "]"] ["with", ident mfld_simps] ["at", ident hp],
      simp [] [] ["only"] ["[", expr Dl, ",", expr hp, "]"] ["with", ident mfld_simps] [] },
    have [ident B] [":", expr times_cont_mdiff_on I.tangent I.tangent m il.symm il.target] [":=", expr times_cont_mdiff_on_chart_symm],
    have [ident C] [":", expr times_cont_mdiff_on I.tangent I.tangent m «expr ∘ »(il.symm, Dl) s'_lift] [":=", expr times_cont_mdiff_on.comp B A' (λ
      p hp, by simp [] [] ["only"] ["[", expr il, "]"] ["with", ident mfld_simps] [])],
    apply [expr times_cont_mdiff_on.comp diff_Drirrfl_lift C (λ p hp, _)],
    simp [] [] ["only"] ["[", expr s'_lift, ",", expr tangent_bundle.proj, "]"] ["with", ident mfld_simps] ["at", ident hp],
    simp [] [] ["only"] ["[", expr il, ",", expr s'l_lift, ",", expr hp, ",", expr tangent_bundle.proj, "]"] ["with", ident mfld_simps] [] },
  have [ident eq_comp] [":", expr ∀
   q «expr ∈ » s'_lift, «expr = »(tangent_map_within I I' f s q, «expr ∘ »(Dr.symm, «expr ∘ »(ir, «expr ∘ »(tangent_map_within I I' «expr ∘ »(r, «expr ∘ »(f, l.symm)) s'l, «expr ∘ »(il.symm, Dl)))) q)] [],
  { assume [binders (q hq)],
    simp [] [] ["only"] ["[", expr s'_lift, ",", expr tangent_bundle.proj, "]"] ["with", ident mfld_simps] ["at", ident hq],
    have [ident U'q] [":", expr unique_mdiff_within_at I s' q.1] [],
    by { apply [expr U'],
      simp [] [] ["only"] ["[", expr hq, ",", expr s', "]"] ["with", ident mfld_simps] [] },
    have [ident U'lq] [":", expr unique_mdiff_within_at I s'l (Dl q).1] [],
    by { apply [expr U'l],
      simp [] [] ["only"] ["[", expr hq, ",", expr s'l, "]"] ["with", ident mfld_simps] [] },
    have [ident A] [":", expr «expr = »(tangent_map_within I I' «expr ∘ »(«expr ∘ »(r, f), l.symm) s'l (il.symm (Dl q)), tangent_map_within I I' «expr ∘ »(r, f) s' (tangent_map_within I I l.symm s'l (il.symm (Dl q))))] [],
    { refine [expr tangent_map_within_comp_at (il.symm (Dl q)) _ _ (λ p hp, _) U'lq],
      { apply [expr diff_rf.mdifferentiable_on one_le_n],
        simp [] [] ["only"] ["[", expr hq, "]"] ["with", ident mfld_simps] [] },
      { apply [expr diff_l.mdifferentiable_on one_le_n],
        simp [] [] ["only"] ["[", expr s'l, ",", expr hq, "]"] ["with", ident mfld_simps] [] },
      { simp [] [] ["only"] [] ["with", ident mfld_simps] ["at", ident hp],
        simp [] [] ["only"] ["[", expr hp, "]"] ["with", ident mfld_simps] [] } },
    have [ident B] [":", expr «expr = »(tangent_map_within I I l.symm s'l (il.symm (Dl q)), q)] [],
    { have [] [":", expr «expr = »(tangent_map_within I I l.symm s'l (il.symm (Dl q)), tangent_map I I l.symm (il.symm (Dl q)))] [],
      { refine [expr tangent_map_within_eq_tangent_map U'lq _],
        refine [expr mdifferentiable_at_atlas_symm _ (chart_mem_atlas _ _) _],
        simp [] [] ["only"] ["[", expr hq, "]"] ["with", ident mfld_simps] [] },
      rw ["[", expr this, ",", expr tangent_map_chart_symm, ",", expr hDl, "]"] [],
      { simp [] [] ["only"] ["[", expr hq, "]"] ["with", ident mfld_simps] [],
        have [] [":", expr «expr ∈ »(q, (chart_at (model_prod H E) p).source)] [],
        by simp [] [] ["only"] ["[", expr hq, "]"] ["with", ident mfld_simps] [],
        exact [expr (chart_at (model_prod H E) p).left_inv this] },
      { simp [] [] ["only"] ["[", expr hq, "]"] ["with", ident mfld_simps] [] } },
    have [ident C] [":", expr «expr = »(tangent_map_within I I' «expr ∘ »(r, f) s' q, tangent_map_within I' I' r r.source (tangent_map_within I I' f s' q))] [],
    { refine [expr tangent_map_within_comp_at q _ _ (λ r hr, _) U'q],
      { apply [expr diff_r.mdifferentiable_on one_le_n],
        simp [] [] ["only"] ["[", expr hq, "]"] ["with", ident mfld_simps] [] },
      { apply [expr diff_f.mdifferentiable_on one_le_n],
        simp [] [] ["only"] ["[", expr hq, "]"] ["with", ident mfld_simps] [] },
      { simp [] [] ["only"] ["[", expr s', "]"] ["with", ident mfld_simps] ["at", ident hr],
        simp [] [] ["only"] ["[", expr hr, "]"] ["with", ident mfld_simps] [] } },
    have [ident D] [":", expr «expr = »(Dr.symm (ir (tangent_map_within I' I' r r.source (tangent_map_within I I' f s' q))), tangent_map_within I I' f s' q)] [],
    { have [ident A] [":", expr «expr = »(tangent_map_within I' I' r r.source (tangent_map_within I I' f s' q), tangent_map I' I' r (tangent_map_within I I' f s' q))] [],
      { apply [expr tangent_map_within_eq_tangent_map],
        { apply [expr is_open.unique_mdiff_within_at _ r.open_source],
          simp [] [] [] ["[", expr hq, "]"] [] [] },
        { refine [expr mdifferentiable_at_atlas _ (chart_mem_atlas _ _) _],
          simp [] [] ["only"] ["[", expr hq, "]"] ["with", ident mfld_simps] [] } },
      have [] [":", expr «expr = »(f p.1, (tangent_map_within I I' f s p).1)] [":=", expr rfl],
      rw ["[", expr A, "]"] [],
      dsimp [] ["[", expr r, ",", expr Dr, "]"] [] [],
      rw ["[", expr this, ",", expr tangent_map_chart, "]"] [],
      { simp [] [] ["only"] ["[", expr hq, "]"] ["with", ident mfld_simps] [],
        have [] [":", expr «expr ∈ »(tangent_map_within I I' f s' q, (chart_at (model_prod H' E') (tangent_map_within I I' f s p)).source)] [],
        by simp [] [] ["only"] ["[", expr hq, "]"] ["with", ident mfld_simps] [],
        exact [expr (chart_at (model_prod H' E') (tangent_map_within I I' f s p)).left_inv this] },
      { simp [] [] ["only"] ["[", expr hq, "]"] ["with", ident mfld_simps] [] } },
    have [ident E] [":", expr «expr = »(tangent_map_within I I' f s' q, tangent_map_within I I' f s q)] [],
    { refine [expr tangent_map_within_subset (by mfld_set_tac) U'q _],
      apply [expr hf.mdifferentiable_on one_le_n],
      simp [] [] ["only"] ["[", expr hq, "]"] ["with", ident mfld_simps] [] },
    simp [] [] ["only"] ["[", expr («expr ∘ »), ",", expr A, ",", expr B, ",", expr C, ",", expr D, ",", expr E.symm, "]"] [] [] },
  exact [expr diff_DrirrflilDl.congr eq_comp]
end

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If a function is `C^n` on a domain with unique derivatives, with `1 ≤ n`, then its bundled
derivative is continuous there. -/
theorem times_cont_mdiff_on.continuous_on_tangent_map_within
(hf : times_cont_mdiff_on I I' n f s)
(hmn : «expr ≤ »(1, n))
(hs : unique_mdiff_on I s) : continuous_on (tangent_map_within I I' f s) «expr ⁻¹' »(tangent_bundle.proj I M, s) :=
begin
  have [] [":", expr times_cont_mdiff_on I.tangent I'.tangent 0 (tangent_map_within I I' f s) «expr ⁻¹' »(tangent_bundle.proj I M, s)] [":=", expr hf.times_cont_mdiff_on_tangent_map_within hmn hs],
  exact [expr this.continuous_on]
end

/-- If a function is `C^n`, then its bundled derivative is `C^m` when `m+1 ≤ n`. -/
theorem TimesContMdiff.times_cont_mdiff_tangent_map (hf : TimesContMdiff I I' n f) (hmn : (m+1) ≤ n) :
  TimesContMdiff I.tangent I'.tangent m (tangentMap I I' f) :=
  by 
    rw [←times_cont_mdiff_on_univ] at hf⊢
    convert hf.times_cont_mdiff_on_tangent_map_within hmn unique_mdiff_on_univ 
    rw [tangent_map_within_univ]

/-- If a function is `C^n`, with `1 ≤ n`, then its bundled derivative is continuous. -/
theorem TimesContMdiff.continuous_tangent_map (hf : TimesContMdiff I I' n f) (hmn : 1 ≤ n) :
  Continuous (tangentMap I I' f) :=
  by 
    rw [←times_cont_mdiff_on_univ] at hf 
    rw [continuous_iff_continuous_on_univ]
    convert hf.continuous_on_tangent_map_within hmn unique_mdiff_on_univ 
    rw [tangent_map_within_univ]

end tangentMap

/-! ### Smoothness of the projection in a basic smooth bundle -/


namespace BasicSmoothBundleCore

variable(Z : BasicSmoothBundleCore I M E')

theorem times_cont_mdiff_proj : TimesContMdiff (I.prod 𝓘(𝕜, E')) I n Z.to_topological_fiber_bundle_core.proj :=
  by 
    intro x 
    rw [TimesContMdiffAt, times_cont_mdiff_within_at_iff]
    refine' ⟨Z.to_topological_fiber_bundle_core.continuous_proj.continuous_at.continuous_within_at, _⟩
    simp' only [· ∘ ·, chart_at, chart] with mfld_simps 
    apply times_cont_diff_within_at_fst.congr
    ·
      rintro ⟨a, b⟩ hab 
      simp' only with mfld_simps  at hab 
      simp' only [hab] with mfld_simps
    ·
      simp' only with mfld_simps

theorem smooth_proj : Smooth (I.prod 𝓘(𝕜, E')) I Z.to_topological_fiber_bundle_core.proj :=
  times_cont_mdiff_proj Z

theorem times_cont_mdiff_on_proj {s : Set Z.to_topological_fiber_bundle_core.total_space} :
  TimesContMdiffOn (I.prod 𝓘(𝕜, E')) I n Z.to_topological_fiber_bundle_core.proj s :=
  Z.times_cont_mdiff_proj.times_cont_mdiff_on

theorem smooth_on_proj {s : Set Z.to_topological_fiber_bundle_core.total_space} :
  SmoothOn (I.prod 𝓘(𝕜, E')) I Z.to_topological_fiber_bundle_core.proj s :=
  times_cont_mdiff_on_proj Z

theorem times_cont_mdiff_at_proj {p : Z.to_topological_fiber_bundle_core.total_space} :
  TimesContMdiffAt (I.prod 𝓘(𝕜, E')) I n Z.to_topological_fiber_bundle_core.proj p :=
  Z.times_cont_mdiff_proj.times_cont_mdiff_at

theorem smooth_at_proj {p : Z.to_topological_fiber_bundle_core.total_space} :
  SmoothAt (I.prod 𝓘(𝕜, E')) I Z.to_topological_fiber_bundle_core.proj p :=
  Z.times_cont_mdiff_at_proj

theorem times_cont_mdiff_within_at_proj {s : Set Z.to_topological_fiber_bundle_core.total_space}
  {p : Z.to_topological_fiber_bundle_core.total_space} :
  TimesContMdiffWithinAt (I.prod 𝓘(𝕜, E')) I n Z.to_topological_fiber_bundle_core.proj s p :=
  Z.times_cont_mdiff_at_proj.times_cont_mdiff_within_at

theorem smooth_within_at_proj {s : Set Z.to_topological_fiber_bundle_core.total_space}
  {p : Z.to_topological_fiber_bundle_core.total_space} :
  SmoothWithinAt (I.prod 𝓘(𝕜, E')) I Z.to_topological_fiber_bundle_core.proj s p :=
  Z.times_cont_mdiff_within_at_proj

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If an element of `E'` is invariant under all coordinate changes, then one can define a
corresponding section of the fiber bundle, which is smooth. This applies in particular to the
zero section of a vector bundle. Another example (not yet defined) would be the identity
section of the endomorphism bundle of a vector bundle. -/
theorem smooth_const_section
(v : E')
(h : ∀
 i
 j : atlas H M, ∀
 x «expr ∈ » «expr ∩ »(i.1.source, j.1.source), «expr = »(Z.coord_change i j (i.1 x) v, v)) : smooth I (I.prod «expr𝓘( , )»(𝕜, E')) (show M → Z.to_topological_fiber_bundle_core.total_space, from λ
 x, ⟨x, v⟩) :=
begin
  assume [binders (x)],
  rw ["[", expr times_cont_mdiff_at, ",", expr times_cont_mdiff_within_at_iff, "]"] [],
  split,
  { apply [expr continuous.continuous_within_at],
    apply [expr topological_fiber_bundle_core.continuous_const_section],
    assume [binders (i j y hy)],
    exact [expr h _ _ _ hy] },
  { have [] [":", expr times_cont_diff 𝕜 «expr⊤»() (λ
      y : E, (y, v))] [":=", expr times_cont_diff_id.prod times_cont_diff_const],
    apply [expr this.times_cont_diff_within_at.congr],
    { assume [binders (y hy)],
      simp [] [] ["only"] [] ["with", ident mfld_simps] ["at", ident hy],
      simp [] [] ["only"] ["[", expr chart, ",", expr hy, ",", expr chart_at, ",", expr prod.mk.inj_iff, ",", expr to_topological_fiber_bundle_core, "]"] ["with", ident mfld_simps] [],
      apply [expr h],
      simp [] [] ["only"] ["[", expr hy, "]"] ["with", ident mfld_simps] [] },
    { simp [] [] ["only"] ["[", expr chart, ",", expr chart_at, ",", expr prod.mk.inj_iff, ",", expr to_topological_fiber_bundle_core, "]"] ["with", ident mfld_simps] [],
      apply [expr h],
      simp [] [] ["only"] [] ["with", ident mfld_simps] [] } }
end

end BasicSmoothBundleCore

/-! ### Smoothness of the tangent bundle projection -/


namespace TangentBundle

include Is

theorem times_cont_mdiff_proj : TimesContMdiff I.tangent I n (proj I M) :=
  BasicSmoothBundleCore.times_cont_mdiff_proj _

theorem smooth_proj : Smooth I.tangent I (proj I M) :=
  BasicSmoothBundleCore.smooth_proj _

theorem times_cont_mdiff_on_proj {s : Set (TangentBundle I M)} : TimesContMdiffOn I.tangent I n (proj I M) s :=
  BasicSmoothBundleCore.times_cont_mdiff_on_proj _

theorem smooth_on_proj {s : Set (TangentBundle I M)} : SmoothOn I.tangent I (proj I M) s :=
  BasicSmoothBundleCore.smooth_on_proj _

theorem times_cont_mdiff_at_proj {p : TangentBundle I M} : TimesContMdiffAt I.tangent I n (proj I M) p :=
  BasicSmoothBundleCore.times_cont_mdiff_at_proj _

theorem smooth_at_proj {p : TangentBundle I M} : SmoothAt I.tangent I (proj I M) p :=
  BasicSmoothBundleCore.smooth_at_proj _

theorem times_cont_mdiff_within_at_proj {s : Set (TangentBundle I M)} {p : TangentBundle I M} :
  TimesContMdiffWithinAt I.tangent I n (proj I M) s p :=
  BasicSmoothBundleCore.times_cont_mdiff_within_at_proj _

theorem smooth_within_at_proj {s : Set (TangentBundle I M)} {p : TangentBundle I M} :
  SmoothWithinAt I.tangent I (proj I M) s p :=
  BasicSmoothBundleCore.smooth_within_at_proj _

variable(I M)

/-- The zero section of the tangent bundle -/
def zero_section : M → TangentBundle I M :=
  fun x => ⟨x, 0⟩

variable{I M}

theorem smooth_zero_section : Smooth I I.tangent (zero_section I M) :=
  by 
    apply BasicSmoothBundleCore.smooth_const_section (tangentBundleCore I M) 0
    intro i j x hx 
    simp' only [tangentBundleCore, ContinuousLinearMap.map_zero] with mfld_simps

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The derivative of the zero section of the tangent bundle maps `⟨x, v⟩` to `⟨⟨x, 0⟩, ⟨v, 0⟩⟩`.

Note that, as currently framed, this is a statement in coordinates, thus reliant on the choice
of the coordinate system we use on the tangent bundle.

However, the result itself is coordinate-dependent only to the extent that the coordinates
determine a splitting of the tangent bundle.  Moreover, there is a canonical splitting at each
point of the zero section (since there is a canonical horizontal space there, the tangent space
to the zero section, in addition to the canonical vertical space which is the kernel of the
derivative of the projection), and this canonical splitting is also the one that comes from the
coordinates on the tangent bundle in our definitions. So this statement is not as crazy as it
may seem.

TODO define splittings of vector bundles; state this result invariantly. -/
theorem tangent_map_tangent_bundle_pure
(p : tangent_bundle I M) : «expr = »(tangent_map I I.tangent (tangent_bundle.zero_section I M) p, ⟨⟨p.1, 0⟩, ⟨p.2, 0⟩⟩) :=
begin
  rcases [expr p, "with", "⟨", ident x, ",", ident v, "⟩"],
  have [ident N] [":", expr «expr ∈ »(«expr ⁻¹' »(I.symm, (chart_at H x).target), expr𝓝() (I (chart_at H x x)))] [],
  { apply [expr is_open.mem_nhds],
    apply [expr (local_homeomorph.open_target _).preimage I.continuous_inv_fun],
    simp [] [] ["only"] [] ["with", ident mfld_simps] [] },
  have [ident A] [":", expr mdifferentiable_at I I.tangent (λ
    x : M, (⟨x, 0⟩ : tangent_bundle I M)) x] [":=", expr tangent_bundle.smooth_zero_section.mdifferentiable_at],
  have [ident B] [":", expr «expr = »(fderiv_within 𝕜 (λ
     x_1 : E, (x_1, (0 : E))) (set.range «expr⇑ »(I)) (I (chart_at H x x)) v, (v, 0))] [],
  { rw ["[", expr fderiv_within_eq_fderiv, ",", expr differentiable_at.fderiv_prod, "]"] [],
    { simp [] [] [] [] [] [] },
    { exact [expr differentiable_at_id'] },
    { exact [expr differentiable_at_const _] },
    { exact [expr model_with_corners.unique_diff_at_image I] },
    { exact [expr differentiable_at_id'.prod (differentiable_at_const _)] } },
  simp [] [] ["only"] ["[", expr tangent_bundle.zero_section, ",", expr tangent_map, ",", expr mfderiv, ",", expr A, ",", expr dif_pos, ",", expr chart_at, ",", expr basic_smooth_bundle_core.chart, ",", expr basic_smooth_bundle_core.to_topological_fiber_bundle_core, ",", expr tangent_bundle_core, ",", expr function.comp, ",", expr continuous_linear_map.map_zero, "]"] ["with", ident mfld_simps] [],
  rw ["<-", expr fderiv_within_inter N (I.unique_diff (I (chart_at H x x)) (set.mem_range_self _))] ["at", ident B],
  rw ["[", "<-", expr fderiv_within_inter N (I.unique_diff (I (chart_at H x x)) (set.mem_range_self _)), ",", "<-", expr B, "]"] [],
  congr' [1] [],
  apply [expr fderiv_within_congr _ (λ y hy, _)],
  { simp [] [] ["only"] [] ["with", ident mfld_simps] [] },
  { apply [expr unique_diff_within_at.inter (I.unique_diff _ _) N],
    simp [] [] ["only"] [] ["with", ident mfld_simps] [] },
  { simp [] [] ["only"] [] ["with", ident mfld_simps] ["at", ident hy],
    simp [] [] ["only"] ["[", expr hy, "]"] ["with", ident mfld_simps] [] }
end

end TangentBundle

/-! ### Smoothness of standard maps associated to the product of manifolds -/


section ProdMk

theorem TimesContMdiffWithinAt.prod_mk {f : M → M'} {g : M → N'} (hf : TimesContMdiffWithinAt I I' n f s x)
  (hg : TimesContMdiffWithinAt I J' n g s x) : TimesContMdiffWithinAt I (I'.prod J') n (fun x => (f x, g x)) s x :=
  by 
    rw [times_cont_mdiff_within_at_iff''] at *
    exact ⟨hf.1.Prod hg.1, hf.2.Prod hg.2⟩

theorem TimesContMdiffWithinAt.prod_mk_space {f : M → E'} {g : M → F'} (hf : TimesContMdiffWithinAt I 𝓘(𝕜, E') n f s x)
  (hg : TimesContMdiffWithinAt I 𝓘(𝕜, F') n g s x) :
  TimesContMdiffWithinAt I 𝓘(𝕜, E' × F') n (fun x => (f x, g x)) s x :=
  by 
    rw [times_cont_mdiff_within_at_iff''] at *
    exact ⟨hf.1.Prod hg.1, hf.2.Prod hg.2⟩

theorem TimesContMdiffAt.prod_mk {f : M → M'} {g : M → N'} (hf : TimesContMdiffAt I I' n f x)
  (hg : TimesContMdiffAt I J' n g x) : TimesContMdiffAt I (I'.prod J') n (fun x => (f x, g x)) x :=
  hf.prod_mk hg

theorem TimesContMdiffAt.prod_mk_space {f : M → E'} {g : M → F'} (hf : TimesContMdiffAt I 𝓘(𝕜, E') n f x)
  (hg : TimesContMdiffAt I 𝓘(𝕜, F') n g x) : TimesContMdiffAt I 𝓘(𝕜, E' × F') n (fun x => (f x, g x)) x :=
  hf.prod_mk_space hg

theorem TimesContMdiffOn.prod_mk {f : M → M'} {g : M → N'} (hf : TimesContMdiffOn I I' n f s)
  (hg : TimesContMdiffOn I J' n g s) : TimesContMdiffOn I (I'.prod J') n (fun x => (f x, g x)) s :=
  fun x hx => (hf x hx).prod_mk (hg x hx)

theorem TimesContMdiffOn.prod_mk_space {f : M → E'} {g : M → F'} (hf : TimesContMdiffOn I 𝓘(𝕜, E') n f s)
  (hg : TimesContMdiffOn I 𝓘(𝕜, F') n g s) : TimesContMdiffOn I 𝓘(𝕜, E' × F') n (fun x => (f x, g x)) s :=
  fun x hx => (hf x hx).prod_mk_space (hg x hx)

theorem TimesContMdiff.prod_mk {f : M → M'} {g : M → N'} (hf : TimesContMdiff I I' n f) (hg : TimesContMdiff I J' n g) :
  TimesContMdiff I (I'.prod J') n fun x => (f x, g x) :=
  fun x => (hf x).prod_mk (hg x)

theorem TimesContMdiff.prod_mk_space {f : M → E'} {g : M → F'} (hf : TimesContMdiff I 𝓘(𝕜, E') n f)
  (hg : TimesContMdiff I 𝓘(𝕜, F') n g) : TimesContMdiff I 𝓘(𝕜, E' × F') n fun x => (f x, g x) :=
  fun x => (hf x).prod_mk_space (hg x)

theorem SmoothWithinAt.prod_mk {f : M → M'} {g : M → N'} (hf : SmoothWithinAt I I' f s x)
  (hg : SmoothWithinAt I J' g s x) : SmoothWithinAt I (I'.prod J') (fun x => (f x, g x)) s x :=
  hf.prod_mk hg

theorem SmoothWithinAt.prod_mk_space {f : M → E'} {g : M → F'} (hf : SmoothWithinAt I 𝓘(𝕜, E') f s x)
  (hg : SmoothWithinAt I 𝓘(𝕜, F') g s x) : SmoothWithinAt I 𝓘(𝕜, E' × F') (fun x => (f x, g x)) s x :=
  hf.prod_mk_space hg

theorem SmoothAt.prod_mk {f : M → M'} {g : M → N'} (hf : SmoothAt I I' f x) (hg : SmoothAt I J' g x) :
  SmoothAt I (I'.prod J') (fun x => (f x, g x)) x :=
  hf.prod_mk hg

theorem SmoothAt.prod_mk_space {f : M → E'} {g : M → F'} (hf : SmoothAt I 𝓘(𝕜, E') f x) (hg : SmoothAt I 𝓘(𝕜, F') g x) :
  SmoothAt I 𝓘(𝕜, E' × F') (fun x => (f x, g x)) x :=
  hf.prod_mk_space hg

theorem SmoothOn.prod_mk {f : M → M'} {g : M → N'} (hf : SmoothOn I I' f s) (hg : SmoothOn I J' g s) :
  SmoothOn I (I'.prod J') (fun x => (f x, g x)) s :=
  hf.prod_mk hg

theorem SmoothOn.prod_mk_space {f : M → E'} {g : M → F'} (hf : SmoothOn I 𝓘(𝕜, E') f s) (hg : SmoothOn I 𝓘(𝕜, F') g s) :
  SmoothOn I 𝓘(𝕜, E' × F') (fun x => (f x, g x)) s :=
  hf.prod_mk_space hg

theorem Smooth.prod_mk {f : M → M'} {g : M → N'} (hf : Smooth I I' f) (hg : Smooth I J' g) :
  Smooth I (I'.prod J') fun x => (f x, g x) :=
  hf.prod_mk hg

theorem Smooth.prod_mk_space {f : M → E'} {g : M → F'} (hf : Smooth I 𝓘(𝕜, E') f) (hg : Smooth I 𝓘(𝕜, F') g) :
  Smooth I 𝓘(𝕜, E' × F') fun x => (f x, g x) :=
  hf.prod_mk_space hg

end ProdMk

section Projections

theorem times_cont_mdiff_within_at_fst {s : Set (M × N)} {p : M × N} :
  TimesContMdiffWithinAt (I.prod J) I n Prod.fst s p :=
  by 
    rw [times_cont_mdiff_within_at_iff]
    refine' ⟨continuous_within_at_fst, _⟩
    refine' times_cont_diff_within_at_fst.congr (fun y hy => _) _
    ·
      simp' only with mfld_simps  at hy 
      simp' only [hy] with mfld_simps
    ·
      simp' only with mfld_simps

theorem times_cont_mdiff_at_fst {p : M × N} : TimesContMdiffAt (I.prod J) I n Prod.fst p :=
  times_cont_mdiff_within_at_fst

theorem times_cont_mdiff_on_fst {s : Set (M × N)} : TimesContMdiffOn (I.prod J) I n Prod.fst s :=
  fun x hx => times_cont_mdiff_within_at_fst

theorem times_cont_mdiff_fst : TimesContMdiff (I.prod J) I n (@Prod.fst M N) :=
  fun x => times_cont_mdiff_at_fst

theorem smooth_within_at_fst {s : Set (M × N)} {p : M × N} : SmoothWithinAt (I.prod J) I Prod.fst s p :=
  times_cont_mdiff_within_at_fst

theorem smooth_at_fst {p : M × N} : SmoothAt (I.prod J) I Prod.fst p :=
  times_cont_mdiff_at_fst

theorem smooth_on_fst {s : Set (M × N)} : SmoothOn (I.prod J) I Prod.fst s :=
  times_cont_mdiff_on_fst

theorem smooth_fst : Smooth (I.prod J) I (@Prod.fst M N) :=
  times_cont_mdiff_fst

theorem times_cont_mdiff_within_at_snd {s : Set (M × N)} {p : M × N} :
  TimesContMdiffWithinAt (I.prod J) J n Prod.snd s p :=
  by 
    rw [times_cont_mdiff_within_at_iff]
    refine' ⟨continuous_within_at_snd, _⟩
    refine' times_cont_diff_within_at_snd.congr (fun y hy => _) _
    ·
      simp' only with mfld_simps  at hy 
      simp' only [hy] with mfld_simps
    ·
      simp' only with mfld_simps

theorem times_cont_mdiff_at_snd {p : M × N} : TimesContMdiffAt (I.prod J) J n Prod.snd p :=
  times_cont_mdiff_within_at_snd

theorem times_cont_mdiff_on_snd {s : Set (M × N)} : TimesContMdiffOn (I.prod J) J n Prod.snd s :=
  fun x hx => times_cont_mdiff_within_at_snd

theorem times_cont_mdiff_snd : TimesContMdiff (I.prod J) J n (@Prod.snd M N) :=
  fun x => times_cont_mdiff_at_snd

theorem smooth_within_at_snd {s : Set (M × N)} {p : M × N} : SmoothWithinAt (I.prod J) J Prod.snd s p :=
  times_cont_mdiff_within_at_snd

theorem smooth_at_snd {p : M × N} : SmoothAt (I.prod J) J Prod.snd p :=
  times_cont_mdiff_at_snd

theorem smooth_on_snd {s : Set (M × N)} : SmoothOn (I.prod J) J Prod.snd s :=
  times_cont_mdiff_on_snd

theorem smooth_snd : Smooth (I.prod J) J (@Prod.snd M N) :=
  times_cont_mdiff_snd

theorem smooth_iff_proj_smooth {f : M → M' × N'} :
  Smooth I (I'.prod J') f ↔ Smooth I I' (Prod.fst ∘ f) ∧ Smooth I J' (Prod.snd ∘ f) :=
  by 
    split 
    ·
      intro h 
      exact ⟨smooth_fst.comp h, smooth_snd.comp h⟩
    ·
      rintro ⟨h_fst, h_snd⟩
      simpa only [Prod.mk.eta] using h_fst.prod_mk h_snd

end Projections

section prod_mapₓ

variable{g : N → N'}{r : Set N}{y : N}

/-- The product map of two `C^n` functions within a set at a point is `C^n`
within the product set at the product point. -/
theorem TimesContMdiffWithinAt.prod_map' {p : M × N} (hf : TimesContMdiffWithinAt I I' n f s p.1)
  (hg : TimesContMdiffWithinAt J J' n g r p.2) :
  TimesContMdiffWithinAt (I.prod J) (I'.prod J') n (Prod.mapₓ f g) (s.prod r) p :=
  (hf.comp p times_cont_mdiff_within_at_fst (prod_subset_preimage_fst _ _)).prod_mk$
    hg.comp p times_cont_mdiff_within_at_snd (prod_subset_preimage_snd _ _)

theorem TimesContMdiffWithinAt.prod_map (hf : TimesContMdiffWithinAt I I' n f s x)
  (hg : TimesContMdiffWithinAt J J' n g r y) :
  TimesContMdiffWithinAt (I.prod J) (I'.prod J') n (Prod.mapₓ f g) (s.prod r) (x, y) :=
  TimesContMdiffWithinAt.prod_map' hf hg

theorem TimesContMdiffAt.prod_map (hf : TimesContMdiffAt I I' n f x) (hg : TimesContMdiffAt J J' n g y) :
  TimesContMdiffAt (I.prod J) (I'.prod J') n (Prod.mapₓ f g) (x, y) :=
  by 
    rw [←times_cont_mdiff_within_at_univ] at *
    convert hf.prod_map hg 
    exact univ_prod_univ.symm

theorem TimesContMdiffAt.prod_map' {p : M × N} (hf : TimesContMdiffAt I I' n f p.1)
  (hg : TimesContMdiffAt J J' n g p.2) : TimesContMdiffAt (I.prod J) (I'.prod J') n (Prod.mapₓ f g) p :=
  by 
    rcases p with ⟨⟩
    exact hf.prod_map hg

theorem TimesContMdiffOn.prod_map (hf : TimesContMdiffOn I I' n f s) (hg : TimesContMdiffOn J J' n g r) :
  TimesContMdiffOn (I.prod J) (I'.prod J') n (Prod.mapₓ f g) (s.prod r) :=
  (hf.comp times_cont_mdiff_on_fst (prod_subset_preimage_fst _ _)).prod_mk$
    hg.comp times_cont_mdiff_on_snd (prod_subset_preimage_snd _ _)

theorem TimesContMdiff.prod_map (hf : TimesContMdiff I I' n f) (hg : TimesContMdiff J J' n g) :
  TimesContMdiff (I.prod J) (I'.prod J') n (Prod.mapₓ f g) :=
  by 
    intro p 
    exact (hf p.1).prod_map' (hg p.2)

theorem SmoothWithinAt.prod_map (hf : SmoothWithinAt I I' f s x) (hg : SmoothWithinAt J J' g r y) :
  SmoothWithinAt (I.prod J) (I'.prod J') (Prod.mapₓ f g) (s.prod r) (x, y) :=
  hf.prod_map hg

theorem SmoothAt.prod_map (hf : SmoothAt I I' f x) (hg : SmoothAt J J' g y) :
  SmoothAt (I.prod J) (I'.prod J') (Prod.mapₓ f g) (x, y) :=
  hf.prod_map hg

theorem SmoothOn.prod_map (hf : SmoothOn I I' f s) (hg : SmoothOn J J' g r) :
  SmoothOn (I.prod J) (I'.prod J') (Prod.mapₓ f g) (s.prod r) :=
  hf.prod_map hg

theorem Smooth.prod_map (hf : Smooth I I' f) (hg : Smooth J J' g) : Smooth (I.prod J) (I'.prod J') (Prod.mapₓ f g) :=
  hf.prod_map hg

end prod_mapₓ

section PiSpace

/-!
### Smoothness of functions with codomain `Π i, F i`

We have no `model_with_corners.pi` yet, so we prove lemmas about functions `f : M → Π i, F i` and
use `𝓘(𝕜, Π i, F i)` as the model space.
-/


variable{ι : Type _}[Fintype ι]{Fi : ι → Type _}[∀ i, NormedGroup (Fi i)][∀ i, NormedSpace 𝕜 (Fi i)]{φ : M → ∀ i, Fi i}

theorem times_cont_mdiff_within_at_pi_space :
  TimesContMdiffWithinAt I 𝓘(𝕜, ∀ i, Fi i) n φ s x ↔ ∀ i, TimesContMdiffWithinAt I 𝓘(𝕜, Fi i) n (fun x => φ x i) s x :=
  by 
    simp only [times_cont_mdiff_within_at_iff'', continuous_within_at_pi, times_cont_diff_within_at_pi,
      forall_and_distrib, writtenInExtChartAt, ext_chart_model_space_eq_id, · ∘ ·, LocalEquiv.refl_coe, id]

theorem times_cont_mdiff_on_pi_space :
  TimesContMdiffOn I 𝓘(𝕜, ∀ i, Fi i) n φ s ↔ ∀ i, TimesContMdiffOn I 𝓘(𝕜, Fi i) n (fun x => φ x i) s :=
  ⟨fun h i x hx => times_cont_mdiff_within_at_pi_space.1 (h x hx) i,
    fun h x hx => times_cont_mdiff_within_at_pi_space.2 fun i => h i x hx⟩

theorem times_cont_mdiff_at_pi_space :
  TimesContMdiffAt I 𝓘(𝕜, ∀ i, Fi i) n φ x ↔ ∀ i, TimesContMdiffAt I 𝓘(𝕜, Fi i) n (fun x => φ x i) x :=
  times_cont_mdiff_within_at_pi_space

theorem times_cont_mdiff_pi_space :
  TimesContMdiff I 𝓘(𝕜, ∀ i, Fi i) n φ ↔ ∀ i, TimesContMdiff I 𝓘(𝕜, Fi i) n fun x => φ x i :=
  ⟨fun h i x => times_cont_mdiff_at_pi_space.1 (h x) i, fun h x => times_cont_mdiff_at_pi_space.2 fun i => h i x⟩

theorem smooth_within_at_pi_space :
  SmoothWithinAt I 𝓘(𝕜, ∀ i, Fi i) φ s x ↔ ∀ i, SmoothWithinAt I 𝓘(𝕜, Fi i) (fun x => φ x i) s x :=
  times_cont_mdiff_within_at_pi_space

theorem smooth_on_pi_space : SmoothOn I 𝓘(𝕜, ∀ i, Fi i) φ s ↔ ∀ i, SmoothOn I 𝓘(𝕜, Fi i) (fun x => φ x i) s :=
  times_cont_mdiff_on_pi_space

theorem smooth_at_pi_space : SmoothAt I 𝓘(𝕜, ∀ i, Fi i) φ x ↔ ∀ i, SmoothAt I 𝓘(𝕜, Fi i) (fun x => φ x i) x :=
  times_cont_mdiff_at_pi_space

theorem smooth_pi_space : Smooth I 𝓘(𝕜, ∀ i, Fi i) φ ↔ ∀ i, Smooth I 𝓘(𝕜, Fi i) fun x => φ x i :=
  times_cont_mdiff_pi_space

end PiSpace

/-! ### Linear maps between normed spaces are smooth -/


theorem ContinuousLinearMap.times_cont_mdiff (L : E →L[𝕜] F) : TimesContMdiff 𝓘(𝕜, E) 𝓘(𝕜, F) n L :=
  L.times_cont_diff.times_cont_mdiff

/-! ### Smoothness of standard operations -/


variable{V : Type _}[NormedGroup V][NormedSpace 𝕜 V]

-- error in Geometry.Manifold.TimesContMdiff: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- On any vector space, multiplication by a scalar is a smooth operation. -/
theorem smooth_smul : smooth («expr𝓘( )»(𝕜).prod «expr𝓘( , )»(𝕜, V)) «expr𝓘( , )»(𝕜, V) (λ
 p : «expr × »(𝕜, V), «expr • »(p.1, p.2)) :=
smooth_iff.2 ⟨continuous_smul, λ x y, times_cont_diff_smul.times_cont_diff_on⟩

theorem Smooth.smul {N : Type _} [TopologicalSpace N] [ChartedSpace H N] {f : N → 𝕜} {g : N → V} (hf : Smooth I 𝓘(𝕜) f)
  (hg : Smooth I 𝓘(𝕜, V) g) : Smooth I 𝓘(𝕜, V) fun p => f p • g p :=
  smooth_smul.comp (hf.prod_mk hg)

theorem SmoothOn.smul {N : Type _} [TopologicalSpace N] [ChartedSpace H N] {f : N → 𝕜} {g : N → V} {s : Set N}
  (hf : SmoothOn I 𝓘(𝕜) f s) (hg : SmoothOn I 𝓘(𝕜, V) g s) : SmoothOn I 𝓘(𝕜, V) (fun p => f p • g p) s :=
  smooth_smul.comp_smooth_on (hf.prod_mk hg)

theorem SmoothAt.smul {N : Type _} [TopologicalSpace N] [ChartedSpace H N] {f : N → 𝕜} {g : N → V} {x : N}
  (hf : SmoothAt I 𝓘(𝕜) f x) (hg : SmoothAt I 𝓘(𝕜, V) g x) : SmoothAt I 𝓘(𝕜, V) (fun p => f p • g p) x :=
  smooth_smul.SmoothAt.comp _ (hf.prod_mk hg)

