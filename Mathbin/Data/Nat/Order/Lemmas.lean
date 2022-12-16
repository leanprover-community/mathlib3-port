/-
Copyright (c) 2014 Floris van Doorn (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn, Leonardo de Moura, Jeremy Avigad, Mario Carneiro

! This file was ported from Lean 3 source module data.nat.order.lemmas
! leanprover-community/mathlib commit d012cd09a9b256d870751284dd6a29882b0be105
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Order.Basic
import Mathbin.Data.Set.Basic
import Mathbin.Algebra.Ring.Divisibility
import Mathbin.Algebra.GroupWithZero.Divisibility

/-!
# Further lemmas about the natural numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> https://github.com/leanprover-community/mathlib4/pull/927
> Any changes to this file require a corresponding PR to mathlib4.

The distinction between this file and `data.nat.order.basic` is not particularly clear.
They are separated by now to minimize the porting requirements for tactics during the transition to
mathlib4. After `data.rat.order` has been ported, please feel free to reorganize these two files.
-/


universe u v

variable {m n k : ℕ}

namespace Nat

/-! ### Sets -/


#print Nat.Subtype.orderBot /-
instance Subtype.orderBot (s : Set ℕ) [DecidablePred (· ∈ s)] [h : Nonempty s] :
    OrderBot
      s where 
  bot := ⟨Nat.find (nonempty_subtype.1 h), Nat.find_spec (nonempty_subtype.1 h)⟩
  bot_le x := Nat.find_min' _ x.2
#align nat.subtype.order_bot Nat.Subtype.orderBot
-/

#print Nat.Subtype.semilatticeSup /-
instance Subtype.semilatticeSup (s : Set ℕ) : SemilatticeSup s :=
  { Subtype.linearOrder s, LinearOrder.toLattice with }
#align nat.subtype.semilattice_sup Nat.Subtype.semilatticeSup
-/

/- warning: nat.subtype.coe_bot -> Nat.Subtype.coe_bot is a dubious translation:
lean 3 declaration is
  forall {s : Set.{0} Nat} [_inst_1 : DecidablePred.{1} Nat (fun (_x : Nat) => Membership.Mem.{0, 0} Nat (Set.{0} Nat) (Set.hasMem.{0} Nat) _x s)] [h : Nonempty.{1} (coeSort.{1, 2} (Set.{0} Nat) Type (Set.hasCoeToSort.{0} Nat) s)], Eq.{1} Nat ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) (coeSort.{1, 2} (Set.{0} Nat) Type (Set.hasCoeToSort.{0} Nat) s) Nat (HasLiftT.mk.{1, 1} (coeSort.{1, 2} (Set.{0} Nat) Type (Set.hasCoeToSort.{0} Nat) s) Nat (CoeTCₓ.coe.{1, 1} (coeSort.{1, 2} (Set.{0} Nat) Type (Set.hasCoeToSort.{0} Nat) s) Nat (CoeTCₓ.mk.{1, 1} (coeSort.{1, 2} (Set.{0} Nat) Type (Set.hasCoeToSort.{0} Nat) s) Nat (Subtype.val.{1} Nat (fun (x : Nat) => (fun (x : Nat) => Membership.Mem.{0, 0} Nat (Set.{0} Nat) (Set.hasMem.{0} Nat) x s) x))))) (Bot.bot.{0} (coeSort.{1, 2} (Set.{0} Nat) Type (Set.hasCoeToSort.{0} Nat) s) (OrderBot.toHasBot.{0} (coeSort.{1, 2} (Set.{0} Nat) Type (Set.hasCoeToSort.{0} Nat) s) (Subtype.hasLe.{0} Nat Nat.hasLe (fun (x : Nat) => Membership.Mem.{0, 0} Nat (Set.{0} Nat) (Set.hasMem.{0} Nat) x s)) (Nat.Subtype.orderBot s (fun (a : Nat) => _inst_1 a) h)))) (Nat.find (fun (n : Nat) => Membership.Mem.{0, 0} Nat (Set.{0} Nat) (Set.hasMem.{0} Nat) n s) (fun (a : Nat) => _inst_1 a) (Iff.mp (Nonempty.{1} (Subtype.{1} Nat (fun (x : Nat) => Membership.Mem.{0, 0} Nat (Set.{0} Nat) (Set.hasMem.{0} Nat) x s))) (Exists.{1} Nat (fun (a : Nat) => Membership.Mem.{0, 0} Nat (Set.{0} Nat) (Set.hasMem.{0} Nat) a s)) (nonempty_subtype.{1} Nat (fun (x : Nat) => Membership.Mem.{0, 0} Nat (Set.{0} Nat) (Set.hasMem.{0} Nat) x s)) h))
