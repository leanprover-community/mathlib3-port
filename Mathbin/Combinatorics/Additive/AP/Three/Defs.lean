/-
Copyright (c) 2021 Yaël Dillies, Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Bhavik Mehta
-/
import Combinatorics.Additive.FreimanHom
import Analysis.Asymptotics.Asymptotics
import Analysis.Convex.StrictConvexSpace

#align_import combinatorics.additive.salem_spencer from "leanprover-community/mathlib"@"1b0a28e1c93409dbf6d69526863cd9984ef652ce"

/-!
# Salem-Spencer sets and Roth numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines Salem-Spencer sets and the Roth number of a set.

A Salem-Spencer set is a set without arithmetic progressions of length `3`. Equivalently, the
average of any two distinct elements is not in the set.

The Roth number of a finset is the size of its biggest Salem-Spencer subset. This is a more general
definition than the one often found in mathematical litterature, where the `n`-th Roth number is
the size of the biggest Salem-Spencer subset of `{0, ..., n - 1}`.

## Main declarations

* `mul_salem_spencer`: Predicate for a set to be multiplicative Salem-Spencer.
* `add_salem_spencer`: Predicate for a set to be additive Salem-Spencer.
* `mul_roth_number`: The multiplicative Roth number of a finset.
* `add_roth_number`: The additive Roth number of a finset.
* `roth_number_nat`: The Roth number of a natural. This corresponds to
  `add_roth_number (finset.range n)`.

## TODO

* Can `add_salem_spencer_iff_eq_right` be made more general?
* Generalize `mul_salem_spencer.image` to Freiman homs

## Tags

Salem-Spencer, Roth, arithmetic progression, average, three-free
-/


open Finset Function Metric Nat

open scoped Pointwise

variable {F α β 𝕜 E : Type _}

section SalemSpencer

open Set

section Monoid

variable [Monoid α] [Monoid β] (s t : Set α)

#print ThreeGPFree /-
/-- A multiplicative Salem-Spencer, aka non averaging, set `s` in a monoid is a set such that the
multiplicative average of any two distinct elements is not in the set. -/
@[to_additive
      "A Salem-Spencer, aka non averaging, set `s` in an additive monoid\nis a set such that the average of any two distinct elements is not in the set."]
def ThreeGPFree : Prop :=
  ∀ ⦃a b c⦄, a ∈ s → b ∈ s → c ∈ s → a * b = c * c → a = b
#align mul_salem_spencer ThreeGPFree
#align add_salem_spencer ThreeAPFree
-/

/-- Whether a given finset is Salem-Spencer is decidable. -/
@[to_additive "Whether a given finset is Salem-Spencer is decidable."]
instance {α : Type _} [DecidableEq α] [Monoid α] {s : Finset α} :
    Decidable (ThreeGPFree (s : Set α)) :=
  decidable_of_iff (∀ a ∈ s, ∀ b ∈ s, ∀ c ∈ s, a * b = c * c → a = b)
    ⟨fun h a b c ha hb hc => h a ha b hb c hc, fun h a ha b hb c hc => h ha hb hc⟩

variable {s t}

#print ThreeGPFree.mono /-
@[to_additive]
theorem ThreeGPFree.mono (h : t ⊆ s) (hs : ThreeGPFree s) : ThreeGPFree t := fun a b c ha hb hc =>
  hs (h ha) (h hb) (h hc)
#align mul_salem_spencer.mono ThreeGPFree.mono
#align add_salem_spencer.mono ThreeAPFree.mono
-/

#print threeGPFree_empty /-
@[simp, to_additive]
theorem threeGPFree_empty : ThreeGPFree (∅ : Set α) := fun a _ _ ha => ha.elim
#align mul_salem_spencer_empty threeGPFree_empty
#align add_salem_spencer_empty threeAPFree_empty
-/

#print Set.Subsingleton.threeGPFree /-
@[to_additive]
theorem Set.Subsingleton.threeGPFree (hs : s.Subsingleton) : ThreeGPFree s := fun a b _ ha hb _ _ =>
  hs ha hb
