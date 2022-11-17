/-
Copyright (c) 2018 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel, Mario Carneiro, Yury Kudryashov, Heather Macbeth
-/
import Mathbin.Analysis.Normed.Order.Lattice
import Mathbin.Analysis.NormedSpace.OperatorNorm
import Mathbin.Analysis.NormedSpace.Star.Basic
import Mathbin.Data.Real.Sqrt
import Mathbin.Topology.ContinuousFunction.Algebra

/-!
# Bounded continuous functions

The type of bounded continuous functions taking values in a metric space, with
the uniform distance.

-/


noncomputable section

open TopologicalSpace Classical Nnreal

open Set Filter Metric Function

universe u v w

variable {F : Type _} {α : Type u} {β : Type v} {γ : Type w}

/-- `α →ᵇ β` is the type of bounded continuous functions `α → β` from a topological space to a
metric space.

When possible, instead of parametrizing results over `(f : α →ᵇ β)`,
you should parametrize over `(F : Type*) [bounded_continuous_map_class F α β] (f : F)`.

When you extend this structure, make sure to extend `bounded_continuous_map_class`. -/
structure BoundedContinuousFunction (α : Type u) (β : Type v) [TopologicalSpace α] [PseudoMetricSpace β] extends
  ContinuousMap α β : Type max u v where
  map_bounded' : ∃ C, ∀ x y, dist (to_fun x) (to_fun y) ≤ C
#align bounded_continuous_function BoundedContinuousFunction

-- mathport name: bounded_continuous_function
scoped[BoundedContinuousFunction] infixr:25 " →ᵇ " => BoundedContinuousFunction

section

/-- `bounded_continuous_map_class F α β` states that `F` is a type of bounded continuous maps.

You should also extend this typeclass when you extend `bounded_continuous_function`. -/
class BoundedContinuousMapClass (F α β : Type _) [TopologicalSpace α] [PseudoMetricSpace β] extends
  ContinuousMapClass F α β where
  map_bounded (f : F) : ∃ C, ∀ x y, dist (f x) (f y) ≤ C
#align bounded_continuous_map_class BoundedContinuousMapClass

end

export BoundedContinuousMapClass (map_bounded)

namespace BoundedContinuousFunction

section Basics

variable [TopologicalSpace α] [PseudoMetricSpace β] [PseudoMetricSpace γ]

variable {f g : α →ᵇ β} {x : α} {C : ℝ}

instance : BoundedContinuousMapClass (α →ᵇ β) α β where
  coe f := f.toFun
  coe_injective' f g h := by
    obtain ⟨⟨_, _⟩, _⟩ := f
    obtain ⟨⟨_, _⟩, _⟩ := g
    congr
  map_continuous f := f.continuous_to_fun
  map_bounded f := f.map_bounded'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (α →ᵇ β) fun _ => α → β :=
  FunLike.hasCoeToFun

