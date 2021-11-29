import Mathbin.Data.List.Basic

/-!
# The Following Are Equivalent

This file allows to state that all propositions in a list are equivalent. It is used by
`tactic.tfae`.
`tfae l` means `∀ x ∈ l, ∀ y ∈ l, x ↔ y`. This is equivalent to `pairwise (↔) l`.
-/


namespace List

/--
tfae: The Following (propositions) Are Equivalent.

The `tfae_have` and `tfae_finish` tactics can be useful in proofs with `tfae` goals.
-/
def tfae (l : List Prop) : Prop :=
  ∀ x (_ : x ∈ l), ∀ y (_ : y ∈ l), x ↔ y

theorem tfae_nil : tfae [] :=
  forall_mem_nil _

theorem tfae_singleton p : tfae [p] :=
  by 
    simp [tfae, -eq_iff_iff]

theorem tfae_cons_of_mem {a b} {l : List Prop} (h : b ∈ l) : tfae (a :: l) ↔ (a ↔ b) ∧ tfae l :=
  ⟨fun H =>
      ⟨H a
          (by 
            simp )
          b (Or.inr h),
        fun p hp q hq => H _ (Or.inr hp) _ (Or.inr hq)⟩,
    by 
      rintro ⟨ab, H⟩ p (rfl | hp) q (rfl | hq)
      ·
        rfl
      ·
        exact ab.trans (H _ h _ hq)
      ·
        exact (ab.trans (H _ h _ hp)).symm
      ·
        exact H _ hp _ hq⟩

theorem tfae_cons_cons {a b} {l : List Prop} : tfae (a :: b :: l) ↔ (a ↔ b) ∧ tfae (b :: l) :=
  tfae_cons_of_mem (Or.inl rfl)

theorem tfae_of_forall (b : Prop) (l : List Prop) (h : ∀ a (_ : a ∈ l), a ↔ b) : tfae l :=
  fun a₁ h₁ a₂ h₂ => (h _ h₁).trans (h _ h₂).symm

-- error in Data.List.Tfae: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tfae_of_cycle
{a b}
{l : list exprProp()} : list.chain ((«->»)) a «expr :: »(b, l) → (ilast' b l → a) → tfae «expr :: »(a, «expr :: »(b, l)) :=
begin
  induction [expr l] [] ["with", ident c, ident l, ident IH] ["generalizing", ident a, ident b]; simp [] [] ["only"] ["[", expr tfae_cons_cons, ",", expr tfae_singleton, ",", expr and_true, ",", expr chain_cons, ",", expr chain.nil, "]"] [] ["at", "*"],
  { intros [ident a, ident b],
    exact [expr iff.intro a b] },
  rintros ["⟨", ident ab, ",", "⟨", ident bc, ",", ident ch, "⟩", "⟩", ident la],
  have [] [] [":=", expr IH ⟨bc, ch⟩ «expr ∘ »(ab, la)],
  exact [expr ⟨⟨ab, «expr ∘ »(la, «expr ∘ »((this.2 c (or.inl rfl) _ (ilast'_mem _ _)).1, bc))⟩, this⟩]
end

theorem tfae.out {l} (h : tfae l) n₁ n₂ {a b}
  (h₁ : List.nth l n₁ = some a :=  by 
    runTac 
      tactic.interactive.refl)
  (h₂ : List.nth l n₂ = some b :=  by 
    runTac 
      tactic.interactive.refl) :
  a ↔ b :=
  h _ (List.nth_mem h₁) _ (List.nth_mem h₂)

end List

