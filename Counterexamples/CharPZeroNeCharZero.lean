/-
Copyright (c) 2022 Damiano Testa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa, Eric Wieser
-/
import Algebra.CharP.Defs

#align_import char_p_zero_ne_char_zero from "leanprover-community/mathlib"@"08b081ea92d80e3a41f899eea36ef6d56e0f1db0"

/-! # `char_p R 0` and `char_zero R` need not coincide for semirings

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

For rings, the two notions coincide.

In fact, `char_p.of_char_zero` shows that `char_zero R` implies `char_p R 0` for any `char_zero`
`add_monoid R` with `1`.
The reverse implication holds for any `add_left_cancel_monoid R` with `1`, by `char_p_to_char_zero`.

This file shows that there are semiring `R` for which `char_p R 0` holds and `char_zero R` does not.

The example is `{0, 1}` with saturating addition.
-/


namespace Counterexample

@[simp]
theorem add_one_eq_one (x : WithZero Unit) : x + 1 = 1 :=
  WithZero.cases_on x (by rfl) fun h => by rfl
#align counterexample.add_one_eq_one Counterexample.add_one_eq_one

theorem withZero_unit_charP_zero : CharP (WithZero Unit) 0 :=
  ⟨fun x => by cases x <;> simp⟩
#align counterexample.with_zero_unit_char_p_zero Counterexample.withZero_unit_charP_zero

theorem withZero_unit_not_charZero : ¬CharZero (WithZero Unit) := fun ⟨h⟩ =>
  h.Ne (by simp : 1 + 1 ≠ 0 + 1) (by simp)
#align counterexample.with_zero_unit_not_char_zero Counterexample.withZero_unit_not_charZero

end Counterexample

