/-
Copyright (c) 2023 Rémy Degenne. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémy Degenne

! This file was ported from Lean 3 source module probability.kernel.composition
! leanprover-community/mathlib commit 3180fab693e2cee3bff62675571264cb8778b212
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Probability.Kernel.Basic

/-!
# Product and composition of kernels

We define
* the composition-product `κ ⊗ₖ η` of two s-finite kernels `κ : kernel α β` and
  `η : kernel (α × β) γ`, a kernel from `α` to `β × γ`.
* the map and comap of a kernel along a measurable function.
* the composition `η ∘ₖ κ` of s-finite kernels `κ : kernel α β` and `η : kernel β γ`,
  a kernel from `α` to `γ`.
* the product `prod κ η` of s-finite kernels `κ : kernel α β` and `η : kernel α γ`,
  a kernel from `α` to `β × γ`.

A note on names:
The composition-product `kernel α β → kernel (α × β) γ → kernel α (β × γ)` is named composition in
[kallenberg2021] and product on the wikipedia article on transition kernels.
Most papers studying categories of kernels call composition the map we call composition. We adopt
that convention because it fits better with the use of the name `comp` elsewhere in mathlib.

## Main definitions

Kernels built from other kernels:
* `comp_prod (κ : kernel α β) (η : kernel (α × β) γ) : kernel α (β × γ)`: composition-product of 2
  s-finite kernels. We define a notation `κ ⊗ₖ η = comp_prod κ η`.
  `∫⁻ bc, f bc ∂((κ ⊗ₖ η) a) = ∫⁻ b, ∫⁻ c, f (b, c) ∂(η (a, b)) ∂(κ a)`
* `map (κ : kernel α β) (f : β → γ) (hf : measurable f) : kernel α γ`
  `∫⁻ c, g c ∂(map κ f hf a) = ∫⁻ b, g (f b) ∂(κ a)`
* `comap (κ : kernel α β) (f : γ → α) (hf : measurable f) : kernel γ β`
  `∫⁻ b, g b ∂(comap κ f hf c) = ∫⁻ b, g b ∂(κ (f c))`
* `comp (η : kernel β γ) (κ : kernel α β) : kernel α γ`: composition of 2 s-finite kernels.
  We define a notation `η ∘ₖ κ = comp η κ`.
  `∫⁻ c, g c ∂((η ∘ₖ κ) a) = ∫⁻ b, ∫⁻ c, g c ∂(η b) ∂(κ a)`
* `prod (κ : kernel α β) (η : kernel α γ) : kernel α (β × γ)`: product of 2 s-finite kernels.
  `∫⁻ bc, f bc ∂(prod κ η a) = ∫⁻ b, ∫⁻ c, f (b, c) ∂(η a) ∂(κ a)`

## Main statements

* `lintegral_comp_prod`, `lintegral_map`, `lintegral_comap`, `lintegral_comp`, `lintegral_prod`:
  Lebesgue integral of a function against a composition-product/map/comap/composition/product of
  kernels.
* Instances of the form `<class>.<operation>` where class is one of `is_markov_kernel`,
  `is_finite_kernel`, `is_s_finite_kernel` and operation is one of `comp_prod`, `map`, `comap`,
  `comp`, `prod`. These instances state that the three classes are stable by the various operations.

## Notations

* `κ ⊗ₖ η = probability_theory.kernel.comp_prod κ η`
* `η ∘ₖ κ = probability_theory.kernel.comp η κ`

-/


open MeasureTheory

open ENNReal

namespace ProbabilityTheory

namespace Kernel

variable {α β ι : Type _} {mα : MeasurableSpace α} {mβ : MeasurableSpace β}

include mα mβ

section CompositionProduct

/-!
### Composition-Product of kernels

We define a kernel composition-product
`comp_prod : kernel α β → kernel (α × β) γ → kernel α (β × γ)`.
-/


variable {γ : Type _} {mγ : MeasurableSpace γ} {s : Set (β × γ)}

include mγ

/-- Auxiliary function for the definition of the composition-product of two kernels.
For all `a : α`, `comp_prod_fun κ η a` is a countably additive function with value zero on the empty
set, and the composition-product of kernels is defined in `kernel.comp_prod` through
`measure.of_measurable`. -/
noncomputable def compProdFun (κ : kernel α β) (η : kernel (α × β) γ) (a : α) (s : Set (β × γ)) :
    ℝ≥0∞ :=
  ∫⁻ b, η (a, b) { c | (b, c) ∈ s } ∂κ a
#align probability_theory.kernel.comp_prod_fun ProbabilityTheory.kernel.compProdFun

theorem compProdFun_empty (κ : kernel α β) (η : kernel (α × β) γ) (a : α) :
    compProdFun κ η a ∅ = 0 := by
  simp only [comp_prod_fun, Set.mem_empty_iff_false, Set.setOf_false, measure_empty,
    lintegral_const, MulZeroClass.zero_mul]
#align probability_theory.kernel.comp_prod_fun_empty ProbabilityTheory.kernel.compProdFun_empty

theorem compProdFun_unionᵢ (κ : kernel α β) (η : kernel (α × β) γ) [IsSFiniteKernel η] (a : α)
    (f : ℕ → Set (β × γ)) (hf_meas : ∀ i, MeasurableSet (f i))
    (hf_disj : Pairwise (Disjoint on f)) :
    compProdFun κ η a (⋃ i, f i) = ∑' i, compProdFun κ η a (f i) :=
  by
  have h_Union :
    (fun b => η (a, b) { c : γ | (b, c) ∈ ⋃ i, f i }) = fun b =>
      η (a, b) (⋃ i, { c : γ | (b, c) ∈ f i }) :=
    by
    ext1 b
    congr with c
    simp only [Set.mem_unionᵢ, Set.supᵢ_eq_unionᵢ, Set.mem_setOf_eq]
    rfl
  rw [comp_prod_fun, h_Union]
  have h_tsum :
    (fun b => η (a, b) (⋃ i, { c : γ | (b, c) ∈ f i })) = fun b =>
      ∑' i, η (a, b) { c : γ | (b, c) ∈ f i } :=
    by
    ext1 b
    rw [measure_Union]
    · intro i j hij s hsi hsj c hcs
      have hbci : {(b, c)} ⊆ f i := by
        rw [Set.singleton_subset_iff]
        exact hsi hcs
      have hbcj : {(b, c)} ⊆ f j := by
        rw [Set.singleton_subset_iff]
        exact hsj hcs
      simpa only [Set.bot_eq_empty, Set.le_eq_subset, Set.singleton_subset_iff,
        Set.mem_empty_iff_false] using hf_disj hij hbci hbcj
    · exact fun i => (@measurable_prod_mk_left β γ _ _ b) _ (hf_meas i)
  rw [h_tsum, lintegral_tsum]
  · rfl
  · intro i
    have hm : MeasurableSet { p : (α × β) × γ | (p.1.2, p.2) ∈ f i } :=
      measurable_fst.snd.prod_mk measurable_snd (hf_meas i)
    exact ((measurable_prod_mk_mem η hm).comp measurable_prod_mk_left).AeMeasurable
