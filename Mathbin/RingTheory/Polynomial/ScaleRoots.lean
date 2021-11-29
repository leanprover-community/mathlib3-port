import Mathbin.RingTheory.NonZeroDivisors 
import Mathbin.Data.Polynomial.AlgebraMap

/-!
# Scaling the roots of a polynomial

This file defines `scale_roots p s` for a polynomial `p` in one variable and a ring element `s` to
be the polynomial with root `r * s` for each root `r` of `p` and proves some basic results about it.
-/


section scaleRoots

variable{A K R S : Type _}[CommRingₓ A][IsDomain A][Field K][CommRingₓ R][CommRingₓ S]

variable{M : Submonoid A}

open Polynomial

open_locale BigOperators

/-- `scale_roots p s` is a polynomial with root `r * s` for each root `r` of `p`. -/
noncomputable def scaleRoots (p : Polynomial R) (s : R) : Polynomial R :=
  ∑i in p.support, monomial i (p.coeff i*s ^ (p.nat_degree - i))

-- error in RingTheory.Polynomial.ScaleRoots: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem coeff_scale_roots
(p : polynomial R)
(s : R)
(i : exprℕ()) : «expr = »((scale_roots p s).coeff i, «expr * »(coeff p i, «expr ^ »(s, «expr - »(p.nat_degree, i)))) :=
by simp [] [] [] ["[", expr scale_roots, ",", expr coeff_monomial, "]"] [] [] { contextual := tt }

theorem coeff_scale_roots_nat_degree (p : Polynomial R) (s : R) :
  (scaleRoots p s).coeff p.nat_degree = p.leading_coeff :=
  by 
    rw [leading_coeff, coeff_scale_roots, tsub_self, pow_zeroₓ, mul_oneₓ]

@[simp]
theorem zero_scale_roots (s : R) : scaleRoots 0 s = 0 :=
  by 
    ext 
    simp 

-- error in RingTheory.Polynomial.ScaleRoots: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem scale_roots_ne_zero {p : polynomial R} (hp : «expr ≠ »(p, 0)) (s : R) : «expr ≠ »(scale_roots p s, 0) :=
begin
  intro [ident h],
  have [] [":", expr «expr ≠ »(p.coeff p.nat_degree, 0)] [":=", expr mt leading_coeff_eq_zero.mp hp],
  have [] [":", expr «expr = »((scale_roots p s).coeff p.nat_degree, 0)] [":=", expr congr_fun (congr_arg (coeff : polynomial R → exprℕ() → R) h) p.nat_degree],
  rw ["[", expr coeff_scale_roots_nat_degree, "]"] ["at", ident this],
  contradiction
end

theorem support_scale_roots_le (p : Polynomial R) (s : R) : (scaleRoots p s).support ≤ p.support :=
  by 
    intro 
    simpa using left_ne_zero_of_mul

-- error in RingTheory.Polynomial.ScaleRoots: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem support_scale_roots_eq
(p : polynomial R)
{s : R}
(hs : «expr ∈ »(s, non_zero_divisors R)) : «expr = »((scale_roots p s).support, p.support) :=
le_antisymm (support_scale_roots_le p s) (begin
   intro [ident i],
   simp [] [] ["only"] ["[", expr coeff_scale_roots, ",", expr polynomial.mem_support_iff, "]"] [] [],
   intros [ident p_ne_zero, ident ps_zero],
   have [] [] [":=", expr (non_zero_divisors R).pow_mem hs «expr - »(p.nat_degree, i) _ ps_zero],
   contradiction
 end)

-- error in RingTheory.Polynomial.ScaleRoots: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp] theorem degree_scale_roots (p : polynomial R) {s : R} : «expr = »(degree (scale_roots p s), degree p) :=
begin
  haveI [] [] [":=", expr classical.prop_decidable],
  by_cases [expr hp, ":", expr «expr = »(p, 0)],
  { rw ["[", expr hp, ",", expr zero_scale_roots, "]"] [] },
  have [] [] [":=", expr scale_roots_ne_zero hp s],
  refine [expr le_antisymm (finset.sup_mono (support_scale_roots_le p s)) (degree_le_degree _)],
  rw [expr coeff_scale_roots_nat_degree] [],
  intro [ident h],
  have [] [] [":=", expr leading_coeff_eq_zero.mp h],
  contradiction
end

@[simp]
theorem nat_degree_scale_roots (p : Polynomial R) (s : R) : nat_degree (scaleRoots p s) = nat_degree p :=
  by 
    simp only [nat_degree, degree_scale_roots]

