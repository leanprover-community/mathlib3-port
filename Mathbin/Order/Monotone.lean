/-
Copyright (c) 2014 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Mario Carneiro, Yaël Dillies
-/
import Mathbin.Order.Compare
import Mathbin.Order.Max
import Mathbin.Order.RelClasses

/-!
# Monotonicity

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> https://github.com/leanprover-community/mathlib4/pull/591
> Any changes to this file require a corresponding PR to mathlib4.

This file defines (strictly) monotone/antitone functions. Contrary to standard mathematical usage,
"monotone"/"mono" here means "increasing", not "increasing or decreasing". We use "antitone"/"anti"
to mean "decreasing".

## Definitions

* `monotone f`: A function `f` between two preorders is monotone if `a ≤ b` implies `f a ≤ f b`.
* `antitone f`: A function `f` between two preorders is antitone if `a ≤ b` implies `f b ≤ f a`.
* `monotone_on f s`: Same as `monotone f`, but for all `a, b ∈ s`.
* `antitone_on f s`: Same as `antitone f`, but for all `a, b ∈ s`.
* `strict_mono f` : A function `f` between two preorders is strictly monotone if `a < b` implies
  `f a < f b`.
* `strict_anti f` : A function `f` between two preorders is strictly antitone if `a < b` implies
  `f b < f a`.
* `strict_mono_on f s`: Same as `strict_mono f`, but for all `a, b ∈ s`.
* `strict_anti_on f s`: Same as `strict_anti f`, but for all `a, b ∈ s`.

## Main theorems

* `monotone_nat_of_le_succ`, `monotone_int_of_le_succ`: If `f : ℕ → α` or `f : ℤ → α` and
  `f n ≤ f (n + 1)` for all `n`, then `f` is monotone.
* `antitone_nat_of_succ_le`, `antitone_int_of_succ_le`: If `f : ℕ → α` or `f : ℤ → α` and
  `f (n + 1) ≤ f n` for all `n`, then `f` is antitone.
* `strict_mono_nat_of_lt_succ`, `strict_mono_int_of_lt_succ`: If `f : ℕ → α` or `f : ℤ → α` and
  `f n < f (n + 1)` for all `n`, then `f` is strictly monotone.
* `strict_anti_nat_of_succ_lt`, `strict_anti_int_of_succ_lt`: If `f : ℕ → α` or `f : ℤ → α` and
  `f (n + 1) < f n` for all `n`, then `f` is strictly antitone.

## Implementation notes

Some of these definitions used to only require `has_le α` or `has_lt α`. The advantage of this is
unclear and it led to slight elaboration issues. Now, everything requires `preorder α` and seems to
work fine. Related Zulip discussion:
https://leanprover.zulipchat.com/#narrow/stream/113488-general/topic/Order.20diamond/near/254353352.

## TODO

The above theorems are also true in `ℕ+`, `fin n`... To make that work, we need `succ_order α`
and `succ_archimedean α`.

## Tags

monotone, strictly monotone, antitone, strictly antitone, increasing, strictly increasing,
decreasing, strictly decreasing
-/


open Function OrderDual

universe u v w

variable {α : Type u} {β : Type v} {γ : Type w} {δ : Type _} {r : α → α → Prop}

section MonotoneDef

variable [Preorder α] [Preorder β]

#print Monotone /-
/-- A function `f` is monotone if `a ≤ b` implies `f a ≤ f b`. -/
def Monotone (f : α → β) : Prop :=
  ∀ ⦃a b⦄, a ≤ b → f a ≤ f b
#align monotone Monotone
-/

#print Antitone /-
/-- A function `f` is antitone if `a ≤ b` implies `f b ≤ f a`. -/
def Antitone (f : α → β) : Prop :=
  ∀ ⦃a b⦄, a ≤ b → f b ≤ f a
#align antitone Antitone
-/

#print MonotoneOn /-
/-- A function `f` is monotone on `s` if, for all `a, b ∈ s`, `a ≤ b` implies `f a ≤ f b`. -/
def MonotoneOn (f : α → β) (s : Set α) : Prop :=
  ∀ ⦃a⦄ (ha : a ∈ s) ⦃b⦄ (hb : b ∈ s), a ≤ b → f a ≤ f b
#align monotone_on MonotoneOn
-/

#print AntitoneOn /-
/-- A function `f` is antitone on `s` if, for all `a, b ∈ s`, `a ≤ b` implies `f b ≤ f a`. -/
def AntitoneOn (f : α → β) (s : Set α) : Prop :=
  ∀ ⦃a⦄ (ha : a ∈ s) ⦃b⦄ (hb : b ∈ s), a ≤ b → f b ≤ f a
#align antitone_on AntitoneOn
-/

#print StrictMono /-
/-- A function `f` is strictly monotone if `a < b` implies `f a < f b`. -/
def StrictMono (f : α → β) : Prop :=
  ∀ ⦃a b⦄, a < b → f a < f b
#align strict_mono StrictMono
-/

#print StrictAnti /-
/-- A function `f` is strictly antitone if `a < b` implies `f b < f a`. -/
def StrictAnti (f : α → β) : Prop :=
  ∀ ⦃a b⦄, a < b → f b < f a
#align strict_anti StrictAnti
-/

#print StrictMonoOn /-
/-- A function `f` is strictly monotone on `s` if, for all `a, b ∈ s`, `a < b` implies
`f a < f b`. -/
def StrictMonoOn (f : α → β) (s : Set α) : Prop :=
  ∀ ⦃a⦄ (ha : a ∈ s) ⦃b⦄ (hb : b ∈ s), a < b → f a < f b
#align strict_mono_on StrictMonoOn
-/

#print StrictAntiOn /-
/-- A function `f` is strictly antitone on `s` if, for all `a, b ∈ s`, `a < b` implies
`f b < f a`. -/
def StrictAntiOn (f : α → β) (s : Set α) : Prop :=
  ∀ ⦃a⦄ (ha : a ∈ s) ⦃b⦄ (hb : b ∈ s), a < b → f b < f a
#align strict_anti_on StrictAntiOn
-/

end MonotoneDef

/-! ### Monotonicity on the dual order

Strictly, many of the `*_on.dual` lemmas in this section should use `of_dual ⁻¹' s` instead of `s`,
but right now this is not possible as `set.preimage` is not defined yet, and importing it creates
an import cycle.

Often, you should not need the rewriting lemmas. Instead, you probably want to add `.dual`,
`.dual_left` or `.dual_right` to your `monotone`/`antitone` hypothesis.
-/


section OrderDual

variable [Preorder α] [Preorder β] {f : α → β} {s : Set α}

#print monotone_comp_ofDual_iff /-
@[simp]
theorem monotone_comp_ofDual_iff : Monotone (f ∘ of_dual) ↔ Antitone f :=
  forall_swap
#align monotone_comp_of_dual_iff monotone_comp_ofDual_iff
-/

#print antitone_comp_ofDual_iff /-
@[simp]
theorem antitone_comp_ofDual_iff : Antitone (f ∘ of_dual) ↔ Monotone f :=
  forall_swap
#align antitone_comp_of_dual_iff antitone_comp_ofDual_iff
-/

#print monotone_toDual_comp_iff /-
@[simp]
theorem monotone_toDual_comp_iff : Monotone (to_dual ∘ f) ↔ Antitone f :=
  Iff.rfl
#align monotone_to_dual_comp_iff monotone_toDual_comp_iff
-/

#print antitone_toDual_comp_iff /-
@[simp]
theorem antitone_toDual_comp_iff : Antitone (to_dual ∘ f) ↔ Monotone f :=
  Iff.rfl
#align antitone_to_dual_comp_iff antitone_toDual_comp_iff
-/

#print monotoneOn_comp_ofDual_iff /-
@[simp]
theorem monotoneOn_comp_ofDual_iff : MonotoneOn (f ∘ of_dual) s ↔ AntitoneOn f s :=
  forall₂_swap
#align monotone_on_comp_of_dual_iff monotoneOn_comp_ofDual_iff
-/

#print antitoneOn_comp_ofDual_iff /-
@[simp]
theorem antitoneOn_comp_ofDual_iff : AntitoneOn (f ∘ of_dual) s ↔ MonotoneOn f s :=
  forall₂_swap
#align antitone_on_comp_of_dual_iff antitoneOn_comp_ofDual_iff
-/

#print monotoneOn_toDual_comp_iff /-
@[simp]
theorem monotoneOn_toDual_comp_iff : MonotoneOn (to_dual ∘ f) s ↔ AntitoneOn f s :=
  Iff.rfl
#align monotone_on_to_dual_comp_iff monotoneOn_toDual_comp_iff
-/

#print antitoneOn_toDual_comp_iff /-
@[simp]
theorem antitoneOn_toDual_comp_iff : AntitoneOn (to_dual ∘ f) s ↔ MonotoneOn f s :=
  Iff.rfl
#align antitone_on_to_dual_comp_iff antitoneOn_toDual_comp_iff
-/

#print strictMono_comp_ofDual_iff /-
@[simp]
theorem strictMono_comp_ofDual_iff : StrictMono (f ∘ of_dual) ↔ StrictAnti f :=
  forall_swap
#align strict_mono_comp_of_dual_iff strictMono_comp_ofDual_iff
-/

#print strictAnti_comp_ofDual_iff /-
@[simp]
theorem strictAnti_comp_ofDual_iff : StrictAnti (f ∘ of_dual) ↔ StrictMono f :=
  forall_swap
#align strict_anti_comp_of_dual_iff strictAnti_comp_ofDual_iff
-/

#print strictMono_toDual_comp_iff /-
@[simp]
theorem strictMono_toDual_comp_iff : StrictMono (to_dual ∘ f) ↔ StrictAnti f :=
  Iff.rfl
#align strict_mono_to_dual_comp_iff strictMono_toDual_comp_iff
-/

#print strictAnti_toDual_comp_iff /-
@[simp]
theorem strictAnti_toDual_comp_iff : StrictAnti (to_dual ∘ f) ↔ StrictMono f :=
  Iff.rfl
#align strict_anti_to_dual_comp_iff strictAnti_toDual_comp_iff
-/

#print strictMonoOn_comp_ofDual_iff /-
@[simp]
theorem strictMonoOn_comp_ofDual_iff : StrictMonoOn (f ∘ of_dual) s ↔ StrictAntiOn f s :=
  forall₂_swap
#align strict_mono_on_comp_of_dual_iff strictMonoOn_comp_ofDual_iff
-/

#print strictAntiOn_comp_ofDual_iff /-
@[simp]
theorem strictAntiOn_comp_ofDual_iff : StrictAntiOn (f ∘ of_dual) s ↔ StrictMonoOn f s :=
  forall₂_swap
#align strict_anti_on_comp_of_dual_iff strictAntiOn_comp_ofDual_iff
-/

#print strictMonoOn_toDual_comp_iff /-
@[simp]
theorem strictMonoOn_toDual_comp_iff : StrictMonoOn (to_dual ∘ f) s ↔ StrictAntiOn f s :=
  Iff.rfl
#align strict_mono_on_to_dual_comp_iff strictMonoOn_toDual_comp_iff
-/

#print strictAntiOn_toDual_comp_iff /-
@[simp]
theorem strictAntiOn_toDual_comp_iff : StrictAntiOn (to_dual ∘ f) s ↔ StrictMonoOn f s :=
  Iff.rfl
#align strict_anti_on_to_dual_comp_iff strictAntiOn_toDual_comp_iff
-/

#print Monotone.dual /-
protected theorem Monotone.dual (hf : Monotone f) : Monotone (to_dual ∘ f ∘ of_dual) :=
  swap hf
#align monotone.dual Monotone.dual
-/

#print Antitone.dual /-
protected theorem Antitone.dual (hf : Antitone f) : Antitone (to_dual ∘ f ∘ of_dual) :=
  swap hf
#align antitone.dual Antitone.dual
-/

#print MonotoneOn.dual /-
protected theorem MonotoneOn.dual (hf : MonotoneOn f s) : MonotoneOn (to_dual ∘ f ∘ of_dual) s :=
  swap₂ hf
#align monotone_on.dual MonotoneOn.dual
-/

#print AntitoneOn.dual /-
protected theorem AntitoneOn.dual (hf : AntitoneOn f s) : AntitoneOn (to_dual ∘ f ∘ of_dual) s :=
  swap₂ hf
#align antitone_on.dual AntitoneOn.dual
-/

#print StrictMono.dual /-
protected theorem StrictMono.dual (hf : StrictMono f) : StrictMono (to_dual ∘ f ∘ of_dual) :=
  swap hf
#align strict_mono.dual StrictMono.dual
-/

#print StrictAnti.dual /-
protected theorem StrictAnti.dual (hf : StrictAnti f) : StrictAnti (to_dual ∘ f ∘ of_dual) :=
  swap hf
#align strict_anti.dual StrictAnti.dual
-/

#print StrictMonoOn.dual /-
protected theorem StrictMonoOn.dual (hf : StrictMonoOn f s) : StrictMonoOn (to_dual ∘ f ∘ of_dual) s :=
  swap₂ hf
#align strict_mono_on.dual StrictMonoOn.dual
-/