#align set.subsingleton.mul_salem_spencer Set.Subsingleton.threeGPFree
#align set.subsingleton.add_salem_spencer Set.Subsingleton.threeAPFree
-/

#print threeGPFree_singleton /-
@[simp, to_additive]
theorem threeGPFree_singleton (a : α) : ThreeGPFree ({a} : Set α) :=
  subsingleton_singleton.ThreeGPFree
#align mul_salem_spencer_singleton threeGPFree_singleton
#align add_salem_spencer_singleton threeAPFree_singleton
-/

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ThreeGPFree.prod /-
@[to_additive ThreeAPFree.prod]
theorem ThreeGPFree.prod {t : Set β} (hs : ThreeGPFree s) (ht : ThreeGPFree t) :
    ThreeGPFree (s ×ˢ t) := fun a b c ha hb hc h =>
  Prod.ext (hs ha.1 hb.1 hc.1 (Prod.ext_iff.1 h).1) (ht ha.2 hb.2 hc.2 (Prod.ext_iff.1 h).2)
#align mul_salem_spencer.prod ThreeGPFree.prod
#align add_salem_spencer.prod ThreeAPFree.prod
-/

#print threeGPFree_pi /-
@[to_additive]
theorem threeGPFree_pi {ι : Type _} {α : ι → Type _} [∀ i, Monoid (α i)] {s : ∀ i, Set (α i)}
    (hs : ∀ i, ThreeGPFree (s i)) : ThreeGPFree ((univ : Set ι).pi s) := fun a b c ha hb hc h =>
  funext fun i => hs i (ha i trivial) (hb i trivial) (hc i trivial) <| congr_fun h i
#align mul_salem_spencer_pi threeGPFree_pi
#align add_salem_spencer_pi threeAPFree_pi
-/

end Monoid

section CommMonoid

variable [CommMonoid α] [CommMonoid β] {s : Set α} {a : α}

#print ThreeGPFree.of_image /-
@[to_additive]
theorem ThreeGPFree.of_image [DFunLike F α fun _ => β] [FreimanHomClass F s β 2] (f : F)
    (hf : s.InjOn f) (h : ThreeGPFree (f '' s)) : ThreeGPFree s := fun a b c ha hb hc habc =>
  hf ha hb <|
    h (mem_image_of_mem _ ha) (mem_image_of_mem _ hb) (mem_image_of_mem _ hc) <|
      IsMulFreimanHom.mul_eq_mul f ha hb hc hc habc
#align mul_salem_spencer.of_image ThreeGPFree.of_image
#align add_salem_spencer.of_image ThreeAPFree.of_image
-/

#print ThreeGPFree.image /-
-- TODO: Generalize to Freiman homs
@[to_additive]
theorem ThreeGPFree.image [MulHomClass F α β] (f : F) (hf : (s * s).InjOn f) (h : ThreeGPFree s) :
    ThreeGPFree (f '' s) :=
  by
  rintro _ _ _ ⟨a, ha, rfl⟩ ⟨b, hb, rfl⟩ ⟨c, hc, rfl⟩ habc
  rw [h ha hb hc (hf (mul_mem_mul ha hb) (mul_mem_mul hc hc) <| by rwa [map_mul, map_mul])]
#align mul_salem_spencer.image ThreeGPFree.image
#align add_salem_spencer.image ThreeAPFree.image
-/

end CommMonoid

section CancelCommMonoid

variable [CancelCommMonoid α] {s : Set α} {a : α}

