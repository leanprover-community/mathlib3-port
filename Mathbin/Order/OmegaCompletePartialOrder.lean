/-
Copyright (c) 2020 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module order.omega_complete_partial_order
! leanprover-community/mathlib commit 48085f140e684306f9e7da907cd5932056d1aded
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Control.Monad.Basic
import Mathbin.Data.Part
import Mathbin.Order.Hom.Order
import Mathbin.Data.Nat.Order.Basic
import Mathbin.Tactic.Wlog

/-!
# Omega Complete Partial Orders

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

An omega-complete partial order is a partial order with a supremum
operation on increasing sequences indexed by natural numbers (which we
call `ωSup`). In this sense, it is strictly weaker than join complete
semi-lattices as only ω-sized totally ordered sets have a supremum.

The concept of an omega-complete partial order (ωCPO) is useful for the
formalization of the semantics of programming languages. Its notion of
supremum helps define the meaning of recursive procedures.

## Main definitions

 * class `omega_complete_partial_order`
 * `ite`, `map`, `bind`, `seq` as continuous morphisms

## Instances of `omega_complete_partial_order`

 * `part`
 * every `complete_lattice`
 * pi-types
 * product types
 * `monotone_hom`
 * `continuous_hom` (with notation →𝒄)
   * an instance of `omega_complete_partial_order (α →𝒄 β)`
 * `continuous_hom.of_fun`
 * `continuous_hom.of_mono`
 * continuous functions:
   * `id`
   * `ite`
   * `const`
   * `part.bind`
   * `part.map`
   * `part.seq`

## References

 * [Chain-complete posets and directed sets with applications][markowsky1976]
 * [Recursive definitions of partial functions and their computations][cadiou1972]
 * [Semantics of Programming Languages: Structures and Techniques][gunter1992]
-/


universe u v

attribute [-simp] Part.bind_eq_bind Part.map_eq_map

open Classical

namespace OrderHom

variable (α : Type _) (β : Type _) {γ : Type _} {φ : Type _}

variable [Preorder α] [Preorder β] [Preorder γ] [Preorder φ]

variable {β γ}

variable {α} {α' : Type _} {β' : Type _} [Preorder α'] [Preorder β']

/- warning: order_hom.bind -> OrderHom.bind is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Preorder.{u1} α] {β : Type.{u2}} {γ : Type.{u2}}, (OrderHom.{u1, u2} α (Part.{u2} β) _inst_1 (PartialOrder.toPreorder.{u2} (Part.{u2} β) (Part.partialOrder.{u2} β))) -> (OrderHom.{u1, u2} α (β -> (Part.{u2} γ)) _inst_1 (Pi.preorder.{u2, u2} β (fun (ᾰ : β) => Part.{u2} γ) (fun (i : β) => PartialOrder.toPreorder.{u2} (Part.{u2} γ) (Part.partialOrder.{u2} γ)))) -> (OrderHom.{u1, u2} α (Part.{u2} γ) _inst_1 (PartialOrder.toPreorder.{u2} (Part.{u2} γ) (Part.partialOrder.{u2} γ)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Preorder.{u1} α] {β : Type.{u2}} {γ : Type.{u2}}, (OrderHom.{u1, u2} α (Part.{u2} β) _inst_1 (PartialOrder.toPreorder.{u2} (Part.{u2} β) (Part.instPartialOrderPart.{u2} β))) -> (OrderHom.{u1, u2} α (β -> (Part.{u2} γ)) _inst_1 (Pi.preorder.{u2, u2} β (fun (ᾰ : β) => Part.{u2} γ) (fun (i : β) => PartialOrder.toPreorder.{u2} (Part.{u2} γ) (Part.instPartialOrderPart.{u2} γ)))) -> (OrderHom.{u1, u2} α (Part.{u2} γ) _inst_1 (PartialOrder.toPreorder.{u2} (Part.{u2} γ) (Part.instPartialOrderPart.{u2} γ)))
Case conversion may be inaccurate. Consider using '#align order_hom.bind OrderHom.bindₓ'. -/
/-- `part.bind` as a monotone function -/
@[simps]
def bind {β γ} (f : α →o Part β) (g : α →o β → Part γ) : α →o Part γ
    where
  toFun x := f x >>= g x
  monotone' := by
    intro x y h a
    simp only [and_imp, exists_prop, Part.bind_eq_bind, Part.mem_bind_iff, exists_imp]
    intro b hb ha
    refine' ⟨b, f.monotone h _ hb, g.monotone h _ _ ha⟩
#align order_hom.bind OrderHom.bind

end OrderHom

namespace OmegaCompletePartialOrder

#print OmegaCompletePartialOrder.Chain /-
/-- A chain is a monotone sequence.

See the definition on page 114 of [gunter1992]. -/
def Chain (α : Type u) [Preorder α] :=
  ℕ →o α
#align omega_complete_partial_order.chain OmegaCompletePartialOrder.Chain
-/

namespace Chain

variable {α : Type u} {β : Type v} {γ : Type _}

variable [Preorder α] [Preorder β] [Preorder γ]

instance : CoeFun (Chain α) fun _ => ℕ → α :=
  OrderHom.hasCoeToFun

instance [Inhabited α] : Inhabited (Chain α) :=
  ⟨⟨default, fun _ _ _ => le_rfl⟩⟩

instance : Membership α (Chain α) :=
  ⟨fun a (c : ℕ →o α) => ∃ i, a = c i⟩

variable (c c' : Chain α)

variable (f : α →o β)

variable (g : β →o γ)

instance : LE (Chain α) where le x y := ∀ i, ∃ j, x i ≤ y j

#print OmegaCompletePartialOrder.Chain.map /-
/-- `map` function for `chain` -/
@[simps (config := { fullyApplied := false })]
def map : Chain β :=
  f.comp c
#align omega_complete_partial_order.chain.map OmegaCompletePartialOrder.Chain.map
-/

variable {f}

#print OmegaCompletePartialOrder.Chain.mem_map /-
theorem mem_map (x : α) : x ∈ c → f x ∈ Chain.map c f := fun ⟨i, h⟩ => ⟨i, h.symm ▸ rfl⟩
#align omega_complete_partial_order.chain.mem_map OmegaCompletePartialOrder.Chain.mem_map
-/

#print OmegaCompletePartialOrder.Chain.exists_of_mem_map /-
theorem exists_of_mem_map {b : β} : b ∈ c.map f → ∃ a, a ∈ c ∧ f a = b := fun ⟨i, h⟩ =>
  ⟨c i, ⟨i, rfl⟩, h.symm⟩
#align omega_complete_partial_order.chain.exists_of_mem_map OmegaCompletePartialOrder.Chain.exists_of_mem_map
-/

#print OmegaCompletePartialOrder.Chain.mem_map_iff /-
theorem mem_map_iff {b : β} : b ∈ c.map f ↔ ∃ a, a ∈ c ∧ f a = b :=
  ⟨exists_of_mem_map _, fun h => by
    rcases h with ⟨w, h, h'⟩
    subst b
    apply mem_map c _ h⟩
#align omega_complete_partial_order.chain.mem_map_iff OmegaCompletePartialOrder.Chain.mem_map_iff
-/

#print OmegaCompletePartialOrder.Chain.map_id /-
@[simp]
theorem map_id : c.map OrderHom.id = c :=
  OrderHom.comp_id _
#align omega_complete_partial_order.chain.map_id OmegaCompletePartialOrder.Chain.map_id
-/

/- warning: omega_complete_partial_order.chain.map_comp -> OmegaCompletePartialOrder.Chain.map_comp is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : Preorder.{u1} α] [_inst_2 : Preorder.{u2} β] [_inst_3 : Preorder.{u3} γ] (c : OmegaCompletePartialOrder.Chain.{u1} α _inst_1) {f : OrderHom.{u1, u2} α β _inst_1 _inst_2} (g : OrderHom.{u2, u3} β γ _inst_2 _inst_3), Eq.{succ u3} (OmegaCompletePartialOrder.Chain.{u3} γ _inst_3) (OmegaCompletePartialOrder.Chain.map.{u2, u3} β γ _inst_2 _inst_3 (OmegaCompletePartialOrder.Chain.map.{u1, u2} α β _inst_1 _inst_2 c f) g) (OmegaCompletePartialOrder.Chain.map.{u1, u3} α γ _inst_1 _inst_3 c (OrderHom.comp.{u1, u2, u3} α β γ _inst_1 _inst_2 _inst_3 g f))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u3}} {γ : Type.{u1}} [_inst_1 : Preorder.{u2} α] [_inst_2 : Preorder.{u3} β] [_inst_3 : Preorder.{u1} γ] (c : OmegaCompletePartialOrder.Chain.{u2} α _inst_1) {f : OrderHom.{u2, u3} α β _inst_1 _inst_2} (g : OrderHom.{u3, u1} β γ _inst_2 _inst_3), Eq.{succ u1} (OmegaCompletePartialOrder.Chain.{u1} γ _inst_3) (OmegaCompletePartialOrder.Chain.map.{u3, u1} β γ _inst_2 _inst_3 (OmegaCompletePartialOrder.Chain.map.{u2, u3} α β _inst_1 _inst_2 c f) g) (OmegaCompletePartialOrder.Chain.map.{u2, u1} α γ _inst_1 _inst_3 c (OrderHom.comp.{u2, u3, u1} α β γ _inst_1 _inst_2 _inst_3 g f))
Case conversion may be inaccurate. Consider using '#align omega_complete_partial_order.chain.map_comp OmegaCompletePartialOrder.Chain.map_compₓ'. -/
theorem map_comp : (c.map f).map g = c.map (g.comp f) :=
  rfl
#align omega_complete_partial_order.chain.map_comp OmegaCompletePartialOrder.Chain.map_comp

#print OmegaCompletePartialOrder.Chain.map_le_map /-
@[mono]
theorem map_le_map {g : α →o β} (h : f ≤ g) : c.map f ≤ c.map g := fun i => by
  simp [mem_map_iff] <;> intros <;> exists i <;> apply h
#align omega_complete_partial_order.chain.map_le_map OmegaCompletePartialOrder.Chain.map_le_map
-/

/- warning: omega_complete_partial_order.chain.zip -> OmegaCompletePartialOrder.Chain.zip is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : Preorder.{u1} α] [_inst_2 : Preorder.{u2} β], (OmegaCompletePartialOrder.Chain.{u1} α _inst_1) -> (OmegaCompletePartialOrder.Chain.{u2} β _inst_2) -> (OmegaCompletePartialOrder.Chain.{max u1 u2} (Prod.{u1, u2} α β) (Prod.preorder.{u1, u2} α β _inst_1 _inst_2))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : Preorder.{u1} α] [_inst_2 : Preorder.{u2} β], (OmegaCompletePartialOrder.Chain.{u1} α _inst_1) -> (OmegaCompletePartialOrder.Chain.{u2} β _inst_2) -> (OmegaCompletePartialOrder.Chain.{max u2 u1} (Prod.{u1, u2} α β) (Prod.instPreorderProd.{u1, u2} α β _inst_1 _inst_2))
Case conversion may be inaccurate. Consider using '#align omega_complete_partial_order.chain.zip OmegaCompletePartialOrder.Chain.zipₓ'. -/
/-- `chain.zip` pairs up the elements of two chains that have the same index -/
@[simps]
def zip (c₀ : Chain α) (c₁ : Chain β) : Chain (α × β) :=
  OrderHom.prod c₀ c₁
#align omega_complete_partial_order.chain.zip OmegaCompletePartialOrder.Chain.zip

end Chain

end OmegaCompletePartialOrder

open OmegaCompletePartialOrder

section Prio

/- ./././Mathport/Syntax/Translate/Basic.lean:334:40: warning: unsupported option extends_priority -/
set_option extends_priority 50

#print OmegaCompletePartialOrder /-
/-- An omega-complete partial order is a partial order with a supremum
operation on increasing sequences indexed by natural numbers (which we
call `ωSup`). In this sense, it is strictly weaker than join complete
semi-lattices as only ω-sized totally ordered sets have a supremum.

See the definition on page 114 of [gunter1992]. -/
class OmegaCompletePartialOrder (α : Type _) extends PartialOrder α where
  ωSup : Chain α → α
  le_ωSup : ∀ c : Chain α, ∀ i, c i ≤ ωSup c
  ωSup_le : ∀ (c : Chain α) (x), (∀ i, c i ≤ x) → ωSup c ≤ x
#align omega_complete_partial_order OmegaCompletePartialOrder
-/

end Prio

namespace OmegaCompletePartialOrder

variable {α : Type u} {β : Type v} {γ : Type _}

variable [OmegaCompletePartialOrder α]

