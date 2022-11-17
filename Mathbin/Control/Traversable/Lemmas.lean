/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon
-/
import Mathbin.Control.Applicative
import Mathbin.Control.Traversable.Basic

/-!
# Traversing collections

This file proves basic properties of traversable and applicative functors and defines
`pure_transformation F`, the natural applicative transformation from the identity functor to `F`.

## References

Inspired by [The Essence of the Iterator Pattern][gibbons2009].
-/


universe u

open IsLawfulTraversable

open Function hiding comp

open Functor

attribute [functor_norm] IsLawfulTraversable.naturality

attribute [simp] IsLawfulTraversable.id_traverse

namespace Traversable

variable {t : Type u → Type u}

variable [Traversable t] [IsLawfulTraversable t]

variable (F G : Type u → Type u)

variable [Applicative F] [LawfulApplicative F]

variable [Applicative G] [LawfulApplicative G]

variable {α β γ : Type u}

variable (g : α → F β)

variable (h : β → G γ)

variable (f : β → γ)

/-- The natural applicative transformation from the identity functor
to `F`, defined by `pure : Π {α}, α → F α`. -/
def pureTransformation : ApplicativeTransformation id F where
  app := @pure F _
  preserves_pure' α x := rfl
  preserves_seq' α β f x := by
    simp only [map_pure, seq_pure]
    rfl
#align traversable.pure_transformation Traversable.pureTransformation

@[simp]
theorem pure_transformation_apply {α} (x : id α) : pureTransformation F x = pure x :=
  rfl
#align traversable.pure_transformation_apply Traversable.pure_transformation_apply

variable {F G} (x : t β)

theorem map_eq_traverse_id : map f = @traverse t _ _ _ _ _ (id.mk ∘ f) :=
  funext $ fun y => (traverse_eq_map_id f y).symm
#align traversable.map_eq_traverse_id Traversable.map_eq_traverse_id

theorem map_traverse (x : t α) : map f <$> traverse g x = traverse (map f ∘ g) x := by
  rw [@map_eq_traverse_id t _ _ _ _ f]
  refine' (comp_traverse (id.mk ∘ f) g x).symm.trans _
  congr
  apply comp.applicative_comp_id
#align traversable.map_traverse Traversable.map_traverse

theorem traverse_map (f : β → F γ) (g : α → β) (x : t α) : traverse f (g <$> x) = traverse (f ∘ g) x := by
  rw [@map_eq_traverse_id t _ _ _ _ g]
  refine' (comp_traverse f (id.mk ∘ g) x).symm.trans _
  congr
  apply comp.applicative_id_comp
#align traversable.traverse_map Traversable.traverse_map

theorem pure_traverse (x : t α) : traverse pure x = (pure x : F (t α)) := by
  have : traverse pure x = pure (traverse id.mk x) := (naturality (pure_transformation F) id.mk x).symm <;>
    rwa [id_traverse] at this
#align traversable.pure_traverse Traversable.pure_traverse

theorem id_sequence (x : t α) : sequence (id.mk <$> x) = id.mk x := by
  simp [sequence, traverse_map, id_traverse] <;> rfl
#align traversable.id_sequence Traversable.id_sequence

theorem comp_sequence (x : t (F (G α))) : sequence (comp.mk <$> x) = Comp.mk (sequence <$> sequence x) := by
  simp [sequence, traverse_map] <;> rw [← comp_traverse] <;> simp [map_id]
#align traversable.comp_sequence Traversable.comp_sequence

theorem naturality' (η : ApplicativeTransformation F G) (x : t (F α)) : η (sequence x) = sequence (@η _ <$> x) := by
  simp [sequence, naturality, traverse_map]
#align traversable.naturality' Traversable.naturality'

@[functor_norm]
theorem traverse_id : traverse id.mk = (id.mk : t α → id (t α)) := by
  ext
  exact id_traverse _
#align traversable.traverse_id Traversable.traverse_id

@[functor_norm]
theorem traverse_comp (g : α → F β) (h : β → G γ) :
    traverse (comp.mk ∘ map h ∘ g) = (comp.mk ∘ map (traverse h) ∘ traverse g : t α → Comp F G (t γ)) := by
  ext
  exact comp_traverse _ _ _
#align traversable.traverse_comp Traversable.traverse_comp

theorem traverse_eq_map_id' (f : β → γ) : traverse (id.mk ∘ f) = id.mk ∘ (map f : t β → t γ) := by
  ext
  exact traverse_eq_map_id _ _
#align traversable.traverse_eq_map_id' Traversable.traverse_eq_map_id'

-- @[functor_norm]
theorem traverse_map' (g : α → β) (h : β → G γ) : traverse (h ∘ g) = (traverse h ∘ map g : t α → G (t γ)) := by
  ext
  rw [comp_app, traverse_map]
#align traversable.traverse_map' Traversable.traverse_map'

theorem map_traverse' (g : α → G β) (h : β → γ) : traverse (map h ∘ g) = (map (map h) ∘ traverse g : t α → G (t γ)) :=
  by
  ext
  rw [comp_app, map_traverse]
#align traversable.map_traverse' Traversable.map_traverse'

theorem naturality_pf (η : ApplicativeTransformation F G) (f : α → F β) :
    traverse (@η _ ∘ f) = @η _ ∘ (traverse f : t α → F (t β)) := by
  ext
  rw [comp_app, naturality]
#align traversable.naturality_pf Traversable.naturality_pf

end Traversable