#align probability_theory.kernel.comp_prod_fun_Union ProbabilityTheory.kernel.compProdFun_unionᵢ

theorem compProdFun_tsum_right (κ : kernel α β) (η : kernel (α × β) γ) [IsSFiniteKernel η] (a : α)
    (hs : MeasurableSet s) : compProdFun κ η a s = ∑' n, compProdFun κ (seq η n) a s :=
  by
  simp_rw [comp_prod_fun, (measure_sum_seq η _).symm]
  have :
    (∫⁻ b, measure.sum (fun n => seq η n (a, b)) { c : γ | (b, c) ∈ s } ∂κ a) =
      ∫⁻ b, ∑' n, seq η n (a, b) { c : γ | (b, c) ∈ s } ∂κ a :=
    by
    congr
    ext1 b
    rw [measure.sum_apply]
    exact measurable_prod_mk_left hs
  rw [this, lintegral_tsum fun n : ℕ => _]
  exact
    ((measurable_prod_mk_mem (seq η n) ((measurable_fst.snd.prod_mk measurable_snd) hs)).comp
        measurable_prod_mk_left).AeMeasurable
#align probability_theory.kernel.comp_prod_fun_tsum_right ProbabilityTheory.kernel.compProdFun_tsum_right

theorem compProdFun_tsum_left (κ : kernel α β) (η : kernel (α × β) γ) [IsSFiniteKernel κ] (a : α)
    (s : Set (β × γ)) : compProdFun κ η a s = ∑' n, compProdFun (seq κ n) η a s := by
  simp_rw [comp_prod_fun, (measure_sum_seq κ _).symm, lintegral_sum_measure]
#align probability_theory.kernel.comp_prod_fun_tsum_left ProbabilityTheory.kernel.compProdFun_tsum_left

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (n m) -/
theorem compProdFun_eq_tsum (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsSFiniteKernel η] (a : α) (hs : MeasurableSet s) :
    compProdFun κ η a s = ∑' (n) (m), compProdFun (seq κ n) (seq η m) a s := by
  simp_rw [comp_prod_fun_tsum_left κ η a s, comp_prod_fun_tsum_right _ η a hs]
#align probability_theory.kernel.comp_prod_fun_eq_tsum ProbabilityTheory.kernel.compProdFun_eq_tsum

/-- Auxiliary lemma for `measurable_comp_prod_fun`. -/
theorem measurable_compProdFun_of_finite (κ : kernel α β) [IsFiniteKernel κ] (η : kernel (α × β) γ)
    [IsFiniteKernel η] (hs : MeasurableSet s) : Measurable fun a => compProdFun κ η a s :=
  by
  simp only [comp_prod_fun]
  have h_meas : Measurable (Function.uncurry fun a b => η (a, b) { c : γ | (b, c) ∈ s }) :=
    by
    have :
      (Function.uncurry fun a b => η (a, b) { c : γ | (b, c) ∈ s }) = fun p =>
        η p { c : γ | (p.2, c) ∈ s } :=
      by
      ext1 p
      have hp_eq_mk : p = (p.fst, p.snd) := prod.mk.eta.symm
      rw [hp_eq_mk, Function.uncurry_apply_pair]
    rw [this]
    exact measurable_prod_mk_mem η (measurable_fst.snd.prod_mk measurable_snd hs)
  exact measurable_lintegral κ h_meas
#align probability_theory.kernel.measurable_comp_prod_fun_of_finite ProbabilityTheory.kernel.measurable_compProdFun_of_finite

theorem measurable_compProdFun (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsSFiniteKernel η] (hs : MeasurableSet s) : Measurable fun a => compProdFun κ η a s :=
  by
  simp_rw [comp_prod_fun_tsum_right κ η _ hs]
  refine' Measurable.eNNReal_tsum fun n => _
  simp only [comp_prod_fun]
  have h_meas : Measurable (Function.uncurry fun a b => seq η n (a, b) { c : γ | (b, c) ∈ s }) :=
    by
    have :
      (Function.uncurry fun a b => seq η n (a, b) { c : γ | (b, c) ∈ s }) = fun p =>
        seq η n p { c : γ | (p.2, c) ∈ s } :=
      by
      ext1 p
      have hp_eq_mk : p = (p.fst, p.snd) := prod.mk.eta.symm
      rw [hp_eq_mk, Function.uncurry_apply_pair]
    rw [this]
    exact measurable_prod_mk_mem (seq η n) (measurable_fst.snd.prod_mk measurable_snd hs)
  exact measurable_lintegral κ h_meas
#align probability_theory.kernel.measurable_comp_prod_fun ProbabilityTheory.kernel.measurable_compProdFun

/-- Composition-Product of kernels. It verifies
`∫⁻ bc, f bc ∂(comp_prod κ η a) = ∫⁻ b, ∫⁻ c, f (b, c) ∂(η (a, b)) ∂(κ a)`
(see `lintegral_comp_prod`). -/
noncomputable def compProd (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsSFiniteKernel η] : kernel α (β × γ)
    where
  val a :=
    Measure.ofMeasurable (fun s hs => compProdFun κ η a s) (compProdFun_empty κ η a)
      (compProdFun_unionᵢ κ η a)
  property := by
    refine' measure.measurable_of_measurable_coe _ fun s hs => _
    have :
      (fun a =>
          measure.of_measurable (fun s hs => comp_prod_fun κ η a s) (comp_prod_fun_empty κ η a)
            (comp_prod_fun_Union κ η a) s) =
        fun a => comp_prod_fun κ η a s :=
      by
      ext1 a
      rwa [measure.of_measurable_apply]
    rw [this]
    exact measurable_comp_prod_fun κ η hs
#align probability_theory.kernel.comp_prod ProbabilityTheory.kernel.compProd

