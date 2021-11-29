import Mathbin.Algebra.GcdMonoid.Basic 
import Mathbin.Data.Polynomial.Derivative 
import Mathbin.Data.Polynomial.RingDivision 
import Mathbin.Data.Set.Pairwise 
import Mathbin.RingTheory.Coprime.Lemmas 
import Mathbin.RingTheory.EuclideanDomain

/-!
# Theory of univariate polynomials

This file starts looking like the ring theory of $ R[X] $

-/


noncomputable theory

open_locale Classical BigOperators

namespace Polynomial

universe u v w y z

variable{R : Type u}{S : Type v}{k : Type y}{A : Type z}{a b : R}{n : ℕ}

section IsDomain

variable[CommRingₓ R][IsDomain R][NormalizationMonoid R]

instance  : NormalizationMonoid (Polynomial R) :=
  { normUnit :=
      fun p =>
        ⟨C («expr↑ » (norm_unit p.leading_coeff)), C («expr↑ » (norm_unit p.leading_coeff⁻¹)),
          by 
            rw [←RingHom.map_mul, Units.mul_inv, C_1],
          by 
            rw [←RingHom.map_mul, Units.inv_mul, C_1]⟩,
    norm_unit_zero :=
      Units.ext
        (by 
          simp ),
    norm_unit_mul :=
      fun p q hp0 hq0 =>
        Units.ext
          (by 
            dsimp 
            rw [Ne.def, ←leading_coeff_eq_zero] at *
            rw [leading_coeff_mul, norm_unit_mul hp0 hq0, Units.coe_mul, C_mul]),
    norm_unit_coe_units :=
      fun u =>
        Units.ext
          (by 
            rw [←mul_oneₓ (u⁻¹), Units.coe_mul, Units.eq_inv_mul_iff_mul_eq]
            dsimp 
            rcases Polynomial.is_unit_iff.1 ⟨u, rfl⟩ with ⟨_, ⟨w, rfl⟩, h2⟩
            rw [←h2, leading_coeff_C, norm_unit_coe_units, ←C_mul, Units.mul_inv, C_1]) }

@[simp]
theorem coe_norm_unit {p : Polynomial R} : (norm_unit p : Polynomial R) = C («expr↑ » (norm_unit p.leading_coeff)) :=
  by 
    simp [norm_unit]

theorem leading_coeff_normalize (p : Polynomial R) : leading_coeff (normalize p) = normalize (leading_coeff p) :=
  by 
    simp 

theorem monic.normalize_eq_self {p : Polynomial R} (hp : p.monic) : normalize p = p :=
  by 
    simp only [Polynomial.coe_norm_unit, normalize_apply, hp.leading_coeff, norm_unit_one, Units.coe_one,
      polynomial.C.map_one, mul_oneₓ]

end IsDomain

section Field

variable[Field R]{p q : Polynomial R}

theorem is_unit_iff_degree_eq_zero : IsUnit p ↔ degree p = 0 :=
  ⟨degree_eq_zero_of_is_unit,
    fun h =>
      have  : degree p ≤ 0 :=
        by 
          simp [le_reflₓ]
      have hc : coeff p 0 ≠ 0 :=
        fun hc =>
          by 
            rw [eq_C_of_degree_le_zero this, hc] at h <;> simpa using h 
      is_unit_iff_dvd_one.2
        ⟨C (coeff p 0⁻¹),
          by 
            conv  in p => rw [eq_C_of_degree_le_zero this]
            rw [←C_mul, _root_.mul_inv_cancel hc, C_1]⟩⟩

theorem degree_pos_of_ne_zero_of_nonunit (hp0 : p ≠ 0) (hp : ¬IsUnit p) : 0 < degree p :=
  lt_of_not_geₓ
    fun h =>
      by 
        rw [eq_C_of_degree_le_zero h] at hp0 hp 
        exact
          hp
            (IsUnit.map (C.to_monoid_hom : R →* _)
              (IsUnit.mk0 (coeff p 0)
                (mt C_inj.2
                  (by 
                    simpa using hp0))))

theorem monic_mul_leading_coeff_inv (h : p ≠ 0) : monic (p*C (leading_coeff p⁻¹)) :=
  by 
    rw [monic, leading_coeff_mul, leading_coeff_C,
      mul_inv_cancel (show leading_coeff p ≠ 0 from mt leading_coeff_eq_zero.1 h)]

