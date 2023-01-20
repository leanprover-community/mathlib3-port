/-
Copyright (c) 2021 Patrick Massot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot

! This file was ported from Lean 3 source module topology.algebra.valued_field
! leanprover-community/mathlib commit 1126441d6bccf98c81214a0780c73d499f6721fe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Algebra.Valuation
import Mathbin.Topology.Algebra.WithZeroTopology
import Mathbin.Topology.Algebra.UniformField

/-!
# Valued fields and their completions

In this file we study the topology of a field `K` endowed with a valuation (in our application
to adic spaces, `K` will be the valuation field associated to some valuation on a ring, defined in
valuation.basic).

We already know from valuation.topology that one can build a topology on `K` which
makes it a topological ring.

The first goal is to show `K` is a topological *field*, ie inversion is continuous
at every non-zero element.

The next goal is to prove `K` is a *completable* topological field. This gives us
a completion `hat K` which is a topological field. We also prove that `K` is automatically
separated, so the map from `K` to `hat K` is injective.

Then we extend the valuation given on `K` to a valuation on `hat K`.
-/


open Filter Set

open TopologicalSpace

section DivisionRing

variable {K : Type _} [DivisionRing K] {Γ₀ : Type _} [LinearOrderedCommGroupWithZero Γ₀]

section ValuationTopologicalDivisionRing

section InversionEstimate

variable (v : Valuation K Γ₀)

-- The following is the main technical lemma ensuring that inversion is continuous
-- in the topology induced by a valuation on a division ring (ie the next instance)
-- and the fact that a valued field is completable
-- [BouAC, VI.5.1 Lemme 1]
theorem Valuation.inversion_estimate {x y : K} {γ : Γ₀ˣ} (y_ne : y ≠ 0)
    (h : v (x - y) < min (γ * (v y * v y)) (v y)) : v (x⁻¹ - y⁻¹) < γ :=
  by
  have hyp1 : v (x - y) < γ * (v y * v y) := lt_of_lt_of_le h (min_le_left _ _)
  have hyp1' : v (x - y) * (v y * v y)⁻¹ < γ := mul_inv_lt_of_lt_mul₀ hyp1
  have hyp2 : v (x - y) < v y := lt_of_lt_of_le h (min_le_right _ _)
  have key : v x = v y := Valuation.map_eq_of_sub_lt v hyp2
  have x_ne : x ≠ 0 := by
    intro h
    apply y_ne
    rw [h, v.map_zero] at key
    exact v.zero_iff.1 key.symm
  have decomp : x⁻¹ - y⁻¹ = x⁻¹ * (y - x) * y⁻¹ := by
    rw [mul_sub_left_distrib, sub_mul, mul_assoc, show y * y⁻¹ = 1 from mul_inv_cancel y_ne,
      show x⁻¹ * x = 1 from inv_mul_cancel x_ne, mul_one, one_mul]
  calc
    v (x⁻¹ - y⁻¹) = v (x⁻¹ * (y - x) * y⁻¹) := by rw [decomp]
    _ = v x⁻¹ * (v <| y - x) * v y⁻¹ := by repeat' rw [Valuation.map_mul]
    _ = (v x)⁻¹ * (v <| y - x) * (v y)⁻¹ := by rw [map_inv₀, map_inv₀]
    _ = (v <| y - x) * (v y * v y)⁻¹ := by rw [mul_assoc, mul_comm, key, mul_assoc, mul_inv_rev]
    _ = (v <| y - x) * (v y * v y)⁻¹ := rfl
    _ = (v <| x - y) * (v y * v y)⁻¹ := by rw [Valuation.map_sub_swap]
    _ < γ := hyp1'
    
#align valuation.inversion_estimate Valuation.inversion_estimate

end InversionEstimate

open Valued

/-- The topology coming from a valuation on a division ring makes it a topological division ring
    [BouAC, VI.5.1 middle of Proposition 1] -/
