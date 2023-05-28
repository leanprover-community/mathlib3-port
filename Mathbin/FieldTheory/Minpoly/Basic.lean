/-
Copyright (c) 2019 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Johan Commelin

! This file was ported from Lean 3 source module field_theory.minpoly.basic
! leanprover-community/mathlib commit 38df578a6450a8c5142b3727e3ae894c2300cae0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.IntegralClosure

/-!
# Minimal polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the minimal polynomial of an element `x` of an `A`-algebra `B`,
under the assumption that x is integral over `A`, and derives some basic properties
such as ireducibility under the assumption `B` is a domain.

-/


open Classical Polynomial

open Polynomial Set Function

variable {A B B' : Type _}

section MinPolyDef

variable (A) [CommRing A] [Ring B] [Algebra A B]

#print minpoly /-
/-- Suppose `x : B`, where `B` is an `A`-algebra.

The minimal polynomial `minpoly A x` of `x`
is a monic polynomial with coefficients in `A` of smallest degree that has `x` as its root,
if such exists (`is_integral A x`) or zero otherwise.

For example, if `V` is a `𝕜`-vector space for some field `𝕜` and `f : V →ₗ[𝕜] V` then
the minimal polynomial of `f` is `minpoly 𝕜 f`.
-/
noncomputable def minpoly (x : B) : A[X] :=
  if hx : IsIntegral A x then degree_lt_wf.min _ hx else 0
#align minpoly minpoly
-/

end MinPolyDef

namespace minpoly

section Ring

variable [CommRing A] [Ring B] [Ring B'] [Algebra A B] [Algebra A B']

variable {x : B}

/- warning: minpoly.monic -> minpoly.monic is a dubious translation:
lean 3 declaration is
  forall {A : Type.{u1}} {B : Type.{u2}} [_inst_1 : CommRing.{u1} A] [_inst_2 : Ring.{u2} B] [_inst_4 : Algebra.{u1, u2} A B (CommRing.toCommSemiring.{u1} A _inst_1) (Ring.toSemiring.{u2} B _inst_2)] {x : B}, (IsIntegral.{u1, u2} A B _inst_1 _inst_2 _inst_4 x) -> (Polynomial.Monic.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1)) (minpoly.{u1, u2} A B _inst_1 _inst_2 _inst_4 x))
but is expected to have type
  forall {A : Type.{u2}} {B : Type.{u1}} [_inst_1 : CommRing.{u2} A] [_inst_2 : Ring.{u1} B] [_inst_4 : Algebra.{u2, u1} A B (CommRing.toCommSemiring.{u2} A _inst_1) (Ring.toSemiring.{u1} B _inst_2)] {x : B}, (IsIntegral.{u2, u1} A B _inst_1 _inst_2 _inst_4 x) -> (Polynomial.Monic.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1)) (minpoly.{u2, u1} A B _inst_1 _inst_2 _inst_4 x))
Case conversion may be inaccurate. Consider using '#align minpoly.monic minpoly.monicₓ'. -/
/-- A minimal polynomial is monic. -/
theorem monic (hx : IsIntegral A x) : Monic (minpoly A x) := by delta minpoly; rw [dif_pos hx];
  exact (degree_lt_wf.min_mem _ hx).1
#align minpoly.monic minpoly.monic

/- warning: minpoly.ne_zero -> minpoly.ne_zero is a dubious translation:
lean 3 declaration is
  forall {A : Type.{u1}} {B : Type.{u2}} [_inst_1 : CommRing.{u1} A] [_inst_2 : Ring.{u2} B] [_inst_4 : Algebra.{u1, u2} A B (CommRing.toCommSemiring.{u1} A _inst_1) (Ring.toSemiring.{u2} B _inst_2)] {x : B} [_inst_6 : Nontrivial.{u1} A], (IsIntegral.{u1, u2} A B _inst_1 _inst_2 _inst_4 x) -> (Ne.{succ u1} (Polynomial.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))) (minpoly.{u1, u2} A B _inst_1 _inst_2 _inst_4 x) (OfNat.ofNat.{u1} (Polynomial.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))) 0 (OfNat.mk.{u1} (Polynomial.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))) 0 (Zero.zero.{u1} (Polynomial.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))) (Polynomial.zero.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1)))))))
