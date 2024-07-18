/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro, Floris van Doorn
-/
import Data.Fintype.BigOperators
import Data.Finsupp.Defs
import Data.Nat.PartENat
import Data.Set.Countable
import Logic.Small.Defs
import Order.ConditionallyCompleteLattice.Basic
import Order.SuccPred.Limit
import SetTheory.Cardinal.SchroederBernstein
import Tactic.Positivity

#align_import set_theory.cardinal.basic from "leanprover-community/mathlib"@"3ff3f2d6a3118b8711063de7111a0d77a53219a8"

/-!
# Cardinal Numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define cardinal numbers as a quotient of types under the equivalence relation of equinumerity.

## Main definitions

* `cardinal` the type of cardinal numbers (in a given universe).
* `cardinal.mk α` or `#α` is the cardinality of `α`. The notation `#` lives in the locale
  `cardinal`.
* Addition `c₁ + c₂` is defined by `cardinal.add_def α β : #α + #β = #(α ⊕ β)`.
* Multiplication `c₁ * c₂` is defined by `cardinal.mul_def : #α * #β = #(α × β)`.
* The order `c₁ ≤ c₂` is defined by `cardinal.le_def α β : #α ≤ #β ↔ nonempty (α ↪ β)`.
* Exponentiation `c₁ ^ c₂` is defined by `cardinal.power_def α β : #α ^ #β = #(β → α)`.
* `cardinal.is_limit c` means that `c` is a (weak) limit cardinal: `c ≠ 0 ∧ ∀ x < c, succ x < c`.
* `cardinal.aleph_0` or `ℵ₀` is the cardinality of `ℕ`. This definition is universe polymorphic:
  `cardinal.aleph_0.{u} : cardinal.{u}` (contrast with `ℕ : Type`, which lives in a specific
  universe). In some cases the universe level has to be given explicitly.
* `cardinal.sum` is the sum of an indexed family of cardinals, i.e. the cardinality of the
  corresponding sigma type.
* `cardinal.prod` is the product of an indexed family of cardinals, i.e. the cardinality of the
  corresponding pi type.
* `cardinal.powerlt a b` or `a ^< b` is defined as the supremum of `a ^ c` for `c < b`.

## Main instances

* Cardinals form a `canonically_ordered_comm_semiring` with the aforementioned sum and product.
* Cardinals form a `succ_order`. Use `order.succ c` for the smallest cardinal greater than `c`.
* The less than relation on cardinals forms a well-order.
* Cardinals form a `conditionally_complete_linear_order_bot`. Bounded sets for cardinals in universe
  `u` are precisely the sets indexed by some type in universe `u`, see
  `cardinal.bdd_above_iff_small`. One can use `Sup` for the cardinal supremum, and `Inf` for the
  minimum of a set of cardinals.

## Main Statements

* Cantor's theorem: `cardinal.cantor c : c < 2 ^ c`.
* König's theorem: `cardinal.sum_lt_prod`

## Implementation notes

* There is a type of cardinal numbers in every universe level:
  `cardinal.{u} : Type (u + 1)` is the quotient of types in `Type u`.
  The operation `cardinal.lift` lifts cardinal numbers to a higher level.
* Cardinal arithmetic specifically for infinite cardinals (like `κ * κ = κ`) is in the file
  `set_theory/cardinal_ordinal.lean`.
* There is an instance `has_pow cardinal`, but this will only fire if Lean already knows that both
  the base and the exponent live in the same universe. As a workaround, you can add
  ```
    local infixr (name := cardinal.pow) ^ := @has_pow.pow cardinal cardinal cardinal.has_pow
  ```
  to a file. This notation will work even if Lean doesn't know yet that the base and the exponent
  live in the same universe (but no exponents in other types can be used).

## References

* <https://en.wikipedia.org/wiki/Cardinal_number>

## Tags

cardinal number, cardinal arithmetic, cardinal exponentiation, aleph,
Cantor's theorem, König's theorem, Konig's theorem
-/


open Function Set Order

open scoped BigOperators Classical

noncomputable section

universe u v w

variable {α β : Type u}

#print Cardinal.isEquivalent /-
/-- The equivalence relation on types given by equivalence (bijective correspondence) of types.
  Quotienting by this equivalence relation gives the cardinal numbers.
-/
instance Cardinal.isEquivalent : Setoid (Type u)
    where
  R α β := Nonempty (α ≃ β)
  iseqv := ⟨fun α => ⟨Equiv.refl α⟩, fun α β ⟨e⟩ => ⟨e.symm⟩, fun α β γ ⟨e₁⟩ ⟨e₂⟩ => ⟨e₁.trans e₂⟩⟩
#align cardinal.is_equivalent Cardinal.isEquivalent
-/

#print Cardinal /-
/-- `cardinal.{u}` is the type of cardinal numbers in `Type u`,
  defined as the quotient of `Type u` by existence of an equivalence
  (a bijection with explicit inverse). -/
def Cardinal : Type (u + 1) :=
  Quotient Cardinal.isEquivalent
#align cardinal Cardinal
-/

namespace Cardinal

#print Cardinal.mk /-
/-- The cardinal number of a type -/
def mk : Type u → Cardinal :=
  Quotient.mk'
#align cardinal.mk Cardinal.mk
-/

scoped prefix:0 "#" => Cardinal.mk

#print Cardinal.canLiftCardinalType /-
instance canLiftCardinalType : CanLift Cardinal.{u} (Type u) mk fun _ => True :=
  ⟨fun c _ => Quot.inductionOn c fun α => ⟨α, rfl⟩⟩
#align cardinal.can_lift_cardinal_Type Cardinal.canLiftCardinalType
-/