#print StrictAntiOn.dual /-
protected theorem StrictAntiOn.dual (hf : StrictAntiOn f s) : StrictAntiOn (to_dual ∘ f ∘ of_dual) s :=
  swap₂ hf
#align strict_anti_on.dual StrictAntiOn.dual
-/

alias antitone_comp_ofDual_iff ↔ _ Monotone.dual_left

alias monotone_comp_ofDual_iff ↔ _ Antitone.dual_left

alias antitone_toDual_comp_iff ↔ _ Monotone.dual_right

alias monotone_toDual_comp_iff ↔ _ Antitone.dual_right

alias antitoneOn_comp_ofDual_iff ↔ _ MonotoneOn.dual_left

alias monotoneOn_comp_ofDual_iff ↔ _ AntitoneOn.dual_left

alias antitoneOn_toDual_comp_iff ↔ _ MonotoneOn.dual_right

alias monotoneOn_toDual_comp_iff ↔ _ AntitoneOn.dual_right

alias strictAnti_comp_ofDual_iff ↔ _ StrictMono.dual_left

alias strictMono_comp_ofDual_iff ↔ _ StrictAnti.dual_left

alias strictAnti_toDual_comp_iff ↔ _ StrictMono.dual_right

alias strictMono_toDual_comp_iff ↔ _ StrictAnti.dual_right

alias strictAntiOn_comp_ofDual_iff ↔ _ StrictMonoOn.dual_left

alias strictMonoOn_comp_ofDual_iff ↔ _ StrictAntiOn.dual_left

alias strictAntiOn_toDual_comp_iff ↔ _ StrictMonoOn.dual_right

alias strictMonoOn_toDual_comp_iff ↔ _ StrictAntiOn.dual_right

end OrderDual

/-! ### Monotonicity in function spaces -/


section Preorder

variable [Preorder α]

#print Monotone.comp_le_comp_left /-
theorem Monotone.comp_le_comp_left [Preorder β] {f : β → α} {g h : γ → β} (hf : Monotone f) (le_gh : g ≤ h) :
    LE.le.{max w u} (f ∘ g) (f ∘ h) := fun x => hf (le_gh x)
#align monotone.comp_le_comp_left Monotone.comp_le_comp_left
-/

variable [Preorder γ]

/- warning: monotone_lam -> monotone_lam is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{w} γ] {f : α -> β -> γ}, (forall (b : β), Monotone.{u w} α γ _inst_1 _inst_2 (fun (a : α) => f a b)) -> (Monotone.{u (max v w)} α (β -> γ) _inst_1 (Pi.preorder.{v w} β (fun (ᾰ : β) => γ) (fun (i : β) => _inst_2)) f)
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} [inst._@.Mathlib.Order.Monotone._hyg.1468 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.1471 : Preorder.{w} γ] {f : α -> β -> γ}, (forall (b : β), Monotone.{u w} α γ inst._@.Mathlib.Order.Monotone._hyg.1468 inst._@.Mathlib.Order.Monotone._hyg.1471 (fun (a : α) => f a b)) -> (Monotone.{u (max v w)} α (β -> γ) inst._@.Mathlib.Order.Monotone._hyg.1468 (instPreorderForAll.{v w} β (fun (a._@.Mathlib.Order.Monotone._hyg.1476 : β) => γ) (fun (i : β) => inst._@.Mathlib.Order.Monotone._hyg.1471)) f)
Case conversion may be inaccurate. Consider using '#align monotone_lam monotone_lamₓ'. -/
theorem monotone_lam {f : α → β → γ} (hf : ∀ b, Monotone fun a => f a b) : Monotone f := fun a a' h b => hf b h
#align monotone_lam monotone_lam

/- warning: monotone_app -> monotone_app is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{w} γ] (f : β -> α -> γ) (b : β), (Monotone.{u (max v w)} α (β -> γ) _inst_1 (Pi.preorder.{v w} β (fun (b : β) => γ) (fun (i : β) => _inst_2)) (fun (a : α) (b : β) => f b a)) -> (Monotone.{u w} α γ _inst_1 _inst_2 (f b))
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} [inst._@.Mathlib.Order.Monotone._hyg.1516 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.1519 : Preorder.{w} γ] (f : β -> α -> γ) (b : β), (Monotone.{u (max v w)} α (β -> γ) inst._@.Mathlib.Order.Monotone._hyg.1516 (instPreorderForAll.{v w} β (fun (b : β) => γ) (fun (i : β) => inst._@.Mathlib.Order.Monotone._hyg.1519)) (fun (a : α) (b : β) => f b a)) -> (Monotone.{u w} α γ inst._@.Mathlib.Order.Monotone._hyg.1516 inst._@.Mathlib.Order.Monotone._hyg.1519 (f b))
Case conversion may be inaccurate. Consider using '#align monotone_app monotone_appₓ'. -/
theorem monotone_app (f : β → α → γ) (b : β) (hf : Monotone fun a b => f b a) : Monotone (f b) := fun a a' h => hf h b
#align monotone_app monotone_app

/- warning: antitone_lam -> antitone_lam is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{w} γ] {f : α -> β -> γ}, (forall (b : β), Antitone.{u w} α γ _inst_1 _inst_2 (fun (a : α) => f a b)) -> (Antitone.{u (max v w)} α (β -> γ) _inst_1 (Pi.preorder.{v w} β (fun (ᾰ : β) => γ) (fun (i : β) => _inst_2)) f)
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} [inst._@.Mathlib.Order.Monotone._hyg.1565 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.1568 : Preorder.{w} γ] {f : α -> β -> γ}, (forall (b : β), Antitone.{u w} α γ inst._@.Mathlib.Order.Monotone._hyg.1565 inst._@.Mathlib.Order.Monotone._hyg.1568 (fun (a : α) => f a b)) -> (Antitone.{u (max v w)} α (β -> γ) inst._@.Mathlib.Order.Monotone._hyg.1565 (instPreorderForAll.{v w} β (fun (a._@.Mathlib.Order.Monotone._hyg.1573 : β) => γ) (fun (i : β) => inst._@.Mathlib.Order.Monotone._hyg.1568)) f)
Case conversion may be inaccurate. Consider using '#align antitone_lam antitone_lamₓ'. -/
theorem antitone_lam {f : α → β → γ} (hf : ∀ b, Antitone fun a => f a b) : Antitone f := fun a a' h b => hf b h
#align antitone_lam antitone_lam

/- warning: antitone_app -> antitone_app is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{w} γ] (f : β -> α -> γ) (b : β), (Antitone.{u (max v w)} α (β -> γ) _inst_1 (Pi.preorder.{v w} β (fun (b : β) => γ) (fun (i : β) => _inst_2)) (fun (a : α) (b : β) => f b a)) -> (Antitone.{u w} α γ _inst_1 _inst_2 (f b))
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} [inst._@.Mathlib.Order.Monotone._hyg.1613 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.1616 : Preorder.{w} γ] (f : β -> α -> γ) (b : β), (Antitone.{u (max v w)} α (β -> γ) inst._@.Mathlib.Order.Monotone._hyg.1613 (instPreorderForAll.{v w} β (fun (b : β) => γ) (fun (i : β) => inst._@.Mathlib.Order.Monotone._hyg.1616)) (fun (a : α) (b : β) => f b a)) -> (Antitone.{u w} α γ inst._@.Mathlib.Order.Monotone._hyg.1613 inst._@.Mathlib.Order.Monotone._hyg.1616 (f b))
Case conversion may be inaccurate. Consider using '#align antitone_app antitone_appₓ'. -/
theorem antitone_app (f : β → α → γ) (b : β) (hf : Antitone fun a b => f b a) : Antitone (f b) := fun a a' h => hf h b
#align antitone_app antitone_app

end Preorder

/- warning: function.monotone_eval -> Function.monotone_eval is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u}} {α : ι -> Type.{v}} [_inst_1 : forall (i : ι), Preorder.{v} (α i)] (i : ι), Monotone.{(max u v) v} (forall (x : ι), α x) (α i) (Pi.preorder.{u v} ι (fun (x : ι) => α x) (fun (i : ι) => _inst_1 i)) (_inst_1 i) (Function.eval.{succ u succ v} ι (fun (i : ι) => α i) i)
but is expected to have type
  forall {ι : Type.{u}} {α : ι -> Type.{v}} [inst._@.Mathlib.Order.Monotone._hyg.1670 : forall (i : ι), Preorder.{v} (α i)] (i : ι), Monotone.{(max u v) v} (forall (x : ι), α x) (α i) (instPreorderForAll.{u v} ι (fun (x : ι) => α x) (fun (i : ι) => inst._@.Mathlib.Order.Monotone._hyg.1670 i)) (inst._@.Mathlib.Order.Monotone._hyg.1670 i) (Function.eval.{succ u succ v} ι (fun (i : ι) => α i) i)
Case conversion may be inaccurate. Consider using '#align function.monotone_eval Function.monotone_evalₓ'. -/
theorem Function.monotone_eval {ι : Type u} {α : ι → Type v} [∀ i, Preorder (α i)] (i : ι) :
    Monotone (Function.eval i : (∀ i, α i) → α i) := fun f g H => H i
#align function.monotone_eval Function.monotone_eval

/-! ### Monotonicity hierarchy -/


section Preorder

variable [Preorder α]

section Preorder

variable [Preorder β] {f : α → β} {a b : α}

/-!
These four lemmas are there to strip off the semi-implicit arguments `⦃a b : α⦄`. This is useful
when you do not want to apply a `monotone` assumption (i.e. your goal is `a ≤ b → f a ≤ f b`).
However if you find yourself writing `hf.imp h`, then you should have written `hf h` instead.
-/


#print Monotone.imp /-
theorem Monotone.imp (hf : Monotone f) (h : a ≤ b) : f a ≤ f b :=
  hf h
#align monotone.imp Monotone.imp
-/

#print Antitone.imp /-
theorem Antitone.imp (hf : Antitone f) (h : a ≤ b) : f b ≤ f a :=
  hf h
#align antitone.imp Antitone.imp
-/

#print StrictMono.imp /-
theorem StrictMono.imp (hf : StrictMono f) (h : a < b) : f a < f b :=
  hf h
#align strict_mono.imp StrictMono.imp
-/

#print StrictAnti.imp /-
theorem StrictAnti.imp (hf : StrictAnti f) (h : a < b) : f b < f a :=
  hf h
#align strict_anti.imp StrictAnti.imp
-/

protected theorem Monotone.monotone_on (hf : Monotone f) (s : Set α) : MonotoneOn f s := fun a _ b _ => hf.imp
#align monotone.monotone_on Monotone.monotone_on

protected theorem Antitone.antitone_on (hf : Antitone f) (s : Set α) : AntitoneOn f s := fun a _ b _ => hf.imp
#align antitone.antitone_on Antitone.antitone_on

#print monotoneOn_univ /-
theorem monotoneOn_univ : MonotoneOn f Set.univ ↔ Monotone f :=
  ⟨fun h a b => h trivial trivial, fun h => h.MonotoneOn _⟩
#align monotone_on_univ monotoneOn_univ
-/

#print antitoneOn_univ /-
theorem antitoneOn_univ : AntitoneOn f Set.univ ↔ Antitone f :=
  ⟨fun h a b => h trivial trivial, fun h => h.AntitoneOn _⟩
#align antitone_on_univ antitoneOn_univ
-/

#print StrictMono.strictMonoOn /-
protected theorem StrictMono.strictMonoOn (hf : StrictMono f) (s : Set α) : StrictMonoOn f s := fun a _ b _ => hf.imp
#align strict_mono.strict_mono_on StrictMono.strictMonoOn
-/

#print StrictAnti.strictAntiOn /-
protected theorem StrictAnti.strictAntiOn (hf : StrictAnti f) (s : Set α) : StrictAntiOn f s := fun a _ b _ => hf.imp
#align strict_anti.strict_anti_on StrictAnti.strictAntiOn
-/

#print strictMonoOn_univ /-
theorem strictMonoOn_univ : StrictMonoOn f Set.univ ↔ StrictMono f :=
  ⟨fun h a b => h trivial trivial, fun h => h.StrictMonoOn _⟩
#align strict_mono_on_univ strictMonoOn_univ
-/

#print strictAntiOn_univ /-
theorem strictAntiOn_univ : StrictAntiOn f Set.univ ↔ StrictAnti f :=
  ⟨fun h a b => h trivial trivial, fun h => h.StrictAntiOn _⟩
#align strict_anti_on_univ strictAntiOn_univ
-/

end Preorder

section PartialOrder

variable [PartialOrder β] {f : α → β}

#print Monotone.strictMono_of_injective /-
theorem Monotone.strictMono_of_injective (h₁ : Monotone f) (h₂ : Injective f) : StrictMono f := fun a b h =>
  (h₁ h.le).lt_of_ne fun H => h.Ne <| h₂ H
#align monotone.strict_mono_of_injective Monotone.strictMono_of_injective
-/

#print Antitone.strictAnti_of_injective /-
theorem Antitone.strictAnti_of_injective (h₁ : Antitone f) (h₂ : Injective f) : StrictAnti f := fun a b h =>
  (h₁ h.le).lt_of_ne fun H => h.Ne <| h₂ H.symm
