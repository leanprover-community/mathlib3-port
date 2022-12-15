/-
Copyright (c) 2018 Sean Leather. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sean Leather, Mario Carneiro

! This file was ported from Lean 3 source module data.finmap
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.Alist
import Mathbin.Data.Finset.Basic
import Mathbin.Data.Part

/-!
# Finite maps over `multiset`
-/


universe u v w

open List

variable {α : Type u} {β : α → Type v}

/-! ### multisets of sigma types-/


namespace Multiset

/-- Multiset of keys of an association multiset. -/
def keys (s : Multiset (Sigma β)) : Multiset α :=
  s.map Sigma.fst
#align multiset.keys Multiset.keys

@[simp]
theorem coe_keys {l : List (Sigma β)} : keys (l : Multiset (Sigma β)) = (l.keys : Multiset α) :=
  rfl
#align multiset.coe_keys Multiset.coe_keys

/-- `nodupkeys s` means that `s` has no duplicate keys. -/
def Nodupkeys (s : Multiset (Sigma β)) : Prop :=
  Quot.liftOn s List.Nodupkeys fun s t p => propext <| perm_nodupkeys p
#align multiset.nodupkeys Multiset.Nodupkeys

@[simp]
theorem coe_nodupkeys {l : List (Sigma β)} : @Nodupkeys α β l ↔ l.Nodupkeys :=
  Iff.rfl
#align multiset.coe_nodupkeys Multiset.coe_nodupkeys

end Multiset

/-! ### finmap -/


/-- `finmap β` is the type of finite maps over a multiset. It is effectively
  a quotient of `alist β` by permutation of the underlying list. -/
structure Finmap (β : α → Type v) : Type max u v where
  entries : Multiset (Sigma β)
  Nodupkeys : entries.Nodupkeys
#align finmap Finmap

/-- The quotient map from `alist` to `finmap`. -/
def Alist.toFinmap (s : Alist β) : Finmap β :=
  ⟨s.entries, s.Nodupkeys⟩
#align alist.to_finmap Alist.toFinmap

-- mathport name: to_finmap
local notation:arg "⟦" a "⟧" => Alist.toFinmap a

theorem Alist.to_finmap_eq {s₁ s₂ : Alist β} : ⟦s₁⟧ = ⟦s₂⟧ ↔ s₁.entries ~ s₂.entries := by
  cases s₁ <;> cases s₂ <;> simp [Alist.toFinmap]
#align alist.to_finmap_eq Alist.to_finmap_eq

@[simp]
theorem Alist.to_finmap_entries (s : Alist β) : ⟦s⟧.entries = s.entries :=
  rfl
#align alist.to_finmap_entries Alist.to_finmap_entries

/-- Given `l : list (sigma β)`, create a term of type `finmap β` by removing
entries with duplicate keys. -/
def List.toFinmap [DecidableEq α] (s : List (Sigma β)) : Finmap β :=
  s.toAlist.toFinmap
#align list.to_finmap List.toFinmap

namespace Finmap

open Alist

/-! ### lifting from alist -/


/-- Lift a permutation-respecting function on `alist` to `finmap`. -/
@[elab_as_elim]
def liftOn {γ} (s : Finmap β) (f : Alist β → γ)
    (H : ∀ a b : Alist β, a.entries ~ b.entries → f a = f b) : γ := by
  refine'
    (Quotient.liftOn s.1 (fun l => (⟨_, fun nd => f ⟨l, nd⟩⟩ : Part γ)) fun l₁ l₂ p =>
            Part.ext' (perm_nodupkeys p) _ :
          Part γ).get
      _
  · exact fun h₁ h₂ => H _ _ p
  · have := s.nodupkeys
    rcases s.entries with ⟨l⟩
    exact id
#align finmap.lift_on Finmap.liftOn

@[simp]
theorem lift_on_to_finmap {γ} (s : Alist β) (f : Alist β → γ) (H) : liftOn ⟦s⟧ f H = f s := by
  cases s <;> rfl
#align finmap.lift_on_to_finmap Finmap.lift_on_to_finmap

