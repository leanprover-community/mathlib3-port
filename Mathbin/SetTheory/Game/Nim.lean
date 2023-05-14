/-
Copyright (c) 2020 Fox Thomson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Fox Thomson, Markus Himmel

! This file was ported from Lean 3 source module set_theory.game.nim
! leanprover-community/mathlib commit 92ca63f0fb391a9ca5f22d2409a6080e786d99f7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Bitwise
import Mathbin.SetTheory.Game.Birthday
import Mathbin.SetTheory.Game.Impartial

/-!
# Nim and the Sprague-Grundy theorem

This file contains the definition for nim for any ordinal `o`. In the game of `nim o₁` both players
may move to `nim o₂` for any `o₂ < o₁`.
We also define a Grundy value for an impartial game `G` and prove the Sprague-Grundy theorem, that
`G` is equivalent to `nim (grundy_value G)`.
Finally, we compute the sum of finite Grundy numbers: if `G` and `H` have Grundy values `n` and `m`,
where `n` and `m` are natural numbers, then `G + H` has the Grundy value `n xor m`.

## Implementation details

The pen-and-paper definition of nim defines the possible moves of `nim o` to be `set.Iio o`.
However, this definition does not work for us because it would make the type of nim
`ordinal.{u} → pgame.{u + 1}`, which would make it impossible for us to state the Sprague-Grundy
theorem, since that requires the type of `nim` to be `ordinal.{u} → pgame.{u}`. For this reason, we
instead use `o.out.α` for the possible moves. You can use `to_left_moves_nim` and
`to_right_moves_nim` to convert an ordinal less than `o` into a left or right move of `nim o`, and
vice versa.
-/


noncomputable section

universe u

open Pgame

namespace Pgame

-- Uses `noncomputable!` to avoid `rec_fn_macro only allowed in meta definitions` VM error
/-- The definition of single-heap nim, which can be viewed as a pile of stones where each player can
  take a positive number of stones from it on their turn. -/
noncomputable def nim : Ordinal.{u} → Pgame.{u}
  | o₁ =>
    let f o₂ :=
      have : Ordinal.typein o₁.out.R o₂ < o₁ := Ordinal.typein_lt_self o₂
      nim (Ordinal.typein o₁.out.R o₂)
    ⟨o₁.out.α, o₁.out.α, f, f⟩
#align pgame.nim Pgame.nim

open Ordinal

theorem nim_def (o : Ordinal) :
    nim o =
      Pgame.mk o.out.α o.out.α (fun o₂ => nim (Ordinal.typein (· < ·) o₂)) fun o₂ =>
        nim (Ordinal.typein (· < ·) o₂) :=
  by
  rw [nim]
  rfl
#align pgame.nim_def Pgame.nim_def

theorem leftMoves_nim (o : Ordinal) : (nim o).LeftMoves = o.out.α :=
  by
  rw [nim_def]
  rfl
#align pgame.left_moves_nim Pgame.leftMoves_nim

theorem rightMoves_nim (o : Ordinal) : (nim o).RightMoves = o.out.α :=
  by
  rw [nim_def]
  rfl
#align pgame.right_moves_nim Pgame.rightMoves_nim

theorem moveLeft_nim_hEq (o : Ordinal) :
    HEq (nim o).moveLeft fun i : o.out.α => nim (typein (· < ·) i) :=
  by
  rw [nim_def]
  rfl
#align pgame.move_left_nim_heq Pgame.moveLeft_nim_hEq

theorem moveRight_nim_hEq (o : Ordinal) :
    HEq (nim o).moveRight fun i : o.out.α => nim (typein (· < ·) i) :=
  by
  rw [nim_def]
  rfl
#align pgame.move_right_nim_heq Pgame.moveRight_nim_hEq

/-- Turns an ordinal less than `o` into a left move for `nim o` and viceversa. -/
noncomputable def toLeftMovesNim {o : Ordinal} : Set.Iio o ≃ (nim o).LeftMoves :=
  (enumIsoOut o).toEquiv.trans (Equiv.cast (leftMoves_nim o).symm)