#align antitone.strict_anti_of_injective Antitone.strictAnti_of_injective
-/

end PartialOrder

end Preorder

section PartialOrder

variable [PartialOrder α] [Preorder β] {f : α → β} {s : Set α}

#print monotone_iff_forall_lt /-
theorem monotone_iff_forall_lt : Monotone f ↔ ∀ ⦃a b⦄, a < b → f a ≤ f b :=
  forall₂_congr fun a b => ⟨fun hf h => hf h.le, fun hf h => h.eq_or_lt.elim (fun H => (congr_arg _ H).le) hf⟩
#align monotone_iff_forall_lt monotone_iff_forall_lt
-/

#print antitone_iff_forall_lt /-
theorem antitone_iff_forall_lt : Antitone f ↔ ∀ ⦃a b⦄, a < b → f b ≤ f a :=
  forall₂_congr fun a b => ⟨fun hf h => hf h.le, fun hf h => h.eq_or_lt.elim (fun H => (congr_arg _ H).ge) hf⟩
#align antitone_iff_forall_lt antitone_iff_forall_lt
-/

#print monotoneOn_iff_forall_lt /-
theorem monotoneOn_iff_forall_lt : MonotoneOn f s ↔ ∀ ⦃a⦄ (ha : a ∈ s) ⦃b⦄ (hb : b ∈ s), a < b → f a ≤ f b :=
  ⟨fun hf a ha b hb h => hf ha hb h.le, fun hf a ha b hb h => h.eq_or_lt.elim (fun H => (congr_arg _ H).le) (hf ha hb)⟩
#align monotone_on_iff_forall_lt monotoneOn_iff_forall_lt
-/

#print antitoneOn_iff_forall_lt /-
theorem antitoneOn_iff_forall_lt : AntitoneOn f s ↔ ∀ ⦃a⦄ (ha : a ∈ s) ⦃b⦄ (hb : b ∈ s), a < b → f b ≤ f a :=
  ⟨fun hf a ha b hb h => hf ha hb h.le, fun hf a ha b hb h => h.eq_or_lt.elim (fun H => (congr_arg _ H).ge) (hf ha hb)⟩
#align antitone_on_iff_forall_lt antitoneOn_iff_forall_lt
-/

#print StrictMonoOn.monotoneOn /-
-- `preorder α` isn't strong enough: if the preorder on `α` is an equivalence relation,
-- then `strict_mono f` is vacuously true.
protected theorem StrictMonoOn.monotoneOn (hf : StrictMonoOn f s) : MonotoneOn f s :=
  monotoneOn_iff_forall_lt.2 fun a ha b hb h => (hf ha hb h).le
#align strict_mono_on.monotone_on StrictMonoOn.monotoneOn
-/

#print StrictAntiOn.antitoneOn /-
protected theorem StrictAntiOn.antitoneOn (hf : StrictAntiOn f s) : AntitoneOn f s :=
  antitoneOn_iff_forall_lt.2 fun a ha b hb h => (hf ha hb h).le
#align strict_anti_on.antitone_on StrictAntiOn.antitoneOn
-/

#print StrictMono.monotone /-
protected theorem StrictMono.monotone (hf : StrictMono f) : Monotone f :=
  monotone_iff_forall_lt.2 fun a b h => (hf h).le
#align strict_mono.monotone StrictMono.monotone
-/

#print StrictAnti.antitone /-
protected theorem StrictAnti.antitone (hf : StrictAnti f) : Antitone f :=
  antitone_iff_forall_lt.2 fun a b h => (hf h).le
#align strict_anti.antitone StrictAnti.antitone
-/

end PartialOrder

/-! ### Monotonicity from and to subsingletons -/


namespace Subsingleton

variable [Preorder α] [Preorder β]

#print Subsingleton.monotone /-
protected theorem monotone [Subsingleton α] (f : α → β) : Monotone f := fun a b _ =>
  (congr_arg _ <| Subsingleton.elim _ _).le
#align subsingleton.monotone Subsingleton.monotone
-/

#print Subsingleton.antitone /-
protected theorem antitone [Subsingleton α] (f : α → β) : Antitone f := fun a b _ =>
  (congr_arg _ <| Subsingleton.elim _ _).le
#align subsingleton.antitone Subsingleton.antitone
-/

#print Subsingleton.monotone' /-
theorem monotone' [Subsingleton β] (f : α → β) : Monotone f := fun a b _ => (Subsingleton.elim _ _).le
#align subsingleton.monotone' Subsingleton.monotone'
-/

#print Subsingleton.antitone' /-
theorem antitone' [Subsingleton β] (f : α → β) : Antitone f := fun a b _ => (Subsingleton.elim _ _).le
#align subsingleton.antitone' Subsingleton.antitone'
-/

#print Subsingleton.strictMono /-
protected theorem strictMono [Subsingleton α] (f : α → β) : StrictMono f := fun a b h =>
  (h.Ne <| Subsingleton.elim _ _).elim
#align subsingleton.strict_mono Subsingleton.strictMono
-/

#print Subsingleton.strictAnti /-
protected theorem strictAnti [Subsingleton α] (f : α → β) : StrictAnti f := fun a b h =>
  (h.Ne <| Subsingleton.elim _ _).elim
#align subsingleton.strict_anti Subsingleton.strictAnti
-/

end Subsingleton

/-! ### Miscellaneous monotonicity results -/


#print monotone_id /-
theorem monotone_id [Preorder α] : Monotone (id : α → α) := fun a b => id
#align monotone_id monotone_id
-/

#print monotoneOn_id /-
theorem monotoneOn_id [Preorder α] {s : Set α} : MonotoneOn id s := fun a ha b hb => id
#align monotone_on_id monotoneOn_id
-/

#print strictMono_id /-
theorem strictMono_id [Preorder α] : StrictMono (id : α → α) := fun a b => id
#align strict_mono_id strictMono_id
-/

#print strictMonoOn_id /-
theorem strictMonoOn_id [Preorder α] {s : Set α} : StrictMonoOn id s := fun a ha b hb => id
#align strict_mono_on_id strictMonoOn_id
-/

#print monotone_const /-
theorem monotone_const [Preorder α] [Preorder β] {c : β} : Monotone fun a : α => c := fun a b _ => le_rfl
#align monotone_const monotone_const
-/

#print monotoneOn_const /-
theorem monotoneOn_const [Preorder α] [Preorder β] {c : β} {s : Set α} : MonotoneOn (fun a : α => c) s :=
  fun a _ b _ _ => le_rfl
#align monotone_on_const monotoneOn_const
-/

#print antitone_const /-
theorem antitone_const [Preorder α] [Preorder β] {c : β} : Antitone fun a : α => c := fun a b _ => le_refl c
#align antitone_const antitone_const
-/

#print antitoneOn_const /-
theorem antitoneOn_const [Preorder α] [Preorder β] {c : β} {s : Set α} : AntitoneOn (fun a : α => c) s :=
  fun a _ b _ _ => le_rfl
#align antitone_on_const antitoneOn_const
-/

