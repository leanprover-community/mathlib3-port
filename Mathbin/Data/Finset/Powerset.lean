import Mathbin.Data.Finset.Lattice

/-!
# The powerset of a finset
-/


namespace Finset

open Multiset

variable{α : Type _}

/-! ### powerset -/


section Powerset

/-- When `s` is a finset, `s.powerset` is the finset of all subsets of `s` (seen as finsets). -/
def powerset (s : Finset α) : Finset (Finset α) :=
  ⟨s.1.Powerset.pmap Finset.mk fun t h => nodup_of_le (mem_powerset.1 h) s.2,
    nodup_pmap (fun a ha b hb => congr_argₓ Finset.val) (nodup_powerset.2 s.2)⟩

@[simp]
theorem mem_powerset {s t : Finset α} : s ∈ powerset t ↔ s ⊆ t :=
  by 
    cases s <;> simp only [powerset, mem_mk, mem_pmap, mem_powerset, exists_prop, exists_eq_right] <;> rw [←val_le_iff]

@[simp]
theorem empty_mem_powerset (s : Finset α) : ∅ ∈ powerset s :=
  mem_powerset.2 (empty_subset _)

@[simp]
theorem mem_powerset_self (s : Finset α) : s ∈ powerset s :=
  mem_powerset.2 (subset.refl _)

@[simp]
theorem powerset_empty : Finset.powerset (∅ : Finset α) = {∅} :=
  rfl

@[simp]
theorem powerset_mono {s t : Finset α} : powerset s ⊆ powerset t ↔ s ⊆ t :=
  ⟨fun h => mem_powerset.1$ h$ mem_powerset_self _, fun st u h => mem_powerset.2$ subset.trans (mem_powerset.1 h) st⟩

/-- **Number of Subsets of a Set** -/
@[simp]
theorem card_powerset (s : Finset α) : card (powerset s) = 2 ^ card s :=
  (card_pmap _ _ _).trans (card_powerset s.1)

theorem not_mem_of_mem_powerset_of_not_mem {s t : Finset α} {a : α} (ht : t ∈ s.powerset) (h : a ∉ s) : a ∉ t :=
  by 
    apply mt _ h 
    apply mem_powerset.1 ht

-- error in Data.Finset.Powerset: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem powerset_insert
[decidable_eq α]
(s : finset α)
(a : α) : «expr = »(powerset (insert a s), «expr ∪ »(s.powerset, s.powerset.image (insert a))) :=
begin
  ext [] [ident t] [],
  simp [] [] ["only"] ["[", expr exists_prop, ",", expr mem_powerset, ",", expr mem_image, ",", expr mem_union, ",", expr subset_insert_iff, "]"] [] [],
  by_cases [expr h, ":", expr «expr ∈ »(a, t)],
  { split,
    { exact [expr λ H, or.inr ⟨_, H, insert_erase h⟩] },
    { intros [ident H],
      cases [expr H] [],
      { exact [expr subset.trans (erase_subset a t) H] },
      { rcases [expr H, "with", "⟨", ident u, ",", ident hu, "⟩"],
        rw ["<-", expr hu.2] [],
        exact [expr subset.trans (erase_insert_subset a u) hu.1] } } },
  { have [] [":", expr «expr¬ »(«expr∃ , »((u : finset α), «expr ∧ »(«expr ⊆ »(u, s), «expr = »(insert a u, t))))] [],
    by simp [] [] [] ["[", expr ne.symm (ne_insert_of_not_mem _ _ h), "]"] [] [],
    simp [] [] [] ["[", expr finset.erase_eq_of_not_mem h, ",", expr this, "]"] [] [] }
end

/-- For predicate `p` decidable on subsets, it is decidable whether `p` holds for any subset. -/
instance decidable_exists_of_decidable_subsets {s : Finset α} {p : ∀ t (_ : t ⊆ s), Prop}
  [∀ t (h : t ⊆ s), Decidable (p t h)] : Decidable (∃ (t : _)(h : t ⊆ s), p t h) :=
  decidableOfIff (∃ (t : _)(hs : t ∈ s.powerset), p t (mem_powerset.1 hs))
    ⟨fun ⟨t, _, hp⟩ => ⟨t, _, hp⟩, fun ⟨t, hs, hp⟩ => ⟨t, mem_powerset.2 hs, hp⟩⟩

/-- For predicate `p` decidable on subsets, it is decidable whether `p` holds for every subset. -/
instance decidable_forall_of_decidable_subsets {s : Finset α} {p : ∀ t (_ : t ⊆ s), Prop}
  [∀ t (h : t ⊆ s), Decidable (p t h)] : Decidable (∀ t (h : t ⊆ s), p t h) :=
  decidableOfIff (∀ t (h : t ∈ s.powerset), p t (mem_powerset.1 h))
    ⟨fun h t hs => h t (mem_powerset.2 hs), fun h _ _ => h _ _⟩