#align pgame.to_left_moves_nim Pgame.toLeftMovesNim

/-- Turns an ordinal less than `o` into a right move for `nim o` and viceversa. -/
noncomputable def toRightMovesNim {o : Ordinal} : Set.Iio o ≃ (nim o).RightMoves :=
  (enumIsoOut o).toEquiv.trans (Equiv.cast (rightMoves_nim o).symm)
#align pgame.to_right_moves_nim Pgame.toRightMovesNim

@[simp]
theorem toLeftMovesNim_symm_lt {o : Ordinal} (i : (nim o).LeftMoves) :
    ↑(toLeftMovesNim.symm i) < o :=
  (toLeftMovesNim.symm i).Prop
#align pgame.to_left_moves_nim_symm_lt Pgame.toLeftMovesNim_symm_lt

@[simp]
theorem toRightMovesNim_symm_lt {o : Ordinal} (i : (nim o).RightMoves) :
    ↑(toRightMovesNim.symm i) < o :=
  (toRightMovesNim.symm i).Prop
#align pgame.to_right_moves_nim_symm_lt Pgame.toRightMovesNim_symm_lt

@[simp]
theorem moveLeft_nim' {o : Ordinal.{u}} (i) :
    (nim o).moveLeft i = nim (toLeftMovesNim.symm i).val :=
  (congr_heq (moveLeft_nim_hEq o).symm (cast_hEq _ i)).symm
#align pgame.move_left_nim' Pgame.moveLeft_nim'

theorem moveLeft_nim {o : Ordinal} (i) : (nim o).moveLeft (toLeftMovesNim i) = nim i := by simp
#align pgame.move_left_nim Pgame.moveLeft_nim

@[simp]
theorem moveRight_nim' {o : Ordinal} (i) : (nim o).moveRight i = nim (toRightMovesNim.symm i).val :=
  (congr_heq (moveRight_nim_hEq o).symm (cast_hEq _ i)).symm
#align pgame.move_right_nim' Pgame.moveRight_nim'

theorem moveRight_nim {o : Ordinal} (i) : (nim o).moveRight (toRightMovesNim i) = nim i := by simp
#align pgame.move_right_nim Pgame.moveRight_nim

/-- A recursion principle for left moves of a nim game. -/
@[elab_as_elim]
def leftMovesNimRecOn {o : Ordinal} {P : (nim o).LeftMoves → Sort _} (i : (nim o).LeftMoves)
    (H : ∀ a < o, P <| toLeftMovesNim ⟨a, H⟩) : P i :=
  by
  rw [← to_left_moves_nim.apply_symm_apply i]
  apply H
#align pgame.left_moves_nim_rec_on Pgame.leftMovesNimRecOn

/-- A recursion principle for right moves of a nim game. -/
@[elab_as_elim]
def rightMovesNimRecOn {o : Ordinal} {P : (nim o).RightMoves → Sort _} (i : (nim o).RightMoves)
    (H : ∀ a < o, P <| toRightMovesNim ⟨a, H⟩) : P i :=
  by
  rw [← to_right_moves_nim.apply_symm_apply i]
  apply H
#align pgame.right_moves_nim_rec_on Pgame.rightMovesNimRecOn

instance isEmpty_nim_zero_leftMoves : IsEmpty (nim 0).LeftMoves :=
  by
  rw [nim_def]
  exact Ordinal.isEmpty_out_zero
#align pgame.is_empty_nim_zero_left_moves Pgame.isEmpty_nim_zero_leftMoves

instance isEmpty_nim_zero_rightMoves : IsEmpty (nim 0).RightMoves :=
  by
  rw [nim_def]
  exact Ordinal.isEmpty_out_zero
#align pgame.is_empty_nim_zero_right_moves Pgame.isEmpty_nim_zero_rightMoves

/-- `nim 0` has exactly the same moves as `0`. -/
def nimZeroRelabelling : nim 0 ≡r 0 :=
  Relabelling.isEmpty _
