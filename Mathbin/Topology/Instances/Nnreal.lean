import Mathbin.Topology.Algebra.InfiniteSum 
import Mathbin.Topology.Algebra.GroupWithZero

/-!
# Topology on `ℝ≥0`

The natural topology on `ℝ≥0` (the one induced from `ℝ`), and a basic API.

## Main definitions

Instances for the following typeclasses are defined:

* `topological_space ℝ≥0`
* `topological_ring ℝ≥0`
* `second_countable_topology ℝ≥0`
* `order_topology ℝ≥0`
* `has_continuous_sub ℝ≥0`
* `has_continuous_inv' ℝ≥0` (continuity of `x⁻¹` away from `0`)
* `has_continuous_smul ℝ≥0 ℝ`

Everything is inherited from the corresponding structures on the reals.

## Main statements

Various mathematically trivial lemmas are proved about the compatibility
of limits and sums in `ℝ≥0` and `ℝ`. For example

* `tendsto_coe {f : filter α} {m : α → ℝ≥0} {x : ℝ≥0} :
  tendsto (λa, (m a : ℝ)) f (𝓝 (x : ℝ)) ↔ tendsto m f (𝓝 x)`

says that the limit of a filter along a map to `ℝ≥0` is the same in `ℝ` and `ℝ≥0`, and

* `coe_tsum {f : α → ℝ≥0} : ((∑'a, f a) : ℝ) = (∑'a, (f a : ℝ))`

says that says that a sum of elements in `ℝ≥0` is the same in `ℝ` and `ℝ≥0`.

Similarly, some mathematically trivial lemmas about infinite sums are proved,
a few of which rely on the fact that subtraction is continuous.

-/


noncomputable theory

open Set TopologicalSpace Metric Filter

open_locale TopologicalSpace

namespace Nnreal

open_locale Nnreal BigOperators Filter

instance  : TopologicalSpace ℝ≥0  :=
  inferInstance

instance  : TopologicalRing ℝ≥0  :=
  { continuous_mul :=
      continuous_subtype_mk _$
        (continuous_subtype_val.comp continuous_fst).mul (continuous_subtype_val.comp continuous_snd),
    continuous_add :=
      continuous_subtype_mk _$
        (continuous_subtype_val.comp continuous_fst).add (continuous_subtype_val.comp continuous_snd) }

instance  : second_countable_topology ℝ≥0  :=
  TopologicalSpace.Subtype.second_countable_topology _ _

instance  : OrderTopology ℝ≥0  :=
  @order_topology_of_ord_connected _ _ _ _ (Ici 0) _

section coeₓ

variable{α : Type _}

open Filter Finset

theorem continuous_of_real : Continuous Real.toNnreal :=
  continuous_subtype_mk _$ continuous_id.max continuous_const

theorem continuous_coe : Continuous (coeₓ :  ℝ≥0  → ℝ) :=
  continuous_subtype_val

@[simp, normCast]
theorem tendsto_coe {f : Filter α} {m : α →  ℝ≥0 } {x :  ℝ≥0 } :
  tendsto (fun a => (m a : ℝ)) f (𝓝 (x : ℝ)) ↔ tendsto m f (𝓝 x) :=
  tendsto_subtype_rng.symm

theorem tendsto_coe' {f : Filter α} [ne_bot f] {m : α →  ℝ≥0 } {x : ℝ} :
  tendsto (fun a => m a : α → ℝ) f (𝓝 x) ↔ ∃ hx : 0 ≤ x, tendsto m f (𝓝 ⟨x, hx⟩) :=
  ⟨fun h => ⟨ge_of_tendsto' h fun c => (m c).2, tendsto_coe.1 h⟩, fun ⟨hx, hm⟩ => tendsto_coe.2 hm⟩

@[simp]
theorem map_coe_at_top : map (coeₓ :  ℝ≥0  → ℝ) at_top = at_top :=
  map_coe_Ici_at_top 0

theorem comap_coe_at_top : comap (coeₓ :  ℝ≥0  → ℝ) at_top = at_top :=
  (at_top_Ici_eq 0).symm

@[simp, normCast]
theorem tendsto_coe_at_top {f : Filter α} {m : α →  ℝ≥0 } :
  tendsto (fun a => (m a : ℝ)) f at_top ↔ tendsto m f at_top :=
  tendsto_Ici_at_top.symm

