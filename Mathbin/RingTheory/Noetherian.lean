/-
Copyright (c) 2018 Mario Carneiro, Kevin Buzzard. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Kevin Buzzard
-/
import Mathbin.GroupTheory.Finiteness
import Mathbin.Data.Multiset.FinsetOps
import Mathbin.Algebra.Algebra.Tower
import Mathbin.Order.OrderIsoNat
import Mathbin.RingTheory.Nilpotent
import Mathbin.Order.CompactlyGenerated
import Mathbin.LinearAlgebra.LinearIndependent
import Mathbin.Algebra.Ring.Idempotents

/-!
# Noetherian rings and modules

The following are equivalent for a module M over a ring R:
1. Every increasing chain of submodules M₁ ⊆ M₂ ⊆ M₃ ⊆ ⋯ eventually stabilises.
2. Every submodule is finitely generated.

A module satisfying these equivalent conditions is said to be a *Noetherian* R-module.
A ring is a *Noetherian ring* if it is Noetherian as a module over itself.

(Note that we do not assume yet that our rings are commutative,
so perhaps this should be called "left Noetherian".
To avoid cumbersome names once we specialize to the commutative case,
we don't make this explicit in the declaration names.)

## Main definitions

Let `R` be a ring and let `M` and `P` be `R`-modules. Let `N` be an `R`-submodule of `M`.

* `submodule.fg N : Prop` is the assertion that `N` is finitely generated as an `R`-module.

* `is_noetherian R M` is the proposition that `M` is a Noetherian `R`-module. It is a class,
  implemented as the predicate that all `R`-submodules of `M` are finitely generated.

## Main statements

* `exists_sub_one_mem_and_smul_eq_zero_of_fg_of_le_smul` is Nakayama's lemma, in the following form:
  if N is a finitely generated submodule of an ambient R-module M and I is an ideal of R
  such that N ⊆ IN, then there exists r ∈ 1 + I such that rN = 0.

* `is_noetherian_iff_well_founded` is the theorem that an R-module M is Noetherian iff
  `>` is well-founded on `submodule R M`.

Note that the Hilbert basis theorem, that if a commutative ring R is Noetherian then so is R[X],
is proved in `ring_theory.polynomial`.

## References

* [M. F. Atiyah and I. G. Macdonald, *Introduction to commutative algebra*][atiyah-macdonald]
* [samuel1967]

## Tags

Noetherian, noetherian, Noetherian ring, Noetherian module, noetherian ring, noetherian module

-/


open Set

open BigOperators Pointwise

namespace Submodule

variable {R : Type _} {M : Type _} [Semiring R] [AddCommMonoid M] [Module R M]

/-- A submodule of `M` is finitely generated if it is the span of a finite subset of `M`. -/
def Fg (N : Submodule R M) : Prop :=
  ∃ S : Finset M, Submodule.span R ↑S = N
#align submodule.fg Submodule.Fg

theorem fg_def {N : Submodule R M} : N.Fg ↔ ∃ S : Set M, S.Finite ∧ span R S = N :=
  ⟨fun ⟨t, h⟩ => ⟨_, Finset.finite_to_set t, h⟩, by
    rintro ⟨t', h, rfl⟩
    rcases finite.exists_finset_coe h with ⟨t, rfl⟩
    exact ⟨t, rfl⟩⟩
#align submodule.fg_def Submodule.fg_def

theorem fg_iff_add_submonoid_fg (P : Submodule ℕ M) : P.Fg ↔ P.toAddSubmonoid.Fg :=
  ⟨fun ⟨S, hS⟩ => ⟨S, by simpa [← span_nat_eq_add_submonoid_closure] using hS⟩, fun ⟨S, hS⟩ =>
    ⟨S, by simpa [← span_nat_eq_add_submonoid_closure] using hS⟩⟩
#align submodule.fg_iff_add_submonoid_fg Submodule.fg_iff_add_submonoid_fg

theorem fg_iff_add_subgroup_fg {G : Type _} [AddCommGroup G] (P : Submodule ℤ G) : P.Fg ↔ P.toAddSubgroup.Fg :=
  ⟨fun ⟨S, hS⟩ => ⟨S, by simpa [← span_int_eq_add_subgroup_closure] using hS⟩, fun ⟨S, hS⟩ =>
    ⟨S, by simpa [← span_int_eq_add_subgroup_closure] using hS⟩⟩
#align submodule.fg_iff_add_subgroup_fg Submodule.fg_iff_add_subgroup_fg

theorem fg_iff_exists_fin_generating_family {N : Submodule R M} :
    N.Fg ↔ ∃ (n : ℕ)(s : Fin n → M), span R (range s) = N := by
  rw [fg_def]
  constructor
  · rintro ⟨S, Sfin, hS⟩
    obtain ⟨n, f, rfl⟩ := Sfin.fin_embedding
    exact ⟨n, f, hS⟩
    
  · rintro ⟨n, s, hs⟩
    refine' ⟨range s, finite_range s, hs⟩
    
#align submodule.fg_iff_exists_fin_generating_family Submodule.fg_iff_exists_fin_generating_family

/-- **Nakayama's Lemma**. Atiyah-Macdonald 2.5, Eisenbud 4.7, Matsumura 2.2,
[Stacks 00DV](https://stacks.math.columbia.edu/tag/00DV) -/
theorem exists_sub_one_mem_and_smul_eq_zero_of_fg_of_le_smul {R : Type _} [CommRing R] {M : Type _} [AddCommGroup M]
    [Module R M] (I : Ideal R) (N : Submodule R M) (hn : N.Fg) (hin : N ≤ I • N) :
    ∃ r : R, r - 1 ∈ I ∧ ∀ n ∈ N, r • n = (0 : M) := by
  rw [fg_def] at hn
  rcases hn with ⟨s, hfs, hs⟩
  have : ∃ r : R, r - 1 ∈ I ∧ N ≤ (I • span R s).comap (LinearMap.lsmul R M r) ∧ s ⊆ N := by
    refine' ⟨1, _, _, _⟩
    · rw [sub_self]
      exact I.zero_mem
      
    · rw [hs]
      intro n hn
      rw [mem_comap]
      change (1 : R) • n ∈ I • N
      rw [one_smul]
      exact hin hn
      
    · rw [← span_le, hs]
      exact le_refl N
      
  clear hin hs
  revert this
  refine' Set.Finite.dinduction_on hfs (fun H => _) fun i s his hfs ih H => _
  · rcases H with ⟨r, hr1, hrn, hs⟩
    refine' ⟨r, hr1, fun n hn => _⟩
    specialize hrn hn
    rwa [mem_comap, span_empty, smul_bot, mem_bot] at hrn
    
  apply ih
  rcases H with ⟨r, hr1, hrn, hs⟩
  rw [← Set.singleton_union, span_union, smul_sup] at hrn
  rw [Set.insert_subset] at hs
  have : ∃ c : R, c - 1 ∈ I ∧ c • i ∈ I • span R s := by
    specialize hrn hs.1
    rw [mem_comap, mem_sup] at hrn
    rcases hrn with ⟨y, hy, z, hz, hyz⟩
    change y + z = r • i at hyz
    rw [mem_smul_span_singleton] at hy
    rcases hy with ⟨c, hci, rfl⟩
    use r - c
    constructor
    · rw [sub_right_comm]
      exact I.sub_mem hr1 hci
      
    · rw [sub_smul, ← hyz, add_sub_cancel']
      exact hz
      
  rcases this with ⟨c, hc1, hci⟩
  refine' ⟨c * r, _, _, hs.2⟩
  · rw [← Ideal.Quotient.eq, RingHom.map_one] at hr1 hc1⊢
    rw [RingHom.map_mul, hc1, hr1, mul_one]
    
  · intro n hn
    specialize hrn hn
    rw [mem_comap, mem_sup] at hrn
    rcases hrn with ⟨y, hy, z, hz, hyz⟩
    change y + z = r • n at hyz
    rw [mem_smul_span_singleton] at hy
    rcases hy with ⟨d, hdi, rfl⟩
    change _ • _ ∈ I • span R s
    rw [mul_smul, ← hyz, smul_add, smul_smul, mul_comm, mul_smul]
    exact add_mem (smul_mem _ _ hci) (smul_mem _ _ hz)
    
#align
  submodule.exists_sub_one_mem_and_smul_eq_zero_of_fg_of_le_smul Submodule.exists_sub_one_mem_and_smul_eq_zero_of_fg_of_le_smul

theorem exists_mem_and_smul_eq_self_of_fg_of_le_smul {R : Type _} [CommRing R] {M : Type _} [AddCommGroup M]
    [Module R M] (I : Ideal R) (N : Submodule R M) (hn : N.Fg) (hin : N ≤ I • N) : ∃ r ∈ I, ∀ n ∈ N, r • n = n := by
  obtain ⟨r, hr, hr'⟩ := N.exists_sub_one_mem_and_smul_eq_zero_of_fg_of_le_smul I hn hin
  exact ⟨-(r - 1), I.neg_mem hr, fun n hn => by simpa [sub_smul] using hr' n hn⟩
#align submodule.exists_mem_and_smul_eq_self_of_fg_of_le_smul Submodule.exists_mem_and_smul_eq_self_of_fg_of_le_smul

theorem fg_bot : (⊥ : Submodule R M).Fg :=
  ⟨∅, by rw [Finset.coe_empty, span_empty]⟩
#align submodule.fg_bot Submodule.fg_bot

theorem _root_.subalgebra.fg_bot_to_submodule {R A : Type _} [CommSemiring R] [Semiring A] [Algebra R A] :
    (⊥ : Subalgebra R A).toSubmodule.Fg :=
  ⟨{1}, by simp [Algebra.to_submodule_bot]⟩
#align submodule._root_.subalgebra.fg_bot_to_submodule submodule._root_.subalgebra.fg_bot_to_submodule

theorem fg_span {s : Set M} (hs : s.Finite) : Fg (span R s) :=
  ⟨hs.toFinset, by rw [hs.coe_to_finset]⟩
#align submodule.fg_span Submodule.fg_span

theorem fg_span_singleton (x : M) : Fg (R ∙ x) :=
  fg_span (finite_singleton x)
#align submodule.fg_span_singleton Submodule.fg_span_singleton

theorem Fg.sup {N₁ N₂ : Submodule R M} (hN₁ : N₁.Fg) (hN₂ : N₂.Fg) : (N₁ ⊔ N₂).Fg :=
  let ⟨t₁, ht₁⟩ := fg_def.1 hN₁
  let ⟨t₂, ht₂⟩ := fg_def.1 hN₂
  fg_def.2 ⟨t₁ ∪ t₂, ht₁.1.union ht₂.1, by rw [span_union, ht₁.2, ht₂.2]⟩
#align submodule.fg.sup Submodule.Fg.sup

theorem fg_finset_sup {ι : Type _} (s : Finset ι) (N : ι → Submodule R M) (h : ∀ i ∈ s, (N i).Fg) : (s.sup N).Fg :=
  Finset.supInduction fg_bot (fun a ha b hb => ha.sup hb) h
#align submodule.fg_finset_sup Submodule.fg_finset_sup

theorem fg_bsupr {ι : Type _} (s : Finset ι) (N : ι → Submodule R M) (h : ∀ i ∈ s, (N i).Fg) : (⨆ i ∈ s, N i).Fg := by
  simpa only [Finset.sup_eq_supr] using fg_finset_sup s N h
#align submodule.fg_bsupr Submodule.fg_bsupr

theorem fg_supr {ι : Type _} [Finite ι] (N : ι → Submodule R M) (h : ∀ i, (N i).Fg) : (supr N).Fg := by
  cases nonempty_fintype ι
  simpa using fg_bsupr Finset.univ N fun i hi => h i
#align submodule.fg_supr Submodule.fg_supr

variable {P : Type _} [AddCommMonoid P] [Module R P]

variable (f : M →ₗ[R] P)

theorem Fg.map {N : Submodule R M} (hs : N.Fg) : (N.map f).Fg :=
  let ⟨t, ht⟩ := fg_def.1 hs
  fg_def.2 ⟨f '' t, ht.1.image _, by rw [span_image, ht.2]⟩
#align submodule.fg.map Submodule.Fg.map

variable {f}

theorem fg_of_fg_map_injective (f : M →ₗ[R] P) (hf : Function.Injective f) {N : Submodule R M} (hfn : (N.map f).Fg) :
    N.Fg :=
  let ⟨t, ht⟩ := hfn
  ⟨(t.Preimage f) fun x _ y _ h => hf h,
    Submodule.map_injective_of_injective hf <| by
      rw [f.map_span, Finset.coe_preimage, Set.image_preimage_eq_inter_range, Set.inter_eq_self_of_subset_left, ht]
      rw [← LinearMap.range_coe, ← span_le, ht, ← map_top]
      exact map_mono le_top⟩
#align submodule.fg_of_fg_map_injective Submodule.fg_of_fg_map_injective

theorem fg_of_fg_map {R M P : Type _} [Ring R] [AddCommGroup M] [Module R M] [AddCommGroup P] [Module R P]
    (f : M →ₗ[R] P) (hf : f.ker = ⊥) {N : Submodule R M} (hfn : (N.map f).Fg) : N.Fg :=
  fg_of_fg_map_injective f (LinearMap.ker_eq_bot.1 hf) hfn
#align submodule.fg_of_fg_map Submodule.fg_of_fg_map

theorem fg_top (N : Submodule R M) : (⊤ : Submodule R N).Fg ↔ N.Fg :=
  ⟨fun h => N.range_subtype ▸ map_top N.Subtype ▸ h.map _, fun h =>
    fg_of_fg_map_injective N.Subtype Subtype.val_injective <| by rwa [map_top, range_subtype]⟩
#align submodule.fg_top Submodule.fg_top

theorem fg_of_linear_equiv (e : M ≃ₗ[R] P) (h : (⊤ : Submodule R P).Fg) : (⊤ : Submodule R M).Fg :=
  e.symm.range ▸ map_top (e.symm : P →ₗ[R] M) ▸ h.map _
#align submodule.fg_of_linear_equiv Submodule.fg_of_linear_equiv

theorem Fg.prod {sb : Submodule R M} {sc : Submodule R P} (hsb : sb.Fg) (hsc : sc.Fg) : (sb.Prod sc).Fg :=
  let ⟨tb, htb⟩ := fg_def.1 hsb
  let ⟨tc, htc⟩ := fg_def.1 hsc
  fg_def.2
    ⟨LinearMap.inl R M P '' tb ∪ LinearMap.inr R M P '' tc, (htb.1.image _).union (htc.1.image _), by
      rw [LinearMap.span_inl_union_inr, htb.2, htc.2]⟩
#align submodule.fg.prod Submodule.Fg.prod

theorem fg_pi {ι : Type _} {M : ι → Type _} [Finite ι] [∀ i, AddCommMonoid (M i)] [∀ i, Module R (M i)]
    {p : ∀ i, Submodule R (M i)} (hsb : ∀ i, (p i).Fg) : (Submodule.pi Set.univ p).Fg := by
  classical simp_rw [fg_def] at hsb⊢
    refine' ⟨⋃ i, (LinearMap.single i : _ →ₗ[R] _) '' t i, Set.finite_Union fun i => (htf i).image _, _⟩
#align submodule.fg_pi Submodule.fg_pi

/-- If 0 → M' → M → M'' → 0 is exact and M' and M'' are
finitely generated then so is M. -/
theorem fg_of_fg_map_of_fg_inf_ker {R M P : Type _} [Ring R] [AddCommGroup M] [Module R M] [AddCommGroup P] [Module R P]
    (f : M →ₗ[R] P) {s : Submodule R M} (hs1 : (s.map f).Fg) (hs2 : (s ⊓ f.ker).Fg) : s.Fg := by
  haveI := Classical.decEq R
  haveI := Classical.decEq M
  haveI := Classical.decEq P
  cases' hs1 with t1 ht1
  cases' hs2 with t2 ht2
  have : ∀ y ∈ t1, ∃ x ∈ s, f x = y := by
    intro y hy
    have : y ∈ map f s := by
      rw [← ht1]
      exact subset_span hy
    rcases mem_map.1 this with ⟨x, hx1, hx2⟩
    exact ⟨x, hx1, hx2⟩
  have : ∃ g : P → M, ∀ y ∈ t1, g y ∈ s ∧ f (g y) = y := by
    choose g hg1 hg2
    exists fun y => if H : y ∈ t1 then g y H else 0
    intro y H
    constructor
    · simp only [dif_pos H]
      apply hg1
      
    · simp only [dif_pos H]
      apply hg2
      
  cases' this with g hg
  clear this
  exists t1.image g ∪ t2
  rw [Finset.coe_union, span_union, Finset.coe_image]
  apply le_antisymm
  · refine' sup_le (span_le.2 <| image_subset_iff.2 _) (span_le.2 _)
    · intro y hy
      exact (hg y hy).1
      
    · intro x hx
      have := subset_span hx
      rw [ht2] at this
      exact this.1
      
    
  intro x hx
  have : f x ∈ map f s := by
    rw [mem_map]
    exact ⟨x, hx, rfl⟩
  rw [← ht1, ← Set.image_id ↑t1, Finsupp.mem_span_image_iff_total] at this
  rcases this with ⟨l, hl1, hl2⟩
  refine'
    mem_sup.2
      ⟨(Finsupp.total M M R id).toFun ((Finsupp.lmapDomain R R g : (P →₀ R) → M →₀ R) l), _,
        x - Finsupp.total M M R id ((Finsupp.lmapDomain R R g : (P →₀ R) → M →₀ R) l), _, add_sub_cancel'_right _ _⟩
  · rw [← Set.image_id (g '' ↑t1), Finsupp.mem_span_image_iff_total]
    refine' ⟨_, _, rfl⟩
    haveI : Inhabited P := ⟨0⟩
    rw [← Finsupp.lmap_domain_supported _ _ g, mem_map]
    refine' ⟨l, hl1, _⟩
    rfl
    
  rw [ht2, mem_inf]
  constructor
  · apply s.sub_mem hx
    rw [Finsupp.total_apply, Finsupp.lmap_domain_apply, Finsupp.sum_map_domain_index]
    refine' s.sum_mem _
    · intro y hy
      exact s.smul_mem _ (hg y (hl1 hy)).1
      
    · exact zero_smul _
      
    · exact fun _ _ _ => add_smul _ _ _
      
    
  · rw [LinearMap.mem_ker, f.map_sub, ← hl2]
    rw [Finsupp.total_apply, Finsupp.total_apply, Finsupp.lmap_domain_apply]
    rw [Finsupp.sum_map_domain_index, Finsupp.sum, Finsupp.sum, f.map_sum]
    rw [sub_eq_zero]
    refine' Finset.sum_congr rfl fun y hy => _
    unfold id
    rw [f.map_smul, (hg y (hl1 hy)).2]
    · exact zero_smul _
      
    · exact fun _ _ _ => add_smul _ _ _
      
    
#align submodule.fg_of_fg_map_of_fg_inf_ker Submodule.fg_of_fg_map_of_fg_inf_ker

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:62:9: parse error -/
theorem fg_induction (R M : Type _) [Semiring R] [AddCommMonoid M] [Module R M] (P : Submodule R M → Prop)
    (h₁ : ∀ x, P (Submodule.span R {x})) (h₂ : ∀ M₁ M₂, P M₁ → P M₂ → P (M₁ ⊔ M₂)) (N : Submodule R M) (hN : N.Fg) :
    P N := by
  classical obtain ⟨s, rfl⟩ := hN
    · rw [Finset.coe_empty, Submodule.span_empty, ← Submodule.span_zero_singleton]
      apply h₁
      
#align submodule.fg_induction Submodule.fg_induction

/-- The kernel of the composition of two linear maps is finitely generated if both kernels are and
the first morphism is surjective. -/
theorem fg_ker_comp {R M N P : Type _} [Ring R] [AddCommGroup M] [Module R M] [AddCommGroup N] [Module R N]
    [AddCommGroup P] [Module R P] (f : M →ₗ[R] N) (g : N →ₗ[R] P) (hf1 : f.ker.Fg) (hf2 : g.ker.Fg)
    (hsur : Function.Surjective f) : (g.comp f).ker.Fg := by
  rw [LinearMap.ker_comp]
  apply fg_of_fg_map_of_fg_inf_ker f
  · rwa [Submodule.map_comap_eq, LinearMap.range_eq_top.2 hsur, top_inf_eq]
    
  · rwa [inf_of_le_right (show f.ker ≤ comap f g.ker from comap_mono bot_le)]
    
#align submodule.fg_ker_comp Submodule.fg_ker_comp

theorem fg_restrict_scalars {R S M : Type _} [CommSemiring R] [Semiring S] [Algebra R S] [AddCommGroup M] [Module S M]
    [Module R M] [IsScalarTower R S M] (N : Submodule S M) (hfin : N.Fg) (h : Function.Surjective (algebraMap R S)) :
    (Submodule.restrictScalars R N).Fg := by
  obtain ⟨X, rfl⟩ := hfin
  use X
  exact Submodule.span_eq_restrict_scalars R S M X h
#align submodule.fg_restrict_scalars Submodule.fg_restrict_scalars

theorem Fg.stablizes_of_supr_eq {M' : Submodule R M} (hM' : M'.Fg) (N : ℕ →o Submodule R M) (H : supr N = M') :
    ∃ n, M' = N n := by
  obtain ⟨S, hS⟩ := hM'
  have : ∀ s : S, ∃ n, (s : M) ∈ N n := fun s =>
    (Submodule.mem_supr_of_chain N s).mp
      (by
        rw [H, ← hS]
        exact Submodule.subset_span s.2)
  choose f hf
  use S.attach.sup f
  apply le_antisymm
  · conv_lhs => rw [← hS]
    rw [Submodule.span_le]
    intro s hs
    exact N.2 (Finset.le_sup <| S.mem_attach ⟨s, hs⟩) (hf _)
    
  · rw [← H]
    exact le_supr _ _
    
#align submodule.fg.stablizes_of_supr_eq Submodule.Fg.stablizes_of_supr_eq

/-- Finitely generated submodules are precisely compact elements in the submodule lattice. -/
theorem fg_iff_compact (s : Submodule R M) : s.Fg ↔ CompleteLattice.IsCompactElement s := by
  classical-- Introduce shorthand for span of an element
    let sp : M → Submodule R M := fun a => span R {a}
    exact fun t => by rfl
    · rintro ⟨t, rfl⟩
      rw [span_eq_supr_of_singleton_spans, ← supr_rw, ← Finset.sup_eq_supr t sp]
      apply CompleteLattice.finsetSupCompactOfCompact
      exact fun n _ => singleton_span_is_compact_element n
      
#align submodule.fg_iff_compact Submodule.fg_iff_compact

end Submodule

namespace Ideal

variable {R : Type _} {M : Type _} [Semiring R] [AddCommMonoid M] [Module R M]

/-- An ideal of `R` is finitely generated if it is the span of a finite subset of `R`.

This is defeq to `submodule.fg`, but unfolds more nicely. -/
def Fg (I : Ideal R) : Prop :=
  ∃ S : Finset R, Ideal.span ↑S = I
#align ideal.fg Ideal.Fg

/-- The image of a finitely generated ideal is finitely generated.

This is the `ideal` version of `submodule.fg.map`. -/
theorem Fg.map {R S : Type _} [Semiring R] [Semiring S] {I : Ideal R} (h : I.Fg) (f : R →+* S) : (I.map f).Fg := by
  classical obtain ⟨s, hs⟩ := h
    rw [Finset.coe_image, ← Ideal.map_span, hs]
#align ideal.fg.map Ideal.Fg.map

theorem fg_ker_comp {R S A : Type _} [CommRing R] [CommRing S] [CommRing A] (f : R →+* S) (g : S →+* A) (hf : f.ker.Fg)
    (hg : g.ker.Fg) (hsur : Function.Surjective f) : (g.comp f).ker.Fg := by
  letI : Algebra R S := RingHom.toAlgebra f
  letI : Algebra R A := RingHom.toAlgebra (g.comp f)
  letI : Algebra S A := RingHom.toAlgebra g
  letI : IsScalarTower R S A := IsScalarTower.of_algebra_map_eq fun _ => rfl
  let f₁ := Algebra.linearMap R S
  let g₁ := (IsScalarTower.toAlgHom R S A).toLinearMap
  exact Submodule.fg_ker_comp f₁ g₁ hf (Submodule.fg_restrict_scalars g.ker hg hsur) hsur
#align ideal.fg_ker_comp Ideal.fg_ker_comp

/-- A finitely generated idempotent ideal is generated by an idempotent element -/
theorem is_idempotent_elem_iff_of_fg {R : Type _} [CommRing R] (I : Ideal R) (h : I.Fg) :
    IsIdempotentElem I ↔ ∃ e : R, IsIdempotentElem e ∧ I = R ∙ e := by
  constructor
  · intro e
    obtain ⟨r, hr, hr'⟩ :=
      Submodule.exists_mem_and_smul_eq_self_of_fg_of_le_smul I I h
        (by
          rw [smul_eq_mul]
          exact e.ge)
    simp_rw [smul_eq_mul] at hr'
    refine' ⟨r, hr' r hr, antisymm _ ((Submodule.span_singleton_le_iff_mem _ _).mpr hr)⟩
    intro x hx
    rw [← hr' x hx]
    exact ideal.mem_span_singleton'.mpr ⟨_, mul_comm _ _⟩
    
  · rintro ⟨e, he, rfl⟩
    simp [IsIdempotentElem, Ideal.span_singleton_mul_span_singleton, he.eq]
    
#align ideal.is_idempotent_elem_iff_of_fg Ideal.is_idempotent_elem_iff_of_fg

theorem is_idempotent_elem_iff_eq_bot_or_top {R : Type _} [CommRing R] [IsDomain R] (I : Ideal R) (h : I.Fg) :
    IsIdempotentElem I ↔ I = ⊥ ∨ I = ⊤ := by
  constructor
  · intro H
    obtain ⟨e, he, rfl⟩ := (I.is_idempotent_elem_iff_of_fg h).mp H
    simp only [Ideal.submodule_span_eq, Ideal.span_singleton_eq_bot]
    apply or_of_or_of_imp_of_imp (is_idempotent_elem.iff_eq_zero_or_one.mp he) id
    rintro rfl
    simp
    
  · rintro (rfl | rfl) <;> simp [IsIdempotentElem]
    
#align ideal.is_idempotent_elem_iff_eq_bot_or_top Ideal.is_idempotent_elem_iff_eq_bot_or_top

theorem exists_radical_pow_le_of_fg {R : Type _} [CommSemiring R] (I : Ideal R) (h : I.radical.Fg) :
    ∃ n : ℕ, I.radical ^ n ≤ I := by
  have := le_refl I.radical
  revert this
  refine' Submodule.fg_induction _ _ (fun J => J ≤ I.radical → ∃ n : ℕ, J ^ n ≤ I) _ _ _ h
  · intro x hx
    obtain ⟨n, hn⟩ := hx (subset_span (Set.mem_singleton x))
    exact ⟨n, by rwa [← Ideal.span, span_singleton_pow, span_le, Set.singleton_subset_iff]⟩
    
  · intro J K hJ hK hJK
    obtain ⟨n, hn⟩ := hJ fun x hx => hJK <| Ideal.mem_sup_left hx
    obtain ⟨m, hm⟩ := hK fun x hx => hJK <| Ideal.mem_sup_right hx
    use n + m
    rw [← Ideal.add_eq_sup, add_pow, Ideal.sum_eq_sup, Finset.sup_le_iff]
    refine' fun i hi => ideal.mul_le_right.trans _
    obtain h | h := le_or_lt n i
    · exact ideal.mul_le_right.trans ((Ideal.pow_le_pow h).trans hn)
      
    · refine' ideal.mul_le_left.trans ((Ideal.pow_le_pow _).trans hm)
      rw [add_comm, Nat.add_sub_assoc h.le]
      apply Nat.le_add_right
      
    
#align ideal.exists_radical_pow_le_of_fg Ideal.exists_radical_pow_le_of_fg

end Ideal

/-- `is_noetherian R M` is the proposition that `M` is a Noetherian `R`-module,
implemented as the predicate that all `R`-submodules of `M` are finitely generated.
-/
class IsNoetherian (R M) [Semiring R] [AddCommMonoid M] [Module R M] : Prop where
  noetherian : ∀ s : Submodule R M, s.Fg
#align is_noetherian IsNoetherian

section

variable {R : Type _} {M : Type _} {P : Type _}

variable [Semiring R] [AddCommMonoid M] [AddCommMonoid P]

variable [Module R M] [Module R P]

open IsNoetherian

include R

/-- An R-module is Noetherian iff all its submodules are finitely-generated. -/
theorem is_noetherian_def : IsNoetherian R M ↔ ∀ s : Submodule R M, s.Fg :=
  ⟨fun h => h.noetherian, IsNoetherian.mk⟩
#align is_noetherian_def is_noetherian_def

theorem is_noetherian_submodule {N : Submodule R M} : IsNoetherian R N ↔ ∀ s : Submodule R M, s ≤ N → s.Fg := by
  refine'
    ⟨fun ⟨hn⟩ => fun s hs =>
      have : s ≤ N.subtype.range := N.range_subtype.symm ▸ hs
      Submodule.map_comap_eq_self this ▸ (hn _).map _,
      fun h => ⟨fun s => _⟩⟩
  have f := (Submodule.equivMapOfInjective N.subtype Subtype.val_injective s).symm
  have h₁ := h (s.map N.subtype) (Submodule.map_subtype_le N s)
  have h₂ : (⊤ : Submodule R (s.map N.subtype)).map f = ⊤ := by simp
  have h₃ := ((Submodule.fg_top _).2 h₁).map (↑f : _ →ₗ[R] s)
  exact (Submodule.fg_top _).1 (h₂ ▸ h₃)
#align is_noetherian_submodule is_noetherian_submodule

theorem is_noetherian_submodule_left {N : Submodule R M} : IsNoetherian R N ↔ ∀ s : Submodule R M, (N ⊓ s).Fg :=
  is_noetherian_submodule.trans ⟨fun H s => H _ inf_le_left, fun H s hs => inf_of_le_right hs ▸ H _⟩
#align is_noetherian_submodule_left is_noetherian_submodule_left

theorem is_noetherian_submodule_right {N : Submodule R M} : IsNoetherian R N ↔ ∀ s : Submodule R M, (s ⊓ N).Fg :=
  is_noetherian_submodule.trans ⟨fun H s => H _ inf_le_right, fun H s hs => inf_of_le_left hs ▸ H _⟩
#align is_noetherian_submodule_right is_noetherian_submodule_right

instance is_noetherian_submodule' [IsNoetherian R M] (N : Submodule R M) : IsNoetherian R N :=
  is_noetherian_submodule.2 fun _ _ => IsNoetherian.noetherian _
#align is_noetherian_submodule' is_noetherian_submodule'

theorem is_noetherian_of_le {s t : Submodule R M} [ht : IsNoetherian R t] (h : s ≤ t) : IsNoetherian R s :=
  is_noetherian_submodule.mpr fun s' hs' => is_noetherian_submodule.mp ht _ (le_trans hs' h)
#align is_noetherian_of_le is_noetherian_of_le

variable (M)

theorem is_noetherian_of_surjective (f : M →ₗ[R] P) (hf : f.range = ⊤) [IsNoetherian R M] : IsNoetherian R P :=
  ⟨fun s =>
    have : (s.comap f).map f = s := Submodule.map_comap_eq_self <| hf.symm ▸ le_top
    this ▸ (noetherian _).map _⟩
#align is_noetherian_of_surjective is_noetherian_of_surjective

variable {M}

theorem is_noetherian_of_linear_equiv (f : M ≃ₗ[R] P) [IsNoetherian R M] : IsNoetherian R P :=
  is_noetherian_of_surjective _ f.toLinearMap f.range
#align is_noetherian_of_linear_equiv is_noetherian_of_linear_equiv

theorem is_noetherian_top_iff : IsNoetherian R (⊤ : Submodule R M) ↔ IsNoetherian R M := by
  constructor <;> intro h
  · exact is_noetherian_of_linear_equiv (LinearEquiv.ofTop (⊤ : Submodule R M) rfl)
    
  · exact is_noetherian_of_linear_equiv (LinearEquiv.ofTop (⊤ : Submodule R M) rfl).symm
    
#align is_noetherian_top_iff is_noetherian_top_iff

theorem is_noetherian_of_injective [IsNoetherian R P] (f : M →ₗ[R] P) (hf : Function.Injective f) : IsNoetherian R M :=
  is_noetherian_of_linear_equiv (LinearEquiv.ofInjective f hf).symm
#align is_noetherian_of_injective is_noetherian_of_injective

theorem fg_of_injective [IsNoetherian R P] {N : Submodule R M} (f : M →ₗ[R] P) (hf : Function.Injective f) : N.Fg :=
  @IsNoetherian.noetherian _ _ _ (is_noetherian_of_injective f hf) N
#align fg_of_injective fg_of_injective

end

section

variable {R : Type _} {M : Type _} {P : Type _}

variable [Ring R] [AddCommGroup M] [AddCommGroup P]

variable [Module R M] [Module R P]

open IsNoetherian

include R

theorem is_noetherian_of_ker_bot [IsNoetherian R P] (f : M →ₗ[R] P) (hf : f.ker = ⊥) : IsNoetherian R M :=
  is_noetherian_of_linear_equiv (LinearEquiv.ofInjective f <| LinearMap.ker_eq_bot.mp hf).symm
#align is_noetherian_of_ker_bot is_noetherian_of_ker_bot

theorem fg_of_ker_bot [IsNoetherian R P] {N : Submodule R M} (f : M →ₗ[R] P) (hf : f.ker = ⊥) : N.Fg :=
  @IsNoetherian.noetherian _ _ _ (is_noetherian_of_ker_bot f hf) N
#align fg_of_ker_bot fg_of_ker_bot

instance is_noetherian_prod [IsNoetherian R M] [IsNoetherian R P] : IsNoetherian R (M × P) :=
  ⟨fun s =>
    Submodule.fg_of_fg_map_of_fg_inf_ker (LinearMap.snd R M P) (noetherian _) <|
      have : s ⊓ LinearMap.ker (LinearMap.snd R M P) ≤ LinearMap.range (LinearMap.inl R M P) := fun x ⟨hx1, hx2⟩ =>
        ⟨x.1, Prod.ext rfl <| Eq.symm <| LinearMap.mem_ker.1 hx2⟩
      Submodule.map_comap_eq_self this ▸ (noetherian _).map _⟩
#align is_noetherian_prod is_noetherian_prod

instance is_noetherian_pi {R ι : Type _} {M : ι → Type _} [Ring R] [∀ i, AddCommGroup (M i)] [∀ i, Module R (M i)]
    [Finite ι] [∀ i, IsNoetherian R (M i)] : IsNoetherian R (∀ i, M i) := by
  cases nonempty_fintype ι
  haveI := Classical.decEq ι
  suffices on_finset : ∀ s : Finset ι, IsNoetherian R (∀ i : s, M i)
  · let coe_e := Equiv.subtypeUnivEquiv Finset.mem_univ
    letI : IsNoetherian R (∀ i : Finset.univ, M (coe_e i)) := on_finset Finset.univ
    exact is_noetherian_of_linear_equiv (LinearEquiv.piCongrLeft R M coe_e)
    
  intro s
  induction' s using Finset.induction with a s has ih
  · exact ⟨fun s => by convert Submodule.fg_bot⟩
    
  refine' @is_noetherian_of_linear_equiv _ _ _ _ _ _ _ _ _ (@is_noetherian_prod _ (M a) _ _ _ _ _ _ _ ih)
  fconstructor
  · exact fun f i =>
      Or.by_cases (Finset.mem_insert.1 i.2) (fun h : i.1 = a => show M i.1 from Eq.recOn h.symm f.1) fun h : i.1 ∈ s =>
        show M i.1 from f.2 ⟨i.1, h⟩
    
  · intro f g
    ext i
    unfold Or.by_cases
    cases' i with i hi
    rcases Finset.mem_insert.1 hi with (rfl | h)
    · change _ = _ + _
      simp only [dif_pos]
      rfl
      
    · change _ = _ + _
      have : ¬i = a := by
        rintro rfl
        exact has h
      simp only [dif_neg this, dif_pos h]
      rfl
      
    
  · intro c f
    ext i
    unfold Or.by_cases
    cases' i with i hi
    rcases Finset.mem_insert.1 hi with (rfl | h)
    · change _ = c • _
      simp only [dif_pos]
      rfl
      
    · change _ = c • _
      have : ¬i = a := by
        rintro rfl
        exact has h
      simp only [dif_neg this, dif_pos h]
      rfl
      
    
  · exact fun f => (f ⟨a, Finset.mem_insert_self _ _⟩, fun i => f ⟨i.1, Finset.mem_insert_of_mem i.2⟩)
    
  · intro f
    apply Prod.ext
    · simp only [Or.by_cases, dif_pos]
      
    · ext ⟨i, his⟩
      have : ¬i = a := by
        rintro rfl
        exact has his
      simp only [Or.by_cases, this, not_false_iff, dif_neg]
      
    
  · intro f
    ext ⟨i, hi⟩
    rcases Finset.mem_insert.1 hi with (rfl | h)
    · simp only [Or.by_cases, dif_pos]
      
    · have : ¬i = a := by
        rintro rfl
        exact has h
      simp only [Or.by_cases, dif_neg this, dif_pos h]
      
    
#align is_noetherian_pi is_noetherian_pi

/-- A version of `is_noetherian_pi` for non-dependent functions. We need this instance because
sometimes Lean fails to apply the dependent version in non-dependent settings (e.g., it fails to
prove that `ι → ℝ` is finite dimensional over `ℝ`). -/
instance is_noetherian_pi' {R ι M : Type _} [Ring R] [AddCommGroup M] [Module R M] [Finite ι] [IsNoetherian R M] :
    IsNoetherian R (ι → M) :=
  is_noetherian_pi
#align is_noetherian_pi' is_noetherian_pi'

end

open IsNoetherian Submodule Function

section

universe w

variable {R M P : Type _} {N : Type w} [Semiring R] [AddCommMonoid M] [Module R M] [AddCommMonoid N] [Module R N]
  [AddCommMonoid P] [Module R P]

theorem is_noetherian_iff_well_founded :
    IsNoetherian R M ↔ WellFounded ((· > ·) : Submodule R M → Submodule R M → Prop) := by
  rw [(CompleteLattice.well_founded_characterisations <| Submodule R M).out 0 3]
  exact ⟨fun ⟨h⟩ => fun k => (fg_iff_compact k).mp (h k), fun h => ⟨fun k => (fg_iff_compact k).mpr (h k)⟩⟩
#align is_noetherian_iff_well_founded is_noetherian_iff_well_founded

theorem is_noetherian_iff_fg_well_founded :
    IsNoetherian R M ↔ WellFounded ((· > ·) : { N : Submodule R M // N.Fg } → { N : Submodule R M // N.Fg } → Prop) :=
  by
  let α := { N : Submodule R M // N.Fg }
  constructor
  · intro H
    let f : α ↪o Submodule R M := OrderEmbedding.subtype _
    exact OrderEmbedding.well_founded f.dual (is_noetherian_iff_well_founded.mp H)
    
  · intro H
    constructor
    intro N
    obtain ⟨⟨N₀, h₁⟩, e : N₀ ≤ N, h₂⟩ :=
      well_founded.well_founded_iff_has_max'.mp H { N' : α | N'.1 ≤ N } ⟨⟨⊥, Submodule.fg_bot⟩, bot_le⟩
    convert h₁
    refine' (e.antisymm _).symm
    by_contra h₃
    obtain ⟨x, hx₁ : x ∈ N, hx₂ : x ∉ N₀⟩ := set.not_subset.mp h₃
    apply hx₂
    have := h₂ ⟨(R ∙ x) ⊔ N₀, _⟩ _ _
    · injection this with eq
      rw [← Eq]
      exact (le_sup_left : (R ∙ x) ≤ (R ∙ x) ⊔ N₀) (Submodule.mem_span_singleton_self _)
      
    · exact Submodule.Fg.sup ⟨{x}, by rw [Finset.coe_singleton]⟩ h₁
      
    · exact sup_le ((Submodule.span_singleton_le_iff_mem _ _).mpr hx₁) e
      
    · show N₀ ≤ (R ∙ x) ⊔ N₀
      exact le_sup_right
      
    
#align is_noetherian_iff_fg_well_founded is_noetherian_iff_fg_well_founded

variable (R M)

theorem well_founded_submodule_gt (R M) [Semiring R] [AddCommMonoid M] [Module R M] :
    ∀ [IsNoetherian R M], WellFounded ((· > ·) : Submodule R M → Submodule R M → Prop) :=
  is_noetherian_iff_well_founded.mp
#align well_founded_submodule_gt well_founded_submodule_gt

variable {R M}

/-- A module is Noetherian iff every nonempty set of submodules has a maximal submodule among them.
-/
theorem set_has_maximal_iff_noetherian :
    (∀ a : Set <| Submodule R M, a.Nonempty → ∃ M' ∈ a, ∀ I ∈ a, M' ≤ I → I = M') ↔ IsNoetherian R M := by
  rw [is_noetherian_iff_well_founded, WellFounded.well_founded_iff_has_max']
#align set_has_maximal_iff_noetherian set_has_maximal_iff_noetherian

/-- A module is Noetherian iff every increasing chain of submodules stabilizes. -/
theorem monotone_stabilizes_iff_noetherian :
    (∀ f : ℕ →o Submodule R M, ∃ n, ∀ m, n ≤ m → f n = f m) ↔ IsNoetherian R M := by
  rw [is_noetherian_iff_well_founded, WellFounded.monotone_chain_condition]
#align monotone_stabilizes_iff_noetherian monotone_stabilizes_iff_noetherian

/-- If `∀ I > J, P I` implies `P J`, then `P` holds for all submodules. -/
theorem IsNoetherian.induction [IsNoetherian R M] {P : Submodule R M → Prop} (hgt : ∀ I, (∀ J > I, P J) → P I)
    (I : Submodule R M) : P I :=
  WellFounded.recursion (well_founded_submodule_gt R M) I hgt
#align is_noetherian.induction IsNoetherian.induction

end

section

universe w

variable {R M P : Type _} {N : Type w} [Ring R] [AddCommGroup M] [Module R M] [AddCommGroup N] [Module R N]
  [AddCommGroup P] [Module R P]

theorem finite_of_linear_independent [Nontrivial R] [IsNoetherian R M] {s : Set M}
    (hs : LinearIndependent R (coe : s → M)) : s.Finite := by
  refine'
    Classical.by_contradiction fun hf =>
      (RelEmbedding.well_founded_iff_no_descending_seq.1 (well_founded_submodule_gt R M)).elim' _
  have f : ℕ ↪ s := Set.Infinite.natEmbedding s hf
  have : ∀ n, coe ∘ f '' { m | m ≤ n } ⊆ s := by
    rintro n x ⟨y, hy₁, rfl⟩
    exact (f y).2
  have : ∀ a b : ℕ, a ≤ b ↔ span R (coe ∘ f '' { m | m ≤ a }) ≤ span R (coe ∘ f '' { m | m ≤ b }) := by
    intro a b
    rw [span_le_span_iff hs (this a) (this b), Set.image_subset_image_iff (subtype.coe_injective.comp f.injective),
      Set.subset_def]
    exact ⟨fun hab x (hxa : x ≤ a) => le_trans hxa hab, fun hx => hx a (le_refl a)⟩
  exact
    ⟨⟨fun n => span R (coe ∘ f '' { m | m ≤ n }), fun x y => by
        simp (config := { contextual := true }) [le_antisymm_iff, (this _ _).symm]⟩,
      by dsimp [GT.gt] <;> simp only [lt_iff_le_not_le, (this _ _).symm] <;> tauto⟩
#align finite_of_linear_independent finite_of_linear_independent

/-- If the first and final modules in a short exact sequence are noetherian,
  then the middle module is also noetherian. -/
theorem is_noetherian_of_range_eq_ker [IsNoetherian R M] [IsNoetherian R P] (f : M →ₗ[R] N) (g : N →ₗ[R] P)
    (hf : Function.Injective f) (hg : Function.Surjective g) (h : f.range = g.ker) : IsNoetherian R N :=
  is_noetherian_iff_well_founded.2 <|
    well_founded_gt_exact_sequence (well_founded_submodule_gt R M) (well_founded_submodule_gt R P) f.range
      (Submodule.map f) (Submodule.comap f) (Submodule.comap g) (Submodule.map g) (Submodule.gciMapComap hf)
      (Submodule.giMapComap hg) (by simp [Submodule.map_comap_eq, inf_comm]) (by simp [Submodule.comap_map_eq, h])
#align is_noetherian_of_range_eq_ker is_noetherian_of_range_eq_ker

/-- For any endomorphism of a Noetherian module, there is some nontrivial iterate
with disjoint kernel and range.
-/
theorem IsNoetherian.exists_endomorphism_iterate_ker_inf_range_eq_bot [I : IsNoetherian R M] (f : M →ₗ[R] M) :
    ∃ n : ℕ, n ≠ 0 ∧ (f ^ n).ker ⊓ (f ^ n).range = ⊥ := by
  obtain ⟨n, w⟩ :=
    monotone_stabilizes_iff_noetherian.mpr I (f.iterate_ker.comp ⟨fun n => n + 1, fun n m w => by linarith⟩)
  specialize w (2 * n + 1) (by linarith)
  dsimp at w
  refine' ⟨n + 1, Nat.succ_ne_zero _, _⟩
  rw [eq_bot_iff]
  rintro - ⟨h, ⟨y, rfl⟩⟩
  rw [mem_bot, ← LinearMap.mem_ker, w]
  erw [LinearMap.mem_ker] at h⊢
  change (f ^ (n + 1) * f ^ (n + 1)) y = 0 at h
  rw [← pow_add] at h
  convert h using 3
  linarith
#align
  is_noetherian.exists_endomorphism_iterate_ker_inf_range_eq_bot IsNoetherian.exists_endomorphism_iterate_ker_inf_range_eq_bot

/-- Any surjective endomorphism of a Noetherian module is injective. -/
theorem IsNoetherian.injective_of_surjective_endomorphism [IsNoetherian R M] (f : M →ₗ[R] M) (s : Surjective f) :
    Injective f := by
  obtain ⟨n, ne, w⟩ := IsNoetherian.exists_endomorphism_iterate_ker_inf_range_eq_bot f
  rw [linear_map.range_eq_top.mpr (LinearMap.iterate_surjective s n), inf_top_eq, LinearMap.ker_eq_bot] at w
  exact LinearMap.injective_of_iterate_injective Ne w
#align is_noetherian.injective_of_surjective_endomorphism IsNoetherian.injective_of_surjective_endomorphism

/-- Any surjective endomorphism of a Noetherian module is bijective. -/
theorem IsNoetherian.bijective_of_surjective_endomorphism [IsNoetherian R M] (f : M →ₗ[R] M) (s : Surjective f) :
    Bijective f :=
  ⟨IsNoetherian.injective_of_surjective_endomorphism f s, s⟩
#align is_noetherian.bijective_of_surjective_endomorphism IsNoetherian.bijective_of_surjective_endomorphism

/-- A sequence `f` of submodules of a noetherian module,
with `f (n+1)` disjoint from the supremum of `f 0`, ..., `f n`,
is eventually zero.
-/
theorem IsNoetherian.disjoint_partial_sups_eventually_bot [I : IsNoetherian R M] (f : ℕ → Submodule R M)
    (h : ∀ n, Disjoint (partialSups f n) (f (n + 1))) : ∃ n : ℕ, ∀ m, n ≤ m → f m = ⊥ := by
  -- A little off-by-one cleanup first:
  suffices t : ∃ n : ℕ, ∀ m, n ≤ m → f (m + 1) = ⊥
  · obtain ⟨n, w⟩ := t
    use n + 1
    rintro (_ | m) p
    · cases p
      
    · apply w
      exact nat.succ_le_succ_iff.mp p
      
    
  obtain ⟨n, w⟩ := monotone_stabilizes_iff_noetherian.mpr I (partialSups f)
  exact ⟨n, fun m p => (h m).eq_bot_of_ge <| sup_eq_left.1 <| (w (m + 1) <| le_add_right p).symm.trans <| w m p⟩
#align is_noetherian.disjoint_partial_sups_eventually_bot IsNoetherian.disjoint_partial_sups_eventually_bot

/-- If `M ⊕ N` embeds into `M`, for `M` noetherian over `R`, then `N` is trivial.
-/
noncomputable def IsNoetherian.equivPunitOfProdInjective [IsNoetherian R M] (f : M × N →ₗ[R] M) (i : Injective f) :
    N ≃ₗ[R] PUnit.{w + 1} := by
  apply Nonempty.some
  obtain ⟨n, w⟩ := IsNoetherian.disjoint_partial_sups_eventually_bot (f.tailing i) (f.tailings_disjoint_tailing i)
  specialize w n (le_refl n)
  apply Nonempty.intro
  refine' (f.tailing_linear_equiv i n).symm ≪≫ₗ _
  rw [w]
  exact Submodule.botEquivPunit
#align is_noetherian.equiv_punit_of_prod_injective IsNoetherian.equivPunitOfProdInjective

end

/-- A (semi)ring is Noetherian if it is Noetherian as a module over itself,
i.e. all its ideals are finitely generated.
-/
@[reducible]
def IsNoetherianRing (R) [Semiring R] :=
  IsNoetherian R R
#align is_noetherian_ring IsNoetherianRing

theorem is_noetherian_ring_iff {R} [Semiring R] : IsNoetherianRing R ↔ IsNoetherian R R :=
  Iff.rfl
#align is_noetherian_ring_iff is_noetherian_ring_iff

/-- A ring is Noetherian if and only if all its ideals are finitely-generated. -/
theorem is_noetherian_ring_iff_ideal_fg (R : Type _) [Semiring R] : IsNoetherianRing R ↔ ∀ I : Ideal R, I.Fg :=
  is_noetherian_ring_iff.trans is_noetherian_def
#align is_noetherian_ring_iff_ideal_fg is_noetherian_ring_iff_ideal_fg

-- see Note [lower instance priority]
instance (priority := 80) is_noetherian_of_finite (R M) [Finite M] [Semiring R] [AddCommMonoid M] [Module R M] :
    IsNoetherian R M :=
  ⟨fun s => ⟨(s : Set M).to_finite.toFinset, by rw [Set.Finite.coe_to_finset, Submodule.span_eq]⟩⟩
#align is_noetherian_of_finite is_noetherian_of_finite

-- see Note [lower instance priority]
/-- Modules over the trivial ring are Noetherian. -/
instance (priority := 100) is_noetherian_of_subsingleton (R M) [Subsingleton R] [Semiring R] [AddCommMonoid M]
    [Module R M] : IsNoetherian R M :=
  haveI := Module.subsingleton R M
  is_noetherian_of_finite R M
#align is_noetherian_of_subsingleton is_noetherian_of_subsingleton

theorem is_noetherian_of_submodule_of_noetherian (R M) [Semiring R] [AddCommMonoid M] [Module R M] (N : Submodule R M)
    (h : IsNoetherian R M) : IsNoetherian R N := by
  rw [is_noetherian_iff_well_founded] at h⊢
  exact OrderEmbedding.well_founded (Submodule.MapSubtype.orderEmbedding N).dual h
#align is_noetherian_of_submodule_of_noetherian is_noetherian_of_submodule_of_noetherian

instance Submodule.Quotient.is_noetherian {R} [Ring R] {M} [AddCommGroup M] [Module R M] (N : Submodule R M)
    [h : IsNoetherian R M] : IsNoetherian R (M ⧸ N) := by
  rw [is_noetherian_iff_well_founded] at h⊢
  exact OrderEmbedding.well_founded (Submodule.ComapMkq.orderEmbedding N).dual h
#align submodule.quotient.is_noetherian Submodule.Quotient.is_noetherian

/-- If `M / S / R` is a scalar tower, and `M / R` is Noetherian, then `M / S` is
also noetherian. -/
theorem is_noetherian_of_tower (R) {S M} [Semiring R] [Semiring S] [AddCommMonoid M] [HasSmul R S] [Module S M]
    [Module R M] [IsScalarTower R S M] (h : IsNoetherian R M) : IsNoetherian S M := by
  rw [is_noetherian_iff_well_founded] at h⊢
  refine' (Submodule.restrictScalarsEmbedding R S M).dual.WellFounded h
#align is_noetherian_of_tower is_noetherian_of_tower

instance Ideal.Quotient.is_noetherian_ring {R : Type _} [CommRing R] [h : IsNoetherianRing R] (I : Ideal R) :
    IsNoetherianRing (R ⧸ I) :=
  is_noetherian_ring_iff.mpr <| is_noetherian_of_tower R <| Submodule.Quotient.is_noetherian _
#align ideal.quotient.is_noetherian_ring Ideal.Quotient.is_noetherian_ring

theorem is_noetherian_of_fg_of_noetherian {R M} [Ring R] [AddCommGroup M] [Module R M] (N : Submodule R M)
    [IsNoetherianRing R] (hN : N.Fg) : IsNoetherian R N := by
  let ⟨s, hs⟩ := hN
  haveI := Classical.decEq M
  haveI := Classical.decEq R
  letI : IsNoetherian R R := by infer_instance
  have : ∀ x ∈ s, x ∈ N := fun x hx => hs ▸ Submodule.subset_span hx
  refine' @is_noetherian_of_surjective ((↑s : Set M) → R) _ _ _ (Pi.module _ _ _) _ _ _ is_noetherian_pi
  · fapply LinearMap.mk
    · exact fun f => ⟨∑ i in s.attach, f i • i.1, N.sum_mem fun c _ => N.smul_mem _ <| this _ c.2⟩
      
    · intro f g
      apply Subtype.eq
      change (∑ i in s.attach, (f i + g i) • _) = _
      simp only [add_smul, Finset.sum_add_distrib]
      rfl
      
    · intro c f
      apply Subtype.eq
      change (∑ i in s.attach, (c • f i) • _) = _
      simp only [smul_eq_mul, mul_smul]
      exact finset.smul_sum.symm
      
    
  rw [LinearMap.range_eq_top]
  rintro ⟨n, hn⟩
  change n ∈ N at hn
  rw [← hs, ← Set.image_id ↑s, Finsupp.mem_span_image_iff_total] at hn
  rcases hn with ⟨l, hl1, hl2⟩
  refine' ⟨fun x => l x, Subtype.ext _⟩
  change (∑ i in s.attach, l i • (i : M)) = n
  rw [@Finset.sum_attach M M s _ fun i => l i • i, ← hl2, Finsupp.total_apply, Finsupp.sum, eq_comm]
  refine' Finset.sum_subset hl1 fun x _ hx => _
  rw [Finsupp.not_mem_support_iff.1 hx, zero_smul]
#align is_noetherian_of_fg_of_noetherian is_noetherian_of_fg_of_noetherian

theorem is_noetherian_of_fg_of_noetherian' {R M} [Ring R] [AddCommGroup M] [Module R M] [IsNoetherianRing R]
    (h : (⊤ : Submodule R M).Fg) : IsNoetherian R M :=
  have : IsNoetherian R (⊤ : Submodule R M) := is_noetherian_of_fg_of_noetherian _ h
  is_noetherian_of_linear_equiv (LinearEquiv.ofTop (⊤ : Submodule R M) rfl)
#align is_noetherian_of_fg_of_noetherian' is_noetherian_of_fg_of_noetherian'

/-- In a module over a noetherian ring, the submodule generated by finitely many vectors is
noetherian. -/
theorem is_noetherian_span_of_finite (R) {M} [Ring R] [AddCommGroup M] [Module R M] [IsNoetherianRing R] {A : Set M}
    (hA : A.Finite) : IsNoetherian R (Submodule.span R A) :=
  is_noetherian_of_fg_of_noetherian _ (Submodule.fg_def.mpr ⟨A, hA, rfl⟩)
#align is_noetherian_span_of_finite is_noetherian_span_of_finite

theorem is_noetherian_ring_of_surjective (R) [Ring R] (S) [Ring S] (f : R →+* S) (hf : Function.Surjective f)
    [H : IsNoetherianRing R] : IsNoetherianRing S := by
  rw [is_noetherian_ring_iff, is_noetherian_iff_well_founded] at H⊢
  exact OrderEmbedding.well_founded (Ideal.orderEmbeddingOfSurjective f hf).dual H
#align is_noetherian_ring_of_surjective is_noetherian_ring_of_surjective

instance is_noetherian_ring_range {R} [Ring R] {S} [Ring S] (f : R →+* S) [IsNoetherianRing R] :
    IsNoetherianRing f.range :=
  is_noetherian_ring_of_surjective R f.range f.range_restrict f.range_restrict_surjective
#align is_noetherian_ring_range is_noetherian_ring_range

theorem is_noetherian_ring_of_ring_equiv (R) [Ring R] {S} [Ring S] (f : R ≃+* S) [IsNoetherianRing R] :
    IsNoetherianRing S :=
  is_noetherian_ring_of_surjective R S f.toRingHom f.toEquiv.Surjective
#align is_noetherian_ring_of_ring_equiv is_noetherian_ring_of_ring_equiv

theorem IsNoetherianRing.is_nilpotent_nilradical (R : Type _) [CommRing R] [IsNoetherianRing R] :
    IsNilpotent (nilradical R) := by
  obtain ⟨n, hn⟩ := Ideal.exists_radical_pow_le_of_fg (⊥ : Ideal R) (IsNoetherian.noetherian _)
  exact ⟨n, eq_bot_iff.mpr hn⟩
#align is_noetherian_ring.is_nilpotent_nilradical IsNoetherianRing.is_nilpotent_nilradical

namespace Submodule

section Map₂

variable {R M N P : Type _}

variable [CommSemiring R] [AddCommMonoid M] [AddCommMonoid N] [AddCommMonoid P]

variable [Module R M] [Module R N] [Module R P]

theorem Fg.map₂ (f : M →ₗ[R] N →ₗ[R] P) {p : Submodule R M} {q : Submodule R N} (hp : p.Fg) (hq : q.Fg) :
    (map₂ f p q).Fg :=
  let ⟨sm, hfm, hm⟩ := fg_def.1 hp
  let ⟨sn, hfn, hn⟩ := fg_def.1 hq
  fg_def.2 ⟨Set.image2 (fun m n => f m n) sm sn, hfm.image2 _ hfn, map₂_span_span R f sm sn ▸ hm ▸ hn ▸ rfl⟩
#align submodule.fg.map₂ Submodule.Fg.map₂

end Map₂

section Mul

variable {R : Type _} {A : Type _} [CommSemiring R] [Semiring A] [Algebra R A]

variable {M N : Submodule R A}

theorem Fg.mul (hm : M.Fg) (hn : N.Fg) : (M * N).Fg :=
  hm.map₂ _ hn
#align submodule.fg.mul Submodule.Fg.mul

theorem Fg.pow (h : M.Fg) (n : ℕ) : (M ^ n).Fg :=
  Nat.recOn n ⟨{1}, by simp [one_eq_span]⟩ fun n ih => by simpa [pow_succ] using h.mul ih
#align submodule.fg.pow Submodule.Fg.pow

end Mul

end Submodule

