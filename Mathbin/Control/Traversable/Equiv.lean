/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module control.traversable.equiv
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Control.Traversable.Lemmas
import Mathbin.Logic.Equiv.Defs

/-!
# Transferring `traversable` instances along isomorphisms

This file allows to transfer `traversable` instances along isomorphisms.

## Main declarations

* `equiv.map`: Turns functorially a function `α → β` into a function `t' α → t' β` using the functor
  `t` and the equivalence `Π α, t α ≃ t' α`.
* `equiv.functor`: `equiv.map` as a functor.
* `equiv.traverse`: Turns traversably a function `α → m β` into a function `t' α → m (t' β)` using
  the traversable functor `t` and the equivalence `Π α, t α ≃ t' α`.
* `equiv.traversable`: `equiv.traverse` as a traversable functor.
* `equiv.is_lawful_traversable`: `equiv.traverse` as a lawful traversable functor.
-/


universe u

namespace Equiv

section Functor

parameter {t t' : Type u → Type u}

parameter (eqv : ∀ α, t α ≃ t' α)

variable [Functor t]

open Functor

/-- Given a functor `t`, a function `t' : Type u → Type u`, and
equivalences `t α ≃ t' α` for all `α`, then every function `α → β` can
be mapped to a function `t' α → t' β` functorially (see
`equiv.functor`). -/
protected def map {α β : Type u} (f : α → β) (x : t' α) : t' β :=
  eqv β <| map f ((eqv α).symm x)
#align equiv.map Equiv.map

/-- The function `equiv.map` transfers the functoriality of `t` to
`t'` using the equivalences `eqv`.  -/
protected def functor : Functor t' where map := @Equiv.map _
#align equiv.functor Equiv.functor

variable [IsLawfulFunctor t]

protected theorem id_map {α : Type u} (x : t' α) : Equiv.map id x = x := by simp [Equiv.map, id_map]
#align equiv.id_map Equiv.id_map

protected theorem comp_map {α β γ : Type u} (g : α → β) (h : β → γ) (x : t' α) :
    Equiv.map (h ∘ g) x = Equiv.map h (Equiv.map g x) := by simp [Equiv.map] <;> apply comp_map
#align equiv.comp_map Equiv.comp_map

protected theorem is_lawful_functor : @IsLawfulFunctor _ Equiv.functor :=
  { id_map := @Equiv.id_map _ _
    comp_map := @Equiv.comp_map _ _ }
#align equiv.is_lawful_functor Equiv.is_lawful_functor

protected theorem is_lawful_functor' [F : Functor t']
    (h₀ : ∀ {α β} (f : α → β), Functor.map f = Equiv.map f)
    (h₁ : ∀ {α β} (f : β), Functor.mapConst f = (Equiv.map ∘ Function.const α) f) :
    IsLawfulFunctor t' := by
  have : F = Equiv.functor := by 
    cases F
    dsimp [Equiv.functor]
    congr <;> ext <;> [rw [← h₀], rw [← h₁]]
  subst this
  exact Equiv.is_lawful_functor
#align equiv.is_lawful_functor' Equiv.is_lawful_functor'

end Functor

section Traversable

parameter {t t' : Type u → Type u}

parameter (eqv : ∀ α, t α ≃ t' α)

variable [Traversable t]

variable {m : Type u → Type u} [Applicative m]

variable {α β : Type u}

/-- Like `equiv.map`, a function `t' : Type u → Type u` can be given
the structure of a traversable functor using a traversable functor
`t'` and equivalences `t α ≃ t' α` for all α.  See `equiv.traversable`. -/
protected def traverse (f : α → m β) (x : t' α) : m (t' β) :=
  eqv β <$> traverse f ((eqv α).symm x)
#align equiv.traverse Equiv.traverse

/-- The function `equiv.traverse` transfers a traversable functor
instance across the equivalences `eqv`. -/
protected def traversable :
    Traversable t' where 
  toFunctor := Equiv.functor eqv
  traverse := @Equiv.traverse _
#align equiv.traversable Equiv.traversable

end Traversable

section Equiv

parameter {t t' : Type u → Type u}

parameter (eqv : ∀ α, t α ≃ t' α)

variable [Traversable t] [IsLawfulTraversable t]

variable {F G : Type u → Type u} [Applicative F] [Applicative G]

variable [LawfulApplicative F] [LawfulApplicative G]

variable (η : ApplicativeTransformation F G)

variable {α β γ : Type u}

open IsLawfulTraversable Functor

protected theorem id_traverse (x : t' α) : Equiv.traverse eqv id.mk x = x := by
  simp! [Equiv.traverse, idBind, id_traverse, Functor.map, functor_norm]
#align equiv.id_traverse Equiv.id_traverse

protected theorem traverse_eq_map_id (f : α → β) (x : t' α) :
    Equiv.traverse eqv (id.mk ∘ f) x = id.mk (Equiv.map eqv f x) := by
  simp [Equiv.traverse, traverse_eq_map_id, functor_norm] <;> rfl
#align equiv.traverse_eq_map_id Equiv.traverse_eq_map_id

protected theorem comp_traverse (f : β → F γ) (g : α → G β) (x : t' α) :
    Equiv.traverse eqv (comp.mk ∘ Functor.map f ∘ g) x =
      Comp.mk (Equiv.traverse eqv f <$> Equiv.traverse eqv g x) :=
  by simp [Equiv.traverse, comp_traverse, functor_norm] <;> congr <;> ext <;> simp
#align equiv.comp_traverse Equiv.comp_traverse

protected theorem naturality (f : α → F β) (x : t' α) :
    η (Equiv.traverse eqv f x) = Equiv.traverse eqv (@η _ ∘ f) x := by
  simp only [Equiv.traverse, functor_norm]
#align equiv.naturality Equiv.naturality

/-- The fact that `t` is a lawful traversable functor carries over the
equivalences to `t'`, with the traversable functor structure given by
`equiv.traversable`. -/
protected def isLawfulTraversable :
    @IsLawfulTraversable t'
      (Equiv.traversable
        eqv) where 
  to_is_lawful_functor := @Equiv.is_lawful_functor _ _ eqv _ _
  id_traverse := @Equiv.id_traverse _ _
  comp_traverse := @Equiv.comp_traverse _ _
  traverse_eq_map_id := @Equiv.traverse_eq_map_id _ _
  naturality := @Equiv.naturality _ _
#align equiv.is_lawful_traversable Equiv.isLawfulTraversable

/-- If the `traversable t'` instance has the properties that `map`,
`map_const`, and `traverse` are equal to the ones that come from
carrying the traversable functor structure from `t` over the
equivalences, then the fact that `t` is a lawful traversable functor
carries over as well. -/
protected def isLawfulTraversable' [_i : Traversable t']
    (h₀ : ∀ {α β} (f : α → β), map f = Equiv.map eqv f)
    (h₁ : ∀ {α β} (f : β), mapConst f = (Equiv.map eqv ∘ Function.const α) f)
    (h₂ :
      ∀ {F : Type u → Type u} [Applicative F],
        ∀ [LawfulApplicative F] {α β} (f : α → F β), traverse f = Equiv.traverse eqv f) :
    IsLawfulTraversable t' :=
  by
  -- we can't use the same approach as for `is_lawful_functor'` because
    -- h₂ needs a `is_lawful_applicative` assumption
    refine' { to_is_lawful_functor := Equiv.is_lawful_functor' eqv @h₀ @h₁.. } <;>
    intros
  · rw [h₂, Equiv.id_traverse]
    infer_instance
  · rw [h₂, Equiv.comp_traverse f g x, h₂]
    congr
    rw [h₂]
    all_goals infer_instance
  · rw [h₂, Equiv.traverse_eq_map_id, h₀] <;> infer_instance
  · rw [h₂, Equiv.naturality, h₂] <;> infer_instance
#align equiv.is_lawful_traversable' Equiv.isLawfulTraversable'

end Equiv

end Equiv

