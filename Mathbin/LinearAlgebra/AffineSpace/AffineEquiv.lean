import Mathbin.LinearAlgebra.AffineSpace.AffineMap 
import Mathbin.Algebra.Invertible

/-!
# Affine equivalences

In this file we define `affine_equiv k P₁ P₂` (notation: `P₁ ≃ᵃ[k] P₂`) to be the type of affine
equivalences between `P₁` and `P₂, i.e., equivalences such that both forward and inverse maps are
affine maps.

We define the following equivalences:

* `affine_equiv.refl k P`: the identity map as an `affine_equiv`;

* `e.symm`: the inverse map of an `affine_equiv` as an `affine_equiv`;

* `e.trans e'`: composition of two `affine_equiv`s; note that the order follows `mathlib`'s
  `category_theory` convention (apply `e`, then `e'`), not the convention used in function
  composition and compositions of bundled morphisms.

## Tags

affine space, affine equivalence
-/


open Function Set

open_locale Affine

/-- An affine equivalence is an equivalence between affine spaces such that both forward
and inverse maps are affine.

We define it using an `equiv` for the map and a `linear_equiv` for the linear part in order
to allow affine equivalences with good definitional equalities. -/
@[nolint has_inhabited_instance]
structure
  AffineEquiv(k P₁ P₂ :
    Type
      _){V₁ V₂ :
    Type
      _}[Ringₓ
      k][AddCommGroupₓ V₁][Module k V₁][AddTorsor V₁ P₁][AddCommGroupₓ V₂][Module k V₂][AddTorsor V₂ P₂] extends
  P₁ ≃ P₂ where 
  linear : V₁ ≃ₗ[k] V₂ 
  map_vadd' : ∀ (p : P₁) (v : V₁), to_equiv (v +ᵥ p) = linear v +ᵥ to_equiv p

notation:25 P₁ " ≃ᵃ[" k:25 "] " P₂:0 => AffineEquiv k P₁ P₂

variable{k V₁ V₂ V₃ V₄ P₁ P₂ P₃ P₄ :
    Type
      _}[Ringₓ
      k][AddCommGroupₓ
      V₁][Module k
      V₁][AddTorsor V₁
      P₁][AddCommGroupₓ
      V₂][Module k
      V₂][AddTorsor V₂
      P₂][AddCommGroupₓ V₃][Module k V₃][AddTorsor V₃ P₃][AddCommGroupₓ V₄][Module k V₄][AddTorsor V₄ P₄]

namespace AffineEquiv

include V₁ V₂

instance  : CoeFun (P₁ ≃ᵃ[k] P₂) fun _ => P₁ → P₂ :=
  ⟨fun e => e.to_fun⟩

instance  : Coe (P₁ ≃ᵃ[k] P₂) (P₁ ≃ P₂) :=
  ⟨AffineEquiv.toEquiv⟩

variable(k P₁)

omit V₂

