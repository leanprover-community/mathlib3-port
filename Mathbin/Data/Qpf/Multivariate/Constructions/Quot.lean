import Mathbin.Data.Qpf.Multivariate.Basic

/-!
# The quotient of QPF is itself a QPF

The quotients are here defined using a surjective function and
its right inverse. They are very similar to the `abs` and `repr`
functions found in the definition of `mvqpf`
-/


universe u

open_locale Mvfunctor

namespace Mvqpf

variable{n : ℕ}

variable{F : Typevec.{u} n → Type u}

section reprₓ

variable[Mvfunctor F][q : Mvqpf F]

variable{G : Typevec.{u} n → Type u}[Mvfunctor G]

variable{FG_abs : ∀ {α}, F α → G α}

variable{FG_repr : ∀ {α}, G α → F α}

/-- If `F` is a QPF then `G` is a QPF as well. Can be used to
construct `mvqpf` instances by transporting them across
surjective functions -/
def quotient_qpf (FG_abs_repr : ∀ {α} (x : G α), FG_abs (FG_repr x) = x)
  (FG_abs_map : ∀ {α β} (f : α ⟹ β) (x : F α), FG_abs (f <$$> x) = f <$$> FG_abs x) : Mvqpf G :=
  { p := q.P, abs := fun α p => FG_abs (abs p), repr := fun α x => reprₓ (FG_repr x),
    abs_repr :=
      fun α x =>
        by 
          rw [abs_repr, FG_abs_repr],
    abs_map :=
      fun α β f p =>
        by 
          rw [abs_map, FG_abs_map] }

end reprₓ

section Rel

variable(R : ∀ ⦃α⦄, F α → F α → Prop)

/-- Functorial quotient type -/
def quot1 (α : Typevec n) :=
  Quot (@R α)

instance quot1.inhabited {α : Typevec n} [Inhabited$ F α] : Inhabited (quot1 R α) :=
  ⟨Quot.mk _ (default _)⟩

variable[Mvfunctor F][q : Mvqpf F]

variable(Hfunc : ∀ ⦃α β⦄ (a b : F α) (f : α ⟹ β), R a b → R (f <$$> a) (f <$$> b))

-- error in Data.Qpf.Multivariate.Constructions.Quot: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- `map` of the `quot1` functor -/ def quot1.map {{α β}} (f : «expr ⟹ »(α, β)) : quot1.{u} R α → quot1.{u} R β :=
«expr $ »(quot.lift (λ x : F α, quot.mk _ («expr <$$> »(f, x) : F β)), λ a b h, «expr $ »(quot.sound, Hfunc a b _ h))

/-- `mvfunctor` instance for `quot1` with well-behaved `R` -/
def quot1.mvfunctor : Mvfunctor (quot1 R) :=
  { map := quot1.map R Hfunc }

/-- `quot1` is a qpf -/
noncomputable def rel_quot : @Mvqpf _ (quot1 R) (Mvqpf.Quot1.mvfunctor R Hfunc) :=
  @quotient_qpf n F _ q _ (Mvqpf.Quot1.mvfunctor R Hfunc) (fun α x => Quot.mk _ x) (fun α => Quot.out)
    (fun α x => Quot.out_eq _) fun α β f x => rfl

end Rel

end Mvqpf