#print OmegaCompletePartialOrder.lift /-
/-- Transfer a `omega_complete_partial_order` on `β` to a `omega_complete_partial_order` on `α`
using a strictly monotone function `f : β →o α`, a definition of ωSup and a proof that `f` is
continuous with regard to the provided `ωSup` and the ωCPO on `α`. -/
@[reducible]
protected def lift [PartialOrder β] (f : β →o α) (ωSup₀ : Chain β → β)
    (h : ∀ x y, f x ≤ f y → x ≤ y) (h' : ∀ c, f (ωSup₀ c) = ωSup (c.map f)) :
    OmegaCompletePartialOrder β where
  ωSup := ωSup₀
  ωSup_le c x hx := h _ _ (by rw [h'] <;> apply ωSup_le <;> intro <;> apply f.monotone (hx i))
  le_ωSup c i := h _ _ (by rw [h'] <;> apply le_ωSup (c.map f))
#align omega_complete_partial_order.lift OmegaCompletePartialOrder.lift
-/

#print OmegaCompletePartialOrder.le_ωSup_of_le /-
theorem le_ωSup_of_le {c : Chain α} {x : α} (i : ℕ) (h : x ≤ c i) : x ≤ ωSup c :=
  le_trans h (le_ωSup c _)
#align omega_complete_partial_order.le_ωSup_of_le OmegaCompletePartialOrder.le_ωSup_of_le
-/

#print OmegaCompletePartialOrder.ωSup_total /-
theorem ωSup_total {c : Chain α} {x : α} (h : ∀ i, c i ≤ x ∨ x ≤ c i) : ωSup c ≤ x ∨ x ≤ ωSup c :=
  by_cases (fun this : ∀ i, c i ≤ x => Or.inl (ωSup_le _ _ this)) fun this : ¬∀ i, c i ≤ x =>
    have : ∃ i, ¬c i ≤ x := by simp only [not_forall] at this⊢ <;> assumption
    let ⟨i, hx⟩ := this
    have : x ≤ c i := (h i).resolve_left hx
    Or.inr <| le_ωSup_of_le _ this
#align omega_complete_partial_order.ωSup_total OmegaCompletePartialOrder.ωSup_total
-/

#print OmegaCompletePartialOrder.ωSup_le_ωSup_of_le /-
@[mono]
theorem ωSup_le_ωSup_of_le {c₀ c₁ : Chain α} (h : c₀ ≤ c₁) : ωSup c₀ ≤ ωSup c₁ :=
  ωSup_le _ _ fun i => Exists.rec_on (h i) fun j h => le_trans h (le_ωSup _ _)
#align omega_complete_partial_order.ωSup_le_ωSup_of_le OmegaCompletePartialOrder.ωSup_le_ωSup_of_le
-/

#print OmegaCompletePartialOrder.ωSup_le_iff /-
theorem ωSup_le_iff (c : Chain α) (x : α) : ωSup c ≤ x ↔ ∀ i, c i ≤ x :=
  by
  constructor <;> intros
  · trans ωSup c
    exact le_ωSup _ _
    assumption
  exact ωSup_le _ _ ‹_›
#align omega_complete_partial_order.ωSup_le_iff OmegaCompletePartialOrder.ωSup_le_iff
-/

#print OmegaCompletePartialOrder.subtype /-
/-- A subset `p : α → Prop` of the type closed under `ωSup` induces an
`omega_complete_partial_order` on the subtype `{a : α // p a}`. -/
def subtype {α : Type _} [OmegaCompletePartialOrder α] (p : α → Prop)
    (hp : ∀ c : Chain α, (∀ i ∈ c, p i) → p (ωSup c)) : OmegaCompletePartialOrder (Subtype p) :=
  OmegaCompletePartialOrder.lift (OrderHom.Subtype.val p)
    (fun c => ⟨ωSup _, hp (c.map (OrderHom.Subtype.val p)) fun i ⟨n, q⟩ => q.symm ▸ (c n).2⟩)
    (fun x y h => h) fun c => rfl
#align omega_complete_partial_order.subtype OmegaCompletePartialOrder.subtype
-/

section Continuity

open Chain

variable [OmegaCompletePartialOrder β]

variable [OmegaCompletePartialOrder γ]

#print OmegaCompletePartialOrder.Continuous /-
/-- A monotone function `f : α →o β` is continuous if it distributes over ωSup.

In order to distinguish it from the (more commonly used) continuity from topology
(see topology/basic.lean), the present definition is often referred to as
"Scott-continuity" (referring to Dana Scott). It corresponds to continuity
in Scott topological spaces (not defined here). -/
def Continuous (f : α →o β) : Prop :=
  ∀ c : Chain α, f (ωSup c) = ωSup (c.map f)
#align omega_complete_partial_order.continuous OmegaCompletePartialOrder.Continuous
-/

#print OmegaCompletePartialOrder.Continuous' /-
/-- `continuous' f` asserts that `f` is both monotone and continuous. -/
def Continuous' (f : α → β) : Prop :=
  ∃ hf : Monotone f, Continuous ⟨f, hf⟩
#align omega_complete_partial_order.continuous' OmegaCompletePartialOrder.Continuous'
-/

#print OmegaCompletePartialOrder.Continuous'.to_monotone /-
theorem Continuous'.to_monotone {f : α → β} (hf : Continuous' f) : Monotone f :=
  hf.fst
#align omega_complete_partial_order.continuous'.to_monotone OmegaCompletePartialOrder.Continuous'.to_monotone
-/

#print OmegaCompletePartialOrder.Continuous.of_bundled /-
theorem Continuous.of_bundled (f : α → β) (hf : Monotone f) (hf' : Continuous ⟨f, hf⟩) :
    Continuous' f :=
  ⟨hf, hf'⟩
#align omega_complete_partial_order.continuous.of_bundled OmegaCompletePartialOrder.Continuous.of_bundled
-/

#print OmegaCompletePartialOrder.Continuous.of_bundled' /-
theorem Continuous.of_bundled' (f : α →o β) (hf' : Continuous f) : Continuous' f :=
  ⟨f.mono, hf'⟩
#align omega_complete_partial_order.continuous.of_bundled' OmegaCompletePartialOrder.Continuous.of_bundled'
-/

#print OmegaCompletePartialOrder.Continuous'.to_bundled /-
theorem Continuous'.to_bundled (f : α → β) (hf : Continuous' f) : Continuous ⟨f, hf.to_monotone⟩ :=
  hf.snd
#align omega_complete_partial_order.continuous'.to_bundled OmegaCompletePartialOrder.Continuous'.to_bundled
-/

#print OmegaCompletePartialOrder.continuous'_coe /-
@[simp, norm_cast]
theorem continuous'_coe : ∀ {f : α →o β}, Continuous' f ↔ Continuous f
  | ⟨f, hf⟩ => ⟨fun ⟨hf', hc⟩ => hc, fun hc => ⟨hf, hc⟩⟩
#align omega_complete_partial_order.continuous'_coe OmegaCompletePartialOrder.continuous'_coe
-/

variable (f : α →o β) (g : β →o γ)

#print OmegaCompletePartialOrder.continuous_id /-
theorem continuous_id : Continuous (@OrderHom.id α _) := by intro <;> rw [c.map_id] <;> rfl
#align omega_complete_partial_order.continuous_id OmegaCompletePartialOrder.continuous_id
-/

/- warning: omega_complete_partial_order.continuous_comp -> OmegaCompletePartialOrder.continuous_comp is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : OmegaCompletePartialOrder.{u2} β] [_inst_3 : OmegaCompletePartialOrder.{u3} γ] (f : OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β _inst_2))) (g : OrderHom.{u2, u3} β γ (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β _inst_2)) (PartialOrder.toPreorder.{u3} γ (OmegaCompletePartialOrder.toPartialOrder.{u3} γ _inst_3))), (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 _inst_2 f) -> (OmegaCompletePartialOrder.Continuous.{u2, u3} β γ _inst_2 _inst_3 g) -> (OmegaCompletePartialOrder.Continuous.{u1, u3} α γ _inst_1 _inst_3 (OrderHom.comp.{u1, u2, u3} α β γ (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β _inst_2)) (PartialOrder.toPreorder.{u3} γ (OmegaCompletePartialOrder.toPartialOrder.{u3} γ _inst_3)) g f))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u3}} {γ : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u2} α] [_inst_2 : OmegaCompletePartialOrder.{u3} β] [_inst_3 : OmegaCompletePartialOrder.{u1} γ] (f : OrderHom.{u2, u3} α β (PartialOrder.toPreorder.{u2} α (OmegaCompletePartialOrder.toPartialOrder.{u2} α _inst_1)) (PartialOrder.toPreorder.{u3} β (OmegaCompletePartialOrder.toPartialOrder.{u3} β _inst_2))) (g : OrderHom.{u3, u1} β γ (PartialOrder.toPreorder.{u3} β (OmegaCompletePartialOrder.toPartialOrder.{u3} β _inst_2)) (PartialOrder.toPreorder.{u1} γ (OmegaCompletePartialOrder.toPartialOrder.{u1} γ _inst_3))), (OmegaCompletePartialOrder.Continuous.{u2, u3} α β _inst_1 _inst_2 f) -> (OmegaCompletePartialOrder.Continuous.{u3, u1} β γ _inst_2 _inst_3 g) -> (OmegaCompletePartialOrder.Continuous.{u2, u1} α γ _inst_1 _inst_3 (OrderHom.comp.{u2, u3, u1} α β γ (PartialOrder.toPreorder.{u2} α (OmegaCompletePartialOrder.toPartialOrder.{u2} α _inst_1)) (PartialOrder.toPreorder.{u3} β (OmegaCompletePartialOrder.toPartialOrder.{u3} β _inst_2)) (PartialOrder.toPreorder.{u1} γ (OmegaCompletePartialOrder.toPartialOrder.{u1} γ _inst_3)) g f))
Case conversion may be inaccurate. Consider using '#align omega_complete_partial_order.continuous_comp OmegaCompletePartialOrder.continuous_compₓ'. -/
theorem continuous_comp (hfc : Continuous f) (hgc : Continuous g) : Continuous (g.comp f) :=
  by
  dsimp [Continuous] at *; intro
  rw [hfc, hgc, chain.map_comp]
#align omega_complete_partial_order.continuous_comp OmegaCompletePartialOrder.continuous_comp

#print OmegaCompletePartialOrder.id_continuous' /-
theorem id_continuous' : Continuous' (@id α) :=
  continuous_id.of_bundled' _
#align omega_complete_partial_order.id_continuous' OmegaCompletePartialOrder.id_continuous'
-/

#print OmegaCompletePartialOrder.continuous_const /-
theorem continuous_const (x : β) : Continuous (OrderHom.const α x) := fun c =>
  eq_of_forall_ge_iff fun z => by simp [ωSup_le_iff]
#align omega_complete_partial_order.continuous_const OmegaCompletePartialOrder.continuous_const
-/

#print OmegaCompletePartialOrder.const_continuous' /-
theorem const_continuous' (x : β) : Continuous' (Function.const α x) :=
  Continuous.of_bundled' (OrderHom.const α x) (continuous_const x)
#align omega_complete_partial_order.const_continuous' OmegaCompletePartialOrder.const_continuous'
-/

end Continuity

end OmegaCompletePartialOrder

namespace Part

variable {α : Type u} {β : Type v} {γ : Type _}

open OmegaCompletePartialOrder

/- warning: part.eq_of_chain -> Part.eq_of_chain is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {c : OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))} {a : α} {b : α}, (Membership.Mem.{u1, u1} (Part.{u1} α) (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) (OmegaCompletePartialOrder.Chain.hasMem.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) (Part.some.{u1} α a) c) -> (Membership.Mem.{u1, u1} (Part.{u1} α) (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) (OmegaCompletePartialOrder.Chain.hasMem.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) (Part.some.{u1} α b) c) -> (Eq.{succ u1} α a b)
but is expected to have type
  forall {α : Type.{u1}} {c : OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))} {a : α} {b : α}, (Membership.mem.{u1, u1} (Part.{u1} α) (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) (OmegaCompletePartialOrder.Chain.instMembershipChain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) (Part.some.{u1} α a) c) -> (Membership.mem.{u1, u1} (Part.{u1} α) (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) (OmegaCompletePartialOrder.Chain.instMembershipChain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) (Part.some.{u1} α b) c) -> (Eq.{succ u1} α a b)
Case conversion may be inaccurate. Consider using '#align part.eq_of_chain Part.eq_of_chainₓ'. -/
theorem eq_of_chain {c : Chain (Part α)} {a b : α} (ha : some a ∈ c) (hb : some b ∈ c) : a = b :=
  by
  cases' ha with i ha; replace ha := ha.symm
  cases' hb with j hb; replace hb := hb.symm
  wlog h : i ≤ j; · exact (this j hb i ha (le_of_not_le h)).symm
  rw [eq_some_iff] at ha hb
  have := c.monotone h _ ha; apply mem_unique this hb
#align part.eq_of_chain Part.eq_of_chain

/- warning: part.ωSup -> Part.ωSup is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}}, (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) -> (Part.{u1} α)
but is expected to have type
  forall {α : Type.{u1}}, (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) -> (Part.{u1} α)
Case conversion may be inaccurate. Consider using '#align part.ωSup Part.ωSupₓ'. -/
/-- The (noncomputable) `ωSup` definition for the `ω`-CPO structure on `part α`. -/
protected noncomputable def ωSup (c : Chain (Part α)) : Part α :=
  if h : ∃ a, some a ∈ c then some (Classical.choose h) else none
