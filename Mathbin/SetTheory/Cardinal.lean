import Mathbin.Data.Nat.Enat 
import Mathbin.Data.Set.Countable 
import Mathbin.SetTheory.SchroederBernstein

/-!
# Cardinal Numbers

We define cardinal numbers as a quotient of types under the equivalence relation of equinumerity.

## Main definitions

* `cardinal` the type of cardinal numbers (in a given universe).
* `cardinal.mk α` or `#α` is the cardinality of `α`. The notation `#` lives in the locale
  `cardinal`.
* There is an instance that `cardinal` forms a `canonically_ordered_comm_semiring`.
* Addition `c₁ + c₂` is defined by `cardinal.add_def α β : #α + #β = #(α ⊕ β)`.
* Multiplication `c₁ * c₂` is defined by `cardinal.mul_def : #α * #β = #(α * β)`.
* The order `c₁ ≤ c₂` is defined by `cardinal.le_def α β : #α ≤ #β ↔ nonempty (α ↪ β)`.
* Exponentiation `c₁ ^ c₂` is defined by `cardinal.power_def α β : #α ^ #β = #(β → α)`.
* `cardinal.omega` or `ω` the cardinality of `ℕ`. This definition is universe polymorphic:
  `cardinal.omega.{u} : cardinal.{u}`
  (contrast with `ℕ : Type`, which lives in a specific universe).
  In some cases the universe level has to be given explicitly.
* `cardinal.min (I : nonempty ι) (c : ι → cardinal)` is the minimal cardinal in the range of `c`.
* `cardinal.succ c` is the successor cardinal, the smallest cardinal larger than `c`.
* `cardinal.sum` is the sum of a collection of cardinals.
* `cardinal.sup` is the supremum of a collection of cardinals.
* `cardinal.powerlt c₁ c₂` or `c₁ ^< c₂` is defined as `sup_{γ < β} α^γ`.

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
    local infixr ^ := @has_pow.pow cardinal cardinal cardinal.has_pow
  ```
  to a file. This notation will work even if Lean doesn't know yet that the base and the exponent
  live in the same universe (but no exponents in other types can be used).

## References

* <https://en.wikipedia.org/wiki/Cardinal_number>

## Tags

cardinal number, cardinal arithmetic, cardinal exponentiation, omega,
Cantor's theorem, König's theorem, Konig's theorem
-/


open Function Set

open_locale Classical

universe u v w x

variable{α β : Type u}

/-- The equivalence relation on types given by equivalence (bijective correspondence) of types.
  Quotienting by this equivalence relation gives the cardinal numbers.
-/
instance Cardinal.isEquivalent : Setoidₓ (Type u) :=
  { R := fun α β => Nonempty (α ≃ β),
    iseqv := ⟨fun α => ⟨Equiv.refl α⟩, fun α β ⟨e⟩ => ⟨e.symm⟩, fun α β γ ⟨e₁⟩ ⟨e₂⟩ => ⟨e₁.trans e₂⟩⟩ }

/-- `cardinal.{u}` is the type of cardinal numbers in `Type u`,
  defined as the quotient of `Type u` by existence of an equivalence
  (a bijection with explicit inverse). -/
def Cardinal : Type (u + 1) :=
  Quotientₓ Cardinal.isEquivalent

namespace Cardinal

/-- The cardinal number of a type -/
def mk : Type u → Cardinal :=
  Quotientₓ.mk

localized [Cardinal] notation "#" => Cardinal.mk

instance can_lift_cardinal_Type : CanLift Cardinal.{u} (Type u) :=
  ⟨mk, fun c => True, fun c _ => Quot.induction_on c$ fun α => ⟨α, rfl⟩⟩

@[elab_as_eliminator]
theorem induction_on {p : Cardinal → Prop} (c : Cardinal) (h : ∀ α, p (# α)) : p c :=
  Quotientₓ.induction_on c h

@[elab_as_eliminator]
theorem induction_on₂ {p : Cardinal → Cardinal → Prop} (c₁ : Cardinal) (c₂ : Cardinal) (h : ∀ α β, p (# α) (# β)) :
  p c₁ c₂ :=
  Quotientₓ.induction_on₂ c₁ c₂ h

@[elab_as_eliminator]
theorem induction_on₃ {p : Cardinal → Cardinal → Cardinal → Prop} (c₁ : Cardinal) (c₂ : Cardinal) (c₃ : Cardinal)
  (h : ∀ α β γ, p (# α) (# β) (# γ)) : p c₁ c₂ c₃ :=
  Quotientₓ.induction_on₃ c₁ c₂ c₃ h

protected theorem Eq : # α = # β ↔ Nonempty (α ≃ β) :=
  Quotientₓ.eq

@[simp]
theorem mk_def (α : Type u) : @Eq Cardinal («expr⟦ ⟧» α) (# α) :=
  rfl

@[simp]
theorem mk_out (c : Cardinal) : # c.out = c :=
  Quotientₓ.out_eq _

/-- The representative of the cardinal of a type is equivalent ot the original type. -/
noncomputable def out_mk_equiv {α : Type v} : (# α).out ≃ α :=
  Nonempty.some$
    Cardinal.eq.mp
      (by 
        simp )

theorem mk_congr (e : α ≃ β) : # α = # β :=
  Quot.sound ⟨e⟩

alias mk_congr ← Equiv.cardinal_eq

/-- Lift a function between `Type*`s to a function between `cardinal`s. -/
def map (f : Type u → Type v) (hf : ∀ α β, α ≃ β → f α ≃ f β) : Cardinal.{u} → Cardinal.{v} :=
  Quotientₓ.map f fun α β ⟨e⟩ => ⟨hf α β e⟩

@[simp]
theorem map_mk (f : Type u → Type v) (hf : ∀ α β, α ≃ β → f α ≃ f β) (α : Type u) : map f hf (# α) = # (f α) :=
  rfl

/-- Lift a binary operation `Type* → Type* → Type*` to a binary operation on `cardinal`s. -/
def map₂ (f : Type u → Type v → Type w) (hf : ∀ α β γ δ, α ≃ β → γ ≃ δ → f α γ ≃ f β δ) :
  Cardinal.{u} → Cardinal.{v} → Cardinal.{w} :=
  Quotientₓ.map₂ f$ fun α β ⟨e₁⟩ γ δ ⟨e₂⟩ => ⟨hf α β γ δ e₁ e₂⟩

/-- The universe lift operation on cardinals. You can specify the universes explicitly with
  `lift.{u v} : cardinal.{v} → cardinal.{max v u}` -/
def lift (c : Cardinal.{v}) : Cardinal.{max v u} :=
  map Ulift (fun α β e => Equiv.ulift.trans$ e.trans Equiv.ulift.symm) c

@[simp]
theorem mk_ulift α : # (Ulift.{v, u} α) = lift.{v} (# α) :=
  rfl

theorem lift_umax : lift.{max u v, u} = lift.{v, u} :=
  funext$ fun a => induction_on a$ fun α => (Equiv.ulift.trans Equiv.ulift.symm).cardinal_eq

theorem lift_umax' : lift.{max v u, u} = lift.{v, u} :=
  lift_umax

theorem lift_id' (a : Cardinal.{max u v}) : lift.{u} a = a :=
  induction_on a$ fun α => mk_congr Equiv.ulift

@[simp]
theorem lift_id (a : Cardinal) : lift.{u, u} a = a :=
  lift_id'.{u, u} a

@[simp]
theorem lift_uzero (a : Cardinal.{u}) : lift.{0} a = a :=
  lift_id'.{0, u} a

@[simp]
theorem lift_lift (a : Cardinal) : lift.{w} (lift.{v} a) = lift.{max v w} a :=
  induction_on a$ fun α => (Equiv.ulift.trans$ Equiv.ulift.trans Equiv.ulift.symm).cardinal_eq

/-- We define the order on cardinal numbers by `#α ≤ #β` if and only if
  there exists an embedding (injective function) from α to β. -/
instance  : LE Cardinal.{u} :=
  ⟨fun q₁ q₂ =>
      (Quotientₓ.liftOn₂ q₁ q₂ fun α β => Nonempty$ α ↪ β)$
        fun α β γ δ ⟨e₁⟩ ⟨e₂⟩ => propext ⟨fun ⟨e⟩ => ⟨e.congr e₁ e₂⟩, fun ⟨e⟩ => ⟨e.congr e₁.symm e₂.symm⟩⟩⟩

theorem le_def (α β : Type u) : # α ≤ # β ↔ Nonempty (α ↪ β) :=
  Iff.rfl

theorem mk_le_of_injective {α β : Type u} {f : α → β} (hf : injective f) : # α ≤ # β :=
  ⟨⟨f, hf⟩⟩

theorem _root_.function.embedding.cardinal_le {α β : Type u} (f : α ↪ β) : # α ≤ # β :=
  ⟨f⟩

theorem mk_le_of_surjective {α β : Type u} {f : α → β} (hf : surjective f) : # β ≤ # α :=
  ⟨embedding.of_surjective f hf⟩

theorem le_mk_iff_exists_set {c : Cardinal} {α : Type u} : c ≤ # α ↔ ∃ p : Set α, # p = c :=
  ⟨induction_on c$ fun β ⟨⟨f, hf⟩⟩ => ⟨Set.Range f, (Equiv.ofInjective f hf).cardinal_eq.symm⟩,
    fun ⟨p, e⟩ => e ▸ ⟨⟨Subtype.val, fun a b => Subtype.eq⟩⟩⟩

