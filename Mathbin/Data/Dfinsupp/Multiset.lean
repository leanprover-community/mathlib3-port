/-
Copyright (c) 2022 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module data.dfinsupp.multiset
! leanprover-community/mathlib commit 26f081a2fb920140ed5bc5cc5344e84bcc7cb2b2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Dfinsupp.Order

/-!
# Equivalence between `multiset` and `ℕ`-valued finitely supported functions

This defines `dfinsupp.to_multiset` the equivalence between `Π₀ a : α, ℕ` and `multiset α`, along
with `multiset.to_dfinsupp` the reverse equivalence.

Note that this provides a computable alternative to `finsupp.to_multiset`.
-/


variable {α : Type _} {β : α → Type _}

namespace Dfinsupp

/-- Non-dependent special case of `dfinsupp.add_zero_class` to help typeclass search. -/
instance addZeroClass' {β} [AddZeroClass β] : AddZeroClass (Π₀ a : α, β) :=
  @Dfinsupp.addZeroClass α (fun _ => β) _
#align dfinsupp.add_zero_class' Dfinsupp.addZeroClass'

variable [DecidableEq α]

/-- A computable version of `finsupp.to_multiset`. -/
def toMultiset : (Π₀ a : α, ℕ) →+ Multiset α :=
  Dfinsupp.sumAddHom fun a : α => Multiset.repeatAddMonoidHom a
#align dfinsupp.to_multiset Dfinsupp.toMultiset

@[simp]
theorem to_multiset_single (a : α) (n : ℕ) :
    toMultiset (Dfinsupp.single a n) = Multiset.repeat a n :=
  Dfinsupp.sum_add_hom_single _ _ _
#align dfinsupp.to_multiset_single Dfinsupp.to_multiset_single

end Dfinsupp

namespace Multiset

variable [DecidableEq α]

/-- A computable version of `multiset.to_finsupp` -/
def toDfinsupp : Multiset α →+ Π₀ a : α, ℕ
    where
  toFun s :=
    { toFun := fun n => s.count n
      support' := Trunc.mk ⟨s, fun i => (em (i ∈ s)).imp_right Multiset.count_eq_zero_of_not_mem⟩ }
  map_zero' := rfl
  map_add' s t := Dfinsupp.ext fun _ => Multiset.count_add _ _ _
#align multiset.to_dfinsupp Multiset.toDfinsupp

@[simp]
theorem to_dfinsupp_apply (s : Multiset α) (a : α) : s.toDfinsupp a = s.count a :=
  rfl
#align multiset.to_dfinsupp_apply Multiset.to_dfinsupp_apply

@[simp]
theorem to_dfinsupp_support (s : Multiset α) : s.toDfinsupp.support = s.toFinset :=
  (Finset.filter_eq_self _).mpr fun x hx => count_ne_zero.mpr <| Multiset.mem_to_finset.1 hx
#align multiset.to_dfinsupp_support Multiset.to_dfinsupp_support

@[simp]
theorem to_dfinsupp_repeat (a : α) (n : ℕ) :
    toDfinsupp (Multiset.repeat a n) = Dfinsupp.single a n :=
  by
  ext i
  dsimp [to_dfinsupp]
  simp [count_repeat, eq_comm]
#align multiset.to_dfinsupp_repeat Multiset.to_dfinsupp_repeat

@[simp]
theorem to_dfinsupp_singleton (a : α) : toDfinsupp {a} = Dfinsupp.single a 1 := by
  rw [← repeat_one, to_dfinsupp_repeat]
#align multiset.to_dfinsupp_singleton Multiset.to_dfinsupp_singleton

/-- `multiset.to_dfinsupp` as an `add_equiv`. -/
@[simps apply symmApply]
def equivDfinsupp : Multiset α ≃+ Π₀ a : α, ℕ :=
  AddMonoidHom.toAddEquiv Multiset.toDfinsupp Dfinsupp.toMultiset
    (by
      ext x : 1
      simp)
    (by
      refine' @Dfinsupp.add_hom_ext α (fun _ => ℕ) _ _ _ _ _ _ fun i hi => _
      simp)
#align multiset.equiv_dfinsupp Multiset.equivDfinsupp

@[simp]
theorem to_dfinsupp_to_multiset (s : Multiset α) : s.toDfinsupp.toMultiset = s :=
  equivDfinsupp.symm_apply_apply s
#align multiset.to_dfinsupp_to_multiset Multiset.to_dfinsupp_to_multiset

@[simp]
theorem to_dfinsupp_le_to_dfinsupp (s t : Multiset α) : toDfinsupp s ≤ toDfinsupp t ↔ s ≤ t := by
  simp [Multiset.le_iff_count, Dfinsupp.le_def]
#align multiset.to_dfinsupp_le_to_dfinsupp Multiset.to_dfinsupp_le_to_dfinsupp

end Multiset

@[simp]
theorem Dfinsupp.to_multiset_to_dfinsupp [DecidableEq α] (f : Π₀ a : α, ℕ) :
    f.toMultiset.toDfinsupp = f :=
  Multiset.equivDfinsupp.apply_symm_apply f
#align dfinsupp.to_multiset_to_dfinsupp Dfinsupp.to_multiset_to_dfinsupp