#align part.ωSup Part.ωSup

/- warning: part.ωSup_eq_some -> Part.ωSup_eq_some is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {c : OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))} {a : α}, (Membership.Mem.{u1, u1} (Part.{u1} α) (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) (OmegaCompletePartialOrder.Chain.hasMem.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) (Part.some.{u1} α a) c) -> (Eq.{succ u1} (Part.{u1} α) (Part.ωSup.{u1} α c) (Part.some.{u1} α a))
but is expected to have type
  forall {α : Type.{u1}} {c : OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))} {a : α}, (Membership.mem.{u1, u1} (Part.{u1} α) (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) (OmegaCompletePartialOrder.Chain.instMembershipChain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) (Part.some.{u1} α a) c) -> (Eq.{succ u1} (Part.{u1} α) (Part.ωSup.{u1} α c) (Part.some.{u1} α a))
Case conversion may be inaccurate. Consider using '#align part.ωSup_eq_some Part.ωSup_eq_someₓ'. -/
theorem ωSup_eq_some {c : Chain (Part α)} {a : α} (h : some a ∈ c) : Part.ωSup c = some a :=
  have : ∃ a, some a ∈ c := ⟨a, h⟩
  have a' : some (Classical.choose this) ∈ c := Classical.choose_spec this
  calc
    Part.ωSup c = some (Classical.choose this) := dif_pos this
    _ = some a := congr_arg _ (eq_of_chain a' h)
    
#align part.ωSup_eq_some Part.ωSup_eq_some

/- warning: part.ωSup_eq_none -> Part.ωSup_eq_none is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {c : OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))}, (Not (Exists.{succ u1} α (fun (a : α) => Membership.Mem.{u1, u1} (Part.{u1} α) (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) (OmegaCompletePartialOrder.Chain.hasMem.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) (Part.some.{u1} α a) c))) -> (Eq.{succ u1} (Part.{u1} α) (Part.ωSup.{u1} α c) (Part.none.{u1} α))
but is expected to have type
  forall {α : Type.{u1}} {c : OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))}, (Not (Exists.{succ u1} α (fun (a : α) => Membership.mem.{u1, u1} (Part.{u1} α) (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) (OmegaCompletePartialOrder.Chain.instMembershipChain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) (Part.some.{u1} α a) c))) -> (Eq.{succ u1} (Part.{u1} α) (Part.ωSup.{u1} α c) (Part.none.{u1} α))
Case conversion may be inaccurate. Consider using '#align part.ωSup_eq_none Part.ωSup_eq_noneₓ'. -/
theorem ωSup_eq_none {c : Chain (Part α)} (h : ¬∃ a, some a ∈ c) : Part.ωSup c = none :=
  dif_neg h
#align part.ωSup_eq_none Part.ωSup_eq_none

/- warning: part.mem_chain_of_mem_ωSup -> Part.mem_chain_of_mem_ωSup is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {c : OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))} {a : α}, (Membership.Mem.{u1, u1} α (Part.{u1} α) (Part.hasMem.{u1} α) a (Part.ωSup.{u1} α c)) -> (Membership.Mem.{u1, u1} (Part.{u1} α) (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) (OmegaCompletePartialOrder.Chain.hasMem.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) (Part.some.{u1} α a) c)
but is expected to have type
  forall {α : Type.{u1}} {c : OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))} {a : α}, (Membership.mem.{u1, u1} α (Part.{u1} α) (Part.instMembershipPart.{u1} α) a (Part.ωSup.{u1} α c)) -> (Membership.mem.{u1, u1} (Part.{u1} α) (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) (OmegaCompletePartialOrder.Chain.instMembershipChain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) (Part.some.{u1} α a) c)
Case conversion may be inaccurate. Consider using '#align part.mem_chain_of_mem_ωSup Part.mem_chain_of_mem_ωSupₓ'. -/
theorem mem_chain_of_mem_ωSup {c : Chain (Part α)} {a : α} (h : a ∈ Part.ωSup c) : some a ∈ c :=
  by
  simp [Part.ωSup] at h; split_ifs  at h
  · have h' := Classical.choose_spec h_1
    rw [← eq_some_iff] at h
    rw [← h]
    exact h'
  · rcases h with ⟨⟨⟩⟩
#align part.mem_chain_of_mem_ωSup Part.mem_chain_of_mem_ωSup

#print Part.omegaCompletePartialOrder /-
noncomputable instance omegaCompletePartialOrder : OmegaCompletePartialOrder (Part α)
    where
  ωSup := Part.ωSup
  le_ωSup c i := by
    intro x hx
    rw [← eq_some_iff] at hx⊢
    rw [ωSup_eq_some, ← hx]
    rw [← hx]
    exact ⟨i, rfl⟩
  ωSup_le := by
    rintro c x hx a ha
    replace ha := mem_chain_of_mem_ωSup ha
    cases' ha with i ha
    apply hx i
    rw [← ha]
    apply mem_some
#align part.omega_complete_partial_order Part.omegaCompletePartialOrder
-/

section Inst

/- warning: part.mem_ωSup -> Part.mem_ωSup is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (x : α) (c : OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))), Iff (Membership.Mem.{u1, u1} α (Part.{u1} α) (Part.hasMem.{u1} α) x (OmegaCompletePartialOrder.ωSup.{u1} (Part.{u1} α) (Part.omegaCompletePartialOrder.{u1} α) c)) (Membership.Mem.{u1, u1} (Part.{u1} α) (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) (OmegaCompletePartialOrder.Chain.hasMem.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.partialOrder.{u1} α))) (Part.some.{u1} α x) c)
but is expected to have type
  forall {α : Type.{u1}} (x : α) (c : OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))), Iff (Membership.mem.{u1, u1} α (Part.{u1} α) (Part.instMembershipPart.{u1} α) x (OmegaCompletePartialOrder.ωSup.{u1} (Part.{u1} α) (Part.omegaCompletePartialOrder.{u1} α) c)) (Membership.mem.{u1, u1} (Part.{u1} α) (OmegaCompletePartialOrder.Chain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) (OmegaCompletePartialOrder.Chain.instMembershipChain.{u1} (Part.{u1} α) (PartialOrder.toPreorder.{u1} (Part.{u1} α) (Part.instPartialOrderPart.{u1} α))) (Part.some.{u1} α x) c)
Case conversion may be inaccurate. Consider using '#align part.mem_ωSup Part.mem_ωSupₓ'. -/
theorem mem_ωSup (x : α) (c : Chain (Part α)) : x ∈ ωSup c ↔ some x ∈ c :=
  by
  simp [OmegaCompletePartialOrder.ωSup, Part.ωSup]
  constructor
  · split_ifs
    swap
    rintro ⟨⟨⟩⟩
    intro h'
    have hh := Classical.choose_spec h
    simp at h'
    subst x
    exact hh
  · intro h
    have h' : ∃ a : α, some a ∈ c := ⟨_, h⟩
    rw [dif_pos h']
    have hh := Classical.choose_spec h'
    rw [eq_of_chain hh h]
    simp
#align part.mem_ωSup Part.mem_ωSup

end Inst

end Part

namespace Pi

variable {α : Type _} {β : α → Type _} {γ : Type _}

open OmegaCompletePartialOrder OmegaCompletePartialOrder.Chain

instance [∀ a, OmegaCompletePartialOrder (β a)] : OmegaCompletePartialOrder (∀ a, β a)
    where
  ωSup c a := ωSup (c.map (Pi.evalOrderHom a))
  ωSup_le c f hf a :=
    ωSup_le _ _ <| by
      rintro i
      apply hf
  le_ωSup c i x := le_ωSup_of_le _ <| le_rfl

namespace OmegaCompletePartialOrder

variable [∀ x, OmegaCompletePartialOrder <| β x]

variable [OmegaCompletePartialOrder γ]

/- warning: pi.omega_complete_partial_order.flip₁_continuous' -> Pi.OmegaCompletePartialOrder.flip₁_continuous' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : α -> Type.{u2}} {γ : Type.{u3}} [_inst_1 : forall (x : α), OmegaCompletePartialOrder.{u2} (β x)] [_inst_2 : OmegaCompletePartialOrder.{u3} γ] (f : forall (x : α), γ -> (β x)) (a : α), (OmegaCompletePartialOrder.Continuous'.{u3, max u1 u2} γ (forall (y : α), β y) _inst_2 (Pi.omegaCompletePartialOrder.{u1, u2} α (fun (y : α) => β y) (fun (a : α) => _inst_1 a)) (fun (x : γ) (y : α) => f y x)) -> (OmegaCompletePartialOrder.Continuous'.{u3, u2} γ (β a) _inst_2 (_inst_1 a) (f a))
but is expected to have type
  forall {α : Type.{u2}} {β : α -> Type.{u1}} {γ : Type.{u3}} [_inst_1 : forall (x : α), OmegaCompletePartialOrder.{u1} (β x)] [_inst_2 : OmegaCompletePartialOrder.{u3} γ] (f : forall (x : α), γ -> (β x)) (a : α), (OmegaCompletePartialOrder.Continuous'.{u3, max u2 u1} γ (forall (y : α), β y) _inst_2 (Pi.instOmegaCompletePartialOrderForAll.{u2, u1} α (fun (y : α) => β y) (fun (a : α) => _inst_1 a)) (fun (x : γ) (y : α) => f y x)) -> (OmegaCompletePartialOrder.Continuous'.{u3, u1} γ (β a) _inst_2 (_inst_1 a) (f a))
Case conversion may be inaccurate. Consider using '#align pi.omega_complete_partial_order.flip₁_continuous' Pi.OmegaCompletePartialOrder.flip₁_continuous'ₓ'. -/
theorem flip₁_continuous' (f : ∀ x : α, γ → β x) (a : α) (hf : Continuous' fun x y => f y x) :
    Continuous' (f a) :=
  Continuous.of_bundled _ (fun x y h => hf.to_monotone h a) fun c => congr_fun (hf.to_bundled _ c) a
#align pi.omega_complete_partial_order.flip₁_continuous' Pi.OmegaCompletePartialOrder.flip₁_continuous'

#print Pi.OmegaCompletePartialOrder.flip₂_continuous' /-
theorem flip₂_continuous' (f : γ → ∀ x, β x) (hf : ∀ x, Continuous' fun g => f g x) :
    Continuous' f :=
  Continuous.of_bundled _ (fun x y h a => (hf a).to_monotone h)
    (by intro c <;> ext a <;> apply (hf a).to_bundled _ c)
#align pi.omega_complete_partial_order.flip₂_continuous' Pi.OmegaCompletePartialOrder.flip₂_continuous'
-/

end OmegaCompletePartialOrder

end Pi

namespace Prod

open OmegaCompletePartialOrder

variable {α : Type _} {β : Type _} {γ : Type _}

variable [OmegaCompletePartialOrder α]

variable [OmegaCompletePartialOrder β]

variable [OmegaCompletePartialOrder γ]

/- warning: prod.ωSup -> Prod.ωSup is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : OmegaCompletePartialOrder.{u2} β], (OmegaCompletePartialOrder.Chain.{max u1 u2} (Prod.{u1, u2} α β) (Prod.preorder.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β _inst_2)))) -> (Prod.{u1, u2} α β)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : OmegaCompletePartialOrder.{u2} β], (OmegaCompletePartialOrder.Chain.{max u2 u1} (Prod.{u1, u2} α β) (Prod.instPreorderProd.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β _inst_2)))) -> (Prod.{u1, u2} α β)
Case conversion may be inaccurate. Consider using '#align prod.ωSup Prod.ωSupₓ'. -/
/-- The supremum of a chain in the product `ω`-CPO. -/
@[simps]
protected def ωSup (c : Chain (α × β)) : α × β :=
  (ωSup (c.map OrderHom.fst), ωSup (c.map OrderHom.snd))
#align prod.ωSup Prod.ωSup

@[simps ωSup_fst ωSup_snd]
instance : OmegaCompletePartialOrder (α × β)
    where
  ωSup := Prod.ωSup
  ωSup_le := fun c ⟨x, x'⟩ h => ⟨ωSup_le _ _ fun i => (h i).1, ωSup_le _ _ fun i => (h i).2⟩
  le_ωSup c i := ⟨le_ωSup (c.map OrderHom.fst) i, le_ωSup (c.map OrderHom.snd) i⟩

