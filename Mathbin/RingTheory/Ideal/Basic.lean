/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Chris Hughes, Mario Carneiro
-/
import Mathbin.Algebra.Associated
import Mathbin.LinearAlgebra.Basic
import Mathbin.Order.Zorn
import Mathbin.Order.Atoms
import Mathbin.Order.CompactlyGenerated
import Mathbin.Tactic.Abel
import Mathbin.Data.Nat.Choose.Sum
import Mathbin.LinearAlgebra.Finsupp

/-!

# Ideals over a ring

This file defines `ideal R`, the type of (left) ideals over a ring `R`.
Note that over commutative rings, left ideals and two-sided ideals are equivalent.

## Implementation notes

`ideal R` is implemented using `submodule R R`, where `•` is interpreted as `*`.

## TODO

Support right ideals, and two-sided ideals over non-commutative rings.
-/


universe u v w

variable {α : Type u} {β : Type v}

open Set Function

open Classical BigOperators Pointwise

/-- A (left) ideal in a semiring `R` is an additive submonoid `s` such that
`a * b ∈ s` whenever `b ∈ s`. If `R` is a ring, then `s` is an additive subgroup.  -/
@[reducible]
def Ideal (R : Type u) [Semiringₓ R] :=
  Submodule R R

section Semiringₓ

namespace Ideal

variable [Semiringₓ α] (I : Ideal α) {a b : α}

protected theorem zero_mem : (0 : α) ∈ I :=
  I.zero_mem

protected theorem add_mem : a ∈ I → b ∈ I → a + b ∈ I :=
  I.add_mem

variable (a)

theorem mul_mem_left : b ∈ I → a * b ∈ I :=
  I.smul_mem a

variable {a}

@[ext]
theorem ext {I J : Ideal α} (h : ∀ x, x ∈ I ↔ x ∈ J) : I = J :=
  Submodule.ext h

theorem sum_mem (I : Ideal α) {ι : Type _} {t : Finset ι} {f : ι → α} :
    (∀, ∀ c ∈ t, ∀, f c ∈ I) → (∑ i in t, f i) ∈ I :=
  Submodule.sum_mem I

theorem eq_top_of_unit_mem (x y : α) (hx : x ∈ I) (h : y * x = 1) : I = ⊤ :=
  eq_top_iff.2 fun z _ =>
    calc
      z = z * (y * x) := by
        simp [h]
      _ = z * y * x := Eq.symm <| mul_assoc z y x
      _ ∈ I := I.mul_mem_left _ hx
      

theorem eq_top_of_is_unit_mem {x} (hx : x ∈ I) (h : IsUnit x) : I = ⊤ :=
  let ⟨y, hy⟩ := h.exists_left_inv
  eq_top_of_unit_mem I x y hx hy

theorem eq_top_iff_one : I = ⊤ ↔ (1 : α) ∈ I :=
  ⟨by
    rintro rfl <;> trivial, fun h =>
    eq_top_of_unit_mem _ _ 1 h
      (by
        simp )⟩

theorem ne_top_iff_one : I ≠ ⊤ ↔ (1 : α) ∉ I :=
  not_congr I.eq_top_iff_one

