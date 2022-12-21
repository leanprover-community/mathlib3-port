/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro, Kyle Miller

! This file was ported from Lean 3 source module data.set.finite
! leanprover-community/mathlib commit 0743cc5d9d86bcd1bba10f480e948a257d65056f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finset.Sort
import Mathbin.Data.Set.Functor
import Mathbin.Data.Finite.Basic

/-!
# Finite sets

This file defines predicates for finite and infinite sets and provides
`fintype` instances for many set constructions. It also proves basic facts
about finite sets and gives ways to manipulate `set.finite` expressions.

## Main definitions

* `set.finite : set α → Prop`
* `set.infinite : set α → Prop`
* `set.to_finite` to prove `set.finite` for a `set` from a `finite` instance.
* `set.finite.to_finset` to noncomputably produce a `finset` from a `set.finite` proof.
  (See `set.to_finset` for a computable version.)

## Implementation

A finite set is defined to be a set whose coercion to a type has a `fintype` instance.
Since `set.finite` is `Prop`-valued, this is the mere fact that the `fintype` instance
exists.

There are two components to finiteness constructions. The first is `fintype` instances for each
construction. This gives a way to actually compute a `finset` that represents the set, and these
may be accessed using `set.to_finset`. This gets the `finset` in the correct form, since otherwise
`finset.univ : finset s` is a `finset` for the subtype for `s`. The second component is
"constructors" for `set.finite` that give proofs that `fintype` instances exist classically given
other `set.finite` proofs. Unlike the `fintype` instances, these *do not* use any decidability
instances since they do not compute anything.

## Tags

finite sets
-/


open Set Function

universe u v w x

variable {α : Type u} {β : Type v} {ι : Sort w} {γ : Type x}

namespace Set

/-- A set is finite if there is a `finset` with the same elements.
This is represented as there being a `fintype` instance for the set
coerced to a type.

Note: this is a custom inductive type rather than `nonempty (fintype s)`
so that it won't be frozen as a local instance. -/
@[protected]
inductive Finite (s : Set α) : Prop
  | intro : Fintype s → Finite
#align set.finite Set.Finite

-- The `protected` attribute does not take effect within the same namespace block.
end Set

namespace Set

theorem finite_def {s : Set α} : s.Finite ↔ Nonempty (Fintype s) :=
  ⟨fun ⟨h⟩ => ⟨h⟩, fun ⟨h⟩ => ⟨h⟩⟩
#align set.finite_def Set.finite_def

alias finite_def ↔ finite.nonempty_fintype _

theorem finite_coe_iff {s : Set α} : Finite s ↔ s.Finite := by
  rw [finite_iff_nonempty_fintype, finite_def]
#align set.finite_coe_iff Set.finite_coe_iff

/-- Constructor for `set.finite` using a `finite` instance. -/
theorem to_finite (s : Set α) [Finite s] : s.Finite :=
  finite_coe_iff.mp ‹_›
#align set.to_finite Set.to_finite

/-- Construct a `finite` instance for a `set` from a `finset` with the same elements. -/
protected theorem Finite.of_finset {p : Set α} (s : Finset α) (H : ∀ x, x ∈ s ↔ x ∈ p) : p.Finite :=
  ⟨Fintype.ofFinset s H⟩
#align set.finite.of_finset Set.Finite.of_finset

/-- Projection of `set.finite` to its `finite` instance.
This is intended to be used with dot notation.
See also `set.finite.fintype` and `set.finite.nonempty_fintype`. -/
protected theorem Finite.to_subtype {s : Set α} (h : s.Finite) : Finite s :=
  finite_coe_iff.mpr h
#align set.finite.to_subtype Set.Finite.to_subtype

/-- A finite set coerced to a type is a `fintype`.
This is the `fintype` projection for a `set.finite`.

Note that because `finite` isn't a typeclass, this definition will not fire if it
is made into an instance -/
noncomputable def Finite.fintype {s : Set α} (h : s.Finite) : Fintype s :=
  h.nonempty_fintype.some
#align set.finite.fintype Set.Finite.fintype

/-- Using choice, get the `finset` that represents this `set.` -/
noncomputable def Finite.toFinset {s : Set α} (h : s.Finite) : Finset α :=
  @Set.toFinset _ _ h.Fintype
#align set.finite.to_finset Set.Finite.toFinset

theorem Finite.exists_finset {s : Set α} (h : s.Finite) :
    ∃ s' : Finset α, ∀ a : α, a ∈ s' ↔ a ∈ s := by
  cases h
  exact ⟨s.to_finset, fun _ => mem_to_finset⟩
#align set.finite.exists_finset Set.Finite.exists_finset

theorem Finite.exists_finset_coe {s : Set α} (h : s.Finite) : ∃ s' : Finset α, ↑s' = s := by
  cases h
  exact ⟨s.to_finset, s.coe_to_finset⟩
#align set.finite.exists_finset_coe Set.Finite.exists_finset_coe

/-- Finite sets can be lifted to finsets. -/
instance : CanLift (Set α) (Finset α) coe Set.Finite where prf s hs := hs.exists_finset_coe

/-- A set is infinite if it is not finite.

This is protected so that it does not conflict with global `infinite`. -/
protected def Infinite (s : Set α) : Prop :=
  ¬s.Finite
#align set.infinite Set.Infinite

@[simp]
theorem not_infinite {s : Set α} : ¬s.Infinite ↔ s.Finite :=
  not_not
#align set.not_infinite Set.not_infinite

/-- See also `finite_or_infinite`, `fintype_or_infinite`. -/
protected theorem finite_or_infinite (s : Set α) : s.Finite ∨ s.Infinite :=
  em _
#align set.finite_or_infinite Set.finite_or_infinite

/-! ### Basic properties of `set.finite.to_finset` -/


section FiniteToFinset

variable {s t : Set α}

@[simp]
theorem Finite.coe_to_finset {s : Set α} (h : s.Finite) : (h.toFinset : Set α) = s :=
  @Set.coe_to_finset _ s h.Fintype
#align set.finite.coe_to_finset Set.Finite.coe_to_finset

@[simp]
theorem Finite.mem_to_finset {s : Set α} (h : s.Finite) {a : α} : a ∈ h.toFinset ↔ a ∈ s :=
  @mem_to_finset _ _ h.Fintype _
#align set.finite.mem_to_finset Set.Finite.mem_to_finset

@[simp]
theorem Finite.nonempty_to_finset {s : Set α} (h : s.Finite) : h.toFinset.Nonempty ↔ s.Nonempty :=
  by rw [← Finset.coe_nonempty, finite.coe_to_finset]
#align set.finite.nonempty_to_finset Set.Finite.nonempty_to_finset

@[simp]
theorem Finite.coe_sort_to_finset {s : Set α} (h : s.Finite) : (h.toFinset : Type _) = s := by
  rw [← Finset.coe_sort_coe _, h.coe_to_finset]
#align set.finite.coe_sort_to_finset Set.Finite.coe_sort_to_finset

@[simp]
theorem finite_empty_to_finset (h : (∅ : Set α).Finite) : h.toFinset = ∅ := by
  rw [← Finset.coe_inj, h.coe_to_finset, Finset.coe_empty]
#align set.finite_empty_to_finset Set.finite_empty_to_finset

@[simp]
theorem finite_univ_to_finset [Fintype α] (h : (Set.univ : Set α).Finite) :
    h.toFinset = Finset.univ :=
  Finset.ext <| by simp
#align set.finite_univ_to_finset Set.finite_univ_to_finset

@[simp]
theorem Finite.to_finset_inj {s t : Set α} {hs : s.Finite} {ht : t.Finite} :
    hs.toFinset = ht.toFinset ↔ s = t := by simp only [← Finset.coe_inj, finite.coe_to_finset]
#align set.finite.to_finset_inj Set.Finite.to_finset_inj

theorem subset_to_finset_iff {s : Finset α} {t : Set α} (ht : t.Finite) :
    s ⊆ ht.toFinset ↔ ↑s ⊆ t := by rw [← Finset.coe_subset, ht.coe_to_finset]
#align set.subset_to_finset_iff Set.subset_to_finset_iff

@[simp]
theorem finite_to_finset_eq_empty_iff {s : Set α} {h : s.Finite} : h.toFinset = ∅ ↔ s = ∅ := by
  simp only [← Finset.coe_inj, finite.coe_to_finset, Finset.coe_empty]
#align set.finite_to_finset_eq_empty_iff Set.finite_to_finset_eq_empty_iff

@[simp, mono]
theorem Finite.to_finset_subset {hs : s.Finite} {ht : t.Finite} :
    hs.toFinset ⊆ ht.toFinset ↔ s ⊆ t := by simp only [← Finset.coe_subset, finite.coe_to_finset]
#align set.finite.to_finset_subset Set.Finite.to_finset_subset

@[simp, mono]
theorem Finite.to_finset_ssubset {hs : s.Finite} {ht : t.Finite} :
    hs.toFinset ⊂ ht.toFinset ↔ s ⊂ t := by simp only [← Finset.coe_ssubset, finite.coe_to_finset]
#align set.finite.to_finset_ssubset Set.Finite.to_finset_ssubset

end FiniteToFinset

/-! ### Fintype instances

Every instance here should have a corresponding `set.finite` constructor in the next section.
 -/


section FintypeInstances

instance fintypeUniv [Fintype α] : Fintype (@univ α) :=
  Fintype.ofEquiv α (Equiv.Set.univ α).symm
#align set.fintype_univ Set.fintypeUniv

/-- If `(set.univ : set α)` is finite then `α` is a finite type. -/
noncomputable def fintypeOfFiniteUniv (H : (univ : Set α).Finite) : Fintype α :=
  @Fintype.ofEquiv _ (univ : Set α) H.Fintype (Equiv.Set.univ _)
#align set.fintype_of_finite_univ Set.fintypeOfFiniteUniv

instance fintypeUnion [DecidableEq α] (s t : Set α) [Fintype s] [Fintype t] :
    Fintype (s ∪ t : Set α) :=
  Fintype.ofFinset (s.toFinset ∪ t.toFinset) <| by simp
#align set.fintype_union Set.fintypeUnion

instance fintypeSep (s : Set α) (p : α → Prop) [Fintype s] [DecidablePred p] :
    Fintype ({ a ∈ s | p a } : Set α) :=
  Fintype.ofFinset (s.toFinset.filter p) <| by simp
#align set.fintype_sep Set.fintypeSep