theorem degree_mul_leading_coeff_inv (p : Polynomial R) (h : q ≠ 0) : degree (p*C (leading_coeff q⁻¹)) = degree p :=
  have h₁ : leading_coeff q⁻¹ ≠ 0 := inv_ne_zero (mt leading_coeff_eq_zero.1 h)
  by 
    rw [degree_mul, degree_C h₁, add_zeroₓ]

-- error in Data.Polynomial.FieldDivision: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem irreducible_of_monic
{p : polynomial R}
(hp1 : p.monic)
(hp2 : «expr ≠ »(p, 1)) : «expr ↔ »(irreducible p, ∀
 f g : polynomial R, f.monic → g.monic → «expr = »(«expr * »(f, g), p) → «expr ∨ »(«expr = »(f, 1), «expr = »(g, 1))) :=
⟨λ
 hp3
 f
 g
 hf
 hg
 hfg, or.cases_on (hp3.is_unit_or_is_unit hfg.symm) (assume
  huf : is_unit f, «expr $ »(or.inl, eq_one_of_is_unit_of_monic hf huf)) (assume
  hug : is_unit g, «expr $ »(or.inr, eq_one_of_is_unit_of_monic hg hug)), λ
 hp3, ⟨mt (eq_one_of_is_unit_of_monic hp1) hp2, λ
  f
  g
  hp, have hf : «expr ≠ »(f, 0), from λ
  hf, by { rw ["[", expr hp, ",", expr hf, ",", expr zero_mul, "]"] ["at", ident hp1],
    exact [expr not_monic_zero hp1] },
  have hg : «expr ≠ »(g, 0), from λ hg, by { rw ["[", expr hp, ",", expr hg, ",", expr mul_zero, "]"] ["at", ident hp1],
    exact [expr not_monic_zero hp1] },
  «expr $ »(or.imp (λ
    hf, is_unit_of_mul_eq_one _ _ hf) (λ
    hg, is_unit_of_mul_eq_one _ _ hg), «expr $ »(hp3 «expr * »(f, C «expr ⁻¹»(f.leading_coeff)) «expr * »(g, C «expr ⁻¹»(g.leading_coeff)) (monic_mul_leading_coeff_inv hf) (monic_mul_leading_coeff_inv hg), by rw ["[", expr mul_assoc, ",", expr mul_left_comm _ g, ",", "<-", expr mul_assoc, ",", "<-", expr C_mul, ",", "<-", expr mul_inv₀, ",", "<-", expr leading_coeff_mul, ",", "<-", expr hp, ",", expr monic.def.1 hp1, ",", expr inv_one, ",", expr C_1, ",", expr mul_one, "]"] []))⟩⟩

/-- Division of polynomials. See polynomial.div_by_monic for more details.-/
def div (p q : Polynomial R) :=
  C (leading_coeff q⁻¹)*p /ₘ q*C (leading_coeff q⁻¹)

/-- Remainder of polynomial division, see the lemma `quotient_mul_add_remainder_eq_aux`.
See polynomial.mod_by_monic for more details. -/
def mod (p q : Polynomial R) :=
  p %ₘ q*C (leading_coeff q⁻¹)

private theorem quotient_mul_add_remainder_eq_aux (p q : Polynomial R) : ((q*div p q)+mod p q) = p :=
  if h : q = 0 then
    by 
      simp only [h, zero_mul, mod, mod_by_monic_zero, zero_addₓ]
  else
    by 
      conv  => toRHS rw [←mod_by_monic_add_div p (monic_mul_leading_coeff_inv h)]
      rw [div, mod, add_commₓ, mul_assocₓ]

private theorem remainder_lt_aux (p : Polynomial R) (hq : q ≠ 0) : degree (mod p q) < degree q :=
  by 
    rw [←degree_mul_leading_coeff_inv q hq] <;> exact degree_mod_by_monic_lt p (monic_mul_leading_coeff_inv hq)

instance  : Div (Polynomial R) :=
  ⟨div⟩

instance  : Mod (Polynomial R) :=
  ⟨mod⟩

theorem div_def : p / q = C (leading_coeff q⁻¹)*p /ₘ q*C (leading_coeff q⁻¹) :=
  rfl

theorem mod_def : p % q = p %ₘ q*C (leading_coeff q⁻¹) :=
  rfl