/-- Lift a permutation-respecting function on 2 `alist`s to 2 `finmap`s. -/
@[elab_as_elim]
def liftOn₂ {γ} (s₁ s₂ : Finmap β) (f : Alist β → Alist β → γ)
    (H :
      ∀ a₁ b₁ a₂ b₂ : Alist β,
        a₁.entries ~ a₂.entries → b₁.entries ~ b₂.entries → f a₁ b₁ = f a₂ b₂) :
    γ :=
  liftOn s₁ (fun l₁ => liftOn s₂ (f l₁) fun b₁ b₂ p => H _ _ _ _ (Perm.refl _) p) fun a₁ a₂ p => by
    have H' : f a₁ = f a₂ := funext fun _ => H _ _ _ _ p (Perm.refl _)
    simp only [H']
#align finmap.lift_on₂ Finmap.liftOn₂

@[simp]
theorem lift_on₂_to_finmap {γ} (s₁ s₂ : Alist β) (f : Alist β → Alist β → γ) (H) :
    liftOn₂ ⟦s₁⟧ ⟦s₂⟧ f H = f s₁ s₂ := by cases s₁ <;> cases s₂ <;> rfl
#align finmap.lift_on₂_to_finmap Finmap.lift_on₂_to_finmap

/-! ### induction -/


@[elab_as_elim]
theorem induction_on {C : Finmap β → Prop} (s : Finmap β) (H : ∀ a : Alist β, C ⟦a⟧) : C s := by
  rcases s with ⟨⟨a⟩, h⟩ <;> exact H ⟨a, h⟩
#align finmap.induction_on Finmap.induction_on

@[elab_as_elim]
theorem induction_on₂ {C : Finmap β → Finmap β → Prop} (s₁ s₂ : Finmap β)
    (H : ∀ a₁ a₂ : Alist β, C ⟦a₁⟧ ⟦a₂⟧) : C s₁ s₂ :=
  (induction_on s₁) fun l₁ => (induction_on s₂) fun l₂ => H l₁ l₂
#align finmap.induction_on₂ Finmap.induction_on₂

@[elab_as_elim]
theorem induction_on₃ {C : Finmap β → Finmap β → Finmap β → Prop} (s₁ s₂ s₃ : Finmap β)
    (H : ∀ a₁ a₂ a₃ : Alist β, C ⟦a₁⟧ ⟦a₂⟧ ⟦a₃⟧) : C s₁ s₂ s₃ :=
  (induction_on₂ s₁ s₂) fun l₁ l₂ => (induction_on s₃) fun l₃ => H l₁ l₂ l₃
#align finmap.induction_on₃ Finmap.induction_on₃

/-! ### extensionality -/


@[ext]
theorem ext : ∀ {s t : Finmap β}, s.entries = t.entries → s = t
  | ⟨l₁, h₁⟩, ⟨l₂, h₂⟩, H => by congr
#align finmap.ext Finmap.ext

@[simp]
theorem ext_iff {s t : Finmap β} : s.entries = t.entries ↔ s = t :=
  ⟨ext, congr_arg _⟩
#align finmap.ext_iff Finmap.ext_iff

/-! ### mem -/


/-- The predicate `a ∈ s` means that `s` has a value associated to the key `a`. -/
instance : Membership α (Finmap β) :=
  ⟨fun a s => a ∈ s.entries.keys⟩

theorem mem_def {a : α} {s : Finmap β} : a ∈ s ↔ a ∈ s.entries.keys :=
  Iff.rfl
#align finmap.mem_def Finmap.mem_def

@[simp]
theorem mem_to_finmap {a : α} {s : Alist β} : a ∈ ⟦s⟧ ↔ a ∈ s :=
  Iff.rfl
#align finmap.mem_to_finmap Finmap.mem_to_finmap

/-! ### keys -/


/-- The set of keys of a finite map. -/
def keys (s : Finmap β) : Finset α :=
  ⟨s.entries.keys, induction_on s keys_nodup⟩
#align finmap.keys Finmap.keys

@[simp]
theorem keys_val (s : Alist β) : (keys ⟦s⟧).val = s.keys :=
  rfl
#align finmap.keys_val Finmap.keys_val

@[simp]
theorem keys_ext {s₁ s₂ : Alist β} : keys ⟦s₁⟧ = keys ⟦s₂⟧ ↔ s₁.keys ~ s₂.keys := by
  simp [keys, Alist.keys]
#align finmap.keys_ext Finmap.keys_ext

theorem mem_keys {a : α} {s : Finmap β} : a ∈ s.keys ↔ a ∈ s :=
  (induction_on s) fun s => Alist.mem_keys
#align finmap.mem_keys Finmap.mem_keys

/-! ### empty -/


/-- The empty map. -/
instance : EmptyCollection (Finmap β) :=
  ⟨⟨0, nodupkeys_nil⟩⟩

instance : Inhabited (Finmap β) :=
  ⟨∅⟩

@[simp]
theorem empty_to_finmap : (⟦∅⟧ : Finmap β) = ∅ :=
  rfl
#align finmap.empty_to_finmap Finmap.empty_to_finmap

@[simp]
theorem to_finmap_nil [DecidableEq α] : ([].toFinmap : Finmap β) = ∅ :=
  rfl
#align finmap.to_finmap_nil Finmap.to_finmap_nil

theorem not_mem_empty {a : α} : a ∉ (∅ : Finmap β) :=
  Multiset.not_mem_zero a
#align finmap.not_mem_empty Finmap.not_mem_empty

@[simp]
theorem keys_empty : (∅ : Finmap β).keys = ∅ :=
  rfl
#align finmap.keys_empty Finmap.keys_empty

/-! ### singleton -/


/-- The singleton map. -/
def singleton (a : α) (b : β a) : Finmap β :=
  ⟦Alist.singleton a b⟧
#align finmap.singleton Finmap.singleton

@[simp]
theorem keys_singleton (a : α) (b : β a) : (singleton a b).keys = {a} :=
  rfl
#align finmap.keys_singleton Finmap.keys_singleton

@[simp]
theorem mem_singleton (x y : α) (b : β y) : x ∈ singleton y b ↔ x = y := by
  simp only [singleton] <;> erw [mem_cons_eq, mem_nil_iff, or_false_iff]
#align finmap.mem_singleton Finmap.mem_singleton

section

variable [DecidableEq α]

instance hasDecidableEq [∀ a, DecidableEq (β a)] : DecidableEq (Finmap β)
  | s₁, s₂ => decidable_of_iff _ ext_iff
#align finmap.has_decidable_eq Finmap.hasDecidableEq

/-! ### lookup -/


/-- Look up the value associated to a key in a map. -/
def lookup (a : α) (s : Finmap β) : Option (β a) :=
  liftOn s (lookup a) fun s t => perm_lookup
#align finmap.lookup Finmap.lookup

@[simp]
theorem lookup_to_finmap (a : α) (s : Alist β) : lookup a ⟦s⟧ = s.lookup a :=
  rfl
#align finmap.lookup_to_finmap Finmap.lookup_to_finmap

@[simp]
theorem lookup_list_to_finmap (a : α) (s : List (Sigma β)) : lookup a s.toFinmap = s.lookup a := by
  rw [List.toFinmap, lookup_to_finmap, lookup_to_alist]
#align finmap.lookup_list_to_finmap Finmap.lookup_list_to_finmap

@[simp]
theorem lookup_empty (a) : lookup a (∅ : Finmap β) = none :=
  rfl
#align finmap.lookup_empty Finmap.lookup_empty

theorem lookup_is_some {a : α} {s : Finmap β} : (s.lookup a).isSome ↔ a ∈ s :=
  (induction_on s) fun s => Alist.lookup_is_some
#align finmap.lookup_is_some Finmap.lookup_is_some

theorem lookup_eq_none {a} {s : Finmap β} : lookup a s = none ↔ a ∉ s :=
  (induction_on s) fun s => Alist.lookup_eq_none
#align finmap.lookup_eq_none Finmap.lookup_eq_none

@[simp]
theorem lookup_singleton_eq {a : α} {b : β a} : (singleton a b).lookup a = some b := by
  rw [singleton, lookup_to_finmap, Alist.singleton, Alist.lookup, lookup_cons_eq]
#align finmap.lookup_singleton_eq Finmap.lookup_singleton_eq

instance (a : α) (s : Finmap β) : Decidable (a ∈ s) :=
  decidable_of_iff _ lookup_is_some

theorem mem_iff {a : α} {s : Finmap β} : a ∈ s ↔ ∃ b, s.lookup a = some b :=
  (induction_on s) fun s =>
    Iff.trans List.mem_keys <| exists_congr fun b => (mem_lookup_iff s.Nodupkeys).symm
#align finmap.mem_iff Finmap.mem_iff

theorem mem_of_lookup_eq_some {a : α} {b : β a} {s : Finmap β} (h : s.lookup a = some b) : a ∈ s :=
  mem_iff.mpr ⟨_, h⟩
#align finmap.mem_of_lookup_eq_some Finmap.mem_of_lookup_eq_some

theorem ext_lookup {s₁ s₂ : Finmap β} : (∀ x, s₁.lookup x = s₂.lookup x) → s₁ = s₂ :=
  (induction_on₂ s₁ s₂) fun s₁ s₂ h => by
    simp only [Alist.lookup, lookup_to_finmap] at h
    rw [Alist.to_finmap_eq]
    apply lookup_ext s₁.nodupkeys s₂.nodupkeys
    intro x y
    rw [h]
#align finmap.ext_lookup Finmap.ext_lookup

/-! ### replace -/


/-- Replace a key with a given value in a finite map.
  If the key is not present it does nothing. -/
def replace (a : α) (b : β a) (s : Finmap β) : Finmap β :=
  (liftOn s fun t => ⟦replace a b t⟧) fun s₁ s₂ p => to_finmap_eq.2 <| perm_replace p
#align finmap.replace Finmap.replace

@[simp]
theorem replace_to_finmap (a : α) (b : β a) (s : Alist β) : replace a b ⟦s⟧ = ⟦s.replace a b⟧ := by
  simp [replace]
#align finmap.replace_to_finmap Finmap.replace_to_finmap

@[simp]
theorem keys_replace (a : α) (b : β a) (s : Finmap β) : (replace a b s).keys = s.keys :=
  (induction_on s) fun s => by simp
#align finmap.keys_replace Finmap.keys_replace

@[simp]
theorem mem_replace {a a' : α} {b : β a} {s : Finmap β} : a' ∈ replace a b s ↔ a' ∈ s :=
  (induction_on s) fun s => by simp
#align finmap.mem_replace Finmap.mem_replace

end

/-! ### foldl -/


/-- Fold a commutative function over the key-value pairs in the map -/
def foldl {δ : Type w} (f : δ → ∀ a, β a → δ)
    (H : ∀ d a₁ b₁ a₂ b₂, f (f d a₁ b₁) a₂ b₂ = f (f d a₂ b₂) a₁ b₁) (d : δ) (m : Finmap β) : δ :=
  m.entries.foldl (fun d s => f d s.1 s.2) (fun d s t => H _ _ _ _ _) d
#align finmap.foldl Finmap.foldl

/-- `any f s` returns `tt` iff there exists a value `v` in `s` such that `f v = tt`. -/
def any (f : ∀ x, β x → Bool) (s : Finmap β) : Bool :=
  s.foldl (fun x y z => x ∨ f y z)
    (by 
      intros
      simp [or_right_comm])
    false
#align finmap.any Finmap.any

/-- `all f s` returns `tt` iff `f v = tt` for all values `v` in `s`. -/
def all (f : ∀ x, β x → Bool) (s : Finmap β) : Bool :=
  s.foldl (fun x y z => x ∧ f y z)
    (by 
      intros
      simp [and_right_comm])
    false
#align finmap.all Finmap.all

/-! ### erase -/


section

variable [DecidableEq α]

/-- Erase a key from the map. If the key is not present it does nothing. -/
def erase (a : α) (s : Finmap β) : Finmap β :=
  (liftOn s fun t => ⟦erase a t⟧) fun s₁ s₂ p => to_finmap_eq.2 <| perm_erase p
#align finmap.erase Finmap.erase

@[simp]
theorem erase_to_finmap (a : α) (s : Alist β) : erase a ⟦s⟧ = ⟦s.erase a⟧ := by simp [erase]
#align finmap.erase_to_finmap Finmap.erase_to_finmap

@[simp]
theorem keys_erase_to_finset (a : α) (s : Alist β) : keys ⟦s.erase a⟧ = (keys ⟦s⟧).erase a := by
  simp [Finset.erase, keys, Alist.erase, keys_kerase]
#align finmap.keys_erase_to_finset Finmap.keys_erase_to_finset

@[simp]
theorem keys_erase (a : α) (s : Finmap β) : (erase a s).keys = s.keys.erase a :=
  (induction_on s) fun s => by simp
#align finmap.keys_erase Finmap.keys_erase

@[simp]
theorem mem_erase {a a' : α} {s : Finmap β} : a' ∈ erase a s ↔ a' ≠ a ∧ a' ∈ s :=
  (induction_on s) fun s => by simp
#align finmap.mem_erase Finmap.mem_erase

theorem not_mem_erase_self {a : α} {s : Finmap β} : ¬a ∈ erase a s := by
  rw [mem_erase, not_and_or, not_not] <;> left <;> rfl
#align finmap.not_mem_erase_self Finmap.not_mem_erase_self

@[simp]
theorem lookup_erase (a) (s : Finmap β) : lookup a (erase a s) = none :=
  induction_on s <| lookup_erase a
#align finmap.lookup_erase Finmap.lookup_erase

@[simp]
theorem lookup_erase_ne {a a'} {s : Finmap β} (h : a ≠ a') : lookup a (erase a' s) = lookup a s :=
  (induction_on s) fun s => lookup_erase_ne h
#align finmap.lookup_erase_ne Finmap.lookup_erase_ne

theorem erase_erase {a a' : α} {s : Finmap β} : erase a (erase a' s) = erase a' (erase a s) :=
  (induction_on s) fun s => ext (by simp only [erase_erase, erase_to_finmap])
#align finmap.erase_erase Finmap.erase_erase

/-! ### sdiff -/


/-- `sdiff s s'` consists of all key-value pairs from `s` and `s'` where the keys are in `s` or
`s'` but not both. -/
def sdiff (s s' : Finmap β) : Finmap β :=
  s'.foldl (fun s x _ => s.erase x) (fun a₀ a₁ _ a₂ _ => erase_erase) s
#align finmap.sdiff Finmap.sdiff

instance : SDiff (Finmap β) :=
  ⟨sdiff⟩

/-! ### insert -/


/-- Insert a key-value pair into a finite map, replacing any existing pair with
  the same key. -/
def insert (a : α) (b : β a) (s : Finmap β) : Finmap β :=
  (liftOn s fun t => ⟦insert a b t⟧) fun s₁ s₂ p => to_finmap_eq.2 <| perm_insert p
#align finmap.insert Finmap.insert

@[simp]
theorem insert_to_finmap (a : α) (b : β a) (s : Alist β) : insert a b ⟦s⟧ = ⟦s.insert a b⟧ := by
  simp [insert]
#align finmap.insert_to_finmap Finmap.insert_to_finmap

theorem insert_entries_of_neg {a : α} {b : β a} {s : Finmap β} :
    a ∉ s → (insert a b s).entries = ⟨a, b⟩ ::ₘ s.entries :=
  (induction_on s) fun s h => by simp [insert_entries_of_neg (mt mem_to_finmap.1 h)]
#align finmap.insert_entries_of_neg Finmap.insert_entries_of_neg

@[simp]
theorem mem_insert {a a' : α} {b' : β a'} {s : Finmap β} : a ∈ insert a' b' s ↔ a = a' ∨ a ∈ s :=
  induction_on s mem_insert
#align finmap.mem_insert Finmap.mem_insert

@[simp]
theorem lookup_insert {a} {b : β a} (s : Finmap β) : lookup a (insert a b s) = some b :=
  (induction_on s) fun s => by simp only [insert_to_finmap, lookup_to_finmap, lookup_insert]
#align finmap.lookup_insert Finmap.lookup_insert

@[simp]
theorem lookup_insert_of_ne {a a'} {b : β a} (s : Finmap β) (h : a' ≠ a) :
    lookup a' (insert a b s) = lookup a' s :=
  (induction_on s) fun s => by simp only [insert_to_finmap, lookup_to_finmap, lookup_insert_ne h]
#align finmap.lookup_insert_of_ne Finmap.lookup_insert_of_ne

@[simp]
theorem insert_insert {a} {b b' : β a} (s : Finmap β) :
    (s.insert a b).insert a b' = s.insert a b' :=
  (induction_on s) fun s => by simp only [insert_to_finmap, insert_insert]
#align finmap.insert_insert Finmap.insert_insert

theorem insert_insert_of_ne {a a'} {b : β a} {b' : β a'} (s : Finmap β) (h : a ≠ a') :
    (s.insert a b).insert a' b' = (s.insert a' b').insert a b :=
  (induction_on s) fun s => by
    simp only [insert_to_finmap, Alist.to_finmap_eq, insert_insert_of_ne _ h]
#align finmap.insert_insert_of_ne Finmap.insert_insert_of_ne

theorem to_finmap_cons (a : α) (b : β a) (xs : List (Sigma β)) :
    List.toFinmap (⟨a, b⟩ :: xs) = insert a b xs.toFinmap :=
  rfl
#align finmap.to_finmap_cons Finmap.to_finmap_cons

theorem mem_list_to_finmap (a : α) (xs : List (Sigma β)) :
    a ∈ xs.toFinmap ↔ ∃ b : β a, Sigma.mk a b ∈ xs := by
  induction' xs with x xs <;> [skip, cases x] <;>
      simp only [to_finmap_cons, *, not_mem_empty, exists_or, not_mem_nil, to_finmap_nil,
        exists_false, mem_cons_iff, mem_insert, exists_and_left] <;>
    apply or_congr _ Iff.rfl
  conv => 
    lhs
    rw [← and_true_iff (a = x_fst)]
  apply and_congr_right
  rintro ⟨⟩
  simp only [exists_eq, heq_iff_eq]
#align finmap.mem_list_to_finmap Finmap.mem_list_to_finmap

@[simp]
theorem insert_singleton_eq {a : α} {b b' : β a} : insert a b (singleton a b') = singleton a b := by
  simp only [singleton, Finmap.insert_to_finmap, Alist.insert_singleton_eq]
#align finmap.insert_singleton_eq Finmap.insert_singleton_eq

/-! ### extract -/


/-- Erase a key from the map, and return the corresponding value, if found. -/
def extract (a : α) (s : Finmap β) : Option (β a) × Finmap β :=
  (liftOn s fun t => Prod.map id toFinmap (extract a t)) fun s₁ s₂ p => by
    simp [perm_lookup p, to_finmap_eq, perm_erase p]
#align finmap.extract Finmap.extract

@[simp]
theorem extract_eq_lookup_erase (a : α) (s : Finmap β) : extract a s = (lookup a s, erase a s) :=
  (induction_on s) fun s => by simp [extract]
#align finmap.extract_eq_lookup_erase Finmap.extract_eq_lookup_erase

/-! ### union -/


/-- `s₁ ∪ s₂` is the key-based union of two finite maps. It is left-biased: if
there exists an `a ∈ s₁`, `lookup a (s₁ ∪ s₂) = lookup a s₁`. -/
def union (s₁ s₂ : Finmap β) : Finmap β :=
  (liftOn₂ s₁ s₂ fun s₁ s₂ => ⟦s₁ ∪ s₂⟧) fun s₁ s₂ s₃ s₄ p₁₃ p₂₄ =>
    to_finmap_eq.mpr <| perm_union p₁₃ p₂₄
#align finmap.union Finmap.union

instance : Union (Finmap β) :=
  ⟨union⟩

@[simp]
theorem mem_union {a} {s₁ s₂ : Finmap β} : a ∈ s₁ ∪ s₂ ↔ a ∈ s₁ ∨ a ∈ s₂ :=
  (induction_on₂ s₁ s₂) fun _ _ => mem_union
#align finmap.mem_union Finmap.mem_union

@[simp]
theorem union_to_finmap (s₁ s₂ : Alist β) : ⟦s₁⟧ ∪ ⟦s₂⟧ = ⟦s₁ ∪ s₂⟧ := by simp [(· ∪ ·), union]
#align finmap.union_to_finmap Finmap.union_to_finmap

theorem keys_union {s₁ s₂ : Finmap β} : (s₁ ∪ s₂).keys = s₁.keys ∪ s₂.keys :=
  (induction_on₂ s₁ s₂) fun s₁ s₂ => Finset.ext <| by simp [keys]
#align finmap.keys_union Finmap.keys_union

@[simp]
theorem lookup_union_left {a} {s₁ s₂ : Finmap β} : a ∈ s₁ → lookup a (s₁ ∪ s₂) = lookup a s₁ :=
  (induction_on₂ s₁ s₂) fun s₁ s₂ => lookup_union_left
#align finmap.lookup_union_left Finmap.lookup_union_left

@[simp]
theorem lookup_union_right {a} {s₁ s₂ : Finmap β} : a ∉ s₁ → lookup a (s₁ ∪ s₂) = lookup a s₂ :=
  (induction_on₂ s₁ s₂) fun s₁ s₂ => lookup_union_right
#align finmap.lookup_union_right Finmap.lookup_union_right

theorem lookup_union_left_of_not_in {a} {s₁ s₂ : Finmap β} (h : a ∉ s₂) :
    lookup a (s₁ ∪ s₂) = lookup a s₁ := by
  by_cases h' : a ∈ s₁
  · rw [lookup_union_left h']
  · rw [lookup_union_right h', lookup_eq_none.mpr h, lookup_eq_none.mpr h']
#align finmap.lookup_union_left_of_not_in Finmap.lookup_union_left_of_not_in

@[simp]
theorem mem_lookup_union {a} {b : β a} {s₁ s₂ : Finmap β} :
    b ∈ lookup a (s₁ ∪ s₂) ↔ b ∈ lookup a s₁ ∨ a ∉ s₁ ∧ b ∈ lookup a s₂ :=
  (induction_on₂ s₁ s₂) fun s₁ s₂ => mem_lookup_union
#align finmap.mem_lookup_union Finmap.mem_lookup_union

theorem mem_lookup_union_middle {a} {b : β a} {s₁ s₂ s₃ : Finmap β} :
    b ∈ lookup a (s₁ ∪ s₃) → a ∉ s₂ → b ∈ lookup a (s₁ ∪ s₂ ∪ s₃) :=
  (induction_on₃ s₁ s₂ s₃) fun s₁ s₂ s₃ => mem_lookup_union_middle
#align finmap.mem_lookup_union_middle Finmap.mem_lookup_union_middle

theorem insert_union {a} {b : β a} {s₁ s₂ : Finmap β} : insert a b (s₁ ∪ s₂) = insert a b s₁ ∪ s₂ :=
  (induction_on₂ s₁ s₂) fun a₁ a₂ => by simp [insert_union]
#align finmap.insert_union Finmap.insert_union

theorem union_assoc {s₁ s₂ s₃ : Finmap β} : s₁ ∪ s₂ ∪ s₃ = s₁ ∪ (s₂ ∪ s₃) :=
  (induction_on₃ s₁ s₂ s₃) fun s₁ s₂ s₃ => by
    simp only [Alist.to_finmap_eq, union_to_finmap, Alist.union_assoc]
#align finmap.union_assoc Finmap.union_assoc

@[simp]
theorem empty_union {s₁ : Finmap β} : ∅ ∪ s₁ = s₁ :=
  (induction_on s₁) fun s₁ => by
    rw [← empty_to_finmap] <;>
      simp [-empty_to_finmap, Alist.to_finmap_eq, union_to_finmap, Alist.union_assoc]
#align finmap.empty_union Finmap.empty_union

@[simp]
theorem union_empty {s₁ : Finmap β} : s₁ ∪ ∅ = s₁ :=
  (induction_on s₁) fun s₁ => by
    rw [← empty_to_finmap] <;>
      simp [-empty_to_finmap, Alist.to_finmap_eq, union_to_finmap, Alist.union_assoc]
#align finmap.union_empty Finmap.union_empty

theorem erase_union_singleton (a : α) (b : β a) (s : Finmap β) (h : s.lookup a = some b) :
    s.erase a ∪ singleton a b = s :=
  ext_lookup fun x => by 
    by_cases h' : x = a
    · subst a
      rw [lookup_union_right not_mem_erase_self, lookup_singleton_eq, h]
    · have : x ∉ singleton a b := by rwa [mem_singleton]
      rw [lookup_union_left_of_not_in this, lookup_erase_ne h']
#align finmap.erase_union_singleton Finmap.erase_union_singleton

end

/-! ### disjoint -/


/-- `disjoint s₁ s₂` holds if `s₁` and `s₂` have no keys in common. -/
def Disjoint (s₁ s₂ : Finmap β) : Prop :=
  ∀ x ∈ s₁, ¬x ∈ s₂
#align finmap.disjoint Finmap.Disjoint

theorem disjoint_empty (x : Finmap β) : Disjoint ∅ x :=
  fun.
#align finmap.disjoint_empty Finmap.disjoint_empty

@[symm]
theorem Disjoint.symm (x y : Finmap β) (h : Disjoint x y) : Disjoint y x := fun p hy hx => h p hx hy
#align finmap.disjoint.symm Finmap.Disjoint.symm

theorem Disjoint.symm_iff (x y : Finmap β) : Disjoint x y ↔ Disjoint y x :=
  ⟨Disjoint.symm x y, Disjoint.symm y x⟩
#align finmap.disjoint.symm_iff Finmap.Disjoint.symm_iff

section

variable [DecidableEq α]

instance : DecidableRel (@Disjoint α β) := fun x y => by dsimp only [Disjoint] <;> infer_instance

theorem disjoint_union_left (x y z : Finmap β) : Disjoint (x ∪ y) z ↔ Disjoint x z ∧ Disjoint y z :=
  by simp [Disjoint, Finmap.mem_union, or_imp, forall_and]
#align finmap.disjoint_union_left Finmap.disjoint_union_left

theorem disjoint_union_right (x y z : Finmap β) :
    Disjoint x (y ∪ z) ↔ Disjoint x y ∧ Disjoint x z := by
  rw [disjoint.symm_iff, disjoint_union_left, disjoint.symm_iff _ x, disjoint.symm_iff _ x]
#align finmap.disjoint_union_right Finmap.disjoint_union_right

theorem union_comm_of_disjoint {s₁ s₂ : Finmap β} : Disjoint s₁ s₂ → s₁ ∪ s₂ = s₂ ∪ s₁ :=
  (induction_on₂ s₁ s₂) fun s₁ s₂ => by 
    intro h
    simp only [Alist.to_finmap_eq, union_to_finmap, Alist.union_comm_of_disjoint h]
#align finmap.union_comm_of_disjoint Finmap.union_comm_of_disjoint

theorem union_cancel {s₁ s₂ s₃ : Finmap β} (h : Disjoint s₁ s₃) (h' : Disjoint s₂ s₃) :
    s₁ ∪ s₃ = s₂ ∪ s₃ ↔ s₁ = s₂ :=
  ⟨fun h'' => by 
    apply ext_lookup
    intro x
    have : (s₁ ∪ s₃).lookup x = (s₂ ∪ s₃).lookup x := h'' ▸ rfl
    by_cases hs₁ : x ∈ s₁
    · rwa [lookup_union_left hs₁, lookup_union_left_of_not_in (h _ hs₁)] at this
    · by_cases hs₂ : x ∈ s₂
      · rwa [lookup_union_left_of_not_in (h' _ hs₂), lookup_union_left hs₂] at this
      · rw [lookup_eq_none.mpr hs₁, lookup_eq_none.mpr hs₂],
    fun h => h ▸ rfl⟩
#align finmap.union_cancel Finmap.union_cancel

end

end Finmap

