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

variable {R R' 𝕜 E F G ι : Type _}

/-- A seminorm on a module over a normed ring is a function to the reals that is positive
semidefinite, positive homogeneous, and subadditive. -/
structure Seminorm (𝕜 : Type _) (E : Type _) [SemiNormedRing 𝕜] [AddGroupₓ E] [HasSmul 𝕜 E] extends
  AddGroupSeminorm E where
  smul' : ∀ (a : 𝕜) (x : E), to_fun (a • x) = ∥a∥ * to_fun x

attribute [nolint doc_blame] Seminorm.toAddGroupSeminorm

/-- `seminorm_class F 𝕜 E` states that `F` is a type of seminorms on the `𝕜`-module E.

You should extend this class when you extend `seminorm`. -/
class SeminormClass (F : Type _) (𝕜 E : outParam <| Type _) [SemiNormedRing 𝕜] [AddGroupₓ E] [HasSmul 𝕜 E] extends
  AddGroupSeminormClass F E where
  map_smul_eq_mul (f : F) (a : 𝕜) (x : E) : f (a • x) = ∥a∥ * f x

export SeminormClass (map_smul_eq_mul)

-- `𝕜` is an `out_param`, so this is a false positive.
attribute [nolint dangerous_instance] SeminormClass.toAddGroupSeminormClass

section Of

/-- Alternative constructor for a `seminorm` on an `add_comm_group E` that is a module over a
`semi_norm_ring 𝕜`. -/
def Seminorm.of [SemiNormedRing 𝕜] [AddCommGroupₓ E] [Module 𝕜 E] (f : E → ℝ)
    (add_le : ∀ x y : E, f (x + y) ≤ f x + f y) (smul : ∀ (a : 𝕜) (x : E), f (a • x) = ∥a∥ * f x) : Seminorm 𝕜 E where
  toFun := f
  map_zero' := by
    rw [← zero_smul 𝕜 (0 : E), smul, norm_zero, zero_mul]
  add_le' := add_le
  smul' := smul
  neg' := fun x => by
    rw [← neg_one_smul 𝕜, smul, norm_neg, ← smul, one_smul]

/-- Alternative constructor for a `seminorm` over a normed field `𝕜` that only assumes `f 0 = 0`
and an inequality for the scalar multiplication. -/
def Seminorm.ofSmulLe [NormedField 𝕜] [AddCommGroupₓ E] [Module 𝕜 E] (f : E → ℝ) (map_zero : f 0 = 0)
    (add_le : ∀ x y, f (x + y) ≤ f x + f y) (smul_le : ∀ (r : 𝕜) (x), f (r • x) ≤ ∥r∥ * f x) : Seminorm 𝕜 E :=
  Seminorm.of f add_le fun r x => by
    refine' le_antisymmₓ (smul_le r x) _
    by_cases' r = 0
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

section AddGroupₓ

variable [AddGroupₓ E]

section HasSmul

variable [HasSmul 𝕜 E]

instance seminormClass : SeminormClass (Seminorm 𝕜 E) 𝕜 E where
  coe := fun f => f.toFun
  coe_injective' := fun f g h => by
    cases f <;> cases g <;> congr
  map_zero := fun f => f.map_zero'
  map_add_le_add := fun f => f.add_le'
  map_neg_eq_map := fun f => f.neg'
  map_smul_eq_mul := fun f => f.smul'

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
      (Seminorm 𝕜
        E) where smul := fun r p =>
    { r • p.toAddGroupSeminorm with toFun := fun x => r • p x,
      smul' := fun _ _ => by
        simp only [← smul_one_smul ℝ≥0 r (_ : ℝ), Nnreal.smul_def, smul_eq_mul]
        rw [map_smul_eq_mul, mul_left_commₓ] }

instance [HasSmul R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] [HasSmul R' ℝ] [HasSmul R' ℝ≥0] [IsScalarTower R' ℝ≥0 ℝ]
    [HasSmul R R'] [IsScalarTower R R' ℝ] :
    IsScalarTower R R' (Seminorm 𝕜 E) where smul_assoc := fun r a p => ext fun x => smul_assoc r a (p x)

theorem coe_smul [HasSmul R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] (r : R) (p : Seminorm 𝕜 E) : ⇑(r • p) = r • p :=
  rfl

@[simp]
theorem smul_apply [HasSmul R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] (r : R) (p : Seminorm 𝕜 E) (x : E) :
    (r • p) x = r • p x :=
  rfl

instance :
    Add
      (Seminorm 𝕜
        E) where add := fun p q =>
    { p.toAddGroupSeminorm + q.toAddGroupSeminorm with toFun := fun x => p x + q x,
      smul' := fun a x => by
        simp only [map_smul_eq_mul, map_smul_eq_mul, mul_addₓ] }

theorem coe_add (p q : Seminorm 𝕜 E) : ⇑(p + q) = p + q :=
  rfl

@[simp]
theorem add_apply (p q : Seminorm 𝕜 E) (x : E) : (p + q) x = p x + q x :=
  rfl

instance : AddMonoidₓ (Seminorm 𝕜 E) :=
  FunLike.coe_injective.AddMonoid _ rfl coe_add fun p n => coe_smul n p

instance : OrderedCancelAddCommMonoid (Seminorm 𝕜 E) :=
  FunLike.coe_injective.OrderedCancelAddCommMonoid _ rfl coe_add fun p n => coe_smul n p

instance [Monoidₓ R] [MulAction R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] : MulAction R (Seminorm 𝕜 E) :=
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

instance [Monoidₓ R] [DistribMulAction R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] :
    DistribMulAction R (Seminorm 𝕜 E) :=
  (coe_fn_add_monoid_hom_injective 𝕜 E).DistribMulAction _ coe_smul

instance [Semiringₓ R] [Module R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] : Module R (Seminorm 𝕜 E) :=
  (coe_fn_add_monoid_hom_injective 𝕜 E).Module R _ coe_smul

-- TODO: define `has_Sup` too, from the skeleton at
-- https://github.com/leanprover-community/mathlib/pull/11329#issuecomment-1008915345
noncomputable instance :
    HasSup
      (Seminorm 𝕜
        E) where sup := fun p q =>
    { p.toAddGroupSeminorm ⊔ q.toAddGroupSeminorm with toFun := p ⊔ q,
      smul' := fun x v =>
        (congr_arg2ₓ max (map_smul_eq_mul p x v) (map_smul_eq_mul q x v)).trans <|
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

instance : PartialOrderₓ (Seminorm 𝕜 E) :=
  PartialOrderₓ.lift _ FunLike.coe_injective

theorem le_def (p q : Seminorm 𝕜 E) : p ≤ q ↔ (p : E → ℝ) ≤ q :=
  Iff.rfl

theorem lt_def (p q : Seminorm 𝕜 E) : p < q ↔ (p : E → ℝ) < q :=
  Iff.rfl

noncomputable instance : SemilatticeSup (Seminorm 𝕜 E) :=
  Function.Injective.semilatticeSup _ FunLike.coe_injective coe_sup

end HasSmul

end AddGroupₓ

section Module

variable [AddCommGroupₓ E] [AddCommGroupₓ F] [AddCommGroupₓ G]

variable [Module 𝕜 E] [Module 𝕜 F] [Module 𝕜 G]

variable [HasSmul R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ]

/-- Composition of a seminorm with a linear map is a seminorm. -/
def comp (p : Seminorm 𝕜 F) (f : E →ₗ[𝕜] F) : Seminorm 𝕜 E :=
  { p.toAddGroupSeminorm.comp f.toAddMonoidHom with toFun := fun x => p (f x),
    smul' := fun _ _ => (congr_arg p (f.map_smul _ _)).trans (map_smul_eq_mul p _ _) }

theorem coe_comp (p : Seminorm 𝕜 F) (f : E →ₗ[𝕜] F) : ⇑(p.comp f) = p ∘ f :=
  rfl

@[simp]
theorem comp_apply (p : Seminorm 𝕜 F) (f : E →ₗ[𝕜] F) (x : E) : (p.comp f) x = p (f x) :=
  rfl

@[simp]
theorem comp_id (p : Seminorm 𝕜 E) : p.comp LinearMap.id = p :=
  ext fun _ => rfl

@[simp]
theorem comp_zero (p : Seminorm 𝕜 F) : p.comp (0 : E →ₗ[𝕜] F) = 0 :=
  ext fun _ => map_zero p

@[simp]
theorem zero_comp (f : E →ₗ[𝕜] F) : (0 : Seminorm 𝕜 F).comp f = 0 :=
  ext fun _ => rfl

theorem comp_comp (p : Seminorm 𝕜 G) (g : F →ₗ[𝕜] G) (f : E →ₗ[𝕜] F) : p.comp (g.comp f) = (p.comp g).comp f :=
  ext fun _ => rfl

theorem add_comp (p q : Seminorm 𝕜 F) (f : E →ₗ[𝕜] F) : (p + q).comp f = p.comp f + q.comp f :=
  ext fun _ => rfl

theorem comp_add_le (p : Seminorm 𝕜 F) (f g : E →ₗ[𝕜] F) : p.comp (f + g) ≤ p.comp f + p.comp g := fun _ =>
  map_add_le_add p _ _

theorem smul_comp (p : Seminorm 𝕜 F) (f : E →ₗ[𝕜] F) (c : R) : (c • p).comp f = c • p.comp f :=
  ext fun _ => rfl

theorem comp_mono {p : Seminorm 𝕜 F} {q : Seminorm 𝕜 F} (f : E →ₗ[𝕜] F) (hp : p ≤ q) : p.comp f ≤ q.comp f := fun _ =>
  hp _

/-- The composition as an `add_monoid_hom`. -/
@[simps]
def pullback (f : E →ₗ[𝕜] F) : Seminorm 𝕜 F →+ Seminorm 𝕜 E :=
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
    

end Module

end SemiNormedRing

section SemiNormedCommRing

variable [SemiNormedCommRing 𝕜] [AddCommGroupₓ E] [AddCommGroupₓ F] [Module 𝕜 E] [Module 𝕜 F]

theorem comp_smul (p : Seminorm 𝕜 F) (f : E →ₗ[𝕜] F) (c : 𝕜) : p.comp (c • f) = ∥c∥₊ • p.comp f :=
  ext fun _ => by
    rw [comp_apply, smul_apply, LinearMap.smul_apply, map_smul_eq_mul, Nnreal.smul_def, coe_nnnorm, smul_eq_mul,
      comp_apply]

theorem comp_smul_apply (p : Seminorm 𝕜 F) (f : E →ₗ[𝕜] F) (c : 𝕜) (x : E) : p.comp (c • f) x = ∥c∥ * p (f x) :=
  map_smul_eq_mul p _ _

end SemiNormedCommRing

section NormedField

variable [NormedField 𝕜] [AddCommGroupₓ E] [Module 𝕜 E] {p q : Seminorm 𝕜 E} {x : E}

/-- Auxiliary lemma to show that the infimum of seminorms is well-defined. -/
theorem bdd_below_range_add : BddBelow (range fun u => p u + q (x - u)) :=
  ⟨0, by
    rintro _ ⟨x, rfl⟩
    exact add_nonneg (map_nonneg p _) (map_nonneg q _)⟩

noncomputable instance :
    HasInf
      (Seminorm 𝕜
        E) where inf := fun p q =>
    { p.toAddGroupSeminorm ⊓ q.toAddGroupSeminorm with toFun := fun x => ⨅ u : E, p u + q (x - u),
      smul' := by
        intro a x
        obtain rfl | ha := eq_or_ne a 0
        · rw [norm_zero, zero_mul, zero_smul]
          refine'
            cinfi_eq_of_forall_ge_of_forall_gt_exists_lt (fun i => add_nonneg (map_nonneg p _) (map_nonneg q _))
              fun x hx =>
              ⟨0, by
                rwa [map_zero, sub_zero, map_zero, add_zeroₓ]⟩
          
        simp_rw [Real.mul_infi_of_nonneg (norm_nonneg a), mul_addₓ, ← map_smul_eq_mul p, ← map_smul_eq_mul q, smul_sub]
        refine' Function.Surjective.infi_congr ((· • ·) a⁻¹ : E → E) (fun u => ⟨a • u, inv_smul_smul₀ ha u⟩) fun u => _
        rw [smul_inv_smul₀ ha] }

@[simp]
theorem inf_apply (p q : Seminorm 𝕜 E) (x : E) : (p ⊓ q) x = ⨅ u : E, p u + q (x - u) :=
  rfl

noncomputable instance : Lattice (Seminorm 𝕜 E) :=
  { Seminorm.semilatticeSup with inf := (· ⊓ ·),
    inf_le_left := fun p q x =>
      cinfi_le_of_le bdd_below_range_add x <| by
        simp only [sub_self, map_zero, add_zeroₓ],
    inf_le_right := fun p q x =>
      cinfi_le_of_le bdd_below_range_add 0 <| by
        simp only [sub_self, map_zero, zero_addₓ, sub_zero],
    le_inf := fun a b c hab hac x => le_cinfi fun u => (le_map_add_map_sub a _ _).trans <| add_le_add (hab _) (hac _) }

theorem smul_inf [HasSmul R ℝ] [HasSmul R ℝ≥0] [IsScalarTower R ℝ≥0 ℝ] (r : R) (p q : Seminorm 𝕜 E) :
    r • (p ⊓ q) = r • p ⊓ r • q := by
  ext
  simp_rw [smul_apply, inf_apply, smul_apply, ← smul_one_smul ℝ≥0 r (_ : ℝ), Nnreal.smul_def, smul_eq_mul,
    Real.mul_infi_of_nonneg (Subtype.prop _), mul_addₓ]

end NormedField

/-! ### Seminorm ball -/


section SemiNormedRing

variable [SemiNormedRing 𝕜]

section AddCommGroupₓ

variable [AddCommGroupₓ E]

section HasSmul

variable [HasSmul 𝕜 E] (p : Seminorm 𝕜 E)

/-- The ball of radius `r` at `x` with respect to seminorm `p` is the set of elements `y` with
`p (y - x) < `r`. -/
def Ball (x : E) (r : ℝ) :=
  { y : E | p (y - x) < r }

variable {x y : E} {r : ℝ}

@[simp]
theorem mem_ball : y ∈ Ball p x r ↔ p (y - x) < r :=
  Iff.rfl

theorem mem_ball_zero : y ∈ Ball p 0 r ↔ p y < r := by
  rw [mem_ball, sub_zero]

theorem ball_zero_eq : Ball p 0 r = { y : E | p y < r } :=
  Set.ext fun x => p.mem_ball_zero

@[simp]
theorem ball_zero' (x : E) (hr : 0 < r) : Ball (0 : Seminorm 𝕜 E) x r = Set.Univ := by
  rw [Set.eq_univ_iff_forall, ball]
  simp [hr]

theorem ball_smul (p : Seminorm 𝕜 E) {c : Nnreal} (hc : 0 < c) (r : ℝ) (x : E) : (c • p).ball x r = p.ball x (r / c) :=
  by
  ext
  rw [mem_ball, mem_ball, smul_apply, Nnreal.smul_def, smul_eq_mul, mul_comm, lt_div_iff (nnreal.coe_pos.mpr hc)]

theorem ball_sup (p : Seminorm 𝕜 E) (q : Seminorm 𝕜 E) (e : E) (r : ℝ) : Ball (p ⊔ q) e r = Ball p e r ∩ Ball q e r :=
  by
  simp_rw [ball, ← Set.set_of_and, coe_sup, Pi.sup_apply, sup_lt_iff]

theorem ball_finset_sup' (p : ι → Seminorm 𝕜 E) (s : Finset ι) (H : s.Nonempty) (e : E) (r : ℝ) :
    Ball (s.sup' H p) e r = s.inf' H fun i => Ball (p i) e r := by
  induction' H using Finset.Nonempty.cons_induction with a a s ha hs ih
  · classical
    simp
    
  · rw [Finset.sup'_cons hs, Finset.inf'_cons hs, ball_sup, inf_eq_inter, ih]
    

theorem ball_mono {p : Seminorm 𝕜 E} {r₁ r₂ : ℝ} (h : r₁ ≤ r₂) : p.ball x r₁ ⊆ p.ball x r₂ := fun _ (hx : _ < _) =>
  hx.trans_le h

theorem ball_antitone {p q : Seminorm 𝕜 E} (h : q ≤ p) : p.ball x r ⊆ q.ball x r := fun _ => (h _).trans_lt

theorem ball_add_ball_subset (p : Seminorm 𝕜 E) (r₁ r₂ : ℝ) (x₁ x₂ : E) :
    p.ball (x₁ : E) r₁ + p.ball (x₂ : E) r₂ ⊆ p.ball (x₁ + x₂) (r₁ + r₂) := by
  rintro x ⟨y₁, y₂, hy₁, hy₂, rfl⟩
  rw [mem_ball, add_sub_add_comm]
  exact (map_add_le_add p _ _).trans_lt (add_lt_add hy₁ hy₂)

end HasSmul

section Module

variable [Module 𝕜 E]

variable [AddCommGroupₓ F] [Module 𝕜 F]

theorem ball_comp (p : Seminorm 𝕜 F) (f : E →ₗ[𝕜] F) (x : E) (r : ℝ) : (p.comp f).ball x r = f ⁻¹' p.ball (f x) r := by
  ext
  simp_rw [ball, mem_preimage, comp_apply, Set.mem_set_of_eq, map_sub]

variable (p : Seminorm 𝕜 E)

theorem ball_zero_eq_preimage_ball {r : ℝ} : p.ball 0 r = p ⁻¹' Metric.Ball 0 r := by
  ext x
  simp only [mem_ball, sub_zero, mem_preimage, mem_ball_zero_iff]
  rw [Real.norm_of_nonneg]
  exact map_nonneg p _

@[simp]
theorem ball_bot {r : ℝ} (x : E) (hr : 0 < r) : Ball (⊥ : Seminorm 𝕜 E) x r = Set.Univ :=
  ball_zero' x hr

/-- Seminorm-balls at the origin are balanced. -/
theorem balanced_ball_zero (r : ℝ) : Balanced 𝕜 (Ball p 0 r) := by
  rintro a ha x ⟨y, hy, hx⟩
  rw [mem_ball_zero, ← hx, map_smul_eq_mul]
  calc
    _ ≤ p y := mul_le_of_le_one_left (map_nonneg p _) ha
    _ < r := by
      rwa [mem_ball_zero] at hy
    

theorem ball_finset_sup_eq_Inter (p : ι → Seminorm 𝕜 E) (s : Finset ι) (x : E) {r : ℝ} (hr : 0 < r) :
    Ball (s.sup p) x r = ⋂ i ∈ s, Ball (p i) x r := by
  lift r to Nnreal using hr.le
  simp_rw [ball, Inter_set_of, finset_sup_apply, Nnreal.coe_lt_coe, Finset.sup_lt_iff (show ⊥ < r from hr), ←
    Nnreal.coe_lt_coe, Subtype.coe_mk]

theorem ball_finset_sup (p : ι → Seminorm 𝕜 E) (s : Finset ι) (x : E) {r : ℝ} (hr : 0 < r) :
    Ball (s.sup p) x r = s.inf fun i => Ball (p i) x r := by
  rw [Finset.inf_eq_infi]
  exact ball_finset_sup_eq_Inter _ _ _ hr

theorem ball_smul_ball (p : Seminorm 𝕜 E) (r₁ r₂ : ℝ) : Metric.Ball (0 : 𝕜) r₁ • p.ball 0 r₂ ⊆ p.ball 0 (r₁ * r₂) := by
  rw [Set.subset_def]
  intro x hx
  rw [Set.mem_smul] at hx
  rcases hx with ⟨a, y, ha, hy, hx⟩
  rw [← hx, mem_ball_zero, map_smul_eq_mul]
  exact mul_lt_mul'' (mem_ball_zero_iff.mp ha) (p.mem_ball_zero.mp hy) (norm_nonneg a) (map_nonneg p y)

@[simp]
theorem ball_eq_emptyset (p : Seminorm 𝕜 E) {x : E} {r : ℝ} (hr : r ≤ 0) : p.ball x r = ∅ := by
  ext
  rw [Seminorm.mem_ball, Set.mem_empty_eq, iff_falseₓ, not_ltₓ]
  exact hr.trans (map_nonneg p _)

end Module

end AddCommGroupₓ

end SemiNormedRing

section NormedField

variable [NormedField 𝕜] [AddCommGroupₓ E] [Module 𝕜 E] (p : Seminorm 𝕜 E) {A B : Set E} {a : 𝕜} {r : ℝ} {x : E}

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
      div_self (ne_of_gtₓ hk), one_mulₓ]
    exact h
    
  rw [← smul_assoc, smul_eq_mul, ← div_eq_mul_inv, div_self (norm_pos_iff.mp hk), one_smul]

theorem ball_zero_absorbs_ball_zero (p : Seminorm 𝕜 E) {r₁ r₂ : ℝ} (hr₁ : 0 < r₁) :
    Absorbs 𝕜 (p.ball 0 r₁) (p.ball 0 r₂) := by
  by_cases' hr₂ : r₂ ≤ 0
  · rw [ball_eq_emptyset p hr₂]
    exact absorbs_empty
    
  rw [not_leₓ] at hr₂
  rcases exists_between hr₁ with ⟨r, hr, hr'⟩
  refine' ⟨r₂ / r, div_pos hr₂ hr, _⟩
  simp_rw [Set.subset_def]
  intro a ha x hx
  have ha' : 0 < ∥a∥ := lt_of_lt_of_leₓ (div_pos hr₂ hr) ha
  rw [smul_ball_zero ha', p.mem_ball_zero]
  rw [p.mem_ball_zero] at hx
  rw [div_le_iff hr] at ha
  exact hx.trans (lt_of_le_of_ltₓ ha ((mul_lt_mul_left ha').mpr hr'))

/-- Seminorm-balls at the origin are absorbent. -/
protected theorem absorbent_ball_zero (hr : 0 < r) : Absorbent 𝕜 (Ball p (0 : E) r) := by
  rw [absorbent_iff_nonneg_lt]
  rintro x
  have hxr : 0 ≤ p x / r := div_nonneg (map_nonneg p _) hr.le
  refine' ⟨p x / r, hxr, fun a ha => _⟩
  have ha₀ : 0 < ∥a∥ := hxr.trans_lt ha
  refine' ⟨a⁻¹ • x, _, smul_inv_smul₀ (norm_pos_iff.1 ha₀) x⟩
  rwa [mem_ball_zero, map_smul_eq_mul, norm_inv, inv_mul_lt_iff ha₀, ← div_lt_iff hr]

/-- Seminorm-balls containing the origin are absorbent. -/
protected theorem absorbent_ball (hpr : p x < r) : Absorbent 𝕜 (Ball p x r) := by
  refine' (p.absorbent_ball_zero <| sub_pos.2 hpr).Subset fun y hy => _
  rw [p.mem_ball_zero] at hy
  exact p.mem_ball.2 ((map_sub_le_add p _ _).trans_lt <| add_lt_of_lt_sub_right hy)

theorem symmetric_ball_zero (r : ℝ) (hx : x ∈ Ball p 0 r) : -x ∈ Ball p 0 r :=
  balanced_ball_zero p r (-1)
    (by
      rw [norm_neg, norm_one])
    ⟨x, hx, by
      rw [neg_smul, one_smul]⟩

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

variable [NormedField 𝕜] [AddCommGroupₓ E] [NormedSpace ℝ 𝕜] [Module 𝕜 E]

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
      rw [norm_smul, norm_smul, norm_one, mul_oneₓ, mul_oneₓ, Real.norm_of_nonneg ha, Real.norm_of_nonneg hb]
    

end HasSmul

section Module

variable [Module ℝ E] [IsScalarTower ℝ 𝕜 E] (p : Seminorm 𝕜 E) (x : E) (r : ℝ)

/-- Seminorm-balls are convex. -/
theorem convex_ball : Convex ℝ (Ball p x r) := by
  convert (p.convex_on.translate_left (-x)).convex_lt r
  ext y
  rw [preimage_univ, sep_univ, p.mem_ball, sub_eq_add_neg]
  rfl

end Module

end Convex

section RestrictScalars

variable (𝕜) {𝕜' : Type _} [NormedField 𝕜] [SemiNormedRing 𝕜'] [NormedAlgebra 𝕜 𝕜'] [NormOneClass 𝕜'] [AddCommGroupₓ E]
  [Module 𝕜' E] [HasSmul 𝕜 E] [IsScalarTower 𝕜 𝕜' E]

/-- Reinterpret a seminorm over a field `𝕜'` as a seminorm over a smaller field `𝕜`. This will
typically be used with `is_R_or_C 𝕜'` and `𝕜 = ℝ`. -/
protected def restrictScalars (p : Seminorm 𝕜' E) : Seminorm 𝕜 E :=
  { p with
    smul' := fun a x => by
      rw [← smul_one_smul 𝕜' a x, p.smul', norm_smul, norm_one, mul_oneₓ] }

@[simp]
theorem coe_restrict_scalars (p : Seminorm 𝕜' E) : (p.restrictScalars 𝕜 : E → ℝ) = p :=
  rfl

@[simp]
theorem restrict_scalars_ball (p : Seminorm 𝕜' E) : (p.restrictScalars 𝕜).ball = p.ball :=
  rfl

end RestrictScalars

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
  ext x r y
  simp only [Seminorm.mem_ball, Metric.mem_ball, coe_norm_seminorm, dist_eq_norm]

variable {𝕜 E} {x : E}

/-- Balls at the origin are absorbent. -/
theorem absorbent_ball_zero (hr : 0 < r) : Absorbent 𝕜 (Metric.Ball (0 : E) r) := by
  rw [← ball_norm_seminorm 𝕜]
  exact (normSeminorm _ _).absorbent_ball_zero hr

/-- Balls containing the origin are absorbent. -/
theorem absorbent_ball (hx : ∥x∥ < r) : Absorbent 𝕜 (Metric.Ball x r) := by
  rw [← ball_norm_seminorm 𝕜]
  exact (normSeminorm _ _).absorbent_ball hx

/-- Balls at the origin are balanced. -/
theorem balanced_ball_zero : Balanced 𝕜 (Metric.Ball (0 : E) r) := by
  rw [← ball_norm_seminorm 𝕜]
  exact (normSeminorm _ _).balanced_ball_zero r

end normSeminorm