/-- Identity map as an `affine_equiv`. -/
@[refl]
def refl : P₁ ≃ᵃ[k] P₁ :=
  { toEquiv := Equiv.refl P₁, linear := LinearEquiv.refl k V₁, map_vadd' := fun _ _ => rfl }

@[simp]
theorem coe_refl : «expr⇑ » (refl k P₁) = id :=
  rfl

theorem refl_apply (x : P₁) : refl k P₁ x = x :=
  rfl

@[simp]
theorem to_equiv_refl : (refl k P₁).toEquiv = Equiv.refl P₁ :=
  rfl

@[simp]
theorem linear_refl : (refl k P₁).linear = LinearEquiv.refl k V₁ :=
  rfl

variable{k P₁}

include V₂

@[simp]
theorem map_vadd (e : P₁ ≃ᵃ[k] P₂) (p : P₁) (v : V₁) : e (v +ᵥ p) = e.linear v +ᵥ e p :=
  e.map_vadd' p v

@[simp]
theorem coe_to_equiv (e : P₁ ≃ᵃ[k] P₂) : «expr⇑ » e.to_equiv = e :=
  rfl

/-- Reinterpret an `affine_equiv` as an `affine_map`. -/
def to_affine_map (e : P₁ ≃ᵃ[k] P₂) : P₁ →ᵃ[k] P₂ :=
  { e with toFun := e }

instance  : Coe (P₁ ≃ᵃ[k] P₂) (P₁ →ᵃ[k] P₂) :=
  ⟨to_affine_map⟩

@[simp]
theorem coe_to_affine_map (e : P₁ ≃ᵃ[k] P₂) : (e.to_affine_map : P₁ → P₂) = (e : P₁ → P₂) :=
  rfl

@[simp]
theorem to_affine_map_mk (f : P₁ ≃ P₂) (f' : V₁ ≃ₗ[k] V₂) h : to_affine_map (mk f f' h) = ⟨f, f', h⟩ :=
  rfl

@[normCast, simp]
theorem coe_coe (e : P₁ ≃ᵃ[k] P₂) : ((e : P₁ →ᵃ[k] P₂) : P₁ → P₂) = e :=
  rfl

@[simp]
theorem linear_to_affine_map (e : P₁ ≃ᵃ[k] P₂) : e.to_affine_map.linear = e.linear :=
  rfl

theorem to_affine_map_injective : injective (to_affine_map : (P₁ ≃ᵃ[k] P₂) → P₁ →ᵃ[k] P₂) :=
  by 
    rintro ⟨e, el, h⟩ ⟨e', el', h'⟩ H 
    simp only [to_affine_map_mk, Equiv.coe_inj, LinearEquiv.to_linear_map_inj] at H 
    congr 
    exacts[H.1, H.2]

@[simp]
theorem to_affine_map_inj {e e' : P₁ ≃ᵃ[k] P₂} : e.to_affine_map = e'.to_affine_map ↔ e = e' :=
  to_affine_map_injective.eq_iff

@[ext]
theorem ext {e e' : P₁ ≃ᵃ[k] P₂} (h : ∀ x, e x = e' x) : e = e' :=
  to_affine_map_injective$ AffineMap.ext h

theorem coe_fn_injective : @injective (P₁ ≃ᵃ[k] P₂) (P₁ → P₂) coeFn :=
  fun e e' H => ext$ congr_funₓ H

@[simp, normCast]
theorem coe_fn_inj {e e' : P₁ ≃ᵃ[k] P₂} : (e : P₁ → P₂) = e' ↔ e = e' :=
  coe_fn_injective.eq_iff

theorem to_equiv_injective : injective (to_equiv : (P₁ ≃ᵃ[k] P₂) → P₁ ≃ P₂) :=
  fun e e' H => ext$ Equiv.ext_iff.1 H

@[simp]
theorem to_equiv_inj {e e' : P₁ ≃ᵃ[k] P₂} : e.to_equiv = e'.to_equiv ↔ e = e' :=
  to_equiv_injective.eq_iff

@[simp]
theorem coe_mk (e : P₁ ≃ P₂) (e' : V₁ ≃ₗ[k] V₂) h : ((⟨e, e', h⟩ : P₁ ≃ᵃ[k] P₂) : P₁ → P₂) = e :=
  rfl

-- error in LinearAlgebra.AffineSpace.AffineEquiv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Construct an affine equivalence by verifying the relation between the map and its linear part at
one base point. Namely, this function takes a map `e : P₁ → P₂`, a linear equivalence
`e' : V₁ ≃ₗ[k] V₂`, and a point `p` such that for any other point `p'` we have
`e p' = e' (p' -ᵥ p) +ᵥ e p`. -/
def mk'
(e : P₁ → P₂)
(e' : «expr ≃ₗ[ ] »(V₁, k, V₂))
(p : P₁)
(h : ∀ p' : P₁, «expr = »(e p', «expr +ᵥ »(e' «expr -ᵥ »(p', p), e p))) : «expr ≃ᵃ[ ] »(P₁, k, P₂) :=
{ to_fun := e,
  inv_fun := λ q' : P₂, «expr +ᵥ »(e'.symm «expr -ᵥ »(q', e p), p),
  left_inv := λ p', by simp [] [] [] ["[", expr h p', "]"] [] [],
  right_inv := λ q', by simp [] [] [] ["[", expr h «expr +ᵥ »(e'.symm «expr -ᵥ »(q', e p), p), "]"] [] [],
  linear := e',
  map_vadd' := λ
  p'
  v, by { simp [] [] [] ["[", expr h p', ",", expr h «expr +ᵥ »(v, p'), ",", expr vadd_vsub_assoc, ",", expr vadd_vadd, "]"] [] [] } }

@[simp]
theorem coe_mk' (e : P₁ ≃ P₂) (e' : V₁ ≃ₗ[k] V₂) p h : «expr⇑ » (mk' e e' p h) = e :=
  rfl

@[simp]
theorem linear_mk' (e : P₁ ≃ P₂) (e' : V₁ ≃ₗ[k] V₂) p h : (mk' e e' p h).linear = e' :=
  rfl