theorem mod_by_monic_eq_mod (p : Polynomial R) (hq : monic q) : p %ₘ q = p % q :=
  show p %ₘ q = p %ₘ q*C (leading_coeff q⁻¹)by 
    simp only [monic.def.1 hq, inv_one, mul_oneₓ, C_1]

theorem div_by_monic_eq_div (p : Polynomial R) (hq : monic q) : p /ₘ q = p / q :=
  show p /ₘ q = C (leading_coeff q⁻¹)*p /ₘ q*C (leading_coeff q⁻¹)by 
    simp only [monic.def.1 hq, inv_one, C_1, one_mulₓ, mul_oneₓ]

theorem mod_X_sub_C_eq_C_eval (p : Polynomial R) (a : R) : p % (X - C a) = C (p.eval a) :=
  mod_by_monic_eq_mod p (monic_X_sub_C a) ▸ mod_by_monic_X_sub_C_eq_C_eval _ _

theorem mul_div_eq_iff_is_root : ((X - C a)*p / (X - C a)) = p ↔ is_root p a :=
  div_by_monic_eq_div p (monic_X_sub_C a) ▸ mul_div_by_monic_eq_iff_is_root

instance  : EuclideanDomain (Polynomial R) :=
  { Polynomial.commRing, Polynomial.nontrivial with Quotient := · / ·,
    quotient_zero :=
      by 
        simp [div_def],
    remainder := · % ·, R := _, r_well_founded := degree_lt_wf,
    quotient_mul_add_remainder_eq := quotient_mul_add_remainder_eq_aux,
    remainder_lt := fun p q hq => remainder_lt_aux _ hq,
    mul_left_not_lt := fun p q hq => not_lt_of_geₓ (degree_le_mul_left _ hq) }

theorem mod_eq_self_iff (hq0 : q ≠ 0) : p % q = p ↔ degree p < degree q :=
  ⟨fun h => h ▸ EuclideanDomain.mod_lt _ hq0,
    fun h =>
      have  : ¬degree (q*C (leading_coeff q⁻¹)) ≤ degree p :=
        not_le_of_gtₓ$
          by 
            rwa [degree_mul_leading_coeff_inv q hq0]
      by 
        rw [mod_def, mod_by_monic, dif_pos (monic_mul_leading_coeff_inv hq0)]
        unfold div_mod_by_monic_aux 
        simp only [this, false_andₓ, if_false]⟩

-- error in Data.Polynomial.FieldDivision: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem div_eq_zero_iff
(hq0 : «expr ≠ »(q, 0)) : «expr ↔ »(«expr = »(«expr / »(p, q), 0), «expr < »(degree p, degree q)) :=
⟨λ
 h, by have [] [] [":=", expr euclidean_domain.div_add_mod p q]; rwa ["[", expr h, ",", expr mul_zero, ",", expr zero_add, ",", expr mod_eq_self_iff hq0, "]"] ["at", ident this], λ
 h, have hlt : «expr < »(degree p, degree «expr * »(q, C «expr ⁻¹»(leading_coeff q))), by rwa [expr degree_mul_leading_coeff_inv q hq0] [],
 have hm : monic «expr * »(q, C «expr ⁻¹»(leading_coeff q)) := monic_mul_leading_coeff_inv hq0,
 by rw ["[", expr div_def, ",", expr (div_by_monic_eq_zero_iff hm).2 hlt, ",", expr mul_zero, "]"] []⟩

theorem degree_add_div (hq0 : q ≠ 0) (hpq : degree q ≤ degree p) : (degree q+degree (p / q)) = degree p :=
  have  : degree (p % q) < degree (q*p / q) :=
    calc degree (p % q) < degree q := EuclideanDomain.mod_lt _ hq0 
      _ ≤ _ := degree_le_mul_left _ (mt (div_eq_zero_iff hq0).1 (not_lt_of_geₓ hpq))
      
  by 
    convRHS => rw [←EuclideanDomain.div_add_mod p q, degree_add_eq_left_of_degree_lt this, degree_mul]

theorem degree_div_le (p q : Polynomial R) : degree (p / q) ≤ degree p :=
  if hq : q = 0 then
    by 
      simp [hq]
  else
    by 
      rw [div_def, mul_commₓ, degree_mul_leading_coeff_inv _ hq] <;> exact degree_div_by_monic_le _ _