but is expected to have type
  forall {s : Set.{0} Nat} [_inst_1 : DecidablePred.{1} Nat (fun (_x : Nat) => Membership.mem.{0, 0} Nat (Set.{0} Nat) (Set.instMembershipSet.{0} Nat) _x s)] [h : Nonempty.{1} (Set.Elem.{0} Nat s)], Eq.{1} Nat (Subtype.val.{1} Nat (fun (x : Nat) => Membership.mem.{0, 0} Nat (Set.{0} Nat) (Set.instMembershipSet.{0} Nat) x s) (Bot.bot.{0} (Set.Elem.{0} Nat s) (OrderBot.toBot.{0} (Set.Elem.{0} Nat s) (Subtype.le.{0} Nat instLENat (fun (x : Nat) => Membership.mem.{0, 0} Nat (Set.{0} Nat) (Set.instMembershipSet.{0} Nat) x s)) (Nat.Subtype.orderBot s (fun (a : Nat) => _inst_1 a) h)))) (Nat.find (fun (n : Nat) => Membership.mem.{0, 0} Nat (Set.{0} Nat) (Set.instMembershipSet.{0} Nat) n s) (fun (a : Nat) => _inst_1 a) (Iff.mp (Nonempty.{1} (Subtype.{1} Nat (fun (x : Nat) => Membership.mem.{0, 0} Nat (Set.{0} Nat) (Set.instMembershipSet.{0} Nat) x s))) (Exists.{1} Nat (fun (a : Nat) => Membership.mem.{0, 0} Nat (Set.{0} Nat) (Set.instMembershipSet.{0} Nat) a s)) (nonempty_subtype.{1} Nat (fun (x : Nat) => Membership.mem.{0, 0} Nat (Set.{0} Nat) (Set.instMembershipSet.{0} Nat) x s)) h))
Case conversion may be inaccurate. Consider using '#align nat.subtype.coe_bot Nat.Subtype.coe_botₓ'. -/
theorem Subtype.coe_bot {s : Set ℕ} [DecidablePred (· ∈ s)] [h : Nonempty s] :
    ((⊥ : s) : ℕ) = Nat.find (nonempty_subtype.1 h) :=
  rfl
#align nat.subtype.coe_bot Nat.Subtype.coe_bot

#print Nat.set_eq_univ /-
theorem set_eq_univ {S : Set ℕ} : S = Set.univ ↔ 0 ∈ S ∧ ∀ k : ℕ, k ∈ S → k + 1 ∈ S :=
  ⟨by rintro rfl <;> simp, fun ⟨h0, hs⟩ => Set.eq_univ_of_forall (set_induction h0 hs)⟩
#align nat.set_eq_univ Nat.set_eq_univ
-/

/-! ### `div` -/


#print Nat.lt_div_iff_mul_lt /-
protected theorem lt_div_iff_mul_lt {n d : ℕ} (hnd : d ∣ n) (a : ℕ) : a < n / d ↔ d * a < n := by
  rcases d.eq_zero_or_pos with (rfl | hd0); · simp [zero_dvd_iff.mp hnd]
  rw [← mul_lt_mul_left hd0, ← Nat.eq_mul_of_div_eq_right hnd rfl]
