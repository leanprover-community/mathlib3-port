/-
Copyright (c) 2019 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Anne Baanen

! This file was ported from Lean 3 source module linear_algebra.finrank
! leanprover-community/mathlib commit 198161d833f2c01498c39c266b0b3dbe2c7a8c07
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Dimension

/-!
# Finite dimension of vector spaces

Definition of the rank of a module, or dimension of a vector space, as a natural number.

## Main definitions

Defined is `finite_dimensional.finrank`, the dimension of a finite dimensional space, returning a
`nat`, as opposed to `module.rank`, which returns a `cardinal`. When the space has infinite
dimension, its `finrank` is by convention set to `0`.

The definition of `finrank` does not assume a `finite_dimensional` instance, but lemmas might.
Import `linear_algebra.finite_dimensional` to get access to these additional lemmas.

Formulas for the dimension are given for linear equivs, in `linear_equiv.finrank_eq`

## Implementation notes

Most results are deduced from the corresponding results for the general dimension (as a cardinal),
in `dimension.lean`. Not all results have been ported yet.

You should not assume that there has been any effort to state lemmas as generally as possible.
-/


universe u v v' w

open Classical Cardinal

open Cardinal Submodule Module Function

variable {K : Type u} {V : Type v}

namespace FiniteDimensional

open IsNoetherian

section DivisionRing

