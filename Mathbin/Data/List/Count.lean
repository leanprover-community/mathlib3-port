import Mathbin.Data.List.BigOperators

/-!
# Counting in lists

This file proves basic properties of `list.countp` and `list.count`, which count the number of
elements of a list satisfying a predicate and equal to a given element respectively. Their
definitions can be found in [`data.list.defs`](./data/list/defs).
-/


open Nat

variable{α β : Type _}{l l₁ l₂ : List α}

namespace List

section Countp

variable(p : α → Prop)[DecidablePred p]

@[simp]
theorem countp_nil : countp p [] = 0 :=
  rfl

@[simp]
theorem countp_cons_of_pos {a : α} l (pa : p a) : countp p (a :: l) = countp p l+1 :=
  if_pos pa

@[simp]
theorem countp_cons_of_neg {a : α} l (pa : ¬p a) : countp p (a :: l) = countp p l :=
  if_neg pa

theorem length_eq_countp_add_countp l : length l = countp p l+countp (fun a => ¬p a) l :=
  by 
    induction' l with x h ih <;> [rfl, byCases' p x] <;>
        [simp only [countp_cons_of_pos _ _ h, countp_cons_of_neg (fun a => ¬p a) _ (Decidable.not_not.2 h), ih, length],
        simp only [countp_cons_of_pos (fun a => ¬p a) _ h, countp_cons_of_neg _ _ h, ih, length]] <;>
      acRfl

theorem countp_eq_length_filter l : countp p l = length (filter p l) :=
  by 
    induction' l with x l ih <;> [rfl, byCases' p x] <;> [simp only [filter_cons_of_pos _ h, countp, ih, if_pos h],
        simp only [countp_cons_of_neg _ _ h, ih, filter_cons_of_neg _ h]] <;>
      rfl

@[simp]
theorem countp_append l₁ l₂ : countp p (l₁ ++ l₂) = countp p l₁+countp p l₂ :=
  by 
    simp only [countp_eq_length_filter, filter_append, length_append]

theorem countp_pos {l} : 0 < countp p l ↔ ∃ (a : _)(_ : a ∈ l), p a :=
  by 
    simp only [countp_eq_length_filter, length_pos_iff_exists_mem, mem_filter, exists_prop]

theorem length_filter_lt_length_iff_exists l : length (filter p l) < length l ↔ ∃ (x : _)(_ : x ∈ l), ¬p x :=
  by 
    rw [length_eq_countp_add_countp p l, ←countp_pos, countp_eq_length_filter, lt_add_iff_pos_right]

theorem sublist.countp_le (s : l₁ <+ l₂) : countp p l₁ ≤ countp p l₂ :=
  by 
    simpa only [countp_eq_length_filter] using length_le_of_sublist (s.filter p)

@[simp]
theorem countp_filter {q} [DecidablePred q] (l : List α) : countp p (filter q l) = countp (fun a => p a ∧ q a) l :=
  by 
    simp only [countp_eq_length_filter, filter_filter]

end Countp

/-! ### count -/


section Count

variable[DecidableEq α]

@[simp]
theorem count_nil (a : α) : count a [] = 0 :=
  rfl

theorem count_cons (a b : α) (l : List α) : count a (b :: l) = if a = b then succ (count a l) else count a l :=
  rfl

theorem count_cons' (a b : α) (l : List α) : count a (b :: l) = count a l+if a = b then 1 else 0 :=
  by 
    rw [count_cons]
    splitIfs <;> rfl

@[simp]
theorem count_cons_self (a : α) (l : List α) : count a (a :: l) = succ (count a l) :=
  if_pos rfl

@[simp]
theorem count_cons_of_ne {a b : α} (h : a ≠ b) (l : List α) : count a (b :: l) = count a l :=
  if_neg h

theorem count_tail :
  ∀ (l : List α) (a : α) (h : 0 < l.length), l.tail.count a = l.count a - ite (a = List.nthLe l 0 h) 1 0
| _ :: _, a, h =>
  by 
    rw [count_cons]
    splitIfs <;> simp 

theorem sublist.count_le (h : l₁ <+ l₂) (a : α) : count a l₁ ≤ count a l₂ :=
  h.countp_le _

theorem count_le_count_cons (a b : α) (l : List α) : count a l ≤ count a (b :: l) :=
  (sublist_cons _ _).count_le _

theorem count_singleton (a : α) : count a [a] = 1 :=
  if_pos rfl