#print strictMono_of_le_iff_le /-
theorem strictMono_of_le_iff_le [Preorder α] [Preorder β] {f : α → β} (h : ∀ x y, x ≤ y ↔ f x ≤ f y) : StrictMono f :=
  fun a b => (lt_iff_lt_of_le_iff_le' (h _ _) (h _ _)).1
#align strict_mono_of_le_iff_le strictMono_of_le_iff_le
-/

#print strictAnti_of_le_iff_le /-
theorem strictAnti_of_le_iff_le [Preorder α] [Preorder β] {f : α → β} (h : ∀ x y, x ≤ y ↔ f y ≤ f x) : StrictAnti f :=
  fun a b => (lt_iff_lt_of_le_iff_le' (h _ _) (h _ _)).1
#align strict_anti_of_le_iff_le strictAnti_of_le_iff_le
-/

#print injective_of_lt_imp_ne /-
theorem injective_of_lt_imp_ne [LinearOrder α] {f : α → β} (h : ∀ x y, x < y → f x ≠ f y) : Injective f := by
  intro x y hxy
  contrapose hxy
  cases' Ne.lt_or_lt hxy with hxy hxy
  exacts[h _ _ hxy, (h _ _ hxy).symm]
#align injective_of_lt_imp_ne injective_of_lt_imp_ne
-/

#print injective_of_le_imp_le /-
theorem injective_of_le_imp_le [PartialOrder α] [Preorder β] (f : α → β) (h : ∀ {x y}, f x ≤ f y → x ≤ y) :
    Injective f := fun x y hxy => (h hxy.le).antisymm (h hxy.ge)
#align injective_of_le_imp_le injective_of_le_imp_le
-/

section Preorder

variable [Preorder α] [Preorder β] {f g : α → β} {a : α}

#print StrictMono.isMax_of_apply /-
theorem StrictMono.isMax_of_apply (hf : StrictMono f) (ha : IsMax (f a)) : IsMax a :=
  of_not_not fun h =>
    let ⟨b, hb⟩ := not_is_max_iff.1 h
    (hf hb).not_is_max ha
#align strict_mono.is_max_of_apply StrictMono.isMax_of_apply
-/

#print StrictMono.isMin_of_apply /-
theorem StrictMono.isMin_of_apply (hf : StrictMono f) (ha : IsMin (f a)) : IsMin a :=
  of_not_not fun h =>
    let ⟨b, hb⟩ := not_is_min_iff.1 h
    (hf hb).not_is_min ha
#align strict_mono.is_min_of_apply StrictMono.isMin_of_apply
-/

#print StrictAnti.isMax_of_apply /-
theorem StrictAnti.isMax_of_apply (hf : StrictAnti f) (ha : IsMin (f a)) : IsMax a :=
  of_not_not fun h =>
    let ⟨b, hb⟩ := not_is_max_iff.1 h
    (hf hb).not_is_min ha
#align strict_anti.is_max_of_apply StrictAnti.isMax_of_apply
-/

#print StrictAnti.isMin_of_apply /-
theorem StrictAnti.isMin_of_apply (hf : StrictAnti f) (ha : IsMax (f a)) : IsMin a :=
  of_not_not fun h =>
    let ⟨b, hb⟩ := not_is_min_iff.1 h
    (hf hb).not_is_max ha
#align strict_anti.is_min_of_apply StrictAnti.isMin_of_apply
-/

#print StrictMono.ite' /-
protected theorem StrictMono.ite' (hf : StrictMono f) (hg : StrictMono g) {p : α → Prop} [DecidablePred p]
    (hp : ∀ ⦃x y⦄, x < y → p y → p x) (hfg : ∀ ⦃x y⦄, p x → ¬p y → x < y → f x < g y) :
    StrictMono fun x => if p x then f x else g x := by
  intro x y h
  by_cases hy : p y
  · have hx : p x := hp h hy
    simpa [hx, hy] using hf h
    
  by_cases hx : p x
  · simpa [hx, hy] using hfg hx hy h
    
  · simpa [hx, hy] using hg h
    
#align strict_mono.ite' StrictMono.ite'
-/

#print StrictMono.ite /-
protected theorem StrictMono.ite (hf : StrictMono f) (hg : StrictMono g) {p : α → Prop} [DecidablePred p]
    (hp : ∀ ⦃x y⦄, x < y → p y → p x) (hfg : ∀ x, f x ≤ g x) : StrictMono fun x => if p x then f x else g x :=
  (hf.ite' hg hp) fun x y hx hy h => (hf h).trans_le (hfg y)
#align strict_mono.ite StrictMono.ite
-/

#print StrictAnti.ite' /-
protected theorem StrictAnti.ite' (hf : StrictAnti f) (hg : StrictAnti g) {p : α → Prop} [DecidablePred p]
    (hp : ∀ ⦃x y⦄, x < y → p y → p x) (hfg : ∀ ⦃x y⦄, p x → ¬p y → x < y → g y < f x) :
    StrictAnti fun x => if p x then f x else g x :=
  (StrictMono.ite' hf.dual_right hg.dual_right hp hfg).dual_right
#align strict_anti.ite' StrictAnti.ite'
-/

#print StrictAnti.ite /-
protected theorem StrictAnti.ite (hf : StrictAnti f) (hg : StrictAnti g) {p : α → Prop} [DecidablePred p]
    (hp : ∀ ⦃x y⦄, x < y → p y → p x) (hfg : ∀ x, g x ≤ f x) : StrictAnti fun x => if p x then f x else g x :=
  (hf.ite' hg hp) fun x y hx hy h => (hfg y).trans_lt (hf h)
#align strict_anti.ite StrictAnti.ite
-/

end Preorder

/-! ### Monotonicity under composition -/


section Composition

variable [Preorder α] [Preorder β] [Preorder γ] {g : β → γ} {f : α → β} {s : Set α}

#print Monotone.comp /-
protected theorem Monotone.comp (hg : Monotone g) (hf : Monotone f) : Monotone (g ∘ f) := fun a b h => hg (hf h)
#align monotone.comp Monotone.comp
-/

#print Monotone.comp_antitone /-
theorem Monotone.comp_antitone (hg : Monotone g) (hf : Antitone f) : Antitone (g ∘ f) := fun a b h => hg (hf h)
#align monotone.comp_antitone Monotone.comp_antitone
-/

#print Antitone.comp /-
protected theorem Antitone.comp (hg : Antitone g) (hf : Antitone f) : Monotone (g ∘ f) := fun a b h => hg (hf h)
#align antitone.comp Antitone.comp
-/

#print Antitone.comp_monotone /-
theorem Antitone.comp_monotone (hg : Antitone g) (hf : Monotone f) : Antitone (g ∘ f) := fun a b h => hg (hf h)
#align antitone.comp_monotone Antitone.comp_monotone
-/

#print Monotone.iterate /-
protected theorem Monotone.iterate {f : α → α} (hf : Monotone f) (n : ℕ) : Monotone (f^[n]) :=
  Nat.recOn n monotone_id fun n h => h.comp hf
#align monotone.iterate Monotone.iterate
-/

#print Monotone.comp_monotoneOn /-
protected theorem Monotone.comp_monotoneOn (hg : Monotone g) (hf : MonotoneOn f s) : MonotoneOn (g ∘ f) s :=
  fun a ha b hb h => hg (hf ha hb h)
#align monotone.comp_monotone_on Monotone.comp_monotoneOn
-/

#print Monotone.comp_antitoneOn /-
theorem Monotone.comp_antitoneOn (hg : Monotone g) (hf : AntitoneOn f s) : AntitoneOn (g ∘ f) s := fun a ha b hb h =>
  hg (hf ha hb h)
#align monotone.comp_antitone_on Monotone.comp_antitoneOn
-/

#print Antitone.comp_antitoneOn /-
protected theorem Antitone.comp_antitoneOn (hg : Antitone g) (hf : AntitoneOn f s) : MonotoneOn (g ∘ f) s :=
  fun a ha b hb h => hg (hf ha hb h)
#align antitone.comp_antitone_on Antitone.comp_antitoneOn
-/

#print Antitone.comp_monotoneOn /-
theorem Antitone.comp_monotoneOn (hg : Antitone g) (hf : MonotoneOn f s) : AntitoneOn (g ∘ f) s := fun a ha b hb h =>
  hg (hf ha hb h)
#align antitone.comp_monotone_on Antitone.comp_monotoneOn
-/

#print StrictMono.comp /-
protected theorem StrictMono.comp (hg : StrictMono g) (hf : StrictMono f) : StrictMono (g ∘ f) := fun a b h => hg (hf h)
#align strict_mono.comp StrictMono.comp
-/

#print StrictMono.comp_strictAnti /-
theorem StrictMono.comp_strictAnti (hg : StrictMono g) (hf : StrictAnti f) : StrictAnti (g ∘ f) := fun a b h =>
  hg (hf h)
#align strict_mono.comp_strict_anti StrictMono.comp_strictAnti
-/

#print StrictAnti.comp /-
protected theorem StrictAnti.comp (hg : StrictAnti g) (hf : StrictAnti f) : StrictMono (g ∘ f) := fun a b h => hg (hf h)
#align strict_anti.comp StrictAnti.comp
-/

#print StrictAnti.comp_strictMono /-
theorem StrictAnti.comp_strictMono (hg : StrictAnti g) (hf : StrictMono f) : StrictAnti (g ∘ f) := fun a b h =>
  hg (hf h)
#align strict_anti.comp_strict_mono StrictAnti.comp_strictMono
-/

#print StrictMono.iterate /-
protected theorem StrictMono.iterate {f : α → α} (hf : StrictMono f) (n : ℕ) : StrictMono (f^[n]) :=
  Nat.recOn n strictMono_id fun n h => h.comp hf
#align strict_mono.iterate StrictMono.iterate
-/

#print StrictMono.comp_strictMonoOn /-
protected theorem StrictMono.comp_strictMonoOn (hg : StrictMono g) (hf : StrictMonoOn f s) : StrictMonoOn (g ∘ f) s :=
  fun a ha b hb h => hg (hf ha hb h)
#align strict_mono.comp_strict_mono_on StrictMono.comp_strictMonoOn
-/

#print StrictMono.comp_strictAntiOn /-
theorem StrictMono.comp_strictAntiOn (hg : StrictMono g) (hf : StrictAntiOn f s) : StrictAntiOn (g ∘ f) s :=
  fun a ha b hb h => hg (hf ha hb h)
#align strict_mono.comp_strict_anti_on StrictMono.comp_strictAntiOn
-/

#print StrictAnti.comp_strictAntiOn /-
protected theorem StrictAnti.comp_strictAntiOn (hg : StrictAnti g) (hf : StrictAntiOn f s) : StrictMonoOn (g ∘ f) s :=
  fun a ha b hb h => hg (hf ha hb h)
#align strict_anti.comp_strict_anti_on StrictAnti.comp_strictAntiOn
-/

#print StrictAnti.comp_strictMonoOn /-
theorem StrictAnti.comp_strictMonoOn (hg : StrictAnti g) (hf : StrictMonoOn f s) : StrictAntiOn (g ∘ f) s :=
  fun a ha b hb h => hg (hf ha hb h)
#align strict_anti.comp_strict_mono_on StrictAnti.comp_strictMonoOn
-/

end Composition

namespace List

section Fold

#print List.foldl_monotone /-
theorem foldl_monotone [Preorder α] {f : α → β → α} (H : ∀ b, Monotone fun a => f a b) (l : List β) :
    Monotone fun a => l.foldl f a :=
  List.recOn l (fun _ _ => id) fun i l hl _ _ h => hl (H _ h)
#align list.foldl_monotone List.foldl_monotone
-/

#print List.foldr_monotone /-
theorem foldr_monotone [Preorder β] {f : α → β → β} (H : ∀ a, Monotone (f a)) (l : List α) :
    Monotone fun b => l.foldr f b := fun _ _ h => List.recOn l h fun i l hl => H i hl
#align list.foldr_monotone List.foldr_monotone
-/

#print List.foldl_strictMono /-
theorem foldl_strictMono [Preorder α] {f : α → β → α} (H : ∀ b, StrictMono fun a => f a b) (l : List β) :
    StrictMono fun a => l.foldl f a :=
  List.recOn l (fun _ _ => id) fun i l hl _ _ h => hl (H _ h)
#align list.foldl_strict_mono List.foldl_strictMono
-/

#print List.foldr_strictMono /-
theorem foldr_strictMono [Preorder β] {f : α → β → β} (H : ∀ a, StrictMono (f a)) (l : List α) :
    StrictMono fun b => l.foldr f b := fun _ _ h => List.recOn l h fun i l hl => H i hl
#align list.foldr_strict_mono List.foldr_strictMono
-/

end Fold

end List

/-! ### Monotonicity in linear orders  -/


section LinearOrder

variable [LinearOrder α]

section Preorder

variable [Preorder β] {f : α → β} {s : Set α}

open Ordering

#print Monotone.reflect_lt /-
theorem Monotone.reflect_lt (hf : Monotone f) {a b : α} (h : f a < f b) : a < b :=
  lt_of_not_ge fun h' => h.not_le (hf h')
#align monotone.reflect_lt Monotone.reflect_lt
-/

#print Antitone.reflect_lt /-
theorem Antitone.reflect_lt (hf : Antitone f) {a b : α} (h : f a < f b) : b < a :=
  lt_of_not_ge fun h' => h.not_le (hf h')
#align antitone.reflect_lt Antitone.reflect_lt
-/

#print MonotoneOn.reflect_lt /-
theorem MonotoneOn.reflect_lt (hf : MonotoneOn f s) {a b : α} (ha : a ∈ s) (hb : b ∈ s) (h : f a < f b) : a < b :=
  lt_of_not_ge fun h' => h.not_le <| hf hb ha h'
#align monotone_on.reflect_lt MonotoneOn.reflect_lt
-/

#print AntitoneOn.reflect_lt /-
theorem AntitoneOn.reflect_lt (hf : AntitoneOn f s) {a b : α} (ha : a ∈ s) (hb : b ∈ s) (h : f a < f b) : b < a :=
  lt_of_not_ge fun h' => h.not_le <| hf ha hb h'
#align antitone_on.reflect_lt AntitoneOn.reflect_lt
-/

#print StrictMonoOn.le_iff_le /-
theorem StrictMonoOn.le_iff_le (hf : StrictMonoOn f s) {a b : α} (ha : a ∈ s) (hb : b ∈ s) : f a ≤ f b ↔ a ≤ b :=
  ⟨fun h => le_of_not_gt fun h' => (hf hb ha h').not_le h, fun h =>
    h.lt_or_eq_dec.elim (fun h' => (hf ha hb h').le) fun h' => h' ▸ le_rfl⟩
#align strict_mono_on.le_iff_le StrictMonoOn.le_iff_le
-/

#print StrictAntiOn.le_iff_le /-
theorem StrictAntiOn.le_iff_le (hf : StrictAntiOn f s) {a b : α} (ha : a ∈ s) (hb : b ∈ s) : f a ≤ f b ↔ b ≤ a :=
  hf.dual_right.le_iff_le hb ha
#align strict_anti_on.le_iff_le StrictAntiOn.le_iff_le
-/

#print StrictMonoOn.eq_iff_eq /-
theorem StrictMonoOn.eq_iff_eq (hf : StrictMonoOn f s) {a b : α} (ha : a ∈ s) (hb : b ∈ s) : f a = f b ↔ a = b :=
  ⟨fun h => le_antisymm ((hf.le_iff_le ha hb).mp h.le) ((hf.le_iff_le hb ha).mp h.ge), by
    rintro rfl
    rfl⟩
#align strict_mono_on.eq_iff_eq StrictMonoOn.eq_iff_eq
-/

#print StrictAntiOn.eq_iff_eq /-
theorem StrictAntiOn.eq_iff_eq (hf : StrictAntiOn f s) {a b : α} (ha : a ∈ s) (hb : b ∈ s) : f a = f b ↔ b = a :=
  (hf.dual_right.eq_iff_eq ha hb).trans eq_comm
#align strict_anti_on.eq_iff_eq StrictAntiOn.eq_iff_eq
-/

#print StrictMonoOn.lt_iff_lt /-
theorem StrictMonoOn.lt_iff_lt (hf : StrictMonoOn f s) {a b : α} (ha : a ∈ s) (hb : b ∈ s) : f a < f b ↔ a < b := by
  rw [lt_iff_le_not_le, lt_iff_le_not_le, hf.le_iff_le ha hb, hf.le_iff_le hb ha]
#align strict_mono_on.lt_iff_lt StrictMonoOn.lt_iff_lt
-/

#print StrictAntiOn.lt_iff_lt /-
theorem StrictAntiOn.lt_iff_lt (hf : StrictAntiOn f s) {a b : α} (ha : a ∈ s) (hb : b ∈ s) : f a < f b ↔ b < a :=
  hf.dual_right.lt_iff_lt hb ha
#align strict_anti_on.lt_iff_lt StrictAntiOn.lt_iff_lt
-/

#print StrictMono.le_iff_le /-
theorem StrictMono.le_iff_le (hf : StrictMono f) {a b : α} : f a ≤ f b ↔ a ≤ b :=
  (hf.StrictMonoOn Set.univ).le_iff_le trivial trivial
#align strict_mono.le_iff_le StrictMono.le_iff_le
-/

#print StrictAnti.le_iff_le /-
theorem StrictAnti.le_iff_le (hf : StrictAnti f) {a b : α} : f a ≤ f b ↔ b ≤ a :=
  (hf.StrictAntiOn Set.univ).le_iff_le trivial trivial
#align strict_anti.le_iff_le StrictAnti.le_iff_le
-/

#print StrictMono.lt_iff_lt /-
theorem StrictMono.lt_iff_lt (hf : StrictMono f) {a b : α} : f a < f b ↔ a < b :=
  (hf.StrictMonoOn Set.univ).lt_iff_lt trivial trivial
#align strict_mono.lt_iff_lt StrictMono.lt_iff_lt
-/

#print StrictAnti.lt_iff_lt /-
theorem StrictAnti.lt_iff_lt (hf : StrictAnti f) {a b : α} : f a < f b ↔ b < a :=
  (hf.StrictAntiOn Set.univ).lt_iff_lt trivial trivial
#align strict_anti.lt_iff_lt StrictAnti.lt_iff_lt
-/

#print StrictMonoOn.compares /-
protected theorem StrictMonoOn.compares (hf : StrictMonoOn f s) {a b : α} (ha : a ∈ s) (hb : b ∈ s) :
    ∀ {o : Ordering}, o.Compares (f a) (f b) ↔ o.Compares a b
  | Ordering.lt => hf.lt_iff_lt ha hb
  | Ordering.eq => ⟨fun h => ((hf.le_iff_le ha hb).1 h.le).antisymm ((hf.le_iff_le hb ha).1 h.symm.le), congr_arg _⟩
  | Ordering.gt => hf.lt_iff_lt hb ha
#align strict_mono_on.compares StrictMonoOn.compares
-/

#print StrictAntiOn.compares /-
protected theorem StrictAntiOn.compares (hf : StrictAntiOn f s) {a b : α} (ha : a ∈ s) (hb : b ∈ s) {o : Ordering} :
    o.Compares (f a) (f b) ↔ o.Compares b a :=
  toDual_compares_toDual.trans <| hf.dual_right.Compares hb ha
#align strict_anti_on.compares StrictAntiOn.compares
-/

#print StrictMono.compares /-
protected theorem StrictMono.compares (hf : StrictMono f) {a b : α} {o : Ordering} :
    o.Compares (f a) (f b) ↔ o.Compares a b :=
  (hf.StrictMonoOn Set.univ).Compares trivial trivial
#align strict_mono.compares StrictMono.compares
-/

#print StrictAnti.compares /-
protected theorem StrictAnti.compares (hf : StrictAnti f) {a b : α} {o : Ordering} :
    o.Compares (f a) (f b) ↔ o.Compares b a :=
  (hf.StrictAntiOn Set.univ).Compares trivial trivial
#align strict_anti.compares StrictAnti.compares
-/

#print StrictMono.injective /-
theorem StrictMono.injective (hf : StrictMono f) : Injective f := fun x y h => show Compares Eq x y from hf.Compares.1 h
#align strict_mono.injective StrictMono.injective
-/

#print StrictAnti.injective /-
theorem StrictAnti.injective (hf : StrictAnti f) : Injective f := fun x y h =>
  show Compares Eq x y from hf.Compares.1 h.symm
#align strict_anti.injective StrictAnti.injective
-/

#print StrictMono.maximal_of_maximal_image /-
theorem StrictMono.maximal_of_maximal_image (hf : StrictMono f) {a} (hmax : ∀ p, p ≤ f a) (x : α) : x ≤ a :=
  hf.le_iff_le.mp (hmax (f x))
#align strict_mono.maximal_of_maximal_image StrictMono.maximal_of_maximal_image
-/

#print StrictMono.minimal_of_minimal_image /-
theorem StrictMono.minimal_of_minimal_image (hf : StrictMono f) {a} (hmin : ∀ p, f a ≤ p) (x : α) : a ≤ x :=
  hf.le_iff_le.mp (hmin (f x))
#align strict_mono.minimal_of_minimal_image StrictMono.minimal_of_minimal_image
-/

#print StrictAnti.minimal_of_maximal_image /-
theorem StrictAnti.minimal_of_maximal_image (hf : StrictAnti f) {a} (hmax : ∀ p, p ≤ f a) (x : α) : a ≤ x :=
  hf.le_iff_le.mp (hmax (f x))
#align strict_anti.minimal_of_maximal_image StrictAnti.minimal_of_maximal_image
-/

#print StrictAnti.maximal_of_minimal_image /-
theorem StrictAnti.maximal_of_minimal_image (hf : StrictAnti f) {a} (hmin : ∀ p, f a ≤ p) (x : α) : x ≤ a :=
  hf.le_iff_le.mp (hmin (f x))
#align strict_anti.maximal_of_minimal_image StrictAnti.maximal_of_minimal_image
-/

end Preorder

section PartialOrder

variable [PartialOrder β] {f : α → β}

#print Monotone.strictMono_iff_injective /-
theorem Monotone.strictMono_iff_injective (hf : Monotone f) : StrictMono f ↔ Injective f :=
  ⟨fun h => h.Injective, hf.strict_mono_of_injective⟩
#align monotone.strict_mono_iff_injective Monotone.strictMono_iff_injective
-/

#print Antitone.strictAnti_iff_injective /-
theorem Antitone.strictAnti_iff_injective (hf : Antitone f) : StrictAnti f ↔ Injective f :=
  ⟨fun h => h.Injective, hf.strict_anti_of_injective⟩
#align antitone.strict_anti_iff_injective Antitone.strictAnti_iff_injective
-/

end PartialOrder

/-!
### Strictly monotone functions and `cmp`
-/


variable [LinearOrder β] {f : α → β} {s : Set α} {x y : α}

#print StrictMonoOn.cmp_map_eq /-
theorem StrictMonoOn.cmp_map_eq (hf : StrictMonoOn f s) (hx : x ∈ s) (hy : y ∈ s) : cmp (f x) (f y) = cmp x y :=
  ((hf.Compares hx hy).2 (cmp_compares x y)).cmp_eq
#align strict_mono_on.cmp_map_eq StrictMonoOn.cmp_map_eq
-/

#print StrictMono.cmp_map_eq /-
theorem StrictMono.cmp_map_eq (hf : StrictMono f) (x y : α) : cmp (f x) (f y) = cmp x y :=
  (hf.StrictMonoOn Set.univ).cmp_map_eq trivial trivial
#align strict_mono.cmp_map_eq StrictMono.cmp_map_eq
-/

#print StrictAntiOn.cmp_map_eq /-
theorem StrictAntiOn.cmp_map_eq (hf : StrictAntiOn f s) (hx : x ∈ s) (hy : y ∈ s) : cmp (f x) (f y) = cmp y x :=
  hf.dual_right.cmp_map_eq hy hx
#align strict_anti_on.cmp_map_eq StrictAntiOn.cmp_map_eq
-/

#print StrictAnti.cmp_map_eq /-
theorem StrictAnti.cmp_map_eq (hf : StrictAnti f) (x y : α) : cmp (f x) (f y) = cmp y x :=
  (hf.StrictAntiOn Set.univ).cmp_map_eq trivial trivial
#align strict_anti.cmp_map_eq StrictAnti.cmp_map_eq
-/

end LinearOrder

/-! ### Monotonicity in `ℕ` and `ℤ` -/


section Preorder

variable [Preorder α]

#print Nat.rel_of_forall_rel_succ_of_le_of_lt /-
theorem Nat.rel_of_forall_rel_succ_of_le_of_lt (r : β → β → Prop) [IsTrans β r] {f : ℕ → β} {a : ℕ}
    (h : ∀ n, a ≤ n → r (f n) (f (n + 1))) ⦃b c : ℕ⦄ (hab : a ≤ b) (hbc : b < c) : r (f b) (f c) := by
  induction' hbc with k b_lt_k r_b_k
  exacts[h _ hab, trans r_b_k (h _ (hab.trans_lt b_lt_k).le)]
#align nat.rel_of_forall_rel_succ_of_le_of_lt Nat.rel_of_forall_rel_succ_of_le_of_lt
-/

#print Nat.rel_of_forall_rel_succ_of_le_of_le /-
theorem Nat.rel_of_forall_rel_succ_of_le_of_le (r : β → β → Prop) [IsRefl β r] [IsTrans β r] {f : ℕ → β} {a : ℕ}
    (h : ∀ n, a ≤ n → r (f n) (f (n + 1))) ⦃b c : ℕ⦄ (hab : a ≤ b) (hbc : b ≤ c) : r (f b) (f c) :=
  hbc.eq_or_lt.elim (fun h => h ▸ refl _) (Nat.rel_of_forall_rel_succ_of_le_of_lt r h hab)
#align nat.rel_of_forall_rel_succ_of_le_of_le Nat.rel_of_forall_rel_succ_of_le_of_le
-/

#print Nat.rel_of_forall_rel_succ_of_lt /-
theorem Nat.rel_of_forall_rel_succ_of_lt (r : β → β → Prop) [IsTrans β r] {f : ℕ → β} (h : ∀ n, r (f n) (f (n + 1)))
    ⦃a b : ℕ⦄ (hab : a < b) : r (f a) (f b) :=
  Nat.rel_of_forall_rel_succ_of_le_of_lt r (fun n _ => h n) le_rfl hab
#align nat.rel_of_forall_rel_succ_of_lt Nat.rel_of_forall_rel_succ_of_lt
-/

#print Nat.rel_of_forall_rel_succ_of_le /-
theorem Nat.rel_of_forall_rel_succ_of_le (r : β → β → Prop) [IsRefl β r] [IsTrans β r] {f : ℕ → β}
    (h : ∀ n, r (f n) (f (n + 1))) ⦃a b : ℕ⦄ (hab : a ≤ b) : r (f a) (f b) :=
  Nat.rel_of_forall_rel_succ_of_le_of_le r (fun n _ => h n) le_rfl hab
#align nat.rel_of_forall_rel_succ_of_le Nat.rel_of_forall_rel_succ_of_le
-/

/- warning: monotone_nat_of_le_succ -> monotone_nat_of_le_succ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] {f : Nat -> α}, (forall (n : Nat), LE.le.{u} α (Preorder.toLE.{u} α _inst_1) (f n) (f (HAdd.hAdd.{0 0 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) -> (Monotone.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.linearOrder)) _inst_1 f)
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.8506 : Preorder.{u} α] {f : Nat -> α}, (forall (n : Nat), LE.le.{u} α (Preorder.toLE.{u} α inst._@.Mathlib.Order.Monotone._hyg.8506) (f n) (f (HAdd.hAdd.{0 0 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) -> (Monotone.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.instLinearOrderNat)) inst._@.Mathlib.Order.Monotone._hyg.8506 f)
Case conversion may be inaccurate. Consider using '#align monotone_nat_of_le_succ monotone_nat_of_le_succₓ'. -/
theorem monotone_nat_of_le_succ {f : ℕ → α} (hf : ∀ n, f n ≤ f (n + 1)) : Monotone f :=
  Nat.rel_of_forall_rel_succ_of_le (· ≤ ·) hf
#align monotone_nat_of_le_succ monotone_nat_of_le_succ

/- warning: antitone_nat_of_succ_le -> antitone_nat_of_succ_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] {f : Nat -> α}, (forall (n : Nat), LE.le.{u} α (Preorder.toLE.{u} α _inst_1) (f (HAdd.hAdd.{0 0 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (f n)) -> (Antitone.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.linearOrder)) _inst_1 f)
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.8560 : Preorder.{u} α] {f : Nat -> α}, (forall (n : Nat), LE.le.{u} α (Preorder.toLE.{u} α inst._@.Mathlib.Order.Monotone._hyg.8560) (f (HAdd.hAdd.{0 0 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (f n)) -> (Antitone.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.instLinearOrderNat)) inst._@.Mathlib.Order.Monotone._hyg.8560 f)
Case conversion may be inaccurate. Consider using '#align antitone_nat_of_succ_le antitone_nat_of_succ_leₓ'. -/
theorem antitone_nat_of_succ_le {f : ℕ → α} (hf : ∀ n, f (n + 1) ≤ f n) : Antitone f :=
  @monotone_nat_of_le_succ αᵒᵈ _ _ hf
#align antitone_nat_of_succ_le antitone_nat_of_succ_le

/- warning: strict_mono_nat_of_lt_succ -> strictMono_nat_of_lt_succ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] {f : Nat -> α}, (forall (n : Nat), LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) (f n) (f (HAdd.hAdd.{0 0 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) -> (StrictMono.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.linearOrder)) _inst_1 f)
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.8604 : Preorder.{u} α] {f : Nat -> α}, (forall (n : Nat), LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.8604) (f n) (f (HAdd.hAdd.{0 0 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) -> (StrictMono.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.instLinearOrderNat)) inst._@.Mathlib.Order.Monotone._hyg.8604 f)
Case conversion may be inaccurate. Consider using '#align strict_mono_nat_of_lt_succ strictMono_nat_of_lt_succₓ'. -/
theorem strictMono_nat_of_lt_succ {f : ℕ → α} (hf : ∀ n, f n < f (n + 1)) : StrictMono f :=
  Nat.rel_of_forall_rel_succ_of_lt (· < ·) hf
