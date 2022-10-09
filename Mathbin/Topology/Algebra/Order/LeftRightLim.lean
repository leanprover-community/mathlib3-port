/-
Copyright (c) 2022 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel
-/
import Mathbin.Topology.Algebra.Order.Basic
import Mathbin.Topology.Algebra.Order.LeftRight

/-!
# Left and right limits

We define the (strict) left and right limits of a function.

* `left_lim f x` is the strict left limit of `f` at `x` (using `f x` as a garbage value if `x`
  is isolated to its left).
* `right_lim f x` is the strict right limit of `f` at `x` (using `f x` as a garbage value if `x`
  is isolated to its right).

We develop a comprehensive API for monotone functions. Notably,

* `monotone.continuous_at_iff_left_lim_eq_right_lim` states that a monotone function is continuous
  at a point if and only if its left and right limits coincide.
* `monotone.countable_not_continuous_at` asserts that a monotone function taking values in a
  second-countable space has at most countably many discontinuity points.

We also port the API to antitone functions.

## TODO

Prove corresponding stronger results for strict_mono and strict_anti functions.
-/


open Set Filter

open TopologicalSpace

section

variable {α β : Type _} [LinearOrderₓ α] [TopologicalSpace β]

/-- Let `f : α → β` be a function from a linear order `α` to a topological_space `β`, and
let `a : α`. The limit strictly to the left of `f` at `a`, denoted with `left_lim f a`, is defined
by using the order topology on `α`. If `a` is isolated to its left or the function has no left
limit, we use `f a` instead to guarantee a good behavior in most cases. -/
noncomputable irreducible_def Function.leftLim (f : α → β) (a : α) : β := by
  classical
  haveI : Nonempty β := ⟨f a⟩
  letI : TopologicalSpace α := Preorderₓ.topology α
  exact if 𝓝[<] a = ⊥ ∨ ¬∃ y, tendsto f (𝓝[<] a) (𝓝 y) then f a else limₓ (𝓝[<] a) f

/-- Let `f : α → β` be a function from a linear order `α` to a topological_space `β`, and
let `a : α`. The limit strictly to the right of `f` at `a`, denoted with `right_lim f a`, is defined
by using the order topology on `α`. If `a` is isolated to its right or the function has no right
limit, , we use `f a` instead to guarantee a good behavior in most cases. -/
noncomputable def Function.rightLim (f : α → β) (a : α) : β :=
  @Function.leftLim αᵒᵈ β _ _ f a

open Function

