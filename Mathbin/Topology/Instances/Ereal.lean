/-
Copyright (c) 2021 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module topology.instances.ereal
! leanprover-community/mathlib commit bcfa726826abd57587355b4b5b7e78ad6527b7e4
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Rat.Encodable
import Mathbin.Data.Real.Ereal
import Mathbin.Topology.Algebra.Order.MonotoneContinuity
import Mathbin.Topology.Instances.Ennreal

/-!
# Topological structure on `ereal`

We endow `ereal` with the order topology, and prove basic properties of this topology.

## Main results

* `coe : ℝ → ereal` is an open embedding
* `coe : ℝ≥0∞ → ereal` is an embedding
* The addition on `ereal` is continuous except at `(⊥, ⊤)` and at `(⊤, ⊥)`.
* Negation is a homeomorphism on `ereal`.

## Implementation

Most proofs are adapted from the corresponding proofs on `ℝ≥0∞`.
-/


noncomputable section

open Classical Set Filter Metric TopologicalSpace

open Classical Topology Ennreal Nnreal BigOperators Filter

variable {α : Type _} [TopologicalSpace α]

namespace Ereal

instance : TopologicalSpace Ereal :=
  Preorder.topology Ereal

instance : OrderTopology Ereal :=
  ⟨rfl⟩

instance : T2Space Ereal := by infer_instance