/-- A version of `finset.decidable_exists_of_decidable_subsets` with a non-dependent `p`.
Typeclass inference cannot find `hu` here, so this is not an instance. -/
def decidable_exists_of_decidable_subsets' {s : Finset α} {p : Finset α → Prop}
  (hu : ∀ t (h : t ⊆ s), Decidable (p t)) : Decidable (∃ (t : _)(h : t ⊆ s), p t) :=
  @Finset.decidableExistsOfDecidableSubsets _ _ _ hu

/-- A version of `finset.decidable_forall_of_decidable_subsets` with a non-dependent `p`.
Typeclass inference cannot find `hu` here, so this is not an instance. -/
def decidable_forall_of_decidable_subsets' {s : Finset α} {p : Finset α → Prop}
  (hu : ∀ t (h : t ⊆ s), Decidable (p t)) : Decidable (∀ t (h : t ⊆ s), p t) :=
  @Finset.decidableForallOfDecidableSubsets _ _ _ hu

end Powerset

section Ssubsets

variable[DecidableEq α]

/-- For `s` a finset, `s.ssubsets` is the finset comprising strict subsets of `s`. -/
def ssubsets (s : Finset α) : Finset (Finset α) :=
  erase (powerset s) s

@[simp]
theorem mem_ssubsets {s t : Finset α} : t ∈ s.ssubsets ↔ t ⊂ s :=
  by 
    rw [ssubsets, mem_erase, mem_powerset, ssubset_iff_subset_ne, And.comm]

theorem empty_mem_ssubsets {s : Finset α} (h : s.nonempty) : ∅ ∈ s.ssubsets :=
  by 
    rw [mem_ssubsets, ssubset_iff_subset_ne]
    exact ⟨empty_subset s, h.ne_empty.symm⟩

/-- For predicate `p` decidable on ssubsets, it is decidable whether `p` holds for any ssubset. -/
instance decidable_exists_of_decidable_ssubsets {s : Finset α} {p : ∀ t (_ : t ⊂ s), Prop}
  [∀ t (h : t ⊂ s), Decidable (p t h)] : Decidable (∃ t h, p t h) :=
  decidableOfIff (∃ (t : _)(hs : t ∈ s.ssubsets), p t (mem_ssubsets.1 hs))
    ⟨fun ⟨t, _, hp⟩ => ⟨t, _, hp⟩, fun ⟨t, hs, hp⟩ => ⟨t, mem_ssubsets.2 hs, hp⟩⟩

/-- For predicate `p` decidable on ssubsets, it is decidable whether `p` holds for every ssubset. -/
instance decidable_forall_of_decidable_ssubsets {s : Finset α} {p : ∀ t (_ : t ⊂ s), Prop}
  [∀ t (h : t ⊂ s), Decidable (p t h)] : Decidable (∀ t h, p t h) :=
  decidableOfIff (∀ t (h : t ∈ s.ssubsets), p t (mem_ssubsets.1 h))
    ⟨fun h t hs => h t (mem_ssubsets.2 hs), fun h _ _ => h _ _⟩

/-- A version of `finset.decidable_exists_of_decidable_ssubsets` with a non-dependent `p`.
Typeclass inference cannot find `hu` here, so this is not an instance. -/
def decidable_exists_of_decidable_ssubsets' {s : Finset α} {p : Finset α → Prop}
  (hu : ∀ t (h : t ⊂ s), Decidable (p t)) : Decidable (∃ (t : _)(h : t ⊂ s), p t) :=
  @Finset.decidableExistsOfDecidableSsubsets _ _ _ _ hu

/-- A version of `finset.decidable_forall_of_decidable_ssubsets` with a non-dependent `p`.
Typeclass inference cannot find `hu` here, so this is not an instance. -/
def decidable_forall_of_decidable_ssubsets' {s : Finset α} {p : Finset α → Prop}
  (hu : ∀ t (h : t ⊂ s), Decidable (p t)) : Decidable (∀ t (h : t ⊂ s), p t) :=
  @Finset.decidableForallOfDecidableSsubsets _ _ _ _ hu

end Ssubsets

section PowersetLen

/-- Given an integer `n` and a finset `s`, then `powerset_len n s` is the finset of subsets of `s`
of cardinality `n`. -/
def powerset_len (n : ℕ) (s : Finset α) : Finset (Finset α) :=
  ⟨(s.1.powersetLen n).pmap Finset.mk fun t h => nodup_of_le (mem_powerset_len.1 h).1 s.2,
    nodup_pmap (fun a ha b hb => congr_argₓ Finset.val) (nodup_powerset_len s.2)⟩

/-- **Formula for the Number of Combinations** -/
theorem mem_powerset_len {n} {s t : Finset α} : s ∈ powerset_len n t ↔ s ⊆ t ∧ card s = n :=
  by 
    cases s <;> simp [powerset_len, val_le_iff.symm] <;> rfl

@[simp]
theorem powerset_len_mono {n} {s t : Finset α} (h : s ⊆ t) : powerset_len n s ⊆ powerset_len n t :=
  fun u h' => mem_powerset_len.2$ And.imp (fun h₂ => subset.trans h₂ h) id (mem_powerset_len.1 h')

