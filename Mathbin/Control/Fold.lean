import Mathbin.Algebra.FreeMonoid 
import Mathbin.Algebra.Opposites 
import Mathbin.Control.Traversable.Instances 
import Mathbin.Control.Traversable.Lemmas 
import Mathbin.CategoryTheory.Endomorphism 
import Mathbin.CategoryTheory.Types 
import Mathbin.CategoryTheory.Category.Kleisli 
import Mathbin.Deprecated.Group

/-!

# List folds generalized to `traversable`

Informally, we can think of `foldl` as a special case of `traverse` where we do not care about the
reconstructed data structure and, in a state monad, we care about the final state.

The obvious way to define `foldl` would be to use the state monad but it
is nicer to reason about a more abstract interface with `fold_map` as a
primitive and `fold_map_hom` as a defining property.

```
def fold_map {α ω} [has_one ω] [has_mul ω] (f : α → ω) : t α → ω := ...

lemma fold_map_hom (α β)
  [monoid α] [monoid β] (f : α → β) [is_monoid_hom f]
  (g : γ → α) (x : t γ) :
  f (fold_map g x) = fold_map (f ∘ g) x :=
...
```

`fold_map` uses a monoid ω to accumulate a value for every element of
a data structure and `fold_map_hom` uses a monoid homomorphism to
substitute the monoid used by `fold_map`. The two are sufficient to
define `foldl`, `foldr` and `to_list`. `to_list` permits the
formulation of specifications in terms of operations on lists.

Each fold function can be defined using a specialized
monoid. `to_list` uses a free monoid represented as a list with
concatenation while `foldl` uses endofunctions together with function
composition.

The definition through monoids uses `traverse` together with the
applicative functor `const m` (where `m` is the monoid). As an
implementation, `const` guarantees that no resource is spent on
reconstructing the structure during traversal.

A special class could be defined for `foldable`, similarly to Haskell,
but the author cannot think of instances of `foldable` that are not also
`traversable`.
-/


universe u v

open Ulift CategoryTheory MulOpposite

namespace Monoidₓ

variable{m : Type u → Type u}[Monadₓ m]

variable{α β : Type u}

/--
For a list, foldl f x [y₀,y₁] reduces as follows:

```
calc  foldl f x [y₀,y₁]
    = foldl f (f x y₀) [y₁]      : rfl
... = foldl f (f (f x y₀) y₁) [] : rfl
... = f (f x y₀) y₁              : rfl
```
with
```
f : α → β → α
x : α
[y₀,y₁] : list β
```

We can view the above as a composition of functions:
```
... = f (f x y₀) y₁              : rfl
... = flip f y₁ (flip f y₀ x)    : rfl
... = (flip f y₁ ∘ flip f y₀) x  : rfl
```

We can use traverse and const to construct this composition:
```
calc   const.run (traverse (λ y, const.mk' (flip f y)) [y₀,y₁]) x
     = const.run ((::) <$> const.mk' (flip f y₀) <*> traverse (λ y, const.mk' (flip f y)) [y₁]) x
...  = const.run ((::) <$> const.mk' (flip f y₀) <*>
         ( (::) <$> const.mk' (flip f y₁) <*> traverse (λ y, const.mk' (flip f y)) [] )) x
...  = const.run ((::) <$> const.mk' (flip f y₀) <*>
         ( (::) <$> const.mk' (flip f y₁) <*> pure [] )) x
...  = const.run ( ((::) <$> const.mk' (flip f y₁) <*> pure []) ∘
         ((::) <$> const.mk' (flip f y₀)) ) x
...  = const.run ( const.mk' (flip f y₁) ∘ const.mk' (flip f y₀) ) x
...  = const.run ( flip f y₁ ∘ flip f y₀ ) x
...  = f (f x y₀) y₁
```

And this is how `const` turns a monoid into an applicative functor and
how the monoid of endofunctions define `foldl`.
-/
@[reducible]
def foldl (α : Type u) : Type u :=
  «expr ᵐᵒᵖ» (End α)

def foldl.mk (f : α → α) : foldl α :=
  op f

def foldl.get (x : foldl α) : α → α :=
  unop x

