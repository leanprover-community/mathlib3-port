/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Gabriel Ebner, Simon Hudon, Scott Morrison
-/
import Mathbin.Tactic.EquivRw

#align_import tactic.transport from "leanprover-community/mathlib"@"48fb5b5280e7c81672afc9524185ae994553ebf4"

/-!
## The `transport` tactic

`transport` attempts to move an `s : S α` expression across an equivalence `e : α ≃ β` to solve
a goal of the form `S β`, by building the new object field by field, taking each field of `s`
and rewriting it along `e` using the `equiv_rw` tactic.

We try to ensure good definitional properties, so that, for example, when we transport a `monoid α`
to a `monoid β`, the new multiplication is definitionally `λ x y, e (e.symm a * e.symm b)`.
-/


namespace Tactic

open Tactic.Interactive

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      Given `s : S α` for some structure `S` depending on a type `α`,
      and an equivalence `e : α ≃ β`,
      try to produce an `S β`,
      by transporting data and axioms across `e` using `equiv_rw`.
      -/
    @[ nolint unused_arguments ]
    unsafe
  def
    transport
    ( s e : expr ) : tactic Unit
    :=
      do
        let
            ( _ , α , β )
              ←
              infer_type e >>= relation_lhs_rhs
                <|>
                fail f! "second argument to `transport` was not an equivalence-type relation"
          seq'
            sorry
              (
                propagate_tags
                  (
                    try
                      do
                        let f ← get_current_field
                          mk_mapp f [ α , none ] >>= note f none
                          let b ← target >>= is_prop
                          if
                            ¬ b
                            then
                            simp_result do equiv_rw_hyp f e get_local f >>= exact
                            else
                            try
                              do
                                try unfold_projs_target
                                  sorry
                                  try
                                    <|
                                    under_binders
                                      <|
                                      to_expr ` `( $ ( e ) . symm . Injective ) >>= apply
                                  equiv_rw_hyp f e
                                  get_local f >>= exact
                    )
                )
#align tactic.transport tactic.transport

namespace Interactive

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
/-- Given a goal `⊢ S β` for some type class `S`, and an equivalence `e : α ≃ β`.
`transport using e` will look for a hypothesis `s : S α`,
and attempt to close the goal by transporting `s` across the equivalence `e`.

```lean
example {α : Type} [ring α] {β : Type} (e : α ≃ β) : ring β :=
by transport using e.
```

You can specify the object to transport using `transport s using e`.

`transport` works by attempting to copy each of the operations and axiom fields of `s`,
rewriting them using `equiv_rw e` and defining a new structure using these rewritten fields.

If it fails to fill in all the new fields, `transport` will produce new subgoals.
It's probably best to think about which missing `simp` lemmas would have allowed `transport`
to finish, rather than solving these goals by hand.
(This may require looking at the implementation of `tranport` to understand its algorithm;
there are several examples of "transport-by-hand" at the end of `test/equiv_rw.lean`,
which `transport` is an abstraction of.)
-/
unsafe def transport (s : parse texpr ?) (e : parse <| tk "using" *> texpr) : itactic := do
  let s ←
    match s with
      | some s => to_expr s
      | none =>
        (do
            let t ← target
            let n := t.get_app_fn.const_name
            let ctx ← local_context
            ctx fun e => do
                let t ← infer_type e
                guard (t = n)
                return e) <|>
          fail "`transport` could not find an appropriate source object. Try `transport s using e`."
  let e ← to_expr e
  tactic.transport s e
#align tactic.interactive.transport tactic.interactive.transport

add_tactic_doc
  { Name := "transport"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.transport]
    tags := ["rewriting", "equiv", "transport"] }

end Interactive

end Tactic

