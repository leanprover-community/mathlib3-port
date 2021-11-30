import Mathbin.Tactic.Basic 
import Mathbin.Data.Equiv.Basic

/-!
# Monad

## Attributes

 * ext
 * functor_norm
 * monad_norm

## Implementation Details

Set of rewrite rules and automation for monads in general and
`reader_t`, `state_t`, `except_t` and `option_t` in particular.

The rewrite rules for monads are carefully chosen so that `simp with
functor_norm` will not introduce monadic vocabulary in a context where
applicatives would do just fine but will handle monadic notation
already present in an expression.

In a context where monadic reasoning is desired `simp with monad_norm`
will translate functor and applicative notation into monad notation
and use regular `functor_norm` rules as well.

## Tags

functor, applicative, monad, simp

-/


-- error in Control.Monad.Basic: ././Mathport/Syntax/Translate/Basic.lean:1274:43: in mk_simp_attribute: ././Mathport/Syntax/Translate/Tactic/Mathlib.lean:251:9: unsupported: weird string
mk_simp_attribute [ident monad_norm, expr none, "with", ident functor_norm]

attribute [ext] ReaderTₓ.ext StateTₓ.ext ExceptTₓ.ext OptionTₓ.ext

attribute [functor_norm] bind_assoc pure_bind bind_pureₓ

attribute [monad_norm] seq_eq_bind_mapₓ

universe u v

@[monad_norm]
theorem map_eq_bind_pure_comp (m : Type u → Type v) [Monadₓ m] [IsLawfulMonad m] {α β : Type u} (f : α → β) (x : m α) :
  f <$> x = x >>= pure ∘ f :=
  by 
    rw [bind_pure_comp_eq_map]

/-- run a `state_t` program and discard the final state -/
def StateTₓ.eval {m : Type u → Type v} [Functor m] {σ α} (cmd : StateTₓ σ m α) (s : σ) : m α :=
  Prod.fst <$> cmd.run s

universe u₀ u₁ v₀ v₁

/-- reduce the equivalence between two state monads to the equivalence between
their respective function spaces -/
def StateTₓ.equiv {m₁ : Type u₀ → Type v₀} {m₂ : Type u₁ → Type v₁} {α₁ σ₁ : Type u₀} {α₂ σ₂ : Type u₁}
  (F : (σ₁ → m₁ (α₁ × σ₁)) ≃ (σ₂ → m₂ (α₂ × σ₂))) : StateTₓ σ₁ m₁ α₁ ≃ StateTₓ σ₂ m₂ α₂ :=
  { toFun := fun ⟨f⟩ => ⟨F f⟩, invFun := fun ⟨f⟩ => ⟨F.symm f⟩,
    left_inv := fun ⟨f⟩ => congr_argₓ StateTₓ.mk$ F.left_inv _,
    right_inv := fun ⟨f⟩ => congr_argₓ StateTₓ.mk$ F.right_inv _ }

/-- reduce the equivalence between two reader monads to the equivalence between
their respective function spaces -/
def ReaderTₓ.equiv {m₁ : Type u₀ → Type v₀} {m₂ : Type u₁ → Type v₁} {α₁ ρ₁ : Type u₀} {α₂ ρ₂ : Type u₁}
  (F : (ρ₁ → m₁ α₁) ≃ (ρ₂ → m₂ α₂)) : ReaderTₓ ρ₁ m₁ α₁ ≃ ReaderTₓ ρ₂ m₂ α₂ :=
  { toFun := fun ⟨f⟩ => ⟨F f⟩, invFun := fun ⟨f⟩ => ⟨F.symm f⟩,
    left_inv := fun ⟨f⟩ => congr_argₓ ReaderTₓ.mk$ F.left_inv _,
    right_inv := fun ⟨f⟩ => congr_argₓ ReaderTₓ.mk$ F.right_inv _ }

