import Mathbin.Analysis.NormedSpace.Dual 
import Mathbin.Data.Set.Intervals.Disjoint 
import Mathbin.MeasureTheory.Measure.Lebesgue 
import Mathbin.Analysis.Calculus.ExtendDeriv 
import Mathbin.MeasureTheory.Integral.SetIntegral 
import Mathbin.MeasureTheory.Integral.VitaliCaratheodory

/-!
# Integral over an interval

In this file we define `∫ x in a..b, f x ∂μ` to be `∫ x in Ioc a b, f x ∂μ` if `a ≤ b` and
`-∫ x in Ioc b a, f x ∂μ` if `b ≤ a`. We prove a few simple properties and several versions of the
[fundamental theorem of calculus](https://en.wikipedia.org/wiki/Fundamental_theorem_of_calculus).

Recall that its first version states that the function `(u, v) ↦ ∫ x in u..v, f x` has derivative
`(δu, δv) ↦ δv • f b - δu • f a` at `(a, b)` provided that `f` is continuous at `a` and `b`,
and its second version states that, if `f` has an integrable derivative on `[a, b]`, then
`∫ x in a..b, f' x = f b - f a`.

## Main statements

### FTC-1 for Lebesgue measure

We prove several versions of FTC-1, all in the `interval_integral` namespace. Many of them follow
the naming scheme `integral_has(_strict?)_(f?)deriv(_within?)_at(_of_tendsto_ae?)(_right|_left?)`.
They formulate FTC in terms of `has(_strict?)_(f?)deriv(_within?)_at`.
Let us explain the meaning of each part of the name:

* `_strict` means that the theorem is about strict differentiability;
* `f` means that the theorem is about differentiability in both endpoints; incompatible with
  `_right|_left`;
* `_within` means that the theorem is about one-sided derivatives, see below for details;
* `_of_tendsto_ae` means that instead of continuity the theorem assumes that `f` has a finite limit
  almost surely as `x` tends to `a` and/or `b`;
* `_right` or `_left` mean that the theorem is about differentiability in the right (resp., left)
  endpoint.

We also reformulate these theorems in terms of `(f?)deriv(_within?)`. These theorems are named
`(f?)deriv(_within?)_integral(_of_tendsto_ae?)(_right|_left?)` with the same meaning of parts of the
name.

### One-sided derivatives

Theorem `integral_has_fderiv_within_at_of_tendsto_ae` states that `(u, v) ↦ ∫ x in u..v, f x` has a
derivative `(δu, δv) ↦ δv • cb - δu • ca` within the set `s × t` at `(a, b)` provided that `f` tends
to `ca` (resp., `cb`) almost surely at `la` (resp., `lb`), where possible values of `s`, `t`, and
corresponding filters `la`, `lb` are given in the following table.

| `s`     | `la`         | `t`     | `lb`         |
| ------- | ----         | ---     | ----         |
| `Iic a` | `𝓝[Iic a] a` | `Iic b` | `𝓝[Iic b] b` |
| `Ici a` | `𝓝[Ioi a] a` | `Ici b` | `𝓝[Ioi b] b` |
| `{a}`   | `⊥`          | `{b}`   | `⊥`          |
| `univ`  | `𝓝 a`        | `univ`  | `𝓝 b`        |

We use a typeclass `FTC_filter` to make Lean automatically find `la`/`lb` based on `s`/`t`. This way
we can formulate one theorem instead of `16` (or `8` if we leave only non-trivial ones not covered
by `integral_has_deriv_within_at_of_tendsto_ae_(left|right)` and
`integral_has_fderiv_at_of_tendsto_ae`). Similarly,
`integral_has_deriv_within_at_of_tendsto_ae_right` works for both one-sided derivatives using the
same typeclass to find an appropriate filter.

### FTC for a locally finite measure

Before proving FTC for the Lebesgue measure, we prove a few statements that can be seen as FTC for
any measure. The most general of them,
`measure_integral_sub_integral_sub_linear_is_o_of_tendsto_ae`, states the following. Let `(la, la')`
be an `FTC_filter` pair of filters around `a` (i.e., `FTC_filter a la la'`) and let `(lb, lb')` be
an `FTC_filter` pair of filters around `b`. If `f` has finite limits `ca` and `cb` almost surely at
`la'` and `lb'`, respectively, then
`∫ x in va..vb, f x ∂μ - ∫ x in ua..ub, f x ∂μ = ∫ x in ub..vb, cb ∂μ - ∫ x in ua..va, ca ∂μ +
  o(∥∫ x in ua..va, (1:ℝ) ∂μ∥ + ∥∫ x in ub..vb, (1:ℝ) ∂μ∥)` as `ua` and `va` tend to `la` while
`ub` and `vb` tend to `lb`.

### FTC-2 and corollaries

We use FTC-1 to prove several versions of FTC-2 for the Lebesgue measure, using a similar naming
scheme as for the versions of FTC-1. They include:
* `interval_integral.integral_eq_sub_of_has_deriv_right_of_le` - most general version, for functions
  with a right derivative
* `interval_integral.integral_eq_sub_of_has_deriv_at'` - version for functions with a derivative on
  an open set
* `interval_integral.integral_deriv_eq_sub'` - version that is easiest to use when computing the
  integral of a specific function

We then derive additional integration techniques from FTC-2:
* `interval_integral.integral_mul_deriv_eq_deriv_mul` - integration by parts
* `interval_integral.integral_comp_mul_deriv''` - integration by substitution

Many applications of these theorems can be found in the file `analysis.special_functions.integrals`.

Note that the assumptions of FTC-2 are formulated in the form that `f'` is integrable. To use it in
a context with the stronger assumption that `f'` is continuous, one can use
`continuous_on.interval_integrable` or `continuous_on.integrable_on_Icc` or
`continuous_on.integrable_on_interval`.

## Implementation notes

### Avoiding `if`, `min`, and `max`

In order to avoid `if`s in the definition, we define `interval_integrable f μ a b` as
`integrable_on f (Ioc a b) μ ∧ integrable_on f (Ioc b a) μ`. For any `a`, `b` one of these
intervals is empty and the other coincides with `set.interval_oc a b = set.Ioc (min a b) (max a b)`.

Similarly, we define `∫ x in a..b, f x ∂μ` to be `∫ x in Ioc a b, f x ∂μ - ∫ x in Ioc b a, f x ∂μ`.
Again, for any `a`, `b` one of these integrals is zero, and the other gives the expected result.

This way some properties can be translated from integrals over sets without dealing with
the cases `a ≤ b` and `b ≤ a` separately.

### Choice of the interval

We use integral over `set.interval_oc a b = set.Ioc (min a b) (max a b)` instead of one of the other
three possible intervals with the same endpoints for two reasons:

* this way `∫ x in a..b, f x ∂μ + ∫ x in b..c, f x ∂μ = ∫ x in a..c, f x ∂μ` holds whenever
  `f` is integrable on each interval; in particular, it works even if the measure `μ` has an atom
  at `b`; this rules out `set.Ioo` and `set.Icc` intervals;
* with this definition for a probability measure `μ`, the integral `∫ x in a..b, 1 ∂μ` equals
  the difference $F_μ(b)-F_μ(a)$, where $F_μ(a)=μ(-∞, a]$ is the
  [cumulative distribution function](https://en.wikipedia.org/wiki/Cumulative_distribution_function)
  of `μ`.

### `FTC_filter` class

As explained above, many theorems in this file rely on the typeclass
`FTC_filter (a : α) (l l' : filter α)` to avoid code duplication. This typeclass combines four
assumptions:

- `pure a ≤ l`;
- `l' ≤ 𝓝 a`;
- `l'` has a basis of measurable sets;
- if `u n` and `v n` tend to `l`, then for any `s ∈ l'`, `Ioc (u n) (v n)` is eventually included
  in `s`.

This typeclass has the following “real” instances: `(a, pure a, ⊥)`, `(a, 𝓝[Ici a] a, 𝓝[Ioi a] a)`,
`(a, 𝓝[Iic a] a, 𝓝[Iic a] a)`, `(a, 𝓝 a, 𝓝 a)`.
Furthermore, we have the following instances that are equal to the previously mentioned instances:
`(a, 𝓝[{a}] a, ⊥)` and `(a, 𝓝[univ] a, 𝓝[univ] a)`.
While the difference between `Ici a` and `Ioi a` doesn't matter for theorems about Lebesgue measure,
it becomes important in the versions of FTC about any locally finite measure if this measure has an
atom at one of the endpoints.

### Combining one-sided and two-sided derivatives

There are some `FTC_filter` instances where the fact that it is one-sided or
two-sided depends on the point, namely `(x, 𝓝[Icc a b] x, 𝓝[Icc a b] x)`
(resp. `(x, 𝓝[[a, b]] x, 𝓝[[a, b]] x)`, where `[a, b] = set.interval a b`),
with `x ∈ Icc a b` (resp. `x ∈ [a, b]`).
This results in a two-sided derivatives for `x ∈ Ioo a b` and one-sided derivatives for
`x ∈ {a, b}`. Other instances could be added when needed (in that case, one also needs to add
instances for `filter.is_measurably_generated` and `filter.tendsto_Ixx_class`).

## Tags

integral, fundamental theorem of calculus, FTC-1, FTC-2, change of variables in integrals
-/


noncomputable theory

open topological_space(SecondCountableTopology)

open MeasureTheory Set Classical Filter Function

open_locale Classical TopologicalSpace Filter Ennreal BigOperators Interval

variable{α β 𝕜 E F : Type _}[LinearOrderₓ α][MeasurableSpace α][MeasurableSpace E][NormedGroup E]

/-!
### Almost everywhere on an interval
-/


section 

variable{μ : Measureₓ α}{a b : α}{P : α → Prop}

theorem ae_interval_oc_iff : (∀ᵐx ∂μ, x ∈ Ι a b → P x) ↔ (∀ᵐx ∂μ, x ∈ Ioc a b → P x) ∧ ∀ᵐx ∂μ, x ∈ Ioc b a → P x :=
  by 
    dsimp [interval_oc]
    cases' le_totalₓ a b with hab hab <;> simp [hab]

theorem ae_measurable_interval_oc_iff {μ : Measureₓ α} {β : Type _} [MeasurableSpace β] {f : α → β} :
  (AeMeasurable f$ μ.restrict$ Ι a b) ↔ (AeMeasurable f$ μ.restrict$ Ioc a b) ∧ (AeMeasurable f$ μ.restrict$ Ioc b a) :=
  by 
    dsimp [interval_oc]
    cases' le_totalₓ a b with hab hab <;> simp [hab]

variable[TopologicalSpace α][OpensMeasurableSpace α][OrderClosedTopology α]

theorem ae_interval_oc_iff' :
  (∀ᵐx ∂μ, x ∈ Ι a b → P x) ↔ (∀ᵐx ∂μ.restrict$ Ioc a b, P x) ∧ ∀ᵐx ∂μ.restrict$ Ioc b a, P x :=
  by 
    simpRw [ae_interval_oc_iff]
    rw [ae_restrict_eq, eventually_inf_principal, ae_restrict_eq, eventually_inf_principal] <;> exact measurable_set_Ioc

end 

/-!
### Integrability at an interval
-/


/-- A function `f` is called *interval integrable* with respect to a measure `μ` on an unordered
interval `a..b` if it is integrable on both intervals `(a, b]` and `(b, a]`. One of these
intervals is always empty, so this property is equivalent to `f` being integrable on
`(min a b, max a b]`. -/
def IntervalIntegrable (f : α → E) (μ : Measureₓ α) (a b : α) :=
  integrable_on f (Ioc a b) μ ∧ integrable_on f (Ioc b a) μ

/-- A function is interval integrable with respect to a given measure `μ` on `interval a b` if and
  only if it is integrable on `interval_oc a b` with respect to `μ`. This is an equivalent
  defintion of `interval_integrable`. -/
theorem interval_integrable_iff {f : α → E} {a b : α} {μ : Measureₓ α} :
  IntervalIntegrable f μ a b ↔ integrable_on f (Ι a b) μ :=
  by 
    cases le_totalₓ a b <;> simp [h, IntervalIntegrable, interval_oc]

/-- If a function is interval integrable with respect to a given measure `μ` on `interval a b` then
  it is integrable on `interval_oc a b` with respect to `μ`. -/
theorem IntervalIntegrable.def {f : α → E} {a b : α} {μ : Measureₓ α} (h : IntervalIntegrable f μ a b) :
  integrable_on f (Ι a b) μ :=
  interval_integrable_iff.mp h

theorem interval_integrable_iff_integrable_Ioc_of_le {f : α → E} {a b : α} (hab : a ≤ b) {μ : Measureₓ α} :
  IntervalIntegrable f μ a b ↔ integrable_on f (Ioc a b) μ :=
  by 
    rw [interval_integrable_iff, interval_oc_of_le hab]

/-- If a function is integrable with respect to a given measure `μ` then it is interval integrable
  with respect to `μ` on `interval a b`. -/
theorem MeasureTheory.Integrable.interval_integrable {f : α → E} {a b : α} {μ : Measureₓ α} (hf : integrable f μ) :
  IntervalIntegrable f μ a b :=
  ⟨hf.integrable_on, hf.integrable_on⟩

theorem MeasureTheory.IntegrableOn.interval_integrable {f : α → E} {a b : α} {μ : Measureₓ α}
  (hf : integrable_on f (interval a b) μ) : IntervalIntegrable f μ a b :=
  ⟨MeasureTheory.IntegrableOn.mono_set hf (Ioc_subset_Icc_self.trans Icc_subset_interval),
    MeasureTheory.IntegrableOn.mono_set hf (Ioc_subset_Icc_self.trans Icc_subset_interval')⟩

theorem interval_integrable_const_iff {a b : α} {μ : Measureₓ α} {c : E} :
  IntervalIntegrable (fun _ => c) μ a b ↔ c = 0 ∨ μ (Ι a b) < ∞ :=
  by 
    simp only [interval_integrable_iff, integrable_on_const]

@[simp]
theorem interval_integrable_const [TopologicalSpace α] [CompactIccSpace α] {μ : Measureₓ α}
  [is_locally_finite_measure μ] {a b : α} {c : E} : IntervalIntegrable (fun _ => c) μ a b :=
  interval_integrable_const_iff.2$ Or.inr measure_Ioc_lt_top

namespace IntervalIntegrable

section 

variable{f : α → E}{a b c d : α}{μ ν : Measureₓ α}

@[symm]
theorem symm (h : IntervalIntegrable f μ a b) : IntervalIntegrable f μ b a :=
  h.symm

@[refl]
theorem refl : IntervalIntegrable f μ a a :=
  by 
    split  <;> simp 

@[trans]
theorem trans (hab : IntervalIntegrable f μ a b) (hbc : IntervalIntegrable f μ b c) : IntervalIntegrable f μ a c :=
  ⟨(hab.1.union hbc.1).mono_set Ioc_subset_Ioc_union_Ioc, (hbc.2.union hab.2).mono_set Ioc_subset_Ioc_union_Ioc⟩

theorem trans_iterate {a : ℕ → α} {n : ℕ} (hint : ∀ k (_ : k < n), IntervalIntegrable f μ (a k) (a$ k+1)) :
  IntervalIntegrable f μ (a 0) (a n) :=
  by 
    induction' n with n hn
    ·
      simp 
    ·
      exact (hn fun k hk => hint k (hk.trans n.lt_succ_self)).trans (hint n n.lt_succ_self)

theorem neg [BorelSpace E] (h : IntervalIntegrable f μ a b) : IntervalIntegrable (-f) μ a b :=
  ⟨h.1.neg, h.2.neg⟩

theorem norm [OpensMeasurableSpace E] (h : IntervalIntegrable f μ a b) : IntervalIntegrable (fun x => ∥f x∥) μ a b :=
  ⟨h.1.norm, h.2.norm⟩

theorem abs {f : α → ℝ} (h : IntervalIntegrable f μ a b) : IntervalIntegrable (fun x => |f x|) μ a b :=
  h.norm

theorem mono (hf : IntervalIntegrable f ν a b) (h1 : interval c d ⊆ interval a b) (h2 : μ ≤ ν) :
  IntervalIntegrable f μ c d :=
  let ⟨h1₁, h1₂⟩ := interval_subset_interval_iff_le.mp h1 
  interval_integrable_iff.mpr$ hf.def.mono (Ioc_subset_Ioc h1₁ h1₂) h2

theorem mono_set (hf : IntervalIntegrable f μ a b) (h : interval c d ⊆ interval a b) : IntervalIntegrable f μ c d :=
  hf.mono h rfl.le

theorem mono_measure (hf : IntervalIntegrable f ν a b) (h : μ ≤ ν) : IntervalIntegrable f μ a b :=
  hf.mono rfl.Subset h

theorem mono_set_ae (hf : IntervalIntegrable f μ a b) (h : Ι c d ≤ᵐ[μ] Ι a b) : IntervalIntegrable f μ c d :=
  interval_integrable_iff.mpr$ hf.def.mono_set_ae h

protected theorem AeMeasurable (h : IntervalIntegrable f μ a b) : AeMeasurable f (μ.restrict (Ioc a b)) :=
  h.1.AeMeasurable

protected theorem ae_measurable' (h : IntervalIntegrable f μ a b) : AeMeasurable f (μ.restrict (Ioc b a)) :=
  h.2.AeMeasurable

end 

variable[BorelSpace E]{f g : α → E}{a b : α}{μ : Measureₓ α}

theorem smul [NormedField 𝕜] [NormedSpace 𝕜 E] [MeasurableSpace 𝕜] [OpensMeasurableSpace 𝕜] {f : α → E} {a b : α}
  {μ : Measureₓ α} (h : IntervalIntegrable f μ a b) (r : 𝕜) : IntervalIntegrable (r • f) μ a b :=
  ⟨h.1.smul r, h.2.smul r⟩

@[simp]
theorem add [second_countable_topology E] (hf : IntervalIntegrable f μ a b) (hg : IntervalIntegrable g μ a b) :
  IntervalIntegrable (fun x => f x+g x) μ a b :=
  ⟨hf.1.add hg.1, hf.2.add hg.2⟩

@[simp]
theorem sub [second_countable_topology E] (hf : IntervalIntegrable f μ a b) (hg : IntervalIntegrable g μ a b) :
  IntervalIntegrable (fun x => f x - g x) μ a b :=
  ⟨hf.1.sub hg.1, hf.2.sub hg.2⟩

theorem mul_continuous_on {α : Type _} [ConditionallyCompleteLinearOrder α] [MeasurableSpace α] [TopologicalSpace α]
  [OrderTopology α] [OpensMeasurableSpace α] {μ : Measureₓ α} {a b : α} {f g : α → ℝ} (hf : IntervalIntegrable f μ a b)
  (hg : ContinuousOn g (interval a b)) : IntervalIntegrable (fun x => f x*g x) μ a b :=
  by 
    rw [interval_integrable_iff] at hf⊢
    exact hf.mul_continuous_on_of_subset hg measurable_set_Ioc is_compact_interval Ioc_subset_Icc_self

theorem continuous_on_mul {α : Type _} [ConditionallyCompleteLinearOrder α] [MeasurableSpace α] [TopologicalSpace α]
  [OrderTopology α] [OpensMeasurableSpace α] {μ : Measureₓ α} {a b : α} {f g : α → ℝ} (hf : IntervalIntegrable f μ a b)
  (hg : ContinuousOn g (interval a b)) : IntervalIntegrable (fun x => g x*f x) μ a b :=
  by 
    simpa [mul_commₓ] using hf.mul_continuous_on hg

end IntervalIntegrable

section 

variable{μ : Measureₓ ℝ}[is_locally_finite_measure μ]

theorem ContinuousOn.interval_integrable [BorelSpace E] {u : ℝ → E} {a b : ℝ} (hu : ContinuousOn u (interval a b)) :
  IntervalIntegrable u μ a b :=
  (ContinuousOn.integrable_on_Icc hu).IntervalIntegrable

theorem ContinuousOn.interval_integrable_of_Icc [BorelSpace E] {u : ℝ → E} {a b : ℝ} (h : a ≤ b)
  (hu : ContinuousOn u (Icc a b)) : IntervalIntegrable u μ a b :=
  ContinuousOn.interval_integrable ((interval_of_le h).symm ▸ hu)

/-- A continuous function on `ℝ` is `interval_integrable` with respect to any locally finite measure
`ν` on ℝ. -/
theorem Continuous.interval_integrable [BorelSpace E] {u : ℝ → E} (hu : Continuous u) (a b : ℝ) :
  IntervalIntegrable u μ a b :=
  hu.continuous_on.interval_integrable

end 

section 

variable{ι :
    Type
      _}[TopologicalSpace
      ι][ConditionallyCompleteLinearOrder
      ι][OrderTopology
      ι][MeasurableSpace
      ι][BorelSpace
      ι]{μ :
    Measureₓ
      ι}[is_locally_finite_measure
      μ][ConditionallyCompleteLinearOrder E][OrderTopology E][second_countable_topology E][BorelSpace E]

theorem MonotoneOn.interval_integrable {u : ι → E} {a b : ι} (hu : MonotoneOn u (interval a b)) :
  IntervalIntegrable u μ a b :=
  by 
    rw [interval_integrable_iff]
    exact (MonotoneOn.integrable_on_compact is_compact_interval hu).mono_set Ioc_subset_Icc_self

theorem AntitoneOn.interval_integrable {u : ι → E} {a b : ι} (hu : AntitoneOn u (interval a b)) :
  IntervalIntegrable u μ a b :=
  @MonotoneOn.interval_integrable (OrderDual E) _ ‹_› ι _ _ _ _ _ _ _ _ _ ‹_› ‹_› u a b hu

theorem Monotone.interval_integrable {u : ι → E} {a b : ι} (hu : Monotone u) : IntervalIntegrable u μ a b :=
  (hu.monotone_on _).IntervalIntegrable

theorem Antitone.interval_integrable {u : ι → E} {a b : ι} (hu : Antitone u) : IntervalIntegrable u μ a b :=
  (hu.antitone_on _).IntervalIntegrable

end 

/-- Let `l'` be a measurably generated filter; let `l` be a of filter such that each `s ∈ l'`
eventually includes `Ioc u v` as both `u` and `v` tend to `l`. Let `μ` be a measure finite at `l'`.

Suppose that `f : α → E` has a finite limit at `l' ⊓ μ.ae`. Then `f` is interval integrable on
`u..v` provided that both `u` and `v` tend to `l`.

Typeclass instances allow Lean to find `l'` based on `l` but not vice versa, so
`apply tendsto.eventually_interval_integrable_ae` will generate goals `filter α` and
`tendsto_Ixx_class Ioc ?m_1 l'`. -/
theorem Filter.Tendsto.eventually_interval_integrable_ae {f : α → E} {μ : Measureₓ α} {l l' : Filter α}
  (hfm : MeasurableAtFilter f l' μ) [tendsto_Ixx_class Ioc l l'] [is_measurably_generated l']
  (hμ : μ.finite_at_filter l') {c : E} (hf : tendsto f (l'⊓μ.ae) (𝓝 c)) {u v : β → α} {lt : Filter β}
  (hu : tendsto u lt l) (hv : tendsto v lt l) : ∀ᶠt in lt, IntervalIntegrable f μ (u t) (v t) :=
  have  := (hf.integrable_at_filter_ae hfm hμ).Eventually
  ((hu.Ioc hv).Eventually this).And$ (hv.Ioc hu).Eventually this

/-- Let `l'` be a measurably generated filter; let `l` be a of filter such that each `s ∈ l'`
eventually includes `Ioc u v` as both `u` and `v` tend to `l`. Let `μ` be a measure finite at `l'`.

Suppose that `f : α → E` has a finite limit at `l`. Then `f` is interval integrable on `u..v`
provided that both `u` and `v` tend to `l`.

Typeclass instances allow Lean to find `l'` based on `l` but not vice versa, so
`apply tendsto.eventually_interval_integrable_ae` will generate goals `filter α` and
`tendsto_Ixx_class Ioc ?m_1 l'`. -/
theorem Filter.Tendsto.eventually_interval_integrable {f : α → E} {μ : Measureₓ α} {l l' : Filter α}
  (hfm : MeasurableAtFilter f l' μ) [tendsto_Ixx_class Ioc l l'] [is_measurably_generated l']
  (hμ : μ.finite_at_filter l') {c : E} (hf : tendsto f l' (𝓝 c)) {u v : β → α} {lt : Filter β} (hu : tendsto u lt l)
  (hv : tendsto v lt l) : ∀ᶠt in lt, IntervalIntegrable f μ (u t) (v t) :=
  (hf.mono_left inf_le_left).eventually_interval_integrable_ae hfm hμ hu hv

/-!
### Interval integral: definition and basic properties

In this section we define `∫ x in a..b, f x ∂μ` as `∫ x in Ioc a b, f x ∂μ - ∫ x in Ioc b a, f x ∂μ`
and prove some basic properties.
-/


variable[second_countable_topology E][CompleteSpace E][NormedSpace ℝ E][BorelSpace E]

/-- The interval integral `∫ x in a..b, f x ∂μ` is defined
as `∫ x in Ioc a b, f x ∂μ - ∫ x in Ioc b a, f x ∂μ`. If `a ≤ b`, then it equals
`∫ x in Ioc a b, f x ∂μ`, otherwise it equals `-∫ x in Ioc b a, f x ∂μ`. -/
def intervalIntegral (f : α → E) (a b : α) (μ : Measureₓ α) :=
  (∫x in Ioc a b, f x ∂μ) - ∫x in Ioc b a, f x ∂μ

notation3  "∫" (...) " in " a ".." b ", " r:(scoped f => f) " ∂" μ => intervalIntegral r a b μ

notation3  "∫" (...) " in " a ".." b ", " r:(scoped f => intervalIntegral f a b volume) => r

namespace intervalIntegral

section Basic

variable{a b : α}{f g : α → E}{μ : Measureₓ α}

@[simp]
theorem integral_zero : (∫x in a..b, (0 : E) ∂μ) = 0 :=
  by 
    simp [intervalIntegral]

theorem integral_of_le (h : a ≤ b) : (∫x in a..b, f x ∂μ) = ∫x in Ioc a b, f x ∂μ :=
  by 
    simp [intervalIntegral, h]

@[simp]
theorem integral_same : (∫x in a..a, f x ∂μ) = 0 :=
  sub_self _

theorem integral_symm a b : (∫x in b..a, f x ∂μ) = -∫x in a..b, f x ∂μ :=
  by 
    simp only [intervalIntegral, neg_sub]

theorem integral_of_ge (h : b ≤ a) : (∫x in a..b, f x ∂μ) = -∫x in Ioc b a, f x ∂μ :=
  by 
    simp only [integral_symm b, integral_of_le h]

theorem interval_integral_eq_integral_interval_oc (f : α → E) (a b : α) (μ : Measureₓ α) :
  (∫x in a..b, f x ∂μ) = (if a ≤ b then 1 else -1 : ℝ) • ∫x in Ι a b, f x ∂μ :=
  by 
    splitIfs with h
    ·
      simp only [integral_of_le h, interval_oc_of_le h, one_smul]
    ·
      simp only [integral_of_ge (not_leₓ.1 h).le, interval_oc_of_lt (not_leₓ.1 h), neg_one_smul]

theorem integral_cases (f : α → E) a b : (∫x in a..b, f x ∂μ) ∈ ({∫x in Ι a b, f x ∂μ, -∫x in Ι a b, f x ∂μ} : Set E) :=
  by 
    rw [interval_integral_eq_integral_interval_oc]
    splitIfs <;> simp 

theorem integral_undef (h : ¬IntervalIntegrable f μ a b) : (∫x in a..b, f x ∂μ) = 0 :=
  by 
    cases' le_totalₓ a b with hab hab <;>
      simp only [integral_of_le, integral_of_ge, hab, neg_eq_zero] <;>
        refine' integral_undef (not_imp_not.mpr integrable.integrable_on' _) <;> simpa [hab] using not_and_distrib.mp h

theorem integral_non_ae_measurable (hf : ¬AeMeasurable f (μ.restrict (Ι a b))) : (∫x in a..b, f x ∂μ) = 0 :=
  by 
    rw [interval_integral_eq_integral_interval_oc, integral_non_ae_measurable hf, smul_zero]

theorem integral_non_ae_measurable_of_le (h : a ≤ b) (hf : ¬AeMeasurable f (μ.restrict (Ioc a b))) :
  (∫x in a..b, f x ∂μ) = 0 :=
  integral_non_ae_measurable$
    by 
      rwa [interval_oc_of_le h]

theorem norm_integral_eq_norm_integral_Ioc : ∥∫x in a..b, f x ∂μ∥ = ∥∫x in Ι a b, f x ∂μ∥ :=
  (integral_cases f a b).elim (congr_argₓ _) fun h => (congr_argₓ _ h).trans (norm_neg _)

theorem norm_integral_le_integral_norm_Ioc : ∥∫x in a..b, f x ∂μ∥ ≤ ∫x in Ι a b, ∥f x∥ ∂μ :=
  calc ∥∫x in a..b, f x ∂μ∥ = ∥∫x in Ι a b, f x ∂μ∥ := norm_integral_eq_norm_integral_Ioc 
    _ ≤ ∫x in Ι a b, ∥f x∥ ∂μ := norm_integral_le_integral_norm f
    

theorem norm_integral_le_abs_integral_norm : ∥∫x in a..b, f x ∂μ∥ ≤ |∫x in a..b, ∥f x∥ ∂μ| :=
  by 
    simp only [←Real.norm_eq_abs, norm_integral_eq_norm_integral_Ioc]
    exact le_transₓ (norm_integral_le_integral_norm _) (le_abs_self _)

theorem norm_integral_le_integral_norm (h : a ≤ b) : ∥∫x in a..b, f x ∂μ∥ ≤ ∫x in a..b, ∥f x∥ ∂μ :=
  norm_integral_le_integral_norm_Ioc.trans_eq$
    by 
      rw [interval_oc_of_le h, integral_of_le h]

theorem norm_integral_le_of_norm_le_const_ae {a b C : ℝ} {f : ℝ → E} (h : ∀ᵐx, x ∈ Ι a b → ∥f x∥ ≤ C) :
  ∥∫x in a..b, f x∥ ≤ C*|b - a| :=
  by 
    rw [norm_integral_eq_norm_integral_Ioc]
    convert norm_set_integral_le_of_norm_le_const_ae'' _ measurable_set_Ioc h
    ·
      rw [Real.volume_Ioc, max_sub_min_eq_abs, Ennreal.to_real_of_real (abs_nonneg _)]
    ·
      simp only [Real.volume_Ioc, Ennreal.of_real_lt_top]

theorem norm_integral_le_of_norm_le_const {a b C : ℝ} {f : ℝ → E} (h : ∀ x (_ : x ∈ Ι a b), ∥f x∥ ≤ C) :
  ∥∫x in a..b, f x∥ ≤ C*|b - a| :=
  norm_integral_le_of_norm_le_const_ae$ eventually_of_forall h

@[simp]
theorem integral_add (hf : IntervalIntegrable f μ a b) (hg : IntervalIntegrable g μ a b) :
  (∫x in a..b, f x+g x ∂μ) = (∫x in a..b, f x ∂μ)+∫x in a..b, g x ∂μ :=
  by 
    simp only [interval_integral_eq_integral_interval_oc, integral_add hf.def hg.def, smul_add]

theorem integral_finset_sum {ι} {s : Finset ι} {f : ι → α → E} (h : ∀ i (_ : i ∈ s), IntervalIntegrable (f i) μ a b) :
  (∫x in a..b, ∑i in s, f i x ∂μ) = ∑i in s, ∫x in a..b, f i x ∂μ :=
  by 
    simp only [interval_integral_eq_integral_interval_oc, integral_finset_sum s fun i hi => (h i hi).def,
      Finset.smul_sum]

@[simp]
theorem integral_neg : (∫x in a..b, -f x ∂μ) = -∫x in a..b, f x ∂μ :=
  by 
    simp only [intervalIntegral, integral_neg]
    abel

@[simp]
theorem integral_sub (hf : IntervalIntegrable f μ a b) (hg : IntervalIntegrable g μ a b) :
  (∫x in a..b, f x - g x ∂μ) = (∫x in a..b, f x ∂μ) - ∫x in a..b, g x ∂μ :=
  by 
    simpa only [sub_eq_add_neg] using (integral_add hf hg.neg).trans (congr_argₓ _ integral_neg)

@[simp]
theorem integral_smul {𝕜 : Type _} [NondiscreteNormedField 𝕜] [NormedSpace 𝕜 E] [SmulCommClass ℝ 𝕜 E]
  [MeasurableSpace 𝕜] [OpensMeasurableSpace 𝕜] (r : 𝕜) (f : α → E) :
  (∫x in a..b, r • f x ∂μ) = r • ∫x in a..b, f x ∂μ :=
  by 
    simp only [intervalIntegral, integral_smul, smul_sub]

@[simp]
theorem integral_smul_const {𝕜 : Type _} [IsROrC 𝕜] [NormedSpace 𝕜 E] [IsScalarTower ℝ 𝕜 E] [MeasurableSpace 𝕜]
  [BorelSpace 𝕜] (f : α → 𝕜) (c : E) : (∫x in a..b, f x • c ∂μ) = (∫x in a..b, f x ∂μ) • c :=
  by 
    simp only [interval_integral_eq_integral_interval_oc, integral_smul_const, smul_assoc]

@[simp]
theorem integral_const_mul {𝕜 : Type _} [IsROrC 𝕜] [MeasurableSpace 𝕜] [BorelSpace 𝕜] (r : 𝕜) (f : α → 𝕜) :
  (∫x in a..b, r*f x ∂μ) = r*∫x in a..b, f x ∂μ :=
  integral_smul r f

@[simp]
theorem integral_mul_const {𝕜 : Type _} [IsROrC 𝕜] [MeasurableSpace 𝕜] [BorelSpace 𝕜] (r : 𝕜) (f : α → 𝕜) :
  (∫x in a..b, f x*r ∂μ) = (∫x in a..b, f x ∂μ)*r :=
  by 
    simpa only [mul_commₓ r] using integral_const_mul r f

@[simp]
theorem integral_div {𝕜 : Type _} [IsROrC 𝕜] [MeasurableSpace 𝕜] [BorelSpace 𝕜] (r : 𝕜) (f : α → 𝕜) :
  (∫x in a..b, f x / r ∂μ) = (∫x in a..b, f x ∂μ) / r :=
  by 
    simpa only [div_eq_mul_inv] using integral_mul_const (r⁻¹) f

theorem integral_const' (c : E) : (∫x in a..b, c ∂μ) = ((μ$ Ioc a b).toReal - (μ$ Ioc b a).toReal) • c :=
  by 
    simp only [intervalIntegral, set_integral_const, sub_smul]

@[simp]
theorem integral_const {a b : ℝ} (c : E) : (∫x in a..b, c) = (b - a) • c :=
  by 
    simp only [integral_const', Real.volume_Ioc, Ennreal.to_real_of_real', ←neg_sub b, max_zero_sub_eq_self]

theorem integral_smul_measure (c : ℝ≥0∞) : (∫x in a..b, f x ∂c • μ) = c.to_real • ∫x in a..b, f x ∂μ :=
  by 
    simp only [intervalIntegral, measure.restrict_smul, integral_smul_measure, smul_sub]

variable[NormedGroup F][second_countable_topology F][CompleteSpace F][NormedSpace ℝ F][MeasurableSpace F][BorelSpace F]

theorem _root_.continuous_linear_map.interval_integral_comp_comm (L : E →L[ℝ] F) (hf : IntervalIntegrable f μ a b) :
  (∫x in a..b, L (f x) ∂μ) = L (∫x in a..b, f x ∂μ) :=
  by 
    rw [intervalIntegral, intervalIntegral, L.integral_comp_comm, L.integral_comp_comm, L.map_sub]
    exacts[hf.2, hf.1]

end Basic

section Comp

variable{a b c d : ℝ}(f : ℝ → E)

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem integral_comp_mul_right
(hc : «expr ≠ »(c, 0)) : «expr = »(«expr∫ in .. , »((x), a, b, f «expr * »(x, c)), «expr • »(«expr ⁻¹»(c), «expr∫ in .. , »((x), «expr * »(a, c), «expr * »(b, c), f x))) :=
begin
  have [ident A] [":", expr measurable_embedding (λ
    x, «expr * »(x, c))] [":=", expr (homeomorph.mul_right₀ c hc).closed_embedding.measurable_embedding],
  conv_rhs [] [] { rw ["[", "<-", expr real.smul_map_volume_mul_right hc, "]"] },
  simp_rw ["[", expr integral_smul_measure, ",", expr interval_integral, ",", expr A.set_integral_map, ",", expr ennreal.to_real_of_real (abs_nonneg c), "]"] [],
  cases [expr hc.lt_or_lt] [],
  { simp [] [] [] ["[", expr h, ",", expr mul_div_cancel, ",", expr hc, ",", expr abs_of_neg, ",", expr restrict_congr_set Ico_ae_eq_Ioc, "]"] [] [] },
  { simp [] [] [] ["[", expr h, ",", expr mul_div_cancel, ",", expr hc, ",", expr abs_of_pos, "]"] [] [] }
end

@[simp]
theorem smul_integral_comp_mul_right c : (c • ∫x in a..b, f (x*c)) = ∫x in a*c..b*c, f x :=
  by 
    byCases' hc : c = 0 <;> simp [hc]

@[simp]
theorem integral_comp_mul_left (hc : c ≠ 0) : (∫x in a..b, f (c*x)) = c⁻¹ • ∫x in c*a..c*b, f x :=
  by 
    simpa only [mul_commₓ c] using integral_comp_mul_right f hc

@[simp]
theorem smul_integral_comp_mul_left c : (c • ∫x in a..b, f (c*x)) = ∫x in c*a..c*b, f x :=
  by 
    byCases' hc : c = 0 <;> simp [hc]

@[simp]
theorem integral_comp_div (hc : c ≠ 0) : (∫x in a..b, f (x / c)) = c • ∫x in a / c..b / c, f x :=
  by 
    simpa only [inv_inv₀] using integral_comp_mul_right f (inv_ne_zero hc)

@[simp]
theorem inv_smul_integral_comp_div c : (c⁻¹ • ∫x in a..b, f (x / c)) = ∫x in a / c..b / c, f x :=
  by 
    byCases' hc : c = 0 <;> simp [hc]

@[simp]
theorem integral_comp_add_right d : (∫x in a..b, f (x+d)) = ∫x in a+d..b+d, f x :=
  have A : MeasurableEmbedding fun x => x+d := (Homeomorph.addRight d).ClosedEmbedding.MeasurableEmbedding 
  calc (∫x in a..b, f (x+d)) = ∫x in a+d..b+d, f x ∂measure.map (fun x => x+d) volume :=
    by 
      simp [intervalIntegral, A.set_integral_map]
    _ = ∫x in a+d..b+d, f x :=
    by 
      rw [Real.map_volume_add_right]
    

@[simp]
theorem integral_comp_add_left d : (∫x in a..b, f (d+x)) = ∫x in d+a..d+b, f x :=
  by 
    simpa only [add_commₓ] using integral_comp_add_right f d

@[simp]
theorem integral_comp_mul_add (hc : c ≠ 0) d : (∫x in a..b, f ((c*x)+d)) = c⁻¹ • ∫x in (c*a)+d..(c*b)+d, f x :=
  by 
    rw [←integral_comp_add_right, ←integral_comp_mul_left _ hc]

@[simp]
theorem smul_integral_comp_mul_add c d : (c • ∫x in a..b, f ((c*x)+d)) = ∫x in (c*a)+d..(c*b)+d, f x :=
  by 
    byCases' hc : c = 0 <;> simp [hc]

@[simp]
theorem integral_comp_add_mul (hc : c ≠ 0) d : (∫x in a..b, f (d+c*x)) = c⁻¹ • ∫x in d+c*a..d+c*b, f x :=
  by 
    rw [←integral_comp_add_left, ←integral_comp_mul_left _ hc]

@[simp]
theorem smul_integral_comp_add_mul c d : (c • ∫x in a..b, f (d+c*x)) = ∫x in d+c*a..d+c*b, f x :=
  by 
    byCases' hc : c = 0 <;> simp [hc]

@[simp]
theorem integral_comp_div_add (hc : c ≠ 0) d : (∫x in a..b, f ((x / c)+d)) = c • ∫x in (a / c)+d..(b / c)+d, f x :=
  by 
    simpa only [div_eq_inv_mul, inv_inv₀] using integral_comp_mul_add f (inv_ne_zero hc) d

@[simp]
theorem inv_smul_integral_comp_div_add c d : (c⁻¹ • ∫x in a..b, f ((x / c)+d)) = ∫x in (a / c)+d..(b / c)+d, f x :=
  by 
    byCases' hc : c = 0 <;> simp [hc]

@[simp]
theorem integral_comp_add_div (hc : c ≠ 0) d : (∫x in a..b, f (d+x / c)) = c • ∫x in d+a / c..d+b / c, f x :=
  by 
    simpa only [div_eq_inv_mul, inv_inv₀] using integral_comp_add_mul f (inv_ne_zero hc) d

@[simp]
theorem inv_smul_integral_comp_add_div c d : (c⁻¹ • ∫x in a..b, f (d+x / c)) = ∫x in d+a / c..d+b / c, f x :=
  by 
    byCases' hc : c = 0 <;> simp [hc]

@[simp]
theorem integral_comp_mul_sub (hc : c ≠ 0) d : (∫x in a..b, f ((c*x) - d)) = c⁻¹ • ∫x in (c*a) - d..(c*b) - d, f x :=
  by 
    simpa only [sub_eq_add_neg] using integral_comp_mul_add f hc (-d)

@[simp]
theorem smul_integral_comp_mul_sub c d : (c • ∫x in a..b, f ((c*x) - d)) = ∫x in (c*a) - d..(c*b) - d, f x :=
  by 
    byCases' hc : c = 0 <;> simp [hc]

@[simp]
theorem integral_comp_sub_mul (hc : c ≠ 0) d : (∫x in a..b, f (d - c*x)) = c⁻¹ • ∫x in d - c*b..d - c*a, f x :=
  by 
    simp only [sub_eq_add_neg, neg_mul_eq_neg_mul]
    rw [integral_comp_add_mul f (neg_ne_zero.mpr hc) d, integral_symm]
    simp only [inv_neg, smul_neg, neg_negₓ, neg_smul]

@[simp]
theorem smul_integral_comp_sub_mul c d : (c • ∫x in a..b, f (d - c*x)) = ∫x in d - c*b..d - c*a, f x :=
  by 
    byCases' hc : c = 0 <;> simp [hc]

@[simp]
theorem integral_comp_div_sub (hc : c ≠ 0) d : (∫x in a..b, f (x / c - d)) = c • ∫x in a / c - d..b / c - d, f x :=
  by 
    simpa only [div_eq_inv_mul, inv_inv₀] using integral_comp_mul_sub f (inv_ne_zero hc) d

@[simp]
theorem inv_smul_integral_comp_div_sub c d : (c⁻¹ • ∫x in a..b, f (x / c - d)) = ∫x in a / c - d..b / c - d, f x :=
  by 
    byCases' hc : c = 0 <;> simp [hc]

@[simp]
theorem integral_comp_sub_div (hc : c ≠ 0) d : (∫x in a..b, f (d - x / c)) = c • ∫x in d - b / c..d - a / c, f x :=
  by 
    simpa only [div_eq_inv_mul, inv_inv₀] using integral_comp_sub_mul f (inv_ne_zero hc) d

@[simp]
theorem inv_smul_integral_comp_sub_div c d : (c⁻¹ • ∫x in a..b, f (d - x / c)) = ∫x in d - b / c..d - a / c, f x :=
  by 
    byCases' hc : c = 0 <;> simp [hc]

@[simp]
theorem integral_comp_sub_right d : (∫x in a..b, f (x - d)) = ∫x in a - d..b - d, f x :=
  by 
    simpa only [sub_eq_add_neg] using integral_comp_add_right f (-d)

@[simp]
theorem integral_comp_sub_left d : (∫x in a..b, f (d - x)) = ∫x in d - b..d - a, f x :=
  by 
    simpa only [one_mulₓ, one_smul, inv_one] using integral_comp_sub_mul f one_ne_zero d

@[simp]
theorem integral_comp_neg : (∫x in a..b, f (-x)) = ∫x in -b..-a, f x :=
  by 
    simpa only [zero_sub] using integral_comp_sub_left f 0

end Comp

/-!
### Integral is an additive function of the interval

In this section we prove that `∫ x in a..b, f x ∂μ + ∫ x in b..c, f x ∂μ = ∫ x in a..c, f x ∂μ`
as well as a few other identities trivially equivalent to this one. We also prove that
`∫ x in a..b, f x ∂μ = ∫ x, f x ∂μ` provided that `support f ⊆ Ioc a b`.
-/


section OrderClosedTopology

variable[TopologicalSpace α][OrderClosedTopology α][OpensMeasurableSpace α]{a b c d : α}{f g : α → E}{μ : Measureₓ α}

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem integrable_on_Icc_iff_integrable_on_Ioc'
{E : Type*}
[measurable_space E]
[normed_group E]
{f : α → E}
{a b : α}
(ha : «expr ≠ »(μ {a}, «expr⊤»())) : «expr ↔ »(integrable_on f (Icc a b) μ, integrable_on f (Ioc a b) μ) :=
begin
  cases [expr le_or_lt a b] ["with", ident hab, ident hab],
  { have [] [":", expr «expr = »(Icc a b, «expr ∪ »(Icc a a, Ioc a b))] [":=", expr (Icc_union_Ioc_eq_Icc le_rfl hab).symm],
    rw ["[", expr this, ",", expr integrable_on_union, "]"] [],
    simp [] [] [] ["[", expr lt_top_iff_ne_top.2 ha, "]"] [] [] },
  { simp [] [] [] ["[", expr hab, ",", expr hab.le, "]"] [] [] }
end

theorem integrable_on_Icc_iff_integrable_on_Ioc {E : Type _} [MeasurableSpace E] [NormedGroup E] [has_no_atoms μ]
  {f : α → E} {a b : α} : integrable_on f (Icc a b) μ ↔ integrable_on f (Ioc a b) μ :=
  integrable_on_Icc_iff_integrable_on_Ioc'
    (by 
      simp )

theorem interval_integrable_iff_integrable_Icc_of_le {E : Type _} [MeasurableSpace E] [NormedGroup E] {f : α → E}
  {a b : α} (hab : a ≤ b) {μ : Measureₓ α} [has_no_atoms μ] :
  IntervalIntegrable f μ a b ↔ integrable_on f (Icc a b) μ :=
  by 
    rw [interval_integrable_iff_integrable_Ioc_of_le hab, integrable_on_Icc_iff_integrable_on_Ioc]

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem integral_Icc_eq_integral_Ioc'
{f : α → E}
{a b : α}
(ha : «expr = »(μ {a}, 0)) : «expr = »(«expr∫ in , ∂ »((t), Icc a b, f t, μ), «expr∫ in , ∂ »((t), Ioc a b, f t, μ)) :=
begin
  cases [expr le_or_lt a b] ["with", ident hab, ident hab],
  { have [] [":", expr «expr = »(μ.restrict (Icc a b), μ.restrict (Ioc a b))] [],
    { rw ["[", "<-", expr Ioc_union_left hab, ",", expr measure_theory.measure.restrict_union _ measurable_set_Ioc (measurable_set_singleton a), "]"] [],
      { simp [] [] [] ["[", expr measure_theory.measure.restrict_zero_set ha, "]"] [] [] },
      { simp [] [] [] [] [] [] } },
    rw [expr this] [] },
  { simp [] [] [] ["[", expr hab, ",", expr hab.le, "]"] [] [] }
end

theorem integral_Icc_eq_integral_Ioc {f : α → E} {a b : α} [has_no_atoms μ] :
  (∫t in Icc a b, f t ∂μ) = ∫t in Ioc a b, f t ∂μ :=
  integral_Icc_eq_integral_Ioc'$ measure_singleton a

/-- If two functions are equal in the relevant interval, their interval integrals are also equal. -/
theorem integral_congr {a b : α} (h : eq_on f g (interval a b)) : (∫x in a..b, f x ∂μ) = ∫x in a..b, g x ∂μ :=
  by 
    cases' le_totalₓ a b with hab hab <;>
      simpa [hab, integral_of_le, integral_of_ge] using
        set_integral_congr measurable_set_Ioc (h.mono Ioc_subset_Icc_self)

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem integral_add_adjacent_intervals_cancel
(hab : interval_integrable f μ a b)
(hbc : interval_integrable f μ b c) : «expr = »(«expr + »(«expr + »(«expr∫ in .. , ∂ »((x), a, b, f x, μ), «expr∫ in .. , ∂ »((x), b, c, f x, μ)), «expr∫ in .. , ∂ »((x), c, a, f x, μ)), 0) :=
begin
  have [ident hac] [] [":=", expr hab.trans hbc],
  simp [] [] ["only"] ["[", expr interval_integral, ",", "<-", expr add_sub_comm, ",", expr sub_eq_zero, "]"] [] [],
  iterate [4] { rw ["<-", expr integral_union] [] },
  { suffices [] [":", expr «expr = »(«expr ∪ »(«expr ∪ »(Ioc a b, Ioc b c), Ioc c a), «expr ∪ »(«expr ∪ »(Ioc b a, Ioc c b), Ioc a c))],
    by rw [expr this] [],
    rw ["[", expr Ioc_union_Ioc_union_Ioc_cycle, ",", expr union_right_comm, ",", expr Ioc_union_Ioc_union_Ioc_cycle, ",", expr min_left_comm, ",", expr max_left_comm, "]"] [] },
  all_goals { simp [] [] [] ["[", "*", ",", expr measurable_set.union, ",", expr measurable_set_Ioc, ",", expr Ioc_disjoint_Ioc_same, ",", expr Ioc_disjoint_Ioc_same.symm, ",", expr hab.1, ",", expr hab.2, ",", expr hbc.1, ",", expr hbc.2, ",", expr hac.1, ",", expr hac.2, "]"] [] [] }
end

theorem integral_add_adjacent_intervals (hab : IntervalIntegrable f μ a b) (hbc : IntervalIntegrable f μ b c) :
  ((∫x in a..b, f x ∂μ)+∫x in b..c, f x ∂μ) = ∫x in a..c, f x ∂μ :=
  by 
    rw [←add_neg_eq_zero, ←integral_symm, integral_add_adjacent_intervals_cancel hab hbc]

theorem sum_integral_adjacent_intervals {a : ℕ → α} {n : ℕ}
  (hint : ∀ k (_ : k < n), IntervalIntegrable f μ (a k) (a$ k+1)) :
  (∑k : ℕ in Finset.range n, ∫x in a k..a$ k+1, f x ∂μ) = ∫x in a 0 ..a n, f x ∂μ :=
  by 
    induction' n with n hn
    ·
      simp 
    ·
      rw [Finset.sum_range_succ, hn fun k hk => hint k (hk.trans n.lt_succ_self)]
      exact
        integral_add_adjacent_intervals (IntervalIntegrable.trans_iterate$ fun k hk => hint k (hk.trans n.lt_succ_self))
          (hint n n.lt_succ_self)

theorem integral_interval_sub_left (hab : IntervalIntegrable f μ a b) (hac : IntervalIntegrable f μ a c) :
  ((∫x in a..b, f x ∂μ) - ∫x in a..c, f x ∂μ) = ∫x in c..b, f x ∂μ :=
  sub_eq_of_eq_add'$ Eq.symm$ integral_add_adjacent_intervals hac (hac.symm.trans hab)

theorem integral_interval_add_interval_comm (hab : IntervalIntegrable f μ a b) (hcd : IntervalIntegrable f μ c d)
  (hac : IntervalIntegrable f μ a c) :
  ((∫x in a..b, f x ∂μ)+∫x in c..d, f x ∂μ) = (∫x in a..d, f x ∂μ)+∫x in c..b, f x ∂μ :=
  by 
    rw [←integral_add_adjacent_intervals hac hcd, add_assocₓ, add_left_commₓ,
      integral_add_adjacent_intervals hac (hac.symm.trans hab), add_commₓ]

theorem integral_interval_sub_interval_comm (hab : IntervalIntegrable f μ a b) (hcd : IntervalIntegrable f μ c d)
  (hac : IntervalIntegrable f μ a c) :
  ((∫x in a..b, f x ∂μ) - ∫x in c..d, f x ∂μ) = (∫x in a..c, f x ∂μ) - ∫x in b..d, f x ∂μ :=
  by 
    simp only [sub_eq_add_neg, ←integral_symm, integral_interval_add_interval_comm hab hcd.symm (hac.trans hcd)]

theorem integral_interval_sub_interval_comm' (hab : IntervalIntegrable f μ a b) (hcd : IntervalIntegrable f μ c d)
  (hac : IntervalIntegrable f μ a c) :
  ((∫x in a..b, f x ∂μ) - ∫x in c..d, f x ∂μ) = (∫x in d..b, f x ∂μ) - ∫x in c..a, f x ∂μ :=
  by 
    rw [integral_interval_sub_interval_comm hab hcd hac, integral_symm b d, integral_symm a c, sub_neg_eq_add,
      sub_eq_neg_add]

theorem integral_Iic_sub_Iic (ha : integrable_on f (Iic a) μ) (hb : integrable_on f (Iic b) μ) :
  ((∫x in Iic b, f x ∂μ) - ∫x in Iic a, f x ∂μ) = ∫x in a..b, f x ∂μ :=
  by 
    wlog (discharger := tactic.skip) hab : a ≤ b using a b
    ·
      rw [sub_eq_iff_eq_add', integral_of_le hab, ←integral_union (Iic_disjoint_Ioc (le_reflₓ _)),
        Iic_union_Ioc_eq_Iic hab]
      exacts[measurable_set_Iic, measurable_set_Ioc, ha, hb.mono_set fun _ => And.right]
    ·
      intro ha hb 
      rw [integral_symm, ←this hb ha, neg_sub]

/-- If `μ` is a finite measure then `∫ x in a..b, c ∂μ = (μ (Iic b) - μ (Iic a)) • c`. -/
theorem integral_const_of_cdf [is_finite_measure μ] (c : E) :
  (∫x in a..b, c ∂μ) = ((μ (Iic b)).toReal - (μ (Iic a)).toReal) • c :=
  by 
    simp only [sub_smul, ←set_integral_const]
    refine' (integral_Iic_sub_Iic _ _).symm <;> simp only [integrable_on_const, measure_lt_top, or_trueₓ]

theorem integral_eq_integral_of_support_subset {f : α → E} {a b} (h : support f ⊆ Ioc a b) :
  (∫x in a..b, f x ∂μ) = ∫x, f x ∂μ :=
  by 
    cases' le_totalₓ a b with hab hab
    ·
      rw [integral_of_le hab, ←integral_indicator measurable_set_Ioc, indicator_eq_self.2 h] <;> infer_instance
    ·
      rw [Ioc_eq_empty hab.not_lt, subset_empty_iff, support_eq_empty_iff] at h 
      simp [h]

theorem integral_congr_ae' {f g : α → E} (h : ∀ᵐx ∂μ, x ∈ Ioc a b → f x = g x) (h' : ∀ᵐx ∂μ, x ∈ Ioc b a → f x = g x) :
  (∫x : α in a..b, f x ∂μ) = ∫x : α in a..b, g x ∂μ :=
  by 
    simp only [intervalIntegral, set_integral_congr_ae measurable_set_Ioc h,
      set_integral_congr_ae measurable_set_Ioc h']

theorem integral_congr_ae {f g : α → E} (h : ∀ᵐx ∂μ, x ∈ Ι a b → f x = g x) :
  (∫x : α in a..b, f x ∂μ) = ∫x : α in a..b, g x ∂μ :=
  integral_congr_ae' (ae_interval_oc_iff.mp h).1 (ae_interval_oc_iff.mp h).2

theorem integral_zero_ae {f : α → E} (h : ∀ᵐx ∂μ, x ∈ Ι a b → f x = 0) : (∫x : α in a..b, f x ∂μ) = 0 :=
  calc (∫x in a..b, f x ∂μ) = ∫x in a..b, 0 ∂μ := integral_congr_ae h 
    _ = 0 := integral_zero
    

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem integral_indicator
{a₁ a₂ a₃ : α}
(h : «expr ∈ »(a₂, Icc a₁ a₃))
{f : α → E} : «expr = »(«expr∫ in .. , ∂ »((x), a₁, a₃, indicator {x | «expr ≤ »(x, a₂)} f x, μ), «expr∫ in .. , ∂ »((x), a₁, a₂, f x, μ)) :=
begin
  have [] [":", expr «expr = »(«expr ∩ »({x | «expr ≤ »(x, a₂)}, Ioc a₁ a₃), Ioc a₁ a₂)] [],
  from [expr Iic_inter_Ioc_of_le h.2],
  rw ["[", expr integral_of_le h.1, ",", expr integral_of_le (h.1.trans h.2), ",", expr integral_indicator, ",", expr measure.restrict_restrict, ",", expr this, "]"] [],
  exact [expr measurable_set_Iic],
  all_goals { apply [expr measurable_set_Iic] }
end

/-- Lebesgue dominated convergence theorem for filters with a countable basis -/
theorem tendsto_integral_filter_of_dominated_convergence {ι} {l : Filter ι} [l.is_countably_generated] {F : ι → α → E}
  (bound : α → ℝ) (hF_meas : ∀ᶠn in l, AeMeasurable (F n) (μ.restrict (Ι a b)))
  (h_bound : ∀ᶠn in l, ∀ᵐx ∂μ, x ∈ Ι a b → ∥F n x∥ ≤ bound x) (bound_integrable : IntervalIntegrable bound μ a b)
  (h_lim : ∀ᵐx ∂μ, x ∈ Ι a b → tendsto (fun n => F n x) l (𝓝 (f x))) :
  tendsto (fun n => ∫x in a..b, F n x ∂μ) l (𝓝$ ∫x in a..b, f x ∂μ) :=
  by 
    simp only [interval_integrable_iff, interval_integral_eq_integral_interval_oc,
      ←ae_restrict_iff' measurable_set_interval_oc] at *
    exact
      tendsto_const_nhds.smul
        (tendsto_integral_filter_of_dominated_convergence bound hF_meas h_bound bound_integrable h_lim)

/-- Lebesgue dominated convergence theorem for series. -/
theorem has_sum_integral_of_dominated_convergence {ι} [Encodable ι] {F : ι → α → E} (bound : ι → α → ℝ)
  (hF_meas : ∀ n, AeMeasurable (F n) (μ.restrict (Ι a b))) (h_bound : ∀ n, ∀ᵐt ∂μ, t ∈ Ι a b → ∥F n t∥ ≤ bound n t)
  (bound_summable : ∀ᵐt ∂μ, t ∈ Ι a b → Summable fun n => bound n t)
  (bound_integrable : IntervalIntegrable (fun t => ∑'n, bound n t) μ a b)
  (h_lim : ∀ᵐt ∂μ, t ∈ Ι a b → HasSum (fun n => F n t) (f t)) :
  HasSum (fun n => ∫t in a..b, F n t ∂μ) (∫t in a..b, f t ∂μ) :=
  by 
    simp only [interval_integrable_iff, interval_integral_eq_integral_interval_oc,
      ←ae_restrict_iff' measurable_set_interval_oc] at *
    exact
      (has_sum_integral_of_dominated_convergence bound hF_meas h_bound bound_summable bound_integrable h_lim).const_smul

open TopologicalSpace

variable{X : Type _}[TopologicalSpace X][first_countable_topology X]

/-- Continuity of interval integral with respect to a parameter, at a point within a set.
  Given `F : X → α → E`, assume `F x` is ae-measurable on `[a, b]` for `x` in a
  neighborhood of `x₀` within `s` and at `x₀`, and assume it is bounded by a function integrable
  on `[a, b]` independent of `x` in a neighborhood of `x₀` within `s`. If `(λ x, F x t)`
  is continuous at `x₀` within `s` for almost every `t` in `[a, b]`
  then the same holds for `(λ x, ∫ t in a..b, F x t ∂μ) s x₀`. -/
theorem continuous_within_at_of_dominated_interval {F : X → α → E} {x₀ : X} {bound : α → ℝ} {a b : α} {s : Set X}
  (hF_meas : ∀ᶠx in 𝓝[s] x₀, AeMeasurable (F x) (μ.restrict$ Ι a b))
  (h_bound : ∀ᶠx in 𝓝[s] x₀, ∀ᵐt ∂μ, t ∈ Ι a b → ∥F x t∥ ≤ bound t) (bound_integrable : IntervalIntegrable bound μ a b)
  (h_cont : ∀ᵐt ∂μ, t ∈ Ι a b → ContinuousWithinAt (fun x => F x t) s x₀) :
  ContinuousWithinAt (fun x => ∫t in a..b, F x t ∂μ) s x₀ :=
  tendsto_integral_filter_of_dominated_convergence bound hF_meas h_bound bound_integrable h_cont

/-- Continuity of interval integral with respect to a parameter at a point.
  Given `F : X → α → E`, assume `F x` is ae-measurable on `[a, b]` for `x` in a
  neighborhood of `x₀`, and assume it is bounded by a function integrable on
  `[a, b]` independent of `x` in a neighborhood of `x₀`. If `(λ x, F x t)`
  is continuous at `x₀` for almost every `t` in `[a, b]`
  then the same holds for `(λ x, ∫ t in a..b, F x t ∂μ) s x₀`. -/
theorem continuous_at_of_dominated_interval {F : X → α → E} {x₀ : X} {bound : α → ℝ} {a b : α}
  (hF_meas : ∀ᶠx in 𝓝 x₀, AeMeasurable (F x) (μ.restrict$ Ι a b))
  (h_bound : ∀ᶠx in 𝓝 x₀, ∀ᵐt ∂μ, t ∈ Ι a b → ∥F x t∥ ≤ bound t) (bound_integrable : IntervalIntegrable bound μ a b)
  (h_cont : ∀ᵐt ∂μ, t ∈ Ι a b → ContinuousAt (fun x => F x t) x₀) : ContinuousAt (fun x => ∫t in a..b, F x t ∂μ) x₀ :=
  tendsto_integral_filter_of_dominated_convergence bound hF_meas h_bound bound_integrable h_cont

/-- Continuity of interval integral with respect to a parameter.
  Given `F : X → α → E`, assume each `F x` is ae-measurable on `[a, b]`,
  and assume it is bounded by a function integrable on `[a, b]` independent of `x`.
  If `(λ x, F x t)` is continuous for almost every `t` in `[a, b]`
  then the same holds for `(λ x, ∫ t in a..b, F x t ∂μ) s x₀`. -/
theorem continuous_of_dominated_interval {F : X → α → E} {bound : α → ℝ} {a b : α}
  (hF_meas : ∀ x, AeMeasurable (F x)$ μ.restrict$ Ι a b) (h_bound : ∀ x, ∀ᵐt ∂μ, t ∈ Ι a b → ∥F x t∥ ≤ bound t)
  (bound_integrable : IntervalIntegrable bound μ a b) (h_cont : ∀ᵐt ∂μ, t ∈ Ι a b → Continuous fun x => F x t) :
  Continuous fun x => ∫t in a..b, F x t ∂μ :=
  continuous_iff_continuous_at.mpr
    fun x₀ =>
      continuous_at_of_dominated_interval (eventually_of_forall hF_meas) (eventually_of_forall h_bound)
          bound_integrable$
        h_cont.mono$ fun x himp hx => (himp hx).ContinuousAt

end OrderClosedTopology

section ContinuousPrimitive

open TopologicalSpace

variable[TopologicalSpace
      α][OrderTopology α][OpensMeasurableSpace α][first_countable_topology α]{a b : α}{μ : Measureₓ α}

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem continuous_within_at_primitive
{f : α → E}
{a b₀ b₁ b₂ : α}
(hb₀ : «expr = »(μ {b₀}, 0))
(h_int : interval_integrable f μ (min a b₁) (max a b₂)) : continuous_within_at (λ
 b, «expr∫ in .. , ∂ »((x), a, b, f x, μ)) (Icc b₁ b₂) b₀ :=
begin
  by_cases [expr h₀, ":", expr «expr ∈ »(b₀, Icc b₁ b₂)],
  { have [ident h₁₂] [":", expr «expr ≤ »(b₁, b₂)] [":=", expr h₀.1.trans h₀.2],
    have [ident min₁₂] [":", expr «expr = »(min b₁ b₂, b₁)] [":=", expr min_eq_left h₁₂],
    have [ident h_int'] [":", expr ∀ {x}, «expr ∈ »(x, Icc b₁ b₂) → interval_integrable f μ b₁ x] [],
    { rintros [ident x, "⟨", ident h₁, ",", ident h₂, "⟩"],
      apply [expr h_int.mono_set],
      apply [expr interval_subset_interval],
      { exact [expr ⟨min_le_of_left_le (min_le_right a b₁), h₁.trans «expr $ »(h₂.trans, «expr $ »(le_max_of_le_right, le_max_right _ _))⟩] },
      { exact [expr ⟨«expr $ »(min_le_of_left_le, (min_le_right _ _).trans h₁), «expr $ »(le_max_of_le_right, «expr $ »(h₂.trans, le_max_right _ _))⟩] } },
    have [] [":", expr ∀
     b «expr ∈ » Icc b₁ b₂, «expr = »(«expr∫ in .. , ∂ »((x), a, b, f x, μ), «expr + »(«expr∫ in .. , ∂ »((x), a, b₁, f x, μ), «expr∫ in .. , ∂ »((x), b₁, b, f x, μ)))] [],
    { rintros [ident b, "⟨", ident h₁, ",", ident h₂, "⟩"],
      rw ["<-", expr integral_add_adjacent_intervals _ (h_int' ⟨h₁, h₂⟩)] [],
      apply [expr h_int.mono_set],
      apply [expr interval_subset_interval],
      { exact [expr ⟨min_le_of_left_le (min_le_left a b₁), le_max_of_le_right (le_max_left _ _)⟩] },
      { exact [expr ⟨min_le_of_left_le (min_le_right _ _), le_max_of_le_right «expr $ »(h₁.trans, h₂.trans (le_max_right a b₂))⟩] } },
    apply [expr continuous_within_at.congr _ this (this _ h₀)],
    clear [ident this],
    refine [expr continuous_within_at_const.add _],
    have [] [":", expr «expr =ᶠ[ ] »(λ
      b, «expr∫ in .. , ∂ »((x), b₁, b, f x, μ), «expr𝓝[ ] »(Icc b₁ b₂, b₀), λ
      b, «expr∫ in .. , ∂ »((x), b₁, b₂, indicator {x | «expr ≤ »(x, b)} f x, μ))] [],
    { apply [expr eventually_eq_of_mem self_mem_nhds_within],
      exact [expr λ b b_in, (integral_indicator b_in).symm] },
    apply [expr continuous_within_at.congr_of_eventually_eq _ this (integral_indicator h₀).symm],
    have [] [":", expr interval_integrable (λ x, «expr∥ ∥»(f x)) μ b₁ b₂] [],
    from [expr interval_integrable.norm «expr $ »(h_int', right_mem_Icc.mpr h₁₂)],
    refine [expr continuous_within_at_of_dominated_interval _ _ this _]; clear [ident this],
    { apply [expr eventually.mono self_mem_nhds_within],
      intros [ident x, ident hx],
      erw ["[", expr ae_measurable_indicator_iff, ",", expr measure.restrict_restrict, ",", expr Iic_inter_Ioc_of_le, "]"] [],
      { rw [expr min₁₂] [],
        exact [expr (h_int' hx).1.ae_measurable] },
      { exact [expr le_max_of_le_right hx.2] },
      exacts ["[", expr measurable_set_Iic, ",", expr measurable_set_Iic, "]"] },
    { refine [expr eventually_of_forall (λ x : α, eventually_of_forall (λ t : α, _))],
      dsimp [] ["[", expr indicator, "]"] [] [],
      split_ifs [] []; simp [] [] [] [] [] [] },
    { have [] [":", expr «expr∀ᵐ ∂ , »((t), μ, «expr ∨ »(«expr < »(t, b₀), «expr < »(b₀, t)))] [],
      { apply [expr eventually.mono (compl_mem_ae_iff.mpr hb₀)],
        intros [ident x, ident hx],
        exact [expr ne.lt_or_lt hx] },
      apply [expr this.mono],
      rintros [ident x₀, "(", ident hx₀, "|", ident hx₀, ")", "-"],
      { have [] [":", expr «expr∀ᶠ in , »((x), «expr𝓝[ ] »(Icc b₁ b₂, b₀), «expr = »({t : α | «expr ≤ »(t, x)}.indicator f x₀, f x₀))] [],
        { apply [expr mem_nhds_within_of_mem_nhds],
          apply [expr eventually.mono (Ioi_mem_nhds hx₀)],
          intros [ident x, ident hx],
          simp [] [] [] ["[", expr hx.le, "]"] [] [] },
        apply [expr continuous_within_at_const.congr_of_eventually_eq this],
        simp [] [] [] ["[", expr hx₀.le, "]"] [] [] },
      { have [] [":", expr «expr∀ᶠ in , »((x), «expr𝓝[ ] »(Icc b₁ b₂, b₀), «expr = »({t : α | «expr ≤ »(t, x)}.indicator f x₀, 0))] [],
        { apply [expr mem_nhds_within_of_mem_nhds],
          apply [expr eventually.mono (Iio_mem_nhds hx₀)],
          intros [ident x, ident hx],
          simp [] [] [] ["[", expr hx, "]"] [] [] },
        apply [expr continuous_within_at_const.congr_of_eventually_eq this],
        simp [] [] [] ["[", expr hx₀, "]"] [] [] } } },
  { apply [expr continuous_within_at_of_not_mem_closure],
    rwa ["[", expr closure_Icc, "]"] [] }
end

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem continuous_on_primitive
{f : α → E}
{a b : α}
[has_no_atoms μ]
(h_int : integrable_on f (Icc a b) μ) : continuous_on (λ x, «expr∫ in , ∂ »((t), Ioc a x, f t, μ)) (Icc a b) :=
begin
  by_cases [expr h, ":", expr «expr ≤ »(a, b)],
  { have [] [":", expr ∀
     x «expr ∈ » Icc a b, «expr = »(«expr∫ in , ∂ »((t : α), Ioc a x, f t, μ), «expr∫ in .. , ∂ »((t : α), a, x, f t, μ))] [],
    { intros [ident x, ident x_in],
      simp_rw ["[", "<-", expr interval_oc_of_le h, ",", expr integral_of_le x_in.1, "]"] [] },
    rw [expr continuous_on_congr this] [],
    intros [ident x₀, ident hx₀],
    refine [expr continuous_within_at_primitive (measure_singleton x₀) _],
    simp [] [] ["only"] ["[", expr interval_integrable_iff_integrable_Ioc_of_le, ",", expr min_eq_left, ",", expr max_eq_right, ",", expr h, "]"] [] [],
    exact [expr h_int.mono Ioc_subset_Icc_self le_rfl] },
  { rw [expr Icc_eq_empty h] [],
    exact [expr continuous_on_empty _] }
end

theorem continuous_on_primitive_Icc {f : α → E} {a b : α} [has_no_atoms μ] (h_int : integrable_on f (Icc a b) μ) :
  ContinuousOn (fun x => ∫t in Icc a x, f t ∂μ) (Icc a b) :=
  by 
    rw
      [show (fun x => ∫t in Icc a x, f t ∂μ) = fun x => ∫t in Ioc a x, f t ∂μ by 
        ext x 
        exact integral_Icc_eq_integral_Ioc]
    exact continuous_on_primitive h_int

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:546:47: unsupported (impossible)
/-- Note: this assumes that `f` is `interval_integrable`, in contrast to some other lemmas here. -/
theorem continuous_on_primitive_interval'
{f : α → E}
{a b₁ b₂ : α}
[has_no_atoms μ]
(h_int : interval_integrable f μ b₁ b₂)
(ha : «expr ∈ »(a, «expr[ , ]»(b₁, b₂))) : continuous_on (λ
 b, «expr∫ in .. , ∂ »((x), a, b, f x, μ)) «expr[ , ]»(b₁, b₂) :=
begin
  intros [ident b₀, ident hb₀],
  refine [expr continuous_within_at_primitive (measure_singleton _) _],
  rw ["[", expr min_eq_right ha.1, ",", expr max_eq_right ha.2, "]"] [],
  simpa [] [] [] ["[", expr interval_integrable_iff, ",", expr interval_oc, "]"] [] ["using", expr h_int]
end

theorem continuous_on_primitive_interval {f : α → E} {a b : α} [has_no_atoms μ]
  (h_int : integrable_on f (interval a b) μ) : ContinuousOn (fun x => ∫t in a..x, f t ∂μ) (interval a b) :=
  continuous_on_primitive_interval' h_int.interval_integrable left_mem_interval

theorem continuous_on_primitive_interval_left {f : α → E} {a b : α} [has_no_atoms μ]
  (h_int : integrable_on f (interval a b) μ) : ContinuousOn (fun x => ∫t in x..b, f t ∂μ) (interval a b) :=
  by 
    rw [interval_swap a b] at h_int⊢
    simp only [integral_symm b]
    exact (continuous_on_primitive_interval h_int).neg

variable[NoBotOrder α][NoTopOrder α][has_no_atoms μ]

theorem continuous_primitive {f : α → E} (h_int : ∀ (a b : α), IntervalIntegrable f μ a b) (a : α) :
  Continuous fun b => ∫x in a..b, f x ∂μ :=
  by 
    rw [continuous_iff_continuous_at]
    intro b₀ 
    cases' no_bot b₀ with b₁ hb₁ 
    cases' no_top b₀ with b₂ hb₂ 
    apply ContinuousWithinAt.continuous_at _ (Icc_mem_nhds hb₁ hb₂)
    exact continuous_within_at_primitive (measure_singleton b₀) (h_int _ _)

theorem _root_.measure_theory.integrable.continuous_primitive {f : α → E} (h_int : integrable f μ) (a : α) :
  Continuous fun b => ∫x in a..b, f x ∂μ :=
  continuous_primitive (fun _ _ => h_int.interval_integrable) a

end ContinuousPrimitive

section 

variable{f g : α → ℝ}{a b : α}{μ : Measureₓ α}

theorem integral_eq_zero_iff_of_le_of_nonneg_ae (hab : a ≤ b) (hf : 0 ≤ᵐ[μ.restrict (Ioc a b)] f)
  (hfi : IntervalIntegrable f μ a b) : (∫x in a..b, f x ∂μ) = 0 ↔ f =ᵐ[μ.restrict (Ioc a b)] 0 :=
  by 
    rw [integral_of_le hab, integral_eq_zero_iff_of_nonneg_ae hf hfi.1]

theorem integral_eq_zero_iff_of_nonneg_ae (hf : 0 ≤ᵐ[μ.restrict (Ioc a b ∪ Ioc b a)] f)
  (hfi : IntervalIntegrable f μ a b) : (∫x in a..b, f x ∂μ) = 0 ↔ f =ᵐ[μ.restrict (Ioc a b ∪ Ioc b a)] 0 :=
  by 
    cases' le_totalₓ a b with hab hab <;> simp only [Ioc_eq_empty hab.not_lt, empty_union, union_empty] at hf⊢
    ·
      exact integral_eq_zero_iff_of_le_of_nonneg_ae hab hf hfi
    ·
      rw [integral_symm, neg_eq_zero, integral_eq_zero_iff_of_le_of_nonneg_ae hab hf hfi.symm]

theorem integral_pos_iff_support_of_nonneg_ae' (hf : 0 ≤ᵐ[μ.restrict (Ioc a b ∪ Ioc b a)] f)
  (hfi : IntervalIntegrable f μ a b) : (0 < ∫x in a..b, f x ∂μ) ↔ a < b ∧ 0 < μ (support f ∩ Ioc a b) :=
  by 
    obtain hab | hab := le_totalₓ b a <;> simp only [Ioc_eq_empty hab.not_lt, empty_union, union_empty] at hf⊢
    ·
      rw [←not_iff_not, not_and_distrib, not_ltₓ, not_ltₓ, integral_of_ge hab, neg_nonpos]
      exact iff_of_true (integral_nonneg_of_ae hf) (Or.intro_left _ hab)
    rw [integral_of_le hab, set_integral_pos_iff_support_of_nonneg_ae hf hfi.1, Iff.comm, and_iff_right_iff_imp]
    contrapose! 
    intro h 
    rw [Ioc_eq_empty h.not_lt, inter_empty, measure_empty]
    exact le_reflₓ 0

theorem integral_pos_iff_support_of_nonneg_ae (hf : 0 ≤ᵐ[μ] f) (hfi : IntervalIntegrable f μ a b) :
  (0 < ∫x in a..b, f x ∂μ) ↔ a < b ∧ 0 < μ (support f ∩ Ioc a b) :=
  integral_pos_iff_support_of_nonneg_ae' (ae_mono measure.restrict_le_self hf) hfi

variable(hab : a ≤ b)

include hab

theorem integral_nonneg_of_ae_restrict (hf : 0 ≤ᵐ[μ.restrict (Icc a b)] f) : 0 ≤ ∫u in a..b, f u ∂μ :=
  let H := ae_restrict_of_ae_restrict_of_subset Ioc_subset_Icc_self hf 
  by 
    simpa only [integral_of_le hab] using set_integral_nonneg_of_ae_restrict H

theorem integral_nonneg_of_ae (hf : 0 ≤ᵐ[μ] f) : 0 ≤ ∫u in a..b, f u ∂μ :=
  integral_nonneg_of_ae_restrict hab$ ae_restrict_of_ae hf

theorem integral_nonneg_of_forall (hf : ∀ u, 0 ≤ f u) : 0 ≤ ∫u in a..b, f u ∂μ :=
  integral_nonneg_of_ae hab$ eventually_of_forall hf

theorem integral_nonneg [TopologicalSpace α] [OpensMeasurableSpace α] [OrderClosedTopology α]
  (hf : ∀ u, u ∈ Icc a b → 0 ≤ f u) : 0 ≤ ∫u in a..b, f u ∂μ :=
  integral_nonneg_of_ae_restrict hab$ (ae_restrict_iff' measurable_set_Icc).mpr$ ae_of_all μ hf

theorem abs_integral_le_integral_abs : |∫x in a..b, f x ∂μ| ≤ ∫x in a..b, |f x| ∂μ :=
  by 
    simpa only [←Real.norm_eq_abs] using norm_integral_le_integral_norm hab

section Mono

variable(hf : IntervalIntegrable f μ a b)(hg : IntervalIntegrable g μ a b)

include hf hg

theorem integral_mono_ae_restrict (h : f ≤ᵐ[μ.restrict (Icc a b)] g) : (∫u in a..b, f u ∂μ) ≤ ∫u in a..b, g u ∂μ :=
  let H := h.filter_mono$ ae_mono$ measure.restrict_mono Ioc_subset_Icc_self$ le_reflₓ μ 
  by 
    simpa only [integral_of_le hab] using set_integral_mono_ae_restrict hf.1 hg.1 H

theorem integral_mono_ae (h : f ≤ᵐ[μ] g) : (∫u in a..b, f u ∂μ) ≤ ∫u in a..b, g u ∂μ :=
  by 
    simpa only [integral_of_le hab] using set_integral_mono_ae hf.1 hg.1 h

theorem integral_mono_on [TopologicalSpace α] [OpensMeasurableSpace α] [OrderClosedTopology α]
  (h : ∀ x (_ : x ∈ Icc a b), f x ≤ g x) : (∫u in a..b, f u ∂μ) ≤ ∫u in a..b, g u ∂μ :=
  let H := fun x hx => h x$ Ioc_subset_Icc_self hx 
  by 
    simpa only [integral_of_le hab] using set_integral_mono_on hf.1 hg.1 measurable_set_Ioc H

theorem integral_mono (h : f ≤ g) : (∫u in a..b, f u ∂μ) ≤ ∫u in a..b, g u ∂μ :=
  integral_mono_ae hab hf hg$ ae_of_all _ h

end Mono

end 

/-!
### Fundamental theorem of calculus, part 1, for any measure

In this section we prove a few lemmas that can be seen as versions of FTC-1 for interval integrals
w.r.t. any measure. Many theorems are formulated for one or two pairs of filters related by
`FTC_filter a l l'`. This typeclass has exactly four “real” instances: `(a, pure a, ⊥)`,
`(a, 𝓝[Ici a] a, 𝓝[Ioi a] a)`, `(a, 𝓝[Iic a] a, 𝓝[Iic a] a)`, `(a, 𝓝 a, 𝓝 a)`, and two instances
that are equal to the first and last “real” instances: `(a, 𝓝[{a}] a, ⊥)` and
`(a, 𝓝[univ] a, 𝓝[univ] a)`.  We use this approach to avoid repeating arguments in many very similar
cases.  Lean can automatically find both `a` and `l'` based on `l`.

The most general theorem `measure_integral_sub_integral_sub_linear_is_o_of_tendsto_ae` can be seen
as a generalization of lemma `integral_has_strict_fderiv_at` below which states strict
differentiability of `∫ x in u..v, f x` in `(u, v)` at `(a, b)` for a measurable function `f` that
is integrable on `a..b` and is continuous at `a` and `b`. The lemma is generalized in three
directions: first, `measure_integral_sub_integral_sub_linear_is_o_of_tendsto_ae` deals with any
locally finite measure `μ`; second, it works for one-sided limits/derivatives; third, it assumes
only that `f` has finite limits almost surely at `a` and `b`.

Namely, let `f` be a measurable function integrable on `a..b`. Let `(la, la')` be a pair of
`FTC_filter`s around `a`; let `(lb, lb')` be a pair of `FTC_filter`s around `b`. Suppose that `f`
has finite limits `ca` and `cb` at `la' ⊓ μ.ae` and `lb' ⊓ μ.ae`, respectively.  Then
`∫ x in va..vb, f x ∂μ - ∫ x in ua..ub, f x ∂μ = ∫ x in ub..vb, cb ∂μ - ∫ x in ua..va, ca ∂μ +
  o(∥∫ x in ua..va, (1:ℝ) ∂μ∥ + ∥∫ x in ub..vb, (1:ℝ) ∂μ∥)`
as `ua` and `va` tend to `la` while `ub` and `vb` tend to `lb`.

This theorem is formulated with integral of constants instead of measures in the right hand sides
for two reasons: first, this way we avoid `min`/`max` in the statements; second, often it is
possible to write better `simp` lemmas for these integrals, see `integral_const` and
`integral_const_of_cdf`.

In the next subsection we apply this theorem to prove various theorems about differentiability
of the integral w.r.t. Lebesgue measure. -/


/-- An auxiliary typeclass for the Fundamental theorem of calculus, part 1. It is used to formulate
theorems that work simultaneously for left and right one-sided derivatives of `∫ x in u..v, f x`. -/
class
  FTC_filter{β :
    Type
      _}[LinearOrderₓ
      β][MeasurableSpace β][TopologicalSpace β](a : outParam β)(outer : Filter β)(inner : outParam$ Filter β) extends
  tendsto_Ixx_class Ioc outer inner : Prop where 
  pure_le : pure a ≤ outer 
  le_nhds : inner ≤ 𝓝 a
  [meas_gen : is_measurably_generated inner]

attribute [nolint dangerous_instance] FTC_filter.to_tendsto_Ixx_class

namespace FTCFilter

variable[LinearOrderₓ β][MeasurableSpace β][TopologicalSpace β]

instance pure (a : β) : FTC_filter a (pure a) ⊥ :=
  { pure_le := le_reflₓ _, le_nhds := bot_le }

instance nhds_within_singleton (a : β) : FTC_filter a (𝓝[{a}] a) ⊥ :=
  by 
    rw [nhdsWithin, principal_singleton, inf_eq_right.2 (pure_le_nhds a)]
    infer_instance

theorem finite_at_inner {a : β} (l : Filter β) {l'} [h : FTC_filter a l l'] {μ : Measureₓ β}
  [is_locally_finite_measure μ] : μ.finite_at_filter l' :=
  (μ.finite_at_nhds a).filter_mono h.le_nhds

variable[OpensMeasurableSpace β][OrderTopology β]

instance nhds (a : β) : FTC_filter a (𝓝 a) (𝓝 a) :=
  { pure_le := pure_le_nhds a, le_nhds := le_reflₓ _ }

instance nhds_univ (a : β) : FTC_filter a (𝓝[univ] a) (𝓝 a) :=
  by 
    rw [nhds_within_univ]
    infer_instance

instance nhds_left (a : β) : FTC_filter a (𝓝[Iic a] a) (𝓝[Iic a] a) :=
  { pure_le := pure_le_nhds_within right_mem_Iic, le_nhds := inf_le_left }

instance nhds_right (a : β) : FTC_filter a (𝓝[Ici a] a) (𝓝[Ioi a] a) :=
  { pure_le := pure_le_nhds_within left_mem_Ici, le_nhds := inf_le_left }

instance nhds_Icc {x a b : β} [h : Fact (x ∈ Icc a b)] : FTC_filter x (𝓝[Icc a b] x) (𝓝[Icc a b] x) :=
  { pure_le := pure_le_nhds_within h.out, le_nhds := inf_le_left }

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:546:47: unsupported (impossible)
instance nhds_interval
{x a b : β}
[h : fact «expr ∈ »(x, «expr[ , ]»(a, b))] : FTC_filter x «expr𝓝[ ] »(«expr[ , ]»(a, b), x) «expr𝓝[ ] »(«expr[ , ]»(a, b), x) :=
by { haveI [] [":", expr fact «expr ∈ »(x, set.Icc (min a b) (max a b))] [":=", expr h],
  exact [expr FTC_filter.nhds_Icc] }

end FTCFilter

open Asymptotics

section 

variable{f :
    α → E}{a b : α}{c ca cb : E}{l l' la la' lb lb' : Filter α}{lt : Filter β}{μ : Measureₓ α}{u v ua va ub vb : β → α}

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Fundamental theorem of calculus-1, local version for any measure.
Let filters `l` and `l'` be related by `tendsto_Ixx_class Ioc`.
If `f` has a finite limit `c` at `l' ⊓ μ.ae`, where `μ` is a measure
finite at `l'`, then `∫ x in u..v, f x ∂μ = ∫ x in u..v, c ∂μ + o(∫ x in u..v, 1 ∂μ)` as both
`u` and `v` tend to `l`.

See also `measure_integral_sub_linear_is_o_of_tendsto_ae` for a version assuming
`[FTC_filter a l l']` and `[is_locally_finite_measure μ]`. If `l` is one of `𝓝[Ici a] a`,
`𝓝[Iic a] a`, `𝓝 a`, then it's easier to apply the non-primed version.
The primed version also works, e.g., for `l = l' = at_top`.

We use integrals of constants instead of measures because this way it is easier to formulate
a statement that works in both cases `u ≤ v` and `v ≤ u`. -/
theorem measure_integral_sub_linear_is_o_of_tendsto_ae'
[is_measurably_generated l']
[tendsto_Ixx_class Ioc l l']
(hfm : measurable_at_filter f l' μ)
(hf : tendsto f «expr ⊓ »(l', μ.ae) (expr𝓝() c))
(hl : μ.finite_at_filter l')
(hu : tendsto u lt l)
(hv : tendsto v lt l) : is_o (λ
 t, «expr - »(«expr∫ in .. , ∂ »((x), u t, v t, f x, μ), «expr∫ in .. , ∂ »((x), u t, v t, c, μ))) (λ
 t, «expr∫ in .. , ∂ »((x), u t, v t, (1 : exprℝ()), μ)) lt :=
begin
  have [ident A] [] [":=", expr hf.integral_sub_linear_is_o_ae hfm hl (hu.Ioc hv)],
  have [ident B] [] [":=", expr hf.integral_sub_linear_is_o_ae hfm hl (hv.Ioc hu)],
  simp [] [] ["only"] ["[", expr integral_const', "]"] [] [],
  convert [] [expr (A.trans_le _).sub (B.trans_le _)] [],
  { ext [] [ident t] [],
    simp_rw ["[", expr interval_integral, ",", expr sub_smul, "]"] [],
    abel [] [] [] },
  all_goals { intro [ident t],
    cases [expr le_total (u t) (v t)] ["with", ident huv, ident huv]; simp [] [] [] ["[", expr huv, "]"] [] [] }
end

/-- Fundamental theorem of calculus-1, local version for any measure.
Let filters `l` and `l'` be related by `tendsto_Ixx_class Ioc`.
If `f` has a finite limit `c` at `l ⊓ μ.ae`, where `μ` is a measure
finite at `l`, then `∫ x in u..v, f x ∂μ = μ (Ioc u v) • c + o(μ(Ioc u v))` as both
`u` and `v` tend to `l` so that `u ≤ v`.

See also `measure_integral_sub_linear_is_o_of_tendsto_ae_of_le` for a version assuming
`[FTC_filter a l l']` and `[is_locally_finite_measure μ]`. If `l` is one of `𝓝[Ici a] a`,
`𝓝[Iic a] a`, `𝓝 a`, then it's easier to apply the non-primed version.
The primed version also works, e.g., for `l = l' = at_top`. -/
theorem measure_integral_sub_linear_is_o_of_tendsto_ae_of_le' [is_measurably_generated l'] [tendsto_Ixx_class Ioc l l']
  (hfm : MeasurableAtFilter f l' μ) (hf : tendsto f (l'⊓μ.ae) (𝓝 c)) (hl : μ.finite_at_filter l') (hu : tendsto u lt l)
  (hv : tendsto v lt l) (huv : u ≤ᶠ[lt] v) :
  is_o (fun t => (∫x in u t..v t, f x ∂μ) - (μ (Ioc (u t) (v t))).toReal • c) (fun t => (μ$ Ioc (u t) (v t)).toReal)
    lt :=
  (measure_integral_sub_linear_is_o_of_tendsto_ae' hfm hf hl hu hv).congr'
    (huv.mono$
      fun x hx =>
        by 
          simp [integral_const', hx])
    (huv.mono$
      fun x hx =>
        by 
          simp [integral_const', hx])

/-- Fundamental theorem of calculus-1, local version for any measure.
Let filters `l` and `l'` be related by `tendsto_Ixx_class Ioc`.
If `f` has a finite limit `c` at `l ⊓ μ.ae`, where `μ` is a measure
finite at `l`, then `∫ x in u..v, f x ∂μ = -μ (Ioc v u) • c + o(μ(Ioc v u))` as both
`u` and `v` tend to `l` so that `v ≤ u`.

See also `measure_integral_sub_linear_is_o_of_tendsto_ae_of_ge` for a version assuming
`[FTC_filter a l l']` and `[is_locally_finite_measure μ]`. If `l` is one of `𝓝[Ici a] a`,
`𝓝[Iic a] a`, `𝓝 a`, then it's easier to apply the non-primed version.
The primed version also works, e.g., for `l = l' = at_top`. -/
theorem measure_integral_sub_linear_is_o_of_tendsto_ae_of_ge' [is_measurably_generated l'] [tendsto_Ixx_class Ioc l l']
  (hfm : MeasurableAtFilter f l' μ) (hf : tendsto f (l'⊓μ.ae) (𝓝 c)) (hl : μ.finite_at_filter l') (hu : tendsto u lt l)
  (hv : tendsto v lt l) (huv : v ≤ᶠ[lt] u) :
  is_o (fun t => (∫x in u t..v t, f x ∂μ)+(μ (Ioc (v t) (u t))).toReal • c) (fun t => (μ$ Ioc (v t) (u t)).toReal) lt :=
  (measure_integral_sub_linear_is_o_of_tendsto_ae_of_le' hfm hf hl hv hu huv).neg_left.congr_left$
    fun t =>
      by 
        simp [integral_symm (u t), add_commₓ]

variable[TopologicalSpace α]

section 

variable[is_locally_finite_measure μ][FTC_filter a l l']

include a

attribute [local instance] FTC_filter.meas_gen

/-- Fundamental theorem of calculus-1, local version for any measure.
Let filters `l` and `l'` be related by `[FTC_filter a l l']`; let `μ` be a locally finite measure.
If `f` has a finite limit `c` at `l' ⊓ μ.ae`, then
`∫ x in u..v, f x ∂μ = ∫ x in u..v, c ∂μ + o(∫ x in u..v, 1 ∂μ)` as both `u` and `v` tend to `l`.

See also `measure_integral_sub_linear_is_o_of_tendsto_ae'` for a version that also works, e.g., for
`l = l' = at_top`.

We use integrals of constants instead of measures because this way it is easier to formulate
a statement that works in both cases `u ≤ v` and `v ≤ u`. -/
theorem measure_integral_sub_linear_is_o_of_tendsto_ae (hfm : MeasurableAtFilter f l' μ)
  (hf : tendsto f (l'⊓μ.ae) (𝓝 c)) (hu : tendsto u lt l) (hv : tendsto v lt l) :
  is_o (fun t => (∫x in u t..v t, f x ∂μ) - ∫x in u t..v t, c ∂μ) (fun t => ∫x in u t..v t, (1 : ℝ) ∂μ) lt :=
  measure_integral_sub_linear_is_o_of_tendsto_ae' hfm hf (FTC_filter.finite_at_inner l) hu hv

/-- Fundamental theorem of calculus-1, local version for any measure.
Let filters `l` and `l'` be related by `[FTC_filter a l l']`; let `μ` be a locally finite measure.
If `f` has a finite limit `c` at `l' ⊓ μ.ae`, then
`∫ x in u..v, f x ∂μ = μ (Ioc u v) • c + o(μ(Ioc u v))` as both `u` and `v` tend to `l`.

See also `measure_integral_sub_linear_is_o_of_tendsto_ae_of_le'` for a version that also works,
e.g., for `l = l' = at_top`. -/
theorem measure_integral_sub_linear_is_o_of_tendsto_ae_of_le (hfm : MeasurableAtFilter f l' μ)
  (hf : tendsto f (l'⊓μ.ae) (𝓝 c)) (hu : tendsto u lt l) (hv : tendsto v lt l) (huv : u ≤ᶠ[lt] v) :
  is_o (fun t => (∫x in u t..v t, f x ∂μ) - (μ (Ioc (u t) (v t))).toReal • c) (fun t => (μ$ Ioc (u t) (v t)).toReal)
    lt :=
  measure_integral_sub_linear_is_o_of_tendsto_ae_of_le' hfm hf (FTC_filter.finite_at_inner l) hu hv huv

/-- Fundamental theorem of calculus-1, local version for any measure.
Let filters `l` and `l'` be related by `[FTC_filter a l l']`; let `μ` be a locally finite measure.
If `f` has a finite limit `c` at `l' ⊓ μ.ae`, then
`∫ x in u..v, f x ∂μ = -μ (Ioc v u) • c + o(μ(Ioc v u))` as both `u` and `v` tend to `l`.

See also `measure_integral_sub_linear_is_o_of_tendsto_ae_of_ge'` for a version that also works,
e.g., for `l = l' = at_top`. -/
theorem measure_integral_sub_linear_is_o_of_tendsto_ae_of_ge (hfm : MeasurableAtFilter f l' μ)
  (hf : tendsto f (l'⊓μ.ae) (𝓝 c)) (hu : tendsto u lt l) (hv : tendsto v lt l) (huv : v ≤ᶠ[lt] u) :
  is_o (fun t => (∫x in u t..v t, f x ∂μ)+(μ (Ioc (v t) (u t))).toReal • c) (fun t => (μ$ Ioc (v t) (u t)).toReal) lt :=
  measure_integral_sub_linear_is_o_of_tendsto_ae_of_ge' hfm hf (FTC_filter.finite_at_inner l) hu hv huv

end 

variable[OrderTopology α][BorelSpace α]

attribute [local instance] FTC_filter.meas_gen

variable[FTC_filter a la la'][FTC_filter b lb lb'][is_locally_finite_measure μ]

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Fundamental theorem of calculus-1, strict derivative in both limits for a locally finite
measure.

Let `f` be a measurable function integrable on `a..b`. Let `(la, la')` be a pair of `FTC_filter`s
around `a`; let `(lb, lb')` be a pair of `FTC_filter`s around `b`. Suppose that `f` has finite
limits `ca` and `cb` at `la' ⊓ μ.ae` and `lb' ⊓ μ.ae`, respectively.
Then `∫ x in va..vb, f x ∂μ - ∫ x in ua..ub, f x ∂μ =
  ∫ x in ub..vb, cb ∂μ - ∫ x in ua..va, ca ∂μ +
    o(∥∫ x in ua..va, (1:ℝ) ∂μ∥ + ∥∫ x in ub..vb, (1:ℝ) ∂μ∥)`
as `ua` and `va` tend to `la` while `ub` and `vb` tend to `lb`.
-/
theorem measure_integral_sub_integral_sub_linear_is_o_of_tendsto_ae
(hab : interval_integrable f μ a b)
(hmeas_a : measurable_at_filter f la' μ)
(hmeas_b : measurable_at_filter f lb' μ)
(ha_lim : tendsto f «expr ⊓ »(la', μ.ae) (expr𝓝() ca))
(hb_lim : tendsto f «expr ⊓ »(lb', μ.ae) (expr𝓝() cb))
(hua : tendsto ua lt la)
(hva : tendsto va lt la)
(hub : tendsto ub lt lb)
(hvb : tendsto vb lt lb) : is_o (λ
 t, «expr - »(«expr - »(«expr∫ in .. , ∂ »((x), va t, vb t, f x, μ), «expr∫ in .. , ∂ »((x), ua t, ub t, f x, μ)), «expr - »(«expr∫ in .. , ∂ »((x), ub t, vb t, cb, μ), «expr∫ in .. , ∂ »((x), ua t, va t, ca, μ)))) (λ
 t, «expr + »(«expr∥ ∥»(«expr∫ in .. , ∂ »((x), ua t, va t, (1 : exprℝ()), μ)), «expr∥ ∥»(«expr∫ in .. , ∂ »((x), ub t, vb t, (1 : exprℝ()), μ)))) lt :=
begin
  refine [expr ((measure_integral_sub_linear_is_o_of_tendsto_ae hmeas_a ha_lim hua hva).neg_left.add_add (measure_integral_sub_linear_is_o_of_tendsto_ae hmeas_b hb_lim hub hvb)).congr' _ eventually_eq.rfl],
  have [ident A] [":", expr «expr∀ᶠ in , »((t), lt, interval_integrable f μ (ua t) (va t))] [":=", expr ha_lim.eventually_interval_integrable_ae hmeas_a (FTC_filter.finite_at_inner la) hua hva],
  have [ident A'] [":", expr «expr∀ᶠ in , »((t), lt, interval_integrable f μ a (ua t))] [":=", expr ha_lim.eventually_interval_integrable_ae hmeas_a (FTC_filter.finite_at_inner la) (tendsto_const_pure.mono_right FTC_filter.pure_le) hua],
  have [ident B] [":", expr «expr∀ᶠ in , »((t), lt, interval_integrable f μ (ub t) (vb t))] [":=", expr hb_lim.eventually_interval_integrable_ae hmeas_b (FTC_filter.finite_at_inner lb) hub hvb],
  have [ident B'] [":", expr «expr∀ᶠ in , »((t), lt, interval_integrable f μ b (ub t))] [":=", expr hb_lim.eventually_interval_integrable_ae hmeas_b (FTC_filter.finite_at_inner lb) (tendsto_const_pure.mono_right FTC_filter.pure_le) hub],
  filter_upwards ["[", expr A, ",", expr A', ",", expr B, ",", expr B', "]"] [],
  intros [ident t, ident ua_va, ident a_ua, ident ub_vb, ident b_ub],
  rw ["[", "<-", expr integral_interval_sub_interval_comm', "]"] [],
  { dsimp ["only"] ["[", "]"] [] [],
    abel [] [] [] },
  exacts ["[", expr ub_vb, ",", expr ua_va, ",", expr «expr $ »(b_ub.symm.trans, hab.symm.trans a_ua), "]"]
end

/-- Fundamental theorem of calculus-1, strict derivative in right endpoint for a locally finite
measure.

Let `f` be a measurable function integrable on `a..b`. Let `(lb, lb')` be a pair of `FTC_filter`s
around `b`. Suppose that `f` has a finite limit `c` at `lb' ⊓ μ.ae`.

Then `∫ x in a..v, f x ∂μ - ∫ x in a..u, f x ∂μ = ∫ x in u..v, c ∂μ + o(∫ x in u..v, (1:ℝ) ∂μ)`
as `u` and `v` tend to `lb`.
-/
theorem measure_integral_sub_integral_sub_linear_is_o_of_tendsto_ae_right (hab : IntervalIntegrable f μ a b)
  (hmeas : MeasurableAtFilter f lb' μ) (hf : tendsto f (lb'⊓μ.ae) (𝓝 c)) (hu : tendsto u lt lb) (hv : tendsto v lt lb) :
  is_o (fun t => ((∫x in a..v t, f x ∂μ) - ∫x in a..u t, f x ∂μ) - ∫x in u t..v t, c ∂μ)
    (fun t => ∫x in u t..v t, (1 : ℝ) ∂μ) lt :=
  by 
    simpa using
      measure_integral_sub_integral_sub_linear_is_o_of_tendsto_ae hab measurable_at_bot hmeas
        ((tendsto_bot : tendsto _ ⊥ (𝓝 0)).mono_left inf_le_left) hf (tendsto_const_pure : tendsto _ _ (pure a))
        tendsto_const_pure hu hv

/-- Fundamental theorem of calculus-1, strict derivative in left endpoint for a locally finite
measure.

Let `f` be a measurable function integrable on `a..b`. Let `(la, la')` be a pair of `FTC_filter`s
around `a`. Suppose that `f` has a finite limit `c` at `la' ⊓ μ.ae`.

Then `∫ x in v..b, f x ∂μ - ∫ x in u..b, f x ∂μ = -∫ x in u..v, c ∂μ + o(∫ x in u..v, (1:ℝ) ∂μ)`
as `u` and `v` tend to `la`.
-/
theorem measure_integral_sub_integral_sub_linear_is_o_of_tendsto_ae_left (hab : IntervalIntegrable f μ a b)
  (hmeas : MeasurableAtFilter f la' μ) (hf : tendsto f (la'⊓μ.ae) (𝓝 c)) (hu : tendsto u lt la) (hv : tendsto v lt la) :
  is_o (fun t => ((∫x in v t..b, f x ∂μ) - ∫x in u t..b, f x ∂μ)+∫x in u t..v t, c ∂μ)
    (fun t => ∫x in u t..v t, (1 : ℝ) ∂μ) lt :=
  by 
    simpa using
      measure_integral_sub_integral_sub_linear_is_o_of_tendsto_ae hab hmeas measurable_at_bot hf
        ((tendsto_bot : tendsto _ ⊥ (𝓝 0)).mono_left inf_le_left) hu hv (tendsto_const_pure : tendsto _ _ (pure b))
        tendsto_const_pure

end 

/-!
### Fundamental theorem of calculus-1 for Lebesgue measure

In this section we restate theorems from the previous section for Lebesgue measure.
In particular, we prove that `∫ x in u..v, f x` is strictly differentiable in `(u, v)`
at `(a, b)` provided that `f` is integrable on `a..b` and is continuous at `a` and `b`.
-/


variable{f :
    ℝ →
      E}{c ca cb :
    E}{l l' la la' lb lb' :
    Filter ℝ}{lt : Filter β}{a b z : ℝ}{u v ua ub va vb : β → ℝ}[FTC_filter a la la'][FTC_filter b lb lb']

/-!
#### Auxiliary `is_o` statements

In this section we prove several lemmas that can be interpreted as strict differentiability of
`(u, v) ↦ ∫ x in u..v, f x ∂μ` in `u` and/or `v` at a filter. The statements use `is_o` because
we have no definition of `has_strict_(f)deriv_at_filter` in the library.
-/


/-- Fundamental theorem of calculus-1, local version. If `f` has a finite limit `c` almost surely at
`l'`, where `(l, l')` is an `FTC_filter` pair around `a`, then
`∫ x in u..v, f x ∂μ = (v - u) • c + o (v - u)` as both `u` and `v` tend to `l`. -/
theorem integral_sub_linear_is_o_of_tendsto_ae [FTC_filter a l l'] (hfm : MeasurableAtFilter f l')
  (hf : tendsto f (l'⊓volume.ae) (𝓝 c)) {u v : β → ℝ} (hu : tendsto u lt l) (hv : tendsto v lt l) :
  is_o (fun t => (∫x in u t..v t, f x) - (v t - u t) • c) (v - u) lt :=
  by 
    simpa [integral_const] using measure_integral_sub_linear_is_o_of_tendsto_ae hfm hf hu hv

/-- Fundamental theorem of calculus-1, strict differentiability at filter in both endpoints.
If `f` is a measurable function integrable on `a..b`, `(la, la')` is an `FTC_filter` pair around
`a`, and `(lb, lb')` is an `FTC_filter` pair around `b`, and `f` has finite limits `ca` and `cb`
almost surely at `la'` and `lb'`, respectively, then
`(∫ x in va..vb, f x) - ∫ x in ua..ub, f x = (vb - ub) • cb - (va - ua) • ca +
  o(∥va - ua∥ + ∥vb - ub∥)` as `ua` and `va` tend to `la` while `ub` and `vb` tend to `lb`.

This lemma could've been formulated using `has_strict_fderiv_at_filter` if we had this
definition. -/
theorem integral_sub_integral_sub_linear_is_o_of_tendsto_ae (hab : IntervalIntegrable f volume a b)
  (hmeas_a : MeasurableAtFilter f la') (hmeas_b : MeasurableAtFilter f lb') (ha_lim : tendsto f (la'⊓volume.ae) (𝓝 ca))
  (hb_lim : tendsto f (lb'⊓volume.ae) (𝓝 cb)) (hua : tendsto ua lt la) (hva : tendsto va lt la) (hub : tendsto ub lt lb)
  (hvb : tendsto vb lt lb) :
  is_o (fun t => ((∫x in va t..vb t, f x) - ∫x in ua t..ub t, f x) - ((vb t - ub t) • cb - (va t - ua t) • ca))
    (fun t => ∥va t - ua t∥+∥vb t - ub t∥) lt :=
  by 
    simpa [integral_const] using
      measure_integral_sub_integral_sub_linear_is_o_of_tendsto_ae hab hmeas_a hmeas_b ha_lim hb_lim hua hva hub hvb

/-- Fundamental theorem of calculus-1, strict differentiability at filter in both endpoints.
If `f` is a measurable function integrable on `a..b`, `(lb, lb')` is an `FTC_filter` pair
around `b`, and `f` has a finite limit `c` almost surely at `lb'`, then
`(∫ x in a..v, f x) - ∫ x in a..u, f x = (v - u) • c + o(∥v - u∥)` as `u` and `v` tend to `lb`.

This lemma could've been formulated using `has_strict_deriv_at_filter` if we had this definition. -/
theorem integral_sub_integral_sub_linear_is_o_of_tendsto_ae_right (hab : IntervalIntegrable f volume a b)
  (hmeas : MeasurableAtFilter f lb') (hf : tendsto f (lb'⊓volume.ae) (𝓝 c)) (hu : tendsto u lt lb)
  (hv : tendsto v lt lb) : is_o (fun t => ((∫x in a..v t, f x) - ∫x in a..u t, f x) - (v t - u t) • c) (v - u) lt :=
  by 
    simpa only [integral_const, smul_eq_mul, mul_oneₓ] using
      measure_integral_sub_integral_sub_linear_is_o_of_tendsto_ae_right hab hmeas hf hu hv

/-- Fundamental theorem of calculus-1, strict differentiability at filter in both endpoints.
If `f` is a measurable function integrable on `a..b`, `(la, la')` is an `FTC_filter` pair
around `a`, and `f` has a finite limit `c` almost surely at `la'`, then
`(∫ x in v..b, f x) - ∫ x in u..b, f x = -(v - u) • c + o(∥v - u∥)` as `u` and `v` tend to `la`.

This lemma could've been formulated using `has_strict_deriv_at_filter` if we had this definition. -/
theorem integral_sub_integral_sub_linear_is_o_of_tendsto_ae_left (hab : IntervalIntegrable f volume a b)
  (hmeas : MeasurableAtFilter f la') (hf : tendsto f (la'⊓volume.ae) (𝓝 c)) (hu : tendsto u lt la)
  (hv : tendsto v lt la) : is_o (fun t => ((∫x in v t..b, f x) - ∫x in u t..b, f x)+(v t - u t) • c) (v - u) lt :=
  by 
    simpa only [integral_const, smul_eq_mul, mul_oneₓ] using
      measure_integral_sub_integral_sub_linear_is_o_of_tendsto_ae_left hab hmeas hf hu hv

open continuous_linear_map(fst snd smulRight sub_apply smul_right_apply coe_fst' coe_snd' map_sub)

/-!
#### Strict differentiability

In this section we prove that for a measurable function `f` integrable on `a..b`,

* `integral_has_strict_fderiv_at_of_tendsto_ae`: the function `(u, v) ↦ ∫ x in u..v, f x` has
  derivative `(u, v) ↦ v • cb - u • ca` at `(a, b)` in the sense of strict differentiability
  provided that `f` tends to `ca` and `cb` almost surely as `x` tendsto to `a` and `b`,
  respectively;

* `integral_has_strict_fderiv_at`: the function `(u, v) ↦ ∫ x in u..v, f x` has
  derivative `(u, v) ↦ v • f b - u • f a` at `(a, b)` in the sense of strict differentiability
  provided that `f` is continuous at `a` and `b`;

* `integral_has_strict_deriv_at_of_tendsto_ae_right`: the function `u ↦ ∫ x in a..u, f x` has
  derivative `c` at `b` in the sense of strict differentiability provided that `f` tends to `c`
  almost surely as `x` tends to `b`;

* `integral_has_strict_deriv_at_right`: the function `u ↦ ∫ x in a..u, f x` has derivative `f b` at
  `b` in the sense of strict differentiability provided that `f` is continuous at `b`;

* `integral_has_strict_deriv_at_of_tendsto_ae_left`: the function `u ↦ ∫ x in u..b, f x` has
  derivative `-c` at `a` in the sense of strict differentiability provided that `f` tends to `c`
  almost surely as `x` tends to `a`;

* `integral_has_strict_deriv_at_left`: the function `u ↦ ∫ x in u..b, f x` has derivative `-f a` at
  `a` in the sense of strict differentiability provided that `f` is continuous at `a`.
-/


-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f x` has finite
limits `ca` and `cb` almost surely as `x` tends to `a` and `b`, respectively, then
`(u, v) ↦ ∫ x in u..v, f x` has derivative `(u, v) ↦ v • cb - u • ca` at `(a, b)`
in the sense of strict differentiability. -/
theorem integral_has_strict_fderiv_at_of_tendsto_ae
(hf : interval_integrable f volume a b)
(hmeas_a : measurable_at_filter f (expr𝓝() a))
(hmeas_b : measurable_at_filter f (expr𝓝() b))
(ha : tendsto f «expr ⊓ »(expr𝓝() a, volume.ae) (expr𝓝() ca))
(hb : tendsto f «expr ⊓ »(expr𝓝() b, volume.ae) (expr𝓝() cb)) : has_strict_fderiv_at (λ
 p : «expr × »(exprℝ(), exprℝ()), «expr∫ in .. , »((x), p.1, p.2, f x)) «expr - »((snd exprℝ() exprℝ() exprℝ()).smul_right cb, (fst exprℝ() exprℝ() exprℝ()).smul_right ca) (a, b) :=
begin
  have [] [] [":=", expr integral_sub_integral_sub_linear_is_o_of_tendsto_ae hf hmeas_a hmeas_b ha hb ((continuous_fst.comp continuous_snd).tendsto ((a, b), (a, b))) ((continuous_fst.comp continuous_fst).tendsto ((a, b), (a, b))) ((continuous_snd.comp continuous_snd).tendsto ((a, b), (a, b))) ((continuous_snd.comp continuous_fst).tendsto ((a, b), (a, b)))],
  refine [expr (this.congr_left _).trans_is_O _],
  { intro [ident x],
    simp [] [] [] ["[", expr sub_smul, "]"] [] [] },
  { exact [expr is_O_fst_prod.norm_left.add is_O_snd_prod.norm_left] }
end

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f` is continuous
at `a` and `b`, then `(u, v) ↦ ∫ x in u..v, f x` has derivative `(u, v) ↦ v • cb - u • ca`
at `(a, b)` in the sense of strict differentiability. -/
theorem integral_has_strict_fderiv_at
(hf : interval_integrable f volume a b)
(hmeas_a : measurable_at_filter f (expr𝓝() a))
(hmeas_b : measurable_at_filter f (expr𝓝() b))
(ha : continuous_at f a)
(hb : continuous_at f b) : has_strict_fderiv_at (λ
 p : «expr × »(exprℝ(), exprℝ()), «expr∫ in .. , »((x), p.1, p.2, f x)) «expr - »((snd exprℝ() exprℝ() exprℝ()).smul_right (f b), (fst exprℝ() exprℝ() exprℝ()).smul_right (f a)) (a, b) :=
integral_has_strict_fderiv_at_of_tendsto_ae hf hmeas_a hmeas_b (ha.mono_left inf_le_left) (hb.mono_left inf_le_left)

/-- **First Fundamental Theorem of Calculus**: if `f : ℝ → E` is integrable on `a..b` and `f x` has
a finite limit `c` almost surely at `b`, then `u ↦ ∫ x in a..u, f x` has derivative `c` at `b` in
the sense of strict differentiability. -/
theorem integral_has_strict_deriv_at_of_tendsto_ae_right (hf : IntervalIntegrable f volume a b)
  (hmeas : MeasurableAtFilter f (𝓝 b)) (hb : tendsto f (𝓝 b⊓volume.ae) (𝓝 c)) :
  HasStrictDerivAt (fun u => ∫x in a..u, f x) c b :=
  integral_sub_integral_sub_linear_is_o_of_tendsto_ae_right hf hmeas hb continuous_at_snd continuous_at_fst

/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f` is continuous
at `b`, then `u ↦ ∫ x in a..u, f x` has derivative `f b` at `b` in the sense of strict
differentiability. -/
theorem integral_has_strict_deriv_at_right (hf : IntervalIntegrable f volume a b) (hmeas : MeasurableAtFilter f (𝓝 b))
  (hb : ContinuousAt f b) : HasStrictDerivAt (fun u => ∫x in a..u, f x) (f b) b :=
  integral_has_strict_deriv_at_of_tendsto_ae_right hf hmeas (hb.mono_left inf_le_left)

/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f x` has a finite
limit `c` almost surely at `a`, then `u ↦ ∫ x in u..b, f x` has derivative `-c` at `a` in the sense
of strict differentiability. -/
theorem integral_has_strict_deriv_at_of_tendsto_ae_left (hf : IntervalIntegrable f volume a b)
  (hmeas : MeasurableAtFilter f (𝓝 a)) (ha : tendsto f (𝓝 a⊓volume.ae) (𝓝 c)) :
  HasStrictDerivAt (fun u => ∫x in u..b, f x) (-c) a :=
  by 
    simpa only [←integral_symm] using (integral_has_strict_deriv_at_of_tendsto_ae_right hf.symm hmeas ha).neg

/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f` is continuous
at `a`, then `u ↦ ∫ x in u..b, f x` has derivative `-f a` at `a` in the sense of strict
differentiability. -/
theorem integral_has_strict_deriv_at_left (hf : IntervalIntegrable f volume a b) (hmeas : MeasurableAtFilter f (𝓝 a))
  (ha : ContinuousAt f a) : HasStrictDerivAt (fun u => ∫x in u..b, f x) (-f a) a :=
  by 
    simpa only [←integral_symm] using (integral_has_strict_deriv_at_right hf.symm hmeas ha).neg

/-!
#### Fréchet differentiability

In this subsection we restate results from the previous subsection in terms of `has_fderiv_at`,
`has_deriv_at`, `fderiv`, and `deriv`.
-/


-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f x` has finite
limits `ca` and `cb` almost surely as `x` tends to `a` and `b`, respectively, then
`(u, v) ↦ ∫ x in u..v, f x` has derivative `(u, v) ↦ v • cb - u • ca` at `(a, b)`. -/
theorem integral_has_fderiv_at_of_tendsto_ae
(hf : interval_integrable f volume a b)
(hmeas_a : measurable_at_filter f (expr𝓝() a))
(hmeas_b : measurable_at_filter f (expr𝓝() b))
(ha : tendsto f «expr ⊓ »(expr𝓝() a, volume.ae) (expr𝓝() ca))
(hb : tendsto f «expr ⊓ »(expr𝓝() b, volume.ae) (expr𝓝() cb)) : has_fderiv_at (λ
 p : «expr × »(exprℝ(), exprℝ()), «expr∫ in .. , »((x), p.1, p.2, f x)) «expr - »((snd exprℝ() exprℝ() exprℝ()).smul_right cb, (fst exprℝ() exprℝ() exprℝ()).smul_right ca) (a, b) :=
(integral_has_strict_fderiv_at_of_tendsto_ae hf hmeas_a hmeas_b ha hb).has_fderiv_at

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f` is continuous
at `a` and `b`, then `(u, v) ↦ ∫ x in u..v, f x` has derivative `(u, v) ↦ v • cb - u • ca`
at `(a, b)`. -/
theorem integral_has_fderiv_at
(hf : interval_integrable f volume a b)
(hmeas_a : measurable_at_filter f (expr𝓝() a))
(hmeas_b : measurable_at_filter f (expr𝓝() b))
(ha : continuous_at f a)
(hb : continuous_at f b) : has_fderiv_at (λ
 p : «expr × »(exprℝ(), exprℝ()), «expr∫ in .. , »((x), p.1, p.2, f x)) «expr - »((snd exprℝ() exprℝ() exprℝ()).smul_right (f b), (fst exprℝ() exprℝ() exprℝ()).smul_right (f a)) (a, b) :=
(integral_has_strict_fderiv_at hf hmeas_a hmeas_b ha hb).has_fderiv_at

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f x` has finite
limits `ca` and `cb` almost surely as `x` tends to `a` and `b`, respectively, then `fderiv`
derivative of `(u, v) ↦ ∫ x in u..v, f x` at `(a, b)` equals `(u, v) ↦ v • cb - u • ca`. -/
theorem fderiv_integral_of_tendsto_ae
(hf : interval_integrable f volume a b)
(hmeas_a : measurable_at_filter f (expr𝓝() a))
(hmeas_b : measurable_at_filter f (expr𝓝() b))
(ha : tendsto f «expr ⊓ »(expr𝓝() a, volume.ae) (expr𝓝() ca))
(hb : tendsto f «expr ⊓ »(expr𝓝() b, volume.ae) (expr𝓝() cb)) : «expr = »(fderiv exprℝ() (λ
  p : «expr × »(exprℝ(), exprℝ()), «expr∫ in .. , »((x), p.1, p.2, f x)) (a, b), «expr - »((snd exprℝ() exprℝ() exprℝ()).smul_right cb, (fst exprℝ() exprℝ() exprℝ()).smul_right ca)) :=
(integral_has_fderiv_at_of_tendsto_ae hf hmeas_a hmeas_b ha hb).fderiv

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f` is continuous
at `a` and `b`, then `fderiv` derivative of `(u, v) ↦ ∫ x in u..v, f x` at `(a, b)` equals `(u, v) ↦
v • cb - u • ca`. -/
theorem fderiv_integral
(hf : interval_integrable f volume a b)
(hmeas_a : measurable_at_filter f (expr𝓝() a))
(hmeas_b : measurable_at_filter f (expr𝓝() b))
(ha : continuous_at f a)
(hb : continuous_at f b) : «expr = »(fderiv exprℝ() (λ
  p : «expr × »(exprℝ(), exprℝ()), «expr∫ in .. , »((x), p.1, p.2, f x)) (a, b), «expr - »((snd exprℝ() exprℝ() exprℝ()).smul_right (f b), (fst exprℝ() exprℝ() exprℝ()).smul_right (f a))) :=
(integral_has_fderiv_at hf hmeas_a hmeas_b ha hb).fderiv

/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f x` has a finite
limit `c` almost surely at `b`, then `u ↦ ∫ x in a..u, f x` has derivative `c` at `b`. -/
theorem integral_has_deriv_at_of_tendsto_ae_right (hf : IntervalIntegrable f volume a b)
  (hmeas : MeasurableAtFilter f (𝓝 b)) (hb : tendsto f (𝓝 b⊓volume.ae) (𝓝 c)) :
  HasDerivAt (fun u => ∫x in a..u, f x) c b :=
  (integral_has_strict_deriv_at_of_tendsto_ae_right hf hmeas hb).HasDerivAt

/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f` is continuous
at `b`, then `u ↦ ∫ x in a..u, f x` has derivative `f b` at `b`. -/
theorem integral_has_deriv_at_right (hf : IntervalIntegrable f volume a b) (hmeas : MeasurableAtFilter f (𝓝 b))
  (hb : ContinuousAt f b) : HasDerivAt (fun u => ∫x in a..u, f x) (f b) b :=
  (integral_has_strict_deriv_at_right hf hmeas hb).HasDerivAt

/-- Fundamental theorem of calculus: if `f : ℝ → E` is integrable on `a..b` and `f` has a finite
limit `c` almost surely at `b`, then the derivative of `u ↦ ∫ x in a..u, f x` at `b` equals `c`. -/
theorem deriv_integral_of_tendsto_ae_right (hf : IntervalIntegrable f volume a b) (hmeas : MeasurableAtFilter f (𝓝 b))
  (hb : tendsto f (𝓝 b⊓volume.ae) (𝓝 c)) : deriv (fun u => ∫x in a..u, f x) b = c :=
  (integral_has_deriv_at_of_tendsto_ae_right hf hmeas hb).deriv

/-- Fundamental theorem of calculus: if `f : ℝ → E` is integrable on `a..b` and `f` is continuous
at `b`, then the derivative of `u ↦ ∫ x in a..u, f x` at `b` equals `f b`. -/
theorem deriv_integral_right (hf : IntervalIntegrable f volume a b) (hmeas : MeasurableAtFilter f (𝓝 b))
  (hb : ContinuousAt f b) : deriv (fun u => ∫x in a..u, f x) b = f b :=
  (integral_has_deriv_at_right hf hmeas hb).deriv

/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f x` has a finite
limit `c` almost surely at `a`, then `u ↦ ∫ x in u..b, f x` has derivative `-c` at `a`. -/
theorem integral_has_deriv_at_of_tendsto_ae_left (hf : IntervalIntegrable f volume a b)
  (hmeas : MeasurableAtFilter f (𝓝 a)) (ha : tendsto f (𝓝 a⊓volume.ae) (𝓝 c)) :
  HasDerivAt (fun u => ∫x in u..b, f x) (-c) a :=
  (integral_has_strict_deriv_at_of_tendsto_ae_left hf hmeas ha).HasDerivAt

/-- Fundamental theorem of calculus-1: if `f : ℝ → E` is integrable on `a..b` and `f` is continuous
at `a`, then `u ↦ ∫ x in u..b, f x` has derivative `-f a` at `a`. -/
theorem integral_has_deriv_at_left (hf : IntervalIntegrable f volume a b) (hmeas : MeasurableAtFilter f (𝓝 a))
  (ha : ContinuousAt f a) : HasDerivAt (fun u => ∫x in u..b, f x) (-f a) a :=
  (integral_has_strict_deriv_at_left hf hmeas ha).HasDerivAt

/-- Fundamental theorem of calculus: if `f : ℝ → E` is integrable on `a..b` and `f` has a finite
limit `c` almost surely at `a`, then the derivative of `u ↦ ∫ x in u..b, f x` at `a` equals `-c`. -/
theorem deriv_integral_of_tendsto_ae_left (hf : IntervalIntegrable f volume a b) (hmeas : MeasurableAtFilter f (𝓝 a))
  (hb : tendsto f (𝓝 a⊓volume.ae) (𝓝 c)) : deriv (fun u => ∫x in u..b, f x) a = -c :=
  (integral_has_deriv_at_of_tendsto_ae_left hf hmeas hb).deriv

/-- Fundamental theorem of calculus: if `f : ℝ → E` is integrable on `a..b` and `f` is continuous
at `a`, then the derivative of `u ↦ ∫ x in u..b, f x` at `a` equals `-f a`. -/
theorem deriv_integral_left (hf : IntervalIntegrable f volume a b) (hmeas : MeasurableAtFilter f (𝓝 a))
  (hb : ContinuousAt f a) : deriv (fun u => ∫x in u..b, f x) a = -f a :=
  (integral_has_deriv_at_left hf hmeas hb).deriv

/-!
#### One-sided derivatives
-/


-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Let `f` be a measurable function integrable on `a..b`. The function `(u, v) ↦ ∫ x in u..v, f x`
has derivative `(u, v) ↦ v • cb - u • ca` within `s × t` at `(a, b)`, where
`s ∈ {Iic a, {a}, Ici a, univ}` and `t ∈ {Iic b, {b}, Ici b, univ}` provided that `f` tends to `ca`
and `cb` almost surely at the filters `la` and `lb` from the following table.

| `s`     | `la`         | `t`     | `lb`         |
| ------- | ----         | ---     | ----         |
| `Iic a` | `𝓝[Iic a] a` | `Iic b` | `𝓝[Iic b] b` |
| `Ici a` | `𝓝[Ioi a] a` | `Ici b` | `𝓝[Ioi b] b` |
| `{a}`   | `⊥`          | `{b}`   | `⊥`          |
| `univ`  | `𝓝 a`        | `univ`  | `𝓝 b`        |
-/
theorem integral_has_fderiv_within_at_of_tendsto_ae
(hf : interval_integrable f volume a b)
{s t : set exprℝ()}
[FTC_filter a «expr𝓝[ ] »(s, a) la]
[FTC_filter b «expr𝓝[ ] »(t, b) lb]
(hmeas_a : measurable_at_filter f la)
(hmeas_b : measurable_at_filter f lb)
(ha : tendsto f «expr ⊓ »(la, volume.ae) (expr𝓝() ca))
(hb : tendsto f «expr ⊓ »(lb, volume.ae) (expr𝓝() cb)) : has_fderiv_within_at (λ
 p : «expr × »(exprℝ(), exprℝ()), «expr∫ in .. , »((x), p.1, p.2, f x)) «expr - »((snd exprℝ() exprℝ() exprℝ()).smul_right cb, (fst exprℝ() exprℝ() exprℝ()).smul_right ca) (s.prod t) (a, b) :=
begin
  rw ["[", expr has_fderiv_within_at, ",", expr nhds_within_prod_eq, "]"] [],
  have [] [] [":=", expr integral_sub_integral_sub_linear_is_o_of_tendsto_ae hf hmeas_a hmeas_b ha hb (tendsto_const_pure.mono_right FTC_filter.pure_le : tendsto _ _ «expr𝓝[ ] »(s, a)) tendsto_fst (tendsto_const_pure.mono_right FTC_filter.pure_le : tendsto _ _ «expr𝓝[ ] »(t, b)) tendsto_snd],
  refine [expr (this.congr_left _).trans_is_O _],
  { intro [ident x],
    simp [] [] [] ["[", expr sub_smul, "]"] [] [] },
  { exact [expr is_O_fst_prod.norm_left.add is_O_snd_prod.norm_left] }
end

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Let `f` be a measurable function integrable on `a..b`. The function `(u, v) ↦ ∫ x in u..v, f x`
has derivative `(u, v) ↦ v • f b - u • f a` within `s × t` at `(a, b)`, where
`s ∈ {Iic a, {a}, Ici a, univ}` and `t ∈ {Iic b, {b}, Ici b, univ}` provided that `f` tends to
`f a` and `f b` at the filters `la` and `lb` from the following table. In most cases this assumption
is definitionally equal `continuous_at f _` or `continuous_within_at f _ _`.

| `s`     | `la`         | `t`     | `lb`         |
| ------- | ----         | ---     | ----         |
| `Iic a` | `𝓝[Iic a] a` | `Iic b` | `𝓝[Iic b] b` |
| `Ici a` | `𝓝[Ioi a] a` | `Ici b` | `𝓝[Ioi b] b` |
| `{a}`   | `⊥`          | `{b}`   | `⊥`          |
| `univ`  | `𝓝 a`        | `univ`  | `𝓝 b`        |
-/
theorem integral_has_fderiv_within_at
(hf : interval_integrable f volume a b)
(hmeas_a : measurable_at_filter f la)
(hmeas_b : measurable_at_filter f lb)
{s t : set exprℝ()}
[FTC_filter a «expr𝓝[ ] »(s, a) la]
[FTC_filter b «expr𝓝[ ] »(t, b) lb]
(ha : tendsto f la «expr $ »(expr𝓝(), f a))
(hb : tendsto f lb «expr $ »(expr𝓝(), f b)) : has_fderiv_within_at (λ
 p : «expr × »(exprℝ(), exprℝ()), «expr∫ in .. , »((x), p.1, p.2, f x)) «expr - »((snd exprℝ() exprℝ() exprℝ()).smul_right (f b), (fst exprℝ() exprℝ() exprℝ()).smul_right (f a)) (s.prod t) (a, b) :=
integral_has_fderiv_within_at_of_tendsto_ae hf hmeas_a hmeas_b (ha.mono_left inf_le_left) (hb.mono_left inf_le_left)

/-- An auxiliary tactic closing goals `unique_diff_within_at ℝ s a` where
`s ∈ {Iic a, Ici a, univ}`. -/
unsafe def unique_diff_within_at_Ici_Iic_univ : tactic Unit :=
  sorry

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Let `f` be a measurable function integrable on `a..b`. Choose `s ∈ {Iic a, Ici a, univ}`
and `t ∈ {Iic b, Ici b, univ}`. Suppose that `f` tends to `ca` and `cb` almost surely at the filters
`la` and `lb` from the table below. Then `fderiv_within ℝ (λ p, ∫ x in p.1..p.2, f x) (s.prod t)`
is equal to `(u, v) ↦ u • cb - v • ca`.

| `s`     | `la`         | `t`     | `lb`         |
| ------- | ----         | ---     | ----         |
| `Iic a` | `𝓝[Iic a] a` | `Iic b` | `𝓝[Iic b] b` |
| `Ici a` | `𝓝[Ioi a] a` | `Ici b` | `𝓝[Ioi b] b` |
| `univ`  | `𝓝 a`        | `univ`  | `𝓝 b`        |

-/
theorem fderiv_within_integral_of_tendsto_ae
(hf : interval_integrable f volume a b)
(hmeas_a : measurable_at_filter f la)
(hmeas_b : measurable_at_filter f lb)
{s t : set exprℝ()}
[FTC_filter a «expr𝓝[ ] »(s, a) la]
[FTC_filter b «expr𝓝[ ] »(t, b) lb]
(ha : tendsto f «expr ⊓ »(la, volume.ae) (expr𝓝() ca))
(hb : tendsto f «expr ⊓ »(lb, volume.ae) (expr𝓝() cb))
(hs : unique_diff_within_at exprℝ() s a . unique_diff_within_at_Ici_Iic_univ)
(ht : unique_diff_within_at exprℝ() t b . unique_diff_within_at_Ici_Iic_univ) : «expr = »(fderiv_within exprℝ() (λ
  p : «expr × »(exprℝ(), exprℝ()), «expr∫ in .. , »((x), p.1, p.2, f x)) (s.prod t) (a, b), «expr - »((snd exprℝ() exprℝ() exprℝ()).smul_right cb, (fst exprℝ() exprℝ() exprℝ()).smul_right ca)) :=
«expr $ »((integral_has_fderiv_within_at_of_tendsto_ae hf hmeas_a hmeas_b ha hb).fderiv_within, hs.prod ht)

/-- Fundamental theorem of calculus: if `f : ℝ → E` is integrable on `a..b` and `f x` has a finite
limit `c` almost surely as `x` tends to `b` from the right or from the left,
then `u ↦ ∫ x in a..u, f x` has right (resp., left) derivative `c` at `b`. -/
theorem integral_has_deriv_within_at_of_tendsto_ae_right (hf : IntervalIntegrable f volume a b) {s t : Set ℝ}
  [FTC_filter b (𝓝[s] b) (𝓝[t] b)] (hmeas : MeasurableAtFilter f (𝓝[t] b)) (hb : tendsto f (𝓝[t] b⊓volume.ae) (𝓝 c)) :
  HasDerivWithinAt (fun u => ∫x in a..u, f x) c s b :=
  integral_sub_integral_sub_linear_is_o_of_tendsto_ae_right hf hmeas hb
    (tendsto_const_pure.mono_right FTC_filter.pure_le) tendsto_id

/-- Fundamental theorem of calculus: if `f : ℝ → E` is integrable on `a..b` and `f x` is continuous
from the left or from the right at `b`, then `u ↦ ∫ x in a..u, f x` has left (resp., right)
derivative `f b` at `b`. -/
theorem integral_has_deriv_within_at_right (hf : IntervalIntegrable f volume a b) {s t : Set ℝ}
  [FTC_filter b (𝓝[s] b) (𝓝[t] b)] (hmeas : MeasurableAtFilter f (𝓝[t] b)) (hb : ContinuousWithinAt f t b) :
  HasDerivWithinAt (fun u => ∫x in a..u, f x) (f b) s b :=
  integral_has_deriv_within_at_of_tendsto_ae_right hf hmeas (hb.mono_left inf_le_left)

/-- Fundamental theorem of calculus: if `f : ℝ → E` is integrable on `a..b` and `f x` has a finite
limit `c` almost surely as `x` tends to `b` from the right or from the left, then the right
(resp., left) derivative of `u ↦ ∫ x in a..u, f x` at `b` equals `c`. -/
theorem deriv_within_integral_of_tendsto_ae_right (hf : IntervalIntegrable f volume a b) {s t : Set ℝ}
  [FTC_filter b (𝓝[s] b) (𝓝[t] b)] (hmeas : MeasurableAtFilter f (𝓝[t] b)) (hb : tendsto f (𝓝[t] b⊓volume.ae) (𝓝 c))
  (hs : UniqueDiffWithinAt ℝ s b :=  by 
    runTac 
      unique_diff_within_at_Ici_Iic_univ) :
  derivWithin (fun u => ∫x in a..u, f x) s b = c :=
  (integral_has_deriv_within_at_of_tendsto_ae_right hf hmeas hb).derivWithin hs

/-- Fundamental theorem of calculus: if `f : ℝ → E` is integrable on `a..b` and `f x` is continuous
on the right or on the left at `b`, then the right (resp., left) derivative of
`u ↦ ∫ x in a..u, f x` at `b` equals `f b`. -/
theorem deriv_within_integral_right (hf : IntervalIntegrable f volume a b) {s t : Set ℝ}
  [FTC_filter b (𝓝[s] b) (𝓝[t] b)] (hmeas : MeasurableAtFilter f (𝓝[t] b)) (hb : ContinuousWithinAt f t b)
  (hs : UniqueDiffWithinAt ℝ s b :=  by 
    runTac 
      unique_diff_within_at_Ici_Iic_univ) :
  derivWithin (fun u => ∫x in a..u, f x) s b = f b :=
  (integral_has_deriv_within_at_right hf hmeas hb).derivWithin hs

/-- Fundamental theorem of calculus: if `f : ℝ → E` is integrable on `a..b` and `f x` has a finite
limit `c` almost surely as `x` tends to `a` from the right or from the left,
then `u ↦ ∫ x in u..b, f x` has right (resp., left) derivative `-c` at `a`. -/
theorem integral_has_deriv_within_at_of_tendsto_ae_left (hf : IntervalIntegrable f volume a b) {s t : Set ℝ}
  [FTC_filter a (𝓝[s] a) (𝓝[t] a)] (hmeas : MeasurableAtFilter f (𝓝[t] a)) (ha : tendsto f (𝓝[t] a⊓volume.ae) (𝓝 c)) :
  HasDerivWithinAt (fun u => ∫x in u..b, f x) (-c) s a :=
  by 
    simp only [integral_symm b]
    exact (integral_has_deriv_within_at_of_tendsto_ae_right hf.symm hmeas ha).neg

/-- Fundamental theorem of calculus: if `f : ℝ → E` is integrable on `a..b` and `f x` is continuous
from the left or from the right at `a`, then `u ↦ ∫ x in u..b, f x` has left (resp., right)
derivative `-f a` at `a`. -/
theorem integral_has_deriv_within_at_left (hf : IntervalIntegrable f volume a b) {s t : Set ℝ}
  [FTC_filter a (𝓝[s] a) (𝓝[t] a)] (hmeas : MeasurableAtFilter f (𝓝[t] a)) (ha : ContinuousWithinAt f t a) :
  HasDerivWithinAt (fun u => ∫x in u..b, f x) (-f a) s a :=
  integral_has_deriv_within_at_of_tendsto_ae_left hf hmeas (ha.mono_left inf_le_left)

/-- Fundamental theorem of calculus: if `f : ℝ → E` is integrable on `a..b` and `f x` has a finite
limit `c` almost surely as `x` tends to `a` from the right or from the left, then the right
(resp., left) derivative of `u ↦ ∫ x in u..b, f x` at `a` equals `-c`. -/
theorem deriv_within_integral_of_tendsto_ae_left (hf : IntervalIntegrable f volume a b) {s t : Set ℝ}
  [FTC_filter a (𝓝[s] a) (𝓝[t] a)] (hmeas : MeasurableAtFilter f (𝓝[t] a)) (ha : tendsto f (𝓝[t] a⊓volume.ae) (𝓝 c))
  (hs : UniqueDiffWithinAt ℝ s a :=  by 
    runTac 
      unique_diff_within_at_Ici_Iic_univ) :
  derivWithin (fun u => ∫x in u..b, f x) s a = -c :=
  (integral_has_deriv_within_at_of_tendsto_ae_left hf hmeas ha).derivWithin hs

/-- Fundamental theorem of calculus: if `f : ℝ → E` is integrable on `a..b` and `f x` is continuous
on the right or on the left at `a`, then the right (resp., left) derivative of
`u ↦ ∫ x in u..b, f x` at `a` equals `-f a`. -/
theorem deriv_within_integral_left (hf : IntervalIntegrable f volume a b) {s t : Set ℝ} [FTC_filter a (𝓝[s] a) (𝓝[t] a)]
  (hmeas : MeasurableAtFilter f (𝓝[t] a)) (ha : ContinuousWithinAt f t a)
  (hs : UniqueDiffWithinAt ℝ s a :=  by 
    runTac 
      unique_diff_within_at_Ici_Iic_univ) :
  derivWithin (fun u => ∫x in u..b, f x) s a = -f a :=
  (integral_has_deriv_within_at_left hf hmeas ha).derivWithin hs

/-- The integral of a continuous function is differentiable on a real set `s`. -/
theorem differentiable_on_integral_of_continuous {s : Set ℝ} (hintg : ∀ x (_ : x ∈ s), IntervalIntegrable f volume a x)
  (hcont : Continuous f) : DifferentiableOn ℝ (fun u => ∫x in a..u, f x) s :=
  fun y hy =>
    (integral_has_deriv_at_right (hintg y hy) hcont.measurable.ae_measurable.measurable_at_filter
          hcont.continuous_at).DifferentiableAt.DifferentiableWithinAt

/-!
### Fundamental theorem of calculus, part 2

This section contains theorems pertaining to FTC-2 for interval integrals, i.e., the assertion
that `∫ x in a..b, f' x = f b - f a` under suitable assumptions.

The most classical version of this theorem assumes that `f'` is continuous. However, this is
unnecessarily strong: the result holds if `f'` is just integrable. We prove the strong version,
following [Rudin, *Real and Complex Analysis* (Theorem 7.21)][rudin2006real]. The proof is first
given for real-valued functions, and then deduced for functions with a general target space. For
a real-valued function `g`, it suffices to show that `g b - g a ≤ (∫ x in a..b, g' x) + ε` for all
positive `ε`. To prove this, choose a lower-semicontinuous function `G'` with `g' < G'` and with
integral close to that of `g'` (its existence is guaranteed by the Vitali-Carathéodory theorem).
It satisfies `g t - g a ≤ ∫ x in a..t, G' x` for all `t ∈ [a, b]`: this inequality holds at `a`,
and if it holds at `t` then it holds for `u` close to `t` on its right, as the left hand side
increases by `g u - g t ∼ (u -t) g' t`, while the right hand side increases by
`∫ x in t..u, G' x` which is roughly at least `∫ x in t..u, G' t = (u - t) G' t`, by lower
semicontinuity. As  `g' t < G' t`, this gives the conclusion. One can therefore push progressively
this inequality to the right until the point `b`, where it gives the desired conclusion.
-/


variable{g' g : ℝ → ℝ}

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Hard part of FTC-2 for integrable derivatives, real-valued functions: one has
`g b - g a ≤ ∫ y in a..b, g' y`.
Auxiliary lemma in the proof of `integral_eq_sub_of_has_deriv_right_of_le`. -/
theorem sub_le_integral_of_has_deriv_right_of_le
(hab : «expr ≤ »(a, b))
(hcont : continuous_on g (Icc a b))
(hderiv : ∀ x «expr ∈ » Ico a b, has_deriv_within_at g (g' x) (Ioi x) x)
(g'int : integrable_on g' (Icc a b)) : «expr ≤ »(«expr - »(g b, g a), «expr∫ in .. , »((y), a, b, g' y)) :=
begin
  refine [expr le_of_forall_pos_le_add (λ ε εpos, _)],
  rcases [expr exists_lt_lower_semicontinuous_integral_lt g' g'int εpos, "with", "⟨", ident G', ",", ident g'_lt_G', ",", ident G'cont, ",", ident G'int, ",", ident G'lt_top, ",", ident hG', "⟩"],
  set [] [ident s] [] [":="] [expr «expr ∩ »({t | «expr ≤ »(«expr - »(g t, g a), «expr∫ in .. , »((u), a, t, (G' u).to_real))}, Icc a b)] [],
  have [ident s_closed] [":", expr is_closed s] [],
  { have [] [":", expr continuous_on (λ
      t, («expr - »(g t, g a), «expr∫ in .. , »((u), a, t, (G' u).to_real))) (Icc a b)] [],
    { rw ["<-", expr interval_of_le hab] ["at", ident G'int, "⊢", ident hcont],
      exact [expr (hcont.sub continuous_on_const).prod (continuous_on_primitive_interval G'int)] },
    simp [] [] ["only"] ["[", expr s, ",", expr inter_comm, "]"] [] [],
    exact [expr this.preimage_closed_of_closed is_closed_Icc order_closed_topology.is_closed_le'] },
  have [ident main] [":", expr «expr ⊆ »(Icc a b, {t | «expr ≤ »(«expr - »(g t, g a), «expr∫ in .. , »((u), a, t, (G' u).to_real))})] [],
  { apply [expr s_closed.Icc_subset_of_forall_exists_gt (by simp [] [] ["only"] ["[", expr integral_same, ",", expr mem_set_of_eq, ",", expr sub_self, "]"] [] []) (λ
      t ht v t_lt_v, _)],
    obtain ["⟨", ident y, ",", ident g'_lt_y', ",", ident y_lt_G', "⟩", ":", expr «expr∃ , »((y : exprℝ()), «expr ∧ »(«expr < »((g' t : ereal), y), «expr < »((y : ereal), G' t))), ":=", expr ereal.lt_iff_exists_real_btwn.1 (g'_lt_G' t)],
    have [ident I1] [":", expr «expr∀ᶠ in , »((u), «expr𝓝[ ] »(Ioi t, t), «expr ≤ »(«expr * »(«expr - »(u, t), y), «expr∫ in .. , »((w), t, u, (G' w).to_real)))] [],
    { have [ident B] [":", expr «expr∀ᶠ in , »((u), expr𝓝() t, «expr < »((y : ereal), G' u))] [":=", expr G'cont.lower_semicontinuous_at _ _ y_lt_G'],
      rcases [expr mem_nhds_iff_exists_Ioo_subset.1 B, "with", "⟨", ident m, ",", ident M, ",", "⟨", ident hm, ",", ident hM, "⟩", ",", ident H, "⟩"],
      have [] [":", expr «expr ∈ »(Ioo t (min M b), «expr𝓝[ ] »(Ioi t, t))] [":=", expr mem_nhds_within_Ioi_iff_exists_Ioo_subset.2 ⟨min M b, by simp [] [] ["only"] ["[", expr hM, ",", expr ht.right.right, ",", expr lt_min_iff, ",", expr mem_Ioi, ",", expr and_self, "]"] [] [], subset.refl _⟩],
      filter_upwards ["[", expr this, "]"] [],
      assume [binders (u hu)],
      have [ident I] [":", expr «expr ⊆ »(Icc t u, Icc a b)] [":=", expr Icc_subset_Icc ht.2.1 (hu.2.le.trans (min_le_right _ _))],
      calc
        «expr = »(«expr * »(«expr - »(u, t), y), «expr∫ in , »((v), Icc t u, y)) : by simp [] [] ["only"] ["[", expr hu.left.le, ",", expr measure_theory.integral_const, ",", expr algebra.id.smul_eq_mul, ",", expr sub_nonneg, ",", expr measurable_set.univ, ",", expr real.volume_Icc, ",", expr measure.restrict_apply, ",", expr univ_inter, ",", expr ennreal.to_real_of_real, "]"] [] []
        «expr ≤ »(..., «expr∫ in .. , »((w), t, u, (G' w).to_real)) : begin
          rw ["[", expr interval_integral.integral_of_le hu.1.le, ",", "<-", expr integral_Icc_eq_integral_Ioc, "]"] [],
          apply [expr set_integral_mono_ae_restrict],
          { simp [] [] ["only"] ["[", expr integrable_on_const, ",", expr real.volume_Icc, ",", expr ennreal.of_real_lt_top, ",", expr or_true, "]"] [] [] },
          { exact [expr integrable_on.mono_set G'int I] },
          { have [ident C1] [":", expr «expr∀ᵐ ∂ , »((x : exprℝ()), volume.restrict (Icc t u), «expr < »(G' x, «expr⊤»()))] [":=", expr ae_mono (measure.restrict_mono I (le_refl _)) G'lt_top],
            have [ident C2] [":", expr «expr∀ᵐ ∂ , »((x : exprℝ()), volume.restrict (Icc t u), «expr ∈ »(x, Icc t u))] [":=", expr ae_restrict_mem measurable_set_Icc],
            filter_upwards ["[", expr C1, ",", expr C2, "]"] [],
            assume [binders (x G'x hx)],
            apply [expr ereal.coe_le_coe_iff.1],
            have [] [":", expr «expr ∈ »(x, Ioo m M)] [],
            by simp [] [] ["only"] ["[", expr hm.trans_le hx.left, ",", expr (hx.right.trans_lt hu.right).trans_le (min_le_left M b), ",", expr mem_Ioo, ",", expr and_self, "]"] [] [],
            convert [] [expr le_of_lt (H this)] [],
            exact [expr ereal.coe_to_real G'x.ne (ne_bot_of_gt (g'_lt_G' x))] }
        end },
    have [ident I2] [":", expr «expr∀ᶠ in , »((u), «expr𝓝[ ] »(Ioi t, t), «expr ≤ »(«expr - »(g u, g t), «expr * »(«expr - »(u, t), y)))] [],
    { have [ident g'_lt_y] [":", expr «expr < »(g' t, y)] [":=", expr ereal.coe_lt_coe_iff.1 g'_lt_y'],
      filter_upwards ["[", expr (hderiv t ⟨ht.2.1, ht.2.2⟩).limsup_slope_le' (not_mem_Ioi.2 le_rfl) g'_lt_y, ",", expr self_mem_nhds_within, "]"] [],
      assume [binders (u hu t_lt_u)],
      have [] [] [":=", expr hu.le],
      rwa ["[", "<-", expr div_eq_inv_mul, ",", expr div_le_iff', "]"] ["at", ident this],
      exact [expr sub_pos.2 t_lt_u] },
    have [ident I3] [":", expr «expr∀ᶠ in , »((u), «expr𝓝[ ] »(Ioi t, t), «expr ≤ »(«expr - »(g u, g t), «expr∫ in .. , »((w), t, u, (G' w).to_real)))] [],
    { filter_upwards ["[", expr I1, ",", expr I2, "]"] [],
      assume [binders (u hu1 hu2)],
      exact [expr hu2.trans hu1] },
    have [ident I4] [":", expr «expr∀ᶠ in , »((u), «expr𝓝[ ] »(Ioi t, t), «expr ∈ »(u, Ioc t (min v b)))] [],
    { refine [expr mem_nhds_within_Ioi_iff_exists_Ioc_subset.2 ⟨min v b, _, subset.refl _⟩],
      simp [] [] ["only"] ["[", expr lt_min_iff, ",", expr mem_Ioi, "]"] [] [],
      exact [expr ⟨t_lt_v, ht.2.2⟩] },
    rcases [expr (I3.and I4).exists, "with", "⟨", ident x, ",", ident hx, ",", ident h'x, "⟩"],
    refine [expr ⟨x, _, Ioc_subset_Ioc (le_refl _) (min_le_left _ _) h'x⟩],
    calc
      «expr = »(«expr - »(g x, g a), «expr + »(«expr - »(g t, g a), «expr - »(g x, g t))) : by abel [] [] []
      «expr ≤ »(..., «expr + »(«expr∫ in .. , »((w), a, t, (G' w).to_real), «expr∫ in .. , »((w), t, x, (G' w).to_real))) : add_le_add ht.1 hx
      «expr = »(..., «expr∫ in .. , »((w), a, x, (G' w).to_real)) : begin
        apply [expr integral_add_adjacent_intervals],
        { rw [expr interval_integrable_iff_integrable_Ioc_of_le ht.2.1] [],
          exact [expr integrable_on.mono_set G'int (Ioc_subset_Icc_self.trans (Icc_subset_Icc le_rfl ht.2.2.le))] },
        { rw [expr interval_integrable_iff_integrable_Ioc_of_le h'x.1.le] [],
          apply [expr integrable_on.mono_set G'int],
          refine [expr Ioc_subset_Icc_self.trans (Icc_subset_Icc ht.2.1 (h'x.2.trans (min_le_right _ _)))] }
      end },
  calc
    «expr ≤ »(«expr - »(g b, g a), «expr∫ in .. , »((y), a, b, (G' y).to_real)) : main (right_mem_Icc.2 hab)
    «expr ≤ »(..., «expr + »(«expr∫ in .. , »((y), a, b, g' y), ε)) : begin
      convert [] [expr hG'.le] []; { rw [expr interval_integral.integral_of_le hab] [],
        simp [] [] ["only"] ["[", expr integral_Icc_eq_integral_Ioc', ",", expr real.volume_singleton, "]"] [] [] }
    end
end

/-- Auxiliary lemma in the proof of `integral_eq_sub_of_has_deriv_right_of_le`. -/
theorem integral_le_sub_of_has_deriv_right_of_le (hab : a ≤ b) (hcont : ContinuousOn g (Icc a b))
  (hderiv : ∀ x (_ : x ∈ Ico a b), HasDerivWithinAt g (g' x) (Ioi x) x) (g'int : integrable_on g' (Icc a b)) :
  (∫y in a..b, g' y) ≤ g b - g a :=
  by 
    rw [←neg_le_neg_iff]
    convert sub_le_integral_of_has_deriv_right_of_le hab hcont.neg (fun x hx => (hderiv x hx).neg) g'int.neg
    ·
      abel
    ·
      simp only [integral_neg]

/-- Auxiliary lemma in the proof of `integral_eq_sub_of_has_deriv_right_of_le`: real version -/
theorem integral_eq_sub_of_has_deriv_right_of_le_real (hab : a ≤ b) (hcont : ContinuousOn g (Icc a b))
  (hderiv : ∀ x (_ : x ∈ Ico a b), HasDerivWithinAt g (g' x) (Ioi x) x) (g'int : integrable_on g' (Icc a b)) :
  (∫y in a..b, g' y) = g b - g a :=
  le_antisymmₓ (integral_le_sub_of_has_deriv_right_of_le hab hcont hderiv g'int)
    (sub_le_integral_of_has_deriv_right_of_le hab hcont hderiv g'int)

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Auxiliary lemma in the proof of `integral_eq_sub_of_has_deriv_right_of_le`: real version, not
requiring differentiability as the left endpoint of the interval. Follows from
`integral_eq_sub_of_has_deriv_right_of_le_real` together with a continuity argument. -/
theorem integral_eq_sub_of_has_deriv_right_of_le_real'
(hab : «expr ≤ »(a, b))
(hcont : continuous_on g (Icc a b))
(hderiv : ∀ x «expr ∈ » Ioo a b, has_deriv_within_at g (g' x) (Ioi x) x)
(g'int : integrable_on g' (Icc a b)) : «expr = »(«expr∫ in .. , »((y), a, b, g' y), «expr - »(g b, g a)) :=
begin
  obtain [ident rfl, "|", ident a_lt_b, ":=", expr hab.eq_or_lt],
  { simp [] [] [] [] [] [] },
  set [] [ident s] [] [":="] [expr «expr ∩ »({t | «expr = »(«expr∫ in .. , »((u), t, b, g' u), «expr - »(g b, g t))}, Icc a b)] [],
  have [ident s_closed] [":", expr is_closed s] [],
  { have [] [":", expr continuous_on (λ t, («expr∫ in .. , »((u), t, b, g' u), «expr - »(g b, g t))) (Icc a b)] [],
    { rw ["<-", expr interval_of_le hab] ["at", "⊢", ident hcont, ident g'int],
      exact [expr (continuous_on_primitive_interval_left g'int).prod (continuous_on_const.sub hcont)] },
    simp [] [] ["only"] ["[", expr s, ",", expr inter_comm, "]"] [] [],
    exact [expr this.preimage_closed_of_closed is_closed_Icc is_closed_diagonal] },
  have [ident A] [":", expr «expr ⊆ »(closure (Ioc a b), s)] [],
  { apply [expr s_closed.closure_subset_iff.2],
    assume [binders (t ht)],
    refine [expr ⟨_, ⟨ht.1.le, ht.2⟩⟩],
    exact [expr integral_eq_sub_of_has_deriv_right_of_le_real ht.2 (hcont.mono (Icc_subset_Icc ht.1.le (le_refl _))) (λ
      x hx, hderiv x ⟨ht.1.trans_le hx.1, hx.2⟩) (g'int.mono_set (Icc_subset_Icc ht.1.le (le_refl _)))] },
  rw [expr closure_Ioc a_lt_b] ["at", ident A],
  exact [expr (A (left_mem_Icc.2 hab)).1]
end

variable{f' : ℝ → E}

/-- **Fundamental theorem of calculus-2**: If `f : ℝ → E` is continuous on `[a, b]` (where `a ≤ b`)
  and has a right derivative at `f' x` for all `x` in `(a, b)`, and `f'` is integrable on `[a, b]`,
  then `∫ y in a..b, f' y` equals `f b - f a`. -/
theorem integral_eq_sub_of_has_deriv_right_of_le (hab : a ≤ b) (hcont : ContinuousOn f (Icc a b))
  (hderiv : ∀ x (_ : x ∈ Ioo a b), HasDerivWithinAt f (f' x) (Ioi x) x) (f'int : IntervalIntegrable f' volume a b) :
  (∫y in a..b, f' y) = f b - f a :=
  by 
    refine' (NormedSpace.eq_iff_forall_dual_eq ℝ).2 fun g => _ 
    rw [←g.interval_integral_comp_comm f'int, g.map_sub]
    exact
      integral_eq_sub_of_has_deriv_right_of_le_real' hab (g.continuous.comp_continuous_on hcont)
        (fun x hx => g.has_fderiv_at.comp_has_deriv_within_at x (hderiv x hx))
        (g.integrable_comp ((interval_integrable_iff_integrable_Icc_of_le hab).1 f'int))

/-- Fundamental theorem of calculus-2: If `f : ℝ → E` is continuous on `[a, b]` and
  has a right derivative at `f' x` for all `x` in `[a, b)`, and `f'` is integrable on `[a, b]` then
  `∫ y in a..b, f' y` equals `f b - f a`. -/
theorem integral_eq_sub_of_has_deriv_right (hcont : ContinuousOn f (interval a b))
  (hderiv : ∀ x (_ : x ∈ Ioo (min a b) (max a b)), HasDerivWithinAt f (f' x) (Ioi x) x)
  (hint : IntervalIntegrable f' volume a b) : (∫y in a..b, f' y) = f b - f a :=
  by 
    cases' le_totalₓ a b with hab hab
    ·
      simp only [interval_of_le, min_eq_leftₓ, max_eq_rightₓ, hab] at hcont hderiv hint 
      apply integral_eq_sub_of_has_deriv_right_of_le hab hcont hderiv hint
    ·
      simp only [interval_of_ge, min_eq_rightₓ, max_eq_leftₓ, hab] at hcont hderiv 
      rw [integral_symm, integral_eq_sub_of_has_deriv_right_of_le hab hcont hderiv hint.symm, neg_sub]

/-- Fundamental theorem of calculus-2: If `f : ℝ → E` is continuous on `[a, b]` (where `a ≤ b`) and
  has a derivative at `f' x` for all `x` in `(a, b)`, and `f'` is integrable on `[a, b]`, then
  `∫ y in a..b, f' y` equals `f b - f a`. -/
theorem integral_eq_sub_of_has_deriv_at_of_le (hab : a ≤ b) (hcont : ContinuousOn f (Icc a b))
  (hderiv : ∀ x (_ : x ∈ Ioo a b), HasDerivAt f (f' x) x) (hint : IntervalIntegrable f' volume a b) :
  (∫y in a..b, f' y) = f b - f a :=
  integral_eq_sub_of_has_deriv_right_of_le hab hcont (fun x hx => (hderiv x hx).HasDerivWithinAt) hint

/-- Fundamental theorem of calculus-2: If `f : ℝ → E` has a derivative at `f' x` for all `x` in
  `[a, b]` and `f'` is integrable on `[a, b]`, then `∫ y in a..b, f' y` equals `f b - f a`. -/
theorem integral_eq_sub_of_has_deriv_at (hderiv : ∀ x (_ : x ∈ interval a b), HasDerivAt f (f' x) x)
  (hint : IntervalIntegrable f' volume a b) : (∫y in a..b, f' y) = f b - f a :=
  integral_eq_sub_of_has_deriv_right (HasDerivAt.continuous_on hderiv)
    (fun x hx => (hderiv _ (mem_Icc_of_Ioo hx)).HasDerivWithinAt) hint

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem integral_eq_sub_of_has_deriv_at_of_tendsto
(hab : «expr < »(a, b))
{fa fb}
(hderiv : ∀ x «expr ∈ » Ioo a b, has_deriv_at f (f' x) x)
(hint : interval_integrable f' volume a b)
(ha : tendsto f «expr𝓝[ ] »(Ioi a, a) (expr𝓝() fa))
(hb : tendsto f «expr𝓝[ ] »(Iio b, b) (expr𝓝() fb)) : «expr = »(«expr∫ in .. , »((y), a, b, f' y), «expr - »(fb, fa)) :=
begin
  set [] [ident F] [":", expr exprℝ() → E] [":="] [expr update (update f a fa) b fb] [],
  have [ident Fderiv] [":", expr ∀ x «expr ∈ » Ioo a b, has_deriv_at F (f' x) x] [],
  { refine [expr λ x hx, (hderiv x hx).congr_of_eventually_eq _],
    filter_upwards ["[", expr Ioo_mem_nhds hx.1 hx.2, "]"] [],
    intros [ident y, ident hy],
    simp [] [] ["only"] ["[", expr F, "]"] [] [],
    rw ["[", expr update_noteq hy.2.ne, ",", expr update_noteq hy.1.ne', "]"] [] },
  have [ident hcont] [":", expr continuous_on F (Icc a b)] [],
  { rw ["[", expr continuous_on_update_iff, ",", expr continuous_on_update_iff, ",", expr Icc_diff_right, ",", expr Ico_diff_left, "]"] [],
    refine [expr ⟨⟨λ z hz, (hderiv z hz).continuous_at.continuous_within_at, _⟩, _⟩],
    { exact [expr λ _, ha.mono_left (nhds_within_mono _ Ioo_subset_Ioi_self)] },
    { rintro ["-"],
      refine [expr (hb.congr' _).mono_left (nhds_within_mono _ Ico_subset_Iio_self)],
      filter_upwards ["[", expr Ioo_mem_nhds_within_Iio (right_mem_Ioc.2 hab), "]"] [],
      exact [expr λ z hz, (update_noteq hz.1.ne' _ _).symm] } },
  simpa [] [] [] ["[", expr F, ",", expr hab.ne, ",", expr hab.ne', "]"] [] ["using", expr integral_eq_sub_of_has_deriv_at_of_le hab.le hcont Fderiv hint]
end

/-- Fundamental theorem of calculus-2: If `f : ℝ → E` is differentiable at every `x` in `[a, b]` and
  its derivative is integrable on `[a, b]`, then `∫ y in a..b, deriv f y` equals `f b - f a`. -/
theorem integral_deriv_eq_sub (hderiv : ∀ x (_ : x ∈ interval a b), DifferentiableAt ℝ f x)
  (hint : IntervalIntegrable (deriv f) volume a b) : (∫y in a..b, deriv f y) = f b - f a :=
  integral_eq_sub_of_has_deriv_at (fun x hx => (hderiv x hx).HasDerivAt) hint

theorem integral_deriv_eq_sub' f (hderiv : deriv f = f') (hdiff : ∀ x (_ : x ∈ interval a b), DifferentiableAt ℝ f x)
  (hcont : ContinuousOn f' (interval a b)) : (∫y in a..b, f' y) = f b - f a :=
  by 
    rw [←hderiv, integral_deriv_eq_sub hdiff]
    rw [hderiv]
    exact hcont.interval_integrable

/-!
### Integration by parts
-/


theorem integral_deriv_mul_eq_sub {u v u' v' : ℝ → ℝ} (hu : ∀ x (_ : x ∈ interval a b), HasDerivAt u (u' x) x)
  (hv : ∀ x (_ : x ∈ interval a b), HasDerivAt v (v' x) x) (hu' : IntervalIntegrable u' volume a b)
  (hv' : IntervalIntegrable v' volume a b) : (∫x in a..b, (u' x*v x)+u x*v' x) = (u b*v b) - u a*v a :=
  (integral_eq_sub_of_has_deriv_at fun x hx => (hu x hx).mul (hv x hx))$
    (hu'.mul_continuous_on (HasDerivAt.continuous_on hv)).add (hv'.continuous_on_mul (HasDerivAt.continuous_on hu))

theorem integral_mul_deriv_eq_deriv_mul {u v u' v' : ℝ → ℝ} (hu : ∀ x (_ : x ∈ interval a b), HasDerivAt u (u' x) x)
  (hv : ∀ x (_ : x ∈ interval a b), HasDerivAt v (v' x) x) (hu' : IntervalIntegrable u' volume a b)
  (hv' : IntervalIntegrable v' volume a b) : (∫x in a..b, u x*v' x) = ((u b*v b) - u a*v a) - ∫x in a..b, v x*u' x :=
  by 
    rw [←integral_deriv_mul_eq_sub hu hv hu' hv', ←integral_sub]
    ·
      exact
        integral_congr
          fun x hx =>
            by 
              simp only [mul_commₓ, add_sub_cancel']
    ·
      exact
        (hu'.mul_continuous_on (HasDerivAt.continuous_on hv)).add (hv'.continuous_on_mul (HasDerivAt.continuous_on hu))
    ·
      exact hu'.continuous_on_mul (HasDerivAt.continuous_on hv)

/-!
### Integration by substitution / Change of variables
-/


section Smul

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:341:40: in have: ././Mathport/Syntax/Translate/Basic.lean:546:47: unsupported (impossible)
/--
Change of variables, general form. If `f` is continuous on `[a, b]` and has
continuous right-derivative `f'` in `(a, b)`, and `g` is continuous on `f '' [a, b]` then we can
substitute `u = f x` to get `∫ x in a..b, f' x • (g ∘ f) x = ∫ u in f a..f b, g u`.

We could potentially slightly weaken the conditions, by not requiring that `f'` and `g` are
continuous on the endpoints of these intervals, but in that case we need to additionally assume that
the functions are integrable on that interval.
-/
theorem integral_comp_smul_deriv''
{f f' : exprℝ() → exprℝ()}
{g : exprℝ() → E}
(hf : continuous_on f «expr[ , ]»(a, b))
(hff' : ∀ x «expr ∈ » Ioo (min a b) (max a b), has_deriv_within_at f (f' x) (Ioi x) x)
(hf' : continuous_on f' «expr[ , ]»(a, b))
(hg : continuous_on g «expr '' »(f, «expr[ , ]»(a, b))) : «expr = »(«expr∫ in .. , »((x), a, b, «expr • »(f' x, «expr ∘ »(g, f) x)), «expr∫ in .. , »((u), f a, f b, g u)) :=
begin
  have [ident h_cont] [":", expr continuous_on (λ u, «expr∫ in .. , »((t), f a, f u, g t)) «expr[ , ]»(a, b)] [],
  { rw ["[", expr hf.image_interval, "]"] ["at", ident hg],
    refine [expr (continuous_on_primitive_interval' hg.interval_integrable _).comp hf _],
    { rw ["[", "<-", expr hf.image_interval, "]"] [],
      exact [expr mem_image_of_mem f left_mem_interval] },
    { rw ["[", "<-", expr image_subset_iff, "]"] [],
      exact [expr hf.image_interval.subset] } },
  have [ident h_der] [":", expr ∀
   x «expr ∈ » Ioo (min a b) (max a b), has_deriv_within_at (λ
    u, «expr∫ in .. , »((t), f a, f u, g t)) «expr • »(f' x, «expr ∘ »(g, f) x) (Ioi x) x] [],
  { intros [ident x, ident hx],
    let [ident I] [] [":=", expr «expr[ , ]»(Inf «expr '' »(f, «expr[ , ]»(a, b)), Sup «expr '' »(f, «expr[ , ]»(a, b)))],
    have [ident hI] [":", expr «expr = »(«expr '' »(f, «expr[ , ]»(a, b)), I)] [":=", expr hf.image_interval],
    have [ident h2x] [":", expr «expr ∈ »(f x, I)] [],
    { rw ["[", "<-", expr hI, "]"] [],
      exact [expr mem_image_of_mem f (Ioo_subset_Icc_self hx)] },
    have [ident h2g] [":", expr interval_integrable g volume (f a) (f x)] [],
    { refine [expr «expr $ »(hg.mono, _).interval_integrable],
      exact [expr hf.surj_on_interval left_mem_interval (Ioo_subset_Icc_self hx)] },
    rw ["[", expr hI, "]"] ["at", ident hg],
    have [ident h3g] [":", expr measurable_at_filter g «expr𝓝[ ] »(I, f x) volume] [":=", expr hg.measurable_at_filter_nhds_within measurable_set_Icc (f x)],
    haveI [] [":", expr fact «expr ∈ »(f x, I)] [":=", expr ⟨h2x⟩],
    have [] [":", expr has_deriv_within_at (λ
      u, «expr∫ in .. , »((x), f a, u, g x)) (g (f x)) I (f x)] [":=", expr integral_has_deriv_within_at_right h2g h3g (hg (f x) h2x)],
    refine [expr (this.scomp x ((hff' x hx).Ioo_of_Ioi hx.2) _).Ioi_of_Ioo hx.2],
    dsimp ["only"] ["[", expr I, "]"] [] [],
    rw ["[", "<-", expr image_subset_iff, ",", "<-", expr hf.image_interval, "]"] [],
    refine [expr image_subset f «expr $ »(Ioo_subset_Icc_self.trans, Icc_subset_Icc_left hx.1.le)] },
  have [ident h_int] [":", expr interval_integrable (λ
    x : exprℝ(), «expr • »(f' x, «expr ∘ »(g, f) x)) volume a b] [":=", expr (hf'.smul «expr $ »(hg.comp hf, subset_preimage_image f _)).interval_integrable],
  simp_rw ["[", expr integral_eq_sub_of_has_deriv_right h_cont h_der h_int, ",", expr integral_same, ",", expr sub_zero, "]"] []
end

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:546:47: unsupported (impossible)
/--
Change of variables. If `f` is has continuous derivative `f'` on `[a, b]`,
and `g` is continuous on `f '' [a, b]`, then we can substitute `u = f x` to get
`∫ x in a..b, f' x • (g ∘ f) x = ∫ u in f a..f b, g u`.
Compared to `interval_integral.integral_comp_smul_deriv` we only require that `g` is continuous on
`f '' [a, b]`.
-/
theorem integral_comp_smul_deriv'
{f f' : exprℝ() → exprℝ()}
{g : exprℝ() → E}
(h : ∀ x «expr ∈ » interval a b, has_deriv_at f (f' x) x)
(h' : continuous_on f' (interval a b))
(hg : continuous_on g «expr '' »(f, «expr[ , ]»(a, b))) : «expr = »(«expr∫ in .. , »((x), a, b, «expr • »(f' x, «expr ∘ »(g, f) x)), «expr∫ in .. , »((x), f a, f b, g x)) :=
integral_comp_smul_deriv'' (λ
 x
 hx, (h x hx).continuous_at.continuous_within_at) (λ
 x hx, «expr $ »(h x, Ioo_subset_Icc_self hx).has_deriv_within_at) h' hg

/--
Change of variables, most common version. If `f` is has continuous derivative `f'` on `[a, b]`,
and `g` is continuous, then we can substitute `u = f x` to get
`∫ x in a..b, f' x • (g ∘ f) x = ∫ u in f a..f b, g u`.
-/
theorem integral_comp_smul_deriv {f f' : ℝ → ℝ} {g : ℝ → E} (h : ∀ x (_ : x ∈ interval a b), HasDerivAt f (f' x) x)
  (h' : ContinuousOn f' (interval a b)) (hg : Continuous g) : (∫x in a..b, f' x • (g ∘ f) x) = ∫x in f a..f b, g x :=
  integral_comp_smul_deriv' h h' hg.continuous_on

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:546:47: unsupported (impossible)
theorem integral_deriv_comp_smul_deriv'
{f f' : exprℝ() → exprℝ()}
{g g' : exprℝ() → E}
(hf : continuous_on f «expr[ , ]»(a, b))
(hff' : ∀ x «expr ∈ » Ioo (min a b) (max a b), has_deriv_within_at f (f' x) (Ioi x) x)
(hf' : continuous_on f' «expr[ , ]»(a, b))
(hg : continuous_on g «expr[ , ]»(f a, f b))
(hgg' : ∀ x «expr ∈ » Ioo (min (f a) (f b)) (max (f a) (f b)), has_deriv_within_at g (g' x) (Ioi x) x)
(hg' : continuous_on g' «expr '' »(f, «expr[ , ]»(a, b))) : «expr = »(«expr∫ in .. , »((x), a, b, «expr • »(f' x, «expr ∘ »(g', f) x)), «expr - »(«expr ∘ »(g, f) b, «expr ∘ »(g, f) a)) :=
begin
  rw ["[", expr integral_comp_smul_deriv'' hf hff' hf' hg', ",", expr integral_eq_sub_of_has_deriv_right hg hgg' (hg'.mono _).interval_integrable, "]"] [],
  exact [expr intermediate_value_interval hf]
end

theorem integral_deriv_comp_smul_deriv {f f' : ℝ → ℝ} {g g' : ℝ → E}
  (hf : ∀ x (_ : x ∈ interval a b), HasDerivAt f (f' x) x)
  (hg : ∀ x (_ : x ∈ interval a b), HasDerivAt g (g' (f x)) (f x)) (hf' : ContinuousOn f' (interval a b))
  (hg' : Continuous g') : (∫x in a..b, f' x • (g' ∘ f) x) = (g ∘ f) b - (g ∘ f) a :=
  integral_eq_sub_of_has_deriv_at (fun x hx => (hg x hx).scomp x$ hf x hx)
    (hf'.smul (hg'.comp_continuous_on$ HasDerivAt.continuous_on hf)).IntervalIntegrable

end Smul

section Mul

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:546:47: unsupported (impossible)
/--
Change of variables, general form for scalar functions. If `f` is continuous on `[a, b]` and has
continuous right-derivative `f'` in `(a, b)`, and `g` is continuous on `f '' [a, b]` then we can
substitute `u = f x` to get `∫ x in a..b, (g ∘ f) x * f' x = ∫ u in f a..f b, g u`.
-/
theorem integral_comp_mul_deriv''
{f f' g : exprℝ() → exprℝ()}
(hf : continuous_on f «expr[ , ]»(a, b))
(hff' : ∀ x «expr ∈ » Ioo (min a b) (max a b), has_deriv_within_at f (f' x) (Ioi x) x)
(hf' : continuous_on f' «expr[ , ]»(a, b))
(hg : continuous_on g «expr '' »(f, «expr[ , ]»(a, b))) : «expr = »(«expr∫ in .. , »((x), a, b, «expr * »(«expr ∘ »(g, f) x, f' x)), «expr∫ in .. , »((u), f a, f b, g u)) :=
by simpa [] [] [] ["[", expr mul_comm, "]"] [] ["using", expr integral_comp_smul_deriv'' hf hff' hf' hg]

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:546:47: unsupported (impossible)
/--
Change of variables. If `f` is has continuous derivative `f'` on `[a, b]`,
and `g` is continuous on `f '' [a, b]`, then we can substitute `u = f x` to get
`∫ x in a..b, (g ∘ f) x * f' x = ∫ u in f a..f b, g u`.
Compared to `interval_integral.integral_comp_mul_deriv` we only require that `g` is continuous on
`f '' [a, b]`.
-/
theorem integral_comp_mul_deriv'
{f f' g : exprℝ() → exprℝ()}
(h : ∀ x «expr ∈ » interval a b, has_deriv_at f (f' x) x)
(h' : continuous_on f' (interval a b))
(hg : continuous_on g «expr '' »(f, «expr[ , ]»(a, b))) : «expr = »(«expr∫ in .. , »((x), a, b, «expr * »(«expr ∘ »(g, f) x, f' x)), «expr∫ in .. , »((x), f a, f b, g x)) :=
by simpa [] [] [] ["[", expr mul_comm, "]"] [] ["using", expr integral_comp_smul_deriv' h h' hg]

/--
Change of variables, most common version. If `f` is has continuous derivative `f'` on `[a, b]`,
and `g` is continuous, then we can substitute `u = f x` to get
`∫ x in a..b, (g ∘ f) x * f' x = ∫ u in f a..f b, g u`.
-/
theorem integral_comp_mul_deriv {f f' g : ℝ → ℝ} (h : ∀ x (_ : x ∈ interval a b), HasDerivAt f (f' x) x)
  (h' : ContinuousOn f' (interval a b)) (hg : Continuous g) : (∫x in a..b, (g ∘ f) x*f' x) = ∫x in f a..f b, g x :=
  integral_comp_mul_deriv' h h' hg.continuous_on

-- error in MeasureTheory.Integral.IntervalIntegral: ././Mathport/Syntax/Translate/Basic.lean:546:47: unsupported (impossible)
theorem integral_deriv_comp_mul_deriv'
{f f' g g' : exprℝ() → exprℝ()}
(hf : continuous_on f «expr[ , ]»(a, b))
(hff' : ∀ x «expr ∈ » Ioo (min a b) (max a b), has_deriv_within_at f (f' x) (Ioi x) x)
(hf' : continuous_on f' «expr[ , ]»(a, b))
(hg : continuous_on g «expr[ , ]»(f a, f b))
(hgg' : ∀ x «expr ∈ » Ioo (min (f a) (f b)) (max (f a) (f b)), has_deriv_within_at g (g' x) (Ioi x) x)
(hg' : continuous_on g' «expr '' »(f, «expr[ , ]»(a, b))) : «expr = »(«expr∫ in .. , »((x), a, b, «expr * »(«expr ∘ »(g', f) x, f' x)), «expr - »(«expr ∘ »(g, f) b, «expr ∘ »(g, f) a)) :=
by simpa [] [] [] ["[", expr mul_comm, "]"] [] ["using", expr integral_deriv_comp_smul_deriv' hf hff' hf' hg hgg' hg']

theorem integral_deriv_comp_mul_deriv {f f' g g' : ℝ → ℝ} (hf : ∀ x (_ : x ∈ interval a b), HasDerivAt f (f' x) x)
  (hg : ∀ x (_ : x ∈ interval a b), HasDerivAt g (g' (f x)) (f x)) (hf' : ContinuousOn f' (interval a b))
  (hg' : Continuous g') : (∫x in a..b, (g' ∘ f) x*f' x) = (g ∘ f) b - (g ∘ f) a :=
  by 
    simpa [mul_commₓ] using integral_deriv_comp_smul_deriv hf hg hf' hg'

end Mul

end intervalIntegral

