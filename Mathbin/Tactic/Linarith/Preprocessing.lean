import Mathbin.Tactic.Linarith.Datatypes 
import Mathbin.Tactic.Zify 
import Mathbin.Tactic.CancelDenoms 
import Mathbin.Order.Lexicographic

/-!
# Linarith preprocessing

This file contains methods used to preprocess inputs to `linarith`.

In particular, `linarith` works over comparisons of the form `t R 0`, where `R ∈ {<,≤,=}`.
It assumes that expressions in `t` have integer coefficients and that the type of `t` has
well-behaved subtraction.

## Implementation details

A `global_preprocessor` is a function `list expr → tactic(list expr)`. Users can add custom
preprocessing steps by adding them to the `linarith_config` object. `linarith.default_preprocessors`
is the main list, and generally none of these should be skipped unless you know what you're doing.
-/


open Native Tactic Expr

namespace Linarith

/-! ### Preprocessing -/


open Tactic

set_option eqn_compiler.max_steps 50000

/--
If `prf` is a proof of `¬ e`, where `e` is a comparison,
`rem_neg prf e` flips the comparison in `e` and returns a proof.
For example, if `prf : ¬ a < b`, ``rem_neg prf `(a < b)`` returns a proof of `a ≥ b`.
-/
unsafe def rem_neg (prf : expr) : expr → tactic expr
| quote.1 (_ ≤ _) => mk_app `` lt_of_not_geₓ [prf]
| quote.1 (_ < _) => mk_app `` le_of_not_gtₓ [prf]
| quote.1 (_ > _) => mk_app `` le_of_not_gtₓ [prf]
| quote.1 (_ ≥ _) => mk_app `` lt_of_not_geₓ [prf]
| e => failed

private unsafe def rearr_comp_aux : expr → expr → tactic expr
| prf, quote.1 ((%%ₓa) ≤ 0) => return prf
| prf, quote.1 ((%%ₓa) < 0) => return prf
| prf, quote.1 ((%%ₓa) = 0) => return prf
| prf, quote.1 ((%%ₓa) ≥ 0) => mk_app `` neg_nonpos_of_nonneg [prf]
| prf, quote.1 ((%%ₓa) > 0) => mk_app `neg_neg_of_pos [prf]
| prf, quote.1 (0 ≥ %%ₓa) => to_expr (pquote.1 (idRhs ((%%ₓa) ≤ 0) (%%ₓprf)))
| prf, quote.1 (0 > %%ₓa) => to_expr (pquote.1 (idRhs ((%%ₓa) < 0) (%%ₓprf)))
| prf, quote.1 (0 = %%ₓa) => mk_app `eq.symm [prf]
| prf, quote.1 (0 ≤ %%ₓa) => mk_app `` neg_nonpos_of_nonneg [prf]
| prf, quote.1 (0 < %%ₓa) => mk_app `neg_neg_of_pos [prf]
| prf, quote.1 ((%%ₓa) ≤ %%ₓb) => mk_app `` sub_nonpos_of_le [prf]
| prf, quote.1 ((%%ₓa) < %%ₓb) => mk_app `sub_neg_of_lt [prf]
| prf, quote.1 ((%%ₓa) = %%ₓb) => mk_app `sub_eq_zero_of_eq [prf]
| prf, quote.1 ((%%ₓa) > %%ₓb) => mk_app `sub_neg_of_lt [prf]
| prf, quote.1 ((%%ₓa) ≥ %%ₓb) => mk_app `` sub_nonpos_of_le [prf]
| prf, quote.1 ¬%%ₓt =>
  do 
    let nprf ← rem_neg prf t 
    let tp ← infer_type nprf 
    rearr_comp_aux nprf tp
| prf, a => trace a >> fail "couldn't rearrange comp"

/--
`rearr_comp e` takes a proof `e` of an equality, inequality, or negation thereof,
and turns it into a proof of a comparison `_ R 0`, where `R ∈ {=, ≤, <}`.
 -/
unsafe def rearr_comp (e : expr) : tactic expr :=
  infer_type e >>= rearr_comp_aux e

/-- If `e` is of the form `((n : ℕ) : ℤ)`, `is_nat_int_coe e` returns `n : ℕ`. -/
unsafe def is_nat_int_coe : expr → Option expr
| quote.1 (@coeₓ ℕ ℤ (%%ₓ_) (%%ₓn)) => some n
| _ => none

/-- If `e : ℕ`, returns a proof of `0 ≤ (e : ℤ)`. -/
unsafe def mk_coe_nat_nonneg_prf (e : expr) : tactic expr :=
  mk_app `int.coe_nat_nonneg [e]

