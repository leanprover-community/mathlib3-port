/-
Copyright (c) 2022 Junyan Xu. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa, Junyan Xu
-/
import Mathbin.Data.Dfinsupp.Order
import Mathbin.Data.Dfinsupp.NeLocus
import Mathbin.Order.WellFoundedSet

/-!
# Lexicographic order on finitely supported dependent functions

This file defines the lexicographic order on `dfinsupp`.
-/


variable {ι : Type _} {α : ι → Type _}

namespace Dfinsupp

section Zero

variable [∀ i, Zero (α i)]

/-- `dfinsupp.lex r s` is the lexicographic relation on `Π₀ i, α i`, where `ι` is ordered by `r`,
and `α i` is ordered by `s i`.
The type synonym `lex (Π₀ i, α i)` has an order given by `dfinsupp.lex (<) (λ i, (<))`.
-/
protected def Lex (r : ι → ι → Prop) (s : ∀ i, α i → α i → Prop) (x y : Π₀ i, α i) : Prop :=
  Pi.Lex r s x y
#align dfinsupp.lex Dfinsupp.Lex

theorem _root_.pi.lex_eq_dfinsupp_lex {r : ι → ι → Prop} {s : ∀ i, α i → α i → Prop} (a b : Π₀ i, α i) :
    Pi.Lex r s (a : ∀ i, α i) b = Dfinsupp.Lex r s a b :=
  rfl
#align dfinsupp._root_.pi.lex_eq_dfinsupp_lex dfinsupp._root_.pi.lex_eq_dfinsupp_lex

theorem lex_def {r : ι → ι → Prop} {s : ∀ i, α i → α i → Prop} {a b : Π₀ i, α i} :
    Dfinsupp.Lex r s a b ↔ ∃ j, (∀ d, r d j → a d = b d) ∧ s j (a j) (b j) :=
  Iff.rfl
#align dfinsupp.lex_def Dfinsupp.lex_def

instance [LT ι] [∀ i, LT (α i)] : LT (Lex (Π₀ i, α i)) :=
  ⟨fun f g => Dfinsupp.Lex (· < ·) (fun i => (· < ·)) (ofLex f) (ofLex g)⟩

theorem lex_lt_of_lt_of_preorder [∀ i, Preorder (α i)] (r) [IsStrictOrder ι r] {x y : Π₀ i, α i} (hlt : x < y) :
    ∃ i, (∀ j, r j i → x j ≤ y j ∧ y j ≤ x j) ∧ x i < y i := by
  obtain ⟨hle, j, hlt⟩ := Pi.lt_def.1 hlt
  classical
  obtain ⟨i, hi, hl⟩ :=
    (x.ne_locus y).finite_to_set.WellFoundedOn.has_min { i | x i < y i } ⟨⟨j, mem_ne_locus.2 hlt.ne⟩, hlt⟩
  pick_goal 3
  · assumption
    
  exact
    ⟨i, fun k hk =>
      ⟨hle k, not_not.1 $ fun h => hl ⟨k, mem_ne_locus.2 (ne_of_not_le h).symm⟩ ((hle k).lt_of_not_le h) hk⟩, hi⟩
#align dfinsupp.lex_lt_of_lt_of_preorder Dfinsupp.lex_lt_of_lt_of_preorder

theorem lex_lt_of_lt [∀ i, PartialOrder (α i)] (r) [IsStrictOrder ι r] {x y : Π₀ i, α i} (hlt : x < y) :
    Pi.Lex r (fun i => (· < ·)) x y := by
  simp_rw [Pi.Lex, le_antisymm_iff]
  exact lex_lt_of_lt_of_preorder r hlt
#align dfinsupp.lex_lt_of_lt Dfinsupp.lex_lt_of_lt

instance Lex.is_strict_order [LinearOrder ι] [∀ i, PartialOrder (α i)] : IsStrictOrder (Lex (Π₀ i, α i)) (· < ·) :=
  let i : IsStrictOrder (Lex (∀ i, α i)) (· < ·) := Pi.Lex.is_strict_order
  { irrefl := toLex.Surjective.forall.2 $ fun a => @irrefl _ _ i.to_is_irrefl a,
    trans := toLex.Surjective.forall₃.2 $ fun a b c => @trans _ _ i.to_is_trans a b c }
