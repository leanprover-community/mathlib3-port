import Mathbin.Data.Prod 
import Mathbin.Data.Subtype

/-!
# Basic definitions about `≤` and `<`

This file proves basic results about orders, provides extensive dot notation, defines useful order
classes and allows to transfer order instances.

## Type synonyms

* `order_dual α` : A type synonym reversing the meaning of all inequalities.
* `as_linear_order α`: A type synonym to promote `partial_order α` to `linear_order α` using
  `is_total α (≤)`.

### Transfering orders

- `order.preimage`, `preorder.lift`: Transfers a (pre)order on `β` to an order on `α`
  using a function `f : α → β`.
- `partial_order.lift`, `linear_order.lift`: Transfers a partial (resp., linear) order on `β` to a
  partial (resp., linear) order on `α` using an injective function `f`.

### Extra classes

- `no_top_order`, `no_bot_order`: An order without a maximal/minimal element.
- `densely_ordered`: An order with no gap, i.e. for any two elements `a < b` there exists `c` such
  that `a < c < b`.

## Notes

`≤` and `<` are highly favored over `≥` and `>` in mathlib. The reason is that we can formulate all
lemmas using `≤`/`<`, and `rw` has trouble unifying `≤` and `≥`. Hence choosing one direction spares
us useless duplication. This is enforced by a linter. See Note [nolint_ge] for more infos.

Dot notation is particularly useful on `≤` (`has_le.le`) and `<` (`has_lt.lt`). To that end, we
provide many aliases to dot notation-less lemmas. For example, `le_trans` is aliased with
`has_le.le.trans` and can be used to construct `hab.trans hbc : a ≤ c` when `hab : a ≤ b`,
`hbc : b ≤ c`, `lt_of_le_of_lt` is aliased as `has_le.le.trans_lt` and can be used to construct
`hab.trans hbc : a < c` when `hab : a ≤ b`, `hbc : b < c`.

## TODO

- expand module docs
- automatic construction of dual definitions / theorems

## See also

- `algebra.order.basic` for basic lemmas about orders, and projection notation for orders

## Tags

preorder, order, partial order, poset, linear order, chain
-/


open Function

universe u v w

variable{α : Type u}{β : Type v}{γ : Type w}{r : α → α → Prop}

attribute [simp] le_reflₓ

attribute [ext] LE

alias le_transₓ ← LE.le.trans

alias lt_of_le_of_ltₓ ← LE.le.trans_lt

alias le_antisymmₓ ← LE.le.antisymm

alias lt_of_le_of_neₓ ← LE.le.lt_of_ne

alias lt_of_le_not_leₓ ← LE.le.lt_of_not_le

alias lt_or_eq_of_leₓ ← LE.le.lt_or_eq

alias Decidable.lt_or_eq_of_leₓ ← LE.le.lt_or_eq_dec

alias le_of_ltₓ ← LT.lt.le

alias lt_transₓ ← LT.lt.trans

alias lt_of_lt_of_leₓ ← LT.lt.trans_le

alias ne_of_ltₓ ← LT.lt.ne

alias lt_asymmₓ ← LT.lt.asymm LT.lt.not_lt

alias le_of_eqₓ ← Eq.le

attribute [nolint decidable_classical] LE.le.lt_or_eq_dec

/-- A version of `le_refl` where the argument is implicit -/
theorem le_rfl [Preorderₓ α] {x : α} : x ≤ x :=
  le_reflₓ x

@[simp]
theorem lt_self_iff_false [Preorderₓ α] (x : α) : x < x ↔ False :=
  ⟨lt_irreflₓ x, False.elim⟩

namespace Eq

/-- If `x = y` then `y ≤ x`. Note: this lemma uses `y ≤ x` instead of `x ≥ y`, because `le` is used
almost exclusively in mathlib. -/
protected theorem Ge [Preorderₓ α] {x y : α} (h : x = y) : y ≤ x :=
  h.symm.le

theorem trans_le [Preorderₓ α] {x y z : α} (h1 : x = y) (h2 : y ≤ z) : x ≤ z :=
  h1.le.trans h2

theorem not_ltₓ [PartialOrderₓ α] {x y : α} (h : x = y) : ¬x < y :=
  fun h' => h'.ne h

theorem not_gt [PartialOrderₓ α] {x y : α} (h : x = y) : ¬y < x :=
  h.symm.not_lt

end Eq

namespace LE.le

@[nolint ge_or_gt]
protected theorem Ge [LE α] {x y : α} (h : x ≤ y) : y ≥ x :=
  h

theorem trans_eq [Preorderₓ α] {x y z : α} (h1 : x ≤ y) (h2 : y = z) : x ≤ z :=
  h1.trans h2.le

theorem lt_iff_ne [PartialOrderₓ α] {x y : α} (h : x ≤ y) : x < y ↔ x ≠ y :=
  ⟨fun h => h.ne, h.lt_of_ne⟩