/-- `get_nat_comps e` returns a list of all subexpressions of `e` of the form `((t : ℕ) : ℤ)`. -/
unsafe def get_nat_comps : expr → List expr
| quote.1 ((%%ₓa)+%%ₓb) => (get_nat_comps a).append (get_nat_comps b)
| quote.1 ((%%ₓa)*%%ₓb) => (get_nat_comps a).append (get_nat_comps b)
| e =>
  match is_nat_int_coe e with 
  | some e' => [e']
  | none => []

/--
If `pf` is a proof of a strict inequality `(a : ℤ) < b`,
`mk_non_strict_int_pf_of_strict_int_pf pf` returns a proof of `a + 1 ≤ b`,
and similarly if `pf` proves a negated weak inequality.
-/
unsafe def mk_non_strict_int_pf_of_strict_int_pf (pf : expr) : tactic expr :=
  do 
    let tp ← infer_type pf 
    match tp with 
      | quote.1 ((%%ₓa) < %%ₓb) => to_expr (pquote.1 (Int.add_one_le_iff.mpr (%%ₓpf)))
      | quote.1 ((%%ₓa) > %%ₓb) => to_expr (pquote.1 (Int.add_one_le_iff.mpr (%%ₓpf)))
      | quote.1 ¬(%%ₓa) ≤ %%ₓb => to_expr (pquote.1 (Int.add_one_le_iff.mpr (le_of_not_gtₓ (%%ₓpf))))
      | quote.1 ¬(%%ₓa) ≥ %%ₓb => to_expr (pquote.1 (Int.add_one_le_iff.mpr (le_of_not_gtₓ (%%ₓpf))))
      | _ => fail "mk_non_strict_int_pf_of_strict_int_pf failed: proof is not an inequality"

/--
`is_nat_prop tp` is true iff `tp` is an inequality or equality between natural numbers
or the negation thereof.
-/
unsafe def is_nat_prop : expr → Bool
| quote.1 (@Eq ℕ (%%ₓ_) _) => tt
| quote.1 (@LE.le ℕ (%%ₓ_) _ _) => tt
| quote.1 (@LT.lt ℕ (%%ₓ_) _ _) => tt
| quote.1 (@Ge ℕ (%%ₓ_) _ _) => tt
| quote.1 (@Gt ℕ (%%ₓ_) _ _) => tt
| quote.1 ¬%%ₓp => is_nat_prop p
| _ => ff

/--
`is_strict_int_prop tp` is true iff `tp` is a strict inequality between integers
or the negation of a weak inequality between integers.
-/
unsafe def is_strict_int_prop : expr → Bool
| quote.1 (@LT.lt ℤ (%%ₓ_) _ _) => tt
| quote.1 (@Gt ℤ (%%ₓ_) _ _) => tt
| quote.1 ¬@LE.le ℤ (%%ₓ_) _ _ => tt
| quote.1 ¬@Ge ℤ (%%ₓ_) _ _ => tt
| _ => ff