instance fintypeInter (s t : Set α) [DecidableEq α] [Fintype s] [Fintype t] :
    Fintype (s ∩ t : Set α) :=
  Fintype.ofFinset (s.toFinset ∩ t.toFinset) <| by simp
#align set.fintype_inter Set.fintypeInter

/-- A `fintype` instance for set intersection where the left set has a `fintype` instance. -/
instance fintypeInterOfLeft (s t : Set α) [Fintype s] [DecidablePred (· ∈ t)] :
    Fintype (s ∩ t : Set α) :=
  Fintype.ofFinset (s.toFinset.filter (· ∈ t)) <| by simp
#align set.fintype_inter_of_left Set.fintypeInterOfLeft

/-- A `fintype` instance for set intersection where the right set has a `fintype` instance. -/
instance fintypeInterOfRight (s t : Set α) [Fintype t] [DecidablePred (· ∈ s)] :
    Fintype (s ∩ t : Set α) :=
  Fintype.ofFinset (t.toFinset.filter (· ∈ s)) <| by simp [and_comm']
#align set.fintype_inter_of_right Set.fintypeInterOfRight

/-- A `fintype` structure on a set defines a `fintype` structure on its subset. -/
def fintypeSubset (s : Set α) {t : Set α} [Fintype s] [DecidablePred (· ∈ t)] (h : t ⊆ s) :
    Fintype t := by 
  rw [← inter_eq_self_of_subset_right h]
  apply Set.fintypeInterOfLeft
#align set.fintype_subset Set.fintypeSubset

instance fintypeDiff [DecidableEq α] (s t : Set α) [Fintype s] [Fintype t] :
    Fintype (s \ t : Set α) :=
  Fintype.ofFinset (s.toFinset \ t.toFinset) <| by simp
#align set.fintype_diff Set.fintypeDiff

instance fintypeDiffLeft (s t : Set α) [Fintype s] [DecidablePred (· ∈ t)] :
    Fintype (s \ t : Set α) :=
  Set.fintypeSep s (· ∈ tᶜ)
#align set.fintype_diff_left Set.fintypeDiffLeft

/- warning: set.fintype_Union clashes with set.fintype_union -> Set.fintypeUnion
warning: set.fintype_Union -> Set.fintypeUnion is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {ι : Sort.{w}} [_inst_1 : DecidableEq.{succ u} α] [_inst_2 : Fintype.{w} (PLift.{w} ι)] (f : ι -> (Set.{u} α)) [_inst_3 : forall (i : ι), Fintype.{u} (coeSort.{max (succ u) 1, succ (succ u)} (Set.{u} α) Type.{u} (Set.hasCoeToSort.{u} α) (f i))], Fintype.{u} (coeSort.{max (succ u) 1, succ (succ u)} (Set.{u} α) Type.{u} (Set.hasCoeToSort.{u} α) (Set.union.{u, w} α ι (fun (i : ι) => f i)))
but is expected to have type
  forall {α : Type.{u}} [ι : DecidableEq.{succ u} α] (_inst_1 : Set.{u} α) (_inst_2 : Set.{u} α) [f : Fintype.{u} (coeSort.{max (succ u) 1, succ (succ u)} (Set.{u} α) Type.{u} (Set.hasCoeToSort.{u} α) _inst_1)] [_inst_3 : Fintype.{u} (coeSort.{max (succ u) 1, succ (succ u)} (Set.{u} α) Type.{u} (Set.hasCoeToSort.{u} α) _inst_2)], Fintype.{u} (coeSort.{max (succ u) 1, succ (succ u)} (Set.{u} α) Type.{u} (Set.hasCoeToSort.{u} α) (Union.union.{u} (Set.{u} α) (Set.hasUnion.{u} α) _inst_1 _inst_2))
Case conversion may be inaccurate. Consider using '#align set.fintype_Union Set.fintypeUnionₓ'. -/
instance fintypeUnion [DecidableEq α] [Fintype (PLift ι)] (f : ι → Set α) [∀ i, Fintype (f i)] :
    Fintype (⋃ i, f i) :=
  Fintype.ofFinset (Finset.univ.bUnion fun i : PLift ι => (f i.down).toFinset) <| by simp
#align set.fintype_Union Set.fintypeUnion

instance fintypeSUnion [DecidableEq α] {s : Set (Set α)} [Fintype s]
    [H : ∀ t : s, Fintype (t : Set α)] : Fintype (⋃₀s) := by
  rw [sUnion_eq_Union]
  exact @Set.fintypeUnion _ _ _ _ _ H
#align set.fintype_sUnion Set.fintypeSUnion

/-- A union of sets with `fintype` structure over a set with `fintype` structure has a `fintype`
structure. -/
def fintypeBUnion [DecidableEq α] {ι : Type _} (s : Set ι) [Fintype s] (t : ι → Set α)
    (H : ∀ i ∈ s, Fintype (t i)) : Fintype (⋃ x ∈ s, t x) :=
  Fintype.ofFinset
      (s.toFinset.attach.bUnion fun x =>
        haveI := H x (by simpa using x.property)
        (t x).toFinset) <|
    by simp
#align set.fintype_bUnion Set.fintypeBUnion

instance fintypeBUnion' [DecidableEq α] {ι : Type _} (s : Set ι) [Fintype s] (t : ι → Set α)
    [∀ i, Fintype (t i)] : Fintype (⋃ x ∈ s, t x) :=
  Fintype.ofFinset (s.toFinset.bUnion fun x => (t x).toFinset) <| by simp
#align set.fintype_bUnion' Set.fintypeBUnion'

/-- If `s : set α` is a set with `fintype` instance and `f : α → set β` is a function such that
each `f a`, `a ∈ s`, has a `fintype` structure, then `s >>= f` has a `fintype` structure. -/
def fintypeBind {α β} [DecidableEq β] (s : Set α) [Fintype s] (f : α → Set β)
    (H : ∀ a ∈ s, Fintype (f a)) : Fintype (s >>= f) :=
  Set.fintypeBUnion s f H
#align set.fintype_bind Set.fintypeBind

instance fintypeBind' {α β} [DecidableEq β] (s : Set α) [Fintype s] (f : α → Set β)
    [H : ∀ a, Fintype (f a)] : Fintype (s >>= f) :=
  Set.fintypeBUnion' s f
#align set.fintype_bind' Set.fintypeBind'

instance fintypeEmpty : Fintype (∅ : Set α) :=
  Fintype.ofFinset ∅ <| by simp
#align set.fintype_empty Set.fintypeEmpty

instance fintypeSingleton (a : α) : Fintype ({a} : Set α) :=
  Fintype.ofFinset {a} <| by simp
#align set.fintype_singleton Set.fintypeSingleton

instance fintypePure : ∀ a : α, Fintype (pure a : Set α) :=
  Set.fintypeSingleton
#align set.fintype_pure Set.fintypePure

/-- A `fintype` instance for inserting an element into a `set` using the
corresponding `insert` function on `finset`. This requires `decidable_eq α`.
There is also `set.fintype_insert'` when `a ∈ s` is decidable. -/
instance fintypeInsert (a : α) (s : Set α) [DecidableEq α] [Fintype s] :
    Fintype (insert a s : Set α) :=
  Fintype.ofFinset (insert a s.toFinset) <| by simp
#align set.fintype_insert Set.fintypeInsert

/-- A `fintype` structure on `insert a s` when inserting a new element. -/
def fintypeInsertOfNotMem {a : α} (s : Set α) [Fintype s] (h : a ∉ s) :
    Fintype (insert a s : Set α) :=
  Fintype.ofFinset ⟨a ::ₘ s.toFinset.1, s.toFinset.Nodup.cons (by simp [h])⟩ <| by simp
#align set.fintype_insert_of_not_mem Set.fintypeInsertOfNotMem

/-- A `fintype` structure on `insert a s` when inserting a pre-existing element. -/
def fintypeInsertOfMem {a : α} (s : Set α) [Fintype s] (h : a ∈ s) : Fintype (insert a s : Set α) :=
  Fintype.ofFinset s.toFinset <| by simp [h]
#align set.fintype_insert_of_mem Set.fintypeInsertOfMem

/-- The `set.fintype_insert` instance requires decidable equality, but when `a ∈ s`
is decidable for this particular `a` we can still get a `fintype` instance by using
`set.fintype_insert_of_not_mem` or `set.fintype_insert_of_mem`.

This instance pre-dates `set.fintype_insert`, and it is less efficient.
When `decidable_mem_of_fintype` is made a local instance, then this instance would
override `set.fintype_insert` if not for the fact that its priority has been
adjusted. See Note [lower instance priority]. -/
instance (priority := 100) fintypeInsert' (a : α) (s : Set α) [Decidable <| a ∈ s] [Fintype s] :
    Fintype (insert a s : Set α) :=
  if h : a ∈ s then fintypeInsertOfMem s h else fintypeInsertOfNotMem s h
#align set.fintype_insert' Set.fintypeInsert'

instance fintypeImage [DecidableEq β] (s : Set α) (f : α → β) [Fintype s] : Fintype (f '' s) :=
  Fintype.ofFinset (s.toFinset.image f) <| by simp
#align set.fintype_image Set.fintypeImage

/-- If a function `f` has a partial inverse and sends a set `s` to a set with `[fintype]` instance,
then `s` has a `fintype` structure as well. -/
def fintypeOfFintypeImage (s : Set α) {f : α → β} {g} (I : IsPartialInv f g) [Fintype (f '' s)] :
    Fintype s :=
  (Fintype.ofFinset ⟨_, (f '' s).toFinset.2.filterMap g <| injective_of_isPartialInv_right I⟩)
    fun a => by
    suffices (∃ b x, f x = b ∧ g b = some a ∧ x ∈ s) ↔ a ∈ s by
      simpa [exists_and_distrib_left.symm, and_comm, and_left_comm, and_assoc]
    rw [exists_swap]
    suffices (∃ x, x ∈ s ∧ g (f x) = some a) ↔ a ∈ s by simpa [and_comm, and_left_comm, and_assoc]
    simp [I _, (injective_of_partial_inv I).eq_iff]
#align set.fintype_of_fintype_image Set.fintypeOfFintypeImage

instance fintypeRange [DecidableEq α] (f : ι → α) [Fintype (PLift ι)] : Fintype (range f) :=
  Fintype.ofFinset (Finset.univ.image <| f ∘ PLift.down) <| by simp [equiv.plift.exists_congr_left]
#align set.fintype_range Set.fintypeRange

instance fintypeMap {α β} [DecidableEq β] :
    ∀ (s : Set α) (f : α → β) [Fintype s], Fintype (f <$> s) :=
  Set.fintypeImage
#align set.fintype_map Set.fintypeMap

instance fintypeLtNat (n : ℕ) : Fintype { i | i < n } :=
  Fintype.ofFinset (Finset.range n) <| by simp
#align set.fintype_lt_nat Set.fintypeLtNat

instance fintypeLeNat (n : ℕ) : Fintype { i | i ≤ n } := by
  simpa [Nat.lt_succ_iff] using Set.fintypeLtNat (n + 1)
#align set.fintype_le_nat Set.fintypeLeNat

/-- This is not an instance so that it does not conflict with the one
in src/order/locally_finite. -/
def Nat.fintypeIio (n : ℕ) : Fintype (Iio n) :=
  Set.fintypeLtNat n
#align set.nat.fintype_Iio Set.Nat.fintypeIio

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance fintypeProd (s : Set α) (t : Set β) [Fintype s] [Fintype t] :
    Fintype (s ×ˢ t : Set (α × β)) :=
  Fintype.ofFinset (s.toFinset ×ˢ t.toFinset) <| by simp
#align set.fintype_prod Set.fintypeProd

instance fintypeOffDiag [DecidableEq α] (s : Set α) [Fintype s] : Fintype s.offDiag :=
  Fintype.ofFinset s.toFinset.offDiag <| by simp
#align set.fintype_off_diag Set.fintypeOffDiag

/-- `image2 f s t` is `fintype` if `s` and `t` are. -/
instance fintypeImage2 [DecidableEq γ] (f : α → β → γ) (s : Set α) (t : Set β) [hs : Fintype s]
    [ht : Fintype t] : Fintype (image2 f s t : Set γ) := by
  rw [← image_prod]
  apply Set.fintypeImage
#align set.fintype_image2 Set.fintypeImage2

instance fintypeSeq [DecidableEq β] (f : Set (α → β)) (s : Set α) [Fintype f] [Fintype s] :
    Fintype (f.seq s) := by 
  rw [seq_def]
  apply Set.fintypeBUnion'
#align set.fintype_seq Set.fintypeSeq

instance fintypeSeq' {α β : Type u} [DecidableEq β] (f : Set (α → β)) (s : Set α) [Fintype f]
    [Fintype s] : Fintype (f <*> s) :=
  Set.fintypeSeq f s
#align set.fintype_seq' Set.fintypeSeq'

instance fintypeMemFinset (s : Finset α) : Fintype { a | a ∈ s } :=
  Finset.fintypeCoeSort s
#align set.fintype_mem_finset Set.fintypeMemFinset

end FintypeInstances

end Set

/-! ### Finset -/


namespace Finset

/-- Gives a `set.finite` for the `finset` coerced to a `set`.
This is a wrapper around `set.to_finite`. -/
theorem finite_to_set (s : Finset α) : (s : Set α).Finite :=
  Set.to_finite _
#align finset.finite_to_set Finset.finite_to_set

@[simp]
theorem finite_to_set_to_finset (s : Finset α) : s.finite_to_set.toFinset = s := by
  ext
  rw [Set.Finite.mem_to_finset, mem_coe]
#align finset.finite_to_set_to_finset Finset.finite_to_set_to_finset

end Finset

namespace Multiset

theorem finite_to_set (s : Multiset α) : { x | x ∈ s }.Finite := by
  classical simpa only [← Multiset.mem_to_finset] using s.to_finset.finite_to_set
#align multiset.finite_to_set Multiset.finite_to_set

@[simp]
theorem finite_to_set_to_finset [DecidableEq α] (s : Multiset α) :
    s.finite_to_set.toFinset = s.toFinset := by 
  ext x
  simp
#align multiset.finite_to_set_to_finset Multiset.finite_to_set_to_finset

end Multiset

theorem List.finite_to_set (l : List α) : { x | x ∈ l }.Finite :=
  (show Multiset α from ⟦l⟧).finite_to_set
#align list.finite_to_set List.finite_to_set

/-! ### Finite instances

There is seemingly some overlap between the following instances and the `fintype` instances
in `data.set.finite`. While every `fintype` instance gives a `finite` instance, those
instances that depend on `fintype` or `decidable` instances need an additional `finite` instance
to be able to generally apply.

Some set instances do not appear here since they are consequences of others, for example
`subtype.finite` for subsets of a finite type.
-/


namespace Finite.Set

open Classical

example {s : Set α} [Finite α] : Finite s :=
  inferInstance

example : Finite (∅ : Set α) :=
  inferInstance

example (a : α) : Finite ({a} : Set α) :=
  inferInstance

instance finite_union (s t : Set α) [Finite s] [Finite t] : Finite (s ∪ t : Set α) := by
  cases nonempty_fintype s
  cases nonempty_fintype t
  infer_instance
#align finite.set.finite_union Finite.Set.finite_union

instance finite_sep (s : Set α) (p : α → Prop) [Finite s] : Finite ({ a ∈ s | p a } : Set α) := by
  cases nonempty_fintype s
  infer_instance
#align finite.set.finite_sep Finite.Set.finite_sep

protected theorem subset (s : Set α) {t : Set α} [Finite s] (h : t ⊆ s) : Finite t := by
  rw [← sep_eq_of_subset h]
  infer_instance
#align finite.set.subset Finite.Set.subset

instance finite_inter_of_right (s t : Set α) [Finite t] : Finite (s ∩ t : Set α) :=
  Finite.Set.subset t (inter_subset_right s t)
#align finite.set.finite_inter_of_right Finite.Set.finite_inter_of_right

instance finite_inter_of_left (s t : Set α) [Finite s] : Finite (s ∩ t : Set α) :=
  Finite.Set.subset s (inter_subset_left s t)
#align finite.set.finite_inter_of_left Finite.Set.finite_inter_of_left

instance finite_diff (s t : Set α) [Finite s] : Finite (s \ t : Set α) :=
  Finite.Set.subset s (diff_subset s t)
#align finite.set.finite_diff Finite.Set.finite_diff

instance finite_range (f : ι → α) [Finite ι] : Finite (range f) := by
  haveI := Fintype.ofFinite (PLift ι)
  infer_instance
#align finite.set.finite_range Finite.Set.finite_range

instance finite_Union [Finite ι] (f : ι → Set α) [∀ i, Finite (f i)] : Finite (⋃ i, f i) := by
  rw [Union_eq_range_psigma]
  apply Set.finite_range
#align finite.set.finite_Union Finite.Set.finite_Union

instance finite_sUnion {s : Set (Set α)} [Finite s] [H : ∀ t : s, Finite (t : Set α)] :
    Finite (⋃₀s) := by 
  rw [sUnion_eq_Union]
  exact @Finite.Set.finite_Union _ _ _ _ H
#align finite.set.finite_sUnion Finite.Set.finite_sUnion

theorem finite_bUnion {ι : Type _} (s : Set ι) [Finite s] (t : ι → Set α)
    (H : ∀ i ∈ s, Finite (t i)) : Finite (⋃ x ∈ s, t x) := by
  rw [bUnion_eq_Union]
  haveI : ∀ i : s, Finite (t i) := fun i => H i i.property
  infer_instance
#align finite.set.finite_bUnion Finite.Set.finite_bUnion

instance finite_bUnion' {ι : Type _} (s : Set ι) [Finite s] (t : ι → Set α) [∀ i, Finite (t i)] :
    Finite (⋃ x ∈ s, t x) :=
  finite_bUnion s t fun i h => inferInstance
#align finite.set.finite_bUnion' Finite.Set.finite_bUnion'

/-- Example: `finite (⋃ (i < n), f i)` where `f : ℕ → set α` and `[∀ i, finite (f i)]`
(when given instances from `data.nat.interval`).
-/
instance finite_bUnion'' {ι : Type _} (p : ι → Prop) [h : Finite { x | p x }] (t : ι → Set α)
    [∀ i, Finite (t i)] : Finite (⋃ (x) (h : p x), t x) :=
  @Finite.Set.finite_bUnion' _ _ (setOf p) h t _
#align finite.set.finite_bUnion'' Finite.Set.finite_bUnion''

instance finite_Inter {ι : Sort _} [Nonempty ι] (t : ι → Set α) [∀ i, Finite (t i)] :
    Finite (⋂ i, t i) :=
  Finite.Set.subset (t <| Classical.arbitrary ι) (Inter_subset _ _)
#align finite.set.finite_Inter Finite.Set.finite_Inter

instance finite_insert (a : α) (s : Set α) [Finite s] : Finite (insert a s : Set α) :=
  Finite.Set.finite_union {a} s
#align finite.set.finite_insert Finite.Set.finite_insert

instance finite_image (s : Set α) (f : α → β) [Finite s] : Finite (f '' s) := by
  cases nonempty_fintype s
  infer_instance
#align finite.set.finite_image Finite.Set.finite_image

/- ./././Mathport/Syntax/Translate/Expr.lean:369:4: unsupported set replacement {(f x) | x : α} -/
instance finite_replacement [Finite α] (f : α → β) :
    Finite
      "./././Mathport/Syntax/Translate/Expr.lean:369:4: unsupported set replacement {(f x) | x : α}" :=
  Finite.Set.finite_range f
#align finite.set.finite_replacement Finite.Set.finite_replacement

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance finite_prod (s : Set α) (t : Set β) [Finite s] [Finite t] :
    Finite (s ×ˢ t : Set (α × β)) :=
  Finite.of_equiv _ (Equiv.Set.prod s t).symm
#align finite.set.finite_prod Finite.Set.finite_prod

instance finite_image2 (f : α → β → γ) (s : Set α) (t : Set β) [Finite s] [Finite t] :
    Finite (image2 f s t : Set γ) := by 
  rw [← image_prod]
  infer_instance
#align finite.set.finite_image2 Finite.Set.finite_image2

instance finite_seq (f : Set (α → β)) (s : Set α) [Finite f] [Finite s] : Finite (f.seq s) := by
  rw [seq_def]
  infer_instance
#align finite.set.finite_seq Finite.Set.finite_seq

end Finite.Set

namespace Set

/-! ### Constructors for `set.finite`

Every constructor here should have a corresponding `fintype` instance in the previous section
(or in the `fintype` module).

The implementation of these constructors ideally should be no more than `set.to_finite`,
after possibly setting up some `fintype` and classical `decidable` instances.
-/


section SetFiniteConstructors

@[nontriviality]
theorem Finite.of_subsingleton [Subsingleton α] (s : Set α) : s.Finite :=
  s.to_finite
#align set.finite.of_subsingleton Set.Finite.of_subsingleton

theorem finite_univ [Finite α] : (@univ α).Finite :=
  Set.to_finite _
#align set.finite_univ Set.finite_univ

theorem finite_univ_iff : (@univ α).Finite ↔ Finite α :=
  finite_coe_iff.symm.trans (Equiv.Set.univ α).finite_iff
#align set.finite_univ_iff Set.finite_univ_iff

alias finite_univ_iff ↔ _root_.finite.of_finite_univ _

theorem Finite.union {s t : Set α} (hs : s.Finite) (ht : t.Finite) : (s ∪ t).Finite := by
  cases hs
  cases ht
  apply to_finite
#align set.finite.union Set.Finite.union

theorem Finite.finite_of_compl {s : Set α} (hs : s.Finite) (hsc : sᶜ.Finite) : Finite α := by
  rw [← finite_univ_iff, ← union_compl_self s]
  exact hs.union hsc
#align set.finite.finite_of_compl Set.Finite.finite_of_compl

theorem Finite.sup {s t : Set α} : s.Finite → t.Finite → (s ⊔ t).Finite :=
  finite.union
#align set.finite.sup Set.Finite.sup

theorem Finite.sep {s : Set α} (hs : s.Finite) (p : α → Prop) : { a ∈ s | p a }.Finite := by
  cases hs
  apply to_finite
#align set.finite.sep Set.Finite.sep

theorem Finite.inter_of_left {s : Set α} (hs : s.Finite) (t : Set α) : (s ∩ t).Finite := by
  cases hs
  apply to_finite
#align set.finite.inter_of_left Set.Finite.inter_of_left

theorem Finite.inter_of_right {s : Set α} (hs : s.Finite) (t : Set α) : (t ∩ s).Finite := by
  cases hs
  apply to_finite
#align set.finite.inter_of_right Set.Finite.inter_of_right

theorem Finite.inf_of_left {s : Set α} (h : s.Finite) (t : Set α) : (s ⊓ t).Finite :=
  h.inter_of_left t
#align set.finite.inf_of_left Set.Finite.inf_of_left

theorem Finite.inf_of_right {s : Set α} (h : s.Finite) (t : Set α) : (t ⊓ s).Finite :=
  h.inter_of_right t
#align set.finite.inf_of_right Set.Finite.inf_of_right

theorem Finite.subset {s : Set α} (hs : s.Finite) {t : Set α} (ht : t ⊆ s) : t.Finite := by
  cases hs
  haveI := Finite.Set.subset _ ht
  apply to_finite
#align set.finite.subset Set.Finite.subset

theorem Finite.diff {s : Set α} (hs : s.Finite) (t : Set α) : (s \ t).Finite := by
  cases hs
  apply to_finite
#align set.finite.diff Set.Finite.diff

theorem Finite.of_diff {s t : Set α} (hd : (s \ t).Finite) (ht : t.Finite) : s.Finite :=
  (hd.union ht).Subset <| subset_diff_union _ _
#align set.finite.of_diff Set.Finite.of_diff

theorem finite_Union [Finite ι] {f : ι → Set α} (H : ∀ i, (f i).Finite) : (⋃ i, f i).Finite := by
  haveI := fun i => (H i).Fintype
  apply to_finite
#align set.finite_Union Set.finite_Union

theorem Finite.sUnion {s : Set (Set α)} (hs : s.Finite) (H : ∀ t ∈ s, Set.Finite t) :
    (⋃₀s).Finite := by 
  cases hs
  haveI := fun i : s => (H i i.2).to_subtype
  apply to_finite
#align set.finite.sUnion Set.Finite.sUnion

theorem Finite.bUnion {ι} {s : Set ι} (hs : s.Finite) {t : ι → Set α} (ht : ∀ i ∈ s, (t i).Finite) :
    (⋃ i ∈ s, t i).Finite := by
  classical 
    cases hs
    haveI := fintype_bUnion s t fun i hi => (ht i hi).Fintype
    apply to_finite
#align set.finite.bUnion Set.Finite.bUnion

/-- Dependent version of `finite.bUnion`. -/
theorem Finite.bUnion' {ι} {s : Set ι} (hs : s.Finite) {t : ∀ i ∈ s, Set α}
    (ht : ∀ i ∈ s, (t i ‹_›).Finite) : (⋃ i ∈ s, t i ‹_›).Finite := by
  cases hs
  rw [bUnion_eq_Union]
  apply finite_Union fun i : s => ht i.1 i.2
#align set.finite.bUnion' Set.Finite.bUnion'

theorem Finite.sInter {α : Type _} {s : Set (Set α)} {t : Set α} (ht : t ∈ s) (hf : t.Finite) :
    (⋂₀ s).Finite :=
  hf.Subset (sInter_subset_of_mem ht)
#align set.finite.sInter Set.Finite.sInter

theorem Finite.bind {α β} {s : Set α} {f : α → Set β} (h : s.Finite) (hf : ∀ a ∈ s, (f a).Finite) :
    (s >>= f).Finite :=
  h.bUnion hf
#align set.finite.bind Set.Finite.bind

@[simp]
theorem finite_empty : (∅ : Set α).Finite :=
  to_finite _
#align set.finite_empty Set.finite_empty

@[simp]
theorem finite_singleton (a : α) : ({a} : Set α).Finite :=
  to_finite _
#align set.finite_singleton Set.finite_singleton

theorem finite_pure (a : α) : (pure a : Set α).Finite :=
  to_finite _
#align set.finite_pure Set.finite_pure

@[simp]
theorem Finite.insert (a : α) {s : Set α} (hs : s.Finite) : (insert a s).Finite := by
  cases hs
  apply to_finite
#align set.finite.insert Set.Finite.insert

theorem Finite.image {s : Set α} (f : α → β) (hs : s.Finite) : (f '' s).Finite := by
  cases hs
  apply to_finite
#align set.finite.image Set.Finite.image

theorem finite_range (f : ι → α) [Finite ι] : (range f).Finite :=
  to_finite _
#align set.finite_range Set.finite_range

theorem Finite.dependent_image {s : Set α} (hs : s.Finite) (F : ∀ i ∈ s, β) :
    { y : β | ∃ (x : _)(hx : x ∈ s), y = F x hx }.Finite := by
  cases hs
  simpa [range, eq_comm] using finite_range fun x : s => F x x.2
#align set.finite.dependent_image Set.Finite.dependent_image

theorem Finite.map {α β} {s : Set α} : ∀ f : α → β, s.Finite → (f <$> s).Finite :=
  finite.image
#align set.finite.map Set.Finite.map

theorem Finite.of_finite_image {s : Set α} {f : α → β} (h : (f '' s).Finite) (hi : Set.InjOn f s) :
    s.Finite := by 
  cases h
  exact
    ⟨Fintype.ofInjective (fun a => (⟨f a.1, mem_image_of_mem f a.2⟩ : f '' s)) fun a b eq =>
        Subtype.eq <| hi a.2 b.2 <| Subtype.ext_iff_val.1 Eq⟩
#align set.finite.of_finite_image Set.Finite.of_finite_image

theorem finite_of_finite_preimage {f : α → β} {s : Set β} (h : (f ⁻¹' s).Finite)
    (hs : s ⊆ range f) : s.Finite := by
  rw [← image_preimage_eq_of_subset hs]
  exact finite.image f h
#align set.finite_of_finite_preimage Set.finite_of_finite_preimage

theorem Finite.of_preimage {f : α → β} {s : Set β} (h : (f ⁻¹' s).Finite) (hf : Surjective f) :
    s.Finite :=
  hf.image_preimage s ▸ h.image _
#align set.finite.of_preimage Set.Finite.of_preimage

theorem Finite.preimage {s : Set β} {f : α → β} (I : Set.InjOn f (f ⁻¹' s)) (h : s.Finite) :
    (f ⁻¹' s).Finite :=
  (h.Subset (image_preimage_subset f s)).of_finite_image I
#align set.finite.preimage Set.Finite.preimage

theorem Finite.preimage_embedding {s : Set β} (f : α ↪ β) (h : s.Finite) : (f ⁻¹' s).Finite :=
  h.Preimage fun _ _ _ _ h' => f.Injective h'
#align set.finite.preimage_embedding Set.Finite.preimage_embedding

theorem finite_lt_nat (n : ℕ) : Set.Finite { i | i < n } :=
  to_finite _
#align set.finite_lt_nat Set.finite_lt_nat

theorem finite_le_nat (n : ℕ) : Set.Finite { i | i ≤ n } :=
  to_finite _
#align set.finite_le_nat Set.finite_le_nat

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem Finite.prod {s : Set α} {t : Set β} (hs : s.Finite) (ht : t.Finite) :
    (s ×ˢ t : Set (α × β)).Finite := by 
  cases hs
  cases ht
  apply to_finite
#align set.finite.prod Set.Finite.prod

theorem Finite.off_diag {s : Set α} (hs : s.Finite) : s.offDiag.Finite := by
  classical 
    cases hs
    apply Set.to_finite
#align set.finite.off_diag Set.Finite.off_diag

theorem Finite.image2 (f : α → β → γ) {s : Set α} {t : Set β} (hs : s.Finite) (ht : t.Finite) :
    (image2 f s t).Finite := by 
  cases hs
  cases ht
  apply to_finite
#align set.finite.image2 Set.Finite.image2

theorem Finite.seq {f : Set (α → β)} {s : Set α} (hf : f.Finite) (hs : s.Finite) :
    (f.seq s).Finite := by
  classical 
    cases hf
    cases hs
    apply to_finite
#align set.finite.seq Set.Finite.seq

theorem Finite.seq' {α β : Type u} {f : Set (α → β)} {s : Set α} (hf : f.Finite) (hs : s.Finite) :
    (f <*> s).Finite :=
  hf.seq hs
#align set.finite.seq' Set.Finite.seq'

theorem finite_mem_finset (s : Finset α) : { a | a ∈ s }.Finite :=
  to_finite _
#align set.finite_mem_finset Set.finite_mem_finset

theorem Subsingleton.finite {s : Set α} (h : s.Subsingleton) : s.Finite :=
  h.induction_on finite_empty finite_singleton
#align set.subsingleton.finite Set.Subsingleton.finite

theorem finite_preimage_inl_and_inr {s : Set (Sum α β)} :
    (Sum.inl ⁻¹' s).Finite ∧ (Sum.inr ⁻¹' s).Finite ↔ s.Finite :=
  ⟨fun h => image_preimage_inl_union_image_preimage_inr s ▸ (h.1.image _).union (h.2.image _),
    fun h => ⟨h.Preimage (Sum.inl_injective.InjOn _), h.Preimage (Sum.inr_injective.InjOn _)⟩⟩
#align set.finite_preimage_inl_and_inr Set.finite_preimage_inl_and_inr

theorem exists_finite_iff_finset {p : Set α → Prop} :
    (∃ s : Set α, s.Finite ∧ p s) ↔ ∃ s : Finset α, p ↑s :=
  ⟨fun ⟨s, hs, hps⟩ => ⟨hs.toFinset, hs.coe_to_finset.symm ▸ hps⟩, fun ⟨s, hs⟩ =>
    ⟨s, s.finite_to_set, hs⟩⟩
#align set.exists_finite_iff_finset Set.exists_finite_iff_finset

/-- There are finitely many subsets of a given finite set -/
theorem Finite.finite_subsets {α : Type u} {a : Set α} (h : a.Finite) : { b | b ⊆ a }.Finite :=
  ⟨(Fintype.ofFinset ((Finset.powerset h.toFinset).map Finset.coeEmb.1)) fun s => by
      simpa [← @exists_finite_iff_finset α fun t => t ⊆ a ∧ t = s, subset_to_finset_iff, ←
        and_assoc] using h.subset⟩
#align set.finite.finite_subsets Set.Finite.finite_subsets

/-- Finite product of finite sets is finite -/
theorem Finite.pi {δ : Type _} [Finite δ] {κ : δ → Type _} {t : ∀ d, Set (κ d)}
    (ht : ∀ d, (t d).Finite) : (pi univ t).Finite := by
  cases nonempty_fintype δ
  lift t to ∀ d, Finset (κ d) using ht
  classical 
    rw [← Fintype.coe_pi_finset]
    apply Finset.finite_to_set
#align set.finite.pi Set.Finite.pi

/-- A finite union of finsets is finite. -/
theorem union_finset_finite_of_range_finite (f : α → Finset β) (h : (range f).Finite) :
    (⋃ a, (f a : Set β)).Finite := by 
  rw [← bUnion_range]
  exact h.bUnion fun y hy => y.finite_to_set
#align set.union_finset_finite_of_range_finite Set.union_finset_finite_of_range_finite

theorem finite_range_ite {p : α → Prop} [DecidablePred p] {f g : α → β} (hf : (range f).Finite)
    (hg : (range g).Finite) : (range fun x => if p x then f x else g x).Finite :=
  (hf.union hg).Subset range_ite_subset
#align set.finite_range_ite Set.finite_range_ite

theorem finite_range_const {c : β} : (range fun x : α => c).Finite :=
  (finite_singleton c).Subset range_const_subset
#align set.finite_range_const Set.finite_range_const

end SetFiniteConstructors

/-! ### Properties -/


instance Finite.inhabited : Inhabited { s : Set α // s.Finite } :=
  ⟨⟨∅, finite_empty⟩⟩
#align set.finite.inhabited Set.Finite.inhabited

@[simp]
theorem finite_union {s t : Set α} : (s ∪ t).Finite ↔ s.Finite ∧ t.Finite :=
  ⟨fun h => ⟨h.Subset (subset_union_left _ _), h.Subset (subset_union_right _ _)⟩, fun ⟨hs, ht⟩ =>
    hs.union ht⟩
#align set.finite_union Set.finite_union

theorem finite_image_iff {s : Set α} {f : α → β} (hi : InjOn f s) : (f '' s).Finite ↔ s.Finite :=
  ⟨fun h => h.of_finite_image hi, Finite.image _⟩
#align set.finite_image_iff Set.finite_image_iff

theorem univ_finite_iff_nonempty_fintype : (univ : Set α).Finite ↔ Nonempty (Fintype α) :=
  ⟨fun h => ⟨fintypeOfFiniteUniv h⟩, fun ⟨_i⟩ => finite_univ⟩
#align set.univ_finite_iff_nonempty_fintype Set.univ_finite_iff_nonempty_fintype

@[simp]
theorem Finite.to_finset_singleton {a : α} (ha : ({a} : Set α).Finite := finite_singleton _) :
    ha.toFinset = {a} :=
  Finset.ext <| by simp
#align set.finite.to_finset_singleton Set.Finite.to_finset_singleton

@[simp]
theorem Finite.to_finset_insert [DecidableEq α] {s : Set α} {a : α} (hs : (insert a s).Finite) :
    hs.toFinset = insert a (hs.Subset <| subset_insert _ _).toFinset :=
  Finset.ext <| by simp
#align set.finite.to_finset_insert Set.Finite.to_finset_insert

theorem Finite.to_finset_insert' [DecidableEq α] {a : α} {s : Set α} (hs : s.Finite) :
    (hs.insert a).toFinset = insert a hs.toFinset :=
  Finite.to_finset_insert _
#align set.finite.to_finset_insert' Set.Finite.to_finset_insert'

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem Finite.to_finset_prod {s : Set α} {t : Set β} (hs : s.Finite) (ht : t.Finite) :
    hs.toFinset ×ˢ ht.toFinset = (hs.Prod ht).toFinset :=
  Finset.ext <| by simp
#align set.finite.to_finset_prod Set.Finite.to_finset_prod

theorem Finite.to_finset_off_diag {s : Set α} [DecidableEq α] (hs : s.Finite) :
    hs.offDiag.toFinset = hs.toFinset.offDiag :=
  Finset.ext <| by simp
#align set.finite.to_finset_off_diag Set.Finite.to_finset_off_diag

theorem Finite.fin_embedding {s : Set α} (h : s.Finite) : ∃ (n : ℕ)(f : Fin n ↪ α), range f = s :=
  ⟨_, (Fintype.equivFin (h.toFinset : Set α)).symm.asEmbedding, by simp⟩
#align set.finite.fin_embedding Set.Finite.fin_embedding

theorem Finite.fin_param {s : Set α} (h : s.Finite) :
    ∃ (n : ℕ)(f : Fin n → α), Injective f ∧ range f = s :=
  let ⟨n, f, hf⟩ := h.fin_embedding
  ⟨n, f, f.Injective, hf⟩
#align set.finite.fin_param Set.Finite.fin_param

theorem finite_option {s : Set (Option α)} : s.Finite ↔ { x : α | some x ∈ s }.Finite :=
  ⟨fun h => h.preimage_embedding Embedding.some, fun h =>
    ((h.image some).insert none).Subset fun x =>
      Option.casesOn x (fun _ => Or.inl rfl) fun x hx => Or.inr <| mem_image_of_mem _ hx⟩
#align set.finite_option Set.finite_option

theorem finite_image_fst_and_snd_iff {s : Set (α × β)} :
    (Prod.fst '' s).Finite ∧ (Prod.snd '' s).Finite ↔ s.Finite :=
  ⟨fun h => (h.1.Prod h.2).Subset fun x h => ⟨mem_image_of_mem _ h, mem_image_of_mem _ h⟩, fun h =>
    ⟨h.image _, h.image _⟩⟩
#align set.finite_image_fst_and_snd_iff Set.finite_image_fst_and_snd_iff

theorem forall_finite_image_eval_iff {δ : Type _} [Finite δ] {κ : δ → Type _} {s : Set (∀ d, κ d)} :
    (∀ d, (eval d '' s).Finite) ↔ s.Finite :=
  ⟨fun h => (Finite.pi h).Subset <| subset_pi_eval_image _ _, fun h d => h.image _⟩
#align set.forall_finite_image_eval_iff Set.forall_finite_image_eval_iff

theorem finite_subset_Union {s : Set α} (hs : s.Finite) {ι} {t : ι → Set α} (h : s ⊆ ⋃ i, t i) :
    ∃ I : Set ι, I.Finite ∧ s ⊆ ⋃ i ∈ I, t i := by
  cases hs
  choose f hf using show ∀ x : s, ∃ i, x.1 ∈ t i by simpa [subset_def] using h
  refine' ⟨range f, finite_range f, fun x hx => _⟩
  rw [bUnion_range, mem_Union]
  exact ⟨⟨x, hx⟩, hf _⟩
#align set.finite_subset_Union Set.finite_subset_Union

theorem eq_finite_Union_of_finite_subset_Union {ι} {s : ι → Set α} {t : Set α} (tfin : t.Finite)
    (h : t ⊆ ⋃ i, s i) :
    ∃ I : Set ι,
      I.Finite ∧
        ∃ σ : { i | i ∈ I } → Set α, (∀ i, (σ i).Finite) ∧ (∀ i, σ i ⊆ s i) ∧ t = ⋃ i, σ i :=
  let ⟨I, Ifin, hI⟩ := finite_subset_Union tfin h
  ⟨I, Ifin, fun x => s x ∩ t, fun i => tfin.Subset (inter_subset_right _ _), fun i =>
    inter_subset_left _ _, by 
    ext x
    rw [mem_Union]
    constructor
    · intro x_in
      rcases mem_Union.mp (hI x_in) with ⟨i, _, ⟨hi, rfl⟩, H⟩
      use i, hi, H, x_in
    · rintro ⟨i, hi, H⟩
      exact H⟩
#align set.eq_finite_Union_of_finite_subset_Union Set.eq_finite_Union_of_finite_subset_Union

@[elab_as_elim]
theorem Finite.induction_on {C : Set α → Prop} {s : Set α} (h : s.Finite) (H0 : C ∅)
    (H1 : ∀ {a s}, a ∉ s → Set.Finite s → C s → C (insert a s)) : C s := by
  lift s to Finset α using h
  induction' s using Finset.cons_induction_on with a s ha hs
  · rwa [Finset.coe_empty]
  · rw [Finset.coe_cons]
    exact @H1 a s ha (Set.to_finite _) hs
#align set.finite.induction_on Set.Finite.induction_on

/-- Analogous to `finset.induction_on'`. -/
@[elab_as_elim]
theorem Finite.induction_on' {C : Set α → Prop} {S : Set α} (h : S.Finite) (H0 : C ∅)
    (H1 : ∀ {a s}, a ∈ S → s ⊆ S → a ∉ s → C s → C (insert a s)) : C S := by
  refine' @Set.Finite.induction_on α (fun s => s ⊆ S → C s) S h (fun _ => H0) _ subset.rfl
  intro a s has hsf hCs haS
  rw [insert_subset] at haS
  exact H1 haS.1 haS.2 has (hCs haS.2)
#align set.finite.induction_on' Set.Finite.induction_on'

@[elab_as_elim]
theorem Finite.dinduction_on {C : ∀ s : Set α, s.Finite → Prop} {s : Set α} (h : s.Finite)
    (H0 : C ∅ finite_empty)
    (H1 : ∀ {a s}, a ∉ s → ∀ h : Set.Finite s, C s h → C (insert a s) (h.insert a)) : C s h :=
  have : ∀ h : s.Finite, C s h :=
    Finite.induction_on h (fun h => H0) fun a s has hs ih h => H1 has hs (ih _)
  this h
#align set.finite.dinduction_on Set.Finite.dinduction_on

section

attribute [local instance] nat.fintype_Iio

/-- If `P` is some relation between terms of `γ` and sets in `γ`,
such that every finite set `t : set γ` has some `c : γ` related to it,
then there is a recursively defined sequence `u` in `γ`
so `u n` is related to the image of `{0, 1, ..., n-1}` under `u`.

(We use this later to show sequentially compact sets
are totally bounded.)
-/
theorem seq_of_forall_finite_exists {γ : Type _} {P : γ → Set γ → Prop}
    (h : ∀ t : Set γ, t.Finite → ∃ c, P c t) : ∃ u : ℕ → γ, ∀ n, P (u n) (u '' Iio n) :=
  ⟨fun n =>
    (@Nat.strongRecOn' (fun _ => γ) n) fun n ih =>
      Classical.choose <| h (range fun m : Iio n => ih m.1 m.2) (finite_range _),
    fun n => by
    classical 
      refine' Nat.strongRecOn' n fun n ih => _
      rw [Nat.strongRecOn'_beta]
      convert Classical.choose_spec (h _ _)
      ext x
      constructor
      · rintro ⟨m, hmn, rfl⟩
        exact ⟨⟨m, hmn⟩, rfl⟩
      · rintro ⟨⟨m, hmn⟩, rfl⟩
        exact ⟨m, hmn, rfl⟩⟩
#align set.seq_of_forall_finite_exists Set.seq_of_forall_finite_exists

end

/-! ### Cardinality -/


theorem empty_card : Fintype.card (∅ : Set α) = 0 :=
  rfl
#align set.empty_card Set.empty_card

@[simp]
theorem empty_card' {h : Fintype.{u} (∅ : Set α)} : @Fintype.card (∅ : Set α) h = 0 :=
  Eq.trans (by congr ) empty_card
#align set.empty_card' Set.empty_card'

theorem card_fintype_insert_of_not_mem {a : α} (s : Set α) [Fintype s] (h : a ∉ s) :
    @Fintype.card _ (fintypeInsertOfNotMem s h) = Fintype.card s + 1 := by
  rw [fintype_insert_of_not_mem, Fintype.card_of_finset] <;> simp [Finset.card, to_finset] <;> rfl
#align set.card_fintype_insert_of_not_mem Set.card_fintype_insert_of_not_mem

@[simp]
theorem card_insert {a : α} (s : Set α) [Fintype s] (h : a ∉ s)
    {d : Fintype.{u} (insert a s : Set α)} : @Fintype.card _ d = Fintype.card s + 1 := by
  rw [← card_fintype_insert_of_not_mem s h] <;> congr
#align set.card_insert Set.card_insert

theorem card_image_of_inj_on {s : Set α} [Fintype s] {f : α → β} [Fintype (f '' s)]
    (H : ∀ x ∈ s, ∀ y ∈ s, f x = f y → x = y) : Fintype.card (f '' s) = Fintype.card s :=
  haveI := Classical.propDecidable
  calc
    Fintype.card (f '' s) = (s.to_finset.image f).card := Fintype.card_of_finset' _ (by simp)
    _ = s.to_finset.card :=
      Finset.card_image_of_inj_on fun x hx y hy hxy =>
        H x (mem_to_finset.1 hx) y (mem_to_finset.1 hy) hxy
    _ = Fintype.card s := (Fintype.card_of_finset' _ fun a => mem_to_finset).symm
    
#align set.card_image_of_inj_on Set.card_image_of_inj_on

theorem card_image_of_injective (s : Set α) [Fintype s] {f : α → β} [Fintype (f '' s)]
    (H : Function.Injective f) : Fintype.card (f '' s) = Fintype.card s :=
  card_image_of_inj_on fun _ _ _ _ h => H h
#align set.card_image_of_injective Set.card_image_of_injective

@[simp]
theorem card_singleton (a : α) : Fintype.card ({a} : Set α) = 1 :=
  Fintype.card_of_subsingleton _
#align set.card_singleton Set.card_singleton

theorem card_lt_card {s t : Set α} [Fintype s] [Fintype t] (h : s ⊂ t) :
    Fintype.card s < Fintype.card t :=
  (Fintype.card_lt_of_injective_not_surjective (Set.inclusion h.1) (Set.inclusion_injective h.1))
    fun hst => (ssubset_iff_subset_ne.1 h).2 (eq_of_inclusion_surjective hst)
#align set.card_lt_card Set.card_lt_card

theorem card_le_of_subset {s t : Set α} [Fintype s] [Fintype t] (hsub : s ⊆ t) :
    Fintype.card s ≤ Fintype.card t :=
  Fintype.card_le_of_injective (Set.inclusion hsub) (Set.inclusion_injective hsub)
#align set.card_le_of_subset Set.card_le_of_subset

theorem eq_of_subset_of_card_le {s t : Set α} [Fintype s] [Fintype t] (hsub : s ⊆ t)
    (hcard : Fintype.card t ≤ Fintype.card s) : s = t :=
  (eq_or_ssubset_of_subset hsub).elim id fun h => absurd hcard <| not_le_of_lt <| card_lt_card h
#align set.eq_of_subset_of_card_le Set.eq_of_subset_of_card_le

theorem card_range_of_injective [Fintype α] {f : α → β} (hf : Injective f) [Fintype (range f)] :
    Fintype.card (range f) = Fintype.card α :=
  Eq.symm <| Fintype.card_congr <| Equiv.ofInjective f hf
#align set.card_range_of_injective Set.card_range_of_injective

theorem Finite.card_to_finset {s : Set α} [Fintype s] (h : s.Finite) :
    h.toFinset.card = Fintype.card s := by
  rw [← Finset.card_attach, Finset.attach_eq_univ, ← Fintype.card]
  refine' Fintype.card_congr (Equiv.setCongr _)
  ext x
  show x ∈ h.to_finset ↔ x ∈ s
  simp
#align set.finite.card_to_finset Set.Finite.card_to_finset

theorem card_ne_eq [Fintype α] (a : α) [Fintype { x : α | x ≠ a }] :
    Fintype.card { x : α | x ≠ a } = Fintype.card α - 1 := by
  haveI := Classical.decEq α
  rw [← to_finset_card, to_finset_ne_eq_erase, Finset.card_erase_of_mem (Finset.mem_univ _),
    Finset.card_univ]
#align set.card_ne_eq Set.card_ne_eq

/-! ### Infinite sets -/


theorem infinite_univ_iff : (@univ α).Infinite ↔ Infinite α := by
  rw [Set.Infinite, finite_univ_iff, not_finite_iff_infinite]
#align set.infinite_univ_iff Set.infinite_univ_iff

theorem infinite_univ [h : Infinite α] : (@univ α).Infinite :=
  infinite_univ_iff.2 h
#align set.infinite_univ Set.infinite_univ

theorem infinite_coe_iff {s : Set α} : Infinite s ↔ s.Infinite :=
  not_finite_iff_infinite.symm.trans finite_coe_iff.Not
#align set.infinite_coe_iff Set.infinite_coe_iff

alias infinite_coe_iff ↔ _ infinite.to_subtype

/-- Embedding of `ℕ` into an infinite set. -/
noncomputable def Infinite.natEmbedding (s : Set α) (h : s.Infinite) : ℕ ↪ s :=
  haveI := h.to_subtype
  Infinite.natEmbedding s
#align set.infinite.nat_embedding Set.Infinite.natEmbedding

theorem Infinite.exists_subset_card_eq {s : Set α} (hs : s.Infinite) (n : ℕ) :
    ∃ t : Finset α, ↑t ⊆ s ∧ t.card = n :=
  ⟨((Finset.range n).map (hs.natEmbedding _)).map (Embedding.subtype _), by simp⟩
#align set.infinite.exists_subset_card_eq Set.Infinite.exists_subset_card_eq

theorem Infinite.nonempty {s : Set α} (h : s.Infinite) : s.Nonempty :=
  let a := Infinite.natEmbedding s h 37
  ⟨a.1, a.2⟩
#align set.infinite.nonempty Set.Infinite.nonempty

theorem infinite_of_finite_compl [Infinite α] {s : Set α} (hs : sᶜ.Finite) : s.Infinite := fun h =>
  Set.infinite_univ (by simpa using hs.union h)
#align set.infinite_of_finite_compl Set.infinite_of_finite_compl

theorem Finite.infinite_compl [Infinite α] {s : Set α} (hs : s.Finite) : sᶜ.Infinite := fun h =>
  Set.infinite_univ (by simpa using hs.union h)
#align set.finite.infinite_compl Set.Finite.infinite_compl

protected theorem Infinite.mono {s t : Set α} (h : s ⊆ t) : s.Infinite → t.Infinite :=
  mt fun ht => ht.Subset h
#align set.infinite.mono Set.Infinite.mono

theorem Infinite.diff {s t : Set α} (hs : s.Infinite) (ht : t.Finite) : (s \ t).Infinite := fun h =>
  hs <| h.of_diff ht
#align set.infinite.diff Set.Infinite.diff

@[simp]
theorem infinite_union {s t : Set α} : (s ∪ t).Infinite ↔ s.Infinite ∨ t.Infinite := by
  simp only [Set.Infinite, finite_union, not_and_or]
#align set.infinite_union Set.infinite_union

theorem infinite_of_infinite_image (f : α → β) {s : Set α} (hs : (f '' s).Infinite) : s.Infinite :=
  mt (Finite.image f) hs
#align set.infinite_of_infinite_image Set.infinite_of_infinite_image

theorem infinite_image_iff {s : Set α} {f : α → β} (hi : InjOn f s) :
    (f '' s).Infinite ↔ s.Infinite :=
  not_congr <| finite_image_iff hi
#align set.infinite_image_iff Set.infinite_image_iff

theorem infinite_of_inj_on_maps_to {s : Set α} {t : Set β} {f : α → β} (hi : InjOn f s)
    (hm : MapsTo f s t) (hs : s.Infinite) : t.Infinite :=
  ((infinite_image_iff hi).2 hs).mono (mapsTo'.mp hm)
#align set.infinite_of_inj_on_maps_to Set.infinite_of_inj_on_maps_to

theorem Infinite.exists_ne_map_eq_of_maps_to {s : Set α} {t : Set β} {f : α → β} (hs : s.Infinite)
    (hf : MapsTo f s t) (ht : t.Finite) : ∃ x ∈ s, ∃ y ∈ s, x ≠ y ∧ f x = f y := by
  contrapose! ht
  exact infinite_of_inj_on_maps_to (fun x hx y hy => not_imp_not.1 (ht x hx y hy)) hf hs
#align set.infinite.exists_ne_map_eq_of_maps_to Set.Infinite.exists_ne_map_eq_of_maps_to

theorem infinite_range_of_injective [Infinite α] {f : α → β} (hi : Injective f) :
    (range f).Infinite := by
  rw [← image_univ, infinite_image_iff (inj_on_of_injective hi _)]
  exact infinite_univ
#align set.infinite_range_of_injective Set.infinite_range_of_injective

theorem infinite_of_injective_forall_mem [Infinite α] {s : Set β} {f : α → β} (hi : Injective f)
    (hf : ∀ x : α, f x ∈ s) : s.Infinite := by
  rw [← range_subset_iff] at hf
  exact (infinite_range_of_injective hi).mono hf
#align set.infinite_of_injective_forall_mem Set.infinite_of_injective_forall_mem

theorem Infinite.exists_nat_lt {s : Set ℕ} (hs : s.Infinite) (n : ℕ) : ∃ m ∈ s, n < m :=
  let ⟨m, hm⟩ := (hs.diff <| Set.finite_le_nat n).Nonempty
  ⟨m, by simpa using hm⟩
#align set.infinite.exists_nat_lt Set.Infinite.exists_nat_lt

theorem Infinite.exists_not_mem_finset {s : Set α} (hs : s.Infinite) (f : Finset α) :
    ∃ a ∈ s, a ∉ f :=
  let ⟨a, has, haf⟩ := (hs.diff (to_finite f)).Nonempty
  ⟨a, has, fun h => haf <| Finset.mem_coe.1 h⟩
#align set.infinite.exists_not_mem_finset Set.Infinite.exists_not_mem_finset

/-! ### Order properties -/


theorem finite_is_top (α : Type _) [PartialOrder α] : { x : α | IsTop x }.Finite :=
  (subsingleton_isTop α).Finite
#align set.finite_is_top Set.finite_is_top

theorem finite_is_bot (α : Type _) [PartialOrder α] : { x : α | IsBot x }.Finite :=
  (subsingleton_isBot α).Finite
#align set.finite_is_bot Set.finite_is_bot

theorem Infinite.exists_lt_map_eq_of_maps_to [LinearOrder α] {s : Set α} {t : Set β} {f : α → β}
    (hs : s.Infinite) (hf : MapsTo f s t) (ht : t.Finite) : ∃ x ∈ s, ∃ y ∈ s, x < y ∧ f x = f y :=
  let ⟨x, hx, y, hy, hxy, hf⟩ := hs.exists_ne_map_eq_of_maps_to hf ht
  hxy.lt_or_lt.elim (fun hxy => ⟨x, hx, y, hy, hxy, hf⟩) fun hyx => ⟨y, hy, x, hx, hyx, hf.symm⟩
#align set.infinite.exists_lt_map_eq_of_maps_to Set.Infinite.exists_lt_map_eq_of_maps_to

theorem Finite.exists_lt_map_eq_of_forall_mem [LinearOrder α] [Infinite α] {t : Set β} {f : α → β}
    (hf : ∀ a, f a ∈ t) (ht : t.Finite) : ∃ a b, a < b ∧ f a = f b := by
  rw [← maps_univ_to] at hf
  obtain ⟨a, -, b, -, h⟩ := (@infinite_univ α _).exists_lt_map_eq_of_maps_to hf ht
  exact ⟨a, b, h⟩
#align set.finite.exists_lt_map_eq_of_forall_mem Set.Finite.exists_lt_map_eq_of_forall_mem

theorem exists_min_image [LinearOrder β] (s : Set α) (f : α → β) (h1 : s.Finite) :
    s.Nonempty → ∃ a ∈ s, ∀ b ∈ s, f a ≤ f b
  | ⟨x, hx⟩ => by
    simpa only [exists_prop, finite.mem_to_finset] using
      h1.to_finset.exists_min_image f ⟨x, h1.mem_to_finset.2 hx⟩
#align set.exists_min_image Set.exists_min_image

theorem exists_max_image [LinearOrder β] (s : Set α) (f : α → β) (h1 : s.Finite) :
    s.Nonempty → ∃ a ∈ s, ∀ b ∈ s, f b ≤ f a
  | ⟨x, hx⟩ => by
    simpa only [exists_prop, finite.mem_to_finset] using
      h1.to_finset.exists_max_image f ⟨x, h1.mem_to_finset.2 hx⟩
#align set.exists_max_image Set.exists_max_image

theorem exists_lower_bound_image [hα : Nonempty α] [LinearOrder β] (s : Set α) (f : α → β)
    (h : s.Finite) : ∃ a : α, ∀ b ∈ s, f a ≤ f b := by
  by_cases hs : Set.Nonempty s
  ·
    exact
      let ⟨x₀, H, hx₀⟩ := Set.exists_min_image s f h hs
      ⟨x₀, fun x hx => hx₀ x hx⟩
  · exact Nonempty.elim hα fun a => ⟨a, fun x hx => absurd (Set.nonempty_of_mem hx) hs⟩
#align set.exists_lower_bound_image Set.exists_lower_bound_image

theorem exists_upper_bound_image [hα : Nonempty α] [LinearOrder β] (s : Set α) (f : α → β)
    (h : s.Finite) : ∃ a : α, ∀ b ∈ s, f b ≤ f a := by
  by_cases hs : Set.Nonempty s
  ·
    exact
      let ⟨x₀, H, hx₀⟩ := Set.exists_max_image s f h hs
      ⟨x₀, fun x hx => hx₀ x hx⟩
  · exact Nonempty.elim hα fun a => ⟨a, fun x hx => absurd (Set.nonempty_of_mem hx) hs⟩
#align set.exists_upper_bound_image Set.exists_upper_bound_image

theorem Finite.supr_binfi_of_monotone {ι ι' α : Type _} [Preorder ι'] [Nonempty ι']
    [IsDirected ι' (· ≤ ·)] [Order.Frame α] {s : Set ι} (hs : s.Finite) {f : ι → ι' → α}
    (hf : ∀ i ∈ s, Monotone (f i)) : (⨆ j, ⨅ i ∈ s, f i j) = ⨅ i ∈ s, ⨆ j, f i j := by
  revert hf
  refine' hs.induction_on _ _
  · intro hf
    simp [supᵢ_const]
  · intro a s has hs ihs hf
    rw [ball_insert_iff] at hf
    simp only [infᵢ_insert, ← ihs hf.2]
    exact supᵢ_inf_of_monotone hf.1 fun j₁ j₂ hj => infᵢ₂_mono fun i hi => hf.2 i hi hj
#align set.finite.supr_binfi_of_monotone Set.Finite.supr_binfi_of_monotone

theorem Finite.supr_binfi_of_antitone {ι ι' α : Type _} [Preorder ι'] [Nonempty ι']
    [IsDirected ι' (swap (· ≤ ·))] [Order.Frame α] {s : Set ι} (hs : s.Finite) {f : ι → ι' → α}
    (hf : ∀ i ∈ s, Antitone (f i)) : (⨆ j, ⨅ i ∈ s, f i j) = ⨅ i ∈ s, ⨆ j, f i j :=
  @Finite.supr_binfi_of_monotone ι ι'ᵒᵈ α _ _ _ _ _ hs _ fun i hi => (hf i hi).dual_left
#align set.finite.supr_binfi_of_antitone Set.Finite.supr_binfi_of_antitone

theorem Finite.infi_bsupr_of_monotone {ι ι' α : Type _} [Preorder ι'] [Nonempty ι']
    [IsDirected ι' (swap (· ≤ ·))] [Order.Coframe α] {s : Set ι} (hs : s.Finite) {f : ι → ι' → α}
    (hf : ∀ i ∈ s, Monotone (f i)) : (⨅ j, ⨆ i ∈ s, f i j) = ⨆ i ∈ s, ⨅ j, f i j :=
  hs.supr_binfi_of_antitone fun i hi => (hf i hi).dual_right
#align set.finite.infi_bsupr_of_monotone Set.Finite.infi_bsupr_of_monotone

theorem Finite.infi_bsupr_of_antitone {ι ι' α : Type _} [Preorder ι'] [Nonempty ι']
    [IsDirected ι' (· ≤ ·)] [Order.Coframe α] {s : Set ι} (hs : s.Finite) {f : ι → ι' → α}
    (hf : ∀ i ∈ s, Antitone (f i)) : (⨅ j, ⨆ i ∈ s, f i j) = ⨆ i ∈ s, ⨅ j, f i j :=
  hs.supr_binfi_of_monotone fun i hi => (hf i hi).dual_right
#align set.finite.infi_bsupr_of_antitone Set.Finite.infi_bsupr_of_antitone

theorem supr_infi_of_monotone {ι ι' α : Type _} [Finite ι] [Preorder ι'] [Nonempty ι']
    [IsDirected ι' (· ≤ ·)] [Order.Frame α] {f : ι → ι' → α} (hf : ∀ i, Monotone (f i)) :
    (⨆ j, ⨅ i, f i j) = ⨅ i, ⨆ j, f i j := by
  simpa only [infᵢ_univ] using finite_univ.supr_binfi_of_monotone fun i hi => hf i
#align supr_infi_of_monotone supr_infi_of_monotone

theorem supr_infi_of_antitone {ι ι' α : Type _} [Finite ι] [Preorder ι'] [Nonempty ι']
    [IsDirected ι' (swap (· ≤ ·))] [Order.Frame α] {f : ι → ι' → α} (hf : ∀ i, Antitone (f i)) :
    (⨆ j, ⨅ i, f i j) = ⨅ i, ⨆ j, f i j :=
  @supr_infi_of_monotone ι ι'ᵒᵈ α _ _ _ _ _ _ fun i => (hf i).dual_left
#align supr_infi_of_antitone supr_infi_of_antitone

theorem infi_supr_of_monotone {ι ι' α : Type _} [Finite ι] [Preorder ι'] [Nonempty ι']
    [IsDirected ι' (swap (· ≤ ·))] [Order.Coframe α] {f : ι → ι' → α} (hf : ∀ i, Monotone (f i)) :
    (⨅ j, ⨆ i, f i j) = ⨆ i, ⨅ j, f i j :=
  supr_infi_of_antitone fun i => (hf i).dual_right
#align infi_supr_of_monotone infi_supr_of_monotone

theorem infi_supr_of_antitone {ι ι' α : Type _} [Finite ι] [Preorder ι'] [Nonempty ι']
    [IsDirected ι' (· ≤ ·)] [Order.Coframe α] {f : ι → ι' → α} (hf : ∀ i, Antitone (f i)) :
    (⨅ j, ⨆ i, f i j) = ⨆ i, ⨅ j, f i j :=
  supr_infi_of_monotone fun i => (hf i).dual_right
#align infi_supr_of_antitone infi_supr_of_antitone

/-- An increasing union distributes over finite intersection. -/
theorem Union_Inter_of_monotone {ι ι' α : Type _} [Finite ι] [Preorder ι'] [IsDirected ι' (· ≤ ·)]
    [Nonempty ι'] {s : ι → ι' → Set α} (hs : ∀ i, Monotone (s i)) :
    (⋃ j : ι', ⋂ i : ι, s i j) = ⋂ i : ι, ⋃ j : ι', s i j :=
  supr_infi_of_monotone hs
#align set.Union_Inter_of_monotone Set.Union_Inter_of_monotone

/-- A decreasing union distributes over finite intersection. -/
theorem Union_Inter_of_antitone {ι ι' α : Type _} [Finite ι] [Preorder ι']
    [IsDirected ι' (swap (· ≤ ·))] [Nonempty ι'] {s : ι → ι' → Set α} (hs : ∀ i, Antitone (s i)) :
    (⋃ j : ι', ⋂ i : ι, s i j) = ⋂ i : ι, ⋃ j : ι', s i j :=
  supr_infi_of_antitone hs
#align set.Union_Inter_of_antitone Set.Union_Inter_of_antitone

/-- An increasing intersection distributes over finite union. -/
theorem Inter_Union_of_monotone {ι ι' α : Type _} [Finite ι] [Preorder ι']
    [IsDirected ι' (swap (· ≤ ·))] [Nonempty ι'] {s : ι → ι' → Set α} (hs : ∀ i, Monotone (s i)) :
    (⋂ j : ι', ⋃ i : ι, s i j) = ⋃ i : ι, ⋂ j : ι', s i j :=
  infi_supr_of_monotone hs
#align set.Inter_Union_of_monotone Set.Inter_Union_of_monotone

/-- A decreasing intersection distributes over finite union. -/
theorem Inter_Union_of_antitone {ι ι' α : Type _} [Finite ι] [Preorder ι'] [IsDirected ι' (· ≤ ·)]
    [Nonempty ι'] {s : ι → ι' → Set α} (hs : ∀ i, Antitone (s i)) :
    (⋂ j : ι', ⋃ i : ι, s i j) = ⋃ i : ι, ⋂ j : ι', s i j :=
  infi_supr_of_antitone hs
#align set.Inter_Union_of_antitone Set.Inter_Union_of_antitone

theorem Union_pi_of_monotone {ι ι' : Type _} [LinearOrder ι'] [Nonempty ι'] {α : ι → Type _}
    {I : Set ι} {s : ∀ i, ι' → Set (α i)} (hI : I.Finite) (hs : ∀ i ∈ I, Monotone (s i)) :
    (⋃ j : ι', I.pi fun i => s i j) = I.pi fun i => ⋃ j, s i j := by
  simp only [pi_def, bInter_eq_Inter, preimage_Union]
  haveI := hI.fintype
  exact Union_Inter_of_monotone fun i j₁ j₂ h => preimage_mono <| hs i i.2 h
#align set.Union_pi_of_monotone Set.Union_pi_of_monotone

theorem Union_univ_pi_of_monotone {ι ι' : Type _} [LinearOrder ι'] [Nonempty ι'] [Finite ι]
    {α : ι → Type _} {s : ∀ i, ι' → Set (α i)} (hs : ∀ i, Monotone (s i)) :
    (⋃ j : ι', pi univ fun i => s i j) = pi univ fun i => ⋃ j, s i j :=
  Union_pi_of_monotone finite_univ fun i _ => hs i
#align set.Union_univ_pi_of_monotone Set.Union_univ_pi_of_monotone

theorem finite_range_find_greatest {P : α → ℕ → Prop} [∀ x, DecidablePred (P x)] {b : ℕ} :
    (range fun x => Nat.findGreatest (P x) b).Finite :=
  (finite_le_nat b).Subset <| range_subset_iff.2 fun x => Nat.findGreatest_le _
#align set.finite_range_find_greatest Set.finite_range_find_greatest

theorem Finite.exists_maximal_wrt [PartialOrder β] (f : α → β) (s : Set α) (h : Set.Finite s) :
    s.Nonempty → ∃ a ∈ s, ∀ a' ∈ s, f a ≤ f a' → f a = f a' := by
  refine' h.induction_on _ _
  · exact fun h => absurd h not_nonempty_empty
  intro a s his _ ih _
  cases' s.eq_empty_or_nonempty with h h
  · use a
    simp [h]
  rcases ih h with ⟨b, hb, ih⟩
  by_cases f b ≤ f a
  · refine' ⟨a, Set.mem_insert _ _, fun c hc hac => le_antisymm hac _⟩
    rcases Set.mem_insert_iff.1 hc with (rfl | hcs)
    · rfl
    · rwa [← ih c hcs (le_trans h hac)]
  · refine' ⟨b, Set.mem_insert_of_mem _ hb, fun c hc hbc => _⟩
    rcases Set.mem_insert_iff.1 hc with (rfl | hcs)
    · exact (h hbc).elim
    · exact ih c hcs hbc
#align set.finite.exists_maximal_wrt Set.Finite.exists_maximal_wrt

section

variable [SemilatticeSup α] [Nonempty α] {s : Set α}

/-- A finite set is bounded above.-/
protected theorem Finite.bdd_above (hs : s.Finite) : BddAbove s :=
  (Finite.induction_on hs bddAbove_empty) fun a s _ _ h => h.insert a
#align set.finite.bdd_above Set.Finite.bdd_above

/-- A finite union of sets which are all bounded above is still bounded above.-/
theorem Finite.bdd_above_bUnion {I : Set β} {S : β → Set α} (H : I.Finite) :
    BddAbove (⋃ i ∈ I, S i) ↔ ∀ i ∈ I, BddAbove (S i) :=
  Finite.induction_on H (by simp only [bUnion_empty, bddAbove_empty, ball_empty_iff])
    fun a s ha _ hs => by simp only [bUnion_insert, ball_insert_iff, bddAbove_union, hs]
#align set.finite.bdd_above_bUnion Set.Finite.bdd_above_bUnion

theorem infinite_of_not_bdd_above : ¬BddAbove s → s.Infinite :=
  mt Finite.bdd_above
#align set.infinite_of_not_bdd_above Set.infinite_of_not_bdd_above

end

section

variable [SemilatticeInf α] [Nonempty α] {s : Set α}

/-- A finite set is bounded below.-/
protected theorem Finite.bdd_below (hs : s.Finite) : BddBelow s :=
  @Finite.bdd_above αᵒᵈ _ _ _ hs
#align set.finite.bdd_below Set.Finite.bdd_below

/-- A finite union of sets which are all bounded below is still bounded below.-/
theorem Finite.bdd_below_bUnion {I : Set β} {S : β → Set α} (H : I.Finite) :
    BddBelow (⋃ i ∈ I, S i) ↔ ∀ i ∈ I, BddBelow (S i) :=
  @Finite.bdd_above_bUnion αᵒᵈ _ _ _ _ _ H
#align set.finite.bdd_below_bUnion Set.Finite.bdd_below_bUnion

theorem infinite_of_not_bdd_below : ¬BddBelow s → s.Infinite := by
  contrapose!
  rw [not_infinite]
  apply finite.bdd_below
#align set.infinite_of_not_bdd_below Set.infinite_of_not_bdd_below

end

end Set

namespace Finset

/-- A finset is bounded above. -/
protected theorem bdd_above [SemilatticeSup α] [Nonempty α] (s : Finset α) :
    BddAbove (↑s : Set α) :=
  s.finite_to_set.BddAbove
#align finset.bdd_above Finset.bdd_above

/-- A finset is bounded below. -/
protected theorem bdd_below [SemilatticeInf α] [Nonempty α] (s : Finset α) :
    BddBelow (↑s : Set α) :=
  s.finite_to_set.BddBelow
#align finset.bdd_below Finset.bdd_below

end Finset

/-- If a set `s` does not contain any elements between any pair of elements `x, z ∈ s` with `x ≤ z`
(i.e if given `x, y, z ∈ s` such that `x ≤ y ≤ z`, then `y` is either `x` or `z`), then `s` is
finite.
-/
theorem Set.finite_of_forall_between_eq_endpoints {α : Type _} [LinearOrder α] (s : Set α)
    (h : ∀ x ∈ s, ∀ y ∈ s, ∀ z ∈ s, x ≤ y → y ≤ z → x = y ∨ y = z) : Set.Finite s := by
  by_contra hinf
  change s.infinite at hinf
  rcases hinf.exists_subset_card_eq 3 with ⟨t, hts, ht⟩
  let f := t.order_iso_of_fin ht
  let x := f 0
  let y := f 1
  let z := f 2
  have := h x (hts x.2) y (hts y.2) z (hts z.2) (f.monotone <| by decide) (f.monotone <| by decide)
  have key₁ : (0 : Fin 3) ≠ 1 := by decide
  have key₂ : (1 : Fin 3) ≠ 2 := by decide
  cases this
  · dsimp only [x, y] at this
    exact key₁ (f.injective <| Subtype.coe_injective this)
  · dsimp only [y, z] at this
    exact key₂ (f.injective <| Subtype.coe_injective this)
#align set.finite_of_forall_between_eq_endpoints Set.finite_of_forall_between_eq_endpoints