/-- **Formula for the Number of Combinations** -/
@[simp]
theorem card_powerset_len (n : ℕ) (s : Finset α) : card (powerset_len n s) = Nat.choose (card s) n :=
  (card_pmap _ _ _).trans (card_powerset_len n s.1)

@[simp]
theorem powerset_len_zero (s : Finset α) : Finset.powersetLen 0 s = {∅} :=
  by 
    ext 
    rw [mem_powerset_len, mem_singleton, card_eq_zero]
    refine'
      ⟨fun h => h.2,
        fun h =>
          by 
            rw [h]
            exact ⟨empty_subset s, rfl⟩⟩

@[simp]
theorem powerset_len_empty (n : ℕ) {s : Finset α} (h : s.card < n) : powerset_len n s = ∅ :=
  Finset.card_eq_zero.mp
    (by 
      rw [card_powerset_len, Nat.choose_eq_zero_of_lt h])

theorem powerset_len_eq_filter {n} {s : Finset α} : powerset_len n s = (powerset s).filter fun x => x.card = n :=
  by 
    ext 
    simp [mem_powerset_len]

-- error in Data.Finset.Powerset: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem powerset_len_succ_insert
[decidable_eq α]
{x : α}
{s : finset α}
(h : «expr ∉ »(x, s))
(n : exprℕ()) : «expr = »(powerset_len n.succ (insert x s), «expr ∪ »(powerset_len n.succ s, (powerset_len n s).image (insert x))) :=
begin
  rw ["[", expr powerset_len_eq_filter, ",", expr powerset_insert, ",", expr filter_union, ",", "<-", expr powerset_len_eq_filter, "]"] [],
  congr,
  rw ["[", expr powerset_len_eq_filter, ",", expr image_filter, "]"] [],
  congr' [1] [],
  ext [] [ident t] [],
  simp [] [] ["only"] ["[", expr mem_powerset, ",", expr mem_filter, ",", expr function.comp_app, ",", expr and.congr_right_iff, "]"] [] [],
  intro [ident ht],
  have [] [":", expr «expr ∉ »(x, t)] [":=", expr λ H, h (ht H)],
  simp [] [] [] ["[", expr card_insert_of_not_mem this, ",", expr nat.succ_inj', "]"] [] []
end

theorem powerset_len_nonempty {n : ℕ} {s : Finset α} (h : n < s.card) : (powerset_len n s).Nonempty :=
  by 
    classical 
    induction' s using Finset.induction_on with x s hx IH generalizing n
    ·
      simpa using h
    ·
      cases n
      ·
        simp 
      ·
        rw [card_insert_of_not_mem hx, Nat.succ_lt_succ_iff] at h 
        rw [powerset_len_succ_insert hx]
        refine' nonempty.mono _ ((IH h).Image (insert x))
        convert subset_union_right _ _

@[simp]
theorem powerset_len_self (s : Finset α) : powerset_len s.card s = {s} :=
  by 
    ext 
    rw [mem_powerset_len, mem_singleton]
    split 
    ·
      exact fun ⟨hs, hc⟩ => eq_of_subset_of_card_le hs hc.ge
    ·
      rintro rfl 
      simp 

theorem powerset_card_bUnion [DecidableEq (Finset α)] (s : Finset α) :
  Finset.powerset s = (range (s.card+1)).bUnion fun i => powerset_len i s :=
  by 
    refine' ext fun a => ⟨fun ha => _, fun ha => _⟩
    ·
      rw [mem_bUnion]
      exact
        ⟨a.card, mem_range.mpr (Nat.lt_succ_of_leₓ (card_le_of_subset (mem_powerset.mp ha))),
          mem_powerset_len.mpr ⟨mem_powerset.mp ha, rfl⟩⟩
    ·
      rcases mem_bUnion.mp ha with ⟨i, hi, ha⟩
      exact mem_powerset.mpr (mem_powerset_len.mp ha).1

theorem powerset_len_sup [DecidableEq α] (u : Finset α) (n : ℕ) (hn : n < u.card) :
  (powerset_len n.succ u).sup id = u :=
  by 
    apply le_antisymmₓ
    ·
      simpRw [sup_le_iff, mem_powerset_len]
      rintro x ⟨h, -⟩
      exact h
    ·
      rw [sup_eq_bUnion, le_iff_subset, subset_iff]
      cases' (Nat.succ_le_of_ltₓ hn).eq_or_lt with h' h'
      ·
        simp [h']
      ·
        intro x hx 
        simp only [mem_bUnion, exists_prop, id.def]
        obtain ⟨t, ht⟩ : ∃ t, t ∈ powerset_len n (u.erase x) := powerset_len_nonempty _
        ·
          refine' ⟨insert x t, _, mem_insert_self _ _⟩
          rw [←insert_erase hx, powerset_len_succ_insert (not_mem_erase _ _)]
          exact mem_union_right _ (mem_image_of_mem _ ht)
        ·
          rwa [card_erase_of_mem hx, Nat.lt_pred_iff]

end PowersetLen

end Finset

