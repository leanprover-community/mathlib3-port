/-
Copyright (c) 2020 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel, Jireh Loreaux

! This file was ported from Lean 3 source module analysis.normed_space.pi_Lp
! leanprover-community/mathlib commit 26f081a2fb920140ed5bc5cc5344e84bcc7cb2b2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.MeanInequalities
import Mathbin.Data.Fintype.Order

/-!
# `L^p` distance on finite products of metric spaces
Given finitely many metric spaces, one can put the max distance on their product, but there is also
a whole family of natural distances, indexed by a parameter `p : ℝ≥0∞`, that also induce
the product topology. We define them in this file. For `0 < p < ∞`, the distance on `Π i, α i`
is given by
$$
d(x, y) = \left(\sum d(x_i, y_i)^p\right)^{1/p}.
$$,
whereas for `p = 0` it is the cardinality of the set ${ i | x_i ≠ y_i}$. For `p = ∞` the distance
is the supremum of the distances.

We give instances of this construction for emetric spaces, metric spaces, normed groups and normed
spaces.

To avoid conflicting instances, all these are defined on a copy of the original Π-type, named
`pi_Lp p α`. The assumpion `[fact (1 ≤ p)]` is required for the metric and normed space instances.

We ensure that the topology, bornology and uniform structure on `pi_Lp p α` are (defeq to) the
product topology, product bornology and product uniformity, to be able to use freely continuity
statements for the coordinate functions, for instance.

## Implementation notes

We only deal with the `L^p` distance on a product of finitely many metric spaces, which may be
distinct. A closely related construction is `lp`, the `L^p` norm on a product of (possibly
infinitely many) normed spaces, where the norm is
$$
\left(\sum ‖f (x)‖^p \right)^{1/p}.
$$
However, the topology induced by this construction is not the product topology, and some functions
have infinite `L^p` norm. These subtleties are not present in the case of finitely many metric
spaces, hence it is worth devoting a file to this specific case which is particularly well behaved.

Another related construction is `measure_theory.Lp`, the `L^p` norm on the space of functions from
a measure space to a normed space, where the norm is
$$
\left(\int ‖f (x)‖^p dμ\right)^{1/p}.
$$
This has all the same subtleties as `lp`, and the further subtlety that this only
defines a seminorm (as almost everywhere zero functions have zero `L^p` norm).
The construction `pi_Lp` corresponds to the special case of `measure_theory.Lp` in which the basis
is a finite space equipped with the counting measure.

To prove that the topology (and the uniform structure) on a finite product with the `L^p` distance
are the same as those coming from the `L^∞` distance, we could argue that the `L^p` and `L^∞` norms
are equivalent on `ℝ^n` for abstract (norm equivalence) reasons. Instead, we give a more explicit
(easy) proof which provides a comparison between these two norms with explicit constants.

We also set up the theory for `pseudo_emetric_space` and `pseudo_metric_space`.
-/


open Real Set Filter IsROrC Bornology

open BigOperators uniformity TopologicalSpace Nnreal Ennreal

noncomputable section

/-- A copy of a Pi type, on which we will put the `L^p` distance. Since the Pi type itself is
already endowed with the `L^∞` distance, we need the type synonym to avoid confusing typeclass
resolution. Also, we let it depend on `p`, to get a whole family of type on which we can put
different distances. -/
@[nolint unused_arguments]
def PiLp (p : ℝ≥0∞) {ι : Type _} (α : ι → Type _) : Type _ :=
  ∀ i : ι, α i
#align pi_Lp PiLp

instance (p : ℝ≥0∞) {ι : Type _} (α : ι → Type _) [∀ i, Inhabited (α i)] : Inhabited (PiLp p α) :=
  ⟨fun i => default⟩

namespace PiLp

variable (p : ℝ≥0∞) (𝕜 : Type _) {ι : Type _} (α : ι → Type _) (β : ι → Type _)

/-- Canonical bijection between `pi_Lp p α` and the original Pi type. We introduce it to be able
to compare the `L^p` and `L^∞` distances through it. -/
protected def equiv : PiLp p α ≃ ∀ i : ι, α i :=
  Equiv.refl _
#align pi_Lp.equiv PiLp.equiv

/-! Note that the unapplied versions of these lemmas are deliberately omitted, as they break
the use of the type synonym. -/


@[simp]
theorem equiv_apply (x : PiLp p α) (i : ι) : PiLp.equiv p α x i = x i :=
  rfl
#align pi_Lp.equiv_apply PiLp.equiv_apply

@[simp]
theorem equiv_symm_apply (x : ∀ i, α i) (i : ι) : (PiLp.equiv p α).symm x i = x i :=
  rfl
#align pi_Lp.equiv_symm_apply PiLp.equiv_symm_apply

section DistNorm

variable [Fintype ι]

/-!
### Definition of `edist`, `dist` and `norm` on `pi_Lp`

In this section we define the `edist`, `dist` and `norm` functions on `pi_Lp p α` without assuming
`[fact (1 ≤ p)]` or metric properties of the spaces `α i`. This allows us to provide the rewrite
lemmas for each of three cases `p = 0`, `p = ∞` and `0 < p.to_real`.
-/


section Edist

variable [∀ i, HasEdist (β i)]

/-- Endowing the space `pi_Lp p β` with the `L^p` edistance. We register this instance
separate from `pi_Lp.pseudo_emetric` since the latter requires the type class hypothesis
`[fact (1 ≤ p)]` in order to prove the triangle inequality.

Registering this separately allows for a future emetric-like structure on `pi_Lp p β` for `p < 1`
satisfying a relaxed triangle inequality. The terminology for this varies throughout the
literature, but it is sometimes called a *quasi-metric* or *semi-metric*. -/
instance : HasEdist (PiLp p β)
    where edist f g :=
    if hp : p = 0 then { i | f i ≠ g i }.to_finite.toFinset.card
    else
      if p = ∞ then ⨆ i, edist (f i) (g i) else (∑ i, edist (f i) (g i) ^ p.toReal) ^ (1 / p.toReal)

variable {β}

theorem edist_eq_card (f g : PiLp 0 β) : edist f g = { i | f i ≠ g i }.to_finite.toFinset.card :=
  if_pos rfl
#align pi_Lp.edist_eq_card PiLp.edist_eq_card

