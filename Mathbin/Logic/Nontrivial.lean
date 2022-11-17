/-
Copyright (c) 2020 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel
-/
import Mathbin.Data.Prod.Basic
import Mathbin.Data.Subtype
import Mathbin.Logic.Function.Basic
import Mathbin.Logic.Unique

/-!
# Nontrivial types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> https://github.com/leanprover-community/mathlib4/pull/547
> Any changes to this file require a corresponding PR to mathlib4.

A type is *nontrivial* if it contains at least two elements. This is useful in particular for rings
(where it is equivalent to the fact that zero is different from one) and for vector spaces
(where it is equivalent to the fact that the dimension is positive).

We introduce a typeclass `nontrivial` formalizing this property.
-/


variable {α : Type _} {β : Type _}

open Classical

#print Nontrivial /-
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (x y) -/
/-- Predicate typeclass for expressing that a type is not reduced to a single element. In rings,
this is equivalent to `0 ≠ 1`. In vector spaces, this is equivalent to positive dimension. -/
class Nontrivial (α : Type _) : Prop where
  exists_pair_ne : ∃ (x : α) (y : α), x ≠ y
#align nontrivial Nontrivial
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (x y) -/
#print nontrivial_iff /-
theorem nontrivial_iff : Nontrivial α ↔ ∃ (x : α) (y : α), x ≠ y :=
  ⟨fun h => h.exists_pair_ne, fun h => ⟨h⟩⟩
#align nontrivial_iff nontrivial_iff
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (x y) -/
#print exists_pair_ne /-
theorem exists_pair_ne (α : Type _) [Nontrivial α] : ∃ (x : α) (y : α), x ≠ y :=
  Nontrivial.exists_pair_ne
#align exists_pair_ne exists_pair_ne
-/

#print Decidable.exists_ne /-
-- See Note [decidable namespace]
protected theorem Decidable.exists_ne [Nontrivial α] [DecidableEq α] (x : α) : ∃ y, y ≠ x := by
  rcases exists_pair_ne α with ⟨y, y', h⟩
  by_cases hx:x = y
  · rw [← hx] at h
    exact ⟨y', h.symm⟩
    
  · exact ⟨y, Ne.symm hx⟩
    
#align decidable.exists_ne Decidable.exists_ne
-/