@[simp]
theorem unit_mul_mem_iff_mem {x y : α} (hy : IsUnit y) : y * x ∈ I ↔ x ∈ I := by
  refine' ⟨fun h => _, fun h => I.mul_mem_left y h⟩
  obtain ⟨y', hy'⟩ := hy.exists_left_inv
  have := I.mul_mem_left y' h
  rwa [← mul_assoc, hy', one_mulₓ] at this

/-- The ideal generated by a subset of a ring -/
def span (s : Set α) : Ideal α :=
  Submodule.span α s

@[simp]
theorem submodule_span_eq {s : Set α} : Submodule.span α s = Ideal.span s :=
  rfl

@[simp]
theorem span_empty : span (∅ : Set α) = ⊥ :=
  Submodule.span_empty

@[simp]
theorem span_univ : span (Set.Univ : Set α) = ⊤ :=
  Submodule.span_univ

theorem span_union (s t : Set α) : span (s ∪ t) = span s⊔span t :=
  Submodule.span_union _ _

theorem span_Union {ι} (s : ι → Set α) : span (⋃ i, s i) = ⨆ i, span (s i) :=
  Submodule.span_Union _

theorem mem_span {s : Set α} x : x ∈ span s ↔ ∀ p : Ideal α, s ⊆ p → x ∈ p :=
  mem_Inter₂

theorem subset_span {s : Set α} : s ⊆ span s :=
  Submodule.subset_span

theorem span_le {s : Set α} {I} : span s ≤ I ↔ s ⊆ I :=
  Submodule.span_le

theorem span_mono {s t : Set α} : s ⊆ t → span s ≤ span t :=
  Submodule.span_mono

@[simp]
theorem span_eq : span (I : Set α) = I :=
  Submodule.span_eq _

@[simp]
theorem span_singleton_one : span ({1} : Set α) = ⊤ :=
  (eq_top_iff_one _).2 <| subset_span <| mem_singleton _

theorem mem_span_insert {s : Set α} {x y} : x ∈ span (insert y s) ↔ ∃ a, ∃ z ∈ span s, x = a * y + z :=
  Submodule.mem_span_insert

theorem mem_span_singleton' {x y : α} : x ∈ span ({y} : Set α) ↔ ∃ a, a * y = x :=
  Submodule.mem_span_singleton

theorem span_insert x (s : Set α) : span (insert x s) = span ({x} : Set α)⊔span s :=
  Submodule.span_insert x s

theorem span_eq_bot {s : Set α} : span s = ⊥ ↔ ∀, ∀ x ∈ s, ∀, (x : α) = 0 :=
  Submodule.span_eq_bot

@[simp]
theorem span_singleton_eq_bot {x} : span ({x} : Set α) = ⊥ ↔ x = 0 :=
  Submodule.span_singleton_eq_bot

@[simp]
theorem span_zero : span (0 : Set α) = ⊥ := by
  rw [← Set.singleton_zero, span_singleton_eq_bot]

@[simp]
theorem span_one : span (1 : Set α) = ⊤ := by
  rw [← Set.singleton_one, span_singleton_one]

theorem span_eq_top_iff_finite (s : Set α) : span s = ⊤ ↔ ∃ s' : Finset α, ↑s' ⊆ s ∧ span (s' : Set α) = ⊤ := by
  simp_rw [eq_top_iff_one]
  exact ⟨Submodule.mem_span_finite_of_mem_span, fun ⟨s', h₁, h₂⟩ => span_mono h₁ h₂⟩

/-- The ideal generated by an arbitrary binary relation.
-/
def ofRel (r : α → α → Prop) : Ideal α :=
  Submodule.span α { x | ∃ (a b : _)(h : r a b), x + b = a }

/-- An ideal `P` of a ring `R` is prime if `P ≠ R` and `xy ∈ P → x ∈ P ∨ y ∈ P` -/
class IsPrime (I : Ideal α) : Prop where
  ne_top' : I ≠ ⊤
  mem_or_mem' : ∀ {x y : α}, x * y ∈ I → x ∈ I ∨ y ∈ I

theorem is_prime_iff {I : Ideal α} : IsPrime I ↔ I ≠ ⊤ ∧ ∀ {x y : α}, x * y ∈ I → x ∈ I ∨ y ∈ I :=
  ⟨fun h => ⟨h.1, h.2⟩, fun h => ⟨h.1, h.2⟩⟩

theorem IsPrime.ne_top {I : Ideal α} (hI : I.IsPrime) : I ≠ ⊤ :=
  hI.1

theorem IsPrime.mem_or_mem {I : Ideal α} (hI : I.IsPrime) : ∀ {x y : α}, x * y ∈ I → x ∈ I ∨ y ∈ I :=
  hI.2

theorem IsPrime.mem_or_mem_of_mul_eq_zero {I : Ideal α} (hI : I.IsPrime) {x y : α} (h : x * y = 0) : x ∈ I ∨ y ∈ I :=
  hI.mem_or_mem (h.symm ▸ I.zero_mem)

theorem IsPrime.mem_of_pow_mem {I : Ideal α} (hI : I.IsPrime) {r : α} (n : ℕ) (H : r ^ n ∈ I) : r ∈ I := by
  induction' n with n ih
  · rw [pow_zeroₓ] at H
    exact (mt (eq_top_iff_one _).2 hI.1).elim H
    
  · rw [pow_succₓ] at H
    exact Or.cases_on (hI.mem_or_mem H) id ih
    

-- ././Mathport/Syntax/Translate/Basic.lean:597:2: warning: expanding binder collection (x «expr ∉ » I)
-- ././Mathport/Syntax/Translate/Basic.lean:597:2: warning: expanding binder collection (y «expr ∉ » I)
theorem not_is_prime_iff {I : Ideal α} : ¬I.IsPrime ↔ I = ⊤ ∨ ∃ (x : _)(_ : x ∉ I)(y : _)(_ : y ∉ I), x * y ∈ I := by
  simp_rw [Ideal.is_prime_iff, not_and_distrib, Ne.def, not_not, not_forall, not_or_distrib]
  exact
    or_congr Iff.rfl ⟨fun ⟨x, y, hxy, hx, hy⟩ => ⟨x, hx, y, hy, hxy⟩, fun ⟨x, hx, y, hy, hxy⟩ => ⟨x, y, hxy, hx, hy⟩⟩

theorem zero_ne_one_of_proper {I : Ideal α} (h : I ≠ ⊤) : (0 : α) ≠ 1 := fun hz =>
  I.ne_top_iff_one.1 h <| hz ▸ I.zero_mem

theorem bot_prime {R : Type _} [Ringₓ R] [IsDomain R] : (⊥ : Ideal R).IsPrime :=
  ⟨fun h =>
    one_ne_zero
      (by
        rwa [Ideal.eq_top_iff_one, Submodule.mem_bot] at h),
    fun x y h =>
    mul_eq_zero.mp
      (by
        simpa only [Submodule.mem_bot] using h)⟩

/-- An ideal is maximal if it is maximal in the collection of proper ideals. -/
class IsMaximal (I : Ideal α) : Prop where
  out : IsCoatom I

theorem is_maximal_def {I : Ideal α} : I.IsMaximal ↔ IsCoatom I :=
  ⟨fun h => h.1, fun h => ⟨h⟩⟩

theorem IsMaximal.ne_top {I : Ideal α} (h : I.IsMaximal) : I ≠ ⊤ :=
  (is_maximal_def.1 h).1

theorem is_maximal_iff {I : Ideal α} :
    I.IsMaximal ↔ (1 : α) ∉ I ∧ ∀ J : Ideal α x, I ≤ J → x ∉ I → x ∈ J → (1 : α) ∈ J :=
  is_maximal_def.trans <|
    and_congr I.ne_top_iff_one <|
      forall_congrₓ fun J => by
        rw [lt_iff_le_not_leₓ] <;>
          exact
            ⟨fun H x h hx₁ hx₂ => J.eq_top_iff_one.1 <| H ⟨h, not_subset.2 ⟨_, hx₂, hx₁⟩⟩, fun H ⟨h₁, h₂⟩ =>
              let ⟨x, xJ, xI⟩ := not_subset.1 h₂
              J.eq_top_iff_one.2 <| H x h₁ xI xJ⟩

theorem IsMaximal.eq_of_le {I J : Ideal α} (hI : I.IsMaximal) (hJ : J ≠ ⊤) (IJ : I ≤ J) : I = J :=
  eq_iff_le_not_lt.2 ⟨IJ, fun h => hJ (hI.1.2 _ h)⟩

instance : IsCoatomic (Ideal α) := by
  apply CompleteLattice.coatomic_of_top_compact
  rw [← span_singleton_one]
  exact Submodule.singleton_span_is_compact_element 1

/-- **Krull's theorem**: if `I` is an ideal that is not the whole ring, then it is included in some
    maximal ideal. -/
theorem exists_le_maximal (I : Ideal α) (hI : I ≠ ⊤) : ∃ M : Ideal α, M.IsMaximal ∧ I ≤ M :=
  let ⟨m, hm⟩ := (eq_top_or_exists_le_coatom I).resolve_left hI
  ⟨m, ⟨⟨hm.1⟩, hm.2⟩⟩

variable (α)

/-- Krull's theorem: a nontrivial ring has a maximal ideal. -/
theorem exists_maximal [Nontrivial α] : ∃ M : Ideal α, M.IsMaximal :=
  let ⟨I, ⟨hI, _⟩⟩ := exists_le_maximal (⊥ : Ideal α) bot_ne_top
  ⟨I, hI⟩

variable {α}

instance [Nontrivial α] : Nontrivial (Ideal α) := by
  rcases@exists_maximal α _ _ with ⟨M, hM, _⟩
  exact nontrivial_of_ne M ⊤ hM

/-- If P is not properly contained in any maximal ideal then it is not properly contained
  in any proper ideal -/
theorem maximal_of_no_maximal {R : Type u} [Semiringₓ R] {P : Ideal R} (hmax : ∀ m : Ideal R, P < m → ¬IsMaximal m)
    (J : Ideal R) (hPJ : P < J) : J = ⊤ := by
  by_contra hnonmax
  rcases exists_le_maximal J hnonmax with ⟨M, hM1, hM2⟩
  exact hmax M (lt_of_lt_of_leₓ hPJ hM2) hM1

theorem mem_span_pair {x y z : α} : z ∈ span ({x, y} : Set α) ↔ ∃ a b, a * x + b * y = z := by
  simp [mem_span_insert, mem_span_singleton', @eq_comm _ _ z]

theorem IsMaximal.exists_inv {I : Ideal α} (hI : I.IsMaximal) {x} (hx : x ∉ I) : ∃ y, ∃ i ∈ I, y * x + i = 1 := by
  cases' is_maximal_iff.1 hI with H₁ H₂
  rcases mem_span_insert.1
      (H₂ (span (insert x I)) x (Set.Subset.trans (subset_insert _ _) subset_span) hx
        (subset_span (mem_insert _ _))) with
    ⟨y, z, hz, hy⟩
  refine' ⟨y, z, _, hy.symm⟩
  rwa [← span_eq I]

section Lattice

variable {R : Type u} [Semiringₓ R]

theorem mem_sup_left {S T : Ideal R} : ∀ {x : R}, x ∈ S → x ∈ S⊔T :=
  show S ≤ S⊔T from le_sup_left

theorem mem_sup_right {S T : Ideal R} : ∀ {x : R}, x ∈ T → x ∈ S⊔T :=
  show T ≤ S⊔T from le_sup_right

theorem mem_supr_of_mem {ι : Sort _} {S : ι → Ideal R} (i : ι) : ∀ {x : R}, x ∈ S i → x ∈ supr S :=
  show S i ≤ supr S from le_supr _ _

theorem mem_Sup_of_mem {S : Set (Ideal R)} {s : Ideal R} (hs : s ∈ S) : ∀ {x : R}, x ∈ s → x ∈ sup S :=
  show s ≤ sup S from le_Sup hs

theorem mem_Inf {s : Set (Ideal R)} {x : R} : x ∈ inf s ↔ ∀ ⦃I⦄, I ∈ s → x ∈ I :=
  ⟨fun hx I his => hx I ⟨I, infi_pos his⟩, fun H I ⟨J, hij⟩ => hij ▸ fun S ⟨hj, hS⟩ => hS ▸ H hj⟩

@[simp]
theorem mem_inf {I J : Ideal R} {x : R} : x ∈ I⊓J ↔ x ∈ I ∧ x ∈ J :=
  Iff.rfl

@[simp]
theorem mem_infi {ι : Sort _} {I : ι → Ideal R} {x : R} : x ∈ infi I ↔ ∀ i, x ∈ I i :=
  Submodule.mem_infi _

@[simp]
theorem mem_bot {x : R} : x ∈ (⊥ : Ideal R) ↔ x = 0 :=
  Submodule.mem_bot _

end Lattice

section Pi

variable (ι : Type v)

/-- `I^n` as an ideal of `R^n`. -/
def pi : Ideal (ι → α) where
  Carrier := { x | ∀ i, x i ∈ I }
  zero_mem' := fun i => I.zero_mem
  add_mem' := fun a b ha hb i => I.add_mem (ha i) (hb i)
  smul_mem' := fun a b hb i => I.mul_mem_left (a i) (hb i)

theorem mem_pi (x : ι → α) : x ∈ I.pi ι ↔ ∀ i, x i ∈ I :=
  Iff.rfl

end Pi

end Ideal

end Semiringₓ

section CommSemiringₓ

variable {a b : α}

-- A separate namespace definition is needed because the variables were historically in a different
-- order.
namespace Ideal

variable [CommSemiringₓ α] (I : Ideal α)

@[simp]
theorem mul_unit_mem_iff_mem {x y : α} (hy : IsUnit y) : x * y ∈ I ↔ x ∈ I :=
  mul_comm y x ▸ unit_mul_mem_iff_mem I hy

theorem mem_span_singleton {x y : α} : x ∈ span ({y} : Set α) ↔ y ∣ x :=
  mem_span_singleton'.trans <|
    exists_congr fun _ => by
      rw [eq_comm, mul_comm]

theorem span_singleton_le_span_singleton {x y : α} : span ({x} : Set α) ≤ span ({y} : Set α) ↔ y ∣ x :=
  span_le.trans <| singleton_subset_iff.trans mem_span_singleton

theorem span_singleton_eq_span_singleton {α : Type u} [CommRingₓ α] [IsDomain α] {x y : α} :
    span ({x} : Set α) = span ({y} : Set α) ↔ Associated x y := by
  rw [← dvd_dvd_iff_associated, le_antisymm_iffₓ, and_comm]
  apply and_congr <;> rw [span_singleton_le_span_singleton]

theorem span_singleton_mul_right_unit {a : α} (h2 : IsUnit a) (x : α) : span ({x * a} : Set α) = span {x} := by
  apply le_antisymmₓ
  · rw [span_singleton_le_span_singleton]
    use a
    
  · rw [span_singleton_le_span_singleton]
    rw [IsUnit.mul_right_dvd h2]
    

theorem span_singleton_mul_left_unit {a : α} (h2 : IsUnit a) (x : α) : span ({a * x} : Set α) = span {x} := by
  rw [mul_comm, span_singleton_mul_right_unit h2]

theorem span_singleton_eq_top {x} : span ({x} : Set α) = ⊤ ↔ IsUnit x := by
  rw [is_unit_iff_dvd_one, ← span_singleton_le_span_singleton, span_singleton_one, eq_top_iff]

theorem span_singleton_prime {p : α} (hp : p ≠ 0) : IsPrime (span ({p} : Set α)) ↔ Prime p := by
  simp [is_prime_iff, Prime, span_singleton_eq_top, hp, mem_span_singleton]

theorem IsMaximal.is_prime {I : Ideal α} (H : I.IsMaximal) : I.IsPrime :=
  ⟨H.1.1, fun x y hxy =>
    or_iff_not_imp_left.2 fun hx => by
      let J : Ideal α := Submodule.span α (insert x ↑I)
      have IJ : I ≤ J := Set.Subset.trans (subset_insert _ _) subset_span
      have xJ : x ∈ J := Ideal.subset_span (Set.mem_insert x I)
      cases' is_maximal_iff.1 H with _ oJ
      specialize oJ J x IJ hx xJ
      rcases submodule.mem_span_insert.mp oJ with ⟨a, b, h, oe⟩
      obtain F : y * 1 = y * (a • x + b) := congr_arg (fun g : α => y * g) oe
      rw [← mul_oneₓ y, F, mul_addₓ, mul_comm, smul_eq_mul, mul_assoc]
      refine' Submodule.add_mem I (I.mul_mem_left a hxy) (Submodule.smul_mem I y _)
      rwa [Submodule.span_eq] at h⟩

-- see Note [lower instance priority]
instance (priority := 100) IsMaximal.is_prime' (I : Ideal α) : ∀ [H : I.IsMaximal], I.IsPrime :=
  is_maximal.is_prime

theorem span_singleton_lt_span_singleton [CommRingₓ β] [IsDomain β] {x y : β} :
    span ({x} : Set β) < span ({y} : Set β) ↔ DvdNotUnit y x := by
  rw [lt_iff_le_not_leₓ, span_singleton_le_span_singleton, span_singleton_le_span_singleton, dvd_and_not_dvd_iff]

theorem factors_decreasing [CommRingₓ β] [IsDomain β] (b₁ b₂ : β) (h₁ : b₁ ≠ 0) (h₂ : ¬IsUnit b₂) :
    span ({b₁ * b₂} : Set β) < span {b₁} :=
  (lt_of_le_not_leₓ (Ideal.span_le.2 <| singleton_subset_iff.2 <| Ideal.mem_span_singleton.2 ⟨b₂, rfl⟩)) fun h =>
    h₂ <|
      is_unit_of_dvd_one _ <|
        (mul_dvd_mul_iff_left h₁).1 <| by
          rwa [mul_oneₓ, ← Ideal.span_singleton_le_span_singleton]

variable (b)

theorem mul_mem_right (h : a ∈ I) : a * b ∈ I :=
  mul_comm b a ▸ I.mul_mem_left b h

variable {b}

theorem pow_mem_of_mem (ha : a ∈ I) (n : ℕ) (hn : 0 < n) : a ^ n ∈ I :=
  Nat.casesOn n
    (Not.elim
      (by
        decide))
    (fun m hm => (pow_succₓ a m).symm ▸ I.mul_mem_right (a ^ m) ha) hn

theorem IsPrime.mul_mem_iff_mem_or_mem {I : Ideal α} (hI : I.IsPrime) : ∀ {x y : α}, x * y ∈ I ↔ x ∈ I ∨ y ∈ I :=
  fun x y =>
  ⟨hI.mem_or_mem, by
    rintro (h | h)
    exacts[I.mul_mem_right y h, I.mul_mem_left x h]⟩

theorem IsPrime.pow_mem_iff_mem {I : Ideal α} (hI : I.IsPrime) {r : α} (n : ℕ) (hn : 0 < n) : r ^ n ∈ I ↔ r ∈ I :=
  ⟨hI.mem_of_pow_mem n, fun hr => I.pow_mem_of_mem hr n hn⟩

theorem pow_multiset_sum_mem_span_pow (s : Multiset α) (n : ℕ) :
    s.Sum ^ (s.card * n + 1) ∈ span ((s.map fun x => x ^ (n + 1)).toFinset : Set α) := by
  induction' s using Multiset.induction_on with a s hs
  · simp
    
  simp only [Finset.coe_insert, Multiset.map_cons, Multiset.to_finset_cons, Multiset.sum_cons, Multiset.card_cons,
    add_pow]
  refine' Submodule.sum_mem _ _
  intro c hc
  rw [mem_span_insert]
  by_cases' h : n + 1 ≤ c
  · refine'
      ⟨a ^ (c - (n + 1)) * s.sum ^ ((s.card + 1) * n + 1 - c) * ((s.card + 1) * n + 1).choose c, 0,
        Submodule.zero_mem _, _⟩
    rw [mul_comm _ (a ^ (n + 1))]
    simp_rw [← mul_assoc]
    rw [← pow_addₓ, add_zeroₓ, add_tsub_cancel_of_le h]
    
  · use 0
    simp_rw [zero_mul, zero_addₓ]
    refine' ⟨_, _, rfl⟩
    replace h : c ≤ n := nat.lt_succ_iff.mp (not_le.mp h)
    have : (s.card + 1) * n + 1 - c = s.card * n + 1 + (n - c) := by
      rw [add_mulₓ, one_mulₓ, add_assocₓ, add_commₓ n 1, ← add_assocₓ, add_tsub_assoc_of_le h]
    rw [this, pow_addₓ]
    simp_rw [mul_assoc, mul_comm (s.sum ^ (s.card * n + 1)), ← mul_assoc]
    exact mul_mem_left _ _ hs
    

theorem sum_pow_mem_span_pow {ι} (s : Finset ι) (f : ι → α) (n : ℕ) :
    (∑ i in s, f i) ^ (s.card * n + 1) ∈ span ((fun i => f i ^ (n + 1)) '' s) := by
  convert pow_multiset_sum_mem_span_pow (s.1.map f) n
  · rw [Multiset.card_map]
    rfl
    
  rw [Multiset.map_map, Multiset.to_finset_map, Finset.val_to_finset, Finset.coe_image]

theorem span_pow_eq_top (s : Set α) (hs : span s = ⊤) (n : ℕ) : span ((fun x => x ^ n) '' s) = ⊤ := by
  rw [eq_top_iff_one]
  cases n
  · obtain rfl | ⟨x, hx⟩ := eq_empty_or_nonempty s
    · rw [Set.image_empty, hs]
      trivial
      
    · exact subset_span ⟨_, hx, pow_zeroₓ _⟩
      
    
  rw [eq_top_iff_one, span, Finsupp.mem_span_iff_total] at hs
  rcases hs with ⟨f, hf⟩
  change (f.support.sum fun a => f a * a) = 1 at hf
  have := sum_pow_mem_span_pow f.support (fun a => f a * a) n
  rw [hf, one_pow] at this
  refine' span_le.mpr _ this
  rintro _ hx
  simp_rw [Finset.mem_coe, Set.mem_image]  at hx
  rcases hx with ⟨x, hx, rfl⟩
  have : span ({x ^ (n + 1)} : Set α) ≤ span ((fun x : α => x ^ (n + 1)) '' s) := by
    rw [span_le, Set.singleton_subset_iff]
    exact subset_span ⟨x, x.prop, rfl⟩
  refine' this _
  rw [mul_powₓ, mem_span_singleton]
  exact ⟨f x ^ (n + 1), mul_comm _ _⟩

end Ideal

end CommSemiringₓ

section Ringₓ

namespace Ideal

variable [Ringₓ α] (I : Ideal α) {a b : α}

protected theorem neg_mem_iff : -a ∈ I ↔ a ∈ I :=
  neg_mem_iff

protected theorem add_mem_iff_left : b ∈ I → (a + b ∈ I ↔ a ∈ I) :=
  I.add_mem_iff_left

protected theorem add_mem_iff_right : a ∈ I → (a + b ∈ I ↔ b ∈ I) :=
  I.add_mem_iff_right

protected theorem sub_mem : a ∈ I → b ∈ I → a - b ∈ I :=
  sub_mem

theorem mem_span_insert' {s : Set α} {x y} : x ∈ span (insert y s) ↔ ∃ a, x + a * y ∈ span s :=
  Submodule.mem_span_insert'

end Ideal

end Ringₓ

section DivisionRing

variable {K : Type u} [DivisionRing K] (I : Ideal K)

namespace Ideal

/-- All ideals in a division ring are trivial. -/
theorem eq_bot_or_top : I = ⊥ ∨ I = ⊤ := by
  rw [or_iff_not_imp_right]
  change _ ≠ _ → _
  rw [Ideal.ne_top_iff_one]
  intro h1
  rw [eq_bot_iff]
  intro r hr
  by_cases' H : r = 0
  · simpa
    
  simpa [H, h1] using I.mul_mem_left r⁻¹ hr

theorem eq_bot_of_prime [h : I.IsPrime] : I = ⊥ :=
  or_iff_not_imp_right.mp I.eq_bot_or_top h.1

theorem bot_is_maximal : IsMaximal (⊥ : Ideal K) :=
  ⟨⟨fun h =>
      absurd ((eq_top_iff_one (⊤ : Ideal K)).mp rfl)
        (by
          rw [← h] <;> simp ),
      fun I hI => or_iff_not_imp_left.mp (eq_bot_or_top I) (ne_of_gtₓ hI)⟩⟩

end Ideal

end DivisionRing

section CommRingₓ

namespace Ideal

theorem mul_sub_mul_mem {R : Type _} [CommRingₓ R] (I : Ideal R) {a b c d : R} (h1 : a - b ∈ I) (h2 : c - d ∈ I) :
    a * c - b * d ∈ I := by
  rw
    [show a * c - b * d = (a - b) * c + b * (c - d) by
      rw [sub_mul, mul_sub]
      abel]
  exact I.add_mem (I.mul_mem_right _ h1) (I.mul_mem_left _ h2)

end Ideal

end CommRingₓ

namespace Ringₓ

variable {R : Type _} [CommRingₓ R]

theorem not_is_field_of_subsingleton {R : Type _} [Ringₓ R] [Subsingleton R] : ¬IsField R := fun ⟨⟨x, y, hxy⟩, _, _⟩ =>
  hxy (Subsingleton.elimₓ x y)

-- ././Mathport/Syntax/Translate/Basic.lean:597:2: warning: expanding binder collection (x «expr ≠ » (0 : R))
theorem exists_not_is_unit_of_not_is_field [Nontrivial R] (hf : ¬IsField R) : ∃ (x : _)(_ : x ≠ (0 : R)), ¬IsUnit x :=
  by
  have : ¬_ := fun h => hf ⟨exists_pair_ne R, mul_comm, h⟩
  simp_rw [is_unit_iff_exists_inv]
  push_neg  at this⊢
  obtain ⟨x, hx, not_unit⟩ := this
  exact ⟨x, hx, not_unit⟩

theorem not_is_field_iff_exists_ideal_bot_lt_and_lt_top [Nontrivial R] : ¬IsField R ↔ ∃ I : Ideal R, ⊥ < I ∧ I < ⊤ := by
  constructor
  · intro h
    obtain ⟨x, nz, nu⟩ := exists_not_is_unit_of_not_is_field h
    use Ideal.span {x}
    rw [bot_lt_iff_ne_bot, lt_top_iff_ne_top]
    exact ⟨mt ideal.span_singleton_eq_bot.mp nz, mt ideal.span_singleton_eq_top.mp nu⟩
    
  · rintro ⟨I, bot_lt, lt_top⟩ hf
    obtain ⟨x, mem, ne_zero⟩ := SetLike.exists_of_lt bot_lt
    rw [Submodule.mem_bot] at ne_zero
    obtain ⟨y, hy⟩ := hf.mul_inv_cancel ne_zero
    rw [lt_top_iff_ne_top, Ne.def, Ideal.eq_top_iff_one, ← hy] at lt_top
    exact lt_top (I.mul_mem_right _ mem)
    

theorem not_is_field_iff_exists_prime [Nontrivial R] : ¬IsField R ↔ ∃ p : Ideal R, p ≠ ⊥ ∧ p.IsPrime :=
  not_is_field_iff_exists_ideal_bot_lt_and_lt_top.trans
    ⟨fun ⟨I, bot_lt, lt_top⟩ =>
      let ⟨p, hp, le_p⟩ := I.exists_le_maximal (lt_top_iff_ne_top.mp lt_top)
      ⟨p, bot_lt_iff_ne_bot.mp (lt_of_lt_of_leₓ bot_lt le_p), hp.IsPrime⟩,
      fun ⟨p, ne_bot, Prime⟩ => ⟨p, bot_lt_iff_ne_bot.mpr ne_bot, lt_top_iff_ne_top.mpr Prime.1⟩⟩

/-- When a ring is not a field, the maximal ideals are nontrivial. -/
theorem ne_bot_of_is_maximal_of_not_is_field [Nontrivial R] {M : Ideal R} (max : M.IsMaximal) (not_field : ¬IsField R) :
    M ≠ ⊥ := by
  rintro h
  rw [h] at max
  rcases max with ⟨⟨h1, h2⟩⟩
  obtain ⟨I, hIbot, hItop⟩ := not_is_field_iff_exists_ideal_bot_lt_and_lt_top.mp not_field
  exact ne_of_ltₓ hItop (h2 I hIbot)

end Ringₓ

namespace Ideal

variable {R : Type u} [CommRingₓ R] [Nontrivial R]

theorem bot_lt_of_maximal (M : Ideal R) [hm : M.IsMaximal] (non_field : ¬IsField R) : ⊥ < M := by
  rcases Ringₓ.not_is_field_iff_exists_ideal_bot_lt_and_lt_top.1 non_field with ⟨I, Ibot, Itop⟩
  constructor
  · simp
    
  intro mle
  apply @irrefl _ (· < ·) _ (⊤ : Ideal R)
  have : M = ⊥ := eq_bot_iff.mpr mle
  rw [this] at *
  rwa [hm.1.2 I Ibot] at Itop

end Ideal

variable {a b : α}

/-- The set of non-invertible elements of a monoid. -/
def Nonunits (α : Type u) [Monoidₓ α] : Set α :=
  { a | ¬IsUnit a }

@[simp]
theorem mem_nonunits_iff [Monoidₓ α] : a ∈ Nonunits α ↔ ¬IsUnit a :=
  Iff.rfl

theorem mul_mem_nonunits_right [CommMonoidₓ α] : b ∈ Nonunits α → a * b ∈ Nonunits α :=
  mt is_unit_of_mul_is_unit_right

theorem mul_mem_nonunits_left [CommMonoidₓ α] : a ∈ Nonunits α → a * b ∈ Nonunits α :=
  mt is_unit_of_mul_is_unit_left

theorem zero_mem_nonunits [Semiringₓ α] : 0 ∈ Nonunits α ↔ (0 : α) ≠ 1 :=
  not_congr is_unit_zero_iff

@[simp]
theorem one_not_mem_nonunits [Monoidₓ α] : (1 : α) ∉ Nonunits α :=
  not_not_intro is_unit_one

theorem coe_subset_nonunits [Semiringₓ α] {I : Ideal α} (h : I ≠ ⊤) : (I : Set α) ⊆ Nonunits α := fun x hx hu =>
  h <| I.eq_top_of_is_unit_mem hx hu

theorem exists_max_ideal_of_mem_nonunits [CommSemiringₓ α] (h : a ∈ Nonunits α) : ∃ I : Ideal α, I.IsMaximal ∧ a ∈ I :=
  by
  have : Ideal.span ({a} : Set α) ≠ ⊤ := by
    intro H
    rw [Ideal.span_singleton_eq_top] at H
    contradiction
  rcases Ideal.exists_le_maximal _ this with ⟨I, Imax, H⟩
  use I, Imax
  apply H
  apply Ideal.subset_span
  exact Set.mem_singleton a

