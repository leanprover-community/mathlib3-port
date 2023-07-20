/-
Copyright (c) 2020 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers
-/
import Mathbin.Data.Set.Pointwise.Interval
import Mathbin.LinearAlgebra.AffineSpace.Basic
import Mathbin.LinearAlgebra.BilinearMap
import Mathbin.LinearAlgebra.Pi
import Mathbin.LinearAlgebra.Prod

#align_import linear_algebra.affine_space.affine_map from "leanprover-community/mathlib"@"bd1fc183335ea95a9519a1630bcf901fe9326d83"

/-!
# Affine maps

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines affine maps.

## Main definitions

* `affine_map` is the type of affine maps between two affine spaces with the same ring `k`.  Various
  basic examples of affine maps are defined, including `const`, `id`, `line_map` and `homothety`.

## Notations

* `P1 →ᵃ[k] P2` is a notation for `affine_map k P1 P2`;
* `affine_space V P`: a localized notation for `add_torsor V P` defined in
  `linear_algebra.affine_space.basic`.

## Implementation notes

`out_param` is used in the definition of `[add_torsor V P]` to make `V` an implicit argument
(deduced from `P`) in most cases; `include V` is needed in many cases for `V`, and type classes
using it, to be added as implicit arguments to individual lemmas.  As for modules, `k` is an
explicit argument rather than implied by `P` or `V`.

This file only provides purely algebraic definitions and results. Those depending on analysis or
topology are defined elsewhere; see `analysis.normed_space.add_torsor` and
`topology.algebra.affine`.

## References

* https://en.wikipedia.org/wiki/Affine_space
* https://en.wikipedia.org/wiki/Principal_homogeneous_space
-/


open scoped Affine

#print AffineMap /-
/-- An `affine_map k P1 P2` (notation: `P1 →ᵃ[k] P2`) is a map from `P1` to `P2` that
induces a corresponding linear map from `V1` to `V2`. -/
structure AffineMap (k : Type _) {V1 : Type _} (P1 : Type _) {V2 : Type _} (P2 : Type _) [Ring k]
    [AddCommGroup V1] [Module k V1] [affine_space V1 P1] [AddCommGroup V2] [Module k V2]
    [affine_space V2 P2] where
  toFun : P1 → P2
  linear : V1 →ₗ[k] V2
  map_vadd' : ∀ (p : P1) (v : V1), to_fun (v +ᵥ p) = linear v +ᵥ to_fun p
#align affine_map AffineMap
-/

notation:25 P1 " →ᵃ[" k:25 "] " P2:0 => AffineMap k P1 P2

#print AffineMap.funLike /-
instance AffineMap.funLike (k : Type _) {V1 : Type _} (P1 : Type _) {V2 : Type _} (P2 : Type _)
    [Ring k] [AddCommGroup V1] [Module k V1] [affine_space V1 P1] [AddCommGroup V2] [Module k V2]
    [affine_space V2 P2] : FunLike (P1 →ᵃ[k] P2) P1 fun _ => P2
    where
  coe := AffineMap.toFun
  coe_injective' := fun ⟨f, f_linear, f_add⟩ ⟨g, g_linear, g_add⟩ (h : f = g) =>
    by
    cases' (AddTorsor.nonempty : Nonempty P1) with p
    congr with v
    apply vadd_right_cancel (f p)
    erw [← f_add, h, ← g_add]
#align affine_map.fun_like AffineMap.funLike
-/

#print AffineMap.hasCoeToFun /-
instance AffineMap.hasCoeToFun (k : Type _) {V1 : Type _} (P1 : Type _) {V2 : Type _} (P2 : Type _)
    [Ring k] [AddCommGroup V1] [Module k V1] [affine_space V1 P1] [AddCommGroup V2] [Module k V2]
    [affine_space V2 P2] : CoeFun (P1 →ᵃ[k] P2) fun _ => P1 → P2 :=
  FunLike.hasCoeToFun
#align affine_map.has_coe_to_fun AffineMap.hasCoeToFun
-/

namespace LinearMap

variable {k : Type _} {V₁ : Type _} {V₂ : Type _} [Ring k] [AddCommGroup V₁] [Module k V₁]
  [AddCommGroup V₂] [Module k V₂] (f : V₁ →ₗ[k] V₂)

#print LinearMap.toAffineMap /-
/-- Reinterpret a linear map as an affine map. -/
def toAffineMap : V₁ →ᵃ[k] V₂ where
  toFun := f
  linear := f
  map_vadd' p v := f.map_add v p
#align linear_map.to_affine_map LinearMap.toAffineMap
-/

#print LinearMap.coe_toAffineMap /-
@[simp]
theorem coe_toAffineMap : ⇑f.toAffineMap = f :=
  rfl
#align linear_map.coe_to_affine_map LinearMap.coe_toAffineMap
-/

#print LinearMap.toAffineMap_linear /-
@[simp]
theorem toAffineMap_linear : f.toAffineMap.linear = f :=
  rfl
#align linear_map.to_affine_map_linear LinearMap.toAffineMap_linear
-/

end LinearMap

namespace AffineMap

variable {k : Type _} {V1 : Type _} {P1 : Type _} {V2 : Type _} {P2 : Type _} {V3 : Type _}
  {P3 : Type _} {V4 : Type _} {P4 : Type _} [Ring k] [AddCommGroup V1] [Module k V1]
  [affine_space V1 P1] [AddCommGroup V2] [Module k V2] [affine_space V2 P2] [AddCommGroup V3]
  [Module k V3] [affine_space V3 P3] [AddCommGroup V4] [Module k V4] [affine_space V4 P4]

#print AffineMap.coe_mk /-
/-- Constructing an affine map and coercing back to a function
produces the same map. -/
@[simp]
theorem coe_mk (f : P1 → P2) (linear add) : ((mk f linear add : P1 →ᵃ[k] P2) : P1 → P2) = f :=
  rfl
#align affine_map.coe_mk AffineMap.coe_mk
-/

