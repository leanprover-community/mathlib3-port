/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module data.set.pairwise
! leanprover-community/mathlib commit 09597669f02422ed388036273d8848119699c22f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Relation
import Mathbin.Logic.Pairwise
import Mathbin.Data.Set.Lattice

/-!
# Relations holding pairwise

This file develops pairwise relations and defines pairwise disjoint indexed sets.

We also prove many basic facts about `pairwise`. It is possible that an intermediate file,
with more imports than `logic.pairwise` but not importing `data.set.lattice` would be appropriate
to hold many of these basic facts.

## Main declarations

* `set.pairwise_disjoint`: `s.pairwise_disjoint f` states that images under `f` of distinct elements
  of `s` are either equal or `disjoint`.

## Notes

The spelling `s.pairwise_disjoint id` is preferred over `s.pairwise disjoint` to permit dot notation
on `set.pairwise_disjoint`, even though the latter unfolds to something nicer.
-/


open Set Function

variable {α β γ ι ι' : Type _} {r p q : α → α → Prop}

section Pairwise

variable {f g : ι → α} {s t u : Set α} {a b : α}

theorem pairwise_on_bool (hr : Symmetric r) {a b : α} :
    Pairwise (r on fun c => cond c a b) ↔ r a b := by simpa [Pairwise, Function.onFun] using @hr a b
#align pairwise_on_bool pairwise_on_bool

theorem pairwise_disjoint_on_bool [SemilatticeInf α] [OrderBot α] {a b : α} :
    Pairwise (Disjoint on fun c => cond c a b) ↔ Disjoint a b :=
  pairwise_on_bool Disjoint.symm
#align pairwise_disjoint_on_bool pairwise_disjoint_on_bool

theorem Symmetric.pairwise_on [LinearOrder ι] (hr : Symmetric r) (f : ι → α) :
    Pairwise (r on f) ↔ ∀ ⦃m n⦄, m < n → r (f m) (f n) :=
  ⟨fun h m n hmn => h hmn.Ne, fun h m n hmn => hmn.lt_or_lt.elim (@h _ _) fun h' => hr (h h')⟩
#align symmetric.pairwise_on Symmetric.pairwise_on

theorem pairwise_disjoint_on [SemilatticeInf α] [OrderBot α] [LinearOrder ι] (f : ι → α) :
    Pairwise (Disjoint on f) ↔ ∀ ⦃m n⦄, m < n → Disjoint (f m) (f n) :=
  Symmetric.pairwise_on Disjoint.symm f
#align pairwise_disjoint_on pairwise_disjoint_on

theorem PairwiseDisjoint.mono [SemilatticeInf α] [OrderBot α] (hs : Pairwise (Disjoint on f))
    (h : g ≤ f) : Pairwise (Disjoint on g) :=
  hs.mono fun i j hij => Disjoint.mono (h i) (h j) hij
#align pairwise_disjoint.mono PairwiseDisjoint.mono

alias Function.injective_iff_pairwise_ne ↔ Function.Injective.pairwise_ne _

namespace Set

theorem Pairwise.mono (h : t ⊆ s) (hs : s.Pairwise r) : t.Pairwise r := fun x xt y yt =>
  hs (h xt) (h yt)
#align set.pairwise.mono Set.Pairwise.mono

theorem Pairwise.mono' (H : r ≤ p) (hr : s.Pairwise r) : s.Pairwise p :=
  hr.imp H
#align set.pairwise.mono' Set.Pairwise.mono'

theorem pairwise_top (s : Set α) : s.Pairwise ⊤ :=
  pairwise_of_forall s _ fun a b => trivial
#align set.pairwise_top Set.pairwise_top

protected theorem Subsingleton.pairwise (h : s.Subsingleton) (r : α → α → Prop) : s.Pairwise r :=
  fun x hx y hy hne => (hne (h hx hy)).elim
#align set.subsingleton.pairwise Set.Subsingleton.pairwise

@[simp]
theorem pairwise_empty (r : α → α → Prop) : (∅ : Set α).Pairwise r :=
  subsingleton_empty.Pairwise r