but is expected to have type
  forall {A : Type.{u2}} {B : Type.{u1}} [_inst_1 : CommRing.{u2} A] [_inst_2 : Ring.{u1} B] [_inst_4 : Algebra.{u2, u1} A B (CommRing.toCommSemiring.{u2} A _inst_1) (Ring.toSemiring.{u1} B _inst_2)] {x : B} [_inst_6 : Nontrivial.{u2} A], (IsIntegral.{u2, u1} A B _inst_1 _inst_2 _inst_4 x) -> (Ne.{succ u2} (Polynomial.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))) (minpoly.{u2, u1} A B _inst_1 _inst_2 _inst_4 x) (OfNat.ofNat.{u2} (Polynomial.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))) 0 (Zero.toOfNat0.{u2} (Polynomial.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))) (Polynomial.zero.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))))))
Case conversion may be inaccurate. Consider using '#align minpoly.ne_zero minpoly.ne_zeroₓ'. -/
/-- A minimal polynomial is nonzero. -/
theorem ne_zero [Nontrivial A] (hx : IsIntegral A x) : minpoly A x ≠ 0 :=
  (monic hx).NeZero
#align minpoly.ne_zero minpoly.ne_zero

/- warning: minpoly.eq_zero -> minpoly.eq_zero is a dubious translation:
lean 3 declaration is
  forall {A : Type.{u1}} {B : Type.{u2}} [_inst_1 : CommRing.{u1} A] [_inst_2 : Ring.{u2} B] [_inst_4 : Algebra.{u1, u2} A B (CommRing.toCommSemiring.{u1} A _inst_1) (Ring.toSemiring.{u2} B _inst_2)] {x : B}, (Not (IsIntegral.{u1, u2} A B _inst_1 _inst_2 _inst_4 x)) -> (Eq.{succ u1} (Polynomial.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))) (minpoly.{u1, u2} A B _inst_1 _inst_2 _inst_4 x) (OfNat.ofNat.{u1} (Polynomial.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))) 0 (OfNat.mk.{u1} (Polynomial.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))) 0 (Zero.zero.{u1} (Polynomial.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))) (Polynomial.zero.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1)))))))
but is expected to have type
  forall {A : Type.{u2}} {B : Type.{u1}} [_inst_1 : CommRing.{u2} A] [_inst_2 : Ring.{u1} B] [_inst_4 : Algebra.{u2, u1} A B (CommRing.toCommSemiring.{u2} A _inst_1) (Ring.toSemiring.{u1} B _inst_2)] {x : B}, (Not (IsIntegral.{u2, u1} A B _inst_1 _inst_2 _inst_4 x)) -> (Eq.{succ u2} (Polynomial.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))) (minpoly.{u2, u1} A B _inst_1 _inst_2 _inst_4 x) (OfNat.ofNat.{u2} (Polynomial.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))) 0 (Zero.toOfNat0.{u2} (Polynomial.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))) (Polynomial.zero.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))))))
Case conversion may be inaccurate. Consider using '#align minpoly.eq_zero minpoly.eq_zeroₓ'. -/
theorem eq_zero (hx : ¬IsIntegral A x) : minpoly A x = 0 :=
  dif_neg hx
#align minpoly.eq_zero minpoly.eq_zero