theorem tendsto_of_real {f : Filter α} {m : α → ℝ} {x : ℝ} (h : tendsto m f (𝓝 x)) :
  tendsto (fun a => Real.toNnreal (m a)) f (𝓝 (Real.toNnreal x)) :=
  (continuous_of_real.Tendsto _).comp h

theorem nhds_zero : 𝓝 (0 :  ℝ≥0 ) = ⨅(a : _)(_ : a ≠ 0), 𝓟 (Iio a) :=
  nhds_bot_order.trans$
    by 
      simp [bot_lt_iff_ne_bot]

-- error in Topology.Instances.Nnreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem nhds_zero_basis : (expr𝓝() (0 : «exprℝ≥0»())).has_basis (λ a : «exprℝ≥0»(), «expr < »(0, a)) (λ a, Iio a) :=
nhds_bot_basis

instance  : HasContinuousSub ℝ≥0  :=
  ⟨continuous_subtype_mk _$
      ((continuous_coe.comp continuous_fst).sub (continuous_coe.comp continuous_snd)).max continuous_const⟩

instance  : HasContinuousInv₀ ℝ≥0  :=
  ⟨fun x hx => tendsto_coe.1$ (Real.tendsto_inv$ Nnreal.coe_ne_zero.2 hx).comp continuous_coe.ContinuousAt⟩

instance  : HasContinuousSmul ℝ≥0  ℝ :=
  { continuous_smul :=
      Continuous.comp Real.continuous_mul$
        Continuous.prod_mk (Continuous.comp continuous_subtype_val continuous_fst) continuous_snd }

@[normCast]
theorem has_sum_coe {f : α →  ℝ≥0 } {r :  ℝ≥0 } : HasSum (fun a => (f a : ℝ)) (r : ℝ) ↔ HasSum f r :=
  by 
    simp only [HasSum, coe_sum.symm, tendsto_coe]

