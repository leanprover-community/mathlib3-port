import Mathbin.RingTheory.EuclideanDomain 
import Mathbin.RingTheory.Localization

/-!
# The field of rational functions

This file defines the field `ratfunc K` of rational functions over a field `K`,
and shows it is the field of fractions of `polynomial K`.

## Main definitions

Working with rational functions as polynomials:
 - `ratfunc.field` provides a field structure
 - `ratfunc.C` is the constant polynomial
 - `ratfunc.X` is the indeterminate
 - `ratfunc.eval` evaluates a rational function given a value for the indeterminate
Use `algebra_map` to map polynomials to rational functions and `is_fraction_ring.alg_equiv`
to map other fields of fractions of `polynomial K` to `ratfunc K`.

Working with rational functions as fractions:
 - `ratfunc.num` and `ratfunc.denom` give the numerator and denominator.
   These values are chosen to be coprime and such that `ratfunc.denom` is monic.

We also have a set of recursion and induction principles:
 - `ratfunc.lift_on`: define a function by mapping a fraction of polynomials `p/q` to `f p q`,
   if `f` is well-defined in the sense that `p/q = p'/q' → f p q = f p' q'`.
 - `ratfunc.lift_on'`: define a function by mapping a fraction of polynomials `p/q` to `f p q`,
   if `f` is well-defined in the sense that `f (a * p) (a * q) = f p' q'`.
 - `ratfunc.induction_on`: if `P` holds on `p / q` for all polynomials `p q`, then `P` holds on all
   rational functions

## Implementation notes

To provide good API encapsulation and speed up unification problems,
`ratfunc` is defined as a structure, and all operations are `@[irreducible] def`s

We need a couple of maps to set up the `field` and `is_fraction_ring` structure,
namely `ratfunc.of_fraction_ring`, `ratfunc.to_fraction_ring`, `ratfunc.mk` and
`ratfunc.aux_equiv`.
All these maps get `simp`ed to bundled morphisms like `algebra_map (polynomial K) (ratfunc K)`
and `is_localization.alg_equiv`.
-/


noncomputable theory

open_locale Classical

open_locale nonZeroDivisors

universe u v

variable (K : Type u) [hring : CommRingₓ K] [hdomain : IsDomain K]

include hring

/-- `ratfunc K` is `K(x)`, the field of rational functions over `K`.

The inclusion of polynomials into `ratfunc` is `algebra_map (polynomial K) (ratfunc K)`,
the maps between `ratfunc K` and another field of fractions of `polynomial K`,
especially `fraction_ring (polynomial K)`, are given by `is_localization.algebra_equiv`.
-/
structure Ratfunc : Type u where of_fraction_ring :: 
  toFractionRing : FractionRing (Polynomial K)

namespace Ratfunc

variable {K}

section Rec

/-! ### Constructing `ratfunc`s and their induction principles -/


theorem of_fraction_ring_injective : Function.Injective (of_fraction_ring : _ → Ratfunc K) :=
  fun x y => of_fraction_ring.inj

theorem to_fraction_ring_injective : Function.Injective (to_fraction_ring : _ → FractionRing (Polynomial K))
| ⟨x⟩, ⟨y⟩, rfl => rfl

include hdomain

/-- `ratfunc.mk (p q : polynomial K)` is `p / q` as a rational function.

If `q = 0`, then `mk` returns 0.

This is an auxiliary definition used to define an `algebra` structure on `ratfunc`;
the `simp` normal form of `mk p q` is `algebra_map _ _ p / algebra_map _ _ q`.
-/
protected irreducible_def mk (p q : Polynomial K) : Ratfunc K :=
  of_fraction_ring (algebraMap _ _ p / algebraMap _ _ q)

theorem mk_eq_div' (p q : Polynomial K) : Ratfunc.mk p q = of_fraction_ring (algebraMap _ _ p / algebraMap _ _ q) :=
  by 
    unfold Ratfunc.mk

