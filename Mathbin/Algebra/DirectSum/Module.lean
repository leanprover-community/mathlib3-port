import Mathbin.Algebra.DirectSum.Basic 
import Mathbin.LinearAlgebra.Dfinsupp

/-!
# Direct sum of modules

The first part of the file provides constructors for direct sums of modules. It provides a
construction of the direct sum using the universal property and proves its uniqueness
(`direct_sum.to_module.unique`).

The second part of the file covers the special case of direct sums of submodules of a fixed module
`M`.  There is a canonical linear map from this direct sum to `M`, and the construction is
of particular importance when this linear map is an equivalence; that is, when the submodules
provide an internal decomposition of `M`.  The property is defined as
`direct_sum.submodule_is_internal`, and its basic consequences are established.

-/


universe u v w u₁

namespace DirectSum

open_locale DirectSum

section General

variable{R : Type u}[Semiringₓ R]

variable{ι : Type v}[dec_ι : DecidableEq ι]

include R

variable{M : ι → Type w}[∀ i, AddCommMonoidₓ (M i)][∀ i, Module R (M i)]

instance  : Module R (⨁i, M i) :=
  Dfinsupp.module

instance  {S : Type _} [Semiringₓ S] [∀ i, Module S (M i)] [∀ i, SmulCommClass R S (M i)] :
  SmulCommClass R S (⨁i, M i) :=
  Dfinsupp.smul_comm_class

instance  {S : Type _} [Semiringₓ S] [HasScalar R S] [∀ i, Module S (M i)] [∀ i, IsScalarTower R S (M i)] :
  IsScalarTower R S (⨁i, M i) :=
  Dfinsupp.is_scalar_tower

theorem smul_apply (b : R) (v : ⨁i, M i) (i : ι) : (b • v) i = b • v i :=
  Dfinsupp.smul_apply _ _ _

include dec_ι

variable(R ι M)

/-- Create the direct sum given a family `M` of `R` modules indexed over `ι`. -/
def lmk : ∀ (s : Finset ι), (∀ (i : («expr↑ » s : Set ι)), M i.val) →ₗ[R] ⨁i, M i :=
  Dfinsupp.lmk

/-- Inclusion of each component into the direct sum. -/
def lof : ∀ (i : ι), M i →ₗ[R] ⨁i, M i :=
  Dfinsupp.lsingle

theorem lof_eq_of (i : ι) (b : M i) : lof R ι M i b = of M i b :=
  rfl

variable{ι M}

theorem single_eq_lof (i : ι) (b : M i) : Dfinsupp.single i b = lof R ι M i b :=
  rfl

/-- Scalar multiplication commutes with direct sums. -/
theorem mk_smul (s : Finset ι) (c : R) x : mk M s (c • x) = c • mk M s x :=
  (lmk R ι M s).map_smul c x

/-- Scalar multiplication commutes with the inclusion of each component into the direct sum. -/
theorem of_smul (i : ι) (c : R) x : of M i (c • x) = c • of M i x :=
  (lof R ι M i).map_smul c x

variable{R}

theorem support_smul [∀ (i : ι) (x : M i), Decidable (x ≠ 0)] (c : R) (v : ⨁i, M i) : (c • v).support ⊆ v.support :=
  Dfinsupp.support_smul _ _

variable{N : Type u₁}[AddCommMonoidₓ N][Module R N]

variable(φ : ∀ i, M i →ₗ[R] N)

variable(R ι N φ)

/-- The linear map constructed using the universal property of the coproduct. -/
def to_module : (⨁i, M i) →ₗ[R] N :=
  Dfinsupp.lsum ℕ φ

/-- Coproducts in the categories of modules and additive monoids commute with the forgetful functor
from modules to additive monoids. -/
theorem coe_to_module_eq_coe_to_add_monoid :
  (to_module R ι N φ : (⨁i, M i) → N) = to_add_monoid fun i => (φ i).toAddMonoidHom :=
  rfl

variable{ι N φ}

