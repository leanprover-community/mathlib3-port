import Mathbin.Logic.Function.Iterate 
import Mathbin.Data.Set.Intervals.ProjIcc 
import Mathbin.Topology.MetricSpace.Basic 
import Mathbin.CategoryTheory.Endomorphism 
import Mathbin.CategoryTheory.Types

/-!
# Lipschitz continuous functions

A map `f : α → β` between two (extended) metric spaces is called *Lipschitz continuous*
with constant `K ≥ 0` if for all `x, y` we have `edist (f x) (f y) ≤ K * edist x y`.
For a metric space, the latter inequality is equivalent to `dist (f x) (f y) ≤ K * dist x y`.
There is also a version asserting this inequality only for `x` and `y` in some set `s`.

In this file we provide various ways to prove that various combinations of Lipschitz continuous
functions are Lipschitz continuous. We also prove that Lipschitz continuous functions are
uniformly continuous.

## Main definitions and lemmas

* `lipschitz_with K f`: states that `f` is Lipschitz with constant `K : ℝ≥0`
* `lipschitz_on_with K f`: states that `f` is Lipschitz with constant `K : ℝ≥0` on a set `s`
* `lipschitz_with.uniform_continuous`: a Lipschitz function is uniformly continuous
* `lipschitz_on_with.uniform_continuous_on`: a function which is Lipschitz on a set is uniformly
  continuous on that set.


## Implementation notes

The parameter `K` has type `ℝ≥0`. This way we avoid conjuction in the definition and have
coercions both to `ℝ` and `ℝ≥0∞`. Constructors whose names end with `'` take `K : ℝ` as an
argument, and return `lipschitz_with (real.to_nnreal K) f`.
-/


universe u v w x

open Filter Function Set

open_locale TopologicalSpace Nnreal Ennreal

variable{α : Type u}{β : Type v}{γ : Type w}{ι : Type x}

/-- A function `f` is Lipschitz continuous with constant `K ≥ 0` if for all `x, y`
we have `dist (f x) (f y) ≤ K * dist x y` -/
def LipschitzWith [PseudoEmetricSpace α] [PseudoEmetricSpace β] (K :  ℝ≥0 ) (f : α → β) :=
  ∀ x y, edist (f x) (f y) ≤ K*edist x y

theorem lipschitz_with_iff_dist_le_mul [PseudoMetricSpace α] [PseudoMetricSpace β] {K :  ℝ≥0 } {f : α → β} :
  LipschitzWith K f ↔ ∀ x y, dist (f x) (f y) ≤ K*dist x y :=
  by 
    simp only [LipschitzWith, edist_nndist, dist_nndist]
    normCast

alias lipschitz_with_iff_dist_le_mul ↔ LipschitzWith.dist_le_mul LipschitzWith.of_dist_le_mul

/-- A function `f` is Lipschitz continuous with constant `K ≥ 0` on `s` if for all `x, y` in `s`
we have `dist (f x) (f y) ≤ K * dist x y` -/
def LipschitzOnWith [PseudoEmetricSpace α] [PseudoEmetricSpace β] (K :  ℝ≥0 ) (f : α → β) (s : Set α) :=
  ∀ ⦃x⦄ (hx : x ∈ s) ⦃y⦄ (hy : y ∈ s), edist (f x) (f y) ≤ K*edist x y

@[simp]
theorem lipschitz_on_with_empty [PseudoEmetricSpace α] [PseudoEmetricSpace β] (K :  ℝ≥0 ) (f : α → β) :
  LipschitzOnWith K f ∅ :=
  fun x x_in y y_in => False.elim x_in

theorem LipschitzOnWith.mono [PseudoEmetricSpace α] [PseudoEmetricSpace β] {K :  ℝ≥0 } {s t : Set α} {f : α → β}
  (hf : LipschitzOnWith K f t) (h : s ⊆ t) : LipschitzOnWith K f s :=
  fun x x_in y y_in => hf (h x_in) (h y_in)