def foldl.of_free_monoid (f : β → α → β) (xs : FreeMonoid α) : Monoidₓ.Foldl β :=
  op$ flip (List.foldlₓ f) xs

@[reducible]
def foldr (α : Type u) : Type u :=
  End α

def foldr.mk (f : α → α) : foldr α :=
  f

def foldr.get (x : foldr α) : α → α :=
  x

def foldr.of_free_monoid (f : α → β → β) (xs : FreeMonoid α) : Monoidₓ.Foldr β :=
  flip (List.foldr f) xs

@[reducible]
def mfoldl (m : Type u → Type u) [Monadₓ m] (α : Type u) : Type u :=
  MulOpposite$ End$ Kleisli.mk m α

def mfoldl.mk (f : α → m α) : mfoldl m α :=
  op f

def mfoldl.get (x : mfoldl m α) : α → m α :=
  unop x

def mfoldl.of_free_monoid (f : β → α → m β) (xs : FreeMonoid α) : Monoidₓ.Mfoldl m β :=
  op$ flip (List.mfoldl f) xs

@[reducible]
def mfoldr (m : Type u → Type u) [Monadₓ m] (α : Type u) : Type u :=
  End$ Kleisli.mk m α

def mfoldr.mk (f : α → m α) : mfoldr m α :=
  f

def mfoldr.get (x : mfoldr m α) : α → m α :=
  x

def mfoldr.of_free_monoid (f : α → β → m β) (xs : FreeMonoid α) : Monoidₓ.Mfoldr m β :=
  flip (List.mfoldr f) xs

end Monoidₓ

namespace Traversable

open Monoidₓ Functor

section Defs

variable{α β : Type u}{t : Type u → Type u}[Traversable t]

