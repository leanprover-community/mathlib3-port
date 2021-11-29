import Mathbin.Algebra.Associated 
import Mathbin.Algebra.BigOperators.Basic 
import Mathbin.RingTheory.Valuation.Basic

/-!
# Multiplicity of a divisor

For a commutative monoid, this file introduces the notion of multiplicity of a divisor and proves
several basic results on it.

## Main definitions

* `multiplicity a b`: for two elements `a` and `b` of a commutative monoid returns the largest
  number `n` such that `a ^ n ∣ b` or infinity, written `⊤`, if `a ^ n ∣ b` for all natural numbers
  `n`.
* `multiplicity.finite a b`: a predicate denoting that the multiplicity of `a` in `b` is finite.
-/


variable{α : Type _}

open Nat Part

open_locale BigOperators

/-- `multiplicity a b` returns the largest natural number `n` such that
  `a ^ n ∣ b`, as an `enat` or natural with infinity. If `∀ n, a ^ n ∣ b`,
  then it returns `⊤`-/
def multiplicity [CommMonoidₓ α] [DecidableRel (· ∣ · : α → α → Prop)] (a b : α) : Enat :=
  Enat.find$ fun n => ¬(a ^ n+1) ∣ b

namespace multiplicity

section CommMonoidₓ

variable[CommMonoidₓ α]

/-- `multiplicity.finite a b` indicates that the multiplicity of `a` in `b` is finite. -/
@[reducible]
def finite (a b : α) : Prop :=
  ∃ n : ℕ, ¬(a ^ n+1) ∣ b

theorem finite_iff_dom [DecidableRel (· ∣ · : α → α → Prop)] {a b : α} : finite a b ↔ (multiplicity a b).Dom :=
  Iff.rfl

theorem finite_def {a b : α} : finite a b ↔ ∃ n : ℕ, ¬(a ^ n+1) ∣ b :=
  Iff.rfl

@[normCast]
theorem int.coe_nat_multiplicity (a b : ℕ) : multiplicity (a : ℤ) (b : ℤ) = multiplicity a b :=
  by 
    apply Part.ext'
    ·
      repeat' 
        rw [←finite_iff_dom, finite_def]
      normCast
    ·
      intro h1 h2 
      apply _root_.le_antisymm <;>
        ·
          apply Nat.find_mono 
          normCast 
          simp 

theorem not_finite_iff_forall {a b : α} : ¬finite a b ↔ ∀ (n : ℕ), a ^ n ∣ b :=
  ⟨fun h n =>
      Nat.casesOn n
        (by 
          rw [pow_zeroₓ]
          exact one_dvd _)
        (by 
          simpa [finite, not_not] using h),
    by 
      simp [finite, multiplicity, not_not] <;> tauto⟩

theorem not_unit_of_finite {a b : α} (h : finite a b) : ¬IsUnit a :=
  let ⟨n, hn⟩ := h 
  mt (is_unit_iff_forall_dvd.1 ∘ IsUnit.pow (n+1))$ fun h => hn (h b)

theorem finite_of_finite_mul_left {a b c : α} : finite a (b*c) → finite a c :=
  fun ⟨n, hn⟩ =>
    ⟨n,
      fun h =>
        hn
          (h.trans
            (by 
              simp [mul_powₓ]))⟩

theorem finite_of_finite_mul_right {a b c : α} : finite a (b*c) → finite a b :=
  by 
    rw [mul_commₓ] <;> exact finite_of_finite_mul_left

variable[DecidableRel (· ∣ · : α → α → Prop)]

theorem pow_dvd_of_le_multiplicity {a b : α} {k : ℕ} : (k : Enat) ≤ multiplicity a b → a ^ k ∣ b :=
  by 
    rw [←Enat.some_eq_coe]
    exact
      Nat.casesOn k
        (fun _ =>
          by 
            rw [pow_zeroₓ]
            exact one_dvd _)
        fun k ⟨h₁, h₂⟩ => by_contradiction fun hk => Nat.find_minₓ _ (lt_of_succ_le (h₂ ⟨k, hk⟩)) hk

theorem pow_multiplicity_dvd {a b : α} (h : finite a b) : a ^ get (multiplicity a b) h ∣ b :=
  pow_dvd_of_le_multiplicity
    (by 
      rw [Enat.coe_get])