#align strict_mono_nat_of_lt_succ strictMono_nat_of_lt_succ

theorem strict_anti_nat_of_succ_lt {f : ℕ → α} (hf : ∀ n, f (n + 1) < f n) : StrictAnti f :=
  @strictMono_nat_of_lt_succ αᵒᵈ _ f hf
#align strict_anti_nat_of_succ_lt strict_anti_nat_of_succ_lt

namespace Nat

/- warning: nat.exists_strict_mono' -> Nat.exists_strictMono' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] [_inst_2 : NoMaxOrder.{u} α (Preorder.toLT.{u} α _inst_1)] (a : α), Exists.{(max 1 (succ u))} (Nat -> α) (fun (f : Nat -> α) => And (StrictMono.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.linearOrder)) _inst_1 f) (Eq.{succ u} α (f (OfNat.ofNat.{0} Nat 0 (OfNat.mk.{0} Nat 0 (Zero.zero.{0} Nat Nat.hasZero)))) a))
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.8702 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.8705 : NoMaxOrder.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.8702)] (a : α), Exists.{succ u} (Nat -> α) (fun (f : Nat -> α) => And (StrictMono.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.instLinearOrderNat)) inst._@.Mathlib.Order.Monotone._hyg.8702 f) (Eq.{succ u} α (f (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0))) a))
Case conversion may be inaccurate. Consider using '#align nat.exists_strict_mono' Nat.exists_strictMono'ₓ'. -/
/-- If `α` is a preorder with no maximal elements, then there exists a strictly monotone function
`ℕ → α` with any prescribed value of `f 0`. -/
theorem exists_strictMono' [NoMaxOrder α] (a : α) : ∃ f : ℕ → α, StrictMono f ∧ f 0 = a := by
  have := fun x : α => exists_gt x
  choose g hg
  exact ⟨fun n => Nat.recOn n a fun _ => g, strictMono_nat_of_lt_succ fun n => hg _, rfl⟩
#align nat.exists_strict_mono' Nat.exists_strictMono'

