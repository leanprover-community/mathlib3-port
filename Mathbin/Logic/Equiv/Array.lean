/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro
-/
import Data.Vector.Basic
import Logic.Equiv.List
import Control.Traversable.Equiv

#align_import logic.equiv.array from "leanprover-community/mathlib"@"9240e8be927a0955b9a82c6c85ef499ee3a626b8"

/-!
# Equivalences involving `array`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We keep this separate from the file containing `list`-like equivalences as those have no future
in mathlib4.
-/


namespace Equiv

/-- The natural equivalence between length-`n` heterogeneous arrays
and dependent functions from `fin n`. -/
def dArrayEquivFin {n : ℕ} (α : Fin n → Type _) : DArray n α ≃ ∀ i, α i :=
  ⟨DArray.read, DArray.mk, fun ⟨f⟩ => rfl, fun f => rfl⟩
#align equiv.d_array_equiv_fin Equiv.dArrayEquivFin

/-- The natural equivalence between length-`n` arrays and functions from `fin n`. -/
def arrayEquivFin (n : ℕ) (α : Type _) : Array' n α ≃ (Fin n → α) :=
  dArrayEquivFin _
#align equiv.array_equiv_fin Equiv.arrayEquivFin

/-- The natural equivalence between length-`n` vectors and length-`n` arrays. -/
def vectorEquivArray (α : Type _) (n : ℕ) : Mathlib.Vector α n ≃ Array' n α :=
  (vectorEquivFin _ _).trans (arrayEquivFin _ _).symm
#align equiv.vector_equiv_array Equiv.vectorEquivArray

end Equiv

namespace Array'

open Function

variable {n : ℕ}

instance : Traversable (Array' n) :=
  @Equiv.traversable (flip Mathlib.Vector n) _ (fun α => Equiv.vectorEquivArray α n) _

instance : LawfulTraversable (Array' n) :=
  @Equiv.isLawfulTraversable (flip Mathlib.Vector n) _ (fun α => Equiv.vectorEquivArray α n) _ _

end Array'

/-- If `α` is encodable, then so is `array n α`. -/
instance Array'.encodable {α} [Encodable α] {n} : Encodable (Array' n α) :=
  Encodable.ofEquiv _ (Equiv.arrayEquivFin _ _)
#align array.encodable Array'.encodable

/-- If `α` is countable, then so is `array n α`. -/
instance Array'.countable {α} [Countable α] {n} : Countable (Array' n α) :=
  Countable.of_equiv _ (Equiv.vectorEquivArray _ _)
#align array.countable Array'.countable