#print AffineMap.toFun_eq_coe /-
/-- `to_fun` is the same as the result of coercing to a function. -/
@[simp]
theorem toFun_eq_coe (f : P1 →ᵃ[k] P2) : f.toFun = ⇑f :=
  rfl
#align affine_map.to_fun_eq_coe AffineMap.toFun_eq_coe
-/

#print AffineMap.map_vadd /-
/-- An affine map on the result of adding a vector to a point produces
the same result as the linear map applied to that vector, added to the
affine map applied to that point. -/
@[simp]
theorem map_vadd (f : P1 →ᵃ[k] P2) (p : P1) (v : V1) : f (v +ᵥ p) = f.linear v +ᵥ f p :=
  f.map_vadd' p v
#align affine_map.map_vadd AffineMap.map_vadd
-/

#print AffineMap.linearMap_vsub /-
/-- The linear map on the result of subtracting two points is the
result of subtracting the result of the affine map on those two
points. -/
@[simp]
theorem linearMap_vsub (f : P1 →ᵃ[k] P2) (p1 p2 : P1) : f.linear (p1 -ᵥ p2) = f p1 -ᵥ f p2 := by
  conv_rhs => rw [← vsub_vadd p1 p2, map_vadd, vadd_vsub]
#align affine_map.linear_map_vsub AffineMap.linearMap_vsub
-/

#print AffineMap.ext /-
/-- Two affine maps are equal if they coerce to the same function. -/
@[ext]
theorem ext {f g : P1 →ᵃ[k] P2} (h : ∀ p, f p = g p) : f = g :=
  FunLike.ext _ _ h
#align affine_map.ext AffineMap.ext
-/

#print AffineMap.ext_iff /-
theorem ext_iff {f g : P1 →ᵃ[k] P2} : f = g ↔ ∀ p, f p = g p :=
  ⟨fun h p => h ▸ rfl, ext⟩
#align affine_map.ext_iff AffineMap.ext_iff
-/

#print AffineMap.coeFn_injective /-
theorem coeFn_injective : @Function.Injective (P1 →ᵃ[k] P2) (P1 → P2) coeFn :=
  FunLike.coe_injective
#align affine_map.coe_fn_injective AffineMap.coeFn_injective
-/

#print AffineMap.congr_arg /-
protected theorem congr_arg (f : P1 →ᵃ[k] P2) {x y : P1} (h : x = y) : f x = f y :=
  congr_arg _ h
#align affine_map.congr_arg AffineMap.congr_arg
-/

#print AffineMap.congr_fun /-
protected theorem congr_fun {f g : P1 →ᵃ[k] P2} (h : f = g) (x : P1) : f x = g x :=
  h ▸ rfl
#align affine_map.congr_fun AffineMap.congr_fun
-/

variable (k P1)

#print AffineMap.const /-
/-- Constant function as an `affine_map`. -/
def const (p : P2) : P1 →ᵃ[k] P2
    where
  toFun := Function.const P1 p
  linear := 0
  map_vadd' p v := by simp
#align affine_map.const AffineMap.const
-/

#print AffineMap.coe_const /-
@[simp]
theorem coe_const (p : P2) : ⇑(const k P1 p) = Function.const P1 p :=
  rfl
#align affine_map.coe_const AffineMap.coe_const
-/

#print AffineMap.const_linear /-
@[simp]
theorem const_linear (p : P2) : (const k P1 p).linear = 0 :=
  rfl
#align affine_map.const_linear AffineMap.const_linear
-/

variable {k P1}

#print AffineMap.linear_eq_zero_iff_exists_const /-
theorem linear_eq_zero_iff_exists_const (f : P1 →ᵃ[k] P2) : f.linear = 0 ↔ ∃ q, f = const k P1 q :=
  by
  refine' ⟨fun h => _, fun h => _⟩
  · use f (Classical.arbitrary P1)
    ext
    rw [coe_const, Function.const_apply, ← @vsub_eq_zero_iff_eq V2, ← f.linear_map_vsub, h,
      LinearMap.zero_apply]
  · rcases h with ⟨q, rfl⟩
    exact const_linear k P1 q
#align affine_map.linear_eq_zero_iff_exists_const AffineMap.linear_eq_zero_iff_exists_const
-/

#print AffineMap.nonempty /-
instance nonempty : Nonempty (P1 →ᵃ[k] P2) :=
  (AddTorsor.nonempty : Nonempty P2).elim fun p => ⟨const k P1 p⟩
#align affine_map.nonempty AffineMap.nonempty
-/

#print AffineMap.mk' /-
/-- Construct an affine map by verifying the relation between the map and its linear part at one
base point. Namely, this function takes a map `f : P₁ → P₂`, a linear map `f' : V₁ →ₗ[k] V₂`, and
a point `p` such that for any other point `p'` we have `f p' = f' (p' -ᵥ p) +ᵥ f p`. -/
def mk' (f : P1 → P2) (f' : V1 →ₗ[k] V2) (p : P1) (h : ∀ p' : P1, f p' = f' (p' -ᵥ p) +ᵥ f p) :
    P1 →ᵃ[k] P2 where
  toFun := f
  linear := f'
  map_vadd' p' v := by rw [h, h p', vadd_vsub_assoc, f'.map_add, vadd_vadd]
#align affine_map.mk' AffineMap.mk'
-/

#print AffineMap.coe_mk' /-
@[simp]
theorem coe_mk' (f : P1 → P2) (f' : V1 →ₗ[k] V2) (p h) : ⇑(mk' f f' p h) = f :=
  rfl
#align affine_map.coe_mk' AffineMap.coe_mk'
-/

#print AffineMap.mk'_linear /-
@[simp]
theorem mk'_linear (f : P1 → P2) (f' : V1 →ₗ[k] V2) (p h) : (mk' f f' p h).linear = f' :=
  rfl
#align affine_map.mk'_linear AffineMap.mk'_linear
-/

section SMul

variable {R : Type _} [Monoid R] [DistribMulAction R V2] [SMulCommClass k R V2]

/-- The space of affine maps to a module inherits an `R`-action from the action on its codomain. -/
instance : MulAction R (P1 →ᵃ[k] V2)
    where
  smul c f := ⟨c • f, c • f.linear, fun p v => by simp [smul_add]⟩
  one_smul f := ext fun p => one_smul _ _
  mul_smul c₁ c₂ f := ext fun p => mul_smul _ _ _