/-- The map constructed using the universal property gives back the original maps when
restricted to each component. -/
@[simp]
theorem to_module_lof i (x : M i) : to_module R ι N φ (lof R ι M i x) = φ i x :=
  to_add_monoid_of (fun i => (φ i).toAddMonoidHom) i x

variable(ψ : (⨁i, M i) →ₗ[R] N)

/-- Every linear map from a direct sum agrees with the one obtained by applying
the universal property to each of its components. -/
theorem to_module.unique (f : ⨁i, M i) : ψ f = to_module R ι N (fun i => ψ.comp$ lof R ι M i) f :=
  to_add_monoid.unique ψ.to_add_monoid_hom f

variable{ψ}{ψ' : (⨁i, M i) →ₗ[R] N}

/-- Two `linear_map`s out of a direct sum are equal if they agree on the generators.

See note [partially-applied ext lemmas]. -/
@[ext]
theorem linear_map_ext ⦃ψ ψ' : (⨁i, M i) →ₗ[R] N⦄ (H : ∀ i, ψ.comp (lof R ι M i) = ψ'.comp (lof R ι M i)) : ψ = ψ' :=
  Dfinsupp.lhom_ext' H

-- error in Algebra.DirectSum.Module: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/--
The inclusion of a subset of the direct summands
into a larger subset of the direct summands, as a linear map.
-/
def lset_to_set
(S T : set ι)
(H : «expr ⊆ »(S, T)) : «expr →ₗ[ ] »(«expr⨁ , »((i : S), M i), R, «expr⨁ , »((i : T), M i)) :=
«expr $ »(to_module R _ _, λ i, lof R T (λ i : subtype T, M i) ⟨i, H i.prop⟩)

omit dec_ι

variable(ι M)

/-- Given `fintype α`, `linear_equiv_fun_on_fintype R` is the natural `R`-linear equivalence
between `⨁ i, M i` and `Π i, M i`. -/
@[simps apply]
def linear_equiv_fun_on_fintype [Fintype ι] : (⨁i, M i) ≃ₗ[R] ∀ i, M i :=
  { Dfinsupp.equivFunOnFintype with toFun := coeFn,
    map_add' :=
      fun f g =>
        by 
          ext 
          simp only [add_apply, Pi.add_apply],
    map_smul' :=
      fun c f =>
        by 
          ext 
          simp only [Dfinsupp.coe_smul, RingHom.id_apply] }

variable{ι M}

@[simp]
theorem linear_equiv_fun_on_fintype_lof [Fintype ι] [DecidableEq ι] (i : ι) (m : M i) :
  (linear_equiv_fun_on_fintype R ι M) (lof R ι M i m) = Pi.single i m :=
  by 
    ext a 
    change (Dfinsupp.equivFunOnFintype (lof R ι M i m)) a = _ 
    convert _root_.congr_fun (Dfinsupp.equiv_fun_on_fintype_single i m) a

@[simp]
theorem linear_equiv_fun_on_fintype_symm_single [Fintype ι] [DecidableEq ι] (i : ι) (m : M i) :
  (linear_equiv_fun_on_fintype R ι M).symm (Pi.single i m) = lof R ι M i m :=
  by 
    ext a 
    change (dfinsupp.equiv_fun_on_fintype.symm (Pi.single i m)) a = _ 
    rw [Dfinsupp.equiv_fun_on_fintype_symm_single i m]
    rfl

@[simp]
theorem linear_equiv_fun_on_fintype_symm_coe [Fintype ι] (f : ⨁i, M i) :
  (linear_equiv_fun_on_fintype R ι M).symm f = f :=
  by 
    ext 
    simp [linear_equiv_fun_on_fintype]

/-- The natural linear equivalence between `⨁ _ : ι, M` and `M` when `unique ι`. -/
protected def lid (M : Type v) (ι : Type _ := PUnit) [AddCommMonoidₓ M] [Module R M] [Unique ι] : (⨁_ : ι, M) ≃ₗ[R] M :=
  { DirectSum.id M ι, to_module R ι M fun i => LinearMap.id with  }