#align set.pairwise_empty Set.pairwise_empty

@[simp]
theorem pairwise_singleton (a : α) (r : α → α → Prop) : Set.Pairwise {a} r :=
  subsingleton_singleton.Pairwise r
#align set.pairwise_singleton Set.pairwise_singleton

theorem pairwise_iff_of_refl [IsRefl α r] : s.Pairwise r ↔ ∀ ⦃a⦄, a ∈ s → ∀ ⦃b⦄, b ∈ s → r a b :=
  forall₄_congr fun a _ b _ => or_iff_not_imp_left.symm.trans <| or_iff_right_of_imp of_eq
#align set.pairwise_iff_of_refl Set.pairwise_iff_of_refl

alias pairwise_iff_of_refl ↔ pairwise.of_refl _

theorem Nonempty.pairwise_iff_exists_forall [IsEquiv α r] {s : Set ι} (hs : s.Nonempty) :
    s.Pairwise (r on f) ↔ ∃ z, ∀ x ∈ s, r (f x) z :=
  by
  fconstructor
  · rcases hs with ⟨y, hy⟩
    refine' fun H => ⟨f y, fun x hx => _⟩
    rcases eq_or_ne x y with (rfl | hne)
    · apply IsRefl.refl
    · exact H hx hy hne
  · rintro ⟨z, hz⟩ x hx y hy hne
    exact @IsTrans.trans α r _ (f x) z (f y) (hz _ hx) (IsSymm.symm _ _ <| hz _ hy)
#align set.nonempty.pairwise_iff_exists_forall Set.Nonempty.pairwise_iff_exists_forall

/-- For a nonempty set `s`, a function `f` takes pairwise equal values on `s` if and only if
for some `z` in the codomain, `f` takes value `z` on all `x ∈ s`. See also
`set.pairwise_eq_iff_exists_eq` for a version that assumes `[nonempty ι]` instead of
`set.nonempty s`. -/
theorem Nonempty.pairwise_eq_iff_exists_eq {s : Set α} (hs : s.Nonempty) {f : α → ι} :
    (s.Pairwise fun x y => f x = f y) ↔ ∃ z, ∀ x ∈ s, f x = z :=
  hs.pairwise_iff_exists_forall
#align set.nonempty.pairwise_eq_iff_exists_eq Set.Nonempty.pairwise_eq_iff_exists_eq

theorem pairwise_iff_exists_forall [Nonempty ι] (s : Set α) (f : α → ι) {r : ι → ι → Prop}
    [IsEquiv ι r] : s.Pairwise (r on f) ↔ ∃ z, ∀ x ∈ s, r (f x) z :=
  by
  rcases s.eq_empty_or_nonempty with (rfl | hne)
  · simp
  · exact hne.pairwise_iff_exists_forall
#align set.pairwise_iff_exists_forall Set.pairwise_iff_exists_forall

/-- A function `f : α → ι` with nonempty codomain takes pairwise equal values on a set `s` if and
only if for some `z` in the codomain, `f` takes value `z` on all `x ∈ s`. See also
`set.nonempty.pairwise_eq_iff_exists_eq` for a version that assumes `set.nonempty s` instead of
`[nonempty ι]`. -/
theorem pairwise_eq_iff_exists_eq [Nonempty ι] (s : Set α) (f : α → ι) :
    (s.Pairwise fun x y => f x = f y) ↔ ∃ z, ∀ x ∈ s, f x = z :=
  pairwise_iff_exists_forall s f
#align set.pairwise_eq_iff_exists_eq Set.pairwise_eq_iff_exists_eq

theorem pairwise_union :
    (s ∪ t).Pairwise r ↔ s.Pairwise r ∧ t.Pairwise r ∧ ∀ a ∈ s, ∀ b ∈ t, a ≠ b → r a b ∧ r b a :=
  by
  simp only [Set.Pairwise, mem_union, or_imp, forall_and]
  exact
    ⟨fun H => ⟨H.1.1, H.2.2, H.2.1, fun x hx y hy hne => H.1.2 y hy x hx hne.symm⟩, fun H =>
      ⟨⟨H.1, fun x hx y hy hne => H.2.2.2 y hy x hx hne.symm⟩, H.2.2.1, H.2.1⟩⟩
