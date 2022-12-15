/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module group_theory.subgroup.pointwise
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Subgroup.Basic
import Mathbin.GroupTheory.Submonoid.Pointwise
import Mathbin.GroupTheory.GroupAction.ConjAct

/-! # Pointwise instances on `subgroup` and `add_subgroup`s

This file provides the actions

* `subgroup.pointwise_mul_action`
* `add_subgroup.pointwise_mul_action`

which matches the action of `mul_action_set`.

These actions are available in the `pointwise` locale.

## Implementation notes

The pointwise section of this file is almost identical to `group_theory/submonoid/pointwise.lean`.
Where possible, try to keep them in sync.
-/


open Set

open Pointwise

variable {α G A S : Type _} [Group G] [AddGroup A] {s : Set G}

@[simp, to_additive]
theorem inv_coe_set [SetLike S G] [SubgroupClass S G] {H : S} : (H : Set G)⁻¹ = H := by
  ext
  simp
#align inv_coe_set inv_coe_set

namespace Subgroup

@[simp, to_additive]
theorem inv_subset_closure (S : Set G) : S⁻¹ ⊆ closure S := fun s hs => by
  rw [SetLike.mem_coe, ← Subgroup.inv_mem_iff]
  exact subset_closure (mem_inv.mp hs)
#align subgroup.inv_subset_closure Subgroup.inv_subset_closure

@[to_additive]
theorem closure_to_submonoid (S : Set G) : (closure S).toSubmonoid = Submonoid.closure (S ∪ S⁻¹) :=
  by 
  refine' le_antisymm (fun x hx => _) (Submonoid.closure_le.2 _)
  · refine'
      closure_induction hx
        (fun x hx => Submonoid.closure_mono (subset_union_left S S⁻¹) (Submonoid.subset_closure hx))
        (Submonoid.one_mem _) (fun x y hx hy => Submonoid.mul_mem _ hx hy) fun x hx => _
    rwa [← Submonoid.mem_closure_inv, Set.union_inv, inv_inv, Set.union_comm]
  · simp only [true_and_iff, coe_to_submonoid, union_subset_iff, subset_closure, inv_subset_closure]
#align subgroup.closure_to_submonoid Subgroup.closure_to_submonoid

@[to_additive]
theorem closure_induction_left {p : G → Prop} {x : G} (h : x ∈ closure s) (H1 : p 1)
    (Hmul : ∀ x ∈ s, ∀ (y), p y → p (x * y)) (Hinv : ∀ x ∈ s, ∀ (y), p y → p (x⁻¹ * y)) : p x :=
  let key := (closure_to_submonoid s).le
  (Submonoid.closure_induction_left (key h) H1) fun x hx =>
    (hx.elim (Hmul x)) fun hx y hy => (congr_arg _ <| inv_inv x).mp <| Hinv x⁻¹ hx y hy
#align subgroup.closure_induction_left Subgroup.closure_induction_left

@[to_additive]
theorem closure_induction_right {p : G → Prop} {x : G} (h : x ∈ closure s) (H1 : p 1)
    (Hmul : ∀ (x), ∀ y ∈ s, p x → p (x * y)) (Hinv : ∀ (x), ∀ y ∈ s, p x → p (x * y⁻¹)) : p x :=
  let key := (closure_to_submonoid s).le
  (Submonoid.closure_induction_right (key h) H1) fun x y hy =>
    (hy.elim (Hmul x y)) fun hy hx => (congr_arg _ <| inv_inv y).mp <| Hinv x y⁻¹ hy hx
#align subgroup.closure_induction_right Subgroup.closure_induction_right

@[simp, to_additive]
theorem closure_inv (s : Set G) : closure s⁻¹ = closure s := by
  simp only [← to_submonoid_eq, closure_to_submonoid, inv_inv, union_comm]
#align subgroup.closure_inv Subgroup.closure_inv

/-- An induction principle for closure membership. If `p` holds for `1` and all elements of
`k` and their inverse, and is preserved under multiplication, then `p` holds for all elements of
the closure of `k`. -/
@[to_additive
      "An induction principle for additive closure membership. If `p` holds for `0` and all\nelements of `k` and their negation, and is preserved under addition, then `p` holds for all\nelements of the additive closure of `k`."]
