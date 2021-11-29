import Mathbin.Data.Multiset.Powerset 
import Mathbin.Data.Multiset.Range

/-!
# The `nodup` predicate for multisets without duplicate elements.
-/


namespace Multiset

open List

variable{α β γ : Type _}

/-- `nodup s` means that `s` has no duplicates, i.e. the multiplicity of
  any element is at most 1. -/
def nodup (s : Multiset α) : Prop :=
  Quot.liftOn s nodup fun s t p => propext p.nodup_iff

@[simp]
theorem coe_nodup {l : List α} : @nodup α l ↔ l.nodup :=
  Iff.rfl

@[simp]
theorem nodup_zero : @nodup α 0 :=
  pairwise.nil

@[simp]
theorem nodup_cons {a : α} {s : Multiset α} : nodup (a ::ₘ s) ↔ a ∉ s ∧ nodup s :=
  Quot.induction_on s$ fun l => nodup_cons

theorem nodup_cons_of_nodup {a : α} {s : Multiset α} (m : a ∉ s) (n : nodup s) : nodup (a ::ₘ s) :=
  nodup_cons.2 ⟨m, n⟩

theorem nodup_singleton : ∀ (a : α), nodup ({a} : Multiset α) :=
  nodup_singleton

theorem nodup_of_nodup_cons {a : α} {s : Multiset α} (h : nodup (a ::ₘ s)) : nodup s :=
  (nodup_cons.1 h).2

theorem not_mem_of_nodup_cons {a : α} {s : Multiset α} (h : nodup (a ::ₘ s)) : a ∉ s :=
  (nodup_cons.1 h).1

theorem nodup_of_le {s t : Multiset α} (h : s ≤ t) : nodup t → nodup s :=
  le_induction_on h$ fun l₁ l₂ => nodup_of_sublist

theorem not_nodup_pair : ∀ (a : α), ¬nodup (a ::ₘ a ::ₘ 0) :=
  not_nodup_pair

theorem nodup_iff_le {s : Multiset α} : nodup s ↔ ∀ (a : α), ¬a ::ₘ a ::ₘ 0 ≤ s :=
  Quot.induction_on s$ fun l => nodup_iff_sublist.trans$ forall_congrₓ$ fun a => not_congr (@repeat_le_coe _ a 2 _).symm

theorem nodup_iff_ne_cons_cons {s : Multiset α} : s.nodup ↔ ∀ a t, s ≠ a ::ₘ a ::ₘ t :=
  nodup_iff_le.trans
    ⟨fun h a t s_eq => h a (s_eq.symm ▸ cons_le_cons a (cons_le_cons a (zero_le _))),
      fun h a le =>
        let ⟨t, s_eq⟩ := le_iff_exists_add.mp le 
        h a t
          (by 
            rwa [cons_add, cons_add, zero_addₓ] at s_eq)⟩

theorem nodup_iff_count_le_one [DecidableEq α] {s : Multiset α} : nodup s ↔ ∀ a, count a s ≤ 1 :=
  Quot.induction_on s$ fun l => nodup_iff_count_le_one

@[simp]
theorem count_eq_one_of_mem [DecidableEq α] {a : α} {s : Multiset α} (d : nodup s) (h : a ∈ s) : count a s = 1 :=
  le_antisymmₓ (nodup_iff_count_le_one.1 d a) (count_pos.2 h)

theorem nodup_iff_pairwise {α} {s : Multiset α} : nodup s ↔ Pairwise (· ≠ ·) s :=
  Quotientₓ.induction_on s$
    fun l =>
      (pairwise_coe_iff_pairwise
          (by 
            exact fun a b => Ne.symm)).symm

theorem pairwise_of_nodup {r : α → α → Prop} {s : Multiset α} :
  (∀ a (_ : a ∈ s), ∀ b (_ : b ∈ s), a ≠ b → r a b) → nodup s → Pairwise r s :=
  Quotientₓ.induction_on s$ fun l h hl => ⟨l, rfl, hl.imp_of_mem$ fun a b ha hb => h a ha b hb⟩

theorem forall_of_pairwise {r : α → α → Prop} (H : Symmetric r) {s : Multiset α} (hs : Pairwise r s) :
  ∀ a (_ : a ∈ s), ∀ b (_ : b ∈ s), a ≠ b → r a b :=
  let ⟨l, hl₁, hl₂⟩ := hs 
  hl₁.symm ▸ List.forall_of_pairwise H hl₂

theorem nodup_add {s t : Multiset α} : nodup (s+t) ↔ nodup s ∧ nodup t ∧ Disjoint s t :=
  Quotientₓ.induction_on₂ s t$ fun l₁ l₂ => nodup_append

theorem disjoint_of_nodup_add {s t : Multiset α} (d : nodup (s+t)) : Disjoint s t :=
  (nodup_add.1 d).2.2

theorem nodup_add_of_nodup {s t : Multiset α} (d₁ : nodup s) (d₂ : nodup t) : nodup (s+t) ↔ Disjoint s t :=
  by 
    simp [nodup_add, d₁, d₂]

