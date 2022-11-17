/-
Copyright (c) 2020 Fox Thomson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Fox Thomson
-/
import Mathbin.Data.Fintype.Basic
import Mathbin.Computability.Language
import Mathbin.Tactic.NormNum

/-!
# Deterministic Finite Automata
This file contains the definition of a Deterministic Finite Automaton (DFA), a state machine which
determines whether a string (implemented as a list over an arbitrary alphabet) is in a regular set
in linear time.
Note that this definition allows for Automaton with infinite states, a `fintype` instance must be
supplied for true DFA's.
-/


universe u v

/-- A DFA is a set of states (`σ`), a transition function from state to state labelled by the
  alphabet (`step`), a starting state (`start`) and a set of acceptance states (`accept`). -/
structure DFA (α : Type u) (σ : Type v) where
  step : σ → α → σ
  start : σ
  accept : Set σ
#align DFA DFA

namespace DFA

variable {α : Type u} {σ : Type v} (M : DFA α σ)

instance [Inhabited σ] : Inhabited (DFA α σ) :=
  ⟨DFA.mk (fun _ _ => default) default ∅⟩

/-- `M.eval_from s x` evaluates `M` with input `x` starting from the state `s`. -/
def evalFrom (start : σ) : List α → σ :=
  List.foldl M.step start
#align DFA.eval_from DFA.evalFrom

@[simp]
theorem eval_from_nil (s : σ) : M.evalFrom s [] = s :=
  rfl
#align DFA.eval_from_nil DFA.eval_from_nil

@[simp]
theorem eval_from_singleton (s : σ) (a : α) : M.evalFrom s [a] = M.step s a :=
  rfl
#align DFA.eval_from_singleton DFA.eval_from_singleton

@[simp]
theorem eval_from_append_singleton (s : σ) (x : List α) (a : α) : M.evalFrom s (x ++ [a]) = M.step (M.evalFrom s x) a :=
  by simp only [eval_from, List.foldl_append, List.foldl_cons, List.foldl_nil]
#align DFA.eval_from_append_singleton DFA.eval_from_append_singleton

/-- `M.eval x` evaluates `M` with input `x` starting from the state `M.start`. -/
def eval : List α → σ :=
  M.evalFrom M.start
#align DFA.eval DFA.eval

@[simp]
theorem eval_nil : M.eval [] = M.start :=
  rfl
#align DFA.eval_nil DFA.eval_nil

@[simp]
theorem eval_singleton (a : α) : M.eval [a] = M.step M.start a :=
  rfl
#align DFA.eval_singleton DFA.eval_singleton

@[simp]
theorem eval_append_singleton (x : List α) (a : α) : M.eval (x ++ [a]) = M.step (M.eval x) a :=
  eval_from_append_singleton _ _ _ _
#align DFA.eval_append_singleton DFA.eval_append_singleton

theorem eval_from_of_append (start : σ) (x y : List α) :
    M.evalFrom start (x ++ y) = M.evalFrom (M.evalFrom start x) y :=
  x.foldl_append _ _ y
#align DFA.eval_from_of_append DFA.eval_from_of_append

/-- `M.accepts` is the language of `x` such that `M.eval x` is an accept state. -/
def accepts : Language α := fun x => M.eval x ∈ M.accept
#align DFA.accepts DFA.accepts

theorem mem_accepts (x : List α) : x ∈ M.accepts ↔ M.evalFrom M.start x ∈ M.accept := by rfl
#align DFA.mem_accepts DFA.mem_accepts

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (q a b c) -/
theorem eval_from_split [Fintype σ] {x : List α} {s t : σ} (hlen : Fintype.card σ ≤ x.length)
    (hx : M.evalFrom s x = t) :
    ∃ (q) (a) (b) (c),
      x = a ++ b ++ c ∧
        a.length + b.length ≤ Fintype.card σ ∧ b ≠ [] ∧ M.evalFrom s a = q ∧ M.evalFrom q b = q ∧ M.evalFrom q c = t :=
  by
  obtain ⟨n, m, hneq, heq⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt (fun n : Fin (Fintype.card σ + 1) => M.eval_from s (x.take n)) (by norm_num)
  wlog hle : (n : ℕ) ≤ m using n m
  have hlt : (n : ℕ) < m := (Ne.le_iff_lt hneq).mp hle
  have hm : (m : ℕ) ≤ Fintype.card σ := Fin.is_le m
  dsimp at heq
  refine' ⟨M.eval_from s ((x.take m).take n), (x.take m).take n, (x.take m).drop n, x.drop m, _, _, _, by rfl, _⟩
  · rw [List.take_append_drop, List.take_append_drop]
    
  · simp only [List.length_drop, List.length_take]
    rw [min_eq_left (hm.trans hlen), min_eq_left hle, add_tsub_cancel_of_le hle]
    exact hm
    
  · intro h
    have hlen' := congr_arg List.length h
    simp only [List.length_drop, List.length, List.length_take] at hlen'
    rw [min_eq_left, tsub_eq_zero_iff_le] at hlen'
    · apply hneq
      apply le_antisymm
      assumption'
      
    exact hm.trans hlen
    
  have hq : M.eval_from (M.eval_from s ((x.take m).take n)) ((x.take m).drop n) = M.eval_from s ((x.take m).take n) :=
    by
    rw [List.take_take, min_eq_left hle, ← eval_from_of_append, HEq, ← min_eq_left hle, ← List.take_take,
      min_eq_left hle, List.take_append_drop]
  use hq
  rwa [← hq, ← eval_from_of_append, ← eval_from_of_append, ← List.append_assoc, List.take_append_drop,
    List.take_append_drop]
#align DFA.eval_from_split DFA.eval_from_split

theorem eval_from_of_pow {x y : List α} {s : σ} (hx : M.evalFrom s x = s) (hy : y ∈ @Language.star α {x}) :
    M.evalFrom s y = s := by
  rw [Language.mem_star] at hy
  rcases hy with ⟨S, rfl, hS⟩
  induction' S with a S ih
  · rfl
    
  · have ha := hS a (List.mem_cons_self _ _)
    rw [Set.mem_singleton_iff] at ha
    rw [List.join, eval_from_of_append, ha, hx]
    apply ih
    intro z hz
    exact hS z (List.mem_cons_of_mem a hz)
    
#align DFA.eval_from_of_pow DFA.eval_from_of_pow

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (a b c) -/
theorem pumping_lemma [Fintype σ] {x : List α} (hx : x ∈ M.accepts) (hlen : Fintype.card σ ≤ List.length x) :
    ∃ (a) (b) (c),
      x = a ++ b ++ c ∧ a.length + b.length ≤ Fintype.card σ ∧ b ≠ [] ∧ {a} * Language.star {b} * {c} ≤ M.accepts :=
  by
  obtain ⟨_, a, b, c, hx, hlen, hnil, rfl, hb, hc⟩ := M.eval_from_split hlen rfl
  use a, b, c, hx, hlen, hnil
  intro y hy
  rw [Language.mem_mul] at hy
  rcases hy with ⟨ab, c', hab, hc', rfl⟩
  rw [Language.mem_mul] at hab
  rcases hab with ⟨a', b', ha', hb', rfl⟩
  rw [Set.mem_singleton_iff] at ha' hc'
  substs ha' hc'
  have h := M.eval_from_of_pow hb hb'
  rwa [mem_accepts, eval_from_of_append, eval_from_of_append, h, hc]
#align DFA.pumping_lemma DFA.pumping_lemma

end DFA

