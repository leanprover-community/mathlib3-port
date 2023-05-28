/-
Copyright (c) 2020 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module analysis.normed_space.enorm
! leanprover-community/mathlib commit 57ac39bd365c2f80589a700f9fbb664d3a1a30c2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.Basic

/-!
# Extended norm

In this file we define a structure `enorm 𝕜 V` representing an extended norm (i.e., a norm that can
take the value `∞`) on a vector space `V` over a normed field `𝕜`. We do not use `class` for
an `enorm` because the same space can have more than one extended norm. For example, the space of
measurable functions `f : α → ℝ` has a family of `L_p` extended norms.

We prove some basic inequalities, then define

* `emetric_space` structure on `V` corresponding to `e : enorm 𝕜 V`;
* the subspace of vectors with finite norm, called `e.finite_subspace`;
* a `normed_space` structure on this space.

The last definition is an instance because the type involves `e`.

## Implementation notes

We do not define extended normed groups. They can be added to the chain once someone will need them.

## Tags

normed space, extended norm
-/


noncomputable section

attribute [local instance 1001] Classical.propDecidable

open scoped ENNReal

/-- Extended norm on a vector space. As in the case of normed spaces, we require only
`‖c • x‖ ≤ ‖c‖ * ‖x‖` in the definition, then prove an equality in `map_smul`. -/
structure Enorm (𝕜 : Type _) (V : Type _) [NormedField 𝕜] [AddCommGroup V] [Module 𝕜 V] where
  toFun : V → ℝ≥0∞
  eq_zero' : ∀ x, to_fun x = 0 → x = 0
  map_add_le' : ∀ x y : V, to_fun (x + y) ≤ to_fun x + to_fun y
  map_smul_le' : ∀ (c : 𝕜) (x : V), to_fun (c • x) ≤ ‖c‖₊ * to_fun x
#align enorm Enorm

namespace Enorm

variable {𝕜 : Type _} {V : Type _} [NormedField 𝕜] [AddCommGroup V] [Module 𝕜 V] (e : Enorm 𝕜 V)

instance : CoeFun (Enorm 𝕜 V) fun _ => V → ℝ≥0∞ :=
  ⟨Enorm.toFun⟩

theorem coeFn_injective : Function.Injective (coeFn : Enorm 𝕜 V → V → ℝ≥0∞) := fun e₁ e₂ h => by
  cases e₁ <;> cases e₂ <;> congr <;> exact h
#align enorm.coe_fn_injective Enorm.coeFn_injective

@[ext]
theorem ext {e₁ e₂ : Enorm 𝕜 V} (h : ∀ x, e₁ x = e₂ x) : e₁ = e₂ :=
  coeFn_injective <| funext h
#align enorm.ext Enorm.ext

theorem ext_iff {e₁ e₂ : Enorm 𝕜 V} : e₁ = e₂ ↔ ∀ x, e₁ x = e₂ x :=
  ⟨fun h x => h ▸ rfl, ext⟩
#align enorm.ext_iff Enorm.ext_iff

@[simp, norm_cast]
theorem coe_inj {e₁ e₂ : Enorm 𝕜 V} : (e₁ : V → ℝ≥0∞) = e₂ ↔ e₁ = e₂ :=
  coeFn_injective.eq_iff
#align enorm.coe_inj Enorm.coe_inj

@[simp]
theorem map_smul (c : 𝕜) (x : V) : e (c • x) = ‖c‖₊ * e x :=
  le_antisymm (e.map_smul_le' c x) <| by
    by_cases hc : c = 0; · simp [hc]
    calc
      (‖c‖₊ : ℝ≥0∞) * e x = ‖c‖₊ * e (c⁻¹ • c • x) := by rw [inv_smul_smul₀ hc]
      _ ≤ ‖c‖₊ * (‖c⁻¹‖₊ * e (c • x)) := _
      _ = e (c • x) := _
      
    · exact mul_le_mul_left' (e.map_smul_le' _ _) _
    ·
      rw [← mul_assoc, nnnorm_inv, ENNReal.coe_inv, ENNReal.mul_inv_cancel _ ENNReal.coe_ne_top,
          one_mul] <;>
        simp [hc]
