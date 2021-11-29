import Mathbin.Data.Finsupp.ToDfinsupp 
import Mathbin.LinearAlgebra.Basis

/-!
# Properties of the module `Π₀ i, M i`

Given an indexed collection of `R`-modules `M i`, the `R`-module structure on `Π₀ i, M i`
is defined in `data.dfinsupp`.

In this file we define `linear_map` versions of various maps:

* `dfinsupp.lsingle a : M →ₗ[R] Π₀ i, M i`: `dfinsupp.single a` as a linear map;

* `dfinsupp.lmk s : (Π i : (↑s : set ι), M i) →ₗ[R] Π₀ i, M i`: `dfinsupp.single a` as a linear map;

* `dfinsupp.lapply i : (Π₀ i, M i) →ₗ[R] M`: the map `λ f, f i` as a linear map;

* `dfinsupp.lsum`: `dfinsupp.sum` or `dfinsupp.lift_add_hom` as a `linear_map`;

## Implementation notes

This file should try to mirror `linear_algebra.finsupp` where possible. The API of `finsupp` is
much more developed, but many lemmas in that file should be eligible to copy over.

## Tags

function with finite support, module, linear algebra
-/


variable{ι : Type _}{R : Type _}{S : Type _}{M : ι → Type _}{N : Type _}

variable[dec_ι : DecidableEq ι]

namespace Dfinsupp

variable[Semiringₓ R][∀ i, AddCommMonoidₓ (M i)][∀ i, Module R (M i)]

variable[AddCommMonoidₓ N][Module R N]

include dec_ι

/-- `dfinsupp.mk` as a `linear_map`. -/
def lmk (s : Finset ι) : (∀ (i : («expr↑ » s : Set ι)), M i) →ₗ[R] Π₀i, M i :=
  { toFun := mk s, map_add' := fun _ _ => mk_add, map_smul' := fun c x => mk_smul c x }