theorem le_iff_eq [PartialOrderₓ α] {x y : α} (h : x ≤ y) : y ≤ x ↔ y = x :=
  ⟨fun h' => h'.antisymm h, Eq.le⟩

theorem lt_or_leₓ [LinearOrderₓ α] {a b : α} (h : a ≤ b) (c : α) : a < c ∨ c ≤ b :=
  (lt_or_geₓ a c).imp id$ fun hc => le_transₓ hc h

theorem le_or_ltₓ [LinearOrderₓ α] {a b : α} (h : a ≤ b) (c : α) : a ≤ c ∨ c < b :=
  (le_or_gtₓ a c).imp id$ fun hc => lt_of_lt_of_leₓ hc h

theorem le_or_le [LinearOrderₓ α] {a b : α} (h : a ≤ b) (c : α) : a ≤ c ∨ c ≤ b :=
  (h.le_or_lt c).elim Or.inl fun h => Or.inr$ le_of_ltₓ h

end LE.le

namespace LT.lt

@[nolint ge_or_gt]
protected theorem Gt [LT α] {x y : α} (h : x < y) : y > x :=
  h

protected theorem False [Preorderₓ α] {x : α} : x < x → False :=
  lt_irreflₓ x

theorem ne' [Preorderₓ α] {x y : α} (h : x < y) : y ≠ x :=
  h.ne.symm

theorem lt_or_lt [LinearOrderₓ α] {x y : α} (h : x < y) (z : α) : x < z ∨ z < y :=
  (lt_or_geₓ z y).elim Or.inr fun hz => Or.inl$ h.trans_le hz

end LT.lt

@[nolint ge_or_gt]
protected theorem Ge.le [LE α] {x y : α} (h : x ≥ y) : y ≤ x :=
  h

@[nolint ge_or_gt]
protected theorem Gt.lt [LT α] {x y : α} (h : x > y) : y < x :=
  h

@[nolint ge_or_gt]
theorem ge_of_eq [Preorderₓ α] {a b : α} (h : a = b) : a ≥ b :=
  h.ge

@[simp, nolint ge_or_gt]
theorem ge_iff_le [Preorderₓ α] {a b : α} : a ≥ b ↔ b ≤ a :=
  Iff.rfl

@[simp, nolint ge_or_gt]
theorem gt_iff_lt [Preorderₓ α] {a b : α} : a > b ↔ b < a :=
  Iff.rfl

theorem not_le_of_lt [Preorderₓ α] {a b : α} (h : a < b) : ¬b ≤ a :=
  (le_not_le_of_ltₓ h).right

alias not_le_of_lt ← LT.lt.not_le

theorem not_lt_of_le [Preorderₓ α] {a b : α} (h : a ≤ b) : ¬b < a :=
  fun hba => hba.not_le h

alias not_lt_of_le ← LE.le.not_lt

theorem ne_of_not_le [Preorderₓ α] {a b : α} (h : ¬a ≤ b) : a ≠ b :=
  fun hab => h (le_of_eqₓ hab)

protected theorem Decidable.le_iff_eq_or_lt [PartialOrderₓ α] [@DecidableRel α (· ≤ ·)] {a b : α} :
  a ≤ b ↔ a = b ∨ a < b :=
  Decidable.le_iff_lt_or_eqₓ.trans Or.comm

theorem le_iff_eq_or_lt [PartialOrderₓ α] {a b : α} : a ≤ b ↔ a = b ∨ a < b :=
  le_iff_lt_or_eqₓ.trans Or.comm

theorem lt_iff_le_and_ne [PartialOrderₓ α] {a b : α} : a < b ↔ a ≤ b ∧ a ≠ b :=
  ⟨fun h => ⟨le_of_ltₓ h, ne_of_ltₓ h⟩, fun ⟨h1, h2⟩ => h1.lt_of_ne h2⟩

protected theorem Decidable.eq_iff_le_not_lt [PartialOrderₓ α] [@DecidableRel α (· ≤ ·)] {a b : α} :
  a = b ↔ a ≤ b ∧ ¬a < b :=
  ⟨fun h => ⟨h.le, h ▸ lt_irreflₓ _⟩,
    fun ⟨h₁, h₂⟩ => h₁.antisymm$ Decidable.by_contradiction$ fun h₃ => h₂ (h₁.lt_of_not_le h₃)⟩

-- error in Order.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem eq_iff_le_not_lt
[partial_order α]
{a b : α} : «expr ↔ »(«expr = »(a, b), «expr ∧ »(«expr ≤ »(a, b), «expr¬ »(«expr < »(a, b)))) :=
by haveI [] [] [":=", expr classical.dec]; exact [expr decidable.eq_iff_le_not_lt]