theorem closure_induction'' {p : G → Prop} {x} (h : x ∈ closure s) (Hk : ∀ x ∈ s, p x)
    (Hk_inv : ∀ x ∈ s, p x⁻¹) (H1 : p 1) (Hmul : ∀ x y, p x → p y → p (x * y)) : p x :=
  (closure_induction_left h H1 fun x hx y hy => Hmul x y (Hk x hx) hy) fun x hx y =>
    Hmul x⁻¹ y <| Hk_inv x hx
#align subgroup.closure_induction'' Subgroup.closure_induction''

/-- An induction principle for elements of `⨆ i, S i`.
If `C` holds for `1` and all elements of `S i` for all `i`, and is preserved under multiplication,
then it holds for all elements of the supremum of `S`. -/
@[elab_as_elim,
  to_additive
      " An induction principle for elements of `⨆ i, S i`.\nIf `C` holds for `0` and all elements of `S i` for all `i`, and is preserved under addition,\nthen it holds for all elements of the supremum of `S`. "]
theorem supr_induction {ι : Sort _} (S : ι → Subgroup G) {C : G → Prop} {x : G} (hx : x ∈ ⨆ i, S i)
    (hp : ∀ (i), ∀ x ∈ S i, C x) (h1 : C 1) (hmul : ∀ x y, C x → C y → C (x * y)) : C x := by
  rw [supr_eq_closure] at hx
  refine' closure_induction'' hx (fun x hx => _) (fun x hx => _) h1 hmul
  · obtain ⟨i, hi⟩ := set.mem_Union.mp hx
    exact hp _ _ hi
  · obtain ⟨i, hi⟩ := set.mem_Union.mp hx
    exact hp _ _ (inv_mem hi)
#align subgroup.supr_induction Subgroup.supr_induction

/-- A dependent version of `subgroup.supr_induction`. -/
@[elab_as_elim, to_additive "A dependent version of `add_subgroup.supr_induction`. "]
theorem supr_induction' {ι : Sort _} (S : ι → Subgroup G) {C : ∀ x, (x ∈ ⨆ i, S i) → Prop}
    (hp : ∀ (i), ∀ x ∈ S i, C x (mem_supr_of_mem i ‹_›)) (h1 : C 1 (one_mem _))
    (hmul : ∀ x y hx hy, C x hx → C y hy → C (x * y) (mul_mem ‹_› ‹_›)) {x : G}
    (hx : x ∈ ⨆ i, S i) : C x hx := by
  refine' Exists.elim _ fun (hx : x ∈ ⨆ i, S i) (hc : C x hx) => hc
  refine' supr_induction S hx (fun i x hx => _) _ fun x y => _
  · exact ⟨_, hp _ _ hx⟩
  · exact ⟨_, h1⟩
  · rintro ⟨_, Cx⟩ ⟨_, Cy⟩
    refine' ⟨_, hmul _ _ _ _ Cx Cy⟩
#align subgroup.supr_induction' Subgroup.supr_induction'

@[to_additive]
theorem closure_mul_le (S T : Set G) : closure (S * T) ≤ closure S ⊔ closure T :=
  Inf_le fun x ⟨s, t, hs, ht, hx⟩ =>
    hx ▸
      (closure S ⊔ closure T).mul_mem (SetLike.le_def.mp le_sup_left <| subset_closure hs)
        (SetLike.le_def.mp le_sup_right <| subset_closure ht)
#align subgroup.closure_mul_le Subgroup.closure_mul_le

@[to_additive]
theorem sup_eq_closure (H K : Subgroup G) : H ⊔ K = closure (H * K) :=
  le_antisymm
    (sup_le (fun h hh => subset_closure ⟨h, 1, hh, K.one_mem, mul_one h⟩) fun k hk =>
      subset_closure ⟨1, k, H.one_mem, hk, one_mul k⟩)
    (by conv_rhs => rw [← closure_eq H, ← closure_eq K] <;> apply closure_mul_le)
#align subgroup.sup_eq_closure Subgroup.sup_eq_closure