#print AffineMap.coe_smul /-
@[simp, norm_cast]
theorem coe_smul (c : R) (f : P1 →ᵃ[k] V2) : ⇑(c • f) = c • f :=
  rfl
#align affine_map.coe_smul AffineMap.coe_smul
-/

#print AffineMap.smul_linear /-
@[simp]
theorem smul_linear (t : R) (f : P1 →ᵃ[k] V2) : (t • f).linear = t • f.linear :=
  rfl
#align affine_map.smul_linear AffineMap.smul_linear
-/

instance [DistribMulAction Rᵐᵒᵖ V2] [IsCentralScalar R V2] : IsCentralScalar R (P1 →ᵃ[k] V2)
    where op_smul_eq_smul r x := ext fun _ => op_smul_eq_smul _ _

end SMul

instance : Zero (P1 →ᵃ[k] V2) where zero := ⟨0, 0, fun p v => (zero_vadd _ _).symm⟩

instance : Add (P1 →ᵃ[k] V2)
    where add f g := ⟨f + g, f.linear + g.linear, fun p v => by simp [add_add_add_comm]⟩

instance : Sub (P1 →ᵃ[k] V2)
    where sub f g := ⟨f - g, f.linear - g.linear, fun p v => by simp [sub_add_sub_comm]⟩

instance : Neg (P1 →ᵃ[k] V2) where neg f := ⟨-f, -f.linear, fun p v => by simp [add_comm]⟩

#print AffineMap.coe_zero /-
@[simp, norm_cast]
theorem coe_zero : ⇑(0 : P1 →ᵃ[k] V2) = 0 :=
  rfl
#align affine_map.coe_zero AffineMap.coe_zero
-/

#print AffineMap.coe_add /-
@[simp, norm_cast]
theorem coe_add (f g : P1 →ᵃ[k] V2) : ⇑(f + g) = f + g :=
  rfl
#align affine_map.coe_add AffineMap.coe_add
-/

#print AffineMap.coe_neg /-
@[simp, norm_cast]
theorem coe_neg (f : P1 →ᵃ[k] V2) : ⇑(-f) = -f :=
  rfl
#align affine_map.coe_neg AffineMap.coe_neg
-/

#print AffineMap.coe_sub /-
@[simp, norm_cast]
theorem coe_sub (f g : P1 →ᵃ[k] V2) : ⇑(f - g) = f - g :=
  rfl
#align affine_map.coe_sub AffineMap.coe_sub
-/

#print AffineMap.zero_linear /-
@[simp]
theorem zero_linear : (0 : P1 →ᵃ[k] V2).linear = 0 :=
  rfl
#align affine_map.zero_linear AffineMap.zero_linear
-/

#print AffineMap.add_linear /-
@[simp]
theorem add_linear (f g : P1 →ᵃ[k] V2) : (f + g).linear = f.linear + g.linear :=
  rfl
#align affine_map.add_linear AffineMap.add_linear
-/

#print AffineMap.sub_linear /-
@[simp]
theorem sub_linear (f g : P1 →ᵃ[k] V2) : (f - g).linear = f.linear - g.linear :=
  rfl
#align affine_map.sub_linear AffineMap.sub_linear
-/

#print AffineMap.neg_linear /-
@[simp]
theorem neg_linear (f : P1 →ᵃ[k] V2) : (-f).linear = -f.linear :=
  rfl
#align affine_map.neg_linear AffineMap.neg_linear
-/

/-- The set of affine maps to a vector space is an additive commutative group. -/
instance : AddCommGroup (P1 →ᵃ[k] V2) :=
  coeFn_injective.AddCommGroup _ coe_zero coe_add coe_neg coe_sub (fun _ _ => coe_smul _ _)
    fun _ _ => coe_smul _ _

/-- The space of affine maps from `P1` to `P2` is an affine space over the space of affine maps
from `P1` to the vector space `V2` corresponding to `P2`. -/
instance : affine_space (P1 →ᵃ[k] V2) (P1 →ᵃ[k] P2)
    where
  vadd f g :=
    ⟨fun p => f p +ᵥ g p, f.linear + g.linear, fun p v => by simp [vadd_vadd, add_right_comm]⟩
  zero_vadd f := ext fun p => zero_vadd _ (f p)
  add_vadd f₁ f₂ f₃ := ext fun p => add_vadd (f₁ p) (f₂ p) (f₃ p)
  vsub f g :=
    ⟨fun p => f p -ᵥ g p, f.linear - g.linear, fun p v => by
      simp [vsub_vadd_eq_vsub_sub, vadd_vsub_assoc, add_sub, sub_add_eq_add_sub]⟩
  vsub_vadd' f g := ext fun p => vsub_vadd (f p) (g p)
  vadd_vsub' f g := ext fun p => vadd_vsub (f p) (g p)

#print AffineMap.vadd_apply /-
@[simp]
theorem vadd_apply (f : P1 →ᵃ[k] V2) (g : P1 →ᵃ[k] P2) (p : P1) : (f +ᵥ g) p = f p +ᵥ g p :=
  rfl
#align affine_map.vadd_apply AffineMap.vadd_apply
-/

#print AffineMap.vsub_apply /-
@[simp]
theorem vsub_apply (f g : P1 →ᵃ[k] P2) (p : P1) : (f -ᵥ g : P1 →ᵃ[k] V2) p = f p -ᵥ g p :=
  rfl
#align affine_map.vsub_apply AffineMap.vsub_apply
-/

#print AffineMap.fst /-
/-- `prod.fst` as an `affine_map`. -/
def fst : P1 × P2 →ᵃ[k] P1 where
  toFun := Prod.fst
  linear := LinearMap.fst k V1 V2
  map_vadd' _ _ := rfl
#align affine_map.fst AffineMap.fst
-/

#print AffineMap.coe_fst /-
@[simp]
theorem coe_fst : ⇑(fst : P1 × P2 →ᵃ[k] P1) = Prod.fst :=
  rfl
