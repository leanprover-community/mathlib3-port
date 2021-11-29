import Mathbin.Algebra.BigOperators.Pi 
import Mathbin.Algebra.Module.Hom 
import Mathbin.Algebra.Module.Prod 
import Mathbin.Algebra.Module.SubmoduleLattice 
import Mathbin.Data.Dfinsupp 
import Mathbin.Data.Finsupp.Basic 
import Mathbin.Order.CompactlyGenerated 
import Mathbin.Order.OmegaCompletePartialOrder

/-!
# Linear algebra

This file defines the basics of linear algebra. It sets up the "categorical/lattice structure" of
modules over a ring, submodules, and linear maps.

Many of the relevant definitions, including `module`, `submodule`, and `linear_map`, are found in
`src/algebra/module`.

## Main definitions

* Many constructors for (semi)linear maps
* `submodule.span s` is defined to be the smallest submodule containing the set `s`.
* The kernel `ker` and range `range` of a linear map are submodules of the domain and codomain
  respectively.
* The general linear group is defined to be the group of invertible linear maps from `M` to itself.

See `linear_algebra.quotient` for quotients by submodules.

## Main theorems

See `linear_algebra.isomorphisms` for Noether's three isomorphism theorems for modules.

## Notations

* We continue to use the notations `M →ₛₗ[σ] M₂` and `M →ₗ[R] M₂` for the type of semilinear
  (resp. linear) maps from `M` to `M₂` over the ring homomorphism `σ` (resp. over the ring `R`).
* We introduce the notation `R ∙ v` for the span of a singleton, `submodule.span R {v}`.  This is
  `\.`, not the same as the scalar multiplication `•`/`\bub`.

## Implementation notes

We note that, when constructing linear maps, it is convenient to use operations defined on bundled
maps (`linear_map.prod`, `linear_map.coprod`, arithmetic operations like `+`) instead of defining a
function and proving it is linear.

## TODO

* Parts of this file have not yet been generalized to semilinear maps

## Tags
linear algebra, vector space, module

-/


open Function

open_locale BigOperators Pointwise

variable{R : Type _}{R₁ : Type _}{R₂ : Type _}{R₃ : Type _}{R₄ : Type _}

variable{S : Type _}

variable{K : Type _}{K₂ : Type _}