def fold_map {α ω} [HasOne ω] [Mul ω] (f : α → ω) : t α → ω :=
  traverse (const.mk' ∘ f)

def foldl (f : α → β → α) (x : α) (xs : t β) : α :=
  (fold_map (foldl.mk ∘ flip f) xs).get x

def foldr (f : α → β → β) (x : β) (xs : t α) : β :=
  (fold_map (foldr.mk ∘ f) xs).get x

/--
Conceptually, `to_list` collects all the elements of a collection
in a list. This idea is formalized by

  `lemma to_list_spec (x : t α) : to_list x = fold_map free_monoid.mk x`.

The definition of `to_list` is based on `foldl` and `list.cons` for
speed. It is faster than using `fold_map free_monoid.mk` because, by
using `foldl` and `list.cons`, each insertion is done in constant
time. As a consequence, `to_list` performs in linear.

On the other hand, `fold_map free_monoid.mk` creates a singleton list
around each element and concatenates all the resulting lists. In
`xs ++ ys`, concatenation takes a time proportional to `length xs`. Since
the order in which concatenation is evaluated is unspecified, nothing
prevents each element of the traversable to be appended at the end
`xs ++ [x]` which would yield a `O(n²)` run time. -/
def to_list : t α → List α :=
  List.reverse ∘ foldl (flip List.cons) []

def length (xs : t α) : ℕ :=
  down$ foldl (fun l _ => up$ l.down+1) (up 0) xs

variable{m : Type u → Type u}[Monadₓ m]

def mfoldl (f : α → β → m α) (x : α) (xs : t β) : m α :=
  (fold_map (mfoldl.mk ∘ flip f) xs).get x

def mfoldr (f : α → β → m β) (x : β) (xs : t α) : m β :=
  (fold_map (mfoldr.mk ∘ f) xs).get x

end Defs

section ApplicativeTransformation

variable{α β γ : Type u}

open Function hiding const

open IsMonoidHom

def map_fold [Monoidₓ α] [Monoidₓ β] {f : α → β} (hf : IsMonoidHom f) : ApplicativeTransformation (const α) (const β) :=
  { app := fun x => f,
    preserves_seq' :=
      by 
        intros 
        simp only [map_mul hf, ·<*>·],
    preserves_pure' :=
      by 
        intros 
        simp only [map_one hf, pure] }

def free.mk : α → FreeMonoid α :=
  List.ret

def free.map (f : α → β) : FreeMonoid α → FreeMonoid β :=
  List.map f

theorem free.map_eq_map (f : α → β) (xs : List α) : f <$> xs = free.map f xs :=
  rfl

theorem free.map.is_monoid_hom (f : α → β) : IsMonoidHom (free.map f) :=
  { map_mul :=
      fun x y =>
        by 
          simp only [free.map, FreeMonoid.mul_def, List.map_append, FreeAddMonoid.add_def],
    map_one :=
      by 
        simp only [free.map, FreeMonoid.one_def, List.map, FreeAddMonoid.zero_def] }

theorem fold_foldl (f : β → α → β) : IsMonoidHom (foldl.of_free_monoid f) :=
  { map_one := rfl,
    map_mul :=
      by 
        intros  <;>
          simp only [FreeMonoid.mul_def, foldl.of_free_monoid, flip, unop_op, List.foldl_append, op_inj] <;> rfl }

theorem foldl.unop_of_free_monoid (f : β → α → β) (xs : FreeMonoid α) (a : β) :
  unop (foldl.of_free_monoid f xs) a = List.foldlₓ f a xs :=
  rfl

theorem fold_foldr (f : α → β → β) : IsMonoidHom (foldr.of_free_monoid f) :=
  { map_one := rfl,
    map_mul :=
      by 
        intros 
        simp only [FreeMonoid.mul_def, foldr.of_free_monoid, List.foldr_append, flip]
        rfl }

variable(m : Type u → Type u)[Monadₓ m][IsLawfulMonad m]

@[simp]
theorem mfoldl.unop_of_free_monoid (f : β → α → m β) (xs : FreeMonoid α) (a : β) :
  unop (mfoldl.of_free_monoid f xs) a = List.mfoldl f a xs :=
  rfl

theorem fold_mfoldl (f : β → α → m β) : IsMonoidHom (mfoldl.of_free_monoid f) :=
  { map_one := rfl,
    map_mul :=
      by 
        intros  <;> apply unop_injective <;> ext <;> apply List.mfoldl_append }

theorem fold_mfoldr (f : α → β → m β) : IsMonoidHom (mfoldr.of_free_monoid f) :=
  { map_one := rfl,
    map_mul :=
      by 
        intros  <;> ext <;> apply List.mfoldr_append }

variable{t : Type u → Type u}[Traversable t][IsLawfulTraversable t]

open IsLawfulTraversable

theorem fold_map_hom [Monoidₓ α] [Monoidₓ β] {f : α → β} (hf : IsMonoidHom f) (g : γ → α) (x : t γ) :
  f (fold_map g x) = fold_map (f ∘ g) x :=
  calc f (fold_map g x) = f (traverse (const.mk' ∘ g) x) := rfl 
    _ = (map_fold hf).app _ (traverse (const.mk' ∘ g) x) := rfl 
    _ = traverse ((map_fold hf).app _ ∘ const.mk' ∘ g) x := naturality (map_fold hf) _ _ 
    _ = fold_map (f ∘ g) x := rfl
    

theorem fold_map_hom_free [Monoidₓ β] {f : FreeMonoid α → β} (hf : IsMonoidHom f) (x : t α) :
  f (fold_map free.mk x) = fold_map (f ∘ free.mk) x :=
  fold_map_hom hf _ x

variable{m}

theorem fold_mfoldl_cons (f : α → β → m α) (x : β) (y : α) : List.mfoldl f y (free.mk x) = f y x :=
  by 
    simp only [free.mk, List.ret, List.mfoldl, bind_pureₓ]

theorem fold_mfoldr_cons (f : β → α → m α) (x : β) (y : α) : List.mfoldr f y (free.mk x) = f x y :=
  by 
    simp only [free.mk, List.ret, List.mfoldr, pure_bind]

end ApplicativeTransformation

section Equalities

open IsLawfulTraversable

open list(cons)

variable{α β γ : Type u}

variable{t : Type u → Type u}[Traversable t][IsLawfulTraversable t]

@[simp]
theorem foldl.of_free_monoid_comp_free_mk (f : α → β → α) : foldl.of_free_monoid f ∘ free.mk = foldl.mk ∘ flip f :=
  rfl

@[simp]
theorem foldr.of_free_monoid_comp_free_mk (f : β → α → α) : foldr.of_free_monoid f ∘ free.mk = foldr.mk ∘ f :=
  rfl

@[simp]
theorem mfoldl.of_free_monoid_comp_free_mk {m} [Monadₓ m] [IsLawfulMonad m] (f : α → β → m α) :
  mfoldl.of_free_monoid f ∘ free.mk = mfoldl.mk ∘ flip f :=
  by 
    ext <;> simp only [· ∘ ·, mfoldl.of_free_monoid, mfoldl.mk, flip, fold_mfoldl_cons] <;> rfl

@[simp]
theorem mfoldr.of_free_monoid_comp_free_mk {m} [Monadₓ m] [IsLawfulMonad m] (f : β → α → m α) :
  mfoldr.of_free_monoid f ∘ free.mk = mfoldr.mk ∘ f :=
  by 
    ext 
    simp only [· ∘ ·, mfoldr.of_free_monoid, mfoldr.mk, flip, fold_mfoldr_cons]

-- error in Control.Fold: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem to_list_spec (xs : t α) : «expr = »(to_list xs, (fold_map free.mk xs : free_monoid _)) :=
«expr $ »(eq.symm, calc
   «expr = »(fold_map free.mk xs, (fold_map free.mk xs).reverse.reverse) : by simp [] [] ["only"] ["[", expr list.reverse_reverse, "]"] [] []
   «expr = »(..., (list.foldr cons «expr[ , ]»([]) (fold_map free.mk xs).reverse).reverse) : by simp [] [] ["only"] ["[", expr list.foldr_eta, "]"] [] []
   «expr = »(..., (unop (foldl.of_free_monoid (flip cons) (fold_map free.mk xs)) «expr[ , ]»([])).reverse) : by simp [] [] ["only"] ["[", expr flip, ",", expr list.foldr_reverse, ",", expr foldl.of_free_monoid, ",", expr unop_op, "]"] [] []
   «expr = »(..., to_list xs) : begin
     have [] [":", expr is_monoid_hom (foldl.of_free_monoid «expr $ »(flip, @cons α))] [],
     { apply [expr fold_foldl] },
     rw [expr fold_map_hom_free this] [],
     simp [] [] ["only"] ["[", expr to_list, ",", expr foldl, ",", expr list.reverse_inj, ",", expr foldl.get, ",", expr foldl.of_free_monoid_comp_free_mk, "]"] [] [],
     all_goals { apply_instance }
   end)

theorem fold_map_map [Monoidₓ γ] (f : α → β) (g : β → γ) (xs : t α) : fold_map g (f <$> xs) = fold_map (g ∘ f) xs :=
  by 
    simp only [fold_map, traverse_map]

theorem foldl_to_list (f : α → β → α) (xs : t β) (x : α) : foldl f x xs = List.foldlₓ f x (to_list xs) :=
  by 
    rw [←foldl.unop_of_free_monoid]
    simp only [foldl, to_list_spec, fold_map_hom_free (fold_foldl f), foldl.of_free_monoid_comp_free_mk, foldl.get]

theorem foldr_to_list (f : α → β → β) (xs : t α) (x : β) : foldr f x xs = List.foldr f x (to_list xs) :=
  by 
    change _ = foldr.of_free_monoid _ _ _ 
    simp only [foldr, to_list_spec, fold_map_hom_free (fold_foldr f), foldr.of_free_monoid_comp_free_mk, foldr.get]

theorem to_list_map (f : α → β) (xs : t α) : to_list (f <$> xs) = f <$> to_list xs :=
  by 
    simp only [to_list_spec, free.map_eq_map, fold_map_hom (free.map.is_monoid_hom f), fold_map_map] <;> rfl

@[simp]
theorem foldl_map (g : β → γ) (f : α → γ → α) (a : α) (l : t β) :
  foldl f a (g <$> l) = foldl (fun x y => f x (g y)) a l :=
  by 
    simp only [foldl, fold_map_map, · ∘ ·, flip]

@[simp]
theorem foldr_map (g : β → γ) (f : γ → α → α) (a : α) (l : t β) : foldr f a (g <$> l) = foldr (f ∘ g) a l :=
  by 
    simp only [foldr, fold_map_map, · ∘ ·, flip]

@[simp]
theorem to_list_eq_self {xs : List α} : to_list xs = xs :=
  by 
    simp only [to_list_spec, fold_map, traverse]
    induction xs 
    case list.nil => 
      rfl 
    case list.cons _ _ ih => 
      unfold List.traverseₓ List.ret 
      rw [ih]
      rfl

-- error in Control.Fold: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem length_to_list {xs : t α} : «expr = »(length xs, list.length (to_list xs)) :=
begin
  unfold [ident length] [],
  rw [expr foldl_to_list] [],
  generalize [] [":"] [expr «expr = »(to_list xs, ys)],
  let [ident f] [] [":=", expr λ (n : exprℕ()) (a : α), «expr + »(n, 1)],
  transitivity [expr list.foldl f 0 ys],
  { generalize [] [":"] [expr «expr = »(0, n)],
    induction [expr ys] [] ["with", "_", "_", ident ih] ["generalizing", ident n],
    { simp [] [] ["only"] ["[", expr list.foldl_nil, "]"] [] [] },
    { simp [] [] ["only"] ["[", expr list.foldl, ",", expr ih «expr + »(n, 1), "]"] [] [] } },
  { induction [expr ys] [] ["with", "_", ident tl, ident ih] [],
    { simp [] [] ["only"] ["[", expr list.length, ",", expr list.foldl_nil, "]"] [] [] },
    { simp [] [] ["only"] ["[", expr list.foldl, ",", expr list.length, "]"] [] [],
      rw ["[", "<-", expr ih, "]"] [],
      exact [expr tl.foldl_hom (λ x, «expr + »(x, 1)) f f 0 (λ n x, rfl)] } }
end

variable{m : Type u → Type u}[Monadₓ m][IsLawfulMonad m]

-- error in Control.Fold: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem mfoldl_to_list {f : α → β → m α} {x : α} {xs : t β} : «expr = »(mfoldl f x xs, list.mfoldl f x (to_list xs)) :=
calc
  «expr = »(mfoldl f x xs, unop (mfoldl.of_free_monoid f (to_list xs)) x) : by simp [] [] ["only"] ["[", expr mfoldl, ",", expr to_list_spec, ",", expr fold_map_hom_free (fold_mfoldl (λ
     β : Type u, m β) f), ",", expr mfoldl.of_free_monoid_comp_free_mk, ",", expr mfoldl.get, "]"] [] []
  «expr = »(..., list.mfoldl f x (to_list xs)) : by simp [] [] ["only"] ["[", expr mfoldl.of_free_monoid, ",", expr unop_op, ",", expr flip, "]"] [] []

-- error in Control.Fold: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem mfoldr_to_list (f : α → β → m β) (x : β) (xs : t α) : «expr = »(mfoldr f x xs, list.mfoldr f x (to_list xs)) :=
begin
  change [expr «expr = »(_, mfoldr.of_free_monoid f (to_list xs) x)] [] [],
  simp [] [] ["only"] ["[", expr mfoldr, ",", expr to_list_spec, ",", expr fold_map_hom_free (fold_mfoldr (λ
     β : Type u, m β) f), ",", expr mfoldr.of_free_monoid_comp_free_mk, ",", expr mfoldr.get, "]"] [] []
end

@[simp]
theorem mfoldl_map (g : β → γ) (f : α → γ → m α) (a : α) (l : t β) :
  mfoldl f a (g <$> l) = mfoldl (fun x y => f x (g y)) a l :=
  by 
    simp only [mfoldl, fold_map_map, · ∘ ·, flip]

@[simp]
theorem mfoldr_map (g : β → γ) (f : γ → α → m α) (a : α) (l : t β) : mfoldr f a (g <$> l) = mfoldr (f ∘ g) a l :=
  by 
    simp only [mfoldr, fold_map_map, · ∘ ·, flip]

end Equalities

end Traversable