/- warning: prod.ωSup_zip -> Prod.ωSup_zip is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : OmegaCompletePartialOrder.{u2} β] (c₀ : OmegaCompletePartialOrder.Chain.{u1} α (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1))) (c₁ : OmegaCompletePartialOrder.Chain.{u2} β (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β _inst_2))), Eq.{succ (max u1 u2)} (Prod.{u1, u2} α β) (OmegaCompletePartialOrder.ωSup.{max u1 u2} (Prod.{u1, u2} α β) (Prod.omegaCompletePartialOrder.{u1, u2} α β _inst_1 _inst_2) (OmegaCompletePartialOrder.Chain.zip.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β _inst_2)) c₀ c₁)) (Prod.mk.{u1, u2} α β (OmegaCompletePartialOrder.ωSup.{u1} α _inst_1 c₀) (OmegaCompletePartialOrder.ωSup.{u2} β _inst_2 c₁))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u2} α] [_inst_2 : OmegaCompletePartialOrder.{u1} β] (c₀ : OmegaCompletePartialOrder.Chain.{u2} α (PartialOrder.toPreorder.{u2} α (OmegaCompletePartialOrder.toPartialOrder.{u2} α _inst_1))) (c₁ : OmegaCompletePartialOrder.Chain.{u1} β (PartialOrder.toPreorder.{u1} β (OmegaCompletePartialOrder.toPartialOrder.{u1} β _inst_2))), Eq.{max (succ u2) (succ u1)} (Prod.{u2, u1} α β) (OmegaCompletePartialOrder.ωSup.{max u2 u1} (Prod.{u2, u1} α β) (Prod.instOmegaCompletePartialOrderProd.{u2, u1} α β _inst_1 _inst_2) (OmegaCompletePartialOrder.Chain.zip.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (OmegaCompletePartialOrder.toPartialOrder.{u2} α _inst_1)) (PartialOrder.toPreorder.{u1} β (OmegaCompletePartialOrder.toPartialOrder.{u1} β _inst_2)) c₀ c₁)) (Prod.mk.{u2, u1} α β (OmegaCompletePartialOrder.ωSup.{u2} α _inst_1 c₀) (OmegaCompletePartialOrder.ωSup.{u1} β _inst_2 c₁))
Case conversion may be inaccurate. Consider using '#align prod.ωSup_zip Prod.ωSup_zipₓ'. -/
theorem ωSup_zip (c₀ : Chain α) (c₁ : Chain β) : ωSup (c₀.zip c₁) = (ωSup c₀, ωSup c₁) :=
  by
  apply eq_of_forall_ge_iff; rintro ⟨z₁, z₂⟩
  simp [ωSup_le_iff, forall_and]
#align prod.ωSup_zip Prod.ωSup_zip

end Prod

open OmegaCompletePartialOrder

namespace CompleteLattice

variable (α : Type u)

-- see Note [lower instance priority]
/-- Any complete lattice has an `ω`-CPO structure where the countable supremum is a special case
of arbitrary suprema. -/
instance (priority := 100) [CompleteLattice α] : OmegaCompletePartialOrder α
    where
  ωSup c := ⨆ i, c i
  ωSup_le := fun ⟨c, _⟩ s hs => by
    simp only [supᵢ_le_iff, OrderHom.coe_fun_mk] at hs⊢ <;> intro i <;> apply hs i
  le_ωSup := fun ⟨c, _⟩ i => by simp only [OrderHom.coe_fun_mk] <;> apply le_supᵢ_of_le i <;> rfl

variable {α} {β : Type v} [OmegaCompletePartialOrder α] [CompleteLattice β]

/- warning: complete_lattice.Sup_continuous -> CompleteLattice.supₛ_continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLattice.{u2} β] (s : Set.{max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β _inst_2))))), (forall (f : OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2)))), (Membership.Mem.{max u1 u2, max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2)))) (Set.{max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β _inst_2))))) (Set.hasMem.{max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β _inst_2))))) f s) -> (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2) f)) -> (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2) (SupSet.supₛ.{max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2)))) (OrderHom.hasSup.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) _inst_2) s))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLattice.{u2} β] (s : Set.{max u2 u1} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2))))), (forall (f : OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2)))), (Membership.mem.{max u1 u2, max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2)))) (Set.{max u2 u1} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2))))) (Set.instMembershipSet.{max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2))))) f s) -> (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2) f)) -> (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2) (SupSet.supₛ.{max u2 u1} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2)))) (OrderHom.instSupSetOrderHomToPreorderToPartialOrderToCompleteSemilatticeInf.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) _inst_2) s))
Case conversion may be inaccurate. Consider using '#align complete_lattice.Sup_continuous CompleteLattice.supₛ_continuousₓ'. -/
theorem supₛ_continuous (s : Set <| α →o β) (hs : ∀ f ∈ s, Continuous f) : Continuous (supₛ s) :=
  by
  intro c
  apply eq_of_forall_ge_iff
  intro z
  suffices (∀ f ∈ s, ∀ (n), (f : _) (c n) ≤ z) ↔ ∀ (n), ∀ f ∈ s, (f : _) (c n) ≤ z by
    simpa (config := { contextual := true }) [ωSup_le_iff, hs _ _ _]
  exact ⟨fun H n f hf => H f hf n, fun H f hf n => H n f hf⟩
#align complete_lattice.Sup_continuous CompleteLattice.supₛ_continuous

/- warning: complete_lattice.supr_continuous -> CompleteLattice.supᵢ_continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLattice.{u2} β] {ι : Sort.{u3}} {f : ι -> (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β _inst_2))))}, (forall (i : ι), OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2) (f i)) -> (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2) (supᵢ.{max u1 u2, u3} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2)))) (OrderHom.hasSup.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) _inst_2) ι (fun (i : ι) => f i)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u3}} [_inst_1 : OmegaCompletePartialOrder.{u2} α] [_inst_2 : CompleteLattice.{u3} β] {ι : Sort.{u1}} {f : ι -> (OrderHom.{u2, u3} α β (PartialOrder.toPreorder.{u2} α (OmegaCompletePartialOrder.toPartialOrder.{u2} α _inst_1)) (PartialOrder.toPreorder.{u3} β (OmegaCompletePartialOrder.toPartialOrder.{u3} β (CompleteLattice.instOmegaCompletePartialOrder.{u3} β _inst_2))))}, (forall (i : ι), OmegaCompletePartialOrder.Continuous.{u2, u3} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u3} β _inst_2) (f i)) -> (OmegaCompletePartialOrder.Continuous.{u2, u3} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u3} β _inst_2) (supᵢ.{max u3 u2, u1} (OrderHom.{u2, u3} α β (PartialOrder.toPreorder.{u2} α (OmegaCompletePartialOrder.toPartialOrder.{u2} α _inst_1)) (PartialOrder.toPreorder.{u3} β (OmegaCompletePartialOrder.toPartialOrder.{u3} β (CompleteLattice.instOmegaCompletePartialOrder.{u3} β _inst_2)))) (OrderHom.instSupSetOrderHomToPreorderToPartialOrderToCompleteSemilatticeInf.{u2, u3} α β (PartialOrder.toPreorder.{u2} α (OmegaCompletePartialOrder.toPartialOrder.{u2} α _inst_1)) _inst_2) ι (fun (i : ι) => f i)))
Case conversion may be inaccurate. Consider using '#align complete_lattice.supr_continuous CompleteLattice.supᵢ_continuousₓ'. -/
theorem supᵢ_continuous {ι : Sort _} {f : ι → α →o β} (h : ∀ i, Continuous (f i)) :
    Continuous (⨆ i, f i) :=
  supₛ_continuous _ <| Set.forall_range_iff.2 h
#align complete_lattice.supr_continuous CompleteLattice.supᵢ_continuous

/- warning: complete_lattice.Sup_continuous' -> CompleteLattice.supₛ_continuous' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLattice.{u2} β] (s : Set.{max u1 u2} (α -> β)), (forall (f : α -> β), (Membership.Mem.{max u1 u2, max u1 u2} (α -> β) (Set.{max u1 u2} (α -> β)) (Set.hasMem.{max u1 u2} (α -> β)) f s) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2) f)) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2) (SupSet.supₛ.{max u1 u2} (α -> β) (Pi.supSet.{u1, u2} α (fun (ᾰ : α) => β) (fun (i : α) => CompleteSemilatticeSup.toHasSup.{u2} β (CompleteLattice.toCompleteSemilatticeSup.{u2} β _inst_2))) s))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLattice.{u2} β] (s : Set.{max u1 u2} (α -> β)), (forall (f : α -> β), (Membership.mem.{max u1 u2, max u1 u2} (α -> β) (Set.{max u1 u2} (α -> β)) (Set.instMembershipSet.{max u1 u2} (α -> β)) f s) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2) f)) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2) (SupSet.supₛ.{max u2 u1} (α -> β) (Pi.supSet.{u1, u2} α (fun (ᾰ : α) => β) (fun (i : α) => CompleteLattice.toSupSet.{u2} β _inst_2)) s))
Case conversion may be inaccurate. Consider using '#align complete_lattice.Sup_continuous' CompleteLattice.supₛ_continuous'ₓ'. -/
theorem supₛ_continuous' (s : Set (α → β)) (hc : ∀ f ∈ s, Continuous' f) : Continuous' (supₛ s) :=
  by
  lift s to Set (α →o β) using fun f hf => (hc f hf).to_monotone
  simp only [Set.ball_image_iff, continuous'_coe] at hc
  rw [supₛ_image]
  norm_cast
  exact supr_continuous fun f => supr_continuous fun hf => hc f hf
#align complete_lattice.Sup_continuous' CompleteLattice.supₛ_continuous'

/- warning: complete_lattice.sup_continuous -> CompleteLattice.sup_continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLattice.{u2} β] {f : OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β _inst_2)))} {g : OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β _inst_2)))}, (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2) f) -> (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2) g) -> (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2) (HasSup.sup.{max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2)))) (OrderHom.hasSup.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (Lattice.toSemilatticeSup.{u2} β (CompleteLattice.toLattice.{u2} β _inst_2))) f g))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLattice.{u2} β] {f : OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2)))} {g : OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2)))}, (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2) f) -> (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2) g) -> (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2) (HasSup.sup.{max u2 u1} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2)))) (OrderHom.instHasSupOrderHomToPreorderToPartialOrder.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (Lattice.toSemilatticeSup.{u2} β (CompleteLattice.toLattice.{u2} β _inst_2))) f g))
Case conversion may be inaccurate. Consider using '#align complete_lattice.sup_continuous CompleteLattice.sup_continuousₓ'. -/
theorem sup_continuous {f g : α →o β} (hf : Continuous f) (hg : Continuous g) :
    Continuous (f ⊔ g) := by
  rw [← supₛ_pair]; apply Sup_continuous
  rintro f (rfl | rfl | _) <;> assumption
#align complete_lattice.sup_continuous CompleteLattice.sup_continuous

/- warning: complete_lattice.top_continuous -> CompleteLattice.top_continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLattice.{u2} β], OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2) (Top.top.{max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β _inst_2)))) (OrderHom.hasTop.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β _inst_2))) (BoundedOrder.toOrderTop.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β _inst_2)))) (CompleteLattice.toBoundedOrder.{u2} β _inst_2))))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLattice.{u2} β], OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2) (Top.top.{max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2)))) (OrderHom.instTopOrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2))) (BoundedOrder.toOrderTop.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2)))) (CompleteLattice.toBoundedOrder.{u2} β _inst_2))))
Case conversion may be inaccurate. Consider using '#align complete_lattice.top_continuous CompleteLattice.top_continuousₓ'. -/
theorem top_continuous : Continuous (⊤ : α →o β) :=
  by
  intro c; apply eq_of_forall_ge_iff; intro z
  simp only [ωSup_le_iff, forall_const, chain.map_coe, (· ∘ ·), Function.const, OrderHom.hasTop_top,
    OrderHom.const_coe_coe]
#align complete_lattice.top_continuous CompleteLattice.top_continuous

/- warning: complete_lattice.bot_continuous -> CompleteLattice.bot_continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLattice.{u2} β], OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β _inst_2) (Bot.bot.{max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β _inst_2)))) (OrderHom.hasBot.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β _inst_2))) (BoundedOrder.toOrderBot.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β _inst_2)))) (CompleteLattice.toBoundedOrder.{u2} β _inst_2))))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLattice.{u2} β], OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2) (Bot.bot.{max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2)))) (OrderHom.instBotOrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2))) (BoundedOrder.toOrderBot.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.instOmegaCompletePartialOrder.{u2} β _inst_2)))) (CompleteLattice.toBoundedOrder.{u2} β _inst_2))))
Case conversion may be inaccurate. Consider using '#align complete_lattice.bot_continuous CompleteLattice.bot_continuousₓ'. -/
theorem bot_continuous : Continuous (⊥ : α →o β) :=
  by
  rw [← supₛ_empty]
  exact Sup_continuous _ fun f hf => hf.elim
#align complete_lattice.bot_continuous CompleteLattice.bot_continuous

end CompleteLattice

namespace CompleteLattice

variable {α β : Type _} [OmegaCompletePartialOrder α] [CompleteLinearOrder β]

