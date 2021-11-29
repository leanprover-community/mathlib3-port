import Mathbin.LinearAlgebra.Basis 
import Mathbin.LinearAlgebra.Pi 
import Mathbin.Data.Matrix.Basis

/-!
# The standard basis

This file defines the standard basis `std_basis R φ i b j`, which is `b` where `i = j` and `0`
elsewhere.

To give a concrete example, `std_basis R (λ (i : fin 3), R) i 1` gives the `i`th unit basis vector
in `R³`, and `pi.is_basis_fun` proves this is a basis over `fin 3 → R`.

## Main definitions

 - `linear_map.std_basis R ϕ i b`: the `i`'th standard `R`-basis vector on `Π i, ϕ i`,
   scaled by `b`.

## Main results

 - `pi.is_basis_std_basis`: `std_basis` turns a component-wise basis into a basis on the product
   type.
 - `pi.is_basis_fun`: `std_basis R (λ _, R) i 1` is a basis for `n → R`.

-/


open Function Submodule

open_locale BigOperators

open_locale BigOperators

namespace LinearMap

variable(R :
    Type _){ι : Type _}[Semiringₓ R](φ : ι → Type _)[∀ i, AddCommMonoidₓ (φ i)][∀ i, Module R (φ i)][DecidableEq ι]

/-- The standard basis of the product of `φ`. -/
def std_basis : ∀ (i : ι), φ i →ₗ[R] ∀ i, φ i :=
  single

theorem std_basis_apply (i : ι) (b : φ i) : std_basis R φ i b = update 0 i b :=
  rfl

theorem coe_std_basis (i : ι) : «expr⇑ » (std_basis R φ i) = Pi.single i :=
  funext$ std_basis_apply R φ i

@[simp]
theorem std_basis_same (i : ι) (b : φ i) : std_basis R φ i b i = b :=
  by 
    rw [std_basis_apply, update_same]

theorem std_basis_ne (i j : ι) (h : j ≠ i) (b : φ i) : std_basis R φ i b j = 0 :=
  by 
    rw [std_basis_apply, update_noteq h] <;> rfl

theorem std_basis_eq_pi_diag (i : ι) : std_basis R φ i = pi (diag i) :=
  by 
    ext x j 
    convert (update_apply 0 x i j _).symm 
    rfl

theorem ker_std_basis (i : ι) : ker (std_basis R φ i) = ⊥ :=
  ker_eq_bot_of_injective$
    fun f g hfg =>
      have  : std_basis R φ i f i = std_basis R φ i g i := hfg ▸ rfl 
      by 
        simpa only [std_basis_same]

theorem proj_comp_std_basis (i j : ι) : (proj i).comp (std_basis R φ j) = diag j i :=
  by 
    rw [std_basis_eq_pi_diag, proj_pi]

theorem proj_std_basis_same (i : ι) : (proj i).comp (std_basis R φ i) = id :=
  by 
    ext b <;> simp 

theorem proj_std_basis_ne (i j : ι) (h : i ≠ j) : (proj i).comp (std_basis R φ j) = 0 :=
  by 
    ext b <;> simp [std_basis_ne R φ _ _ h]

-- error in LinearAlgebra.StdBasis: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem supr_range_std_basis_le_infi_ker_proj
(I J : set ι)
(h : disjoint I J) : «expr ≤ »(«expr⨆ , »((i «expr ∈ » I), range (std_basis R φ i)), «expr⨅ , »((i «expr ∈ » J), ker (proj i))) :=
begin
  refine [expr «expr $ »(supr_le, assume i, «expr $ »(supr_le, assume hi, range_le_iff_comap.2 _))],
  simp [] [] ["only"] ["[", expr (ker_comp _ _).symm, ",", expr eq_top_iff, ",", expr set_like.le_def, ",", expr mem_ker, ",", expr comap_infi, ",", expr mem_infi, "]"] [] [],
  assume [binders (b hb j hj)],
  have [] [":", expr «expr ≠ »(i, j)] [":=", expr assume eq, h ⟨hi, «expr ▸ »(eq.symm, hj)⟩],
  rw ["[", expr mem_comap, ",", expr mem_ker, ",", "<-", expr comp_apply, ",", expr proj_std_basis_ne R φ j i this.symm, ",", expr zero_apply, "]"] []