/- warning: nat.exists_strict_anti' -> Nat.exists_strictAnti' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] [_inst_2 : NoMinOrder.{u} α (Preorder.toLT.{u} α _inst_1)] (a : α), Exists.{(max 1 (succ u))} (Nat -> α) (fun (f : Nat -> α) => And (StrictAnti.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.linearOrder)) _inst_1 f) (Eq.{succ u} α (f (OfNat.ofNat.{0} Nat 0 (OfNat.mk.{0} Nat 0 (Zero.zero.{0} Nat Nat.hasZero)))) a))
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.8787 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.8790 : NoMinOrder.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.8787)] (a : α), Exists.{succ u} (Nat -> α) (fun (f : Nat -> α) => And (StrictAnti.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.instLinearOrderNat)) inst._@.Mathlib.Order.Monotone._hyg.8787 f) (Eq.{succ u} α (f (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0))) a))
Case conversion may be inaccurate. Consider using '#align nat.exists_strict_anti' Nat.exists_strictAnti'ₓ'. -/
/-- If `α` is a preorder with no maximal elements, then there exists a strictly antitone function
`ℕ → α` with any prescribed value of `f 0`. -/
theorem exists_strictAnti' [NoMinOrder α] (a : α) : ∃ f : ℕ → α, StrictAnti f ∧ f 0 = a :=
  exists_strictMono' (OrderDual.toDual a)
#align nat.exists_strict_anti' Nat.exists_strictAnti'

variable (α)

/- warning: nat.exists_strict_mono -> Nat.exists_strictMono is a dubious translation:
lean 3 declaration is
  forall (α : Type.{u}) [_inst_1 : Preorder.{u} α] [_inst_2 : Nonempty.{succ u} α] [_inst_3 : NoMaxOrder.{u} α (Preorder.toLT.{u} α _inst_1)], Exists.{(max 1 (succ u))} (Nat -> α) (fun (f : Nat -> α) => StrictMono.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.linearOrder)) _inst_1 f)
but is expected to have type
  forall (α : Type.{u}) [inst._@.Mathlib.Order.Monotone._hyg.8847 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.8850 : Nonempty.{succ u} α] [inst._@.Mathlib.Order.Monotone._hyg.8853 : NoMaxOrder.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.8847)], Exists.{succ u} (Nat -> α) (fun (f : Nat -> α) => StrictMono.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.instLinearOrderNat)) inst._@.Mathlib.Order.Monotone._hyg.8847 f)
Case conversion may be inaccurate. Consider using '#align nat.exists_strict_mono Nat.exists_strictMonoₓ'. -/
/-- If `α` is a nonempty preorder with no maximal elements, then there exists a strictly monotone
function `ℕ → α`. -/
theorem exists_strictMono [Nonempty α] [NoMaxOrder α] : ∃ f : ℕ → α, StrictMono f :=
  let ⟨a⟩ := ‹Nonempty α›
  let ⟨f, hf, hfa⟩ := exists_strictMono' a
  ⟨f, hf⟩
#align nat.exists_strict_mono Nat.exists_strictMono

/- warning: nat.exists_strict_anti -> Nat.exists_strictAnti is a dubious translation:
lean 3 declaration is
  forall (α : Type.{u}) [_inst_1 : Preorder.{u} α] [_inst_2 : Nonempty.{succ u} α] [_inst_3 : NoMinOrder.{u} α (Preorder.toLT.{u} α _inst_1)], Exists.{(max 1 (succ u))} (Nat -> α) (fun (f : Nat -> α) => StrictAnti.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.linearOrder)) _inst_1 f)
but is expected to have type
  forall (α : Type.{u}) [inst._@.Mathlib.Order.Monotone._hyg.8936 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.8939 : Nonempty.{succ u} α] [inst._@.Mathlib.Order.Monotone._hyg.8942 : NoMinOrder.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.8936)], Exists.{succ u} (Nat -> α) (fun (f : Nat -> α) => StrictAnti.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.instLinearOrderNat)) inst._@.Mathlib.Order.Monotone._hyg.8936 f)
Case conversion may be inaccurate. Consider using '#align nat.exists_strict_anti Nat.exists_strictAntiₓ'. -/
/-- If `α` is a nonempty preorder with no minimal elements, then there exists a strictly antitone
function `ℕ → α`. -/
theorem exists_strictAnti [Nonempty α] [NoMinOrder α] : ∃ f : ℕ → α, StrictAnti f :=
  exists_strictMono αᵒᵈ
#align nat.exists_strict_anti Nat.exists_strictAnti

end Nat

#print Int.rel_of_forall_rel_succ_of_lt /-
theorem Int.rel_of_forall_rel_succ_of_lt (r : β → β → Prop) [IsTrans β r] {f : ℤ → β} (h : ∀ n, r (f n) (f (n + 1)))
    ⦃a b : ℤ⦄ (hab : a < b) : r (f a) (f b) := by
  rcases hab.dest with ⟨n, rfl⟩
  clear hab
  induction' n with n ihn
  · rw [Int.ofNat_one]
    apply h
    
  · rw [Int.ofNat_succ, ← Int.add_assoc]
    exact trans ihn (h _)
    
#align int.rel_of_forall_rel_succ_of_lt Int.rel_of_forall_rel_succ_of_lt
-/

#print Int.rel_of_forall_rel_succ_of_le /-
theorem Int.rel_of_forall_rel_succ_of_le (r : β → β → Prop) [IsRefl β r] [IsTrans β r] {f : ℤ → β}
    (h : ∀ n, r (f n) (f (n + 1))) ⦃a b : ℤ⦄ (hab : a ≤ b) : r (f a) (f b) :=
  hab.eq_or_lt.elim (fun h => h ▸ refl _) fun h' => Int.rel_of_forall_rel_succ_of_lt r h h'
#align int.rel_of_forall_rel_succ_of_le Int.rel_of_forall_rel_succ_of_le
-/

/- warning: monotone_int_of_le_succ -> monotone_int_of_le_succ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] {f : Int -> α}, (forall (n : Int), LE.le.{u} α (Preorder.toLE.{u} α _inst_1) (f n) (f (HAdd.hAdd.{0 0 0} Int Int Int (instHAdd.{0} Int Int.hasAdd) n (OfNat.ofNat.{0} Int 1 (OfNat.mk.{0} Int 1 (One.one.{0} Int Int.hasOne)))))) -> (Monotone.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.linearOrder)) _inst_1 f)
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.9232 : Preorder.{u} α] {f : Int -> α}, (forall (n : Int), LE.le.{u} α (Preorder.toLE.{u} α inst._@.Mathlib.Order.Monotone._hyg.9232) (f n) (f (HAdd.hAdd.{0 0 0} Int Int Int (instHAdd.{0} Int Int.instAddInt) n (OfNat.ofNat.{0} Int 1 (instOfNatInt 1))))) -> (Monotone.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.instLinearOrderInt)) inst._@.Mathlib.Order.Monotone._hyg.9232 f)
Case conversion may be inaccurate. Consider using '#align monotone_int_of_le_succ monotone_int_of_le_succₓ'. -/
theorem monotone_int_of_le_succ {f : ℤ → α} (hf : ∀ n, f n ≤ f (n + 1)) : Monotone f :=
  Int.rel_of_forall_rel_succ_of_le (· ≤ ·) hf
#align monotone_int_of_le_succ monotone_int_of_le_succ

/- warning: antitone_int_of_succ_le -> antitone_int_of_succ_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] {f : Int -> α}, (forall (n : Int), LE.le.{u} α (Preorder.toLE.{u} α _inst_1) (f (HAdd.hAdd.{0 0 0} Int Int Int (instHAdd.{0} Int Int.hasAdd) n (OfNat.ofNat.{0} Int 1 (OfNat.mk.{0} Int 1 (One.one.{0} Int Int.hasOne))))) (f n)) -> (Antitone.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.linearOrder)) _inst_1 f)
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.9285 : Preorder.{u} α] {f : Int -> α}, (forall (n : Int), LE.le.{u} α (Preorder.toLE.{u} α inst._@.Mathlib.Order.Monotone._hyg.9285) (f (HAdd.hAdd.{0 0 0} Int Int Int (instHAdd.{0} Int Int.instAddInt) n (OfNat.ofNat.{0} Int 1 (instOfNatInt 1)))) (f n)) -> (Antitone.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.instLinearOrderInt)) inst._@.Mathlib.Order.Monotone._hyg.9285 f)
Case conversion may be inaccurate. Consider using '#align antitone_int_of_succ_le antitone_int_of_succ_leₓ'. -/
theorem antitone_int_of_succ_le {f : ℤ → α} (hf : ∀ n, f (n + 1) ≤ f n) : Antitone f :=
  Int.rel_of_forall_rel_succ_of_le (· ≥ ·) hf
#align antitone_int_of_succ_le antitone_int_of_succ_le

/- warning: strict_mono_int_of_lt_succ -> strictMono_int_of_lt_succ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] {f : Int -> α}, (forall (n : Int), LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) (f n) (f (HAdd.hAdd.{0 0 0} Int Int Int (instHAdd.{0} Int Int.hasAdd) n (OfNat.ofNat.{0} Int 1 (OfNat.mk.{0} Int 1 (One.one.{0} Int Int.hasOne)))))) -> (StrictMono.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.linearOrder)) _inst_1 f)
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.9338 : Preorder.{u} α] {f : Int -> α}, (forall (n : Int), LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9338) (f n) (f (HAdd.hAdd.{0 0 0} Int Int Int (instHAdd.{0} Int Int.instAddInt) n (OfNat.ofNat.{0} Int 1 (instOfNatInt 1))))) -> (StrictMono.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.instLinearOrderInt)) inst._@.Mathlib.Order.Monotone._hyg.9338 f)
Case conversion may be inaccurate. Consider using '#align strict_mono_int_of_lt_succ strictMono_int_of_lt_succₓ'. -/
theorem strictMono_int_of_lt_succ {f : ℤ → α} (hf : ∀ n, f n < f (n + 1)) : StrictMono f :=
  Int.rel_of_forall_rel_succ_of_lt (· < ·) hf
#align strict_mono_int_of_lt_succ strictMono_int_of_lt_succ

/- warning: strict_anti_int_of_succ_lt -> strictAnti_int_of_succ_lt is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] {f : Int -> α}, (forall (n : Int), LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) (f (HAdd.hAdd.{0 0 0} Int Int Int (instHAdd.{0} Int Int.hasAdd) n (OfNat.ofNat.{0} Int 1 (OfNat.mk.{0} Int 1 (One.one.{0} Int Int.hasOne))))) (f n)) -> (StrictAnti.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.linearOrder)) _inst_1 f)
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.9392 : Preorder.{u} α] {f : Int -> α}, (forall (n : Int), LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9392) (f (HAdd.hAdd.{0 0 0} Int Int Int (instHAdd.{0} Int Int.instAddInt) n (OfNat.ofNat.{0} Int 1 (instOfNatInt 1)))) (f n)) -> (StrictAnti.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.instLinearOrderInt)) inst._@.Mathlib.Order.Monotone._hyg.9392 f)
Case conversion may be inaccurate. Consider using '#align strict_anti_int_of_succ_lt strictAnti_int_of_succ_ltₓ'. -/
theorem strictAnti_int_of_succ_lt {f : ℤ → α} (hf : ∀ n, f (n + 1) < f n) : StrictAnti f :=
  Int.rel_of_forall_rel_succ_of_lt (· > ·) hf
#align strict_anti_int_of_succ_lt strictAnti_int_of_succ_lt

namespace Int

variable (α) [Nonempty α] [NoMinOrder α] [NoMaxOrder α]

/- warning: int.exists_strict_mono -> Int.exists_strictMono is a dubious translation:
lean 3 declaration is
  forall (α : Type.{u}) [_inst_1 : Preorder.{u} α] [_inst_2 : Nonempty.{succ u} α] [_inst_3 : NoMinOrder.{u} α (Preorder.toLT.{u} α _inst_1)] [_inst_4 : NoMaxOrder.{u} α (Preorder.toLT.{u} α _inst_1)], Exists.{(max 1 (succ u))} (Int -> α) (fun (f : Int -> α) => StrictMono.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.linearOrder)) _inst_1 f)
but is expected to have type
  forall (α : Type.{u}) [inst._@.Mathlib.Order.Monotone._hyg.9480 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.9483 : Nonempty.{succ u} α] [inst._@.Mathlib.Order.Monotone._hyg.9486 : NoMinOrder.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9480)] [inst._@.Mathlib.Order.Monotone._hyg.9489 : NoMaxOrder.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9480)], Exists.{succ u} (Int -> α) (fun (f : Int -> α) => StrictMono.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.instLinearOrderInt)) inst._@.Mathlib.Order.Monotone._hyg.9480 f)
Case conversion may be inaccurate. Consider using '#align int.exists_strict_mono Int.exists_strictMonoₓ'. -/
/-- If `α` is a nonempty preorder with no minimal or maximal elements, then there exists a strictly
monotone function `f : ℤ → α`. -/
theorem exists_strictMono : ∃ f : ℤ → α, StrictMono f := by
  inhabit α
  rcases Nat.exists_strictMono' (default : α) with ⟨f, hf, hf₀⟩
  rcases Nat.exists_strictAnti' (default : α) with ⟨g, hg, hg₀⟩
  refine' ⟨fun n => Int.casesOn n f fun n => g (n + 1), strictMono_int_of_lt_succ _⟩
  rintro (n | _ | n)
  · exact hf n.lt_succ_self
    
  · show g 1 < f 0
    rw [hf₀, ← hg₀]
    exact hg Nat.zero_lt_one
    
  · exact hg (Nat.lt_succ_self _)
    
