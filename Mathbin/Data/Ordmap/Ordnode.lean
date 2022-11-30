/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro
-/
import Mathbin.Order.Compare
import Mathbin.Data.List.Defs
import Mathbin.Data.Nat.Psub

/-!
# Ordered sets

This file defines a data structure for ordered sets, supporting a
variety of useful operations including insertion and deletion,
logarithmic time lookup, set operations, folds,
and conversion from lists.

The `ordnode α` operations all assume that `α` has the structure of
a total preorder, meaning a `≤` operation that is

* Transitive: `x ≤ y → y ≤ z → x ≤ z`
* Reflexive: `x ≤ x`
* Total: `x ≤ y ∨ y ≤ x`

For example, in order to use this data structure as a map type, one
can store pairs `(k, v)` where `(k, v) ≤ (k', v')` is defined to mean
`k ≤ k'` (assuming that the key values are linearly ordered).

Two values `x,y` are equivalent if `x ≤ y` and `y ≤ x`. An `ordnode α`
maintains the invariant that it never stores two equivalent nodes;
the insertion operation comes with two variants depending on whether
you want to keep the old value or the new value in case you insert a value
that is equivalent to one in the set.

The operations in this file are not verified, in the sense that they provide
"raw operations" that work for programming purposes but the invariants
are not explicitly in the structure. See `ordset` for a verified version
of this data structure.

## Main definitions

* `ordnode α`: A set of values of type `α`

## Implementation notes

Based on weight balanced trees:

 * Stephen Adams, "Efficient sets: a balancing act",
   Journal of Functional Programming 3(4):553-562, October 1993,
   <http://www.swiss.ai.mit.edu/~adams/BB/>.
 * J. Nievergelt and E.M. Reingold,
   "Binary search trees of bounded balance",
   SIAM journal of computing 2(1), March 1973.

Ported from Haskell's `Data.Set`.

## Tags

ordered map, ordered set, data structure

-/


universe u

/- ./././Mathport/Syntax/Translate/Command.lean:355:30: infer kinds are unsupported in Lean 4: nil {} -/
/-- An `ordnode α` is a finite set of values, represented as a tree.
  The operations on this type maintain that the tree is balanced
  and correctly stores subtree sizes at each level. -/
inductive Ordnode (α : Type u) : Type u
  | nil : Ordnode
  | node (size : ℕ) (l : Ordnode) (x : α) (r : Ordnode) : Ordnode
#align ordnode Ordnode

namespace Ordnode

variable {α : Type u}

instance : EmptyCollection (Ordnode α) :=
  ⟨nil⟩

instance : Inhabited (Ordnode α) :=
  ⟨nil⟩

/-- **Internal use only**

The maximal relative difference between the sizes of
two trees, it corresponds with the `w` in Adams' paper.

According to the Haskell comment, only `(delta, ratio)` settings
of `(3, 2)` and `(4, 2)` will work, and the proofs in
`ordset.lean` assume `delta := 3` and `ratio := 2`. -/
@[inline]
def delta :=
  3
#align ordnode.delta Ordnode.delta

/-- **Internal use only**

The ratio between an outer and inner sibling of the
heavier subtree in an unbalanced setting. It determines
whether a double or single rotation should be performed
to restore balance. It is corresponds with the inverse
of `α` in Adam's article. -/
@[inline]
def ratio :=
  2
#align ordnode.ratio Ordnode.ratio

/-- O(1). Construct a singleton set containing value `a`.

     singleton 3 = {3} -/
@[inline]
protected def singleton (a : α) : Ordnode α :=
  node 1 nil a nil
#align ordnode.singleton Ordnode.singleton

-- mathport name: «exprι »
local prefix:arg "ι" => Ordnode.singleton

instance : Singleton α (Ordnode α) :=
  ⟨Ordnode.singleton⟩

/-- O(1). Get the size of the set.

     size {2, 1, 1, 4} = 3  -/
@[inline, simp]
def size : Ordnode α → ℕ
  | nil => 0
  | node sz _ _ _ => sz
#align ordnode.size Ordnode.size

/-- O(1). Is the set empty?

     empty ∅ = tt
     empty {1, 2, 3} = ff -/
@[inline]
def empty : Ordnode α → Bool
  | nil => true
  | node _ _ _ _ => false
#align ordnode.empty Ordnode.empty

/-- **Internal use only**, because it violates the BST property on the original order.

O(n). The dual of a tree is a tree with its left and right sides reversed throughout.
The dual of a valid BST is valid under the dual order. This is convenient for exploiting
symmetries in the algorithms. -/
@[simp]
def dual : Ordnode α → Ordnode α
  | nil => nil
  | node s l x r => node s (dual r) x (dual l)
#align ordnode.dual Ordnode.dual

/-- **Internal use only**

O(1). Construct a node with the correct size information, without rebalancing. -/
@[inline, reducible]
def node' (l : Ordnode α) (x : α) (r : Ordnode α) : Ordnode α :=
  node (size l + size r + 1) l x r
#align ordnode.node' Ordnode.node'

/-- Basic pretty printing for `ordnode α` that shows the structure of the tree.

     repr {3, 1, 2, 4} = ((∅ 1 ∅) 2 ((∅ 3 ∅) 4 ∅)) -/
def repr {α} [Repr α] : Ordnode α → String
  | nil => "∅"
  | node _ l x r => "(" ++ repr l ++ " " ++ repr x ++ " " ++ repr r ++ ")"
#align ordnode.repr Ordnode.repr

instance {α} [Repr α] : Repr (Ordnode α) :=
  ⟨repr⟩

-- Note: The function has been written with tactics to avoid extra junk
/-- **Internal use only**

O(1). Rebalance a tree which was previously balanced but has had its left
side grow by 1, or its right side shrink by 1. -/
def balanceL (l : Ordnode α) (x : α) (r : Ordnode α) : Ordnode α := by
  clean by 
    cases' id r with rs
    · cases' id l with ls ll lx lr
      · exact ι x
      · cases' id ll with lls
        · cases' lr with _ _ lrx
          · exact node 2 l x nil
          · exact node 3 (ι lx) lrx ι x
        · cases' id lr with lrs lrl lrx lrr
          · exact node 3 ll lx ι x
          ·
            exact
              if lrs < ratio * lls then node (ls + 1) ll lx (node (lrs + 1) lr x nil)
              else
                node (ls + 1) (node (lls + size lrl + 1) ll lx lrl) lrx
                  (node (size lrr + 1) lrr x nil)
    · cases' id l with ls ll lx lr
      · exact node (rs + 1) nil x r
      · refine' if ls > delta * rs then _ else node (ls + rs + 1) l x r
        cases' id ll with lls
        · exact nil
        --should not happen
        cases' id lr with lrs lrl lrx lrr
        · exact nil
        --should not happen
        exact
          if lrs < ratio * lls then node (ls + rs + 1) ll lx (node (rs + lrs + 1) lr x r)
          else
            node (ls + rs + 1) (node (lls + size lrl + 1) ll lx lrl) lrx
              (node (size lrr + rs + 1) lrr x r)
#align ordnode.balance_l Ordnode.balanceL

/-- **Internal use only**