instance : SecondCountableTopology Ereal :=
  ⟨by
    refine'
      ⟨⋃ q : ℚ, {{ a : Ereal | a < (q : ℝ) }, { a : Ereal | ((q : ℝ) : Ereal) < a }},
        countable_Union fun a => (countable_singleton _).insert _, _⟩
    refine'
      le_antisymm
        (le_generateFrom <| by
          simp (config := { contextual := true }) [or_imp, isOpen_lt', isOpen_gt'])
        _
    apply le_generateFrom fun s h => _
    rcases h with ⟨a, hs | hs⟩ <;>
        [rw [show s = ⋃ q ∈ { q : ℚ | a < (q : ℝ) }, { b | ((q : ℝ) : Ereal) < b }
            by
            ext x
            simpa only [hs, exists_prop, mem_Union] using lt_iff_exists_rat_btwn],
        rw [show s = ⋃ q ∈ { q : ℚ | ((q : ℝ) : Ereal) < a }, { b | b < ((q : ℝ) : Ereal) }
            by
            ext x
            simpa only [hs, and_comm', exists_prop, mem_Union] using lt_iff_exists_rat_btwn]] <;>
      · apply isOpen_unionᵢ
        intro q
        apply isOpen_unionᵢ
        intro hq
        apply generate_open.basic
        exact mem_Union.2 ⟨q, by simp⟩⟩

/-! ### Real coercion -/


theorem embedding_coe : Embedding (coe : ℝ → Ereal) :=
  ⟨⟨by
      refine' le_antisymm _ _
      · rw [@OrderTopology.topology_eq_generate_intervals Ereal _, ← coinduced_le_iff_le_induced]
        refine' le_generateFrom fun s ha => _
        rcases ha with ⟨a, rfl | rfl⟩
        show IsOpen { b : ℝ | a < ↑b }
        · induction a using Ereal.rec
          · simp only [isOpen_univ, bot_lt_coe, set_of_true]
          · simp only [Ereal.coe_lt_coe_iff]
            exact isOpen_ioi
          · simp only [set_of_false, isOpen_empty, not_top_lt]
        show IsOpen { b : ℝ | ↑b < a }
        · induction a using Ereal.rec
          · simp only [not_lt_bot, set_of_false, isOpen_empty]
          · simp only [Ereal.coe_lt_coe_iff]
            exact isOpen_iio
          · simp only [isOpen_univ, coe_lt_top, set_of_true]
      · rw [@OrderTopology.topology_eq_generate_intervals ℝ _]
        refine' le_generateFrom fun s ha => _
        rcases ha with ⟨a, rfl | rfl⟩
        exact ⟨Ioi a, isOpen_ioi, by simp [Ioi]⟩
        exact ⟨Iio a, isOpen_iio, by simp [Iio]⟩⟩, fun a b => by
    simp only [imp_self, Ereal.coe_eq_coe_iff]⟩
#align ereal.embedding_coe Ereal.embedding_coe

theorem openEmbedding_coe : OpenEmbedding (coe : ℝ → Ereal) :=
  ⟨embedding_coe, by
    convert @isOpen_ioo Ereal _ _ _ ⊥ ⊤
    ext x
    induction x using Ereal.rec
    · simp only [left_mem_Ioo, mem_range, coe_ne_bot, exists_false, not_false_iff]
    · simp only [mem_range_self, mem_Ioo, bot_lt_coe, coe_lt_top, and_self_iff]
    · simp only [mem_range, right_mem_Ioo, exists_false, coe_ne_top]⟩
#align ereal.open_embedding_coe Ereal.openEmbedding_coe

@[norm_cast]
theorem tendsto_coe {α : Type _} {f : Filter α} {m : α → ℝ} {a : ℝ} :
    Tendsto (fun a => (m a : Ereal)) f (𝓝 ↑a) ↔ Tendsto m f (𝓝 a) :=
  embedding_coe.tendsto_nhds_iff.symm
#align ereal.tendsto_coe Ereal.tendsto_coe

theorem continuous_coe_real_ereal : Continuous (coe : ℝ → Ereal) :=
  embedding_coe.Continuous
#align continuous_coe_real_ereal continuous_coe_real_ereal

theorem continuous_coe_iff {f : α → ℝ} : (Continuous fun a => (f a : Ereal)) ↔ Continuous f :=
  embedding_coe.continuous_iff.symm
#align ereal.continuous_coe_iff Ereal.continuous_coe_iff

theorem nhds_coe {r : ℝ} : 𝓝 (r : Ereal) = (𝓝 r).map coe :=
  (openEmbedding_coe.map_nhds_eq r).symm
#align ereal.nhds_coe Ereal.nhds_coe

theorem nhds_coe_coe {r p : ℝ} :
    𝓝 ((r : Ereal), (p : Ereal)) = (𝓝 (r, p)).map fun p : ℝ × ℝ => (p.1, p.2) :=
  ((openEmbedding_coe.Prod openEmbedding_coe).map_nhds_eq (r, p)).symm
#align ereal.nhds_coe_coe Ereal.nhds_coe_coe

theorem tendsto_toReal {a : Ereal} (ha : a ≠ ⊤) (h'a : a ≠ ⊥) :
    Tendsto Ereal.toReal (𝓝 a) (𝓝 a.toReal) :=
  by
  lift a to ℝ using And.intro ha h'a
  rw [nhds_coe, tendsto_map'_iff]
  exact tendsto_id
#align ereal.tendsto_to_real Ereal.tendsto_toReal

theorem continuousOn_toReal : ContinuousOn Ereal.toReal ({⊥, ⊤}ᶜ : Set Ereal) := fun a ha =>
  ContinuousAt.continuousWithinAt
    (tendsto_toReal
      (by
        simp [not_or] at ha
        exact ha.2)
      (by
        simp [not_or] at ha
        exact ha.1))
#align ereal.continuous_on_to_real Ereal.continuousOn_toReal

/-- The set of finite `ereal` numbers is homeomorphic to `ℝ`. -/
def neBotTopHomeomorphReal : ({⊥, ⊤}ᶜ : Set Ereal) ≃ₜ ℝ :=
  {
    neTopBotEquivReal with
    continuous_to_fun := continuousOn_iff_continuous_restrict.1 continuousOn_toReal
    continuous_inv_fun := continuous_coe_real_ereal.subtype_mk _ }
#align ereal.ne_bot_top_homeomorph_real Ereal.neBotTopHomeomorphReal

/-! ### ennreal coercion -/


theorem embedding_coe_ennreal : Embedding (coe : ℝ≥0∞ → Ereal) :=
  ⟨⟨by
      refine' le_antisymm _ _
      · rw [@OrderTopology.topology_eq_generate_intervals Ereal _, ← coinduced_le_iff_le_induced]
        refine' le_generateFrom fun s ha => _
        rcases ha with ⟨a, rfl | rfl⟩
        show IsOpen { b : ℝ≥0∞ | a < ↑b }
        · induction' a using Ereal.rec with x
          · simp only [isOpen_univ, bot_lt_coe_ennreal, set_of_true]
          · rcases le_or_lt 0 x with (h | h)
            · have : (x : Ereal) = ((id ⟨x, h⟩ : ℝ≥0) : ℝ≥0∞) := rfl
              rw [this]
              simp only [id.def, coe_ennreal_lt_coe_ennreal_iff]
              exact isOpen_ioi
            · have : ∀ y : ℝ≥0∞, (x : Ereal) < y := fun y =>
                (Ereal.coe_lt_coe_iff.2 h).trans_le (coe_ennreal_nonneg _)
              simp only [this, isOpen_univ, set_of_true]
          · simp only [set_of_false, isOpen_empty, not_top_lt]
        show IsOpen { b : ℝ≥0∞ | ↑b < a }
        · induction' a using Ereal.rec with x
          · simp only [not_lt_bot, set_of_false, isOpen_empty]
          · rcases le_or_lt 0 x with (h | h)
            · have : (x : Ereal) = ((id ⟨x, h⟩ : ℝ≥0) : ℝ≥0∞) := rfl
              rw [this]
              simp only [id.def, coe_ennreal_lt_coe_ennreal_iff]
              exact isOpen_iio
            · convert isOpen_empty
              apply eq_empty_iff_forall_not_mem.2 fun y hy => lt_irrefl (x : Ereal) _
              exact ((Ereal.coe_lt_coe_iff.2 h).trans_le (coe_ennreal_nonneg y)).trans hy
          · simp only [← coe_ennreal_top, coe_ennreal_lt_coe_ennreal_iff]
            exact isOpen_iio
      · rw [@OrderTopology.topology_eq_generate_intervals ℝ≥0∞ _]
        refine' le_generateFrom fun s ha => _
        rcases ha with ⟨a, rfl | rfl⟩
        exact ⟨Ioi a, isOpen_ioi, by simp [Ioi]⟩
        exact ⟨Iio a, isOpen_iio, by simp [Iio]⟩⟩, fun a b => by
    simp only [imp_self, coe_ennreal_eq_coe_ennreal_iff]⟩
#align ereal.embedding_coe_ennreal Ereal.embedding_coe_ennreal

@[norm_cast]
theorem tendsto_coe_ennreal {α : Type _} {f : Filter α} {m : α → ℝ≥0∞} {a : ℝ≥0∞} :
    Tendsto (fun a => (m a : Ereal)) f (𝓝 ↑a) ↔ Tendsto m f (𝓝 a) :=
  embedding_coe_ennreal.tendsto_nhds_iff.symm
#align ereal.tendsto_coe_ennreal Ereal.tendsto_coe_ennreal

theorem continuous_coe_ennreal_ereal : Continuous (coe : ℝ≥0∞ → Ereal) :=
  embedding_coe_ennreal.Continuous
#align continuous_coe_ennreal_ereal continuous_coe_ennreal_ereal

theorem continuous_coe_ennreal_iff {f : α → ℝ≥0∞} :
    (Continuous fun a => (f a : Ereal)) ↔ Continuous f :=
  embedding_coe_ennreal.continuous_iff.symm
#align ereal.continuous_coe_ennreal_iff Ereal.continuous_coe_ennreal_iff

/-! ### Neighborhoods of infinity -/


/- ./././Mathport/Syntax/Translate/Basic.lean:628:2: warning: expanding binder collection (a «expr ≠ » «expr⊤»()) -/
theorem nhds_top : 𝓝 (⊤ : Ereal) = ⨅ (a) (_ : a ≠ ⊤), 𝓟 (Ioi a) :=
  nhds_top_order.trans <| by simp [lt_top_iff_ne_top, Ioi]
#align ereal.nhds_top Ereal.nhds_top

theorem nhds_top' : 𝓝 (⊤ : Ereal) = ⨅ a : ℝ, 𝓟 (Ioi a) :=
  by
  rw [nhds_top]
  apply le_antisymm
  · exact infᵢ_mono' fun x => ⟨x, by simp⟩
  · refine' le_infᵢ fun r => le_infᵢ fun hr => _
    induction r using Ereal.rec
    · exact (infᵢ_le _ 0).trans (by simp)
    · exact infᵢ_le _ _
    · simpa using hr
#align ereal.nhds_top' Ereal.nhds_top'

theorem mem_nhds_top_iff {s : Set Ereal} : s ∈ 𝓝 (⊤ : Ereal) ↔ ∃ y : ℝ, Ioi (y : Ereal) ⊆ s :=
  by
  rw [nhds_top', mem_infi_of_directed]
  · rfl
  exact fun x y => ⟨max x y, by simp [le_refl], by simp [le_refl]⟩
#align ereal.mem_nhds_top_iff Ereal.mem_nhds_top_iff

theorem tendsto_nhds_top_iff_real {α : Type _} {m : α → Ereal} {f : Filter α} :
    Tendsto m f (𝓝 ⊤) ↔ ∀ x : ℝ, ∀ᶠ a in f, ↑x < m a := by
  simp only [nhds_top', mem_Ioi, tendsto_infi, tendsto_principal]
#align ereal.tendsto_nhds_top_iff_real Ereal.tendsto_nhds_top_iff_real

/- ./././Mathport/Syntax/Translate/Basic.lean:628:2: warning: expanding binder collection (a «expr ≠ » «expr⊥»()) -/
theorem nhds_bot : 𝓝 (⊥ : Ereal) = ⨅ (a) (_ : a ≠ ⊥), 𝓟 (Iio a) :=
  nhds_bot_order.trans <| by simp [bot_lt_iff_ne_bot]
#align ereal.nhds_bot Ereal.nhds_bot

theorem nhds_bot' : 𝓝 (⊥ : Ereal) = ⨅ a : ℝ, 𝓟 (Iio a) :=
  by
  rw [nhds_bot]
  apply le_antisymm
  · exact infᵢ_mono' fun x => ⟨x, by simp⟩
  · refine' le_infᵢ fun r => le_infᵢ fun hr => _
    induction r using Ereal.rec
    · simpa using hr
    · exact infᵢ_le _ _
    · exact (infᵢ_le _ 0).trans (by simp)
#align ereal.nhds_bot' Ereal.nhds_bot'

theorem mem_nhds_bot_iff {s : Set Ereal} : s ∈ 𝓝 (⊥ : Ereal) ↔ ∃ y : ℝ, Iio (y : Ereal) ⊆ s :=
  by
  rw [nhds_bot', mem_infi_of_directed]
  · rfl
  exact fun x y => ⟨min x y, by simp [le_refl], by simp [le_refl]⟩
#align ereal.mem_nhds_bot_iff Ereal.mem_nhds_bot_iff

theorem tendsto_nhds_bot_iff_real {α : Type _} {m : α → Ereal} {f : Filter α} :
    Tendsto m f (𝓝 ⊥) ↔ ∀ x : ℝ, ∀ᶠ a in f, m a < x := by
  simp only [nhds_bot', mem_Iio, tendsto_infi, tendsto_principal]
#align ereal.tendsto_nhds_bot_iff_real Ereal.tendsto_nhds_bot_iff_real

/-! ### Continuity of addition -/


theorem continuousAt_add_coe_coe (a b : ℝ) :
    ContinuousAt (fun p : Ereal × Ereal => p.1 + p.2) (a, b) := by
  simp only [ContinuousAt, nhds_coe_coe, ← coe_add, tendsto_map'_iff, (· ∘ ·), tendsto_coe,
    tendsto_add]
#align ereal.continuous_at_add_coe_coe Ereal.continuousAt_add_coe_coe

theorem continuousAt_add_top_coe (a : ℝ) :
    ContinuousAt (fun p : Ereal × Ereal => p.1 + p.2) (⊤, a) :=
  by
  simp only [ContinuousAt, tendsto_nhds_top_iff_real, top_add_coe, nhds_prod_eq]
  intro r
  rw [eventually_prod_iff]
  refine'
    ⟨fun z => ((r - (a - 1) : ℝ) : Ereal) < z, ioi_mem_nhds (coe_lt_top _), fun z =>
      ((a - 1 : ℝ) : Ereal) < z, ioi_mem_nhds (by simp [-Ereal.coe_sub]), fun x hx y hy => _⟩
  dsimp
  convert add_lt_add hx hy
  simp
#align ereal.continuous_at_add_top_coe Ereal.continuousAt_add_top_coe

theorem continuousAt_add_coe_top (a : ℝ) :
    ContinuousAt (fun p : Ereal × Ereal => p.1 + p.2) (a, ⊤) :=
  by
  change ContinuousAt ((fun p : Ereal × Ereal => p.2 + p.1) ∘ Prod.swap) (a, ⊤)
  apply ContinuousAt.comp _ continuous_swap.continuous_at
  simp_rw [add_comm]
  exact continuous_at_add_top_coe a
#align ereal.continuous_at_add_coe_top Ereal.continuousAt_add_coe_top

theorem continuousAt_add_top_top : ContinuousAt (fun p : Ereal × Ereal => p.1 + p.2) (⊤, ⊤) :=
  by
  simp only [ContinuousAt, tendsto_nhds_top_iff_real, top_add_top, nhds_prod_eq]
  intro r
  rw [eventually_prod_iff]
  refine'
    ⟨fun z => (r : Ereal) < z, ioi_mem_nhds (coe_lt_top _), fun z => ((0 : ℝ) : Ereal) < z,
      ioi_mem_nhds (by simp [zero_lt_one]), fun x hx y hy => _⟩
  dsimp
  convert add_lt_add hx hy
  simp
#align ereal.continuous_at_add_top_top Ereal.continuousAt_add_top_top

theorem continuousAt_add_bot_coe (a : ℝ) :
    ContinuousAt (fun p : Ereal × Ereal => p.1 + p.2) (⊥, a) :=
  by
  simp only [ContinuousAt, tendsto_nhds_bot_iff_real, nhds_prod_eq, bot_add]
  intro r
  rw [eventually_prod_iff]
  refine'
    ⟨fun z => z < ((r - (a + 1) : ℝ) : Ereal), iio_mem_nhds (bot_lt_coe _), fun z =>
      z < ((a + 1 : ℝ) : Ereal), iio_mem_nhds (by simp [-coe_add, zero_lt_one]), fun x hx y hy => _⟩
  convert add_lt_add hx hy
  rw [sub_add_cancel]
#align ereal.continuous_at_add_bot_coe Ereal.continuousAt_add_bot_coe

theorem continuousAt_add_coe_bot (a : ℝ) :
    ContinuousAt (fun p : Ereal × Ereal => p.1 + p.2) (a, ⊥) :=
  by
  change ContinuousAt ((fun p : Ereal × Ereal => p.2 + p.1) ∘ Prod.swap) (a, ⊥)
  apply ContinuousAt.comp _ continuous_swap.continuous_at
  simp_rw [add_comm]
  exact continuous_at_add_bot_coe a
#align ereal.continuous_at_add_coe_bot Ereal.continuousAt_add_coe_bot

theorem continuousAt_add_bot_bot : ContinuousAt (fun p : Ereal × Ereal => p.1 + p.2) (⊥, ⊥) :=
  by
  simp only [ContinuousAt, tendsto_nhds_bot_iff_real, nhds_prod_eq, bot_add]
  intro r
  rw [eventually_prod_iff]
  refine'
    ⟨fun z => z < r, iio_mem_nhds (bot_lt_coe _), fun z => z < 0, iio_mem_nhds (bot_lt_coe _),
      fun x hx y hy => _⟩
  dsimp
  convert add_lt_add hx hy
  simp
#align ereal.continuous_at_add_bot_bot Ereal.continuousAt_add_bot_bot

/-- The addition on `ereal` is continuous except where it doesn't make sense (i.e., at `(⊥, ⊤)`
and at `(⊤, ⊥)`). -/
theorem continuousAt_add {p : Ereal × Ereal} (h : p.1 ≠ ⊤ ∨ p.2 ≠ ⊥) (h' : p.1 ≠ ⊥ ∨ p.2 ≠ ⊤) :
    ContinuousAt (fun p : Ereal × Ereal => p.1 + p.2) p :=
  by
  rcases p with ⟨x, y⟩
  induction x using Ereal.rec <;> induction y using Ereal.rec
  · exact continuous_at_add_bot_bot
  · exact continuous_at_add_bot_coe _
  · simpa using h'
  · exact continuous_at_add_coe_bot _
  · exact continuous_at_add_coe_coe _ _
  · exact continuous_at_add_coe_top _
  · simpa using h
  · exact continuous_at_add_top_coe _
  · exact continuous_at_add_top_top
#align ereal.continuous_at_add Ereal.continuousAt_add

/-! ### Negation-/


/-- Negation on `ereal` as a homeomorphism -/
def negHomeo : Ereal ≃ₜ Ereal :=
  negOrderIso.toHomeomorph
#align ereal.neg_homeo Ereal.negHomeo

theorem continuous_neg : Continuous fun x : Ereal => -x :=
  negHomeo.Continuous
#align ereal.continuous_neg Ereal.continuous_neg

end Ereal

