import Mathbin.Data.Pfunctor.Multivariate.Basic

/-!
# The W construction as a multivariate polynomial functor.

W types are well-founded tree-like structures. They are defined
as the least fixpoint of a polynomial functor.

## Main definitions

 * `W_mk`     - constructor
 * `W_dest    - destructor
 * `W_rec`    - recursor: basis for defining functions by structural recursion on `P.W α`
 * `W_rec_eq` - defining equation for `W_rec`
 * `W_ind`    - induction principle for `P.W α`

## Implementation notes

Three views of M-types:

 * `Wp`: polynomial functor
 * `W`: data type inductively defined by a triple:
     shape of the root, data in the root and children of the root
 * `W`: least fixed point of a polynomial functor

Specifically, we define the polynomial functor `Wp` as:

 * A := a tree-like structure without information in the nodes
 * B := given the tree-like structure `t`, `B t` is a valid path
   (specified inductively by `W_path`) from the root of `t` to any given node.

As a result `Wp.obj α` is made of a dataless tree and a function from
its valid paths to values of `α`

## Reference

 * [Jeremy Avigad, Mario M. Carneiro and Simon Hudon, *Data Types as Quotients of Polynomial Functors*][avigad-carneiro-hudon2019]
-/


universe u v

namespace Mvpfunctor

open Typevec

open_locale Mvfunctor

variable{n : ℕ}(P : Mvpfunctor.{u} (n+1))

/-- A path from the root of a tree to one of its node -/
inductive W_path : P.last.W → Fin2 n → Type u
  | root (a : P.A) (f : P.last.B a → P.last.W) (i : Fin2 n) (c : P.drop.B a i) : W_path ⟨a, f⟩ i
  | child (a : P.A) (f : P.last.B a → P.last.W) (i : Fin2 n) (j : P.last.B a) (c : W_path (f j) i) : W_path ⟨a, f⟩ i

instance W_path.inhabited (x : P.last.W) {i} [I : Inhabited (P.drop.B x.head i)] : Inhabited (W_path P x i) :=
  ⟨match x, I with 
    | ⟨a, f⟩, I => W_path.root a f i (@default _ I)⟩

/-- Specialized destructor on `W_path` -/
def W_path_cases_on {α : Typevec n} {a : P.A} {f : P.last.B a → P.last.W} (g' : P.drop.B a ⟹ α)
  (g : ∀ (j : P.last.B a), P.W_path (f j) ⟹ α) : P.W_path ⟨a, f⟩ ⟹ α :=
  by 
    intro i x 
    cases x 
    case W_path.root _ _ i c => 
      exact g' i c 
    case W_path.child _ _ i j c => 
      exact g j i c

/-- Specialized destructor on `W_path` -/
def W_path_dest_left {α : Typevec n} {a : P.A} {f : P.last.B a → P.last.W} (h : P.W_path ⟨a, f⟩ ⟹ α) : P.drop.B a ⟹ α :=
  fun i c => h i (W_path.root a f i c)

/-- Specialized destructor on `W_path` -/
def W_path_dest_right {α : Typevec n} {a : P.A} {f : P.last.B a → P.last.W} (h : P.W_path ⟨a, f⟩ ⟹ α) :
  ∀ (j : P.last.B a), P.W_path (f j) ⟹ α :=
  fun j i c => h i (W_path.child a f i j c)

theorem W_path_dest_left_W_path_cases_on {α : Typevec n} {a : P.A} {f : P.last.B a → P.last.W} (g' : P.drop.B a ⟹ α)
  (g : ∀ (j : P.last.B a), P.W_path (f j) ⟹ α) : P.W_path_dest_left (P.W_path_cases_on g' g) = g' :=
  rfl

theorem W_path_dest_right_W_path_cases_on {α : Typevec n} {a : P.A} {f : P.last.B a → P.last.W} (g' : P.drop.B a ⟹ α)
  (g : ∀ (j : P.last.B a), P.W_path (f j) ⟹ α) : P.W_path_dest_right (P.W_path_cases_on g' g) = g :=
  rfl

theorem W_path_cases_on_eta {α : Typevec n} {a : P.A} {f : P.last.B a → P.last.W} (h : P.W_path ⟨a, f⟩ ⟹ α) :
  P.W_path_cases_on (P.W_path_dest_left h) (P.W_path_dest_right h) = h :=
  by 
    ext i x <;> cases x <;> rfl

theorem comp_W_path_cases_on {α β : Typevec n} (h : α ⟹ β) {a : P.A} {f : P.last.B a → P.last.W} (g' : P.drop.B a ⟹ α)
  (g : ∀ (j : P.last.B a), P.W_path (f j) ⟹ α) :
  h ⊚ P.W_path_cases_on g' g = P.W_path_cases_on (h ⊚ g') fun i => h ⊚ g i :=
  by 
    ext i x <;> cases x <;> rfl

/-- Polynomial functor for the W-type of `P`. `A` is a data-less well-founded
tree whereas, for a given `a : A`, `B a` is a valid path in tree `a` so
that `Wp.obj α` is made of a tree and a function from its valid paths to
the values it contains  -/
def Wp : Mvpfunctor n :=
  { A := P.last.W, B := P.W_path }

/-- W-type of `P` -/
@[nolint has_inhabited_instance]
def W (α : Typevec n) : Type _ :=
  P.Wp.obj α

instance mvfunctor_W : Mvfunctor P.W :=
  by 
    delta' Mvpfunctor.W <;> infer_instance

/-!
First, describe operations on `W` as a polynomial functor.
-/


/-- Constructor for `Wp` -/
def Wp_mk {α : Typevec n} (a : P.A) (f : P.last.B a → P.last.W) (f' : P.W_path ⟨a, f⟩ ⟹ α) : P.W α :=
  ⟨⟨a, f⟩, f'⟩

/-- Recursor for `Wp` -/
def Wp_rec {α : Typevec n} {C : Type _}
  (g : ∀ (a : P.A) (f : P.last.B a → P.last.W), P.W_path ⟨a, f⟩ ⟹ α → (P.last.B a → C) → C) :
  ∀ (x : P.last.W) (f' : P.W_path x ⟹ α), C
| ⟨a, f⟩, f' => g a f f' fun i => Wp_rec (f i) (P.W_path_dest_right f' i)

theorem Wp_rec_eq {α : Typevec n} {C : Type _}
  (g : ∀ (a : P.A) (f : P.last.B a → P.last.W), P.W_path ⟨a, f⟩ ⟹ α → (P.last.B a → C) → C) (a : P.A)
  (f : P.last.B a → P.last.W) (f' : P.W_path ⟨a, f⟩ ⟹ α) :
  P.Wp_rec g ⟨a, f⟩ f' = g a f f' fun i => P.Wp_rec g (f i) (P.W_path_dest_right f' i) :=
  rfl

theorem Wp_ind {α : Typevec n} {C : ∀ (x : P.last.W), P.W_path x ⟹ α → Prop}
  (ih :
    ∀ (a : P.A) (f : P.last.B a → P.last.W) (f' : P.W_path ⟨a, f⟩ ⟹ α),
      (∀ (i : P.last.B a), C (f i) (P.W_path_dest_right f' i)) → C ⟨a, f⟩ f') :
  ∀ (x : P.last.W) (f' : P.W_path x ⟹ α), C x f'
| ⟨a, f⟩, f' => ih a f f' fun i => Wp_ind _ _

/-!
Now think of W as defined inductively by the data ⟨a, f', f⟩ where
- `a  : P.A` is the shape of the top node
- `f' : P.drop.B a ⟹ α` is the contents of the top node
- `f  : P.last.B a → P.last.W` are the subtrees
 -/


