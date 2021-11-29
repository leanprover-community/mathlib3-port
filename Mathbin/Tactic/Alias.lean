import Leanbin.Data.Buffer.Parser 
import Mathbin.Tactic.Core

/-!
# The `alias` command

This file defines an `alias` command, which can be used to create copies
of a theorem or definition with different names.

Syntax:

```lean
/-- doc string -/
alias my_theorem ← alias1 alias2 ...
```

This produces defs or theorems of the form:

```lean
/-- doc string -/
@[alias] theorem alias1 : <type of my_theorem> := my_theorem

/-- doc string -/
@[alias] theorem alias2 : <type of my_theorem> := my_theorem
```

Iff alias syntax:

```lean
alias A_iff_B ↔ B_of_A A_of_B
alias A_iff_B ↔ ..
```

This gets an existing biconditional theorem `A_iff_B` and produces
the one-way implications `B_of_A` and `A_of_B` (with no change in
implicit arguments). A blank `_` can be used to avoid generating one direction.
The `..` notation attempts to generate the 'of'-names automatically when the
input theorem has the form `A_iff_B` or `A_iff_B_left` etc.
-/


open Lean.Parser Tactic Interactive Parser

namespace Tactic.Alias

@[user_attribute]
unsafe def alias_attr : user_attribute :=
  { Name := `alias, descr := "This definition is an alias of another.", Parser := failed }

unsafe def alias_direct (d : declaration) (doc : Stringₓ) (al : Name) : tactic Unit :=
  do 
    updateex_env$
        fun env =>
          env.add
            (match d.to_definition with 
            | declaration.defn n ls t _ _ _ =>
              declaration.defn al ls t (expr.const n (level.param <$> ls)) ReducibilityHints.abbrev tt
            | declaration.thm n ls t _ => declaration.thm al ls t$ task.pure$ expr.const n (level.param <$> ls)
            | _ => undefined)
    alias_attr al () tt 
    add_doc_string al doc

unsafe def mk_iff_mp_app (iffmp : Name) : expr → (ℕ → expr) → tactic expr
| expr.pi n bi e t, f => expr.lam n bi e <$> mk_iff_mp_app t fun n => f (n+1) (expr.var n)
| quote.1 ((%%ₓa) ↔ %%ₓb), f => pure$ @expr.const tt iffmp [] a b (f 0)
| _, f => fail "Target theorem must have the form `Π x y z, a ↔ b`"

unsafe def alias_iff (d : declaration) (doc : Stringₓ) (al : Name) (iffmp : Name) : tactic Unit :=
  (if al = `_ then skip else get_decl al >> skip) <|>
    do 
      let ls := d.univ_params 
      let t := d.type 
      let v ← mk_iff_mp_app iffmp t fun _ => expr.const d.to_name (level.param <$> ls)
      let t' ← infer_type v 
      updateex_env$ fun env => env.add (declaration.thm al ls t'$ task.pure v)
      alias_attr al () tt 
      add_doc_string al doc

unsafe def make_left_right : Name → tactic (Name × Name)
| Name.mk_string s p =>
  do 
    let buf : CharBuffer := s.to_char_buffer 
    let Sum.inr parts ← pure$ run (sep_by1 (ch '_') (many_char (sat (· ≠ '_')))) s.to_char_buffer 
    let (left, _ :: right) ← pure$ parts.span (· ≠ "iff")
    let pfx (a b : Stringₓ) := a.to_list.is_prefix_of b.to_list 
    let (suffix', right') ← pure$ right.reverse.span fun s => pfx "left" s ∨ pfx "right" s 
    let right := right'.reverse 
    let suffix := suffix'.reverse 
    pure
        (p <.> "_".intercalate (right ++ "of" :: left ++ suffix),
        p <.> "_".intercalate (left ++ "of" :: right ++ suffix))
| _ => failed

-- error in Tactic.Alias: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/--
The `alias` command can be used to create copies
of a theorem or definition with different names.

Syntax:

```lean
/-- doc string -/
alias my_theorem ← alias1 alias2 ...
```

This produces defs or theorems of the form:

```lean
/-- doc string -/
@[alias] theorem alias1 : <type of my_theorem> := my_theorem

/-- doc string -/
@[alias] theorem alias2 : <type of my_theorem> := my_theorem
```

Iff alias syntax:

```lean
alias A_iff_B ↔ B_of_A A_of_B
alias A_iff_B ↔ ..
```

This gets an existing biconditional theorem `A_iff_B` and produces
the one-way implications `B_of_A` and `A_of_B` (with no change in
implicit arguments). A blank `_` can be used to avoid generating one direction.
The `..` notation attempts to generate the 'of'-names automatically when the
input theorem has the form `A_iff_B` or `A_iff_B_left` etc.
-/
@[user_command]
meta
def alias_cmd (meta_info : decl_meta_info) (_ : «expr $ »(parse, tk "alias")) : lean.parser unit :=
do {
old ← ident,
  d ← «expr <|> »(do {
   old ← resolve_constant old,
     get_decl old }, fail «expr ++ »(«expr ++ »("declaration ", to_string old), " not found")),
  let doc := λ
  al : name, «expr $ »(meta_info.doc_string.get_or_else, «expr ++ »(«expr ++ »("**Alias** of `", to_string old), "`.")),
  «expr <|> »(do
   «expr <|> »(tk "←", tk "<-"),
     aliases ← many ident,
     «expr↑ »(«expr $ »(aliases.mmap', λ al, alias_direct d (doc al) al)), do
   «expr <|> »(tk "↔", tk "<->"),
     (left, right) ← mcond «expr <|> »(«expr >> »(«expr *> »(tk ".", tk "."), pure tt), pure ff) «expr <|> »(make_left_right old, fail "invalid name for automatic name generation") «expr <*> »(«expr <$> »(prod.mk, types.ident_), types.ident_),
     alias_iff d (doc left) left (`iff.mp),
     alias_iff d (doc right) right (`iff.mpr)) }

add_tactic_doc
  { Name := "alias", category := DocCategory.cmd, declNames := [`tactic.alias.alias_cmd], tags := ["renaming"] }

unsafe def get_lambda_body : expr → expr
| expr.lam _ _ _ b => get_lambda_body b
| a => a

unsafe def get_alias_target (n : Name) : tactic (Option Name) :=
  do 
    let tt ← has_attribute' `alias n | pure none 
    let d ← get_decl n 
    let (head, args) := (get_lambda_body d.value).get_app_fn_args 
    let head :=
      if head.is_constant_of `iff.mp ∨ head.is_constant_of `iff.mpr then expr.get_app_fn (head.ith_arg 2) else head 
    guardb$ head.is_constant 
    pure$ head.const_name

end Tactic.Alias