#align pgame.nim_zero_relabelling Pgame.nimZeroRelabelling

theorem nim_zero_equiv : nim 0 ≈ 0 :=
  Equiv.isEmpty _
#align pgame.nim_zero_equiv Pgame.nim_zero_equiv

noncomputable instance uniqueNimOneLeftMoves : Unique (nim 1).LeftMoves :=
  (Equiv.cast <| leftMoves_nim 1).unique
#align pgame.unique_nim_one_left_moves Pgame.uniqueNimOneLeftMoves

noncomputable instance uniqueNimOneRightMoves : Unique (nim 1).RightMoves :=
  (Equiv.cast <| rightMoves_nim 1).unique
#align pgame.unique_nim_one_right_moves Pgame.uniqueNimOneRightMoves

@[simp]
theorem default_nim_one_leftMoves_eq :
    (default : (nim 1).LeftMoves) = @toLeftMovesNim 1 ⟨0, zero_lt_one⟩ :=
  rfl
#align pgame.default_nim_one_left_moves_eq Pgame.default_nim_one_leftMoves_eq

@[simp]
theorem default_nim_one_rightMoves_eq :
    (default : (nim 1).RightMoves) = @toRightMovesNim 1 ⟨0, zero_lt_one⟩ :=
  rfl
#align pgame.default_nim_one_right_moves_eq Pgame.default_nim_one_rightMoves_eq

@[simp]
theorem toLeftMovesNim_one_symm (i) : (@toLeftMovesNim 1).symm i = ⟨0, zero_lt_one⟩ := by simp
#align pgame.to_left_moves_nim_one_symm Pgame.toLeftMovesNim_one_symm

@[simp]
theorem toRightMovesNim_one_symm (i) : (@toRightMovesNim 1).symm i = ⟨0, zero_lt_one⟩ := by simp
#align pgame.to_right_moves_nim_one_symm Pgame.toRightMovesNim_one_symm

theorem nim_one_moveLeft (x) : (nim 1).moveLeft x = nim 0 := by simp
#align pgame.nim_one_move_left Pgame.nim_one_moveLeft

theorem nim_one_moveRight (x) : (nim 1).moveRight x = nim 0 := by simp
#align pgame.nim_one_move_right Pgame.nim_one_moveRight

/-- `nim 1` has exactly the same moves as `star`. -/
def nimOneRelabelling : nim 1 ≡r star := by
  rw [nim_def]
  refine' ⟨_, _, fun i => _, fun j => _⟩
  any_goals dsimp; apply Equiv.equivOfUnique
  all_goals simp; exact nim_zero_relabelling
#align pgame.nim_one_relabelling Pgame.nimOneRelabelling

theorem nim_one_equiv : nim 1 ≈ star :=
  nimOneRelabelling.Equiv
#align pgame.nim_one_equiv Pgame.nim_one_equiv

@[simp]
theorem nim_birthday (o : Ordinal) : (nim o).birthday = o :=
  by
  induction' o using Ordinal.induction with o IH
  rw [nim_def, birthday_def]
  dsimp
  rw [max_eq_right le_rfl]
  convert lsub_typein o
  exact funext fun i => IH _ (typein_lt_self i)
#align pgame.nim_birthday Pgame.nim_birthday

@[simp]
theorem neg_nim (o : Ordinal) : -nim o = nim o :=
  by
  induction' o using Ordinal.induction with o IH
  rw [nim_def]; dsimp <;> congr <;> funext i <;> exact IH _ (Ordinal.typein_lt_self i)
#align pgame.neg_nim Pgame.neg_nim

instance nim_impartial (o : Ordinal) : Impartial (nim o) :=
  by
  induction' o using Ordinal.induction with o IH
  rw [impartial_def, neg_nim]
  refine' ⟨equiv_rfl, fun i => _, fun i => _⟩ <;> simpa using IH _ (typein_lt_self _)
#align pgame.nim_impartial Pgame.nim_impartial