theorem IsGreatest {a b : α} {m : ℕ} (hm : multiplicity a b < m) : ¬a ^ m ∣ b :=
  fun h =>
    by 
      rw [Enat.lt_coe_iff] at hm <;> exact Nat.find_specₓ hm.fst ((pow_dvd_pow _ hm.snd).trans h)

theorem is_greatest' {a b : α} {m : ℕ} (h : finite a b) (hm : get (multiplicity a b) h < m) : ¬a ^ m ∣ b :=
  IsGreatest
    (by 
      rwa [←Enat.coe_lt_coe, Enat.coe_get] at hm)

theorem Unique {a b : α} {k : ℕ} (hk : a ^ k ∣ b) (hsucc : ¬(a ^ k+1) ∣ b) : (k : Enat) = multiplicity a b :=
  le_antisymmₓ (le_of_not_gtₓ fun hk' => IsGreatest hk' hk)$
    have  : finite a b := ⟨k, hsucc⟩
    by 
      rw [Enat.le_coe_iff]
      exact ⟨this, Nat.find_min'ₓ _ hsucc⟩

theorem unique' {a b : α} {k : ℕ} (hk : a ^ k ∣ b) (hsucc : ¬(a ^ k+1) ∣ b) : k = get (multiplicity a b) ⟨k, hsucc⟩ :=
  by 
    rw [←Enat.coe_inj, Enat.coe_get, Unique hk hsucc]

theorem le_multiplicity_of_pow_dvd {a b : α} {k : ℕ} (hk : a ^ k ∣ b) : (k : Enat) ≤ multiplicity a b :=
  le_of_not_gtₓ$ fun hk' => IsGreatest hk' hk

theorem pow_dvd_iff_le_multiplicity {a b : α} {k : ℕ} : a ^ k ∣ b ↔ (k : Enat) ≤ multiplicity a b :=
  ⟨le_multiplicity_of_pow_dvd, pow_dvd_of_le_multiplicity⟩

theorem multiplicity_lt_iff_neg_dvd {a b : α} {k : ℕ} : multiplicity a b < (k : Enat) ↔ ¬a ^ k ∣ b :=
  by 
    rw [pow_dvd_iff_le_multiplicity, not_leₓ]

theorem eq_coe_iff {a b : α} {n : ℕ} : multiplicity a b = (n : Enat) ↔ a ^ n ∣ b ∧ ¬(a ^ n+1) ∣ b :=
  by 
    rw [←Enat.some_eq_coe]
    exact
      ⟨fun h =>
          let ⟨h₁, h₂⟩ := eq_some_iff.1 h 
          h₂ ▸
            ⟨pow_multiplicity_dvd _,
              IsGreatest
                (by 
                  rw [Enat.lt_coe_iff]
                  exact ⟨h₁, lt_succ_self _⟩)⟩,
        fun h => eq_some_iff.2 ⟨⟨n, h.2⟩, Eq.symm$ unique' h.1 h.2⟩⟩

theorem eq_top_iff {a b : α} : multiplicity a b = ⊤ ↔ ∀ (n : ℕ), a ^ n ∣ b :=
  (Enat.find_eq_top_iff _).trans$
    by 
      simp only [not_not]
      exact
        ⟨fun h n =>
            Nat.casesOn n
              (by 
                rw [pow_zeroₓ]
                exact one_dvd _)
              fun n => h _,
          fun h n => h _⟩

@[simp]
theorem is_unit_left {a : α} (b : α) (ha : IsUnit a) : multiplicity a b = ⊤ :=
  eq_top_iff.2 fun _ => is_unit_iff_forall_dvd.1 (ha.pow _) _

theorem is_unit_right {a b : α} (ha : ¬IsUnit a) (hb : IsUnit b) : multiplicity a b = 0 :=
  eq_coe_iff.2
    ⟨show a ^ 0 ∣ b by 
        simp only [pow_zeroₓ, one_dvd],
      by 
        rw [pow_oneₓ]
        exact fun h => mt (is_unit_of_dvd_unit h) ha hb⟩

@[simp]
theorem one_left (b : α) : multiplicity 1 b = ⊤ :=
  is_unit_left b is_unit_one

theorem one_right {a : α} (ha : ¬IsUnit a) : multiplicity a 1 = 0 :=
  is_unit_right ha is_unit_one

