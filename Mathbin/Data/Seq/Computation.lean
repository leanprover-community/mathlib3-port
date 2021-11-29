import Mathbin.Tactic.Basic 
import Mathbin.Data.Stream.Init 
import Mathbin.Logic.Relator

open Function

universe u v w

/-- `computation α` is the type of unbounded computations returning `α`.
  An element of `computation α` is an infinite sequence of `option α` such
  that if `f n = some a` for some `n` then it is constantly `some a` after that. -/
def Computation (α : Type u) : Type u :=
  { f : Streamₓ (Option α) // ∀ {n a}, f n = some a → f (n+1) = some a }

namespace Computation

variable{α : Type u}{β : Type v}{γ : Type w}

/-- `return a` is the computation that immediately terminates with result `a`. -/
def return (a : α) : Computation α :=
  ⟨Streamₓ.const (some a), fun n a' => id⟩

instance  : CoeTₓ α (Computation α) :=
  ⟨return⟩

/-- `think c` is the computation that delays for one "tick" and then performs
  computation `c`. -/
def think (c : Computation α) : Computation α :=
  ⟨none :: c.1,
    fun n a h =>
      by 
        cases' n with n 
        contradiction 
        exact c.2 h⟩

/-- `thinkN c n` is the computation that delays for `n` ticks and then performs
  computation `c`. -/
def thinkN (c : Computation α) : ℕ → Computation α
| 0 => c
| n+1 => think (thinkN n)

/-- `head c` is the first step of computation, either `some a` if `c = return a`
  or `none` if `c = think c'`. -/
def head (c : Computation α) : Option α :=
  c.1.head

/-- `tail c` is the remainder of computation, either `c` if `c = return a`
  or `c'` if `c = think c'`. -/
def tail (c : Computation α) : Computation α :=
  ⟨c.1.tail,
    fun n a =>
      let t := c.2
      t⟩

/-- `empty α` is the computation that never returns, an infinite sequence of
  `think`s. -/
def Empty α : Computation α :=
  ⟨Streamₓ.const none, fun n a' => id⟩

instance  : Inhabited (Computation α) :=
  ⟨Empty _⟩

/-- `run_for c n` evaluates `c` for `n` steps and returns the result, or `none`
  if it did not terminate after `n` steps. -/
def run_for : Computation α → ℕ → Option α :=
  Subtype.val

/-- `destruct c` is the destructor for `computation α` as a coinductive type.
  It returns `inl a` if `c = return a` and `inr c'` if `c = think c'`. -/
def destruct (c : Computation α) : Sum α (Computation α) :=
  match c.1 0 with 
  | none => Sum.inr (tail c)
  | some a => Sum.inl a

/-- `run c` is an unsound meta function that runs `c` to completion, possibly
  resulting in an infinite loop in the VM. -/
unsafe def run : Computation α → α
| c =>
  match destruct c with 
  | Sum.inl a => a
  | Sum.inr ca => run ca

theorem destruct_eq_ret {s : Computation α} {a : α} : destruct s = Sum.inl a → s = return a :=
  by 
    dsimp [destruct]
    induction' f0 : s.1 0 with  <;> intro h
    ·
      contradiction
    ·
      apply Subtype.eq 
      funext n 
      induction' n with n IH
      ·
        injection h with h' 
        rwa [h'] at f0
      ·
        exact s.2 IH

theorem destruct_eq_think {s : Computation α} {s'} : destruct s = Sum.inr s' → s = think s' :=
  by 
    dsimp [destruct]
    induction' f0 : s.1 0 with a' <;> intro h
    ·
      injection h with h' 
      rw [←h']
      cases' s with f al 
      apply Subtype.eq 
      dsimp [think, tail]
      rw [←f0]
      exact (Streamₓ.eta f).symm
    ·
      contradiction

@[simp]
theorem destruct_ret (a : α) : destruct (return a) = Sum.inl a :=
  rfl

@[simp]
theorem destruct_think : ∀ (s : Computation α), destruct (think s) = Sum.inr s
| ⟨f, al⟩ => rfl

@[simp]
theorem destruct_empty : destruct (Empty α) = Sum.inr (Empty α) :=
  rfl

@[simp]
theorem head_ret (a : α) : head (return a) = some a :=
  rfl

@[simp]
theorem head_think (s : Computation α) : head (think s) = none :=
  rfl

@[simp]
theorem head_empty : head (Empty α) = none :=
  rfl

@[simp]
theorem tail_ret (a : α) : tail (return a) = return a :=
  rfl

@[simp]
theorem tail_think (s : Computation α) : tail (think s) = s :=
  by 
    cases' s with f al <;> apply Subtype.eq <;> dsimp [tail, think] <;> rw [Streamₓ.tail_cons]

@[simp]
theorem tail_empty : tail (Empty α) = Empty α :=
  rfl

theorem think_empty : Empty α = think (Empty α) :=
  destruct_eq_think destruct_empty

def cases_on {C : Computation α → Sort v} (s : Computation α) (h1 : ∀ a, C (return a)) (h2 : ∀ s, C (think s)) : C s :=
  by 
    induction' H : destruct s with v v
    ·
      rw [destruct_eq_ret H]
      apply h1
    ·
      cases' v with a s' 
      rw [destruct_eq_think H]
      apply h2

def corec.F (f : β → Sum α β) : Sum α β → Option α × Sum α β
| Sum.inl a => (some a, Sum.inl a)
| Sum.inr b =>
  (match f b with 
  | Sum.inl a => some a
  | Sum.inr b' => none,
  f b)

/-- `corec f b` is the corecursor for `computation α` as a coinductive type.
  If `f b = inl a` then `corec f b = return a`, and if `f b = inl b'` then
  `corec f b = think (corec f b')`. -/
def corec (f : β → Sum α β) (b : β) : Computation α :=
  by 
    refine' ⟨Streamₓ.corec' (corec.F f) (Sum.inr b), fun n a' h => _⟩
    rw [Streamₓ.corec'_eq]
    change Streamₓ.corec' (corec.F f) (corec.F f (Sum.inr b)).2 n = some a' 
    revert h 
    generalize Sum.inr b = o 
    revert o 
    induction' n with n IH <;> intro o
    ·
      change (corec.F f o).1 = some a' → (corec.F f (corec.F f o).2).1 = some a' 
      cases' o with a b <;> intro h
      ·
        exact h 
      dsimp [corec.F]  at h 
      dsimp [corec.F]
      cases' f b with a b'
      ·
        exact h
      ·
        contradiction
    ·
      rw [Streamₓ.corec'_eq (corec.F f) (corec.F f o).2, Streamₓ.corec'_eq (corec.F f) o]
      exact IH (corec.F f o).2

/-- left map of `⊕` -/
def lmap (f : α → β) : Sum α γ → Sum β γ
| Sum.inl a => Sum.inl (f a)
| Sum.inr b => Sum.inr b

/-- right map of `⊕` -/
def rmap (f : β → γ) : Sum α β → Sum α γ
| Sum.inl a => Sum.inl a
| Sum.inr b => Sum.inr (f b)

attribute [simp] lmap rmap

@[simp]
theorem corec_eq (f : β → Sum α β) (b : β) : destruct (corec f b) = rmap (corec f) (f b) :=
  by 
    dsimp [corec, destruct]
    change Streamₓ.corec' (corec.F f) (Sum.inr b) 0 with corec.F._match_1 (f b)
    induction' h : f b with a b'
    ·
      rfl 
    dsimp [corec.F, destruct]
    apply congr_argₓ 
    apply Subtype.eq 
    dsimp [corec, tail]
    rw [Streamₓ.corec'_eq, Streamₓ.tail_cons]
    dsimp [corec.F]
    rw [h]

section Bisim

variable(R : Computation α → Computation α → Prop)

local infixl:50 " ~ " => R

def bisim_o : Sum α (Computation α) → Sum α (Computation α) → Prop
| Sum.inl a, Sum.inl a' => a = a'
| Sum.inr s, Sum.inr s' => R s s'
| _, _ => False

attribute [simp] bisim_o

def is_bisimulation :=
  ∀ ⦃s₁ s₂⦄, s₁ ~ s₂ → bisim_o R (destruct s₁) (destruct s₂)

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem eq_of_bisim (bisim : is_bisimulation R) {s₁ s₂} (r : «expr ~ »(s₁, s₂)) : «expr = »(s₁, s₂) :=
begin
  apply [expr subtype.eq],
  apply [expr stream.eq_of_bisim (λ
    x y, «expr∃ , »((s s' : computation α), «expr ∧ »(«expr = »(s.1, x), «expr ∧ »(«expr = »(s'.1, y), R s s'))))],
  dsimp [] ["[", expr stream.is_bisimulation, "]"] [] [],
  intros [ident t₁, ident t₂, ident e],
  exact [expr match t₁, t₂, e with
   | ._, ._, ⟨s, s', rfl, rfl, r⟩ := suffices «expr ∧ »(«expr = »(head s, head s'), R (tail s) (tail s')), from and.imp id (λ
    r, ⟨tail s, tail s', by cases [expr s] []; refl, by cases [expr s'] []; refl, r⟩) this,
   begin
     have [] [] [":=", expr bisim r],
     revert [ident r, ident this],
     apply [expr cases_on s _ _]; intros []; apply [expr cases_on s' _ _]; intros []; intros [ident r, ident this],
     { constructor,
       dsimp [] [] [] ["at", ident this],
       rw [expr this] [],
       assumption },
     { rw ["[", expr destruct_ret, ",", expr destruct_think, "]"] ["at", ident this],
       exact [expr false.elim this] },
     { rw ["[", expr destruct_ret, ",", expr destruct_think, "]"] ["at", ident this],
       exact [expr false.elim this] },
     { simp [] [] [] [] [] ["at", ident this],
       simp [] [] [] ["[", "*", "]"] [] [] }
   end
   end],
  exact [expr ⟨s₁, s₂, rfl, rfl, r⟩]
end

end Bisim

protected def mem (a : α) (s : Computation α) :=
  some a ∈ s.1

instance  : HasMem α (Computation α) :=
  ⟨Computation.Mem⟩

theorem le_stable (s : Computation α) {a m n} (h : m ≤ n) : s.1 m = some a → s.1 n = some a :=
  by 
    cases' s with f al 
    induction' h with n h IH 
    exacts[id, fun h2 => al (IH h2)]

theorem mem_unique {s : Computation α} {a b : α} : a ∈ s → b ∈ s → a = b
| ⟨m, ha⟩, ⟨n, hb⟩ =>
  by 
    injection (le_stable s (le_max_leftₓ m n) ha.symm).symm.trans (le_stable s (le_max_rightₓ m n) hb.symm)

theorem mem.left_unique : Relator.LeftUnique (· ∈ · : α → Computation α → Prop) :=
  fun a s b => mem_unique

/-- `terminates s` asserts that the computation `s` eventually terminates with some value. -/
class terminates(s : Computation α) : Prop where 
  term : ∃ a, a ∈ s

theorem terminates_iff (s : Computation α) : terminates s ↔ ∃ a, a ∈ s :=
  ⟨fun h => h.1, terminates.mk⟩

theorem terminates_of_mem {s : Computation α} {a : α} (h : a ∈ s) : terminates s :=
  ⟨⟨a, h⟩⟩

theorem terminates_def (s : Computation α) : terminates s ↔ ∃ n, (s.1 n).isSome :=
  ⟨fun ⟨⟨a, n, h⟩⟩ =>
      ⟨n,
        by 
          dsimp [Streamₓ.nth]  at h 
          rw [←h]
          exact rfl⟩,
    fun ⟨n, h⟩ => ⟨⟨Option.get h, n, (Option.eq_some_of_is_some h).symm⟩⟩⟩

theorem ret_mem (a : α) : a ∈ return a :=
  Exists.introₓ 0 rfl

theorem eq_of_ret_mem {a a' : α} (h : a' ∈ return a) : a' = a :=
  mem_unique h (ret_mem _)

instance ret_terminates (a : α) : terminates (return a) :=
  terminates_of_mem (ret_mem _)

theorem think_mem {s : Computation α} {a} : a ∈ s → a ∈ think s
| ⟨n, h⟩ => ⟨n+1, h⟩

instance think_terminates (s : Computation α) : ∀ [terminates s], terminates (think s)
| ⟨⟨a, n, h⟩⟩ => ⟨⟨a, n+1, h⟩⟩

theorem of_think_mem {s : Computation α} {a} : a ∈ think s → a ∈ s
| ⟨n, h⟩ =>
  by 
    cases' n with n' 
    contradiction 
    exact ⟨n', h⟩

theorem of_think_terminates {s : Computation α} : terminates (think s) → terminates s
| ⟨⟨a, h⟩⟩ => ⟨⟨a, of_think_mem h⟩⟩

theorem not_mem_empty (a : α) : a ∉ Empty α :=
  fun ⟨n, h⟩ =>
    by 
      clear _fun_match <;> contradiction

theorem not_terminates_empty : ¬terminates (Empty α) :=
  fun ⟨⟨a, h⟩⟩ => not_mem_empty a h

theorem eq_empty_of_not_terminates {s} (H : ¬terminates s) : s = Empty α :=
  by 
    apply Subtype.eq 
    funext n 
    induction' h : s.val n with 
    ·
      rfl 
    refine' absurd _ H 
    exact ⟨⟨_, _, h.symm⟩⟩

theorem thinkN_mem {s : Computation α} {a} : ∀ n, a ∈ thinkN s n ↔ a ∈ s
| 0 => Iff.rfl
| n+1 => Iff.trans ⟨of_think_mem, think_mem⟩ (thinkN_mem n)

instance thinkN_terminates (s : Computation α) : ∀ [terminates s] n, terminates (thinkN s n)
| ⟨⟨a, h⟩⟩, n => ⟨⟨a, (thinkN_mem n).2 h⟩⟩

theorem of_thinkN_terminates (s : Computation α) n : terminates (thinkN s n) → terminates s
| ⟨⟨a, h⟩⟩ => ⟨⟨a, (thinkN_mem _).1 h⟩⟩

/-- `promises s a`, or `s ~> a`, asserts that although the computation `s`
  may not terminate, if it does, then the result is `a`. -/
def promises (s : Computation α) (a : α) : Prop :=
  ∀ ⦃a'⦄, a' ∈ s → a = a'

infixl:50 " ~> " => promises

theorem mem_promises {s : Computation α} {a : α} : a ∈ s → s ~> a :=
  fun h a' => mem_unique h

theorem empty_promises (a : α) : Empty α ~> a :=
  fun a' h => absurd h (not_mem_empty _)

section get

variable(s : Computation α)[h : terminates s]

include s h

/-- `length s` gets the number of steps of a terminating computation -/
def length : ℕ :=
  Nat.findₓ ((terminates_def _).1 h)

/-- `get s` returns the result of a terminating computation -/
def get : α :=
  Option.get (Nat.find_specₓ$ (terminates_def _).1 h)

theorem get_mem : get s ∈ s :=
  Exists.introₓ (length s) (Option.eq_some_of_is_some _).symm

theorem get_eq_of_mem {a} : a ∈ s → get s = a :=
  mem_unique (get_mem _)

theorem mem_of_get_eq {a} : get s = a → a ∈ s :=
  by 
    intro h <;> rw [←h] <;> apply get_mem

@[simp]
theorem get_think : get (think s) = get s :=
  get_eq_of_mem _$
    let ⟨n, h⟩ := get_mem s
    ⟨n+1, h⟩

@[simp]
theorem get_thinkN n : get (thinkN s n) = get s :=
  get_eq_of_mem _$ (thinkN_mem _).2 (get_mem _)

theorem get_promises : s ~> get s :=
  fun a => get_eq_of_mem _

theorem mem_of_promises {a} (p : s ~> a) : a ∈ s :=
  by 
    cases' h 
    cases' h with a' h 
    rw [p h]
    exact h

theorem get_eq_of_promises {a} : s ~> a → get s = a :=
  get_eq_of_mem _ ∘ mem_of_promises _

end get

/-- `results s a n` completely characterizes a terminating computation:
  it asserts that `s` terminates after exactly `n` steps, with result `a`. -/
def results (s : Computation α) (a : α) (n : ℕ) :=
  ∃ h : a ∈ s, @length _ s (terminates_of_mem h) = n

theorem results_of_terminates (s : Computation α) [T : terminates s] : results s (get s) (length s) :=
  ⟨get_mem _, rfl⟩

theorem results_of_terminates' (s : Computation α) [T : terminates s] {a} (h : a ∈ s) : results s a (length s) :=
  by 
    rw [←get_eq_of_mem _ h] <;> apply results_of_terminates

theorem results.mem {s : Computation α} {a n} : results s a n → a ∈ s
| ⟨m, _⟩ => m

theorem results.terminates {s : Computation α} {a n} (h : results s a n) : terminates s :=
  terminates_of_mem h.mem

theorem results.length {s : Computation α} {a n} [T : terminates s] : results s a n → length s = n
| ⟨_, h⟩ => h

theorem results.val_unique {s : Computation α} {a b m n} (h1 : results s a m) (h2 : results s b n) : a = b :=
  mem_unique h1.mem h2.mem

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem results.len_unique {s : computation α} {a b m n} (h1 : results s a m) (h2 : results s b n) : «expr = »(m, n) :=
by haveI [] [] [":=", expr h1.terminates]; haveI [] [] [":=", expr h2.terminates]; rw ["[", "<-", expr h1.length, ",", expr h2.length, "]"] []

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem exists_results_of_mem {s : computation α} {a} (h : «expr ∈ »(a, s)) : «expr∃ , »((n), results s a n) :=
by haveI [] [] [":=", expr terminates_of_mem h]; exact [expr ⟨_, results_of_terminates' s h⟩]

@[simp]
theorem get_ret (a : α) : get (return a) = a :=
  get_eq_of_mem _ ⟨0, rfl⟩

@[simp]
theorem length_ret (a : α) : length (return a) = 0 :=
  let h := Computation.ret_terminates a 
  Nat.eq_zero_of_le_zeroₓ$ Nat.find_min'ₓ ((terminates_def (return a)).1 h) rfl

theorem results_ret (a : α) : results (return a) a 0 :=
  ⟨_, length_ret _⟩

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem length_think (s : computation α) [h : terminates s] : «expr = »(length (think s), «expr + »(length s, 1)) :=
begin
  apply [expr le_antisymm],
  { exact [expr nat.find_min' _ (nat.find_spec ((terminates_def _).1 h))] },
  { have [] [":", expr (option.is_some ((think s).val (length (think s))) : exprProp())] [":=", expr nat.find_spec ((terminates_def _).1 s.think_terminates)],
    cases [expr length (think s)] ["with", ident n],
    { contradiction },
    { apply [expr nat.succ_le_succ],
      apply [expr nat.find_min'],
      apply [expr this] } }
end

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem results_think {s : computation α} {a n} (h : results s a n) : results (think s) a «expr + »(n, 1) :=
by haveI [] [] [":=", expr h.terminates]; exact [expr ⟨think_mem h.mem, by rw ["[", expr length_think, ",", expr h.length, "]"] []⟩]

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem of_results_think
{s : computation α}
{a n}
(h : results (think s) a n) : «expr∃ , »((m), «expr ∧ »(results s a m, «expr = »(n, «expr + »(m, 1)))) :=
begin
  haveI [] [] [":=", expr of_think_terminates h.terminates],
  have [] [] [":=", expr results_of_terminates' _ (of_think_mem h.mem)],
  exact [expr ⟨_, this, results.len_unique h (results_think this)⟩]
end

@[simp]
theorem results_think_iff {s : Computation α} {a n} : results (think s) a (n+1) ↔ results s a n :=
  ⟨fun h =>
      let ⟨n', r, e⟩ := of_results_think h 
      by 
        injection e with h' <;> rwa [h'],
    results_think⟩

theorem results_thinkN {s : Computation α} {a m} : ∀ n, results s a m → results (thinkN s n) a (m+n)
| 0, h => h
| n+1, h => results_think (results_thinkN n h)

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem results_thinkN_ret (a : α) (n) : results (thinkN (return a) n) a n :=
by have [] [] [":=", expr results_thinkN n (results_ret a)]; rwa [expr nat.zero_add] ["at", ident this]

@[simp]
theorem length_thinkN (s : Computation α) [h : terminates s] n : length (thinkN s n) = length s+n :=
  (results_thinkN n (results_of_terminates _)).length

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem eq_thinkN {s : computation α} {a n} (h : results s a n) : «expr = »(s, thinkN (return a) n) :=
begin
  revert [ident s],
  induction [expr n] [] ["with", ident n, ident IH] []; intro [ident s]; apply [expr cases_on s (λ
    a', _) (λ s, _)]; intro [ident h],
  { rw ["<-", expr eq_of_ret_mem h.mem] [],
    refl },
  { cases [expr of_results_think h] ["with", ident n, ident h],
    cases [expr h] [],
    contradiction },
  { have [] [] [":=", expr h.len_unique (results_ret _)],
    contradiction },
  { rw [expr IH (results_think_iff.1 h)] [],
    refl }
end

theorem eq_thinkN' (s : Computation α) [h : terminates s] : s = thinkN (return (get s)) (length s) :=
  eq_thinkN (results_of_terminates _)

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
def mem_rec_on
{C : computation α → Sort v}
{a s}
(M : «expr ∈ »(a, s))
(h1 : C (return a))
(h2 : ∀ s, C s → C (think s)) : C s :=
begin
  haveI [ident T] [] [":=", expr terminates_of_mem M],
  rw ["[", expr eq_thinkN' s, ",", expr get_eq_of_mem s M, "]"] [],
  generalize [] [":"] [expr «expr = »(length s, n)],
  induction [expr n] [] ["with", ident n, ident IH] [],
  exacts ["[", expr h1, ",", expr h2 _ IH, "]"]
end

def terminates_rec_on {C : Computation α → Sort v} s [terminates s] (h1 : ∀ a, C (return a))
  (h2 : ∀ s, C s → C (think s)) : C s :=
  mem_rec_on (get_mem s) (h1 _) h2

/-- Map a function on the result of a computation. -/
def map (f : α → β) : Computation α → Computation β
| ⟨s, al⟩ =>
  ⟨s.map fun o => Option.casesOn o none (some ∘ f),
    fun n b =>
      by 
        dsimp [Streamₓ.map, Streamₓ.nth]
        induction' e : s n with a <;> intro h
        ·
          contradiction
        ·
          rw [al e, ←h]⟩

def bind.G : Sum β (Computation β) → Sum β (Sum (Computation α) (Computation β))
| Sum.inl b => Sum.inl b
| Sum.inr cb' => Sum.inr$ Sum.inr cb'

def bind.F (f : α → Computation β) : Sum (Computation α) (Computation β) → Sum β (Sum (Computation α) (Computation β))
| Sum.inl ca =>
  match destruct ca with 
  | Sum.inl a => bind.G$ destruct (f a)
  | Sum.inr ca' => Sum.inr$ Sum.inl ca'
| Sum.inr cb => bind.G$ destruct cb

/-- Compose two computations into a monadic `bind` operation. -/
def bind (c : Computation α) (f : α → Computation β) : Computation β :=
  corec (bind.F f) (Sum.inl c)

instance  : Bind Computation :=
  ⟨@bind⟩

theorem has_bind_eq_bind {β} (c : Computation α) (f : α → Computation β) : c >>= f = bind c f :=
  rfl

/-- Flatten a computation of computations into a single computation. -/
def join (c : Computation (Computation α)) : Computation α :=
  c >>= id

@[simp]
theorem map_ret (f : α → β) a : map f (return a) = return (f a) :=
  rfl

@[simp]
theorem map_think (f : α → β) : ∀ s, map f (think s) = think (map f s)
| ⟨s, al⟩ =>
  by 
    apply Subtype.eq <;> dsimp [think, map] <;> rw [Streamₓ.map_cons]

@[simp]
theorem destruct_map (f : α → β) s : destruct (map f s) = lmap f (rmap (map f) (destruct s)) :=
  by 
    apply s.cases_on <;> intro  <;> simp 

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp] theorem map_id : ∀ s : computation α, «expr = »(map id s, s)
| ⟨f, al⟩ := begin
  apply [expr subtype.eq]; simp [] [] [] ["[", expr map, ",", expr function.comp, "]"] [] [],
  have [ident e] [":", expr «expr = »(@option.rec α (λ _, option α) none some, id)] [],
  { ext [] ["⟨", "⟩"] []; refl },
  simp [] [] [] ["[", expr e, ",", expr stream.map_id, "]"] [] []
end

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem map_comp (f : α → β) (g : β → γ) : ∀ s : computation α, «expr = »(map «expr ∘ »(g, f) s, map g (map f s))
| ⟨s, al⟩ := begin
  apply [expr subtype.eq]; dsimp [] ["[", expr map, "]"] [] [],
  rw [expr stream.map_map] [],
  apply [expr congr_arg (λ f : _ → option γ, stream.map f s)],
  ext [] ["⟨", "⟩"] []; refl
end

@[simp]
theorem ret_bind a (f : α → Computation β) : bind (return a) f = f a :=
  by 
    apply eq_of_bisim fun c₁ c₂ => c₁ = bind (return a) f ∧ c₂ = f a ∨ c₁ = corec (bind.F f) (Sum.inr c₂)
    ·
      intro c₁ c₂ h 
      exact
        match c₁, c₂, h with 
        | _, _, Or.inl ⟨rfl, rfl⟩ =>
          by 
            simp [bind, bind.F]
            cases' destruct (f a) with b cb <;> simp [bind.G]
        | _, c, Or.inr rfl =>
          by 
            simp [bind.F]
            cases' destruct c with b cb <;> simp [bind.G]
    ·
      simp 

@[simp]
theorem think_bind c (f : α → Computation β) : bind (think c) f = think (bind c f) :=
  destruct_eq_think$
    by 
      simp [bind, bind.F]

@[simp]
theorem bind_ret (f : α → β) s : bind s (return ∘ f) = map f s :=
  by 
    apply eq_of_bisim fun c₁ c₂ => c₁ = c₂ ∨ ∃ s, c₁ = bind s (return ∘ f) ∧ c₂ = map f s
    ·
      intro c₁ c₂ h 
      exact
        match c₁, c₂, h with 
        | _, _, Or.inl (Eq.refl c) =>
          by 
            cases' destruct c with b cb <;> simp 
        | _, _, Or.inr ⟨s, rfl, rfl⟩ =>
          by 
            apply cases_on s <;> intro s <;> simp 
            exact Or.inr ⟨s, rfl, rfl⟩
    ·
      exact Or.inr ⟨s, rfl, rfl⟩

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp] theorem bind_ret' (s : computation α) : «expr = »(bind s return, s) :=
by rw [expr bind_ret] []; change [expr λ x : α, x] ["with", expr @id α] []; rw [expr map_id] []

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem bind_assoc
(s : computation α)
(f : α → computation β)
(g : β → computation γ) : «expr = »(bind (bind s f) g, bind s (λ x : α, bind (f x) g)) :=
begin
  apply [expr eq_of_bisim (λ
    c₁
    c₂, «expr ∨ »(«expr = »(c₁, c₂), «expr∃ , »((s), «expr ∧ »(«expr = »(c₁, bind (bind s f) g), «expr = »(c₂, bind s (λ
         x : α, bind (f x) g))))))],
  { intros [ident c₁, ident c₂, ident h],
    exact [expr match c₁, c₂, h with
     | _, _, or.inl (eq.refl c) := by cases [expr destruct c] ["with", ident b, ident cb]; simp [] [] [] [] [] []
     | ._, ._, or.inr ⟨s, rfl, rfl⟩ := begin
       apply [expr cases_on s]; intros [ident s]; simp [] [] [] [] [] [],
       { generalize [] [":"] [expr «expr = »(f s, fs)],
         apply [expr cases_on fs]; intros [ident t]; simp [] [] [] [] [] [],
         { cases [expr destruct (g t)] ["with", ident b, ident cb]; simp [] [] [] [] [] [] } },
       { exact [expr or.inr ⟨s, rfl, rfl⟩] }
     end
     end] },
  { exact [expr or.inr ⟨s, rfl, rfl⟩] }
end

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem results_bind
{s : computation α}
{f : α → computation β}
{a b m n}
(h1 : results s a m)
(h2 : results (f a) b n) : results (bind s f) b «expr + »(n, m) :=
begin
  have [] [] [":=", expr h1.mem],
  revert [ident m],
  apply [expr mem_rec_on this _ (λ s IH, _)]; intros [ident m, ident h1],
  { rw ["[", expr ret_bind, "]"] [],
    rw [expr h1.len_unique (results_ret _)] [],
    exact [expr h2] },
  { rw ["[", expr think_bind, "]"] [],
    cases [expr of_results_think h1] ["with", ident m', ident h],
    cases [expr h] ["with", ident h1, ident e],
    rw [expr e] [],
    exact [expr results_think (IH h1)] }
end

theorem mem_bind {s : Computation α} {f : α → Computation β} {a b} (h1 : a ∈ s) (h2 : b ∈ f a) : b ∈ bind s f :=
  let ⟨m, h1⟩ := exists_results_of_mem h1 
  let ⟨n, h2⟩ := exists_results_of_mem h2
  (results_bind h1 h2).Mem

instance terminates_bind (s : Computation α) (f : α → Computation β) [terminates s] [terminates (f (get s))] :
  terminates (bind s f) :=
  terminates_of_mem (mem_bind (get_mem s) (get_mem (f (get s))))

@[simp]
theorem get_bind (s : Computation α) (f : α → Computation β) [terminates s] [terminates (f (get s))] :
  get (bind s f) = get (f (get s)) :=
  get_eq_of_mem _ (mem_bind (get_mem s) (get_mem (f (get s))))

@[simp]
theorem length_bind (s : Computation α) (f : α → Computation β) [T1 : terminates s] [T2 : terminates (f (get s))] :
  length (bind s f) = length (f (get s))+length s :=
  (results_of_terminates _).len_unique$ results_bind (results_of_terminates _) (results_of_terminates _)

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem of_results_bind
{s : computation α}
{f : α → computation β}
{b
 k} : results (bind s f) b k → «expr∃ , »((a
  m
  n), «expr ∧ »(results s a m, «expr ∧ »(results (f a) b n, «expr = »(k, «expr + »(n, m))))) :=
begin
  induction [expr k] [] ["with", ident n, ident IH] ["generalizing", ident s]; apply [expr cases_on s (λ
    a, _) (λ s', _)]; intro [ident e],
  { simp [] [] [] ["[", expr thinkN, "]"] [] ["at", ident e],
    refine [expr ⟨a, _, _, results_ret _, e, rfl⟩] },
  { have [] [] [":=", expr congr_arg head (eq_thinkN e)],
    contradiction },
  { simp [] [] [] [] [] ["at", ident e],
    refine [expr ⟨a, _, «expr + »(n, 1), results_ret _, e, rfl⟩] },
  { simp [] [] [] [] [] ["at", ident e],
    exact [expr let ⟨a, m, n', h1, h2, e'⟩ := IH e in
     by rw [expr e'] []; exact [expr ⟨a, m.succ, n', results_think h1, h2, rfl⟩]] }
end

theorem exists_of_mem_bind {s : Computation α} {f : α → Computation β} {b} (h : b ∈ bind s f) :
  ∃ (a : _)(_ : a ∈ s), b ∈ f a :=
  let ⟨k, h⟩ := exists_results_of_mem h 
  let ⟨a, m, n, h1, h2, e⟩ := of_results_bind h
  ⟨a, h1.mem, h2.mem⟩

theorem bind_promises {s : Computation α} {f : α → Computation β} {a b} (h1 : s ~> a) (h2 : f a ~> b) : bind s f ~> b :=
  fun b' bB =>
    by 
      rcases exists_of_mem_bind bB with ⟨a', a's, ba'⟩
      rw [←h1 a's] at ba' 
      exact h2 ba'

instance  : Monadₓ Computation :=
  { map := @map, pure := @return, bind := @bind }

instance  : IsLawfulMonad Computation :=
  { id_map := @map_id, bind_pure_comp_eq_map := @bind_ret, pure_bind := @ret_bind, bind_assoc := @bind_assoc }

theorem has_map_eq_map {β} (f : α → β) (c : Computation α) : f <$> c = map f c :=
  rfl

@[simp]
theorem return_def a : (_root_.return a : Computation α) = return a :=
  rfl

@[simp]
theorem map_ret' {α β} : ∀ (f : α → β) a, f <$> return a = return (f a) :=
  map_ret

@[simp]
theorem map_think' {α β} : ∀ (f : α → β) s, f <$> think s = think (f <$> s) :=
  map_think

theorem mem_map (f : α → β) {a} {s : Computation α} (m : a ∈ s) : f a ∈ map f s :=
  by 
    rw [←bind_ret] <;> apply mem_bind m <;> apply ret_mem

theorem exists_of_mem_map {f : α → β} {b : β} {s : Computation α} (h : b ∈ map f s) : ∃ a, a ∈ s ∧ f a = b :=
  by 
    rw [←bind_ret] at h <;>
      exact
        let ⟨a, as, fb⟩ := exists_of_mem_bind h
        ⟨a, as, mem_unique (ret_mem _) fb⟩

instance terminates_map (f : α → β) (s : Computation α) [terminates s] : terminates (map f s) :=
  by 
    rw [←bind_ret] <;> infer_instance

theorem terminates_map_iff (f : α → β) (s : Computation α) : terminates (map f s) ↔ terminates s :=
  ⟨fun ⟨⟨a, h⟩⟩ =>
      let ⟨b, h1, _⟩ := exists_of_mem_map h
      ⟨⟨_, h1⟩⟩,
    @Computation.terminates_map _ _ _ _⟩

/-- `c₁ <|> c₂` calculates `c₁` and `c₂` simultaneously, returning
  the first one that gives a result. -/
def orelse (c₁ c₂ : Computation α) : Computation α :=
  @Computation.corec α (Computation α × Computation α)
    (fun ⟨c₁, c₂⟩ =>
      match destruct c₁ with 
      | Sum.inl a => Sum.inl a
      | Sum.inr c₁' =>
        match destruct c₂ with 
        | Sum.inl a => Sum.inl a
        | Sum.inr c₂' => Sum.inr (c₁', c₂'))
    (c₁, c₂)

instance  : Alternativeₓ Computation :=
  { Computation.monad with orelse := @orelse, failure := @Empty }

@[simp]
theorem ret_orelse (a : α) (c₂ : Computation α) : (return a <|> c₂) = return a :=
  destruct_eq_ret$
    by 
      unfold HasOrelse.orelse <;> simp [orelse]

@[simp]
theorem orelse_ret (c₁ : Computation α) (a : α) : (think c₁ <|> return a) = return a :=
  destruct_eq_ret$
    by 
      unfold HasOrelse.orelse <;> simp [orelse]

@[simp]
theorem orelse_think (c₁ c₂ : Computation α) : (think c₁ <|> think c₂) = think (c₁ <|> c₂) :=
  destruct_eq_think$
    by 
      unfold HasOrelse.orelse <;> simp [orelse]

@[simp]
theorem empty_orelse c : (Empty α <|> c) = c :=
  by 
    apply eq_of_bisim (fun c₁ c₂ => (Empty α <|> c₂) = c₁) _ rfl 
    intro s' s h 
    rw [←h]
    apply cases_on s <;> intro s <;> rw [think_empty] <;> simp 
    rw [←think_empty]

@[simp]
theorem orelse_empty (c : Computation α) : (c <|> Empty α) = c :=
  by 
    apply eq_of_bisim (fun c₁ c₂ => (c₂ <|> Empty α) = c₁) _ rfl 
    intro s' s h 
    rw [←h]
    apply cases_on s <;> intro s <;> rw [think_empty] <;> simp 
    rw [←think_empty]

/-- `c₁ ~ c₂` asserts that `c₁` and `c₂` either both terminate with the same result,
  or both loop forever. -/
def equiv (c₁ c₂ : Computation α) : Prop :=
  ∀ a, a ∈ c₁ ↔ a ∈ c₂

infixl:50 " ~ " => equiv

@[refl]
theorem equiv.refl (s : Computation α) : s ~ s :=
  fun _ => Iff.rfl

@[symm]
theorem equiv.symm {s t : Computation α} : s ~ t → t ~ s :=
  fun h a => (h a).symm

@[trans]
theorem equiv.trans {s t u : Computation α} : s ~ t → t ~ u → s ~ u :=
  fun h1 h2 a => (h1 a).trans (h2 a)

theorem equiv.equivalence : Equivalenceₓ (@equiv α) :=
  ⟨@equiv.refl _, @equiv.symm _, @equiv.trans _⟩

theorem equiv_of_mem {s t : Computation α} {a} (h1 : a ∈ s) (h2 : a ∈ t) : s ~ t :=
  fun a' =>
    ⟨fun ma =>
        by 
          rw [mem_unique ma h1] <;> exact h2,
      fun ma =>
        by 
          rw [mem_unique ma h2] <;> exact h1⟩

theorem terminates_congr {c₁ c₂ : Computation α} (h : c₁ ~ c₂) : terminates c₁ ↔ terminates c₂ :=
  by 
    simp only [terminates_iff, exists_congr h]

theorem promises_congr {c₁ c₂ : Computation α} (h : c₁ ~ c₂) a : c₁ ~> a ↔ c₂ ~> a :=
  forall_congrₓ fun a' => imp_congr (h a') Iff.rfl

theorem get_equiv {c₁ c₂ : Computation α} (h : c₁ ~ c₂) [terminates c₁] [terminates c₂] : get c₁ = get c₂ :=
  get_eq_of_mem _$ (h _).2$ get_mem _

theorem think_equiv (s : Computation α) : think s ~ s :=
  fun a => ⟨of_think_mem, think_mem⟩

theorem thinkN_equiv (s : Computation α) n : thinkN s n ~ s :=
  fun a => thinkN_mem n

theorem bind_congr {s1 s2 : Computation α} {f1 f2 : α → Computation β} (h1 : s1 ~ s2) (h2 : ∀ a, f1 a ~ f2 a) :
  bind s1 f1 ~ bind s2 f2 :=
  fun b =>
    ⟨fun h =>
        let ⟨a, ha, hb⟩ := exists_of_mem_bind h 
        mem_bind ((h1 a).1 ha) ((h2 a b).1 hb),
      fun h =>
        let ⟨a, ha, hb⟩ := exists_of_mem_bind h 
        mem_bind ((h1 a).2 ha) ((h2 a b).2 hb)⟩

theorem equiv_ret_of_mem {s : Computation α} {a} (h : a ∈ s) : s ~ return a :=
  equiv_of_mem h (ret_mem _)

/-- `lift_rel R ca cb` is a generalization of `equiv` to relations other than
  equality. It asserts that if `ca` terminates with `a`, then `cb` terminates with
  some `b` such that `R a b`, and if `cb` terminates with `b` then `ca` terminates
  with some `a` such that `R a b`. -/
def lift_rel (R : α → β → Prop) (ca : Computation α) (cb : Computation β) : Prop :=
  (∀ {a}, a ∈ ca → ∃ b, b ∈ cb ∧ R a b) ∧ ∀ {b}, b ∈ cb → ∃ a, a ∈ ca ∧ R a b

theorem lift_rel.swap (R : α → β → Prop) (ca : Computation α) (cb : Computation β) :
  lift_rel (swap R) cb ca ↔ lift_rel R ca cb :=
  and_comm _ _

theorem lift_eq_iff_equiv (c₁ c₂ : Computation α) : lift_rel (· = ·) c₁ c₂ ↔ c₁ ~ c₂ :=
  ⟨fun ⟨h1, h2⟩ a =>
      ⟨fun a1 =>
          let ⟨b, b2, ab⟩ := h1 a1 
          by 
            rwa [ab],
        fun a2 =>
          let ⟨b, b1, ab⟩ := h2 a2 
          by 
            rwa [←ab]⟩,
    fun e => ⟨fun a a1 => ⟨a, (e _).1 a1, rfl⟩, fun a a2 => ⟨a, (e _).2 a2, rfl⟩⟩⟩

theorem lift_rel.refl (R : α → α → Prop) (H : Reflexive R) : Reflexive (lift_rel R) :=
  fun s => ⟨fun a as => ⟨a, as, H a⟩, fun b bs => ⟨b, bs, H b⟩⟩

theorem lift_rel.symm (R : α → α → Prop) (H : Symmetric R) : Symmetric (lift_rel R) :=
  fun s1 s2 ⟨l, r⟩ =>
    ⟨fun a a2 =>
        let ⟨b, b1, ab⟩ := r a2
        ⟨b, b1, H ab⟩,
      fun a a1 =>
        let ⟨b, b2, ab⟩ := l a1
        ⟨b, b2, H ab⟩⟩

theorem lift_rel.trans (R : α → α → Prop) (H : Transitive R) : Transitive (lift_rel R) :=
  fun s1 s2 s3 ⟨l1, r1⟩ ⟨l2, r2⟩ =>
    ⟨fun a a1 =>
        let ⟨b, b2, ab⟩ := l1 a1 
        let ⟨c, c3, bc⟩ := l2 b2
        ⟨c, c3, H ab bc⟩,
      fun c c3 =>
        let ⟨b, b2, bc⟩ := r2 c3 
        let ⟨a, a1, ab⟩ := r1 b2
        ⟨a, a1, H ab bc⟩⟩

theorem lift_rel.equiv (R : α → α → Prop) : Equivalenceₓ R → Equivalenceₓ (lift_rel R)
| ⟨refl, symm, trans⟩ => ⟨lift_rel.refl R refl, lift_rel.symm R symm, lift_rel.trans R trans⟩

theorem lift_rel.imp {R S : α → β → Prop} (H : ∀ {a b}, R a b → S a b) s t : lift_rel R s t → lift_rel S s t
| ⟨l, r⟩ =>
  ⟨fun a as =>
      let ⟨b, bt, ab⟩ := l as
      ⟨b, bt, H ab⟩,
    fun b bt =>
      let ⟨a, as, ab⟩ := r bt
      ⟨a, as, H ab⟩⟩

theorem terminates_of_lift_rel {R : α → β → Prop} {s t} : lift_rel R s t → (terminates s ↔ terminates t)
| ⟨l, r⟩ =>
  ⟨fun ⟨⟨a, as⟩⟩ =>
      let ⟨b, bt, ab⟩ := l as
      ⟨⟨b, bt⟩⟩,
    fun ⟨⟨b, bt⟩⟩ =>
      let ⟨a, as, ab⟩ := r bt
      ⟨⟨a, as⟩⟩⟩

theorem rel_of_lift_rel {R : α → β → Prop} {ca cb} : lift_rel R ca cb → ∀ {a b}, a ∈ ca → b ∈ cb → R a b
| ⟨l, r⟩, a, b, ma, mb =>
  let ⟨b', mb', ab'⟩ := l ma 
  by 
    rw [mem_unique mb mb'] <;> exact ab'

theorem lift_rel_of_mem {R : α → β → Prop} {a b ca cb} (ma : a ∈ ca) (mb : b ∈ cb) (ab : R a b) : lift_rel R ca cb :=
  ⟨fun a' ma' =>
      by 
        rw [mem_unique ma' ma] <;> exact ⟨b, mb, ab⟩,
    fun b' mb' =>
      by 
        rw [mem_unique mb' mb] <;> exact ⟨a, ma, ab⟩⟩

theorem exists_of_lift_rel_left {R : α → β → Prop} {ca cb} (H : lift_rel R ca cb) {a} (h : a ∈ ca) :
  ∃ b, b ∈ cb ∧ R a b :=
  H.left h

theorem exists_of_lift_rel_right {R : α → β → Prop} {ca cb} (H : lift_rel R ca cb) {b} (h : b ∈ cb) :
  ∃ a, a ∈ ca ∧ R a b :=
  H.right h

theorem lift_rel_def {R : α → β → Prop} {ca cb} :
  lift_rel R ca cb ↔ (terminates ca ↔ terminates cb) ∧ ∀ {a b}, a ∈ ca → b ∈ cb → R a b :=
  ⟨fun h =>
      ⟨terminates_of_lift_rel h,
        fun a b ma mb =>
          let ⟨b', mb', ab⟩ := h.left ma 
          by 
            rwa [mem_unique mb mb']⟩,
    fun ⟨l, r⟩ =>
      ⟨fun a ma =>
          let ⟨⟨b, mb⟩⟩ := l.1 ⟨⟨_, ma⟩⟩
          ⟨b, mb, r ma mb⟩,
        fun b mb =>
          let ⟨⟨a, ma⟩⟩ := l.2 ⟨⟨_, mb⟩⟩
          ⟨a, ma, r ma mb⟩⟩⟩

theorem lift_rel_bind {δ} (R : α → β → Prop) (S : γ → δ → Prop) {s1 : Computation α} {s2 : Computation β}
  {f1 : α → Computation γ} {f2 : β → Computation δ} (h1 : lift_rel R s1 s2)
  (h2 : ∀ {a b}, R a b → lift_rel S (f1 a) (f2 b)) : lift_rel S (bind s1 f1) (bind s2 f2) :=
  let ⟨l1, r1⟩ := h1
  ⟨fun c cB =>
      let ⟨a, a1, c₁⟩ := exists_of_mem_bind cB 
      let ⟨b, b2, ab⟩ := l1 a1 
      let ⟨l2, r2⟩ := h2 ab 
      let ⟨d, d2, cd⟩ := l2 c₁
      ⟨_, mem_bind b2 d2, cd⟩,
    fun d dB =>
      let ⟨b, b1, d1⟩ := exists_of_mem_bind dB 
      let ⟨a, a2, ab⟩ := r1 b1 
      let ⟨l2, r2⟩ := h2 ab 
      let ⟨c, c₂, cd⟩ := r2 d1
      ⟨_, mem_bind a2 c₂, cd⟩⟩

@[simp]
theorem lift_rel_return_left (R : α → β → Prop) (a : α) (cb : Computation β) :
  lift_rel R (return a) cb ↔ ∃ b, b ∈ cb ∧ R a b :=
  ⟨fun ⟨l, r⟩ => l (ret_mem _),
    fun ⟨b, mb, ab⟩ =>
      ⟨fun a' ma' =>
          by 
            rw [eq_of_ret_mem ma'] <;> exact ⟨b, mb, ab⟩,
        fun b' mb' =>
          ⟨_, ret_mem _,
            by 
              rw [mem_unique mb' mb] <;> exact ab⟩⟩⟩

@[simp]
theorem lift_rel_return_right (R : α → β → Prop) (ca : Computation α) (b : β) :
  lift_rel R ca (return b) ↔ ∃ a, a ∈ ca ∧ R a b :=
  by 
    rw [lift_rel.swap, lift_rel_return_left]

@[simp]
theorem lift_rel_return (R : α → β → Prop) (a : α) (b : β) : lift_rel R (return a) (return b) ↔ R a b :=
  by 
    rw [lift_rel_return_left] <;>
      exact
        ⟨fun ⟨b', mb', ab'⟩ =>
            by 
              rwa [eq_of_ret_mem mb'] at ab',
          fun ab => ⟨_, ret_mem _, ab⟩⟩

@[simp]
theorem lift_rel_think_left (R : α → β → Prop) (ca : Computation α) (cb : Computation β) :
  lift_rel R (think ca) cb ↔ lift_rel R ca cb :=
  and_congr (forall_congrₓ$ fun b => imp_congr ⟨of_think_mem, think_mem⟩ Iff.rfl)
    (forall_congrₓ$ fun b => imp_congr Iff.rfl$ exists_congr$ fun b => and_congr ⟨of_think_mem, think_mem⟩ Iff.rfl)

@[simp]
theorem lift_rel_think_right (R : α → β → Prop) (ca : Computation α) (cb : Computation β) :
  lift_rel R ca (think cb) ↔ lift_rel R ca cb :=
  by 
    rw [←lift_rel.swap R, ←lift_rel.swap R] <;> apply lift_rel_think_left

theorem lift_rel_mem_cases {R : α → β → Prop} {ca cb} (Ha : ∀ a (_ : a ∈ ca), lift_rel R ca cb)
  (Hb : ∀ b (_ : b ∈ cb), lift_rel R ca cb) : lift_rel R ca cb :=
  ⟨fun a ma => (Ha _ ma).left ma, fun b mb => (Hb _ mb).right mb⟩

theorem lift_rel_congr {R : α → β → Prop} {ca ca' : Computation α} {cb cb' : Computation β} (ha : ca ~ ca')
  (hb : cb ~ cb') : lift_rel R ca cb ↔ lift_rel R ca' cb' :=
  and_congr (forall_congrₓ$ fun a => imp_congr (ha _)$ exists_congr$ fun b => and_congr (hb _) Iff.rfl)
    (forall_congrₓ$ fun b => imp_congr (hb _)$ exists_congr$ fun a => and_congr (ha _) Iff.rfl)

theorem lift_rel_map {δ} (R : α → β → Prop) (S : γ → δ → Prop) {s1 : Computation α} {s2 : Computation β} {f1 : α → γ}
  {f2 : β → δ} (h1 : lift_rel R s1 s2) (h2 : ∀ {a b}, R a b → S (f1 a) (f2 b)) : lift_rel S (map f1 s1) (map f2 s2) :=
  by 
    rw [←bind_ret, ←bind_ret] <;> apply lift_rel_bind _ _ h1 <;> simp  <;> exact @h2

theorem map_congr (R : α → α → Prop) (S : β → β → Prop) {s1 s2 : Computation α} {f : α → β} (h1 : s1 ~ s2) :
  map f s1 ~ map f s2 :=
  by 
    rw [←lift_eq_iff_equiv] <;> exact lift_rel_map Eq _ ((lift_eq_iff_equiv _ _).2 h1) fun a b => congr_argₓ _

def lift_rel_aux (R : α → β → Prop) (C : Computation α → Computation β → Prop) :
  Sum α (Computation α) → Sum β (Computation β) → Prop
| Sum.inl a, Sum.inl b => R a b
| Sum.inl a, Sum.inr cb => ∃ b, b ∈ cb ∧ R a b
| Sum.inr ca, Sum.inl b => ∃ a, a ∈ ca ∧ R a b
| Sum.inr ca, Sum.inr cb => C ca cb

attribute [simp] lift_rel_aux

@[simp]
theorem lift_rel_aux.ret_left (R : α → β → Prop) (C : Computation α → Computation β → Prop) a cb :
  lift_rel_aux R C (Sum.inl a) (destruct cb) ↔ ∃ b, b ∈ cb ∧ R a b :=
  by 
    apply cb.cases_on (fun b => _) fun cb => _
    ·
      exact
        ⟨fun h => ⟨_, ret_mem _, h⟩,
          fun ⟨b', mb, h⟩ =>
            by 
              rw [mem_unique (ret_mem _) mb] <;> exact h⟩
    ·
      rw [destruct_think]
      exact ⟨fun ⟨b, h, r⟩ => ⟨b, think_mem h, r⟩, fun ⟨b, h, r⟩ => ⟨b, of_think_mem h, r⟩⟩

theorem lift_rel_aux.swap (R : α → β → Prop) C a b : lift_rel_aux (swap R) (swap C) b a = lift_rel_aux R C a b :=
  by 
    cases' a with a ca <;> cases' b with b cb <;> simp only [lift_rel_aux]

@[simp]
theorem lift_rel_aux.ret_right (R : α → β → Prop) (C : Computation α → Computation β → Prop) b ca :
  lift_rel_aux R C (destruct ca) (Sum.inl b) ↔ ∃ a, a ∈ ca ∧ R a b :=
  by 
    rw [←lift_rel_aux.swap, lift_rel_aux.ret_left]

-- error in Data.Seq.Computation: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem lift_rel_rec.lem
{R : α → β → exprProp()}
(C : computation α → computation β → exprProp())
(H : ∀ {ca cb}, C ca cb → lift_rel_aux R C (destruct ca) (destruct cb))
(ca cb)
(Hc : C ca cb)
(a)
(ha : «expr ∈ »(a, ca)) : lift_rel R ca cb :=
begin
  revert [ident cb],
  refine [expr mem_rec_on ha _ (λ ca' IH, _)]; intros [ident cb, ident Hc]; have [ident h] [] [":=", expr H Hc],
  { simp [] [] [] [] [] ["at", ident h],
    simp [] [] [] ["[", expr h, "]"] [] [] },
  { have [ident h] [] [":=", expr H Hc],
    simp [] [] [] [] [] [],
    revert [ident h],
    apply [expr cb.cases_on (λ
      b, _) (λ cb', _)]; intro [ident h]; simp [] [] [] [] [] ["at", ident h]; simp [] [] [] ["[", expr h, "]"] [] [],
    exact [expr IH _ h] }
end

theorem lift_rel_rec {R : α → β → Prop} (C : Computation α → Computation β → Prop)
  (H : ∀ {ca cb}, C ca cb → lift_rel_aux R C (destruct ca) (destruct cb)) ca cb (Hc : C ca cb) : lift_rel R ca cb :=
  lift_rel_mem_cases (lift_rel_rec.lem C (@H) ca cb Hc)
    fun b hb =>
      (lift_rel.swap _ _ _).2$
        lift_rel_rec.lem (swap C) (fun cb ca h => cast (lift_rel_aux.swap _ _ _ _).symm$ H h) cb ca Hc b hb

end Computation