theorem monic_scale_roots_iff {p : Polynomial R} (s : R) : monic (scaleRoots p s) ↔ monic p :=
  by 
    simp only [monic, leading_coeff, nat_degree_scale_roots, coeff_scale_roots_nat_degree]

-- error in RingTheory.Polynomial.ScaleRoots: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem scale_roots_eval₂_eq_zero
{p : polynomial S}
(f : «expr →+* »(S, R))
{r : R}
{s : S}
(hr : «expr = »(eval₂ f r p, 0)) : «expr = »(eval₂ f «expr * »(f s, r) (scale_roots p s), 0) :=
calc
  «expr = »(eval₂ f «expr * »(f s, r) (scale_roots p s), (scale_roots p s).support.sum (λ
    i, «expr * »(f «expr * »(coeff p i, «expr ^ »(s, «expr - »(p.nat_degree, i))), «expr ^ »(«expr * »(f s, r), i)))) : by simp [] [] [] ["[", expr eval₂_eq_sum, ",", expr sum_def, "]"] [] []
  «expr = »(..., p.support.sum (λ
    i, «expr * »(f «expr * »(coeff p i, «expr ^ »(s, «expr - »(p.nat_degree, i))), «expr ^ »(«expr * »(f s, r), i)))) : finset.sum_subset (support_scale_roots_le p s) (λ
   i
   hi
   hi', let this : «expr = »(«expr * »(coeff p i, «expr ^ »(s, «expr - »(p.nat_degree, i))), 0) := by simpa [] [] [] [] [] ["using", expr hi'] in
   by simp [] [] [] ["[", expr this, "]"] [] [])
  «expr = »(..., p.support.sum (λ
    i : exprℕ(), «expr * »(«expr * »(f (p.coeff i), «expr ^ »(f s, «expr + »(«expr - »(p.nat_degree, i), i))), «expr ^ »(r, i)))) : finset.sum_congr rfl (λ
   i
   hi, by simp_rw ["[", expr f.map_mul, ",", expr f.map_pow, ",", expr pow_add, ",", expr mul_pow, ",", expr mul_assoc, "]"] [])
  «expr = »(..., p.support.sum (λ
    i : exprℕ(), «expr * »(«expr ^ »(f s, p.nat_degree), «expr * »(f (p.coeff i), «expr ^ »(r, i))))) : finset.sum_congr rfl (λ
   i hi, by { rw ["[", expr mul_assoc, ",", expr mul_left_comm, ",", expr tsub_add_cancel_of_le, "]"] [],
     exact [expr le_nat_degree_of_ne_zero (polynomial.mem_support_iff.mp hi)] })
  «expr = »(..., «expr * »(«expr ^ »(f s, p.nat_degree), p.support.sum (λ
     i : exprℕ(), «expr * »(f (p.coeff i), «expr ^ »(r, i))))) : finset.mul_sum.symm
  «expr = »(..., «expr * »(«expr ^ »(f s, p.nat_degree), eval₂ f r p)) : by { simp [] [] [] ["[", expr eval₂_eq_sum, ",", expr sum_def, "]"] [] [] }
  «expr = »(..., 0) : by rw ["[", expr hr, ",", expr _root_.mul_zero, "]"] []

theorem scale_roots_aeval_eq_zero [Algebra S R] {p : Polynomial S} {r : R} {s : S} (hr : aeval r p = 0) :
  aeval (algebraMap S R s*r) (scaleRoots p s) = 0 :=
  scale_roots_eval₂_eq_zero (algebraMap S R) hr

theorem scale_roots_eval₂_eq_zero_of_eval₂_div_eq_zero {p : Polynomial A} {f : A →+* K} (hf : Function.Injective f)
  {r s : A} (hr : eval₂ f (f r / f s) p = 0) (hs : s ∈ nonZeroDivisors A) : eval₂ f (f r) (scaleRoots p s) = 0 :=
  by 
    convert scale_roots_eval₂_eq_zero f hr 
    rw [←mul_div_assoc, mul_commₓ, mul_div_cancel]
    exact f.map_ne_zero_of_mem_non_zero_divisors hf hs

theorem scale_roots_aeval_eq_zero_of_aeval_div_eq_zero [Algebra A K] (inj : Function.Injective (algebraMap A K))
  {p : Polynomial A} {r s : A} (hr : aeval (algebraMap A K r / algebraMap A K s) p = 0) (hs : s ∈ nonZeroDivisors A) :
  aeval (algebraMap A K r) (scaleRoots p s) = 0 :=
  scale_roots_eval₂_eq_zero_of_eval₂_div_eq_zero inj hr hs

end scaleRoots