/-- Inverse of an affine equivalence as an affine equivalence. -/
@[symm]
def symm (e : P₁ ≃ᵃ[k] P₂) : P₂ ≃ᵃ[k] P₁ :=
  { toEquiv := e.to_equiv.symm, linear := e.linear.symm,
    map_vadd' :=
      fun v p =>
        e.to_equiv.symm.apply_eq_iff_eq_symm_apply.2$
          by 
            simpa using (e.to_equiv.apply_symm_apply v).symm }

@[simp]
theorem symm_to_equiv (e : P₁ ≃ᵃ[k] P₂) : e.to_equiv.symm = e.symm.to_equiv :=
  rfl

@[simp]
theorem symm_linear (e : P₁ ≃ᵃ[k] P₂) : e.linear.symm = e.symm.linear :=
  rfl

protected theorem bijective (e : P₁ ≃ᵃ[k] P₂) : bijective e :=
  e.to_equiv.bijective

protected theorem surjective (e : P₁ ≃ᵃ[k] P₂) : surjective e :=
  e.to_equiv.surjective

protected theorem injective (e : P₁ ≃ᵃ[k] P₂) : injective e :=
  e.to_equiv.injective

@[simp]
theorem range_eq (e : P₁ ≃ᵃ[k] P₂) : range e = univ :=
  e.surjective.range_eq

@[simp]
theorem apply_symm_apply (e : P₁ ≃ᵃ[k] P₂) (p : P₂) : e (e.symm p) = p :=
  e.to_equiv.apply_symm_apply p

@[simp]
theorem symm_apply_apply (e : P₁ ≃ᵃ[k] P₂) (p : P₁) : e.symm (e p) = p :=
  e.to_equiv.symm_apply_apply p

theorem apply_eq_iff_eq_symm_apply (e : P₁ ≃ᵃ[k] P₂) {p₁ p₂} : e p₁ = p₂ ↔ p₁ = e.symm p₂ :=
  e.to_equiv.apply_eq_iff_eq_symm_apply

@[simp]
theorem apply_eq_iff_eq (e : P₁ ≃ᵃ[k] P₂) {p₁ p₂ : P₁} : e p₁ = e p₂ ↔ p₁ = p₂ :=
  e.to_equiv.apply_eq_iff_eq

omit V₂

@[simp]
theorem symm_refl : (refl k P₁).symm = refl k P₁ :=
  rfl

include V₂ V₃

