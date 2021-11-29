import Mathbin.Analysis.Calculus.Fderiv 
import Mathbin.Data.Polynomial.Derivative

/-!

# One-dimensional derivatives

This file defines the derivative of a function `f : 𝕜 → F` where `𝕜` is a
normed field and `F` is a normed space over this field. The derivative of
such a function `f` at a point `x` is given by an element `f' : F`.

The theory is developed analogously to the [Fréchet
derivatives](./fderiv.html). We first introduce predicates defined in terms
of the corresponding predicates for Fréchet derivatives:

 - `has_deriv_at_filter f f' x L` states that the function `f` has the
    derivative `f'` at the point `x` as `x` goes along the filter `L`.

 - `has_deriv_within_at f f' s x` states that the function `f` has the
    derivative `f'` at the point `x` within the subset `s`.

 - `has_deriv_at f f' x` states that the function `f` has the derivative `f'`
    at the point `x`.

 - `has_strict_deriv_at f f' x` states that the function `f` has the derivative `f'`
    at the point `x` in the sense of strict differentiability, i.e.,
   `f y - f z = (y - z) • f' + o (y - z)` as `y, z → x`.

For the last two notions we also define a functional version:

  - `deriv_within f s x` is a derivative of `f` at `x` within `s`. If the
    derivative does not exist, then `deriv_within f s x` equals zero.

  - `deriv f x` is a derivative of `f` at `x`. If the derivative does not
    exist, then `deriv f x` equals zero.

The theorems `fderiv_within_deriv_within` and `fderiv_deriv` show that the
one-dimensional derivatives coincide with the general Fréchet derivatives.

We also show the existence and compute the derivatives of:
  - constants
  - the identity function
  - linear maps
  - addition
  - sum of finitely many functions
  - negation
  - subtraction
  - multiplication
  - inverse `x → x⁻¹`
  - multiplication of two functions in `𝕜 → 𝕜`
  - multiplication of a function in `𝕜 → 𝕜` and of a function in `𝕜 → E`
  - composition of a function in `𝕜 → F` with a function in `𝕜 → 𝕜`
  - composition of a function in `F → E` with a function in `𝕜 → F`
  - inverse function (assuming that it exists; the inverse function theorem is in `inverse.lean`)
  - division
  - polynomials

For most binary operations we also define `const_op` and `op_const` theorems for the cases when
the first or second argument is a constant. This makes writing chains of `has_deriv_at`'s easier,
and they more frequently lead to the desired result.

We set up the simplifier so that it can compute the derivative of simple functions. For instance,
```lean
example (x : ℝ) : deriv (λ x, cos (sin x) * exp x) x = (cos(sin(x))-sin(sin(x))*cos(x))*exp(x) :=
by { simp, ring }
```

## Implementation notes

Most of the theorems are direct restatements of the corresponding theorems
for Fréchet derivatives.

The strategy to construct simp lemmas that give the simplifier the possibility to compute
derivatives is the same as the one for differentiability statements, as explained in `fderiv.lean`.
See the explanations there.
-/


universe u v w

noncomputable theory

open_locale Classical TopologicalSpace BigOperators Filter Ennreal

open Filter Asymptotics Set

open continuous_linear_map(smulRight smul_right_one_eq_iff)

variable{𝕜 : Type u}[NondiscreteNormedField 𝕜]

section 

variable{F : Type v}[NormedGroup F][NormedSpace 𝕜 F]

variable{E : Type w}[NormedGroup E][NormedSpace 𝕜 E]

/--
`f` has the derivative `f'` at the point `x` as `x` goes along the filter `L`.