#align nat.lt_div_iff_mul_lt Nat.lt_div_iff_mul_lt
-/

#print Nat.div_eq_iff_eq_of_dvd_dvd /-
theorem div_eq_iff_eq_of_dvd_dvd {n x y : ℕ} (hn : n ≠ 0) (hx : x ∣ n) (hy : y ∣ n) :
    n / x = n / y ↔ x = y := by 
  constructor
  · intro h
    rw [← mul_right_inj' hn]
    apply Nat.eq_mul_of_div_eq_left (dvd_mul_of_dvd_left hy x)
    rw [eq_comm, mul_comm, Nat.mul_div_assoc _ hy]
    exact Nat.eq_mul_of_div_eq_right hx h
  · intro h
    rw [h]
#align nat.div_eq_iff_eq_of_dvd_dvd Nat.div_eq_iff_eq_of_dvd_dvd
-/

#print Nat.div_eq_zero_iff /-
protected theorem div_eq_zero_iff {a b : ℕ} (hb : 0 < b) : a / b = 0 ↔ a < b :=
  ⟨fun h => by rw [← mod_add_div a b, h, mul_zero, add_zero] <;> exact mod_lt _ hb, fun h => by
    rw [← mul_right_inj' hb.ne', ← @add_left_cancel_iff _ _ _ (a % b), mod_add_div, mod_eq_of_lt h,
      mul_zero, add_zero]⟩
#align nat.div_eq_zero_iff Nat.div_eq_zero_iff
-/

#print Nat.div_eq_zero /-
protected theorem div_eq_zero {a b : ℕ} (hb : a < b) : a / b = 0 :=
  (Nat.div_eq_zero_iff <| (zero_le a).trans_lt hb).mpr hb
#align nat.div_eq_zero Nat.div_eq_zero
-/

/-! ### `mod`, `dvd` -/


#print Nat.dvd_one /-
@[simp]
protected theorem dvd_one {n : ℕ} : n ∣ 1 ↔ n = 1 :=
  ⟨eq_one_of_dvd_one, fun e => e.symm ▸ dvd_rfl⟩
#align nat.dvd_one Nat.dvd_one
-/

#print Nat.not_two_dvd_bit1 /-
@[simp]
protected theorem not_two_dvd_bit1 (n : ℕ) : ¬2 ∣ bit1 n := by
  rw [bit1, Nat.dvd_add_right two_dvd_bit0, Nat.dvd_one]
  cc
#align nat.not_two_dvd_bit1 Nat.not_two_dvd_bit1
-/

#print Nat.dvd_add_self_left /-
/-- A natural number `m` divides the sum `m + n` if and only if `m` divides `n`.-/
@[simp]
protected theorem dvd_add_self_left {m n : ℕ} : m ∣ m + n ↔ m ∣ n :=
  Nat.dvd_add_right (dvd_refl m)
#align nat.dvd_add_self_left Nat.dvd_add_self_left
-/

#print Nat.dvd_add_self_right /-
/-- A natural number `m` divides the sum `n + m` if and only if `m` divides `n`.-/
@[simp]
protected theorem dvd_add_self_right {m n : ℕ} : m ∣ n + m ↔ m ∣ n :=
  Nat.dvd_add_left (dvd_refl m)
#align nat.dvd_add_self_right Nat.dvd_add_self_right
-/

#print Nat.dvd_sub' /-
-- TODO: update `nat.dvd_sub` in core
theorem dvd_sub' {k m n : ℕ} (h₁ : k ∣ m) (h₂ : k ∣ n) : k ∣ m - n := by
  cases' le_total n m with H H
  · exact dvd_sub H h₁ h₂
  · rw [tsub_eq_zero_iff_le.mpr H]
    exact dvd_zero k
#align nat.dvd_sub' Nat.dvd_sub'
-/

/- warning: nat.succ_div -> Nat.succ_div is a dubious translation:
lean 3 declaration is
  forall (a : Nat) (b : Nat), Eq.{1} Nat (HDiv.hDiv.{0, 0, 0} Nat Nat Nat (instHDiv.{0} Nat Nat.hasDiv) (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) a (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))) b) (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) (HDiv.hDiv.{0, 0, 0} Nat Nat Nat (instHDiv.{0} Nat Nat.hasDiv) a b) (ite.{1} Nat (Dvd.Dvd.{0} Nat Nat.hasDvd b (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) a (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Nat.decidableDvd b (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) a (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))) (OfNat.ofNat.{0} Nat 0 (OfNat.mk.{0} Nat 0 (Zero.zero.{0} Nat Nat.hasZero)))))