@[simp]
theorem count_append (a : α) : ∀ l₁ l₂, count a (l₁ ++ l₂) = count a l₁+count a l₂ :=
  countp_append _

theorem count_concat (a : α) (l : List α) : count a (concat l a) = succ (count a l) :=
  by 
    simp [-add_commₓ]

theorem count_pos {a : α} {l : List α} : 0 < count a l ↔ a ∈ l :=
  by 
    simp only [count, countp_pos, exists_prop, exists_eq_right']

@[simp]
theorem count_eq_zero_of_not_mem {a : α} {l : List α} (h : a ∉ l) : count a l = 0 :=
  Decidable.by_contradiction$ fun h' => h$ count_pos.1 (Nat.pos_of_ne_zeroₓ h')

theorem not_mem_of_count_eq_zero {a : α} {l : List α} (h : count a l = 0) : a ∉ l :=
  fun h' => (count_pos.2 h').ne' h

@[simp]
theorem count_repeat (a : α) (n : ℕ) : count a (repeat a n) = n :=
  by 
    rw [count, countp_eq_length_filter, filter_eq_self.2, length_repeat] <;> exact fun b m => (eq_of_mem_repeat m).symm

theorem le_count_iff_repeat_sublist {a : α} {l : List α} {n : ℕ} : n ≤ count a l ↔ repeat a n <+ l :=
  ⟨fun h =>
      ((repeat_sublist_repeat a).2 h).trans$
        have  : filter (Eq a) l = repeat a (count a l) :=
          eq_repeat.2
            ⟨by 
                simp only [count, countp_eq_length_filter],
              fun b m => (of_mem_filter m).symm⟩
        by 
          rw [←this] <;> apply filter_sublist,
    fun h =>
      by 
        simpa only [count_repeat] using h.count_le a⟩

theorem repeat_count_eq_of_count_eq_length {a : α} {l : List α} (h : count a l = length l) : repeat a (count a l) = l :=
  eq_of_sublist_of_length_eq (le_count_iff_repeat_sublist.mp (le_reflₓ (count a l)))
    (Eq.trans (length_repeat a (count a l)) h)

@[simp]
theorem count_filter {p} [DecidablePred p] {a} {l : List α} (h : p a) : count a (filter p l) = count a l :=
  by 
    simp only [count, countp_filter] <;> congr <;> exact Set.ext fun b => and_iff_left_of_imp fun e => e ▸ h

theorem count_bind {α β} [DecidableEq β] (l : List α) (f : α → List β) (x : β) :
  count x (l.bind f) = Sum (map (count x ∘ f) l) :=
  by 
    induction' l with hd tl IH
    ·
      simp 
    ·
      simpa

@[simp]
theorem count_map_map {α β} [DecidableEq α] [DecidableEq β] (l : List α) (f : α → β) (hf : Function.Injective f)
  (x : α) : count (f x) (map f l) = count x l :=
  by 
    induction' l with y l IH generalizing x
    ·
      simp 
    ·
      rw [map_cons]
      byCases' h : x = y
      ·
        simpa [h] using IH _
      ·
        simpa [h, hf.ne h] using IH _

-- error in Data.List.Count: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp] theorem count_erase_self (a : α) : ∀ s : list α, «expr = »(count a (list.erase s a), pred (count a s))
| «expr[ , ]»([]) := by simp [] [] [] [] [] []
| «expr :: »(h, t) := begin
  rw [expr erase_cons] [],
  by_cases [expr p, ":", expr «expr = »(h, a)],
  { rw ["[", expr if_pos p, ",", expr count_cons', ",", expr if_pos p.symm, "]"] [],
    simp [] [] [] [] [] [] },
  { rw ["[", expr if_neg p, ",", expr count_cons', ",", expr count_cons', ",", expr if_neg (λ
      x : «expr = »(a, h), p x.symm), ",", expr count_erase_self, "]"] [],
    simp [] [] [] [] [] [] }
end

@[simp]
theorem count_erase_of_ne {a b : α} (ab : a ≠ b) : ∀ (s : List α), count a (List.eraseₓ s b) = count a s
| [] =>
  by 
    simp 
| x :: xs =>
  by 
    rw [erase_cons]
    splitIfs with h
    ·
      rw [count_cons', h, if_neg ab]
      simp 
    ·
      rw [count_cons', count_cons', count_erase_of_ne]

end Count

end List