/-- Constructor for `W` -/
def W_mk {α : Typevec n} (a : P.A) (f' : P.drop.B a ⟹ α) (f : P.last.B a → P.W α) : P.W α :=
  let g : P.last.B a → P.last.W := fun i => (f i).fst 
  let g' : P.W_path ⟨a, g⟩ ⟹ α := P.W_path_cases_on f' fun i => (f i).snd
  ⟨⟨a, g⟩, g'⟩

/-- Recursor for `W` -/
def W_rec {α : Typevec n} {C : Type _} (g : ∀ (a : P.A), P.drop.B a ⟹ α → (P.last.B a → P.W α) → (P.last.B a → C) → C) :
  P.W α → C
| ⟨a, f'⟩ =>
  let g' (a : P.A) (f : P.last.B a → P.last.W) (h : P.W_path ⟨a, f⟩ ⟹ α) (h' : P.last.B a → C) : C :=
    g a (P.W_path_dest_left h) (fun i => ⟨f i, P.W_path_dest_right h i⟩) h' 
  P.Wp_rec g' a f'

/-- Defining equation for the recursor of `W` -/
theorem W_rec_eq {α : Typevec n} {C : Type _}
  (g : ∀ (a : P.A), P.drop.B a ⟹ α → (P.last.B a → P.W α) → (P.last.B a → C) → C) (a : P.A) (f' : P.drop.B a ⟹ α)
  (f : P.last.B a → P.W α) : P.W_rec g (P.W_mk a f' f) = g a f' f fun i => P.W_rec g (f i) :=
  by 
    rw [W_mk, W_rec]
    dsimp 
    rw [Wp_rec_eq]
    dsimp only [W_path_dest_left_W_path_cases_on, W_path_dest_right_W_path_cases_on]
    congr <;> ext1 i <;> cases f i <;> rfl

/-- Induction principle for `W` -/
theorem W_ind {α : Typevec n} {C : P.W α → Prop}
  (ih : ∀ (a : P.A) (f' : P.drop.B a ⟹ α) (f : P.last.B a → P.W α), (∀ i, C (f i)) → C (P.W_mk a f' f)) : ∀ x, C x :=
  by 
    intro x 
    cases' x with a f 
    apply @Wp_ind n P α fun a f => C ⟨a, f⟩
    dsimp 
    intro a f f' ih' 
    dsimp [W_mk]  at ih 
    let ih'' := ih a (P.W_path_dest_left f') fun i => ⟨f i, P.W_path_dest_right f' i⟩
    dsimp  at ih'' 
    rw [W_path_cases_on_eta] at ih'' 
    apply ih'' 
    apply ih'

theorem W_cases {α : Typevec n} {C : P.W α → Prop}
  (ih : ∀ (a : P.A) (f' : P.drop.B a ⟹ α) (f : P.last.B a → P.W α), C (P.W_mk a f' f)) : ∀ x, C x :=
  P.W_ind fun a f' f ih' => ih a f' f

/-- W-types are functorial -/
def W_map {α β : Typevec n} (g : α ⟹ β) : P.W α → P.W β :=
  fun x => g <$$> x

theorem W_mk_eq {α : Typevec n} (a : P.A) (f : P.last.B a → P.last.W) (g' : P.drop.B a ⟹ α)
  (g : ∀ (j : P.last.B a), P.W_path (f j) ⟹ α) : (P.W_mk a g' fun i => ⟨f i, g i⟩) = ⟨⟨a, f⟩, P.W_path_cases_on g' g⟩ :=
  rfl

-- error in Data.Pfunctor.Multivariate.W: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem W_map_W_mk
{α β : typevec n}
(g : «expr ⟹ »(α, β))
(a : P.A)
(f' : «expr ⟹ »(P.drop.B a, α))
(f : P.last.B a → P.W α) : «expr = »(«expr <$$> »(g, P.W_mk a f' f), P.W_mk a «expr ⊚ »(g, f') (λ
  i, «expr <$$> »(g, f i))) :=
begin
  show [expr «expr = »(_, P.W_mk a «expr ⊚ »(g, f') «expr ∘ »(mvfunctor.map g, f))],
  have [] [":", expr «expr = »(«expr ∘ »(mvfunctor.map g, f), λ i, ⟨(f i).fst, «expr ⊚ »(g, (f i).snd)⟩)] [],
  { ext [] [ident i] [":", 1],
    dsimp [] ["[", expr function.comp, "]"] [] [],
    cases [expr f i] [],
    refl },
  rw [expr this] [],
  have [] [":", expr «expr = »(f, λ i, ⟨(f i).fst, (f i).snd⟩)] [],
  { ext1 [] [],
    cases [expr f x] [],
    refl },
  rw [expr this] [],
  dsimp [] [] [] [],
  rw ["[", expr W_mk_eq, ",", expr W_mk_eq, "]"] [],
  have [ident h] [] [":=", expr mvpfunctor.map_eq P.Wp g],
  rw ["[", expr h, ",", expr comp_W_path_cases_on, "]"] []
end

/-- Constructor of a value of `P.obj (α ::: β)` from components.
Useful to avoid complicated type annotation -/
@[reducible]
def obj_append1 {α : Typevec n} {β : Type _} (a : P.A) (f' : P.drop.B a ⟹ α) (f : P.last.B a → β) : P.obj (α ::: β) :=
  ⟨a, split_fun f' f⟩

theorem map_obj_append1 {α γ : Typevec n} (g : α ⟹ γ) (a : P.A) (f' : P.drop.B a ⟹ α) (f : P.last.B a → P.W α) :
  append_fun g (P.W_map g) <$$> P.obj_append1 a f' f = P.obj_append1 a (g ⊚ f') fun x => P.W_map g (f x) :=
  by 
    rw [obj_append1, obj_append1, map_eq, append_fun, ←split_fun_comp] <;> rfl

/-!
Yet another view of the W type: as a fixed point for a multivariate polynomial functor.
These are needed to use the W-construction to construct a fixed point of a qpf, since
the qpf axioms are expressed in terms of `map` on `P`.
-/


/-- Constructor for the W-type of `P` -/
def W_mk' {α : Typevec n} : P.obj (α ::: P.W α) → P.W α
| ⟨a, f⟩ => P.W_mk a (drop_fun f) (last_fun f)

/-- Destructor for the W-type of `P` -/
def W_dest' {α : Typevec.{u} n} : P.W α → P.obj (α.append1 (P.W α)) :=
  P.W_rec fun a f' f _ => ⟨a, split_fun f' f⟩

theorem W_dest'_W_mk {α : Typevec n} (a : P.A) (f' : P.drop.B a ⟹ α) (f : P.last.B a → P.W α) :
  P.W_dest' (P.W_mk a f' f) = ⟨a, split_fun f' f⟩ :=
  by 
    rw [W_dest', W_rec_eq]

theorem W_dest'_W_mk' {α : Typevec n} (x : P.obj (α.append1 (P.W α))) : P.W_dest' (P.W_mk' x) = x :=
  by 
    cases' x with a f <;> rw [W_mk', W_dest'_W_mk, split_drop_fun_last_fun]

end Mvpfunctor