@[simp]
theorem get_one_right {a : α} (ha : finite a 1) : get (multiplicity a 1) ha = 0 :=
  by 
    rw [Enat.get_eq_iff_eq_coe, eq_coe_iff, pow_zeroₓ]
    simpa [is_unit_iff_dvd_one.symm] using not_unit_of_finite ha

@[simp]
theorem unit_left (a : α) (u : Units α) : multiplicity (u : α) a = ⊤ :=
  is_unit_left a u.is_unit

theorem unit_right {a : α} (ha : ¬IsUnit a) (u : Units α) : multiplicity a u = 0 :=
  is_unit_right ha u.is_unit

theorem multiplicity_eq_zero_of_not_dvd {a b : α} (ha : ¬a ∣ b) : multiplicity a b = 0 :=
  by 
    rw [←Nat.cast_zero, eq_coe_iff]
    simpa

theorem eq_top_iff_not_finite {a b : α} : multiplicity a b = ⊤ ↔ ¬finite a b :=
  Part.eq_none_iff'

theorem ne_top_iff_finite {a b : α} : multiplicity a b ≠ ⊤ ↔ finite a b :=
  by 
    rw [Ne.def, eq_top_iff_not_finite, not_not]

theorem lt_top_iff_finite {a b : α} : multiplicity a b < ⊤ ↔ finite a b :=
  by 
    rw [lt_top_iff_ne_top, ne_top_iff_finite]

open_locale Classical

theorem multiplicity_le_multiplicity_iff {a b c d : α} :
  multiplicity a b ≤ multiplicity c d ↔ ∀ (n : ℕ), a ^ n ∣ b → c ^ n ∣ d :=
  ⟨fun h n hab => pow_dvd_of_le_multiplicity (le_transₓ (le_multiplicity_of_pow_dvd hab) h),
    fun h =>
      if hab : finite a b then
        by 
          rw [←Enat.coe_get (finite_iff_dom.1 hab)] <;> exact le_multiplicity_of_pow_dvd (h _ (pow_multiplicity_dvd _))
      else
        have  : ∀ (n : ℕ), c ^ n ∣ d := fun n => h n (not_finite_iff_forall.1 hab _)
        by 
          rw [eq_top_iff_not_finite.2 hab, eq_top_iff_not_finite.2 (not_finite_iff_forall.2 this)]⟩

theorem multiplicity_le_multiplicity_of_dvd_left {a b c : α} (hdvd : a ∣ b) : multiplicity b c ≤ multiplicity a c :=
  multiplicity_le_multiplicity_iff.2$ fun n h => (pow_dvd_pow_of_dvd hdvd n).trans h

theorem eq_of_associated_left {a b c : α} (h : Associated a b) : multiplicity b c = multiplicity a c :=
  le_antisymmₓ (multiplicity_le_multiplicity_of_dvd_left h.dvd) (multiplicity_le_multiplicity_of_dvd_left h.symm.dvd)

theorem multiplicity_le_multiplicity_of_dvd_right {a b c : α} (h : b ∣ c) : multiplicity a b ≤ multiplicity a c :=
  multiplicity_le_multiplicity_iff.2$ fun n hb => hb.trans h

theorem eq_of_associated_right {a b c : α} (h : Associated b c) : multiplicity a b = multiplicity a c :=
  le_antisymmₓ (multiplicity_le_multiplicity_of_dvd_right h.dvd) (multiplicity_le_multiplicity_of_dvd_right h.symm.dvd)

theorem dvd_of_multiplicity_pos {a b : α} (h : (0 : Enat) < multiplicity a b) : a ∣ b :=
  by 
    rw [←pow_oneₓ a]
    apply pow_dvd_of_le_multiplicity 
    simpa only [Nat.cast_one, Enat.pos_iff_one_le] using h

theorem dvd_iff_multiplicity_pos {a b : α} : (0 : Enat) < multiplicity a b ↔ a ∣ b :=
  ⟨dvd_of_multiplicity_pos,
    fun hdvd =>
      lt_of_le_of_neₓ (zero_le _)
        fun heq =>
          IsGreatest
            (show multiplicity a b < «expr↑ » 1by 
              simpa only [HEq, Nat.cast_zero] using enat.coe_lt_coe.mpr zero_lt_one)
            (by 
              rwa [pow_oneₓ a])⟩