/- warning: minpoly.minpoly_alg_hom -> minpoly.minpoly_algHom is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align minpoly.minpoly_alg_hom minpoly.minpoly_algHomₓ'. -/
theorem minpoly_algHom (f : B →ₐ[A] B') (hf : Function.Injective f) (x : B) :
    minpoly A (f x) = minpoly A x :=
  by
  refine' dif_ctx_congr (isIntegral_algHom_iff _ hf) (fun _ => _) fun _ => rfl
  simp_rw [← Polynomial.aeval_def, aeval_alg_hom, AlgHom.comp_apply, _root_.map_eq_zero_iff f hf]
#align minpoly.minpoly_alg_hom minpoly.minpoly_algHom

/- warning: minpoly.minpoly_alg_equiv -> minpoly.minpoly_algEquiv is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align minpoly.minpoly_alg_equiv minpoly.minpoly_algEquivₓ'. -/
@[simp]
theorem minpoly_algEquiv (f : B ≃ₐ[A] B') (x : B) : minpoly A (f x) = minpoly A x :=
  minpoly_algHom (f : B →ₐ[A] B') f.Injective x
#align minpoly.minpoly_alg_equiv minpoly.minpoly_algEquiv

variable (A x)

#print minpoly.aeval /-
/-- An element is a root of its minimal polynomial. -/
@[simp]
theorem aeval : aeval x (minpoly A x) = 0 :=
  by
  delta minpoly; split_ifs with hx
  · exact (degree_lt_wf.min_mem _ hx).2
  · exact aeval_zero _
#align minpoly.aeval minpoly.aeval
-/

#print minpoly.ne_one /-
/-- A minimal polynomial is not `1`. -/
theorem ne_one [Nontrivial B] : minpoly A x ≠ 1 :=
  by
  intro h
  refine' (one_ne_zero : (1 : B) ≠ 0) _
  simpa using congr_arg (Polynomial.aeval x) h
#align minpoly.ne_one minpoly.ne_one
-/

/- warning: minpoly.map_ne_one -> minpoly.map_ne_one is a dubious translation:
lean 3 declaration is
  forall (A : Type.{u1}) {B : Type.{u2}} [_inst_1 : CommRing.{u1} A] [_inst_2 : Ring.{u2} B] [_inst_4 : Algebra.{u1, u2} A B (CommRing.toCommSemiring.{u1} A _inst_1) (Ring.toSemiring.{u2} B _inst_2)] (x : B) [_inst_6 : Nontrivial.{u2} B] {R : Type.{u3}} [_inst_7 : Semiring.{u3} R] [_inst_8 : Nontrivial.{u3} R] (f : RingHom.{u1, u3} A R (NonAssocRing.toNonAssocSemiring.{u1} A (Ring.toNonAssocRing.{u1} A (CommRing.toRing.{u1} A _inst_1))) (Semiring.toNonAssocSemiring.{u3} R _inst_7)), Ne.{succ u3} (Polynomial.{u3} R _inst_7) (Polynomial.map.{u1, u3} A R (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1)) _inst_7 f (minpoly.{u1, u2} A B _inst_1 _inst_2 _inst_4 x)) (OfNat.ofNat.{u3} (Polynomial.{u3} R _inst_7) 1 (OfNat.mk.{u3} (Polynomial.{u3} R _inst_7) 1 (One.one.{u3} (Polynomial.{u3} R _inst_7) (Polynomial.hasOne.{u3} R _inst_7))))
but is expected to have type
  forall (A : Type.{u1}) {B : Type.{u3}} [_inst_1 : CommRing.{u1} A] [_inst_2 : Ring.{u3} B] [_inst_4 : Algebra.{u1, u3} A B (CommRing.toCommSemiring.{u1} A _inst_1) (Ring.toSemiring.{u3} B _inst_2)] (x : B) [_inst_6 : Nontrivial.{u3} B] {R : Type.{u2}} [_inst_7 : Semiring.{u2} R] [_inst_8 : Nontrivial.{u2} R] (f : RingHom.{u1, u2} A R (Semiring.toNonAssocSemiring.{u1} A (CommSemiring.toSemiring.{u1} A (CommRing.toCommSemiring.{u1} A _inst_1))) (Semiring.toNonAssocSemiring.{u2} R _inst_7)), Ne.{succ u2} (Polynomial.{u2} R _inst_7) (Polynomial.map.{u1, u2} A R (CommSemiring.toSemiring.{u1} A (CommRing.toCommSemiring.{u1} A _inst_1)) _inst_7 f (minpoly.{u1, u3} A B _inst_1 _inst_2 _inst_4 x)) (OfNat.ofNat.{u2} (Polynomial.{u2} R _inst_7) 1 (One.toOfNat1.{u2} (Polynomial.{u2} R _inst_7) (Polynomial.one.{u2} R _inst_7)))
Case conversion may be inaccurate. Consider using '#align minpoly.map_ne_one minpoly.map_ne_oneₓ'. -/
theorem map_ne_one [Nontrivial B] {R : Type _} [Semiring R] [Nontrivial R] (f : A →+* R) :
    (minpoly A x).map f ≠ 1 := by
  by_cases hx : IsIntegral A x
  · exact mt ((monic hx).eq_one_of_map_eq_one f) (ne_one A x)
  · rw [eq_zero hx, Polynomial.map_zero]; exact zero_ne_one
#align minpoly.map_ne_one minpoly.map_ne_one

/- warning: minpoly.not_is_unit -> minpoly.not_isUnit is a dubious translation:
lean 3 declaration is
  forall (A : Type.{u1}) {B : Type.{u2}} [_inst_1 : CommRing.{u1} A] [_inst_2 : Ring.{u2} B] [_inst_4 : Algebra.{u1, u2} A B (CommRing.toCommSemiring.{u1} A _inst_1) (Ring.toSemiring.{u2} B _inst_2)] (x : B) [_inst_6 : Nontrivial.{u2} B], Not (IsUnit.{u1} (Polynomial.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))) (Ring.toMonoid.{u1} (Polynomial.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))) (Polynomial.ring.{u1} A (CommRing.toRing.{u1} A _inst_1))) (minpoly.{u1, u2} A B _inst_1 _inst_2 _inst_4 x))
