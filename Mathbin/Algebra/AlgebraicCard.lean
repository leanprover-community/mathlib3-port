/-
Copyright (c) 2022 Violeta Hernández Palacios. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Violeta Hernández Palacios
-/
import Mathbin.Data.Polynomial.Cardinal
import Mathbin.RingTheory.Algebraic

/-!
### Cardinality of algebraic numbers

In this file, we prove variants of the following result: the cardinality of algebraic numbers under
an R-algebra is at most `# R[X] * ℵ₀`.

Although this can be used to prove that real or complex transcendental numbers exist, a more direct
proof is given by `liouville.is_transcendental`.
-/


universe u v

open Cardinal Polynomial

open Cardinal Polynomial

namespace Algebraic

theorem aleph_0_le_cardinal_mk_of_char_zero (R A : Type _) [CommRing R] [IsDomain R] [Ring A]
    [Algebra R A] [CharZero A] : ℵ₀ ≤ (#{ x : A // IsAlgebraic R x }) :=
  @mk_le_of_injective (ULift ℕ) { x : A | IsAlgebraic R x } (fun n => ⟨_, is_algebraic_nat n.down⟩)
    fun m n hmn => by simpa using hmn
#align algebraic.aleph_0_le_cardinal_mk_of_char_zero Algebraic.aleph_0_le_cardinal_mk_of_char_zero

section lift

variable (R : Type u) (A : Type v) [CommRing R] [CommRing A] [IsDomain A] [Algebra R A]
  [NoZeroSmulDivisors R A]

theorem cardinal_mk_lift_le_mul :
    Cardinal.lift.{u, v} (#{ x : A // IsAlgebraic R x }) ≤ Cardinal.lift.{v, u} (#R[X]) * ℵ₀ := by
  rw [← mk_ulift, ← mk_ulift]
  let g : ULift.{u} { x : A | IsAlgebraic R x } → ULift.{v} R[X] := fun x =>
    ULift.up (Classical.choose x.1.2)
  apply Cardinal.mk_le_mk_mul_of_mk_preimage_le g fun f => _
  rsuffices : Fintype (g ⁻¹' {f})
  · exact mk_le_aleph_0
  by_cases hf : f.1 = 0
  · convert Set.fintypeEmpty
    apply Set.eq_empty_iff_forall_not_mem.2 fun x hx => _
    simp only [Set.mem_preimage, Set.mem_singleton_iff] at hx
    apply_fun ULift.down  at hx
    rw [hf] at hx
    exact (Classical.choose_spec x.1.2).1 hx
  let h : g ⁻¹' {f} → f.down.root_set A := fun x =>
    ⟨x.1.1.1,
      mem_root_set.2
        ⟨hf, by 
          have key' : g x = f := x.2
          simp_rw [← key']
          exact (Classical.choose_spec x.1.1.2).2⟩⟩
  apply Fintype.ofInjective h fun _ _ H => _
  simp only [Subtype.val_eq_coe, Subtype.mk_eq_mk] at H
  exact Subtype.ext (ULift.down_injective (Subtype.ext H))
#align algebraic.cardinal_mk_lift_le_mul Algebraic.cardinal_mk_lift_le_mul

theorem cardinal_mk_lift_le_max :
    Cardinal.lift.{u, v} (#{ x : A // IsAlgebraic R x }) ≤ max (Cardinal.lift.{v, u} (#R)) ℵ₀ :=
  (cardinal_mk_lift_le_mul R A).trans <|
    (mul_le_mul_right' (lift_le.2 cardinal_mk_le_max) _).trans <| by simp [le_total]
#align algebraic.cardinal_mk_lift_le_max Algebraic.cardinal_mk_lift_le_max

theorem cardinal_mk_lift_le_of_infinite [Infinite R] :
    Cardinal.lift.{u, v} (#{ x : A // IsAlgebraic R x }) ≤ Cardinal.lift.{v, u} (#R) :=
  (cardinal_mk_lift_le_max R A).trans <| by simp
#align algebraic.cardinal_mk_lift_le_of_infinite Algebraic.cardinal_mk_lift_le_of_infinite

variable [Encodable R]

@[simp]
theorem countable_of_encodable : Set.Countable { x : A | IsAlgebraic R x } := by
  rw [← le_aleph_0_iff_set_countable, ← lift_le]
  apply (cardinal_mk_lift_le_max R A).trans
  simp
#align algebraic.countable_of_encodable Algebraic.countable_of_encodable

@[simp]
theorem cardinal_mk_of_encodable_of_char_zero [CharZero A] [IsDomain R] :
    (#{ x : A // IsAlgebraic R x }) = ℵ₀ :=
  le_antisymm (by simp) (aleph_0_le_cardinal_mk_of_char_zero R A)
#align
  algebraic.cardinal_mk_of_encodable_of_char_zero Algebraic.cardinal_mk_of_encodable_of_char_zero

end lift

section NonLift

variable (R A : Type u) [CommRing R] [CommRing A] [IsDomain A] [Algebra R A]
  [NoZeroSmulDivisors R A]

theorem cardinal_mk_le_mul : (#{ x : A // IsAlgebraic R x }) ≤ (#R[X]) * ℵ₀ := by
  rw [← lift_id (#_), ← lift_id (#R[X])]
  exact cardinal_mk_lift_le_mul R A
#align algebraic.cardinal_mk_le_mul Algebraic.cardinal_mk_le_mul

theorem cardinal_mk_le_max : (#{ x : A // IsAlgebraic R x }) ≤ max (#R) ℵ₀ := by
  rw [← lift_id (#_), ← lift_id (#R)]
  exact cardinal_mk_lift_le_max R A
#align algebraic.cardinal_mk_le_max Algebraic.cardinal_mk_le_max

theorem cardinal_mk_le_of_infinite [Infinite R] : (#{ x : A // IsAlgebraic R x }) ≤ (#R) :=
  (cardinal_mk_le_max R A).trans <| by simp
#align algebraic.cardinal_mk_le_of_infinite Algebraic.cardinal_mk_le_of_infinite

end NonLift

end Algebraic