#align dfinsupp.lex.is_strict_order Dfinsupp.Lex.is_strict_order

variable [LinearOrder ι]

/-- The partial order on `dfinsupp`s obtained by the lexicographic ordering.
See `dfinsupp.lex.linear_order` for a proof that this partial order is in fact linear. -/
instance Lex.partialOrder [∀ i, PartialOrder (α i)] : PartialOrder (Lex (Π₀ i, α i)) :=
  PartialOrder.lift (fun x => toLex ⇑(ofLex x)) Dfinsupp.coe_fn_injective
#align dfinsupp.lex.partial_order Dfinsupp.Lex.partialOrder

section LinearOrder

variable [∀ i, LinearOrder (α i)]

/-- Auxiliary helper to case split computably. There is no need for this to be public, as it
can be written with `or.by_cases` on `lt_trichotomy` once the instances below are constructed. -/
private def lt_trichotomy_rec {P : Lex (Π₀ i, α i) → Lex (Π₀ i, α i) → Sort _}
    (h_lt : ∀ {f g}, toLex f < toLex g → P (toLex f) (toLex g))
    (h_eq : ∀ {f g}, toLex f = toLex g → P (toLex f) (toLex g))
    (h_gt : ∀ {f g}, toLex g < toLex f → P (toLex f) (toLex g)) : ∀ f g, P f g :=
  Lex.rec $ fun f =>
    Lex.rec $ fun g =>
      match (motive := ∀ y, (f.neLocus g).min = y → _) _, rfl with
      | ⊤, h => h_eq (ne_locus_eq_empty.mp $ Finset.min_eq_top.mp h)
      | (wit : ι), h =>
        (mem_ne_locus.mp $ Finset.mem_of_min h).lt_or_lt.byCases
          (fun hwit => h_lt ⟨wit, fun j hj => not_mem_ne_locus.mp (Finset.not_mem_of_lt_min hj h), hwit⟩) fun hwit =>
          h_gt ⟨wit, fun j hj => not_mem_ne_locus.mp (Finset.not_mem_of_lt_min hj $ by rwa [ne_locus_comm]), hwit⟩
#align dfinsupp.lt_trichotomy_rec dfinsupp.lt_trichotomy_rec

/- ./././Mathport/Syntax/Translate/Command.lean:294:38: unsupported irreducible non-definition -/
irreducible_def Lex.decidableLe : @DecidableRel (Lex (Π₀ i, α i)) (· ≤ ·) :=
  ltTrichotomyRec (fun f g h => is_true $ Or.inr h) (fun f g h => is_true $ Or.inl $ congr_arg _ h) fun f g h =>
    is_false $ fun h' => (lt_irrefl _ (h.trans_le h')).elim
#align dfinsupp.lex.decidable_le Dfinsupp.Lex.decidableLe

/- ./././Mathport/Syntax/Translate/Command.lean:294:38: unsupported irreducible non-definition -/
irreducible_def Lex.decidableLt : @DecidableRel (Lex (Π₀ i, α i)) (· < ·) :=
  ltTrichotomyRec (fun f g h => isTrue h) (fun f g h => isFalse h.not_lt) fun f g h => isFalse h.asymm
#align dfinsupp.lex.decidable_lt Dfinsupp.Lex.decidableLt

/-- The linear order on `dfinsupp`s obtained by the lexicographic ordering. -/
instance Lex.linearOrder : LinearOrder (Lex (Π₀ i, α i)) :=
  { Lex.partialOrder with
    le_total := ltTrichotomyRec (fun f g h => Or.inl h.le) (fun f g h => Or.inl h.le) fun f g h => Or.inr h.le,
    decidableLt := by infer_instance, decidableLe := by infer_instance, DecidableEq := by infer_instance }
#align dfinsupp.lex.linear_order Dfinsupp.Lex.linearOrder

end LinearOrder