@[to_additive]
private def mul_normal_aux (H N : Subgroup G) [hN : N.Normal] :
    Subgroup G where 
  carrier := (H : Set G) * N
  one_mem' := ⟨1, 1, H.one_mem, N.one_mem, by rw [mul_one]⟩
  mul_mem' := fun a b ⟨h, n, hh, hn, ha⟩ ⟨h', n', hh', hn', hb⟩ =>
    ⟨h * h', h'⁻¹ * n * h' * n', H.mul_mem hh hh',
      N.mul_mem (by simpa using hN.conj_mem _ hn h'⁻¹) hn', by simp [← ha, ← hb, mul_assoc]⟩
  inv_mem' := fun x ⟨h, n, hh, hn, hx⟩ =>
    ⟨h⁻¹, h * n⁻¹ * h⁻¹, H.inv_mem hh, hN.conj_mem _ (N.inv_mem hn) h, by
      rw [mul_assoc h, inv_mul_cancel_left, ← hx, mul_inv_rev]⟩
#align subgroup.mul_normal_aux subgroup.mul_normal_aux

/-- The carrier of `H ⊔ N` is just `↑H * ↑N` (pointwise set product) when `N` is normal. -/
@[to_additive
      "The carrier of `H ⊔ N` is just `↑H + ↑N` (pointwise set addition)\nwhen `N` is normal."]
theorem mul_normal (H N : Subgroup G) [N.Normal] : (↑(H ⊔ N) : Set G) = H * N :=
  Set.Subset.antisymm
    (show H ⊔ N ≤ mulNormalAux H N by 
      rw [sup_eq_closure]
      apply Inf_le _
      dsimp
      rfl)
    ((sup_eq_closure H N).symm ▸ subset_closure)
#align subgroup.mul_normal Subgroup.mul_normal

@[to_additive]
private def normal_mul_aux (N H : Subgroup G) [hN : N.Normal] :
    Subgroup G where 
  carrier := (N : Set G) * H
  one_mem' := ⟨1, 1, N.one_mem, H.one_mem, by rw [mul_one]⟩
  mul_mem' := fun a b ⟨n, h, hn, hh, ha⟩ ⟨n', h', hn', hh', hb⟩ =>
    ⟨n * (h * n' * h⁻¹), h * h', N.mul_mem hn (hN.conj_mem _ hn' _), H.mul_mem hh hh', by
      simp [← ha, ← hb, mul_assoc]⟩
  inv_mem' := fun x ⟨n, h, hn, hh, hx⟩ =>
    ⟨h⁻¹ * n⁻¹ * h, h⁻¹, by simpa using hN.conj_mem _ (N.inv_mem hn) h⁻¹, H.inv_mem hh, by
      rw [mul_inv_cancel_right, ← mul_inv_rev, hx]⟩
#align subgroup.normal_mul_aux subgroup.normal_mul_aux

/-- The carrier of `N ⊔ H` is just `↑N * ↑H` (pointwise set product) when `N` is normal. -/
@[to_additive
      "The carrier of `N ⊔ H` is just `↑N + ↑H` (pointwise set addition)\nwhen `N` is normal."]
theorem normal_mul (N H : Subgroup G) [N.Normal] : (↑(N ⊔ H) : Set G) = N * H :=
  Set.Subset.antisymm
    (show N ⊔ H ≤ normalMulAux N H by 
      rw [sup_eq_closure]
      apply Inf_le _
      dsimp
      rfl)
    ((sup_eq_closure N H).symm ▸ subset_closure)
#align subgroup.normal_mul Subgroup.normal_mul

@[to_additive]
theorem mul_inf_assoc (A B C : Subgroup G) (h : A ≤ C) : (A : Set G) * ↑(B ⊓ C) = A * B ⊓ C := by
  ext
  simp only [coe_inf, Set.inf_eq_inter, Set.mem_mul, Set.mem_inter_iff]
  constructor
  · rintro ⟨y, z, hy, ⟨hzB, hzC⟩, rfl⟩
    refine' ⟨_, mul_mem (h hy) hzC⟩
    exact ⟨y, z, hy, hzB, rfl⟩
  rintro ⟨⟨y, z, hy, hz, rfl⟩, hyz⟩
  refine' ⟨y, z, hy, ⟨hz, _⟩, rfl⟩
  suffices y⁻¹ * (y * z) ∈ C by simpa
  exact mul_mem (inv_mem (h hy)) hyz
#align subgroup.mul_inf_assoc Subgroup.mul_inf_assoc

@[to_additive]
theorem inf_mul_assoc (A B C : Subgroup G) (h : C ≤ A) :
    ((A ⊓ B : Subgroup G) : Set G) * C = A ⊓ B * C := by
  ext
  simp only [coe_inf, Set.inf_eq_inter, Set.mem_mul, Set.mem_inter_iff]
  constructor
  · rintro ⟨y, z, ⟨hyA, hyB⟩, hz, rfl⟩
    refine' ⟨A.mul_mem hyA (h hz), _⟩
    exact ⟨y, z, hyB, hz, rfl⟩
  rintro ⟨hyz, y, z, hy, hz, rfl⟩
  refine' ⟨y, z, ⟨_, hy⟩, hz, rfl⟩
  suffices y * z * z⁻¹ ∈ A by simpa
  exact mul_mem hyz (inv_mem (h hz))
#align subgroup.inf_mul_assoc Subgroup.inf_mul_assoc

instance sup_normal (H K : Subgroup G) [hH : H.Normal] [hK : K.Normal] :
    (H ⊔
        K).Normal where conj_mem n hmem g := by
    change n ∈ ↑(H ⊔ K) at hmem
    change g * n * g⁻¹ ∈ ↑(H ⊔ K)
    rw [normal_mul, Set.mem_mul] at *
    rcases hmem with ⟨h, k, hh, hk, rfl⟩
    refine' ⟨g * h * g⁻¹, g * k * g⁻¹, hH.conj_mem h hh g, hK.conj_mem k hk g, _⟩
    simp
#align subgroup.sup_normal Subgroup.sup_normal

@[to_additive]
theorem smul_opposite_image_mul_preimage {H : Subgroup G} (g : G) (h : H.opposite) (s : Set G) :
    (fun y => h • y) '' (Mul.mul g ⁻¹' s) = Mul.mul g ⁻¹' ((fun y => h • y) '' s) := by
  ext x
  cases h
  simp [(· • ·), mul_assoc]
#align subgroup.smul_opposite_image_mul_preimage Subgroup.smul_opposite_image_mul_preimage

/-! ### Pointwise action -/


section Monoid

variable [Monoid α] [MulDistribMulAction α G]

/-- The action on a subgroup corresponding to applying the action to every element.

This is available as an instance in the `pointwise` locale. -/
protected def pointwiseMulAction :
    MulAction α
      (Subgroup
        G) where 
  smul a S := S.map (MulDistribMulAction.toMonoidEnd _ _ a)
  one_smul S := (congr_arg (fun f => S.map f) (MonoidHom.map_one _)).trans S.map_id
  mul_smul a₁ a₂ S :=
    (congr_arg (fun f => S.map f) (MonoidHom.map_mul _ _ _)).trans (S.map_map _ _).symm
#align subgroup.pointwise_mul_action Subgroup.pointwiseMulAction

scoped[Pointwise] attribute [instance] Subgroup.pointwiseMulAction

open Pointwise

theorem pointwise_smul_def {a : α} (S : Subgroup G) :
    a • S = S.map (MulDistribMulAction.toMonoidEnd _ _ a) :=
  rfl
#align subgroup.pointwise_smul_def Subgroup.pointwise_smul_def

@[simp]
theorem coe_pointwise_smul (a : α) (S : Subgroup G) : ↑(a • S) = a • (S : Set G) :=
  rfl
#align subgroup.coe_pointwise_smul Subgroup.coe_pointwise_smul

@[simp]
theorem pointwise_smul_to_submonoid (a : α) (S : Subgroup G) :
    (a • S).toSubmonoid = a • S.toSubmonoid :=
  rfl
#align subgroup.pointwise_smul_to_submonoid Subgroup.pointwise_smul_to_submonoid

theorem smul_mem_pointwise_smul (m : G) (a : α) (S : Subgroup G) : m ∈ S → a • m ∈ a • S :=
  (Set.smul_mem_smul_set : _ → _ ∈ a • (S : Set G))
#align subgroup.smul_mem_pointwise_smul Subgroup.smul_mem_pointwise_smul

theorem mem_smul_pointwise_iff_exists (m : G) (a : α) (S : Subgroup G) :
    m ∈ a • S ↔ ∃ s : G, s ∈ S ∧ a • s = m :=
  (Set.mem_smul_set : m ∈ a • (S : Set G) ↔ _)
#align subgroup.mem_smul_pointwise_iff_exists Subgroup.mem_smul_pointwise_iff_exists

@[simp]
theorem smul_bot (a : α) : a • (⊥ : Subgroup G) = ⊥ :=
  map_bot _
#align subgroup.smul_bot Subgroup.smul_bot

theorem smul_sup (a : α) (S T : Subgroup G) : a • (S ⊔ T) = a • S ⊔ a • T :=
  map_sup _ _ _
#align subgroup.smul_sup Subgroup.smul_sup

theorem smul_closure (a : α) (s : Set G) : a • closure s = closure (a • s) :=
  MonoidHom.map_closure _ _
#align subgroup.smul_closure Subgroup.smul_closure

instance pointwise_central_scalar [MulDistribMulAction αᵐᵒᵖ G] [IsCentralScalar α G] :
    IsCentralScalar α (Subgroup G) :=
  ⟨fun a S => (congr_arg fun f => S.map f) <| MonoidHom.ext <| op_smul_eq_smul _⟩
#align subgroup.pointwise_central_scalar Subgroup.pointwise_central_scalar

theorem conj_smul_le_of_le {P H : Subgroup G} (hP : P ≤ H) (h : H) : MulAut.conj (h : G) • P ≤ H :=
  by 
  rintro - ⟨g, hg, rfl⟩
  exact H.mul_mem (H.mul_mem h.2 (hP hg)) (H.inv_mem h.2)
#align subgroup.conj_smul_le_of_le Subgroup.conj_smul_le_of_le

theorem conj_smul_subgroup_of {P H : Subgroup G} (hP : P ≤ H) (h : H) :
    MulAut.conj h • P.subgroupOf H = (MulAut.conj (h : G) • P).subgroupOf H := by
  refine' le_antisymm _ _
  · rintro - ⟨g, hg, rfl⟩
    exact ⟨g, hg, rfl⟩
  · rintro p ⟨g, hg, hp⟩
    exact ⟨⟨g, hP hg⟩, hg, Subtype.ext hp⟩
#align subgroup.conj_smul_subgroup_of Subgroup.conj_smul_subgroup_of

end Monoid

section Group

variable [Group α] [MulDistribMulAction α G]

open Pointwise

@[simp]
theorem smul_mem_pointwise_smul_iff {a : α} {S : Subgroup G} {x : G} : a • x ∈ a • S ↔ x ∈ S :=
  smul_mem_smul_set_iff
#align subgroup.smul_mem_pointwise_smul_iff Subgroup.smul_mem_pointwise_smul_iff

theorem mem_pointwise_smul_iff_inv_smul_mem {a : α} {S : Subgroup G} {x : G} :
    x ∈ a • S ↔ a⁻¹ • x ∈ S :=
  mem_smul_set_iff_inv_smul_mem
#align subgroup.mem_pointwise_smul_iff_inv_smul_mem Subgroup.mem_pointwise_smul_iff_inv_smul_mem

theorem mem_inv_pointwise_smul_iff {a : α} {S : Subgroup G} {x : G} : x ∈ a⁻¹ • S ↔ a • x ∈ S :=
  mem_inv_smul_set_iff
#align subgroup.mem_inv_pointwise_smul_iff Subgroup.mem_inv_pointwise_smul_iff

@[simp]
theorem pointwise_smul_le_pointwise_smul_iff {a : α} {S T : Subgroup G} : a • S ≤ a • T ↔ S ≤ T :=
  set_smul_subset_set_smul_iff
#align subgroup.pointwise_smul_le_pointwise_smul_iff Subgroup.pointwise_smul_le_pointwise_smul_iff

theorem pointwise_smul_subset_iff {a : α} {S T : Subgroup G} : a • S ≤ T ↔ S ≤ a⁻¹ • T :=
  set_smul_subset_iff
#align subgroup.pointwise_smul_subset_iff Subgroup.pointwise_smul_subset_iff

theorem subset_pointwise_smul_iff {a : α} {S T : Subgroup G} : S ≤ a • T ↔ a⁻¹ • S ≤ T :=
  subset_set_smul_iff
#align subgroup.subset_pointwise_smul_iff Subgroup.subset_pointwise_smul_iff

@[simp]
theorem smul_inf (a : α) (S T : Subgroup G) : a • (S ⊓ T) = a • S ⊓ a • T := by
  simp [SetLike.ext_iff, mem_pointwise_smul_iff_inv_smul_mem]
#align subgroup.smul_inf Subgroup.smul_inf

/-- Applying a `mul_distrib_mul_action` results in an isomorphic subgroup -/
@[simps]
def equivSmul (a : α) (H : Subgroup G) : H ≃* (a • H : Subgroup G) :=
  (MulDistribMulAction.toMulEquiv G a).subgroupMap H
#align subgroup.equiv_smul Subgroup.equivSmul

theorem subgroup_mul_singleton {H : Subgroup G} {h : G} (hh : h ∈ H) : (H : Set G) * {h} = H := by
  refine'
    le_antisymm _ fun h' hh' =>
      ⟨h' * h⁻¹, h, H.mul_mem hh' (H.inv_mem hh), rfl, inv_mul_cancel_right h' h⟩
  rintro _ ⟨h', h, hh', rfl : _ = _, rfl⟩
  exact H.mul_mem hh' hh
#align subgroup.subgroup_mul_singleton Subgroup.subgroup_mul_singleton

theorem singleton_mul_subgroup {H : Subgroup G} {h : G} (hh : h ∈ H) : {h} * (H : Set G) = H := by
  refine'
    le_antisymm _ fun h' hh' =>
      ⟨h, h⁻¹ * h', rfl, H.mul_mem (H.inv_mem hh) hh', mul_inv_cancel_left h h'⟩
  rintro _ ⟨h, h', rfl : _ = _, hh', rfl⟩
  exact H.mul_mem hh hh'
#align subgroup.singleton_mul_subgroup Subgroup.singleton_mul_subgroup

theorem Normal.conj_act {G : Type _} [Group G] {H : Subgroup G} (hH : H.Normal) (g : ConjAct G) :
    g • H = H := by 
  ext
  constructor
  · intro h
    have := hH.conj_mem (g⁻¹ • x) _ (ConjAct.ofConjAct g)
    rw [Subgroup.mem_pointwise_smul_iff_inv_smul_mem] at h
    dsimp at *
    rw [ConjAct.smul_def] at *
    simp only [ConjAct.of_conj_act_inv, ConjAct.of_conj_act_to_conj_act, inv_inv] at *
    convert this
    simp only [← mul_assoc, mul_right_inv, one_mul, mul_inv_cancel_right]
    rw [Subgroup.mem_pointwise_smul_iff_inv_smul_mem] at h
    exact h
  · intro h
    rw [Subgroup.mem_pointwise_smul_iff_inv_smul_mem, ConjAct.smul_def]
    apply hH.conj_mem
    exact h
#align subgroup.normal.conj_act Subgroup.Normal.conj_act

@[simp]
theorem smul_normal (g : G) (H : Subgroup G) [h : Normal H] : MulAut.conj g • H = H :=
  h.ConjAct g
#align subgroup.smul_normal Subgroup.smul_normal

end Group

section GroupWithZero

variable [GroupWithZero α] [MulDistribMulAction α G]

open Pointwise

@[simp]
theorem smul_mem_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) (S : Subgroup G) (x : G) :
    a • x ∈ a • S ↔ x ∈ S :=
  smul_mem_smul_set_iff₀ ha (S : Set G) x
#align subgroup.smul_mem_pointwise_smul_iff₀ Subgroup.smul_mem_pointwise_smul_iff₀

theorem mem_pointwise_smul_iff_inv_smul_mem₀ {a : α} (ha : a ≠ 0) (S : Subgroup G) (x : G) :
    x ∈ a • S ↔ a⁻¹ • x ∈ S :=
  mem_smul_set_iff_inv_smul_mem₀ ha (S : Set G) x
#align subgroup.mem_pointwise_smul_iff_inv_smul_mem₀ Subgroup.mem_pointwise_smul_iff_inv_smul_mem₀

theorem mem_inv_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) (S : Subgroup G) (x : G) :
    x ∈ a⁻¹ • S ↔ a • x ∈ S :=
  mem_inv_smul_set_iff₀ ha (S : Set G) x
#align subgroup.mem_inv_pointwise_smul_iff₀ Subgroup.mem_inv_pointwise_smul_iff₀

@[simp]
theorem pointwise_smul_le_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) {S T : Subgroup G} :
    a • S ≤ a • T ↔ S ≤ T :=
  set_smul_subset_set_smul_iff₀ ha
#align subgroup.pointwise_smul_le_pointwise_smul_iff₀ Subgroup.pointwise_smul_le_pointwise_smul_iff₀

theorem pointwise_smul_le_iff₀ {a : α} (ha : a ≠ 0) {S T : Subgroup G} : a • S ≤ T ↔ S ≤ a⁻¹ • T :=
  set_smul_subset_iff₀ ha
#align subgroup.pointwise_smul_le_iff₀ Subgroup.pointwise_smul_le_iff₀

theorem le_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) {S T : Subgroup G} : S ≤ a • T ↔ a⁻¹ • S ≤ T :=
  subset_set_smul_iff₀ ha