end

theorem infi_ker_proj_le_supr_range_std_basis {I : Finset ι} {J : Set ι} (hu : Set.Univ ⊆ «expr↑ » I ∪ J) :
  (⨅(i : _)(_ : i ∈ J), ker (proj i)) ≤ ⨆(i : _)(_ : i ∈ I), range (std_basis R φ i) :=
  SetLike.le_def.2
    (by 
      intro b hb 
      simp only [mem_infi, mem_ker, proj_apply] at hb 
      rw
        [←show (∑i in I, std_basis R φ i (b i)) = b by 
          ext i 
          rw [Finset.sum_apply, ←std_basis_same R φ i (b i)]
          refine' Finset.sum_eq_single i (fun j hjI ne => std_basis_ne _ _ _ _ Ne.symm _) _ 
          intro hiI 
          rw [std_basis_same]
          exact hb _ ((hu trivialₓ).resolve_left hiI)]
      exact sum_mem _ fun i hiI => mem_supr_of_mem i$ mem_supr_of_mem hiI$ (std_basis R φ i).mem_range_self (b i))

-- error in LinearAlgebra.StdBasis: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem supr_range_std_basis_eq_infi_ker_proj
{I J : set ι}
(hd : disjoint I J)
(hu : «expr ⊆ »(set.univ, «expr ∪ »(I, J)))
(hI : set.finite I) : «expr = »(«expr⨆ , »((i «expr ∈ » I), range (std_basis R φ i)), «expr⨅ , »((i «expr ∈ » J), ker (proj i))) :=
begin
  refine [expr le_antisymm (supr_range_std_basis_le_infi_ker_proj _ _ _ _ hd) _],
  have [] [":", expr «expr ⊆ »(set.univ, «expr ∪ »(«expr↑ »(hI.to_finset), J))] [],
  { rwa ["[", expr hI.coe_to_finset, "]"] [] },
  refine [expr le_trans (infi_ker_proj_le_supr_range_std_basis R φ this) «expr $ »(supr_le_supr, assume i, _)],
  rw ["[", expr set.finite.mem_to_finset, "]"] [],
  exact [expr le_refl _]
end

theorem supr_range_std_basis [Fintype ι] : (⨆i : ι, range (std_basis R φ i)) = ⊤ :=
  have  : (Set.Univ : Set ι) ⊆ «expr↑ » (Finset.univ : Finset ι) ∪ ∅ :=
    by 
      rw [Finset.coe_univ, Set.union_empty]
  by 
    apply top_unique 
    convert infi_ker_proj_le_supr_range_std_basis R φ this 
    exact infi_emptyset.symm 
    exact funext$ fun i => ((@supr_pos _ _ _ fun h => range (std_basis R φ i))$ Finset.mem_univ i).symm

theorem disjoint_std_basis_std_basis (I J : Set ι) (h : Disjoint I J) :
  Disjoint (⨆(i : _)(_ : i ∈ I), range (std_basis R φ i)) (⨆(i : _)(_ : i ∈ J), range (std_basis R φ i)) :=
  by 
    refine'
      Disjoint.mono (supr_range_std_basis_le_infi_ker_proj _ _ _ _$ disjoint_compl_right)
        (supr_range_std_basis_le_infi_ker_proj _ _ _ _$ disjoint_compl_right) _ 
    simp only [Disjoint, SetLike.le_def, mem_infi, mem_inf, mem_ker, mem_bot, proj_apply, funext_iff]
    rintro b ⟨hI, hJ⟩ i 
    classical 
    byCases' hiI : i ∈ I
    ·
      byCases' hiJ : i ∈ J
      ·
        exact (h ⟨hiI, hiJ⟩).elim
      ·
        exact hJ i hiJ
    ·
      exact hI i hiI

