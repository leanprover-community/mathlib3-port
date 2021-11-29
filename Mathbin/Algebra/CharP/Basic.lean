import Mathbin.Data.Int.Modeq 
import Mathbin.Algebra.IterateHom 
import Mathbin.Data.Nat.Choose.Sum 
import Mathbin.GroupTheory.OrderOfElement 
import Mathbin.Data.Nat.Choose.Dvd

/-!
# Characteristic of semirings
-/


universe u v

variable(R : Type u)

/-- The generator of the kernel of the unique homomorphism ℕ → R for a semiring R -/
class CharP[AddMonoidₓ R][HasOne R](p : ℕ) : Prop where 
  cast_eq_zero_iff{} : ∀ (x : ℕ), (x : R) = 0 ↔ p ∣ x

theorem CharP.cast_eq_zero [AddMonoidₓ R] [HasOne R] (p : ℕ) [CharP R p] : (p : R) = 0 :=
  (CharP.cast_eq_zero_iff R p p).2 (dvd_refl p)

@[simp]
theorem CharP.cast_card_eq_zero [AddGroupₓ R] [HasOne R] [Fintype R] : (Fintype.card R : R) = 0 :=
  by 
    rw [←nsmul_one, card_nsmul_eq_zero]

theorem CharP.int_cast_eq_zero_iff [AddGroupₓ R] [HasOne R] (p : ℕ) [CharP R p] (a : ℤ) : (a : R) = 0 ↔ (p : ℤ) ∣ a :=
  by 
    rcases lt_trichotomyₓ a 0 with (h | rfl | h)
    ·
      rw [←neg_eq_zero, ←Int.cast_neg, ←dvd_neg]
      lift -a to ℕ using neg_nonneg.mpr (le_of_ltₓ h) with b 
      rw [Int.cast_coe_nat, CharP.cast_eq_zero_iff R p, Int.coe_nat_dvd]
    ·
      simp only [Int.cast_zero, eq_self_iff_true, dvd_zero]
    ·
      lift a to ℕ using le_of_ltₓ h with b 
      rw [Int.cast_coe_nat, CharP.cast_eq_zero_iff R p, Int.coe_nat_dvd]

theorem CharP.int_coe_eq_int_coe_iff [AddGroupₓ R] [HasOne R] (p : ℕ) [CharP R p] (a b : ℤ) :
  (a : R) = (b : R) ↔ a ≡ b [ZMOD p] :=
  by 
    rw [eq_comm, ←sub_eq_zero, ←Int.cast_sub, CharP.int_cast_eq_zero_iff R p, Int.modeq_iff_dvd]

theorem CharP.eq [AddMonoidₓ R] [HasOne R] {p q : ℕ} (c1 : CharP R p) (c2 : CharP R q) : p = q :=
  Nat.dvd_antisymm ((CharP.cast_eq_zero_iff R p q).1 (CharP.cast_eq_zero _ _))
    ((CharP.cast_eq_zero_iff R q p).1 (CharP.cast_eq_zero _ _))

instance CharP.of_char_zero [AddMonoidₓ R] [HasOne R] [CharZero R] : CharP R 0 :=
  ⟨fun x =>
      by 
        rw [zero_dvd_iff, ←Nat.cast_zero, Nat.cast_inj]⟩