#align subgroup.le_pointwise_smul_iff₀ Subgroup.le_pointwise_smul_iff₀

end GroupWithZero

end Subgroup

namespace AddSubgroup

section Monoid

variable [Monoid α] [DistribMulAction α A]

/-- The action on an additive subgroup corresponding to applying the action to every element.

This is available as an instance in the `pointwise` locale. -/
protected def pointwiseMulAction :
    MulAction α
      (AddSubgroup
        A) where 
  smul a S := S.map (DistribMulAction.toAddMonoidEnd _ _ a)
  one_smul S := (congr_arg (fun f => S.map f) (MonoidHom.map_one _)).trans S.map_id
  mul_smul a₁ a₂ S :=
    (congr_arg (fun f => S.map f) (MonoidHom.map_mul _ _ _)).trans (S.map_map _ _).symm
#align add_subgroup.pointwise_mul_action AddSubgroup.pointwiseMulAction

scoped[Pointwise] attribute [instance] AddSubgroup.pointwiseMulAction

open Pointwise

@[simp]
theorem coe_pointwise_smul (a : α) (S : AddSubgroup A) : ↑(a • S) = a • (S : Set A) :=
  rfl
#align add_subgroup.coe_pointwise_smul AddSubgroup.coe_pointwise_smul

@[simp]
theorem pointwise_smul_to_add_submonoid (a : α) (S : AddSubgroup A) :
    (a • S).toAddSubmonoid = a • S.toAddSubmonoid :=
  rfl