theorem mk_zero (p : Polynomial K) : Ratfunc.mk p 0 = of_fraction_ring 0 :=
  by 
    rw [mk_eq_div', RingHom.map_zero, div_zero]

theorem mk_coe_def (p : Polynomial K) (q : (Polynomial K)⁰) :
  Ratfunc.mk p q = of_fraction_ring (IsLocalization.mk' _ p q) :=
  by 
    simp only [mk_eq_div', ←Localization.mk_eq_mk', FractionRing.mk_eq_div]

theorem mk_def_of_mem (p : Polynomial K) {q} (hq : q ∈ (Polynomial K)⁰) :
  Ratfunc.mk p q = of_fraction_ring (IsLocalization.mk' _ p ⟨q, hq⟩) :=
  by 
    simp only [←mk_coe_def, SetLike.coe_mk]

theorem mk_def_of_ne (p : Polynomial K) {q : Polynomial K} (hq : q ≠ 0) :
  Ratfunc.mk p q = of_fraction_ring (IsLocalization.mk' _ p ⟨q, mem_non_zero_divisors_iff_ne_zero.mpr hq⟩) :=
  mk_def_of_mem p _

theorem mk_eq_localization_mk (p : Polynomial K) {q : Polynomial K} (hq : q ≠ 0) :
  Ratfunc.mk p q = of_fraction_ring (Localization.mk p ⟨q, mem_non_zero_divisors_iff_ne_zero.mpr hq⟩) :=
  by 
    rw [mk_def_of_ne, Localization.mk_eq_mk']

theorem mk_one' (p : Polynomial K) : Ratfunc.mk p 1 = of_fraction_ring (algebraMap _ _ p) :=
  by 
    rw [←IsLocalization.mk'_one (FractionRing (Polynomial K)) p, ←mk_coe_def, Submonoid.coe_one]

theorem mk_eq_mk {p q p' q' : Polynomial K} (hq : q ≠ 0) (hq' : q' ≠ 0) :
  Ratfunc.mk p q = Ratfunc.mk p' q' ↔ (p*q') = p'*q :=
  by 
    rw [mk_def_of_ne _ hq, mk_def_of_ne _ hq', of_fraction_ring_injective.eq_iff, IsLocalization.mk'_eq_iff_eq,
      SetLike.coe_mk, SetLike.coe_mk, (IsFractionRing.injective (Polynomial K) (FractionRing (Polynomial K))).eq_iff]

/-- Non-dependent recursion principle for `ratfunc K`: if `f p q : P` for all `p q`,
such that `p * q' = p' * q` implies `f p q = f p' q'`, then we can find a value of `P`
for all elements of `ratfunc K` by setting `lift_on (p / q) f _ = f p q`.

The value of `f p 0` for any `p` is never used and in principle this may be anything,
although many usages of `lift_on` assume `f p 0 = f 0 1`.
-/
protected irreducible_def lift_on {P : Sort v} (x : Ratfunc K) (f : ∀ p q : Polynomial K, P)
  (H : ∀ {p q p' q'} hq : q ≠ 0 hq' : q' ≠ 0, ((p*q') = p'*q) → f p q = f p' q') : P :=
  Localization.liftOn (to_fraction_ring x) (fun p q => f p q)
    fun p p' q q' h =>
      H (mem_non_zero_divisors_iff_ne_zero.mp q.2) (mem_non_zero_divisors_iff_ne_zero.mp q'.2)
        (let ⟨⟨c, hc⟩, mul_eq⟩ := Localization.r_iff_exists.mp h
        (mul_eq_mul_right_iff.mp mul_eq).resolve_right (mem_non_zero_divisors_iff_ne_zero.mp hc))

theorem lift_on_mk {P : Sort v} (p q : Polynomial K) (f : ∀ p q : Polynomial K, P) (f0 : ∀ p, f p 0 = f 0 1)
  (H : ∀ {p q p' q'} hq : q ≠ 0 hq' : q' ≠ 0, ((p*q') = p'*q) → f p q = f p' q') :
  (Ratfunc.mk p q).liftOn f @H = f p q :=
  by 
    unfold Ratfunc.liftOn 
    byCases' hq : q = 0
    ·
      subst hq 
      simp only [mk_zero, f0, ←Localization.mk_zero 1, Localization.lift_on_mk, Submonoid.coe_one]
    ·
      simp only [mk_eq_localization_mk _ hq, Localization.lift_on_mk, SetLike.coe_mk]

-- error in FieldTheory.Ratfunc: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Non-dependent recursion principle for `ratfunc K`: if `f p q : P` for all `p q`,
such that `f (a * p) (a * q) = f p q`, then we can find a value of `P`
for all elements of `ratfunc K` by setting `lift_on' (p / q) f _ = f p q`.

The value of `f p 0` for any `p` is never used and in principle this may be anything,
although many usages of `lift_on'` assume `f p 0 = f 0 1`.
-/
@[irreducible]
protected
def lift_on'
{P : Sort v}
(x : ratfunc K)
(f : ∀ p q : polynomial K, P)
(H : ∀
 {p q a}
 (hq : «expr ≠ »(q, 0))
 (ha : «expr ≠ »(a, 0)), «expr = »(f «expr * »(a, p) «expr * »(a, q), f p q)) : P :=
x.lift_on f (λ p q p' q' hq hq' h, begin
   have [ident H0] [":", expr «expr = »(f 0 q, f 0 q')] [],
   { calc
       «expr = »(f 0 q, f «expr * »(q', 0) «expr * »(q', q)) : (H hq hq').symm
       «expr = »(..., f «expr * »(q, 0) «expr * »(q, q')) : by rw ["[", expr mul_zero, ",", expr mul_zero, ",", expr mul_comm, "]"] []
       «expr = »(..., f 0 q') : H hq' hq },
   by_cases [expr hp, ":", expr «expr = »(p, 0)],
   { simp [] [] [] ["[", expr hp, ",", expr hq, "]"] [] ["at", "⊢", ident h],
     rw ["[", expr h, ",", expr H0, "]"] [] },
   by_cases [expr hp', ":", expr «expr = »(p', 0)],
   { simp [] [] [] ["[", expr hp', ",", expr hq', "]"] [] ["at", "⊢", ident h],
     rw ["[", expr h, ",", expr H0, "]"] [] },
   calc
     «expr = »(f p q, f «expr * »(p', p) «expr * »(p', q)) : (H hq hp').symm
     «expr = »(..., f «expr * »(p, p') «expr * »(p, q')) : by rw ["[", expr mul_comm p p', ",", expr h, "]"] []
     «expr = »(..., f p' q') : H hq' hp
 end)

theorem lift_on'_mk {P : Sort v} (p q : Polynomial K) (f : ∀ p q : Polynomial K, P) (f0 : ∀ p, f p 0 = f 0 1)
  (H : ∀ {p q a} hq : q ≠ 0 ha : a ≠ 0, f (a*p) (a*q) = f p q) : (Ratfunc.mk p q).liftOn' f @H = f p q :=
  by 
    rw [Ratfunc.liftOn', Ratfunc.lift_on_mk _ _ _ f0]

-- error in FieldTheory.Ratfunc: ././Mathport/Syntax/Translate/Basic.lean:927:38: unsupported irreducible non-definition
/-- Induction principle for `ratfunc K`: if `f p q : P (ratfunc.mk p q)` for all `p q`,
then `P` holds on all elements of `ratfunc K`.

See also `induction_on`, which is a recursion principle defined in terms of `algebra_map`.
-/
@[irreducible]
protected
theorem induction_on'
{P : ratfunc K → exprProp()} : ∀
(x : ratfunc K)
(f : ∀ (p q : polynomial K) (hq : «expr ≠ »(q, 0)), P (ratfunc.mk p q)), P x
| ⟨x⟩, f := localization.induction_on x (λ
 ⟨p, q⟩, by simpa [] [] ["only"] ["[", expr mk_coe_def, ",", expr localization.mk_eq_mk', "]"] [] ["using", expr f p q (mem_non_zero_divisors_iff_ne_zero.mp q.2)])

end Rec

section Field

/-! ### Defining the field structure -/


/-- The zero rational function. -/
protected irreducible_def zero : Ratfunc K :=
  ⟨0⟩

instance : HasZero (Ratfunc K) :=
  ⟨Ratfunc.zero⟩

theorem of_fraction_ring_zero : (of_fraction_ring 0 : Ratfunc K) = 0 :=
  by 
    unfold HasZero.zero Ratfunc.zero

/-- Addition of rational functions. -/
protected irreducible_def add : Ratfunc K → Ratfunc K → Ratfunc K
| ⟨p⟩, ⟨q⟩ => ⟨p+q⟩

instance : Add (Ratfunc K) :=
  ⟨Ratfunc.add⟩

theorem of_fraction_ring_add (p q : FractionRing (Polynomial K)) :
  of_fraction_ring (p+q) = of_fraction_ring p+of_fraction_ring q :=
  by 
    unfold Add.add Ratfunc.add

/-- Subtraction of rational functions. -/
protected irreducible_def sub : Ratfunc K → Ratfunc K → Ratfunc K
| ⟨p⟩, ⟨q⟩ => ⟨p - q⟩

instance : Sub (Ratfunc K) :=
  ⟨Ratfunc.sub⟩

theorem of_fraction_ring_sub (p q : FractionRing (Polynomial K)) :
  of_fraction_ring (p - q) = of_fraction_ring p - of_fraction_ring q :=
  by 
    unfold Sub.sub Ratfunc.sub

/-- Additive inverse of a rational function. -/
protected irreducible_def neg : Ratfunc K → Ratfunc K
| ⟨p⟩ => ⟨-p⟩

instance : Neg (Ratfunc K) :=
  ⟨Ratfunc.neg⟩

theorem of_fraction_ring_neg (p : FractionRing (Polynomial K)) : of_fraction_ring (-p) = -of_fraction_ring p :=
  by 
    unfold Neg.neg Ratfunc.neg

/-- The multiplicative unit of rational functions. -/
protected irreducible_def one : Ratfunc K :=
  ⟨1⟩

instance : HasOne (Ratfunc K) :=
  ⟨Ratfunc.one⟩

theorem of_fraction_ring_one : (of_fraction_ring 1 : Ratfunc K) = 1 :=
  by 
    unfold HasOne.one Ratfunc.one

/-- Multiplication of rational functions. -/
protected irreducible_def mul : Ratfunc K → Ratfunc K → Ratfunc K
| ⟨p⟩, ⟨q⟩ => ⟨p*q⟩

instance : Mul (Ratfunc K) :=
  ⟨Ratfunc.mul⟩

theorem of_fraction_ring_mul (p q : FractionRing (Polynomial K)) :
  of_fraction_ring (p*q) = of_fraction_ring p*of_fraction_ring q :=
  by 
    unfold Mul.mul Ratfunc.mul

include hdomain

/-- Division of rational functions. -/
protected irreducible_def div : Ratfunc K → Ratfunc K → Ratfunc K
| ⟨p⟩, ⟨q⟩ => ⟨p / q⟩

instance : Div (Ratfunc K) :=
  ⟨Ratfunc.div⟩

theorem of_fraction_ring_div (p q : FractionRing (Polynomial K)) :
  of_fraction_ring (p / q) = of_fraction_ring p / of_fraction_ring q :=
  by 
    unfold Div.div Ratfunc.div

/-- Multiplicative inverse of a rational function. -/
protected irreducible_def inv : Ratfunc K → Ratfunc K
| ⟨p⟩ => ⟨p⁻¹⟩

instance : HasInv (Ratfunc K) :=
  ⟨Ratfunc.inv⟩

theorem of_fraction_ring_inv (p : FractionRing (Polynomial K)) : of_fraction_ring (p⁻¹) = of_fraction_ring p⁻¹ :=
  by 
    unfold HasInv.inv Ratfunc.inv

theorem mul_inv_cancel : ∀ {p : Ratfunc K} hp : p ≠ 0, (p*p⁻¹) = 1
| ⟨p⟩, h =>
  have  : p ≠ 0 :=
    fun hp =>
      h$
        by 
          rw [hp, of_fraction_ring_zero]
  by 
    simpa only [←of_fraction_ring_inv, ←of_fraction_ring_mul, ←of_fraction_ring_one] using _root_.mul_inv_cancel this

section HasScalar

variable {R : Type _} [Monoidₓ R] [DistribMulAction R (Polynomial K)]

variable [htower : IsScalarTower R (Polynomial K) (Polynomial K)]

include htower

instance : HasScalar R (Ratfunc K) :=
  ⟨fun c p =>
      p.lift_on (fun p q => Ratfunc.mk (c • p) q)
        fun p q p' q' hq hq' h =>
          (mk_eq_mk hq hq').mpr$
            by 
              rw [smul_mul_assoc, h, smul_mul_assoc]⟩

theorem mk_smul (c : R) (p q : Polynomial K) : Ratfunc.mk (c • p) q = c • Ratfunc.mk p q :=
  show Ratfunc.mk (c • p) q = (Ratfunc.mk p q).liftOn _ _ from
    symm$
      lift_on_mk p q _
        (fun p =>
          show Ratfunc.mk (c • p) 0 = Ratfunc.mk (c • 0) 1by 
            rw [mk_zero, smul_zero, mk_eq_localization_mk (0 : Polynomial K) one_ne_zero, Localization.mk_zero])
        _

instance : IsScalarTower R (Polynomial K) (Ratfunc K) :=
  ⟨fun c p q =>
      q.induction_on'
        fun q r _ =>
          by 
            rw [←mk_smul, smul_assoc, mk_smul, mk_smul]⟩

end HasScalar

variable (K)

omit hdomain

instance : Inhabited (Ratfunc K) :=
  ⟨0⟩

instance [IsDomain K] : Nontrivial (Ratfunc K) :=
  ⟨⟨0, 1,
      mt (congr_argₓ to_fraction_ring)$
        by 
          simpa only [←of_fraction_ring_zero, ←of_fraction_ring_one] using zero_ne_one⟩⟩

omit hring

/-- Solve equations for `ratfunc K` by working in `fraction_ring (polynomial K)`. -/
unsafe def frac_tac : tactic Unit :=
  sorry

/-- Solve equations for `ratfunc K` by applying `ratfunc.induction_on`. -/
unsafe def smul_tac : tactic Unit :=
  sorry

include hring hdomain

instance : Field (Ratfunc K) :=
  { Ratfunc.nontrivial K with add := ·+·,
    add_assoc :=
      by 
        runTac 
          frac_tac,
    add_comm :=
      by 
        runTac 
          frac_tac,
    zero := 0,
    zero_add :=
      by 
        runTac 
          frac_tac,
    add_zero :=
      by 
        runTac 
          frac_tac,
    neg := Neg.neg,
    add_left_neg :=
      by 
        runTac 
          frac_tac,
    sub := Sub.sub,
    sub_eq_add_neg :=
      by 
        runTac 
          frac_tac,
    mul := ·*·,
    mul_assoc :=
      by 
        runTac 
          frac_tac,
    mul_comm :=
      by 
        runTac 
          frac_tac,
    left_distrib :=
      by 
        runTac 
          frac_tac,
    right_distrib :=
      by 
        runTac 
          frac_tac,
    one := 1,
    one_mul :=
      by 
        runTac 
          frac_tac,
    mul_one :=
      by 
        runTac 
          frac_tac,
    inv := HasInv.inv,
    inv_zero :=
      by 
        runTac 
          frac_tac,
    div := · / ·,
    div_eq_mul_inv :=
      by 
        runTac 
          frac_tac,
    mul_inv_cancel := fun _ => mul_inv_cancel, nsmul := · • ·,
    nsmul_zero' :=
      by 
        runTac 
          smul_tac,
    nsmul_succ' :=
      by 
        runTac 
          smul_tac,
    zsmul := · • ·,
    zsmul_zero' :=
      by 
        runTac 
          smul_tac,
    zsmul_succ' :=
      by 
        runTac 
          smul_tac,
    zsmul_neg' :=
      by 
        runTac 
          smul_tac,
    npow := npowRec, zpow := zpowRec }

end Field

section IsFractionRing

/-! ### `ratfunc` as field of fractions of `polynomial` -/


include hdomain

instance (R : Type _) [CommSemiringₓ R] [Algebra R (Polynomial K)] : Algebra R (Ratfunc K) :=
  { toFun := fun x => Ratfunc.mk (algebraMap _ _ x) 1,
    map_add' :=
      fun x y =>
        by 
          simp only [mk_one', RingHom.map_add, of_fraction_ring_add],
    map_mul' :=
      fun x y =>
        by 
          simp only [mk_one', RingHom.map_mul, of_fraction_ring_mul],
    map_one' :=
      by 
        simp only [mk_one', RingHom.map_one, of_fraction_ring_one],
    map_zero' :=
      by 
        simp only [mk_one', RingHom.map_zero, of_fraction_ring_zero],
    smul := · • ·,
    smul_def' :=
      fun c x =>
        x.induction_on'$
          fun p q hq =>
            by 
              simpRw [mk_one', ←mk_smul, mk_def_of_ne (c • p) hq, mk_def_of_ne p hq, ←of_fraction_ring_mul,
                IsLocalization.mul_mk'_eq_mk'_of_mul, Algebra.smul_def],
    commutes' := fun c x => mul_commₓ _ _ }

variable {K}

theorem mk_one (x : Polynomial K) : Ratfunc.mk x 1 = algebraMap _ _ x :=
  rfl

theorem of_fraction_ring_algebra_map (x : Polynomial K) :
  of_fraction_ring (algebraMap _ (FractionRing (Polynomial K)) x) = algebraMap _ _ x :=
  by 
    rw [←mk_one, mk_one']

@[simp]
theorem mk_eq_div (p q : Polynomial K) : Ratfunc.mk p q = algebraMap _ _ p / algebraMap _ _ q :=
  by 
    simp only [mk_eq_div', of_fraction_ring_div, of_fraction_ring_algebra_map]

variable (K)

theorem of_fraction_ring_comp_algebra_map :
  of_fraction_ring ∘ algebraMap (Polynomial K) (FractionRing (Polynomial K)) = algebraMap _ _ :=
  funext of_fraction_ring_algebra_map

theorem algebra_map_injective : Function.Injective (algebraMap (Polynomial K) (Ratfunc K)) :=
  by 
    rw [←of_fraction_ring_comp_algebra_map]
    exact of_fraction_ring_injective.comp (IsFractionRing.injective _ _)

@[simp]
theorem algebra_map_eq_zero_iff {x : Polynomial K} : algebraMap (Polynomial K) (Ratfunc K) x = 0 ↔ x = 0 :=
  ⟨(RingHom.injective_iff _).mp (algebra_map_injective K) _,
    fun hx =>
      by 
        rw [hx, RingHom.map_zero]⟩

variable {K}

theorem algebra_map_ne_zero {x : Polynomial K} (hx : x ≠ 0) : algebraMap (Polynomial K) (Ratfunc K) x ≠ 0 :=
  mt (algebra_map_eq_zero_iff K).mp hx

variable (K)

omit hdomain

/-- `ratfunc K` is isomorphic to the field of fractions of `polynomial K`, as rings.

This is an auxiliary definition; `simp`-normal form is `is_localization.alg_equiv`.
-/
def aux_equiv : FractionRing (Polynomial K) ≃+* Ratfunc K :=
  { toFun := of_fraction_ring, invFun := to_fraction_ring, left_inv := fun x => rfl, right_inv := fun ⟨x⟩ => rfl,
    map_add' := of_fraction_ring_add, map_mul' := of_fraction_ring_mul }

include hdomain

/-- `ratfunc K` is the field of fractions of the polynomials over `K`. -/
instance : IsFractionRing (Polynomial K) (Ratfunc K) :=
  { map_units :=
      fun y =>
        by 
          rw [←of_fraction_ring_algebra_map] <;>
            exact (aux_equiv K).toRingHom.is_unit_map (IsLocalization.map_units _ y),
    eq_iff_exists :=
      fun x y =>
        by 
          rw [←of_fraction_ring_algebra_map, ←of_fraction_ring_algebra_map] <;>
            exact (aux_equiv K).Injective.eq_iff.trans (IsLocalization.eq_iff_exists _ _),
    surj :=
      by 
        rintro ⟨z⟩
        convert IsLocalization.surj (Polynomial K)⁰ z 
        ext ⟨x, y⟩
        simp only [←of_fraction_ring_algebra_map, Function.comp_app, ←of_fraction_ring_mul] }

variable {K}

@[simp]
theorem lift_on_div {P : Sort v} (p q : Polynomial K) (f : ∀ p q : Polynomial K, P) (f0 : ∀ p, f p 0 = f 0 1)
  (H : ∀ {p q p' q'} hq : q ≠ 0 hq' : q' ≠ 0, ((p*q') = p'*q) → f p q = f p' q') :
  (algebraMap _ (Ratfunc K) p / algebraMap _ _ q).liftOn f @H = f p q :=
  by 
    rw [←mk_eq_div, lift_on_mk _ _ f f0 @H]

@[simp]
theorem lift_on'_div {P : Sort v} (p q : Polynomial K) (f : ∀ p q : Polynomial K, P) (f0 : ∀ p, f p 0 = f 0 1) H :
  (algebraMap _ (Ratfunc K) p / algebraMap _ _ q).liftOn' f @H = f p q :=
  by 
    rw [Ratfunc.liftOn', lift_on_div]
    assumption

/-- Induction principle for `ratfunc K`: if `f p q : P (p / q)` for all `p q : polynomial K`,
then `P` holds on all elements of `ratfunc K`.

See also `induction_on'`, which is a recursion principle defined in terms of `ratfunc.mk`.
-/
protected theorem induction_on {P : Ratfunc K → Prop} (x : Ratfunc K)
  (f : ∀ p q : Polynomial K hq : q ≠ 0, P (algebraMap _ (Ratfunc K) p / algebraMap _ _ q)) : P x :=
  x.induction_on'
    fun p q hq =>
      by 
        simpa using f p q hq

theorem of_fraction_ring_mk' (x : Polynomial K) (y : (Polynomial K)⁰) :
  of_fraction_ring (IsLocalization.mk' _ x y) = IsLocalization.mk' (Ratfunc K) x y :=
  by 
    rw [IsFractionRing.mk'_eq_div, IsFractionRing.mk'_eq_div, ←mk_eq_div', ←mk_eq_div]

@[simp]
theorem of_fraction_ring_eq :
  (of_fraction_ring : FractionRing (Polynomial K) → Ratfunc K) = IsLocalization.algEquiv (Polynomial K)⁰ _ _ :=
  funext$
    fun x =>
      Localization.induction_on x$
        fun x =>
          by 
            simp only [IsLocalization.alg_equiv_apply, IsLocalization.ring_equiv_of_ring_equiv_apply,
              RingEquiv.to_fun_eq_coe, Localization.mk_eq_mk'_apply, IsLocalization.map_mk', of_fraction_ring_mk',
              RingEquiv.coe_to_ring_hom, RingEquiv.refl_apply, SetLike.eta]

@[simp]
theorem to_fraction_ring_eq :
  (to_fraction_ring : Ratfunc K → FractionRing (Polynomial K)) = IsLocalization.algEquiv (Polynomial K)⁰ _ _ :=
  funext$
    fun ⟨x⟩ =>
      Localization.induction_on x$
        fun x =>
          by 
            simp only [Localization.mk_eq_mk'_apply, of_fraction_ring_mk', IsLocalization.alg_equiv_apply,
              RingEquiv.to_fun_eq_coe, IsLocalization.ring_equiv_of_ring_equiv_apply, IsLocalization.map_mk',
              RingEquiv.coe_to_ring_hom, RingEquiv.refl_apply, SetLike.eta]

@[simp]
theorem aux_equiv_eq : aux_equiv K = (IsLocalization.algEquiv (Polynomial K)⁰ _ _).toRingEquiv :=
  by 
    ext x 
    simp only [aux_equiv, RingEquiv.coe_mk, of_fraction_ring_eq, AlgEquiv.coe_ring_equiv']

end IsFractionRing

section NumDenom

/-! ### Numerator and denominator -/


open GcdMonoid Polynomial

omit hring

variable [hfield : Field K]

include hfield

-- error in FieldTheory.Ratfunc: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- `ratfunc.num_denom` are numerator and denominator of a rational function over a field,
normalized such that the denominator is monic. -/
def num_denom (x : ratfunc K) : «expr × »(polynomial K, polynomial K) :=
x.lift_on' (λ p q, if «expr = »(q, 0) then ⟨0, 1⟩ else let r := gcd p q in
 ⟨«expr * »(polynomial.C «expr ⁻¹»(«expr / »(q, r).leading_coeff), «expr / »(p, r)), «expr * »(polynomial.C «expr ⁻¹»(«expr / »(q, r).leading_coeff), «expr / »(q, r))⟩) (begin
   intros [ident p, ident q, ident a, ident hq, ident ha],
   rw ["[", expr if_neg hq, ",", expr if_neg (mul_ne_zero ha hq), "]"] [],
   have [ident hpq] [":", expr «expr ≠ »(gcd p q, 0)] [":=", expr mt «expr ∘ »(and.right, (gcd_eq_zero_iff _ _).mp) hq],
   have [ident ha'] [":", expr «expr ≠ »(a.leading_coeff, 0)] [":=", expr polynomial.leading_coeff_ne_zero.mpr ha],
   have [ident hainv] [":", expr «expr ≠ »(«expr ⁻¹»(a.leading_coeff), 0)] [":=", expr inv_ne_zero ha'],
   simp [] [] ["only"] ["[", expr prod.ext_iff, ",", expr gcd_mul_left, ",", expr normalize_apply, ",", expr polynomial.coe_norm_unit, ",", expr mul_assoc, ",", expr comm_group_with_zero.coe_norm_unit _ ha', "]"] [] [],
   have [ident hdeg] [":", expr «expr ≤ »((gcd p q).degree, q.degree)] [":=", expr degree_gcd_le_right _ hq],
   have [ident hdeg'] [":", expr «expr ≤ »(«expr * »(polynomial.C «expr ⁻¹»(a.leading_coeff), gcd p q).degree, q.degree)] [],
   { rw ["[", expr polynomial.degree_mul, ",", expr polynomial.degree_C hainv, ",", expr zero_add, "]"] [],
     exact [expr hdeg] },
   have [ident hdivp] [":", expr «expr ∣ »(«expr * »(polynomial.C «expr ⁻¹»(a.leading_coeff), gcd p q), p)] [":=", expr (C_mul_dvd hainv).mpr (gcd_dvd_left p q)],
   have [ident hdivq] [":", expr «expr ∣ »(«expr * »(polynomial.C «expr ⁻¹»(a.leading_coeff), gcd p q), q)] [":=", expr (C_mul_dvd hainv).mpr (gcd_dvd_right p q)],
   rw ["[", expr euclidean_domain.mul_div_mul_cancel ha hdivp, ",", expr euclidean_domain.mul_div_mul_cancel ha hdivq, ",", expr leading_coeff_div hdeg, ",", expr leading_coeff_div hdeg', ",", expr polynomial.leading_coeff_mul, ",", expr polynomial.leading_coeff_C, ",", expr div_C_mul, ",", expr div_C_mul, ",", "<-", expr mul_assoc, ",", "<-", expr polynomial.C_mul, ",", "<-", expr mul_assoc, ",", "<-", expr polynomial.C_mul, "]"] [],
   split; congr; rw ["[", expr inv_div, ",", expr mul_comm, ",", expr mul_div_assoc, ",", "<-", expr mul_assoc, ",", expr inv_inv₀, ",", expr _root_.mul_inv_cancel ha', ",", expr one_mul, ",", expr inv_div, "]"] []
 end)

@[simp]
theorem num_denom_div (p : Polynomial K) {q : Polynomial K} (hq : q ≠ 0) :
  num_denom (algebraMap _ _ p / algebraMap _ _ q) =
    (Polynomial.c ((q / gcd p q).leadingCoeff⁻¹)*p / gcd p q,
    Polynomial.c ((q / gcd p q).leadingCoeff⁻¹)*q / gcd p q) :=
  by 
    rw [num_denom, lift_on'_div, if_neg hq]
    intro p 
    rw [if_pos rfl, if_neg (@one_ne_zero (Polynomial K) _ _)]
    simp 

/-- `ratfunc.num` is the numerator of a rational function,
normalized such that the denominator is monic. -/
def Num (x : Ratfunc K) : Polynomial K :=
  x.num_denom.1

@[simp]
theorem num_div (p : Polynomial K) {q : Polynomial K} (hq : q ≠ 0) :
  Num (algebraMap _ _ p / algebraMap _ _ q) = Polynomial.c ((q / gcd p q).leadingCoeff⁻¹)*p / gcd p q :=
  by 
    rw [Num, num_denom_div _ hq]

@[simp]
theorem num_zero : Num (0 : Ratfunc K) = 0 :=
  by 
    convert num_div (0 : Polynomial K) one_ne_zero <;> simp 

@[simp]
theorem num_one : Num (1 : Ratfunc K) = 1 :=
  by 
    convert num_div (1 : Polynomial K) one_ne_zero <;> simp 

@[simp]
theorem num_algebra_map (p : Polynomial K) : Num (algebraMap _ _ p) = p :=
  by 
    convert num_div p one_ne_zero <;> simp 

@[simp]
theorem num_div_dvd (p : Polynomial K) {q : Polynomial K} (hq : q ≠ 0) :
  Num (algebraMap _ _ p / algebraMap _ _ q) ∣ p :=
  by 
    rw [num_div _ hq, C_mul_dvd]
    ·
      exact EuclideanDomain.div_dvd_of_dvd (gcd_dvd_left p q)
    ·
      simpa only [Ne.def, inv_eq_zero, Polynomial.leading_coeff_eq_zero] using right_div_gcd_ne_zero hq

/-- `ratfunc.denom` is the denominator of a rational function,
normalized such that it is monic. -/
def denom (x : Ratfunc K) : Polynomial K :=
  x.num_denom.2

@[simp]
theorem denom_div (p : Polynomial K) {q : Polynomial K} (hq : q ≠ 0) :
  denom (algebraMap _ _ p / algebraMap _ _ q) = Polynomial.c ((q / gcd p q).leadingCoeff⁻¹)*q / gcd p q :=
  by 
    rw [denom, num_denom_div _ hq]

theorem monic_denom (x : Ratfunc K) : (denom x).Monic :=
  x.induction_on
    fun p q hq =>
      by 
        rw [denom_div p hq, mul_commₓ]
        exact Polynomial.monic_mul_leading_coeff_inv (right_div_gcd_ne_zero hq)

theorem denom_ne_zero (x : Ratfunc K) : denom x ≠ 0 :=
  (monic_denom x).ne_zero

@[simp]
theorem denom_zero : denom (0 : Ratfunc K) = 1 :=
  by 
    convert denom_div (0 : Polynomial K) one_ne_zero <;> simp 

@[simp]
theorem denom_one : denom (1 : Ratfunc K) = 1 :=
  by 
    convert denom_div (1 : Polynomial K) one_ne_zero <;> simp 

@[simp]
theorem denom_algebra_map (p : Polynomial K) : denom (algebraMap _ (Ratfunc K) p) = 1 :=
  by 
    convert denom_div p one_ne_zero <;> simp 

@[simp]
theorem denom_div_dvd (p : Polynomial K) {q : Polynomial K} (hq : q ≠ 0) :
  denom (algebraMap _ _ p / algebraMap _ _ q) ∣ q :=
  by 
    rw [denom_div _ hq, C_mul_dvd]
    ·
      exact EuclideanDomain.div_dvd_of_dvd (gcd_dvd_right p q)
    ·
      simpa only [Ne.def, inv_eq_zero, Polynomial.leading_coeff_eq_zero] using right_div_gcd_ne_zero hq

-- error in FieldTheory.Ratfunc: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem num_div_denom (x : ratfunc K) : «expr = »(«expr / »(algebra_map _ _ (num x), algebra_map _ _ (denom x)), x) :=
x.induction_on (λ p q hq, begin
   by_cases [expr hp, ":", expr «expr = »(p, 0)],
   { simp [] [] [] ["[", expr hp, "]"] [] [] },
   have [ident q_div_ne_zero] [] [":=", expr right_div_gcd_ne_zero hq],
   rw ["[", expr num_div p hq, ",", expr denom_div p hq, ",", expr ring_hom.map_mul, ",", expr ring_hom.map_mul, ",", expr mul_div_mul_left, ",", expr div_eq_div_iff, ",", "<-", expr ring_hom.map_mul, ",", "<-", expr ring_hom.map_mul, ",", expr mul_comm _ q, ",", "<-", expr euclidean_domain.mul_div_assoc, ",", "<-", expr euclidean_domain.mul_div_assoc, ",", expr mul_comm, "]"] [],
   { apply [expr gcd_dvd_right] },
   { apply [expr gcd_dvd_left] },
   { exact [expr algebra_map_ne_zero q_div_ne_zero] },
   { exact [expr algebra_map_ne_zero hq] },
   { refine [expr algebra_map_ne_zero (mt polynomial.C_eq_zero.mp _)],
     exact [expr inv_ne_zero (polynomial.leading_coeff_ne_zero.mpr q_div_ne_zero)] }
 end)

@[simp]
theorem num_eq_zero_iff {x : Ratfunc K} : Num x = 0 ↔ x = 0 :=
  ⟨fun h =>
      by 
        rw [←num_div_denom x, h, RingHom.map_zero, zero_div],
    fun h => h.symm ▸ num_zero⟩

theorem num_ne_zero {x : Ratfunc K} (hx : x ≠ 0) : Num x ≠ 0 :=
  mt num_eq_zero_iff.mp hx

theorem num_mul_eq_mul_denom_iff {x : Ratfunc K} {p q : Polynomial K} (hq : q ≠ 0) :
  ((x.num*q) = p*x.denom) ↔ x = algebraMap _ _ p / algebraMap _ _ q :=
  by 
    rw [←(algebra_map_injective K).eq_iff, eq_div_iff (algebra_map_ne_zero hq)]
    convRHS => rw [←num_div_denom x]
    rw [RingHom.map_mul, RingHom.map_mul, div_eq_mul_inv, mul_assocₓ, mul_commₓ (HasInv.inv _), ←mul_assocₓ,
      ←div_eq_mul_inv, div_eq_iff]
    exact algebra_map_ne_zero (denom_ne_zero x)

theorem num_denom_add (x y : Ratfunc K) : ((x+y).num*x.denom*y.denom) = ((x.num*y.denom)+x.denom*y.num)*(x+y).denom :=
  (num_mul_eq_mul_denom_iff (mul_ne_zero (denom_ne_zero x) (denom_ne_zero y))).mpr$
    by 
      convLHS => rw [←num_div_denom x, ←num_div_denom y]
      rw [div_add_div, RingHom.map_mul, RingHom.map_add, RingHom.map_mul, RingHom.map_mul]
      ·
        exact algebra_map_ne_zero (denom_ne_zero x)
      ·
        exact algebra_map_ne_zero (denom_ne_zero y)

theorem num_denom_mul (x y : Ratfunc K) : ((x*y).num*x.denom*y.denom) = (x.num*y.num)*(x*y).denom :=
  (num_mul_eq_mul_denom_iff (mul_ne_zero (denom_ne_zero x) (denom_ne_zero y))).mpr$
    by 
      convLHS => rw [←num_div_denom x, ←num_div_denom y, div_mul_div, ←RingHom.map_mul, ←RingHom.map_mul]

theorem num_dvd {x : Ratfunc K} {p : Polynomial K} (hp : p ≠ 0) :
  Num x ∣ p ↔ ∃ (q : Polynomial K)(hq : q ≠ 0), x = algebraMap _ _ p / algebraMap _ _ q :=
  by 
    split 
    ·
      rintro ⟨q, rfl⟩
      obtain ⟨hx, hq⟩ := mul_ne_zero_iff.mp hp 
      use denom x*q 
      rw [RingHom.map_mul, RingHom.map_mul, ←div_mul_div, div_self, mul_oneₓ, num_div_denom]
      ·
        exact ⟨mul_ne_zero (denom_ne_zero x) hq, rfl⟩
      ·
        exact algebra_map_ne_zero hq
    ·
      rintro ⟨q, hq, rfl⟩
      exact num_div_dvd p hq

theorem denom_dvd {x : Ratfunc K} {q : Polynomial K} (hq : q ≠ 0) :
  denom x ∣ q ↔ ∃ p : Polynomial K, x = algebraMap _ _ p / algebraMap _ _ q :=
  by 
    split 
    ·
      rintro ⟨p, rfl⟩
      obtain ⟨hx, hp⟩ := mul_ne_zero_iff.mp hq 
      use Num x*p 
      rw [RingHom.map_mul, RingHom.map_mul, ←div_mul_div, div_self, mul_oneₓ, num_div_denom]
      ·
        exact algebra_map_ne_zero hp
    ·
      rintro ⟨p, rfl⟩
      exact denom_div_dvd p hq

theorem num_mul_dvd (x y : Ratfunc K) : Num (x*y) ∣ Num x*Num y :=
  by 
    byCases' hx : x = 0
    ·
      simp [hx]
    byCases' hy : y = 0
    ·
      simp [hy]
    rw [num_dvd (mul_ne_zero (num_ne_zero hx) (num_ne_zero hy))]
    refine' ⟨x.denom*y.denom, mul_ne_zero (denom_ne_zero x) (denom_ne_zero y), _⟩
    rw [RingHom.map_mul, RingHom.map_mul, ←div_mul_div, num_div_denom, num_div_denom]

theorem denom_mul_dvd (x y : Ratfunc K) : denom (x*y) ∣ denom x*denom y :=
  by 
    rw [denom_dvd (mul_ne_zero (denom_ne_zero x) (denom_ne_zero y))]
    refine' ⟨x.num*y.num, _⟩
    rw [RingHom.map_mul, RingHom.map_mul, ←div_mul_div, num_div_denom, num_div_denom]

theorem denom_add_dvd (x y : Ratfunc K) : denom (x+y) ∣ denom x*denom y :=
  by 
    rw [denom_dvd (mul_ne_zero (denom_ne_zero x) (denom_ne_zero y))]
    refine' ⟨(x.num*y.denom)+x.denom*y.num, _⟩
    rw [RingHom.map_mul, RingHom.map_add, RingHom.map_mul, RingHom.map_mul, ←div_add_div, num_div_denom, num_div_denom]
    ·
      exact algebra_map_ne_zero (denom_ne_zero x)
    ·
      exact algebra_map_ne_zero (denom_ne_zero y)

end NumDenom

section Eval

/-! ### Polynomial structure: `C`, `X`, `eval` -/


include hdomain

/-- `ratfunc.C a` is the constant rational function `a`. -/
def C : K →+* Ratfunc K :=
  algebraMap _ _

@[simp]
theorem algebra_map_eq_C : algebraMap K (Ratfunc K) = C :=
  rfl

@[simp]
theorem algebra_map_C (a : K) : algebraMap (Polynomial K) (Ratfunc K) (Polynomial.c a) = C a :=
  rfl

@[simp]
theorem algebra_map_comp_C : (algebraMap (Polynomial K) (Ratfunc K)).comp Polynomial.c = C :=
  rfl

/-- `ratfunc.X` is the polynomial variable (aka indeterminate). -/
def X : Ratfunc K :=
  algebraMap (Polynomial K) (Ratfunc K) Polynomial.x

@[simp]
theorem algebra_map_X : algebraMap (Polynomial K) (Ratfunc K) Polynomial.x = X :=
  rfl

omit hring hdomain

variable [hfield : Field K]

include hfield

@[simp]
theorem num_C (c : K) : Num (C c) = Polynomial.c c :=
  num_algebra_map _

@[simp]
theorem denom_C (c : K) : denom (C c) = 1 :=
  denom_algebra_map _

@[simp]
theorem num_X : Num (X : Ratfunc K) = Polynomial.x :=
  num_algebra_map _

@[simp]
theorem denom_X : denom (X : Ratfunc K) = 1 :=
  denom_algebra_map _

variable {L : Type _} [Field L]

/-- Evaluate a rational function `p` given a ring hom `f` from the scalar field
to the target and a value `x` for the variable in the target.

Fractions are reduced by clearing common denominators before evaluating:
`eval id 1 ((X^2 - 1) / (X - 1)) = eval id 1 (X + 1) = 2`, not `0 / 0 = 0`.
-/
def eval (f : K →+* L) (a : L) (p : Ratfunc K) : L :=
  (Num p).eval₂ f a / (denom p).eval₂ f a

variable {f : K →+* L} {a : L}

theorem eval_eq_zero_of_eval₂_denom_eq_zero {x : Ratfunc K} (h : Polynomial.eval₂ f a (denom x) = 0) : eval f a x = 0 :=
  by 
    rw [eval, h, div_zero]

theorem eval₂_denom_ne_zero {x : Ratfunc K} (h : eval f a x ≠ 0) : Polynomial.eval₂ f a (denom x) ≠ 0 :=
  mt eval_eq_zero_of_eval₂_denom_eq_zero h

variable (f a)

@[simp]
theorem eval_C {c : K} : eval f a (C c) = f c :=
  by 
    simp [eval]

@[simp]
theorem eval_X : eval f a X = a :=
  by 
    simp [eval]

@[simp]
theorem eval_zero : eval f a 0 = 0 :=
  by 
    simp [eval]

@[simp]
theorem eval_one : eval f a 1 = 1 :=
  by 
    simp [eval]

@[simp]
theorem eval_algebra_map {S : Type _} [CommSemiringₓ S] [Algebra S (Polynomial K)] (p : S) :
  eval f a (algebraMap _ _ p) = (algebraMap _ (Polynomial K) p).eval₂ f a :=
  by 
    simp [eval, IsScalarTower.algebra_map_apply S (Polynomial K) (Ratfunc K)]

-- error in FieldTheory.Ratfunc: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- `eval` is an additive homomorphism except when a denominator evaluates to `0`.

Counterexample: `eval _ 1 (X / (X-1)) + eval _ 1 (-1 / (X-1)) = 0`
`... ≠ 1 = eval _ 1 ((X-1) / (X-1))`.

See also `ratfunc.eval₂_denom_ne_zero` to make the hypotheses simpler but less general.
-/
theorem eval_add
{x y : ratfunc K}
(hx : «expr ≠ »(polynomial.eval₂ f a (denom x), 0))
(hy : «expr ≠ »(polynomial.eval₂ f a (denom y), 0)) : «expr = »(eval f a «expr + »(x, y), «expr + »(eval f a x, eval f a y)) :=
begin
  unfold [ident eval] [],
  by_cases [expr hxy, ":", expr «expr = »(polynomial.eval₂ f a (denom «expr + »(x, y)), 0)],
  { have [] [] [":=", expr polynomial.eval₂_eq_zero_of_dvd_of_eval₂_eq_zero f a (denom_add_dvd x y) hxy],
    rw [expr polynomial.eval₂_mul] ["at", ident this],
    cases [expr mul_eq_zero.mp this] []; contradiction },
  rw ["[", expr div_add_div _ _ hx hy, ",", expr eq_div_iff (mul_ne_zero hx hy), ",", expr div_eq_mul_inv, ",", expr mul_right_comm, ",", "<-", expr div_eq_mul_inv, ",", expr div_eq_iff hxy, "]"] [],
  simp [] [] ["only"] ["[", "<-", expr polynomial.eval₂_mul, ",", "<-", expr polynomial.eval₂_add, "]"] [] [],
  congr' [1] [],
  apply [expr num_denom_add]
end

-- error in FieldTheory.Ratfunc: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- `eval` is a multiplicative homomorphism except when a denominator evaluates to `0`.

Counterexample: `eval _ 0 X * eval _ 0 (1/X) = 0 ≠ 1 = eval _ 0 1 = eval _ 0 (X * 1/X)`.

See also `ratfunc.eval₂_denom_ne_zero` to make the hypotheses simpler but less general.
-/
theorem eval_mul
{x y : ratfunc K}
(hx : «expr ≠ »(polynomial.eval₂ f a (denom x), 0))
(hy : «expr ≠ »(polynomial.eval₂ f a (denom y), 0)) : «expr = »(eval f a «expr * »(x, y), «expr * »(eval f a x, eval f a y)) :=
begin
  unfold [ident eval] [],
  by_cases [expr hxy, ":", expr «expr = »(polynomial.eval₂ f a (denom «expr * »(x, y)), 0)],
  { have [] [] [":=", expr polynomial.eval₂_eq_zero_of_dvd_of_eval₂_eq_zero f a (denom_mul_dvd x y) hxy],
    rw [expr polynomial.eval₂_mul] ["at", ident this],
    cases [expr mul_eq_zero.mp this] []; contradiction },
  rw ["[", expr div_mul_div, ",", expr eq_div_iff (mul_ne_zero hx hy), ",", expr div_eq_mul_inv, ",", expr mul_right_comm, ",", "<-", expr div_eq_mul_inv, ",", expr div_eq_iff hxy, "]"] [],
  repeat { rw ["<-", expr polynomial.eval₂_mul] [] },
  congr' [1] [],
  apply [expr num_denom_mul]
end

end Eval

end Ratfunc