private unsafe def filter_comparisons_aux : expr → Bool
| quote.1 ¬%%ₓp => p.app_symbol_in [`has_lt.lt, `has_le.le, `gt, `ge]
| tp => tp.app_symbol_in [`has_lt.lt, `has_le.le, `gt, `ge, `eq]

/--
Removes any expressions that are not proofs of inequalities, equalities, or negations thereof.
-/
unsafe def filter_comparisons : preprocessor :=
  { Name := "filter terms that are not proofs of comparisons",
    transform :=
      fun h =>
        (do 
            let tp ← infer_type h 
            is_prop tp >>= guardb 
            guardb (filter_comparisons_aux tp)
            return [h]) <|>
          return [] }

/--
Replaces proofs of negations of comparisons with proofs of the reversed comparisons.
For example, a proof of `¬ a < b` will become a proof of `a ≥ b`.
-/
unsafe def remove_negations : preprocessor :=
  { Name := "replace negations of comparisons",
    transform :=
      fun h =>
        do 
          let tp ← infer_type h 
          match tp with 
            | quote.1 ¬%%ₓp => singleton <$> rem_neg h p
            | _ => return [h] }

-- error in Tactic.Linarith.Preprocessing: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/--
If `h` is an equality or inequality between natural numbers,
`nat_to_int` lifts this inequality to the integers.
It also adds the facts that the integers involved are nonnegative.
To avoid adding the same nonnegativity facts many times, it is a global preprocessor.
 -/ meta def nat_to_int : global_preprocessor :=
{ name := "move nats to ints",
  transform := λ l, do {
  l ← «expr $ »(lock_tactic_state, «expr $ »(l.mmap, λ
      h, «expr <|> »(«expr >> »(«expr >>= »(infer_type h, «expr ∘ »(guardb, is_nat_prop)), zify_proof «expr[ , ]»([]) h), return h))),
    nonnegs ← l.mfoldl (λ (es : expr_set) (h), do {
     (a, b) ← «expr >>= »(infer_type h, get_rel_sides),
       «expr $ »(return, (es.insert_list (get_nat_comps a)).insert_list (get_nat_comps b)) }) mk_rb_set,
    «expr <$> »(((«expr ++ »)) l, nonnegs.to_list.mmap mk_coe_nat_nonneg_prf) } }

/-- `strengthen_strict_int h` turns a proof `h` of a strict integer inequality `t1 < t2`
into a proof of `t1 ≤ t2 + 1`. -/
unsafe def strengthen_strict_int : preprocessor :=
  { Name := "strengthen strict inequalities over int",
    transform :=
      fun h =>
        do 
          let tp ← infer_type h 
          guardb (is_strict_int_prop tp) >> singleton <$> mk_non_strict_int_pf_of_strict_int_pf h <|> return [h] }

/--
`mk_comp_with_zero h` takes a proof `h` of an equality, inequality, or negation thereof,
and turns it into a proof of a comparison `_ R 0`, where `R ∈ {=, ≤, <}`.
 -/
unsafe def make_comp_with_zero : preprocessor :=
  { Name := "make comparisons with zero", transform := fun e => singleton <$> rearr_comp e <|> return [] }

/--
`normalize_denominators_in_lhs h lhs` assumes that `h` is a proof of `lhs R 0`.
It creates a proof of `lhs' R 0`, where all numeric division in `lhs` has been cancelled.
-/
unsafe def normalize_denominators_in_lhs (h lhs : expr) : tactic expr :=
  do 
    let (v, lhs') ← cancel_factors.derive lhs 
    if v = 1 then return h else
        do 
          let (ih, h'') ← mk_single_comp_zero_pf v h 
          let (_, nep, _) ← infer_type h'' >>= rewrite_core lhs' 
          mk_eq_mp nep h''

/--
`cancel_denoms pf` assumes `pf` is a proof of `t R 0`. If `t` contains the division symbol `/`,
it tries to scale `t` to cancel out division by numerals.
-/
unsafe def cancel_denoms : preprocessor :=
  { Name := "cancel denominators",
    transform :=
      fun pf =>
        (do 
            let some (_, lhs) ← parse_into_comp_and_expr <$> infer_type pf 
            guardb$ lhs.contains_constant (· = `has_div.div)
            singleton <$> normalize_denominators_in_lhs pf lhs) <|>
          return [pf] }

/--
`find_squares m e` collects all terms of the form `a ^ 2` and `a * a` that appear in `e`
and adds them to the set `m`.
A pair `(a, tt)` is added to `m` when `a^2` appears in `e`, and `(a, ff)` is added to `m`
when `a*a` appears in `e`.  -/
unsafe def find_squares : rb_set (expr × Bool) → expr → tactic (rb_set (Lex expr Bool))
| s, quote.1 ((%%ₓa) ^ 2) =>
  do 
    let s ← find_squares s a 
    return (s.insert (a, tt))
| s, e@(quote.1 ((%%ₓe1)*%%ₓe2)) =>
  if e1 = e2 then
    do 
      let s ← find_squares s e1 
      return (s.insert (e1, ff))
  else e.mfoldl find_squares s
| s, e => e.mfoldl find_squares s

/--
`nlinarith_extras` is the preprocessor corresponding to the `nlinarith` tactic.

* For every term `t` such that `t^2` or `t*t` appears in the input, adds a proof of `t^2 ≥ 0`
  or `t*t ≥ 0`.
* For every pair of comparisons `t1 R1 0` and `t2 R2 0`, adds a proof of `t1*t2 R 0`.

This preprocessor is typically run last, after all inputs have been canonized.
-/
unsafe def nlinarith_extras : global_preprocessor :=
  { Name := "nonlinear arithmetic extras",
    transform :=
      fun ls =>
        do 
          let s ← ls.mfoldr (fun h s' => infer_type h >>= find_squares s') mk_rb_set 
          let new_es ←
            s.mfold ([] : List expr)$
                fun ⟨e, is_sq⟩ new_es =>
                  (do 
                      let p ← mk_app (if is_sq then `` sq_nonneg else `` mul_self_nonneg) [e]
                      return$ p :: new_es) <|>
                    return new_es 
          let new_es ← make_comp_with_zero.globalize.transform new_es 
          linarith_trace "nlinarith preprocessing found squares"
          linarith_trace s 
          linarith_trace_proofs "so we added proofs" new_es 
          let with_comps ←
            (new_es ++ ls).mmap
                fun e =>
                  do 
                    let tp ← infer_type e 
                    return$ (parse_into_comp_and_expr tp).elim (ineq.lt, e) fun ⟨ine, _⟩ => (ine, e)
          let products ←
            with_comps.mmap_upper_triangle$
                fun ⟨posa, a⟩ ⟨posb, b⟩ =>
                  (some <$>
                      match posa, posb with 
                      | ineq.eq, _ => mk_app `` zero_mul_eq [a, b]
                      | _, ineq.eq => mk_app `` mul_zero_eq [a, b]
                      | ineq.lt, ineq.lt => mk_app `` mul_pos_of_neg_of_neg [a, b]
                      | ineq.lt, ineq.le =>
                        do 
                          let a ← mk_app `` le_of_ltₓ [a]
                          mk_app `` mul_nonneg_of_nonpos_of_nonpos [a, b]
                      | ineq.le, ineq.lt =>
                        do 
                          let b ← mk_app `` le_of_ltₓ [b]
                          mk_app `` mul_nonneg_of_nonpos_of_nonpos [a, b]
                      | ineq.le, ineq.le => mk_app `` mul_nonneg_of_nonpos_of_nonpos [a, b]) <|>
                    return none 
          let products ← make_comp_with_zero.globalize.transform products.reduce_option 
          return$ new_es ++ ls ++ products }

-- error in Tactic.Linarith.Preprocessing: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/--
`remove_ne_aux` case splits on any proof `h : a ≠ b` in the input, turning it into `a < b ∨ a > b`.
This produces `2^n` branches when there are `n` such hypotheses in the input.
-/ meta def remove_ne_aux : list expr → tactic (list branch) :=
λ
hs, «expr <|> »(do {
 e ← hs.mfind (λ e : expr, do { e ← infer_type e, «expr $ »(guard, e.is_ne.is_some) }),
   «expr[ , ]»([(_, ng1), (_, ng2)]) ← «expr >>= »(to_expr (``(or.elim (lt_or_gt_of_ne (%%e)))), apply),
   let do_goal : expr → tactic (list branch) := λ g, do {
       set_goals «expr[ , ]»([g]),
         h ← intro1,
         ls ← «expr $ »(remove_ne_aux, hs.remove_all «expr[ , ]»([e])),
         «expr $ »(return, ls.map (λ b : branch, (b.1, [«expr :: »/«expr :: »/«expr :: »](h, b.2)))) } in
   «expr <*> »(«expr <$> »((«expr ++ »), do_goal ng1), do_goal ng2) }, do {
 g ← get_goal,
   return «expr[ , ]»([(g, hs)]) })

/--
`remove_ne` case splits on any proof `h : a ≠ b` in the input, turning it into `a < b ∨ a > b`,
by calling `linarith.remove_ne_aux`.
This produces `2^n` branches when there are `n` such hypotheses in the input.
-/
unsafe def remove_ne : global_branching_preprocessor :=
  { Name := "remove_ne", transform := remove_ne_aux }

/--
The default list of preprocessors, in the order they should typically run.
-/
unsafe def default_preprocessors : List global_branching_preprocessor :=
  [filter_comparisons, remove_negations, nat_to_int, strengthen_strict_int, make_comp_with_zero, cancel_denoms]

/--
`preprocess pps l` takes a list `l` of proofs of propositions.
It maps each preprocessor `pp ∈ pps` over this list.
The preprocessors are run sequentially: each recieves the output of the previous one.
Note that a preprocessor may produce multiple or no expressions from each input expression,
so the size of the list may change.
-/
unsafe def preprocess (pps : List global_branching_preprocessor) (l : List expr) : tactic (List branch) :=
  do 
    let g ← get_goal 
    pps.mfoldl (fun ls pp => List.join <$> (ls.mmap$ fun b => set_goals [b.1] >> pp.process b.2)) [(g, l)]

end Linarith

