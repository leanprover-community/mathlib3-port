/-
Copyright (c) 2019 Jean Lo. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jean Lo, Yaël Dillies, Moritz Doll
-/
import Mathbin.Data.Real.Pointwise
import Mathbin.Data.Real.Sqrt
import Mathbin.Topology.Algebra.FilterBasis
import Mathbin.Topology.Algebra.Module.LocallyConvex

/-!
# Seminorms

This file defines seminorms.

A seminorm is a function to the reals which is positive-semidefinite, absolutely homogeneous, and
subadditive. They are closely related to convex sets and a topological vector space is locally
convex if and only if its topology is induced by a family of seminorms.

## Main declarations

For a module over a normed ring:
* `seminorm`: A function to the reals that is positive-semidefinite, absolutely homogeneous, and
  subadditive.
* `norm_seminorm 𝕜 E`: The norm on `E` as a seminorm.

## References

* [H. H. Schaefer, *Topological Vector Spaces*][schaefer1966]

## Tags

seminorm, locally convex, LCTVS
-/


open NormedField Set

open BigOperators Nnreal Pointwise TopologicalSpace

variable {R R' 𝕜 𝕜₂ 𝕜₃ E E₂ E₃ F G ι : Type _}

/-- A seminorm on a module over a normed ring is a function to the reals that is positive
semidefinite, positive homogeneous, and subadditive. -/
structure Seminorm (𝕜 : Type _) (E : Type _) [SemiNormedRing 𝕜] [AddGroup E] [HasSmul 𝕜 E] extends
  AddGroupSeminorm E where
  smul' : ∀ (a : 𝕜) (x : E), to_fun (a • x) = ∥a∥ * to_fun x

attribute [nolint doc_blame] Seminorm.toAddGroupSeminorm

/-- `seminorm_class F 𝕜 E` states that `F` is a type of seminorms on the `𝕜`-module E.

You should extend this class when you extend `seminorm`. -/
class SeminormClass (F : Type _) (𝕜 E : outParam <| Type _) [SemiNormedRing 𝕜] [AddGroup E] [HasSmul 𝕜 E] extends
  AddGroupSeminormClass F E where
  map_smul_eq_mul (f : F) (a : 𝕜) (x : E) : f (a • x) = ∥a∥ * f x

export SeminormClass (map_smul_eq_mul)

-- `𝕜` is an `out_param`, so this is a false positive.
attribute [nolint dangerous_instance] SeminormClass.toAddGroupSeminormClass

section Of

/-- Alternative constructor for a `seminorm` on an `add_comm_group E` that is a module over a
`semi_norm_ring 𝕜`. -/
def Seminorm.of [SemiNormedRing 𝕜] [AddCommGroup E] [Module 𝕜 E] (f : E → ℝ) (add_le : ∀ x y : E, f (x + y) ≤ f x + f y)
    (smul : ∀ (a : 𝕜) (x : E), f (a • x) = ∥a∥ * f x) : Seminorm 𝕜 E where
  toFun := f
  map_zero' := by rw [← zero_smul 𝕜 (0 : E), smul, norm_zero, zero_mul]
  add_le' := add_le
  smul' := smul
  neg' x := by rw [← neg_one_smul 𝕜, smul, norm_neg, ← smul, one_smul]

/-- Alternative constructor for a `seminorm` over a normed field `𝕜` that only assumes `f 0 = 0`
and an inequality for the scalar multiplication. -/
def Seminorm.ofSmulLe [NormedField 𝕜] [AddCommGroup E] [Module 𝕜 E] (f : E → ℝ) (map_zero : f 0 = 0)
    (add_le : ∀ x y, f (x + y) ≤ f x + f y) (smul_le : ∀ (r : 𝕜) (x), f (r • x) ≤ ∥r∥ * f x) : Seminorm 𝕜 E :=
  Seminorm.of f add_le fun r x => by
    refine' le_antisymm (smul_le r x) _
    by_cases r = 0
    · simp [h, map_zero]
      
    rw [← mul_le_mul_left (inv_pos.mpr (norm_pos_iff.mpr h))]
    rw [inv_mul_cancel_left₀ (norm_ne_zero_iff.mpr h)]
    specialize smul_le r⁻¹ (r • x)
    rw [norm_inv] at smul_le
    convert smul_le
    simp [h]

end Of

namespace Seminorm

section SemiNormedRing

variable [SemiNormedRing 𝕜]

section AddGroup

variable [AddGroup E]

section HasSmul

variable [HasSmul 𝕜 E]

instance seminormClass : SeminormClass (Seminorm 𝕜 E) 𝕜 E where
  coe f := f.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  map_zero f := f.map_zero'
  map_add_le_add f := f.add_le'
  map_neg_eq_map f := f.neg'
  map_smul_eq_mul f := f.smul'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`. -/
instance : CoeFun (Seminorm 𝕜 E) fun _ => E → ℝ :=
  FunLike.hasCoeToFun

@[ext]
theorem ext {p q : Seminorm 𝕜 E} (h : ∀ x, (p : E → ℝ) x = q x) : p = q :=
  FunLike.ext p q h

instance : Zero (Seminorm 𝕜 E) :=
  ⟨{ AddGroupSeminorm.hasZero.zero with smul' := fun _ _ => (mul_zero _).symm }⟩

@[simp]
theorem coe_zero : ⇑(0 : Seminorm 𝕜 E) = 0 :=
  rfl

@[simp]
theorem zero_apply (x : E) : (0 : Seminorm 𝕜 E) x = 0 :=
  rfl

instance : Inhabited (Seminorm 𝕜 E) :=
  ⟨0⟩

variable (p : Seminorm 𝕜 E) (c : 𝕜) (x y : E) (r : ℝ)

/-- Any action on `ℝ` which factors through `ℝ≥0` applies to a seminorm. -/
instance [HasSmul R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] :
    HasSmul R
      (Seminorm 𝕜 E) where smul r p :=
    { r • p.toAddGroupSeminorm with toFun := fun x => r • p x,
      smul' := fun _ _ => by
        simp only [← smul_one_smul ℝ≥0 r (_ : ℝ), Nnreal.smul_def, smul_eq_mul]
        rw [map_smul_eq_mul, mul_left_comm] }

instance [HasSmul R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] [HasSmul R' ℝ] [HasSmul R' ℝ≥0] [IsScalarTower R' ℝ≥0 ℝ]
    [HasSmul R R'] [IsScalarTower R R' ℝ] :
    IsScalarTower R R' (Seminorm 𝕜 E) where smul_assoc r a p := ext fun x => smul_assoc r a (p x)

theorem coe_smul [HasSmul R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] (r : R) (p : Seminorm 𝕜 E) : ⇑(r • p) = r • p :=
  rfl

@[simp]
theorem smul_apply [HasSmul R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] (r : R) (p : Seminorm 𝕜 E) (x : E) :
    (r • p) x = r • p x :=
  rfl

instance :
    Add
      (Seminorm 𝕜
        E) where add p q :=
    { p.toAddGroupSeminorm + q.toAddGroupSeminorm with toFun := fun x => p x + q x,
      smul' := fun a x => by simp only [map_smul_eq_mul, map_smul_eq_mul, mul_add] }

theorem coe_add (p q : Seminorm 𝕜 E) : ⇑(p + q) = p + q :=
  rfl

@[simp]
theorem add_apply (p q : Seminorm 𝕜 E) (x : E) : (p + q) x = p x + q x :=
  rfl

instance : AddMonoid (Seminorm 𝕜 E) :=
  FunLike.coe_injective.AddMonoid _ rfl coe_add fun p n => coe_smul n p

instance : OrderedCancelAddCommMonoid (Seminorm 𝕜 E) :=
  FunLike.coe_injective.OrderedCancelAddCommMonoid _ rfl coe_add fun p n => coe_smul n p

instance [Monoid R] [MulAction R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] : MulAction R (Seminorm 𝕜 E) :=
  FunLike.coe_injective.MulAction _ coe_smul

variable (𝕜 E)

/-- `coe_fn` as an `add_monoid_hom`. Helper definition for showing that `seminorm 𝕜 E` is
a module. -/
@[simps]
def coeFnAddMonoidHom : AddMonoidHom (Seminorm 𝕜 E) (E → ℝ) :=
  ⟨coeFn, coe_zero, coe_add⟩

theorem coe_fn_add_monoid_hom_injective : Function.Injective (coeFnAddMonoidHom 𝕜 E) :=
  show @Function.Injective (Seminorm 𝕜 E) (E → ℝ) coeFn from FunLike.coe_injective

variable {𝕜 E}

instance [Monoid R] [DistribMulAction R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] :
    DistribMulAction R (Seminorm 𝕜 E) :=
  (coe_fn_add_monoid_hom_injective 𝕜 E).DistribMulAction _ coe_smul

instance [Semiring R] [Module R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] : Module R (Seminorm 𝕜 E) :=
  (coe_fn_add_monoid_hom_injective 𝕜 E).Module R _ coe_smul

instance :
    HasSup
      (Seminorm 𝕜
        E) where sup p q :=
    { p.toAddGroupSeminorm ⊔ q.toAddGroupSeminorm with toFun := p ⊔ q,
      smul' := fun x v =>
        (congr_arg₂ max (map_smul_eq_mul p x v) (map_smul_eq_mul q x v)).trans <|
          (mul_max_of_nonneg _ _ <| norm_nonneg x).symm }

@[simp]
theorem coe_sup (p q : Seminorm 𝕜 E) : ⇑(p ⊔ q) = p ⊔ q :=
  rfl

theorem sup_apply (p q : Seminorm 𝕜 E) (x : E) : (p ⊔ q) x = p x ⊔ q x :=
  rfl

theorem smul_sup [HasSmul R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] (r : R) (p q : Seminorm 𝕜 E) :
    r • (p ⊔ q) = r • p ⊔ r • q :=
  have real.smul_max : ∀ x y : ℝ, r • max x y = max (r • x) (r • y) := fun x y => by
    simpa only [← smul_eq_mul, ← Nnreal.smul_def, smul_one_smul ℝ≥0 r (_ : ℝ)] using
      mul_max_of_nonneg x y (r • 1 : ℝ≥0).Prop
  ext fun x => real.smul_max _ _

instance : PartialOrder (Seminorm 𝕜 E) :=
  PartialOrder.lift _ FunLike.coe_injective

theorem le_def (p q : Seminorm 𝕜 E) : p ≤ q ↔ (p : E → ℝ) ≤ q :=
  Iff.rfl

theorem lt_def (p q : Seminorm 𝕜 E) : p < q ↔ (p : E → ℝ) < q :=
  Iff.rfl

instance : SemilatticeSup (Seminorm 𝕜 E) :=
  Function.Injective.semilatticeSup _ FunLike.coe_injective coe_sup

end HasSmul

end AddGroup

section Module

variable [SemiNormedRing 𝕜₂] [SemiNormedRing 𝕜₃]

variable {σ₁₂ : 𝕜 →+* 𝕜₂} [RingHomIsometric σ₁₂]

variable {σ₂₃ : 𝕜₂ →+* 𝕜₃} [RingHomIsometric σ₂₃]

variable {σ₁₃ : 𝕜 →+* 𝕜₃} [RingHomIsometric σ₁₃]

variable [AddCommGroup E] [AddCommGroup E₂] [AddCommGroup E₃]

variable [AddCommGroup F] [AddCommGroup G]

variable [Module 𝕜 E] [Module 𝕜₂ E₂] [Module 𝕜₃ E₃] [Module 𝕜 F] [Module 𝕜 G]

variable [HasSmul R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ]

/-- Composition of a seminorm with a linear map is a seminorm. -/
def comp (p : Seminorm 𝕜₂ E₂) (f : E →ₛₗ[σ₁₂] E₂) : Seminorm 𝕜 E :=
  { p.toAddGroupSeminorm.comp f.toAddMonoidHom with toFun := fun x => p (f x),
    smul' := fun _ _ => by rw [map_smulₛₗ, map_smul_eq_mul, RingHomIsometric.is_iso] }

theorem coe_comp (p : Seminorm 𝕜₂ E₂) (f : E →ₛₗ[σ₁₂] E₂) : ⇑(p.comp f) = p ∘ f :=
  rfl

@[simp]
theorem comp_apply (p : Seminorm 𝕜₂ E₂) (f : E →ₛₗ[σ₁₂] E₂) (x : E) : (p.comp f) x = p (f x) :=
  rfl

@[simp]
theorem comp_id (p : Seminorm 𝕜 E) : p.comp LinearMap.id = p :=
  ext fun _ => rfl

@[simp]
theorem comp_zero (p : Seminorm 𝕜₂ E₂) : p.comp (0 : E →ₛₗ[σ₁₂] E₂) = 0 :=
  ext fun _ => map_zero p

@[simp]
theorem zero_comp (f : E →ₛₗ[σ₁₂] E₂) : (0 : Seminorm 𝕜₂ E₂).comp f = 0 :=
  ext fun _ => rfl

theorem comp_comp [RingHomCompTriple σ₁₂ σ₂₃ σ₁₃] (p : Seminorm 𝕜₃ E₃) (g : E₂ →ₛₗ[σ₂₃] E₃) (f : E →ₛₗ[σ₁₂] E₂) :
    p.comp (g.comp f) = (p.comp g).comp f :=
  ext fun _ => rfl

theorem add_comp (p q : Seminorm 𝕜₂ E₂) (f : E →ₛₗ[σ₁₂] E₂) : (p + q).comp f = p.comp f + q.comp f :=
  ext fun _ => rfl

theorem comp_add_le (p : Seminorm 𝕜₂ E₂) (f g : E →ₛₗ[σ₁₂] E₂) : p.comp (f + g) ≤ p.comp f + p.comp g := fun _ =>
  map_add_le_add p _ _

theorem smul_comp (p : Seminorm 𝕜₂ E₂) (f : E →ₛₗ[σ₁₂] E₂) (c : R) : (c • p).comp f = c • p.comp f :=
  ext fun _ => rfl

theorem comp_mono {p q : Seminorm 𝕜₂ E₂} (f : E →ₛₗ[σ₁₂] E₂) (hp : p ≤ q) : p.comp f ≤ q.comp f := fun _ => hp _

/-- The composition as an `add_monoid_hom`. -/
@[simps]
def pullback (f : E →ₛₗ[σ₁₂] E₂) : Seminorm 𝕜₂ E₂ →+ Seminorm 𝕜 E :=
  ⟨fun p => p.comp f, zero_comp f, fun p q => add_comp p q f⟩

instance : OrderBot (Seminorm 𝕜 E) :=
  ⟨0, map_nonneg⟩

@[simp]
theorem coe_bot : ⇑(⊥ : Seminorm 𝕜 E) = 0 :=
  rfl

theorem bot_eq_zero : (⊥ : Seminorm 𝕜 E) = 0 :=
  rfl

theorem smul_le_smul {p q : Seminorm 𝕜 E} {a b : ℝ≥0} (hpq : p ≤ q) (hab : a ≤ b) : a • p ≤ b • q := by
  simp_rw [le_def, Pi.le_def, coe_smul]
  intro x
  simp_rw [Pi.smul_apply, Nnreal.smul_def, smul_eq_mul]
  exact mul_le_mul hab (hpq x) (map_nonneg p x) (Nnreal.coe_nonneg b)

theorem finset_sup_apply (p : ι → Seminorm 𝕜 E) (s : Finset ι) (x : E) :
    s.sup p x = ↑(s.sup fun i => ⟨p i x, map_nonneg (p i) x⟩ : ℝ≥0) := by
  induction' s using Finset.cons_induction_on with a s ha ih
  · rw [Finset.sup_empty, Finset.sup_empty, coe_bot, _root_.bot_eq_zero, Pi.zero_apply, Nonneg.coe_zero]
    
  · rw [Finset.sup_cons, Finset.sup_cons, coe_sup, sup_eq_max, Pi.sup_apply, sup_eq_max, Nnreal.coe_max, Subtype.coe_mk,
      ih]
    

theorem finset_sup_le_sum (p : ι → Seminorm 𝕜 E) (s : Finset ι) : s.sup p ≤ ∑ i in s, p i := by
  classical
  refine' finset.sup_le_iff.mpr _
  intro i hi
  rw [Finset.sum_eq_sum_diff_singleton_add hi, le_add_iff_nonneg_left]
  exact bot_le

theorem finset_sup_apply_le {p : ι → Seminorm 𝕜 E} {s : Finset ι} {x : E} {a : ℝ} (ha : 0 ≤ a)
    (h : ∀ i, i ∈ s → p i x ≤ a) : s.sup p x ≤ a := by
  lift a to ℝ≥0 using ha
  rw [finset_sup_apply, Nnreal.coe_le_coe]
  exact Finset.sup_le h

theorem finset_sup_apply_lt {p : ι → Seminorm 𝕜 E} {s : Finset ι} {x : E} {a : ℝ} (ha : 0 < a)
    (h : ∀ i, i ∈ s → p i x < a) : s.sup p x < a := by
  lift a to ℝ≥0 using ha.le
  rw [finset_sup_apply, Nnreal.coe_lt_coe, Finset.sup_lt_iff]
  · exact h
    
  · exact nnreal.coe_pos.mpr ha
    

theorem norm_sub_map_le_sub (p : Seminorm 𝕜 E) (x y : E) : ∥p x - p y∥ ≤ p (x - y) :=
  abs_sub_map_le_sub p x y

end Module

end SemiNormedRing

section SemiNormedCommRing

variable [SemiNormedRing 𝕜] [SemiNormedCommRing 𝕜₂]

variable {σ₁₂ : 𝕜 →+* 𝕜₂} [RingHomIsometric σ₁₂]

variable [AddCommGroup E] [AddCommGroup E₂] [Module 𝕜 E] [Module 𝕜₂ E₂]

theorem comp_smul (p : Seminorm 𝕜₂ E₂) (f : E →ₛₗ[σ₁₂] E₂) (c : 𝕜₂) : p.comp (c • f) = ∥c∥₊ • p.comp f :=
  ext fun _ => by
    rw [comp_apply, smul_apply, LinearMap.smul_apply, map_smul_eq_mul, Nnreal.smul_def, coe_nnnorm, smul_eq_mul,
      comp_apply]

theorem comp_smul_apply (p : Seminorm 𝕜₂ E₂) (f : E →ₛₗ[σ₁₂] E₂) (c : 𝕜₂) (x : E) : p.comp (c • f) x = ∥c∥ * p (f x) :=
  map_smul_eq_mul p _ _

end SemiNormedCommRing

section NormedField

variable [NormedField 𝕜] [AddCommGroup E] [Module 𝕜 E] {p q : Seminorm 𝕜 E} {x : E}

/-- Auxiliary lemma to show that the infimum of seminorms is well-defined. -/
theorem bdd_below_range_add : BddBelow (range fun u => p u + q (x - u)) :=
  ⟨0, by
    rintro _ ⟨x, rfl⟩
    dsimp
    positivity⟩

noncomputable instance :
    HasInf
      (Seminorm 𝕜
        E) where inf p q :=
    { p.toAddGroupSeminorm ⊓ q.toAddGroupSeminorm with toFun := fun x => ⨅ u : E, p u + q (x - u),
      smul' := by
        intro a x
        obtain rfl | ha := eq_or_ne a 0
        · rw [norm_zero, zero_mul, zero_smul]
          refine'
            cinfi_eq_of_forall_ge_of_forall_gt_exists_lt (fun i => by positivity) fun x hx =>
              ⟨0, by rwa [map_zero, sub_zero, map_zero, add_zero]⟩
          
        simp_rw [Real.mul_infi_of_nonneg (norm_nonneg a), mul_add, ← map_smul_eq_mul p, ← map_smul_eq_mul q, smul_sub]
        refine' Function.Surjective.infi_congr ((· • ·) a⁻¹ : E → E) (fun u => ⟨a • u, inv_smul_smul₀ ha u⟩) fun u => _
        rw [smul_inv_smul₀ ha] }

@[simp]
theorem inf_apply (p q : Seminorm 𝕜 E) (x : E) : (p ⊓ q) x = ⨅ u : E, p u + q (x - u) :=
  rfl

noncomputable instance : Lattice (Seminorm 𝕜 E) :=
  { Seminorm.semilatticeSup with inf := (· ⊓ ·),
    inf_le_left := fun p q x => cinfi_le_of_le bdd_below_range_add x <| by simp only [sub_self, map_zero, add_zero],
    inf_le_right := fun p q x =>
      cinfi_le_of_le bdd_below_range_add 0 <| by simp only [sub_self, map_zero, zero_add, sub_zero],
    le_inf := fun a b c hab hac x => le_cinfi fun u => (le_map_add_map_sub a _ _).trans <| add_le_add (hab _) (hac _) }

theorem smul_inf [HasSmul R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] (r : R) (p q : Seminorm 𝕜 E) :
    r • (p ⊓ q) = r • p ⊓ r • q := by
  ext
  simp_rw [smul_apply, inf_apply, smul_apply, ← smul_one_smul ℝ≥0 r (_ : ℝ), Nnreal.smul_def, smul_eq_mul,
    Real.mul_infi_of_nonneg (Subtype.prop _), mul_add]

section Classical

open Classical

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:66:14: unsupported tactic `congrm #[[expr «expr⨆ , »((i), _)]] -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:66:14: unsupported tactic `congrm #[[expr «expr⨆ , »((i), _)]] -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:66:14: unsupported tactic `congrm #[[expr «expr⨆ , »((i), _)]] -/
/-- We define the supremum of an arbitrary subset of `seminorm 𝕜 E` as follows:
* if `s` is `bdd_above` *as a set of functions `E → ℝ`* (that is, if `s` is pointwise bounded
above), we take the pointwise supremum of all elements of `s`, and we prove that it is indeed a
seminorm.
* otherwise, we take the zero seminorm `⊥`.

There are two things worth mentionning here:
* First, it is not trivial at first that `s` being bounded above *by a function* implies
being bounded above *as a seminorm*. We show this in `seminorm.bdd_above_iff` by using
that the `Sup s` as defined here is then a bounding seminorm for `s`. So it is important to make
the case disjunction on `bdd_above (coe_fn '' s : set (E → ℝ))` and not `bdd_above s`.
* Since the pointwise `Sup` already gives `0` at points where a family of functions is
not bounded above, one could hope that just using the pointwise `Sup` would work here, without the
need for an additional case disjunction. As discussed on Zulip, this doesn't work because this can
give a function which does *not* satisfy the seminorm axioms (typically sub-additivity).
-/
noncomputable instance :
    HasSup
      (Seminorm 𝕜
        E) where sup s :=
    if h : BddAbove (coeFn '' s : Set (E → ℝ)) then
      { toFun := ⨆ p : s, ((p : Seminorm 𝕜 E) : E → ℝ),
        map_zero' := by
          rw [supr_apply, ← @Real.csupr_const_zero s]
          trace
            "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:66:14: unsupported tactic `congrm #[[expr «expr⨆ , »((i), _)]]"
          exact map_zero i.1,
        add_le' := fun x y => by
          rcases h with ⟨q, hq⟩
          obtain rfl | h := s.eq_empty_or_nonempty
          · simp [Real.csupr_empty]
            
          haveI : Nonempty ↥s := h.coe_sort
          simp only [supr_apply]
          refine'
              csupr_le fun i =>
                ((i : Seminorm 𝕜 E).add_le' x y).trans <| add_le_add (le_csupr ⟨q x, _⟩ i) (le_csupr ⟨q y, _⟩ i) <;>
            rw [mem_upper_bounds, forall_range_iff] <;> exact fun j => hq (mem_image_of_mem _ j.2) _,
        neg' := fun x => by
          simp only [supr_apply]
          trace
            "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:66:14: unsupported tactic `congrm #[[expr «expr⨆ , »((i), _)]]"
          exact i.1.neg' _,
        smul' := fun a x => by
          simp only [supr_apply]
          rw [← smul_eq_mul, Real.smul_supr_of_nonneg (norm_nonneg a) fun i : s => (i : Seminorm 𝕜 E) x]
          trace
            "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:66:14: unsupported tactic `congrm #[[expr «expr⨆ , »((i), _)]]"
          exact i.1.smul' a x }
    else ⊥

protected theorem coe_Sup_eq' {s : Set <| Seminorm 𝕜 E} (hs : BddAbove (coeFn '' s : Set (E → ℝ))) :
    coeFn (sup s) = ⨆ p : s, p :=
  congr_arg _ (dif_pos hs)

protected theorem bdd_above_iff {s : Set <| Seminorm 𝕜 E} : BddAbove s ↔ BddAbove (coeFn '' s : Set (E → ℝ)) :=
  ⟨fun ⟨q, hq⟩ => ⟨q, ball_image_of_ball fun p hp => hq hp⟩, fun H =>
    ⟨sup s, fun p hp x => by
      rw [Seminorm.coe_Sup_eq' H, supr_apply]
      rcases H with ⟨q, hq⟩
      exact le_csupr ⟨q x, forall_range_iff.mpr fun i : s => hq (mem_image_of_mem _ i.2) x⟩ ⟨p, hp⟩⟩⟩

protected theorem coe_Sup_eq {s : Set <| Seminorm 𝕜 E} (hs : BddAbove s) : coeFn (sup s) = ⨆ p : s, p :=
  Seminorm.coe_Sup_eq' (Seminorm.bdd_above_iff.mp hs)

protected theorem coe_supr_eq {ι : Type _} {p : ι → Seminorm 𝕜 E} (hp : BddAbove (Range p)) :
    coeFn (⨆ i, p i) = ⨆ i, p i := by
  rw [← Sup_range, Seminorm.coe_Sup_eq hp] <;> exact supr_range' (coeFn : Seminorm 𝕜 E → E → ℝ) p

private theorem seminorm.is_lub_Sup (s : Set (Seminorm 𝕜 E)) (hs₁ : BddAbove s) (hs₂ : s.Nonempty) : IsLub s (sup s) :=
  by
  refine' ⟨fun p hp x => _, fun p hp x => _⟩ <;>
    haveI : Nonempty ↥s := hs₂.coe_sort <;> rw [Seminorm.coe_Sup_eq hs₁, supr_apply]
  · rcases hs₁ with ⟨q, hq⟩
    exact le_csupr ⟨q x, forall_range_iff.mpr fun i : s => hq i.2 x⟩ ⟨p, hp⟩
    
  · exact csupr_le fun q => hp q.2 x
    

/-- `seminorm 𝕜 E` is a conditionally complete lattice.

Note that, while `inf`, `sup` and `Sup` have good definitional properties (corresponding to
`seminorm.has_inf`, `seminorm.has_sup` and `seminorm.has_Sup` respectively), `Inf s` is just
defined as the supremum of the lower bounds of `s`, which is not really useful in practice. If you
need to use `Inf` on seminorms, then you should probably provide a more workable definition first,
but this is unlikely to happen so we keep the "bad" definition for now. -/
noncomputable instance : ConditionallyCompleteLattice (Seminorm 𝕜 E) :=
  conditionallyCompleteLatticeOfLatticeOfSup (Seminorm 𝕜 E) Seminorm.is_lub_Sup

end Classical

end NormedField

/-! ### Seminorm ball -/


section SemiNormedRing

variable [SemiNormedRing 𝕜]

section AddCommGroup

variable [AddCommGroup E]

section HasSmul

variable [HasSmul 𝕜 E] (p : Seminorm 𝕜 E)

/-- The ball of radius `r` at `x` with respect to seminorm `p` is the set of elements `y` with
`p (y - x) < r`. -/
def Ball (x : E) (r : ℝ) :=
  { y : E | p (y - x) < r }

/-- The closed ball of radius `r` at `x` with respect to seminorm `p` is the set of elements `y`
with `p (y - x) ≤ r`. -/
def ClosedBall (x : E) (r : ℝ) :=
  { y : E | p (y - x) ≤ r }

variable {x y : E} {r : ℝ}

@[simp]
theorem mem_ball : y ∈ Ball p x r ↔ p (y - x) < r :=
  Iff.rfl

@[simp]
theorem mem_closed_ball : y ∈ ClosedBall p x r ↔ p (y - x) ≤ r :=
  Iff.rfl

theorem mem_ball_self (hr : 0 < r) : x ∈ Ball p x r := by simp [hr]

theorem mem_closed_ball_self (hr : 0 ≤ r) : x ∈ ClosedBall p x r := by simp [hr]

theorem mem_ball_zero : y ∈ Ball p 0 r ↔ p y < r := by rw [mem_ball, sub_zero]

theorem mem_closed_ball_zero : y ∈ ClosedBall p 0 r ↔ p y ≤ r := by rw [mem_closed_ball, sub_zero]

theorem ball_zero_eq : Ball p 0 r = { y : E | p y < r } :=
  Set.ext fun x => p.mem_ball_zero

theorem closed_ball_zero_eq : ClosedBall p 0 r = { y : E | p y ≤ r } :=
  Set.ext fun x => p.mem_closed_ball_zero

theorem ball_subset_closed_ball (x r) : Ball p x r ⊆ ClosedBall p x r := fun y (hy : _ < _) => hy.le

theorem closed_ball_eq_bInter_ball (x r) : ClosedBall p x r = ⋂ ρ > r, Ball p x ρ := by
  ext y <;> simp_rw [mem_closed_ball, mem_Inter₂, mem_ball, ← forall_lt_iff_le']

@[simp]
theorem ball_zero' (x : E) (hr : 0 < r) : Ball (0 : Seminorm 𝕜 E) x r = Set.Univ := by
  rw [Set.eq_univ_iff_forall, ball]
  simp [hr]

@[simp]
theorem closed_ball_zero' (x : E) (hr : 0 < r) : ClosedBall (0 : Seminorm 𝕜 E) x r = Set.Univ :=
  eq_univ_of_subset (ball_subset_closed_ball _ _ _) (ball_zero' x hr)

theorem ball_smul (p : Seminorm 𝕜 E) {c : Nnreal} (hc : 0 < c) (r : ℝ) (x : E) : (c • p).ball x r = p.ball x (r / c) :=
  by
  ext
  rw [mem_ball, mem_ball, smul_apply, Nnreal.smul_def, smul_eq_mul, mul_comm, lt_div_iff (nnreal.coe_pos.mpr hc)]

theorem closed_ball_smul (p : Seminorm 𝕜 E) {c : Nnreal} (hc : 0 < c) (r : ℝ) (x : E) :
    (c • p).ClosedBall x r = p.ClosedBall x (r / c) := by
  ext
  rw [mem_closed_ball, mem_closed_ball, smul_apply, Nnreal.smul_def, smul_eq_mul, mul_comm,
    le_div_iff (nnreal.coe_pos.mpr hc)]

theorem ball_sup (p : Seminorm 𝕜 E) (q : Seminorm 𝕜 E) (e : E) (r : ℝ) : Ball (p ⊔ q) e r = Ball p e r ∩ Ball q e r :=
  by simp_rw [ball, ← Set.set_of_and, coe_sup, Pi.sup_apply, sup_lt_iff]

theorem closed_ball_sup (p : Seminorm 𝕜 E) (q : Seminorm 𝕜 E) (e : E) (r : ℝ) :
    ClosedBall (p ⊔ q) e r = ClosedBall p e r ∩ ClosedBall q e r := by
  simp_rw [closed_ball, ← Set.set_of_and, coe_sup, Pi.sup_apply, sup_le_iff]

theorem ball_finset_sup' (p : ι → Seminorm 𝕜 E) (s : Finset ι) (H : s.Nonempty) (e : E) (r : ℝ) :
    Ball (s.sup' H p) e r = s.inf' H fun i => Ball (p i) e r := by
  induction' H using Finset.Nonempty.cons_induction with a a s ha hs ih
  · classical
    simp
    
  · rw [Finset.sup'_cons hs, Finset.inf'_cons hs, ball_sup, inf_eq_inter, ih]
    

theorem closed_ball_finset_sup' (p : ι → Seminorm 𝕜 E) (s : Finset ι) (H : s.Nonempty) (e : E) (r : ℝ) :
    ClosedBall (s.sup' H p) e r = s.inf' H fun i => ClosedBall (p i) e r := by
  induction' H using Finset.Nonempty.cons_induction with a a s ha hs ih
  · classical
    simp
    
  · rw [Finset.sup'_cons hs, Finset.inf'_cons hs, closed_ball_sup, inf_eq_inter, ih]
    

theorem ball_mono {p : Seminorm 𝕜 E} {r₁ r₂ : ℝ} (h : r₁ ≤ r₂) : p.ball x r₁ ⊆ p.ball x r₂ := fun _ (hx : _ < _) =>
  hx.trans_le h

theorem closed_ball_mono {p : Seminorm 𝕜 E} {r₁ r₂ : ℝ} (h : r₁ ≤ r₂) : p.ClosedBall x r₁ ⊆ p.ClosedBall x r₂ :=
  fun _ (hx : _ ≤ _) => hx.trans h

theorem ball_antitone {p q : Seminorm 𝕜 E} (h : q ≤ p) : p.ball x r ⊆ q.ball x r := fun _ => (h _).trans_lt

theorem closed_ball_antitone {p q : Seminorm 𝕜 E} (h : q ≤ p) : p.ClosedBall x r ⊆ q.ClosedBall x r := fun _ =>
  (h _).trans

theorem ball_add_ball_subset (p : Seminorm 𝕜 E) (r₁ r₂ : ℝ) (x₁ x₂ : E) :
    p.ball (x₁ : E) r₁ + p.ball (x₂ : E) r₂ ⊆ p.ball (x₁ + x₂) (r₁ + r₂) := by
  rintro x ⟨y₁, y₂, hy₁, hy₂, rfl⟩
  rw [mem_ball, add_sub_add_comm]
  exact (map_add_le_add p _ _).trans_lt (add_lt_add hy₁ hy₂)

theorem closed_ball_add_closed_ball_subset (p : Seminorm 𝕜 E) (r₁ r₂ : ℝ) (x₁ x₂ : E) :
    p.ClosedBall (x₁ : E) r₁ + p.ClosedBall (x₂ : E) r₂ ⊆ p.ClosedBall (x₁ + x₂) (r₁ + r₂) := by
  rintro x ⟨y₁, y₂, hy₁, hy₂, rfl⟩
  rw [mem_closed_ball, add_sub_add_comm]
  exact (map_add_le_add p _ _).trans (add_le_add hy₁ hy₂)

end HasSmul

section Module

variable [Module 𝕜 E]

variable [SemiNormedRing 𝕜₂] [AddCommGroup E₂] [Module 𝕜₂ E₂]

variable {σ₁₂ : 𝕜 →+* 𝕜₂} [RingHomIsometric σ₁₂]

theorem ball_comp (p : Seminorm 𝕜₂ E₂) (f : E →ₛₗ[σ₁₂] E₂) (x : E) (r : ℝ) :
    (p.comp f).ball x r = f ⁻¹' p.ball (f x) r := by
  ext
  simp_rw [ball, mem_preimage, comp_apply, Set.mem_set_of_eq, map_sub]

theorem closed_ball_comp (p : Seminorm 𝕜₂ E₂) (f : E →ₛₗ[σ₁₂] E₂) (x : E) (r : ℝ) :
    (p.comp f).ClosedBall x r = f ⁻¹' p.ClosedBall (f x) r := by
  ext
  simp_rw [closed_ball, mem_preimage, comp_apply, Set.mem_set_of_eq, map_sub]

variable (p : Seminorm 𝕜 E)

theorem preimage_metric_ball {r : ℝ} : p ⁻¹' Metric.Ball 0 r = { x | p x < r } := by
  ext x
  simp only [mem_set_of, mem_preimage, mem_ball_zero_iff, Real.norm_of_nonneg (map_nonneg p _)]

theorem preimage_metric_closed_ball {r : ℝ} : p ⁻¹' Metric.ClosedBall 0 r = { x | p x ≤ r } := by
  ext x
  simp only [mem_set_of, mem_preimage, mem_closed_ball_zero_iff, Real.norm_of_nonneg (map_nonneg p _)]

theorem ball_zero_eq_preimage_ball {r : ℝ} : p.ball 0 r = p ⁻¹' Metric.Ball 0 r := by
  rw [ball_zero_eq, preimage_metric_ball]

theorem closed_ball_zero_eq_preimage_closed_ball {r : ℝ} : p.ClosedBall 0 r = p ⁻¹' Metric.ClosedBall 0 r := by
  rw [closed_ball_zero_eq, preimage_metric_closed_ball]

@[simp]
theorem ball_bot {r : ℝ} (x : E) (hr : 0 < r) : Ball (⊥ : Seminorm 𝕜 E) x r = Set.Univ :=
  ball_zero' x hr

@[simp]
theorem closed_ball_bot {r : ℝ} (x : E) (hr : 0 < r) : ClosedBall (⊥ : Seminorm 𝕜 E) x r = Set.Univ :=
  closed_ball_zero' x hr

/-- Seminorm-balls at the origin are balanced. -/
theorem balancedBallZero (r : ℝ) : Balanced 𝕜 (Ball p 0 r) := by
  rintro a ha x ⟨y, hy, hx⟩
  rw [mem_ball_zero, ← hx, map_smul_eq_mul]
  calc
    _ ≤ p y := mul_le_of_le_one_left (map_nonneg p _) ha
    _ < r := by rwa [mem_ball_zero] at hy
    

/-- Closed seminorm-balls at the origin are balanced. -/
theorem balancedClosedBallZero (r : ℝ) : Balanced 𝕜 (ClosedBall p 0 r) := by
  rintro a ha x ⟨y, hy, hx⟩
  rw [mem_closed_ball_zero, ← hx, map_smul_eq_mul]
  calc
    _ ≤ p y := mul_le_of_le_one_left (map_nonneg p _) ha
    _ ≤ r := by rwa [mem_closed_ball_zero] at hy
    

theorem ball_finset_sup_eq_Inter (p : ι → Seminorm 𝕜 E) (s : Finset ι) (x : E) {r : ℝ} (hr : 0 < r) :
    Ball (s.sup p) x r = ⋂ i ∈ s, Ball (p i) x r := by
  lift r to Nnreal using hr.le
  simp_rw [ball, Inter_set_of, finset_sup_apply, Nnreal.coe_lt_coe, Finset.sup_lt_iff (show ⊥ < r from hr), ←
    Nnreal.coe_lt_coe, Subtype.coe_mk]

theorem closed_ball_finset_sup_eq_Inter (p : ι → Seminorm 𝕜 E) (s : Finset ι) (x : E) {r : ℝ} (hr : 0 ≤ r) :
    ClosedBall (s.sup p) x r = ⋂ i ∈ s, ClosedBall (p i) x r := by
  lift r to Nnreal using hr
  simp_rw [closed_ball, Inter_set_of, finset_sup_apply, Nnreal.coe_le_coe, Finset.sup_le_iff, ← Nnreal.coe_le_coe,
    Subtype.coe_mk]

theorem ball_finset_sup (p : ι → Seminorm 𝕜 E) (s : Finset ι) (x : E) {r : ℝ} (hr : 0 < r) :
    Ball (s.sup p) x r = s.inf fun i => Ball (p i) x r := by
  rw [Finset.inf_eq_infi]
  exact ball_finset_sup_eq_Inter _ _ _ hr

theorem closed_ball_finset_sup (p : ι → Seminorm 𝕜 E) (s : Finset ι) (x : E) {r : ℝ} (hr : 0 ≤ r) :
    ClosedBall (s.sup p) x r = s.inf fun i => ClosedBall (p i) x r := by
  rw [Finset.inf_eq_infi]
  exact closed_ball_finset_sup_eq_Inter _ _ _ hr

theorem ball_smul_ball (p : Seminorm 𝕜 E) (r₁ r₂ : ℝ) : Metric.Ball (0 : 𝕜) r₁ • p.ball 0 r₂ ⊆ p.ball 0 (r₁ * r₂) := by
  rw [Set.subset_def]
  intro x hx
  rw [Set.mem_smul] at hx
  rcases hx with ⟨a, y, ha, hy, hx⟩
  rw [← hx, mem_ball_zero, map_smul_eq_mul]
  exact mul_lt_mul'' (mem_ball_zero_iff.mp ha) (p.mem_ball_zero.mp hy) (norm_nonneg a) (map_nonneg p y)

theorem closed_ball_smul_closed_ball (p : Seminorm 𝕜 E) (r₁ r₂ : ℝ) :
    Metric.ClosedBall (0 : 𝕜) r₁ • p.ClosedBall 0 r₂ ⊆ p.ClosedBall 0 (r₁ * r₂) := by
  rw [Set.subset_def]
  intro x hx
  rw [Set.mem_smul] at hx
  rcases hx with ⟨a, y, ha, hy, hx⟩
  rw [← hx, mem_closed_ball_zero, map_smul_eq_mul]
  rw [mem_closed_ball_zero_iff] at ha
  exact mul_le_mul ha (p.mem_closed_ball_zero.mp hy) (map_nonneg _ y) ((norm_nonneg a).trans ha)

@[simp]
theorem ball_eq_emptyset (p : Seminorm 𝕜 E) {x : E} {r : ℝ} (hr : r ≤ 0) : p.ball x r = ∅ := by
  ext
  rw [Seminorm.mem_ball, Set.mem_empty_iff_false, iff_false_iff, not_lt]
  exact hr.trans (map_nonneg p _)

@[simp]
theorem closed_ball_eq_emptyset (p : Seminorm 𝕜 E) {x : E} {r : ℝ} (hr : r < 0) : p.ClosedBall x r = ∅ := by
  ext
  rw [Seminorm.mem_closed_ball, Set.mem_empty_iff_false, iff_false_iff, not_le]
  exact hr.trans_le (map_nonneg _ _)

end Module

end AddCommGroup

end SemiNormedRing

section NormedField

variable [NormedField 𝕜] [AddCommGroup E] [Module 𝕜 E] (p : Seminorm 𝕜 E) {A B : Set E} {a : 𝕜} {r : ℝ} {x : E}

theorem smul_ball_zero {p : Seminorm 𝕜 E} {k : 𝕜} {r : ℝ} (hk : 0 < ∥k∥) : k • p.ball 0 r = p.ball 0 (∥k∥ * r) := by
  ext
  rw [Set.mem_smul_set, Seminorm.mem_ball_zero]
  constructor <;> intro h
  · rcases h with ⟨y, hy, h⟩
    rw [← h, map_smul_eq_mul]
    rw [Seminorm.mem_ball_zero] at hy
    exact (mul_lt_mul_left hk).mpr hy
    
  refine' ⟨k⁻¹ • x, _, _⟩
  · rw [Seminorm.mem_ball_zero, map_smul_eq_mul, norm_inv, ← mul_lt_mul_left hk, ← mul_assoc, ← div_eq_mul_inv ∥k∥ ∥k∥,
      div_self (ne_of_gt hk), one_mul]
    exact h
    
  rw [← smul_assoc, smul_eq_mul, ← div_eq_mul_inv, div_self (norm_pos_iff.mp hk), one_smul]

theorem ballZeroAbsorbsBallZero (p : Seminorm 𝕜 E) {r₁ r₂ : ℝ} (hr₁ : 0 < r₁) : Absorbs 𝕜 (p.ball 0 r₁) (p.ball 0 r₂) :=
  by
  by_cases hr₂:r₂ ≤ 0
  · rw [ball_eq_emptyset p hr₂]
    exact absorbsEmpty
    
  rw [not_le] at hr₂
  rcases exists_between hr₁ with ⟨r, hr, hr'⟩
  refine' ⟨r₂ / r, div_pos hr₂ hr, _⟩
  simp_rw [Set.subset_def]
  intro a ha x hx
  have ha' : 0 < ∥a∥ := lt_of_lt_of_le (div_pos hr₂ hr) ha
  rw [smul_ball_zero ha', p.mem_ball_zero]
  rw [p.mem_ball_zero] at hx
  rw [div_le_iff hr] at ha
  exact hx.trans (lt_of_le_of_lt ha ((mul_lt_mul_left ha').mpr hr'))

/-- Seminorm-balls at the origin are absorbent. -/
protected theorem absorbentBallZero (hr : 0 < r) : Absorbent 𝕜 (Ball p (0 : E) r) := by
  rw [absorbent_iff_nonneg_lt]
  rintro x
  have hxr : 0 ≤ p x / r := by positivity
  refine' ⟨p x / r, hxr, fun a ha => _⟩
  have ha₀ : 0 < ∥a∥ := hxr.trans_lt ha
  refine' ⟨a⁻¹ • x, _, smul_inv_smul₀ (norm_pos_iff.1 ha₀) x⟩
  rwa [mem_ball_zero, map_smul_eq_mul, norm_inv, inv_mul_lt_iff ha₀, ← div_lt_iff hr]

/-- Closed seminorm-balls at the origin are absorbent. -/
protected theorem absorbentClosedBallZero (hr : 0 < r) : Absorbent 𝕜 (ClosedBall p (0 : E) r) :=
  (p.absorbentBallZero hr).Subset (p.ball_subset_closed_ball _ _)

/-- Seminorm-balls containing the origin are absorbent. -/
protected theorem absorbentBall (hpr : p x < r) : Absorbent 𝕜 (Ball p x r) := by
  refine' (p.absorbent_ball_zero <| sub_pos.2 hpr).Subset fun y hy => _
  rw [p.mem_ball_zero] at hy
  exact p.mem_ball.2 ((map_sub_le_add p _ _).trans_lt <| add_lt_of_lt_sub_right hy)

/-- Seminorm-balls containing the origin are absorbent. -/
protected theorem absorbentClosedBall (hpr : p x < r) : Absorbent 𝕜 (ClosedBall p x r) := by
  refine' (p.absorbent_closed_ball_zero <| sub_pos.2 hpr).Subset fun y hy => _
  rw [p.mem_closed_ball_zero] at hy
  exact p.mem_closed_ball.2 ((map_sub_le_add p _ _).trans <| add_le_of_le_sub_right hy)

theorem symmetric_ball_zero (r : ℝ) (hx : x ∈ Ball p 0 r) : -x ∈ Ball p 0 r :=
  balancedBallZero p r (-1) (by rw [norm_neg, norm_one]) ⟨x, hx, by rw [neg_smul, one_smul]⟩

@[simp]
theorem neg_ball (p : Seminorm 𝕜 E) (r : ℝ) (x : E) : -Ball p x r = Ball p (-x) r := by
  ext
  rw [mem_neg, mem_ball, mem_ball, ← neg_add', sub_neg_eq_add, map_neg_eq_map]

@[simp]
theorem smul_ball_preimage (p : Seminorm 𝕜 E) (y : E) (r : ℝ) (a : 𝕜) (ha : a ≠ 0) :
    (· • ·) a ⁻¹' p.ball y r = p.ball (a⁻¹ • y) (r / ∥a∥) :=
  Set.ext fun _ => by
    rw [mem_preimage, mem_ball, mem_ball, lt_div_iff (norm_pos_iff.mpr ha), mul_comm, ← map_smul_eq_mul p, smul_sub,
      smul_inv_smul₀ ha]

end NormedField

section Convex

variable [NormedField 𝕜] [AddCommGroup E] [NormedSpace ℝ 𝕜] [Module 𝕜 E]

section HasSmul

variable [HasSmul ℝ E] [IsScalarTower ℝ 𝕜 E] (p : Seminorm 𝕜 E)

/-- A seminorm is convex. Also see `convex_on_norm`. -/
protected theorem convex_on : ConvexOn ℝ Univ p := by
  refine' ⟨convex_univ, fun x _ y _ a b ha hb hab => _⟩
  calc
    p (a • x + b • y) ≤ p (a • x) + p (b • y) := map_add_le_add p _ _
    _ = ∥a • (1 : 𝕜)∥ * p x + ∥b • (1 : 𝕜)∥ * p y := by
      rw [← map_smul_eq_mul p, ← map_smul_eq_mul p, smul_one_smul, smul_one_smul]
    _ = a * p x + b * p y := by
      rw [norm_smul, norm_smul, norm_one, mul_one, mul_one, Real.norm_of_nonneg ha, Real.norm_of_nonneg hb]
    

end HasSmul

section Module

variable [Module ℝ E] [IsScalarTower ℝ 𝕜 E] (p : Seminorm 𝕜 E) (x : E) (r : ℝ)

/-- Seminorm-balls are convex. -/
theorem convex_ball : Convex ℝ (Ball p x r) := by
  convert (p.convex_on.translate_left (-x)).convex_lt r
  ext y
  rw [preimage_univ, sep_univ, p.mem_ball, sub_eq_add_neg]
  rfl

/-- Closed seminorm-balls are convex. -/
theorem convex_closed_ball : Convex ℝ (ClosedBall p x r) := by
  rw [closed_ball_eq_bInter_ball]
  exact convex_Inter₂ fun _ _ => convex_ball _ _ _

end Module

end Convex

section RestrictScalars

variable (𝕜) {𝕜' : Type _} [NormedField 𝕜] [SemiNormedRing 𝕜'] [NormedAlgebra 𝕜 𝕜'] [NormOneClass 𝕜'] [AddCommGroup E]
  [Module 𝕜' E] [HasSmul 𝕜 E] [IsScalarTower 𝕜 𝕜' E]

/-- Reinterpret a seminorm over a field `𝕜'` as a seminorm over a smaller field `𝕜`. This will
typically be used with `is_R_or_C 𝕜'` and `𝕜 = ℝ`. -/
protected def restrictScalars (p : Seminorm 𝕜' E) : Seminorm 𝕜 E :=
  { p with smul' := fun a x => by rw [← smul_one_smul 𝕜' a x, p.smul', norm_smul, norm_one, mul_one] }

@[simp]
theorem coe_restrict_scalars (p : Seminorm 𝕜' E) : (p.restrictScalars 𝕜 : E → ℝ) = p :=
  rfl

@[simp]
theorem restrict_scalars_ball (p : Seminorm 𝕜' E) : (p.restrictScalars 𝕜).ball = p.ball :=
  rfl

end RestrictScalars

/-! ### Continuity criterions for seminorms -/


section Continuity

variable [SemiNormedRing 𝕜] [AddCommGroup E] [Module 𝕜 E]

theorem continuous_at_zero [NormOneClass 𝕜] [NormedAlgebra ℝ 𝕜] [Module ℝ E] [IsScalarTower ℝ 𝕜 E] [TopologicalSpace E]
    [HasContinuousConstSmul ℝ E] {p : Seminorm 𝕜 E} (hp : p.ball 0 1 ∈ (𝓝 0 : Filter E)) : ContinuousAt p 0 := by
  change ContinuousAt (p.restrict_scalars ℝ) 0
  rw [← p.restrict_scalars_ball ℝ] at hp
  refine' metric.nhds_basis_ball.tendsto_right_iff.mpr _
  intro ε hε
  rw [map_zero]
  suffices (p.restrict_scalars ℝ).ball 0 ε ∈ (𝓝 0 : Filter E) by rwa [Seminorm.ball_zero_eq_preimage_ball] at this
  have := (set_smul_mem_nhds_zero_iff hε.ne.symm).mpr hp
  rwa [Seminorm.smul_ball_zero (norm_pos_iff.mpr hε.ne.symm), Real.norm_of_nonneg hε.le, mul_one] at this

protected theorem uniform_continuous_of_continuous_at_zero [UniformSpace E] [UniformAddGroup E] {p : Seminorm 𝕜 E}
    (hp : ContinuousAt p 0) : UniformContinuous p := by
  have hp : Filter.Tendsto p (𝓝 0) (𝓝 0) := map_zero p ▸ hp
  rw [UniformContinuous, uniformity_eq_comap_nhds_zero_swapped, Metric.uniformity_eq_comap_nhds_zero,
    Filter.tendsto_comap_iff]
  exact
    tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds (hp.comp Filter.tendsto_comap) (fun xy => dist_nonneg)
      fun xy => p.norm_sub_map_le_sub _ _

protected theorem continuous_of_continuous_at_zero [TopologicalSpace E] [TopologicalAddGroup E] {p : Seminorm 𝕜 E}
    (hp : ContinuousAt p 0) : Continuous p := by
  letI := TopologicalAddGroup.toUniformSpace E
  haveI : UniformAddGroup E := topological_add_comm_group_is_uniform
  exact (Seminorm.uniform_continuous_of_continuous_at_zero hp).Continuous

protected theorem uniform_continuous [NormOneClass 𝕜] [NormedAlgebra ℝ 𝕜] [Module ℝ E] [IsScalarTower ℝ 𝕜 E]
    [UniformSpace E] [UniformAddGroup E] [HasContinuousConstSmul ℝ E] {p : Seminorm 𝕜 E}
    (hp : p.ball 0 1 ∈ (𝓝 0 : Filter E)) : UniformContinuous p :=
  Seminorm.uniform_continuous_of_continuous_at_zero (continuous_at_zero hp)

protected theorem continuous [NormOneClass 𝕜] [NormedAlgebra ℝ 𝕜] [Module ℝ E] [IsScalarTower ℝ 𝕜 E]
    [TopologicalSpace E] [TopologicalAddGroup E] [HasContinuousConstSmul ℝ E] {p : Seminorm 𝕜 E}
    (hp : p.ball 0 1 ∈ (𝓝 0 : Filter E)) : Continuous p :=
  Seminorm.continuous_of_continuous_at_zero (continuous_at_zero hp)

theorem continuous_of_le [NormOneClass 𝕜] [NormedAlgebra ℝ 𝕜] [Module ℝ E] [IsScalarTower ℝ 𝕜 E] [TopologicalSpace E]
    [TopologicalAddGroup E] [HasContinuousConstSmul ℝ E] {p q : Seminorm 𝕜 E} (hq : Continuous q) (hpq : p ≤ q) :
    Continuous p := by
  refine'
    Seminorm.continuous (Filter.mem_of_superset (IsOpen.mem_nhds _ <| q.mem_ball_self zero_lt_one) (ball_antitone hpq))
  rw [ball_zero_eq]
  exact is_open_lt hq continuous_const

end Continuity

end Seminorm

/-! ### The norm as a seminorm -/


section normSeminorm

variable (𝕜) (E) [NormedField 𝕜] [SeminormedAddCommGroup E] [NormedSpace 𝕜 E] {r : ℝ}

/-- The norm of a seminormed group as a seminorm. -/
def normSeminorm : Seminorm 𝕜 E :=
  { normAddGroupSeminorm E with smul' := norm_smul }

@[simp]
theorem coe_norm_seminorm : ⇑(normSeminorm 𝕜 E) = norm :=
  rfl

@[simp]
theorem ball_norm_seminorm : (normSeminorm 𝕜 E).ball = Metric.Ball := by
  ext (x r y)
  simp only [Seminorm.mem_ball, Metric.mem_ball, coe_norm_seminorm, dist_eq_norm]

variable {𝕜 E} {x : E}

/-- Balls at the origin are absorbent. -/
theorem absorbentBallZero (hr : 0 < r) : Absorbent 𝕜 (Metric.Ball (0 : E) r) := by
  rw [← ball_norm_seminorm 𝕜]
  exact (normSeminorm _ _).absorbentBallZero hr

/-- Balls containing the origin are absorbent. -/
theorem absorbentBall (hx : ∥x∥ < r) : Absorbent 𝕜 (Metric.Ball x r) := by
  rw [← ball_norm_seminorm 𝕜]
  exact (normSeminorm _ _).absorbentBall hx

/-- Balls at the origin are balanced. -/
theorem balancedBallZero : Balanced 𝕜 (Metric.Ball (0 : E) r) := by
  rw [← ball_norm_seminorm 𝕜]
  exact (normSeminorm _ _).balancedBallZero r

end normSeminorm

