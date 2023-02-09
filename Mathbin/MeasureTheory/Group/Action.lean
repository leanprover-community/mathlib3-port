/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module measure_theory.group.action
! leanprover-community/mathlib commit d101e93197bb5f6ea89bd7ba386b7f7dff1f3903
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Group.MeasurableEquiv
import Mathbin.MeasureTheory.Measure.Regular
import Mathbin.Dynamics.Ergodic.MeasurePreserving
import Mathbin.Dynamics.Minimal

/-!
# Measures invariant under group actions

A measure `μ : measure α` is said to be *invariant* under an action of a group `G` if scalar
multiplication by `c : G` is a measure preserving map for all `c`. In this file we define a
typeclass for measures invariant under action of an (additive or multiplicative) group and prove
some basic properties of such measures.
-/


open Ennreal Nnreal Pointwise Topology

open MeasureTheory MeasureTheory.Measure Set Function

namespace MeasureTheory

variable {G M α : Type _} {s : Set α}

/- ./././Mathport/Syntax/Translate/Command.lean:388:30: infer kinds are unsupported in Lean 4: #[`measure_preimage_vadd] [] -/
/-- A measure `μ : measure α` is invariant under an additive action of `M` on `α` if for any
measurable set `s : set α` and `c : M`, the measure of its preimage under `λ x, c +ᵥ x` is equal to
the measure of `s`. -/
class VaddInvariantMeasure (M α : Type _) [VAdd M α] {_ : MeasurableSpace α} (μ : Measure α) :
  Prop where
  measure_preimage_vadd : ∀ (c : M) ⦃s : Set α⦄, MeasurableSet s → μ ((fun x => c +ᵥ x) ⁻¹' s) = μ s
#align measure_theory.vadd_invariant_measure MeasureTheory.VaddInvariantMeasure

/- ./././Mathport/Syntax/Translate/Command.lean:388:30: infer kinds are unsupported in Lean 4: #[`measure_preimage_smul] [] -/
/-- A measure `μ : measure α` is invariant under a multiplicative action of `M` on `α` if for any
measurable set `s : set α` and `c : M`, the measure of its preimage under `λ x, c • x` is equal to
the measure of `s`. -/
@[to_additive]
class SmulInvariantMeasure (M α : Type _) [SMul M α] {_ : MeasurableSpace α} (μ : Measure α) :
  Prop where
  measure_preimage_smul : ∀ (c : M) ⦃s : Set α⦄, MeasurableSet s → μ ((fun x => c • x) ⁻¹' s) = μ s
#align measure_theory.smul_invariant_measure MeasureTheory.SmulInvariantMeasure
#align measure_theory.vadd_invariant_measure MeasureTheory.VaddInvariantMeasure

namespace SmulInvariantMeasure

@[to_additive]
instance zero [MeasurableSpace α] [SMul M α] : SmulInvariantMeasure M α 0 :=
  ⟨fun _ _ _ => rfl⟩
#align measure_theory.smul_invariant_measure.zero MeasureTheory.SmulInvariantMeasure.zero
#align measure_theory.vadd_invariant_measure.zero MeasureTheory.VaddInvariantMeasure.zero

variable [SMul M α] {m : MeasurableSpace α} {μ ν : Measure α}

@[to_additive]
instance add [SmulInvariantMeasure M α μ] [SmulInvariantMeasure M α ν] :
    SmulInvariantMeasure M α (μ + ν) :=
  ⟨fun c s hs =>
    show _ + _ = _ + _ from
      congr_arg₂ (· + ·) (measure_preimage_smul μ c hs) (measure_preimage_smul ν c hs)⟩
#align measure_theory.smul_invariant_measure.add MeasureTheory.SmulInvariantMeasure.add
#align measure_theory.vadd_invariant_measure.add MeasureTheory.VaddInvariantMeasure.add

@[to_additive]
instance smul [SmulInvariantMeasure M α μ] (c : ℝ≥0∞) : SmulInvariantMeasure M α (c • μ) :=
  ⟨fun a s hs => show c • _ = c • _ from congr_arg ((· • ·) c) (measure_preimage_smul μ a hs)⟩
#align measure_theory.smul_invariant_measure.smul MeasureTheory.SmulInvariantMeasure.smul
#align measure_theory.vadd_invariant_measure.vadd MeasureTheory.VaddInvariantMeasure.vadd

@[to_additive]
instance smulNnreal [SmulInvariantMeasure M α μ] (c : ℝ≥0) : SmulInvariantMeasure M α (c • μ) :=
  SmulInvariantMeasure.smul c
#align measure_theory.smul_invariant_measure.smul_nnreal MeasureTheory.SmulInvariantMeasure.smulNnreal
#align measure_theory.vadd_invariant_measure.vadd_nnreal MeasureTheory.VaddInvariantMeasure.vadd_nnreal

end SmulInvariantMeasure

section HasMeasurableSmul

variable {m : MeasurableSpace α} [MeasurableSpace M] [SMul M α] [HasMeasurableSmul M α] (c : M)
  (μ : Measure α) [SmulInvariantMeasure M α μ]

@[simp, to_additive]
theorem measurePreservingSmul : MeasurePreserving ((· • ·) c) μ μ :=
  { Measurable := measurable_const_smul c
    map_eq := by
      ext1 s hs
      rw [map_apply (measurable_const_smul c) hs]
      exact smul_invariant_measure.measure_preimage_smul μ c hs }
#align measure_theory.measure_preserving_smul MeasureTheory.measurePreservingSmul
#align measure_theory.measure_preserving_vadd MeasureTheory.measure_preserving_vadd

@[simp, to_additive]
theorem map_smul : map ((· • ·) c) μ = μ :=
  (measurePreservingSmul c μ).map_eq
#align measure_theory.map_smul MeasureTheory.map_smul
#align measure_theory.map_vadd MeasureTheory.map_vadd

end HasMeasurableSmul

variable (G) {m : MeasurableSpace α} [Group G] [MulAction G α] [MeasurableSpace G]
  [HasMeasurableSmul G α] (c : G) (μ : Measure α)

/-- Equivalent definitions of a measure invariant under a multiplicative action of a group.

- 0: `smul_invariant_measure G α μ`;

- 1: for every `c : G` and a measurable set `s`, the measure of the preimage of `s` under scalar
     multiplication by `c` is equal to the measure of `s`;

- 2: for every `c : G` and a measurable set `s`, the measure of the image `c • s` of `s` under
     scalar multiplication by `c` is equal to the measure of `s`;

- 3, 4: properties 2, 3 for any set, including non-measurable ones;

- 5: for any `c : G`, scalar multiplication by `c` maps `μ` to `μ`;

- 6: for any `c : G`, scalar multiplication by `c` is a measure preserving map. -/
@[to_additive]
theorem smulInvariantMeasure_tFAE :
    TFAE
      [SmulInvariantMeasure G α μ, ∀ (c : G) (s), MeasurableSet s → μ ((· • ·) c ⁻¹' s) = μ s,
        ∀ (c : G) (s), MeasurableSet s → μ (c • s) = μ s, ∀ (c : G) (s), μ ((· • ·) c ⁻¹' s) = μ s,
        ∀ (c : G) (s), μ (c • s) = μ s, ∀ c : G, Measure.map ((· • ·) c) μ = μ,
        ∀ c : G, MeasurePreserving ((· • ·) c) μ μ] :=
  by
  tfae_have 1 ↔ 2; exact ⟨fun h => h.1, fun h => ⟨h⟩⟩
  tfae_have 1 → 6;
  · intro h c
    exact (measure_preserving_smul c μ).map_eq
  tfae_have 6 → 7; exact fun H c => ⟨measurable_const_smul c, H c⟩
  tfae_have 7 → 4; exact fun H c => (H c).measure_preimage_emb (measurableEmbedding_const_smul c)
  tfae_have 4 → 5;
  exact fun H c s => by
    rw [← preimage_smul_inv]
    apply H
  tfae_have 5 → 3; exact fun H c s hs => H c s
  tfae_have 3 → 2;
  · intro H c s hs
    rw [preimage_smul]
    exact H c⁻¹ s hs
  tfae_finish
#align measure_theory.smul_invariant_measure_tfae MeasureTheory.smulInvariantMeasure_tFAE
#align measure_theory.vadd_invariant_measure_tfae MeasureTheory.vadd_invariant_measure_tfae

/-- Equivalent definitions of a measure invariant under an additive action of a group.

- 0: `vadd_invariant_measure G α μ`;

- 1: for every `c : G` and a measurable set `s`, the measure of the preimage of `s` under
     vector addition `(+ᵥ) c` is equal to the measure of `s`;

- 2: for every `c : G` and a measurable set `s`, the measure of the image `c +ᵥ s` of `s` under
     vector addition `(+ᵥ) c` is equal to the measure of `s`;

- 3, 4: properties 2, 3 for any set, including non-measurable ones;

- 5: for any `c : G`, vector addition of `c` maps `μ` to `μ`;

- 6: for any `c : G`, vector addition of `c` is a measure preserving map. -/
add_decl_doc vadd_invariant_measure_tfae

variable {G} [SmulInvariantMeasure G α μ]

@[simp, to_additive]
theorem measure_preimage_smul (s : Set α) : μ ((· • ·) c ⁻¹' s) = μ s :=
  ((smulInvariantMeasure_tFAE G μ).out 0 3).mp ‹_› c s
#align measure_theory.measure_preimage_smul MeasureTheory.measure_preimage_smul
#align measure_theory.measure_preimage_vadd MeasureTheory.measure_preimage_vadd

@[simp, to_additive]
theorem measure_smul (s : Set α) : μ (c • s) = μ s :=
  ((smulInvariantMeasure_tFAE G μ).out 0 4).mp ‹_› c s
#align measure_theory.measure_smul MeasureTheory.measure_smul
#align measure_theory.measure_vadd MeasureTheory.measure_vadd

variable {μ}

@[to_additive]
theorem NullMeasurableSet.smul {s} (hs : NullMeasurableSet s μ) (c : G) :
    NullMeasurableSet (c • s) μ := by
  simpa only [← preimage_smul_inv] using
    hs.preimage (measure_preserving_smul _ _).QuasiMeasurePreserving
#align measure_theory.null_measurable_set.smul MeasureTheory.NullMeasurableSet.smul
#align measure_theory.null_measurable_set.vadd MeasureTheory.NullMeasurableSet.vadd

theorem measure_smul_null {s} (h : μ s = 0) (c : G) : μ (c • s) = 0 := by rwa [measure_smul]
#align measure_theory.measure_smul_null MeasureTheory.measure_smul_null

section IsMinimal

variable (G) [TopologicalSpace α] [HasContinuousConstSMul G α] [MulAction.IsMinimal G α]
  {K U : Set α}

/-- If measure `μ` is invariant under a group action and is nonzero on a compact set `K`, then it is
positive on any nonempty open set. In case of a regular measure, one can assume `μ ≠ 0` instead of
`μ K ≠ 0`, see `measure_theory.measure_is_open_pos_of_smul_invariant_of_ne_zero`. -/
@[to_additive]
theorem measure_isOpen_pos_of_smul_invariant_of_compact_ne_zero (hK : IsCompact K) (hμK : μ K ≠ 0)
    (hU : IsOpen U) (hne : U.Nonempty) : 0 < μ U :=
  let ⟨t, ht⟩ := hK.exists_finite_cover_smul G hU hne
  pos_iff_ne_zero.2 fun hμU =>
    hμK <|
      measure_mono_null ht <|
        (measure_bUnion_null_iff t.countable_toSet).2 fun _ _ => by rwa [measure_smul]
#align measure_theory.measure_is_open_pos_of_smul_invariant_of_compact_ne_zero MeasureTheory.measure_isOpen_pos_of_smul_invariant_of_compact_ne_zero
#align measure_theory.measure_is_open_pos_of_vadd_invariant_of_compact_ne_zero MeasureTheory.measure_is_open_pos_of_vadd_invariant_of_compact_ne_zero

/-- If measure `μ` is invariant under an additive group action and is nonzero on a compact set `K`,
then it is positive on any nonempty open set. In case of a regular measure, one can assume `μ ≠ 0`
instead of `μ K ≠ 0`, see `measure_theory.measure_is_open_pos_of_vadd_invariant_of_ne_zero`. -/
add_decl_doc measure_is_open_pos_of_vadd_invariant_of_compact_ne_zero

@[to_additive]
theorem isLocallyFiniteMeasureOfSmulInvariant (hU : IsOpen U) (hne : U.Nonempty) (hμU : μ U ≠ ∞) :
    IsLocallyFiniteMeasure μ :=
  ⟨fun x =>
    let ⟨g, hg⟩ := hU.exists_smul_mem G x hne
    ⟨(· • ·) g ⁻¹' U, (hU.Preimage (continuous_id.const_smul _)).mem_nhds hg,
      Ne.lt_top <| by rwa [measure_preimage_smul]⟩⟩
#align measure_theory.is_locally_finite_measure_of_smul_invariant MeasureTheory.isLocallyFiniteMeasureOfSmulInvariant
#align measure_theory.is_locally_finite_measure_of_vadd_invariant MeasureTheory.is_locally_finite_measure_of_vadd_invariant

variable [Measure.Regular μ]

@[to_additive]
theorem measure_isOpen_pos_of_smul_invariant_of_ne_zero (hμ : μ ≠ 0) (hU : IsOpen U)
    (hne : U.Nonempty) : 0 < μ U :=
  let ⟨K, hK, hμK⟩ := Regular.exists_compact_not_null.mpr hμ
  measure_isOpen_pos_of_smul_invariant_of_compact_ne_zero G hK hμK hU hne
#align measure_theory.measure_is_open_pos_of_smul_invariant_of_ne_zero MeasureTheory.measure_isOpen_pos_of_smul_invariant_of_ne_zero
#align measure_theory.measure_is_open_pos_of_vadd_invariant_of_ne_zero MeasureTheory.measure_is_open_pos_of_vadd_invariant_of_ne_zero

@[to_additive]
theorem measure_pos_iff_nonempty_of_smul_invariant (hμ : μ ≠ 0) (hU : IsOpen U) :
    0 < μ U ↔ U.Nonempty :=
  ⟨fun h => nonempty_of_measure_ne_zero h.ne',
    measure_isOpen_pos_of_smul_invariant_of_ne_zero G hμ hU⟩
#align measure_theory.measure_pos_iff_nonempty_of_smul_invariant MeasureTheory.measure_pos_iff_nonempty_of_smul_invariant
#align measure_theory.measure_pos_iff_nonempty_of_vadd_invariant MeasureTheory.measure_pos_iff_nonempty_of_vadd_invariant

include G

@[to_additive]
theorem measure_eq_zero_iff_eq_empty_of_smul_invariant (hμ : μ ≠ 0) (hU : IsOpen U) :
    μ U = 0 ↔ U = ∅ := by
  rw [← not_iff_not, ← Ne.def, ← pos_iff_ne_zero,
    measure_pos_iff_nonempty_of_smul_invariant G hμ hU, nonempty_iff_ne_empty]
#align measure_theory.measure_eq_zero_iff_eq_empty_of_smul_invariant MeasureTheory.measure_eq_zero_iff_eq_empty_of_smul_invariant
#align measure_theory.measure_eq_zero_iff_eq_empty_of_vadd_invariant MeasureTheory.measure_eq_zero_iff_eq_empty_of_vadd_invariant

end IsMinimal

theorem smul_ae_eq_self_of_mem_zpowers {x y : G} (hs : (x • s : Set α) =ᵐ[μ] s)
    (hy : y ∈ Subgroup.zpowers x) : (y • s : Set α) =ᵐ[μ] s :=
  by
  obtain ⟨k, rfl⟩ := subgroup.mem_zpowers_iff.mp hy
  let e : α ≃ α := MulAction.toPermHom G α x
  have he : quasi_measure_preserving e μ μ := (measure_preserving_smul x μ).QuasiMeasurePreserving
  have he' : quasi_measure_preserving e.symm μ μ :=
    (measure_preserving_smul x⁻¹ μ).QuasiMeasurePreserving
  simpa only [MulAction.toPermHom_apply, MulAction.toPerm_apply, image_smul, ←
    MonoidHom.map_zpow] using he.image_zpow_ae_eq he' k hs
#align measure_theory.smul_ae_eq_self_of_mem_zpowers MeasureTheory.smul_ae_eq_self_of_mem_zpowers

theorem vadd_ae_eq_self_of_mem_zmultiples {G : Type _} [MeasurableSpace G] [AddGroup G]
    [AddAction G α] [VaddInvariantMeasure G α μ] [HasMeasurableVadd G α] {x y : G}
    (hs : (x +ᵥ s : Set α) =ᵐ[μ] s) (hy : y ∈ AddSubgroup.zmultiples x) :
    (y +ᵥ s : Set α) =ᵐ[μ] s :=
  by
  letI : MeasurableSpace (Multiplicative G) := (by infer_instance : MeasurableSpace G)
  letI : smul_invariant_measure (Multiplicative G) α μ :=
    ⟨fun g => vadd_invariant_measure.measure_preimage_vadd μ (Multiplicative.toAdd g)⟩
  letI : HasMeasurableSmul (Multiplicative G) α :=
    { measurable_const_smul := fun g => measurable_const_vadd (Multiplicative.toAdd g)
      measurable_smul_const := fun a =>
        @measurable_vadd_const (Multiplicative G) α (by infer_instance : VAdd G α) _ _
          (by infer_instance : HasMeasurableVadd G α) a }
  exact @smul_ae_eq_self_of_mem_zpowers (Multiplicative G) α _ _ _ _ _ _ _ _ _ _ hs hy
#align measure_theory.vadd_ae_eq_self_of_mem_zmultiples MeasureTheory.vadd_ae_eq_self_of_mem_zmultiples

attribute [to_additive vadd_ae_eq_self_of_mem_zmultiples] smul_ae_eq_self_of_mem_zpowers

end MeasureTheory

