import Mathbin.RingTheory.Algebraic 
import Mathbin.RingTheory.Localization

/-!
# Ideals over/under ideals

This file concerns ideals lying over other ideals.
Let `f : R →+* S` be a ring homomorphism (typically a ring extension), `I` an ideal of `R` and
`J` an ideal of `S`. We say `J` lies over `I` (and `I` under `J`) if `I` is the `f`-preimage of `J`.
This is expressed here by writing `I = J.comap f`.

## Implementation notes

The proofs of the `comap_ne_bot` and `comap_lt_comap` families use an approach
specific for their situation: we construct an element in `I.comap f` from the
coefficients of a minimal polynomial.
Once mathlib has more material on the localization at a prime ideal, the results
can be proven using more general going-up/going-down theory.
-/


variable{R : Type _}[CommRingₓ R]

namespace Ideal

open Polynomial

open Submodule

section CommRingₓ

variable{S : Type _}[CommRingₓ S]{f : R →+* S}{I J : Ideal S}

theorem coeff_zero_mem_comap_of_root_mem_of_eval_mem {r : S} (hr : r ∈ I) {p : Polynomial R} (hp : p.eval₂ f r ∈ I) :
  p.coeff 0 ∈ I.comap f :=
  by 
    rw [←p.div_X_mul_X_add, eval₂_add, eval₂_C, eval₂_mul, eval₂_X] at hp 
    refine' mem_comap.mpr ((I.add_mem_iff_right _).mp hp)
    exact I.mul_mem_left _ hr

theorem coeff_zero_mem_comap_of_root_mem {r : S} (hr : r ∈ I) {p : Polynomial R} (hp : p.eval₂ f r = 0) :
  p.coeff 0 ∈ I.comap f :=
  coeff_zero_mem_comap_of_root_mem_of_eval_mem hr (hp.symm ▸ I.zero_mem)

theorem exists_coeff_ne_zero_mem_comap_of_non_zero_divisor_root_mem {r : S}
  (r_non_zero_divisor : ∀ {x}, (x*r) = 0 → x = 0) (hr : r ∈ I) {p : Polynomial R} :
  ∀ (p_ne_zero : p ≠ 0) (hp : p.eval₂ f r = 0), ∃ i, p.coeff i ≠ 0 ∧ p.coeff i ∈ I.comap f :=
  by 
    refine' p.rec_on_horner _ _ _
    ·
      intro h 
      contradiction
    ·
      intro p a coeff_eq_zero a_ne_zero ih p_ne_zero hp 
      refine' ⟨0, _, coeff_zero_mem_comap_of_root_mem hr hp⟩
      simp [coeff_eq_zero, a_ne_zero]
    ·
      intro p p_nonzero ih mul_nonzero hp 
      rw [eval₂_mul, eval₂_X] at hp 
      obtain ⟨i, hi, mem⟩ := ih p_nonzero (r_non_zero_divisor hp)
      refine' ⟨i+1, _, _⟩ <;> simp [hi, mem]

/-- Let `P` be an ideal in `R[x]`.  The map
`R[x]/P → (R / (P ∩ R))[x] / (P / (P ∩ R))`
is injective.
-/
theorem injective_quotient_le_comap_map (P : Ideal (Polynomial R)) :
  Function.Injective
    ((map (map_ring_hom (Quotientₓ.mk (P.comap C))) P).quotientMap (map_ring_hom (Quotientₓ.mk (P.comap C)))
      le_comap_map) :=
  by 
    refine' quotient_map_injective' (le_of_eqₓ _)
    rw [comap_map_of_surjective (map_ring_hom (Quotientₓ.mk (P.comap C))) (map_surjective _ quotient.mk_surjective)]
    refine' le_antisymmₓ (sup_le le_rfl _) (le_sup_of_le_left le_rfl)
    refine' fun p hp => polynomial_mem_ideal_of_coeff_mem_ideal P p fun n => quotient.eq_zero_iff_mem.mp _ 
    simpa only [coeff_map, coe_map_ring_hom] using ext_iff.mp (ideal.mem_bot.mp (mem_comap.mp hp)) n