That is, `f x' = f x + (x' - x) • f' + o(x' - x)` where `x'` converges along the filter `L`.
-/
def HasDerivAtFilter (f : 𝕜 → F) (f' : F) (x : 𝕜) (L : Filter 𝕜) :=
  HasFderivAtFilter f (smul_right (1 : 𝕜 →L[𝕜] 𝕜) f') x L

/--
`f` has the derivative `f'` at the point `x` within the subset `s`.

That is, `f x' = f x + (x' - x) • f' + o(x' - x)` where `x'` converges to `x` inside `s`.
-/
def HasDerivWithinAt (f : 𝕜 → F) (f' : F) (s : Set 𝕜) (x : 𝕜) :=
  HasDerivAtFilter f f' x (𝓝[s] x)

/--
`f` has the derivative `f'` at the point `x`.

That is, `f x' = f x + (x' - x) • f' + o(x' - x)` where `x'` converges to `x`.
-/
def HasDerivAt (f : 𝕜 → F) (f' : F) (x : 𝕜) :=
  HasDerivAtFilter f f' x (𝓝 x)

/-- `f` has the derivative `f'` at the point `x` in the sense of strict differentiability.

That is, `f y - f z = (y - z) • f' + o(y - z)` as `y, z → x`. -/
def HasStrictDerivAt (f : 𝕜 → F) (f' : F) (x : 𝕜) :=
  HasStrictFderivAt f (smul_right (1 : 𝕜 →L[𝕜] 𝕜) f') x

/--
Derivative of `f` at the point `x` within the set `s`, if it exists.  Zero otherwise.

If the derivative exists (i.e., `∃ f', has_deriv_within_at f f' s x`), then
`f x' = f x + (x' - x) • deriv_within f s x + o(x' - x)` where `x'` converges to `x` inside `s`.
-/
def derivWithin (f : 𝕜 → F) (s : Set 𝕜) (x : 𝕜) :=
  fderivWithin 𝕜 f s x 1

/--
Derivative of `f` at the point `x`, if it exists.  Zero otherwise.

If the derivative exists (i.e., `∃ f', has_deriv_at f f' x`), then
`f x' = f x + (x' - x) • deriv f x + o(x' - x)` where `x'` converges to `x`.
-/
def deriv (f : 𝕜 → F) (x : 𝕜) :=
  fderiv 𝕜 f x 1

variable{f f₀ f₁ g : 𝕜 → F}

variable{f' f₀' f₁' g' : F}

variable{x : 𝕜}

variable{s t : Set 𝕜}

variable{L L₁ L₂ : Filter 𝕜}

/-- Expressing `has_fderiv_at_filter f f' x L` in terms of `has_deriv_at_filter` -/
theorem has_fderiv_at_filter_iff_has_deriv_at_filter {f' : 𝕜 →L[𝕜] F} :
  HasFderivAtFilter f f' x L ↔ HasDerivAtFilter f (f' 1) x L :=
  by 
    simp [HasDerivAtFilter]

theorem HasFderivAtFilter.has_deriv_at_filter {f' : 𝕜 →L[𝕜] F} :
  HasFderivAtFilter f f' x L → HasDerivAtFilter f (f' 1) x L :=
  has_fderiv_at_filter_iff_has_deriv_at_filter.mp

/-- Expressing `has_fderiv_within_at f f' s x` in terms of `has_deriv_within_at` -/
theorem has_fderiv_within_at_iff_has_deriv_within_at {f' : 𝕜 →L[𝕜] F} :
  HasFderivWithinAt f f' s x ↔ HasDerivWithinAt f (f' 1) s x :=
  has_fderiv_at_filter_iff_has_deriv_at_filter

/-- Expressing `has_deriv_within_at f f' s x` in terms of `has_fderiv_within_at` -/
theorem has_deriv_within_at_iff_has_fderiv_within_at {f' : F} :
  HasDerivWithinAt f f' s x ↔ HasFderivWithinAt f (smul_right (1 : 𝕜 →L[𝕜] 𝕜) f') s x :=
  Iff.rfl

theorem HasFderivWithinAt.has_deriv_within_at {f' : 𝕜 →L[𝕜] F} :
  HasFderivWithinAt f f' s x → HasDerivWithinAt f (f' 1) s x :=
  has_fderiv_within_at_iff_has_deriv_within_at.mp

theorem HasDerivWithinAt.has_fderiv_within_at {f' : F} :
  HasDerivWithinAt f f' s x → HasFderivWithinAt f (smul_right (1 : 𝕜 →L[𝕜] 𝕜) f') s x :=
  has_deriv_within_at_iff_has_fderiv_within_at.mp

/-- Expressing `has_fderiv_at f f' x` in terms of `has_deriv_at` -/
theorem has_fderiv_at_iff_has_deriv_at {f' : 𝕜 →L[𝕜] F} : HasFderivAt f f' x ↔ HasDerivAt f (f' 1) x :=
  has_fderiv_at_filter_iff_has_deriv_at_filter

theorem HasFderivAt.has_deriv_at {f' : 𝕜 →L[𝕜] F} : HasFderivAt f f' x → HasDerivAt f (f' 1) x :=
  has_fderiv_at_iff_has_deriv_at.mp

theorem has_strict_fderiv_at_iff_has_strict_deriv_at {f' : 𝕜 →L[𝕜] F} :
  HasStrictFderivAt f f' x ↔ HasStrictDerivAt f (f' 1) x :=
  by 
    simp [HasStrictDerivAt, HasStrictFderivAt]

protected theorem HasStrictFderivAt.has_strict_deriv_at {f' : 𝕜 →L[𝕜] F} :
  HasStrictFderivAt f f' x → HasStrictDerivAt f (f' 1) x :=
  has_strict_fderiv_at_iff_has_strict_deriv_at.mp

theorem has_strict_deriv_at_iff_has_strict_fderiv_at :
  HasStrictDerivAt f f' x ↔ HasStrictFderivAt f (smul_right (1 : 𝕜 →L[𝕜] 𝕜) f') x :=
  Iff.rfl

alias has_strict_deriv_at_iff_has_strict_fderiv_at ↔ HasStrictDerivAt.has_strict_fderiv_at _

/-- Expressing `has_deriv_at f f' x` in terms of `has_fderiv_at` -/
theorem has_deriv_at_iff_has_fderiv_at {f' : F} : HasDerivAt f f' x ↔ HasFderivAt f (smul_right (1 : 𝕜 →L[𝕜] 𝕜) f') x :=
  Iff.rfl

alias has_deriv_at_iff_has_fderiv_at ↔ HasDerivAt.has_fderiv_at _

theorem deriv_within_zero_of_not_differentiable_within_at (h : ¬DifferentiableWithinAt 𝕜 f s x) :
  derivWithin f s x = 0 :=
  by 
    unfold derivWithin 
    rw [fderiv_within_zero_of_not_differentiable_within_at]
    simp 
    assumption

theorem differentiable_within_at_of_deriv_within_ne_zero (h : derivWithin f s x ≠ 0) : DifferentiableWithinAt 𝕜 f s x :=
  not_imp_comm.1 deriv_within_zero_of_not_differentiable_within_at h

theorem deriv_zero_of_not_differentiable_at (h : ¬DifferentiableAt 𝕜 f x) : deriv f x = 0 :=
  by 
    unfold deriv 
    rw [fderiv_zero_of_not_differentiable_at]
    simp 
    assumption

theorem differentiable_at_of_deriv_ne_zero (h : deriv f x ≠ 0) : DifferentiableAt 𝕜 f x :=
  not_imp_comm.1 deriv_zero_of_not_differentiable_at h

theorem UniqueDiffWithinAt.eq_deriv (s : Set 𝕜) (H : UniqueDiffWithinAt 𝕜 s x) (h : HasDerivWithinAt f f' s x)
  (h₁ : HasDerivWithinAt f f₁' s x) : f' = f₁' :=
  smul_right_one_eq_iff.mp$ UniqueDiffWithinAt.eq H h h₁

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem has_deriv_at_filter_iff_tendsto : «expr ↔ »(has_deriv_at_filter f f' x L, tendsto (λ
  x' : 𝕜, «expr * »(«expr ⁻¹»(«expr∥ ∥»(«expr - »(x', x))), «expr∥ ∥»(«expr - »(«expr - »(f x', f x), «expr • »(«expr - »(x', x), f'))))) L (expr𝓝() 0)) :=
has_fderiv_at_filter_iff_tendsto

theorem has_deriv_within_at_iff_tendsto :
  HasDerivWithinAt f f' s x ↔ tendsto (fun x' => ∥x' - x∥⁻¹*∥f x' - f x - (x' - x) • f'∥) (𝓝[s] x) (𝓝 0) :=
  has_fderiv_at_filter_iff_tendsto

theorem has_deriv_at_iff_tendsto :
  HasDerivAt f f' x ↔ tendsto (fun x' => ∥x' - x∥⁻¹*∥f x' - f x - (x' - x) • f'∥) (𝓝 x) (𝓝 0) :=
  has_fderiv_at_filter_iff_tendsto

theorem HasStrictDerivAt.has_deriv_at (h : HasStrictDerivAt f f' x) : HasDerivAt f f' x :=
  h.has_fderiv_at

/-- If the domain has dimension one, then Fréchet derivative is equivalent to the classical
definition with a limit. In this version we have to take the limit along the subset `-{x}`,
because for `y=x` the slope equals zero due to the convention `0⁻¹=0`. -/
theorem has_deriv_at_filter_iff_tendsto_slope {x : 𝕜} {L : Filter 𝕜} :
  HasDerivAtFilter f f' x L ↔ tendsto (fun y => (y - x)⁻¹ • (f y - f x)) (L⊓𝓟 («expr ᶜ» {x})) (𝓝 f') :=
  by 
    convLHS =>
      simp only [has_deriv_at_filter_iff_tendsto, (NormedField.norm_inv _).symm, (norm_smul _ _).symm,
        tendsto_zero_iff_norm_tendsto_zero.symm]
    convRHS => rw [←nhds_translation_sub f', tendsto_comap_iff]
    refine'
      (tendsto_inf_principal_nhds_iff_of_forall_eq$
              by 
                simp ).symm.trans
        (tendsto_congr' _)
    refine' (eventually_principal.2$ fun z hz => _).filter_mono inf_le_right 
    simp only [· ∘ ·]
    rw [smul_sub, ←mul_smul, inv_mul_cancel (sub_ne_zero.2 hz), one_smul]

theorem has_deriv_within_at_iff_tendsto_slope :
  HasDerivWithinAt f f' s x ↔ tendsto (fun y => (y - x)⁻¹ • (f y - f x)) (𝓝[s \ {x}] x) (𝓝 f') :=
  by 
    simp only [HasDerivWithinAt, nhdsWithin, diff_eq, inf_assoc.symm, inf_principal.symm]
    exact has_deriv_at_filter_iff_tendsto_slope

theorem has_deriv_within_at_iff_tendsto_slope' (hs : x ∉ s) :
  HasDerivWithinAt f f' s x ↔ tendsto (fun y => (y - x)⁻¹ • (f y - f x)) (𝓝[s] x) (𝓝 f') :=
  by 
    convert ← has_deriv_within_at_iff_tendsto_slope 
    exact diff_singleton_eq_self hs

theorem has_deriv_at_iff_tendsto_slope :
  HasDerivAt f f' x ↔ tendsto (fun y => (y - x)⁻¹ • (f y - f x)) (𝓝[«expr ᶜ» {x}] x) (𝓝 f') :=
  has_deriv_at_filter_iff_tendsto_slope

theorem has_deriv_within_at_congr_set {s t u : Set 𝕜} (hu : u ∈ 𝓝 x) (h : s ∩ u = t ∩ u) :
  HasDerivWithinAt f f' s x ↔ HasDerivWithinAt f f' t x :=
  by 
    simpRw [HasDerivWithinAt, nhds_within_eq_nhds_within' hu h]

alias has_deriv_within_at_congr_set ↔ HasDerivWithinAt.congr_set _

@[simp]
theorem has_deriv_within_at_diff_singleton : HasDerivWithinAt f f' (s \ {x}) x ↔ HasDerivWithinAt f f' s x :=
  by 
    simp only [has_deriv_within_at_iff_tendsto_slope, sdiff_idem]

@[simp]
theorem has_deriv_within_at_Ioi_iff_Ici [PartialOrderₓ 𝕜] :
  HasDerivWithinAt f f' (Ioi x) x ↔ HasDerivWithinAt f f' (Ici x) x :=
  by 
    rw [←Ici_diff_left, has_deriv_within_at_diff_singleton]

alias has_deriv_within_at_Ioi_iff_Ici ↔ HasDerivWithinAt.Ici_of_Ioi HasDerivWithinAt.Ioi_of_Ici

@[simp]
theorem has_deriv_within_at_Iio_iff_Iic [PartialOrderₓ 𝕜] :
  HasDerivWithinAt f f' (Iio x) x ↔ HasDerivWithinAt f f' (Iic x) x :=
  by 
    rw [←Iic_diff_right, has_deriv_within_at_diff_singleton]

alias has_deriv_within_at_Iio_iff_Iic ↔ HasDerivWithinAt.Iic_of_Iio HasDerivWithinAt.Iio_of_Iic

theorem HasDerivWithinAt.Ioi_iff_Ioo [LinearOrderₓ 𝕜] [OrderClosedTopology 𝕜] {x y : 𝕜} (h : x < y) :
  HasDerivWithinAt f f' (Ioo x y) x ↔ HasDerivWithinAt f f' (Ioi x) x :=
  has_deriv_within_at_congr_set (is_open_Iio.mem_nhds h)$
    by 
      rw [Ioi_inter_Iio, inter_eq_left_iff_subset]
      exact Ioo_subset_Iio_self

alias HasDerivWithinAt.Ioi_iff_Ioo ↔ HasDerivWithinAt.Ioi_of_Ioo HasDerivWithinAt.Ioo_of_Ioi

theorem has_deriv_at_iff_is_o_nhds_zero :
  HasDerivAt f f' x ↔ is_o (fun h => f (x+h) - f x - h • f') (fun h => h) (𝓝 0) :=
  has_fderiv_at_iff_is_o_nhds_zero

theorem HasDerivAtFilter.mono (h : HasDerivAtFilter f f' x L₂) (hst : L₁ ≤ L₂) : HasDerivAtFilter f f' x L₁ :=
  HasFderivAtFilter.mono h hst

theorem HasDerivWithinAt.mono (h : HasDerivWithinAt f f' t x) (hst : s ⊆ t) : HasDerivWithinAt f f' s x :=
  HasFderivWithinAt.mono h hst

theorem HasDerivAt.has_deriv_at_filter (h : HasDerivAt f f' x) (hL : L ≤ 𝓝 x) : HasDerivAtFilter f f' x L :=
  HasFderivAt.has_fderiv_at_filter h hL

theorem HasDerivAt.has_deriv_within_at (h : HasDerivAt f f' x) : HasDerivWithinAt f f' s x :=
  HasFderivAt.has_fderiv_within_at h

theorem HasDerivWithinAt.differentiable_within_at (h : HasDerivWithinAt f f' s x) : DifferentiableWithinAt 𝕜 f s x :=
  HasFderivWithinAt.differentiable_within_at h

theorem HasDerivAt.differentiable_at (h : HasDerivAt f f' x) : DifferentiableAt 𝕜 f x :=
  HasFderivAt.differentiable_at h

@[simp]
theorem has_deriv_within_at_univ : HasDerivWithinAt f f' univ x ↔ HasDerivAt f f' x :=
  has_fderiv_within_at_univ

theorem HasDerivAt.unique (h₀ : HasDerivAt f f₀' x) (h₁ : HasDerivAt f f₁' x) : f₀' = f₁' :=
  smul_right_one_eq_iff.mp$ h₀.has_fderiv_at.unique h₁

theorem has_deriv_within_at_inter' (h : t ∈ 𝓝[s] x) : HasDerivWithinAt f f' (s ∩ t) x ↔ HasDerivWithinAt f f' s x :=
  has_fderiv_within_at_inter' h

theorem has_deriv_within_at_inter (h : t ∈ 𝓝 x) : HasDerivWithinAt f f' (s ∩ t) x ↔ HasDerivWithinAt f f' s x :=
  has_fderiv_within_at_inter h

theorem HasDerivWithinAt.union (hs : HasDerivWithinAt f f' s x) (ht : HasDerivWithinAt f f' t x) :
  HasDerivWithinAt f f' (s ∪ t) x :=
  by 
    simp only [HasDerivWithinAt, nhds_within_union]
    exact hs.join ht

theorem HasDerivWithinAt.nhds_within (h : HasDerivWithinAt f f' s x) (ht : s ∈ 𝓝[t] x) : HasDerivWithinAt f f' t x :=
  (has_deriv_within_at_inter' ht).1 (h.mono (inter_subset_right _ _))

theorem HasDerivWithinAt.has_deriv_at (h : HasDerivWithinAt f f' s x) (hs : s ∈ 𝓝 x) : HasDerivAt f f' x :=
  HasFderivWithinAt.has_fderiv_at h hs

theorem DifferentiableWithinAt.has_deriv_within_at (h : DifferentiableWithinAt 𝕜 f s x) :
  HasDerivWithinAt f (derivWithin f s x) s x :=
  h.has_fderiv_within_at.has_deriv_within_at

theorem DifferentiableAt.has_deriv_at (h : DifferentiableAt 𝕜 f x) : HasDerivAt f (deriv f x) x :=
  h.has_fderiv_at.has_deriv_at

theorem DifferentiableOn.has_deriv_at (h : DifferentiableOn 𝕜 f s) (hs : s ∈ 𝓝 x) : HasDerivAt f (deriv f x) x :=
  (h.has_fderiv_at hs).HasDerivAt

theorem HasDerivAt.deriv (h : HasDerivAt f f' x) : deriv f x = f' :=
  h.differentiable_at.has_deriv_at.unique h

theorem HasDerivWithinAt.deriv_within (h : HasDerivWithinAt f f' s x) (hxs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin f s x = f' :=
  hxs.eq_deriv _ h.differentiable_within_at.has_deriv_within_at h

theorem fderiv_within_deriv_within : (fderivWithin 𝕜 f s x : 𝕜 → F) 1 = derivWithin f s x :=
  rfl

theorem deriv_within_fderiv_within : smul_right (1 : 𝕜 →L[𝕜] 𝕜) (derivWithin f s x) = fderivWithin 𝕜 f s x :=
  by 
    simp [derivWithin]

theorem fderiv_deriv : (fderiv 𝕜 f x : 𝕜 → F) 1 = deriv f x :=
  rfl

theorem deriv_fderiv : smul_right (1 : 𝕜 →L[𝕜] 𝕜) (deriv f x) = fderiv 𝕜 f x :=
  by 
    simp [deriv]

theorem DifferentiableAt.deriv_within (h : DifferentiableAt 𝕜 f x) (hxs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin f s x = deriv f x :=
  by 
    unfold derivWithin deriv 
    rw [h.fderiv_within hxs]

theorem deriv_within_subset (st : s ⊆ t) (ht : UniqueDiffWithinAt 𝕜 s x) (h : DifferentiableWithinAt 𝕜 f t x) :
  derivWithin f s x = derivWithin f t x :=
  ((DifferentiableWithinAt.has_deriv_within_at h).mono st).derivWithin ht

@[simp]
theorem deriv_within_univ : derivWithin f univ = deriv f :=
  by 
    ext 
    unfold derivWithin deriv 
    rw [fderiv_within_univ]

theorem deriv_within_inter (ht : t ∈ 𝓝 x) (hs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin f (s ∩ t) x = derivWithin f s x :=
  by 
    unfold derivWithin 
    rw [fderiv_within_inter ht hs]

theorem deriv_within_of_open (hs : IsOpen s) (hx : x ∈ s) : derivWithin f s x = deriv f x :=
  by 
    unfold derivWithin 
    rw [fderiv_within_of_open hs hx]
    rfl

section congr

/-! ### Congruence properties of derivatives -/


theorem Filter.EventuallyEq.has_deriv_at_filter_iff (h₀ : f₀ =ᶠ[L] f₁) (hx : f₀ x = f₁ x) (h₁ : f₀' = f₁') :
  HasDerivAtFilter f₀ f₀' x L ↔ HasDerivAtFilter f₁ f₁' x L :=
  h₀.has_fderiv_at_filter_iff hx
    (by 
      simp [h₁])

theorem HasDerivAtFilter.congr_of_eventually_eq (h : HasDerivAtFilter f f' x L) (hL : f₁ =ᶠ[L] f) (hx : f₁ x = f x) :
  HasDerivAtFilter f₁ f' x L :=
  by 
    rwa [hL.has_deriv_at_filter_iff hx rfl]

theorem HasDerivWithinAt.congr_mono (h : HasDerivWithinAt f f' s x) (ht : ∀ x (_ : x ∈ t), f₁ x = f x) (hx : f₁ x = f x)
  (h₁ : t ⊆ s) : HasDerivWithinAt f₁ f' t x :=
  HasFderivWithinAt.congr_mono h ht hx h₁

theorem HasDerivWithinAt.congr (h : HasDerivWithinAt f f' s x) (hs : ∀ x (_ : x ∈ s), f₁ x = f x) (hx : f₁ x = f x) :
  HasDerivWithinAt f₁ f' s x :=
  h.congr_mono hs hx (subset.refl _)

theorem HasDerivWithinAt.congr_of_eventually_eq (h : HasDerivWithinAt f f' s x) (h₁ : f₁ =ᶠ[𝓝[s] x] f)
  (hx : f₁ x = f x) : HasDerivWithinAt f₁ f' s x :=
  HasDerivAtFilter.congr_of_eventually_eq h h₁ hx

theorem HasDerivWithinAt.congr_of_eventually_eq_of_mem (h : HasDerivWithinAt f f' s x) (h₁ : f₁ =ᶠ[𝓝[s] x] f)
  (hx : x ∈ s) : HasDerivWithinAt f₁ f' s x :=
  h.congr_of_eventually_eq h₁ (h₁.eq_of_nhds_within hx)

theorem HasDerivAt.congr_of_eventually_eq (h : HasDerivAt f f' x) (h₁ : f₁ =ᶠ[𝓝 x] f) : HasDerivAt f₁ f' x :=
  HasDerivAtFilter.congr_of_eventually_eq h h₁ (mem_of_mem_nhds h₁ : _)

theorem Filter.EventuallyEq.deriv_within_eq (hs : UniqueDiffWithinAt 𝕜 s x) (hL : f₁ =ᶠ[𝓝[s] x] f) (hx : f₁ x = f x) :
  derivWithin f₁ s x = derivWithin f s x :=
  by 
    unfold derivWithin 
    rw [hL.fderiv_within_eq hs hx]

theorem deriv_within_congr (hs : UniqueDiffWithinAt 𝕜 s x) (hL : ∀ y (_ : y ∈ s), f₁ y = f y) (hx : f₁ x = f x) :
  derivWithin f₁ s x = derivWithin f s x :=
  by 
    unfold derivWithin 
    rw [fderiv_within_congr hs hL hx]

theorem Filter.EventuallyEq.deriv_eq (hL : f₁ =ᶠ[𝓝 x] f) : deriv f₁ x = deriv f x :=
  by 
    unfold deriv 
    rwa [Filter.EventuallyEq.fderiv_eq]

protected theorem Filter.EventuallyEq.deriv (h : f₁ =ᶠ[𝓝 x] f) : deriv f₁ =ᶠ[𝓝 x] deriv f :=
  h.eventually_eq_nhds.mono$ fun x h => h.deriv_eq

end congr

section id

/-! ### Derivative of the identity -/


variable(s x L)

theorem has_deriv_at_filter_id : HasDerivAtFilter id 1 x L :=
  (has_fderiv_at_filter_id x L).HasDerivAtFilter

theorem has_deriv_within_at_id : HasDerivWithinAt id 1 s x :=
  has_deriv_at_filter_id _ _

theorem has_deriv_at_id : HasDerivAt id 1 x :=
  has_deriv_at_filter_id _ _

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem has_deriv_at_id' : has_deriv_at (λ x : 𝕜, x) 1 x := has_deriv_at_filter_id _ _

theorem has_strict_deriv_at_id : HasStrictDerivAt id 1 x :=
  (has_strict_fderiv_at_id x).HasStrictDerivAt

theorem deriv_id : deriv id x = 1 :=
  HasDerivAt.deriv (has_deriv_at_id x)

@[simp]
theorem deriv_id' : deriv (@id 𝕜) = fun _ => 1 :=
  funext deriv_id

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp] theorem deriv_id'' : «expr = »(deriv (λ x : 𝕜, x), λ _, 1) := deriv_id'

theorem deriv_within_id (hxs : UniqueDiffWithinAt 𝕜 s x) : derivWithin id s x = 1 :=
  (has_deriv_within_at_id x s).derivWithin hxs

end id

section Const

/-! ### Derivative of constant functions -/


variable(c : F)(s x L)

theorem has_deriv_at_filter_const : HasDerivAtFilter (fun x => c) 0 x L :=
  (has_fderiv_at_filter_const c x L).HasDerivAtFilter

theorem has_strict_deriv_at_const : HasStrictDerivAt (fun x => c) 0 x :=
  (has_strict_fderiv_at_const c x).HasStrictDerivAt

theorem has_deriv_within_at_const : HasDerivWithinAt (fun x => c) 0 s x :=
  has_deriv_at_filter_const _ _ _

theorem has_deriv_at_const : HasDerivAt (fun x => c) 0 x :=
  has_deriv_at_filter_const _ _ _

theorem deriv_const : deriv (fun x => c) x = 0 :=
  HasDerivAt.deriv (has_deriv_at_const x c)

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp] theorem deriv_const' : «expr = »(deriv (λ x : 𝕜, c), λ x, 0) := funext (λ x, deriv_const x c)

theorem deriv_within_const (hxs : UniqueDiffWithinAt 𝕜 s x) : derivWithin (fun x => c) s x = 0 :=
  (has_deriv_within_at_const _ _ _).derivWithin hxs

end Const

section ContinuousLinearMap

/-! ### Derivative of continuous linear maps -/


variable(e : 𝕜 →L[𝕜] F)

protected theorem ContinuousLinearMap.has_deriv_at_filter : HasDerivAtFilter e (e 1) x L :=
  e.has_fderiv_at_filter.has_deriv_at_filter

protected theorem ContinuousLinearMap.has_strict_deriv_at : HasStrictDerivAt e (e 1) x :=
  e.has_strict_fderiv_at.has_strict_deriv_at

protected theorem ContinuousLinearMap.has_deriv_at : HasDerivAt e (e 1) x :=
  e.has_deriv_at_filter

protected theorem ContinuousLinearMap.has_deriv_within_at : HasDerivWithinAt e (e 1) s x :=
  e.has_deriv_at_filter

@[simp]
protected theorem ContinuousLinearMap.deriv : deriv e x = e 1 :=
  e.has_deriv_at.deriv

protected theorem ContinuousLinearMap.deriv_within (hxs : UniqueDiffWithinAt 𝕜 s x) : derivWithin e s x = e 1 :=
  e.has_deriv_within_at.deriv_within hxs

end ContinuousLinearMap

section LinearMap

/-! ### Derivative of bundled linear maps -/


variable(e : 𝕜 →ₗ[𝕜] F)

protected theorem LinearMap.has_deriv_at_filter : HasDerivAtFilter e (e 1) x L :=
  e.to_continuous_linear_map₁.has_deriv_at_filter

protected theorem LinearMap.has_strict_deriv_at : HasStrictDerivAt e (e 1) x :=
  e.to_continuous_linear_map₁.has_strict_deriv_at

protected theorem LinearMap.has_deriv_at : HasDerivAt e (e 1) x :=
  e.has_deriv_at_filter

protected theorem LinearMap.has_deriv_within_at : HasDerivWithinAt e (e 1) s x :=
  e.has_deriv_at_filter

@[simp]
protected theorem LinearMap.deriv : deriv e x = e 1 :=
  e.has_deriv_at.deriv

protected theorem LinearMap.deriv_within (hxs : UniqueDiffWithinAt 𝕜 s x) : derivWithin e s x = e 1 :=
  e.has_deriv_within_at.deriv_within hxs

end LinearMap

section Add

/-! ### Derivative of the sum of two functions -/


theorem HasDerivAtFilter.add (hf : HasDerivAtFilter f f' x L) (hg : HasDerivAtFilter g g' x L) :
  HasDerivAtFilter (fun y => f y+g y) (f'+g') x L :=
  by 
    simpa using (hf.add hg).HasDerivAtFilter

theorem HasStrictDerivAt.add (hf : HasStrictDerivAt f f' x) (hg : HasStrictDerivAt g g' x) :
  HasStrictDerivAt (fun y => f y+g y) (f'+g') x :=
  by 
    simpa using (hf.add hg).HasStrictDerivAt

theorem HasDerivWithinAt.add (hf : HasDerivWithinAt f f' s x) (hg : HasDerivWithinAt g g' s x) :
  HasDerivWithinAt (fun y => f y+g y) (f'+g') s x :=
  hf.add hg

theorem HasDerivAt.add (hf : HasDerivAt f f' x) (hg : HasDerivAt g g' x) : HasDerivAt (fun x => f x+g x) (f'+g') x :=
  hf.add hg

theorem deriv_within_add (hxs : UniqueDiffWithinAt 𝕜 s x) (hf : DifferentiableWithinAt 𝕜 f s x)
  (hg : DifferentiableWithinAt 𝕜 g s x) : derivWithin (fun y => f y+g y) s x = derivWithin f s x+derivWithin g s x :=
  (hf.has_deriv_within_at.add hg.has_deriv_within_at).derivWithin hxs

@[simp]
theorem deriv_add (hf : DifferentiableAt 𝕜 f x) (hg : DifferentiableAt 𝕜 g x) :
  deriv (fun y => f y+g y) x = deriv f x+deriv g x :=
  (hf.has_deriv_at.add hg.has_deriv_at).deriv

theorem HasDerivAtFilter.add_const (hf : HasDerivAtFilter f f' x L) (c : F) :
  HasDerivAtFilter (fun y => f y+c) f' x L :=
  add_zeroₓ f' ▸ hf.add (has_deriv_at_filter_const x L c)

theorem HasDerivWithinAt.add_const (hf : HasDerivWithinAt f f' s x) (c : F) :
  HasDerivWithinAt (fun y => f y+c) f' s x :=
  hf.add_const c

theorem HasDerivAt.add_const (hf : HasDerivAt f f' x) (c : F) : HasDerivAt (fun x => f x+c) f' x :=
  hf.add_const c

theorem deriv_within_add_const (hxs : UniqueDiffWithinAt 𝕜 s x) (c : F) :
  derivWithin (fun y => f y+c) s x = derivWithin f s x :=
  by 
    simp only [derivWithin, fderiv_within_add_const hxs]

theorem deriv_add_const (c : F) : deriv (fun y => f y+c) x = deriv f x :=
  by 
    simp only [deriv, fderiv_add_const]

@[simp]
theorem deriv_add_const' (c : F) : (deriv fun y => f y+c) = deriv f :=
  funext$ fun x => deriv_add_const c

theorem HasDerivAtFilter.const_add (c : F) (hf : HasDerivAtFilter f f' x L) :
  HasDerivAtFilter (fun y => c+f y) f' x L :=
  zero_addₓ f' ▸ (has_deriv_at_filter_const x L c).add hf

theorem HasDerivWithinAt.const_add (c : F) (hf : HasDerivWithinAt f f' s x) :
  HasDerivWithinAt (fun y => c+f y) f' s x :=
  hf.const_add c

theorem HasDerivAt.const_add (c : F) (hf : HasDerivAt f f' x) : HasDerivAt (fun x => c+f x) f' x :=
  hf.const_add c

theorem deriv_within_const_add (hxs : UniqueDiffWithinAt 𝕜 s x) (c : F) :
  derivWithin (fun y => c+f y) s x = derivWithin f s x :=
  by 
    simp only [derivWithin, fderiv_within_const_add hxs]

theorem deriv_const_add (c : F) : deriv (fun y => c+f y) x = deriv f x :=
  by 
    simp only [deriv, fderiv_const_add]

@[simp]
theorem deriv_const_add' (c : F) : (deriv fun y => c+f y) = deriv f :=
  funext$ fun x => deriv_const_add c

end Add

section Sum

/-! ### Derivative of a finite sum of functions -/


open_locale BigOperators

variable{ι : Type _}{u : Finset ι}{A : ι → 𝕜 → F}{A' : ι → F}

theorem HasDerivAtFilter.sum (h : ∀ i (_ : i ∈ u), HasDerivAtFilter (A i) (A' i) x L) :
  HasDerivAtFilter (fun y => ∑i in u, A i y) (∑i in u, A' i) x L :=
  by 
    simpa [ContinuousLinearMap.sum_apply] using (HasFderivAtFilter.sum h).HasDerivAtFilter

theorem HasStrictDerivAt.sum (h : ∀ i (_ : i ∈ u), HasStrictDerivAt (A i) (A' i) x) :
  HasStrictDerivAt (fun y => ∑i in u, A i y) (∑i in u, A' i) x :=
  by 
    simpa [ContinuousLinearMap.sum_apply] using (HasStrictFderivAt.sum h).HasStrictDerivAt

theorem HasDerivWithinAt.sum (h : ∀ i (_ : i ∈ u), HasDerivWithinAt (A i) (A' i) s x) :
  HasDerivWithinAt (fun y => ∑i in u, A i y) (∑i in u, A' i) s x :=
  HasDerivAtFilter.sum h

theorem HasDerivAt.sum (h : ∀ i (_ : i ∈ u), HasDerivAt (A i) (A' i) x) :
  HasDerivAt (fun y => ∑i in u, A i y) (∑i in u, A' i) x :=
  HasDerivAtFilter.sum h

theorem deriv_within_sum (hxs : UniqueDiffWithinAt 𝕜 s x) (h : ∀ i (_ : i ∈ u), DifferentiableWithinAt 𝕜 (A i) s x) :
  derivWithin (fun y => ∑i in u, A i y) s x = ∑i in u, derivWithin (A i) s x :=
  (HasDerivWithinAt.sum fun i hi => (h i hi).HasDerivWithinAt).derivWithin hxs

@[simp]
theorem deriv_sum (h : ∀ i (_ : i ∈ u), DifferentiableAt 𝕜 (A i) x) :
  deriv (fun y => ∑i in u, A i y) x = ∑i in u, deriv (A i) x :=
  (HasDerivAt.sum fun i hi => (h i hi).HasDerivAt).deriv

end Sum

section Pi

/-! ### Derivatives of functions `f : 𝕜 → Π i, E i` -/


variable{ι :
    Type
      _}[Fintype
      ι]{E' : ι → Type _}[∀ i, NormedGroup (E' i)][∀ i, NormedSpace 𝕜 (E' i)]{φ : 𝕜 → ∀ i, E' i}{φ' : ∀ i, E' i}

@[simp]
theorem has_strict_deriv_at_pi : HasStrictDerivAt φ φ' x ↔ ∀ i, HasStrictDerivAt (fun x => φ x i) (φ' i) x :=
  has_strict_fderiv_at_pi'

@[simp]
theorem has_deriv_at_filter_pi : HasDerivAtFilter φ φ' x L ↔ ∀ i, HasDerivAtFilter (fun x => φ x i) (φ' i) x L :=
  has_fderiv_at_filter_pi'

theorem has_deriv_at_pi : HasDerivAt φ φ' x ↔ ∀ i, HasDerivAt (fun x => φ x i) (φ' i) x :=
  has_deriv_at_filter_pi

theorem has_deriv_within_at_pi : HasDerivWithinAt φ φ' s x ↔ ∀ i, HasDerivWithinAt (fun x => φ x i) (φ' i) s x :=
  has_deriv_at_filter_pi

theorem deriv_within_pi (h : ∀ i, DifferentiableWithinAt 𝕜 (fun x => φ x i) s x) (hs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin φ s x = fun i => derivWithin (fun x => φ x i) s x :=
  (has_deriv_within_at_pi.2 fun i => (h i).HasDerivWithinAt).derivWithin hs

theorem deriv_pi (h : ∀ i, DifferentiableAt 𝕜 (fun x => φ x i) x) : deriv φ x = fun i => deriv (fun x => φ x i) x :=
  (has_deriv_at_pi.2 fun i => (h i).HasDerivAt).deriv

end Pi

section Smul

/-! ### Derivative of the multiplication of a scalar function and a vector function -/


variable{𝕜' :
    Type _}[NondiscreteNormedField 𝕜'][NormedAlgebra 𝕜 𝕜'][NormedSpace 𝕜' F][IsScalarTower 𝕜 𝕜' F]{c : 𝕜 → 𝕜'}{c' : 𝕜'}

theorem HasDerivWithinAt.smul (hc : HasDerivWithinAt c c' s x) (hf : HasDerivWithinAt f f' s x) :
  HasDerivWithinAt (fun y => c y • f y) ((c x • f')+c' • f x) s x :=
  by 
    simpa using (HasFderivWithinAt.smul hc hf).HasDerivWithinAt

theorem HasDerivAt.smul (hc : HasDerivAt c c' x) (hf : HasDerivAt f f' x) :
  HasDerivAt (fun y => c y • f y) ((c x • f')+c' • f x) x :=
  by 
    rw [←has_deriv_within_at_univ] at *
    exact hc.smul hf

theorem HasStrictDerivAt.smul (hc : HasStrictDerivAt c c' x) (hf : HasStrictDerivAt f f' x) :
  HasStrictDerivAt (fun y => c y • f y) ((c x • f')+c' • f x) x :=
  by 
    simpa using (hc.smul hf).HasStrictDerivAt

theorem deriv_within_smul (hxs : UniqueDiffWithinAt 𝕜 s x) (hc : DifferentiableWithinAt 𝕜 c s x)
  (hf : DifferentiableWithinAt 𝕜 f s x) :
  derivWithin (fun y => c y • f y) s x = (c x • derivWithin f s x)+derivWithin c s x • f x :=
  (hc.has_deriv_within_at.smul hf.has_deriv_within_at).derivWithin hxs

theorem deriv_smul (hc : DifferentiableAt 𝕜 c x) (hf : DifferentiableAt 𝕜 f x) :
  deriv (fun y => c y • f y) x = (c x • deriv f x)+deriv c x • f x :=
  (hc.has_deriv_at.smul hf.has_deriv_at).deriv

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem has_deriv_within_at.smul_const
(hc : has_deriv_within_at c c' s x)
(f : F) : has_deriv_within_at (λ y, «expr • »(c y, f)) «expr • »(c', f) s x :=
begin
  have [] [] [":=", expr hc.smul (has_deriv_within_at_const x s f)],
  rwa ["[", expr smul_zero, ",", expr zero_add, "]"] ["at", ident this]
end

theorem HasDerivAt.smul_const (hc : HasDerivAt c c' x) (f : F) : HasDerivAt (fun y => c y • f) (c' • f) x :=
  by 
    rw [←has_deriv_within_at_univ] at *
    exact hc.smul_const f

theorem deriv_within_smul_const (hxs : UniqueDiffWithinAt 𝕜 s x) (hc : DifferentiableWithinAt 𝕜 c s x) (f : F) :
  derivWithin (fun y => c y • f) s x = derivWithin c s x • f :=
  (hc.has_deriv_within_at.smul_const f).derivWithin hxs

theorem deriv_smul_const (hc : DifferentiableAt 𝕜 c x) (f : F) : deriv (fun y => c y • f) x = deriv c x • f :=
  (hc.has_deriv_at.smul_const f).deriv

end Smul

section ConstSmul

variable{R : Type _}[Semiringₓ R][Module R F][TopologicalSpace R][SmulCommClass 𝕜 R F][HasContinuousSmul R F]

theorem HasStrictDerivAt.const_smul (c : R) (hf : HasStrictDerivAt f f' x) :
  HasStrictDerivAt (fun y => c • f y) (c • f') x :=
  by 
    simpa using (hf.const_smul c).HasStrictDerivAt

theorem HasDerivAtFilter.const_smul (c : R) (hf : HasDerivAtFilter f f' x L) :
  HasDerivAtFilter (fun y => c • f y) (c • f') x L :=
  by 
    simpa using (hf.const_smul c).HasDerivAtFilter

theorem HasDerivWithinAt.const_smul (c : R) (hf : HasDerivWithinAt f f' s x) :
  HasDerivWithinAt (fun y => c • f y) (c • f') s x :=
  hf.const_smul c

theorem HasDerivAt.const_smul (c : R) (hf : HasDerivAt f f' x) : HasDerivAt (fun y => c • f y) (c • f') x :=
  hf.const_smul c

theorem deriv_within_const_smul (hxs : UniqueDiffWithinAt 𝕜 s x) (c : R) (hf : DifferentiableWithinAt 𝕜 f s x) :
  derivWithin (fun y => c • f y) s x = c • derivWithin f s x :=
  (hf.has_deriv_within_at.const_smul c).derivWithin hxs

theorem deriv_const_smul (c : R) (hf : DifferentiableAt 𝕜 f x) : deriv (fun y => c • f y) x = c • deriv f x :=
  (hf.has_deriv_at.const_smul c).deriv

end ConstSmul

section Neg

/-! ### Derivative of the negative of a function -/


theorem HasDerivAtFilter.neg (h : HasDerivAtFilter f f' x L) : HasDerivAtFilter (fun x => -f x) (-f') x L :=
  by 
    simpa using h.neg.has_deriv_at_filter

theorem HasDerivWithinAt.neg (h : HasDerivWithinAt f f' s x) : HasDerivWithinAt (fun x => -f x) (-f') s x :=
  h.neg

theorem HasDerivAt.neg (h : HasDerivAt f f' x) : HasDerivAt (fun x => -f x) (-f') x :=
  h.neg

theorem HasStrictDerivAt.neg (h : HasStrictDerivAt f f' x) : HasStrictDerivAt (fun x => -f x) (-f') x :=
  by 
    simpa using h.neg.has_strict_deriv_at

theorem derivWithin.neg (hxs : UniqueDiffWithinAt 𝕜 s x) : derivWithin (fun y => -f y) s x = -derivWithin f s x :=
  by 
    simp only [derivWithin, fderiv_within_neg hxs, ContinuousLinearMap.neg_apply]

theorem deriv.neg : deriv (fun y => -f y) x = -deriv f x :=
  by 
    simp only [deriv, fderiv_neg, ContinuousLinearMap.neg_apply]

@[simp]
theorem deriv.neg' : (deriv fun y => -f y) = fun x => -deriv f x :=
  funext$ fun x => deriv.neg

end Neg

section Neg2

/-! ### Derivative of the negation function (i.e `has_neg.neg`) -/


variable(s x L)

theorem has_deriv_at_filter_neg : HasDerivAtFilter Neg.neg (-1) x L :=
  HasDerivAtFilter.neg$ has_deriv_at_filter_id _ _

theorem has_deriv_within_at_neg : HasDerivWithinAt Neg.neg (-1) s x :=
  has_deriv_at_filter_neg _ _

theorem has_deriv_at_neg : HasDerivAt Neg.neg (-1) x :=
  has_deriv_at_filter_neg _ _

theorem has_deriv_at_neg' : HasDerivAt (fun x => -x) (-1) x :=
  has_deriv_at_filter_neg _ _

theorem has_strict_deriv_at_neg : HasStrictDerivAt Neg.neg (-1) x :=
  HasStrictDerivAt.neg$ has_strict_deriv_at_id _

theorem deriv_neg : deriv Neg.neg x = -1 :=
  HasDerivAt.deriv (has_deriv_at_neg x)

@[simp]
theorem deriv_neg' : deriv (Neg.neg : 𝕜 → 𝕜) = fun _ => -1 :=
  funext deriv_neg

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp] theorem deriv_neg'' : «expr = »(deriv (λ x : 𝕜, «expr- »(x)) x, «expr- »(1)) := deriv_neg x

theorem deriv_within_neg (hxs : UniqueDiffWithinAt 𝕜 s x) : derivWithin Neg.neg s x = -1 :=
  (has_deriv_within_at_neg x s).derivWithin hxs

theorem differentiable_neg : Differentiable 𝕜 (Neg.neg : 𝕜 → 𝕜) :=
  Differentiable.neg differentiable_id

theorem differentiable_on_neg : DifferentiableOn 𝕜 (Neg.neg : 𝕜 → 𝕜) s :=
  DifferentiableOn.neg differentiable_on_id

end Neg2

section Sub

/-! ### Derivative of the difference of two functions -/


theorem HasDerivAtFilter.sub (hf : HasDerivAtFilter f f' x L) (hg : HasDerivAtFilter g g' x L) :
  HasDerivAtFilter (fun x => f x - g x) (f' - g') x L :=
  by 
    simpa only [sub_eq_add_neg] using hf.add hg.neg

theorem HasDerivWithinAt.sub (hf : HasDerivWithinAt f f' s x) (hg : HasDerivWithinAt g g' s x) :
  HasDerivWithinAt (fun x => f x - g x) (f' - g') s x :=
  hf.sub hg

theorem HasDerivAt.sub (hf : HasDerivAt f f' x) (hg : HasDerivAt g g' x) :
  HasDerivAt (fun x => f x - g x) (f' - g') x :=
  hf.sub hg

theorem HasStrictDerivAt.sub (hf : HasStrictDerivAt f f' x) (hg : HasStrictDerivAt g g' x) :
  HasStrictDerivAt (fun x => f x - g x) (f' - g') x :=
  by 
    simpa only [sub_eq_add_neg] using hf.add hg.neg

theorem deriv_within_sub (hxs : UniqueDiffWithinAt 𝕜 s x) (hf : DifferentiableWithinAt 𝕜 f s x)
  (hg : DifferentiableWithinAt 𝕜 g s x) :
  derivWithin (fun y => f y - g y) s x = derivWithin f s x - derivWithin g s x :=
  (hf.has_deriv_within_at.sub hg.has_deriv_within_at).derivWithin hxs

@[simp]
theorem deriv_sub (hf : DifferentiableAt 𝕜 f x) (hg : DifferentiableAt 𝕜 g x) :
  deriv (fun y => f y - g y) x = deriv f x - deriv g x :=
  (hf.has_deriv_at.sub hg.has_deriv_at).deriv

theorem HasDerivAtFilter.is_O_sub (h : HasDerivAtFilter f f' x L) : is_O (fun x' => f x' - f x) (fun x' => x' - x) L :=
  HasFderivAtFilter.is_O_sub h

theorem HasDerivAtFilter.sub_const (hf : HasDerivAtFilter f f' x L) (c : F) :
  HasDerivAtFilter (fun x => f x - c) f' x L :=
  by 
    simpa only [sub_eq_add_neg] using hf.add_const (-c)

theorem HasDerivWithinAt.sub_const (hf : HasDerivWithinAt f f' s x) (c : F) :
  HasDerivWithinAt (fun x => f x - c) f' s x :=
  hf.sub_const c

theorem HasDerivAt.sub_const (hf : HasDerivAt f f' x) (c : F) : HasDerivAt (fun x => f x - c) f' x :=
  hf.sub_const c

theorem deriv_within_sub_const (hxs : UniqueDiffWithinAt 𝕜 s x) (c : F) :
  derivWithin (fun y => f y - c) s x = derivWithin f s x :=
  by 
    simp only [derivWithin, fderiv_within_sub_const hxs]

theorem deriv_sub_const (c : F) : deriv (fun y => f y - c) x = deriv f x :=
  by 
    simp only [deriv, fderiv_sub_const]

theorem HasDerivAtFilter.const_sub (c : F) (hf : HasDerivAtFilter f f' x L) :
  HasDerivAtFilter (fun x => c - f x) (-f') x L :=
  by 
    simpa only [sub_eq_add_neg] using hf.neg.const_add c

theorem HasDerivWithinAt.const_sub (c : F) (hf : HasDerivWithinAt f f' s x) :
  HasDerivWithinAt (fun x => c - f x) (-f') s x :=
  hf.const_sub c

theorem HasStrictDerivAt.const_sub (c : F) (hf : HasStrictDerivAt f f' x) :
  HasStrictDerivAt (fun x => c - f x) (-f') x :=
  by 
    simpa only [sub_eq_add_neg] using hf.neg.const_add c

theorem HasDerivAt.const_sub (c : F) (hf : HasDerivAt f f' x) : HasDerivAt (fun x => c - f x) (-f') x :=
  hf.const_sub c

theorem deriv_within_const_sub (hxs : UniqueDiffWithinAt 𝕜 s x) (c : F) :
  derivWithin (fun y => c - f y) s x = -derivWithin f s x :=
  by 
    simp [derivWithin, fderiv_within_const_sub hxs]

theorem deriv_const_sub (c : F) : deriv (fun y => c - f y) x = -deriv f x :=
  by 
    simp only [←deriv_within_univ, deriv_within_const_sub unique_diff_within_at_univ]

end Sub

section Continuous

/-! ### Continuity of a function admitting a derivative -/


theorem HasDerivAtFilter.tendsto_nhds (hL : L ≤ 𝓝 x) (h : HasDerivAtFilter f f' x L) : tendsto f L (𝓝 (f x)) :=
  h.tendsto_nhds hL

theorem HasDerivWithinAt.continuous_within_at (h : HasDerivWithinAt f f' s x) : ContinuousWithinAt f s x :=
  HasDerivAtFilter.tendsto_nhds inf_le_left h

theorem HasDerivAt.continuous_at (h : HasDerivAt f f' x) : ContinuousAt f x :=
  HasDerivAtFilter.tendsto_nhds (le_reflₓ _) h

protected theorem HasDerivAt.continuous_on {f f' : 𝕜 → F} (hderiv : ∀ x (_ : x ∈ s), HasDerivAt f (f' x) x) :
  ContinuousOn f s :=
  fun x hx => (hderiv x hx).ContinuousAt.ContinuousWithinAt

end Continuous

section CartesianProduct

/-! ### Derivative of the cartesian product of two functions -/


variable{G : Type w}[NormedGroup G][NormedSpace 𝕜 G]

variable{f₂ : 𝕜 → G}{f₂' : G}

theorem HasDerivAtFilter.prod (hf₁ : HasDerivAtFilter f₁ f₁' x L) (hf₂ : HasDerivAtFilter f₂ f₂' x L) :
  HasDerivAtFilter (fun x => (f₁ x, f₂ x)) (f₁', f₂') x L :=
  hf₁.prod hf₂

theorem HasDerivWithinAt.prod (hf₁ : HasDerivWithinAt f₁ f₁' s x) (hf₂ : HasDerivWithinAt f₂ f₂' s x) :
  HasDerivWithinAt (fun x => (f₁ x, f₂ x)) (f₁', f₂') s x :=
  hf₁.prod hf₂

theorem HasDerivAt.prod (hf₁ : HasDerivAt f₁ f₁' x) (hf₂ : HasDerivAt f₂ f₂' x) :
  HasDerivAt (fun x => (f₁ x, f₂ x)) (f₁', f₂') x :=
  hf₁.prod hf₂

theorem HasStrictDerivAt.prod (hf₁ : HasStrictDerivAt f₁ f₁' x) (hf₂ : HasStrictDerivAt f₂ f₂' x) :
  HasStrictDerivAt (fun x => (f₁ x, f₂ x)) (f₁', f₂') x :=
  hf₁.prod hf₂

end CartesianProduct

section Composition

/-!
### Derivative of the composition of a vector function and a scalar function

We use `scomp` in lemmas on composition of vector valued and scalar valued functions, and `comp`
in lemmas on composition of scalar valued functions, in analogy for `smul` and `mul` (and also
because the `comp` version with the shorter name will show up much more often in applications).
The formula for the derivative involves `smul` in `scomp` lemmas, which can be reduced to
usual multiplication in `comp` lemmas.
-/


variable{h h₁ h₂ : 𝕜 → 𝕜}{h' h₁' h₂' : 𝕜}

variable(x)

theorem HasDerivAtFilter.scomp (hg : HasDerivAtFilter g g' (h x) (L.map h)) (hh : HasDerivAtFilter h h' x L) :
  HasDerivAtFilter (g ∘ h) (h' • g') x L :=
  by 
    simpa using (hg.comp x hh).HasDerivAtFilter

theorem HasDerivWithinAt.scomp {t : Set 𝕜} (hg : HasDerivWithinAt g g' t (h x)) (hh : HasDerivWithinAt h h' s x)
  (hst : s ⊆ h ⁻¹' t) : HasDerivWithinAt (g ∘ h) (h' • g') s x :=
  HasDerivAtFilter.scomp _ (HasDerivAtFilter.mono hg$ hh.continuous_within_at.tendsto_nhds_within hst) hh

/-- The chain rule. -/
theorem HasDerivAt.scomp (hg : HasDerivAt g g' (h x)) (hh : HasDerivAt h h' x) : HasDerivAt (g ∘ h) (h' • g') x :=
  (hg.mono hh.continuous_at).scomp x hh

theorem HasStrictDerivAt.scomp (hg : HasStrictDerivAt g g' (h x)) (hh : HasStrictDerivAt h h' x) :
  HasStrictDerivAt (g ∘ h) (h' • g') x :=
  by 
    simpa using (hg.comp x hh).HasStrictDerivAt

theorem HasDerivAt.scomp_has_deriv_within_at (hg : HasDerivAt g g' (h x)) (hh : HasDerivWithinAt h h' s x) :
  HasDerivWithinAt (g ∘ h) (h' • g') s x :=
  by 
    rw [←has_deriv_within_at_univ] at hg 
    exact HasDerivWithinAt.scomp x hg hh subset_preimage_univ

theorem derivWithin.scomp (hg : DifferentiableWithinAt 𝕜 g t (h x)) (hh : DifferentiableWithinAt 𝕜 h s x)
  (hs : s ⊆ h ⁻¹' t) (hxs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin (g ∘ h) s x = derivWithin h s x • derivWithin g t (h x) :=
  by 
    apply HasDerivWithinAt.deriv_within _ hxs 
    exact HasDerivWithinAt.scomp x hg.has_deriv_within_at hh.has_deriv_within_at hs

theorem deriv.scomp (hg : DifferentiableAt 𝕜 g (h x)) (hh : DifferentiableAt 𝕜 h x) :
  deriv (g ∘ h) x = deriv h x • deriv g (h x) :=
  by 
    apply HasDerivAt.deriv 
    exact HasDerivAt.scomp x hg.has_deriv_at hh.has_deriv_at

/-! ### Derivative of the composition of a scalar and vector functions -/


theorem HasDerivAtFilter.comp_has_fderiv_at_filter {f : E → 𝕜} {f' : E →L[𝕜] 𝕜} x {L : Filter E}
  (hh₁ : HasDerivAtFilter h₁ h₁' (f x) (L.map f)) (hf : HasFderivAtFilter f f' x L) :
  HasFderivAtFilter (h₁ ∘ f) (h₁' • f') x L :=
  by 
    convert HasFderivAtFilter.comp x hh₁ hf 
    ext x 
    simp [mul_commₓ]

theorem HasStrictDerivAt.comp_has_strict_fderiv_at {f : E → 𝕜} {f' : E →L[𝕜] 𝕜} x (hh₁ : HasStrictDerivAt h₁ h₁' (f x))
  (hf : HasStrictFderivAt f f' x) : HasStrictFderivAt (h₁ ∘ f) (h₁' • f') x :=
  by 
    rw [HasStrictDerivAt] at hh₁ 
    convert hh₁.comp x hf 
    ext x 
    simp [mul_commₓ]

theorem HasDerivAt.comp_has_fderiv_at {f : E → 𝕜} {f' : E →L[𝕜] 𝕜} x (hh₁ : HasDerivAt h₁ h₁' (f x))
  (hf : HasFderivAt f f' x) : HasFderivAt (h₁ ∘ f) (h₁' • f') x :=
  (hh₁.mono hf.continuous_at).comp_has_fderiv_at_filter x hf

theorem HasDerivAt.comp_has_fderiv_within_at {f : E → 𝕜} {f' : E →L[𝕜] 𝕜} {s} x (hh₁ : HasDerivAt h₁ h₁' (f x))
  (hf : HasFderivWithinAt f f' s x) : HasFderivWithinAt (h₁ ∘ f) (h₁' • f') s x :=
  (hh₁.mono hf.continuous_within_at).comp_has_fderiv_at_filter x hf

theorem HasDerivWithinAt.comp_has_fderiv_within_at {f : E → 𝕜} {f' : E →L[𝕜] 𝕜} {s t} x
  (hh₁ : HasDerivWithinAt h₁ h₁' t (f x)) (hf : HasFderivWithinAt f f' s x) (hst : maps_to f s t) :
  HasFderivWithinAt (h₁ ∘ f) (h₁' • f') s x :=
  (HasDerivAtFilter.mono hh₁$ hf.continuous_within_at.tendsto_nhds_within hst).comp_has_fderiv_at_filter x hf

/-! ### Derivative of the composition of two scalar functions -/


theorem HasDerivAtFilter.comp (hh₁ : HasDerivAtFilter h₁ h₁' (h₂ x) (L.map h₂)) (hh₂ : HasDerivAtFilter h₂ h₂' x L) :
  HasDerivAtFilter (h₁ ∘ h₂) (h₁'*h₂') x L :=
  by 
    rw [mul_commₓ]
    exact hh₁.scomp x hh₂

theorem HasDerivWithinAt.comp {t : Set 𝕜} (hh₁ : HasDerivWithinAt h₁ h₁' t (h₂ x)) (hh₂ : HasDerivWithinAt h₂ h₂' s x)
  (hst : s ⊆ h₂ ⁻¹' t) : HasDerivWithinAt (h₁ ∘ h₂) (h₁'*h₂') s x :=
  by 
    rw [mul_commₓ]
    exact hh₁.scomp x hh₂ hst

/-- The chain rule. -/
theorem HasDerivAt.comp (hh₁ : HasDerivAt h₁ h₁' (h₂ x)) (hh₂ : HasDerivAt h₂ h₂' x) :
  HasDerivAt (h₁ ∘ h₂) (h₁'*h₂') x :=
  (hh₁.mono hh₂.continuous_at).comp x hh₂

theorem HasStrictDerivAt.comp (hh₁ : HasStrictDerivAt h₁ h₁' (h₂ x)) (hh₂ : HasStrictDerivAt h₂ h₂' x) :
  HasStrictDerivAt (h₁ ∘ h₂) (h₁'*h₂') x :=
  by 
    rw [mul_commₓ]
    exact hh₁.scomp x hh₂

theorem HasDerivAt.comp_has_deriv_within_at (hh₁ : HasDerivAt h₁ h₁' (h₂ x)) (hh₂ : HasDerivWithinAt h₂ h₂' s x) :
  HasDerivWithinAt (h₁ ∘ h₂) (h₁'*h₂') s x :=
  by 
    rw [←has_deriv_within_at_univ] at hh₁ 
    exact HasDerivWithinAt.comp x hh₁ hh₂ subset_preimage_univ

theorem derivWithin.comp (hh₁ : DifferentiableWithinAt 𝕜 h₁ t (h₂ x)) (hh₂ : DifferentiableWithinAt 𝕜 h₂ s x)
  (hs : s ⊆ h₂ ⁻¹' t) (hxs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin (h₁ ∘ h₂) s x = derivWithin h₁ t (h₂ x)*derivWithin h₂ s x :=
  by 
    apply HasDerivWithinAt.deriv_within _ hxs 
    exact HasDerivWithinAt.comp x hh₁.has_deriv_within_at hh₂.has_deriv_within_at hs

theorem deriv.comp (hh₁ : DifferentiableAt 𝕜 h₁ (h₂ x)) (hh₂ : DifferentiableAt 𝕜 h₂ x) :
  deriv (h₁ ∘ h₂) x = deriv h₁ (h₂ x)*deriv h₂ x :=
  by 
    apply HasDerivAt.deriv 
    exact HasDerivAt.comp x hh₁.has_deriv_at hh₂.has_deriv_at

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
protected
theorem has_deriv_at_filter.iterate
{f : 𝕜 → 𝕜}
{f' : 𝕜}
(hf : has_deriv_at_filter f f' x L)
(hL : tendsto f L L)
(hx : «expr = »(f x, x))
(n : exprℕ()) : has_deriv_at_filter «expr ^[ ]»(f, n) «expr ^ »(f', n) x L :=
begin
  have [] [] [":=", expr hf.iterate hL hx n],
  rwa ["[", expr continuous_linear_map.smul_right_one_pow, "]"] ["at", ident this]
end

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
protected
theorem has_deriv_at.iterate
{f : 𝕜 → 𝕜}
{f' : 𝕜}
(hf : has_deriv_at f f' x)
(hx : «expr = »(f x, x))
(n : exprℕ()) : has_deriv_at «expr ^[ ]»(f, n) «expr ^ »(f', n) x :=
begin
  have [] [] [":=", expr has_fderiv_at.iterate hf hx n],
  rwa ["[", expr continuous_linear_map.smul_right_one_pow, "]"] ["at", ident this]
end

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
protected
theorem has_deriv_within_at.iterate
{f : 𝕜 → 𝕜}
{f' : 𝕜}
(hf : has_deriv_within_at f f' s x)
(hx : «expr = »(f x, x))
(hs : maps_to f s s)
(n : exprℕ()) : has_deriv_within_at «expr ^[ ]»(f, n) «expr ^ »(f', n) s x :=
begin
  have [] [] [":=", expr has_fderiv_within_at.iterate hf hx hs n],
  rwa ["[", expr continuous_linear_map.smul_right_one_pow, "]"] ["at", ident this]
end

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
protected
theorem has_strict_deriv_at.iterate
{f : 𝕜 → 𝕜}
{f' : 𝕜}
(hf : has_strict_deriv_at f f' x)
(hx : «expr = »(f x, x))
(n : exprℕ()) : has_strict_deriv_at «expr ^[ ]»(f, n) «expr ^ »(f', n) x :=
begin
  have [] [] [":=", expr hf.iterate hx n],
  rwa ["[", expr continuous_linear_map.smul_right_one_pow, "]"] ["at", ident this]
end

end Composition

section CompositionVector

/-! ### Derivative of the composition of a function between vector spaces and a function on `𝕜` -/


open ContinuousLinearMap

variable{l : F → E}{l' : F →L[𝕜] E}

variable(x)

/-- The composition `l ∘ f` where `l : F → E` and `f : 𝕜 → F`, has a derivative within a set
equal to the Fréchet derivative of `l` applied to the derivative of `f`. -/
theorem HasFderivWithinAt.comp_has_deriv_within_at {t : Set F} (hl : HasFderivWithinAt l l' t (f x))
  (hf : HasDerivWithinAt f f' s x) (hst : maps_to f s t) : HasDerivWithinAt (l ∘ f) (l' f') s x :=
  by 
    simpa only [one_apply, one_smul, smul_right_apply, coe_comp', · ∘ ·] using
      (hl.comp x hf.has_fderiv_within_at hst).HasDerivWithinAt

theorem HasFderivAt.comp_has_deriv_within_at (hl : HasFderivAt l l' (f x)) (hf : HasDerivWithinAt f f' s x) :
  HasDerivWithinAt (l ∘ f) (l' f') s x :=
  hl.has_fderiv_within_at.comp_has_deriv_within_at x hf (maps_to_univ _ _)

/-- The composition `l ∘ f` where `l : F → E` and `f : 𝕜 → F`, has a derivative equal to the
Fréchet derivative of `l` applied to the derivative of `f`. -/
theorem HasFderivAt.comp_has_deriv_at (hl : HasFderivAt l l' (f x)) (hf : HasDerivAt f f' x) :
  HasDerivAt (l ∘ f) (l' f') x :=
  has_deriv_within_at_univ.mp$ hl.comp_has_deriv_within_at x hf.has_deriv_within_at

theorem HasStrictFderivAt.comp_has_strict_deriv_at (hl : HasStrictFderivAt l l' (f x)) (hf : HasStrictDerivAt f f' x) :
  HasStrictDerivAt (l ∘ f) (l' f') x :=
  by 
    simpa only [one_apply, one_smul, smul_right_apply, coe_comp', · ∘ ·] using
      (hl.comp x hf.has_strict_fderiv_at).HasStrictDerivAt

theorem fderivWithin.comp_deriv_within {t : Set F} (hl : DifferentiableWithinAt 𝕜 l t (f x))
  (hf : DifferentiableWithinAt 𝕜 f s x) (hs : maps_to f s t) (hxs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin (l ∘ f) s x = (fderivWithin 𝕜 l t (f x) : F → E) (derivWithin f s x) :=
  (hl.has_fderiv_within_at.comp_has_deriv_within_at x hf.has_deriv_within_at hs).derivWithin hxs

theorem fderiv.comp_deriv (hl : DifferentiableAt 𝕜 l (f x)) (hf : DifferentiableAt 𝕜 f x) :
  deriv (l ∘ f) x = (fderiv 𝕜 l (f x) : F → E) (deriv f x) :=
  (hl.has_fderiv_at.comp_has_deriv_at x hf.has_deriv_at).deriv

end CompositionVector

section Mul

/-! ### Derivative of the multiplication of two functions -/


variable{𝕜' 𝔸 :
    Type _}[NormedField 𝕜'][NormedRing 𝔸][NormedAlgebra 𝕜 𝕜'][NormedAlgebra 𝕜 𝔸]{c d : 𝕜 → 𝔸}{c' d' : 𝔸}{u v : 𝕜 → 𝕜'}

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem has_deriv_within_at.mul
(hc : has_deriv_within_at c c' s x)
(hd : has_deriv_within_at d d' s x) : has_deriv_within_at (λ
 y, «expr * »(c y, d y)) «expr + »(«expr * »(c', d x), «expr * »(c x, d')) s x :=
begin
  have [] [] [":=", expr (has_fderiv_within_at.mul' hc hd).has_deriv_within_at],
  rwa ["[", expr continuous_linear_map.add_apply, ",", expr continuous_linear_map.smul_apply, ",", expr continuous_linear_map.smul_right_apply, ",", expr continuous_linear_map.smul_right_apply, ",", expr continuous_linear_map.smul_right_apply, ",", expr continuous_linear_map.one_apply, ",", expr one_smul, ",", expr one_smul, ",", expr add_comm, "]"] ["at", ident this]
end

theorem HasDerivAt.mul (hc : HasDerivAt c c' x) (hd : HasDerivAt d d' x) :
  HasDerivAt (fun y => c y*d y) ((c'*d x)+c x*d') x :=
  by 
    rw [←has_deriv_within_at_univ] at *
    exact hc.mul hd

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem has_strict_deriv_at.mul
(hc : has_strict_deriv_at c c' x)
(hd : has_strict_deriv_at d d' x) : has_strict_deriv_at (λ
 y, «expr * »(c y, d y)) «expr + »(«expr * »(c', d x), «expr * »(c x, d')) x :=
begin
  have [] [] [":=", expr (has_strict_fderiv_at.mul' hc hd).has_strict_deriv_at],
  rwa ["[", expr continuous_linear_map.add_apply, ",", expr continuous_linear_map.smul_apply, ",", expr continuous_linear_map.smul_right_apply, ",", expr continuous_linear_map.smul_right_apply, ",", expr continuous_linear_map.smul_right_apply, ",", expr continuous_linear_map.one_apply, ",", expr one_smul, ",", expr one_smul, ",", expr add_comm, "]"] ["at", ident this]
end

theorem deriv_within_mul (hxs : UniqueDiffWithinAt 𝕜 s x) (hc : DifferentiableWithinAt 𝕜 c s x)
  (hd : DifferentiableWithinAt 𝕜 d s x) :
  derivWithin (fun y => c y*d y) s x = (derivWithin c s x*d x)+c x*derivWithin d s x :=
  (hc.has_deriv_within_at.mul hd.has_deriv_within_at).derivWithin hxs

@[simp]
theorem deriv_mul (hc : DifferentiableAt 𝕜 c x) (hd : DifferentiableAt 𝕜 d x) :
  deriv (fun y => c y*d y) x = (deriv c x*d x)+c x*deriv d x :=
  (hc.has_deriv_at.mul hd.has_deriv_at).deriv

theorem HasDerivWithinAt.mul_const (hc : HasDerivWithinAt c c' s x) (d : 𝔸) :
  HasDerivWithinAt (fun y => c y*d) (c'*d) s x :=
  by 
    convert hc.mul (has_deriv_within_at_const x s d)
    rw [mul_zero, add_zeroₓ]

theorem HasDerivAt.mul_const (hc : HasDerivAt c c' x) (d : 𝔸) : HasDerivAt (fun y => c y*d) (c'*d) x :=
  by 
    rw [←has_deriv_within_at_univ] at *
    exact hc.mul_const d

theorem has_deriv_at_mul_const (c : 𝕜) : HasDerivAt (fun x => x*c) c x :=
  by 
    simpa only [one_mulₓ] using (has_deriv_at_id' x).mul_const c

theorem HasStrictDerivAt.mul_const (hc : HasStrictDerivAt c c' x) (d : 𝔸) :
  HasStrictDerivAt (fun y => c y*d) (c'*d) x :=
  by 
    convert hc.mul (has_strict_deriv_at_const x d)
    rw [mul_zero, add_zeroₓ]

theorem deriv_within_mul_const (hxs : UniqueDiffWithinAt 𝕜 s x) (hc : DifferentiableWithinAt 𝕜 c s x) (d : 𝔸) :
  derivWithin (fun y => c y*d) s x = derivWithin c s x*d :=
  (hc.has_deriv_within_at.mul_const d).derivWithin hxs

theorem deriv_mul_const (hc : DifferentiableAt 𝕜 c x) (d : 𝔸) : deriv (fun y => c y*d) x = deriv c x*d :=
  (hc.has_deriv_at.mul_const d).deriv

theorem deriv_mul_const_field (v : 𝕜') : deriv (fun y => u y*v) x = deriv u x*v :=
  by 
    byCases' hu : DifferentiableAt 𝕜 u x
    ·
      exact deriv_mul_const hu v
    ·
      rw [deriv_zero_of_not_differentiable_at hu, zero_mul]
      rcases eq_or_ne v 0 with (rfl | hd)
      ·
        simp only [mul_zero, deriv_const]
      ·
        refine' deriv_zero_of_not_differentiable_at (mt (fun H => _) hu)
        simpa only [mul_inv_cancel_right₀ hd] using H.mul_const (v⁻¹)

@[simp]
theorem deriv_mul_const_field' (v : 𝕜') : (deriv fun x => u x*v) = fun x => deriv u x*v :=
  funext$ fun _ => deriv_mul_const_field v

theorem HasDerivWithinAt.const_mul (c : 𝔸) (hd : HasDerivWithinAt d d' s x) :
  HasDerivWithinAt (fun y => c*d y) (c*d') s x :=
  by 
    convert (has_deriv_within_at_const x s c).mul hd 
    rw [zero_mul, zero_addₓ]

theorem HasDerivAt.const_mul (c : 𝔸) (hd : HasDerivAt d d' x) : HasDerivAt (fun y => c*d y) (c*d') x :=
  by 
    rw [←has_deriv_within_at_univ] at *
    exact hd.const_mul c

theorem HasStrictDerivAt.const_mul (c : 𝔸) (hd : HasStrictDerivAt d d' x) :
  HasStrictDerivAt (fun y => c*d y) (c*d') x :=
  by 
    convert (has_strict_deriv_at_const _ _).mul hd 
    rw [zero_mul, zero_addₓ]

theorem deriv_within_const_mul (hxs : UniqueDiffWithinAt 𝕜 s x) (c : 𝔸) (hd : DifferentiableWithinAt 𝕜 d s x) :
  derivWithin (fun y => c*d y) s x = c*derivWithin d s x :=
  (hd.has_deriv_within_at.const_mul c).derivWithin hxs

theorem deriv_const_mul (c : 𝔸) (hd : DifferentiableAt 𝕜 d x) : deriv (fun y => c*d y) x = c*deriv d x :=
  (hd.has_deriv_at.const_mul c).deriv

theorem deriv_const_mul_field (u : 𝕜') : deriv (fun y => u*v y) x = u*deriv v x :=
  by 
    simp only [mul_commₓ u, deriv_mul_const_field]

@[simp]
theorem deriv_const_mul_field' (u : 𝕜') : (deriv fun x => u*v x) = fun x => u*deriv v x :=
  funext fun x => deriv_const_mul_field u

end Mul

section Inverse

/-! ### Derivative of `x ↦ x⁻¹` -/


-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem has_strict_deriv_at_inv
(hx : «expr ≠ »(x, 0)) : has_strict_deriv_at has_inv.inv «expr- »(«expr ⁻¹»(«expr ^ »(x, 2))) x :=
begin
  suffices [] [":", expr is_o (λ
    p : «expr × »(𝕜, 𝕜), «expr * »(«expr - »(p.1, p.2), «expr - »(«expr ⁻¹»(«expr * »(x, x)), «expr ⁻¹»(«expr * »(p.1, p.2))))) (λ
    p : «expr × »(𝕜, 𝕜), «expr * »(«expr - »(p.1, p.2), 1)) (expr𝓝() (x, x))],
  { refine [expr this.congr' _ «expr $ »(eventually_of_forall, λ _, mul_one _)],
    refine [expr eventually.mono (is_open.mem_nhds (is_open_ne.prod is_open_ne) ⟨hx, hx⟩) _],
    rintro ["⟨", ident y, ",", ident z, "⟩", "⟨", ident hy, ",", ident hz, "⟩"],
    simp [] [] ["only"] ["[", expr mem_set_of_eq, "]"] [] ["at", ident hy, ident hz],
    field_simp [] ["[", expr hx, ",", expr hy, ",", expr hz, "]"] [] [],
    ring [] },
  refine [expr (is_O_refl (λ p : «expr × »(𝕜, 𝕜), «expr - »(p.1, p.2)) _).mul_is_o ((is_o_one_iff _).2 _)],
  rw ["[", "<-", expr sub_self «expr ⁻¹»(«expr * »(x, x)), "]"] [],
  exact [expr tendsto_const_nhds.sub «expr $ »((continuous_mul.tendsto (x, x)).inv₀, mul_ne_zero hx hx)]
end

theorem has_deriv_at_inv (x_ne_zero : x ≠ 0) : HasDerivAt (fun y => y⁻¹) (-(x ^ 2)⁻¹) x :=
  (has_strict_deriv_at_inv x_ne_zero).HasDerivAt

theorem has_deriv_within_at_inv (x_ne_zero : x ≠ 0) (s : Set 𝕜) : HasDerivWithinAt (fun x => x⁻¹) (-(x ^ 2)⁻¹) s x :=
  (has_deriv_at_inv x_ne_zero).HasDerivWithinAt

theorem differentiable_at_inv : DifferentiableAt 𝕜 (fun x => x⁻¹) x ↔ x ≠ 0 :=
  ⟨fun H => NormedField.continuous_at_inv.1 H.continuous_at, fun H => (has_deriv_at_inv H).DifferentiableAt⟩

theorem differentiable_within_at_inv (x_ne_zero : x ≠ 0) : DifferentiableWithinAt 𝕜 (fun x => x⁻¹) s x :=
  (differentiable_at_inv.2 x_ne_zero).DifferentiableWithinAt

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem differentiable_on_inv : differentiable_on 𝕜 (λ x : 𝕜, «expr ⁻¹»(x)) {x | «expr ≠ »(x, 0)} :=
λ x hx, differentiable_within_at_inv hx

theorem deriv_inv : deriv (fun x => x⁻¹) x = -(x ^ 2)⁻¹ :=
  by 
    rcases eq_or_ne x 0 with (rfl | hne)
    ·
      simp [deriv_zero_of_not_differentiable_at (mt differentiable_at_inv.1 (not_not.2 rfl))]
    ·
      exact (has_deriv_at_inv hne).deriv

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp] theorem deriv_inv' : «expr = »(deriv (λ x : 𝕜, «expr ⁻¹»(x)), λ x, «expr- »(«expr ⁻¹»(«expr ^ »(x, 2)))) :=
funext (λ x, deriv_inv)

theorem deriv_within_inv (x_ne_zero : x ≠ 0) (hxs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin (fun x => x⁻¹) s x = -(x ^ 2)⁻¹ :=
  by 
    rw [DifferentiableAt.deriv_within (differentiable_at_inv.2 x_ne_zero) hxs]
    exact deriv_inv

theorem has_fderiv_at_inv (x_ne_zero : x ≠ 0) :
  HasFderivAt (fun x => x⁻¹) (smul_right (1 : 𝕜 →L[𝕜] 𝕜) (-(x ^ 2)⁻¹) : 𝕜 →L[𝕜] 𝕜) x :=
  has_deriv_at_inv x_ne_zero

theorem has_fderiv_within_at_inv (x_ne_zero : x ≠ 0) :
  HasFderivWithinAt (fun x => x⁻¹) (smul_right (1 : 𝕜 →L[𝕜] 𝕜) (-(x ^ 2)⁻¹) : 𝕜 →L[𝕜] 𝕜) s x :=
  (has_fderiv_at_inv x_ne_zero).HasFderivWithinAt

theorem fderiv_inv : fderiv 𝕜 (fun x => x⁻¹) x = smul_right (1 : 𝕜 →L[𝕜] 𝕜) (-(x ^ 2)⁻¹) :=
  by 
    rw [←deriv_fderiv, deriv_inv]

theorem fderiv_within_inv (x_ne_zero : x ≠ 0) (hxs : UniqueDiffWithinAt 𝕜 s x) :
  fderivWithin 𝕜 (fun x => x⁻¹) s x = smul_right (1 : 𝕜 →L[𝕜] 𝕜) (-(x ^ 2)⁻¹) :=
  by 
    rw [DifferentiableAt.fderiv_within (differentiable_at_inv.2 x_ne_zero) hxs]
    exact fderiv_inv

variable{c : 𝕜 → 𝕜}{c' : 𝕜}

theorem HasDerivWithinAt.inv (hc : HasDerivWithinAt c c' s x) (hx : c x ≠ 0) :
  HasDerivWithinAt (fun y => c y⁻¹) (-c' / c x ^ 2) s x :=
  by 
    convert (has_deriv_at_inv hx).comp_has_deriv_within_at x hc 
    fieldSimp

theorem HasDerivAt.inv (hc : HasDerivAt c c' x) (hx : c x ≠ 0) : HasDerivAt (fun y => c y⁻¹) (-c' / c x ^ 2) x :=
  by 
    rw [←has_deriv_within_at_univ] at *
    exact hc.inv hx

theorem DifferentiableWithinAt.inv (hc : DifferentiableWithinAt 𝕜 c s x) (hx : c x ≠ 0) :
  DifferentiableWithinAt 𝕜 (fun x => c x⁻¹) s x :=
  (hc.has_deriv_within_at.inv hx).DifferentiableWithinAt

@[simp]
theorem DifferentiableAt.inv (hc : DifferentiableAt 𝕜 c x) (hx : c x ≠ 0) : DifferentiableAt 𝕜 (fun x => c x⁻¹) x :=
  (hc.has_deriv_at.inv hx).DifferentiableAt

theorem DifferentiableOn.inv (hc : DifferentiableOn 𝕜 c s) (hx : ∀ x (_ : x ∈ s), c x ≠ 0) :
  DifferentiableOn 𝕜 (fun x => c x⁻¹) s :=
  fun x h => (hc x h).inv (hx x h)

@[simp]
theorem Differentiable.inv (hc : Differentiable 𝕜 c) (hx : ∀ x, c x ≠ 0) : Differentiable 𝕜 fun x => c x⁻¹ :=
  fun x => (hc x).inv (hx x)

theorem deriv_within_inv' (hc : DifferentiableWithinAt 𝕜 c s x) (hx : c x ≠ 0) (hxs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin (fun x => c x⁻¹) s x = -derivWithin c s x / c x ^ 2 :=
  (hc.has_deriv_within_at.inv hx).derivWithin hxs

@[simp]
theorem deriv_inv'' (hc : DifferentiableAt 𝕜 c x) (hx : c x ≠ 0) : deriv (fun x => c x⁻¹) x = -deriv c x / c x ^ 2 :=
  (hc.has_deriv_at.inv hx).deriv

end Inverse

section Division

/-! ### Derivative of `x ↦ c x / d x` -/


variable{c d : 𝕜 → 𝕜}{c' d' : 𝕜}

theorem HasDerivWithinAt.div (hc : HasDerivWithinAt c c' s x) (hd : HasDerivWithinAt d d' s x) (hx : d x ≠ 0) :
  HasDerivWithinAt (fun y => c y / d y) (((c'*d x) - c x*d') / d x ^ 2) s x :=
  by 
    convert hc.mul ((has_deriv_at_inv hx).comp_has_deriv_within_at x hd)
    ·
      simp only [div_eq_mul_inv]
    ·
      fieldSimp 
      ring

theorem HasStrictDerivAt.div (hc : HasStrictDerivAt c c' x) (hd : HasStrictDerivAt d d' x) (hx : d x ≠ 0) :
  HasStrictDerivAt (fun y => c y / d y) (((c'*d x) - c x*d') / d x ^ 2) x :=
  by 
    convert hc.mul ((has_strict_deriv_at_inv hx).comp x hd)
    ·
      simp only [div_eq_mul_inv]
    ·
      fieldSimp 
      ring

theorem HasDerivAt.div (hc : HasDerivAt c c' x) (hd : HasDerivAt d d' x) (hx : d x ≠ 0) :
  HasDerivAt (fun y => c y / d y) (((c'*d x) - c x*d') / d x ^ 2) x :=
  by 
    rw [←has_deriv_within_at_univ] at *
    exact hc.div hd hx

theorem DifferentiableWithinAt.div (hc : DifferentiableWithinAt 𝕜 c s x) (hd : DifferentiableWithinAt 𝕜 d s x)
  (hx : d x ≠ 0) : DifferentiableWithinAt 𝕜 (fun x => c x / d x) s x :=
  (hc.has_deriv_within_at.div hd.has_deriv_within_at hx).DifferentiableWithinAt

@[simp]
theorem DifferentiableAt.div (hc : DifferentiableAt 𝕜 c x) (hd : DifferentiableAt 𝕜 d x) (hx : d x ≠ 0) :
  DifferentiableAt 𝕜 (fun x => c x / d x) x :=
  (hc.has_deriv_at.div hd.has_deriv_at hx).DifferentiableAt

theorem DifferentiableOn.div (hc : DifferentiableOn 𝕜 c s) (hd : DifferentiableOn 𝕜 d s)
  (hx : ∀ x (_ : x ∈ s), d x ≠ 0) : DifferentiableOn 𝕜 (fun x => c x / d x) s :=
  fun x h => (hc x h).div (hd x h) (hx x h)

@[simp]
theorem Differentiable.div (hc : Differentiable 𝕜 c) (hd : Differentiable 𝕜 d) (hx : ∀ x, d x ≠ 0) :
  Differentiable 𝕜 fun x => c x / d x :=
  fun x => (hc x).div (hd x) (hx x)

theorem deriv_within_div (hc : DifferentiableWithinAt 𝕜 c s x) (hd : DifferentiableWithinAt 𝕜 d s x) (hx : d x ≠ 0)
  (hxs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin (fun x => c x / d x) s x = ((derivWithin c s x*d x) - c x*derivWithin d s x) / d x ^ 2 :=
  (hc.has_deriv_within_at.div hd.has_deriv_within_at hx).derivWithin hxs

@[simp]
theorem deriv_div (hc : DifferentiableAt 𝕜 c x) (hd : DifferentiableAt 𝕜 d x) (hx : d x ≠ 0) :
  deriv (fun x => c x / d x) x = ((deriv c x*d x) - c x*deriv d x) / d x ^ 2 :=
  (hc.has_deriv_at.div hd.has_deriv_at hx).deriv

theorem DifferentiableWithinAt.div_const (hc : DifferentiableWithinAt 𝕜 c s x) {d : 𝕜} :
  DifferentiableWithinAt 𝕜 (fun x => c x / d) s x :=
  by 
    simp [div_eq_inv_mul, DifferentiableWithinAt.const_mul, hc]

@[simp]
theorem DifferentiableAt.div_const (hc : DifferentiableAt 𝕜 c x) {d : 𝕜} : DifferentiableAt 𝕜 (fun x => c x / d) x :=
  by 
    simpa only [div_eq_mul_inv] using (hc.has_deriv_at.mul_const (d⁻¹)).DifferentiableAt

theorem DifferentiableOn.div_const (hc : DifferentiableOn 𝕜 c s) {d : 𝕜} : DifferentiableOn 𝕜 (fun x => c x / d) s :=
  by 
    simp [div_eq_inv_mul, DifferentiableOn.const_mul, hc]

@[simp]
theorem Differentiable.div_const (hc : Differentiable 𝕜 c) {d : 𝕜} : Differentiable 𝕜 fun x => c x / d :=
  by 
    simp [div_eq_inv_mul, Differentiable.const_mul, hc]

theorem deriv_within_div_const (hc : DifferentiableWithinAt 𝕜 c s x) {d : 𝕜} (hxs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin (fun x => c x / d) s x = derivWithin c s x / d :=
  by 
    simp [div_eq_inv_mul, deriv_within_const_mul, hc, hxs]

@[simp]
theorem deriv_div_const (d : 𝕜) : deriv (fun x => c x / d) x = deriv c x / d :=
  by 
    simp only [div_eq_mul_inv, deriv_mul_const_field]

end Division

section ClmCompApply

/-! ### Derivative of the pointwise composition/application of continuous linear maps -/


open ContinuousLinearMap

variable{G :
    Type
      _}[NormedGroup
      G][NormedSpace 𝕜 G]{c : 𝕜 → F →L[𝕜] G}{c' : F →L[𝕜] G}{d : 𝕜 → E →L[𝕜] F}{d' : E →L[𝕜] F}{u : 𝕜 → F}{u' : F}

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem has_strict_deriv_at.clm_comp
(hc : has_strict_deriv_at c c' x)
(hd : has_strict_deriv_at d d' x) : has_strict_deriv_at (λ
 y, (c y).comp (d y)) «expr + »(c'.comp (d x), (c x).comp d') x :=
begin
  have [] [] [":=", expr (hc.has_strict_fderiv_at.clm_comp hd.has_strict_fderiv_at).has_strict_deriv_at],
  rwa ["[", expr add_apply, ",", expr comp_apply, ",", expr comp_apply, ",", expr smul_right_apply, ",", expr smul_right_apply, ",", expr one_apply, ",", expr one_smul, ",", expr one_smul, ",", expr add_comm, "]"] ["at", ident this]
end

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem has_deriv_within_at.clm_comp
(hc : has_deriv_within_at c c' s x)
(hd : has_deriv_within_at d d' s x) : has_deriv_within_at (λ
 y, (c y).comp (d y)) «expr + »(c'.comp (d x), (c x).comp d') s x :=
begin
  have [] [] [":=", expr (hc.has_fderiv_within_at.clm_comp hd.has_fderiv_within_at).has_deriv_within_at],
  rwa ["[", expr add_apply, ",", expr comp_apply, ",", expr comp_apply, ",", expr smul_right_apply, ",", expr smul_right_apply, ",", expr one_apply, ",", expr one_smul, ",", expr one_smul, ",", expr add_comm, "]"] ["at", ident this]
end

theorem HasDerivAt.clm_comp (hc : HasDerivAt c c' x) (hd : HasDerivAt d d' x) :
  HasDerivAt (fun y => (c y).comp (d y)) (c'.comp (d x)+(c x).comp d') x :=
  by 
    rw [←has_deriv_within_at_univ] at *
    exact hc.clm_comp hd

theorem deriv_within_clm_comp (hc : DifferentiableWithinAt 𝕜 c s x) (hd : DifferentiableWithinAt 𝕜 d s x)
  (hxs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin (fun y => (c y).comp (d y)) s x = (derivWithin c s x).comp (d x)+(c x).comp (derivWithin d s x) :=
  (hc.has_deriv_within_at.clm_comp hd.has_deriv_within_at).derivWithin hxs

theorem deriv_clm_comp (hc : DifferentiableAt 𝕜 c x) (hd : DifferentiableAt 𝕜 d x) :
  deriv (fun y => (c y).comp (d y)) x = (deriv c x).comp (d x)+(c x).comp (deriv d x) :=
  (hc.has_deriv_at.clm_comp hd.has_deriv_at).deriv

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem has_strict_deriv_at.clm_apply
(hc : has_strict_deriv_at c c' x)
(hu : has_strict_deriv_at u u' x) : has_strict_deriv_at (λ y, c y (u y)) «expr + »(c' (u x), c x u') x :=
begin
  have [] [] [":=", expr (hc.has_strict_fderiv_at.clm_apply hu.has_strict_fderiv_at).has_strict_deriv_at],
  rwa ["[", expr add_apply, ",", expr comp_apply, ",", expr flip_apply, ",", expr smul_right_apply, ",", expr smul_right_apply, ",", expr one_apply, ",", expr one_smul, ",", expr one_smul, ",", expr add_comm, "]"] ["at", ident this]
end

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem has_deriv_within_at.clm_apply
(hc : has_deriv_within_at c c' s x)
(hu : has_deriv_within_at u u' s x) : has_deriv_within_at (λ y, c y (u y)) «expr + »(c' (u x), c x u') s x :=
begin
  have [] [] [":=", expr (hc.has_fderiv_within_at.clm_apply hu.has_fderiv_within_at).has_deriv_within_at],
  rwa ["[", expr add_apply, ",", expr comp_apply, ",", expr flip_apply, ",", expr smul_right_apply, ",", expr smul_right_apply, ",", expr one_apply, ",", expr one_smul, ",", expr one_smul, ",", expr add_comm, "]"] ["at", ident this]
end

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem has_deriv_at.clm_apply
(hc : has_deriv_at c c' x)
(hu : has_deriv_at u u' x) : has_deriv_at (λ y, c y (u y)) «expr + »(c' (u x), c x u') x :=
begin
  have [] [] [":=", expr (hc.has_fderiv_at.clm_apply hu.has_fderiv_at).has_deriv_at],
  rwa ["[", expr add_apply, ",", expr comp_apply, ",", expr flip_apply, ",", expr smul_right_apply, ",", expr smul_right_apply, ",", expr one_apply, ",", expr one_smul, ",", expr one_smul, ",", expr add_comm, "]"] ["at", ident this]
end

theorem deriv_within_clm_apply (hxs : UniqueDiffWithinAt 𝕜 s x) (hc : DifferentiableWithinAt 𝕜 c s x)
  (hu : DifferentiableWithinAt 𝕜 u s x) :
  derivWithin (fun y => (c y) (u y)) s x = derivWithin c s x (u x)+c x (derivWithin u s x) :=
  (hc.has_deriv_within_at.clm_apply hu.has_deriv_within_at).derivWithin hxs

theorem deriv_clm_apply (hc : DifferentiableAt 𝕜 c x) (hu : DifferentiableAt 𝕜 u x) :
  deriv (fun y => (c y) (u y)) x = deriv c x (u x)+c x (deriv u x) :=
  (hc.has_deriv_at.clm_apply hu.has_deriv_at).deriv

end ClmCompApply

theorem HasStrictDerivAt.has_strict_fderiv_at_equiv {f : 𝕜 → 𝕜} {f' x : 𝕜} (hf : HasStrictDerivAt f f' x)
  (hf' : f' ≠ 0) : HasStrictFderivAt f (ContinuousLinearEquiv.unitsEquivAut 𝕜 (Units.mk0 f' hf') : 𝕜 →L[𝕜] 𝕜) x :=
  hf

theorem HasDerivAt.has_fderiv_at_equiv {f : 𝕜 → 𝕜} {f' x : 𝕜} (hf : HasDerivAt f f' x) (hf' : f' ≠ 0) :
  HasFderivAt f (ContinuousLinearEquiv.unitsEquivAut 𝕜 (Units.mk0 f' hf') : 𝕜 →L[𝕜] 𝕜) x :=
  hf

/-- If `f (g y) = y` for `y` in some neighborhood of `a`, `g` is continuous at `a`, and `f` has an
invertible derivative `f'` at `g a` in the strict sense, then `g` has the derivative `f'⁻¹` at `a`
in the strict sense.

This is one of the easy parts of the inverse function theorem: it assumes that we already have an
inverse function. -/
theorem HasStrictDerivAt.of_local_left_inverse {f g : 𝕜 → 𝕜} {f' a : 𝕜} (hg : ContinuousAt g a)
  (hf : HasStrictDerivAt f f' (g a)) (hf' : f' ≠ 0) (hfg : ∀ᶠy in 𝓝 a, f (g y) = y) : HasStrictDerivAt g (f'⁻¹) a :=
  (hf.has_strict_fderiv_at_equiv hf').of_local_left_inverse hg hfg

/-- If `f` is a local homeomorphism defined on a neighbourhood of `f.symm a`, and `f` has a
nonzero derivative `f'` at `f.symm a` in the strict sense, then `f.symm` has the derivative `f'⁻¹`
at `a` in the strict sense.

This is one of the easy parts of the inverse function theorem: it assumes that we already have
an inverse function. -/
theorem LocalHomeomorph.has_strict_deriv_at_symm (f : LocalHomeomorph 𝕜 𝕜) {a f' : 𝕜} (ha : a ∈ f.target) (hf' : f' ≠ 0)
  (htff' : HasStrictDerivAt f f' (f.symm a)) : HasStrictDerivAt f.symm (f'⁻¹) a :=
  htff'.of_local_left_inverse (f.symm.continuous_at ha) hf' (f.eventually_right_inverse ha)

/-- If `f (g y) = y` for `y` in some neighborhood of `a`, `g` is continuous at `a`, and `f` has an
invertible derivative `f'` at `g a`, then `g` has the derivative `f'⁻¹` at `a`.

This is one of the easy parts of the inverse function theorem: it assumes that we already have
an inverse function. -/
theorem HasDerivAt.of_local_left_inverse {f g : 𝕜 → 𝕜} {f' a : 𝕜} (hg : ContinuousAt g a) (hf : HasDerivAt f f' (g a))
  (hf' : f' ≠ 0) (hfg : ∀ᶠy in 𝓝 a, f (g y) = y) : HasDerivAt g (f'⁻¹) a :=
  (hf.has_fderiv_at_equiv hf').of_local_left_inverse hg hfg

/-- If `f` is a local homeomorphism defined on a neighbourhood of `f.symm a`, and `f` has an
nonzero derivative `f'` at `f.symm a`, then `f.symm` has the derivative `f'⁻¹` at `a`.

This is one of the easy parts of the inverse function theorem: it assumes that we already have
an inverse function. -/
theorem LocalHomeomorph.has_deriv_at_symm (f : LocalHomeomorph 𝕜 𝕜) {a f' : 𝕜} (ha : a ∈ f.target) (hf' : f' ≠ 0)
  (htff' : HasDerivAt f f' (f.symm a)) : HasDerivAt f.symm (f'⁻¹) a :=
  htff'.of_local_left_inverse (f.symm.continuous_at ha) hf' (f.eventually_right_inverse ha)

theorem HasDerivAt.eventually_ne (h : HasDerivAt f f' x) (hf' : f' ≠ 0) : ∀ᶠz in 𝓝[«expr ᶜ» {x}] x, f z ≠ f x :=
  (has_deriv_at_iff_has_fderiv_at.1 h).eventually_ne
    ⟨∥f'∥⁻¹,
      fun z =>
        by 
          fieldSimp [norm_smul, mt norm_eq_zero.1 hf']⟩

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem not_differentiable_within_at_of_local_left_inverse_has_deriv_within_at_zero
{f g : 𝕜 → 𝕜}
{a : 𝕜}
{s t : set 𝕜}
(ha : «expr ∈ »(a, s))
(hsu : unique_diff_within_at 𝕜 s a)
(hf : has_deriv_within_at f 0 t (g a))
(hst : maps_to g s t)
(hfg : «expr =ᶠ[ ] »(«expr ∘ »(f, g), «expr𝓝[ ] »(s, a), id)) : «expr¬ »(differentiable_within_at 𝕜 g s a) :=
begin
  intro [ident hg],
  have [] [] [":=", expr (hf.comp a hg.has_deriv_within_at hst).congr_of_eventually_eq_of_mem hfg.symm ha],
  simpa [] [] [] [] [] ["using", expr hsu.eq_deriv _ this (has_deriv_within_at_id _ _)]
end

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem not_differentiable_at_of_local_left_inverse_has_deriv_at_zero
{f g : 𝕜 → 𝕜}
{a : 𝕜}
(hf : has_deriv_at f 0 (g a))
(hfg : «expr =ᶠ[ ] »(«expr ∘ »(f, g), expr𝓝() a, id)) : «expr¬ »(differentiable_at 𝕜 g a) :=
begin
  intro [ident hg],
  have [] [] [":=", expr (hf.comp a hg.has_deriv_at).congr_of_eventually_eq hfg.symm],
  simpa [] [] [] [] [] ["using", expr this.unique (has_deriv_at_id a)]
end

end 

namespace Polynomial

/-! ### Derivative of a polynomial -/


variable{x : 𝕜}{s : Set 𝕜}

variable(p : Polynomial 𝕜)

/-- The derivative (in the analysis sense) of a polynomial `p` is given by `p.derivative`. -/
protected theorem HasStrictDerivAt (x : 𝕜) : HasStrictDerivAt (fun x => p.eval x) (p.derivative.eval x) x :=
  by 
    apply p.induction_on
    ·
      simp [has_strict_deriv_at_const]
    ·
      intro p q hp hq 
      convert hp.add hq <;> simp 
    ·
      intro n a h 
      convert h.mul (has_strict_deriv_at_id x)
      ·
        ext y 
        simp [pow_addₓ, mul_assocₓ]
      ·
        simp [pow_addₓ]
        ring

/-- The derivative (in the analysis sense) of a polynomial `p` is given by `p.derivative`. -/
protected theorem HasDerivAt (x : 𝕜) : HasDerivAt (fun x => p.eval x) (p.derivative.eval x) x :=
  (p.has_strict_deriv_at x).HasDerivAt

protected theorem HasDerivWithinAt (x : 𝕜) (s : Set 𝕜) :
  HasDerivWithinAt (fun x => p.eval x) (p.derivative.eval x) s x :=
  (p.has_deriv_at x).HasDerivWithinAt

protected theorem DifferentiableAt : DifferentiableAt 𝕜 (fun x => p.eval x) x :=
  (p.has_deriv_at x).DifferentiableAt

protected theorem DifferentiableWithinAt : DifferentiableWithinAt 𝕜 (fun x => p.eval x) s x :=
  p.differentiable_at.differentiable_within_at

protected theorem Differentiable : Differentiable 𝕜 fun x => p.eval x :=
  fun x => p.differentiable_at

protected theorem DifferentiableOn : DifferentiableOn 𝕜 (fun x => p.eval x) s :=
  p.differentiable.differentiable_on

@[simp]
protected theorem deriv : deriv (fun x => p.eval x) x = p.derivative.eval x :=
  (p.has_deriv_at x).deriv

protected theorem derivWithin (hxs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin (fun x => p.eval x) s x = p.derivative.eval x :=
  by 
    rw [DifferentiableAt.deriv_within p.differentiable_at hxs]
    exact p.deriv

protected theorem HasFderivAt (x : 𝕜) :
  HasFderivAt (fun x => p.eval x) (smul_right (1 : 𝕜 →L[𝕜] 𝕜) (p.derivative.eval x)) x :=
  p.has_deriv_at x

protected theorem HasFderivWithinAt (x : 𝕜) :
  HasFderivWithinAt (fun x => p.eval x) (smul_right (1 : 𝕜 →L[𝕜] 𝕜) (p.derivative.eval x)) s x :=
  (p.has_fderiv_at x).HasFderivWithinAt

@[simp]
protected theorem fderiv : fderiv 𝕜 (fun x => p.eval x) x = smul_right (1 : 𝕜 →L[𝕜] 𝕜) (p.derivative.eval x) :=
  (p.has_fderiv_at x).fderiv

protected theorem fderivWithin (hxs : UniqueDiffWithinAt 𝕜 s x) :
  fderivWithin 𝕜 (fun x => p.eval x) s x = smul_right (1 : 𝕜 →L[𝕜] 𝕜) (p.derivative.eval x) :=
  (p.has_fderiv_within_at x).fderivWithin hxs

end Polynomial

section Pow

/-! ### Derivative of `x ↦ x^n` for `n : ℕ` -/


variable{x : 𝕜}{s : Set 𝕜}{c : 𝕜 → 𝕜}{c' : 𝕜}

variable{n : ℕ}

theorem has_strict_deriv_at_pow (n : ℕ) (x : 𝕜) : HasStrictDerivAt (fun x => x ^ n) ((n : 𝕜)*x ^ (n - 1)) x :=
  by 
    convert (Polynomial.c (1 : 𝕜)*Polynomial.x ^ n).HasStrictDerivAt x
    ·
      simp 
    ·
      rw [Polynomial.derivative_C_mul_X_pow]
      simp 

theorem has_deriv_at_pow (n : ℕ) (x : 𝕜) : HasDerivAt (fun x => x ^ n) ((n : 𝕜)*x ^ (n - 1)) x :=
  (has_strict_deriv_at_pow n x).HasDerivAt

theorem has_deriv_within_at_pow (n : ℕ) (x : 𝕜) (s : Set 𝕜) :
  HasDerivWithinAt (fun x => x ^ n) ((n : 𝕜)*x ^ (n - 1)) s x :=
  (has_deriv_at_pow n x).HasDerivWithinAt

theorem differentiable_at_pow : DifferentiableAt 𝕜 (fun x => x ^ n) x :=
  (has_deriv_at_pow n x).DifferentiableAt

theorem differentiable_within_at_pow : DifferentiableWithinAt 𝕜 (fun x => x ^ n) s x :=
  differentiable_at_pow.DifferentiableWithinAt

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem differentiable_pow : differentiable 𝕜 (λ x : 𝕜, «expr ^ »(x, n)) := λ x, differentiable_at_pow

theorem differentiable_on_pow : DifferentiableOn 𝕜 (fun x => x ^ n) s :=
  differentiable_pow.DifferentiableOn

theorem deriv_pow : deriv (fun x => x ^ n) x = (n : 𝕜)*x ^ (n - 1) :=
  (has_deriv_at_pow n x).deriv

@[simp]
theorem deriv_pow' : (deriv fun x => x ^ n) = fun x => (n : 𝕜)*x ^ (n - 1) :=
  funext$ fun x => deriv_pow

theorem deriv_within_pow (hxs : UniqueDiffWithinAt 𝕜 s x) : derivWithin (fun x => x ^ n) s x = (n : 𝕜)*x ^ (n - 1) :=
  (has_deriv_within_at_pow n x s).derivWithin hxs

theorem HasDerivWithinAt.pow (hc : HasDerivWithinAt c c' s x) :
  HasDerivWithinAt (fun y => c y ^ n) (((n : 𝕜)*c x ^ (n - 1))*c') s x :=
  (has_deriv_at_pow n (c x)).comp_has_deriv_within_at x hc

theorem HasDerivAt.pow (hc : HasDerivAt c c' x) : HasDerivAt (fun y => c y ^ n) (((n : 𝕜)*c x ^ (n - 1))*c') x :=
  by 
    rw [←has_deriv_within_at_univ] at *
    exact hc.pow

theorem DifferentiableWithinAt.pow (hc : DifferentiableWithinAt 𝕜 c s x) :
  DifferentiableWithinAt 𝕜 (fun x => c x ^ n) s x :=
  hc.has_deriv_within_at.pow.differentiable_within_at

@[simp]
theorem DifferentiableAt.pow (hc : DifferentiableAt 𝕜 c x) : DifferentiableAt 𝕜 (fun x => c x ^ n) x :=
  hc.has_deriv_at.pow.differentiable_at

theorem DifferentiableOn.pow (hc : DifferentiableOn 𝕜 c s) : DifferentiableOn 𝕜 (fun x => c x ^ n) s :=
  fun x h => (hc x h).pow

@[simp]
theorem Differentiable.pow (hc : Differentiable 𝕜 c) : Differentiable 𝕜 fun x => c x ^ n :=
  fun x => (hc x).pow

theorem deriv_within_pow' (hc : DifferentiableWithinAt 𝕜 c s x) (hxs : UniqueDiffWithinAt 𝕜 s x) :
  derivWithin (fun x => c x ^ n) s x = ((n : 𝕜)*c x ^ (n - 1))*derivWithin c s x :=
  hc.has_deriv_within_at.pow.deriv_within hxs

@[simp]
theorem deriv_pow'' (hc : DifferentiableAt 𝕜 c x) : deriv (fun x => c x ^ n) x = ((n : 𝕜)*c x ^ (n - 1))*deriv c x :=
  hc.has_deriv_at.pow.deriv

end Pow

section Zpow

/-! ### Derivative of `x ↦ x^m` for `m : ℤ` -/


variable{x : 𝕜}{s : Set 𝕜}{m : ℤ}

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem has_strict_deriv_at_zpow
(m : exprℤ())
(x : 𝕜)
(h : «expr ∨ »(«expr ≠ »(x, 0), «expr ≤ »(0, m))) : has_strict_deriv_at (λ
 x, «expr ^ »(x, m)) «expr * »((m : 𝕜), «expr ^ »(x, «expr - »(m, 1))) x :=
begin
  have [] [":", expr ∀
   m : exprℤ(), «expr < »(0, m) → has_strict_deriv_at (λ
    x, «expr ^ »(x, m)) «expr * »((m : 𝕜), «expr ^ »(x, «expr - »(m, 1))) x] [],
  { assume [binders (m hm)],
    lift [expr m] ["to", expr exprℕ()] ["using", expr le_of_lt hm] [],
    simp [] [] ["only"] ["[", expr zpow_coe_nat, ",", expr int.cast_coe_nat, "]"] [] [],
    convert [] [expr has_strict_deriv_at_pow _ _] ["using", 2],
    rw ["[", "<-", expr int.coe_nat_one, ",", "<-", expr int.coe_nat_sub, ",", expr zpow_coe_nat, "]"] [],
    norm_cast ["at", ident hm],
    exact [expr nat.succ_le_of_lt hm] },
  rcases [expr lt_trichotomy m 0, "with", ident hm, "|", ident hm, "|", ident hm],
  { have [ident hx] [":", expr «expr ≠ »(x, 0)] [],
    from [expr h.resolve_right hm.not_le],
    have [] [] [":=", expr (has_strict_deriv_at_inv _).scomp _ (this «expr- »(m) (neg_pos.2 hm))]; [skip, exact [expr zpow_ne_zero_of_ne_zero hx _]],
    simp [] [] ["only"] ["[", expr («expr ∘ »), ",", expr zpow_neg₀, ",", expr one_div, ",", expr inv_inv₀, ",", expr smul_eq_mul, "]"] [] ["at", ident this],
    convert [] [expr this] ["using", 1],
    rw ["[", expr sq, ",", expr mul_inv₀, ",", expr inv_inv₀, ",", expr int.cast_neg, ",", "<-", expr neg_mul_eq_neg_mul, ",", expr neg_mul_neg, ",", "<-", expr zpow_add₀ hx, ",", expr mul_assoc, ",", "<-", expr zpow_add₀ hx, "]"] [],
    congr,
    abel [] [] [] },
  { simp [] [] ["only"] ["[", expr hm, ",", expr zpow_zero, ",", expr int.cast_zero, ",", expr zero_mul, ",", expr has_strict_deriv_at_const, "]"] [] [] },
  { exact [expr this m hm] }
end

theorem has_deriv_at_zpow (m : ℤ) (x : 𝕜) (h : x ≠ 0 ∨ 0 ≤ m) : HasDerivAt (fun x => x ^ m) ((m : 𝕜)*x ^ (m - 1)) x :=
  (has_strict_deriv_at_zpow m x h).HasDerivAt

theorem has_deriv_within_at_zpow (m : ℤ) (x : 𝕜) (h : x ≠ 0 ∨ 0 ≤ m) (s : Set 𝕜) :
  HasDerivWithinAt (fun x => x ^ m) ((m : 𝕜)*x ^ (m - 1)) s x :=
  (has_deriv_at_zpow m x h).HasDerivWithinAt

theorem differentiable_at_zpow : DifferentiableAt 𝕜 (fun x => x ^ m) x ↔ x ≠ 0 ∨ 0 ≤ m :=
  ⟨fun H => NormedField.continuous_at_zpow.1 H.continuous_at, fun H => (has_deriv_at_zpow m x H).DifferentiableAt⟩

theorem differentiable_within_at_zpow (m : ℤ) (x : 𝕜) (h : x ≠ 0 ∨ 0 ≤ m) :
  DifferentiableWithinAt 𝕜 (fun x => x ^ m) s x :=
  (differentiable_at_zpow.mpr h).DifferentiableWithinAt

theorem differentiable_on_zpow (m : ℤ) (s : Set 𝕜) (h : (0 : 𝕜) ∉ s ∨ 0 ≤ m) : DifferentiableOn 𝕜 (fun x => x ^ m) s :=
  fun x hxs => differentiable_within_at_zpow m x$ h.imp_left$ ne_of_mem_of_not_mem hxs

theorem deriv_zpow (m : ℤ) (x : 𝕜) : deriv (fun x => x ^ m) x = m*x ^ (m - 1) :=
  by 
    byCases' H : x ≠ 0 ∨ 0 ≤ m
    ·
      exact (has_deriv_at_zpow m x H).deriv
    ·
      rw [deriv_zero_of_not_differentiable_at (mt differentiable_at_zpow.1 H)]
      pushNeg  at H 
      rcases H with ⟨rfl, hm⟩
      rw [zero_zpow _ ((sub_one_lt _).trans hm).Ne, mul_zero]

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem deriv_zpow'
(m : exprℤ()) : «expr = »(deriv (λ x : 𝕜, «expr ^ »(x, m)), λ x, «expr * »(m, «expr ^ »(x, «expr - »(m, 1)))) :=
«expr $ »(funext, deriv_zpow m)

theorem deriv_within_zpow (hxs : UniqueDiffWithinAt 𝕜 s x) (h : x ≠ 0 ∨ 0 ≤ m) :
  derivWithin (fun x => x ^ m) s x = (m : 𝕜)*x ^ (m - 1) :=
  (has_deriv_within_at_zpow m x h s).derivWithin hxs

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem iter_deriv_zpow'
(m : exprℤ())
(k : exprℕ()) : «expr = »(«expr ^[ ]»(deriv, k) (λ
  x : 𝕜, «expr ^ »(x, m)), λ
 x, «expr * »(«expr∏ in , »((i), finset.range k, «expr - »(m, i)), «expr ^ »(x, «expr - »(m, k)))) :=
begin
  induction [expr k] [] ["with", ident k, ident ihk] [],
  { simp [] [] ["only"] ["[", expr one_mul, ",", expr int.coe_nat_zero, ",", expr id, ",", expr sub_zero, ",", expr finset.prod_range_zero, ",", expr function.iterate_zero, "]"] [] [] },
  { simp [] [] ["only"] ["[", expr function.iterate_succ_apply', ",", expr ihk, ",", expr deriv_const_mul_field', ",", expr deriv_zpow', ",", expr finset.prod_range_succ, ",", expr int.coe_nat_succ, ",", "<-", expr sub_sub, ",", expr int.cast_sub, ",", expr int.cast_coe_nat, ",", expr mul_assoc, "]"] [] [] }
end

theorem iter_deriv_zpow (m : ℤ) (x : 𝕜) (k : ℕ) :
  (deriv^[k]) (fun y => y ^ m) x = (∏i in Finset.range k, m - i)*x ^ (m - k) :=
  congr_funₓ (iter_deriv_zpow' m k) x

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem iter_deriv_pow
(n : exprℕ())
(x : 𝕜)
(k : exprℕ()) : «expr = »(«expr ^[ ]»(deriv, k) (λ
  x : 𝕜, «expr ^ »(x, n)) x, «expr * »(«expr∏ in , »((i), finset.range k, «expr - »(n, i)), «expr ^ »(x, «expr - »(n, k)))) :=
begin
  simp [] [] ["only"] ["[", "<-", expr zpow_coe_nat, ",", expr iter_deriv_zpow, ",", expr int.cast_coe_nat, "]"] [] [],
  cases [expr le_or_lt k n] ["with", ident hkn, ident hnk],
  { rw [expr int.coe_nat_sub hkn] [] },
  { have [] [":", expr «expr = »(«expr∏ in , »((i), finset.range k, («expr - »(n, i) : 𝕜)), 0)] [],
    from [expr finset.prod_eq_zero (finset.mem_range.2 hnk) (sub_self _)],
    simp [] [] ["only"] ["[", expr this, ",", expr zero_mul, "]"] [] [] }
end

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem iter_deriv_pow'
(n
 k : exprℕ()) : «expr = »(«expr ^[ ]»(deriv, k) (λ
  x : 𝕜, «expr ^ »(x, n)), λ
 x, «expr * »(«expr∏ in , »((i), finset.range k, «expr - »(n, i)), «expr ^ »(x, «expr - »(n, k)))) :=
«expr $ »(funext, λ x, iter_deriv_pow n x k)

theorem iter_deriv_inv (k : ℕ) (x : 𝕜) : (deriv^[k]) HasInv.inv x = (∏i in Finset.range k, -1 - i)*x ^ (-1 - k : ℤ) :=
  by 
    simpa only [zpow_neg_one₀, Int.cast_neg, Int.cast_one] using iter_deriv_zpow (-1) x k

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem iter_deriv_inv'
(k : exprℕ()) : «expr = »(«expr ^[ ]»(deriv, k) has_inv.inv, λ
 x : 𝕜, «expr * »(«expr∏ in , »((i), finset.range k, «expr - »(«expr- »(1), i)), «expr ^ »(x, («expr - »(«expr- »(1), k) : exprℤ())))) :=
funext (iter_deriv_inv k)

end Zpow

/-! ### Upper estimates on liminf and limsup -/


section Real

variable{f : ℝ → ℝ}{f' : ℝ}{s : Set ℝ}{x : ℝ}{r : ℝ}

theorem HasDerivWithinAt.limsup_slope_le (hf : HasDerivWithinAt f f' s x) (hr : f' < r) :
  ∀ᶠz in 𝓝[s \ {x}] x, ((z - x)⁻¹*f z - f x) < r :=
  has_deriv_within_at_iff_tendsto_slope.1 hf (IsOpen.mem_nhds is_open_Iio hr)

theorem HasDerivWithinAt.limsup_slope_le' (hf : HasDerivWithinAt f f' s x) (hs : x ∉ s) (hr : f' < r) :
  ∀ᶠz in 𝓝[s] x, ((z - x)⁻¹*f z - f x) < r :=
  (has_deriv_within_at_iff_tendsto_slope' hs).1 hf (IsOpen.mem_nhds is_open_Iio hr)

theorem HasDerivWithinAt.liminf_right_slope_le (hf : HasDerivWithinAt f f' (Ici x) x) (hr : f' < r) :
  ∃ᶠz in 𝓝[Ioi x] x, ((z - x)⁻¹*f z - f x) < r :=
  (hf.Ioi_of_Ici.limsup_slope_le' (lt_irreflₓ x) hr).Frequently

end Real

section RealSpace

open Metric

variable{E : Type u}[NormedGroup E][NormedSpace ℝ E]{f : ℝ → E}{f' : E}{s : Set ℝ}{x r : ℝ}

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `f` has derivative `f'` within `s` at `x`, then for any `r > ∥f'∥` the ratio
`∥f z - f x∥ / ∥z - x∥` is less than `r` in some neighborhood of `x` within `s`.
In other words, the limit superior of this ratio as `z` tends to `x` along `s`
is less than or equal to `∥f'∥`. -/
theorem has_deriv_within_at.limsup_norm_slope_le
(hf : has_deriv_within_at f f' s x)
(hr : «expr < »(«expr∥ ∥»(f'), r)) : «expr∀ᶠ in , »((z), «expr𝓝[ ] »(s, x), «expr < »(«expr * »(«expr ⁻¹»(«expr∥ ∥»(«expr - »(z, x))), «expr∥ ∥»(«expr - »(f z, f x))), r)) :=
begin
  have [ident hr₀] [":", expr «expr < »(0, r)] [],
  from [expr lt_of_le_of_lt (norm_nonneg f') hr],
  have [ident A] [":", expr «expr∀ᶠ in , »((z), «expr𝓝[ ] »(«expr \ »(s, {x}), x), «expr ∈ »(«expr∥ ∥»(«expr • »(«expr ⁻¹»(«expr - »(z, x)), «expr - »(f z, f x))), Iio r))] [],
  from [expr (has_deriv_within_at_iff_tendsto_slope.1 hf).norm (is_open.mem_nhds is_open_Iio hr)],
  have [ident B] [":", expr «expr∀ᶠ in , »((z), «expr𝓝[ ] »({x}, x), «expr ∈ »(«expr∥ ∥»(«expr • »(«expr ⁻¹»(«expr - »(z, x)), «expr - »(f z, f x))), Iio r))] [],
  from [expr mem_of_superset self_mem_nhds_within «expr $ »(singleton_subset_iff.2, by simp [] [] [] ["[", expr hr₀, "]"] [] [])],
  have [ident C] [] [":=", expr mem_sup.2 ⟨A, B⟩],
  rw ["[", "<-", expr nhds_within_union, ",", expr diff_union_self, ",", expr nhds_within_union, ",", expr mem_sup, "]"] ["at", ident C],
  filter_upwards ["[", expr C.1, "]"] [],
  simp [] [] ["only"] ["[", expr norm_smul, ",", expr mem_Iio, ",", expr normed_field.norm_inv, "]"] [] [],
  exact [expr λ _, id]
end

/-- If `f` has derivative `f'` within `s` at `x`, then for any `r > ∥f'∥` the ratio
`(∥f z∥ - ∥f x∥) / ∥z - x∥` is less than `r` in some neighborhood of `x` within `s`.
In other words, the limit superior of this ratio as `z` tends to `x` along `s`
is less than or equal to `∥f'∥`.

This lemma is a weaker version of `has_deriv_within_at.limsup_norm_slope_le`
where `∥f z∥ - ∥f x∥` is replaced by `∥f z - f x∥`. -/
theorem HasDerivWithinAt.limsup_slope_norm_le (hf : HasDerivWithinAt f f' s x) (hr : ∥f'∥ < r) :
  ∀ᶠz in 𝓝[s] x, (∥z - x∥⁻¹*∥f z∥ - ∥f x∥) < r :=
  by 
    apply (hf.limsup_norm_slope_le hr).mono 
    intro z hz 
    refine' lt_of_le_of_ltₓ (mul_le_mul_of_nonneg_left (norm_sub_norm_le _ _) _) hz 
    exact inv_nonneg.2 (norm_nonneg _)

/-- If `f` has derivative `f'` within `(x, +∞)` at `x`, then for any `r > ∥f'∥` the ratio
`∥f z - f x∥ / ∥z - x∥` is frequently less than `r` as `z → x+0`.
In other words, the limit inferior of this ratio as `z` tends to `x+0`
is less than or equal to `∥f'∥`. See also `has_deriv_within_at.limsup_norm_slope_le`
for a stronger version using limit superior and any set `s`. -/
theorem HasDerivWithinAt.liminf_right_norm_slope_le (hf : HasDerivWithinAt f f' (Ici x) x) (hr : ∥f'∥ < r) :
  ∃ᶠz in 𝓝[Ioi x] x, (∥z - x∥⁻¹*∥f z - f x∥) < r :=
  (hf.Ioi_of_Ici.limsup_norm_slope_le hr).Frequently

-- error in Analysis.Calculus.Deriv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `f` has derivative `f'` within `(x, +∞)` at `x`, then for any `r > ∥f'∥` the ratio
`(∥f z∥ - ∥f x∥) / (z - x)` is frequently less than `r` as `z → x+0`.
In other words, the limit inferior of this ratio as `z` tends to `x+0`
is less than or equal to `∥f'∥`.

See also

* `has_deriv_within_at.limsup_norm_slope_le` for a stronger version using
  limit superior and any set `s`;
* `has_deriv_within_at.liminf_right_norm_slope_le` for a stronger version using
  `∥f z - f x∥` instead of `∥f z∥ - ∥f x∥`. -/
theorem has_deriv_within_at.liminf_right_slope_norm_le
(hf : has_deriv_within_at f f' (Ici x) x)
(hr : «expr < »(«expr∥ ∥»(f'), r)) : «expr∃ᶠ in , »((z), «expr𝓝[ ] »(Ioi x, x), «expr < »(«expr * »(«expr ⁻¹»(«expr - »(z, x)), «expr - »(«expr∥ ∥»(f z), «expr∥ ∥»(f x))), r)) :=
begin
  have [] [] [":=", expr (hf.Ioi_of_Ici.limsup_slope_norm_le hr).frequently],
  refine [expr this.mp (eventually.mono self_mem_nhds_within _)],
  assume [binders (z hxz hz)],
  rwa ["[", expr real.norm_eq_abs, ",", expr abs_of_pos (sub_pos_of_lt hxz), "]"] ["at", ident hz]
end

end RealSpace

