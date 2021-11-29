import Mathbin.Data.Prod 
import Mathbin.Data.Subtype 
import Mathbin.Logic.Function.Basic 
import Mathbin.Logic.Unique

/-!
# Nontrivial types

A type is *nontrivial* if it contains at least two elements. This is useful in particular for rings
(where it is equivalent to the fact that zero is different from one) and for vector spaces
(where it is equivalent to the fact that the dimension is positive).

We introduce a typeclass `nontrivial` formalizing this property.
-/


variable{α : Type _}{β : Type _}

open_locale Classical

/-- Predicate typeclass for expressing that a type is not reduced to a single element. In rings,
this is equivalent to `0 ≠ 1`. In vector spaces, this is equivalent to positive dimension. -/
class Nontrivial(α : Type _) : Prop where 
  exists_pair_ne : ∃ x y : α, x ≠ y

theorem nontrivial_iff : Nontrivial α ↔ ∃ x y : α, x ≠ y :=
  ⟨fun h => h.exists_pair_ne, fun h => ⟨h⟩⟩

theorem exists_pair_ne (α : Type _) [Nontrivial α] : ∃ x y : α, x ≠ y :=
  Nontrivial.exists_pair_ne

protected theorem Decidable.exists_ne [Nontrivial α] [DecidableEq α] (x : α) : ∃ y, y ≠ x :=
  by 
    rcases exists_pair_ne α with ⟨y, y', h⟩
    byCases' hx : x = y
    ·
      rw [←hx] at h 
      exact ⟨y', h.symm⟩
    ·
      exact ⟨y, Ne.symm hx⟩

theorem exists_ne [Nontrivial α] (x : α) : ∃ y, y ≠ x :=
  by 
    classical <;> exact Decidable.exists_ne x

theorem nontrivial_of_ne (x y : α) (h : x ≠ y) : Nontrivial α :=
  ⟨⟨x, y, h⟩⟩

theorem nontrivial_of_lt [Preorderₓ α] (x y : α) (h : x < y) : Nontrivial α :=
  ⟨⟨x, y, ne_of_ltₓ h⟩⟩

theorem nontrivial_iff_exists_ne (x : α) : Nontrivial α ↔ ∃ y, y ≠ x :=
  ⟨fun h => @exists_ne α h x, fun ⟨y, hy⟩ => nontrivial_of_ne _ _ hy⟩

theorem Subtype.nontrivial_iff_exists_ne (p : α → Prop) (x : Subtype p) :
  Nontrivial (Subtype p) ↔ ∃ (y : α)(hy : p y), y ≠ x :=
  by 
    simp only [nontrivial_iff_exists_ne x, Subtype.exists, Ne.def, Subtype.ext_iff, Subtype.coe_mk]

instance  : Nontrivial Prop :=
  ⟨⟨True, False, true_ne_false⟩⟩

/--
See Note [lower instance priority]

Note that since this and `nonempty_of_inhabited` are the most "obvious" way to find a nonempty
instance if no direct instance can be found, we give this a higher priority than the usual `100`.
-/
instance (priority := 500)Nontrivial.to_nonempty [Nontrivial α] : Nonempty α :=
  let ⟨x, _⟩ := exists_pair_ne α
  ⟨x⟩

attribute [instance] nonempty_of_inhabited

-- error in Logic.Nontrivial: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- An inhabited type is either nontrivial, or has a unique element. -/
noncomputable
def nontrivial_psum_unique (α : Type*) [inhabited α] : psum (nontrivial α) (unique α) :=
if h : nontrivial α then psum.inl h else psum.inr { default := default α,
  uniq := λ x : α, begin
    change [expr «expr = »(x, default α)] [] [],
    contrapose ["!"] [ident h],
    use ["[", expr x, ",", expr default α, "]"]
  end }

theorem subsingleton_iff : Subsingleton α ↔ ∀ (x y : α), x = y :=
  ⟨by 
      intros h 
      exact Subsingleton.elimₓ,
    fun h => ⟨h⟩⟩

theorem not_nontrivial_iff_subsingleton : ¬Nontrivial α ↔ Subsingleton α :=
  by 
    rw [nontrivial_iff, subsingleton_iff]
    pushNeg 
    rfl

theorem not_subsingleton α [h : Nontrivial α] : ¬Subsingleton α :=
  let ⟨⟨x, y, hxy⟩⟩ := h 
  fun ⟨h'⟩ => hxy$ h' x y