/- warning: complete_lattice.inf_continuous -> CompleteLattice.inf_continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLinearOrder.{u2} β] (f : OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β (CompleteLinearOrder.toCompleteLattice.{u2} β _inst_2))))) (g : OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (CompleteSemilatticeInf.toPartialOrder.{u2} β (CompleteLattice.toCompleteSemilatticeInf.{u2} β (CompleteLinearOrder.toCompleteLattice.{u2} β _inst_2))))), (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β (CompleteLinearOrder.toCompleteLattice.{u2} β _inst_2)) f) -> (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β (CompleteLinearOrder.toCompleteLattice.{u2} β _inst_2)) g) -> (OmegaCompletePartialOrder.Continuous.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β (CompleteLinearOrder.toCompleteLattice.{u2} β _inst_2)) (HasInf.inf.{max u1 u2} (OrderHom.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β (CompleteLattice.omegaCompletePartialOrder.{u2} β (CompleteLinearOrder.toCompleteLattice.{u2} β _inst_2))))) (OrderHom.hasInf.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (Lattice.toSemilatticeInf.{u2} β (CompleteLattice.toLattice.{u2} β (CompleteLinearOrder.toCompleteLattice.{u2} β _inst_2)))) f g))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u2} α] [_inst_2 : CompleteLinearOrder.{u1} β] (f : OrderHom.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (OmegaCompletePartialOrder.toPartialOrder.{u2} α _inst_1)) (PartialOrder.toPreorder.{u1} β (OmegaCompletePartialOrder.toPartialOrder.{u1} β (CompleteLattice.instOmegaCompletePartialOrder.{u1} β (CompleteLinearOrder.toCompleteLattice.{u1} β _inst_2))))) (g : OrderHom.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (OmegaCompletePartialOrder.toPartialOrder.{u2} α _inst_1)) (PartialOrder.toPreorder.{u1} β (OmegaCompletePartialOrder.toPartialOrder.{u1} β (CompleteLattice.instOmegaCompletePartialOrder.{u1} β (CompleteLinearOrder.toCompleteLattice.{u1} β _inst_2))))), (OmegaCompletePartialOrder.Continuous.{u2, u1} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u1} β (CompleteLinearOrder.toCompleteLattice.{u1} β _inst_2)) f) -> (OmegaCompletePartialOrder.Continuous.{u2, u1} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u1} β (CompleteLinearOrder.toCompleteLattice.{u1} β _inst_2)) g) -> (OmegaCompletePartialOrder.Continuous.{u2, u1} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u1} β (CompleteLinearOrder.toCompleteLattice.{u1} β _inst_2)) (HasInf.inf.{max u1 u2} (OrderHom.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (OmegaCompletePartialOrder.toPartialOrder.{u2} α _inst_1)) (PartialOrder.toPreorder.{u1} β (OmegaCompletePartialOrder.toPartialOrder.{u1} β (CompleteLattice.instOmegaCompletePartialOrder.{u1} β (CompleteLinearOrder.toCompleteLattice.{u1} β _inst_2))))) (OrderHom.instHasInfOrderHomToPreorderToPartialOrder.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (OmegaCompletePartialOrder.toPartialOrder.{u2} α _inst_1)) (Lattice.toSemilatticeInf.{u1} β (CompleteLattice.toLattice.{u1} β (CompleteLinearOrder.toCompleteLattice.{u1} β _inst_2)))) f g))
Case conversion may be inaccurate. Consider using '#align complete_lattice.inf_continuous CompleteLattice.inf_continuousₓ'. -/
theorem inf_continuous (f g : α →o β) (hf : Continuous f) (hg : Continuous g) :
    Continuous (f ⊓ g) := by
  refine' fun c => eq_of_forall_ge_iff fun z => _
  simp only [inf_le_iff, hf c, hg c, ωSup_le_iff, ← forall_or_left, ← forall_or_right,
    Function.comp_apply, chain.map_coe, OrderHom.hasInf_inf_coe]
  exact
    ⟨fun h _ => h _ _, fun h i j =>
      (h (max i j)).imp (le_trans <| f.mono <| c.mono <| le_max_left _ _)
        (le_trans <| g.mono <| c.mono <| le_max_right _ _)⟩
#align complete_lattice.inf_continuous CompleteLattice.inf_continuous

