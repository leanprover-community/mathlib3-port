/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module algebra.support
! leanprover-community/mathlib commit 0743cc5d9d86bcd1bba10f480e948a257d65056f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.ConditionallyCompleteLattice.Basic
import Mathbin.Data.Set.Finite
import Mathbin.Algebra.BigOperators.Basic
import Mathbin.Algebra.Group.Prod
import Mathbin.Algebra.Group.Pi
import Mathbin.Algebra.Module.Basic
import Mathbin.GroupTheory.GroupAction.Pi

/-!
# Support of a function

In this file we define `function.support f = {x | f x ≠ 0}` and prove its basic properties.
We also define `function.mul_support f = {x | f x ≠ 1}`.
-/


open Set

open BigOperators

namespace Function

variable {α β A B M N P R S G M₀ G₀ : Type _} {ι : Sort _}

section One

variable [One M] [One N] [One P]

/-- `support` of a function is the set of points `x` such that `f x ≠ 0`. -/
def support [Zero A] (f : α → A) : Set α :=
  { x | f x ≠ 0 }
#align function.support Function.support

/-- `mul_support` of a function is the set of points `x` such that `f x ≠ 1`. -/
@[to_additive]
def mulSupport (f : α → M) : Set α :=
  { x | f x ≠ 1 }
#align function.mul_support Function.mulSupport

@[to_additive]
theorem mul_support_eq_preimage (f : α → M) : mulSupport f = f ⁻¹' {1}ᶜ :=
  rfl
#align function.mul_support_eq_preimage Function.mul_support_eq_preimage

@[to_additive]
theorem nmem_mul_support {f : α → M} {x : α} : x ∉ mulSupport f ↔ f x = 1 :=
  not_not
#align function.nmem_mul_support Function.nmem_mul_support

@[to_additive]
theorem compl_mul_support {f : α → M} : mulSupport fᶜ = { x | f x = 1 } :=
  ext fun x => nmem_mul_support
#align function.compl_mul_support Function.compl_mul_support

@[simp, to_additive]
theorem mem_mul_support {f : α → M} {x : α} : x ∈ mulSupport f ↔ f x ≠ 1 :=
  Iff.rfl
#align function.mem_mul_support Function.mem_mul_support

@[simp, to_additive]
theorem mul_support_subset_iff {f : α → M} {s : Set α} : mulSupport f ⊆ s ↔ ∀ x, f x ≠ 1 → x ∈ s :=
  Iff.rfl
#align function.mul_support_subset_iff Function.mul_support_subset_iff

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (x «expr ∉ » s) -/
@[to_additive]
theorem mul_support_subset_iff' {f : α → M} {s : Set α} :
    mulSupport f ⊆ s ↔ ∀ (x) (_ : x ∉ s), f x = 1 :=
  forall_congr' fun x => not_imp_comm
#align function.mul_support_subset_iff' Function.mul_support_subset_iff'