but is expected to have type
  forall (A : Type.{u1}) {B : Type.{u2}} [_inst_1 : CommRing.{u1} A] [_inst_2 : Ring.{u2} B] [_inst_4 : Algebra.{u1, u2} A B (CommRing.toCommSemiring.{u1} A _inst_1) (Ring.toSemiring.{u2} B _inst_2)] (x : B) [_inst_6 : Nontrivial.{u2} B], Not (IsUnit.{u1} (Polynomial.{u1} A (CommSemiring.toSemiring.{u1} A (CommRing.toCommSemiring.{u1} A _inst_1))) (MonoidWithZero.toMonoid.{u1} (Polynomial.{u1} A (CommSemiring.toSemiring.{u1} A (CommRing.toCommSemiring.{u1} A _inst_1))) (Semiring.toMonoidWithZero.{u1} (Polynomial.{u1} A (CommSemiring.toSemiring.{u1} A (CommRing.toCommSemiring.{u1} A _inst_1))) (Polynomial.semiring.{u1} A (CommSemiring.toSemiring.{u1} A (CommRing.toCommSemiring.{u1} A _inst_1))))) (minpoly.{u1, u2} A B _inst_1 _inst_2 _inst_4 x))
Case conversion may be inaccurate. Consider using '#align minpoly.not_is_unit minpoly.not_isUnitₓ'. -/
/-- A minimal polynomial is not a unit. -/
theorem not_isUnit [Nontrivial B] : ¬IsUnit (minpoly A x) :=
  by
  haveI : Nontrivial A := (algebraMap A B).domain_nontrivial
  by_cases hx : IsIntegral A x
  · exact mt (monic hx).eq_one_of_isUnit (ne_one A x)
  · rw [eq_zero hx]; exact not_isUnit_zero
#align minpoly.not_is_unit minpoly.not_isUnit