-- error in Algebra.CharP.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem char_p.exists [non_assoc_semiring R] : «expr∃ , »((p), char_p R p) :=
by letI [] [] [":=", expr classical.dec_eq R]; exact [expr classical.by_cases (assume
  H : ∀
  p : exprℕ(), «expr = »((p : R), 0) → «expr = »(p, 0), ⟨0, ⟨λ
    x, by rw ["[", expr zero_dvd_iff, "]"] []; exact [expr ⟨H x, by rintro [ident rfl]; refl⟩]⟩⟩) (λ
  H, ⟨nat.find (not_forall.1 H), ⟨λ
    x, ⟨λ
     H1, nat.dvd_of_mod_eq_zero «expr $ »(by_contradiction, λ
      H2, nat.find_min (not_forall.1 H) «expr $ »(nat.mod_lt x, «expr $ »(nat.pos_of_ne_zero, «expr $ »(not_of_not_imp, nat.find_spec (not_forall.1 H)))) (not_imp_of_and_not ⟨by rwa ["[", "<-", expr nat.mod_add_div x (nat.find (not_forall.1 H)), ",", expr nat.cast_add, ",", expr nat.cast_mul, ",", expr of_not_not «expr $ »(not_not_of_not_imp, nat.find_spec (not_forall.1 H)), ",", expr zero_mul, ",", expr add_zero, "]"] ["at", ident H1], H2⟩)), λ
     H1, by rw ["[", "<-", expr nat.mul_div_cancel' H1, ",", expr nat.cast_mul, ",", expr of_not_not «expr $ »(not_not_of_not_imp, nat.find_spec (not_forall.1 H)), ",", expr zero_mul, "]"] []⟩⟩⟩)]

theorem CharP.exists_unique [NonAssocSemiring R] : ∃!p, CharP R p :=
  let ⟨c, H⟩ := CharP.exists R
  ⟨c, H, fun y H2 => CharP.eq R H2 H⟩

theorem CharP.congr {R : Type u} [AddMonoidₓ R] [HasOne R] {p : ℕ} (q : ℕ) [hq : CharP R q] (h : q = p) : CharP R p :=
  h ▸ hq

/-- Noncomputable function that outputs the unique characteristic of a semiring. -/
noncomputable def ringChar [NonAssocSemiring R] : ℕ :=
  Classical.some (CharP.exists_unique R)

namespace ringChar

variable[NonAssocSemiring R]

-- error in Algebra.CharP.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem spec : ∀ x : exprℕ(), «expr ↔ »(«expr = »((x : R), 0), «expr ∣ »(ring_char R, x)) :=
by letI [] [] [":=", expr (classical.some_spec (char_p.exists_unique R)).1]; unfold [ident ring_char] []; exact [expr char_p.cast_eq_zero_iff R (ring_char R)]

theorem Eq {p : ℕ} (C : CharP R p) : p = ringChar R :=
  (Classical.some_spec (CharP.exists_unique R)).2 p C

instance CharP : CharP R (ringChar R) :=
  ⟨spec R⟩

variable{R}

theorem of_eq {p : ℕ} (h : ringChar R = p) : CharP R p :=
  CharP.congr (ringChar R) h

theorem eq_iff {p : ℕ} : ringChar R = p ↔ CharP R p :=
  ⟨of_eq, Eq.symm ∘ Eq R⟩

theorem dvd {x : ℕ} (hx : (x : R) = 0) : ringChar R ∣ x :=
  (spec R x).1 hx

@[simp]
theorem eq_zero [CharZero R] : ringChar R = 0 :=
  (Eq R (CharP.of_char_zero R)).symm

end ringChar

theorem add_pow_char_of_commute [Semiringₓ R] {p : ℕ} [Fact p.prime] [CharP R p] (x y : R) (h : Commute x y) :
  (x+y) ^ p = (x ^ p)+y ^ p :=
  by 
    rw [Commute.add_pow h, Finset.sum_range_succ_comm, tsub_self, pow_zeroₓ, Nat.choose_self]
    rw [Nat.cast_one, mul_oneₓ, mul_oneₓ]
    congr 1
    convert Finset.sum_eq_single 0 _ _
    ·
      simp only [mul_oneₓ, one_mulₓ, Nat.choose_zero_right, tsub_zero, Nat.cast_one, pow_zeroₓ]
    ·
      intro b h1 h2 
      suffices  : (p.choose b : R) = 0
      ·
        rw [this]
        simp 
      rw [CharP.cast_eq_zero_iff R p]
      refine' Nat.Prime.dvd_choose_self (pos_iff_ne_zero.mpr h2) _ (Fact.out _)
      rwa [←Finset.mem_range]
    ·
      intro h1 
      contrapose! h1 
      rw [Finset.mem_range]
      exact Nat.Prime.pos (Fact.out _)

theorem add_pow_char_pow_of_commute [Semiringₓ R] {p : ℕ} [Fact p.prime] [CharP R p] {n : ℕ} (x y : R)
  (h : Commute x y) : (x+y) ^ p ^ n = (x ^ p ^ n)+y ^ p ^ n :=
  by 
    induction n
    ·
      simp 
    rw [pow_succ'ₓ, pow_mulₓ, pow_mulₓ, pow_mulₓ, n_ih]
    apply add_pow_char_of_commute 
    apply Commute.pow_pow h

theorem sub_pow_char_of_commute [Ringₓ R] {p : ℕ} [Fact p.prime] [CharP R p] (x y : R) (h : Commute x y) :
  (x - y) ^ p = x ^ p - y ^ p :=
  by 
    rw [eq_sub_iff_add_eq, ←add_pow_char_of_commute _ _ _ (Commute.sub_left h rfl)]
    simp 
    repeat' 
      infer_instance

theorem sub_pow_char_pow_of_commute [Ringₓ R] {p : ℕ} [Fact p.prime] [CharP R p] {n : ℕ} (x y : R) (h : Commute x y) :
  (x - y) ^ p ^ n = x ^ p ^ n - y ^ p ^ n :=
  by 
    induction n
    ·
      simp 
    rw [pow_succ'ₓ, pow_mulₓ, pow_mulₓ, pow_mulₓ, n_ih]
    apply sub_pow_char_of_commute 
    apply Commute.pow_pow h

theorem add_pow_char [CommSemiringₓ R] {p : ℕ} [Fact p.prime] [CharP R p] (x y : R) : (x+y) ^ p = (x ^ p)+y ^ p :=
  add_pow_char_of_commute _ _ _ (Commute.all _ _)

theorem add_pow_char_pow [CommSemiringₓ R] {p : ℕ} [Fact p.prime] [CharP R p] {n : ℕ} (x y : R) :
  (x+y) ^ p ^ n = (x ^ p ^ n)+y ^ p ^ n :=
  add_pow_char_pow_of_commute _ _ _ (Commute.all _ _)

theorem sub_pow_char [CommRingₓ R] {p : ℕ} [Fact p.prime] [CharP R p] (x y : R) : (x - y) ^ p = x ^ p - y ^ p :=
  sub_pow_char_of_commute _ _ _ (Commute.all _ _)

theorem sub_pow_char_pow [CommRingₓ R] {p : ℕ} [Fact p.prime] [CharP R p] {n : ℕ} (x y : R) :
  (x - y) ^ p ^ n = x ^ p ^ n - y ^ p ^ n :=
  sub_pow_char_pow_of_commute _ _ _ (Commute.all _ _)

theorem eq_iff_modeq_int [Ringₓ R] (p : ℕ) [CharP R p] (a b : ℤ) : (a : R) = b ↔ a ≡ b [ZMOD p] :=
  by 
    rw [eq_comm, ←sub_eq_zero, ←Int.cast_sub, CharP.int_cast_eq_zero_iff R p, Int.modeq_iff_dvd]

-- error in Algebra.CharP.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem char_p.neg_one_ne_one
[ring R]
(p : exprℕ())
[char_p R p]
[fact «expr < »(2, p)] : «expr ≠ »((«expr- »(1) : R), (1 : R)) :=
begin
  suffices [] [":", expr «expr ≠ »((2 : R), 0)],
  { symmetry,
    rw ["[", expr ne.def, ",", "<-", expr sub_eq_zero, ",", expr sub_neg_eq_add, "]"] [],
    exact [expr this] },
  assume [binders (h)],
  rw ["[", expr show «expr = »((2 : R), (2 : exprℕ())), by norm_cast [], "]"] ["at", ident h],
  have [] [] [":=", expr (char_p.cast_eq_zero_iff R p 2).mp h],
  have [] [] [":=", expr nat.le_of_dvd exprdec_trivial() this],
  rw [expr fact_iff] ["at", "*"],
  linarith [] [] []
end

theorem CharP.neg_one_pow_char [CommRingₓ R] (p : ℕ) [CharP R p] [Fact p.prime] : (-1 : R) ^ p = -1 :=
  by 
    rw [eq_neg_iff_add_eq_zero]
    nthRw 1[←one_pow p]
    rw [←add_pow_char, add_left_negₓ, zero_pow (Fact.out (Nat.Prime p)).Pos]

theorem CharP.neg_one_pow_char_pow [CommRingₓ R] (p n : ℕ) [CharP R p] [Fact p.prime] : (-1 : R) ^ p ^ n = -1 :=
  by 
    rw [eq_neg_iff_add_eq_zero]
    nthRw 1[←one_pow (p ^ n)]
    rw [←add_pow_char_pow, add_left_negₓ, zero_pow (pow_pos (Fact.out (Nat.Prime p)).Pos _)]

theorem RingHom.char_p_iff_char_p {K L : Type _} [DivisionRing K] [Semiringₓ L] [Nontrivial L] (f : K →+* L) (p : ℕ) :
  CharP K p ↔ CharP L p :=
  by 
    split  <;>
      ·
        intro _c 
        constructor 
        intro n 
        rw [←@CharP.cast_eq_zero_iff _ _ _ p _c n, ←f.injective.eq_iff, f.map_nat_cast, f.map_zero]

section frobenius

section CommSemiringₓ

variable[CommSemiringₓ
      R]{S : Type v}[CommSemiringₓ S](f : R →* S)(g : R →+* S)(p : ℕ)[Fact p.prime][CharP R p][CharP S p](x y : R)

/-- The frobenius map that sends x to x^p -/
def frobenius : R →+* R :=
  { toFun := fun x => x ^ p, map_one' := one_pow p, map_mul' := fun x y => mul_powₓ x y p,
    map_zero' := zero_pow (Fact.out (Nat.Prime p)).Pos, map_add' := add_pow_char R }

variable{R}

theorem frobenius_def : frobenius R p x = x ^ p :=
  rfl

theorem iterate_frobenius (n : ℕ) : (frobenius R p^[n]) x = x ^ p ^ n :=
  by 
    induction n
    ·
      simp 
    rw [Function.iterate_succ', pow_succ'ₓ, pow_mulₓ, Function.comp_apply, frobenius_def, n_ih]

theorem frobenius_mul : frobenius R p (x*y) = frobenius R p x*frobenius R p y :=
  (frobenius R p).map_mul x y

theorem frobenius_one : frobenius R p 1 = 1 :=
  one_pow _

theorem MonoidHom.map_frobenius : f (frobenius R p x) = frobenius S p (f x) :=
  f.map_pow x p

theorem RingHom.map_frobenius : g (frobenius R p x) = frobenius S p (g x) :=
  g.map_pow x p

theorem MonoidHom.map_iterate_frobenius (n : ℕ) : f ((frobenius R p^[n]) x) = (frobenius S p^[n]) (f x) :=
  Function.Semiconj.iterate_right (f.map_frobenius p) n x

theorem RingHom.map_iterate_frobenius (n : ℕ) : g ((frobenius R p^[n]) x) = (frobenius S p^[n]) (g x) :=
  g.to_monoid_hom.map_iterate_frobenius p x n

theorem MonoidHom.iterate_map_frobenius (f : R →* R) (p : ℕ) [Fact p.prime] [CharP R p] (n : ℕ) :
  (f^[n]) (frobenius R p x) = frobenius R p ((f^[n]) x) :=
  f.iterate_map_pow _ _ _

theorem RingHom.iterate_map_frobenius (f : R →+* R) (p : ℕ) [Fact p.prime] [CharP R p] (n : ℕ) :
  (f^[n]) (frobenius R p x) = frobenius R p ((f^[n]) x) :=
  f.iterate_map_pow _ _ _

variable(R)

theorem frobenius_zero : frobenius R p 0 = 0 :=
  (frobenius R p).map_zero

theorem frobenius_add : frobenius R p (x+y) = frobenius R p x+frobenius R p y :=
  (frobenius R p).map_add x y

theorem frobenius_nat_cast (n : ℕ) : frobenius R p n = n :=
  (frobenius R p).map_nat_cast n

end CommSemiringₓ

section CommRingₓ

variable[CommRingₓ
      R]{S : Type v}[CommRingₓ S](f : R →* S)(g : R →+* S)(p : ℕ)[Fact p.prime][CharP R p][CharP S p](x y : R)

theorem frobenius_neg : frobenius R p (-x) = -frobenius R p x :=
  (frobenius R p).map_neg x

theorem frobenius_sub : frobenius R p (x - y) = frobenius R p x - frobenius R p y :=
  (frobenius R p).map_sub x y

end CommRingₓ

end frobenius

theorem frobenius_inj [CommRingₓ R] [NoZeroDivisors R] (p : ℕ) [Fact p.prime] [CharP R p] :
  Function.Injective (frobenius R p) :=
  fun x h H =>
    by 
      rw [←sub_eq_zero] at H⊢
      rw [←frobenius_sub] at H 
      exact pow_eq_zero H

namespace CharP

section 

variable[Ringₓ R]

theorem char_p_to_char_zero [CharP R 0] : CharZero R :=
  char_zero_of_inj_zero$ fun n h0 => eq_zero_of_zero_dvd ((cast_eq_zero_iff R 0 n).mp h0)

theorem cast_eq_mod (p : ℕ) [CharP R p] (k : ℕ) : (k : R) = (k % p : ℕ) :=
  calc (k : R) = «expr↑ » ((k % p)+p*k / p) :=
    by 
      rw [Nat.mod_add_divₓ]
    _ = «expr↑ » (k % p) :=
    by 
      simp [cast_eq_zero]
    

-- error in Algebra.CharP.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem char_ne_zero_of_fintype (p : exprℕ()) [hc : char_p R p] [fintype R] : «expr ≠ »(p, 0) :=
assume h : «expr = »(p, 0), have char_zero R := @char_p_to_char_zero R _ «expr ▸ »(h, hc),
absurd (@nat.cast_injective R _ _ this) (not_injective_infinite_fintype coe)

end 

section Semiringₓ

open Nat

variable[NonAssocSemiring R]

-- error in Algebra.CharP.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem char_ne_one [nontrivial R] (p : exprℕ()) [hc : char_p R p] : «expr ≠ »(p, 1) :=
assume
hp : «expr = »(p, 1), have «expr = »((1 : R), 0), by simpa [] [] [] [] [] ["using", expr (cast_eq_zero_iff R p 1).mpr «expr ▸ »(hp, dvd_refl p)],
absurd this one_ne_zero

section NoZeroDivisors

variable[NoZeroDivisors R]

-- error in Algebra.CharP.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem char_is_prime_of_two_le (p : exprℕ()) [hc : char_p R p] (hp : «expr ≤ »(2, p)) : nat.prime p :=
suffices ∀ d «expr ∣ » p, «expr ∨ »(«expr = »(d, 1), «expr = »(d, p)), from ⟨hp, this⟩,
assume (d : exprℕ()) (hdvd : «expr∃ , »((e), «expr = »(p, «expr * »(d, e)))), let ⟨e, hmul⟩ := hdvd in
have «expr = »((p : R), 0), from (cast_eq_zero_iff R p p).mpr (dvd_refl p),
have «expr = »(«expr * »((d : R), e), 0), from «expr ▸ »(@cast_mul R _ d e, «expr ▸ »(hmul, this)),
or.elim (eq_zero_or_eq_zero_of_mul_eq_zero this) (assume
 hd : «expr = »((d : R), 0), have «expr ∣ »(p, d), from (cast_eq_zero_iff R p d).mp hd,
 show «expr ∨ »(«expr = »(d, 1), «expr = »(d, p)), from or.inr (dvd_antisymm ⟨e, hmul⟩ this)) (assume
 he : «expr = »((e : R), 0), have «expr ∣ »(p, e), from (cast_eq_zero_iff R p e).mp he,
 have «expr ∣ »(e, p), from dvd_of_mul_left_eq d (eq.symm hmul),
 have «expr = »(e, p), from dvd_antisymm «expr‹ ›»(«expr ∣ »(e, p)) «expr‹ ›»(«expr ∣ »(p, e)),
 have h₀ : «expr > »(p, 0), from gt_of_ge_of_gt hp (nat.zero_lt_succ 1),
 have «expr = »(«expr * »(d, p), «expr * »(1, p)), by rw [expr «expr‹ ›»(«expr = »(e, p))] ["at", ident hmul]; rw ["[", expr one_mul, "]"] []; exact [expr eq.symm hmul],
 show «expr ∨ »(«expr = »(d, 1), «expr = »(d, p)), from or.inl (eq_of_mul_eq_mul_right h₀ this))

section Nontrivial

variable[Nontrivial R]

theorem char_is_prime_or_zero (p : ℕ) [hc : CharP R p] : Nat.Prime p ∨ p = 0 :=
  match p, hc with 
  | 0, _ => Or.inr rfl
  | 1, hc => absurd (Eq.refl (1 : ℕ)) (@char_ne_one R _ _ (1 : ℕ) hc)
  | m+2, hc => Or.inl (@char_is_prime_of_two_le R _ _ (m+2) hc (Nat.le_add_leftₓ 2 m))

theorem char_is_prime_of_pos (p : ℕ) [h : Fact (0 < p)] [CharP R p] : Fact p.prime :=
  ⟨(CharP.char_is_prime_or_zero R _).resolve_right (pos_iff_ne_zero.1 h.1)⟩

end Nontrivial

end NoZeroDivisors

end Semiringₓ

section Ringₓ

variable(R)[Ringₓ R][NoZeroDivisors R][Nontrivial R][Fintype R]

theorem char_is_prime (p : ℕ) [CharP R p] : p.prime :=
  Or.resolve_right (char_is_prime_or_zero R p) (char_ne_zero_of_fintype R p)

end Ringₓ

section CharOne

variable{R}[NonAssocSemiring R]

instance (priority := 100) [CharP R 1] : Subsingleton R :=
  Subsingleton.intro$
    suffices ∀ (r : R), r = 0 from
      fun a b =>
        show a = b by 
          rw [this a, this b]
    fun r =>
      calc r = 1*r :=
        by 
          rw [one_mulₓ]
        _ = (1 : ℕ)*r :=
        by 
          rw [Nat.cast_one]
        _ = 0*r :=
        by 
          rw [CharP.cast_eq_zero]
        _ = 0 :=
        by 
          rw [zero_mul]
        

theorem false_of_nontrivial_of_char_one [Nontrivial R] [CharP R 1] : False :=
  false_of_nontrivial_of_subsingleton R

theorem ring_char_ne_one [Nontrivial R] : ringChar R ≠ 1 :=
  by 
    intro h 
    apply @zero_ne_one R 
    symm 
    rw [←Nat.cast_one, ringChar.spec, h]

theorem nontrivial_of_char_ne_one {v : ℕ} (hv : v ≠ 1) [hr : CharP R v] : Nontrivial R :=
  ⟨⟨(1 : ℕ), 0,
      fun h =>
        hv$
          by 
            rwa [CharP.cast_eq_zero_iff _ v, Nat.dvd_one] at h <;> assumption⟩⟩

end CharOne

end CharP

section 

variable(R)[CommRingₓ R][Fintype R](n : ℕ)

-- error in Algebra.CharP.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem char_p_of_ne_zero
(hn : «expr = »(fintype.card R, n))
(hR : ∀ i «expr < » n, «expr = »((i : R), 0) → «expr = »(i, 0)) : char_p R n :=
{ cast_eq_zero_iff := begin
    have [ident H] [":", expr «expr = »((n : R), 0)] [],
    by { rw ["[", "<-", expr hn, ",", expr char_p.cast_card_eq_zero, "]"] [] },
    intro [ident k],
    split,
    { intro [ident h],
      rw ["[", "<-", expr nat.mod_add_div k n, ",", expr nat.cast_add, ",", expr nat.cast_mul, ",", expr H, ",", expr zero_mul, ",", expr add_zero, "]"] ["at", ident h],
      rw [expr nat.dvd_iff_mod_eq_zero] [],
      apply [expr hR _ (nat.mod_lt _ _) h],
      rw ["[", "<-", expr hn, ",", expr fintype.card_pos_iff, "]"] [],
      exact [expr ⟨0⟩] },
    { rintro ["⟨", ident k, ",", ident rfl, "⟩"],
      rw ["[", expr nat.cast_mul, ",", expr H, ",", expr zero_mul, "]"] [] }
  end }

-- error in Algebra.CharP.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem char_p_of_prime_pow_injective
(p : exprℕ())
[hp : fact p.prime]
(n : exprℕ())
(hn : «expr = »(fintype.card R, «expr ^ »(p, n)))
(hR : ∀ i «expr ≤ » n, «expr = »((«expr ^ »(p, i) : R), 0) → «expr = »(i, n)) : char_p R «expr ^ »(p, n) :=
begin
  obtain ["⟨", ident c, ",", ident hc, "⟩", ":=", expr char_p.exists R],
  resetI,
  have [ident hcpn] [":", expr «expr ∣ »(c, «expr ^ »(p, n))] [],
  { rw ["[", "<-", expr char_p.cast_eq_zero_iff R c, ",", "<-", expr hn, ",", expr char_p.cast_card_eq_zero, "]"] [] },
  obtain ["⟨", ident i, ",", ident hi, ",", ident hc, "⟩", ":", expr «expr∃ , »((i «expr ≤ » n), «expr = »(c, «expr ^ »(p, i)))],
  by rwa [expr nat.dvd_prime_pow hp.1] ["at", ident hcpn],
  obtain [ident rfl, ":", expr «expr = »(i, n)],
  { apply [expr hR i hi],
    rw ["[", "<-", expr nat.cast_pow, ",", "<-", expr hc, ",", expr char_p.cast_eq_zero, "]"] [] },
  rwa ["<-", expr hc] []
end

end 

section Prod

variable(S : Type v)[Semiringₓ R][Semiringₓ S](p q : ℕ)[CharP R p]

/-- The characteristic of the product of rings is the least common multiple of the
characteristics of the two rings. -/
instance  [CharP S q] : CharP (R × S) (Nat.lcmₓ p q) :=
  { cast_eq_zero_iff :=
      by 
        simp [Prod.ext_iff, CharP.cast_eq_zero_iff R p, CharP.cast_eq_zero_iff S q, Nat.lcm_dvd_iff] }

/-- The characteristic of the product of two rings of the same characteristic
  is the same as the characteristic of the rings -/
instance Prod.char_p [CharP S p] : CharP (R × S) p :=
  by 
    convert Nat.lcmₓ.char_p R S p p <;> simp 

end Prod

