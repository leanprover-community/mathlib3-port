import Mathbin.Data.Option.Basic 
import Mathbin.Logic.Nontrivial 
import Mathbin.Order.Lattice 
import Mathbin.Order.OrderDual 
import Mathbin.Tactic.PiInstances

/-!
# ⊤ and ⊥, bounded lattices and variants

This file defines top and bottom elements (greatest and least elements) of a type, the bounded
variants of different kinds of lattices, sets up the typeclass hierarchy between them and provides
instances for `Prop` and `fun`.

## Main declarations

* `has_<top/bot> α`: Typeclasses to declare the `⊤`/`⊥` notation.
* `order_<top/bot> α`: Order with a top/bottom element.
* `bounded_order α`: Order with a top and bottom element.
* `with_<top/bot> α`: Equips `option α` with the order on `α` plus `none` as the top/bottom element.
* `semilattice_<sup/inf>_<top/bot>`: Semilattice with a join/meet and a top/bottom element (all four
  combinations). Typical examples include `ℕ`.
* `is_compl x y`: In a bounded lattice, predicate for "`x` is a complement of `y`". Note that in a
  non distributive lattice, an element can have several complements.
* `is_complemented α`: Typeclass stating that any element of a lattice has a complement.

## Common lattices

* Distributive lattices with a bottom element. Notated by `[distrib_lattice α] [order_bot α]`
  It captures the properties of `disjoint` that are common to `generalized_boolean_algebra` and
  `distrib_lattice` when `order_bot`.
* Bounded and distributive lattice. Notated by `[distrib_lattice α] [bounded_order α]`.
  Typical examples include `Prop` and `set α`.

## Implementation notes

We didn't prove things about `[distrib_lattice α] [order_top α]` because the dual notion of
`disjoint` isn't really used anywhere.
-/


/-! ### Top, bottom element -/


universe u v

variable {α : Type u} {β : Type v}

/-- Typeclass for the `⊤` (`\top`) notation -/
@[notationClass]
class HasTop (α : Type u) where 
  top : α

/-- Typeclass for the `⊥` (`\bot`) notation -/
@[notationClass]
class HasBot (α : Type u) where 
  bot : α

notation "⊤" => HasTop.top

notation "⊥" => HasBot.bot

instance (priority := 100) has_top_nonempty (α : Type u) [HasTop α] : Nonempty α :=
  ⟨⊤⟩

instance (priority := 100) has_bot_nonempty (α : Type u) [HasBot α] : Nonempty α :=
  ⟨⊥⟩

attribute [matchPattern] HasBot.bot HasTop.top

/-- An order is an `order_top` if it has a greatest element.
We state this using a data mixin, holding the value of `⊤` and the greatest element constraint. -/
@[ancestor HasTop]
class OrderTop (α : Type u) [LE α] extends HasTop α where 
  le_top : ∀ a : α, a ≤ ⊤

section OrderTop

variable [PartialOrderₓ α] [OrderTop α] {a b : α}

@[simp]
theorem le_top {α : Type u} [LE α] [OrderTop α] {a : α} : a ≤ ⊤ :=
  OrderTop.le_top a

@[simp]
theorem not_top_lt {α : Type u} [Preorderₓ α] [OrderTop α] {a : α} : ¬⊤ < a :=
  fun h => lt_irreflₓ a (lt_of_le_of_ltₓ le_top h)

theorem top_unique (h : ⊤ ≤ a) : a = ⊤ :=
  le_top.antisymm h

theorem eq_top_iff : a = ⊤ ↔ ⊤ ≤ a :=
  ⟨fun eq => Eq.symm ▸ le_reflₓ ⊤, top_unique⟩

@[simp]
theorem top_le_iff : ⊤ ≤ a ↔ a = ⊤ :=
  ⟨top_unique, fun h => h.symm ▸ le_reflₓ ⊤⟩

@[simp]
theorem is_top_iff_eq_top : IsTop a ↔ a = ⊤ :=
  ⟨fun h => h.unique le_top, fun h b => h.symm ▸ le_top⟩

theorem eq_top_mono (h : a ≤ b) (h₂ : a = ⊤) : b = ⊤ :=
  top_le_iff.1$ h₂ ▸ h

theorem lt_top_iff_ne_top : a < ⊤ ↔ a ≠ ⊤ :=
  le_top.lt_iff_ne

theorem ne_top_of_lt (h : a < b) : a ≠ ⊤ :=
  lt_top_iff_ne_top.1$ lt_of_lt_of_leₓ h le_top

alias ne_top_of_lt ← LT.lt.ne_top

theorem ne_top_of_le_ne_top {a b : α} (hb : b ≠ ⊤) (hab : a ≤ b) : a ≠ ⊤ :=
  fun ha => hb$ top_unique$ ha ▸ hab

theorem eq_top_of_maximal (h : ∀ b, ¬a < b) : a = ⊤ :=
  Or.elim (lt_or_eq_of_leₓ le_top) (fun hlt => absurd hlt (h ⊤)) fun he => he

theorem Ne.lt_top (h : a ≠ ⊤) : a < ⊤ :=
  lt_top_iff_ne_top.mpr h

theorem Ne.lt_top' (h : ⊤ ≠ a) : a < ⊤ :=
  h.symm.lt_top

end OrderTop

theorem StrictMono.maximal_preimage_top [LinearOrderₓ α] [Preorderₓ β] [OrderTop β] {f : α → β} (H : StrictMono f) {a}
  (h_top : f a = ⊤) (x : α) : x ≤ a :=
  H.maximal_of_maximal_image
    (fun p =>
      by 
        rw [h_top]
        exact le_top)
    x

-- error in Order.BoundedOrder: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem order_top.ext_top
{α}
{hA : partial_order α}
(A : order_top α)
{hB : partial_order α}
(B : order_top α)
(H : ∀
 x
 y : α, «expr ↔ »(by haveI [] [] [":=", expr hA]; exact [expr «expr ≤ »(x, y)], «expr ≤ »(x, y))) : «expr = »((by haveI [] [] [":=", expr A]; exact [expr «expr⊤»()] : α), «expr⊤»()) :=
«expr $ »(top_unique, by rw ["<-", expr H] []; apply [expr le_top])

-- error in Order.BoundedOrder: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem order_top.ext {α} [partial_order α] {A B : order_top α} : «expr = »(A, B) :=
begin
  have [ident tt] [] [":=", expr order_top.ext_top A B (λ _ _, iff.rfl)],
  casesI [expr A] ["with", "_", ident ha],
  casesI [expr B] ["with", "_", ident hb],
  congr,
  exact [expr le_antisymm (hb _) (ha _)]
end

/-- An order is an `order_bot` if it has a least element.
We state this using a data mixin, holding the value of `⊥` and the least element constraint. -/
@[ancestor HasBot]
class OrderBot (α : Type u) [LE α] extends HasBot α where 
  bot_le : ∀ a : α, ⊥ ≤ a

section OrderBot

variable [PartialOrderₓ α] [OrderBot α] {a b : α}

@[simp]
theorem bot_le {α : Type u} [LE α] [OrderBot α] {a : α} : ⊥ ≤ a :=
  OrderBot.bot_le a

@[simp]
theorem not_lt_bot {α : Type u} [Preorderₓ α] [OrderBot α] {a : α} : ¬a < ⊥ :=
  fun h => lt_irreflₓ a (lt_of_lt_of_leₓ h bot_le)

theorem bot_unique (h : a ≤ ⊥) : a = ⊥ :=
  h.antisymm bot_le

theorem eq_bot_iff : a = ⊥ ↔ a ≤ ⊥ :=
  ⟨fun eq => Eq.symm ▸ le_reflₓ ⊥, bot_unique⟩

@[simp]
theorem le_bot_iff : a ≤ ⊥ ↔ a = ⊥ :=
  ⟨bot_unique, fun h => h.symm ▸ le_reflₓ ⊥⟩

@[simp]
theorem is_bot_iff_eq_bot : IsBot a ↔ a = ⊥ :=
  ⟨fun h => h.unique bot_le, fun h b => h.symm ▸ bot_le⟩

theorem ne_bot_of_le_ne_bot {a b : α} (hb : b ≠ ⊥) (hab : b ≤ a) : a ≠ ⊥ :=
  fun ha => hb$ bot_unique$ ha ▸ hab