theorem out_embedding {c c' : Cardinal} : c ≤ c' ↔ Nonempty (c.out ↪ c'.out) :=
  by 
    trans _ 
    rw [←Quotientₓ.out_eq c, ←Quotientₓ.out_eq c']
    rfl

instance  : Preorderₓ Cardinal.{u} :=
  { le := · ≤ ·,
    le_refl :=
      by 
        rintro ⟨α⟩ <;> exact ⟨embedding.refl _⟩,
    le_trans :=
      by 
        rintro ⟨α⟩ ⟨β⟩ ⟨γ⟩ ⟨e₁⟩ ⟨e₂⟩ <;> exact ⟨e₁.trans e₂⟩ }

instance  : PartialOrderₓ Cardinal.{u} :=
  { Cardinal.preorder with
    le_antisymm :=
      by 
        rintro ⟨α⟩ ⟨β⟩ ⟨e₁⟩ ⟨e₂⟩
        exact Quotientₓ.sound (e₁.antisymm e₂) }

theorem lift_mk_le {α : Type u} {β : Type v} : lift.{max v w} (# α) ≤ lift.{max u w} (# β) ↔ Nonempty (α ↪ β) :=
  ⟨fun ⟨f⟩ => ⟨embedding.congr Equiv.ulift Equiv.ulift f⟩,
    fun ⟨f⟩ => ⟨embedding.congr Equiv.ulift.symm Equiv.ulift.symm f⟩⟩

/-- A variant of `cardinal.lift_mk_le` with specialized universes.
Because Lean often can not realize it should use this specialization itself,
we provide this statement separately so you don't have to solve the specialization problem either.
-/
theorem lift_mk_le' {α : Type u} {β : Type v} : lift.{v} (# α) ≤ lift.{u} (# β) ↔ Nonempty (α ↪ β) :=
  lift_mk_le.{u, v, 0}

theorem lift_mk_eq {α : Type u} {β : Type v} : lift.{max v w} (# α) = lift.{max u w} (# β) ↔ Nonempty (α ≃ β) :=
  Quotientₓ.eq.trans
    ⟨fun ⟨f⟩ => ⟨Equiv.ulift.symm.trans$ f.trans Equiv.ulift⟩, fun ⟨f⟩ => ⟨Equiv.ulift.trans$ f.trans Equiv.ulift.symm⟩⟩

/-- A variant of `cardinal.lift_mk_eq` with specialized universes.
Because Lean often can not realize it should use this specialization itself,
we provide this statement separately so you don't have to solve the specialization problem either.
-/
theorem lift_mk_eq' {α : Type u} {β : Type v} : lift.{v} (# α) = lift.{u} (# β) ↔ Nonempty (α ≃ β) :=
  lift_mk_eq.{u, v, 0}

@[simp]
theorem lift_le {a b : Cardinal} : lift a ≤ lift b ↔ a ≤ b :=
  induction_on₂ a b$
    fun α β =>
      by 
        rw [←lift_umax]
        exact lift_mk_le

/-- `cardinal.lift` as an `order_embedding`. -/
@[simps (config := { fullyApplied := ff })]
def lift_order_embedding : Cardinal.{v} ↪o Cardinal.{max v u} :=
  OrderEmbedding.ofMapLeIff lift fun _ _ => lift_le

theorem lift_injective : injective lift.{u, v} :=
  lift_order_embedding.Injective

@[simp]
theorem lift_inj {a b : Cardinal} : lift a = lift b ↔ a = b :=
  lift_injective.eq_iff

@[simp]
theorem lift_lt {a b : Cardinal} : lift a < lift b ↔ a < b :=
  lift_order_embedding.lt_iff_lt

instance  : HasZero Cardinal.{u} :=
  ⟨# Pempty⟩

instance  : Inhabited Cardinal.{u} :=
  ⟨0⟩

theorem mk_eq_zero (α : Type u) [IsEmpty α] : # α = 0 :=
  (Equiv.equivPempty α).cardinal_eq

@[simp]
theorem lift_zero : lift 0 = 0 :=
  mk_congr (Equiv.equivPempty _)

@[simp]
theorem lift_eq_zero {a : Cardinal.{v}} : lift.{u} a = 0 ↔ a = 0 :=
  lift_injective.eq_iff' lift_zero

theorem mk_eq_zero_iff {α : Type u} : # α = 0 ↔ IsEmpty α :=
  ⟨fun e =>
      let ⟨h⟩ := Quotientₓ.exact e 
      h.is_empty,
    @mk_eq_zero α⟩

theorem mk_ne_zero_iff {α : Type u} : # α ≠ 0 ↔ Nonempty α :=
  (not_iff_not.2 mk_eq_zero_iff).trans not_is_empty_iff

@[simp]
theorem mk_ne_zero (α : Type u) [Nonempty α] : # α ≠ 0 :=
  mk_ne_zero_iff.2 ‹_›

instance  : HasOne Cardinal.{u} :=
  ⟨«expr⟦ ⟧» PUnit⟩

instance  : Nontrivial Cardinal.{u} :=
  ⟨⟨1, 0, mk_ne_zero _⟩⟩

theorem mk_eq_one (α : Type u) [Unique α] : # α = 1 :=
  mk_congr equivPunitOfUnique

theorem le_one_iff_subsingleton {α : Type u} : # α ≤ 1 ↔ Subsingleton α :=
  ⟨fun ⟨f⟩ => ⟨fun a b => f.injective (Subsingleton.elimₓ _ _)⟩, fun ⟨h⟩ => ⟨⟨fun a => PUnit.unit, fun a b _ => h _ _⟩⟩⟩

instance  : Add Cardinal.{u} :=
  ⟨map₂ Sum$ fun α β γ δ => Equiv.sumCongr⟩

theorem add_def (α β : Type u) : (# α+# β) = # (Sum α β) :=
  rfl

@[simp]
theorem mk_sum (α : Type u) (β : Type v) : # (Sum α β) = lift.{v, u} (# α)+lift.{u, v} (# β) :=
  mk_congr (Equiv.ulift.symm.sumCongr Equiv.ulift.symm)

@[simp]
theorem mk_option {α : Type u} : # (Option α) = # α+1 :=
  (Equiv.optionEquivSumPunit α).cardinal_eq

@[simp]
theorem mk_psum (α : Type u) (β : Type v) : # (Psum α β) = lift.{v} (# α)+lift.{u} (# β) :=
  (mk_congr (Equiv.psumEquivSum α β)).trans (mk_sum α β)

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp] theorem mk_fintype (α : Type u) [fintype α] : «expr = »(«expr#»() α, fintype.card α) :=
begin
  refine [expr fintype.induction_empty_option' _ _ _ α],
  { introsI [ident α, ident β, ident h, ident e, ident hα],
    letI [] [] [":=", expr fintype.of_equiv β e.symm],
    rwa ["[", expr mk_congr e, ",", expr fintype.card_congr e, "]"] ["at", ident hα] },
  { refl },
  { introsI [ident α, ident h, ident hα],
    simp [] [] [] ["[", expr hα, "]"] [] [] }
end

instance  : Mul Cardinal.{u} :=
  ⟨map₂ Prod$ fun α β γ δ => Equiv.prodCongr⟩

theorem mul_def (α β : Type u) : (# α*# β) = # (α × β) :=
  rfl

@[simp]
theorem mk_prod (α : Type u) (β : Type v) : # (α × β) = lift.{v, u} (# α)*lift.{u, v} (# β) :=
  mk_congr (Equiv.ulift.symm.prodCongr Equiv.ulift.symm)

protected theorem add_commₓ (a b : Cardinal.{u}) : (a+b) = b+a :=
  induction_on₂ a b$ fun α β => mk_congr (Equiv.sumComm α β)

protected theorem mul_commₓ (a b : Cardinal.{u}) : (a*b) = b*a :=
  induction_on₂ a b$ fun α β => mk_congr (Equiv.prodComm α β)

protected theorem zero_addₓ (a : Cardinal.{u}) : (0+a) = a :=
  induction_on a$ fun α => mk_congr (Equiv.emptySum Pempty α)

protected theorem zero_mul (a : Cardinal.{u}) : (0*a) = 0 :=
  induction_on a$ fun α => mk_congr (Equiv.pemptyProd α)

protected theorem one_mulₓ (a : Cardinal.{u}) : (1*a) = a :=
  induction_on a$ fun α => mk_congr (Equiv.punitProd α)

protected theorem left_distrib (a b c : Cardinal.{u}) : (a*b+c) = (a*b)+a*c :=
  induction_on₃ a b c$ fun α β γ => mk_congr (Equiv.prodSumDistrib α β γ)

protected theorem eq_zero_or_eq_zero_of_mul_eq_zero {a b : Cardinal.{u}} : (a*b) = 0 → a = 0 ∨ b = 0 :=
  by 
    induction' a using Cardinal.induction_on with α 
    induction' b using Cardinal.induction_on with β 
    simp only [mul_def, mk_eq_zero_iff, is_empty_prod]
    exact id

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The cardinal exponential. `#α ^ #β` is the cardinal of `β → α`. -/
protected
def power (a b : cardinal.{u}) : cardinal.{u} :=
map₂ (λ α β : Type u, β → α) (λ α β γ δ e₁ e₂, e₂.arrow_congr e₁) a b

instance  : Pow Cardinal Cardinal :=
  ⟨Cardinal.power⟩

local infixr:0 "^" => @Pow.pow Cardinal Cardinal Cardinal.hasPow

local infixr:80 " ^ℕ " => @Pow.pow Cardinal ℕ Monoidₓ.hasPow

theorem power_def α β : (# α^# β) = # (β → α) :=
  rfl

theorem mk_arrow (α : Type u) (β : Type v) : # (α → β) = (lift.{u} (# β)^lift.{v} (# α)) :=
  mk_congr (Equiv.ulift.symm.arrowCongr Equiv.ulift.symm)

@[simp]
theorem lift_power a b : lift (a^b) = (lift a^lift b) :=
  induction_on₂ a b$ fun α β => mk_congr (Equiv.ulift.trans (Equiv.ulift.arrowCongr Equiv.ulift).symm)

@[simp]
theorem power_zero {a : Cardinal} : (a^0) = 1 :=
  induction_on a$ fun α => (Equiv.pemptyArrowEquivPunit α).cardinal_eq

@[simp]
theorem power_one {a : Cardinal} : (a^1) = a :=
  induction_on a$ fun α => (Equiv.punitArrowEquiv α).cardinal_eq

theorem power_add {a b c : Cardinal} : (a^b+c) = (a^b)*a^c :=
  induction_on₃ a b c$ fun α β γ => (Equiv.sumArrowEquivProdArrow β γ α).cardinal_eq

instance  : CommSemiringₓ Cardinal.{u} :=
  { zero := 0, one := 1, add := ·+·, mul := ·*·, zero_add := Cardinal.zero_add,
    add_zero :=
      fun a =>
        by 
          rw [Cardinal.add_comm a 0, Cardinal.zero_add a],
    add_assoc := fun a b c => induction_on₃ a b c$ fun α β γ => mk_congr (Equiv.sumAssoc α β γ),
    add_comm := Cardinal.add_comm, zero_mul := Cardinal.zero_mul,
    mul_zero :=
      fun a =>
        by 
          rw [Cardinal.mul_comm a 0, Cardinal.zero_mul a],
    one_mul := Cardinal.one_mul,
    mul_one :=
      fun a =>
        by 
          rw [Cardinal.mul_comm a 1, Cardinal.one_mul a],
    mul_assoc := fun a b c => induction_on₃ a b c$ fun α β γ => mk_congr (Equiv.prodAssoc α β γ),
    mul_comm := Cardinal.mul_comm, left_distrib := Cardinal.left_distrib,
    right_distrib :=
      fun a b c =>
        by 
          rw [Cardinal.mul_comm (a+b) c, Cardinal.left_distrib c a b, Cardinal.mul_comm c a, Cardinal.mul_comm c b],
    npow := fun n c => c^n, npow_zero' := @power_zero,
    npow_succ' :=
      fun n c =>
        by 
          rw [Nat.cast_succ, power_add, power_one, Cardinal.mul_comm] }

@[simp]
theorem one_power {a : Cardinal} : (1^a) = 1 :=
  induction_on a$ fun α => (Equiv.arrowPunitEquivPunit α).cardinal_eq

@[simp]
theorem mk_bool : # Bool = 2 :=
  by 
    simp 

@[simp]
theorem mk_Prop : # Prop = 2 :=
  by 
    simp 

@[simp]
theorem zero_power {a : Cardinal} : a ≠ 0 → (0^a) = 0 :=
  induction_on a$
    fun α heq =>
      mk_eq_zero_iff.2$
        is_empty_pi.2$
          let ⟨a⟩ := mk_ne_zero_iff.1 HEq
          ⟨a, Pempty.is_empty⟩

theorem power_ne_zero {a : Cardinal} b : a ≠ 0 → (a^b) ≠ 0 :=
  induction_on₂ a b$
    fun α β h =>
      let ⟨a⟩ := mk_ne_zero_iff.1 h 
      mk_ne_zero_iff.2 ⟨fun _ => a⟩

theorem mul_power {a b c : Cardinal} : ((a*b)^c) = (a^c)*b^c :=
  induction_on₃ a b c$ fun α β γ => (Equiv.arrowProdEquivProdArrow α β γ).cardinal_eq

theorem power_mul {a b c : Cardinal} : (a^b*c) = ((a^b)^c) :=
  by 
    rw [mul_commₓ b c] <;> exact induction_on₃ a b c$ fun α β γ => mk_congr (Equiv.curry γ β α)

@[simp]
theorem pow_cast_right (κ : Cardinal.{u}) (n : ℕ) : (κ^(«expr↑ » n : Cardinal.{u})) = κ ^ℕ n :=
  rfl

@[simp]
theorem lift_one : lift 1 = 1 :=
  mk_congr (Equiv.ulift.trans Equiv.punitEquivPunit)

@[simp]
theorem lift_add a b : lift (a+b) = lift a+lift b :=
  induction_on₂ a b$ fun α β => mk_congr (Equiv.ulift.trans (Equiv.sumCongr Equiv.ulift Equiv.ulift).symm)

@[simp]
theorem lift_mul a b : lift (a*b) = lift a*lift b :=
  induction_on₂ a b$ fun α β => mk_congr (Equiv.ulift.trans (Equiv.prodCongr Equiv.ulift Equiv.ulift).symm)

@[simp]
theorem lift_bit0 (a : Cardinal) : lift (bit0 a) = bit0 (lift a) :=
  lift_add a a

@[simp]
theorem lift_bit1 (a : Cardinal) : lift (bit1 a) = bit1 (lift a) :=
  by 
    simp [bit1]

theorem lift_two : lift.{u, v} 2 = 2 :=
  by 
    simp 

@[simp]
theorem mk_set {α : Type u} : # (Set α) = (2^# α) :=
  by 
    simp [Set, mk_arrow]

theorem lift_two_power a : lift (2^a) = (2^lift a) :=
  by 
    simp 

section OrderProperties

open Sum

protected theorem zero_le : ∀ (a : Cardinal), 0 ≤ a :=
  by 
    rintro ⟨α⟩ <;> exact ⟨embedding.of_is_empty⟩

protected theorem add_le_add : ∀ {a b c d : Cardinal}, a ≤ b → c ≤ d → (a+c) ≤ b+d :=
  by 
    rintro ⟨α⟩ ⟨β⟩ ⟨γ⟩ ⟨δ⟩ ⟨e₁⟩ ⟨e₂⟩ <;> exact ⟨e₁.sum_map e₂⟩

protected theorem add_le_add_left a {b c : Cardinal} : b ≤ c → (a+b) ≤ a+c :=
  Cardinal.add_le_add (le_reflₓ _)

protected theorem le_iff_exists_add {a b : Cardinal} : a ≤ b ↔ ∃ c, b = a+c :=
  ⟨induction_on₂ a b$
      fun α β ⟨⟨f, hf⟩⟩ =>
        have  : Sum α («expr ᶜ» (range f) : Set β) ≃ β :=
          (Equiv.sumCongr (Equiv.ofInjective f hf) (Equiv.refl _)).trans$ Equiv.Set.sumCompl (range f)
        ⟨# («expr↥ » («expr ᶜ» (range f))), mk_congr this.symm⟩,
    fun ⟨c, e⟩ => add_zeroₓ a ▸ e.symm ▸ Cardinal.add_le_add_left _ (Cardinal.zero_le _)⟩

instance  : OrderBot Cardinal.{u} :=
  { bot := 0, bot_le := Cardinal.zero_le }

instance  : CanonicallyOrderedCommSemiring Cardinal.{u} :=
  { Cardinal.orderBot, Cardinal.commSemiring, Cardinal.partialOrder with
    add_le_add_left := fun a b h c => Cardinal.add_le_add_left _ h, le_iff_exists_add := @Cardinal.le_iff_exists_add,
    eq_zero_or_eq_zero_of_mul_eq_zero := @Cardinal.eq_zero_or_eq_zero_of_mul_eq_zero }

@[simp]
theorem zero_lt_one : (0 : Cardinal) < 1 :=
  lt_of_le_of_neₓ (zero_le _) zero_ne_one

theorem zero_power_le (c : Cardinal.{u}) : ((0 : Cardinal.{u})^c) ≤ 1 :=
  by 
    byCases' h : c = 0
    rw [h, power_zero]
    rw [zero_power h]
    apply zero_le

theorem power_le_power_left : ∀ {a b c : Cardinal}, a ≠ 0 → b ≤ c → (a^b) ≤ (a^c) :=
  by 
    rintro ⟨α⟩ ⟨β⟩ ⟨γ⟩ hα ⟨e⟩ <;>
      exact
        let ⟨a⟩ := mk_ne_zero_iff.1 hα
        ⟨@embedding.arrow_congr_left _ _ _ ⟨a⟩ e⟩

/-- **Cantor's theorem** -/
theorem cantor (a : Cardinal.{u}) : a < (2^a) :=
  by 
    induction' a using Cardinal.induction_on with α 
    rw [←mk_set]
    refine' ⟨⟨⟨singleton, fun a b => singleton_eq_singleton_iff.1⟩⟩, _⟩
    rintro ⟨⟨f, hf⟩⟩
    exact cantor_injective f hf

instance  : NoTopOrder Cardinal.{u} :=
  { Cardinal.partialOrder with no_top := fun a => ⟨_, cantor a⟩ }

noncomputable instance  : LinearOrderₓ Cardinal.{u} :=
  { Cardinal.partialOrder with
    le_total :=
      by 
        rintro ⟨α⟩ ⟨β⟩ <;> exact embedding.total,
    decidableLe := Classical.decRel _ }

noncomputable instance  : CanonicallyLinearOrderedAddMonoid Cardinal.{u} :=
  { (inferInstance : CanonicallyOrderedAddMonoid Cardinal.{u}), Cardinal.linearOrder with  }

noncomputable instance  : DistribLattice Cardinal.{u} :=
  by 
    infer_instance

theorem one_lt_iff_nontrivial {α : Type u} : 1 < # α ↔ Nontrivial α :=
  by 
    rw [←not_leₓ, le_one_iff_subsingleton, ←not_nontrivial_iff_subsingleton, not_not]

theorem power_le_max_power_one {a b c : Cardinal} (h : b ≤ c) : (a^b) ≤ max (a^c) 1 :=
  by 
    byCases' ha : a = 0
    simp [ha, zero_power_le]
    exact le_transₓ (power_le_power_left ha h) (le_max_leftₓ _ _)

theorem power_le_power_right {a b c : Cardinal} : a ≤ b → (a^c) ≤ (b^c) :=
  induction_on₃ a b c$ fun α β γ ⟨e⟩ => ⟨embedding.arrow_congr_right e⟩

end OrderProperties

/-- The minimum cardinal in a family of cardinals (the existence
  of which is provided by `injective_min`). -/
noncomputable def min {ι} (I : Nonempty ι) (f : ι → Cardinal) : Cardinal :=
  f$ Classical.some$ @embedding.min_injective _ (fun i => (f i).out) I

theorem min_eq {ι} I (f : ι → Cardinal) : ∃ i, min I f = f i :=
  ⟨_, rfl⟩

theorem min_le {ι I} (f : ι → Cardinal) i : min I f ≤ f i :=
  by 
    rw [←mk_out (min I f), ←mk_out (f i)] <;>
      exact
        let ⟨g⟩ := Classical.some_spec (@embedding.min_injective _ (fun i => (f i).out) I)
        ⟨g i⟩

theorem le_minₓ {ι I} {f : ι → Cardinal} {a} : a ≤ min I f ↔ ∀ i, a ≤ f i :=
  ⟨fun h i => le_transₓ h (min_le _ _),
    fun h =>
      let ⟨i, e⟩ := min_eq I f 
      e.symm ▸ h i⟩

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
protected theorem wf : @well_founded cardinal.{u} ((«expr < »)) :=
⟨λ
 a, «expr $ »(classical.by_contradiction, λ
  h, let ι := {c : cardinal // «expr¬ »(acc ((«expr < »)) c)},
      f : ι → cardinal := subtype.val,
      ⟨⟨c, hc⟩, hi⟩ := @min_eq ι ⟨⟨_, h⟩⟩ f in
  hc (acc.intro _ (λ
    (j)
    ⟨_, h'⟩, «expr $ »(classical.by_contradiction, λ
     hj, «expr $ »(h', by have [] [] [":=", expr min_le f ⟨j, hj⟩]; rwa [expr hi] ["at", ident this])))))⟩

instance has_wf : @HasWellFounded Cardinal.{u} :=
  ⟨· < ·, Cardinal.wf⟩

instance wo : @IsWellOrder Cardinal.{u} (· < ·) :=
  ⟨Cardinal.wf⟩

/-- The successor cardinal - the smallest cardinal greater than
  `c`. This is not the same as `c + 1` except in the case of finite `c`. -/
noncomputable def succ (c : Cardinal) : Cardinal :=
  @min { c' // c < c' } ⟨⟨_, cantor _⟩⟩ Subtype.val

theorem lt_succ_self (c : Cardinal) : c < succ c :=
  by 
    cases' min_eq _ _ with s e <;> rw [succ, e] <;> exact s.2

theorem succ_le {a b : Cardinal} : succ a ≤ b ↔ a < b :=
  ⟨lt_of_lt_of_leₓ (lt_succ_self _),
    fun h =>
      by 
        exact min_le _ (Subtype.mk b h)⟩

@[simp]
theorem lt_succ {a b : Cardinal} : a < succ b ↔ a ≤ b :=
  by 
    rw [←not_leₓ, succ_le, not_ltₓ]

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem add_one_le_succ (c : cardinal.{u}) : «expr ≤ »(«expr + »(c, 1), succ c) :=
begin
  refine [expr le_min.2 (λ b, _)],
  rcases ["⟨", expr b, ",", expr c, "⟩", "with", "⟨", "⟨", "⟨", ident β, "⟩", ",", ident hlt, "⟩", ",", "⟨", ident γ, "⟩", "⟩"],
  cases [expr hlt.le] ["with", ident f],
  have [] [":", expr «expr¬ »(surjective f)] [":=", expr λ hn, hlt.not_le (mk_le_of_surjective hn)],
  simp [] [] ["only"] ["[", expr surjective, ",", expr not_forall, "]"] [] ["at", ident this],
  rcases [expr this, "with", "⟨", ident b, ",", ident hb, "⟩"],
  calc
    «expr = »(«expr + »(«expr#»() γ, 1), «expr#»() (option γ)) : mk_option.symm
    «expr ≤ »(..., «expr#»() β) : (f.option_elim b hb).cardinal_le
end

theorem succ_pos (c : Cardinal) : 0 < succ c :=
  by 
    simp 

theorem succ_ne_zero (c : Cardinal) : succ c ≠ 0 :=
  (succ_pos _).ne'

/-- The indexed sum of cardinals is the cardinality of the
  indexed disjoint union, i.e. sigma type. -/
def Sum {ι} (f : ι → Cardinal) : Cardinal :=
  mk (Σi, (f i).out)

theorem le_sum {ι} (f : ι → Cardinal) i : f i ≤ Sum f :=
  by 
    rw [←Quotientₓ.out_eq (f i)] <;>
      exact
        ⟨⟨fun a => ⟨i, a⟩,
            fun a b h =>
              eq_of_heq$
                by 
                  injection h⟩⟩

@[simp]
theorem mk_sigma {ι} (f : ι → Type _) : # (Σi, f i) = Sum fun i => # (f i) :=
  mk_congr$ Equiv.sigmaCongrRight$ fun i => out_mk_equiv.symm

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem sum_const
(ι : Type u)
(a : cardinal.{v}) : «expr = »(sum (λ i : ι, a), «expr * »(lift.{v} («expr#»() ι), lift.{u} a)) :=
«expr $ »(induction_on a, λ
 α, «expr $ »(mk_congr, calc
    «expr ≃ »(«exprΣ , »((i : ι), quotient.out («expr#»() α)), «expr × »(ι, quotient.out («expr#»() α))) : equiv.sigma_equiv_prod _ _
    «expr ≃ »(..., «expr × »(ulift ι, ulift α)) : equiv.ulift.symm.prod_congr (out_mk_equiv.trans equiv.ulift.symm)))

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem sum_const' (ι : Type u) (a : cardinal.{u}) : «expr = »(sum (λ _ : ι, a), «expr * »(«expr#»() ι, a)) :=
by simp [] [] [] [] [] []

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem sum_le_sum {ι} (f g : ι → cardinal) (H : ∀ i, «expr ≤ »(f i, g i)) : «expr ≤ »(sum f, sum g) :=
⟨«expr $ »((embedding.refl _).sigma_map, λ
  i, «expr $ »(classical.choice, by have [] [] [":=", expr H i]; rwa ["[", "<-", expr quot.out_eq (f i), ",", "<-", expr quot.out_eq (g i), "]"] ["at", ident this]))⟩

/-- The indexed supremum of cardinals is the smallest cardinal above
  everything in the family. -/
noncomputable def sup {ι} (f : ι → Cardinal) : Cardinal :=
  @min { c // ∀ i, f i ≤ c } ⟨⟨Sum f, le_sum f⟩⟩ fun a => a.1

theorem le_sup {ι} (f : ι → Cardinal) i : f i ≤ sup f :=
  by 
    dsimp [sup] <;> cases' min_eq _ _ with c hc <;> rw [hc] <;> exact c.2 i

theorem sup_le {ι} {f : ι → Cardinal} {a} : sup f ≤ a ↔ ∀ i, f i ≤ a :=
  ⟨fun h i => le_transₓ (le_sup _ _) h,
    fun h =>
      by 
        dsimp [sup] <;> change a with (⟨a, h⟩ : Subtype _).1 <;> apply min_le⟩

theorem sup_le_sup {ι} (f g : ι → Cardinal) (H : ∀ i, f i ≤ g i) : sup f ≤ sup g :=
  sup_le.2$ fun i => le_transₓ (H i) (le_sup _ _)

theorem sup_le_sum {ι} (f : ι → Cardinal) : sup f ≤ Sum f :=
  sup_le.2$ le_sum _

theorem sum_le_sup {ι : Type u} (f : ι → Cardinal.{u}) : Sum f ≤ # ι*sup.{u, u} f :=
  by 
    rw [←sum_const'] <;> exact sum_le_sum _ _ (le_sup _)

theorem sup_eq_zero {ι} {f : ι → Cardinal} [IsEmpty ι] : sup f = 0 :=
  by 
    rw [←nonpos_iff_eq_zero, sup_le]
    exact isEmptyElim

/-- The indexed product of cardinals is the cardinality of the Pi type
  (dependent product). -/
def Prod {ι : Type u} (f : ι → Cardinal) : Cardinal :=
  # (∀ i, (f i).out)

@[simp]
theorem mk_pi {ι : Type u} (α : ι → Type v) : # (∀ i, α i) = Prod fun i => # (α i) :=
  mk_congr$ Equiv.piCongrRight$ fun i => out_mk_equiv.symm

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem prod_const
(ι : Type u)
(a : cardinal.{v}) : «expr = »(prod (λ i : ι, a), «expr ^ »(lift.{u} a, lift.{v} («expr#»() ι))) :=
«expr $ »(induction_on a, λ
 α, «expr $ »(mk_congr, «expr $ »(equiv.Pi_congr equiv.ulift.symm, λ i, out_mk_equiv.trans equiv.ulift.symm)))

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem prod_const' (ι : Type u) (a : cardinal.{u}) : «expr = »(prod (λ _ : ι, a), «expr ^ »(a, «expr#»() ι)) :=
«expr $ »(induction_on a, λ α, (mk_pi _).symm)

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem prod_le_prod {ι} (f g : ι → cardinal) (H : ∀ i, «expr ≤ »(f i, g i)) : «expr ≤ »(prod f, prod g) :=
⟨«expr $ »(embedding.Pi_congr_right, λ
  i, «expr $ »(classical.choice, by have [] [] [":=", expr H i]; rwa ["[", "<-", expr mk_out (f i), ",", "<-", expr mk_out (g i), "]"] ["at", ident this]))⟩

@[simp]
theorem prod_eq_zero {ι} (f : ι → Cardinal.{u}) : Prod f = 0 ↔ ∃ i, f i = 0 :=
  by 
    lift f to ι → Type u using fun _ => trivialₓ 
    simp only [mk_eq_zero_iff, ←mk_pi, is_empty_pi]

theorem prod_ne_zero {ι} (f : ι → Cardinal) : Prod f ≠ 0 ↔ ∀ i, f i ≠ 0 :=
  by 
    simp [prod_eq_zero]

@[simp]
theorem lift_prod {ι : Type u} (c : ι → Cardinal.{v}) : lift.{w} (Prod c) = Prod fun i => lift.{w} (c i) :=
  by 
    lift c to ι → Type v using fun _ => trivialₓ 
    simp only [←mk_pi, ←mk_ulift]
    exact mk_congr (equiv.ulift.trans$ Equiv.piCongrRight$ fun i => equiv.ulift.symm)

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp] theorem lift_min {ι I} (f : ι → cardinal) : «expr = »(lift (min I f), min I «expr ∘ »(lift, f)) :=
«expr $ »(le_antisymm «expr $ »(le_min.2, λ
  a, «expr $ »(lift_le.2, min_le _ a)), let ⟨i, e⟩ := min_eq I «expr ∘ »(lift, f) in
 by rw [expr e] []; exact [expr lift_le.2 «expr $ »(le_min.2, λ
   j, «expr $ »(lift_le.1, by have [] [] [":=", expr min_le «expr ∘ »(lift, f) j]; rwa [expr e] ["at", ident this]))])

theorem lift_down {a : Cardinal.{u}} {b : Cardinal.{max u v}} : b ≤ lift a → ∃ a', lift a' = b :=
  induction_on₂ a b$
    fun α β =>
      by 
        rw [←lift_id (# β), ←lift_umax, ←lift_umax.{u, v}, lift_mk_le] <;>
          exact
            fun ⟨f⟩ =>
              ⟨# (Set.Range f),
                Eq.symm$
                  lift_mk_eq.2
                    ⟨embedding.equiv_of_surjective (embedding.cod_restrict _ f Set.mem_range_self)$
                        fun ⟨a, ⟨b, e⟩⟩ => ⟨b, Subtype.eq e⟩⟩⟩

theorem le_lift_iff {a : Cardinal.{u}} {b : Cardinal.{max u v}} : b ≤ lift a ↔ ∃ a', lift a' = b ∧ a' ≤ a :=
  ⟨fun h =>
      let ⟨a', e⟩ := lift_down h
      ⟨a', e, lift_le.1$ e.symm ▸ h⟩,
    fun ⟨a', e, h⟩ => e ▸ lift_le.2 h⟩

theorem lt_lift_iff {a : Cardinal.{u}} {b : Cardinal.{max u v}} : b < lift a ↔ ∃ a', lift a' = b ∧ a' < a :=
  ⟨fun h =>
      let ⟨a', e⟩ := lift_down (le_of_ltₓ h)
      ⟨a', e, lift_lt.1$ e.symm ▸ h⟩,
    fun ⟨a', e, h⟩ => e ▸ lift_lt.2 h⟩

@[simp]
theorem lift_succ a : lift (succ a) = succ (lift a) :=
  le_antisymmₓ
    (le_of_not_gtₓ$
      fun h =>
        by 
          rcases lt_lift_iff.1 h with ⟨b, e, h⟩
          rw [lt_succ, ←lift_le, e] at h 
          exact not_lt_of_le h (lt_succ_self _))
    (succ_le.2$ lift_lt.2$ lt_succ_self _)

@[simp]
theorem lift_max {a : Cardinal.{u}} {b : Cardinal.{v}} :
  lift.{max v w} a = lift.{max u w} b ↔ lift.{v} a = lift.{u} b :=
  calc lift.{max v w} a = lift.{max u w} b ↔ lift.{w} (lift.{v} a) = lift.{w} (lift.{u} b) :=
    by 
      simp 
    _ ↔ lift.{v} a = lift.{u} b := lift_inj
    

protected theorem le_sup_iff {ι : Type v} {f : ι → Cardinal.{max v w}} {c : Cardinal} :
  c ≤ sup f ↔ ∀ b, (∀ i, f i ≤ b) → c ≤ b :=
  ⟨fun h b hb => le_transₓ h (sup_le.mpr hb), fun h => h _$ fun i => le_sup f i⟩

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The lift of a supremum is the supremum of the lifts. -/
theorem lift_sup
{ι : Type v}
(f : ι → cardinal.{max v w}) : «expr = »(lift.{u} (sup.{v, w} f), sup.{v, max u w} (λ i : ι, lift.{u} (f i))) :=
begin
  apply [expr le_antisymm],
  { rw ["[", expr cardinal.le_sup_iff, "]"] [],
    intros [ident c, ident hc],
    by_contra [ident h],
    obtain ["⟨", ident d, ",", ident rfl, "⟩", ":=", expr cardinal.lift_down (not_le.mp h).le],
    simp [] [] ["only"] ["[", expr lift_le, ",", expr sup_le, "]"] [] ["at", ident h, ident hc],
    exact [expr h hc] },
  { simp [] [] ["only"] ["[", expr cardinal.sup_le, ",", expr lift_le, ",", expr le_sup, ",", expr implies_true_iff, "]"] [] [] }
end

/-- To prove that the lift of a supremum is bounded by some cardinal `t`,
it suffices to show that the lift of each cardinal is bounded by `t`. -/
theorem lift_sup_le {ι : Type v} (f : ι → Cardinal.{max v w}) (t : Cardinal.{max u v w}) (w : ∀ i, lift.{u} (f i) ≤ t) :
  lift.{u} (sup f) ≤ t :=
  by 
    rw [lift_sup]
    exact sup_le.mpr w

@[simp]
theorem lift_sup_le_iff {ι : Type v} (f : ι → Cardinal.{max v w}) (t : Cardinal.{max u v w}) :
  lift.{u} (sup f) ≤ t ↔ ∀ i, lift.{u} (f i) ≤ t :=
  ⟨fun h i => (lift_le.mpr (le_sup f i)).trans h, fun h => lift_sup_le f t h⟩

universe v' w'

/--
To prove an inequality between the lifts to a common universe of two different supremums,
it suffices to show that the lift of each cardinal from the smaller supremum
if bounded by the lift of some cardinal from the larger supremum.
-/
theorem lift_sup_le_lift_sup {ι : Type v} {ι' : Type v'} (f : ι → Cardinal.{max v w}) (f' : ι' → Cardinal.{max v' w'})
  (g : ι → ι') (h : ∀ i, lift.{max v' w'} (f i) ≤ lift.{max v w} (f' (g i))) :
  lift.{max v' w'} (sup f) ≤ lift.{max v w} (sup f') :=
  by 
    apply lift_sup_le.{max v' w'} f 
    intro i 
    apply le_transₓ (h i)
    simp only [lift_le]
    apply le_sup

/-- A variant of `lift_sup_le_lift_sup` with universes specialized via `w = v` and `w' = v'`.
This is sometimes necessary to avoid universe unification issues. -/
theorem lift_sup_le_lift_sup' {ι : Type v} {ι' : Type v'} (f : ι → Cardinal.{v}) (f' : ι' → Cardinal.{v'}) (g : ι → ι')
  (h : ∀ i, lift.{v'} (f i) ≤ lift.{v} (f' (g i))) : lift.{v'} (sup.{v, v} f) ≤ lift.{v} (sup.{v', v'} f') :=
  lift_sup_le_lift_sup f f' g h

/-- `ω` is the smallest infinite cardinal, also known as ℵ₀. -/
def omega : Cardinal.{u} :=
  lift (# ℕ)

localized [Cardinal] notation "ω" => Cardinal.omega

theorem mk_nat : # ℕ = ω :=
  (lift_id _).symm

theorem omega_ne_zero : ω ≠ 0 :=
  mk_ne_zero _

theorem omega_pos : 0 < ω :=
  pos_iff_ne_zero.2 omega_ne_zero

@[simp]
theorem lift_omega : lift ω = ω :=
  lift_lift _

@[simp]
theorem omega_le_lift {c : Cardinal.{u}} : ω ≤ lift.{v} c ↔ ω ≤ c :=
  by 
    rw [←lift_omega, lift_le]

@[simp]
theorem lift_le_omega {c : Cardinal.{u}} : lift.{v} c ≤ ω ↔ c ≤ ω :=
  by 
    rw [←lift_omega, lift_le]

/-! ### Properties about the cast from `ℕ` -/


@[simp]
theorem mk_fin (n : ℕ) : # (Finₓ n) = n :=
  by 
    simp 

@[simp]
theorem lift_nat_cast (n : ℕ) : lift.{u} (n : Cardinal.{v}) = n :=
  by 
    induction n <;> simp 

@[simp]
theorem lift_eq_nat_iff {a : Cardinal.{u}} {n : ℕ} : lift.{v} a = n ↔ a = n :=
  lift_injective.eq_iff' (lift_nat_cast n)

@[simp]
theorem nat_eq_lift_iff {n : ℕ} {a : Cardinal.{u}} : (n : Cardinal) = lift.{v} a ↔ (n : Cardinal) = a :=
  by 
    rw [←lift_nat_cast.{v} n, lift_inj]

theorem lift_mk_fin (n : ℕ) : lift (# (Finₓ n)) = n :=
  by 
    simp 

theorem mk_finset {α : Type u} {s : Finset α} : # s = «expr↑ » (Finset.card s) :=
  by 
    simp 

theorem card_le_of_finset {α} (s : Finset α) : (s.card : Cardinal) ≤ # α :=
  by 
    rw [(_ : (s.card : Cardinal) = # s)]
    ·
      exact ⟨Function.Embedding.subtype _⟩
    rw [Cardinal.mk_fintype, Fintype.card_coe]

@[simp, normCast]
theorem nat_cast_pow {m n : ℕ} : («expr↑ » (pow m n) : Cardinal) = (m^n) :=
  by 
    induction n <;> simp [pow_succ'ₓ, power_add]

@[simp, normCast]
theorem nat_cast_le {m n : ℕ} : (m : Cardinal) ≤ n ↔ m ≤ n :=
  by 
    rw [←lift_mk_fin, ←lift_mk_fin, lift_le] <;>
      exact
        ⟨fun ⟨⟨f, hf⟩⟩ =>
            by 
              simpa only [Fintype.card_fin] using Fintype.card_le_of_injective f hf,
          fun h => ⟨(Finₓ.castLe h).toEmbedding⟩⟩

@[simp, normCast]
theorem nat_cast_lt {m n : ℕ} : (m : Cardinal) < n ↔ m < n :=
  by 
    simp [lt_iff_le_not_leₓ, -not_leₓ]

instance  : CharZero Cardinal :=
  ⟨StrictMono.injective$ fun m n => nat_cast_lt.2⟩

theorem nat_cast_inj {m n : ℕ} : (m : Cardinal) = n ↔ m = n :=
  Nat.cast_inj

theorem nat_cast_injective : injective (coeₓ : ℕ → Cardinal) :=
  Nat.cast_injective

@[simp, normCast]
theorem nat_succ (n : ℕ) : (n.succ : Cardinal) = succ n :=
  le_antisymmₓ (add_one_le_succ _) (succ_le.2$ nat_cast_lt.2$ Nat.lt_succ_selfₓ _)

@[simp]
theorem succ_zero : succ 0 = 1 :=
  by 
    normCast

theorem card_le_of {α : Type u} {n : ℕ} (H : ∀ (s : Finset α), s.card ≤ n) : # α ≤ n :=
  by 
    refine' lt_succ.1 (lt_of_not_geₓ$ fun hn => _)
    rw [←Cardinal.nat_succ, ←Cardinal.lift_mk_fin n.succ] at hn 
    cases' hn with f 
    refine' not_lt_of_le (H$ finset.univ.map f) _ 
    rw [Finset.card_map, ←Fintype.card, Fintype.card_ulift, Fintype.card_fin]
    exact n.lt_succ_self

theorem cantor' a {b : Cardinal} (hb : 1 < b) : a < (b^a) :=
  by 
    rw [←succ_le,
        (by 
          normCast :
        succ 1 = 2)] at
        hb <;>
      exact lt_of_lt_of_leₓ (cantor _) (power_le_power_right hb)

theorem one_le_iff_pos {c : Cardinal} : 1 ≤ c ↔ 0 < c :=
  by 
    rw [←succ_zero, succ_le]

theorem one_le_iff_ne_zero {c : Cardinal} : 1 ≤ c ↔ c ≠ 0 :=
  by 
    rw [one_le_iff_pos, pos_iff_ne_zero]

theorem nat_lt_omega (n : ℕ) : (n : Cardinal.{u}) < ω :=
  succ_le.1$
    by 
      rw [←nat_succ, ←lift_mk_fin, omega, lift_mk_le.{0, 0, u}] <;> exact ⟨⟨coeₓ, fun a b => Finₓ.ext⟩⟩

@[simp]
theorem one_lt_omega : 1 < ω :=
  by 
    simpa using nat_lt_omega 1

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem lt_omega {c : cardinal.{u}} : «expr ↔ »(«expr < »(c, exprω()), «expr∃ , »((n : exprℕ()), «expr = »(c, n))) :=
⟨λ h, begin
   rcases [expr lt_lift_iff.1 h, "with", "⟨", ident c, ",", ident rfl, ",", ident h', "⟩"],
   rcases [expr le_mk_iff_exists_set.1 h'.1, "with", "⟨", ident S, ",", ident rfl, "⟩"],
   suffices [] [":", expr finite S],
   { lift [expr S] ["to", expr finset exprℕ()] ["using", expr this] [],
     simp [] [] [] [] [] [] },
   contrapose ["!"] [ident h'],
   haveI [] [] [":=", expr infinite.to_subtype h'],
   exact [expr ⟨infinite.nat_embedding S⟩]
 end, λ ⟨n, e⟩, «expr ▸ »(e.symm, nat_lt_omega _)⟩

theorem omega_le {c : Cardinal.{u}} : ω ≤ c ↔ ∀ (n : ℕ), (n : Cardinal) ≤ c :=
  ⟨fun h n => le_transₓ (le_of_ltₓ (nat_lt_omega _)) h,
    fun h =>
      le_of_not_ltₓ$
        fun hn =>
          by 
            rcases lt_omega.1 hn with ⟨n, rfl⟩
            exact not_le_of_lt (Nat.lt_succ_selfₓ _) (nat_cast_le.1 (h (n+1)))⟩

theorem lt_omega_iff_fintype {α : Type u} : # α < ω ↔ Nonempty (Fintype α) :=
  lt_omega.trans
    ⟨fun ⟨n, e⟩ =>
        by 
          rw [←lift_mk_fin n] at e 
          cases' Quotientₓ.exact e with f 
          exact ⟨Fintype.ofEquiv _ f.symm⟩,
      fun ⟨_⟩ =>
        by 
          exact ⟨_, mk_fintype _⟩⟩

theorem lt_omega_iff_finite {α} {S : Set α} : # S < ω ↔ finite S :=
  lt_omega_iff_fintype.trans finite_def.symm

instance can_lift_cardinal_nat : CanLift Cardinal ℕ :=
  ⟨coeₓ, fun x => x < ω,
    fun x hx =>
      let ⟨n, hn⟩ := lt_omega.mp hx
      ⟨n, hn.symm⟩⟩

theorem add_lt_omega {a b : Cardinal} (ha : a < ω) (hb : b < ω) : (a+b) < ω :=
  match a, b, lt_omega.1 ha, lt_omega.1 hb with 
  | _, _, ⟨m, rfl⟩, ⟨n, rfl⟩ =>
    by 
      rw [←Nat.cast_add] <;> apply nat_lt_omega

theorem add_lt_omega_iff {a b : Cardinal} : (a+b) < ω ↔ a < ω ∧ b < ω :=
  ⟨fun h => ⟨lt_of_le_of_ltₓ (self_le_add_right _ _) h, lt_of_le_of_ltₓ (self_le_add_left _ _) h⟩,
    fun ⟨h1, h2⟩ => add_lt_omega h1 h2⟩

theorem omega_le_add_iff {a b : Cardinal} : (ω ≤ a+b) ↔ ω ≤ a ∨ ω ≤ b :=
  by 
    simp only [←not_ltₓ, add_lt_omega_iff, not_and_distrib]

theorem mul_lt_omega {a b : Cardinal} (ha : a < ω) (hb : b < ω) : (a*b) < ω :=
  match a, b, lt_omega.1 ha, lt_omega.1 hb with 
  | _, _, ⟨m, rfl⟩, ⟨n, rfl⟩ =>
    by 
      rw [←Nat.cast_mul] <;> apply nat_lt_omega

theorem mul_lt_omega_iff {a b : Cardinal} : (a*b) < ω ↔ a = 0 ∨ b = 0 ∨ a < ω ∧ b < ω :=
  by 
    split 
    ·
      intro h 
      byCases' ha : a = 0
      ·
        left 
        exact ha 
      right 
      byCases' hb : b = 0
      ·
        left 
        exact hb 
      right 
      rw [←Ne, ←one_le_iff_ne_zero] at ha hb 
      split 
      ·
        rw [←mul_oneₓ a]
        refine' lt_of_le_of_ltₓ (mul_le_mul' (le_reflₓ a) hb) h
      ·
        rw [←one_mulₓ b]
        refine' lt_of_le_of_ltₓ (mul_le_mul' ha (le_reflₓ b)) h 
    rintro (rfl | rfl | ⟨ha, hb⟩) <;> simp only [mul_lt_omega, omega_pos, zero_mul, mul_zero]

theorem mul_lt_omega_iff_of_ne_zero {a b : Cardinal} (ha : a ≠ 0) (hb : b ≠ 0) : (a*b) < ω ↔ a < ω ∧ b < ω :=
  by 
    simp [mul_lt_omega_iff, ha, hb]

theorem power_lt_omega {a b : Cardinal} (ha : a < ω) (hb : b < ω) : (a^b) < ω :=
  match a, b, lt_omega.1 ha, lt_omega.1 hb with 
  | _, _, ⟨m, rfl⟩, ⟨n, rfl⟩ =>
    by 
      rw [←nat_cast_pow] <;> apply nat_lt_omega

theorem eq_one_iff_unique {α : Type _} : # α = 1 ↔ Subsingleton α ∧ Nonempty α :=
  calc # α = 1 ↔ # α ≤ 1 ∧ ¬# α < 1 := eq_iff_le_not_lt 
    _ ↔ Subsingleton α ∧ Nonempty α :=
    by 
      apply and_congr le_one_iff_subsingleton 
      pushNeg 
      rw [one_le_iff_ne_zero, mk_ne_zero_iff]
    

theorem infinite_iff {α : Type u} : Infinite α ↔ ω ≤ # α :=
  by 
    rw [←not_ltₓ, lt_omega_iff_fintype, not_nonempty_iff, is_empty_fintype]

@[simp]
theorem omega_le_mk (α : Type u) [Infinite α] : ω ≤ # α :=
  infinite_iff.1 ‹_›

theorem encodable_iff {α : Type u} : Nonempty (Encodable α) ↔ # α ≤ ω :=
  ⟨fun ⟨h⟩ => ⟨(@Encodable.encode' α h).trans Equiv.ulift.symm.toEmbedding⟩,
    fun ⟨h⟩ => ⟨Encodable.ofInj _ (h.trans Equiv.ulift.toEmbedding).Injective⟩⟩

@[simp]
theorem mk_le_omega [Encodable α] : # α ≤ ω :=
  encodable_iff.1 ⟨‹_›⟩

theorem denumerable_iff {α : Type u} : Nonempty (Denumerable α) ↔ # α = ω :=
  ⟨fun ⟨h⟩ => mk_congr ((@Denumerable.eqv α h).trans Equiv.ulift.symm),
    fun h =>
      by 
        cases' Quotientₓ.exact h with f 
        exact ⟨Denumerable.mk'$ f.trans Equiv.ulift⟩⟩

@[simp]
theorem mk_denumerable (α : Type u) [Denumerable α] : # α = ω :=
  denumerable_iff.1 ⟨‹_›⟩

@[simp]
theorem mk_set_le_omega (s : Set α) : # s ≤ ω ↔ countable s :=
  by 
    rw [countable_iff_exists_injective]
    split 
    ·
      rintro ⟨f'⟩
      cases' embedding.trans f' equiv.ulift.to_embedding with f hf 
      exact ⟨f, hf⟩
    ·
      rintro ⟨f, hf⟩
      exact ⟨embedding.trans ⟨f, hf⟩ equiv.ulift.symm.to_embedding⟩

@[simp]
theorem omega_add_omega : (ω+ω) = ω :=
  mk_denumerable _

theorem omega_mul_omega : (ω*ω) = ω :=
  mk_denumerable _

@[simp]
theorem add_le_omega {c₁ c₂ : Cardinal} : (c₁+c₂) ≤ ω ↔ c₁ ≤ ω ∧ c₂ ≤ ω :=
  ⟨fun h => ⟨le_self_add.trans h, le_add_self.trans h⟩, fun h => omega_add_omega ▸ add_le_add h.1 h.2⟩

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- This function sends finite cardinals to the corresponding natural, and infinite cardinals
  to 0. -/ noncomputable def to_nat : zero_hom cardinal exprℕ() :=
⟨λ c, if h : «expr < »(c, omega.{v}) then classical.some (lt_omega.1 h) else 0, begin
   have [ident h] [":", expr «expr < »(0, exprω())] [":=", expr nat_lt_omega 0],
   rw ["[", expr dif_pos h, ",", "<-", expr cardinal.nat_cast_inj, ",", "<-", expr classical.some_spec (lt_omega.1 h), ",", expr nat.cast_zero, "]"] []
 end⟩

theorem to_nat_apply_of_lt_omega {c : Cardinal} (h : c < ω) : c.to_nat = Classical.some (lt_omega.1 h) :=
  dif_pos h

@[simp]
theorem to_nat_apply_of_omega_le {c : Cardinal} (h : ω ≤ c) : c.to_nat = 0 :=
  dif_neg (not_lt_of_le h)

@[simp]
theorem cast_to_nat_of_lt_omega {c : Cardinal} (h : c < ω) : «expr↑ » c.to_nat = c :=
  by 
    rw [to_nat_apply_of_lt_omega h, ←Classical.some_spec (lt_omega.1 h)]

@[simp]
theorem cast_to_nat_of_omega_le {c : Cardinal} (h : ω ≤ c) : «expr↑ » c.to_nat = (0 : Cardinal) :=
  by 
    rw [to_nat_apply_of_omega_le h, Nat.cast_zero]

@[simp]
theorem to_nat_cast (n : ℕ) : Cardinal.toNat n = n :=
  by 
    rw [to_nat_apply_of_lt_omega (nat_lt_omega n), ←nat_cast_inj]
    exact (Classical.some_spec (lt_omega.1 (nat_lt_omega n))).symm

/-- `to_nat` has a right-inverse: coercion. -/
theorem to_nat_right_inverse : Function.RightInverse (coeₓ : ℕ → Cardinal) to_nat :=
  to_nat_cast

theorem to_nat_surjective : surjective to_nat :=
  to_nat_right_inverse.Surjective

@[simp]
theorem mk_to_nat_of_infinite [h : Infinite α] : (# α).toNat = 0 :=
  dif_neg (not_lt_of_le (infinite_iff.1 h))

theorem mk_to_nat_eq_card [Fintype α] : (# α).toNat = Fintype.card α :=
  by 
    simp 

@[simp]
theorem zero_to_nat : to_nat 0 = 0 :=
  by 
    rw [←to_nat_cast 0, Nat.cast_zero]

@[simp]
theorem one_to_nat : to_nat 1 = 1 :=
  by 
    rw [←to_nat_cast 1, Nat.cast_one]

@[simp]
theorem to_nat_eq_one {c : Cardinal} : to_nat c = 1 ↔ c = 1 :=
  ⟨fun h =>
      (cast_to_nat_of_lt_omega (lt_of_not_geₓ (one_ne_zero ∘ h.symm.trans ∘ to_nat_apply_of_omega_le))).symm.trans
        ((congr_argₓ coeₓ h).trans Nat.cast_one),
    fun h => (congr_argₓ to_nat h).trans one_to_nat⟩

theorem to_nat_eq_one_iff_unique {α : Type _} : (# α).toNat = 1 ↔ Subsingleton α ∧ Nonempty α :=
  to_nat_eq_one.trans eq_one_iff_unique

@[simp]
theorem to_nat_lift (c : Cardinal.{v}) : (lift.{u, v} c).toNat = c.to_nat :=
  by 
    apply nat_cast_injective 
    cases' lt_or_geₓ c ω with hc hc
    ·
      rw [cast_to_nat_of_lt_omega, ←lift_nat_cast, cast_to_nat_of_lt_omega hc]
      rwa [←lift_omega, lift_lt]
    ·
      rw [cast_to_nat_of_omega_le, ←lift_nat_cast, cast_to_nat_of_omega_le hc, lift_zero]
      rwa [←lift_omega, lift_le]

theorem to_nat_congr {β : Type v} (e : α ≃ β) : (# α).toNat = (# β).toNat :=
  by 
    rw [←to_nat_lift, lift_mk_eq.mpr ⟨e⟩, to_nat_lift]

@[simp]
theorem to_nat_mul (x y : Cardinal) : (x*y).toNat = x.to_nat*y.to_nat :=
  by 
    byCases' hx1 : x = 0
    ·
      rw [CommSemiringₓ.mul_comm, hx1, mul_zero, zero_to_nat, Nat.zero_mul]
    byCases' hy1 : y = 0
    ·
      rw [hy1, zero_to_nat, mul_zero, mul_zero, zero_to_nat]
    refine' nat_cast_injective (Eq.trans _ (Nat.cast_mul _ _).symm)
    cases' lt_or_geₓ x ω with hx2 hx2
    ·
      cases' lt_or_geₓ y ω with hy2 hy2
      ·
        rw [cast_to_nat_of_lt_omega, cast_to_nat_of_lt_omega hx2, cast_to_nat_of_lt_omega hy2]
        exact mul_lt_omega hx2 hy2
      ·
        rw [cast_to_nat_of_omega_le hy2, mul_zero, cast_to_nat_of_omega_le]
        exact not_lt.mp (mt (mul_lt_omega_iff_of_ne_zero hx1 hy1).mp fun h => not_lt.mpr hy2 h.2)
    ·
      rw [cast_to_nat_of_omega_le hx2, zero_mul, cast_to_nat_of_omega_le]
      exact not_lt.mp (mt (mul_lt_omega_iff_of_ne_zero hx1 hy1).mp fun h => not_lt.mpr hx2 h.1)

@[simp]
theorem to_nat_add_of_lt_omega {a : Cardinal.{u}} {b : Cardinal.{v}} (ha : a < ω) (hb : b < ω) :
  (lift.{v, u} a+lift.{u, v} b).toNat = a.to_nat+b.to_nat :=
  by 
    apply Cardinal.nat_cast_injective 
    replace ha : lift.{v, u} a < ω :=
      by 
        rw [←lift_omega]
        exact lift_lt.2 ha 
    replace hb : lift.{u, v} b < ω :=
      by 
        rw [←lift_omega]
        exact lift_lt.2 hb 
    rw [Nat.cast_add, ←to_nat_lift.{v, u} a, ←to_nat_lift.{u, v} b, cast_to_nat_of_lt_omega ha,
      cast_to_nat_of_lt_omega hb, cast_to_nat_of_lt_omega (add_lt_omega ha hb)]

/-- This function sends finite cardinals to the corresponding natural, and infinite cardinals
  to `⊤`. -/
noncomputable def to_enat : Cardinal →+ Enat :=
  { toFun := fun c => if c < omega.{v} then c.to_nat else ⊤,
    map_zero' :=
      by 
        simp [if_pos (lt_transₓ zero_lt_one one_lt_omega)],
    map_add' :=
      fun x y =>
        by 
          byCases' hx : x < ω
          ·
            obtain ⟨x0, rfl⟩ := lt_omega.1 hx 
            byCases' hy : y < ω
            ·
              obtain ⟨y0, rfl⟩ := lt_omega.1 hy 
              simp only [add_lt_omega hx hy, hx, hy, to_nat_cast, if_true]
              rw [←Nat.cast_add, to_nat_cast, Nat.cast_add]
            ·
              rw [if_neg hy, if_neg, Enat.add_top]
              contrapose! hy 
              apply lt_of_le_of_ltₓ le_add_self hy
          ·
            rw [if_neg hx, if_neg, Enat.top_add]
            contrapose! hx 
            apply lt_of_le_of_ltₓ le_self_add hx }

@[simp]
theorem to_enat_apply_of_lt_omega {c : Cardinal} (h : c < ω) : c.to_enat = c.to_nat :=
  if_pos h

@[simp]
theorem to_enat_apply_of_omega_le {c : Cardinal} (h : ω ≤ c) : c.to_enat = ⊤ :=
  if_neg (not_lt_of_le h)

@[simp]
theorem to_enat_cast (n : ℕ) : Cardinal.toEnat n = n :=
  by 
    rw [to_enat_apply_of_lt_omega (nat_lt_omega n), to_nat_cast]

@[simp]
theorem mk_to_enat_of_infinite [h : Infinite α] : (# α).toEnat = ⊤ :=
  to_enat_apply_of_omega_le (infinite_iff.1 h)

theorem to_enat_surjective : surjective to_enat :=
  by 
    intro x 
    exact Enat.cases_on x ⟨ω, to_enat_apply_of_omega_le (le_reflₓ ω)⟩ fun n => ⟨n, to_enat_cast n⟩

theorem mk_to_enat_eq_coe_card [Fintype α] : (# α).toEnat = Fintype.card α :=
  by 
    simp 

theorem mk_int : # ℤ = ω :=
  mk_denumerable ℤ

theorem mk_pnat : # ℕ+ = ω :=
  mk_denumerable ℕ+

theorem two_le_iff : (2 : Cardinal) ≤ # α ↔ ∃ x y : α, x ≠ y :=
  by 
    split 
    ·
      rintro ⟨f⟩
      refine' ⟨f$ Sum.inl ⟨⟩, f$ Sum.inr ⟨⟩, _⟩
      intro h 
      cases f.2 h
    ·
      rintro ⟨x, y, h⟩
      byContra h' 
      rw [not_leₓ, ←Nat.cast_two, nat_succ, lt_succ, Nat.cast_one, le_one_iff_subsingleton] at h' 
      apply h 
      exact Subsingleton.elimₓ _ _

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem two_le_iff' (x : α) : «expr ↔ »(«expr ≤ »((2 : cardinal), «expr#»() α), «expr∃ , »((y : α), «expr ≠ »(x, y))) :=
begin
  rw ["[", expr two_le_iff, "]"] [],
  split,
  { rintro ["⟨", ident y, ",", ident z, ",", ident h, "⟩"],
    refine [expr classical.by_cases (λ h' : «expr = »(x, y), _) (λ h', ⟨y, h'⟩)],
    rw ["[", "<-", expr h', "]"] ["at", ident h],
    exact [expr ⟨z, h⟩] },
  { rintro ["⟨", ident y, ",", ident h, "⟩"],
    exact [expr ⟨x, y, h⟩] }
end

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- **König's theorem** -/
theorem sum_lt_prod {ι} (f g : ι → cardinal) (H : ∀ i, «expr < »(f i, g i)) : «expr < »(sum f, prod g) :=
«expr $ »(lt_of_not_ge, λ ⟨F⟩, begin
   haveI [] [":", expr inhabited (∀ i : ι, (g i).out)] [],
   { refine [expr ⟨λ i, «expr $ »(classical.choice, mk_ne_zero_iff.1 _)⟩],
     rw [expr mk_out] [],
     exact [expr (H i).ne_bot] },
   let [ident G] [] [":=", expr inv_fun F],
   have [ident sG] [":", expr surjective G] [":=", expr inv_fun_surjective F.2],
   choose [] [ident C] [ident hc] ["using", expr show ∀
    i, «expr∃ , »((b), ∀ a, «expr ≠ »(G ⟨i, a⟩ i, b)), { assume [binders (i)],
      simp [] [] ["only"] ["[", "-", ident not_exists, ",", expr not_exists.symm, ",", expr not_forall.symm, "]"] [] [],
      refine [expr λ h, not_le_of_lt (H i) _],
      rw ["[", "<-", expr mk_out (f i), ",", "<-", expr mk_out (g i), "]"] [],
      exact [expr ⟨embedding.of_surjective _ h⟩] }],
   exact [expr let ⟨⟨i, a⟩, h⟩ := sG C in hc i a (congr_fun h _)]
 end)

@[simp]
theorem mk_empty : # Empty = 0 :=
  mk_eq_zero _

@[simp]
theorem mk_pempty : # Pempty = 0 :=
  mk_eq_zero _

@[simp]
theorem mk_punit : # PUnit = 1 :=
  mk_eq_one PUnit

theorem mk_unit : # Unit = 1 :=
  mk_punit

@[simp]
theorem mk_singleton {α : Type u} (x : α) : # ({x} : Set α) = 1 :=
  mk_eq_one _

@[simp]
theorem mk_plift_true : # (Plift True) = 1 :=
  mk_eq_one _

@[simp]
theorem mk_plift_false : # (Plift False) = 0 :=
  mk_eq_zero _

@[simp]
theorem mk_vector (α : Type u) (n : ℕ) : # (Vector α n) = # α ^ℕ n :=
  (mk_congr (Equiv.vectorEquivFin α n)).trans$
    by 
      simp 

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem mk_list_eq_sum_pow
(α : Type u) : «expr = »(«expr#»() (list α), sum (λ n : exprℕ(), «expr ^ℕ »(«expr#»() α, n))) :=
calc
  «expr = »(«expr#»() (list α), «expr#»() «exprΣ , »((n), vector α n)) : mk_congr (equiv.sigma_preimage_equiv list.length).symm
  «expr = »(..., sum (λ n : exprℕ(), «expr ^ℕ »(«expr#»() α, n))) : by simp [] [] [] [] [] []

theorem mk_quot_le {α : Type u} {r : α → α → Prop} : # (Quot r) ≤ # α :=
  mk_le_of_surjective Quot.exists_rep

theorem mk_quotient_le {α : Type u} {s : Setoidₓ α} : # (Quotientₓ s) ≤ # α :=
  mk_quot_le

theorem mk_subtype_le {α : Type u} (p : α → Prop) : # (Subtype p) ≤ # α :=
  ⟨embedding.subtype p⟩

theorem mk_subtype_le_of_subset {α : Type u} {p q : α → Prop} (h : ∀ ⦃x⦄, p x → q x) : # (Subtype p) ≤ # (Subtype q) :=
  ⟨embedding.subtype_map (embedding.refl α) h⟩

@[simp]
theorem mk_emptyc (α : Type u) : # (∅ : Set α) = 0 :=
  mk_eq_zero _

theorem mk_emptyc_iff {α : Type u} {s : Set α} : # s = 0 ↔ s = ∅ :=
  by 
    split 
    ·
      intro h 
      rw [mk_eq_zero_iff] at h 
      exact eq_empty_iff_forall_not_mem.2 fun x hx => h.elim' ⟨x, hx⟩
    ·
      rintro rfl 
      exact mk_emptyc _

@[simp]
theorem mk_univ {α : Type u} : # (@univ α) = # α :=
  mk_congr (Equiv.Set.univ α)

theorem mk_image_le {α β : Type u} {f : α → β} {s : Set α} : # (f '' s) ≤ # s :=
  mk_le_of_surjective surjective_onto_image

theorem mk_image_le_lift {α : Type u} {β : Type v} {f : α → β} {s : Set α} : lift.{u} (# (f '' s)) ≤ lift.{v} (# s) :=
  lift_mk_le.{v, u, 0}.mpr ⟨embedding.of_surjective _ surjective_onto_image⟩

theorem mk_range_le {α β : Type u} {f : α → β} : # (range f) ≤ # α :=
  mk_le_of_surjective surjective_onto_range

theorem mk_range_le_lift {α : Type u} {β : Type v} {f : α → β} : lift.{u} (# (range f)) ≤ lift.{v} (# α) :=
  lift_mk_le.{v, u, 0}.mpr ⟨embedding.of_surjective _ surjective_onto_range⟩

theorem mk_range_eq (f : α → β) (h : injective f) : # (range f) = # α :=
  mk_congr (Equiv.ofInjective f h).symm

theorem mk_range_eq_of_injective {α : Type u} {β : Type v} {f : α → β} (hf : injective f) :
  lift.{u} (# (range f)) = lift.{v} (# α) :=
  lift_mk_eq'.mpr ⟨(Equiv.ofInjective f hf).symm⟩

theorem mk_range_eq_lift {α : Type u} {β : Type v} {f : α → β} (hf : injective f) :
  lift.{max u w} (# (range f)) = lift.{max v w} (# α) :=
  lift_mk_eq.mpr ⟨(Equiv.ofInjective f hf).symm⟩

theorem mk_image_eq {α β : Type u} {f : α → β} {s : Set α} (hf : injective f) : # (f '' s) = # s :=
  mk_congr (Equiv.Set.image f s hf).symm

theorem mk_Union_le_sum_mk {α ι : Type u} {f : ι → Set α} : # (⋃i, f i) ≤ Sum fun i => # (f i) :=
  calc # (⋃i, f i) ≤ # (Σi, f i) := mk_le_of_surjective (Set.sigma_to_Union_surjective f)
    _ = Sum fun i => # (f i) := mk_sigma _
    

theorem mk_Union_eq_sum_mk {α ι : Type u} {f : ι → Set α} (h : ∀ i j, i ≠ j → Disjoint (f i) (f j)) :
  # (⋃i, f i) = Sum fun i => # (f i) :=
  calc # (⋃i, f i) = # (Σi, f i) := mk_congr (Set.unionEqSigmaOfDisjoint h)
    _ = Sum fun i => # (f i) := mk_sigma _
    

theorem mk_Union_le {α ι : Type u} (f : ι → Set α) : # (⋃i, f i) ≤ # ι*Cardinal.sup.{u, u} fun i => # (f i) :=
  le_transₓ mk_Union_le_sum_mk (sum_le_sup _)

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem mk_sUnion_le
{α : Type u}
(A : set (set α)) : «expr ≤ »(«expr#»() «expr⋃₀ »(A), «expr * »(«expr#»() A, cardinal.sup.{u, u} (λ
   s : A, «expr#»() s))) :=
by { rw ["[", expr sUnion_eq_Union, "]"] [],
  apply [expr mk_Union_le] }

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem mk_bUnion_le
{ι α : Type u}
(A : ι → set α)
(s : set ι) : «expr ≤ »(«expr#»() «expr⋃ , »((x «expr ∈ » s), A x), «expr * »(«expr#»() s, cardinal.sup.{u, u} (λ
   x : s, «expr#»() (A x.1)))) :=
by { rw ["[", expr bUnion_eq_Union, "]"] [],
  apply [expr mk_Union_le] }

theorem finset_card_lt_omega (s : Finset α) : # («expr↑ » s : Set α) < ω :=
  by 
    rw [lt_omega_iff_fintype]
    exact ⟨Finset.subtype.fintype s⟩

theorem mk_eq_nat_iff_finset {α} {s : Set α} {n : ℕ} : # s = n ↔ ∃ t : Finset α, (t : Set α) = s ∧ t.card = n :=
  by 
    split 
    ·
      intro h 
      lift s to Finset α using lt_omega_iff_finite.1 (h.symm ▸ nat_lt_omega n)
      simpa using h
    ·
      rintro ⟨t, rfl, rfl⟩
      exact mk_finset

theorem mk_union_add_mk_inter {α : Type u} {S T : Set α} : (# (S ∪ T : Set α)+# (S ∩ T : Set α)) = # S+# T :=
  Quot.sound ⟨Equiv.Set.unionSumInter S T⟩

/-- The cardinality of a union is at most the sum of the cardinalities
of the two sets. -/
theorem mk_union_le {α : Type u} (S T : Set α) : # (S ∪ T : Set α) ≤ # S+# T :=
  @mk_union_add_mk_inter α S T ▸ self_le_add_right (# (S ∪ T : Set α)) (# (S ∩ T : Set α))

theorem mk_union_of_disjoint {α : Type u} {S T : Set α} (H : Disjoint S T) : # (S ∪ T : Set α) = # S+# T :=
  Quot.sound ⟨Equiv.Set.union H⟩

theorem mk_insert {α : Type u} {s : Set α} {a : α} (h : a ∉ s) : # (insert a s : Set α) = # s+1 :=
  by 
    rw [←union_singleton, mk_union_of_disjoint, mk_singleton]
    simpa

theorem mk_sum_compl {α} (s : Set α) : (# s+# («expr ᶜ» s : Set α)) = # α :=
  mk_congr (Equiv.Set.sumCompl s)

theorem mk_le_mk_of_subset {α} {s t : Set α} (h : s ⊆ t) : # s ≤ # t :=
  ⟨Set.embeddingOfSubset s t h⟩

theorem mk_subtype_mono {p q : α → Prop} (h : ∀ x, p x → q x) : # { x // p x } ≤ # { x // q x } :=
  ⟨embedding_of_subset _ _ h⟩

theorem mk_set_le (s : Set α) : # s ≤ # α :=
  mk_subtype_le s

theorem mk_union_le_omega {α} {P Q : Set α} : # (P ∪ Q : Set α) ≤ ω ↔ # P ≤ ω ∧ # Q ≤ ω :=
  by 
    simp 

theorem mk_image_eq_lift {α : Type u} {β : Type v} (f : α → β) (s : Set α) (h : injective f) :
  lift.{u} (# (f '' s)) = lift.{v} (# s) :=
  lift_mk_eq.{v, u, 0}.mpr ⟨(Equiv.Set.image f s h).symm⟩

theorem mk_image_eq_of_inj_on_lift {α : Type u} {β : Type v} (f : α → β) (s : Set α) (h : inj_on f s) :
  lift.{u} (# (f '' s)) = lift.{v} (# s) :=
  lift_mk_eq.{v, u, 0}.mpr ⟨(Equiv.Set.imageOfInjOn f s h).symm⟩

theorem mk_image_eq_of_inj_on {α β : Type u} (f : α → β) (s : Set α) (h : inj_on f s) : # (f '' s) = # s :=
  mk_congr (Equiv.Set.imageOfInjOn f s h).symm

theorem mk_subtype_of_equiv {α β : Type u} (p : β → Prop) (e : α ≃ β) : # { a : α // p (e a) } = # { b : β // p b } :=
  mk_congr (Equiv.subtypeEquivOfSubtype e)

theorem mk_sep (s : Set α) (t : α → Prop) : # ({ x∈s | t x } : Set α) = # { x:s | t x.1 } :=
  mk_congr (Equiv.Set.sep s t)

theorem mk_preimage_of_injective_lift {α : Type u} {β : Type v} (f : α → β) (s : Set β) (h : injective f) :
  lift.{v} (# (f ⁻¹' s)) ≤ lift.{u} (# s) :=
  by 
    rw [lift_mk_le.{u, v, 0}]
    use Subtype.coind (fun x => f x.1) fun x => x.2
    apply Subtype.coind_injective 
    exact h.comp Subtype.val_injective

theorem mk_preimage_of_subset_range_lift {α : Type u} {β : Type v} (f : α → β) (s : Set β) (h : s ⊆ range f) :
  lift.{u} (# s) ≤ lift.{v} (# (f ⁻¹' s)) :=
  by 
    rw [lift_mk_le.{v, u, 0}]
    refine' ⟨⟨_, _⟩⟩
    ·
      rintro ⟨y, hy⟩
      rcases Classical.subtypeOfExists (h hy) with ⟨x, rfl⟩
      exact ⟨x, hy⟩
    rintro ⟨y, hy⟩ ⟨y', hy'⟩
    dsimp 
    rcases Classical.subtypeOfExists (h hy) with ⟨x, rfl⟩
    rcases Classical.subtypeOfExists (h hy') with ⟨x', rfl⟩
    simp 
    intro hxx' 
    rw [hxx']

theorem mk_preimage_of_injective_of_subset_range_lift {β : Type v} (f : α → β) (s : Set β) (h : injective f)
  (h2 : s ⊆ range f) : lift.{v} (# (f ⁻¹' s)) = lift.{u} (# s) :=
  le_antisymmₓ (mk_preimage_of_injective_lift f s h) (mk_preimage_of_subset_range_lift f s h2)

theorem mk_preimage_of_injective (f : α → β) (s : Set β) (h : injective f) : # (f ⁻¹' s) ≤ # s :=
  by 
    convert mk_preimage_of_injective_lift.{u, u} f s h using 1 <;> rw [lift_id]

theorem mk_preimage_of_subset_range (f : α → β) (s : Set β) (h : s ⊆ range f) : # s ≤ # (f ⁻¹' s) :=
  by 
    convert mk_preimage_of_subset_range_lift.{u, u} f s h using 1 <;> rw [lift_id]

theorem mk_preimage_of_injective_of_subset_range (f : α → β) (s : Set β) (h : injective f) (h2 : s ⊆ range f) :
  # (f ⁻¹' s) = # s :=
  by 
    convert mk_preimage_of_injective_of_subset_range_lift.{u, u} f s h h2 using 1 <;> rw [lift_id]

theorem mk_subset_ge_of_subset_image_lift {α : Type u} {β : Type v} (f : α → β) {s : Set α} {t : Set β}
  (h : t ⊆ f '' s) : lift.{u} (# t) ≤ lift.{v} (# ({ x∈s | f x ∈ t } : Set α)) :=
  by 
    rw [image_eq_range] at h 
    convert mk_preimage_of_subset_range_lift _ _ h using 1
    rw [mk_sep]
    rfl

theorem mk_subset_ge_of_subset_image (f : α → β) {s : Set α} {t : Set β} (h : t ⊆ f '' s) :
  # t ≤ # ({ x∈s | f x ∈ t } : Set α) :=
  by 
    rw [image_eq_range] at h 
    convert mk_preimage_of_subset_range _ _ h using 1
    rw [mk_sep]
    rfl

theorem le_mk_iff_exists_subset {c : Cardinal} {α : Type u} {s : Set α} : c ≤ # s ↔ ∃ p : Set α, p ⊆ s ∧ # p = c :=
  by 
    rw [le_mk_iff_exists_set, ←Subtype.exists_set_subtype]
    apply exists_congr 
    intro t 
    rw [mk_image_eq]
    apply Subtype.val_injective

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The function α^{<β}, defined to be sup_{γ < β} α^γ.
  We index over {s : set β.out // #s < β } instead of {γ // γ < β}, because the latter lives in a
  higher universe -/ noncomputable def powerlt (α β : cardinal.{u}) : cardinal.{u} :=
sup.{u, u} (λ s : {s : set β.out // «expr < »(«expr#»() s, β)}, «expr ^ »(α, mk.{u} s))

infixl:80 " ^< " => powerlt

-- error in SetTheory.Cardinal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem powerlt_aux
{c c' : cardinal}
(h : «expr < »(c, c')) : «expr∃ , »((s : {s : set c'.out // «expr < »(«expr#»() s, c')}), «expr = »(«expr#»() s, c)) :=
begin
  cases [expr out_embedding.mp (le_of_lt h)] ["with", ident f],
  have [] [":", expr «expr = »(«expr#»() «expr↥ »(range «expr⇑ »(f)), c)] [],
  { rwa ["[", expr mk_range_eq, ",", expr mk, ",", expr quotient.out_eq c, "]"] [],
    exact [expr f.2] },
  exact [expr ⟨⟨range f, by convert [] [expr h] []⟩, this⟩]
end

theorem le_powerlt {c₁ c₂ c₃ : Cardinal} (h : c₂ < c₃) : (c₁^c₂) ≤ c₁ ^< c₃ :=
  by 
    rcases powerlt_aux h with ⟨s, rfl⟩
    apply le_sup _ s

theorem powerlt_le {c₁ c₂ c₃ : Cardinal} : c₁ ^< c₂ ≤ c₃ ↔ ∀ c₄ (_ : c₄ < c₂), (c₁^c₄) ≤ c₃ :=
  by 
    rw [powerlt, sup_le]
    split 
    ·
      intro h c₄ hc₄ 
      rcases powerlt_aux hc₄ with ⟨s, rfl⟩
      exact h s 
    intro h s 
    exact h _ s.2

theorem powerlt_le_powerlt_left {a b c : Cardinal} (h : b ≤ c) : a ^< b ≤ a ^< c :=
  by 
    rw [powerlt, sup_le]
    rintro ⟨s, hs⟩
    apply le_powerlt 
    exact lt_of_lt_of_leₓ hs h

theorem powerlt_succ {c₁ c₂ : Cardinal} (h : c₁ ≠ 0) : c₁ ^< c₂.succ = (c₁^c₂) :=
  by 
    apply le_antisymmₓ
    ·
      rw [powerlt_le]
      intro c₃ h2 
      apply power_le_power_left h 
      rwa [←lt_succ]
    ·
      apply le_powerlt 
      apply lt_succ_self

theorem powerlt_max {c₁ c₂ c₃ : Cardinal} : c₁ ^< max c₂ c₃ = max (c₁ ^< c₂) (c₁ ^< c₃) :=
  by 
    cases le_totalₓ c₂ c₃ <;> simp only [max_eq_leftₓ, max_eq_rightₓ, h, powerlt_le_powerlt_left]

theorem zero_powerlt {a : Cardinal} (h : a ≠ 0) : 0 ^< a = 1 :=
  by 
    apply le_antisymmₓ
    ·
      rw [powerlt_le]
      intro c hc 
      apply zero_power_le 
    convert le_powerlt (pos_iff_ne_zero.2 h)
    rw [power_zero]

theorem powerlt_zero {a : Cardinal} : a ^< 0 = 0 :=
  by 
    convert sup_eq_zero 
    exact Subtype.is_empty_of_false fun x => (zero_le _).not_lt

end Cardinal