#align set.pairwise_union Set.pairwise_union

theorem pairwise_union_of_symmetric (hr : Symmetric r) :
    (s ∪ t).Pairwise r ↔ s.Pairwise r ∧ t.Pairwise r ∧ ∀ a ∈ s, ∀ b ∈ t, a ≠ b → r a b :=
  pairwise_union.trans <| by simp only [hr.iff, and_self_iff]
#align set.pairwise_union_of_symmetric Set.pairwise_union_of_symmetric

theorem pairwise_insert : (insert a s).Pairwise r ↔ s.Pairwise r ∧ ∀ b ∈ s, a ≠ b → r a b ∧ r b a :=
  by
  simp only [insert_eq, pairwise_union, pairwise_singleton, true_and_iff, mem_singleton_iff,
    forall_eq]
#align set.pairwise_insert Set.pairwise_insert

theorem pairwise_insert_of_not_mem (ha : a ∉ s) :
    (insert a s).Pairwise r ↔ s.Pairwise r ∧ ∀ b ∈ s, r a b ∧ r b a :=
  pairwise_insert.trans <|
    and_congr_right' <| forall₂_congr fun b hb => by simp [(ne_of_mem_of_not_mem hb ha).symm]
#align set.pairwise_insert_of_not_mem Set.pairwise_insert_of_not_mem

theorem Pairwise.insert (hs : s.Pairwise r) (h : ∀ b ∈ s, a ≠ b → r a b ∧ r b a) :
    (insert a s).Pairwise r :=
  pairwise_insert.2 ⟨hs, h⟩
#align set.pairwise.insert Set.Pairwise.insert

theorem Pairwise.insert_of_not_mem (ha : a ∉ s) (hs : s.Pairwise r) (h : ∀ b ∈ s, r a b ∧ r b a) :
    (insert a s).Pairwise r :=
  (pairwise_insert_of_not_mem ha).2 ⟨hs, h⟩
#align set.pairwise.insert_of_not_mem Set.Pairwise.insert_of_not_mem

theorem pairwise_insert_of_symmetric (hr : Symmetric r) :
    (insert a s).Pairwise r ↔ s.Pairwise r ∧ ∀ b ∈ s, a ≠ b → r a b := by
  simp only [pairwise_insert, hr.iff a, and_self_iff]
#align set.pairwise_insert_of_symmetric Set.pairwise_insert_of_symmetric

theorem pairwise_insert_of_symmetric_of_not_mem (hr : Symmetric r) (ha : a ∉ s) :
    (insert a s).Pairwise r ↔ s.Pairwise r ∧ ∀ b ∈ s, r a b := by
  simp only [pairwise_insert_of_not_mem ha, hr.iff a, and_self_iff]
#align set.pairwise_insert_of_symmetric_of_not_mem Set.pairwise_insert_of_symmetric_of_not_mem

theorem Pairwise.insert_of_symmetric (hs : s.Pairwise r) (hr : Symmetric r)
    (h : ∀ b ∈ s, a ≠ b → r a b) : (insert a s).Pairwise r :=
  (pairwise_insert_of_symmetric hr).2 ⟨hs, h⟩
#align set.pairwise.insert_of_symmetric Set.Pairwise.insert_of_symmetric

theorem Pairwise.insert_of_symmetric_of_not_mem (hs : s.Pairwise r) (hr : Symmetric r) (ha : a ∉ s)
    (h : ∀ b ∈ s, r a b) : (insert a s).Pairwise r :=
  (pairwise_insert_of_symmetric_of_not_mem hr ha).2 ⟨hs, h⟩
#align set.pairwise.insert_of_symmetric_of_not_mem Set.Pairwise.insert_of_symmetric_of_not_mem

theorem pairwise_pair : Set.Pairwise {a, b} r ↔ a ≠ b → r a b ∧ r b a := by simp [pairwise_insert]
#align set.pairwise_pair Set.pairwise_pair