-- error in LinearAlgebra.StdBasis: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem std_basis_eq_single {a : R} : «expr = »(λ i : ι, std_basis R (λ _ : ι, R) i a, λ i : ι, finsupp.single i a) :=
begin
  ext [] [ident i, ident j] [],
  rw ["[", expr std_basis_apply, ",", expr finsupp.single_apply, "]"] [],
  split_ifs [] [],
  { rw ["[", expr h, ",", expr function.update_same, "]"] [] },
  { rw ["[", expr function.update_noteq (ne.symm h), "]"] [],
    refl }
end

end LinearMap

namespace Pi

open LinearMap

open Set

variable{R : Type _}

section Module

variable{η : Type _}{ιs : η → Type _}{Ms : η → Type _}

-- error in LinearAlgebra.StdBasis: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem linear_independent_std_basis
[ring R]
[∀ i, add_comm_group (Ms i)]
[∀ i, module R (Ms i)]
[decidable_eq η]
(v : ∀ j, ιs j → Ms j)
(hs : ∀
 i, linear_independent R (v i)) : linear_independent R (λ
 ji : «exprΣ , »((j), ιs j), std_basis R Ms ji.1 (v ji.1 ji.2)) :=
begin
  have [ident hs'] [":", expr ∀ j : η, linear_independent R (λ i : ιs j, std_basis R Ms j (v j i))] [],
  { intro [ident j],
    exact [expr (hs j).map' _ (ker_std_basis _ _ _)] },
  apply [expr linear_independent_Union_finite hs'],
  { assume [binders (j J _ hiJ)],
    simp [] [] [] ["[", expr (set.Union.equations._eqn_1 _).symm, ",", expr submodule.span_image, ",", expr submodule.span_Union, "]"] [] [],
    have [ident h₀] [":", expr ∀
     j, «expr ≤ »(span R (range (λ i : ιs j, std_basis R Ms j (v j i))), range (std_basis R Ms j))] [],
    { intro [ident j],
      rw ["[", expr span_le, ",", expr linear_map.range_coe, "]"] [],
      apply [expr range_comp_subset_range] },
    have [ident h₁] [":", expr «expr ≤ »(span R (range (λ
        i : ιs j, std_basis R Ms j (v j i))), «expr⨆ , »((i «expr ∈ » {j}), range (std_basis R Ms i)))] [],
    { rw [expr @supr_singleton _ _ _ (λ i, linear_map.range (std_basis R (λ j : η, Ms j) i))] [],
      apply [expr h₀] },
    have [ident h₂] [":", expr «expr ≤ »(«expr⨆ , »((j «expr ∈ » J), span R (range (λ
         i : ιs j, std_basis R Ms j (v j i)))), «expr⨆ , »((j «expr ∈ » J), range (std_basis R (λ
         j : η, Ms j) j)))] [":=", expr supr_le_supr (λ i, supr_le_supr (λ H, h₀ i))],
    have [ident h₃] [":", expr disjoint (λ i : η, «expr ∈ »(i, {j})) J] [],
    { convert [] [expr set.disjoint_singleton_left.2 hiJ] ["using", 0] },
    exact [expr (disjoint_std_basis_std_basis _ _ _ _ h₃).mono h₁ h₂] }
end

variable[Semiringₓ R][∀ i, AddCommMonoidₓ (Ms i)][∀ i, Module R (Ms i)]

variable[Fintype η]

section 

open LinearEquiv

/-- `pi.basis (s : ∀ j, basis (ιs j) R (Ms j))` is the `Σ j, ιs j`-indexed basis on `Π j, Ms j`
given by `s j` on each component. -/
protected noncomputable def Basis (s : ∀ j, Basis (ιs j) R (Ms j)) : Basis (Σj, ιs j) R (∀ j, Ms j) :=
  by 
    refine' Basis.of_repr (_ ≪≫ₗ (Finsupp.sigmaFinsuppLequivPiFinsupp R).symm)
    exact LinearEquiv.piCongrRight fun j => (s j).repr

-- error in LinearAlgebra.StdBasis: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem basis_repr_std_basis
[decidable_eq η]
(s : ∀ j, basis (ιs j) R (Ms j))
(j i) : «expr = »((pi.basis s).repr (std_basis R _ j (s j i)), finsupp.single ⟨j, i⟩ 1) :=
begin
  ext [] ["⟨", ident j', ",", ident i', "⟩"] [],
  by_cases [expr hj, ":", expr «expr = »(j, j')],
  { subst [expr hj],
    simp [] [] ["only"] ["[", expr pi.basis, ",", expr linear_equiv.trans_apply, ",", expr basis.repr_self, ",", expr std_basis_same, ",", expr linear_equiv.Pi_congr_right_apply, ",", expr finsupp.sigma_finsupp_lequiv_pi_finsupp_symm_apply, "]"] [] [],
    symmetry,
    exact [expr basis.finsupp.single_apply_left (λ
      (i i')
      (h : «expr = »((⟨j, i⟩ : «exprΣ , »((j), ιs j)), ⟨j, i'⟩)), eq_of_heq (sigma.mk.inj h).2) _ _ _] },
  simp [] [] ["only"] ["[", expr pi.basis, ",", expr linear_equiv.trans_apply, ",", expr finsupp.sigma_finsupp_lequiv_pi_finsupp_symm_apply, ",", expr linear_equiv.Pi_congr_right_apply, "]"] [] [],
  dsimp [] [] [] [],
  rw ["[", expr std_basis_ne _ _ _ _ (ne.symm hj), ",", expr linear_equiv.map_zero, ",", expr finsupp.zero_apply, ",", expr finsupp.single_eq_of_ne, "]"] [],
  rintros ["⟨", "⟩"],
  contradiction
end

@[simp]
theorem basis_apply [DecidableEq η] (s : ∀ j, Basis (ιs j) R (Ms j)) ji :
  Pi.basis s ji = std_basis R _ ji.1 (s ji.1 ji.2) :=
  Basis.apply_eq_iff.mpr
    (by 
      simp )

@[simp]
theorem basis_repr (s : ∀ j, Basis (ιs j) R (Ms j)) x ji : (Pi.basis s).repr x ji = (s ji.1).repr (x ji.1) ji.2 :=
  rfl

end 

section 

variable(R η)

/-- The basis on `η → R` where the `i`th basis vector is `function.update 0 i 1`. -/
noncomputable def basis_fun : Basis η R (∀ (j : η), R) :=
  Basis.ofEquivFun (LinearEquiv.refl _ _)

-- error in LinearAlgebra.StdBasis: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp] theorem basis_fun_apply [decidable_eq η] (i) : «expr = »(basis_fun R η i, std_basis R (λ i : η, R) i 1) :=
by { simp [] [] ["only"] ["[", expr basis_fun, ",", expr basis.coe_of_equiv_fun, ",", expr linear_equiv.refl_symm, ",", expr linear_equiv.refl_apply, ",", expr std_basis_apply, "]"] [] [],
  congr }

@[simp]
theorem basis_fun_repr (x : η → R) (i : η) : (Pi.basisFun R η).repr x i = x i :=
  by 
    simp [basis_fun]

end 

end Module

end Pi

namespace Matrix

variable(R : Type _)(n : Type _)(m : Type _)[Fintype m][Fintype n][Semiringₓ R]

-- error in LinearAlgebra.StdBasis: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The standard basis of `matrix n m R`. -/ noncomputable def std_basis : basis «expr × »(n, m) R (matrix n m R) :=
basis.reindex (pi.basis (λ i : n, pi.basis_fun R m)) (equiv.sigma_equiv_prod _ _)

variable{n m}

theorem std_basis_eq_std_basis_matrix (i : n) (j : m) [DecidableEq n] [DecidableEq m] :
  std_basis R n m (i, j) = std_basis_matrix i j (1 : R) :=
  by 
    ext a b 
    byCases' hi : i = a <;> byCases' hj : j = b
    ·
      simp [std_basis, hi, hj]
    ·
      simp [std_basis, hi, hj, Ne.symm hj, LinearMap.std_basis_ne]
    ·
      simp [std_basis, hi, hj, Ne.symm hi, LinearMap.std_basis_ne]
    ·
      simp [std_basis, hi, hj, Ne.symm hj, Ne.symm hi, LinearMap.std_basis_ne]

end Matrix