#align add_subgroup.pointwise_smul_to_add_submonoid AddSubgroup.pointwise_smul_to_add_submonoid

theorem smul_mem_pointwise_smul (m : A) (a : α) (S : AddSubgroup A) : m ∈ S → a • m ∈ a • S :=
  (Set.smul_mem_smul_set : _ → _ ∈ a • (S : Set A))
#align add_subgroup.smul_mem_pointwise_smul AddSubgroup.smul_mem_pointwise_smul

theorem mem_smul_pointwise_iff_exists (m : A) (a : α) (S : AddSubgroup A) :
    m ∈ a • S ↔ ∃ s : A, s ∈ S ∧ a • s = m :=
  (Set.mem_smul_set : m ∈ a • (S : Set A) ↔ _)
#align add_subgroup.mem_smul_pointwise_iff_exists AddSubgroup.mem_smul_pointwise_iff_exists

instance pointwise_central_scalar [DistribMulAction αᵐᵒᵖ A] [IsCentralScalar α A] :
    IsCentralScalar α (AddSubgroup A) :=
  ⟨fun a S => (congr_arg fun f => S.map f) <| AddMonoidHom.ext <| op_smul_eq_smul _⟩
#align add_subgroup.pointwise_central_scalar AddSubgroup.pointwise_central_scalar