/- warning: minpoly.mem_range_of_degree_eq_one -> minpoly.mem_range_of_degree_eq_one is a dubious translation:
lean 3 declaration is
  forall (A : Type.{u1}) {B : Type.{u2}} [_inst_1 : CommRing.{u1} A] [_inst_2 : Ring.{u2} B] [_inst_4 : Algebra.{u1, u2} A B (CommRing.toCommSemiring.{u1} A _inst_1) (Ring.toSemiring.{u2} B _inst_2)] (x : B), (Eq.{1} (WithBot.{0} Nat) (Polynomial.degree.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1)) (minpoly.{u1, u2} A B _inst_1 _inst_2 _inst_4 x)) (OfNat.ofNat.{0} (WithBot.{0} Nat) 1 (OfNat.mk.{0} (WithBot.{0} Nat) 1 (One.one.{0} (WithBot.{0} Nat) (WithBot.hasOne.{0} Nat Nat.hasOne))))) -> (Membership.Mem.{u2, u2} B (Subring.{u2} B _inst_2) (SetLike.hasMem.{u2, u2} (Subring.{u2} B _inst_2) B (Subring.setLike.{u2} B _inst_2)) x (RingHom.range.{u1, u2} A B (CommRing.toRing.{u1} A _inst_1) _inst_2 (algebraMap.{u1, u2} A B (CommRing.toCommSemiring.{u1} A _inst_1) (Ring.toSemiring.{u2} B _inst_2) _inst_4)))
but is expected to have type
  forall (A : Type.{u2}) {B : Type.{u1}} [_inst_1 : CommRing.{u2} A] [_inst_2 : Ring.{u1} B] [_inst_4 : Algebra.{u2, u1} A B (CommRing.toCommSemiring.{u2} A _inst_1) (Ring.toSemiring.{u1} B _inst_2)] (x : B), (Eq.{1} (WithBot.{0} Nat) (Polynomial.degree.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1)) (minpoly.{u2, u1} A B _inst_1 _inst_2 _inst_4 x)) (OfNat.ofNat.{0} (WithBot.{0} Nat) 1 (One.toOfNat1.{0} (WithBot.{0} Nat) (WithBot.one.{0} Nat (CanonicallyOrderedCommSemiring.toOne.{0} Nat Nat.canonicallyOrderedCommSemiring))))) -> (Membership.mem.{u1, u1} B (Subring.{u1} B _inst_2) (SetLike.instMembership.{u1, u1} (Subring.{u1} B _inst_2) B (Subring.instSetLikeSubring.{u1} B _inst_2)) x (RingHom.range.{u2, u1} A B (CommRing.toRing.{u2} A _inst_1) _inst_2 (algebraMap.{u2, u1} A B (CommRing.toCommSemiring.{u2} A _inst_1) (Ring.toSemiring.{u1} B _inst_2) _inst_4)))
Case conversion may be inaccurate. Consider using '#align minpoly.mem_range_of_degree_eq_one minpoly.mem_range_of_degree_eq_oneₓ'. -/
theorem mem_range_of_degree_eq_one (hx : (minpoly A x).degree = 1) : x ∈ (algebraMap A B).range :=
  by
  have h : IsIntegral A x := by
    by_contra h
    rw [eq_zero h, degree_zero, ← WithBot.coe_one] at hx
    exact ne_of_lt (show ⊥ < ↑1 from WithBot.bot_lt_coe 1) hx
  have key := minpoly.aeval A x
  rw [eq_X_add_C_of_degree_eq_one hx, (minpoly.monic h).leadingCoeff, C_1, one_mul, aeval_add,
    aeval_C, aeval_X, ← eq_neg_iff_add_eq_zero, ← RingHom.map_neg] at key
  exact ⟨-(minpoly A x).coeff 0, key.symm⟩
#align minpoly.mem_range_of_degree_eq_one minpoly.mem_range_of_degree_eq_one

/- warning: minpoly.min -> minpoly.min is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align minpoly.min minpoly.minₓ'. -/
/-- The defining property of the minimal polynomial of an element `x`:
it is the monic polynomial with smallest degree that has `x` as its root. -/
theorem min {p : A[X]} (pmonic : p.Monic) (hp : Polynomial.aeval x p = 0) :
    degree (minpoly A x) ≤ degree p := by
  delta minpoly; split_ifs with hx
  · exact le_of_not_lt (degree_lt_wf.not_lt_min _ hx ⟨pmonic, hp⟩)
  · simp only [degree_zero, bot_le]
#align minpoly.min minpoly.min