@[to_additive]
theorem mul_support_eq_iff {f : α → M} {s : Set α} :
    mulSupport f = s ↔ (∀ x, x ∈ s → f x ≠ 1) ∧ ∀ x, x ∉ s → f x = 1 := by
  simp only [Set.ext_iff, mem_mul_support, Ne.def, imp_not_comm, ← forall_and, ← iff_def, ←
    xor_iff_not_iff', ← xor_iff_iff_not]
#align function.mul_support_eq_iff Function.mul_support_eq_iff

@[to_additive]
theorem mul_support_disjoint_iff {f : α → M} {s : Set α} : Disjoint (mulSupport f) s ↔ EqOn f 1 s :=
  by
  simp_rw [← subset_compl_iff_disjoint_right, mul_support_subset_iff', not_mem_compl_iff, eq_on,
    Pi.one_apply]
#align function.mul_support_disjoint_iff Function.mul_support_disjoint_iff

@[to_additive]
theorem disjoint_mul_support_iff {f : α → M} {s : Set α} : Disjoint s (mulSupport f) ↔ EqOn f 1 s :=
  by rw [Disjoint.comm, mul_support_disjoint_iff]
#align function.disjoint_mul_support_iff Function.disjoint_mul_support_iff

@[simp, to_additive]
theorem mul_support_eq_empty_iff {f : α → M} : mulSupport f = ∅ ↔ f = 1 := by
  simp_rw [← subset_empty_iff, mul_support_subset_iff', funext_iff]
  simp
#align function.mul_support_eq_empty_iff Function.mul_support_eq_empty_iff

@[simp, to_additive]
theorem mul_support_nonempty_iff {f : α → M} : (mulSupport f).Nonempty ↔ f ≠ 1 := by
  rw [nonempty_iff_ne_empty, Ne.def, mul_support_eq_empty_iff]
#align function.mul_support_nonempty_iff Function.mul_support_nonempty_iff

@[to_additive]
theorem range_subset_insert_image_mul_support (f : α → M) :
    range f ⊆ insert 1 (f '' mulSupport f) := by
  simpa only [range_subset_iff, mem_insert_iff, or_iff_not_imp_left] using
    fun x (hx : x ∈ mul_support f) => mem_image_of_mem f hx
#align function.range_subset_insert_image_mul_support Function.range_subset_insert_image_mul_support

@[simp, to_additive]
theorem mul_support_one' : mulSupport (1 : α → M) = ∅ :=
  mul_support_eq_empty_iff.2 rfl
#align function.mul_support_one' Function.mul_support_one'

@[simp, to_additive]
theorem mul_support_one : (mulSupport fun x : α => (1 : M)) = ∅ :=
  mul_support_one'
#align function.mul_support_one Function.mul_support_one

@[to_additive]
theorem mul_support_const {c : M} (hc : c ≠ 1) : (mulSupport fun x : α => c) = Set.univ := by
  ext x
  simp [hc]
#align function.mul_support_const Function.mul_support_const

@[to_additive]
theorem mul_support_binop_subset (op : M → N → P) (op1 : op 1 1 = 1) (f : α → M) (g : α → N) :
    (mulSupport fun x => op (f x) (g x)) ⊆ mulSupport f ∪ mulSupport g := fun x hx =>
  not_or_of_imp fun hf hg => hx <| by simp only [hf, hg, op1]
#align function.mul_support_binop_subset Function.mul_support_binop_subset

@[to_additive]
theorem mul_support_sup [SemilatticeSup M] (f g : α → M) :
    (mulSupport fun x => f x ⊔ g x) ⊆ mulSupport f ∪ mulSupport g :=
  mul_support_binop_subset (· ⊔ ·) sup_idem f g
#align function.mul_support_sup Function.mul_support_sup

@[to_additive]
theorem mul_support_inf [SemilatticeInf M] (f g : α → M) :
    (mulSupport fun x => f x ⊓ g x) ⊆ mulSupport f ∪ mulSupport g :=
  mul_support_binop_subset (· ⊓ ·) inf_idem f g
#align function.mul_support_inf Function.mul_support_inf

@[to_additive]
theorem mul_support_max [LinearOrder M] (f g : α → M) :
    (mulSupport fun x => max (f x) (g x)) ⊆ mulSupport f ∪ mulSupport g :=
  mul_support_sup f g
#align function.mul_support_max Function.mul_support_max

@[to_additive]
theorem mul_support_min [LinearOrder M] (f g : α → M) :
    (mulSupport fun x => min (f x) (g x)) ⊆ mulSupport f ∪ mulSupport g :=
  mul_support_inf f g
#align function.mul_support_min Function.mul_support_min

@[to_additive]
theorem mul_support_supr [ConditionallyCompleteLattice M] [Nonempty ι] (f : ι → α → M) :
    (mulSupport fun x => ⨆ i, f i x) ⊆ ⋃ i, mulSupport (f i) := by
  rw [mul_support_subset_iff']
  simp only [mem_Union, not_exists, nmem_mul_support]
  intro x hx
  simp only [hx, csupr_const]
#align function.mul_support_supr Function.mul_support_supr

@[to_additive]
theorem mul_support_infi [ConditionallyCompleteLattice M] [Nonempty ι] (f : ι → α → M) :
    (mulSupport fun x => ⨅ i, f i x) ⊆ ⋃ i, mulSupport (f i) :=
  @mul_support_supr _ Mᵒᵈ ι ⟨(1 : M)⟩ _ _ f
#align function.mul_support_infi Function.mul_support_infi

@[to_additive]
theorem mul_support_comp_subset {g : M → N} (hg : g 1 = 1) (f : α → M) :
    mulSupport (g ∘ f) ⊆ mulSupport f := fun x => mt fun h => by simp only [(· ∘ ·), *]
#align function.mul_support_comp_subset Function.mul_support_comp_subset

@[to_additive]
theorem mul_support_subset_comp {g : M → N} (hg : ∀ {x}, g x = 1 → x = 1) (f : α → M) :
    mulSupport f ⊆ mulSupport (g ∘ f) := fun x => mt hg
#align function.mul_support_subset_comp Function.mul_support_subset_comp

@[to_additive]
theorem mul_support_comp_eq (g : M → N) (hg : ∀ {x}, g x = 1 ↔ x = 1) (f : α → M) :
    mulSupport (g ∘ f) = mulSupport f :=
  Set.ext fun x => not_congr hg
#align function.mul_support_comp_eq Function.mul_support_comp_eq

@[to_additive]
theorem mul_support_comp_eq_preimage (g : β → M) (f : α → β) :
    mulSupport (g ∘ f) = f ⁻¹' mulSupport g :=
  rfl
#align function.mul_support_comp_eq_preimage Function.mul_support_comp_eq_preimage

@[to_additive support_prod_mk]
theorem mul_support_prod_mk (f : α → M) (g : α → N) :
    (mulSupport fun x => (f x, g x)) = mulSupport f ∪ mulSupport g :=
  Set.ext fun x => by
    simp only [mul_support, not_and_or, mem_union, mem_set_of_eq, Prod.mk_eq_one, Ne.def]
#align function.mul_support_prod_mk Function.mul_support_prod_mk

@[to_additive support_prod_mk']
theorem mul_support_prod_mk' (f : α → M × N) :
    mulSupport f = (mulSupport fun x => (f x).1) ∪ mulSupport fun x => (f x).2 := by
  simp only [← mul_support_prod_mk, Prod.mk.eta]
#align function.mul_support_prod_mk' Function.mul_support_prod_mk'

@[to_additive]
theorem mul_support_along_fiber_subset (f : α × β → M) (a : α) :
    (mulSupport fun b => f (a, b)) ⊆ (mulSupport f).image Prod.snd := by tidy
#align function.mul_support_along_fiber_subset Function.mul_support_along_fiber_subset

@[simp, to_additive]
theorem mul_support_along_fiber_finite_of_finite (f : α × β → M) (a : α)
    (h : (mulSupport f).Finite) : (mulSupport fun b => f (a, b)).Finite :=
  (h.image Prod.snd).Subset (mul_support_along_fiber_subset f a)
#align
  function.mul_support_along_fiber_finite_of_finite Function.mul_support_along_fiber_finite_of_finite

end One

@[to_additive]
theorem mul_support_mul [MulOneClass M] (f g : α → M) :
    (mulSupport fun x => f x * g x) ⊆ mulSupport f ∪ mulSupport g :=
  mul_support_binop_subset (· * ·) (one_mul _) f g
#align function.mul_support_mul Function.mul_support_mul

@[to_additive]
theorem mul_support_pow [Monoid M] (f : α → M) (n : ℕ) :
    (mulSupport fun x => f x ^ n) ⊆ mulSupport f := by
  induction' n with n hfn
  · simpa only [pow_zero, mul_support_one] using empty_subset _
  · simpa only [pow_succ] using (mul_support_mul f _).trans (union_subset subset.rfl hfn)
#align function.mul_support_pow Function.mul_support_pow

section DivisionMonoid

variable [DivisionMonoid G] (f g : α → G)

@[simp, to_additive]
theorem mul_support_inv : (mulSupport fun x => (f x)⁻¹) = mulSupport f :=
  ext fun _ => inv_ne_one
#align function.mul_support_inv Function.mul_support_inv

@[simp, to_additive]
theorem mul_support_inv' : mulSupport f⁻¹ = mulSupport f :=
  mul_support_inv f
#align function.mul_support_inv' Function.mul_support_inv'

@[to_additive]
theorem mul_support_mul_inv : (mulSupport fun x => f x * (g x)⁻¹) ⊆ mulSupport f ∪ mulSupport g :=
  mul_support_binop_subset (fun a b => a * b⁻¹) (by simp) f g
#align function.mul_support_mul_inv Function.mul_support_mul_inv

@[to_additive]
theorem mul_support_div : (mulSupport fun x => f x / g x) ⊆ mulSupport f ∪ mulSupport g :=
  mul_support_binop_subset (· / ·) one_div_one f g
#align function.mul_support_div Function.mul_support_div

end DivisionMonoid

theorem support_smul [Zero R] [Zero M] [SmulWithZero R M] [NoZeroSmulDivisors R M] (f : α → R)
    (g : α → M) : support (f • g) = support f ∩ support g :=
  ext fun x => smul_ne_zero_iff
#align function.support_smul Function.support_smul

@[simp]
theorem support_mul [MulZeroClass R] [NoZeroDivisors R] (f g : α → R) :
    (support fun x => f x * g x) = support f ∩ support g :=
  support_smul f g
#align function.support_mul Function.support_mul

@[simp]
theorem support_mul_subset_left [MulZeroClass R] (f g : α → R) :
    (support fun x => f x * g x) ⊆ support f := fun x hfg hf => hfg <| by simp only [hf, zero_mul]
#align function.support_mul_subset_left Function.support_mul_subset_left

@[simp]
theorem support_mul_subset_right [MulZeroClass R] (f g : α → R) :
    (support fun x => f x * g x) ⊆ support g := fun x hfg hg => hfg <| by simp only [hg, mul_zero]
#align function.support_mul_subset_right Function.support_mul_subset_right

theorem support_smul_subset_right [AddMonoid A] [Monoid B] [DistribMulAction B A] (b : B)
    (f : α → A) : support (b • f) ⊆ support f := fun x hbf hf =>
  hbf <| by rw [Pi.smul_apply, hf, smul_zero]
#align function.support_smul_subset_right Function.support_smul_subset_right

theorem support_smul_subset_left [Zero M] [Zero β] [SmulWithZero M β] (f : α → M) (g : α → β) :
    support (f • g) ⊆ support f := fun x hfg hf => hfg <| by rw [Pi.smul_apply', hf, zero_smul]
#align function.support_smul_subset_left Function.support_smul_subset_left

theorem support_const_smul_of_ne_zero [Semiring R] [AddCommMonoid M] [Module R M]
    [NoZeroSmulDivisors R M] (c : R) (g : α → M) (hc : c ≠ 0) : support (c • g) = support g :=
  ext fun x => by simp only [hc, mem_support, Pi.smul_apply, Ne.def, smul_eq_zero, false_or_iff]
#align function.support_const_smul_of_ne_zero Function.support_const_smul_of_ne_zero

@[simp]
theorem support_inv [GroupWithZero G₀] (f : α → G₀) : (support fun x => (f x)⁻¹) = support f :=
  Set.ext fun x => not_congr inv_eq_zero
#align function.support_inv Function.support_inv

@[simp]
theorem support_div [GroupWithZero G₀] (f g : α → G₀) :
    (support fun x => f x / g x) = support f ∩ support g := by simp [div_eq_mul_inv]
#align function.support_div Function.support_div

@[to_additive]
theorem mul_support_prod [CommMonoid M] (s : Finset α) (f : α → β → M) :
    (mulSupport fun x => ∏ i in s, f i x) ⊆ ⋃ i ∈ s, mulSupport (f i) := by
  rw [mul_support_subset_iff']
  simp only [mem_Union, not_exists, nmem_mul_support]
  exact fun x => Finset.prod_eq_one
#align function.mul_support_prod Function.mul_support_prod

theorem support_prod_subset [CommMonoidWithZero A] (s : Finset α) (f : α → β → A) :
    (support fun x => ∏ i in s, f i x) ⊆ ⋂ i ∈ s, support (f i) := fun x hx =>
  mem_Inter₂.2 fun i hi H => hx <| Finset.prod_eq_zero hi H
#align function.support_prod_subset Function.support_prod_subset

theorem support_prod [CommMonoidWithZero A] [NoZeroDivisors A] [Nontrivial A] (s : Finset α)
    (f : α → β → A) : (support fun x => ∏ i in s, f i x) = ⋂ i ∈ s, support (f i) :=
  Set.ext fun x => by
    simp only [support, Ne.def, Finset.prod_eq_zero_iff, mem_set_of_eq, Set.mem_Inter, not_exists]
#align function.support_prod Function.support_prod

theorem mul_support_one_add [One R] [AddLeftCancelMonoid R] (f : α → R) :
    (mulSupport fun x => 1 + f x) = support f :=
  Set.ext fun x => not_congr add_right_eq_self
#align function.mul_support_one_add Function.mul_support_one_add

theorem mul_support_one_add' [One R] [AddLeftCancelMonoid R] (f : α → R) :
    mulSupport (1 + f) = support f :=
  mul_support_one_add f
#align function.mul_support_one_add' Function.mul_support_one_add'

theorem mul_support_add_one [One R] [AddRightCancelMonoid R] (f : α → R) :
    (mulSupport fun x => f x + 1) = support f :=
  Set.ext fun x => not_congr add_left_eq_self
#align function.mul_support_add_one Function.mul_support_add_one

theorem mul_support_add_one' [One R] [AddRightCancelMonoid R] (f : α → R) :
    mulSupport (f + 1) = support f :=
  mul_support_add_one f
#align function.mul_support_add_one' Function.mul_support_add_one'

theorem mul_support_one_sub' [One R] [AddGroup R] (f : α → R) : mulSupport (1 - f) = support f := by
  rw [sub_eq_add_neg, mul_support_one_add', support_neg']
#align function.mul_support_one_sub' Function.mul_support_one_sub'

theorem mul_support_one_sub [One R] [AddGroup R] (f : α → R) :
    (mulSupport fun x => 1 - f x) = support f :=
  mul_support_one_sub' f
#align function.mul_support_one_sub Function.mul_support_one_sub

end Function

namespace Set

open Function

variable {α β M : Type _} [One M] {f : α → M}

@[to_additive]
theorem image_inter_mul_support_eq {s : Set β} {g : β → α} :
    g '' s ∩ mulSupport f = g '' (s ∩ mulSupport (f ∘ g)) := by
  rw [mul_support_comp_eq_preimage f g, image_inter_preimage]
#align set.image_inter_mul_support_eq Set.image_inter_mul_support_eq

end Set

namespace Pi

variable {A : Type _} {B : Type _} [DecidableEq A] [One B] {a : A} {b : B}

open Function

@[to_additive]
theorem mul_support_mul_single_subset : mulSupport (mulSingle a b) ⊆ {a} := fun x hx =>
  by_contra fun hx' => hx <| mulSingle_eq_of_ne hx' _
#align pi.mul_support_mul_single_subset Pi.mul_support_mul_single_subset

@[to_additive]
theorem mul_support_mul_single_one : mulSupport (mulSingle a (1 : B)) = ∅ := by simp
#align pi.mul_support_mul_single_one Pi.mul_support_mul_single_one

@[simp, to_additive]
theorem mul_support_mul_single_of_ne (h : b ≠ 1) : mulSupport (mulSingle a b) = {a} :=
  mul_support_mul_single_subset.antisymm fun x (hx : x = a) => by
    rwa [mem_mul_support, hx, mul_single_eq_same]
#align pi.mul_support_mul_single_of_ne Pi.mul_support_mul_single_of_ne

@[to_additive]
theorem mul_support_mul_single [DecidableEq B] :
    mulSupport (mulSingle a b) = if b = 1 then ∅ else {a} := by split_ifs with h <;> simp [h]
#align pi.mul_support_mul_single Pi.mul_support_mul_single

@[to_additive]
theorem mul_support_mul_single_disjoint {b' : B} (hb : b ≠ 1) (hb' : b' ≠ 1) {i j : A} :
    Disjoint (mulSupport (mulSingle i b)) (mulSupport (mulSingle j b')) ↔ i ≠ j := by
  rw [mul_support_mul_single_of_ne hb, mul_support_mul_single_of_ne hb', disjoint_singleton]
#align pi.mul_support_mul_single_disjoint Pi.mul_support_mul_single_disjoint

end Pi