instance (priority := 100) Valued.topologicalDivisionRing [Valued K Γ₀] :
    TopologicalDivisionRing K :=
  { (by infer_instance : TopologicalRing K) with
    continuous_at_inv₀ := by
      intro x x_ne s s_in
      cases' valued.mem_nhds.mp s_in with γ hs; clear s_in
      rw [mem_map, Valued.mem_nhds]
      change ∃ γ : Γ₀ˣ, { y : K | (v (y - x) : Γ₀) < γ } ⊆ { x : K | x⁻¹ ∈ s }
      have vx_ne := (Valuation.ne_zero_iff <| v).mpr x_ne
      let γ' := Units.mk0 _ vx_ne
      use min (γ * (γ' * γ')) γ'
      intro y y_in
      apply hs
      simp only [mem_set_of_eq] at y_in
      rw [Units.min_val, Units.val_mul, Units.val_mul] at y_in
      exact Valuation.inversion_estimate _ x_ne y_in }
#align valued.topological_division_ring Valued.topologicalDivisionRing

/-- A valued division ring is separated. -/
instance (priority := 100) ValuedRing.separated [Valued K Γ₀] : SeparatedSpace K :=
  by
  rw [separated_iff_t2]
  apply TopologicalAddGroup.t2_space_of_zero_sep
  intro x x_ne
  refine' ⟨{ k | v k < v x }, _, fun h => lt_irrefl _ h⟩
  rw [Valued.mem_nhds]
  have vx_ne := (Valuation.ne_zero_iff <| v).mpr x_ne
  let γ' := Units.mk0 _ vx_ne
  exact ⟨γ', fun y hy => by simpa using hy⟩
#align valued_ring.separated ValuedRing.separated

section

attribute [local instance] LinearOrderedCommGroupWithZero.topologicalSpace

open Valued

theorem Valued.continuous_valuation [Valued K Γ₀] : Continuous (v : K → Γ₀) :=
  by
  rw [continuous_iff_continuousAt]
  intro x
  rcases eq_or_ne x 0 with (rfl | h)
  · rw [ContinuousAt, map_zero, LinearOrderedCommGroupWithZero.tendsto_zero]
    intro γ hγ
    rw [Filter.Eventually, Valued.mem_nhds_zero]
    use Units.mk0 γ hγ, subset.rfl
  · have v_ne : (v x : Γ₀) ≠ 0 := (Valuation.ne_zero_iff _).mpr h
    rw [ContinuousAt, LinearOrderedCommGroupWithZero.tendsto_of_ne_zero v_ne]
    apply Valued.loc_const v_ne
#align valued.continuous_valuation Valued.continuous_valuation

end

end ValuationTopologicalDivisionRing

end DivisionRing

namespace Valued

open UniformSpace

variable {K : Type _} [Field K] {Γ₀ : Type _} [LinearOrderedCommGroupWithZero Γ₀] [hv : Valued K Γ₀]

include hv

-- mathport name: exprhat
local notation "hat " => Completion