#print exists_ne /-
/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `exists_ne [])
      (Command.declSig
       [(Term.instBinder "[" [] (Term.app `Nontrivial [`α]) "]") (Term.explicitBinder "(" [`x] [":" `α] [] ")")]
       (Term.typeSpec
        ":"
        (Init.Logic.«term∃_,_»
         "∃"
         (Std.ExtendedBinder.extBinders (Std.ExtendedBinder.extBinder (Lean.binderIdent `y) []))
         ", "
         (Init.Logic.«term_≠_» `y " ≠ " `x))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.«tactic_<;>_»
            (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
            "<;>"
            (Tactic.exact "exact" (Term.app `Decidable.exists_ne [`x])))])))
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
         [(Tactic.«tactic_<;>_»
           (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
           "<;>"
           (Tactic.exact "exact" (Term.app `Decidable.exists_ne [`x])))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.«tactic_<;>_»
       (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
       "<;>"
       (Tactic.exact "exact" (Term.app `Decidable.exists_ne [`x])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact "exact" (Term.app `Decidable.exists_ne [`x]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Decidable.exists_ne [`x])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `x
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Decidable.exists_ne
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1, tactic))
      (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.skip', expected 'Lean.Parser.Tactic.tacticSeq'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem exists_ne [ Nontrivial α ] ( x : α ) : ∃ y , y ≠ x := by skip <;> exact Decidable.exists_ne x
#align exists_ne exists_ne
-/

#print nontrivial_of_ne /-
-- `x` and `y` are explicit here, as they are often needed to guide typechecking of `h`.
theorem nontrivial_of_ne (x y : α) (h : x ≠ y) : Nontrivial α :=
  ⟨⟨x, y, h⟩⟩
#align nontrivial_of_ne nontrivial_of_ne
-/

#print nontrivial_of_lt /-
-- `x` and `y` are explicit here, as they are often needed to guide typechecking of `h`.
theorem nontrivial_of_lt [Preorder α] (x y : α) (h : x < y) : Nontrivial α :=
  ⟨⟨x, y, ne_of_lt h⟩⟩
#align nontrivial_of_lt nontrivial_of_lt
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (x y) -/
#print exists_pair_lt /-
theorem exists_pair_lt (α : Type _) [Nontrivial α] [LinearOrder α] : ∃ (x : α) (y : α), x < y := by
  rcases exists_pair_ne α with ⟨x, y, hxy⟩
  cases lt_or_gt_of_ne hxy <;> exact ⟨_, _, h⟩
#align exists_pair_lt exists_pair_lt
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (x y) -/
#print nontrivial_iff_lt /-
theorem nontrivial_iff_lt [LinearOrder α] : Nontrivial α ↔ ∃ (x : α) (y : α), x < y :=
  ⟨fun h => @exists_pair_lt α h _, fun ⟨x, y, h⟩ => nontrivial_of_lt x y h⟩
#align nontrivial_iff_lt nontrivial_iff_lt
-/

#print nontrivial_iff_exists_ne /-
theorem nontrivial_iff_exists_ne (x : α) : Nontrivial α ↔ ∃ y, y ≠ x :=
  ⟨fun h => @exists_ne α h x, fun ⟨y, hy⟩ => nontrivial_of_ne _ _ hy⟩
#align nontrivial_iff_exists_ne nontrivial_iff_exists_ne
-/

#print Subtype.nontrivial_iff_exists_ne /-
theorem Subtype.nontrivial_iff_exists_ne (p : α → Prop) (x : Subtype p) :
    Nontrivial (Subtype p) ↔ ∃ (y : α) (hy : p y), y ≠ x := by
  simp only [nontrivial_iff_exists_ne x, Subtype.exists, Ne.def, Subtype.ext_iff, Subtype.coe_mk]
#align subtype.nontrivial_iff_exists_ne Subtype.nontrivial_iff_exists_ne
-/

instance : Nontrivial Prop :=
  ⟨⟨True, False, true_ne_false⟩⟩

#print Nontrivial.to_nonempty /-
/-- See Note [lower instance priority]

Note that since this and `nonempty_of_inhabited` are the most "obvious" way to find a nonempty
instance if no direct instance can be found, we give this a higher priority than the usual `100`.
-/
instance (priority := 500) Nontrivial.to_nonempty [Nontrivial α] : Nonempty α :=
  let ⟨x, _⟩ := exists_pair_ne α
  ⟨x⟩
#align nontrivial.to_nonempty Nontrivial.to_nonempty
-/

attribute [instance] nonempty_of_inhabited

/-- An inhabited type is either nontrivial, or has a unique element. -/
noncomputable def nontrivialPsumUnique (α : Type _) [Inhabited α] : PSum (Nontrivial α) (Unique α) :=
  if h : Nontrivial α then PSum.inl h
  else
    PSum.inr
      { default := default,
        uniq := fun x : α => by
          change x = default
          contrapose! h
          use x, default }
#align nontrivial_psum_unique nontrivialPsumUnique

#print subsingleton_iff /-
theorem subsingleton_iff : Subsingleton α ↔ ∀ x y : α, x = y :=
  ⟨by
    intro h
    exact Subsingleton.elim, fun h => ⟨h⟩⟩
#align subsingleton_iff subsingleton_iff
-/

#print not_nontrivial_iff_subsingleton /-
theorem not_nontrivial_iff_subsingleton : ¬Nontrivial α ↔ Subsingleton α := by
  rw [nontrivial_iff, subsingleton_iff]
  push_neg
  rfl
#align not_nontrivial_iff_subsingleton not_nontrivial_iff_subsingleton
-/

#print not_nontrivial /-
theorem not_nontrivial (α) [Subsingleton α] : ¬Nontrivial α := fun ⟨⟨x, y, h⟩⟩ => h $ Subsingleton.elim x y
#align not_nontrivial not_nontrivial
-/

#print not_subsingleton /-
theorem not_subsingleton (α) [h : Nontrivial α] : ¬Subsingleton α :=
  let ⟨⟨x, y, hxy⟩⟩ := h
  fun ⟨h'⟩ => hxy $ h' x y
#align not_subsingleton not_subsingleton
-/

#print subsingleton_or_nontrivial /-
/-- A type is either a subsingleton or nontrivial. -/
theorem subsingleton_or_nontrivial (α : Type _) : Subsingleton α ∨ Nontrivial α := by
  rw [← not_nontrivial_iff_subsingleton, or_comm']
  exact Classical.em _
#align subsingleton_or_nontrivial subsingleton_or_nontrivial
-/

#print false_of_nontrivial_of_subsingleton /-
theorem false_of_nontrivial_of_subsingleton (α : Type _) [Nontrivial α] [Subsingleton α] : False :=
  let ⟨x, y, h⟩ := exists_pair_ne α
  h $ Subsingleton.elim x y
#align false_of_nontrivial_of_subsingleton false_of_nontrivial_of_subsingleton
-/

#print Option.nontrivial /-
instance Option.nontrivial [Nonempty α] : Nontrivial (Option α) := by
  inhabit α
  use none, some default
#align option.nontrivial Option.nontrivial
-/

/- warning: function.injective.nontrivial -> Function.Injective.nontrivial is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} {β : Type.{u_2}} [_inst_1 : Nontrivial.{u_1} α] {f : α -> β}, (Function.Injective.{succ u_1 succ u_2} α β f) -> (Nontrivial.{u_2} β)
but is expected to have type
  forall {α : Type.{u_1}} {β : Type.{u_2}} [inst._@.Mathlib.Logic.Nontrivial._hyg.975 : Nontrivial.{u_1} α] {f : α -> β}, (Function.Injective.{succ u_1 succ u_2} α β f) -> (Nontrivial.{u_2} β)
Case conversion may be inaccurate. Consider using '#align function.injective.nontrivial Function.Injective.nontrivialₓ'. -/
/-- Pushforward a `nontrivial` instance along an injective function. -/
protected theorem Function.Injective.nontrivial [Nontrivial α] {f : α → β} (hf : Function.Injective f) : Nontrivial β :=
  let ⟨x, y, h⟩ := exists_pair_ne α
  ⟨⟨f x, f y, hf.Ne h⟩⟩
#align function.injective.nontrivial Function.Injective.nontrivial

#print Function.Surjective.nontrivial /-
/-- Pullback a `nontrivial` instance along a surjective function. -/
protected theorem Function.Surjective.nontrivial [Nontrivial β] {f : α → β} (hf : Function.Surjective f) :
    Nontrivial α := by
  rcases exists_pair_ne β with ⟨x, y, h⟩
  rcases hf x with ⟨x', hx'⟩
  rcases hf y with ⟨y', hy'⟩
  have : x' ≠ y' := by
    contrapose! h
    rw [← hx', ← hy', h]
  exact ⟨⟨x', y', this⟩⟩
#align function.surjective.nontrivial Function.Surjective.nontrivial
-/

/- warning: function.injective.exists_ne -> Function.Injective.exists_ne is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} {β : Type.{u_2}} [_inst_1 : Nontrivial.{u_1} α] {f : α -> β}, (Function.Injective.{succ u_1 succ u_2} α β f) -> (forall (y : β), Exists.{succ u_1} α (fun (x : α) => Ne.{succ u_2} β (f x) y))
but is expected to have type
  forall {α : Type.{u_1}} {β : Type.{u_2}} [inst._@.Mathlib.Logic.Nontrivial._hyg.1133 : Nontrivial.{u_1} α] {f : α -> β}, (Function.Injective.{succ u_1 succ u_2} α β f) -> (forall (y : β), Exists.{succ u_1} α (fun (x : α) => Ne.{succ u_2} β (f x) y))
Case conversion may be inaccurate. Consider using '#align function.injective.exists_ne Function.Injective.exists_neₓ'. -/
/-- An injective function from a nontrivial type has an argument at
which it does not take a given value. -/
protected theorem Function.Injective.exists_ne [Nontrivial α] {f : α → β} (hf : Function.Injective f) (y : β) :
    ∃ x, f x ≠ y := by
  rcases exists_pair_ne α with ⟨x₁, x₂, hx⟩
  by_cases h:f x₂ = y
  · exact ⟨x₁, (hf.ne_iff' h).2 hx⟩
    
  · exact ⟨x₂, h⟩
    
#align function.injective.exists_ne Function.Injective.exists_ne

#print nontrivial_prod_right /-
instance nontrivial_prod_right [Nonempty α] [Nontrivial β] : Nontrivial (α × β) :=
  Prod.snd_surjective.Nontrivial
#align nontrivial_prod_right nontrivial_prod_right
-/

#print nontrivial_prod_left /-
instance nontrivial_prod_left [Nontrivial α] [Nonempty β] : Nontrivial (α × β) :=
  Prod.fst_surjective.Nontrivial
#align nontrivial_prod_left nontrivial_prod_left
-/

namespace Pi

variable {I : Type _} {f : I → Type _}

#print Pi.nontrivial_at /-
/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers
      [(Command.docComment "/--" "A pi type is nontrivial if it's nonempty everywhere and nontrivial somewhere. -/")]
      []
      []
      []
      []
      [])
     (Command.theorem
      "theorem"
      (Command.declId `nontrivial_at [])
      (Command.declSig
       [(Term.explicitBinder "(" [`i'] [":" `I] [] ")")
        (Term.instBinder "[" [`inst ":"] (Term.forall "∀" [`i] [] "," (Term.app `Nonempty [(Term.app `f [`i])])) "]")
        (Term.instBinder "[" [] (Term.app `Nontrivial [(Term.app `f [`i'])]) "]")]
       (Term.typeSpec
        ":"
        (Term.app `Nontrivial [(Term.forall "∀" [`i] [(Term.typeSpec ":" `I)] "," (Term.app `f [`i]))])))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.«tactic_<;>_»
            (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
            "<;>"
            (Tactic.exact
             "exact"
             (Term.proj
              (Term.app
               `Function.update_injective
               [(Term.fun "fun" (Term.basicFun [`i] [] "=>" (Term.app `Classical.choice [(Term.app `inst [`i])]))) `i'])
              "."
              `Nontrivial)))])))
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
         [(Tactic.«tactic_<;>_»
           (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
           "<;>"
           (Tactic.exact
            "exact"
            (Term.proj
             (Term.app
              `Function.update_injective
              [(Term.fun "fun" (Term.basicFun [`i] [] "=>" (Term.app `Classical.choice [(Term.app `inst [`i])]))) `i'])
             "."
             `Nontrivial)))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.«tactic_<;>_»
       (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
       "<;>"
       (Tactic.exact
        "exact"
        (Term.proj
         (Term.app
          `Function.update_injective
          [(Term.fun "fun" (Term.basicFun [`i] [] "=>" (Term.app `Classical.choice [(Term.app `inst [`i])]))) `i'])
         "."
         `Nontrivial)))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact
       "exact"
       (Term.proj
        (Term.app
         `Function.update_injective
         [(Term.fun "fun" (Term.basicFun [`i] [] "=>" (Term.app `Classical.choice [(Term.app `inst [`i])]))) `i'])
        "."
        `Nontrivial))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.proj
       (Term.app
        `Function.update_injective
        [(Term.fun "fun" (Term.basicFun [`i] [] "=>" (Term.app `Classical.choice [(Term.app `inst [`i])]))) `i'])
       "."
       `Nontrivial)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app
       `Function.update_injective
       [(Term.fun "fun" (Term.basicFun [`i] [] "=>" (Term.app `Classical.choice [(Term.app `inst [`i])]))) `i'])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i'
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.fun "fun" (Term.basicFun [`i] [] "=>" (Term.app `Classical.choice [(Term.app `inst [`i])])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Classical.choice [(Term.app `inst [`i])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `inst [`i])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `inst
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `inst [`i]) ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Classical.choice
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (some 0, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.fun
      "fun"
      (Term.basicFun [`i] [] "=>" (Term.app `Classical.choice [(Term.paren "(" (Term.app `inst [`i]) ")")])))
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Function.update_injective
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app
      `Function.update_injective
      [(Term.paren
        "("
        (Term.fun
         "fun"
         (Term.basicFun [`i] [] "=>" (Term.app `Classical.choice [(Term.paren "(" (Term.app `inst [`i]) ")")])))
        ")")
       `i'])
     ")")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1, tactic))
      (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.skip', expected 'Lean.Parser.Tactic.tacticSeq'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
/-- A pi type is nontrivial if it's nonempty everywhere and nontrivial somewhere. -/
  theorem
    nontrivial_at
    ( i' : I ) [ inst : ∀ i , Nonempty f i ] [ Nontrivial f i' ] : Nontrivial ∀ i : I , f i
    := by skip <;> exact Function.update_injective fun i => Classical.choice inst i i' . Nontrivial
#align pi.nontrivial_at Pi.nontrivial_at
-/

#print Pi.nontrivial /-
/-- As a convenience, provide an instance automatically if `(f default)` is nontrivial.

If a different index has the non-trivial type, then use `haveI := nontrivial_at that_index`.
-/
instance nontrivial [Inhabited I] [inst : ∀ i, Nonempty (f i)] [Nontrivial (f default)] : Nontrivial (∀ i : I, f i) :=
  nontrivial_at default
#align pi.nontrivial Pi.nontrivial
-/

end Pi

#print Function.nontrivial /-
instance Function.nontrivial [h : Nonempty α] [Nontrivial β] : Nontrivial (α → β) :=
  h.elim $ fun a => Pi.nontrivial_at a
#align function.nontrivial Function.nontrivial
-/

/- failed to parenthesize: unknown constant 'Lean.Meta._root_.Lean.Parser.Command.registerSimpAttr'
[PrettyPrinter.parenthesize.input] (Lean.Meta._root_.Lean.Parser.Command.registerSimpAttr
     [(Command.docComment "/--" "Simp lemmas for `nontriviality` tactic -/")]
     "register_simp_attr"
     `nontriviality)-/-- failed to format: unknown constant 'Lean.Meta._root_.Lean.Parser.Command.registerSimpAttr'
/-- Simp lemmas for `nontriviality` tactic -/ register_simp_attr nontriviality

#print Subsingleton.le /-
protected theorem Subsingleton.le [Preorder α] [Subsingleton α] (x y : α) : x ≤ y :=
  le_of_eq (Subsingleton.elim x y)
#align subsingleton.le Subsingleton.le
-/

attribute [nontriviality] eq_iff_true_of_subsingleton Subsingleton.le

namespace Bool

instance : Nontrivial Bool :=
  ⟨⟨true, false, Bool.true_eq_false_eq_False⟩⟩

end Bool