/- warning: minpoly.unique' -> minpoly.unique' is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align minpoly.unique' minpoly.unique'ₓ'. -/
theorem unique' {p : A[X]} (hm : p.Monic) (hp : Polynomial.aeval x p = 0)
    (hl : ∀ q : A[X], degree q < degree p → q = 0 ∨ Polynomial.aeval x q ≠ 0) : p = minpoly A x :=
  by
  nontriviality A
  have hx : IsIntegral A x := ⟨p, hm, hp⟩
  obtain h | h := hl _ ((minpoly A x).degree_modByMonic_lt hm); swap
  · exact (h <| (aeval_mod_by_monic_eq_self_of_root hm hp).trans <| aeval A x).elim
  obtain ⟨r, hr⟩ := (dvd_iff_mod_by_monic_eq_zero hm).1 h
  rw [hr]; have hlead := congr_arg leading_coeff hr
  rw [mul_comm, leading_coeff_mul_monic hm, (monic hx).leadingCoeff] at hlead
  have : nat_degree r ≤ 0 :=
    by
    have hr0 : r ≠ 0 := by rintro rfl; exact NeZero hx (MulZeroClass.mul_zero p ▸ hr)
    apply_fun nat_degree  at hr
    rw [hm.nat_degree_mul' hr0] at hr
    apply Nat.le_of_add_le_add_left
    rw [add_zero]
    exact hr.symm.trans_le (nat_degree_le_nat_degree <| min A x hm hp)
  rw [eq_C_of_nat_degree_le_zero this, ← Nat.eq_zero_of_le_zero this, ← leading_coeff, ← hlead, C_1,
    mul_one]
#align minpoly.unique' minpoly.unique'

#print minpoly.subsingleton /-
@[nontriviality]
theorem subsingleton [Subsingleton B] : minpoly A x = 1 :=
  by
  nontriviality A
  have := minpoly.min A x monic_one (Subsingleton.elim _ _)
  rw [degree_one] at this
  cases' le_or_lt (minpoly A x).degree 0 with h h
  · rwa [(monic ⟨1, monic_one, by simp⟩ : (minpoly A x).Monic).degree_le_zero_iff_eq_one] at h
  · exact (this.not_lt h).elim
#align minpoly.subsingleton minpoly.subsingleton
-/

end Ring

section CommRing

variable [CommRing A]

section Ring

variable [Ring B] [Algebra A B]

variable {x : B}

#print minpoly.natDegree_pos /-
/-- The degree of a minimal polynomial, as a natural number, is positive. -/
theorem natDegree_pos [Nontrivial B] (hx : IsIntegral A x) : 0 < natDegree (minpoly A x) :=
  by
  rw [pos_iff_ne_zero]
  intro ndeg_eq_zero
  have eq_one : minpoly A x = 1 :=
    by
    rw [eq_C_of_nat_degree_eq_zero ndeg_eq_zero]; convert C_1
    simpa only [ndeg_eq_zero.symm] using (monic hx).leadingCoeff
  simpa only [eq_one, AlgHom.map_one, one_ne_zero] using aeval A x
#align minpoly.nat_degree_pos minpoly.natDegree_pos
-/

/- warning: minpoly.degree_pos -> minpoly.degree_pos is a dubious translation:
lean 3 declaration is
  forall {A : Type.{u1}} {B : Type.{u2}} [_inst_1 : CommRing.{u1} A] [_inst_2 : Ring.{u2} B] [_inst_3 : Algebra.{u1, u2} A B (CommRing.toCommSemiring.{u1} A _inst_1) (Ring.toSemiring.{u2} B _inst_2)] {x : B} [_inst_4 : Nontrivial.{u2} B], (IsIntegral.{u1, u2} A B _inst_1 _inst_2 _inst_3 x) -> (LT.lt.{0} (WithBot.{0} Nat) (Preorder.toHasLt.{0} (WithBot.{0} Nat) (WithBot.preorder.{0} Nat (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))))) (OfNat.ofNat.{0} (WithBot.{0} Nat) 0 (OfNat.mk.{0} (WithBot.{0} Nat) 0 (Zero.zero.{0} (WithBot.{0} Nat) (WithBot.hasZero.{0} Nat Nat.hasZero)))) (Polynomial.degree.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1)) (minpoly.{u1, u2} A B _inst_1 _inst_2 _inst_3 x)))