/-- A valued field is completable. -/
instance (priority := 100) completable : CompletableTopField K :=
  { ValuedRing.separated with
    nice := by
      rintro F hF h0
      have : ∃ γ₀ : Γ₀ˣ, ∃ M ∈ F, ∀ x ∈ M, (γ₀ : Γ₀) ≤ v x :=
        by
        rcases filter.inf_eq_bot_iff.mp h0 with ⟨U, U_in, M, M_in, H⟩
        rcases valued.mem_nhds_zero.mp U_in with ⟨γ₀, hU⟩
        exists γ₀, M, M_in
        intro x xM
        apply le_of_not_lt _
        intro hyp
        have : x ∈ U ∩ M := ⟨hU hyp, xM⟩
        rwa [H] at this
      rcases this with ⟨γ₀, M₀, M₀_in, H₀⟩
      rw [Valued.cauchy_iff] at hF⊢
      refine' ⟨hF.1.map _, _⟩
      replace hF := hF.2
      intro γ
      rcases hF (min (γ * γ₀ * γ₀) γ₀) with ⟨M₁, M₁_in, H₁⟩
      clear hF
      use (fun x : K => x⁻¹) '' (M₀ ∩ M₁)
      constructor
      · rw [mem_map]
        apply mem_of_superset (Filter.inter_mem M₀_in M₁_in)
        exact subset_preimage_image _ _
      · rintro _ ⟨x, ⟨x_in₀, x_in₁⟩, rfl⟩ _ ⟨y, ⟨y_in₀, y_in₁⟩, rfl⟩
        simp only [mem_set_of_eq]
        specialize H₁ x x_in₁ y y_in₁
        replace x_in₀ := H₀ x x_in₀
        replace y_in₀ := H₀ y y_in₀
        clear H₀
        apply Valuation.inversion_estimate
        · have : (v x : Γ₀) ≠ 0 := by
            intro h
            rw [h] at x_in₀
            simpa using x_in₀
          exact (Valuation.ne_zero_iff _).mp this
        · refine' lt_of_lt_of_le H₁ _
          rw [Units.min_val]
          apply min_le_min _ x_in₀
          rw [mul_assoc]
          have : ((γ₀ * γ₀ : Γ₀ˣ) : Γ₀) ≤ v x * v x :=
            calc
              ↑γ₀ * ↑γ₀ ≤ ↑γ₀ * v x := mul_le_mul_left' x_in₀ ↑γ₀
              _ ≤ _ := mul_le_mul_right' x_in₀ (v x)
              
          rw [Units.val_mul]
          exact mul_le_mul_left' this γ }
#align valued.completable Valued.completable

attribute [local instance] LinearOrderedCommGroupWithZero.topologicalSpace

/-- The extension of the valuation of a valued field to the completion of the field. -/
noncomputable def extension : hat K → Γ₀ :=
  Completion.denseInducing_coe.extend (v : K → Γ₀)
#align valued.extension Valued.extension

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (x y «expr ∈ » V') -/
theorem continuous_extension : Continuous (Valued.extension : hat K → Γ₀) :=
  by
  refine' completion.dense_inducing_coe.continuous_extend _
  intro x₀
  rcases eq_or_ne x₀ 0 with (rfl | h)
  · refine' ⟨0, _⟩
    erw [← completion.dense_inducing_coe.to_inducing.nhds_eq_comap]
    exact valued.continuous_valuation.tendsto' 0 0 (map_zero v)
  · have preimage_one : v ⁻¹' {(1 : Γ₀)} ∈ 𝓝 (1 : K) :=
      by
      have : (v (1 : K) : Γ₀) ≠ 0 := by
        rw [Valuation.map_one]
        exact zero_ne_one.symm
      convert Valued.loc_const this
      ext x
      rw [Valuation.map_one, mem_preimage, mem_singleton_iff, mem_set_of_eq]
    obtain ⟨V, V_in, hV⟩ : ∃ V ∈ 𝓝 (1 : hat K), ∀ x : K, (x : hat K) ∈ V → (v x : Γ₀) = 1 := by
      rwa [completion.dense_inducing_coe.nhds_eq_comap, mem_comap] at preimage_one
    have :
      ∃ V' ∈ 𝓝 (1 : hat K), (0 : hat K) ∉ V' ∧ ∀ (x) (_ : x ∈ V') (y) (_ : y ∈ V'), x * y⁻¹ ∈ V :=
      by
      have : tendsto (fun p : hat K × hat K => p.1 * p.2⁻¹) ((𝓝 1).Prod (𝓝 1)) (𝓝 1) :=
        by
        rw [← nhds_prod_eq]
        conv =>
          congr
          skip
          skip
          rw [← one_mul (1 : hat K)]
        refine'
          tendsto.mul continuous_fst.continuous_at (tendsto.comp _ continuous_snd.continuous_at)
        convert continuous_at_inv₀ (zero_ne_one.symm : 1 ≠ (0 : hat K))
        exact inv_one.symm
      rcases tendsto_prod_self_iff.mp this V V_in with ⟨U, U_in, hU⟩
      let hatKstar := ({0}ᶜ : Set <| hat K)
      have : hatKstar ∈ 𝓝 (1 : hat K) := compl_singleton_mem_nhds zero_ne_one.symm
      use U ∩ hatKstar, Filter.inter_mem U_in this
      constructor
      · rintro ⟨h, h'⟩
        rw [mem_compl_singleton_iff] at h'
        exact h' rfl
      · rintro x ⟨hx, _⟩ y ⟨hy, _⟩
        apply hU <;> assumption
    rcases this with ⟨V', V'_in, zeroV', hV'⟩
    have nhds_right : (fun x => x * x₀) '' V' ∈ 𝓝 x₀ :=
      by
      have l : Function.LeftInverse (fun x : hat K => x * x₀⁻¹) fun x : hat K => x * x₀ :=
        by
        intro x
        simp only [mul_assoc, mul_inv_cancel h, mul_one]
      have r : Function.RightInverse (fun x : hat K => x * x₀⁻¹) fun x : hat K => x * x₀ :=
        by
        intro x
        simp only [mul_assoc, inv_mul_cancel h, mul_one]
      have c : Continuous fun x : hat K => x * x₀⁻¹ := continuous_id.mul continuous_const
      rw [image_eq_preimage_of_inverse l r]
      rw [← mul_inv_cancel h] at V'_in
      exact c.continuous_at V'_in
    have : ∃ z₀ : K, ∃ y₀ ∈ V', coe z₀ = y₀ * x₀ ∧ z₀ ≠ 0 :=
      by
      rcases completion.dense_range_coe.mem_nhds nhds_right with ⟨z₀, y₀, y₀_in, H : y₀ * x₀ = z₀⟩
      refine' ⟨z₀, y₀, y₀_in, ⟨H.symm, _⟩⟩
      rintro rfl
      exact mul_ne_zero (ne_of_mem_of_not_mem y₀_in zeroV') h H
    rcases this with ⟨z₀, y₀, y₀_in, hz₀, z₀_ne⟩
    have vz₀_ne : (v z₀ : Γ₀) ≠ 0 := by rwa [Valuation.ne_zero_iff]
    refine' ⟨v z₀, _⟩
    rw [LinearOrderedCommGroupWithZero.tendsto_of_ne_zero vz₀_ne, eventually_comap]
    filter_upwards [nhds_right] with x x_in a ha
    rcases x_in with ⟨y, y_in, rfl⟩
    have : (v (a * z₀⁻¹) : Γ₀) = 1 := by
      apply hV
      have : ((z₀⁻¹ : K) : hat K) = z₀⁻¹ := map_inv₀ (completion.coe_ring_hom : K →+* hat K) z₀
      rw [completion.coe_mul, this, ha, hz₀, mul_inv, mul_comm y₀⁻¹, ← mul_assoc, mul_assoc y,
        mul_inv_cancel h, mul_one]
      solve_by_elim
    calc
      v a = v (a * z₀⁻¹ * z₀) := by rw [mul_assoc, inv_mul_cancel z₀_ne, mul_one]
      _ = v (a * z₀⁻¹) * v z₀ := Valuation.map_mul _ _ _
      _ = v z₀ := by rw [this, one_mul]
      
#align valued.continuous_extension Valued.continuous_extension

@[simp, norm_cast]
theorem extension_extends (x : K) : extension (x : hat K) = v x :=
  by
  refine' completion.dense_inducing_coe.extend_eq_of_tendsto _
  rw [← completion.dense_inducing_coe.nhds_eq_comap]
  exact valued.continuous_valuation.continuous_at
#align valued.extension_extends Valued.extension_extends

/-- the extension of a valuation on a division ring to its completion. -/
noncomputable def extensionValuation : Valuation (hat K) Γ₀
    where
  toFun := Valued.extension
  map_zero' := by
    rw [← v.map_zero, ← Valued.extension_extends (0 : K)]
    rfl
  map_one' := by
    rw [← completion.coe_one, Valued.extension_extends (1 : K)]
    exact Valuation.map_one _
  map_mul' x y := by
    apply completion.induction_on₂ x y
    · have c1 : Continuous fun x : hat K × hat K => Valued.extension (x.1 * x.2) :=
        valued.continuous_extension.comp (continuous_fst.mul continuous_snd)
      have c2 : Continuous fun x : hat K × hat K => Valued.extension x.1 * Valued.extension x.2 :=
        (valued.continuous_extension.comp continuous_fst).mul
          (valued.continuous_extension.comp continuous_snd)
      exact isClosed_eq c1 c2
    · intro x y
      norm_cast
      exact Valuation.map_mul _ _ _
  map_add_le_max' x y := by
    rw [le_max_iff]
    apply completion.induction_on₂ x y
    · have cont : Continuous (Valued.extension : hat K → Γ₀) := Valued.continuous_extension
      exact
        (isClosed_le (cont.comp continuous_add) <| cont.comp continuous_fst).union
          (isClosed_le (cont.comp continuous_add) <| cont.comp continuous_snd)
    · intro x y
      dsimp
      norm_cast
      rw [← le_max_iff]
      exact v.map_add x y
#align valued.extension_valuation Valued.extensionValuation

-- Bourbaki CA VI §5 no.3 Proposition 5 (d)
theorem closure_coe_completion_v_lt {γ : Γ₀ˣ} :
    closure (coe '' { x : K | v x < (γ : Γ₀) }) = { x : hat K | extensionValuation x < (γ : Γ₀) } :=
  by
  ext x
  let γ₀ := extension_valuation x
  suffices γ₀ ≠ 0 → (x ∈ closure (coe '' { x : K | v x < (γ : Γ₀) }) ↔ γ₀ < (γ : Γ₀))
    by
    cases eq_or_ne γ₀ 0
    · simp only [h, (Valuation.zero_iff _).mp h, mem_set_of_eq, Valuation.map_zero, Units.zero_lt,
        iff_true_iff]
      apply subset_closure
      exact ⟨0, by simpa only [mem_set_of_eq, Valuation.map_zero, Units.zero_lt, true_and_iff] ⟩
    · exact this h
  intro h
  have hγ₀ : extension ⁻¹' {γ₀} ∈ 𝓝 x :=
    continuous_extension.continuous_at.preimage_mem_nhds
      (LinearOrderedCommGroupWithZero.singleton_mem_nhds_of_ne_zero h)
  rw [mem_closure_iff_nhds']
  refine' ⟨fun hx => _, fun hx s hs => _⟩
  · obtain ⟨⟨-, y, hy₁ : v y < (γ : Γ₀), rfl⟩, hy₂⟩ := hx _ hγ₀
    replace hy₂ : v y = γ₀
    · simpa using hy₂
    rwa [← hy₂]
  · obtain ⟨y, hy₁, hy₂ : ↑y ∈ s⟩ := completion.dense_range_coe.mem_nhds (inter_mem hγ₀ hs)
    replace hy₁ : v y = γ₀
    · simpa using hy₁
    rw [← hy₁] at hx
    exact ⟨⟨y, ⟨y, hx, rfl⟩⟩, hy₂⟩
#align valued.closure_coe_completion_v_lt Valued.closure_coe_completion_v_lt

noncomputable instance valuedCompletion : Valued (hat K) Γ₀
    where
  V := extensionValuation
  is_topological_valuation s :=
    by
    suffices
      has_basis (𝓝 (0 : hat K)) (fun _ => True) fun γ : Γ₀ˣ => { x | extension_valuation x < γ }
      by
      rw [this.mem_iff]
      exact exists_congr fun γ => by simp
    simp_rw [← closure_coe_completion_v_lt]
    exact (has_basis_nhds_zero K Γ₀).has_basis_of_dense_inducing completion.dense_inducing_coe
#align valued.valued_completion Valued.valuedCompletion

end Valued