theorem nim_fuzzy_zero_of_ne_zero {o : Ordinal} (ho : o ≠ 0) : nim o ‖ 0 :=
  by
  rw [impartial.fuzzy_zero_iff_lf, nim_def, lf_zero_le]
  rw [← Ordinal.pos_iff_ne_zero] at ho
  exact ⟨(Ordinal.principalSegOut ho).top, by simp⟩
#align pgame.nim_fuzzy_zero_of_ne_zero Pgame.nim_fuzzy_zero_of_ne_zero

@[simp]
theorem nim_add_equiv_zero_iff (o₁ o₂ : Ordinal) : (nim o₁ + nim o₂ ≈ 0) ↔ o₁ = o₂ :=
  by
  constructor
  · refine' not_imp_not.1 fun hne : _ ≠ _ => (impartial.not_equiv_zero_iff _).2 _
    wlog h : o₁ < o₂
    · exact (fuzzy_congr_left add_comm_equiv).1 (this _ _ hne.symm (hne.lt_or_lt.resolve_left h))
    rw [impartial.fuzzy_zero_iff_gf, zero_lf_le, nim_def o₂]
    refine' ⟨to_left_moves_add (Sum.inr _), _⟩
    · exact (Ordinal.principalSegOut h).top
    · simpa using (impartial.add_self (nim o₁)).2
  · rintro rfl
    exact impartial.add_self (nim o₁)
#align pgame.nim_add_equiv_zero_iff Pgame.nim_add_equiv_zero_iff

@[simp]
theorem nim_add_fuzzy_zero_iff {o₁ o₂ : Ordinal} : nim o₁ + nim o₂ ‖ 0 ↔ o₁ ≠ o₂ := by
  rw [iff_not_comm, impartial.not_fuzzy_zero_iff, nim_add_equiv_zero_iff]
#align pgame.nim_add_fuzzy_zero_iff Pgame.nim_add_fuzzy_zero_iff

@[simp]
theorem nim_equiv_iff_eq {o₁ o₂ : Ordinal} : (nim o₁ ≈ nim o₂) ↔ o₁ = o₂ := by
  rw [impartial.equiv_iff_add_equiv_zero, nim_add_equiv_zero_iff]
#align pgame.nim_equiv_iff_eq Pgame.nim_equiv_iff_eq

/-- The Grundy value of an impartial game, the ordinal which corresponds to the game of nim that the
 game is equivalent to -/
noncomputable def grundyValue : ∀ G : Pgame.{u}, Ordinal.{u}
  | G => Ordinal.mex.{u, u} fun i => grundy_value (G.moveLeft i)decreasing_by pgame_wf_tac
#align pgame.grundy_value Pgame.grundyValue

theorem grundyValue_eq_mex_left (G : Pgame) :
    grundyValue G = Ordinal.mex.{u, u} fun i => grundyValue (G.moveLeft i) := by rw [grundy_value]
#align pgame.grundy_value_eq_mex_left Pgame.grundyValue_eq_mex_left

/-- The Sprague-Grundy theorem which states that every impartial game is equivalent to a game of
 nim, namely the game of nim corresponding to the games Grundy value -/