#print threeGPFree_insert /-
@[to_additive]
theorem threeGPFree_insert :
    ThreeGPFree (insert a s) ↔
      ThreeGPFree s ∧
        (∀ ⦃b c⦄, b ∈ s → c ∈ s → a * b = c * c → a = b) ∧
          ∀ ⦃b c⦄, b ∈ s → c ∈ s → b * c = a * a → b = c :=
  by
  refine'
    ⟨fun hs =>
      ⟨hs.mono (subset_insert _ _), fun b c hb hc => hs (Or.inl rfl) (Or.inr hb) (Or.inr hc),
        fun b c hb hc => hs (Or.inr hb) (Or.inr hc) (Or.inl rfl)⟩,
      _⟩
  rintro ⟨hs, ha, ha'⟩ b c d hb hc hd h
  rw [mem_insert_iff] at hb hc hd
  obtain rfl | hb := hb <;> obtain rfl | hc := hc
  · rfl
  all_goals obtain rfl | hd := hd
  · exact (mul_left_cancel h).symm
  · exact ha hc hd h
  · exact mul_right_cancel h
  · exact (ha hb hd <| (mul_comm _ _).trans h).symm
  · exact ha' hb hc h
  · exact hs hb hc hd h
#align mul_salem_spencer_insert threeGPFree_insert
#align add_salem_spencer_insert threeAPFree_insert
-/

@[simp, to_additive]
theorem threeGPFree_pair (a b : α) : ThreeGPFree ({a, b} : Set α) :=
  by
  rw [threeGPFree_insert]
  refine' ⟨threeGPFree_singleton _, _, _⟩
  · rintro c d (rfl : c = b) (rfl : d = c)
    exact mul_right_cancel
  · rintro c d (rfl : c = b) (rfl : d = c) _
    rfl
#align mul_salem_spencer_pair threeGPFree_pair
#align add_salem_spencer_pair add_salem_spencer_pair

#print ThreeGPFree.smul_set /-
@[to_additive]
theorem ThreeGPFree.smul_set (hs : ThreeGPFree s) : ThreeGPFree ((· * ·) a '' s) :=
  by
  rintro _ _ _ ⟨b, hb, rfl⟩ ⟨c, hc, rfl⟩ ⟨d, hd, rfl⟩ h
  rw [mul_mul_mul_comm, mul_mul_mul_comm a d] at h
  rw [hs hb hc hd (mul_left_cancel h)]
#align mul_salem_spencer.mul_left ThreeGPFree.smul_set
#align add_salem_spencer.add_left ThreeAPFree.vadd_set
-/

@[to_additive]
theorem ThreeGPFree.hMul_right (hs : ThreeGPFree s) : ThreeGPFree ((· * a) '' s) :=
  by
  rintro _ _ _ ⟨b, hb, rfl⟩ ⟨c, hc, rfl⟩ ⟨d, hd, rfl⟩ h
  rw [mul_mul_mul_comm, mul_mul_mul_comm d] at h
  rw [hs hb hc hd (mul_right_cancel h)]
#align mul_salem_spencer.mul_right ThreeGPFree.hMul_right
#align add_salem_spencer.add_right ThreeAPFree.add_right

#print threeGPFree_smul_set /-
@[to_additive]
theorem threeGPFree_smul_set : ThreeGPFree ((· * ·) a '' s) ↔ ThreeGPFree s :=
  ⟨fun hs b c d hb hc hd h =>
    mul_left_cancel
      (hs (mem_image_of_mem _ hb) (mem_image_of_mem _ hc) (mem_image_of_mem _ hd) <| by
        rw [mul_mul_mul_comm, h, mul_mul_mul_comm]),
    ThreeGPFree.smul_set⟩
#align mul_salem_spencer_mul_left_iff threeGPFree_smul_set
#align add_salem_spencer_add_left_iff threeAPFree_vadd_set
-/

@[to_additive]
theorem threeGPFree_hMul_right_iff : ThreeGPFree ((· * a) '' s) ↔ ThreeGPFree s :=
  ⟨fun hs b c d hb hc hd h =>
    mul_right_cancel
      (hs (Set.mem_image_of_mem _ hb) (Set.mem_image_of_mem _ hc) (Set.mem_image_of_mem _ hd) <| by
        rw [mul_mul_mul_comm, h, mul_mul_mul_comm]),
    ThreeGPFree.hMul_right⟩
#align mul_salem_spencer_mul_right_iff threeGPFree_hMul_right_iff
#align add_salem_spencer_add_right_iff add_salem_spencer_add_right_iff