but is expected to have type
  forall (a : Nat) (b : Nat), Eq.{1} Nat (HDiv.hDiv.{0, 0, 0} Nat Nat Nat (instHDiv.{0} Nat Nat.instDivNat) (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) a (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))) b) (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) (HDiv.hDiv.{0, 0, 0} Nat Nat Nat (instHDiv.{0} Nat Nat.instDivNat) a b) (ite.{1} Nat (Dvd.dvd.{0} Nat Nat.instDvdNat b (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) a (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (Nat.decidable_dvd b (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) a (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)) (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0))))
Case conversion may be inaccurate. Consider using '#align nat.succ_div Nat.succ_divₓ'. -/
theorem succ_div : ∀ a b : ℕ, (a + 1) / b = a / b + if b ∣ a + 1 then 1 else 0
  | a, 0 => by simp
  | 0, 1 => by simp
  | 0, b + 2 => by 
    have hb2 : b + 2 > 1 := by decide
    simp [ne_of_gt hb2, div_eq_of_lt hb2]
  | a + 1, b + 1 => by 
    rw [Nat.div_eq]; conv_rhs => rw [Nat.div_eq]
    by_cases hb_eq_a : b = a + 1
    · simp [hb_eq_a, le_refl]
    by_cases hb_le_a1 : b ≤ a + 1
    · have hb_le_a : b ≤ a := le_of_lt_succ (lt_of_le_of_ne hb_le_a1 hb_eq_a)
      have h₁ : 0 < b + 1 ∧ b + 1 ≤ a + 1 + 1 := ⟨succ_pos _, (add_le_add_iff_right _).2 hb_le_a1⟩
      have h₂ : 0 < b + 1 ∧ b + 1 ≤ a + 1 := ⟨succ_pos _, (add_le_add_iff_right _).2 hb_le_a⟩
      have dvd_iff : b + 1 ∣ a - b + 1 ↔ b + 1 ∣ a + 1 + 1 := by
        rw [Nat.dvd_add_iff_left (dvd_refl (b + 1)), ← add_tsub_add_eq_tsub_right a 1 b,
          add_comm (_ - _), add_assoc, tsub_add_cancel_of_le (succ_le_succ hb_le_a), add_comm 1]
      have wf : a - b < a + 1 := lt_succ_of_le tsub_le_self
      rw [if_pos h₁, if_pos h₂, add_tsub_add_eq_tsub_right, ← tsub_add_eq_add_tsub hb_le_a,
        have := wf
        succ_div (a - b),
        add_tsub_add_eq_tsub_right]
      simp [dvd_iff, succ_eq_add_one, add_comm 1, add_assoc]
    · have hba : ¬b ≤ a := not_le_of_gt (lt_trans (lt_succ_self a) (lt_of_not_ge hb_le_a1))
      have hb_dvd_a : ¬b + 1 ∣ a + 2 := fun h =>
        hb_le_a1 (le_of_succ_le_succ (le_of_dvd (succ_pos _) h))
      simp [hba, hb_le_a1, hb_dvd_a]
#align nat.succ_div Nat.succ_div

#print Nat.succ_div_of_dvd /-
theorem succ_div_of_dvd {a b : ℕ} (hba : b ∣ a + 1) : (a + 1) / b = a / b + 1 := by
  rw [succ_div, if_pos hba]