/-- A type is either a subsingleton or nontrivial. -/
theorem subsingleton_or_nontrivial (α : Type _) : Subsingleton α ∨ Nontrivial α :=
  by 
    rw [←not_nontrivial_iff_subsingleton, or_comm]
    exact Classical.em _

theorem false_of_nontrivial_of_subsingleton (α : Type _) [Nontrivial α] [Subsingleton α] : False :=
  let ⟨x, y, h⟩ := exists_pair_ne α 
  h$ Subsingleton.elimₓ x y

instance Option.nontrivial [Nonempty α] : Nontrivial (Option α) :=
  by 
    inhabit α 
    use none, some (default α)

/-- Pushforward a `nontrivial` instance along an injective function. -/
protected theorem Function.Injective.nontrivial [Nontrivial α] {f : α → β} (hf : Function.Injective f) : Nontrivial β :=
  let ⟨x, y, h⟩ := exists_pair_ne α
  ⟨⟨f x, f y, hf.ne h⟩⟩

-- error in Logic.Nontrivial: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Pullback a `nontrivial` instance along a surjective function. -/
protected
theorem function.surjective.nontrivial [nontrivial β] {f : α → β} (hf : function.surjective f) : nontrivial α :=
begin
  rcases [expr exists_pair_ne β, "with", "⟨", ident x, ",", ident y, ",", ident h, "⟩"],
  rcases [expr hf x, "with", "⟨", ident x', ",", ident hx', "⟩"],
  rcases [expr hf y, "with", "⟨", ident y', ",", ident hy', "⟩"],
  have [] [":", expr «expr ≠ »(x', y')] [],
  by { contrapose ["!"] [ident h],
    rw ["[", "<-", expr hx', ",", "<-", expr hy', ",", expr h, "]"] [] },
  exact [expr ⟨⟨x', y', this⟩⟩]
end

