import Mathbin.Data.Multiset.EraseDup

/-!
# Preparations for defining operations on `finset`.

The operations here ignore multiplicities,
and preparatory for defining the corresponding operations on `finset`.
-/


namespace Multiset

open List

variable{α : Type _}[DecidableEq α]

/-! ### finset insert -/


/-- `ndinsert a s` is the lift of the list `insert` operation. This operation
  does not respect multiplicities, unlike `cons`, but it is suitable as
  an insert operation on `finset`. -/
def ndinsert (a : α) (s : Multiset α) : Multiset α :=
  Quot.liftOn s (fun l => (l.insert a : Multiset α)) fun s t p => Quot.sound (p.insert a)

@[simp]
theorem coe_ndinsert (a : α) (l : List α) : ndinsert a l = (insert a l : List α) :=
  rfl

@[simp]
theorem ndinsert_zero (a : α) : ndinsert a 0 = {a} :=
  rfl

@[simp]
theorem ndinsert_of_mem {a : α} {s : Multiset α} : a ∈ s → ndinsert a s = s :=
  Quot.induction_on s$ fun l h => congr_argₓ coeₓ$ insert_of_mem h

@[simp]
theorem ndinsert_of_not_mem {a : α} {s : Multiset α} : a ∉ s → ndinsert a s = a ::ₘ s :=
  Quot.induction_on s$ fun l h => congr_argₓ coeₓ$ insert_of_not_mem h

@[simp]
theorem mem_ndinsert {a b : α} {s : Multiset α} : a ∈ ndinsert b s ↔ a = b ∨ a ∈ s :=
  Quot.induction_on s$ fun l => mem_insert_iff

@[simp]
theorem le_ndinsert_self (a : α) (s : Multiset α) : s ≤ ndinsert a s :=
  Quot.induction_on s$ fun l => (sublist_insert _ _).Subperm

@[simp]
theorem mem_ndinsert_self (a : α) (s : Multiset α) : a ∈ ndinsert a s :=
  mem_ndinsert.2 (Or.inl rfl)

theorem mem_ndinsert_of_mem {a b : α} {s : Multiset α} (h : a ∈ s) : a ∈ ndinsert b s :=
  mem_ndinsert.2 (Or.inr h)

@[simp]
theorem length_ndinsert_of_mem {a : α} {s : Multiset α} (h : a ∈ s) : card (ndinsert a s) = card s :=
  by 
    simp [h]

@[simp]
theorem length_ndinsert_of_not_mem {a : α} {s : Multiset α} (h : a ∉ s) : card (ndinsert a s) = card s+1 :=
  by 
    simp [h]

theorem erase_dup_cons {a : α} {s : Multiset α} : erase_dup (a ::ₘ s) = ndinsert a (erase_dup s) :=
  by 
    byCases' a ∈ s <;> simp [h]

theorem nodup_ndinsert (a : α) {s : Multiset α} : nodup s → nodup (ndinsert a s) :=
  Quot.induction_on s$ fun l => nodup_insert

theorem ndinsert_le {a : α} {s t : Multiset α} : ndinsert a s ≤ t ↔ s ≤ t ∧ a ∈ t :=
  ⟨fun h => ⟨le_transₓ (le_ndinsert_self _ _) h, mem_of_le h (mem_ndinsert_self _ _)⟩,
    fun ⟨l, m⟩ =>
      if h : a ∈ s then
        by 
          simp [h, l]
      else
        by 
          rw [ndinsert_of_not_mem h, ←cons_erase m, cons_le_cons_iff, ←le_cons_of_not_mem h, cons_erase m] <;> exact l⟩

-- error in Data.Multiset.FinsetOps: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem attach_ndinsert
(a : α)
(s : multiset α) : «expr = »((s.ndinsert a).attach, ndinsert ⟨a, mem_ndinsert_self a s⟩ «expr $ »(s.attach.map, λ
  p, ⟨p.1, mem_ndinsert_of_mem p.2⟩)) :=
