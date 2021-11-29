import Mathbin.LinearAlgebra.Basis 
import Mathbin.LinearAlgebra.Multilinear.Basic

/-!
# Multilinear maps in relation to bases.

This file proves lemmas about the action of multilinear maps on basis vectors.

## TODO

 * Refactor the proofs in terms of bases of tensor products, once there is an equivalent of
   `basis.tensor_product` for `pi_tensor_product`.

-/


open MultilinearMap

variable{R : Type _}{ι : Type _}{n : ℕ}{M : Finₓ n → Type _}{M₂ : Type _}{M₃ : Type _}

variable[CommSemiringₓ R][AddCommMonoidₓ M₂][AddCommMonoidₓ M₃][∀ i, AddCommMonoidₓ (M i)]

variable[∀ i, Module R (M i)][Module R M₂][Module R M₃]

/-- Two multilinear maps indexed by `fin n` are equal if they are equal when all arguments are
basis vectors. -/
theorem Basis.ext_multilinear_fin {f g : MultilinearMap R M M₂} {ι₁ : Finₓ n → Type _} (e : ∀ i, Basis (ι₁ i) R (M i))
  (h : ∀ (v : ∀ i, ι₁ i), (f fun i => e i (v i)) = g fun i => e i (v i)) : f = g :=
  by 
    (
      induction' n with m hm)
    ·
      ext x 
      convert h finZeroElim
    ·
      apply Function.LeftInverse.injective uncurry_curry_left 
      refine' Basis.ext (e 0) _ 
      intro i 
      apply hm (Finₓ.tail e)
      intro j 
      convert h (Finₓ.cons i j)
      iterate 2
        rw [curry_left_apply]
        congr 1 with x 
        refine' Finₓ.cases rfl (fun x => _) x 
        dsimp [Finₓ.tail]
        rw [Finₓ.cons_succ, Finₓ.cons_succ]

-- error in LinearAlgebra.Multilinear.Basis: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Two multilinear maps indexed by a `fintype` are equal if they are equal when all arguments
are basis vectors. Unlike `basis.ext_multilinear_fin`, this only uses a single basis; a
dependently-typed version would still be true, but the proof would need a dependently-typed
version of `dom_dom_congr`. -/
theorem basis.ext_multilinear
[decidable_eq ι]
[fintype ι]
{f g : multilinear_map R (λ i : ι, M₂) M₃}
{ι₁ : Type*}
(e : basis ι₁ R M₂)
(h : ∀ v : ι → ι₁, «expr = »(f (λ i, e (v i)), g (λ i, e (v i)))) : «expr = »(f, g) :=
«expr $ »((dom_dom_congr_eq_iff (fintype.equiv_fin ι) f g).mp, basis.ext_multilinear_fin (λ
  i, e) (λ i, h «expr ∘ »(i, _)))