-- error in RingTheory.Multiplicity: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem finite_nat_iff {a b : exprℕ()} : «expr ↔ »(finite a b, «expr ∧ »(«expr ≠ »(a, 1), «expr < »(0, b))) :=
begin
  rw ["[", "<-", expr not_iff_not, ",", expr not_finite_iff_forall, ",", expr not_and_distrib, ",", expr ne.def, ",", expr not_not, ",", expr not_lt, ",", expr nat.le_zero_iff, "]"] [],
  exact [expr ⟨λ
    h, or_iff_not_imp_right.2 (λ
     hb, have ha : «expr ≠ »(a, 0), from λ ha, by simpa [] [] [] ["[", expr ha, "]"] [] ["using", expr h 1],
     by_contradiction (λ
      ha1 : «expr ≠ »(a, 1), have ha_gt_one : «expr < »(1, a), from lt_of_not_ge (λ ha', by { clear [ident h],
         revert [ident ha, ident ha1],
         dec_trivial ["!"] }),
      not_lt_of_ge (le_of_dvd (nat.pos_of_ne_zero hb) (h b)) (lt_pow_self ha_gt_one b))), λ
    h, by cases [expr h] []; simp [] [] [] ["*"] [] []⟩]
end

end CommMonoidₓ

section CommMonoidWithZero

variable[CommMonoidWithZero α]

theorem ne_zero_of_finite {a b : α} (h : finite a b) : b ≠ 0 :=
  let ⟨n, hn⟩ := h 
  fun hb =>
    by 
      simpa [hb] using hn

variable[DecidableRel (· ∣ · : α → α → Prop)]

@[simp]
protected theorem zero (a : α) : multiplicity a 0 = ⊤ :=
  Part.eq_none_iff.2 fun n ⟨⟨k, hk⟩, _⟩ => hk (dvd_zero _)

@[simp]
theorem multiplicity_zero_eq_zero_of_ne_zero (a : α) (ha : a ≠ 0) : multiplicity 0 a = 0 :=
  by 
    apply multiplicity.multiplicity_eq_zero_of_not_dvd 
    rwa [zero_dvd_iff]

end CommMonoidWithZero

section CommSemiringₓ

variable[CommSemiringₓ α][DecidableRel (· ∣ · : α → α → Prop)]

theorem min_le_multiplicity_add {p a b : α} : min (multiplicity p a) (multiplicity p b) ≤ multiplicity p (a+b) :=
  (le_totalₓ (multiplicity p a) (multiplicity p b)).elim
    (fun h =>
      by 
        rw [min_eq_leftₓ h, multiplicity_le_multiplicity_iff] <;>
          exact fun n hn => dvd_add hn (multiplicity_le_multiplicity_iff.1 h n hn))
    fun h =>
      by 
        rw [min_eq_rightₓ h, multiplicity_le_multiplicity_iff] <;>
          exact fun n hn => dvd_add (multiplicity_le_multiplicity_iff.1 h n hn) hn

end CommSemiringₓ

section CommRingₓ

variable[CommRingₓ α][DecidableRel (· ∣ · : α → α → Prop)]

open_locale Classical

