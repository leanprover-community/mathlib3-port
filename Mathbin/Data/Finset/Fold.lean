import Mathbin.Data.Finset.Basic 
import Mathbin.Data.Multiset.Fold

/-!
# The fold operation for a commutative associative operation over a finset.
-/


namespace Finset

open Multiset

variable{α β γ : Type _}

/-! ### fold -/


section Fold

variable(op : β → β → β)[hc : IsCommutative β op][ha : IsAssociative β op]

local notation a "*" b => op a b

include hc ha

/-- `fold op b f s` folds the commutative associative operation `op` over the
  `f`-image of `s`, i.e. `fold (+) b f {1,2,3} = f 1 + f 2 + f 3 + b`. -/
def fold (b : β) (f : α → β) (s : Finset α) : β :=
  (s.1.map f).fold op b

variable{op}{f : α → β}{b : β}{s : Finset α}{a : α}

@[simp]
theorem fold_empty : (∅ : Finset α).fold op b f = b :=
  rfl

@[simp]
theorem fold_cons (h : a ∉ s) : (cons a s h).fold op b f = f a*s.fold op b f :=
  by 
    dunfold fold 
    rw [cons_val, map_cons, fold_cons_left]

@[simp]
theorem fold_insert [DecidableEq α] (h : a ∉ s) : (insert a s).fold op b f = f a*s.fold op b f :=
  by 
    unfold fold <;> rw [insert_val, ndinsert_of_not_mem h, map_cons, fold_cons_left]

@[simp]
theorem fold_singleton : ({a} : Finset α).fold op b f = f a*b :=
  rfl

@[simp]
theorem fold_map {g : γ ↪ α} {s : Finset γ} : (s.map g).fold op b f = s.fold op b (f ∘ g) :=
  by 
    simp only [fold, map, Multiset.map_map]

@[simp]
theorem fold_image [DecidableEq α] {g : γ → α} {s : Finset γ} (H : ∀ x (_ : x ∈ s) y (_ : y ∈ s), g x = g y → x = y) :
  (s.image g).fold op b f = s.fold op b (f ∘ g) :=
  by 
    simp only [fold, image_val_of_inj_on H, Multiset.map_map]

@[congr]
theorem fold_congr {g : α → β} (H : ∀ x (_ : x ∈ s), f x = g x) : s.fold op b f = s.fold op b g :=
  by 
    rw [fold, fold, map_congr H]

theorem fold_op_distrib {f g : α → β} {b₁ b₂ : β} :
  (s.fold op (b₁*b₂) fun x => f x*g x) = s.fold op b₁ f*s.fold op b₂ g :=
  by 
    simp only [fold, fold_distrib]

