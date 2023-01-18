/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module topology.locally_finite
! leanprover-community/mathlib commit 008205aa645b3f194c1da47025c5f110c8406eab
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Basic
import Mathbin.Order.Filter.SmallSets

/-!
### Locally finite families of sets

We say that a family of sets in a topological space is *locally finite* if at every point `x : X`,
there is a neighborhood of `x` which meets only finitely many sets in the family.

In this file we give the definition and prove basic properties of locally finite families of sets.
-/


-- locally finite family [General Topology (Bourbaki, 1995)]
open Set Function Filter

open TopologicalSpace Filter

universe u

variable {ι : Type u} {ι' α X Y : Type _} [TopologicalSpace X] [TopologicalSpace Y]
  {f g : ι → Set X}

/-- A family of sets in `set X` is locally finite if at every point `x : X`,
there is a neighborhood of `x` which meets only finitely many sets in the family. -/
def LocallyFinite (f : ι → Set X) :=
  ∀ x : X, ∃ t ∈ 𝓝 x, { i | (f i ∩ t).Nonempty }.Finite
#align locally_finite LocallyFinite

theorem locally_finite_of_finite [Finite ι] (f : ι → Set X) : LocallyFinite f := fun x =>
  ⟨univ, univ_mem, to_finite _⟩
#align locally_finite_of_finite locally_finite_of_finite

namespace LocallyFinite

theorem point_finite (hf : LocallyFinite f) (x : X) : { b | x ∈ f b }.Finite :=
  let ⟨t, hxt, ht⟩ := hf x
  ht.Subset fun b hb => ⟨x, hb, mem_of_mem_nhds hxt⟩
#align locally_finite.point_finite LocallyFinite.point_finite

protected theorem subset (hf : LocallyFinite f) (hg : ∀ i, g i ⊆ f i) : LocallyFinite g := fun a =>
  let ⟨t, ht₁, ht₂⟩ := hf a
  ⟨t, ht₁, ht₂.Subset fun i hi => hi.mono <| inter_subset_inter (hg i) Subset.rfl⟩
#align locally_finite.subset LocallyFinite.subset

theorem comp_inj_on {g : ι' → ι} (hf : LocallyFinite f) (hg : InjOn g { i | (f (g i)).Nonempty }) :
    LocallyFinite (f ∘ g) := fun x =>
  let ⟨t, htx, htf⟩ := hf x
  ⟨t, htx, htf.Preimage <| hg.mono fun i hi => hi.out.mono <| inter_subset_left _ _⟩
#align locally_finite.comp_inj_on LocallyFinite.comp_inj_on

theorem comp_injective {g : ι' → ι} (hf : LocallyFinite f) (hg : Injective g) :
    LocallyFinite (f ∘ g) :=
  hf.comp_inj_on (hg.InjOn _)
#align locally_finite.comp_injective LocallyFinite.comp_injective

theorem locally_finite_iff_small_sets :
    LocallyFinite f ↔ ∀ x, ∀ᶠ s in (𝓝 x).smallSets, { i | (f i ∩ s).Nonempty }.Finite :=
  forall_congr' fun x =>
    Iff.symm <|
      eventually_small_sets' fun s t hst ht =>
        ht.Subset fun i hi => hi.mono <| inter_subset_inter_right _ hst
#align locally_finite_iff_small_sets locally_finite_iff_small_sets

protected theorem eventually_small_sets (hf : LocallyFinite f) (x : X) :
    ∀ᶠ s in (𝓝 x).smallSets, { i | (f i ∩ s).Nonempty }.Finite :=
  locally_finite_iff_small_sets.mp hf x
#align locally_finite.eventually_small_sets LocallyFinite.eventually_small_sets

theorem exists_mem_basis {ι' : Sort _} (hf : LocallyFinite f) {p : ι' → Prop} {s : ι' → Set X}
    {x : X} (hb : (𝓝 x).HasBasis p s) : ∃ (i : _)(hi : p i), { j | (f j ∩ s i).Nonempty }.Finite :=
  let ⟨i, hpi, hi⟩ := hb.smallSets.eventually_iff.mp (hf.eventually_small_sets x)
  ⟨i, hpi, hi Subset.rfl⟩
#align locally_finite.exists_mem_basis LocallyFinite.exists_mem_basis

protected theorem closure (hf : LocallyFinite f) : LocallyFinite fun i => closure (f i) :=
  by
  intro x
  rcases hf x with ⟨s, hsx, hsf⟩
  refine' ⟨interior s, interior_mem_nhds.2 hsx, hsf.subset fun i hi => _⟩
  exact
    (hi.mono is_open_interior.closure_inter).of_closure.mono
      (inter_subset_inter_right _ interior_subset)
#align locally_finite.closure LocallyFinite.closure

theorem is_closed_Union (hf : LocallyFinite f) (hc : ∀ i, IsClosed (f i)) : IsClosed (⋃ i, f i) :=
  by
  simp only [← is_open_compl_iff, compl_Union, is_open_iff_mem_nhds, mem_Inter]
  intro a ha
  replace ha : ∀ i, f iᶜ ∈ 𝓝 a := fun i => (hc i).is_open_compl.mem_nhds (ha i)
  rcases hf a with ⟨t, h_nhds, h_fin⟩
  have : (t ∩ ⋂ i ∈ { i | (f i ∩ t).Nonempty }, f iᶜ) ∈ 𝓝 a :=
    inter_mem h_nhds ((bInter_mem h_fin).2 fun i _ => ha i)
  filter_upwards [this]
  simp only [mem_inter_iff, mem_Inter]
  rintro b ⟨hbt, hn⟩ i hfb
  exact hn i ⟨b, hfb, hbt⟩ hfb
#align locally_finite.is_closed_Union LocallyFinite.is_closed_Union

theorem closure_Union (h : LocallyFinite f) : closure (⋃ i, f i) = ⋃ i, closure (f i) :=
  Subset.antisymm
    (closure_minimal (Union_mono fun _ => subset_closure) <|
      h.closure.is_closed_Union fun _ => is_closed_closure)
    (Union_subset fun i => closure_mono <| subset_unionᵢ _ _)
#align locally_finite.closure_Union LocallyFinite.closure_Union

/-- If `f : β → set α` is a locally finite family of closed sets, then for any `x : α`, the
intersection of the complements to `f i`, `x ∉ f i`, is a neighbourhood of `x`. -/
theorem Inter_compl_mem_nhds (hf : LocallyFinite f) (hc : ∀ i, IsClosed (f i)) (x : X) :
    (⋂ (i) (hi : x ∉ f i), f iᶜ) ∈ 𝓝 x :=
  by
  refine' IsOpen.mem_nhds _ (mem_Inter₂.2 fun i => id)
  suffices IsClosed (⋃ i : { i // x ∉ f i }, f i) by
    rwa [← is_open_compl_iff, compl_Union, Inter_subtype] at this
  exact (hf.comp_injective Subtype.coe_injective).is_closed_Union fun i => hc _
#align locally_finite.Inter_compl_mem_nhds LocallyFinite.Inter_compl_mem_nhds

/-- Let `f : ℕ → Π a, β a` be a sequence of (dependent) functions on a topological space. Suppose
that the family of sets `s n = {x | f (n + 1) x ≠ f n x}` is locally finite. Then there exists a
function `F : Π a, β a` such that for any `x`, we have `f n x = F x` on the product of an infinite
interval `[N, +∞)` and a neighbourhood of `x`.

We formulate the conclusion in terms of the product of filter `filter.at_top` and `𝓝 x`. -/
theorem exists_forall_eventually_eq_prod {π : X → Sort _} {f : ℕ → ∀ x : X, π x}
    (hf : LocallyFinite fun n => { x | f (n + 1) x ≠ f n x }) :
    ∃ F : ∀ x : X, π x, ∀ x, ∀ᶠ p : ℕ × X in at_top ×ᶠ 𝓝 x, f p.1 p.2 = F p.2 :=
  by
  choose U hUx hU using hf
  choose N hN using fun x => (hU x).BddAbove
  replace hN : ∀ (x), ∀ n > N x, ∀ y ∈ U x, f (n + 1) y = f n y
  exact fun x n hn y hy => by_contra fun hne => hn.lt.not_le <| hN x ⟨y, hne, hy⟩
  replace hN : ∀ (x), ∀ n ≥ N x + 1, ∀ y ∈ U x, f n y = f (N x + 1) y
  exact fun x n hn y hy => Nat.le_induction rfl (fun k hle => (hN x _ hle _ hy).trans) n hn
  refine' ⟨fun x => f (N x + 1) x, fun x => _⟩
  filter_upwards [Filter.prod_mem_prod (eventually_gt_at_top (N x)) (hUx x)]
  rintro ⟨n, y⟩ ⟨hn : N x < n, hy : y ∈ U x⟩
  calc
    f n y = f (N x + 1) y := hN _ _ hn _ hy
    _ = f (max (N x + 1) (N y + 1)) y := (hN _ _ (le_max_left _ _) _ hy).symm
    _ = f (N y + 1) y := hN _ _ (le_max_right _ _) _ (mem_of_mem_nhds <| hUx y)
    
#align
  locally_finite.exists_forall_eventually_eq_prod LocallyFinite.exists_forall_eventually_eq_prod

/-- Let `f : ℕ → Π a, β a` be a sequence of (dependent) functions on a topological space. Suppose
that the family of sets `s n = {x | f (n + 1) x ≠ f n x}` is locally finite. Then there exists a
function `F : Π a, β a` such that for any `x`, for sufficiently large values of `n`, we have
`f n y = F y` in a neighbourhood of `x`. -/
theorem exists_forall_eventually_at_top_eventually_eq' {π : X → Sort _} {f : ℕ → ∀ x : X, π x}
    (hf : LocallyFinite fun n => { x | f (n + 1) x ≠ f n x }) :
    ∃ F : ∀ x : X, π x, ∀ x, ∀ᶠ n : ℕ in at_top, ∀ᶠ y : X in 𝓝 x, f n y = F y :=
  hf.exists_forall_eventually_eq_prod.imp fun F hF x => (hF x).curry
#align
  locally_finite.exists_forall_eventually_at_top_eventually_eq' LocallyFinite.exists_forall_eventually_at_top_eventually_eq'

/-- Let `f : ℕ → α → β` be a sequence of functions on a topological space. Suppose
that the family of sets `s n = {x | f (n + 1) x ≠ f n x}` is locally finite. Then there exists a
function `F :  α → β` such that for any `x`, for sufficiently large values of `n`, we have
`f n =ᶠ[𝓝 x] F`. -/
theorem exists_forall_eventually_at_top_eventually_eq {f : ℕ → X → α}
    (hf : LocallyFinite fun n => { x | f (n + 1) x ≠ f n x }) :
    ∃ F : X → α, ∀ x, ∀ᶠ n : ℕ in at_top, f n =ᶠ[𝓝 x] F :=
  hf.exists_forall_eventually_at_top_eventually_eq'
#align
  locally_finite.exists_forall_eventually_at_top_eventually_eq LocallyFinite.exists_forall_eventually_at_top_eventually_eq

theorem preimage_continuous {g : Y → X} (hf : LocallyFinite f) (hg : Continuous g) :
    LocallyFinite fun i => g ⁻¹' f i := fun x =>
  let ⟨s, hsx, hs⟩ := hf (g x)
  ⟨g ⁻¹' s, hg.ContinuousAt hsx, hs.Subset fun i ⟨y, hy⟩ => ⟨g y, hy⟩⟩
#align locally_finite.preimage_continuous LocallyFinite.preimage_continuous

end LocallyFinite

@[simp]
theorem Equiv.locally_finite_comp_iff (e : ι' ≃ ι) : LocallyFinite (f ∘ e) ↔ LocallyFinite f :=
  ⟨fun h => by simpa only [(· ∘ ·), e.apply_symm_apply] using h.comp_injective e.symm.injective,
    fun h => h.comp_injective e.Injective⟩
#align equiv.locally_finite_comp_iff Equiv.locally_finite_comp_iff

theorem locally_finite_sum {f : Sum ι ι' → Set X} :
    LocallyFinite f ↔ LocallyFinite (f ∘ Sum.inl) ∧ LocallyFinite (f ∘ Sum.inr) := by
  simp only [locally_finite_iff_small_sets, ← forall_and, ← finite_preimage_inl_and_inr,
    preimage_set_of_eq, (· ∘ ·), eventually_and]
#align locally_finite_sum locally_finite_sum

theorem LocallyFinite.sum_elim {g : ι' → Set X} (hf : LocallyFinite f) (hg : LocallyFinite g) :
    LocallyFinite (Sum.elim f g) :=
  locally_finite_sum.mpr ⟨hf, hg⟩
#align locally_finite.sum_elim LocallyFinite.sum_elim

theorem locally_finite_option {f : Option ι → Set X} : LocallyFinite f ↔ LocallyFinite (f ∘ some) :=
  by
  simp only [← (Equiv.optionEquivSumPUnit.{u} ι).symm.locally_finite_comp_iff, locally_finite_sum,
    locally_finite_of_finite, and_true_iff]
  rfl
#align locally_finite_option locally_finite_option

theorem LocallyFinite.option_elim (hf : LocallyFinite f) (s : Set X) :
    LocallyFinite (Option.elim' s f) :=
  locally_finite_option.2 hf
#align locally_finite.option_elim LocallyFinite.option_elim