@[simp]
protected theorem neg (a b : α) : multiplicity a (-b) = multiplicity a b :=
  Part.ext'
    (by 
      simp only [multiplicity, Enat.find, dvd_neg])
    fun h₁ h₂ =>
      Enat.coe_inj.1
        (by 
          rw [Enat.coe_get] <;>
            exact
              Eq.symm
                (Unique ((dvd_neg _ _).2 (pow_multiplicity_dvd _))
                  (mt (dvd_neg _ _).1 (is_greatest' _ (lt_succ_self _)))))

theorem multiplicity_add_of_gt {p a b : α} (h : multiplicity p b < multiplicity p a) :
  multiplicity p (a+b) = multiplicity p b :=
  by 
    apply le_antisymmₓ
    ·
      apply Enat.le_of_lt_add_one 
      cases' enat.ne_top_iff.mp (Enat.ne_top_of_lt h) with k hk 
      rw [hk]
      rwModCast [multiplicity_lt_iff_neg_dvd]
      intro h_dvd 
      rw [←dvd_add_iff_right] at h_dvd 
      apply multiplicity.is_greatest _ h_dvd 
      rw [hk]
      applyModCast Nat.lt_succ_selfₓ 
      rw [pow_dvd_iff_le_multiplicity, Nat.cast_add, ←hk, Nat.cast_one]
      exact Enat.add_one_le_of_lt h
    ·
      convert min_le_multiplicity_add 
      rw [min_eq_rightₓ (le_of_ltₓ h)]

theorem multiplicity_sub_of_gt {p a b : α} (h : multiplicity p b < multiplicity p a) :
  multiplicity p (a - b) = multiplicity p b :=
  by 
    rw [sub_eq_add_neg, multiplicity_add_of_gt] <;> rwa [multiplicity.neg]

theorem multiplicity_add_eq_min {p a b : α} (h : multiplicity p a ≠ multiplicity p b) :
  multiplicity p (a+b) = min (multiplicity p a) (multiplicity p b) :=
  by 
    rcases lt_trichotomyₓ (multiplicity p a) (multiplicity p b) with (hab | hab | hab)
    ·
      rw [add_commₓ, multiplicity_add_of_gt hab, min_eq_leftₓ]
      exact le_of_ltₓ hab
    ·
      contradiction
    ·
      rw [multiplicity_add_of_gt hab, min_eq_rightₓ]
      exact le_of_ltₓ hab

end CommRingₓ

section CommCancelMonoidWithZero

variable[CommCancelMonoidWithZero α]

theorem finite_mul_aux {p : α} (hp : Prime p) :
  ∀ {n m : ℕ} {a b : α}, ¬(p ^ n+1) ∣ a → ¬(p ^ m+1) ∣ b → ¬(p ^ (n+m)+1) ∣ a*b
| n, m =>
  fun a b ha hb ⟨s, hs⟩ =>
    have  : p ∣ a*b :=
      ⟨(p ^ n+m)*s,
        by 
          simp [hs, pow_addₓ, mul_commₓ, mul_assocₓ, mul_left_commₓ]⟩
    (hp.2.2 a b this).elim
      (fun ⟨x, hx⟩ =>
        have hn0 : 0 < n :=
          Nat.pos_of_ne_zeroₓ
            fun hn0 =>
              by 
                clear _fun_match _fun_match <;> simpa [hx, hn0] using ha 
        have wf : n - 1 < n :=
          tsub_lt_self hn0
            (by 
              decide)
        have hpx : ¬(p ^ (n - 1)+1) ∣ x :=
          fun ⟨y, hy⟩ =>
            ha
              (hx.symm ▸
                ⟨y,
                  mul_right_cancel₀ hp.1$
                    by 
                      rw [tsub_add_cancel_of_le (succ_le_of_lt hn0)] at hy <;>
                        simp [hy, pow_addₓ, mul_commₓ, mul_assocₓ, mul_left_commₓ]⟩)
        have  : 1 ≤ n+m := le_transₓ hn0 (Nat.le_add_rightₓ n m)
        finite_mul_aux hpx hb
          ⟨s,
            mul_right_cancel₀ hp.1
              (by 
                rw [tsub_add_eq_add_tsub (succ_le_of_lt hn0), tsub_add_cancel_of_le this]
                clear _fun_match _fun_match finite_mul_aux 
                simp_all [mul_commₓ, mul_assocₓ, mul_left_commₓ, pow_addₓ])⟩)
      fun ⟨x, hx⟩ =>
        have hm0 : 0 < m :=
          Nat.pos_of_ne_zeroₓ
            fun hm0 =>
              by 
                clear _fun_match _fun_match <;> simpa [hx, hm0] using hb 
        have wf : m - 1 < m :=
          tsub_lt_self hm0
            (by 
              decide)
        have hpx : ¬(p ^ (m - 1)+1) ∣ x :=
          fun ⟨y, hy⟩ =>
            hb
              (hx.symm ▸
                ⟨y,
                  mul_right_cancel₀ hp.1$
                    by 
                      rw [tsub_add_cancel_of_le (succ_le_of_lt hm0)] at hy <;>
                        simp [hy, pow_addₓ, mul_commₓ, mul_assocₓ, mul_left_commₓ]⟩)
        finite_mul_aux ha hpx
          ⟨s,
            mul_right_cancel₀ hp.1
              (by 
                rw [add_assocₓ, tsub_add_cancel_of_le (succ_le_of_lt hm0)]
                clear _fun_match _fun_match finite_mul_aux 
                simp_all [mul_commₓ, mul_assocₓ, mul_left_commₓ, pow_addₓ])⟩

theorem finite_mul {p a b : α} (hp : Prime p) : finite p a → finite p b → finite p (a*b) :=
  fun ⟨n, hn⟩ ⟨m, hm⟩ => ⟨n+m, finite_mul_aux hp hn hm⟩

theorem finite_mul_iff {p a b : α} (hp : Prime p) : finite p (a*b) ↔ finite p a ∧ finite p b :=
  ⟨fun h => ⟨finite_of_finite_mul_right h, finite_of_finite_mul_left h⟩, fun h => finite_mul hp h.1 h.2⟩

theorem finite_pow {p a : α} (hp : Prime p) : ∀ {k : ℕ} (ha : finite p a), finite p (a ^ k)
| 0, ha =>
  ⟨0,
    by 
      simp [mt is_unit_iff_dvd_one.2 hp.2.1]⟩
| k+1, ha =>
  by 
    rw [pow_succₓ] <;> exact finite_mul hp ha (finite_pow ha)

variable[DecidableRel (· ∣ · : α → α → Prop)]

@[simp]
theorem multiplicity_self {a : α} (ha : ¬IsUnit a) (ha0 : a ≠ 0) : multiplicity a a = 1 :=
  by 
    rw [←Nat.cast_one]
    exact
      eq_coe_iff.2
        ⟨by 
            simp ,
          fun ⟨b, hb⟩ =>
            ha
              (is_unit_iff_dvd_one.2
                ⟨b,
                  mul_left_cancel₀ ha0$
                    by 
                      clear _fun_match 
                      simpa [pow_succₓ, mul_assocₓ] using hb⟩)⟩

@[simp]
theorem get_multiplicity_self {a : α} (ha : finite a a) : get (multiplicity a a) ha = 1 :=
  Enat.get_eq_iff_eq_coe.2
    (eq_coe_iff.2
      ⟨by 
          simp ,
        fun ⟨b, hb⟩ =>
          by 
            rw [←mul_oneₓ a, pow_addₓ, pow_oneₓ, mul_assocₓ, mul_assocₓ, mul_right_inj' (ne_zero_of_finite ha)] at
                hb <;>
              exact
                mt is_unit_iff_dvd_one.2 (not_unit_of_finite ha)
                  ⟨b,
                    by 
                      clear _fun_match <;> simp_all ⟩⟩)

protected theorem mul' {p a b : α} (hp : Prime p) (h : (multiplicity p (a*b)).Dom) :
  get (multiplicity p (a*b)) h =
    get (multiplicity p a) ((finite_mul_iff hp).1 h).1+get (multiplicity p b) ((finite_mul_iff hp).1 h).2 :=
  have hdiva : p ^ get (multiplicity p a) ((finite_mul_iff hp).1 h).1 ∣ a := pow_multiplicity_dvd _ 
  have hdivb : p ^ get (multiplicity p b) ((finite_mul_iff hp).1 h).2 ∣ b := pow_multiplicity_dvd _ 
  have hpoweq :
    (p ^ get (multiplicity p a) ((finite_mul_iff hp).1 h).1+get (multiplicity p b) ((finite_mul_iff hp).1 h).2) =
      (p ^ get (multiplicity p a) ((finite_mul_iff hp).1 h).1)*p ^ get (multiplicity p b) ((finite_mul_iff hp).1 h).2 :=
    by 
      simp [pow_addₓ]
  have hdiv :
    (p ^ get (multiplicity p a) ((finite_mul_iff hp).1 h).1+get (multiplicity p b) ((finite_mul_iff hp).1 h).2) ∣ a*b :=
    by 
      rw [hpoweq] <;> apply mul_dvd_mul <;> assumption 
  have hsucc :
    ¬(p ^ (get (multiplicity p a) ((finite_mul_iff hp).1 h).1+get (multiplicity p b) ((finite_mul_iff hp).1 h).2)+1) ∣
        a*b :=
    fun h =>
      by 
        exact
          not_orₓ (is_greatest' _ (lt_succ_self _)) (is_greatest' _ (lt_succ_self _))
            (_root_.succ_dvd_or_succ_dvd_of_succ_sum_dvd_mul hp hdiva hdivb h)
  by 
    rw [←Enat.coe_inj, Enat.coe_get, eq_coe_iff] <;> exact ⟨hdiv, hsucc⟩

open_locale Classical

protected theorem mul {p a b : α} (hp : Prime p) : multiplicity p (a*b) = multiplicity p a+multiplicity p b :=
  if h : finite p a ∧ finite p b then
    by 
      rw [←Enat.coe_get (finite_iff_dom.1 h.1), ←Enat.coe_get (finite_iff_dom.1 h.2),
          ←Enat.coe_get (finite_iff_dom.1 (finite_mul hp h.1 h.2)), ←Nat.cast_add, Enat.coe_inj,
          multiplicity.mul' hp] <;>
        rfl
  else
    by 
      rw [eq_top_iff_not_finite.2 (mt (finite_mul_iff hp).1 h)]
      cases' not_and_distrib.1 h with h h <;> simp [eq_top_iff_not_finite.2 h]

theorem Finset.prod {β : Type _} {p : α} (hp : Prime p) (s : Finset β) (f : β → α) :
  multiplicity p (∏x in s, f x) = ∑x in s, multiplicity p (f x) :=
  by 
    classical 
    induction' s using Finset.induction with a s has ih h
    ·
      simp only [Finset.sum_empty, Finset.prod_empty]
      convert one_right hp.not_unit
    ·
      simp [has, ←ih]
      convert multiplicity.mul hp

protected theorem pow' {p a : α} (hp : Prime p) (ha : finite p a) :
  ∀ {k : ℕ}, get (multiplicity p (a ^ k)) (finite_pow hp ha) = k*get (multiplicity p a) ha
| 0 =>
  by 
    simp [one_right hp.not_unit]
| k+1 =>
  have  : multiplicity p (a ^ k+1) = multiplicity p (a*a ^ k) :=
    by 
      rw [pow_succₓ]
  by 
    rw [get_eq_get_of_eq _ _ this, multiplicity.mul' hp, pow', add_mulₓ, one_mulₓ, add_commₓ]

theorem pow {p a : α} (hp : Prime p) : ∀ {k : ℕ}, multiplicity p (a ^ k) = k • multiplicity p a
| 0 =>
  by 
    simp [one_right hp.not_unit]
| succ k =>
  by 
    simp [pow_succₓ, succ_nsmul, pow, multiplicity.mul hp]

theorem multiplicity_pow_self {p : α} (h0 : p ≠ 0) (hu : ¬IsUnit p) (n : ℕ) : multiplicity p (p ^ n) = n :=
  by 
    rw [eq_coe_iff]
    use dvd_rfl 
    rw [pow_dvd_pow_iff h0 hu]
    apply Nat.not_succ_le_selfₓ

theorem multiplicity_pow_self_of_prime {p : α} (hp : Prime p) (n : ℕ) : multiplicity p (p ^ n) = n :=
  multiplicity_pow_self hp.ne_zero hp.not_unit n

end CommCancelMonoidWithZero

section Valuation

variable{R : Type _}[CommRingₓ R][IsDomain R]{p : R}[DecidableRel (HasDvd.Dvd : R → R → Prop)]

/-- `multiplicity` of a prime inan integral domain as an additive valuation to `enat`. -/
noncomputable def AddValuation (hp : Prime p) : AddValuation R Enat :=
  AddValuation.of (multiplicity p) (multiplicity.zero _) (one_right hp.not_unit) (fun _ _ => min_le_multiplicity_add)
    fun a b => multiplicity.mul hp

@[simp]
theorem add_valuation_apply {hp : Prime p} {r : R} : AddValuation hp r = multiplicity p r :=
  rfl

end Valuation

end multiplicity

section Nat

open multiplicity

-- error in RingTheory.Multiplicity: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem multiplicity_eq_zero_of_coprime
{p a b : exprℕ()}
(hp : «expr ≠ »(p, 1))
(hle : «expr ≤ »(multiplicity p a, multiplicity p b))
(hab : nat.coprime a b) : «expr = »(multiplicity p a, 0) :=
begin
  rw ["[", expr multiplicity_le_multiplicity_iff, "]"] ["at", ident hle],
  rw ["[", "<-", expr nonpos_iff_eq_zero, ",", "<-", expr not_lt, ",", expr enat.pos_iff_one_le, ",", "<-", expr nat.cast_one, ",", "<-", expr pow_dvd_iff_le_multiplicity, "]"] [],
  assume [binders (h)],
  have [] [] [":=", expr nat.dvd_gcd h (hle _ h)],
  rw ["[", expr coprime.gcd_eq_one hab, ",", expr nat.dvd_one, ",", expr pow_one, "]"] ["at", ident this],
  exact [expr hp this]
end

end Nat