-- error in Topology.Instances.Nnreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem has_sum_of_real_of_nonneg
{f : α → exprℝ()}
(hf_nonneg : ∀ n, «expr ≤ »(0, f n))
(hf : summable f) : has_sum (λ n, real.to_nnreal (f n)) (real.to_nnreal «expr∑' , »((n), f n)) :=
begin
  have [ident h_sum] [":", expr «expr = »(λ
    s, «expr∑ in , »((b), s, real.to_nnreal (f b)), λ s, real.to_nnreal «expr∑ in , »((b), s, f b))] [],
  from [expr funext (λ _, (real.to_nnreal_sum_of_nonneg (λ n _, hf_nonneg n)).symm)],
  simp_rw ["[", expr has_sum, ",", expr h_sum, "]"] [],
  exact [expr tendsto_of_real hf.has_sum]
end

@[normCast]
theorem summable_coe {f : α →  ℝ≥0 } : (Summable fun a => (f a : ℝ)) ↔ Summable f :=
  by 
    split 
    exact fun ⟨a, ha⟩ => ⟨⟨a, has_sum_le (fun a => (f a).2) has_sum_zero ha⟩, has_sum_coe.1 ha⟩
    exact fun ⟨a, ha⟩ => ⟨a.1, has_sum_coe.2 ha⟩

theorem summable_coe_of_nonneg {f : α → ℝ} (hf₁ : ∀ n, 0 ≤ f n) :
  (@Summable ℝ≥0  _ _ _ fun n => ⟨f n, hf₁ n⟩) ↔ Summable f :=
  by 
    lift f to α →  ℝ≥0  using hf₁ with f rfl hf₁ 
    simp only [summable_coe, Subtype.coe_eta]

open_locale Classical

@[normCast]
theorem coe_tsum {f : α →  ℝ≥0 } : «expr↑ » (∑'a, f a) = ∑'a, (f a : ℝ) :=
  if hf : Summable f then Eq.symm$ (has_sum_coe.2$ hf.has_sum).tsum_eq else
    by 
      simp [tsum, hf, mt summable_coe.1 hf]

theorem coe_tsum_of_nonneg {f : α → ℝ} (hf₁ : ∀ n, 0 ≤ f n) :
  (⟨∑'n, f n, tsum_nonneg hf₁⟩ :  ℝ≥0 ) = (∑'n, ⟨f n, hf₁ n⟩ :  ℝ≥0 ) :=
  by 
    lift f to α →  ℝ≥0  using hf₁ with f rfl hf₁ 
    simpRw [←Nnreal.coe_tsum, Subtype.coe_eta]

theorem tsum_mul_left (a :  ℝ≥0 ) (f : α →  ℝ≥0 ) : (∑'x, a*f x) = a*∑'x, f x :=
  Nnreal.eq$
    by 
      simp only [coe_tsum, Nnreal.coe_mul, tsum_mul_left]

theorem tsum_mul_right (f : α →  ℝ≥0 ) (a :  ℝ≥0 ) : (∑'x, f x*a) = (∑'x, f x)*a :=
  Nnreal.eq$
    by 
      simp only [coe_tsum, Nnreal.coe_mul, tsum_mul_right]

theorem summable_comp_injective {β : Type _} {f : α →  ℝ≥0 } (hf : Summable f) {i : β → α} (hi : Function.Injective i) :
  Summable (f ∘ i) :=
  Nnreal.summable_coe.1$ show Summable ((coeₓ ∘ f) ∘ i) from (Nnreal.summable_coe.2 hf).comp_injective hi

theorem summable_nat_add (f : ℕ →  ℝ≥0 ) (hf : Summable f) (k : ℕ) : Summable fun i => f (i+k) :=
  summable_comp_injective hf$ add_left_injective k

theorem summable_nat_add_iff {f : ℕ →  ℝ≥0 } (k : ℕ) : (Summable fun i => f (i+k)) ↔ Summable f :=
  by 
    rw [←summable_coe, ←summable_coe]
    exact @summable_nat_add_iff ℝ _ _ _ (fun i => (f i : ℝ)) k

theorem has_sum_nat_add_iff {f : ℕ →  ℝ≥0 } (k : ℕ) {a :  ℝ≥0 } :
  HasSum (fun n => f (n+k)) a ↔ HasSum f (a+∑i in range k, f i) :=
  by 
    simp [←has_sum_coe, coe_sum, Nnreal.coe_add, ←has_sum_nat_add_iff k]

theorem sum_add_tsum_nat_add {f : ℕ →  ℝ≥0 } (k : ℕ) (hf : Summable f) :
  (∑'i, f i) = (∑i in range k, f i)+∑'i, f (i+k) :=
  by 
    rw [←Nnreal.coe_eq, coe_tsum, Nnreal.coe_add, coe_sum, coe_tsum, sum_add_tsum_nat_add k (Nnreal.summable_coe.2 hf)]

theorem infi_real_pos_eq_infi_nnreal_pos [CompleteLattice α] {f : ℝ → α} :
  (⨅(n : ℝ)(h : 0 < n), f n) = ⨅(n :  ℝ≥0 )(h : 0 < n), f n :=
  le_antisymmₓ (infi_le_infi2$ fun r => ⟨r, infi_le_infi$ fun hr => le_rfl⟩)
    (le_infi$ fun r => le_infi$ fun hr => infi_le_of_le ⟨r, hr.le⟩$ infi_le _ hr)

end coeₓ

-- error in Topology.Instances.Nnreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tendsto_cofinite_zero_of_summable
{α}
{f : α → «exprℝ≥0»()}
(hf : summable f) : tendsto f cofinite (expr𝓝() 0) :=
begin
  have [ident h_f_coe] [":", expr «expr = »(f, λ n, real.to_nnreal (f n : exprℝ()))] [],
  from [expr funext (λ n, real.to_nnreal_coe.symm)],
  rw ["[", expr h_f_coe, ",", "<-", expr @real.to_nnreal_coe 0, "]"] [],
  exact [expr tendsto_of_real (summable_coe.mpr hf).tendsto_cofinite_zero]
end

theorem tendsto_at_top_zero_of_summable {f : ℕ →  ℝ≥0 } (hf : Summable f) : tendsto f at_top (𝓝 0) :=
  by 
    rw [←Nat.cofinite_eq_at_top]
    exact tendsto_cofinite_zero_of_summable hf

-- error in Topology.Instances.Nnreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The sum over the complement of a finset tends to `0` when the finset grows to cover the whole
space. This does not need a summability assumption, as otherwise all sums are zero. -/
theorem tendsto_tsum_compl_at_top_zero
{α : Type*}
(f : α → «exprℝ≥0»()) : tendsto (λ s : finset α, «expr∑' , »((b : {x // «expr ∉ »(x, s)}), f b)) at_top (expr𝓝() 0) :=
begin
  simp_rw ["[", "<-", expr tendsto_coe, ",", expr coe_tsum, ",", expr nnreal.coe_zero, "]"] [],
  exact [expr tendsto_tsum_compl_at_top_zero (λ a : α, (f a : exprℝ()))]
end

end Nnreal

