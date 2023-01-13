/-
Copyright (c) 2021 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson

! This file was ported from Lean 3 source module order.well_founded_set
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Antichain
import Mathbin.Order.OrderIsoNat
import Mathbin.Order.WellFounded
import Mathbin.Tactic.Tfae

/-!
# Well-founded sets

A well-founded subset of an ordered type is one on which the relation `<` is well-founded.

## Main Definitions
 * `set.well_founded_on s r` indicates that the relation `r` is
  well-founded when restricted to the set `s`.
 * `set.is_wf s` indicates that `<` is well-founded when restricted to `s`.
 * `set.partially_well_ordered_on s r` indicates that the relation `r` is
  partially well-ordered (also known as well quasi-ordered) when restricted to the set `s`.
 * `set.is_pwo s` indicates that any infinite sequence of elements in `s` contains an infinite
  monotone subsequence. Note that this is equivalent to containing only two comparable elements.

## Main Results
 * Higman's Lemma, `set.partially_well_ordered_on.partially_well_ordered_on_sublist_forall₂`,
  shows that if `r` is partially well-ordered on `s`, then `list.sublist_forall₂` is partially
  well-ordered on the set of lists of elements of `s`. The result was originally published by
  Higman, but this proof more closely follows Nash-Williams.
 * `set.well_founded_on_iff` relates `well_founded_on` to the well-foundedness of a relation on the
 original type, to avoid dealing with subtypes.
 * `set.is_wf.mono` shows that a subset of a well-founded subset is well-founded.
 * `set.is_wf.union` shows that the union of two well-founded subsets is well-founded.
 * `finset.is_wf` shows that all `finset`s are well-founded.

## TODO

Prove that `s` is partial well ordered iff it has no infinite descending chain or antichain.

## References
 * [Higman, *Ordering by Divisibility in Abstract Algebras*][Higman52]
 * [Nash-Williams, *On Well-Quasi-Ordering Finite Trees*][Nash-Williams63]
-/


variable {ι α β : Type _}

namespace Set

/-! ### Relations well-founded on sets -/


/-- `s.well_founded_on r` indicates that the relation `r` is well-founded when restricted to `s`. -/
def WellFoundedOn (s : Set α) (r : α → α → Prop) : Prop :=
  WellFounded fun a b : s => r a b
#align set.well_founded_on Set.WellFoundedOn

@[simp]
theorem well_founded_on_empty (r : α → α → Prop) : WellFoundedOn ∅ r :=
  wellFounded_of_isEmpty _
#align set.well_founded_on_empty Set.well_founded_on_empty

section WellFoundedOn