theorem equiv_nim_grundyValue : ∀ (G : Pgame.{u}) [G.Impartial], G ≈ nim (grundyValue G)
  | G => by
    intro hG
    rw [impartial.equiv_iff_add_equiv_zero, ← impartial.forall_left_moves_fuzzy_iff_equiv_zero]
    intro i
    apply left_moves_add_cases i
    · intro i₁
      rw [add_move_left_inl]
      apply (fuzzy_congr_left (add_congr_left (equiv_nim_grundy_value (G.move_left i₁)).symm)).1
      rw [nim_add_fuzzy_zero_iff]
      intro heq
      rw [eq_comm, grundy_value_eq_mex_left G] at heq
      have h := Ordinal.ne_mex _
      rw [HEq] at h
      exact (h i₁).irrefl
    · intro i₂
      rw [add_move_left_inr, ← impartial.exists_left_move_equiv_iff_fuzzy_zero]
      revert i₂
      rw [nim_def]
      intro i₂
      have h' :
        ∃ i : G.left_moves,
          grundy_value (G.move_left i) = Ordinal.typein (Quotient.out (grundy_value G)).R i₂ :=
        by
        revert i₂
        rw [grundy_value_eq_mex_left]
        intro i₂
        have hnotin : _ ∉ _ := fun hin =>
          (le_not_le_of_lt (Ordinal.typein_lt_self i₂)).2 (csInf_le' hin)
        simpa using hnotin
      cases' h' with i hi
      use to_left_moves_add (Sum.inl i)
      rw [add_move_left_inl, move_left_mk]
      apply (add_congr_left (equiv_nim_grundy_value (G.move_left i))).trans
      simpa only [hi] using impartial.add_self (nim (grundy_value (G.move_left i)))decreasing_by
  pgame_wf_tac
#align pgame.equiv_nim_grundy_value Pgame.equiv_nim_grundyValue

theorem grundyValue_eq_iff_equiv_nim {G : Pgame} [G.Impartial] {o : Ordinal} :
    grundyValue G = o ↔ (G ≈ nim o) :=
  ⟨by
    rintro rfl
    exact equiv_nim_grundy_value G, by
    intro h
    rw [← nim_equiv_iff_eq]
    exact (equiv_nim_grundy_value G).symm.trans h⟩
#align pgame.grundy_value_eq_iff_equiv_nim Pgame.grundyValue_eq_iff_equiv_nim

@[simp]
theorem nim_grundyValue (o : Ordinal.{u}) : grundyValue (nim o) = o :=
  grundyValue_eq_iff_equiv_nim.2 Pgame.equiv_rfl
#align pgame.nim_grundy_value Pgame.nim_grundyValue

theorem grundyValue_eq_iff_equiv (G H : Pgame) [G.Impartial] [H.Impartial] :
    grundyValue G = grundyValue H ↔ (G ≈ H) :=
  grundyValue_eq_iff_equiv_nim.trans (equiv_congr_left.1 (equiv_nim_grundyValue H) _).symm
#align pgame.grundy_value_eq_iff_equiv Pgame.grundyValue_eq_iff_equiv

@[simp]
theorem grundyValue_zero : grundyValue 0 = 0 :=
  grundyValue_eq_iff_equiv_nim.2 nim_zero_equiv.symm
#align pgame.grundy_value_zero Pgame.grundyValue_zero

theorem grundyValue_iff_equiv_zero (G : Pgame) [G.Impartial] : grundyValue G = 0 ↔ (G ≈ 0) := by
  rw [← grundy_value_eq_iff_equiv, grundy_value_zero]
#align pgame.grundy_value_iff_equiv_zero Pgame.grundyValue_iff_equiv_zero

@[simp]
theorem grundyValue_star : grundyValue star = 1 :=
  grundyValue_eq_iff_equiv_nim.2 nim_one_equiv.symm
#align pgame.grundy_value_star Pgame.grundyValue_star

@[simp]
theorem grundyValue_neg (G : Pgame) [G.Impartial] : grundyValue (-G) = grundyValue G := by
  rw [grundy_value_eq_iff_equiv_nim, neg_equiv_iff, neg_nim, ← grundy_value_eq_iff_equiv_nim]
#align pgame.grundy_value_neg Pgame.grundyValue_neg

theorem grundyValue_eq_mex_right :
    ∀ (G : Pgame) [G.Impartial],
      grundyValue G = Ordinal.mex.{u, u} fun i => grundyValue (G.moveRight i)
  | ⟨l, r, L, R⟩ => by
    intro H
    rw [← grundy_value_neg, grundy_value_eq_mex_left]
    congr
    ext i
    haveI : (R i).Impartial := @impartial.move_right_impartial ⟨l, r, L, R⟩ _ i
    apply grundy_value_neg
#align pgame.grundy_value_eq_mex_right Pgame.grundyValue_eq_mex_right

-- Todo: this actually generalizes to all ordinals, by defining `ordinal.lxor` as the pairwise
-- `nat.lxor` of base `ω` Cantor normal forms.
/-- The Grundy value of the sum of two nim games with natural numbers of piles equals their bitwise
xor. -/
@[simp]
theorem grundyValue_nim_add_nim (n m : ℕ) : grundyValue (nim.{u} n + nim.{u} m) = Nat.lxor' n m :=
  by
  -- We do strong induction on both variables.
  induction' n using Nat.strong_induction_on with n hn generalizing m
  induction' m using Nat.strong_induction_on with m hm
  rw [grundy_value_eq_mex_left]
  apply (Ordinal.mex_le_of_ne.{u, u} fun i => _).antisymm (Ordinal.le_mex_of_forall fun ou hu => _)
  -- The Grundy value `nat.lxor n m` can't be reached by left moves.
  ·
    apply left_moves_add_cases i <;>
      · -- A left move leaves us with a Grundy value of `nat.lxor k m` for `k < n`, or `nat.lxor n k`
        -- for `k < m`.
        refine' fun a => left_moves_nim_rec_on a fun ok hk => _
        obtain ⟨k, rfl⟩ := Ordinal.lt_omega.1 (hk.trans (Ordinal.nat_lt_omega _))
        simp only [add_move_left_inl, add_move_left_inr, move_left_nim', Equiv.symm_apply_apply]
        -- The inequality follows from injectivity.
        rw [nat_cast_lt] at hk
        first |rw [hn _ hk]|rw [hm _ hk]
        refine' fun h => hk.ne _
        rw [Ordinal.nat_cast_inj] at h
        first |rwa [Nat.lxor'_left_inj] at h|rwa [Nat.lxor'_right_inj] at h
  -- Every other smaller Grundy value can be reached by left moves.
  · -- If `u < nat.lxor m n`, then either `nat.lxor u n < m` or `nat.lxor u m < n`.
    obtain ⟨u, rfl⟩ := Ordinal.lt_omega.1 (hu.trans (Ordinal.nat_lt_omega _))
    replace hu := Ordinal.nat_cast_lt.1 hu
    cases' Nat.lt_lxor'_cases hu with h h
    -- In the first case, reducing the `m` pile to `nat.lxor u n` gives the desired Grundy value.
    · refine' ⟨to_left_moves_add (Sum.inl <| to_left_moves_nim ⟨_, Ordinal.nat_cast_lt.2 h⟩), _⟩
      simp [Nat.lxor_cancel_right, hn _ h]
    -- In the second case, reducing the `n` pile to `nat.lxor u m` gives the desired Grundy value.
    · refine' ⟨to_left_moves_add (Sum.inr <| to_left_moves_nim ⟨_, Ordinal.nat_cast_lt.2 h⟩), _⟩
      have : n.lxor (u.lxor n) = u
      rw [Nat.lxor'_comm u, Nat.lxor'_cancel_left]
      simpa [hm _ h] using this
#align pgame.grundy_value_nim_add_nim Pgame.grundyValue_nim_add_nim

theorem nim_add_nim_equiv {n m : ℕ} : nim n + nim m ≈ nim (Nat.lxor' n m) := by
  rw [← grundy_value_eq_iff_equiv_nim, grundy_value_nim_add_nim]
#align pgame.nim_add_nim_equiv Pgame.nim_add_nim_equiv

theorem grundyValue_add (G H : Pgame) [G.Impartial] [H.Impartial] {n m : ℕ} (hG : grundyValue G = n)
    (hH : grundyValue H = m) : grundyValue (G + H) = Nat.lxor' n m :=
  by
  rw [← nim_grundy_value (Nat.lxor' n m), grundy_value_eq_iff_equiv]
  refine' Equiv.trans _ nim_add_nim_equiv
  convert add_congr (equiv_nim_grundy_value G) (equiv_nim_grundy_value H) <;> simp only [hG, hH]
#align pgame.grundy_value_add Pgame.grundyValue_add

end Pgame