end Monoid

section Group

variable [Group α] [DistribMulAction α A]

open Pointwise

@[simp]
theorem smul_mem_pointwise_smul_iff {a : α} {S : AddSubgroup A} {x : A} : a • x ∈ a • S ↔ x ∈ S :=
  smul_mem_smul_set_iff
#align add_subgroup.smul_mem_pointwise_smul_iff AddSubgroup.smul_mem_pointwise_smul_iff

theorem mem_pointwise_smul_iff_inv_smul_mem {a : α} {S : AddSubgroup A} {x : A} :
    x ∈ a • S ↔ a⁻¹ • x ∈ S :=
  mem_smul_set_iff_inv_smul_mem
#align
  add_subgroup.mem_pointwise_smul_iff_inv_smul_mem AddSubgroup.mem_pointwise_smul_iff_inv_smul_mem

theorem mem_inv_pointwise_smul_iff {a : α} {S : AddSubgroup A} {x : A} : x ∈ a⁻¹ • S ↔ a • x ∈ S :=
  mem_inv_smul_set_iff
#align add_subgroup.mem_inv_pointwise_smul_iff AddSubgroup.mem_inv_pointwise_smul_iff

@[simp]
theorem pointwise_smul_le_pointwise_smul_iff {a : α} {S T : AddSubgroup A} :
    a • S ≤ a • T ↔ S ≤ T :=
  set_smul_subset_set_smul_iff