have eq : ∀
h : ∀
p : {x // «expr ∈ »(x, s)}, «expr ∈ »(p.1, s), «expr = »((λ
 p : {x // «expr ∈ »(x, s)}, ⟨p.val, h p⟩ : {x // «expr ∈ »(x, s)} → {x // «expr ∈ »(x, s)}), id), from assume
h, «expr $ »(funext, assume p, subtype.eq rfl),
have ∀
(t)
(eq : «expr = »(s.ndinsert a, t)), «expr = »(t.attach, ndinsert ⟨a, «expr ▸ »(eq, mem_ndinsert_self a s)⟩ «expr $ »(s.attach.map, λ
  p, ⟨p.1, «expr ▸ »(eq, mem_ndinsert_of_mem p.2)⟩)), begin
  intros [ident t, ident ht],
  by_cases [expr «expr ∈ »(a, s)],
  { rw ["[", expr ndinsert_of_mem h, "]"] ["at", ident ht],
    subst [expr ht],
    rw ["[", expr eq, ",", expr map_id, ",", expr ndinsert_of_mem (mem_attach _ _), "]"] [] },
  { rw ["[", expr ndinsert_of_not_mem h, "]"] ["at", ident ht],
    subst [expr ht],
    simp [] [] [] ["[", expr attach_cons, ",", expr h, "]"] [] [] }
end,
this _ rfl

@[simp]
theorem disjoint_ndinsert_left {a : α} {s t : Multiset α} : Disjoint (ndinsert a s) t ↔ a ∉ t ∧ Disjoint s t :=
  Iff.trans
    (by 
      simp [Disjoint])
    disjoint_cons_left

@[simp]
theorem disjoint_ndinsert_right {a : α} {s t : Multiset α} : Disjoint s (ndinsert a t) ↔ a ∉ s ∧ Disjoint s t :=
  by 
    rw [disjoint_comm, disjoint_ndinsert_left] <;> tauto

/-! ### finset union -/


/-- `ndunion s t` is the lift of the list `union` operation. This operation
  does not respect multiplicities, unlike `s ∪ t`, but it is suitable as
  a union operation on `finset`. (`s ∪ t` would also work as a union operation
  on finset, but this is more efficient.) -/
def ndunion (s t : Multiset α) : Multiset α :=
  (Quotientₓ.liftOn₂ s t fun l₁ l₂ => (l₁.union l₂ : Multiset α))$ fun v₁ v₂ w₁ w₂ p₁ p₂ => Quot.sound$ p₁.union p₂

@[simp]
theorem coe_ndunion (l₁ l₂ : List α) : @ndunion α _ l₁ l₂ = (l₁ ∪ l₂ : List α) :=
  rfl

@[simp]
theorem zero_ndunion (s : Multiset α) : ndunion 0 s = s :=
  Quot.induction_on s$ fun l => rfl

@[simp]
theorem cons_ndunion (s t : Multiset α) (a : α) : ndunion (a ::ₘ s) t = ndinsert a (ndunion s t) :=
  Quotientₓ.induction_on₂ s t$ fun l₁ l₂ => rfl

@[simp]
theorem mem_ndunion {s t : Multiset α} {a : α} : a ∈ ndunion s t ↔ a ∈ s ∨ a ∈ t :=
  Quotientₓ.induction_on₂ s t$ fun l₁ l₂ => List.mem_union

theorem le_ndunion_right (s t : Multiset α) : t ≤ ndunion s t :=
  Quotientₓ.induction_on₂ s t$ fun l₁ l₂ => (suffix_union_right _ _).Sublist.Subperm

theorem subset_ndunion_right (s t : Multiset α) : t ⊆ ndunion s t :=
  subset_of_le (le_ndunion_right s t)

theorem ndunion_le_add (s t : Multiset α) : ndunion s t ≤ s+t :=
  Quotientₓ.induction_on₂ s t$ fun l₁ l₂ => (union_sublist_append _ _).Subperm

-- error in Data.Multiset.FinsetOps: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem ndunion_le
{s t u : multiset α} : «expr ↔ »(«expr ≤ »(ndunion s t, u), «expr ∧ »(«expr ⊆ »(s, u), «expr ≤ »(t, u))) :=
multiset.induction_on s (by simp [] [] [] [] [] []) (by simp [] [] [] ["[", expr ndinsert_le, ",", expr and_comm, ",", expr and.left_comm, "]"] [] [] { contextual := tt })

theorem subset_ndunion_left (s t : Multiset α) : s ⊆ ndunion s t :=
  fun a h => mem_ndunion.2$ Or.inl h

theorem le_ndunion_left {s} (t : Multiset α) (d : nodup s) : s ≤ ndunion s t :=
  (le_iff_subset d).2$ subset_ndunion_left _ _

theorem ndunion_le_union (s t : Multiset α) : ndunion s t ≤ s ∪ t :=
  ndunion_le.2 ⟨subset_of_le (le_union_left _ _), le_union_right _ _⟩

theorem nodup_ndunion (s : Multiset α) {t : Multiset α} : nodup t → nodup (ndunion s t) :=
  Quotientₓ.induction_on₂ s t$ fun l₁ l₂ => List.nodup_union _

@[simp]
theorem ndunion_eq_union {s t : Multiset α} (d : nodup s) : ndunion s t = s ∪ t :=
  le_antisymmₓ (ndunion_le_union _ _)$ union_le (le_ndunion_left _ d) (le_ndunion_right _ _)

theorem erase_dup_add (s t : Multiset α) : erase_dup (s+t) = ndunion s (erase_dup t) :=
  Quotientₓ.induction_on₂ s t$ fun l₁ l₂ => congr_argₓ coeₓ$ erase_dup_append _ _

/-! ### finset inter -/


/-- `ndinter s t` is the lift of the list `∩` operation. This operation
  does not respect multiplicities, unlike `s ∩ t`, but it is suitable as
  an intersection operation on `finset`. (`s ∩ t` would also work as a union operation
  on finset, but this is more efficient.) -/
def ndinter (s t : Multiset α) : Multiset α :=
  filter (· ∈ t) s

@[simp]
theorem coe_ndinter (l₁ l₂ : List α) : @ndinter α _ l₁ l₂ = (l₁ ∩ l₂ : List α) :=
  rfl

@[simp]
theorem zero_ndinter (s : Multiset α) : ndinter 0 s = 0 :=
  rfl

@[simp]
theorem cons_ndinter_of_mem {a : α} (s : Multiset α) {t : Multiset α} (h : a ∈ t) :
  ndinter (a ::ₘ s) t = a ::ₘ ndinter s t :=
  by 
    simp [ndinter, h]

@[simp]
theorem ndinter_cons_of_not_mem {a : α} (s : Multiset α) {t : Multiset α} (h : a ∉ t) :
  ndinter (a ::ₘ s) t = ndinter s t :=
  by 
    simp [ndinter, h]

@[simp]
theorem mem_ndinter {s t : Multiset α} {a : α} : a ∈ ndinter s t ↔ a ∈ s ∧ a ∈ t :=
  mem_filter

@[simp]
theorem nodup_ndinter {s : Multiset α} (t : Multiset α) : nodup s → nodup (ndinter s t) :=
  nodup_filter _

theorem le_ndinter {s t u : Multiset α} : s ≤ ndinter t u ↔ s ≤ t ∧ s ⊆ u :=
  by 
    simp [ndinter, le_filter, subset_iff]

theorem ndinter_le_left (s t : Multiset α) : ndinter s t ≤ s :=
  (le_ndinter.1 (le_reflₓ _)).1

theorem ndinter_subset_left (s t : Multiset α) : ndinter s t ⊆ s :=
  subset_of_le (ndinter_le_left s t)

theorem ndinter_subset_right (s t : Multiset α) : ndinter s t ⊆ t :=
  (le_ndinter.1 (le_reflₓ _)).2

theorem ndinter_le_right {s} (t : Multiset α) (d : nodup s) : ndinter s t ≤ t :=
  (le_iff_subset$ nodup_ndinter _ d).2 (ndinter_subset_right _ _)

theorem inter_le_ndinter (s t : Multiset α) : s ∩ t ≤ ndinter s t :=
  le_ndinter.2 ⟨inter_le_left _ _, subset_of_le$ inter_le_right _ _⟩

@[simp]
theorem ndinter_eq_inter {s t : Multiset α} (d : nodup s) : ndinter s t = s ∩ t :=
  le_antisymmₓ (le_inter (ndinter_le_left _ _) (ndinter_le_right _ d)) (inter_le_ndinter _ _)

theorem ndinter_eq_zero_iff_disjoint {s t : Multiset α} : ndinter s t = 0 ↔ Disjoint s t :=
  by 
    rw [←subset_zero] <;> simp [subset_iff, Disjoint]

end Multiset