variable {r r' : α → α → Prop}

section AnyRel

variable {s t : Set α} {x y : α}

theorem well_founded_on_iff :
    s.WellFoundedOn r ↔ WellFounded fun a b : α => r a b ∧ a ∈ s ∧ b ∈ s :=
  by
  have f : RelEmbedding (fun (a : s) (b : s) => r a b) fun a b : α => r a b ∧ a ∈ s ∧ b ∈ s :=
    ⟨⟨coe, Subtype.coe_injective⟩, fun a b => by simp⟩
  refine' ⟨fun h => _, f.well_founded⟩
  rw [WellFounded.wellFounded_iff_has_min]
  intro t ht
  by_cases hst : (s ∩ t).Nonempty
  · rw [← Subtype.preimage_coe_nonempty] at hst
    rcases h.has_min (coe ⁻¹' t) hst with ⟨⟨m, ms⟩, mt, hm⟩
    exact ⟨m, mt, fun x xt ⟨xm, xs, ms⟩ => hm ⟨x, xs⟩ xt xm⟩
  · rcases ht with ⟨m, mt⟩
    exact ⟨m, mt, fun x xt ⟨xm, xs, ms⟩ => hst ⟨m, ⟨ms, mt⟩⟩⟩
#align set.well_founded_on_iff Set.well_founded_on_iff

namespace WellFoundedOn

protected theorem induction (hs : s.WellFoundedOn r) (hx : x ∈ s) {P : α → Prop}
    (hP : ∀ y ∈ s, (∀ z ∈ s, r z y → P z) → P y) : P x :=
  by
  let Q : s → Prop := fun y => P y
  change Q ⟨x, hx⟩
  refine' WellFounded.induction hs ⟨x, hx⟩ _
  simpa only [Subtype.forall]
#align set.well_founded_on.induction Set.WellFoundedOn.induction

protected theorem mono (h : t.WellFoundedOn r') (hle : r ≤ r') (hst : s ⊆ t) : s.WellFoundedOn r :=
  by
  rw [well_founded_on_iff] at *
  refine' Subrelation.wf (fun x y xy => _) h
  exact ⟨hle _ _ xy.1, hst xy.2.1, hst xy.2.2⟩
#align set.well_founded_on.mono Set.WellFoundedOn.mono

theorem subset (h : t.WellFoundedOn r) (hst : s ⊆ t) : s.WellFoundedOn r :=
  h.mono le_rfl hst
#align set.well_founded_on.subset Set.WellFoundedOn.subset

open Relation

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers
      [(Command.docComment
        "/--"
        "`a` is accessible under the relation `r` iff `r` is well-founded on the downward transitive\n  closure of `a` under `r` (including `a` or not). -/")]
      []
      []
      []
      []
      [])
     (Command.theorem
      "theorem"
      (Command.declId `acc_iff_well_founded_on [])
      (Command.declSig
       [(Term.implicitBinder "{" [`α] [] "}")
        (Term.implicitBinder
         "{"
         [`r]
         [":" (Term.arrow `α "→" (Term.arrow `α "→" (Term.prop "Prop")))]
         "}")
        (Term.implicitBinder "{" [`a] [":" `α] "}")]
       (Term.typeSpec
        ":"
        (Term.proj
         («term[_]»
          "["
          [(Term.app `Acc [`r `a])
           ","
           (Term.app
            (Term.proj
             (Set.«term{_|_}»
              "{"
              (Std.ExtendedBinder.extBinder (Lean.binderIdent `b) [])
              "|"
              (Term.app `ReflTransGen [`r `b `a])
              "}")
             "."
             `WellFoundedOn)
            [`r])
           ","
           (Term.app
            (Term.proj
             (Set.«term{_|_}»
              "{"
              (Std.ExtendedBinder.extBinder (Lean.binderIdent `b) [])
              "|"
              (Term.app `TransGen [`r `b `a])
              "}")
             "."
             `WellFoundedOn)
            [`r])]
          "]")
         "."
         `Tfae)))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.tfaeHave "tfae_have" [] (num "1") "→" (num "2"))
           []
           (tactic__
            (cdotTk (patternIgnore (token.«· » "·")))
            [(Tactic.refine'
              "refine'"
              (Term.fun
               "fun"
               (Term.basicFun
                [`h]
                []
                "=>"
                (Term.anonymousCtor
                 "⟨"
                 [(Term.fun "fun" (Term.basicFun [`b] [] "=>" (Term.hole "_")))]
                 "⟩"))))
             []
             (Tactic.apply "apply" `InvImage.accessible)
             []
             (Tactic.rwSeq
              "rw"
              []
              (Tactic.rwRuleSeq
               "["
               [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `acc_transGen_iff)]
               "]")
              [(Tactic.location "at" (Tactic.locationHyp [`h] [(patternIgnore (token.«⊢» "⊢"))]))])
             []
             (Std.Tactic.obtain
              "obtain"
              [(Std.Tactic.RCases.rcasesPatMed
                [(Std.Tactic.RCases.rcasesPat.one `h') "|" (Std.Tactic.RCases.rcasesPat.one `h')])]
              []
              [":="
               [(Term.app
                 (Term.proj `refl_trans_gen_iff_eq_or_trans_gen "." (fieldIdx "1"))
                 [(Term.proj `b "." (fieldIdx "2"))])]])
             []
             (tactic__
              (cdotTk (patternIgnore (token.«· » "·")))
              [(Std.Tactic.tacticRwa__
                "rwa"
                (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `h')] "]")
                [(Tactic.location "at" (Tactic.locationHyp [`h] []))])])
             []
             (tactic__
              (cdotTk (patternIgnore (token.«· » "·")))
              [(Tactic.exact "exact" (Term.app `h.inv [`h']))])])
           []
           (Tactic.tfaeHave "tfae_have" [] (num "2") "→" (num "3"))
           []
           (tactic__
            (cdotTk (patternIgnore (token.«· » "·")))
            [(Tactic.exact
              "exact"
              (Term.fun
               "fun"
               (Term.basicFun
                [`h]
                []
                "=>"
                (Term.app
                 (Term.proj `h "." `Subset)
                 [(Term.fun
                   "fun"
                   (Term.basicFun [(Term.hole "_")] [] "=>" `trans_gen.to_refl))]))))])
           []
           (Tactic.tfaeHave "tfae_have" [] (num "3") "→" (num "1"))
           []
           (tactic__
            (cdotTk (patternIgnore (token.«· » "·")))
            [(Tactic.refine'
              "refine'"
              (Term.fun
               "fun"
               (Term.basicFun
                [`h]
                []
                "=>"
                (Term.app
                 `Acc.intro
                 [(Term.hole "_")
                  (Term.fun
                   "fun"
                   (Term.basicFun
                    [`b `hb]
                    []
                    "=>"
                    (Term.app
                     (Term.proj
                      (Term.app
                       (Term.proj `h "." `apply)
                       [(Term.anonymousCtor "⟨" [`b "," (Term.app `trans_gen.single [`hb])] "⟩")])
                      "."
                      `of_fibration)
                     [`Subtype.val (Term.hole "_")])))]))))
             []
             (Tactic.exact
              "exact"
              (Term.fun
               "fun"
               (Term.basicFun
                [(Term.anonymousCtor "⟨" [`c "," `hc] "⟩") `d `h]
                []
                "=>"
                (Term.anonymousCtor
                 "⟨"
                 [(Term.anonymousCtor "⟨" [`d "," (Term.app `trans_gen.head [`h `hc])] "⟩")
                  ","
                  `h
                  ","
                  `rfl]
                 "⟩"))))])
           []
           (Tactic.tfaeFinish "tfae_finish")])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.tfaeHave "tfae_have" [] (num "1") "→" (num "2"))
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.refine'
             "refine'"
             (Term.fun
              "fun"
              (Term.basicFun
               [`h]
               []
               "=>"
               (Term.anonymousCtor
                "⟨"
                [(Term.fun "fun" (Term.basicFun [`b] [] "=>" (Term.hole "_")))]
                "⟩"))))
            []
            (Tactic.apply "apply" `InvImage.accessible)
            []
            (Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [(patternIgnore (token.«← » "←"))] `acc_transGen_iff)]
              "]")
             [(Tactic.location "at" (Tactic.locationHyp [`h] [(patternIgnore (token.«⊢» "⊢"))]))])
            []
            (Std.Tactic.obtain
             "obtain"
             [(Std.Tactic.RCases.rcasesPatMed
               [(Std.Tactic.RCases.rcasesPat.one `h') "|" (Std.Tactic.RCases.rcasesPat.one `h')])]
             []
             [":="
              [(Term.app
                (Term.proj `refl_trans_gen_iff_eq_or_trans_gen "." (fieldIdx "1"))
                [(Term.proj `b "." (fieldIdx "2"))])]])
            []
            (tactic__
             (cdotTk (patternIgnore (token.«· » "·")))
             [(Std.Tactic.tacticRwa__
               "rwa"
               (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `h')] "]")
               [(Tactic.location "at" (Tactic.locationHyp [`h] []))])])
            []
            (tactic__
             (cdotTk (patternIgnore (token.«· » "·")))
             [(Tactic.exact "exact" (Term.app `h.inv [`h']))])])
          []
          (Tactic.tfaeHave "tfae_have" [] (num "2") "→" (num "3"))
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.exact
             "exact"
             (Term.fun
              "fun"
              (Term.basicFun
               [`h]
               []
               "=>"
               (Term.app
                (Term.proj `h "." `Subset)
                [(Term.fun
                  "fun"
                  (Term.basicFun [(Term.hole "_")] [] "=>" `trans_gen.to_refl))]))))])
          []
          (Tactic.tfaeHave "tfae_have" [] (num "3") "→" (num "1"))
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.refine'
             "refine'"
             (Term.fun
              "fun"
              (Term.basicFun
               [`h]
               []
               "=>"
               (Term.app
                `Acc.intro
                [(Term.hole "_")
                 (Term.fun
                  "fun"
                  (Term.basicFun
                   [`b `hb]
                   []
                   "=>"
                   (Term.app
                    (Term.proj
                     (Term.app
                      (Term.proj `h "." `apply)
                      [(Term.anonymousCtor "⟨" [`b "," (Term.app `trans_gen.single [`hb])] "⟩")])
                     "."
                     `of_fibration)
                    [`Subtype.val (Term.hole "_")])))]))))
            []
            (Tactic.exact
             "exact"
             (Term.fun
              "fun"
              (Term.basicFun
               [(Term.anonymousCtor "⟨" [`c "," `hc] "⟩") `d `h]
               []
               "=>"
               (Term.anonymousCtor
                "⟨"
                [(Term.anonymousCtor "⟨" [`d "," (Term.app `trans_gen.head [`h `hc])] "⟩")
                 ","
                 `h
                 ","
                 `rfl]
                "⟩"))))])
          []
          (Tactic.tfaeFinish "tfae_finish")])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tfaeFinish "tfae_finish")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (tactic__
       (cdotTk (patternIgnore (token.«· » "·")))
       [(Tactic.refine'
         "refine'"
         (Term.fun
          "fun"
          (Term.basicFun
           [`h]
           []
           "=>"
           (Term.app
            `Acc.intro
            [(Term.hole "_")
             (Term.fun
              "fun"
              (Term.basicFun
               [`b `hb]
               []
               "=>"
               (Term.app
                (Term.proj
                 (Term.app
                  (Term.proj `h "." `apply)
                  [(Term.anonymousCtor "⟨" [`b "," (Term.app `trans_gen.single [`hb])] "⟩")])
                 "."
                 `of_fibration)
                [`Subtype.val (Term.hole "_")])))]))))
        []
        (Tactic.exact
         "exact"
         (Term.fun
          "fun"
          (Term.basicFun
           [(Term.anonymousCtor "⟨" [`c "," `hc] "⟩") `d `h]
           []
           "=>"
           (Term.anonymousCtor
            "⟨"
            [(Term.anonymousCtor "⟨" [`d "," (Term.app `trans_gen.head [`h `hc])] "⟩")
             ","
             `h
             ","
             `rfl]
            "⟩"))))])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact
       "exact"
       (Term.fun
        "fun"
        (Term.basicFun
         [(Term.anonymousCtor "⟨" [`c "," `hc] "⟩") `d `h]
         []
         "=>"
         (Term.anonymousCtor
          "⟨"
          [(Term.anonymousCtor "⟨" [`d "," (Term.app `trans_gen.head [`h `hc])] "⟩")
           ","
           `h
           ","
           `rfl]
          "⟩"))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [(Term.anonymousCtor "⟨" [`c "," `hc] "⟩") `d `h]
        []
        "=>"
        (Term.anonymousCtor
         "⟨"
         [(Term.anonymousCtor "⟨" [`d "," (Term.app `trans_gen.head [`h `hc])] "⟩") "," `h "," `rfl]
         "⟩")))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor
       "⟨"
       [(Term.anonymousCtor "⟨" [`d "," (Term.app `trans_gen.head [`h `hc])] "⟩") "," `h "," `rfl]
       "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `rfl
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor "⟨" [`d "," (Term.app `trans_gen.head [`h `hc])] "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `trans_gen.head [`h `hc])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hc
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `trans_gen.head
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `d
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `d
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.anonymousCtor', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.anonymousCtor', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.anonymousCtor', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.anonymousCtor "⟨" [`c "," `hc] "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hc
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `c
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.refine'
       "refine'"
       (Term.fun
        "fun"
        (Term.basicFun
         [`h]
         []
         "=>"
         (Term.app
          `Acc.intro
          [(Term.hole "_")
           (Term.fun
            "fun"
            (Term.basicFun
             [`b `hb]
             []
             "=>"
             (Term.app
              (Term.proj
               (Term.app
                (Term.proj `h "." `apply)
                [(Term.anonymousCtor "⟨" [`b "," (Term.app `trans_gen.single [`hb])] "⟩")])
               "."
               `of_fibration)
              [`Subtype.val (Term.hole "_")])))]))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`h]
        []
        "=>"
        (Term.app
         `Acc.intro
         [(Term.hole "_")
          (Term.fun
           "fun"
           (Term.basicFun
            [`b `hb]
            []
            "=>"
            (Term.app
             (Term.proj
              (Term.app
               (Term.proj `h "." `apply)
               [(Term.anonymousCtor "⟨" [`b "," (Term.app `trans_gen.single [`hb])] "⟩")])
              "."
              `of_fibration)
             [`Subtype.val (Term.hole "_")])))])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `Acc.intro
       [(Term.hole "_")
        (Term.fun
         "fun"
         (Term.basicFun
          [`b `hb]
          []
          "=>"
          (Term.app
           (Term.proj
            (Term.app
             (Term.proj `h "." `apply)
             [(Term.anonymousCtor "⟨" [`b "," (Term.app `trans_gen.single [`hb])] "⟩")])
            "."
            `of_fibration)
           [`Subtype.val (Term.hole "_")])))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`b `hb]
        []
        "=>"
        (Term.app
         (Term.proj
          (Term.app
           (Term.proj `h "." `apply)
           [(Term.anonymousCtor "⟨" [`b "," (Term.app `trans_gen.single [`hb])] "⟩")])
          "."
          `of_fibration)
         [`Subtype.val (Term.hole "_")])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       (Term.proj
        (Term.app
         (Term.proj `h "." `apply)
         [(Term.anonymousCtor "⟨" [`b "," (Term.app `trans_gen.single [`hb])] "⟩")])
        "."
        `of_fibration)
       [`Subtype.val (Term.hole "_")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      `Subtype.val
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1023, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj
       (Term.app
        (Term.proj `h "." `apply)
        [(Term.anonymousCtor "⟨" [`b "," (Term.app `trans_gen.single [`hb])] "⟩")])
       "."
       `of_fibration)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app
       (Term.proj `h "." `apply)
       [(Term.anonymousCtor "⟨" [`b "," (Term.app `trans_gen.single [`hb])] "⟩")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.anonymousCtor', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.anonymousCtor', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor "⟨" [`b "," (Term.app `trans_gen.single [`hb])] "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `trans_gen.single [`hb])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hb
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `trans_gen.single
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `b
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj `h "." `apply)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `h
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app
      (Term.proj `h "." `apply)
      [(Term.anonymousCtor "⟨" [`b "," (Term.app `trans_gen.single [`hb])] "⟩")])
     ")")
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hb
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `b
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1023, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Acc.intro
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tfaeHave "tfae_have" [] (num "3") "→" (num "1"))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«→»', expected 'token.« → »'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«→»', expected 'token.« ↔ »'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«→»', expected 'token.« ← »'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
/--
    `a` is accessible under the relation `r` iff `r` is well-founded on the downward transitive
      closure of `a` under `r` (including `a` or not). -/
  theorem
    acc_iff_well_founded_on
    { α } { r : α → α → Prop } { a : α }
      :
        [
            Acc r a
              ,
              { b | ReflTransGen r b a } . WellFoundedOn r
              ,
              { b | TransGen r b a } . WellFoundedOn r
            ]
          .
          Tfae
    :=
      by
        tfae_have 1 → 2
          ·
            refine' fun h => ⟨ fun b => _ ⟩
              apply InvImage.accessible
              rw [ ← acc_transGen_iff ] at h ⊢
              obtain h' | h' := refl_trans_gen_iff_eq_or_trans_gen . 1 b . 2
              · rwa [ h' ] at h
              · exact h.inv h'
          tfae_have 2 → 3
          · exact fun h => h . Subset fun _ => trans_gen.to_refl
          tfae_have 3 → 1
          ·
            refine'
                fun
                  h
                    =>
                    Acc.intro
                      _
                        fun
                          b hb => h . apply ⟨ b , trans_gen.single hb ⟩ . of_fibration Subtype.val _
              exact fun ⟨ c , hc ⟩ d h => ⟨ ⟨ d , trans_gen.head h hc ⟩ , h , rfl ⟩
          tfae_finish
#align set.well_founded_on.acc_iff_well_founded_on Set.WellFoundedOn.acc_iff_well_founded_on

end WellFoundedOn

end AnyRel

section IsStrictOrder

variable [IsStrictOrder α r] {s t : Set α}

instance IsStrictOrder.subset : IsStrictOrder α fun a b : α => r a b ∧ a ∈ s ∧ b ∈ s
    where
  to_is_irrefl := ⟨fun a con => irrefl_of r a con.1⟩
  to_is_trans := ⟨fun a b c ab bc => ⟨trans_of r ab.1 bc.1, ab.2.1, bc.2.2⟩⟩
#align set.is_strict_order.subset Set.IsStrictOrder.subset

theorem well_founded_on_iff_no_descending_seq :
    s.WellFoundedOn r ↔ ∀ f : ((· > ·) : ℕ → ℕ → Prop) ↪r r, ¬∀ n, f n ∈ s :=
  by
  simp only [well_founded_on_iff, RelEmbedding.well_founded_iff_no_descending_seq, ← not_exists, ←
    not_nonempty_iff, not_iff_not]
  constructor
  · rintro ⟨⟨f, hf⟩⟩
    have H : ∀ n, f n ∈ s := fun n => (hf.2 n.lt_succ_self).2.2
    refine' ⟨⟨f, _⟩, H⟩
    simpa only [H, and_true_iff] using @hf
  · rintro ⟨⟨f, hf⟩, hfs : ∀ n, f n ∈ s⟩
    refine' ⟨⟨f, _⟩⟩
    simpa only [hfs, and_true_iff] using @hf
#align set.well_founded_on_iff_no_descending_seq Set.well_founded_on_iff_no_descending_seq

theorem WellFoundedOn.union (hs : s.WellFoundedOn r) (ht : t.WellFoundedOn r) :
    (s ∪ t).WellFoundedOn r :=
  by
  rw [well_founded_on_iff_no_descending_seq] at *
  rintro f hf
  rcases Nat.exists_subseq_of_forall_mem_union f hf with ⟨g, hg | hg⟩
  exacts[hs (g.dual.lt_embedding.trans f) hg, ht (g.dual.lt_embedding.trans f) hg]
#align set.well_founded_on.union Set.WellFoundedOn.union

@[simp]
theorem well_founded_on_union : (s ∪ t).WellFoundedOn r ↔ s.WellFoundedOn r ∧ t.WellFoundedOn r :=
  ⟨fun h => ⟨h.Subset <| subset_union_left _ _, h.Subset <| subset_union_right _ _⟩, fun h =>
    h.1.union h.2⟩
#align set.well_founded_on_union Set.well_founded_on_union

end IsStrictOrder

end WellFoundedOn

/-! ### Sets well-founded w.r.t. the strict inequality -/


section LT

variable [LT α] {s t : Set α}

/-- `s.is_wf` indicates that `<` is well-founded when restricted to `s`. -/
def IsWf (s : Set α) : Prop :=
  WellFoundedOn s (· < ·)
#align set.is_wf Set.IsWf

@[simp]
theorem is_wf_empty : IsWf (∅ : Set α) :=
  wellFounded_of_isEmpty _
#align set.is_wf_empty Set.is_wf_empty

theorem is_wf_univ_iff : IsWf (univ : Set α) ↔ WellFounded ((· < ·) : α → α → Prop) := by
  simp [is_wf, well_founded_on_iff]
#align set.is_wf_univ_iff Set.is_wf_univ_iff

theorem IsWf.mono (h : IsWf t) (st : s ⊆ t) : IsWf s :=
  h.Subset st
#align set.is_wf.mono Set.IsWf.mono

end LT

section Preorder

variable [Preorder α] {s t : Set α} {a : α}

protected theorem IsWf.union (hs : IsWf s) (ht : IsWf t) : IsWf (s ∪ t) :=
  hs.union ht
#align set.is_wf.union Set.IsWf.union

@[simp]
theorem is_wf_union : IsWf (s ∪ t) ↔ IsWf s ∧ IsWf t :=
  well_founded_on_union
#align set.is_wf_union Set.is_wf_union

end Preorder

section Preorder

variable [Preorder α] {s t : Set α} {a : α}

theorem is_wf_iff_no_descending_seq :
    IsWf s ↔ ∀ f : ℕ → α, StrictAnti f → ¬∀ n, f (OrderDual.toDual n) ∈ s :=
  well_founded_on_iff_no_descending_seq.trans
    ⟨fun H f hf => H ⟨⟨f, hf.Injective⟩, fun a b => hf.lt_iff_lt⟩, fun H f =>
      H f fun _ _ => f.map_rel_iff.2⟩
#align set.is_wf_iff_no_descending_seq Set.is_wf_iff_no_descending_seq

end Preorder

/-!
### Partially well-ordered sets

A set is partially well-ordered by a relation `r` when any infinite sequence contains two elements
where the first is related to the second by `r`. Equivalently, any antichain (see `is_antichain`) is
finite, see `set.partially_well_ordered_on_iff_finite_antichains`.
-/


/-- A subset is partially well-ordered by a relation `r` when any infinite sequence contains
  two elements where the first is related to the second by `r`. -/
def PartiallyWellOrderedOn (s : Set α) (r : α → α → Prop) : Prop :=
  ∀ f : ℕ → α, (∀ n, f n ∈ s) → ∃ m n : ℕ, m < n ∧ r (f m) (f n)
#align set.partially_well_ordered_on Set.PartiallyWellOrderedOn

section PartiallyWellOrderedOn

variable {r : α → α → Prop} {r' : β → β → Prop} {f : α → β} {s : Set α} {t : Set α} {a : α}

theorem PartiallyWellOrderedOn.mono (ht : t.PartiallyWellOrderedOn r) (h : s ⊆ t) :
    s.PartiallyWellOrderedOn r := fun f hf => (ht f) fun n => h <| hf n
#align set.partially_well_ordered_on.mono Set.PartiallyWellOrderedOn.mono

@[simp]
theorem partially_well_ordered_on_empty (r : α → α → Prop) : PartiallyWellOrderedOn ∅ r :=
  fun f hf => (hf 0).elim
#align set.partially_well_ordered_on_empty Set.partially_well_ordered_on_empty

theorem PartiallyWellOrderedOn.union (hs : s.PartiallyWellOrderedOn r)
    (ht : t.PartiallyWellOrderedOn r) : (s ∪ t).PartiallyWellOrderedOn r :=
  by
  rintro f hf
  rcases Nat.exists_subseq_of_forall_mem_union f hf with ⟨g, hgs | hgt⟩
  · rcases hs _ hgs with ⟨m, n, hlt, hr⟩
    exact ⟨g m, g n, g.strict_mono hlt, hr⟩
  · rcases ht _ hgt with ⟨m, n, hlt, hr⟩
    exact ⟨g m, g n, g.strict_mono hlt, hr⟩
#align set.partially_well_ordered_on.union Set.PartiallyWellOrderedOn.union

@[simp]
theorem partially_well_ordered_on_union :
    (s ∪ t).PartiallyWellOrderedOn r ↔ s.PartiallyWellOrderedOn r ∧ t.PartiallyWellOrderedOn r :=
  ⟨fun h => ⟨h.mono <| subset_union_left _ _, h.mono <| subset_union_right _ _⟩, fun h =>
    h.1.union h.2⟩
#align set.partially_well_ordered_on_union Set.partially_well_ordered_on_union

theorem PartiallyWellOrderedOn.image_of_monotone_on (hs : s.PartiallyWellOrderedOn r)
    (hf : ∀ a₁ ∈ s, ∀ a₂ ∈ s, r a₁ a₂ → r' (f a₁) (f a₂)) : (f '' s).PartiallyWellOrderedOn r' :=
  by
  intro g' hg'
  choose g hgs heq using hg'
  obtain rfl : f ∘ g = g'; exact funext HEq
  obtain ⟨m, n, hlt, hmn⟩ := hs g hgs
  exact ⟨m, n, hlt, hf _ (hgs m) _ (hgs n) hmn⟩
#align
  set.partially_well_ordered_on.image_of_monotone_on Set.PartiallyWellOrderedOn.image_of_monotone_on

theorem IsAntichain.finite_of_partially_well_ordered_on (ha : IsAntichain r s)
    (hp : s.PartiallyWellOrderedOn r) : s.Finite :=
  by
  refine' not_infinite.1 fun hi => _
  obtain ⟨m, n, hmn, h⟩ := hp (fun n => hi.nat_embedding _ n) fun n => (hi.nat_embedding _ n).2
  exact
    hmn.ne
      ((hi.nat_embedding _).Injective <|
        Subtype.val_injective <| ha.eq (hi.nat_embedding _ m).2 (hi.nat_embedding _ n).2 h)
#align
  is_antichain.finite_of_partially_well_ordered_on IsAntichain.finite_of_partially_well_ordered_on

section IsRefl

variable [IsRefl α r]

protected theorem Finite.partially_well_ordered_on (hs : s.Finite) : s.PartiallyWellOrderedOn r :=
  by
  intro f hf
  obtain ⟨m, n, hmn, h⟩ := hs.exists_lt_map_eq_of_forall_mem hf
  exact ⟨m, n, hmn, h.subst <| refl (f m)⟩
#align set.finite.partially_well_ordered_on Set.Finite.partially_well_ordered_on

theorem IsAntichain.partially_well_ordered_on_iff (hs : IsAntichain r s) :
    s.PartiallyWellOrderedOn r ↔ s.Finite :=
  ⟨hs.finite_of_partially_well_ordered_on, Finite.partially_well_ordered_on⟩
#align is_antichain.partially_well_ordered_on_iff IsAntichain.partially_well_ordered_on_iff

@[simp]
theorem partially_well_ordered_on_singleton (a : α) : PartiallyWellOrderedOn {a} r :=
  (finite_singleton a).PartiallyWellOrderedOn
#align set.partially_well_ordered_on_singleton Set.partially_well_ordered_on_singleton

@[simp]
theorem partially_well_ordered_on_insert :
    PartiallyWellOrderedOn (insert a s) r ↔ PartiallyWellOrderedOn s r := by
  simp only [← singleton_union, partially_well_ordered_on_union,
    partially_well_ordered_on_singleton, true_and_iff]
#align set.partially_well_ordered_on_insert Set.partially_well_ordered_on_insert

protected theorem PartiallyWellOrderedOn.insert (h : PartiallyWellOrderedOn s r) (a : α) :
    PartiallyWellOrderedOn (insert a s) r :=
  partially_well_ordered_on_insert.2 h
#align set.partially_well_ordered_on.insert Set.PartiallyWellOrderedOn.insert

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (t «expr ⊆ » s) -/
theorem partially_well_ordered_on_iff_finite_antichains [IsSymm α r] :
    s.PartiallyWellOrderedOn r ↔ ∀ (t) (_ : t ⊆ s), IsAntichain r t → t.Finite :=
  by
  refine' ⟨fun h t ht hrt => hrt.finite_of_partially_well_ordered_on (h.mono ht), _⟩
  rintro hs f hf
  by_contra' H
  refine' infinite_range_of_injective (fun m n hmn => _) (hs _ (range_subset_iff.2 hf) _)
  · obtain h | h | h := lt_trichotomy m n
    · refine' (H _ _ h _).elim
      rw [hmn]
      exact refl _
    · exact h
    · refine' (H _ _ h _).elim
      rw [hmn]
      exact refl _
  rintro _ ⟨m, hm, rfl⟩ _ ⟨n, hn, rfl⟩ hmn
  obtain h | h := (ne_of_apply_ne _ hmn).lt_or_lt
  · exact H _ _ h
  · exact mt symm (H _ _ h)
#align
  set.partially_well_ordered_on_iff_finite_antichains Set.partially_well_ordered_on_iff_finite_antichains

variable [IsTrans α r]

theorem PartiallyWellOrderedOn.exists_monotone_subseq (h : s.PartiallyWellOrderedOn r) (f : ℕ → α)
    (hf : ∀ n, f n ∈ s) : ∃ g : ℕ ↪o ℕ, ∀ m n : ℕ, m ≤ n → r (f (g m)) (f (g n)) :=
  by
  obtain ⟨g, h1 | h2⟩ := exists_increasing_or_nonincreasing_subseq r f
  · refine' ⟨g, fun m n hle => _⟩
    obtain hlt | rfl := hle.lt_or_eq
    exacts[h1 m n hlt, refl_of r _]
  · exfalso
    obtain ⟨m, n, hlt, hle⟩ := h (f ∘ g) fun n => hf _
    exact h2 m n hlt hle
#align
  set.partially_well_ordered_on.exists_monotone_subseq Set.PartiallyWellOrderedOn.exists_monotone_subseq

theorem partially_well_ordered_on_iff_exists_monotone_subseq :
    s.PartiallyWellOrderedOn r ↔
      ∀ f : ℕ → α, (∀ n, f n ∈ s) → ∃ g : ℕ ↪o ℕ, ∀ m n : ℕ, m ≤ n → r (f (g m)) (f (g n)) :=
  by
  classical
    constructor <;> intro h f hf
    · exact h.exists_monotone_subseq f hf
    · obtain ⟨g, gmon⟩ := h f hf
      exact ⟨g 0, g 1, g.lt_iff_lt.2 zero_lt_one, gmon _ _ zero_le_one⟩
#align
  set.partially_well_ordered_on_iff_exists_monotone_subseq Set.partially_well_ordered_on_iff_exists_monotone_subseq

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
protected theorem PartiallyWellOrderedOn.prod {t : Set β} (hs : PartiallyWellOrderedOn s r)
    (ht : PartiallyWellOrderedOn t r') :
    PartiallyWellOrderedOn (s ×ˢ t) fun x y : α × β => r x.1 y.1 ∧ r' x.2 y.2 :=
  by
  intro f hf
  obtain ⟨g₁, h₁⟩ := hs.exists_monotone_subseq (Prod.fst ∘ f) fun n => (hf n).1
  obtain ⟨m, n, hlt, hle⟩ := ht (Prod.snd ∘ f ∘ g₁) fun n => (hf _).2
  exact ⟨g₁ m, g₁ n, g₁.strict_mono hlt, h₁ _ _ hlt.le, hle⟩
#align set.partially_well_ordered_on.prod Set.PartiallyWellOrderedOn.prod

end IsRefl

theorem PartiallyWellOrderedOn.well_founded_on [IsPreorder α r] (h : s.PartiallyWellOrderedOn r) :
    s.WellFoundedOn fun a b => r a b ∧ ¬r b a :=
  by
  letI : Preorder α :=
    { le := r
      le_refl := refl_of r
      le_trans := fun _ _ _ => trans_of r }
  change s.well_founded_on (· < ·); change s.partially_well_ordered_on (· ≤ ·) at h
  rw [well_founded_on_iff_no_descending_seq]
  intro f hf
  obtain ⟨m, n, hlt, hle⟩ := h f hf
  exact (f.map_rel_iff.2 hlt).not_le hle
#align set.partially_well_ordered_on.well_founded_on Set.PartiallyWellOrderedOn.well_founded_on

end PartiallyWellOrderedOn

section IsPwo

variable [Preorder α] [Preorder β] {s t : Set α}

/-- A subset of a preorder is partially well-ordered when any infinite sequence contains
  a monotone subsequence of length 2 (or equivalently, an infinite monotone subsequence). -/
def IsPwo (s : Set α) : Prop :=
  PartiallyWellOrderedOn s (· ≤ ·)
#align set.is_pwo Set.IsPwo

theorem IsPwo.mono (ht : t.IsPwo) : s ⊆ t → s.IsPwo :=
  ht.mono
#align set.is_pwo.mono Set.IsPwo.mono

theorem IsPwo.exists_monotone_subseq (h : s.IsPwo) (f : ℕ → α) (hf : ∀ n, f n ∈ s) :
    ∃ g : ℕ ↪o ℕ, Monotone (f ∘ g) :=
  h.exists_monotone_subseq f hf
#align set.is_pwo.exists_monotone_subseq Set.IsPwo.exists_monotone_subseq

theorem is_pwo_iff_exists_monotone_subseq :
    s.IsPwo ↔ ∀ f : ℕ → α, (∀ n, f n ∈ s) → ∃ g : ℕ ↪o ℕ, Monotone (f ∘ g) :=
  partially_well_ordered_on_iff_exists_monotone_subseq
#align set.is_pwo_iff_exists_monotone_subseq Set.is_pwo_iff_exists_monotone_subseq

protected theorem IsPwo.is_wf (h : s.IsPwo) : s.IsWf := by
  simpa only [← lt_iff_le_not_le] using h.well_founded_on
#align set.is_pwo.is_wf Set.IsPwo.is_wf

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem IsPwo.prod {t : Set β} (hs : s.IsPwo) (ht : t.IsPwo) : IsPwo (s ×ˢ t) :=
  hs.Prod ht
#align set.is_pwo.prod Set.IsPwo.prod

theorem IsPwo.image_of_monotone_on (hs : s.IsPwo) {f : α → β} (hf : MonotoneOn f s) :
    IsPwo (f '' s) :=
  hs.image_of_monotone_on hf
#align set.is_pwo.image_of_monotone_on Set.IsPwo.image_of_monotone_on

theorem IsPwo.image_of_monotone (hs : s.IsPwo) {f : α → β} (hf : Monotone f) : IsPwo (f '' s) :=
  hs.image_of_monotone_on (hf.MonotoneOn _)
#align set.is_pwo.image_of_monotone Set.IsPwo.image_of_monotone

protected theorem IsPwo.union (hs : IsPwo s) (ht : IsPwo t) : IsPwo (s ∪ t) :=
  hs.union ht
#align set.is_pwo.union Set.IsPwo.union

@[simp]
theorem is_pwo_union : IsPwo (s ∪ t) ↔ IsPwo s ∧ IsPwo t :=
  partially_well_ordered_on_union
#align set.is_pwo_union Set.is_pwo_union

protected theorem Finite.is_pwo (hs : s.Finite) : IsPwo s :=
  hs.PartiallyWellOrderedOn
#align set.finite.is_pwo Set.Finite.is_pwo

@[simp]
theorem is_pwo_of_finite [Finite α] : s.IsPwo :=
  s.to_finite.IsPwo
#align set.is_pwo_of_finite Set.is_pwo_of_finite

@[simp]
theorem is_pwo_singleton (a : α) : IsPwo ({a} : Set α) :=
  (finite_singleton a).IsPwo
#align set.is_pwo_singleton Set.is_pwo_singleton

@[simp]
theorem is_pwo_empty : IsPwo (∅ : Set α) :=
  finite_empty.IsPwo
#align set.is_pwo_empty Set.is_pwo_empty

protected theorem Subsingleton.is_pwo (hs : s.Subsingleton) : IsPwo s :=
  hs.Finite.IsPwo
#align set.subsingleton.is_pwo Set.Subsingleton.is_pwo

@[simp]
theorem is_pwo_insert {a} : IsPwo (insert a s) ↔ IsPwo s := by
  simp only [← singleton_union, is_pwo_union, is_pwo_singleton, true_and_iff]
#align set.is_pwo_insert Set.is_pwo_insert

protected theorem IsPwo.insert (h : IsPwo s) (a : α) : IsPwo (insert a s) :=
  is_pwo_insert.2 h
#align set.is_pwo.insert Set.IsPwo.insert

protected theorem Finite.is_wf (hs : s.Finite) : IsWf s :=
  hs.IsPwo.IsWf
#align set.finite.is_wf Set.Finite.is_wf

@[simp]
theorem is_wf_singleton {a : α} : IsWf ({a} : Set α) :=
  (finite_singleton a).IsWf
#align set.is_wf_singleton Set.is_wf_singleton

protected theorem Subsingleton.is_wf (hs : s.Subsingleton) : IsWf s :=
  hs.IsPwo.IsWf
#align set.subsingleton.is_wf Set.Subsingleton.is_wf

@[simp]
theorem is_wf_insert {a} : IsWf (insert a s) ↔ IsWf s := by
  simp only [← singleton_union, is_wf_union, is_wf_singleton, true_and_iff]
#align set.is_wf_insert Set.is_wf_insert

theorem IsWf.insert (h : IsWf s) (a : α) : IsWf (insert a s) :=
  is_wf_insert.2 h
#align set.is_wf.insert Set.IsWf.insert

end IsPwo

section WellFoundedOn

variable {r : α → α → Prop} [IsStrictOrder α r] {s : Set α} {a : α}

protected theorem Finite.well_founded_on (hs : s.Finite) : s.WellFoundedOn r :=
  letI := partialOrderOfSO r
  hs.is_wf
#align set.finite.well_founded_on Set.Finite.well_founded_on

@[simp]
theorem well_founded_on_singleton : WellFoundedOn ({a} : Set α) r :=
  (finite_singleton a).WellFoundedOn
#align set.well_founded_on_singleton Set.well_founded_on_singleton

protected theorem Subsingleton.well_founded_on (hs : s.Subsingleton) : s.WellFoundedOn r :=
  hs.Finite.WellFoundedOn
#align set.subsingleton.well_founded_on Set.Subsingleton.well_founded_on

@[simp]
theorem well_founded_on_insert : WellFoundedOn (insert a s) r ↔ WellFoundedOn s r := by
  simp only [← singleton_union, well_founded_on_union, well_founded_on_singleton, true_and_iff]
#align set.well_founded_on_insert Set.well_founded_on_insert

theorem WellFoundedOn.insert (h : WellFoundedOn s r) (a : α) : WellFoundedOn (insert a s) r :=
  well_founded_on_insert.2 h
#align set.well_founded_on.insert Set.WellFoundedOn.insert

end WellFoundedOn

section LinearOrder

variable [LinearOrder α] {s : Set α}

protected theorem IsWf.is_pwo (hs : s.IsWf) : s.IsPwo :=
  by
  intro f hf
  lift f to ℕ → s using hf
  have hrange : (range f).Nonempty := range_nonempty _
  rcases hs.has_min (range f) (range_nonempty _) with ⟨_, ⟨m, rfl⟩, hm⟩
  simp only [forall_range_iff, not_lt] at hm
  exact ⟨m, m + 1, lt_add_one m, hm _⟩
#align set.is_wf.is_pwo Set.IsWf.is_pwo

/-- In a linear order, the predicates `set.is_wf` and `set.is_pwo` are equivalent. -/
theorem is_wf_iff_is_pwo : s.IsWf ↔ s.IsPwo :=
  ⟨IsWf.is_pwo, IsPwo.is_wf⟩
#align set.is_wf_iff_is_pwo Set.is_wf_iff_is_pwo

end LinearOrder

end Set

namespace Finset

variable {r : α → α → Prop}

@[simp]
protected theorem partially_well_ordered_on [IsRefl α r] (s : Finset α) :
    (s : Set α).PartiallyWellOrderedOn r :=
  s.finite_to_set.PartiallyWellOrderedOn
#align finset.partially_well_ordered_on Finset.partially_well_ordered_on

@[simp]
protected theorem is_pwo [Preorder α] (s : Finset α) : Set.IsPwo (↑s : Set α) :=
  s.PartiallyWellOrderedOn
#align finset.is_pwo Finset.is_pwo

@[simp]
protected theorem is_wf [Preorder α] (s : Finset α) : Set.IsWf (↑s : Set α) :=
  s.finite_to_set.IsWf
#align finset.is_wf Finset.is_wf

@[simp]
protected theorem well_founded_on [IsStrictOrder α r] (s : Finset α) :
    Set.WellFoundedOn (↑s : Set α) r :=
  letI := partialOrderOfSO r
  s.is_wf
#align finset.well_founded_on Finset.well_founded_on

theorem well_founded_on_sup [IsStrictOrder α r] (s : Finset ι) {f : ι → Set α} :
    (s.sup f).WellFoundedOn r ↔ ∀ i ∈ s, (f i).WellFoundedOn r :=
  (Finset.cons_induction_on s (by simp)) fun a s ha hs => by simp [-sup_set_eq_bUnion, hs]
#align finset.well_founded_on_sup Finset.well_founded_on_sup

theorem partially_well_ordered_on_sup (s : Finset ι) {f : ι → Set α} :
    (s.sup f).PartiallyWellOrderedOn r ↔ ∀ i ∈ s, (f i).PartiallyWellOrderedOn r :=
  (Finset.cons_induction_on s (by simp)) fun a s ha hs => by simp [-sup_set_eq_bUnion, hs]
#align finset.partially_well_ordered_on_sup Finset.partially_well_ordered_on_sup

theorem is_wf_sup [Preorder α] (s : Finset ι) {f : ι → Set α} :
    (s.sup f).IsWf ↔ ∀ i ∈ s, (f i).IsWf :=
  s.well_founded_on_sup
#align finset.is_wf_sup Finset.is_wf_sup

theorem is_pwo_sup [Preorder α] (s : Finset ι) {f : ι → Set α} :
    (s.sup f).IsPwo ↔ ∀ i ∈ s, (f i).IsPwo :=
  s.partially_well_ordered_on_sup
#align finset.is_pwo_sup Finset.is_pwo_sup

@[simp]
theorem well_founded_on_bUnion [IsStrictOrder α r] (s : Finset ι) {f : ι → Set α} :
    (⋃ i ∈ s, f i).WellFoundedOn r ↔ ∀ i ∈ s, (f i).WellFoundedOn r := by
  simpa only [Finset.sup_eq_supr] using s.well_founded_on_sup
#align finset.well_founded_on_bUnion Finset.well_founded_on_bUnion

@[simp]
theorem partially_well_ordered_on_bUnion (s : Finset ι) {f : ι → Set α} :
    (⋃ i ∈ s, f i).PartiallyWellOrderedOn r ↔ ∀ i ∈ s, (f i).PartiallyWellOrderedOn r := by
  simpa only [Finset.sup_eq_supr] using s.partially_well_ordered_on_sup
#align finset.partially_well_ordered_on_bUnion Finset.partially_well_ordered_on_bUnion

@[simp]
theorem is_wf_bUnion [Preorder α] (s : Finset ι) {f : ι → Set α} :
    (⋃ i ∈ s, f i).IsWf ↔ ∀ i ∈ s, (f i).IsWf :=
  s.well_founded_on_bUnion
#align finset.is_wf_bUnion Finset.is_wf_bUnion

@[simp]
theorem is_pwo_bUnion [Preorder α] (s : Finset ι) {f : ι → Set α} :
    (⋃ i ∈ s, f i).IsPwo ↔ ∀ i ∈ s, (f i).IsPwo :=
  s.partially_well_ordered_on_bUnion
#align finset.is_pwo_bUnion Finset.is_pwo_bUnion

end Finset

namespace Set

section Preorder

variable [Preorder α] {s : Set α} {a : α}

/-- `is_wf.min` returns a minimal element of a nonempty well-founded set. -/
noncomputable def IsWf.min (hs : IsWf s) (hn : s.Nonempty) : α :=
  hs.min univ (nonempty_iff_univ_nonempty.1 hn.to_subtype)
#align set.is_wf.min Set.IsWf.min

theorem IsWf.min_mem (hs : IsWf s) (hn : s.Nonempty) : hs.min hn ∈ s :=
  (WellFounded.min hs univ (nonempty_iff_univ_nonempty.1 hn.to_subtype)).2
#align set.is_wf.min_mem Set.IsWf.min_mem

theorem IsWf.not_lt_min (hs : IsWf s) (hn : s.Nonempty) (ha : a ∈ s) : ¬a < hs.min hn :=
  hs.not_lt_min univ (nonempty_iff_univ_nonempty.1 hn.to_subtype) (mem_univ (⟨a, ha⟩ : s))
#align set.is_wf.not_lt_min Set.IsWf.not_lt_min

@[simp]
theorem is_wf_min_singleton (a) {hs : IsWf ({a} : Set α)} {hn : ({a} : Set α).Nonempty} :
    hs.min hn = a :=
  eq_of_mem_singleton (IsWf.min_mem hs hn)
#align set.is_wf_min_singleton Set.is_wf_min_singleton

end Preorder

section LinearOrder

variable [LinearOrder α] {s t : Set α} {a : α}

theorem IsWf.min_le (hs : s.IsWf) (hn : s.Nonempty) (ha : a ∈ s) : hs.min hn ≤ a :=
  le_of_not_lt (hs.not_lt_min hn ha)
#align set.is_wf.min_le Set.IsWf.min_le

theorem IsWf.le_min_iff (hs : s.IsWf) (hn : s.Nonempty) : a ≤ hs.min hn ↔ ∀ b, b ∈ s → a ≤ b :=
  ⟨fun ha b hb => le_trans ha (hs.min_le hn hb), fun h => h _ (hs.min_mem _)⟩
#align set.is_wf.le_min_iff Set.IsWf.le_min_iff

theorem IsWf.min_le_min_of_subset {hs : s.IsWf} {hsn : s.Nonempty} {ht : t.IsWf} {htn : t.Nonempty}
    (hst : s ⊆ t) : ht.min htn ≤ hs.min hsn :=
  (IsWf.le_min_iff _ _).2 fun b hb => ht.min_le htn (hst hb)
#align set.is_wf.min_le_min_of_subset Set.IsWf.min_le_min_of_subset

theorem IsWf.min_union (hs : s.IsWf) (hsn : s.Nonempty) (ht : t.IsWf) (htn : t.Nonempty) :
    (hs.union ht).min (union_nonempty.2 (Or.intro_left _ hsn)) = min (hs.min hsn) (ht.min htn) :=
  by
  refine'
    le_antisymm
      (le_min (is_wf.min_le_min_of_subset (subset_union_left _ _))
        (is_wf.min_le_min_of_subset (subset_union_right _ _)))
      _
  rw [min_le_iff]
  exact
    ((mem_union _ _ _).1 ((hs.union ht).min_mem (union_nonempty.2 (Or.intro_left _ hsn)))).imp
      (hs.min_le _) (ht.min_le _)
#align set.is_wf.min_union Set.IsWf.min_union

end LinearOrder

end Set

open Set

namespace Set.PartiallyWellOrderedOn

variable {r : α → α → Prop}

/-- In the context of partial well-orderings, a bad sequence is a nonincreasing sequence
  whose range is contained in a particular set `s`. One exists if and only if `s` is not
  partially well-ordered. -/
def IsBadSeq (r : α → α → Prop) (s : Set α) (f : ℕ → α) : Prop :=
  (∀ n, f n ∈ s) ∧ ∀ m n : ℕ, m < n → ¬r (f m) (f n)
#align set.partially_well_ordered_on.is_bad_seq Set.PartiallyWellOrderedOn.IsBadSeq

theorem iff_forall_not_is_bad_seq (r : α → α → Prop) (s : Set α) :
    s.PartiallyWellOrderedOn r ↔ ∀ f, ¬IsBadSeq r s f :=
  forall_congr' fun f => by simp [is_bad_seq]
#align
  set.partially_well_ordered_on.iff_forall_not_is_bad_seq Set.PartiallyWellOrderedOn.iff_forall_not_is_bad_seq

/-- This indicates that every bad sequence `g` that agrees with `f` on the first `n`
  terms has `rk (f n) ≤ rk (g n)`. -/
def IsMinBadSeq (r : α → α → Prop) (rk : α → ℕ) (s : Set α) (n : ℕ) (f : ℕ → α) : Prop :=
  ∀ g : ℕ → α, (∀ m : ℕ, m < n → f m = g m) → rk (g n) < rk (f n) → ¬IsBadSeq r s g
#align set.partially_well_ordered_on.is_min_bad_seq Set.PartiallyWellOrderedOn.IsMinBadSeq

/-- Given a bad sequence `f`, this constructs a bad sequence that agrees with `f` on the first `n`
  terms and is minimal at `n`.
-/
noncomputable def minBadSeqOfBadSeq (r : α → α → Prop) (rk : α → ℕ) (s : Set α) (n : ℕ) (f : ℕ → α)
    (hf : IsBadSeq r s f) :
    { g : ℕ → α // (∀ m : ℕ, m < n → f m = g m) ∧ IsBadSeq r s g ∧ IsMinBadSeq r rk s n g } := by
  classical
    have h : ∃ (k : ℕ)(g : ℕ → α), (∀ m, m < n → f m = g m) ∧ is_bad_seq r s g ∧ rk (g n) = k :=
      ⟨_, f, fun _ _ => rfl, hf, rfl⟩
    obtain ⟨h1, h2, h3⟩ := Classical.choose_spec (Nat.find_spec h)
    refine' ⟨Classical.choose (Nat.find_spec h), h1, by convert h2, fun g hg1 hg2 con => _⟩
    refine' Nat.find_min h _ ⟨g, fun m mn => (h1 m mn).trans (hg1 m mn), by convert con, rfl⟩
    rwa [← h3]
#align
  set.partially_well_ordered_on.min_bad_seq_of_bad_seq Set.PartiallyWellOrderedOn.minBadSeqOfBadSeq

theorem exists_min_bad_of_exists_bad (r : α → α → Prop) (rk : α → ℕ) (s : Set α) :
    (∃ f, IsBadSeq r s f) → ∃ f, IsBadSeq r s f ∧ ∀ n, IsMinBadSeq r rk s n f :=
  by
  rintro ⟨f0, hf0 : is_bad_seq r s f0⟩
  let fs : ∀ n : ℕ, { f : ℕ → α // is_bad_seq r s f ∧ is_min_bad_seq r rk s n f } :=
    by
    refine' Nat.rec _ _
    ·
      exact
        ⟨(min_bad_seq_of_bad_seq r rk s 0 f0 hf0).1, (min_bad_seq_of_bad_seq r rk s 0 f0 hf0).2.2⟩
    ·
      exact fun n fn =>
        ⟨(min_bad_seq_of_bad_seq r rk s (n + 1) fn.1 fn.2.1).1,
          (min_bad_seq_of_bad_seq r rk s (n + 1) fn.1 fn.2.1).2.2⟩
  have h : ∀ m n, m ≤ n → (fs m).1 m = (fs n).1 m :=
    by
    intro m n mn
    obtain ⟨k, rfl⟩ := exists_add_of_le mn
    clear mn
    induction' k with k ih
    · rfl
    rw [ih,
      (min_bad_seq_of_bad_seq r rk s (m + k).succ (fs (m + k)).1 (fs (m + k)).2.1).2.1 m
        (Nat.lt_succ_iff.2 (Nat.add_le_add_left k.zero_le m))]
    rfl
  refine' ⟨fun n => (fs n).1 n, ⟨fun n => (fs n).2.1.1 n, fun m n mn => _⟩, fun n g hg1 hg2 => _⟩
  · dsimp
    rw [← Subtype.val_eq_coe, h m n (le_of_lt mn)]
    convert (fs n).2.1.2 m n mn
  · convert (fs n).2.2 g (fun m mn => Eq.trans _ (hg1 m mn)) (lt_of_lt_of_le hg2 le_rfl)
    rw [← h m n (le_of_lt mn)]
#align
  set.partially_well_ordered_on.exists_min_bad_of_exists_bad Set.PartiallyWellOrderedOn.exists_min_bad_of_exists_bad

theorem iff_not_exists_is_min_bad_seq (rk : α → ℕ) {s : Set α} :
    s.PartiallyWellOrderedOn r ↔ ¬∃ f, IsBadSeq r s f ∧ ∀ n, IsMinBadSeq r rk s n f :=
  by
  rw [iff_forall_not_is_bad_seq, ← not_exists, not_congr]
  constructor
  · apply exists_min_bad_of_exists_bad
  rintro ⟨f, hf1, hf2⟩
  exact ⟨f, hf1⟩
#align
  set.partially_well_ordered_on.iff_not_exists_is_min_bad_seq Set.PartiallyWellOrderedOn.iff_not_exists_is_min_bad_seq

/-- Higman's Lemma, which states that for any reflexive, transitive relation `r` which is
  partially well-ordered on a set `s`, the relation `list.sublist_forall₂ r` is partially
  well-ordered on the set of lists of elements of `s`. That relation is defined so that
  `list.sublist_forall₂ r l₁ l₂` whenever `l₁` related pointwise by `r` to a sublist of `l₂`.  -/
theorem partially_well_ordered_on_sublist_forall₂ (r : α → α → Prop) [IsRefl α r] [IsTrans α r]
    {s : Set α} (h : s.PartiallyWellOrderedOn r) :
    { l : List α | ∀ x, x ∈ l → x ∈ s }.PartiallyWellOrderedOn (List.SublistForall₂ r) :=
  by
  rcases s.eq_empty_or_nonempty with (rfl | ⟨as, has⟩)
  · apply partially_well_ordered_on.mono (Finset.partially_well_ordered_on {List.nil})
    · intro l hl
      rw [Finset.mem_coe, Finset.mem_singleton, List.eq_nil_iff_forall_not_mem]
      exact hl
    infer_instance
  haveI : Inhabited α := ⟨as⟩
  rw [iff_not_exists_is_min_bad_seq List.length]
  rintro ⟨f, hf1, hf2⟩
  have hnil : ∀ n, f n ≠ List.nil := fun n con =>
    hf1.2 n n.succ n.lt_succ_self (con.symm ▸ List.SublistForall₂.nil)
  obtain ⟨g, hg⟩ := h.exists_monotone_subseq (List.headI ∘ f) _
  swap;
  · simp only [Set.range_subset_iff, Function.comp_apply]
    exact fun n => hf1.1 n _ (List.head!_mem_self (hnil n))
  have hf' :=
    hf2 (g 0) (fun n => if n < g 0 then f n else List.tail (f (g (n - g 0))))
      (fun m hm => (if_pos hm).symm) _
  swap;
  · simp only [if_neg (lt_irrefl (g 0)), tsub_self]
    rw [List.length_tail, ← Nat.pred_eq_sub_one]
    exact Nat.pred_lt fun con => hnil _ (List.length_eq_zero.1 con)
  rw [is_bad_seq] at hf'
  push_neg  at hf'
  obtain ⟨m, n, mn, hmn⟩ := hf' _
  swap
  · rintro n x hx
    split_ifs  at hx with hn hn
    · exact hf1.1 _ _ hx
    · refine' hf1.1 _ _ (List.tail_subset _ hx)
  by_cases hn : n < g 0
  · apply hf1.2 m n mn
    rwa [if_pos hn, if_pos (mn.trans hn)] at hmn
  · obtain ⟨n', rfl⟩ := exists_add_of_le (not_lt.1 hn)
    rw [if_neg hn, add_comm (g 0) n', add_tsub_cancel_right] at hmn
    split_ifs  at hmn with hm hm
    · apply hf1.2 m (g n') (lt_of_lt_of_le hm (g.monotone n'.zero_le))
      exact trans hmn (List.tail_sublistForall₂_self _)
    · rw [← tsub_lt_iff_left (le_of_not_lt hm)] at mn
      apply hf1.2 _ _ (g.lt_iff_lt.2 mn)
      rw [← List.cons_head!_tail (hnil (g (m - g 0))), ← List.cons_head!_tail (hnil (g n'))]
      exact List.SublistForall₂.cons (hg _ _ (le_of_lt mn)) hmn
#align
  set.partially_well_ordered_on.partially_well_ordered_on_sublist_forall₂ Set.PartiallyWellOrderedOn.partially_well_ordered_on_sublist_forall₂

end Set.PartiallyWellOrderedOn

theorem WellFounded.is_wf [LT α] (h : WellFounded ((· < ·) : α → α → Prop)) (s : Set α) : s.IsWf :=
  (Set.is_wf_univ_iff.2 h).mono s.subset_univ
#align well_founded.is_wf WellFounded.is_wf

/-- A version of **Dickson's lemma** any subset of functions `Π s : σ, α s` is partially well
ordered, when `σ` is a `fintype` and each `α s` is a linear well order.
This includes the classical case of Dickson's lemma that `ℕ ^ n` is a well partial order.
Some generalizations would be possible based on this proof, to include cases where the target is
partially well ordered, and also to consider the case of `set.partially_well_ordered_on` instead of
`set.is_pwo`. -/
theorem Pi.is_pwo {α : ι → Type _} [∀ i, LinearOrder (α i)] [∀ i, IsWellOrder (α i) (· < ·)]
    [Finite ι] (s : Set (∀ i, α i)) : s.IsPwo :=
  by
  cases nonempty_fintype ι
  suffices
    ∀ s : Finset ι,
      ∀ f : ℕ → ∀ s, α s,
        ∃ g : ℕ ↪o ℕ, ∀ ⦃a b : ℕ⦄, a ≤ b → ∀ (x : ι) (hs : x ∈ s), (f ∘ g) a x ≤ (f ∘ g) b x
    by
    refine' is_pwo_iff_exists_monotone_subseq.2 fun f hf => _
    simpa only [Finset.mem_univ, true_imp_iff] using this Finset.univ f
  refine' Finset.cons_induction _ _
  · intro f
    exists RelEmbedding.refl (· ≤ ·)
    simp only [IsEmpty.forall_iff, imp_true_iff, forall_const, Finset.not_mem_empty]
  · intro x s hx ih f
    obtain ⟨g, hg⟩ :=
      (is_well_founded.wf.is_wf univ).IsPwo.exists_monotone_subseq (fun n => f n x) mem_univ
    obtain ⟨g', hg'⟩ := ih (f ∘ g)
    refine' ⟨g'.trans g, fun a b hab => (Finset.forall_mem_cons _ _).2 _⟩
    exact ⟨hg (OrderHomClass.mono g' hab), hg' hab⟩
#align pi.is_pwo Pi.is_pwo

