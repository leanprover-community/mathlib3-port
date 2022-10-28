/-
Copyright (c) 2021 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anatole Dedecker
-/
import Mathbin.Topology.ContinuousOn

/-!
# Left and right continuity

In this file we prove a few lemmas about left and right continuous functions:

* `continuous_within_at_Ioi_iff_Ici`: two definitions of right continuity
  (with `(a, ∞)` and with `[a, ∞)`) are equivalent;
* `continuous_within_at_Iio_iff_Iic`: two definitions of left continuity
  (with `(-∞, a)` and with `(-∞, a]`) are equivalent;
* `continuous_at_iff_continuous_left_right`, `continuous_at_iff_continuous_left'_right'` :
  a function is continuous at `a` if and only if it is left and right continuous at `a`.

## Tags

left continuous, right continuous
-/


open Set Filter

open TopologicalSpace

section PartialOrder

variable {α β : Type _} [TopologicalSpace α] [PartialOrder α] [TopologicalSpace β]

theorem continuous_within_at_Ioi_iff_Ici {a : α} {f : α → β} :
    ContinuousWithinAt f (IoiCat a) a ↔ ContinuousWithinAt f (IciCat a) a := by
  simp only [← Ici_diff_left, continuous_within_at_diff_self]

theorem continuous_within_at_Iio_iff_Iic {a : α} {f : α → β} :
    ContinuousWithinAt f (IioCat a) a ↔ ContinuousWithinAt f (IicCat a) a :=
  @continuous_within_at_Ioi_iff_Ici αᵒᵈ _ ‹TopologicalSpace α› _ _ _ f

theorem nhds_left'_le_nhds_ne (a : α) : 𝓝[<] a ≤ 𝓝[≠] a :=
  nhds_within_mono a fun y hy => ne_of_lt hy

theorem nhds_right'_le_nhds_ne (a : α) : 𝓝[>] a ≤ 𝓝[≠] a :=
  nhds_within_mono a fun y hy => ne_of_gt hy

end PartialOrder

section TopologicalSpace

variable {α β : Type _} [TopologicalSpace α] [LinearOrder α] [TopologicalSpace β]

theorem nhds_left_sup_nhds_right (a : α) : 𝓝[≤] a ⊔ 𝓝[≥] a = 𝓝 a := by
  rw [← nhds_within_union, Iic_union_Ici, nhds_within_univ]

theorem nhds_left'_sup_nhds_right (a : α) : 𝓝[<] a ⊔ 𝓝[≥] a = 𝓝 a := by
  rw [← nhds_within_union, Iio_union_Ici, nhds_within_univ]

theorem nhds_left_sup_nhds_right' (a : α) : 𝓝[≤] a ⊔ 𝓝[>] a = 𝓝 a := by
  rw [← nhds_within_union, Iic_union_Ioi, nhds_within_univ]

theorem nhds_left'_sup_nhds_right' (a : α) : 𝓝[<] a ⊔ 𝓝[>] a = 𝓝[≠] a := by rw [← nhds_within_union, Iio_union_Ioi]

theorem continuous_at_iff_continuous_left_right {a : α} {f : α → β} :
    ContinuousAt f a ↔ ContinuousWithinAt f (IicCat a) a ∧ ContinuousWithinAt f (IciCat a) a := by
  simp only [ContinuousWithinAt, ContinuousAt, ← tendsto_sup, nhds_left_sup_nhds_right]

theorem continuous_at_iff_continuous_left'_right' {a : α} {f : α → β} :
    ContinuousAt f a ↔ ContinuousWithinAt f (IioCat a) a ∧ ContinuousWithinAt f (IoiCat a) a := by
  rw [continuous_within_at_Ioi_iff_Ici, continuous_within_at_Iio_iff_Iic, continuous_at_iff_continuous_left_right]

end TopologicalSpace

