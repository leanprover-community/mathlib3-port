/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Bryan Gin-ge Chen

! This file was ported from Lean 3 source module order.boolean_algebra
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Heyting.Basic

/-!
# (Generalized) Boolean algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> https://github.com/leanprover-community/mathlib4/pull/794
> Any changes to this file require a corresponding PR to mathlib4.

A Boolean algebra is a bounded distributive lattice with a complement operator. Boolean algebras
generalize the (classical) logic of propositions and the lattice of subsets of a set.

Generalized Boolean algebras may be less familiar, but they are essentially Boolean algebras which
do not necessarily have a top element (`⊤`) (and hence not all elements may have complements). One
example in mathlib is `finset α`, the type of all finite subsets of an arbitrary
(not-necessarily-finite) type `α`.

`generalized_boolean_algebra α` is defined to be a distributive lattice with bottom (`⊥`) admitting
a *relative* complement operator, written using "set difference" notation as `x \ y` (`sdiff x y`).
For convenience, the `boolean_algebra` type class is defined to extend `generalized_boolean_algebra`
so that it is also bundled with a `\` operator.

(A terminological point: `x \ y` is the complement of `y` relative to the interval `[⊥, x]`. We do
not yet have relative complements for arbitrary intervals, as we do not even have lattice
intervals.)

## Main declarations

* `generalized_boolean_algebra`: a type class for generalized Boolean algebras
* `boolean_algebra`: a type class for Boolean algebras.
* `Prop.boolean_algebra`: the Boolean algebra instance on `Prop`

## Implementation notes

The `sup_inf_sdiff` and `inf_inf_sdiff` axioms for the relative complement operator in
`generalized_boolean_algebra` are taken from
[Wikipedia](https://en.wikipedia.org/wiki/Boolean_algebra_(structure)#Generalizations).

[Stone's paper introducing generalized Boolean algebras][Stone1935] does not define a relative
complement operator `a \ b` for all `a`, `b`. Instead, the postulates there amount to an assumption
that for all `a, b : α` where `a ≤ b`, the equations `x ⊔ a = b` and `x ⊓ a = ⊥` have a solution
`x`. `disjoint.sdiff_unique` proves that this `x` is in fact `b \ a`.

## References

* <https://en.wikipedia.org/wiki/Boolean_algebra_(structure)#Generalizations>
* [*Postulates for Boolean Algebras and Generalized Boolean Algebras*, M.H. Stone][Stone1935]
* [*Lattice Theory: Foundation*, George Grätzer][Gratzer2011]

## Tags

generalized Boolean algebras, Boolean algebras, lattices, sdiff, compl
-/


open Function OrderDual

universe u v

variable {α : Type u} {β : Type _} {w x y z : α}

/-!
### Generalized Boolean algebras

Some of the lemmas in this section are from:

* [*Lattice Theory: Foundation*, George Grätzer][Gratzer2011]
* <https://ncatlab.org/nlab/show/relative+complement>
* <https://people.math.gatech.edu/~mccuan/courses/4317/symmetricdifference.pdf>

-/


#print GeneralizedBooleanAlgebra /-
/-- A generalized Boolean algebra is a distributive lattice with `⊥` and a relative complement
operation `\` (called `sdiff`, after "set difference") satisfying `(a ⊓ b) ⊔ (a \ b) = a` and
`(a ⊓ b) ⊓ (a \ b) = ⊥`, i.e. `a \ b` is the complement of `b` in `a`.

This is a generalization of Boolean algebras which applies to `finset α` for arbitrary
(not-necessarily-`fintype`) `α`. -/
class GeneralizedBooleanAlgebra (α : Type u) extends DistribLattice α, SDiff α, Bot α where
  sup_inf_sdiff : ∀ a b : α, a ⊓ b ⊔ a \ b = a
  inf_inf_sdiff : ∀ a b : α, a ⊓ b ⊓ a \ b = ⊥
#align generalized_boolean_algebra GeneralizedBooleanAlgebra
-/

-- We might want a `is_compl_of` predicate (for relative complements) generalizing `is_compl`,
-- however we'd need another type class for lattices with bot, and all the API for that.
section GeneralizedBooleanAlgebra

variable [GeneralizedBooleanAlgebra α]

/- warning: sup_inf_sdiff -> sup_inf_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α] (x : α) (y : α), Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y)) x
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α] (x : α) (y : α), Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y)) x
Case conversion may be inaccurate. Consider using '#align sup_inf_sdiff sup_inf_sdiffₓ'. -/
@[simp]
theorem sup_inf_sdiff (x y : α) : x ⊓ y ⊔ x \ y = x :=
  GeneralizedBooleanAlgebra.sup_inf_sdiff _ _
#align sup_inf_sdiff sup_inf_sdiff

/- warning: inf_inf_sdiff -> inf_inf_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α] (x : α) (y : α), Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y)) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toHasBot.{u1} α _inst_1))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α] (x : α) (y : α), Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y)) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toBot.{u1} α _inst_1))
Case conversion may be inaccurate. Consider using '#align inf_inf_sdiff inf_inf_sdiffₓ'. -/
@[simp]
theorem inf_inf_sdiff (x y : α) : x ⊓ y ⊓ x \ y = ⊥ :=
  GeneralizedBooleanAlgebra.inf_inf_sdiff _ _
#align inf_inf_sdiff inf_inf_sdiff

/- warning: sup_sdiff_inf -> sup_sdiff_inf is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α] (x : α) (y : α), Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) x y)) x
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α] (x : α) (y : α), Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) x y)) x
Case conversion may be inaccurate. Consider using '#align sup_sdiff_inf sup_sdiff_infₓ'. -/
@[simp]
theorem sup_sdiff_inf (x y : α) : x \ y ⊔ x ⊓ y = x := by rw [sup_comm, sup_inf_sdiff]
#align sup_sdiff_inf sup_sdiff_inf

/- warning: inf_sdiff_inf -> inf_sdiff_inf is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α] (x : α) (y : α), Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) x y)) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toHasBot.{u1} α _inst_1))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α] (x : α) (y : α), Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) x y)) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toBot.{u1} α _inst_1))
Case conversion may be inaccurate. Consider using '#align inf_sdiff_inf inf_sdiff_infₓ'. -/
@[simp]
theorem inf_sdiff_inf (x y : α) : x \ y ⊓ (x ⊓ y) = ⊥ := by rw [inf_comm, inf_inf_sdiff]
#align inf_sdiff_inf inf_sdiff_inf

#print GeneralizedBooleanAlgebra.toOrderBot /-
-- see Note [lower instance priority]
instance (priority := 100) GeneralizedBooleanAlgebra.toOrderBot : OrderBot α :=
  { GeneralizedBooleanAlgebra.toHasBot α with
    bot_le := fun a => by
      rw [← inf_inf_sdiff a a, inf_assoc]
      exact inf_le_left }
#align generalized_boolean_algebra.to_order_bot GeneralizedBooleanAlgebra.toOrderBot
-/

/- warning: disjoint_inf_sdiff -> disjoint_inf_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y)
Case conversion may be inaccurate. Consider using '#align disjoint_inf_sdiff disjoint_inf_sdiffₓ'. -/
theorem disjoint_inf_sdiff : Disjoint (x ⊓ y) (x \ y) :=
  disjoint_iff_inf_le.mpr (inf_inf_sdiff x y).le
#align disjoint_inf_sdiff disjoint_inf_sdiff

/- warning: sdiff_unique -> sdiff_unique is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) x y) z) x) -> (Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) x y) z) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toHasBot.{u1} α _inst_1))) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) z)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) x y) z) x) -> (Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) x y) z) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toBot.{u1} α _inst_1))) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) z)
Case conversion may be inaccurate. Consider using '#align sdiff_unique sdiff_uniqueₓ'. -/
-- TODO: in distributive lattices, relative complements are unique when they exist
theorem sdiff_unique (s : x ⊓ y ⊔ z = x) (i : x ⊓ y ⊓ z = ⊥) : x \ y = z :=
  by
  conv_rhs at s => rw [← sup_inf_sdiff x y, sup_comm]
  rw [sup_comm] at s
  conv_rhs at i => rw [← inf_inf_sdiff x y, inf_comm]
  rw [inf_comm] at i
  exact (eq_of_inf_eq_sup_eq i s).symm
#align sdiff_unique sdiff_unique

-- Use `sdiff_le`
private theorem sdiff_le' : x \ y ≤ x :=
  calc
    x \ y ≤ x ⊓ y ⊔ x \ y := le_sup_right
    _ = x := sup_inf_sdiff x y
    
#align sdiff_le' sdiff_le'

-- Use `sdiff_sup_self`
private theorem sdiff_sup_self' : y \ x ⊔ x = y ⊔ x :=
  calc
    y \ x ⊔ x = y \ x ⊔ (x ⊔ x ⊓ y) := by rw [sup_inf_self]
    _ = y ⊓ x ⊔ y \ x ⊔ x := by ac_rfl
    _ = y ⊔ x := by rw [sup_inf_sdiff]
    
#align sdiff_sup_self' sdiff_sup_self'

/- warning: sdiff_inf_sdiff -> sdiff_inf_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x)) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toHasBot.{u1} α _inst_1))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x)) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toBot.{u1} α _inst_1))
Case conversion may be inaccurate. Consider using '#align sdiff_inf_sdiff sdiff_inf_sdiffₓ'. -/
@[simp]
theorem sdiff_inf_sdiff : x \ y ⊓ y \ x = ⊥ :=
  Eq.symm <|
    calc
      ⊥ = x ⊓ y ⊓ x \ y := by rw [inf_inf_sdiff]
      _ = x ⊓ (y ⊓ x ⊔ y \ x) ⊓ x \ y := by rw [sup_inf_sdiff]
      _ = (x ⊓ (y ⊓ x) ⊔ x ⊓ y \ x) ⊓ x \ y := by rw [inf_sup_left]
      _ = (y ⊓ (x ⊓ x) ⊔ x ⊓ y \ x) ⊓ x \ y := by ac_rfl
      _ = (y ⊓ x ⊔ x ⊓ y \ x) ⊓ x \ y := by rw [inf_idem]
      _ = x ⊓ y ⊓ x \ y ⊔ x ⊓ y \ x ⊓ x \ y := by rw [inf_sup_right, @inf_comm _ _ x y]
      _ = x ⊓ y \ x ⊓ x \ y := by rw [inf_inf_sdiff, bot_sup_eq]
      _ = x ⊓ x \ y ⊓ y \ x := by ac_rfl
      _ = x \ y ⊓ y \ x := by rw [inf_of_le_right sdiff_le']
      
#align sdiff_inf_sdiff sdiff_inf_sdiff

/- warning: disjoint_sdiff_sdiff -> disjoint_sdiff_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x)
Case conversion may be inaccurate. Consider using '#align disjoint_sdiff_sdiff disjoint_sdiff_sdiffₓ'. -/
theorem disjoint_sdiff_sdiff : Disjoint (x \ y) (y \ x) :=
  disjoint_iff_inf_le.mpr sdiff_inf_sdiff.le
#align disjoint_sdiff_sdiff disjoint_sdiff_sdiff

/- warning: inf_sdiff_self_right -> inf_sdiff_self_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x)) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toHasBot.{u1} α _inst_1))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x)) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toBot.{u1} α _inst_1))
Case conversion may be inaccurate. Consider using '#align inf_sdiff_self_right inf_sdiff_self_rightₓ'. -/
@[simp]
theorem inf_sdiff_self_right : x ⊓ y \ x = ⊥ :=
  calc
    x ⊓ y \ x = (x ⊓ y ⊔ x \ y) ⊓ y \ x := by rw [sup_inf_sdiff]
    _ = x ⊓ y ⊓ y \ x ⊔ x \ y ⊓ y \ x := by rw [inf_sup_right]
    _ = ⊥ := by rw [@inf_comm _ _ x y, inf_inf_sdiff, sdiff_inf_sdiff, bot_sup_eq]
    
#align inf_sdiff_self_right inf_sdiff_self_right

/- warning: inf_sdiff_self_left -> inf_sdiff_self_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x) x) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toHasBot.{u1} α _inst_1))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (GeneralizedBooleanAlgebra.toDistribLattice.{u1} α _inst_1))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x) x) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toBot.{u1} α _inst_1))
Case conversion may be inaccurate. Consider using '#align inf_sdiff_self_left inf_sdiff_self_leftₓ'. -/
@[simp]
theorem inf_sdiff_self_left : y \ x ⊓ x = ⊥ := by rw [inf_comm, inf_sdiff_self_right]
#align inf_sdiff_self_left inf_sdiff_self_left

#print GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra /-
-- see Note [lower instance priority]
instance (priority := 100) GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra :
    GeneralizedCoheytingAlgebra α :=
  { ‹GeneralizedBooleanAlgebra α›,
    GeneralizedBooleanAlgebra.toOrderBot with
    sdiff := (· \ ·)
    sdiff_le_iff := fun y x z =>
      ⟨fun h =>
        le_of_inf_le_sup_le
          (le_of_eq
            (calc
              y ⊓ y \ x = y \ x := inf_of_le_right sdiff_le'
              _ = x ⊓ y \ x ⊔ z ⊓ y \ x := by
                rw [inf_eq_right.2 h, inf_sdiff_self_right, bot_sup_eq]
              _ = (x ⊔ z) ⊓ y \ x := inf_sup_right.symm
              ))
          (calc
            y ⊔ y \ x = y := sup_of_le_left sdiff_le'
            _ ≤ y ⊔ (x ⊔ z) := le_sup_left
            _ = y \ x ⊔ x ⊔ z := by rw [← sup_assoc, ← @sdiff_sup_self' _ x y]
            _ = x ⊔ z ⊔ y \ x := by ac_rfl
            ),
        fun h =>
        le_of_inf_le_sup_le
          (calc
            y \ x ⊓ x = ⊥ := inf_sdiff_self_left
            _ ≤ z ⊓ x := bot_le
            )
          (calc
            y \ x ⊔ x = y ⊔ x := sdiff_sup_self'
            _ ≤ x ⊔ z ⊔ x := sup_le_sup_right h x
            _ ≤ z ⊔ x := by rw [sup_assoc, sup_comm, sup_assoc, sup_idem]
            )⟩ }
#align
  generalized_boolean_algebra.to_generalized_coheyting_algebra GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra
-/

/- warning: disjoint_sdiff_self_left -> disjoint_sdiff_self_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x) x
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x) x
Case conversion may be inaccurate. Consider using '#align disjoint_sdiff_self_left disjoint_sdiff_self_leftₓ'. -/
theorem disjoint_sdiff_self_left : Disjoint (y \ x) x :=
  disjoint_iff_inf_le.mpr inf_sdiff_self_left.le
#align disjoint_sdiff_self_left disjoint_sdiff_self_left

/- warning: disjoint_sdiff_self_right -> disjoint_sdiff_self_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x)
Case conversion may be inaccurate. Consider using '#align disjoint_sdiff_self_right disjoint_sdiff_self_rightₓ'. -/
theorem disjoint_sdiff_self_right : Disjoint x (y \ x) :=
  disjoint_iff_inf_le.mpr inf_sdiff_self_right.le
#align disjoint_sdiff_self_right disjoint_sdiff_self_right

/- warning: disjoint.sdiff_eq_of_sup_eq -> Disjoint.sdiff_eq_of_sup_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) x z) -> (Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x z) y) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x) z)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) x z) -> (Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x z) y) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x) z)
Case conversion may be inaccurate. Consider using '#align disjoint.sdiff_eq_of_sup_eq Disjoint.sdiff_eq_of_sup_eqₓ'. -/
/- TODO: we could make an alternative constructor for `generalized_boolean_algebra` using
`disjoint x (y \ x)` and `x ⊔ (y \ x) = y` as axioms. -/
theorem Disjoint.sdiff_eq_of_sup_eq (hi : Disjoint x z) (hs : x ⊔ z = y) : y \ x = z :=
  have h : y ⊓ x = x := inf_eq_right.2 <| le_sup_left.trans hs.le
  sdiff_unique (by rw [h, hs]) (by rw [h, hi.eq_bot])
#align disjoint.sdiff_eq_of_sup_eq Disjoint.sdiff_eq_of_sup_eq

/- warning: disjoint.sdiff_unique -> Disjoint.sdiff_unique is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) x z) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z y) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x z)) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x) z)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) x z) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z y) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x z)) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x) z)
Case conversion may be inaccurate. Consider using '#align disjoint.sdiff_unique Disjoint.sdiff_uniqueₓ'. -/
protected theorem Disjoint.sdiff_unique (hd : Disjoint x z) (hz : z ≤ y) (hs : y ≤ x ⊔ z) :
    y \ x = z :=
  sdiff_unique
    (by
      rw [← inf_eq_right] at hs
      rwa [sup_inf_right, inf_sup_right, @sup_comm _ _ x, inf_sup_self, inf_comm, @sup_comm _ _ z,
        hs, sup_eq_left])
    (by rw [inf_assoc, hd.eq_bot, inf_bot_eq])
#align disjoint.sdiff_unique Disjoint.sdiff_unique

/- warning: disjoint_sdiff_iff_le -> disjoint_sdiff_iff_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z y) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x y) -> (Iff (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) z (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x)) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z x))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z y) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x y) -> (Iff (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) z (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x)) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z x))
Case conversion may be inaccurate. Consider using '#align disjoint_sdiff_iff_le disjoint_sdiff_iff_leₓ'. -/
-- cf. `is_compl.disjoint_left_iff` and `is_compl.disjoint_right_iff`
theorem disjoint_sdiff_iff_le (hz : z ≤ y) (hx : x ≤ y) : Disjoint z (y \ x) ↔ z ≤ x :=
  ⟨fun H =>
    le_of_inf_le_sup_le (le_trans H.le_bot bot_le)
      (by
        rw [sup_sdiff_cancel_right hx]
        refine' le_trans (sup_le_sup_left sdiff_le z) _
        rw [sup_eq_right.2 hz]),
    fun H => disjoint_sdiff_self_right.mono_left H⟩
#align disjoint_sdiff_iff_le disjoint_sdiff_iff_le

/- warning: le_iff_disjoint_sdiff -> le_iff_disjoint_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z y) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x y) -> (Iff (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z x) (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) z (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x)))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z y) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x y) -> (Iff (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z x) (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) z (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x)))
Case conversion may be inaccurate. Consider using '#align le_iff_disjoint_sdiff le_iff_disjoint_sdiffₓ'. -/
-- cf. `is_compl.le_left_iff` and `is_compl.le_right_iff`
theorem le_iff_disjoint_sdiff (hz : z ≤ y) (hx : x ≤ y) : z ≤ x ↔ Disjoint z (y \ x) :=
  (disjoint_sdiff_iff_le hz hx).symm
#align le_iff_disjoint_sdiff le_iff_disjoint_sdiff

/- warning: inf_sdiff_eq_bot_iff -> inf_sdiff_eq_bot_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z y) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x y) -> (Iff (Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) z (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x)) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toHasBot.{u1} α _inst_1))) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z x))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z y) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x y) -> (Iff (Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) z (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x)) (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toBot.{u1} α _inst_1))) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z x))
Case conversion may be inaccurate. Consider using '#align inf_sdiff_eq_bot_iff inf_sdiff_eq_bot_iffₓ'. -/
-- cf. `is_compl.inf_left_eq_bot_iff` and `is_compl.inf_right_eq_bot_iff`
theorem inf_sdiff_eq_bot_iff (hz : z ≤ y) (hx : x ≤ y) : z ⊓ y \ x = ⊥ ↔ z ≤ x :=
  by
  rw [← disjoint_iff]
  exact disjoint_sdiff_iff_le hz hx
#align inf_sdiff_eq_bot_iff inf_sdiff_eq_bot_iff

/- warning: le_iff_eq_sup_sdiff -> le_iff_eq_sup_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z y) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x y) -> (Iff (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x z) (Eq.{succ u1} α y (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) z (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x))))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z y) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x y) -> (Iff (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x z) (Eq.{succ u1} α y (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) z (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x))))
Case conversion may be inaccurate. Consider using '#align le_iff_eq_sup_sdiff le_iff_eq_sup_sdiffₓ'. -/
-- cf. `is_compl.left_le_iff` and `is_compl.right_le_iff`
theorem le_iff_eq_sup_sdiff (hz : z ≤ y) (hx : x ≤ y) : x ≤ z ↔ y = z ⊔ y \ x :=
  ⟨fun H => by
    apply le_antisymm
    · conv_lhs => rw [← sup_inf_sdiff y x]
      apply sup_le_sup_right
      rwa [inf_eq_right.2 hx]
    · apply le_trans
      · apply sup_le_sup_right hz
      · rw [sup_sdiff_left], fun H =>
    by
    conv_lhs at H => rw [← sup_sdiff_cancel_right hx]
    refine' le_of_inf_le_sup_le _ H.le
    rw [inf_sdiff_self_right]
    exact bot_le⟩
#align le_iff_eq_sup_sdiff le_iff_eq_sup_sdiff

/- warning: sdiff_sup -> sdiff_sup is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x z)) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y z))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x z)) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y z))
Case conversion may be inaccurate. Consider using '#align sdiff_sup sdiff_supₓ'. -/
-- cf. `is_compl.sup_inf`
theorem sdiff_sup : y \ (x ⊔ z) = y \ x ⊓ y \ z :=
  sdiff_unique
    (calc
      y ⊓ (x ⊔ z) ⊔ y \ x ⊓ y \ z = (y ⊓ (x ⊔ z) ⊔ y \ x) ⊓ (y ⊓ (x ⊔ z) ⊔ y \ z) := by
        rw [sup_inf_left]
      _ = (y ⊓ x ⊔ y ⊓ z ⊔ y \ x) ⊓ (y ⊓ x ⊔ y ⊓ z ⊔ y \ z) := by rw [@inf_sup_left _ _ y]
      _ = (y ⊓ z ⊔ (y ⊓ x ⊔ y \ x)) ⊓ (y ⊓ x ⊔ (y ⊓ z ⊔ y \ z)) := by ac_rfl
      _ = (y ⊓ z ⊔ y) ⊓ (y ⊓ x ⊔ y) := by rw [sup_inf_sdiff, sup_inf_sdiff]
      _ = (y ⊔ y ⊓ z) ⊓ (y ⊔ y ⊓ x) := by ac_rfl
      _ = y := by rw [sup_inf_self, sup_inf_self, inf_idem]
      )
    (calc
      y ⊓ (x ⊔ z) ⊓ (y \ x ⊓ y \ z) = (y ⊓ x ⊔ y ⊓ z) ⊓ (y \ x ⊓ y \ z) := by rw [inf_sup_left]
      _ = y ⊓ x ⊓ (y \ x ⊓ y \ z) ⊔ y ⊓ z ⊓ (y \ x ⊓ y \ z) := by rw [inf_sup_right]
      _ = y ⊓ x ⊓ y \ x ⊓ y \ z ⊔ y \ x ⊓ (y \ z ⊓ (y ⊓ z)) := by ac_rfl
      _ = ⊥ := by
        rw [inf_inf_sdiff, bot_inf_eq, bot_sup_eq, @inf_comm _ _ (y \ z), inf_inf_sdiff, inf_bot_eq]
      )
#align sdiff_sup sdiff_sup

/- warning: sdiff_eq_sdiff_iff_inf_eq_inf -> sdiff_eq_sdiff_iff_inf_eq_inf is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Iff (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y z)) (Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) y x) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) y z))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Iff (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y z)) (Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) y x) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) y z))
Case conversion may be inaccurate. Consider using '#align sdiff_eq_sdiff_iff_inf_eq_inf sdiff_eq_sdiff_iff_inf_eq_infₓ'. -/
theorem sdiff_eq_sdiff_iff_inf_eq_inf : y \ x = y \ z ↔ y ⊓ x = y ⊓ z :=
  ⟨fun h =>
    eq_of_inf_eq_sup_eq (by rw [inf_inf_sdiff, h, inf_inf_sdiff])
      (by rw [sup_inf_sdiff, h, sup_inf_sdiff]),
    fun h => by rw [← sdiff_inf_self_right, ← sdiff_inf_self_right z y, inf_comm, h, inf_comm]⟩
#align sdiff_eq_sdiff_iff_inf_eq_inf sdiff_eq_sdiff_iff_inf_eq_inf

/- warning: sdiff_eq_self_iff_disjoint -> sdiff_eq_self_iff_disjoint is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Iff (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) x) (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) y x)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Iff (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) x) (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) y x)
Case conversion may be inaccurate. Consider using '#align sdiff_eq_self_iff_disjoint sdiff_eq_self_iff_disjointₓ'. -/
theorem sdiff_eq_self_iff_disjoint : x \ y = x ↔ Disjoint y x :=
  calc
    x \ y = x ↔ x \ y = x \ ⊥ := by rw [sdiff_bot]
    _ ↔ x ⊓ y = x ⊓ ⊥ := sdiff_eq_sdiff_iff_inf_eq_inf
    _ ↔ Disjoint y x := by rw [inf_bot_eq, inf_comm, disjoint_iff]
    
#align sdiff_eq_self_iff_disjoint sdiff_eq_self_iff_disjoint

/- warning: sdiff_eq_self_iff_disjoint' -> sdiff_eq_self_iff_disjoint' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Iff (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) x) (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) x y)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Iff (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) x) (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} α _inst_1) x y)
Case conversion may be inaccurate. Consider using '#align sdiff_eq_self_iff_disjoint' sdiff_eq_self_iff_disjoint'ₓ'. -/
theorem sdiff_eq_self_iff_disjoint' : x \ y = x ↔ Disjoint x y := by
  rw [sdiff_eq_self_iff_disjoint, Disjoint.comm]
#align sdiff_eq_self_iff_disjoint' sdiff_eq_self_iff_disjoint'

/- warning: sdiff_lt -> sdiff_lt is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y x) -> (Ne.{succ u1} α y (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toHasBot.{u1} α _inst_1))) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) x)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y x) -> (Ne.{succ u1} α y (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toBot.{u1} α _inst_1))) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) x)
Case conversion may be inaccurate. Consider using '#align sdiff_lt sdiff_ltₓ'. -/
theorem sdiff_lt (hx : y ≤ x) (hy : y ≠ ⊥) : x \ y < x :=
  by
  refine' sdiff_le.lt_of_ne fun h => hy _
  rw [sdiff_eq_self_iff_disjoint', disjoint_iff] at h
  rw [← h, inf_eq_right.mpr hx]
#align sdiff_lt sdiff_lt

/- warning: le_sdiff_iff -> le_sdiff_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Iff (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x)) (Eq.{succ u1} α x (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toHasBot.{u1} α _inst_1)))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Iff (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x)) (Eq.{succ u1} α x (Bot.bot.{u1} α (GeneralizedBooleanAlgebra.toBot.{u1} α _inst_1)))
Case conversion may be inaccurate. Consider using '#align le_sdiff_iff le_sdiff_iffₓ'. -/
@[simp]
theorem le_sdiff_iff : x ≤ y \ x ↔ x = ⊥ :=
  ⟨fun h => disjoint_self.1 (disjoint_sdiff_self_right.mono_right h), fun h => h.le.trans bot_le⟩
#align le_sdiff_iff le_sdiff_iff

/- warning: sdiff_lt_sdiff_right -> sdiff_lt_sdiff_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x y) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z x) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x z) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y z))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x y) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z x) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x z) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y z))
Case conversion may be inaccurate. Consider using '#align sdiff_lt_sdiff_right sdiff_lt_sdiff_rightₓ'. -/
theorem sdiff_lt_sdiff_right (h : x < y) (hz : z ≤ x) : x \ z < y \ z :=
  (sdiff_le_sdiff_right h.le).lt_of_not_le fun h' =>
    h.not_le <| le_sdiff_sup.trans <| sup_le_of_le_sdiff_right h' hz
#align sdiff_lt_sdiff_right sdiff_lt_sdiff_right

/- warning: sup_inf_inf_sdiff -> sup_inf_inf_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y) z) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y z)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y z))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) x y) z) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y z)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y z))
Case conversion may be inaccurate. Consider using '#align sup_inf_inf_sdiff sup_inf_inf_sdiffₓ'. -/
theorem sup_inf_inf_sdiff : x ⊓ y ⊓ z ⊔ y \ z = x ⊓ y ⊔ y \ z :=
  calc
    x ⊓ y ⊓ z ⊔ y \ z = x ⊓ (y ⊓ z) ⊔ y \ z := by rw [inf_assoc]
    _ = (x ⊔ y \ z) ⊓ y := by rw [sup_inf_right, sup_inf_sdiff]
    _ = x ⊓ y ⊔ y \ z := by rw [inf_sup_right, inf_sdiff_left]
    
#align sup_inf_inf_sdiff sup_inf_inf_sdiff

/- warning: sdiff_sdiff_right -> sdiff_sdiff_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y z)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y) z))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y z)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) x y) z))
Case conversion may be inaccurate. Consider using '#align sdiff_sdiff_right sdiff_sdiff_rightₓ'. -/
theorem sdiff_sdiff_right : x \ (y \ z) = x \ y ⊔ x ⊓ y ⊓ z :=
  by
  rw [sup_comm, inf_comm, ← inf_assoc, sup_inf_inf_sdiff]
  apply sdiff_unique
  ·
    calc
      x ⊓ y \ z ⊔ (z ⊓ x ⊔ x \ y) = (x ⊔ (z ⊓ x ⊔ x \ y)) ⊓ (y \ z ⊔ (z ⊓ x ⊔ x \ y)) := by
        rw [sup_inf_right]
      _ = (x ⊔ x ⊓ z ⊔ x \ y) ⊓ (y \ z ⊔ (x ⊓ z ⊔ x \ y)) := by ac_rfl
      _ = x ⊓ (y \ z ⊔ x ⊓ z ⊔ x \ y) := by rw [sup_inf_self, sup_sdiff_left, ← sup_assoc]
      _ = x ⊓ (y \ z ⊓ (z ⊔ y) ⊔ x ⊓ (z ⊔ y) ⊔ x \ y) := by
        rw [sup_inf_left, sdiff_sup_self', inf_sup_right, @sup_comm _ _ y]
      _ = x ⊓ (y \ z ⊔ (x ⊓ z ⊔ x ⊓ y) ⊔ x \ y) := by
        rw [inf_sdiff_sup_right, @inf_sup_left _ _ x z y]
      _ = x ⊓ (y \ z ⊔ (x ⊓ z ⊔ (x ⊓ y ⊔ x \ y))) := by ac_rfl
      _ = x ⊓ (y \ z ⊔ (x ⊔ x ⊓ z)) := by rw [sup_inf_sdiff, @sup_comm _ _ (x ⊓ z)]
      _ = x := by rw [sup_inf_self, sup_comm, inf_sup_self]
      
  ·
    calc
      x ⊓ y \ z ⊓ (z ⊓ x ⊔ x \ y) = x ⊓ y \ z ⊓ (z ⊓ x) ⊔ x ⊓ y \ z ⊓ x \ y := by rw [inf_sup_left]
      _ = x ⊓ (y \ z ⊓ z ⊓ x) ⊔ x ⊓ y \ z ⊓ x \ y := by ac_rfl
      _ = x ⊓ y \ z ⊓ x \ y := by rw [inf_sdiff_self_left, bot_inf_eq, inf_bot_eq, bot_sup_eq]
      _ = x ⊓ (y \ z ⊓ y) ⊓ x \ y := by conv_lhs => rw [← inf_sdiff_left]
      _ = x ⊓ (y \ z ⊓ (y ⊓ x \ y)) := by ac_rfl
      _ = ⊥ := by rw [inf_sdiff_self_right, inf_bot_eq, inf_bot_eq]
      
#align sdiff_sdiff_right sdiff_sdiff_right

/- warning: sdiff_sdiff_right' -> sdiff_sdiff_right' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y z)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x z))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y z)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) x z))
Case conversion may be inaccurate. Consider using '#align sdiff_sdiff_right' sdiff_sdiff_right'ₓ'. -/
theorem sdiff_sdiff_right' : x \ (y \ z) = x \ y ⊔ x ⊓ z :=
  calc
    x \ (y \ z) = x \ y ⊔ x ⊓ y ⊓ z := sdiff_sdiff_right
    _ = z ⊓ x ⊓ y ⊔ x \ y := by ac_rfl
    _ = x \ y ⊔ x ⊓ z := by rw [sup_inf_inf_sdiff, sup_comm, inf_comm]
    
#align sdiff_sdiff_right' sdiff_sdiff_right'

/- warning: sdiff_sdiff_eq_sdiff_sup -> sdiff_sdiff_eq_sdiff_sup is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z x) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y z)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) z))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z x) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y z)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) z))
Case conversion may be inaccurate. Consider using '#align sdiff_sdiff_eq_sdiff_sup sdiff_sdiff_eq_sdiff_supₓ'. -/
theorem sdiff_sdiff_eq_sdiff_sup (h : z ≤ x) : x \ (y \ z) = x \ y ⊔ z := by
  rw [sdiff_sdiff_right', inf_eq_right.2 h]
#align sdiff_sdiff_eq_sdiff_sup sdiff_sdiff_eq_sdiff_sup

/- warning: sdiff_sdiff_right_self -> sdiff_sdiff_right_self is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y)) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y)) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) x y)
Case conversion may be inaccurate. Consider using '#align sdiff_sdiff_right_self sdiff_sdiff_right_selfₓ'. -/
@[simp]
theorem sdiff_sdiff_right_self : x \ (x \ y) = x ⊓ y := by
  rw [sdiff_sdiff_right, inf_idem, sdiff_self, bot_sup_eq]
#align sdiff_sdiff_right_self sdiff_sdiff_right_self

/- warning: sdiff_sdiff_eq_self -> sdiff_sdiff_eq_self is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y x) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y)) y)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y x) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y)) y)
Case conversion may be inaccurate. Consider using '#align sdiff_sdiff_eq_self sdiff_sdiff_eq_selfₓ'. -/
theorem sdiff_sdiff_eq_self (h : y ≤ x) : x \ (x \ y) = y := by
  rw [sdiff_sdiff_right_self, inf_of_le_right h]
#align sdiff_sdiff_eq_self sdiff_sdiff_eq_self

/- warning: sdiff_eq_symm -> sdiff_eq_symm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y x) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) z) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x z) y)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y x) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) z) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x z) y)
Case conversion may be inaccurate. Consider using '#align sdiff_eq_symm sdiff_eq_symmₓ'. -/
theorem sdiff_eq_symm (hy : y ≤ x) (h : x \ y = z) : x \ z = y := by
  rw [← h, sdiff_sdiff_eq_self hy]
#align sdiff_eq_symm sdiff_eq_symm

/- warning: sdiff_eq_comm -> sdiff_eq_comm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y x) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z x) -> (Iff (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) z) (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x z) y))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y x) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) z x) -> (Iff (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) z) (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x z) y))
Case conversion may be inaccurate. Consider using '#align sdiff_eq_comm sdiff_eq_commₓ'. -/
theorem sdiff_eq_comm (hy : y ≤ x) (hz : z ≤ x) : x \ y = z ↔ x \ z = y :=
  ⟨sdiff_eq_symm hy, sdiff_eq_symm hz⟩
#align sdiff_eq_comm sdiff_eq_comm

/- warning: eq_of_sdiff_eq_sdiff -> eq_of_sdiff_eq_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x z) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y z) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) z x) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) z y)) -> (Eq.{succ u1} α x y)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x z) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y z) -> (Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) z x) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) z y)) -> (Eq.{succ u1} α x y)
Case conversion may be inaccurate. Consider using '#align eq_of_sdiff_eq_sdiff eq_of_sdiff_eq_sdiffₓ'. -/
theorem eq_of_sdiff_eq_sdiff (hxz : x ≤ z) (hyz : y ≤ z) (h : z \ x = z \ y) : x = y := by
  rw [← sdiff_sdiff_eq_self hxz, h, sdiff_sdiff_eq_self hyz]
#align eq_of_sdiff_eq_sdiff eq_of_sdiff_eq_sdiff

/- warning: sdiff_sdiff_left' -> sdiff_sdiff_left' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) z) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x z))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) z) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x z))
Case conversion may be inaccurate. Consider using '#align sdiff_sdiff_left' sdiff_sdiff_left'ₓ'. -/
theorem sdiff_sdiff_left' : (x \ y) \ z = x \ y ⊓ x \ z := by rw [sdiff_sdiff_left, sdiff_sup]
#align sdiff_sdiff_left' sdiff_sdiff_left'

/- warning: sdiff_sdiff_sup_sdiff -> sdiff_sdiff_sup_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) z (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) z (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) z x) y)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) z y) x))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) z (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) z (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) z x) y)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) z y) x))
Case conversion may be inaccurate. Consider using '#align sdiff_sdiff_sup_sdiff sdiff_sdiff_sup_sdiffₓ'. -/
theorem sdiff_sdiff_sup_sdiff : z \ (x \ y ⊔ y \ x) = z ⊓ (z \ x ⊔ y) ⊓ (z \ y ⊔ x) :=
  calc
    z \ (x \ y ⊔ y \ x) = (z \ x ⊔ z ⊓ x ⊓ y) ⊓ (z \ y ⊔ z ⊓ y ⊓ x) := by
      rw [sdiff_sup, sdiff_sdiff_right, sdiff_sdiff_right]
    _ = z ⊓ (z \ x ⊔ y) ⊓ (z \ y ⊔ z ⊓ y ⊓ x) := by rw [sup_inf_left, sup_comm, sup_inf_sdiff]
    _ = z ⊓ (z \ x ⊔ y) ⊓ (z ⊓ (z \ y ⊔ x)) := by
      rw [sup_inf_left, @sup_comm _ _ (z \ y), sup_inf_sdiff]
    _ = z ⊓ z ⊓ (z \ x ⊔ y) ⊓ (z \ y ⊔ x) := by ac_rfl
    _ = z ⊓ (z \ x ⊔ y) ⊓ (z \ y ⊔ x) := by rw [inf_idem]
    
#align sdiff_sdiff_sup_sdiff sdiff_sdiff_sup_sdiff

/- warning: sdiff_sdiff_sup_sdiff' -> sdiff_sdiff_sup_sdiff' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) z (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x))) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) z x) y) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) z x) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) z y)))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) z (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x))) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) z x) y) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) z x) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) z y)))
Case conversion may be inaccurate. Consider using '#align sdiff_sdiff_sup_sdiff' sdiff_sdiff_sup_sdiff'ₓ'. -/
theorem sdiff_sdiff_sup_sdiff' : z \ (x \ y ⊔ y \ x) = z ⊓ x ⊓ y ⊔ z \ x ⊓ z \ y :=
  calc
    z \ (x \ y ⊔ y \ x) = z \ (x \ y) ⊓ z \ (y \ x) := sdiff_sup
    _ = (z \ x ⊔ z ⊓ x ⊓ y) ⊓ (z \ y ⊔ z ⊓ y ⊓ x) := by rw [sdiff_sdiff_right, sdiff_sdiff_right]
    _ = (z \ x ⊔ z ⊓ y ⊓ x) ⊓ (z \ y ⊔ z ⊓ y ⊓ x) := by ac_rfl
    _ = z \ x ⊓ z \ y ⊔ z ⊓ y ⊓ x := sup_inf_right.symm
    _ = z ⊓ x ⊓ y ⊔ z \ x ⊓ z \ y := by ac_rfl
    
#align sdiff_sdiff_sup_sdiff' sdiff_sdiff_sup_sdiff'

/- warning: inf_sdiff -> inf_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y) z) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x z) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y z))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) x y) z) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x z) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y z))
Case conversion may be inaccurate. Consider using '#align inf_sdiff inf_sdiffₓ'. -/
theorem inf_sdiff : (x ⊓ y) \ z = x \ z ⊓ y \ z :=
  sdiff_unique
    (calc
      x ⊓ y ⊓ z ⊔ x \ z ⊓ y \ z = (x ⊓ y ⊓ z ⊔ x \ z) ⊓ (x ⊓ y ⊓ z ⊔ y \ z) := by rw [sup_inf_left]
      _ = (x ⊓ y ⊓ (z ⊔ x) ⊔ x \ z) ⊓ (x ⊓ y ⊓ z ⊔ y \ z) := by
        rw [sup_inf_right, sup_sdiff_self_right, inf_sup_right, inf_sdiff_sup_right]
      _ = (y ⊓ (x ⊓ (x ⊔ z)) ⊔ x \ z) ⊓ (x ⊓ y ⊓ z ⊔ y \ z) := by ac_rfl
      _ = (y ⊓ x ⊔ x \ z) ⊓ (x ⊓ y ⊔ y \ z) := by rw [inf_sup_self, sup_inf_inf_sdiff]
      _ = x ⊓ y ⊔ x \ z ⊓ y \ z := by rw [@inf_comm _ _ y, sup_inf_left]
      _ = x ⊓ y := sup_eq_left.2 (inf_le_inf sdiff_le sdiff_le)
      )
    (calc
      x ⊓ y ⊓ z ⊓ (x \ z ⊓ y \ z) = x ⊓ y ⊓ (z ⊓ x \ z) ⊓ y \ z := by ac_rfl
      _ = ⊥ := by rw [inf_sdiff_self_right, inf_bot_eq, bot_inf_eq]
      )
#align inf_sdiff inf_sdiff

/- warning: inf_sdiff_assoc -> inf_sdiff_assoc is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y) z) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y z))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) x y) z) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y z))
Case conversion may be inaccurate. Consider using '#align inf_sdiff_assoc inf_sdiff_assocₓ'. -/
theorem inf_sdiff_assoc : (x ⊓ y) \ z = x ⊓ y \ z :=
  sdiff_unique
    (calc
      x ⊓ y ⊓ z ⊔ x ⊓ y \ z = x ⊓ (y ⊓ z) ⊔ x ⊓ y \ z := by rw [inf_assoc]
      _ = x ⊓ (y ⊓ z ⊔ y \ z) := inf_sup_left.symm
      _ = x ⊓ y := by rw [sup_inf_sdiff]
      )
    (calc
      x ⊓ y ⊓ z ⊓ (x ⊓ y \ z) = x ⊓ x ⊓ (y ⊓ z ⊓ y \ z) := by ac_rfl
      _ = ⊥ := by rw [inf_inf_sdiff, inf_bot_eq]
      )
#align inf_sdiff_assoc inf_sdiff_assoc

/- warning: inf_sdiff_right_comm -> inf_sdiff_right_comm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x z) y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y) z)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x z) y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) x y) z)
Case conversion may be inaccurate. Consider using '#align inf_sdiff_right_comm inf_sdiff_right_commₓ'. -/
theorem inf_sdiff_right_comm : x \ z ⊓ y = (x ⊓ y) \ z := by
  rw [@inf_comm _ _ x, inf_comm, inf_sdiff_assoc]
#align inf_sdiff_right_comm inf_sdiff_right_comm

/- warning: inf_sdiff_distrib_left -> inf_sdiff_distrib_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α] (a : α) (b : α) (c : α), Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) a (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) b c)) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) a b) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) a c))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α] (a : α) (b : α) (c : α), Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) a (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) b c)) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) a b) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) a c))
Case conversion may be inaccurate. Consider using '#align inf_sdiff_distrib_left inf_sdiff_distrib_leftₓ'. -/
theorem inf_sdiff_distrib_left (a b c : α) : a ⊓ b \ c = (a ⊓ b) \ (a ⊓ c) := by
  rw [sdiff_inf, sdiff_eq_bot_iff.2 inf_le_left, bot_sup_eq, inf_sdiff_assoc]
#align inf_sdiff_distrib_left inf_sdiff_distrib_left

/- warning: inf_sdiff_distrib_right -> inf_sdiff_distrib_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α] (a : α) (b : α) (c : α), Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) a b) c) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) a c) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) b c))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α] (a : α) (b : α) (c : α), Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) a b) c) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) a c) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) b c))
Case conversion may be inaccurate. Consider using '#align inf_sdiff_distrib_right inf_sdiff_distrib_rightₓ'. -/
theorem inf_sdiff_distrib_right (a b c : α) : a \ b ⊓ c = (a ⊓ c) \ (b ⊓ c) := by
  simp_rw [@inf_comm _ _ _ c, inf_sdiff_distrib_left]
#align inf_sdiff_distrib_right inf_sdiff_distrib_right

/- warning: sup_eq_sdiff_sup_sdiff_sup_inf -> sup_eq_sdiff_sup_sdiff_sup_inf is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x)) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) x y) (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) y x)) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1))) x y))
Case conversion may be inaccurate. Consider using '#align sup_eq_sdiff_sup_sdiff_sup_inf sup_eq_sdiff_sup_sdiff_sup_infₓ'. -/
theorem sup_eq_sdiff_sup_sdiff_sup_inf : x ⊔ y = x \ y ⊔ y \ x ⊔ x ⊓ y :=
  Eq.symm <|
    calc
      x \ y ⊔ y \ x ⊔ x ⊓ y = (x \ y ⊔ y \ x ⊔ x) ⊓ (x \ y ⊔ y \ x ⊔ y) := by rw [sup_inf_left]
      _ = (x \ y ⊔ x ⊔ y \ x) ⊓ (x \ y ⊔ (y \ x ⊔ y)) := by ac_rfl
      _ = (x ⊔ y \ x) ⊓ (x \ y ⊔ y) := by rw [sup_sdiff_right, sup_sdiff_right]
      _ = x ⊔ y := by rw [sup_sdiff_self_right, sup_sdiff_self_left, inf_idem]
      
#align sup_eq_sdiff_sup_sdiff_sup_inf sup_eq_sdiff_sup_sdiff_sup_inf

/- warning: sup_lt_of_lt_sdiff_left -> sup_lt_of_lt_sdiff_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) z x)) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x z) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y) z)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) z x)) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x z) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y) z)
Case conversion may be inaccurate. Consider using '#align sup_lt_of_lt_sdiff_left sup_lt_of_lt_sdiff_leftₓ'. -/
theorem sup_lt_of_lt_sdiff_left (h : y < z \ x) (hxz : x ≤ z) : x ⊔ y < z :=
  by
  rw [← sup_sdiff_cancel_right hxz]
  refine' (sup_le_sup_left h.le _).lt_of_not_le fun h' => h.not_le _
  rw [← sdiff_idem]
  exact (sdiff_le_sdiff_of_sup_le_sup_left h').trans sdiff_le
#align sup_lt_of_lt_sdiff_left sup_lt_of_lt_sdiff_left

/- warning: sup_lt_of_lt_sdiff_right -> sup_lt_of_lt_sdiff_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toHasSdiff.{u1} α _inst_1) z y)) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y z) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y) z)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} {z : α} [_inst_1 : GeneralizedBooleanAlgebra.{u1} α], (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) x (SDiff.sdiff.{u1} α (GeneralizedBooleanAlgebra.toSDiff.{u1} α _inst_1) z y)) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) y z) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))))) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α _inst_1)))) x y) z)
Case conversion may be inaccurate. Consider using '#align sup_lt_of_lt_sdiff_right sup_lt_of_lt_sdiff_rightₓ'. -/
theorem sup_lt_of_lt_sdiff_right (h : x < z \ y) (hyz : y ≤ z) : x ⊔ y < z :=
  by
  rw [← sdiff_sup_cancel hyz]
  refine' (sup_le_sup_right h.le _).lt_of_not_le fun h' => h.not_le _
  rw [← sdiff_idem]
  exact (sdiff_le_sdiff_of_sup_le_sup_right h').trans sdiff_le
#align sup_lt_of_lt_sdiff_right sup_lt_of_lt_sdiff_right

#print Pi.generalizedBooleanAlgebra /-
instance Pi.generalizedBooleanAlgebra {α : Type u} {β : Type v} [GeneralizedBooleanAlgebra β] :
    GeneralizedBooleanAlgebra (α → β) := by pi_instance
#align pi.generalized_boolean_algebra Pi.generalizedBooleanAlgebra
-/

end GeneralizedBooleanAlgebra

/-!
### Boolean algebras
-/


#print BooleanAlgebra /-
/-- A Boolean algebra is a bounded distributive lattice with a complement operator `ᶜ` such that
`x ⊓ xᶜ = ⊥` and `x ⊔ xᶜ = ⊤`. For convenience, it must also provide a set difference operation `\`
and a Heyting implication `⇨` satisfying `x \ y = x ⊓ yᶜ` and `x ⇨ y = y ⊔ xᶜ`.

This is a generalization of (classical) logic of propositions, or the powerset lattice.

Since `bounded_order`, `order_bot`, and `order_top` are mixins that require `has_le`
to be present at define-time, the `extends` mechanism does not work with them.
Instead, we extend using the underlying `has_bot` and `has_top` data typeclasses, and replicate the
order axioms of those classes here. A "forgetful" instance back to `bounded_order` is provided.
-/
class BooleanAlgebra (α : Type u) extends DistribLattice α, HasCompl α, SDiff α, HImp α, Top α,
  Bot α where
  inf_compl_le_bot : ∀ x : α, x ⊓ xᶜ ≤ ⊥
  top_le_sup_compl : ∀ x : α, ⊤ ≤ x ⊔ xᶜ
  le_top : ∀ a : α, a ≤ ⊤
  bot_le : ∀ a : α, ⊥ ≤ a
  sdiff := fun x y => x ⊓ yᶜ
  himp := fun x y => y ⊔ xᶜ
  sdiff_eq : ∀ x y : α, x \ y = x ⊓ yᶜ := by obviously
  himp_eq : ∀ x y : α, x ⇨ y = y ⊔ xᶜ := by obviously
#align boolean_algebra BooleanAlgebra
-/

#print BooleanAlgebra.toBoundedOrder /-
-- see Note [lower instance priority]
instance (priority := 100) BooleanAlgebra.toBoundedOrder [h : BooleanAlgebra α] : BoundedOrder α :=
  { h with }
#align boolean_algebra.to_bounded_order BooleanAlgebra.toBoundedOrder
-/

#print GeneralizedBooleanAlgebra.toBooleanAlgebra /-
-- See note [reducible non instances]
/-- A bounded generalized boolean algebra is a boolean algebra. -/
@[reducible]
def GeneralizedBooleanAlgebra.toBooleanAlgebra [GeneralizedBooleanAlgebra α] [OrderTop α] :
    BooleanAlgebra α :=
  { ‹GeneralizedBooleanAlgebra α›, GeneralizedBooleanAlgebra.toOrderBot,
    ‹OrderTop α› with
    compl := fun a => ⊤ \ a
    inf_compl_le_bot := fun _ => disjoint_sdiff_self_right.le_bot
    top_le_sup_compl := fun _ => le_sup_sdiff
    sdiff_eq := fun _ _ => by
      rw [← inf_sdiff_assoc, inf_top_eq]
      rfl }
#align generalized_boolean_algebra.to_boolean_algebra GeneralizedBooleanAlgebra.toBooleanAlgebra
-/

section BooleanAlgebra

variable [BooleanAlgebra α]

/- warning: inf_compl_eq_bot' -> inf_compl_eq_bot' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (BooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) x (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x)) (Bot.bot.{u1} α (BooleanAlgebra.toHasBot.{u1} α _inst_1))
but is expected to have type
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (BooleanAlgebra.toDistribLattice.{u1} α _inst_1))) x (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x)) (Bot.bot.{u1} α (BooleanAlgebra.toBot.{u1} α _inst_1))
Case conversion may be inaccurate. Consider using '#align inf_compl_eq_bot' inf_compl_eq_bot'ₓ'. -/
@[simp]
theorem inf_compl_eq_bot' : x ⊓ xᶜ = ⊥ :=
  bot_unique <| BooleanAlgebra.inf_compl_le_bot x
#align inf_compl_eq_bot' inf_compl_eq_bot'

/- warning: sup_compl_eq_top -> sup_compl_eq_top is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (BooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) x (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x)) (Top.top.{u1} α (BooleanAlgebra.toHasTop.{u1} α _inst_1))
but is expected to have type
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (BooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) x (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x)) (Top.top.{u1} α (BooleanAlgebra.toTop.{u1} α _inst_1))
Case conversion may be inaccurate. Consider using '#align sup_compl_eq_top sup_compl_eq_topₓ'. -/
@[simp]
theorem sup_compl_eq_top : x ⊔ xᶜ = ⊤ :=
  top_unique <| BooleanAlgebra.top_le_sup_compl x
#align sup_compl_eq_top sup_compl_eq_top

/- warning: compl_sup_eq_top -> compl_sup_eq_top is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (BooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x) x) (Top.top.{u1} α (BooleanAlgebra.toHasTop.{u1} α _inst_1))
but is expected to have type
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (BooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x) x) (Top.top.{u1} α (BooleanAlgebra.toTop.{u1} α _inst_1))
Case conversion may be inaccurate. Consider using '#align compl_sup_eq_top compl_sup_eq_topₓ'. -/
@[simp]
theorem compl_sup_eq_top : xᶜ ⊔ x = ⊤ :=
  sup_comm.trans sup_compl_eq_top
#align compl_sup_eq_top compl_sup_eq_top

#print is_compl_compl /-
theorem is_compl_compl : IsCompl x (xᶜ) :=
  IsCompl.of_eq inf_compl_eq_bot' sup_compl_eq_top
#align is_compl_compl is_compl_compl
-/

/- warning: sdiff_eq -> sdiff_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (BooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (BooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) x (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) y))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (BooleanAlgebra.toSDiff.{u1} α _inst_1) x y) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α (BooleanAlgebra.toDistribLattice.{u1} α _inst_1))) x (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) y))
Case conversion may be inaccurate. Consider using '#align sdiff_eq sdiff_eqₓ'. -/
theorem sdiff_eq : x \ y = x ⊓ yᶜ :=
  BooleanAlgebra.sdiff_eq x y
#align sdiff_eq sdiff_eq

/- warning: himp_eq -> himp_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HImp.himp.{u1} α (BooleanAlgebra.toHasHimp.{u1} α _inst_1) x y) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (BooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) y (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x))
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HImp.himp.{u1} α (BooleanAlgebra.toHImp.{u1} α _inst_1) x y) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (BooleanAlgebra.toDistribLattice.{u1} α _inst_1)))) y (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x))
Case conversion may be inaccurate. Consider using '#align himp_eq himp_eqₓ'. -/
theorem himp_eq : x ⇨ y = y ⊔ xᶜ :=
  BooleanAlgebra.himp_eq x y
#align himp_eq himp_eq

#print BooleanAlgebra.toComplementedLattice /-
instance (priority := 100) BooleanAlgebra.toComplementedLattice : ComplementedLattice α :=
  ⟨fun x => ⟨xᶜ, is_compl_compl⟩⟩
#align boolean_algebra.to_complemented_lattice BooleanAlgebra.toComplementedLattice
-/

#print BooleanAlgebra.toGeneralizedBooleanAlgebra /-
-- see Note [lower instance priority]
instance (priority := 100) BooleanAlgebra.toGeneralizedBooleanAlgebra :
    GeneralizedBooleanAlgebra α :=
  {
    ‹BooleanAlgebra
        α› with
    sup_inf_sdiff := fun a b => by rw [sdiff_eq, ← inf_sup_left, sup_compl_eq_top, inf_top_eq]
    inf_inf_sdiff := fun a b =>
      by
      rw [sdiff_eq, ← inf_inf_distrib_left, inf_compl_eq_bot', inf_bot_eq]
      congr }
#align boolean_algebra.to_generalized_boolean_algebra BooleanAlgebra.toGeneralizedBooleanAlgebra
-/

#print BooleanAlgebra.toBiheytingAlgebra /-
-- See note [lower instance priority]
instance (priority := 100) BooleanAlgebra.toBiheytingAlgebra : BiheytingAlgebra α :=
  { ‹BooleanAlgebra α›,
    GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra with
    hnot := compl
    le_himp_iff := fun a b c => by rw [himp_eq, is_compl_compl.le_sup_right_iff_inf_left_le]
    himp_bot := fun _ => himp_eq.trans bot_sup_eq
    top_sdiff := fun a => by rw [sdiff_eq, top_inf_eq] }
#align boolean_algebra.to_biheyting_algebra BooleanAlgebra.toBiheytingAlgebra
-/

/- warning: hnot_eq_compl -> hnot_eq_compl is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HNot.hnot.{u1} α (BiheytingAlgebra.toHasHnot.{u1} α (BooleanAlgebra.toBiheytingAlgebra.{u1} α _inst_1)) x) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x)
but is expected to have type
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HNot.hnot.{u1} α (BiheytingAlgebra.toHNot.{u1} α (BooleanAlgebra.toBiheytingAlgebra.{u1} α _inst_1)) x) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x)
Case conversion may be inaccurate. Consider using '#align hnot_eq_compl hnot_eq_complₓ'. -/
@[simp]
theorem hnot_eq_compl : ￢x = xᶜ :=
  rfl
#align hnot_eq_compl hnot_eq_compl

/- warning: top_sdiff -> top_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (BooleanAlgebra.toHasSdiff.{u1} α _inst_1) (Top.top.{u1} α (BooleanAlgebra.toHasTop.{u1} α _inst_1)) x) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x)
but is expected to have type
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (BooleanAlgebra.toSDiff.{u1} α _inst_1) (Top.top.{u1} α (BooleanAlgebra.toTop.{u1} α _inst_1)) x) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x)
Case conversion may be inaccurate. Consider using '#align top_sdiff top_sdiffₓ'. -/
@[simp]
theorem top_sdiff : ⊤ \ x = xᶜ :=
  top_sdiff' _
#align top_sdiff top_sdiff

#print eq_compl_iff_is_compl /-
theorem eq_compl_iff_is_compl : x = yᶜ ↔ IsCompl x y :=
  ⟨fun h => by
    rw [h]
    exact is_compl_compl.symm, IsCompl.eq_compl⟩
#align eq_compl_iff_is_compl eq_compl_iff_is_compl
-/

#print compl_eq_iff_is_compl /-
theorem compl_eq_iff_is_compl : xᶜ = y ↔ IsCompl x y :=
  ⟨fun h => by
    rw [← h]
    exact is_compl_compl, IsCompl.compl_eq⟩
#align compl_eq_iff_is_compl compl_eq_iff_is_compl
-/

#print compl_eq_comm /-
theorem compl_eq_comm : xᶜ = y ↔ yᶜ = x := by
  rw [eq_comm, compl_eq_iff_is_compl, eq_compl_iff_is_compl]
#align compl_eq_comm compl_eq_comm
-/

#print eq_compl_comm /-
theorem eq_compl_comm : x = yᶜ ↔ y = xᶜ := by
  rw [eq_comm, compl_eq_iff_is_compl, eq_compl_iff_is_compl]
#align eq_compl_comm eq_compl_comm
-/

#print compl_compl /-
@[simp]
theorem compl_compl (x : α) : xᶜᶜ = x :=
  (@is_compl_compl _ x _).symm.compl_eq
#align compl_compl compl_compl
-/

#print compl_comp_compl /-
theorem compl_comp_compl : compl ∘ compl = @id α :=
  funext compl_compl
#align compl_comp_compl compl_comp_compl
-/

#print compl_involutive /-
@[simp]
theorem compl_involutive : Function.Involutive (compl : α → α) :=
  compl_compl
#align compl_involutive compl_involutive
-/

#print compl_bijective /-
theorem compl_bijective : Function.Bijective (compl : α → α) :=
  compl_involutive.Bijective
#align compl_bijective compl_bijective
-/

#print compl_surjective /-
theorem compl_surjective : Function.Surjective (compl : α → α) :=
  compl_involutive.Surjective
#align compl_surjective compl_surjective
-/

#print compl_injective /-
theorem compl_injective : Function.Injective (compl : α → α) :=
  compl_involutive.Injective
#align compl_injective compl_injective
-/

#print compl_inj_iff /-
@[simp]
theorem compl_inj_iff : xᶜ = yᶜ ↔ x = y :=
  compl_injective.eq_iff
#align compl_inj_iff compl_inj_iff
-/

#print IsCompl.compl_eq_iff /-
theorem IsCompl.compl_eq_iff (h : IsCompl x y) : zᶜ = y ↔ z = x :=
  h.compl_eq ▸ compl_inj_iff
#align is_compl.compl_eq_iff IsCompl.compl_eq_iff
-/

/- warning: compl_eq_top -> compl_eq_top is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Iff (Eq.{succ u1} α (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x) (Top.top.{u1} α (BooleanAlgebra.toHasTop.{u1} α _inst_1))) (Eq.{succ u1} α x (Bot.bot.{u1} α (BooleanAlgebra.toHasBot.{u1} α _inst_1)))
but is expected to have type
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Iff (Eq.{succ u1} α (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x) (Top.top.{u1} α (BooleanAlgebra.toTop.{u1} α _inst_1))) (Eq.{succ u1} α x (Bot.bot.{u1} α (BooleanAlgebra.toBot.{u1} α _inst_1)))
Case conversion may be inaccurate. Consider using '#align compl_eq_top compl_eq_topₓ'. -/
@[simp]
theorem compl_eq_top : xᶜ = ⊤ ↔ x = ⊥ :=
  isCompl_bot_top.compl_eq_iff
#align compl_eq_top compl_eq_top

/- warning: compl_eq_bot -> compl_eq_bot is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Iff (Eq.{succ u1} α (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x) (Bot.bot.{u1} α (BooleanAlgebra.toHasBot.{u1} α _inst_1))) (Eq.{succ u1} α x (Top.top.{u1} α (BooleanAlgebra.toHasTop.{u1} α _inst_1)))
but is expected to have type
  forall {α : Type.{u1}} {x : α} [_inst_1 : BooleanAlgebra.{u1} α], Iff (Eq.{succ u1} α (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x) (Bot.bot.{u1} α (BooleanAlgebra.toBot.{u1} α _inst_1))) (Eq.{succ u1} α x (Top.top.{u1} α (BooleanAlgebra.toTop.{u1} α _inst_1)))
Case conversion may be inaccurate. Consider using '#align compl_eq_bot compl_eq_botₓ'. -/
@[simp]
theorem compl_eq_bot : xᶜ = ⊥ ↔ x = ⊤ :=
  isCompl_top_bot.compl_eq_iff
#align compl_eq_bot compl_eq_bot

#print compl_inf /-
@[simp]
theorem compl_inf : (x ⊓ y)ᶜ = xᶜ ⊔ yᶜ :=
  hnot_inf_distrib _ _
#align compl_inf compl_inf
-/

#print compl_le_compl_iff_le /-
@[simp]
theorem compl_le_compl_iff_le : yᶜ ≤ xᶜ ↔ x ≤ y :=
  ⟨fun h => by have h := compl_le_compl h <;> simp at h <;> assumption, compl_le_compl⟩
#align compl_le_compl_iff_le compl_le_compl_iff_le
-/

#print compl_le_of_compl_le /-
theorem compl_le_of_compl_le (h : yᶜ ≤ x) : xᶜ ≤ y := by
  simpa only [compl_compl] using compl_le_compl h
#align compl_le_of_compl_le compl_le_of_compl_le
-/

#print compl_le_iff_compl_le /-
theorem compl_le_iff_compl_le : xᶜ ≤ y ↔ yᶜ ≤ x :=
  ⟨compl_le_of_compl_le, compl_le_of_compl_le⟩
#align compl_le_iff_compl_le compl_le_iff_compl_le
-/

/- warning: sdiff_compl -> sdiff_compl is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (BooleanAlgebra.toHasSdiff.{u1} α _inst_1) x (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) y)) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u1} α (BooleanAlgebra.toGeneralizedBooleanAlgebra.{u1} α _inst_1))))) x y)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (BooleanAlgebra.toSDiff.{u1} α _inst_1) x (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) y)) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (GeneralizedCoheytingAlgebra.toLattice.{u1} α (CoheytingAlgebra.toGeneralizedCoheytingAlgebra.{u1} α (BiheytingAlgebra.toCoheytingAlgebra.{u1} α (BooleanAlgebra.toBiheytingAlgebra.{u1} α _inst_1))))) x y)
Case conversion may be inaccurate. Consider using '#align sdiff_compl sdiff_complₓ'. -/
@[simp]
theorem sdiff_compl : x \ yᶜ = x ⊓ y := by rw [sdiff_eq, compl_compl]
#align sdiff_compl sdiff_compl

instance : BooleanAlgebra αᵒᵈ :=
  { OrderDual.distribLattice α,
    OrderDual.boundedOrder α with
    compl := fun a => toDual (ofDual aᶜ)
    sdiff := fun a b => toDual (ofDual b ⇨ ofDual a)
    himp := fun a b => toDual (ofDual b \ ofDual a)
    inf_compl_le_bot := fun a => (@codisjoint_hnot_right _ _ (ofDual a)).top_le
    top_le_sup_compl := fun a => (@disjoint_compl_right _ _ (ofDual a)).le_bot
    sdiff_eq := fun _ _ => himp_eq
    himp_eq := fun _ _ => sdiff_eq }

#print sup_inf_inf_compl /-
@[simp]
theorem sup_inf_inf_compl : x ⊓ y ⊔ x ⊓ yᶜ = x := by rw [← sdiff_eq, sup_inf_sdiff _ _]
#align sup_inf_inf_compl sup_inf_inf_compl
-/

/- warning: compl_sdiff -> compl_sdiff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) (SDiff.sdiff.{u1} α (BooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y)) (HImp.himp.{u1} α (BooleanAlgebra.toHasHimp.{u1} α _inst_1) x y)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) (SDiff.sdiff.{u1} α (BooleanAlgebra.toSDiff.{u1} α _inst_1) x y)) (HImp.himp.{u1} α (BooleanAlgebra.toHImp.{u1} α _inst_1) x y)
Case conversion may be inaccurate. Consider using '#align compl_sdiff compl_sdiffₓ'. -/
@[simp]
theorem compl_sdiff : (x \ y)ᶜ = x ⇨ y := by
  rw [sdiff_eq, himp_eq, compl_inf, compl_compl, sup_comm]
#align compl_sdiff compl_sdiff

/- warning: compl_himp -> compl_himp is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) (HImp.himp.{u1} α (BooleanAlgebra.toHasHimp.{u1} α _inst_1) x y)) (SDiff.sdiff.{u1} α (BooleanAlgebra.toHasSdiff.{u1} α _inst_1) x y)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) (HImp.himp.{u1} α (BooleanAlgebra.toHImp.{u1} α _inst_1) x y)) (SDiff.sdiff.{u1} α (BooleanAlgebra.toSDiff.{u1} α _inst_1) x y)
Case conversion may be inaccurate. Consider using '#align compl_himp compl_himpₓ'. -/
@[simp]
theorem compl_himp : (x ⇨ y)ᶜ = x \ y :=
  @compl_sdiff αᵒᵈ _ _ _
#align compl_himp compl_himp

/- warning: compl_sdiff_compl -> compl_sdiff_compl is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (BooleanAlgebra.toHasSdiff.{u1} α _inst_1) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) y)) (SDiff.sdiff.{u1} α (BooleanAlgebra.toHasSdiff.{u1} α _inst_1) y x)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (SDiff.sdiff.{u1} α (BooleanAlgebra.toSDiff.{u1} α _inst_1) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) y)) (SDiff.sdiff.{u1} α (BooleanAlgebra.toSDiff.{u1} α _inst_1) y x)
Case conversion may be inaccurate. Consider using '#align compl_sdiff_compl compl_sdiff_complₓ'. -/
@[simp]
theorem compl_sdiff_compl : xᶜ \ yᶜ = y \ x := by rw [sdiff_compl, sdiff_eq, inf_comm]
#align compl_sdiff_compl compl_sdiff_compl

/- warning: compl_himp_compl -> compl_himp_compl is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HImp.himp.{u1} α (BooleanAlgebra.toHasHimp.{u1} α _inst_1) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) y)) (HImp.himp.{u1} α (BooleanAlgebra.toHasHimp.{u1} α _inst_1) y x)
but is expected to have type
  forall {α : Type.{u1}} {x : α} {y : α} [_inst_1 : BooleanAlgebra.{u1} α], Eq.{succ u1} α (HImp.himp.{u1} α (BooleanAlgebra.toHImp.{u1} α _inst_1) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) x) (HasCompl.compl.{u1} α (BooleanAlgebra.toHasCompl.{u1} α _inst_1) y)) (HImp.himp.{u1} α (BooleanAlgebra.toHImp.{u1} α _inst_1) y x)
Case conversion may be inaccurate. Consider using '#align compl_himp_compl compl_himp_complₓ'. -/
@[simp]
theorem compl_himp_compl : xᶜ ⇨ yᶜ = y ⇨ x :=
  @compl_sdiff_compl αᵒᵈ _ _ _
#align compl_himp_compl compl_himp_compl

#print disjoint_compl_left_iff /-
theorem disjoint_compl_left_iff : Disjoint (xᶜ) y ↔ y ≤ x := by
  rw [← le_compl_iff_disjoint_left, compl_compl]
#align disjoint_compl_left_iff disjoint_compl_left_iff
-/

#print disjoint_compl_right_iff /-
theorem disjoint_compl_right_iff : Disjoint x (yᶜ) ↔ x ≤ y := by
  rw [← le_compl_iff_disjoint_right, compl_compl]
#align disjoint_compl_right_iff disjoint_compl_right_iff
-/

end BooleanAlgebra

#print Prop.booleanAlgebra /-
instance Prop.booleanAlgebra : BooleanAlgebra Prop :=
  { Prop.heytingAlgebra,
    GeneralizedHeytingAlgebra.toDistribLattice with
    compl := Not
    himp_eq := fun p q => propext imp_iff_or_not
    inf_compl_le_bot := fun p ⟨Hp, Hpc⟩ => Hpc Hp
    top_le_sup_compl := fun p H => Classical.em p }
#align Prop.boolean_algebra Prop.booleanAlgebra
-/

#print Pi.booleanAlgebra /-
instance Pi.booleanAlgebra {ι : Type u} {α : ι → Type v} [∀ i, BooleanAlgebra (α i)] :
    BooleanAlgebra (∀ i, α i) :=
  { Pi.sdiff, Pi.heytingAlgebra,
    Pi.distribLattice with
    sdiff_eq := fun x y => funext fun i => sdiff_eq
    himp_eq := fun x y => funext fun i => himp_eq
    inf_compl_le_bot := fun _ _ => BooleanAlgebra.inf_compl_le_bot _
    top_le_sup_compl := fun _ _ => BooleanAlgebra.top_le_sup_compl _ }
#align pi.boolean_algebra Pi.booleanAlgebra
-/

instance : BooleanAlgebra Bool :=
  { Bool.linearOrder, Bool.boundedOrder with
    sup := or
    le_sup_left := Bool.left_le_or
    le_sup_right := Bool.right_le_or
    sup_le := fun _ _ _ => Bool.or_le
    inf := and
    inf_le_left := Bool.and_le_left
    inf_le_right := Bool.and_le_right
    le_inf := fun _ _ _ => Bool.le_and
    le_sup_inf := by decide
    compl := not
    inf_compl_le_bot := fun a => a.band_bnot_self.le
    top_le_sup_compl := fun a => a.bor_bnot_self.ge }

/- warning: bool.sup_eq_bor -> Bool.sup_eq_bor is a dubious translation:
lean 3 declaration is
  Eq.{1} (Bool -> Bool -> Bool) (HasSup.sup.{0} Bool (SemilatticeSup.toHasSup.{0} Bool (Lattice.toSemilatticeSup.{0} Bool (GeneralizedCoheytingAlgebra.toLattice.{0} Bool (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{0} Bool (BooleanAlgebra.toGeneralizedBooleanAlgebra.{0} Bool Bool.booleanAlgebra)))))) or
but is expected to have type
  Eq.{1} (Bool -> Bool -> Bool) (fun (x._@.Mathlib.Order.BooleanAlgebra._hyg.10906 : Bool) (x._@.Mathlib.Order.BooleanAlgebra._hyg.10908 : Bool) => HasSup.sup.{0} Bool (SemilatticeSup.toHasSup.{0} Bool (Lattice.toSemilatticeSup.{0} Bool (GeneralizedCoheytingAlgebra.toLattice.{0} Bool (CoheytingAlgebra.toGeneralizedCoheytingAlgebra.{0} Bool (BiheytingAlgebra.toCoheytingAlgebra.{0} Bool (BooleanAlgebra.toBiheytingAlgebra.{0} Bool instBooleanAlgebraBool)))))) x._@.Mathlib.Order.BooleanAlgebra._hyg.10906 x._@.Mathlib.Order.BooleanAlgebra._hyg.10908) or
Case conversion may be inaccurate. Consider using '#align bool.sup_eq_bor Bool.sup_eq_borₓ'. -/
@[simp]
theorem Bool.sup_eq_bor : (· ⊔ ·) = or :=
  rfl
#align bool.sup_eq_bor Bool.sup_eq_bor

/- warning: bool.inf_eq_band -> Bool.inf_eq_band is a dubious translation:
lean 3 declaration is
  Eq.{1} (Bool -> Bool -> Bool) (HasInf.inf.{0} Bool (SemilatticeInf.toHasInf.{0} Bool (Lattice.toSemilatticeInf.{0} Bool (GeneralizedCoheytingAlgebra.toLattice.{0} Bool (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{0} Bool (BooleanAlgebra.toGeneralizedBooleanAlgebra.{0} Bool Bool.booleanAlgebra)))))) and
but is expected to have type
  Eq.{1} (Bool -> Bool -> Bool) (fun (x._@.Mathlib.Order.BooleanAlgebra._hyg.10938 : Bool) (x._@.Mathlib.Order.BooleanAlgebra._hyg.10940 : Bool) => HasInf.inf.{0} Bool (Lattice.toHasInf.{0} Bool (GeneralizedCoheytingAlgebra.toLattice.{0} Bool (CoheytingAlgebra.toGeneralizedCoheytingAlgebra.{0} Bool (BiheytingAlgebra.toCoheytingAlgebra.{0} Bool (BooleanAlgebra.toBiheytingAlgebra.{0} Bool instBooleanAlgebraBool))))) x._@.Mathlib.Order.BooleanAlgebra._hyg.10938 x._@.Mathlib.Order.BooleanAlgebra._hyg.10940) and
Case conversion may be inaccurate. Consider using '#align bool.inf_eq_band Bool.inf_eq_bandₓ'. -/
@[simp]
theorem Bool.inf_eq_band : (· ⊓ ·) = and :=
  rfl
#align bool.inf_eq_band Bool.inf_eq_band

/- warning: bool.compl_eq_bnot -> Bool.compl_eq_bnot is a dubious translation:
lean 3 declaration is
  Eq.{1} (Bool -> Bool) (HasCompl.compl.{0} Bool (BooleanAlgebra.toHasCompl.{0} Bool Bool.booleanAlgebra)) not
but is expected to have type
  Eq.{1} (Bool -> Bool) (HasCompl.compl.{0} Bool (BooleanAlgebra.toHasCompl.{0} Bool instBooleanAlgebraBool)) not
Case conversion may be inaccurate. Consider using '#align bool.compl_eq_bnot Bool.compl_eq_bnotₓ'. -/
@[simp]
theorem Bool.compl_eq_bnot : HasCompl.compl = not :=
  rfl
#align bool.compl_eq_bnot Bool.compl_eq_bnot

section lift

/- warning: function.injective.generalized_boolean_algebra -> Function.Injective.generalizedBooleanAlgebra is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : HasSup.{u1} α] [_inst_2 : HasInf.{u1} α] [_inst_3 : Bot.{u1} α] [_inst_4 : SDiff.{u1} α] [_inst_5 : GeneralizedBooleanAlgebra.{u2} β] (f : α -> β), (Function.Injective.{succ u1, succ u2} α β f) -> (forall (a : α) (b : α), Eq.{succ u2} β (f (HasSup.sup.{u1} α _inst_1 a b)) (HasSup.sup.{u2} β (SemilatticeSup.toHasSup.{u2} β (Lattice.toSemilatticeSup.{u2} β (GeneralizedCoheytingAlgebra.toLattice.{u2} β (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u2} β _inst_5)))) (f a) (f b))) -> (forall (a : α) (b : α), Eq.{succ u2} β (f (HasInf.inf.{u1} α _inst_2 a b)) (HasInf.inf.{u2} β (SemilatticeInf.toHasInf.{u2} β (Lattice.toSemilatticeInf.{u2} β (GeneralizedCoheytingAlgebra.toLattice.{u2} β (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u2} β _inst_5)))) (f a) (f b))) -> (Eq.{succ u2} β (f (Bot.bot.{u1} α _inst_3)) (Bot.bot.{u2} β (GeneralizedBooleanAlgebra.toHasBot.{u2} β _inst_5))) -> (forall (a : α) (b : α), Eq.{succ u2} β (f (SDiff.sdiff.{u1} α _inst_4 a b)) (SDiff.sdiff.{u2} β (GeneralizedBooleanAlgebra.toHasSdiff.{u2} β _inst_5) (f a) (f b))) -> (GeneralizedBooleanAlgebra.{u1} α)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : HasSup.{u1} α] [_inst_2 : HasInf.{u1} α] [_inst_3 : Bot.{u1} α] [_inst_4 : SDiff.{u1} α] [_inst_5 : GeneralizedBooleanAlgebra.{u2} β] (f : α -> β), (Function.Injective.{succ u1, succ u2} α β f) -> (forall (a : α) (b : α), Eq.{succ u2} β (f (HasSup.sup.{u1} α _inst_1 a b)) (HasSup.sup.{u2} β (SemilatticeSup.toHasSup.{u2} β (Lattice.toSemilatticeSup.{u2} β (GeneralizedCoheytingAlgebra.toLattice.{u2} β (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u2} β _inst_5)))) (f a) (f b))) -> (forall (a : α) (b : α), Eq.{succ u2} β (f (HasInf.inf.{u1} α _inst_2 a b)) (HasInf.inf.{u2} β (Lattice.toHasInf.{u2} β (GeneralizedCoheytingAlgebra.toLattice.{u2} β (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u2} β _inst_5))) (f a) (f b))) -> (Eq.{succ u2} β (f (Bot.bot.{u1} α _inst_3)) (Bot.bot.{u2} β (GeneralizedBooleanAlgebra.toBot.{u2} β _inst_5))) -> (forall (a : α) (b : α), Eq.{succ u2} β (f (SDiff.sdiff.{u1} α _inst_4 a b)) (SDiff.sdiff.{u2} β (GeneralizedBooleanAlgebra.toSDiff.{u2} β _inst_5) (f a) (f b))) -> (GeneralizedBooleanAlgebra.{u1} α)
Case conversion may be inaccurate. Consider using '#align function.injective.generalized_boolean_algebra Function.Injective.generalizedBooleanAlgebraₓ'. -/
-- See note [reducible non-instances]
/-- Pullback a `generalized_boolean_algebra` along an injection. -/
@[reducible]
protected def Function.Injective.generalizedBooleanAlgebra [HasSup α] [HasInf α] [Bot α] [SDiff α]
    [GeneralizedBooleanAlgebra β] (f : α → β) (hf : Injective f)
    (map_sup : ∀ a b, f (a ⊔ b) = f a ⊔ f b) (map_inf : ∀ a b, f (a ⊓ b) = f a ⊓ f b)
    (map_bot : f ⊥ = ⊥) (map_sdiff : ∀ a b, f (a \ b) = f a \ f b) : GeneralizedBooleanAlgebra α :=
  { hf.GeneralizedCoheytingAlgebra f map_sup map_inf map_bot map_sdiff,
    hf.DistribLattice f map_sup
      map_inf with
    sup_inf_sdiff := fun a b => hf <| by erw [map_sup, map_sdiff, map_inf, sup_inf_sdiff]
    inf_inf_sdiff := fun a b => hf <| by erw [map_inf, map_sdiff, map_inf, inf_inf_sdiff, map_bot] }
#align function.injective.generalized_boolean_algebra Function.Injective.generalizedBooleanAlgebra

/- warning: function.injective.boolean_algebra -> Function.Injective.booleanAlgebra is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : HasSup.{u1} α] [_inst_2 : HasInf.{u1} α] [_inst_3 : Top.{u1} α] [_inst_4 : Bot.{u1} α] [_inst_5 : HasCompl.{u1} α] [_inst_6 : SDiff.{u1} α] [_inst_7 : BooleanAlgebra.{u2} β] (f : α -> β), (Function.Injective.{succ u1, succ u2} α β f) -> (forall (a : α) (b : α), Eq.{succ u2} β (f (HasSup.sup.{u1} α _inst_1 a b)) (HasSup.sup.{u2} β (SemilatticeSup.toHasSup.{u2} β (Lattice.toSemilatticeSup.{u2} β (GeneralizedCoheytingAlgebra.toLattice.{u2} β (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u2} β (BooleanAlgebra.toGeneralizedBooleanAlgebra.{u2} β _inst_7))))) (f a) (f b))) -> (forall (a : α) (b : α), Eq.{succ u2} β (f (HasInf.inf.{u1} α _inst_2 a b)) (HasInf.inf.{u2} β (SemilatticeInf.toHasInf.{u2} β (Lattice.toSemilatticeInf.{u2} β (GeneralizedCoheytingAlgebra.toLattice.{u2} β (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{u2} β (BooleanAlgebra.toGeneralizedBooleanAlgebra.{u2} β _inst_7))))) (f a) (f b))) -> (Eq.{succ u2} β (f (Top.top.{u1} α _inst_3)) (Top.top.{u2} β (BooleanAlgebra.toHasTop.{u2} β _inst_7))) -> (Eq.{succ u2} β (f (Bot.bot.{u1} α _inst_4)) (Bot.bot.{u2} β (BooleanAlgebra.toHasBot.{u2} β _inst_7))) -> (forall (a : α), Eq.{succ u2} β (f (HasCompl.compl.{u1} α _inst_5 a)) (HasCompl.compl.{u2} β (BooleanAlgebra.toHasCompl.{u2} β _inst_7) (f a))) -> (forall (a : α) (b : α), Eq.{succ u2} β (f (SDiff.sdiff.{u1} α _inst_6 a b)) (SDiff.sdiff.{u2} β (BooleanAlgebra.toHasSdiff.{u2} β _inst_7) (f a) (f b))) -> (BooleanAlgebra.{u1} α)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : HasSup.{u1} α] [_inst_2 : HasInf.{u1} α] [_inst_3 : Top.{u1} α] [_inst_4 : Bot.{u1} α] [_inst_5 : HasCompl.{u1} α] [_inst_6 : SDiff.{u1} α] [_inst_7 : BooleanAlgebra.{u2} β] (f : α -> β), (Function.Injective.{succ u1, succ u2} α β f) -> (forall (a : α) (b : α), Eq.{succ u2} β (f (HasSup.sup.{u1} α _inst_1 a b)) (HasSup.sup.{u2} β (SemilatticeSup.toHasSup.{u2} β (Lattice.toSemilatticeSup.{u2} β (GeneralizedCoheytingAlgebra.toLattice.{u2} β (CoheytingAlgebra.toGeneralizedCoheytingAlgebra.{u2} β (BiheytingAlgebra.toCoheytingAlgebra.{u2} β (BooleanAlgebra.toBiheytingAlgebra.{u2} β _inst_7)))))) (f a) (f b))) -> (forall (a : α) (b : α), Eq.{succ u2} β (f (HasInf.inf.{u1} α _inst_2 a b)) (HasInf.inf.{u2} β (Lattice.toHasInf.{u2} β (GeneralizedCoheytingAlgebra.toLattice.{u2} β (CoheytingAlgebra.toGeneralizedCoheytingAlgebra.{u2} β (BiheytingAlgebra.toCoheytingAlgebra.{u2} β (BooleanAlgebra.toBiheytingAlgebra.{u2} β _inst_7))))) (f a) (f b))) -> (Eq.{succ u2} β (f (Top.top.{u1} α _inst_3)) (Top.top.{u2} β (BooleanAlgebra.toTop.{u2} β _inst_7))) -> (Eq.{succ u2} β (f (Bot.bot.{u1} α _inst_4)) (Bot.bot.{u2} β (BooleanAlgebra.toBot.{u2} β _inst_7))) -> (forall (a : α), Eq.{succ u2} β (f (HasCompl.compl.{u1} α _inst_5 a)) (HasCompl.compl.{u2} β (BooleanAlgebra.toHasCompl.{u2} β _inst_7) (f a))) -> (forall (a : α) (b : α), Eq.{succ u2} β (f (SDiff.sdiff.{u1} α _inst_6 a b)) (SDiff.sdiff.{u2} β (BooleanAlgebra.toSDiff.{u2} β _inst_7) (f a) (f b))) -> (BooleanAlgebra.{u1} α)
Case conversion may be inaccurate. Consider using '#align function.injective.boolean_algebra Function.Injective.booleanAlgebraₓ'. -/
-- See note [reducible non-instances]
/-- Pullback a `boolean_algebra` along an injection. -/
@[reducible]
protected def Function.Injective.booleanAlgebra [HasSup α] [HasInf α] [Top α] [Bot α] [HasCompl α]
    [SDiff α] [BooleanAlgebra β] (f : α → β) (hf : Injective f)
    (map_sup : ∀ a b, f (a ⊔ b) = f a ⊔ f b) (map_inf : ∀ a b, f (a ⊓ b) = f a ⊓ f b)
    (map_top : f ⊤ = ⊤) (map_bot : f ⊥ = ⊥) (map_compl : ∀ a, f (aᶜ) = f aᶜ)
    (map_sdiff : ∀ a b, f (a \ b) = f a \ f b) : BooleanAlgebra α :=
  {
    hf.GeneralizedBooleanAlgebra f map_sup map_inf map_bot
      map_sdiff with
    compl := compl
    top := ⊤
    le_top := fun a => (@le_top β _ _ _).trans map_top.ge
    bot_le := fun a => map_bot.le.trans bot_le
    inf_compl_le_bot := fun a =>
      ((map_inf _ _).trans <| by rw [map_compl, inf_compl_eq_bot, map_bot]).le
    top_le_sup_compl := fun a =>
      ((map_sup _ _).trans <| by rw [map_compl, sup_compl_eq_top, map_top]).ge
    sdiff_eq := fun a b =>
      hf <|
        (map_sdiff _ _).trans <|
          sdiff_eq.trans <| by
            convert (map_inf _ _).symm
            exact (map_compl _).symm }
#align function.injective.boolean_algebra Function.Injective.booleanAlgebra

end lift

instance : BooleanAlgebra PUnit := by
  refine_struct { PUnit.biheytingAlgebra with } <;> intros <;>
    first |trivial|exact Subsingleton.elim _ _

