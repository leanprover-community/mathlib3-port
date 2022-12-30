/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module control.traversable.instances
! leanprover-community/mathlib commit 09597669f02422ed388036273d8848119699c22f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Control.Applicative
import Mathbin.Data.List.Forall2
import Mathbin.Data.Set.Functor

/-!
# Traversable instances

This file provides instances of `traversable` for types from the core library: `option`, `list` and
`sum`.
-/


universe u v

section Option

open Functor

variable {F G : Type u → Type u}

variable [Applicative F] [Applicative G]

variable [LawfulApplicative F] [LawfulApplicative G]

theorem Option.id_traverse {α} (x : Option α) : Option.traverse id.mk x = x := by cases x <;> rfl
#align option.id_traverse Option.id_traverse

@[nolint unused_arguments]
theorem Option.comp_traverse {α β γ} (f : β → F γ) (g : α → G β) (x : Option α) :
    Option.traverse (comp.mk ∘ (· <$> ·) f ∘ g) x =
      Comp.mk (Option.traverse f <$> Option.traverse g x) :=
  by cases x <;> simp! [functor_norm] <;> rfl
#align option.comp_traverse Option.comp_traverse

theorem Option.traverse_eq_map_id {α β} (f : α → β) (x : Option α) :
    traverse (id.mk ∘ f) x = id.mk (f <$> x) := by cases x <;> rfl
#align option.traverse_eq_map_id Option.traverse_eq_map_id

variable (η : ApplicativeTransformation F G)

theorem Option.naturality {α β} (f : α → F β) (x : Option α) :
    η (Option.traverse f x) = Option.traverse (@η _ ∘ f) x := by
  cases' x with x <;> simp! [*, functor_norm]
#align option.naturality Option.naturality

end Option

instance : IsLawfulTraversable Option :=
  { Option.is_lawful_monad with
    id_traverse := @Option.id_traverse
    comp_traverse := @Option.comp_traverse
    traverse_eq_map_id := @Option.traverse_eq_map_id
    naturality := @Option.naturality }

namespace List

variable {F G : Type u → Type u}

variable [Applicative F] [Applicative G]

section

variable [LawfulApplicative F] [LawfulApplicative G]

open Applicative Functor List

protected theorem id_traverse {α} (xs : List α) : List.traverse id.mk xs = xs := by
  induction xs <;> simp! [*, functor_norm] <;> rfl
#align list.id_traverse List.id_traverse

@[nolint unused_arguments]
protected theorem comp_traverse {α β γ} (f : β → F γ) (g : α → G β) (x : List α) :
    List.traverse (comp.mk ∘ (· <$> ·) f ∘ g) x = Comp.mk (List.traverse f <$> List.traverse g x) :=
  by induction x <;> simp! [*, functor_norm] <;> rfl
#align list.comp_traverse List.comp_traverse

protected theorem traverse_eq_map_id {α β} (f : α → β) (x : List α) :
    List.traverse (id.mk ∘ f) x = id.mk (f <$> x) := by
  induction x <;> simp! [*, functor_norm] <;> rfl
#align list.traverse_eq_map_id List.traverse_eq_map_id

variable (η : ApplicativeTransformation F G)

protected theorem naturality {α β} (f : α → F β) (x : List α) :
    η (List.traverse f x) = List.traverse (@η _ ∘ f) x := by induction x <;> simp! [*, functor_norm]
#align list.naturality List.naturality

open Nat

instance : IsLawfulTraversable.{u} List :=
  { List.is_lawful_monad with
    id_traverse := @List.id_traverse
    comp_traverse := @List.comp_traverse
    traverse_eq_map_id := @List.traverse_eq_map_id
    naturality := @List.naturality }

end

section Traverse

variable {α' β' : Type u} (f : α' → F β')

@[simp]
theorem traverse_nil : traverse f ([] : List α') = (pure [] : F (List β')) :=
  rfl
#align list.traverse_nil List.traverse_nil

@[simp]
theorem traverse_cons (a : α') (l : List α') :
    traverse f (a :: l) = (· :: ·) <$> f a <*> traverse f l :=
  rfl
#align list.traverse_cons List.traverse_cons

variable [LawfulApplicative F]

@[simp]
theorem traverse_append :
    ∀ as bs : List α', traverse f (as ++ bs) = (· ++ ·) <$> traverse f as <*> traverse f bs
  | [], bs => by
    have : Append.append ([] : List β') = id := by funext <;> rfl
    simp [this, functor_norm]
  | a :: as, bs => by simp [traverse_append as bs, functor_norm] <;> congr
#align list.traverse_append List.traverse_append

theorem mem_traverse {f : α' → Set β'} :
    ∀ (l : List α') (n : List β'), n ∈ traverse f l ↔ Forall₂ (fun b a => b ∈ f a) n l
  | [], [] => by simp
  | a :: as, [] => by simp
  | [], b :: bs => by simp
  | a :: as, b :: bs => by simp [mem_traverse as bs]
#align list.mem_traverse List.mem_traverse

end Traverse

end List

namespace Sum

section Traverse

variable {σ : Type u}

variable {F G : Type u → Type u}

variable [Applicative F] [Applicative G]

open Applicative Functor

open List (cons)

protected theorem traverse_map {α β γ : Type u} (g : α → β) (f : β → G γ) (x : Sum σ α) :
    Sum.traverse f (g <$> x) = Sum.traverse (f ∘ g) x := by
  cases x <;> simp [Sum.traverse, id_map, functor_norm] <;> rfl
#align sum.traverse_map Sum.traverse_map

variable [LawfulApplicative F] [LawfulApplicative G]

protected theorem id_traverse {σ α} (x : Sum σ α) : Sum.traverse id.mk x = x := by cases x <;> rfl
#align sum.id_traverse Sum.id_traverse

@[nolint unused_arguments]
protected theorem comp_traverse {α β γ} (f : β → F γ) (g : α → G β) (x : Sum σ α) :
    Sum.traverse (comp.mk ∘ (· <$> ·) f ∘ g) x = Comp.mk (Sum.traverse f <$> Sum.traverse g x) := by
  cases x <;> simp! [Sum.traverse, map_id, functor_norm] <;> rfl
#align sum.comp_traverse Sum.comp_traverse

protected theorem traverse_eq_map_id {α β} (f : α → β) (x : Sum σ α) :
    Sum.traverse (id.mk ∘ f) x = id.mk (f <$> x) := by
  induction x <;> simp! [*, functor_norm] <;> rfl
#align sum.traverse_eq_map_id Sum.traverse_eq_map_id

protected theorem map_traverse {α β γ} (g : α → G β) (f : β → γ) (x : Sum σ α) :
    (· <$> ·) f <$> Sum.traverse g x = Sum.traverse ((· <$> ·) f ∘ g) x := by
  cases x <;> simp [Sum.traverse, id_map, functor_norm] <;> congr <;> rfl
#align sum.map_traverse Sum.map_traverse

variable (η : ApplicativeTransformation F G)

protected theorem naturality {α β} (f : α → F β) (x : Sum σ α) :
    η (Sum.traverse f x) = Sum.traverse (@η _ ∘ f) x := by
  cases x <;> simp! [Sum.traverse, functor_norm]
#align sum.naturality Sum.naturality

end Traverse

instance {σ : Type u} : IsLawfulTraversable.{u} (Sum σ) :=
  { Sum.is_lawful_monad with
    id_traverse := @Sum.id_traverse σ
    comp_traverse := @Sum.comp_traverse σ
    traverse_eq_map_id := @Sum.traverse_eq_map_id σ
    naturality := @Sum.naturality σ }

end Sum