but is expected to have type
  forall {A : Type.{u1}} {B : Type.{u2}} [_inst_1 : CommRing.{u1} A] [_inst_2 : Ring.{u2} B] [_inst_3 : Algebra.{u1, u2} A B (CommRing.toCommSemiring.{u1} A _inst_1) (Ring.toSemiring.{u2} B _inst_2)] {x : B} [_inst_4 : Nontrivial.{u2} B], (IsIntegral.{u1, u2} A B _inst_1 _inst_2 _inst_3 x) -> (LT.lt.{0} (WithBot.{0} Nat) (Preorder.toLT.{0} (WithBot.{0} Nat) (WithBot.preorder.{0} Nat (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring)))) (OfNat.ofNat.{0} (WithBot.{0} Nat) 0 (Zero.toOfNat0.{0} (WithBot.{0} Nat) (WithBot.zero.{0} Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero)))) (Polynomial.degree.{u1} A (CommSemiring.toSemiring.{u1} A (CommRing.toCommSemiring.{u1} A _inst_1)) (minpoly.{u1, u2} A B _inst_1 _inst_2 _inst_3 x)))
Case conversion may be inaccurate. Consider using '#align minpoly.degree_pos minpoly.degree_posₓ'. -/
/-- The degree of a minimal polynomial is positive. -/
theorem degree_pos [Nontrivial B] (hx : IsIntegral A x) : 0 < degree (minpoly A x) :=
  natDegree_pos_iff_degree_pos.mp (natDegree_pos hx)
#align minpoly.degree_pos minpoly.degree_pos

/- warning: minpoly.eq_X_sub_C_of_algebra_map_inj -> minpoly.eq_X_sub_C_of_algebraMap_inj is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align minpoly.eq_X_sub_C_of_algebra_map_inj minpoly.eq_X_sub_C_of_algebraMap_injₓ'. -/
/-- If `B/A` is an injective ring extension, and `a` is an element of `A`,
then the minimal polynomial of `algebra_map A B a` is `X - C a`. -/
theorem eq_X_sub_C_of_algebraMap_inj (a : A) (hf : Function.Injective (algebraMap A B)) :
    minpoly A (algebraMap A B a) = X - C a :=
  by
  nontriviality A
  refine' (unique' A _ (monic_X_sub_C a) _ _).symm
  · rw [map_sub, aeval_C, aeval_X, sub_self]
  simp_rw [or_iff_not_imp_left]
  intro q hl h0
  rw [← nat_degree_lt_nat_degree_iff h0, nat_degree_X_sub_C, Nat.lt_one_iff] at hl
  rw [eq_C_of_nat_degree_eq_zero hl] at h0⊢
  rwa [aeval_C, map_ne_zero_iff _ hf, ← C_ne_zero]
#align minpoly.eq_X_sub_C_of_algebra_map_inj minpoly.eq_X_sub_C_of_algebraMap_inj

end Ring

section IsDomain

variable [Ring B] [Algebra A B]

variable {x : B}

/- warning: minpoly.aeval_ne_zero_of_dvd_not_unit_minpoly -> minpoly.aeval_ne_zero_of_dvdNotUnit_minpoly is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align minpoly.aeval_ne_zero_of_dvd_not_unit_minpoly minpoly.aeval_ne_zero_of_dvdNotUnit_minpolyₓ'. -/
/-- If `a` strictly divides the minimal polynomial of `x`, then `x` cannot be a root for `a`. -/
theorem aeval_ne_zero_of_dvdNotUnit_minpoly {a : A[X]} (hx : IsIntegral A x) (hamonic : a.Monic)
    (hdvd : DvdNotUnit a (minpoly A x)) : Polynomial.aeval x a ≠ 0 :=
  by
  refine' fun ha => (min A x hamonic ha).not_lt (degree_lt_degree _)
  obtain ⟨b, c, hu, he⟩ := hdvd
  have hcm := hamonic.of_mul_monic_left (he.subst <| monic hx)
  rw [he, hamonic.nat_degree_mul hcm]
  apply Nat.lt_add_of_zero_lt_left _ _ (lt_of_not_le fun h => hu _)
  rw [eq_C_of_nat_degree_le_zero h, ← Nat.eq_zero_of_le_zero h, ← leading_coeff, hcm.leading_coeff,
    C_1]
  exact isUnit_one