#align
  add_subgroup.pointwise_smul_le_pointwise_smul_iff AddSubgroup.pointwise_smul_le_pointwise_smul_iff

theorem pointwise_smul_le_iff {a : α} {S T : AddSubgroup A} : a • S ≤ T ↔ S ≤ a⁻¹ • T :=
  set_smul_subset_iff
#align add_subgroup.pointwise_smul_le_iff AddSubgroup.pointwise_smul_le_iff

theorem le_pointwise_smul_iff {a : α} {S T : AddSubgroup A} : S ≤ a • T ↔ a⁻¹ • S ≤ T :=
  subset_set_smul_iff
#align add_subgroup.le_pointwise_smul_iff AddSubgroup.le_pointwise_smul_iff

end Group

section GroupWithZero

variable [GroupWithZero α] [DistribMulAction α A]

open Pointwise

@[simp]
theorem smul_mem_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) (S : AddSubgroup A) (x : A) :
    a • x ∈ a • S ↔ x ∈ S :=
  smul_mem_smul_set_iff₀ ha (S : Set A) x
#align add_subgroup.smul_mem_pointwise_smul_iff₀ AddSubgroup.smul_mem_pointwise_smul_iff₀

theorem mem_pointwise_smul_iff_inv_smul_mem₀ {a : α} (ha : a ≠ 0) (S : AddSubgroup A) (x : A) :
    x ∈ a • S ↔ a⁻¹ • x ∈ S :=
  mem_smul_set_iff_inv_smul_mem₀ ha (S : Set A) x