-- mathport name: kernel.comp_prod
scoped[ProbabilityTheory] infixl:100 " ⊗ₖ " => ProbabilityTheory.kernel.compProd

theorem compProd_apply_eq_compProdFun (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsSFiniteKernel η] (a : α) (hs : MeasurableSet s) : (κ ⊗ₖ η) a s = compProdFun κ η a s :=
  by
  rw [comp_prod]
  change
    measure.of_measurable (fun s hs => comp_prod_fun κ η a s) (comp_prod_fun_empty κ η a)
        (comp_prod_fun_Union κ η a) s =
      ∫⁻ b, η (a, b) { c | (b, c) ∈ s } ∂κ a
  rw [measure.of_measurable_apply _ hs]
  rfl
#align probability_theory.kernel.comp_prod_apply_eq_comp_prod_fun ProbabilityTheory.kernel.compProd_apply_eq_compProdFun

theorem compProd_apply (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsSFiniteKernel η] (a : α) (hs : MeasurableSet s) :
    (κ ⊗ₖ η) a s = ∫⁻ b, η (a, b) { c | (b, c) ∈ s } ∂κ a :=
  compProd_apply_eq_compProdFun κ η a hs
#align probability_theory.kernel.comp_prod_apply ProbabilityTheory.kernel.compProd_apply

