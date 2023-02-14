/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module topology.metric_space.holder
! leanprover-community/mathlib commit 48085f140e684306f9e7da907cd5932056d1aded
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.MetricSpace.Lipschitz
import Mathbin.Analysis.SpecialFunctions.Pow

/-!
# Hölder continuous functions

In this file we define Hölder continuity on a set and on the whole space. We also prove some basic
properties of Hölder continuous functions.

## Main definitions

* `holder_on_with`: `f : X → Y` is said to be *Hölder continuous* with constant `C : ℝ≥0` and
  exponent `r : ℝ≥0` on a set `s`, if `edist (f x) (f y) ≤ C * edist x y ^ r` for all `x y ∈ s`;
* `holder_with`: `f : X → Y` is said to be *Hölder continuous* with constant `C : ℝ≥0` and exponent
  `r : ℝ≥0`, if `edist (f x) (f y) ≤ C * edist x y ^ r` for all `x y : X`.

## Implementation notes

We use the type `ℝ≥0` (a.k.a. `nnreal`) for `C` because this type has coercion both to `ℝ` and
`ℝ≥0∞`, so it can be easily used both in inequalities about `dist` and `edist`. We also use `ℝ≥0`
for `r` to ensure that `d ^ r` is monotone in `d`. It might be a good idea to use
`ℝ>0` for `r` but we don't have this type in `mathlib` (yet).

## Tags

Hölder continuity, Lipschitz continuity

 -/


variable {X Y Z : Type _}

open Filter Set

open Nnreal Ennreal Topology

section Emetric

variable [PseudoEmetricSpace X] [PseudoEmetricSpace Y] [PseudoEmetricSpace Z]

/-- A function `f : X → Y` between two `pseudo_emetric_space`s is Hölder continuous with constant
`C : ℝ≥0` and exponent `r : ℝ≥0`, if `edist (f x) (f y) ≤ C * edist x y ^ r` for all `x y : X`. -/
def HolderWith (C r : ℝ≥0) (f : X → Y) : Prop :=
  ∀ x y, edist (f x) (f y) ≤ C * edist x y ^ (r : ℝ)
#align holder_with HolderWith

/-- A function `f : X → Y` between two `pseudo_emeteric_space`s is Hölder continuous with constant
`C : ℝ≥0` and exponent `r : ℝ≥0` on a set `s : set X`, if `edist (f x) (f y) ≤ C * edist x y ^ r`
for all `x y ∈ s`. -/
def HolderOnWith (C r : ℝ≥0) (f : X → Y) (s : Set X) : Prop :=
  ∀ x ∈ s, ∀ y ∈ s, edist (f x) (f y) ≤ C * edist x y ^ (r : ℝ)
#align holder_on_with HolderOnWith

@[simp]
theorem holderOnWith_empty (C r : ℝ≥0) (f : X → Y) : HolderOnWith C r f ∅ := fun x hx => hx.elim
#align holder_on_with_empty holderOnWith_empty

@[simp]
theorem holderOnWith_singleton (C r : ℝ≥0) (f : X → Y) (x : X) : HolderOnWith C r f {x} :=
  by
  rintro a (rfl : a = x) b (rfl : b = a)
  rw [edist_self]
  exact zero_le _
#align holder_on_with_singleton holderOnWith_singleton

theorem Set.Subsingleton.holderOnWith {s : Set X} (hs : s.Subsingleton) (C r : ℝ≥0) (f : X → Y) :
    HolderOnWith C r f s :=
  hs.inductionOn (holderOnWith_empty C r f) (holderOnWith_singleton C r f)
#align set.subsingleton.holder_on_with Set.Subsingleton.holderOnWith

theorem holderOnWith_univ {C r : ℝ≥0} {f : X → Y} : HolderOnWith C r f univ ↔ HolderWith C r f := by
  simp only [HolderOnWith, HolderWith, mem_univ, true_imp_iff]
#align holder_on_with_univ holderOnWith_univ

@[simp]
theorem holderOnWith_one {C : ℝ≥0} {f : X → Y} {s : Set X} :
    HolderOnWith C 1 f s ↔ LipschitzOnWith C f s := by
  simp only [HolderOnWith, LipschitzOnWith, Nnreal.coe_one, Ennreal.rpow_one]