theorem lipschitz_on_with_iff_dist_le_mul [PseudoMetricSpace α] [PseudoMetricSpace β] {K :  ℝ≥0 } {s : Set α}
  {f : α → β} : LipschitzOnWith K f s ↔ ∀ x (_ : x ∈ s) y (_ : y ∈ s), dist (f x) (f y) ≤ K*dist x y :=
  by 
    simp only [LipschitzOnWith, edist_nndist, dist_nndist]
    normCast

alias lipschitz_on_with_iff_dist_le_mul ↔ LipschitzOnWith.dist_le_mul LipschitzOnWith.of_dist_le_mul

@[simp]
theorem lipschitz_on_univ [PseudoEmetricSpace α] [PseudoEmetricSpace β] {K :  ℝ≥0 } {f : α → β} :
  LipschitzOnWith K f univ ↔ LipschitzWith K f :=
  by 
    simp [LipschitzOnWith, LipschitzWith]

theorem lipschitz_on_with_iff_restrict [PseudoEmetricSpace α] [PseudoEmetricSpace β] {K :  ℝ≥0 } {f : α → β}
  {s : Set α} : LipschitzOnWith K f s ↔ LipschitzWith K (s.restrict f) :=
  by 
    simp only [LipschitzOnWith, LipschitzWith, SetCoe.forall', restrict, Subtype.edist_eq]

namespace LipschitzWith

section Emetric

variable[PseudoEmetricSpace α][PseudoEmetricSpace β][PseudoEmetricSpace γ]

variable{K :  ℝ≥0 }{f : α → β}

protected theorem LipschitzOnWith (h : LipschitzWith K f) (s : Set α) : LipschitzOnWith K f s :=
  fun x _ y _ => h x y

theorem edist_le_mul (h : LipschitzWith K f) (x y : α) : edist (f x) (f y) ≤ K*edist x y :=
  h x y

theorem edist_lt_top (hf : LipschitzWith K f) {x y : α} (h : edist x y ≠ ⊤) : edist (f x) (f y) < ⊤ :=
  lt_of_le_of_ltₓ (hf x y)$ Ennreal.mul_lt_top Ennreal.coe_ne_top h

theorem mul_edist_le (h : LipschitzWith K f) (x y : α) : ((K⁻¹ : ℝ≥0∞)*edist (f x) (f y)) ≤ edist x y :=
  by 
    rw [mul_commₓ, ←div_eq_mul_inv]
    exact Ennreal.div_le_of_le_mul' (h x y)

protected theorem of_edist_le (h : ∀ x y, edist (f x) (f y) ≤ edist x y) : LipschitzWith 1 f :=
  fun x y =>
    by 
      simp only [Ennreal.coe_one, one_mulₓ, h]

protected theorem weaken (hf : LipschitzWith K f) {K' :  ℝ≥0 } (h : K ≤ K') : LipschitzWith K' f :=
  fun x y => le_transₓ (hf x y)$ Ennreal.mul_right_mono (Ennreal.coe_le_coe.2 h)

theorem ediam_image_le (hf : LipschitzWith K f) (s : Set α) : Emetric.diam (f '' s) ≤ K*Emetric.diam s :=
  by 
    apply Emetric.diam_le 
    rintro _ ⟨x, hx, rfl⟩ _ ⟨y, hy, rfl⟩
    calc edist (f x) (f y) ≤ «expr↑ » K*edist x y := hf.edist_le_mul x y _ ≤ «expr↑ » K*Emetric.diam s :=
      Ennreal.mul_left_mono (Emetric.edist_le_diam_of_mem hx hy)

theorem edist_lt_of_edist_lt_div (hf : LipschitzWith K f) {x y : α} {d : ℝ≥0∞} (h : edist x y < d / K) :
  edist (f x) (f y) < d :=
  calc edist (f x) (f y) ≤ K*edist x y := hf x y 
    _ < d := Ennreal.mul_lt_of_lt_div' h
    

/-- A Lipschitz function is uniformly continuous -/
protected theorem UniformContinuous (hf : LipschitzWith K f) : UniformContinuous f :=
  by 
    refine' Emetric.uniform_continuous_iff.2 fun ε εpos => _ 
    use ε / K, Ennreal.div_pos_iff.2 ⟨ne_of_gtₓ εpos, Ennreal.coe_ne_top⟩
    exact fun x y => hf.edist_lt_of_edist_lt_div

/-- A Lipschitz function is continuous -/
protected theorem Continuous (hf : LipschitzWith K f) : Continuous f :=
  hf.uniform_continuous.continuous

-- error in Topology.MetricSpace.Lipschitz: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
protected theorem const (b : β) : lipschitz_with 0 (λ a : α, b) :=
assume x y, by simp [] [] ["only"] ["[", expr edist_self, ",", expr zero_le, "]"] [] []

protected theorem id : LipschitzWith 1 (@id α) :=
  LipschitzWith.of_edist_le$ fun x y => le_reflₓ _

protected theorem subtype_val (s : Set α) : LipschitzWith 1 (Subtype.val : s → α) :=
  LipschitzWith.of_edist_le$ fun x y => le_reflₓ _

protected theorem subtype_coe (s : Set α) : LipschitzWith 1 (coeₓ : s → α) :=
  LipschitzWith.subtype_val s

theorem subtype_mk (hf : LipschitzWith K f) {p : β → Prop} (hp : ∀ x, p (f x)) :
  LipschitzWith K (fun x => ⟨f x, hp x⟩ : α → { y // p y }) :=
  hf

protected theorem eval {α : ι → Type u} [∀ i, PseudoEmetricSpace (α i)] [Fintype ι] (i : ι) :
  LipschitzWith 1 (Function.eval i : (∀ i, α i) → α i) :=
  LipschitzWith.of_edist_le$
    fun f g =>
      by 
        convert edist_le_pi_edist f g i

protected theorem restrict (hf : LipschitzWith K f) (s : Set α) : LipschitzWith K (s.restrict f) :=
  fun x y => hf x y

protected theorem comp {Kf Kg :  ℝ≥0 } {f : β → γ} {g : α → β} (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
  LipschitzWith (Kf*Kg) (f ∘ g) :=
  fun x y =>
    calc edist (f (g x)) (f (g y)) ≤ Kf*edist (g x) (g y) := hf _ _ 
      _ ≤ Kf*Kg*edist x y := Ennreal.mul_left_mono (hg _ _)
      _ = (Kf*Kg :  ℝ≥0 )*edist x y :=
      by 
        rw [←mul_assocₓ, Ennreal.coe_mul]
      

protected theorem prod_fst : LipschitzWith 1 (@Prod.fst α β) :=
  LipschitzWith.of_edist_le$ fun x y => le_max_leftₓ _ _

protected theorem prod_snd : LipschitzWith 1 (@Prod.snd α β) :=
  LipschitzWith.of_edist_le$ fun x y => le_max_rightₓ _ _

protected theorem Prod {f : α → β} {Kf :  ℝ≥0 } (hf : LipschitzWith Kf f) {g : α → γ} {Kg :  ℝ≥0 }
  (hg : LipschitzWith Kg g) : LipschitzWith (max Kf Kg) fun x => (f x, g x) :=
  by 
    intro x y 
    rw [ennreal.coe_mono.map_max, Prod.edist_eq, Ennreal.max_mul]
    exact max_le_max (hf x y) (hg x y)

protected theorem uncurry {f : α → β → γ} {Kα Kβ :  ℝ≥0 } (hα : ∀ b, LipschitzWith Kα fun a => f a b)
  (hβ : ∀ a, LipschitzWith Kβ (f a)) : LipschitzWith (Kα+Kβ) (Function.uncurry f) :=
  by 
    rintro ⟨a₁, b₁⟩ ⟨a₂, b₂⟩
    simp only [Function.uncurry, Ennreal.coe_add, add_mulₓ]
    apply le_transₓ (edist_triangle _ (f a₂ b₁) _)
    exact
      add_le_add (le_transₓ (hα _ _ _)$ Ennreal.mul_left_mono$ le_max_leftₓ _ _)
        (le_transₓ (hβ _ _ _)$ Ennreal.mul_left_mono$ le_max_rightₓ _ _)

protected theorem iterate {f : α → α} (hf : LipschitzWith K f) : ∀ n, LipschitzWith (K ^ n) (f^[n])
| 0 => LipschitzWith.id
| n+1 =>
  by 
    rw [pow_succ'ₓ] <;> exact (iterate n).comp hf

theorem edist_iterate_succ_le_geometric {f : α → α} (hf : LipschitzWith K f) x n :
  edist ((f^[n]) x) ((f^[n+1]) x) ≤ edist x (f x)*K ^ n :=
  by 
    rw [iterate_succ, mul_commₓ]
    simpa only [Ennreal.coe_pow] using (hf.iterate n) x (f x)

open CategoryTheory

protected theorem mul {f g : End α} {Kf Kg} (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
  LipschitzWith (Kf*Kg) (f*g : End α) :=
  hf.comp hg

/-- The product of a list of Lipschitz continuous endomorphisms is a Lipschitz continuous
endomorphism. -/
protected theorem list_prod (f : ι → End α) (K : ι →  ℝ≥0 ) (h : ∀ i, LipschitzWith (K i) (f i)) :
  ∀ (l : List ι), LipschitzWith (l.map K).Prod (l.map f).Prod
| [] =>
  by 
    simp [types_id, LipschitzWith.id]
| i :: l =>
  by 
    simp only [List.map_consₓ, List.prod_cons]
    exact (h i).mul (list_prod l)

protected theorem pow {f : End α} {K} (h : LipschitzWith K f) : ∀ (n : ℕ), LipschitzWith (K ^ n) (f ^ n : End α)
| 0 => LipschitzWith.id
| n+1 =>
  by 
    rw [pow_succₓ, pow_succₓ]
    exact h.mul (pow n)

end Emetric

section Metric

variable[PseudoMetricSpace α][PseudoMetricSpace β][PseudoMetricSpace γ]{K :  ℝ≥0 }

protected theorem of_dist_le' {f : α → β} {K : ℝ} (h : ∀ x y, dist (f x) (f y) ≤ K*dist x y) :
  LipschitzWith (Real.toNnreal K) f :=
  of_dist_le_mul$ fun x y => le_transₓ (h x y)$ mul_le_mul_of_nonneg_right (Real.le_coe_to_nnreal K) dist_nonneg

protected theorem mk_one {f : α → β} (h : ∀ x y, dist (f x) (f y) ≤ dist x y) : LipschitzWith 1 f :=
  of_dist_le_mul$
    by 
      simpa only [Nnreal.coe_one, one_mulₓ] using h

/-- For functions to `ℝ`, it suffices to prove `f x ≤ f y + K * dist x y`; this version
doesn't assume `0≤K`. -/
protected theorem of_le_add_mul' {f : α → ℝ} (K : ℝ) (h : ∀ x y, f x ≤ f y+K*dist x y) :
  LipschitzWith (Real.toNnreal K) f :=
  have I : ∀ x y, f x - f y ≤ K*dist x y := fun x y => sub_le_iff_le_add'.2 (h x y)
  LipschitzWith.of_dist_le'$ fun x y => abs_sub_le_iff.2 ⟨I x y, dist_comm y x ▸ I y x⟩

/-- For functions to `ℝ`, it suffices to prove `f x ≤ f y + K * dist x y`; this version
assumes `0≤K`. -/
protected theorem of_le_add_mul {f : α → ℝ} (K :  ℝ≥0 ) (h : ∀ x y, f x ≤ f y+K*dist x y) : LipschitzWith K f :=
  by 
    simpa only [Real.to_nnreal_coe] using LipschitzWith.of_le_add_mul' K h

protected theorem of_le_add {f : α → ℝ} (h : ∀ x y, f x ≤ f y+dist x y) : LipschitzWith 1 f :=
  LipschitzWith.of_le_add_mul 1$
    by 
      simpa only [Nnreal.coe_one, one_mulₓ]

protected theorem le_add_mul {f : α → ℝ} {K :  ℝ≥0 } (h : LipschitzWith K f) x y : f x ≤ f y+K*dist x y :=
  sub_le_iff_le_add'.1$ le_transₓ (le_abs_self _)$ h.dist_le_mul x y

protected theorem iff_le_add_mul {f : α → ℝ} {K :  ℝ≥0 } : LipschitzWith K f ↔ ∀ x y, f x ≤ f y+K*dist x y :=
  ⟨LipschitzWith.le_add_mul, LipschitzWith.of_le_add_mul K⟩

theorem nndist_le {f : α → β} (hf : LipschitzWith K f) (x y : α) : nndist (f x) (f y) ≤ K*nndist x y :=
  hf.dist_le_mul x y

theorem diam_image_le {f : α → β} (hf : LipschitzWith K f) (s : Set α) (hs : Metric.Bounded s) :
  Metric.diam (f '' s) ≤ K*Metric.diam s :=
  by 
    apply Metric.diam_le_of_forall_dist_le (mul_nonneg K.coe_nonneg Metric.diam_nonneg)
    rintro _ ⟨x, hx, rfl⟩ _ ⟨y, hy, rfl⟩
    calc dist (f x) (f y) ≤ «expr↑ » K*dist x y := hf.dist_le_mul x y _ ≤ «expr↑ » K*Metric.diam s :=
      mul_le_mul_of_nonneg_left (Metric.dist_le_diam_of_mem hs hx hy) K.2

protected theorem dist_left (y : α) : LipschitzWith 1 fun x => dist x y :=
  LipschitzWith.of_le_add$
    fun x z =>
      by 
        rw [add_commₓ]
        apply dist_triangle

protected theorem dist_right (x : α) : LipschitzWith 1 (dist x) :=
  LipschitzWith.of_le_add$ fun y z => dist_triangle_right _ _ _

protected theorem dist : LipschitzWith 2 (Function.uncurry$ @dist α _) :=
  LipschitzWith.uncurry LipschitzWith.dist_left LipschitzWith.dist_right

theorem dist_iterate_succ_le_geometric {f : α → α} (hf : LipschitzWith K f) x n :
  dist ((f^[n]) x) ((f^[n+1]) x) ≤ dist x (f x)*K ^ n :=
  by 
    rw [iterate_succ, mul_commₓ]
    simpa only [Nnreal.coe_pow] using (hf.iterate n).dist_le_mul x (f x)

-- error in Topology.MetricSpace.Lipschitz: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem _root_.lipschitz_with_max : lipschitz_with 1 (λ p : «expr × »(exprℝ(), exprℝ()), max p.1 p.2) :=
«expr $ »(lipschitz_with.of_le_add, λ
 p₁ p₂, «expr $ »(sub_le_iff_le_add'.1, (le_abs_self _).trans (abs_max_sub_max_le_max _ _ _ _)))

-- error in Topology.MetricSpace.Lipschitz: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem _root_.lipschitz_with_min : lipschitz_with 1 (λ p : «expr × »(exprℝ(), exprℝ()), min p.1 p.2) :=
«expr $ »(lipschitz_with.of_le_add, λ
 p₁ p₂, «expr $ »(sub_le_iff_le_add'.1, (le_abs_self _).trans (abs_min_sub_min_le_max _ _ _ _)))

end Metric

section Emetric

variable{α}[PseudoEmetricSpace α]{f g : α → ℝ}{Kf Kg :  ℝ≥0 }

protected theorem max (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
  LipschitzWith (max Kf Kg) fun x => max (f x) (g x) :=
  by 
    simpa only [· ∘ ·, one_mulₓ] using lipschitz_with_max.comp (hf.prod hg)

protected theorem min (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
  LipschitzWith (max Kf Kg) fun x => min (f x) (g x) :=
  by 
    simpa only [· ∘ ·, one_mulₓ] using lipschitz_with_min.comp (hf.prod hg)

theorem max_const (hf : LipschitzWith Kf f) (a : ℝ) : LipschitzWith Kf fun x => max (f x) a :=
  by 
    simpa only [max_eq_leftₓ (zero_le Kf)] using hf.max (LipschitzWith.const a)

theorem const_max (hf : LipschitzWith Kf f) (a : ℝ) : LipschitzWith Kf fun x => max a (f x) :=
  by 
    simpa only [max_commₓ] using hf.max_const a

theorem min_const (hf : LipschitzWith Kf f) (a : ℝ) : LipschitzWith Kf fun x => min (f x) a :=
  by 
    simpa only [max_eq_leftₓ (zero_le Kf)] using hf.min (LipschitzWith.const a)

theorem const_min (hf : LipschitzWith Kf f) (a : ℝ) : LipschitzWith Kf fun x => min a (f x) :=
  by 
    simpa only [min_commₓ] using hf.min_const a

end Emetric

protected theorem proj_Icc {a b : ℝ} (h : a ≤ b) : LipschitzWith 1 (proj_Icc a b h) :=
  ((LipschitzWith.id.const_min _).const_max _).subtype_mk _

end LipschitzWith

namespace LipschitzOnWith

variable[PseudoEmetricSpace α][PseudoEmetricSpace β][PseudoEmetricSpace γ]

variable{K :  ℝ≥0 }{s : Set α}{f : α → β}

protected theorem UniformContinuousOn (hf : LipschitzOnWith K f s) : UniformContinuousOn f s :=
  uniform_continuous_on_iff_restrict.mpr (lipschitz_on_with_iff_restrict.mp hf).UniformContinuous

protected theorem ContinuousOn (hf : LipschitzOnWith K f s) : ContinuousOn f s :=
  hf.uniform_continuous_on.continuous_on

theorem edist_lt_of_edist_lt_div (hf : LipschitzOnWith K f s) {x y : α} (hx : x ∈ s) (hy : y ∈ s) {d : ℝ≥0∞}
  (hd : edist x y < d / K) : edist (f x) (f y) < d :=
  (lipschitz_on_with_iff_restrict.mp hf).edist_lt_of_edist_lt_div$ show edist (⟨x, hx⟩ : s) ⟨y, hy⟩ < d / K from hd

end LipschitzOnWith

-- error in Topology.MetricSpace.Lipschitz: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Consider a function `f : α × β → γ`. Suppose that it is continuous on each “vertical fiber”
`{a} × t`, `a ∈ s`, and is Lipschitz continuous on each “horizontal fiber” `s × {b}`, `b ∈ t`
with the same Lipschitz constant `K`. Then it is continuous on `s × t`.

The actual statement uses (Lipschitz) continuity of `λ y, f (a, y)` and `λ x, f (x, b)` instead
of continuity of `f` on subsets of the product space. -/
theorem continuous_on_prod_of_continuous_on_lipschitz_on
[pseudo_emetric_space α]
[topological_space β]
[pseudo_emetric_space γ]
(f : «expr × »(α, β) → γ)
{s : set α}
{t : set β}
(K : «exprℝ≥0»())
(ha : ∀ a «expr ∈ » s, continuous_on (λ y, f (a, y)) t)
(hb : ∀ b «expr ∈ » t, lipschitz_on_with K (λ x, f (x, b)) s) : continuous_on f (s.prod t) :=
begin
  rintro ["⟨", ident x, ",", ident y, "⟩", "⟨", ident hx, ":", expr «expr ∈ »(x, s), ",", ident hy, ":", expr «expr ∈ »(y, t), "⟩"],
  refine [expr emetric.tendsto_nhds.2 (λ (ε) (ε0 : «expr < »(0, ε)), _)],
  replace [ident ε0] [":", expr «expr < »(0, «expr / »(ε, 2))] [":=", expr ennreal.half_pos (ne_of_gt ε0)],
  have [ident εK] [":", expr «expr < »(0, «expr / »(«expr / »(ε, 2), K))] [":=", expr ennreal.div_pos_iff.2 ⟨ε0.ne', ennreal.coe_ne_top⟩],
  have [ident A] [":", expr «expr ∈ »(«expr ∩ »(s, emetric.ball x «expr / »(«expr / »(ε, 2), K)), «expr𝓝[ ] »(s, x))] [":=", expr inter_mem_nhds_within _ (emetric.ball_mem_nhds _ εK)],
  have [ident B] [":", expr «expr ∈ »({b : β | «expr ∧ »(«expr ∈ »(b, t), «expr < »(edist (f (x, b)) (f (x, y)), «expr / »(ε, 2)))}, «expr𝓝[ ] »(t, y))] [":=", expr inter_mem self_mem_nhds_within (ha x hx y hy (emetric.ball_mem_nhds _ ε0))],
  filter_upwards ["[", expr nhds_within_prod A B, "]"] [],
  rintro ["⟨", ident a, ",", ident b, "⟩", "⟨", "⟨", ident has, ":", expr «expr ∈ »(a, s), ",", ident hax, ":", expr «expr < »(edist a x, «expr / »(«expr / »(ε, 2), K)), "⟩", ",", ident hbt, ":", expr «expr ∈ »(b, t), ",", ident hby, ":", expr «expr < »(edist (f (x, b)) (f (x, y)), «expr / »(ε, 2)), "⟩"],
  calc
    «expr ≤ »(edist (f (a, b)) (f (x, y)), «expr + »(edist (f (a, b)) (f (x, b)), edist (f (x, b)) (f (x, y)))) : edist_triangle _ _ _
    «expr < »(..., «expr + »(«expr / »(ε, 2), «expr / »(ε, 2))) : ennreal.add_lt_add ((hb _ hbt).edist_lt_of_edist_lt_div has hx hax) hby
    «expr = »(..., ε) : ennreal.add_halves ε
end

/-- Consider a function `f : α × β → γ`. Suppose that it is continuous on each “vertical section”
`{a} × univ`, `a : α`, and is Lipschitz continuous on each “horizontal section”
`univ × {b}`, `b : β` with the same Lipschitz constant `K`. Then it is continuous.

The actual statement uses (Lipschitz) continuity of `λ y, f (a, y)` and `λ x, f (x, b)` instead
of continuity of `f` on subsets of the product space. -/
theorem continuous_prod_of_continuous_lipschitz [PseudoEmetricSpace α] [TopologicalSpace β] [PseudoEmetricSpace γ]
  (f : α × β → γ) (K :  ℝ≥0 ) (ha : ∀ a, Continuous fun y => f (a, y)) (hb : ∀ b, LipschitzWith K fun x => f (x, b)) :
  Continuous f :=
  by 
    simp only [continuous_iff_continuous_on_univ, ←univ_prod_univ, ←lipschitz_on_univ] at *
    exact continuous_on_prod_of_continuous_on_lipschitz_on f K (fun a _ => ha a) fun b _ => hb b

open Metric

/-- If a function is locally Lipschitz around a point, then it is continuous at this point. -/
theorem continuous_at_of_locally_lipschitz [MetricSpace α] [MetricSpace β] {f : α → β} {x : α} {r : ℝ} (hr : 0 < r)
  (K : ℝ) (h : ∀ y, dist y x < r → dist (f y) (f x) ≤ K*dist y x) : ContinuousAt f x :=
  by 
    refine'
      tendsto_iff_dist_tendsto_zero.2
        (squeeze_zero' (eventually_of_forall$ fun _ => dist_nonneg) (mem_of_superset (ball_mem_nhds _ hr) h) _)
    refine' (continuous_const.mul (continuous_id.dist continuous_const)).tendsto' _ _ _ 
    simp 

