/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module algebra.big_operators.finsupp
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finsupp.Defs
import Mathbin.Algebra.BigOperators.Pi
import Mathbin.Algebra.BigOperators.Ring
import Mathbin.Algebra.BigOperators.Order
import Mathbin.GroupTheory.Submonoid.Membership

/-!
# Big operators for finsupps

This file contains theorems relevant to big operators in finitely supported functions.
-/


noncomputable section

open Finset Function

open Classical BigOperators

variable {α ι γ A B C : Type _} [AddCommMonoid A] [AddCommMonoid B] [AddCommMonoid C]

variable {t : ι → A → C} (h0 : ∀ i, t i 0 = 0) (h1 : ∀ i x y, t i (x + y) = t i x + t i y)

variable {s : Finset α} {f : α → ι →₀ A} (i : ι)

variable (g : ι →₀ A) (k : ι → A → γ → B) (x : γ)

variable {β M M' N P G H R S : Type _}

namespace Finsupp

/-!
### Declarations about `sum` and `prod`

In most of this section, the domain `β` is assumed to be an `add_monoid`.
-/


section SumProd

/-- `prod f g` is the product of `g a (f a)` over the support of `f`. -/
@[to_additive "`sum f g` is the sum of `g a (f a)` over the support of `f`. "]
def prod [Zero M] [CommMonoid N] (f : α →₀ M) (g : α → M → N) : N :=
  ∏ a in f.support, g a (f a)
#align finsupp.prod Finsupp.prod

variable [Zero M] [Zero M'] [CommMonoid N]

@[to_additive]
theorem prod_of_support_subset (f : α →₀ M) {s : Finset α} (hs : f.support ⊆ s) (g : α → M → N)
    (h : ∀ i ∈ s, g i 0 = 1) : f.Prod g = ∏ x in s, g x (f x) :=
  (Finset.prod_subset hs) fun x hxs hx => h x hxs ▸ congr_arg (g x) <| not_mem_support_iff.1 hx
#align finsupp.prod_of_support_subset Finsupp.prod_of_support_subset

@[to_additive]
theorem prod_fintype [Fintype α] (f : α →₀ M) (g : α → M → N) (h : ∀ i, g i 0 = 1) :
    f.Prod g = ∏ i, g i (f i) :=
  f.prod_of_support_subset (subset_univ _) g fun x _ => h x
#align finsupp.prod_fintype Finsupp.prod_fintype

@[simp, to_additive]
theorem prod_single_index {a : α} {b : M} {h : α → M → N} (h_zero : h a 0 = 1) :
    (single a b).Prod h = h a b :=
  calc
    (single a b).Prod h = ∏ x in {a}, h x (single a b x) :=
      (prod_of_support_subset _ support_single_subset h) fun x hx =>
        (mem_singleton.1 hx).symm ▸ h_zero
    _ = h a b := by simp
    
#align finsupp.prod_single_index Finsupp.prod_single_index

@[to_additive]
theorem prod_map_range_index {f : M → M'} {hf : f 0 = 0} {g : α →₀ M} {h : α → M' → N}
    (h0 : ∀ a, h a 0 = 1) : (mapRange f hf g).Prod h = g.Prod fun a b => h a (f b) :=
  (Finset.prod_subset support_map_range) fun _ _ H => by rw [not_mem_support_iff.1 H, h0]
#align finsupp.prod_map_range_index Finsupp.prod_map_range_index

@[simp, to_additive]
theorem prod_zero_index {h : α → M → N} : (0 : α →₀ M).Prod h = 1 :=
  rfl
#align finsupp.prod_zero_index Finsupp.prod_zero_index

@[to_additive]
theorem prod_comm (f : α →₀ M) (g : β →₀ M') (h : α → M → β → M' → N) :
    (f.Prod fun x v => g.Prod fun x' v' => h x v x' v') =
      g.Prod fun x' v' => f.Prod fun x v => h x v x' v' :=
  Finset.prod_comm
#align finsupp.prod_comm Finsupp.prod_comm

@[simp, to_additive]
theorem prod_ite_eq [DecidableEq α] (f : α →₀ M) (a : α) (b : α → M → N) :
    (f.Prod fun x v => ite (a = x) (b x v) 1) = ite (a ∈ f.support) (b a (f a)) 1 :=
  by
  dsimp [Finsupp.prod]
  rw [f.support.prod_ite_eq]
#align finsupp.prod_ite_eq Finsupp.prod_ite_eq

@[simp]
theorem sum_ite_self_eq [DecidableEq α] {N : Type _} [AddCommMonoid N] (f : α →₀ N) (a : α) :
    (f.Sum fun x v => ite (a = x) v 0) = f a :=
  by
  convert f.sum_ite_eq a fun x => id
  simp [ite_eq_right_iff.2 Eq.symm]
#align finsupp.sum_ite_self_eq Finsupp.sum_ite_self_eq

/-- A restatement of `prod_ite_eq` with the equality test reversed. -/
@[simp, to_additive "A restatement of `sum_ite_eq` with the equality test reversed."]
theorem prod_ite_eq' [DecidableEq α] (f : α →₀ M) (a : α) (b : α → M → N) :
    (f.Prod fun x v => ite (x = a) (b x v) 1) = ite (a ∈ f.support) (b a (f a)) 1 :=
  by
  dsimp [Finsupp.prod]
  rw [f.support.prod_ite_eq']
#align finsupp.prod_ite_eq' Finsupp.prod_ite_eq'

@[simp]
theorem sum_ite_self_eq' [DecidableEq α] {N : Type _} [AddCommMonoid N] (f : α →₀ N) (a : α) :
    (f.Sum fun x v => ite (x = a) v 0) = f a :=
  by
  convert f.sum_ite_eq' a fun x => id
  simp [ite_eq_right_iff.2 Eq.symm]
#align finsupp.sum_ite_self_eq' Finsupp.sum_ite_self_eq'

@[simp]
theorem prod_pow [Fintype α] (f : α →₀ ℕ) (g : α → N) :
    (f.Prod fun a b => g a ^ b) = ∏ a, g a ^ f a :=
  (f.prod_fintype _) fun a => pow_zero _
#align finsupp.prod_pow Finsupp.prod_pow

/-- If `g` maps a second argument of 0 to 1, then multiplying it over the
result of `on_finset` is the same as multiplying it over the original
`finset`. -/
@[to_additive
      "If `g` maps a second argument of 0 to 0, summing it over the\nresult of `on_finset` is the same as summing it over the original\n`finset`."]
theorem on_finset_prod {s : Finset α} {f : α → M} {g : α → M → N} (hf : ∀ a, f a ≠ 0 → a ∈ s)
    (hg : ∀ a, g a 0 = 1) : (onFinset s f hf).Prod g = ∏ a in s, g a (f a) :=
  Finset.prod_subset support_on_finset_subset <| by simp (config := { contextual := true }) [*]
#align finsupp.on_finset_prod Finsupp.on_finset_prod

/-- Taking a product over `f : α →₀ M` is the same as multiplying the value on a single element
`y ∈ f.support` by the product over `erase y f`. -/
@[to_additive
      " Taking a sum over over `f : α →₀ M` is the same as adding the value on a\nsingle element `y ∈ f.support` to the sum over `erase y f`. "]
theorem mul_prod_erase (f : α →₀ M) (y : α) (g : α → M → N) (hyf : y ∈ f.support) :
    g y (f y) * (erase y f).Prod g = f.Prod g :=
  by
  rw [Finsupp.prod, Finsupp.prod, ← Finset.mul_prod_erase _ _ hyf, Finsupp.support_erase,
    Finset.prod_congr rfl]
  intro h hx
  rw [Finsupp.erase_ne (ne_of_mem_erase hx)]
#align finsupp.mul_prod_erase Finsupp.mul_prod_erase

/-- Generalization of `finsupp.mul_prod_erase`: if `g` maps a second argument of 0 to 1,
then its product over `f : α →₀ M` is the same as multiplying the value on any element
`y : α` by the product over `erase y f`. -/
@[to_additive
      " Generalization of `finsupp.add_sum_erase`: if `g` maps a second argument of 0\nto 0, then its sum over `f : α →₀ M` is the same as adding the value on any element\n`y : α` to the sum over `erase y f`. "]
theorem mul_prod_erase' (f : α →₀ M) (y : α) (g : α → M → N) (hg : ∀ i : α, g i 0 = 1) :
    g y (f y) * (erase y f).Prod g = f.Prod g := by
  classical
    by_cases hyf : y ∈ f.support
    · exact Finsupp.mul_prod_erase f y g hyf
    · rw [not_mem_support_iff.mp hyf, hg y, erase_of_not_mem_support hyf, one_mul]
#align finsupp.mul_prod_erase' Finsupp.mul_prod_erase'

@[to_additive]
theorem SubmonoidClass.finsupp_prod_mem {S : Type _} [SetLike S N] [SubmonoidClass S N] (s : S)
    (f : α →₀ M) (g : α → M → N) (h : ∀ c, f c ≠ 0 → g c (f c) ∈ s) : f.Prod g ∈ s :=
  prod_mem fun i hi => h _ (Finsupp.mem_support_iff.mp hi)
#align submonoid_class.finsupp_prod_mem SubmonoidClass.finsupp_prod_mem

@[to_additive]
theorem prod_congr {f : α →₀ M} {g1 g2 : α → M → N} (h : ∀ x ∈ f.support, g1 x (f x) = g2 x (f x)) :
    f.Prod g1 = f.Prod g2 :=
  Finset.prod_congr rfl h
#align finsupp.prod_congr Finsupp.prod_congr

end SumProd

end Finsupp

@[to_additive]
theorem map_finsupp_prod [Zero M] [CommMonoid N] [CommMonoid P] {H : Type _} [MonoidHomClass H N P]
    (h : H) (f : α →₀ M) (g : α → M → N) : h (f.Prod g) = f.Prod fun a b => h (g a b) :=
  map_prod h _ _
#align map_finsupp_prod map_finsupp_prod

/-- Deprecated, use `_root_.map_finsupp_prod` instead. -/
@[to_additive "Deprecated, use `_root_.map_finsupp_sum` instead."]
protected theorem MulEquiv.map_finsupp_prod [Zero M] [CommMonoid N] [CommMonoid P] (h : N ≃* P)
    (f : α →₀ M) (g : α → M → N) : h (f.Prod g) = f.Prod fun a b => h (g a b) :=
  map_finsupp_prod h f g
#align mul_equiv.map_finsupp_prod MulEquiv.map_finsupp_prod

/-- Deprecated, use `_root_.map_finsupp_prod` instead. -/
@[to_additive "Deprecated, use `_root_.map_finsupp_sum` instead."]
protected theorem MonoidHom.map_finsupp_prod [Zero M] [CommMonoid N] [CommMonoid P] (h : N →* P)
    (f : α →₀ M) (g : α → M → N) : h (f.Prod g) = f.Prod fun a b => h (g a b) :=
  map_finsupp_prod h f g
#align monoid_hom.map_finsupp_prod MonoidHom.map_finsupp_prod

/-- Deprecated, use `_root_.map_finsupp_sum` instead. -/
protected theorem RingHom.map_finsupp_sum [Zero M] [Semiring R] [Semiring S] (h : R →+* S)
    (f : α →₀ M) (g : α → M → R) : h (f.Sum g) = f.Sum fun a b => h (g a b) :=
  map_finsupp_sum h f g
#align ring_hom.map_finsupp_sum RingHom.map_finsupp_sum

/-- Deprecated, use `_root_.map_finsupp_prod` instead. -/
protected theorem RingHom.map_finsupp_prod [Zero M] [CommSemiring R] [CommSemiring S] (h : R →+* S)
    (f : α →₀ M) (g : α → M → R) : h (f.Prod g) = f.Prod fun a b => h (g a b) :=
  map_finsupp_prod h f g
#align ring_hom.map_finsupp_prod RingHom.map_finsupp_prod

@[to_additive]
theorem MonoidHom.coe_finsupp_prod [Zero β] [Monoid N] [CommMonoid P] (f : α →₀ β)
    (g : α → β → N →* P) : ⇑(f.Prod g) = f.Prod fun i fi => g i fi :=
  MonoidHom.coe_finset_prod _ _
#align monoid_hom.coe_finsupp_prod MonoidHom.coe_finsupp_prod

@[simp, to_additive]
theorem MonoidHom.finsupp_prod_apply [Zero β] [Monoid N] [CommMonoid P] (f : α →₀ β)
    (g : α → β → N →* P) (x : N) : f.Prod g x = f.Prod fun i fi => g i fi x :=
  MonoidHom.finset_prod_apply _ _ _
#align monoid_hom.finsupp_prod_apply MonoidHom.finsupp_prod_apply

namespace Finsupp

theorem single_multiset_sum [AddCommMonoid M] (s : Multiset M) (a : α) :
    single a s.Sum = (s.map (single a)).Sum :=
  (Multiset.induction_on s (single_zero _)) fun a s ih => by
    rw [Multiset.sum_cons, single_add, ih, Multiset.map_cons, Multiset.sum_cons]
#align finsupp.single_multiset_sum Finsupp.single_multiset_sum

theorem single_finset_sum [AddCommMonoid M] (s : Finset ι) (f : ι → M) (a : α) :
    single a (∑ b in s, f b) = ∑ b in s, single a (f b) :=
  by
  trans
  apply single_multiset_sum
  rw [Multiset.map_map]
  rfl
#align finsupp.single_finset_sum Finsupp.single_finset_sum

theorem single_sum [Zero M] [AddCommMonoid N] (s : ι →₀ M) (f : ι → M → N) (a : α) :
    single a (s.Sum f) = s.Sum fun d c => single a (f d c) :=
  single_finset_sum _ _ _
#align finsupp.single_sum Finsupp.single_sum

@[to_additive]
theorem prod_neg_index [AddGroup G] [CommMonoid M] {g : α →₀ G} {h : α → G → M}
    (h0 : ∀ a, h a 0 = 1) : (-g).Prod h = g.Prod fun a b => h a (-b) :=
  prod_map_range_index h0
#align finsupp.prod_neg_index Finsupp.prod_neg_index

end Finsupp

namespace Finsupp

theorem finset_sum_apply [AddCommMonoid N] (S : Finset ι) (f : ι → α →₀ N) (a : α) :
    (∑ i in S, f i) a = ∑ i in S, f i a :=
  (applyAddHom a : (α →₀ N) →+ _).map_sum _ _
#align finsupp.finset_sum_apply Finsupp.finset_sum_apply

@[simp]
theorem sum_apply [Zero M] [AddCommMonoid N] {f : α →₀ M} {g : α → M → β →₀ N} {a₂ : β} :
    (f.Sum g) a₂ = f.Sum fun a₁ b => g a₁ b a₂ :=
  finset_sum_apply _ _ _
#align finsupp.sum_apply Finsupp.sum_apply

theorem coe_finset_sum [AddCommMonoid N] (S : Finset ι) (f : ι → α →₀ N) :
    ⇑(∑ i in S, f i) = ∑ i in S, f i :=
  (coeFnAddHom : (α →₀ N) →+ _).map_sum _ _
#align finsupp.coe_finset_sum Finsupp.coe_finset_sum

theorem coe_sum [Zero M] [AddCommMonoid N] (f : α →₀ M) (g : α → M → β →₀ N) :
    ⇑(f.Sum g) = f.Sum fun a₁ b => g a₁ b :=
  coe_finset_sum _ _
#align finsupp.coe_sum Finsupp.coe_sum

theorem support_sum [DecidableEq β] [Zero M] [AddCommMonoid N] {f : α →₀ M} {g : α → M → β →₀ N} :
    (f.Sum g).support ⊆ f.support.bUnion fun a => (g a (f a)).support :=
  by
  have : ∀ c, (f.Sum fun a b => g a b c) ≠ 0 → ∃ a, f a ≠ 0 ∧ ¬(g a (f a)) c = 0 := fun a₁ h =>
    let ⟨a, ha, Ne⟩ := Finset.exists_ne_zero_of_sum_ne_zero h
    ⟨a, mem_support_iff.mp ha, Ne⟩
  simpa only [Finset.subset_iff, mem_support_iff, Finset.mem_bUnion, sum_apply, exists_prop]
#align finsupp.support_sum Finsupp.support_sum

theorem support_finset_sum [DecidableEq β] [AddCommMonoid M] {s : Finset α} {f : α → β →₀ M} :
    (Finset.sum s f).support ⊆ s.bUnion fun x => (f x).support :=
  by
  rw [← Finset.sup_eq_bUnion]
  induction' s using Finset.cons_induction_on with a s ha ih
  · rfl
  · rw [Finset.sum_cons, Finset.sup_cons]
    exact support_add.trans (Finset.union_subset_union (Finset.Subset.refl _) ih)
#align finsupp.support_finset_sum Finsupp.support_finset_sum

@[simp]
theorem sum_zero [Zero M] [AddCommMonoid N] {f : α →₀ M} : (f.Sum fun a b => (0 : N)) = 0 :=
  Finset.sum_const_zero
#align finsupp.sum_zero Finsupp.sum_zero

@[simp, to_additive]
theorem prod_mul [Zero M] [CommMonoid N] {f : α →₀ M} {h₁ h₂ : α → M → N} :
    (f.Prod fun a b => h₁ a b * h₂ a b) = f.Prod h₁ * f.Prod h₂ :=
  Finset.prod_mul_distrib
#align finsupp.prod_mul Finsupp.prod_mul

@[simp, to_additive]
theorem prod_inv [Zero M] [CommGroup G] {f : α →₀ M} {h : α → M → G} :
    (f.Prod fun a b => (h a b)⁻¹) = (f.Prod h)⁻¹ :=
  (map_prod (MonoidHom.id G)⁻¹ _ _).symm
#align finsupp.prod_inv Finsupp.prod_inv

@[simp]
theorem sum_sub [Zero M] [AddCommGroup G] {f : α →₀ M} {h₁ h₂ : α → M → G} :
    (f.Sum fun a b => h₁ a b - h₂ a b) = f.Sum h₁ - f.Sum h₂ :=
  Finset.sum_sub_distrib
#align finsupp.sum_sub Finsupp.sum_sub

/-- Taking the product under `h` is an additive-to-multiplicative homomorphism of finsupps,
if `h` is an additive-to-multiplicative homomorphism on the support.
This is a more general version of `finsupp.prod_add_index'`; the latter has simpler hypotheses. -/
@[to_additive
      "Taking the product under `h` is an additive homomorphism of finsupps,\nif `h` is an additive homomorphism on the support.\nThis is a more general version of `finsupp.sum_add_index'`; the latter has simpler hypotheses."]
theorem prod_add_index [AddZeroClass M] [CommMonoid N] {f g : α →₀ M} {h : α → M → N}
    (h_zero : ∀ a ∈ f.support ∪ g.support, h a 0 = 1)
    (h_add : ∀ a ∈ f.support ∪ g.support, ∀ (b₁ b₂), h a (b₁ + b₂) = h a b₁ * h a b₂) :
    (f + g).Prod h = f.Prod h * g.Prod h :=
  by
  rw [Finsupp.prod_of_support_subset f (subset_union_left _ g.support) h h_zero,
    Finsupp.prod_of_support_subset g (subset_union_right f.support _) h h_zero, ←
    Finset.prod_mul_distrib, Finsupp.prod_of_support_subset (f + g) Finsupp.support_add h h_zero]
  exact Finset.prod_congr rfl fun x hx => by apply h_add x hx
#align finsupp.prod_add_index Finsupp.prod_add_index

/-- Taking the product under `h` is an additive-to-multiplicative homomorphism of finsupps,
if `h` is an additive-to-multiplicative homomorphism.
This is a more specialized version of `finsupp.prod_add_index` with simpler hypotheses. -/
@[to_additive
      "Taking the sum under `h` is an additive homomorphism of finsupps,\nif `h` is an additive homomorphism.\nThis is a more specific version of `finsupp.sum_add_index` with simpler hypotheses."]
theorem prod_add_index' [AddZeroClass M] [CommMonoid N] {f g : α →₀ M} {h : α → M → N}
    (h_zero : ∀ a, h a 0 = 1) (h_add : ∀ a b₁ b₂, h a (b₁ + b₂) = h a b₁ * h a b₂) :
    (f + g).Prod h = f.Prod h * g.Prod h :=
  prod_add_index (fun a ha => h_zero a) fun a ha => h_add a
#align finsupp.prod_add_index' Finsupp.prod_add_index'

@[simp]
theorem sum_hom_add_index [AddZeroClass M] [AddCommMonoid N] {f g : α →₀ M} (h : α → M →+ N) :
    ((f + g).Sum fun x => h x) = (f.Sum fun x => h x) + g.Sum fun x => h x :=
  sum_add_index' (fun a => (h a).map_zero) fun a => (h a).map_add
#align finsupp.sum_hom_add_index Finsupp.sum_hom_add_index

@[simp]
theorem prod_hom_add_index [AddZeroClass M] [CommMonoid N] {f g : α →₀ M}
    (h : α → Multiplicative M →* N) :
    ((f + g).Prod fun a b => h a (Multiplicative.ofAdd b)) =
      (f.Prod fun a b => h a (Multiplicative.ofAdd b)) *
        g.Prod fun a b => h a (Multiplicative.ofAdd b) :=
  prod_add_index' (fun a => (h a).map_one) fun a => (h a).map_mul
#align finsupp.prod_hom_add_index Finsupp.prod_hom_add_index

/-- The canonical isomorphism between families of additive monoid homomorphisms `α → (M →+ N)`
and monoid homomorphisms `(α →₀ M) →+ N`. -/
def liftAddHom [AddZeroClass M] [AddCommMonoid N] : (α → M →+ N) ≃+ ((α →₀ M) →+ N)
    where
  toFun F :=
    { toFun := fun f => f.Sum fun x => F x
      map_zero' := Finset.sum_empty
      map_add' := fun _ _ => sum_add_index' (fun x => (F x).map_zero) fun x => (F x).map_add }
  invFun F x := F.comp <| singleAddHom x
  left_inv F := by
    ext
    simp
  right_inv F := by
    ext
    simp
  map_add' F G := by
    ext
    simp
#align finsupp.lift_add_hom Finsupp.liftAddHom

@[simp]
theorem lift_add_hom_apply [AddCommMonoid M] [AddCommMonoid N] (F : α → M →+ N) (f : α →₀ M) :
    liftAddHom F f = f.Sum fun x => F x :=
  rfl
#align finsupp.lift_add_hom_apply Finsupp.lift_add_hom_apply

@[simp]
theorem lift_add_hom_symm_apply [AddCommMonoid M] [AddCommMonoid N] (F : (α →₀ M) →+ N) (x : α) :
    liftAddHom.symm F x = F.comp (singleAddHom x) :=
  rfl
#align finsupp.lift_add_hom_symm_apply Finsupp.lift_add_hom_symm_apply

theorem lift_add_hom_symm_apply_apply [AddCommMonoid M] [AddCommMonoid N] (F : (α →₀ M) →+ N)
    (x : α) (y : M) : liftAddHom.symm F x y = F (single x y) :=
  rfl
#align finsupp.lift_add_hom_symm_apply_apply Finsupp.lift_add_hom_symm_apply_apply

@[simp]
theorem lift_add_hom_single_add_hom [AddCommMonoid M] :
    liftAddHom (singleAddHom : α → M →+ α →₀ M) = AddMonoidHom.id _ :=
  liftAddHom.toEquiv.apply_eq_iff_eq_symm_apply.2 rfl
#align finsupp.lift_add_hom_single_add_hom Finsupp.lift_add_hom_single_add_hom

@[simp]
theorem sum_single [AddCommMonoid M] (f : α →₀ M) : f.Sum single = f :=
  AddMonoidHom.congr_fun lift_add_hom_single_add_hom f
#align finsupp.sum_single Finsupp.sum_single

@[simp]
theorem sum_univ_single [AddCommMonoid M] [Fintype α] (i : α) (m : M) :
    (∑ j : α, (single i m) j) = m := by simp [single]
#align finsupp.sum_univ_single Finsupp.sum_univ_single

@[simp]
theorem sum_univ_single' [AddCommMonoid M] [Fintype α] (i : α) (m : M) :
    (∑ j : α, (single j m) i) = m := by simp [single]
#align finsupp.sum_univ_single' Finsupp.sum_univ_single'

@[simp]
theorem lift_add_hom_apply_single [AddCommMonoid M] [AddCommMonoid N] (f : α → M →+ N) (a : α)
    (b : M) : liftAddHom f (single a b) = f a b :=
  sum_single_index (f a).map_zero
#align finsupp.lift_add_hom_apply_single Finsupp.lift_add_hom_apply_single

@[simp]
theorem lift_add_hom_comp_single [AddCommMonoid M] [AddCommMonoid N] (f : α → M →+ N) (a : α) :
    (liftAddHom f).comp (singleAddHom a) = f a :=
  AddMonoidHom.ext fun b => lift_add_hom_apply_single f a b
#align finsupp.lift_add_hom_comp_single Finsupp.lift_add_hom_comp_single

theorem comp_lift_add_hom [AddCommMonoid M] [AddCommMonoid N] [AddCommMonoid P] (g : N →+ P)
    (f : α → M →+ N) : g.comp (liftAddHom f) = liftAddHom fun a => g.comp (f a) :=
  liftAddHom.symm_apply_eq.1 <|
    funext fun a => by
      rw [lift_add_hom_symm_apply, AddMonoidHom.comp_assoc, lift_add_hom_comp_single]
#align finsupp.comp_lift_add_hom Finsupp.comp_lift_add_hom

theorem sum_sub_index [AddCommGroup β] [AddCommGroup γ] {f g : α →₀ β} {h : α → β → γ}
    (h_sub : ∀ a b₁ b₂, h a (b₁ - b₂) = h a b₁ - h a b₂) : (f - g).Sum h = f.Sum h - g.Sum h :=
  (liftAddHom fun a => AddMonoidHom.ofMapSub (h a) (h_sub a)).map_sub f g
#align finsupp.sum_sub_index Finsupp.sum_sub_index

@[to_additive]
theorem prod_emb_domain [Zero M] [CommMonoid N] {v : α →₀ M} {f : α ↪ β} {g : β → M → N} :
    (v.embDomain f).Prod g = v.Prod fun a b => g (f a) b :=
  by
  rw [Prod, Prod, support_emb_domain, Finset.prod_map]
  simp_rw [emb_domain_apply]
#align finsupp.prod_emb_domain Finsupp.prod_emb_domain

@[to_additive]
theorem prod_finset_sum_index [AddCommMonoid M] [CommMonoid N] {s : Finset ι} {g : ι → α →₀ M}
    {h : α → M → N} (h_zero : ∀ a, h a 0 = 1) (h_add : ∀ a b₁ b₂, h a (b₁ + b₂) = h a b₁ * h a b₂) :
    (∏ i in s, (g i).Prod h) = (∑ i in s, g i).Prod h :=
  (Finset.induction_on s rfl) fun a s has ih => by
    rw [prod_insert has, ih, sum_insert has, prod_add_index' h_zero h_add]
#align finsupp.prod_finset_sum_index Finsupp.prod_finset_sum_index

@[to_additive]
theorem prod_sum_index [AddCommMonoid M] [AddCommMonoid N] [CommMonoid P] {f : α →₀ M}
    {g : α → M → β →₀ N} {h : β → N → P} (h_zero : ∀ a, h a 0 = 1)
    (h_add : ∀ a b₁ b₂, h a (b₁ + b₂) = h a b₁ * h a b₂) :
    (f.Sum g).Prod h = f.Prod fun a b => (g a b).Prod h :=
  (prod_finset_sum_index h_zero h_add).symm
#align finsupp.prod_sum_index Finsupp.prod_sum_index

theorem multiset_sum_sum_index [AddCommMonoid M] [AddCommMonoid N] (f : Multiset (α →₀ M))
    (h : α → M → N) (h₀ : ∀ a, h a 0 = 0)
    (h₁ : ∀ (a : α) (b₁ b₂ : M), h a (b₁ + b₂) = h a b₁ + h a b₂) :
    f.Sum.Sum h = (f.map fun g : α →₀ M => g.Sum h).Sum :=
  (Multiset.induction_on f rfl) fun a s ih => by
    rw [Multiset.sum_cons, Multiset.map_cons, Multiset.sum_cons, sum_add_index' h₀ h₁, ih]
#align finsupp.multiset_sum_sum_index Finsupp.multiset_sum_sum_index

theorem support_sum_eq_bUnion {α : Type _} {ι : Type _} {M : Type _} [AddCommMonoid M]
    {g : ι → α →₀ M} (s : Finset ι)
    (h : ∀ i₁ i₂, i₁ ≠ i₂ → Disjoint (g i₁).support (g i₂).support) :
    (∑ i in s, g i).support = s.bUnion fun i => (g i).support :=
  by
  apply Finset.induction_on s
  · simp
  · intro i s hi
    simp only [hi, sum_insert, not_false_iff, bUnion_insert]
    intro hs
    rw [Finsupp.support_add_eq, hs]
    rw [hs, Finset.disjoint_bUnion_right]
    intro j hj
    refine' h _ _ (ne_of_mem_of_not_mem hj hi).symm
#align finsupp.support_sum_eq_bUnion Finsupp.support_sum_eq_bUnion

theorem multiset_map_sum [Zero M] {f : α →₀ M} {m : β → γ} {h : α → M → Multiset β} :
    Multiset.map m (f.Sum h) = f.Sum fun a b => (h a b).map m :=
  (Multiset.mapAddMonoidHom m).map_sum _ f.support
#align finsupp.multiset_map_sum Finsupp.multiset_map_sum

theorem multiset_sum_sum [Zero M] [AddCommMonoid N] {f : α →₀ M} {h : α → M → Multiset N} :
    Multiset.sum (f.Sum h) = f.Sum fun a b => Multiset.sum (h a b) :=
  (Multiset.sumAddMonoidHom : Multiset N →+ N).map_sum _ f.support
#align finsupp.multiset_sum_sum Finsupp.multiset_sum_sum

/-- For disjoint `f1` and `f2`, and function `g`, the product of the products of `g`
over `f1` and `f2` equals the product of `g` over `f1 + f2` -/
@[to_additive
      "For disjoint `f1` and `f2`, and function `g`, the sum of the sums of `g`\nover `f1` and `f2` equals the sum of `g` over `f1 + f2`"]
theorem prod_add_index_of_disjoint [AddCommMonoid M] {f1 f2 : α →₀ M}
    (hd : Disjoint f1.support f2.support) {β : Type _} [CommMonoid β] (g : α → M → β) :
    (f1 + f2).Prod g = f1.Prod g * f2.Prod g :=
  by
  have :
    ∀ {f1 f2 : α →₀ M},
      Disjoint f1.support f2.support → (∏ x in f1.support, g x (f1 x + f2 x)) = f1.Prod g :=
    fun f1 f2 hd =>
    Finset.prod_congr rfl fun x hx => by
      simp only [not_mem_support_iff.mp (disjoint_left.mp hd hx), add_zero]
  simp_rw [← this hd, ← this hd.symm, add_comm (f2 _), Finsupp.prod, support_add_eq hd,
    prod_union hd, add_apply]
#align finsupp.prod_add_index_of_disjoint Finsupp.prod_add_index_of_disjoint

theorem prod_dvd_prod_of_subset_of_dvd [AddCommMonoid M] [CommMonoid N] {f1 f2 : α →₀ M}
    {g1 g2 : α → M → N} (h1 : f1.support ⊆ f2.support)
    (h2 : ∀ a : α, a ∈ f1.support → g1 a (f1 a) ∣ g2 a (f2 a)) : f1.Prod g1 ∣ f2.Prod g2 :=
  by
  simp only [Finsupp.prod, Finsupp.prod_mul]
  rw [← sdiff_union_of_subset h1, prod_union sdiff_disjoint]
  apply dvd_mul_of_dvd_right
  apply prod_dvd_prod_of_dvd
  exact h2
#align finsupp.prod_dvd_prod_of_subset_of_dvd Finsupp.prod_dvd_prod_of_subset_of_dvd

end Finsupp

theorem Finset.sum_apply' : (∑ k in s, f k) i = ∑ k in s, f k i :=
  (Finsupp.applyAddHom i : (ι →₀ A) →+ A).map_sum f s
#align finset.sum_apply' Finset.sum_apply'

theorem Finsupp.sum_apply' : g.Sum k x = g.Sum fun i b => k i b x :=
  Finset.sum_apply _ _ _
#align finsupp.sum_apply' Finsupp.sum_apply'

section

include h0 h1

open Classical

theorem Finsupp.sum_sum_index' : (∑ x in s, f x).Sum t = ∑ x in s, (f x).Sum t :=
  (Finset.induction_on s rfl) fun a s has ih => by
    simp_rw [Finset.sum_insert has, Finsupp.sum_add_index' h0 h1, ih]
#align finsupp.sum_sum_index' Finsupp.sum_sum_index'

end

section

variable [NonUnitalNonAssocSemiring R] [NonUnitalNonAssocSemiring S]

theorem Finsupp.sum_mul (b : S) (s : α →₀ R) {f : α → R → S} :
    s.Sum f * b = s.Sum fun a c => f a c * b := by simp only [Finsupp.sum, Finset.sum_mul]
#align finsupp.sum_mul Finsupp.sum_mul

theorem Finsupp.mul_sum (b : S) (s : α →₀ R) {f : α → R → S} :
    b * s.Sum f = s.Sum fun a c => b * f a c := by simp only [Finsupp.sum, Finset.mul_sum]
#align finsupp.mul_sum Finsupp.mul_sum

end

namespace Nat

/-- If `0 : ℕ` is not in the support of `f : ℕ →₀ ℕ` then `0 < ∏ x in f.support, x ^ (f x)`. -/
theorem prod_pow_pos_of_zero_not_mem_support {f : ℕ →₀ ℕ} (hf : 0 ∉ f.support) : 0 < f.Prod pow :=
  Finset.prod_pos fun a ha =>
    pos_iff_ne_zero.mpr
      (pow_ne_zero _ fun H => by
        subst H
        exact hf ha)
#align nat.prod_pow_pos_of_zero_not_mem_support Nat.prod_pow_pos_of_zero_not_mem_support

end Nat