theorem degree_div_lt (hp : p ≠ 0) (hq : 0 < degree q) : degree (p / q) < degree p :=
  have hq0 : q ≠ 0 :=
    fun hq0 =>
      by 
        simpa [hq0] using hq 
  by 
    rw [div_def, mul_commₓ, degree_mul_leading_coeff_inv _ hq0] <;>
      exact
        degree_div_by_monic_lt _ (monic_mul_leading_coeff_inv hq0) hp
          (by 
            rw [degree_mul_leading_coeff_inv _ hq0] <;> exact hq)

@[simp]
theorem degree_map [Field k] (p : Polynomial R) (f : R →+* k) : degree (p.map f) = degree p :=
  p.degree_map_eq_of_injective f.injective

@[simp]
theorem nat_degree_map [Field k] (f : R →+* k) : nat_degree (p.map f) = nat_degree p :=
  nat_degree_eq_of_degree_eq (degree_map _ f)

@[simp]
theorem leading_coeff_map [Field k] (f : R →+* k) : leading_coeff (p.map f) = f (leading_coeff p) :=
  by 
    simp only [←coeff_nat_degree, coeff_map f, nat_degree_map]

theorem monic_map_iff [Field k] {f : R →+* k} {p : Polynomial R} : (p.map f).Monic ↔ p.monic :=
  by 
    rw [monic, leading_coeff_map, ←f.map_one, Function.Injective.eq_iff f.injective, monic]

theorem is_unit_map [Field k] (f : R →+* k) : IsUnit (p.map f) ↔ IsUnit p :=
  by 
    simpRw [is_unit_iff_degree_eq_zero, degree_map]

theorem map_div [Field k] (f : R →+* k) : (p / q).map f = p.map f / q.map f :=
  if hq0 : q = 0 then
    by 
      simp [hq0]
  else
    by 
      rw [div_def, div_def, map_mul, map_div_by_monic f (monic_mul_leading_coeff_inv hq0)] <;>
        simp [f.map_inv, coeff_map f]

theorem map_mod [Field k] (f : R →+* k) : (p % q).map f = p.map f % q.map f :=
  if hq0 : q = 0 then
    by 
      simp [hq0]
  else
    by 
      rw [mod_def, mod_def, leading_coeff_map f, ←f.map_inv, ←map_C f, ←map_mul f,
        map_mod_by_monic f (monic_mul_leading_coeff_inv hq0)]

section 

open EuclideanDomain

theorem gcd_map [Field k] (f : R →+* k) : gcd (p.map f) (q.map f) = (gcd p q).map f :=
  (gcd.induction p q
      fun x =>
        by 
          simpRw [map_zero, EuclideanDomain.gcd_zero_left])$
    fun x y hx ih =>
      by 
        rw [gcd_val, ←map_mod, ih, ←gcd_val]

end 

theorem eval₂_gcd_eq_zero [CommSemiringₓ k] {ϕ : R →+* k} {f g : Polynomial R} {α : k} (hf : f.eval₂ ϕ α = 0)
  (hg : g.eval₂ ϕ α = 0) : (EuclideanDomain.gcd f g).eval₂ ϕ α = 0 :=
  by 
    rw [EuclideanDomain.gcd_eq_gcd_ab f g, Polynomial.eval₂_add, Polynomial.eval₂_mul, Polynomial.eval₂_mul, hf, hg,
      zero_mul, zero_mul, zero_addₓ]

theorem eval_gcd_eq_zero {f g : Polynomial R} {α : R} (hf : f.eval α = 0) (hg : g.eval α = 0) :
  (EuclideanDomain.gcd f g).eval α = 0 :=
  eval₂_gcd_eq_zero hf hg

theorem root_left_of_root_gcd [CommSemiringₓ k] {ϕ : R →+* k} {f g : Polynomial R} {α : k}
  (hα : (EuclideanDomain.gcd f g).eval₂ ϕ α = 0) : f.eval₂ ϕ α = 0 :=
  by 
    cases' EuclideanDomain.gcd_dvd_left f g with p hp 
    rw [hp, Polynomial.eval₂_mul, hα, zero_mul]

theorem root_right_of_root_gcd [CommSemiringₓ k] {ϕ : R →+* k} {f g : Polynomial R} {α : k}
  (hα : (EuclideanDomain.gcd f g).eval₂ ϕ α = 0) : g.eval₂ ϕ α = 0 :=
  by 
    cases' EuclideanDomain.gcd_dvd_right f g with p hp 
    rw [hp, Polynomial.eval₂_mul, hα, zero_mul]

