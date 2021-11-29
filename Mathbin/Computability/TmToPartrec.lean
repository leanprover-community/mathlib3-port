import Mathbin.Computability.Halting 
import Mathbin.Computability.TuringMachine 
import Mathbin.Data.Num.Lemmas 
import Mathbin.Tactic.DeriveFintype

/-!
# Modelling partial recursive functions using Turing machines

This file defines a simplified basis for partial recursive functions, and a `turing.TM2` model
Turing machine for evaluating these functions. This amounts to a constructive proof that every
`partrec` function can be evaluated by a Turing machine.

## Main definitions

* `to_partrec.code`: a simplified basis for partial recursive functions, valued in
  `list ℕ →. list ℕ`.
  * `to_partrec.code.eval`: semantics for a `to_partrec.code` program
* `partrec_to_TM2.tr`: A TM2 turing machine which can evaluate `code` programs
-/


open function(update)

open Relation

namespace Turing

/-!
## A simplified basis for partrec

This section constructs the type `code`, which is a data type of programs with `list ℕ` input and
output, with enough expressivity to write any partial recursive function. The primitives are:

* `zero'` appends a `0` to the input. That is, `zero' v = 0 :: v`.
* `succ` returns the successor of the head of the input, defaulting to zero if there is no head:
  * `succ [] = [1]`
  * `succ (n :: v) = [n + 1]`
* `tail` returns the tail of the input
  * `tail [] = []`
  * `tail (n :: v) = v`
* `cons f fs` calls `f` and `fs` on the input and conses the results:
  * `cons f fs v = (f v).head :: fs v`
* `comp f g` calls `f` on the output of `g`:
  * `comp f g v = f (g v)`
* `case f g` cases on the head of the input, calling `f` or `g` depending on whether it is zero or
  a successor (similar to `nat.cases_on`).
  * `case f g [] = f []`
  * `case f g (0 :: v) = f v`
  * `case f g (n+1 :: v) = g (n :: v)`
* `fix f` calls `f` repeatedly, using the head of the result of `f` to decide whether to call `f`
  again or finish:
  * `fix f v = []` if `f v = []`
  * `fix f v = w` if `f v = 0 :: w`
  * `fix f v = fix f w` if `f v = n+1 :: w` (the exact value of `n` is discarded)

This basis is convenient because it is closer to the Turing machine model - the key operations are
splitting and merging of lists of unknown length, while the messy `n`-ary composition operation
from the traditional basis for partial recursive functions is absent - but it retains a
compositional semantics. The first step in transitioning to Turing machines is to make a sequential
evaluator for this basis, which we take up in the next section.
-/