/--
The identity in this lemma asserts that the "obvious" square
```
    R    → (R / (P ∩ R))
    ↓          ↓
R[x] / P → (R / (P ∩ R))[x] / (P / (P ∩ R))
```
commutes.  It is used, for instance, in the proof of `quotient_mk_comp_C_is_integral_of_jacobson`,
in the file `ring_theory/jacobson`.
-/
theorem quotient_mk_maps_eq (P : Ideal (Polynomial R)) :
  ((Quotientₓ.mk (map (map_ring_hom (Quotientₓ.mk (P.comap C))) P)).comp C).comp (Quotientₓ.mk (P.comap C)) =
    ((map (map_ring_hom (Quotientₓ.mk (P.comap C))) P).quotientMap (map_ring_hom (Quotientₓ.mk (P.comap C)))
          le_comap_map).comp
      ((Quotientₓ.mk P).comp C) :=
  by 
    refine' RingHom.ext fun x => _ 
    repeat' 
      rw [RingHom.coe_comp, Function.comp_app]
    rw [quotient_map_mk, coe_map_ring_hom, map_C]

/--
This technical lemma asserts the existence of a polynomial `p` in an ideal `P ⊂ R[x]`
that is non-zero in the quotient `R / (P ∩ R) [x]`.  The assumptions are equivalent to
`P ≠ 0` and `P ∩ R = (0)`.
-/
theorem exists_nonzero_mem_of_ne_bot {P : Ideal (Polynomial R)} (Pb : P ≠ ⊥) (hP : ∀ (x : R), C x ∈ P → x = 0) :
  ∃ p : Polynomial R, p ∈ P ∧ Polynomial.map (Quotientₓ.mk (P.comap C)) p ≠ 0 :=
  by 
    obtain ⟨m, hm⟩ := Submodule.nonzero_mem_of_bot_lt (bot_lt_iff_ne_bot.mpr Pb)
    refine' ⟨m, Submodule.coe_mem m, fun pp0 => hm (submodule.coe_eq_zero.mp _)⟩
    refine' (RingHom.injective_iff (Polynomial.mapRingHom (Quotientₓ.mk (P.comap C)))).mp _ _ pp0 
    refine' map_injective _ ((Quotientₓ.mk (P.comap C)).injective_iff_ker_eq_bot.mpr _)
    rw [mk_ker]
    exact (Submodule.eq_bot_iff _).mpr fun x hx => hP x (mem_comap.mp hx)

variable{p : Ideal R}{P : Ideal S}

/-- If there is an injective map `R/p → S/P` such that following diagram commutes:
```
R   → S
↓     ↓
R/p → S/P
```
then `P` lies over `p`.
-/
theorem comap_eq_of_scalar_tower_quotient [Algebra R S] [Algebra p.quotient P.quotient]
  [IsScalarTower R p.quotient P.quotient] (h : Function.Injective (algebraMap p.quotient P.quotient)) :
  comap (algebraMap R S) P = p :=
  by 
    ext x 
    split  <;>
      rw [mem_comap, ←quotient.eq_zero_iff_mem, ←quotient.eq_zero_iff_mem, quotient.mk_algebra_map,
        IsScalarTower.algebra_map_apply _ p.quotient, quotient.algebra_map_eq]
    ·
      intro hx 
      exact (algebraMap p.quotient P.quotient).injective_iff.mp h _ hx
    ·
      intro hx 
      rw [hx, RingHom.map_zero]

/-- If `P` lies over `p`, then `R / p` has a canonical map to `S / P`. -/
def quotient.algebra_quotient_of_le_comap (h : p ≤ comap f P) : Algebra p.quotient P.quotient :=
  RingHom.toAlgebra$ quotient_map _ f h

/-- `R / p` has a canonical map to `S / pS`. -/
instance quotient.algebra_quotient_map_quotient : Algebra p.quotient (map f p).Quotient :=
  quotient.algebra_quotient_of_le_comap le_comap_map

@[simp]
theorem quotient.algebra_map_quotient_map_quotient (x : R) :
  algebraMap p.quotient (map f p).Quotient (Quotientₓ.mk p x) = Quotientₓ.mk _ (f x) :=
  rfl

@[simp]
theorem quotient.mk_smul_mk_quotient_map_quotient (x : R) (y : S) :
  Quotientₓ.mk p x • Quotientₓ.mk (map f p) y = Quotientₓ.mk _ (f x*y) :=
  rfl

instance quotient.tower_quotient_map_quotient [Algebra R S] :
  IsScalarTower R p.quotient (map (algebraMap R S) p).Quotient :=
  IsScalarTower.of_algebra_map_eq$
    fun x =>
      by 
        rw [quotient.algebra_map_eq, quotient.algebra_map_quotient_map_quotient, quotient.mk_algebra_map]