O(1). Rebalance a tree which was previously balanced but has had its right
side grow by 1, or its left side shrink by 1. -/
def balanceR (l : Ordnode α) (x : α) (r : Ordnode α) : Ordnode α := by
  clean by 
    cases' id l with ls
    · cases' id r with rs rl rx rr
      · exact ι x
      · cases' id rr with rrs
        · cases' rl with _ _ rlx
          · exact node 2 nil x r
          · exact node 3 (ι x) rlx ι rx
        · cases' id rl with rls rll rlx rlr
          · exact node 3 (ι x) rx rr
          ·
            exact
              if rls < ratio * rrs then node (rs + 1) (node (rls + 1) nil x rl) rx rr
              else
                node (rs + 1) (node (size rll + 1) nil x rll) rlx
                  (node (size rlr + rrs + 1) rlr rx rr)
    · cases' id r with rs rl rx rr
      · exact node (ls + 1) l x nil
      · refine' if rs > delta * ls then _ else node (ls + rs + 1) l x r
        cases' id rr with rrs
        · exact nil
        --should not happen
        cases' id rl with rls rll rlx rlr
        · exact nil
        --should not happen
        exact
          if rls < ratio * rrs then node (ls + rs + 1) (node (ls + rls + 1) l x rl) rx rr
          else
            node (ls + rs + 1) (node (ls + size rll + 1) l x rll) rlx
              (node (size rlr + rrs + 1) rlr rx rr)
#align ordnode.balance_r Ordnode.balanceR

/-- **Internal use only**

O(1). Rebalance a tree which was previously balanced but has had one side change
by at most 1. -/
def balance (l : Ordnode α) (x : α) (r : Ordnode α) : Ordnode α := by
  clean by 
    cases' id l with ls ll lx lr
    · cases' id r with rs rl rx rr
      · exact ι x
      · cases' id rl with rls rll rlx rlr
        · cases id rr
          · exact node 2 nil x r
          · exact node 3 (ι x) rx rr
        · cases' id rr with rrs
          · exact node 3 (ι x) rlx ι rx
          ·
            exact
              if rls < ratio * rrs then node (rs + 1) (node (rls + 1) nil x rl) rx rr
              else
                node (rs + 1) (node (size rll + 1) nil x rll) rlx
                  (node (size rlr + rrs + 1) rlr rx rr)
    · cases' id r with rs rl rx rr
      · cases' id ll with lls
        · cases' lr with _ _ lrx
          · exact node 2 l x nil
          · exact node 3 (ι lx) lrx ι x
        · cases' id lr with lrs lrl lrx lrr
          · exact node 3 ll lx ι x
          ·
            exact
              if lrs < ratio * lls then node (ls + 1) ll lx (node (lrs + 1) lr x nil)
              else
                node (ls + 1) (node (lls + size lrl + 1) ll lx lrl) lrx
                  (node (size lrr + 1) lrr x nil)
      · refine'
          if delta * ls < rs then _ else if delta * rs < ls then _ else node (ls + rs + 1) l x r
        · cases' id rl with rls rll rlx rlr
          · exact nil
          --should not happen
          cases' id rr with rrs
          · exact nil
          --should not happen
          exact
            if rls < ratio * rrs then node (ls + rs + 1) (node (ls + rls + 1) l x rl) rx rr
            else
              node (ls + rs + 1) (node (ls + size rll + 1) l x rll) rlx
                (node (size rlr + rrs + 1) rlr rx rr)
        · cases' id ll with lls
          · exact nil
          --should not happen
          cases' id lr with lrs lrl lrx lrr
          · exact nil
          --should not happen
          exact
            if lrs < ratio * lls then node (ls + rs + 1) ll lx (node (lrs + rs + 1) lr x r)
            else
              node (ls + rs + 1) (node (lls + size lrl + 1) ll lx lrl) lrx
                (node (size lrr + rs + 1) lrr x r)
#align ordnode.balance Ordnode.balance

/-- O(n). Does every element of the map satisfy property `P`?

     all (λ x, x < 5) {1, 2, 3} = true
     all (λ x, x < 5) {1, 2, 3, 5} = false -/
def All (P : α → Prop) : Ordnode α → Prop
  | nil => True
  | node _ l x r => all l ∧ P x ∧ all r
#align ordnode.all Ordnode.All

instance All.decidable {P : α → Prop} [DecidablePred P] (t) : Decidable (All P t) := by
  induction t <;> dsimp only [all] <;> skip <;> infer_instance
#align ordnode.all.decidable Ordnode.All.decidable

/-- O(n). Does any element of the map satisfy property `P`?

     any (λ x, x < 2) {1, 2, 3} = true
     any (λ x, x < 2) {2, 3, 5} = false -/
def Any (P : α → Prop) : Ordnode α → Prop
  | nil => False
  | node _ l x r => any l ∨ P x ∨ any r
#align ordnode.any Ordnode.Any

instance Any.decidable {P : α → Prop} [DecidablePred P] (t) : Decidable (Any P t) := by
  induction t <;> dsimp only [any] <;> skip <;> infer_instance
#align ordnode.any.decidable Ordnode.Any.decidable

/-- O(n). Exact membership in the set. This is useful primarily for stating
correctness properties; use `∈` for a version that actually uses the BST property
of the tree.

    emem 2 {1, 2, 3} = true
    emem 4 {1, 2, 3} = false -/
def Emem (x : α) : Ordnode α → Prop :=
  Any (Eq x)
#align ordnode.emem Ordnode.Emem

instance Emem.decidable [DecidableEq α] (x : α) : ∀ t, Decidable (Emem x t) :=
  any.decidable
#align ordnode.emem.decidable Ordnode.Emem.decidable

/-- O(n). Approximate membership in the set, that is, whether some element in the
set is equivalent to this one in the preorder. This is useful primarily for stating
correctness properties; use `∈` for a version that actually uses the BST property
of the tree.

    amem 2 {1, 2, 3} = true
    amem 4 {1, 2, 3} = false

To see the difference with `emem`, we need a preorder that is not a partial order.
For example, suppose we compare pairs of numbers using only their first coordinate. Then:

    emem (0, 1) {(0, 0), (1, 2)} = false
    amem (0, 1) {(0, 0), (1, 2)} = true
    (0, 1) ∈ {(0, 0), (1, 2)} = true

The `∈` relation is equivalent to `amem` as long as the `ordnode` is well formed,
and should always be used instead of `amem`. -/
def Amem [LE α] (x : α) : Ordnode α → Prop :=
  Any fun y => x ≤ y ∧ y ≤ x
#align ordnode.amem Ordnode.Amem

instance Amem.decidable [LE α] [@DecidableRel α (· ≤ ·)] (x : α) : ∀ t, Decidable (Amem x t) :=
  any.decidable
#align ordnode.amem.decidable Ordnode.Amem.decidable

/-- O(log n). Return the minimum element of the tree, or the provided default value.

     find_min' 37 {1, 2, 3} = 1
     find_min' 37 ∅ = 37 -/
def findMin' : Ordnode α → α → α
  | nil, x => x
  | node _ l x r, _ => find_min' l x
#align ordnode.find_min' Ordnode.findMin'

/-- O(log n). Return the minimum element of the tree, if it exists.

     find_min {1, 2, 3} = some 1
     find_min ∅ = none -/
