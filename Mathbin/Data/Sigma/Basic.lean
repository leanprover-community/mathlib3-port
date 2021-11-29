import Mathbin.Tactic.Lint.Default 
import Mathbin.Tactic.Ext

/-!
# Sigma types

This file proves basic results about sigma types.

A sigma type is a dependent pair type. Like `α × β` but where the type of the second component
depends on the first component. This can be seen as a generalization of the sum type `α ⊕ β`:
* `α ⊕ β` is made of stuff which is either of type `α` or `β`.
* Given `α : ι → Type*`, `sigma α` is made of stuff which is of type `α i` for some `i : ι`. One
  effectively recovers a type isomorphic to `α ⊕ β` by taking a `ι` with exactly two elements. See
  `equiv.sum_equiv_sigma_bool`.

`Σ x, A x` is notation for `sigma A` (note the difference with the big operator `∑`).
`Σ x y z ..., A x y z ...` is notation for `Σ x, Σ y, Σ z, ..., A x y z ...`. Here we have 
`α : Type*`, `β : α → Type*`, `γ : Π a : α, β a → Type*`, ...,
`A : Π (a : α) (b : β a) (c : γ a b) ..., Type*`  with `x : α` `y : β x`, `z : γ x y`, ...

## Notes

The definition of `sigma` takes values in `Type*`. This effectively forbids `Prop`- valued sigma
types. To that effect, we have `psigma`, which takes value in `Sort*` and carries a more complicated
universe signature in consequence.
-/


section Sigma

variable{α α₁ α₂ : Type _}{β : α → Type _}{β₁ : α₁ → Type _}{β₂ : α₂ → Type _}

namespace Sigma

instance  [Inhabited α] [Inhabited (β (default α))] : Inhabited (Sigma β) :=
  ⟨⟨default α, default (β (default α))⟩⟩

instance  [h₁ : DecidableEq α] [h₂ : ∀ a, DecidableEq (β a)] : DecidableEq (Sigma β)
| ⟨a₁, b₁⟩, ⟨a₂, b₂⟩ =>
  match a₁, b₁, a₂, b₂, h₁ a₁ a₂ with 
  | _, b₁, _, b₂, is_true (Eq.refl a) =>
    match b₁, b₂, h₂ a b₁ b₂ with 
    | _, _, is_true (Eq.refl b) => is_true rfl
    | b₁, b₂, is_false n => is_false fun h => Sigma.noConfusion h fun e₁ e₂ => n$ eq_of_heq e₂
  | a₁, _, a₂, _, is_false n => is_false fun h => Sigma.noConfusion h fun e₁ e₂ => n e₁

@[simp, nolint simp_nf]
theorem mk.inj_iff {a₁ a₂ : α} {b₁ : β a₁} {b₂ : β a₂} : Sigma.mk a₁ b₁ = ⟨a₂, b₂⟩ ↔ a₁ = a₂ ∧ HEq b₁ b₂ :=
  by 
    simp 

@[simp]
theorem eta : ∀ (x : Σa, β a), Sigma.mk x.1 x.2 = x
| ⟨i, x⟩ => rfl

@[ext]
theorem ext {x₀ x₁ : Sigma β} (h₀ : x₀.1 = x₁.1) (h₁ : HEq x₀.2 x₁.2) : x₀ = x₁ :=
  by 
    cases x₀ 
    cases x₁ 
    cases h₀ 
    cases h₁ 
    rfl

theorem ext_iff {x₀ x₁ : Sigma β} : x₀ = x₁ ↔ x₀.1 = x₁.1 ∧ HEq x₀.2 x₁.2 :=
  by 
    cases x₀ 
    cases x₁ 
    exact Sigma.mk.inj_iff

/-- A specialized ext lemma for equality of sigma types over an indexed subtype. -/
@[ext]
theorem subtype_ext {β : Type _} {p : α → β → Prop} :
  ∀ {x₀ x₁ : Σa, Subtype (p a)}, x₀.fst = x₁.fst → (x₀.snd : β) = x₁.snd → x₀ = x₁
| ⟨a₀, b₀, hb₀⟩, ⟨a₁, b₁, hb₁⟩, rfl, rfl => rfl