theorem eq_bot_mono (h : a ≤ b) (h₂ : b = ⊥) : a = ⊥ :=
  le_bot_iff.1$ h₂ ▸ h

-- error in Order.BoundedOrder: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem bot_lt_iff_ne_bot : «expr ↔ »(«expr < »(«expr⊥»(), a), «expr ≠ »(a, «expr⊥»())) :=
begin
  haveI [] [] [":=", expr classical.dec_eq α],
  haveI [] [":", expr decidable «expr ≤ »(a, «expr⊥»())] [":=", expr decidable_of_iff' _ le_bot_iff],
  simp [] [] ["only"] ["[", expr lt_iff_le_not_le, ",", expr not_iff_not.mpr le_bot_iff, ",", expr true_and, ",", expr bot_le, "]"] [] []
end

theorem ne_bot_of_gt (h : a < b) : b ≠ ⊥ :=
  bot_lt_iff_ne_bot.1$ lt_of_le_of_ltₓ bot_le h

alias ne_bot_of_gt ← LT.lt.ne_bot

theorem eq_bot_of_minimal (h : ∀ b, ¬b < a) : a = ⊥ :=
  Or.elim (lt_or_eq_of_leₓ bot_le) (fun hlt => absurd hlt (h ⊥)) fun he => he.symm

theorem Ne.bot_lt (h : a ≠ ⊥) : ⊥ < a :=
  bot_lt_iff_ne_bot.mpr h

theorem Ne.bot_lt' (h : ⊥ ≠ a) : ⊥ < a :=
  h.symm.bot_lt

end OrderBot

theorem StrictMono.minimal_preimage_bot [LinearOrderₓ α] [PartialOrderₓ β] [OrderBot β] {f : α → β} (H : StrictMono f)
  {a} (h_bot : f a = ⊥) (x : α) : a ≤ x :=
  H.minimal_of_minimal_image
    (fun p =>
      by 
        rw [h_bot]
        exact bot_le)
    x

-- error in Order.BoundedOrder: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem order_bot.ext_bot
{α}
{hA : partial_order α}
(A : order_bot α)
{hB : partial_order α}
(B : order_bot α)
(H : ∀
 x
 y : α, «expr ↔ »(by haveI [] [] [":=", expr hA]; exact [expr «expr ≤ »(x, y)], «expr ≤ »(x, y))) : «expr = »((by haveI [] [] [":=", expr A]; exact [expr «expr⊥»()] : α), «expr⊥»()) :=
«expr $ »(bot_unique, by rw ["<-", expr H] []; apply [expr bot_le])

-- error in Order.BoundedOrder: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem order_bot.ext {α} [partial_order α] {A B : order_bot α} : «expr = »(A, B) :=
begin
  have [ident tt] [] [":=", expr order_bot.ext_bot A B (λ _ _, iff.rfl)],
  casesI [expr A] ["with", ident a, ident ha],
  casesI [expr B] ["with", ident b, ident hb],
  congr,
  exact [expr le_antisymm (ha _) (hb _)]
end

section SemilatticeSupTop

variable [SemilatticeSup α] [OrderTop α] {a : α}

@[simp]
theorem top_sup_eq : ⊤⊔a = ⊤ :=
  sup_of_le_left le_top

@[simp]
theorem sup_top_eq : a⊔⊤ = ⊤ :=
  sup_of_le_right le_top

end SemilatticeSupTop

section SemilatticeSupBot

variable [SemilatticeSup α] [OrderBot α] {a b : α}

@[simp]
theorem bot_sup_eq : ⊥⊔a = a :=
  sup_of_le_right bot_le

@[simp]
theorem sup_bot_eq : a⊔⊥ = a :=
  sup_of_le_left bot_le

@[simp]
theorem sup_eq_bot_iff : a⊔b = ⊥ ↔ a = ⊥ ∧ b = ⊥ :=
  by 
    rw [eq_bot_iff, sup_le_iff] <;> simp 

end SemilatticeSupBot

section SemilatticeInfTop

variable [SemilatticeInf α] [OrderTop α] {a b : α}

@[simp]
theorem top_inf_eq : ⊤⊓a = a :=
  inf_of_le_right le_top

@[simp]
theorem inf_top_eq : a⊓⊤ = a :=
  inf_of_le_left le_top

@[simp]
theorem inf_eq_top_iff : a⊓b = ⊤ ↔ a = ⊤ ∧ b = ⊤ :=
  by 
    rw [eq_top_iff, le_inf_iff] <;> simp 

end SemilatticeInfTop

section SemilatticeInfBot

variable [SemilatticeInf α] [OrderBot α] {a : α}

@[simp]
theorem bot_inf_eq : ⊥⊓a = ⊥ :=
  inf_of_le_left bot_le

@[simp]
theorem inf_bot_eq : a⊓⊥ = ⊥ :=
  inf_of_le_right bot_le

end SemilatticeInfBot

/-! ### Bounded lattice -/


/-- A bounded order describes an order `(≤)` with a top and bottom element,
  denoted `⊤` and `⊥` respectively. This allows for the interpretation
  of all finite suprema and infima, taking `inf ∅ = ⊤` and `sup ∅ = ⊥`. -/
@[ancestor OrderTop OrderBot]
class BoundedOrder (α : Type u) [LE α] extends OrderTop α, OrderBot α

-- error in Order.BoundedOrder: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem bounded_order.ext {α} [partial_order α] {A B : bounded_order α} : «expr = »(A, B) :=
begin
  have [ident ht] [":", expr «expr = »(@bounded_order.to_order_top α _ A, @bounded_order.to_order_top α _ B)] [":=", expr order_top.ext],
  have [ident hb] [":", expr «expr = »(@bounded_order.to_order_bot α _ A, @bounded_order.to_order_bot α _ B)] [":=", expr order_bot.ext],
  casesI [expr A] [],
  casesI [expr B] [],
  injection [expr ht] ["with", ident h],
  injection [expr hb] ["with", ident h'],
  convert [] [expr rfl] [],
  { exact [expr h.symm] },
  { exact [expr h'.symm] }
end

theorem inf_eq_bot_iff_le_compl {α : Type u} [DistribLattice α] [BoundedOrder α] {a b c : α} (h₁ : b⊔c = ⊤)
  (h₂ : b⊓c = ⊥) : a⊓b = ⊥ ↔ a ≤ c :=
  ⟨fun h =>
      calc a ≤ a⊓(b⊔c) :=
        by 
          simp [h₁]
        _ = a⊓b⊔a⊓c :=
        by 
          simp [inf_sup_left]
        _ ≤ c :=
        by 
          simp [h, inf_le_right]
        ,
    fun h =>
      bot_unique$
        calc a⊓b ≤ b⊓c :=
          by 
            rw [inf_comm]
            exact inf_le_inf_left _ h 
          _ = ⊥ := h₂
          ⟩

/-- Propositions form a distributive lattice. -/
instance Prop.distribLattice : DistribLattice Prop :=
  { le := fun a b => a → b, le_refl := fun _ => id, le_trans := fun a b c f g => g ∘ f,
    le_antisymm := fun a b Hab Hba => propext ⟨Hab, Hba⟩, sup := Or, le_sup_left := @Or.inl, le_sup_right := @Or.inr,
    sup_le := fun a b c => Or.ndrec, inf := And, inf_le_left := @And.left, inf_le_right := @And.right,
    le_inf := fun a b c Hab Hac Ha => And.intro (Hab Ha) (Hac Ha),
    le_sup_inf := fun a b c H => or_iff_not_imp_left.2$ fun Ha => ⟨H.1.resolve_left Ha, H.2.resolve_left Ha⟩ }

/-- Propositions form a bounded order. -/
instance Prop.boundedOrder : BoundedOrder Prop :=
  { top := True, le_top := fun a Ha => True.intro, bot := False, bot_le := @False.elim }

noncomputable instance Prop.linearOrder : LinearOrderₓ Prop :=
  @Lattice.toLinearOrder Prop _ (Classical.decEq _) (Classical.decRel _) (Classical.decRel _)$
    fun p q =>
      by 
        change (p → q) ∨ (q → p)
        tauto!

@[simp]
theorem le_Prop_eq : (· ≤ · : Prop → Prop → Prop) = «->» · · :=
  rfl

@[simp]
theorem sup_Prop_eq : ·⊔· = (· ∨ ·) :=
  rfl

@[simp]
theorem inf_Prop_eq : ·⊓· = (· ∧ ·) :=
  rfl

section Logic

variable [Preorderₓ α]

theorem monotone_and {p q : α → Prop} (m_p : Monotone p) (m_q : Monotone q) : Monotone fun x => p x ∧ q x :=
  fun a b h => And.imp (m_p h) (m_q h)

theorem monotone_or {p q : α → Prop} (m_p : Monotone p) (m_q : Monotone q) : Monotone fun x => p x ∨ q x :=
  fun a b h => Or.imp (m_p h) (m_q h)

end Logic

/-! ### Function lattices -/


namespace Pi

variable {ι : Type _} {α' : ι → Type _}

instance [∀ i, HasBot (α' i)] : HasBot (∀ i, α' i) :=
  ⟨fun i => ⊥⟩

@[simp]
theorem bot_apply [∀ i, HasBot (α' i)] (i : ι) : (⊥ : ∀ i, α' i) i = ⊥ :=
  rfl

theorem bot_def [∀ i, HasBot (α' i)] : (⊥ : ∀ i, α' i) = fun i => ⊥ :=
  rfl

instance [∀ i, HasTop (α' i)] : HasTop (∀ i, α' i) :=
  ⟨fun i => ⊤⟩

@[simp]
theorem top_apply [∀ i, HasTop (α' i)] (i : ι) : (⊤ : ∀ i, α' i) i = ⊤ :=
  rfl

theorem top_def [∀ i, HasTop (α' i)] : (⊤ : ∀ i, α' i) = fun i => ⊤ :=
  rfl

instance [∀ i, LE (α' i)] [∀ i, OrderTop (α' i)] : OrderTop (∀ i, α' i) :=
  { Pi.hasTop with le_top := fun _ _ => le_top }

instance [∀ i, LE (α' i)] [∀ i, OrderBot (α' i)] : OrderBot (∀ i, α' i) :=
  { Pi.hasBot with bot_le := fun _ _ => bot_le }

instance [∀ i, LE (α' i)] [∀ i, BoundedOrder (α' i)] : BoundedOrder (∀ i, α' i) :=
  { Pi.orderTop, Pi.orderBot with  }

end Pi

section Subsingleton

variable [PartialOrderₓ α] [BoundedOrder α]

theorem eq_bot_of_bot_eq_top (hα : (⊥ : α) = ⊤) (x : α) : x = (⊥ : α) :=
  eq_bot_mono le_top (Eq.symm hα)

theorem eq_top_of_bot_eq_top (hα : (⊥ : α) = ⊤) (x : α) : x = (⊤ : α) :=
  eq_top_mono bot_le hα

theorem subsingleton_of_top_le_bot (h : (⊤ : α) ≤ (⊥ : α)) : Subsingleton α :=
  ⟨fun a b => le_antisymmₓ (le_transₓ le_top$ le_transₓ h bot_le) (le_transₓ le_top$ le_transₓ h bot_le)⟩

theorem subsingleton_of_bot_eq_top (hα : (⊥ : α) = (⊤ : α)) : Subsingleton α :=
  subsingleton_of_top_le_bot (ge_of_eq hα)

theorem subsingleton_iff_bot_eq_top : (⊥ : α) = (⊤ : α) ↔ Subsingleton α :=
  ⟨subsingleton_of_bot_eq_top,
    fun h =>
      by 
        exact Subsingleton.elimₓ ⊥ ⊤⟩

end Subsingleton

/-! ### `with_bot`, `with_top` -/


/-- Attach `⊥` to a type. -/
def WithBot (α : Type _) :=
  Option α

namespace WithBot

unsafe instance {α} [has_to_format α] : has_to_format (WithBot α) :=
  { to_format :=
      fun x =>
        match x with 
        | none => "⊥"
        | some x => to_fmt x }

instance : CoeTₓ α (WithBot α) :=
  ⟨some⟩

instance HasBot : HasBot (WithBot α) :=
  ⟨none⟩

instance : Inhabited (WithBot α) :=
  ⟨⊥⟩

theorem none_eq_bot : (none : WithBot α) = (⊥ : WithBot α) :=
  rfl

theorem some_eq_coe (a : α) : (some a : WithBot α) = («expr↑ » a : WithBot α) :=
  rfl

@[simp]
theorem bot_ne_coe (a : α) : ⊥ ≠ (a : WithBot α) :=
  fun.

@[simp]
theorem coe_ne_bot (a : α) : (a : WithBot α) ≠ ⊥ :=
  fun.

/-- Recursor for `with_bot` using the preferred forms `⊥` and `↑a`. -/
@[elab_as_eliminator]
def rec_bot_coe {C : WithBot α → Sort _} (h₁ : C ⊥) (h₂ : ∀ a : α, C a) : ∀ n : WithBot α, C n :=
  Option.rec h₁ h₂

@[normCast]
theorem coe_eq_coe {a b : α} : (a : WithBot α) = b ↔ a = b :=
  by 
    rw [←Option.some.inj_eq a b] <;> rfl

theorem ne_bot_iff_exists {x : WithBot α} : x ≠ ⊥ ↔ ∃ a : α, «expr↑ » a = x :=
  Option.ne_none_iff_exists

/-- Deconstruct a `x : with_bot α` to the underlying value in `α`, given a proof that `x ≠ ⊥`. -/
def unbot : ∀ x : WithBot α, x ≠ ⊥ → α
| ⊥, h => absurd rfl h
| some x, h => x

@[simp]
theorem coe_unbot {α : Type _} (x : WithBot α) (h : x ≠ ⊥) : (x.unbot h : WithBot α) = x :=
  by 
    cases x 
    simpa using h 
    rfl

@[simp]
theorem unbot_coe (x : α) (h : (x : WithBot α) ≠ ⊥ := coe_ne_bot _) : (x : WithBot α).unbot h = x :=
  rfl

instance (priority := 10) LE [LE α] : LE (WithBot α) :=
  { le := fun o₁ o₂ : Option α => ∀ a _ : a ∈ o₁, ∃ (b : _)(_ : b ∈ o₂), a ≤ b }

instance (priority := 10) LT [LT α] : LT (WithBot α) :=
  { lt := fun o₁ o₂ : Option α => ∃ (b : _)(_ : b ∈ o₂), ∀ a _ : a ∈ o₁, a < b }

@[simp]
theorem some_lt_some [LT α] {a b : α} : @LT.lt (WithBot α) _ (some a) (some b) ↔ a < b :=
  by 
    simp [· < ·]

theorem none_lt_some [LT α] (a : α) : @LT.lt (WithBot α) _ none (some a) :=
  ⟨a, rfl, fun b hb => (Option.not_mem_none _ hb).elim⟩

theorem bot_lt_coe [LT α] (a : α) : (⊥ : WithBot α) < a :=
  none_lt_some a

instance : CanLift (WithBot α) α :=
  { coe := coeₓ, cond := fun r => r ≠ ⊥,
    prf := fun x hx => ⟨Option.get$ Option.ne_none_iff_is_some.1 hx, Option.some_get _⟩ }

instance [Preorderₓ α] : Preorderₓ (WithBot α) :=
  { le := · ≤ ·, lt := · < ·,
    lt_iff_le_not_le :=
      by 
        intros  <;> cases a <;> cases b <;> simp [lt_iff_le_not_leₓ] <;> simp [· ≤ ·, · < ·] <;> split  <;> rfl,
    le_refl := fun o a ha => ⟨a, ha, le_reflₓ _⟩,
    le_trans :=
      fun o₁ o₂ o₃ h₁ h₂ a ha =>
        let ⟨b, hb, ab⟩ := h₁ a ha 
        let ⟨c, hc, bc⟩ := h₂ b hb
        ⟨c, hc, le_transₓ ab bc⟩ }

instance PartialOrderₓ [PartialOrderₓ α] : PartialOrderₓ (WithBot α) :=
  { WithBot.preorder with
    le_antisymm :=
      fun o₁ o₂ h₁ h₂ =>
        by 
          cases' o₁ with a
          ·
            cases' o₂ with b
            ·
              rfl 
            rcases h₂ b rfl with ⟨_, ⟨⟩, _⟩
          ·
            rcases h₁ a rfl with ⟨b, ⟨⟩, h₁'⟩
            rcases h₂ b rfl with ⟨_, ⟨⟩, h₂'⟩
            rw [le_antisymmₓ h₁' h₂'] }

instance OrderBot [LE α] : OrderBot (WithBot α) :=
  { WithBot.hasBot with bot_le := fun a a' h => Option.noConfusion h }

@[simp, normCast]
theorem coe_le_coe [LE α] {a b : α} : (a : WithBot α) ≤ b ↔ a ≤ b :=
  ⟨fun h =>
      by 
        rcases h a rfl with ⟨_, ⟨⟩, h⟩ <;> exact h,
    fun h a' e => Option.some_inj.1 e ▸ ⟨b, rfl, h⟩⟩

@[simp]
theorem some_le_some [LE α] {a b : α} : @LE.le (WithBot α) _ (some a) (some b) ↔ a ≤ b :=
  coe_le_coe

theorem coe_le [LE α] {a b : α} : ∀ {o : Option α}, b ∈ o → ((a : WithBot α) ≤ o ↔ a ≤ b)
| _, rfl => coe_le_coe

@[normCast]
theorem coe_lt_coe [LT α] {a b : α} : (a : WithBot α) < b ↔ a < b :=
  some_lt_some

theorem le_coe_get_or_else [Preorderₓ α] : ∀ a : WithBot α b : α, a ≤ a.get_or_else b
| some a, b => le_reflₓ a
| none, b => fun _ h => Option.noConfusion h

@[simp]
theorem get_or_else_bot (a : α) : Option.getOrElse (⊥ : WithBot α) a = a :=
  rfl

theorem get_or_else_bot_le_iff [LE α] [OrderBot α] {a : WithBot α} {b : α} : a.get_or_else ⊥ ≤ b ↔ a ≤ b :=
  by 
    cases a <;> simp [none_eq_bot, some_eq_coe]

instance decidable_le [LE α] [@DecidableRel α (· ≤ ·)] : @DecidableRel (WithBot α) (· ≤ ·)
| none, x => is_true$ fun a h => Option.noConfusion h
| some x, some y =>
  if h : x ≤ y then is_true (some_le_some.2 h) else
    is_false$
      by 
        simp 
| some x, none =>
  is_false$
    fun h =>
      by 
        rcases h x rfl with ⟨y, ⟨_⟩, _⟩

instance decidable_lt [LT α] [@DecidableRel α (· < ·)] : @DecidableRel (WithBot α) (· < ·)
| none, some x =>
  is_true$
    by 
      exists x, rfl <;> rintro _ ⟨⟩
| some x, some y =>
  if h : x < y then
    is_true$
      by 
        simp 
  else
    is_false$
      by 
        simp 
| x, none =>
  is_false$
    by 
      rintro ⟨a, ⟨⟨⟩⟩⟩

instance [PartialOrderₓ α] [IsTotal α (· ≤ ·)] : IsTotal (WithBot α) (· ≤ ·) :=
  { Total :=
      fun a b =>
        match a, b with 
        | none, _ => Or.inl bot_le
        | _, none => Or.inr bot_le
        | some x, some y =>
          by 
            simp only [some_le_some, total_of] }

instance SemilatticeSup [SemilatticeSup α] : SemilatticeSup (WithBot α) :=
  { WithBot.orderBot, WithBot.partialOrder with sup := Option.liftOrGet (·⊔·),
    le_sup_left :=
      fun o₁ o₂ a ha =>
        by 
          cases ha <;> cases o₂ <;> simp [Option.liftOrGet],
    le_sup_right :=
      fun o₁ o₂ a ha =>
        by 
          cases ha <;> cases o₁ <;> simp [Option.liftOrGet],
    sup_le :=
      fun o₁ o₂ o₃ h₁ h₂ a ha =>
        by 
          cases' o₁ with b <;> cases' o₂ with c <;> cases ha
          ·
            exact h₂ a rfl
          ·
            exact h₁ a rfl
          ·
            rcases h₁ b rfl with ⟨d, ⟨⟩, h₁'⟩
            simp  at h₂ 
            exact ⟨d, rfl, sup_le h₁' h₂⟩ }

theorem coe_sup [SemilatticeSup α] (a b : α) : ((a⊔b : α) : WithBot α) = a⊔b :=
  rfl

instance SemilatticeInf [SemilatticeInf α] : SemilatticeInf (WithBot α) :=
  { WithBot.orderBot, WithBot.partialOrder with inf := fun o₁ o₂ => o₁.bind fun a => o₂.map fun b => a⊓b,
    inf_le_left :=
      fun o₁ o₂ a ha =>
        by 
          simp  at ha 
          rcases ha with ⟨b, rfl, c, rfl, rfl⟩
          exact ⟨_, rfl, inf_le_left⟩,
    inf_le_right :=
      fun o₁ o₂ a ha =>
        by 
          simp  at ha 
          rcases ha with ⟨b, rfl, c, rfl, rfl⟩
          exact ⟨_, rfl, inf_le_right⟩,
    le_inf :=
      fun o₁ o₂ o₃ h₁ h₂ a ha =>
        by 
          cases ha 
          rcases h₁ a rfl with ⟨b, ⟨⟩, ab⟩
          rcases h₂ a rfl with ⟨c, ⟨⟩, ac⟩
          exact ⟨_, rfl, le_inf ab ac⟩ }

theorem coe_inf [SemilatticeInf α] (a b : α) : ((a⊓b : α) : WithBot α) = a⊓b :=
  rfl

instance Lattice [Lattice α] : Lattice (WithBot α) :=
  { WithBot.semilatticeSup, WithBot.semilatticeInf with  }

instance LinearOrderₓ [LinearOrderₓ α] : LinearOrderₓ (WithBot α) :=
  Lattice.toLinearOrder _$
    fun o₁ o₂ =>
      by 
        cases' o₁ with a
        ·
          exact Or.inl bot_le 
        cases' o₂ with b
        ·
          exact Or.inr bot_le 
        simp [le_totalₓ]

@[normCast]
theorem coe_min [LinearOrderₓ α] (x y : α) : ((min x y : α) : WithBot α) = min x y :=
  rfl

@[normCast]
theorem coe_max [LinearOrderₓ α] (x y : α) : ((max x y : α) : WithBot α) = max x y :=
  rfl

instance OrderTop [LE α] [OrderTop α] : OrderTop (WithBot α) :=
  { top := some ⊤,
    le_top :=
      fun o a ha =>
        by 
          cases ha <;> exact ⟨_, rfl, le_top⟩ }

instance BoundedOrder [LE α] [OrderTop α] : BoundedOrder (WithBot α) :=
  { WithBot.orderTop, WithBot.orderBot with  }

theorem well_founded_lt [PartialOrderₓ α] (h : WellFounded (· < · : α → α → Prop)) :
  WellFounded (· < · : WithBot α → WithBot α → Prop) :=
  have acc_bot : Acc (· < · : WithBot α → WithBot α → Prop) ⊥ := Acc.intro _ fun a ha => (not_le_of_gtₓ ha bot_le).elim
  ⟨fun a =>
      Option.recOn a acc_bot
        fun a =>
          Acc.intro _
            fun b =>
              Option.recOn b (fun _ => acc_bot)
                fun b =>
                  WellFounded.induction h b
                    (show
                      ∀ b : α,
                        (∀ c, c < b → (c : WithBot α) < a → Acc (· < · : WithBot α → WithBot α → Prop) c) →
                          (b : WithBot α) < a → Acc (· < · : WithBot α → WithBot α → Prop) b from
                      fun b ih hba =>
                        Acc.intro _
                          fun c =>
                            Option.recOn c (fun _ => acc_bot) fun c hc => ih _ (some_lt_some.1 hc) (lt_transₓ hc hba))⟩

instance DenselyOrdered [PartialOrderₓ α] [DenselyOrdered α] [NoBotOrder α] : DenselyOrdered (WithBot α) :=
  ⟨fun a b =>
      match a, b with 
      | a, none => fun h : a < ⊥ => (not_lt_bot h).elim
      | none, some b =>
        fun h =>
          let ⟨a, ha⟩ := no_bot b
          ⟨a, bot_lt_coe a, coe_lt_coe.2 ha⟩
      | some a, some b =>
        fun h =>
          let ⟨a, ha₁, ha₂⟩ := exists_between (coe_lt_coe.1 h)
          ⟨a, coe_lt_coe.2 ha₁, coe_lt_coe.2 ha₂⟩⟩

instance {α : Type _} [Preorderₓ α] [NoTopOrder α] [Nonempty α] : NoTopOrder (WithBot α) :=
  ⟨by 
      apply WithBot.recBotCoe
      ·
        apply ‹Nonempty α›.elim 
        exact fun a => ⟨a, WithBot.bot_lt_coe a⟩
      ·
        intro a 
        obtain ⟨b, ha⟩ := no_top a 
        exact ⟨b, with_bot.coe_lt_coe.mpr ha⟩⟩

end WithBot

/-- Attach `⊤` to a type. -/
def WithTop (α : Type _) :=
  Option α

namespace WithTop

unsafe instance {α} [has_to_format α] : has_to_format (WithTop α) :=
  { to_format :=
      fun x =>
        match x with 
        | none => "⊤"
        | some x => to_fmt x }

instance : CoeTₓ α (WithTop α) :=
  ⟨some⟩

instance HasTop : HasTop (WithTop α) :=
  ⟨none⟩

instance : Inhabited (WithTop α) :=
  ⟨⊤⟩

theorem none_eq_top : (none : WithTop α) = (⊤ : WithTop α) :=
  rfl

theorem some_eq_coe (a : α) : (some a : WithTop α) = («expr↑ » a : WithTop α) :=
  rfl

/-- Recursor for `with_top` using the preferred forms `⊤` and `↑a`. -/
@[elab_as_eliminator]
def rec_top_coe {C : WithTop α → Sort _} (h₁ : C ⊤) (h₂ : ∀ a : α, C a) : ∀ n : WithTop α, C n :=
  Option.rec h₁ h₂

@[normCast]
theorem coe_eq_coe {a b : α} : (a : WithTop α) = b ↔ a = b :=
  by 
    rw [←Option.some.inj_eq a b] <;> rfl

@[simp]
theorem top_ne_coe {a : α} : ⊤ ≠ (a : WithTop α) :=
  fun.

@[simp]
theorem coe_ne_top {a : α} : (a : WithTop α) ≠ ⊤ :=
  fun.

theorem ne_top_iff_exists {x : WithTop α} : x ≠ ⊤ ↔ ∃ a : α, «expr↑ » a = x :=
  Option.ne_none_iff_exists

/-- Deconstruct a `x : with_top α` to the underlying value in `α`, given a proof that `x ≠ ⊤`. -/
def untop : ∀ x : WithTop α, x ≠ ⊤ → α :=
  WithBot.unbot

@[simp]
theorem coe_untop {α : Type _} (x : WithTop α) (h : x ≠ ⊤) : (x.untop h : WithTop α) = x :=
  by 
    cases x 
    simpa using h 
    rfl

@[simp]
theorem untop_coe (x : α) (h : (x : WithTop α) ≠ ⊤ := coe_ne_top) : (x : WithTop α).untop h = x :=
  rfl

instance (priority := 10) LT [LT α] : LT (WithTop α) :=
  { lt := fun o₁ o₂ : Option α => ∃ (b : _)(_ : b ∈ o₁), ∀ a _ : a ∈ o₂, b < a }

instance (priority := 10) LE [LE α] : LE (WithTop α) :=
  { le := fun o₁ o₂ : Option α => ∀ a _ : a ∈ o₂, ∃ (b : _)(_ : b ∈ o₁), b ≤ a }

@[simp]
theorem some_lt_some [LT α] {a b : α} : @LT.lt (WithTop α) _ (some a) (some b) ↔ a < b :=
  by 
    simp [· < ·]

@[simp]
theorem some_le_some [LE α] {a b : α} : @LE.le (WithTop α) _ (some a) (some b) ↔ a ≤ b :=
  by 
    simp [· ≤ ·]

@[simp]
theorem le_none [LE α] {a : WithTop α} : @LE.le (WithTop α) _ a none :=
  by 
    simp [· ≤ ·]

@[simp]
theorem some_lt_none [LT α] (a : α) : @LT.lt (WithTop α) _ (some a) none :=
  by 
    simp [· < ·] <;> exists a <;> rfl

instance : CanLift (WithTop α) α :=
  { coe := coeₓ, cond := fun r => r ≠ ⊤,
    prf := fun x hx => ⟨Option.get$ Option.ne_none_iff_is_some.1 hx, Option.some_get _⟩ }

instance [Preorderₓ α] : Preorderₓ (WithTop α) :=
  { le := fun o₁ o₂ : Option α => ∀ a _ : a ∈ o₂, ∃ (b : _)(_ : b ∈ o₁), b ≤ a, lt := · < ·,
    lt_iff_le_not_le :=
      by 
        intros  <;> cases a <;> cases b <;> simp [lt_iff_le_not_leₓ] <;> simp [· < ·, · ≤ ·],
    le_refl := fun o a ha => ⟨a, ha, le_reflₓ _⟩,
    le_trans :=
      fun o₁ o₂ o₃ h₁ h₂ c hc =>
        let ⟨b, hb, bc⟩ := h₂ c hc 
        let ⟨a, ha, ab⟩ := h₁ b hb
        ⟨a, ha, le_transₓ ab bc⟩ }

instance PartialOrderₓ [PartialOrderₓ α] : PartialOrderₓ (WithTop α) :=
  { WithTop.preorder with
    le_antisymm :=
      fun o₁ o₂ h₁ h₂ =>
        by 
          cases' o₂ with b
          ·
            cases' o₁ with a
            ·
              rfl 
            rcases h₂ a rfl with ⟨_, ⟨⟩, _⟩
          ·
            rcases h₁ b rfl with ⟨a, ⟨⟩, h₁'⟩
            rcases h₂ a rfl with ⟨_, ⟨⟩, h₂'⟩
            rw [le_antisymmₓ h₁' h₂'] }

instance OrderTop [LE α] : OrderTop (WithTop α) :=
  { WithTop.hasTop with le_top := fun a a' h => Option.noConfusion h }

@[simp, normCast]
theorem coe_le_coe [LE α] {a b : α} : (a : WithTop α) ≤ b ↔ a ≤ b :=
  ⟨fun h =>
      by 
        rcases h b rfl with ⟨_, ⟨⟩, h⟩ <;> exact h,
    fun h a' e => Option.some_inj.1 e ▸ ⟨a, rfl, h⟩⟩

theorem le_coe [LE α] {a b : α} : ∀ {o : Option α}, a ∈ o → (@LE.le (WithTop α) _ o b ↔ a ≤ b)
| _, rfl => coe_le_coe

theorem le_coe_iff [PartialOrderₓ α] {b : α} : ∀ {x : WithTop α}, x ≤ b ↔ ∃ a : α, x = a ∧ a ≤ b
| some a =>
  by 
    simp [some_eq_coe, coe_eq_coe]
| none =>
  by 
    simp [none_eq_top]

theorem coe_le_iff [PartialOrderₓ α] {a : α} : ∀ {x : WithTop α}, «expr↑ » a ≤ x ↔ ∀ b : α, x = «expr↑ » b → a ≤ b
| some b =>
  by 
    simp [some_eq_coe, coe_eq_coe]
| none =>
  by 
    simp [none_eq_top]

theorem lt_iff_exists_coe [PartialOrderₓ α] : ∀ {a b : WithTop α}, a < b ↔ ∃ p : α, a = p ∧ «expr↑ » p < b
| some a, b =>
  by 
    simp [some_eq_coe, coe_eq_coe]
| none, b =>
  by 
    simp [none_eq_top]

@[normCast]
theorem coe_lt_coe [LT α] {a b : α} : (a : WithTop α) < b ↔ a < b :=
  some_lt_some

theorem coe_lt_top [LT α] (a : α) : (a : WithTop α) < ⊤ :=
  some_lt_none a

theorem coe_lt_iff [Preorderₓ α] {a : α} : ∀ {x : WithTop α}, «expr↑ » a < x ↔ ∀ b : α, x = «expr↑ » b → a < b
| some b =>
  by 
    simp [some_eq_coe, coe_eq_coe, coe_lt_coe]
| none =>
  by 
    simp [none_eq_top, coe_lt_top]

theorem not_top_le_coe [Preorderₓ α] (a : α) : ¬(⊤ : WithTop α) ≤ «expr↑ » a :=
  fun h => (lt_irreflₓ ⊤ (lt_of_le_of_ltₓ h (coe_lt_top a))).elim

instance decidable_le [LE α] [@DecidableRel α (· ≤ ·)] : @DecidableRel (WithTop α) (· ≤ ·) :=
  fun x y => @WithBot.decidableLe (OrderDual α) _ _ y x

instance decidable_lt [LT α] [@DecidableRel α (· < ·)] : @DecidableRel (WithTop α) (· < ·) :=
  fun x y => @WithBot.decidableLt (OrderDual α) _ _ y x

instance [PartialOrderₓ α] [IsTotal α (· ≤ ·)] : IsTotal (WithTop α) (· ≤ ·) :=
  { Total :=
      fun a b =>
        match a, b with 
        | none, _ => Or.inr le_top
        | _, none => Or.inl le_top
        | some x, some y =>
          by 
            simp only [some_le_some, total_of] }

instance SemilatticeInf [SemilatticeInf α] : SemilatticeInf (WithTop α) :=
  { WithTop.partialOrder with inf := Option.liftOrGet (·⊓·),
    inf_le_left :=
      fun o₁ o₂ a ha =>
        by 
          cases ha <;> cases o₂ <;> simp [Option.liftOrGet],
    inf_le_right :=
      fun o₁ o₂ a ha =>
        by 
          cases ha <;> cases o₁ <;> simp [Option.liftOrGet],
    le_inf :=
      fun o₁ o₂ o₃ h₁ h₂ a ha =>
        by 
          cases' o₂ with b <;> cases' o₃ with c <;> cases ha
          ·
            exact h₂ a rfl
          ·
            exact h₁ a rfl
          ·
            rcases h₁ b rfl with ⟨d, ⟨⟩, h₁'⟩
            simp  at h₂ 
            exact ⟨d, rfl, le_inf h₁' h₂⟩ }

theorem coe_inf [SemilatticeInf α] (a b : α) : ((a⊓b : α) : WithTop α) = a⊓b :=
  rfl

instance SemilatticeSup [SemilatticeSup α] : SemilatticeSup (WithTop α) :=
  { WithTop.partialOrder with sup := fun o₁ o₂ => o₁.bind fun a => o₂.map fun b => a⊔b,
    le_sup_left :=
      fun o₁ o₂ a ha =>
        by 
          simp  at ha 
          rcases ha with ⟨b, rfl, c, rfl, rfl⟩
          exact ⟨_, rfl, le_sup_left⟩,
    le_sup_right :=
      fun o₁ o₂ a ha =>
        by 
          simp  at ha 
          rcases ha with ⟨b, rfl, c, rfl, rfl⟩
          exact ⟨_, rfl, le_sup_right⟩,
    sup_le :=
      fun o₁ o₂ o₃ h₁ h₂ a ha =>
        by 
          cases ha 
          rcases h₁ a rfl with ⟨b, ⟨⟩, ab⟩
          rcases h₂ a rfl with ⟨c, ⟨⟩, ac⟩
          exact ⟨_, rfl, sup_le ab ac⟩ }

theorem coe_sup [SemilatticeSup α] (a b : α) : ((a⊔b : α) : WithTop α) = a⊔b :=
  rfl

instance Lattice [Lattice α] : Lattice (WithTop α) :=
  { WithTop.semilatticeSup, WithTop.semilatticeInf with  }

instance LinearOrderₓ [LinearOrderₓ α] : LinearOrderₓ (WithTop α) :=
  Lattice.toLinearOrder _$
    fun o₁ o₂ =>
      by 
        cases' o₁ with a
        ·
          exact Or.inr le_top 
        cases' o₂ with b
        ·
          exact Or.inl le_top 
        simp [le_totalₓ]

@[simp, normCast]
theorem coe_min [LinearOrderₓ α] (x y : α) : ((min x y : α) : WithTop α) = min x y :=
  rfl

@[simp, normCast]
theorem coe_max [LinearOrderₓ α] (x y : α) : ((max x y : α) : WithTop α) = max x y :=
  rfl

instance OrderBot [LE α] [OrderBot α] : OrderBot (WithTop α) :=
  { bot := some ⊥,
    bot_le :=
      fun o a ha =>
        by 
          cases ha <;> exact ⟨_, rfl, bot_le⟩ }

instance BoundedOrder [LE α] [OrderBot α] : BoundedOrder (WithTop α) :=
  { WithTop.orderTop, WithTop.orderBot with  }

theorem well_founded_lt {α : Type _} [PartialOrderₓ α] (h : WellFounded (· < · : α → α → Prop)) :
  WellFounded (· < · : WithTop α → WithTop α → Prop) :=
  have acc_some : ∀ a : α, Acc (· < · : WithTop α → WithTop α → Prop) (some a) :=
    fun a =>
      Acc.intro _
        (WellFounded.induction h a
          (show
            ∀ b,
              (∀ c, c < b → ∀ d : WithTop α, d < some c → Acc (· < ·) d) →
                ∀ y : WithTop α, y < some b → Acc (· < ·) y from
            fun b ih c =>
              Option.recOn c (fun hc => (not_lt_of_geₓ le_top hc).elim)
                fun c hc => Acc.intro _ (ih _ (some_lt_some.1 hc))))
  ⟨fun a =>
      Option.recOn a (Acc.intro _ fun y => Option.recOn y (fun h => (lt_irreflₓ _ h).elim) fun _ _ => acc_some _)
        acc_some⟩

instance DenselyOrdered [PartialOrderₓ α] [DenselyOrdered α] [NoTopOrder α] : DenselyOrdered (WithTop α) :=
  ⟨fun a b =>
      match a, b with 
      | none, a => fun h : ⊤ < a => (not_top_lt h).elim
      | some a, none =>
        fun h =>
          let ⟨b, hb⟩ := no_top a
          ⟨b, coe_lt_coe.2 hb, coe_lt_top b⟩
      | some a, some b =>
        fun h =>
          let ⟨a, ha₁, ha₂⟩ := exists_between (coe_lt_coe.1 h)
          ⟨a, coe_lt_coe.2 ha₁, coe_lt_coe.2 ha₂⟩⟩

theorem lt_iff_exists_coe_btwn [PartialOrderₓ α] [DenselyOrdered α] [NoTopOrder α] {a b : WithTop α} :
  a < b ↔ ∃ x : α, a < «expr↑ » x ∧ «expr↑ » x < b :=
  ⟨fun h =>
      let ⟨y, hy⟩ := exists_between h 
      let ⟨x, hx⟩ := lt_iff_exists_coe.1 hy.2
      ⟨x, hx.1 ▸ hy⟩,
    fun ⟨x, hx⟩ => lt_transₓ hx.1 hx.2⟩

instance {α : Type _} [Preorderₓ α] [NoBotOrder α] [Nonempty α] : NoBotOrder (WithTop α) :=
  ⟨by 
      apply WithTop.recTopCoe
      ·
        apply ‹Nonempty α›.elim 
        exact fun a => ⟨a, WithTop.coe_lt_top a⟩
      ·
        intro a 
        obtain ⟨b, ha⟩ := no_bot a 
        exact ⟨b, with_top.coe_lt_coe.mpr ha⟩⟩

end WithTop

/-! ### Subtype, order dual, product lattices -/


namespace Subtype

/-- A subtype remains a `⊥`-order if the property holds at `⊥`.
See note [reducible non-instances]. -/
@[reducible]
protected def OrderBot [Preorderₓ α] [OrderBot α] {P : α → Prop} (Pbot : P ⊥) : OrderBot { x : α // P x } :=
  { bot := ⟨⊥, Pbot⟩, bot_le := fun _ => bot_le }

/-- A subtype remains a `⊤`-order if the property holds at `⊤`.
See note [reducible non-instances]. -/
@[reducible]
protected def OrderTop [Preorderₓ α] [OrderTop α] {P : α → Prop} (Ptop : P ⊤) : OrderTop { x : α // P x } :=
  { top := ⟨⊤, Ptop⟩, le_top := fun _ => le_top }

end Subtype

namespace OrderDual

variable (α)

instance [HasBot α] : HasTop (OrderDual α) :=
  ⟨(⊥ : α)⟩

instance [HasTop α] : HasBot (OrderDual α) :=
  ⟨(⊤ : α)⟩

instance [LE α] [OrderBot α] : OrderTop (OrderDual α) :=
  { OrderDual.hasTop α with le_top := @bot_le α _ _ }

instance [LE α] [OrderTop α] : OrderBot (OrderDual α) :=
  { OrderDual.hasBot α with bot_le := @le_top α _ _ }

instance [LE α] [BoundedOrder α] : BoundedOrder (OrderDual α) :=
  { OrderDual.orderTop α, OrderDual.orderBot α with  }

end OrderDual

namespace Prod

variable (α β)

instance [HasTop α] [HasTop β] : HasTop (α × β) :=
  ⟨⟨⊤, ⊤⟩⟩

instance [HasBot α] [HasBot β] : HasBot (α × β) :=
  ⟨⟨⊥, ⊥⟩⟩

instance [LE α] [LE β] [OrderTop α] [OrderTop β] : OrderTop (α × β) :=
  { Prod.hasTop α β with le_top := fun a => ⟨le_top, le_top⟩ }

instance [LE α] [LE β] [OrderBot α] [OrderBot β] : OrderBot (α × β) :=
  { Prod.hasBot α β with bot_le := fun a => ⟨bot_le, bot_le⟩ }

instance [LE α] [LE β] [BoundedOrder α] [BoundedOrder β] : BoundedOrder (α × β) :=
  { Prod.orderTop α β, Prod.orderBot α β with  }

end Prod

/-! ### Disjointness and complements -/


section Disjoint

section SemilatticeInfBot

variable [SemilatticeInf α] [OrderBot α]

/-- Two elements of a lattice are disjoint if their inf is the bottom element.
  (This generalizes disjoint sets, viewed as members of the subset lattice.) -/
def Disjoint (a b : α) : Prop :=
  a⊓b ≤ ⊥

theorem Disjoint.eq_bot {a b : α} (h : Disjoint a b) : a⊓b = ⊥ :=
  eq_bot_iff.2 h

theorem disjoint_iff {a b : α} : Disjoint a b ↔ a⊓b = ⊥ :=
  eq_bot_iff.symm

theorem Disjoint.comm {a b : α} : Disjoint a b ↔ Disjoint b a :=
  by 
    rw [Disjoint, Disjoint, inf_comm]

@[symm]
theorem Disjoint.symm ⦃a b : α⦄ : Disjoint a b → Disjoint b a :=
  Disjoint.comm.1

theorem symmetric_disjoint : Symmetric (Disjoint : α → α → Prop) :=
  Disjoint.symm

@[simp]
theorem disjoint_bot_left {a : α} : Disjoint ⊥ a :=
  inf_le_left

@[simp]
theorem disjoint_bot_right {a : α} : Disjoint a ⊥ :=
  inf_le_right

theorem Disjoint.mono {a b c d : α} (h₁ : a ≤ b) (h₂ : c ≤ d) : Disjoint b d → Disjoint a c :=
  le_transₓ (inf_le_inf h₁ h₂)

theorem Disjoint.mono_left {a b c : α} (h : a ≤ b) : Disjoint b c → Disjoint a c :=
  Disjoint.mono h (le_reflₓ _)

theorem Disjoint.mono_right {a b c : α} (h : b ≤ c) : Disjoint a c → Disjoint a b :=
  Disjoint.mono (le_reflₓ _) h

@[simp]
theorem disjoint_self {a : α} : Disjoint a a ↔ a = ⊥ :=
  by 
    simp [Disjoint]

theorem Disjoint.ne {a b : α} (ha : a ≠ ⊥) (hab : Disjoint a b) : a ≠ b :=
  by 
    intro h 
    rw [←h, disjoint_self] at hab 
    exact ha hab

theorem Disjoint.eq_bot_of_le {a b : α} (hab : Disjoint a b) (h : a ≤ b) : a = ⊥ :=
  eq_bot_iff.2
    (by 
      rwa [←inf_eq_left.2 h])

theorem Disjoint.of_disjoint_inf_of_le {a b c : α} (h : Disjoint (a⊓b) c) (hle : a ≤ c) : Disjoint a b :=
  by 
    rw [disjoint_iff, h.eq_bot_of_le (inf_le_left.trans hle)]

theorem Disjoint.of_disjoint_inf_of_le' {a b c : α} (h : Disjoint (a⊓b) c) (hle : b ≤ c) : Disjoint a b :=
  by 
    rw [disjoint_iff, h.eq_bot_of_le (inf_le_right.trans hle)]

end SemilatticeInfBot

section BoundedOrder

variable [Lattice α] [BoundedOrder α] {a : α}

@[simp]
theorem disjoint_top : Disjoint a ⊤ ↔ a = ⊥ :=
  by 
    simp [disjoint_iff]

@[simp]
theorem top_disjoint : Disjoint ⊤ a ↔ a = ⊥ :=
  by 
    simp [disjoint_iff]

theorem eq_bot_of_disjoint_absorbs {a b : α} (w : Disjoint a b) (h : a⊔b = a) : b = ⊥ :=
  by 
    rw [disjoint_iff] at w 
    rw [←w, right_eq_inf]
    rwa [sup_eq_left] at h

end BoundedOrder

section LinearOrderₓ

variable [LinearOrderₓ α]

theorem min_top_left [OrderTop α] (a : α) : min (⊤ : α) a = a :=
  min_eq_rightₓ le_top

theorem min_top_right [OrderTop α] (a : α) : min a ⊤ = a :=
  min_eq_leftₓ le_top

theorem max_bot_left [OrderBot α] (a : α) : max (⊥ : α) a = a :=
  max_eq_rightₓ bot_le

theorem max_bot_right [OrderBot α] (a : α) : max a ⊥ = a :=
  max_eq_leftₓ bot_le

end LinearOrderₓ

section DistribLatticeBot

variable [DistribLattice α] [OrderBot α] {a b c : α}

@[simp]
theorem disjoint_sup_left : Disjoint (a⊔b) c ↔ Disjoint a c ∧ Disjoint b c :=
  by 
    simp only [disjoint_iff, inf_sup_right, sup_eq_bot_iff]

@[simp]
theorem disjoint_sup_right : Disjoint a (b⊔c) ↔ Disjoint a b ∧ Disjoint a c :=
  by 
    simp only [disjoint_iff, inf_sup_left, sup_eq_bot_iff]

theorem Disjoint.sup_left (ha : Disjoint a c) (hb : Disjoint b c) : Disjoint (a⊔b) c :=
  disjoint_sup_left.2 ⟨ha, hb⟩

theorem Disjoint.sup_right (hb : Disjoint a b) (hc : Disjoint a c) : Disjoint a (b⊔c) :=
  disjoint_sup_right.2 ⟨hb, hc⟩

theorem Disjoint.left_le_of_le_sup_right {a b c : α} (h : a ≤ b⊔c) (hd : Disjoint a c) : a ≤ b :=
  (fun x => le_of_inf_le_sup_le x (sup_le h le_sup_right)) ((disjoint_iff.mp hd).symm ▸ bot_le)

theorem Disjoint.left_le_of_le_sup_left {a b c : α} (h : a ≤ c⊔b) (hd : Disjoint a c) : a ≤ b :=
  @le_of_inf_le_sup_le _ _ a b c ((disjoint_iff.mp hd).symm ▸ bot_le) (@sup_comm _ _ c b ▸ sup_le h le_sup_left)

end DistribLatticeBot

section SemilatticeInfBot

variable [SemilatticeInf α] [OrderBot α] {a b : α} (c : α)

theorem Disjoint.inf_left (h : Disjoint a b) : Disjoint (a⊓c) b :=
  h.mono_left inf_le_left

theorem Disjoint.inf_left' (h : Disjoint a b) : Disjoint (c⊓a) b :=
  h.mono_left inf_le_right

theorem Disjoint.inf_right (h : Disjoint a b) : Disjoint a (b⊓c) :=
  h.mono_right inf_le_left

theorem Disjoint.inf_right' (h : Disjoint a b) : Disjoint a (c⊓b) :=
  h.mono_right inf_le_right

end SemilatticeInfBot

end Disjoint

section IsCompl

/-- Two elements `x` and `y` are complements of each other if `x ⊔ y = ⊤` and `x ⊓ y = ⊥`. -/
structure IsCompl [Lattice α] [BoundedOrder α] (x y : α) : Prop where 
  inf_le_bot : x⊓y ≤ ⊥
  top_le_sup : ⊤ ≤ x⊔y

namespace IsCompl

section BoundedOrder

variable [Lattice α] [BoundedOrder α] {x y z : α}

protected theorem Disjoint (h : IsCompl x y) : Disjoint x y :=
  h.1

@[symm]
protected theorem symm (h : IsCompl x y) : IsCompl y x :=
  ⟨by 
      rw [inf_comm]
      exact h.1,
    by 
      rw [sup_comm]
      exact h.2⟩

theorem of_eq (h₁ : x⊓y = ⊥) (h₂ : x⊔y = ⊤) : IsCompl x y :=
  ⟨le_of_eqₓ h₁, le_of_eqₓ h₂.symm⟩

theorem inf_eq_bot (h : IsCompl x y) : x⊓y = ⊥ :=
  h.disjoint.eq_bot

theorem sup_eq_top (h : IsCompl x y) : x⊔y = ⊤ :=
  top_unique h.top_le_sup

open order_dual(toDual)

theorem to_order_dual (h : IsCompl x y) : IsCompl (to_dual x) (to_dual y) :=
  ⟨h.2, h.1⟩

end BoundedOrder

variable [DistribLattice α] [BoundedOrder α] {a b x y z : α}

theorem inf_left_le_of_le_sup_right (h : IsCompl x y) (hle : a ≤ b⊔y) : a⊓x ≤ b :=
  calc a⊓x ≤ (b⊔y)⊓x := inf_le_inf hle le_rfl 
    _ = b⊓x⊔y⊓x := inf_sup_right 
    _ = b⊓x :=
    by 
      rw [h.symm.inf_eq_bot, sup_bot_eq]
    _ ≤ b := inf_le_left
    

theorem le_sup_right_iff_inf_left_le {a b} (h : IsCompl x y) : a ≤ b⊔y ↔ a⊓x ≤ b :=
  ⟨h.inf_left_le_of_le_sup_right, h.symm.to_order_dual.inf_left_le_of_le_sup_right⟩

theorem inf_left_eq_bot_iff (h : IsCompl y z) : x⊓y = ⊥ ↔ x ≤ z :=
  by 
    rw [←le_bot_iff, ←h.le_sup_right_iff_inf_left_le, bot_sup_eq]

theorem inf_right_eq_bot_iff (h : IsCompl y z) : x⊓z = ⊥ ↔ x ≤ y :=
  h.symm.inf_left_eq_bot_iff

theorem disjoint_left_iff (h : IsCompl y z) : Disjoint x y ↔ x ≤ z :=
  by 
    rw [disjoint_iff]
    exact h.inf_left_eq_bot_iff

theorem disjoint_right_iff (h : IsCompl y z) : Disjoint x z ↔ x ≤ y :=
  h.symm.disjoint_left_iff

theorem le_left_iff (h : IsCompl x y) : z ≤ x ↔ Disjoint z y :=
  h.disjoint_right_iff.symm

theorem le_right_iff (h : IsCompl x y) : z ≤ y ↔ Disjoint z x :=
  h.symm.le_left_iff

theorem left_le_iff (h : IsCompl x y) : x ≤ z ↔ ⊤ ≤ z⊔y :=
  h.to_order_dual.le_left_iff

theorem right_le_iff (h : IsCompl x y) : y ≤ z ↔ ⊤ ≤ z⊔x :=
  h.symm.left_le_iff

protected theorem Antitone {x' y'} (h : IsCompl x y) (h' : IsCompl x' y') (hx : x ≤ x') : y' ≤ y :=
  h'.right_le_iff.2$ le_transₓ h.symm.top_le_sup (sup_le_sup_left hx _)

theorem right_unique (hxy : IsCompl x y) (hxz : IsCompl x z) : y = z :=
  le_antisymmₓ (hxz.antitone hxy$ le_reflₓ x) (hxy.antitone hxz$ le_reflₓ x)

theorem left_unique (hxz : IsCompl x z) (hyz : IsCompl y z) : x = y :=
  hxz.symm.right_unique hyz.symm

theorem sup_inf {x' y'} (h : IsCompl x y) (h' : IsCompl x' y') : IsCompl (x⊔x') (y⊓y') :=
  of_eq
    (by 
      rw [inf_sup_right, ←inf_assoc, h.inf_eq_bot, bot_inf_eq, bot_sup_eq, inf_left_comm, h'.inf_eq_bot, inf_bot_eq])
    (by 
      rw [sup_inf_left, @sup_comm _ _ x, sup_assoc, h.sup_eq_top, sup_top_eq, top_inf_eq, sup_assoc, sup_left_comm,
        h'.sup_eq_top, sup_top_eq])

theorem inf_sup {x' y'} (h : IsCompl x y) (h' : IsCompl x' y') : IsCompl (x⊓x') (y⊔y') :=
  (h.symm.sup_inf h'.symm).symm

end IsCompl

theorem is_compl_bot_top [Lattice α] [BoundedOrder α] : IsCompl (⊥ : α) ⊤ :=
  IsCompl.of_eq bot_inf_eq sup_top_eq

theorem is_compl_top_bot [Lattice α] [BoundedOrder α] : IsCompl (⊤ : α) ⊥ :=
  IsCompl.of_eq inf_bot_eq top_sup_eq

section 

variable [Lattice α] [BoundedOrder α] {x : α}

theorem eq_top_of_is_compl_bot (h : IsCompl x ⊥) : x = ⊤ :=
  sup_bot_eq.symm.trans h.sup_eq_top

theorem eq_top_of_bot_is_compl (h : IsCompl ⊥ x) : x = ⊤ :=
  eq_top_of_is_compl_bot h.symm

theorem eq_bot_of_is_compl_top (h : IsCompl x ⊤) : x = ⊥ :=
  eq_top_of_is_compl_bot h.to_order_dual

theorem eq_bot_of_top_is_compl (h : IsCompl ⊤ x) : x = ⊥ :=
  eq_top_of_bot_is_compl h.to_order_dual

end 

/-- A complemented bounded lattice is one where every element has a (not necessarily unique)
complement. -/
class IsComplemented (α) [Lattice α] [BoundedOrder α] : Prop where 
  exists_is_compl : ∀ a : α, ∃ b : α, IsCompl a b

export IsComplemented(exists_is_compl)

namespace IsComplemented

variable [Lattice α] [BoundedOrder α] [IsComplemented α]

instance : IsComplemented (OrderDual α) :=
  ⟨fun a =>
      let ⟨b, hb⟩ := exists_is_compl (show α from a)
      ⟨b, hb.to_order_dual⟩⟩

end IsComplemented

end IsCompl

section Nontrivial

variable [Lattice α] [BoundedOrder α] [Nontrivial α]

theorem bot_ne_top : (⊥ : α) ≠ ⊤ :=
  fun H => not_nontrivial_iff_subsingleton.mpr (subsingleton_of_bot_eq_top H) ‹_›

theorem top_ne_bot : (⊤ : α) ≠ ⊥ :=
  Ne.symm bot_ne_top

end Nontrivial

namespace Bool

instance : BoundedOrder Bool :=
  { top := tt, le_top := fun x => le_tt, bot := ff, bot_le := fun x => ff_le }

end Bool

section Bool

@[simp]
theorem top_eq_tt : ⊤ = tt :=
  rfl

@[simp]
theorem bot_eq_ff : ⊥ = ff :=
  rfl

end Bool