/-- Composition of two `affine_equiv`alences, applied left to right. -/
@[trans]
def trans (e : P₁ ≃ᵃ[k] P₂) (e' : P₂ ≃ᵃ[k] P₃) : P₁ ≃ᵃ[k] P₃ :=
  { toEquiv := e.to_equiv.trans e'.to_equiv, linear := e.linear.trans e'.linear,
    map_vadd' :=
      fun p v =>
        by 
          simp only [LinearEquiv.trans_apply, coe_to_equiv, · ∘ ·, Equiv.coe_trans, map_vadd] }

@[simp]
theorem coeTransₓ (e : P₁ ≃ᵃ[k] P₂) (e' : P₂ ≃ᵃ[k] P₃) : «expr⇑ » (e.trans e') = e' ∘ e :=
  rfl

theorem trans_apply (e : P₁ ≃ᵃ[k] P₂) (e' : P₂ ≃ᵃ[k] P₃) (p : P₁) : e.trans e' p = e' (e p) :=
  rfl

include V₄

theorem trans_assoc (e₁ : P₁ ≃ᵃ[k] P₂) (e₂ : P₂ ≃ᵃ[k] P₃) (e₃ : P₃ ≃ᵃ[k] P₄) :
  (e₁.trans e₂).trans e₃ = e₁.trans (e₂.trans e₃) :=
  ext$ fun _ => rfl

omit V₃ V₄

@[simp]
theorem trans_refl (e : P₁ ≃ᵃ[k] P₂) : e.trans (refl k P₂) = e :=
  ext$ fun _ => rfl

@[simp]
theorem refl_trans (e : P₁ ≃ᵃ[k] P₂) : (refl k P₁).trans e = e :=
  ext$ fun _ => rfl

@[simp]
theorem self_trans_symm (e : P₁ ≃ᵃ[k] P₂) : e.trans e.symm = refl k P₁ :=
  ext e.symm_apply_apply

@[simp]
theorem symm_trans_self (e : P₁ ≃ᵃ[k] P₂) : e.symm.trans e = refl k P₂ :=
  ext e.apply_symm_apply

@[simp]
theorem apply_line_map (e : P₁ ≃ᵃ[k] P₂) (a b : P₁) (c : k) :
  e (AffineMap.lineMap a b c) = AffineMap.lineMap (e a) (e b) c :=
  e.to_affine_map.apply_line_map a b c

omit V₂

instance  : Groupₓ (P₁ ≃ᵃ[k] P₁) :=
  { one := refl k P₁, mul := fun e e' => e'.trans e, inv := symm, mul_assoc := fun e₁ e₂ e₃ => trans_assoc _ _ _,
    one_mul := trans_refl, mul_one := refl_trans, mul_left_inv := self_trans_symm }

theorem one_def : (1 : P₁ ≃ᵃ[k] P₁) = refl k P₁ :=
  rfl

@[simp]
theorem coe_one : «expr⇑ » (1 : P₁ ≃ᵃ[k] P₁) = id :=
  rfl

theorem mul_def (e e' : P₁ ≃ᵃ[k] P₁) : (e*e') = e'.trans e :=
  rfl

@[simp]
theorem coe_mul (e e' : P₁ ≃ᵃ[k] P₁) : «expr⇑ » (e*e') = e ∘ e' :=
  rfl

theorem inv_def (e : P₁ ≃ᵃ[k] P₁) : e⁻¹ = e.symm :=
  rfl

variable(k)

/-- The map `v ↦ v +ᵥ b` as an affine equivalence between a module `V` and an affine space `P` with
tangent space `V`. -/
def vadd_const (b : P₁) : V₁ ≃ᵃ[k] P₁ :=
  { toEquiv := Equiv.vaddConst b, linear := LinearEquiv.refl _ _, map_vadd' := fun p v => add_vadd _ _ _ }

@[simp]
theorem linear_vadd_const (b : P₁) : (vadd_const k b).linear = LinearEquiv.refl k V₁ :=
  rfl

@[simp]
theorem vadd_const_apply (b : P₁) (v : V₁) : vadd_const k b v = v +ᵥ b :=
  rfl

@[simp]
theorem vadd_const_symm_apply (b p : P₁) : (vadd_const k b).symm p = p -ᵥ b :=
  rfl

/-- `p' ↦ p -ᵥ p'` as an equivalence. -/
def const_vsub (p : P₁) : P₁ ≃ᵃ[k] V₁ :=
  { toEquiv := Equiv.constVsub p, linear := LinearEquiv.neg k,
    map_vadd' :=
      fun p' v =>
        by 
          simp [vsub_vadd_eq_vsub_sub, neg_add_eq_sub] }

@[simp]
theorem coe_const_vsub (p : P₁) : «expr⇑ » (const_vsub k p) = (· -ᵥ ·) p :=
  rfl

@[simp]
theorem coe_const_vsub_symm (p : P₁) : «expr⇑ » (const_vsub k p).symm = fun v => -v +ᵥ p :=
  rfl

variable(P₁)

/-- The map `p ↦ v +ᵥ p` as an affine automorphism of an affine space. -/
def const_vadd (v : V₁) : P₁ ≃ᵃ[k] P₁ :=
  { toEquiv := Equiv.constVadd P₁ v, linear := LinearEquiv.refl _ _, map_vadd' := fun p w => vadd_comm _ _ _ }

@[simp]
theorem linear_const_vadd (v : V₁) : (const_vadd k P₁ v).linear = LinearEquiv.refl _ _ :=
  rfl

@[simp]
theorem const_vadd_apply (v : V₁) (p : P₁) : const_vadd k P₁ v p = v +ᵥ p :=
  rfl

@[simp]
theorem const_vadd_symm_apply (v : V₁) (p : P₁) : (const_vadd k P₁ v).symm p = -v +ᵥ p :=
  rfl

section Homothety

omit V₁

variable{R V P : Type _}[CommRingₓ R][AddCommGroupₓ V][Module R V][affine_space V P]

include V

/-- Fixing a point in affine space, homothety about this point gives a group homomorphism from (the
centre of) the units of the scalars into the group of affine equivalences. -/
def homothety_units_mul_hom (p : P) : Units R →* P ≃ᵃ[R] P :=
  { toFun :=
      fun t =>
        { toFun := AffineMap.homothety p (t : R), invFun := AffineMap.homothety p («expr↑ » (t⁻¹) : R),
          left_inv :=
            fun p =>
              by 
                simp [←AffineMap.comp_apply, ←AffineMap.homothety_mul],
          right_inv :=
            fun p =>
              by 
                simp [←AffineMap.comp_apply, ←AffineMap.homothety_mul],
          linear :=
            { LinearMap.lsmul R V t with invFun := LinearMap.lsmul R V («expr↑ » (t⁻¹) : R),
              left_inv :=
                fun v =>
                  by 
                    simp [smul_smul],
              right_inv :=
                fun v =>
                  by 
                    simp [smul_smul] },
          map_vadd' :=
            fun p v =>
              by 
                simp only [vadd_vsub_assoc, smul_add, add_vadd, AffineMap.coe_line_map, AffineMap.homothety_eq_line_map,
                  Equiv.coe_fn_mk, LinearEquiv.coe_mk, LinearMap.lsmul_apply, LinearMap.to_fun_eq_coe] },
    map_one' :=
      by 
        ext 
        simp ,
    map_mul' :=
      fun t₁ t₂ =>
        by 
          ext 
          simp [←AffineMap.comp_apply, ←AffineMap.homothety_mul] }

@[simp]
theorem coe_homothety_units_mul_hom_apply (p : P) (t : Units R) :
  (homothety_units_mul_hom p t : P → P) = AffineMap.homothety p (t : R) :=
  rfl

@[simp]
theorem coe_homothety_units_mul_hom_apply_symm (p : P) (t : Units R) :
  ((homothety_units_mul_hom p t).symm : P → P) = AffineMap.homothety p («expr↑ » (t⁻¹) : R) :=
  rfl

@[simp]
theorem coe_homothety_units_mul_hom_eq_homothety_hom_coe (p : P) :
  (coeₓ : (P ≃ᵃ[R] P) → P →ᵃ[R] P) ∘ homothety_units_mul_hom p = AffineMap.homothetyHom p ∘ (coeₓ : Units R → R) :=
  by 
    ext 
    simp 

end Homothety

variable{P₁}

open Function

/-- Point reflection in `x` as a permutation. -/
def point_reflection (x : P₁) : P₁ ≃ᵃ[k] P₁ :=
  (const_vsub k x).trans (vadd_const k x)

theorem point_reflection_apply (x y : P₁) : point_reflection k x y = x -ᵥ y +ᵥ x :=
  rfl

@[simp]
theorem point_reflection_symm (x : P₁) : (point_reflection k x).symm = point_reflection k x :=
  to_equiv_injective$ Equiv.point_reflection_symm x

@[simp]
theorem to_equiv_point_reflection (x : P₁) : (point_reflection k x).toEquiv = Equiv.pointReflection x :=
  rfl

@[simp]
theorem point_reflection_self (x : P₁) : point_reflection k x x = x :=
  vsub_vadd _ _

theorem point_reflection_involutive (x : P₁) : involutive (point_reflection k x : P₁ → P₁) :=
  Equiv.point_reflection_involutive x

/-- `x` is the only fixed point of `point_reflection x`. This lemma requires
`x + x = y + y ↔ x = y`. There is no typeclass to use here, so we add it as an explicit argument. -/
theorem point_reflection_fixed_iff_of_injective_bit0 {x y : P₁} (h : injective (bit0 : V₁ → V₁)) :
  point_reflection k x y = y ↔ y = x :=
  Equiv.point_reflection_fixed_iff_of_injective_bit0 h

-- error in LinearAlgebra.AffineSpace.AffineEquiv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem injective_point_reflection_left_of_injective_bit0
(h : injective (bit0 : V₁ → V₁))
(y : P₁) : injective (λ x : P₁, point_reflection k x y) :=
equiv.injective_point_reflection_left_of_injective_bit0 h y

-- error in LinearAlgebra.AffineSpace.AffineEquiv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem injective_point_reflection_left_of_module
[invertible (2 : k)] : ∀ y, injective (λ x : P₁, point_reflection k x y) :=
«expr $ »(injective_point_reflection_left_of_injective_bit0 k, λ
 x
 y
 h, by rwa ["[", expr bit0, ",", expr bit0, ",", "<-", expr two_smul k x, ",", "<-", expr two_smul k y, ",", expr (is_unit_of_invertible (2 : k)).smul_left_cancel, "]"] ["at", ident h])

theorem point_reflection_fixed_iff_of_module [Invertible (2 : k)] {x y : P₁} : point_reflection k x y = y ↔ y = x :=
  ((injective_point_reflection_left_of_module k y).eq_iff' (point_reflection_self k y)).trans eq_comm

end AffineEquiv

namespace LinearEquiv

/-- Interpret a linear equivalence between modules as an affine equivalence. -/
def to_affine_equiv (e : V₁ ≃ₗ[k] V₂) : V₁ ≃ᵃ[k] V₂ :=
  { toEquiv := e.to_equiv, linear := e, map_vadd' := fun p v => e.map_add v p }

@[simp]
theorem coe_to_affine_equiv (e : V₁ ≃ₗ[k] V₂) : «expr⇑ » e.to_affine_equiv = e :=
  rfl

end LinearEquiv

namespace AffineMap

open AffineEquiv

include V₁

theorem line_map_vadd (v v' : V₁) (p : P₁) (c : k) : line_map v v' c +ᵥ p = line_map (v +ᵥ p) (v' +ᵥ p) c :=
  (vadd_const k p).apply_line_map v v' c

theorem line_map_vsub (p₁ p₂ p₃ : P₁) (c : k) : line_map p₁ p₂ c -ᵥ p₃ = line_map (p₁ -ᵥ p₃) (p₂ -ᵥ p₃) c :=
  (vadd_const k p₃).symm.apply_line_map p₁ p₂ c

theorem vsub_line_map (p₁ p₂ p₃ : P₁) (c : k) : p₁ -ᵥ line_map p₂ p₃ c = line_map (p₁ -ᵥ p₂) (p₁ -ᵥ p₃) c :=
  (const_vsub k p₁).apply_line_map p₂ p₃ c

theorem vadd_line_map (v : V₁) (p₁ p₂ : P₁) (c : k) : v +ᵥ line_map p₁ p₂ c = line_map (v +ᵥ p₁) (v +ᵥ p₂) c :=
  (const_vadd k P₁ v).apply_line_map p₁ p₂ c

variable{R' : Type _}[CommRingₓ R'][Module R' V₁]

theorem homothety_neg_one_apply (c p : P₁) : homothety c (-1 : R') p = point_reflection R' c p :=
  by 
    simp [homothety_apply, point_reflection_apply]

end AffineMap