theorem pairwise_pair_of_symmetric (hr : Symmetric r) : Set.Pairwise {a, b} r ↔ a ≠ b → r a b := by
  simp [pairwise_insert_of_symmetric hr]
#align set.pairwise_pair_of_symmetric Set.pairwise_pair_of_symmetric

theorem pairwise_univ : (univ : Set α).Pairwise r ↔ Pairwise r := by
  simp only [Set.Pairwise, Pairwise, mem_univ, forall_const]
#align set.pairwise_univ Set.pairwise_univ

@[simp]
theorem pairwise_bot_iff : s.Pairwise (⊥ : α → α → Prop) ↔ (s : Set α).Subsingleton :=
  ⟨fun h a ha b hb => h.Eq ha hb id, fun h => h.Pairwise _⟩
#align set.pairwise_bot_iff Set.pairwise_bot_iff

alias pairwise_bot_iff ↔ pairwise.subsingleton _

theorem InjOn.pairwise_image {s : Set ι} (h : s.InjOn f) :
    (f '' s).Pairwise r ↔ s.Pairwise (r on f) := by
  simp (config := { contextual := true }) [h.eq_iff, Set.Pairwise]
#align set.inj_on.pairwise_image Set.InjOn.pairwise_image

theorem pairwise_Union {f : ι → Set α} (h : Directed (· ⊆ ·) f) :
    (⋃ n, f n).Pairwise r ↔ ∀ n, (f n).Pairwise r :=
  by
  constructor
  · intro H n
    exact Pairwise.mono (subset_Union _ _) H
  · intro H i hi j hj hij
    rcases mem_Union.1 hi with ⟨m, hm⟩
    rcases mem_Union.1 hj with ⟨n, hn⟩
    rcases h m n with ⟨p, mp, np⟩
    exact H p (mp hm) (np hn) hij
#align set.pairwise_Union Set.pairwise_Union

theorem pairwise_sUnion {r : α → α → Prop} {s : Set (Set α)} (h : DirectedOn (· ⊆ ·) s) :
    (⋃₀s).Pairwise r ↔ ∀ a ∈ s, Set.Pairwise a r :=
  by
  rw [sUnion_eq_Union, pairwise_Union h.directed_coe, SetCoe.forall]
  rfl
#align set.pairwise_sUnion Set.pairwise_sUnion

end Set

end Pairwise

theorem pairwise_subtype_iff_pairwise_set (s : Set α) (r : α → α → Prop) :
    (Pairwise fun (x : s) (y : s) => r x y) ↔ s.Pairwise r := by
  simp only [Pairwise, Set.Pairwise, SetCoe.forall, Ne.def, Subtype.ext_iff, Subtype.coe_mk]
#align pairwise_subtype_iff_pairwise_set pairwise_subtype_iff_pairwise_set

alias pairwise_subtype_iff_pairwise_set ↔ Pairwise.set_of_subtype Set.Pairwise.subtype

namespace Set

section PartialOrderBot

variable [PartialOrder α] [OrderBot α] {s t : Set ι} {f g : ι → α}

/-- A set is `pairwise_disjoint` under `f`, if the images of any distinct two elements under `f`
are disjoint.

`s.pairwise disjoint` is (definitionally) the same as `s.pairwise_disjoint id`. We prefer the latter
in order to allow dot notation on `set.pairwise_disjoint`, even though the former unfolds more
nicely. -/
def PairwiseDisjoint (s : Set ι) (f : ι → α) : Prop :=
  s.Pairwise (Disjoint on f)
#align set.pairwise_disjoint Set.PairwiseDisjoint

theorem PairwiseDisjoint.subset (ht : t.PairwiseDisjoint f) (h : s ⊆ t) : s.PairwiseDisjoint f :=
  Pairwise.mono h ht
#align set.pairwise_disjoint.subset Set.PairwiseDisjoint.subset

theorem PairwiseDisjoint.mono_on (hs : s.PairwiseDisjoint f) (h : ∀ ⦃i⦄, i ∈ s → g i ≤ f i) :
    s.PairwiseDisjoint g := fun a ha b hb hab => (hs ha hb hab).mono (h ha) (h hb)
