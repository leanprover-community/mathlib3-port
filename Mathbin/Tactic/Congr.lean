/-
Copyright (c) 2020 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn

! This file was ported from Lean 3 source module tactic.congr
! leanprover-community/mathlib commit d101e93197bb5f6ea89bd7ba386b7f7dff1f3903
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Lint.Default
import Mathbin.Tactic.Ext

/-!
# Congruence and related tactics

This file contains the tactic `congr'`, which is an extension of `congr`, and various tactics
using `congr'` internally.

`congr'` has some advantages over `congr`:
* It turns `↔` to equalities, before trying another congr lemma
* You can write `congr' n` to give the maximal depth of recursive applications. This is useful if
  `congr` breaks down the goal to aggressively, and the resulting goals are false.
* You can write `congr' with ...` to do `congr', ext ...` in a single tactic.

Other tactics in this file:
* `rcongr`: repeatedly apply `congr'` and `ext.`
* `convert`: like `exact`, but produces an equality goal if the type doesn't match.
* `convert_to`: changes the goal, if you prove an equality between the old goal and the new goal.
* `ac_change`: like `convert_to`, but uses `ac_refl` to discharge the goals.
-/


open Tactic

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
namespace Tactic

/-- Apply the constant `iff_of_eq` to the goal. -/
unsafe def apply_iff_congr_core : tactic Unit :=
  applyc `` iff_of_eq
#align tactic.apply_iff_congr_core tactic.apply_iff_congr_core

/-- The main part of the body for the loop in `congr'`. This will try to replace a goal `f x = f y`
 with `x = y`. Also has support for `==` and `↔`. -/
unsafe def congr_core' : tactic Unit := do
  let tgt ← target
  apply_eq_congr_core tgt <|>
      apply_heq_congr_core <|> apply_iff_congr_core <|> fail "congr tactic failed"
#align tactic.congr_core' tactic.congr_core'

-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      The main function in `convert_to`. Changes the goal to `r` and a proof obligation that the goal
        is equal to `r`. -/
    unsafe
  def
    convert_to_core
    ( r : pexpr ) : tactic Unit
    := do let tgt ← target let h ← to_expr ` `( ( _ : $ ( tgt ) = $ ( r ) ) ) rewrite_target h swap
#align tactic.convert_to_core tactic.convert_to_core

/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/-- Attempts to prove the goal by proof irrelevance, but avoids unifying universe metavariables
to do so. -/
unsafe def by_proof_irrel : tactic Unit := do
  let tgt ← target
  let @expr.const tt n [level.zero] ← pure tgt.get_app_fn
  if n = `` Eq then sorry else if n = `` HEq then sorry else failed
#align tactic.by_proof_irrel tactic.by_proof_irrel

/-- Same as the `congr` tactic, but takes an optional argument which gives
the depth of recursive applications.
* This is useful when `congr` is too aggressive in breaking down the goal.
* For example, given `⊢ f (g (x + y)) = f (g (y + x))`, `congr'` produces the goals `⊢ x = y`
  and `⊢ y = x`, while `congr' 2` produces the intended `⊢ x + y = y + x`.
