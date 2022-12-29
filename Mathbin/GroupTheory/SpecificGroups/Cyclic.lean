/-
Copyright (c) 2018 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module group_theory.specific_groups.cyclic
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Order
import Mathbin.Data.Nat.Totient
import Mathbin.GroupTheory.OrderOfElement
import Mathbin.Tactic.Group
import Mathbin.GroupTheory.Exponent

/-!
# Cyclic groups

A group `G` is called cyclic if there exists an element `g : G` such that every element of `G` is of
the form `g ^ n` for some `n : ℕ`. This file only deals with the predicate on a group to be cyclic.
For the concrete cyclic group of order `n`, see `data.zmod.basic`.

## Main definitions

* `is_cyclic` is a predicate on a group stating that the group is cyclic.

## Main statements

* `is_cyclic_of_prime_card` proves that a finite group of prime order is cyclic.
* `is_simple_group_of_prime_card`, `is_simple_group.is_cyclic`,
  and `is_simple_group.prime_card` classify finite simple abelian groups.
* `is_cyclic.exponent_eq_card`: For a finite cyclic group `G`, the exponent is equal to
  the group's cardinality.
* `is_cyclic.exponent_eq_zero_of_infinite`: Infinite cyclic groups have exponent zero.
* `is_cyclic.iff_exponent_eq_card`: A finite commutative group is cyclic iff its exponent
  is equal to its cardinality.

## Tags

cyclic group
-/


universe u

variable {α : Type u} {a : α}

section Cyclic

open BigOperators

attribute [local instance] setFintype

open Subgroup

/- ./././Mathport/Syntax/Translate/Command.lean:379:30: infer kinds are unsupported in Lean 4: #[`exists_generator] [] -/
/-- A group is called *cyclic* if it is generated by a single element. -/
class IsAddCyclic (α : Type u) [AddGroup α] : Prop where
  exists_generator : ∃ g : α, ∀ x, x ∈ AddSubgroup.zmultiples g
#align is_add_cyclic IsAddCyclic

/- ./././Mathport/Syntax/Translate/Command.lean:379:30: infer kinds are unsupported in Lean 4: #[`exists_generator] [] -/
/-- A group is called *cyclic* if it is generated by a single element. -/
@[to_additive IsAddCyclic]
class IsCyclic (α : Type u) [Group α] : Prop where
  exists_generator : ∃ g : α, ∀ x, x ∈ zpowers g
#align is_cyclic IsCyclic

@[to_additive is_add_cyclic_of_subsingleton]
instance (priority := 100) is_cyclic_of_subsingleton [Group α] [Subsingleton α] : IsCyclic α :=
  ⟨⟨1, fun x => by
      rw [Subsingleton.elim x 1]
      exact mem_zpowers 1⟩⟩
#align is_cyclic_of_subsingleton is_cyclic_of_subsingleton

/-- A cyclic group is always commutative. This is not an `instance` because often we have a better
proof of `comm_group`. -/
@[to_additive
      "A cyclic group is always commutative. This is not an `instance` because often we have\n  a better proof of `add_comm_group`."]
def IsCyclic.commGroup [hg : Group α] [IsCyclic α] : CommGroup α :=
  { hg with
    mul_comm := fun x y =>
      let ⟨g, hg⟩ := IsCyclic.exists_generator α
      let ⟨n, hn⟩ := hg x
      let ⟨m, hm⟩ := hg y
      hm ▸ hn ▸ zpow_mul_comm _ _ _ }
#align is_cyclic.comm_group IsCyclic.commGroup

variable [Group α]