end CancelCommMonoid

section OrderedCancelCommMonoid

variable [OrderedCancelCommMonoid α] {s : Set α} {a : α}

#print threeGPFree_insert_of_lt /-
@[to_additive]
theorem threeGPFree_insert_of_lt (hs : ∀ i ∈ s, i < a) :
    ThreeGPFree (insert a s) ↔ ThreeGPFree s ∧ ∀ ⦃b c⦄, b ∈ s → c ∈ s → a * b = c * c → a = b :=
  by
  refine' mul_salem_spencer_insert.trans _
  rw [← and_assoc]
  exact and_iff_left fun b c hb hc h => ((mul_lt_mul_of_lt_of_lt (hs _ hb) (hs _ hc)).Ne h).elim
#align mul_salem_spencer_insert_of_lt threeGPFree_insert_of_lt
#align add_salem_spencer_insert_of_lt threeAPFree_insert_of_lt
-/

end OrderedCancelCommMonoid

section CancelCommMonoidWithZero

variable [CancelCommMonoidWithZero α] [NoZeroDivisors α] {s : Set α} {a : α}

#print ThreeGPFree.smul_set₀ /-
theorem ThreeGPFree.smul_set₀ (hs : ThreeGPFree s) (ha : a ≠ 0) : ThreeGPFree ((· * ·) a '' s) :=
  by
  rintro _ _ _ ⟨b, hb, rfl⟩ ⟨c, hc, rfl⟩ ⟨d, hd, rfl⟩ h
  rw [mul_mul_mul_comm, mul_mul_mul_comm a d] at h
  rw [hs hb hc hd (mul_left_cancel₀ (mul_ne_zero ha ha) h)]
#align mul_salem_spencer.mul_left₀ ThreeGPFree.smul_set₀
-/

theorem ThreeGPFree.hMul_right₀ (hs : ThreeGPFree s) (ha : a ≠ 0) : ThreeGPFree ((· * a) '' s) :=
  by
  rintro _ _ _ ⟨b, hb, rfl⟩ ⟨c, hc, rfl⟩ ⟨d, hd, rfl⟩ h
  rw [mul_mul_mul_comm, mul_mul_mul_comm d] at h
  rw [hs hb hc hd (mul_right_cancel₀ (mul_ne_zero ha ha) h)]
#align mul_salem_spencer.mul_right₀ ThreeGPFree.hMul_right₀

#print threeGPFree_smul_set₀ /-
theorem threeGPFree_smul_set₀ (ha : a ≠ 0) : ThreeGPFree ((· * ·) a '' s) ↔ ThreeGPFree s :=
  ⟨fun hs b c d hb hc hd h =>
    mul_left_cancel₀ ha
      (hs (Set.mem_image_of_mem _ hb) (Set.mem_image_of_mem _ hc) (Set.mem_image_of_mem _ hd) <| by
        rw [mul_mul_mul_comm, h, mul_mul_mul_comm]),
    fun hs => hs.mulLeft₀ ha⟩
#align mul_salem_spencer_mul_left_iff₀ threeGPFree_smul_set₀
-/

theorem threeGPFree_hMul_right_iff₀ (ha : a ≠ 0) : ThreeGPFree ((· * a) '' s) ↔ ThreeGPFree s :=
  ⟨fun hs b c d hb hc hd h =>
    mul_right_cancel₀ ha
      (hs (Set.mem_image_of_mem _ hb) (Set.mem_image_of_mem _ hc) (Set.mem_image_of_mem _ hd) <| by
        rw [mul_mul_mul_comm, h, mul_mul_mul_comm]),
    fun hs => hs.mulRight₀ ha⟩
#align mul_salem_spencer_mul_right_iff₀ threeGPFree_hMul_right_iff₀

end CancelCommMonoidWithZero

section Nat