theorem subtype_ext_iff {β : Type _} {p : α → β → Prop} {x₀ x₁ : Σa, Subtype (p a)} :
  x₀ = x₁ ↔ x₀.fst = x₁.fst ∧ (x₀.snd : β) = x₁.snd :=
  ⟨fun h => h ▸ ⟨rfl, rfl⟩, fun ⟨h₁, h₂⟩ => subtype_ext h₁ h₂⟩

@[simp]
theorem forall {p : (Σa, β a) → Prop} : (∀ x, p x) ↔ ∀ a b, p ⟨a, b⟩ :=
  ⟨fun h a b => h ⟨a, b⟩, fun h ⟨a, b⟩ => h a b⟩

@[simp]
theorem exists {p : (Σa, β a) → Prop} : (∃ x, p x) ↔ ∃ a b, p ⟨a, b⟩ :=
  ⟨fun ⟨⟨a, b⟩, h⟩ => ⟨a, b, h⟩, fun ⟨a, b, h⟩ => ⟨⟨a, b⟩, h⟩⟩

/-- Map the left and right components of a sigma -/
def map (f₁ : α₁ → α₂) (f₂ : ∀ a, β₁ a → β₂ (f₁ a)) (x : Sigma β₁) : Sigma β₂ :=
  ⟨f₁ x.1, f₂ x.1 x.2⟩

end Sigma

theorem sigma_mk_injective {i : α} : Function.Injective (@Sigma.mk α β i)
| _, _, rfl => rfl

-- error in Data.Sigma.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem function.injective.sigma_map
{f₁ : α₁ → α₂}
{f₂ : ∀ a, β₁ a → β₂ (f₁ a)}
(h₁ : function.injective f₁)
(h₂ : ∀ a, function.injective (f₂ a)) : function.injective (sigma.map f₁ f₂)
| ⟨i, x⟩, ⟨j, y⟩, h := begin
  have [] [":", expr «expr = »(i, j)] [],
  from [expr h₁ (sigma.mk.inj_iff.mp h).1],
  subst [expr j],
  have [] [":", expr «expr = »(x, y)] [],
  from [expr h₂ i (eq_of_heq (sigma.mk.inj_iff.mp h).2)],
  subst [expr y]
end

theorem Function.Surjective.sigma_map {f₁ : α₁ → α₂} {f₂ : ∀ a, β₁ a → β₂ (f₁ a)} (h₁ : Function.Surjective f₁)
  (h₂ : ∀ a, Function.Surjective (f₂ a)) : Function.Surjective (Sigma.map f₁ f₂) :=
  by 
    intro y 
    cases' y with j y 
    cases' h₁ j with i hi 
    subst j 
    cases' h₂ i y with x hx 
    subst y 
    exact ⟨⟨i, x⟩, rfl⟩

/-- Interpret a function on `Σ x : α, β x` as a dependent function with two arguments.

This also exists as an `equiv` as `equiv.Pi_curry γ`. -/
def Sigma.curry {γ : ∀ a, β a → Type _} (f : ∀ (x : Sigma β), γ x.1 x.2) (x : α) (y : β x) : γ x y :=
  f ⟨x, y⟩

/-- Interpret a dependent function with two arguments as a function on `Σ x : α, β x`.

This also exists as an `equiv` as `(equiv.Pi_curry γ).symm`. -/
def Sigma.uncurry {γ : ∀ a, β a → Type _} (f : ∀ x (y : β x), γ x y) (x : Sigma β) : γ x.1 x.2 :=
  f x.1 x.2

@[simp]
theorem Sigma.uncurry_curry {γ : ∀ a, β a → Type _} (f : ∀ (x : Sigma β), γ x.1 x.2) :
  Sigma.uncurry (Sigma.curry f) = f :=
  funext$ fun ⟨i, j⟩ => rfl

@[simp]
theorem Sigma.curry_uncurry {γ : ∀ a, β a → Type _} (f : ∀ x (y : β x), γ x y) : Sigma.curry (Sigma.uncurry f) = f :=
  rfl

/-- Convert a product type to a Σ-type. -/
@[simp]
def Prod.toSigma {α β} : α × β → Σ_ : α, β
| ⟨x, y⟩ => ⟨x, y⟩