#align int.exists_strict_mono Int.exists_strictMono

/- warning: int.exists_strict_anti -> Int.exists_strictAnti is a dubious translation:
lean 3 declaration is
  forall (α : Type.{u}) [_inst_1 : Preorder.{u} α] [_inst_2 : Nonempty.{succ u} α] [_inst_3 : NoMinOrder.{u} α (Preorder.toLT.{u} α _inst_1)] [_inst_4 : NoMaxOrder.{u} α (Preorder.toLT.{u} α _inst_1)], Exists.{(max 1 (succ u))} (Int -> α) (fun (f : Int -> α) => StrictAnti.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.linearOrder)) _inst_1 f)
but is expected to have type
  forall (α : Type.{u}) [inst._@.Mathlib.Order.Monotone._hyg.9648 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.9651 : Nonempty.{succ u} α] [inst._@.Mathlib.Order.Monotone._hyg.9654 : NoMinOrder.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9648)] [inst._@.Mathlib.Order.Monotone._hyg.9657 : NoMaxOrder.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9648)], Exists.{succ u} (Int -> α) (fun (f : Int -> α) => StrictAnti.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.instLinearOrderInt)) inst._@.Mathlib.Order.Monotone._hyg.9648 f)
Case conversion may be inaccurate. Consider using '#align int.exists_strict_anti Int.exists_strictAntiₓ'. -/
/-- If `α` is a nonempty preorder with no minimal or maximal elements, then there exists a strictly
antitone function `f : ℤ → α`. -/
theorem exists_strictAnti : ∃ f : ℤ → α, StrictAnti f :=
  exists_strictMono αᵒᵈ
#align int.exists_strict_anti Int.exists_strictAnti

end Int

/- warning: monotone.ne_of_lt_of_lt_nat -> Monotone.ne_of_lt_of_lt_nat is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] {f : Nat -> α}, (Monotone.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.linearOrder)) _inst_1 f) -> (forall (n : Nat) {x : α}, (LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) (f n) x) -> (LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) x (f (HAdd.hAdd.{0 0 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) -> (forall (a : Nat), Ne.{succ u} α (f a) x))
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.9694 : Preorder.{u} α] {f : Nat -> α}, (Monotone.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.instLinearOrderNat)) inst._@.Mathlib.Order.Monotone._hyg.9694 f) -> (forall (n : Nat) {x : α}, (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9694) (f n) x) -> (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9694) x (f (HAdd.hAdd.{0 0 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) -> (forall (a : Nat), Ne.{succ u} α (f a) x))
Case conversion may be inaccurate. Consider using '#align monotone.ne_of_lt_of_lt_nat Monotone.ne_of_lt_of_lt_natₓ'. -/
-- TODO@Yael: Generalize the following four to succ orders
/-- If `f` is a monotone function from `ℕ` to a preorder such that `x` lies between `f n` and
  `f (n + 1)`, then `x` doesn't lie in the range of `f`. -/
theorem Monotone.ne_of_lt_of_lt_nat {f : ℕ → α} (hf : Monotone f) (n : ℕ) {x : α} (h1 : f n < x) (h2 : x < f (n + 1))
    (a : ℕ) : f a ≠ x := by
  rintro rfl
  exact (hf.reflect_lt h1).not_le (Nat.le_of_lt_succ <| hf.reflect_lt h2)
#align monotone.ne_of_lt_of_lt_nat Monotone.ne_of_lt_of_lt_nat

/- warning: antitone.ne_of_lt_of_lt_nat -> Antitone.ne_of_lt_of_lt_nat is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] {f : Nat -> α}, (Antitone.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.linearOrder)) _inst_1 f) -> (forall (n : Nat) {x : α}, (LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) (f (HAdd.hAdd.{0 0 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) x) -> (LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) x (f n)) -> (forall (a : Nat), Ne.{succ u} α (f a) x))
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.9767 : Preorder.{u} α] {f : Nat -> α}, (Antitone.{0 u} Nat α (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.instLinearOrderNat)) inst._@.Mathlib.Order.Monotone._hyg.9767 f) -> (forall (n : Nat) {x : α}, (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9767) (f (HAdd.hAdd.{0 0 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) x) -> (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9767) x (f n)) -> (forall (a : Nat), Ne.{succ u} α (f a) x))
Case conversion may be inaccurate. Consider using '#align antitone.ne_of_lt_of_lt_nat Antitone.ne_of_lt_of_lt_natₓ'. -/
/-- If `f` is an antitone function from `ℕ` to a preorder such that `x` lies between `f (n + 1)` and
`f n`, then `x` doesn't lie in the range of `f`. -/
theorem Antitone.ne_of_lt_of_lt_nat {f : ℕ → α} (hf : Antitone f) (n : ℕ) {x : α} (h1 : f (n + 1) < x) (h2 : x < f n)
    (a : ℕ) : f a ≠ x := by
  rintro rfl
  exact (hf.reflect_lt h2).not_le (Nat.le_of_lt_succ <| hf.reflect_lt h1)
#align antitone.ne_of_lt_of_lt_nat Antitone.ne_of_lt_of_lt_nat

/- warning: monotone.ne_of_lt_of_lt_int -> Monotone.ne_of_lt_of_lt_int is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] {f : Int -> α}, (Monotone.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.linearOrder)) _inst_1 f) -> (forall (n : Int) {x : α}, (LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) (f n) x) -> (LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) x (f (HAdd.hAdd.{0 0 0} Int Int Int (instHAdd.{0} Int Int.hasAdd) n (OfNat.ofNat.{0} Int 1 (OfNat.mk.{0} Int 1 (One.one.{0} Int Int.hasOne)))))) -> (forall (a : Int), Ne.{succ u} α (f a) x))
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.9840 : Preorder.{u} α] {f : Int -> α}, (Monotone.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.instLinearOrderInt)) inst._@.Mathlib.Order.Monotone._hyg.9840 f) -> (forall (n : Int) {x : α}, (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9840) (f n) x) -> (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9840) x (f (HAdd.hAdd.{0 0 0} Int Int Int (instHAdd.{0} Int Int.instAddInt) n (OfNat.ofNat.{0} Int 1 (instOfNatInt 1))))) -> (forall (a : Int), Ne.{succ u} α (f a) x))
Case conversion may be inaccurate. Consider using '#align monotone.ne_of_lt_of_lt_int Monotone.ne_of_lt_of_lt_intₓ'. -/
/-- If `f` is a monotone function from `ℤ` to a preorder and `x` lies between `f n` and
  `f (n + 1)`, then `x` doesn't lie in the range of `f`. -/
theorem Monotone.ne_of_lt_of_lt_int {f : ℤ → α} (hf : Monotone f) (n : ℤ) {x : α} (h1 : f n < x) (h2 : x < f (n + 1))
    (a : ℤ) : f a ≠ x := by
  rintro rfl
  exact (hf.reflect_lt h1).not_le (Int.le_of_lt_add_one <| hf.reflect_lt h2)
#align monotone.ne_of_lt_of_lt_int Monotone.ne_of_lt_of_lt_int

/- warning: antitone.ne_of_lt_of_lt_int -> Antitone.ne_of_lt_of_lt_int is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : Preorder.{u} α] {f : Int -> α}, (Antitone.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.linearOrder)) _inst_1 f) -> (forall (n : Int) {x : α}, (LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) (f (HAdd.hAdd.{0 0 0} Int Int Int (instHAdd.{0} Int Int.hasAdd) n (OfNat.ofNat.{0} Int 1 (OfNat.mk.{0} Int 1 (One.one.{0} Int Int.hasOne))))) x) -> (LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) x (f n)) -> (forall (a : Int), Ne.{succ u} α (f a) x))
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Monotone._hyg.9913 : Preorder.{u} α] {f : Int -> α}, (Antitone.{0 u} Int α (PartialOrder.toPreorder.{0} Int (LinearOrder.toPartialOrder.{0} Int Int.instLinearOrderInt)) inst._@.Mathlib.Order.Monotone._hyg.9913 f) -> (forall (n : Int) {x : α}, (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9913) (f (HAdd.hAdd.{0 0 0} Int Int Int (instHAdd.{0} Int Int.instAddInt) n (OfNat.ofNat.{0} Int 1 (instOfNatInt 1)))) x) -> (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Monotone._hyg.9913) x (f n)) -> (forall (a : Int), Ne.{succ u} α (f a) x))
Case conversion may be inaccurate. Consider using '#align antitone.ne_of_lt_of_lt_int Antitone.ne_of_lt_of_lt_intₓ'. -/
/-- If `f` is an antitone function from `ℤ` to a preorder and `x` lies between `f (n + 1)` and
`f n`, then `x` doesn't lie in the range of `f`. -/
theorem Antitone.ne_of_lt_of_lt_int {f : ℤ → α} (hf : Antitone f) (n : ℤ) {x : α} (h1 : f (n + 1) < x) (h2 : x < f n)
    (a : ℤ) : f a ≠ x := by
  rintro rfl
  exact (hf.reflect_lt h2).not_le (Int.le_of_lt_add_one <| hf.reflect_lt h1)
#align antitone.ne_of_lt_of_lt_int Antitone.ne_of_lt_of_lt_int

/- warning: strict_mono.id_le -> StrictMono.id_le is a dubious translation:
lean 3 declaration is
  forall {φ : Nat -> Nat}, (StrictMono.{0 0} Nat Nat (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.linearOrder)) (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.linearOrder)) φ) -> (forall (n : Nat), LE.le.{0} Nat Nat.hasLe n (φ n))
but is expected to have type
  forall {φ : Nat -> Nat}, (StrictMono.{0 0} Nat Nat (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.instLinearOrderNat)) (PartialOrder.toPreorder.{0} Nat (LinearOrder.toPartialOrder.{0} Nat Nat.instLinearOrderNat)) φ) -> (forall (n : Nat), LE.le.{0} Nat instLENat n (φ n))
Case conversion may be inaccurate. Consider using '#align strict_mono.id_le StrictMono.id_leₓ'. -/
theorem StrictMono.id_le {φ : ℕ → ℕ} (h : StrictMono φ) : ∀ n, n ≤ φ n := fun n =>
  Nat.recOn n (Nat.zero_le _) fun n hn => Nat.succ_le_of_lt (hn.trans_lt <| h <| Nat.lt_succ_self n)
#align strict_mono.id_le StrictMono.id_le

end Preorder

#print Subtype.mono_coe /-
theorem Subtype.mono_coe [Preorder α] (t : Set α) : Monotone (coe : Subtype t → α) := fun x y => id
#align subtype.mono_coe Subtype.mono_coe
-/

#print Subtype.strictMono_coe /-
theorem Subtype.strictMono_coe [Preorder α] (t : Set α) : StrictMono (coe : Subtype t → α) := fun x y => id
#align subtype.strict_mono_coe Subtype.strictMono_coe
-/

section Preorder

variable [Preorder α] [Preorder β] [Preorder γ] [Preorder δ] {f : α → γ} {g : β → δ} {a b : α}

/- warning: monotone_fst -> monotone_fst is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{v} β], Monotone.{(max u v) u} (Prod.{u v} α β) α (Prod.preorder.{u v} α β _inst_1 _inst_2) _inst_1 (Prod.fst.{u v} α β)
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} [inst._@.Mathlib.Order.Monotone._hyg.10174 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.10177 : Preorder.{v} β], Monotone.{(max u v) u} (Prod.{u v} α β) α (Prod.instPreorderProd.{u v} α β inst._@.Mathlib.Order.Monotone._hyg.10174 inst._@.Mathlib.Order.Monotone._hyg.10177) inst._@.Mathlib.Order.Monotone._hyg.10174 (Prod.fst.{u v} α β)
Case conversion may be inaccurate. Consider using '#align monotone_fst monotone_fstₓ'. -/
theorem monotone_fst : Monotone (@Prod.fst α β) := fun a b => And.left
#align monotone_fst monotone_fst

/- warning: monotone_snd -> monotone_snd is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{v} β], Monotone.{(max u v) v} (Prod.{u v} α β) β (Prod.preorder.{u v} α β _inst_1 _inst_2) _inst_2 (Prod.snd.{u v} α β)
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} [inst._@.Mathlib.Order.Monotone._hyg.10219 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.10222 : Preorder.{v} β], Monotone.{(max u v) v} (Prod.{u v} α β) β (Prod.instPreorderProd.{u v} α β inst._@.Mathlib.Order.Monotone._hyg.10219 inst._@.Mathlib.Order.Monotone._hyg.10222) inst._@.Mathlib.Order.Monotone._hyg.10222 (Prod.snd.{u v} α β)
Case conversion may be inaccurate. Consider using '#align monotone_snd monotone_sndₓ'. -/
theorem monotone_snd : Monotone (@Prod.snd α β) := fun a b => And.right
#align monotone_snd monotone_snd