theorem nodup_of_nodup_map (f : α → β) {s : Multiset α} : nodup (map f s) → nodup s :=
  Quot.induction_on s$ fun l => nodup_of_nodup_map f

theorem nodup_map_on {f : α → β} {s : Multiset α} :
  (∀ x (_ : x ∈ s), ∀ y (_ : y ∈ s), f x = f y → x = y) → nodup s → nodup (map f s) :=
  Quot.induction_on s$ fun l => nodup_map_on

theorem nodup_map {f : α → β} {s : Multiset α} (hf : Function.Injective f) : nodup s → nodup (map f s) :=
  nodup_map_on fun x _ y _ h => hf h

theorem inj_on_of_nodup_map {f : α → β} {s : Multiset α} :
  nodup (map f s) → ∀ x (_ : x ∈ s) y (_ : y ∈ s), f x = f y → x = y :=
  Quot.induction_on s$ fun l => inj_on_of_nodup_map

theorem nodup_map_iff_inj_on {f : α → β} {s : Multiset α} (d : nodup s) :
  nodup (map f s) ↔ ∀ x (_ : x ∈ s) y (_ : y ∈ s), f x = f y → x = y :=
  ⟨inj_on_of_nodup_map, fun h => nodup_map_on h d⟩

theorem nodup_filter (p : α → Prop) [DecidablePred p] {s} : nodup s → nodup (filter p s) :=
  Quot.induction_on s$ fun l => nodup_filter p

@[simp]
theorem nodup_attach {s : Multiset α} : nodup (attach s) ↔ nodup s :=
  Quot.induction_on s$ fun l => nodup_attach

theorem nodup_pmap {p : α → Prop} {f : ∀ a, p a → β} {s : Multiset α} {H} (hf : ∀ a ha b hb, f a ha = f b hb → a = b) :
  nodup s → nodup (pmap f s H) :=
  Quot.induction_on s (fun l H => nodup_pmap hf) H

instance nodup_decidable [DecidableEq α] (s : Multiset α) : Decidable (nodup s) :=
  Quotientₓ.recOnSubsingleton s$ fun l => l.nodup_decidable

theorem nodup_erase_eq_filter [DecidableEq α] (a : α) {s} : nodup s → s.erase a = filter (· ≠ a) s :=
  Quot.induction_on s$ fun l d => congr_argₓ coeₓ$ nodup_erase_eq_filter a d

theorem nodup_erase_of_nodup [DecidableEq α] (a : α) {l} : nodup l → nodup (l.erase a) :=
  nodup_of_le (erase_le _ _)

theorem mem_erase_iff_of_nodup [DecidableEq α] {a b : α} {l} (d : nodup l) : a ∈ l.erase b ↔ a ≠ b ∧ a ∈ l :=
  by 
    rw [nodup_erase_eq_filter b d] <;> simp [and_comm]

theorem mem_erase_of_nodup [DecidableEq α] {a : α} {l} (h : nodup l) : a ∉ l.erase a :=
  by 
    rw [mem_erase_iff_of_nodup h] <;> simp 

theorem nodup_product {s : Multiset α} {t : Multiset β} : nodup s → nodup t → nodup (product s t) :=
  Quotientₓ.induction_on₂ s t$
    fun l₁ l₂ d₁ d₂ =>
      by 
        simp [nodup_product d₁ d₂]

theorem nodup_sigma {σ : α → Type _} {s : Multiset α} {t : ∀ a, Multiset (σ a)} :
  nodup s → (∀ a, nodup (t a)) → nodup (s.sigma t) :=
  Quot.induction_on s$
    fun l₁ =>
      by 
        choose f hf using fun a => Quotientₓ.exists_rep (t a)
        rw [show t = fun a => f a from Eq.symm$ funext$ fun a => hf a]
        simpa using nodup_sigma

