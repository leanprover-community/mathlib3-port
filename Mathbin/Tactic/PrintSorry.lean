/-
Copyright (c) 2022 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn
-/
import Mathbin.Tactic.Core
import Mathbin.Data.Bool.Basic

/-!
# Print sorry

Adds a command `#print_sorry_in nm` that prints all occurrences of `sorry` in declarations used in
`nm`, including all intermediate declarations.

Other searches through the environment can be done using `tactic.find_all_exprs`
-/


namespace Tactic

/-- Auxilliary data type for `tactic.find_all_exprs` -/
unsafe structure find_all_expr_data where
  matching_subexpr : Bool
  -- this declaration contains a subexpression on which the test passes
  test_passed : Bool
  -- the search has found a matching subexpression somewhere
  -- name, contains subexpression directly, direct descendants
  descendants : List (Name × Bool × name_set)
  name_map : name_map Bool
  -- all data
  direct_descendants : name_set
#align tactic.find_all_expr_data tactic.find_all_expr_data

-- direct descendants of a declaration
/-- Auxilliary declaration for `tactic.find_all_exprs`.

Traverse all declarations occurring in the declaration with the given name,
excluding declarations `n` such that `g n` is true (and all their descendants),
recording the structure of which declaration depends on which,
and whether `f e` is true on any subexpression `e` of the declaration. -/
unsafe def find_all_exprs_aux (env : environment) (f : expr → Bool) (g : Name → Bool) :
    Name → find_all_expr_data → tactic find_all_expr_data
  | n, ⟨b₀, b₁, l, ns, desc⟩ =>
    match ns.find n with
    |-- Skip declarations that we have already handled.
        some
        b =>
      pure ⟨b₀, b || b₁, l, ns, if b then desc.insert n else desc⟩
    | none =>
      if g n then pure ⟨b₀, b₁, l, ns.insert n false, desc⟩
      else do
        let d ← env.get n
        let process (v : expr) : tactic find_all_expr_data :=
          (v.mfold ⟨false, false, l, ns, mk_name_set⟩) fun e _ p =>
            if f e then pure ⟨true, true, p.descendants, p.name_map, p.direct_descendants⟩
            else if e.is_constant then find_all_exprs_aux e.const_name p else pure p
        let ⟨b', b, l, ns, desc'⟩ ← process d.value
        pure ⟨b₀, b₁ || b, if b then (n, b', desc') :: l else l, ns n b, if b then desc n else desc⟩
#align tactic.find_all_exprs_aux tactic.find_all_exprs_aux

/-- `tactic.find_all_exprs env test exclude nm` searches for all declarations (transitively)
  occuring in `nm` that contain a subexpression `e` such that `test e` is true.
  All declarations `n` such that `exclude n` is true (and all their descendants) are ignored. -/
unsafe def find_all_exprs (env : environment) (test : expr → Bool) (exclude : Name → Bool) (nm : Name) :
    tactic <| List <| Name × Bool × name_set := do
  let ⟨_, _, l, _, _⟩ ← find_all_exprs_aux env test exclude nm ⟨false, false, [], mk_name_map, mk_name_set⟩
  pure l
#align tactic.find_all_exprs tactic.find_all_exprs

end Tactic

open Tactic

/-- Print all declarations that (transitively) occur in the value of declaration `nm` and depend on
`sorry`. If `ignore_mathlib` is set true, then all declarations in `mathlib` are
assumed to be `sorry`-free, which greatly reduces the search space. We could also exclude `core`,
but this doesn't speed up the search. -/
unsafe def print_sorry_in (nm : Name) (ignore_mathlib := true) : tactic Unit := do
  let env ← get_env
  let dir ← get_mathlib_dir
  let data ←
    find_all_exprs env (fun e => e.is_sorry.isSome)
        (if ignore_mathlib then env.is_prefix_of_file dir else fun _ => false) nm
  let to_print : List format :=
    data.map fun ⟨nm, contains_sorry, desc⟩ =>
      let s1 := if contains_sorry then " contains sorry" else ""
      let s2 := if contains_sorry && !desc.Empty then " and" else ""
      let s3 := String.join <| (desc.toList.map toString).intersperse ", "
      let s4 := if !desc.Empty then f! " depends on {s3}" else ""
      f! "{nm }{s1 }{s2 }{s4}."
  trace <| format.join <| to_print format.line
#align print_sorry_in print_sorry_in

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
/-- The command
```
#print_sorry_in nm
```
prints all declarations that (transitively) occur in the value of declaration `nm` and depend on
`sorry`. This command assumes that no `sorry` occurs in mathlib. To find `sorry` in mathlib, use
``#eval print_sorry_in `nm ff`` instead.
Example:
```
def foo1 : false := sorry
def foo2 : false ∧ false := ⟨sorry, foo1⟩
def foo3 : false := foo2.left
def foo4 : true := trivial
def foo5 : true ∧ false := ⟨foo4, foo3⟩
#print_sorry_in foo5
```
prints
```
foo5 depends on foo3.
foo3 depends on foo2.
foo2 contains sorry and depends on foo1.
foo1 contains sorry.
```
-/
@[user_command]
unsafe def print_sorry_in_cmd (_ : parse <| tk "#print_sorry_in") : parser Unit := do
  let nm ← ident
  let nm ← resolve_name nm
  print_sorry_in nm
#align print_sorry_in_cmd print_sorry_in_cmd

add_tactic_doc
  { Name := "print_sorry_in", category := DocCategory.cmd, declNames := [`print_sorry_in_cmd],
    tags := ["search", "environment", "debugging"] }