instance [BoundedContinuousMapClass F α β] : CoeTC F (α →ᵇ β) :=
  ⟨fun f => { toFun := f, continuous_to_fun := map_continuous f, map_bounded' := map_bounded f }⟩

@[simp]
theorem coe_to_continuous_fun (f : α →ᵇ β) : (f.toContinuousMap : α → β) = f :=
  rfl
#align bounded_continuous_function.coe_to_continuous_fun BoundedContinuousFunction.coe_to_continuous_fun

/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
  because it is a composition of multiple projections. -/
def Simps.apply (h : α →ᵇ β) : α → β :=
  h
#align bounded_continuous_function.simps.apply BoundedContinuousFunction.Simps.apply

initialize_simps_projections BoundedContinuousFunction (to_continuous_map_to_fun → apply)

protected theorem bounded (f : α →ᵇ β) : ∃ C, ∀ x y : α, dist (f x) (f y) ≤ C :=
  f.map_bounded'
#align bounded_continuous_function.bounded BoundedContinuousFunction.bounded

protected theorem continuous (f : α →ᵇ β) : Continuous f :=
  f.toContinuousMap.Continuous
#align bounded_continuous_function.continuous BoundedContinuousFunction.continuous

@[ext.1]
theorem ext (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext _ _ h
#align bounded_continuous_function.ext BoundedContinuousFunction.ext

theorem boundedRange (f : α →ᵇ β) : Bounded (range f) :=
  bounded_range_iff.2 f.Bounded
#align bounded_continuous_function.bounded_range BoundedContinuousFunction.boundedRange

theorem boundedImage (f : α →ᵇ β) (s : Set α) : Bounded (f '' s) :=
  f.boundedRange.mono $ image_subset_range _ _
#align bounded_continuous_function.bounded_image BoundedContinuousFunction.boundedImage

theorem eq_of_empty [IsEmpty α] (f g : α →ᵇ β) : f = g :=
  ext $ IsEmpty.elim ‹_›
#align bounded_continuous_function.eq_of_empty BoundedContinuousFunction.eq_of_empty

/-- A continuous function with an explicit bound is a bounded continuous function. -/
def mkOfBound (f : C(α, β)) (C : ℝ) (h : ∀ x y : α, dist (f x) (f y) ≤ C) : α →ᵇ β :=
  ⟨f, ⟨C, h⟩⟩
#align bounded_continuous_function.mk_of_bound BoundedContinuousFunction.mkOfBound

@[simp]
theorem mk_of_bound_coe {f} {C} {h} : (mkOfBound f C h : α → β) = (f : α → β) :=
  rfl
#align bounded_continuous_function.mk_of_bound_coe BoundedContinuousFunction.mk_of_bound_coe

/-- A continuous function on a compact space is automatically a bounded continuous function. -/
def mkOfCompact [CompactSpace α] (f : C(α, β)) : α →ᵇ β :=
  ⟨f, bounded_range_iff.1 (is_compact_range f.Continuous).Bounded⟩
#align bounded_continuous_function.mk_of_compact BoundedContinuousFunction.mkOfCompact

@[simp]
theorem mk_of_compact_apply [CompactSpace α] (f : C(α, β)) (a : α) : mkOfCompact f a = f a :=
  rfl
#align bounded_continuous_function.mk_of_compact_apply BoundedContinuousFunction.mk_of_compact_apply

/-- If a function is bounded on a discrete space, it is automatically continuous,
and therefore gives rise to an element of the type of bounded continuous functions -/
@[simps]
def mkOfDiscrete [DiscreteTopology α] (f : α → β) (C : ℝ) (h : ∀ x y : α, dist (f x) (f y) ≤ C) : α →ᵇ β :=
  ⟨⟨f, continuous_of_discrete_topology⟩, ⟨C, h⟩⟩
#align bounded_continuous_function.mk_of_discrete BoundedContinuousFunction.mkOfDiscrete

/-- The uniform distance between two bounded continuous functions -/
instance : HasDist (α →ᵇ β) :=
  ⟨fun f g => inf { C | 0 ≤ C ∧ ∀ x : α, dist (f x) (g x) ≤ C }⟩

theorem dist_eq : dist f g = inf { C | 0 ≤ C ∧ ∀ x : α, dist (f x) (g x) ≤ C } :=
  rfl
#align bounded_continuous_function.dist_eq BoundedContinuousFunction.dist_eq

theorem dist_set_exists : ∃ C, 0 ≤ C ∧ ∀ x : α, dist (f x) (g x) ≤ C := by
  rcases f.bounded_range.union g.bounded_range with ⟨C, hC⟩
  refine' ⟨max 0 C, le_max_left _ _, fun x => (hC _ _ _ _).trans (le_max_right _ _)⟩ <;> [left, right] <;>
    apply mem_range_self
#align bounded_continuous_function.dist_set_exists BoundedContinuousFunction.dist_set_exists

/-- The pointwise distance is controlled by the distance between functions, by definition. -/
theorem dist_coe_le_dist (x : α) : dist (f x) (g x) ≤ dist f g :=
  le_cInf dist_set_exists $ fun b hb => hb.2 x
#align bounded_continuous_function.dist_coe_le_dist BoundedContinuousFunction.dist_coe_le_dist

/- This lemma will be needed in the proof of the metric space instance, but it will become
useless afterwards as it will be superseded by the general result that the distance is nonnegative
in metric spaces. -/
private theorem dist_nonneg' : 0 ≤ dist f g :=
  le_cInf dist_set_exists fun C => And.left
#align bounded_continuous_function.dist_nonneg' bounded_continuous_function.dist_nonneg'

/-- The distance between two functions is controlled by the supremum of the pointwise distances -/
theorem dist_le (C0 : (0 : ℝ) ≤ C) : dist f g ≤ C ↔ ∀ x : α, dist (f x) (g x) ≤ C :=
  ⟨fun h x => le_trans (dist_coe_le_dist x) h, fun H => cInf_le ⟨0, fun C => And.left⟩ ⟨C0, H⟩⟩
#align bounded_continuous_function.dist_le BoundedContinuousFunction.dist_le

theorem dist_le_iff_of_nonempty [Nonempty α] : dist f g ≤ C ↔ ∀ x, dist (f x) (g x) ≤ C :=
  ⟨fun h x => le_trans (dist_coe_le_dist x) h, fun w => (dist_le (le_trans dist_nonneg (w (Nonempty.some ‹_›)))).mpr w⟩
#align bounded_continuous_function.dist_le_iff_of_nonempty BoundedContinuousFunction.dist_le_iff_of_nonempty

theorem dist_lt_of_nonempty_compact [Nonempty α] [CompactSpace α] (w : ∀ x : α, dist (f x) (g x) < C) : dist f g < C :=
  by
  have c : Continuous fun x => dist (f x) (g x) := by continuity
  obtain ⟨x, -, le⟩ := IsCompact.exists_forall_ge is_compact_univ Set.univ_nonempty (Continuous.continuous_on c)
  exact lt_of_le_of_lt (dist_le_iff_of_nonempty.mpr fun y => le y trivial) (w x)
#align bounded_continuous_function.dist_lt_of_nonempty_compact BoundedContinuousFunction.dist_lt_of_nonempty_compact

theorem dist_lt_iff_of_compact [CompactSpace α] (C0 : (0 : ℝ) < C) : dist f g < C ↔ ∀ x : α, dist (f x) (g x) < C := by
  fconstructor
  · intro w x
    exact lt_of_le_of_lt (dist_coe_le_dist x) w
    
  · by_cases h:Nonempty α
    · skip
      exact dist_lt_of_nonempty_compact
      
    · rintro -
      convert C0
      apply le_antisymm _ dist_nonneg'
      rw [dist_eq]
      exact cInf_le ⟨0, fun C => And.left⟩ ⟨le_rfl, fun x => False.elim (h (Nonempty.intro x))⟩
      
    
#align bounded_continuous_function.dist_lt_iff_of_compact BoundedContinuousFunction.dist_lt_iff_of_compact

theorem dist_lt_iff_of_nonempty_compact [Nonempty α] [CompactSpace α] : dist f g < C ↔ ∀ x : α, dist (f x) (g x) < C :=
  ⟨fun w x => lt_of_le_of_lt (dist_coe_le_dist x) w, dist_lt_of_nonempty_compact⟩
#align
  bounded_continuous_function.dist_lt_iff_of_nonempty_compact BoundedContinuousFunction.dist_lt_iff_of_nonempty_compact

/-- The type of bounded continuous functions, with the uniform distance, is a pseudometric space. -/
instance : PseudoMetricSpace (α →ᵇ β) where
  dist_self f := le_antisymm ((dist_le le_rfl).2 $ fun x => by simp) dist_nonneg'
  dist_comm f g := by simp [dist_eq, dist_comm]
  dist_triangle f g h :=
    (dist_le (add_nonneg dist_nonneg' dist_nonneg')).2 $ fun x =>
      le_trans (dist_triangle _ _ _) (add_le_add (dist_coe_le_dist _) (dist_coe_le_dist _))

/-- The type of bounded continuous functions, with the uniform distance, is a metric space. -/
instance {α β} [TopologicalSpace α] [MetricSpace β] :
    MetricSpace
      (α →ᵇ
        β) where eq_of_dist_eq_zero f g hfg := by
    ext x <;> exact eq_of_dist_eq_zero (le_antisymm (hfg ▸ dist_coe_le_dist _) dist_nonneg)

theorem nndist_eq : nndist f g = inf { C | ∀ x : α, nndist (f x) (g x) ≤ C } :=
  Subtype.ext $
    dist_eq.trans $ by
      rw [Nnreal.coe_Inf, Nnreal.coe_image]
      simp_rw [mem_set_of_eq, ← Nnreal.coe_le_coe, Subtype.coe_mk, exists_prop, coe_nndist]
#align bounded_continuous_function.nndist_eq BoundedContinuousFunction.nndist_eq

theorem nndist_set_exists : ∃ C, ∀ x : α, nndist (f x) (g x) ≤ C :=
  Subtype.exists.mpr $ dist_set_exists.imp $ fun a ⟨ha, h⟩ => ⟨ha, h⟩
#align bounded_continuous_function.nndist_set_exists BoundedContinuousFunction.nndist_set_exists

theorem nndist_coe_le_nndist (x : α) : nndist (f x) (g x) ≤ nndist f g :=
  dist_coe_le_dist x
#align bounded_continuous_function.nndist_coe_le_nndist BoundedContinuousFunction.nndist_coe_le_nndist

/-- On an empty space, bounded continuous functions are at distance 0 -/
theorem dist_zero_of_empty [IsEmpty α] : dist f g = 0 := by rw [(ext isEmptyElim : f = g), dist_self]
#align bounded_continuous_function.dist_zero_of_empty BoundedContinuousFunction.dist_zero_of_empty

theorem dist_eq_supr : dist f g = ⨆ x : α, dist (f x) (g x) := by
  cases isEmpty_or_nonempty α
  · rw [supr_of_empty', Real.Sup_empty, dist_zero_of_empty]
    
  refine' (dist_le_iff_of_nonempty.mpr $ le_csupr _).antisymm (csupr_le dist_coe_le_dist)
  exact dist_set_exists.imp fun C hC => forall_range_iff.2 hC.2
#align bounded_continuous_function.dist_eq_supr BoundedContinuousFunction.dist_eq_supr

theorem nndist_eq_supr : nndist f g = ⨆ x : α, nndist (f x) (g x) :=
  Subtype.ext $ dist_eq_supr.trans $ by simp_rw [Nnreal.coe_supr, coe_nndist]
#align bounded_continuous_function.nndist_eq_supr BoundedContinuousFunction.nndist_eq_supr

theorem tendsto_iff_tendsto_uniformly {ι : Type _} {F : ι → α →ᵇ β} {f : α →ᵇ β} {l : Filter ι} :
    Tendsto F l (𝓝 f) ↔ TendstoUniformly (fun i => F i) f l :=
  Iff.intro
    (fun h =>
      tendsto_uniformly_iff.2 fun ε ε0 =>
        (Metric.tendsto_nhds.mp h ε ε0).mp
          (eventually_of_forall $ fun n hn x => lt_of_le_of_lt (dist_coe_le_dist x) (dist_comm (F n) f ▸ hn)))
    fun h =>
    Metric.tendsto_nhds.mpr $ fun ε ε_pos =>
      (h _ (dist_mem_uniformity $ half_pos ε_pos)).mp
        (eventually_of_forall $ fun n hn =>
          lt_of_le_of_lt ((dist_le (half_pos ε_pos).le).mpr $ fun x => dist_comm (f x) (F n x) ▸ le_of_lt (hn x))
            (half_lt_self ε_pos))
#align bounded_continuous_function.tendsto_iff_tendsto_uniformly BoundedContinuousFunction.tendsto_iff_tendsto_uniformly

variable (α) {β}

/-- Constant as a continuous bounded function. -/
@[simps (config := { fullyApplied := false })]
def const (b : β) : α →ᵇ β :=
  ⟨ContinuousMap.const α b, 0, by simp [le_rfl]⟩
#align bounded_continuous_function.const BoundedContinuousFunction.const

variable {α}

theorem const_apply' (a : α) (b : β) : (const α b : α → β) a = b :=
  rfl
#align bounded_continuous_function.const_apply' BoundedContinuousFunction.const_apply'

/-- If the target space is inhabited, so is the space of bounded continuous functions -/
instance [Inhabited β] : Inhabited (α →ᵇ β) :=
  ⟨const α default⟩

theorem lipschitzEvalx (x : α) : LipschitzWith 1 fun f : α →ᵇ β => f x :=
  LipschitzWith.mkOne $ fun f g => dist_coe_le_dist x
#align bounded_continuous_function.lipschitz_evalx BoundedContinuousFunction.lipschitzEvalx

theorem uniform_continuous_coe : @UniformContinuous (α →ᵇ β) (α → β) _ _ coeFn :=
  uniform_continuous_pi.2 $ fun x => (lipschitzEvalx x).UniformContinuous
#align bounded_continuous_function.uniform_continuous_coe BoundedContinuousFunction.uniform_continuous_coe

theorem continuous_coe : Continuous fun (f : α →ᵇ β) x => f x :=
  UniformContinuous.continuous uniform_continuous_coe
#align bounded_continuous_function.continuous_coe BoundedContinuousFunction.continuous_coe

/-- When `x` is fixed, `(f : α →ᵇ β) ↦ f x` is continuous -/
@[continuity]
theorem continuous_eval_const {x : α} : Continuous fun f : α →ᵇ β => f x :=
  (continuous_apply x).comp continuous_coe
#align bounded_continuous_function.continuous_eval_const BoundedContinuousFunction.continuous_eval_const

/-- The evaluation map is continuous, as a joint function of `u` and `x` -/
@[continuity]
theorem continuous_eval : Continuous fun p : (α →ᵇ β) × α => p.1 p.2 :=
  (continuous_prod_of_continuous_lipschitz _ 1 fun f => f.Continuous) $ lipschitz_evalx
#align bounded_continuous_function.continuous_eval BoundedContinuousFunction.continuous_eval

/-- Bounded continuous functions taking values in a complete space form a complete space. -/
instance [CompleteSpace β] : CompleteSpace (α →ᵇ β) :=
  complete_of_cauchy_seq_tendsto $ fun (f : ℕ → α →ᵇ β) (hf : CauchySeq f) => by
    /- We have to show that `f n` converges to a bounded continuous function.
      For this, we prove pointwise convergence to define the limit, then check
      it is a continuous bounded function, and then check the norm convergence. -/
    rcases cauchy_seq_iff_le_tendsto_0.1 hf with ⟨b, b0, b_bound, b_lim⟩
    have f_bdd := fun x n m N hn hm => le_trans (dist_coe_le_dist x) (b_bound n m N hn hm)
    have fx_cau : ∀ x, CauchySeq fun n => f n x := fun x => cauchy_seq_iff_le_tendsto_0.2 ⟨b, b0, f_bdd x, b_lim⟩
    choose F hF using fun x => cauchy_seq_tendsto_of_complete (fx_cau x)
    /- F : α → β,  hF : ∀ (x : α), tendsto (λ (n : ℕ), f n x) at_top (𝓝 (F x))
      `F` is the desired limit function. Check that it is uniformly approximated by `f N` -/
    have fF_bdd : ∀ x N, dist (f N x) (F x) ≤ b N := fun x N =>
      le_of_tendsto (tendsto_const_nhds.dist (hF x))
        (Filter.eventually_at_top.2 ⟨N, fun n hn => f_bdd x N n N (le_refl N) hn⟩)
    refine' ⟨⟨⟨F, _⟩, _⟩, _⟩
    · -- Check that `F` is continuous, as a uniform limit of continuous functions
      have : TendstoUniformly (fun n x => f n x) F at_top := by
        refine' Metric.tendsto_uniformly_iff.2 fun ε ε0 => _
        refine' ((tendsto_order.1 b_lim).2 ε ε0).mono fun n hn x => _
        rw [dist_comm]
        exact lt_of_le_of_lt (fF_bdd x n) hn
      exact this.continuous (eventually_of_forall $ fun N => (f N).Continuous)
      
    · -- Check that `F` is bounded
      rcases(f 0).Bounded with ⟨C, hC⟩
      refine' ⟨C + (b 0 + b 0), fun x y => _⟩
      calc
        dist (F x) (F y) ≤ dist (f 0 x) (f 0 y) + (dist (f 0 x) (F x) + dist (f 0 y) (F y)) :=
          dist_triangle4_left _ _ _ _
        _ ≤ C + (b 0 + b 0) := by mono*
        
      
    · -- Check that `F` is close to `f N` in distance terms
      refine' tendsto_iff_dist_tendsto_zero.2 (squeeze_zero (fun _ => dist_nonneg) _ b_lim)
      exact fun N => (dist_le (b0 _)).2 fun x => fF_bdd x N
      

/-- Composition of a bounded continuous function and a continuous function. -/
@[simps (config := { fullyApplied := false })]
def compContinuous {δ : Type _} [TopologicalSpace δ] (f : α →ᵇ β) (g : C(δ, α)) : δ →ᵇ β where
  toContinuousMap := f.1.comp g
  map_bounded' := f.map_bounded'.imp fun C hC x y => hC _ _
#align bounded_continuous_function.comp_continuous BoundedContinuousFunction.compContinuous

theorem lipschitzCompContinuous {δ : Type _} [TopologicalSpace δ] (g : C(δ, α)) :
    LipschitzWith 1 fun f : α →ᵇ β => f.comp_continuous g :=
  LipschitzWith.mkOne $ fun f₁ f₂ => (dist_le dist_nonneg).2 $ fun x => dist_coe_le_dist (g x)
#align bounded_continuous_function.lipschitz_comp_continuous BoundedContinuousFunction.lipschitzCompContinuous

theorem continuous_comp_continuous {δ : Type _} [TopologicalSpace δ] (g : C(δ, α)) :
    Continuous fun f : α →ᵇ β => f.comp_continuous g :=
  (lipschitzCompContinuous g).Continuous
#align bounded_continuous_function.continuous_comp_continuous BoundedContinuousFunction.continuous_comp_continuous

/-- Restrict a bounded continuous function to a set. -/
@[simps (config := { fullyApplied := false }) apply]
def restrict (f : α →ᵇ β) (s : Set α) : s →ᵇ β :=
  f.comp_continuous $ (ContinuousMap.id _).restrict s
#align bounded_continuous_function.restrict BoundedContinuousFunction.restrict

/-- Composition (in the target) of a bounded continuous function with a Lipschitz map again
gives a bounded continuous function -/
def comp (G : β → γ) {C : ℝ≥0} (H : LipschitzWith C G) (f : α →ᵇ β) : α →ᵇ γ :=
  ⟨⟨fun x => G (f x), H.Continuous.comp f.Continuous⟩,
    let ⟨D, hD⟩ := f.Bounded
    ⟨max C 0 * D, fun x y =>
      calc
        dist (G (f x)) (G (f y)) ≤ C * dist (f x) (f y) := H.dist_le_mul _ _
        _ ≤ max C 0 * dist (f x) (f y) := mul_le_mul_of_nonneg_right (le_max_left C 0) dist_nonneg
        _ ≤ max C 0 * D := mul_le_mul_of_nonneg_left (hD _ _) (le_max_right C 0)
        ⟩⟩
#align bounded_continuous_function.comp BoundedContinuousFunction.comp

/-- The composition operator (in the target) with a Lipschitz map is Lipschitz -/
theorem lipschitzComp {G : β → γ} {C : ℝ≥0} (H : LipschitzWith C G) : LipschitzWith C (comp G H : (α →ᵇ β) → α →ᵇ γ) :=
  LipschitzWith.ofDistLeMul $ fun f g =>
    (dist_le (mul_nonneg C.2 dist_nonneg)).2 $ fun x =>
      calc
        dist (G (f x)) (G (g x)) ≤ C * dist (f x) (g x) := H.dist_le_mul _ _
        _ ≤ C * dist f g := mul_le_mul_of_nonneg_left (dist_coe_le_dist _) C.2
        
#align bounded_continuous_function.lipschitz_comp BoundedContinuousFunction.lipschitzComp

/-- The composition operator (in the target) with a Lipschitz map is uniformly continuous -/
theorem uniform_continuous_comp {G : β → γ} {C : ℝ≥0} (H : LipschitzWith C G) :
    UniformContinuous (comp G H : (α →ᵇ β) → α →ᵇ γ) :=
  (lipschitzComp H).UniformContinuous
#align bounded_continuous_function.uniform_continuous_comp BoundedContinuousFunction.uniform_continuous_comp

/-- The composition operator (in the target) with a Lipschitz map is continuous -/
theorem continuous_comp {G : β → γ} {C : ℝ≥0} (H : LipschitzWith C G) : Continuous (comp G H : (α →ᵇ β) → α →ᵇ γ) :=
  (lipschitzComp H).Continuous
#align bounded_continuous_function.continuous_comp BoundedContinuousFunction.continuous_comp

/-- Restriction (in the target) of a bounded continuous function taking values in a subset -/
def codRestrict (s : Set β) (f : α →ᵇ β) (H : ∀ x, f x ∈ s) : α →ᵇ s :=
  ⟨⟨s.codRestrict f H, f.Continuous.subtype_mk _⟩, f.Bounded⟩
#align bounded_continuous_function.cod_restrict BoundedContinuousFunction.codRestrict

section Extend

variable {δ : Type _} [TopologicalSpace δ] [DiscreteTopology δ]

/-- A version of `function.extend` for bounded continuous maps. We assume that the domain has
discrete topology, so we only need to verify boundedness. -/
def extend (f : α ↪ δ) (g : α →ᵇ β) (h : δ →ᵇ β) : δ →ᵇ β where
  toFun := extend f g h
  continuous_to_fun := continuous_of_discrete_topology
  map_bounded' := by
    rw [← bounded_range_iff, range_extend f.injective, Metric.bounded_union]
    exact ⟨g.bounded_range, h.bounded_image _⟩
#align bounded_continuous_function.extend BoundedContinuousFunction.extend

@[simp]
theorem extend_apply (f : α ↪ δ) (g : α →ᵇ β) (h : δ →ᵇ β) (x : α) : extend f g h (f x) = g x :=
  extend_apply f.Injective _ _ _
#align bounded_continuous_function.extend_apply BoundedContinuousFunction.extend_apply

@[simp]
theorem extend_comp (f : α ↪ δ) (g : α →ᵇ β) (h : δ →ᵇ β) : extend f g h ∘ f = g :=
  extend_comp f.Injective _ _
#align bounded_continuous_function.extend_comp BoundedContinuousFunction.extend_comp

theorem extend_apply' {f : α ↪ δ} {x : δ} (hx : x ∉ range f) (g : α →ᵇ β) (h : δ →ᵇ β) : extend f g h x = h x :=
  extend_apply' _ _ _ hx
#align bounded_continuous_function.extend_apply' BoundedContinuousFunction.extend_apply'

theorem extend_of_empty [IsEmpty α] (f : α ↪ δ) (g : α →ᵇ β) (h : δ →ᵇ β) : extend f g h = h :=
  FunLike.coe_injective $ Function.extend_of_isEmpty f g h
#align bounded_continuous_function.extend_of_empty BoundedContinuousFunction.extend_of_empty

@[simp]
theorem dist_extend_extend (f : α ↪ δ) (g₁ g₂ : α →ᵇ β) (h₁ h₂ : δ →ᵇ β) :
    dist (g₁.extend f h₁) (g₂.extend f h₂) =
      max (dist g₁ g₂) (dist (h₁.restrict (range fᶜ)) (h₂.restrict (range fᶜ))) :=
  by
  refine' le_antisymm ((dist_le $ le_max_iff.2 $ Or.inl dist_nonneg).2 $ fun x => _) (max_le _ _)
  · rcases em (∃ y, f y = x) with (⟨x, rfl⟩ | hx)
    · simp only [extend_apply]
      exact (dist_coe_le_dist x).trans (le_max_left _ _)
      
    · simp only [extend_apply' hx]
      lift x to (range fᶜ : Set δ) using hx
      calc
        dist (h₁ x) (h₂ x) = dist (h₁.restrict (range fᶜ) x) (h₂.restrict (range fᶜ) x) := rfl
        _ ≤ dist (h₁.restrict (range fᶜ)) (h₂.restrict (range fᶜ)) := dist_coe_le_dist x
        _ ≤ _ := le_max_right _ _
        
      
    
  · refine' (dist_le dist_nonneg).2 fun x => _
    rw [← extend_apply f g₁ h₁, ← extend_apply f g₂ h₂]
    exact dist_coe_le_dist _
    
  · refine' (dist_le dist_nonneg).2 fun x => _
    calc
      dist (h₁ x) (h₂ x) = dist (extend f g₁ h₁ x) (extend f g₂ h₂ x) := by
        rw [extend_apply' x.coe_prop, extend_apply' x.coe_prop]
      _ ≤ _ := dist_coe_le_dist _
      
    
#align bounded_continuous_function.dist_extend_extend BoundedContinuousFunction.dist_extend_extend

theorem isometryExtend (f : α ↪ δ) (h : δ →ᵇ β) : Isometry fun g : α →ᵇ β => extend f g h :=
  Isometry.ofDistEq $ fun g₁ g₂ => by simp [dist_nonneg]
#align bounded_continuous_function.isometry_extend BoundedContinuousFunction.isometryExtend

end Extend

end Basics

section ArzelaAscoli

variable [TopologicalSpace α] [CompactSpace α] [PseudoMetricSpace β]

variable {f g : α →ᵇ β} {x : α} {C : ℝ}

/- ./././Mathport/Syntax/Translate/Basic.lean:611:2: warning: expanding binder collection (y z «expr ∈ » U) -/
/- ./././Mathport/Syntax/Translate/Basic.lean:611:2: warning: expanding binder collection (y z «expr ∈ » U) -/
/- Arzela-Ascoli theorem asserts that, on a compact space, a set of functions sharing
a common modulus of continuity and taking values in a compact set forms a compact
subset for the topology of uniform convergence. In this section, we prove this theorem
and several useful variations around it. -/
/-- First version, with pointwise equicontinuity and range in a compact space -/
theorem arzela_ascoli₁ [CompactSpace β] (A : Set (α →ᵇ β)) (closed : IsClosed A)
    (H : ∀ (x : α), ∀ ε > 0, ∃ U ∈ 𝓝 x, ∀ (y z) (_ : y ∈ U) (_ : z ∈ U) (f : α →ᵇ β), f ∈ A → dist (f y) (f z) < ε) :
    IsCompact A := by
  refine' is_compact_of_totally_bounded_is_closed _ closed
  refine' totally_bounded_of_finite_discretization fun ε ε0 => _
  rcases exists_between ε0 with ⟨ε₁, ε₁0, εε₁⟩
  let ε₂ := ε₁ / 2 / 2
  /- We have to find a finite discretization of `u`, i.e., finite information
    that is sufficient to reconstruct `u` up to ε. This information will be
    provided by the values of `u` on a sufficiently dense set tα,
    slightly translated to fit in a finite ε₂-dense set tβ in the image. Such
    sets exist by compactness of the source and range. Then, to check that these
    data determine the function up to ε, one uses the control on the modulus of
    continuity to extend the closeness on tα to closeness everywhere. -/
  have ε₂0 : ε₂ > 0 := half_pos (half_pos ε₁0)
  have : ∀ x : α, ∃ U, x ∈ U ∧ IsOpen U ∧ ∀ (y z) (_ : y ∈ U) (_ : z ∈ U) {f : α →ᵇ β}, f ∈ A → dist (f y) (f z) < ε₂ :=
    fun x =>
    let ⟨U, nhdsU, hU⟩ := H x _ ε₂0
    let ⟨V, VU, openV, xV⟩ := _root_.mem_nhds_iff.1 nhdsU
    ⟨V, xV, openV, fun y hy z hz f hf => hU y (VU hy) z (VU hz) f hf⟩
  choose U hU using this
  /- For all x, the set hU x is an open set containing x on which the elements of A
    fluctuate by at most ε₂.
    We extract finitely many of these sets that cover the whole space, by compactness -/
  rcases is_compact_univ.elim_finite_subcover_image (fun x _ => (hU x).2.1) fun x hx =>
      mem_bUnion (mem_univ _) (hU x).1 with
    ⟨tα, _, ⟨_⟩, htα⟩
  -- tα : set α, htα : univ ⊆ ⋃x ∈ tα, U x
  rcases@finite_cover_balls_of_compact β _ _ is_compact_univ _ ε₂0 with ⟨tβ, _, ⟨_⟩, htβ⟩
  skip
  -- tβ : set β, htβ : univ ⊆ ⋃y ∈ tβ, ball y ε₂ 
  -- Associate to every point `y` in the space a nearby point `F y` in tβ
  choose F hF using fun y => show ∃ z ∈ tβ, dist y z < ε₂ by simpa using htβ (mem_univ y)
  -- F : β → β, hF : ∀ (y : β), F y ∈ tβ ∧ dist y (F y) < ε₂ 
  /- Associate to every function a discrete approximation, mapping each point in `tα`
    to a point in `tβ` close to its true image by the function. -/
  refine' ⟨tα → tβ, by infer_instance, fun f a => ⟨F (f a), (hF (f a)).1⟩, _⟩
  rintro ⟨f, hf⟩ ⟨g, hg⟩ f_eq_g
  -- If two functions have the same approximation, then they are within distance ε
  refine' lt_of_le_of_lt ((dist_le $ le_of_lt ε₁0).2 fun x => _) εε₁
  obtain ⟨x', x'tα, hx'⟩ : ∃ x' ∈ tα, x ∈ U x' := mem_Union₂.1 (htα (mem_univ x))
  calc
    dist (f x) (g x) ≤ dist (f x) (f x') + dist (g x) (g x') + dist (f x') (g x') := dist_triangle4_right _ _ _ _
    _ ≤ ε₂ + ε₂ + ε₁ / 2 := le_of_lt (add_lt_add (add_lt_add _ _) _)
    _ = ε₁ := by rw [add_halves, add_halves]
    
  · exact (hU x').2.2 _ hx' _ (hU x').1 hf
    
  · exact (hU x').2.2 _ hx' _ (hU x').1 hg
    
  · have F_f_g : F (f x') = F (g x') := (congr_arg (fun f : tα → tβ => (f ⟨x', x'tα⟩ : β)) f_eq_g : _)
    calc
      dist (f x') (g x') ≤ dist (f x') (F (f x')) + dist (g x') (F (f x')) := dist_triangle_right _ _ _
      _ = dist (f x') (F (f x')) + dist (g x') (F (g x')) := by rw [F_f_g]
      _ < ε₂ + ε₂ := add_lt_add (hF (f x')).2 (hF (g x')).2
      _ = ε₁ / 2 := add_halves _
      
    
#align bounded_continuous_function.arzela_ascoli₁ BoundedContinuousFunction.arzela_ascoli₁

/- ./././Mathport/Syntax/Translate/Basic.lean:611:2: warning: expanding binder collection (y z «expr ∈ » U) -/
/-- Second version, with pointwise equicontinuity and range in a compact subset -/
theorem arzela_ascoli₂ (s : Set β) (hs : IsCompact s) (A : Set (α →ᵇ β)) (closed : IsClosed A)
    (in_s : ∀ (f : α →ᵇ β) (x : α), f ∈ A → f x ∈ s)
    (H : ∀ (x : α), ∀ ε > 0, ∃ U ∈ 𝓝 x, ∀ (y z) (_ : y ∈ U) (_ : z ∈ U) (f : α →ᵇ β), f ∈ A → dist (f y) (f z) < ε) :
    IsCompact A := by
  /- This version is deduced from the previous one by restricting to the compact type in the target,
  using compactness there and then lifting everything to the original space. -/
  have M : LipschitzWith 1 coe := LipschitzWith.subtypeCoe s
  let F : (α →ᵇ s) → α →ᵇ β := comp coe M
  refine' is_compact_of_is_closed_subset ((_ : IsCompact (F ⁻¹' A)).image (continuous_comp M)) closed fun f hf => _
  · haveI : CompactSpace s := is_compact_iff_compact_space.1 hs
    refine'
      arzela_ascoli₁ _ (continuous_iff_is_closed.1 (continuous_comp M) _ closed) fun x ε ε0 =>
        BEx.imp_right (fun U U_nhds hU y hy z hz f hf => _) (H x ε ε0)
    calc
      dist (f y) (f z) = dist (F f y) (F f z) := rfl
      _ < ε := hU y hy z hz (F f) hf
      
    
  · let g := cod_restrict s f fun x => in_s f x hf
    rw [show f = F g by ext <;> rfl] at hf⊢
    exact ⟨g, hf, rfl⟩
    
#align bounded_continuous_function.arzela_ascoli₂ BoundedContinuousFunction.arzela_ascoli₂

/- ./././Mathport/Syntax/Translate/Basic.lean:611:2: warning: expanding binder collection (y z «expr ∈ » U) -/
/- ./././Mathport/Syntax/Translate/Basic.lean:611:2: warning: expanding binder collection (y z «expr ∈ » U) -/
/-- Third (main) version, with pointwise equicontinuity and range in a compact subset, but
without closedness. The closure is then compact -/
theorem arzela_ascoli [T2Space β] (s : Set β) (hs : IsCompact s) (A : Set (α →ᵇ β))
    (in_s : ∀ (f : α →ᵇ β) (x : α), f ∈ A → f x ∈ s)
    (H : ∀ (x : α), ∀ ε > 0, ∃ U ∈ 𝓝 x, ∀ (y z) (_ : y ∈ U) (_ : z ∈ U) (f : α →ᵇ β), f ∈ A → dist (f y) (f z) < ε) :
    IsCompact (closure A) :=
  /- This version is deduced from the previous one by checking that the closure of A, in
    addition to being closed, still satisfies the properties of compact range and equicontinuity -/
    arzela_ascoli₂
    s hs (closure A) isClosedClosure
    (fun f x hf =>
      (mem_of_closed' hs.IsClosed).2 $ fun ε ε0 =>
        let ⟨g, gA, dist_fg⟩ := Metric.mem_closure_iff.1 hf ε ε0
        ⟨g x, in_s g x gA, lt_of_le_of_lt (dist_coe_le_dist _) dist_fg⟩)
    fun x ε ε0 =>
    show ∃ U ∈ 𝓝 x, ∀ (y z) (_ : y ∈ U) (_ : z ∈ U), ∀ f : α →ᵇ β, f ∈ closure A → dist (f y) (f z) < ε by
      refine' BEx.imp_right (fun U U_set hU y hy z hz f hf => _) (H x (ε / 2) (half_pos ε0))
      rcases Metric.mem_closure_iff.1 hf (ε / 2 / 2) (half_pos (half_pos ε0)) with ⟨g, gA, dist_fg⟩
      replace dist_fg := fun x => lt_of_le_of_lt (dist_coe_le_dist x) dist_fg
      calc
        dist (f y) (f z) ≤ dist (f y) (g y) + dist (f z) (g z) + dist (g y) (g z) := dist_triangle4_right _ _ _ _
        _ < ε / 2 / 2 + ε / 2 / 2 + ε / 2 := add_lt_add (add_lt_add (dist_fg y) (dist_fg z)) (hU y hy z hz g gA)
        _ = ε := by rw [add_halves, add_halves]
        
#align bounded_continuous_function.arzela_ascoli BoundedContinuousFunction.arzela_ascoli

/- ./././Mathport/Syntax/Translate/Basic.lean:611:2: warning: expanding binder collection (y z «expr ∈ » U) -/
/- To apply the previous theorems, one needs to check the equicontinuity. An important
instance is when the source space is a metric space, and there is a fixed modulus of continuity
for all the functions in the set A -/
theorem equicontinuous_of_continuity_modulus {α : Type u} [PseudoMetricSpace α] (b : ℝ → ℝ)
    (b_lim : Tendsto b (𝓝 0) (𝓝 0)) (A : Set (α →ᵇ β))
    (H : ∀ (x y : α) (f : α →ᵇ β), f ∈ A → dist (f x) (f y) ≤ b (dist x y)) (x : α) (ε : ℝ) (ε0 : 0 < ε) :
    ∃ U ∈ 𝓝 x, ∀ (y z) (_ : y ∈ U) (_ : z ∈ U) (f : α →ᵇ β), f ∈ A → dist (f y) (f z) < ε := by
  rcases tendsto_nhds_nhds.1 b_lim ε ε0 with ⟨δ, δ0, hδ⟩
  refine' ⟨ball x (δ / 2), ball_mem_nhds x (half_pos δ0), fun y hy z hz f hf => _⟩
  have : dist y z < δ :=
    calc
      dist y z ≤ dist y x + dist z x := dist_triangle_right _ _ _
      _ < δ / 2 + δ / 2 := add_lt_add hy hz
      _ = δ := add_halves _
      
  calc
    dist (f y) (f z) ≤ b (dist y z) := H y z f hf
    _ ≤ |b (dist y z)| := le_abs_self _
    _ = dist (b (dist y z)) 0 := by simp [Real.dist_eq]
    _ < ε := hδ (by simpa [Real.dist_eq] using this)
    
#align
  bounded_continuous_function.equicontinuous_of_continuity_modulus BoundedContinuousFunction.equicontinuous_of_continuity_modulus

end ArzelaAscoli

section One

variable [TopologicalSpace α] [PseudoMetricSpace β] [One β]

@[to_additive]
instance : One (α →ᵇ β) :=
  ⟨const α 1⟩

@[simp, to_additive]
protected theorem coe_one : ((1 : α →ᵇ β) : α → β) = 1 :=
  rfl
#align bounded_continuous_function.coe_one BoundedContinuousFunction.coe_one

@[simp, to_additive]
theorem mk_of_compact_one [CompactSpace α] : mkOfCompact (1 : C(α, β)) = 1 :=
  rfl
#align bounded_continuous_function.mk_of_compact_one BoundedContinuousFunction.mk_of_compact_one

@[to_additive]
theorem forall_coe_one_iff_one (f : α →ᵇ β) : (∀ x, f x = 1) ↔ f = 1 :=
  (@FunLike.ext_iff _ _ _ _ f 1).symm
#align bounded_continuous_function.forall_coe_one_iff_one BoundedContinuousFunction.forall_coe_one_iff_one

@[simp, to_additive]
theorem one_comp_continuous [TopologicalSpace γ] (f : C(γ, α)) : (1 : α →ᵇ β).comp_continuous f = 1 :=
  rfl
#align bounded_continuous_function.one_comp_continuous BoundedContinuousFunction.one_comp_continuous

end One

section HasLipschitzAdd

/- In this section, if `β` is an `add_monoid` whose addition operation is Lipschitz, then we show
that the space of bounded continuous functions from `α` to `β` inherits a topological `add_monoid`
structure, by using pointwise operations and checking that they are compatible with the uniform
distance.

Implementation note: The material in this section could have been written for `has_lipschitz_mul`
and transported by `@[to_additive]`.  We choose not to do this because this causes a few lemma
names (for example, `coe_mul`) to conflict with later lemma names for normed rings; this is only a
trivial inconvenience, but in any case there are no obvious applications of the multiplicative
version. -/
variable [TopologicalSpace α] [PseudoMetricSpace β] [AddMonoid β]

variable [HasLipschitzAdd β]

variable (f g : α →ᵇ β) {x : α} {C : ℝ}

/-- The pointwise sum of two bounded continuous functions is again bounded continuous. -/
instance :
    Add
      (α →ᵇ
        β) where add f g :=
    BoundedContinuousFunction.mkOfBound (f.toContinuousMap + g.toContinuousMap)
      (↑(HasLipschitzAdd.c β) * max (Classical.choose f.Bounded) (Classical.choose g.Bounded))
      (by
        intro x y
        refine' le_trans (lipschitz_with_lipschitz_const_add ⟨f x, g x⟩ ⟨f y, g y⟩) _
        rw [Prod.dist_eq]
        refine' mul_le_mul_of_nonneg_left _ (HasLipschitzAdd.c β).coe_nonneg
        apply max_le_max
        exact Classical.choose_spec f.bounded x y
        exact Classical.choose_spec g.bounded x y)

@[simp]
protected theorem coe_add : ⇑(f + g) = f + g :=
  rfl
#align bounded_continuous_function.coe_add BoundedContinuousFunction.coe_add

theorem add_apply : (f + g) x = f x + g x :=
  rfl
#align bounded_continuous_function.add_apply BoundedContinuousFunction.add_apply

@[simp]
theorem mk_of_compact_add [CompactSpace α] (f g : C(α, β)) : mkOfCompact (f + g) = mkOfCompact f + mkOfCompact g :=
  rfl
#align bounded_continuous_function.mk_of_compact_add BoundedContinuousFunction.mk_of_compact_add

theorem add_comp_continuous [TopologicalSpace γ] (h : C(γ, α)) :
    (g + f).comp_continuous h = g.comp_continuous h + f.comp_continuous h :=
  rfl
#align bounded_continuous_function.add_comp_continuous BoundedContinuousFunction.add_comp_continuous

@[simp]
theorem coe_nsmul_rec : ∀ n, ⇑(nsmulRec n f) = n • f
  | 0 => by rw [nsmulRec, zero_smul, BoundedContinuousFunction.coe_zero]
  | n + 1 => by rw [nsmulRec, succ_nsmul, BoundedContinuousFunction.coe_add, coe_nsmul_rec]
#align bounded_continuous_function.coe_nsmul_rec BoundedContinuousFunction.coe_nsmul_rec

instance hasNatScalar :
    HasSmul ℕ
      (α →ᵇ
        β) where smul n f :=
    { toContinuousMap := n • f.toContinuousMap,
      map_bounded' := by simpa [coe_nsmul_rec] using (nsmulRec n f).map_bounded' }
#align bounded_continuous_function.has_nat_scalar BoundedContinuousFunction.hasNatScalar

@[simp]
protected theorem coe_nsmul (r : ℕ) (f : α →ᵇ β) : ⇑(r • f) = r • f :=
  rfl
#align bounded_continuous_function.coe_nsmul BoundedContinuousFunction.coe_nsmul

@[simp]
theorem nsmul_apply (r : ℕ) (f : α →ᵇ β) (v : α) : (r • f) v = r • f v :=
  rfl
#align bounded_continuous_function.nsmul_apply BoundedContinuousFunction.nsmul_apply

instance : AddMonoid (α →ᵇ β) :=
  FunLike.coe_injective.AddMonoid _ BoundedContinuousFunction.coe_zero BoundedContinuousFunction.coe_add fun _ _ =>
    BoundedContinuousFunction.coe_nsmul _ _

instance :
    HasLipschitzAdd (α →ᵇ β) where lipschitz_add :=
    ⟨HasLipschitzAdd.c β, by
      have C_nonneg := (HasLipschitzAdd.c β).coe_nonneg
      rw [lipschitz_with_iff_dist_le_mul]
      rintro ⟨f₁, g₁⟩ ⟨f₂, g₂⟩
      rw [dist_le (mul_nonneg C_nonneg dist_nonneg)]
      intro x
      refine' le_trans (lipschitz_with_lipschitz_const_add ⟨f₁ x, g₁ x⟩ ⟨f₂ x, g₂ x⟩) _
      refine' mul_le_mul_of_nonneg_left _ C_nonneg
      apply max_le_max <;> exact dist_coe_le_dist x⟩

/-- Coercion of a `normed_add_group_hom` is an `add_monoid_hom`. Similar to
`add_monoid_hom.coe_fn`. -/
@[simps]
def coeFnAddHom : (α →ᵇ β) →+ α → β where
  toFun := coeFn
  map_zero' := BoundedContinuousFunction.coe_zero
  map_add' := BoundedContinuousFunction.coe_add
#align bounded_continuous_function.coe_fn_add_hom BoundedContinuousFunction.coeFnAddHom

variable (α β)

/-- The additive map forgetting that a bounded continuous function is bounded.
-/
@[simps]
def toContinuousMapAddHom : (α →ᵇ β) →+ C(α, β) where
  toFun := toContinuousMap
  map_zero' := by
    ext
    simp
  map_add' := by
    intros
    ext
    simp
#align bounded_continuous_function.to_continuous_map_add_hom BoundedContinuousFunction.toContinuousMapAddHom

end HasLipschitzAdd

section CommHasLipschitzAdd

variable [TopologicalSpace α] [PseudoMetricSpace β] [AddCommMonoid β] [HasLipschitzAdd β]

@[to_additive]
instance : AddCommMonoid (α →ᵇ β) :=
  { BoundedContinuousFunction.addMonoid with add_comm := fun f g => by ext <;> simp [add_comm] }

open BigOperators

@[simp]
theorem coe_sum {ι : Type _} (s : Finset ι) (f : ι → α →ᵇ β) : ⇑(∑ i in s, f i) = ∑ i in s, (f i : α → β) :=
  (@coeFnAddHom α β _ _ _ _).map_sum f s
#align bounded_continuous_function.coe_sum BoundedContinuousFunction.coe_sum

theorem sum_apply {ι : Type _} (s : Finset ι) (f : ι → α →ᵇ β) (a : α) : (∑ i in s, f i) a = ∑ i in s, f i a := by simp
#align bounded_continuous_function.sum_apply BoundedContinuousFunction.sum_apply

end CommHasLipschitzAdd

section NormedAddCommGroup

/- In this section, if β is a normed group, then we show that the space of bounded
continuous functions from α to β inherits a normed group structure, by using
pointwise operations and checking that they are compatible with the uniform distance. -/
variable [TopologicalSpace α] [SeminormedAddCommGroup β]

variable (f g : α →ᵇ β) {x : α} {C : ℝ}

instance : HasNorm (α →ᵇ β) :=
  ⟨fun u => dist u 0⟩

theorem norm_def : ∥f∥ = dist f 0 :=
  rfl
#align bounded_continuous_function.norm_def BoundedContinuousFunction.norm_def

/-- The norm of a bounded continuous function is the supremum of `∥f x∥`.
We use `Inf` to ensure that the definition works if `α` has no elements. -/
theorem norm_eq (f : α →ᵇ β) : ∥f∥ = inf { C : ℝ | 0 ≤ C ∧ ∀ x : α, ∥f x∥ ≤ C } := by
  simp [norm_def, BoundedContinuousFunction.dist_eq]
#align bounded_continuous_function.norm_eq BoundedContinuousFunction.norm_eq

/-- When the domain is non-empty, we do not need the `0 ≤ C` condition in the formula for ∥f∥ as an
`Inf`. -/
theorem norm_eq_of_nonempty [h : Nonempty α] : ∥f∥ = inf { C : ℝ | ∀ x : α, ∥f x∥ ≤ C } := by
  obtain ⟨a⟩ := h
  rw [norm_eq]
  congr
  ext
  simp only [and_iff_right_iff_imp]
  exact fun h' => le_trans (norm_nonneg (f a)) (h' a)
#align bounded_continuous_function.norm_eq_of_nonempty BoundedContinuousFunction.norm_eq_of_nonempty

@[simp]
theorem norm_eq_zero_of_empty [h : IsEmpty α] : ∥f∥ = 0 :=
  dist_zero_of_empty
#align bounded_continuous_function.norm_eq_zero_of_empty BoundedContinuousFunction.norm_eq_zero_of_empty

theorem norm_coe_le_norm (x : α) : ∥f x∥ ≤ ∥f∥ :=
  calc
    ∥f x∥ = dist (f x) ((0 : α →ᵇ β) x) := by simp [dist_zero_right]
    _ ≤ ∥f∥ := dist_coe_le_dist _
    
#align bounded_continuous_function.norm_coe_le_norm BoundedContinuousFunction.norm_coe_le_norm

theorem dist_le_two_norm' {f : γ → β} {C : ℝ} (hC : ∀ x, ∥f x∥ ≤ C) (x y : γ) : dist (f x) (f y) ≤ 2 * C :=
  calc
    dist (f x) (f y) ≤ ∥f x∥ + ∥f y∥ := dist_le_norm_add_norm _ _
    _ ≤ C + C := add_le_add (hC x) (hC y)
    _ = 2 * C := (two_mul _).symm
    
#align bounded_continuous_function.dist_le_two_norm' BoundedContinuousFunction.dist_le_two_norm'

/-- Distance between the images of any two points is at most twice the norm of the function. -/
theorem dist_le_two_norm (x y : α) : dist (f x) (f y) ≤ 2 * ∥f∥ :=
  dist_le_two_norm' f.norm_coe_le_norm x y
#align bounded_continuous_function.dist_le_two_norm BoundedContinuousFunction.dist_le_two_norm

variable {f}

/-- The norm of a function is controlled by the supremum of the pointwise norms -/
theorem norm_le (C0 : (0 : ℝ) ≤ C) : ∥f∥ ≤ C ↔ ∀ x : α, ∥f x∥ ≤ C := by simpa using @dist_le _ _ _ _ f 0 _ C0
#align bounded_continuous_function.norm_le BoundedContinuousFunction.norm_le

theorem norm_le_of_nonempty [Nonempty α] {f : α →ᵇ β} {M : ℝ} : ∥f∥ ≤ M ↔ ∀ x, ∥f x∥ ≤ M := by
  simp_rw [norm_def, ← dist_zero_right]
  exact dist_le_iff_of_nonempty
#align bounded_continuous_function.norm_le_of_nonempty BoundedContinuousFunction.norm_le_of_nonempty

theorem norm_lt_iff_of_compact [CompactSpace α] {f : α →ᵇ β} {M : ℝ} (M0 : 0 < M) : ∥f∥ < M ↔ ∀ x, ∥f x∥ < M := by
  simp_rw [norm_def, ← dist_zero_right]
  exact dist_lt_iff_of_compact M0
#align bounded_continuous_function.norm_lt_iff_of_compact BoundedContinuousFunction.norm_lt_iff_of_compact

theorem norm_lt_iff_of_nonempty_compact [Nonempty α] [CompactSpace α] {f : α →ᵇ β} {M : ℝ} : ∥f∥ < M ↔ ∀ x, ∥f x∥ < M :=
  by
  simp_rw [norm_def, ← dist_zero_right]
  exact dist_lt_iff_of_nonempty_compact
#align
  bounded_continuous_function.norm_lt_iff_of_nonempty_compact BoundedContinuousFunction.norm_lt_iff_of_nonempty_compact

variable (f)

/-- Norm of `const α b` is less than or equal to `∥b∥`. If `α` is nonempty,
then it is equal to `∥b∥`. -/
theorem norm_const_le (b : β) : ∥const α b∥ ≤ ∥b∥ :=
  (norm_le (norm_nonneg b)).2 $ fun x => le_rfl
#align bounded_continuous_function.norm_const_le BoundedContinuousFunction.norm_const_le

@[simp]
theorem norm_const_eq [h : Nonempty α] (b : β) : ∥const α b∥ = ∥b∥ :=
  le_antisymm (norm_const_le b) $ h.elim $ fun x => (const α b).norm_coe_le_norm x
#align bounded_continuous_function.norm_const_eq BoundedContinuousFunction.norm_const_eq

/-- Constructing a bounded continuous function from a uniformly bounded continuous
function taking values in a normed group. -/
def ofNormedAddCommGroup {α : Type u} {β : Type v} [TopologicalSpace α] [SeminormedAddCommGroup β] (f : α → β)
    (Hf : Continuous f) (C : ℝ) (H : ∀ x, ∥f x∥ ≤ C) : α →ᵇ β :=
  ⟨⟨fun n => f n, Hf⟩, ⟨_, dist_le_two_norm' H⟩⟩
#align bounded_continuous_function.of_normed_add_comm_group BoundedContinuousFunction.ofNormedAddCommGroup

@[simp]
theorem coe_of_normed_add_comm_group {α : Type u} {β : Type v} [TopologicalSpace α] [SeminormedAddCommGroup β]
    (f : α → β) (Hf : Continuous f) (C : ℝ) (H : ∀ x, ∥f x∥ ≤ C) : (ofNormedAddCommGroup f Hf C H : α → β) = f :=
  rfl
#align bounded_continuous_function.coe_of_normed_add_comm_group BoundedContinuousFunction.coe_of_normed_add_comm_group

theorem norm_of_normed_add_comm_group_le {f : α → β} (hfc : Continuous f) {C : ℝ} (hC : 0 ≤ C) (hfC : ∀ x, ∥f x∥ ≤ C) :
    ∥ofNormedAddCommGroup f hfc C hfC∥ ≤ C :=
  (norm_le hC).2 hfC
#align
  bounded_continuous_function.norm_of_normed_add_comm_group_le BoundedContinuousFunction.norm_of_normed_add_comm_group_le

/-- Constructing a bounded continuous function from a uniformly bounded
function on a discrete space, taking values in a normed group -/
def ofNormedAddCommGroupDiscrete {α : Type u} {β : Type v} [TopologicalSpace α] [DiscreteTopology α]
    [SeminormedAddCommGroup β] (f : α → β) (C : ℝ) (H : ∀ x, norm (f x) ≤ C) : α →ᵇ β :=
  ofNormedAddCommGroup f continuous_of_discrete_topology C H
#align
  bounded_continuous_function.of_normed_add_comm_group_discrete BoundedContinuousFunction.ofNormedAddCommGroupDiscrete

@[simp]
theorem coe_of_normed_add_comm_group_discrete {α : Type u} {β : Type v} [TopologicalSpace α] [DiscreteTopology α]
    [SeminormedAddCommGroup β] (f : α → β) (C : ℝ) (H : ∀ x, ∥f x∥ ≤ C) :
    (ofNormedAddCommGroupDiscrete f C H : α → β) = f :=
  rfl
#align
  bounded_continuous_function.coe_of_normed_add_comm_group_discrete BoundedContinuousFunction.coe_of_normed_add_comm_group_discrete

/-- Taking the pointwise norm of a bounded continuous function with values in a
`seminormed_add_comm_group` yields a bounded continuous function with values in ℝ. -/
def normComp : α →ᵇ ℝ :=
  f.comp norm lipschitzWithOneNorm
#align bounded_continuous_function.norm_comp BoundedContinuousFunction.normComp

@[simp]
theorem coe_norm_comp : (f.normComp : α → ℝ) = norm ∘ f :=
  rfl
#align bounded_continuous_function.coe_norm_comp BoundedContinuousFunction.coe_norm_comp

@[simp]
theorem norm_norm_comp : ∥f.normComp∥ = ∥f∥ := by simp only [norm_eq, coe_norm_comp, norm_norm]
#align bounded_continuous_function.norm_norm_comp BoundedContinuousFunction.norm_norm_comp

theorem bdd_above_range_norm_comp : BddAbove $ Set.range $ norm ∘ f :=
  (Real.bounded_iff_bdd_below_bdd_above.mp $ @boundedRange _ _ _ _ f.normComp).2
#align bounded_continuous_function.bdd_above_range_norm_comp BoundedContinuousFunction.bdd_above_range_norm_comp

theorem norm_eq_supr_norm : ∥f∥ = ⨆ x : α, ∥f x∥ := by
  simp_rw [norm_def, dist_eq_supr, BoundedContinuousFunction.coe_zero, Pi.zero_apply, dist_zero_right]
#align bounded_continuous_function.norm_eq_supr_norm BoundedContinuousFunction.norm_eq_supr_norm

/-- If `∥(1 : β)∥ = 1`, then `∥(1 : α →ᵇ β)∥ = 1` if `α` is nonempty. -/
instance [Nonempty α] [One β] [NormOneClass β] :
    NormOneClass
      (α →ᵇ
        β) where norm_one := by
    simp only [norm_eq_supr_norm, BoundedContinuousFunction.coe_one, Pi.one_apply, norm_one, csupr_const]

/-- The pointwise opposite of a bounded continuous function is again bounded continuous. -/
instance : Neg (α →ᵇ β) :=
  ⟨fun f =>
    ofNormedAddCommGroup (-f) f.Continuous.neg ∥f∥ $ fun x => trans_rel_right _ (norm_neg _) (f.norm_coe_le_norm x)⟩

/-- The pointwise difference of two bounded continuous functions is again bounded continuous. -/
instance : Sub (α →ᵇ β) :=
  ⟨fun f g =>
    ofNormedAddCommGroup (f - g) (f.Continuous.sub g.Continuous) (∥f∥ + ∥g∥) $ fun x => by
      simp only [sub_eq_add_neg]
      exact
        le_trans (norm_add_le _ _)
          (add_le_add (f.norm_coe_le_norm x) $ trans_rel_right _ (norm_neg _) (g.norm_coe_le_norm x))⟩

@[simp]
protected theorem coe_neg : ⇑(-f) = -f :=
  rfl
#align bounded_continuous_function.coe_neg BoundedContinuousFunction.coe_neg

theorem neg_apply : (-f) x = -f x :=
  rfl
#align bounded_continuous_function.neg_apply BoundedContinuousFunction.neg_apply

@[simp]
protected theorem coe_sub : ⇑(f - g) = f - g :=
  rfl
#align bounded_continuous_function.coe_sub BoundedContinuousFunction.coe_sub

theorem sub_apply : (f - g) x = f x - g x :=
  rfl
#align bounded_continuous_function.sub_apply BoundedContinuousFunction.sub_apply

@[simp]
theorem mk_of_compact_neg [CompactSpace α] (f : C(α, β)) : mkOfCompact (-f) = -mkOfCompact f :=
  rfl
#align bounded_continuous_function.mk_of_compact_neg BoundedContinuousFunction.mk_of_compact_neg

@[simp]
theorem mk_of_compact_sub [CompactSpace α] (f g : C(α, β)) : mkOfCompact (f - g) = mkOfCompact f - mkOfCompact g :=
  rfl
#align bounded_continuous_function.mk_of_compact_sub BoundedContinuousFunction.mk_of_compact_sub

@[simp]
theorem coe_zsmul_rec : ∀ z, ⇑(zsmulRec z f) = z • f
  | Int.ofNat n => by rw [zsmulRec, Int.ofNat_eq_coe, coe_nsmul_rec, coe_nat_zsmul]
  | -[1+ n] => by rw [zsmulRec, zsmul_neg_succ_of_nat, BoundedContinuousFunction.coe_neg, coe_nsmul_rec]
#align bounded_continuous_function.coe_zsmul_rec BoundedContinuousFunction.coe_zsmul_rec

instance hasIntScalar :
    HasSmul ℤ
      (α →ᵇ
        β) where smul n f :=
    { toContinuousMap := n • f.toContinuousMap, map_bounded' := by simpa using (zsmulRec n f).map_bounded' }
#align bounded_continuous_function.has_int_scalar BoundedContinuousFunction.hasIntScalar

@[simp]
protected theorem coe_zsmul (r : ℤ) (f : α →ᵇ β) : ⇑(r • f) = r • f :=
  rfl
#align bounded_continuous_function.coe_zsmul BoundedContinuousFunction.coe_zsmul

@[simp]
theorem zsmul_apply (r : ℤ) (f : α →ᵇ β) (v : α) : (r • f) v = r • f v :=
  rfl
#align bounded_continuous_function.zsmul_apply BoundedContinuousFunction.zsmul_apply

instance : AddCommGroup (α →ᵇ β) :=
  FunLike.coe_injective.AddCommGroup _ BoundedContinuousFunction.coe_zero BoundedContinuousFunction.coe_add
    BoundedContinuousFunction.coe_neg BoundedContinuousFunction.coe_sub
    (fun _ _ => BoundedContinuousFunction.coe_nsmul _ _) fun _ _ => BoundedContinuousFunction.coe_zsmul _ _

instance : SeminormedAddCommGroup (α →ᵇ β) where dist_eq f g := by simp only [norm_eq, dist_eq, dist_eq_norm, sub_apply]

instance {α β} [TopologicalSpace α] [NormedAddCommGroup β] : NormedAddCommGroup (α →ᵇ β) :=
  { BoundedContinuousFunction.seminormedAddCommGroup with }

theorem nnnorm_def : ∥f∥₊ = nndist f 0 :=
  rfl
#align bounded_continuous_function.nnnorm_def BoundedContinuousFunction.nnnorm_def

theorem nnnorm_coe_le_nnnorm (x : α) : ∥f x∥₊ ≤ ∥f∥₊ :=
  norm_coe_le_norm _ _
#align bounded_continuous_function.nnnorm_coe_le_nnnorm BoundedContinuousFunction.nnnorm_coe_le_nnnorm

theorem nndist_le_two_nnnorm (x y : α) : nndist (f x) (f y) ≤ 2 * ∥f∥₊ :=
  dist_le_two_norm _ _ _
#align bounded_continuous_function.nndist_le_two_nnnorm BoundedContinuousFunction.nndist_le_two_nnnorm

/-- The nnnorm of a function is controlled by the supremum of the pointwise nnnorms -/
theorem nnnorm_le (C : ℝ≥0) : ∥f∥₊ ≤ C ↔ ∀ x : α, ∥f x∥₊ ≤ C :=
  norm_le C.Prop
#align bounded_continuous_function.nnnorm_le BoundedContinuousFunction.nnnorm_le

theorem nnnorm_const_le (b : β) : ∥const α b∥₊ ≤ ∥b∥₊ :=
  norm_const_le _
#align bounded_continuous_function.nnnorm_const_le BoundedContinuousFunction.nnnorm_const_le

@[simp]
theorem nnnorm_const_eq [h : Nonempty α] (b : β) : ∥const α b∥₊ = ∥b∥₊ :=
  Subtype.ext $ norm_const_eq _
#align bounded_continuous_function.nnnorm_const_eq BoundedContinuousFunction.nnnorm_const_eq

theorem nnnorm_eq_supr_nnnorm : ∥f∥₊ = ⨆ x : α, ∥f x∥₊ :=
  Subtype.ext $ (norm_eq_supr_norm f).trans $ by simp_rw [Nnreal.coe_supr, coe_nnnorm]
#align bounded_continuous_function.nnnorm_eq_supr_nnnorm BoundedContinuousFunction.nnnorm_eq_supr_nnnorm

theorem abs_diff_coe_le_dist : ∥f x - g x∥ ≤ dist f g := by
  rw [dist_eq_norm]
  exact (f - g).norm_coe_le_norm x
#align bounded_continuous_function.abs_diff_coe_le_dist BoundedContinuousFunction.abs_diff_coe_le_dist

theorem coe_le_coe_add_dist {f g : α →ᵇ ℝ} : f x ≤ g x + dist f g :=
  sub_le_iff_le_add'.1 $ (abs_le.1 $ @dist_coe_le_dist _ _ _ _ f g x).2
#align bounded_continuous_function.coe_le_coe_add_dist BoundedContinuousFunction.coe_le_coe_add_dist

theorem norm_comp_continuous_le [TopologicalSpace γ] (f : α →ᵇ β) (g : C(γ, α)) : ∥f.comp_continuous g∥ ≤ ∥f∥ :=
  ((lipschitzCompContinuous g).dist_le_mul f 0).trans $ by rw [Nnreal.coe_one, one_mul, dist_zero_right]
#align bounded_continuous_function.norm_comp_continuous_le BoundedContinuousFunction.norm_comp_continuous_le

end NormedAddCommGroup

section HasBoundedSmul

/-!
### `has_bounded_smul` (in particular, topological module) structure

In this section, if `β` is a metric space and a `𝕜`-module whose addition and scalar multiplication
are compatible with the metric structure, then we show that the space of bounded continuous
functions from `α` to `β` inherits a so-called `has_bounded_smul` structure (in particular, a
`has_continuous_mul` structure, which is the mathlib formulation of being a topological module), by
using pointwise operations and checking that they are compatible with the uniform distance. -/


variable {𝕜 : Type _} [PseudoMetricSpace 𝕜] [TopologicalSpace α] [PseudoMetricSpace β]

section HasSmul

variable [Zero 𝕜] [Zero β] [HasSmul 𝕜 β] [HasBoundedSmul 𝕜 β]

instance :
    HasSmul 𝕜
      (α →ᵇ β) where smul c f :=
    { toContinuousMap := c • f.toContinuousMap,
      map_bounded' :=
        let ⟨b, hb⟩ := f.Bounded
        ⟨dist c 0 * b, fun x y => by
          refine' (dist_smul_pair c (f x) (f y)).trans _
          refine' mul_le_mul_of_nonneg_left _ dist_nonneg
          exact hb x y⟩ }

@[simp]
theorem coe_smul (c : 𝕜) (f : α →ᵇ β) : ⇑(c • f) = fun x => c • f x :=
  rfl
#align bounded_continuous_function.coe_smul BoundedContinuousFunction.coe_smul

theorem smul_apply (c : 𝕜) (f : α →ᵇ β) (x : α) : (c • f) x = c • f x :=
  rfl
#align bounded_continuous_function.smul_apply BoundedContinuousFunction.smul_apply

instance [HasSmul 𝕜ᵐᵒᵖ β] [IsCentralScalar 𝕜 β] :
    IsCentralScalar 𝕜 (α →ᵇ β) where op_smul_eq_smul _ _ := ext $ fun _ => op_smul_eq_smul _ _

instance : HasBoundedSmul 𝕜 (α →ᵇ β) where
  dist_smul_pair' c f₁ f₂ := by
    rw [dist_le (mul_nonneg dist_nonneg dist_nonneg)]
    intro x
    refine' (dist_smul_pair c (f₁ x) (f₂ x)).trans _
    exact mul_le_mul_of_nonneg_left (dist_coe_le_dist x) dist_nonneg
  dist_pair_smul' c₁ c₂ f := by
    rw [dist_le (mul_nonneg dist_nonneg dist_nonneg)]
    intro x
    refine' (dist_pair_smul c₁ c₂ (f x)).trans _
    convert mul_le_mul_of_nonneg_left (dist_coe_le_dist x) dist_nonneg
    simp

end HasSmul

section MulAction

variable [MonoidWithZero 𝕜] [Zero β] [MulAction 𝕜 β] [HasBoundedSmul 𝕜 β]

instance : MulAction 𝕜 (α →ᵇ β) :=
  FunLike.coe_injective.MulAction _ coe_smul

end MulAction

section DistribMulAction

variable [MonoidWithZero 𝕜] [AddMonoid β] [DistribMulAction 𝕜 β] [HasBoundedSmul 𝕜 β]

variable [HasLipschitzAdd β]

instance : DistribMulAction 𝕜 (α →ᵇ β) :=
  Function.Injective.distribMulAction coeFnAddHom FunLike.coe_injective coe_smul

end DistribMulAction

section Module

variable [Semiring 𝕜] [AddCommMonoid β] [Module 𝕜 β] [HasBoundedSmul 𝕜 β]

variable {f g : α →ᵇ β} {x : α} {C : ℝ}

variable [HasLipschitzAdd β]

instance : Module 𝕜 (α →ᵇ β) :=
  Function.Injective.module _ coeFnAddHom FunLike.coe_injective coe_smul

variable (𝕜)

/-- The evaluation at a point, as a continuous linear map from `α →ᵇ β` to `β`. -/
def evalClm (x : α) : (α →ᵇ β) →L[𝕜] β where
  toFun f := f x
  map_add' f g := add_apply _ _
  map_smul' c f := smul_apply _ _ _
#align bounded_continuous_function.eval_clm BoundedContinuousFunction.evalClm

@[simp]
theorem eval_clm_apply (x : α) (f : α →ᵇ β) : evalClm 𝕜 x f = f x :=
  rfl
#align bounded_continuous_function.eval_clm_apply BoundedContinuousFunction.eval_clm_apply

variable (α β)

/-- The linear map forgetting that a bounded continuous function is bounded. -/
@[simps]
def toContinuousMapLinearMap : (α →ᵇ β) →ₗ[𝕜] C(α, β) where
  toFun := toContinuousMap
  map_smul' f g := rfl
  map_add' c f := rfl
#align bounded_continuous_function.to_continuous_map_linear_map BoundedContinuousFunction.toContinuousMapLinearMap

end Module

end HasBoundedSmul

section NormedSpace

/-!
### Normed space structure

In this section, if `β` is a normed space, then we show that the space of bounded
continuous functions from `α` to `β` inherits a normed space structure, by using
pointwise operations and checking that they are compatible with the uniform distance. -/


variable {𝕜 : Type _}

variable [TopologicalSpace α] [SeminormedAddCommGroup β]

variable {f g : α →ᵇ β} {x : α} {C : ℝ}

instance [NormedField 𝕜] [NormedSpace 𝕜 β] : NormedSpace 𝕜 (α →ᵇ β) :=
  ⟨fun c f => by
    refine' norm_of_normed_add_comm_group_le _ (mul_nonneg (norm_nonneg _) (norm_nonneg _)) _
    exact fun x => trans_rel_right _ (norm_smul _ _) (mul_le_mul_of_nonneg_left (f.norm_coe_le_norm _) (norm_nonneg _))⟩

variable [NontriviallyNormedField 𝕜] [NormedSpace 𝕜 β]

variable [SeminormedAddCommGroup γ] [NormedSpace 𝕜 γ]

variable (α)

-- TODO does this work in the `has_bounded_smul` setting, too?
/-- Postcomposition of bounded continuous functions into a normed module by a continuous linear map is
a continuous linear map.
Upgraded version of `continuous_linear_map.comp_left_continuous`, similar to
`linear_map.comp_left`. -/
protected def _root_.continuous_linear_map.comp_left_continuous_bounded (g : β →L[𝕜] γ) : (α →ᵇ β) →L[𝕜] α →ᵇ γ :=
  LinearMap.mkContinuous
    { toFun := fun f =>
        ofNormedAddCommGroup (g ∘ f) (g.Continuous.comp f.Continuous) (∥g∥ * ∥f∥) fun x =>
          g.le_op_norm_of_le (f.norm_coe_le_norm x),
      map_add' := fun f g => by ext <;> simp, map_smul' := fun c f => by ext <;> simp }
    ∥g∥ fun f => norm_of_normed_add_comm_group_le _ (mul_nonneg (norm_nonneg g) (norm_nonneg f)) _
#align
  bounded_continuous_function._root_.continuous_linear_map.comp_left_continuous_bounded bounded_continuous_function._root_.continuous_linear_map.comp_left_continuous_bounded

@[simp]
theorem _root_.continuous_linear_map.comp_left_continuous_bounded_apply (g : β →L[𝕜] γ) (f : α →ᵇ β) (x : α) :
    (g.compLeftContinuousBounded α f) x = g (f x) :=
  rfl
#align
  bounded_continuous_function._root_.continuous_linear_map.comp_left_continuous_bounded_apply bounded_continuous_function._root_.continuous_linear_map.comp_left_continuous_bounded_apply

end NormedSpace

section NormedRing

/-!
### Normed ring structure

In this section, if `R` is a normed ring, then we show that the space of bounded
continuous functions from `α` to `R` inherits a normed ring structure, by using
pointwise operations and checking that they are compatible with the uniform distance. -/


variable [TopologicalSpace α] {R : Type _}

section NonUnital

section SemiNormed

variable [NonUnitalSemiNormedRing R]

instance :
    Mul
      (α →ᵇ
        R) where mul f g :=
    ofNormedAddCommGroup (f * g) (f.Continuous.mul g.Continuous) (∥f∥ * ∥g∥) $ fun x =>
      le_trans (norm_mul_le (f x) (g x)) $
        mul_le_mul (f.norm_coe_le_norm x) (g.norm_coe_le_norm x) (norm_nonneg _) (norm_nonneg _)

@[simp]
protected theorem coe_mul (f g : α →ᵇ R) : ⇑(f * g) = f * g :=
  rfl
#align bounded_continuous_function.coe_mul BoundedContinuousFunction.coe_mul

theorem mul_apply (f g : α →ᵇ R) (x : α) : (f * g) x = f x * g x :=
  rfl
#align bounded_continuous_function.mul_apply BoundedContinuousFunction.mul_apply

instance : NonUnitalRing (α →ᵇ R) :=
  FunLike.coe_injective.NonUnitalRing _ BoundedContinuousFunction.coe_zero BoundedContinuousFunction.coe_add
    BoundedContinuousFunction.coe_mul BoundedContinuousFunction.coe_neg BoundedContinuousFunction.coe_sub
    (fun _ _ => BoundedContinuousFunction.coe_nsmul _ _) fun _ _ => BoundedContinuousFunction.coe_zsmul _ _

instance : NonUnitalSemiNormedRing (α →ᵇ R) :=
  { BoundedContinuousFunction.seminormedAddCommGroup with
    norm_mul := fun f g => norm_of_normed_add_comm_group_le _ (mul_nonneg (norm_nonneg _) (norm_nonneg _)) _ }

end SemiNormed

instance [NonUnitalNormedRing R] : NonUnitalNormedRing (α →ᵇ R) :=
  { BoundedContinuousFunction.nonUnitalSemiNormedRing, BoundedContinuousFunction.normedAddCommGroup with }

end NonUnital

section SemiNormed

variable [SemiNormedRing R]

@[simp]
theorem coe_npow_rec (f : α →ᵇ R) : ∀ n, ⇑(npowRec n f) = f ^ n
  | 0 => by rw [npowRec, pow_zero, BoundedContinuousFunction.coe_one]
  | n + 1 => by rw [npowRec, pow_succ, BoundedContinuousFunction.coe_mul, coe_npow_rec]
#align bounded_continuous_function.coe_npow_rec BoundedContinuousFunction.coe_npow_rec

instance hasNatPow :
    Pow (α →ᵇ R)
      ℕ where pow f n :=
    { toContinuousMap := f.toContinuousMap ^ n,
      map_bounded' := by simpa [coe_npow_rec] using (npowRec n f).map_bounded' }
#align bounded_continuous_function.has_nat_pow BoundedContinuousFunction.hasNatPow

@[simp]
protected theorem coe_pow (n : ℕ) (f : α →ᵇ R) : ⇑(f ^ n) = f ^ n :=
  rfl
#align bounded_continuous_function.coe_pow BoundedContinuousFunction.coe_pow

@[simp]
theorem pow_apply (n : ℕ) (f : α →ᵇ R) (v : α) : (f ^ n) v = f v ^ n :=
  rfl
#align bounded_continuous_function.pow_apply BoundedContinuousFunction.pow_apply

instance : HasNatCast (α →ᵇ R) :=
  ⟨fun n => BoundedContinuousFunction.const _ n⟩

@[simp, norm_cast]
theorem coe_nat_cast (n : ℕ) : ((n : α →ᵇ R) : α → R) = n :=
  rfl
#align bounded_continuous_function.coe_nat_cast BoundedContinuousFunction.coe_nat_cast

instance : HasIntCast (α →ᵇ R) :=
  ⟨fun n => BoundedContinuousFunction.const _ n⟩

@[simp, norm_cast]
theorem coe_int_cast (n : ℤ) : ((n : α →ᵇ R) : α → R) = n :=
  rfl
#align bounded_continuous_function.coe_int_cast BoundedContinuousFunction.coe_int_cast

instance : Ring (α →ᵇ R) :=
  FunLike.coe_injective.Ring _ BoundedContinuousFunction.coe_zero BoundedContinuousFunction.coe_one
    BoundedContinuousFunction.coe_add BoundedContinuousFunction.coe_mul BoundedContinuousFunction.coe_neg
    BoundedContinuousFunction.coe_sub (fun _ _ => BoundedContinuousFunction.coe_nsmul _ _)
    (fun _ _ => BoundedContinuousFunction.coe_zsmul _ _) (fun _ _ => BoundedContinuousFunction.coe_pow _ _) coe_nat_cast
    coe_int_cast

instance : SemiNormedRing (α →ᵇ R) :=
  { BoundedContinuousFunction.nonUnitalSemiNormedRing with }

end SemiNormed

instance [NormedRing R] : NormedRing (α →ᵇ R) :=
  { BoundedContinuousFunction.nonUnitalNormedRing with }

end NormedRing

section NormedCommRing

/-!
### Normed commutative ring structure

In this section, if `R` is a normed commutative ring, then we show that the space of bounded
continuous functions from `α` to `R` inherits a normed commutative ring structure, by using
pointwise operations and checking that they are compatible with the uniform distance. -/


variable [TopologicalSpace α] {R : Type _}

instance [SemiNormedCommRing R] : CommRing (α →ᵇ R) :=
  { BoundedContinuousFunction.ring with mul_comm := fun f₁ f₂ => ext $ fun x => mul_comm _ _ }

instance [SemiNormedCommRing R] : SemiNormedCommRing (α →ᵇ R) :=
  { BoundedContinuousFunction.commRing, BoundedContinuousFunction.seminormedAddCommGroup with }

instance [NormedCommRing R] : NormedCommRing (α →ᵇ R) :=
  { BoundedContinuousFunction.commRing, BoundedContinuousFunction.normedAddCommGroup with }

end NormedCommRing

section NormedAlgebra

/-!
### Normed algebra structure

In this section, if `γ` is a normed algebra, then we show that the space of bounded
continuous functions from `α` to `γ` inherits a normed algebra structure, by using
pointwise operations and checking that they are compatible with the uniform distance. -/


variable {𝕜 : Type _} [NormedField 𝕜]

variable [TopologicalSpace α] [SeminormedAddCommGroup β] [NormedSpace 𝕜 β]

variable [NormedRing γ] [NormedAlgebra 𝕜 γ]

variable {f g : α →ᵇ γ} {x : α} {c : 𝕜}

/-- `bounded_continuous_function.const` as a `ring_hom`. -/
def c : 𝕜 →+* α →ᵇ γ where
  toFun := fun c : 𝕜 => const α ((algebraMap 𝕜 γ) c)
  map_one' := ext $ fun x => (algebraMap 𝕜 γ).map_one
  map_mul' c₁ c₂ := ext $ fun x => (algebraMap 𝕜 γ).map_mul _ _
  map_zero' := ext $ fun x => (algebraMap 𝕜 γ).map_zero
  map_add' c₁ c₂ := ext $ fun x => (algebraMap 𝕜 γ).map_add _ _
#align bounded_continuous_function.C BoundedContinuousFunction.c

instance : Algebra 𝕜 (α →ᵇ γ) :=
  { BoundedContinuousFunction.module, BoundedContinuousFunction.ring with toRingHom := c,
    commutes' := fun c f => ext $ fun x => Algebra.commutes' _ _,
    smul_def' := fun c f => ext $ fun x => Algebra.smul_def' _ _ }

@[simp]
theorem algebra_map_apply (k : 𝕜) (a : α) : algebraMap 𝕜 (α →ᵇ γ) k a = k • 1 := by
  rw [Algebra.algebra_map_eq_smul_one]
  rfl
#align bounded_continuous_function.algebra_map_apply BoundedContinuousFunction.algebra_map_apply

instance : NormedAlgebra 𝕜 (α →ᵇ γ) :=
  { BoundedContinuousFunction.normedSpace with }

/-!
### Structure as normed module over scalar functions

If `β` is a normed `𝕜`-space, then we show that the space of bounded continuous
functions from `α` to `β` is naturally a module over the algebra of bounded continuous
functions from `α` to `𝕜`. -/


instance hasSmul' : HasSmul (α →ᵇ 𝕜) (α →ᵇ β) :=
  ⟨fun (f : α →ᵇ 𝕜) (g : α →ᵇ β) =>
    ofNormedAddCommGroup (fun x => f x • g x) (f.Continuous.smul g.Continuous) (∥f∥ * ∥g∥) fun x =>
      calc
        ∥f x • g x∥ ≤ ∥f x∥ * ∥g x∥ := NormedSpace.norm_smul_le _ _
        _ ≤ ∥f∥ * ∥g∥ := mul_le_mul (f.norm_coe_le_norm _) (g.norm_coe_le_norm _) (norm_nonneg _) (norm_nonneg _)
        ⟩
#align bounded_continuous_function.has_smul' BoundedContinuousFunction.hasSmul'

instance module' : Module (α →ᵇ 𝕜) (α →ᵇ β) :=
  Module.ofCore $
    { smul := (· • ·), smul_add := fun c f₁ f₂ => ext $ fun x => smul_add _ _ _,
      add_smul := fun c₁ c₂ f => ext $ fun x => add_smul _ _ _,
      mul_smul := fun c₁ c₂ f => ext $ fun x => mul_smul _ _ _, one_smul := fun f => ext $ fun x => one_smul 𝕜 (f x) }
#align bounded_continuous_function.module' BoundedContinuousFunction.module'

theorem norm_smul_le (f : α →ᵇ 𝕜) (g : α →ᵇ β) : ∥f • g∥ ≤ ∥f∥ * ∥g∥ :=
  norm_of_normed_add_comm_group_le _ (mul_nonneg (norm_nonneg _) (norm_nonneg _)) _
#align bounded_continuous_function.norm_smul_le BoundedContinuousFunction.norm_smul_le

/- TODO: When `normed_module` has been added to `normed_space.basic`, the above facts
show that the space of bounded continuous functions from `α` to `β` is naturally a normed
module over the algebra of bounded continuous functions from `α` to `𝕜`. -/
end NormedAlgebra

theorem Nnreal.upper_bound {α : Type _} [TopologicalSpace α] (f : α →ᵇ ℝ≥0) (x : α) : f x ≤ nndist f 0 := by
  have key : nndist (f x) ((0 : α →ᵇ ℝ≥0) x) ≤ nndist f 0 := @dist_coe_le_dist α ℝ≥0 _ _ f 0 x
  simp only [BoundedContinuousFunction.coe_zero, Pi.zero_apply] at key
  rwa [Nnreal.nndist_zero_eq_val' (f x)] at key
#align bounded_continuous_function.nnreal.upper_bound BoundedContinuousFunction.Nnreal.upper_bound

/-!
### Star structures

In this section, if `β` is a normed ⋆-group, then so is the space of bounded
continuous functions from `α` to `β`, by using the star operation pointwise.

If `𝕜` is normed field and a ⋆-ring over which `β` is a normed algebra and a
star module, then the space of bounded continuous functions from `α` to `β`
is a star module.

If `β` is a ⋆-ring in addition to being a normed ⋆-group, then `α →ᵇ β`
inherits a ⋆-ring structure.

In summary, if `β` is a C⋆-algebra over `𝕜`, then so is  `α →ᵇ β`; note that
completeness is guaranteed when `β` is complete (see
`bounded_continuous_function.complete`). -/


section NormedAddCommGroup

variable {𝕜 : Type _} [NormedField 𝕜] [StarRing 𝕜] [TopologicalSpace α] [SeminormedAddCommGroup β] [StarAddMonoid β]
  [NormedStarGroup β]

variable [NormedSpace 𝕜 β] [StarModule 𝕜 β]

instance : StarAddMonoid (α →ᵇ β) where
  star f := f.comp star starNormedAddGroupHom.lipschitz
  star_involutive f := ext $ fun x => star_star (f x)
  star_add f g := ext $ fun x => star_add (f x) (g x)

/-- The right-hand side of this equality can be parsed `star ∘ ⇑f` because of the
instance `pi.has_star`. Upon inspecting the goal, one sees `⊢ ⇑(star f) = star ⇑f`.-/
@[simp]
theorem coe_star (f : α →ᵇ β) : ⇑(star f) = star f :=
  rfl
#align bounded_continuous_function.coe_star BoundedContinuousFunction.coe_star

@[simp]
theorem star_apply (f : α →ᵇ β) (x : α) : star f x = star (f x) :=
  rfl
#align bounded_continuous_function.star_apply BoundedContinuousFunction.star_apply

instance : NormedStarGroup (α →ᵇ β) where norm_star f := by simp only [norm_eq, star_apply, norm_star]

instance : StarModule 𝕜 (α →ᵇ β) where star_smul k f := ext $ fun x => star_smul k (f x)

end NormedAddCommGroup

section CstarRing

variable [TopologicalSpace α]

variable [NonUnitalNormedRing β] [StarRing β]

instance [NormedStarGroup β] : StarRing (α →ᵇ β) :=
  { BoundedContinuousFunction.starAddMonoid with star_mul := fun f g => ext $ fun x => star_mul (f x) (g x) }

variable [CstarRing β]

instance :
    CstarRing (α →ᵇ β) where norm_star_mul_self := by
    intro f
    refine' le_antisymm _ _
    · rw [← sq, norm_le (sq_nonneg _)]
      dsimp [star_apply]
      intro x
      rw [CstarRing.norm_star_mul_self, ← sq]
      refine' sq_le_sq' _ _
      · linarith [norm_nonneg (f x), norm_nonneg f]
        
      · exact norm_coe_le_norm f x
        
      
    · rw [← sq, ← Real.le_sqrt (norm_nonneg _) (norm_nonneg _), norm_le (Real.sqrt_nonneg _)]
      intro x
      rw [Real.le_sqrt (norm_nonneg _) (norm_nonneg _), sq, ← CstarRing.norm_star_mul_self]
      exact norm_coe_le_norm (star f * f) x
      

end CstarRing

section NormedLatticeOrderedGroup

variable [TopologicalSpace α] [NormedLatticeAddCommGroup β]

instance : PartialOrder (α →ᵇ β) :=
  PartialOrder.lift (fun f => f.toFun) (by tidy)

/-- Continuous normed lattice group valued functions form a meet-semilattice
-/
instance : SemilatticeInf (α →ᵇ β) :=
  { BoundedContinuousFunction.partialOrder with
    inf := fun f g =>
      { toFun := fun t => f t ⊓ g t, continuous_to_fun := f.Continuous.inf g.Continuous,
        map_bounded' := by
          obtain ⟨C₁, hf⟩ := f.bounded
          obtain ⟨C₂, hg⟩ := g.bounded
          refine' ⟨C₁ + C₂, fun x y => _⟩
          simp_rw [NormedAddCommGroup.dist_eq] at hf hg⊢
          exact (norm_inf_sub_inf_le_add_norm _ _ _ _).trans (add_le_add (hf _ _) (hg _ _)) },
    inf_le_left := fun f g => ContinuousMap.le_def.mpr fun _ => inf_le_left,
    inf_le_right := fun f g => ContinuousMap.le_def.mpr fun _ => inf_le_right,
    le_inf := fun f g₁ g₂ w₁ w₂ =>
      ContinuousMap.le_def.mpr fun _ => le_inf (ContinuousMap.le_def.mp w₁ _) (ContinuousMap.le_def.mp w₂ _) }

instance : SemilatticeSup (α →ᵇ β) :=
  { BoundedContinuousFunction.partialOrder with
    sup := fun f g =>
      { toFun := fun t => f t ⊔ g t, continuous_to_fun := f.Continuous.sup g.Continuous,
        map_bounded' := by
          obtain ⟨C₁, hf⟩ := f.bounded
          obtain ⟨C₂, hg⟩ := g.bounded
          refine' ⟨C₁ + C₂, fun x y => _⟩
          simp_rw [NormedAddCommGroup.dist_eq] at hf hg⊢
          exact (norm_sup_sub_sup_le_add_norm _ _ _ _).trans (add_le_add (hf _ _) (hg _ _)) },
    le_sup_left := fun f g => ContinuousMap.le_def.mpr fun _ => le_sup_left,
    le_sup_right := fun f g => ContinuousMap.le_def.mpr fun _ => le_sup_right,
    sup_le := fun f g₁ g₂ w₁ w₂ =>
      ContinuousMap.le_def.mpr fun _ => sup_le (ContinuousMap.le_def.mp w₁ _) (ContinuousMap.le_def.mp w₂ _) }

instance : Lattice (α →ᵇ β) :=
  { BoundedContinuousFunction.semilatticeSup, BoundedContinuousFunction.semilatticeInf with }

@[simp]
theorem coe_fn_sup (f g : α →ᵇ β) : ⇑(f ⊔ g) = f ⊔ g :=
  rfl
#align bounded_continuous_function.coe_fn_sup BoundedContinuousFunction.coe_fn_sup

@[simp]
theorem coe_fn_abs (f : α →ᵇ β) : ⇑|f| = |f| :=
  rfl
#align bounded_continuous_function.coe_fn_abs BoundedContinuousFunction.coe_fn_abs

instance : NormedLatticeAddCommGroup (α →ᵇ β) :=
  { BoundedContinuousFunction.lattice, BoundedContinuousFunction.seminormedAddCommGroup with
    add_le_add_left := by
      intro f g h₁ h t
      simp only [coe_to_continuous_fun, Pi.add_apply, add_le_add_iff_left, BoundedContinuousFunction.coe_add,
        ContinuousMap.to_fun_eq_coe]
      exact h₁ _,
    solid := by
      intro f g h
      have i1 : ∀ t, ∥f t∥ ≤ ∥g t∥ := fun t => solid (h t)
      rw [norm_le (norm_nonneg _)]
      exact fun t => (i1 t).trans (norm_coe_le_norm g t) }

end NormedLatticeOrderedGroup

section NonnegativePart

variable [TopologicalSpace α]

/-- The nonnegative part of a bounded continuous `ℝ`-valued function as a bounded
continuous `ℝ≥0`-valued function. -/
def nnrealPart (f : α →ᵇ ℝ) : α →ᵇ ℝ≥0 :=
  BoundedContinuousFunction.comp _ (show LipschitzWith 1 Real.toNnreal from lipschitzWithPos) f
#align bounded_continuous_function.nnreal_part BoundedContinuousFunction.nnrealPart

@[simp]
theorem nnreal_part_coe_fun_eq (f : α →ᵇ ℝ) : ⇑f.nnrealPart = Real.toNnreal ∘ ⇑f :=
  rfl
#align bounded_continuous_function.nnreal_part_coe_fun_eq BoundedContinuousFunction.nnreal_part_coe_fun_eq

/-- The absolute value of a bounded continuous `ℝ`-valued function as a bounded
continuous `ℝ≥0`-valued function. -/
def nnnorm (f : α →ᵇ ℝ) : α →ᵇ ℝ≥0 :=
  BoundedContinuousFunction.comp _ (show LipschitzWith 1 fun x : ℝ => ∥x∥₊ from lipschitzWithOneNorm) f
#align bounded_continuous_function.nnnorm BoundedContinuousFunction.nnnorm

@[simp]
theorem nnnorm_coe_fun_eq (f : α →ᵇ ℝ) : ⇑f.nnnorm = HasNnnorm.nnnorm ∘ ⇑f :=
  rfl
#align bounded_continuous_function.nnnorm_coe_fun_eq BoundedContinuousFunction.nnnorm_coe_fun_eq

/-- Decompose a bounded continuous function to its positive and negative parts. -/
theorem self_eq_nnreal_part_sub_nnreal_part_neg (f : α →ᵇ ℝ) : ⇑f = coe ∘ f.nnrealPart - coe ∘ (-f).nnrealPart := by
  funext x
  dsimp
  simp only [max_zero_sub_max_neg_zero_eq_self]
#align
  bounded_continuous_function.self_eq_nnreal_part_sub_nnreal_part_neg BoundedContinuousFunction.self_eq_nnreal_part_sub_nnreal_part_neg

/-- Express the absolute value of a bounded continuous function in terms of its
positive and negative parts. -/
theorem abs_self_eq_nnreal_part_add_nnreal_part_neg (f : α →ᵇ ℝ) :
    abs ∘ ⇑f = coe ∘ f.nnrealPart + coe ∘ (-f).nnrealPart := by
  funext x
  dsimp
  simp only [max_zero_add_max_neg_zero_eq_abs_self]
#align
  bounded_continuous_function.abs_self_eq_nnreal_part_add_nnreal_part_neg BoundedContinuousFunction.abs_self_eq_nnreal_part_add_nnreal_part_neg

end NonnegativePart

end BoundedContinuousFunction

