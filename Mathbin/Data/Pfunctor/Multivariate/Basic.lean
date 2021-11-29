import Mathbin.Control.Functor.Multivariate 
import Mathbin.Data.Pfunctor.Univariate.Basic

/-!
# Multivariate polynomial functors.

Multivariate polynomial functors are used for defining M-types and W-types.
They map a type vector `α` to the type `Σ a : A, B a ⟹ α`, with `A : Type` and
`B : A → typevec n`. They interact well with Lean's inductive definitions because
they guarantee that occurrences of `α` are positive.
-/


universe u v

open_locale Mvfunctor

/--
multivariate polynomial functors
-/
structure Mvpfunctor(n : ℕ) where 
  A : Type u 
  B : A → Typevec.{u} n

namespace Mvpfunctor

open mvfunctor(Liftp Liftr)

variable{n m : ℕ}(P : Mvpfunctor.{u} n)

/-- Applying `P` to an object of `Type` -/
def obj (α : Typevec.{u} n) : Type u :=
  Σa : P.A, P.B a ⟹ α

/-- Applying `P` to a morphism of `Type` -/
def map {α β : Typevec n} (f : α ⟹ β) : P.obj α → P.obj β :=
  fun ⟨a, g⟩ => ⟨a, Typevec.comp f g⟩

instance  : Inhabited (Mvpfunctor n) :=
  ⟨⟨default _, fun _ => default _⟩⟩

instance obj.inhabited {α : Typevec n} [Inhabited P.A] [∀ i, Inhabited (α i)] : Inhabited (P.obj α) :=
  ⟨⟨default _, fun _ _ => default _⟩⟩

instance  : Mvfunctor P.obj :=
  ⟨@Mvpfunctor.map n P⟩

theorem map_eq {α β : Typevec n} (g : α ⟹ β) (a : P.A) (f : P.B a ⟹ α) :
  @Mvfunctor.map _ P.obj _ _ _ g ⟨a, f⟩ = ⟨a, g ⊚ f⟩ :=
  rfl

theorem id_map {α : Typevec n} : ∀ (x : P.obj α), Typevec.id <$$> x = x
| ⟨a, g⟩ => rfl

theorem comp_map {α β γ : Typevec n} (f : α ⟹ β) (g : β ⟹ γ) : ∀ (x : P.obj α), (g ⊚ f) <$$> x = g <$$> f <$$> x
| ⟨a, h⟩ => rfl

instance  : IsLawfulMvfunctor P.obj :=
  { id_map := @id_map _ P, comp_map := @comp_map _ P }

/-- Constant functor where the input object does not affect the output -/
def const (n : ℕ) (A : Type u) : Mvpfunctor n :=
  { A, B := fun a i => Pempty }

section Const

variable(n){A : Type u}{α β : Typevec.{u} n}

/-- Constructor for the constant functor -/
def const.mk (x : A) {α} : (const n A).Obj α :=
  ⟨x, fun i a => Pempty.elimₓ a⟩

variable{n A}

/-- Destructor for the constant functor -/
def const.get (x : (const n A).Obj α) : A :=
  x.1

@[simp]
theorem const.get_map (f : α ⟹ β) (x : (const n A).Obj α) : const.get (f <$$> x) = const.get x :=
  by 
    cases x 
    rfl

@[simp]
theorem const.get_mk (x : A) : const.get (const.mk n x : (const n A).Obj α) = x :=
  by 
    rfl

@[simp]
theorem const.mk_get (x : (const n A).Obj α) : const.mk n (const.get x) = x :=
  by 
    cases x 
    dsimp [const.get, const.mk]
    congr with _⟨⟩

end Const

/-- Functor composition on polynomial functors -/
def comp (P : Mvpfunctor.{u} n) (Q : Fin2 n → Mvpfunctor.{u} m) : Mvpfunctor m :=
  { A := Σa₂ : P.1, ∀ i, P.2 a₂ i → (Q i).1, B := fun a => fun i => Σ(j : _)(b : P.2 a.1 j), (Q j).2 (a.snd j b) i }

variable{P}{Q : Fin2 n → Mvpfunctor.{u} m}{α β : Typevec.{u} m}

/-- Constructor for functor composition -/
def comp.mk (x : P.obj fun i => (Q i).Obj α) : (comp P Q).Obj α :=
  ⟨⟨x.1, fun i a => (x.2 _ a).1⟩, fun i a => (x.snd a.fst a.snd.fst).snd i a.snd.snd⟩

-- error in Data.Pfunctor.Multivariate.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Destructor for functor composition -/ def comp.get (x : (comp P Q).obj α) : P.obj (λ i, (Q i).obj α) :=
⟨x.1.1, λ i a, ⟨x.fst.snd i a, λ (j : fin2 m) (b : (Q i).B _ j), x.snd j ⟨i, ⟨a, b⟩⟩⟩⟩