/- warning: complete_lattice.inf_continuous' -> CompleteLattice.inf_continuous' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : CompleteLinearOrder.{u2} β] {f : α -> β} {g : α -> β}, (OmegaCompletePartialOrder.Continuous'.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β (CompleteLinearOrder.toCompleteLattice.{u2} β _inst_2)) f) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β (CompleteLinearOrder.toCompleteLattice.{u2} β _inst_2)) g) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α β _inst_1 (CompleteLattice.omegaCompletePartialOrder.{u2} β (CompleteLinearOrder.toCompleteLattice.{u2} β _inst_2)) (HasInf.inf.{max u1 u2} (α -> β) (Pi.hasInf.{u1, u2} α (fun (ᾰ : α) => β) (fun (i : α) => SemilatticeInf.toHasInf.{u2} β (Lattice.toSemilatticeInf.{u2} β (CompleteLattice.toLattice.{u2} β (CompleteLinearOrder.toCompleteLattice.{u2} β _inst_2))))) f g))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u2} α] [_inst_2 : CompleteLinearOrder.{u1} β] {f : α -> β} {g : α -> β}, (OmegaCompletePartialOrder.Continuous'.{u2, u1} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u1} β (CompleteLinearOrder.toCompleteLattice.{u1} β _inst_2)) f) -> (OmegaCompletePartialOrder.Continuous'.{u2, u1} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u1} β (CompleteLinearOrder.toCompleteLattice.{u1} β _inst_2)) g) -> (OmegaCompletePartialOrder.Continuous'.{u2, u1} α β _inst_1 (CompleteLattice.instOmegaCompletePartialOrder.{u1} β (CompleteLinearOrder.toCompleteLattice.{u1} β _inst_2)) (HasInf.inf.{max u1 u2} (α -> β) (Pi.instHasInfForAll.{u2, u1} α (fun (ᾰ : α) => β) (fun (i : α) => Lattice.toHasInf.{u1} β (CompleteLattice.toLattice.{u1} β (CompleteLinearOrder.toCompleteLattice.{u1} β _inst_2)))) f g))
Case conversion may be inaccurate. Consider using '#align complete_lattice.inf_continuous' CompleteLattice.inf_continuous'ₓ'. -/
theorem inf_continuous' {f g : α → β} (hf : Continuous' f) (hg : Continuous' g) :
    Continuous' (f ⊓ g) :=
  ⟨_, inf_continuous _ _ hf.snd hg.snd⟩
#align complete_lattice.inf_continuous' CompleteLattice.inf_continuous'

end CompleteLattice

namespace OmegaCompletePartialOrder

variable {α : Type u} {α' : Type _} {β : Type v} {β' : Type _} {γ : Type _} {φ : Type _}

variable [OmegaCompletePartialOrder α] [OmegaCompletePartialOrder β]

variable [OmegaCompletePartialOrder γ] [OmegaCompletePartialOrder φ]

variable [OmegaCompletePartialOrder α'] [OmegaCompletePartialOrder β']

namespace OrderHom

#print OmegaCompletePartialOrder.OrderHom.ωSup /-
/-- The `ωSup` operator for monotone functions. -/
@[simps]
protected def ωSup (c : Chain (α →o β)) : α →o β
    where
  toFun a := ωSup (c.map (OrderHom.apply a))
  monotone' x y h := ωSup_le_ωSup_of_le (Chain.map_le_map _ fun a => a.Monotone h)
#align omega_complete_partial_order.order_hom.ωSup OmegaCompletePartialOrder.OrderHom.ωSup
-/

#print OmegaCompletePartialOrder.OrderHom.omegaCompletePartialOrder /-
@[simps ωSup_coe]
instance omegaCompletePartialOrder : OmegaCompletePartialOrder (α →o β) :=
  OmegaCompletePartialOrder.lift OrderHom.coeFnHom OrderHom.ωSup (fun x y h => h) fun c => rfl
#align omega_complete_partial_order.order_hom.omega_complete_partial_order OmegaCompletePartialOrder.OrderHom.omegaCompletePartialOrder
-/

end OrderHom

section

variable (α β)

#print OmegaCompletePartialOrder.ContinuousHom /-
/-- A monotone function on `ω`-continuous partial orders is said to be continuous
if for every chain `c : chain α`, `f (⊔ i, c i) = ⊔ i, f (c i)`.
This is just the bundled version of `order_hom.continuous`. -/
structure ContinuousHom extends OrderHom α β where
  cont : Continuous (OrderHom.mk to_fun monotone')
#align omega_complete_partial_order.continuous_hom OmegaCompletePartialOrder.ContinuousHom
-/

attribute [nolint doc_blame] continuous_hom.to_order_hom

-- mathport name: «expr →𝒄 »
infixr:25 " →𝒄 " => ContinuousHom

-- Input: \r\MIc
instance : CoeFun (α →𝒄 β) fun _ => α → β :=
  ⟨fun f => f.toOrderHom.toFun⟩

instance : Coe (α →𝒄 β) (α →o β) where coe := ContinuousHom.toOrderHom

instance : PartialOrder (α →𝒄 β) :=
  (PartialOrder.lift fun f => f.toOrderHom.toFun) <| by rintro ⟨⟨⟩⟩ ⟨⟨⟩⟩ h <;> congr <;> exact h

#print OmegaCompletePartialOrder.ContinuousHom.Simps.apply /-
/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
  because it is a composition of multiple projections. -/
def ContinuousHom.Simps.apply (h : α →𝒄 β) : α → β :=
  h
#align omega_complete_partial_order.continuous_hom.simps.apply OmegaCompletePartialOrder.ContinuousHom.Simps.apply
-/

initialize_simps_projections ContinuousHom (to_order_hom_to_fun → apply, -toOrderHom)

end

namespace ContinuousHom

#print OmegaCompletePartialOrder.ContinuousHom.congr_fun /-
theorem congr_fun {f g : α →𝒄 β} (h : f = g) (x : α) : f x = g x :=
  congr_arg (fun h : α →𝒄 β => h x) h
#align omega_complete_partial_order.continuous_hom.congr_fun OmegaCompletePartialOrder.ContinuousHom.congr_fun
-/

#print OmegaCompletePartialOrder.ContinuousHom.congr_arg /-
theorem congr_arg (f : α →𝒄 β) {x y : α} (h : x = y) : f x = f y :=
  congr_arg (fun x : α => f x) h
#align omega_complete_partial_order.continuous_hom.congr_arg OmegaCompletePartialOrder.ContinuousHom.congr_arg
-/

#print OmegaCompletePartialOrder.ContinuousHom.monotone /-
protected theorem monotone (f : α →𝒄 β) : Monotone f :=
  f.monotone'
#align omega_complete_partial_order.continuous_hom.monotone OmegaCompletePartialOrder.ContinuousHom.monotone
-/

#print OmegaCompletePartialOrder.ContinuousHom.apply_mono /-
@[mono]
theorem apply_mono {f g : α →𝒄 β} {x y : α} (h₁ : f ≤ g) (h₂ : x ≤ y) : f x ≤ g y :=
  OrderHom.apply_mono (show (f : α →o β) ≤ g from h₁) h₂
#align omega_complete_partial_order.continuous_hom.apply_mono OmegaCompletePartialOrder.ContinuousHom.apply_mono
-/

#print OmegaCompletePartialOrder.ContinuousHom.ite_continuous' /-
theorem ite_continuous' {p : Prop} [hp : Decidable p] (f g : α → β) (hf : Continuous' f)
    (hg : Continuous' g) : Continuous' fun x => if p then f x else g x := by split_ifs <;> simp [*]
#align omega_complete_partial_order.continuous_hom.ite_continuous' OmegaCompletePartialOrder.ContinuousHom.ite_continuous'
-/

/- warning: omega_complete_partial_order.continuous_hom.ωSup_bind -> OmegaCompletePartialOrder.ContinuousHom.ωSup_bind is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] {β : Type.{u2}} {γ : Type.{u2}} (c : OmegaCompletePartialOrder.Chain.{u1} α (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1))) (f : OrderHom.{u1, u2} α (Part.{u2} β) (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} (Part.{u2} β) (Part.partialOrder.{u2} β))) (g : OrderHom.{u1, u2} α (β -> (Part.{u2} γ)) (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (Pi.preorder.{u2, u2} β (fun (ᾰ : β) => Part.{u2} γ) (fun (i : β) => PartialOrder.toPreorder.{u2} (Part.{u2} γ) (Part.partialOrder.{u2} γ)))), Eq.{succ u2} (Part.{u2} γ) (OmegaCompletePartialOrder.ωSup.{u2} (Part.{u2} γ) (Part.omegaCompletePartialOrder.{u2} γ) (OmegaCompletePartialOrder.Chain.map.{u1, u2} α (Part.{u2} γ) (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} (Part.{u2} γ) (OmegaCompletePartialOrder.toPartialOrder.{u2} (Part.{u2} γ) (Part.omegaCompletePartialOrder.{u2} γ))) c (OrderHom.bind.{u1, u2} α (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) β γ f g))) (Bind.bind.{u2, u2} Part.{u2} (Monad.toHasBind.{u2, u2} Part.{u2} Part.monad.{u2}) β γ (OmegaCompletePartialOrder.ωSup.{u2} (Part.{u2} β) (Part.omegaCompletePartialOrder.{u2} β) (OmegaCompletePartialOrder.Chain.map.{u1, u2} α (Part.{u2} β) (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} (Part.{u2} β) (OmegaCompletePartialOrder.toPartialOrder.{u2} (Part.{u2} β) (Part.omegaCompletePartialOrder.{u2} β))) c f)) (OmegaCompletePartialOrder.ωSup.{u2} (β -> (Part.{u2} γ)) (Pi.omegaCompletePartialOrder.{u2, u2} β (fun (ᾰ : β) => Part.{u2} γ) (fun (a : β) => Part.omegaCompletePartialOrder.{u2} γ)) (OmegaCompletePartialOrder.Chain.map.{u1, u2} α (β -> (Part.{u2} γ)) (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} (β -> (Part.{u2} γ)) (OmegaCompletePartialOrder.toPartialOrder.{u2} (β -> (Part.{u2} γ)) (Pi.omegaCompletePartialOrder.{u2, u2} β (fun (ᾰ : β) => Part.{u2} γ) (fun (a : β) => Part.omegaCompletePartialOrder.{u2} γ)))) c g)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] {β : Type.{u2}} {γ : Type.{u2}} (c : OmegaCompletePartialOrder.Chain.{u1} α (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1))) (f : OrderHom.{u1, u2} α (Part.{u2} β) (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} (Part.{u2} β) (Part.instPartialOrderPart.{u2} β))) (g : OrderHom.{u1, u2} α (β -> (Part.{u2} γ)) (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (Pi.preorder.{u2, u2} β (fun (ᾰ : β) => Part.{u2} γ) (fun (i : β) => PartialOrder.toPreorder.{u2} (Part.{u2} γ) (Part.instPartialOrderPart.{u2} γ)))), Eq.{succ u2} (Part.{u2} γ) (OmegaCompletePartialOrder.ωSup.{u2} (Part.{u2} γ) (Part.omegaCompletePartialOrder.{u2} γ) (OmegaCompletePartialOrder.Chain.map.{u1, u2} α (Part.{u2} γ) (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} (Part.{u2} γ) (OmegaCompletePartialOrder.toPartialOrder.{u2} (Part.{u2} γ) (Part.omegaCompletePartialOrder.{u2} γ))) c (OrderHom.bind.{u1, u2} α (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) β γ f g))) (Bind.bind.{u2, u2} Part.{u2} (Monad.toBind.{u2, u2} Part.{u2} Part.instMonadPart.{u2}) β γ (OmegaCompletePartialOrder.ωSup.{u2} (Part.{u2} β) (Part.omegaCompletePartialOrder.{u2} β) (OmegaCompletePartialOrder.Chain.map.{u1, u2} α (Part.{u2} β) (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} (Part.{u2} β) (OmegaCompletePartialOrder.toPartialOrder.{u2} (Part.{u2} β) (Part.omegaCompletePartialOrder.{u2} β))) c f)) (OmegaCompletePartialOrder.ωSup.{u2} (β -> (Part.{u2} γ)) (Pi.instOmegaCompletePartialOrderForAll.{u2, u2} β (fun (ᾰ : β) => Part.{u2} γ) (fun (a : β) => Part.omegaCompletePartialOrder.{u2} γ)) (OmegaCompletePartialOrder.Chain.map.{u1, u2} α (β -> (Part.{u2} γ)) (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} (β -> (Part.{u2} γ)) (OmegaCompletePartialOrder.toPartialOrder.{u2} (β -> (Part.{u2} γ)) (Pi.instOmegaCompletePartialOrderForAll.{u2, u2} β (fun (ᾰ : β) => Part.{u2} γ) (fun (a : β) => Part.omegaCompletePartialOrder.{u2} γ)))) c g)))
Case conversion may be inaccurate. Consider using '#align omega_complete_partial_order.continuous_hom.ωSup_bind OmegaCompletePartialOrder.ContinuousHom.ωSup_bindₓ'. -/
theorem ωSup_bind {β γ : Type v} (c : Chain α) (f : α →o Part β) (g : α →o β → Part γ) :
    ωSup (c.map (f.bind g)) = ωSup (c.map f) >>= ωSup (c.map g) :=
  by
  apply eq_of_forall_ge_iff; intro x
  simp only [ωSup_le_iff, Part.bind_le, chain.mem_map_iff, and_imp, OrderHom.bind_coe, exists_imp]
  constructor <;> intro h'''
  · intro b hb
    apply ωSup_le _ _ _
    rintro i y hy
    simp only [Part.mem_ωSup] at hb
    rcases hb with ⟨j, hb⟩
    replace hb := hb.symm
    simp only [Part.eq_some_iff, chain.map_coe, Function.comp_apply, OrderHom.apply_coe] at hy hb
    replace hb : b ∈ f (c (max i j)) := f.mono (c.mono (le_max_right i j)) _ hb
    replace hy : y ∈ g (c (max i j)) b := g.mono (c.mono (le_max_left i j)) _ _ hy
    apply h''' (max i j)
    simp only [exists_prop, Part.bind_eq_bind, Part.mem_bind_iff, chain.map_coe,
      Function.comp_apply, OrderHom.bind_coe]
    exact ⟨_, hb, hy⟩
  · intro i
    intro y hy
    simp only [exists_prop, Part.bind_eq_bind, Part.mem_bind_iff, chain.map_coe,
      Function.comp_apply, OrderHom.bind_coe] at hy
    rcases hy with ⟨b, hb₀, hb₁⟩
    apply h''' b _
    · apply le_ωSup (c.map g) _ _ _ hb₁
    · apply le_ωSup (c.map f) i _ hb₀
#align omega_complete_partial_order.continuous_hom.ωSup_bind OmegaCompletePartialOrder.ContinuousHom.ωSup_bind

/- warning: omega_complete_partial_order.continuous_hom.bind_continuous' -> OmegaCompletePartialOrder.ContinuousHom.bind_continuous' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] {β : Type.{u2}} {γ : Type.{u2}} (f : α -> (Part.{u2} β)) (g : α -> β -> (Part.{u2} γ)), (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} β) _inst_1 (Part.omegaCompletePartialOrder.{u2} β) f) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (β -> (Part.{u2} γ)) _inst_1 (Pi.omegaCompletePartialOrder.{u2, u2} β (fun (ᾰ : β) => Part.{u2} γ) (fun (a : β) => Part.omegaCompletePartialOrder.{u2} γ)) g) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} γ) _inst_1 (Part.omegaCompletePartialOrder.{u2} γ) (fun (x : α) => Bind.bind.{u2, u2} Part.{u2} (Monad.toHasBind.{u2, u2} Part.{u2} Part.monad.{u2}) β γ (f x) (g x)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] {β : Type.{u2}} {γ : Type.{u2}} (f : α -> (Part.{u2} β)) (g : α -> β -> (Part.{u2} γ)), (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} β) _inst_1 (Part.omegaCompletePartialOrder.{u2} β) f) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (β -> (Part.{u2} γ)) _inst_1 (Pi.instOmegaCompletePartialOrderForAll.{u2, u2} β (fun (ᾰ : β) => Part.{u2} γ) (fun (a : β) => Part.omegaCompletePartialOrder.{u2} γ)) g) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} γ) _inst_1 (Part.omegaCompletePartialOrder.{u2} γ) (fun (x : α) => Bind.bind.{u2, u2} Part.{u2} (Monad.toBind.{u2, u2} Part.{u2} Part.instMonadPart.{u2}) β γ (f x) (g x)))
Case conversion may be inaccurate. Consider using '#align omega_complete_partial_order.continuous_hom.bind_continuous' OmegaCompletePartialOrder.ContinuousHom.bind_continuous'ₓ'. -/
theorem bind_continuous' {β γ : Type v} (f : α → Part β) (g : α → β → Part γ) :
    Continuous' f → Continuous' g → Continuous' fun x => f x >>= g x
  | ⟨hf, hf'⟩, ⟨hg, hg'⟩ =>
    Continuous.of_bundled' (OrderHom.bind ⟨f, hf⟩ ⟨g, hg⟩)
      (by intro c <;> rw [ωSup_bind, ← hf', ← hg'] <;> rfl)
#align omega_complete_partial_order.continuous_hom.bind_continuous' OmegaCompletePartialOrder.ContinuousHom.bind_continuous'

/- warning: omega_complete_partial_order.continuous_hom.map_continuous' -> OmegaCompletePartialOrder.ContinuousHom.map_continuous' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] {β : Type.{u2}} {γ : Type.{u2}} (f : β -> γ) (g : α -> (Part.{u2} β)), (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} β) _inst_1 (Part.omegaCompletePartialOrder.{u2} β) g) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} γ) _inst_1 (Part.omegaCompletePartialOrder.{u2} γ) (fun (x : α) => Functor.map.{u2, u2} (fun {β : Type.{u2}} => Part.{u2} β) (Applicative.toFunctor.{u2, u2} (fun {β : Type.{u2}} => Part.{u2} β) (Monad.toApplicative.{u2, u2} (fun {β : Type.{u2}} => Part.{u2} β) Part.monad.{u2})) β γ f (g x)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] {β : Type.{u2}} {γ : Type.{u2}} (f : β -> γ) (g : α -> (Part.{u2} β)), (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} β) _inst_1 (Part.omegaCompletePartialOrder.{u2} β) g) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} γ) _inst_1 (Part.omegaCompletePartialOrder.{u2} γ) (fun (x : α) => Functor.map.{u2, u2} Part.{u2} (Applicative.toFunctor.{u2, u2} Part.{u2} (Monad.toApplicative.{u2, u2} Part.{u2} Part.instMonadPart.{u2})) β γ f (g x)))
Case conversion may be inaccurate. Consider using '#align omega_complete_partial_order.continuous_hom.map_continuous' OmegaCompletePartialOrder.ContinuousHom.map_continuous'ₓ'. -/
theorem map_continuous' {β γ : Type v} (f : β → γ) (g : α → Part β) (hg : Continuous' g) :
    Continuous' fun x => f <$> g x := by
  simp only [map_eq_bind_pure_comp] <;> apply bind_continuous' _ _ hg <;> apply const_continuous'
#align omega_complete_partial_order.continuous_hom.map_continuous' OmegaCompletePartialOrder.ContinuousHom.map_continuous'

/- warning: omega_complete_partial_order.continuous_hom.seq_continuous' -> OmegaCompletePartialOrder.ContinuousHom.seq_continuous' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] {β : Type.{u2}} {γ : Type.{u2}} (f : α -> (Part.{u2} (β -> γ))) (g : α -> (Part.{u2} β)), (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} (β -> γ)) _inst_1 (Part.omegaCompletePartialOrder.{u2} (β -> γ)) f) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} β) _inst_1 (Part.omegaCompletePartialOrder.{u2} β) g) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} γ) _inst_1 (Part.omegaCompletePartialOrder.{u2} γ) (fun (x : α) => Seq.seq.{u2, u2} Part.{u2} (Applicative.toHasSeq.{u2, u2} Part.{u2} (Monad.toApplicative.{u2, u2} Part.{u2} Part.monad.{u2})) β γ (f x) (g x)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] {β : Type.{u2}} {γ : Type.{u2}} (f : α -> (Part.{u2} (β -> γ))) (g : α -> (Part.{u2} β)), (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} (β -> γ)) _inst_1 (Part.omegaCompletePartialOrder.{u2} (β -> γ)) f) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} β) _inst_1 (Part.omegaCompletePartialOrder.{u2} β) g) -> (OmegaCompletePartialOrder.Continuous'.{u1, u2} α (Part.{u2} γ) _inst_1 (Part.omegaCompletePartialOrder.{u2} γ) (fun (x : α) => Seq.seq.{u2, u2} Part.{u2} (Applicative.toSeq.{u2, u2} Part.{u2} (Monad.toApplicative.{u2, u2} Part.{u2} Part.instMonadPart.{u2})) β γ (f x) (fun (x._@.Mathlib.Order.OmegaCompletePartialOrder._hyg.6415 : Unit) => g x)))
Case conversion may be inaccurate. Consider using '#align omega_complete_partial_order.continuous_hom.seq_continuous' OmegaCompletePartialOrder.ContinuousHom.seq_continuous'ₓ'. -/
theorem seq_continuous' {β γ : Type v} (f : α → Part (β → γ)) (g : α → Part β) (hf : Continuous' f)
    (hg : Continuous' g) : Continuous' fun x => f x <*> g x := by
  simp only [seq_eq_bind_map] <;> apply bind_continuous' _ _ hf <;>
        apply Pi.OmegaCompletePartialOrder.flip₂_continuous' <;>
      intro <;>
    apply map_continuous' _ _ hg
#align omega_complete_partial_order.continuous_hom.seq_continuous' OmegaCompletePartialOrder.ContinuousHom.seq_continuous'

#print OmegaCompletePartialOrder.ContinuousHom.continuous /-
theorem continuous (F : α →𝒄 β) (C : Chain α) : F (ωSup C) = ωSup (C.map F) :=
  ContinuousHom.cont _ _
#align omega_complete_partial_order.continuous_hom.continuous OmegaCompletePartialOrder.ContinuousHom.continuous
-/

#print OmegaCompletePartialOrder.ContinuousHom.ofFun /-
/-- Construct a continuous function from a bare function, a continuous function, and a proof that
they are equal. -/
@[simps, reducible]
def ofFun (f : α → β) (g : α →𝒄 β) (h : f = g) : α →𝒄 β := by
  refine' { toOrderHom := { toFun := f.. }.. } <;> subst h <;> rcases g with ⟨⟨⟩⟩ <;> assumption
#align omega_complete_partial_order.continuous_hom.of_fun OmegaCompletePartialOrder.ContinuousHom.ofFun
-/

#print OmegaCompletePartialOrder.ContinuousHom.ofMono /-
/-- Construct a continuous function from a monotone function with a proof of continuity. -/
@[simps, reducible]
def ofMono (f : α →o β) (h : ∀ c : Chain α, f (ωSup c) = ωSup (c.map f)) : α →𝒄 β
    where
  toFun := f
  monotone' := f.Monotone
  cont := h
#align omega_complete_partial_order.continuous_hom.of_mono OmegaCompletePartialOrder.ContinuousHom.ofMono
-/

#print OmegaCompletePartialOrder.ContinuousHom.id /-
/-- The identity as a continuous function. -/
@[simps]
def id : α →𝒄 α :=
  ofMono OrderHom.id continuous_id
#align omega_complete_partial_order.continuous_hom.id OmegaCompletePartialOrder.ContinuousHom.id
-/

#print OmegaCompletePartialOrder.ContinuousHom.comp /-
/-- The composition of continuous functions. -/
@[simps]
def comp (f : β →𝒄 γ) (g : α →𝒄 β) : α →𝒄 γ :=
  ofMono (OrderHom.comp ↑f ↑g) (continuous_comp _ _ g.cont f.cont)
#align omega_complete_partial_order.continuous_hom.comp OmegaCompletePartialOrder.ContinuousHom.comp
-/

#print OmegaCompletePartialOrder.ContinuousHom.ext /-
@[ext]
protected theorem ext (f g : α →𝒄 β) (h : ∀ x, f x = g x) : f = g := by
  cases f <;> cases g <;> congr <;> ext <;> apply h
#align omega_complete_partial_order.continuous_hom.ext OmegaCompletePartialOrder.ContinuousHom.ext
-/

#print OmegaCompletePartialOrder.ContinuousHom.coe_inj /-
protected theorem coe_inj (f g : α →𝒄 β) (h : (f : α → β) = g) : f = g :=
  ContinuousHom.ext _ _ <| congr_fun h
#align omega_complete_partial_order.continuous_hom.coe_inj OmegaCompletePartialOrder.ContinuousHom.coe_inj
-/

/- warning: omega_complete_partial_order.continuous_hom.comp_id -> OmegaCompletePartialOrder.ContinuousHom.comp_id is a dubious translation:
lean 3 declaration is
  forall {β : Type.{u1}} {γ : Type.{u2}} [_inst_2 : OmegaCompletePartialOrder.{u1} β] [_inst_3 : OmegaCompletePartialOrder.{u2} γ] (f : OmegaCompletePartialOrder.ContinuousHom.{u1, u2} β γ _inst_2 _inst_3), Eq.{max (succ u1) (succ u2)} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} β γ _inst_2 _inst_3) (OmegaCompletePartialOrder.ContinuousHom.comp.{u1, u1, u2} β β γ _inst_2 _inst_2 _inst_3 f (OmegaCompletePartialOrder.ContinuousHom.id.{u1} β _inst_2)) f
but is expected to have type
  forall {β : Type.{u2}} {γ : Type.{u1}} [_inst_2 : OmegaCompletePartialOrder.{u2} β] [_inst_3 : OmegaCompletePartialOrder.{u1} γ] (f : OmegaCompletePartialOrder.ContinuousHom.{u2, u1} β γ _inst_2 _inst_3), Eq.{max (succ u2) (succ u1)} (OmegaCompletePartialOrder.ContinuousHom.{u2, u1} β γ _inst_2 _inst_3) (OmegaCompletePartialOrder.ContinuousHom.comp.{u2, u2, u1} β β γ _inst_2 _inst_2 _inst_3 f (OmegaCompletePartialOrder.ContinuousHom.id.{u2} β _inst_2)) f
Case conversion may be inaccurate. Consider using '#align omega_complete_partial_order.continuous_hom.comp_id OmegaCompletePartialOrder.ContinuousHom.comp_idₓ'. -/
@[simp]
theorem comp_id (f : β →𝒄 γ) : f.comp id = f := by ext <;> rfl
#align omega_complete_partial_order.continuous_hom.comp_id OmegaCompletePartialOrder.ContinuousHom.comp_id

/- warning: omega_complete_partial_order.continuous_hom.id_comp -> OmegaCompletePartialOrder.ContinuousHom.id_comp is a dubious translation:
lean 3 declaration is
  forall {β : Type.{u1}} {γ : Type.{u2}} [_inst_2 : OmegaCompletePartialOrder.{u1} β] [_inst_3 : OmegaCompletePartialOrder.{u2} γ] (f : OmegaCompletePartialOrder.ContinuousHom.{u1, u2} β γ _inst_2 _inst_3), Eq.{max (succ u1) (succ u2)} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} β γ _inst_2 _inst_3) (OmegaCompletePartialOrder.ContinuousHom.comp.{u1, u2, u2} β γ γ _inst_2 _inst_3 _inst_3 (OmegaCompletePartialOrder.ContinuousHom.id.{u2} γ _inst_3) f) f
but is expected to have type
  forall {β : Type.{u2}} {γ : Type.{u1}} [_inst_2 : OmegaCompletePartialOrder.{u2} β] [_inst_3 : OmegaCompletePartialOrder.{u1} γ] (f : OmegaCompletePartialOrder.ContinuousHom.{u2, u1} β γ _inst_2 _inst_3), Eq.{max (succ u2) (succ u1)} (OmegaCompletePartialOrder.ContinuousHom.{u2, u1} β γ _inst_2 _inst_3) (OmegaCompletePartialOrder.ContinuousHom.comp.{u2, u1, u1} β γ γ _inst_2 _inst_3 _inst_3 (OmegaCompletePartialOrder.ContinuousHom.id.{u1} γ _inst_3) f) f
Case conversion may be inaccurate. Consider using '#align omega_complete_partial_order.continuous_hom.id_comp OmegaCompletePartialOrder.ContinuousHom.id_compₓ'. -/
@[simp]
theorem id_comp (f : β →𝒄 γ) : id.comp f = f := by ext <;> rfl
#align omega_complete_partial_order.continuous_hom.id_comp OmegaCompletePartialOrder.ContinuousHom.id_comp

/- warning: omega_complete_partial_order.continuous_hom.comp_assoc -> OmegaCompletePartialOrder.ContinuousHom.comp_assoc is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} {φ : Type.{u4}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : OmegaCompletePartialOrder.{u2} β] [_inst_3 : OmegaCompletePartialOrder.{u3} γ] [_inst_4 : OmegaCompletePartialOrder.{u4} φ] (f : OmegaCompletePartialOrder.ContinuousHom.{u3, u4} γ φ _inst_3 _inst_4) (g : OmegaCompletePartialOrder.ContinuousHom.{u2, u3} β γ _inst_2 _inst_3) (h : OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2), Eq.{max (succ u1) (succ u4)} (OmegaCompletePartialOrder.ContinuousHom.{u1, u4} α φ _inst_1 _inst_4) (OmegaCompletePartialOrder.ContinuousHom.comp.{u1, u3, u4} α γ φ _inst_1 _inst_3 _inst_4 f (OmegaCompletePartialOrder.ContinuousHom.comp.{u1, u2, u3} α β γ _inst_1 _inst_2 _inst_3 g h)) (OmegaCompletePartialOrder.ContinuousHom.comp.{u1, u2, u4} α β φ _inst_1 _inst_2 _inst_4 (OmegaCompletePartialOrder.ContinuousHom.comp.{u2, u3, u4} β γ φ _inst_2 _inst_3 _inst_4 f g) h)
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u4}} {γ : Type.{u2}} {φ : Type.{u1}} [_inst_1 : OmegaCompletePartialOrder.{u3} α] [_inst_2 : OmegaCompletePartialOrder.{u4} β] [_inst_3 : OmegaCompletePartialOrder.{u2} γ] [_inst_4 : OmegaCompletePartialOrder.{u1} φ] (f : OmegaCompletePartialOrder.ContinuousHom.{u2, u1} γ φ _inst_3 _inst_4) (g : OmegaCompletePartialOrder.ContinuousHom.{u4, u2} β γ _inst_2 _inst_3) (h : OmegaCompletePartialOrder.ContinuousHom.{u3, u4} α β _inst_1 _inst_2), Eq.{max (succ u3) (succ u1)} (OmegaCompletePartialOrder.ContinuousHom.{u3, u1} α φ _inst_1 _inst_4) (OmegaCompletePartialOrder.ContinuousHom.comp.{u3, u2, u1} α γ φ _inst_1 _inst_3 _inst_4 f (OmegaCompletePartialOrder.ContinuousHom.comp.{u3, u4, u2} α β γ _inst_1 _inst_2 _inst_3 g h)) (OmegaCompletePartialOrder.ContinuousHom.comp.{u3, u4, u1} α β φ _inst_1 _inst_2 _inst_4 (OmegaCompletePartialOrder.ContinuousHom.comp.{u4, u2, u1} β γ φ _inst_2 _inst_3 _inst_4 f g) h)
Case conversion may be inaccurate. Consider using '#align omega_complete_partial_order.continuous_hom.comp_assoc OmegaCompletePartialOrder.ContinuousHom.comp_assocₓ'. -/
@[simp]
theorem comp_assoc (f : γ →𝒄 φ) (g : β →𝒄 γ) (h : α →𝒄 β) : f.comp (g.comp h) = (f.comp g).comp h :=
  by ext <;> rfl
#align omega_complete_partial_order.continuous_hom.comp_assoc OmegaCompletePartialOrder.ContinuousHom.comp_assoc

@[simp]
theorem coe_apply (a : α) (f : α →𝒄 β) : (f : α →o β) a = f a :=
  rfl
#align omega_complete_partial_order.continuous_hom.coe_apply OmegaCompletePartialOrder.ContinuousHom.coe_apply

#print OmegaCompletePartialOrder.ContinuousHom.const /-
/-- `function.const` is a continuous function. -/
def const (x : β) : α →𝒄 β :=
  ofMono (OrderHom.const _ x) (continuous_const x)
#align omega_complete_partial_order.continuous_hom.const OmegaCompletePartialOrder.ContinuousHom.const
-/

#print OmegaCompletePartialOrder.ContinuousHom.const_apply /-
@[simp]
theorem const_apply (f : β) (a : α) : const f a = f :=
  rfl
#align omega_complete_partial_order.continuous_hom.const_apply OmegaCompletePartialOrder.ContinuousHom.const_apply
-/

instance [Inhabited β] : Inhabited (α →𝒄 β) :=
  ⟨const default⟩

#print OmegaCompletePartialOrder.ContinuousHom.toMono /-
/-- The map from continuous functions to monotone functions is itself a monotone function. -/
@[simps]
def toMono : (α →𝒄 β) →o α →o β where
  toFun f := f
  monotone' x y h := h
#align omega_complete_partial_order.continuous_hom.to_mono OmegaCompletePartialOrder.ContinuousHom.toMono
-/

#print OmegaCompletePartialOrder.ContinuousHom.forall_forall_merge /-
/-- When proving that a chain of applications is below a bound `z`, it suffices to consider the
functions and values being selected from the same index in the chains.

This lemma is more specific than necessary, i.e. `c₀` only needs to be a
chain of monotone functions, but it is only used with continuous functions. -/
@[simp]
theorem forall_forall_merge (c₀ : Chain (α →𝒄 β)) (c₁ : Chain α) (z : β) :
    (∀ i j : ℕ, (c₀ i) (c₁ j) ≤ z) ↔ ∀ i : ℕ, (c₀ i) (c₁ i) ≤ z :=
  by
  constructor <;> introv h
  · apply h
  · apply le_trans _ (h (max i j))
    trans c₀ i (c₁ (max i j))
    · apply (c₀ i).Monotone
      apply c₁.monotone
      apply le_max_right
    · apply c₀.monotone
      apply le_max_left
#align omega_complete_partial_order.continuous_hom.forall_forall_merge OmegaCompletePartialOrder.ContinuousHom.forall_forall_merge
-/

#print OmegaCompletePartialOrder.ContinuousHom.forall_forall_merge' /-
@[simp]
theorem forall_forall_merge' (c₀ : Chain (α →𝒄 β)) (c₁ : Chain α) (z : β) :
    (∀ j i : ℕ, (c₀ i) (c₁ j) ≤ z) ↔ ∀ i : ℕ, (c₀ i) (c₁ i) ≤ z := by
  rw [forall_swap, forall_forall_merge]
#align omega_complete_partial_order.continuous_hom.forall_forall_merge' OmegaCompletePartialOrder.ContinuousHom.forall_forall_merge'
-/

#print OmegaCompletePartialOrder.ContinuousHom.ωSup /-
/-- The `ωSup` operator for continuous functions, which takes the pointwise countable supremum
of the functions in the `ω`-chain. -/
@[simps]
protected def ωSup (c : Chain (α →𝒄 β)) : α →𝒄 β :=
  ContinuousHom.ofMono (ωSup <| c.map toMono)
    (by
      intro c'
      apply eq_of_forall_ge_iff; intro z
      simp only [ωSup_le_iff, (c _).Continuous, chain.map_coe, OrderHom.apply_coe, to_mono_coe,
        coe_apply, order_hom.omega_complete_partial_order_ωSup_coe, forall_forall_merge,
        forall_forall_merge', (· ∘ ·), Function.eval])
#align omega_complete_partial_order.continuous_hom.ωSup OmegaCompletePartialOrder.ContinuousHom.ωSup
-/

@[simps ωSup]
instance : OmegaCompletePartialOrder (α →𝒄 β) :=
  OmegaCompletePartialOrder.lift ContinuousHom.toMono ContinuousHom.ωSup (fun x y h => h) fun c =>
    rfl

namespace Prod

/- warning: omega_complete_partial_order.continuous_hom.prod.apply -> OmegaCompletePartialOrder.ContinuousHom.Prod.apply is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : OmegaCompletePartialOrder.{u2} β], OmegaCompletePartialOrder.ContinuousHom.{max u1 u2, u2} (Prod.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α) β (Prod.omegaCompletePartialOrder.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α (OmegaCompletePartialOrder.ContinuousHom.omegaCompletePartialOrder.{u1, u2} α β _inst_1 _inst_2) _inst_1) _inst_2
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : OmegaCompletePartialOrder.{u2} β], OmegaCompletePartialOrder.ContinuousHom.{max u2 u1, u2} (Prod.{max u2 u1, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α) β (Prod.instOmegaCompletePartialOrderProd.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α (OmegaCompletePartialOrder.ContinuousHom.instOmegaCompletePartialOrderContinuousHom.{u1, u2} α β _inst_1 _inst_2) _inst_1) _inst_2
Case conversion may be inaccurate. Consider using '#align omega_complete_partial_order.continuous_hom.prod.apply OmegaCompletePartialOrder.ContinuousHom.Prod.applyₓ'. -/
/-- The application of continuous functions as a continuous function.  -/
@[simps]
def apply : (α →𝒄 β) × α →𝒄 β where
  toFun f := f.1 f.2
  monotone' x y h := by
    dsimp
    trans y.fst x.snd <;> [apply h.1, apply y.1.Monotone h.2]
  cont := by
    intro c
    apply le_antisymm
    · apply ωSup_le
      intro i
      dsimp
      rw [(c _).fst.Continuous]
      apply ωSup_le
      intro j
      apply le_ωSup_of_le (max i j)
      apply apply_mono
      exact monotone_fst (OrderHom.mono _ (le_max_left _ _))
      exact monotone_snd (OrderHom.mono _ (le_max_right _ _))
    · apply ωSup_le
      intro i
      apply le_ωSup_of_le i
      dsimp
      apply OrderHom.mono _
      apply le_ωSup_of_le i
      rfl
#align omega_complete_partial_order.continuous_hom.prod.apply OmegaCompletePartialOrder.ContinuousHom.Prod.apply

end Prod

#print OmegaCompletePartialOrder.ContinuousHom.ωSup_def /-
theorem ωSup_def (c : Chain (α →𝒄 β)) (x : α) : ωSup c x = ContinuousHom.ωSup c x :=
  rfl
#align omega_complete_partial_order.continuous_hom.ωSup_def OmegaCompletePartialOrder.ContinuousHom.ωSup_def
-/

/- warning: omega_complete_partial_order.continuous_hom.ωSup_apply_ωSup -> OmegaCompletePartialOrder.ContinuousHom.ωSup_apply_ωSup is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : OmegaCompletePartialOrder.{u2} β] (c₀ : OmegaCompletePartialOrder.Chain.{max u1 u2} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) (PartialOrder.toPreorder.{max u1 u2} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) (OmegaCompletePartialOrder.ContinuousHom.partialOrder.{u1, u2} α β _inst_1 _inst_2))) (c₁ : OmegaCompletePartialOrder.Chain.{u1} α (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1))), Eq.{succ u2} β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) (fun (_x : OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) => α -> β) (OmegaCompletePartialOrder.ContinuousHom.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) (OmegaCompletePartialOrder.ωSup.{max u1 u2} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) (OmegaCompletePartialOrder.ContinuousHom.omegaCompletePartialOrder.{u1, u2} α β _inst_1 _inst_2) c₀) (OmegaCompletePartialOrder.ωSup.{u1} α _inst_1 c₁)) (coeFn.{max (succ (max u1 u2)) (succ u2), max (succ (max u1 u2)) (succ u2)} (OmegaCompletePartialOrder.ContinuousHom.{max u1 u2, u2} (Prod.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α) β (Prod.omegaCompletePartialOrder.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α (OmegaCompletePartialOrder.ContinuousHom.omegaCompletePartialOrder.{u1, u2} α β _inst_1 _inst_2) _inst_1) _inst_2) (fun (_x : OmegaCompletePartialOrder.ContinuousHom.{max u1 u2, u2} (Prod.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α) β (Prod.omegaCompletePartialOrder.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α (OmegaCompletePartialOrder.ContinuousHom.omegaCompletePartialOrder.{u1, u2} α β _inst_1 _inst_2) _inst_1) _inst_2) => (Prod.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α) -> β) (OmegaCompletePartialOrder.ContinuousHom.hasCoeToFun.{max u1 u2, u2} (Prod.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α) β (Prod.omegaCompletePartialOrder.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α (OmegaCompletePartialOrder.ContinuousHom.omegaCompletePartialOrder.{u1, u2} α β _inst_1 _inst_2) _inst_1) _inst_2) (OmegaCompletePartialOrder.ContinuousHom.Prod.apply.{u1, u2} α β _inst_1 _inst_2) (OmegaCompletePartialOrder.ωSup.{max u1 u2} (Prod.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α) (Prod.omegaCompletePartialOrder.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α (OmegaCompletePartialOrder.ContinuousHom.omegaCompletePartialOrder.{u1, u2} α β _inst_1 _inst_2) _inst_1) (OmegaCompletePartialOrder.Chain.zip.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α (PartialOrder.toPreorder.{max u1 u2} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) (OmegaCompletePartialOrder.ContinuousHom.partialOrder.{u1, u2} α β _inst_1 _inst_2)) (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) c₀ c₁)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : OmegaCompletePartialOrder.{u1} α] [_inst_2 : OmegaCompletePartialOrder.{u2} β] (c₀ : OmegaCompletePartialOrder.Chain.{max u2 u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) (PartialOrder.toPreorder.{max u1 u2} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) (OmegaCompletePartialOrder.instPartialOrderContinuousHom.{u1, u2} α β _inst_1 _inst_2))) (c₁ : OmegaCompletePartialOrder.Chain.{u1} α (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1))), Eq.{succ u2} β (OrderHom.toFun.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β _inst_2)) (OmegaCompletePartialOrder.ContinuousHom.toOrderHom.{u1, u2} α β _inst_1 _inst_2 (OmegaCompletePartialOrder.ωSup.{max u1 u2} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) (OmegaCompletePartialOrder.ContinuousHom.instOmegaCompletePartialOrderContinuousHom.{u1, u2} α β _inst_1 _inst_2) c₀)) (OmegaCompletePartialOrder.ωSup.{u1} α _inst_1 c₁)) (OrderHom.toFun.{max u2 u1, u2} (Prod.{max u2 u1, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α) β (PartialOrder.toPreorder.{max u2 u1} (Prod.{max u2 u1, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α) (OmegaCompletePartialOrder.toPartialOrder.{max u2 u1} (Prod.{max u2 u1, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α) (Prod.instOmegaCompletePartialOrderProd.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α (OmegaCompletePartialOrder.ContinuousHom.instOmegaCompletePartialOrderContinuousHom.{u1, u2} α β _inst_1 _inst_2) _inst_1))) (PartialOrder.toPreorder.{u2} β (OmegaCompletePartialOrder.toPartialOrder.{u2} β _inst_2)) (OmegaCompletePartialOrder.ContinuousHom.toOrderHom.{max u2 u1, u2} (Prod.{max u2 u1, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α) β (Prod.instOmegaCompletePartialOrderProd.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α (OmegaCompletePartialOrder.ContinuousHom.instOmegaCompletePartialOrderContinuousHom.{u1, u2} α β _inst_1 _inst_2) _inst_1) _inst_2 (OmegaCompletePartialOrder.ContinuousHom.Prod.apply.{u1, u2} α β _inst_1 _inst_2)) (OmegaCompletePartialOrder.ωSup.{max u2 u1} (Prod.{max u2 u1, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α) (Prod.instOmegaCompletePartialOrderProd.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α (OmegaCompletePartialOrder.ContinuousHom.instOmegaCompletePartialOrderContinuousHom.{u1, u2} α β _inst_1 _inst_2) _inst_1) (OmegaCompletePartialOrder.Chain.zip.{max u1 u2, u1} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) α (PartialOrder.toPreorder.{max u1 u2} (OmegaCompletePartialOrder.ContinuousHom.{u1, u2} α β _inst_1 _inst_2) (OmegaCompletePartialOrder.instPartialOrderContinuousHom.{u1, u2} α β _inst_1 _inst_2)) (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α _inst_1)) c₀ c₁)))
Case conversion may be inaccurate. Consider using '#align omega_complete_partial_order.continuous_hom.ωSup_apply_ωSup OmegaCompletePartialOrder.ContinuousHom.ωSup_apply_ωSupₓ'. -/
theorem ωSup_apply_ωSup (c₀ : Chain (α →𝒄 β)) (c₁ : Chain α) :
    ωSup c₀ (ωSup c₁) = Prod.apply (ωSup (c₀.zip c₁)) := by simp [prod.apply_apply, Prod.ωSup_zip]
#align omega_complete_partial_order.continuous_hom.ωSup_apply_ωSup OmegaCompletePartialOrder.ContinuousHom.ωSup_apply_ωSup

#print OmegaCompletePartialOrder.ContinuousHom.flip /-
/-- A family of continuous functions yields a continuous family of functions. -/
@[simps]
def flip {α : Type _} (f : α → β →𝒄 γ) : β →𝒄 α → γ
    where
  toFun x y := f y x
  monotone' x y h a := (f a).Monotone h
  cont := by intro <;> ext <;> change f x _ = _ <;> rw [(f x).Continuous] <;> rfl
#align omega_complete_partial_order.continuous_hom.flip OmegaCompletePartialOrder.ContinuousHom.flip
-/

#print OmegaCompletePartialOrder.ContinuousHom.bind /-
/-- `part.bind` as a continuous function. -/
@[simps (config := { rhsMd := reducible })]
noncomputable def bind {β γ : Type v} (f : α →𝒄 Part β) (g : α →𝒄 β → Part γ) : α →𝒄 Part γ :=
  ofMono (OrderHom.bind ↑f ↑g) fun c =>
    by
    rw [OrderHom.bind, ← OrderHom.bind, ωSup_bind, ← f.continuous, ← g.continuous]
    rfl
#align omega_complete_partial_order.continuous_hom.bind OmegaCompletePartialOrder.ContinuousHom.bind
-/

#print OmegaCompletePartialOrder.ContinuousHom.map /-
/-- `part.map` as a continuous function. -/
@[simps (config := { rhsMd := reducible })]
noncomputable def map {β γ : Type v} (f : β → γ) (g : α →𝒄 Part β) : α →𝒄 Part γ :=
  ofFun (fun x => f <$> g x) (bind g (const (pure ∘ f))) <| by
    ext <;>
      simp only [map_eq_bind_pure_comp, bind_apply, OrderHom.bind_coe, const_apply,
        OrderHom.const_coe_coe, coe_apply]
#align omega_complete_partial_order.continuous_hom.map OmegaCompletePartialOrder.ContinuousHom.map
-/

#print OmegaCompletePartialOrder.ContinuousHom.seq /-
/-- `part.seq` as a continuous function. -/
@[simps (config := { rhsMd := reducible })]
noncomputable def seq {β γ : Type v} (f : α →𝒄 Part (β → γ)) (g : α →𝒄 Part β) : α →𝒄 Part γ :=
  ofFun (fun x => f x <*> g x) (bind f <| flip <| flip map g)
    (by
      ext <;>
          simp only [seq_eq_bind_map, flip, Part.bind_eq_bind, map_apply, Part.mem_bind_iff,
            bind_apply, OrderHom.bind_coe, coe_apply, flip_apply] <;>
        rfl)
#align omega_complete_partial_order.continuous_hom.seq OmegaCompletePartialOrder.ContinuousHom.seq
-/

end ContinuousHom

end OmegaCompletePartialOrder