#align holder_on_with_one holderOnWith_one

alias holderOnWith_one ↔ _ LipschitzOnWith.holderOnWith
#align lipschitz_on_with.holder_on_with LipschitzOnWith.holderOnWith

@[simp]
theorem holderWith_one {C : ℝ≥0} {f : X → Y} : HolderWith C 1 f ↔ LipschitzWith C f :=
  holderOnWith_univ.symm.trans <| holderOnWith_one.trans lipschitz_on_univ
#align holder_with_one holderWith_one

alias holderWith_one ↔ _ LipschitzWith.holderWith
#align lipschitz_with.holder_with LipschitzWith.holderWith

theorem holderWith_id : HolderWith 1 1 (id : X → X) :=
  LipschitzWith.id.HolderWith
#align holder_with_id holderWith_id

protected theorem HolderWith.holderOnWith {C r : ℝ≥0} {f : X → Y} (h : HolderWith C r f)
    (s : Set X) : HolderOnWith C r f s := fun x _ y _ => h x y
#align holder_with.holder_on_with HolderWith.holderOnWith

namespace HolderOnWith

variable {C r : ℝ≥0} {f : X → Y} {s t : Set X}

theorem edist_le (h : HolderOnWith C r f s) {x y : X} (hx : x ∈ s) (hy : y ∈ s) :
    edist (f x) (f y) ≤ C * edist x y ^ (r : ℝ) :=
  h x hx y hy
#align holder_on_with.edist_le HolderOnWith.edist_le