#align affine_map.coe_fst AffineMap.coe_fst
-/

#print AffineMap.fst_linear /-
@[simp]
theorem fst_linear : (fst : P1 × P2 →ᵃ[k] P1).linear = LinearMap.fst k V1 V2 :=
  rfl
#align affine_map.fst_linear AffineMap.fst_linear
-/

#print AffineMap.snd /-
/-- `prod.snd` as an `affine_map`. -/
def snd : P1 × P2 →ᵃ[k] P2 where
  toFun := Prod.snd
  linear := LinearMap.snd k V1 V2
  map_vadd' _ _ := rfl
#align affine_map.snd AffineMap.snd
-/

#print AffineMap.coe_snd /-
@[simp]
theorem coe_snd : ⇑(snd : P1 × P2 →ᵃ[k] P2) = Prod.snd :=
  rfl
#align affine_map.coe_snd AffineMap.coe_snd
-/

#print AffineMap.snd_linear /-
@[simp]
theorem snd_linear : (snd : P1 × P2 →ᵃ[k] P2).linear = LinearMap.snd k V1 V2 :=
  rfl
#align affine_map.snd_linear AffineMap.snd_linear
-/

variable (k P1)

#print AffineMap.id /-
/-- Identity map as an affine map. -/
def id : P1 →ᵃ[k] P1 where
  toFun := id
  linear := LinearMap.id
  map_vadd' p v := rfl
#align affine_map.id AffineMap.id
-/

#print AffineMap.coe_id /-
/-- The identity affine map acts as the identity. -/
@[simp]
theorem coe_id : ⇑(id k P1) = id :=
  rfl
#align affine_map.coe_id AffineMap.coe_id
-/

#print AffineMap.id_linear /-
@[simp]
theorem id_linear : (id k P1).linear = LinearMap.id :=
  rfl
#align affine_map.id_linear AffineMap.id_linear
-/

variable {P1}

#print AffineMap.id_apply /-
/-- The identity affine map acts as the identity. -/
theorem id_apply (p : P1) : id k P1 p = p :=
  rfl
#align affine_map.id_apply AffineMap.id_apply
-/

variable {k P1}

instance : Inhabited (P1 →ᵃ[k] P1) :=
  ⟨id k P1⟩

#print AffineMap.comp /-
/-- Composition of affine maps. -/
def comp (f : P2 →ᵃ[k] P3) (g : P1 →ᵃ[k] P2) : P1 →ᵃ[k] P3
    where
  toFun := f ∘ g
  linear := f.linear.comp g.linear
  map_vadd' := by
    intro p v
    rw [Function.comp_apply, g.map_vadd, f.map_vadd]
    rfl
#align affine_map.comp AffineMap.comp
-/

#print AffineMap.coe_comp /-
/-- Composition of affine maps acts as applying the two functions. -/
@[simp]
theorem coe_comp (f : P2 →ᵃ[k] P3) (g : P1 →ᵃ[k] P2) : ⇑(f.comp g) = f ∘ g :=
  rfl
#align affine_map.coe_comp AffineMap.coe_comp
-/

#print AffineMap.comp_apply /-
/-- Composition of affine maps acts as applying the two functions. -/
theorem comp_apply (f : P2 →ᵃ[k] P3) (g : P1 →ᵃ[k] P2) (p : P1) : f.comp g p = f (g p) :=
  rfl
#align affine_map.comp_apply AffineMap.comp_apply
-/

#print AffineMap.comp_id /-
@[simp]
theorem comp_id (f : P1 →ᵃ[k] P2) : f.comp (id k P1) = f :=
  ext fun p => rfl
#align affine_map.comp_id AffineMap.comp_id
-/

#print AffineMap.id_comp /-
@[simp]
theorem id_comp (f : P1 →ᵃ[k] P2) : (id k P2).comp f = f :=
  ext fun p => rfl
#align affine_map.id_comp AffineMap.id_comp
-/

#print AffineMap.comp_assoc /-
theorem comp_assoc (f₃₄ : P3 →ᵃ[k] P4) (f₂₃ : P2 →ᵃ[k] P3) (f₁₂ : P1 →ᵃ[k] P2) :
    (f₃₄.comp f₂₃).comp f₁₂ = f₃₄.comp (f₂₃.comp f₁₂) :=
  rfl
#align affine_map.comp_assoc AffineMap.comp_assoc
-/

instance : Monoid (P1 →ᵃ[k] P1) where
  one := id k P1
  mul := comp
  one_mul := id_comp
  mul_one := comp_id
  mul_assoc := comp_assoc

#print AffineMap.coe_mul /-
@[simp]
theorem coe_mul (f g : P1 →ᵃ[k] P1) : ⇑(f * g) = f ∘ g :=
  rfl
#align affine_map.coe_mul AffineMap.coe_mul
-/

#print AffineMap.coe_one /-
@[simp]
theorem coe_one : ⇑(1 : P1 →ᵃ[k] P1) = id :=
  rfl
#align affine_map.coe_one AffineMap.coe_one
-/

#print AffineMap.linearHom /-
/-- `affine_map.linear` on endomorphisms is a `monoid_hom`. -/
@[simps]
def linearHom : (P1 →ᵃ[k] P1) →* V1 →ₗ[k] V1
    where
  toFun := linear
  map_one' := rfl
  map_mul' _ _ := rfl
#align affine_map.linear_hom AffineMap.linearHom
-/

#print AffineMap.linear_injective_iff /-
@[simp]
theorem linear_injective_iff (f : P1 →ᵃ[k] P2) :
    Function.Injective f.linear ↔ Function.Injective f :=
  by
  obtain ⟨p⟩ := (inferInstance : Nonempty P1)
  have h : ⇑f.linear = (Equiv.vaddConst (f p)).symm ∘ f ∘ Equiv.vaddConst p := by ext v;
    simp [f.map_vadd, vadd_vsub_assoc]
  rw [h, Equiv.comp_injective, Equiv.injective_comp]
#align affine_map.linear_injective_iff AffineMap.linear_injective_iff
-/