theorem fold_hom {op' : γ → γ → γ} [IsCommutative γ op'] [IsAssociative γ op'] {m : β → γ}
  (hm : ∀ x y, m (op x y) = op' (m x) (m y)) : (s.fold op' (m b) fun x => m (f x)) = m (s.fold op b f) :=
  by 
    rw [fold, fold, ←fold_hom op hm, Multiset.map_map]

theorem fold_union_inter [DecidableEq α] {s₁ s₂ : Finset α} {b₁ b₂ : β} :
  ((s₁ ∪ s₂).fold op b₁ f*(s₁ ∩ s₂).fold op b₂ f) = s₁.fold op b₂ f*s₂.fold op b₁ f :=
  by 
    unfold fold <;> rw [←fold_add op, ←map_add, union_val, inter_val, union_add_inter, map_add, hc.comm, fold_add]

@[simp]
theorem fold_insert_idem [DecidableEq α] [hi : IsIdempotent β op] : (insert a s).fold op b f = f a*s.fold op b f :=
  by 
    byCases' a ∈ s
    ·
      rw [←insert_erase h]
      simp [←ha.assoc, hi.idempotent]
    ·
      apply fold_insert h

-- error in Data.Finset.Fold: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem fold_image_idem
[decidable_eq α]
{g : γ → α}
{s : finset γ}
[hi : is_idempotent β op] : «expr = »((image g s).fold op b f, s.fold op b «expr ∘ »(f, g)) :=
begin
  induction [expr s] ["using", ident finset.cons_induction] ["with", ident x, ident xs, ident hx, ident ih] [],
  { rw ["[", expr fold_empty, ",", expr image_empty, ",", expr fold_empty, "]"] [] },
  { haveI [] [] [":=", expr classical.dec_eq γ],
    rw ["[", expr fold_cons, ",", expr cons_eq_insert, ",", expr image_insert, ",", expr fold_insert_idem, ",", expr ih, "]"] [] }
end

-- error in Data.Finset.Fold: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Meta.solveByElim'
theorem fold_op_rel_iff_and
{r : β → β → exprProp()}
(hr : ∀ {x y z}, «expr ↔ »(r x (op y z), «expr ∧ »(r x y, r x z)))
{c : β} : «expr ↔ »(r c (s.fold op b f), «expr ∧ »(r c b, ∀ x «expr ∈ » s, r c (f x))) :=
begin
  classical,
  apply [expr finset.induction_on s],
  { simp [] [] [] [] [] [] },
  clear [ident s],
  intros [ident a, ident s, ident ha, ident IH],
  rw ["[", expr finset.fold_insert ha, ",", expr hr, ",", expr IH, ",", "<-", expr and_assoc, ",", expr and_comm (r c (f a)), ",", expr and_assoc, "]"] [],
  apply [expr and_congr iff.rfl],
  split,
  { rintro ["⟨", ident h₁, ",", ident h₂, "⟩"],
    intros [ident b, ident hb],
    rw [expr finset.mem_insert] ["at", ident hb],
    rcases [expr hb, "with", ident rfl, "|", ident hb]; solve_by_elim [] [] [] [] },
  { intro [ident h],
    split,
    { exact [expr h a (finset.mem_insert_self _ _)] },
    { intros [ident b, ident hb],
      apply [expr h b],
      rw [expr finset.mem_insert] [],
      right,
      exact [expr hb] } }
end

theorem fold_op_rel_iff_or {r : β → β → Prop} (hr : ∀ {x y z}, r x (op y z) ↔ r x y ∨ r x z) {c : β} :
  r c (s.fold op b f) ↔ r c b ∨ ∃ (x : _)(_ : x ∈ s), r c (f x) :=
  by 
    classical 
    apply Finset.induction_on s
    ·
      simp 
    clear s 
    intro a s ha IH 
    rw [Finset.fold_insert ha, hr, IH, ←or_assoc, or_comm (r c (f a)), or_assoc]
    apply or_congr Iff.rfl 
    split 
    ·
      rintro (h₁ | ⟨x, hx, h₂⟩)
      ·
        use a 
        simp [h₁]
      ·
        refine'
          ⟨x,
            by 
              simp [hx],
            h₂⟩
    ·
      rintro ⟨x, hx, h⟩
      rw [mem_insert] at hx 
      cases hx
      ·
        left 
        rwa [hx] at h
      ·
        right 
        exact ⟨x, hx, h⟩

omit hc ha

@[simp]
theorem fold_union_empty_singleton [DecidableEq α] (s : Finset α) : Finset.fold (· ∪ ·) ∅ singleton s = s :=
  by 
    apply Finset.induction_on s
    ·
      simp only [fold_empty]
    ·
      intro a s has ih 
      rw [fold_insert has, ih, insert_eq]

theorem fold_sup_bot_singleton [DecidableEq α] (s : Finset α) : Finset.fold (·⊔·) ⊥ singleton s = s :=
  fold_union_empty_singleton s

section Order

variable[LinearOrderₓ β](c : β)

theorem le_fold_min : c ≤ s.fold min b f ↔ c ≤ b ∧ ∀ x (_ : x ∈ s), c ≤ f x :=
  fold_op_rel_iff_and$ fun x y z => le_min_iff

theorem fold_min_le : s.fold min b f ≤ c ↔ b ≤ c ∨ ∃ (x : _)(_ : x ∈ s), f x ≤ c :=
  by 
    show _ ≥ _ ↔ _ 
    apply fold_op_rel_iff_or 
    intro x y z 
    show _ ≤ _ ↔ _ 
    exact min_le_iff

theorem lt_fold_min : c < s.fold min b f ↔ c < b ∧ ∀ x (_ : x ∈ s), c < f x :=
  fold_op_rel_iff_and$ fun x y z => lt_min_iff

theorem fold_min_lt : s.fold min b f < c ↔ b < c ∨ ∃ (x : _)(_ : x ∈ s), f x < c :=
  by 
    show _ > _ ↔ _ 
    apply fold_op_rel_iff_or 
    intro x y z 
    show _ < _ ↔ _ 
    exact min_lt_iff

theorem fold_max_le : s.fold max b f ≤ c ↔ b ≤ c ∧ ∀ x (_ : x ∈ s), f x ≤ c :=
  by 
    show _ ≥ _ ↔ _ 
    apply fold_op_rel_iff_and 
    intro x y z 
    show _ ≤ _ ↔ _ 
    exact max_le_iff

theorem le_fold_max : c ≤ s.fold max b f ↔ c ≤ b ∨ ∃ (x : _)(_ : x ∈ s), c ≤ f x :=
  fold_op_rel_iff_or$ fun x y z => le_max_iff

theorem fold_max_lt : s.fold max b f < c ↔ b < c ∧ ∀ x (_ : x ∈ s), f x < c :=
  by 
    show _ > _ ↔ _ 
    apply fold_op_rel_iff_and 
    intro x y z 
    show _ < _ ↔ _ 
    exact max_lt_iff

theorem lt_fold_max : c < s.fold max b f ↔ c < b ∨ ∃ (x : _)(_ : x ∈ s), c < f x :=
  fold_op_rel_iff_or$ fun x y z => lt_max_iff

end Order

end Fold

end Finset