end CommRingₓ

section IsDomain

variable{S : Type _}[CommRingₓ S]{f : R →+* S}{I J : Ideal S}

theorem exists_coeff_ne_zero_mem_comap_of_root_mem [IsDomain S] {r : S} (r_ne_zero : r ≠ 0) (hr : r ∈ I)
  {p : Polynomial R} : ∀ (p_ne_zero : p ≠ 0) (hp : p.eval₂ f r = 0), ∃ i, p.coeff i ≠ 0 ∧ p.coeff i ∈ I.comap f :=
  exists_coeff_ne_zero_mem_comap_of_non_zero_divisor_root_mem (fun _ h => Or.resolve_right (mul_eq_zero.mp h) r_ne_zero)
    hr

-- error in RingTheory.Ideal.Over: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem exists_coeff_mem_comap_sdiff_comap_of_root_mem_sdiff
[is_prime I]
(hIJ : «expr ≤ »(I, J))
{r : S}
(hr : «expr ∈ »(r, «expr \ »((J : set S), I)))
{p : polynomial R}
(p_ne_zero : «expr ≠ »(p.map (quotient.mk (I.comap f)), 0))
(hpI : «expr ∈ »(p.eval₂ f r, I)) : «expr∃ , »((i), «expr ∈ »(p.coeff i, «expr \ »((J.comap f : set R), I.comap f))) :=
begin
  obtain ["⟨", ident hrJ, ",", ident hrI, "⟩", ":=", expr hr],
  have [ident rbar_ne_zero] [":", expr «expr ≠ »(quotient.mk I r, 0)] [":=", expr mt (quotient.mk_eq_zero I).mp hrI],
  have [ident rbar_mem_J] [":", expr «expr ∈ »(quotient.mk I r, J.map (quotient.mk I))] [":=", expr mem_map_of_mem _ hrJ],
  have [ident quotient_f] [":", expr ∀ x «expr ∈ » I.comap f, «expr = »((quotient.mk I).comp f x, 0)] [],
  { simp [] [] [] ["[", expr quotient.eq_zero_iff_mem, "]"] [] [] },
  have [ident rbar_root] [":", expr «expr = »((p.map (quotient.mk (I.comap f))).eval₂ (quotient.lift (I.comap f) _ quotient_f) (quotient.mk I r), 0)] [],
  { convert [] [expr quotient.eq_zero_iff_mem.mpr hpI] [],
    exact [expr trans (eval₂_map _ _ _) (hom_eval₂ p f (quotient.mk I) r).symm] },
  obtain ["⟨", ident i, ",", ident ne_zero, ",", ident mem, "⟩", ":=", expr exists_coeff_ne_zero_mem_comap_of_root_mem rbar_ne_zero rbar_mem_J p_ne_zero rbar_root],
  rw [expr coeff_map] ["at", ident ne_zero, ident mem],
  refine [expr ⟨i, (mem_quotient_iff_mem hIJ).mp _, mt _ ne_zero⟩],
  { simpa [] [] [] [] [] ["using", expr mem] },
  simp [] [] [] ["[", expr quotient.eq_zero_iff_mem, "]"] [] []
end

theorem comap_lt_comap_of_root_mem_sdiff [I.is_prime] (hIJ : I ≤ J) {r : S} (hr : r ∈ (J : Set S) \ I)
  {p : Polynomial R} (p_ne_zero : p.map (Quotientₓ.mk (I.comap f)) ≠ 0) (hp : p.eval₂ f r ∈ I) :
  I.comap f < J.comap f :=
  let ⟨i, hJ, hI⟩ := exists_coeff_mem_comap_sdiff_comap_of_root_mem_sdiff hIJ hr p_ne_zero hp 
  SetLike.lt_iff_le_and_exists.mpr ⟨comap_mono hIJ, p.coeff i, hJ, hI⟩

theorem mem_of_one_mem (h : (1 : S) ∈ I) x : x ∈ I :=
  (I.eq_top_iff_one.mpr h).symm ▸ mem_top

