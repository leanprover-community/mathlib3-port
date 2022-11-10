/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Kenny Lau, Scott Morrison
-/
import Mathbin.Data.List.Chain
import Mathbin.Data.List.Nodup
import Mathbin.Data.List.OfFn
import Mathbin.Data.List.Zip

/-!
# Ranges of naturals as lists

This file shows basic results about `list.iota`, `list.range`, `list.range'` (all defined in
`data.list.defs`) and defines `list.fin_range`.
`fin_range n` is the list of elements of `fin n`.
`iota n = [n, n - 1, ..., 1]` and `range n = [0, ..., n - 1]` are basic list constructions used for
tactics. `range' a b = [a, ..., a + b - 1]` is there to help prove properties about them.
Actual maths should use `list.Ico` instead.
-/


universe u

open Nat

namespace List

variable {α : Type u}

@[simp]
theorem length_range' : ∀ s n : ℕ, length (range' s n) = n
  | s, 0 => rfl
  | s, n + 1 => congr_arg succ (length_range' _ _)

@[simp]
theorem range'_eq_nil {s n : ℕ} : range' s n = [] ↔ n = 0 := by rw [← length_eq_zero, length_range']

#print List.mem_range' /-
@[simp]
theorem mem_range' {m : ℕ} : ∀ {s n : ℕ}, m ∈ range' s n ↔ s ≤ m ∧ m < s + n
  | s, 0 => (false_iff_iff _).2 fun ⟨H1, H2⟩ => not_le_of_lt H2 H1
  | s, succ n =>
    have : m = s → m < s + n + 1 := fun e => e ▸ lt_succ_of_le (Nat.le_add_right _ _)
    have l : m = s ∨ s + 1 ≤ m ↔ s ≤ m := by simpa only [eq_comm] using (@Decidable.le_iff_eq_or_lt _ _ _ s m).symm
    (mem_cons_iff _ _ _).trans <| by
      simp only [mem_range', or_and_left, or_iff_right_of_imp this, l, add_right_comm] <;> rfl
-/

theorem map_add_range' (a) : ∀ s n : ℕ, map ((· + ·) a) (range' s n) = range' (a + s) n
  | s, 0 => rfl
  | s, n + 1 => congr_arg (cons _) (map_add_range' (s + 1) n)

theorem map_sub_range' (a) : ∀ (s n : ℕ) (h : a ≤ s), map (fun x => x - a) (range' s n) = range' (s - a) n
  | s, 0, _ => rfl
  | s, n + 1, h => by
    convert congr_arg (cons (s - a)) (map_sub_range' (s + 1) n (Nat.le_succ_of_le h))
    rw [Nat.succ_sub h]
    rfl

#print List.chain_succ_range' /-
theorem chain_succ_range' : ∀ s n : ℕ, Chain (fun a b => b = succ a) s (range' (s + 1) n)
  | s, 0 => Chain.nil
  | s, n + 1 => (chain_succ_range' (s + 1) n).cons rfl
-/

#print List.chain_lt_range' /-
theorem chain_lt_range' (s n : ℕ) : Chain (· < ·) s (range' (s + 1) n) :=
  (chain_succ_range' s n).imp fun a b e => e.symm ▸ lt_succ_self _
-/

#print List.pairwise_lt_range' /-
theorem pairwise_lt_range' : ∀ s n : ℕ, Pairwise (· < ·) (range' s n)
  | s, 0 => Pairwise.nil
  | s, n + 1 => chain_iff_pairwise.1 (chain_lt_range' s n)
-/

#print List.nodup_range' /-
theorem nodup_range' (s n : ℕ) : Nodup (range' s n) :=
  (pairwise_lt_range' s n).imp fun a b => ne_of_lt
-/

@[simp]
theorem range'_append : ∀ s m n : ℕ, range' s m ++ range' (s + m) n = range' s (n + m)
  | s, 0, n => rfl
  | s, m + 1, n =>
    show s :: (range' (s + 1) m ++ range' (s + m + 1) n) = s :: range' (s + 1) (n + m) by
      rw [add_right_comm, range'_append]

theorem range'_sublist_right {s m n : ℕ} : range' s m <+ range' s n ↔ m ≤ n :=
  ⟨fun h => by simpa only [length_range'] using h.length_le, fun h => by
    rw [← tsub_add_cancel_of_le h, ← range'_append] <;> apply sublist_append_left⟩

theorem range'_subset_right {s m n : ℕ} : range' s m ⊆ range' s n ↔ m ≤ n :=
  ⟨fun h =>
    le_of_not_lt fun hn =>
      lt_irrefl (s + n) <| (mem_range'.1 <| h <| mem_range'.2 ⟨Nat.le_add_right _ _, Nat.add_lt_add_left hn s⟩).2,
    fun h => (range'_sublist_right.2 h).Subset⟩

theorem nth_range' : ∀ (s) {m n : ℕ}, m < n → nth (range' s n) m = some (s + m)
  | s, 0, n + 1, _ => rfl
  | s, m + 1, n + 1, h => (nth_range' (s + 1) (lt_of_add_lt_add_right h)).trans <| by rw [add_right_comm] <;> rfl

@[simp]
theorem nth_le_range' {n m} (i) (H : i < (range' n m).length) : nthLe (range' n m) i H = n + i :=
  Option.some.inj <| by rw [← nth_le_nth _, nth_range' _ (by simpa using H)]

theorem range'_concat (s n : ℕ) : range' s (n + 1) = range' s n ++ [s + n] := by
  rw [add_comm n 1] <;> exact (range'_append s n 1).symm

theorem range_core_range' : ∀ s n : ℕ, rangeCore s (range' s n) = range' 0 (n + s)
  | 0, n => rfl
  | s + 1, n => by rw [show n + (s + 1) = n + 1 + s from add_right_comm n s 1] <;> exact range_core_range' s (n + 1)

#print List.range_eq_range' /-
theorem range_eq_range' (n : ℕ) : range n = range' 0 n :=
  (range_core_range' n 0).trans <| by rw [zero_add]
-/

theorem range_succ_eq_map (n : ℕ) : range (n + 1) = 0 :: map succ (range n) := by
  rw [range_eq_range', range_eq_range', range', add_comm, ← map_add_range'] <;> congr <;> exact funext one_add

theorem range'_eq_map_range (s n : ℕ) : range' s n = map ((· + ·) s) (range n) := by
  rw [range_eq_range', map_add_range'] <;> rfl

@[simp]
theorem length_range (n : ℕ) : length (range n) = n := by simp only [range_eq_range', length_range']

@[simp]
theorem range_eq_nil {n : ℕ} : range n = [] ↔ n = 0 := by rw [← length_eq_zero, length_range]

theorem pairwise_lt_range (n : ℕ) : Pairwise (· < ·) (range n) := by simp only [range_eq_range', pairwise_lt_range']

theorem pairwise_le_range (n : ℕ) : Pairwise (· ≤ ·) (range n) :=
  Pairwise.imp (@le_of_lt ℕ _) (pairwise_lt_range _)

#print List.nodup_range /-
theorem nodup_range (n : ℕ) : Nodup (range n) := by simp only [range_eq_range', nodup_range']
-/

theorem range_sublist {m n : ℕ} : range m <+ range n ↔ m ≤ n := by simp only [range_eq_range', range'_sublist_right]

theorem range_subset {m n : ℕ} : range m ⊆ range n ↔ m ≤ n := by simp only [range_eq_range', range'_subset_right]

#print List.mem_range /-
@[simp]
theorem mem_range {m n : ℕ} : m ∈ range n ↔ m < n := by
  simp only [range_eq_range', mem_range', Nat.zero_le, true_and_iff, zero_add]
-/

@[simp]
theorem not_mem_range_self {n : ℕ} : n ∉ range n :=
  mt mem_range.1 <| lt_irrefl _

@[simp]
theorem self_mem_range_succ (n : ℕ) : n ∈ range (n + 1) := by simp only [succ_pos', lt_add_iff_pos_right, mem_range]

theorem nth_range {m n : ℕ} (h : m < n) : nth (range n) m = some m := by
  simp only [range_eq_range', nth_range' _ h, zero_add]

theorem range_succ (n : ℕ) : range (succ n) = range n ++ [n] := by simp only [range_eq_range', range'_concat, zero_add]

@[simp]
theorem range_zero : range 0 = [] :=
  rfl

theorem chain'_range_succ (r : ℕ → ℕ → Prop) (n : ℕ) : Chain' r (range n.succ) ↔ ∀ m < n, r m m.succ := by
  rw [range_succ]
  induction' n with n hn
  · simp
    
  · rw [range_succ]
    simp only [append_assoc, singleton_append, chain'_append_cons_cons, chain'_singleton, and_true_iff]
    rw [hn, forall_lt_succ]
    

theorem chain_range_succ (r : ℕ → ℕ → Prop) (n a : ℕ) : Chain r a (range n.succ) ↔ r a 0 ∧ ∀ m < n, r m m.succ := by
  rw [range_succ_eq_map, chain_cons, and_congr_right_iff, ← chain'_range_succ, range_succ_eq_map]
  exact fun _ => Iff.rfl

theorem range_add (a : ℕ) : ∀ b, range (a + b) = range a ++ (range b).map fun x => a + x
  | 0 => by rw [add_zero, range_zero, map_nil, append_nil]
  | b + 1 => by rw [Nat.add_succ, range_succ, range_add b, range_succ, map_append, map_singleton, append_assoc]

theorem iota_eq_reverse_range' : ∀ n : ℕ, iota n = reverse (range' 1 n)
  | 0 => rfl
  | n + 1 => by simp only [iota, range'_concat, iota_eq_reverse_range' n, reverse_append, add_comm] <;> rfl

@[simp]
theorem length_iota (n : ℕ) : length (iota n) = n := by
  simp only [iota_eq_reverse_range', length_reverse, length_range']

theorem pairwise_gt_iota (n : ℕ) : Pairwise (· > ·) (iota n) := by
  simp only [iota_eq_reverse_range', pairwise_reverse, pairwise_lt_range']

theorem nodup_iota (n : ℕ) : Nodup (iota n) := by simp only [iota_eq_reverse_range', nodup_reverse, nodup_range']

theorem mem_iota {m n : ℕ} : m ∈ iota n ↔ 1 ≤ m ∧ m ≤ n := by
  simp only [iota_eq_reverse_range', mem_reverse, mem_range', add_comm, lt_succ_iff]

theorem reverse_range' : ∀ s n : ℕ, reverse (range' s n) = map (fun i => s + n - 1 - i) (range n)
  | s, 0 => rfl
  | s, n + 1 => by
    rw [range'_concat, reverse_append, range_succ_eq_map] <;>
      simpa only [show s + (n + 1) - 1 = s + n from rfl, (· ∘ ·), fun a i =>
        show a - 1 - i = a - succ i from pred_sub _ _, reverse_singleton, map_cons, tsub_zero, cons_append, nil_append,
        eq_self_iff_true, true_and_iff, map_map] using reverse_range' s n

#print List.finRange /-
/-- All elements of `fin n`, from `0` to `n-1`. The corresponding finset is `finset.univ`. -/
def finRange (n : ℕ) : List (Fin n) :=
  (range n).pmap Fin.mk fun _ => List.mem_range.1
-/

#print List.fin_range_zero /-
@[simp]
theorem fin_range_zero : finRange 0 = [] :=
  rfl
-/

#print List.mem_fin_range /-
@[simp]
theorem mem_fin_range {n : ℕ} (a : Fin n) : a ∈ finRange n :=
  mem_pmap.2 ⟨a.1, mem_range.2 a.2, Fin.eta _ _⟩
-/

#print List.nodup_fin_range /-
theorem nodup_fin_range (n : ℕ) : (finRange n).Nodup :=
  (nodup_range _).pmap fun _ _ _ _ => Fin.veq_of_eq
-/

@[simp]
theorem length_fin_range (n : ℕ) : (finRange n).length = n := by rw [fin_range, length_pmap, length_range]

@[simp]
theorem fin_range_eq_nil {n : ℕ} : finRange n = [] ↔ n = 0 := by rw [← length_eq_zero, length_fin_range]

@[simp]
theorem map_coe_fin_range (n : ℕ) : (finRange n).map coe = List.range n := by
  simp_rw [fin_range, map_pmap, Fin.coe_mk, pmap_eq_map]
  exact List.map_id _

theorem fin_range_succ_eq_map (n : ℕ) : finRange n.succ = 0 :: (finRange n).map Fin.succ := by
  apply map_injective_iff.mpr Fin.coe_injective
  rw [map_cons, map_coe_fin_range, range_succ_eq_map, Fin.coe_zero, ← map_coe_fin_range, map_map, map_map,
    Function.comp, Function.comp]
  congr 2 with x
  exact (Fin.coe_succ _).symm

@[to_additive]
theorem prod_range_succ {α : Type u} [Monoid α] (f : ℕ → α) (n : ℕ) :
    ((range n.succ).map f).Prod = ((range n).map f).Prod * f n := by
  rw [range_succ, map_append, map_singleton, prod_append, prod_cons, prod_nil, mul_one]

/-- A variant of `prod_range_succ` which pulls off the first
  term in the product rather than the last.-/
@[to_additive "A variant of `sum_range_succ` which pulls off the first term in the sum\n  rather than the last."]
theorem prod_range_succ' {α : Type u} [Monoid α] (f : ℕ → α) (n : ℕ) :
    ((range n.succ).map f).Prod = f 0 * ((range n).map fun i => f (succ i)).Prod :=
  Nat.recOn n (show 1 * f 0 = f 0 * 1 by rw [one_mul, mul_one]) fun _ hd => by
    rw [List.prod_range_succ, hd, mul_assoc, ← List.prod_range_succ]

@[simp]
theorem enum_from_map_fst : ∀ (n) (l : List α), map Prod.fst (enumFrom n l) = range' n l.length
  | n, [] => rfl
  | n, a :: l => congr_arg (cons _) (enum_from_map_fst _ _)

@[simp]
theorem enum_map_fst (l : List α) : map Prod.fst (enum l) = range l.length := by
  simp only [enum, enum_from_map_fst, range_eq_range']

theorem enum_eq_zip_range (l : List α) : l.enum = (range l.length).zip l :=
  zip_of_prod (enum_map_fst _) (enum_map_snd _)

@[simp]
theorem unzip_enum_eq_prod (l : List α) : l.enum.unzip = (range l.length, l) := by
  simp only [enum_eq_zip_range, unzip_zip, length_range]

theorem enum_from_eq_zip_range' (l : List α) {n : ℕ} : l.enumFrom n = (range' n l.length).zip l :=
  zip_of_prod (enum_from_map_fst _ _) (enum_from_map_snd _ _)

@[simp]
theorem unzip_enum_from_eq_prod (l : List α) {n : ℕ} : (l.enumFrom n).unzip = (range' n l.length, l) := by
  simp only [enum_from_eq_zip_range', unzip_zip, length_range']

@[simp]
theorem nth_le_range {n} (i) (H : i < (range n).length) : nthLe (range n) i H = i :=
  Option.some.inj <| by rw [← nth_le_nth _, nth_range (by simpa using H)]

@[simp]
theorem nth_le_fin_range {n : ℕ} {i : ℕ} (h) : (finRange n).nthLe i h = ⟨i, length_fin_range n ▸ h⟩ := by
  simp only [fin_range, nth_le_range, nth_le_pmap]

@[simp]
theorem map_nth_le (l : List α) : ((finRange l.length).map fun n => l.nthLe n n.2) = l :=
  (ext_le (by rw [length_map, length_fin_range])) fun n _ h => by
    rw [← nth_le_map_rev]
    congr
    · rw [nth_le_fin_range]
      rfl
      
    · rw [length_fin_range]
      exact h
      

theorem of_fn_eq_pmap {α n} {f : Fin n → α} : ofFn f = pmap (fun i hi => f ⟨i, hi⟩) (range n) fun _ => mem_range.1 := by
  rw [pmap_eq_map_attach] <;>
    exact
      ext_le (by simp) fun i hi1 hi2 => by
        simp at hi1
        simp [nth_le_of_fn f ⟨i, hi1⟩, -Subtype.val_eq_coe]

theorem of_fn_id (n) : ofFn id = finRange n :=
  of_fn_eq_pmap

theorem of_fn_eq_map {α n} {f : Fin n → α} : ofFn f = (finRange n).map f := by
  rw [← of_fn_id, map_of_fn, Function.right_id]

theorem nodup_of_fn {α n} {f : Fin n → α} (hf : Function.Injective f) : Nodup (ofFn f) := by
  rw [of_fn_eq_pmap]
  exact (nodup_range n).pmap fun _ _ _ _ H => Fin.veq_of_eq <| hf H

end List