#align nat.succ_div_of_dvd Nat.succ_div_of_dvd
-/

#print Nat.succ_div_of_not_dvd /-
theorem succ_div_of_not_dvd {a b : ℕ} (hba : ¬b ∣ a + 1) : (a + 1) / b = a / b := by
  rw [succ_div, if_neg hba, add_zero]
#align nat.succ_div_of_not_dvd Nat.succ_div_of_not_dvd
-/

#print Nat.dvd_iff_div_mul_eq /-
theorem dvd_iff_div_mul_eq (n d : ℕ) : d ∣ n ↔ n / d * d = n :=
  ⟨fun h => Nat.div_mul_cancel h, fun h => Dvd.intro_left (n / d) h⟩
#align nat.dvd_iff_div_mul_eq Nat.dvd_iff_div_mul_eq
-/

#print Nat.dvd_iff_le_div_mul /-
theorem dvd_iff_le_div_mul (n d : ℕ) : d ∣ n ↔ n ≤ n / d * d :=
  ((dvd_iff_div_mul_eq _ _).trans le_antisymm_iff).trans (and_iff_right (div_mul_le_self n d))
#align nat.dvd_iff_le_div_mul Nat.dvd_iff_le_div_mul
-/

#print Nat.dvd_iff_dvd_dvd /-
theorem dvd_iff_dvd_dvd (n d : ℕ) : d ∣ n ↔ ∀ k : ℕ, k ∣ d → k ∣ n :=
  ⟨fun h k hkd => dvd_trans hkd h, fun h => h _ dvd_rfl⟩
#align nat.dvd_iff_dvd_dvd Nat.dvd_iff_dvd_dvd
-/

#print Nat.dvd_div_of_mul_dvd /-
theorem dvd_div_of_mul_dvd {a b c : ℕ} (h : a * b ∣ c) : b ∣ c / a :=
  if ha : a = 0 then by simp [ha]
  else
    have ha : 0 < a := Nat.pos_of_ne_zero ha
    have h1 : ∃ d, c = a * b * d := h
    let ⟨d, hd⟩ := h1
    have h2 : c / a = b * d := Nat.div_eq_of_eq_mul_right ha (by simpa [mul_assoc] using hd)
    show ∃ d, c / a = b * d from ⟨d, h2⟩
#align nat.dvd_div_of_mul_dvd Nat.dvd_div_of_mul_dvd
-/

#print Nat.dvd_div_iff /-
@[simp]
theorem dvd_div_iff {a b c : ℕ} (hbc : c ∣ b) : a ∣ b / c ↔ c * a ∣ b :=
  ⟨fun h => mul_dvd_of_dvd_div hbc h, fun h => dvd_div_of_mul_dvd h⟩
#align nat.dvd_div_iff Nat.dvd_div_iff
-/

#print Nat.div_div_div_eq_div /-
@[simp]
theorem div_div_div_eq_div : ∀ {a b c : ℕ} (dvd : b ∣ a) (dvd2 : a ∣ c), c / (a / b) / b = c / a
  | 0, _ => by simp
  | a + 1, 0 => fun _ dvd _ => by simpa using dvd
  | a + 1, c + 1 =>
    have a_split : a + 1 ≠ 0 := succ_ne_zero a
    have c_split : c + 1 ≠ 0 := succ_ne_zero c
    fun b dvd dvd2 => by 
    rcases dvd2 with ⟨k, rfl⟩
    rcases dvd with ⟨k2, pr⟩
    have k2_nonzero : k2 ≠ 0 := fun k2_zero => by simpa [k2_zero] using pr
    rw [Nat.mul_div_cancel_left k (Nat.pos_of_ne_zero a_split), pr,
      Nat.mul_div_cancel_left k2 (Nat.pos_of_ne_zero c_split), Nat.mul_comm ((c + 1) * k2) k, ←
      Nat.mul_assoc k (c + 1) k2, Nat.mul_div_cancel _ (Nat.pos_of_ne_zero k2_nonzero),
      Nat.mul_div_cancel _ (Nat.pos_of_ne_zero c_split)]