-- error in Data.Pfunctor.Multivariate.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem comp.get_map
(f : «expr ⟹ »(α, β))
(x : (comp P Q).obj α) : «expr = »(comp.get «expr <$$> »(f, x), «expr <$$> »(λ
  (i)
  (x : (Q i).obj α), «expr <$$> »(f, x), comp.get x)) :=
by { cases [expr x] [],
  refl }

@[simp]
theorem comp.get_mk (x : P.obj fun i => (Q i).Obj α) : comp.get (comp.mk x) = x :=
  by 
    cases x 
    simp [comp.get, comp.mk]

@[simp]
theorem comp.mk_get (x : (comp P Q).Obj α) : comp.mk (comp.get x) = x :=
  by 
    cases x 
    dsimp [comp.get, comp.mk]
    ext : 2 <;> intros 
    rfl 
    rfl 
    congr 
    ext1 <;> intros  <;> rfl 
    ext : 2
    congr 
    rcases x_1 with ⟨a, b, c⟩ <;> rfl

theorem liftp_iff {α : Typevec n} (p : ∀ ⦃i⦄, α i → Prop) (x : P.obj α) :
  liftp p x ↔ ∃ a f, x = ⟨a, f⟩ ∧ ∀ i j, p (f i j) :=
  by 
    split 
    ·
      rintro ⟨y, hy⟩
      cases' h : y with a f 
      refine' ⟨a, fun i j => (f i j).val, _, fun i j => (f i j).property⟩
      rw [←hy, h, map_eq]
      rfl 
    rintro ⟨a, f, xeq, pf⟩
    use ⟨a, fun i j => ⟨f i j, pf i j⟩⟩
    rw [xeq]
    rfl

theorem liftp_iff' {α : Typevec n} (p : ∀ ⦃i⦄, α i → Prop) (a : P.A) (f : P.B a ⟹ α) :
  @liftp.{u} _ P.obj _ α p ⟨a, f⟩ ↔ ∀ i x, p (f i x) :=
  by 
    simp only [liftp_iff, Sigma.mk.inj_iff] <;> split  <;> intro 
    ·
      casesM* Exists _, _ ∧ _ 
      substVars 
      assumption 
    repeat' 
      first |
        constructor|
        assumption

theorem liftr_iff {α : Typevec n} (r : ∀ ⦃i⦄, α i → α i → Prop) (x y : P.obj α) :
  liftr r x y ↔ ∃ a f₀ f₁, x = ⟨a, f₀⟩ ∧ y = ⟨a, f₁⟩ ∧ ∀ i j, r (f₀ i j) (f₁ i j) :=
  by 
    split 
    ·
      rintro ⟨u, xeq, yeq⟩
      cases' h : u with a f 
      use a, fun i j => (f i j).val.fst, fun i j => (f i j).val.snd 
      split 
      ·
        rw [←xeq, h]
        rfl 
      split 
      ·
        rw [←yeq, h]
        rfl 
      intro i j 
      exact (f i j).property 
    rintro ⟨a, f₀, f₁, xeq, yeq, h⟩
    use ⟨a, fun i j => ⟨(f₀ i j, f₁ i j), h i j⟩⟩
    dsimp 
    split 
    ·
      rw [xeq]
      rfl 
    rw [yeq]
    rfl

open Set Mvfunctor

theorem supp_eq {α : Typevec n} (a : P.A) (f : P.B a ⟹ α) i :
  @supp.{u} _ P.obj _ α (⟨a, f⟩ : P.obj α) i = f i '' univ :=
  by 
    ext 
    simp only [supp, image_univ, mem_range, mem_set_of_eq]
    split  <;> intro h
    ·
      apply @h fun i x => ∃ y : P.B a i, f i y = x 
      rw [liftp_iff']
      intros 
      refine' ⟨_, rfl⟩
    ·
      simp only [liftp_iff']
      cases h 
      subst x 
      tauto

end Mvpfunctor

namespace Mvpfunctor

open Typevec

variable{n : ℕ}(P : Mvpfunctor.{u} (n+1))

/-- Split polynomial functor, get a n-ary functor
from a `n+1`-ary functor -/
def drop : Mvpfunctor n :=
  { A := P.A, B := fun a => (P.B a).drop }

/-- Split polynomial functor, get a univariate functor
from a `n+1`-ary functor -/
def last : Pfunctor :=
  { A := P.A, B := fun a => (P.B a).last }

/-- append arrows of a polynomial functor application -/
@[reducible]
def append_contents {α : Typevec n} {β : Type _} {a : P.A} (f' : P.drop.B a ⟹ α) (f : P.last.B a → β) :
  P.B a ⟹ (α ::: β) :=
  split_fun f' f

end Mvpfunctor