#align set.pairwise_disjoint.mono_on Set.PairwiseDisjoint.mono_on

theorem PairwiseDisjoint.mono (hs : s.PairwiseDisjoint f) (h : g ≤ f) : s.PairwiseDisjoint g :=
  hs.mono_on fun i _ => h i
#align set.pairwise_disjoint.mono Set.PairwiseDisjoint.mono

@[simp]
theorem pairwise_disjoint_empty : (∅ : Set ι).PairwiseDisjoint f :=
  pairwise_empty _
#align set.pairwise_disjoint_empty Set.pairwise_disjoint_empty

@[simp]
theorem pairwise_disjoint_singleton (i : ι) (f : ι → α) : PairwiseDisjoint {i} f :=
  pairwise_singleton i _
#align set.pairwise_disjoint_singleton Set.pairwise_disjoint_singleton

theorem pairwise_disjoint_insert {i : ι} :
    (insert i s).PairwiseDisjoint f ↔
      s.PairwiseDisjoint f ∧ ∀ j ∈ s, i ≠ j → Disjoint (f i) (f j) :=
  Set.pairwise_insert_of_symmetric <| symmetric_disjoint.comap f
#align set.pairwise_disjoint_insert Set.pairwise_disjoint_insert

theorem pairwise_disjoint_insert_of_not_mem {i : ι} (hi : i ∉ s) :
    (insert i s).PairwiseDisjoint f ↔ s.PairwiseDisjoint f ∧ ∀ j ∈ s, Disjoint (f i) (f j) :=
  pairwise_insert_of_symmetric_of_not_mem (symmetric_disjoint.comap f) hi
#align set.pairwise_disjoint_insert_of_not_mem Set.pairwise_disjoint_insert_of_not_mem

theorem PairwiseDisjoint.insert (hs : s.PairwiseDisjoint f) {i : ι}
    (h : ∀ j ∈ s, i ≠ j → Disjoint (f i) (f j)) : (insert i s).PairwiseDisjoint f :=
  Set.pairwise_disjoint_insert.2 ⟨hs, h⟩
#align set.pairwise_disjoint.insert Set.PairwiseDisjoint.insert

theorem PairwiseDisjoint.insert_of_not_mem (hs : s.PairwiseDisjoint f) {i : ι} (hi : i ∉ s)
    (h : ∀ j ∈ s, Disjoint (f i) (f j)) : (insert i s).PairwiseDisjoint f :=
  (Set.pairwise_disjoint_insert_of_not_mem hi).2 ⟨hs, h⟩
#align set.pairwise_disjoint.insert_of_not_mem Set.PairwiseDisjoint.insert_of_not_mem

theorem PairwiseDisjoint.image_of_le (hs : s.PairwiseDisjoint f) {g : ι → ι} (hg : f ∘ g ≤ f) :
    (g '' s).PairwiseDisjoint f :=
  by
  rintro _ ⟨a, ha, rfl⟩ _ ⟨b, hb, rfl⟩ h
  exact (hs ha hb <| ne_of_apply_ne _ h).mono (hg a) (hg b)
#align set.pairwise_disjoint.image_of_le Set.PairwiseDisjoint.image_of_le

theorem InjOn.pairwise_disjoint_image {g : ι' → ι} {s : Set ι'} (h : s.InjOn g) :
    (g '' s).PairwiseDisjoint f ↔ s.PairwiseDisjoint (f ∘ g) :=
  h.pairwise_image
#align set.inj_on.pairwise_disjoint_image Set.InjOn.pairwise_disjoint_image

theorem PairwiseDisjoint.range (g : s → ι) (hg : ∀ i : s, f (g i) ≤ f i)
    (ht : s.PairwiseDisjoint f) : (range g).PairwiseDisjoint f :=
  by
  rintro _ ⟨x, rfl⟩ _ ⟨y, rfl⟩ hxy
  exact ((ht x.2 y.2) fun h => hxy <| congr_arg g <| Subtype.ext h).mono (hg x) (hg y)
#align set.pairwise_disjoint.range Set.PairwiseDisjoint.range