#print AffineMap.linear_surjective_iff /-
@[simp]
theorem linear_surjective_iff (f : P1 →ᵃ[k] P2) :
    Function.Surjective f.linear ↔ Function.Surjective f :=
  by
  obtain ⟨p⟩ := (inferInstance : Nonempty P1)
  have h : ⇑f.linear = (Equiv.vaddConst (f p)).symm ∘ f ∘ Equiv.vaddConst p := by ext v;
    simp [f.map_vadd, vadd_vsub_assoc]
  rw [h, Equiv.comp_surjective, Equiv.surjective_comp]
#align affine_map.linear_surjective_iff AffineMap.linear_surjective_iff
-/

#print AffineMap.linear_bijective_iff /-
@[simp]
theorem linear_bijective_iff (f : P1 →ᵃ[k] P2) :
    Function.Bijective f.linear ↔ Function.Bijective f :=
  and_congr f.linear_injective_iff f.linear_surjective_iff
#align affine_map.linear_bijective_iff AffineMap.linear_bijective_iff
-/

#print AffineMap.image_vsub_image /-
theorem image_vsub_image {s t : Set P1} (f : P1 →ᵃ[k] P2) :
    f '' s -ᵥ f '' t = f.linear '' (s -ᵥ t) := by
  ext v
  simp only [Set.mem_vsub, Set.mem_image, exists_exists_and_eq_and, exists_and_left, ←
    f.linear_map_vsub]
  constructor
  · rintro ⟨x, hx, y, hy, hv⟩
    exact ⟨x -ᵥ y, ⟨x, hx, y, hy, rfl⟩, hv⟩
  · rintro ⟨-, ⟨x, hx, y, hy, rfl⟩, rfl⟩
    exact ⟨x, hx, y, hy, rfl⟩
#align affine_map.image_vsub_image AffineMap.image_vsub_image
-/

/-! ### Definition of `affine_map.line_map` and lemmas about it -/


#print AffineMap.lineMap /-
/-- The affine map from `k` to `P1` sending `0` to `p₀` and `1` to `p₁`. -/
def lineMap (p₀ p₁ : P1) : k →ᵃ[k] P1 :=
  ((LinearMap.id : k →ₗ[k] k).smul_right (p₁ -ᵥ p₀)).toAffineMap +ᵥ const k k p₀
#align affine_map.line_map AffineMap.lineMap
-/

#print AffineMap.coe_lineMap /-
theorem coe_lineMap (p₀ p₁ : P1) : (lineMap p₀ p₁ : k → P1) = fun c => c • (p₁ -ᵥ p₀) +ᵥ p₀ :=
  rfl
#align affine_map.coe_line_map AffineMap.coe_lineMap
-/

#print AffineMap.lineMap_apply /-
theorem lineMap_apply (p₀ p₁ : P1) (c : k) : lineMap p₀ p₁ c = c • (p₁ -ᵥ p₀) +ᵥ p₀ :=
  rfl
#align affine_map.line_map_apply AffineMap.lineMap_apply
-/

#print AffineMap.lineMap_apply_module' /-
theorem lineMap_apply_module' (p₀ p₁ : V1) (c : k) : lineMap p₀ p₁ c = c • (p₁ - p₀) + p₀ :=
  rfl
#align affine_map.line_map_apply_module' AffineMap.lineMap_apply_module'
-/