theorem root_gcd_iff_root_left_right [CommSemiringₓ k] {ϕ : R →+* k} {f g : Polynomial R} {α : k} :
  (EuclideanDomain.gcd f g).eval₂ ϕ α = 0 ↔ f.eval₂ ϕ α = 0 ∧ g.eval₂ ϕ α = 0 :=
  ⟨fun h => ⟨root_left_of_root_gcd h, root_right_of_root_gcd h⟩, fun h => eval₂_gcd_eq_zero h.1 h.2⟩

theorem is_root_gcd_iff_is_root_left_right {f g : Polynomial R} {α : R} :
  (EuclideanDomain.gcd f g).IsRoot α ↔ f.is_root α ∧ g.is_root α :=
  root_gcd_iff_root_left_right

theorem is_coprime_map [Field k] (f : R →+* k) : IsCoprime (p.map f) (q.map f) ↔ IsCoprime p q :=
  by 
    rw [←gcd_is_unit_iff, ←gcd_is_unit_iff, gcd_map, is_unit_map]

@[simp]
theorem map_eq_zero [Semiringₓ S] [Nontrivial S] (f : R →+* S) : p.map f = 0 ↔ p = 0 :=
  by 
    simp only [Polynomial.ext_iff, f.map_eq_zero, coeff_map, coeff_zero]

theorem map_ne_zero [Semiringₓ S] [Nontrivial S] {f : R →+* S} (hp : p ≠ 0) : p.map f ≠ 0 :=
  mt (map_eq_zero f).1 hp

theorem mem_roots_map [Field k] {f : R →+* k} {x : k} (hp : p ≠ 0) : x ∈ (p.map f).roots ↔ p.eval₂ f x = 0 :=
  by 
    rw
      [mem_roots
        (show p.map f ≠ 0 by 
          exact map_ne_zero hp)]
    dsimp only [is_root]
    rw [Polynomial.eval_map]

theorem mem_root_set [Field k] [Algebra R k] {x : k} (hp : p ≠ 0) : x ∈ p.root_set k ↔ aeval x p = 0 :=
  Iff.trans Multiset.mem_to_finset (mem_roots_map hp)

theorem root_set_C_mul_X_pow {R S : Type _} [Field R] [Field S] [Algebra R S] {n : ℕ} (hn : n ≠ 0) {a : R}
  (ha : a ≠ 0) : (C a*X ^ n).RootSet S = {0} :=
  by 
    ext x 
    rw [Set.mem_singleton_iff, mem_root_set, aeval_mul, aeval_C, aeval_X_pow, mul_eq_zero]
    ·
      simpRw [RingHom.map_eq_zero, pow_eq_zero_iff (Nat.pos_of_ne_zeroₓ hn), or_iff_right_iff_imp]
      exact fun ha' => (ha ha').elim
    ·
      exact mul_ne_zero (mt C_eq_zero.mp ha) (pow_ne_zero n X_ne_zero)

theorem root_set_monomial {R S : Type _} [Field R] [Field S] [Algebra R S] {n : ℕ} (hn : n ≠ 0) {a : R} (ha : a ≠ 0) :
  (monomial n a).RootSet S = {0} :=
  by 
    rw [←C_mul_X_pow_eq_monomial, root_set_C_mul_X_pow hn ha]

theorem root_set_X_pow {R S : Type _} [Field R] [Field S] [Algebra R S] {n : ℕ} (hn : n ≠ 0) :
  (X ^ n : Polynomial R).RootSet S = {0} :=
  by 
    rw [←one_mulₓ (X ^ n : Polynomial R), ←C_1, root_set_C_mul_X_pow hn]
    exact one_ne_zero