/- warning: monotone.prod_map -> Monotone.prod_map is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} {δ : Type.{u_1}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{v} β] [_inst_3 : Preorder.{w} γ] [_inst_4 : Preorder.{u_1} δ] {f : α -> γ} {g : β -> δ}, (Monotone.{u w} α γ _inst_1 _inst_3 f) -> (Monotone.{v u_1} β δ _inst_2 _inst_4 g) -> (Monotone.{(max u v) (max w u_1)} (Prod.{u v} α β) (Prod.{w u_1} γ δ) (Prod.preorder.{u v} α β _inst_1 _inst_2) (Prod.preorder.{w u_1} γ δ _inst_3 _inst_4) (Prod.map.{u w v u_1} α γ β δ f g))
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} {δ : Type.{u_1}} [inst._@.Mathlib.Order.Monotone._hyg.10267 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.10270 : Preorder.{v} β] [inst._@.Mathlib.Order.Monotone._hyg.10273 : Preorder.{w} γ] [inst._@.Mathlib.Order.Monotone._hyg.10276 : Preorder.{u_1} δ] {f : α -> γ} {g : β -> δ}, (Monotone.{u w} α γ inst._@.Mathlib.Order.Monotone._hyg.10267 inst._@.Mathlib.Order.Monotone._hyg.10273 f) -> (Monotone.{v u_1} β δ inst._@.Mathlib.Order.Monotone._hyg.10270 inst._@.Mathlib.Order.Monotone._hyg.10276 g) -> (Monotone.{(max v u) (max u_1 w)} (Prod.{u v} α β) (Prod.{w u_1} γ δ) (Prod.instPreorderProd.{u v} α β inst._@.Mathlib.Order.Monotone._hyg.10267 inst._@.Mathlib.Order.Monotone._hyg.10270) (Prod.instPreorderProd.{w u_1} γ δ inst._@.Mathlib.Order.Monotone._hyg.10273 inst._@.Mathlib.Order.Monotone._hyg.10276) (Prod.map.{u w v u_1} α γ β δ f g))
Case conversion may be inaccurate. Consider using '#align monotone.prod_map Monotone.prod_mapₓ'. -/
theorem Monotone.prod_map (hf : Monotone f) (hg : Monotone g) : Monotone (Prod.map f g) := fun a b h => ⟨hf h.1, hg h.2⟩
#align monotone.prod_map Monotone.prod_map

/- warning: antitone.prod_map -> Antitone.prod_map is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} {δ : Type.{u_1}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{v} β] [_inst_3 : Preorder.{w} γ] [_inst_4 : Preorder.{u_1} δ] {f : α -> γ} {g : β -> δ}, (Antitone.{u w} α γ _inst_1 _inst_3 f) -> (Antitone.{v u_1} β δ _inst_2 _inst_4 g) -> (Antitone.{(max u v) (max w u_1)} (Prod.{u v} α β) (Prod.{w u_1} γ δ) (Prod.preorder.{u v} α β _inst_1 _inst_2) (Prod.preorder.{w u_1} γ δ _inst_3 _inst_4) (Prod.map.{u w v u_1} α γ β δ f g))
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} {δ : Type.{u_1}} [inst._@.Mathlib.Order.Monotone._hyg.10326 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.10329 : Preorder.{v} β] [inst._@.Mathlib.Order.Monotone._hyg.10332 : Preorder.{w} γ] [inst._@.Mathlib.Order.Monotone._hyg.10335 : Preorder.{u_1} δ] {f : α -> γ} {g : β -> δ}, (Antitone.{u w} α γ inst._@.Mathlib.Order.Monotone._hyg.10326 inst._@.Mathlib.Order.Monotone._hyg.10332 f) -> (Antitone.{v u_1} β δ inst._@.Mathlib.Order.Monotone._hyg.10329 inst._@.Mathlib.Order.Monotone._hyg.10335 g) -> (Antitone.{(max v u) (max u_1 w)} (Prod.{u v} α β) (Prod.{w u_1} γ δ) (Prod.instPreorderProd.{u v} α β inst._@.Mathlib.Order.Monotone._hyg.10326 inst._@.Mathlib.Order.Monotone._hyg.10329) (Prod.instPreorderProd.{w u_1} γ δ inst._@.Mathlib.Order.Monotone._hyg.10332 inst._@.Mathlib.Order.Monotone._hyg.10335) (Prod.map.{u w v u_1} α γ β δ f g))
Case conversion may be inaccurate. Consider using '#align antitone.prod_map Antitone.prod_mapₓ'. -/
theorem Antitone.prod_map (hf : Antitone f) (hg : Antitone g) : Antitone (Prod.map f g) := fun a b h => ⟨hf h.1, hg h.2⟩
#align antitone.prod_map Antitone.prod_map

end Preorder

section PartialOrder

variable [PartialOrder α] [PartialOrder β] [Preorder γ] [Preorder δ] {f : α → γ} {g : β → δ}

/- warning: strict_mono.prod_map -> StrictMono.prod_map is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} {δ : Type.{u_1}} [_inst_1 : PartialOrder.{u} α] [_inst_2 : PartialOrder.{v} β] [_inst_3 : Preorder.{w} γ] [_inst_4 : Preorder.{u_1} δ] {f : α -> γ} {g : β -> δ}, (StrictMono.{u w} α γ (PartialOrder.toPreorder.{u} α _inst_1) _inst_3 f) -> (StrictMono.{v u_1} β δ (PartialOrder.toPreorder.{v} β _inst_2) _inst_4 g) -> (StrictMono.{(max u v) (max w u_1)} (Prod.{u v} α β) (Prod.{w u_1} γ δ) (Prod.preorder.{u v} α β (PartialOrder.toPreorder.{u} α _inst_1) (PartialOrder.toPreorder.{v} β _inst_2)) (Prod.preorder.{w u_1} γ δ _inst_3 _inst_4) (Prod.map.{u w v u_1} α γ β δ f g))
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} {δ : Type.{u_1}} [inst._@.Mathlib.Order.Monotone._hyg.10421 : PartialOrder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.10424 : PartialOrder.{v} β] [inst._@.Mathlib.Order.Monotone._hyg.10427 : Preorder.{w} γ] [inst._@.Mathlib.Order.Monotone._hyg.10430 : Preorder.{u_1} δ] {f : α -> γ} {g : β -> δ}, (StrictMono.{u w} α γ (PartialOrder.toPreorder.{u} α inst._@.Mathlib.Order.Monotone._hyg.10421) inst._@.Mathlib.Order.Monotone._hyg.10427 f) -> (StrictMono.{v u_1} β δ (PartialOrder.toPreorder.{v} β inst._@.Mathlib.Order.Monotone._hyg.10424) inst._@.Mathlib.Order.Monotone._hyg.10430 g) -> (StrictMono.{(max v u) (max u_1 w)} (Prod.{u v} α β) (Prod.{w u_1} γ δ) (Prod.instPreorderProd.{u v} α β (PartialOrder.toPreorder.{u} α inst._@.Mathlib.Order.Monotone._hyg.10421) (PartialOrder.toPreorder.{v} β inst._@.Mathlib.Order.Monotone._hyg.10424)) (Prod.instPreorderProd.{w u_1} γ δ inst._@.Mathlib.Order.Monotone._hyg.10427 inst._@.Mathlib.Order.Monotone._hyg.10430) (Prod.map.{u w v u_1} α γ β δ f g))
Case conversion may be inaccurate. Consider using '#align strict_mono.prod_map StrictMono.prod_mapₓ'. -/
theorem StrictMono.prod_map (hf : StrictMono f) (hg : StrictMono g) : StrictMono (Prod.map f g) := fun a b => by
  simp_rw [Prod.lt_iff]
  exact Or.imp (And.imp hf.imp hg.monotone.imp) (And.imp hf.monotone.imp hg.imp)
#align strict_mono.prod_map StrictMono.prod_map

/- warning: strict_anti.prod_map -> StrictAnti.prod_map is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} {δ : Type.{u_1}} [_inst_1 : PartialOrder.{u} α] [_inst_2 : PartialOrder.{v} β] [_inst_3 : Preorder.{w} γ] [_inst_4 : Preorder.{u_1} δ] {f : α -> γ} {g : β -> δ}, (StrictAnti.{u w} α γ (PartialOrder.toPreorder.{u} α _inst_1) _inst_3 f) -> (StrictAnti.{v u_1} β δ (PartialOrder.toPreorder.{v} β _inst_2) _inst_4 g) -> (StrictAnti.{(max u v) (max w u_1)} (Prod.{u v} α β) (Prod.{w u_1} γ δ) (Prod.preorder.{u v} α β (PartialOrder.toPreorder.{u} α _inst_1) (PartialOrder.toPreorder.{v} β _inst_2)) (Prod.preorder.{w u_1} γ δ _inst_3 _inst_4) (Prod.map.{u w v u_1} α γ β δ f g))
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} {γ : Type.{w}} {δ : Type.{u_1}} [inst._@.Mathlib.Order.Monotone._hyg.10485 : PartialOrder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.10488 : PartialOrder.{v} β] [inst._@.Mathlib.Order.Monotone._hyg.10491 : Preorder.{w} γ] [inst._@.Mathlib.Order.Monotone._hyg.10494 : Preorder.{u_1} δ] {f : α -> γ} {g : β -> δ}, (StrictAnti.{u w} α γ (PartialOrder.toPreorder.{u} α inst._@.Mathlib.Order.Monotone._hyg.10485) inst._@.Mathlib.Order.Monotone._hyg.10491 f) -> (StrictAnti.{v u_1} β δ (PartialOrder.toPreorder.{v} β inst._@.Mathlib.Order.Monotone._hyg.10488) inst._@.Mathlib.Order.Monotone._hyg.10494 g) -> (StrictAnti.{(max v u) (max u_1 w)} (Prod.{u v} α β) (Prod.{w u_1} γ δ) (Prod.instPreorderProd.{u v} α β (PartialOrder.toPreorder.{u} α inst._@.Mathlib.Order.Monotone._hyg.10485) (PartialOrder.toPreorder.{v} β inst._@.Mathlib.Order.Monotone._hyg.10488)) (Prod.instPreorderProd.{w u_1} γ δ inst._@.Mathlib.Order.Monotone._hyg.10491 inst._@.Mathlib.Order.Monotone._hyg.10494) (Prod.map.{u w v u_1} α γ β δ f g))
Case conversion may be inaccurate. Consider using '#align strict_anti.prod_map StrictAnti.prod_mapₓ'. -/
theorem StrictAnti.prod_map (hf : StrictAnti f) (hg : StrictAnti g) : StrictAnti (Prod.map f g) := fun a b => by
  simp_rw [Prod.lt_iff]
  exact Or.imp (And.imp hf.imp hg.antitone.imp) (And.imp hf.antitone.imp hg.imp)
#align strict_anti.prod_map StrictAnti.prod_map

end PartialOrder

namespace Function

variable [Preorder α]

/- warning: function.const_mono -> Function.const_mono is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} [_inst_1 : Preorder.{u} α], Monotone.{u (max v u)} α (β -> α) _inst_1 (Pi.preorder.{v u} β (fun (ᾰ : β) => α) (fun (i : β) => _inst_1)) (Function.const.{succ u succ v} α β)
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} [inst._@.Mathlib.Order.Monotone._hyg.10562 : Preorder.{u} α], Monotone.{u (max u v)} α (β -> α) inst._@.Mathlib.Order.Monotone._hyg.10562 (instPreorderForAll.{v u} β (fun (a._@.Init.Prelude._hyg.54 : β) => α) (fun (i : β) => inst._@.Mathlib.Order.Monotone._hyg.10562)) (Function.const.{succ u succ v} α β)
Case conversion may be inaccurate. Consider using '#align function.const_mono Function.const_monoₓ'. -/
theorem const_mono : Monotone (const β : α → β → α) := fun a b h i => h
#align function.const_mono Function.const_mono

/- warning: function.const_strict_mono -> Function.const_strictMono is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} [_inst_1 : Preorder.{u} α] [_inst_2 : Nonempty.{succ v} β], StrictMono.{u (max v u)} α (β -> α) _inst_1 (Pi.preorder.{v u} β (fun (ᾰ : β) => α) (fun (i : β) => _inst_1)) (Function.const.{succ u succ v} α β)
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} [inst._@.Mathlib.Order.Monotone._hyg.10597 : Preorder.{u} α] [inst._@.Mathlib.Order.Monotone._hyg.10600 : Nonempty.{succ v} β], StrictMono.{u (max u v)} α (β -> α) inst._@.Mathlib.Order.Monotone._hyg.10597 (instPreorderForAll.{v u} β (fun (a._@.Init.Prelude._hyg.54 : β) => α) (fun (i : β) => inst._@.Mathlib.Order.Monotone._hyg.10597)) (Function.const.{succ u succ v} α β)
Case conversion may be inaccurate. Consider using '#align function.const_strict_mono Function.const_strictMonoₓ'. -/
theorem const_strictMono [Nonempty β] : StrictMono (const β : α → β → α) := fun a b => const_lt_const.2
#align function.const_strict_mono Function.const_strictMono

end Function

