import Mathbin.Logic.Function.Basic

/-!
# More theorems about the sum type
-/


universe u v w x

variable{α : Type u}{α' : Type w}{β : Type v}{β' : Type x}

open Sum

/-- Check if a sum is `inl` and if so, retrieve its contents. -/
@[simp]
def Sum.getLeft {α β} : Sum α β → Option α
| inl a => some a
| inr _ => none

/-- Check if a sum is `inr` and if so, retrieve its contents. -/
@[simp]
def Sum.getRight {α β} : Sum α β → Option β
| inr b => some b
| inl _ => none

/-- Check if a sum is `inl`. -/
@[simp]
def Sum.isLeft {α β} : Sum α β → Bool
| inl _ => tt
| inr _ => ff

/-- Check if a sum is `inr`. -/
@[simp]
def Sum.isRight {α β} : Sum α β → Bool
| inl _ => ff
| inr _ => tt

-- error in Data.Sum: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler decidable_eq
attribute [derive #[expr decidable_eq]] sum

@[simp]
theorem Sum.forall {p : Sum α β → Prop} : (∀ x, p x) ↔ (∀ a, p (inl a)) ∧ ∀ b, p (inr b) :=
  ⟨fun h => ⟨fun a => h _, fun b => h _⟩, fun ⟨h₁, h₂⟩ => Sum.rec h₁ h₂⟩

@[simp]
theorem Sum.exists {p : Sum α β → Prop} : (∃ x, p x) ↔ (∃ a, p (inl a)) ∨ ∃ b, p (inr b) :=
  ⟨fun h =>
      match h with 
      | ⟨inl a, h⟩ => Or.inl ⟨a, h⟩
      | ⟨inr b, h⟩ => Or.inr ⟨b, h⟩,
    fun h =>
      match h with 
      | Or.inl ⟨a, h⟩ => ⟨inl a, h⟩
      | Or.inr ⟨b, h⟩ => ⟨inr b, h⟩⟩

namespace Sum

theorem inl_injective : Function.Injective (Sum.inl : α → Sum α β) :=
  fun x y => Sum.inl.injₓ

theorem inr_injective : Function.Injective (Sum.inr : β → Sum α β) :=
  fun x y => Sum.inr.injₓ

/-- Map `α ⊕ β` to `α' ⊕ β'` sending `α` to `α'` and `β` to `β'`. -/
protected def map (f : α → α') (g : β → β') : Sum α β → Sum α' β'
| Sum.inl x => Sum.inl (f x)
| Sum.inr x => Sum.inr (g x)

@[simp]
theorem map_inl (f : α → α') (g : β → β') (x : α) : (inl x).map f g = inl (f x) :=
  rfl

@[simp]
theorem map_inr (f : α → α') (g : β → β') (x : β) : (inr x).map f g = inr (g x) :=
  rfl

@[simp]
theorem map_map {α'' β''} (f' : α' → α'') (g' : β' → β'') (f : α → α') (g : β → β') :
  ∀ (x : Sum α β), (x.map f g).map f' g' = x.map (f' ∘ f) (g' ∘ g)
| inl a => rfl
| inr b => rfl

@[simp]
theorem map_comp_map {α'' β''} (f' : α' → α'') (g' : β' → β'') (f : α → α') (g : β → β') :
  Sum.map f' g' ∘ Sum.map f g = Sum.map (f' ∘ f) (g' ∘ g) :=
  funext$ map_map f' g' f g

@[simp]
theorem map_id_id α β : Sum.map (@id α) (@id β) = id :=
  funext$ fun x => Sum.recOn x (fun _ => rfl) fun _ => rfl

theorem inl.inj_iff {a b} : (inl a : Sum α β) = inl b ↔ a = b :=
  ⟨inl.inj, congr_argₓ _⟩

theorem inr.inj_iff {a b} : (inr a : Sum α β) = inr b ↔ a = b :=
  ⟨inr.inj, congr_argₓ _⟩

theorem inl_ne_inr {a : α} {b : β} : inl a ≠ inr b :=
  fun.

theorem inr_ne_inl {a : α} {b : β} : inr b ≠ inl a :=
  fun.

/-- Define a function on `α ⊕ β` by giving separate definitions on `α` and `β`. -/
protected def elim {α β γ : Sort _} (f : α → γ) (g : β → γ) : Sum α β → γ :=
  fun x => Sum.recOn x f g

@[simp]
theorem elim_inl {α β γ : Sort _} (f : α → γ) (g : β → γ) (x : α) : Sum.elim f g (inl x) = f x :=
  rfl

@[simp]
theorem elim_inr {α β γ : Sort _} (f : α → γ) (g : β → γ) (x : β) : Sum.elim f g (inr x) = g x :=
  rfl

@[simp]
theorem elim_comp_inl {α β γ : Sort _} (f : α → γ) (g : β → γ) : Sum.elim f g ∘ inl = f :=
  rfl

@[simp]
theorem elim_comp_inr {α β γ : Sort _} (f : α → γ) (g : β → γ) : Sum.elim f g ∘ inr = g :=
  rfl

@[simp]
theorem elim_inl_inr {α β : Sort _} : @Sum.elim α β _ inl inr = id :=
  funext$ fun x => Sum.casesOn x (fun _ => rfl) fun _ => rfl

theorem comp_elim {α β γ δ : Sort _} (f : γ → δ) (g : α → γ) (h : β → γ) :
  f ∘ Sum.elim g h = Sum.elim (f ∘ g) (f ∘ h) :=
  funext$ fun x => Sum.casesOn x (fun _ => rfl) fun _ => rfl

@[simp]
theorem elim_comp_inl_inr {α β γ : Sort _} (f : Sum α β → γ) : Sum.elim (f ∘ inl) (f ∘ inr) = f :=
  funext$ fun x => Sum.casesOn x (fun _ => rfl) fun _ => rfl

open function(update update_eq_iff update_comp_eq_of_injective update_comp_eq_of_forall_ne)

-- error in Data.Sum: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem update_elim_inl
{α β γ}
[decidable_eq α]
[decidable_eq «expr ⊕ »(α, β)]
{f : α → γ}
{g : β → γ}
{i : α}
{x : γ} : «expr = »(update (sum.elim f g) (inl i) x, sum.elim (update f i x) g) :=
update_eq_iff.2 ⟨by simp [] [] [] [] [] [], by simp [] [] [] [] [] [] { contextual := tt }⟩

-- error in Data.Sum: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem update_elim_inr
{α β γ}
[decidable_eq β]
[decidable_eq «expr ⊕ »(α, β)]
{f : α → γ}
{g : β → γ}
{i : β}
{x : γ} : «expr = »(update (sum.elim f g) (inr i) x, sum.elim f (update g i x)) :=
update_eq_iff.2 ⟨by simp [] [] [] [] [] [], by simp [] [] [] [] [] [] { contextual := tt }⟩

@[simp]
theorem update_inl_comp_inl {α β γ} [DecidableEq α] [DecidableEq (Sum α β)] {f : Sum α β → γ} {i : α} {x : γ} :
  update f (inl i) x ∘ inl = update (f ∘ inl) i x :=
  update_comp_eq_of_injective _ inl_injective _ _

@[simp]
theorem update_inl_apply_inl {α β γ} [DecidableEq α] [DecidableEq (Sum α β)] {f : Sum α β → γ} {i j : α} {x : γ} :
  update f (inl i) x (inl j) = update (f ∘ inl) i x j :=
  by 
    rw [←update_inl_comp_inl]

@[simp]
theorem update_inl_comp_inr {α β γ} [DecidableEq (Sum α β)] {f : Sum α β → γ} {i : α} {x : γ} :
  update f (inl i) x ∘ inr = f ∘ inr :=
  update_comp_eq_of_forall_ne _ _$ fun _ => inr_ne_inl

@[simp]
theorem update_inl_apply_inr {α β γ} [DecidableEq (Sum α β)] {f : Sum α β → γ} {i : α} {j : β} {x : γ} :
  update f (inl i) x (inr j) = f (inr j) :=
  Function.update_noteq inr_ne_inl _ _

@[simp]
theorem update_inr_comp_inl {α β γ} [DecidableEq (Sum α β)] {f : Sum α β → γ} {i : β} {x : γ} :
  update f (inr i) x ∘ inl = f ∘ inl :=
  update_comp_eq_of_forall_ne _ _$ fun _ => inl_ne_inr

@[simp]
theorem update_inr_apply_inl {α β γ} [DecidableEq (Sum α β)] {f : Sum α β → γ} {i : α} {j : β} {x : γ} :
  update f (inr j) x (inl i) = f (inl i) :=
  Function.update_noteq inl_ne_inr _ _

@[simp]
theorem update_inr_comp_inr {α β γ} [DecidableEq β] [DecidableEq (Sum α β)] {f : Sum α β → γ} {i : β} {x : γ} :
  update f (inr i) x ∘ inr = update (f ∘ inr) i x :=
  update_comp_eq_of_injective _ inr_injective _ _

@[simp]
theorem update_inr_apply_inr {α β γ} [DecidableEq β] [DecidableEq (Sum α β)] {f : Sum α β → γ} {i j : β} {x : γ} :
  update f (inr i) x (inr j) = update (f ∘ inr) i x j :=
  by 
    rw [←update_inr_comp_inr]

section 

variable(ra : α → α → Prop)(rb : β → β → Prop)

/-- Lexicographic order for sum. Sort all the `inl a` before the `inr b`,
    otherwise use the respective order on `α` or `β`. -/
inductive lex : Sum α β → Sum α β → Prop
  | inl {a₁ a₂} (h : ra a₁ a₂) : lex (inl a₁) (inl a₂)
  | inr {b₁ b₂} (h : rb b₁ b₂) : lex (inr b₁) (inr b₂)
  | sep a b : lex (inl a) (inr b)

variable{ra rb}

@[simp]
theorem lex_inl_inl {a₁ a₂} : lex ra rb (inl a₁) (inl a₂) ↔ ra a₁ a₂ :=
  ⟨fun h =>
      by 
        cases h <;> assumption,
    lex.inl⟩

@[simp]
theorem lex_inr_inr {b₁ b₂} : lex ra rb (inr b₁) (inr b₂) ↔ rb b₁ b₂ :=
  ⟨fun h =>
      by 
        cases h <;> assumption,
    lex.inr⟩

@[simp]
theorem lex_inr_inl {b a} : ¬lex ra rb (inr b) (inl a) :=
  fun h =>
    by 
      cases h

attribute [simp] lex.sep

theorem lex_acc_inl {a} (aca : Acc ra a) : Acc (lex ra rb) (inl a) :=
  by 
    induction' aca with a H IH 
    constructor 
    intro y h 
    cases' h with a' _ h' 
    exact IH _ h'

theorem lex_acc_inr (aca : ∀ a, Acc (lex ra rb) (inl a)) {b} (acb : Acc rb b) : Acc (lex ra rb) (inr b) :=
  by 
    induction' acb with b H IH 
    constructor 
    intro y h 
    cases' h with _ _ _ b' _ h' a
    ·
      exact IH _ h'
    ·
      exact aca _

theorem lex_wf (ha : WellFounded ra) (hb : WellFounded rb) : WellFounded (lex ra rb) :=
  have aca : ∀ a, Acc (lex ra rb) (inl a) := fun a => lex_acc_inl (ha.apply a)
  ⟨fun x => Sum.recOn x aca fun b => lex_acc_inr aca (hb.apply b)⟩

end 

/-- Swap the factors of a sum type -/
@[simp]
def swap : Sum α β → Sum β α
| inl a => inr a
| inr b => inl b

@[simp]
theorem swap_swap (x : Sum α β) : swap (swap x) = x :=
  by 
    cases x <;> rfl

@[simp]
theorem swap_swap_eq : swap ∘ swap = @id (Sum α β) :=
  funext$ swap_swap

@[simp]
theorem swap_left_inverse : Function.LeftInverse (@swap α β) swap :=
  swap_swap

@[simp]
theorem swap_right_inverse : Function.RightInverse (@swap α β) swap :=
  swap_swap

end Sum

namespace Function

open Sum

theorem injective.sum_elim {γ} {f : α → γ} {g : β → γ} (hf : injective f) (hg : injective g) (hfg : ∀ a b, f a ≠ g b) :
  injective (Sum.elim f g)
| inl x, inl y, h => congr_argₓ inl$ hf h
| inl x, inr y, h => (hfg x y h).elim
| inr x, inl y, h => (hfg y x h.symm).elim
| inr x, inr y, h => congr_argₓ inr$ hg h

theorem injective.sum_map {f : α → β} {g : α' → β'} (hf : injective f) (hg : injective g) : injective (Sum.map f g)
| inl x, inl y, h => congr_argₓ inl$ hf$ inl.inj h
| inr x, inr y, h => congr_argₓ inr$ hg$ inr.inj h

theorem surjective.sum_map {f : α → β} {g : α' → β'} (hf : surjective f) (hg : surjective g) : surjective (Sum.map f g)
| inl y =>
  let ⟨x, hx⟩ := hf y
  ⟨inl x, congr_argₓ inl hx⟩
| inr y =>
  let ⟨x, hx⟩ := hg y
  ⟨inr x, congr_argₓ inr hx⟩

end Function

