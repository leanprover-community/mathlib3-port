/-
Copyright (c) 2018 Robert Y. Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Robert Y. Lewis

! This file was ported from Lean 3 source module meta.rb_map
! leanprover-community/mathlib commit 986c4d5761f938b2e1c43c01f001b6d9d88c2055
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Option.Defs
import Mathbin.Data.List.Defs

/-!
# rb_map

This file defines additional operations on native rb_maps and rb_sets.
These structures are defined in core in `init.meta.rb_map`.
They are meta objects, and are generally the most efficient dictionary structures
to use for pure metaprogramming right now.
-/


namespace Native

/-! ### Declarations about `rb_set` -/


namespace RbSet

unsafe instance {key} [LT key] [DecidableRel ((· < ·) : key → key → Prop)] :
    Inhabited (rb_set key) :=
  ⟨mk_rb_set⟩

/-- `filter s P` returns the subset of elements of `s` satisfying `P`. -/
unsafe def filter {key} (s : rb_set key) (P : key → Bool) : rb_set key :=
  s.fold s fun a m => if P a then m else m.erase a
#align native.rb_set.filter native.rb_set.filter

/-- `mfilter s P` returns the subset of elements of `s` satisfying `P`,
where the check `P` is monadic. -/
unsafe def mfilter {m} [Monad m] {key} (s : rb_set key) (P : key → m Bool) : m (rb_set key) :=
  s.fold (pure s) fun a m => do
    let x ← m
    condM (P a) (pure x) (pure <| x a)
#align native.rb_set.mfilter native.rb_set.mfilter

/-- `union s t` returns an rb_set containing every element that appears in either `s` or `t`. -/
unsafe def union {key} (s t : rb_set key) : rb_set key :=
  s.fold t fun a t => t.insert a
#align native.rb_set.union native.rb_set.union

/-- `of_list_core empty l` turns a list of keys into an `rb_set`.
It takes a user_provided `rb_set` to use for the base case.
This can be used to pre-seed the set with additional elements,
and/or to use a custom comparison operator.
-/
unsafe def of_list_core {key} (base : rb_set key) : List key → rb_map key Unit
  | [] => base
  | x :: xs => rb_set.insert (of_list_core xs) x
#align native.rb_set.of_list_core native.rb_set.of_list_core

/-- `of_list l` transforms a list `l : list key` into an `rb_set`,
inferring an order on the type `key`.
-/
unsafe def of_list {key} [LT key] [DecidableRel ((· < ·) : key → key → Prop)] :
    List key → rb_set key :=
  of_list_core mk_rb_set
#align native.rb_set.of_list native.rb_set.of_list

/-- `sdiff s1 s2` returns the set of elements that are in `s1` but not in `s2`.
It does so by folding over `s2`. If `s1` is significantly smaller than `s2`,
it may be worth it to reverse the fold.
-/
unsafe def sdiff {α} (s1 s2 : rb_set α) : rb_set α :=
  (s2.fold s1) fun v s => s.erase v
#align native.rb_set.sdiff native.rb_set.sdiff

/-- `insert_list s l` inserts each element of `l` into `s`.
-/
unsafe def insert_list {key} (s : rb_set key) (l : List key) : rb_set key :=
  l.foldl rb_set.insert s
#align native.rb_set.insert_list native.rb_set.insert_list

end RbSet

/-! ### Declarations about `rb_map` -/


namespace RbMap

unsafe instance {key data : Type} [LT key] [DecidableRel ((· < ·) : key → key → Prop)] :
    Inhabited (rb_map key data) :=
  ⟨mk_rb_map⟩

/-- `find_def default m k` returns the value corresponding to `k` in `m`, if it exists.
Otherwise it returns `default`. -/
unsafe def find_def {key value} (default : value) (m : rb_map key value) (k : key) :=
  (m.find k).getOrElse default
#align native.rb_map.find_def native.rb_map.find_def

/-- `ifind m key` returns the value corresponding to `key` in `m`, if it exists.
Otherwise it returns the default value of `value`. -/
unsafe def ifind {key value} [Inhabited value] (m : rb_map key value) (k : key) : value :=
  (m.find k).iget
#align native.rb_map.ifind native.rb_map.ifind

/-- `zfind m key` returns the value corresponding to `key` in `m`, if it exists.
Otherwise it returns 0. -/
unsafe def zfind {key value} [Zero value] (m : rb_map key value) (k : key) : value :=
  (m.find k).getOrElse 0
#align native.rb_map.zfind native.rb_map.zfind

/-- Returns the pointwise sum of `m1` and `m2`, treating nonexistent values as 0. -/
unsafe def add {key value} [Add value] [Zero value] [DecidableEq value] (m1 m2 : rb_map key value) :
    rb_map key value :=
  m1.fold m2 fun n v m =>
    let nv := v + m2.zfind n
    if nv = 0 then m.erase n else m.insert n nv
#align native.rb_map.add native.rb_map.add

variable {m : Type → Type _} [Monad m]

open Function

/-- `mfilter P s` filters `s` by the monadic predicate `P` on keys and values. -/
unsafe def mfilter {key val} [LT key] [DecidableRel ((· < ·) : key → key → Prop)]
    (P : key → val → m Bool) (s : rb_map key val) : m (rb_map.{0, 0} key val) :=
  rb_map.of_list <$> s.toList.mfilter (uncurry P)
#align native.rb_map.mfilter native.rb_map.mfilter

