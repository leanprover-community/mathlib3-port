import Mathbin.Control.Functor.Multivariate 
import Mathbin.Data.Qpf.Multivariate.Basic

/-!
Projection functors are QPFs. The `n`-ary projection functors on `i` is an `n`-ary
functor `F` such that `F (α₀..αᵢ₋₁, αᵢ, αᵢ₊₁..αₙ₋₁) = αᵢ`
-/


universe u v

namespace Mvqpf

open_locale Mvfunctor

variable{n : ℕ}(i : Fin2 n)

/-- The projection `i` functor -/
def prj (v : Typevec.{u} n) : Type u :=
  v i

instance prj.inhabited {v : Typevec.{u} n} [Inhabited (v i)] : Inhabited (prj i v) :=
  ⟨(default _ : v i)⟩

/-- `map` on functor `prj i` -/
def prj.map ⦃α β : Typevec n⦄ (f : α ⟹ β) : prj i α → prj i β :=
  f _

instance prj.mvfunctor : Mvfunctor (prj i) :=
  { map := prj.map i }

/-- Polynomial representation of the projection functor -/
def prj.P : Mvpfunctor.{u} n :=
  { A := PUnit, B := fun _ j => Ulift$ Plift$ i = j }

/-- Abstraction function of the `qpf` instance -/
def prj.abs ⦃α : Typevec n⦄ : (prj.P i).Obj α → prj i α
| ⟨x, f⟩ => f _ ⟨⟨rfl⟩⟩

-- error in Data.Qpf.Multivariate.Constructions.Prj: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Representation function of the `qpf` instance -/ def prj.repr {{α : typevec n}} : prj i α → (prj.P i).obj α :=
λ x : α i, ⟨⟨⟩, λ (j) ⟨⟨h⟩⟩, (h.rec x : α j)⟩

instance prj.mvqpf : Mvqpf (prj i) :=
  { p := prj.P i, abs := prj.abs i, repr := prj.repr i,
    abs_repr :=
      by 
        intros  <;> rfl,
    abs_map :=
      by 
        intros  <;> cases p <;> rfl }

end Mvqpf