#print threeAPFree_iff_eq_right /-
theorem threeAPFree_iff_eq_right {s : Set ℕ} :
    ThreeAPFree s ↔ ∀ ⦃a b c⦄, a ∈ s → b ∈ s → c ∈ s → a + b = c + c → a = c :=
  by
  refine' forall₄_congr fun a b c _ => forall₃_congr fun _ _ habc => ⟨_, _⟩
  · rintro rfl
    simp_rw [← two_mul] at habc
    exact mul_left_cancel₀ two_ne_zero habc
  · rintro rfl
    exact (add_left_cancel habc).symm
#align add_salem_spencer_iff_eq_right threeAPFree_iff_eq_right
-/

end Nat

#print threeAPFree_frontier /-
/-- The frontier of a closed strictly convex set only contains trivial arithmetic progressions.
The idea is that an arithmetic progression is contained on a line and the frontier of a strictly
convex set does not contain lines. -/
theorem threeAPFree_frontier [LinearOrderedField 𝕜] [TopologicalSpace E] [AddCommMonoid E]
    [Module 𝕜 E] {s : Set E} (hs₀ : IsClosed s) (hs₁ : StrictConvex 𝕜 s) :
    ThreeAPFree (frontier s) := by
  intro a b c ha hb hc habc
  obtain rfl : (1 / 2 : 𝕜) • a + (1 / 2 : 𝕜) • b = c := by
    rwa [← smul_add, one_div, inv_smul_eq_iff₀ (show (2 : 𝕜) ≠ 0 by norm_num), two_smul]
  exact
    hs₁.eq (hs₀.frontier_subset ha) (hs₀.frontier_subset hb) one_half_pos one_half_pos
      (add_halves _) hc.2
#align add_salem_spencer_frontier threeAPFree_frontier
-/

#print threeAPFree_sphere /-
theorem threeAPFree_sphere [NormedAddCommGroup E] [NormedSpace ℝ E] [StrictConvexSpace ℝ E] (x : E)
    (r : ℝ) : ThreeAPFree (sphere x r) :=
  by
  obtain rfl | hr := eq_or_ne r 0
  · rw [sphere_zero]
    exact threeAPFree_singleton _
  · convert threeAPFree_frontier is_closed_ball (strictConvex_closedBall ℝ x r)
    exact (frontier_closedBall _ hr).symm
#align add_salem_spencer_sphere threeAPFree_sphere
-/

end SalemSpencer

open Finset

section RothNumber

variable [DecidableEq α]

section Monoid

variable [Monoid α] [DecidableEq β] [Monoid β] (s t : Finset α)

/- ././././Mathport/Syntax/Translate/Basic.lean:642:2: warning: expanding binder collection (t «expr ⊆ » s) -/
#print mulRothNumber /-
/-- The multiplicative Roth number of a finset is the cardinality of its biggest multiplicative
Salem-Spencer subset. -/
@[to_additive
      "The additive Roth number of a finset is the cardinality of its biggest additive\nSalem-Spencer subset. The usual Roth number corresponds to `add_roth_number (finset.range n)`, see\n`roth_number_nat`. "]
def mulRothNumber : Finset α →o ℕ :=
  ⟨fun s =>
    Nat.findGreatest (fun m => ∃ (t : _) (_ : t ⊆ s), t.card = m ∧ ThreeGPFree (t : Set α)) s.card,
    by
    rintro t u htu
    refine' Nat.findGreatest_mono (fun m => _) (card_le_of_subset htu)
    rintro ⟨v, hvt, hv⟩
    exact ⟨v, hvt.trans htu, hv⟩⟩
#align mul_roth_number mulRothNumber
#align add_roth_number addRothNumber
-/

#print mulRothNumber_le /-
@[to_additive]
theorem mulRothNumber_le : mulRothNumber s ≤ s.card := by convert Nat.findGreatest_le s.card
#align mul_roth_number_le mulRothNumber_le
#align add_roth_number_le addRothNumber_le
-/