variable [∀ i, PartialOrder (α i)]

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `to_lex_monotone [])
      (Command.declSig
       []
       (Term.typeSpec
        ":"
        (Term.app
         `Monotone
         [(Term.app
           (Term.explicit "@" `toLex)
           [(Data.Dfinsupp.Basic.«termΠ₀_,_»
             "Π₀"
             (Std.ExtendedBinder.extBinders (Std.ExtendedBinder.extBinder (Lean.binderIdent `i) []))
             ", "
             (Term.app `α [`i]))])])))
      (Command.declValSimple
       ":="
       (Term.fun
        "fun"
        (Term.basicFun
         [`a `b `h]
         []
         "=>"
         (Init.Core.«term_$_»
          `le_of_lt_or_eq
          " $ "
          (Init.Core.«term_$_»
           (Term.proj `or_iff_not_imp_right "." (fieldIdx "2"))
           " $ "
           (Term.fun
            "fun"
            (Term.basicFun
             [`hne]
             []
             "=>"
             (Term.byTactic
              "by"
              (Tactic.tacticSeq
               (Tactic.tacticSeq1Indented
                [(Tactic.«tactic_<;>_»
                  (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
                  "<;>"
                  (Tactic.exact
                   "exact"
                   (Term.anonymousCtor
                    "⟨"
                    [(Term.app
                      `Finset.min'
                      [(Term.hole "_") (Term.app (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2")) [`hne])])
                     ","
                     (Term.fun
                      "fun"
                      (Term.basicFun
                       [`j `hj]
                       []
                       "=>"
                       (Term.app
                        (Term.proj `not_mem_ne_locus "." (fieldIdx "1"))
                        [(Term.fun
                          "fun"
                          (Term.basicFun
                           [`h]
                           []
                           "=>"
                           (Term.app
                            (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt)
                            [`hj])))])))
                     ","
                     (Term.app
                      (Term.proj (Term.app `h [(Term.hole "_")]) "." `lt_of_ne)
                      [(Init.Core.«term_$_»
                        (Term.proj `mem_ne_locus "." (fieldIdx "1"))
                        " $ "
                        (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")]))])]
                    "⟩")))])))))))))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`a `b `h]
        []
        "=>"
        (Init.Core.«term_$_»
         `le_of_lt_or_eq
         " $ "
         (Init.Core.«term_$_»
          (Term.proj `or_iff_not_imp_right "." (fieldIdx "2"))
          " $ "
          (Term.fun
           "fun"
           (Term.basicFun
            [`hne]
            []
            "=>"
            (Term.byTactic
             "by"
             (Tactic.tacticSeq
              (Tactic.tacticSeq1Indented
               [(Tactic.«tactic_<;>_»
                 (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
                 "<;>"
                 (Tactic.exact
                  "exact"
                  (Term.anonymousCtor
                   "⟨"
                   [(Term.app
                     `Finset.min'
                     [(Term.hole "_") (Term.app (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2")) [`hne])])
                    ","
                    (Term.fun
                     "fun"
                     (Term.basicFun
                      [`j `hj]
                      []
                      "=>"
                      (Term.app
                       (Term.proj `not_mem_ne_locus "." (fieldIdx "1"))
                       [(Term.fun
                         "fun"
                         (Term.basicFun
                          [`h]
                          []
                          "=>"
                          (Term.app
                           (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt)
                           [`hj])))])))
                    ","
                    (Term.app
                     (Term.proj (Term.app `h [(Term.hole "_")]) "." `lt_of_ne)
                     [(Init.Core.«term_$_»
                       (Term.proj `mem_ne_locus "." (fieldIdx "1"))
                       " $ "
                       (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")]))])]
                   "⟩")))])))))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Init.Core.«term_$_»
       `le_of_lt_or_eq
       " $ "
       (Init.Core.«term_$_»
        (Term.proj `or_iff_not_imp_right "." (fieldIdx "2"))
        " $ "
        (Term.fun
         "fun"
         (Term.basicFun
          [`hne]
          []
          "=>"
          (Term.byTactic
           "by"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Tactic.«tactic_<;>_»
               (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
               "<;>"
               (Tactic.exact
                "exact"
                (Term.anonymousCtor
                 "⟨"
                 [(Term.app
                   `Finset.min'
                   [(Term.hole "_") (Term.app (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2")) [`hne])])
                  ","
                  (Term.fun
                   "fun"
                   (Term.basicFun
                    [`j `hj]
                    []
                    "=>"
                    (Term.app
                     (Term.proj `not_mem_ne_locus "." (fieldIdx "1"))
                     [(Term.fun
                       "fun"
                       (Term.basicFun
                        [`h]
                        []
                        "=>"
                        (Term.app
                         (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt)
                         [`hj])))])))
                  ","
                  (Term.app
                   (Term.proj (Term.app `h [(Term.hole "_")]) "." `lt_of_ne)
                   [(Init.Core.«term_$_»
                     (Term.proj `mem_ne_locus "." (fieldIdx "1"))
                     " $ "
                     (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")]))])]
                 "⟩")))])))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Init.Core.«term_$_»
       (Term.proj `or_iff_not_imp_right "." (fieldIdx "2"))
       " $ "
       (Term.fun
        "fun"
        (Term.basicFun
         [`hne]
         []
         "=>"
         (Term.byTactic
          "by"
          (Tactic.tacticSeq
           (Tactic.tacticSeq1Indented
            [(Tactic.«tactic_<;>_»
              (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
              "<;>"
              (Tactic.exact
               "exact"
               (Term.anonymousCtor
                "⟨"
                [(Term.app
                  `Finset.min'
                  [(Term.hole "_") (Term.app (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2")) [`hne])])
                 ","
                 (Term.fun
                  "fun"
                  (Term.basicFun
                   [`j `hj]
                   []
                   "=>"
                   (Term.app
                    (Term.proj `not_mem_ne_locus "." (fieldIdx "1"))
                    [(Term.fun
                      "fun"
                      (Term.basicFun
                       [`h]
                       []
                       "=>"
                       (Term.app
                        (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt)
                        [`hj])))])))
                 ","
                 (Term.app
                  (Term.proj (Term.app `h [(Term.hole "_")]) "." `lt_of_ne)
                  [(Init.Core.«term_$_»
                    (Term.proj `mem_ne_locus "." (fieldIdx "1"))
                    " $ "
                    (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")]))])]
                "⟩")))]))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`hne]
        []
        "=>"
        (Term.byTactic
         "by"
         (Tactic.tacticSeq
          (Tactic.tacticSeq1Indented
           [(Tactic.«tactic_<;>_»
             (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
             "<;>"
             (Tactic.exact
              "exact"
              (Term.anonymousCtor
               "⟨"
               [(Term.app
                 `Finset.min'
                 [(Term.hole "_") (Term.app (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2")) [`hne])])
                ","
                (Term.fun
                 "fun"
                 (Term.basicFun
                  [`j `hj]
                  []
                  "=>"
                  (Term.app
                   (Term.proj `not_mem_ne_locus "." (fieldIdx "1"))
                   [(Term.fun
                     "fun"
                     (Term.basicFun
                      [`h]
                      []
                      "=>"
                      (Term.app
                       (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt)
                       [`hj])))])))
                ","
                (Term.app
                 (Term.proj (Term.app `h [(Term.hole "_")]) "." `lt_of_ne)
                 [(Init.Core.«term_$_»
                   (Term.proj `mem_ne_locus "." (fieldIdx "1"))
                   " $ "
                   (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")]))])]
               "⟩")))])))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.«tactic_<;>_»
           (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
           "<;>"
           (Tactic.exact
            "exact"
            (Term.anonymousCtor
             "⟨"
             [(Term.app
               `Finset.min'
               [(Term.hole "_") (Term.app (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2")) [`hne])])
              ","
              (Term.fun
               "fun"
               (Term.basicFun
                [`j `hj]
                []
                "=>"
                (Term.app
                 (Term.proj `not_mem_ne_locus "." (fieldIdx "1"))
                 [(Term.fun
                   "fun"
                   (Term.basicFun
                    [`h]
                    []
                    "=>"
                    (Term.app
                     (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt)
                     [`hj])))])))
              ","
              (Term.app
               (Term.proj (Term.app `h [(Term.hole "_")]) "." `lt_of_ne)
               [(Init.Core.«term_$_»
                 (Term.proj `mem_ne_locus "." (fieldIdx "1"))
                 " $ "
                 (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")]))])]
             "⟩")))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.«tactic_<;>_»
       (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
       "<;>"
       (Tactic.exact
        "exact"
        (Term.anonymousCtor
         "⟨"
         [(Term.app
           `Finset.min'
           [(Term.hole "_") (Term.app (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2")) [`hne])])
          ","
          (Term.fun
           "fun"
           (Term.basicFun
            [`j `hj]
            []
            "=>"
            (Term.app
             (Term.proj `not_mem_ne_locus "." (fieldIdx "1"))
             [(Term.fun
               "fun"
               (Term.basicFun
                [`h]
                []
                "=>"
                (Term.app
                 (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt)
                 [`hj])))])))
          ","
          (Term.app
           (Term.proj (Term.app `h [(Term.hole "_")]) "." `lt_of_ne)
           [(Init.Core.«term_$_»
             (Term.proj `mem_ne_locus "." (fieldIdx "1"))
             " $ "
             (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")]))])]
         "⟩")))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact
       "exact"
       (Term.anonymousCtor
        "⟨"
        [(Term.app
          `Finset.min'
          [(Term.hole "_") (Term.app (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2")) [`hne])])
         ","
         (Term.fun
          "fun"
          (Term.basicFun
           [`j `hj]
           []
           "=>"
           (Term.app
            (Term.proj `not_mem_ne_locus "." (fieldIdx "1"))
            [(Term.fun
              "fun"
              (Term.basicFun
               [`h]
               []
               "=>"
               (Term.app
                (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt)
                [`hj])))])))
         ","
         (Term.app
          (Term.proj (Term.app `h [(Term.hole "_")]) "." `lt_of_ne)
          [(Init.Core.«term_$_»
            (Term.proj `mem_ne_locus "." (fieldIdx "1"))
            " $ "
            (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")]))])]
        "⟩"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor
       "⟨"
       [(Term.app
         `Finset.min'
         [(Term.hole "_") (Term.app (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2")) [`hne])])
        ","
        (Term.fun
         "fun"
         (Term.basicFun
          [`j `hj]
          []
          "=>"
          (Term.app
           (Term.proj `not_mem_ne_locus "." (fieldIdx "1"))
           [(Term.fun
             "fun"
             (Term.basicFun
              [`h]
              []
              "=>"
              (Term.app
               (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt)
               [`hj])))])))
        ","
        (Term.app
         (Term.proj (Term.app `h [(Term.hole "_")]) "." `lt_of_ne)
         [(Init.Core.«term_$_»
           (Term.proj `mem_ne_locus "." (fieldIdx "1"))
           " $ "
           (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")]))])]
       "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       (Term.proj (Term.app `h [(Term.hole "_")]) "." `lt_of_ne)
       [(Init.Core.«term_$_»
         (Term.proj `mem_ne_locus "." (fieldIdx "1"))
         " $ "
         (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")]))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Init.Core.«term_$_»', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Init.Core.«term_$_»', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Init.Core.«term_$_»
       (Term.proj `mem_ne_locus "." (fieldIdx "1"))
       " $ "
       (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1023, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Finset.min'_mem
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1, term))
      (Term.proj `mem_ne_locus "." (fieldIdx "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `mem_ne_locus
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Init.Core.«term_$_»
      (Term.proj `mem_ne_locus "." (fieldIdx "1"))
      " $ "
      (Term.app `Finset.min'_mem [(Term.hole "_") (Term.hole "_")]))
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj (Term.app `h [(Term.hole "_")]) "." `lt_of_ne)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app `h [(Term.hole "_")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `h [(Term.hole "_")]) ")")
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`j `hj]
        []
        "=>"
        (Term.app
         (Term.proj `not_mem_ne_locus "." (fieldIdx "1"))
         [(Term.fun
           "fun"
           (Term.basicFun
            [`h]
            []
            "=>"
            (Term.app
             (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt)
             [`hj])))])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       (Term.proj `not_mem_ne_locus "." (fieldIdx "1"))
       [(Term.fun
         "fun"
         (Term.basicFun
          [`h]
          []
          "=>"
          (Term.app (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt) [`hj])))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`h]
        []
        "=>"
        (Term.app (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt) [`hj])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt) [`hj])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hj
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h]) "." `not_lt)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1023, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Finset.min'_le
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app `Finset.min'_le [(Term.hole "_") (Term.hole "_") `h])
     ")")
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj `not_mem_ne_locus "." (fieldIdx "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `not_mem_ne_locus
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hj
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `j
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Finset.min' [(Term.hole "_") (Term.app (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2")) [`hne])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2")) [`hne])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hne
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `nonempty_ne_locus_iff
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app (Term.proj `nonempty_ne_locus_iff "." (fieldIdx "2")) [`hne])
     ")")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Finset.min'
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1, tactic))
      (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.skip', expected 'Lean.Parser.Tactic.tacticSeq'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.basicFun', expected 'Lean.Parser.Term.matchAlts'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.basicFun', expected 'Lean.Parser.Term.matchAlts'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  to_lex_monotone
  : Monotone @ toLex Π₀ i , α i
  :=
    fun
      a b h
        =>
        le_of_lt_or_eq
          $
          or_iff_not_imp_right . 2
            $
            fun
              hne
                =>
                by
                  skip
                    <;>
                    exact
                      ⟨
                        Finset.min' _ nonempty_ne_locus_iff . 2 hne
                          ,
                          fun j hj => not_mem_ne_locus . 1 fun h => Finset.min'_le _ _ h . not_lt hj
                          ,
                          h _ . lt_of_ne mem_ne_locus . 1 $ Finset.min'_mem _ _
                        ⟩
#align dfinsupp.to_lex_monotone Dfinsupp.to_lex_monotone

theorem lt_of_forall_lt_of_lt (a b : Lex (Π₀ i, α i)) (i : ι) :
    (∀ j < i, ofLex a j = ofLex b j) → ofLex a i < ofLex b i → a < b := fun h1 h2 => ⟨i, h1, h2⟩
#align dfinsupp.lt_of_forall_lt_of_lt Dfinsupp.lt_of_forall_lt_of_lt

end Zero

section Covariants

variable [LinearOrder ι] [∀ i, AddMonoid (α i)] [∀ i, LinearOrder (α i)]

/-!  We are about to sneak in a hypothesis that might appear to be too strong.
We assume `covariant_class` with *strict* inequality `<` also when proving the one with the
*weak* inequality `≤`.  This is actually necessary: addition on `lex (Π₀ i, α i)` may fail to be
monotone, when it is "just" monotone on `α i`. -/


section Left

variable [∀ i, CovariantClass (α i) (α i) (· + ·) (· < ·)]

instance Lex.covariant_class_lt_left : CovariantClass (Lex (Π₀ i, α i)) (Lex (Π₀ i, α i)) (· + ·) (· < ·) :=
  ⟨fun f g h ⟨a, lta, ha⟩ => ⟨a, fun j ja => congr_arg ((· + ·) _) (lta j ja), add_lt_add_left ha _⟩⟩
#align dfinsupp.lex.covariant_class_lt_left Dfinsupp.Lex.covariant_class_lt_left

instance Lex.covariant_class_le_left : CovariantClass (Lex (Π₀ i, α i)) (Lex (Π₀ i, α i)) (· + ·) (· ≤ ·) :=
  Add.to_covariant_class_left _
#align dfinsupp.lex.covariant_class_le_left Dfinsupp.Lex.covariant_class_le_left

end Left

section Right

variable [∀ i, CovariantClass (α i) (α i) (Function.swap (· + ·)) (· < ·)]

instance Lex.covariant_class_lt_right :
    CovariantClass (Lex (Π₀ i, α i)) (Lex (Π₀ i, α i)) (Function.swap (· + ·)) (· < ·) :=
  ⟨fun f g h ⟨a, lta, ha⟩ => ⟨a, fun j ja => congr_arg (· + ofLex f j) (lta j ja), add_lt_add_right ha _⟩⟩
#align dfinsupp.lex.covariant_class_lt_right Dfinsupp.Lex.covariant_class_lt_right

instance Lex.covariant_class_le_right :
    CovariantClass (Lex (Π₀ i, α i)) (Lex (Π₀ i, α i)) (Function.swap (· + ·)) (· ≤ ·) :=
  Add.to_covariant_class_right _
#align dfinsupp.lex.covariant_class_le_right Dfinsupp.Lex.covariant_class_le_right

end Right

end Covariants

end Dfinsupp