/-- `dfinsupp.single` as a `linear_map` -/
def lsingle i : M i →ₗ[R] Π₀i, M i :=
  { Dfinsupp.singleAddHom _ _ with toFun := single i, map_smul' := single_smul }

/-- Two `R`-linear maps from `Π₀ i, M i` which agree on each `single i x` agree everywhere. -/
theorem lhom_ext ⦃φ ψ : (Π₀i, M i) →ₗ[R] N⦄ (h : ∀ i x, φ (single i x) = ψ (single i x)) : φ = ψ :=
  LinearMap.to_add_monoid_hom_injective$ add_hom_ext h

/-- Two `R`-linear maps from `Π₀ i, M i` which agree on each `single i x` agree everywhere.

See note [partially-applied ext lemmas].
After apply this lemma, if `M = R` then it suffices to verify `φ (single a 1) = ψ (single a 1)`. -/
@[ext]
theorem lhom_ext' ⦃φ ψ : (Π₀i, M i) →ₗ[R] N⦄ (h : ∀ i, φ.comp (lsingle i) = ψ.comp (lsingle i)) : φ = ψ :=
  lhom_ext$ fun i => LinearMap.congr_fun (h i)

omit dec_ι

/-- Interpret `λ (f : Π₀ i, M i), f i` as a linear map. -/
def lapply (i : ι) : (Π₀i, M i) →ₗ[R] M i :=
  { toFun := fun f => f i, map_add' := fun f g => add_apply f g i, map_smul' := fun c f => smul_apply c f i }

include dec_ι

@[simp]
theorem lmk_apply (s : Finset ι) x : (lmk s : _ →ₗ[R] Π₀i, M i) x = mk s x :=
  rfl

@[simp]
theorem lsingle_apply (i : ι) (x : M i) : (lsingle i : _ →ₗ[R] _) x = single i x :=
  rfl

omit dec_ι

@[simp]
theorem lapply_apply (i : ι) (f : Π₀i, M i) : (lapply i : _ →ₗ[R] _) f = f i :=
  rfl

section Lsum

/-- Typeclass inference can't find `dfinsupp.add_comm_monoid` without help for this case.
This instance allows it to be found where it is needed on the LHS of the colon in
`dfinsupp.module_of_linear_map`. -/
instance add_comm_monoid_of_linear_map : AddCommMonoidₓ (Π₀i : ι, M i →ₗ[R] N) :=
  @Dfinsupp.addCommMonoid _ (fun i => M i →ₗ[R] N) _

/-- Typeclass inference can't find `dfinsupp.module` without help for this case.
This is needed to define `dfinsupp.lsum` below.

The cause seems to be an inability to unify the `Π i, add_comm_monoid (M i →ₗ[R] N)` instance that
we have with the `Π i, has_zero (M i →ₗ[R] N)` instance which appears as a parameter to the
`dfinsupp` type. -/
instance module_of_linear_map [Semiringₓ S] [Module S N] [SmulCommClass R S N] : Module S (Π₀i : ι, M i →ₗ[R] N) :=
  @Dfinsupp.module _ _ (fun i => M i →ₗ[R] N) _ _ _

variable(S)

include dec_ι

/-- The `dfinsupp` version of `finsupp.lsum`.

See note [bundled maps over different rings] for why separate `R` and `S` semirings are used. -/
@[simps]
def lsum [Semiringₓ S] [Module S N] [SmulCommClass R S N] : (∀ i, M i →ₗ[R] N) ≃ₗ[S] (Π₀i, M i) →ₗ[R] N :=
  { toFun :=
      fun F =>
        { toFun := sum_add_hom fun i => (F i).toAddMonoidHom,
          map_add' := (lift_add_hom fun i => (F i).toAddMonoidHom).map_add,
          map_smul' :=
            fun c f =>
              by 
                dsimp 
                apply Dfinsupp.induction f
                ·
                  rw [smul_zero, AddMonoidHom.map_zero, smul_zero]
                ·
                  intro a b f ha hb hf 
                  rw [smul_add, AddMonoidHom.map_add, AddMonoidHom.map_add, smul_add, hf, ←single_smul,
                    sum_add_hom_single, sum_add_hom_single, LinearMap.to_add_monoid_hom_coe, LinearMap.map_smul] },
    invFun := fun F i => F.comp (lsingle i),
    left_inv :=
      fun F =>
        by 
          ext x y 
          simp ,
    right_inv :=
      fun F =>
        by 
          ext x y 
          simp ,
    map_add' :=
      fun F G =>
        by 
          ext x y 
          simp ,
    map_smul' :=
      fun c F =>
        by 
          ext 
          simp  }

/-- While `simp` can prove this, it is often convenient to avoid unfolding `lsum` into `sum_add_hom`
with `dfinsupp.lsum_apply_apply`. -/
theorem lsum_single [Semiringₓ S] [Module S N] [SmulCommClass R S N] (F : ∀ i, M i →ₗ[R] N) i (x : M i) :
  lsum S F (single i x) = F i x :=
  sum_add_hom_single _ _ _

end Lsum

/-! ### Bundled versions of `dfinsupp.map_range`

The names should match the equivalent bundled `finsupp.map_range` definitions.
-/


section MapRange

variable{β β₁ β₂ : ι → Type _}

variable[∀ i, AddCommMonoidₓ (β i)][∀ i, AddCommMonoidₓ (β₁ i)][∀ i, AddCommMonoidₓ (β₂ i)]

variable[∀ i, Module R (β i)][∀ i, Module R (β₁ i)][∀ i, Module R (β₂ i)]

theorem map_range_smul (f : ∀ i, β₁ i → β₂ i) (hf : ∀ i, f i 0 = 0) (r : R) (hf' : ∀ i x, f i (r • x) = r • f i x)
  (g : Π₀i, β₁ i) : map_range f hf (r • g) = r • map_range f hf g :=
  by 
    ext 
    simp only [map_range_apply f, coe_smul, Pi.smul_apply, hf']

/-- `dfinsupp.map_range` as an `linear_map`. -/
@[simps apply]
def map_range.linear_map (f : ∀ i, β₁ i →ₗ[R] β₂ i) : (Π₀i, β₁ i) →ₗ[R] Π₀i, β₂ i :=
  { map_range.add_monoid_hom fun i => (f i).toAddMonoidHom with
    toFun := map_range (fun i x => f i x) fun i => (f i).map_zero,
    map_smul' := fun r => map_range_smul _ _ _ fun i => (f i).map_smul r }

@[simp]
theorem map_range.linear_map_id : (map_range.linear_map fun i => (LinearMap.id : β₂ i →ₗ[R] _)) = LinearMap.id :=
  LinearMap.ext map_range_id

theorem map_range.linear_map_comp (f : ∀ i, β₁ i →ₗ[R] β₂ i) (f₂ : ∀ i, β i →ₗ[R] β₁ i) :
  (map_range.linear_map fun i => (f i).comp (f₂ i)) = (map_range.linear_map f).comp (map_range.linear_map f₂) :=
  LinearMap.ext$ map_range_comp (fun i x => f i x) (fun i x => f₂ i x) _ _ _

include dec_ι

theorem sum_map_range_index.linear_map [∀ (i : ι) (x : β₁ i), Decidable (x ≠ 0)]
  [∀ (i : ι) (x : β₂ i), Decidable (x ≠ 0)] {f : ∀ i, β₁ i →ₗ[R] β₂ i} {h : ∀ i, β₂ i →ₗ[R] N} {l : Π₀i, β₁ i} :
  Dfinsupp.lsum ℕ h (map_range.linear_map f l) = Dfinsupp.lsum ℕ (fun i => (h i).comp (f i)) l :=
  by 
    simpa [Dfinsupp.sum_add_hom_apply] using
      @sum_map_range_index ι N _ _ _ _ _ _ _ _ (fun i => f i)
        (fun i =>
          by 
            simp )
        l (fun i => h i)
        fun i =>
          by 
            simp 

omit dec_ι

/-- `dfinsupp.map_range.linear_map` as an `linear_equiv`. -/
@[simps apply]
def map_range.linear_equiv (e : ∀ i, β₁ i ≃ₗ[R] β₂ i) : (Π₀i, β₁ i) ≃ₗ[R] Π₀i, β₂ i :=
  { map_range.add_equiv fun i => (e i).toAddEquiv, map_range.linear_map fun i => (e i).toLinearMap with
    toFun := map_range (fun i x => e i x) fun i => (e i).map_zero,
    invFun := map_range (fun i x => (e i).symm x) fun i => (e i).symm.map_zero }

@[simp]
theorem map_range.linear_equiv_refl :
  (map_range.linear_equiv$ fun i => LinearEquiv.refl R (β₁ i)) = LinearEquiv.refl _ _ :=
  LinearEquiv.ext map_range_id

theorem map_range.linear_equiv_trans (f : ∀ i, β i ≃ₗ[R] β₁ i) (f₂ : ∀ i, β₁ i ≃ₗ[R] β₂ i) :
  (map_range.linear_equiv fun i => (f i).trans (f₂ i)) = (map_range.linear_equiv f).trans (map_range.linear_equiv f₂) :=
  LinearEquiv.ext$ map_range_comp (fun i x => f₂ i x) (fun i x => f i x) _ _ _

@[simp]
theorem map_range.linear_equiv_symm (e : ∀ i, β₁ i ≃ₗ[R] β₂ i) :
  (map_range.linear_equiv e).symm = map_range.linear_equiv fun i => (e i).symm :=
  rfl

end MapRange

section Basis

/-- The direct sum of free modules is free.

Note that while this is stated for `dfinsupp` not `direct_sum`, the types are defeq. -/
noncomputable def Basis {η : ι → Type _} (b : ∀ i, Basis (η i) R (M i)) : Basis (Σi, η i) R (Π₀i, M i) :=
  Basis.of_repr ((map_range.linear_equiv fun i => (b i).repr).trans (sigmaFinsuppLequivDfinsupp R).symm)

end Basis

end Dfinsupp

include dec_ι

namespace Submodule

variable[Semiringₓ R][AddCommMonoidₓ N][Module R N]

open Dfinsupp

theorem dfinsupp_sum_mem {β : ι → Type _} [∀ i, HasZero (β i)] [∀ i (x : β i), Decidable (x ≠ 0)] (S : Submodule R N)
  (f : Π₀i, β i) (g : ∀ i, β i → N) (h : ∀ c, f c ≠ 0 → g c (f c) ∈ S) : f.sum g ∈ S :=
  S.to_add_submonoid.dfinsupp_sum_mem f g h

theorem dfinsupp_sum_add_hom_mem {β : ι → Type _} [∀ i, AddZeroClass (β i)] (S : Submodule R N) (f : Π₀i, β i)
  (g : ∀ i, β i →+ N) (h : ∀ c, f c ≠ 0 → g c (f c) ∈ S) : Dfinsupp.sumAddHom g f ∈ S :=
  S.to_add_submonoid.dfinsupp_sum_add_hom_mem f g h

/-- The supremum of a family of submodules is equal to the range of `dfinsupp.lsum`; that is
every element in the `supr` can be produced from taking a finite number of non-zero elements
of `p i`, coercing them to `N`, and summing them. -/
theorem supr_eq_range_dfinsupp_lsum (p : ι → Submodule R N) : supr p = (Dfinsupp.lsum ℕ fun i => (p i).Subtype).range :=
  by 
    apply le_antisymmₓ
    ·
      apply supr_le _ 
      intro i y hy 
      exact ⟨Dfinsupp.single i ⟨y, hy⟩, Dfinsupp.sum_add_hom_single _ _ _⟩
    ·
      rintro x ⟨v, rfl⟩
      exact dfinsupp_sum_add_hom_mem _ v _ fun i _ => (le_supr p i : p i ≤ _) (v i).Prop

/-- The bounded supremum of a family of commutative additive submonoids is equal to the range of
`dfinsupp.sum_add_hom` composed with `dfinsupp.filter_add_monoid_hom`; that is, every element in the
bounded `supr` can be produced from taking a finite number of non-zero elements from the `S i` that
satisfy `p i`, coercing them to `γ`, and summing them. -/
theorem bsupr_eq_range_dfinsupp_lsum (p : ι → Prop) [DecidablePred p] (S : ι → Submodule R N) :
  (⨆(i : _)(h : p i), S i) = ((Dfinsupp.lsum ℕ fun i => (S i).Subtype).comp (Dfinsupp.filterLinearMap R _ p)).range :=
  by 
    apply le_antisymmₓ
    ·
      apply bsupr_le _ 
      intro i hi y hy 
      refine' ⟨Dfinsupp.single i ⟨y, hy⟩, _⟩
      rw [LinearMap.comp_apply, filter_linear_map_apply, filter_single_pos _ _ hi]
      exact Dfinsupp.sum_add_hom_single _ _ _
    ·
      rintro x ⟨v, rfl⟩
      refine' dfinsupp_sum_add_hom_mem _ _ _ fun i hi => _ 
      refine' mem_supr_of_mem i _ 
      byCases' hp : p i
      ·
        simp [hp]
      ·
        simp [hp]

theorem mem_supr_iff_exists_dfinsupp (p : ι → Submodule R N) (x : N) :
  x ∈ supr p ↔ ∃ f : Π₀i, p i, Dfinsupp.lsum ℕ (fun i => (p i).Subtype) f = x :=
  SetLike.ext_iff.mp (supr_eq_range_dfinsupp_lsum p) x

/-- A variant of `submodule.mem_supr_iff_exists_dfinsupp` with the RHS fully unfolded. -/
theorem mem_supr_iff_exists_dfinsupp' (p : ι → Submodule R N) [∀ i (x : p i), Decidable (x ≠ 0)] (x : N) :
  x ∈ supr p ↔ ∃ f : Π₀i, p i, (f.sum fun i xi => «expr↑ » xi) = x :=
  by 
    rw [mem_supr_iff_exists_dfinsupp]
    simpRw [Dfinsupp.lsum_apply_apply, Dfinsupp.sum_add_hom_apply]
    congr

theorem mem_bsupr_iff_exists_dfinsupp (p : ι → Prop) [DecidablePred p] (S : ι → Submodule R N) (x : N) :
  (x ∈ ⨆(i : _)(h : p i), S i) ↔ ∃ f : Π₀i, S i, Dfinsupp.lsum ℕ (fun i => (S i).Subtype) (f.filter p) = x :=
  SetLike.ext_iff.mp (bsupr_eq_range_dfinsupp_lsum p S) x

end Submodule

namespace CompleteLattice

open Dfinsupp

section Semiringₓ

variable[Semiringₓ R][AddCommMonoidₓ N][Module R N]

/-- Independence of a family of submodules can be expressed as a quantifier over `dfinsupp`s.

This is an intermediate result used to prove
`complete_lattice.independent_of_dfinsupp_lsum_injective` and
`complete_lattice.independent.dfinsupp_lsum_injective`. -/
theorem independent_iff_forall_dfinsupp (p : ι → Submodule R N) :
  independent p ↔
    ∀ i (x : p i) (v : Π₀i : ι, «expr↥ » (p i)), lsum ℕ (fun i => (p i).Subtype) (erase i v) = x → x = 0 :=
  by 
    simpRw [CompleteLattice.independent_def, Submodule.disjoint_def, Submodule.mem_bsupr_iff_exists_dfinsupp,
      exists_imp_distrib, filter_ne_eq_erase]
    apply forall_congrₓ fun i => _ 
    refine' subtype.forall'.trans _ 
    simpRw [Submodule.coe_eq_zero]
    rfl

-- error in LinearAlgebra.Dfinsupp: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem independent_of_dfinsupp_lsum_injective
(p : ι → submodule R N)
(h : function.injective (lsum exprℕ() (λ i, (p i).subtype))) : independent p :=
begin
  rw [expr independent_iff_forall_dfinsupp] [],
  intros [ident i, ident x, ident v, ident hv],
  replace [ident hv] [":", expr «expr = »(lsum exprℕ() (λ
     i, (p i).subtype) (erase i v), lsum exprℕ() (λ i, (p i).subtype) (single i x))] [],
  { simpa [] [] ["only"] ["[", expr lsum_single, "]"] [] ["using", expr hv] },
  have [] [] [":=", expr dfinsupp.ext_iff.mp (h hv) i],
  simpa [] [] [] ["[", expr eq_comm, "]"] [] ["using", expr this]
end

theorem independent_of_dfinsupp_sum_add_hom_injective (p : ι → AddSubmonoid N)
  (h : Function.Injective (sum_add_hom fun i => (p i).Subtype)) : independent p :=
  by 
    rw [←independent_map_order_iso_iff (AddSubmonoid.toNatSubmodule : AddSubmonoid N ≃o _)]
    exact independent_of_dfinsupp_lsum_injective _ h

/-- Combining `dfinsupp.lsum` with `linear_map.to_span_singleton` is the same as `finsupp.total` -/
theorem lsum_comp_map_range_to_span_singleton [∀ (m : R), Decidable (m ≠ 0)] (p : ι → Submodule R N) {v : ι → N}
  (hv : ∀ (i : ι), v i ∈ p i) :
  ((lsum ℕ) fun i => (p i).Subtype : _ →ₗ[R] _).comp
      ((map_range.linear_map fun i => LinearMap.toSpanSingleton R («expr↥ » (p i)) ⟨v i, hv i⟩ : _ →ₗ[R] _).comp
        (finsuppLequivDfinsupp R : (ι →₀ R) ≃ₗ[R] _).toLinearMap) =
    Finsupp.total ι N R v :=
  by 
    ext 
    simp 

end Semiringₓ

section Ringₓ

variable[Ringₓ R][AddCommGroupₓ N][Module R N]

theorem independent_of_dfinsupp_sum_add_hom_injective' (p : ι → AddSubgroup N)
  (h : Function.Injective (sum_add_hom fun i => (p i).Subtype)) : independent p :=
  by 
    rw [←independent_map_order_iso_iff (AddSubgroup.toIntSubmodule : AddSubgroup N ≃o _)]
    exact independent_of_dfinsupp_lsum_injective _ h

-- error in LinearAlgebra.Dfinsupp: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The canonical map out of a direct sum of a family of submodules is injective when the submodules
are `complete_lattice.independent`.

Note that this is not generally true for `[semiring R]`, for instance when `A` is the
`ℕ`-submodules of the positive and negative integers.

See `counterexamples/direct_sum_is_internal.lean` for a proof of this fact. -/
theorem independent.dfinsupp_lsum_injective
{p : ι → submodule R N}
(h : independent p) : function.injective (lsum exprℕ() (λ i, (p i).subtype)) :=
begin
  rw [expr independent_iff_forall_dfinsupp] ["at", ident h],
  suffices [] [":", expr «expr = »((lsum exprℕ() (λ i, (p i).subtype)).ker, «expr⊥»())],
  { letI [] [":", expr add_comm_group «exprΠ₀ , »((i), p i)] [":=", expr @dfinsupp.add_comm_group _ (λ i, p i) _],
    rw [expr linear_map.ker_eq_bot] ["at", ident this],
    exact [expr this] },
  rw [expr linear_map.ker_eq_bot'] [],
  intros [ident m, ident hm],
  ext [] [ident i] [":", 1],
  rw ["[", expr dfinsupp.zero_apply, ",", "<-", expr neg_eq_zero, "]"] [],
  refine [expr h i «expr- »(m i) m _],
  rwa ["[", "<-", expr erase_add_single i m, ",", expr linear_map.map_add, ",", expr lsum_single, ",", expr submodule.subtype_apply, ",", expr add_eq_zero_iff_eq_neg, ",", "<-", expr submodule.coe_neg, "]"] ["at", ident hm]
end

/-- The canonical map out of a direct sum of a family of additive subgroups is injective when the
additive subgroups are `complete_lattice.independent`. -/
theorem independent.dfinsupp_sum_add_hom_injective {p : ι → AddSubgroup N} (h : independent p) :
  Function.Injective (sum_add_hom fun i => (p i).Subtype) :=
  by 
    rw [←independent_map_order_iso_iff (AddSubgroup.toIntSubmodule : AddSubgroup N ≃o _)] at h 
    exact h.dfinsupp_lsum_injective

/-- A family of submodules over an additive group are independent if and only iff `dfinsupp.lsum`
applied with `submodule.subtype` is injective.

Note that this is not generally true for `[semiring R]`; see
`complete_lattice.independent.dfinsupp_lsum_injective` for details. -/
theorem independent_iff_dfinsupp_lsum_injective (p : ι → Submodule R N) :
  independent p ↔ Function.Injective (lsum ℕ fun i => (p i).Subtype) :=
  ⟨independent.dfinsupp_lsum_injective, independent_of_dfinsupp_lsum_injective p⟩

/-- A family of additive subgroups over an additive group are independent if and only if
`dfinsupp.sum_add_hom` applied with `add_subgroup.subtype` is injective. -/
theorem independent_iff_dfinsupp_sum_add_hom_injective (p : ι → AddSubgroup N) :
  independent p ↔ Function.Injective (sum_add_hom fun i => (p i).Subtype) :=
  ⟨independent.dfinsupp_sum_add_hom_injective, independent_of_dfinsupp_sum_add_hom_injective' p⟩

omit dec_ι

-- error in LinearAlgebra.Dfinsupp: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If a family of submodules is `independent`, then a choice of nonzero vector from each submodule
forms a linearly independent family. -/
theorem independent.linear_independent
[no_zero_smul_divisors R N]
(p : ι → submodule R N)
(hp : complete_lattice.independent p)
{v : ι → N}
(hv : ∀ i, «expr ∈ »(v i, p i))
(hv' : ∀ i, «expr ≠ »(v i, 0)) : linear_independent R v :=
begin
  classical,
  rw [expr linear_independent_iff] [],
  intros [ident l, ident hl],
  let [ident a] [] [":=", expr dfinsupp.map_range.linear_map (λ
    i, linear_map.to_span_singleton R (p i) ⟨v i, hv i⟩) l.to_dfinsupp],
  have [ident ha] [":", expr «expr = »(a, 0)] [],
  { apply [expr hp.dfinsupp_lsum_injective],
    rwa ["<-", expr lsum_comp_map_range_to_span_singleton _ hv] ["at", ident hl] },
  ext [] [ident i] [],
  apply [expr smul_left_injective R (hv' i)],
  have [] [":", expr «expr = »(«expr • »(l i, v i), a i)] [":=", expr rfl],
  simp [] [] [] ["[", expr this, ",", expr ha, "]"] [] []
end

end Ringₓ

end CompleteLattice