/-- Lebesgue integral against the composition-product of two kernels. -/
theorem lintegral_comp_prod' (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsSFiniteKernel η] (a : α) {f : β → γ → ℝ≥0∞} (hf : Measurable (Function.uncurry f)) :
    (∫⁻ bc, f bc.1 bc.2 ∂(κ ⊗ₖ η) a) = ∫⁻ b, ∫⁻ c, f b c ∂η (a, b) ∂κ a :=
  by
  let F : ℕ → simple_func (β × γ) ℝ≥0∞ := simple_func.eapprox (Function.uncurry f)
  have h : ∀ a, (⨆ n, F n a) = Function.uncurry f a :=
    simple_func.supr_eapprox_apply (Function.uncurry f) hf
  simp only [Prod.forall, Function.uncurry_apply_pair] at h
  simp_rw [← h, Prod.mk.eta]
  have h_mono : Monotone F := fun i j hij b =>
    simple_func.monotone_eapprox (Function.uncurry f) hij _
  rw [lintegral_supr (fun n => (F n).Measurable) h_mono]
  have : ∀ b, (∫⁻ c, ⨆ n, F n (b, c) ∂η (a, b)) = ⨆ n, ∫⁻ c, F n (b, c) ∂η (a, b) :=
    by
    intro a
    rw [lintegral_supr]
    · exact fun n => (F n).Measurable.comp measurable_prod_mk_left
    · exact fun i j hij b => h_mono hij _
  simp_rw [this]
  have h_some_meas_integral :
    ∀ f' : simple_func (β × γ) ℝ≥0∞, Measurable fun b => ∫⁻ c, f' (b, c) ∂η (a, b) :=
    by
    intro f'
    have :
      (fun b => ∫⁻ c, f' (b, c) ∂η (a, b)) =
        (fun ab => ∫⁻ c, f' (ab.2, c) ∂η ab) ∘ fun b => (a, b) :=
      by
      ext1 ab
      rfl
    rw [this]
    refine' Measurable.comp _ measurable_prod_mk_left
    exact
      measurable_lintegral η
        ((simple_func.measurable _).comp (measurable_fst.snd.prod_mk measurable_snd))
  rw [lintegral_supr]
  rotate_left
  · exact fun n => h_some_meas_integral (F n)
  · exact fun i j hij b => lintegral_mono fun c => h_mono hij _
  congr
  ext1 n
  refine' simple_func.induction _ _ (F n)
  · intro c s hs
    simp only [simple_func.const_zero, simple_func.coe_piecewise, simple_func.coe_const,
      simple_func.coe_zero, Set.piecewise_eq_indicator, lintegral_indicator_const hs]
    rw [comp_prod_apply κ η _ hs, ← lintegral_const_mul c _]
    swap
    ·
      exact
        (measurable_prod_mk_mem η ((measurable_fst.snd.prod_mk measurable_snd) hs)).comp
          measurable_prod_mk_left
    congr
    ext1 b
    rw [lintegral_indicator_const_comp measurable_prod_mk_left hs]
    rfl
  · intro f f' h_disj hf_eq hf'_eq
    simp_rw [simple_func.coe_add, Pi.add_apply]
    change
      (∫⁻ x, (f : β × γ → ℝ≥0∞) x + f' x ∂(κ ⊗ₖ η) a) =
        ∫⁻ b, ∫⁻ c : γ, f (b, c) + f' (b, c) ∂η (a, b) ∂κ a
    rw [lintegral_add_left (simple_func.measurable _), hf_eq, hf'_eq, ← lintegral_add_left]
    swap
    · exact h_some_meas_integral f
    congr with b
    rw [← lintegral_add_left ((simple_func.measurable _).comp measurable_prod_mk_left)]
#align probability_theory.kernel.lintegral_comp_prod' ProbabilityTheory.kernel.lintegral_comp_prod'

/-- Lebesgue integral against the composition-product of two kernels. -/
theorem lintegral_compProd (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsSFiniteKernel η] (a : α) {f : β × γ → ℝ≥0∞} (hf : Measurable f) :
    (∫⁻ bc, f bc ∂(κ ⊗ₖ η) a) = ∫⁻ b, ∫⁻ c, f (b, c) ∂η (a, b) ∂κ a :=
  by
  let g := Function.curry f
  change (∫⁻ bc, f bc ∂(κ ⊗ₖ η) a) = ∫⁻ b, ∫⁻ c, g b c ∂η (a, b) ∂κ a
  rw [← lintegral_comp_prod']
  · simp_rw [g, Function.curry_apply, Prod.mk.eta]
  · simp_rw [g, Function.uncurry_curry]
    exact hf
#align probability_theory.kernel.lintegral_comp_prod ProbabilityTheory.kernel.lintegral_compProd

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (n m) -/
theorem compProd_eq_tsum_compProd (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsSFiniteKernel η] (a : α) (hs : MeasurableSet s) :
    (κ ⊗ₖ η) a s = ∑' (n : ℕ) (m : ℕ), (seq κ n ⊗ₖ seq η m) a s :=
  by
  simp_rw [comp_prod_apply_eq_comp_prod_fun _ _ _ hs]
  exact comp_prod_fun_eq_tsum κ η a hs
#align probability_theory.kernel.comp_prod_eq_tsum_comp_prod ProbabilityTheory.kernel.compProd_eq_tsum_compProd

theorem compProd_eq_sum_compProd (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsSFiniteKernel η] : κ ⊗ₖ η = kernel.sum fun n => kernel.sum fun m => seq κ n ⊗ₖ seq η m :=
  by
  ext (a s hs) : 2
  simp_rw [kernel.sum_apply' _ a hs]
  rw [comp_prod_eq_tsum_comp_prod κ η a hs]
#align probability_theory.kernel.comp_prod_eq_sum_comp_prod ProbabilityTheory.kernel.compProd_eq_sum_compProd

theorem compProd_eq_sum_compProd_left (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsSFiniteKernel η] : κ ⊗ₖ η = kernel.sum fun n => seq κ n ⊗ₖ η :=
  by
  rw [comp_prod_eq_sum_comp_prod]
  congr with (n a s hs)
  simp_rw [kernel.sum_apply' _ _ hs, comp_prod_apply_eq_comp_prod_fun _ _ _ hs,
    comp_prod_fun_tsum_right _ η a hs]
#align probability_theory.kernel.comp_prod_eq_sum_comp_prod_left ProbabilityTheory.kernel.compProd_eq_sum_compProd_left

theorem compProd_eq_sum_compProd_right (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsSFiniteKernel η] : κ ⊗ₖ η = kernel.sum fun n => κ ⊗ₖ seq η n :=
  by
  rw [comp_prod_eq_sum_comp_prod]
  simp_rw [comp_prod_eq_sum_comp_prod_left κ _]
  rw [kernel.sum_comm]
#align probability_theory.kernel.comp_prod_eq_sum_comp_prod_right ProbabilityTheory.kernel.compProd_eq_sum_compProd_right

instance IsMarkovKernel.compProd (κ : kernel α β) [IsMarkovKernel κ] (η : kernel (α × β) γ)
    [IsMarkovKernel η] : IsMarkovKernel (κ ⊗ₖ η) :=
  ⟨fun a =>
    ⟨by
      rw [comp_prod_apply κ η a MeasurableSet.univ]
      simp only [Set.mem_univ, Set.setOf_true, measure_univ, lintegral_one]⟩⟩
#align probability_theory.kernel.is_markov_kernel.comp_prod ProbabilityTheory.kernel.IsMarkovKernel.compProd

theorem compProd_apply_univ_le (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsFiniteKernel η] (a : α) : (κ ⊗ₖ η) a Set.univ ≤ κ a Set.univ * IsFiniteKernel.bound η :=
  by
  rw [comp_prod_apply κ η a MeasurableSet.univ]
  simp only [Set.mem_univ, Set.setOf_true]
  let Cη := is_finite_kernel.bound η
  calc
    (∫⁻ b, η (a, b) Set.univ ∂κ a) ≤ ∫⁻ b, Cη ∂κ a :=
      lintegral_mono fun b => measure_le_bound η (a, b) Set.univ
    _ = Cη * κ a Set.univ := (lintegral_const Cη)
    _ = κ a Set.univ * Cη := mul_comm _ _
    
#align probability_theory.kernel.comp_prod_apply_univ_le ProbabilityTheory.kernel.compProd_apply_univ_le

instance IsFiniteKernel.compProd (κ : kernel α β) [IsFiniteKernel κ] (η : kernel (α × β) γ)
    [IsFiniteKernel η] : IsFiniteKernel (κ ⊗ₖ η) :=
  ⟨⟨IsFiniteKernel.bound κ * IsFiniteKernel.bound η,
      ENNReal.mul_lt_top (IsFiniteKernel.bound_ne_top κ) (IsFiniteKernel.bound_ne_top η), fun a =>
      calc
        (κ ⊗ₖ η) a Set.univ ≤ κ a Set.univ * IsFiniteKernel.bound η := compProd_apply_univ_le κ η a
        _ ≤ IsFiniteKernel.bound κ * IsFiniteKernel.bound η :=
          mul_le_mul (measure_le_bound κ a Set.univ) le_rfl (zero_le _) (zero_le _)
        ⟩⟩
#align probability_theory.kernel.is_finite_kernel.comp_prod ProbabilityTheory.kernel.IsFiniteKernel.compProd

instance IsSFiniteKernel.compProd (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel (α × β) γ)
    [IsSFiniteKernel η] : IsSFiniteKernel (κ ⊗ₖ η) :=
  by
  rw [comp_prod_eq_sum_comp_prod]
  exact kernel.is_s_finite_kernel_sum fun n => kernel.is_s_finite_kernel_sum inferInstance
#align probability_theory.kernel.is_s_finite_kernel.comp_prod ProbabilityTheory.kernel.IsSFiniteKernel.compProd

end CompositionProduct

section MapComap

/-! ### map, comap -/


variable {γ : Type _} {mγ : MeasurableSpace γ} {f : β → γ} {g : γ → α}

include mγ

/-- The pushforward of a kernel along a measurable function. 
We include measurability in the assumptions instead of using junk values
to make sure that typeclass inference can infer that the `map` of a Markov kernel
is again a Markov kernel. -/
noncomputable def map (κ : kernel α β) (f : β → γ) (hf : Measurable f) : kernel α γ
    where
  val a := (κ a).map f
  property := (Measure.measurable_map _ hf).comp (kernel.measurable κ)
#align probability_theory.kernel.map ProbabilityTheory.kernel.map

theorem map_apply (κ : kernel α β) (hf : Measurable f) (a : α) : map κ f hf a = (κ a).map f :=
  rfl
#align probability_theory.kernel.map_apply ProbabilityTheory.kernel.map_apply

theorem map_apply' (κ : kernel α β) (hf : Measurable f) (a : α) {s : Set γ} (hs : MeasurableSet s) :
    map κ f hf a s = κ a (f ⁻¹' s) := by rw [map_apply, measure.map_apply hf hs]
#align probability_theory.kernel.map_apply' ProbabilityTheory.kernel.map_apply'

theorem lintegral_map (κ : kernel α β) (hf : Measurable f) (a : α) {g' : γ → ℝ≥0∞}
    (hg : Measurable g') : (∫⁻ b, g' b ∂map κ f hf a) = ∫⁻ a, g' (f a) ∂κ a := by
  rw [map_apply _ hf, lintegral_map hg hf]
#align probability_theory.kernel.lintegral_map ProbabilityTheory.kernel.lintegral_map

theorem sum_map_seq (κ : kernel α β) [IsSFiniteKernel κ] (hf : Measurable f) :
    (kernel.sum fun n => map (seq κ n) f hf) = map κ f hf :=
  by
  ext (a s hs) : 2
  rw [kernel.sum_apply, map_apply' κ hf a hs, measure.sum_apply _ hs, ← measure_sum_seq κ,
    measure.sum_apply _ (hf hs)]
  simp_rw [map_apply' _ hf _ hs]
#align probability_theory.kernel.sum_map_seq ProbabilityTheory.kernel.sum_map_seq

instance IsMarkovKernel.map (κ : kernel α β) [IsMarkovKernel κ] (hf : Measurable f) :
    IsMarkovKernel (map κ f hf) :=
  ⟨fun a => ⟨by rw [map_apply' κ hf a MeasurableSet.univ, Set.preimage_univ, measure_univ]⟩⟩
#align probability_theory.kernel.is_markov_kernel.map ProbabilityTheory.kernel.IsMarkovKernel.map

instance IsFiniteKernel.map (κ : kernel α β) [IsFiniteKernel κ] (hf : Measurable f) :
    IsFiniteKernel (map κ f hf) :=
  by
  refine' ⟨⟨is_finite_kernel.bound κ, is_finite_kernel.bound_lt_top κ, fun a => _⟩⟩
  rw [map_apply' κ hf a MeasurableSet.univ]
  exact measure_le_bound κ a _
#align probability_theory.kernel.is_finite_kernel.map ProbabilityTheory.kernel.IsFiniteKernel.map

instance IsSFiniteKernel.map (κ : kernel α β) [IsSFiniteKernel κ] (hf : Measurable f) :
    IsSFiniteKernel (map κ f hf) :=
  ⟨⟨fun n => map (seq κ n) f hf, inferInstance, (sum_map_seq κ hf).symm⟩⟩
#align probability_theory.kernel.is_s_finite_kernel.map ProbabilityTheory.kernel.IsSFiniteKernel.map

/-- Pullback of a kernel, such that for each set s `comap κ g hg c s = κ (g c) s`.
We include measurability in the assumptions instead of using junk values
to make sure that typeclass inference can infer that the `comap` of a Markov kernel
is again a Markov kernel. -/
def comap (κ : kernel α β) (g : γ → α) (hg : Measurable g) : kernel γ β
    where
  val a := κ (g a)
  property := (kernel.measurable κ).comp hg
#align probability_theory.kernel.comap ProbabilityTheory.kernel.comap

theorem comap_apply (κ : kernel α β) (hg : Measurable g) (c : γ) : comap κ g hg c = κ (g c) :=
  rfl
#align probability_theory.kernel.comap_apply ProbabilityTheory.kernel.comap_apply

theorem comap_apply' (κ : kernel α β) (hg : Measurable g) (c : γ) (s : Set β) :
    comap κ g hg c s = κ (g c) s :=
  rfl
#align probability_theory.kernel.comap_apply' ProbabilityTheory.kernel.comap_apply'

theorem lintegral_comap (κ : kernel α β) (hg : Measurable g) (c : γ) (g' : β → ℝ≥0∞) :
    (∫⁻ b, g' b ∂comap κ g hg c) = ∫⁻ b, g' b ∂κ (g c) :=
  rfl
#align probability_theory.kernel.lintegral_comap ProbabilityTheory.kernel.lintegral_comap

theorem sum_comap_seq (κ : kernel α β) [IsSFiniteKernel κ] (hg : Measurable g) :
    (kernel.sum fun n => comap (seq κ n) g hg) = comap κ g hg :=
  by
  ext (a s hs) : 2
  rw [kernel.sum_apply, comap_apply' κ hg a s, measure.sum_apply _ hs, ← measure_sum_seq κ,
    measure.sum_apply _ hs]
  simp_rw [comap_apply' _ hg _ s]
#align probability_theory.kernel.sum_comap_seq ProbabilityTheory.kernel.sum_comap_seq

instance IsMarkovKernel.comap (κ : kernel α β) [IsMarkovKernel κ] (hg : Measurable g) :
    IsMarkovKernel (comap κ g hg) :=
  ⟨fun a => ⟨by rw [comap_apply' κ hg a Set.univ, measure_univ]⟩⟩
#align probability_theory.kernel.is_markov_kernel.comap ProbabilityTheory.kernel.IsMarkovKernel.comap

instance IsFiniteKernel.comap (κ : kernel α β) [IsFiniteKernel κ] (hg : Measurable g) :
    IsFiniteKernel (comap κ g hg) :=
  by
  refine' ⟨⟨is_finite_kernel.bound κ, is_finite_kernel.bound_lt_top κ, fun a => _⟩⟩
  rw [comap_apply' κ hg a Set.univ]
  exact measure_le_bound κ _ _
#align probability_theory.kernel.is_finite_kernel.comap ProbabilityTheory.kernel.IsFiniteKernel.comap

instance IsSFiniteKernel.comap (κ : kernel α β) [IsSFiniteKernel κ] (hg : Measurable g) :
    IsSFiniteKernel (comap κ g hg) :=
  ⟨⟨fun n => comap (seq κ n) g hg, inferInstance, (sum_comap_seq κ hg).symm⟩⟩
#align probability_theory.kernel.is_s_finite_kernel.comap ProbabilityTheory.kernel.IsSFiniteKernel.comap

end MapComap

open ProbabilityTheory

section FstSnd

/-- Define a `kernel (γ × α) β` from a `kernel α β` by taking the comap of the projection. -/
def prodMkLeft (κ : kernel α β) (γ : Type _) [MeasurableSpace γ] : kernel (γ × α) β :=
  comap κ Prod.snd measurable_snd
#align probability_theory.kernel.prod_mk_left ProbabilityTheory.kernel.prodMkLeft

variable {γ : Type _} {mγ : MeasurableSpace γ} {f : β → γ} {g : γ → α}

include mγ

theorem prodMkLeft_apply (κ : kernel α β) (ca : γ × α) : prodMkLeft κ γ ca = κ ca.snd :=
  rfl
#align probability_theory.kernel.prod_mk_left_apply ProbabilityTheory.kernel.prodMkLeft_apply

theorem prodMkLeft_apply' (κ : kernel α β) (ca : γ × α) (s : Set β) :
    prodMkLeft κ γ ca s = κ ca.snd s :=
  rfl
#align probability_theory.kernel.prod_mk_left_apply' ProbabilityTheory.kernel.prodMkLeft_apply'

theorem lintegral_prodMkLeft (κ : kernel α β) (ca : γ × α) (g : β → ℝ≥0∞) :
    (∫⁻ b, g b ∂prodMkLeft κ γ ca) = ∫⁻ b, g b ∂κ ca.snd :=
  rfl
#align probability_theory.kernel.lintegral_prod_mk_left ProbabilityTheory.kernel.lintegral_prodMkLeft

instance IsMarkovKernel.prodMkLeft (κ : kernel α β) [IsMarkovKernel κ] :
    IsMarkovKernel (prodMkLeft κ γ) := by
  rw [prod_mk_left]
  infer_instance
#align probability_theory.kernel.is_markov_kernel.prod_mk_left ProbabilityTheory.kernel.IsMarkovKernel.prodMkLeft

instance IsFiniteKernel.prodMkLeft (κ : kernel α β) [IsFiniteKernel κ] :
    IsFiniteKernel (prodMkLeft κ γ) := by
  rw [prod_mk_left]
  infer_instance
#align probability_theory.kernel.is_finite_kernel.prod_mk_left ProbabilityTheory.kernel.IsFiniteKernel.prodMkLeft

instance IsSFiniteKernel.prodMkLeft (κ : kernel α β) [IsSFiniteKernel κ] :
    IsSFiniteKernel (prodMkLeft κ γ) := by
  rw [prod_mk_left]
  infer_instance
#align probability_theory.kernel.is_s_finite_kernel.prod_mk_left ProbabilityTheory.kernel.IsSFiniteKernel.prodMkLeft

/-- Define a `kernel (β × α) γ` from a `kernel (α × β) γ` by taking the comap of `prod.swap`. -/
def swapLeft (κ : kernel (α × β) γ) : kernel (β × α) γ :=
  comap κ Prod.swap measurable_swap
#align probability_theory.kernel.swap_left ProbabilityTheory.kernel.swapLeft

theorem swapLeft_apply (κ : kernel (α × β) γ) (a : β × α) : swapLeft κ a = κ a.symm :=
  rfl
#align probability_theory.kernel.swap_left_apply ProbabilityTheory.kernel.swapLeft_apply

theorem swapLeft_apply' (κ : kernel (α × β) γ) (a : β × α) (s : Set γ) :
    swapLeft κ a s = κ a.symm s :=
  rfl
#align probability_theory.kernel.swap_left_apply' ProbabilityTheory.kernel.swapLeft_apply'

theorem lintegral_swapLeft (κ : kernel (α × β) γ) (a : β × α) (g : γ → ℝ≥0∞) :
    (∫⁻ c, g c ∂swapLeft κ a) = ∫⁻ c, g c ∂κ a.symm := by
  rw [swap_left, lintegral_comap _ measurable_swap a]
#align probability_theory.kernel.lintegral_swap_left ProbabilityTheory.kernel.lintegral_swapLeft

instance IsMarkovKernel.swapLeft (κ : kernel (α × β) γ) [IsMarkovKernel κ] :
    IsMarkovKernel (swapLeft κ) := by
  rw [swap_left]
  infer_instance
#align probability_theory.kernel.is_markov_kernel.swap_left ProbabilityTheory.kernel.IsMarkovKernel.swapLeft

instance IsFiniteKernel.swapLeft (κ : kernel (α × β) γ) [IsFiniteKernel κ] :
    IsFiniteKernel (swapLeft κ) := by
  rw [swap_left]
  infer_instance
#align probability_theory.kernel.is_finite_kernel.swap_left ProbabilityTheory.kernel.IsFiniteKernel.swapLeft

instance IsSFiniteKernel.swapLeft (κ : kernel (α × β) γ) [IsSFiniteKernel κ] :
    IsSFiniteKernel (swapLeft κ) := by
  rw [swap_left]
  infer_instance
#align probability_theory.kernel.is_s_finite_kernel.swap_left ProbabilityTheory.kernel.IsSFiniteKernel.swapLeft

/-- Define a `kernel α (γ × β)` from a `kernel α (β × γ)` by taking the map of `prod.swap`. -/
noncomputable def swapRight (κ : kernel α (β × γ)) : kernel α (γ × β) :=
  map κ Prod.swap measurable_swap
#align probability_theory.kernel.swap_right ProbabilityTheory.kernel.swapRight

theorem swapRight_apply (κ : kernel α (β × γ)) (a : α) : swapRight κ a = (κ a).map Prod.swap :=
  rfl
#align probability_theory.kernel.swap_right_apply ProbabilityTheory.kernel.swapRight_apply

theorem swapRight_apply' (κ : kernel α (β × γ)) (a : α) {s : Set (γ × β)} (hs : MeasurableSet s) :
    swapRight κ a s = κ a { p | p.symm ∈ s } :=
  by
  rw [swap_right_apply, measure.map_apply measurable_swap hs]
  rfl
#align probability_theory.kernel.swap_right_apply' ProbabilityTheory.kernel.swapRight_apply'

theorem lintegral_swapRight (κ : kernel α (β × γ)) (a : α) {g : γ × β → ℝ≥0∞} (hg : Measurable g) :
    (∫⁻ c, g c ∂swapRight κ a) = ∫⁻ bc : β × γ, g bc.symm ∂κ a := by
  rw [swap_right, lintegral_map _ measurable_swap a hg]
#align probability_theory.kernel.lintegral_swap_right ProbabilityTheory.kernel.lintegral_swapRight

instance IsMarkovKernel.swapRight (κ : kernel α (β × γ)) [IsMarkovKernel κ] :
    IsMarkovKernel (swapRight κ) := by
  rw [swap_right]
  infer_instance
#align probability_theory.kernel.is_markov_kernel.swap_right ProbabilityTheory.kernel.IsMarkovKernel.swapRight

instance IsFiniteKernel.swapRight (κ : kernel α (β × γ)) [IsFiniteKernel κ] :
    IsFiniteKernel (swapRight κ) := by
  rw [swap_right]
  infer_instance
#align probability_theory.kernel.is_finite_kernel.swap_right ProbabilityTheory.kernel.IsFiniteKernel.swapRight

instance IsSFiniteKernel.swapRight (κ : kernel α (β × γ)) [IsSFiniteKernel κ] :
    IsSFiniteKernel (swapRight κ) := by
  rw [swap_right]
  infer_instance
#align probability_theory.kernel.is_s_finite_kernel.swap_right ProbabilityTheory.kernel.IsSFiniteKernel.swapRight

/-- Define a `kernel α β` from a `kernel α (β × γ)` by taking the map of the first projection. -/
noncomputable def fst (κ : kernel α (β × γ)) : kernel α β :=
  map κ Prod.fst measurable_fst
#align probability_theory.kernel.fst ProbabilityTheory.kernel.fst

theorem fst_apply (κ : kernel α (β × γ)) (a : α) : fst κ a = (κ a).map Prod.fst :=
  rfl
#align probability_theory.kernel.fst_apply ProbabilityTheory.kernel.fst_apply

theorem fst_apply' (κ : kernel α (β × γ)) (a : α) {s : Set β} (hs : MeasurableSet s) :
    fst κ a s = κ a { p | p.1 ∈ s } :=
  by
  rw [fst_apply, measure.map_apply measurable_fst hs]
  rfl
#align probability_theory.kernel.fst_apply' ProbabilityTheory.kernel.fst_apply'

theorem lintegral_fst (κ : kernel α (β × γ)) (a : α) {g : β → ℝ≥0∞} (hg : Measurable g) :
    (∫⁻ c, g c ∂fst κ a) = ∫⁻ bc : β × γ, g bc.fst ∂κ a := by
  rw [fst, lintegral_map _ measurable_fst a hg]
#align probability_theory.kernel.lintegral_fst ProbabilityTheory.kernel.lintegral_fst

instance IsMarkovKernel.fst (κ : kernel α (β × γ)) [IsMarkovKernel κ] : IsMarkovKernel (fst κ) :=
  by
  rw [fst]
  infer_instance
#align probability_theory.kernel.is_markov_kernel.fst ProbabilityTheory.kernel.IsMarkovKernel.fst

instance IsFiniteKernel.fst (κ : kernel α (β × γ)) [IsFiniteKernel κ] : IsFiniteKernel (fst κ) :=
  by
  rw [fst]
  infer_instance
#align probability_theory.kernel.is_finite_kernel.fst ProbabilityTheory.kernel.IsFiniteKernel.fst

instance IsSFiniteKernel.fst (κ : kernel α (β × γ)) [IsSFiniteKernel κ] : IsSFiniteKernel (fst κ) :=
  by
  rw [fst]
  infer_instance
#align probability_theory.kernel.is_s_finite_kernel.fst ProbabilityTheory.kernel.IsSFiniteKernel.fst

/-- Define a `kernel α γ` from a `kernel α (β × γ)` by taking the map of the second projection. -/
noncomputable def snd (κ : kernel α (β × γ)) : kernel α γ :=
  map κ Prod.snd measurable_snd
#align probability_theory.kernel.snd ProbabilityTheory.kernel.snd

theorem snd_apply (κ : kernel α (β × γ)) (a : α) : snd κ a = (κ a).map Prod.snd :=
  rfl
#align probability_theory.kernel.snd_apply ProbabilityTheory.kernel.snd_apply

theorem snd_apply' (κ : kernel α (β × γ)) (a : α) {s : Set γ} (hs : MeasurableSet s) :
    snd κ a s = κ a { p | p.2 ∈ s } :=
  by
  rw [snd_apply, measure.map_apply measurable_snd hs]
  rfl
#align probability_theory.kernel.snd_apply' ProbabilityTheory.kernel.snd_apply'

theorem lintegral_snd (κ : kernel α (β × γ)) (a : α) {g : γ → ℝ≥0∞} (hg : Measurable g) :
    (∫⁻ c, g c ∂snd κ a) = ∫⁻ bc : β × γ, g bc.snd ∂κ a := by
  rw [snd, lintegral_map _ measurable_snd a hg]
#align probability_theory.kernel.lintegral_snd ProbabilityTheory.kernel.lintegral_snd

instance IsMarkovKernel.snd (κ : kernel α (β × γ)) [IsMarkovKernel κ] : IsMarkovKernel (snd κ) :=
  by
  rw [snd]
  infer_instance
#align probability_theory.kernel.is_markov_kernel.snd ProbabilityTheory.kernel.IsMarkovKernel.snd

instance IsFiniteKernel.snd (κ : kernel α (β × γ)) [IsFiniteKernel κ] : IsFiniteKernel (snd κ) :=
  by
  rw [snd]
  infer_instance
#align probability_theory.kernel.is_finite_kernel.snd ProbabilityTheory.kernel.IsFiniteKernel.snd

instance IsSFiniteKernel.snd (κ : kernel α (β × γ)) [IsSFiniteKernel κ] : IsSFiniteKernel (snd κ) :=
  by
  rw [snd]
  infer_instance
#align probability_theory.kernel.is_s_finite_kernel.snd ProbabilityTheory.kernel.IsSFiniteKernel.snd

end FstSnd

section Comp

/-! ### Composition of two kernels -/


variable {γ : Type _} {mγ : MeasurableSpace γ} {f : β → γ} {g : γ → α}

include mγ

/-- Composition of two s-finite kernels. -/
noncomputable def comp (η : kernel β γ) [IsSFiniteKernel η] (κ : kernel α β) [IsSFiniteKernel κ] :
    kernel α γ :=
  snd (κ ⊗ₖ prodMkLeft η α)
#align probability_theory.kernel.comp ProbabilityTheory.kernel.comp

-- mathport name: kernel.comp
scoped[ProbabilityTheory] infixl:100 " ∘ₖ " => ProbabilityTheory.kernel.comp

theorem comp_apply (η : kernel β γ) [IsSFiniteKernel η] (κ : kernel α β) [IsSFiniteKernel κ] (a : α)
    {s : Set γ} (hs : MeasurableSet s) : (η ∘ₖ κ) a s = ∫⁻ b, η b s ∂κ a :=
  by
  rw [comp, snd_apply' _ _ hs, comp_prod_apply]
  swap; · exact measurable_snd hs
  simp only [Set.mem_setOf_eq, Set.setOf_mem_eq, prod_mk_left_apply' _ _ s]
#align probability_theory.kernel.comp_apply ProbabilityTheory.kernel.comp_apply

theorem lintegral_comp (η : kernel β γ) [IsSFiniteKernel η] (κ : kernel α β) [IsSFiniteKernel κ]
    (a : α) {g : γ → ℝ≥0∞} (hg : Measurable g) :
    (∫⁻ c, g c ∂(η ∘ₖ κ) a) = ∫⁻ b, ∫⁻ c, g c ∂η b ∂κ a :=
  by
  rw [comp, lintegral_snd _ _ hg]
  change
    (∫⁻ bc, (fun a b => g b) bc.fst bc.snd ∂(κ ⊗ₖ prod_mk_left η α) a) = ∫⁻ b, ∫⁻ c, g c ∂η b ∂κ a
  exact lintegral_comp_prod _ _ _ (hg.comp measurable_snd)
#align probability_theory.kernel.lintegral_comp ProbabilityTheory.kernel.lintegral_comp

instance IsMarkovKernel.comp (η : kernel β γ) [IsMarkovKernel η] (κ : kernel α β)
    [IsMarkovKernel κ] : IsMarkovKernel (η ∘ₖ κ) :=
  by
  rw [comp]
  infer_instance
#align probability_theory.kernel.is_markov_kernel.comp ProbabilityTheory.kernel.IsMarkovKernel.comp

instance IsFiniteKernel.comp (η : kernel β γ) [IsFiniteKernel η] (κ : kernel α β)
    [IsFiniteKernel κ] : IsFiniteKernel (η ∘ₖ κ) :=
  by
  rw [comp]
  infer_instance
#align probability_theory.kernel.is_finite_kernel.comp ProbabilityTheory.kernel.IsFiniteKernel.comp

instance IsSFiniteKernel.comp (η : kernel β γ) [IsSFiniteKernel η] (κ : kernel α β)
    [IsSFiniteKernel κ] : IsSFiniteKernel (η ∘ₖ κ) :=
  by
  rw [comp]
  infer_instance
#align probability_theory.kernel.is_s_finite_kernel.comp ProbabilityTheory.kernel.IsSFiniteKernel.comp

/-- Composition of kernels is associative. -/
theorem comp_assoc {δ : Type _} {mδ : MeasurableSpace δ} (ξ : kernel γ δ) [IsSFiniteKernel ξ]
    (η : kernel β γ) [IsSFiniteKernel η] (κ : kernel α β) [IsSFiniteKernel κ] :
    ξ ∘ₖ η ∘ₖ κ = ξ ∘ₖ (η ∘ₖ κ) :=
  by
  refine' ext_fun fun a f hf => _
  simp_rw [lintegral_comp _ _ _ hf, lintegral_comp _ _ _ (measurable_lintegral' ξ hf)]
#align probability_theory.kernel.comp_assoc ProbabilityTheory.kernel.comp_assoc

theorem deterministic_comp_eq_map (hf : Measurable f) (κ : kernel α β) [IsSFiniteKernel κ] :
    deterministic hf ∘ₖ κ = map κ f hf :=
  by
  ext (a s hs) : 2
  simp_rw [map_apply' _ _ _ hs, comp_apply _ _ _ hs, deterministic_apply' hf _ hs,
    lintegral_indicator_const_comp hf hs, one_mul]
#align probability_theory.kernel.deterministic_comp_eq_map ProbabilityTheory.kernel.deterministic_comp_eq_map

theorem comp_deterministic_eq_comap (κ : kernel α β) [IsSFiniteKernel κ] (hg : Measurable g) :
    κ ∘ₖ deterministic hg = comap κ g hg :=
  by
  ext (a s hs) : 2
  simp_rw [comap_apply' _ _ _ s, comp_apply _ _ _ hs, deterministic_apply hg a,
    lintegral_dirac' _ (kernel.measurable_coe κ hs)]
#align probability_theory.kernel.comp_deterministic_eq_comap ProbabilityTheory.kernel.comp_deterministic_eq_comap

end Comp

section Prod

/-! ### Product of two kernels -/


variable {γ : Type _} {mγ : MeasurableSpace γ}

include mγ

/-- Product of two s-finite kernels. -/
noncomputable def prod (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel α γ) [IsSFiniteKernel η] :
    kernel α (β × γ) :=
  κ ⊗ₖ swapLeft (prodMkLeft η β)
#align probability_theory.kernel.prod ProbabilityTheory.kernel.prod

theorem prod_apply (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel α γ) [IsSFiniteKernel η] (a : α)
    {s : Set (β × γ)} (hs : MeasurableSet s) :
    (prod κ η) a s = ∫⁻ b : β, (η a) { c : γ | (b, c) ∈ s } ∂κ a := by
  simp_rw [Prod, comp_prod_apply _ _ _ hs, swap_left_apply _ _, prod_mk_left_apply,
    Prod.swap_prod_mk]
#align probability_theory.kernel.prod_apply ProbabilityTheory.kernel.prod_apply

theorem lintegral_prod (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel α γ) [IsSFiniteKernel η]
    (a : α) {g : β × γ → ℝ≥0∞} (hg : Measurable g) :
    (∫⁻ c, g c ∂(prod κ η) a) = ∫⁻ b, ∫⁻ c, g (b, c) ∂η a ∂κ a := by
  simp_rw [Prod, lintegral_comp_prod _ _ _ hg, swap_left_apply, prod_mk_left_apply,
    Prod.swap_prod_mk]
#align probability_theory.kernel.lintegral_prod ProbabilityTheory.kernel.lintegral_prod

instance IsMarkovKernel.prod (κ : kernel α β) [IsMarkovKernel κ] (η : kernel α γ)
    [IsMarkovKernel η] : IsMarkovKernel (prod κ η) :=
  by
  rw [Prod]
  infer_instance
#align probability_theory.kernel.is_markov_kernel.prod ProbabilityTheory.kernel.IsMarkovKernel.prod

instance IsFiniteKernel.prod (κ : kernel α β) [IsFiniteKernel κ] (η : kernel α γ)
    [IsFiniteKernel η] : IsFiniteKernel (prod κ η) :=
  by
  rw [Prod]
  infer_instance
#align probability_theory.kernel.is_finite_kernel.prod ProbabilityTheory.kernel.IsFiniteKernel.prod

instance IsSFiniteKernel.prod (κ : kernel α β) [IsSFiniteKernel κ] (η : kernel α γ)
    [IsSFiniteKernel η] : IsSFiniteKernel (prod κ η) :=
  by
  rw [Prod]
  infer_instance
#align probability_theory.kernel.is_s_finite_kernel.prod ProbabilityTheory.kernel.IsSFiniteKernel.prod

end Prod

end Kernel

end ProbabilityTheory