#align
  add_subgroup.mem_pointwise_smul_iff_inv_smul_mem₀ AddSubgroup.mem_pointwise_smul_iff_inv_smul_mem₀

theorem mem_inv_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) (S : AddSubgroup A) (x : A) :
    x ∈ a⁻¹ • S ↔ a • x ∈ S :=
  mem_inv_smul_set_iff₀ ha (S : Set A) x
#align add_subgroup.mem_inv_pointwise_smul_iff₀ AddSubgroup.mem_inv_pointwise_smul_iff₀

@[simp]
theorem pointwise_smul_le_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) {S T : AddSubgroup A} :
    a • S ≤ a • T ↔ S ≤ T :=
  set_smul_subset_set_smul_iff₀ ha
#align
  add_subgroup.pointwise_smul_le_pointwise_smul_iff₀ AddSubgroup.pointwise_smul_le_pointwise_smul_iff₀

theorem pointwise_smul_le_iff₀ {a : α} (ha : a ≠ 0) {S T : AddSubgroup A} :
    a • S ≤ T ↔ S ≤ a⁻¹ • T :=
  set_smul_subset_iff₀ ha
#align add_subgroup.pointwise_smul_le_iff₀ AddSubgroup.pointwise_smul_le_iff₀

theorem le_pointwise_smul_iff₀ {a : α} (ha : a ≠ 0) {S T : AddSubgroup A} :
    S ≤ a • T ↔ a⁻¹ • S ≤ T :=
  subset_set_smul_iff₀ ha
#align add_subgroup.le_pointwise_smul_iff₀ AddSubgroup.le_pointwise_smul_iff₀

end GroupWithZero

end AddSubgroup