/- ././././Mathport/Syntax/Translate/Basic.lean:642:2: warning: expanding binder collection (t «expr ⊆ » s) -/
/- ././././Mathport/Syntax/Translate/Basic.lean:642:2: warning: expanding binder collection (t «expr ⊆ » s) -/
#print mulRothNumber_spec /-
@[to_additive]
theorem mulRothNumber_spec :
    ∃ (t : _) (_ : t ⊆ s), t.card = mulRothNumber s ∧ ThreeGPFree (t : Set α) :=
  @Nat.findGreatest_spec _ _ (fun m => ∃ (t : _) (_ : t ⊆ s), t.card = m ∧ ThreeGPFree (t : Set α))
    _ (Nat.zero_le _) ⟨∅, empty_subset _, card_empty, threeGPFree_empty⟩
#align mul_roth_number_spec mulRothNumber_spec
#align add_roth_number_spec addRothNumber_spec
-/

variable {s t} {n : ℕ}

#print ThreeGPFree.le_mulRothNumber /-
@[to_additive]
theorem ThreeGPFree.le_mulRothNumber (hs : ThreeGPFree (s : Set α)) (h : s ⊆ t) :
    s.card ≤ mulRothNumber t :=
  le_findGreatest (card_le_card h) ⟨s, h, rfl, hs⟩
#align mul_salem_spencer.le_mul_roth_number ThreeGPFree.le_mulRothNumber
#align add_salem_spencer.le_add_roth_number ThreeAPFree.le_addRothNumber
-/

#print ThreeGPFree.mulRothNumber_eq /-
@[to_additive]
theorem ThreeGPFree.mulRothNumber_eq (hs : ThreeGPFree (s : Set α)) : mulRothNumber s = s.card :=
  (mulRothNumber_le _).antisymm <| hs.le_mulRothNumber <| Subset.refl _
#align mul_salem_spencer.roth_number_eq ThreeGPFree.mulRothNumber_eq
#align add_salem_spencer.roth_number_eq ThreeAPFree.addRothNumber_eq
-/

#print mulRothNumber_empty /-
@[simp, to_additive]
theorem mulRothNumber_empty : mulRothNumber (∅ : Finset α) = 0 :=
  Nat.eq_zero_of_le_zero <| (mulRothNumber_le _).trans card_empty.le
#align mul_roth_number_empty mulRothNumber_empty
#align add_roth_number_empty addRothNumber_empty
-/

#print mulRothNumber_singleton /-
@[simp, to_additive]
theorem mulRothNumber_singleton (a : α) : mulRothNumber ({a} : Finset α) = 1 :=
  by
  convert ThreeGPFree.mulRothNumber_eq _
  rw [coe_singleton]
  exact threeGPFree_singleton a
#align mul_roth_number_singleton mulRothNumber_singleton
#align add_roth_number_singleton addRothNumber_singleton
-/

#print mulRothNumber_union_le /-
@[to_additive]
theorem mulRothNumber_union_le (s t : Finset α) :
    mulRothNumber (s ∪ t) ≤ mulRothNumber s + mulRothNumber t :=
  let ⟨u, hus, hcard, hu⟩ := mulRothNumber_spec (s ∪ t)
  calc
    mulRothNumber (s ∪ t) = u.card := hcard.symm
    _ = (u ∩ s ∪ u ∩ t).card := by rw [← inter_distrib_left, (inter_eq_left_iff_subset _ _).2 hus]
    _ ≤ (u ∩ s).card + (u ∩ t).card := (card_union_le _ _)
    _ ≤ mulRothNumber s + mulRothNumber t :=
      add_le_add ((hu.mono <| inter_subset_left _ _).le_mulRothNumber <| inter_subset_right _ _)
        ((hu.mono <| inter_subset_left _ _).le_mulRothNumber <| inter_subset_right _ _)
#align mul_roth_number_union_le mulRothNumber_union_le
#align add_roth_number_union_le addRothNumber_union_le
-/

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print le_mulRothNumber_product /-
@[to_additive]
theorem le_mulRothNumber_product (s : Finset α) (t : Finset β) :
    mulRothNumber s * mulRothNumber t ≤ mulRothNumber (s ×ˢ t) :=
  by
  obtain ⟨u, hus, hucard, hu⟩ := mulRothNumber_spec s
  obtain ⟨v, hvt, hvcard, hv⟩ := mulRothNumber_spec t
  rw [← hucard, ← hvcard, ← card_product]
  refine' ThreeGPFree.le_mulRothNumber _ (product_subset_product hus hvt)
  rw [coe_product]
  exact hu.prod hv
