/-
Copyright (c) 202 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov
-/
import Mathbin.SetTheory.Ordinal.Basic
import Mathbin.Topology.MetricSpace.EmetricSpace
import Mathbin.Topology.Paracompact

/-!
# (Extended) metric spaces are paracompact

In this file we provide two instances:

* `emetric.paracompact_space`: a `pseudo_emetric_space` is paracompact; formalization is based
  on [MR0236876];
* `emetric.normal_of_metric`: an `emetric_space` is a normal topological space.

## Tags

metric space, paracompact space, normal space
-/


variable {α : Type _}

open Ennreal TopologicalSpace

open Set

namespace Emetric

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in apply_rules #[["[", expr ennreal.add_lt_add, "]"], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error -/
-- See note [lower instance priority]
/-- A `pseudo_emetric_space` is always a paracompact space. Formalization is based
on [MR0236876]. -/
instance (priority := 100) [PseudoEmetricSpace α] : ParacompactSpace α := by
  classical/- We start with trivial observations about `1 / 2 ^ k`. Here and below we use `1 / 2 ^ k` in
      the comments and `2⁻¹ ^ k` in the code. -/
    have pow_pos : ∀ k : ℕ, (0 : ℝ≥0∞) < 2⁻¹ ^ k
    have hpow_le : ∀ {m n : ℕ}, m ≤ n → (2⁻¹ : ℝ≥0∞) ^ n ≤ 2⁻¹ ^ m
    have h2pow : ∀ n : ℕ, 2 * (2⁻¹ : ℝ≥0∞) ^ (n + 1) = 2⁻¹ ^ n
    -- Consider an open covering `S : set (set α)`
    refine' ⟨fun ι s ho hcov => _⟩
    -- choose a well founded order on `S`
    letI : LinearOrder ι := linearOrderOfSTO WellOrderingRel
    -- Let `ind x` be the minimal index `s : S` such that `x ∈ s`.
    set ind : α → ι := fun x => wf.min { i : ι | x ∈ s i } (hcov x)
    exact fun x => wf.min_mem _ (hcov x)
    exact fun x i hlt hxi => wf.not_lt_min _ (hcov x) hxi hlt
    have Dn :
      ∀ n i,
        D n i =
          ⋃ (x : α) (hxs : ind x = i) (hb : ball x (3 * 2⁻¹ ^ n) ⊆ s i) (hlt : ∀ m < n, ∀ (j : ι), x ∉ D m j),
            ball x (2⁻¹ ^ n)
    have memD :
      ∀ {n i y},
        y ∈ D n i ↔
          ∃ (x : _)(hi : ind x = i)(hb : ball x (3 * 2⁻¹ ^ n) ⊆ s i)(hlt : ∀ m < n, ∀ (j : ι), x ∉ D m j),
            edist y x < 2⁻¹ ^ n
    -- The sets `D n i` cover the whole space. Indeed, for each `x` we can choose `n` such that
    -- `ball x (3 / 2 ^ n) ⊆ s (ind x)`, then either `x ∈ D n i`, or `x ∈ D m i` for some `m < n`.
    have Dcov : ∀ x, ∃ n i, x ∈ D n i
    -- Each `D n i` is a union of open balls, hence it is an open set
    have Dopen : ∀ n i, IsOpen (D n i)
    -- the covering `D n i` is a refinement of the original covering: `D n i ⊆ s i`
    have HDS : ∀ n i, D n i ⊆ s i
    -- Let us show the rest of the properties. Since the definition expects a family indexed
    -- by a single parameter, we use `ℕ × ι` as the domain.
    refine' ⟨ℕ × ι, fun ni => D ni.1 ni.2, fun _ => Dopen _ _, _, _, fun ni => ⟨ni.2, HDS _ _⟩⟩
    · /- Let us prove that the covering `D n i` is locally finite. Take a point `x` and choose
          `n`, `i` so that `x ∈ D n i`. Since `D n i` is an open set, we can choose `k` so that
          `B = ball x (1 / 2 ^ (n + k + 1)) ⊆ D n i`. -/
      intro x
      rcases Dcov x with ⟨n, i, hn⟩
      have : D n i ∈ 𝓝 x := IsOpen.mem_nhds (Dopen _ _) hn
      rcases(nhds_basis_uniformity uniformity_basis_edist_inv_two_pow).mem_iff.1 this with
        ⟨k, -, hsub : ball x (2⁻¹ ^ k) ⊆ D n i⟩
      set B := ball x (2⁻¹ ^ (n + k + 1))
      refine' ⟨B, ball_mem_nhds _ (pow_pos _), _⟩
      -- The sets `D m i`, `m > n + k`, are disjoint with `B`
      have Hgt : ∀ m ≥ n + k + 1, ∀ (i : ι), Disjoint (D m i) B := by
        rintro m hm i
        rw [disjoint_iff_inf_le]
        rintro y ⟨hym, hyx⟩
        rcases memD.1 hym with ⟨z, rfl, hzi, H, hz⟩
        have : z ∉ ball x (2⁻¹ ^ k) := fun hz => H n (by linarith) i (hsub hz)
        apply this
        calc
          edist z x ≤ edist y z + edist y x := edist_triangle_left _ _ _
          _ < 2⁻¹ ^ m + 2⁻¹ ^ (n + k + 1) := Ennreal.add_lt_add hz hyx
          _ ≤ 2⁻¹ ^ (k + 1) + 2⁻¹ ^ (k + 1) := add_le_add (hpow_le <| by linarith) (hpow_le <| by linarith)
          _ = 2⁻¹ ^ k := by rw [← two_mul, h2pow]
          
      -- For each `m ≤ n + k` there is at most one `j` such that `D m j ∩ B` is nonempty.
      have Hle : ∀ m ≤ n + k, Set.Subsingleton { j | (D m j ∩ B).Nonempty } := by
        rintro m hm j₁ ⟨y, hyD, hyB⟩ j₂ ⟨z, hzD, hzB⟩
        by_contra h
        wlog h : j₁ < j₂ := Ne.lt_or_lt h using j₁ j₂ y z, j₂ j₁ z y
        rcases memD.1 hyD with ⟨y', rfl, hsuby, -, hdisty⟩
        rcases memD.1 hzD with ⟨z', rfl, -, -, hdistz⟩
        suffices : edist z' y' < 3 * 2⁻¹ ^ m
        exact nmem_of_lt_ind h (hsuby this)
        calc
          edist z' y' ≤ edist z' x + edist x y' := edist_triangle _ _ _
          _ ≤ edist z z' + edist z x + (edist y x + edist y y') :=
            add_le_add (edist_triangle_left _ _ _) (edist_triangle_left _ _ _)
          _ < 2⁻¹ ^ m + 2⁻¹ ^ (n + k + 1) + (2⁻¹ ^ (n + k + 1) + 2⁻¹ ^ m) := by
            trace
              "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in apply_rules #[[\"[\", expr ennreal.add_lt_add, \"]\"], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error"
          _ = 2 * (2⁻¹ ^ m + 2⁻¹ ^ (n + k + 1)) := by simp only [two_mul, add_comm]
          _ ≤ 2 * (2⁻¹ ^ m + 2⁻¹ ^ (m + 1)) :=
            Ennreal.mul_le_mul le_rfl <| add_le_add le_rfl <| hpow_le (add_le_add hm le_rfl)
          _ = 3 * 2⁻¹ ^ m := by rw [mul_add, h2pow, bit1, add_mul, one_mul]
          
      -- Finally, we glue `Hgt` and `Hle`
      have : (⋃ (m ≤ n + k) (i ∈ { i : ι | (D m i ∩ B).Nonempty }), {(m, i)}).Finite :=
        (finite_le_nat _).bUnion' fun i hi => (Hle i hi).Finite.bUnion' fun _ _ => finite_singleton _
      refine' this.subset fun I hI => _
      simp only [mem_Union]
      refine' ⟨I.1, _, I.2, hI, prod.mk.eta.symm⟩
      exact not_lt.1 fun hlt => (Hgt I.1 hlt I.2).le_bot hI.some_spec
      

-- see Note [lower instance priority]
instance (priority := 100) normalOfEmetric [EmetricSpace α] : NormalSpace α :=
  normalOfParacompactT2
#align emetric.normal_of_emetric Emetric.normalOfEmetric

end Emetric