#align enorm.map_smul Enorm.map_smul

@[simp]
theorem map_zero : e 0 = 0 := by rw [← zero_smul 𝕜 (0 : V), e.map_smul]; norm_num
#align enorm.map_zero Enorm.map_zero

@[simp]
theorem eq_zero_iff {x : V} : e x = 0 ↔ x = 0 :=
  ⟨e.eq_zero' x, fun h => h.symm ▸ e.map_zero⟩
#align enorm.eq_zero_iff Enorm.eq_zero_iff

@[simp]
theorem map_neg (x : V) : e (-x) = e x :=
  calc
    e (-x) = ‖(-1 : 𝕜)‖₊ * e x := by rw [← map_smul, neg_one_smul]
    _ = e x := by simp
    
#align enorm.map_neg Enorm.map_neg

theorem map_sub_rev (x y : V) : e (x - y) = e (y - x) := by rw [← neg_sub, e.map_neg]
#align enorm.map_sub_rev Enorm.map_sub_rev

theorem map_add_le (x y : V) : e (x + y) ≤ e x + e y :=
  e.map_add_le' x y
#align enorm.map_add_le Enorm.map_add_le

theorem map_sub_le (x y : V) : e (x - y) ≤ e x + e y :=
  calc
    e (x - y) = e (x + -y) := by rw [sub_eq_add_neg]
    _ ≤ e x + e (-y) := (e.map_add_le x (-y))
    _ = e x + e y := by rw [e.map_neg]
    
#align enorm.map_sub_le Enorm.map_sub_le

instance : PartialOrder (Enorm 𝕜 V)
    where
  le e₁ e₂ := ∀ x, e₁ x ≤ e₂ x
  le_refl e x := le_rfl
  le_trans e₁ e₂ e₃ h₁₂ h₂₃ x := le_trans (h₁₂ x) (h₂₃ x)
  le_antisymm e₁ e₂ h₁₂ h₂₁ := ext fun x => le_antisymm (h₁₂ x) (h₂₁ x)

/-- The `enorm` sending each non-zero vector to infinity. -/
noncomputable instance : Top (Enorm 𝕜 V) :=
  ⟨{  toFun := fun x => if x = 0 then 0 else ⊤
      eq_zero' := fun x => by split_ifs <;> simp [*]
      map_add_le' := fun x y =>
        by
        split_ifs with hxy hx hy hy hx hy hy <;> try simp [*]
        simpa [hx, hy] using hxy
      map_smul_le' := fun c x =>
        by
        split_ifs with hcx hx hx <;> simp only [smul_eq_zero, not_or] at hcx
        · simp only [MulZeroClass.mul_zero, le_refl]
        · have : c = 0 := by tauto
          simp [this]
        · tauto
        · simp [hcx.1] }⟩

noncomputable instance : Inhabited (Enorm 𝕜 V) :=
  ⟨⊤⟩

theorem top_map {x : V} (hx : x ≠ 0) : (⊤ : Enorm 𝕜 V) x = ⊤ :=
  if_neg hx
#align enorm.top_map Enorm.top_map

noncomputable instance : OrderTop (Enorm 𝕜 V)
    where
  top := ⊤
  le_top e x := if h : x = 0 then by simp [h] else by simp [top_map h]