theorem comap_lt_comap_of_integral_mem_sdiff [Algebra R S] [hI : I.is_prime] (hIJ : I ≤ J) {x : S}
  (mem : x ∈ (J : Set S) \ I) (integral : IsIntegral R x) : I.comap (algebraMap R S) < J.comap (algebraMap _ _) :=
  by 
    obtain ⟨p, p_monic, hpx⟩ := integral 
    refine' comap_lt_comap_of_root_mem_sdiff hIJ mem _ _ 
    swap
    ·
      apply map_monic_ne_zero p_monic 
      apply quotient.nontrivial 
      apply mt comap_eq_top_iff.mp 
      apply hI.1
    convert I.zero_mem

theorem comap_ne_bot_of_root_mem [IsDomain S] {r : S} (r_ne_zero : r ≠ 0) (hr : r ∈ I) {p : Polynomial R}
  (p_ne_zero : p ≠ 0) (hp : p.eval₂ f r = 0) : I.comap f ≠ ⊥ :=
  fun h =>
    let ⟨i, hi, mem⟩ := exists_coeff_ne_zero_mem_comap_of_root_mem r_ne_zero hr p_ne_zero hp 
    absurd (mem_bot.mp (eq_bot_iff.mp h mem)) hi

theorem is_maximal_of_is_integral_of_is_maximal_comap [Algebra R S] (hRS : Algebra.IsIntegral R S) (I : Ideal S)
  [I.is_prime] (hI : is_maximal (I.comap (algebraMap R S))) : is_maximal I :=
  ⟨⟨mt comap_eq_top_iff.mpr hI.1.1,
      fun J I_lt_J =>
        let ⟨I_le_J, x, hxJ, hxI⟩ := SetLike.lt_iff_le_and_exists.mp I_lt_J 
        comap_eq_top_iff.1$ hI.1.2 _ (comap_lt_comap_of_integral_mem_sdiff I_le_J ⟨hxJ, hxI⟩ (hRS x))⟩⟩