#align le_mul_roth_number_product le_mulRothNumber_product
#align le_add_roth_number_product le_addRothNumber_product
-/

#print mulRothNumber_lt_of_forall_not_threeGPFree /-
@[to_additive]
theorem mulRothNumber_lt_of_forall_not_threeGPFree
    (h : ∀ t ∈ powersetCard n s, ¬ThreeGPFree ((t : Finset α) : Set α)) : mulRothNumber s < n :=
  by
  obtain ⟨t, hts, hcard, ht⟩ := mulRothNumber_spec s
  rw [← hcard, ← not_le]
  intro hn
  obtain ⟨u, hut, rfl⟩ := exists_smaller_set t n hn
  exact h _ (mem_powerset_len.2 ⟨hut.trans hts, rfl⟩) (ht.mono hut)
#align mul_roth_number_lt_of_forall_not_mul_salem_spencer mulRothNumber_lt_of_forall_not_threeGPFree
#align add_roth_number_lt_of_forall_not_add_salem_spencer addRothNumber_lt_of_forall_not_threeAPFree
-/

end Monoid

section CancelCommMonoid

variable [CancelCommMonoid α] (s : Finset α) (a : α)

#print mulRothNumber_map_mul_left /-
@[simp, to_additive]
theorem mulRothNumber_map_mul_left :
    mulRothNumber (s.map <| mulLeftEmbedding a) = mulRothNumber s :=
  by
  refine' le_antisymm _ _
  · obtain ⟨u, hus, hcard, hu⟩ := mulRothNumber_spec (s.map <| mulLeftEmbedding a)
    rw [subset_map_iff] at hus
    obtain ⟨u, hus, rfl⟩ := hus
    rw [coe_map] at hu
    rw [← hcard, card_map]
    exact (threeGPFree_smul_set.1 hu).le_mulRothNumber hus
  · obtain ⟨u, hus, hcard, hu⟩ := mulRothNumber_spec s
    have h : ThreeGPFree (u.map <| mulLeftEmbedding a : Set α) :=
      by
      rw [coe_map]
      exact hu.mul_left
    convert h.le_mul_roth_number (map_subset_map.2 hus)
    rw [card_map, hcard]
#align mul_roth_number_map_mul_left mulRothNumber_map_mul_left
#align add_roth_number_map_add_left addRothNumber_map_add_left
-/

#print mulRothNumber_map_mul_right /-
@[simp, to_additive]
theorem mulRothNumber_map_mul_right :
    mulRothNumber (s.map <| mulRightEmbedding a) = mulRothNumber s := by
  rw [← mulLeftEmbedding_eq_mulRightEmbedding, mulRothNumber_map_mul_left s a]
#align mul_roth_number_map_mul_right mulRothNumber_map_mul_right
#align add_roth_number_map_add_right addRothNumber_map_add_right
-/

end CancelCommMonoid

end RothNumber

section rothNumberNat

variable {s : Finset ℕ} {k n : ℕ}

#print rothNumberNat /-
/-- The Roth number of a natural `N` is the largest integer `m` for which there is a subset of
`range N` of size `m` with no arithmetic progression of length 3.
Trivially, `roth_number_nat N ≤ N`, but Roth's theorem (proved in 1953) shows that
`roth_number_nat N = o(N)` and the construction by Behrend gives a lower bound of the form
`N * exp(-C sqrt(log(N))) ≤ roth_number_nat N`.
A significant refinement of Roth's theorem by Bloom and Sisask announced in 2020 gives
`roth_number_nat N = O(N / (log N)^(1+c))` for an absolute constant `c`. -/
def rothNumberNat : ℕ →o ℕ :=
  ⟨fun n => addRothNumber (range n), addRothNumber.mono.comp range_mono⟩
