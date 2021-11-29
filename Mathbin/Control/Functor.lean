import Mathbin.Tactic.Ext 
import Mathbin.Tactic.Lint.Default

/-!
# Functors

This module provides additional lemmas, definitions, and instances for `functor`s.

## Main definitions

* `const α` is the functor that sends all types to `α`.
* `add_const α` is `const α` but for when `α` has an additive structure.
* `comp F G` for functors `F` and `G` is the functor composition of `F` and `G`.
* `liftp` and `liftr` respectively lift predicates and relations on a type `α`
  to `F α`.  Terms of `F α` are considered to, in some sense, contain values of type `α`.

## Tags

functor, applicative
-/


attribute [functor_norm] seq_assoc pure_seq_eq_map map_pure seq_map_assoc map_seq

universe u v w

section Functor

variable{F : Type u → Type v}

variable{α β γ : Type u}

variable[Functor F][IsLawfulFunctor F]

theorem Functor.map_id : (· <$> ·) id = (id : F α → F α) :=
  by 
    apply funext <;> apply id_map

theorem Functor.map_comp_map (f : α → β) (g : β → γ) : ((· <$> ·) g ∘ (· <$> ·) f : F α → F γ) = (· <$> ·) (g ∘ f) :=
  by 
    apply funext <;> intro  <;> rw [comp_map]