theorem eq_or_lt_of_le [PartialOrderₓ α] {a b : α} (h : a ≤ b) : a = b ∨ a < b :=
  h.lt_or_eq.symm

alias Decidable.eq_or_lt_of_leₓ ← LE.le.eq_or_lt_dec

alias eq_or_lt_of_le ← LE.le.eq_or_lt

attribute [nolint decidable_classical] LE.le.eq_or_lt_dec

theorem Ne.le_iff_lt [PartialOrderₓ α] {a b : α} (h : a ≠ b) : a ≤ b ↔ a < b :=
  ⟨fun h' => lt_of_le_of_neₓ h' h, fun h => h.le⟩

protected theorem Decidable.ne_iff_lt_iff_le [PartialOrderₓ α] [@DecidableRel α (· ≤ ·)] {a b : α} :
  (a ≠ b ↔ a < b) ↔ a ≤ b :=
  ⟨fun h => Decidable.byCases le_of_eqₓ (le_of_ltₓ ∘ h.mp), fun h => ⟨lt_of_le_of_neₓ h, ne_of_ltₓ⟩⟩

-- error in Order.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem ne_iff_lt_iff_le
[partial_order α]
{a b : α} : «expr ↔ »(«expr ↔ »(«expr ≠ »(a, b), «expr < »(a, b)), «expr ≤ »(a, b)) :=
by haveI [] [] [":=", expr classical.dec]; exact [expr decidable.ne_iff_lt_iff_le]

theorem lt_of_not_ge' [LinearOrderₓ α] {a b : α} (h : ¬b ≤ a) : a < b :=
  ((le_totalₓ _ _).resolve_right h).lt_of_not_le h

theorem lt_iff_not_ge' [LinearOrderₓ α] {x y : α} : x < y ↔ ¬y ≤ x :=
  ⟨not_le_of_gtₓ, lt_of_not_ge'⟩

theorem Ne.lt_or_lt [LinearOrderₓ α] {x y : α} (h : x ≠ y) : x < y ∨ y < x :=
  lt_or_gt_of_neₓ h

/-- A version of `ne_iff_lt_or_gt` with LHS and RHS reversed. -/
@[simp]
theorem lt_or_lt_iff_ne [LinearOrderₓ α] {x y : α} : x < y ∨ y < x ↔ x ≠ y :=
  ne_iff_lt_or_gtₓ.symm

theorem not_lt_iff_eq_or_lt [LinearOrderₓ α] {a b : α} : ¬a < b ↔ a = b ∨ b < a :=
  not_ltₓ.trans$ Decidable.le_iff_eq_or_lt.trans$ or_congr eq_comm Iff.rfl

theorem exists_ge_of_linear [LinearOrderₓ α] (a b : α) : ∃ c, a ≤ c ∧ b ≤ c :=
  match le_totalₓ a b with 
  | Or.inl h => ⟨_, h, le_rfl⟩
  | Or.inr h => ⟨_, le_rfl, h⟩