#align roth_number_nat rothNumberNat
-/

#print rothNumberNat_def /-
theorem rothNumberNat_def (n : ℕ) : rothNumberNat n = addRothNumber (range n) :=
  rfl
#align roth_number_nat_def rothNumberNat_def
-/

#print rothNumberNat_le /-
theorem rothNumberNat_le (N : ℕ) : rothNumberNat N ≤ N :=
  (addRothNumber_le _).trans (card_range _).le
#align roth_number_nat_le rothNumberNat_le
-/

/- ././././Mathport/Syntax/Translate/Basic.lean:642:2: warning: expanding binder collection (t «expr ⊆ » range[finset.range] n) -/
#print rothNumberNat_spec /-
theorem rothNumberNat_spec (n : ℕ) :
    ∃ (t : _) (_ : t ⊆ range n), t.card = rothNumberNat n ∧ ThreeAPFree (t : Set ℕ) :=
  addRothNumber_spec _
#align roth_number_nat_spec rothNumberNat_spec
-/

#print ThreeAPFree.le_rothNumberNat /-
/-- A verbose specialization of `add_salem_spencer.le_add_roth_number`, sometimes convenient in
practice. -/
theorem ThreeAPFree.le_rothNumberNat (s : Finset ℕ) (hs : ThreeAPFree (s : Set ℕ))
    (hsn : ∀ x ∈ s, x < n) (hsk : s.card = k) : k ≤ rothNumberNat n :=
  hsk.ge.trans <| hs.le_addRothNumber fun x hx => mem_range.2 <| hsn x hx
#align add_salem_spencer.le_roth_number_nat ThreeAPFree.le_rothNumberNat
-/

#print rothNumberNat_add_le /-
/-- The Roth number is a subadditive function. Note that by Fekete's lemma this shows that
the limit `roth_number_nat N / N` exists, but Roth's theorem gives the stronger result that this
limit is actually `0`. -/
theorem rothNumberNat_add_le (M N : ℕ) :
    rothNumberNat (M + N) ≤ rothNumberNat M + rothNumberNat N :=
  by
  simp_rw [rothNumberNat_def]
  rw [range_add_eq_union, ← addRothNumber_map_add_left (range N) M]
  exact addRothNumber_union_le _ _
#align roth_number_nat_add_le rothNumberNat_add_le
-/

#print rothNumberNat_zero /-
@[simp]
theorem rothNumberNat_zero : rothNumberNat 0 = 0 :=
  rfl
#align roth_number_nat_zero rothNumberNat_zero
-/

#print addRothNumber_Ico /-
theorem addRothNumber_Ico (a b : ℕ) : addRothNumber (Ico a b) = rothNumberNat (b - a) :=
  by
  obtain h | h := le_total b a
  · rw [tsub_eq_zero_of_le h, Ico_eq_empty_of_le h, rothNumberNat_zero, addRothNumber_empty]
  convert addRothNumber_map_add_left _ a
  rw [range_eq_Ico, map_eq_image]
  convert (image_add_left_Ico 0 (b - a) _).symm
  exact (add_tsub_cancel_of_le h).symm
#align add_roth_number_Ico addRothNumber_Ico
-/

open Asymptotics Filter

theorem rothNumberNat_isBigOWith_id :
    IsBigOWith 1 atTop (fun N => (rothNumberNat N : ℝ)) fun N => (N : ℝ) :=
  isBigOWith_of_le _ <| by simpa only [Real.norm_natCast, Nat.cast_le] using rothNumberNat_le
#align roth_number_nat_is_O_with_id rothNumberNat_isBigOWith_id

/-- The Roth number has the trivial bound `roth_number_nat N = O(N)`. -/
theorem rothNumberNat_isBigO_id : (fun N => (rothNumberNat N : ℝ)) =O[atTop] fun N => (N : ℝ) :=
  rothNumberNat_isBigOWith_id.IsBigO
#align roth_number_nat_is_O_id rothNumberNat_isBigO_id

end rothNumberNat