def findMin : Ordnode α → Option α
  | nil => none
  | node _ l x r => some (findMin' l x)
#align ordnode.find_min Ordnode.findMin

/-- O(log n). Return the maximum element of the tree, or the provided default value.

     find_max' 37 {1, 2, 3} = 3
     find_max' 37 ∅ = 37 -/
def findMax' : α → Ordnode α → α
  | x, nil => x
  | _, node _ l x r => find_max' x r
#align ordnode.find_max' Ordnode.findMax'

/-- O(log n). Return the maximum element of the tree, if it exists.

     find_max {1, 2, 3} = some 3
     find_max ∅ = none -/
def findMax : Ordnode α → Option α
  | nil => none
  | node _ l x r => some (findMax' x r)
#align ordnode.find_max Ordnode.findMax

/-- O(log n). Remove the minimum element from the tree, or do nothing if it is already empty.

     erase_min {1, 2, 3} = {2, 3}
     erase_min ∅ = ∅ -/
def eraseMin : Ordnode α → Ordnode α
  | nil => nil
  | node _ nil x r => r
  | node _ l x r => balanceR (erase_min l) x r
#align ordnode.erase_min Ordnode.eraseMin

/-- O(log n). Remove the maximum element from the tree, or do nothing if it is already empty.

     erase_max {1, 2, 3} = {1, 2}
     erase_max ∅ = ∅ -/
def eraseMax : Ordnode α → Ordnode α
  | nil => nil
  | node _ l x nil => l
  | node _ l x r => balanceL l x (erase_max r)
#align ordnode.erase_max Ordnode.eraseMax

/-- **Internal use only**, because it requires a balancing constraint on the inputs.

O(log n). Extract and remove the minimum element from a nonempty tree. -/
def splitMin' : Ordnode α → α → Ordnode α → α × Ordnode α
  | nil, x, r => (x, r)
  | node _ ll lx lr, x, r =>
    let (xm, l') := split_min' ll lx lr
    (xm, balanceR l' x r)
#align ordnode.split_min' Ordnode.splitMin'

/-- O(log n). Extract and remove the minimum element from the tree, if it exists.

     split_min {1, 2, 3} = some (1, {2, 3})
     split_min ∅ = none -/
def splitMin : Ordnode α → Option (α × Ordnode α)
  | nil => none
  | node _ l x r => splitMin' l x r
#align ordnode.split_min Ordnode.splitMin

/-- **Internal use only**, because it requires a balancing constraint on the inputs.

O(log n). Extract and remove the maximum element from a nonempty tree. -/
def splitMax' : Ordnode α → α → Ordnode α → Ordnode α × α
  | l, x, nil => (l, x)
  | l, x, node _ rl rx rr =>
    let (r', xm) := split_max' rl rx rr
    (balanceL l x r', xm)
#align ordnode.split_max' Ordnode.splitMax'

/-- O(log n). Extract and remove the maximum element from the tree, if it exists.

     split_max {1, 2, 3} = some ({1, 2}, 3)
     split_max ∅ = none -/
def splitMax : Ordnode α → Option (Ordnode α × α)
  | nil => none
  | node _ x l r => splitMax' x l r
#align ordnode.split_max Ordnode.splitMax

/-- **Internal use only**

O(log(m+n)). Concatenate two trees that are balanced and ordered with respect to each other. -/
def glue : Ordnode α → Ordnode α → Ordnode α
  | nil, r => r
  | l@(node _ _ _ _), nil => l
  | l@(node sl ll lx lr), r@(node sr rl rx rr) =>
    if sl > sr then
      let (l', m) := splitMax' ll lx lr
      balanceR l' m r
    else
      let (m, r') := splitMin' rl rx rr
      balanceL l m r'
#align ordnode.glue Ordnode.glue

/-- O(log(m+n)). Concatenate two trees that are ordered with respect to each other.

     merge {1, 2} {3, 4} = {1, 2, 3, 4}
     merge {3, 4} {1, 2} = precondition violation -/
def merge (l : Ordnode α) : Ordnode α → Ordnode α :=
  (Ordnode.recOn l fun r => r) fun ls ll lx lr IHll IHlr r =>
    (Ordnode.recOn r (node ls ll lx lr)) fun rs rl rx rr IHrl IHrr =>
      if delta * ls < rs then balanceL IHrl rx rr
      else
        if delta * rs < ls then balanceR ll lx (IHlr <| node rs rl rx rr)
        else glue (node ls ll lx lr) (node rs rl rx rr)
#align ordnode.merge Ordnode.merge

/-- O(log n). Insert an element above all the others, without any comparisons.
(Assumes that the element is in fact above all the others).

    insert_max {1, 2} 4 = {1, 2, 4}
    insert_max {1, 2} 0 = precondition violation -/
def insertMax : Ordnode α → α → Ordnode α
  | nil, x => ι x
  | node _ l y r, x => balanceR l y (insert_max r x)
#align ordnode.insert_max Ordnode.insertMax

/-- O(log n). Insert an element below all the others, without any comparisons.
(Assumes that the element is in fact below all the others).

    insert_min {1, 2} 0 = {0, 1, 2}
    insert_min {1, 2} 4 = precondition violation -/
def insertMin (x : α) : Ordnode α → Ordnode α
  | nil => ι x
  | node _ l y r => balanceR (insert_min l) y r
#align ordnode.insert_min Ordnode.insertMin

/-- O(log(m+n)). Build a tree from an element between two trees, without any
assumption on the relative sizes.

    link {1, 2} 4 {5, 6} = {1, 2, 4, 5, 6}
    link {1, 3} 2 {5} = precondition violation -/
def link (l : Ordnode α) (x : α) : Ordnode α → Ordnode α :=
  (Ordnode.recOn l (insertMin x)) fun ls ll lx lr IHll IHlr r =>
    (Ordnode.recOn r (insertMax l x)) fun rs rl rx rr IHrl IHrr =>
      if delta * ls < rs then balanceL IHrl rx rr
      else if delta * rs < ls then balanceR ll lx (IHlr r) else node' l x r
#align ordnode.link Ordnode.link

/-- O(n). Filter the elements of a tree satisfying a predicate.

     filter (λ x, x < 3) {1, 2, 4} = {1, 2}
     filter (λ x, x > 5) {1, 2, 4} = ∅ -/
def filter (p : α → Prop) [DecidablePred p] : Ordnode α → Ordnode α
  | nil => nil
  | node _ l x r => if p x then link (filter l) x (filter r) else merge (filter l) (filter r)
#align ordnode.filter Ordnode.filter

/-- O(n). Split the elements of a tree into those satisfying, and not satisfying, a predicate.

     partition (λ x, x < 3) {1, 2, 4} = ({1, 2}, {3}) -/
def partition (p : α → Prop) [DecidablePred p] : Ordnode α → Ordnode α × Ordnode α
  | nil => (nil, nil)
  | node _ l x r =>
    let (l₁, l₂) := partition l
    let (r₁, r₂) := partition r
    if p x then (link l₁ x r₁, merge l₂ r₂) else (merge l₁ r₁, link l₂ x r₂)
#align ordnode.partition Ordnode.partition

/- warning: ordnode.map -> Ordnode.map is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{u_1}}, (α -> β) -> (Ordnode.{u} α) -> (Ordnode.{u_1} β)
but is expected to have type
  forall {α : Type.{u}} {β : Type.{_aux_param_0}}, (α -> β) -> (Ordnode.{u} α) -> (Ordnode.{_aux_param_0} β)
Case conversion may be inaccurate. Consider using '#align ordnode.map Ordnode.mapₓ'. -/
/-- O(n). Map a function across a tree, without changing the structure. Only valid when
the function is strictly monotone, i.e. `x < y → f x < f y`.

     partition (λ x, x + 2) {1, 2, 4} = {2, 3, 6}
     partition (λ x : ℕ, x - 2) {1, 2, 4} = precondition violation -/
def map {β} (f : α → β) : Ordnode α → Ordnode β
  | nil => nil
  | node s l x r => node s (map l) (f x) (map r)
#align ordnode.map Ordnode.map

/- warning: ordnode.fold -> Ordnode.fold is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Sort.{u_1}}, β -> (β -> α -> β -> β) -> (Ordnode.{u} α) -> β
but is expected to have type
  forall {α : Type.{u}} {β : Sort.{_aux_param_0}}, β -> (β -> α -> β -> β) -> (Ordnode.{u} α) -> β
Case conversion may be inaccurate. Consider using '#align ordnode.fold Ordnode.foldₓ'. -/
/-- O(n). Fold a function across the structure of a tree.

     fold z f {1, 2, 4} = f (f z 1 z) 2 (f z 4 z)

The exact structure of function applications depends on the tree and so
is unspecified. -/
def fold {β} (z : β) (f : β → α → β → β) : Ordnode α → β
  | nil => z
  | node _ l x r => f (fold l) x (fold r)
#align ordnode.fold Ordnode.fold

/- warning: ordnode.foldl -> Ordnode.foldl is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Sort.{u_1}}, (β -> α -> β) -> β -> (Ordnode.{u} α) -> β
but is expected to have type
  forall {α : Type.{u}} {β : Sort.{_aux_param_0}}, (β -> α -> β) -> β -> (Ordnode.{u} α) -> β
Case conversion may be inaccurate. Consider using '#align ordnode.foldl Ordnode.foldlₓ'. -/
/-- O(n). Fold a function from left to right (in increasing order) across the tree.

     foldl f z {1, 2, 4} = f (f (f z 1) 2) 4 -/
def foldl {β} (f : β → α → β) : β → Ordnode α → β
  | z, nil => z
  | z, node _ l x r => foldl (f (foldl z l) x) r
#align ordnode.foldl Ordnode.foldl

/- warning: ordnode.foldr -> Ordnode.foldr is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Sort.{u_1}}, (α -> β -> β) -> (Ordnode.{u} α) -> β -> β
but is expected to have type
  forall {α : Type.{u}} {β : Sort.{_aux_param_0}}, (α -> β -> β) -> (Ordnode.{u} α) -> β -> β
Case conversion may be inaccurate. Consider using '#align ordnode.foldr Ordnode.foldrₓ'. -/
/-- O(n). Fold a function from right to left (in decreasing order) across the tree.

     foldl f {1, 2, 4} z = f 1 (f 2 (f 4 z)) -/
def foldr {β} (f : α → β → β) : Ordnode α → β → β
  | nil, z => z
  | node _ l x r, z => foldr l (f x (foldr r z))
#align ordnode.foldr Ordnode.foldr

/-- O(n). Build a list of elements in ascending order from the tree.

     to_list {1, 2, 4} = [1, 2, 4]
     to_list {2, 1, 1, 4} = [1, 2, 4] -/
def toList (t : Ordnode α) : List α :=
  foldr List.cons t []
#align ordnode.to_list Ordnode.toList

/-- O(n). Build a list of elements in descending order from the tree.

     to_rev_list {1, 2, 4} = [4, 2, 1]
     to_rev_list {2, 1, 1, 4} = [4, 2, 1] -/
def toRevList (t : Ordnode α) : List α :=
  foldl (flip List.cons) [] t
#align ordnode.to_rev_list Ordnode.toRevList

instance [ToString α] : ToString (Ordnode α) :=
  ⟨fun t => "{" ++ String.intercalate ", " (t.toList.map toString) ++ "}"⟩

unsafe instance [has_to_format α] : has_to_format (Ordnode α) :=
  ⟨fun t => "{" ++ format.intercalate ", " (t.toList.map to_fmt) ++ "}"⟩

/-- O(n). True if the trees have the same elements, ignoring structural differences.

     equiv {1, 2, 4} {2, 1, 1, 4} = true
     equiv {1, 2, 4} {1, 2, 3} = false -/
def Equiv (t₁ t₂ : Ordnode α) : Prop :=
  t₁.size = t₂.size ∧ t₁.toList = t₂.toList
#align ordnode.equiv Ordnode.Equiv

instance [DecidableEq α] : DecidableRel (@Equiv α) := fun t₁ t₂ => And.decidable

/-- O(2^n). Constructs the powerset of a given set, that is, the set of all subsets.

     powerset {1, 2, 3} = {∅, {1}, {2}, {3}, {1,2}, {1,3}, {2,3}, {1,2,3}} -/
def powerset (t : Ordnode α) : Ordnode (Ordnode α) :=
  insertMin nil <| foldr (fun x ts => glue (insertMin (ι x) (map (insertMin x) ts)) ts) t nil
#align ordnode.powerset Ordnode.powerset

/-- O(m*n). The cartesian product of two sets: `(a, b) ∈ s.prod t` iff `a ∈ s` and `b ∈ t`.

     prod {1, 2} {2, 3} = {(1, 2), (1, 3), (2, 2), (2, 3)} -/
protected def prod {β} (t₁ : Ordnode α) (t₂ : Ordnode β) : Ordnode (α × β) :=
  fold nil (fun s₁ a s₂ => merge s₁ <| merge (map (Prod.mk a) t₂) s₂) t₁
#align ordnode.prod Ordnode.prod

/-- O(m+n). Build a set on the disjoint union by combining sets on the factors.
`inl a ∈ s.copair t` iff `a ∈ s`, and `inr b ∈ s.copair t` iff `b ∈ t`.

    copair {1, 2} {2, 3} = {inl 1, inl 2, inr 2, inr 3} -/
protected def copair {β} (t₁ : Ordnode α) (t₂ : Ordnode β) : Ordnode (Sum α β) :=
  merge (map Sum.inl t₁) (map Sum.inr t₂)
#align ordnode.copair Ordnode.copair

/- warning: ordnode.pmap -> Ordnode.pmap is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {P : α -> Prop} {β : Type.{u_1}}, (forall (a : α), (P a) -> β) -> (forall (t : Ordnode.{u} α), (Ordnode.All.{u} α P t) -> (Ordnode.{u_1} β))
but is expected to have type
  forall {α : Type.{u}} {P : α -> Prop} {β : Type.{_aux_param_0}}, (forall (a : α), (P a) -> β) -> (forall (t : Ordnode.{u} α), (Ordnode.All.{u} α P t) -> (Ordnode.{_aux_param_0} β))
Case conversion may be inaccurate. Consider using '#align ordnode.pmap Ordnode.pmapₓ'. -/
/-- O(n). Map a partial function across a set. The result depends on a proof
that the function is defined on all members of the set.

    pmap (fin.mk : ∀ n, n < 4 → fin 4) {1, 2} H = {(1 : fin 4), (2 : fin 4)} -/
def pmap {P : α → Prop} {β} (f : ∀ a, P a → β) : ∀ t : Ordnode α, All P t → Ordnode β
  | nil, _ => nil
  | node s l x r, ⟨hl, hx, hr⟩ => node s (pmap l hl) (f x hx) (pmap r hr)
#align ordnode.pmap Ordnode.pmap

/-- O(n). "Attach" the information that every element of `t` satisfies property
P to these elements inside the set, producing a set in the subtype.

    attach' (λ x, x < 4) {1, 2} H = ({1, 2} : ordnode {x // x<4}) -/
def attach' {P : α → Prop} : ∀ t, All P t → Ordnode { a // P a } :=
  pmap Subtype.mk
#align ordnode.attach' Ordnode.attach'

/-- O(log n). Get the `i`th element of the set, by its index from left to right.

     nth {a, b, c, d} 2 = some c
     nth {a, b, c, d} 5 = none -/
def nth : Ordnode α → ℕ → Option α
  | nil, i => none
  | node _ l x r, i =>
    match Nat.psub' i (size l) with
    | none => nth l i
    | some 0 => some x
    | some (j + 1) => nth r j
#align ordnode.nth Ordnode.nth

/-- O(log n). Remove the `i`th element of the set, by its index from left to right.

     remove_nth {a, b, c, d} 2 = {a, b, d}
     remove_nth {a, b, c, d} 5 = {a, b, c, d} -/
def removeNth : Ordnode α → ℕ → Ordnode α
  | nil, i => nil
  | node _ l x r, i =>
    match Nat.psub' i (size l) with
    | none => balanceR (remove_nth l i) x r
    | some 0 => glue l r
    | some (j + 1) => balanceL l x (remove_nth r j)
#align ordnode.remove_nth Ordnode.removeNth

/-- Auxiliary definition for `take`. (Can also be used in lieu of `take` if you know the
index is within the range of the data structure.)

    take_aux {a, b, c, d} 2 = {a, b}
    take_aux {a, b, c, d} 5 = {a, b, c, d} -/
def takeAux : Ordnode α → ℕ → Ordnode α
  | nil, i => nil
  | node _ l x r, i =>
    if i = 0 then nil
    else
      match Nat.psub' i (size l) with
      | none => take_aux l i
      | some 0 => l
      | some (j + 1) => link l x (take_aux r j)
#align ordnode.take_aux Ordnode.takeAux

/-- O(log n). Get the first `i` elements of the set, counted from the left.

     take 2 {a, b, c, d} = {a, b}
     take 5 {a, b, c, d} = {a, b, c, d} -/
def take (i : ℕ) (t : Ordnode α) : Ordnode α :=
  if size t ≤ i then t else takeAux t i
#align ordnode.take Ordnode.take

/-- Auxiliary definition for `drop`. (Can also be used in lieu of `drop` if you know the
index is within the range of the data structure.)

    drop_aux {a, b, c, d} 2 = {c, d}
    drop_aux {a, b, c, d} 5 = ∅ -/
def dropAux : Ordnode α → ℕ → Ordnode α
  | nil, i => nil
  | t@(node _ l x r), i =>
    if i = 0 then t
    else
      match Nat.psub' i (size l) with
      | none => link (drop_aux l i) x r
      | some 0 => insertMin x r
      | some (j + 1) => drop_aux r j
#align ordnode.drop_aux Ordnode.dropAux

/-- O(log n). Remove the first `i` elements of the set, counted from the left.

     drop 2 {a, b, c, d} = {c, d}
     drop 5 {a, b, c, d} = ∅ -/
def drop (i : ℕ) (t : Ordnode α) : Ordnode α :=
  if size t ≤ i then nil else dropAux t i
#align ordnode.drop Ordnode.drop

/-- Auxiliary definition for `split_at`. (Can also be used in lieu of `split_at` if you know the
index is within the range of the data structure.)

    split_at_aux {a, b, c, d} 2 = ({a, b}, {c, d})
    split_at_aux {a, b, c, d} 5 = ({a, b, c, d}, ∅) -/
def splitAtAux : Ordnode α → ℕ → Ordnode α × Ordnode α
  | nil, i => (nil, nil)
  | t@(node _ l x r), i =>
    if i = 0 then (nil, t)
    else
      match Nat.psub' i (size l) with
      | none =>
        let (l₁, l₂) := split_at_aux l i
        (l₁, link l₂ x r)
      | some 0 => (glue l r, insertMin x r)
      | some (j + 1) =>
        let (r₁, r₂) := split_at_aux r j
        (link l x r₁, r₂)
#align ordnode.split_at_aux Ordnode.splitAtAux

/-- O(log n). Split a set at the `i`th element, getting the first `i` and everything else.

     split_at 2 {a, b, c, d} = ({a, b}, {c, d})
     split_at 5 {a, b, c, d} = ({a, b, c, d}, ∅) -/
def splitAt (i : ℕ) (t : Ordnode α) : Ordnode α × Ordnode α :=
  if size t ≤ i then (t, nil) else splitAtAux t i
#align ordnode.split_at Ordnode.splitAt

/-- O(log n). Get an initial segment of the set that satisfies the predicate `p`.
`p` is required to be antitone, that is, `x < y → p y → p x`.

    take_while (λ x, x < 4) {1, 2, 3, 4, 5} = {1, 2, 3}
    take_while (λ x, x > 4) {1, 2, 3, 4, 5} = precondition violation -/
def takeWhile (p : α → Prop) [DecidablePred p] : Ordnode α → Ordnode α
  | nil => nil
  | node _ l x r => if p x then link l x (take_while r) else take_while l
#align ordnode.take_while Ordnode.takeWhile

/-- O(log n). Remove an initial segment of the set that satisfies the predicate `p`.
`p` is required to be antitone, that is, `x < y → p y → p x`.

    drop_while (λ x, x < 4) {1, 2, 3, 4, 5} = {4, 5}
    drop_while (λ x, x > 4) {1, 2, 3, 4, 5} = precondition violation -/
def dropWhile (p : α → Prop) [DecidablePred p] : Ordnode α → Ordnode α
  | nil => nil
  | node _ l x r => if p x then drop_while r else link (drop_while l) x r
#align ordnode.drop_while Ordnode.dropWhile

/-- O(log n). Split the set into those satisfying and not satisfying the predicate `p`.
`p` is required to be antitone, that is, `x < y → p y → p x`.

    span (λ x, x < 4) {1, 2, 3, 4, 5} = ({1, 2, 3}, {4, 5})
    span (λ x, x > 4) {1, 2, 3, 4, 5} = precondition violation -/
def span (p : α → Prop) [DecidablePred p] : Ordnode α → Ordnode α × Ordnode α
  | nil => (nil, nil)
  | node _ l x r =>
    if p x then
      let (r₁, r₂) := span r
      (link l x r₁, r₂)
    else
      let (l₁, l₂) := span l
      (l₁, link l₂ x r)
#align ordnode.span Ordnode.span

/-- Auxiliary definition for `of_asc_list`.

**Note:** This function is defined by well founded recursion, so it will probably not compute
in the kernel, meaning that you probably can't prove things like
`of_asc_list [1, 2, 3] = {1, 2, 3}` by `rfl`.
This implementation is optimized for VM evaluation. -/
def ofAscListAux₁ : ∀ l : List α, ℕ → Ordnode α × { l' : List α // l'.length ≤ l.length }
  | [] => fun s => (nil, ⟨[], le_rfl⟩)
  | x :: xs => fun s =>
    if s = 1 then (ι x, ⟨xs, Nat.le_succ _⟩)
    else
      have := Nat.lt_succ_self xs.length
      match of_asc_list_aux₁ xs (s.shiftl 1) with
      | (t, ⟨[], h⟩) => (t, ⟨[], Nat.zero_le _⟩)
      | (l, ⟨y :: ys, h⟩) =>
        have := Nat.le_succ_of_le h
        let (r, ⟨zs, h'⟩) := of_asc_list_aux₁ ys (s.shiftl 1)
        (link l y r, ⟨zs, le_trans h' (le_of_lt this)⟩)termination_by'
  ⟨_, measure_wf List.length⟩
#align ordnode.of_asc_list_aux₁ Ordnode.ofAscListAux₁

/-- Auxiliary definition for `of_asc_list`. -/
def ofAscListAux₂ : List α → Ordnode α → ℕ → Ordnode α
  | [] => fun t s => t
  | x :: xs => fun l s =>
    have := Nat.lt_succ_self xs.length
    match ofAscListAux₁ xs s with
    | (r, ⟨ys, h⟩) =>
      have := Nat.lt_succ_of_le h
      of_asc_list_aux₂ ys (link l x r) (s.shiftl 1)termination_by'
  ⟨_, measure_wf List.length⟩
#align ordnode.of_asc_list_aux₂ Ordnode.ofAscListAux₂

/-- O(n). Build a set from a list which is already sorted. Performs no comparisons.

     of_asc_list [1, 2, 3] = {1, 2, 3}
     of_asc_list [3, 2, 1] = precondition violation -/
def ofAscList : List α → Ordnode α
  | [] => nil
  | x :: xs => ofAscListAux₂ xs (ι x) 1
#align ordnode.of_asc_list Ordnode.ofAscList

section

variable [LE α] [@DecidableRel α (· ≤ ·)]

/-- O(log n). Does the set (approximately) contain the element `x`? That is,
is there an element that is equivalent to `x` in the order?

    1 ∈ {1, 2, 3} = true
    4 ∈ {1, 2, 3} = false

Using a preorder on `ℕ × ℕ` that only compares the first coordinate:

    (1, 1) ∈ {(0, 1), (1, 2)} = true
    (3, 1) ∈ {(0, 1), (1, 2)} = false -/
def mem (x : α) : Ordnode α → Bool
  | nil => false
  | node _ l y r =>
    match cmpLE x y with
    | Ordering.lt => mem l
    | Ordering.eq => true
    | Ordering.gt => mem r
#align ordnode.mem Ordnode.mem

/-- O(log n). Retrieve an element in the set that is equivalent to `x` in the order,
if it exists.

    find 1 {1, 2, 3} = some 1
    find 4 {1, 2, 3} = none

Using a preorder on `ℕ × ℕ` that only compares the first coordinate:

    find (1, 1) {(0, 1), (1, 2)} = some (1, 2)
    find (3, 1) {(0, 1), (1, 2)} = none -/
def find (x : α) : Ordnode α → Option α
  | nil => none
  | node _ l y r =>
    match cmpLE x y with
    | Ordering.lt => find l
    | Ordering.eq => some y
    | Ordering.gt => find r
#align ordnode.find Ordnode.find

instance : Membership α (Ordnode α) :=
  ⟨fun x t => t.Mem x⟩

instance mem.decidable (x : α) (t : Ordnode α) : Decidable (x ∈ t) :=
  Bool.decidableEq _ _
#align ordnode.mem.decidable Ordnode.mem.decidable

/-- O(log n). Insert an element into the set, preserving balance and the BST property.
If an equivalent element is already in the set, the function `f` is used to generate
the element to insert (being passed the current value in the set).

    insert_with f 0 {1, 2, 3} = {0, 1, 2, 3}
    insert_with f 1 {1, 2, 3} = {f 1, 2, 3}

Using a preorder on `ℕ × ℕ` that only compares the first coordinate:

    insert_with f (1, 1) {(0, 1), (1, 2)} = {(0, 1), f (1, 2)}
    insert_with f (3, 1) {(0, 1), (1, 2)} = {(0, 1), (1, 2), (3, 1)} -/
def insertWith (f : α → α) (x : α) : Ordnode α → Ordnode α
  | nil => ι x
  | t@(node sz l y r) =>
    match cmpLE x y with
    | Ordering.lt => balanceL (insert_with l) y r
    | Ordering.eq => node sz l (f y) r
    | Ordering.gt => balanceR l y (insert_with r)
#align ordnode.insert_with Ordnode.insertWith

/-- O(log n). Modify an element in the set with the given function,
doing nothing if the key is not found.
Note that the element returned by `f` must be equivalent to `x`.

    adjust_with f 0 {1, 2, 3} = {1, 2, 3}
    adjust_with f 1 {1, 2, 3} = {f 1, 2, 3}

Using a preorder on `ℕ × ℕ` that only compares the first coordinate:

    adjust_with f (1, 1) {(0, 1), (1, 2)} = {(0, 1), f (1, 2)}
    adjust_with f (3, 1) {(0, 1), (1, 2)} = {(0, 1), (1, 2)} -/
def adjustWith (f : α → α) (x : α) : Ordnode α → Ordnode α
  | nil => nil
  | t@(node sz l y r) =>
    match cmpLE x y with
    | Ordering.lt => node sz (adjust_with l) y r
    | Ordering.eq => node sz l (f y) r
    | Ordering.gt => node sz l y (adjust_with r)
#align ordnode.adjust_with Ordnode.adjustWith

/-- O(log n). Modify an element in the set with the given function,
doing nothing if the key is not found.
Note that the element returned by `f` must be equivalent to `x`.

    update_with f 0 {1, 2, 3} = {1, 2, 3}
    update_with f 1 {1, 2, 3} = {2, 3}     if f 1 = none
                              = {a, 2, 3}  if f 1 = some a -/
def updateWith (f : α → Option α) (x : α) : Ordnode α → Ordnode α
  | nil => nil
  | t@(node sz l y r) =>
    match cmpLE x y with
    | Ordering.lt => balanceR (update_with l) y r
    | Ordering.eq =>
      match f y with
      | none => glue l r
      | some a => node sz l a r
    | Ordering.gt => balanceL l y (update_with r)
#align ordnode.update_with Ordnode.updateWith

/-- O(log n). Modify an element in the set with the given function,
doing nothing if the key is not found.
Note that the element returned by `f` must be equivalent to `x`.

    alter f 0 {1, 2, 3} = {1, 2, 3}     if f none = none
                        = {a, 1, 2, 3}  if f none = some a
    alter f 1 {1, 2, 3} = {2, 3}     if f 1 = none
                        = {a, 2, 3}  if f 1 = some a -/
def alter (f : Option α → Option α) (x : α) : Ordnode α → Ordnode α
  | nil => Option.recOn (f none) nil Ordnode.singleton
  | t@(node sz l y r) =>
    match cmpLE x y with
    | Ordering.lt => balance (alter l) y r
    | Ordering.eq =>
      match f (some y) with
      | none => glue l r
      | some a => node sz l a r
    | Ordering.gt => balance l y (alter r)
#align ordnode.alter Ordnode.alter

/-- O(log n). Insert an element into the set, preserving balance and the BST property.
If an equivalent element is already in the set, this replaces it.

    insert 1 {1, 2, 3} = {1, 2, 3}
    insert 4 {1, 2, 3} = {1, 2, 3, 4}

Using a preorder on `ℕ × ℕ` that only compares the first coordinate:

    insert (1, 1) {(0, 1), (1, 2)} = {(0, 1), (1, 1)}
    insert (3, 1) {(0, 1), (1, 2)} = {(0, 1), (1, 2), (3, 1)} -/
protected def insert (x : α) : Ordnode α → Ordnode α
  | nil => ι x
  | node sz l y r =>
    match cmpLE x y with
    | Ordering.lt => balanceL (insert l) y r
    | Ordering.eq => node sz l x r
    | Ordering.gt => balanceR l y (insert r)
#align ordnode.insert Ordnode.insert

instance : Insert α (Ordnode α) :=
  ⟨Ordnode.insert⟩

/-- O(log n). Insert an element into the set, preserving balance and the BST property.
If an equivalent element is already in the set, the set is returned as is.

    insert' 1 {1, 2, 3} = {1, 2, 3}
    insert' 4 {1, 2, 3} = {1, 2, 3, 4}

Using a preorder on `ℕ × ℕ` that only compares the first coordinate:

    insert' (1, 1) {(0, 1), (1, 2)} = {(0, 1), (1, 2)}
    insert' (3, 1) {(0, 1), (1, 2)} = {(0, 1), (1, 2), (3, 1)} -/
def insert' (x : α) : Ordnode α → Ordnode α
  | nil => ι x
  | t@(node sz l y r) =>
    match cmpLE x y with
    | Ordering.lt => balanceL (insert' l) y r
    | Ordering.eq => t
    | Ordering.gt => balanceR l y (insert' r)
#align ordnode.insert' Ordnode.insert'

/-- O(log n). Split the tree into those smaller than `x` and those greater than it.
If an element equivalent to `x` is in the set, it is discarded.

    split 2 {1, 2, 4} = ({1}, {4})
    split 3 {1, 2, 4} = ({1, 2}, {4})
    split 4 {1, 2, 4} = ({1, 2}, ∅)

Using a preorder on `ℕ × ℕ` that only compares the first coordinate:

    split (1, 1) {(0, 1), (1, 2)} = ({(0, 1)}, ∅)
    split (3, 1) {(0, 1), (1, 2)} = ({(0, 1), (1, 2)}, ∅) -/
def split (x : α) : Ordnode α → Ordnode α × Ordnode α
  | nil => (nil, nil)
  | node sz l y r =>
    match cmpLE x y with
    | Ordering.lt =>
      let (lt, GT.gt) := split l
      (lt, link GT.gt y r)
    | Ordering.eq => (l, r)
    | Ordering.gt =>
      let (lt, GT.gt) := split r
      (link l y lt, GT.gt)
#align ordnode.split Ordnode.split

/-- O(log n). Split the tree into those smaller than `x` and those greater than it,
plus an element equivalent to `x`, if it exists.

    split 2 {1, 2, 4} = ({1}, some 2, {4})
    split 3 {1, 2, 4} = ({1, 2}, none, {4})
    split 4 {1, 2, 4} = ({1, 2}, some 4, ∅)

Using a preorder on `ℕ × ℕ` that only compares the first coordinate:

    split (1, 1) {(0, 1), (1, 2)} = ({(0, 1)}, some (1, 2), ∅)
    split (3, 1) {(0, 1), (1, 2)} = ({(0, 1), (1, 2)}, none, ∅) -/
def split3 (x : α) : Ordnode α → Ordnode α × Option α × Ordnode α
  | nil => (nil, none, nil)
  | node sz l y r =>
    match cmpLE x y with
    | Ordering.lt =>
      let (lt, f, GT.gt) := split3 l
      (lt, f, link GT.gt y r)
    | Ordering.eq => (l, some y, r)
    | Ordering.gt =>
      let (lt, f, GT.gt) := split3 r
      (link l y lt, f, GT.gt)
#align ordnode.split3 Ordnode.split3

/-- O(log n). Remove an element from the set equivalent to `x`. Does nothing if there
is no such element.

    erase 1 {1, 2, 3} = {2, 3}
    erase 4 {1, 2, 3} = {1, 2, 3}

Using a preorder on `ℕ × ℕ` that only compares the first coordinate:

    erase (1, 1) {(0, 1), (1, 2)} = {(0, 1)}
    erase (3, 1) {(0, 1), (1, 2)} = {(0, 1), (1, 2)} -/
def erase (x : α) : Ordnode α → Ordnode α
  | nil => nil
  | t@(node sz l y r) =>
    match cmpLE x y with
    | Ordering.lt => balanceR (erase l) y r
    | Ordering.eq => glue l r
    | Ordering.gt => balanceL l y (erase r)
#align ordnode.erase Ordnode.erase

/-- Auxiliary definition for `find_lt`. -/
def findLtAux (x : α) : Ordnode α → α → α
  | nil, best => best
  | node _ l y r, best => if x ≤ y then find_lt_aux l best else find_lt_aux r y
#align ordnode.find_lt_aux Ordnode.findLtAux

/-- O(log n). Get the largest element in the tree that is `< x`.

     find_lt 2 {1, 2, 4} = some 1
     find_lt 3 {1, 2, 4} = some 2
     find_lt 0 {1, 2, 4} = none -/
def findLt (x : α) : Ordnode α → Option α
  | nil => none
  | node _ l y r => if x ≤ y then find_lt l else some (findLtAux x r y)
#align ordnode.find_lt Ordnode.findLt

/-- Auxiliary definition for `find_gt`. -/
def findGtAux (x : α) : Ordnode α → α → α
  | nil, best => best
  | node _ l y r, best => if y ≤ x then find_gt_aux r best else find_gt_aux l y
#align ordnode.find_gt_aux Ordnode.findGtAux

/-- O(log n). Get the smallest element in the tree that is `> x`.

     find_lt 2 {1, 2, 4} = some 4
     find_lt 3 {1, 2, 4} = some 4
     find_lt 4 {1, 2, 4} = none -/
def findGt (x : α) : Ordnode α → Option α
  | nil => none
  | node _ l y r => if y ≤ x then find_gt r else some (findGtAux x l y)
#align ordnode.find_gt Ordnode.findGt

/-- Auxiliary definition for `find_le`. -/
def findLeAux (x : α) : Ordnode α → α → α
  | nil, best => best
  | node _ l y r, best =>
    match cmpLE x y with
    | Ordering.lt => find_le_aux l best
    | Ordering.eq => y
    | Ordering.gt => find_le_aux r y
#align ordnode.find_le_aux Ordnode.findLeAux

/-- O(log n). Get the largest element in the tree that is `≤ x`.

     find_le 2 {1, 2, 4} = some 2
     find_le 3 {1, 2, 4} = some 2
     find_le 0 {1, 2, 4} = none -/
def findLe (x : α) : Ordnode α → Option α
  | nil => none
  | node _ l y r =>
    match cmpLE x y with
    | Ordering.lt => find_le l
    | Ordering.eq => some y
    | Ordering.gt => some (findLeAux x r y)
#align ordnode.find_le Ordnode.findLe

/-- Auxiliary definition for `find_ge`. -/
def findGeAux (x : α) : Ordnode α → α → α
  | nil, best => best
  | node _ l y r, best =>
    match cmpLE x y with
    | Ordering.lt => find_ge_aux l y
    | Ordering.eq => y
    | Ordering.gt => find_ge_aux r best
#align ordnode.find_ge_aux Ordnode.findGeAux

/-- O(log n). Get the smallest element in the tree that is `≥ x`.

     find_le 2 {1, 2, 4} = some 2
     find_le 3 {1, 2, 4} = some 4
     find_le 5 {1, 2, 4} = none -/
def findGe (x : α) : Ordnode α → Option α
  | nil => none
  | node _ l y r =>
    match cmpLE x y with
    | Ordering.lt => some (findGeAux x l y)
    | Ordering.eq => some y
    | Ordering.gt => find_ge r
#align ordnode.find_ge Ordnode.findGe

/-- Auxiliary definition for `find_index`. -/
def findIndexAux (x : α) : Ordnode α → ℕ → Option ℕ
  | nil, i => none
  | node _ l y r, i =>
    match cmpLE x y with
    | Ordering.lt => find_index_aux l i
    | Ordering.eq => some (i + size l)
    | Ordering.gt => find_index_aux r (i + size l + 1)
#align ordnode.find_index_aux Ordnode.findIndexAux

/-- O(log n). Get the index, counting from the left,
of an element equivalent to `x` if it exists.

    find_index 2 {1, 2, 4} = some 1
    find_index 4 {1, 2, 4} = some 2
    find_index 5 {1, 2, 4} = none -/
def findIndex (x : α) (t : Ordnode α) : Option ℕ :=
  findIndexAux x t 0
#align ordnode.find_index Ordnode.findIndex

/-- Auxiliary definition for `is_subset`. -/
def isSubsetAux : Ordnode α → Ordnode α → Bool
  | nil, _ => true
  | _, nil => false
  | node _ l x r, t =>
    let (lt, found, GT.gt) := split3 x t
    found.isSome && is_subset_aux l lt && is_subset_aux r GT.gt
#align ordnode.is_subset_aux Ordnode.isSubsetAux

/-- O(m+n). Is every element of `t₁` equivalent to some element of `t₂`?

     is_subset {1, 4} {1, 2, 4} = tt
     is_subset {1, 3} {1, 2, 4} = ff -/
def isSubset (t₁ t₂ : Ordnode α) : Bool :=
  decide (size t₁ ≤ size t₂) && isSubsetAux t₁ t₂
#align ordnode.is_subset Ordnode.isSubset

/-- O(m+n). Is every element of `t₁` not equivalent to any element of `t₂`?

     disjoint {1, 3} {2, 4} = tt
     disjoint {1, 2} {2, 4} = ff -/
def disjoint : Ordnode α → Ordnode α → Bool
  | nil, _ => true
  | _, nil => true
  | node _ l x r, t =>
    let (lt, found, GT.gt) := split3 x t
    found.isNone && Disjoint l lt && Disjoint r GT.gt
#align ordnode.disjoint Ordnode.disjoint

/-- O(m * log(|m ∪ n| + 1)), m ≤ n. The union of two sets, preferring members of
  `t₁` over those of `t₂` when equivalent elements are encountered.

    union {1, 2} {2, 3} = {1, 2, 3}
    union {1, 3} {2} = {1, 2, 3}

Using a preorder on `ℕ × ℕ` that only compares the first coordinate:

    union {(1, 1)} {(0, 1), (1, 2)} = {(0, 1), (1, 1)} -/
def union : Ordnode α → Ordnode α → Ordnode α
  | t₁, nil => t₁
  | nil, t₂ => t₂
  | t₁@(node s₁ l₁ x₁ r₁), t₂@(node s₂ l₂ x₂ r₂) =>
    if s₂ = 1 then insert' x₂ t₁
    else
      if s₁ = 1 then insert x₁ t₂
      else
        let (l₂', r₂') := split x₁ t₂
        link (union l₁ l₂') x₁ (union r₁ r₂')
#align ordnode.union Ordnode.union

/-- O(m * log(|m ∪ n| + 1)), m ≤ n. Difference of two sets.

    diff {1, 2} {2, 3} = {1}
    diff {1, 2, 3} {2} = {1, 3} -/
def diff : Ordnode α → Ordnode α → Ordnode α
  | t₁, nil => t₁
  | t₁, t₂@(node _ l₂ x r₂) =>
    cond t₁.Empty t₂ <|
      let (l₁, r₁) := split x t₁
      let l₁₂ := diff l₁ l₂
      let r₁₂ := diff r₁ r₂
      if size l₁₂ + size r₁₂ = size t₁ then t₁ else merge l₁₂ r₁₂
#align ordnode.diff Ordnode.diff

/-- O(m * log(|m ∪ n| + 1)), m ≤ n. Intersection of two sets, preferring members of
`t₁` over those of `t₂` when equivalent elements are encountered.

    inter {1, 2} {2, 3} = {2}
    inter {1, 3} {2} = ∅ -/
def inter : Ordnode α → Ordnode α → Ordnode α
  | nil, t₂ => nil
  | t₁@(node _ l₁ x r₁), t₂ =>
    cond t₂.Empty t₁ <|
      let (l₂, y, r₂) := split3 x t₂
      let l₁₂ := inter l₁ l₂
      let r₁₂ := inter r₁ r₂
      cond y.isSome (link l₁₂ x r₁₂) (merge l₁₂ r₁₂)
#align ordnode.inter Ordnode.inter

/-- O(n * log n). Build a set from a list, preferring elements that appear earlier in the list
in the case of equivalent elements.

    of_list [1, 2, 3] = {1, 2, 3}
    of_list [2, 1, 1, 3] = {1, 2, 3}

Using a preorder on `ℕ × ℕ` that only compares the first coordinate:

    of_list [(1, 1), (0, 1), (1, 2)] = {(0, 1), (1, 1)} -/
def ofList (l : List α) : Ordnode α :=
  l.foldr insert nil
#align ordnode.of_list Ordnode.ofList

/-- O(n * log n). Adaptively chooses between the linear and log-linear algorithm depending
  on whether the input list is already sorted.

    of_list' [1, 2, 3] = {1, 2, 3}
    of_list' [2, 1, 1, 3] = {1, 2, 3} -/
def ofList' : List α → Ordnode α
  | [] => nil
  | x :: xs => if List.Chain (fun a b => ¬b ≤ a) x xs then ofAscList (x :: xs) else ofList (x :: xs)
#align ordnode.of_list' Ordnode.ofList'

/-- O(n * log n). Map a function on a set. Unlike `map` this has no requirements on
`f`, and the resulting set may be smaller than the input if `f` is noninjective.
Equivalent elements are selected with a preference for smaller source elements.

    image (λ x, x + 2) {1, 2, 4} = {3, 4, 6}
    image (λ x : ℕ, x - 2) {1, 2, 4} = {0, 2} -/
def image {α β} [LE β] [@DecidableRel β (· ≤ ·)] (f : α → β) (t : Ordnode α) : Ordnode β :=
  ofList (t.toList.map f)
#align ordnode.image Ordnode.image

end

end Ordnode

