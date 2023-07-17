/-
Copyright (c) 2021 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module girard
! leanprover-community/mathlib commit 08b081ea92d80e3a41f899eea36ef6d56e0f1db0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Basic

/-!
# Girard's paradox

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Girard's paradox is a proof that `Type : Type` entails a contradiction. We can't say this directly
in Lean because `Type : Type 1` and it's not possible to give `Type` a different type via an axiom,
so instead we axiomatize the behavior of the Pi type and application if the typing rule for Pi was
`(Type → Type) → Type` instead of `(Type → Type) → Type 1`.

Furthermore, we don't actually want false axioms in mathlib, so rather than introducing the axioms
using `axiom` or `constant` declarations, we take them as assumptions to the `girard` theorem.

Based on Watkins' LF implementation of Hurkens' simplification of Girard's paradox:
<http://www.cs.cmu.edu/~kw/research/hurkens95tlca.elf>.

## Main statements

* `girard`: there are no Girard universes.
-/


namespace Counterexample

/-- **Girard's paradox**: there are no universes `u` such that `Type u : Type u`.
Since we can't actually change the type of Lean's `Π` operator, we assume the existence of
`pi`, `lam`, `app` and the `beta` rule equivalent to the `Π` and `app` constructors of type theory.
-/
theorem girard.{u} (pi : (Type u → Type u) → Type u)
    (lam : ∀ {A : Type u → Type u}, (∀ x, A x) → pi A) (app : ∀ {A}, pi A → ∀ x, A x)
    (beta : ∀ {A : Type u → Type u} (f : ∀ x, A x) (x), app (lam f) x = f x) : False :=
  let F (X) := (Set (Set X) → X) → Set (Set X)
  let U := pi F
  let G (T : Set (Set U)) (X) : F X := fun f => {p | {x : U | f (app x X f) ∈ p} ∈ T}
  let τ (T : Set (Set U)) : U := lam (G T)
  let σ (S : U) : Set (Set U) := app S U τ
  have στ : ∀ {s S}, s ∈ σ (τ S) ↔ {x | τ (σ x) ∈ s} ∈ S := fun s S =>
    iff_of_eq (congr_arg (fun f : F U => s ∈ f τ) (beta (G S) U) : _)
  let ω : Set (Set U) := {p | ∀ x, p ∈ σ x → x ∈ p}
  let δ (S : Set (Set U)) := ∀ p, p ∈ S → τ S ∈ p
  have : δ ω := fun p d => d (τ ω) <| στ.2 fun x h => d (τ (σ x)) (στ.2 h)
  this {y | ¬δ (σ y)} (fun x e f => f _ e fun p h => f _ (στ.1 h)) fun p h => this _ (στ.1 h)
#align counterexample.girard Counterexample.girard

end Counterexample