-- error in Control.Functor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem functor.ext
{F} : ∀
{F1 : functor F}
{F2 : functor F}
[@is_lawful_functor F F1]
[@is_lawful_functor F F2]
(H : ∀ (α β) (f : α → β) (x : F α), «expr = »(@functor.map _ F1 _ _ f x, @functor.map _ F2 _ _ f x)), «expr = »(F1, F2)
| ⟨m, mc⟩, ⟨m', mc'⟩, H1, H2, H := begin
  cases [expr show «expr = »(@m, @m'), by funext [ident α, ident β, ident f, ident x]; apply [expr H]] [],
  congr,
  funext [ident α, ident β],
  have [ident E1] [] [":=", expr @map_const_eq _ ⟨@m, @mc⟩ H1],
  have [ident E2] [] [":=", expr @map_const_eq _ ⟨@m, @mc'⟩ H2],
  exact [expr E1.trans E2.symm]
end

end Functor

/-- Introduce the `id` functor. Incidentally, this is `pure` for
`id` as a `monad` and as an `applicative` functor. -/
def id.mk {α : Sort u} : α → id α :=
  id

namespace Functor

/-- `const α` is the constant functor, mapping every type to `α`. When
`α` has a monoid structure, `const α` has an `applicative` instance.
(If `α` has an additive monoid structure, see `functor.add_const`.) -/
@[nolint unused_arguments]
def const (α : Type _) (β : Type _) :=
  α

/-- `const.mk` is the canonical map `α → const α β` (the identity), and
it can be used as a pattern to extract this value. -/
@[matchPattern]
def const.mk {α β} (x : α) : const α β :=
  x

/-- `const.mk'` is `const.mk` but specialized to map `α` to
`const α punit`, where `punit` is the terminal object in `Type*`. -/
def const.mk' {α} (x : α) : const α PUnit :=
  x

/-- Extract the element of `α` from the `const` functor. -/
def const.run {α β} (x : const α β) : α :=
  x

namespace Const

protected theorem ext {α β} {x y : const α β} (h : x.run = y.run) : x = y :=
  h

/-- The map operation of the `const γ` functor. -/
@[nolint unused_arguments]
protected def map {γ α β} (f : α → β) (x : const γ β) : const γ α :=
  x

instance  {γ} : Functor (const γ) :=
  { map := @const.map γ }

instance  {γ} : IsLawfulFunctor (const γ) :=
  by 
    constructor <;> intros  <;> rfl

instance  {α β} [Inhabited α] : Inhabited (const α β) :=
  ⟨(default _ : α)⟩

end Const

/-- `add_const α` is a synonym for constant functor `const α`, mapping
every type to `α`. When `α` has a additive monoid structure,
`add_const α` has an `applicative` instance. (If `α` has a
multiplicative monoid structure, see `functor.const`.) -/
def add_const (α : Type _) :=
  const α

/-- `add_const.mk` is the canonical map `α → add_const α β`, which is the identity,
where `add_const α β = const α β`. It can be used as a pattern to extract this value. -/
@[matchPattern]
def add_const.mk {α β} (x : α) : add_const α β :=
  x

/-- Extract the element of `α` from the constant functor. -/
def add_const.run {α β} : add_const α β → α :=
  id

instance add_const.functor {γ} : Functor (add_const γ) :=
  @const.functor γ

instance add_const.is_lawful_functor {γ} : IsLawfulFunctor (add_const γ) :=
  @const.is_lawful_functor γ

instance  {α β} [Inhabited α] : Inhabited (add_const α β) :=
  ⟨(default _ : α)⟩

/-- `functor.comp` is a wrapper around `function.comp` for types.
    It prevents Lean's type class resolution mechanism from trying
    a `functor (comp F id)` when `functor F` would do. -/
def comp (F : Type u → Type w) (G : Type v → Type u) (α : Type v) : Type w :=
  F$ G α

/-- Construct a term of `comp F G α` from a term of `F (G α)`, which is the same type.
Can be used as a pattern to extract a term of `F (G α)`. -/
@[matchPattern]
def comp.mk {F : Type u → Type w} {G : Type v → Type u} {α : Type v} (x : F (G α)) : comp F G α :=
  x

/-- Extract a term of `F (G α)` from a term of `comp F G α`, which is the same type. -/
def comp.run {F : Type u → Type w} {G : Type v → Type u} {α : Type v} (x : comp F G α) : F (G α) :=
  x

namespace Comp

variable{F : Type u → Type w}{G : Type v → Type u}

protected theorem ext {α} {x y : comp F G α} : x.run = y.run → x = y :=
  id

instance  {α} [Inhabited (F (G α))] : Inhabited (comp F G α) :=
  ⟨(default _ : F (G α))⟩

variable[Functor F][Functor G]

/-- The map operation for the composition `comp F G` of functors `F` and `G`. -/
protected def map {α β : Type v} (h : α → β) : comp F G α → comp F G β
| comp.mk x => comp.mk ((· <$> ·) h <$> x)

instance  : Functor (comp F G) :=
  { map := @comp.map F G _ _ }

@[functor_norm]
theorem map_mk {α β} (h : α → β) (x : F (G α)) : h <$> comp.mk x = comp.mk ((· <$> ·) h <$> x) :=
  rfl

@[simp]
protected theorem run_map {α β} (h : α → β) (x : comp F G α) : (h <$> x).run = (· <$> ·) h <$> x.run :=
  rfl

variable[IsLawfulFunctor F][IsLawfulFunctor G]

variable{α β γ : Type v}

protected theorem id_map : ∀ (x : comp F G α), comp.map id x = x
| comp.mk x =>
  by 
    simp [comp.map, Functor.map_id]

protected theorem comp_map (g' : α → β) (h : β → γ) :
  ∀ (x : comp F G α), comp.map (h ∘ g') x = comp.map h (comp.map g' x)
| comp.mk x =>
  by 
    simp' [comp.map, Functor.map_comp_map g' h] with functor_norm

instance  : IsLawfulFunctor (comp F G) :=
  { id_map := @comp.id_map F G _ _ _ _, comp_map := @comp.comp_map F G _ _ _ _ }

theorem functor_comp_id {F} [AF : Functor F] [IsLawfulFunctor F] : @comp.functor F id _ _ = AF :=
  @Functor.ext F _ AF (@comp.is_lawful_functor F id _ _ _ _) _ fun α β f x => rfl

theorem functor_id_comp {F} [AF : Functor F] [IsLawfulFunctor F] : @comp.functor id F _ _ = AF :=
  @Functor.ext F _ AF (@comp.is_lawful_functor id F _ _ _ _) _ fun α β f x => rfl

end Comp

namespace Comp

open Function hiding comp

open Functor

variable{F : Type u → Type w}{G : Type v → Type u}

variable[Applicativeₓ F][Applicativeₓ G]

/-- The `<*>` operation for the composition of applicative functors. -/
protected def seq {α β : Type v} : comp F G (α → β) → comp F G α → comp F G β
| comp.mk f, comp.mk x => comp.mk$ (· <*> ·) <$> f <*> x

instance  : Pure (comp F G) :=
  ⟨fun _ x => comp.mk$ pure$ pure x⟩

instance  : Seqₓ (comp F G) :=
  ⟨fun _ _ f x => comp.seq f x⟩

@[simp]
protected theorem run_pure {α : Type v} : ∀ (x : α), (pure x : comp F G α).run = pure (pure x)
| _ => rfl

@[simp]
protected theorem run_seq {α β : Type v} (f : comp F G (α → β)) (x : comp F G α) :
  (f <*> x).run = (· <*> ·) <$> f.run <*> x.run :=
  rfl

instance  : Applicativeₓ (comp F G) :=
  { comp.has_pure with map := @comp.map F G _ _, seq := @comp.seq F G _ _ }

end Comp

variable{F : Type u → Type u}[Functor F]

/-- If we consider `x : F α` to, in some sense, contain values of type `α`,
predicate `liftp p x` holds iff every value contained by `x` satisfies `p`. -/
def liftp {α : Type u} (p : α → Prop) (x : F α) : Prop :=
  ∃ u : F (Subtype p), Subtype.val <$> u = x

-- error in Control.Functor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- If we consider `x : F α` to, in some sense, contain values of type `α`, then
`liftr r x y` relates `x` and `y` iff (1) `x` and `y` have the same shape and
(2) we can pair values `a` from `x` and `b` from `y` so that `r a b` holds. -/
def liftr {α : Type u} (r : α → α → exprProp()) (x y : F α) : exprProp() :=
«expr∃ , »((u : F {p : «expr × »(α, α) // r p.fst p.snd}), «expr ∧ »(«expr = »(«expr <$> »(λ
    t : {p : «expr × »(α, α) // r p.fst p.snd}, t.val.fst, u), x), «expr = »(«expr <$> »(λ
    t : {p : «expr × »(α, α) // r p.fst p.snd}, t.val.snd, u), y)))

/-- If we consider `x : F α` to, in some sense, contain values of type `α`, then
`supp x` is the set of values of type `α` that `x` contains. -/
def supp {α : Type u} (x : F α) : Set α :=
  { y:α | ∀ ⦃p⦄, liftp p x → p y }

theorem of_mem_supp {α : Type u} {x : F α} {p : α → Prop} (h : liftp p x) : ∀ y (_ : y ∈ supp x), p y :=
  fun y hy => hy h

end Functor