noncomputable instance : SemilatticeSup (Enorm 𝕜 V) :=
  { Enorm.partialOrder with
    le := (· ≤ ·)
    lt := (· < ·)
    sup := fun e₁ e₂ =>
      { toFun := fun x => max (e₁ x) (e₂ x)
        eq_zero' := fun x h => e₁.eq_zero_iff.1 (ENNReal.max_eq_zero_iff.1 h).1
        map_add_le' := fun x y =>
          max_le (le_trans (e₁.map_add_le _ _) <| add_le_add (le_max_left _ _) (le_max_left _ _))
            (le_trans (e₂.map_add_le _ _) <| add_le_add (le_max_right _ _) (le_max_right _ _))
        map_smul_le' := fun c x => le_of_eq <| by simp only [map_smul, ENNReal.mul_max] }
    le_sup_left := fun e₁ e₂ x => le_max_left _ _
    le_sup_right := fun e₁ e₂ x => le_max_right _ _
    sup_le := fun e₁ e₂ e₃ h₁ h₂ x => max_le (h₁ x) (h₂ x) }

@[simp, norm_cast]
theorem coe_max (e₁ e₂ : Enorm 𝕜 V) : ⇑(e₁ ⊔ e₂) = fun x => max (e₁ x) (e₂ x) :=
  rfl
#align enorm.coe_max Enorm.coe_max

@[norm_cast]
theorem max_map (e₁ e₂ : Enorm 𝕜 V) (x : V) : (e₁ ⊔ e₂) x = max (e₁ x) (e₂ x) :=
  rfl
#align enorm.max_map Enorm.max_map

/-- Structure of an `emetric_space` defined by an extended norm. -/
@[reducible]
def emetricSpace : EMetricSpace V where
  edist x y := e (x - y)
  edist_self x := by simp
  eq_of_edist_eq_zero x y := by simp [sub_eq_zero]
  edist_comm := e.map_sub_rev
  edist_triangle x y z :=
    calc
      e (x - z) = e (x - y + (y - z)) := by rw [sub_add_sub_cancel]
      _ ≤ e (x - y) + e (y - z) := e.map_add_le (x - y) (y - z)
      
#align enorm.emetric_space Enorm.emetricSpace

/-- The subspace of vectors with finite enorm. -/
def finiteSubspace : Subspace 𝕜 V
    where
  carrier := { x | e x < ⊤ }
  zero_mem' := by simp
  add_mem' x y hx hy := lt_of_le_of_lt (e.map_add_le x y) (ENNReal.add_lt_top.2 ⟨hx, hy⟩)
  smul_mem' c x (hx : _ < _) :=
    calc
      e (c • x) = ‖c‖₊ * e x := e.map_smul c x
      _ < ⊤ := ENNReal.mul_lt_top ENNReal.coe_ne_top hx.Ne
      
#align enorm.finite_subspace Enorm.finiteSubspace

/-- Metric space structure on `e.finite_subspace`. We use `emetric_space.to_metric_space`
to ensure that this definition agrees with `e.emetric_space`. -/
instance : MetricSpace e.finiteSubspace :=
  by
  letI := e.emetric_space
  refine' EMetricSpace.toMetricSpace fun x y => _
  change e (x - y) ≠ ⊤
  exact ne_top_of_le_ne_top (ENNReal.add_lt_top.2 ⟨x.2, y.2⟩).Ne (e.map_sub_le x y)

theorem finite_dist_eq (x y : e.finiteSubspace) : dist x y = (e (x - y)).toReal :=
  rfl
#align enorm.finite_dist_eq Enorm.finite_dist_eq

theorem finite_edist_eq (x y : e.finiteSubspace) : edist x y = e (x - y) :=
  rfl
#align enorm.finite_edist_eq Enorm.finite_edist_eq

/-- Normed group instance on `e.finite_subspace`. -/
instance : NormedAddCommGroup e.finiteSubspace :=
  { finiteSubspace.metricSpace e,
    Submodule.addCommGroup _ with
    norm := fun x => (e x).toReal
    dist_eq := fun x y => rfl }

theorem finite_norm_eq (x : e.finiteSubspace) : ‖x‖ = (e x).toReal :=
  rfl
#align enorm.finite_norm_eq Enorm.finite_norm_eq

/-- Normed space instance on `e.finite_subspace`. -/
instance : NormedSpace 𝕜 e.finiteSubspace
    where norm_smul_le c x := le_of_eq <| by simp [finite_norm_eq, ENNReal.toReal_mul]

end Enorm