namespace ToPartrec

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler decidable_eq
/-- The type of codes for primitive recursive functions. Unlike `nat.partrec.code`, this uses a set
of operations on `list ℕ`. See `code.eval` for a description of the behavior of the primitives. -/
@[derive #["[", expr decidable_eq, ",", expr inhabited, "]"]]
inductive code
| zero'
| succ
| tail
| cons : code → code → code
| comp : code → code → code
| case : code → code → code
| fix : code → code

/-- The semantics of the `code` primitives, as partial functions `list ℕ →. list ℕ`. By convention
we functions that return a single result return a singleton `[n]`, or in some cases `n :: v` where
`v` will be ignored by a subsequent function.

* `zero'` appends a `0` to the input. That is, `zero' v = 0 :: v`.
* `succ` returns the successor of the head of the input, defaulting to zero if there is no head:
  * `succ [] = [1]`
  * `succ (n :: v) = [n + 1]`
* `tail` returns the tail of the input
  * `tail [] = []`
  * `tail (n :: v) = v`
* `cons f fs` calls `f` and `fs` on the input and conses the results:
  * `cons f fs v = (f v).head :: fs v`
* `comp f g` calls `f` on the output of `g`:
  * `comp f g v = f (g v)`
* `case f g` cases on the head of the input, calling `f` or `g` depending on whether it is zero or
  a successor (similar to `nat.cases_on`).
  * `case f g [] = f []`
  * `case f g (0 :: v) = f v`
  * `case f g (n+1 :: v) = g (n :: v)`
* `fix f` calls `f` repeatedly, using the head of the result of `f` to decide whether to call `f`
  again or finish:
  * `fix f v = []` if `f v = []`
  * `fix f v = w` if `f v = 0 :: w`
  * `fix f v = fix f w` if `f v = n+1 :: w` (the exact value of `n` is discarded)
-/
@[simp]
def code.eval : code → List ℕ →. List ℕ
| code.zero' => fun v => pure (0 :: v)
| code.succ => fun v => pure [v.head.succ]
| code.tail => fun v => pure v.tail
| code.cons f fs =>
  fun v =>
    do 
      let n ← code.eval f v 
      let ns ← code.eval fs v 
      pure (n.head :: ns)
| code.comp f g => fun v => g.eval v >>= f.eval
| code.case f g => fun v => v.head.elim (f.eval v.tail) fun y _ => g.eval (y :: v.tail)
| code.fix f => Pfun.fix$ fun v => (f.eval v).map$ fun v => if v.head = 0 then Sum.inl v.tail else Sum.inr v.tail

namespace Code

/-- `nil` is the constant nil function: `nil v = []`. -/
def nil : code :=
  tail.comp succ

@[simp]
theorem nil_eval v : nil.eval v = pure [] :=
  by 
    simp [nil]

/-- `id` is the identity function: `id v = v`. -/
def id : code :=
  tail.comp zero'

@[simp]
theorem id_eval v : id.eval v = pure v :=
  by 
    simp [id]

/-- `head` gets the head of the input list: `head [] = [0]`, `head (n :: v) = [n]`. -/
def head : code :=
  cons id nil

@[simp]
theorem head_eval v : head.eval v = pure [v.head] :=
  by 
    simp [head]

/-- `zero` is the constant zero function: `zero v = [0]`. -/
def zero : code :=
  cons zero' nil

@[simp]
theorem zero_eval v : zero.eval v = pure [0] :=
  by 
    simp [zero]

/-- `pred` returns the predecessor of the head of the input:
`pred [] = [0]`, `pred (0 :: v) = [0]`, `pred (n+1 :: v) = [n]`. -/
def pred : code :=
  case zero head

@[simp]
theorem pred_eval v : pred.eval v = pure [v.head.pred] :=
  by 
    simp [pred] <;> cases v.head <;> simp 

/-- `rfind f` performs the function of the `rfind` primitive of partial recursive functions.
`rfind f v` returns the smallest `n` such that `(f (n :: v)).head = 0`.

It is implemented as:

    rfind f v = pred (fix (λ (n::v), f (n::v) :: n+1 :: v) (0 :: v))

The idea is that the initial state is `0 :: v`, and the `fix` keeps `n :: v` as its internal state;
it calls `f (n :: v)` as the exit test and `n+1 :: v` as the next state. At the end we get
`n+1 :: v` where `n` is the desired output, and `pred (n+1 :: v) = [n]` returns the result.
 -/
def rfind (f : code) : code :=
  comp pred$ comp (fix$ cons f$ cons succ tail) zero'

/-- `prec f g` implements the `prec` (primitive recursion) operation of partial recursive
functions. `prec f g` evaluates as:

* `prec f g [] = [f []]`
* `prec f g (0 :: v) = [f v]`
* `prec f g (n+1 :: v) = [g (n :: prec f g (n :: v) :: v)]`

It is implemented as:

    G (a :: b :: IH :: v) = (b :: a+1 :: b-1 :: g (a :: IH :: v) :: v)
    F (0 :: f_v :: v) = (f_v :: v)
    F (n+1 :: f_v :: v) = (fix G (0 :: n :: f_v :: v)).tail.tail
    prec f g (a :: v) = [(F (a :: f v :: v)).head]

Because `fix` always evaluates its body at least once, we must special case the `0` case to avoid
calling `g` more times than necessary (which could be bad if `g` diverges). If the input is
`0 :: v`, then `F (0 :: f v :: v) = (f v :: v)` so we return `[f v]`. If the input is `n+1 :: v`,
we evaluate the function from the bottom up, with initial state `0 :: n :: f v :: v`. The first
number counts up, providing arguments for the applications to `g`, while the second number counts
down, providing the exit condition (this is the initial `b` in the return value of `G`, which is
stripped by `fix`). After the `fix` is complete, the final state is `n :: 0 :: res :: v` where
`res` is the desired result, and the rest reduces this to `[res]`. -/
def prec (f g : code) : code :=
  let G :=
    cons tail$ cons succ$ cons (comp pred tail)$ cons (comp g$ cons id$ comp tail tail)$ comp tail$ comp tail tail 
  let F := case id$ comp (comp (comp tail tail) (fix G)) zero' 
  cons (comp F (cons head$ cons (comp f tail) tail)) nil

attribute [-simp] Part.bind_eq_bind Part.map_eq_map Part.pure_eq_some

theorem exists_code.comp {m n} {f : Vector ℕ n →. ℕ} {g : Finₓ n → Vector ℕ m →. ℕ}
  (hf : ∃ c : code, ∀ (v : Vector ℕ n), c.eval v.1 = pure <$> f v)
  (hg : ∀ i, ∃ c : code, ∀ (v : Vector ℕ m), c.eval v.1 = pure <$> g i v) :
  ∃ c : code, ∀ (v : Vector ℕ m), c.eval v.1 = pure <$> ((Vector.mOfFnₓ fun i => g i v) >>= f) :=
  by 
    suffices  : ∃ c : code, ∀ (v : Vector ℕ m), c.eval v.1 = Subtype.val <$> Vector.mOfFnₓ fun i => g i v
    ·
      obtain ⟨cf, hf⟩ := hf 
      obtain ⟨cg, hg⟩ := this 
      exact
        ⟨cf.comp cg,
          fun v =>
            by 
              simp [hg, hf, map_bind, seq_bind_eq, · ∘ ·, -Subtype.val_eq_coe]
              rfl⟩
    clear hf f 
    induction' n with n IH
    ·
      exact
        ⟨nil,
          fun v =>
            by 
              simp [Vector.mOfFnₓ] <;> rfl⟩
    ·
      obtain ⟨cg, hg₁⟩ := hg 0 
      obtain ⟨cl, hl⟩ := IH fun i => hg i.succ 
      exact
        ⟨cons cg cl,
          fun v =>
            by 
              simp [Vector.mOfFnₓ, hg₁, map_bind, seq_bind_eq, bind_assoc, · ∘ ·, hl, -Subtype.val_eq_coe]
              rfl⟩

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem exists_code
{n}
{f : «expr →. »(vector exprℕ() n, exprℕ())}
(hf : nat.partrec' f) : «expr∃ , »((c : code), ∀ v : vector exprℕ() n, «expr = »(c.eval v.1, «expr <$> »(pure, f v))) :=
begin
  induction [expr hf] [] ["with", ident n, ident f, ident hf] [],
  induction [expr hf] [] [] [],
  case [ident prim, ident zero] { exact [expr ⟨zero', λ ⟨«expr[ , ]»([]), _⟩, rfl⟩] },
  case [ident prim, ident succ] { exact [expr ⟨succ, λ ⟨«expr[ , ]»([v]), _⟩, rfl⟩] },
  case [ident prim, ident nth, ":", ident n, ident i] { refine [expr fin.succ_rec (λ n, _) (λ n i IH, _) i],
    { exact [expr ⟨head, λ ⟨list.cons a as, _⟩, by simp [] [] [] [] [] []; refl⟩] },
    { obtain ["⟨", ident c, ",", ident h, "⟩", ":=", expr IH],
      exact [expr ⟨c.comp tail, λ
        v, by simpa [] [] [] ["[", "<-", expr vector.nth_tail, "]"] [] ["using", expr h v.tail]⟩] } },
  case [ident prim, ident comp, ":", ident m, ident n, ident f, ident g, ident hf, ident hg, ident IHf, ident IHg] { simpa [] [] [] ["[", expr part.bind_eq_bind, "]"] [] ["using", expr exists_code.comp IHf IHg] },
  case [ident prim, ident prec, ":", ident n, ident f, ident g, ident hf, ident hg, ident IHf, ident IHg] { obtain ["⟨", ident cf, ",", ident hf, "⟩", ":=", expr IHf],
    obtain ["⟨", ident cg, ",", ident hg, "⟩", ":=", expr IHg],
    simp [] [] ["only"] ["[", expr part.map_eq_map, ",", expr part.map_some, ",", expr pfun.coe_val, "]"] [] ["at", ident hf, ident hg],
    refine [expr ⟨prec cf cg, λ v, _⟩],
    rw ["<-", expr v.cons_head_tail] [],
    specialize [expr hf v.tail],
    replace [ident hg] [] [":=", expr λ a b, hg «expr ::ᵥ »(a, «expr ::ᵥ »(b, v.tail))],
    simp [] [] ["only"] ["[", expr vector.cons_val, ",", expr vector.tail_val, "]"] [] ["at", ident hf, ident hg],
    simp [] [] ["only"] ["[", expr part.map_eq_map, ",", expr part.map_some, ",", expr vector.cons_val, ",", expr vector.cons_tail, ",", expr vector.cons_head, ",", expr pfun.coe_val, ",", expr vector.tail_val, "]"] [] [],
    simp [] [] ["only"] ["[", "<-", expr part.pure_eq_some, "]"] [] ["at", ident hf, ident hg, "⊢"],
    induction [expr v.head] [] ["with", ident n, ident IH] []; simp [] [] [] ["[", expr prec, ",", expr hf, ",", expr bind_assoc, ",", "<-", expr part.map_eq_map, ",", "<-", expr bind_pure_comp_eq_map, ",", expr show ∀
     x, «expr = »(pure x, «expr[ , ]»([x])), from λ _, rfl, ",", "-", ident subtype.val_eq_coe, "]"] [] [],
    suffices [] [":", expr ∀
     a
     b, «expr = »(«expr + »(a, b), n) → «expr ∈ »(([«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](n.succ, [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](0, [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](g «expr ::ᵥ »(n, «expr ::ᵥ »(nat.elim (f v.tail) (λ
            y
            IH, g «expr ::ᵥ »(y, «expr ::ᵥ »(IH, v.tail))) n, v.tail)), v.val.tail))) : list exprℕ()), pfun.fix (λ
       v : list exprℕ(), do {
       x ← cg.eval [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](v.head, v.tail.tail),
         «expr $ »(pure, if «expr = »(v.tail.head, 0) then sum.inl ([«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](v.head.succ, [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](v.tail.head.pred, [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](x.head, v.tail.tail.tail))) : list exprℕ()) else sum.inr [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](v.head.succ, [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](v.tail.head.pred, [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](x.head, v.tail.tail.tail)))) }) [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](a, [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](b, [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](nat.elim (f v.tail) (λ
          y IH, g «expr ::ᵥ »(y, «expr ::ᵥ »(IH, v.tail))) a, v.val.tail))))],
    { rw [expr (_ : «expr = »(pfun.fix _ _, pure _))] [],
      swap,
      exact [expr part.eq_some_iff.2 (this 0 n (zero_add n))],
      simp [] [] ["only"] ["[", expr list.head, ",", expr pure_bind, ",", expr list.tail_cons, "]"] [] [] },
    intros [ident a, ident b, ident e],
    induction [expr b] [] ["with", ident b, ident IH] ["generalizing", ident a, ident e],
    { refine [expr pfun.mem_fix_iff.2 «expr $ »(or.inl, part.eq_some_iff.1 _)],
      simp [] [] ["only"] ["[", expr hg, ",", "<-", expr e, ",", expr pure_bind, ",", expr list.tail_cons, "]"] [] [],
      refl },
    { refine [expr pfun.mem_fix_iff.2 (or.inr ⟨_, _, IH «expr + »(a, 1) (by rwa [expr add_right_comm] [])⟩)],
      simp [] [] ["only"] ["[", expr hg, ",", expr eval, ",", expr pure_bind, ",", expr nat.elim_succ, ",", expr list.tail, "]"] [] [],
      exact [expr part.mem_some_iff.2 rfl] } },
  case [ident comp, ":", ident m, ident n, ident f, ident g, ident hf, ident hg, ident IHf, ident IHg] { exact [expr exists_code.comp IHf IHg] },
  case [ident rfind, ":", ident n, ident f, ident hf, ident IHf] { obtain ["⟨", ident cf, ",", ident hf, "⟩", ":=", expr IHf],
    refine [expr ⟨rfind cf, λ v, _⟩],
    replace [ident hf] [] [":=", expr λ a, hf «expr ::ᵥ »(a, v)],
    simp [] [] ["only"] ["[", expr part.map_eq_map, ",", expr part.map_some, ",", expr vector.cons_val, ",", expr pfun.coe_val, ",", expr show ∀
     x, «expr = »(pure x, «expr[ , ]»([x])), from λ _, rfl, "]"] [] ["at", ident hf, "⊢"],
    refine [expr part.ext (λ x, _)],
    simp [] [] ["only"] ["[", expr rfind, ",", expr part.bind_eq_bind, ",", expr part.pure_eq_some, ",", expr part.map_eq_map, ",", expr part.bind_some, ",", expr exists_prop, ",", expr eval, ",", expr list.head, ",", expr pred_eval, ",", expr part.map_some, ",", expr bool.ff_eq_to_bool_iff, ",", expr part.mem_bind_iff, ",", expr list.length, ",", expr part.mem_map_iff, ",", expr nat.mem_rfind, ",", expr list.tail, ",", expr bool.tt_eq_to_bool_iff, ",", expr part.mem_some_iff, ",", expr part.map_bind, "]"] [] [],
    split,
    { rintro ["⟨", ident v', ",", ident h1, ",", ident rfl, "⟩"],
      suffices [] [":", expr ∀
       v₁ : list exprℕ(), «expr ∈ »(v', pfun.fix (λ
         v, «expr $ »((cf.eval v).bind, λ
          y, «expr $ »(part.some, if «expr = »(y.head, 0) then sum.inl [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](v.head.succ, v.tail) else sum.inr [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](v.head.succ, v.tail)))) v₁) → ∀
       n, «expr = »(v₁, [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](n, v.val)) → ∀
       m «expr < » n, «expr¬ »(«expr = »(f «expr ::ᵥ »(m, v), 0)) → «expr∃ , »((a : exprℕ()), «expr ∧ »(«expr ∧ »(«expr = »(f «expr ::ᵥ »(a, v), 0), ∀
          {m : exprℕ()}, «expr < »(m, a) → «expr¬ »(«expr = »(f «expr ::ᵥ »(m, v), 0))), «expr = »(«expr[ , ]»([a]), «expr[ , ]»([v'.head.pred]))))],
      { exact [expr this _ h1 0 rfl (by rintro ["_", "⟨", "⟩"])] },
      clear [ident h1],
      intros [ident v₀, ident h1],
      refine [expr pfun.fix_induction h1 (λ v₁ h2 IH, _)],
      clear [ident h1],
      rintro [ident n, ident rfl, ident hm],
      have [] [] [":=", expr pfun.mem_fix_iff.1 h2],
      simp [] [] ["only"] ["[", expr hf, ",", expr part.bind_some, "]"] [] ["at", ident this],
      split_ifs ["at", ident this] [],
      { simp [] [] ["only"] ["[", expr list.head, ",", expr exists_false, ",", expr or_false, ",", expr part.mem_some_iff, ",", expr list.tail_cons, ",", expr false_and, "]"] [] ["at", ident this],
        subst [expr this],
        exact [expr ⟨_, ⟨h, hm⟩, rfl⟩] },
      { simp [] [] ["only"] ["[", expr list.head, ",", expr exists_eq_left, ",", expr part.mem_some_iff, ",", expr list.tail_cons, ",", expr false_or, "]"] [] ["at", ident this],
        refine [expr IH _ this (by simp [] [] [] ["[", expr hf, ",", expr h, ",", "-", ident subtype.val_eq_coe, "]"] [] []) _ rfl (λ
          m h', _)],
        obtain [ident h, "|", ident rfl, ":=", expr nat.lt_succ_iff_lt_or_eq.1 h'],
        exacts ["[", expr hm _ h, ",", expr h, "]"] } },
    { rintro ["⟨", ident n, ",", "⟨", ident hn, ",", ident hm, "⟩", ",", ident rfl, "⟩"],
      refine [expr ⟨[«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](n.succ, v.1), _, rfl⟩],
      have [] [":", expr «expr ∈ »(([«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](n.succ, v.1) : list exprℕ()), pfun.fix (λ
         v, «expr $ »((cf.eval v).bind, λ
          y, «expr $ »(part.some, if «expr = »(y.head, 0) then sum.inl [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](v.head.succ, v.tail) else sum.inr [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](v.head.succ, v.tail)))) [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](n, v.val))] [":=", expr pfun.mem_fix_iff.2 (or.inl (by simp [] [] [] ["[", expr hf, ",", expr hn, ",", "-", ident subtype.val_eq_coe, "]"] [] []))],
      generalize_hyp [] [":"] [expr «expr = »(([«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](n.succ, v.1) : list exprℕ()), w)] ["at", ident this, "⊢"],
      clear [ident hn],
      induction [expr n] [] ["with", ident n, ident IH] [],
      { exact [expr this] },
      refine [expr IH (λ m h', hm (nat.lt_succ_of_lt h')) (pfun.mem_fix_iff.2 (or.inr ⟨_, _, this⟩))],
      simp [] [] ["only"] ["[", expr hf, ",", expr hm n.lt_succ_self, ",", expr part.bind_some, ",", expr list.head, ",", expr eq_self_iff_true, ",", expr if_false, ",", expr part.mem_some_iff, ",", expr and_self, ",", expr list.tail_cons, "]"] [] [] } }
end

end Code

/-!
## From compositional semantics to sequential semantics

Our initial sequential model is designed to be as similar as possible to the compositional
semantics in terms of its primitives, but it is a sequential semantics, meaning that rather than
defining an `eval c : list ℕ →. list ℕ` function for each program, defined by recursion on
programs, we have a type `cfg` with a step function `step : cfg → option cfg` that provides a
deterministic evaluation order. In order to do this, we introduce the notion of a *continuation*,
which can be viewed as a `code` with a hole in it where evaluation is currently taking place.
Continuations can be assigned a `list ℕ →. list ℕ` semantics as well, with the interpretation
being that given a `list ℕ` result returned from the code in the hole, the remainder of the
program will evaluate to a `list ℕ` final value.

The continuations are:

* `halt`: the empty continuation: the hole is the whole program, whatever is returned is the
  final result. In our notation this is just `_`.
* `cons₁ fs v k`: evaluating the first part of a `cons`, that is `k (_ :: fs v)`, where `k` is the
  outer continuation.
* `cons₂ ns k`: evaluating the second part of a `cons`: `k (ns.head :: _)`. (Technically we don't
  need to hold on to all of `ns` here since we are already committed to taking the head, but this
  is more regular.)
* `comp f k`: evaluating the first part of a composition: `k (f _)`.
* `fix f k`: waiting for the result of `f` in a `fix f` expression:
  `k (if _.head = 0 then _.tail else fix f (_.tail))`

The type `cfg` of evaluation states is:

* `ret k v`: we have received a result, and are now evaluating the continuation `k` with result
  `v`; that is, `k v` where `k` is ready to evaluate.
* `halt v`: we are done and the result is `v`.

The main theorem of this section is that for each code `c`, the state `step_normal c halt v` steps
to `v'` in finitely many steps if and only if `code.eval c v = some v'`.
-/


-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler inhabited
/-- The type of continuations, built up during evaluation of a `code` expression. -/
@[derive #[expr inhabited]]
inductive cont
| halt
| cons₁ : code → list exprℕ() → cont → cont
| cons₂ : list exprℕ() → cont → cont
| comp : code → cont → cont
| fix : code → cont → cont

/-- The semantics of a continuation. -/
def cont.eval : cont → List ℕ →. List ℕ
| cont.halt => pure
| cont.cons₁ fs as k =>
  fun v =>
    do 
      let ns ← code.eval fs as 
      cont.eval k (v.head :: ns)
| cont.cons₂ ns k => fun v => cont.eval k (ns.head :: v)
| cont.comp f k => fun v => code.eval f v >>= cont.eval k
| cont.fix f k => fun v => if v.head = 0 then k.eval v.tail else f.fix.eval v.tail >>= k.eval

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler inhabited
/-- The set of configurations of the machine:

* `halt v`: The machine is about to stop and `v : list ℕ` is the result.
* `ret k v`: The machine is about to pass `v : list ℕ` to continuation `k : cont`.

We don't have a state corresponding to normal evaluation because these are evaluated immediately
to a `ret` "in zero steps" using the `step_normal` function. -/ @[derive #[expr inhabited]] inductive cfg
| halt : list exprℕ() → cfg
| ret : cont → list exprℕ() → cfg

/-- Evaluating `c : code` in a continuation `k : cont` and input `v : list ℕ`. This goes by
recursion on `c`, building an augmented continuation and a value to pass to it.

* `zero' v = 0 :: v` evaluates immediately, so we return it to the parent continuation
* `succ v = [v.head.succ]` evaluates immediately, so we return it to the parent continuation
* `tail v = v.tail` evaluates immediately, so we return it to the parent continuation
* `cons f fs v = (f v).head :: fs v` requires two sub-evaluations, so we evaluate
  `f v` in the continuation `k (_.head :: fs v)` (called `cont.cons₁ fs v k`)
* `comp f g v = f (g v)` requires two sub-evaluations, so we evaluate
  `g v` in the continuation `k (f _)` (called `cont.comp f k`)
* `case f g v = v.head.cases_on (f v.tail) (λ n, g (n :: v.tail))` has the information needed to
  evaluate the case statement, so we do that and transition to either `f v` or `g (n :: v.tail)`.
* `fix f v = let v' := f v in if v'.head = 0 then k v'.tail else fix f v'.tail`
  needs to first evaluate `f v`, so we do that and leave the rest for the continuation (called
  `cont.fix f k`)
-/
def step_normal : code → cont → List ℕ → cfg
| code.zero', k, v => cfg.ret k (0 :: v)
| code.succ, k, v => cfg.ret k [v.head.succ]
| code.tail, k, v => cfg.ret k v.tail
| code.cons f fs, k, v => step_normal f (cont.cons₁ fs v k) v
| code.comp f g, k, v => step_normal g (cont.comp f k) v
| code.case f g, k, v => v.head.elim (step_normal f k v.tail) fun y _ => step_normal g k (y :: v.tail)
| code.fix f, k, v => step_normal f (cont.fix f k) v

/-- Evaluating a continuation `k : cont` on input `v : list ℕ`. This is the second part of
evaluation, when we receive results from continuations built by `step_normal`.

* `cont.halt v = v`, so we are done and transition to the `cfg.halt v` state
* `cont.cons₁ fs as k v = k (v.head :: fs as)`, so we evaluate `fs as` now with the continuation
  `k (v.head :: _)` (called `cons₂ v k`).
* `cont.cons₂ ns k v = k (ns.head :: v)`, where we now have everything we need to evaluate
  `ns.head :: v`, so we return it to `k`.
* `cont.comp f k v = k (f v)`, so we call `f v` with `k` as the continuation.
* `cont.fix f k v = k (if v.head = 0 then k v.tail else fix f v.tail)`, where `v` is a value,
  so we evaluate the if statement and either call `k` with `v.tail`, or call `fix f v` with `k` as
  the continuation (which immediately calls `f` with `cont.fix f k` as the continuation).
-/
def step_ret : cont → List ℕ → cfg
| cont.halt, v => cfg.halt v
| cont.cons₁ fs as k, v => step_normal fs (cont.cons₂ v k) as
| cont.cons₂ ns k, v => step_ret k (ns.head :: v)
| cont.comp f k, v => step_normal f k v
| cont.fix f k, v => if v.head = 0 then step_ret k v.tail else step_normal f (cont.fix f k) v.tail

/-- If we are not done (in `cfg.halt` state), then we must be still stuck on a continuation, so
this main loop calls `step_ret` with the new continuation. The overall `step` function transitions
from one `cfg` to another, only halting at the `cfg.halt` state. -/
def step : cfg → Option cfg
| cfg.halt _ => none
| cfg.ret k v => some (step_ret k v)

/-- In order to extract a compositional semantics from the sequential execution behavior of
configurations, we observe that continuations have a monoid structure, with `cont.halt` as the unit
and `cont.then` as the multiplication. `cont.then k₁ k₂` runs `k₁` until it halts, and then takes
the result of `k₁` and passes it to `k₂`.

We will not prove it is associative (although it is), but we are instead interested in the
associativity law `k₂ (eval c k₁) = eval c (k₁.then k₂)`. This holds at both the sequential and
compositional levels, and allows us to express running a machine without the ambient continuation
and relate it to the original machine's evaluation steps. In the literature this is usually
where one uses Turing machines embedded inside other Turing machines, but this approach allows us
to avoid changing the ambient type `cfg` in the middle of the recursion.
-/
def cont.then : cont → cont → cont
| cont.halt, k' => k'
| cont.cons₁ fs as k, k' => cont.cons₁ fs as (k.then k')
| cont.cons₂ ns k, k' => cont.cons₂ ns (k.then k')
| cont.comp f k, k' => cont.comp f (k.then k')
| cont.fix f k, k' => cont.fix f (k.then k')

theorem cont.then_eval {k k' : cont} {v} : (k.then k').eval v = k.eval v >>= k'.eval :=
  by 
    induction k generalizing v <;> simp only [cont.eval, cont.then, bind_assoc, pure_bind]
    ·
      simp only [←k_ih]
    ·
      splitIfs <;> [rfl, simp only [←k_ih, bind_assoc]]

/-- The `then k` function is a "configuration homomorphism". Its operation on states is to append
`k` to the continuation of a `cfg.ret` state, and to run `k` on `v` if we are in the `cfg.halt v`
state. -/
def cfg.then : cfg → cont → cfg
| cfg.halt v, k' => step_ret k' v
| cfg.ret k v, k' => cfg.ret (k.then k') v

/-- The `step_normal` function respects the `then k'` homomorphism. Note that this is an exact
equality, not a simulation; the original and embedded machines move in lock-step until the
embedded machine reaches the halt state. -/
theorem step_normal_then c (k k' : cont) v : step_normal c (k.then k') v = (step_normal c k v).then k' :=
  by 
    induction c generalizing k v <;> simp only [cont.then, step_normal, cfg.then]
    case turing.to_partrec.code.cons c c' ih ih' => 
      rw [←ih, cont.then]
    case turing.to_partrec.code.comp c c' ih ih' => 
      rw [←ih', cont.then]
    ·
      cases v.head <;> simp only [Nat.elim]
    case turing.to_partrec.code.fix c ih => 
      rw [←ih, cont.then]

/-- The `step_ret` function respects the `then k'` homomorphism. Note that this is an exact
equality, not a simulation; the original and embedded machines move in lock-step until the
embedded machine reaches the halt state. -/
theorem step_ret_then {k k' : cont} {v} : step_ret (k.then k') v = (step_ret k v).then k' :=
  by 
    induction k generalizing v <;> simp only [cont.then, step_ret, cfg.then]
    ·
      rw [←step_normal_then]
      rfl
    ·
      rw [←step_normal_then]
    ·
      splitIfs
      ·
        rw [←k_ih]
      ·
        rw [←step_normal_then]
        rfl

/-- This is a temporary definition, because we will prove in `code_is_ok` that it always holds.
It asserts that `c` is semantically correct; that is, for any `k` and `v`,
`eval (step_normal c k v) = eval (cfg.ret k (code.eval c v))`, as an equality of partial values
(so one diverges iff the other does).

In particular, we can let `k = cont.halt`, and then this asserts that `step_normal c cont.halt v`
evaluates to `cfg.halt (code.eval c v)`. -/
def code.ok (c : code) :=
  ∀ k v, eval step (step_normal c k v) = code.eval c v >>= fun v => eval step (cfg.ret k v)

theorem code.ok.zero {c} (h : code.ok c) {v} : eval step (step_normal c cont.halt v) = cfg.halt <$> code.eval c v :=
  by 
    rw [h, ←bind_pure_comp_eq_map]
    congr 
    funext v 
    exact Part.eq_some_iff.2 (mem_eval.2 ⟨refl_trans_gen.single rfl, rfl⟩)

theorem step_normal.is_ret c k v : ∃ k' v', step_normal c k v = cfg.ret k' v' :=
  by 
    induction c generalizing k v 
    iterate 3 
      exact ⟨_, _, rfl⟩
    case cons f fs IHf IHfs => 
      apply IHf 
    case comp f g IHf IHg => 
      apply IHg 
    case case f g IHf IHg => 
      rw [step_normal]
      cases v.head <;> simp only [Nat.elim] <;> [apply IHf, apply IHg]
    case fix f IHf => 
      apply IHf

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem cont_eval_fix
{f k v}
(fok : code.ok f) : «expr = »(eval step (step_normal f (cont.fix f k) v), «expr >>= »(f.fix.eval v, λ
  v, eval step (cfg.ret k v))) :=
begin
  refine [expr part.ext (λ x, _)],
  simp [] [] ["only"] ["[", expr part.bind_eq_bind, ",", expr part.mem_bind_iff, "]"] [] [],
  split,
  { suffices [] [":", expr ∀
     c, «expr ∈ »(x, eval step c) → ∀
     v
     c', «expr = »(c, cfg.then c' (cont.fix f k)) → reaches step (step_normal f cont.halt v) c' → «expr∃ , »((v₁ «expr ∈ » f.eval v), «expr∃ , »((v₂ «expr ∈ » if «expr = »(list.head v₁, 0) then pure v₁.tail else f.fix.eval v₁.tail), «expr ∈ »(x, eval step (cfg.ret k v₂))))],
    { intro [ident h],
      obtain ["⟨", ident v₁, ",", ident hv₁, ",", ident v₂, ",", ident hv₂, ",", ident h₃, "⟩", ":=", expr this _ h _ _ (step_normal_then _ cont.halt _ _) refl_trans_gen.refl],
      refine [expr ⟨v₂, pfun.mem_fix_iff.2 _, h₃⟩],
      simp [] [] ["only"] ["[", expr part.eq_some_iff.2 hv₁, ",", expr part.map_some, "]"] [] [],
      split_ifs ["at", ident hv₂, "⊢"] [],
      { rw [expr part.mem_some_iff.1 hv₂] [],
        exact [expr or.inl (part.mem_some _)] },
      { exact [expr or.inr ⟨_, part.mem_some _, hv₂⟩] } },
    refine [expr λ c he, eval_induction he (λ y h IH, _)],
    rintro [ident v, "(", "⟨", ident v', "⟩", "|", "⟨", ident k', ",", ident v', "⟩", ")", ident rfl, ident hr]; rw [expr cfg.then] ["at", ident h, ident IH],
    { have [] [] [":=", expr mem_eval.2 ⟨hr, rfl⟩],
      rw ["[", expr fok, ",", expr part.bind_eq_bind, ",", expr part.mem_bind_iff, "]"] ["at", ident this],
      obtain ["⟨", ident v'', ",", ident h₁, ",", ident h₂, "⟩", ":=", expr this],
      rw [expr reaches_eval] ["at", ident h₂],
      swap,
      exact [expr refl_trans_gen.single rfl],
      cases [expr part.mem_unique h₂ (mem_eval.2 ⟨refl_trans_gen.refl, rfl⟩)] [],
      refine [expr ⟨v', h₁, _⟩],
      rw ["[", expr step_ret, "]"] ["at", ident h],
      revert [ident h],
      by_cases [expr he, ":", expr «expr = »(v'.head, 0)]; simp [] [] ["only"] ["[", expr exists_prop, ",", expr if_pos, ",", expr if_false, ",", expr he, "]"] [] []; intro [ident h],
      { refine [expr ⟨_, part.mem_some _, _⟩],
        rw [expr reaches_eval] [],
        exact [expr h],
        exact [expr refl_trans_gen.single rfl] },
      { obtain ["⟨", ident k₀, ",", ident v₀, ",", ident e₀, "⟩", ":=", expr step_normal.is_ret f cont.halt v'.tail],
        have [ident e₁] [] [":=", expr step_normal_then f cont.halt (cont.fix f k) v'.tail],
        rw ["[", expr e₀, ",", expr cont.then, ",", expr cfg.then, "]"] ["at", ident e₁],
        obtain ["⟨", ident v₁, ",", ident hv₁, ",", ident v₂, ",", ident hv₂, ",", ident h₃, "⟩", ":=", expr IH (step_ret (k₀.then (cont.fix f k)) v₀) _ _ v'.tail _ step_ret_then _],
        { refine [expr ⟨_, pfun.mem_fix_iff.2 _, h₃⟩],
          simp [] [] ["only"] ["[", expr part.eq_some_iff.2 hv₁, ",", expr part.map_some, ",", expr part.mem_some_iff, "]"] [] [],
          split_ifs ["at", ident hv₂, "⊢"] []; [exact [expr or.inl (part.mem_some_iff.1 hv₂)], exact [expr or.inr ⟨_, rfl, hv₂⟩]] },
        { rwa ["[", "<-", expr @reaches_eval _ _ (cfg.ret (k₀.then (cont.fix f k)) v₀), ",", "<-", expr e₁, "]"] [],
          exact [expr refl_trans_gen.single rfl] },
        { rw ["[", expr step_ret, ",", expr if_neg he, ",", expr e₁, "]"] [],
          refl },
        { apply [expr refl_trans_gen.single],
          rw [expr e₀] [],
          exact [expr rfl] } } },
    { rw [expr reaches_eval] ["at", ident h],
      swap,
      exact [expr refl_trans_gen.single rfl],
      exact [expr IH _ h rfl _ _ step_ret_then (refl_trans_gen.tail hr rfl)] } },
  { rintro ["⟨", ident v', ",", ident he, ",", ident hr, "⟩"],
    rw [expr reaches_eval] ["at", ident hr],
    swap,
    exact [expr refl_trans_gen.single rfl],
    refine [expr pfun.fix_induction he (λ (v) (he : «expr ∈ »(v', f.fix.eval v)) (IH), _)],
    rw ["[", expr fok, ",", expr part.bind_eq_bind, ",", expr part.mem_bind_iff, "]"] [],
    obtain [ident he, "|", "⟨", ident v'', ",", ident he₁', ",", ident he₂', "⟩", ":=", expr pfun.mem_fix_iff.1 he],
    { obtain ["⟨", ident v', ",", ident he₁, ",", ident he₂, "⟩", ":=", expr (part.mem_map_iff _).1 he],
      split_ifs ["at", ident he₂] []; cases [expr he₂] [],
      refine [expr ⟨_, he₁, _⟩],
      rw [expr reaches_eval] [],
      swap,
      exact [expr refl_trans_gen.single rfl],
      rwa ["[", expr step_ret, ",", expr if_pos h, "]"] [] },
    { obtain ["⟨", ident v₁, ",", ident he₁, ",", ident he₂, "⟩", ":=", expr (part.mem_map_iff _).1 he₁'],
      split_ifs ["at", ident he₂] []; cases [expr he₂] [],
      clear [ident he₂, ident he₁'],
      change [expr «expr ∈ »(_, f.fix.eval _)] [] ["at", ident he₂'],
      refine [expr ⟨_, he₁, _⟩],
      rw [expr reaches_eval] [],
      swap,
      exact [expr refl_trans_gen.single rfl],
      rwa ["[", expr step_ret, ",", expr if_neg h, "]"] [],
      exact [expr IH v₁.tail he₂' ((part.mem_map_iff _).2 ⟨_, he₁, if_neg h⟩)] } }
end

theorem code_is_ok c : code.ok c :=
  by 
    induction c <;> intro k v <;> rw [step_normal]
    iterate 3
      simp only [code.eval, pure_bind]
    case cons f fs IHf IHfs => 
      rw [code.eval, IHf]
      simp only [bind_assoc, cont.eval, pure_bind]
      congr 
      funext v 
      rw [reaches_eval]
      swap 
      exact refl_trans_gen.single rfl 
      rw [step_ret, IHfs]
      congr 
      funext v' 
      refine' Eq.trans _ (Eq.symm _) <;>
        try 
          exact reaches_eval (refl_trans_gen.single rfl)
    case comp f g IHf IHg => 
      rw [code.eval, IHg]
      simp only [bind_assoc, cont.eval, pure_bind]
      congr 
      funext v 
      rw [reaches_eval]
      swap 
      exact refl_trans_gen.single rfl 
      rw [step_ret, IHf]
    case case f g IHf IHg => 
      simp only [code.eval]
      cases v.head <;> simp only [Nat.elim, code.eval] <;> [apply IHf, apply IHg]
    case fix f IHf => 
      rw [cont_eval_fix IHf]

theorem step_normal_eval c v : eval step (step_normal c cont.halt v) = cfg.halt <$> c.eval v :=
  (code_is_ok c).zero

theorem step_ret_eval {k v} : eval step (step_ret k v) = cfg.halt <$> k.eval v :=
  by 
    induction k generalizing v 
    case halt => 
      simp only [mem_eval, cont.eval, map_pure]
      exact Part.eq_some_iff.2 (mem_eval.2 ⟨refl_trans_gen.refl, rfl⟩)
    case cons₁ fs as k IH => 
      rw [cont.eval, step_ret, code_is_ok]
      simp only [←bind_pure_comp_eq_map, bind_assoc]
      congr 
      funext v' 
      rw [reaches_eval]
      swap 
      exact refl_trans_gen.single rfl 
      rw [step_ret, IH, bind_pure_comp_eq_map]
    case cons₂ ns k IH => 
      rw [cont.eval, step_ret]
      exact IH 
    case comp f k IH => 
      rw [cont.eval, step_ret, code_is_ok]
      simp only [←bind_pure_comp_eq_map, bind_assoc]
      congr 
      funext v' 
      rw [reaches_eval]
      swap 
      exact refl_trans_gen.single rfl 
      rw [IH, bind_pure_comp_eq_map]
    case fix f k IH => 
      rw [cont.eval, step_ret]
      simp only [bind_pure_comp_eq_map]
      splitIfs
      ·
        exact IH 
      simp only [←bind_pure_comp_eq_map, bind_assoc, cont_eval_fix (code_is_ok _)]
      congr 
      funext 
      rw [bind_pure_comp_eq_map, ←IH]
      exact reaches_eval (refl_trans_gen.single rfl)

end ToPartrec

/-!
## Simulating sequentialized partial recursive functions in TM2

At this point we have a sequential model of partial recursive functions: the `cfg` type and
`step : cfg → option cfg` function from the previous section. The key feature of this model is that
it does a finite amount of computation (in fact, an amount which is statically bounded by the size
of the program) between each step, and no individual step can diverge (unlike the compositional
semantics, where every sub-part of the computation is potentially divergent). So we can utilize the
same techniques as in the other TM simulations in `computability.turing_machine` to prove that
each step corresponds to a finite number of steps in a lower level model. (We don't prove it here,
but in anticipation of the complexity class P, the simulation is actually polynomial-time as well.)

The target model is `turing.TM2`, which has a fixed finite set of stacks, a bit of local storage,
with programs selected from a potentially infinite (but finitely accessible) set of program
positions, or labels `Λ`, each of which executes a finite sequence of basic stack commands.

For this program we will need four stacks, each on an alphabet `Γ'` like so:

    inductive Γ'  | Cons | cons | bit0 | bit1

We represent a number as a bit sequence, lists of numbers by putting `cons` after each element, and
lists of lists of natural numbers by putting `Cons` after each list. For example:

    0 ~> []
    1 ~> [bit1]
    6 ~> [bit0, bit1, bit1]
    [1, 2] ~> [bit1, cons, bit0, bit1, cons]
    [[], [1, 2]] ~> [Cons, bit1, cons, bit0, bit1, cons, Cons]

The four stacks are `main`, `rev`, `aux`, `stack`. In normal mode, `main` contains the input to the
current program (a `list ℕ`) and `stack` contains data (a `list (list ℕ)`) associated to the
current continuation, and in `ret` mode `main` contains the value that is being passed to the
continuation and `stack` contains the data for the continuation. The `rev` and `aux` stacks are
usually empty; `rev` is used to store reversed data when e.g. moving a value from one stack to
another, while `aux` is used as a temporary for a `main`/`stack` swap that happens during `cons₁`
evaluation.

The only local store we need is `option Γ'`, which stores the result of the last pop
operation. (Most of our working data are natural numbers, which are too large to fit in the local
store.)

The continuations from the previous section are data-carrying, containing all the values that have
been computed and are awaiting other arguments. In order to have only a finite number of
continuations appear in the program so that they can be used in machine states, we separate the
data part (anything with type `list ℕ`) from the `cont` type, producing a `cont'` type that lacks
this information. The data is kept on the `stack` stack.

Because we want to have subroutines for e.g. moving an entire stack to another place, we use an
infinite inductive type `Λ'` so that we can execute a program and then return to do something else
without having to define too many different kinds of intermediate states. (We must nevertheless
prove that only finitely many labels are accessible.) The labels are:

* `move p k₁ k₂ q`: move elements from stack `k₁` to `k₂` while `p` holds of the value being moved.
  The last element, that fails `p`, is placed in neither stack but left in the local store.
  At the end of the operation, `k₂` will have the elements of `k₁` in reverse order. Then do `q`.
* `clear p k q`: delete elements from stack `k` until `p` is true. Like `move`, the last element is
  left in the local storage. Then do `q`.
* `copy q`: Move all elements from `rev` to both `main` and `stack` (in reverse order),
  then do `q`. That is, it takes `(a, b, c, d)` to `(b.reverse ++ a, [], c, b.reverse ++ d)`.
* `push k f q`: push `f s`, where `s` is the local store, to stack `k`, then do `q`. This is a
  duplicate of the `push` instruction that is part of the TM2 model, but by having a subroutine
  just for this purpose we can build up programs to execute inside a `goto` statement, where we
  have the flexibility to be general recursive.
* `read (f : option Γ' → Λ')`: go to state `f s` where `s` is the local store. Again this is only
  here for convenience.
* `succ q`: perform a successor operation. Assuming `[n]` is encoded on `main` before,
  `[n+1]` will be on main after. This implements successor for binary natural numbers.
* `pred q₁ q₂`: perform a predecessor operation or `case` statement. If `[]` is encoded on
  `main` before, then we transition to `q₁` with `[]` on main; if `(0 :: v)` is on `main` before
  then `v` will be on `main` after and we transition to `q₁`; and if `(n+1 :: v)` is on `main`
  before then `n :: v` will be on `main` after and we transition to `q₂`.
* `ret k`: call continuation `k`. Each continuation has its own interpretation of the data in
  `stack` and sets up the data for the next continuation.
  * `ret (cons₁ fs k)`: `v :: k_data` on `stack` and `ns` on `main`, and the next step expects
    `v` on `main` and `ns :: k_data` on `stack`. So we have to do a little dance here with six
    reverse-moves using the `aux` stack to perform a three-point swap, each of which involves two
    reversals.
  * `ret (cons₂ k)`: `ns :: k_data` is on `stack` and `v` is on `main`, and we have to put
    `ns.head :: v` on `main` and `k_data` on `stack`. This is done using the `head` subroutine.
  * `ret (fix f k)`: This stores no data, so we just check if `main` starts with `0` and
    if so, remove it and call `k`, otherwise `clear` the first value and call `f`.
  * `ret halt`: the stack is empty, and `main` has the output. Do nothing and halt.

In addition to these basic states, we define some additional subroutines that are used in the
above:
* `push'`, `peek'`, `pop'` are special versions of the builtins that use the local store to supply
  inputs and outputs.
* `unrev`: special case `move ff rev main` to move everything from `rev` back to `main`. Used as a
  cleanup operation in several functions.
* `move_excl p k₁ k₂ q`: same as `move` but pushes the last value read back onto the source stack.
* `move₂ p k₁ k₂ q`: double `move`, so that the result comes out in the right order at the target
  stack. Implemented as `move_excl p k rev; move ff rev k₂`. Assumes that neither `k₁` nor `k₂` is
  `rev` and `rev` is initially empty.
* `head k q`: get the first natural number from stack `k` and reverse-move it to `rev`, then clear
  the rest of the list at `k` and then `unrev` to reverse-move the head value to `main`. This is
  used with `k = main` to implement regular `head`, i.e. if `v` is on `main` before then `[v.head]`
  will be on `main` after; and also with `k = stack` for the `cons` operation, which has `v` on
  `main` and `ns :: k_data` on `stack`, and results in `k_data` on `stack` and `ns.head :: v` on
  `main`.
* `tr_normal` is the main entry point, defining states that perform a given `code` computation.
  It mostly just dispatches to functions written above.

The main theorem of this section is `tr_eval`, which asserts that for each that for each code `c`,
the state `init c v` steps to `halt v'` in finitely many steps if and only if
`code.eval c v = some v'`.
-/


namespace PartrecToTM2

section 

open ToPartrec

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler decidable_eq
/-- The alphabet for the stacks in the program. `bit0` and `bit1` are used to represent `ℕ` values
as lists of binary digits, `cons` is used to separate `list ℕ` values, and `Cons` is used to
separate `list (list ℕ)` values. See the section documentation. -/
@[derive #["[", expr decidable_eq, ",", expr inhabited, ",", expr fintype, "]"]]
inductive Γ'
| Cons
| cons
| bit0
| bit1

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler decidable_eq
/-- The four stacks used by the program. `main` is used to store the input value in `tr_normal`
mode and the output value in `Λ'.ret` mode, while `stack` is used to keep all the data for the
continuations. `rev` is used to store reversed lists when transferring values between stacks, and
`aux` is only used once in `cons₁`. See the section documentation. -/
@[derive #["[", expr decidable_eq, ",", expr inhabited, "]"]]
inductive K'
| main
| rev
| aux
| stack

open K'

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler decidable_eq
/-- Continuations as in `to_partrec.cont` but with the data removed. This is done because we want
the set of all continuations in the program to be finite (so that it can ultimately be encoded into
the finite state machine of a Turing machine), but a continuation can handle a potentially infinite
number of data values during execution. -/ @[derive #["[", expr decidable_eq, ",", expr inhabited, "]"]] inductive cont'
| halt
| cons₁ : code → cont' → cont'
| cons₂ : cont' → cont'
| comp : code → cont' → cont'
| fix : code → cont' → cont'

/-- The set of program positions. We make extensive use of inductive types here to let us describe
"subroutines"; for example `clear p k q` is a program that clears stack `k`, then does `q` where
`q` is another label. In order to prevent this from resulting in an infinite number of distinct
accessible states, we are careful to be non-recursive (although loops are okay). See the section
documentation for a description of all the programs. -/
inductive Λ'
  | move (p : Γ' → Bool) (k₁ k₂ : K') (q : Λ')
  | clear (p : Γ' → Bool) (k : K') (q : Λ')
  | copy (q : Λ')
  | push (k : K') (s : Option Γ' → Option Γ') (q : Λ')
  | read (f : Option Γ' → Λ')
  | succ (q : Λ')
  | pred (q₁ q₂ : Λ')
  | ret (k : cont')

instance  : Inhabited Λ' :=
  ⟨Λ'.ret cont'.halt⟩

instance  : DecidableEq Λ' :=
  fun a b =>
    by 
      induction a generalizing b <;>
        cases b <;>
          try 
            apply Decidable.isFalse 
            rintro ⟨⟨⟩⟩
            done 
      all_goals 
        exact
          decidableOfIff' _
            (by 
              simp [Function.funext_iffₓ])

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler inhabited
/-- The type of TM2 statements used by this machine. -/ @[derive #[expr inhabited]] def stmt' :=
TM2.stmt (λ _ : K', Γ') Λ' (option Γ')

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler inhabited
/-- The type of TM2 configurations used by this machine. -/ @[derive #[expr inhabited]] def cfg' :=
TM2.cfg (λ _ : K', Γ') Λ' (option Γ')

open TM2.Stmt

/-- A predicate that detects the end of a natural number, either `Γ'.cons` or `Γ'.Cons` (or
implicitly the end of the list), for use in predicate-taking functions like `move` and `clear`. -/
def nat_end : Γ' → Bool
| Γ'.Cons => tt
| Γ'.cons => tt
| _ => ff

/-- Pop a value from the stack and place the result in local store. -/
@[simp]
def pop' (k : K') : stmt' → stmt' :=
  pop k fun x v => v

/-- Peek a value from the stack and place the result in local store. -/
@[simp]
def peek' (k : K') : stmt' → stmt' :=
  peek k fun x v => v

/-- Push the value in the local store to the given stack. -/
@[simp]
def push' (k : K') : stmt' → stmt' :=
  push k fun x => x.iget

/-- Move everything from the `rev` stack to the `main` stack (reversed). -/
def unrev :=
  Λ'.move (fun _ => ff) rev main

/-- Move elements from `k₁` to `k₂` while `p` holds, with the last element being left on `k₁`. -/
def move_excl p k₁ k₂ q :=
  Λ'.move p k₁ k₂$ Λ'.push k₁ id q

/-- Move elements from `k₁` to `k₂` without reversion, by performing a double move via the `rev`
stack. -/
def move₂ p k₁ k₂ q :=
  move_excl p k₁ rev$ Λ'.move (fun _ => ff) rev k₂ q

/-- Assuming `tr_list v` is on the front of stack `k`, remove it, and push `v.head` onto `main`.
See the section documentation. -/
def head (k : K') (q : Λ') : Λ' :=
  Λ'.move nat_end k rev$
    (Λ'.push rev fun _ => some Γ'.cons)$
      Λ'.read$ fun s => (if s = some Γ'.Cons then id else Λ'.clear (fun x => x = Γ'.Cons) k)$ unrev q

/-- The program that evaluates code `c` with continuation `k`. This expects an initial state where
`tr_list v` is on `main`, `tr_cont_stack k` is on `stack`, and `aux` and `rev` are empty.
See the section documentation for details. -/
@[simp]
def tr_normal : code → cont' → Λ'
| code.zero', k => (Λ'.push main fun _ => some Γ'.cons)$ Λ'.ret k
| code.succ, k => head main$ Λ'.succ$ Λ'.ret k
| code.tail, k => Λ'.clear nat_end main$ Λ'.ret k
| code.cons f fs, k =>
  (Λ'.push stack fun _ => some Γ'.Cons)$ Λ'.move (fun _ => ff) main rev$ Λ'.copy$ tr_normal f (cont'.cons₁ fs k)
| code.comp f g, k => tr_normal g (cont'.comp f k)
| code.case f g, k => Λ'.pred (tr_normal f k) (tr_normal g k)
| code.fix f, k => tr_normal f (cont'.fix f k)

/-- The main program. See the section documentation for details. -/
@[simp]
def tr : Λ' → stmt'
| Λ'.move p k₁ k₂ q =>
  pop' k₁$ branch (fun s => s.elim tt p) (goto$ fun _ => q) (push' k₂$ goto$ fun _ => Λ'.move p k₁ k₂ q)
| Λ'.push k f q => branch (fun s => (f s).isSome) ((push k fun s => (f s).iget)$ goto$ fun _ => q) (goto$ fun _ => q)
| Λ'.read q => goto q
| Λ'.clear p k q => pop' k$ branch (fun s => s.elim tt p) (goto$ fun _ => q) (goto$ fun _ => Λ'.clear p k q)
| Λ'.copy q => pop' rev$ branch Option.isSome (push' main$ push' stack$ goto$ fun _ => Λ'.copy q) (goto$ fun _ => q)
| Λ'.succ q =>
  pop' main$
    branch (fun s => s = some Γ'.bit1) ((push rev fun _ => Γ'.bit0)$ goto$ fun _ => Λ'.succ q)$
      branch (fun s => s = some Γ'.cons)
        ((push main fun _ => Γ'.cons)$ (push main fun _ => Γ'.bit1)$ goto$ fun _ => unrev q)
        ((push main fun _ => Γ'.bit1)$ goto$ fun _ => unrev q)
| Λ'.pred q₁ q₂ =>
  pop' main$
    branch (fun s => s = some Γ'.bit0) ((push rev fun _ => Γ'.bit1)$ goto$ fun _ => Λ'.pred q₁ q₂)$
      branch (fun s => nat_end s.iget) (goto$ fun _ => q₁)
        (peek' main$
          branch (fun s => nat_end s.iget) (goto$ fun _ => unrev q₂)
            ((push rev fun _ => Γ'.bit0)$ goto$ fun _ => unrev q₂))
| Λ'.ret (cont'.cons₁ fs k) =>
  goto$
    fun _ =>
      move₂ (fun _ => ff) main aux$
        move₂ (fun s => s = Γ'.Cons) stack main$ move₂ (fun _ => ff) aux stack$ tr_normal fs (cont'.cons₂ k)
| Λ'.ret (cont'.cons₂ k) => goto$ fun _ => head stack$ Λ'.ret k
| Λ'.ret (cont'.comp f k) => goto$ fun _ => tr_normal f k
| Λ'.ret (cont'.fix f k) =>
  pop' main$ goto$ fun s => cond (nat_end s.iget) (Λ'.ret k)$ Λ'.clear nat_end main$ tr_normal f (cont'.fix f k)
| Λ'.ret cont'.halt => (load fun _ => none)$ halt

/-- Translating a `cont` continuation to a `cont'` continuation simply entails dropping all the
data. This data is instead encoded in `tr_cont_stack` in the configuration. -/
def tr_cont : cont → cont'
| cont.halt => cont'.halt
| cont.cons₁ c _ k => cont'.cons₁ c (tr_cont k)
| cont.cons₂ _ k => cont'.cons₂ (tr_cont k)
| cont.comp c k => cont'.comp c (tr_cont k)
| cont.fix c k => cont'.fix c (tr_cont k)

/-- We use `pos_num` to define the translation of binary natural numbers. A natural number is
represented as a little-endian list of `bit0` and `bit1` elements:

    1 = [bit1]
    2 = [bit0, bit1]
    3 = [bit1, bit1]
    4 = [bit0, bit0, bit1]

In particular, this representation guarantees no trailing `bit0`'s at the end of the list. -/
def tr_pos_num : PosNum → List Γ'
| PosNum.one => [Γ'.bit1]
| PosNum.bit0 n => Γ'.bit0 :: tr_pos_num n
| PosNum.bit1 n => Γ'.bit1 :: tr_pos_num n

/-- We use `num` to define the translation of binary natural numbers. Positive numbers are
translated using `tr_pos_num`, and `tr_num 0 = []`. So there are never any trailing `bit0`'s in
a translated `num`.

    0 = []
    1 = [bit1]
    2 = [bit0, bit1]
    3 = [bit1, bit1]
    4 = [bit0, bit0, bit1]
-/
def tr_num : Num → List Γ'
| Num.zero => []
| Num.pos n => tr_pos_num n

/-- Because we use binary encoding, we define `tr_nat` in terms of `tr_num`, using `num`, which are
binary natural numbers. (We could also use `nat.binary_rec_on`, but `num` and `pos_num` make for
easy inductions.) -/
def tr_nat (n : ℕ) : List Γ' :=
  tr_num n

@[simp]
theorem tr_nat_zero : tr_nat 0 = [] :=
  rfl

/-- Lists are translated with a `cons` after each encoded number.
For example:

    [] = []
    [0] = [cons]
    [1] = [bit1, cons]
    [6, 0] = [bit0, bit1, bit1, cons, cons]
-/
@[simp]
def tr_list : List ℕ → List Γ'
| [] => []
| n :: ns => tr_nat n ++ Γ'.cons :: tr_list ns

/-- Lists of lists are translated with a `Cons` after each encoded list.
For example:

    [] = []
    [[]] = [Cons]
    [[], []] = [Cons, Cons]
    [[0]] = [cons, Cons]
    [[1, 2], [0]] = [bit1, cons, bit0, bit1, cons, Cons, cons, Cons]
-/
@[simp]
def tr_llist : List (List ℕ) → List Γ'
| [] => []
| l :: ls => tr_list l ++ Γ'.Cons :: tr_llist ls

/-- The data part of a continuation is a list of lists, which is encoded on the `stack` stack
using `tr_llist`. -/
@[simp]
def cont_stack : cont → List (List ℕ)
| cont.halt => []
| cont.cons₁ _ ns k => ns :: cont_stack k
| cont.cons₂ ns k => ns :: cont_stack k
| cont.comp _ k => cont_stack k
| cont.fix _ k => cont_stack k

/-- The data part of a continuation is a list of lists, which is encoded on the `stack` stack
using `tr_llist`. -/
def tr_cont_stack (k : cont) :=
  tr_llist (cont_stack k)

/-- This is the nondependent eliminator for `K'`, but we use it specifically here in order to
represent the stack data as four lists rather than as a function `K' → list Γ'`, because this makes
rewrites easier. The theorems `K'.elim_update_main` et. al. show how such a function is updated
after an `update` to one of the components. -/
@[simp]
def K'.elim (a b c d : List Γ') : K' → List Γ'
| K'.main => a
| K'.rev => b
| K'.aux => c
| K'.stack => d

@[simp]
theorem K'.elim_update_main {a b c d a'} : update (K'.elim a b c d) main a' = K'.elim a' b c d :=
  by 
    funext x <;> cases x <;> rfl

@[simp]
theorem K'.elim_update_rev {a b c d b'} : update (K'.elim a b c d) rev b' = K'.elim a b' c d :=
  by 
    funext x <;> cases x <;> rfl

@[simp]
theorem K'.elim_update_aux {a b c d c'} : update (K'.elim a b c d) aux c' = K'.elim a b c' d :=
  by 
    funext x <;> cases x <;> rfl

@[simp]
theorem K'.elim_update_stack {a b c d d'} : update (K'.elim a b c d) stack d' = K'.elim a b c d' :=
  by 
    funext x <;> cases x <;> rfl

/-- The halting state corresponding to a `list ℕ` output value. -/
def halt (v : List ℕ) : cfg' :=
  ⟨none, none, K'.elim (tr_list v) [] [] []⟩

/-- The `cfg` states map to `cfg'` states almost one to one, except that in normal operation the
local store contains an arbitrary garbage value. To make the final theorem cleaner we explicitly
clear it in the halt state so that there is exactly one configuration corresponding to output `v`.
-/
def tr_cfg : cfg → cfg' → Prop
| cfg.ret k v, c' => ∃ s, c' = ⟨some (Λ'.ret (tr_cont k)), s, K'.elim (tr_list v) [] [] (tr_cont_stack k)⟩
| cfg.halt v, c' => c' = halt v

/-- This could be a general list definition, but it is also somewhat specialized to this
application. `split_at_pred p L` will search `L` for the first element satisfying `p`.
If it is found, say `L = l₁ ++ a :: l₂` where `a` satisfies `p` but `l₁` does not, then it returns
`(l₁, some a, l₂)`. Otherwise, if there is no such element, it returns `(L, none, [])`. -/
def split_at_pred {α} (p : α → Bool) : List α → List α × Option α × List α
| [] => ([], none, [])
| a :: as =>
  cond (p a) ([], some a, as)$
    let ⟨l₁, o, l₂⟩ := split_at_pred as
    ⟨a :: l₁, o, l₂⟩

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem split_at_pred_eq
{α}
(p : α → bool) : ∀
L
l₁
o
l₂, ∀
x «expr ∈ » l₁, «expr = »(p x, ff) → option.elim o «expr ∧ »(«expr = »(L, l₁), «expr = »(l₂, «expr[ , ]»([]))) (λ
 a, «expr ∧ »(«expr = »(p a, tt), «expr = »(L, «expr ++ »(l₁, [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](a, l₂))))) → «expr = »(split_at_pred p L, (l₁, o, l₂))
| «expr[ , ]»([]), _, none, _, _, ⟨rfl, rfl⟩ := rfl
| «expr[ , ]»([]), l₁, some o, l₂, h₁, ⟨h₂, h₃⟩ := by simp [] [] [] [] [] ["at", ident h₃]; contradiction
| [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](a, L), l₁, o, l₂, h₁, h₂ := begin
  rw ["[", expr split_at_pred, "]"] [],
  have [ident IH] [] [":=", expr split_at_pred_eq L],
  cases [expr o] [],
  { cases [expr l₁] ["with", ident a', ident l₁]; rcases [expr h₂, "with", "⟨", "⟨", "⟩", ",", ident rfl, "⟩"],
    rw ["[", expr h₁ a (or.inl rfl), ",", expr cond, ",", expr IH L none «expr[ , ]»([]) _ ⟨rfl, rfl⟩, "]"] [],
    refl,
    exact [expr λ x h, h₁ x (or.inr h)] },
  { cases [expr l₁] ["with", ident a', ident l₁]; rcases [expr h₂, "with", "⟨", ident h₂, ",", "⟨", "⟩", "⟩"],
    { rw ["[", expr h₂, ",", expr cond, "]"] [] },
    rw ["[", expr h₁ a (or.inl rfl), ",", expr cond, ",", expr IH l₁ (some o) l₂ _ ⟨h₂, _⟩, "]"] []; try { refl },
    exact [expr λ x h, h₁ x (or.inr h)] }
end

theorem split_at_pred_ff {α} (L : List α) : split_at_pred (fun _ => ff) L = (L, none, []) :=
  split_at_pred_eq _ _ _ _ _ (fun _ _ => rfl) ⟨rfl, rfl⟩

theorem move_ok {p k₁ k₂ q s L₁ o L₂} {S : K' → List Γ'} (h₁ : k₁ ≠ k₂) (e : split_at_pred p (S k₁) = (L₁, o, L₂)) :
  reaches₁ (TM2.step tr) ⟨some (Λ'.move p k₁ k₂ q), s, S⟩
    ⟨some q, o, update (update S k₁ L₂) k₂ (L₁.reverse_core (S k₂))⟩ :=
  by 
    induction' L₁ with a L₁ IH generalizing S s
    ·
      rw [(_ : [].reverseCore _ = _), Function.update_eq_self]
      swap
      ·
        rw [Function.update_noteq h₁.symm]
        rfl 
      refine' trans_gen.head' rfl _ 
      simp 
      cases' S k₁ with a Sk
      ·
        cases e 
        rfl 
      simp [split_at_pred] at e⊢
      cases p a <;> simp  at e⊢
      ·
        revert e 
        rcases split_at_pred p Sk with ⟨_, _, _⟩
        rintro ⟨⟩
      ·
        simp only [e]
    ·
      refine' trans_gen.head rfl _ 
      simp 
      cases' e₁ : S k₁ with a' Sk <;> rw [e₁, split_at_pred] at e
      ·
        cases e 
      cases e₂ : p a' <;> simp only [e₂, cond] at e 
      swap
      ·
        cases e 
      rcases e₃ : split_at_pred p Sk with ⟨_, _, _⟩
      rw [e₃, split_at_pred] at e 
      cases e 
      simp [e₂]
      convert @IH (update (update S k₁ Sk) k₂ (a :: S k₂)) _ _ using 2 <;>
        simp [Function.update_noteq, h₁, h₁.symm, e₃, List.reverseCore]
      simp [Function.update_comm h₁.symm]

theorem unrev_ok {q s} {S : K' → List Γ'} :
  reaches₁ (TM2.step tr) ⟨some (unrev q), s, S⟩
    ⟨some q, none, update (update S rev []) main (List.reverseCore (S rev) (S main))⟩ :=
  move_ok
      (by 
        decide)$
    split_at_pred_ff _

theorem move₂_ok {p k₁ k₂ q s L₁ o L₂} {S : K' → List Γ'} (h₁ : k₁ ≠ rev ∧ k₂ ≠ rev ∧ k₁ ≠ k₂) (h₂ : S rev = [])
  (e : split_at_pred p (S k₁) = (L₁, o, L₂)) :
  reaches₁ (TM2.step tr) ⟨some (move₂ p k₁ k₂ q), s, S⟩
    ⟨some q, none, update (update S k₁ (o.elim id List.cons L₂)) k₂ (L₁ ++ S k₂)⟩ :=
  by 
    refine' (move_ok h₁.1 e).trans (trans_gen.head rfl _)
    cases o <;> simp only [Option.elim, tr, id.def]
    ·
      convert move_ok h₁.2.1.symm (split_at_pred_ff _) using 2
      simp only [Function.update_comm h₁.1, Function.update_idem]
      rw
        [show update S rev [] = S by 
          rw [←h₂, Function.update_eq_self]]
      simp only [Function.update_noteq h₁.2.2.symm, Function.update_noteq h₁.2.1, Function.update_noteq h₁.1.symm,
        List.reverse_core_eq, h₂, Function.update_same, List.append_nil, List.reverse_reverse]
    ·
      convert move_ok h₁.2.1.symm (split_at_pred_ff _) using 2
      simp only [h₂, Function.update_comm h₁.1, List.reverse_core_eq, Function.update_same, List.append_nil,
        Function.update_idem]
      rw
        [show update S rev [] = S by 
          rw [←h₂, Function.update_eq_self]]
      simp only [Function.update_noteq h₁.1.symm, Function.update_noteq h₁.2.2.symm, Function.update_noteq h₁.2.1,
        Function.update_same, List.reverse_reverse]

theorem clear_ok {p k q s L₁ o L₂} {S : K' → List Γ'} (e : split_at_pred p (S k) = (L₁, o, L₂)) :
  reaches₁ (TM2.step tr) ⟨some (Λ'.clear p k q), s, S⟩ ⟨some q, o, update S k L₂⟩ :=
  by 
    induction' L₁ with a L₁ IH generalizing S s
    ·
      refine' trans_gen.head' rfl _ 
      simp 
      cases' S k with a Sk
      ·
        cases e 
        rfl 
      simp [split_at_pred] at e⊢
      cases p a <;> simp  at e⊢
      ·
        revert e 
        rcases split_at_pred p Sk with ⟨_, _, _⟩
        rintro ⟨⟩
      ·
        simp only [e]
    ·
      refine' trans_gen.head rfl _ 
      simp 
      cases' e₁ : S k with a' Sk <;> rw [e₁, split_at_pred] at e
      ·
        cases e 
      cases e₂ : p a' <;> simp only [e₂, cond] at e 
      swap
      ·
        cases e 
      rcases e₃ : split_at_pred p Sk with ⟨_, _, _⟩
      rw [e₃, split_at_pred] at e 
      cases e 
      simp [e₂]
      convert @IH (update S k Sk) _ _ using 2 <;> simp [e₃]

theorem copy_ok q s a b c d :
  reaches₁ (TM2.step tr) ⟨some (Λ'.copy q), s, K'.elim a b c d⟩
    ⟨some q, none, K'.elim (List.reverseCore b a) [] c (List.reverseCore b d)⟩ :=
  by 
    induction' b with x b IH generalizing a d s
    ·
      refine' trans_gen.single _ 
      simp 
      rfl 
    refine' trans_gen.head rfl _ 
    simp 
    exact IH _ _ _

theorem tr_pos_num_nat_end : ∀ n x (_ : x ∈ tr_pos_num n), nat_end x = ff
| PosNum.one, _, Or.inl rfl => rfl
| PosNum.bit0 n, _, Or.inl rfl => rfl
| PosNum.bit0 n, _, Or.inr h => tr_pos_num_nat_end n _ h
| PosNum.bit1 n, _, Or.inl rfl => rfl
| PosNum.bit1 n, _, Or.inr h => tr_pos_num_nat_end n _ h

theorem tr_num_nat_end : ∀ n x (_ : x ∈ tr_num n), nat_end x = ff
| Num.pos n, x, h => tr_pos_num_nat_end n x h

theorem tr_nat_nat_end n : ∀ x (_ : x ∈ tr_nat n), nat_end x = ff :=
  tr_num_nat_end _

theorem tr_list_ne_Cons : ∀ l x (_ : x ∈ tr_list l), x ≠ Γ'.Cons
| a :: l, x, h =>
  by 
    simp [tr_list] at h 
    obtain h | rfl | h := h
    ·
      rintro rfl 
      cases tr_nat_nat_end _ _ h
    ·
      rintro ⟨⟩
    ·
      exact tr_list_ne_Cons l _ h

theorem head_main_ok {q s L} {c d : List Γ'} :
  reaches₁ (TM2.step tr) ⟨some (head main q), s, K'.elim (tr_list L) [] c d⟩
    ⟨some q, none, K'.elim (tr_list [L.head]) [] c d⟩ :=
  by 
    let o : Option Γ' := List.casesOn L none fun _ _ => some Γ'.cons 
    refine'
      (move_ok
            (by 
              decide)
            (split_at_pred_eq _ _ (tr_nat L.head) o (tr_list L.tail) (tr_nat_nat_end _) _)).trans
        (trans_gen.head rfl (trans_gen.head rfl _))
    ·
      cases L <;> exact ⟨rfl, rfl⟩
    simp
      [show o ≠ some Γ'.Cons by 
        cases L <;> rintro ⟨⟩]
    refine' (clear_ok (split_at_pred_eq _ _ _ none [] _ ⟨rfl, rfl⟩)).trans _
    ·
      exact fun x h => to_bool_ff (tr_list_ne_Cons _ _ h)
    convert unrev_ok 
    simp [List.reverse_core_eq]

theorem head_stack_ok {q s L₁ L₂ L₃} :
  reaches₁ (TM2.step tr) ⟨some (head stack q), s, K'.elim (tr_list L₁) [] [] (tr_list L₂ ++ Γ'.Cons :: L₃)⟩
    ⟨some q, none, K'.elim (tr_list (L₂.head :: L₁)) [] [] L₃⟩ :=
  by 
    cases' L₂ with a L₂
    ·
      refine'
        trans_gen.trans
          (move_ok
            (by 
              decide)
            (split_at_pred_eq _ _ [] (some Γ'.Cons) L₃
              (by 
                rintro _ ⟨⟩)
              ⟨rfl, rfl⟩))
          (trans_gen.head rfl (trans_gen.head rfl _))
      convert unrev_ok 
      simp 
      rfl
    ·
      refine'
        trans_gen.trans
          (move_ok
            (by 
              decide)
            (split_at_pred_eq _ _ (tr_nat a) (some Γ'.cons) (tr_list L₂ ++ Γ'.Cons :: L₃) (tr_nat_nat_end _)
              ⟨rfl,
                by 
                  simp ⟩))
          (trans_gen.head rfl (trans_gen.head rfl _))
      simp 
      refine'
        trans_gen.trans
          (clear_ok
            (split_at_pred_eq _ _ (tr_list L₂) (some Γ'.Cons) L₃ (fun x h => to_bool_ff (tr_list_ne_Cons _ _ h))
              ⟨rfl,
                by 
                  simp ⟩))
          _ 
      convert unrev_ok 
      simp [List.reverse_core_eq]

theorem succ_ok {q s n} {c d : List Γ'} :
  reaches₁ (TM2.step tr) ⟨some (Λ'.succ q), s, K'.elim (tr_list [n]) [] c d⟩
    ⟨some q, none, K'.elim (tr_list [n.succ]) [] c d⟩ :=
  by 
    simp [tr_nat, Num.add_one]
    cases' (n : Num) with a
    ·
      refine' trans_gen.head rfl _ 
      simp 
      rw [if_neg]
      swap 
      rintro ⟨⟩
      rw [if_pos]
      swap 
      rfl 
      convert unrev_ok 
      simp 
      rfl 
    simp [Num.succ, tr_num, Num.succ']
    suffices  :
      ∀ l₁,
        ∃ l₁' l₂' s',
          List.reverseCore l₁ (tr_pos_num a.succ) = List.reverseCore l₁' l₂' ∧
            reaches₁ (TM2.step tr) ⟨some q.succ, s, K'.elim (tr_pos_num a ++ [Γ'.cons]) l₁ c d⟩
              ⟨some (unrev q), s', K'.elim (l₂' ++ [Γ'.cons]) l₁' c d⟩
    ·
      obtain ⟨l₁', l₂', s', e, h⟩ := this []
      simp [List.reverseCore] at e 
      refine' h.trans _ 
      convert unrev_ok using 2
      simp [e, List.reverse_core_eq]
    induction' a with m IH m IH generalizing s <;> intro l₁
    ·
      refine' ⟨Γ'.bit0 :: l₁, [Γ'.bit1], some Γ'.cons, rfl, trans_gen.head rfl (trans_gen.single _)⟩
      simp [tr_pos_num]
    ·
      obtain ⟨l₁', l₂', s', e, h⟩ := IH (Γ'.bit0 :: l₁)
      refine' ⟨l₁', l₂', s', e, trans_gen.head _ h⟩
      swap 
      simp [PosNum.succ, tr_pos_num]
    ·
      refine' ⟨l₁, _, some Γ'.bit0, rfl, trans_gen.single _⟩
      simp 
      rfl

theorem pred_ok q₁ q₂ s v (c d : List Γ') :
  ∃ s',
    reaches₁ (TM2.step tr) ⟨some (Λ'.pred q₁ q₂), s, K'.elim (tr_list v) [] c d⟩
      (v.head.elim ⟨some q₁, s', K'.elim (tr_list v.tail) [] c d⟩
        fun n _ => ⟨some q₂, s', K'.elim (tr_list (n :: v.tail)) [] c d⟩) :=
  by 
    rcases v with (_ | ⟨_ | n, v⟩)
    ·
      refine' ⟨none, trans_gen.single _⟩
      simp 
      rfl
    ·
      refine' ⟨some Γ'.cons, trans_gen.single _⟩
      simp 
      rfl 
    refine' ⟨none, _⟩
    simp [tr_nat, Num.add_one, Num.succ, tr_num]
    cases' (n : Num) with a
    ·
      simp [tr_pos_num, tr_num, show num.zero.succ' = PosNum.one from rfl]
      refine' trans_gen.head rfl _ 
      convert unrev_ok 
      simp 
      rfl 
    simp [tr_num, Num.succ']
    suffices  :
      ∀ l₁,
        ∃ l₁' l₂' s',
          List.reverseCore l₁ (tr_pos_num a) = List.reverseCore l₁' l₂' ∧
            reaches₁ (TM2.step tr) ⟨some (q₁.pred q₂), s, K'.elim (tr_pos_num a.succ ++ Γ'.cons :: tr_list v) l₁ c d⟩
              ⟨some (unrev q₂), s', K'.elim (l₂' ++ Γ'.cons :: tr_list v) l₁' c d⟩
    ·
      obtain ⟨l₁', l₂', s', e, h⟩ := this []
      simp [List.reverseCore] at e 
      refine' h.trans _ 
      convert unrev_ok using 2
      simp [e, List.reverse_core_eq]
    induction' a with m IH m IH generalizing s <;> intro l₁
    ·
      refine' ⟨Γ'.bit1 :: l₁, [], some Γ'.cons, rfl, trans_gen.head rfl (trans_gen.single _)⟩
      simp [tr_pos_num, show pos_num.one.succ = pos_num.one.bit0 from rfl]
      rfl
    ·
      obtain ⟨l₁', l₂', s', e, h⟩ := IH (some Γ'.bit0) (Γ'.bit1 :: l₁)
      refine' ⟨l₁', l₂', s', e, trans_gen.head _ h⟩
      simp 
      rfl
    ·
      obtain ⟨a, l, e, h⟩ : ∃ a l, tr_pos_num m = a :: l ∧ nat_end a = ff
      ·
        cases m <;> refine' ⟨_, _, rfl, rfl⟩
      refine' ⟨Γ'.bit0 :: l₁, _, some a, rfl, trans_gen.single _⟩
      simp [tr_pos_num, PosNum.succ, e, h, nat_end,
        show some Γ'.bit1 ≠ some Γ'.bit0 from
          by 
            decide]

theorem tr_normal_respects c k v s :
  ∃ b₂,
    tr_cfg (step_normal c k v) b₂ ∧
      reaches₁ (TM2.step tr) ⟨some (tr_normal c (tr_cont k)), s, K'.elim (tr_list v) [] [] (tr_cont_stack k)⟩ b₂ :=
  by 
    induction c generalizing k v s 
    case zero' => 
      refine' ⟨_, ⟨s, rfl⟩, trans_gen.single _⟩
      simp 
    case succ => 
      refine' ⟨_, ⟨none, rfl⟩, head_main_ok.trans succ_ok⟩
    case tail => 
      let o : Option Γ' := List.casesOn v none fun _ _ => some Γ'.cons 
      refine' ⟨_, ⟨o, rfl⟩, _⟩
      convert clear_ok _ 
      simp 
      swap 
      refine' split_at_pred_eq _ _ (tr_nat v.head) _ _ (tr_nat_nat_end _) _ 
      cases v <;> exact ⟨rfl, rfl⟩
    case cons f fs IHf IHfs => 
      obtain ⟨c, h₁, h₂⟩ := IHf (cont.cons₁ fs v k) v none 
      refine'
        ⟨c, h₁,
          trans_gen.head rfl$
            (move_ok
                  (by 
                    decide)
                  (split_at_pred_ff _)).trans
              _⟩
      simp [step_normal]
      refine' (copy_ok _ none [] (tr_list v).reverse _ _).trans _ 
      convert h₂ using 2
      simp [List.reverse_core_eq, tr_cont_stack]
    case comp f g IHf IHg => 
      exact IHg (cont.comp f k) v s 
    case case f g IHf IHg => 
      rw [step_normal]
      obtain ⟨s', h⟩ := pred_ok _ _ s v _ _ 
      cases' v.head with n
      ·
        obtain ⟨c, h₁, h₂⟩ := IHf k _ s' 
        exact ⟨_, h₁, h.trans h₂⟩
      ·
        obtain ⟨c, h₁, h₂⟩ := IHg k _ s' 
        exact ⟨_, h₁, h.trans h₂⟩
    case fix f IH => 
      apply IH

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_ret_respects
(k
 v
 s) : «expr∃ , »((b₂), «expr ∧ »(tr_cfg (step_ret k v) b₂, reaches₁ (TM2.step tr) ⟨some (Λ'.ret (tr_cont k)), s, K'.elim (tr_list v) «expr[ , ]»([]) «expr[ , ]»([]) (tr_cont_stack k)⟩ b₂)) :=
begin
  induction [expr k] [] [] ["generalizing", ident v, ident s],
  case [ident halt] { exact [expr ⟨_, rfl, trans_gen.single rfl⟩] },
  case [ident cons₁, ":", ident fs, ident as, ident k, ident IH] { obtain ["⟨", ident s', ",", ident h₁, ",", ident h₂, "⟩", ":=", expr tr_normal_respects fs (cont.cons₂ v k) as none],
    refine [expr ⟨s', h₁, trans_gen.head rfl _⟩],
    simp [] [] [] [] [] [],
    refine [expr (move₂_ok exprdec_trivial() _ (split_at_pred_ff _)).trans _],
    { refl },
    simp [] [] [] [] [] [],
    refine [expr (move₂_ok exprdec_trivial() _ _).trans _],
    swap 4,
    { refl },
    swap 4,
    { exact [expr split_at_pred_eq _ _ _ (some Γ'.Cons) _ (λ x h, to_bool_ff (tr_list_ne_Cons _ _ h)) ⟨rfl, rfl⟩] },
    refine [expr (move₂_ok exprdec_trivial() _ (split_at_pred_ff _)).trans _],
    { refl },
    simp [] [] [] [] [] [],
    exact [expr h₂] },
  case [ident cons₂, ":", ident ns, ident k, ident IH] { obtain ["⟨", ident c, ",", ident h₁, ",", ident h₂, "⟩", ":=", expr IH [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](ns.head, v) none],
    exact [expr ⟨c, h₁, «expr $ »(trans_gen.head rfl, head_stack_ok.trans h₂)⟩] },
  case [ident comp, ":", ident f, ident k, ident IH] { obtain ["⟨", ident s', ",", ident h₁, ",", ident h₂, "⟩", ":=", expr tr_normal_respects f k v s],
    exact [expr ⟨_, h₁, trans_gen.head rfl h₂⟩] },
  case [ident fix, ":", ident f, ident k, ident IH] { rw ["[", expr step_ret, "]"] [],
    have [] [":", expr if «expr = »(v.head, 0) then «expr ∧ »(«expr = »(nat_end (tr_list v).head'.iget, tt), «expr = »((tr_list v).tail, tr_list v.tail)) else «expr ∧ »(«expr = »(nat_end (tr_list v).head'.iget, ff), «expr = »((tr_list v).tail, «expr ++ »((tr_nat v.head).tail, [«expr :: »/«expr :: »/«expr :: »/«expr :: »/«expr :: »](Γ'.cons, tr_list v.tail))))] [],
    { cases [expr v] ["with", ident n],
      { exact [expr ⟨rfl, rfl⟩] },
      cases [expr n] [],
      { exact [expr ⟨rfl, rfl⟩] },
      rw ["[", expr tr_list, ",", expr list.head, ",", expr tr_nat, ",", expr nat.cast_succ, ",", expr num.add_one, ",", expr num.succ, ",", expr list.tail, "]"] [],
      cases [expr (n : num).succ'] []; exact [expr ⟨rfl, rfl⟩] },
    by_cases [expr «expr = »(v.head, 0)]; simp [] [] [] ["[", expr h, "]"] [] ["at", ident this, "⊢"],
    { obtain ["⟨", ident c, ",", ident h₁, ",", ident h₂, "⟩", ":=", expr IH v.tail (tr_list v).head'],
      refine [expr ⟨c, h₁, trans_gen.head rfl _⟩],
      simp [] [] [] ["[", expr tr_cont, ",", expr tr_cont_stack, ",", expr this, "]"] [] [],
      exact [expr h₂] },
    { obtain ["⟨", ident s', ",", ident h₁, ",", ident h₂, "⟩", ":=", expr tr_normal_respects f (cont.fix f k) v.tail (some Γ'.cons)],
      refine [expr ⟨_, h₁, «expr $ »(trans_gen.head rfl, trans_gen.trans _ h₂)⟩],
      swap 3,
      simp [] [] [] ["[", expr tr_cont, ",", expr this.1, "]"] [] [],
      convert [] [expr clear_ok (split_at_pred_eq _ _ (tr_nat v.head).tail (some Γ'.cons) _ _ _)] ["using", 2],
      { simp [] [] [] [] [] [] },
      { exact [expr λ x h, tr_nat_nat_end _ _ (list.tail_subset _ h)] },
      { exact [expr ⟨rfl, this.2⟩] } } }
end

theorem tr_respects : respects step (TM2.step tr) tr_cfg
| cfg.ret k v, _, ⟨s, rfl⟩ => tr_ret_respects _ _ _
| cfg.halt v, _, rfl => rfl

/-- The initial state, evaluating function `c` on input `v`. -/
def init (c : code) (v : List ℕ) : cfg' :=
  ⟨some (tr_normal c cont'.halt), none, K'.elim (tr_list v) [] [] []⟩

theorem tr_init c v : ∃ b, tr_cfg (step_normal c cont.halt v) b ∧ reaches₁ (TM2.step tr) (init c v) b :=
  tr_normal_respects _ _ _ _

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_eval (c v) : «expr = »(eval (TM2.step tr) (init c v), «expr <$> »(halt, code.eval c v)) :=
begin
  obtain ["⟨", ident i, ",", ident h₁, ",", ident h₂, "⟩", ":=", expr tr_init c v],
  refine [expr part.ext (λ x, _)],
  rw ["[", expr reaches_eval h₂.to_refl, "]"] [],
  simp [] [] [] [] [] [],
  refine [expr ⟨λ h, _, _⟩],
  { obtain ["⟨", ident c, ",", ident hc₁, ",", ident hc₂, "⟩", ":=", expr tr_eval_rev tr_respects h₁ h],
    simp [] [] [] ["[", expr step_normal_eval, "]"] [] ["at", ident hc₂],
    obtain ["⟨", ident v', ",", ident hv, ",", ident rfl, "⟩", ":=", expr hc₂],
    exact [expr ⟨_, hv, hc₁.symm⟩] },
  { rintro ["⟨", ident v', ",", ident hv, ",", ident rfl, "⟩"],
    have [] [] [":=", expr tr_eval tr_respects h₁],
    simp [] [] [] ["[", expr step_normal_eval, "]"] [] ["at", ident this],
    obtain ["⟨", "_", ",", "⟨", "⟩", ",", ident h, "⟩", ":=", expr this _ hv rfl],
    exact [expr h] }
end

/-- The set of machine states reachable via downward label jumps, discounting jumps via `ret`. -/
def tr_stmts₁ : Λ' → Finset Λ'
| Q@(Λ'.move p k₁ k₂ q) => insert Q$ tr_stmts₁ q
| Q@(Λ'.push k f q) => insert Q$ tr_stmts₁ q
| Q@(Λ'.read q) => insert Q$ Finset.univ.bUnion$ fun s => tr_stmts₁ (q s)
| Q@(Λ'.clear p k q) => insert Q$ tr_stmts₁ q
| Q@(Λ'.copy q) => insert Q$ tr_stmts₁ q
| Q@(Λ'.succ q) => insert Q$ insert (unrev q)$ tr_stmts₁ q
| Q@(Λ'.pred q₁ q₂) => insert Q$ tr_stmts₁ q₁ ∪ insert (unrev q₂) (tr_stmts₁ q₂)
| Q@(Λ'.ret k) => {Q}

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_stmts₁_trans {q q'} : «expr ∈ »(q', tr_stmts₁ q) → «expr ⊆ »(tr_stmts₁ q', tr_stmts₁ q) :=
begin
  induction [expr q] [] [] []; simp [] [] ["only"] ["[", expr tr_stmts₁, ",", expr finset.mem_insert, ",", expr finset.mem_union, ",", expr or_imp_distrib, ",", expr finset.mem_singleton, ",", expr finset.subset.refl, ",", expr imp_true_iff, ",", expr true_and, "]"] [] [] { contextual := tt },
  iterate [4] { exact [expr λ h, finset.subset.trans (q_ih h) (finset.subset_insert _ _)] },
  { simp [] [] [] [] [] [],
    intros [ident s, ident h, ident x, ident h'],
    simp [] [] [] [] [] [],
    exact [expr or.inr ⟨_, q_ih s h h'⟩] },
  { split,
    { rintro [ident rfl],
      apply [expr finset.subset_insert] },
    { intros [ident h, ident x, ident h'],
      simp [] [] [] [] [] [],
      exact [expr or.inr «expr $ »(or.inr, q_ih h h')] } },
  { refine [expr ⟨λ h x h', _, λ h x h', _, λ h x h', _⟩]; simp [] [] [] [] [] [],
    { exact [expr or.inr «expr $ »(or.inr, «expr $ »(or.inl, q_ih_q₁ h h'))] },
    { cases [expr finset.mem_insert.1 h'] ["with", ident h', ident h']; simp [] [] [] ["[", expr h', ",", expr unrev, "]"] [] [] },
    { exact [expr or.inr «expr $ »(or.inr, «expr $ »(or.inr, q_ih_q₂ h h'))] } }
end

theorem tr_stmts₁_self q : q ∈ tr_stmts₁ q :=
  by 
    induction q <;>
      ·
        first |
          apply Finset.mem_singleton_self|
          apply Finset.mem_insert_self

/-- The (finite!) set of machine states visited during the course of evaluation of `c`,
including the state `ret k` but not any states after that (that is, the states visited while
evaluating `k`). -/
def code_supp' : code → cont' → Finset Λ'
| c@code.zero', k => tr_stmts₁ (tr_normal c k)
| c@code.succ, k => tr_stmts₁ (tr_normal c k)
| c@code.tail, k => tr_stmts₁ (tr_normal c k)
| c@(code.cons f fs), k =>
  tr_stmts₁ (tr_normal c k) ∪
    (code_supp' f (cont'.cons₁ fs k) ∪
      (tr_stmts₁
          (move₂ (fun _ => ff) main aux$
            move₂ (fun s => s = Γ'.Cons) stack main$ move₂ (fun _ => ff) aux stack$ tr_normal fs (cont'.cons₂ k)) ∪
        (code_supp' fs (cont'.cons₂ k) ∪ tr_stmts₁ (head stack$ Λ'.ret k))))
| c@(code.comp f g), k =>
  tr_stmts₁ (tr_normal c k) ∪ (code_supp' g (cont'.comp f k) ∪ (tr_stmts₁ (tr_normal f k) ∪ code_supp' f k))
| c@(code.case f g), k => tr_stmts₁ (tr_normal c k) ∪ (code_supp' f k ∪ code_supp' g k)
| c@(code.fix f), k =>
  tr_stmts₁ (tr_normal c k) ∪
    (code_supp' f (cont'.fix f k) ∪ (tr_stmts₁ (Λ'.clear nat_end main$ tr_normal f (cont'.fix f k)) ∪ {Λ'.ret k}))

@[simp]
theorem code_supp'_self c k : tr_stmts₁ (tr_normal c k) ⊆ code_supp' c k :=
  by 
    cases c <;>
      first |
        rfl|
        exact Finset.subset_union_left _ _

/-- The (finite!) set of machine states visited during the course of evaluation of a continuation
`k`, not including the initial state `ret k`. -/
def cont_supp : cont' → Finset Λ'
| cont'.cons₁ fs k =>
  tr_stmts₁
      (move₂ (fun _ => ff) main aux$
        move₂ (fun s => s = Γ'.Cons) stack main$ move₂ (fun _ => ff) aux stack$ tr_normal fs (cont'.cons₂ k)) ∪
    (code_supp' fs (cont'.cons₂ k) ∪ (tr_stmts₁ (head stack$ Λ'.ret k) ∪ cont_supp k))
| cont'.cons₂ k => tr_stmts₁ (head stack$ Λ'.ret k) ∪ cont_supp k
| cont'.comp f k => code_supp' f k ∪ cont_supp k
| cont'.fix f k => code_supp' (code.fix f) k ∪ cont_supp k
| cont'.halt => ∅

/-- The (finite!) set of machine states visited during the course of evaluation of `c` in
continuation `k`. This is actually closed under forward simulation (see `tr_supports`), and the
existence of this set means that the machine constructed in this section is in fact a proper
Turing machine, with a finite set of states. -/
def code_supp (c : code) (k : cont') : Finset Λ' :=
  code_supp' c k ∪ cont_supp k

@[simp]
theorem code_supp_self c k : tr_stmts₁ (tr_normal c k) ⊆ code_supp c k :=
  Finset.Subset.trans (code_supp'_self _ _) (Finset.subset_union_left _ _)

@[simp]
theorem code_supp_zero k : code_supp code.zero' k = tr_stmts₁ (tr_normal code.zero' k) ∪ cont_supp k :=
  rfl

@[simp]
theorem code_supp_succ k : code_supp code.succ k = tr_stmts₁ (tr_normal code.succ k) ∪ cont_supp k :=
  rfl

@[simp]
theorem code_supp_tail k : code_supp code.tail k = tr_stmts₁ (tr_normal code.tail k) ∪ cont_supp k :=
  rfl

@[simp]
theorem code_supp_cons f fs k :
  code_supp (code.cons f fs) k = tr_stmts₁ (tr_normal (code.cons f fs) k) ∪ code_supp f (cont'.cons₁ fs k) :=
  by 
    simp [code_supp, code_supp', cont_supp, Finset.union_assoc]

@[simp]
theorem code_supp_comp f g k :
  code_supp (code.comp f g) k = tr_stmts₁ (tr_normal (code.comp f g) k) ∪ code_supp g (cont'.comp f k) :=
  by 
    simp [code_supp, code_supp', cont_supp, Finset.union_assoc]
    rw [←Finset.union_assoc _ _ (cont_supp k), Finset.union_eq_right_iff_subset.2 (code_supp'_self _ _)]

@[simp]
theorem code_supp_case f g k :
  code_supp (code.case f g) k = tr_stmts₁ (tr_normal (code.case f g) k) ∪ (code_supp f k ∪ code_supp g k) :=
  by 
    simp [code_supp, code_supp', cont_supp, Finset.union_assoc, Finset.union_left_comm]

@[simp]
theorem code_supp_fix f k :
  code_supp (code.fix f) k = tr_stmts₁ (tr_normal (code.fix f) k) ∪ code_supp f (cont'.fix f k) :=
  by 
    simp [code_supp, code_supp', cont_supp, Finset.union_assoc, Finset.union_left_comm, Finset.union_left_idem]

@[simp]
theorem cont_supp_cons₁ fs k :
  cont_supp (cont'.cons₁ fs k) =
    tr_stmts₁
        (move₂ (fun _ => ff) main aux$
          move₂ (fun s => s = Γ'.Cons) stack main$ move₂ (fun _ => ff) aux stack$ tr_normal fs (cont'.cons₂ k)) ∪
      code_supp fs (cont'.cons₂ k) :=
  by 
    simp [code_supp, code_supp', cont_supp, Finset.union_assoc]

@[simp]
theorem cont_supp_cons₂ k : cont_supp (cont'.cons₂ k) = tr_stmts₁ (head stack$ Λ'.ret k) ∪ cont_supp k :=
  rfl

@[simp]
theorem cont_supp_comp f k : cont_supp (cont'.comp f k) = code_supp f k :=
  rfl

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem cont_supp_fix (f k) : «expr = »(cont_supp (cont'.fix f k), code_supp f (cont'.fix f k)) :=
by simp [] [] [] ["[", expr code_supp, ",", expr code_supp', ",", expr cont_supp, ",", expr finset.union_assoc, ",", expr finset.subset_iff, "]"] [] [] { contextual := tt }

@[simp]
theorem cont_supp_halt : cont_supp cont'.halt = ∅ :=
  rfl

/-- The statement `Λ'.supports S q` means that `cont_supp k ⊆ S` for any `ret k`
reachable from `q`.
(This is a technical condition used in the proof that the machine is supported.) -/
def Λ'.supports (S : Finset Λ') : Λ' → Prop
| Q@(Λ'.move p k₁ k₂ q) => Λ'.supports q
| Q@(Λ'.push k f q) => Λ'.supports q
| Q@(Λ'.read q) => ∀ s, Λ'.supports (q s)
| Q@(Λ'.clear p k q) => Λ'.supports q
| Q@(Λ'.copy q) => Λ'.supports q
| Q@(Λ'.succ q) => Λ'.supports q
| Q@(Λ'.pred q₁ q₂) => Λ'.supports q₁ ∧ Λ'.supports q₂
| Q@(Λ'.ret k) => cont_supp k ⊆ S

/-- A shorthand for the predicate that we are proving in the main theorems `tr_stmts₁_supports`,
`code_supp'_supports`, `cont_supp_supports`, `code_supp_supports`. The set `S` is fixed throughout
the proof, and denotes the full set of states in the machine, while `K` is a subset that we are
currently proving a property about. The predicate asserts that every state in `K` is closed in `S`
under forward simulation, i.e. stepping forward through evaluation starting from any state in `K`
stays entirely within `S`. -/
def supports (K S : Finset Λ') :=
  ∀ q (_ : q ∈ K), TM2.supports_stmt S (tr q)

theorem supports_insert {K S q} : supports (insert q K) S ↔ TM2.supports_stmt S (tr q) ∧ supports K S :=
  by 
    simp [supports]

theorem supports_singleton {S q} : supports {q} S ↔ TM2.supports_stmt S (tr q) :=
  by 
    simp [supports]

theorem supports_union {K₁ K₂ S} : supports (K₁ ∪ K₂) S ↔ supports K₁ S ∧ supports K₂ S :=
  by 
    simp [supports, or_imp_distrib, forall_and_distrib]

theorem supports_bUnion {K : Option Γ' → Finset Λ'} {S} : supports (Finset.univ.bUnion K) S ↔ ∀ a, supports (K a) S :=
  by 
    simp [supports] <;> apply forall_swap

theorem head_supports {S k q} (H : (q : Λ').Supports S) : (head k q).Supports S :=
  fun _ =>
    by 
      dsimp only <;> splitIfs <;> exact H

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem ret_supports {S k} (H₁ : «expr ⊆ »(cont_supp k, S)) : TM2.supports_stmt S (tr (Λ'.ret k)) :=
begin
  have [ident W] [] [":=", expr λ {q}, tr_stmts₁_self q],
  cases [expr k] [],
  case [ident halt] { trivial },
  case [ident cons₁] { rw ["[", expr cont_supp_cons₁, ",", expr finset.union_subset_iff, "]"] ["at", ident H₁],
    exact [expr λ _, H₁.1 W] },
  case [ident cons₂] { rw ["[", expr cont_supp_cons₂, ",", expr finset.union_subset_iff, "]"] ["at", ident H₁],
    exact [expr λ _, H₁.1 W] },
  case [ident comp] { rw ["[", expr cont_supp_comp, "]"] ["at", ident H₁],
    exact [expr λ _, H₁ (code_supp_self _ _ W)] },
  case [ident fix] { rw ["[", expr cont_supp_fix, "]"] ["at", ident H₁],
    have [ident L] [] [":=", expr @finset.mem_union_left],
    have [ident R] [] [":=", expr @finset.mem_union_right],
    intro [ident s],
    dsimp ["only"] [] [] [],
    cases [expr nat_end s.iget] [],
    { refine [expr H₁ «expr $ »(R _, «expr $ »(L _, «expr $ »(R _, «expr $ »(R _, L _ W))))] },
    { exact [expr H₁ «expr $ »(R _, «expr $ »(L _, «expr $ »(R _, «expr $ »(R _, «expr $ »(R _, finset.mem_singleton_self _)))))] } }
end

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_stmts₁_supports
{S q}
(H₁ : (q : Λ').supports S)
(HS₁ : «expr ⊆ »(tr_stmts₁ q, S)) : supports (tr_stmts₁ q) S :=
begin
  have [ident W] [] [":=", expr λ {q}, tr_stmts₁_self q],
  induction [expr q] [] [] []; simp [] [] [] ["[", expr tr_stmts₁, "]"] [] ["at", ident HS₁, "⊢"],
  any_goals { cases [expr finset.insert_subset.1 HS₁] ["with", ident h₁, ident h₂],
    id { have [ident h₃] [] [":=", expr h₂ W] } <|> try { simp [] [] [] ["[", expr finset.subset_iff, "]"] [] ["at", ident h₂] } },
  { exact [expr supports_insert.2 ⟨⟨λ _, h₃, λ _, h₁⟩, q_ih H₁ h₂⟩] },
  { exact [expr supports_insert.2 ⟨⟨λ _, h₃, λ _, h₁⟩, q_ih H₁ h₂⟩] },
  { exact [expr supports_insert.2 ⟨⟨λ _, h₁, λ _, h₃⟩, q_ih H₁ h₂⟩] },
  { exact [expr supports_insert.2 ⟨⟨λ _, h₃, λ _, h₃⟩, q_ih H₁ h₂⟩] },
  { refine [expr supports_insert.2 ⟨λ _, h₂ _ W, _⟩],
    exact [expr supports_bUnion.2 (λ _, q_ih _ (H₁ _) (λ _ h, h₂ _ h))] },
  { refine [expr supports_insert.2 ⟨⟨λ _, h₁, λ _, h₂.1, λ _, h₂.1⟩, _⟩],
    exact [expr supports_insert.2 ⟨⟨λ _, h₂.2 _ W, λ _, h₂.1⟩, q_ih H₁ h₂.2⟩] },
  { refine [expr supports_insert.2 ⟨⟨λ _, h₁, λ _, h₂.2 _ (or.inl W), λ _, h₂.1, λ _, h₂.1⟩, _⟩],
    refine [expr supports_insert.2 ⟨⟨λ _, h₂.2 _ (or.inr W), λ _, h₂.1⟩, _⟩],
    refine [expr supports_union.2 ⟨_, _⟩],
    { exact [expr q_ih_q₁ H₁.1 (λ _ h, h₂.2 _ (or.inl h))] },
    { exact [expr q_ih_q₂ H₁.2 (λ _ h, h₂.2 _ (or.inr h))] } },
  { exact [expr supports_singleton.2 (ret_supports H₁)] }
end

theorem tr_stmts₁_supports' {S q K} (H₁ : (q : Λ').Supports S) (H₂ : tr_stmts₁ q ∪ K ⊆ S) (H₃ : K ⊆ S → supports K S) :
  supports (tr_stmts₁ q ∪ K) S :=
  by 
    simp [Finset.union_subset_iff] at H₂ 
    exact supports_union.2 ⟨tr_stmts₁_supports H₁ H₂.1, H₃ H₂.2⟩

theorem tr_normal_supports {S c k} (Hk : code_supp c k ⊆ S) : (tr_normal c k).Supports S :=
  by 
    induction c generalizing k <;> simp [Λ'.supports, head]
    case zero' => 
      exact Finset.union_subset_right Hk 
    case succ => 
      intro 
      splitIfs <;> exact Finset.union_subset_right Hk 
    case tail => 
      exact Finset.union_subset_right Hk 
    case cons f fs IHf IHfs => 
      apply IHf 
      rw [code_supp_cons] at Hk 
      exact Finset.union_subset_right Hk 
    case comp f g IHf IHg => 
      apply IHg 
      rw [code_supp_comp] at Hk 
      exact Finset.union_subset_right Hk 
    case case f g IHf IHg => 
      simp only [code_supp_case, Finset.union_subset_iff] at Hk 
      exact ⟨IHf Hk.2.1, IHg Hk.2.2⟩
    case fix f IHf => 
      apply IHf 
      rw [code_supp_fix] at Hk 
      exact Finset.union_subset_right Hk

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem code_supp'_supports {S c k} (H : «expr ⊆ »(code_supp c k, S)) : supports (code_supp' c k) S :=
begin
  induction [expr c] [] [] ["generalizing", ident k],
  iterate [3] { exact [expr tr_stmts₁_supports (tr_normal_supports H) (finset.subset.trans (code_supp_self _ _) H)] },
  case [ident cons, ":", ident f, ident fs, ident IHf, ident IHfs] { have [ident H'] [] [":=", expr H],
    simp [] [] ["only"] ["[", expr code_supp_cons, ",", expr finset.union_subset_iff, "]"] [] ["at", ident H'],
    refine [expr tr_stmts₁_supports' (tr_normal_supports H) (finset.union_subset_left H) (λ h, _)],
    refine [expr supports_union.2 ⟨IHf H'.2, _⟩],
    refine [expr tr_stmts₁_supports' (tr_normal_supports _) (finset.union_subset_right h) (λ h, _)],
    { simp [] [] ["only"] ["[", expr code_supp, ",", expr finset.union_subset_iff, ",", expr cont_supp, "]"] [] ["at", ident h, ident H, "⊢"],
      exact [expr ⟨h.2.2.1, h.2.2.2, H.2⟩] },
    refine [expr supports_union.2 ⟨IHfs _, _⟩],
    { rw ["[", expr code_supp, ",", expr cont_supp_cons₁, "]"] ["at", ident H'],
      exact [expr finset.union_subset_right (finset.union_subset_right H'.2)] },
    exact [expr tr_stmts₁_supports «expr $ »(head_supports, finset.union_subset_right H) (finset.union_subset_right h)] },
  case [ident comp, ":", ident f, ident g, ident IHf, ident IHg] { have [ident H'] [] [":=", expr H],
    rw ["[", expr code_supp_comp, "]"] ["at", ident H'],
    have [ident H'] [] [":=", expr finset.union_subset_right H'],
    refine [expr tr_stmts₁_supports' (tr_normal_supports H) (finset.union_subset_left H) (λ h, _)],
    refine [expr supports_union.2 ⟨IHg H', _⟩],
    refine [expr tr_stmts₁_supports' (tr_normal_supports _) (finset.union_subset_right h) (λ h, _)],
    { simp [] [] ["only"] ["[", expr code_supp', ",", expr code_supp, ",", expr finset.union_subset_iff, ",", expr cont_supp, "]"] [] ["at", ident h, ident H, "⊢"],
      exact [expr ⟨h.2.2, H.2⟩] },
    exact [expr IHf (finset.union_subset_right H')] },
  case [ident case, ":", ident f, ident g, ident IHf, ident IHg] { have [ident H'] [] [":=", expr H],
    simp [] [] ["only"] ["[", expr code_supp_case, ",", expr finset.union_subset_iff, "]"] [] ["at", ident H'],
    refine [expr tr_stmts₁_supports' (tr_normal_supports H) (finset.union_subset_left H) (λ h, _)],
    exact [expr supports_union.2 ⟨IHf H'.2.1, IHg H'.2.2⟩] },
  case [ident fix, ":", ident f, ident IHf] { have [ident H'] [] [":=", expr H],
    simp [] [] ["only"] ["[", expr code_supp_fix, ",", expr finset.union_subset_iff, "]"] [] ["at", ident H'],
    refine [expr tr_stmts₁_supports' (tr_normal_supports H) (finset.union_subset_left H) (λ h, _)],
    refine [expr supports_union.2 ⟨IHf H'.2, _⟩],
    refine [expr tr_stmts₁_supports' (tr_normal_supports _) (finset.union_subset_right h) (λ h, _)],
    { simp [] [] ["only"] ["[", expr code_supp', ",", expr code_supp, ",", expr finset.union_subset_iff, ",", expr cont_supp, ",", expr tr_stmts₁, ",", expr finset.insert_subset, "]"] [] ["at", ident h, ident H, "⊢"],
      exact [expr ⟨h.1, ⟨H.1.1, h⟩, H.2⟩] },
    exact [expr supports_singleton.2 «expr $ »(ret_supports, finset.union_subset_right H)] }
end

-- error in Computability.TmToPartrec: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem cont_supp_supports {S k} (H : «expr ⊆ »(cont_supp k, S)) : supports (cont_supp k) S :=
begin
  induction [expr k] [] [] [],
  { simp [] [] [] ["[", expr cont_supp_halt, ",", expr supports, "]"] [] [] },
  case [ident cons₁, ":", ident f, ident k, ident IH] { have [ident H₁] [] [":=", expr H],
    rw ["[", expr cont_supp_cons₁, "]"] ["at", ident H₁],
    have [ident H₂] [] [":=", expr finset.union_subset_right H₁],
    refine [expr tr_stmts₁_supports' (tr_normal_supports H₂) H₁ (λ h, _)],
    refine [expr supports_union.2 ⟨code_supp'_supports H₂, _⟩],
    simp [] [] ["only"] ["[", expr code_supp, ",", expr cont_supp_cons₂, ",", expr finset.union_subset_iff, "]"] [] ["at", ident H₂],
    exact [expr tr_stmts₁_supports' (head_supports H₂.2.2) (finset.union_subset_right h) IH] },
  case [ident cons₂, ":", ident k, ident IH] { have [ident H'] [] [":=", expr H],
    rw ["[", expr cont_supp_cons₂, "]"] ["at", ident H'],
    exact [expr tr_stmts₁_supports' «expr $ »(head_supports, finset.union_subset_right H') H' IH] },
  case [ident comp, ":", ident f, ident k, ident IH] { have [ident H'] [] [":=", expr H],
    rw ["[", expr cont_supp_comp, "]"] ["at", ident H'],
    have [ident H₂] [] [":=", expr finset.union_subset_right H'],
    exact [expr supports_union.2 ⟨code_supp'_supports H', IH H₂⟩] },
  case [ident fix, ":", ident f, ident k, ident IH] { rw [expr cont_supp] ["at", ident H],
    exact [expr supports_union.2 ⟨code_supp'_supports H, IH (finset.union_subset_right H)⟩] }
end

theorem code_supp_supports {S c k} (H : code_supp c k ⊆ S) : supports (code_supp c k) S :=
  supports_union.2 ⟨code_supp'_supports H, cont_supp_supports (Finset.union_subset_right H)⟩

/-- The set `code_supp c k` is a finite set that witnesses the effective finiteness of the `tr`
Turing machine. Starting from the initial state `tr_normal c k`, forward simulation uses only
states in `code_supp c k`, so this is a finite state machine. Even though the underlying type of
state labels `Λ'` is infinite, for a given partial recursive function `c` and continuation `k`,
only finitely many states are accessed, corresponding roughly to subterms of `c`. -/
theorem tr_supports c k : @TM2.supports _ _ _ _ _ ⟨tr_normal c k⟩ tr (code_supp c k) :=
  ⟨code_supp_self _ _ (tr_stmts₁_self _), fun l' => code_supp_supports (Finset.Subset.refl _) _⟩

end 

end PartrecToTM2

end Turing