#print Cardinal.inductionOn /-
@[elab_as_elim]
theorem inductionOn {p : Cardinal → Prop} (c : Cardinal) (h : ∀ α, p (#α)) : p c :=
  Quotient.inductionOn c h
#align cardinal.induction_on Cardinal.inductionOn
-/

#print Cardinal.inductionOn₂ /-
@[elab_as_elim]
theorem inductionOn₂ {p : Cardinal → Cardinal → Prop} (c₁ : Cardinal) (c₂ : Cardinal)
    (h : ∀ α β, p (#α) (#β)) : p c₁ c₂ :=
  Quotient.induction_on₂ c₁ c₂ h
#align cardinal.induction_on₂ Cardinal.inductionOn₂
-/

#print Cardinal.inductionOn₃ /-
@[elab_as_elim]
theorem inductionOn₃ {p : Cardinal → Cardinal → Cardinal → Prop} (c₁ : Cardinal) (c₂ : Cardinal)
    (c₃ : Cardinal) (h : ∀ α β γ, p (#α) (#β) (#γ)) : p c₁ c₂ c₃ :=
  Quotient.induction_on₃ c₁ c₂ c₃ h
#align cardinal.induction_on₃ Cardinal.inductionOn₃
-/

#print Cardinal.eq /-
protected theorem eq : (#α) = (#β) ↔ Nonempty (α ≃ β) :=
  Quotient.eq'
#align cardinal.eq Cardinal.eq
-/

#print Cardinal.mk'_def /-
@[simp]
theorem mk'_def (α : Type u) : @Eq Cardinal ⟦α⟧ (#α) :=
  rfl
#align cardinal.mk_def Cardinal.mk'_def
-/

#print Cardinal.mk_out /-
@[simp]
theorem mk_out (c : Cardinal) : (#c.out) = c :=
  Quotient.out_eq _
#align cardinal.mk_out Cardinal.mk_out
-/

#print Cardinal.outMkEquiv /-
/-- The representative of the cardinal of a type is equivalent ot the original type. -/
def outMkEquiv {α : Type v} : (#α).out ≃ α :=
  Nonempty.some <| Cardinal.eq.mp (by simp)
#align cardinal.out_mk_equiv Cardinal.outMkEquiv
-/

#print Cardinal.mk_congr /-
theorem mk_congr (e : α ≃ β) : (#α) = (#β) :=
  Quot.sound ⟨e⟩
#align cardinal.mk_congr Cardinal.mk_congr
-/

alias _root_.equiv.cardinal_eq := mk_congr
#align equiv.cardinal_eq Equiv.cardinal_eq

#print Cardinal.map /-
/-- Lift a function between `Type*`s to a function between `cardinal`s. -/
def map (f : Type u → Type v) (hf : ∀ α β, α ≃ β → f α ≃ f β) : Cardinal.{u} → Cardinal.{v} :=
  Quotient.map f fun α β ⟨e⟩ => ⟨hf α β e⟩
#align cardinal.map Cardinal.map
-/

#print Cardinal.map_mk /-
@[simp]
theorem map_mk (f : Type u → Type v) (hf : ∀ α β, α ≃ β → f α ≃ f β) (α : Type u) :
    map f hf (#α) = (#f α) :=
  rfl
#align cardinal.map_mk Cardinal.map_mk
-/

#print Cardinal.map₂ /-
/-- Lift a binary operation `Type* → Type* → Type*` to a binary operation on `cardinal`s. -/
def map₂ (f : Type u → Type v → Type w) (hf : ∀ α β γ δ, α ≃ β → γ ≃ δ → f α γ ≃ f β δ) :
    Cardinal.{u} → Cardinal.{v} → Cardinal.{w} :=
  Quotient.map₂ f fun α β ⟨e₁⟩ γ δ ⟨e₂⟩ => ⟨hf α β γ δ e₁ e₂⟩
#align cardinal.map₂ Cardinal.map₂
-/

#print Cardinal.lift /-
/-- The universe lift operation on cardinals. You can specify the universes explicitly with
  `lift.{u v} : cardinal.{v} → cardinal.{max v u}` -/
def lift (c : Cardinal.{v}) : Cardinal.{max v u} :=
  map ULift (fun α β e => Equiv.ulift.trans <| e.trans Equiv.ulift.symm) c
#align cardinal.lift Cardinal.lift
-/

#print Cardinal.mk_uLift /-
@[simp]
theorem mk_uLift (α) : (#ULift.{v, u} α) = lift.{v} (#α) :=
  rfl
#align cardinal.mk_ulift Cardinal.mk_uLift
-/

#print Cardinal.lift_umax /-
/-- `lift.{(max u v) u}` equals `lift.{v u}`. Using `set_option pp.universes true` will make it much
    easier to understand what's happening when using this lemma. -/
@[simp]
theorem lift_umax : lift.{max u v, u} = lift.{v, u} :=
  funext fun a => inductionOn a fun α => (Equiv.ulift.trans Equiv.ulift.symm).cardinal_eq
#align cardinal.lift_umax Cardinal.lift_umax
-/

#print Cardinal.lift_umax' /-
/-- `lift.{(max v u) u}` equals `lift.{v u}`. Using `set_option pp.universes true` will make it much
    easier to understand what's happening when using this lemma. -/
@[simp]
theorem lift_umax' : lift.{max v u, u} = lift.{v, u} :=
  lift_umax
#align cardinal.lift_umax' Cardinal.lift_umax'
-/

#print Cardinal.lift_id' /-
/-- A cardinal lifted to a lower or equal universe equals itself. -/
@[simp]
theorem lift_id' (a : Cardinal.{max u v}) : lift.{u} a = a :=
  inductionOn a fun α => mk_congr Equiv.ulift
#align cardinal.lift_id' Cardinal.lift_id'
-/

#print Cardinal.lift_id /-
/-- A cardinal lifted to the same universe equals itself. -/
@[simp]
theorem lift_id (a : Cardinal) : lift.{u, u} a = a :=
  lift_id'.{u, u} a
#align cardinal.lift_id Cardinal.lift_id
-/

#print Cardinal.lift_uzero /-
/-- A cardinal lifted to the zero universe equals itself. -/
@[simp]
theorem lift_uzero (a : Cardinal.{u}) : lift.{0} a = a :=
  lift_id'.{0, u} a
#align cardinal.lift_uzero Cardinal.lift_uzero
-/

#print Cardinal.lift_lift /-
@[simp]
theorem lift_lift (a : Cardinal) : lift.{w} (lift.{v} a) = lift.{max v w} a :=
  inductionOn a fun α => (Equiv.ulift.trans <| Equiv.ulift.trans Equiv.ulift.symm).cardinal_eq
#align cardinal.lift_lift Cardinal.lift_lift
-/

/-- We define the order on cardinal numbers by `#α ≤ #β` if and only if
  there exists an embedding (injective function) from α to β. -/
instance : LE Cardinal.{u} :=
  ⟨fun q₁ q₂ =>
    Quotient.liftOn₂ q₁ q₂ (fun α β => Nonempty <| α ↪ β) fun α β γ δ ⟨e₁⟩ ⟨e₂⟩ =>
      propext ⟨fun ⟨e⟩ => ⟨e.congr e₁ e₂⟩, fun ⟨e⟩ => ⟨e.congr e₁.symm e₂.symm⟩⟩⟩

instance : PartialOrder Cardinal.{u} where
  le := (· ≤ ·)
  le_refl := by rintro ⟨α⟩ <;> exact ⟨embedding.refl _⟩
  le_trans := by rintro ⟨α⟩ ⟨β⟩ ⟨γ⟩ ⟨e₁⟩ ⟨e₂⟩ <;> exact ⟨e₁.trans e₂⟩
  le_antisymm := by rintro ⟨α⟩ ⟨β⟩ ⟨e₁⟩ ⟨e₂⟩; exact Quotient.sound (e₁.antisymm e₂)

instance : LinearOrder Cardinal.{u} :=
  {
    Cardinal.partialOrder.{u} with
    le_total := by rintro ⟨α⟩ ⟨β⟩; apply embedding.total
    decidableLe := Classical.decRel _ }

#print Cardinal.le_def /-
theorem le_def (α β : Type u) : (#α) ≤ (#β) ↔ Nonempty (α ↪ β) :=
  Iff.rfl
#align cardinal.le_def Cardinal.le_def
-/

#print Cardinal.mk_le_of_injective /-
theorem mk_le_of_injective {α β : Type u} {f : α → β} (hf : Injective f) : (#α) ≤ (#β) :=
  ⟨⟨f, hf⟩⟩
#align cardinal.mk_le_of_injective Cardinal.mk_le_of_injective
-/

#print Function.Embedding.cardinal_le /-
theorem Function.Embedding.cardinal_le {α β : Type u} (f : α ↪ β) : (#α) ≤ (#β) :=
  ⟨f⟩
#align function.embedding.cardinal_le Function.Embedding.cardinal_le
-/

#print Cardinal.mk_le_of_surjective /-
theorem mk_le_of_surjective {α β : Type u} {f : α → β} (hf : Surjective f) : (#β) ≤ (#α) :=
  ⟨Embedding.ofSurjective f hf⟩
#align cardinal.mk_le_of_surjective Cardinal.mk_le_of_surjective
-/

#print Cardinal.le_mk_iff_exists_set /-
theorem le_mk_iff_exists_set {c : Cardinal} {α : Type u} : c ≤ (#α) ↔ ∃ p : Set α, (#p) = c :=
  ⟨inductionOn c fun β ⟨⟨f, hf⟩⟩ => ⟨Set.range f, (Equiv.ofInjective f hf).cardinal_eq.symm⟩,
    fun ⟨p, e⟩ => e ▸ ⟨⟨Subtype.val, fun a b => Subtype.eq⟩⟩⟩
#align cardinal.le_mk_iff_exists_set Cardinal.le_mk_iff_exists_set
-/

#print Cardinal.mk_subtype_le /-
theorem mk_subtype_le {α : Type u} (p : α → Prop) : (#Subtype p) ≤ (#α) :=
  ⟨Embedding.subtype p⟩
#align cardinal.mk_subtype_le Cardinal.mk_subtype_le
-/

#print Cardinal.mk_set_le /-
theorem mk_set_le (s : Set α) : (#s) ≤ (#α) :=
  mk_subtype_le s
#align cardinal.mk_set_le Cardinal.mk_set_le
-/

#print Cardinal.out_embedding /-
theorem out_embedding {c c' : Cardinal} : c ≤ c' ↔ Nonempty (c.out ↪ c'.out) := by trans _;
  rw [← Quotient.out_eq c, ← Quotient.out_eq c']; rfl
#align cardinal.out_embedding Cardinal.out_embedding
-/

#print Cardinal.lift_mk_le /-
theorem lift_mk_le {α : Type u} {β : Type v} :
    lift.{max v w} (#α) ≤ lift.{max u w} (#β) ↔ Nonempty (α ↪ β) :=
  ⟨fun ⟨f⟩ => ⟨Embedding.congr Equiv.ulift Equiv.ulift f⟩, fun ⟨f⟩ =>
    ⟨Embedding.congr Equiv.ulift.symm Equiv.ulift.symm f⟩⟩
#align cardinal.lift_mk_le Cardinal.lift_mk_le
-/

#print Cardinal.lift_mk_le' /-
/-- A variant of `cardinal.lift_mk_le` with specialized universes.
Because Lean often can not realize it should use this specialization itself,
we provide this statement separately so you don't have to solve the specialization problem either.
-/
theorem lift_mk_le' {α : Type u} {β : Type v} : lift.{v} (#α) ≤ lift.{u} (#β) ↔ Nonempty (α ↪ β) :=
  lift_mk_le.{u, v, 0}
#align cardinal.lift_mk_le' Cardinal.lift_mk_le'
-/

#print Cardinal.lift_mk_eq /-
theorem lift_mk_eq {α : Type u} {β : Type v} :
    lift.{max v w} (#α) = lift.{max u w} (#β) ↔ Nonempty (α ≃ β) :=
  Quotient.eq'.trans
    ⟨fun ⟨f⟩ => ⟨Equiv.ulift.symm.trans <| f.trans Equiv.ulift⟩, fun ⟨f⟩ =>
      ⟨Equiv.ulift.trans <| f.trans Equiv.ulift.symm⟩⟩
#align cardinal.lift_mk_eq Cardinal.lift_mk_eq
-/

#print Cardinal.lift_mk_eq' /-
/-- A variant of `cardinal.lift_mk_eq` with specialized universes.
Because Lean often can not realize it should use this specialization itself,
we provide this statement separately so you don't have to solve the specialization problem either.
-/
theorem lift_mk_eq' {α : Type u} {β : Type v} : lift.{v} (#α) = lift.{u} (#β) ↔ Nonempty (α ≃ β) :=
  lift_mk_eq.{u, v, 0}
#align cardinal.lift_mk_eq' Cardinal.lift_mk_eq'
-/

#print Cardinal.lift_le /-
@[simp]
theorem lift_le {a b : Cardinal} : lift a ≤ lift b ↔ a ≤ b :=
  inductionOn₂ a b fun α β => by rw [← lift_umax]; exact lift_mk_le
#align cardinal.lift_le Cardinal.lift_le
-/

#print Cardinal.liftOrderEmbedding /-
/-- `cardinal.lift` as an `order_embedding`. -/
@[simps (config := { fullyApplied := false })]
def liftOrderEmbedding : Cardinal.{v} ↪o Cardinal.{max v u} :=
  OrderEmbedding.ofMapLEIff lift fun _ _ => lift_le
#align cardinal.lift_order_embedding Cardinal.liftOrderEmbedding
-/

#print Cardinal.lift_injective /-
theorem lift_injective : Injective lift.{u, v} :=
  liftOrderEmbedding.Injective
#align cardinal.lift_injective Cardinal.lift_injective
-/

#print Cardinal.lift_inj /-
@[simp]
theorem lift_inj {a b : Cardinal} : lift a = lift b ↔ a = b :=
  lift_injective.eq_iff
#align cardinal.lift_inj Cardinal.lift_inj
-/

#print Cardinal.lift_lt /-
@[simp]
theorem lift_lt {a b : Cardinal} : lift a < lift b ↔ a < b :=
  liftOrderEmbedding.lt_iff_lt
#align cardinal.lift_lt Cardinal.lift_lt
-/

#print Cardinal.lift_strictMono /-
theorem lift_strictMono : StrictMono lift := fun a b => lift_lt.2
#align cardinal.lift_strict_mono Cardinal.lift_strictMono
-/

#print Cardinal.lift_monotone /-
theorem lift_monotone : Monotone lift :=
  lift_strictMono.Monotone
#align cardinal.lift_monotone Cardinal.lift_monotone
-/

instance : Zero Cardinal.{u} :=
  ⟨#PEmpty⟩

instance : Inhabited Cardinal.{u} :=
  ⟨0⟩

#print Cardinal.mk_eq_zero /-
theorem mk_eq_zero (α : Type u) [IsEmpty α] : (#α) = 0 :=
  (Equiv.equivPEmpty α).cardinal_eq
#align cardinal.mk_eq_zero Cardinal.mk_eq_zero
-/

#print Cardinal.lift_zero /-
@[simp]
theorem lift_zero : lift 0 = 0 :=
  mk_congr (Equiv.equivPEmpty _)
#align cardinal.lift_zero Cardinal.lift_zero
-/

#print Cardinal.lift_eq_zero /-
@[simp]
theorem lift_eq_zero {a : Cardinal.{v}} : lift.{u} a = 0 ↔ a = 0 :=
  lift_injective.eq_iff' lift_zero
#align cardinal.lift_eq_zero Cardinal.lift_eq_zero
-/

#print Cardinal.mk_eq_zero_iff /-
theorem mk_eq_zero_iff {α : Type u} : (#α) = 0 ↔ IsEmpty α :=
  ⟨fun e =>
    let ⟨h⟩ := Quotient.exact e
    h.isEmpty,
    @mk_eq_zero α⟩
#align cardinal.mk_eq_zero_iff Cardinal.mk_eq_zero_iff
-/

#print Cardinal.mk_ne_zero_iff /-
theorem mk_ne_zero_iff {α : Type u} : (#α) ≠ 0 ↔ Nonempty α :=
  (not_iff_not.2 mk_eq_zero_iff).trans not_isEmpty_iff
#align cardinal.mk_ne_zero_iff Cardinal.mk_ne_zero_iff
-/

#print Cardinal.mk_ne_zero /-
@[simp]
theorem mk_ne_zero (α : Type u) [Nonempty α] : (#α) ≠ 0 :=
  mk_ne_zero_iff.2 ‹_›
#align cardinal.mk_ne_zero Cardinal.mk_ne_zero
-/

instance : One Cardinal.{u} :=
  ⟨#PUnit⟩

instance : Nontrivial Cardinal.{u} :=
  ⟨⟨1, 0, mk_ne_zero _⟩⟩

#print Cardinal.mk_eq_one /-
theorem mk_eq_one (α : Type u) [Unique α] : (#α) = 1 :=
  (Equiv.equivPUnit α).cardinal_eq
#align cardinal.mk_eq_one Cardinal.mk_eq_one
-/

#print Cardinal.le_one_iff_subsingleton /-
theorem le_one_iff_subsingleton {α : Type u} : (#α) ≤ 1 ↔ Subsingleton α :=
  ⟨fun ⟨f⟩ => ⟨fun a b => f.Injective (Subsingleton.elim _ _)⟩, fun ⟨h⟩ =>
    ⟨⟨fun a => PUnit.unit, fun a b _ => h _ _⟩⟩⟩
#align cardinal.le_one_iff_subsingleton Cardinal.le_one_iff_subsingleton
-/

#print Cardinal.mk_le_one_iff_set_subsingleton /-
@[simp]
theorem mk_le_one_iff_set_subsingleton {s : Set α} : (#s) ≤ 1 ↔ s.Subsingleton :=
  le_one_iff_subsingleton.trans s.subsingleton_coe
#align cardinal.mk_le_one_iff_set_subsingleton Cardinal.mk_le_one_iff_set_subsingleton
-/

alias ⟨_, _root_.set.subsingleton.cardinal_mk_le_one⟩ := mk_le_one_iff_set_subsingleton
#align set.subsingleton.cardinal_mk_le_one Set.Subsingleton.cardinal_mk_le_one

instance : Add Cardinal.{u} :=
  ⟨map₂ Sum fun α β γ δ => Equiv.sumCongr⟩

#print Cardinal.add_def /-
theorem add_def (α β : Type u) : (#α) + (#β) = (#Sum α β) :=
  rfl
#align cardinal.add_def Cardinal.add_def
-/

instance : NatCast Cardinal.{u} :=
  ⟨Nat.unaryCast⟩

#print Cardinal.mk_sum /-
@[simp]
theorem mk_sum (α : Type u) (β : Type v) : (#Sum α β) = lift.{v, u} (#α) + lift.{u, v} (#β) :=
  mk_congr (Equiv.ulift.symm.sumCongr Equiv.ulift.symm)
#align cardinal.mk_sum Cardinal.mk_sum
-/

#print Cardinal.mk_option /-
@[simp]
theorem mk_option {α : Type u} : (#Option α) = (#α) + 1 :=
  (Equiv.optionEquivSumPUnit α).cardinal_eq
#align cardinal.mk_option Cardinal.mk_option
-/

#print Cardinal.mk_psum /-
@[simp]
theorem mk_psum (α : Type u) (β : Type v) : (#PSum α β) = lift.{v} (#α) + lift.{u} (#β) :=
  (mk_congr (Equiv.psumEquivSum α β)).trans (mk_sum α β)
#align cardinal.mk_psum Cardinal.mk_psum
-/

#print Cardinal.mk_fintype /-
@[simp]
theorem mk_fintype (α : Type u) [Fintype α] : (#α) = Fintype.card α :=
  by
  refine' Fintype.induction_empty_option _ _ _ α
  · intro α β h e hα; letI := Fintype.ofEquiv β e.symm
    rwa [mk_congr e, Fintype.card_congr e] at hα
  · rfl
  · intro α h hα; simp [hα]; rfl
#align cardinal.mk_fintype Cardinal.mk_fintype
-/

instance : Mul Cardinal.{u} :=
  ⟨map₂ Prod fun α β γ δ => Equiv.prodCongr⟩

#print Cardinal.mul_def /-
theorem mul_def (α β : Type u) : (#α) * (#β) = (#α × β) :=
  rfl
#align cardinal.mul_def Cardinal.mul_def
-/

#print Cardinal.mk_prod /-
@[simp]
theorem mk_prod (α : Type u) (β : Type v) : (#α × β) = lift.{v, u} (#α) * lift.{u, v} (#β) :=
  mk_congr (Equiv.ulift.symm.prodCongr Equiv.ulift.symm)
#align cardinal.mk_prod Cardinal.mk_prod
-/

private theorem mul_comm' (a b : Cardinal.{u}) : a * b = b * a :=
  inductionOn₂ a b fun α β => mk_congr <| Equiv.prodComm α β

/-- The cardinal exponential. `#α ^ #β` is the cardinal of `β → α`. -/
instance : Pow Cardinal.{u} Cardinal.{u} :=
  ⟨map₂ (fun α β => β → α) fun α β γ δ e₁ e₂ => e₂.arrowCongr e₁⟩

local infixr:0 "^" => @Pow.pow Cardinal Cardinal Cardinal.hasPow

local infixr:80 " ^ℕ " => @Pow.pow Cardinal ℕ Monoid.toNatPow

#print Cardinal.power_def /-
theorem power_def (α β) : ((#α)^#β) = (#β → α) :=
  rfl
#align cardinal.power_def Cardinal.power_def
-/

#print Cardinal.mk_arrow /-
theorem mk_arrow (α : Type u) (β : Type v) : (#α → β) = (lift.{u} (#β)^lift.{v} (#α)) :=
  mk_congr (Equiv.ulift.symm.arrowCongr Equiv.ulift.symm)
#align cardinal.mk_arrow Cardinal.mk_arrow
-/

#print Cardinal.lift_power /-
@[simp]
theorem lift_power (a b) : lift (a^b) = (lift a^lift b) :=
  inductionOn₂ a b fun α β =>
    mk_congr <| Equiv.ulift.trans (Equiv.ulift.arrowCongr Equiv.ulift).symm
#align cardinal.lift_power Cardinal.lift_power
-/

#print Cardinal.power_zero /-
@[simp]
theorem power_zero {a : Cardinal} : (a^0) = 1 :=
  inductionOn a fun α => mk_congr <| Equiv.pemptyArrowEquivPUnit α
#align cardinal.power_zero Cardinal.power_zero
-/

#print Cardinal.power_one /-
@[simp]
theorem power_one {a : Cardinal} : (a^1) = a :=
  inductionOn a fun α => mk_congr <| Equiv.punitArrowEquiv α
#align cardinal.power_one Cardinal.power_one
-/

#print Cardinal.power_add /-
theorem power_add {a b c : Cardinal} : (a^b + c) = (a^b) * (a^c) :=
  inductionOn₃ a b c fun α β γ => mk_congr <| Equiv.sumArrowEquivProdArrow β γ α
#align cardinal.power_add Cardinal.power_add
-/

instance : CommSemiring Cardinal.{u} where
  zero := 0
  one := 1
  add := (· + ·)
  mul := (· * ·)
  zero_add a := inductionOn a fun α => mk_congr <| Equiv.emptySum PEmpty α
  add_zero a := inductionOn a fun α => mk_congr <| Equiv.sumEmpty α PEmpty
  add_assoc a b c := inductionOn₃ a b c fun α β γ => mk_congr <| Equiv.sumAssoc α β γ
  add_comm a b := inductionOn₂ a b fun α β => mk_congr <| Equiv.sumComm α β
  zero_mul a := inductionOn a fun α => mk_congr <| Equiv.pemptyProd α
  mul_zero a := inductionOn a fun α => mk_congr <| Equiv.prodPEmpty α
  one_mul a := inductionOn a fun α => mk_congr <| Equiv.punitProd α
  mul_one a := inductionOn a fun α => mk_congr <| Equiv.prodPUnit α
  mul_assoc a b c := inductionOn₃ a b c fun α β γ => mk_congr <| Equiv.prodAssoc α β γ
  mul_comm := hMul_comm'
  left_distrib a b c := inductionOn₃ a b c fun α β γ => mk_congr <| Equiv.prodSumDistrib α β γ
  right_distrib a b c := inductionOn₃ a b c fun α β γ => mk_congr <| Equiv.sumProdDistrib α β γ
  npow n c := c^n
  npow_zero := @power_zero
  npow_succ n c := show (c^n + 1) = c * (c^n) by rw [power_add, power_one, mul_comm']

theorem power_bit0 (a b : Cardinal) : (a^bit0 b) = (a^b) * (a^b) :=
  power_add
#align cardinal.power_bit0 Cardinal.power_bit0

theorem power_bit1 (a b : Cardinal) : (a^bit1 b) = (a^b) * (a^b) * a := by
  rw [bit1, ← power_bit0, power_add, power_one]
#align cardinal.power_bit1 Cardinal.power_bit1

#print Cardinal.one_power /-
@[simp]
theorem one_power {a : Cardinal} : (1^a) = 1 :=
  inductionOn a fun α => (Equiv.arrowPUnitEquivPUnit α).cardinal_eq
#align cardinal.one_power Cardinal.one_power
-/

#print Cardinal.mk_bool /-
@[simp]
theorem mk_bool : (#Bool) = 2 := by simp
#align cardinal.mk_bool Cardinal.mk_bool
-/

#print Cardinal.mk_Prop /-
@[simp]
theorem mk_Prop : (#Prop) = 2 := by simp
#align cardinal.mk_Prop Cardinal.mk_Prop
-/

#print Cardinal.zero_power /-
@[simp]
theorem zero_power {a : Cardinal} : a ≠ 0 → (0^a) = 0 :=
  inductionOn a fun α heq =>
    mk_eq_zero_iff.2 <|
      isEmpty_pi.2 <|
        let ⟨a⟩ := mk_ne_zero_iff.1 HEq
        ⟨a, PEmpty.isEmpty⟩
#align cardinal.zero_power Cardinal.zero_power
-/

#print Cardinal.power_ne_zero /-
theorem power_ne_zero {a : Cardinal} (b) : a ≠ 0 → (a^b) ≠ 0 :=
  inductionOn₂ a b fun α β h =>
    let ⟨a⟩ := mk_ne_zero_iff.1 h
    mk_ne_zero_iff.2 ⟨fun _ => a⟩
#align cardinal.power_ne_zero Cardinal.power_ne_zero
-/

#print Cardinal.mul_power /-
theorem mul_power {a b c : Cardinal} : (a * b^c) = (a^c) * (b^c) :=
  inductionOn₃ a b c fun α β γ => mk_congr <| Equiv.arrowProdEquivProdArrow α β γ
#align cardinal.mul_power Cardinal.mul_power
-/

#print Cardinal.power_mul /-
theorem power_mul {a b c : Cardinal} : (a^b * c) = ((a^b)^c) := by rw [mul_comm b c];
  exact induction_on₃ a b c fun α β γ => mk_congr <| Equiv.curry γ β α
#align cardinal.power_mul Cardinal.power_mul
-/

#print Cardinal.pow_cast_right /-
@[simp]
theorem pow_cast_right (a : Cardinal.{u}) (n : ℕ) : (a^(↑n : Cardinal.{u})) = a ^ℕ n :=
  rfl
#align cardinal.pow_cast_right Cardinal.pow_cast_right
-/

#print Cardinal.lift_one /-
@[simp]
theorem lift_one : lift 1 = 1 :=
  mk_congr <| Equiv.ulift.trans Equiv.punitEquivPUnit
#align cardinal.lift_one Cardinal.lift_one
-/

#print Cardinal.lift_add /-
@[simp]
theorem lift_add (a b) : lift (a + b) = lift a + lift b :=
  inductionOn₂ a b fun α β =>
    mk_congr <| Equiv.ulift.trans (Equiv.sumCongr Equiv.ulift Equiv.ulift).symm
#align cardinal.lift_add Cardinal.lift_add
-/

#print Cardinal.lift_mul /-
@[simp]
theorem lift_mul (a b) : lift (a * b) = lift a * lift b :=
  inductionOn₂ a b fun α β =>
    mk_congr <| Equiv.ulift.trans (Equiv.prodCongr Equiv.ulift Equiv.ulift).symm
#align cardinal.lift_mul Cardinal.lift_mul
-/

@[simp]
theorem lift_bit0 (a : Cardinal) : lift (bit0 a) = bit0 (lift a) :=
  lift_add a a
#align cardinal.lift_bit0 Cardinal.lift_bit0

@[simp]
theorem lift_bit1 (a : Cardinal) : lift (bit1 a) = bit1 (lift a) := by simp [bit1]
#align cardinal.lift_bit1 Cardinal.lift_bit1

#print Cardinal.lift_two /-
theorem lift_two : lift.{u, v} 2 = 2 := by simp
#align cardinal.lift_two Cardinal.lift_two
-/

#print Cardinal.mk_set /-
@[simp]
theorem mk_set {α : Type u} : (#Set α) = (2^#α) := by simp [Set, mk_arrow]
#align cardinal.mk_set Cardinal.mk_set
-/

#print Cardinal.mk_powerset /-
/-- A variant of `cardinal.mk_set` expressed in terms of a `set` instead of a `Type`. -/
@[simp]
theorem mk_powerset {α : Type u} (s : Set α) : (#↥(𝒫 s)) = (2^#↥s) :=
  (mk_congr (Equiv.Set.powerset s)).trans mk_set
#align cardinal.mk_powerset Cardinal.mk_powerset
-/

#print Cardinal.lift_two_power /-
theorem lift_two_power (a) : lift (2^a) = (2^lift a) := by simp
#align cardinal.lift_two_power Cardinal.lift_two_power
-/

section OrderProperties

open Sum

#print Cardinal.zero_le /-
protected theorem zero_le : ∀ a : Cardinal, 0 ≤ a := by rintro ⟨α⟩ <;> exact ⟨embedding.of_is_empty⟩
#align cardinal.zero_le Cardinal.zero_le
-/

private theorem add_le_add' : ∀ {a b c d : Cardinal}, a ≤ b → c ≤ d → a + c ≤ b + d := by
  rintro ⟨α⟩ ⟨β⟩ ⟨γ⟩ ⟨δ⟩ ⟨e₁⟩ ⟨e₂⟩ <;> exact ⟨e₁.sum_map e₂⟩

#print Cardinal.add_covariantClass /-
instance add_covariantClass : CovariantClass Cardinal Cardinal (· + ·) (· ≤ ·) :=
  ⟨fun a b c => add_le_add' le_rfl⟩
#align cardinal.add_covariant_class Cardinal.add_covariantClass
-/

#print Cardinal.add_swap_covariantClass /-
instance add_swap_covariantClass : CovariantClass Cardinal Cardinal (swap (· + ·)) (· ≤ ·) :=
  ⟨fun a b c h => add_le_add' h le_rfl⟩
#align cardinal.add_swap_covariant_class Cardinal.add_swap_covariantClass
-/

instance : CanonicallyOrderedCommSemiring Cardinal.{u} :=
  { Cardinal.commSemiring,
    Cardinal.partialOrder with
    bot := 0
    bot_le := Cardinal.zero_le
    add_le_add_left := fun a b => add_le_add_left
    exists_add_of_le := fun a b =>
      inductionOn₂ a b fun α β ⟨⟨f, hf⟩⟩ =>
        have : Sum α (range fᶜ : Set β) ≃ β :=
          (Equiv.sumCongr (Equiv.ofInjective f hf) (Equiv.refl _)).trans <|
            Equiv.Set.sumCompl (range f)
        ⟨#↥(range fᶜ), mk_congr this.symm⟩
    le_self_add := fun a b => (add_zero a).ge.trans <| add_le_add_left (Cardinal.zero_le _) _
    eq_zero_or_eq_zero_of_mul_eq_zero := fun a b =>
      inductionOn₂ a b fun α β => by simpa only [mul_def, mk_eq_zero_iff, isEmpty_prod] using id }

instance : CanonicallyLinearOrderedAddCommMonoid Cardinal.{u} :=
  { Cardinal.canonicallyOrderedCommSemiring, Cardinal.linearOrder with }

-- Computable instance to prevent a non-computable one being found via the one above
instance : CanonicallyOrderedAddCommMonoid Cardinal.{u} :=
  { Cardinal.canonicallyOrderedCommSemiring with }

instance : LinearOrderedCommMonoidWithZero Cardinal.{u} :=
  { Cardinal.commSemiring,
    Cardinal.linearOrder with
    mul_le_mul_left := @mul_le_mul_left' _ _ _ _
    zero_le_one := zero_le _ }

-- Computable instance to prevent a non-computable one being found via the one above
instance : CommMonoidWithZero Cardinal.{u} :=
  { Cardinal.canonicallyOrderedCommSemiring with }

#print Cardinal.zero_power_le /-
theorem zero_power_le (c : Cardinal.{u}) : ((0 : Cardinal.{u})^c) ≤ 1 := by by_cases h : c = 0;
  rw [h, power_zero]; rw [zero_power h]; apply zero_le
#align cardinal.zero_power_le Cardinal.zero_power_le
-/

#print Cardinal.power_le_power_left /-
theorem power_le_power_left : ∀ {a b c : Cardinal}, a ≠ 0 → b ≤ c → (a^b) ≤ (a^c) := by
  rintro ⟨α⟩ ⟨β⟩ ⟨γ⟩ hα ⟨e⟩ <;>
    exact
      let ⟨a⟩ := mk_ne_zero_iff.1 hα
      ⟨@embedding.arrow_congr_left _ _ _ ⟨a⟩ e⟩
#align cardinal.power_le_power_left Cardinal.power_le_power_left
-/

#print Cardinal.self_le_power /-
theorem self_le_power (a : Cardinal) {b : Cardinal} (hb : 1 ≤ b) : a ≤ (a^b) :=
  by
  rcases eq_or_ne a 0 with (rfl | ha)
  · exact zero_le _
  · convert power_le_power_left ha hb; exact power_one.symm
#align cardinal.self_le_power Cardinal.self_le_power
-/

#print Cardinal.cantor /-
/-- **Cantor's theorem** -/
theorem cantor (a : Cardinal.{u}) : a < (2^a) :=
  by
  induction' a using Cardinal.inductionOn with α
  rw [← mk_set]
  refine' ⟨⟨⟨singleton, fun a b => singleton_eq_singleton_iff.1⟩⟩, _⟩
  rintro ⟨⟨f, hf⟩⟩
  exact cantor_injective f hf
#align cardinal.cantor Cardinal.cantor
-/

instance : NoMaxOrder Cardinal.{u} where exists_gt a := ⟨_, cantor a⟩

-- short-circuit type class inference
instance : DistribLattice Cardinal.{u} := by infer_instance

#print Cardinal.one_lt_iff_nontrivial /-
theorem one_lt_iff_nontrivial {α : Type u} : 1 < (#α) ↔ Nontrivial α := by
  rw [← not_le, le_one_iff_subsingleton, ← not_nontrivial_iff_subsingleton, Classical.not_not]
#align cardinal.one_lt_iff_nontrivial Cardinal.one_lt_iff_nontrivial
-/

#print Cardinal.power_le_max_power_one /-
theorem power_le_max_power_one {a b c : Cardinal} (h : b ≤ c) : (a^b) ≤ max (a^c) 1 :=
  by
  by_cases ha : a = 0
  simp [ha, zero_power_le]
  exact (power_le_power_left ha h).trans (le_max_left _ _)
#align cardinal.power_le_max_power_one Cardinal.power_le_max_power_one
-/

#print Cardinal.power_le_power_right /-
theorem power_le_power_right {a b c : Cardinal} : a ≤ b → (a^c) ≤ (b^c) :=
  inductionOn₃ a b c fun α β γ ⟨e⟩ => ⟨Embedding.arrowCongrRight e⟩
#align cardinal.power_le_power_right Cardinal.power_le_power_right
-/

#print Cardinal.power_pos /-
theorem power_pos {a : Cardinal} (b) (ha : 0 < a) : 0 < (a^b) :=
  (power_ne_zero _ ha.ne').bot_lt
#align cardinal.power_pos Cardinal.power_pos
-/

end OrderProperties

#print Cardinal.lt_wf /-
protected theorem lt_wf : @WellFounded Cardinal.{u} (· < ·) :=
  ⟨fun a =>
    by_contradiction fun h => by
      let ι := { c : Cardinal // ¬Acc (· < ·) c }
      let f : ι → Cardinal := Subtype.val
      haveI hι : Nonempty ι := ⟨⟨_, h⟩⟩
      obtain ⟨⟨c : Cardinal, hc : ¬Acc (· < ·) c⟩, ⟨h_1 : ∀ j, (f ⟨c, hc⟩).out ↪ (f j).out⟩⟩ :=
        embedding.min_injective fun i => (f i).out
      apply hc (Acc.intro _ fun j h' => by_contradiction fun hj => h'.2 _)
      have : (#_) ≤ (#_) := ⟨h_1 ⟨j, hj⟩⟩
      simpa only [f, mk_out] using this⟩
#align cardinal.lt_wf Cardinal.lt_wf
-/

instance : WellFoundedRelation Cardinal.{u} :=
  ⟨(· < ·), Cardinal.lt_wf⟩

#print Cardinal.wo /-
instance wo : @IsWellOrder Cardinal.{u} (· < ·) where
#align cardinal.wo Cardinal.wo
-/

instance : ConditionallyCompleteLinearOrderBot Cardinal :=
  IsWellOrder.conditionallyCompleteLinearOrderBot _

#print Cardinal.sInf_empty /-
@[simp]
theorem sInf_empty : sInf (∅ : Set Cardinal.{u}) = 0 :=
  dif_neg not_nonempty_empty
#align cardinal.Inf_empty Cardinal.sInf_empty
-/

/-- Note that the successor of `c` is not the same as `c + 1` except in the case of finite `c`. -/
instance : SuccOrder Cardinal :=
  SuccOrder.ofSuccLeIff (fun c => sInf {c' | c < c'}) fun a b =>
    ⟨lt_of_lt_of_le <| csInf_mem <| exists_gt a, csInf_le'⟩

#print Cardinal.succ_def /-
theorem succ_def (c : Cardinal) : succ c = sInf {c' | c < c'} :=
  rfl
#align cardinal.succ_def Cardinal.succ_def
-/

#print Cardinal.succ_pos /-
theorem succ_pos : ∀ c : Cardinal, 0 < succ c :=
  bot_lt_succ
#align cardinal.succ_pos Cardinal.succ_pos
-/

#print Cardinal.succ_ne_zero /-
theorem succ_ne_zero (c : Cardinal) : succ c ≠ 0 :=
  (succ_pos _).ne'
#align cardinal.succ_ne_zero Cardinal.succ_ne_zero
-/

#print Cardinal.add_one_le_succ /-
theorem add_one_le_succ (c : Cardinal.{u}) : c + 1 ≤ succ c :=
  by
  refine' (le_csInf_iff'' (exists_gt c)).2 fun b hlt => _
  rcases b, c with ⟨⟨β⟩, ⟨γ⟩⟩
  cases' le_of_lt hlt with f
  have : ¬surjective f := fun hn => (not_le_of_lt hlt) (mk_le_of_surjective hn)
  simp only [surjective, Classical.not_forall] at this
  rcases this with ⟨b, hb⟩
  calc
    (#γ) + 1 = (#Option γ) := mk_option.symm
    _ ≤ (#β) := (f.option_elim b hb).cardinal_le
#align cardinal.add_one_le_succ Cardinal.add_one_le_succ
-/

#print Cardinal.IsLimit /-
/-- A cardinal is a limit if it is not zero or a successor cardinal. Note that `ℵ₀` is a limit
  cardinal by this definition, but `0` isn't.

  Use `is_succ_limit` if you want to include the `c = 0` case. -/
def IsLimit (c : Cardinal) : Prop :=
  c ≠ 0 ∧ IsSuccLimit c
#align cardinal.is_limit Cardinal.IsLimit
-/

#print Cardinal.IsLimit.ne_zero /-
protected theorem IsLimit.ne_zero {c} (h : IsLimit c) : c ≠ 0 :=
  h.1
#align cardinal.is_limit.ne_zero Cardinal.IsLimit.ne_zero
-/

#print Cardinal.IsLimit.isSuccLimit /-
protected theorem IsLimit.isSuccLimit {c} (h : IsLimit c) : IsSuccLimit c :=
  h.2
#align cardinal.is_limit.is_succ_limit Cardinal.IsLimit.isSuccLimit
-/

#print Cardinal.IsLimit.succ_lt /-
theorem IsLimit.succ_lt {x c} (h : IsLimit c) : x < c → succ x < c :=
  h.IsSuccLimit.succ_lt
#align cardinal.is_limit.succ_lt Cardinal.IsLimit.succ_lt
-/

#print Cardinal.isSuccLimit_zero /-
theorem isSuccLimit_zero : IsSuccLimit (0 : Cardinal) :=
  isSuccLimit_bot
#align cardinal.is_succ_limit_zero Cardinal.isSuccLimit_zero
-/

#print Cardinal.sum /-
/-- The indexed sum of cardinals is the cardinality of the
  indexed disjoint union, i.e. sigma type. -/
def sum {ι} (f : ι → Cardinal) : Cardinal :=
  mk (Σ i, (f i).out)
#align cardinal.sum Cardinal.sum
-/

#print Cardinal.le_sum /-
theorem le_sum {ι} (f : ι → Cardinal) (i) : f i ≤ sum f := by
  rw [← Quotient.out_eq (f i)] <;>
    exact ⟨⟨fun a => ⟨i, a⟩, fun a b h => eq_of_hEq <| by injection h⟩⟩
#align cardinal.le_sum Cardinal.le_sum
-/

#print Cardinal.mk_sigma /-
@[simp]
theorem mk_sigma {ι} (f : ι → Type _) : (#Σ i, f i) = sum fun i => #f i :=
  mk_congr <| Equiv.sigmaCongrRight fun i => outMkEquiv.symm
#align cardinal.mk_sigma Cardinal.mk_sigma
-/

#print Cardinal.sum_const /-
@[simp]
theorem sum_const (ι : Type u) (a : Cardinal.{v}) :
    (sum fun i : ι => a) = lift.{v} (#ι) * lift.{u} a :=
  inductionOn a fun α =>
    mk_congr <|
      calc
        (Σ i : ι, Quotient.out (#α)) ≃ ι × Quotient.out (#α) := Equiv.sigmaEquivProd _ _
        _ ≃ ULift ι × ULift α := Equiv.ulift.symm.prodCongr (outMkEquiv.trans Equiv.ulift.symm)
#align cardinal.sum_const Cardinal.sum_const
-/

#print Cardinal.sum_const' /-
theorem sum_const' (ι : Type u) (a : Cardinal.{u}) : (sum fun _ : ι => a) = (#ι) * a := by simp
#align cardinal.sum_const' Cardinal.sum_const'
-/

#print Cardinal.sum_add_distrib /-
@[simp]
theorem sum_add_distrib {ι} (f g : ι → Cardinal) : sum (f + g) = sum f + sum g := by
  simpa only [mk_sigma, mk_sum, mk_out, lift_id] using
    mk_congr (Equiv.sigmaSumDistrib (Quotient.out ∘ f) (Quotient.out ∘ g))
#align cardinal.sum_add_distrib Cardinal.sum_add_distrib
-/

#print Cardinal.sum_add_distrib' /-
@[simp]
theorem sum_add_distrib' {ι} (f g : ι → Cardinal) :
    (Cardinal.sum fun i => f i + g i) = sum f + sum g :=
  sum_add_distrib f g
#align cardinal.sum_add_distrib' Cardinal.sum_add_distrib'
-/

#print Cardinal.lift_sum /-
@[simp]
theorem lift_sum {ι : Type u} (f : ι → Cardinal.{v}) :
    Cardinal.lift.{w} (Cardinal.sum f) = Cardinal.sum fun i => Cardinal.lift.{w} (f i) :=
  Equiv.cardinal_eq <|
    Equiv.ulift.trans <|
      Equiv.sigmaCongrRight fun a =>
        Nonempty.some <| by rw [← lift_mk_eq, mk_out, mk_out, lift_lift]
#align cardinal.lift_sum Cardinal.lift_sum
-/

#print Cardinal.sum_le_sum /-
theorem sum_le_sum {ι} (f g : ι → Cardinal) (H : ∀ i, f i ≤ g i) : sum f ≤ sum g :=
  ⟨(Embedding.refl _).sigma_map fun i =>
      Classical.choice <| by have := H i <;> rwa [← Quot.out_eq (f i), ← Quot.out_eq (g i)] at this⟩
#align cardinal.sum_le_sum Cardinal.sum_le_sum
-/

#print Cardinal.mk_le_mk_mul_of_mk_preimage_le /-
theorem mk_le_mk_mul_of_mk_preimage_le {c : Cardinal} (f : α → β) (hf : ∀ b : β, (#f ⁻¹' {b}) ≤ c) :
    (#α) ≤ (#β) * c := by
  simpa only [← mk_congr (@Equiv.sigmaFiberEquiv α β f), mk_sigma, ← sum_const'] using
    sum_le_sum _ _ hf
#align cardinal.mk_le_mk_mul_of_mk_preimage_le Cardinal.mk_le_mk_mul_of_mk_preimage_le
-/

#print Cardinal.lift_mk_le_lift_mk_mul_of_lift_mk_preimage_le /-
theorem lift_mk_le_lift_mk_mul_of_lift_mk_preimage_le {α : Type u} {β : Type v} {c : Cardinal}
    (f : α → β) (hf : ∀ b : β, lift.{v} (#f ⁻¹' {b}) ≤ c) : lift.{v} (#α) ≤ lift.{u} (#β) * c :=
  (mk_le_mk_mul_of_mk_preimage_le fun x : ULift.{v} α => ULift.up.{u} (f x.1)) <|
    ULift.forall.2 fun b =>
      (mk_congr <|
            (Equiv.ulift.image _).trans
              (Equiv.trans (by rw [Equiv.image_eq_preimage]; simp [Set.preimage])
                Equiv.ulift.symm)).trans_le
        (hf b)
#align cardinal.lift_mk_le_lift_mk_mul_of_lift_mk_preimage_le Cardinal.lift_mk_le_lift_mk_mul_of_lift_mk_preimage_le
-/

#print Cardinal.bddAbove_range /-
/-- The range of an indexed cardinal function, whose outputs live in a higher universe than the
    inputs, is always bounded above. -/
theorem bddAbove_range {ι : Type u} (f : ι → Cardinal.{max u v}) : BddAbove (Set.range f) :=
  ⟨_, by rintro a ⟨i, rfl⟩; exact le_sum f i⟩
#align cardinal.bdd_above_range Cardinal.bddAbove_range
-/

instance (a : Cardinal.{u}) : Small.{u} (Set.Iic a) :=
  by
  rw [← mk_out a]
  apply @small_of_surjective (Set a.out) (Iic (#a.out)) _ fun x => ⟨#x, mk_set_le x⟩
  rintro ⟨x, hx⟩
  simpa using le_mk_iff_exists_set.1 hx

instance (a : Cardinal.{u}) : Small.{u} (Set.Iio a) :=
  small_subset Iio_subset_Iic_self

#print Cardinal.bddAbove_iff_small /-
/-- A set of cardinals is bounded above iff it's small, i.e. it corresponds to an usual ZFC set. -/
theorem bddAbove_iff_small {s : Set Cardinal.{u}} : BddAbove s ↔ Small.{u} s :=
  ⟨fun ⟨a, ha⟩ => @small_subset _ (Iic a) s (fun x h => ha h) _,
    by
    rintro ⟨ι, ⟨e⟩⟩
    suffices (range fun x : ι => (e.symm x).1) = s
      by
      rw [← this]
      apply bddAbove_range.{u, u}
    ext x
    refine' ⟨_, fun hx => ⟨e ⟨x, hx⟩, _⟩⟩
    · rintro ⟨a, rfl⟩
      exact (e.symm a).IProp
    · simp_rw [Subtype.val_eq_coe, Equiv.symm_apply_apply]; rfl⟩
#align cardinal.bdd_above_iff_small Cardinal.bddAbove_iff_small
-/

#print Cardinal.bddAbove_of_small /-
theorem bddAbove_of_small (s : Set Cardinal.{u}) [h : Small.{u} s] : BddAbove s :=
  bddAbove_iff_small.2 h
#align cardinal.bdd_above_of_small Cardinal.bddAbove_of_small
-/

#print Cardinal.bddAbove_image /-
theorem bddAbove_image (f : Cardinal.{u} → Cardinal.{max u v}) {s : Set Cardinal.{u}}
    (hs : BddAbove s) : BddAbove (f '' s) := by rw [bdd_above_iff_small] at hs ⊢; exact small_lift _
#align cardinal.bdd_above_image Cardinal.bddAbove_image
-/

#print Cardinal.bddAbove_range_comp /-
theorem bddAbove_range_comp {ι : Type u} {f : ι → Cardinal.{v}} (hf : BddAbove (range f))
    (g : Cardinal.{v} → Cardinal.{max v w}) : BddAbove (range (g ∘ f)) := by rw [range_comp];
  exact bdd_above_image g hf
#align cardinal.bdd_above_range_comp Cardinal.bddAbove_range_comp
-/

#print Cardinal.iSup_le_sum /-
theorem iSup_le_sum {ι} (f : ι → Cardinal) : iSup f ≤ sum f :=
  ciSup_le' <| le_sum _
#align cardinal.supr_le_sum Cardinal.iSup_le_sum
-/

#print Cardinal.sum_le_iSup_lift /-
theorem sum_le_iSup_lift {ι : Type u} (f : ι → Cardinal.{max u v}) : sum f ≤ (#ι).lift * iSup f :=
  by
  rw [← (iSup f).lift_id, ← lift_umax, lift_umax.{max u v, u}, ← sum_const]
  exact sum_le_sum _ _ (le_ciSup <| bddAbove_range.{u, v} f)
#align cardinal.sum_le_supr_lift Cardinal.sum_le_iSup_lift
-/

#print Cardinal.sum_le_iSup /-
theorem sum_le_iSup {ι : Type u} (f : ι → Cardinal.{u}) : sum f ≤ (#ι) * iSup f := by
  rw [← lift_id (#ι)]; exact sum_le_supr_lift f
#align cardinal.sum_le_supr Cardinal.sum_le_iSup
-/

#print Cardinal.sum_nat_eq_add_sum_succ /-
theorem sum_nat_eq_add_sum_succ (f : ℕ → Cardinal.{u}) :
    Cardinal.sum f = f 0 + Cardinal.sum fun i => f (i + 1) :=
  by
  refine' (Equiv.sigmaNatSucc fun i => Quotient.out (f i)).cardinal_eq.trans _
  simp only [mk_sum, mk_out, lift_id, mk_sigma]
#align cardinal.sum_nat_eq_add_sum_succ Cardinal.sum_nat_eq_add_sum_succ
-/

#print Cardinal.iSup_of_empty /-
/-- A variant of `csupr_of_empty` but with `0` on the RHS for convenience -/
@[simp]
protected theorem iSup_of_empty {ι} (f : ι → Cardinal) [IsEmpty ι] : iSup f = 0 :=
  ciSup_of_empty f
#align cardinal.supr_of_empty Cardinal.iSup_of_empty
-/

#print Cardinal.lift_mk_shrink /-
@[simp]
theorem lift_mk_shrink (α : Type u) [Small.{v} α] :
    Cardinal.lift.{max u w} (#Shrink.{v} α) = Cardinal.lift.{max v w} (#α) :=
  lift_mk_eq.2 ⟨(equivShrink α).symm⟩
#align cardinal.lift_mk_shrink Cardinal.lift_mk_shrink
-/

#print Cardinal.lift_mk_shrink' /-
@[simp]
theorem lift_mk_shrink' (α : Type u) [Small.{v} α] :
    Cardinal.lift.{u} (#Shrink.{v} α) = Cardinal.lift.{v} (#α) :=
  lift_mk_shrink.{u, v, 0} α
#align cardinal.lift_mk_shrink' Cardinal.lift_mk_shrink'
-/

#print Cardinal.lift_mk_shrink'' /-
@[simp]
theorem lift_mk_shrink'' (α : Type max u v) [Small.{v} α] :
    Cardinal.lift.{u} (#Shrink.{v} α) = (#α) := by
  rw [← lift_umax', lift_mk_shrink.{max u v, v, 0} α, ← lift_umax, lift_id]
#align cardinal.lift_mk_shrink'' Cardinal.lift_mk_shrink''
-/

#print Cardinal.prod /-
/-- The indexed product of cardinals is the cardinality of the Pi type
  (dependent product). -/
def prod {ι : Type u} (f : ι → Cardinal) : Cardinal :=
  #∀ i, (f i).out
#align cardinal.prod Cardinal.prod
-/

#print Cardinal.mk_pi /-
@[simp]
theorem mk_pi {ι : Type u} (α : ι → Type v) : (#∀ i, α i) = prod fun i => #α i :=
  mk_congr <| Equiv.piCongrRight fun i => outMkEquiv.symm
#align cardinal.mk_pi Cardinal.mk_pi
-/

#print Cardinal.prod_const /-
@[simp]
theorem prod_const (ι : Type u) (a : Cardinal.{v}) :
    (prod fun i : ι => a) = (lift.{u} a^lift.{v} (#ι)) :=
  inductionOn a fun α =>
    mk_congr <| Equiv.piCongr Equiv.ulift.symm fun i => outMkEquiv.trans Equiv.ulift.symm
#align cardinal.prod_const Cardinal.prod_const
-/

#print Cardinal.prod_const' /-
theorem prod_const' (ι : Type u) (a : Cardinal.{u}) : (prod fun _ : ι => a) = (a^#ι) :=
  inductionOn a fun α => (mk_pi _).symm
#align cardinal.prod_const' Cardinal.prod_const'
-/

#print Cardinal.prod_le_prod /-
theorem prod_le_prod {ι} (f g : ι → Cardinal) (H : ∀ i, f i ≤ g i) : prod f ≤ prod g :=
  ⟨Embedding.piCongrRight fun i =>
      Classical.choice <| by have := H i <;> rwa [← mk_out (f i), ← mk_out (g i)] at this⟩
#align cardinal.prod_le_prod Cardinal.prod_le_prod
-/

#print Cardinal.prod_eq_zero /-
@[simp]
theorem prod_eq_zero {ι} (f : ι → Cardinal.{u}) : prod f = 0 ↔ ∃ i, f i = 0 := by
  lift f to ι → Type u using fun _ => trivial; simp only [mk_eq_zero_iff, ← mk_pi, isEmpty_pi]
#align cardinal.prod_eq_zero Cardinal.prod_eq_zero
-/

#print Cardinal.prod_ne_zero /-
theorem prod_ne_zero {ι} (f : ι → Cardinal) : prod f ≠ 0 ↔ ∀ i, f i ≠ 0 := by simp [prod_eq_zero]
#align cardinal.prod_ne_zero Cardinal.prod_ne_zero
-/

#print Cardinal.lift_prod /-
@[simp]
theorem lift_prod {ι : Type u} (c : ι → Cardinal.{v}) :
    lift.{w} (prod c) = prod fun i => lift.{w} (c i) :=
  by
  lift c to ι → Type v using fun _ => trivial
  simp only [← mk_pi, ← mk_ulift]
  exact mk_congr (equiv.ulift.trans <| Equiv.piCongrRight fun i => equiv.ulift.symm)
#align cardinal.lift_prod Cardinal.lift_prod
-/

#print Cardinal.prod_eq_of_fintype /-
theorem prod_eq_of_fintype {α : Type u} [Fintype α] (f : α → Cardinal.{v}) :
    prod f = Cardinal.lift.{u} (∏ i, f i) := by
  revert f
  refine' Fintype.induction_empty_option _ _ _ α
  · intro α β hβ e h f
    letI := Fintype.ofEquiv β e.symm
    rw [← e.prod_comp f, ← h]
    exact mk_congr (e.Pi_congr_left _).symm
  · intro f
    rw [Fintype.univ_pempty, Finset.prod_empty, lift_one, Cardinal.prod, mk_eq_one]
  · intro α hα h f
    rw [Cardinal.prod, mk_congr Equiv.piOptionEquivProd, mk_prod, lift_umax', mk_out, ←
      Cardinal.prod, lift_prod, Fintype.prod_option, lift_mul, ← h fun a => f (some a)]
    simp only [lift_id]
#align cardinal.prod_eq_of_fintype Cardinal.prod_eq_of_fintype
-/

#print Cardinal.lift_sInf /-
@[simp]
theorem lift_sInf (s : Set Cardinal) : lift (sInf s) = sInf (lift '' s) :=
  by
  rcases eq_empty_or_nonempty s with (rfl | hs)
  · simp
  · exact lift_monotone.map_Inf hs
#align cardinal.lift_Inf Cardinal.lift_sInf
-/

#print Cardinal.lift_iInf /-
@[simp]
theorem lift_iInf {ι} (f : ι → Cardinal) : lift (iInf f) = ⨅ i, lift (f i) := by unfold iInf;
  convert lift_Inf (range f); rw [range_comp]
#align cardinal.lift_infi Cardinal.lift_iInf
-/

#print Cardinal.lift_down /-
theorem lift_down {a : Cardinal.{u}} {b : Cardinal.{max u v}} : b ≤ lift a → ∃ a', lift a' = b :=
  inductionOn₂ a b fun α β => by
    rw [← lift_id (#β), ← lift_umax, ← lift_umax.{u, v}, lift_mk_le] <;>
      exact fun ⟨f⟩ =>
        ⟨#Set.range f,
          Eq.symm <|
            lift_mk_eq.2
              ⟨embedding.equiv_of_surjective (Embedding.codRestrict _ f Set.mem_range_self)
                  fun ⟨a, ⟨b, e⟩⟩ => ⟨b, Subtype.eq e⟩⟩⟩
#align cardinal.lift_down Cardinal.lift_down
-/

#print Cardinal.le_lift_iff /-
theorem le_lift_iff {a : Cardinal.{u}} {b : Cardinal.{max u v}} :
    b ≤ lift a ↔ ∃ a', lift a' = b ∧ a' ≤ a :=
  ⟨fun h =>
    let ⟨a', e⟩ := lift_down h
    ⟨a', e, lift_le.1 <| e.symm ▸ h⟩,
    fun ⟨a', e, h⟩ => e ▸ lift_le.2 h⟩
#align cardinal.le_lift_iff Cardinal.le_lift_iff
-/

#print Cardinal.lt_lift_iff /-
theorem lt_lift_iff {a : Cardinal.{u}} {b : Cardinal.{max u v}} :
    b < lift a ↔ ∃ a', lift a' = b ∧ a' < a :=
  ⟨fun h =>
    let ⟨a', e⟩ := lift_down h.le
    ⟨a', e, lift_lt.1 <| e.symm ▸ h⟩,
    fun ⟨a', e, h⟩ => e ▸ lift_lt.2 h⟩
#align cardinal.lt_lift_iff Cardinal.lt_lift_iff
-/

#print Cardinal.lift_succ /-
@[simp]
theorem lift_succ (a) : lift (succ a) = succ (lift a) :=
  le_antisymm
    (le_of_not_gt fun h => by
      rcases lt_lift_iff.1 h with ⟨b, e, h⟩
      rw [lt_succ_iff, ← lift_le, e] at h
      exact h.not_lt (lt_succ _))
    (succ_le_of_lt <| lift_lt.2 <| lt_succ a)
#align cardinal.lift_succ Cardinal.lift_succ
-/

#print Cardinal.lift_umax_eq /-
@[simp]
theorem lift_umax_eq {a : Cardinal.{u}} {b : Cardinal.{v}} :
    lift.{max v w} a = lift.{max u w} b ↔ lift.{v} a = lift.{u} b := by
  rw [← lift_lift, ← lift_lift, lift_inj]
#align cardinal.lift_umax_eq Cardinal.lift_umax_eq
-/

#print Cardinal.lift_min /-
@[simp]
theorem lift_min {a b : Cardinal} : lift (min a b) = min (lift a) (lift b) :=
  lift_monotone.map_min
#align cardinal.lift_min Cardinal.lift_min
-/

#print Cardinal.lift_max /-
@[simp]
theorem lift_max {a b : Cardinal} : lift (max a b) = max (lift a) (lift b) :=
  lift_monotone.map_max
#align cardinal.lift_max Cardinal.lift_max
-/

#print Cardinal.lift_sSup /-
/-- The lift of a supremum is the supremum of the lifts. -/
theorem lift_sSup {s : Set Cardinal} (hs : BddAbove s) : lift.{u} (sSup s) = sSup (lift.{u} '' s) :=
  by
  apply ((le_csSup_iff' (bdd_above_image _ hs)).2 fun c hc => _).antisymm (csSup_le' _)
  · by_contra h
    obtain ⟨d, rfl⟩ := Cardinal.lift_down (not_le.1 h).le
    simp_rw [lift_le] at h hc
    rw [csSup_le_iff' hs] at h
    exact h fun a ha => lift_le.1 <| hc (mem_image_of_mem _ ha)
  · rintro i ⟨j, hj, rfl⟩
    exact lift_le.2 (le_csSup hs hj)
#align cardinal.lift_Sup Cardinal.lift_sSup
-/

#print Cardinal.lift_iSup /-
/-- The lift of a supremum is the supremum of the lifts. -/
theorem lift_iSup {ι : Type v} {f : ι → Cardinal.{w}} (hf : BddAbove (range f)) :
    lift.{u} (iSup f) = ⨆ i, lift.{u} (f i) := by rw [iSup, iSup, lift_Sup hf, ← range_comp]
#align cardinal.lift_supr Cardinal.lift_iSup
-/

#print Cardinal.lift_iSup_le /-
/-- To prove that the lift of a supremum is bounded by some cardinal `t`,
it suffices to show that the lift of each cardinal is bounded by `t`. -/
theorem lift_iSup_le {ι : Type v} {f : ι → Cardinal.{w}} {t : Cardinal} (hf : BddAbove (range f))
    (w : ∀ i, lift.{u} (f i) ≤ t) : lift.{u} (iSup f) ≤ t := by rw [lift_supr hf]; exact ciSup_le' w
#align cardinal.lift_supr_le Cardinal.lift_iSup_le
-/

#print Cardinal.lift_iSup_le_iff /-
@[simp]
theorem lift_iSup_le_iff {ι : Type v} {f : ι → Cardinal.{w}} (hf : BddAbove (range f))
    {t : Cardinal} : lift.{u} (iSup f) ≤ t ↔ ∀ i, lift.{u} (f i) ≤ t := by rw [lift_supr hf];
  exact ciSup_le_iff' (bdd_above_range_comp hf _)
#align cardinal.lift_supr_le_iff Cardinal.lift_iSup_le_iff
-/

universe v' w'

#print Cardinal.lift_iSup_le_lift_iSup /-
/-- To prove an inequality between the lifts to a common universe of two different supremums,
it suffices to show that the lift of each cardinal from the smaller supremum
if bounded by the lift of some cardinal from the larger supremum.
-/
theorem lift_iSup_le_lift_iSup {ι : Type v} {ι' : Type v'} {f : ι → Cardinal.{w}}
    {f' : ι' → Cardinal.{w'}} (hf : BddAbove (range f)) (hf' : BddAbove (range f')) {g : ι → ι'}
    (h : ∀ i, lift.{w'} (f i) ≤ lift.{w} (f' (g i))) : lift.{w'} (iSup f) ≤ lift.{w} (iSup f') :=
  by
  rw [lift_supr hf, lift_supr hf']
  exact ciSup_mono' (bdd_above_range_comp hf' _) fun i => ⟨_, h i⟩
#align cardinal.lift_supr_le_lift_supr Cardinal.lift_iSup_le_lift_iSup
-/

#print Cardinal.lift_iSup_le_lift_iSup' /-
/-- A variant of `lift_supr_le_lift_supr` with universes specialized via `w = v` and `w' = v'`.
This is sometimes necessary to avoid universe unification issues. -/
theorem lift_iSup_le_lift_iSup' {ι : Type v} {ι' : Type v'} {f : ι → Cardinal.{v}}
    {f' : ι' → Cardinal.{v'}} (hf : BddAbove (range f)) (hf' : BddAbove (range f')) (g : ι → ι')
    (h : ∀ i, lift.{v'} (f i) ≤ lift.{v} (f' (g i))) : lift.{v'} (iSup f) ≤ lift.{v} (iSup f') :=
  lift_iSup_le_lift_iSup hf hf' h
#align cardinal.lift_supr_le_lift_supr' Cardinal.lift_iSup_le_lift_iSup'
-/

#print Cardinal.aleph0 /-
/-- `ℵ₀` is the smallest infinite cardinal. -/
def aleph0 : Cardinal.{u} :=
  lift (#ℕ)
#align cardinal.aleph_0 Cardinal.aleph0
-/

scoped notation "ℵ₀" => Cardinal.aleph0

#print Cardinal.mk_nat /-
theorem mk_nat : (#ℕ) = ℵ₀ :=
  (lift_id _).symm
#align cardinal.mk_nat Cardinal.mk_nat
-/

#print Cardinal.aleph0_ne_zero /-
theorem aleph0_ne_zero : ℵ₀ ≠ 0 :=
  mk_ne_zero _
#align cardinal.aleph_0_ne_zero Cardinal.aleph0_ne_zero
-/

#print Cardinal.aleph0_pos /-
theorem aleph0_pos : 0 < ℵ₀ :=
  pos_iff_ne_zero.2 aleph0_ne_zero
#align cardinal.aleph_0_pos Cardinal.aleph0_pos
-/

#print Cardinal.lift_aleph0 /-
@[simp]
theorem lift_aleph0 : lift ℵ₀ = ℵ₀ :=
  lift_lift _
#align cardinal.lift_aleph_0 Cardinal.lift_aleph0
-/

#print Cardinal.aleph0_le_lift /-
@[simp]
theorem aleph0_le_lift {c : Cardinal.{u}} : ℵ₀ ≤ lift.{v} c ↔ ℵ₀ ≤ c := by
  rw [← lift_aleph_0, lift_le]
#align cardinal.aleph_0_le_lift Cardinal.aleph0_le_lift
-/

#print Cardinal.lift_le_aleph0 /-
@[simp]
theorem lift_le_aleph0 {c : Cardinal.{u}} : lift.{v} c ≤ ℵ₀ ↔ c ≤ ℵ₀ := by
  rw [← lift_aleph_0, lift_le]
#align cardinal.lift_le_aleph_0 Cardinal.lift_le_aleph0
-/

#print Cardinal.aleph0_lt_lift /-
@[simp]
theorem aleph0_lt_lift {c : Cardinal.{u}} : ℵ₀ < lift.{v} c ↔ ℵ₀ < c := by
  rw [← lift_aleph_0, lift_lt]
#align cardinal.aleph_0_lt_lift Cardinal.aleph0_lt_lift
-/

#print Cardinal.lift_lt_aleph0 /-
@[simp]
theorem lift_lt_aleph0 {c : Cardinal.{u}} : lift.{v} c < ℵ₀ ↔ c < ℵ₀ := by
  rw [← lift_aleph_0, lift_lt]
#align cardinal.lift_lt_aleph_0 Cardinal.lift_lt_aleph0
-/

/-! ### Properties about the cast from `ℕ` -/


#print Cardinal.mk_fin /-
@[simp]
theorem mk_fin (n : ℕ) : (#Fin n) = n := by simp
#align cardinal.mk_fin Cardinal.mk_fin
-/

#print Cardinal.lift_natCast /-
@[simp]
theorem lift_natCast (n : ℕ) : lift.{u} (n : Cardinal.{v}) = n := by induction n <;> simp [*]
#align cardinal.lift_nat_cast Cardinal.lift_natCast
-/

#print Cardinal.lift_eq_nat_iff /-
@[simp]
theorem lift_eq_nat_iff {a : Cardinal.{u}} {n : ℕ} : lift.{v} a = n ↔ a = n :=
  lift_injective.eq_iff' (lift_natCast n)
#align cardinal.lift_eq_nat_iff Cardinal.lift_eq_nat_iff
-/

#print Cardinal.nat_eq_lift_iff /-
@[simp]
theorem nat_eq_lift_iff {n : ℕ} {a : Cardinal.{u}} :
    (n : Cardinal) = lift.{v} a ↔ (n : Cardinal) = a := by rw [← lift_natCast.{v} n, lift_inj]
#align cardinal.nat_eq_lift_iff Cardinal.nat_eq_lift_iff
-/

#print Cardinal.lift_le_nat_iff /-
@[simp]
theorem lift_le_nat_iff {a : Cardinal.{u}} {n : ℕ} : lift.{v} a ≤ n ↔ a ≤ n := by
  simp only [← lift_nat_cast, lift_le]
#align cardinal.lift_le_nat_iff Cardinal.lift_le_nat_iff
-/

#print Cardinal.nat_le_lift_iff /-
@[simp]
theorem nat_le_lift_iff {n : ℕ} {a : Cardinal.{u}} :
    (n : Cardinal) ≤ lift.{v} a ↔ (n : Cardinal) ≤ a := by simp only [← lift_nat_cast, lift_le]
#align cardinal.nat_le_lift_iff Cardinal.nat_le_lift_iff
-/

#print Cardinal.lift_lt_nat_iff /-
@[simp]
theorem lift_lt_nat_iff {a : Cardinal.{u}} {n : ℕ} : lift.{v} a < n ↔ a < n := by
  simp only [← lift_nat_cast, lift_lt]
#align cardinal.lift_lt_nat_iff Cardinal.lift_lt_nat_iff
-/

#print Cardinal.nat_lt_lift_iff /-
@[simp]
theorem nat_lt_lift_iff {n : ℕ} {a : Cardinal.{u}} :
    (n : Cardinal) < lift.{v} a ↔ (n : Cardinal) < a := by simp only [← lift_nat_cast, lift_lt]
#align cardinal.nat_lt_lift_iff Cardinal.nat_lt_lift_iff
-/

#print Cardinal.lift_mk_fin /-
theorem lift_mk_fin (n : ℕ) : lift (#Fin n) = n := by simp
#align cardinal.lift_mk_fin Cardinal.lift_mk_fin
-/

#print Cardinal.mk_coe_finset /-
theorem mk_coe_finset {α : Type u} {s : Finset α} : (#s) = ↑(Finset.card s) := by simp
#align cardinal.mk_coe_finset Cardinal.mk_coe_finset
-/

#print Cardinal.mk_finset_of_fintype /-
theorem mk_finset_of_fintype [Fintype α] : (#Finset α) = 2 ^ℕ Fintype.card α := by simp
#align cardinal.mk_finset_of_fintype Cardinal.mk_finset_of_fintype
-/

#print Cardinal.mk_finsupp_lift_of_fintype /-
@[simp]
theorem mk_finsupp_lift_of_fintype (α : Type u) (β : Type v) [Fintype α] [Zero β] :
    (#α →₀ β) = lift.{u} (#β) ^ℕ Fintype.card α := by
  simpa using (@Finsupp.equivFunOnFinite α β _ _).cardinal_eq
#align cardinal.mk_finsupp_lift_of_fintype Cardinal.mk_finsupp_lift_of_fintype
-/

#print Cardinal.mk_finsupp_of_fintype /-
theorem mk_finsupp_of_fintype (α β : Type u) [Fintype α] [Zero β] :
    (#α →₀ β) = (#β) ^ℕ Fintype.card α := by simp
#align cardinal.mk_finsupp_of_fintype Cardinal.mk_finsupp_of_fintype
-/

#print Cardinal.card_le_of_finset /-
theorem card_le_of_finset {α} (s : Finset α) : (s.card : Cardinal) ≤ (#α) :=
  @mk_coe_finset _ s ▸ mk_set_le _
#align cardinal.card_le_of_finset Cardinal.card_le_of_finset
-/

#print Cardinal.natCast_pow /-
@[simp, norm_cast]
theorem natCast_pow {m n : ℕ} : (↑(pow m n) : Cardinal) = (m^n) := by
  induction n <;> simp [pow_succ, power_add, *]
#align cardinal.nat_cast_pow Cardinal.natCast_pow
-/

#print Cardinal.natCast_le /-
@[simp, norm_cast]
theorem natCast_le {m n : ℕ} : (m : Cardinal) ≤ n ↔ m ≤ n := by
  rw [← lift_mk_fin, ← lift_mk_fin, lift_le, le_def, Function.Embedding.nonempty_iff_card_le,
    Fintype.card_fin, Fintype.card_fin]
#align cardinal.nat_cast_le Cardinal.natCast_le
-/

#print Cardinal.natCast_lt /-
@[simp, norm_cast]
theorem natCast_lt {m n : ℕ} : (m : Cardinal) < n ↔ m < n := by simp [lt_iff_le_not_le, ← not_le]
#align cardinal.nat_cast_lt Cardinal.natCast_lt
-/

instance : CharZero Cardinal :=
  ⟨StrictMono.injective fun m n => natCast_lt.2⟩

#print Cardinal.natCast_inj /-
theorem natCast_inj {m n : ℕ} : (m : Cardinal) = n ↔ m = n :=
  Nat.cast_inj
#align cardinal.nat_cast_inj Cardinal.natCast_inj
-/

#print Cardinal.natCast_injective /-
theorem natCast_injective : Injective (coe : ℕ → Cardinal) :=
  Nat.cast_injective
#align cardinal.nat_cast_injective Cardinal.natCast_injective
-/

#print Cardinal.nat_succ /-
@[simp, norm_cast]
theorem nat_succ (n : ℕ) : (n.succ : Cardinal) = succ n :=
  (add_one_le_succ _).antisymm (succ_le_of_lt <| natCast_lt.2 <| Nat.lt_succ_self _)
#align cardinal.nat_succ Cardinal.nat_succ
-/

#print Cardinal.succ_zero /-
@[simp]
theorem succ_zero : succ (0 : Cardinal) = 1 := by norm_cast
#align cardinal.succ_zero Cardinal.succ_zero
-/

#print Cardinal.card_le_of /-
theorem card_le_of {α : Type u} {n : ℕ} (H : ∀ s : Finset α, s.card ≤ n) : (#α) ≤ n :=
  by
  refine' le_of_lt_succ (lt_of_not_ge fun hn => _)
  rw [← Cardinal.nat_succ, ← lift_mk_fin n.succ] at hn
  cases' hn with f
  refine' (H <| finset.univ.map f).not_lt _
  rw [Finset.card_map, ← Fintype.card, Fintype.card_ulift, Fintype.card_fin]
  exact n.lt_succ_self
#align cardinal.card_le_of Cardinal.card_le_of
-/

#print Cardinal.cantor' /-
theorem cantor' (a) {b : Cardinal} (hb : 1 < b) : a < (b^a) :=
  by
  rw [← succ_le_iff, (by norm_cast : succ (1 : Cardinal) = 2)] at hb
  exact (cantor a).trans_le (power_le_power_right hb)
#align cardinal.cantor' Cardinal.cantor'
-/

#print Cardinal.one_le_iff_pos /-
theorem one_le_iff_pos {c : Cardinal} : 1 ≤ c ↔ 0 < c := by rw [← succ_zero, succ_le_iff]
#align cardinal.one_le_iff_pos Cardinal.one_le_iff_pos
-/

#print Cardinal.one_le_iff_ne_zero /-
theorem one_le_iff_ne_zero {c : Cardinal} : 1 ≤ c ↔ c ≠ 0 := by rw [one_le_iff_pos, pos_iff_ne_zero]
#align cardinal.one_le_iff_ne_zero Cardinal.one_le_iff_ne_zero
-/

#print Cardinal.nat_lt_aleph0 /-
theorem nat_lt_aleph0 (n : ℕ) : (n : Cardinal.{u}) < ℵ₀ :=
  succ_le_iff.1
    (by
      rw [← nat_succ, ← lift_mk_fin, aleph_0, lift_mk_le.{0, 0, u}]
      exact ⟨⟨coe, fun a b => Fin.ext⟩⟩)
#align cardinal.nat_lt_aleph_0 Cardinal.nat_lt_aleph0
-/

#print Cardinal.one_lt_aleph0 /-
@[simp]
theorem one_lt_aleph0 : 1 < ℵ₀ := by simpa using nat_lt_aleph_0 1
#align cardinal.one_lt_aleph_0 Cardinal.one_lt_aleph0
-/

#print Cardinal.one_le_aleph0 /-
theorem one_le_aleph0 : 1 ≤ ℵ₀ :=
  one_lt_aleph0.le
#align cardinal.one_le_aleph_0 Cardinal.one_le_aleph0
-/

#print Cardinal.lt_aleph0 /-
theorem lt_aleph0 {c : Cardinal} : c < ℵ₀ ↔ ∃ n : ℕ, c = n :=
  ⟨fun h => by
    rcases lt_lift_iff.1 h with ⟨c, rfl, h'⟩
    rcases le_mk_iff_exists_set.1 h'.1 with ⟨S, rfl⟩
    suffices S.finite by
      lift S to Finset ℕ using this
      simp
    contrapose! h'
    haveI := infinite.to_subtype h'
    exact ⟨Infinite.natEmbedding S⟩, fun ⟨n, e⟩ => e.symm ▸ nat_lt_aleph0 _⟩
#align cardinal.lt_aleph_0 Cardinal.lt_aleph0
-/

#print Cardinal.aleph0_le /-
theorem aleph0_le {c : Cardinal} : ℵ₀ ≤ c ↔ ∀ n : ℕ, ↑n ≤ c :=
  ⟨fun h n => (nat_lt_aleph0 _).le.trans h, fun h =>
    le_of_not_lt fun hn => by
      rcases lt_aleph_0.1 hn with ⟨n, rfl⟩
      exact (Nat.lt_succ_self _).not_le (nat_cast_le.1 (h (n + 1)))⟩
#align cardinal.aleph_0_le Cardinal.aleph0_le
-/

#print Cardinal.isSuccLimit_aleph0 /-
theorem isSuccLimit_aleph0 : IsSuccLimit ℵ₀ :=
  isSuccLimit_of_succ_lt fun a ha =>
    by
    rcases lt_aleph_0.1 ha with ⟨n, rfl⟩
    rw [← nat_succ]
    apply nat_lt_aleph_0
#align cardinal.is_succ_limit_aleph_0 Cardinal.isSuccLimit_aleph0
-/

#print Cardinal.isLimit_aleph0 /-
theorem isLimit_aleph0 : IsLimit ℵ₀ :=
  ⟨aleph0_ne_zero, isSuccLimit_aleph0⟩
#align cardinal.is_limit_aleph_0 Cardinal.isLimit_aleph0
-/

#print Cardinal.IsLimit.aleph0_le /-
theorem IsLimit.aleph0_le {c : Cardinal} (h : IsLimit c) : ℵ₀ ≤ c :=
  by
  by_contra! h'
  rcases lt_aleph_0.1 h' with ⟨_ | n, rfl⟩
  · exact h.ne_zero.irrefl
  · rw [nat_succ] at h
    exact not_is_succ_limit_succ _ h.is_succ_limit
#align cardinal.is_limit.aleph_0_le Cardinal.IsLimit.aleph0_le
-/

#print Cardinal.range_natCast /-
@[simp]
theorem range_natCast : range (coe : ℕ → Cardinal) = Iio ℵ₀ :=
  ext fun x => by simp only [mem_Iio, mem_range, eq_comm, lt_aleph_0]
#align cardinal.range_nat_cast Cardinal.range_natCast
-/

#print Cardinal.mk_eq_nat_iff /-
theorem mk_eq_nat_iff {α : Type u} {n : ℕ} : (#α) = n ↔ Nonempty (α ≃ Fin n) := by
  rw [← lift_mk_fin, ← lift_uzero (#α), lift_mk_eq']
#align cardinal.mk_eq_nat_iff Cardinal.mk_eq_nat_iff
-/

#print Cardinal.lt_aleph0_iff_finite /-
theorem lt_aleph0_iff_finite {α : Type u} : (#α) < ℵ₀ ↔ Finite α := by
  simp only [lt_aleph_0, mk_eq_nat_iff, finite_iff_exists_equiv_fin]
#align cardinal.lt_aleph_0_iff_finite Cardinal.lt_aleph0_iff_finite
-/

#print Cardinal.lt_aleph0_iff_fintype /-
theorem lt_aleph0_iff_fintype {α : Type u} : (#α) < ℵ₀ ↔ Nonempty (Fintype α) :=
  lt_aleph0_iff_finite.trans (finite_iff_nonempty_fintype _)
#align cardinal.lt_aleph_0_iff_fintype Cardinal.lt_aleph0_iff_fintype
-/

#print Cardinal.lt_aleph0_of_finite /-
theorem lt_aleph0_of_finite (α : Type u) [Finite α] : (#α) < ℵ₀ :=
  lt_aleph0_iff_finite.2 ‹_›
#align cardinal.lt_aleph_0_of_finite Cardinal.lt_aleph0_of_finite
-/

#print Cardinal.lt_aleph0_iff_set_finite /-
@[simp]
theorem lt_aleph0_iff_set_finite {S : Set α} : (#S) < ℵ₀ ↔ S.Finite :=
  lt_aleph0_iff_finite.trans finite_coe_iff
#align cardinal.lt_aleph_0_iff_set_finite Cardinal.lt_aleph0_iff_set_finite
-/

alias ⟨_, _root_.set.finite.lt_aleph_0⟩ := lt_aleph_0_iff_set_finite
#align set.finite.lt_aleph_0 Set.Finite.lt_aleph0

#print Cardinal.lt_aleph0_iff_subtype_finite /-
@[simp]
theorem lt_aleph0_iff_subtype_finite {p : α → Prop} : (#{ x // p x }) < ℵ₀ ↔ {x | p x}.Finite :=
  lt_aleph0_iff_set_finite
#align cardinal.lt_aleph_0_iff_subtype_finite Cardinal.lt_aleph0_iff_subtype_finite
-/

#print Cardinal.mk_le_aleph0_iff /-
theorem mk_le_aleph0_iff : (#α) ≤ ℵ₀ ↔ Countable α := by
  rw [countable_iff_nonempty_embedding, aleph_0, ← lift_uzero (#α), lift_mk_le']
#align cardinal.mk_le_aleph_0_iff Cardinal.mk_le_aleph0_iff
-/

#print Cardinal.mk_le_aleph0 /-
@[simp]
theorem mk_le_aleph0 [Countable α] : (#α) ≤ ℵ₀ :=
  mk_le_aleph0_iff.mpr ‹_›
#align cardinal.mk_le_aleph_0 Cardinal.mk_le_aleph0
-/

#print Cardinal.le_aleph0_iff_set_countable /-
@[simp]
theorem le_aleph0_iff_set_countable {s : Set α} : (#s) ≤ ℵ₀ ↔ s.Countable := by
  rw [mk_le_aleph_0_iff, countable_coe_iff]
#align cardinal.le_aleph_0_iff_set_countable Cardinal.le_aleph0_iff_set_countable
-/

alias ⟨_, _root_.set.countable.le_aleph_0⟩ := le_aleph_0_iff_set_countable
#align set.countable.le_aleph_0 Set.Countable.le_aleph0

#print Cardinal.le_aleph0_iff_subtype_countable /-
@[simp]
theorem le_aleph0_iff_subtype_countable {p : α → Prop} :
    (#{ x // p x }) ≤ ℵ₀ ↔ {x | p x}.Countable :=
  le_aleph0_iff_set_countable
#align cardinal.le_aleph_0_iff_subtype_countable Cardinal.le_aleph0_iff_subtype_countable
-/

#print Cardinal.canLiftCardinalNat /-
instance canLiftCardinalNat : CanLift Cardinal ℕ coe fun x => x < ℵ₀ :=
  ⟨fun x hx =>
    let ⟨n, hn⟩ := lt_aleph0.mp hx
    ⟨n, hn.symm⟩⟩
#align cardinal.can_lift_cardinal_nat Cardinal.canLiftCardinalNat
-/

#print Cardinal.add_lt_aleph0 /-
theorem add_lt_aleph0 {a b : Cardinal} (ha : a < ℵ₀) (hb : b < ℵ₀) : a + b < ℵ₀ :=
  match a, b, lt_aleph0.1 ha, lt_aleph0.1 hb with
  | _, _, ⟨m, rfl⟩, ⟨n, rfl⟩ => by rw [← Nat.cast_add] <;> apply nat_lt_aleph_0
#align cardinal.add_lt_aleph_0 Cardinal.add_lt_aleph0
-/

#print Cardinal.add_lt_aleph0_iff /-
theorem add_lt_aleph0_iff {a b : Cardinal} : a + b < ℵ₀ ↔ a < ℵ₀ ∧ b < ℵ₀ :=
  ⟨fun h => ⟨(self_le_add_right _ _).trans_lt h, (self_le_add_left _ _).trans_lt h⟩, fun ⟨h1, h2⟩ =>
    add_lt_aleph0 h1 h2⟩
#align cardinal.add_lt_aleph_0_iff Cardinal.add_lt_aleph0_iff
-/

#print Cardinal.aleph0_le_add_iff /-
theorem aleph0_le_add_iff {a b : Cardinal} : ℵ₀ ≤ a + b ↔ ℵ₀ ≤ a ∨ ℵ₀ ≤ b := by
  simp only [← not_lt, add_lt_aleph_0_iff, not_and_or]
#align cardinal.aleph_0_le_add_iff Cardinal.aleph0_le_add_iff
-/

#print Cardinal.nsmul_lt_aleph0_iff /-
/-- See also `cardinal.nsmul_lt_aleph_0_iff_of_ne_zero` if you already have `n ≠ 0`. -/
theorem nsmul_lt_aleph0_iff {n : ℕ} {a : Cardinal} : n • a < ℵ₀ ↔ n = 0 ∨ a < ℵ₀ :=
  by
  cases n
  · simpa using nat_lt_aleph_0 0
  simp only [Nat.succ_ne_zero, false_or_iff]
  induction' n with n ih
  · simp
  rw [succ_nsmul', add_lt_aleph_0_iff, ih, and_self_iff]
#align cardinal.nsmul_lt_aleph_0_iff Cardinal.nsmul_lt_aleph0_iff
-/

#print Cardinal.nsmul_lt_aleph0_iff_of_ne_zero /-
/-- See also `cardinal.nsmul_lt_aleph_0_iff` for a hypothesis-free version. -/
theorem nsmul_lt_aleph0_iff_of_ne_zero {n : ℕ} {a : Cardinal} (h : n ≠ 0) : n • a < ℵ₀ ↔ a < ℵ₀ :=
  nsmul_lt_aleph0_iff.trans <| or_iff_right h
#align cardinal.nsmul_lt_aleph_0_iff_of_ne_zero Cardinal.nsmul_lt_aleph0_iff_of_ne_zero
-/

#print Cardinal.mul_lt_aleph0 /-
theorem mul_lt_aleph0 {a b : Cardinal} (ha : a < ℵ₀) (hb : b < ℵ₀) : a * b < ℵ₀ :=
  match a, b, lt_aleph0.1 ha, lt_aleph0.1 hb with
  | _, _, ⟨m, rfl⟩, ⟨n, rfl⟩ => by rw [← Nat.cast_mul] <;> apply nat_lt_aleph_0
#align cardinal.mul_lt_aleph_0 Cardinal.mul_lt_aleph0
-/

#print Cardinal.mul_lt_aleph0_iff /-
theorem mul_lt_aleph0_iff {a b : Cardinal} : a * b < ℵ₀ ↔ a = 0 ∨ b = 0 ∨ a < ℵ₀ ∧ b < ℵ₀ :=
  by
  refine' ⟨fun h => _, _⟩
  · by_cases ha : a = 0; · exact Or.inl ha
    right; by_cases hb : b = 0; · exact Or.inl hb
    right; rw [← Ne, ← one_le_iff_ne_zero] at ha hb; constructor
    · rw [← mul_one a]
      refine' (mul_le_mul' le_rfl hb).trans_lt h
    · rw [← one_mul b]
      refine' (mul_le_mul' ha le_rfl).trans_lt h
  rintro (rfl | rfl | ⟨ha, hb⟩) <;>
    simp only [*, mul_lt_aleph_0, aleph_0_pos, MulZeroClass.zero_mul, MulZeroClass.mul_zero]
#align cardinal.mul_lt_aleph_0_iff Cardinal.mul_lt_aleph0_iff
-/

#print Cardinal.aleph0_le_mul_iff /-
/-- See also `cardinal.aleph_0_le_mul_iff`. -/
theorem aleph0_le_mul_iff {a b : Cardinal} : ℵ₀ ≤ a * b ↔ a ≠ 0 ∧ b ≠ 0 ∧ (ℵ₀ ≤ a ∨ ℵ₀ ≤ b) :=
  by
  let h := (@mul_lt_aleph0_iff a b).Not
  rwa [not_lt, not_or, not_or, not_and_or, not_lt, not_lt] at h
#align cardinal.aleph_0_le_mul_iff Cardinal.aleph0_le_mul_iff
-/

#print Cardinal.aleph0_le_mul_iff' /-
/-- See also `cardinal.aleph_0_le_mul_iff'`. -/
theorem aleph0_le_mul_iff' {a b : Cardinal.{u}} : ℵ₀ ≤ a * b ↔ a ≠ 0 ∧ ℵ₀ ≤ b ∨ ℵ₀ ≤ a ∧ b ≠ 0 :=
  by
  have : ∀ {a : Cardinal.{u}}, ℵ₀ ≤ a → a ≠ 0 := fun a => ne_bot_of_le_ne_bot aleph_0_ne_zero
  simp only [aleph_0_le_mul_iff, and_or_left, and_iff_right_of_imp this, @and_left_comm (a ≠ 0)]
  simp only [and_comm, or_comm]
#align cardinal.aleph_0_le_mul_iff' Cardinal.aleph0_le_mul_iff'
-/

#print Cardinal.mul_lt_aleph0_iff_of_ne_zero /-
theorem mul_lt_aleph0_iff_of_ne_zero {a b : Cardinal} (ha : a ≠ 0) (hb : b ≠ 0) :
    a * b < ℵ₀ ↔ a < ℵ₀ ∧ b < ℵ₀ := by simp [mul_lt_aleph_0_iff, ha, hb]
#align cardinal.mul_lt_aleph_0_iff_of_ne_zero Cardinal.mul_lt_aleph0_iff_of_ne_zero
-/

#print Cardinal.power_lt_aleph0 /-
theorem power_lt_aleph0 {a b : Cardinal} (ha : a < ℵ₀) (hb : b < ℵ₀) : (a^b) < ℵ₀ :=
  match a, b, lt_aleph0.1 ha, lt_aleph0.1 hb with
  | _, _, ⟨m, rfl⟩, ⟨n, rfl⟩ => by rw [← nat_cast_pow] <;> apply nat_lt_aleph_0
#align cardinal.power_lt_aleph_0 Cardinal.power_lt_aleph0
-/

#print Cardinal.eq_one_iff_unique /-
theorem eq_one_iff_unique {α : Type _} : (#α) = 1 ↔ Subsingleton α ∧ Nonempty α :=
  calc
    (#α) = 1 ↔ (#α) ≤ 1 ∧ 1 ≤ (#α) := le_antisymm_iff
    _ ↔ Subsingleton α ∧ Nonempty α :=
      le_one_iff_subsingleton.And (one_le_iff_ne_zero.trans mk_ne_zero_iff)
#align cardinal.eq_one_iff_unique Cardinal.eq_one_iff_unique
-/

#print Cardinal.infinite_iff /-
theorem infinite_iff {α : Type u} : Infinite α ↔ ℵ₀ ≤ (#α) := by
  rw [← not_lt, lt_aleph_0_iff_finite, not_finite_iff_infinite]
#align cardinal.infinite_iff Cardinal.infinite_iff
-/

#print Cardinal.aleph0_le_mk /-
@[simp]
theorem aleph0_le_mk (α : Type u) [Infinite α] : ℵ₀ ≤ (#α) :=
  infinite_iff.1 ‹_›
#align cardinal.aleph_0_le_mk Cardinal.aleph0_le_mk
-/

#print Cardinal.mk_eq_aleph0 /-
@[simp]
theorem mk_eq_aleph0 (α : Type _) [Countable α] [Infinite α] : (#α) = ℵ₀ :=
  mk_le_aleph0.antisymm <| aleph0_le_mk _
#align cardinal.mk_eq_aleph_0 Cardinal.mk_eq_aleph0
-/

#print Cardinal.denumerable_iff /-
theorem denumerable_iff {α : Type u} : Nonempty (Denumerable α) ↔ (#α) = ℵ₀ :=
  ⟨fun ⟨h⟩ => mk_congr ((@Denumerable.eqv α h).trans Equiv.ulift.symm), fun h => by
    cases' Quotient.exact h with f; exact ⟨Denumerable.mk' <| f.trans Equiv.ulift⟩⟩
#align cardinal.denumerable_iff Cardinal.denumerable_iff
-/

#print Cardinal.mk_denumerable /-
@[simp]
theorem mk_denumerable (α : Type u) [Denumerable α] : (#α) = ℵ₀ :=
  denumerable_iff.1 ⟨‹_›⟩
#align cardinal.mk_denumerable Cardinal.mk_denumerable
-/

#print Cardinal.aleph0_add_aleph0 /-
@[simp]
theorem aleph0_add_aleph0 : ℵ₀ + ℵ₀ = ℵ₀ :=
  mk_denumerable _
#align cardinal.aleph_0_add_aleph_0 Cardinal.aleph0_add_aleph0
-/

#print Cardinal.aleph0_mul_aleph0 /-
theorem aleph0_mul_aleph0 : ℵ₀ * ℵ₀ = ℵ₀ :=
  mk_denumerable _
#align cardinal.aleph_0_mul_aleph_0 Cardinal.aleph0_mul_aleph0
-/

#print Cardinal.nat_mul_aleph0 /-
@[simp]
theorem nat_mul_aleph0 {n : ℕ} (hn : n ≠ 0) : ↑n * ℵ₀ = ℵ₀ :=
  le_antisymm (lift_mk_fin n ▸ mk_le_aleph0) <|
    le_mul_of_one_le_left (zero_le _) <| by
      rwa [← Nat.cast_one, nat_cast_le, Nat.one_le_iff_ne_zero]
#align cardinal.nat_mul_aleph_0 Cardinal.nat_mul_aleph0
-/

#print Cardinal.aleph0_mul_nat /-
@[simp]
theorem aleph0_mul_nat {n : ℕ} (hn : n ≠ 0) : ℵ₀ * n = ℵ₀ := by rw [mul_comm, nat_mul_aleph_0 hn]
#align cardinal.aleph_0_mul_nat Cardinal.aleph0_mul_nat
-/

#print Cardinal.add_le_aleph0 /-
@[simp]
theorem add_le_aleph0 {c₁ c₂ : Cardinal} : c₁ + c₂ ≤ ℵ₀ ↔ c₁ ≤ ℵ₀ ∧ c₂ ≤ ℵ₀ :=
  ⟨fun h => ⟨le_self_add.trans h, le_add_self.trans h⟩, fun h =>
    aleph0_add_aleph0 ▸ add_le_add h.1 h.2⟩
#align cardinal.add_le_aleph_0 Cardinal.add_le_aleph0
-/

#print Cardinal.aleph0_add_nat /-
@[simp]
theorem aleph0_add_nat (n : ℕ) : ℵ₀ + n = ℵ₀ :=
  (add_le_aleph0.2 ⟨le_rfl, (nat_lt_aleph0 n).le⟩).antisymm le_self_add
#align cardinal.aleph_0_add_nat Cardinal.aleph0_add_nat
-/

#print Cardinal.nat_add_aleph0 /-
@[simp]
theorem nat_add_aleph0 (n : ℕ) : ↑n + ℵ₀ = ℵ₀ := by rw [add_comm, aleph_0_add_nat]
#align cardinal.nat_add_aleph_0 Cardinal.nat_add_aleph0
-/

#print Cardinal.toNat /-
/-- This function sends finite cardinals to the corresponding natural, and infinite cardinals
  to 0. -/
def toNat : ZeroHom Cardinal ℕ :=
  ⟨fun c => if h : c < aleph0.{v} then Classical.choose (lt_aleph0.1 h) else 0,
    by
    have h : 0 < ℵ₀ := nat_lt_aleph_0 0
    rw [dif_pos h, ← Cardinal.natCast_inj, ← Classical.choose_spec (lt_aleph_0.1 h), Nat.cast_zero]⟩
#align cardinal.to_nat Cardinal.toNat
-/

#print Cardinal.toNat_apply_of_lt_aleph0 /-
theorem toNat_apply_of_lt_aleph0 {c : Cardinal} (h : c < ℵ₀) :
    c.toNat = Classical.choose (lt_aleph0.1 h) :=
  dif_pos h
#align cardinal.to_nat_apply_of_lt_aleph_0 Cardinal.toNat_apply_of_lt_aleph0
-/

#print Cardinal.toNat_apply_of_aleph0_le /-
theorem toNat_apply_of_aleph0_le {c : Cardinal} (h : ℵ₀ ≤ c) : c.toNat = 0 :=
  dif_neg h.not_lt
#align cardinal.to_nat_apply_of_aleph_0_le Cardinal.toNat_apply_of_aleph0_le
-/

#print Cardinal.cast_toNat_of_lt_aleph0 /-
theorem cast_toNat_of_lt_aleph0 {c : Cardinal} (h : c < ℵ₀) : ↑c.toNat = c := by
  rw [to_nat_apply_of_lt_aleph_0 h, ← Classical.choose_spec (lt_aleph_0.1 h)]
#align cardinal.cast_to_nat_of_lt_aleph_0 Cardinal.cast_toNat_of_lt_aleph0
-/

#print Cardinal.cast_toNat_of_aleph0_le /-
theorem cast_toNat_of_aleph0_le {c : Cardinal} (h : ℵ₀ ≤ c) : ↑c.toNat = (0 : Cardinal) := by
  rw [to_nat_apply_of_aleph_0_le h, Nat.cast_zero]
#align cardinal.cast_to_nat_of_aleph_0_le Cardinal.cast_toNat_of_aleph0_le
-/

#print Cardinal.toNat_eq_iff_eq_of_lt_aleph0 /-
theorem toNat_eq_iff_eq_of_lt_aleph0 {c d : Cardinal} (hc : c < ℵ₀) (hd : d < ℵ₀) :
    c.toNat = d.toNat ↔ c = d := by
  rw [← nat_cast_inj, cast_to_nat_of_lt_aleph_0 hc, cast_to_nat_of_lt_aleph_0 hd]
#align cardinal.to_nat_eq_iff_eq_of_lt_aleph_0 Cardinal.toNat_eq_iff_eq_of_lt_aleph0
-/

#print Cardinal.toNat_le_iff_le_of_lt_aleph0 /-
theorem toNat_le_iff_le_of_lt_aleph0 {c d : Cardinal} (hc : c < ℵ₀) (hd : d < ℵ₀) :
    c.toNat ≤ d.toNat ↔ c ≤ d := by
  rw [← nat_cast_le, cast_to_nat_of_lt_aleph_0 hc, cast_to_nat_of_lt_aleph_0 hd]
#align cardinal.to_nat_le_iff_le_of_lt_aleph_0 Cardinal.toNat_le_iff_le_of_lt_aleph0
-/

#print Cardinal.toNat_lt_iff_lt_of_lt_aleph0 /-
theorem toNat_lt_iff_lt_of_lt_aleph0 {c d : Cardinal} (hc : c < ℵ₀) (hd : d < ℵ₀) :
    c.toNat < d.toNat ↔ c < d := by
  rw [← nat_cast_lt, cast_to_nat_of_lt_aleph_0 hc, cast_to_nat_of_lt_aleph_0 hd]
#align cardinal.to_nat_lt_iff_lt_of_lt_aleph_0 Cardinal.toNat_lt_iff_lt_of_lt_aleph0
-/

#print Cardinal.toNat_le_toNat /-
theorem toNat_le_toNat {c d : Cardinal} (hd : d < ℵ₀) (hcd : c ≤ d) : c.toNat ≤ d.toNat :=
  (toNat_le_iff_le_of_lt_aleph0 (hcd.trans_lt hd) hd).mpr hcd
#align cardinal.to_nat_le_of_le_of_lt_aleph_0 Cardinal.toNat_le_toNat
-/

#print Cardinal.toNat_lt_toNat /-
theorem toNat_lt_toNat {c d : Cardinal} (hd : d < ℵ₀) (hcd : c < d) : c.toNat < d.toNat :=
  (toNat_lt_iff_lt_of_lt_aleph0 (hcd.trans hd) hd).mpr hcd
#align cardinal.to_nat_lt_of_lt_of_lt_aleph_0 Cardinal.toNat_lt_toNat
-/

#print Cardinal.toNat_natCast /-
@[simp]
theorem toNat_natCast (n : ℕ) : Cardinal.toNat n = n :=
  by
  rw [to_nat_apply_of_lt_aleph_0 (nat_lt_aleph_0 n), ← nat_cast_inj]
  exact (Classical.choose_spec (lt_aleph_0.1 (nat_lt_aleph_0 n))).symm
#align cardinal.to_nat_cast Cardinal.toNat_natCast
-/

#print Cardinal.toNat_rightInverse /-
/-- `to_nat` has a right-inverse: coercion. -/
theorem toNat_rightInverse : Function.RightInverse (coe : ℕ → Cardinal) toNat :=
  toNat_natCast
#align cardinal.to_nat_right_inverse Cardinal.toNat_rightInverse
-/

#print Cardinal.toNat_surjective /-
theorem toNat_surjective : Surjective toNat :=
  toNat_rightInverse.Surjective
#align cardinal.to_nat_surjective Cardinal.toNat_surjective
-/

#print Cardinal.exists_nat_eq_of_le_nat /-
theorem exists_nat_eq_of_le_nat {c : Cardinal} {n : ℕ} (h : c ≤ n) : ∃ m, m ≤ n ∧ c = m :=
  let he := cast_toNat_of_lt_aleph0 (h.trans_lt <| nat_lt_aleph0 n)
  ⟨c.toNat, natCast_le.1 (he.trans_le h), he.symm⟩
#align cardinal.exists_nat_eq_of_le_nat Cardinal.exists_nat_eq_of_le_nat
-/

#print Cardinal.mk_toNat_of_infinite /-
@[simp]
theorem mk_toNat_of_infinite [h : Infinite α] : (#α).toNat = 0 :=
  dif_neg (infinite_iff.1 h).not_lt
#align cardinal.mk_to_nat_of_infinite Cardinal.mk_toNat_of_infinite
-/

#print Cardinal.aleph0_toNat /-
@[simp]
theorem aleph0_toNat : toNat ℵ₀ = 0 :=
  toNat_apply_of_aleph0_le le_rfl
#align cardinal.aleph_0_to_nat Cardinal.aleph0_toNat
-/

#print Cardinal.mk_toNat_eq_card /-
theorem mk_toNat_eq_card [Fintype α] : (#α).toNat = Fintype.card α := by simp
#align cardinal.mk_to_nat_eq_card Cardinal.mk_toNat_eq_card
-/

#print Cardinal.zero_toNat /-
@[simp]
theorem zero_toNat : toNat 0 = 0 := by rw [← to_nat_cast 0, Nat.cast_zero]
#align cardinal.zero_to_nat Cardinal.zero_toNat
-/

#print Cardinal.one_toNat /-
@[simp]
theorem one_toNat : toNat 1 = 1 := by rw [← to_nat_cast 1, Nat.cast_one]
#align cardinal.one_to_nat Cardinal.one_toNat
-/

#print Cardinal.toNat_eq_iff /-
theorem toNat_eq_iff {c : Cardinal} {n : ℕ} (hn : n ≠ 0) : toNat c = n ↔ c = n :=
  ⟨fun h =>
    (cast_toNat_of_lt_aleph0
            (lt_of_not_ge (hn ∘ h.symm.trans ∘ toNat_apply_of_aleph0_le))).symm.trans
      (congr_arg coe h),
    fun h => (congr_arg toNat h).trans (toNat_natCast n)⟩
#align cardinal.to_nat_eq_iff Cardinal.toNat_eq_iff
-/

#print Cardinal.toNat_eq_one /-
@[simp]
theorem toNat_eq_one {c : Cardinal} : toNat c = 1 ↔ c = 1 := by
  rw [to_nat_eq_iff one_ne_zero, Nat.cast_one]
#align cardinal.to_nat_eq_one Cardinal.toNat_eq_one
-/

#print Cardinal.toNat_eq_one_iff_unique /-
theorem toNat_eq_one_iff_unique {α : Type _} : (#α).toNat = 1 ↔ Subsingleton α ∧ Nonempty α :=
  toNat_eq_one.trans eq_one_iff_unique
#align cardinal.to_nat_eq_one_iff_unique Cardinal.toNat_eq_one_iff_unique
-/

#print Cardinal.toNat_lift /-
@[simp]
theorem toNat_lift (c : Cardinal.{v}) : (lift.{u, v} c).toNat = c.toNat :=
  by
  apply nat_cast_injective
  cases' lt_or_ge c ℵ₀ with hc hc
  · rw [cast_to_nat_of_lt_aleph_0, ← lift_nat_cast, cast_to_nat_of_lt_aleph_0 hc]
    rwa [lift_lt_aleph_0]
  · rw [cast_to_nat_of_aleph_0_le, ← lift_nat_cast, cast_to_nat_of_aleph_0_le hc, lift_zero]
    rwa [aleph_0_le_lift]
#align cardinal.to_nat_lift Cardinal.toNat_lift
-/

#print Cardinal.toNat_congr /-
theorem toNat_congr {β : Type v} (e : α ≃ β) : (#α).toNat = (#β).toNat := by
  rw [← to_nat_lift, lift_mk_eq.mpr ⟨e⟩, to_nat_lift]
#align cardinal.to_nat_congr Cardinal.toNat_congr
-/

#print Cardinal.toNat_mul /-
@[simp]
theorem toNat_mul (x y : Cardinal) : (x * y).toNat = x.toNat * y.toNat :=
  by
  rcases eq_or_ne x 0 with (rfl | hx1)
  · rw [MulZeroClass.zero_mul, zero_to_nat, MulZeroClass.zero_mul]
  rcases eq_or_ne y 0 with (rfl | hy1)
  · rw [MulZeroClass.mul_zero, zero_to_nat, MulZeroClass.mul_zero]
  cases' lt_or_le x ℵ₀ with hx2 hx2
  · cases' lt_or_le y ℵ₀ with hy2 hy2
    · lift x to ℕ using hx2; lift y to ℕ using hy2
      rw [← Nat.cast_mul, to_nat_cast, to_nat_cast, to_nat_cast]
    · rw [to_nat_apply_of_aleph_0_le hy2, MulZeroClass.mul_zero, to_nat_apply_of_aleph_0_le]
      exact aleph_0_le_mul_iff'.2 (Or.inl ⟨hx1, hy2⟩)
  · rw [to_nat_apply_of_aleph_0_le hx2, MulZeroClass.zero_mul, to_nat_apply_of_aleph_0_le]
    exact aleph_0_le_mul_iff'.2 (Or.inr ⟨hx2, hy1⟩)
#align cardinal.to_nat_mul Cardinal.toNat_mul
-/

/- warning: cardinal.to_nat_hom clashes with cardinal.to_nat -> Cardinal.toNat
Case conversion may be inaccurate. Consider using '#align cardinal.to_nat_hom Cardinal.toNatₓ'. -/
#print Cardinal.toNat /-
/-- `cardinal.to_nat` as a `monoid_with_zero_hom`. -/
@[simps]
def toNat : Cardinal →*₀ ℕ where
  toFun := toNat
  map_zero' := zero_toNat
  map_one' := one_toNat
  map_mul' := toNat_mul
#align cardinal.to_nat_hom Cardinal.toNat
-/

#print Cardinal.toNat_finset_prod /-
theorem toNat_finset_prod (s : Finset α) (f : α → Cardinal) :
    toNat (∏ i in s, f i) = ∏ i in s, toNat (f i) :=
  map_prod toNat _ _
#align cardinal.to_nat_finset_prod Cardinal.toNat_finset_prod
-/

#print Cardinal.toNat_lift_add_lift /-
@[simp]
theorem toNat_lift_add_lift {a : Cardinal.{u}} {b : Cardinal.{v}} (ha : a < ℵ₀) (hb : b < ℵ₀) :
    (lift.{v, u} a + lift.{u, v} b).toNat = a.toNat + b.toNat :=
  by
  apply Cardinal.natCast_injective
  replace ha : lift.{v, u} a < ℵ₀ := by rwa [lift_lt_aleph_0]
  replace hb : lift.{u, v} b < ℵ₀ := by rwa [lift_lt_aleph_0]
  rw [Nat.cast_add, ← toNat_lift.{v, u} a, ← toNat_lift.{u, v} b, cast_to_nat_of_lt_aleph_0 ha,
    cast_to_nat_of_lt_aleph_0 hb, cast_to_nat_of_lt_aleph_0 (add_lt_aleph_0 ha hb)]
#align cardinal.to_nat_add_of_lt_aleph_0 Cardinal.toNat_lift_add_lift
-/

#print Cardinal.toPartENat /-
/-- This function sends finite cardinals to the corresponding natural, and infinite cardinals
  to `⊤`. -/
def toPartENat : Cardinal →+ PartENat
    where
  toFun c := if c < ℵ₀ then c.toNat else ⊤
  map_zero' := by simp [if_pos (zero_lt_one.trans one_lt_aleph_0)]
  map_add' x y := by
    by_cases hx : x < ℵ₀
    · obtain ⟨x0, rfl⟩ := lt_aleph_0.1 hx
      by_cases hy : y < ℵ₀
      · obtain ⟨y0, rfl⟩ := lt_aleph_0.1 hy
        simp only [add_lt_aleph_0 hx hy, hx, hy, to_nat_cast, if_true]
        rw [← Nat.cast_add, to_nat_cast, Nat.cast_add]
      · rw [if_neg hy, if_neg, PartENat.add_top]
        contrapose! hy
        apply le_add_self.trans_lt hy
    · rw [if_neg hx, if_neg, PartENat.top_add]
      contrapose! hx
      apply le_self_add.trans_lt hx
#align cardinal.to_part_enat Cardinal.toPartENat
-/

#print Cardinal.toPartENat_apply_of_lt_aleph0 /-
theorem toPartENat_apply_of_lt_aleph0 {c : Cardinal} (h : c < ℵ₀) : c.toPartENat = c.toNat :=
  if_pos h
#align cardinal.to_part_enat_apply_of_lt_aleph_0 Cardinal.toPartENat_apply_of_lt_aleph0
-/

#print Cardinal.toPartENat_apply_of_aleph0_le /-
theorem toPartENat_apply_of_aleph0_le {c : Cardinal} (h : ℵ₀ ≤ c) : c.toPartENat = ⊤ :=
  if_neg h.not_lt
#align cardinal.to_part_enat_apply_of_aleph_0_le Cardinal.toPartENat_apply_of_aleph0_le
-/

#print Cardinal.toPartENat_natCast /-
@[simp]
theorem toPartENat_natCast (n : ℕ) : Cardinal.toPartENat n = n := by
  rw [to_part_enat_apply_of_lt_aleph_0 (nat_lt_aleph_0 n), to_nat_cast]
#align cardinal.to_part_enat_cast Cardinal.toPartENat_natCast
-/

#print Cardinal.mk_toPartENat_of_infinite /-
@[simp]
theorem mk_toPartENat_of_infinite [h : Infinite α] : (#α).toPartENat = ⊤ :=
  toPartENat_apply_of_aleph0_le (infinite_iff.1 h)
#align cardinal.mk_to_part_enat_of_infinite Cardinal.mk_toPartENat_of_infinite
-/

#print Cardinal.aleph0_toPartENat /-
@[simp]
theorem aleph0_toPartENat : toPartENat ℵ₀ = ⊤ :=
  toPartENat_apply_of_aleph0_le le_rfl
#align cardinal.aleph_0_to_part_enat Cardinal.aleph0_toPartENat
-/

#print Cardinal.toPartENat_eq_top_iff_le_aleph0 /-
theorem toPartENat_eq_top_iff_le_aleph0 {c : Cardinal} : toPartENat c = ⊤ ↔ aleph0 ≤ c :=
  by
  cases' lt_or_ge c aleph_0 with hc hc
  simp only [to_part_enat_apply_of_lt_aleph_0 hc, PartENat.natCast_ne_top, false_iff_iff, not_le,
    hc]
  simp only [to_part_enat_apply_of_aleph_0_le hc, eq_self_iff_true, true_iff_iff]
  exact hc
#align cardinal.to_part_enat_eq_top_iff_le_aleph_0 Cardinal.toPartENat_eq_top_iff_le_aleph0
-/

theorem toPartENat_le_iff_le_of_le_aleph0 {c c' : Cardinal} (h : c ≤ aleph0) :
    toPartENat c ≤ toPartENat c' ↔ c ≤ c' :=
  by
  cases' lt_or_ge c aleph_0 with hc hc
  rw [to_part_enat_apply_of_lt_aleph_0 hc]
  cases' lt_or_ge c' aleph_0 with hc' hc'
  · rw [to_part_enat_apply_of_lt_aleph_0 hc']
    rw [PartENat.coe_le_coe]
    exact to_nat_le_iff_le_of_lt_aleph_0 hc hc'
  · simp only [to_part_enat_apply_of_aleph_0_le hc', le_top, true_iff_iff]
    exact le_trans h hc'
  · rw [to_part_enat_apply_of_aleph_0_le hc]
    simp only [top_le_iff, Cardinal.toPartENat_eq_top, le_antisymm h hc]
#align cardinal.to_part_enat_le_iff_le_of_le_aleph_0 Cardinal.toPartENat_le_iff_le_of_le_aleph0

theorem toPartENat_le_iff_le_of_lt_aleph0 {c c' : Cardinal} (hc' : c' < aleph0) :
    toPartENat c ≤ toPartENat c' ↔ c ≤ c' :=
  by
  cases' lt_or_ge c aleph_0 with hc hc
  · rw [to_part_enat_apply_of_lt_aleph_0 hc]
    rw [to_part_enat_apply_of_lt_aleph_0 hc']
    rw [PartENat.coe_le_coe]
    exact to_nat_le_iff_le_of_lt_aleph_0 hc hc'
  · rw [to_part_enat_apply_of_aleph_0_le hc]
    simp only [top_le_iff, Cardinal.toPartENat_eq_top]
    rw [← not_iff_not, not_le, not_le]
    simp only [hc', lt_of_lt_of_le hc' hc]
#align cardinal.to_part_enat_le_iff_le_of_lt_aleph_0 Cardinal.toPartENat_le_iff_le_of_lt_aleph0

theorem toPartENat_eq_iff_eq_of_le_aleph0 {c c' : Cardinal} (hc : c ≤ aleph0) (hc' : c' ≤ aleph0) :
    toPartENat c = toPartENat c' ↔ c = c' := by
  rw [le_antisymm_iff, le_antisymm_iff, Cardinal.toPartENat_le_iff_of_le_aleph0 hc,
    Cardinal.toPartENat_le_iff_of_le_aleph0 hc']
#align cardinal.to_part_enat_eq_iff_eq_of_le_aleph_0 Cardinal.toPartENat_eq_iff_eq_of_le_aleph0

#print Cardinal.toPartENat_mono /-
theorem toPartENat_mono {c c' : Cardinal} (h : c ≤ c') : toPartENat c ≤ toPartENat c' :=
  by
  cases' lt_or_ge c aleph_0 with hc hc
  rw [to_part_enat_apply_of_lt_aleph_0 hc]
  cases' lt_or_ge c' aleph_0 with hc' hc'
  rw [to_part_enat_apply_of_lt_aleph_0 hc']
  simp only [PartENat.coe_le_coe]
  exact to_nat_le_of_le_of_lt_aleph_0 hc' h
  rw [to_part_enat_apply_of_aleph_0_le hc']
  exact le_top
  rw [to_part_enat_apply_of_aleph_0_le hc, to_part_enat_apply_of_aleph_0_le (le_trans hc h)]
#align cardinal.to_part_enat_mono Cardinal.toPartENat_mono
-/

#print Cardinal.toPartENat_surjective /-
theorem toPartENat_surjective : Surjective toPartENat := fun x =>
  PartENat.casesOn x ⟨ℵ₀, toPartENat_apply_of_aleph0_le le_rfl⟩ fun n => ⟨n, toPartENat_natCast n⟩
#align cardinal.to_part_enat_surjective Cardinal.toPartENat_surjective
-/

#print Cardinal.toPartENat_lift /-
theorem toPartENat_lift (c : Cardinal.{v}) : (lift.{u, v} c).toPartENat = c.toPartENat :=
  by
  cases' lt_or_ge c ℵ₀ with hc hc
  · rw [to_part_enat_apply_of_lt_aleph_0 hc, Cardinal.toPartENat_apply_of_lt_aleph0 _]
    simp only [to_nat_lift]
    rw [← lift_aleph_0, lift_lt]; exact hc
  · rw [to_part_enat_apply_of_aleph_0_le hc, Cardinal.toPartENat_apply_of_aleph0_le _]
    rw [← lift_aleph_0, lift_le]; exact hc
#align cardinal.to_part_enat_lift Cardinal.toPartENat_lift
-/

#print Cardinal.toPartENat_congr /-
theorem toPartENat_congr {β : Type v} (e : α ≃ β) : (#α).toPartENat = (#β).toPartENat := by
  rw [← to_part_enat_lift, lift_mk_eq.mpr ⟨e⟩, to_part_enat_lift]
#align cardinal.to_part_enat_congr Cardinal.toPartENat_congr
-/

#print Cardinal.mk_toPartENat_eq_coe_card /-
theorem mk_toPartENat_eq_coe_card [Fintype α] : (#α).toPartENat = Fintype.card α := by simp
#align cardinal.mk_to_part_enat_eq_coe_card Cardinal.mk_toPartENat_eq_coe_card
-/

#print Cardinal.mk_int /-
theorem mk_int : (#ℤ) = ℵ₀ :=
  mk_denumerable ℤ
#align cardinal.mk_int Cardinal.mk_int
-/

#print Cardinal.mk_pNat /-
theorem mk_pNat : (#ℕ+) = ℵ₀ :=
  mk_denumerable ℕ+
#align cardinal.mk_pnat Cardinal.mk_pNat
-/

#print Cardinal.sum_lt_prod /-
/-- **König's theorem** -/
theorem sum_lt_prod {ι} (f g : ι → Cardinal) (H : ∀ i, f i < g i) : sum f < prod g :=
  lt_of_not_ge fun ⟨F⟩ =>
    by
    have : Inhabited (∀ i : ι, (g i).out) :=
      by
      refine' ⟨fun i => Classical.choice <| mk_ne_zero_iff.1 _⟩
      rw [mk_out]
      exact (H i).ne_bot
    let G := inv_fun F
    have sG : surjective G := inv_fun_surjective F.2
    choose C hc using
      show ∀ i, ∃ b, ∀ a, G ⟨i, a⟩ i ≠ b by
        intro i
        simp only [-not_exists, not_exists.symm, not_forall.symm]
        refine' fun h => (H i).not_le _
        rw [← mk_out (f i), ← mk_out (g i)]
        exact ⟨embedding.of_surjective _ h⟩
    exact
      let ⟨⟨i, a⟩, h⟩ := sG C
      hc i a (congr_fun h _)
#align cardinal.sum_lt_prod Cardinal.sum_lt_prod
-/

#print Cardinal.mk_empty /-
@[simp]
theorem mk_empty : (#Empty) = 0 :=
  mk_eq_zero _
#align cardinal.mk_empty Cardinal.mk_empty
-/

#print Cardinal.mk_pempty /-
@[simp]
theorem mk_pempty : (#PEmpty) = 0 :=
  mk_eq_zero _
#align cardinal.mk_pempty Cardinal.mk_pempty
-/

#print Cardinal.mk_punit /-
@[simp]
theorem mk_punit : (#PUnit) = 1 :=
  mk_eq_one PUnit
#align cardinal.mk_punit Cardinal.mk_punit
-/

#print Cardinal.mk_unit /-
theorem mk_unit : (#Unit) = 1 :=
  mk_punit
#align cardinal.mk_unit Cardinal.mk_unit
-/

#print Cardinal.mk_singleton /-
@[simp]
theorem mk_singleton {α : Type u} (x : α) : (#({x} : Set α)) = 1 :=
  mk_eq_one _
#align cardinal.mk_singleton Cardinal.mk_singleton
-/

#print Cardinal.mk_plift_true /-
@[simp]
theorem mk_plift_true : (#PLift True) = 1 :=
  mk_eq_one _
#align cardinal.mk_plift_true Cardinal.mk_plift_true
-/

#print Cardinal.mk_plift_false /-
@[simp]
theorem mk_plift_false : (#PLift False) = 0 :=
  mk_eq_zero _
#align cardinal.mk_plift_false Cardinal.mk_plift_false
-/

#print Cardinal.mk_vector /-
@[simp]
theorem mk_vector (α : Type u) (n : ℕ) : (#Mathlib.Vector α n) = (#α) ^ℕ n :=
  (mk_congr (Equiv.vectorEquivFin α n)).trans <| by simp
#align cardinal.mk_vector Cardinal.mk_vector
-/

#print Cardinal.mk_list_eq_sum_pow /-
theorem mk_list_eq_sum_pow (α : Type u) : (#List α) = sum fun n : ℕ => (#α) ^ℕ n :=
  calc
    (#List α) = (#Σ n, Mathlib.Vector α n) := mk_congr (Equiv.sigmaFiberEquiv List.length).symm
    _ = sum fun n : ℕ => (#α) ^ℕ n := by simp
#align cardinal.mk_list_eq_sum_pow Cardinal.mk_list_eq_sum_pow
-/

#print Cardinal.mk_quot_le /-
theorem mk_quot_le {α : Type u} {r : α → α → Prop} : (#Quot r) ≤ (#α) :=
  mk_le_of_surjective Quot.exists_rep
#align cardinal.mk_quot_le Cardinal.mk_quot_le
-/

#print Cardinal.mk_quotient_le /-
theorem mk_quotient_le {α : Type u} {s : Setoid α} : (#Quotient s) ≤ (#α) :=
  mk_quot_le
#align cardinal.mk_quotient_le Cardinal.mk_quotient_le
-/

#print Cardinal.mk_subtype_le_of_subset /-
theorem mk_subtype_le_of_subset {α : Type u} {p q : α → Prop} (h : ∀ ⦃x⦄, p x → q x) :
    (#Subtype p) ≤ (#Subtype q) :=
  ⟨Embedding.subtypeMap (Embedding.refl α) h⟩
#align cardinal.mk_subtype_le_of_subset Cardinal.mk_subtype_le_of_subset
-/

#print Cardinal.mk_emptyCollection /-
@[simp]
theorem mk_emptyCollection (α : Type u) : (#(∅ : Set α)) = 0 :=
  mk_eq_zero _
#align cardinal.mk_emptyc Cardinal.mk_emptyCollection
-/

#print Cardinal.mk_emptyCollection_iff /-
theorem mk_emptyCollection_iff {α : Type u} {s : Set α} : (#s) = 0 ↔ s = ∅ :=
  by
  constructor
  · intro h
    rw [mk_eq_zero_iff] at h
    exact eq_empty_iff_forall_not_mem.2 fun x hx => h.elim' ⟨x, hx⟩
  · rintro rfl; exact mk_emptyc _
#align cardinal.mk_emptyc_iff Cardinal.mk_emptyCollection_iff
-/

#print Cardinal.mk_univ /-
@[simp]
theorem mk_univ {α : Type u} : (#@univ α) = (#α) :=
  mk_congr (Equiv.Set.univ α)
#align cardinal.mk_univ Cardinal.mk_univ
-/

#print Cardinal.mk_image_le /-
theorem mk_image_le {α β : Type u} {f : α → β} {s : Set α} : (#f '' s) ≤ (#s) :=
  mk_le_of_surjective surjective_onto_image
#align cardinal.mk_image_le Cardinal.mk_image_le
-/

#print Cardinal.mk_image_le_lift /-
theorem mk_image_le_lift {α : Type u} {β : Type v} {f : α → β} {s : Set α} :
    lift.{u} (#f '' s) ≤ lift.{v} (#s) :=
  lift_mk_le.{v, u, 0}.mpr ⟨Embedding.ofSurjective _ surjective_onto_image⟩
#align cardinal.mk_image_le_lift Cardinal.mk_image_le_lift
-/

#print Cardinal.mk_range_le /-
theorem mk_range_le {α β : Type u} {f : α → β} : (#range f) ≤ (#α) :=
  mk_le_of_surjective surjective_onto_range
#align cardinal.mk_range_le Cardinal.mk_range_le
-/

#print Cardinal.mk_range_le_lift /-
theorem mk_range_le_lift {α : Type u} {β : Type v} {f : α → β} :
    lift.{u} (#range f) ≤ lift.{v} (#α) :=
  lift_mk_le.{v, u, 0}.mpr ⟨Embedding.ofSurjective _ surjective_onto_range⟩
#align cardinal.mk_range_le_lift Cardinal.mk_range_le_lift
-/

#print Cardinal.mk_range_eq /-
theorem mk_range_eq (f : α → β) (h : Injective f) : (#range f) = (#α) :=
  mk_congr (Equiv.ofInjective f h).symm
#align cardinal.mk_range_eq Cardinal.mk_range_eq
-/

#print Cardinal.mk_range_eq_of_injective /-
theorem mk_range_eq_of_injective {α : Type u} {β : Type v} {f : α → β} (hf : Injective f) :
    lift.{u} (#range f) = lift.{v} (#α) :=
  lift_mk_eq'.mpr ⟨(Equiv.ofInjective f hf).symm⟩
#align cardinal.mk_range_eq_of_injective Cardinal.mk_range_eq_of_injective
-/

#print Cardinal.mk_range_eq_lift /-
theorem mk_range_eq_lift {α : Type u} {β : Type v} {f : α → β} (hf : Injective f) :
    lift.{max u w} (#range f) = lift.{max v w} (#α) :=
  lift_mk_eq.mpr ⟨(Equiv.ofInjective f hf).symm⟩
#align cardinal.mk_range_eq_lift Cardinal.mk_range_eq_lift
-/

#print Cardinal.mk_image_eq /-
theorem mk_image_eq {α β : Type u} {f : α → β} {s : Set α} (hf : Injective f) : (#f '' s) = (#s) :=
  mk_congr (Equiv.Set.image f s hf).symm
#align cardinal.mk_image_eq Cardinal.mk_image_eq
-/

#print Cardinal.mk_iUnion_le_sum_mk /-
theorem mk_iUnion_le_sum_mk {α ι : Type u} {f : ι → Set α} : (#⋃ i, f i) ≤ sum fun i => #f i :=
  calc
    (#⋃ i, f i) ≤ (#Σ i, f i) := mk_le_of_surjective (Set.sigmaToiUnion_surjective f)
    _ = sum fun i => #f i := mk_sigma _
#align cardinal.mk_Union_le_sum_mk Cardinal.mk_iUnion_le_sum_mk
-/

#print Cardinal.mk_iUnion_eq_sum_mk /-
theorem mk_iUnion_eq_sum_mk {α ι : Type u} {f : ι → Set α}
    (h : ∀ i j, i ≠ j → Disjoint (f i) (f j)) : (#⋃ i, f i) = sum fun i => #f i :=
  calc
    (#⋃ i, f i) = (#Σ i, f i) := mk_congr (Set.unionEqSigmaOfDisjoint h)
    _ = sum fun i => #f i := mk_sigma _
#align cardinal.mk_Union_eq_sum_mk Cardinal.mk_iUnion_eq_sum_mk
-/

#print Cardinal.mk_iUnion_le /-
theorem mk_iUnion_le {α ι : Type u} (f : ι → Set α) : (#⋃ i, f i) ≤ (#ι) * ⨆ i, #f i :=
  mk_iUnion_le_sum_mk.trans (sum_le_iSup _)
#align cardinal.mk_Union_le Cardinal.mk_iUnion_le
-/

#print Cardinal.mk_sUnion_le /-
theorem mk_sUnion_le {α : Type u} (A : Set (Set α)) : (#⋃₀ A) ≤ (#A) * ⨆ s : A, #s := by
  rw [sUnion_eq_Union]; apply mk_Union_le
#align cardinal.mk_sUnion_le Cardinal.mk_sUnion_le
-/

#print Cardinal.mk_biUnion_le /-
theorem mk_biUnion_le {ι α : Type u} (A : ι → Set α) (s : Set ι) :
    (#⋃ x ∈ s, A x) ≤ (#s) * ⨆ x : s, #A x.1 := by rw [bUnion_eq_Union]; apply mk_Union_le
#align cardinal.mk_bUnion_le Cardinal.mk_biUnion_le
-/

#print Cardinal.finset_card_lt_aleph0 /-
theorem finset_card_lt_aleph0 (s : Finset α) : (#(↑s : Set α)) < ℵ₀ :=
  lt_aleph0_of_finite _
#align cardinal.finset_card_lt_aleph_0 Cardinal.finset_card_lt_aleph0
-/

#print Cardinal.mk_set_eq_nat_iff_finset /-
theorem mk_set_eq_nat_iff_finset {α} {s : Set α} {n : ℕ} :
    (#s) = n ↔ ∃ t : Finset α, (t : Set α) = s ∧ t.card = n :=
  by
  constructor
  · intro h
    lift s to Finset α using lt_aleph_0_iff_set_finite.1 (h.symm ▸ nat_lt_aleph_0 n)
    simpa using h
  · rintro ⟨t, rfl, rfl⟩
    exact mk_coe_finset
#align cardinal.mk_set_eq_nat_iff_finset Cardinal.mk_set_eq_nat_iff_finset
-/

#print Cardinal.mk_eq_nat_iff_finset /-
theorem mk_eq_nat_iff_finset {n : ℕ} : (#α) = n ↔ ∃ t : Finset α, (t : Set α) = univ ∧ t.card = n :=
  by rw [← mk_univ, mk_set_eq_nat_iff_finset]
#align cardinal.mk_eq_nat_iff_finset Cardinal.mk_eq_nat_iff_finset
-/

#print Cardinal.mk_eq_nat_iff_fintype /-
theorem mk_eq_nat_iff_fintype {n : ℕ} : (#α) = n ↔ ∃ h : Fintype α, @Fintype.card α h = n :=
  by
  rw [mk_eq_nat_iff_finset]
  constructor
  · rintro ⟨t, ht, hn⟩
    exact ⟨⟨t, eq_univ_iff_forall.1 ht⟩, hn⟩
  · rintro ⟨⟨t, ht⟩, hn⟩
    exact ⟨t, eq_univ_iff_forall.2 ht, hn⟩
#align cardinal.mk_eq_nat_iff_fintype Cardinal.mk_eq_nat_iff_fintype
-/

#print Cardinal.mk_union_add_mk_inter /-
theorem mk_union_add_mk_inter {α : Type u} {S T : Set α} :
    (#(S ∪ T : Set α)) + (#(S ∩ T : Set α)) = (#S) + (#T) :=
  Quot.sound ⟨Equiv.Set.unionSumInter S T⟩
#align cardinal.mk_union_add_mk_inter Cardinal.mk_union_add_mk_inter
-/

#print Cardinal.mk_union_le /-
/-- The cardinality of a union is at most the sum of the cardinalities
of the two sets. -/
theorem mk_union_le {α : Type u} (S T : Set α) : (#(S ∪ T : Set α)) ≤ (#S) + (#T) :=
  @mk_union_add_mk_inter α S T ▸ self_le_add_right (#(S ∪ T : Set α)) (#(S ∩ T : Set α))
#align cardinal.mk_union_le Cardinal.mk_union_le
-/

#print Cardinal.mk_union_of_disjoint /-
theorem mk_union_of_disjoint {α : Type u} {S T : Set α} (H : Disjoint S T) :
    (#(S ∪ T : Set α)) = (#S) + (#T) :=
  Quot.sound ⟨Equiv.Set.union H.le_bot⟩
#align cardinal.mk_union_of_disjoint Cardinal.mk_union_of_disjoint
-/

#print Cardinal.mk_insert /-
theorem mk_insert {α : Type u} {s : Set α} {a : α} (h : a ∉ s) :
    (#(insert a s : Set α)) = (#s) + 1 := by
  rw [← union_singleton, mk_union_of_disjoint, mk_singleton]; simpa
#align cardinal.mk_insert Cardinal.mk_insert
-/

#print Cardinal.mk_sum_compl /-
theorem mk_sum_compl {α} (s : Set α) : (#s) + (#(sᶜ : Set α)) = (#α) :=
  mk_congr (Equiv.Set.sumCompl s)
#align cardinal.mk_sum_compl Cardinal.mk_sum_compl
-/

#print Cardinal.mk_le_mk_of_subset /-
theorem mk_le_mk_of_subset {α} {s t : Set α} (h : s ⊆ t) : (#s) ≤ (#t) :=
  ⟨Set.embeddingOfSubset s t h⟩
#align cardinal.mk_le_mk_of_subset Cardinal.mk_le_mk_of_subset
-/

#print Cardinal.mk_subtype_mono /-
theorem mk_subtype_mono {p q : α → Prop} (h : ∀ x, p x → q x) : (#{ x // p x }) ≤ (#{ x // q x }) :=
  ⟨embeddingOfSubset _ _ h⟩
#align cardinal.mk_subtype_mono Cardinal.mk_subtype_mono
-/

#print Cardinal.le_mk_diff_add_mk /-
theorem le_mk_diff_add_mk (S T : Set α) : (#S) ≤ (#(S \ T : Set α)) + (#T) :=
  (mk_le_mk_of_subset <| subset_diff_union _ _).trans <| mk_union_le _ _
#align cardinal.le_mk_diff_add_mk Cardinal.le_mk_diff_add_mk
-/

#print Cardinal.mk_diff_add_mk /-
theorem mk_diff_add_mk {S T : Set α} (h : T ⊆ S) : (#(S \ T : Set α)) + (#T) = (#S) :=
  (mk_union_of_disjoint <| disjoint_sdiff_self_left).symm.trans <| by rw [diff_union_of_subset h]
#align cardinal.mk_diff_add_mk Cardinal.mk_diff_add_mk
-/

#print Cardinal.mk_union_le_aleph0 /-
theorem mk_union_le_aleph0 {α} {P Q : Set α} : (#(P ∪ Q : Set α)) ≤ ℵ₀ ↔ (#P) ≤ ℵ₀ ∧ (#Q) ≤ ℵ₀ := by
  simp
#align cardinal.mk_union_le_aleph_0 Cardinal.mk_union_le_aleph0
-/

#print Cardinal.mk_image_eq_lift /-
theorem mk_image_eq_lift {α : Type u} {β : Type v} (f : α → β) (s : Set α) (h : Injective f) :
    lift.{u} (#f '' s) = lift.{v} (#s) :=
  lift_mk_eq.{v, u, 0}.mpr ⟨(Equiv.Set.image f s h).symm⟩
#align cardinal.mk_image_eq_lift Cardinal.mk_image_eq_lift
-/

#print Cardinal.mk_image_eq_of_injOn_lift /-
theorem mk_image_eq_of_injOn_lift {α : Type u} {β : Type v} (f : α → β) (s : Set α)
    (h : InjOn f s) : lift.{u} (#f '' s) = lift.{v} (#s) :=
  lift_mk_eq.{v, u, 0}.mpr ⟨(Equiv.Set.imageOfInjOn f s h).symm⟩
#align cardinal.mk_image_eq_of_inj_on_lift Cardinal.mk_image_eq_of_injOn_lift
-/

#print Cardinal.mk_image_eq_of_injOn /-
theorem mk_image_eq_of_injOn {α β : Type u} (f : α → β) (s : Set α) (h : InjOn f s) :
    (#f '' s) = (#s) :=
  mk_congr (Equiv.Set.imageOfInjOn f s h).symm
#align cardinal.mk_image_eq_of_inj_on Cardinal.mk_image_eq_of_injOn
-/

#print Cardinal.mk_subtype_of_equiv /-
theorem mk_subtype_of_equiv {α β : Type u} (p : β → Prop) (e : α ≃ β) :
    (#{ a : α // p (e a) }) = (#{ b : β // p b }) :=
  mk_congr (Equiv.subtypeEquivOfSubtype e)
#align cardinal.mk_subtype_of_equiv Cardinal.mk_subtype_of_equiv
-/

#print Cardinal.mk_sep /-
theorem mk_sep (s : Set α) (t : α → Prop) : (#({x ∈ s | t x} : Set α)) = (#{x : s | t x.1}) :=
  mk_congr (Equiv.Set.sep s t)
#align cardinal.mk_sep Cardinal.mk_sep
-/

#print Cardinal.mk_preimage_of_injective_lift /-
theorem mk_preimage_of_injective_lift {α : Type u} {β : Type v} (f : α → β) (s : Set β)
    (h : Injective f) : lift.{v} (#f ⁻¹' s) ≤ lift.{u} (#s) :=
  by
  rw [lift_mk_le.{u, v, 0}]; use Subtype.coind (fun x => f x.1) fun x => x.2
  apply Subtype.coind_injective; exact h.comp Subtype.val_injective
#align cardinal.mk_preimage_of_injective_lift Cardinal.mk_preimage_of_injective_lift
-/

#print Cardinal.mk_preimage_of_subset_range_lift /-
theorem mk_preimage_of_subset_range_lift {α : Type u} {β : Type v} (f : α → β) (s : Set β)
    (h : s ⊆ range f) : lift.{u} (#s) ≤ lift.{v} (#f ⁻¹' s) :=
  by
  rw [lift_mk_le.{v, u, 0}]
  refine' ⟨⟨_, _⟩⟩
  · rintro ⟨y, hy⟩; rcases Classical.subtype_of_exists (h hy) with ⟨x, rfl⟩; exact ⟨x, hy⟩
  rintro ⟨y, hy⟩ ⟨y', hy'⟩; dsimp
  rcases Classical.subtype_of_exists (h hy) with ⟨x, rfl⟩
  rcases Classical.subtype_of_exists (h hy') with ⟨x', rfl⟩
  simp; intro hxx'; rw [hxx']
#align cardinal.mk_preimage_of_subset_range_lift Cardinal.mk_preimage_of_subset_range_lift
-/

#print Cardinal.mk_preimage_of_injective_of_subset_range_lift /-
theorem mk_preimage_of_injective_of_subset_range_lift {β : Type v} (f : α → β) (s : Set β)
    (h : Injective f) (h2 : s ⊆ range f) : lift.{v} (#f ⁻¹' s) = lift.{u} (#s) :=
  le_antisymm (mk_preimage_of_injective_lift f s h) (mk_preimage_of_subset_range_lift f s h2)
#align cardinal.mk_preimage_of_injective_of_subset_range_lift Cardinal.mk_preimage_of_injective_of_subset_range_lift
-/

#print Cardinal.mk_preimage_of_injective /-
theorem mk_preimage_of_injective (f : α → β) (s : Set β) (h : Injective f) : (#f ⁻¹' s) ≤ (#s) := by
  convert mk_preimage_of_injective_lift.{u, u} f s h using 1 <;> rw [lift_id]
#align cardinal.mk_preimage_of_injective Cardinal.mk_preimage_of_injective
-/

#print Cardinal.mk_preimage_of_subset_range /-
theorem mk_preimage_of_subset_range (f : α → β) (s : Set β) (h : s ⊆ range f) : (#s) ≤ (#f ⁻¹' s) :=
  by convert mk_preimage_of_subset_range_lift.{u, u} f s h using 1 <;> rw [lift_id]
#align cardinal.mk_preimage_of_subset_range Cardinal.mk_preimage_of_subset_range
-/

#print Cardinal.mk_preimage_of_injective_of_subset_range /-
theorem mk_preimage_of_injective_of_subset_range (f : α → β) (s : Set β) (h : Injective f)
    (h2 : s ⊆ range f) : (#f ⁻¹' s) = (#s) := by
  convert mk_preimage_of_injective_of_subset_range_lift.{u, u} f s h h2 using 1 <;> rw [lift_id]
#align cardinal.mk_preimage_of_injective_of_subset_range Cardinal.mk_preimage_of_injective_of_subset_range
-/

#print Cardinal.mk_subset_ge_of_subset_image_lift /-
theorem mk_subset_ge_of_subset_image_lift {α : Type u} {β : Type v} (f : α → β) {s : Set α}
    {t : Set β} (h : t ⊆ f '' s) : lift.{u} (#t) ≤ lift.{v} (#({x ∈ s | f x ∈ t} : Set α)) :=
  by
  rw [image_eq_range] at h; convert mk_preimage_of_subset_range_lift _ _ h using 1
  rw [mk_sep]; rfl
#align cardinal.mk_subset_ge_of_subset_image_lift Cardinal.mk_subset_ge_of_subset_image_lift
-/

#print Cardinal.mk_subset_ge_of_subset_image /-
theorem mk_subset_ge_of_subset_image (f : α → β) {s : Set α} {t : Set β} (h : t ⊆ f '' s) :
    (#t) ≤ (#({x ∈ s | f x ∈ t} : Set α)) :=
  by
  rw [image_eq_range] at h; convert mk_preimage_of_subset_range _ _ h using 1
  rw [mk_sep]; rfl
#align cardinal.mk_subset_ge_of_subset_image Cardinal.mk_subset_ge_of_subset_image
-/

#print Cardinal.le_mk_iff_exists_subset /-
theorem le_mk_iff_exists_subset {c : Cardinal} {α : Type u} {s : Set α} :
    c ≤ (#s) ↔ ∃ p : Set α, p ⊆ s ∧ (#p) = c :=
  by
  rw [le_mk_iff_exists_set, ← Subtype.exists_set_subtype]
  apply exists_congr; intro t; rw [mk_image_eq]; apply Subtype.val_injective
#align cardinal.le_mk_iff_exists_subset Cardinal.le_mk_iff_exists_subset
-/

#print Cardinal.two_le_iff /-
theorem two_le_iff : (2 : Cardinal) ≤ (#α) ↔ ∃ x y : α, x ≠ y := by
  rw [← Nat.cast_two, nat_succ, succ_le_iff, Nat.cast_one, one_lt_iff_nontrivial, nontrivial_iff]
#align cardinal.two_le_iff Cardinal.two_le_iff
-/

#print Cardinal.two_le_iff' /-
theorem two_le_iff' (x : α) : (2 : Cardinal) ≤ (#α) ↔ ∃ y : α, y ≠ x := by
  rw [two_le_iff, ← nontrivial_iff, nontrivial_iff_exists_ne x]
#align cardinal.two_le_iff' Cardinal.two_le_iff'
-/

#print Cardinal.mk_eq_two_iff /-
theorem mk_eq_two_iff : (#α) = 2 ↔ ∃ x y : α, x ≠ y ∧ ({x, y} : Set α) = univ :=
  by
  simp only [← @Nat.cast_two Cardinal, mk_eq_nat_iff_finset, Finset.card_eq_two]
  constructor
  · rintro ⟨t, ht, x, y, hne, rfl⟩
    exact ⟨x, y, hne, by simpa using ht⟩
  · rintro ⟨x, y, hne, h⟩
    exact ⟨{x, y}, by simpa using h, x, y, hne, rfl⟩
#align cardinal.mk_eq_two_iff Cardinal.mk_eq_two_iff
-/

#print Cardinal.mk_eq_two_iff' /-
theorem mk_eq_two_iff' (x : α) : (#α) = 2 ↔ ∃! y, y ≠ x :=
  by
  rw [mk_eq_two_iff]; constructor
  · rintro ⟨a, b, hne, h⟩
    simp only [eq_univ_iff_forall, mem_insert_iff, mem_singleton_iff] at h
    rcases h x with (rfl | rfl)
    exacts [⟨b, hne.symm, fun z => (h z).resolve_left⟩, ⟨a, hne, fun z => (h z).resolve_right⟩]
  · rintro ⟨y, hne, hy⟩
    exact ⟨x, y, hne.symm, eq_univ_of_forall fun z => Classical.or_iff_not_imp_left.2 (hy z)⟩
#align cardinal.mk_eq_two_iff' Cardinal.mk_eq_two_iff'
-/

#print Cardinal.exists_not_mem_of_length_lt /-
theorem exists_not_mem_of_length_lt {α : Type _} (l : List α) (h : ↑l.length < (#α)) :
    ∃ z : α, z ∉ l := by
  contrapose! h
  calc
    (#α) = (#(Set.univ : Set α)) := mk_univ.symm
    _ ≤ (#l.to_finset) := (mk_le_mk_of_subset fun x _ => list.mem_to_finset.mpr (h x))
    _ = l.to_finset.card := Cardinal.mk_coe_finset
    _ ≤ l.length := cardinal.nat_cast_le.mpr (List.toFinset_card_le l)
#align cardinal.exists_not_mem_of_length_lt Cardinal.exists_not_mem_of_length_lt
-/

#print Cardinal.three_le /-
theorem three_le {α : Type _} (h : 3 ≤ (#α)) (x : α) (y : α) : ∃ z : α, z ≠ x ∧ z ≠ y :=
  by
  have : ↑(3 : ℕ) ≤ (#α); simpa using h
  have : ↑(2 : ℕ) < (#α); rwa [← succ_le_iff, ← Cardinal.nat_succ]
  have := exists_not_mem_of_length_lt [x, y] this
  simpa [not_or] using this
#align cardinal.three_le Cardinal.three_le
-/

#print Cardinal.powerlt /-
/-- The function `a ^< b`, defined as the supremum of `a ^ c` for `c < b`. -/
def powerlt (a b : Cardinal.{u}) : Cardinal.{u} :=
  ⨆ c : Iio b, a^c
#align cardinal.powerlt Cardinal.powerlt
-/

infixl:80 " ^< " => powerlt

#print Cardinal.le_powerlt /-
theorem le_powerlt {b c : Cardinal.{u}} (a) (h : c < b) : (a^c) ≤ a ^< b :=
  by
  apply @le_ciSup _ _ _ (fun y : Iio b => a^y) _ ⟨c, h⟩
  rw [← image_eq_range]
  exact bddAbove_image.{u, u} _ bddAbove_Iio
#align cardinal.le_powerlt Cardinal.le_powerlt
-/

#print Cardinal.powerlt_le /-
theorem powerlt_le {a b c : Cardinal.{u}} : a ^< b ≤ c ↔ ∀ x < b, (a^x) ≤ c :=
  by
  rw [powerlt, ciSup_le_iff']
  · simp
  · rw [← image_eq_range]
    exact bddAbove_image.{u, u} _ bddAbove_Iio
#align cardinal.powerlt_le Cardinal.powerlt_le
-/

#print Cardinal.powerlt_le_powerlt_left /-
theorem powerlt_le_powerlt_left {a b c : Cardinal} (h : b ≤ c) : a ^< b ≤ a ^< c :=
  powerlt_le.2 fun x hx => le_powerlt a <| hx.trans_le h
#align cardinal.powerlt_le_powerlt_left Cardinal.powerlt_le_powerlt_left
-/

#print Cardinal.powerlt_mono_left /-
theorem powerlt_mono_left (a) : Monotone fun c => a ^< c := fun b c => powerlt_le_powerlt_left
#align cardinal.powerlt_mono_left Cardinal.powerlt_mono_left
-/

#print Cardinal.powerlt_succ /-
theorem powerlt_succ {a b : Cardinal} (h : a ≠ 0) : a ^< succ b = (a^b) :=
  (powerlt_le.2 fun c h' => power_le_power_left h <| le_of_lt_succ h').antisymm <|
    le_powerlt a (lt_succ b)
#align cardinal.powerlt_succ Cardinal.powerlt_succ
-/

#print Cardinal.powerlt_min /-
theorem powerlt_min {a b c : Cardinal} : a ^< min b c = min (a ^< b) (a ^< c) :=
  (powerlt_mono_left a).map_min
#align cardinal.powerlt_min Cardinal.powerlt_min
-/

#print Cardinal.powerlt_max /-
theorem powerlt_max {a b c : Cardinal} : a ^< max b c = max (a ^< b) (a ^< c) :=
  (powerlt_mono_left a).map_max
#align cardinal.powerlt_max Cardinal.powerlt_max
-/

#print Cardinal.zero_powerlt /-
theorem zero_powerlt {a : Cardinal} (h : a ≠ 0) : 0 ^< a = 1 :=
  by
  apply (powerlt_le.2 fun c hc => zero_power_le _).antisymm
  rw [← power_zero]
  exact le_powerlt 0 (pos_iff_ne_zero.2 h)
#align cardinal.zero_powerlt Cardinal.zero_powerlt
-/

#print Cardinal.powerlt_zero /-
@[simp]
theorem powerlt_zero {a : Cardinal} : a ^< 0 = 0 :=
  by
  convert Cardinal.iSup_of_empty _
  exact Subtype.isEmpty_of_false fun x => (Cardinal.zero_le _).not_lt
#align cardinal.powerlt_zero Cardinal.powerlt_zero
-/

end Cardinal

namespace Tactic

open Cardinal Positivity

/-- Extension for the `positivity` tactic: The cardinal power of a positive cardinal is positive. -/
@[positivity]
unsafe def positivity_cardinal_pow : expr → tactic strictness
  | q(@Pow.pow _ _ $(inst) $(a) $(b)) => do
    let strictness_a ← core a
    match strictness_a with
      | positive p => positive <$> mk_app `` power_pos [b, p]
      | _ => failed
  |-- We already know that `0 ≤ x` for all `x : cardinal`
    _ =>
    failed
#align tactic.positivity_cardinal_pow tactic.positivity_cardinal_pow

end Tactic