theorem exists_root_of_degree_eq_one (h : degree p = 1) : ∃ x, is_root p x :=
  ⟨-(p.coeff 0 / p.coeff 1),
    have  : p.coeff 1 ≠ 0 :=
      by 
        rw [←nat_degree_eq_of_degree_eq_some h] <;>
          exact
            mt leading_coeff_eq_zero.1
              fun h0 =>
                by 
                  simpa [h0] using h 
    by 
      conv  in p =>
          rw
            [eq_X_add_C_of_degree_le_one
              (show degree p ≤ 1by 
                rw [h] <;> exact le_reflₓ _)] <;>
        simp [is_root, mul_div_cancel' _ this]⟩

theorem coeff_inv_units (u : Units (Polynomial R)) (n : ℕ) :
  («expr↑ » u : Polynomial R).coeff n⁻¹ = («expr↑ » (u⁻¹) : Polynomial R).coeff n :=
  by 
    rw [eq_C_of_degree_eq_zero (degree_coe_units u), eq_C_of_degree_eq_zero (degree_coe_units (u⁻¹)), coeff_C, coeff_C,
      inv_eq_one_div]
    splitIfs
    ·
      rw [div_eq_iff_mul_eq (coeff_coe_units_zero_ne_zero u), coeff_zero_eq_eval_zero, coeff_zero_eq_eval_zero,
          ←eval_mul, ←Units.coe_mul, inv_mul_selfₓ] <;>
        simp 
    ·
      simp 

theorem monic_normalize (hp0 : p ≠ 0) : monic (normalize p) :=
  by 
    rw [Ne.def, ←leading_coeff_eq_zero, ←Ne.def, ←is_unit_iff_ne_zero] at hp0 
    rw [monic, leading_coeff_normalize, normalize_eq_one]
    apply hp0

theorem leading_coeff_div (hpq : q.degree ≤ p.degree) : (p / q).leadingCoeff = p.leading_coeff / q.leading_coeff :=
  by 
    byCases' hq : q = 0
    ·
      simp [hq]
    rw [div_def, leading_coeff_mul, leading_coeff_C,
      leading_coeff_div_by_monic_of_monic (monic_mul_leading_coeff_inv hq) _, mul_commₓ, div_eq_mul_inv]
    rwa [degree_mul_leading_coeff_inv q hq]

theorem div_C_mul : (p / C a*q) = C (a⁻¹)*p / q :=
  by 
    byCases' ha : a = 0
    ·
      simp [ha]
    simp only [div_def, leading_coeff_mul, mul_inv₀, leading_coeff_C, C.map_mul, mul_assocₓ]
    congr 3
    rw [mul_left_commₓ q, ←mul_assocₓ, ←C.map_mul, mul_inv_cancel ha, C.map_one, one_mulₓ]

theorem C_mul_dvd (ha : a ≠ 0) : (C a*p) ∣ q ↔ p ∣ q :=
  ⟨fun h => dvd_trans (dvd_mul_left _ _) h,
    fun ⟨r, hr⟩ =>
      ⟨C (a⁻¹)*r,
        by 
          rw [mul_assocₓ, mul_left_commₓ p, ←mul_assocₓ, ←C.map_mul, _root_.mul_inv_cancel ha, C.map_one, one_mulₓ,
            hr]⟩⟩

theorem dvd_C_mul (ha : a ≠ 0) : (p ∣ Polynomial.c a*q) ↔ p ∣ q :=
  ⟨fun ⟨r, hr⟩ =>
      ⟨C (a⁻¹)*r,
        by 
          rw [mul_left_commₓ p, ←hr, ←mul_assocₓ, ←C.map_mul, _root_.inv_mul_cancel ha, C.map_one, one_mulₓ]⟩,
    fun h => dvd_trans h (dvd_mul_left _ _)⟩

theorem coe_norm_unit_of_ne_zero (hp : p ≠ 0) : (norm_unit p : Polynomial R) = C (p.leading_coeff⁻¹) :=
  have  : p.leading_coeff ≠ 0 := mt leading_coeff_eq_zero.mp hp 
  by 
    simp [CommGroupWithZero.coe_norm_unit _ this]

theorem normalize_monic (h : monic p) : normalize p = p :=
  by 
    simp [h]

theorem map_dvd_map' [Field k] (f : R →+* k) {x y : Polynomial R} : x.map f ∣ y.map f ↔ x ∣ y :=
  if H : x = 0 then
    by 
      rw [H, map_zero, zero_dvd_iff, zero_dvd_iff, map_eq_zero]
  else
    by 
      rw [←normalize_dvd_iff, ←@normalize_dvd_iff (Polynomial R), normalize_apply, normalize_apply,
        coe_norm_unit_of_ne_zero H, coe_norm_unit_of_ne_zero (mt (map_eq_zero f).1 H), leading_coeff_map, ←f.map_inv,
        ←map_C, ←map_mul, map_dvd_map _ f.injective (monic_mul_leading_coeff_inv H)]

theorem degree_normalize : degree (normalize p) = degree p :=
  by 
    simp 

theorem prime_of_degree_eq_one (hp1 : degree p = 1) : Prime p :=
  have  : Prime (normalize p) :=
    monic.prime_of_degree_eq_one (hp1 ▸ degree_normalize)
      (monic_normalize
        fun hp0 =>
          absurd hp1
            (hp0.symm ▸
              by 
                simp  <;>
                  exact
                    by 
                      decide))
  (normalize_associated _).Prime this

theorem irreducible_of_degree_eq_one (hp1 : degree p = 1) : Irreducible p :=
  (prime_of_degree_eq_one hp1).Irreducible

theorem not_irreducible_C (x : R) : ¬Irreducible (C x) :=
  if H : x = 0 then
    by 
      rw [H, C_0]
      exact not_irreducible_zero
  else fun hx => Irreducible.not_unit hx$ is_unit_C.2$ is_unit_iff_ne_zero.2 H

theorem degree_pos_of_irreducible (hp : Irreducible p) : 0 < p.degree :=
  lt_of_not_geₓ$
    fun hp0 =>
      have  := eq_C_of_degree_le_zero hp0 
      not_irreducible_C (p.coeff 0)$ this ▸ hp

-- error in Data.Polynomial.FieldDivision: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem pairwise_coprime_X_sub
{α : Type u}
[field α]
{I : Type v}
{s : I → α}
(H : function.injective s) : pairwise «expr on »(is_coprime, λ i : I, «expr - »(polynomial.X, polynomial.C (s i))) :=
λ
i
j
hij, have h : «expr ≠ »(«expr - »(s j, s i), 0), from «expr $ »(sub_ne_zero_of_ne, function.injective.ne H hij.symm),
⟨polynomial.C «expr ⁻¹»(«expr - »(s j, s i)), «expr- »(polynomial.C «expr ⁻¹»(«expr - »(s j, s i))), by rw ["[", expr neg_mul_eq_neg_mul_symm, ",", "<-", expr sub_eq_add_neg, ",", "<-", expr mul_sub, ",", expr sub_sub_sub_cancel_left, ",", "<-", expr polynomial.C_sub, ",", "<-", expr polynomial.C_mul, ",", expr inv_mul_cancel h, ",", expr polynomial.C_1, "]"] []⟩

-- error in Data.Polynomial.FieldDivision: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `f` is a polynomial over a field, and `a : K` satisfies `f' a ≠ 0`,
then `f / (X - a)` is coprime with `X - a`.
Note that we do not assume `f a = 0`, because `f / (X - a) = (f - f a) / (X - a)`. -/
theorem is_coprime_of_is_root_of_eval_derivative_ne_zero
{K : Type*}
[field K]
(f : polynomial K)
(a : K)
(hf' : «expr ≠ »(f.derivative.eval a, 0)) : is_coprime («expr - »(X, C a) : polynomial K) «expr /ₘ »(f, «expr - »(X, C a)) :=
begin
  refine [expr or.resolve_left (dvd_or_coprime «expr - »(X, C a) «expr /ₘ »(f, «expr - »(X, C a)) (irreducible_of_degree_eq_one (polynomial.degree_X_sub_C a))) _],
  contrapose ["!"] [ident hf', "with", ident h],
  have [ident key] [":", expr «expr = »(«expr * »(«expr - »(X, C a), «expr /ₘ »(f, «expr - »(X, C a))), «expr - »(f, «expr %ₘ »(f, «expr - »(X, C a))))] [],
  { rw ["[", expr eq_sub_iff_add_eq, ",", "<-", expr eq_sub_iff_add_eq', ",", expr mod_by_monic_eq_sub_mul_div, "]"] [],
    exact [expr monic_X_sub_C a] },
  replace [ident key] [] [":=", expr congr_arg derivative key],
  simp [] [] ["only"] ["[", expr derivative_X, ",", expr derivative_mul, ",", expr one_mul, ",", expr sub_zero, ",", expr derivative_sub, ",", expr mod_by_monic_X_sub_C_eq_C_eval, ",", expr derivative_C, "]"] [] ["at", ident key],
  have [] [":", expr «expr ∣ »(«expr - »(X, C a), derivative f)] [":=", expr «expr ▸ »(key, dvd_add h (dvd_mul_right _ _))],
  rw ["[", "<-", expr dvd_iff_mod_by_monic_eq_zero (monic_X_sub_C _), ",", expr mod_by_monic_X_sub_C_eq_C_eval, "]"] ["at", ident this],
  rw ["[", "<-", expr C_inj, ",", expr this, ",", expr C_0, "]"] []
end

-- error in Data.Polynomial.FieldDivision: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem prod_multiset_root_eq_finset_root
{p : polynomial R}
(hzero : «expr ≠ »(p, 0)) : «expr = »((multiset.map (λ
   a : R, «expr - »(X, C a)) p.roots).prod, «expr∏ in , »((a), multiset.to_finset p.roots, λ
  a : R, «expr ^ »(«expr - »(X, C a), root_multiplicity a p) a)) :=
by simp [] [] ["only"] ["[", expr count_roots hzero, ",", expr finset.prod_multiset_map_count, "]"] [] []

-- error in Data.Polynomial.FieldDivision: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The product `∏ (X - a)` for `a` inside the multiset `p.roots` divides `p`. -/
theorem prod_multiset_X_sub_C_dvd
(p : polynomial R) : «expr ∣ »((multiset.map (λ a : R, «expr - »(X, C a)) p.roots).prod, p) :=
begin
  by_cases [expr hp0, ":", expr «expr = »(p, 0)],
  { simp [] [] ["only"] ["[", expr hp0, ",", expr roots_zero, ",", expr is_unit_one, ",", expr multiset.prod_zero, ",", expr multiset.map_zero, ",", expr is_unit.dvd, "]"] [] [] },
  rw [expr prod_multiset_root_eq_finset_root hp0] [],
  have [ident hcoprime] [":", expr pairwise «expr on »(is_coprime, λ
    a : R, «expr - »(polynomial.X, C (id a)))] [":=", expr pairwise_coprime_X_sub function.injective_id],
  have [ident H] [":", expr pairwise «expr on »(is_coprime, λ
    a : R, «expr ^ »(«expr - »(polynomial.X, C (id a)), root_multiplicity a p))] [],
  { intros [ident a, ident b, ident hdiff],
    exact [expr (hcoprime a b hdiff).pow] },
  apply [expr finset.prod_dvd_of_coprime (H.set_pairwise («expr↑ »(multiset.to_finset p.roots) : set R))],
  intros [ident a, ident h],
  rw [expr multiset.mem_to_finset] ["at", ident h],
  exact [expr pow_root_multiplicity_dvd p a]
end

-- error in Data.Polynomial.FieldDivision: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem roots_C_mul
(p : polynomial R)
{a : R}
(hzero : «expr ≠ »(a, 0)) : «expr = »(«expr * »(C a, p).roots, p.roots) :=
begin
  by_cases [expr hpzero, ":", expr «expr = »(p, 0)],
  { simp [] [] ["only"] ["[", expr hpzero, ",", expr mul_zero, "]"] [] [] },
  rw [expr multiset.ext] [],
  intro [ident b],
  have [ident prodzero] [":", expr «expr ≠ »(«expr * »(C a, p), 0)] [],
  { simp [] [] ["only"] ["[", expr hpzero, ",", expr or_false, ",", expr ne.def, ",", expr mul_eq_zero, ",", expr C_eq_zero, ",", expr hzero, ",", expr not_false_iff, "]"] [] [] },
  rw ["[", expr count_roots hpzero, ",", expr count_roots prodzero, ",", expr root_multiplicity_mul prodzero, "]"] [],
  have [ident mulzero] [":", expr «expr = »(root_multiplicity b (C a), 0)] [],
  { simp [] [] ["only"] ["[", expr hzero, ",", expr root_multiplicity_eq_zero, ",", expr eval_C, ",", expr is_root.def, ",", expr not_false_iff, "]"] [] [] },
  simp [] [] ["only"] ["[", expr mulzero, ",", expr zero_add, "]"] [] []
end

-- error in Data.Polynomial.FieldDivision: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem roots_normalize : «expr = »((normalize p).roots, p.roots) :=
begin
  by_cases [expr hzero, ":", expr «expr = »(p, 0)],
  { rw ["[", expr hzero, ",", expr normalize_zero, "]"] [] },
  { have [ident hcoeff] [":", expr «expr ≠ »(p.leading_coeff, 0)] [],
    { intro [ident h],
      exact [expr hzero (leading_coeff_eq_zero.1 h)] },
    rw ["[", expr normalize_apply, ",", expr mul_comm, ",", expr coe_norm_unit_of_ne_zero hzero, ",", expr roots_C_mul _ (inv_ne_zero hcoeff), "]"] [] }
end

end Field

end Polynomial