variable{M : Type _}{M' : Type _}{M₁ : Type _}{M₂ : Type _}{M₃ : Type _}{M₄ : Type _}

variable{N : Type _}{N₂ : Type _}

variable{ι : Type _}

variable{V : Type _}{V₂ : Type _}

namespace Finsupp

theorem smul_sum {α : Type _} {β : Type _} {R : Type _} {M : Type _} [HasZero β] [Monoidₓ R] [AddCommMonoidₓ M]
  [DistribMulAction R M] {v : α →₀ β} {c : R} {h : α → β → M} : c • v.sum h = v.sum fun a b => c • h a b :=
  Finset.smul_sum

@[simp]
theorem sum_smul_index_linear_map' {α : Type _} {R : Type _} {M : Type _} {M₂ : Type _} [Semiringₓ R] [AddCommMonoidₓ M]
  [Module R M] [AddCommMonoidₓ M₂] [Module R M₂] {v : α →₀ M} {c : R} {h : α → M →ₗ[R] M₂} :
  ((c • v).Sum fun a => h a) = c • v.sum fun a => h a :=
  by 
    rw [Finsupp.sum_smul_index', Finsupp.smul_sum]
    ·
      simp only [LinearMap.map_smul]
    ·
      intro i 
      exact (h i).map_zero

variable(α : Type _)[Fintype α]

variable(R M)[AddCommMonoidₓ M][Semiringₓ R][Module R M]

/-- Given `fintype α`, `linear_equiv_fun_on_fintype R` is the natural `R`-linear equivalence between
`α →₀ β` and `α → β`. -/
@[simps apply]
noncomputable def linear_equiv_fun_on_fintype : (α →₀ M) ≃ₗ[R] α → M :=
  { equiv_fun_on_fintype with toFun := coeFn,
    map_add' :=
      fun f g =>
        by 
          ext 
          rfl,
    map_smul' :=
      fun c f =>
        by 
          ext 
          rfl }

@[simp]
theorem linear_equiv_fun_on_fintype_single [DecidableEq α] (x : α) (m : M) :
  (linear_equiv_fun_on_fintype R M α) (single x m) = Pi.single x m :=
  by 
    ext a 
    change (equiv_fun_on_fintype (single x m)) a = _ 
    convert _root_.congr_fun (equiv_fun_on_fintype_single x m) a

@[simp]
theorem linear_equiv_fun_on_fintype_symm_single [DecidableEq α] (x : α) (m : M) :
  (linear_equiv_fun_on_fintype R M α).symm (Pi.single x m) = single x m :=
  by 
    ext a 
    change (equiv_fun_on_fintype.symm (Pi.single x m)) a = _ 
    convert congr_funₓ (equiv_fun_on_fintype_symm_single x m) a

@[simp]
theorem linear_equiv_fun_on_fintype_symm_coe (f : α →₀ M) : (linear_equiv_fun_on_fintype R M α).symm f = f :=
  by 
    ext 
    simp [linear_equiv_fun_on_fintype]

end Finsupp

section 

open_locale Classical

/-- decomposing `x : ι → R` as a sum along the canonical basis -/
theorem pi_eq_sum_univ {ι : Type _} [Fintype ι] {R : Type _} [Semiringₓ R] (x : ι → R) :
  x = ∑i, x i • fun j => if i = j then 1 else 0 :=
  by 
    ext 
    simp 

end 

/-! ### Properties of linear maps -/


namespace LinearMap

section AddCommMonoidₓ

variable[Semiringₓ R][Semiringₓ R₂][Semiringₓ R₃][Semiringₓ R₄]

variable[AddCommMonoidₓ M][AddCommMonoidₓ M₁][AddCommMonoidₓ M₂]

variable[AddCommMonoidₓ M₃][AddCommMonoidₓ M₄]

variable[Module R M][Module R M₁][Module R₂ M₂][Module R₃ M₃][Module R₄ M₄]

variable{σ₁₂ : R →+* R₂}{σ₂₃ : R₂ →+* R₃}{σ₃₄ : R₃ →+* R₄}

variable{σ₁₃ : R →+* R₃}{σ₂₄ : R₂ →+* R₄}{σ₁₄ : R →+* R₄}

variable[RingHomCompTriple σ₁₂ σ₂₃ σ₁₃][RingHomCompTriple σ₂₃ σ₃₄ σ₂₄]

variable[RingHomCompTriple σ₁₃ σ₃₄ σ₁₄][RingHomCompTriple σ₁₂ σ₂₄ σ₁₄]

variable(f : M →ₛₗ[σ₁₂] M₂)(g : M₂ →ₛₗ[σ₂₃] M₃)

include R R₂

theorem comp_assoc (h : M₃ →ₛₗ[σ₃₄] M₄) :
  ((h.comp g : M₂ →ₛₗ[σ₂₄] M₄).comp f : M →ₛₗ[σ₁₄] M₄) = h.comp (g.comp f : M →ₛₗ[σ₁₃] M₃) :=
  rfl

omit R R₂

/-- The restriction of a linear map `f : M → M₂` to a submodule `p ⊆ M` gives a linear map
`p → M₂`. -/
def dom_restrict (f : M →ₛₗ[σ₁₂] M₂) (p : Submodule R M) : p →ₛₗ[σ₁₂] M₂ :=
  f.comp p.subtype

@[simp]
theorem dom_restrict_apply (f : M →ₛₗ[σ₁₂] M₂) (p : Submodule R M) (x : p) : f.dom_restrict p x = f x :=
  rfl

/-- A linear map `f : M₂ → M` whose values lie in a submodule `p ⊆ M` can be restricted to a
linear map M₂ → p. -/
def cod_restrict (p : Submodule R₂ M₂) (f : M →ₛₗ[σ₁₂] M₂) (h : ∀ c, f c ∈ p) : M →ₛₗ[σ₁₂] p :=
  by 
    refine' { toFun := fun c => ⟨f c, h c⟩, .. } <;> intros  <;> apply SetCoe.ext <;> simp 

@[simp]
theorem cod_restrict_apply (p : Submodule R₂ M₂) (f : M →ₛₗ[σ₁₂] M₂) {h} (x : M) : (cod_restrict p f h x : M₂) = f x :=
  rfl

@[simp]
theorem comp_cod_restrict (p : Submodule R₃ M₃) (h : ∀ b, g b ∈ p) :
  ((cod_restrict p g h).comp f : M →ₛₗ[σ₁₃] p) = cod_restrict p (g.comp f) fun b => h _ :=
  ext$ fun b => rfl

@[simp]
theorem subtype_comp_cod_restrict (p : Submodule R₂ M₂) (h : ∀ b, f b ∈ p) : p.subtype.comp (cod_restrict p f h) = f :=
  ext$ fun b => rfl

/-- Restrict domain and codomain of an endomorphism. -/
def restrict (f : M →ₗ[R] M) {p : Submodule R M} (hf : ∀ x (_ : x ∈ p), f x ∈ p) : p →ₗ[R] p :=
  (f.dom_restrict p).codRestrict p$ SetLike.forall.2 hf

theorem restrict_apply {f : M →ₗ[R] M} {p : Submodule R M} (hf : ∀ x (_ : x ∈ p), f x ∈ p) (x : p) :
  f.restrict hf x = ⟨f x, hf x.1 x.2⟩ :=
  rfl

theorem subtype_comp_restrict {f : M →ₗ[R] M} {p : Submodule R M} (hf : ∀ x (_ : x ∈ p), f x ∈ p) :
  p.subtype.comp (f.restrict hf) = f.dom_restrict p :=
  rfl

theorem restrict_eq_cod_restrict_dom_restrict {f : M →ₗ[R] M} {p : Submodule R M} (hf : ∀ x (_ : x ∈ p), f x ∈ p) :
  f.restrict hf = (f.dom_restrict p).codRestrict p fun x => hf x.1 x.2 :=
  rfl

theorem restrict_eq_dom_restrict_cod_restrict {f : M →ₗ[R] M} {p : Submodule R M} (hf : ∀ x, f x ∈ p) :
  (f.restrict fun x _ => hf x) = (f.cod_restrict p hf).domRestrict p :=
  rfl

instance unique_of_left [Subsingleton M] : Unique (M →ₛₗ[σ₁₂] M₂) :=
  { LinearMap.inhabited with
    uniq :=
      fun f =>
        ext$
          fun x =>
            by 
              rw [Subsingleton.elimₓ x 0, map_zero, map_zero] }

instance unique_of_right [Subsingleton M₂] : Unique (M →ₛₗ[σ₁₂] M₂) :=
  coe_injective.unique

/-- Evaluation of a `σ₁₂`-linear map at a fixed `a`, as an `add_monoid_hom`. -/
def eval_add_monoid_hom (a : M) : (M →ₛₗ[σ₁₂] M₂) →+ M₂ :=
  { toFun := fun f => f a, map_add' := fun f g => LinearMap.add_apply f g a, map_zero' := rfl }

/-- `linear_map.to_add_monoid_hom` promoted to an `add_monoid_hom` -/
def to_add_monoid_hom' : (M →ₛₗ[σ₁₂] M₂) →+ M →+ M₂ :=
  { toFun := to_add_monoid_hom,
    map_zero' :=
      by 
        ext <;> rfl,
    map_add' :=
      by 
        intros  <;> ext <;> rfl }

theorem sum_apply (t : Finset ι) (f : ι → M →ₛₗ[σ₁₂] M₂) (b : M) : (∑d in t, f d) b = ∑d in t, f d b :=
  AddMonoidHom.map_sum ((AddMonoidHom.eval b).comp to_add_monoid_hom') f _

section SmulRight

variable[Semiringₓ S][Module R S][Module S M][IsScalarTower R S M]

/-- When `f` is an `R`-linear map taking values in `S`, then `λb, f b • x` is an `R`-linear map. -/
def smul_right (f : M₁ →ₗ[R] S) (x : M) : M₁ →ₗ[R] M :=
  { toFun := fun b => f b • x,
    map_add' :=
      fun x y =>
        by 
          rw [f.map_add, add_smul],
    map_smul' :=
      fun b y =>
        by 
          dsimp <;> rw [f.map_smul, smul_assoc] }

@[simp]
theorem coe_smul_right (f : M₁ →ₗ[R] S) (x : M) : (smul_right f x : M₁ → M) = fun c => f c • x :=
  rfl

theorem smul_right_apply (f : M₁ →ₗ[R] S) (x : M) (c : M₁) : smul_right f x c = f c • x :=
  rfl

end SmulRight

instance  [Nontrivial M] : Nontrivial (Module.End R M) :=
  by 
    obtain ⟨m, ne⟩ := (nontrivial_iff_exists_ne (0 : M)).mp inferInstance 
    exact nontrivial_of_ne 1 0 fun p => Ne (LinearMap.congr_fun p m)

@[simp, normCast]
theorem coe_fn_sum {ι : Type _} (t : Finset ι) (f : ι → M →ₛₗ[σ₁₂] M₂) :
  «expr⇑ » (∑i in t, f i) = ∑i in t, (f i : M → M₂) :=
  AddMonoidHom.map_sum ⟨@to_fun R R₂ _ _ σ₁₂ M M₂ _ _ _ _, rfl, fun x y => rfl⟩ _ _

@[simp]
theorem pow_apply (f : M →ₗ[R] M) (n : ℕ) (m : M) : (f ^ n) m = (f^[n]) m :=
  by 
    induction' n with n ih
    ·
      rfl
    ·
      simp only [Function.comp_app, Function.iterate_succ, LinearMap.mul_apply, pow_succₓ, ih]
      exact (Function.Commute.iterate_self _ _ m).symm

theorem pow_map_zero_of_le {f : Module.End R M} {m : M} {k l : ℕ} (hk : k ≤ l) (hm : (f ^ k) m = 0) : (f ^ l) m = 0 :=
  by 
    rw [←tsub_add_cancel_of_le hk, pow_addₓ, mul_apply, hm, map_zero]

theorem commute_pow_left_of_commute {f : M →ₛₗ[σ₁₂] M₂} {g : Module.End R M} {g₂ : Module.End R₂ M₂}
  (h : g₂.comp f = f.comp g) (k : ℕ) : (g₂ ^ k).comp f = f.comp (g ^ k) :=
  by 
    induction' k with k ih
    ·
      simpa only [pow_zeroₓ]
    ·
      rw [pow_succₓ, pow_succₓ, LinearMap.mul_eq_comp, LinearMap.comp_assoc, ih, ←LinearMap.comp_assoc, h,
        LinearMap.comp_assoc, LinearMap.mul_eq_comp]

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem submodule_pow_eq_zero_of_pow_eq_zero
{N : submodule R M}
{g : module.End R N}
{G : module.End R M}
(h : «expr = »(G.comp N.subtype, N.subtype.comp g))
{k : exprℕ()}
(hG : «expr = »(«expr ^ »(G, k), 0)) : «expr = »(«expr ^ »(g, k), 0) :=
begin
  ext [] [ident m] [],
  have [ident hg] [":", expr «expr = »(N.subtype.comp «expr ^ »(g, k) m, 0)] [],
  { rw ["[", "<-", expr commute_pow_left_of_commute h, ",", expr hG, ",", expr zero_comp, ",", expr zero_apply, "]"] [] },
  simp [] [] ["only"] ["[", expr submodule.subtype_apply, ",", expr comp_app, ",", expr submodule.coe_eq_zero, ",", expr coe_comp, "]"] [] ["at", ident hg],
  rw ["[", expr hg, ",", expr linear_map.zero_apply, "]"] []
end

theorem coe_pow (f : M →ₗ[R] M) (n : ℕ) : «expr⇑ » (f ^ n) = f^[n] :=
  by 
    ext m 
    apply pow_apply

@[simp]
theorem id_pow (n : ℕ) : (id : M →ₗ[R] M) ^ n = id :=
  one_pow n

section 

variable{f' : M →ₗ[R] M}

theorem iterate_succ (n : ℕ) : (f' ^ n+1) = comp (f' ^ n) f' :=
  by 
    rw [pow_succ'ₓ, mul_eq_comp]

theorem iterate_surjective (h : surjective f') : ∀ (n : ℕ), surjective («expr⇑ » (f' ^ n))
| 0 => surjective_id
| n+1 =>
  by 
    rw [iterate_succ]
    exact surjective.comp (iterate_surjective n) h

theorem iterate_injective (h : injective f') : ∀ (n : ℕ), injective («expr⇑ » (f' ^ n))
| 0 => injective_id
| n+1 =>
  by 
    rw [iterate_succ]
    exact injective.comp (iterate_injective n) h

theorem iterate_bijective (h : bijective f') : ∀ (n : ℕ), bijective («expr⇑ » (f' ^ n))
| 0 => bijective_id
| n+1 =>
  by 
    rw [iterate_succ]
    exact bijective.comp (iterate_bijective n) h

theorem injective_of_iterate_injective {n : ℕ} (hn : n ≠ 0) (h : injective («expr⇑ » (f' ^ n))) : injective f' :=
  by 
    rw [←Nat.succ_pred_eq_of_posₓ (pos_iff_ne_zero.mpr hn), iterate_succ, coe_comp] at h 
    exact injective.of_comp h

theorem surjective_of_iterate_surjective {n : ℕ} (hn : n ≠ 0) (h : surjective («expr⇑ » (f' ^ n))) : surjective f' :=
  by 
    rw [←Nat.succ_pred_eq_of_posₓ (pos_iff_ne_zero.mpr hn), Nat.succ_eq_add_one, add_commₓ, pow_addₓ] at h 
    exact surjective.of_comp h

end 

section 

open_locale Classical

/-- A linear map `f` applied to `x : ι → R` can be computed using the image under `f` of elements
of the canonical basis. -/
theorem pi_apply_eq_sum_univ [Fintype ι] (f : (ι → R) →ₗ[R] M) (x : ι → R) :
  f x = ∑i, x i • f fun j => if i = j then 1 else 0 :=
  by 
    convLHS => rw [pi_eq_sum_univ x, f.map_sum]
    apply Finset.sum_congr rfl fun l hl => _ 
    rw [f.map_smul]

end 

end AddCommMonoidₓ

section Module

variable[Semiringₓ
      R][Semiringₓ
      S][AddCommMonoidₓ
      M][AddCommMonoidₓ
      M₂][AddCommMonoidₓ
      M₃][Module R
      M][Module R M₂][Module R M₃][Module S M₂][Module S M₃][SmulCommClass R S M₂][SmulCommClass R S M₃](f : M →ₗ[R] M₂)

variable(S)

/-- Applying a linear map at `v : M`, seen as `S`-linear map from `M →ₗ[R] M₂` to `M₂`.

 See `linear_map.applyₗ` for a version where `S = R`. -/
@[simps]
def applyₗ' : M →+ (M →ₗ[R] M₂) →ₗ[S] M₂ :=
  { toFun :=
      fun v =>
        { toFun := fun f => f v, map_add' := fun f g => f.add_apply g v, map_smul' := fun x f => f.smul_apply x v },
    map_zero' := LinearMap.ext$ fun f => f.map_zero, map_add' := fun x y => LinearMap.ext$ fun f => f.map_add _ _ }

section 

variable(R M)

/--
The equivalence between R-linear maps from `R` to `M`, and points of `M` itself.
This says that the forgetful functor from `R`-modules to types is representable, by `R`.

This as an `S`-linear equivalence, under the assumption that `S` acts on `M` commuting with `R`.
When `R` is commutative, we can take this to be the usual action with `S = R`.
Otherwise, `S = ℕ` shows that the equivalence is additive.
See note [bundled maps over different rings].
-/
@[simps]
def ring_lmap_equiv_self [Module S M] [SmulCommClass R S M] : (R →ₗ[R] M) ≃ₗ[S] M :=
  { applyₗ' S (1 : R) with toFun := fun f => f 1, invFun := smul_right (1 : R →ₗ[R] R),
    left_inv :=
      fun f =>
        by 
          ext 
          simp ,
    right_inv :=
      fun x =>
        by 
          simp  }

end 

end Module

section CommSemiringₓ

variable[CommSemiringₓ R][AddCommMonoidₓ M][AddCommMonoidₓ M₂][AddCommMonoidₓ M₃]

variable[Module R M][Module R M₂][Module R M₃]

variable(f g : M →ₗ[R] M₂)

include R

/-- Composition by `f : M₂ → M₃` is a linear map from the space of linear maps `M → M₂`
to the space of linear maps `M₂ → M₃`. -/
def comp_right (f : M₂ →ₗ[R] M₃) : (M →ₗ[R] M₂) →ₗ[R] M →ₗ[R] M₃ :=
  { toFun := f.comp, map_add' := fun _ _ => LinearMap.ext$ fun _ => f.map_add _ _,
    map_smul' := fun _ _ => LinearMap.ext$ fun _ => f.map_smul _ _ }

/-- Applying a linear map at `v : M`, seen as a linear map from `M →ₗ[R] M₂` to `M₂`.
See also `linear_map.applyₗ'` for a version that works with two different semirings.

This is the `linear_map` version of `add_monoid_hom.eval`. -/
@[simps]
def applyₗ : M →ₗ[R] (M →ₗ[R] M₂) →ₗ[R] M₂ :=
  { applyₗ' R with toFun := fun v => { applyₗ' R v with toFun := fun f => f v },
    map_smul' := fun x y => LinearMap.ext$ fun f => f.map_smul _ _ }

/-- Alternative version of `dom_restrict` as a linear map. -/
def dom_restrict' (p : Submodule R M) : (M →ₗ[R] M₂) →ₗ[R] p →ₗ[R] M₂ :=
  { toFun := fun φ => φ.dom_restrict p,
    map_add' :=
      by 
        simp [LinearMap.ext_iff],
    map_smul' :=
      by 
        simp [LinearMap.ext_iff] }

@[simp]
theorem dom_restrict'_apply (f : M →ₗ[R] M₂) (p : Submodule R M) (x : p) : dom_restrict' p f x = f x :=
  rfl

end CommSemiringₓ

section CommRingₓ

variable[CommRingₓ R][AddCommGroupₓ M][AddCommGroupₓ M₂][AddCommGroupₓ M₃]

variable[Module R M][Module R M₂][Module R M₃]

/--
The family of linear maps `M₂ → M` parameterised by `f ∈ M₂ → R`, `x ∈ M`, is linear in `f`, `x`.
-/
def smul_rightₗ : (M₂ →ₗ[R] R) →ₗ[R] M →ₗ[R] M₂ →ₗ[R] M :=
  { toFun :=
      fun f =>
        { toFun := LinearMap.smulRight f,
          map_add' :=
            fun m m' =>
              by 
                ext 
                apply smul_add,
          map_smul' :=
            fun c m =>
              by 
                ext 
                apply smul_comm },
    map_add' :=
      fun f f' =>
        by 
          ext 
          apply add_smul,
    map_smul' :=
      fun c f =>
        by 
          ext 
          apply mul_smul }

@[simp]
theorem smul_rightₗ_apply (f : M₂ →ₗ[R] R) (x : M) (c : M₂) :
  (smul_rightₗ : (M₂ →ₗ[R] R) →ₗ[R] M →ₗ[R] M₂ →ₗ[R] M) f x c = f c • x :=
  rfl

end CommRingₓ

end LinearMap

/--
The `R`-linear equivalence between additive morphisms `A →+ B` and `ℕ`-linear morphisms `A →ₗ[ℕ] B`.
-/
@[simps]
def addMonoidHomLequivNat {A B : Type _} (R : Type _) [Semiringₓ R] [AddCommMonoidₓ A] [AddCommMonoidₓ B] [Module R B] :
  (A →+ B) ≃ₗ[R] A →ₗ[ℕ] B :=
  { toFun := AddMonoidHom.toNatLinearMap, invFun := LinearMap.toAddMonoidHom,
    map_add' :=
      by 
        intros 
        ext 
        rfl,
    map_smul' :=
      by 
        intros 
        ext 
        rfl,
    left_inv :=
      by 
        intro f 
        ext 
        rfl,
    right_inv :=
      by 
        intro f 
        ext 
        rfl }

/--
The `R`-linear equivalence between additive morphisms `A →+ B` and `ℤ`-linear morphisms `A →ₗ[ℤ] B`.
-/
@[simps]
def addMonoidHomLequivInt {A B : Type _} (R : Type _) [Semiringₓ R] [AddCommGroupₓ A] [AddCommGroupₓ B] [Module R B] :
  (A →+ B) ≃ₗ[R] A →ₗ[ℤ] B :=
  { toFun := AddMonoidHom.toIntLinearMap, invFun := LinearMap.toAddMonoidHom,
    map_add' :=
      by 
        intros 
        ext 
        rfl,
    map_smul' :=
      by 
        intros 
        ext 
        rfl,
    left_inv :=
      by 
        intro f 
        ext 
        rfl,
    right_inv :=
      by 
        intro f 
        ext 
        rfl }

/-! ### Properties of submodules -/


namespace Submodule

section AddCommMonoidₓ

variable[Semiringₓ R][Semiringₓ R₂][Semiringₓ R₃]

variable[AddCommMonoidₓ M][AddCommMonoidₓ M₂][AddCommMonoidₓ M₃][AddCommMonoidₓ M']

variable[Module R M][Module R M'][Module R₂ M₂][Module R₃ M₃]

variable{σ₁₂ : R →+* R₂}{σ₂₃ : R₂ →+* R₃}{σ₁₃ : R →+* R₃}

variable{σ₂₁ : R₂ →+* R}

variable[RingHomInvPair σ₁₂ σ₂₁][RingHomInvPair σ₂₁ σ₁₂]

variable[RingHomCompTriple σ₁₂ σ₂₃ σ₁₃]

variable(p p' : Submodule R M)(q q' : Submodule R₂ M₂)

variable(q₁ q₁' : Submodule R M')

variable{r : R}{x y : M}

open Set

variable{p p'}

/-- If two submodules `p` and `p'` satisfy `p ⊆ p'`, then `of_le p p'` is the linear map version of
this inclusion. -/
def of_le (h : p ≤ p') : p →ₗ[R] p' :=
  p.subtype.cod_restrict p'$ fun ⟨x, hx⟩ => h hx

@[simp]
theorem coe_of_le (h : p ≤ p') (x : p) : (of_le h x : M) = x :=
  rfl

theorem of_le_apply (h : p ≤ p') (x : p) : of_le h x = ⟨x, h x.2⟩ :=
  rfl

theorem of_le_injective (h : p ≤ p') : Function.Injective (of_le h) :=
  fun x y h => Subtype.val_injective (Subtype.mk.injₓ h)

variable(p p')

theorem subtype_comp_of_le (p q : Submodule R M) (h : p ≤ q) : q.subtype.comp (of_le h) = p.subtype :=
  by 
    ext ⟨b, hb⟩
    rfl

variable(R)

@[simp]
theorem subsingleton_iff : Subsingleton (Submodule R M) ↔ Subsingleton M :=
  have h : Subsingleton (Submodule R M) ↔ Subsingleton (AddSubmonoid M) :=
    by 
      rw [←subsingleton_iff_bot_eq_top, ←subsingleton_iff_bot_eq_top]
      convert to_add_submonoid_eq.symm <;> rfl 
  h.trans AddSubmonoid.subsingleton_iff

@[simp]
theorem nontrivial_iff : Nontrivial (Submodule R M) ↔ Nontrivial M :=
  not_iff_not.mp
    ((not_nontrivial_iff_subsingleton.trans$ subsingleton_iff R).trans not_nontrivial_iff_subsingleton.symm)

variable{R}

instance  [Subsingleton M] : Unique (Submodule R M) :=
  ⟨⟨⊥⟩, fun a => @Subsingleton.elimₓ _ ((subsingleton_iff R).mpr ‹_›) a _⟩

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
instance unique' [subsingleton R] : unique (submodule R M) :=
by haveI [] [] [":=", expr module.subsingleton R M]; apply_instance

instance  [Nontrivial M] : Nontrivial (Submodule R M) :=
  (nontrivial_iff R).mpr ‹_›

theorem disjoint_def {p p' : Submodule R M} : Disjoint p p' ↔ ∀ x (_ : x ∈ p), x ∈ p' → x = (0 : M) :=
  show (∀ x, x ∈ p ∧ x ∈ p' → x ∈ ({0} : Set M)) ↔ _ by 
    simp 

theorem disjoint_def' {p p' : Submodule R M} : Disjoint p p' ↔ ∀ x (_ : x ∈ p) y (_ : y ∈ p'), x = y → x = (0 : M) :=
  disjoint_def.trans ⟨fun h x hx y hy hxy => h x hx$ hxy.symm ▸ hy, fun h x hx hx' => h _ hx x hx' rfl⟩

theorem mem_right_iff_eq_zero_of_disjoint {p p' : Submodule R M} (h : Disjoint p p') {x : p} : (x : M) ∈ p' ↔ x = 0 :=
  ⟨fun hx => coe_eq_zero.1$ disjoint_def.1 h x x.2 hx, fun h => h.symm ▸ p'.zero_mem⟩

theorem mem_left_iff_eq_zero_of_disjoint {p p' : Submodule R M} (h : Disjoint p p') {x : p'} : (x : M) ∈ p ↔ x = 0 :=
  ⟨fun hx => coe_eq_zero.1$ disjoint_def.1 h x hx x.2, fun h => h.symm ▸ p.zero_mem⟩

section 

variable[RingHomSurjective σ₁₂]

/-- The pushforward of a submodule `p ⊆ M` by `f : M → M₂` -/
def map (f : M →ₛₗ[σ₁₂] M₂) (p : Submodule R M) : Submodule R₂ M₂ :=
  { p.to_add_submonoid.map f.to_add_monoid_hom with Carrier := f '' p,
    smul_mem' :=
      by 
        rintro c x ⟨y, hy, rfl⟩
        obtain ⟨a, rfl⟩ := σ₁₂.is_surjective c 
        exact ⟨_, p.smul_mem a hy, f.map_smulₛₗ _ _⟩ }

@[simp]
theorem map_coe (f : M →ₛₗ[σ₁₂] M₂) (p : Submodule R M) : (map f p : Set M₂) = f '' p :=
  rfl

@[simp]
theorem mem_map {f : M →ₛₗ[σ₁₂] M₂} {p : Submodule R M} {x : M₂} : x ∈ map f p ↔ ∃ y, y ∈ p ∧ f y = x :=
  Iff.rfl

theorem mem_map_of_mem {f : M →ₛₗ[σ₁₂] M₂} {p : Submodule R M} {r} (h : r ∈ p) : f r ∈ map f p :=
  Set.mem_image_of_mem _ h

theorem apply_coe_mem_map (f : M →ₛₗ[σ₁₂] M₂) {p : Submodule R M} (r : p) : f r ∈ map f p :=
  mem_map_of_mem r.prop

@[simp]
theorem map_id : map (LinearMap.id : M →ₗ[R] M) p = p :=
  Submodule.ext$
    fun a =>
      by 
        simp 

theorem map_comp [RingHomSurjective σ₂₃] [RingHomSurjective σ₁₃] (f : M →ₛₗ[σ₁₂] M₂) (g : M₂ →ₛₗ[σ₂₃] M₃)
  (p : Submodule R M) : map (g.comp f : M →ₛₗ[σ₁₃] M₃) p = map g (map f p) :=
  SetLike.coe_injective$
    by 
      simp [map_coe] <;> rw [←image_comp]

theorem map_mono {f : M →ₛₗ[σ₁₂] M₂} {p p' : Submodule R M} : p ≤ p' → map f p ≤ map f p' :=
  image_subset _

@[simp]
theorem map_zero : map (0 : M →ₛₗ[σ₁₂] M₂) p = ⊥ :=
  have  : ∃ x : M, x ∈ p := ⟨0, p.zero_mem⟩
  ext$
    by 
      simp [this, eq_comm]

theorem map_add_le (f g : M →ₛₗ[σ₁₂] M₂) : map (f+g) p ≤ map f p⊔map g p :=
  by 
    rintro x ⟨m, hm, rfl⟩
    exact add_mem_sup (mem_map_of_mem hm) (mem_map_of_mem hm)

theorem range_map_nonempty (N : Submodule R M) :
  (Set.Range (fun ϕ => Submodule.map ϕ N : (M →ₛₗ[σ₁₂] M₂) → Submodule R₂ M₂)).Nonempty :=
  ⟨_, Set.mem_range.mpr ⟨0, rfl⟩⟩

end 

include σ₂₁

/-- The pushforward of a submodule by an injective linear map is
linearly equivalent to the original submodule. -/
noncomputable def equiv_map_of_injective (f : M →ₛₗ[σ₁₂] M₂) (i : injective f) (p : Submodule R M) :
  p ≃ₛₗ[σ₁₂] p.map f :=
  { Equiv.Set.image f p i with
    map_add' :=
      by 
        intros 
        simp 
        rfl,
    map_smul' :=
      by 
        intros 
        simp 
        rfl }

@[simp]
theorem coe_equiv_map_of_injective_apply (f : M →ₛₗ[σ₁₂] M₂) (i : injective f) (p : Submodule R M) (x : p) :
  (equiv_map_of_injective f i p x : M₂) = f x :=
  rfl

omit σ₂₁

/-- The pullback of a submodule `p ⊆ M₂` along `f : M → M₂` -/
def comap (f : M →ₛₗ[σ₁₂] M₂) (p : Submodule R₂ M₂) : Submodule R M :=
  { p.to_add_submonoid.comap f.to_add_monoid_hom with Carrier := f ⁻¹' p,
    smul_mem' :=
      fun a x h =>
        by 
          simp [p.smul_mem _ h] }

@[simp]
theorem comap_coe (f : M →ₛₗ[σ₁₂] M₂) (p : Submodule R₂ M₂) : (comap f p : Set M) = f ⁻¹' p :=
  rfl

@[simp]
theorem mem_comap {f : M →ₛₗ[σ₁₂] M₂} {p : Submodule R₂ M₂} : x ∈ comap f p ↔ f x ∈ p :=
  Iff.rfl

theorem comap_id : comap LinearMap.id p = p :=
  SetLike.coe_injective rfl

theorem comap_comp (f : M →ₛₗ[σ₁₂] M₂) (g : M₂ →ₛₗ[σ₂₃] M₃) (p : Submodule R₃ M₃) :
  comap (g.comp f : M →ₛₗ[σ₁₃] M₃) p = comap f (comap g p) :=
  rfl

theorem comap_mono {f : M →ₛₗ[σ₁₂] M₂} {q q' : Submodule R₂ M₂} : q ≤ q' → comap f q ≤ comap f q' :=
  preimage_mono

section 

variable[RingHomSurjective σ₁₂]

theorem map_le_iff_le_comap {f : M →ₛₗ[σ₁₂] M₂} {p : Submodule R M} {q : Submodule R₂ M₂} :
  map f p ≤ q ↔ p ≤ comap f q :=
  image_subset_iff

theorem gc_map_comap (f : M →ₛₗ[σ₁₂] M₂) : GaloisConnection (map f) (comap f)
| p, q => map_le_iff_le_comap

@[simp]
theorem map_bot (f : M →ₛₗ[σ₁₂] M₂) : map f ⊥ = ⊥ :=
  (gc_map_comap f).l_bot

@[simp]
theorem map_sup (f : M →ₛₗ[σ₁₂] M₂) : map f (p⊔p') = map f p⊔map f p' :=
  (gc_map_comap f).l_sup

@[simp]
theorem map_supr {ι : Sort _} (f : M →ₛₗ[σ₁₂] M₂) (p : ι → Submodule R M) : map f (⨆i, p i) = ⨆i, map f (p i) :=
  (gc_map_comap f).l_supr

end 

@[simp]
theorem comap_top (f : M →ₛₗ[σ₁₂] M₂) : comap f ⊤ = ⊤ :=
  rfl

@[simp]
theorem comap_inf (f : M →ₛₗ[σ₁₂] M₂) : comap f (q⊓q') = comap f q⊓comap f q' :=
  rfl

@[simp]
theorem comap_infi [RingHomSurjective σ₁₂] {ι : Sort _} (f : M →ₛₗ[σ₁₂] M₂) (p : ι → Submodule R₂ M₂) :
  comap f (⨅i, p i) = ⨅i, comap f (p i) :=
  (gc_map_comap f).u_infi

@[simp]
theorem comap_zero : comap (0 : M →ₛₗ[σ₁₂] M₂) q = ⊤ :=
  ext$
    by 
      simp 

theorem map_comap_le [RingHomSurjective σ₁₂] (f : M →ₛₗ[σ₁₂] M₂) (q : Submodule R₂ M₂) : map f (comap f q) ≤ q :=
  (gc_map_comap f).l_u_le _

theorem le_comap_map [RingHomSurjective σ₁₂] (f : M →ₛₗ[σ₁₂] M₂) (p : Submodule R M) : p ≤ comap f (map f p) :=
  (gc_map_comap f).le_u_l _

section GaloisInsertion

variable{f : M →ₛₗ[σ₁₂] M₂}(hf : surjective f)

variable[RingHomSurjective σ₁₂]

include hf

/-- `map f` and `comap f` form a `galois_insertion` when `f` is surjective. -/
def gi_map_comap : GaloisInsertion (map f) (comap f) :=
  (gc_map_comap f).toGaloisInsertion
    fun S x hx =>
      by 
        rcases hf x with ⟨y, rfl⟩
        simp only [mem_map, mem_comap]
        exact ⟨y, hx, rfl⟩

theorem map_comap_eq_of_surjective (p : Submodule R₂ M₂) : (p.comap f).map f = p :=
  (gi_map_comap hf).l_u_eq _

theorem map_surjective_of_surjective : Function.Surjective (map f) :=
  (gi_map_comap hf).l_surjective

theorem comap_injective_of_surjective : Function.Injective (comap f) :=
  (gi_map_comap hf).u_injective

theorem map_sup_comap_of_surjective (p q : Submodule R₂ M₂) : (p.comap f⊔q.comap f).map f = p⊔q :=
  (gi_map_comap hf).l_sup_u _ _

theorem map_supr_comap_of_sujective (S : ι → Submodule R₂ M₂) : (⨆i, (S i).comap f).map f = supr S :=
  (gi_map_comap hf).l_supr_u _

theorem map_inf_comap_of_surjective (p q : Submodule R₂ M₂) : (p.comap f⊓q.comap f).map f = p⊓q :=
  (gi_map_comap hf).l_inf_u _ _

theorem map_infi_comap_of_surjective (S : ι → Submodule R₂ M₂) : (⨅i, (S i).comap f).map f = infi S :=
  (gi_map_comap hf).l_infi_u _

theorem comap_le_comap_iff_of_surjective (p q : Submodule R₂ M₂) : p.comap f ≤ q.comap f ↔ p ≤ q :=
  (gi_map_comap hf).u_le_u_iff

theorem comap_strict_mono_of_surjective : StrictMono (comap f) :=
  (gi_map_comap hf).strict_mono_u

end GaloisInsertion

section GaloisCoinsertion

variable[RingHomSurjective σ₁₂]{f : M →ₛₗ[σ₁₂] M₂}(hf : injective f)

include hf

/-- `map f` and `comap f` form a `galois_coinsertion` when `f` is injective. -/
def gci_map_comap : GaloisCoinsertion (map f) (comap f) :=
  (gc_map_comap f).toGaloisCoinsertion
    fun S x =>
      by 
        simp [mem_comap, mem_map, hf.eq_iff]

theorem comap_map_eq_of_injective (p : Submodule R M) : (p.map f).comap f = p :=
  (gci_map_comap hf).u_l_eq _

theorem comap_surjective_of_injective : Function.Surjective (comap f) :=
  (gci_map_comap hf).u_surjective

theorem map_injective_of_injective : Function.Injective (map f) :=
  (gci_map_comap hf).l_injective

theorem comap_inf_map_of_injective (p q : Submodule R M) : (p.map f⊓q.map f).comap f = p⊓q :=
  (gci_map_comap hf).u_inf_l _ _

theorem comap_infi_map_of_injective (S : ι → Submodule R M) : (⨅i, (S i).map f).comap f = infi S :=
  (gci_map_comap hf).u_infi_l _

theorem comap_sup_map_of_injective (p q : Submodule R M) : (p.map f⊔q.map f).comap f = p⊔q :=
  (gci_map_comap hf).u_sup_l _ _

theorem comap_supr_map_of_injective (S : ι → Submodule R M) : (⨆i, (S i).map f).comap f = supr S :=
  (gci_map_comap hf).u_supr_l _

theorem map_le_map_iff_of_injective (p q : Submodule R M) : p.map f ≤ q.map f ↔ p ≤ q :=
  (gci_map_comap hf).l_le_l_iff

theorem map_strict_mono_of_injective : StrictMono (map f) :=
  (gci_map_comap hf).strict_mono_l

end GaloisCoinsertion

theorem map_inf_eq_map_inf_comap [RingHomSurjective σ₁₂] {f : M →ₛₗ[σ₁₂] M₂} {p : Submodule R M}
  {p' : Submodule R₂ M₂} : map f p⊓p' = map f (p⊓comap f p') :=
  le_antisymmₓ
    (by 
      rintro _ ⟨⟨x, h₁, rfl⟩, h₂⟩ <;> exact ⟨_, ⟨h₁, h₂⟩, rfl⟩)
    (le_inf (map_mono inf_le_left) (map_le_iff_le_comap.2 inf_le_right))

theorem map_comap_subtype : map p.subtype (comap p.subtype p') = p⊓p' :=
  ext$
    fun x =>
      ⟨by 
          rintro ⟨⟨_, h₁⟩, h₂, rfl⟩ <;> exact ⟨h₁, h₂⟩,
        fun ⟨h₁, h₂⟩ => ⟨⟨_, h₁⟩, h₂, rfl⟩⟩

theorem eq_zero_of_bot_submodule : ∀ (b : (⊥ : Submodule R M)), b = 0
| ⟨b', hb⟩ => Subtype.eq$ show b' = 0 from (mem_bot R).1 hb

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The infimum of a family of invariant submodule of an endomorphism is also an invariant
submodule. -/
theorem _root_.linear_map.infi_invariant
{σ : «expr →+* »(R, R)}
[ring_hom_surjective σ]
{ι : Type*}
(f : «expr →ₛₗ[ ] »(M, σ, M))
{p : ι → submodule R M}
(hf : ∀ i, ∀ v «expr ∈ » p i, «expr ∈ »(f v, p i)) : ∀ v «expr ∈ » infi p, «expr ∈ »(f v, infi p) :=
begin
  have [] [":", expr ∀ i, «expr ≤ »((p i).map f, p i)] [],
  { rintros [ident i, "-", "⟨", ident v, ",", ident hv, ",", ident rfl, "⟩"],
    exact [expr hf i v hv] },
  suffices [] [":", expr «expr ≤ »((infi p).map f, infi p)],
  { exact [expr λ v hv, this ⟨v, hv, rfl⟩] },
  exact [expr le_infi (λ i, (submodule.map_mono (infi_le p i)).trans (this i))]
end

section 

variable(R)

/-- The span of a set `s ⊆ M` is the smallest submodule of M that contains `s`. -/
def span (s : Set M) : Submodule R M :=
  Inf { p | s ⊆ p }

end 

variable{s t : Set M}

theorem mem_span : x ∈ span R s ↔ ∀ (p : Submodule R M), s ⊆ p → x ∈ p :=
  mem_bInter_iff

theorem subset_span : s ⊆ span R s :=
  fun x h => mem_span.2$ fun p hp => hp h

theorem span_le {p} : span R s ≤ p ↔ s ⊆ p :=
  ⟨subset.trans subset_span, fun ss x h => mem_span.1 h _ ss⟩

theorem span_mono (h : s ⊆ t) : span R s ≤ span R t :=
  span_le.2$ subset.trans h subset_span

theorem span_eq_of_le (h₁ : s ⊆ p) (h₂ : p ≤ span R s) : span R s = p :=
  le_antisymmₓ (span_le.2 h₁) h₂

theorem span_eq : span R (p : Set M) = p :=
  span_eq_of_le _ (subset.refl _) subset_span

/-- A version of `submodule.span_eq` for when the span is by a smaller ring. -/
@[simp]
theorem span_coe_eq_restrict_scalars [Semiringₓ S] [HasScalar S R] [Module S M] [IsScalarTower S R M] :
  span S (p : Set M) = p.restrict_scalars S :=
  span_eq (p.restrict_scalars S)

theorem map_span [RingHomSurjective σ₁₂] (f : M →ₛₗ[σ₁₂] M₂) (s : Set M) : (span R s).map f = span R₂ (f '' s) :=
  Eq.symm$
    span_eq_of_le _ (Set.image_subset f subset_span)$
      map_le_iff_le_comap.2$ span_le.2$ fun x hx => subset_span ⟨x, hx, rfl⟩

alias Submodule.map_span ← LinearMap.map_span

theorem map_span_le [RingHomSurjective σ₁₂] (f : M →ₛₗ[σ₁₂] M₂) (s : Set M) (N : Submodule R₂ M₂) :
  map f (span R s) ≤ N ↔ ∀ m (_ : m ∈ s), f m ∈ N :=
  by 
    rw [f.map_span, span_le, Set.image_subset_iff]
    exact Iff.rfl

alias Submodule.map_span_le ← LinearMap.map_span_le

@[simp]
theorem span_insert_zero : span R (insert (0 : M) s) = span R s :=
  by 
    refine' le_antisymmₓ _ (Submodule.span_mono (Set.subset_insert 0 s))
    rw [span_le, Set.insert_subset]
    exact
      ⟨by 
          simp only [SetLike.mem_coe, Submodule.zero_mem],
        Submodule.subset_span⟩

theorem span_preimage_le (f : M →ₛₗ[σ₁₂] M₂) (s : Set M₂) : span R (f ⁻¹' s) ≤ (span R₂ s).comap f :=
  by 
    rw [span_le, comap_coe]
    exact preimage_mono subset_span

alias Submodule.span_preimage_le ← LinearMap.span_preimage_le

/-- An induction principle for span membership. If `p` holds for 0 and all elements of `s`, and is
preserved under addition and scalar multiplication, then `p` holds for all elements of the span of
`s`. -/
@[elab_as_eliminator]
theorem span_induction {p : M → Prop} (h : x ∈ span R s) (Hs : ∀ x (_ : x ∈ s), p x) (H0 : p 0)
  (H1 : ∀ x y, p x → p y → p (x+y)) (H2 : ∀ (a : R) x, p x → p (a • x)) : p x :=
  (@span_le _ _ _ _ _ _ ⟨p, H0, H1, H2⟩).2 Hs h

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The difference with `submodule.span_induction` is that this acts on the subtype. -/
theorem span_induction'
{p : span R s → exprProp()}
(Hs : ∀ (x) (h : «expr ∈ »(x, s)), p ⟨x, subset_span h⟩)
(H0 : p 0)
(H1 : ∀ x y, p x → p y → p «expr + »(x, y))
(H2 : ∀ (a : R) (x), p x → p «expr • »(a, x))
(x : span R s) : p x :=
«expr $ »(subtype.rec_on x, λ x hx, begin
   refine [expr exists.elim _ (λ (hx : «expr ∈ »(x, span R s)) (hc : p ⟨x, hx⟩), hc)],
   refine [expr span_induction hx (λ
     m
     hm, ⟨subset_span hm, Hs m hm⟩) ⟨zero_mem _, H0⟩ (λ
     x
     y
     hx
     hy, «expr $ »(exists.elim hx, λ
      hx'
      hx, «expr $ »(exists.elim hy, λ
       hy'
       hy, ⟨add_mem _ hx' hy', H1 _ _ hx hy⟩))) (λ
     r x hx, «expr $ »(exists.elim hx, λ hx' hx, ⟨smul_mem _ _ hx', H2 r _ hx⟩))]
 end)

@[simp]
theorem span_span_coe_preimage : span R ((coeₓ : span R s → M) ⁻¹' s) = ⊤ :=
  by 
    refine' eq_top_iff.2 fun x hx => span_induction' (fun x hx => _) _ _ (fun r x hx => _) x
    ·
      exact subset_span hx
    ·
      exact Submodule.zero_mem _
    ·
      intro x y hx hy 
      exact Submodule.add_mem _ hx hy
    ·
      exact Submodule.smul_mem _ _ hx

theorem span_nat_eq_add_submonoid_closure (s : Set M) : (span ℕ s).toAddSubmonoid = AddSubmonoid.closure s :=
  by 
    refine' Eq.symm (AddSubmonoid.closure_eq_of_le subset_span _)
    apply add_submonoid.to_nat_submodule.symm.to_galois_connection.l_le _ 
    rw [span_le]
    exact AddSubmonoid.subset_closure

@[simp]
theorem span_nat_eq (s : AddSubmonoid M) : (span ℕ (s : Set M)).toAddSubmonoid = s :=
  by 
    rw [span_nat_eq_add_submonoid_closure, s.closure_eq]

theorem span_int_eq_add_subgroup_closure {M : Type _} [AddCommGroupₓ M] (s : Set M) :
  (span ℤ s).toAddSubgroup = AddSubgroup.closure s :=
  Eq.symm$
    AddSubgroup.closure_eq_of_le _ subset_span$
      fun x hx =>
        span_induction hx (fun x hx => AddSubgroup.subset_closure hx) (AddSubgroup.zero_mem _)
          (fun _ _ => AddSubgroup.add_mem _) fun _ _ _ => AddSubgroup.zsmul_mem _ ‹_› _

@[simp]
theorem span_int_eq {M : Type _} [AddCommGroupₓ M] (s : AddSubgroup M) : (span ℤ (s : Set M)).toAddSubgroup = s :=
  by 
    rw [span_int_eq_add_subgroup_closure, s.closure_eq]

section 

variable(R M)

/-- `span` forms a Galois insertion with the coercion from submodule to set. -/
protected def gi : GaloisInsertion (@span R M _ _ _) coeₓ :=
  { choice := fun s _ => span R s, gc := fun s t => span_le, le_l_u := fun s => subset_span,
    choice_eq := fun s h => rfl }

end 

@[simp]
theorem span_empty : span R (∅ : Set M) = ⊥ :=
  (Submodule.gi R M).gc.l_bot

@[simp]
theorem span_univ : span R (univ : Set M) = ⊤ :=
  eq_top_iff.2$ SetLike.le_def.2$ subset_span

theorem span_union (s t : Set M) : span R (s ∪ t) = span R s⊔span R t :=
  (Submodule.gi R M).gc.l_sup

theorem span_Union {ι} (s : ι → Set M) : span R (⋃i, s i) = ⨆i, span R (s i) :=
  (Submodule.gi R M).gc.l_supr

theorem span_eq_supr_of_singleton_spans (s : Set M) : span R s = ⨆(x : _)(_ : x ∈ s), span R {x} :=
  by 
    simp only [←span_Union, Set.bUnion_of_singleton s]

@[simp]
theorem coe_supr_of_directed {ι} [hι : Nonempty ι] (S : ι → Submodule R M) (H : Directed (· ≤ ·) S) :
  ((supr S : Submodule R M) : Set M) = ⋃i, S i :=
  by 
    refine' subset.antisymm _ (Union_subset$ le_supr S)
    suffices  : (span R (⋃i, (S i : Set M)) : Set M) ⊆ ⋃i : ι, «expr↑ » (S i)
    ·
      simpa only [span_Union, span_eq] using this 
    refine' fun x hx => span_induction hx (fun _ => id) _ _ _ <;> simp only [mem_Union, exists_imp_distrib]
    ·
      exact hι.elim fun i => ⟨i, (S i).zero_mem⟩
    ·
      intro x y i hi j hj 
      rcases H i j with ⟨k, ik, jk⟩
      exact ⟨k, add_mem _ (ik hi) (jk hj)⟩
    ·
      exact fun a x i hi => ⟨i, smul_mem _ a hi⟩

@[simp]
theorem mem_supr_of_directed {ι} [Nonempty ι] (S : ι → Submodule R M) (H : Directed (· ≤ ·) S) {x} :
  x ∈ supr S ↔ ∃ i, x ∈ S i :=
  by 
    rw [←SetLike.mem_coe, coe_supr_of_directed S H, mem_Union]
    rfl

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem mem_Sup_of_directed
{s : set (submodule R M)}
{z}
(hs : s.nonempty)
(hdir : directed_on ((«expr ≤ »)) s) : «expr ↔ »(«expr ∈ »(z, Sup s), «expr∃ , »((y «expr ∈ » s), «expr ∈ »(z, y))) :=
begin
  haveI [] [":", expr nonempty s] [":=", expr hs.to_subtype],
  simp [] [] ["only"] ["[", expr Sup_eq_supr', ",", expr mem_supr_of_directed _ hdir.directed_coe, ",", expr set_coe.exists, ",", expr subtype.coe_mk, "]"] [] []
end

@[normCast, simp]
theorem coe_supr_of_chain (a : ℕ →ₘ Submodule R M) : («expr↑ » (⨆k, a k) : Set M) = ⋃k, (a k : Set M) :=
  coe_supr_of_directed a a.monotone.directed_le

/-- We can regard `coe_supr_of_chain` as the statement that `coe : (submodule R M) → set M` is
Scott continuous for the ω-complete partial order induced by the complete lattice structures. -/
theorem coe_scott_continuous : OmegaCompletePartialOrder.Continuous' (coeₓ : Submodule R M → Set M) :=
  ⟨SetLike.coe_mono, coe_supr_of_chain⟩

@[simp]
theorem mem_supr_of_chain (a : ℕ →ₘ Submodule R M) (m : M) : (m ∈ ⨆k, a k) ↔ ∃ k, m ∈ a k :=
  mem_supr_of_directed a a.monotone.directed_le

section 

variable{p p'}

theorem mem_sup : x ∈ p⊔p' ↔ ∃ (y : _)(_ : y ∈ p)(z : _)(_ : z ∈ p'), (y+z) = x :=
  ⟨fun h =>
      by 
        rw [←span_eq p, ←span_eq p', ←span_union] at h 
        apply span_induction h
        ·
          rintro y (h | h)
          ·
            exact
              ⟨y, h, 0,
                by 
                  simp ,
                by 
                  simp ⟩
          ·
            exact
              ⟨0,
                by 
                  simp ,
                y, h,
                by 
                  simp ⟩
        ·
          exact
            ⟨0,
              by 
                simp ,
              0,
              by 
                simp ⟩
        ·
          rintro _ _ ⟨y₁, hy₁, z₁, hz₁, rfl⟩ ⟨y₂, hy₂, z₂, hz₂, rfl⟩
          exact
            ⟨_, add_mem _ hy₁ hy₂, _, add_mem _ hz₁ hz₂,
              by 
                simp [add_assocₓ] <;> cc⟩
        ·
          rintro a _ ⟨y, hy, z, hz, rfl⟩
          exact
            ⟨_, smul_mem _ a hy, _, smul_mem _ a hz,
              by 
                simp [smul_add]⟩,
    by 
      rintro ⟨y, hy, z, hz, rfl⟩ <;> exact add_mem _ ((le_sup_left : p ≤ p⊔p') hy) ((le_sup_right : p' ≤ p⊔p') hz)⟩

theorem mem_sup' : x ∈ p⊔p' ↔ ∃ (y : p)(z : p'), ((y : M)+z) = x :=
  mem_sup.trans$
    by 
      simp only [SetLike.exists, coe_mk]

theorem coe_sup : «expr↑ » (p⊔p') = (p+p' : Set M) :=
  by 
    ext 
    rw [SetLike.mem_coe, mem_sup, Set.mem_add]
    simp 

end 

notation:1000 R "∙" x => span R (@singleton _ _ Set.hasSingleton x)

theorem mem_span_singleton_self (x : M) : x ∈ R∙x :=
  subset_span rfl

theorem nontrivial_span_singleton {x : M} (h : x ≠ 0) : Nontrivial (R∙x) :=
  ⟨by 
      use 0, x, Submodule.mem_span_singleton_self x 
      intro H 
      rw [eq_comm, Submodule.mk_eq_zero] at H 
      exact h H⟩

theorem mem_span_singleton {y : M} : (x ∈ R∙y) ↔ ∃ a : R, a • y = x :=
  ⟨fun h =>
      by 
        apply span_induction h
        ·
          rintro y (rfl | ⟨⟨⟩⟩)
          exact
            ⟨1,
              by 
                simp ⟩
        ·
          exact
            ⟨0,
              by 
                simp ⟩
        ·
          rintro _ _ ⟨a, rfl⟩ ⟨b, rfl⟩
          exact
            ⟨a+b,
              by 
                simp [add_smul]⟩
        ·
          rintro a _ ⟨b, rfl⟩
          exact
            ⟨a*b,
              by 
                simp [smul_smul]⟩,
    by 
      rintro ⟨a, y, rfl⟩ <;>
        exact
          smul_mem _ _
            (subset_span$
              by 
                simp )⟩

theorem le_span_singleton_iff {s : Submodule R M} {v₀ : M} : (s ≤ R∙v₀) ↔ ∀ v (_ : v ∈ s), ∃ r : R, r • v₀ = v :=
  by 
    simpRw [SetLike.le_def, mem_span_singleton]

theorem span_singleton_eq_top_iff (x : M) : (R∙x) = ⊤ ↔ ∀ v, ∃ r : R, r • x = v :=
  by 
    rw [eq_top_iff, le_span_singleton_iff]
    finish

@[simp]
theorem span_zero_singleton : (R∙(0 : M)) = ⊥ :=
  by 
    ext 
    simp [mem_span_singleton, eq_comm]

theorem span_singleton_eq_range (y : M) : «expr↑ » (R∙y) = range (· • y : R → M) :=
  Set.ext$ fun x => mem_span_singleton

theorem span_singleton_smul_le (r : R) (x : M) : (R∙r • x) ≤ R∙x :=
  by 
    rw [span_le, Set.singleton_subset_iff, SetLike.mem_coe]
    exact smul_mem _ _ (mem_span_singleton_self _)

theorem span_singleton_smul_eq {K E : Type _} [DivisionRing K] [AddCommGroupₓ E] [Module K E] {r : K} (x : E)
  (hr : r ≠ 0) : (K∙r • x) = K∙x :=
  by 
    refine' le_antisymmₓ (span_singleton_smul_le r x) _ 
    convert span_singleton_smul_le (r⁻¹) (r • x)
    exact (inv_smul_smul₀ hr _).symm

theorem disjoint_span_singleton {K E : Type _} [DivisionRing K] [AddCommGroupₓ E] [Module K E] {s : Submodule K E}
  {x : E} : Disjoint s (K∙x) ↔ x ∈ s → x = 0 :=
  by 
    refine' disjoint_def.trans ⟨fun H hx => H x hx$ subset_span$ mem_singleton x, _⟩
    intro H y hy hyx 
    obtain ⟨c, hc⟩ := mem_span_singleton.1 hyx 
    subst y 
    classical 
    byCases' hc : c = 0
    ·
      simp only [hc, zero_smul]
    rw [s.smul_mem_iff hc] at hy 
    rw [H hy, smul_zero]

theorem disjoint_span_singleton' {K E : Type _} [DivisionRing K] [AddCommGroupₓ E] [Module K E] {p : Submodule K E}
  {x : E} (x0 : x ≠ 0) : Disjoint p (K∙x) ↔ x ∉ p :=
  disjoint_span_singleton.trans ⟨fun h₁ h₂ => x0 (h₁ h₂), fun h₁ h₂ => (h₁ h₂).elim⟩

theorem mem_span_insert {y} : x ∈ span R (insert y s) ↔ ∃ (a : R)(z : _)(_ : z ∈ span R s), x = (a • y)+z :=
  by 
    simp only [←union_singleton, span_union, mem_sup, mem_span_singleton, exists_prop, exists_exists_eq_and]
    rw [exists_comm]
    simp only [eq_comm, add_commₓ, exists_and_distrib_left]

theorem span_insert x (s : Set M) : span R (insert x s) = span R ({x} : Set M)⊔span R s :=
  by 
    rw [insert_eq, span_union]

theorem span_insert_eq_span (h : x ∈ span R s) : span R (insert x s) = span R s :=
  span_eq_of_le _ (Set.insert_subset.mpr ⟨h, subset_span⟩) (span_mono$ subset_insert _ _)

theorem span_span : span R (span R s : Set M) = span R s :=
  span_eq _

variable(R S s)

/-- If `R` is "smaller" ring than `S` then the span by `R` is smaller than the span by `S`. -/
theorem span_le_restrict_scalars [Semiringₓ S] [HasScalar R S] [Module S M] [IsScalarTower R S M] :
  span R s ≤ (span S s).restrictScalars R :=
  Submodule.span_le.2 Submodule.subset_span

/-- A version of `submodule.span_le_restrict_scalars` with coercions. -/
@[simp]
theorem span_subset_span [Semiringₓ S] [HasScalar R S] [Module S M] [IsScalarTower R S M] :
  «expr↑ » (span R s) ⊆ (span S s : Set M) :=
  span_le_restrict_scalars R S s

/-- Taking the span by a large ring of the span by the small ring is the same as taking the span
by just the large ring. -/
theorem span_span_of_tower [Semiringₓ S] [HasScalar R S] [Module S M] [IsScalarTower R S M] :
  span S (span R s : Set M) = span S s :=
  le_antisymmₓ (span_le.2$ span_subset_span R S s) (span_mono subset_span)

variable{R S s}

theorem span_eq_bot : span R (s : Set M) = ⊥ ↔ ∀ x (_ : x ∈ s), (x : M) = 0 :=
  eq_bot_iff.trans ⟨fun H x h => (mem_bot R).1$ H$ subset_span h, fun H => span_le.2 fun x h => (mem_bot R).2$ H x h⟩

@[simp]
theorem span_singleton_eq_bot : (R∙x) = ⊥ ↔ x = 0 :=
  span_eq_bot.trans$
    by 
      simp 

@[simp]
theorem span_zero : span R (0 : Set M) = ⊥ :=
  by 
    rw [←singleton_zero, span_singleton_eq_bot]

@[simp]
theorem span_image [RingHomSurjective σ₁₂] (f : M →ₛₗ[σ₁₂] M₂) : span R₂ (f '' s) = map f (span R s) :=
  (map_span f s).symm

theorem apply_mem_span_image_of_mem_span [RingHomSurjective σ₁₂] (f : M →ₛₗ[σ₁₂] M₂) {x : M} {s : Set M}
  (h : x ∈ Submodule.span R s) : f x ∈ Submodule.span R₂ (f '' s) :=
  by 
    rw [Submodule.span_image]
    exact Submodule.mem_map_of_mem h

/-- `f` is an explicit argument so we can `apply` this theorem and obtain `h` as a new goal. -/
theorem not_mem_span_of_apply_not_mem_span_image [RingHomSurjective σ₁₂] (f : M →ₛₗ[σ₁₂] M₂) {x : M} {s : Set M}
  (h : f x ∉ Submodule.span R₂ (f '' s)) : x ∉ Submodule.span R s :=
  h.imp (apply_mem_span_image_of_mem_span f)

theorem supr_eq_span {ι : Sort _} (p : ι → Submodule R M) : (⨆i : ι, p i) = Submodule.span R (⋃i : ι, «expr↑ » (p i)) :=
  le_antisymmₓ (supr_le$ fun i => subset.trans (fun m hm => Set.mem_Union.mpr ⟨i, hm⟩) subset_span)
    (span_le.mpr$ Union_subset_iff.mpr$ fun i m hm => mem_supr_of_mem i hm)

theorem span_singleton_le_iff_mem (m : M) (p : Submodule R M) : (R∙m) ≤ p ↔ m ∈ p :=
  by 
    rw [span_le, singleton_subset_iff, SetLike.mem_coe]

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem singleton_span_is_compact_element (x : M) : complete_lattice.is_compact_element (span R {x} : submodule R M) :=
begin
  rw [expr complete_lattice.is_compact_element_iff_le_of_directed_Sup_le] [],
  intros [ident d, ident hemp, ident hdir, ident hsup],
  have [] [":", expr «expr ∈ »(x, Sup d)] [],
  from [expr set_like.le_def.mp hsup (mem_span_singleton_self x)],
  obtain ["⟨", ident y, ",", "⟨", ident hyd, ",", ident hxy, "⟩", "⟩", ":=", expr (mem_Sup_of_directed hemp hdir).mp this],
  exact [expr ⟨y, ⟨hyd, by simpa [] [] ["only"] ["[", expr span_le, ",", expr singleton_subset_iff, "]"] [] []⟩⟩]
end

instance  : IsCompactlyGenerated (Submodule R M) :=
  ⟨fun s =>
      ⟨(fun x => span R {x}) '' s,
        ⟨fun t ht =>
            by 
              rcases(Set.mem_image _ _ _).1 ht with ⟨x, hx, rfl⟩
              apply singleton_span_is_compact_element,
          by 
            rw [Sup_eq_supr, supr_image, ←span_eq_supr_of_singleton_spans, span_eq]⟩⟩⟩

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem lt_sup_iff_not_mem
{I : submodule R M}
{a : M} : «expr ↔ »(«expr < »(I, «expr ⊔ »(I, «expr ∙ »(R, a))), «expr ∉ »(a, I)) :=
begin
  split,
  { intro [ident h],
    by_contra [ident akey],
    have [ident h1] [":", expr «expr ≤ »(«expr ⊔ »(I, «expr ∙ »(R, a)), I)] [],
    { simp [] [] ["only"] ["[", expr sup_le_iff, "]"] [] [],
      split,
      { exact [expr le_refl I] },
      { exact [expr (span_singleton_le_iff_mem a I).mpr akey] } },
    have [ident h2] [] [":=", expr gt_of_ge_of_gt h1 h],
    exact [expr lt_irrefl I h2] },
  { intro [ident h],
    apply [expr set_like.lt_iff_le_and_exists.mpr],
    split,
    simp [] [] ["only"] ["[", expr le_sup_left, "]"] [] [],
    use [expr a],
    split,
    swap,
    { assumption },
    { have [] [":", expr «expr ≤ »(«expr ∙ »(R, a), «expr ⊔ »(I, «expr ∙ »(R, a)))] [":=", expr le_sup_right],
      exact [expr this (mem_span_singleton_self a)] } }
end

theorem mem_supr {ι : Sort _} (p : ι → Submodule R M) {m : M} : (m ∈ ⨆i, p i) ↔ ∀ N, (∀ i, p i ≤ N) → m ∈ N :=
  by 
    rw [←span_singleton_le_iff_mem, le_supr_iff]
    simp only [span_singleton_le_iff_mem]

section 

open_locale Classical

/-- For every element in the span of a set, there exists a finite subset of the set
such that the element is contained in the span of the subset. -/
theorem mem_span_finite_of_mem_span {S : Set M} {x : M} (hx : x ∈ span R S) :
  ∃ T : Finset M, «expr↑ » T ⊆ S ∧ x ∈ span R (T : Set M) :=
  by 
    refine' span_induction hx (fun x hx => _) _ _ _
    ·
      refine' ⟨{x}, _, _⟩
      ·
        rwa [Finset.coe_singleton, Set.singleton_subset_iff]
      ·
        rw [Finset.coe_singleton]
        exact Submodule.mem_span_singleton_self x
    ·
      use ∅
      simp 
    ·
      rintro x y ⟨X, hX, hxX⟩ ⟨Y, hY, hyY⟩
      refine' ⟨X ∪ Y, _, _⟩
      ·
        rw [Finset.coe_union]
        exact Set.union_subset hX hY 
      rw [Finset.coe_union, span_union, mem_sup]
      exact ⟨x, hxX, y, hyY, rfl⟩
    ·
      rintro a x ⟨T, hT, h2⟩
      exact ⟨T, hT, smul_mem _ _ h2⟩

end 

/-- The product of two submodules is a submodule. -/
def Prod : Submodule R (M × M') :=
  { p.to_add_submonoid.prod q₁.to_add_submonoid with Carrier := Set.Prod p q₁,
    smul_mem' :=
      by 
        rintro a ⟨x, y⟩ ⟨hx, hy⟩ <;> exact ⟨smul_mem _ a hx, smul_mem _ a hy⟩ }

@[simp]
theorem prod_coe : (Prod p q₁ : Set (M × M')) = Set.Prod p q₁ :=
  rfl

@[simp]
theorem mem_prod {p : Submodule R M} {q : Submodule R M'} {x : M × M'} : x ∈ Prod p q ↔ x.1 ∈ p ∧ x.2 ∈ q :=
  Set.mem_prod

theorem span_prod_le (s : Set M) (t : Set M') : span R (Set.Prod s t) ≤ Prod (span R s) (span R t) :=
  span_le.2$ Set.prod_mono subset_span subset_span

@[simp]
theorem prod_top : (Prod ⊤ ⊤ : Submodule R (M × M')) = ⊤ :=
  by 
    ext <;> simp 

@[simp]
theorem prod_bot : (Prod ⊥ ⊥ : Submodule R (M × M')) = ⊥ :=
  by 
    ext ⟨x, y⟩ <;> simp [Prod.zero_eq_mk]

theorem prod_mono {p p' : Submodule R M} {q q' : Submodule R M'} : p ≤ p' → q ≤ q' → Prod p q ≤ Prod p' q' :=
  prod_mono

@[simp]
theorem prod_inf_prod : Prod p q₁⊓Prod p' q₁' = Prod (p⊓p') (q₁⊓q₁') :=
  SetLike.coe_injective Set.prod_inter_prod

@[simp]
theorem prod_sup_prod : Prod p q₁⊔Prod p' q₁' = Prod (p⊔p') (q₁⊔q₁') :=
  by 
    refine' le_antisymmₓ (sup_le (prod_mono le_sup_left le_sup_left) (prod_mono le_sup_right le_sup_right)) _ 
    simp [SetLike.le_def]
    intro xx yy hxx hyy 
    rcases mem_sup.1 hxx with ⟨x, hx, x', hx', rfl⟩
    rcases mem_sup.1 hyy with ⟨y, hy, y', hy', rfl⟩
    refine' mem_sup.2 ⟨(x, y), ⟨hx, hy⟩, (x', y'), ⟨hx', hy'⟩, rfl⟩

end AddCommMonoidₓ

variable[Ringₓ R][AddCommGroupₓ M][AddCommGroupₓ M₂][AddCommGroupₓ M₃]

variable[Module R M][Module R M₂][Module R M₃]

variable(p p' : Submodule R M)(q q' : Submodule R M₂)

variable{r : R}{x y : M}

open Set

@[simp]
theorem neg_coe : -(p : Set M) = p :=
  Set.ext$ fun x => p.neg_mem_iff

@[simp]
protected theorem map_neg (f : M →ₗ[R] M₂) : map (-f) p = map f p :=
  ext$
    fun y =>
      ⟨fun ⟨x, hx, hy⟩ => hy ▸ ⟨-x, neg_mem _ hx, f.map_neg x⟩,
        fun ⟨x, hx, hy⟩ => hy ▸ ⟨-x, neg_mem _ hx, ((-f).map_neg _).trans (neg_negₓ (f x))⟩⟩

@[simp]
theorem span_neg (s : Set M) : span R (-s) = span R s :=
  calc span R (-s) = span R ((-LinearMap.id : M →ₗ[R] M) '' s) :=
    by 
      simp 
    _ = map (-LinearMap.id) (span R s) := ((-LinearMap.id).map_span _).symm 
    _ = span R s :=
    by 
      simp 
    

theorem mem_span_insert' {y} {s : Set M} : x ∈ span R (insert y s) ↔ ∃ a : R, (x+a • y) ∈ span R s :=
  by 
    rw [mem_span_insert]
    split 
    ·
      rintro ⟨a, z, hz, rfl⟩
      exact
        ⟨-a,
          by 
            simp [hz, add_assocₓ]⟩
    ·
      rintro ⟨a, h⟩
      exact
        ⟨-a, _, h,
          by 
            simp [add_commₓ, add_left_commₓ]⟩

end Submodule

namespace Submodule

variable[Field K]

variable[AddCommGroupₓ V][Module K V]

variable[AddCommGroupₓ V₂][Module K V₂]

theorem comap_smul (f : V →ₗ[K] V₂) (p : Submodule K V₂) (a : K) (h : a ≠ 0) : p.comap (a • f) = p.comap f :=
  by 
    ext b <;> simp only [Submodule.mem_comap, p.smul_mem_iff h, LinearMap.smul_apply]

theorem map_smul (f : V →ₗ[K] V₂) (p : Submodule K V) (a : K) (h : a ≠ 0) : p.map (a • f) = p.map f :=
  le_antisymmₓ
    (by 
      rw [map_le_iff_le_comap, comap_smul f _ a h, ←map_le_iff_le_comap]
      exact le_reflₓ _)
    (by 
      rw [map_le_iff_le_comap, ←comap_smul f _ a h, ←map_le_iff_le_comap]
      exact le_reflₓ _)

theorem comap_smul' (f : V →ₗ[K] V₂) (p : Submodule K V₂) (a : K) : p.comap (a • f) = ⨅h : a ≠ 0, p.comap f :=
  by 
    classical <;> byCases' a = 0 <;> simp [h, comap_smul]

theorem map_smul' (f : V →ₗ[K] V₂) (p : Submodule K V) (a : K) : p.map (a • f) = ⨆h : a ≠ 0, p.map f :=
  by 
    classical <;> byCases' a = 0 <;> simp [h, map_smul]

end Submodule

/-! ### Properties of linear maps -/


namespace LinearMap

section AddCommMonoidₓ

variable[Semiringₓ R][Semiringₓ R₂][Semiringₓ R₃]

variable[AddCommMonoidₓ M][AddCommMonoidₓ M₂][AddCommMonoidₓ M₃]

variable{σ₁₂ : R →+* R₂}{σ₂₃ : R₂ →+* R₃}{σ₁₃ : R →+* R₃}

variable[RingHomCompTriple σ₁₂ σ₂₃ σ₁₃]

variable[Module R M][Module R₂ M₂][Module R₃ M₃]

include R

open Submodule

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If two linear maps are equal on a set `s`, then they are equal on `submodule.span s`.

See also `linear_map.eq_on_span'` for a version using `set.eq_on`. -/
theorem eq_on_span
{s : set M}
{f g : «expr →ₛₗ[ ] »(M, σ₁₂, M₂)}
(H : set.eq_on f g s)
{{x}}
(h : «expr ∈ »(x, span R s)) : «expr = »(f x, g x) :=
by apply [expr span_induction h H]; simp [] [] [] [] [] [] { contextual := tt }

/-- If two linear maps are equal on a set `s`, then they are equal on `submodule.span s`.

This version uses `set.eq_on`, and the hidden argument will expand to `h : x ∈ (span R s : set M)`.
See `linear_map.eq_on_span` for a version that takes `h : x ∈ span R s` as an argument. -/
theorem eq_on_span' {s : Set M} {f g : M →ₛₗ[σ₁₂] M₂} (H : Set.EqOn f g s) : Set.EqOn f g (span R s : Set M) :=
  eq_on_span H

/-- If `s` generates the whole module and linear maps `f`, `g` are equal on `s`, then they are
equal. -/
theorem ext_on {s : Set M} {f g : M →ₛₗ[σ₁₂] M₂} (hv : span R s = ⊤) (h : Set.EqOn f g s) : f = g :=
  LinearMap.ext fun x => eq_on_span h (eq_top_iff'.1 hv _)

/-- If the range of `v : ι → M` generates the whole module and linear maps `f`, `g` are equal at
each `v i`, then they are equal. -/
theorem ext_on_range {v : ι → M} {f g : M →ₛₗ[σ₁₂] M₂} (hv : span R (Set.Range v) = ⊤) (h : ∀ i, f (v i) = g (v i)) :
  f = g :=
  ext_on hv (Set.forall_range_iff.2 h)

section Finsupp

variable{γ : Type _}[HasZero γ]

@[simp]
theorem map_finsupp_sum (f : M →ₛₗ[σ₁₂] M₂) {t : ι →₀ γ} {g : ι → γ → M} : f (t.sum g) = t.sum fun i d => f (g i d) :=
  f.map_sum

theorem coe_finsupp_sum (t : ι →₀ γ) (g : ι → γ → M →ₛₗ[σ₁₂] M₂) : «expr⇑ » (t.sum g) = t.sum fun i d => g i d :=
  coe_fn_sum _ _

@[simp]
theorem finsupp_sum_apply (t : ι →₀ γ) (g : ι → γ → M →ₛₗ[σ₁₂] M₂) (b : M) : (t.sum g) b = t.sum fun i d => g i d b :=
  sum_apply _ _ _

end Finsupp

section Dfinsupp

open Dfinsupp

variable{γ : ι → Type _}[DecidableEq ι]

section Sum

variable[∀ i, HasZero (γ i)][∀ i (x : γ i), Decidable (x ≠ 0)]

@[simp]
theorem map_dfinsupp_sum (f : M →ₛₗ[σ₁₂] M₂) {t : Π₀i, γ i} {g : ∀ i, γ i → M} :
  f (t.sum g) = t.sum fun i d => f (g i d) :=
  f.map_sum

theorem coe_dfinsupp_sum (t : Π₀i, γ i) (g : ∀ i, γ i → M →ₛₗ[σ₁₂] M₂) : «expr⇑ » (t.sum g) = t.sum fun i d => g i d :=
  coe_fn_sum _ _

@[simp]
theorem dfinsupp_sum_apply (t : Π₀i, γ i) (g : ∀ i, γ i → M →ₛₗ[σ₁₂] M₂) (b : M) :
  (t.sum g) b = t.sum fun i d => g i d b :=
  sum_apply _ _ _

end Sum

section SumAddHom

variable[∀ i, AddZeroClass (γ i)]

@[simp]
theorem map_dfinsupp_sum_add_hom (f : M →ₛₗ[σ₁₂] M₂) {t : Π₀i, γ i} {g : ∀ i, γ i →+ M} :
  f (sum_add_hom g t) = sum_add_hom (fun i => f.to_add_monoid_hom.comp (g i)) t :=
  f.to_add_monoid_hom.map_dfinsupp_sum_add_hom _ _

end SumAddHom

end Dfinsupp

variable{σ₂₁ : R₂ →+* R}{τ₁₂ : R →+* R₂}{τ₂₃ : R₂ →+* R₃}{τ₁₃ : R →+* R₃}

variable[RingHomCompTriple τ₁₂ τ₂₃ τ₁₃]

theorem map_cod_restrict [RingHomSurjective σ₂₁] (p : Submodule R M) (f : M₂ →ₛₗ[σ₂₁] M) h p' :
  Submodule.map (cod_restrict p f h) p' = comap p.subtype (p'.map f) :=
  Submodule.ext$
    fun ⟨x, hx⟩ =>
      by 
        simp [Subtype.ext_iff_val]

theorem comap_cod_restrict (p : Submodule R M) (f : M₂ →ₛₗ[σ₂₁] M) hf p' :
  Submodule.comap (cod_restrict p f hf) p' = Submodule.comap f (map p.subtype p') :=
  Submodule.ext$
    fun x =>
      ⟨fun h => ⟨⟨_, hf x⟩, h, rfl⟩,
        by 
          rintro ⟨⟨_, _⟩, h, ⟨⟩⟩ <;> exact h⟩

section 

/-- The range of a linear map `f : M → M₂` is a submodule of `M₂`.
See Note [range copy pattern]. -/
def range [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) : Submodule R₂ M₂ :=
  (map f ⊤).copy (Set.Range f) Set.image_univ.symm

theorem range_coe [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) : (range f : Set M₂) = Set.Range f :=
  rfl

@[simp]
theorem mem_range [RingHomSurjective τ₁₂] {f : M →ₛₗ[τ₁₂] M₂} {x} : x ∈ range f ↔ ∃ y, f y = x :=
  Iff.rfl

theorem range_eq_map [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) : f.range = map f ⊤ :=
  by 
    ext 
    simp 

theorem mem_range_self [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) (x : M) : f x ∈ f.range :=
  ⟨x, rfl⟩

@[simp]
theorem range_id : range (LinearMap.id : M →ₗ[R] M) = ⊤ :=
  SetLike.coe_injective Set.range_id

theorem range_comp [RingHomSurjective τ₁₂] [RingHomSurjective τ₂₃] [RingHomSurjective τ₁₃] (f : M →ₛₗ[τ₁₂] M₂)
  (g : M₂ →ₛₗ[τ₂₃] M₃) : range (g.comp f : M →ₛₗ[τ₁₃] M₃) = map g (range f) :=
  SetLike.coe_injective (Set.range_comp g f)

theorem range_comp_le_range [RingHomSurjective τ₂₃] [RingHomSurjective τ₁₃] (f : M →ₛₗ[τ₁₂] M₂) (g : M₂ →ₛₗ[τ₂₃] M₃) :
  range (g.comp f : M →ₛₗ[τ₁₃] M₃) ≤ range g :=
  SetLike.coe_mono (Set.range_comp_subset_range f g)

theorem range_eq_top [RingHomSurjective τ₁₂] {f : M →ₛₗ[τ₁₂] M₂} : range f = ⊤ ↔ surjective f :=
  by 
    rw [SetLike.ext'_iff, range_coe, top_coe, Set.range_iff_surjective]

theorem range_le_iff_comap [RingHomSurjective τ₁₂] {f : M →ₛₗ[τ₁₂] M₂} {p : Submodule R₂ M₂} :
  range f ≤ p ↔ comap f p = ⊤ :=
  by 
    rw [range_eq_map, map_le_iff_le_comap, eq_top_iff]

theorem map_le_range [RingHomSurjective τ₁₂] {f : M →ₛₗ[τ₁₂] M₂} {p : Submodule R M} : map f p ≤ range f :=
  SetLike.coe_mono (Set.image_subset_range f p)

end 

/--
The decreasing sequence of submodules consisting of the ranges of the iterates of a linear map.
-/
@[simps]
def iterate_range (f : M →ₗ[R] M) : ℕ →ₘ OrderDual (Submodule R M) :=
  ⟨fun n => (f ^ n).range,
    fun n m w x h =>
      by 
        obtain ⟨c, rfl⟩ := le_iff_exists_add.mp w 
        rw [LinearMap.mem_range] at h 
        obtain ⟨m, rfl⟩ := h 
        rw [LinearMap.mem_range]
        use (f ^ c) m 
        rw [pow_addₓ, LinearMap.mul_apply]⟩

/-- Restrict the codomain of a linear map `f` to `f.range`.

This is the bundled version of `set.range_factorization`. -/
@[reducible]
def range_restrict [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) : M →ₛₗ[τ₁₂] f.range :=
  f.cod_restrict f.range f.mem_range_self

/-- The range of a linear map is finite if the domain is finite.
Note: this instance can form a diamond with `subtype.fintype` in the
  presence of `fintype M₂`. -/
instance fintype_range [Fintype M] [DecidableEq M₂] [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) : Fintype (range f) :=
  Set.fintypeRange f

section 

variable(R)(M)

/-- Given an element `x` of a module `M` over `R`, the natural map from
    `R` to scalar multiples of `x`.-/
@[simps]
def to_span_singleton (x : M) : R →ₗ[R] M :=
  LinearMap.id.smulRight x

/-- The range of `to_span_singleton x` is the span of `x`.-/
theorem span_singleton_eq_range (x : M) : (R∙x) = (to_span_singleton R M x).range :=
  Submodule.ext$
    fun y =>
      by 
        refine' Iff.trans _ mem_range.symm 
        exact mem_span_singleton

theorem to_span_singleton_one (x : M) : to_span_singleton R M x 1 = x :=
  one_smul _ _

end 

/-- The kernel of a linear map `f : M → M₂` is defined to be `comap f ⊥`. This is equivalent to the
set of `x : M` such that `f x = 0`. The kernel is a submodule of `M`. -/
def ker (f : M →ₛₗ[τ₁₂] M₂) : Submodule R M :=
  comap f ⊥

@[simp]
theorem mem_ker {f : M →ₛₗ[τ₁₂] M₂} {y} : y ∈ ker f ↔ f y = 0 :=
  mem_bot R₂

@[simp]
theorem ker_id : ker (LinearMap.id : M →ₗ[R] M) = ⊥ :=
  rfl

@[simp]
theorem map_coe_ker (f : M →ₛₗ[τ₁₂] M₂) (x : ker f) : f x = 0 :=
  mem_ker.1 x.2

theorem comp_ker_subtype (f : M →ₛₗ[τ₁₂] M₂) : f.comp f.ker.subtype = 0 :=
  LinearMap.ext$
    fun x =>
      suffices f x = 0 by 
        simp [this]
      mem_ker.1 x.2

theorem ker_comp (f : M →ₛₗ[τ₁₂] M₂) (g : M₂ →ₛₗ[τ₂₃] M₃) : ker (g.comp f : M →ₛₗ[τ₁₃] M₃) = comap f (ker g) :=
  rfl

theorem ker_le_ker_comp (f : M →ₛₗ[τ₁₂] M₂) (g : M₂ →ₛₗ[τ₂₃] M₃) : ker f ≤ ker (g.comp f : M →ₛₗ[τ₁₃] M₃) :=
  by 
    rw [ker_comp] <;> exact comap_mono bot_le

theorem disjoint_ker {f : M →ₛₗ[τ₁₂] M₂} {p : Submodule R M} : Disjoint p (ker f) ↔ ∀ x (_ : x ∈ p), f x = 0 → x = 0 :=
  by 
    simp [disjoint_def]

theorem ker_eq_bot' {f : M →ₛₗ[τ₁₂] M₂} : ker f = ⊥ ↔ ∀ m, f m = 0 → m = 0 :=
  by 
    simpa [Disjoint] using @disjoint_ker _ _ _ _ _ _ _ _ _ _ _ f ⊤

theorem ker_eq_bot_of_inverse {τ₂₁ : R₂ →+* R} [RingHomInvPair τ₁₂ τ₂₁] {f : M →ₛₗ[τ₁₂] M₂} {g : M₂ →ₛₗ[τ₂₁] M}
  (h : (g.comp f : M →ₗ[R] M) = id) : ker f = ⊥ :=
  ker_eq_bot'.2$
    fun m hm =>
      by 
        rw [←id_apply m, ←h, comp_apply, hm, g.map_zero]

theorem le_ker_iff_map [RingHomSurjective τ₁₂] {f : M →ₛₗ[τ₁₂] M₂} {p : Submodule R M} : p ≤ ker f ↔ map f p = ⊥ :=
  by 
    rw [ker, eq_bot_iff, map_le_iff_le_comap]

theorem ker_cod_restrict {τ₂₁ : R₂ →+* R} (p : Submodule R M) (f : M₂ →ₛₗ[τ₂₁] M) hf :
  ker (cod_restrict p f hf) = ker f :=
  by 
    rw [ker, comap_cod_restrict, map_bot] <;> rfl

theorem range_cod_restrict {τ₂₁ : R₂ →+* R} [RingHomSurjective τ₂₁] (p : Submodule R M) (f : M₂ →ₛₗ[τ₂₁] M) hf :
  range (cod_restrict p f hf) = comap p.subtype f.range :=
  by 
    simpa only [range_eq_map] using map_cod_restrict _ _ _ _

theorem ker_restrict {p : Submodule R M} {f : M →ₗ[R] M} (hf : ∀ (x : M), x ∈ p → f x ∈ p) :
  ker (f.restrict hf) = (f.dom_restrict p).ker :=
  by 
    rw [restrict_eq_cod_restrict_dom_restrict, ker_cod_restrict]

theorem _root_.submodule.map_comap_eq [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) (q : Submodule R₂ M₂) :
  map f (comap f q) = range f⊓q :=
  le_antisymmₓ (le_inf map_le_range (map_comap_le _ _))$
    by 
      rintro _ ⟨⟨x, _, rfl⟩, hx⟩ <;> exact ⟨x, hx, rfl⟩

theorem _root_.submodule.map_comap_eq_self [RingHomSurjective τ₁₂] {f : M →ₛₗ[τ₁₂] M₂} {q : Submodule R₂ M₂}
  (h : q ≤ range f) : map f (comap f q) = q :=
  by 
    rwa [Submodule.map_comap_eq, inf_eq_right]

@[simp]
theorem ker_zero : ker (0 : M →ₛₗ[τ₁₂] M₂) = ⊤ :=
  eq_top_iff'.2$
    fun x =>
      by 
        simp 

@[simp]
theorem range_zero [RingHomSurjective τ₁₂] : range (0 : M →ₛₗ[τ₁₂] M₂) = ⊥ :=
  by 
    simpa only [range_eq_map] using Submodule.map_zero _

theorem ker_eq_top {f : M →ₛₗ[τ₁₂] M₂} : ker f = ⊤ ↔ f = 0 :=
  ⟨fun h => ext$ fun x => mem_ker.1$ h.symm ▸ trivialₓ, fun h => h.symm ▸ ker_zero⟩

section 

variable[RingHomSurjective τ₁₂]

theorem range_le_bot_iff (f : M →ₛₗ[τ₁₂] M₂) : range f ≤ ⊥ ↔ f = 0 :=
  by 
    rw [range_le_iff_comap] <;> exact ker_eq_top

theorem range_eq_bot {f : M →ₛₗ[τ₁₂] M₂} : range f = ⊥ ↔ f = 0 :=
  by 
    rw [←range_le_bot_iff, le_bot_iff]

theorem range_le_ker_iff {f : M →ₛₗ[τ₁₂] M₂} {g : M₂ →ₛₗ[τ₂₃] M₃} : range f ≤ ker g ↔ (g.comp f : M →ₛₗ[τ₁₃] M₃) = 0 :=
  ⟨fun h => ker_eq_top.1$ eq_top_iff'.2$ fun x => h$ ⟨_, rfl⟩,
    fun h x hx =>
      mem_ker.2$
        Exists.elim hx$
          fun y hy =>
            by 
              rw [←hy, ←comp_apply, h, zero_apply]⟩

theorem comap_le_comap_iff {f : M →ₛₗ[τ₁₂] M₂} (hf : range f = ⊤) {p p'} : comap f p ≤ comap f p' ↔ p ≤ p' :=
  ⟨fun H x hx =>
      by 
        rcases range_eq_top.1 hf x with ⟨y, hy, rfl⟩ <;> exact H hx,
    comap_mono⟩

theorem comap_injective {f : M →ₛₗ[τ₁₂] M₂} (hf : range f = ⊤) : injective (comap f) :=
  fun p p' h => le_antisymmₓ ((comap_le_comap_iff hf).1 (le_of_eqₓ h)) ((comap_le_comap_iff hf).1 (ge_of_eq h))

end 

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem ker_eq_bot_of_injective {f : «expr →ₛₗ[ ] »(M, τ₁₂, M₂)} (hf : injective f) : «expr = »(ker f, «expr⊥»()) :=
begin
  have [] [":", expr disjoint «expr⊤»() f.ker] [],
  by { rw ["[", expr disjoint_ker, ",", "<-", expr map_zero f, "]"] [],
    exact [expr λ x hx H, hf H] },
  simpa [] [] [] ["[", expr disjoint, "]"] [] []
end

/--
The increasing sequence of submodules consisting of the kernels of the iterates of a linear map.
-/
@[simps]
def iterate_ker (f : M →ₗ[R] M) : ℕ →ₘ Submodule R M :=
  ⟨fun n => (f ^ n).ker,
    fun n m w x h =>
      by 
        obtain ⟨c, rfl⟩ := le_iff_exists_add.mp w 
        rw [LinearMap.mem_ker] at h 
        rw [LinearMap.mem_ker, add_commₓ, pow_addₓ, LinearMap.mul_apply, h, LinearMap.map_zero]⟩

end AddCommMonoidₓ

section AddCommGroupₓ

variable[Semiringₓ R][Semiringₓ R₂][Semiringₓ R₃]

variable[AddCommGroupₓ M][AddCommGroupₓ M₂][AddCommGroupₓ M₃]

variable[Module R M][Module R₂ M₂][Module R₃ M₃]

variable{τ₁₂ : R →+* R₂}{τ₂₃ : R₂ →+* R₃}{τ₁₃ : R →+* R₃}

variable[RingHomCompTriple τ₁₂ τ₂₃ τ₁₃][RingHomSurjective τ₁₂]

include R

open Submodule

theorem _root_.submodule.comap_map_eq (f : M →ₛₗ[τ₁₂] M₂) (p : Submodule R M) : comap f (map f p) = p⊔ker f :=
  by 
    refine' le_antisymmₓ _ (sup_le (le_comap_map _ _) (comap_mono bot_le))
    rintro x ⟨y, hy, e⟩
    exact
      mem_sup.2
        ⟨y, hy, x - y,
          by 
            simpa using sub_eq_zero.2 e.symm,
          by 
            simp ⟩

theorem _root_.submodule.comap_map_eq_self {f : M →ₛₗ[τ₁₂] M₂} {p : Submodule R M} (h : ker f ≤ p) :
  comap f (map f p) = p :=
  by 
    rw [Submodule.comap_map_eq, sup_of_le_left h]

theorem map_le_map_iff (f : M →ₛₗ[τ₁₂] M₂) {p p'} : map f p ≤ map f p' ↔ p ≤ p'⊔ker f :=
  by 
    rw [map_le_iff_le_comap, Submodule.comap_map_eq]

theorem map_le_map_iff' {f : M →ₛₗ[τ₁₂] M₂} (hf : ker f = ⊥) {p p'} : map f p ≤ map f p' ↔ p ≤ p' :=
  by 
    rw [map_le_map_iff, hf, sup_bot_eq]

theorem map_injective {f : M →ₛₗ[τ₁₂] M₂} (hf : ker f = ⊥) : injective (map f) :=
  fun p p' h => le_antisymmₓ ((map_le_map_iff' hf).1 (le_of_eqₓ h)) ((map_le_map_iff' hf).1 (ge_of_eq h))

theorem map_eq_top_iff {f : M →ₛₗ[τ₁₂] M₂} (hf : range f = ⊤) {p : Submodule R M} : p.map f = ⊤ ↔ p⊔f.ker = ⊤ :=
  by 
    simpRw [←top_le_iff, ←hf, range_eq_map, map_le_map_iff]

end AddCommGroupₓ

section Ringₓ

variable[Ringₓ R][Ringₓ R₂][Ringₓ R₃]

variable[AddCommGroupₓ M][AddCommGroupₓ M₂][AddCommGroupₓ M₃]

variable[Module R M][Module R₂ M₂][Module R₃ M₃]

variable{τ₁₂ : R →+* R₂}{τ₂₃ : R₂ →+* R₃}{τ₁₃ : R →+* R₃}

variable[RingHomCompTriple τ₁₂ τ₂₃ τ₁₃]

variable{f : M →ₛₗ[τ₁₂] M₂}

include R

open Submodule

theorem sub_mem_ker_iff {x y} : x - y ∈ f.ker ↔ f x = f y :=
  by 
    rw [mem_ker, map_sub, sub_eq_zero]

theorem disjoint_ker' {p : Submodule R M} : Disjoint p (ker f) ↔ ∀ x y (_ : x ∈ p) (_ : y ∈ p), f x = f y → x = y :=
  disjoint_ker.trans
    ⟨fun H x y hx hy h =>
        eq_of_sub_eq_zero$
          H _ (sub_mem _ hx hy)
            (by 
              simp [h]),
      fun H x h₁ h₂ =>
        H x 0 h₁ (zero_mem _)
          (by 
            simpa using h₂)⟩

theorem inj_of_disjoint_ker {p : Submodule R M} {s : Set M} (h : s ⊆ p) (hd : Disjoint p (ker f)) :
  ∀ x y (_ : x ∈ s) (_ : y ∈ s), f x = f y → x = y :=
  fun x y hx hy => disjoint_ker'.1 hd _ _ (h hx) (h hy)

theorem ker_eq_bot : ker f = ⊥ ↔ injective f :=
  by 
    simpa [Disjoint] using @disjoint_ker' _ _ _ _ _ _ _ _ _ _ _ f ⊤

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem ker_le_iff
[ring_hom_surjective τ₁₂]
{p : submodule R M} : «expr ↔ »(«expr ≤ »(ker f, p), «expr∃ , »((y «expr ∈ » range f), «expr ⊆ »(«expr ⁻¹' »(f, {y}), p))) :=
begin
  split,
  { intros [ident h],
    use [expr 0],
    rw ["[", "<-", expr set_like.mem_coe, ",", expr f.range_coe, "]"] [],
    exact [expr ⟨⟨0, map_zero f⟩, h⟩] },
  { rintros ["⟨", ident y, ",", ident h₁, ",", ident h₂, "⟩"],
    rw [expr set_like.le_def] [],
    intros [ident z, ident hz],
    simp [] [] ["only"] ["[", expr mem_ker, ",", expr set_like.mem_coe, "]"] [] ["at", ident hz],
    rw ["[", "<-", expr set_like.mem_coe, ",", expr f.range_coe, ",", expr set.mem_range, "]"] ["at", ident h₁],
    obtain ["⟨", ident x, ",", ident hx, "⟩", ":=", expr h₁],
    have [ident hx'] [":", expr «expr ∈ »(x, p)] [],
    { exact [expr h₂ hx] },
    have [ident hxz] [":", expr «expr ∈ »(«expr + »(z, x), p)] [],
    { apply [expr h₂],
      simp [] [] [] ["[", expr hx, ",", expr hz, "]"] [] [] },
    suffices [] [":", expr «expr ∈ »(«expr - »(«expr + »(z, x), x), p)],
    { simpa [] [] ["only"] ["[", expr this, ",", expr add_sub_cancel, "]"] [] [] },
    exact [expr p.sub_mem hxz hx'] }
end

end Ringₓ

section Field

variable[Field K][Field K₂]

variable[AddCommGroupₓ V][Module K V]

variable[AddCommGroupₓ V₂][Module K V₂]

theorem ker_smul (f : V →ₗ[K] V₂) (a : K) (h : a ≠ 0) : ker (a • f) = ker f :=
  Submodule.comap_smul f _ a h

theorem ker_smul' (f : V →ₗ[K] V₂) (a : K) : ker (a • f) = ⨅h : a ≠ 0, ker f :=
  Submodule.comap_smul' f _ a

theorem range_smul (f : V →ₗ[K] V₂) (a : K) (h : a ≠ 0) : range (a • f) = range f :=
  by 
    simpa only [range_eq_map] using Submodule.map_smul f _ a h

theorem range_smul' (f : V →ₗ[K] V₂) (a : K) : range (a • f) = ⨆h : a ≠ 0, range f :=
  by 
    simpa only [range_eq_map] using Submodule.map_smul' f _ a

theorem span_singleton_sup_ker_eq_top (f : V →ₗ[K] K) {x : V} (hx : f x ≠ 0) : (K∙x)⊔f.ker = ⊤ :=
  eq_top_iff.2
    fun y hy =>
      Submodule.mem_sup.2
        ⟨(f y*f x⁻¹) • x, Submodule.mem_span_singleton.2 ⟨f y*f x⁻¹, rfl⟩,
          ⟨y - (f y*f x⁻¹) • x,
            by 
              rw [LinearMap.mem_ker, f.map_sub, f.map_smul, smul_eq_mul, mul_assocₓ, inv_mul_cancel hx, mul_oneₓ,
                sub_self],
            by 
              simp only [add_sub_cancel'_right]⟩⟩

end Field

end LinearMap

namespace IsLinearMap

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem is_linear_map_add
[semiring R]
[add_comm_monoid M]
[module R M] : is_linear_map R (λ x : «expr × »(M, M), «expr + »(x.1, x.2)) :=
begin
  apply [expr is_linear_map.mk],
  { intros [ident x, ident y],
    simp [] [] [] [] [] [],
    cc },
  { intros [ident x, ident y],
    simp [] [] [] ["[", expr smul_add, "]"] [] [] }
end

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem is_linear_map_sub
{R M : Type*}
[semiring R]
[add_comm_group M]
[module R M] : is_linear_map R (λ x : «expr × »(M, M), «expr - »(x.1, x.2)) :=
begin
  apply [expr is_linear_map.mk],
  { intros [ident x, ident y],
    simp [] [] [] ["[", expr add_comm, ",", expr add_left_comm, ",", expr sub_eq_add_neg, "]"] [] [] },
  { intros [ident x, ident y],
    simp [] [] [] ["[", expr smul_sub, "]"] [] [] }
end

end IsLinearMap

namespace Submodule

section AddCommMonoidₓ

variable[Semiringₓ R][Semiringₓ R₂][AddCommMonoidₓ M][AddCommMonoidₓ M₂]

variable[Module R M][Module R₂ M₂]

variable(p p' : Submodule R M)(q : Submodule R₂ M₂)

variable{τ₁₂ : R →+* R₂}

open LinearMap

@[simp]
theorem map_top [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) : map f ⊤ = range f :=
  f.range_eq_map.symm

@[simp]
theorem comap_bot (f : M →ₛₗ[τ₁₂] M₂) : comap f ⊥ = ker f :=
  rfl

@[simp]
theorem ker_subtype : p.subtype.ker = ⊥ :=
  ker_eq_bot_of_injective$ fun x y => Subtype.ext_val

@[simp]
theorem range_subtype : p.subtype.range = p :=
  by 
    simpa using map_comap_subtype p ⊤

theorem map_subtype_le (p' : Submodule R p) : map p.subtype p' ≤ p :=
  by 
    simpa using (map_le_range : map p.subtype p' ≤ p.subtype.range)

/-- Under the canonical linear map from a submodule `p` to the ambient space `M`, the image of the
maximal submodule of `p` is just `p `. -/
@[simp]
theorem map_subtype_top : map p.subtype (⊤ : Submodule R p) = p :=
  by 
    simp 

@[simp]
theorem comap_subtype_eq_top {p p' : Submodule R M} : comap p.subtype p' = ⊤ ↔ p ≤ p' :=
  eq_top_iff.trans$
    map_le_iff_le_comap.symm.trans$
      by 
        rw [map_subtype_top]

@[simp]
theorem comap_subtype_self : comap p.subtype p = ⊤ :=
  comap_subtype_eq_top.2 (le_reflₓ _)

@[simp]
theorem ker_of_le (p p' : Submodule R M) (h : p ≤ p') : (of_le h).ker = ⊥ :=
  by 
    rw [of_le, ker_cod_restrict, ker_subtype]

theorem range_of_le (p q : Submodule R M) (h : p ≤ q) : (of_le h).range = comap q.subtype p :=
  by 
    rw [←map_top, of_le, LinearMap.map_cod_restrict, map_top, range_subtype]

theorem disjoint_iff_comap_eq_bot {p q : Submodule R M} : Disjoint p q ↔ comap p.subtype q = ⊥ :=
  by 
    rw [←(map_injective_of_injective (show injective p.subtype from Subtype.coe_injective)).eq_iff, map_comap_subtype,
      map_bot, disjoint_iff]

/-- If `N ⊆ M` then submodules of `N` are the same as submodules of `M` contained in `N` -/
def map_subtype.rel_iso : Submodule R p ≃o { p' : Submodule R M // p' ≤ p } :=
  { toFun := fun p' => ⟨map p.subtype p', map_subtype_le p _⟩, invFun := fun q => comap p.subtype q,
    left_inv := fun p' => comap_map_eq_of_injective Subtype.coe_injective p',
    right_inv :=
      fun ⟨q, hq⟩ =>
        Subtype.ext_val$
          by 
            simp [map_comap_subtype p, inf_of_le_right hq],
    map_rel_iff' :=
      fun p₁ p₂ =>
        Subtype.coe_le_coe.symm.trans
          (by 
            dsimp 
            rw [map_le_iff_le_comap,
              comap_map_eq_of_injective (show injective p.subtype from Subtype.coe_injective) p₂]) }

/-- If `p ⊆ M` is a submodule, the ordering of submodules of `p` is embedded in the ordering of
submodules of `M`. -/
def map_subtype.order_embedding : Submodule R p ↪o Submodule R M :=
  (RelIso.toRelEmbedding$ map_subtype.rel_iso p).trans (Subtype.relEmbedding _ _)

@[simp]
theorem map_subtype_embedding_eq (p' : Submodule R p) : map_subtype.order_embedding p p' = map p.subtype p' :=
  rfl

end AddCommMonoidₓ

end Submodule

namespace LinearMap

section Semiringₓ

variable[Semiringₓ R][Semiringₓ R₂][Semiringₓ R₃]

variable[AddCommMonoidₓ M][AddCommMonoidₓ M₂][AddCommMonoidₓ M₃]

variable[Module R M][Module R₂ M₂][Module R₃ M₃]

variable{τ₁₂ : R →+* R₂}{τ₂₃ : R₂ →+* R₃}{τ₁₃ : R →+* R₃}

variable[RingHomCompTriple τ₁₂ τ₂₃ τ₁₃]

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- A monomorphism is injective. -/
theorem ker_eq_bot_of_cancel
{f : «expr →ₛₗ[ ] »(M, τ₁₂, M₂)}
(h : ∀
 u v : «expr →ₗ[ ] »(f.ker, R, M), «expr = »(f.comp u, f.comp v) → «expr = »(u, v)) : «expr = »(f.ker, «expr⊥»()) :=
begin
  have [ident h₁] [":", expr «expr = »(f.comp (0 : «expr →ₗ[ ] »(f.ker, R, M)), 0)] [":=", expr comp_zero _],
  rw ["[", "<-", expr submodule.range_subtype f.ker, ",", "<-", expr h 0 f.ker.subtype (eq.trans h₁ (comp_ker_subtype f).symm), "]"] [],
  exact [expr range_zero]
end

theorem range_comp_of_range_eq_top [RingHomSurjective τ₁₂] [RingHomSurjective τ₂₃] [RingHomSurjective τ₁₃]
  {f : M →ₛₗ[τ₁₂] M₂} (g : M₂ →ₛₗ[τ₂₃] M₃) (hf : range f = ⊤) : range (g.comp f : M →ₛₗ[τ₁₃] M₃) = range g :=
  by 
    rw [range_comp, hf, Submodule.map_top]

theorem ker_comp_of_ker_eq_bot (f : M →ₛₗ[τ₁₂] M₂) {g : M₂ →ₛₗ[τ₂₃] M₃} (hg : ker g = ⊥) :
  ker (g.comp f : M →ₛₗ[τ₁₃] M₃) = ker f :=
  by 
    rw [ker_comp, hg, Submodule.comap_bot]

section Image

/-- If `O` is a submodule of `M`, and `Φ : O →ₗ M'` is a linear map,
then `(ϕ : O →ₗ M').submodule_image N` is `ϕ(N)` as a submodule of `M'` -/
def submodule_image {M' : Type _} [AddCommMonoidₓ M'] [Module R M'] {O : Submodule R M} (ϕ : O →ₗ[R] M')
  (N : Submodule R M) : Submodule R M' :=
  (N.comap O.subtype).map ϕ

@[simp]
theorem mem_submodule_image {M' : Type _} [AddCommMonoidₓ M'] [Module R M'] {O : Submodule R M} {ϕ : O →ₗ[R] M'}
  {N : Submodule R M} {x : M'} : x ∈ ϕ.submodule_image N ↔ ∃ (y : _)(yO : y ∈ O)(yN : y ∈ N), ϕ ⟨y, yO⟩ = x :=
  by 
    refine' submodule.mem_map.trans ⟨_, _⟩ <;> simpRw [Submodule.mem_comap]
    ·
      rintro ⟨⟨y, yO⟩, yN : y ∈ N, h⟩
      exact ⟨y, yO, yN, h⟩
    ·
      rintro ⟨y, yO, yN, h⟩
      exact ⟨⟨y, yO⟩, yN, h⟩

theorem mem_submodule_image_of_le {M' : Type _} [AddCommMonoidₓ M'] [Module R M'] {O : Submodule R M} {ϕ : O →ₗ[R] M'}
  {N : Submodule R M} (hNO : N ≤ O) {x : M'} : x ∈ ϕ.submodule_image N ↔ ∃ (y : _)(yN : y ∈ N), ϕ ⟨y, hNO yN⟩ = x :=
  by 
    refine' mem_submodule_image.trans ⟨_, _⟩
    ·
      rintro ⟨y, yO, yN, h⟩
      exact ⟨y, yN, h⟩
    ·
      rintro ⟨y, yN, h⟩
      exact ⟨y, hNO yN, yN, h⟩

theorem submodule_image_apply_of_le {M' : Type _} [AddCommGroupₓ M'] [Module R M'] {O : Submodule R M} (ϕ : O →ₗ[R] M')
  (N : Submodule R M) (hNO : N ≤ O) : ϕ.submodule_image N = (ϕ.comp (Submodule.ofLe hNO)).range :=
  by 
    rw [submodule_image, range_comp, Submodule.range_of_le]

end Image

end Semiringₓ

end LinearMap

@[simp]
theorem LinearMap.range_range_restrict [Semiringₓ R] [AddCommMonoidₓ M] [AddCommMonoidₓ M₂] [Module R M] [Module R M₂]
  (f : M →ₗ[R] M₂) : f.range_restrict.range = ⊤ :=
  by 
    simp [f.range_cod_restrict _]

/-! ### Linear equivalences -/


namespace LinearEquiv

section AddCommMonoidₓ

section Subsingleton

variable[Semiringₓ R][Semiringₓ R₂][Semiringₓ R₃][Semiringₓ R₄]

variable[AddCommMonoidₓ M][AddCommMonoidₓ M₂][AddCommMonoidₓ M₃][AddCommMonoidₓ M₄]

variable[Module R M][Module R₂ M₂]

variable[Subsingleton M][Subsingleton M₂]

variable{σ₁₂ : R →+* R₂}{σ₂₁ : R₂ →+* R}

variable[RingHomInvPair σ₁₂ σ₂₁][RingHomInvPair σ₂₁ σ₁₂]

include σ₂₁

/-- Between two zero modules, the zero map is an equivalence. -/
instance  : HasZero (M ≃ₛₗ[σ₁₂] M₂) :=
  ⟨{ (0 : M →ₛₗ[σ₁₂] M₂) with toFun := 0, invFun := 0, right_inv := fun x => Subsingleton.elimₓ _ _,
      left_inv := fun x => Subsingleton.elimₓ _ _ }⟩

omit σ₂₁

include σ₂₁

@[simp]
theorem zero_symm : (0 : M ≃ₛₗ[σ₁₂] M₂).symm = 0 :=
  rfl

@[simp]
theorem coe_zero : «expr⇑ » (0 : M ≃ₛₗ[σ₁₂] M₂) = 0 :=
  rfl

theorem zero_apply (x : M) : (0 : M ≃ₛₗ[σ₁₂] M₂) x = 0 :=
  rfl

/-- Between two zero modules, the zero map is the only equivalence. -/
instance  : Unique (M ≃ₛₗ[σ₁₂] M₂) :=
  { uniq := fun f => to_linear_map_injective (Subsingleton.elimₓ _ _), default := 0 }

omit σ₂₁

end Subsingleton

section 

variable[Semiringₓ R][Semiringₓ R₂][Semiringₓ R₃][Semiringₓ R₄]

variable[AddCommMonoidₓ M][AddCommMonoidₓ M₂][AddCommMonoidₓ M₃][AddCommMonoidₓ M₄]

variable{module_M : Module R M}{module_M₂ : Module R₂ M₂}

variable{σ₁₂ : R →+* R₂}{σ₂₁ : R₂ →+* R}

variable{re₁₂ : RingHomInvPair σ₁₂ σ₂₁}{re₂₁ : RingHomInvPair σ₂₁ σ₁₂}

variable(e e' : M ≃ₛₗ[σ₁₂] M₂)

theorem map_eq_comap {p : Submodule R M} :
  (p.map (e : M →ₛₗ[σ₁₂] M₂) : Submodule R₂ M₂) = p.comap (e.symm : M₂ →ₛₗ[σ₂₁] M) :=
  SetLike.coe_injective$
    by 
      simp [e.image_eq_preimage]

/-- A linear equivalence of two modules restricts to a linear equivalence from any submodule
`p` of the domain onto the image of that submodule.

This is `linear_equiv.of_submodule'` but with `map` on the right instead of `comap` on the left. -/
def of_submodule (p : Submodule R M) : p ≃ₛₗ[σ₁₂] «expr↥ » (p.map (e : M →ₛₗ[σ₁₂] M₂) : Submodule R₂ M₂) :=
  { ((e : M →ₛₗ[σ₁₂] M₂).domRestrict p).codRestrict (p.map (e : M →ₛₗ[σ₁₂] M₂))
      fun x =>
        ⟨x,
          by 
            simp ⟩ with
    invFun :=
      fun y =>
        ⟨(e.symm : M₂ →ₛₗ[σ₂₁] M) y,
          by 
            rcases y with ⟨y', hy⟩
            rw [Submodule.mem_map] at hy 
            rcases hy with ⟨x, hx, hxy⟩
            subst hxy 
            simp only [symm_apply_apply, Submodule.coe_mk, coe_coe, hx]⟩,
    left_inv :=
      fun x =>
        by 
          simp ,
    right_inv :=
      fun y =>
        by 
          apply SetCoe.ext 
          simp  }

include σ₂₁

@[simp]
theorem of_submodule_apply (p : Submodule R M) (x : p) : «expr↑ » (e.of_submodule p x) = e x :=
  rfl

@[simp]
theorem of_submodule_symm_apply (p : Submodule R M) (x : (p.map (e : M →ₛₗ[σ₁₂] M₂) : Submodule R₂ M₂)) :
  «expr↑ » ((e.of_submodule p).symm x) = e.symm x :=
  rfl

omit σ₂₁

end 

section Finsupp

variable{γ : Type _}

variable[Semiringₓ R][Semiringₓ R₂]

variable[AddCommMonoidₓ M][AddCommMonoidₓ M₂]

variable[Module R M][Module R₂ M₂][HasZero γ]

variable{τ₁₂ : R →+* R₂}{τ₂₁ : R₂ →+* R}

variable[RingHomInvPair τ₁₂ τ₂₁][RingHomInvPair τ₂₁ τ₁₂]

include τ₂₁

@[simp]
theorem map_finsupp_sum (f : M ≃ₛₗ[τ₁₂] M₂) {t : ι →₀ γ} {g : ι → γ → M} : f (t.sum g) = t.sum fun i d => f (g i d) :=
  f.map_sum _

omit τ₂₁

end Finsupp

section Dfinsupp

open Dfinsupp

variable[Semiringₓ R][Semiringₓ R₂]

variable[AddCommMonoidₓ M][AddCommMonoidₓ M₂]

variable[Module R M][Module R₂ M₂]

variable{τ₁₂ : R →+* R₂}{τ₂₁ : R₂ →+* R}

variable[RingHomInvPair τ₁₂ τ₂₁][RingHomInvPair τ₂₁ τ₁₂]

variable{γ : ι → Type _}[DecidableEq ι]

include τ₂₁

@[simp]
theorem map_dfinsupp_sum [∀ i, HasZero (γ i)] [∀ i (x : γ i), Decidable (x ≠ 0)] (f : M ≃ₛₗ[τ₁₂] M₂) (t : Π₀i, γ i)
  (g : ∀ i, γ i → M) : f (t.sum g) = t.sum fun i d => f (g i d) :=
  f.map_sum _

@[simp]
theorem map_dfinsupp_sum_add_hom [∀ i, AddZeroClass (γ i)] (f : M ≃ₛₗ[τ₁₂] M₂) (t : Π₀i, γ i) (g : ∀ i, γ i →+ M) :
  f (sum_add_hom g t) = sum_add_hom (fun i => f.to_add_equiv.to_add_monoid_hom.comp (g i)) t :=
  f.to_add_equiv.map_dfinsupp_sum_add_hom _ _

end Dfinsupp

section Uncurry

variable[Semiringₓ R][Semiringₓ R₂][Semiringₓ R₃][Semiringₓ R₄]

variable[AddCommMonoidₓ M][AddCommMonoidₓ M₂][AddCommMonoidₓ M₃][AddCommMonoidₓ M₄]

variable(V V₂ R)

/-- Linear equivalence between a curried and uncurried function.
  Differs from `tensor_product.curry`. -/
protected def curry : (V × V₂ → R) ≃ₗ[R] V → V₂ → R :=
  { Equiv.curry _ _ _ with
    map_add' :=
      fun _ _ =>
        by 
          ext 
          rfl,
    map_smul' :=
      fun _ _ =>
        by 
          ext 
          rfl }

@[simp]
theorem coe_curry : «expr⇑ » (LinearEquiv.curry R V V₂) = curry :=
  rfl

@[simp]
theorem coe_curry_symm : «expr⇑ » (LinearEquiv.curry R V V₂).symm = uncurry :=
  rfl

end Uncurry

section 

variable[Semiringₓ R][Semiringₓ R₂][Semiringₓ R₃][Semiringₓ R₄]

variable[AddCommMonoidₓ M][AddCommMonoidₓ M₂][AddCommMonoidₓ M₃][AddCommMonoidₓ M₄]

variable{module_M : Module R M}{module_M₂ : Module R₂ M₂}{module_M₃ : Module R₃ M₃}

variable{σ₁₂ : R →+* R₂}{σ₂₁ : R₂ →+* R}

variable{σ₂₃ : R₂ →+* R₃}{σ₁₃ : R →+* R₃}[RingHomCompTriple σ₁₂ σ₂₃ σ₁₃]

variable{σ₃₂ : R₃ →+* R₂}

variable{re₁₂ : RingHomInvPair σ₁₂ σ₂₁}{re₂₁ : RingHomInvPair σ₂₁ σ₁₂}

variable{re₂₃ : RingHomInvPair σ₂₃ σ₃₂}{re₃₂ : RingHomInvPair σ₃₂ σ₂₃}

variable(f : M →ₛₗ[σ₁₂] M₂)(g : M₂ →ₛₗ[σ₂₁] M)(e : M ≃ₛₗ[σ₁₂] M₂)(h : M₂ →ₛₗ[σ₂₃] M₃)

variable(e'' : M₂ ≃ₛₗ[σ₂₃] M₃)

variable(p q : Submodule R M)

/-- Linear equivalence between two equal submodules. -/
def of_eq (h : p = q) : p ≃ₗ[R] q :=
  { Equiv.Set.ofEq (congr_argₓ _ h) with map_smul' := fun _ _ => rfl, map_add' := fun _ _ => rfl }

variable{p q}

@[simp]
theorem coe_of_eq_apply (h : p = q) (x : p) : (of_eq p q h x : M) = x :=
  rfl

@[simp]
theorem of_eq_symm (h : p = q) : (of_eq p q h).symm = of_eq q p h.symm :=
  rfl

include σ₂₁

/-- A linear equivalence which maps a submodule of one module onto another, restricts to a linear
equivalence of the two submodules. -/
def of_submodules (p : Submodule R M) (q : Submodule R₂ M₂) (h : p.map (e : M →ₛₗ[σ₁₂] M₂) = q) : p ≃ₛₗ[σ₁₂] q :=
  (e.of_submodule p).trans (LinearEquiv.ofEq _ _ h)

@[simp]
theorem of_submodules_apply {p : Submodule R M} {q : Submodule R₂ M₂} (h : p.map («expr↑ » e) = q) (x : p) :
  «expr↑ » (e.of_submodules p q h x) = e x :=
  rfl

@[simp]
theorem of_submodules_symm_apply {p : Submodule R M} {q : Submodule R₂ M₂} (h : p.map («expr↑ » e) = q) (x : q) :
  «expr↑ » ((e.of_submodules p q h).symm x) = e.symm x :=
  rfl

include re₁₂ re₂₁

/-- A linear equivalence of two modules restricts to a linear equivalence from the preimage of any
submodule to that submodule.

This is `linear_equiv.of_submodule` but with `comap` on the left instead of `map` on the right. -/
def of_submodule' [Module R M] [Module R₂ M₂] (f : M ≃ₛₗ[σ₁₂] M₂) (U : Submodule R₂ M₂) :
  U.comap (f : M →ₛₗ[σ₁₂] M₂) ≃ₛₗ[σ₁₂] U :=
  (f.symm.of_submodules _ _ f.symm.map_eq_comap).symm

theorem of_submodule'_to_linear_map [Module R M] [Module R₂ M₂] (f : M ≃ₛₗ[σ₁₂] M₂) (U : Submodule R₂ M₂) :
  (f.of_submodule' U).toLinearMap = (f.to_linear_map.dom_restrict _).codRestrict _ Subtype.prop :=
  by 
    ext 
    rfl

@[simp]
theorem of_submodule'_apply [Module R M] [Module R₂ M₂] (f : M ≃ₛₗ[σ₁₂] M₂) (U : Submodule R₂ M₂)
  (x : U.comap (f : M →ₛₗ[σ₁₂] M₂)) : (f.of_submodule' U x : M₂) = f (x : M) :=
  rfl

@[simp]
theorem of_submodule'_symm_apply [Module R M] [Module R₂ M₂] (f : M ≃ₛₗ[σ₁₂] M₂) (U : Submodule R₂ M₂) (x : U) :
  ((f.of_submodule' U).symm x : M) = f.symm (x : M₂) :=
  rfl

variable(p)

omit σ₂₁ re₁₂ re₂₁

/-- The top submodule of `M` is linearly equivalent to `M`. -/
def of_top (h : p = ⊤) : p ≃ₗ[R] M :=
  { p.subtype with invFun := fun x => ⟨x, h.symm ▸ trivialₓ⟩, left_inv := fun ⟨x, h⟩ => rfl, right_inv := fun x => rfl }

@[simp]
theorem of_top_apply {h} (x : p) : of_top p h x = x :=
  rfl

@[simp]
theorem coe_of_top_symm_apply {h} (x : M) : ((of_top p h).symm x : M) = x :=
  rfl

theorem of_top_symm_apply {h} (x : M) : (of_top p h).symm x = ⟨x, h.symm ▸ trivialₓ⟩ :=
  rfl

include σ₂₁ re₁₂ re₂₁

/-- If a linear map has an inverse, it is a linear equivalence. -/
def of_linear (h₁ : f.comp g = LinearMap.id) (h₂ : g.comp f = LinearMap.id) : M ≃ₛₗ[σ₁₂] M₂ :=
  { f with invFun := g, left_inv := LinearMap.ext_iff.1 h₂, right_inv := LinearMap.ext_iff.1 h₁ }

omit σ₂₁ re₁₂ re₂₁

include σ₂₁ re₁₂ re₂₁

@[simp]
theorem of_linear_apply {h₁ h₂} (x : M) : of_linear f g h₁ h₂ x = f x :=
  rfl

omit σ₂₁ re₁₂ re₂₁

include σ₂₁ re₁₂ re₂₁

@[simp]
theorem of_linear_symm_apply {h₁ h₂} (x : M₂) : (of_linear f g h₁ h₂).symm x = g x :=
  rfl

omit σ₂₁ re₁₂ re₂₁

@[simp]
protected theorem range : (e : M →ₛₗ[σ₁₂] M₂).range = ⊤ :=
  LinearMap.range_eq_top.2 e.to_equiv.surjective

include σ₂₁ re₁₂ re₂₁

theorem eq_bot_of_equiv [Module R₂ M₂] (e : p ≃ₛₗ[σ₁₂] (⊥ : Submodule R₂ M₂)) : p = ⊥ :=
  by 
    refine' bot_unique (SetLike.le_def.2$ fun b hb => (Submodule.mem_bot R).2 _)
    rw [←p.mk_eq_zero hb, ←e.map_eq_zero_iff]
    apply Submodule.eq_zero_of_bot_submodule

omit σ₂₁ re₁₂ re₂₁

@[simp]
protected theorem ker : (e : M →ₛₗ[σ₁₂] M₂).ker = ⊥ :=
  LinearMap.ker_eq_bot_of_injective e.to_equiv.injective

@[simp]
theorem range_comp [RingHomSurjective σ₁₂] [RingHomSurjective σ₂₃] [RingHomSurjective σ₁₃] :
  (h.comp (e : M →ₛₗ[σ₁₂] M₂) : M →ₛₗ[σ₁₃] M₃).range = h.range :=
  LinearMap.range_comp_of_range_eq_top _ e.range

include module_M

@[simp]
theorem ker_comp (l : M →ₛₗ[σ₁₂] M₂) : (((e'' : M₂ →ₛₗ[σ₂₃] M₃).comp l : M →ₛₗ[σ₁₃] M₃) : M →ₛₗ[σ₁₃] M₃).ker = l.ker :=
  LinearMap.ker_comp_of_ker_eq_bot _ e''.ker

omit module_M

variable{f g}

include σ₂₁

/-- An linear map `f : M →ₗ[R] M₂` with a left-inverse `g : M₂ →ₗ[R] M` defines a linear
equivalence between `M` and `f.range`.

This is a computable alternative to `linear_equiv.of_injective`, and a bidirectional version of
`linear_map.range_restrict`. -/
def of_left_inverse [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂] {g : M₂ → M} (h : Function.LeftInverse g f) :
  M ≃ₛₗ[σ₁₂] f.range :=
  { f.range_restrict with toFun := f.range_restrict, invFun := g ∘ f.range.subtype, left_inv := h,
    right_inv :=
      fun x =>
        Subtype.ext$
          let ⟨x', hx'⟩ := LinearMap.mem_range.mp x.prop 
          show f (g x) = x by 
            rw [←hx', h x'] }

omit σ₂₁

@[simp]
theorem of_left_inverse_apply [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂] (h : Function.LeftInverse g f) (x : M) :
  «expr↑ » (of_left_inverse h x) = f x :=
  rfl

include σ₂₁

@[simp]
theorem of_left_inverse_symm_apply [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂] (h : Function.LeftInverse g f)
  (x : f.range) : (of_left_inverse h).symm x = g x :=
  rfl

omit σ₂₁

variable(f)

/-- An `injective` linear map `f : M →ₗ[R] M₂` defines a linear equivalence
between `M` and `f.range`. See also `linear_map.of_left_inverse`. -/
noncomputable def of_injective [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂] (h : injective f) :
  M ≃ₛₗ[σ₁₂] f.range :=
  of_left_inverse$ Classical.some_spec h.has_left_inverse

@[simp]
theorem of_injective_apply [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂] {h : injective f} (x : M) :
  «expr↑ » (of_injective f h x) = f x :=
  rfl

/-- A bijective linear map is a linear equivalence. -/
noncomputable def of_bijective [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂] (hf₁ : injective f)
  (hf₂ : surjective f) : M ≃ₛₗ[σ₁₂] M₂ :=
  (of_injective f hf₁).trans (of_top _$ LinearMap.range_eq_top.2 hf₂)

@[simp]
theorem of_bijective_apply [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂] {hf₁ hf₂} (x : M) :
  of_bijective f hf₁ hf₂ x = f x :=
  rfl

end 

end AddCommMonoidₓ

section AddCommGroupₓ

variable[Semiringₓ R][Semiringₓ R₂][Semiringₓ R₃][Semiringₓ R₄]

variable[AddCommGroupₓ M][AddCommGroupₓ M₂][AddCommGroupₓ M₃][AddCommGroupₓ M₄]

variable{module_M : Module R M}{module_M₂ : Module R₂ M₂}

variable{module_M₃ : Module R₃ M₃}{module_M₄ : Module R₄ M₄}

variable{σ₁₂ : R →+* R₂}{σ₃₄ : R₃ →+* R₄}

variable{σ₂₁ : R₂ →+* R}{σ₄₃ : R₄ →+* R₃}

variable{re₁₂ : RingHomInvPair σ₁₂ σ₂₁}{re₂₁ : RingHomInvPair σ₂₁ σ₁₂}

variable{re₃₄ : RingHomInvPair σ₃₄ σ₄₃}{re₄₃ : RingHomInvPair σ₄₃ σ₃₄}

variable(e e₁ : M ≃ₛₗ[σ₁₂] M₂)(e₂ : M₃ ≃ₛₗ[σ₃₄] M₄)

@[simp]
theorem map_neg (a : M) : e (-a) = -e a :=
  e.to_linear_map.map_neg a

@[simp]
theorem map_sub (a b : M) : e (a - b) = e a - e b :=
  e.to_linear_map.map_sub a b

end AddCommGroupₓ

section Neg

variable(R)[Semiringₓ R][AddCommGroupₓ M][Module R M]

/-- `x ↦ -x` as a `linear_equiv` -/
def neg : M ≃ₗ[R] M :=
  { Equiv.neg M, (-LinearMap.id : M →ₗ[R] M) with  }

variable{R}

@[simp]
theorem coe_neg : «expr⇑ » (neg R : M ≃ₗ[R] M) = -id :=
  rfl

theorem neg_apply (x : M) : neg R x = -x :=
  by 
    simp 

@[simp]
theorem symm_neg : (neg R : M ≃ₗ[R] M).symm = neg R :=
  rfl

end Neg

section CommSemiringₓ

variable[CommSemiringₓ R][AddCommMonoidₓ M][AddCommMonoidₓ M₂][AddCommMonoidₓ M₃]

variable[Module R M][Module R M₂][Module R M₃]

open _Root_.LinearMap

/-- Multiplying by a unit `a` of the ring `R` is a linear equivalence. -/
def smul_of_unit (a : Units R) : M ≃ₗ[R] M :=
  of_linear ((a : R) • 1 : M →ₗ[R] M) (((a⁻¹ : Units R) : R) • 1 : M →ₗ[R] M)
    (by 
      rw [smul_comp, comp_smul, smul_smul, Units.mul_inv, one_smul] <;> rfl)
    (by 
      rw [smul_comp, comp_smul, smul_smul, Units.inv_mul, one_smul] <;> rfl)

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- A linear isomorphism between the domains and codomains of two spaces of linear maps gives a
linear isomorphism between the two function spaces. -/
def arrow_congr
{R M₁ M₂ M₂₁ M₂₂ : Sort*}
[comm_semiring R]
[add_comm_monoid M₁]
[add_comm_monoid M₂]
[add_comm_monoid M₂₁]
[add_comm_monoid M₂₂]
[module R M₁]
[module R M₂]
[module R M₂₁]
[module R M₂₂]
(e₁ : «expr ≃ₗ[ ] »(M₁, R, M₂))
(e₂ : «expr ≃ₗ[ ] »(M₂₁, R, M₂₂)) : «expr ≃ₗ[ ] »(«expr →ₗ[ ] »(M₁, R, M₂₁), R, «expr →ₗ[ ] »(M₂, R, M₂₂)) :=
{ to_fun := λ
  f : «expr →ₗ[ ] »(M₁, R, M₂₁), «expr $ »((e₂ : «expr →ₗ[ ] »(M₂₁, R, M₂₂)).comp, f.comp (e₁.symm : «expr →ₗ[ ] »(M₂, R, M₁))),
  inv_fun := λ f, «expr $ »((e₂.symm : «expr →ₗ[ ] »(M₂₂, R, M₂₁)).comp, f.comp (e₁ : «expr →ₗ[ ] »(M₁, R, M₂))),
  left_inv := λ f, by { ext [] [ident x] [],
    simp [] [] ["only"] ["[", expr symm_apply_apply, ",", expr comp_app, ",", expr coe_comp, ",", expr coe_coe, "]"] [] [] },
  right_inv := λ f, by { ext [] [ident x] [],
    simp [] [] ["only"] ["[", expr comp_app, ",", expr apply_symm_apply, ",", expr coe_comp, ",", expr coe_coe, "]"] [] [] },
  map_add' := λ f g, by { ext [] [ident x] [],
    simp [] [] ["only"] ["[", expr map_add, ",", expr add_apply, ",", expr comp_app, ",", expr coe_comp, ",", expr coe_coe, "]"] [] [] },
  map_smul' := λ c f, by { ext [] [ident x] [],
    simp [] [] ["only"] ["[", expr smul_apply, ",", expr comp_app, ",", expr coe_comp, ",", expr map_smulₛₗ, ",", expr coe_coe, "]"] [] [] } }

@[simp]
theorem arrow_congr_apply {R M₁ M₂ M₂₁ M₂₂ : Sort _} [CommSemiringₓ R] [AddCommMonoidₓ M₁] [AddCommMonoidₓ M₂]
  [AddCommMonoidₓ M₂₁] [AddCommMonoidₓ M₂₂] [Module R M₁] [Module R M₂] [Module R M₂₁] [Module R M₂₂] (e₁ : M₁ ≃ₗ[R] M₂)
  (e₂ : M₂₁ ≃ₗ[R] M₂₂) (f : M₁ →ₗ[R] M₂₁) (x : M₂) : arrow_congr e₁ e₂ f x = e₂ (f (e₁.symm x)) :=
  rfl

@[simp]
theorem arrow_congr_symm_apply {R M₁ M₂ M₂₁ M₂₂ : Sort _} [CommSemiringₓ R] [AddCommMonoidₓ M₁] [AddCommMonoidₓ M₂]
  [AddCommMonoidₓ M₂₁] [AddCommMonoidₓ M₂₂] [Module R M₁] [Module R M₂] [Module R M₂₁] [Module R M₂₂] (e₁ : M₁ ≃ₗ[R] M₂)
  (e₂ : M₂₁ ≃ₗ[R] M₂₂) (f : M₂ →ₗ[R] M₂₂) (x : M₁) : (arrow_congr e₁ e₂).symm f x = e₂.symm (f (e₁ x)) :=
  rfl

theorem arrow_congr_comp {N N₂ N₃ : Sort _} [AddCommMonoidₓ N] [AddCommMonoidₓ N₂] [AddCommMonoidₓ N₃] [Module R N]
  [Module R N₂] [Module R N₃] (e₁ : M ≃ₗ[R] N) (e₂ : M₂ ≃ₗ[R] N₂) (e₃ : M₃ ≃ₗ[R] N₃) (f : M →ₗ[R] M₂)
  (g : M₂ →ₗ[R] M₃) : arrow_congr e₁ e₃ (g.comp f) = (arrow_congr e₂ e₃ g).comp (arrow_congr e₁ e₂ f) :=
  by 
    ext 
    simp only [symm_apply_apply, arrow_congr_apply, LinearMap.comp_apply]

theorem arrow_congr_trans {M₁ M₂ M₃ N₁ N₂ N₃ : Sort _} [AddCommMonoidₓ M₁] [Module R M₁] [AddCommMonoidₓ M₂]
  [Module R M₂] [AddCommMonoidₓ M₃] [Module R M₃] [AddCommMonoidₓ N₁] [Module R N₁] [AddCommMonoidₓ N₂] [Module R N₂]
  [AddCommMonoidₓ N₃] [Module R N₃] (e₁ : M₁ ≃ₗ[R] M₂) (e₂ : N₁ ≃ₗ[R] N₂) (e₃ : M₂ ≃ₗ[R] M₃) (e₄ : N₂ ≃ₗ[R] N₃) :
  (arrow_congr e₁ e₂).trans (arrow_congr e₃ e₄) = arrow_congr (e₁.trans e₃) (e₂.trans e₄) :=
  rfl

/-- If `M₂` and `M₃` are linearly isomorphic then the two spaces of linear maps from `M` into `M₂`
and `M` into `M₃` are linearly isomorphic. -/
def congr_right (f : M₂ ≃ₗ[R] M₃) : (M →ₗ[R] M₂) ≃ₗ[R] M →ₗ[R] M₃ :=
  arrow_congr (LinearEquiv.refl R M) f

/-- If `M` and `M₂` are linearly isomorphic then the two spaces of linear maps from `M` and `M₂` to
themselves are linearly isomorphic. -/
def conj (e : M ≃ₗ[R] M₂) : Module.End R M ≃ₗ[R] Module.End R M₂ :=
  arrow_congr e e

theorem conj_apply (e : M ≃ₗ[R] M₂) (f : Module.End R M) :
  e.conj f = ((«expr↑ » e : M →ₗ[R] M₂).comp f).comp (e.symm : M₂ →ₗ[R] M) :=
  rfl

theorem symm_conj_apply (e : M ≃ₗ[R] M₂) (f : Module.End R M₂) :
  e.symm.conj f = ((«expr↑ » e.symm : M₂ →ₗ[R] M).comp f).comp (e : M →ₗ[R] M₂) :=
  rfl

theorem conj_comp (e : M ≃ₗ[R] M₂) (f g : Module.End R M) : e.conj (g.comp f) = (e.conj g).comp (e.conj f) :=
  arrow_congr_comp e e e f g

theorem conj_trans (e₁ : M ≃ₗ[R] M₂) (e₂ : M₂ ≃ₗ[R] M₃) : e₁.conj.trans e₂.conj = (e₁.trans e₂).conj :=
  by 
    ext f x 
    rfl

@[simp]
theorem conj_id (e : M ≃ₗ[R] M₂) : e.conj LinearMap.id = LinearMap.id :=
  by 
    ext 
    simp [conj_apply]

end CommSemiringₓ

section Field

variable[Field K][AddCommGroupₓ M][AddCommGroupₓ M₂][AddCommGroupₓ M₃]

variable[Module K M][Module K M₂][Module K M₃]

variable(K)(M)

open _Root_.LinearMap

/-- Multiplying by a nonzero element `a` of the field `K` is a linear equivalence. -/
def smul_of_ne_zero (a : K) (ha : a ≠ 0) : M ≃ₗ[K] M :=
  smul_of_unit$ Units.mk0 a ha

section 

noncomputable theory

open_locale Classical

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem ker_to_span_singleton {x : M} (h : «expr ≠ »(x, 0)) : «expr = »((to_span_singleton K M x).ker, «expr⊥»()) :=
begin
  ext [] [ident c] [],
  split,
  { intros [ident hc],
    rw [expr submodule.mem_bot] [],
    rw [expr mem_ker] ["at", ident hc],
    by_contra [ident hc'],
    have [] [":", expr «expr = »(x, 0)] [],
    calc
      «expr = »(x, «expr • »(«expr ⁻¹»(c), «expr • »(c, x))) : by rw ["[", "<-", expr mul_smul, ",", expr inv_mul_cancel hc', ",", expr one_smul, "]"] []
      «expr = »(..., «expr • »(«expr ⁻¹»(c), to_span_singleton K M x c)) : rfl
      «expr = »(..., 0) : by rw ["[", expr hc, ",", expr smul_zero, "]"] [],
    tauto [] },
  { rw ["[", expr mem_ker, ",", expr submodule.mem_bot, "]"] [],
    intros [ident h],
    rw [expr h] [],
    simp [] [] [] [] [] [] }
end

/-- Given a nonzero element `x` of a vector space `M` over a field `K`, the natural
    map from `K` to the span of `x`, with invertibility check to consider it as an
    isomorphism.-/
def to_span_nonzero_singleton (x : M) (h : x ≠ 0) : K ≃ₗ[K] K∙x :=
  LinearEquiv.trans (LinearEquiv.ofInjective (to_span_singleton K M x) (ker_eq_bot.1$ ker_to_span_singleton K M h))
    (of_eq (to_span_singleton K M x).range (K∙x) (span_singleton_eq_range K M x).symm)

-- error in LinearAlgebra.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem to_span_nonzero_singleton_one
(x : M)
(h : «expr ≠ »(x, 0)) : «expr = »(to_span_nonzero_singleton K M x h 1, (⟨x, submodule.mem_span_singleton_self x⟩ : «expr ∙ »(K, x))) :=
begin
  apply [expr set_like.coe_eq_coe.mp],
  have [] [":", expr «expr = »(«expr↑ »(to_span_nonzero_singleton K M x h 1), to_span_singleton K M x 1)] [":=", expr rfl],
  rw ["[", expr this, ",", expr to_span_singleton_one, ",", expr submodule.coe_mk, "]"] []
end

/-- Given a nonzero element `x` of a vector space `M` over a field `K`, the natural map
    from the span of `x` to `K`.-/
abbrev coord (x : M) (h : x ≠ 0) : (K∙x) ≃ₗ[K] K :=
  (to_span_nonzero_singleton K M x h).symm

theorem coord_self (x : M) (h : x ≠ 0) : (coord K M x h) (⟨x, Submodule.mem_span_singleton_self x⟩ : K∙x) = 1 :=
  by 
    rw [←to_span_nonzero_singleton_one K M x h, symm_apply_apply]

end 

end Field

end LinearEquiv

namespace Submodule

section Module

variable[Semiringₓ R][AddCommMonoidₓ M][Module R M]

/-- Given `p` a submodule of the module `M` and `q` a submodule of `p`, `p.equiv_subtype_map q`
is the natural `linear_equiv` between `q` and `q.map p.subtype`. -/
def equiv_subtype_map (p : Submodule R M) (q : Submodule R p) : q ≃ₗ[R] q.map p.subtype :=
  { (p.subtype.dom_restrict q).codRestrict _
      (by 
        rintro ⟨x, hx⟩
        refine' ⟨x, hx, rfl⟩) with
    invFun :=
      by 
        rintro ⟨x, hx⟩
        refine' ⟨⟨x, _⟩, _⟩ <;> rcases hx with ⟨⟨_, h⟩, _, rfl⟩ <;> assumption,
    left_inv := fun ⟨⟨_, _⟩, _⟩ => rfl, right_inv := fun ⟨x, ⟨_, h⟩, _, rfl⟩ => rfl }

@[simp]
theorem equiv_subtype_map_apply {p : Submodule R M} {q : Submodule R p} (x : q) :
  (p.equiv_subtype_map q x : M) = p.subtype.dom_restrict q x :=
  rfl

@[simp]
theorem equiv_subtype_map_symm_apply {p : Submodule R M} {q : Submodule R p} (x : q.map p.subtype) :
  ((p.equiv_subtype_map q).symm x : M) = x :=
  by 
    cases x 
    rfl

/-- If `s ≤ t`, then we can view `s` as a submodule of `t` by taking the comap
of `t.subtype`. -/
@[simps]
def comap_subtype_equiv_of_le {p q : Submodule R M} (hpq : p ≤ q) : comap q.subtype p ≃ₗ[R] p :=
  { toFun := fun x => ⟨x, x.2⟩, invFun := fun x => ⟨⟨x, hpq x.2⟩, x.2⟩,
    left_inv :=
      fun x =>
        by 
          simp only [coe_mk, SetLike.eta, coe_coe],
    right_inv :=
      fun x =>
        by 
          simp only [Subtype.coe_mk, SetLike.eta, coe_coe],
    map_add' := fun x y => rfl, map_smul' := fun c x => rfl }

end Module

end Submodule

namespace Submodule

variable[CommSemiringₓ R][CommSemiringₓ R₂]

variable[AddCommMonoidₓ M][AddCommMonoidₓ M₂][Module R M][Module R₂ M₂]

variable[AddCommMonoidₓ N][AddCommMonoidₓ N₂][Module R N][Module R N₂]

variable{τ₁₂ : R →+* R₂}{τ₂₁ : R₂ →+* R}

variable[RingHomInvPair τ₁₂ τ₂₁][RingHomInvPair τ₂₁ τ₁₂]

variable(p : Submodule R M)(q : Submodule R₂ M₂)

variable(pₗ : Submodule R N)(qₗ : Submodule R N₂)

include τ₂₁

@[simp]
theorem mem_map_equiv {e : M ≃ₛₗ[τ₁₂] M₂} {x : M₂} : x ∈ p.map (e : M →ₛₗ[τ₁₂] M₂) ↔ e.symm x ∈ p :=
  by 
    rw [Submodule.mem_map]
    split 
    ·
      rintro ⟨y, hy, hx⟩
      simp [←hx, hy]
    ·
      intro hx 
      refine'
        ⟨e.symm x, hx,
          by 
            simp ⟩

omit τ₂₁

theorem map_equiv_eq_comap_symm (e : M ≃ₛₗ[τ₁₂] M₂) (K : Submodule R M) :
  K.map (e : M →ₛₗ[τ₁₂] M₂) = K.comap (e.symm : M₂ →ₛₗ[τ₂₁] M) :=
  Submodule.ext
    fun _ =>
      by 
        rw [mem_map_equiv, mem_comap, LinearEquiv.coe_coe]

theorem comap_equiv_eq_map_symm (e : M ≃ₛₗ[τ₁₂] M₂) (K : Submodule R₂ M₂) :
  K.comap (e : M →ₛₗ[τ₁₂] M₂) = K.map (e.symm : M₂ →ₛₗ[τ₂₁] M) :=
  (map_equiv_eq_comap_symm e.symm K).symm

theorem comap_le_comap_smul (fₗ : N →ₗ[R] N₂) (c : R) : comap fₗ qₗ ≤ comap (c • fₗ) qₗ :=
  by 
    rw [SetLike.le_def]
    intro m h 
    change c • fₗ m ∈ qₗ 
    change fₗ m ∈ qₗ at h 
    apply qₗ.smul_mem _ h

theorem inf_comap_le_comap_add (f₁ f₂ : M →ₛₗ[τ₁₂] M₂) : comap f₁ q⊓comap f₂ q ≤ comap (f₁+f₂) q :=
  by 
    rw [SetLike.le_def]
    intro m h 
    change (f₁ m+f₂ m) ∈ q 
    change f₁ m ∈ q ∧ f₂ m ∈ q at h 
    apply q.add_mem h.1 h.2

/-- Given modules `M`, `M₂` over a commutative ring, together with submodules `p ⊆ M`, `q ⊆ M₂`,
the set of maps $\{f ∈ Hom(M, M₂) | f(p) ⊆ q \}$ is a submodule of `Hom(M, M₂)`. -/
def compatible_maps : Submodule R (N →ₗ[R] N₂) :=
  { Carrier := { fₗ | pₗ ≤ comap fₗ qₗ },
    zero_mem' :=
      by 
        change pₗ ≤ comap 0 qₗ 
        rw [comap_zero]
        refine' le_top,
    add_mem' :=
      fun f₁ f₂ h₁ h₂ =>
        by 
          apply le_transₓ _ (inf_comap_le_comap_add qₗ f₁ f₂)
          rw [le_inf_iff]
          exact ⟨h₁, h₂⟩,
    smul_mem' := fun c fₗ h => le_transₓ h (comap_le_comap_smul qₗ fₗ c) }

end Submodule

namespace Equiv

variable[Semiringₓ R][AddCommMonoidₓ M][Module R M][AddCommMonoidₓ M₂][Module R M₂]

/-- An equivalence whose underlying function is linear is a linear equivalence. -/
def to_linear_equiv (e : M ≃ M₂) (h : IsLinearMap R (e : M → M₂)) : M ≃ₗ[R] M₂ :=
  { e, h.mk' e with  }

end Equiv

namespace AddEquiv

variable[Semiringₓ R][AddCommMonoidₓ M][Module R M][AddCommMonoidₓ M₂][Module R M₂]

/-- An additive equivalence whose underlying function preserves `smul` is a linear equivalence. -/
def to_linear_equiv (e : M ≃+ M₂) (h : ∀ (c : R) x, e (c • x) = c • e x) : M ≃ₗ[R] M₂ :=
  { e with map_smul' := h }

@[simp]
theorem coe_to_linear_equiv (e : M ≃+ M₂) (h : ∀ (c : R) x, e (c • x) = c • e x) : «expr⇑ » (e.to_linear_equiv h) = e :=
  rfl

@[simp]
theorem coe_to_linear_equiv_symm (e : M ≃+ M₂) (h : ∀ (c : R) x, e (c • x) = c • e x) :
  «expr⇑ » (e.to_linear_equiv h).symm = e.symm :=
  rfl

end AddEquiv

section FunLeft

variable(R M)[Semiringₓ R][AddCommMonoidₓ M][Module R M]

variable{m n p : Type _}

namespace LinearMap

/-- Given an `R`-module `M` and a function `m → n` between arbitrary types,
construct a linear map `(n → M) →ₗ[R] (m → M)` -/
def fun_left (f : m → n) : (n → M) →ₗ[R] m → M :=
  { toFun := · ∘ f, map_add' := fun _ _ => rfl, map_smul' := fun _ _ => rfl }

@[simp]
theorem fun_left_apply (f : m → n) (g : n → M) (i : m) : fun_left R M f g i = g (f i) :=
  rfl

@[simp]
theorem fun_left_id (g : n → M) : fun_left R M _root_.id g = g :=
  rfl

theorem fun_left_comp (f₁ : n → p) (f₂ : m → n) : fun_left R M (f₁ ∘ f₂) = (fun_left R M f₂).comp (fun_left R M f₁) :=
  rfl

theorem fun_left_surjective_of_injective (f : m → n) (hf : injective f) : surjective (fun_left R M f) :=
  by 
    classical 
    intro g 
    refine' ⟨fun x => if h : ∃ y, f y = x then g h.some else 0, _⟩
    ·
      ext 
      dsimp only [fun_left_apply]
      splitIfs with w
      ·
        congr 
        exact hf w.some_spec
      ·
        simpa only [not_true, exists_apply_eq_applyₓ] using w

theorem fun_left_injective_of_surjective (f : m → n) (hf : surjective f) : injective (fun_left R M f) :=
  by 
    obtain ⟨g, hg⟩ := hf.has_right_inverse 
    suffices  : left_inverse (fun_left R M g) (fun_left R M f)
    ·
      exact this.injective 
    intro x 
    rw [←LinearMap.comp_apply, ←fun_left_comp, hg.id, fun_left_id]

end LinearMap

namespace LinearEquiv

open _Root_.LinearMap

/-- Given an `R`-module `M` and an equivalence `m ≃ n` between arbitrary types,
construct a linear equivalence `(n → M) ≃ₗ[R] (m → M)` -/
def fun_congr_left (e : m ≃ n) : (n → M) ≃ₗ[R] m → M :=
  LinearEquiv.ofLinear (fun_left R M e) (fun_left R M e.symm)
    (LinearMap.ext$
      fun x =>
        funext$
          fun i =>
            by 
              rw [id_apply, ←fun_left_comp, Equiv.symm_comp_self, fun_left_id])
    (LinearMap.ext$
      fun x =>
        funext$
          fun i =>
            by 
              rw [id_apply, ←fun_left_comp, Equiv.self_comp_symm, fun_left_id])

@[simp]
theorem fun_congr_left_apply (e : m ≃ n) (x : n → M) : fun_congr_left R M e x = fun_left R M e x :=
  rfl

@[simp]
theorem fun_congr_left_id : fun_congr_left R M (Equiv.refl n) = LinearEquiv.refl R (n → M) :=
  rfl

@[simp]
theorem fun_congr_left_comp (e₁ : m ≃ n) (e₂ : n ≃ p) :
  fun_congr_left R M (Equiv.trans e₁ e₂) = LinearEquiv.trans (fun_congr_left R M e₂) (fun_congr_left R M e₁) :=
  rfl

@[simp]
theorem fun_congr_left_symm (e : m ≃ n) : (fun_congr_left R M e).symm = fun_congr_left R M e.symm :=
  rfl

end LinearEquiv

end FunLeft

namespace LinearMap

variable[Semiringₓ R][AddCommMonoidₓ M][Module R M]

variable(R M)

/-- The group of invertible linear maps from `M` to itself -/
@[reducible]
def general_linear_group :=
  Units (M →ₗ[R] M)

namespace GeneralLinearGroup

variable{R M}

instance  : CoeFun (general_linear_group R M) fun _ => M → M :=
  by 
    infer_instance

/-- An invertible linear map `f` determines an equivalence from `M` to itself. -/
def to_linear_equiv (f : general_linear_group R M) : M ≃ₗ[R] M :=
  { f.val with invFun := f.inv.to_fun,
    left_inv :=
      fun m =>
        show (f.inv*f.val) m = m by 
          erw [f.inv_val] <;> simp ,
    right_inv :=
      fun m =>
        show (f.val*f.inv) m = m by 
          erw [f.val_inv] <;> simp  }

/-- An equivalence from `M` to itself determines an invertible linear map. -/
def of_linear_equiv (f : M ≃ₗ[R] M) : general_linear_group R M :=
  { val := f, inv := (f.symm : M →ₗ[R] M), val_inv := LinearMap.ext$ fun _ => f.apply_symm_apply _,
    inv_val := LinearMap.ext$ fun _ => f.symm_apply_apply _ }

variable(R M)

/-- The general linear group on `R` and `M` is multiplicatively equivalent to the type of linear
equivalences between `M` and itself. -/
def general_linear_equiv : general_linear_group R M ≃* M ≃ₗ[R] M :=
  { toFun := to_linear_equiv, invFun := of_linear_equiv,
    left_inv :=
      fun f =>
        by 
          ext 
          rfl,
    right_inv :=
      fun f =>
        by 
          ext 
          rfl,
    map_mul' :=
      fun x y =>
        by 
          ext 
          rfl }

@[simp]
theorem general_linear_equiv_to_linear_map (f : general_linear_group R M) :
  (general_linear_equiv R M f : M →ₗ[R] M) = f :=
  by 
    ext 
    rfl

end GeneralLinearGroup

end LinearMap

namespace Submodule

variable[Ringₓ R][AddCommGroupₓ M][Module R M]

instance  : IsModularLattice (Submodule R M) :=
  ⟨fun x y z xz a ha =>
      by 
        rw [mem_inf, mem_sup] at ha 
        rcases ha with ⟨⟨b, hb, c, hc, rfl⟩, haz⟩
        rw [mem_sup]
        refine' ⟨b, hb, c, mem_inf.2 ⟨hc, _⟩, rfl⟩
        rw [←add_sub_cancel c b, add_commₓ]
        apply z.sub_mem haz (xz hb)⟩

end Submodule