theorem edist_le_of_le (h : HolderOnWith C r f s) {x y : X} (hx : x ∈ s) (hy : y ∈ s) {d : ℝ≥0∞}
    (hd : edist x y ≤ d) : edist (f x) (f y) ≤ C * d ^ (r : ℝ) :=
  (h.edist_le hx hy).trans (mul_le_mul_left' (Ennreal.rpow_le_rpow hd r.coe_nonneg) _)
#align holder_on_with.edist_le_of_le HolderOnWith.edist_le_of_le

theorem comp {Cg rg : ℝ≥0} {g : Y → Z} {t : Set Y} (hg : HolderOnWith Cg rg g t) {Cf rf : ℝ≥0}
    {f : X → Y} (hf : HolderOnWith Cf rf f s) (hst : MapsTo f s t) :
    HolderOnWith (Cg * Cf ^ (rg : ℝ)) (rg * rf) (g ∘ f) s :=
  by
  intro x hx y hy
  rw [Ennreal.coe_mul, mul_comm rg, Nnreal.coe_mul, Ennreal.rpow_mul, mul_assoc, ←
    Ennreal.coe_rpow_of_nonneg _ rg.coe_nonneg, ← Ennreal.mul_rpow_of_nonneg _ _ rg.coe_nonneg]
  exact hg.edist_le_of_le (hst hx) (hst hy) (hf.edist_le hx hy)
#align holder_on_with.comp HolderOnWith.comp

theorem comp_holderWith {Cg rg : ℝ≥0} {g : Y → Z} {t : Set Y} (hg : HolderOnWith Cg rg g t)
    {Cf rf : ℝ≥0} {f : X → Y} (hf : HolderWith Cf rf f) (ht : ∀ x, f x ∈ t) :
    HolderWith (Cg * Cf ^ (rg : ℝ)) (rg * rf) (g ∘ f) :=
  holderOnWith_univ.mp <| hg.comp (hf.HolderOnWith univ) fun x _ => ht x
#align holder_on_with.comp_holder_with HolderOnWith.comp_holderWith

/-- A Hölder continuous function is uniformly continuous -/
protected theorem uniformContinuousOn (hf : HolderOnWith C r f s) (h0 : 0 < r) :
    UniformContinuousOn f s :=
  by
  refine' Emetric.uniformContinuousOn_iff.2 fun ε εpos => _
  have : tendsto (fun d : ℝ≥0∞ => (C : ℝ≥0∞) * d ^ (r : ℝ)) (𝓝 0) (𝓝 0) :=
    Ennreal.tendsto_const_mul_rpow_nhds_zero_of_pos Ennreal.coe_ne_top h0
  rcases ennreal.nhds_zero_basis.mem_iff.1 (this (gt_mem_nhds εpos)) with ⟨δ, δ0, H⟩
  exact ⟨δ, δ0, fun x hx y hy h => (hf.edist_le hx hy).trans_lt (H h)⟩
#align holder_on_with.uniform_continuous_on HolderOnWith.uniformContinuousOn

protected theorem continuousOn (hf : HolderOnWith C r f s) (h0 : 0 < r) : ContinuousOn f s :=
  (hf.UniformContinuousOn h0).ContinuousOn
#align holder_on_with.continuous_on HolderOnWith.continuousOn

protected theorem mono (hf : HolderOnWith C r f s) (ht : t ⊆ s) : HolderOnWith C r f t :=
  fun x hx y hy => hf.edist_le (ht hx) (ht hy)
#align holder_on_with.mono HolderOnWith.mono

theorem ediam_image_le_of_le (hf : HolderOnWith C r f s) {d : ℝ≥0∞} (hd : Emetric.diam s ≤ d) :
    Emetric.diam (f '' s) ≤ C * d ^ (r : ℝ) :=
  Emetric.diam_image_le_iff.2 fun x hx y hy =>
    hf.edist_le_of_le hx hy <| (Emetric.edist_le_diam_of_mem hx hy).trans hd
#align holder_on_with.ediam_image_le_of_le HolderOnWith.ediam_image_le_of_le

theorem ediam_image_le (hf : HolderOnWith C r f s) :
    Emetric.diam (f '' s) ≤ C * Emetric.diam s ^ (r : ℝ) :=
  hf.ediam_image_le_of_le le_rfl
#align holder_on_with.ediam_image_le HolderOnWith.ediam_image_le

theorem ediam_image_le_of_subset (hf : HolderOnWith C r f s) (ht : t ⊆ s) :
    Emetric.diam (f '' t) ≤ C * Emetric.diam t ^ (r : ℝ) :=
  (hf.mono ht).ediam_image_le
#align holder_on_with.ediam_image_le_of_subset HolderOnWith.ediam_image_le_of_subset

theorem ediam_image_le_of_subset_of_le (hf : HolderOnWith C r f s) (ht : t ⊆ s) {d : ℝ≥0∞}
    (hd : Emetric.diam t ≤ d) : Emetric.diam (f '' t) ≤ C * d ^ (r : ℝ) :=
  (hf.mono ht).ediam_image_le_of_le hd
#align holder_on_with.ediam_image_le_of_subset_of_le HolderOnWith.ediam_image_le_of_subset_of_le

theorem ediam_image_inter_le_of_le (hf : HolderOnWith C r f s) {d : ℝ≥0∞}
    (hd : Emetric.diam t ≤ d) : Emetric.diam (f '' (t ∩ s)) ≤ C * d ^ (r : ℝ) :=
  hf.ediam_image_le_of_subset_of_le (inter_subset_right _ _) <|
    (Emetric.diam_mono <| inter_subset_left _ _).trans hd
#align holder_on_with.ediam_image_inter_le_of_le HolderOnWith.ediam_image_inter_le_of_le

theorem ediam_image_inter_le (hf : HolderOnWith C r f s) (t : Set X) :
    Emetric.diam (f '' (t ∩ s)) ≤ C * Emetric.diam t ^ (r : ℝ) :=
  hf.ediam_image_inter_le_of_le le_rfl
#align holder_on_with.ediam_image_inter_le HolderOnWith.ediam_image_inter_le

end HolderOnWith

namespace HolderWith

variable {C r : ℝ≥0} {f : X → Y}

theorem edist_le (h : HolderWith C r f) (x y : X) : edist (f x) (f y) ≤ C * edist x y ^ (r : ℝ) :=
  h x y
#align holder_with.edist_le HolderWith.edist_le

theorem edist_le_of_le (h : HolderWith C r f) {x y : X} {d : ℝ≥0∞} (hd : edist x y ≤ d) :
    edist (f x) (f y) ≤ C * d ^ (r : ℝ) :=
  (h.HolderOnWith univ).edist_le_of_le trivial trivial hd
#align holder_with.edist_le_of_le HolderWith.edist_le_of_le

theorem comp {Cg rg : ℝ≥0} {g : Y → Z} (hg : HolderWith Cg rg g) {Cf rf : ℝ≥0} {f : X → Y}
    (hf : HolderWith Cf rf f) : HolderWith (Cg * Cf ^ (rg : ℝ)) (rg * rf) (g ∘ f) :=
  (hg.HolderOnWith univ).comp_holderWith hf fun _ => trivial
#align holder_with.comp HolderWith.comp

theorem comp_holderOnWith {Cg rg : ℝ≥0} {g : Y → Z} (hg : HolderWith Cg rg g) {Cf rf : ℝ≥0}
    {f : X → Y} {s : Set X} (hf : HolderOnWith Cf rf f s) :
    HolderOnWith (Cg * Cf ^ (rg : ℝ)) (rg * rf) (g ∘ f) s :=
  (hg.HolderOnWith univ).comp hf fun _ _ => trivial
#align holder_with.comp_holder_on_with HolderWith.comp_holderOnWith

/-- A Hölder continuous function is uniformly continuous -/
protected theorem uniformContinuous (hf : HolderWith C r f) (h0 : 0 < r) : UniformContinuous f :=
  uniformContinuousOn_univ.mp <| (hf.HolderOnWith univ).UniformContinuousOn h0
#align holder_with.uniform_continuous HolderWith.uniformContinuous

protected theorem continuous (hf : HolderWith C r f) (h0 : 0 < r) : Continuous f :=
  (hf.UniformContinuous h0).Continuous
#align holder_with.continuous HolderWith.continuous

theorem ediam_image_le (hf : HolderWith C r f) (s : Set X) :
    Emetric.diam (f '' s) ≤ C * Emetric.diam s ^ (r : ℝ) :=
  Emetric.diam_image_le_iff.2 fun x hx y hy =>
    hf.edist_le_of_le <| Emetric.edist_le_diam_of_mem hx hy
#align holder_with.ediam_image_le HolderWith.ediam_image_le

end HolderWith

end Emetric

section Metric

variable [PseudoMetricSpace X] [PseudoMetricSpace Y] {C r : ℝ≥0} {f : X → Y}

namespace HolderWith

theorem nndist_le_of_le (hf : HolderWith C r f) {x y : X} {d : ℝ≥0} (hd : nndist x y ≤ d) :
    nndist (f x) (f y) ≤ C * d ^ (r : ℝ) :=
  by
  rw [← Ennreal.coe_le_coe, ← edist_nndist, Ennreal.coe_mul, ←
    Ennreal.coe_rpow_of_nonneg _ r.coe_nonneg]
  apply hf.edist_le_of_le
  rwa [edist_nndist, Ennreal.coe_le_coe]
#align holder_with.nndist_le_of_le HolderWith.nndist_le_of_le

theorem nndist_le (hf : HolderWith C r f) (x y : X) :
    nndist (f x) (f y) ≤ C * nndist x y ^ (r : ℝ) :=
  hf.nndist_le_of_le le_rfl
#align holder_with.nndist_le HolderWith.nndist_le

theorem dist_le_of_le (hf : HolderWith C r f) {x y : X} {d : ℝ} (hd : dist x y ≤ d) :
    dist (f x) (f y) ≤ C * d ^ (r : ℝ) :=
  by
  lift d to ℝ≥0 using dist_nonneg.trans hd
  rw [dist_nndist] at hd⊢
  norm_cast  at hd⊢
  exact hf.nndist_le_of_le hd
#align holder_with.dist_le_of_le HolderWith.dist_le_of_le

theorem dist_le (hf : HolderWith C r f) (x y : X) : dist (f x) (f y) ≤ C * dist x y ^ (r : ℝ) :=
  hf.dist_le_of_le le_rfl
#align holder_with.dist_le HolderWith.dist_le

end HolderWith

end Metric