theorem nodup_filter_map (f : α → Option β) {s : Multiset α} (H : ∀ (a a' : α) (b : β), b ∈ f a → b ∈ f a' → a = a') :
  nodup s → nodup (filter_map f s) :=
  Quot.induction_on s$ fun l => nodup_filter_map H

theorem nodup_range (n : ℕ) : nodup (range n) :=
  nodup_range _

theorem nodup_inter_left [DecidableEq α] {s : Multiset α} t : nodup s → nodup (s ∩ t) :=
  nodup_of_le$ inter_le_left _ _

theorem nodup_inter_right [DecidableEq α] s {t : Multiset α} : nodup t → nodup (s ∩ t) :=
  nodup_of_le$ inter_le_right _ _

@[simp]
theorem nodup_union [DecidableEq α] {s t : Multiset α} : nodup (s ∪ t) ↔ nodup s ∧ nodup t :=
  ⟨fun h => ⟨nodup_of_le (le_union_left _ _) h, nodup_of_le (le_union_right _ _) h⟩,
    fun ⟨h₁, h₂⟩ =>
      nodup_iff_count_le_one.2$
        fun a =>
          by 
            rw [count_union] <;> exact max_leₓ (nodup_iff_count_le_one.1 h₁ a) (nodup_iff_count_le_one.1 h₂ a)⟩

@[simp]
theorem nodup_powerset {s : Multiset α} : nodup (powerset s) ↔ nodup s :=
  ⟨fun h => nodup_of_nodup_map _ (nodup_of_le (map_single_le_powerset _) h),
    Quotientₓ.induction_on s$
      fun l h =>
        by 
          simp  <;>
            refine' List.nodup_map_on _ (nodup_sublists'.2 h) <;>
              exact fun x sx y sy e => (h.sublist_ext (mem_sublists'.1 sx) (mem_sublists'.1 sy)).1 (Quotientₓ.exact e)⟩

theorem nodup_powerset_len {n : ℕ} {s : Multiset α} (h : nodup s) : nodup (powerset_len n s) :=
  nodup_of_le (powerset_len_le_powerset _ _) (nodup_powerset.2 h)

@[simp]
theorem nodup_bind {s : Multiset α} {t : α → Multiset β} :
  nodup (bind s t) ↔ (∀ a (_ : a ∈ s), nodup (t a)) ∧ s.pairwise fun a b => Disjoint (t a) (t b) :=
  have h₁ : ∀ a, ∃ l : List β, t a = l := fun a => Quot.induction_on (t a)$ fun l => ⟨l, rfl⟩
  let ⟨t', h'⟩ := Classical.axiom_of_choice h₁ 
  have  : t = fun a => t' a := funext h' 
  have hd : Symmetric fun a b => List.Disjoint (t' a) (t' b) := fun a b h => h.symm 
  Quot.induction_on s$
    by 
      simp [this, List.nodup_bind, pairwise_coe_iff_pairwise hd]

theorem nodup_ext {s t : Multiset α} : nodup s → nodup t → (s = t ↔ ∀ a, a ∈ s ↔ a ∈ t) :=
  Quotientₓ.induction_on₂ s t$ fun l₁ l₂ d₁ d₂ => Quotientₓ.eq.trans$ perm_ext d₁ d₂

theorem le_iff_subset {s t : Multiset α} : nodup s → (s ≤ t ↔ s ⊆ t) :=
  Quotientₓ.induction_on₂ s t$ fun l₁ l₂ d => ⟨subset_of_le, subperm_of_subset_nodup d⟩

theorem range_le {m n : ℕ} : range m ≤ range n ↔ m ≤ n :=
  (le_iff_subset (nodup_range _)).trans range_subset

theorem mem_sub_of_nodup [DecidableEq α] {a : α} {s t : Multiset α} (d : nodup s) : a ∈ s - t ↔ a ∈ s ∧ a ∉ t :=
  ⟨fun h =>
      ⟨mem_of_le tsub_le_self h,
        fun h' =>
          by 
            refine' count_eq_zero.1 _ h <;>
              rw [count_sub a s t, tsub_eq_zero_iff_le] <;>
                exact le_transₓ (nodup_iff_count_le_one.1 d _) (count_pos.2 h')⟩,
    fun ⟨h₁, h₂⟩ => Or.resolve_right (mem_add.1$ mem_of_le le_tsub_add h₁) h₂⟩

-- error in Data.Multiset.Nodup: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem map_eq_map_of_bij_of_nodup
(f : α → γ)
(g : β → γ)
{s : multiset α}
{t : multiset β}
(hs : s.nodup)
(ht : t.nodup)
(i : ∀ a «expr ∈ » s, β)
(hi : ∀ a ha, «expr ∈ »(i a ha, t))
(h : ∀ a ha, «expr = »(f a, g (i a ha)))
(i_inj : ∀ a₁ a₂ ha₁ ha₂, «expr = »(i a₁ ha₁, i a₂ ha₂) → «expr = »(a₁, a₂))
(i_surj : ∀ b «expr ∈ » t, «expr∃ , »((a ha), «expr = »(b, i a ha))) : «expr = »(s.map f, t.map g) :=
have «expr = »(t, s.attach.map (λ
  x, i x.1 x.2)), from (nodup_ext ht (nodup_map (show function.injective (λ
    x : {x // «expr ∈ »(x, s)}, i x.1 x.2), from λ
   x
   y
   hxy, subtype.eq (i_inj x.1 y.1 x.2 y.2 hxy)) (nodup_attach.2 hs))).2 (λ
 x, by simp [] [] ["only"] ["[", expr mem_map, ",", expr true_and, ",", expr subtype.exists, ",", expr eq_comm, ",", expr mem_attach, "]"] [] []; exact [expr ⟨i_surj _, λ
   ⟨y, hy⟩, «expr ▸ »(hy.snd.symm, hi _ _)⟩]),
calc
  «expr = »(s.map f, s.pmap (λ x _, f x) (λ _, id)) : by rw ["[", expr pmap_eq_map, "]"] []
  «expr = »(..., s.attach.map (λ x, f x.1)) : by rw ["[", expr pmap_eq_map_attach, "]"] []
  «expr = »(..., t.map g) : by rw ["[", expr this, ",", expr multiset.map_map, "]"] []; exact [expr map_congr (λ
    x _, h _ _)]

end Multiset