/-- `mmap f s` maps the monadic function `f` over values in `s`. -/
unsafe def mmap {key val val'} [LT key] [DecidableRel ((· < ·) : key → key → Prop)]
    (f : val → m val') (s : rb_map key val) : m (rb_map.{0, 0} key val') :=
  rb_map.of_list <$> s.toList.mmap fun ⟨a, b⟩ => Prod.mk a <$> f b
#align native.rb_map.mmap native.rb_map.mmap

/-- `scale b m` multiplies every value in `m` by `b`. -/
unsafe def scale {key value} [LT key] [DecidableRel ((· < ·) : key → key → Prop)] [Mul value]
    (b : value) (m : rb_map key value) : rb_map key value :=
  m.map ((· * ·) b)
#align native.rb_map.scale native.rb_map.scale

section

open Format Prod

variable {key : Type} {data : Type} [has_to_tactic_format key] [has_to_tactic_format data]

private unsafe def pp_key_data (k : key) (d : data) (first : Bool) : tactic format := do
  let fk ← tactic.pp k
  let fd ← tactic.pp d
  return <|
      (if first then to_fmt "" else to_fmt "," ++ line) ++ fk ++ space ++ to_fmt "←" ++ space ++ fd
#align native.rb_map.pp_key_data native.rb_map.pp_key_data

unsafe instance : has_to_tactic_format (rb_map key data) :=
  ⟨fun m => do
    let (fmt, _) ←
      fold m (return (to_fmt "", true)) fun k d p => do
          let p ← p
          let pkd ← pp_key_data k d (snd p)
          return (fst p ++ pkd, ff)
    return <| group <| to_fmt "⟨" ++ nest 1 fmt ++ to_fmt "⟩"⟩

end

end RbMap

/-! ### Declarations about `rb_lmap` -/


namespace RbLmap

unsafe instance (key : Type) [LT key] [DecidableRel ((· < ·) : key → key → Prop)] (data : Type) :
    Inhabited (rb_lmap key data) :=
  ⟨rb_lmap.mk _ _⟩

/-- Construct a rb_lmap from a list of key-data pairs -/
protected unsafe def of_list {key : Type} {data : Type} [LT key]
    [DecidableRel ((· < ·) : key → key → Prop)] : List (key × data) → rb_lmap key data
  | [] => rb_lmap.mk key data
  | (k, v) :: ls => (of_list ls).insert k v
#align native.rb_lmap.of_list native.rb_lmap.of_list

/-- Returns the list of values of an `rb_lmap`. -/
protected unsafe def values {key data} (m : rb_lmap key data) : List data :=
  m.fold [] fun _ => (· ++ ·)
#align native.rb_lmap.values native.rb_lmap.values

end RbLmap

end Native

/-! ### Declarations about `name_set` -/


namespace NameSet

unsafe instance : Inhabited name_set :=
  ⟨mk_name_set⟩

/-- `filter P s` returns the subset of elements of `s` satisfying `P`. -/
unsafe def filter (P : Name → Bool) (s : name_set) : name_set :=
  s.fold s fun a m => if P a then m else m.erase a
#align name_set.filter name_set.filter

/-- `mfilter P s` returns the subset of elements of `s` satisfying `P`,
where the check `P` is monadic. -/
unsafe def mfilter {m} [Monad m] (P : Name → m Bool) (s : name_set) : m name_set :=
  s.fold (pure s) fun a m => do
    let x ← m
    condM (P a) (pure x) (pure <| x a)
#align name_set.mfilter name_set.mfilter

/-- `mmap f s` maps the monadic function `f` over values in `s`. -/
unsafe def mmap {m} [Monad m] (f : Name → m Name) (s : name_set) : m name_set :=
  s.fold (pure mk_name_set) fun a m => do
    let x ← m
    let b ← f a
    pure <| x b
#align name_set.mmap name_set.mmap

/-- `insert_list s l` inserts every element of `l` into `s`. -/
unsafe def insert_list (s : name_set) (l : List Name) : name_set :=
  l.foldr (fun n s' => s'.insert n) s
#align name_set.insert_list name_set.insert_list

/-- `local_list_to_name_set lcs` is the set of unique names of the local
constants `lcs`. If any of the `lcs` are not local constants, the returned set
will contain bogus names.
-/
unsafe def local_list_to_name_set (lcs : List expr) : name_set :=
  lcs.foldl (fun ns h => ns.insert h.local_uniq_name) mk_name_set
#align name_set.local_list_to_name_set name_set.local_list_to_name_set

end NameSet

/-! ### Declarations about `name_map` -/


namespace NameMap

unsafe instance {data : Type} : Inhabited (name_map data) :=
  ⟨mk_name_map⟩

end NameMap

/-! ### Declarations about `expr_set` -/


namespace ExprSet

/-- `local_set_to_name_set lcs` is the set of unique names of the local constants
`lcs`. If any of the `lcs` are not local constants, the returned set will
contain bogus names.
-/
unsafe def local_set_to_name_set (lcs : expr_set) : name_set :=
  (lcs.fold mk_name_set) fun h ns => ns.insert h.local_uniq_name
#align expr_set.local_set_to_name_set expr_set.local_set_to_name_set

end ExprSet

namespace List

/-- `to_rb_map as` is the map that associates each index `i` of `as` with the
corresponding element of `as`.

```
to_rb_map ['a', 'b', 'c'] = rb_map.of_list [(0, 'a'), (1, 'b'), (2, 'c')]
```
-/
unsafe def to_rb_map {α : Type} : List α → native.rb_map ℕ α :=
  foldlIdx (fun i mapp a => mapp.insert i a) native.mk_rb_map
#align list.to_rb_map list.to_rb_map

end List