#print AffineMap.lineMap_apply_module /-
theorem lineMap_apply_module (p₀ p₁ : V1) (c : k) : lineMap p₀ p₁ c = (1 - c) • p₀ + c • p₁ := by
  simp [line_map_apply_module', smul_sub, sub_smul] <;> abel
#align affine_map.line_map_apply_module AffineMap.lineMap_apply_module
-/

#print AffineMap.lineMap_apply_ring' /-
theorem lineMap_apply_ring' (a b c : k) : lineMap a b c = c * (b - a) + a :=
  rfl
#align affine_map.line_map_apply_ring' AffineMap.lineMap_apply_ring'
-/

#print AffineMap.lineMap_apply_ring /-
theorem lineMap_apply_ring (a b c : k) : lineMap a b c = (1 - c) * a + c * b :=
  lineMap_apply_module a b c
#align affine_map.line_map_apply_ring AffineMap.lineMap_apply_ring
-/

#print AffineMap.lineMap_vadd_apply /-
theorem lineMap_vadd_apply (p : P1) (v : V1) (c : k) : lineMap p (v +ᵥ p) c = c • v +ᵥ p := by
  rw [line_map_apply, vadd_vsub]
#align affine_map.line_map_vadd_apply AffineMap.lineMap_vadd_apply
-/

#print AffineMap.lineMap_linear /-
@[simp]
theorem lineMap_linear (p₀ p₁ : P1) :
    (lineMap p₀ p₁ : k →ᵃ[k] P1).linear = LinearMap.id.smul_right (p₁ -ᵥ p₀) :=
  add_zero _
#align affine_map.line_map_linear AffineMap.lineMap_linear
-/

#print AffineMap.lineMap_same_apply /-
theorem lineMap_same_apply (p : P1) (c : k) : lineMap p p c = p := by simp [line_map_apply]
#align affine_map.line_map_same_apply AffineMap.lineMap_same_apply
-/

#print AffineMap.lineMap_same /-
@[simp]
theorem lineMap_same (p : P1) : lineMap p p = const k k p :=
  ext <| lineMap_same_apply p
#align affine_map.line_map_same AffineMap.lineMap_same
-/

#print AffineMap.lineMap_apply_zero /-
@[simp]
theorem lineMap_apply_zero (p₀ p₁ : P1) : lineMap p₀ p₁ (0 : k) = p₀ := by simp [line_map_apply]
#align affine_map.line_map_apply_zero AffineMap.lineMap_apply_zero
-/

#print AffineMap.lineMap_apply_one /-
@[simp]
theorem lineMap_apply_one (p₀ p₁ : P1) : lineMap p₀ p₁ (1 : k) = p₁ := by simp [line_map_apply]
#align affine_map.line_map_apply_one AffineMap.lineMap_apply_one
-/

#print AffineMap.lineMap_eq_lineMap_iff /-
@[simp]
theorem lineMap_eq_lineMap_iff [NoZeroSMulDivisors k V1] {p₀ p₁ : P1} {c₁ c₂ : k} :
    lineMap p₀ p₁ c₁ = lineMap p₀ p₁ c₂ ↔ p₀ = p₁ ∨ c₁ = c₂ := by
  rw [line_map_apply, line_map_apply, ← @vsub_eq_zero_iff_eq V1, vadd_vsub_vadd_cancel_right, ←
    sub_smul, smul_eq_zero, sub_eq_zero, vsub_eq_zero_iff_eq, or_comm', eq_comm]
#align affine_map.line_map_eq_line_map_iff AffineMap.lineMap_eq_lineMap_iff
-/

#print AffineMap.lineMap_eq_left_iff /-
@[simp]
theorem lineMap_eq_left_iff [NoZeroSMulDivisors k V1] {p₀ p₁ : P1} {c : k} :
    lineMap p₀ p₁ c = p₀ ↔ p₀ = p₁ ∨ c = 0 := by
  rw [← @line_map_eq_line_map_iff k V1, line_map_apply_zero]
#align affine_map.line_map_eq_left_iff AffineMap.lineMap_eq_left_iff
-/

#print AffineMap.lineMap_eq_right_iff /-
@[simp]
theorem lineMap_eq_right_iff [NoZeroSMulDivisors k V1] {p₀ p₁ : P1} {c : k} :
    lineMap p₀ p₁ c = p₁ ↔ p₀ = p₁ ∨ c = 1 := by
  rw [← @line_map_eq_line_map_iff k V1, line_map_apply_one]
#align affine_map.line_map_eq_right_iff AffineMap.lineMap_eq_right_iff
-/

variable (k)

#print AffineMap.lineMap_injective /-
theorem lineMap_injective [NoZeroSMulDivisors k V1] {p₀ p₁ : P1} (h : p₀ ≠ p₁) :
    Function.Injective (lineMap p₀ p₁ : k → P1) := fun c₁ c₂ hc =>
  (lineMap_eq_lineMap_iff.mp hc).resolve_left h
#align affine_map.line_map_injective AffineMap.lineMap_injective
-/

variable {k}

#print AffineMap.apply_lineMap /-
@[simp]
theorem apply_lineMap (f : P1 →ᵃ[k] P2) (p₀ p₁ : P1) (c : k) :
    f (lineMap p₀ p₁ c) = lineMap (f p₀) (f p₁) c := by simp [line_map_apply]
#align affine_map.apply_line_map AffineMap.apply_lineMap
-/

#print AffineMap.comp_lineMap /-
@[simp]
theorem comp_lineMap (f : P1 →ᵃ[k] P2) (p₀ p₁ : P1) :
    f.comp (lineMap p₀ p₁) = lineMap (f p₀) (f p₁) :=
  ext <| f.apply_lineMap p₀ p₁
#align affine_map.comp_line_map AffineMap.comp_lineMap
-/

#print AffineMap.fst_lineMap /-
@[simp]
theorem fst_lineMap (p₀ p₁ : P1 × P2) (c : k) : (lineMap p₀ p₁ c).1 = lineMap p₀.1 p₁.1 c :=
  fst.apply_lineMap p₀ p₁ c
#align affine_map.fst_line_map AffineMap.fst_lineMap
-/

#print AffineMap.snd_lineMap /-
@[simp]
theorem snd_lineMap (p₀ p₁ : P1 × P2) (c : k) : (lineMap p₀ p₁ c).2 = lineMap p₀.2 p₁.2 c :=
  snd.apply_lineMap p₀ p₁ c
#align affine_map.snd_line_map AffineMap.snd_lineMap
-/

#print AffineMap.lineMap_symm /-
theorem lineMap_symm (p₀ p₁ : P1) :
    lineMap p₀ p₁ = (lineMap p₁ p₀).comp (lineMap (1 : k) (0 : k)) := by rw [comp_line_map]; simp
#align affine_map.line_map_symm AffineMap.lineMap_symm
-/

#print AffineMap.lineMap_apply_one_sub /-
theorem lineMap_apply_one_sub (p₀ p₁ : P1) (c : k) : lineMap p₀ p₁ (1 - c) = lineMap p₁ p₀ c := by
  rw [line_map_symm p₀, comp_apply]; congr; simp [line_map_apply]
#align affine_map.line_map_apply_one_sub AffineMap.lineMap_apply_one_sub
-/

#print AffineMap.lineMap_vsub_left /-
@[simp]
theorem lineMap_vsub_left (p₀ p₁ : P1) (c : k) : lineMap p₀ p₁ c -ᵥ p₀ = c • (p₁ -ᵥ p₀) :=
  vadd_vsub _ _
#align affine_map.line_map_vsub_left AffineMap.lineMap_vsub_left
-/

#print AffineMap.left_vsub_lineMap /-
@[simp]
theorem left_vsub_lineMap (p₀ p₁ : P1) (c : k) : p₀ -ᵥ lineMap p₀ p₁ c = c • (p₀ -ᵥ p₁) := by
  rw [← neg_vsub_eq_vsub_rev, line_map_vsub_left, ← smul_neg, neg_vsub_eq_vsub_rev]
#align affine_map.left_vsub_line_map AffineMap.left_vsub_lineMap
-/

#print AffineMap.lineMap_vsub_right /-
@[simp]
theorem lineMap_vsub_right (p₀ p₁ : P1) (c : k) : lineMap p₀ p₁ c -ᵥ p₁ = (1 - c) • (p₀ -ᵥ p₁) := by
  rw [← line_map_apply_one_sub, line_map_vsub_left]
#align affine_map.line_map_vsub_right AffineMap.lineMap_vsub_right
-/

#print AffineMap.right_vsub_lineMap /-
@[simp]
theorem right_vsub_lineMap (p₀ p₁ : P1) (c : k) : p₁ -ᵥ lineMap p₀ p₁ c = (1 - c) • (p₁ -ᵥ p₀) := by
  rw [← line_map_apply_one_sub, left_vsub_line_map]
#align affine_map.right_vsub_line_map AffineMap.right_vsub_lineMap
-/

#print AffineMap.lineMap_vadd_lineMap /-
theorem lineMap_vadd_lineMap (v₁ v₂ : V1) (p₁ p₂ : P1) (c : k) :
    lineMap v₁ v₂ c +ᵥ lineMap p₁ p₂ c = lineMap (v₁ +ᵥ p₁) (v₂ +ᵥ p₂) c :=
  ((fst : V1 × P1 →ᵃ[k] V1) +ᵥ snd).apply_lineMap (v₁, p₁) (v₂, p₂) c
#align affine_map.line_map_vadd_line_map AffineMap.lineMap_vadd_lineMap
-/

#print AffineMap.lineMap_vsub_lineMap /-
theorem lineMap_vsub_lineMap (p₁ p₂ p₃ p₄ : P1) (c : k) :
    lineMap p₁ p₂ c -ᵥ lineMap p₃ p₄ c = lineMap (p₁ -ᵥ p₃) (p₂ -ᵥ p₄) c :=
  letI : affine_space (V1 × V1) (P1 × P1) := Prod.addTorsor
  ((fst : P1 × P1 →ᵃ[k] P1) -ᵥ (snd : P1 × P1 →ᵃ[k] P1)).apply_lineMap (_, _) (_, _) c
#align affine_map.line_map_vsub_line_map AffineMap.lineMap_vsub_lineMap
-/

#print AffineMap.decomp /-
/-- Decomposition of an affine map in the special case when the point space and vector space
are the same. -/
theorem decomp (f : V1 →ᵃ[k] V2) : (f : V1 → V2) = f.linear + fun z => f 0 :=
  by
  ext x
  calc
    f x = f.linear x +ᵥ f 0 := by simp [← f.map_vadd]
    _ = (f.linear.to_fun + fun z : V1 => f 0) x := by simp
#align affine_map.decomp AffineMap.decomp
-/

#print AffineMap.decomp' /-
/-- Decomposition of an affine map in the special case when the point space and vector space
are the same. -/
theorem decomp' (f : V1 →ᵃ[k] V2) : (f.linear : V1 → V2) = f - fun z => f 0 := by
  rw [decomp] <;> simp only [LinearMap.map_zero, Pi.add_apply, add_sub_cancel, zero_add]
#align affine_map.decomp' AffineMap.decomp'
-/

#print AffineMap.image_uIcc /-
theorem image_uIcc {k : Type _} [LinearOrderedField k] (f : k →ᵃ[k] k) (a b : k) :
    f '' Set.uIcc a b = Set.uIcc (f a) (f b) :=
  by
  have : ⇑f = (fun x => x + f 0) ∘ fun x => x * (f 1 - f 0) :=
    by
    ext x
    change f x = x • (f 1 -ᵥ f 0) +ᵥ f 0
    rw [← f.linear_map_vsub, ← f.linear.map_smul, ← f.map_vadd]
    simp only [vsub_eq_sub, add_zero, mul_one, vadd_eq_add, sub_zero, smul_eq_mul]
  rw [this, Set.image_comp]
  simp only [Set.image_add_const_uIcc, Set.image_mul_const_uIcc]
#align affine_map.image_uIcc AffineMap.image_uIcc
-/

section

variable {ι : Type _} {V : ∀ i : ι, Type _} {P : ∀ i : ι, Type _} [∀ i, AddCommGroup (V i)]
  [∀ i, Module k (V i)] [∀ i, AddTorsor (V i) (P i)]

#print AffineMap.proj /-
/-- Evaluation at a point as an affine map. -/
def proj (i : ι) : (∀ i : ι, P i) →ᵃ[k] P i
    where
  toFun f := f i
  linear := @LinearMap.proj k ι _ V _ _ i
  map_vadd' p v := rfl
#align affine_map.proj AffineMap.proj
-/

#print AffineMap.proj_apply /-
@[simp]
theorem proj_apply (i : ι) (f : ∀ i, P i) : @proj k _ ι V P _ _ _ i f = f i :=
  rfl
#align affine_map.proj_apply AffineMap.proj_apply
-/

#print AffineMap.proj_linear /-
@[simp]
theorem proj_linear (i : ι) : (@proj k _ ι V P _ _ _ i).linear = @LinearMap.proj k ι _ V _ _ i :=
  rfl
#align affine_map.proj_linear AffineMap.proj_linear
-/

#print AffineMap.pi_lineMap_apply /-
theorem pi_lineMap_apply (f g : ∀ i, P i) (c : k) (i : ι) :
    lineMap f g c i = lineMap (f i) (g i) c :=
  (proj i : (∀ i, P i) →ᵃ[k] P i).apply_lineMap f g c
#align affine_map.pi_line_map_apply AffineMap.pi_lineMap_apply
-/

end

end AffineMap

namespace AffineMap

variable {R k V1 P1 V2 : Type _}

section Ring

variable [Ring k] [AddCommGroup V1] [affine_space V1 P1] [AddCommGroup V2]

variable [Module k V1] [Module k V2]

section DistribMulAction

variable [Monoid R] [DistribMulAction R V2] [SMulCommClass k R V2]

/-- The space of affine maps to a module inherits an `R`-action from the action on its codomain. -/
instance : DistribMulAction R (P1 →ᵃ[k] V2)
    where
  smul_add c f g := ext fun p => smul_add _ _ _
  smul_zero c := ext fun p => smul_zero _

end DistribMulAction

section Module

variable [Semiring R] [Module R V2] [SMulCommClass k R V2]

/-- The space of affine maps taking values in an `R`-module is an `R`-module. -/
instance : Module R (P1 →ᵃ[k] V2) :=
  { AffineMap.distribMulAction with
    smul := (· • ·)
    add_smul := fun c₁ c₂ f => ext fun p => add_smul _ _ _
    zero_smul := fun f => ext fun p => zero_smul _ _ }

variable (R)

#print AffineMap.toConstProdLinearMap /-
/-- The space of affine maps between two modules is linearly equivalent to the product of the
domain with the space of linear maps, by taking the value of the affine map at `(0 : V1)` and the
linear part.

See note [bundled maps over different rings]-/
@[simps]
def toConstProdLinearMap : (V1 →ᵃ[k] V2) ≃ₗ[R] V2 × (V1 →ₗ[k] V2)
    where
  toFun f := ⟨f 0, f.linear⟩
  invFun p := p.2.toAffineMap + const k V1 p.1
  left_inv f := by ext; rw [f.decomp]; simp
  right_inv := by rintro ⟨v, f⟩; ext <;> simp
  map_add' := by simp
  map_smul' := by simp
#align affine_map.to_const_prod_linear_map AffineMap.toConstProdLinearMap
-/

end Module

end Ring

section CommRing

variable [CommRing k] [AddCommGroup V1] [affine_space V1 P1] [AddCommGroup V2]

variable [Module k V1] [Module k V2]

#print AffineMap.homothety /-
/-- `homothety c r` is the homothety (also known as dilation) about `c` with scale factor `r`. -/
def homothety (c : P1) (r : k) : P1 →ᵃ[k] P1 :=
  r • (id k P1 -ᵥ const k P1 c) +ᵥ const k P1 c
#align affine_map.homothety AffineMap.homothety
-/

#print AffineMap.homothety_def /-
theorem homothety_def (c : P1) (r : k) :
    homothety c r = r • (id k P1 -ᵥ const k P1 c) +ᵥ const k P1 c :=
  rfl
#align affine_map.homothety_def AffineMap.homothety_def
-/

#print AffineMap.homothety_apply /-
theorem homothety_apply (c : P1) (r : k) (p : P1) : homothety c r p = r • (p -ᵥ c : V1) +ᵥ c :=
  rfl
#align affine_map.homothety_apply AffineMap.homothety_apply
-/

#print AffineMap.homothety_eq_lineMap /-
theorem homothety_eq_lineMap (c : P1) (r : k) (p : P1) : homothety c r p = lineMap c p r :=
  rfl
#align affine_map.homothety_eq_line_map AffineMap.homothety_eq_lineMap
-/

#print AffineMap.homothety_one /-
@[simp]
theorem homothety_one (c : P1) : homothety c (1 : k) = id k P1 := by ext p; simp [homothety_apply]
#align affine_map.homothety_one AffineMap.homothety_one
-/

#print AffineMap.homothety_apply_same /-
@[simp]
theorem homothety_apply_same (c : P1) (r : k) : homothety c r c = c :=
  lineMap_same_apply c r
#align affine_map.homothety_apply_same AffineMap.homothety_apply_same
-/

#print AffineMap.homothety_mul_apply /-
theorem homothety_mul_apply (c : P1) (r₁ r₂ : k) (p : P1) :
    homothety c (r₁ * r₂) p = homothety c r₁ (homothety c r₂ p) := by
  simp [homothety_apply, mul_smul]
#align affine_map.homothety_mul_apply AffineMap.homothety_mul_apply
-/

#print AffineMap.homothety_mul /-
theorem homothety_mul (c : P1) (r₁ r₂ : k) :
    homothety c (r₁ * r₂) = (homothety c r₁).comp (homothety c r₂) :=
  ext <| homothety_mul_apply c r₁ r₂
#align affine_map.homothety_mul AffineMap.homothety_mul
-/

#print AffineMap.homothety_zero /-
@[simp]
theorem homothety_zero (c : P1) : homothety c (0 : k) = const k P1 c := by ext p;
  simp [homothety_apply]
#align affine_map.homothety_zero AffineMap.homothety_zero
-/

#print AffineMap.homothety_add /-
@[simp]
theorem homothety_add (c : P1) (r₁ r₂ : k) :
    homothety c (r₁ + r₂) = r₁ • (id k P1 -ᵥ const k P1 c) +ᵥ homothety c r₂ := by
  simp only [homothety_def, add_smul, vadd_vadd]
#align affine_map.homothety_add AffineMap.homothety_add
-/

#print AffineMap.homothetyHom /-
/-- `homothety` as a multiplicative monoid homomorphism. -/
def homothetyHom (c : P1) : k →* P1 →ᵃ[k] P1 :=
  ⟨homothety c, homothety_one c, homothety_mul c⟩
#align affine_map.homothety_hom AffineMap.homothetyHom
-/

#print AffineMap.coe_homothetyHom /-
@[simp]
theorem coe_homothetyHom (c : P1) : ⇑(homothetyHom c : k →* _) = homothety c :=
  rfl
#align affine_map.coe_homothety_hom AffineMap.coe_homothetyHom
-/

#print AffineMap.homothetyAffine /-
/-- `homothety` as an affine map. -/
def homothetyAffine (c : P1) : k →ᵃ[k] P1 →ᵃ[k] P1 :=
  ⟨homothety c, (LinearMap.lsmul k _).flip (id k P1 -ᵥ const k P1 c),
    Function.swap (homothety_add c)⟩
#align affine_map.homothety_affine AffineMap.homothetyAffine
-/

#print AffineMap.coe_homothetyAffine /-
@[simp]
theorem coe_homothetyAffine (c : P1) : ⇑(homothetyAffine c : k →ᵃ[k] _) = homothety c :=
  rfl
#align affine_map.coe_homothety_affine AffineMap.coe_homothetyAffine
-/

end CommRing

end AffineMap

section

variable {𝕜 E F : Type _} [Ring 𝕜] [AddCommGroup E] [AddCommGroup F] [Module 𝕜 E] [Module 𝕜 F]

#print Convex.combo_affine_apply /-
/-- Applying an affine map to an affine combination of two points yields an affine combination of
the images. -/
theorem Convex.combo_affine_apply {x y : E} {a b : 𝕜} {f : E →ᵃ[𝕜] F} (h : a + b = 1) :
    f (a • x + b • y) = a • f x + b • f y := by
  simp only [Convex.combo_eq_smul_sub_add h, ← vsub_eq_sub]; exact f.apply_line_map _ _ _
#align convex.combo_affine_apply Convex.combo_affine_apply
-/

end

