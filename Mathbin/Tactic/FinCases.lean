import Mathbin.Data.Fintype.Basic 
import Mathbin.Tactic.NormNum

/-!
# Case bash

This file provides the tactic `fin_cases`. `fin_cases x` performs case analysis on `x`, that is
creates one goal for each possible value of `x`, where either:
* `x : α`, where `[fintype α]`
* `x ∈ A`, where `A : finset α`, `A : multiset α` or `A : list α`.
-/


namespace Tactic

open Expr

open Conv.Interactive

/-- Checks that the expression looks like `x ∈ A` for `A : finset α`, `multiset α` or `A : list α`,
    and returns the type α. -/
unsafe def guard_mem_fin (e : expr) : tactic expr :=
  do 
    let t ← infer_type e 
    let α ← mk_mvar 
    to_expr (pquote.1 (_ ∈ (_ : Finset (%%ₓα)))) tt ff >>= unify t <|>
        to_expr (pquote.1 (_ ∈ (_ : Multiset (%%ₓα)))) tt ff >>= unify t <|>
          to_expr (pquote.1 (_ ∈ (_ : List (%%ₓα)))) tt ff >>= unify t 
    instantiate_mvars α

/--
`expr_list_to_list_expr` converts an `expr` of type `list α`
to a list of `expr`s each with type `α`.

TODO: this should be moved, and possibly duplicates an existing definition.
-/
unsafe def expr_list_to_list_expr : ∀ (e : expr), tactic (List expr)
| quote.1 (List.cons (%%ₓh) (%%ₓt)) => List.cons h <$> expr_list_to_list_expr t
| quote.1 [] => return []
| _ => failed

private unsafe def fin_cases_at_aux : ∀ (with_list : List expr) (e : expr), tactic Unit
| with_list, e =>
  do 
    let result ← cases_core e 
    match result with 
      | [(_, [s], _), (_, [e], _)] =>
        do 
          let sn := local_pp_name s 
          let ng ← num_goals 
          match with_list.nth 0 with 
            | some h => tactic.interactive.conv (some sn) none (to_rhs >> conv.interactive.change (to_pexpr h))
            | _ =>
              try$
                tactic.interactive.conv (some sn) none$
                  to_rhs >>
                    conv.interactive.norm_num
                      [simp_arg_type.expr (pquote.1 max_def), simp_arg_type.expr (pquote.1 min_def)]
          let s ← get_local sn 
          try sorry 
          let ng' ← num_goals 
          when (ng = ng') (rotate_left 1)
          fin_cases_at_aux with_list.tail e
      | [] => skip
      | _ => failed

/--
`fin_cases_at with_list e` performs case analysis on `e : α`, where `α` is a fintype.
The optional list of expressions `with_list` provides descriptions for the cases of `e`,
for example, to display nats as `n.succ` instead of `n+1`.
These should be defeq to and in the same order as the terms in the enumeration of `α`.
-/
unsafe def fin_cases_at : ∀ (with_list : Option pexpr) (e : expr), tactic Unit
| with_list, e =>
  do 
    let ty ← try_core$ guard_mem_fin e 
    match ty with 
      | none =>
        do 
          let ty ← infer_type e 
          let i ← to_expr (pquote.1 (Fintype (%%ₓty))) >>= mk_instance <|> fail "Failed to find `fintype` instance."
          let t ← to_expr (pquote.1 ((%%ₓe) ∈ @Fintype.elems (%%ₓty) (%%ₓi)))
          let v ← to_expr (pquote.1 (@Fintype.complete (%%ₓty) (%%ₓi) (%%ₓe)))
          let h ← assertv `h t v 
          fin_cases_at with_list h
      | some ty =>
        do 
          let with_list ←
            match with_list with 
              | some e =>
                do 
                  let e ← to_expr (pquote.1 (%%ₓe : List (%%ₓty)))
                  expr_list_to_list_expr e
              | none => return []
          fin_cases_at_aux with_list e

namespace Interactive

setup_tactic_parser

private unsafe def hyp :=
  tk "*" *> return none <|> some <$> ident

/--
`fin_cases h` performs case analysis on a hypothesis of the form
`h : A`, where `[fintype A]` is available, or
`h ∈ A`, where `A : finset X`, `A : multiset X` or `A : list X`.

`fin_cases *` performs case analysis on all suitable hypotheses.

As an example, in
```
example (f : ℕ → Prop) (p : fin 3) (h0 : f 0) (h1 : f 1) (h2 : f 2) : f p.val :=
begin
  fin_cases *; simp,
  all_goals { assumption }
end
```
after `fin_cases p; simp`, there are three goals, `f 0`, `f 1`, and `f 2`.
-/
unsafe def fin_cases : parse hyp → parse (tk "with" *> texpr)? → tactic Unit
| none, none =>
  focus1$
    do 
      let ctx ← local_context 
      ctx.mfirst (fin_cases_at none) <|>
          fail
            ("No hypothesis of the forms `x ∈ A`, where " ++
              "`A : finset X`, `A : list X`, or `A : multiset X`, or `x : A`, with `[fintype A]`.")
| none, some _ => fail "Specify a single hypothesis when using a `with` argument."
| some n, with_list =>
  do 
    let h ← get_local n 
    focus1$ fin_cases_at with_list h

end Interactive

add_tactic_doc
  { Name := "fin_cases", category := DocCategory.tactic, declNames := [`tactic.interactive.fin_cases],
    tags := ["case bashing"] }

end Tactic