theorem pairwise_disjoint_union :
    (s ∪ t).PairwiseDisjoint f ↔
      s.PairwiseDisjoint f ∧
        t.PairwiseDisjoint f ∧ ∀ ⦃i⦄, i ∈ s → ∀ ⦃j⦄, j ∈ t → i ≠ j → Disjoint (f i) (f j) :=
  pairwise_union_of_symmetric <| symmetric_disjoint.comap f
#align set.pairwise_disjoint_union Set.pairwise_disjoint_union

theorem PairwiseDisjoint.union (hs : s.PairwiseDisjoint f) (ht : t.PairwiseDisjoint f)
    (h : ∀ ⦃i⦄, i ∈ s → ∀ ⦃j⦄, j ∈ t → i ≠ j → Disjoint (f i) (f j)) : (s ∪ t).PairwiseDisjoint f :=
  pairwise_disjoint_union.2 ⟨hs, ht, h⟩
#align set.pairwise_disjoint.union Set.PairwiseDisjoint.union

theorem pairwise_disjoint_Union {g : ι' → Set ι} (h : Directed (· ⊆ ·) g) :
    (⋃ n, g n).PairwiseDisjoint f ↔ ∀ ⦃n⦄, (g n).PairwiseDisjoint f :=
  pairwise_Union h
#align set.pairwise_disjoint_Union Set.pairwise_disjoint_Union

theorem pairwise_disjoint_sUnion {s : Set (Set ι)} (h : DirectedOn (· ⊆ ·) s) :
    (⋃₀s).PairwiseDisjoint f ↔ ∀ ⦃a⦄, a ∈ s → Set.PairwiseDisjoint a f :=
  pairwise_sUnion h
#align set.pairwise_disjoint_sUnion Set.pairwise_disjoint_sUnion

-- classical
theorem PairwiseDisjoint.elim (hs : s.PairwiseDisjoint f) {i j : ι} (hi : i ∈ s) (hj : j ∈ s)
    (h : ¬Disjoint (f i) (f j)) : i = j :=
  hs.Eq hi hj h
#align set.pairwise_disjoint.elim Set.PairwiseDisjoint.elim

end PartialOrderBot

section SemilatticeInfBot

variable [SemilatticeInf α] [OrderBot α] {s t : Set ι} {f g : ι → α}

-- classical
theorem PairwiseDisjoint.elim' (hs : s.PairwiseDisjoint f) {i j : ι} (hi : i ∈ s) (hj : j ∈ s)
    (h : f i ⊓ f j ≠ ⊥) : i = j :=
  (hs.elim hi hj) fun hij => h hij.eq_bot
#align set.pairwise_disjoint.elim' Set.PairwiseDisjoint.elim'

theorem PairwiseDisjoint.eq_of_le (hs : s.PairwiseDisjoint f) {i j : ι} (hi : i ∈ s) (hj : j ∈ s)
    (hf : f i ≠ ⊥) (hij : f i ≤ f j) : i = j :=
  (hs.elim' hi hj) fun h => hf <| (inf_of_le_left hij).symm.trans h
#align set.pairwise_disjoint.eq_of_le Set.PairwiseDisjoint.eq_of_le

end SemilatticeInfBot

section CompleteLattice

variable [CompleteLattice α]

/-- Bind operation for `set.pairwise_disjoint`. If you want to only consider finsets of indices, you
can use `set.pairwise_disjoint.bUnion_finset`. -/
theorem PairwiseDisjoint.bUnion {s : Set ι'} {g : ι' → Set ι} {f : ι → α}
    (hs : s.PairwiseDisjoint fun i' : ι' => ⨆ i ∈ g i', f i)
    (hg : ∀ i ∈ s, (g i).PairwiseDisjoint f) : (⋃ i ∈ s, g i).PairwiseDisjoint f :=
  by
  rintro a ha b hb hab
  simp_rw [Set.mem_unionᵢ] at ha hb
  obtain ⟨c, hc, ha⟩ := ha
  obtain ⟨d, hd, hb⟩ := hb
  obtain hcd | hcd := eq_or_ne (g c) (g d)
  · exact hg d hd (hcd.subst ha) hb hab
  · exact (hs hc hd <| ne_of_apply_ne _ hcd).mono (le_supᵢ₂ a ha) (le_supᵢ₂ b hb)
#align set.pairwise_disjoint.bUnion Set.PairwiseDisjoint.bUnion

end CompleteLattice

/-! ### Pairwise disjoint set of sets -/


theorem pairwise_disjoint_range_singleton :
    (Set.range (singleton : ι → Set ι)).PairwiseDisjoint id :=
  by
  rintro _ ⟨a, rfl⟩ _ ⟨b, rfl⟩ h
  exact disjoint_singleton.2 (ne_of_apply_ne _ h)
#align set.pairwise_disjoint_range_singleton Set.pairwise_disjoint_range_singleton

theorem pairwise_disjoint_fiber (f : ι → α) (s : Set α) : s.PairwiseDisjoint fun a => f ⁻¹' {a} :=
  fun a _ b _ h => disjoint_iff_inf_le.mpr fun i ⟨hia, hib⟩ => h <| (Eq.symm hia).trans hib
#align set.pairwise_disjoint_fiber Set.pairwise_disjoint_fiber

-- classical
theorem PairwiseDisjoint.elim_set {s : Set ι} {f : ι → Set α} (hs : s.PairwiseDisjoint f) {i j : ι}
    (hi : i ∈ s) (hj : j ∈ s) (a : α) (hai : a ∈ f i) (haj : a ∈ f j) : i = j :=
  hs.elim hi hj <| not_disjoint_iff.2 ⟨a, hai, haj⟩
#align set.pairwise_disjoint.elim_set Set.PairwiseDisjoint.elim_set

theorem bUnion_diff_bUnion_eq {s t : Set ι} {f : ι → Set α} (h : (s ∪ t).PairwiseDisjoint f) :
    ((⋃ i ∈ s, f i) \ ⋃ i ∈ t, f i) = ⋃ i ∈ s \ t, f i :=
  by
  refine'
    (bUnion_diff_bUnion_subset f s t).antisymm
      (Union₂_subset fun i hi a ha => (mem_diff _).2 ⟨mem_bUnion hi.1 ha, _⟩)
  rw [mem_Union₂]; rintro ⟨j, hj, haj⟩
  exact (h (Or.inl hi.1) (Or.inr hj) (ne_of_mem_of_not_mem hj hi.2).symm).le_bot ⟨ha, haj⟩
#align set.bUnion_diff_bUnion_eq Set.bUnion_diff_bUnion_eq

/-- Equivalence between a disjoint bounded union and a dependent sum. -/
noncomputable def bUnionEqSigmaOfDisjoint {s : Set ι} {f : ι → Set α} (h : s.PairwiseDisjoint f) :
    (⋃ i ∈ s, f i) ≃ Σi : s, f i :=
  (Equiv.setCongr (bunionᵢ_eq_unionᵢ _ _)).trans <|
    Union_eq_sigma_of_disjoint fun ⟨i, hi⟩ ⟨j, hj⟩ ne => (h hi hj) fun eq => Ne <| Subtype.eq Eq
#align set.bUnion_eq_sigma_of_disjoint Set.bUnionEqSigmaOfDisjoint

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The partial images of a binary function `f` whose partial evaluations are injective are pairwise
disjoint iff `f` is injective . -/
theorem pairwise_disjoint_image_right_iff {f : α → β → γ} {s : Set α} {t : Set β}
    (hf : ∀ a ∈ s, Injective (f a)) :
    (s.PairwiseDisjoint fun a => f a '' t) ↔ (s ×ˢ t).InjOn fun p => f p.1 p.2 :=
  by
  refine' ⟨fun hs x hx y hy (h : f _ _ = _) => _, fun hs x hx y hy h => _⟩
  · suffices x.1 = y.1 by exact Prod.ext this (hf _ hx.1 <| h.trans <| by rw [this])
    refine' hs.elim hx.1 hy.1 (not_disjoint_iff.2 ⟨_, mem_image_of_mem _ hx.2, _⟩)
    rw [h]
    exact mem_image_of_mem _ hy.2
  · refine' disjoint_iff_inf_le.mpr _
    rintro _ ⟨⟨a, ha, hab⟩, b, hb, rfl⟩
    exact h (congr_arg Prod.fst <| hs (mk_mem_prod hx ha) (mk_mem_prod hy hb) hab)
#align set.pairwise_disjoint_image_right_iff Set.pairwise_disjoint_image_right_iff

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The partial images of a binary function `f` whose partial evaluations are injective are pairwise
disjoint iff `f` is injective . -/
theorem pairwise_disjoint_image_left_iff {f : α → β → γ} {s : Set α} {t : Set β}
    (hf : ∀ b ∈ t, Injective fun a => f a b) :
    (t.PairwiseDisjoint fun b => (fun a => f a b) '' s) ↔ (s ×ˢ t).InjOn fun p => f p.1 p.2 :=
  by
  refine' ⟨fun ht x hx y hy (h : f _ _ = _) => _, fun ht x hx y hy h => _⟩
  · suffices x.2 = y.2 by exact Prod.ext (hf _ hx.2 <| h.trans <| by rw [this]) this
    refine' ht.elim hx.2 hy.2 (not_disjoint_iff.2 ⟨_, mem_image_of_mem _ hx.1, _⟩)
    rw [h]
    exact mem_image_of_mem _ hy.1
  · refine' disjoint_iff_inf_le.mpr _
    rintro _ ⟨⟨a, ha, hab⟩, b, hb, rfl⟩
    exact h (congr_arg Prod.snd <| ht (mk_mem_prod ha hx) (mk_mem_prod hb hy) hab)
#align set.pairwise_disjoint_image_left_iff Set.pairwise_disjoint_image_left_iff

end Set

theorem pairwise_disjoint_fiber (f : ι → α) : Pairwise (Disjoint on fun a : α => f ⁻¹' {a}) :=
  Set.pairwise_univ.1 <| Set.pairwise_disjoint_fiber f univ
#align pairwise_disjoint_fiber pairwise_disjoint_fiber

section

variable {f : ι → Set α} {s t : Set ι}

theorem Set.PairwiseDisjoint.subset_of_bUnion_subset_bUnion (h₀ : (s ∪ t).PairwiseDisjoint f)
    (h₁ : ∀ i ∈ s, (f i).Nonempty) (h : (⋃ i ∈ s, f i) ⊆ ⋃ i ∈ t, f i) : s ⊆ t :=
  by
  rintro i hi
  obtain ⟨a, hai⟩ := h₁ i hi
  obtain ⟨j, hj, haj⟩ := mem_Union₂.1 (h <| mem_Union₂_of_mem hi hai)
  rwa [h₀.eq (subset_union_left _ _ hi) (subset_union_right _ _ hj)
      (not_disjoint_iff.2 ⟨a, hai, haj⟩)]
#align
  set.pairwise_disjoint.subset_of_bUnion_subset_bUnion Set.PairwiseDisjoint.subset_of_bUnion_subset_bUnion

theorem Pairwise.subset_of_bUnion_subset_bUnion (h₀ : Pairwise (Disjoint on f))
    (h₁ : ∀ i ∈ s, (f i).Nonempty) (h : (⋃ i ∈ s, f i) ⊆ ⋃ i ∈ t, f i) : s ⊆ t :=
  Set.PairwiseDisjoint.subset_of_bUnion_subset_bUnion (h₀.set_pairwise _) h₁ h
#align pairwise.subset_of_bUnion_subset_bUnion Pairwise.subset_of_bUnion_subset_bUnion

theorem Pairwise.bUnion_injective (h₀ : Pairwise (Disjoint on f)) (h₁ : ∀ i, (f i).Nonempty) :
    Injective fun s : Set ι => ⋃ i ∈ s, f i := fun s t h =>
  ((h₀.subset_of_bUnion_subset_bUnion fun _ _ => h₁ _) <| h.Subset).antisymm <|
    (h₀.subset_of_bUnion_subset_bUnion fun _ _ => h₁ _) <| h.Superset
#align pairwise.bUnion_injective Pairwise.bUnion_injective

end