variable [DivisionRing K] [AddCommGroup V] [Module K V] {V₂ : Type v'} [AddCommGroup V₂]
  [Module K V₂]

/-- The rank of a module as a natural number.

Defined by convention to be `0` if the space has infinite rank.

For a vector space `V` over a field `K`, this is the same as the finite dimension
of `V` over `K`.
-/
noncomputable def finrank (R V : Type _) [Semiring R] [AddCommGroup V] [Module R V] : ℕ :=
  (Module.rank R V).toNat
#align finite_dimensional.finrank FiniteDimensional.finrank

theorem finrank_eq_of_dim_eq {n : ℕ} (h : Module.rank K V = ↑n) : finrank K V = n := by
  apply_fun to_nat  at h
  rw [to_nat_cast] at h
  exact_mod_cast h
#align finite_dimensional.finrank_eq_of_dim_eq FiniteDimensional.finrank_eq_of_dim_eq

theorem finrank_le_of_dim_le {n : ℕ} (h : Module.rank K V ≤ ↑n) : finrank K V ≤ n := by
  rwa [← Cardinal.to_nat_le_iff_le_of_lt_aleph_0, to_nat_cast] at h
  · exact h.trans_lt (nat_lt_aleph_0 n)
  · exact nat_lt_aleph_0 n
#align finite_dimensional.finrank_le_of_dim_le FiniteDimensional.finrank_le_of_dim_le

theorem finrank_lt_of_dim_lt {n : ℕ} (h : Module.rank K V < ↑n) : finrank K V < n := by
  rwa [← Cardinal.to_nat_lt_iff_lt_of_lt_aleph_0, to_nat_cast] at h
  · exact h.trans (nat_lt_aleph_0 n)
  · exact nat_lt_aleph_0 n
#align finite_dimensional.finrank_lt_of_dim_lt FiniteDimensional.finrank_lt_of_dim_lt

theorem dim_lt_of_finrank_lt {n : ℕ} (h : n < finrank K V) : ↑n < Module.rank K V := by
  rwa [← Cardinal.to_nat_lt_iff_lt_of_lt_aleph_0, to_nat_cast]
  · exact nat_lt_aleph_0 n
  · contrapose! h
    rw [finrank, Cardinal.to_nat_apply_of_aleph_0_le h]
    exact n.zero_le
#align finite_dimensional.dim_lt_of_finrank_lt FiniteDimensional.dim_lt_of_finrank_lt

/-- If a vector space has a finite basis, then its dimension is equal to the cardinality of the
basis. -/
theorem finrank_eq_card_basis {ι : Type w} [Fintype ι] (h : Basis ι K V) :
    finrank K V = Fintype.card ι :=
  finrank_eq_of_dim_eq (dim_eq_card_basis h)
#align finite_dimensional.finrank_eq_card_basis FiniteDimensional.finrank_eq_card_basis

/-- If a vector space has a finite basis, then its dimension is equal to the cardinality of the
basis. This lemma uses a `finset` instead of indexed types. -/
theorem finrank_eq_card_finset_basis {ι : Type w} {b : Finset ι} (h : Basis.{w} b K V) :
    finrank K V = Finset.card b := by rw [finrank_eq_card_basis h, Fintype.card_coe]
#align
  finite_dimensional.finrank_eq_card_finset_basis FiniteDimensional.finrank_eq_card_finset_basis

/-- A finite dimensional space is nontrivial if it has positive `finrank`. -/
theorem nontrivial_of_finrank_pos (h : 0 < finrank K V) : Nontrivial V :=
  dim_pos_iff_nontrivial.mp (dim_lt_of_finrank_lt h)
#align finite_dimensional.nontrivial_of_finrank_pos FiniteDimensional.nontrivial_of_finrank_pos

/-- A finite dimensional space is nontrivial if it has `finrank` equal to the successor of a
natural number. -/
theorem nontrivial_of_finrank_eq_succ {n : ℕ} (hn : finrank K V = n.succ) : Nontrivial V :=
  nontrivial_of_finrank_pos (by rw [hn] <;> exact n.succ_pos)
#align
  finite_dimensional.nontrivial_of_finrank_eq_succ FiniteDimensional.nontrivial_of_finrank_eq_succ

/-- A (finite dimensional) space that is a subsingleton has zero `finrank`. -/
theorem finrank_zero_of_subsingleton [h : Subsingleton V] : finrank K V = 0 := by
  by_contra h0
  obtain ⟨x, y, hxy⟩ := nontrivial_of_finrank_pos (Nat.pos_of_ne_zero h0)
  exact hxy (Subsingleton.elim _ _)
#align
  finite_dimensional.finrank_zero_of_subsingleton FiniteDimensional.finrank_zero_of_subsingleton

theorem Basis.subset_extend {s : Set V} (hs : LinearIndependent K (coe : s → V)) :
    s ⊆ hs.extend (Set.subset_univ _) :=
  hs.subset_extend _
#align finite_dimensional.basis.subset_extend FiniteDimensional.Basis.subset_extend

variable (K)

/-- A division_ring is one-dimensional as a vector space over itself. -/
@[simp]
theorem finrank_self : finrank K K = 1 :=
  finrank_eq_of_dim_eq (by simp)
#align finite_dimensional.finrank_self FiniteDimensional.finrank_self

/-- The vector space of functions on a fintype ι has finrank equal to the cardinality of ι. -/
@[simp]
theorem finrank_fintype_fun_eq_card {ι : Type v} [Fintype ι] : finrank K (ι → K) = Fintype.card ι :=
  finrank_eq_of_dim_eq dim_fun'
#align finite_dimensional.finrank_fintype_fun_eq_card FiniteDimensional.finrank_fintype_fun_eq_card

/-- The vector space of functions on `fin n` has finrank equal to `n`. -/
@[simp]
theorem finrank_fin_fun {n : ℕ} : finrank K (Fin n → K) = n := by simp
#align finite_dimensional.finrank_fin_fun FiniteDimensional.finrank_fin_fun

end DivisionRing

end FiniteDimensional

variable {K V}

section ZeroDim

variable [DivisionRing K] [AddCommGroup V] [Module K V]

open FiniteDimensional

theorem finrank_eq_zero_of_basis_imp_not_finite
    (h : ∀ s : Set V, Basis.{v} (s : Set V) K V → ¬s.Finite) : finrank K V = 0 :=
  dif_neg fun dim_lt =>
    h _ (Basis.ofVectorSpace K V) ((Basis.ofVectorSpace K V).finite_index_of_dim_lt_aleph_0 dim_lt)
#align finrank_eq_zero_of_basis_imp_not_finite finrank_eq_zero_of_basis_imp_not_finite

theorem finrank_eq_zero_of_basis_imp_false (h : ∀ s : Finset V, Basis.{v} (s : Set V) K V → False) :
    finrank K V = 0 :=
  finrank_eq_zero_of_basis_imp_not_finite fun s b hs =>
    h hs.toFinset
      (by 
        convert b
        simp)
#align finrank_eq_zero_of_basis_imp_false finrank_eq_zero_of_basis_imp_false

theorem finrank_eq_zero_of_not_exists_basis
    (h : ¬∃ s : Finset V, Nonempty (Basis (s : Set V) K V)) : finrank K V = 0 :=
  finrank_eq_zero_of_basis_imp_false fun s b => h ⟨s, ⟨b⟩⟩
#align finrank_eq_zero_of_not_exists_basis finrank_eq_zero_of_not_exists_basis

theorem finrank_eq_zero_of_not_exists_basis_finite
    (h : ¬∃ (s : Set V)(b : Basis.{v} (s : Set V) K V), s.Finite) : finrank K V = 0 :=
  finrank_eq_zero_of_basis_imp_not_finite fun s b hs => h ⟨s, b, hs⟩
#align finrank_eq_zero_of_not_exists_basis_finite finrank_eq_zero_of_not_exists_basis_finite

theorem finrank_eq_zero_of_not_exists_basis_finset (h : ¬∃ s : Finset V, Nonempty (Basis s K V)) :
    finrank K V = 0 :=
  finrank_eq_zero_of_basis_imp_false fun s b => h ⟨s, ⟨b⟩⟩
#align finrank_eq_zero_of_not_exists_basis_finset finrank_eq_zero_of_not_exists_basis_finset

variable (K V)

@[simp]
theorem finrank_bot : finrank K (⊥ : Submodule K V) = 0 :=
  finrank_eq_of_dim_eq (dim_bot _ _)
#align finrank_bot finrank_bot

end ZeroDim

namespace LinearEquiv

open FiniteDimensional

variable [DivisionRing K] [AddCommGroup V] [Module K V] {V₂ : Type v'} [AddCommGroup V₂]
  [Module K V₂]

variable {R M M₂ : Type _} [Ring R] [AddCommGroup M] [AddCommGroup M₂]

variable [Module R M] [Module R M₂]

/-- The dimension of a finite dimensional space is preserved under linear equivalence. -/
theorem finrank_eq (f : M ≃ₗ[R] M₂) : finrank R M = finrank R M₂ := by
  unfold finrank
  rw [← Cardinal.to_nat_lift, f.lift_dim_eq, Cardinal.to_nat_lift]
#align linear_equiv.finrank_eq LinearEquiv.finrank_eq

/-- Pushforwards of finite-dimensional submodules along a `linear_equiv` have the same finrank. -/
theorem finrank_map_eq (f : M ≃ₗ[R] M₂) (p : Submodule R M) :
    finrank R (p.map (f : M →ₗ[R] M₂)) = finrank R p :=
  (f.submoduleMap p).finrank_eq.symm
#align linear_equiv.finrank_map_eq LinearEquiv.finrank_map_eq

end LinearEquiv

namespace LinearMap

open FiniteDimensional

section DivisionRing

variable [DivisionRing K] [AddCommGroup V] [Module K V] {V₂ : Type v'} [AddCommGroup V₂]
  [Module K V₂]

/-- The dimensions of the domain and range of an injective linear map are equal. -/
theorem finrank_range_of_inj {f : V →ₗ[K] V₂} (hf : Function.Injective f) :
    finrank K f.range = finrank K V := by rw [(LinearEquiv.ofInjective f hf).finrank_eq]
#align linear_map.finrank_range_of_inj LinearMap.finrank_range_of_inj

end DivisionRing

end LinearMap

open Module FiniteDimensional

section

variable [DivisionRing K] [AddCommGroup V] [Module K V]

@[simp]
theorem finrank_top : finrank K (⊤ : Submodule K V) = finrank K V := by
  unfold finrank
  simp [dim_top]
#align finrank_top finrank_top

end

namespace Submodule

section DivisionRing

variable [DivisionRing K] [AddCommGroup V] [Module K V] {V₂ : Type v'} [AddCommGroup V₂]
  [Module K V₂]

theorem lt_of_le_of_finrank_lt_finrank {s t : Submodule K V} (le : s ≤ t)
    (lt : finrank K s < finrank K t) : s < t :=
  lt_of_le_of_ne le fun h => ne_of_lt lt (by rw [h])
#align submodule.lt_of_le_of_finrank_lt_finrank Submodule.lt_of_le_of_finrank_lt_finrank

theorem lt_top_of_finrank_lt_finrank {s : Submodule K V} (lt : finrank K s < finrank K V) : s < ⊤ :=
  by 
  rw [← @finrank_top K V] at lt
  exact lt_of_le_of_finrank_lt_finrank le_top lt
#align submodule.lt_top_of_finrank_lt_finrank Submodule.lt_top_of_finrank_lt_finrank

end DivisionRing

end Submodule

section Span

open Submodule

section DivisionRing

variable [DivisionRing K] [AddCommGroup V] [Module K V]

variable (K)

/-- The rank of a set of vectors as a natural number. -/
protected noncomputable def Set.finrank (s : Set V) : ℕ :=
  finrank K (span K s)
#align set.finrank Set.finrank

variable {K}

theorem finrank_span_le_card (s : Set V) [Fintype s] : finrank K (span K s) ≤ s.toFinset.card :=
  finrank_le_of_dim_le (by simpa using dim_span_le s)
#align finrank_span_le_card finrank_span_le_card

theorem finrank_span_finset_le_card (s : Finset V) : (s : Set V).finrank K ≤ s.card :=
  calc
    (s : Set V).finrank K ≤ (s : Set V).toFinset.card := finrank_span_le_card s
    _ = s.card := by simp
    
#align finrank_span_finset_le_card finrank_span_finset_le_card

theorem finrank_range_le_card {ι : Type _} [Fintype ι] {b : ι → V} :
    (Set.range b).finrank K ≤ Fintype.card ι :=
  (finrank_span_le_card _).trans <| by 
    rw [Set.to_finset_range]
    exact Finset.card_image_le
#align finrank_range_le_card finrank_range_le_card

theorem finrank_span_eq_card {ι : Type _} [Fintype ι] {b : ι → V} (hb : LinearIndependent K b) :
    finrank K (span K (Set.range b)) = Fintype.card ι :=
  finrank_eq_of_dim_eq
    (by 
      have : Module.rank K (span K (Set.range b)) = (#Set.range b) := dim_span hb
      rwa [← lift_inj, mk_range_eq_of_injective hb.injective, Cardinal.mk_fintype, lift_nat_cast,
        lift_eq_nat_iff] at this)
#align finrank_span_eq_card finrank_span_eq_card

theorem finrank_span_set_eq_card (s : Set V) [Fintype s] (hs : LinearIndependent K (coe : s → V)) :
    finrank K (span K s) = s.toFinset.card :=
  finrank_eq_of_dim_eq
    (by 
      have : Module.rank K (span K s) = (#s) := dim_span_set hs
      rwa [Cardinal.mk_fintype, ← Set.to_finset_card] at this)
#align finrank_span_set_eq_card finrank_span_set_eq_card

theorem finrank_span_finset_eq_card (s : Finset V) (hs : LinearIndependent K (coe : s → V)) :
    finrank K (span K (s : Set V)) = s.card := by
  convert finrank_span_set_eq_card (↑s) hs
  ext
  simp
#align finrank_span_finset_eq_card finrank_span_finset_eq_card

theorem span_lt_of_subset_of_card_lt_finrank {s : Set V} [Fintype s] {t : Submodule K V}
    (subset : s ⊆ t) (card_lt : s.toFinset.card < finrank K t) : span K s < t :=
  lt_of_le_of_finrank_lt_finrank (span_le.mpr subset)
    (lt_of_le_of_lt (finrank_span_le_card _) card_lt)
#align span_lt_of_subset_of_card_lt_finrank span_lt_of_subset_of_card_lt_finrank

theorem span_lt_top_of_card_lt_finrank {s : Set V} [Fintype s]
    (card_lt : s.toFinset.card < finrank K V) : span K s < ⊤ :=
  lt_top_of_finrank_lt_finrank (lt_of_le_of_lt (finrank_span_le_card _) card_lt)
#align span_lt_top_of_card_lt_finrank span_lt_top_of_card_lt_finrank

end DivisionRing

end Span

section Basis

section DivisionRing

variable [DivisionRing K] [AddCommGroup V] [Module K V]

theorem linear_independent_of_top_le_span_of_card_eq_finrank {ι : Type _} [Fintype ι] {b : ι → V}
    (spans : ⊤ ≤ span K (Set.range b)) (card_eq : Fintype.card ι = finrank K V) :
    LinearIndependent K b :=
  linear_independent_iff'.mpr fun s g dependent i i_mem_s => by
    by_contra gx_ne_zero
    -- We'll derive a contradiction by showing `b '' (univ \ {i})` of cardinality `n - 1`
    -- spans a vector space of dimension `n`.
    refine'
      not_le_of_gt
        (span_lt_top_of_card_lt_finrank
          (show (b '' (Set.univ \ {i})).toFinset.card < finrank K V from _))
        _
    ·
      calc
        (b '' (Set.univ \ {i})).toFinset.card = ((Set.univ \ {i}).toFinset.image b).card := by
          rw [Set.to_finset_card, Fintype.card_of_finset]
        _ ≤ (Set.univ \ {i}).toFinset.card := Finset.card_image_le
        _ = (finset.univ.erase i).card := congr_arg Finset.card (Finset.ext (by simp [and_comm']))
        _ < finset.univ.card := Finset.card_erase_lt_of_mem (Finset.mem_univ i)
        _ = finrank K V := card_eq
        
    -- We already have that `b '' univ` spans the whole space,
    -- so we only need to show that the span of `b '' (univ \ {i})` contains each `b j`.
    refine' spans.trans (span_le.mpr _)
    rintro _ ⟨j, rfl, rfl⟩
    -- The case that `j ≠ i` is easy because `b j ∈ b '' (univ \ {i})`.
    by_cases j_eq : j = i
    swap
    · refine' subset_span ⟨j, (Set.mem_diff _).mpr ⟨Set.mem_univ _, _⟩, rfl⟩
      exact mt set.mem_singleton_iff.mp j_eq
    -- To show `b i ∈ span (b '' (univ \ {i}))`, we use that it's a weighted sum
    -- of the other `b j`s.
    rw [j_eq, SetLike.mem_coe, show b i = -((g i)⁻¹ • (s.erase i).Sum fun j => g j • b j) from _]
    · refine' neg_mem (smul_mem _ _ (sum_mem fun k hk => _))
      obtain ⟨k_ne_i, k_mem⟩ := finset.mem_erase.mp hk
      refine' smul_mem _ _ (subset_span ⟨k, _, rfl⟩)
      simpa using k_mem
    -- To show `b i` is a weighted sum of the other `b j`s, we'll rewrite this sum
    -- to have the form of the assumption `dependent`.
    apply eq_neg_of_add_eq_zero_left
    calc
      (b i + (g i)⁻¹ • (s.erase i).Sum fun j => g j • b j) =
          (g i)⁻¹ • (g i • b i + (s.erase i).Sum fun j => g j • b j) :=
        by rw [smul_add, ← mul_smul, inv_mul_cancel gx_ne_zero, one_smul]
      _ = (g i)⁻¹ • 0 := congr_arg _ _
      _ = 0 := smul_zero _
      
    -- And then it's just a bit of manipulation with finite sums.
    rwa [← Finset.insert_erase i_mem_s, Finset.sum_insert (Finset.not_mem_erase _ _)] at dependent
#align
  linear_independent_of_top_le_span_of_card_eq_finrank linear_independent_of_top_le_span_of_card_eq_finrank

/-- A finite family of vectors is linearly independent if and only if
its cardinality equals the dimension of its span. -/
theorem linear_independent_iff_card_eq_finrank_span {ι : Type _} [Fintype ι] {b : ι → V} :
    LinearIndependent K b ↔ Fintype.card ι = (Set.range b).finrank K := by
  constructor
  · intro h
    exact (finrank_span_eq_card h).symm
  · intro hc
    let f := Submodule.subtype (span K (Set.range b))
    let b' : ι → span K (Set.range b) := fun i =>
      ⟨b i, mem_span.2 fun p hp => hp (Set.mem_range_self _)⟩
    have hs : ⊤ ≤ span K (Set.range b') := by 
      intro x
      have h : span K (f '' Set.range b') = map f (span K (Set.range b')) := span_image f
      have hf : f '' Set.range b' = Set.range b := by
        ext x
        simp [Set.mem_image, Set.mem_range]
      rw [hf] at h
      have hx : (x : V) ∈ span K (Set.range b) := x.property
      conv at hx => 
        congr
        skip
        rw [h]
      simpa [mem_map] using hx
    have hi : f.ker = ⊥ := ker_subtype _
    convert (linear_independent_of_top_le_span_of_card_eq_finrank hs hc).map' _ hi
#align linear_independent_iff_card_eq_finrank_span linear_independent_iff_card_eq_finrank_span

theorem linear_independent_iff_card_le_finrank_span {ι : Type _} [Fintype ι] {b : ι → V} :
    LinearIndependent K b ↔ Fintype.card ι ≤ (Set.range b).finrank K := by
  rw [linear_independent_iff_card_eq_finrank_span, finrank_range_le_card.le_iff_eq]
#align linear_independent_iff_card_le_finrank_span linear_independent_iff_card_le_finrank_span

/-- A family of `finrank K V` vectors forms a basis if they span the whole space. -/
noncomputable def basisOfTopLeSpanOfCardEqFinrank {ι : Type _} [Fintype ι] (b : ι → V)
    (le_span : ⊤ ≤ span K (Set.range b)) (card_eq : Fintype.card ι = finrank K V) : Basis ι K V :=
  Basis.mk (linear_independent_of_top_le_span_of_card_eq_finrank le_span card_eq) le_span
#align basis_of_top_le_span_of_card_eq_finrank basisOfTopLeSpanOfCardEqFinrank

@[simp]
theorem coe_basis_of_top_le_span_of_card_eq_finrank {ι : Type _} [Fintype ι] (b : ι → V)
    (le_span : ⊤ ≤ span K (Set.range b)) (card_eq : Fintype.card ι = finrank K V) :
    ⇑(basisOfTopLeSpanOfCardEqFinrank b le_span card_eq) = b :=
  Basis.coe_mk _ _
#align coe_basis_of_top_le_span_of_card_eq_finrank coe_basis_of_top_le_span_of_card_eq_finrank

/-- A finset of `finrank K V` vectors forms a basis if they span the whole space. -/
@[simps]
noncomputable def finsetBasisOfTopLeSpanOfCardEqFinrank {s : Finset V}
    (le_span : ⊤ ≤ span K (s : Set V)) (card_eq : s.card = finrank K V) : Basis (s : Set V) K V :=
  basisOfTopLeSpanOfCardEqFinrank (coe : (s : Set V) → V)
    ((@Subtype.range_coe_subtype _ fun x => x ∈ s).symm ▸ le_span)
    (trans (Fintype.card_coe _) card_eq)
#align finset_basis_of_top_le_span_of_card_eq_finrank finsetBasisOfTopLeSpanOfCardEqFinrank

/-- A set of `finrank K V` vectors forms a basis if they span the whole space. -/
@[simps]
noncomputable def setBasisOfTopLeSpanOfCardEqFinrank {s : Set V} [Fintype s]
    (le_span : ⊤ ≤ span K s) (card_eq : s.toFinset.card = finrank K V) : Basis s K V :=
  basisOfTopLeSpanOfCardEqFinrank (coe : s → V) ((@Subtype.range_coe_subtype _ s).symm ▸ le_span)
    (trans s.to_finset_card.symm card_eq)
#align set_basis_of_top_le_span_of_card_eq_finrank setBasisOfTopLeSpanOfCardEqFinrank

end DivisionRing

end Basis

/-!
We now give characterisations of `finrank K V = 1` and `finrank K V ≤ 1`.
-/


section finrank_eq_one

variable [DivisionRing K] [AddCommGroup V] [Module K V]

/-- If there is a nonzero vector and every other vector is a multiple of it,
then the module has dimension one. -/
theorem finrank_eq_one (v : V) (n : v ≠ 0) (h : ∀ w : V, ∃ c : K, c • v = w) : finrank K V = 1 := by
  obtain ⟨b⟩ := (Basis.basis_singleton_iff PUnit).mpr ⟨v, n, h⟩
  rw [finrank_eq_card_basis b, Fintype.card_punit]
#align finrank_eq_one finrank_eq_one

/-- If every vector is a multiple of some `v : V`, then `V` has dimension at most one.
-/
theorem finrank_le_one (v : V) (h : ∀ w : V, ∃ c : K, c • v = w) : finrank K V ≤ 1 := by
  rcases eq_or_ne v 0 with (rfl | hn)
  · haveI :=
      subsingleton_of_forall_eq (0 : V) fun w => by
        obtain ⟨c, rfl⟩ := h w
        simp
    rw [finrank_zero_of_subsingleton]
    exact zero_le_one
  · exact (finrank_eq_one v hn h).le
#align finrank_le_one finrank_le_one

end finrank_eq_one

section SubalgebraDim

open Module

variable {F E : Type _} [Field F] [Ring E] [Algebra F E]

@[simp]
theorem Subalgebra.dim_bot [Nontrivial E] : Module.rank F (⊥ : Subalgebra F E) = 1 :=
  ((Subalgebra.toSubmoduleEquiv (⊥ : Subalgebra F E)).symm.trans <|
          LinearEquiv.ofEq _ _ Algebra.to_submodule_bot).dim_eq.trans <|
    by 
    rw [dim_span_set]
    exacts[mk_singleton _, linear_independent_singleton one_ne_zero]
#align subalgebra.dim_bot Subalgebra.dim_bot

@[simp]
theorem Subalgebra.dim_to_submodule (S : Subalgebra F E) :
    Module.rank F S.toSubmodule = Module.rank F S :=
  rfl
#align subalgebra.dim_to_submodule Subalgebra.dim_to_submodule

@[simp]
theorem Subalgebra.finrank_to_submodule (S : Subalgebra F E) :
    finrank F S.toSubmodule = finrank F S :=
  rfl
#align subalgebra.finrank_to_submodule Subalgebra.finrank_to_submodule

theorem subalgebra_top_dim_eq_submodule_top_dim :
    Module.rank F (⊤ : Subalgebra F E) = Module.rank F (⊤ : Submodule F E) := by
  rw [← Algebra.top_to_submodule]
  rfl
#align subalgebra_top_dim_eq_submodule_top_dim subalgebra_top_dim_eq_submodule_top_dim

theorem subalgebra_top_finrank_eq_submodule_top_finrank :
    finrank F (⊤ : Subalgebra F E) = finrank F (⊤ : Submodule F E) := by
  rw [← Algebra.top_to_submodule]
  rfl
#align
  subalgebra_top_finrank_eq_submodule_top_finrank subalgebra_top_finrank_eq_submodule_top_finrank

theorem Subalgebra.dim_top : Module.rank F (⊤ : Subalgebra F E) = Module.rank F E := by
  rw [subalgebra_top_dim_eq_submodule_top_dim]
  exact dim_top F E
#align subalgebra.dim_top Subalgebra.dim_top

@[simp]
theorem Subalgebra.finrank_bot [Nontrivial E] : finrank F (⊥ : Subalgebra F E) = 1 :=
  finrank_eq_of_dim_eq (by simp)
#align subalgebra.finrank_bot Subalgebra.finrank_bot

end SubalgebraDim