@[simp]
theorem Prod.fst_to_sigma {α β} (x : α × β) : (Prod.toSigma x).fst = x.fst :=
  by 
    cases x <;> rfl

@[simp]
theorem Prod.snd_to_sigma {α β} (x : α × β) : (Prod.toSigma x).snd = x.snd :=
  by 
    cases x <;> rfl

end Sigma

section Psigma

variable{α : Sort _}{β : α → Sort _}

namespace Psigma

/-- Nondependent eliminator for `psigma`. -/
def elim {γ} (f : ∀ a, β a → γ) (a : Psigma β) : γ :=
  Psigma.casesOn a f

@[simp]
theorem elim_val {γ} (f : ∀ a, β a → γ) a b : Psigma.elim f ⟨a, b⟩ = f a b :=
  rfl

instance  [Inhabited α] [Inhabited (β (default α))] : Inhabited (Psigma β) :=
  ⟨⟨default α, default (β (default α))⟩⟩

instance  [h₁ : DecidableEq α] [h₂ : ∀ a, DecidableEq (β a)] : DecidableEq (Psigma β)
| ⟨a₁, b₁⟩, ⟨a₂, b₂⟩ =>
  match a₁, b₁, a₂, b₂, h₁ a₁ a₂ with 
  | _, b₁, _, b₂, is_true (Eq.refl a) =>
    match b₁, b₂, h₂ a b₁ b₂ with 
    | _, _, is_true (Eq.refl b) => is_true rfl
    | b₁, b₂, is_false n => is_false fun h => Psigma.noConfusion h fun e₁ e₂ => n$ eq_of_heq e₂
  | a₁, _, a₂, _, is_false n => is_false fun h => Psigma.noConfusion h fun e₁ e₂ => n e₁

theorem mk.inj_iff {a₁ a₂ : α} {b₁ : β a₁} {b₂ : β a₂} :
  @Psigma.mk α β a₁ b₁ = @Psigma.mk α β a₂ b₂ ↔ a₁ = a₂ ∧ HEq b₁ b₂ :=
  Iff.intro Psigma.mk.inj$
    fun ⟨h₁, h₂⟩ =>
      match a₁, a₂, b₁, b₂, h₁, h₂ with 
      | _, _, _, _, Eq.refl a, HEq.refl b => rfl

@[ext]
theorem ext {x₀ x₁ : Psigma β} (h₀ : x₀.1 = x₁.1) (h₁ : HEq x₀.2 x₁.2) : x₀ = x₁ :=
  by 
    cases x₀ 
    cases x₁ 
    cases h₀ 
    cases h₁ 
    rfl

theorem ext_iff {x₀ x₁ : Psigma β} : x₀ = x₁ ↔ x₀.1 = x₁.1 ∧ HEq x₀.2 x₁.2 :=
  by 
    cases x₀ 
    cases x₁ 
    exact Psigma.mk.inj_iff

/-- A specialized ext lemma for equality of psigma types over an indexed subtype. -/
@[ext]
theorem subtype_ext {β : Sort _} {p : α → β → Prop} :
  ∀ {x₀ x₁ : Σ'a, Subtype (p a)}, x₀.fst = x₁.fst → (x₀.snd : β) = x₁.snd → x₀ = x₁
| ⟨a₀, b₀, hb₀⟩, ⟨a₁, b₁, hb₁⟩, rfl, rfl => rfl

theorem subtype_ext_iff {β : Sort _} {p : α → β → Prop} {x₀ x₁ : Σ'a, Subtype (p a)} :
  x₀ = x₁ ↔ x₀.fst = x₁.fst ∧ (x₀.snd : β) = x₁.snd :=
  ⟨fun h => h ▸ ⟨rfl, rfl⟩, fun ⟨h₁, h₂⟩ => subtype_ext h₁ h₂⟩

variable{α₁ : Sort _}{α₂ : Sort _}{β₁ : α₁ → Sort _}{β₂ : α₂ → Sort _}

/-- Map the left and right components of a sigma -/
def map (f₁ : α₁ → α₂) (f₂ : ∀ a, β₁ a → β₂ (f₁ a)) : Psigma β₁ → Psigma β₂
| ⟨a, b⟩ => ⟨f₁ a, f₂ a b⟩

end Psigma

end Psigma