theorem lt_imp_lt_of_le_imp_le {β} [LinearOrderₓ α] [Preorderₓ β] {a b : α} {c d : β} (H : a ≤ b → c ≤ d) (h : d < c) :
  b < a :=
  lt_of_not_ge'$ fun h' => (H h').not_lt h

theorem le_imp_le_iff_lt_imp_lt {β} [LinearOrderₓ α] [LinearOrderₓ β] {a b : α} {c d : β} :
  a ≤ b → c ≤ d ↔ d < c → b < a :=
  ⟨lt_imp_lt_of_le_imp_le, le_imp_le_of_lt_imp_ltₓ⟩

theorem lt_iff_lt_of_le_iff_le' {β} [Preorderₓ α] [Preorderₓ β] {a b : α} {c d : β} (H : a ≤ b ↔ c ≤ d)
  (H' : b ≤ a ↔ d ≤ c) : b < a ↔ d < c :=
  lt_iff_le_not_leₓ.trans$ (and_congr H' (not_congr H)).trans lt_iff_le_not_leₓ.symm

theorem lt_iff_lt_of_le_iff_le {β} [LinearOrderₓ α] [LinearOrderₓ β] {a b : α} {c d : β} (H : a ≤ b ↔ c ≤ d) :
  b < a ↔ d < c :=
  not_leₓ.symm.trans$ (not_congr H).trans$ not_leₓ

theorem le_iff_le_iff_lt_iff_lt {β} [LinearOrderₓ α] [LinearOrderₓ β] {a b : α} {c d : β} :
  (a ≤ b ↔ c ≤ d) ↔ (b < a ↔ d < c) :=
  ⟨lt_iff_lt_of_le_iff_le, fun H => not_ltₓ.symm.trans$ (not_congr H).trans$ not_ltₓ⟩

theorem eq_of_forall_le_iff [PartialOrderₓ α] {a b : α} (H : ∀ c, c ≤ a ↔ c ≤ b) : a = b :=
  ((H _).1 le_rfl).antisymm ((H _).2 le_rfl)

theorem le_of_forall_le [Preorderₓ α] {a b : α} (H : ∀ c, c ≤ a → c ≤ b) : a ≤ b :=
  H _ le_rfl

theorem le_of_forall_le' [Preorderₓ α] {a b : α} (H : ∀ c, a ≤ c → b ≤ c) : b ≤ a :=
  H _ le_rfl

theorem le_of_forall_lt [LinearOrderₓ α] {a b : α} (H : ∀ c, c < a → c < b) : a ≤ b :=
  le_of_not_ltₓ$ fun h => lt_irreflₓ _ (H _ h)

theorem forall_lt_iff_le [LinearOrderₓ α] {a b : α} : (∀ ⦃c⦄, c < a → c < b) ↔ a ≤ b :=
  ⟨le_of_forall_lt, fun h c hca => lt_of_lt_of_leₓ hca h⟩

theorem le_of_forall_lt' [LinearOrderₓ α] {a b : α} (H : ∀ c, a < c → b < c) : b ≤ a :=
  le_of_not_ltₓ$ fun h => lt_irreflₓ _ (H _ h)

theorem forall_lt_iff_le' [LinearOrderₓ α] {a b : α} : (∀ ⦃c⦄, a < c → b < c) ↔ b ≤ a :=
  ⟨le_of_forall_lt', fun h c hac => lt_of_le_of_ltₓ h hac⟩

theorem eq_of_forall_ge_iff [PartialOrderₓ α] {a b : α} (H : ∀ c, a ≤ c ↔ b ≤ c) : a = b :=
  ((H _).2 le_rfl).antisymm ((H _).1 le_rfl)

/-- monotonicity of `≤` with respect to `→` -/
theorem le_implies_le_of_le_of_le {a b c d : α} [Preorderₓ α] (hca : c ≤ a) (hbd : b ≤ d) : a ≤ b → c ≤ d :=
  fun hab => (hca.trans hab).trans hbd

-- error in Order.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[ext #[]] theorem preorder.to_has_le_injective {α : Type*} : function.injective (@preorder.to_has_le α) :=
λ A B h, begin
  cases [expr A] [],
  cases [expr B] [],
  injection [expr h] ["with", ident h_le],
  have [] [":", expr «expr = »(A_lt, B_lt)] [],
  { funext [ident a, ident b],
    dsimp [] ["[", expr («expr ≤ »), "]"] [] ["at", ident A_lt_iff_le_not_le, ident B_lt_iff_le_not_le, ident h_le],
    simp [] [] [] ["[", expr A_lt_iff_le_not_le, ",", expr B_lt_iff_le_not_le, ",", expr h_le, "]"] [] [] },
  congr' [] []
end

@[ext]
theorem PartialOrderₓ.to_preorder_injective {α : Type _} : Function.Injective (@PartialOrderₓ.toPreorder α) :=
  fun A B h =>
    by 
      cases A 
      cases B 
      injection h 
      congr

@[ext]
theorem LinearOrderₓ.to_partial_order_injective {α : Type _} : Function.Injective (@LinearOrderₓ.toPartialOrder α) :=
  by 
    intro A B h 
    cases A 
    cases B 
    injection h 
    obtain rfl : A_le = B_le := ‹_›
    obtain rfl : A_lt = B_lt := ‹_›
    obtain rfl : A_decidable_le = B_decidable_le := Subsingleton.elimₓ _ _ 
    obtain rfl : A_max = B_max := A_max_def.trans B_max_def.symm 
    obtain rfl : A_min = B_min := A_min_def.trans B_min_def.symm 
    congr

-- error in Order.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem preorder.ext
{α}
{A B : preorder α}
(H : ∀
 x y : α, «expr ↔ »(by haveI [] [] [":=", expr A]; exact [expr «expr ≤ »(x, y)], «expr ≤ »(x, y))) : «expr = »(A, B) :=
by { ext [] [ident x, ident y] [],
  exact [expr H x y] }

-- error in Order.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem partial_order.ext
{α}
{A B : partial_order α}
(H : ∀
 x y : α, «expr ↔ »(by haveI [] [] [":=", expr A]; exact [expr «expr ≤ »(x, y)], «expr ≤ »(x, y))) : «expr = »(A, B) :=
by { ext [] [ident x, ident y] [],
  exact [expr H x y] }

-- error in Order.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem linear_order.ext
{α}
{A B : linear_order α}
(H : ∀
 x y : α, «expr ↔ »(by haveI [] [] [":=", expr A]; exact [expr «expr ≤ »(x, y)], «expr ≤ »(x, y))) : «expr = »(A, B) :=
by { ext [] [ident x, ident y] [],
  exact [expr H x y] }

/-- Given a relation `R` on `β` and a function `f : α → β`, the preimage relation on `α` is defined
by `x ≤ y ↔ f x ≤ f y`. It is the unique relation on `α` making `f` a `rel_embedding` (assuming `f`
is injective). -/
@[simp]
def Order.Preimage {α β} (f : α → β) (s : β → β → Prop) (x y : α) : Prop :=
  s (f x) (f y)

infixl:80 " ⁻¹'o " => Order.Preimage

/-- The preimage of a decidable order is decidable. -/
instance Order.Preimage.decidable {α β} (f : α → β) (s : β → β → Prop) [H : DecidableRel s] : DecidableRel (f ⁻¹'o s) :=
  fun x y => H _ _

/-! ### Order dual -/


/-- Type synonym to equip a type with the dual order: `≤` means `≥` and `<` means `>`. -/
def OrderDual (α : Type _) : Type _ :=
  α

namespace OrderDual

instance  (α : Type _) [h : Nonempty α] : Nonempty (OrderDual α) :=
  h

instance  (α : Type _) [h : Subsingleton α] : Subsingleton (OrderDual α) :=
  h

-- error in Order.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
instance (α : Type*) [has_le α] : has_le (order_dual α) := ⟨λ x y : α, «expr ≤ »(y, x)⟩

-- error in Order.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
instance (α : Type*) [has_lt α] : has_lt (order_dual α) := ⟨λ x y : α, «expr < »(y, x)⟩

instance  (α : Type _) [HasZero α] : HasZero (OrderDual α) :=
  ⟨(0 : α)⟩

theorem dual_le [LE α] {a b : α} : @LE.le (OrderDual α) _ a b ↔ @LE.le α _ b a :=
  Iff.rfl

theorem dual_lt [LT α] {a b : α} : @LT.lt (OrderDual α) _ a b ↔ @LT.lt α _ b a :=
  Iff.rfl

instance  (α : Type _) [Preorderₓ α] : Preorderₓ (OrderDual α) :=
  { OrderDual.hasLe α, OrderDual.hasLt α with le_refl := le_reflₓ, le_trans := fun a b c hab hbc => hbc.trans hab,
    lt_iff_le_not_le := fun _ _ => lt_iff_le_not_leₓ }

instance  (α : Type _) [PartialOrderₓ α] : PartialOrderₓ (OrderDual α) :=
  { OrderDual.preorder α with le_antisymm := fun a b hab hba => @le_antisymmₓ α _ a b hba hab }

-- error in Order.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
instance (α : Type*) [linear_order α] : linear_order (order_dual α) :=
{ le_total := λ a b : α, le_total b a,
  decidable_le := (infer_instance : decidable_rel (λ a b : α, «expr ≤ »(b, a))),
  decidable_lt := (infer_instance : decidable_rel (λ a b : α, «expr < »(b, a))),
  min := @max α _,
  max := @min α _,
  min_def := @linear_order.max_def α _,
  max_def := @linear_order.min_def α _,
  ..order_dual.partial_order α }

instance  : ∀ [Inhabited α], Inhabited (OrderDual α) :=
  id

theorem preorder.dual_dual (α : Type _) [H : Preorderₓ α] : OrderDual.preorder (OrderDual α) = H :=
  Preorderₓ.ext$ fun _ _ => Iff.rfl

theorem partial_order.dual_dual (α : Type _) [H : PartialOrderₓ α] : OrderDual.partialOrder (OrderDual α) = H :=
  PartialOrderₓ.ext$ fun _ _ => Iff.rfl

theorem linear_order.dual_dual (α : Type _) [H : LinearOrderₓ α] : OrderDual.linearOrder (OrderDual α) = H :=
  LinearOrderₓ.ext$ fun _ _ => Iff.rfl

end OrderDual

/-! ### Order instances on the function space -/


instance Pi.hasLe {ι : Type u} {α : ι → Type v} [∀ i, LE (α i)] : LE (∀ i, α i) :=
  { le := fun x y => ∀ i, x i ≤ y i }

theorem Pi.le_def {ι : Type u} {α : ι → Type v} [∀ i, LE (α i)] {x y : ∀ i, α i} : x ≤ y ↔ ∀ i, x i ≤ y i :=
  Iff.rfl

instance Pi.preorder {ι : Type u} {α : ι → Type v} [∀ i, Preorderₓ (α i)] : Preorderₓ (∀ i, α i) :=
  { Pi.hasLe with le_refl := fun a i => le_reflₓ (a i), le_trans := fun a b c h₁ h₂ i => le_transₓ (h₁ i) (h₂ i) }

-- error in Order.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem pi.lt_def
{ι : Type u}
{α : ι → Type v}
[∀ i, preorder (α i)]
{x y : ∀ i, α i} : «expr ↔ »(«expr < »(x, y), «expr ∧ »(«expr ≤ »(x, y), «expr∃ , »((i), «expr < »(x i, y i)))) :=
by simp [] [] [] ["[", expr lt_iff_le_not_le, ",", expr pi.le_def, "]"] [] [] { contextual := tt }

theorem le_update_iff {ι : Type u} {α : ι → Type v} [∀ i, Preorderₓ (α i)] [DecidableEq ι] {x y : ∀ i, α i} {i : ι}
  {a : α i} : x ≤ Function.update y i a ↔ x i ≤ a ∧ ∀ j (_ : j ≠ i), x j ≤ y j :=
  Function.forall_update_iff _ fun j z => x j ≤ z

theorem update_le_iff {ι : Type u} {α : ι → Type v} [∀ i, Preorderₓ (α i)] [DecidableEq ι] {x y : ∀ i, α i} {i : ι}
  {a : α i} : Function.update x i a ≤ y ↔ a ≤ y i ∧ ∀ j (_ : j ≠ i), x j ≤ y j :=
  Function.forall_update_iff _ fun j z => z ≤ y j

-- error in Order.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem update_le_update_iff
{ι : Type u}
{α : ι → Type v}
[∀ i, preorder (α i)]
[decidable_eq ι]
{x y : ∀ i, α i}
{i : ι}
{a
 b : α i} : «expr ↔ »(«expr ≤ »(function.update x i a, function.update y i b), «expr ∧ »(«expr ≤ »(a, b), ∀
  j «expr ≠ » i, «expr ≤ »(x j, y j))) :=
by simp [] [] [] ["[", expr update_le_iff, "]"] [] [] { contextual := tt }

instance Pi.partialOrder {ι : Type u} {α : ι → Type v} [∀ i, PartialOrderₓ (α i)] : PartialOrderₓ (∀ i, α i) :=
  { Pi.preorder with le_antisymm := fun f g h1 h2 => funext fun b => (h1 b).antisymm (h2 b) }

/-! ### Lifts of order instances -/


/-- Transfer a `preorder` on `β` to a `preorder` on `α` using a function `f : α → β`.
See note [reducible non-instances]. -/
@[reducible]
def Preorderₓ.lift {α β} [Preorderₓ β] (f : α → β) : Preorderₓ α :=
  { le := fun x y => f x ≤ f y, le_refl := fun a => le_rfl, le_trans := fun a b c => le_transₓ,
    lt := fun x y => f x < f y, lt_iff_le_not_le := fun a b => lt_iff_le_not_leₓ }

/-- Transfer a `partial_order` on `β` to a `partial_order` on `α` using an injective
function `f : α → β`. See note [reducible non-instances]. -/
@[reducible]
def PartialOrderₓ.lift {α β} [PartialOrderₓ β] (f : α → β) (inj : injective f) : PartialOrderₓ α :=
  { Preorderₓ.lift f with le_antisymm := fun a b h₁ h₂ => inj (h₁.antisymm h₂) }

/-- Transfer a `linear_order` on `β` to a `linear_order` on `α` using an injective
function `f : α → β`. See note [reducible non-instances]. -/
@[reducible]
def LinearOrderₓ.lift {α β} [LinearOrderₓ β] (f : α → β) (inj : injective f) : LinearOrderₓ α :=
  { PartialOrderₓ.lift f inj with le_total := fun x y => le_totalₓ (f x) (f y),
    decidableLe := fun x y => (inferInstance : Decidable (f x ≤ f y)),
    decidableLt := fun x y => (inferInstance : Decidable (f x < f y)),
    DecidableEq := fun x y => decidableOfIff _ inj.eq_iff }

instance Subtype.preorder {α} [Preorderₓ α] (p : α → Prop) : Preorderₓ (Subtype p) :=
  Preorderₓ.lift (coeₓ : Subtype p → α)

@[simp]
theorem Subtype.mk_le_mk {α} [Preorderₓ α] {p : α → Prop} {x y : α} {hx : p x} {hy : p y} :
  (⟨x, hx⟩ : Subtype p) ≤ ⟨y, hy⟩ ↔ x ≤ y :=
  Iff.rfl

@[simp]
theorem Subtype.mk_lt_mk {α} [Preorderₓ α] {p : α → Prop} {x y : α} {hx : p x} {hy : p y} :
  (⟨x, hx⟩ : Subtype p) < ⟨y, hy⟩ ↔ x < y :=
  Iff.rfl

@[simp, normCast]
theorem Subtype.coe_le_coe {α} [Preorderₓ α] {p : α → Prop} {x y : Subtype p} : (x : α) ≤ y ↔ x ≤ y :=
  Iff.rfl

@[simp, normCast]
theorem Subtype.coe_lt_coe {α} [Preorderₓ α] {p : α → Prop} {x y : Subtype p} : (x : α) < y ↔ x < y :=
  Iff.rfl

instance Subtype.partialOrder {α} [PartialOrderₓ α] (p : α → Prop) : PartialOrderₓ (Subtype p) :=
  PartialOrderₓ.lift coeₓ Subtype.coe_injective

/-- A subtype of a linear order is a linear order. We explicitly give the proof of decidable
  equality as the existing instance, in order to not have two instances of decidable equality that
  are not definitionally equal. -/
instance Subtype.linearOrder {α} [LinearOrderₓ α] (p : α → Prop) : LinearOrderₓ (Subtype p) :=
  { LinearOrderₓ.lift coeₓ Subtype.coe_injective with DecidableEq := Subtype.decidableEq }

namespace Prod

instance  (α : Type u) (β : Type v) [LE α] [LE β] : LE (α × β) :=
  ⟨fun p q => p.1 ≤ q.1 ∧ p.2 ≤ q.2⟩

theorem le_def {α β : Type _} [LE α] [LE β] {x y : α × β} : x ≤ y ↔ x.1 ≤ y.1 ∧ x.2 ≤ y.2 :=
  Iff.rfl

@[simp]
theorem mk_le_mk {α β : Type _} [LE α] [LE β] {x₁ x₂ : α} {y₁ y₂ : β} : (x₁, y₁) ≤ (x₂, y₂) ↔ x₁ ≤ x₂ ∧ y₁ ≤ y₂ :=
  Iff.rfl

instance  (α : Type u) (β : Type v) [Preorderₓ α] [Preorderₓ β] : Preorderₓ (α × β) :=
  { Prod.hasLe α β with le_refl := fun ⟨a, b⟩ => ⟨le_reflₓ a, le_reflₓ b⟩,
    le_trans := fun ⟨a, b⟩ ⟨c, d⟩ ⟨e, f⟩ ⟨hac, hbd⟩ ⟨hce, hdf⟩ => ⟨le_transₓ hac hce, le_transₓ hbd hdf⟩ }

/-- The pointwise partial order on a product.
    (The lexicographic ordering is defined in order/lexicographic.lean, and the instances are
    available via the type synonym `lex α β = α × β`.) -/
instance  (α : Type u) (β : Type v) [PartialOrderₓ α] [PartialOrderₓ β] : PartialOrderₓ (α × β) :=
  { Prod.preorder α β with
    le_antisymm := fun ⟨a, b⟩ ⟨c, d⟩ ⟨hac, hbd⟩ ⟨hca, hdb⟩ => Prod.extₓ (hac.antisymm hca) (hbd.antisymm hdb) }

end Prod

/-! ### Additional order classes -/


/-- Order without a maximal element. Sometimes called cofinal. -/
class NoTopOrder(α : Type u)[Preorderₓ α] : Prop where 
  no_top : ∀ (a : α), ∃ a', a < a'

theorem no_top [Preorderₓ α] [NoTopOrder α] : ∀ (a : α), ∃ a', a < a' :=
  NoTopOrder.no_top

instance nonempty_gt {α : Type u} [Preorderₓ α] [NoTopOrder α] (a : α) : Nonempty { x // a < x } :=
  nonempty_subtype.2 (no_top a)

/-- `a : α` is a top element of `α` if it is greater than or equal to any other element of `α`.
This predicate is useful, e.g., to make some statements and proofs work in both cases
`[order_top α]` and `[no_top_order α]`. -/
def IsTop {α : Type u} [LE α] (a : α) : Prop :=
  ∀ b, b ≤ a

@[simp]
theorem not_is_top {α : Type u} [Preorderₓ α] [NoTopOrder α] (a : α) : ¬IsTop a :=
  fun h =>
    let ⟨b, hb⟩ := no_top a 
    hb.not_le (h b)

theorem IsTop.unique {α : Type u} [PartialOrderₓ α] {a b : α} (ha : IsTop a) (hb : a ≤ b) : a = b :=
  le_antisymmₓ hb (ha b)

/-- Order without a minimal element. Sometimes called coinitial or dense. -/
class NoBotOrder(α : Type u)[Preorderₓ α] : Prop where 
  no_bot : ∀ (a : α), ∃ a', a' < a

theorem no_bot [Preorderₓ α] [NoBotOrder α] : ∀ (a : α), ∃ a', a' < a :=
  NoBotOrder.no_bot

/-- `a : α` is a bottom element of `α` if it is less than or equal to any other element of `α`.
This predicate is useful, e.g., to make some statements and proofs work in both cases
`[order_bot α]` and `[no_bot_order α]`. -/
def IsBot {α : Type u} [LE α] (a : α) : Prop :=
  ∀ b, a ≤ b

@[simp]
theorem not_is_bot {α : Type u} [Preorderₓ α] [NoBotOrder α] (a : α) : ¬IsBot a :=
  fun h =>
    let ⟨b, hb⟩ := no_bot a 
    hb.not_le (h b)

theorem IsBot.unique {α : Type u} [PartialOrderₓ α] {a b : α} (ha : IsBot a) (hb : b ≤ a) : a = b :=
  le_antisymmₓ (ha b) hb

instance OrderDual.no_top_order (α : Type u) [Preorderₓ α] [NoBotOrder α] : NoTopOrder (OrderDual α) :=
  ⟨fun a => @no_bot α _ _ a⟩

instance OrderDual.no_bot_order (α : Type u) [Preorderₓ α] [NoTopOrder α] : NoBotOrder (OrderDual α) :=
  ⟨fun a => @no_top α _ _ a⟩

instance nonempty_lt {α : Type u} [Preorderₓ α] [NoBotOrder α] (a : α) : Nonempty { x // x < a } :=
  nonempty_subtype.2 (no_bot a)

/-- An order is dense if there is an element between any pair of distinct elements. -/
class DenselyOrdered(α : Type u)[Preorderₓ α] : Prop where 
  dense : ∀ (a₁ a₂ : α), a₁ < a₂ → ∃ a, a₁ < a ∧ a < a₂

theorem exists_between [Preorderₓ α] [DenselyOrdered α] : ∀ {a₁ a₂ : α}, a₁ < a₂ → ∃ a, a₁ < a ∧ a < a₂ :=
  DenselyOrdered.dense

instance OrderDual.densely_ordered (α : Type u) [Preorderₓ α] [DenselyOrdered α] : DenselyOrdered (OrderDual α) :=
  ⟨fun a₁ a₂ ha => (@exists_between α _ _ _ _ ha).imp$ fun a => And.symm⟩

theorem le_of_forall_le_of_dense [LinearOrderₓ α] [DenselyOrdered α] {a₁ a₂ : α} (h : ∀ a, a₂ < a → a₁ ≤ a) : a₁ ≤ a₂ :=
  le_of_not_gtₓ$
    fun ha =>
      let ⟨a, ha₁, ha₂⟩ := exists_between ha 
      lt_irreflₓ a$ lt_of_lt_of_leₓ ‹a < a₁› (h _ ‹a₂ < a›)

theorem eq_of_le_of_forall_le_of_dense [LinearOrderₓ α] [DenselyOrdered α] {a₁ a₂ : α} (h₁ : a₂ ≤ a₁)
  (h₂ : ∀ a, a₂ < a → a₁ ≤ a) : a₁ = a₂ :=
  le_antisymmₓ (le_of_forall_le_of_dense h₂) h₁

theorem le_of_forall_ge_of_dense [LinearOrderₓ α] [DenselyOrdered α] {a₁ a₂ : α} (h : ∀ a₃ (_ : a₃ < a₁), a₃ ≤ a₂) :
  a₁ ≤ a₂ :=
  le_of_not_gtₓ$
    fun ha =>
      let ⟨a, ha₁, ha₂⟩ := exists_between ha 
      lt_irreflₓ a$ lt_of_le_of_ltₓ (h _ ‹a < a₁›) ‹a₂ < a›

theorem eq_of_le_of_forall_ge_of_dense [LinearOrderₓ α] [DenselyOrdered α] {a₁ a₂ : α} (h₁ : a₂ ≤ a₁)
  (h₂ : ∀ a₃ (_ : a₃ < a₁), a₃ ≤ a₂) : a₁ = a₂ :=
  (le_of_forall_ge_of_dense h₂).antisymm h₁

theorem dense_or_discrete [LinearOrderₓ α] (a₁ a₂ : α) :
  (∃ a, a₁ < a ∧ a < a₂) ∨ (∀ a, a₁ < a → a₂ ≤ a) ∧ ∀ a (_ : a < a₂), a ≤ a₁ :=
  or_iff_not_imp_left.2$
    fun h =>
      ⟨fun a ha₁ => le_of_not_gtₓ$ fun ha₂ => h ⟨a, ha₁, ha₂⟩, fun a ha₂ => le_of_not_gtₓ$ fun ha₁ => h ⟨a, ha₁, ha₂⟩⟩

variable{s : β → β → Prop}{t : γ → γ → Prop}

/-! ### Linear order from a total partial order -/


/-- Type synonym to create an instance of `linear_order` from a `partial_order` and
`is_total α (≤)` -/
def AsLinearOrder (α : Type u) :=
  α

instance  {α} [Inhabited α] : Inhabited (AsLinearOrder α) :=
  ⟨(default α : α)⟩

noncomputable instance AsLinearOrder.linearOrder {α} [PartialOrderₓ α] [IsTotal α (· ≤ ·)] :
  LinearOrderₓ (AsLinearOrder α) :=
  { (_ : PartialOrderₓ α) with le_total := @total_of α (· ≤ ·) _, decidableLe := Classical.decRel _ }