/-- An injective function from a nontrivial type has an argument at
which it does not take a given value. -/
protected theorem Function.Injective.exists_ne [Nontrivial α] {f : α → β} (hf : Function.Injective f) (y : β) :
  ∃ x, f x ≠ y :=
  by 
    rcases exists_pair_ne α with ⟨x₁, x₂, hx⟩
    byCases' h : f x₂ = y
    ·
      exact ⟨x₁, (hf.ne_iff' h).2 hx⟩
    ·
      exact ⟨x₂, h⟩

instance nontrivial_prod_right [Nonempty α] [Nontrivial β] : Nontrivial (α × β) :=
  Prod.snd_surjective.Nontrivial

instance nontrivial_prod_left [Nontrivial α] [Nonempty β] : Nontrivial (α × β) :=
  Prod.fst_surjectiveₓ.Nontrivial

namespace Pi

variable{I : Type _}{f : I → Type _}

/-- A pi type is nontrivial if it's nonempty everywhere and nontrivial somewhere. -/
theorem nontrivial_at (i' : I) [inst : ∀ i, Nonempty (f i)] [Nontrivial (f i')] : Nontrivial (∀ (i : I), f i) :=
  by 
    classical <;> exact (Function.update_injective (fun i => Classical.choice (inst i)) i').Nontrivial

/--
As a convenience, provide an instance automatically if `(f (default I))` is nontrivial.

If a different index has the non-trivial type, then use `haveI := nontrivial_at that_index`.
-/
instance Nontrivial [Inhabited I] [inst : ∀ i, Nonempty (f i)] [Nontrivial (f (default I))] :
  Nontrivial (∀ (i : I), f i) :=
  nontrivial_at (default I)

end Pi

instance Function.nontrivial [h : Nonempty α] [Nontrivial β] : Nontrivial (α → β) :=
  h.elim$ fun a => Pi.nontrivial_at a

mk_simp_attribute nontriviality := "Simp lemmas for `nontriviality` tactic"

protected theorem Subsingleton.le [Preorderₓ α] [Subsingleton α] (x y : α) : x ≤ y :=
  le_of_eqₓ (Subsingleton.elimₓ x y)

attribute [nontriviality] eq_iff_true_of_subsingleton Subsingleton.le

namespace Tactic

/--
Tries to generate a `nontrivial α` instance by performing case analysis on
`subsingleton_or_nontrivial α`,
attempting to discharge the subsingleton branch using lemmas with `@[nontriviality]` attribute,
including `subsingleton.le` and `eq_iff_true_of_subsingleton`.
-/
unsafe def nontriviality_by_elim (α : expr) (lems : interactive.parse simp_arg_list) : tactic Unit :=
  do 
    let alternative ← to_expr (pquote.1 (subsingleton_or_nontrivial (%%ₓα)))
    let n ← get_unused_name "_inst"
    tactic.cases Alternativeₓ [n, n]
    (solve1$
          do 
            reset_instance_cache 
            apply_instance <|> interactive.simp none none ff lems [`nontriviality] (Interactive.Loc.ns [none])) <|>
        fail f! "Could not prove goal assuming `subsingleton {α }`"
    reset_instance_cache

/--
Tries to generate a `nontrivial α` instance using `nontrivial_of_ne` or `nontrivial_of_lt`
and local hypotheses.
-/
unsafe def nontriviality_by_assumption (α : expr) : tactic Unit :=
  do 
    let n ← get_unused_name "_inst"
    to_expr (pquote.1 (Nontrivial (%%ₓα))) >>= assert n 
    apply_instance <|> sorry 
    reset_instance_cache

end Tactic

namespace Tactic.Interactive

open Tactic

setup_tactic_parser

/--
Attempts to generate a `nontrivial α` hypothesis.

The tactic first looks for an instance using `apply_instance`.

If the goal is an (in)equality, the type `α` is inferred from the goal.
Otherwise, the type needs to be specified in the tactic invocation, as `nontriviality α`.

The `nontriviality` tactic will first look for strict inequalities amongst the hypotheses,
and use these to derive the `nontrivial` instance directly.

Otherwise, it will perform a case split on `subsingleton α ∨ nontrivial α`, and attempt to discharge
the `subsingleton` goal using `simp [lemmas] with nontriviality`, where `[lemmas]` is a list of
additional `simp` lemmas that can be passed to `nontriviality` using the syntax
`nontriviality α using [lemmas]`.

```
example {R : Type} [ordered_ring R] {a : R} (h : 0 < a) : 0 < a :=
begin
  nontriviality, -- There is now a `nontrivial R` hypothesis available.
  assumption,
end
```

```
example {R : Type} [comm_ring R] {r s : R} : r * s = s * r :=
begin
  nontriviality, -- There is now a `nontrivial R` hypothesis available.
  apply mul_comm,
end
```

```
example {R : Type} [ordered_ring R] {a : R} (h : 0 < a) : (2 : ℕ) ∣ 4 :=
begin
  nontriviality R, -- there is now a `nontrivial R` hypothesis available.
  dec_trivial
end
```

```
def myeq {α : Type} (a b : α) : Prop := a = b

example {α : Type} (a b : α) (h : a = b) : myeq a b :=
begin
  success_if_fail { nontriviality α }, -- Fails
  nontriviality α using [myeq], -- There is now a `nontrivial α` hypothesis available
  assumption
end
```
-/
unsafe def nontriviality (t : parse (texpr)?) (lems : parse (tk "using" *> simp_arg_list <|> pure [])) : tactic Unit :=
  do 
    let α ←
      match t with 
        | some α => to_expr α
        | none =>
          (do 
              let t ← mk_mvar 
              let e ← to_expr (pquote.1 (@Eq (%%ₓt) _ _))
              target >>= unify e 
              return t) <|>
            (do 
                let t ← mk_mvar 
                let e ← to_expr (pquote.1 (@LE.le (%%ₓt) _ _ _))
                target >>= unify e 
                return t) <|>
              (do 
                  let t ← mk_mvar 
                  let e ← to_expr (pquote.1 (@Ne (%%ₓt) _ _))
                  target >>= unify e 
                  return t) <|>
                (do 
                    let t ← mk_mvar 
                    let e ← to_expr (pquote.1 (@LT.lt (%%ₓt) _ _ _))
                    target >>= unify e 
                    return t) <|>
                  fail
                    "The goal is not an (in)equality, so you'll need to specify the desired `nontrivial α`\n      instance by invoking `nontriviality α`."
    nontriviality_by_assumption α <|> nontriviality_by_elim α lems

add_tactic_doc
  { Name := "nontriviality", category := DocCategory.tactic, declNames := [`tactic.interactive.nontriviality],
    tags := ["logic", "type class"] }

end Tactic.Interactive

namespace Bool

instance  : Nontrivial Bool :=
  ⟨⟨tt, ff, tt_eq_ff_eq_false⟩⟩

end Bool