variable(ι M)

/-- The projection map onto one component, as a linear map. -/
def component (i : ι) : (⨁i, M i) →ₗ[R] M i :=
  Dfinsupp.lapply i

variable{ι M}

theorem apply_eq_component (f : ⨁i, M i) (i : ι) : f i = component R ι M i f :=
  rfl

@[ext]
theorem ext {f g : ⨁i, M i} (h : ∀ i, component R ι M i f = component R ι M i g) : f = g :=
  Dfinsupp.ext h

theorem ext_iff {f g : ⨁i, M i} : f = g ↔ ∀ i, component R ι M i f = component R ι M i g :=
  ⟨fun h _ =>
      by 
        rw [h],
    ext R⟩

include dec_ι

@[simp]
theorem lof_apply (i : ι) (b : M i) : ((lof R ι M i) b) i = b :=
  Dfinsupp.single_eq_same

@[simp]
theorem component.lof_self (i : ι) (b : M i) : component R ι M i ((lof R ι M i) b) = b :=
  lof_apply R i b

theorem component.of (i j : ι) (b : M j) :
  component R ι M i ((lof R ι M j) b) = if h : j = i then Eq.recOnₓ h b else 0 :=
  Dfinsupp.single_apply

end General

section Submodule

section Semiringₓ

variable{R : Type u}[Semiringₓ R]

variable{ι : Type v}[dec_ι : DecidableEq ι]

include dec_ι

variable{M : Type _}[AddCommMonoidₓ M][Module R M]

variable(A : ι → Submodule R M)

/-- The canonical embedding from `⨁ i, A i` to `M`  where `A` is a collection of `submodule R M`
indexed by `ι`-/
def submodule_coe : (⨁i, A i) →ₗ[R] M :=
  to_module R ι M fun i => (A i).Subtype

@[simp]
theorem submodule_coe_of (i : ι) (x : A i) : submodule_coe A (of (fun i => A i) i x) = x :=
  to_add_monoid_of _ _ _

/-- The `direct_sum` formed by a collection of `submodule`s of `M` is said to be internal if the
canonical map `(⨁ i, A i) →ₗ[R] M` is bijective.

For the alternate statement in terms of independence and spanning, see
`direct_sum.submodule_is_internal_iff_independent_and_supr_eq_top`. -/
def submodule_is_internal : Prop :=
  Function.Bijective (submodule_coe A)

theorem submodule_is_internal.to_add_submonoid :
  submodule_is_internal A ↔ add_submonoid_is_internal fun i => (A i).toAddSubmonoid :=
  Iff.rfl

variable{A}

/-- If a direct sum of submodules is internal then the submodules span the module. -/
theorem submodule_is_internal.supr_eq_top (h : submodule_is_internal A) : supr A = ⊤ :=
  by 
    rw [Submodule.supr_eq_range_dfinsupp_lsum, LinearMap.range_eq_top]
    exact Function.Bijective.surjective h

/-- If a direct sum of submodules is internal then the submodules are independent. -/
theorem submodule_is_internal.independent (h : submodule_is_internal A) : CompleteLattice.Independent A :=
  CompleteLattice.independent_of_dfinsupp_lsum_injective _ h.injective

/-- Given an internal direct sum decomposition of a module `M`, and a basis for each of the
components of the direct sum, the disjoint union of these bases is a basis for `M`. -/
noncomputable def submodule_is_internal.collected_basis (h : submodule_is_internal A) {α : ι → Type _}
  (v : ∀ i, Basis (α i) R (A i)) : Basis (Σi, α i) R M :=
  { repr :=
      ((LinearEquiv.ofBijective _ h.injective h.surjective).symm ≪≫ₗ
          Dfinsupp.mapRange.linearEquiv fun i => (v i).repr) ≪≫ₗ
        (sigmaFinsuppLequivDfinsupp R).symm }