@[to_additive MonoidAddHom.map_add_cyclic]
theorem MonoidHom.map_cyclic {G : Type _} [Group G] [h : IsCyclic G] (σ : G →* G) :
    ∃ m : ℤ, ∀ g : G, σ g = g ^ m :=
  by
  obtain ⟨h, hG⟩ := IsCyclic.exists_generator G
  obtain ⟨m, hm⟩ := hG (σ h)
  refine' ⟨m, fun g => _⟩
  obtain ⟨n, rfl⟩ := hG g
  rw [MonoidHom.map_zpow, ← hm, ← zpow_mul, ← zpow_mul']
#align monoid_hom.map_cyclic MonoidHom.map_cyclic

@[to_additive is_add_cyclic_of_order_of_eq_card]
theorem is_cyclic_of_order_of_eq_card [Fintype α] (x : α) (hx : orderOf x = Fintype.card α) :
    IsCyclic α := by
  classical
    use x
    simp_rw [← SetLike.mem_coe, ← Set.eq_univ_iff_forall]
    rw [← Fintype.card_congr (Equiv.Set.univ α), order_eq_card_zpowers] at hx
    exact Set.eq_of_subset_of_card_le (Set.subset_univ _) (ge_of_eq hx)
#align is_cyclic_of_order_of_eq_card is_cyclic_of_order_of_eq_card

/-- A finite group of prime order is cyclic. -/
@[to_additive is_add_cyclic_of_prime_card "A finite group of prime order is cyclic."]
theorem is_cyclic_of_prime_card {α : Type u} [Group α] [Fintype α] {p : ℕ} [hp : Fact p.Prime]
    (h : Fintype.card α = p) : IsCyclic α :=
  ⟨by
    obtain ⟨g, hg⟩ : ∃ g : α, g ≠ 1 := Fintype.exists_ne_of_one_lt_card (h.symm ▸ hp.1.one_lt) 1
    classical
      -- for fintype (subgroup.zpowers g)
      have : Fintype.card (Subgroup.zpowers g) ∣ p :=
        by
        rw [← h]
        apply card_subgroup_dvd_card
      rw [Nat.dvd_prime hp.1] at this
      cases this
      · rw [Fintype.card_eq_one_iff] at this
        cases' this with t ht
        suffices g = 1 by contradiction
        have hgt :=
          ht
            ⟨g, by
              change g ∈ Subgroup.zpowers g
              exact Subgroup.mem_zpowers g⟩
        rw [← ht 1] at hgt
        change (⟨_, _⟩ : Subgroup.zpowers g) = ⟨_, _⟩ at hgt
        simpa using hgt
      · use g
        intro x
        rw [← h] at this
        rw [Subgroup.eq_top_of_card_eq _ this]
        exact Subgroup.mem_top _⟩
#align is_cyclic_of_prime_card is_cyclic_of_prime_card

@[to_additive add_order_of_eq_card_of_forall_mem_zmultiples]
theorem order_of_eq_card_of_forall_mem_zpowers [Fintype α] {g : α} (hx : ∀ x, x ∈ zpowers g) :
    orderOf g = Fintype.card α := by
  classical
    rw [order_eq_card_zpowers]
    apply Fintype.card_of_finset'
    simpa using hx
#align order_of_eq_card_of_forall_mem_zpowers order_of_eq_card_of_forall_mem_zpowers

@[to_additive Infinite.add_order_of_eq_zero_of_forall_mem_zmultiples]
theorem Infinite.order_of_eq_zero_of_forall_mem_zpowers [Infinite α] {g : α}
    (h : ∀ x, x ∈ zpowers g) : orderOf g = 0 := by
  classical
    rw [order_of_eq_zero_iff']
    refine' fun n hn hgn => _
    have ho := order_of_pos' ((is_of_fin_order_iff_pow_eq_one g).mpr ⟨n, hn, hgn⟩)
    obtain ⟨x, hx⟩ :=
      Infinite.exists_not_mem_finset (Finset.image (pow g) <| Finset.range <| orderOf g)
    apply hx
    rw [← mem_powers_iff_mem_range_order_of' g x ho, Submonoid.mem_powers_iff]
    obtain ⟨k, hk⟩ := h x
    obtain ⟨k, rfl | rfl⟩ := k.eq_coe_or_neg
    · exact ⟨k, by exact_mod_cast hk⟩
    let t : ℤ := -k % orderOf g
    rw [zpow_eq_mod_order_of] at hk
    have : 0 ≤ t := Int.emod_nonneg (-k) (by exact_mod_cast ho.ne')
    refine' ⟨t.to_nat, _⟩
    rwa [← zpow_ofNat, Int.toNat_of_nonneg this]
#align
  infinite.order_of_eq_zero_of_forall_mem_zpowers Infinite.order_of_eq_zero_of_forall_mem_zpowers

@[to_additive Bot.is_add_cyclic]
instance Bot.is_cyclic {α : Type u} [Group α] : IsCyclic (⊥ : Subgroup α) :=
  ⟨⟨1, fun x => ⟨0, Subtype.eq <| (zpow_zero (1 : α)).trans <| Eq.symm (Subgroup.mem_bot.1 x.2)⟩⟩⟩
#align bot.is_cyclic Bot.is_cyclic

@[to_additive AddSubgroup.is_add_cyclic]
instance Subgroup.is_cyclic {α : Type u} [Group α] [IsCyclic α] (H : Subgroup α) : IsCyclic H :=
  haveI := Classical.propDecidable
  let ⟨g, hg⟩ := IsCyclic.exists_generator α
  if hx : ∃ x : α, x ∈ H ∧ x ≠ (1 : α) then
    let ⟨x, hx₁, hx₂⟩ := hx
    let ⟨k, hk⟩ := hg x
    have hex : ∃ n : ℕ, 0 < n ∧ g ^ n ∈ H :=
      ⟨k.natAbs,
        Nat.pos_of_ne_zero fun h => hx₂ <| by rw [← hk, Int.eq_zero_of_natAbs_eq_zero h, zpow_zero],
        match k, hk with
        | (k : ℕ), hk => by rw [Int.natAbs_ofNat, ← zpow_ofNat, hk] <;> exact hx₁
        | -[k+1], hk => by
          rw [Int.nat_abs_of_neg_succ_of_nat, ← Subgroup.inv_mem_iff H] <;> simp_all⟩
    ⟨⟨⟨g ^ Nat.find hex, (Nat.find_spec hex).2⟩, fun ⟨x, hx⟩ =>
        let ⟨k, hk⟩ := hg x
        have hk₁ : g ^ ((Nat.find hex : ℤ) * (k / Nat.find hex)) ∈ zpowers (g ^ Nat.find hex) :=
          ⟨k / Nat.find hex, by rw [← zpow_ofNat, zpow_mul]⟩
        have hk₂ : g ^ ((Nat.find hex : ℤ) * (k / Nat.find hex)) ∈ H :=
          by
          rw [zpow_mul]
          apply H.zpow_mem
          exact_mod_cast (Nat.find_spec hex).2
        have hk₃ : g ^ (k % Nat.find hex) ∈ H :=
          (Subgroup.mul_mem_cancel_right H hk₂).1 <| by
            rw [← zpow_add, Int.mod_add_div, hk] <;> exact hx
        have hk₄ : k % Nat.find hex = (k % Nat.find hex).natAbs := by
          rw [Int.natAbs_of_nonneg
              (Int.emod_nonneg _ (Int.coe_nat_ne_zero_iff_pos.2 (Nat.find_spec hex).1))]
        have hk₅ : g ^ (k % Nat.find hex).natAbs ∈ H := by rwa [← zpow_ofNat, ← hk₄]
        have hk₆ : (k % (Nat.find hex : ℤ)).natAbs = 0 :=
          by_contradiction fun h =>
            Nat.find_min hex
              (Int.ofNat_lt.1 <| by
                rw [← hk₄] <;> exact Int.emod_lt_of_pos _ (Int.coe_nat_pos.2 (Nat.find_spec hex).1))
              ⟨Nat.pos_of_ne_zero h, hk₅⟩
        ⟨k / (Nat.find hex : ℤ),
          Subtype.ext_iff_val.2
            (by
              suffices g ^ ((Nat.find hex : ℤ) * (k / Nat.find hex)) = x by simpa [zpow_mul]
              rw [Int.mul_ediv_cancel'
                  (Int.dvd_of_emod_eq_zero (Int.eq_zero_of_natAbs_eq_zero hk₆)),
                hk])⟩⟩⟩
  else
    by
    have : H = (⊥ : Subgroup α) :=
      Subgroup.ext fun x =>
        ⟨fun h => by simp at * <;> tauto, fun h => by rw [Subgroup.mem_bot.1 h] <;> exact H.one_mem⟩
    clear _let_match <;> subst this <;> infer_instance
#align subgroup.is_cyclic Subgroup.is_cyclic

open Finset Nat

section Classical

open Classical

/- ./././Mathport/Syntax/Translate/Tactic/Lean3.lean:132:4: warning: unsupported: rw with cfg: { occs := occurrences.pos[occurrences.pos] «expr[ ,]»([2, 3]) } -/
@[to_additive IsAddCyclic.card_pow_eq_one_le]
theorem IsCyclic.card_pow_eq_one_le [DecidableEq α] [Fintype α] [IsCyclic α] {n : ℕ} (hn0 : 0 < n) :
    (univ.filter fun a : α => a ^ n = 1).card ≤ n :=
  let ⟨g, hg⟩ := IsCyclic.exists_generator α
  calc
    (univ.filter fun a : α => a ^ n = 1).card ≤
        (zpowers (g ^ (Fintype.card α / Nat.gcd n (Fintype.card α))) : Set α).toFinset.card :=
      card_le_of_subset fun x hx =>
        let ⟨m, hm⟩ := show x ∈ Submonoid.powers g from mem_powers_iff_mem_zpowers.2 <| hg x
        Set.mem_to_finset.2
          ⟨(m / (Fintype.card α / Nat.gcd n (Fintype.card α)) : ℕ),
            by
            have hgmn : g ^ (m * Nat.gcd n (Fintype.card α)) = 1 := by
              rw [pow_mul, hm, ← pow_gcd_card_eq_one_iff] <;> exact (mem_filter.1 hx).2
            rw [zpow_ofNat, ← pow_mul, Nat.mul_div_cancel_left', hm]
            refine' dvd_of_mul_dvd_mul_right (gcd_pos_of_pos_left (Fintype.card α) hn0) _
            conv_lhs =>
              rw [Nat.div_mul_cancel (Nat.gcd_dvd_right _ _), ←
                order_of_eq_card_of_forall_mem_zpowers hg]
            exact order_of_dvd_of_pow_eq_one hgmn⟩
    _ ≤ n := by
      let ⟨m, hm⟩ := Nat.gcd_dvd_right n (Fintype.card α)
      have hm0 : 0 < m :=
        Nat.pos_of_ne_zero fun hm0 =>
          by
          rw [hm0, mul_zero, Fintype.card_eq_zero_iff] at hm
          exact hm.elim' 1
      simp only [Set.to_finset_card, SetLike.coe_sort_coe]
      rw [← order_eq_card_zpowers, order_of_pow g, order_of_eq_card_of_forall_mem_zpowers hg]
      rw [hm]
      rw [Nat.mul_div_cancel_left _ (gcd_pos_of_pos_left _ hn0), gcd_mul_left_left, hm,
        Nat.mul_div_cancel _ hm0]
      exact le_of_dvd hn0 (Nat.gcd_dvd_left _ _)
    
#align is_cyclic.card_pow_eq_one_le IsCyclic.card_pow_eq_one_le

end Classical

@[to_additive]
theorem IsCyclic.exists_monoid_generator [Finite α] [IsCyclic α] :
    ∃ x : α, ∀ y : α, y ∈ Submonoid.powers x :=
  by
  simp_rw [mem_powers_iff_mem_zpowers]
  exact IsCyclic.exists_generator α
#align is_cyclic.exists_monoid_generator IsCyclic.exists_monoid_generator

section

variable [DecidableEq α] [Fintype α]

@[to_additive]
theorem IsCyclic.image_range_order_of (ha : ∀ x : α, x ∈ zpowers a) :
    Finset.image (fun i => a ^ i) (range (orderOf a)) = univ :=
  by
  simp_rw [← SetLike.mem_coe] at ha
  simp only [image_range_order_of, set.eq_univ_iff_forall.mpr ha, Set.to_finset_univ]
#align is_cyclic.image_range_order_of IsCyclic.image_range_order_of

@[to_additive]
theorem IsCyclic.image_range_card (ha : ∀ x : α, x ∈ zpowers a) :
    Finset.image (fun i => a ^ i) (range (Fintype.card α)) = univ := by
  rw [← order_of_eq_card_of_forall_mem_zpowers ha, IsCyclic.image_range_order_of ha]
#align is_cyclic.image_range_card IsCyclic.image_range_card

end

section Totient

variable [DecidableEq α] [Fintype α]
  (hn : ∀ n : ℕ, 0 < n → (univ.filter fun a : α => a ^ n = 1).card ≤ n)

include hn

private theorem card_pow_eq_one_eq_order_of_aux (a : α) :
    (Finset.univ.filter fun b : α => b ^ orderOf a = 1).card = orderOf a :=
  le_antisymm (hn _ (order_of_pos a))
    (calc
      orderOf a = @Fintype.card (zpowers a) (id _) := order_eq_card_zpowers
      _ ≤
          @Fintype.card (↑(univ.filter fun b : α => b ^ orderOf a = 1) : Set α)
            (Fintype.ofFinset _ fun _ => Iff.rfl) :=
        @Fintype.card_le_of_injective (zpowers a)
          (↑(univ.filter fun b : α => b ^ orderOf a = 1) : Set α) (id _) (id _)
          (fun b =>
            ⟨b.1,
              mem_filter.2
                ⟨mem_univ _, by
                  let ⟨i, hi⟩ := b.2
                  rw [← hi, ← zpow_ofNat, ← zpow_mul, mul_comm, zpow_mul, zpow_ofNat,
                    pow_order_of_eq_one, one_zpow]⟩⟩)
          fun _ _ h => Subtype.eq (Subtype.mk.inj h)
      _ = (univ.filter fun b : α => b ^ orderOf a = 1).card := Fintype.card_of_finset _ _
      )
#align card_pow_eq_one_eq_order_of_aux card_pow_eq_one_eq_order_of_aux

open Nat

-- use φ for nat.totient
private theorem card_order_of_eq_totient_aux₁ :
    ∀ {d : ℕ},
      d ∣ Fintype.card α →
        0 < (univ.filter fun a : α => orderOf a = d).card →
          (univ.filter fun a : α => orderOf a = d).card = φ d :=
  by
  intro d hd hd0
  induction' d using Nat.strongRec' with d IH
  rcases d.eq_zero_or_pos with (rfl | hd_pos)
  · cases Fintype.card_ne_zero (eq_zero_of_zero_dvd hd)
  rcases card_pos.1 hd0 with ⟨a, ha'⟩
  have ha : orderOf a = d := (mem_filter.1 ha').2
  have h1 :
    (∑ m in d.proper_divisors, (univ.filter fun a : α => orderOf a = m).card) =
      ∑ m in d.proper_divisors, φ m :=
    by
    refine' Finset.sum_congr rfl fun m hm => _
    simp only [mem_filter, mem_range, mem_proper_divisors] at hm
    refine' IH m hm.2 (hm.1.trans hd) (Finset.card_pos.2 ⟨a ^ (d / m), _⟩)
    simp only [mem_filter, mem_univ, order_of_pow a, ha, true_and_iff,
      Nat.gcd_eq_right (div_dvd_of_dvd hm.1), Nat.div_div_self hm.1 hd_pos.ne']
  have h2 :
    (∑ m in d.divisors, (univ.filter fun a : α => orderOf a = m).card) = ∑ m in d.divisors, φ m :=
    by
    rw [← filter_dvd_eq_divisors hd_pos.ne', sum_card_order_of_eq_card_pow_eq_one hd_pos,
      filter_dvd_eq_divisors hd_pos.ne', sum_totient, ← ha, card_pow_eq_one_eq_order_of_aux hn a]
  simpa [divisors_eq_proper_divisors_insert_self_of_pos hd_pos, ← h1] using h2
#align card_order_of_eq_totient_aux₁ card_order_of_eq_totient_aux₁

theorem card_order_of_eq_totient_aux₂ {d : ℕ} (hd : d ∣ Fintype.card α) :
    (univ.filter fun a : α => orderOf a = d).card = φ d :=
  by
  let c := Fintype.card α
  have hc0 : 0 < c := Fintype.card_pos_iff.2 ⟨1⟩
  apply card_order_of_eq_totient_aux₁ hn hd
  by_contra h0
  simp only [not_lt, _root_.le_zero_iff, card_eq_zero] at h0
  apply lt_irrefl c
  calc
    c = ∑ m in c.divisors, (univ.filter fun a : α => orderOf a = m).card :=
      by
      simp only [← filter_dvd_eq_divisors hc0.ne', sum_card_order_of_eq_card_pow_eq_one hc0]
      apply congr_arg card
      simp
    _ = ∑ m in c.divisors.erase d, (univ.filter fun a : α => orderOf a = m).card :=
      by
      rw [eq_comm]
      refine' sum_subset (erase_subset _ _) fun m hm₁ hm₂ => _
      have : m = d := by
        contrapose! hm₂
        exact mem_erase_of_ne_of_mem hm₂ hm₁
      simp [this, h0]
    _ ≤ ∑ m in c.divisors.erase d, φ m :=
      by
      refine' sum_le_sum fun m hm => _
      have hmc : m ∣ c := by
        simp only [mem_erase, mem_divisors] at hm
        tauto
      rcases(filter (fun a : α => orderOf a = m) univ).card.eq_zero_or_pos with (h1 | h1)
      · simp [h1]
      · simp [card_order_of_eq_totient_aux₁ hn hmc h1]
    _ < ∑ m in c.divisors, φ m :=
      sum_erase_lt_of_pos (mem_divisors.2 ⟨hd, hc0.ne'⟩) (totient_pos (pos_of_dvd_of_pos hd hc0))
    _ = c := sum_totient _
    
#align card_order_of_eq_totient_aux₂ card_order_of_eq_totient_aux₂

theorem is_cyclic_of_card_pow_eq_one_le : IsCyclic α :=
  have : (univ.filter fun a : α => orderOf a = Fintype.card α).Nonempty :=
    card_pos.1 <| by
      rw [card_order_of_eq_totient_aux₂ hn dvd_rfl] <;>
        exact totient_pos (Fintype.card_pos_iff.2 ⟨1⟩)
  let ⟨x, hx⟩ := this
  is_cyclic_of_order_of_eq_card x (Finset.mem_filter.1 hx).2
#align is_cyclic_of_card_pow_eq_one_le is_cyclic_of_card_pow_eq_one_le

theorem is_add_cyclic_of_card_pow_eq_one_le {α} [AddGroup α] [DecidableEq α] [Fintype α]
    (hn : ∀ n : ℕ, 0 < n → (univ.filter fun a : α => n • a = 0).card ≤ n) : IsAddCyclic α :=
  by
  obtain ⟨g, hg⟩ := @is_cyclic_of_card_pow_eq_one_le (Multiplicative α) _ _ _ hn
  exact ⟨⟨g, hg⟩⟩
#align is_add_cyclic_of_card_pow_eq_one_le is_add_cyclic_of_card_pow_eq_one_le

attribute [to_additive is_cyclic_of_card_pow_eq_one_le] is_add_cyclic_of_card_pow_eq_one_le

end Totient

theorem IsCyclic.card_order_of_eq_totient [IsCyclic α] [Fintype α] {d : ℕ}
    (hd : d ∣ Fintype.card α) : (univ.filter fun a : α => orderOf a = d).card = totient d := by
  classical apply card_order_of_eq_totient_aux₂ (fun n => IsCyclic.card_pow_eq_one_le) hd
#align is_cyclic.card_order_of_eq_totient IsCyclic.card_order_of_eq_totient

theorem IsAddCyclic.card_order_of_eq_totient {α} [AddGroup α] [IsAddCyclic α] [Fintype α] {d : ℕ}
    (hd : d ∣ Fintype.card α) : (univ.filter fun a : α => addOrderOf a = d).card = totient d :=
  by
  obtain ⟨g, hg⟩ := id ‹IsAddCyclic α›
  exact @IsCyclic.card_order_of_eq_totient (Multiplicative α) _ ⟨⟨g, hg⟩⟩ _ _ hd
#align is_add_cyclic.card_order_of_eq_totient IsAddCyclic.card_order_of_eq_totient

attribute [to_additive IsCyclic.card_order_of_eq_totient] IsAddCyclic.card_order_of_eq_totient

/-- A finite group of prime order is simple. -/
@[to_additive "A finite group of prime order is simple."]
theorem is_simple_group_of_prime_card {α : Type u} [Group α] [Fintype α] {p : ℕ} [hp : Fact p.Prime]
    (h : Fintype.card α = p) : IsSimpleGroup α :=
  ⟨by
    have h' := Nat.Prime.one_lt (Fact.out p.prime)
    rw [← h] at h'
    haveI := Fintype.one_lt_card_iff_nontrivial.1 h'
    apply exists_pair_ne α, fun H Hn => by
    classical
      have hcard := card_subgroup_dvd_card H
      rw [h, dvd_prime (Fact.out p.prime)] at hcard
      refine' hcard.imp (fun h1 => _) fun hp => _
      · haveI := Fintype.card_le_one_iff_subsingleton.1 (le_of_eq h1)
        apply eq_bot_of_subsingleton
      · exact eq_top_of_card_eq _ (hp.trans h.symm)⟩
#align is_simple_group_of_prime_card is_simple_group_of_prime_card

end Cyclic

section QuotientCenter

open Subgroup

variable {G : Type _} {H : Type _} [Group G] [Group H]

/-- A group is commutative if the quotient by the center is cyclic.
  Also see `comm_group_of_cycle_center_quotient` for the `comm_group` instance. -/
@[to_additive commutative_of_add_cyclic_center_quotient
      "A group is commutative if the quotient by\n  the center is cyclic. Also see `add_comm_group_of_cycle_center_quotient`\n  for the `add_comm_group` instance."]
theorem commutative_of_cyclic_center_quotient [IsCyclic H] (f : G →* H) (hf : f.ker ≤ center G)
    (a b : G) : a * b = b * a :=
  let ⟨⟨x, y, (hxy : f y = x)⟩, (hx : ∀ a : f, a ∈ zpowers _)⟩ := IsCyclic.exists_generator f.range
  let ⟨m, hm⟩ := hx ⟨f a, a, rfl⟩
  let ⟨n, hn⟩ := hx ⟨f b, b, rfl⟩
  have hm : x ^ m = f a := by simpa [Subtype.ext_iff] using hm
  have hn : x ^ n = f b := by simpa [Subtype.ext_iff] using hn
  have ha : y ^ (-m) * a ∈ center G :=
    hf (by rw [f.mem_ker, f.map_mul, f.map_zpow, hxy, zpow_neg, hm, inv_mul_self])
  have hb : y ^ (-n) * b ∈ center G :=
    hf (by rw [f.mem_ker, f.map_mul, f.map_zpow, hxy, zpow_neg, hn, inv_mul_self])
  calc
    a * b = y ^ m * (y ^ (-m) * a * y ^ n) * (y ^ (-n) * b) := by simp [mul_assoc]
    _ = y ^ m * (y ^ n * (y ^ (-m) * a)) * (y ^ (-n) * b) := by rw [mem_center_iff.1 ha]
    _ = y ^ m * y ^ n * y ^ (-m) * (a * (y ^ (-n) * b)) := by simp [mul_assoc]
    _ = y ^ m * y ^ n * y ^ (-m) * (y ^ (-n) * b * a) := by rw [mem_center_iff.1 hb]
    _ = b * a := by group
    
#align commutative_of_cyclic_center_quotient commutative_of_cyclic_center_quotient

/-- A group is commutative if the quotient by the center is cyclic. -/
@[to_additive commutativeOfAddCycleCenterQuotient
      "A group is commutative if the quotient by\n  the center is cyclic."]
def commGroupOfCycleCenterQuotient [IsCyclic H] (f : G →* H) (hf : f.ker ≤ center G) :
    CommGroup G :=
  { show Group G by infer_instance with mul_comm := commutative_of_cyclic_center_quotient f hf }
#align comm_group_of_cycle_center_quotient commGroupOfCycleCenterQuotient

end QuotientCenter

namespace IsSimpleGroup

section CommGroup

variable [CommGroup α] [IsSimpleGroup α]

@[to_additive IsSimpleAddGroup.is_add_cyclic]
instance (priority := 100) : IsCyclic α :=
  by
  cases' subsingleton_or_nontrivial α with hi hi <;> haveI := hi
  · apply is_cyclic_of_subsingleton
  · obtain ⟨g, hg⟩ := exists_ne (1 : α)
    refine' ⟨⟨g, fun x => _⟩⟩
    cases' IsSimpleOrder.eq_bot_or_eq_top (Subgroup.zpowers g) with hb ht
    · exfalso
      apply hg
      rw [← Subgroup.mem_bot, ← hb]
      apply Subgroup.mem_zpowers
    · rw [ht]
      apply Subgroup.mem_top

@[to_additive]
theorem prime_card [Fintype α] : (Fintype.card α).Prime :=
  by
  have h0 : 0 < Fintype.card α := Fintype.card_pos_iff.2 (by infer_instance)
  obtain ⟨g, hg⟩ := IsCyclic.exists_generator α
  rw [Nat.prime_def_lt'']
  refine' ⟨Fintype.one_lt_card_iff_nontrivial.2 inferInstance, fun n hn => _⟩
  refine' (IsSimpleOrder.eq_bot_or_eq_top (Subgroup.zpowers (g ^ n))).symm.imp _ _
  · intro h
    have hgo := order_of_pow g
    rw [order_of_eq_card_of_forall_mem_zpowers hg, Nat.gcd_eq_right_iff_dvd.1 hn,
      order_of_eq_card_of_forall_mem_zpowers, eq_comm,
      Nat.div_eq_iff_eq_mul_left (Nat.pos_of_dvd_of_pos hn h0) hn] at hgo
    · exact (mul_left_cancel₀ (ne_of_gt h0) ((mul_one (Fintype.card α)).trans hgo)).symm
    · intro x
      rw [h]
      exact Subgroup.mem_top _
  · intro h
    apply le_antisymm (Nat.le_of_dvd h0 hn)
    rw [← order_of_eq_card_of_forall_mem_zpowers hg]
    apply order_of_le_of_pow_eq_one (Nat.pos_of_dvd_of_pos hn h0)
    rw [← Subgroup.mem_bot, ← h]
    exact Subgroup.mem_zpowers _
#align is_simple_group.prime_card IsSimpleGroup.prime_card

end CommGroup

end IsSimpleGroup

@[to_additive AddCommGroup.is_simple_iff_is_add_cyclic_and_prime_card]
theorem CommGroup.is_simple_iff_is_cyclic_and_prime_card [Fintype α] [CommGroup α] :
    IsSimpleGroup α ↔ IsCyclic α ∧ (Fintype.card α).Prime :=
  by
  constructor
  · intro h
    exact ⟨IsSimpleGroup.is_cyclic, IsSimpleGroup.prime_card⟩
  · rintro ⟨hc, hp⟩
    haveI : Fact (Fintype.card α).Prime := ⟨hp⟩
    exact is_simple_group_of_prime_card rfl
#align
  comm_group.is_simple_iff_is_cyclic_and_prime_card CommGroup.is_simple_iff_is_cyclic_and_prime_card

section Exponent

open Monoid

@[to_additive]
theorem IsCyclic.exponent_eq_card [Group α] [IsCyclic α] [Fintype α] :
    exponent α = Fintype.card α :=
  by
  obtain ⟨g, hg⟩ := IsCyclic.exists_generator α
  apply Nat.dvd_antisymm
  · rw [← lcm_order_eq_exponent, Finset.lcm_dvd_iff]
    exact fun b _ => order_of_dvd_card_univ
  rw [← order_of_eq_card_of_forall_mem_zpowers hg]
  exact order_dvd_exponent _
#align is_cyclic.exponent_eq_card IsCyclic.exponent_eq_card

@[to_additive]
theorem IsCyclic.of_exponent_eq_card [CommGroup α] [Fintype α] (h : exponent α = Fintype.card α) :
    IsCyclic α :=
  let ⟨g, _, hg⟩ := Finset.mem_image.mp (Finset.max'_mem _ _)
  is_cyclic_of_order_of_eq_card g <| hg.trans <| exponent_eq_max'_order_of.symm.trans h
#align is_cyclic.of_exponent_eq_card IsCyclic.of_exponent_eq_card

@[to_additive]
theorem IsCyclic.iff_exponent_eq_card [CommGroup α] [Fintype α] :
    IsCyclic α ↔ exponent α = Fintype.card α :=
  ⟨fun h => IsCyclic.exponent_eq_card, IsCyclic.of_exponent_eq_card⟩
#align is_cyclic.iff_exponent_eq_card IsCyclic.iff_exponent_eq_card

@[to_additive]
theorem IsCyclic.exponent_eq_zero_of_infinite [Group α] [IsCyclic α] [Infinite α] :
    exponent α = 0 :=
  let ⟨g, hg⟩ := IsCyclic.exists_generator α
  exponent_eq_zero_of_order_zero <| Infinite.order_of_eq_zero_of_forall_mem_zpowers hg
#align is_cyclic.exponent_eq_zero_of_infinite IsCyclic.exponent_eq_zero_of_infinite

end Exponent