* If, at any point, a subgoal matches a hypothesis then the subgoal will be closed.
-/
unsafe def congr' : Option ℕ → tactic Unit
  | o =>
    focus1 <|
      assumption <|>
        reflexivity Transparency.none <|>
          by_proof_irrel <|>
            (guard (o ≠ some 0) >> congr_core') >> all_goals' (try (congr' (Nat.pred <$> o))) <|>
              reflexivity
#align tactic.congr' tactic.congr'

namespace Interactive

/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `parser.optional -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `parser.optional -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `parser.many -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `parser.optional -/
/-- Same as the `congr` tactic, but takes an optional argument which gives
the depth of recursive applications.
* This is useful when `congr` is too aggressive in breaking down the goal.
* For example, given `⊢ f (g (x + y)) = f (g (y + x))`, `congr'` produces the goals `⊢ x = y`
  and `⊢ y = x`, while `congr' 2` produces the intended `⊢ x + y = y + x`.
* If, at any point, a subgoal matches a hypothesis then the subgoal will be closed.
* You can use `congr' with p (: n)?` to call `ext p (: n)?` to all subgoals generated by `congr'`.
  For example, if the goal is `⊢ f '' s = g '' s` then `congr' with x` generates the goal
  `x : α ⊢ f x = g x`.
-/
unsafe def congr' (n : parse (parser.optional (with_desc "n" small_nat))) :
    parse
        (parser.optional
          (tk "with" *> Prod.mk <$> parser.many rintro_patt_parse_hi <*>
            parser.optional (tk ":" *> small_nat))) →
      tactic Unit
  | none => tactic.congr' n
  | some ⟨p, m⟩ => focus1 (tactic.congr' n >> all_goals' (tactic.ext p.join m $> ()))
#align tactic.interactive.congr' tactic.interactive.congr'

/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `parser.many -/
/-- Repeatedly and apply `congr'` and `ext`, using the given patterns as arguments for `ext`.

There are two ways this tactic stops:
* `congr'` fails (makes no progress), after having already applied `ext`.
* `congr'` canceled out the last usage of `ext`. In this case, the state is reverted to before
  the `congr'` was applied.

For example, when the goal is
```lean
⊢ (λ x, f x + 3) '' s = (λ x, g x + 3) '' s
```
then `rcongr x` produces the goal
```lean
x : α ⊢ f x = g x
```
This gives the same result as `congr', ext x, congr'`.

In contrast, `congr'` would produce
```lean
⊢ (λ x, f x + 3) = (λ x, g x + 3)
```
and `congr' with x` (or `congr', ext x`) would produce
```lean
x : α ⊢ f x + 3 = g x + 3
```
-/
unsafe def rcongr : parse (List.join <$> parser.many rintro_patt_parse_hi) → tactic Unit
  | ps => do
    let t ← target
    let qs ← try_core (tactic.ext ps none)
    let some () ←
      try_core
          (tactic.congr' none >>
            (done <|> do
              let s ← target
              guard <| ¬s == t)) |
      skip
    done <|> rcongr (qs ps)
#align tactic.interactive.rcongr tactic.interactive.rcongr

add_tactic_doc
  { Name := "congr'"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.congr', `tactic.interactive.congr, `tactic.interactive.rcongr]
    tags := ["congruence"]
    inheritDescriptionFrom := `tactic.interactive.congr' }

/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `parser.optional -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `parser.optional -/
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      The `exact e` and `refine e` tactics require a term `e` whose type is
      definitionally equal to the goal. `convert e` is similar to `refine e`,
      but the type of `e` is not required to exactly match the
      goal. Instead, new goals are created for differences between the type
      of `e` and the goal. For example, in the proof state
      
      ```lean
      n : ℕ,
      e : prime (2 * n + 1)
      ⊢ prime (n + n + 1)
      ```
      
      the tactic `convert e` will change the goal to
      
      ```lean
      ⊢ n + n = 2 * n
      ```
      
      In this example, the new goal can be solved using `ring`.
      
      The `convert` tactic applies congruence lemmas eagerly before reducing,
      therefore it can fail in cases where `exact` succeeds:
      ```lean
      def p (n : ℕ) := true
      example (h : p 0) : p 1 := by exact h -- succeeds
      example (h : p 0) : p 1 := by convert h -- fails, with leftover goal `1 = 0`
      ```
      
      If `x y : t`, and an instance `subsingleton t` is in scope, then any goals of the form
      `x = y` are solved automatically.
      
      The syntax `convert ← e` will reverse the direction of the new goals
      (producing `⊢ 2 * n = n + n` in this example).
      
      Internally, `convert e` works by creating a new goal asserting that
      the goal equals the type of `e`, then simplifying it using
      `congr'`. The syntax `convert e using n` can be used to control the
      depth of matching (like `congr' n`). In the example, `convert e using
      1` would produce a new goal `⊢ n + n + 1 = 2 * n + 1`.
      -/
    unsafe
  def
    convert
    ( sym : parse ( with_desc "←" ( parser.optional ( tk "<-" ) ) ) )
        ( r : parse texpr )
        ( n : parse ( parser.optional ( tk "using" *> small_nat ) ) )
      : tactic Unit
    :=
      do
        let tgt ← target
          let u ← infer_type tgt
          let r ← i_to_expr ` `( ( $ ( r ) : ( _ : $ ( u ) ) ) )
          let src ← infer_type r
          let src ← simp_lemmas.mk . dsimplify [ ] src { failIfUnchanged := false }
          let
            v
              ←
              to_expr
                  (
                      if
                        Sym . isSome
                        then
                        ` `( $ ( src ) = $ ( tgt ) )
                        else
                        ` `( $ ( tgt ) = $ ( src ) )
                      )
                    true
                    false
                >>=
                mk_meta_var
          ( if Sym then mk_eq_mp v r else mk_eq_mpr v r ) >>= tactic.exact
          let gs ← get_goals
          set_goals [ v ]
          try ( tactic.congr' n )
          let gs' ← get_goals
          set_goals <| gs' ++ gs
#align tactic.interactive.convert tactic.interactive.convert

add_tactic_doc
  { Name := "convert"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.convert]
    tags := ["congruence"] }

/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `parser.optional -/
/-- `convert_to g using n` attempts to change the current goal to `g`, but unlike `change`,
it will generate equality proof obligations using `congr' n` to resolve discrepancies.
`convert_to g` defaults to using `congr' 1`.

`convert_to` is similar to `convert`, but `convert_to` takes a type (the desired subgoal) while
`convert` takes a proof term.
That is, `convert_to g using n` is equivalent to `convert (_ : g) using n`.
-/
unsafe def convert_to (r : parse texpr) (n : parse (parser.optional (tk "using" *> small_nat))) :
    tactic Unit :=
  match n with
  | none => convert_to_core r >> sorry
  | some 0 => convert_to_core r
  | some o => convert_to_core r >> tactic.congr' o
#align tactic.interactive.convert_to tactic.interactive.convert_to

/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `parser.optional -/
/-- `ac_change g using n` is `convert_to g using n` followed by `ac_refl`. It is useful for
rearranging/reassociating e.g. sums:
```lean
example (a b c d e f g N : ℕ) : (a + b) + (c + d) + (e + f) + g ≤ N :=
begin
  ac_change a + d + e + f + c + g + b ≤ _,
-- ⊢ a + d + e + f + c + g + b ≤ N
end
```

##  Related tactic: `move_add`
In the case in which the expression to be changed is a sum of terms, tactic
`tactive.interactive.move_add` can also be useful. -/
unsafe def ac_change (r : parse texpr) (n : parse (parser.optional (tk "using" *> small_nat))) :
    tactic Unit :=
  andthen (convert_to r n) (try ac_refl)
#align tactic.interactive.ac_change tactic.interactive.ac_change

add_tactic_doc
  { Name := "convert_to"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.convert_to, `tactic.interactive.ac_change]
    tags := ["congruence"]
    inheritDescriptionFrom := `tactic.interactive.convert_to }

end Interactive

end Tactic