theorem is_maximal_of_is_integral_of_is_maximal_comap' (f : R →+* S) (hf : f.is_integral) (I : Ideal S)
  [hI' : I.is_prime] (hI : is_maximal (I.comap f)) : is_maximal I :=
  @is_maximal_of_is_integral_of_is_maximal_comap R _ S _ f.to_algebra hf I hI' hI

variable[Algebra R S]

theorem comap_ne_bot_of_algebraic_mem [IsDomain S] {x : S} (x_ne_zero : x ≠ 0) (x_mem : x ∈ I) (hx : IsAlgebraic R x) :
  I.comap (algebraMap R S) ≠ ⊥ :=
  let ⟨p, p_ne_zero, hp⟩ := hx 
  comap_ne_bot_of_root_mem x_ne_zero x_mem p_ne_zero hp

theorem comap_ne_bot_of_integral_mem [Nontrivial R] [IsDomain S] {x : S} (x_ne_zero : x ≠ 0) (x_mem : x ∈ I)
  (hx : IsIntegral R x) : I.comap (algebraMap R S) ≠ ⊥ :=
  comap_ne_bot_of_algebraic_mem x_ne_zero x_mem (hx.is_algebraic R)

theorem eq_bot_of_comap_eq_bot [Nontrivial R] [IsDomain S] (hRS : Algebra.IsIntegral R S)
  (hI : I.comap (algebraMap R S) = ⊥) : I = ⊥ :=
  by 
    refine' eq_bot_iff.2 fun x hx => _ 
    byCases' hx0 : x = 0
    ·
      exact hx0.symm ▸ Ideal.zero_mem ⊥
    ·
      exact absurd hI (comap_ne_bot_of_integral_mem hx0 hx (hRS x))

-- error in RingTheory.Ideal.Over: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem is_maximal_comap_of_is_integral_of_is_maximal
(hRS : algebra.is_integral R S)
(I : ideal S)
[hI : I.is_maximal] : is_maximal (I.comap (algebra_map R S)) :=
begin
  refine [expr quotient.maximal_of_is_field _ _],
  haveI [] [":", expr is_prime (I.comap (algebra_map R S))] [":=", expr comap_is_prime _ _],
  exact [expr is_field_of_is_integral_of_is_field (is_integral_quotient_of_is_integral hRS) algebra_map_quotient_injective (by rwa ["<-", expr quotient.maximal_ideal_iff_is_field_quotient] [])]
end

theorem is_maximal_comap_of_is_integral_of_is_maximal' {R S : Type _} [CommRingₓ R] [CommRingₓ S] (f : R →+* S)
  (hf : f.is_integral) (I : Ideal S) (hI : I.is_maximal) : is_maximal (I.comap f) :=
  @is_maximal_comap_of_is_integral_of_is_maximal R _ S _ f.to_algebra hf I hI

section IsIntegralClosure

variable(S){A : Type _}[CommRingₓ A]

variable[Algebra R A][Algebra A S][IsScalarTower R A S][IsIntegralClosure A R S]

theorem is_integral_closure.comap_lt_comap {I J : Ideal A} [I.is_prime] (I_lt_J : I < J) :
  I.comap (algebraMap R A) < J.comap (algebraMap _ _) :=
  let ⟨I_le_J, x, hxJ, hxI⟩ := SetLike.lt_iff_le_and_exists.mp I_lt_J 
  comap_lt_comap_of_integral_mem_sdiff I_le_J ⟨hxJ, hxI⟩ (IsIntegralClosure.is_integral R S x)

theorem is_integral_closure.is_maximal_of_is_maximal_comap (I : Ideal A) [I.is_prime]
  (hI : is_maximal (I.comap (algebraMap R A))) : is_maximal I :=
  is_maximal_of_is_integral_of_is_maximal_comap (fun x => IsIntegralClosure.is_integral R S x) I hI

variable[IsDomain A]

theorem is_integral_closure.comap_ne_bot [Nontrivial R] {I : Ideal A} (I_ne_bot : I ≠ ⊥) :
  I.comap (algebraMap R A) ≠ ⊥ :=
  let ⟨x, x_mem, x_ne_zero⟩ := I.ne_bot_iff.mp I_ne_bot 
  comap_ne_bot_of_integral_mem x_ne_zero x_mem (IsIntegralClosure.is_integral R S x)

theorem is_integral_closure.eq_bot_of_comap_eq_bot [Nontrivial R] {I : Ideal A} :
  I.comap (algebraMap R A) = ⊥ → I = ⊥ :=
  imp_of_not_imp_not _ _ (is_integral_closure.comap_ne_bot S)

end IsIntegralClosure

theorem integral_closure.comap_lt_comap {I J : Ideal (integralClosure R S)} [I.is_prime] (I_lt_J : I < J) :
  I.comap (algebraMap R (integralClosure R S)) < J.comap (algebraMap _ _) :=
  is_integral_closure.comap_lt_comap S I_lt_J

theorem integral_closure.is_maximal_of_is_maximal_comap (I : Ideal (integralClosure R S)) [I.is_prime]
  (hI : is_maximal (I.comap (algebraMap R (integralClosure R S)))) : is_maximal I :=
  is_integral_closure.is_maximal_of_is_maximal_comap S I hI

section 

variable[IsDomain S]

theorem integral_closure.comap_ne_bot [Nontrivial R] {I : Ideal (integralClosure R S)} (I_ne_bot : I ≠ ⊥) :
  I.comap (algebraMap R (integralClosure R S)) ≠ ⊥ :=
  is_integral_closure.comap_ne_bot S I_ne_bot

theorem integral_closure.eq_bot_of_comap_eq_bot [Nontrivial R] {I : Ideal (integralClosure R S)} :
  I.comap (algebraMap R (integralClosure R S)) = ⊥ → I = ⊥ :=
  is_integral_closure.eq_bot_of_comap_eq_bot S

-- error in RingTheory.Ideal.Over: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- `comap (algebra_map R S)` is a surjection from the prime spec of `R` to prime spec of `S`.
`hP : (algebra_map R S).ker ≤ P` is a slight generalization of the extension being injective -/
theorem exists_ideal_over_prime_of_is_integral'
(H : algebra.is_integral R S)
(P : ideal R)
[is_prime P]
(hP : «expr ≤ »((algebra_map R S).ker, P)) : «expr∃ , »((Q : ideal S), «expr ∧ »(is_prime Q, «expr = »(Q.comap (algebra_map R S), P))) :=
begin
  have [ident hP0] [":", expr «expr ∉ »((0 : S), algebra.algebra_map_submonoid S P.prime_compl)] [],
  { rintro ["⟨", ident x, ",", "⟨", ident hx, ",", ident x0, "⟩", "⟩"],
    exact [expr absurd (hP x0) hx] },
  let [ident Rₚ] [] [":=", expr localization P.prime_compl],
  let [ident Sₚ] [] [":=", expr localization (algebra.algebra_map_submonoid S P.prime_compl)],
  letI [] [":", expr is_domain (localization (algebra.algebra_map_submonoid S P.prime_compl))] [":=", expr is_localization.is_domain_localization (le_non_zero_divisors_of_no_zero_divisors hP0)],
  obtain ["⟨", ident Qₚ, ":", expr ideal Sₚ, ",", ident Qₚ_maximal, "⟩", ":=", expr exists_maximal Sₚ],
  haveI [ident Qₚ_max] [":", expr is_maximal (comap _ Qₚ)] [":=", expr @is_maximal_comap_of_is_integral_of_is_maximal Rₚ _ Sₚ _ (localization_algebra P.prime_compl S) (is_integral_localization H) _ Qₚ_maximal],
  refine [expr ⟨comap (algebra_map S Sₚ) Qₚ, ⟨comap_is_prime _ Qₚ, _⟩⟩],
  convert [] [expr localization.at_prime.comap_maximal_ideal] [],
  rw ["[", expr comap_comap, ",", "<-", expr local_ring.eq_maximal_ideal Qₚ_max, ",", "<-", expr is_localization.map_comp _, "]"] [],
  refl
end

end 

-- error in RingTheory.Ideal.Over: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- More general going-up theorem than `exists_ideal_over_prime_of_is_integral'`.
TODO: Version of going-up theorem with arbitrary length chains (by induction on this)?
  Not sure how best to write an ascending chain in Lean -/
theorem exists_ideal_over_prime_of_is_integral
(H : algebra.is_integral R S)
(P : ideal R)
[is_prime P]
(I : ideal S)
[is_prime I]
(hIP : «expr ≤ »(I.comap (algebra_map R S), P)) : «expr∃ , »((Q «expr ≥ » I), «expr ∧ »(is_prime Q, «expr = »(Q.comap (algebra_map R S), P))) :=
begin
  obtain ["⟨", ident Q', ":", expr ideal I.quotient, ",", "⟨", ident Q'_prime, ",", ident hQ', "⟩", "⟩", ":=", expr @exists_ideal_over_prime_of_is_integral' (I.comap (algebra_map R S)).quotient _ I.quotient _ ideal.quotient_algebra _ (is_integral_quotient_of_is_integral H) (map (quotient.mk (I.comap (algebra_map R S))) P) (map_is_prime_of_surjective quotient.mk_surjective (by simp [] [] [] ["[", expr hIP, "]"] [] [])) (le_trans (le_of_eq ((ring_hom.injective_iff_ker_eq_bot _).1 algebra_map_quotient_injective)) bot_le)],
  haveI [] [] [":=", expr Q'_prime],
  refine [expr ⟨Q'.comap _, le_trans (le_of_eq mk_ker.symm) (ker_le_comap _), ⟨comap_is_prime _ Q', _⟩⟩],
  rw [expr comap_comap] [],
  refine [expr trans _ (trans (congr_arg (comap (quotient.mk (comap (algebra_map R S) I))) hQ') _)],
  { simpa [] [] [] ["[", expr comap_comap, "]"] [] [] },
  { refine [expr trans (comap_map_of_surjective _ quotient.mk_surjective _) (sup_eq_left.2 _)],
    simpa [] [] [] ["[", "<-", expr ring_hom.ker_eq_comap_bot, "]"] [] ["using", expr hIP] }
end

-- error in RingTheory.Ideal.Over: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- `comap (algebra_map R S)` is a surjection from the max spec of `S` to max spec of `R`.
`hP : (algebra_map R S).ker ≤ P` is a slight generalization of the extension being injective -/
theorem exists_ideal_over_maximal_of_is_integral
[is_domain S]
(H : algebra.is_integral R S)
(P : ideal R)
[P_max : is_maximal P]
(hP : «expr ≤ »((algebra_map R S).ker, P)) : «expr∃ , »((Q : ideal S), «expr ∧ »(is_maximal Q, «expr = »(Q.comap (algebra_map R S), P))) :=
begin
  obtain ["⟨", ident Q, ",", "⟨", ident Q_prime, ",", ident hQ, "⟩", "⟩", ":=", expr exists_ideal_over_prime_of_is_integral' H P hP],
  haveI [] [":", expr Q.is_prime] [":=", expr Q_prime],
  exact [expr ⟨Q, is_maximal_of_is_integral_of_is_maximal_comap H _ «expr ▸ »(hQ.symm, P_max), hQ⟩]
end

end IsDomain

end Ideal