theorem left_lim_eq_of_tendsto [hα : TopologicalSpace α] [h'α : OrderTopology α] [T2Space β] {f : α → β} {a : α} {y : β}
    (h : 𝓝[<] a ≠ ⊥) (h' : Tendsto f (𝓝[<] a) (𝓝 y)) : leftLim f a = y := by
  have h'' : ∃ y, tendsto f (𝓝[<] a) (𝓝 y) := ⟨y, h'⟩
  rw [h'α.topology_eq_generate_intervals] at h h' h''
  simp only [left_lim, h, h'', not_true, or_selfₓ, if_false]
  haveI := ne_bot_iff.2 h
  exact h'.lim_eq

theorem left_lim_eq_of_eq_bot [hα : TopologicalSpace α] [h'α : OrderTopology α] (f : α → β) {a : α} (h : 𝓝[<] a = ⊥) :
    leftLim f a = f a := by
  rw [h'α.topology_eq_generate_intervals] at h
  simp [left_lim, ite_eq_left_iff, h]

end

open Function

namespace Monotoneₓ

variable {α β : Type _} [LinearOrderₓ α] [ConditionallyCompleteLinearOrder β] [TopologicalSpace β] [OrderTopology β]
  {f : α → β} (hf : Monotoneₓ f) {x y : α}

include hf

theorem left_lim_eq_Sup [TopologicalSpace α] [OrderTopology α] (h : 𝓝[<] x ≠ ⊥) : leftLim f x = sup (f '' Iio x) :=
  left_lim_eq_of_tendsto h (hf.tendsto_nhds_within_Iio x)

theorem left_lim_le (h : x ≤ y) : leftLim f x ≤ f y := by
  letI : TopologicalSpace α := Preorderₓ.topology α
  haveI : OrderTopology α := ⟨rfl⟩
  rcases eq_or_ne (𝓝[<] x) ⊥ with (h' | h')
  · simpa [left_lim, h'] using hf h
    
  haveI A : ne_bot (𝓝[<] x) := ne_bot_iff.2 h'
  rw [left_lim_eq_Sup hf h']
  refine' cSup_le _ _
  · simp only [nonempty_image_iff]
    exact (forall_mem_nonempty_iff_ne_bot.2 A) _ self_mem_nhds_within
    
  · simp only [mem_image, mem_Iio, forall_exists_index, and_imp, forall_apply_eq_imp_iff₂]
    intro z hz
    exact hf (hz.le.trans h)
    

theorem le_left_lim (h : x < y) : f x ≤ leftLim f y := by
  letI : TopologicalSpace α := Preorderₓ.topology α
  haveI : OrderTopology α := ⟨rfl⟩
  rcases eq_or_ne (𝓝[<] y) ⊥ with (h' | h')
  · rw [left_lim_eq_of_eq_bot _ h']
    exact hf h.le
    
  rw [left_lim_eq_Sup hf h']
  refine' le_cSup ⟨f y, _⟩ (mem_image_of_mem _ h)
  simp only [UpperBounds, mem_image, mem_Iio, forall_exists_index, and_imp, forall_apply_eq_imp_iff₂, mem_set_of_eq]
  intro z hz
  exact hf hz.le

@[mono]
protected theorem left_lim : Monotoneₓ (leftLim f) := by
  intro x y h
  rcases eq_or_lt_of_leₓ h with (rfl | hxy)
  · exact le_rflₓ
    
  · exact (hf.left_lim_le le_rflₓ).trans (hf.le_left_lim hxy)
    

theorem le_right_lim (h : x ≤ y) : f x ≤ rightLim f y :=
  hf.dual.left_lim_le h

theorem right_lim_le (h : x < y) : rightLim f x ≤ f y :=
  hf.dual.le_left_lim h

@[mono]
protected theorem right_lim : Monotoneₓ (rightLim f) := fun x y h => hf.dual.leftLim h

theorem left_lim_le_right_lim (h : x ≤ y) : leftLim f x ≤ rightLim f y :=
  (hf.left_lim_le le_rflₓ).trans (hf.le_right_lim h)

theorem right_lim_le_left_lim (h : x < y) : rightLim f x ≤ leftLim f y := by
  letI : TopologicalSpace α := Preorderₓ.topology α
  haveI : OrderTopology α := ⟨rfl⟩
  rcases eq_or_ne (𝓝[<] y) ⊥ with (h' | h')
  · simp [left_lim, h']
    exact right_lim_le hf h
    
  obtain ⟨a, ⟨xa, ay⟩⟩ : (Ioo x y).Nonempty :=
    forall_mem_nonempty_iff_ne_bot.2 (ne_bot_iff.2 h') (Ioo x y) (Ioo_mem_nhds_within_Iio ⟨h, le_reflₓ _⟩)
  calc
    right_lim f x ≤ f a := hf.right_lim_le xa
    _ ≤ left_lim f y := hf.le_left_lim ay
    

variable [TopologicalSpace α] [OrderTopology α]

theorem tendsto_left_lim (x : α) : Tendsto f (𝓝[<] x) (𝓝 (leftLim f x)) := by
  rcases eq_or_ne (𝓝[<] x) ⊥ with (h' | h')
  · simp [h']
    
  rw [left_lim_eq_Sup hf h']
  exact hf.tendsto_nhds_within_Iio x

theorem tendsto_left_lim_within (x : α) : Tendsto f (𝓝[<] x) (𝓝[≤] leftLim f x) := by
  apply tendsto_nhds_within_of_tendsto_nhds_of_eventually_within f (hf.tendsto_left_lim x)
  filter_upwards [self_mem_nhds_within] with y hy using hf.le_left_lim hy

theorem tendsto_right_lim (x : α) : Tendsto f (𝓝[>] x) (𝓝 (rightLim f x)) :=
  hf.dual.tendsto_left_lim x

theorem tendsto_right_lim_within (x : α) : Tendsto f (𝓝[>] x) (𝓝[≥] rightLim f x) :=
  hf.dual.tendsto_left_lim_within x

/-- A monotone function is continuous to the left at a point if and only if its left limit
coincides with the value of the function. -/
theorem continuous_within_at_Iio_iff_left_lim_eq : ContinuousWithinAt f (Iio x) x ↔ leftLim f x = f x := by
  rcases eq_or_ne (𝓝[<] x) ⊥ with (h' | h')
  · simp [left_lim_eq_of_eq_bot f h', ContinuousWithinAt, h']
    
  haveI : (𝓝[Iio x] x).ne_bot := ne_bot_iff.2 h'
  refine' ⟨fun h => tendsto_nhds_unique (hf.tendsto_left_lim x) h.Tendsto, fun h => _⟩
  have := hf.tendsto_left_lim x
  rwa [h] at this

/-- A monotone function is continuous to the right at a point if and only if its right limit
coincides with the value of the function. -/
theorem continuous_within_at_Ioi_iff_right_lim_eq : ContinuousWithinAt f (Ioi x) x ↔ rightLim f x = f x :=
  hf.dual.continuous_within_at_Iio_iff_left_lim_eq

/-- A monotone function is continuous at a point if and only if its left and right limits
coincide. -/
theorem continuous_at_iff_left_lim_eq_right_lim : ContinuousAt f x ↔ leftLim f x = rightLim f x := by
  refine' ⟨fun h => _, fun h => _⟩
  · have A : left_lim f x = f x := hf.continuous_within_at_Iio_iff_left_lim_eq.1 h.continuous_within_at
    have B : right_lim f x = f x := hf.continuous_within_at_Ioi_iff_right_lim_eq.1 h.continuous_within_at
    exact A.trans B.symm
    
  · have h' : left_lim f x = f x := by
      apply le_antisymmₓ (left_lim_le hf (le_reflₓ _))
      rw [h]
      exact le_right_lim hf (le_reflₓ _)
    refine' continuous_at_iff_continuous_left'_right'.2 ⟨_, _⟩
    · exact hf.continuous_within_at_Iio_iff_left_lim_eq.2 h'
      
    · rw [h] at h'
      exact hf.continuous_within_at_Ioi_iff_right_lim_eq.2 h'
      
    

/-- In a second countable space, the set of points where a monotone function is not right-continuous
is at most countable. Superseded by `countable_not_continuous_at` which gives the two-sided
version. -/
theorem countable_not_continuous_within_at_Ioi [TopologicalSpace.SecondCountableTopology β] :
    Set.Countable { x | ¬ContinuousWithinAt f (Ioi x) x } := by
  /- If `f` is not continuous on the right at `x`, there is an interval `(f x, z x)` which is not
    reached by `f`. This gives a family of disjoint open intervals in `β`. Such a family can only
    be countable as `β` is second-countable. -/
  nontriviality α
  let s := { x | ¬ContinuousWithinAt f (Ioi x) x }
  have : ∀ x, x ∈ s → ∃ z, f x < z ∧ ∀ y, x < y → z ≤ f y := by
    rintro x (hx : ¬ContinuousWithinAt f (Ioi x) x)
    contrapose! hx
    refine' tendsto_order.2 ⟨fun m hm => _, fun u hu => _⟩
    · filter_upwards [self_mem_nhds_within] with y hy using hm.trans_le (hf (le_of_ltₓ hy))
      
    rcases hx u hu with ⟨v, xv, fvu⟩
    have : Ioo x v ∈ 𝓝[>] x := Ioo_mem_nhds_within_Ioi ⟨le_reflₓ _, xv⟩
    filter_upwards [this] with y hy
    apply (hf hy.2.le).trans_lt fvu
  -- choose `z x` such that `f` does not take the values in `(f x, z x)`.
  choose! z hz using this
  have I : inj_on f s := by
    apply StrictMonoOnₓ.inj_on
    intro x hx y hy hxy
    calc
      f x < z x := (hz x hx).1
      _ ≤ f y := (hz x hx).2 y hxy
      
  -- show that `f s` is countable by arguing that a disjoint family of disjoint open intervals
  -- (the intervals `(f x, z x)`) is at most countable.
  have fs_count : (f '' s).Countable := by
    have A : (f '' s).PairwiseDisjoint fun x => Ioo x (z (inv_fun_on f s x)) := by
      rintro _ ⟨u, us, rfl⟩ _ ⟨v, vs, rfl⟩ huv
      wlog (discharger := tactic.skip) h'uv : u ≤ v := le_totalₓ u v using u v, v u
      · rcases eq_or_lt_of_leₓ h'uv with (rfl | h''uv)
        · exact (huv rfl).elim
          
        apply disjoint_iff_forall_ne.2
        rintro a ha b hb rfl
        simp [I.left_inv_on_inv_fun_on us, I.left_inv_on_inv_fun_on vs] at ha hb
        exact lt_irreflₓ _ ((ha.2.trans_le ((hz u us).2 v h''uv)).trans hb.1)
        
      · intro hu hv h'uv
        exact (this hv hu h'uv.symm).symm
        
    apply Set.PairwiseDisjoint.countable_of_Ioo A
    rintro _ ⟨y, ys, rfl⟩
    simpa only [I.left_inv_on_inv_fun_on ys] using (hz y ys).1
  exact maps_to.countable_of_inj_on (maps_to_image f s) I fs_count

/-- In a second countable space, the set of points where a monotone function is not left-continuous
is at most countable. Superseded by `countable_not_continuous_at` which gives the two-sided
version. -/
theorem countable_not_continuous_within_at_Iio [TopologicalSpace.SecondCountableTopology β] :
    Set.Countable { x | ¬ContinuousWithinAt f (Iio x) x } :=
  hf.dual.countable_not_continuous_within_at_Ioi

/-- In a second countable space, the set of points where a monotone function is not continuous
is at most countable. -/
theorem countable_not_continuous_at [TopologicalSpace.SecondCountableTopology β] :
    Set.Countable { x | ¬ContinuousAt f x } := by
  apply (hf.countable_not_continuous_within_at_Ioi.union hf.countable_not_continuous_within_at_Iio).mono _
  refine' compl_subset_compl.1 _
  simp only [compl_union]
  rintro x ⟨hx, h'x⟩
  simp only [mem_set_of_eq, not_not, mem_compl_iff] at hx h'x⊢
  exact continuous_at_iff_continuous_left'_right'.2 ⟨h'x, hx⟩

end Monotoneₓ

namespace Antitoneₓ

variable {α β : Type _} [LinearOrderₓ α] [ConditionallyCompleteLinearOrder β] [TopologicalSpace β] [OrderTopology β]
  {f : α → β} (hf : Antitoneₓ f) {x y : α}

include hf

theorem le_left_lim (h : x ≤ y) : f y ≤ leftLim f x :=
  hf.dual_right.left_lim_le h

theorem left_lim_le (h : x < y) : leftLim f y ≤ f x :=
  hf.dual_right.le_left_lim h

@[mono]
protected theorem left_lim : Antitoneₓ (leftLim f) :=
  hf.dual_right.leftLim

theorem right_lim_le (h : x ≤ y) : rightLim f y ≤ f x :=
  hf.dual_right.le_right_lim h

theorem le_right_lim (h : x < y) : f y ≤ rightLim f x :=
  hf.dual_right.right_lim_le h

@[mono]
protected theorem right_lim : Antitoneₓ (rightLim f) :=
  hf.dual_right.rightLim

theorem right_lim_le_left_lim (h : x ≤ y) : rightLim f y ≤ leftLim f x :=
  hf.dual_right.left_lim_le_right_lim h

theorem left_lim_le_right_lim (h : x < y) : leftLim f y ≤ rightLim f x :=
  hf.dual_right.right_lim_le_left_lim h

variable [TopologicalSpace α] [OrderTopology α]

theorem tendsto_left_lim (x : α) : Tendsto f (𝓝[<] x) (𝓝 (leftLim f x)) :=
  hf.dual_right.tendsto_left_lim x

theorem tendsto_left_lim_within (x : α) : Tendsto f (𝓝[<] x) (𝓝[≥] leftLim f x) :=
  hf.dual_right.tendsto_left_lim_within x

theorem tendsto_right_lim (x : α) : Tendsto f (𝓝[>] x) (𝓝 (rightLim f x)) :=
  hf.dual_right.tendsto_right_lim x

theorem tendsto_right_lim_within (x : α) : Tendsto f (𝓝[>] x) (𝓝[≤] rightLim f x) :=
  hf.dual_right.tendsto_right_lim_within x

/-- An antitone function is continuous to the left at a point if and only if its left limit
coincides with the value of the function. -/
theorem continuous_within_at_Iio_iff_left_lim_eq : ContinuousWithinAt f (Iio x) x ↔ leftLim f x = f x :=
  hf.dual_right.continuous_within_at_Iio_iff_left_lim_eq

/-- An antitone function is continuous to the right at a point if and only if its right limit
coincides with the value of the function. -/
theorem continuous_within_at_Ioi_iff_right_lim_eq : ContinuousWithinAt f (Ioi x) x ↔ rightLim f x = f x :=
  hf.dual_right.continuous_within_at_Ioi_iff_right_lim_eq

/-- An antitone function is continuous at a point if and only if its left and right limits
coincide. -/
theorem continuous_at_iff_left_lim_eq_right_lim : ContinuousAt f x ↔ leftLim f x = rightLim f x :=
  hf.dual_right.continuous_at_iff_left_lim_eq_right_lim

/-- In a second countable space, the set of points where an antitone function is not continuous
is at most countable. -/
theorem countable_not_continuous_at [TopologicalSpace.SecondCountableTopology β] :
    Set.Countable { x | ¬ContinuousAt f x } :=
  hf.dual_right.countable_not_continuous_at

end Antitoneₓ