theorem edist_eq_sum {p : ℝ≥0∞} (hp : 0 < p.toReal) (f g : PiLp p β) :
    edist f g = (∑ i, edist (f i) (g i) ^ p.toReal) ^ (1 / p.toReal) :=
  let hp' := Ennreal.to_real_pos_iff.mp hp
  (if_neg hp'.1.ne').trans (if_neg hp'.2.Ne)
#align pi_Lp.edist_eq_sum PiLp.edist_eq_sum

theorem edist_eq_supr (f g : PiLp ∞ β) : edist f g = ⨆ i, edist (f i) (g i) :=
  by
  dsimp [edist]
  exact if_neg Ennreal.top_ne_zero
#align pi_Lp.edist_eq_supr PiLp.edist_eq_supr

end Edist

section EdistProp

variable {β} [∀ i, PseudoEmetricSpace (β i)]

/-- This holds independent of `p` and does not require `[fact (1 ≤ p)]`. We keep it separate
from `pi_Lp.pseudo_emetric_space` so it can be used also for `p < 1`. -/
protected theorem edist_self (f : PiLp p β) : edist f f = 0 :=
  by
  rcases p.trichotomy with (rfl | rfl | h)
  · simp [edist_eq_card]
  · simp [edist_eq_supr]
  · simp [edist_eq_sum h, Ennreal.zero_rpow_of_pos h, Ennreal.zero_rpow_of_pos (inv_pos.2 <| h)]
#align pi_Lp.edist_self PiLp.edist_self

/-- This holds independent of `p` and does not require `[fact (1 ≤ p)]`. We keep it separate
from `pi_Lp.pseudo_emetric_space` so it can be used also for `p < 1`. -/
protected theorem edist_comm (f g : PiLp p β) : edist f g = edist g f :=
  by
  rcases p.trichotomy with (rfl | rfl | h)
  · simp only [edist_eq_card, eq_comm, Ne.def]
  · simp only [edist_eq_supr, edist_comm]
  · simp only [edist_eq_sum h, edist_comm]
#align pi_Lp.edist_comm PiLp.edist_comm

end EdistProp

section Dist

variable [∀ i, HasDist (α i)]

/-- Endowing the space `pi_Lp p β` with the `L^p` distance. We register this instance
separate from `pi_Lp.pseudo_metric` since the latter requires the type class hypothesis
`[fact (1 ≤ p)]` in order to prove the triangle inequality.

Registering this separately allows for a future metric-like structure on `pi_Lp p β` for `p < 1`
satisfying a relaxed triangle inequality. The terminology for this varies throughout the
literature, but it is sometimes called a *quasi-metric* or *semi-metric*. -/
instance : HasDist (PiLp p α)
    where dist f g :=
    if hp : p = 0 then { i | f i ≠ g i }.to_finite.toFinset.card
    else
      if p = ∞ then ⨆ i, dist (f i) (g i) else (∑ i, dist (f i) (g i) ^ p.toReal) ^ (1 / p.toReal)

variable {α}

theorem dist_eq_card (f g : PiLp 0 α) : dist f g = { i | f i ≠ g i }.to_finite.toFinset.card :=
  if_pos rfl
#align pi_Lp.dist_eq_card PiLp.dist_eq_card

theorem dist_eq_sum {p : ℝ≥0∞} (hp : 0 < p.toReal) (f g : PiLp p α) :
    dist f g = (∑ i, dist (f i) (g i) ^ p.toReal) ^ (1 / p.toReal) :=
  let hp' := Ennreal.to_real_pos_iff.mp hp
  (if_neg hp'.1.ne').trans (if_neg hp'.2.Ne)
#align pi_Lp.dist_eq_sum PiLp.dist_eq_sum

theorem dist_eq_csupr (f g : PiLp ∞ α) : dist f g = ⨆ i, dist (f i) (g i) :=
  by
  dsimp [dist]
  exact if_neg Ennreal.top_ne_zero
#align pi_Lp.dist_eq_csupr PiLp.dist_eq_csupr

end Dist

section Norm

variable [∀ i, HasNorm (β i)] [∀ i, Zero (β i)]

/-- Endowing the space `pi_Lp p β` with the `L^p` norm. We register this instance
separate from `pi_Lp.seminormed_add_comm_group` since the latter requires the type class hypothesis
`[fact (1 ≤ p)]` in order to prove the triangle inequality.

Registering this separately allows for a future norm-like structure on `pi_Lp p β` for `p < 1`
satisfying a relaxed triangle inequality. These are called *quasi-norms*. -/
instance hasNorm : HasNorm (PiLp p β)
    where norm f :=
    if hp : p = 0 then { i | f i ≠ 0 }.to_finite.toFinset.card
    else if p = ∞ then ⨆ i, ‖f i‖ else (∑ i, ‖f i‖ ^ p.toReal) ^ (1 / p.toReal)
#align pi_Lp.has_norm PiLp.hasNorm

variable {p β}

theorem norm_eq_card (f : PiLp 0 β) : ‖f‖ = { i | f i ≠ 0 }.to_finite.toFinset.card :=
  if_pos rfl
#align pi_Lp.norm_eq_card PiLp.norm_eq_card

theorem norm_eq_csupr (f : PiLp ∞ β) : ‖f‖ = ⨆ i, ‖f i‖ :=
  by
  dsimp [norm]
  exact if_neg Ennreal.top_ne_zero
#align pi_Lp.norm_eq_csupr PiLp.norm_eq_csupr

theorem norm_eq_sum (hp : 0 < p.toReal) (f : PiLp p β) :
    ‖f‖ = (∑ i, ‖f i‖ ^ p.toReal) ^ (1 / p.toReal) :=
  let hp' := Ennreal.to_real_pos_iff.mp hp
  (if_neg hp'.1.ne').trans (if_neg hp'.2.Ne)
#align pi_Lp.norm_eq_sum PiLp.norm_eq_sum

end Norm

end DistNorm

section Aux

/-!
### The uniformity on finite `L^p` products is the product uniformity

In this section, we put the `L^p` edistance on `pi_Lp p α`, and we check that the uniformity
coming from this edistance coincides with the product uniformity, by showing that the canonical
map to the Pi type (with the `L^∞` distance) is a uniform embedding, as it is both Lipschitz and
antiLipschitz.

We only register this emetric space structure as a temporary instance, as the true instance (to be
registered later) will have as uniformity exactly the product uniformity, instead of the one coming
from the edistance (which is equal to it, but not defeq). See Note [forgetful inheritance]
explaining why having definitionally the right uniformity is often important.
-/


variable [Fact (1 ≤ p)] [∀ i, PseudoMetricSpace (α i)] [∀ i, PseudoEmetricSpace (β i)]

variable [Fintype ι]

/-- Endowing the space `pi_Lp p β` with the `L^p` pseudoemetric structure. This definition is not
satisfactory, as it does not register the fact that the topology and the uniform structure coincide
with the product one. Therefore, we do not register it as an instance. Using this as a temporary
pseudoemetric space instance, we will show that the uniform structure is equal (but not defeq) to
the product one, and then register an instance in which we replace the uniform structure by the
product one using this pseudoemetric space and `pseudo_emetric_space.replace_uniformity`. -/
def pseudoEmetricAux : PseudoEmetricSpace (PiLp p β)
    where
  edist_self := PiLp.edist_self p
  edist_comm := PiLp.edist_comm p
  edist_triangle f g h := by
    rcases p.dichotomy with (rfl | hp)
    · simp only [edist_eq_supr]
      cases isEmpty_or_nonempty ι
      · simp only [csupᵢ_of_empty, Ennreal.bot_eq_zero, add_zero, nonpos_iff_eq_zero]
      exact
        supᵢ_le fun i => (edist_triangle _ (g i) _).trans <| add_le_add (le_supᵢ _ i) (le_supᵢ _ i)
    · simp only [edist_eq_sum (zero_lt_one.trans_le hp)]
      calc
        (∑ i, edist (f i) (h i) ^ p.to_real) ^ (1 / p.to_real) ≤
            (∑ i, (edist (f i) (g i) + edist (g i) (h i)) ^ p.to_real) ^ (1 / p.to_real) :=
          by
          apply Ennreal.rpow_le_rpow _ (one_div_nonneg.2 <| zero_le_one.trans hp)
          refine' Finset.sum_le_sum fun i hi => _
          exact Ennreal.rpow_le_rpow (edist_triangle _ _ _) (zero_le_one.trans hp)
        _ ≤
            (∑ i, edist (f i) (g i) ^ p.to_real) ^ (1 / p.to_real) +
              (∑ i, edist (g i) (h i) ^ p.to_real) ^ (1 / p.to_real) :=
          Ennreal.Lp_add_le _ _ _ hp
        
#align pi_Lp.pseudo_emetric_aux PiLp.pseudoEmetricAux

attribute [local instance] PiLp.pseudoEmetricAux

/-- An auxiliary lemma used twice in the proof of `pi_Lp.pseudo_metric_aux` below. Not intended for
use outside this file. -/
theorem supr_edist_ne_top_aux {ι : Type _} [Finite ι] {α : ι → Type _}
    [∀ i, PseudoMetricSpace (α i)] (f g : PiLp ∞ α) : (⨆ i, edist (f i) (g i)) ≠ ⊤ :=
  by
  cases nonempty_fintype ι
  obtain ⟨M, hM⟩ := Fintype.exists_le fun i => (⟨dist (f i) (g i), dist_nonneg⟩ : ℝ≥0)
  refine' ne_of_lt ((supᵢ_le fun i => _).trans_lt (@Ennreal.coe_lt_top M))
  simp only [edist, PseudoMetricSpace.edist_dist, Ennreal.of_real_eq_coe_nnreal dist_nonneg]
  exact_mod_cast hM i
#align pi_Lp.supr_edist_ne_top_aux PiLp.supr_edist_ne_top_aux

/-- Endowing the space `pi_Lp p α` with the `L^p` pseudometric structure. This definition is not
satisfactory, as it does not register the fact that the topology, the uniform structure, and the
bornology coincide with the product ones. Therefore, we do not register it as an instance. Using
this as a temporary pseudoemetric space instance, we will show that the uniform structure is equal
(but not defeq) to the product one, and then register an instance in which we replace the uniform
structure and the bornology by the product ones using this pseudometric space,
`pseudo_metric_space.replace_uniformity`, and `pseudo_metric_space.replace_bornology`.

See note [reducible non-instances] -/
@[reducible]
def pseudoMetricAux : PseudoMetricSpace (PiLp p α) :=
  PseudoEmetricSpace.toPseudoMetricSpaceOfDist dist
    (fun f g => by
      rcases p.dichotomy with (rfl | h)
      · exact supr_edist_ne_top_aux f g
      · rw [edist_eq_sum (zero_lt_one.trans_le h)]
        exact
          Ennreal.rpow_ne_top_of_nonneg (one_div_nonneg.2 (zero_le_one.trans h))
            (ne_of_lt <|
              Ennreal.sum_lt_top fun i hi =>
                Ennreal.rpow_ne_top_of_nonneg (zero_le_one.trans h) (edist_ne_top _ _)))
    fun f g => by
    rcases p.dichotomy with (rfl | h)
    · rw [edist_eq_supr, dist_eq_csupr]
      · cases isEmpty_or_nonempty ι
        · simp only [Real.csupr_empty, csupᵢ_of_empty, Ennreal.bot_eq_zero, Ennreal.zero_to_real]
        · refine' le_antisymm (csupᵢ_le fun i => _) _
          · rw [← Ennreal.of_real_le_iff_le_to_real (supr_edist_ne_top_aux f g), ←
              PseudoMetricSpace.edist_dist]
            exact le_supᵢ _ i
          · refine' Ennreal.to_real_le_of_le_of_real (Real.Sup_nonneg _ _) (supᵢ_le fun i => _)
            · rintro - ⟨i, rfl⟩
              exact dist_nonneg
            · unfold edist
              rw [PseudoMetricSpace.edist_dist]
              exact Ennreal.of_real_le_of_real (le_csupᵢ (Fintype.bdd_above_range _) i)
    · have A : ∀ i, edist (f i) (g i) ^ p.to_real ≠ ⊤ := fun i =>
        Ennreal.rpow_ne_top_of_nonneg (zero_le_one.trans h) (edist_ne_top _ _)
      simp only [edist_eq_sum (zero_lt_one.trans_le h), dist_edist, Ennreal.to_real_rpow,
        dist_eq_sum (zero_lt_one.trans_le h), ← Ennreal.to_real_sum fun i _ => A i]
#align pi_Lp.pseudo_metric_aux PiLp.pseudoMetricAux

attribute [local instance] PiLp.pseudoMetricAux

theorem lipschitz_with_equiv_aux : LipschitzWith 1 (PiLp.equiv p β) :=
  by
  intro x y
  rcases p.dichotomy with (rfl | h)
  ·
    simpa only [Ennreal.coe_one, one_mul, edist_eq_supr, edist, Finset.sup_le_iff, Finset.mem_univ,
      forall_true_left] using le_supᵢ fun i => edist (x i) (y i)
  · have cancel : p.to_real * (1 / p.to_real) = 1 := mul_div_cancel' 1 (zero_lt_one.trans_le h).ne'
    rw [edist_eq_sum (zero_lt_one.trans_le h)]
    simp only [edist, forall_prop_of_true, one_mul, Finset.mem_univ, Finset.sup_le_iff,
      Ennreal.coe_one]
    intro i
    calc
      edist (x i) (y i) = (edist (x i) (y i) ^ p.to_real) ^ (1 / p.to_real) := by
        simp [← Ennreal.rpow_mul, cancel, -one_div]
      _ ≤ (∑ i, edist (x i) (y i) ^ p.to_real) ^ (1 / p.to_real) :=
        by
        apply Ennreal.rpow_le_rpow _ (one_div_nonneg.2 <| zero_le_one.trans h)
        exact Finset.single_le_sum (fun i hi => (bot_le : (0 : ℝ≥0∞) ≤ _)) (Finset.mem_univ i)
      
#align pi_Lp.lipschitz_with_equiv_aux PiLp.lipschitz_with_equiv_aux

theorem antilipschitz_with_equiv_aux :
    AntilipschitzWith ((Fintype.card ι : ℝ≥0) ^ (1 / p).toReal) (PiLp.equiv p β) :=
  by
  intro x y
  rcases p.dichotomy with (rfl | h)
  · simp only [edist_eq_supr, Ennreal.div_top, Ennreal.zero_to_real, Nnreal.rpow_zero,
      Ennreal.coe_one, one_mul, supᵢ_le_iff]
    exact fun i => Finset.le_sup (Finset.mem_univ i)
  · have pos : 0 < p.to_real := zero_lt_one.trans_le h
    have nonneg : 0 ≤ 1 / p.to_real := one_div_nonneg.2 (le_of_lt Pos)
    have cancel : p.to_real * (1 / p.to_real) = 1 := mul_div_cancel' 1 (ne_of_gt Pos)
    rw [edist_eq_sum Pos, Ennreal.to_real_div 1 p]
    simp only [edist, ← one_div, Ennreal.one_to_real]
    calc
      (∑ i, edist (x i) (y i) ^ p.to_real) ^ (1 / p.to_real) ≤
          (∑ i, edist (PiLp.equiv p β x) (PiLp.equiv p β y) ^ p.to_real) ^ (1 / p.to_real) :=
        by
        apply Ennreal.rpow_le_rpow _ nonneg
        apply Finset.sum_le_sum fun i hi => _
        apply Ennreal.rpow_le_rpow _ (le_of_lt Pos)
        exact Finset.le_sup (Finset.mem_univ i)
      _ =
          ((Fintype.card ι : ℝ≥0) ^ (1 / p.to_real) : ℝ≥0) *
            edist (PiLp.equiv p β x) (PiLp.equiv p β y) :=
        by
        simp only [nsmul_eq_mul, Finset.card_univ, Ennreal.rpow_one, Finset.sum_const,
          Ennreal.mul_rpow_of_nonneg _ _ nonneg, ← Ennreal.rpow_mul, cancel]
        have : (Fintype.card ι : ℝ≥0∞) = (Fintype.card ι : ℝ≥0) :=
          (Ennreal.coe_nat (Fintype.card ι)).symm
        rw [this, Ennreal.coe_rpow_of_nonneg _ nonneg]
      
#align pi_Lp.antilipschitz_with_equiv_aux PiLp.antilipschitz_with_equiv_aux

theorem aux_uniformity_eq : 𝓤 (PiLp p β) = @uniformity _ (PiCat.uniformSpace _) :=
  by
  have A : UniformInducing (PiLp.equiv p β) :=
    (antilipschitz_with_equiv_aux p β).UniformInducing
      (lipschitz_with_equiv_aux p β).UniformContinuous
  have : (fun x : PiLp p β × PiLp p β => ((PiLp.equiv p β) x.fst, (PiLp.equiv p β) x.snd)) = id :=
    by ext i <;> rfl
  rw [← A.comap_uniformity, this, comap_id]
#align pi_Lp.aux_uniformity_eq PiLp.aux_uniformity_eq

theorem aux_cobounded_eq : cobounded (PiLp p α) = @cobounded _ Pi.bornology :=
  calc
    cobounded (PiLp p α) = comap (PiLp.equiv p α) (cobounded _) :=
      le_antisymm (antilipschitz_with_equiv_aux p α).tendsto_cobounded.le_comap
        (lipschitz_with_equiv_aux p α).comap_cobounded_le
    _ = _ := comap_id
    
#align pi_Lp.aux_cobounded_eq PiLp.aux_cobounded_eq

end Aux

/-! ### Instances on finite `L^p` products -/


instance uniformSpace [∀ i, UniformSpace (β i)] : UniformSpace (PiLp p β) :=
  PiCat.uniformSpace _
#align pi_Lp.uniform_space PiLp.uniformSpace

variable [Fintype ι]

instance bornology [∀ i, Bornology (β i)] : Bornology (PiLp p β) :=
  Pi.bornology
#align pi_Lp.bornology PiLp.bornology

-- throughout the rest of the file, we assume `1 ≤ p`
variable [Fact (1 ≤ p)]

/-- pseudoemetric space instance on the product of finitely many pseudoemetric spaces, using the
`L^p` pseudoedistance, and having as uniformity the product uniformity. -/
instance [∀ i, PseudoEmetricSpace (β i)] : PseudoEmetricSpace (PiLp p β) :=
  (pseudoEmetricAux p β).replaceUniformity (aux_uniformity_eq p β).symm

/-- emetric space instance on the product of finitely many emetric spaces, using the `L^p`
edistance, and having as uniformity the product uniformity. -/
instance [∀ i, EmetricSpace (α i)] : EmetricSpace (PiLp p α) :=
  @Emetric.ofT0PseudoEmetricSpace (PiLp p α) _ Pi.t0_space

/-- pseudometric space instance on the product of finitely many psuedometric spaces, using the
`L^p` distance, and having as uniformity the product uniformity. -/
instance [∀ i, PseudoMetricSpace (β i)] : PseudoMetricSpace (PiLp p β) :=
  ((pseudoMetricAux p β).replaceUniformity (aux_uniformity_eq p β).symm).replaceBornology fun s =>
    Filter.ext_iff.1 (aux_cobounded_eq p β).symm (sᶜ)

/-- metric space instance on the product of finitely many metric spaces, using the `L^p` distance,
and having as uniformity the product uniformity. -/
instance [∀ i, MetricSpace (α i)] : MetricSpace (PiLp p α) :=
  Metric.ofT0PseudoMetricSpace _

theorem nndist_eq_sum {p : ℝ≥0∞} [Fact (1 ≤ p)] {β : ι → Type _} [∀ i, PseudoMetricSpace (β i)]
    (hp : p ≠ ∞) (x y : PiLp p β) :
    nndist x y = (∑ i : ι, nndist (x i) (y i) ^ p.toReal) ^ (1 / p.toReal) :=
  Subtype.ext <| by
    push_cast
    exact dist_eq_sum (p.to_real_pos_iff_ne_top.mpr hp) _ _
#align pi_Lp.nndist_eq_sum PiLp.nndist_eq_sum

theorem nndist_eq_supr {β : ι → Type _} [∀ i, PseudoMetricSpace (β i)] (x y : PiLp ∞ β) :
    nndist x y = ⨆ i, nndist (x i) (y i) :=
  Subtype.ext <| by
    push_cast
    exact dist_eq_csupr _ _
#align pi_Lp.nndist_eq_supr PiLp.nndist_eq_supr

theorem lipschitz_with_equiv [∀ i, PseudoEmetricSpace (β i)] : LipschitzWith 1 (PiLp.equiv p β) :=
  lipschitz_with_equiv_aux p β
#align pi_Lp.lipschitz_with_equiv PiLp.lipschitz_with_equiv

theorem antilipschitz_with_equiv [∀ i, PseudoEmetricSpace (β i)] :
    AntilipschitzWith ((Fintype.card ι : ℝ≥0) ^ (1 / p).toReal) (PiLp.equiv p β) :=
  antilipschitz_with_equiv_aux p β
#align pi_Lp.antilipschitz_with_equiv PiLp.antilipschitz_with_equiv

theorem infty_equiv_isometry [∀ i, PseudoEmetricSpace (β i)] : Isometry (PiLp.equiv ∞ β) :=
  fun x y =>
  le_antisymm (by simpa only [Ennreal.coe_one, one_mul] using lipschitz_with_equiv ∞ β x y)
    (by
      simpa only [Ennreal.div_top, Ennreal.zero_to_real, Nnreal.rpow_zero, Ennreal.coe_one,
        one_mul] using antilipschitz_with_equiv ∞ β x y)
#align pi_Lp.infty_equiv_isometry PiLp.infty_equiv_isometry

variable (p β)

/-- seminormed group instance on the product of finitely many normed groups, using the `L^p`
norm. -/
instance seminormedAddCommGroup [∀ i, SeminormedAddCommGroup (β i)] :
    SeminormedAddCommGroup (PiLp p β) :=
  { Pi.addCommGroup with
    dist_eq := fun x y => by
      rcases p.dichotomy with (rfl | h)
      · simpa only [dist_eq_csupr, norm_eq_csupr, dist_eq_norm]
      · have : p ≠ ∞ := by
          intro hp
          rw [hp, Ennreal.top_to_real] at h
          linarith
        simpa only [dist_eq_sum (zero_lt_one.trans_le h), norm_eq_sum (zero_lt_one.trans_le h),
          dist_eq_norm] }
#align pi_Lp.seminormed_add_comm_group PiLp.seminormedAddCommGroup

/-- normed group instance on the product of finitely many normed groups, using the `L^p` norm. -/
instance normedAddCommGroup [∀ i, NormedAddCommGroup (α i)] : NormedAddCommGroup (PiLp p α) :=
  { PiLp.seminormedAddCommGroup p α with }
#align pi_Lp.normed_add_comm_group PiLp.normedAddCommGroup

theorem nnnorm_eq_sum {p : ℝ≥0∞} [Fact (1 ≤ p)] {β : ι → Type _} (hp : p ≠ ∞)
    [∀ i, SeminormedAddCommGroup (β i)] (f : PiLp p β) :
    ‖f‖₊ = (∑ i, ‖f i‖₊ ^ p.toReal) ^ (1 / p.toReal) :=
  by
  ext
  simp [Nnreal.coe_sum, norm_eq_sum (p.to_real_pos_iff_ne_top.mpr hp)]
#align pi_Lp.nnnorm_eq_sum PiLp.nnnorm_eq_sum

theorem nnnorm_eq_csupr {β : ι → Type _} [∀ i, SeminormedAddCommGroup (β i)] (f : PiLp ∞ β) :
    ‖f‖₊ = ⨆ i, ‖f i‖₊ := by
  ext
  simp [Nnreal.coe_supr, norm_eq_csupr]
#align pi_Lp.nnnorm_eq_csupr PiLp.nnnorm_eq_csupr

theorem norm_eq_of_nat {p : ℝ≥0∞} [Fact (1 ≤ p)] {β : ι → Type _}
    [∀ i, SeminormedAddCommGroup (β i)] (n : ℕ) (h : p = n) (f : PiLp p β) :
    ‖f‖ = (∑ i, ‖f i‖ ^ n) ^ (1 / (n : ℝ)) :=
  by
  have := p.to_real_pos_iff_ne_top.mpr (ne_of_eq_of_ne h <| Ennreal.nat_ne_top n)
  simp only [one_div, h, Real.rpow_nat_cast, Ennreal.to_real_nat, eq_self_iff_true,
    Finset.sum_congr, norm_eq_sum this]
#align pi_Lp.norm_eq_of_nat PiLp.norm_eq_of_nat

theorem norm_eq_of_L2 {β : ι → Type _} [∀ i, SeminormedAddCommGroup (β i)] (x : PiLp 2 β) :
    ‖x‖ = sqrt (∑ i : ι, ‖x i‖ ^ 2) :=
  by
  convert norm_eq_of_nat 2 (by norm_cast) _
  rw [sqrt_eq_rpow]
  norm_cast
#align pi_Lp.norm_eq_of_L2 PiLp.norm_eq_of_L2

theorem nnnorm_eq_of_L2 {β : ι → Type _} [∀ i, SeminormedAddCommGroup (β i)] (x : PiLp 2 β) :
    ‖x‖₊ = Nnreal.sqrt (∑ i : ι, ‖x i‖₊ ^ 2) :=
  Subtype.ext <| by
    push_cast
    exact norm_eq_of_L2 x
#align pi_Lp.nnnorm_eq_of_L2 PiLp.nnnorm_eq_of_L2

theorem norm_sq_eq_of_L2 (β : ι → Type _) [∀ i, SeminormedAddCommGroup (β i)] (x : PiLp 2 β) :
    ‖x‖ ^ 2 = ∑ i : ι, ‖x i‖ ^ 2 :=
  by
  suffices ‖x‖₊ ^ 2 = ∑ i : ι, ‖x i‖₊ ^ 2 by
    simpa only [Nnreal.coe_sum] using congr_arg (coe : ℝ≥0 → ℝ) this
  rw [nnnorm_eq_of_L2, Nnreal.sq_sqrt]
#align pi_Lp.norm_sq_eq_of_L2 PiLp.norm_sq_eq_of_L2

theorem dist_eq_of_L2 {β : ι → Type _} [∀ i, SeminormedAddCommGroup (β i)] (x y : PiLp 2 β) :
    dist x y = (∑ i, dist (x i) (y i) ^ 2).sqrt := by
  simp_rw [dist_eq_norm, norm_eq_of_L2, Pi.sub_apply]
#align pi_Lp.dist_eq_of_L2 PiLp.dist_eq_of_L2

theorem nndist_eq_of_L2 {β : ι → Type _} [∀ i, SeminormedAddCommGroup (β i)] (x y : PiLp 2 β) :
    nndist x y = (∑ i, nndist (x i) (y i) ^ 2).sqrt :=
  Subtype.ext <| by
    push_cast
    exact dist_eq_of_L2 _ _
#align pi_Lp.nndist_eq_of_L2 PiLp.nndist_eq_of_L2

theorem edist_eq_of_L2 {β : ι → Type _} [∀ i, SeminormedAddCommGroup (β i)] (x y : PiLp 2 β) :
    edist x y = (∑ i, edist (x i) (y i) ^ 2) ^ (1 / 2 : ℝ) := by simp [PiLp.edist_eq_sum]
#align pi_Lp.edist_eq_of_L2 PiLp.edist_eq_of_L2

variable [NormedField 𝕜]

/-- The product of finitely many normed spaces is a normed space, with the `L^p` norm. -/
instance normedSpace [∀ i, SeminormedAddCommGroup (β i)] [∀ i, NormedSpace 𝕜 (β i)] :
    NormedSpace 𝕜 (PiLp p β) :=
  { Pi.module ι β 𝕜 with
    norm_smul_le := fun c f => by
      rcases p.dichotomy with (rfl | hp)
      · letI : Module 𝕜 (PiLp ∞ β) := Pi.module ι β 𝕜
        suffices ‖c • f‖₊ = ‖c‖₊ * ‖f‖₊ by exact_mod_cast Nnreal.coe_mono this.le
        simpa only [nnnorm_eq_csupr, Nnreal.mul_supr, ← nnnorm_smul]
      · have : p.to_real * (1 / p.to_real) = 1 := mul_div_cancel' 1 (zero_lt_one.trans_le hp).ne'
        simp only [norm_eq_sum (zero_lt_one.trans_le hp), norm_smul, mul_rpow, norm_nonneg, ←
          Finset.mul_sum, Pi.smul_apply]
        rw [mul_rpow (rpow_nonneg_of_nonneg (norm_nonneg _) _), ← rpow_mul (norm_nonneg _), this,
          rpow_one]
        exact Finset.sum_nonneg fun i hi => rpow_nonneg_of_nonneg (norm_nonneg _) _ }
#align pi_Lp.normed_space PiLp.normedSpace

instance finite_dimensional [∀ i, SeminormedAddCommGroup (β i)] [∀ i, NormedSpace 𝕜 (β i)]
    [I : ∀ i, FiniteDimensional 𝕜 (β i)] : FiniteDimensional 𝕜 (PiLp p β) :=
  FiniteDimensional.finite_dimensional_pi' _ _
#align pi_Lp.finite_dimensional PiLp.finite_dimensional

/- Register simplification lemmas for the applications of `pi_Lp` elements, as the usual lemmas
for Pi types will not trigger. -/
variable {𝕜 p α} [∀ i, SeminormedAddCommGroup (β i)] [∀ i, NormedSpace 𝕜 (β i)] (c : 𝕜)

variable (x y : PiLp p β) (x' y' : ∀ i, β i) (i : ι)

@[simp]
theorem zero_apply : (0 : PiLp p β) i = 0 :=
  rfl
#align pi_Lp.zero_apply PiLp.zero_apply

@[simp]
theorem add_apply : (x + y) i = x i + y i :=
  rfl
#align pi_Lp.add_apply PiLp.add_apply

@[simp]
theorem sub_apply : (x - y) i = x i - y i :=
  rfl
#align pi_Lp.sub_apply PiLp.sub_apply

@[simp]
theorem smul_apply : (c • x) i = c • x i :=
  rfl
#align pi_Lp.smul_apply PiLp.smul_apply

@[simp]
theorem neg_apply : (-x) i = -x i :=
  rfl
#align pi_Lp.neg_apply PiLp.neg_apply

/-- The canonical map `pi_Lp.equiv` between `pi_Lp ∞ β` and `Π i, β i` as a linear isometric
equivalence. -/
def equivₗᵢ : PiLp ∞ β ≃ₗᵢ[𝕜] ∀ i, β i :=
  { PiLp.equiv ∞ β with
    map_add' := fun f g => rfl
    map_smul' := fun c f => rfl
    norm_map' := fun f =>
      by
      suffices (finset.univ.sup fun i => ‖f i‖₊) = ⨆ i, ‖f i‖₊ by
        simpa only [Nnreal.coe_supr] using congr_arg (coe : ℝ≥0 → ℝ) this
      refine'
        antisymm (Finset.sup_le fun i _ => le_csupᵢ (Fintype.bdd_above_range fun i => ‖f i‖₊) _) _
      cases isEmpty_or_nonempty ι
      · simp only [csupᵢ_of_empty, Finset.univ_eq_empty, Finset.sup_empty]
      · exact csupᵢ_le fun i => Finset.le_sup (Finset.mem_univ i) }
#align pi_Lp.equivₗᵢ PiLp.equivₗᵢ

variable {ι' : Type _}

variable [Fintype ι']

variable (p 𝕜) (E : Type _) [NormedAddCommGroup E] [NormedSpace 𝕜 E]

/-- An equivalence of finite domains induces a linearly isometric equivalence of finitely supported
functions-/
def LinearIsometryEquiv.piLpCongrLeft (e : ι ≃ ι') :
    (PiLp p fun i : ι => E) ≃ₗᵢ[𝕜] PiLp p fun i : ι' => E
    where
  toLinearEquiv := LinearEquiv.piCongrLeft' 𝕜 (fun i : ι => E) e
  norm_map' x := by
    rcases p.dichotomy with (rfl | h)
    · simp_rw [norm_eq_csupr, LinearEquiv.Pi_congr_left'_apply 𝕜 (fun i : ι => E) e x _]
      exact e.symm.supr_congr fun i => rfl
    · simp only [norm_eq_sum (zero_lt_one.trans_le h)]
      simp_rw [LinearEquiv.Pi_congr_left'_apply 𝕜 (fun i : ι => E) e x _]
      congr
      exact Fintype.sum_equiv e.symm _ _ fun i => rfl
#align linear_isometry_equiv.pi_Lp_congr_left LinearIsometryEquiv.piLpCongrLeft

variable {p 𝕜 E}

@[simp]
theorem LinearIsometryEquiv.pi_Lp_congr_left_apply (e : ι ≃ ι') (v : PiLp p fun i : ι => E) :
    LinearIsometryEquiv.piLpCongrLeft p 𝕜 E e v = Equiv.piCongrLeft' (fun i : ι => E) e v :=
  rfl
#align linear_isometry_equiv.pi_Lp_congr_left_apply LinearIsometryEquiv.pi_Lp_congr_left_apply

@[simp]
theorem LinearIsometryEquiv.pi_Lp_congr_left_symm (e : ι ≃ ι') :
    (LinearIsometryEquiv.piLpCongrLeft p 𝕜 E e).symm =
      LinearIsometryEquiv.piLpCongrLeft p 𝕜 E e.symm :=
  LinearIsometryEquiv.ext fun x => rfl
#align linear_isometry_equiv.pi_Lp_congr_left_symm LinearIsometryEquiv.pi_Lp_congr_left_symm

@[simp]
theorem LinearIsometryEquiv.pi_Lp_congr_left_single [DecidableEq ι] [DecidableEq ι'] (e : ι ≃ ι')
    (i : ι) (v : E) :
    LinearIsometryEquiv.piLpCongrLeft p 𝕜 E e (Pi.single i v) = Pi.single (e i) v :=
  by
  funext x
  simp [LinearIsometryEquiv.piLpCongrLeft, LinearEquiv.piCongrLeft', Equiv.piCongrLeft', Pi.single,
    Function.update, Equiv.symm_apply_eq]
#align linear_isometry_equiv.pi_Lp_congr_left_single LinearIsometryEquiv.pi_Lp_congr_left_single

@[simp]
theorem equiv_zero : PiLp.equiv p β 0 = 0 :=
  rfl
#align pi_Lp.equiv_zero PiLp.equiv_zero

@[simp]
theorem equiv_symm_zero : (PiLp.equiv p β).symm 0 = 0 :=
  rfl
#align pi_Lp.equiv_symm_zero PiLp.equiv_symm_zero

@[simp]
theorem equiv_add : PiLp.equiv p β (x + y) = PiLp.equiv p β x + PiLp.equiv p β y :=
  rfl
#align pi_Lp.equiv_add PiLp.equiv_add

@[simp]
theorem equiv_symm_add :
    (PiLp.equiv p β).symm (x' + y') = (PiLp.equiv p β).symm x' + (PiLp.equiv p β).symm y' :=
  rfl
#align pi_Lp.equiv_symm_add PiLp.equiv_symm_add

@[simp]
theorem equiv_sub : PiLp.equiv p β (x - y) = PiLp.equiv p β x - PiLp.equiv p β y :=
  rfl
#align pi_Lp.equiv_sub PiLp.equiv_sub

@[simp]
theorem equiv_symm_sub :
    (PiLp.equiv p β).symm (x' - y') = (PiLp.equiv p β).symm x' - (PiLp.equiv p β).symm y' :=
  rfl
#align pi_Lp.equiv_symm_sub PiLp.equiv_symm_sub

@[simp]
theorem equiv_neg : PiLp.equiv p β (-x) = -PiLp.equiv p β x :=
  rfl
#align pi_Lp.equiv_neg PiLp.equiv_neg

@[simp]
theorem equiv_symm_neg : (PiLp.equiv p β).symm (-x') = -(PiLp.equiv p β).symm x' :=
  rfl
#align pi_Lp.equiv_symm_neg PiLp.equiv_symm_neg

@[simp]
theorem equiv_smul : PiLp.equiv p β (c • x) = c • PiLp.equiv p β x :=
  rfl
#align pi_Lp.equiv_smul PiLp.equiv_smul

@[simp]
theorem equiv_symm_smul : (PiLp.equiv p β).symm (c • x') = c • (PiLp.equiv p β).symm x' :=
  rfl
#align pi_Lp.equiv_symm_smul PiLp.equiv_symm_smul

/-- When `p = ∞`, this lemma does not hold without the additional assumption `nonempty ι` because
the left-hand side simplifies to `0`, while the right-hand side simplifies to `‖b‖₊`. See
`pi_Lp.nnnorm_equiv_symm_const'` for a version which exchanges the hypothesis `p ≠ ∞` for
`nonempty ι`. -/
theorem nnnorm_equiv_symm_const {β} [SeminormedAddCommGroup β] (hp : p ≠ ∞) (b : β) :
    ‖(PiLp.equiv p fun _ : ι => β).symm (Function.const _ b)‖₊ =
      Fintype.card ι ^ (1 / p).toReal * ‖b‖₊ :=
  by
  rcases p.dichotomy with (h | h)
  · exact False.elim (hp h)
  · have ne_zero : p.to_real ≠ 0 := (zero_lt_one.trans_le h).ne'
    simp_rw [nnnorm_eq_sum hp, equiv_symm_apply, Function.const_apply, Finset.sum_const,
      Finset.card_univ, nsmul_eq_mul, Nnreal.mul_rpow, ← Nnreal.rpow_mul, mul_one_div_cancel NeZero,
      Nnreal.rpow_one, Ennreal.to_real_div, Ennreal.one_to_real]
#align pi_Lp.nnnorm_equiv_symm_const PiLp.nnnorm_equiv_symm_const

/-- When `is_empty ι`, this lemma does not hold without the additional assumption `p ≠ ∞` because
the left-hand side simplifies to `0`, while the right-hand side simplifies to `‖b‖₊`. See
`pi_Lp.nnnorm_equiv_symm_const` for a version which exchanges the hypothesis `nonempty ι`.
for `p ≠ ∞`. -/
theorem nnnorm_equiv_symm_const' {β} [SeminormedAddCommGroup β] [Nonempty ι] (b : β) :
    ‖(PiLp.equiv p fun _ : ι => β).symm (Function.const _ b)‖₊ =
      Fintype.card ι ^ (1 / p).toReal * ‖b‖₊ :=
  by
  rcases em <| p = ∞ with (rfl | hp)
  ·
    simp only [equiv_symm_apply, Ennreal.div_top, Ennreal.zero_to_real, Nnreal.rpow_zero, one_mul,
      nnnorm_eq_csupr, Function.const_apply, csupᵢ_const]
  · exact nnnorm_equiv_symm_const hp b
#align pi_Lp.nnnorm_equiv_symm_const' PiLp.nnnorm_equiv_symm_const'

/-- When `p = ∞`, this lemma does not hold without the additional assumption `nonempty ι` because
the left-hand side simplifies to `0`, while the right-hand side simplifies to `‖b‖₊`. See
`pi_Lp.norm_equiv_symm_const'` for a version which exchanges the hypothesis `p ≠ ∞` for
`nonempty ι`. -/
theorem norm_equiv_symm_const {β} [SeminormedAddCommGroup β] (hp : p ≠ ∞) (b : β) :
    ‖(PiLp.equiv p fun _ : ι => β).symm (Function.const _ b)‖ =
      Fintype.card ι ^ (1 / p).toReal * ‖b‖ :=
  (congr_arg coe <| nnnorm_equiv_symm_const hp b).trans <| by simp
#align pi_Lp.norm_equiv_symm_const PiLp.norm_equiv_symm_const

/-- When `is_empty ι`, this lemma does not hold without the additional assumption `p ≠ ∞` because
the left-hand side simplifies to `0`, while the right-hand side simplifies to `‖b‖₊`. See
`pi_Lp.norm_equiv_symm_const` for a version which exchanges the hypothesis `nonempty ι`.
for `p ≠ ∞`. -/
theorem norm_equiv_symm_const' {β} [SeminormedAddCommGroup β] [Nonempty ι] (b : β) :
    ‖(PiLp.equiv p fun _ : ι => β).symm (Function.const _ b)‖ =
      Fintype.card ι ^ (1 / p).toReal * ‖b‖ :=
  (congr_arg coe <| nnnorm_equiv_symm_const' b).trans <| by simp
#align pi_Lp.norm_equiv_symm_const' PiLp.norm_equiv_symm_const'

theorem nnnorm_equiv_symm_one {β} [SeminormedAddCommGroup β] (hp : p ≠ ∞) [One β] :
    ‖(PiLp.equiv p fun _ : ι => β).symm 1‖₊ = Fintype.card ι ^ (1 / p).toReal * ‖(1 : β)‖₊ :=
  (nnnorm_equiv_symm_const hp (1 : β)).trans rfl
#align pi_Lp.nnnorm_equiv_symm_one PiLp.nnnorm_equiv_symm_one

theorem norm_equiv_symm_one {β} [SeminormedAddCommGroup β] (hp : p ≠ ∞) [One β] :
    ‖(PiLp.equiv p fun _ : ι => β).symm 1‖ = Fintype.card ι ^ (1 / p).toReal * ‖(1 : β)‖ :=
  (norm_equiv_symm_const hp (1 : β)).trans rfl
#align pi_Lp.norm_equiv_symm_one PiLp.norm_equiv_symm_one

variable (𝕜 p)

/-- `pi_Lp.equiv` as a linear map. -/
@[simps (config := { fullyApplied := false })]
protected def linearEquiv : PiLp p β ≃ₗ[𝕜] ∀ i, β i :=
  { LinearEquiv.refl _ _ with
    toFun := PiLp.equiv _ _
    invFun := (PiLp.equiv _ _).symm }
#align pi_Lp.linear_equiv PiLp.linearEquiv

section Basis

variable (ι)

/-- A version of `pi.basis_fun` for `pi_Lp`. -/
def basisFun : Basis ι 𝕜 (PiLp p fun _ => 𝕜) :=
  Basis.ofEquivFun (PiLp.linearEquiv p 𝕜 fun _ : ι => 𝕜)
#align pi_Lp.basis_fun PiLp.basisFun

@[simp]
theorem basis_fun_apply [DecidableEq ι] (i) :
    basisFun p 𝕜 ι i = (PiLp.equiv p _).symm (Pi.single i 1) :=
  by
  simp_rw [basis_fun, Basis.coe_of_equiv_fun, PiLp.linear_equiv_symm_apply, Pi.single]
  congr
#align pi_Lp.basis_fun_apply PiLp.basis_fun_apply

-- Get rid of a `decidable_eq` mismatch.
@[simp]
theorem basis_fun_repr (x : PiLp p fun i : ι => 𝕜) (i : ι) : (basisFun p 𝕜 ι).repr x i = x i :=
  rfl
#align pi_Lp.basis_fun_repr PiLp.basis_fun_repr

theorem basis_fun_eq_pi_basis_fun :
    basisFun p 𝕜 ι = (Pi.basisFun 𝕜 ι).map (PiLp.linearEquiv p 𝕜 fun _ : ι => 𝕜).symm :=
  rfl
#align pi_Lp.basis_fun_eq_pi_basis_fun PiLp.basis_fun_eq_pi_basis_fun

@[simp]
theorem basis_fun_map :
    (basisFun p 𝕜 ι).map (PiLp.linearEquiv p 𝕜 fun _ : ι => 𝕜) = Pi.basisFun 𝕜 ι :=
  rfl
#align pi_Lp.basis_fun_map PiLp.basis_fun_map

open Matrix

theorem basis_to_matrix_basis_fun_mul (b : Basis ι 𝕜 (PiLp p fun i : ι => 𝕜)) (A : Matrix ι ι 𝕜) :
    b.toMatrix (PiLp.basisFun _ _ _) ⬝ A =
      Matrix.of fun i j => b.repr ((PiLp.equiv _ _).symm (Aᵀ j)) i :=
  by
  have := basis_to_matrix_basis_fun_mul (b.map (PiLp.linearEquiv _ 𝕜 _)) A
  simp_rw [← PiLp.basis_fun_map p, Basis.map_repr, LinearEquiv.trans_apply,
    PiLp.linear_equiv_symm_apply, Basis.to_matrix_map, Function.comp, Basis.map_apply,
    LinearEquiv.symm_apply_apply] at this
  exact this
#align pi_Lp.basis_to_matrix_basis_fun_mul PiLp.basis_to_matrix_basis_fun_mul

end Basis

end PiLp