-- error in Algebra.DirectSum.Module: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem submodule_is_internal.collected_basis_coe
(h : submodule_is_internal A)
{α : ι → Type*}
(v : ∀
 i, basis (α i) R (A i)) : «expr = »(«expr⇑ »(h.collected_basis v), λ a : «exprΣ , »((i), α i), «expr↑ »(v a.1 a.2)) :=
begin
  funext [ident a],
  simp [] [] ["only"] ["[", expr submodule_is_internal.collected_basis, ",", expr to_module, ",", expr submodule_coe, ",", expr add_equiv.to_fun_eq_coe, ",", expr basis.coe_of_repr, ",", expr basis.repr_symm_apply, ",", expr dfinsupp.lsum_apply_apply, ",", expr dfinsupp.map_range.linear_equiv_apply, ",", expr dfinsupp.map_range.linear_equiv_symm, ",", expr dfinsupp.map_range_single, ",", expr finsupp.total_single, ",", expr linear_equiv.of_bijective_apply, ",", expr linear_equiv.symm_symm, ",", expr linear_equiv.symm_trans_apply, ",", expr one_smul, ",", expr sigma_finsupp_add_equiv_dfinsupp_apply, ",", expr sigma_finsupp_equiv_dfinsupp_single, ",", expr sigma_finsupp_lequiv_dfinsupp_apply, "]"] [] [],
  convert [] [expr dfinsupp.sum_add_hom_single (λ i, (A i).subtype.to_add_monoid_hom) a.1 (v a.1 a.2)] []
end

theorem submodule_is_internal.collected_basis_mem (h : submodule_is_internal A) {α : ι → Type _}
  (v : ∀ i, Basis (α i) R (A i)) (a : Σi, α i) : h.collected_basis v a ∈ A a.1 :=
  by 
    simp 

end Semiringₓ

section Ringₓ

variable{R : Type u}[Ringₓ R]

variable{ι : Type v}[dec_ι : DecidableEq ι]

include dec_ι

variable{M : Type _}[AddCommGroupₓ M][Module R M]

theorem submodule_is_internal.to_add_subgroup (A : ι → Submodule R M) :
  submodule_is_internal A ↔ add_subgroup_is_internal fun i => (A i).toAddSubgroup :=
  Iff.rfl

/-- Note that this is not generally true for `[semiring R]`; see
`complete_lattice.independent.dfinsupp_lsum_injective` for details. -/
theorem submodule_is_internal_of_independent_of_supr_eq_top {A : ι → Submodule R M} (hi : CompleteLattice.Independent A)
  (hs : supr A = ⊤) : submodule_is_internal A :=
  ⟨hi.dfinsupp_lsum_injective, LinearMap.range_eq_top.1$ (Submodule.supr_eq_range_dfinsupp_lsum _).symm.trans hs⟩

/-- `iff` version of `direct_sum.submodule_is_internal_of_independent_of_supr_eq_top`,
`direct_sum.submodule_is_internal.independent`, and `direct_sum.submodule_is_internal.supr_eq_top`.
-/
theorem submodule_is_internal_iff_independent_and_supr_eq_top (A : ι → Submodule R M) :
  submodule_is_internal A ↔ CompleteLattice.Independent A ∧ supr A = ⊤ :=
  ⟨fun i => ⟨i.independent, i.supr_eq_top⟩, And.ndrec submodule_is_internal_of_independent_of_supr_eq_top⟩

/-! Now copy the lemmas for subgroup and submonoids. -/


theorem add_submonoid_is_internal.independent {M : Type _} [AddCommMonoidₓ M] {A : ι → AddSubmonoid M}
  (h : add_submonoid_is_internal A) : CompleteLattice.Independent A :=
  CompleteLattice.independent_of_dfinsupp_sum_add_hom_injective _ h.injective

theorem add_subgroup_is_internal.independent {M : Type _} [AddCommGroupₓ M] {A : ι → AddSubgroup M}
  (h : add_subgroup_is_internal A) : CompleteLattice.Independent A :=
  CompleteLattice.independent_of_dfinsupp_sum_add_hom_injective' _ h.injective

end Ringₓ

end Submodule

end DirectSum