#align minpoly.aeval_ne_zero_of_dvd_not_unit_minpoly minpoly.aeval_ne_zero_of_dvdNotUnit_minpoly

variable [IsDomain A] [IsDomain B]

/- warning: minpoly.irreducible -> minpoly.irreducible is a dubious translation:
lean 3 declaration is
  forall {A : Type.{u1}} {B : Type.{u2}} [_inst_1 : CommRing.{u1} A] [_inst_2 : Ring.{u2} B] [_inst_3 : Algebra.{u1, u2} A B (CommRing.toCommSemiring.{u1} A _inst_1) (Ring.toSemiring.{u2} B _inst_2)] {x : B} [_inst_4 : IsDomain.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))] [_inst_5 : IsDomain.{u2} B (Ring.toSemiring.{u2} B _inst_2)], (IsIntegral.{u1, u2} A B _inst_1 _inst_2 _inst_3 x) -> (Irreducible.{u1} (Polynomial.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))) (Ring.toMonoid.{u1} (Polynomial.{u1} A (Ring.toSemiring.{u1} A (CommRing.toRing.{u1} A _inst_1))) (Polynomial.ring.{u1} A (CommRing.toRing.{u1} A _inst_1))) (minpoly.{u1, u2} A B _inst_1 _inst_2 _inst_3 x))
but is expected to have type
  forall {A : Type.{u2}} {B : Type.{u1}} [_inst_1 : CommRing.{u2} A] [_inst_2 : Ring.{u1} B] [_inst_3 : Algebra.{u2, u1} A B (CommRing.toCommSemiring.{u2} A _inst_1) (Ring.toSemiring.{u1} B _inst_2)] {x : B} [_inst_4 : IsDomain.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))] [_inst_5 : IsDomain.{u1} B (Ring.toSemiring.{u1} B _inst_2)], (IsIntegral.{u2, u1} A B _inst_1 _inst_2 _inst_3 x) -> (Irreducible.{u2} (Polynomial.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))) (MonoidWithZero.toMonoid.{u2} (Polynomial.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))) (Semiring.toMonoidWithZero.{u2} (Polynomial.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))) (Polynomial.semiring.{u2} A (CommSemiring.toSemiring.{u2} A (CommRing.toCommSemiring.{u2} A _inst_1))))) (minpoly.{u2, u1} A B _inst_1 _inst_2 _inst_3 x))
Case conversion may be inaccurate. Consider using '#align minpoly.irreducible minpoly.irreducibleₓ'. -/
/-- A minimal polynomial is irreducible. -/
theorem irreducible (hx : IsIntegral A x) : Irreducible (minpoly A x) :=
  by
  refine' (irreducible_of_monic (monic hx) <| ne_one A x).2 fun f g hf hg he => _
  rw [← hf.is_unit_iff, ← hg.is_unit_iff]
  by_contra' h
  have heval := congr_arg (Polynomial.aeval x) he
  rw [aeval A x, aeval_mul, mul_eq_zero] at heval
  cases heval
  · exact aeval_ne_zero_of_dvd_not_unit_minpoly hx hf ⟨hf.ne_zero, g, h.2, he.symm⟩ heval
  · refine' aeval_ne_zero_of_dvd_not_unit_minpoly hx hg ⟨hg.ne_zero, f, h.1, _⟩ heval
    rw [mul_comm, he]
#align minpoly.irreducible minpoly.irreducible

end IsDomain

end CommRing

end minpoly

