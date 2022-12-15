/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module tactic.rewrite
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Leanbin.Data.Dlist
import Mathbin.Tactic.Core

namespace Tactic

open Expr List

unsafe def match_fn (fn : expr) : expr → tactic (expr × expr)
  | app (app fn' e₀) e₁ => unify fn fn' $> (e₀, e₁)
  | _ => failed
#align tactic.match_fn tactic.match_fn

unsafe def fill_args : expr → tactic (expr × List expr)
  | pi n bi d b => do
    let v ← mk_meta_var d
    let (r, vs) ← fill_args (b.instantiate_var v)
    return (r, v :: vs)
  | e => return (e, [])
#align tactic.fill_args tactic.fill_args

unsafe def mk_assoc_pattern' (fn : expr) : expr → tactic (Dlist expr)
  | e =>
    (do
        let (e₀, e₁) ← match_fn fn e
        (· ++ ·) <$> mk_assoc_pattern' e₀ <*> mk_assoc_pattern' e₁) <|>
      pure (Dlist.singleton e)
#align tactic.mk_assoc_pattern' tactic.mk_assoc_pattern'

unsafe def mk_assoc_pattern (fn e : expr) : tactic (List expr) :=
  Dlist.toList <$> mk_assoc_pattern' fn e
#align tactic.mk_assoc_pattern tactic.mk_assoc_pattern

unsafe def mk_assoc (fn : expr) : List expr → tactic expr
  | [] => failed
  | [x] => pure x
  | x₀ :: x₁ :: xs => mk_assoc (fn x₀ x₁ :: xs)
#align tactic.mk_assoc tactic.mk_assoc

unsafe def chain_eq_trans : List expr → tactic expr
  | [] => to_expr ``(rfl)
  | [e] => pure e
  | e :: es => chain_eq_trans es >>= mk_eq_trans e
#align tactic.chain_eq_trans tactic.chain_eq_trans

unsafe def unify_prefix : List expr → List expr → tactic Unit
  | [], _ => pure ()
  | _, [] => failed
  | x :: xs, y :: ys => unify x y >> unify_prefix xs ys
#align tactic.unify_prefix tactic.unify_prefix

unsafe def match_assoc_pattern' (p : List expr) : List expr → tactic (List expr × List expr)
  | es =>
    unify_prefix p es $> ([], es.drop p.length) <|>
      match es with
      | [] => failed
      | x :: xs => Prod.map (cons x) id <$> match_assoc_pattern' xs
#align tactic.match_assoc_pattern' tactic.match_assoc_pattern'

unsafe def match_assoc_pattern (fn p e : expr) : tactic (List expr × List expr) := do
  let p' ← mk_assoc_pattern fn p
  let e' ← mk_assoc_pattern fn e
  match_assoc_pattern' p' e'
#align tactic.match_assoc_pattern tactic.match_assoc_pattern

/-- Tag for proofs generated by `assoc_rewrite`. -/
def IdTag.assocProof :=
  ()
#align tactic.id_tag.assoc_proof Tactic.IdTag.assocProof

unsafe def mk_eq_proof (fn : expr) (e₀ e₁ : List expr) (p : expr) : tactic (expr × expr × expr) :=
  do
  let (l, r) ← infer_type p >>= match_eq
  if e₀ ∧ e₁ then pure (l, r, p)
    else do
      let l' ← mk_assoc fn (e₀ ++ [l] ++ e₁)
      let r' ← mk_assoc fn (e₀ ++ [r] ++ e₁)
      let t ← infer_type l'
      let v ← mk_local_def `x t
      let e ← mk_assoc fn (e₀ ++ [v] ++ e₁)
      let p ← mk_congr_arg (e [v]) p
      let p' ← mk_app `` Eq [l', r']
      let p' := mk_tagged_proof p' p `` id_tag.assoc_proof
      return (l', r', p')
#align tactic.mk_eq_proof tactic.mk_eq_proof

unsafe def assoc_root (fn assoc : expr) : expr → tactic (expr × expr)
  | e =>
    (do
        let (e₀, e₁) ← match_fn fn e
        let (ea, eb) ← match_fn fn e₁
        let e' := fn (fn e₀ ea) eb
        let p' ← mk_eq_symm (assoc e₀ ea eb)
        let (e'', p'') ← assoc_root e'
        Prod.mk e'' <$> mk_eq_trans p' p'') <|>
      Prod.mk e <$> mk_eq_refl e
#align tactic.assoc_root tactic.assoc_root

unsafe def assoc_refl' (fn assoc : expr) : expr → expr → tactic expr
  | l, r =>
    is_def_eq l r >> mk_eq_refl l <|> do
      let (l', l_p) ← assoc_root fn assoc l <|> fail "A"
      let (el₀, el₁) ← match_fn fn l' <|> fail "B"
      let (r', r_p) ← assoc_root fn assoc r <|> fail "C"
      let (er₀, er₁) ← match_fn fn r' <|> fail "D"
      let p₀ ← assoc_refl' el₀ er₀
      let p₁ ← is_def_eq el₁ er₁ >> mk_eq_refl el₁
      let f_eq ← mk_congr_arg fn p₀ <|> fail "G"
      let p' ← mk_congr f_eq p₁ <|> fail "H"
      let r_p' ← mk_eq_symm r_p
      chain_eq_trans [l_p, p', r_p']
#align tactic.assoc_refl' tactic.assoc_refl'

unsafe def assoc_refl (fn : expr) : tactic Unit := do
  let (l, r) ← target >>= match_eq
  let assoc ← mk_mapp `` IsAssociative.assoc [none, fn, none] <|> fail f! "{fn} is not associative"
  assoc_refl' fn assoc l r >>= tactic.exact
#align tactic.assoc_refl tactic.assoc_refl

unsafe def flatten (fn assoc e : expr) : tactic (expr × expr) := do
  let ls ← mk_assoc_pattern fn e
  let e' ← mk_assoc fn ls
  let p ← assoc_refl' fn assoc e e'
  return (e', p)
#align tactic.flatten tactic.flatten

unsafe def assoc_rewrite_intl (assoc h e : expr) : tactic (expr × expr) := do
  let t ← infer_type h
  let (lhs, rhs) ← match_eq t
  let fn := lhs.app_fn.app_fn
  let (l, r) ← match_assoc_pattern fn lhs e
  let (lhs', rhs', h') ← mk_eq_proof fn l r h
  let e_p ← assoc_refl' fn assoc e lhs'
  let (rhs'', rhs_p) ← flatten fn assoc rhs'
  let final_p ← chain_eq_trans [e_p, h', rhs_p]
  return (rhs'', final_p)
#align tactic.assoc_rewrite_intl tactic.assoc_rewrite_intl

-- TODO(Simon): visit expressions built of `fn` nested inside other such expressions:
-- e.g.: x + f (a + b + c) + y should generate two rewrite candidates
unsafe def enum_assoc_subexpr' (fn : expr) : expr → tactic (Dlist expr)
  | e =>
    Dlist.singleton e <$ (match_fn fn e >> guard ¬e.has_var) <|>
      expr.mfoldl (fun es e' => (· ++ es) <$> enum_assoc_subexpr' e') Dlist.empty e
#align tactic.enum_assoc_subexpr' tactic.enum_assoc_subexpr'

unsafe def enum_assoc_subexpr (fn e : expr) : tactic (List expr) :=
  Dlist.toList <$> enum_assoc_subexpr' fn e
#align tactic.enum_assoc_subexpr tactic.enum_assoc_subexpr

unsafe def mk_assoc_instance (fn : expr) : tactic expr := do
  let t ← mk_mapp `` IsAssociative [none, fn]
  let inst ←
    Prod.snd <$> solve_aux t assumption <|>
        mk_instance t >>= assertv `_inst t <|> fail f! "{fn} is not associative"
  mk_mapp `` IsAssociative.assoc [none, fn, inst]
#align tactic.mk_assoc_instance tactic.mk_assoc_instance

unsafe def assoc_rewrite (h e : expr) (opt_assoc : Option expr := none) :
    tactic (expr × expr × List expr) := do
  let (t, vs) ← infer_type h >>= fill_args
  let (lhs, rhs) ← match_eq t
  let fn := lhs.app_fn.app_fn
  let es ← enum_assoc_subexpr fn e
  let assoc ←
    match opt_assoc with
      | none => mk_assoc_instance fn
      | some assoc => pure assoc
  let (_, p) ← firstM (assoc_rewrite_intl assoc <| h.mk_app vs) es
  let (e', p', _) ← tactic.rewrite p e
  pure (e', p', vs)
#align tactic.assoc_rewrite tactic.assoc_rewrite

unsafe def assoc_rewrite_target (h : expr) (opt_assoc : Option expr := none) : tactic Unit := do
  let tgt ← target
  let (tgt', p, _) ← assoc_rewrite h tgt opt_assoc
  replace_target tgt' p
#align tactic.assoc_rewrite_target tactic.assoc_rewrite_target

unsafe def assoc_rewrite_hyp (h hyp : expr) (opt_assoc : Option expr := none) : tactic expr := do
  let tgt ← infer_type hyp
  let (tgt', p, _) ← assoc_rewrite h tgt opt_assoc
  replace_hyp hyp tgt' p
#align tactic.assoc_rewrite_hyp tactic.assoc_rewrite_hyp

namespace Interactive

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `eq_lemmas -/
private unsafe def assoc_rw_goal (rs : List rw_rule) : tactic Unit :=
  rs.mmap' fun r => do
    save_info r
    let eq_lemmas ← get_rule_eqn_lemmas r
    orelse'
        (do
          let e ← to_expr' r
          assoc_rewrite_target e)
        (eq_lemmas fun n => do
          let e ← mk_const n
          assoc_rewrite_target e)
        (eq_lemmas eq_lemmas.empty)
#align tactic.interactive.assoc_rw_goal tactic.interactive.assoc_rw_goal

private unsafe def uses_hyp (e : expr) (h : expr) : Bool :=
  (e.fold false) fun t _ r => r || t = h
#align tactic.interactive.uses_hyp tactic.interactive.uses_hyp

/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `eq_lemmas -/
private unsafe def assoc_rw_hyp : List rw_rule → expr → tactic Unit
  | [], hyp => skip
  | r :: rs, hyp => do
    save_info r
    let eq_lemmas ← get_rule_eqn_lemmas r
    orelse'
        (do
          let e ← to_expr' r
          when ¬uses_hyp e hyp <| assoc_rewrite_hyp e hyp >>= assoc_rw_hyp rs)
        (eq_lemmas fun n => do
          let e ← mk_const n
          assoc_rewrite_hyp e hyp >>= assoc_rw_hyp rs)
        (eq_lemmas eq_lemmas.empty)
#align tactic.interactive.assoc_rw_hyp tactic.interactive.assoc_rw_hyp

private unsafe def assoc_rw_core (rs : parse rw_rules) (loca : parse location) : tactic Unit :=
  ((match loca with
      | loc.wildcard => loca.try_apply (assoc_rw_hyp rs.rules) (assoc_rw_goal rs.rules)
      | _ => loca.apply (assoc_rw_hyp rs.rules) (assoc_rw_goal rs.rules)) >>
      try reflexivity) >>
    try (returnopt rs.end_pos >>= save_info)
#align tactic.interactive.assoc_rw_core tactic.interactive.assoc_rw_core

/-- `assoc_rewrite [h₀,← h₁] at ⊢ h₂` behaves like `rewrite [h₀,← h₁] at ⊢ h₂`
with the exception that associativity is used implicitly to make rewriting
possible.

It works for any function `f` for which an `is_associative f` instance can be found.

```
example {α : Type*} (f : α → α → α) [is_associative α f] (a b c d x : α) :
  let infix ` ~ ` := f in
  b ~ c = x → (a ~ b ~ c ~ d) = (a ~ x ~ d) :=
begin
  intro h,
  assoc_rw h,
end
```
-/
unsafe def assoc_rewrite (q : parse rw_rules) (l : parse location) : tactic Unit :=
  propagate_tags (assoc_rw_core q l)
#align tactic.interactive.assoc_rewrite tactic.interactive.assoc_rewrite

/-- synonym for `assoc_rewrite` -/
unsafe def assoc_rw (q : parse rw_rules) (l : parse location) : tactic Unit :=
  assoc_rewrite q l
#align tactic.interactive.assoc_rw tactic.interactive.assoc_rw

add_tactic_doc
  { Name := "assoc_rewrite"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.assoc_rewrite, `tactic.interactive.assoc_rw]
    tags := ["rewriting"]
    inheritDescriptionFrom := `tactic.interactive.assoc_rewrite }

end Interactive

end Tactic