#align nat.div_div_div_eq_div Nat.div_div_div_eq_div
-/

#print Nat.eq_zero_of_dvd_of_lt /-
/-- If a small natural number is divisible by a larger natural number,
the small number is zero. -/
theorem eq_zero_of_dvd_of_lt {a b : ℕ} (w : a ∣ b) (h : b < a) : b = 0 :=
  Nat.eq_zero_of_dvd_of_div_eq_zero w
    ((Nat.div_eq_zero_iff (lt_of_le_of_lt (zero_le b) h)).elimRight h)
#align nat.eq_zero_of_dvd_of_lt Nat.eq_zero_of_dvd_of_lt
-/

#print Nat.mod_div_self /-
@[simp]
theorem mod_div_self (m n : ℕ) : m % n / n = 0 := by
  cases n
  · exact (m % 0).div_zero
  · exact Nat.div_eq_zero (m.mod_lt n.succ_pos)
#align nat.mod_div_self Nat.mod_div_self
-/

#print Nat.not_dvd_iff_between_consec_multiples /-
/-- `n` is not divisible by `a` iff it is between `a * k` and `a * (k + 1)` for some `k`. -/
theorem not_dvd_iff_between_consec_multiples (n : ℕ) {a : ℕ} (ha : 0 < a) :
    (∃ k : ℕ, a * k < n ∧ n < a * (k + 1)) ↔ ¬a ∣ n := by
  refine'
    ⟨fun ⟨k, hk1, hk2⟩ => not_dvd_of_between_consec_multiples hk1 hk2, fun han =>
      ⟨n / a, ⟨lt_of_le_of_ne (mul_div_le n a) _, lt_mul_div_succ _ ha⟩⟩⟩
  exact mt (Dvd.intro (n / a)) han
#align nat.not_dvd_iff_between_consec_multiples Nat.not_dvd_iff_between_consec_multiples
-/

#print Nat.dvd_right_iff_eq /-
/-- Two natural numbers are equal if and only if they have the same multiples. -/
theorem dvd_right_iff_eq {m n : ℕ} : (∀ a : ℕ, m ∣ a ↔ n ∣ a) ↔ m = n :=
  ⟨fun h => dvd_antisymm ((h _).mpr dvd_rfl) ((h _).mp dvd_rfl), fun h n => by rw [h]⟩
#align nat.dvd_right_iff_eq Nat.dvd_right_iff_eq
-/

#print Nat.dvd_left_iff_eq /-
/-- Two natural numbers are equal if and only if they have the same divisors. -/
theorem dvd_left_iff_eq {m n : ℕ} : (∀ a : ℕ, a ∣ m ↔ a ∣ n) ↔ m = n :=
  ⟨fun h => dvd_antisymm ((h _).mp dvd_rfl) ((h _).mpr dvd_rfl), fun h n => by rw [h]⟩
#align nat.dvd_left_iff_eq Nat.dvd_left_iff_eq
-/

#print Nat.dvd_left_injective /-
/-- `dvd` is injective in the left argument -/
theorem dvd_left_injective : Function.Injective ((· ∣ ·) : ℕ → ℕ → Prop) := fun m n h =>
  dvd_right_iff_eq.mp fun a => iff_of_eq (congr_fun h a)
#align nat.dvd_left_injective Nat.dvd_left_injective
-/

#print Nat.div_lt_div_of_lt_of_dvd /-
theorem div_lt_div_of_lt_of_dvd {a b d : ℕ} (hdb : d ∣ b) (h : a < b) : a / d < b / d := by
  rw [Nat.lt_div_iff_mul_lt hdb]
  exact lt_of_le_of_lt (mul_div_le a d) h
#align nat.div_lt_div_of_lt_of_dvd Nat.div_lt_div_of_lt_of_dvd
-/

end Nat

