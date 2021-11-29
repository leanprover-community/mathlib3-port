import Mathbin.Data.Real.Nnreal

/-!
# Extended non-negative reals

We define `ennreal = ℝ≥0∞ := with_top ℝ≥0` to be the type of extended nonnegative real numbers,
i.e., the interval `[0, +∞]`. This type is used as the codomain of a `measure_theory.measure`,
and of the extended distance `edist` in a `emetric_space`.
In this file we define some algebraic operations and a linear order on `ℝ≥0∞`
and prove basic properties of these operations, order, and conversions to/from `ℝ`, `ℝ≥0`, and `ℕ`.

## Main definitions

* `ℝ≥0∞`: the extended nonnegative real numbers `[0, ∞]`; defined as `with_top ℝ≥0`; it is
  equipped with the following structures:

  - coercion from `ℝ≥0` defined in the natural way;

  - the natural structure of a complete dense linear order: `↑p ≤ ↑q ↔ p ≤ q` and `∀ a, a ≤ ∞`;

  - `a + b` is defined so that `↑p + ↑q = ↑(p + q)` for `(p q : ℝ≥0)` and `a + ∞ = ∞ + a = ∞`;

  - `a * b` is defined so that `↑p * ↑q = ↑(p * q)` for `(p q : ℝ≥0)`, `0 * ∞ = ∞ * 0 = 0`, and `a *
    ∞ = ∞ * a = ∞` for `a ≠ 0`;

  - `a - b` is defined as the minimal `d` such that `a ≤ d + b`; this way we have
    `↑p - ↑q = ↑(p - q)`, `∞ - ↑p = ∞`, `↑p - ∞ = ∞ - ∞ = 0`; note that there is no negation, only
    subtraction;

  - `a⁻¹` is defined as `Inf {b | 1 ≤ a * b}`. This way we have `(↑p)⁻¹ = ↑(p⁻¹)` for
    `p : ℝ≥0`, `p ≠ 0`, `0⁻¹ = ∞`, and `∞⁻¹ = 0`.

  - `a / b` is defined as `a * b⁻¹`.

  The addition and multiplication defined this way together with `0 = ↑0` and `1 = ↑1` turn
  `ℝ≥0∞` into a canonically ordered commutative semiring of characteristic zero.

* Coercions to/from other types:

  - coercion `ℝ≥0 → ℝ≥0∞` is defined as `has_coe`, so one can use `(p : ℝ≥0)` in a context that
    expects `a : ℝ≥0∞`, and Lean will apply `coe` automatically;

  - `ennreal.to_nnreal` sends `↑p` to `p` and `∞` to `0`;

  - `ennreal.to_real := coe ∘ ennreal.to_nnreal` sends `↑p`, `p : ℝ≥0` to `(↑p : ℝ)` and `∞` to `0`;

  - `ennreal.of_real := coe ∘ real.to_nnreal` sends `x : ℝ` to `↑⟨max x 0, _⟩`

  - `ennreal.ne_top_equiv_nnreal` is an equivalence between `{a : ℝ≥0∞ // a ≠ 0}` and `ℝ≥0`.

## Implementation notes

We define a `can_lift ℝ≥0∞ ℝ≥0` instance, so one of the ways to prove theorems about an `ℝ≥0∞`
number `a` is to consider the cases `a = ∞` and `a ≠ ∞`, and use the tactic `lift a to ℝ≥0 using ha`
in the second case. This instance is even more useful if one already has `ha : a ≠ ∞` in the
context, or if we have `(f : α → ℝ≥0∞) (hf : ∀ x, f x ≠ ∞)`.

## Notations

* `ℝ≥0∞`: the type of the extended nonnegative real numbers;
* `ℝ≥0`: the type of nonnegative real numbers `[0, ∞)`; defined in `data.real.nnreal`;
* `∞`: a localized notation in `ℝ≥0∞` for `⊤ : ℝ≥0∞`.

-/


open Classical Set

open_locale Classical BigOperators Nnreal

variable{α : Type _}{β : Type _}

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler has_zero
/-- The extended nonnegative real numbers. This is usually denoted [0, ∞],
  and is relevant as the codomain of a measure. -/
@[derive #["[", expr has_zero, ",", expr add_comm_monoid, ",", expr canonically_ordered_comm_semiring, ",",
   expr complete_linear_order, ",", expr densely_ordered, ",", expr nontrivial, ",",
   expr canonically_linear_ordered_add_monoid, ",", expr has_sub, ",", expr has_ordered_sub, "]"]]
def ennreal :=
with_top «exprℝ≥0»()

localized [Ennreal] notation "ℝ≥0∞" => Ennreal

localized [Ennreal] notation "∞" => (⊤ : Ennreal)

noncomputable instance  : LinearOrderedAddCommMonoid ℝ≥0∞ :=
  { Ennreal.canonicallyOrderedCommSemiring, Ennreal.completeLinearOrder with  }

instance covariant_class_mul : CovariantClass ℝ≥0∞ ℝ≥0∞ (·*·) (· ≤ ·) :=
  CanonicallyOrderedCommSemiring.to_covariant_mul_le

instance covariant_class_add : CovariantClass ℝ≥0∞ ℝ≥0∞ (·+·) (· ≤ ·) :=
  OrderedAddCommMonoid.to_covariant_class_left ℝ≥0∞

namespace Ennreal

variable{a b c d : ℝ≥0∞}{r p q :  ℝ≥0 }

instance  : Inhabited ℝ≥0∞ :=
  ⟨0⟩

instance  : Coe ℝ≥0  ℝ≥0∞ :=
  ⟨Option.some⟩

instance  : CanLift ℝ≥0∞ ℝ≥0  :=
  { coe := coeₓ, cond := fun r => r ≠ ∞,
    prf := fun x hx => ⟨Option.get$ Option.ne_none_iff_is_some.1 hx, Option.some_get _⟩ }

@[simp]
theorem none_eq_top : (none : ℝ≥0∞) = ∞ :=
  rfl

@[simp]
theorem some_eq_coe (a :  ℝ≥0 ) : (some a : ℝ≥0∞) = («expr↑ » a : ℝ≥0∞) :=
  rfl

/-- `to_nnreal x` returns `x` if it is real, otherwise 0. -/
protected def to_nnreal : ℝ≥0∞ →  ℝ≥0 
| some r => r
| none => 0

/-- `to_real x` returns `x` if it is real, `0` otherwise. -/
protected def to_real (a : ℝ≥0∞) : Real :=
  coeₓ a.to_nnreal

/-- `of_real x` returns `x` if it is nonnegative, `0` otherwise. -/
protected noncomputable def of_real (r : Real) : ℝ≥0∞ :=
  coeₓ (Real.toNnreal r)

@[simp, normCast]
theorem to_nnreal_coe : (r : ℝ≥0∞).toNnreal = r :=
  rfl

@[simp]
theorem coe_to_nnreal : ∀ {a : ℝ≥0∞}, a ≠ ∞ → «expr↑ » a.to_nnreal = a
| some r, h => rfl
| none, h => (h rfl).elim

@[simp]
theorem of_real_to_real {a : ℝ≥0∞} (h : a ≠ ∞) : Ennreal.ofReal a.to_real = a :=
  by 
    simp [Ennreal.toReal, Ennreal.ofReal, h]

@[simp]
theorem to_real_of_real {r : ℝ} (h : 0 ≤ r) : Ennreal.toReal (Ennreal.ofReal r) = r :=
  by 
    simp [Ennreal.toReal, Ennreal.ofReal, Real.coe_to_nnreal _ h]

theorem to_real_of_real' {r : ℝ} : Ennreal.toReal (Ennreal.ofReal r) = max r 0 :=
  rfl

theorem coe_to_nnreal_le_self : ∀ {a : ℝ≥0∞}, «expr↑ » a.to_nnreal ≤ a
| some r =>
  by 
    rw [some_eq_coe, to_nnreal_coe] <;> exact le_reflₓ _
| none => le_top

theorem coe_nnreal_eq (r :  ℝ≥0 ) : (r : ℝ≥0∞) = Ennreal.ofReal r :=
  by 
    rw [Ennreal.ofReal, Real.toNnreal]
    cases' r with r h 
    congr 
    dsimp 
    rw [max_eq_leftₓ h]

theorem of_real_eq_coe_nnreal {x : ℝ} (h : 0 ≤ x) : Ennreal.ofReal x = @coeₓ ℝ≥0  ℝ≥0∞ _ (⟨x, h⟩ :  ℝ≥0 ) :=
  by 
    rw [coe_nnreal_eq]
    rfl

@[simp]
theorem of_real_coe_nnreal : Ennreal.ofReal p = p :=
  (coe_nnreal_eq p).symm

@[simp, normCast]
theorem coe_zero : «expr↑ » (0 :  ℝ≥0 ) = (0 : ℝ≥0∞) :=
  rfl

@[simp, normCast]
theorem coe_one : «expr↑ » (1 :  ℝ≥0 ) = (1 : ℝ≥0∞) :=
  rfl

@[simp]
theorem to_real_nonneg {a : ℝ≥0∞} : 0 ≤ a.to_real :=
  by 
    simp [Ennreal.toReal]

@[simp]
theorem top_to_nnreal : ∞.toNnreal = 0 :=
  rfl

@[simp]
theorem top_to_real : ∞.toReal = 0 :=
  rfl

@[simp]
theorem one_to_real : (1 : ℝ≥0∞).toReal = 1 :=
  rfl

@[simp]
theorem one_to_nnreal : (1 : ℝ≥0∞).toNnreal = 1 :=
  rfl

@[simp]
theorem coe_to_real (r :  ℝ≥0 ) : (r : ℝ≥0∞).toReal = r :=
  rfl

@[simp]
theorem zero_to_nnreal : (0 : ℝ≥0∞).toNnreal = 0 :=
  rfl

@[simp]
theorem zero_to_real : (0 : ℝ≥0∞).toReal = 0 :=
  rfl

@[simp]
theorem of_real_zero : Ennreal.ofReal (0 : ℝ) = 0 :=
  by 
    simp [Ennreal.ofReal] <;> rfl

@[simp]
theorem of_real_one : Ennreal.ofReal (1 : ℝ) = (1 : ℝ≥0∞) :=
  by 
    simp [Ennreal.ofReal]

theorem of_real_to_real_le {a : ℝ≥0∞} : Ennreal.ofReal a.to_real ≤ a :=
  if ha : a = ∞ then ha.symm ▸ le_top else le_of_eqₓ (of_real_to_real ha)

theorem forall_ennreal {p : ℝ≥0∞ → Prop} : (∀ a, p a) ↔ (∀ (r :  ℝ≥0 ), p r) ∧ p ∞ :=
  ⟨fun h => ⟨fun r => h _, h _⟩,
    fun ⟨h₁, h₂⟩ a =>
      match a with 
      | some r => h₁ _
      | none => h₂⟩

theorem forall_ne_top {p : ℝ≥0∞ → Prop} : (∀ a (_ : a ≠ ∞), p a) ↔ ∀ (r :  ℝ≥0 ), p r :=
  Option.ball_ne_none

theorem exists_ne_top {p : ℝ≥0∞ → Prop} : (∃ (a : _)(_ : a ≠ ∞), p a) ↔ ∃ r :  ℝ≥0 , p r :=
  Option.bex_ne_none

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem to_nnreal_eq_zero_iff
(x : «exprℝ≥0∞»()) : «expr ↔ »(«expr = »(x.to_nnreal, 0), «expr ∨ »(«expr = »(x, 0), «expr = »(x, «expr∞»()))) :=
⟨begin
   cases [expr x] [],
   { simp [] [] [] ["[", expr none_eq_top, "]"] [] [] },
   { have [ident A] [":", expr «expr = »(some (0 : «exprℝ≥0»()), (0 : «exprℝ≥0∞»()))] [":=", expr rfl],
     simp [] [] [] ["[", expr ennreal.to_nnreal, ",", expr A, "]"] [] [] { contextual := tt } }
 end, by intro [ident h]; cases [expr h] []; simp [] [] [] ["[", expr h, "]"] [] []⟩

theorem to_real_eq_zero_iff (x : ℝ≥0∞) : x.to_real = 0 ↔ x = 0 ∨ x = ∞ :=
  by 
    simp [Ennreal.toReal, to_nnreal_eq_zero_iff]

@[simp]
theorem coe_ne_top : (r : ℝ≥0∞) ≠ ∞ :=
  WithTop.coe_ne_top

@[simp]
theorem top_ne_coe : ∞ ≠ (r : ℝ≥0∞) :=
  WithTop.top_ne_coe

@[simp]
theorem of_real_ne_top {r : ℝ} : Ennreal.ofReal r ≠ ∞ :=
  by 
    simp [Ennreal.ofReal]

@[simp]
theorem of_real_lt_top {r : ℝ} : Ennreal.ofReal r < ∞ :=
  lt_top_iff_ne_top.2 of_real_ne_top

@[simp]
theorem top_ne_of_real {r : ℝ} : ∞ ≠ Ennreal.ofReal r :=
  by 
    simp [Ennreal.ofReal]

@[simp]
theorem zero_ne_top : 0 ≠ ∞ :=
  coe_ne_top

@[simp]
theorem top_ne_zero : ∞ ≠ 0 :=
  top_ne_coe

@[simp]
theorem one_ne_top : 1 ≠ ∞ :=
  coe_ne_top

@[simp]
theorem top_ne_one : ∞ ≠ 1 :=
  top_ne_coe

@[simp, normCast]
theorem coe_eq_coe : («expr↑ » r : ℝ≥0∞) = «expr↑ » q ↔ r = q :=
  WithTop.coe_eq_coe

@[simp, normCast]
theorem coe_le_coe : («expr↑ » r : ℝ≥0∞) ≤ «expr↑ » q ↔ r ≤ q :=
  WithTop.coe_le_coe

@[simp, normCast]
theorem coe_lt_coe : («expr↑ » r : ℝ≥0∞) < «expr↑ » q ↔ r < q :=
  WithTop.coe_lt_coe

theorem coe_mono : Monotone (coeₓ :  ℝ≥0  → ℝ≥0∞) :=
  fun _ _ => coe_le_coe.2

@[simp, normCast]
theorem coe_eq_zero : («expr↑ » r : ℝ≥0∞) = 0 ↔ r = 0 :=
  coe_eq_coe

@[simp, normCast]
theorem zero_eq_coe : 0 = («expr↑ » r : ℝ≥0∞) ↔ 0 = r :=
  coe_eq_coe

@[simp, normCast]
theorem coe_eq_one : («expr↑ » r : ℝ≥0∞) = 1 ↔ r = 1 :=
  coe_eq_coe

@[simp, normCast]
theorem one_eq_coe : 1 = («expr↑ » r : ℝ≥0∞) ↔ 1 = r :=
  coe_eq_coe

@[simp, normCast]
theorem coe_nonneg : 0 ≤ («expr↑ » r : ℝ≥0∞) ↔ 0 ≤ r :=
  coe_le_coe

@[simp, normCast]
theorem coe_pos : 0 < («expr↑ » r : ℝ≥0∞) ↔ 0 < r :=
  coe_lt_coe

theorem coe_ne_zero : (r : ℝ≥0∞) ≠ 0 ↔ r ≠ 0 :=
  not_congr coe_eq_coe

@[simp, normCast]
theorem coe_add : «expr↑ » (r+p) = (r+p : ℝ≥0∞) :=
  WithTop.coe_add

@[simp, normCast]
theorem coe_mul : «expr↑ » (r*p) = (r*p : ℝ≥0∞) :=
  WithTop.coe_mul

@[simp, normCast]
theorem coe_bit0 : («expr↑ » (bit0 r) : ℝ≥0∞) = bit0 r :=
  coe_add

@[simp, normCast]
theorem coe_bit1 : («expr↑ » (bit1 r) : ℝ≥0∞) = bit1 r :=
  by 
    simp [bit1]

theorem coe_two : ((2 :  ℝ≥0 ) : ℝ≥0∞) = 2 :=
  by 
    normCast

protected theorem zero_lt_one : 0 < (1 : ℝ≥0∞) :=
  CanonicallyOrderedCommSemiring.zero_lt_one

@[simp]
theorem one_lt_two : (1 : ℝ≥0∞) < 2 :=
  coe_one ▸
    coe_two ▸
      by 
        exactModCast @one_lt_two ℕ _ _

@[simp]
theorem zero_lt_two : (0 : ℝ≥0∞) < 2 :=
  lt_transₓ Ennreal.zero_lt_one one_lt_two

theorem two_ne_zero : (2 : ℝ≥0∞) ≠ 0 :=
  (ne_of_ltₓ zero_lt_two).symm

theorem two_ne_top : (2 : ℝ≥0∞) ≠ ∞ :=
  coe_two ▸ coe_ne_top

/-- The set of numbers in `ℝ≥0∞` that are not equal to `∞` is equivalent to `ℝ≥0`. -/
def ne_top_equiv_nnreal : { a | a ≠ ∞ } ≃  ℝ≥0  :=
  { toFun := fun x => Ennreal.toNnreal x, invFun := fun x => ⟨x, coe_ne_top⟩,
    left_inv := fun ⟨x, hx⟩ => Subtype.eq$ coe_to_nnreal hx, right_inv := fun x => to_nnreal_coe }

theorem cinfi_ne_top [HasInfₓ α] (f : ℝ≥0∞ → α) : (⨅x : { x // x ≠ ∞ }, f x) = ⨅x :  ℝ≥0 , f x :=
  Eq.symm$ infi_congr _ ne_top_equiv_nnreal.symm.Surjective$ fun x => rfl

theorem infi_ne_top [CompleteLattice α] (f : ℝ≥0∞ → α) : (⨅(x : _)(_ : x ≠ ∞), f x) = ⨅x :  ℝ≥0 , f x :=
  by 
    rw [infi_subtype', cinfi_ne_top]

theorem csupr_ne_top [HasSupₓ α] (f : ℝ≥0∞ → α) : (⨆x : { x // x ≠ ∞ }, f x) = ⨆x :  ℝ≥0 , f x :=
  @cinfi_ne_top (OrderDual α) _ _

theorem supr_ne_top [CompleteLattice α] (f : ℝ≥0∞ → α) : (⨆(x : _)(_ : x ≠ ∞), f x) = ⨆x :  ℝ≥0 , f x :=
  @infi_ne_top (OrderDual α) _ _

theorem infi_ennreal {α : Type _} [CompleteLattice α] {f : ℝ≥0∞ → α} : (⨅n, f n) = (⨅n :  ℝ≥0 , f n)⊓f ∞ :=
  le_antisymmₓ (le_inf (le_infi$ fun i => infi_le _ _) (infi_le _ _))
    (le_infi$ forall_ennreal.2 ⟨fun r => inf_le_of_left_le$ infi_le _ _, inf_le_right⟩)

theorem supr_ennreal {α : Type _} [CompleteLattice α] {f : ℝ≥0∞ → α} : (⨆n, f n) = (⨆n :  ℝ≥0 , f n)⊔f ∞ :=
  @infi_ennreal (OrderDual α) _ _

@[simp]
theorem add_top : (a+∞) = ∞ :=
  WithTop.add_top

@[simp]
theorem top_add : (∞+a) = ∞ :=
  WithTop.top_add

/-- Coercion `ℝ≥0 → ℝ≥0∞` as a `ring_hom`. -/
noncomputable def of_nnreal_hom :  ℝ≥0  →+* ℝ≥0∞ :=
  ⟨coeₓ, coe_one, fun _ _ => coe_mul, coe_zero, fun _ _ => coe_add⟩

@[simp]
theorem coe_of_nnreal_hom : «expr⇑ » of_nnreal_hom = coeₓ :=
  rfl

section Actions

/-- A `mul_action` over `ℝ≥0∞` restricts to a `mul_action` over `ℝ≥0`. -/
noncomputable instance  {M : Type _} [MulAction ℝ≥0∞ M] : MulAction ℝ≥0  M :=
  MulAction.compHom M of_nnreal_hom.toMonoidHom

theorem smul_def {M : Type _} [MulAction ℝ≥0∞ M] (c :  ℝ≥0 ) (x : M) : c • x = (c : ℝ≥0∞) • x :=
  rfl

instance  {M N : Type _} [MulAction ℝ≥0∞ M] [MulAction ℝ≥0∞ N] [HasScalar M N] [IsScalarTower ℝ≥0∞ M N] :
  IsScalarTower ℝ≥0  M N :=
  { smul_assoc := fun r => (smul_assoc (r : ℝ≥0∞) : _) }

instance smul_comm_class_left {M N : Type _} [MulAction ℝ≥0∞ N] [HasScalar M N] [SmulCommClass ℝ≥0∞ M N] :
  SmulCommClass ℝ≥0  M N :=
  { smul_comm := fun r => (smul_comm (r : ℝ≥0∞) : _) }

instance smul_comm_class_right {M N : Type _} [MulAction ℝ≥0∞ N] [HasScalar M N] [SmulCommClass M ℝ≥0∞ N] :
  SmulCommClass M ℝ≥0  N :=
  { smul_comm := fun m r => (smul_comm m (r : ℝ≥0∞) : _) }

/-- A `distrib_mul_action` over `ℝ≥0∞` restricts to a `distrib_mul_action` over `ℝ≥0`. -/
noncomputable instance  {M : Type _} [AddMonoidₓ M] [DistribMulAction ℝ≥0∞ M] : DistribMulAction ℝ≥0  M :=
  DistribMulAction.compHom M of_nnreal_hom.toMonoidHom

/-- A `module` over `ℝ≥0∞` restricts to a `module` over `ℝ≥0`. -/
noncomputable instance  {M : Type _} [AddCommMonoidₓ M] [Module ℝ≥0∞ M] : Module ℝ≥0  M :=
  Module.compHom M of_nnreal_hom

/-- An `algebra` over `ℝ≥0∞` restricts to an `algebra` over `ℝ≥0`. -/
noncomputable instance  {A : Type _} [Semiringₓ A] [Algebra ℝ≥0∞ A] : Algebra ℝ≥0  A :=
  { smul := · • ·,
    commutes' :=
      fun r x =>
        by 
          simp [Algebra.commutes],
    smul_def' :=
      fun r x =>
        by 
          simp [←Algebra.smul_def (r : ℝ≥0∞) x, smul_def],
    toRingHom := (algebraMap ℝ≥0∞ A).comp (of_nnreal_hom :  ℝ≥0  →+* ℝ≥0∞) }

noncomputable example  : Algebra ℝ≥0  ℝ≥0∞ :=
  by 
    infer_instance

noncomputable example  : DistribMulAction (Units ℝ≥0 ) ℝ≥0∞ :=
  by 
    infer_instance

theorem coe_smul {R} (r : R) (s :  ℝ≥0 ) [HasScalar R ℝ≥0 ] [HasScalar R ℝ≥0∞] [IsScalarTower R ℝ≥0  ℝ≥0 ]
  [IsScalarTower R ℝ≥0  ℝ≥0∞] : («expr↑ » (r • s) : ℝ≥0∞) = r • «expr↑ » s :=
  by 
    rw [←smul_one_smul ℝ≥0  r (s : ℝ≥0∞), smul_def, smul_eq_mul, ←Ennreal.coe_mul, smul_mul_assoc, one_mulₓ]

end Actions

@[simp, normCast]
theorem coe_indicator {α} (s : Set α) (f : α →  ℝ≥0 ) (a : α) :
  ((s.indicator f a :  ℝ≥0 ) : ℝ≥0∞) = s.indicator (fun x => f x) a :=
  (of_nnreal_hom :  ℝ≥0  →+ ℝ≥0∞).map_indicator _ _ _

@[simp, normCast]
theorem coe_pow (n : ℕ) : («expr↑ » (r ^ n) : ℝ≥0∞) = r ^ n :=
  of_nnreal_hom.map_pow r n

@[simp]
theorem add_eq_top : (a+b) = ∞ ↔ a = ∞ ∨ b = ∞ :=
  WithTop.add_eq_top

@[simp]
theorem add_lt_top : (a+b) < ∞ ↔ a < ∞ ∧ b < ∞ :=
  WithTop.add_lt_top

theorem to_nnreal_add {r₁ r₂ : ℝ≥0∞} (h₁ : r₁ ≠ ∞) (h₂ : r₂ ≠ ∞) : (r₁+r₂).toNnreal = r₁.to_nnreal+r₂.to_nnreal :=
  by 
    lift r₁ to  ℝ≥0  using h₁ 
    lift r₂ to  ℝ≥0  using h₂ 
    rfl

theorem not_lt_top {x : ℝ≥0∞} : ¬x < ∞ ↔ x = ∞ :=
  by 
    rw [lt_top_iff_ne_top, not_not]

theorem add_ne_top : (a+b) ≠ ∞ ↔ a ≠ ∞ ∧ b ≠ ∞ :=
  by 
    simpa only [lt_top_iff_ne_top] using add_lt_top

theorem mul_top : (a*∞) = if a = 0 then 0 else ∞ :=
  by 
    splitIfs
    ·
      simp [h]
    ·
      exact WithTop.mul_top h

theorem top_mul : (∞*a) = if a = 0 then 0 else ∞ :=
  by 
    splitIfs
    ·
      simp [h]
    ·
      exact WithTop.top_mul h

@[simp]
theorem top_mul_top : (∞*∞) = ∞ :=
  WithTop.top_mul_top

theorem top_pow {n : ℕ} (h : 0 < n) : ∞ ^ n = ∞ :=
  Nat.le_induction (pow_oneₓ _)
    (fun m hm hm' =>
      by 
        rw [pow_succₓ, hm', top_mul_top])
    _ (Nat.succ_le_of_ltₓ h)

theorem mul_eq_top : (a*b) = ∞ ↔ a ≠ 0 ∧ b = ∞ ∨ a = ∞ ∧ b ≠ 0 :=
  WithTop.mul_eq_top_iff

theorem mul_lt_top : a ≠ ∞ → b ≠ ∞ → (a*b) < ∞ :=
  WithTop.mul_lt_top

theorem mul_ne_top : a ≠ ∞ → b ≠ ∞ → (a*b) ≠ ∞ :=
  by 
    simpa only [lt_top_iff_ne_top] using mul_lt_top

theorem lt_top_of_mul_ne_top_left (h : (a*b) ≠ ∞) (hb : b ≠ 0) : a < ∞ :=
  lt_top_iff_ne_top.2$ fun ha => h$ mul_eq_top.2 (Or.inr ⟨ha, hb⟩)

theorem lt_top_of_mul_ne_top_right (h : (a*b) ≠ ∞) (ha : a ≠ 0) : b < ∞ :=
  lt_top_of_mul_ne_top_left
    (by 
      rwa [mul_commₓ])
    ha

theorem mul_lt_top_iff {a b : ℝ≥0∞} : (a*b) < ∞ ↔ a < ∞ ∧ b < ∞ ∨ a = 0 ∨ b = 0 :=
  by 
    split 
    ·
      intro h 
      rw [←or_assoc, or_iff_not_imp_right, or_iff_not_imp_right]
      intro hb ha 
      exact ⟨lt_top_of_mul_ne_top_left h.ne hb, lt_top_of_mul_ne_top_right h.ne ha⟩
    ·
      rintro (⟨ha, hb⟩ | rfl | rfl) <;> [exact mul_lt_top ha.ne hb.ne, simp , simp ]

theorem mul_self_lt_top_iff {a : ℝ≥0∞} : (a*a) < ⊤ ↔ a < ⊤ :=
  by 
    rw [Ennreal.mul_lt_top_iff, and_selfₓ, or_selfₓ, or_iff_left_iff_imp]
    rintro rfl 
    normNum

theorem mul_pos_iff : (0 < a*b) ↔ 0 < a ∧ 0 < b :=
  CanonicallyOrderedCommSemiring.mul_pos

theorem mul_pos (ha : a ≠ 0) (hb : b ≠ 0) : 0 < a*b :=
  mul_pos_iff.2 ⟨pos_iff_ne_zero.2 ha, pos_iff_ne_zero.2 hb⟩

@[simp]
theorem pow_eq_top_iff {n : ℕ} : a ^ n = ∞ ↔ a = ∞ ∧ n ≠ 0 :=
  by 
    induction' n with n ihn
    ·
      simp 
    rw [pow_succₓ, mul_eq_top, ihn]
    fsplit
    ·
      rintro (⟨-, rfl, h0⟩ | ⟨rfl, h0⟩) <;> exact ⟨rfl, n.succ_ne_zero⟩
    ·
      rintro ⟨rfl, -⟩
      exact Or.inr ⟨rfl, pow_ne_zero n top_ne_zero⟩

theorem pow_eq_top (n : ℕ) (h : a ^ n = ∞) : a = ∞ :=
  (pow_eq_top_iff.1 h).1

theorem pow_ne_top (h : a ≠ ∞) {n : ℕ} : a ^ n ≠ ∞ :=
  mt (pow_eq_top n) h

theorem pow_lt_top : a < ∞ → ∀ (n : ℕ), a ^ n < ∞ :=
  by 
    simpa only [lt_top_iff_ne_top] using pow_ne_top

@[simp, normCast]
theorem coe_finset_sum {s : Finset α} {f : α →  ℝ≥0 } : «expr↑ » (∑a in s, f a) = (∑a in s, f a : ℝ≥0∞) :=
  of_nnreal_hom.map_sum f s

@[simp, normCast]
theorem coe_finset_prod {s : Finset α} {f : α →  ℝ≥0 } : «expr↑ » (∏a in s, f a) = (∏a in s, f a : ℝ≥0∞) :=
  of_nnreal_hom.map_prod f s

section Order

@[simp]
theorem bot_eq_zero : (⊥ : ℝ≥0∞) = 0 :=
  rfl

@[simp]
theorem coe_lt_top : coeₓ r < ∞ :=
  WithTop.coe_lt_top r

@[simp]
theorem not_top_le_coe : ¬∞ ≤ «expr↑ » r :=
  WithTop.not_top_le_coe r

@[simp, normCast]
theorem one_le_coe_iff : (1 : ℝ≥0∞) ≤ «expr↑ » r ↔ 1 ≤ r :=
  coe_le_coe

@[simp, normCast]
theorem coe_le_one_iff : «expr↑ » r ≤ (1 : ℝ≥0∞) ↔ r ≤ 1 :=
  coe_le_coe

@[simp, normCast]
theorem coe_lt_one_iff : («expr↑ » p : ℝ≥0∞) < 1 ↔ p < 1 :=
  coe_lt_coe

@[simp, normCast]
theorem one_lt_coe_iff : 1 < («expr↑ » p : ℝ≥0∞) ↔ 1 < p :=
  coe_lt_coe

@[simp, normCast]
theorem coe_nat (n : ℕ) : ((n :  ℝ≥0 ) : ℝ≥0∞) = n :=
  WithTop.coe_nat n

@[simp]
theorem of_real_coe_nat (n : ℕ) : Ennreal.ofReal n = n :=
  by 
    simp [Ennreal.ofReal]

@[simp]
theorem nat_ne_top (n : ℕ) : (n : ℝ≥0∞) ≠ ∞ :=
  WithTop.nat_ne_top n

@[simp]
theorem top_ne_nat (n : ℕ) : ∞ ≠ n :=
  WithTop.top_ne_nat n

@[simp]
theorem one_lt_top : 1 < ∞ :=
  coe_lt_top

@[simp, normCast]
theorem to_nnreal_nat (n : ℕ) : (n : ℝ≥0∞).toNnreal = n :=
  by 
    convLHS => rw [←Ennreal.coe_nat n, Ennreal.to_nnreal_coe]

@[simp, normCast]
theorem to_real_nat (n : ℕ) : (n : ℝ≥0∞).toReal = n :=
  by 
    convLHS => rw [←Ennreal.of_real_coe_nat n, Ennreal.to_real_of_real (Nat.cast_nonneg _)]

theorem le_coe_iff : a ≤ «expr↑ » r ↔ ∃ p :  ℝ≥0 , a = p ∧ p ≤ r :=
  WithTop.le_coe_iff

theorem coe_le_iff : «expr↑ » r ≤ a ↔ ∀ (p :  ℝ≥0 ), a = p → r ≤ p :=
  WithTop.coe_le_iff

theorem lt_iff_exists_coe : a < b ↔ ∃ p :  ℝ≥0 , a = p ∧ «expr↑ » p < b :=
  WithTop.lt_iff_exists_coe

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem to_real_le_coe_of_le_coe {a : «exprℝ≥0∞»()} {b : «exprℝ≥0»()} (h : «expr ≤ »(a, b)) : «expr ≤ »(a.to_real, b) :=
show «expr ≤ »(«expr↑ »(a.to_nnreal), «expr↑ »(b)), begin
  have [] [":", expr «expr = »(«expr↑ »(a.to_nnreal), a)] [":=", expr ennreal.coe_to_nnreal (lt_of_le_of_lt h coe_lt_top).ne],
  rw ["<-", expr this] ["at", ident h],
  exact_mod_cast [expr h]
end

@[simp, normCast]
theorem coe_finset_sup {s : Finset α} {f : α →  ℝ≥0 } : «expr↑ » (s.sup f) = s.sup fun x => (f x : ℝ≥0∞) :=
  Finset.comp_sup_eq_sup_comp_of_is_total _ coe_mono rfl

theorem pow_le_pow {n m : ℕ} (ha : 1 ≤ a) (h : n ≤ m) : a ^ n ≤ a ^ m :=
  by 
    cases a
    ·
      cases m
      ·
        rw [eq_bot_iff.mpr h]
        exact le_reflₓ _
      ·
        rw [none_eq_top, top_pow (Nat.succ_posₓ m)]
        exact le_top
    ·
      rw [some_eq_coe, ←coe_pow, ←coe_pow, coe_le_coe]
      exact
        pow_le_pow
          (by 
            simpa using ha)
          h

theorem one_le_pow_of_one_le (ha : 1 ≤ a) (n : ℕ) : 1 ≤ a ^ n :=
  by 
    simpa using pow_le_pow ha (zero_le n)

@[simp]
theorem max_eq_zero_iff : max a b = 0 ↔ a = 0 ∧ b = 0 :=
  by 
    simp only [nonpos_iff_eq_zero.symm, max_le_iff]

@[simp]
theorem max_zero_left : max 0 a = a :=
  max_eq_rightₓ (zero_le a)

@[simp]
theorem max_zero_right : max a 0 = a :=
  max_eq_leftₓ (zero_le a)

@[simp]
theorem sup_eq_max : a⊔b = max a b :=
  rfl

protected theorem pow_pos : 0 < a → ∀ (n : ℕ), 0 < a ^ n :=
  CanonicallyOrderedCommSemiring.pow_pos

protected theorem pow_ne_zero : a ≠ 0 → ∀ (n : ℕ), a ^ n ≠ 0 :=
  by 
    simpa only [pos_iff_ne_zero] using Ennreal.pow_pos

@[simp]
theorem not_lt_zero : ¬a < 0 :=
  by 
    simp 

theorem add_lt_add_iff_left (ha : a ≠ ∞) : ((a+c) < a+b) ↔ c < b :=
  WithTop.add_lt_add_iff_left ha

theorem add_lt_add_left (ha : a ≠ ∞) (h : b < c) : (a+b) < a+c :=
  (add_lt_add_iff_left ha).2 h

theorem add_lt_add_iff_right (ha : a ≠ ∞) : ((c+a) < b+a) ↔ c < b :=
  WithTop.add_lt_add_iff_right ha

theorem add_lt_add_right (ha : a ≠ ∞) (h : b < c) : (b+a) < c+a :=
  (add_lt_add_iff_right ha).2 h

instance contravariant_class_add_lt : ContravariantClass ℝ≥0∞ ℝ≥0∞ (·+·) (· < ·) :=
  WithTop.contravariant_class_add_lt

theorem lt_add_right (ha : a ≠ ∞) (hb : b ≠ 0) : a < a+b :=
  by 
    rwa [←pos_iff_ne_zero, ←add_lt_add_iff_left ha, add_zeroₓ] at hb

theorem le_of_forall_pos_le_add : ∀ {a b : ℝ≥0∞}, (∀ (ε :  ℝ≥0 ), 0 < ε → b < ∞ → a ≤ b+ε) → a ≤ b
| a, none, h => le_top
| none, some a, h =>
  have  : ∞ ≤ «expr↑ » a+«expr↑ » (1 :  ℝ≥0 ) := h 1 zero_lt_one coe_lt_top 
  by 
    rw [←coe_add] at this <;> exact (not_top_le_coe this).elim
| some a, some b, h =>
  by 
    simp only [none_eq_top, some_eq_coe, coe_add.symm, coe_le_coe, coe_lt_top, true_implies_iff] at * <;>
      exact Nnreal.le_of_forall_pos_le_add h

theorem lt_iff_exists_rat_btwn : a < b ↔ ∃ q : ℚ, 0 ≤ q ∧ a < Real.toNnreal q ∧ (Real.toNnreal q : ℝ≥0∞) < b :=
  ⟨fun h =>
      by 
        rcases lt_iff_exists_coe.1 h with ⟨p, rfl, _⟩
        rcases exists_between h with ⟨c, pc, cb⟩
        rcases lt_iff_exists_coe.1 cb with ⟨r, rfl, _⟩
        rcases(Nnreal.lt_iff_exists_rat_btwn _ _).1 (coe_lt_coe.1 pc) with ⟨q, hq0, pq, qr⟩
        exact ⟨q, hq0, coe_lt_coe.2 pq, lt_transₓ (coe_lt_coe.2 qr) cb⟩,
    fun ⟨q, q0, qa, qb⟩ => lt_transₓ qa qb⟩

theorem lt_iff_exists_real_btwn : a < b ↔ ∃ r : ℝ, 0 ≤ r ∧ a < Ennreal.ofReal r ∧ (Ennreal.ofReal r : ℝ≥0∞) < b :=
  ⟨fun h =>
      let ⟨q, q0, aq, qb⟩ := Ennreal.lt_iff_exists_rat_btwn.1 h
      ⟨q, Rat.cast_nonneg.2 q0, aq, qb⟩,
    fun ⟨q, q0, qa, qb⟩ => lt_transₓ qa qb⟩

theorem lt_iff_exists_nnreal_btwn : a < b ↔ ∃ r :  ℝ≥0 , a < r ∧ (r : ℝ≥0∞) < b :=
  WithTop.lt_iff_exists_coe_btwn

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem lt_iff_exists_add_pos_lt : «expr ↔ »(«expr < »(a, b), «expr∃ , »((r : «exprℝ≥0»()), «expr ∧ »(«expr < »(0, r), «expr < »(«expr + »(a, r), b)))) :=
begin
  refine [expr ⟨λ hab, _, λ ⟨r, rpos, hr⟩, lt_of_le_of_lt le_self_add hr⟩],
  cases [expr a] [],
  { simpa [] [] [] [] [] ["using", expr hab] },
  rcases [expr lt_iff_exists_real_btwn.1 hab, "with", "⟨", ident c, ",", ident c_nonneg, ",", ident ac, ",", ident cb, "⟩"],
  let [ident d] [":", expr «exprℝ≥0»()] [":=", expr ⟨c, c_nonneg⟩],
  have [ident ad] [":", expr «expr < »(a, d)] [],
  { rw [expr of_real_eq_coe_nnreal c_nonneg] ["at", ident ac],
    exact [expr coe_lt_coe.1 ac] },
  refine [expr ⟨«expr - »(d, a), tsub_pos_iff_lt.2 ad, _⟩],
  rw ["[", expr some_eq_coe, ",", "<-", expr coe_add, "]"] [],
  convert [] [expr cb] [],
  have [] [":", expr «expr = »(real.to_nnreal c, d)] [],
  by { rw ["[", "<-", expr nnreal.coe_eq, ",", expr real.coe_to_nnreal _ c_nonneg, "]"] [],
    refl },
  rw ["[", expr add_comm, ",", expr this, "]"] [],
  exact [expr tsub_add_cancel_of_le ad.le]
end

theorem coe_nat_lt_coe {n : ℕ} : (n : ℝ≥0∞) < r ↔ «expr↑ » n < r :=
  Ennreal.coe_nat n ▸ coe_lt_coe

theorem coe_lt_coe_nat {n : ℕ} : (r : ℝ≥0∞) < n ↔ r < n :=
  Ennreal.coe_nat n ▸ coe_lt_coe

@[simp, normCast]
theorem coe_nat_lt_coe_nat {m n : ℕ} : (m : ℝ≥0∞) < n ↔ m < n :=
  Ennreal.coe_nat n ▸ coe_nat_lt_coe.trans Nat.cast_lt

theorem coe_nat_ne_top {n : ℕ} : (n : ℝ≥0∞) ≠ ∞ :=
  Ennreal.coe_nat n ▸ coe_ne_top

theorem coe_nat_mono : StrictMono (coeₓ : ℕ → ℝ≥0∞) :=
  fun _ _ => coe_nat_lt_coe_nat.2

@[simp, normCast]
theorem coe_nat_le_coe_nat {m n : ℕ} : (m : ℝ≥0∞) ≤ n ↔ m ≤ n :=
  coe_nat_mono.le_iff_le

instance  : CharZero ℝ≥0∞ :=
  ⟨coe_nat_mono.Injective⟩

protected theorem exists_nat_gt {r : ℝ≥0∞} (h : r ≠ ∞) : ∃ n : ℕ, r < n :=
  by 
    lift r to  ℝ≥0  using h 
    rcases exists_nat_gt r with ⟨n, hn⟩
    exact ⟨n, coe_lt_coe_nat.2 hn⟩

theorem add_lt_add (ac : a < c) (bd : b < d) : (a+b) < c+d :=
  by 
    lift a to  ℝ≥0  using ne_top_of_lt ac 
    lift b to  ℝ≥0  using ne_top_of_lt bd 
    cases c
    ·
      simp 
    cases d
    ·
      simp 
    simp only [←coe_add, some_eq_coe, coe_lt_coe] at *
    exact add_lt_add ac bd

@[normCast]
theorem coe_min : ((min r p :  ℝ≥0 ) : ℝ≥0∞) = min r p :=
  coe_mono.map_min

@[normCast]
theorem coe_max : ((max r p :  ℝ≥0 ) : ℝ≥0∞) = max r p :=
  coe_mono.map_max

theorem le_of_top_imp_top_of_to_nnreal_le {a b : ℝ≥0∞} (h : a = ⊤ → b = ⊤)
  (h_nnreal : a ≠ ⊤ → b ≠ ⊤ → a.to_nnreal ≤ b.to_nnreal) : a ≤ b :=
  by 
    byCases' ha : a = ⊤
    ·
      rw [h ha]
      exact le_top 
    byCases' hb : b = ⊤
    ·
      rw [hb]
      exact le_top 
    rw [←coe_to_nnreal hb, ←coe_to_nnreal ha, coe_le_coe]
    exact h_nnreal ha hb

end Order

section CompleteLattice

theorem coe_Sup {s : Set ℝ≥0 } : BddAbove s → («expr↑ » (Sup s) : ℝ≥0∞) = ⨆(a : _)(_ : a ∈ s), «expr↑ » a :=
  WithTop.coe_Sup

theorem coe_Inf {s : Set ℝ≥0 } : s.nonempty → («expr↑ » (Inf s) : ℝ≥0∞) = ⨅(a : _)(_ : a ∈ s), «expr↑ » a :=
  WithTop.coe_Inf

@[simp]
theorem top_mem_upper_bounds {s : Set ℝ≥0∞} : ∞ ∈ UpperBounds s :=
  fun x hx => le_top

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem coe_mem_upper_bounds
{s : set «exprℝ≥0»()} : «expr ↔ »(«expr ∈ »(«expr↑ »(r), upper_bounds «expr '' »((coe : «exprℝ≥0»() → «exprℝ≥0∞»()), s)), «expr ∈ »(r, upper_bounds s)) :=
by simp [] [] [] ["[", expr upper_bounds, ",", expr ball_image_iff, ",", "-", ident mem_image, ",", "*", "]"] [] [] { contextual := tt }

end CompleteLattice

/-- `le_of_add_le_add_left` is normally applicable to `ordered_cancel_add_comm_monoid`,
but it holds in `ℝ≥0∞` with the additional assumption that `a ≠ ∞`. -/
theorem le_of_add_le_add_left {a b c : ℝ≥0∞} (ha : a ≠ ∞) : ((a+b) ≤ a+c) → b ≤ c :=
  by 
    lift a to  ℝ≥0  using ha 
    cases b <;> cases c <;> simp [←Ennreal.coe_add, Ennreal.coe_le_coe]

/-- `le_of_add_le_add_right` is normally applicable to `ordered_cancel_add_comm_monoid`,
but it holds in `ℝ≥0∞` with the additional assumption that `a ≠ ∞`. -/
theorem le_of_add_le_add_right {a b c : ℝ≥0∞} : a ≠ ∞ → ((b+a) ≤ c+a) → b ≤ c :=
  by 
    simpa only [add_commₓ _ a] using le_of_add_le_add_left

section Mul

@[mono]
theorem mul_le_mul : a ≤ b → c ≤ d → (a*c) ≤ b*d :=
  mul_le_mul'

@[mono]
theorem mul_lt_mul (ac : a < c) (bd : b < d) : (a*b) < c*d :=
  by 
    rcases lt_iff_exists_nnreal_btwn.1 ac with ⟨a', aa', a'c⟩
    lift a to  ℝ≥0  using ne_top_of_lt aa' 
    rcases lt_iff_exists_nnreal_btwn.1 bd with ⟨b', bb', b'd⟩
    lift b to  ℝ≥0  using ne_top_of_lt bb' 
    normCast  at *
    calc «expr↑ » (a*b) < «expr↑ » (a'*b') :=
      coe_lt_coe.2 (mul_lt_mul' aa'.le bb' (zero_le _) ((zero_le a).trans_lt aa'))_ = «expr↑ » a'*«expr↑ » b' :=
      coe_mul _ ≤ c*d := mul_le_mul a'c.le b'd.le

theorem mul_left_mono : Monotone ((·*·) a) :=
  fun b c => mul_le_mul (le_reflₓ a)

theorem mul_right_mono : Monotone fun x => x*a :=
  fun b c h => mul_le_mul h (le_reflₓ a)

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem pow_strict_mono {n : exprℕ()} (hn : «expr ≠ »(n, 0)) : strict_mono (λ x : «exprℝ≥0∞»(), «expr ^ »(x, n)) :=
begin
  assume [binders (x y hxy)],
  obtain ["⟨", ident n, ",", ident rfl, "⟩", ":=", expr nat.exists_eq_succ_of_ne_zero hn],
  induction [expr n] [] ["with", ident n, ident IH] [],
  { simp [] [] ["only"] ["[", expr hxy, ",", expr pow_one, "]"] [] [] },
  { simp [] [] ["only"] ["[", expr pow_succ _ n.succ, ",", expr mul_lt_mul hxy (IH (nat.succ_pos _).ne'), "]"] [] [] }
end

theorem max_mul : (max a b*c) = max (a*c) (b*c) :=
  mul_right_mono.map_max

theorem mul_max : (a*max b c) = max (a*b) (a*c) :=
  mul_left_mono.map_max

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem mul_eq_mul_left : «expr ≠ »(a, 0) → «expr ≠ »(a, «expr∞»()) → «expr ↔ »(«expr = »(«expr * »(a, b), «expr * »(a, c)), «expr = »(b, c)) :=
begin
  cases [expr a] []; cases [expr b] []; cases [expr c] []; simp [] [] [] ["[", expr none_eq_top, ",", expr some_eq_coe, ",", expr mul_top, ",", expr top_mul, ",", "-", ident coe_mul, ",", expr coe_mul.symm, ",", expr nnreal.mul_eq_mul_left, "]"] [] [] { contextual := tt }
end

theorem mul_eq_mul_right : c ≠ 0 → c ≠ ∞ → (((a*c) = b*c) ↔ a = b) :=
  mul_commₓ c a ▸ mul_commₓ c b ▸ mul_eq_mul_left

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem mul_le_mul_left : «expr ≠ »(a, 0) → «expr ≠ »(a, «expr∞»()) → «expr ↔ »(«expr ≤ »(«expr * »(a, b), «expr * »(a, c)), «expr ≤ »(b, c)) :=
begin
  cases [expr a] []; cases [expr b] []; cases [expr c] []; simp [] [] [] ["[", expr none_eq_top, ",", expr some_eq_coe, ",", expr mul_top, ",", expr top_mul, ",", "-", ident coe_mul, ",", expr coe_mul.symm, "]"] [] [] { contextual := tt },
  assume [binders (h)],
  exact [expr mul_le_mul_left (pos_iff_ne_zero.2 h)]
end

theorem mul_le_mul_right : c ≠ 0 → c ≠ ∞ → (((a*c) ≤ b*c) ↔ a ≤ b) :=
  mul_commₓ c a ▸ mul_commₓ c b ▸ mul_le_mul_left

theorem mul_lt_mul_left : a ≠ 0 → a ≠ ∞ → (((a*b) < a*c) ↔ b < c) :=
  fun h0 ht =>
    by 
      simp only [mul_le_mul_left h0 ht, lt_iff_le_not_leₓ]

theorem mul_lt_mul_right : c ≠ 0 → c ≠ ∞ → (((a*c) < b*c) ↔ a < b) :=
  mul_commₓ c a ▸ mul_commₓ c b ▸ mul_lt_mul_left

end Mul

section Cancel

/-- An element `a` is `add_le_cancellable` if `a + b ≤ a + c` implies `b ≤ c` for all `b` and `c`.
  This is true in `ℝ≥0∞` for all elements except `∞`. -/
theorem add_le_cancellable_iff_ne {a : ℝ≥0∞} : AddLeCancellable a ↔ a ≠ ∞ :=
  by 
    split 
    ·
      rintro h rfl 
      refine' ennreal.zero_lt_one.not_le (h _)
      simp 
    ·
      rintro h b c hbc 
      apply Ennreal.le_of_add_le_add_left h hbc

/-- This lemma has an abbreviated name because it is used frequently. -/
theorem cancel_of_ne {a : ℝ≥0∞} (h : a ≠ ∞) : AddLeCancellable a :=
  add_le_cancellable_iff_ne.mpr h

/-- This lemma has an abbreviated name because it is used frequently. -/
theorem cancel_of_lt {a : ℝ≥0∞} (h : a < ∞) : AddLeCancellable a :=
  cancel_of_ne h.ne

/-- This lemma has an abbreviated name because it is used frequently. -/
theorem cancel_of_lt' {a b : ℝ≥0∞} (h : a < b) : AddLeCancellable a :=
  cancel_of_ne h.ne_top

/-- This lemma has an abbreviated name because it is used frequently. -/
theorem cancel_coe {a :  ℝ≥0 } : AddLeCancellable (a : ℝ≥0∞) :=
  cancel_of_ne coe_ne_top

theorem add_right_injₓ (h : a ≠ ∞) : ((a+b) = a+c) ↔ b = c :=
  (cancel_of_ne h).inj

theorem add_left_injₓ (h : a ≠ ∞) : ((b+a) = c+a) ↔ b = c :=
  (cancel_of_ne h).inj_left

end Cancel

section Sub

theorem sub_eq_Inf {a b : ℝ≥0∞} : a - b = Inf { d | a ≤ d+b } :=
  le_antisymmₓ (le_Inf$ fun c => tsub_le_iff_right.mpr)$ Inf_le le_tsub_add

/-- This is a special case of `with_top.coe_sub` in the `ennreal` namespace -/
theorem coe_sub : («expr↑ » (r - p) : ℝ≥0∞) = «expr↑ » r - «expr↑ » p :=
  by 
    simp 

/-- This is a special case of `with_top.top_sub_coe` in the `ennreal` namespace -/
theorem top_sub_coe : ∞ - «expr↑ » r = ∞ :=
  by 
    simp 

/-- This is a special case of `with_top.sub_top` in the `ennreal` namespace -/
theorem sub_top : a - ∞ = 0 :=
  by 
    simp 

theorem sub_eq_top_iff : a - b = ∞ ↔ a = ∞ ∧ b ≠ ∞ :=
  by 
    cases a <;> cases b <;> simp [←WithTop.coe_sub]

theorem sub_ne_top (ha : a ≠ ∞) : a - b ≠ ∞ :=
  mt sub_eq_top_iff.mp$ mt And.left ha

protected theorem sub_lt_of_lt_add (hac : c ≤ a) (h : a < b+c) : a - c < b :=
  ((cancel_of_lt'$ hac.trans_lt h).tsub_lt_iff_right hac).mpr h

@[simp]
theorem add_sub_self (hb : b ≠ ∞) : (a+b) - b = a :=
  (cancel_of_ne hb).add_tsub_cancel_right

@[simp]
theorem add_sub_self' (ha : a ≠ ∞) : (a+b) - a = b :=
  (cancel_of_ne ha).add_tsub_cancel_left

theorem sub_eq_of_add_eq (hb : b ≠ ∞) (hc : (a+b) = c) : c - b = a :=
  (cancel_of_ne hb).tsub_eq_of_eq_add hc.symm

protected theorem lt_add_of_sub_lt (ht : a ≠ ∞ ∨ b ≠ ∞) (h : a - b < c) : a < c+b :=
  by 
    rcases eq_or_ne b ∞ with (rfl | hb)
    ·
      rw [add_top, lt_top_iff_ne_top]
      exact ht.resolve_right (not_not.2 rfl)
    ·
      exact (cancel_of_ne hb).lt_add_of_tsub_lt_right h

protected theorem sub_lt_iff_lt_add (hb : b ≠ ∞) (hab : b ≤ a) : a - b < c ↔ a < c+b :=
  (cancel_of_ne hb).tsub_lt_iff_right hab

protected theorem sub_lt_self (hat : a ≠ ∞) (ha0 : a ≠ 0) (hb : b ≠ 0) : a - b < a :=
  by 
    cases b
    ·
      simp [pos_iff_ne_zero, ha0]
    exact (cancel_of_ne hat).tsub_lt_self cancel_coe (pos_iff_ne_zero.mpr ha0) (pos_iff_ne_zero.mpr hb)

theorem sub_lt_of_sub_lt (h₂ : c ≤ a) (h₃ : a ≠ ∞ ∨ b ≠ ∞) (h₁ : a - b < c) : a - c < b :=
  Ennreal.sub_lt_of_lt_add h₂ (add_commₓ c b ▸ Ennreal.lt_add_of_sub_lt h₃ h₁)

theorem sub_sub_cancel (h : a ≠ ∞) (h2 : b ≤ a) : a - (a - b) = b :=
  (cancel_of_ne$ sub_ne_top h).tsub_tsub_cancel_of_le h2

theorem sub_right_inj {a b c : ℝ≥0∞} (ha : a ≠ ∞) (hb : b ≤ a) (hc : c ≤ a) : a - b = a - c ↔ b = c :=
  (cancel_of_ne ha).tsub_right_inj (cancel_of_ne$ ne_top_of_le_ne_top ha hb) (cancel_of_ne$ ne_top_of_le_ne_top ha hc)
    hb hc

theorem sub_mul (h : 0 < b → b < a → c ≠ ∞) : ((a - b)*c) = (a*c) - b*c :=
  by 
    cases' le_or_ltₓ a b with hab hab
    ·
      simp [hab, mul_right_mono hab]
    rcases eq_or_lt_of_le (zero_le b) with (rfl | hb)
    ·
      simp 
    exact (cancel_of_ne$ mul_ne_top hab.ne_top (h hb hab)).tsub_mul

theorem mul_sub (h : 0 < c → c < b → a ≠ ∞) : (a*b - c) = (a*b) - a*c :=
  by 
    simp only [mul_commₓ a]
    exact sub_mul h

end Sub

section Sum

open Finset

/-- A product of finite numbers is still finite -/
theorem prod_lt_top {s : Finset α} {f : α → ℝ≥0∞} (h : ∀ a (_ : a ∈ s), f a ≠ ∞) : (∏a in s, f a) < ∞ :=
  WithTop.prod_lt_top h

/-- A sum of finite numbers is still finite -/
theorem sum_lt_top {s : Finset α} {f : α → ℝ≥0∞} (h : ∀ a (_ : a ∈ s), f a ≠ ∞) : (∑a in s, f a) < ∞ :=
  WithTop.sum_lt_top h

/-- A sum of finite numbers is still finite -/
theorem sum_lt_top_iff {s : Finset α} {f : α → ℝ≥0∞} : (∑a in s, f a) < ∞ ↔ ∀ a (_ : a ∈ s), f a < ∞ :=
  WithTop.sum_lt_top_iff

/-- A sum of numbers is infinite iff one of them is infinite -/
theorem sum_eq_top_iff {s : Finset α} {f : α → ℝ≥0∞} : (∑x in s, f x) = ∞ ↔ ∃ (a : _)(_ : a ∈ s), f a = ∞ :=
  WithTop.sum_eq_top_iff

theorem lt_top_of_sum_ne_top {s : Finset α} {f : α → ℝ≥0∞} (h : (∑x in s, f x) ≠ ∞) {a : α} (ha : a ∈ s) : f a < ∞ :=
  sum_lt_top_iff.1 h.lt_top a ha

/-- seeing `ℝ≥0∞` as `ℝ≥0` does not change their sum, unless one of the `ℝ≥0∞` is
infinity -/
theorem to_nnreal_sum {s : Finset α} {f : α → ℝ≥0∞} (hf : ∀ a (_ : a ∈ s), f a ≠ ∞) :
  Ennreal.toNnreal (∑a in s, f a) = ∑a in s, Ennreal.toNnreal (f a) :=
  by 
    rw [←coe_eq_coe, coe_to_nnreal, coe_finset_sum, sum_congr rfl]
    ·
      intro x hx 
      exact (coe_to_nnreal (hf x hx)).symm
    ·
      exact (sum_lt_top hf).Ne

/-- seeing `ℝ≥0∞` as `real` does not change their sum, unless one of the `ℝ≥0∞` is infinity -/
theorem to_real_sum {s : Finset α} {f : α → ℝ≥0∞} (hf : ∀ a (_ : a ∈ s), f a ≠ ∞) :
  Ennreal.toReal (∑a in s, f a) = ∑a in s, Ennreal.toReal (f a) :=
  by 
    rw [Ennreal.toReal, to_nnreal_sum hf, Nnreal.coe_sum]
    rfl

theorem of_real_sum_of_nonneg {s : Finset α} {f : α → ℝ} (hf : ∀ i, i ∈ s → 0 ≤ f i) :
  Ennreal.ofReal (∑i in s, f i) = ∑i in s, Ennreal.ofReal (f i) :=
  by 
    simpRw [Ennreal.ofReal, ←coe_finset_sum, coe_eq_coe]
    exact Real.to_nnreal_sum_of_nonneg hf

theorem sum_lt_sum_of_nonempty {s : Finset α} (hs : s.nonempty) {f g : α → ℝ≥0∞} (Hlt : ∀ i (_ : i ∈ s), f i < g i) :
  (∑i in s, f i) < ∑i in s, g i :=
  by 
    classical 
    induction' s using Finset.induction_on with a s as IH
    ·
      exact (Finset.not_nonempty_empty hs).elim
    ·
      rcases Finset.eq_empty_or_nonempty s with (rfl | h's)
      ·
        simp [Hlt _ (Finset.mem_singleton_self _)]
      ·
        simp only [as, Finset.sum_insert, not_false_iff]
        exact
          Ennreal.add_lt_add (Hlt _ (Finset.mem_insert_self _ _))
            (IH h's fun i hi => Hlt _ (Finset.mem_insert_of_mem hi))

theorem exists_le_of_sum_le {s : Finset α} (hs : s.nonempty) {f g : α → ℝ≥0∞} (Hle : (∑i in s, f i) ≤ ∑i in s, g i) :
  ∃ (i : _)(_ : i ∈ s), f i ≤ g i :=
  by 
    contrapose! Hle 
    apply Ennreal.sum_lt_sum_of_nonempty hs Hle

end Sum

section Interval

variable{x y z : ℝ≥0∞}{ε ε₁ ε₂ : ℝ≥0∞}{s : Set ℝ≥0∞}

protected theorem Ico_eq_Iio : Ico 0 y = Iio y :=
  Ico_bot

theorem mem_Iio_self_add : x ≠ ∞ → ε ≠ 0 → x ∈ Iio (x+ε) :=
  fun xt ε0 => lt_add_right xt ε0

theorem mem_Ioo_self_sub_add : x ≠ ∞ → x ≠ 0 → ε₁ ≠ 0 → ε₂ ≠ 0 → x ∈ Ioo (x - ε₁) (x+ε₂) :=
  fun xt x0 ε0 ε0' => ⟨Ennreal.sub_lt_self xt x0 ε0, lt_add_right xt ε0'⟩

end Interval

section Bit

@[simp]
theorem bit0_inj : bit0 a = bit0 b ↔ a = b :=
  ⟨fun h =>
      by 
        rcases lt_trichotomyₓ a b with (h₁ | h₂ | h₃)
        ·
          exact absurd h (ne_of_ltₓ (add_lt_add h₁ h₁))
        ·
          exact h₂
        ·
          exact absurd h.symm (ne_of_ltₓ (add_lt_add h₃ h₃)),
    fun h => congr_argₓ _ h⟩

@[simp]
theorem bit0_eq_zero_iff : bit0 a = 0 ↔ a = 0 :=
  by 
    simpa only [bit0_zero] using @bit0_inj a 0

@[simp]
theorem bit0_eq_top_iff : bit0 a = ∞ ↔ a = ∞ :=
  by 
    rw [bit0, add_eq_top, or_selfₓ]

@[simp]
theorem bit1_inj : bit1 a = bit1 b ↔ a = b :=
  ⟨fun h =>
      by 
        unfold bit1  at h 
        rwa [add_left_injₓ, bit0_inj] at h 
        simp [lt_top_iff_ne_top],
    fun h => congr_argₓ _ h⟩

@[simp]
theorem bit1_ne_zero : bit1 a ≠ 0 :=
  by 
    unfold bit1 <;> simp 

@[simp]
theorem bit1_eq_one_iff : bit1 a = 1 ↔ a = 0 :=
  by 
    simpa only [bit1_zero] using @bit1_inj a 0

@[simp]
theorem bit1_eq_top_iff : bit1 a = ∞ ↔ a = ∞ :=
  by 
    unfold bit1 <;> rw [add_eq_top] <;> simp 

end Bit

section Inv

noncomputable theory

instance  : HasInv ℝ≥0∞ :=
  ⟨fun a => Inf { b | 1 ≤ a*b }⟩

instance  : DivInvMonoidₓ ℝ≥0∞ :=
  { (inferInstance : Monoidₓ ℝ≥0∞) with inv := HasInv.inv }

@[simp]
theorem inv_zero : (0 : ℝ≥0∞)⁻¹ = ∞ :=
  show Inf { b:ℝ≥0∞ | 1 ≤ 0*b } = ∞by 
    simp  <;> rfl

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp] theorem inv_top : «expr = »(«expr ⁻¹»(«expr∞»()), 0) :=
«expr $ »(bot_unique, «expr $ »(le_of_forall_le_of_dense, λ
  (a)
  (h : «expr > »(a, 0)), «expr $ »(Inf_le, by simp [] [] [] ["[", "*", ",", expr ne_of_gt h, ",", expr top_mul, "]"] [] [])))

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp, norm_cast #[]]
theorem coe_inv (hr : «expr ≠ »(r, 0)) : «expr = »((«expr↑ »(«expr ⁻¹»(r)) : «exprℝ≥0∞»()), «expr ⁻¹»(«expr↑ »(r))) :=
le_antisymm «expr $ »(le_Inf, assume
 (b)
 (hb : «expr ≤ »(1, «expr * »(«expr↑ »(r), b))), «expr $ »(coe_le_iff.2, by rintros [ident b, ident rfl]; rwa ["[", "<-", expr coe_mul, ",", "<-", expr coe_one, ",", expr coe_le_coe, ",", "<-", expr nnreal.inv_le hr, "]"] ["at", ident hb])) «expr $ »(Inf_le, by simp [] [] [] [] [] []; rw ["[", "<-", expr coe_mul, ",", expr mul_inv_cancel hr, "]"] []; exact [expr le_refl 1])

theorem coe_inv_le : («expr↑ » (r⁻¹) : ℝ≥0∞) ≤ «expr↑ » r⁻¹ :=
  if hr : r = 0 then
    by 
      simp only [hr, inv_zero, coe_zero, le_top]
  else
    by 
      simp only [coe_inv hr, le_reflₓ]

@[normCast]
theorem coe_inv_two : ((2⁻¹ :  ℝ≥0 ) : ℝ≥0∞) = 2⁻¹ :=
  by 
    rw [coe_inv (ne_of_gtₓ _root_.zero_lt_two), coe_two]

@[simp, normCast]
theorem coe_div (hr : r ≠ 0) : («expr↑ » (p / r) : ℝ≥0∞) = p / r :=
  by 
    rw [div_eq_mul_inv, div_eq_mul_inv, coe_mul, coe_inv hr]

theorem div_zero (h : a ≠ 0) : a / 0 = ∞ :=
  by 
    simp [div_eq_mul_inv, h]

@[simp]
theorem inv_one : (1 : ℝ≥0∞)⁻¹ = 1 :=
  by 
    simpa only [coe_inv one_ne_zero, coe_one] using coe_eq_coe.2 inv_one

@[simp]
theorem div_one {a : ℝ≥0∞} : a / 1 = a :=
  by 
    rw [div_eq_mul_inv, inv_one, mul_oneₓ]

protected theorem inv_pow {n : ℕ} : (a ^ n)⁻¹ = a⁻¹ ^ n :=
  by 
    byCases' a = 0 <;> cases a <;> cases n <;> simp_all [none_eq_top, some_eq_coe, zero_pow, top_pow, Nat.zero_lt_succₓ]
    rw [←coe_inv h, ←coe_pow, ←coe_inv (pow_ne_zero _ h), ←inv_pow₀, coe_pow]

@[simp]
theorem inv_invₓ : a⁻¹⁻¹ = a :=
  by 
    byCases' a = 0 <;> cases a <;> simp_all [none_eq_top, some_eq_coe, -coe_inv, (coe_inv _).symm]

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem inv_involutive : function.involutive (λ a : «exprℝ≥0∞»(), «expr ⁻¹»(a)) := λ a, ennreal.inv_inv

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem inv_bijective : function.bijective (λ a : «exprℝ≥0∞»(), «expr ⁻¹»(a)) := ennreal.inv_involutive.bijective

@[simp]
theorem inv_eq_inv : a⁻¹ = b⁻¹ ↔ a = b :=
  inv_bijective.1.eq_iff

@[simp]
theorem inv_eq_top : a⁻¹ = ∞ ↔ a = 0 :=
  inv_zero ▸ inv_eq_inv

theorem inv_ne_top : a⁻¹ ≠ ∞ ↔ a ≠ 0 :=
  by 
    simp 

@[simp]
theorem inv_lt_top {x : ℝ≥0∞} : x⁻¹ < ∞ ↔ 0 < x :=
  by 
    simp only [lt_top_iff_ne_top, inv_ne_top, pos_iff_ne_zero]

theorem div_lt_top {x y : ℝ≥0∞} (h1 : x ≠ ∞) (h2 : y ≠ 0) : x / y < ∞ :=
  mul_lt_top h1 (inv_ne_top.mpr h2)

@[simp]
theorem inv_eq_zero : a⁻¹ = 0 ↔ a = ∞ :=
  inv_top ▸ inv_eq_inv

theorem inv_ne_zero : a⁻¹ ≠ 0 ↔ a ≠ ∞ :=
  by 
    simp 

@[simp]
theorem inv_pos : 0 < a⁻¹ ↔ a ≠ ∞ :=
  pos_iff_ne_zero.trans inv_ne_zero

@[simp]
theorem inv_lt_inv : a⁻¹ < b⁻¹ ↔ b < a :=
  by 
    cases a <;> cases b <;> simp only [some_eq_coe, none_eq_top, inv_top]
    ·
      simp only [lt_irreflₓ]
    ·
      exact inv_pos.trans lt_top_iff_ne_top.symm
    ·
      simp only [not_lt_zero, not_top_lt]
    ·
      cases' eq_or_lt_of_le (zero_le a) with ha ha <;> cases' eq_or_lt_of_le (zero_le b) with hb hb
      ·
        subst a 
        subst b 
        simp 
      ·
        subst a 
        simp 
      ·
        subst b 
        simp [pos_iff_ne_zero, lt_top_iff_ne_top, inv_ne_top]
      ·
        rw [←coe_inv (ne_of_gtₓ ha), ←coe_inv (ne_of_gtₓ hb), coe_lt_coe, coe_lt_coe]
        simp only [nnreal.coe_lt_coe.symm] at *
        exact inv_lt_inv ha hb

theorem inv_lt_iff_inv_lt : a⁻¹ < b ↔ b⁻¹ < a :=
  by 
    simpa only [inv_invₓ] using @inv_lt_inv a (b⁻¹)

theorem lt_inv_iff_lt_inv : a < b⁻¹ ↔ b < a⁻¹ :=
  by 
    simpa only [inv_invₓ] using @inv_lt_inv (a⁻¹) b

@[simp]
theorem inv_le_inv : a⁻¹ ≤ b⁻¹ ↔ b ≤ a :=
  by 
    simp only [le_iff_lt_or_eqₓ, inv_lt_inv, inv_eq_inv, eq_comm]

theorem inv_le_iff_inv_le : a⁻¹ ≤ b ↔ b⁻¹ ≤ a :=
  by 
    simpa only [inv_invₓ] using @inv_le_inv a (b⁻¹)

theorem le_inv_iff_le_inv : a ≤ b⁻¹ ↔ b ≤ a⁻¹ :=
  by 
    simpa only [inv_invₓ] using @inv_le_inv (a⁻¹) b

@[simp]
theorem inv_le_one : a⁻¹ ≤ 1 ↔ 1 ≤ a :=
  inv_le_iff_inv_le.trans$
    by 
      rw [inv_one]

theorem one_le_inv : 1 ≤ a⁻¹ ↔ a ≤ 1 :=
  le_inv_iff_le_inv.trans$
    by 
      rw [inv_one]

@[simp]
theorem inv_lt_one : a⁻¹ < 1 ↔ 1 < a :=
  inv_lt_iff_inv_lt.trans$
    by 
      rw [inv_one]

theorem pow_le_pow_of_le_one {n m : ℕ} (ha : a ≤ 1) (h : n ≤ m) : a ^ m ≤ a ^ n :=
  by 
    rw [←@inv_invₓ a, ←Ennreal.inv_pow, ←@Ennreal.inv_pow (a⁻¹), inv_le_inv]
    exact pow_le_pow (one_le_inv.2 ha) h

@[simp]
theorem div_top : a / ∞ = 0 :=
  by 
    rw [div_eq_mul_inv, inv_top, mul_zero]

@[simp]
theorem top_div_coe : ∞ / p = ∞ :=
  by 
    simp [div_eq_mul_inv, top_mul]

theorem top_div_of_ne_top (h : a ≠ ∞) : ∞ / a = ∞ :=
  by 
    lift a to  ℝ≥0  using h 
    exact top_div_coe

theorem top_div_of_lt_top (h : a < ∞) : ∞ / a = ∞ :=
  top_div_of_ne_top h.ne

theorem top_div : ∞ / a = if a = ∞ then 0 else ∞ :=
  by 
    byCases' a = ∞ <;> simp [top_div_of_ne_top]

@[simp]
theorem zero_div : 0 / a = 0 :=
  zero_mul (a⁻¹)

theorem div_eq_top : a / b = ∞ ↔ a ≠ 0 ∧ b = 0 ∨ a = ∞ ∧ b ≠ ∞ :=
  by 
    simp [div_eq_mul_inv, Ennreal.mul_eq_top]

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem le_div_iff_mul_le
(h0 : «expr ∨ »(«expr ≠ »(b, 0), «expr ≠ »(c, 0)))
(ht : «expr ∨ »(«expr ≠ »(b, «expr∞»()), «expr ≠ »(c, «expr∞»()))) : «expr ↔ »(«expr ≤ »(a, «expr / »(c, b)), «expr ≤ »(«expr * »(a, b), c)) :=
begin
  cases [expr b] [],
  { simp [] [] [] [] [] ["at", ident ht],
    split,
    { assume [binders (ha)],
      simp [] [] [] [] [] ["at", ident ha],
      simp [] [] [] ["[", expr ha, "]"] [] [] },
    { contrapose [] [],
      assume [binders (ha)],
      simp [] [] [] [] [] ["at", ident ha],
      have [] [":", expr «expr = »(«expr * »(a, «expr∞»()), «expr∞»())] [],
      by simp [] [] [] ["[", expr ennreal.mul_eq_top, ",", expr ha, "]"] [] [],
      simp [] [] [] ["[", expr this, ",", expr ht, "]"] [] [] } },
  by_cases [expr hb, ":", expr «expr ≠ »(b, 0)],
  { have [] [":", expr «expr ≠ »((b : «exprℝ≥0∞»()), 0)] [],
    by simp [] [] [] ["[", expr hb, "]"] [] [],
    rw ["[", "<-", expr ennreal.mul_le_mul_left this coe_ne_top, "]"] [],
    suffices [] [":", expr «expr ↔ »(«expr ≤ »(«expr * »(«expr↑ »(b), a), «expr * »(«expr * »(«expr↑ »(b), «expr↑ »(«expr ⁻¹»(b))), c)), «expr ≤ »(«expr * »(a, «expr↑ »(b)), c))],
    { simpa [] [] [] ["[", expr some_eq_coe, ",", expr div_eq_mul_inv, ",", expr hb, ",", expr mul_left_comm, ",", expr mul_comm, ",", expr mul_assoc, "]"] [] [] },
    rw ["[", "<-", expr coe_mul, ",", expr mul_inv_cancel hb, ",", expr coe_one, ",", expr one_mul, ",", expr mul_comm, "]"] [] },
  { simp [] [] [] [] [] ["at", ident hb],
    simp [] [] [] ["[", expr hb, "]"] [] ["at", ident h0],
    have [] [":", expr «expr = »(«expr / »(c, 0), «expr∞»())] [],
    by simp [] [] [] ["[", expr div_eq_top, ",", expr h0, "]"] [] [],
    simp [] [] [] ["[", expr hb, ",", expr this, "]"] [] [] }
end

theorem div_le_iff_le_mul (hb0 : b ≠ 0 ∨ c ≠ ∞) (hbt : b ≠ ∞ ∨ c ≠ 0) : a / b ≤ c ↔ a ≤ c*b :=
  by 
    suffices  : (a*b⁻¹) ≤ c ↔ a ≤ c / b⁻¹
    ·
      simpa [div_eq_mul_inv]
    refine' (le_div_iff_mul_le _ _).symm <;> simpa

theorem lt_div_iff_mul_lt (hb0 : b ≠ 0 ∨ c ≠ ∞) (hbt : b ≠ ∞ ∨ c ≠ 0) : c < a / b ↔ (c*b) < a :=
  lt_iff_lt_of_le_iff_le (div_le_iff_le_mul hb0 hbt)

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem div_le_of_le_mul (h : «expr ≤ »(a, «expr * »(b, c))) : «expr ≤ »(«expr / »(a, c), b) :=
begin
  by_cases [expr h0, ":", expr «expr = »(c, 0)],
  { have [] [":", expr «expr = »(a, 0)] [],
    by simpa [] [] [] ["[", expr h0, "]"] [] ["using", expr h],
    simp [] [] [] ["[", "*", "]"] [] [] },
  by_cases [expr hinf, ":", expr «expr = »(c, «expr∞»())],
  by simp [] [] [] ["[", expr hinf, "]"] [] [],
  exact [expr (div_le_iff_le_mul (or.inl h0) (or.inl hinf)).2 h]
end

theorem div_le_of_le_mul' (h : a ≤ b*c) : a / b ≤ c :=
  div_le_of_le_mul$ mul_commₓ b c ▸ h

theorem mul_le_of_le_div (h : a ≤ b / c) : (a*c) ≤ b :=
  by 
    rcases _root_.em (c = 0 ∧ b = 0 ∨ c = ∞ ∧ b = ∞) with ((⟨rfl, rfl⟩ | ⟨rfl, rfl⟩) | H)
    ·
      rw [mul_zero]
      exact le_rfl
    ·
      exact le_top
    ·
      simp only [not_or_distrib, not_and_distrib] at H 
      rwa [←le_div_iff_mul_le H.1 H.2]

theorem mul_le_of_le_div' (h : a ≤ b / c) : (c*a) ≤ b :=
  mul_commₓ a c ▸ mul_le_of_le_div h

protected theorem div_lt_iff (h0 : b ≠ 0 ∨ c ≠ 0) (ht : b ≠ ∞ ∨ c ≠ ∞) : c / b < a ↔ c < a*b :=
  lt_iff_lt_of_le_iff_le$ le_div_iff_mul_le h0 ht

theorem mul_lt_of_lt_div (h : a < b / c) : (a*c) < b :=
  by 
    contrapose! h 
    exact Ennreal.div_le_of_le_mul h

theorem mul_lt_of_lt_div' (h : a < b / c) : (c*a) < b :=
  mul_commₓ a c ▸ mul_lt_of_lt_div h

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem inv_le_iff_le_mul : («expr = »(b, «expr∞»()) → «expr ≠ »(a, 0)) → («expr = »(a, «expr∞»()) → «expr ≠ »(b, 0)) → «expr ↔ »(«expr ≤ »(«expr ⁻¹»(a), b), «expr ≤ »(1, «expr * »(a, b))) :=
begin
  cases [expr a] []; cases [expr b] []; simp [] [] [] ["[", expr none_eq_top, ",", expr some_eq_coe, ",", expr mul_top, ",", expr top_mul, "]"] [] [] { contextual := tt },
  by_cases [expr «expr = »(a, 0)]; simp [] [] [] ["[", "*", ",", "-", ident coe_mul, ",", expr coe_mul.symm, ",", "-", ident coe_inv, ",", expr (coe_inv _).symm, ",", expr nnreal.inv_le, "]"] [] []
end

@[simp]
theorem le_inv_iff_mul_le : a ≤ b⁻¹ ↔ (a*b) ≤ 1 :=
  by 
    cases b
    ·
      byCases' a = 0 <;> simp [none_eq_top, mul_top]
    byCases' b = 0 <;> simp [some_eq_coe, le_div_iff_mul_le]
    suffices  : a ≤ 1 / b ↔ (a*b) ≤ 1
    ·
      simpa [div_eq_mul_inv, h]
    exact le_div_iff_mul_le (Or.inl (mt coe_eq_coe.1 h)) (Or.inl coe_ne_top)

theorem mul_inv_cancel (h0 : a ≠ 0) (ht : a ≠ ∞) : (a*a⁻¹) = 1 :=
  by 
    lift a to  ℝ≥0  using ht 
    normCast  at *
    exact mul_inv_cancel h0

theorem inv_mul_cancel (h0 : a ≠ 0) (ht : a ≠ ∞) : (a⁻¹*a) = 1 :=
  mul_commₓ a (a⁻¹) ▸ mul_inv_cancel h0 ht

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem eq_inv_of_mul_eq_one (h : «expr = »(«expr * »(a, b), 1)) : «expr = »(a, «expr ⁻¹»(b)) :=
begin
  rcases [expr eq_or_ne b «expr∞»(), "with", ident rfl, "|", ident hb],
  { have [] [":", expr false] [],
    by simpa [] [] [] ["[", expr left_ne_zero_of_mul_eq_one h, "]"] [] ["using", expr h],
    exact [expr this.elim] },
  { rw ["[", "<-", expr mul_one a, ",", "<-", expr mul_inv_cancel (right_ne_zero_of_mul_eq_one h) hb, ",", "<-", expr mul_assoc, ",", expr h, ",", expr one_mul, "]"] [] }
end

theorem mul_le_iff_le_inv {a b r : ℝ≥0∞} (hr₀ : r ≠ 0) (hr₁ : r ≠ ∞) : (r*a) ≤ b ↔ a ≤ r⁻¹*b :=
  by 
    rw [←@Ennreal.mul_le_mul_left _ a _ hr₀ hr₁, ←mul_assocₓ, mul_inv_cancel hr₀ hr₁, one_mulₓ]

theorem le_of_forall_nnreal_lt {x y : ℝ≥0∞} (h : ∀ (r :  ℝ≥0 ), «expr↑ » r < x → «expr↑ » r ≤ y) : x ≤ y :=
  by 
    refine' le_of_forall_ge_of_dense fun r hr => _ 
    lift r to  ℝ≥0  using ne_top_of_lt hr 
    exact h r hr

theorem le_of_forall_pos_nnreal_lt {x y : ℝ≥0∞} (h : ∀ (r :  ℝ≥0 ), 0 < r → «expr↑ » r < x → «expr↑ » r ≤ y) : x ≤ y :=
  le_of_forall_nnreal_lt$ fun r hr => (zero_le r).eq_or_lt.elim (fun h => h ▸ zero_le _) fun h0 => h r h0 hr

theorem eq_top_of_forall_nnreal_le {x : ℝ≥0∞} (h : ∀ (r :  ℝ≥0 ), «expr↑ » r ≤ x) : x = ∞ :=
  top_unique$ le_of_forall_nnreal_lt$ fun r hr => h r

theorem add_div {a b c : ℝ≥0∞} : (a+b) / c = (a / c)+b / c :=
  right_distrib a b (c⁻¹)

theorem div_add_div_same {a b c : ℝ≥0∞} : ((a / c)+b / c) = (a+b) / c :=
  Eq.symm$ right_distrib a b (c⁻¹)

theorem div_self (h0 : a ≠ 0) (hI : a ≠ ∞) : a / a = 1 :=
  mul_inv_cancel h0 hI

theorem mul_div_cancel (h0 : a ≠ 0) (hI : a ≠ ∞) : ((b / a)*a) = b :=
  by 
    rw [div_eq_mul_inv, mul_assocₓ, inv_mul_cancel h0 hI, mul_oneₓ]

theorem mul_div_cancel' (h0 : a ≠ 0) (hI : a ≠ ∞) : (a*b / a) = b :=
  by 
    rw [mul_commₓ, mul_div_cancel h0 hI]

theorem mul_div_le : (a*b / a) ≤ b :=
  by 
    byCases' h0 : a = 0
    ·
      simp [h0]
    byCases' hI : a = ∞
    ·
      simp [hI]
    rw [mul_div_cancel' h0 hI]
    exact le_reflₓ b

theorem inv_two_add_inv_two : ((2 : ℝ≥0∞)⁻¹+2⁻¹) = 1 :=
  by 
    rw [←two_mul, ←div_eq_mul_inv, div_self two_ne_zero two_ne_top]

theorem add_halves (a : ℝ≥0∞) : ((a / 2)+a / 2) = a :=
  by 
    rw [div_eq_mul_inv, ←mul_addₓ, inv_two_add_inv_two, mul_oneₓ]

@[simp]
theorem div_zero_iff : a / b = 0 ↔ a = 0 ∨ b = ∞ :=
  by 
    simp [div_eq_mul_inv]

@[simp]
theorem div_pos_iff : 0 < a / b ↔ a ≠ 0 ∧ b ≠ ∞ :=
  by 
    simp [pos_iff_ne_zero, not_or_distrib]

theorem half_pos {a : ℝ≥0∞} (h : a ≠ 0) : 0 < a / 2 :=
  by 
    simp [h]

theorem one_half_lt_one : (2⁻¹ : ℝ≥0∞) < 1 :=
  inv_lt_one.2$ one_lt_two

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem half_lt_self
{a : «exprℝ≥0∞»()}
(hz : «expr ≠ »(a, 0))
(ht : «expr ≠ »(a, «expr∞»())) : «expr < »(«expr / »(a, 2), a) :=
begin
  lift [expr a] ["to", expr «exprℝ≥0»()] ["using", expr ht] [],
  have [ident h] [":", expr «expr = »((2 : «exprℝ≥0∞»()), ((2 : «exprℝ≥0»()) : «exprℝ≥0∞»()))] [],
  from [expr rfl],
  have [ident h'] [":", expr «expr ≠ »((2 : «exprℝ≥0»()), 0)] [],
  from [expr _root_.two_ne_zero'],
  rw ["[", expr h, ",", "<-", expr coe_div h', ",", expr coe_lt_coe, "]"] [],
  norm_cast ["at", ident hz],
  exact [expr nnreal.half_lt_self hz]
end

theorem half_le_self : a / 2 ≤ a :=
  le_add_self.trans_eq (add_halves _)

theorem sub_half (h : a ≠ ∞) : a - a / 2 = a / 2 :=
  by 
    lift a to  ℝ≥0  using h 
    exact
      sub_eq_of_add_eq
        (mul_ne_top coe_ne_top$
          by 
            simp )
        (add_halves a)

@[simp]
theorem one_sub_inv_two : (1 : ℝ≥0∞) - 2⁻¹ = 2⁻¹ :=
  by 
    simpa only [div_eq_mul_inv, one_mulₓ] using sub_half one_ne_top

theorem exists_inv_nat_lt {a : ℝ≥0∞} (h : a ≠ 0) : ∃ n : ℕ, (n : ℝ≥0∞)⁻¹ < a :=
  @inv_invₓ a ▸
    by 
      simp only [inv_lt_inv, Ennreal.exists_nat_gt (inv_ne_top.2 h)]

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem exists_nat_pos_mul_gt
(ha : «expr ≠ »(a, 0))
(hb : «expr ≠ »(b, «expr∞»())) : «expr∃ , »((n «expr > » 0), «expr < »(b, «expr * »((n : exprℕ()), a))) :=
begin
  have [] [":", expr «expr ≠ »(«expr / »(b, a), «expr∞»())] [],
  from [expr mul_ne_top hb (inv_ne_top.2 ha)],
  refine [expr (ennreal.exists_nat_gt this).imp (λ n hn, _)],
  have [] [":", expr «expr < »(0, (n : «exprℝ≥0∞»()))] [],
  from [expr (zero_le _).trans_lt hn],
  refine [expr ⟨coe_nat_lt_coe_nat.1 this, _⟩],
  rwa ["[", "<-", expr ennreal.div_lt_iff (or.inl ha) (or.inr hb), "]"] []
end

theorem exists_nat_mul_gt (ha : a ≠ 0) (hb : b ≠ ∞) : ∃ n : ℕ, b < n*a :=
  (exists_nat_pos_mul_gt ha hb).imp$ fun n => Exists.snd

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem exists_nat_pos_inv_mul_lt
(ha : «expr ≠ »(a, «expr∞»()))
(hb : «expr ≠ »(b, 0)) : «expr∃ , »((n «expr > » 0), «expr < »(«expr * »(«expr ⁻¹»(((n : exprℕ()) : «exprℝ≥0∞»())), a), b)) :=
begin
  rcases [expr exists_nat_pos_mul_gt hb ha, "with", "⟨", ident n, ",", ident npos, ",", ident hn, "⟩"],
  have [] [":", expr «expr ≠ »((n : «exprℝ≥0∞»()), 0)] [":=", expr nat.cast_ne_zero.2 npos.lt.ne'],
  use ["[", expr n, ",", expr npos, "]"],
  rwa ["[", "<-", expr one_mul b, ",", "<-", expr inv_mul_cancel this coe_nat_ne_top, ",", expr mul_assoc, ",", expr mul_lt_mul_left (inv_ne_zero.2 coe_nat_ne_top) (inv_ne_top.2 this), "]"] []
end

theorem exists_nnreal_pos_mul_lt (ha : a ≠ ∞) (hb : b ≠ 0) : ∃ (n : _)(_ : n > 0), («expr↑ » (n :  ℝ≥0 )*a) < b :=
  by 
    rcases exists_nat_pos_inv_mul_lt ha hb with ⟨n, npos : 0 < n, hn⟩
    use (n :  ℝ≥0 )⁻¹
    simp [npos.ne', zero_lt_one]

theorem exists_inv_two_pow_lt (ha : a ≠ 0) : ∃ n : ℕ, 2⁻¹ ^ n < a :=
  by 
    rcases exists_inv_nat_lt ha with ⟨n, hn⟩
    simp only [←Ennreal.inv_pow]
    refine' ⟨n, lt_transₓ (inv_lt_inv.2 _) hn⟩
    normCast 
    exact n.lt_two_pow

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp, norm_cast #[]]
theorem coe_zpow
(hr : «expr ≠ »(r, 0))
(n : exprℤ()) : «expr = »((«expr↑ »(«expr ^ »(r, n)) : «exprℝ≥0∞»()), «expr ^ »(r, n)) :=
begin
  cases [expr n] [],
  { simp [] [] ["only"] ["[", expr int.of_nat_eq_coe, ",", expr coe_pow, ",", expr zpow_coe_nat, "]"] [] [] },
  { have [] [":", expr «expr ≠ »(«expr ^ »(r, n.succ), 0)] [":=", expr pow_ne_zero «expr + »(n, 1) hr],
    simp [] [] ["only"] ["[", expr zpow_neg_succ_of_nat, ",", expr coe_inv this, ",", expr coe_pow, "]"] [] [] }
end

theorem zpow_pos (ha : a ≠ 0) (h'a : a ≠ ∞) (n : ℤ) : 0 < a ^ n :=
  by 
    cases n
    ·
      exact Ennreal.pow_pos ha.bot_lt n
    ·
      simp only [h'a, pow_eq_top_iff, zpow_neg_succ_of_nat, Ne.def, not_false_iff, inv_pos, false_andₓ]

theorem zpow_lt_top (ha : a ≠ 0) (h'a : a ≠ ∞) (n : ℤ) : a ^ n < ∞ :=
  by 
    cases n
    ·
      exact Ennreal.pow_lt_top h'a.lt_top _
    ·
      simp only [Ennreal.pow_pos ha.bot_lt (n+1), zpow_neg_succ_of_nat, inv_lt_top]

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem exists_mem_Ico_zpow
{x y : «exprℝ≥0∞»()}
(hx : «expr ≠ »(x, 0))
(h'x : «expr ≠ »(x, «expr∞»()))
(hy : «expr < »(1, y))
(h'y : «expr ≠ »(y, «expr⊤»())) : «expr∃ , »((n : exprℤ()), «expr ∈ »(x, Ico «expr ^ »(y, n) «expr ^ »(y, «expr + »(n, 1)))) :=
begin
  lift [expr x] ["to", expr «exprℝ≥0»()] ["using", expr h'x] [],
  lift [expr y] ["to", expr «exprℝ≥0»()] ["using", expr h'y] [],
  have [ident A] [":", expr «expr ≠ »(y, 0)] [],
  by simpa [] [] ["only"] ["[", expr ne.def, ",", expr coe_eq_zero, "]"] [] ["using", expr (ennreal.zero_lt_one.trans hy).ne'],
  obtain ["⟨", ident n, ",", ident hn, ",", ident h'n, "⟩", ":", expr «expr∃ , »((n : exprℤ()), «expr ∧ »(«expr ≤ »(«expr ^ »(y, n), x), «expr < »(x, «expr ^ »(y, «expr + »(n, 1)))))],
  { refine [expr nnreal.exists_mem_Ico_zpow _ (one_lt_coe_iff.1 hy)],
    simpa [] [] ["only"] ["[", expr ne.def, ",", expr coe_eq_zero, "]"] [] ["using", expr hx] },
  refine [expr ⟨n, _, _⟩],
  { rwa ["[", "<-", expr ennreal.coe_zpow A, ",", expr ennreal.coe_le_coe, "]"] [] },
  { rwa ["[", "<-", expr ennreal.coe_zpow A, ",", expr ennreal.coe_lt_coe, "]"] [] }
end

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem exists_mem_Ioc_zpow
{x y : «exprℝ≥0∞»()}
(hx : «expr ≠ »(x, 0))
(h'x : «expr ≠ »(x, «expr∞»()))
(hy : «expr < »(1, y))
(h'y : «expr ≠ »(y, «expr⊤»())) : «expr∃ , »((n : exprℤ()), «expr ∈ »(x, Ioc «expr ^ »(y, n) «expr ^ »(y, «expr + »(n, 1)))) :=
begin
  lift [expr x] ["to", expr «exprℝ≥0»()] ["using", expr h'x] [],
  lift [expr y] ["to", expr «exprℝ≥0»()] ["using", expr h'y] [],
  have [ident A] [":", expr «expr ≠ »(y, 0)] [],
  by simpa [] [] ["only"] ["[", expr ne.def, ",", expr coe_eq_zero, "]"] [] ["using", expr (ennreal.zero_lt_one.trans hy).ne'],
  obtain ["⟨", ident n, ",", ident hn, ",", ident h'n, "⟩", ":", expr «expr∃ , »((n : exprℤ()), «expr ∧ »(«expr < »(«expr ^ »(y, n), x), «expr ≤ »(x, «expr ^ »(y, «expr + »(n, 1)))))],
  { refine [expr nnreal.exists_mem_Ioc_zpow _ (one_lt_coe_iff.1 hy)],
    simpa [] [] ["only"] ["[", expr ne.def, ",", expr coe_eq_zero, "]"] [] ["using", expr hx] },
  refine [expr ⟨n, _, _⟩],
  { rwa ["[", "<-", expr ennreal.coe_zpow A, ",", expr ennreal.coe_lt_coe, "]"] [] },
  { rwa ["[", "<-", expr ennreal.coe_zpow A, ",", expr ennreal.coe_le_coe, "]"] [] }
end

theorem Ioo_zero_top_eq_Union_Ico_zpow {y : ℝ≥0∞} (hy : 1 < y) (h'y : y ≠ ⊤) :
  Ioo (0 : ℝ≥0∞) (∞ : ℝ≥0∞) = ⋃n : ℤ, Ico (y ^ n) (y ^ n+1) :=
  by 
    ext x 
    simp only [mem_Union, mem_Ioo, mem_Ico]
    split 
    ·
      rintro ⟨hx, h'x⟩
      exact exists_mem_Ico_zpow hx.ne' h'x.ne hy h'y
    ·
      rintro ⟨n, hn, h'n⟩
      split 
      ·
        apply lt_of_lt_of_leₓ _ hn 
        exact Ennreal.zpow_pos (ennreal.zero_lt_one.trans hy).ne' h'y _
      ·
        apply lt_transₓ h'n _ 
        exact Ennreal.zpow_lt_top (ennreal.zero_lt_one.trans hy).ne' h'y _

-- error in Data.Real.Ennreal: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem zpow_le_of_le
{x : «exprℝ≥0∞»()}
(hx : «expr ≤ »(1, x))
{a b : exprℤ()}
(h : «expr ≤ »(a, b)) : «expr ≤ »(«expr ^ »(x, a), «expr ^ »(x, b)) :=
begin
  induction [expr a] [] ["with", ident a, ident a] []; induction [expr b] [] ["with", ident b, ident b] [],
  { simp [] [] [] [] [] [],
    apply [expr pow_le_pow hx],
    apply [expr int.le_of_coe_nat_le_coe_nat h] },
  { apply [expr absurd h],
    apply [expr not_le_of_gt],
    exact [expr lt_of_lt_of_le (int.neg_succ_lt_zero _) (int.of_nat_nonneg _)] },
  { simp [] [] ["only"] ["[", expr zpow_neg_succ_of_nat, ",", expr int.of_nat_eq_coe, ",", expr zpow_coe_nat, "]"] [] [],
    refine [expr le_trans (inv_le_one.2 _) _]; apply [expr ennreal.one_le_pow_of_one_le hx] },
  { simp [] [] ["only"] ["[", expr zpow_neg_succ_of_nat, "]"] [] [],
    apply [expr inv_le_inv.2],
    { apply [expr pow_le_pow hx],
      have [] [":", expr «expr ≤ »(«expr- »((«expr↑ »(«expr + »(a, 1)) : exprℤ())), «expr- »((«expr↑ »(«expr + »(b, 1)) : exprℤ())))] [],
      from [expr h],
      have [ident h'] [] [":=", expr le_of_neg_le_neg this],
      apply [expr int.le_of_coe_nat_le_coe_nat h'] },
    repeat { apply [expr pow_pos (lt_of_lt_of_le zero_lt_one hx)] } }
end

theorem monotone_zpow {x : ℝ≥0∞} (hx : 1 ≤ x) : Monotone ((· ^ ·) x : ℤ → ℝ≥0∞) :=
  fun a b h => zpow_le_of_le hx h

theorem zpow_add {x : ℝ≥0∞} (hx : x ≠ 0) (h'x : x ≠ ∞) (m n : ℤ) : (x ^ m+n) = (x ^ m)*x ^ n :=
  by 
    lift x to  ℝ≥0  using h'x 
    replace hx : x ≠ 0
    ·
      simpa only [Ne.def, coe_eq_zero] using hx 
    simp only [←coe_zpow hx, zpow_add₀ hx, coe_mul]

end Inv

section Real

theorem to_real_add (ha : a ≠ ∞) (hb : b ≠ ∞) : (a+b).toReal = a.to_real+b.to_real :=
  by 
    lift a to  ℝ≥0  using ha 
    lift b to  ℝ≥0  using hb 
    rfl

theorem to_real_sub_of_le {a b : ℝ≥0∞} (h : b ≤ a) (ha : a ≠ ∞) : (a - b).toReal = a.to_real - b.to_real :=
  by 
    lift b to  ℝ≥0  using ne_top_of_le_ne_top ha h 
    lift a to  ℝ≥0  using ha 
    simp only [←Ennreal.coe_sub, Ennreal.coe_to_real, Nnreal.coe_sub (ennreal.coe_le_coe.mp h)]

theorem le_to_real_sub {a b : ℝ≥0∞} (hb : b ≠ ∞) : a.to_real - b.to_real ≤ (a - b).toReal :=
  by 
    lift b to  ℝ≥0  using hb 
    cases a
    ·
      simp 
    ·
      simp only [some_eq_coe, ←coe_sub, Nnreal.sub_def, Real.coe_to_nnreal', coe_to_real]
      exact le_max_leftₓ _ _

theorem to_real_add_le : (a+b).toReal ≤ a.to_real+b.to_real :=
  if ha : a = ∞ then
    by 
      simp only [ha, top_add, top_to_real, zero_addₓ, to_real_nonneg]
  else
    if hb : b = ∞ then
      by 
        simp only [hb, add_top, top_to_real, add_zeroₓ, to_real_nonneg]
    else le_of_eqₓ (to_real_add ha hb)

theorem of_real_add {p q : ℝ} (hp : 0 ≤ p) (hq : 0 ≤ q) : Ennreal.ofReal (p+q) = Ennreal.ofReal p+Ennreal.ofReal q :=
  by 
    rw [Ennreal.ofReal, Ennreal.ofReal, Ennreal.ofReal, ←coe_add, coe_eq_coe, Real.to_nnreal_add hp hq]

theorem of_real_add_le {p q : ℝ} : Ennreal.ofReal (p+q) ≤ Ennreal.ofReal p+Ennreal.ofReal q :=
  coe_le_coe.2 Real.to_nnreal_add_le

@[simp]
theorem to_real_le_to_real (ha : a ≠ ∞) (hb : b ≠ ∞) : a.to_real ≤ b.to_real ↔ a ≤ b :=
  by 
    lift a to  ℝ≥0  using ha 
    lift b to  ℝ≥0  using hb 
    normCast

theorem to_real_mono (hb : b ≠ ∞) (h : a ≤ b) : a.to_real ≤ b.to_real :=
  (to_real_le_to_real (h.trans_lt (lt_top_iff_ne_top.2 hb)).Ne hb).2 h

@[simp]
theorem to_real_lt_to_real (ha : a ≠ ∞) (hb : b ≠ ∞) : a.to_real < b.to_real ↔ a < b :=
  by 
    lift a to  ℝ≥0  using ha 
    lift b to  ℝ≥0  using hb 
    normCast

theorem to_real_strict_mono (hb : b ≠ ∞) (h : a < b) : a.to_real < b.to_real :=
  (to_real_lt_to_real (h.trans (lt_top_iff_ne_top.2 hb)).Ne hb).2 h

theorem to_real_max (hr : a ≠ ∞) (hp : b ≠ ∞) : Ennreal.toReal (max a b) = max (Ennreal.toReal a) (Ennreal.toReal b) :=
  (le_totalₓ a b).elim
    (fun h =>
      by 
        simp only [h, (Ennreal.to_real_le_to_real hr hp).2 h, max_eq_rightₓ])
    fun h =>
      by 
        simp only [h, (Ennreal.to_real_le_to_real hp hr).2 h, max_eq_leftₓ]

theorem to_nnreal_pos_iff : 0 < a.to_nnreal ↔ 0 < a ∧ a ≠ ∞ :=
  by 
    cases a
    ·
      simp [none_eq_top]
    ·
      simp [some_eq_coe]

theorem to_real_pos_iff : 0 < a.to_real ↔ 0 < a ∧ a ≠ ∞ :=
  Nnreal.coe_pos.trans to_nnreal_pos_iff

theorem of_real_le_of_real {p q : ℝ} (h : p ≤ q) : Ennreal.ofReal p ≤ Ennreal.ofReal q :=
  by 
    simp [Ennreal.ofReal, Real.to_nnreal_le_to_nnreal h]

theorem of_real_le_of_le_to_real {a : ℝ} {b : ℝ≥0∞} (h : a ≤ Ennreal.toReal b) : Ennreal.ofReal a ≤ b :=
  (of_real_le_of_real h).trans of_real_to_real_le

@[simp]
theorem of_real_le_of_real_iff {p q : ℝ} (h : 0 ≤ q) : Ennreal.ofReal p ≤ Ennreal.ofReal q ↔ p ≤ q :=
  by 
    rw [Ennreal.ofReal, Ennreal.ofReal, coe_le_coe, Real.to_nnreal_le_to_nnreal_iff h]

@[simp]
theorem of_real_lt_of_real_iff {p q : ℝ} (h : 0 < q) : Ennreal.ofReal p < Ennreal.ofReal q ↔ p < q :=
  by 
    rw [Ennreal.ofReal, Ennreal.ofReal, coe_lt_coe, Real.to_nnreal_lt_to_nnreal_iff h]

theorem of_real_lt_of_real_iff_of_nonneg {p q : ℝ} (hp : 0 ≤ p) : Ennreal.ofReal p < Ennreal.ofReal q ↔ p < q :=
  by 
    rw [Ennreal.ofReal, Ennreal.ofReal, coe_lt_coe, Real.to_nnreal_lt_to_nnreal_iff_of_nonneg hp]

@[simp]
theorem of_real_pos {p : ℝ} : 0 < Ennreal.ofReal p ↔ 0 < p :=
  by 
    simp [Ennreal.ofReal]

@[simp]
theorem of_real_eq_zero {p : ℝ} : Ennreal.ofReal p = 0 ↔ p ≤ 0 :=
  by 
    simp [Ennreal.ofReal]

@[simp]
theorem zero_eq_of_real {p : ℝ} : 0 = Ennreal.ofReal p ↔ p ≤ 0 :=
  eq_comm.trans of_real_eq_zero

theorem of_real_le_iff_le_to_real {a : ℝ} {b : ℝ≥0∞} (hb : b ≠ ∞) : Ennreal.ofReal a ≤ b ↔ a ≤ Ennreal.toReal b :=
  by 
    lift b to  ℝ≥0  using hb 
    simpa [Ennreal.ofReal, Ennreal.toReal] using Real.to_nnreal_le_iff_le_coe

theorem of_real_lt_iff_lt_to_real {a : ℝ} {b : ℝ≥0∞} (ha : 0 ≤ a) (hb : b ≠ ∞) :
  Ennreal.ofReal a < b ↔ a < Ennreal.toReal b :=
  by 
    lift b to  ℝ≥0  using hb 
    simpa [Ennreal.ofReal, Ennreal.toReal] using Real.to_nnreal_lt_iff_lt_coe ha

theorem le_of_real_iff_to_real_le {a : ℝ≥0∞} {b : ℝ} (ha : a ≠ ∞) (hb : 0 ≤ b) :
  a ≤ Ennreal.ofReal b ↔ Ennreal.toReal a ≤ b :=
  by 
    lift a to  ℝ≥0  using ha 
    simpa [Ennreal.ofReal, Ennreal.toReal] using Real.le_to_nnreal_iff_coe_le hb

theorem to_real_le_of_le_of_real {a : ℝ≥0∞} {b : ℝ} (hb : 0 ≤ b) (h : a ≤ Ennreal.ofReal b) : Ennreal.toReal a ≤ b :=
  have ha : a ≠ ∞ := ne_top_of_le_ne_top of_real_ne_top h
  (le_of_real_iff_to_real_le ha hb).1 h

theorem lt_of_real_iff_to_real_lt {a : ℝ≥0∞} {b : ℝ} (ha : a ≠ ∞) : a < Ennreal.ofReal b ↔ Ennreal.toReal a < b :=
  by 
    lift a to  ℝ≥0  using ha 
    simpa [Ennreal.ofReal, Ennreal.toReal] using Real.lt_to_nnreal_iff_coe_lt

theorem of_real_mul {p q : ℝ} (hp : 0 ≤ p) : Ennreal.ofReal (p*q) = Ennreal.ofReal p*Ennreal.ofReal q :=
  by 
    simp only [Ennreal.ofReal, coe_mul.symm, coe_eq_coe]
    exact Real.to_nnreal_mul hp

theorem of_real_pow {p : ℝ} (hp : 0 ≤ p) (n : ℕ) : Ennreal.ofReal (p ^ n) = Ennreal.ofReal p ^ n :=
  by 
    rw [of_real_eq_coe_nnreal hp, ←coe_pow, ←of_real_coe_nnreal, Nnreal.coe_pow, Nnreal.coe_mk]

theorem of_real_inv_of_pos {x : ℝ} (hx : 0 < x) : Ennreal.ofReal x⁻¹ = Ennreal.ofReal (x⁻¹) :=
  by 
    rw [Ennreal.ofReal, Ennreal.ofReal,
      ←@coe_inv (Real.toNnreal x)
        (by 
          simp [hx]),
      coe_eq_coe, real.to_nnreal_inv.symm]

theorem of_real_div_of_pos {x y : ℝ} (hy : 0 < y) : Ennreal.ofReal (x / y) = Ennreal.ofReal x / Ennreal.ofReal y :=
  by 
    rw [div_eq_inv_mul, div_eq_mul_inv, of_real_mul (inv_nonneg.2 hy.le), of_real_inv_of_pos hy, mul_commₓ]

theorem to_real_of_real_mul (c : ℝ) (a : ℝ≥0∞) (h : 0 ≤ c) : Ennreal.toReal (Ennreal.ofReal c*a) = c*Ennreal.toReal a :=
  by 
    cases a
    ·
      simp only [none_eq_top, Ennreal.toReal, top_to_nnreal, Nnreal.coe_zero, mul_zero, mul_top]
      byCases' h' : c ≤ 0
      ·
        rw [if_pos]
        ·
          simp 
        ·
          convert of_real_zero 
          exact le_antisymmₓ h' h
      ·
        rw [if_neg]
        rfl 
        rw [of_real_eq_zero]
        assumption
    ·
      simp only [Ennreal.toReal, Ennreal.toNnreal]
      simp only [some_eq_coe, Ennreal.ofReal, coe_mul.symm, to_nnreal_coe, Nnreal.coe_mul]
      congr 
      apply Real.coe_to_nnreal 
      exact h

@[simp]
theorem to_nnreal_mul_top (a : ℝ≥0∞) : Ennreal.toNnreal (a*∞) = 0 :=
  by 
    byCases' h : a = 0
    ·
      rw [h, zero_mul, zero_to_nnreal]
    ·
      rw [mul_top, if_neg h, top_to_nnreal]

@[simp]
theorem to_nnreal_top_mul (a : ℝ≥0∞) : Ennreal.toNnreal (∞*a) = 0 :=
  by 
    rw [mul_commₓ, to_nnreal_mul_top]

@[simp]
theorem to_real_mul_top (a : ℝ≥0∞) : Ennreal.toReal (a*∞) = 0 :=
  by 
    rw [Ennreal.toReal, to_nnreal_mul_top, Nnreal.coe_zero]

@[simp]
theorem to_real_top_mul (a : ℝ≥0∞) : Ennreal.toReal (∞*a) = 0 :=
  by 
    rw [mul_commₓ]
    exact to_real_mul_top _

theorem to_real_eq_to_real (ha : a ≠ ∞) (hb : b ≠ ∞) : Ennreal.toReal a = Ennreal.toReal b ↔ a = b :=
  by 
    lift a to  ℝ≥0  using ha 
    lift b to  ℝ≥0  using hb 
    simp only [coe_eq_coe, Nnreal.coe_eq, coe_to_real]

theorem to_real_smul (r :  ℝ≥0 ) (s : ℝ≥0∞) : (r • s).toReal = r • s.to_real :=
  by 
    induction s using WithTop.recTopCoe
    ·
      rw
        [show r • ∞ = (r : ℝ≥0∞)*∞by 
          rfl]
      simp only [Ennreal.to_real_mul_top, Ennreal.top_to_real, smul_zero]
    ·
      rw [←coe_smul, Ennreal.coe_to_real, Ennreal.coe_to_real]
      rfl

/-- `ennreal.to_nnreal` as a `monoid_hom`. -/
def to_nnreal_hom : ℝ≥0∞ →*  ℝ≥0  :=
  { toFun := Ennreal.toNnreal, map_one' := to_nnreal_coe,
    map_mul' :=
      by 
        rintro (_ | x) (_ | y) <;>
          simp only [←coe_mul, none_eq_top, some_eq_coe, to_nnreal_top_mul, to_nnreal_mul_top, top_to_nnreal, mul_zero,
            zero_mul, to_nnreal_coe] }

theorem to_nnreal_mul {a b : ℝ≥0∞} : (a*b).toNnreal = a.to_nnreal*b.to_nnreal :=
  to_nnreal_hom.map_mul a b

theorem to_nnreal_pow (a : ℝ≥0∞) (n : ℕ) : (a ^ n).toNnreal = a.to_nnreal ^ n :=
  to_nnreal_hom.map_pow a n

theorem to_nnreal_prod {ι : Type _} {s : Finset ι} {f : ι → ℝ≥0∞} : (∏i in s, f i).toNnreal = ∏i in s, (f i).toNnreal :=
  to_nnreal_hom.map_prod _ _

theorem to_nnreal_inv (a : ℝ≥0∞) : a⁻¹.toNnreal = a.to_nnreal⁻¹ :=
  by 
    rcases eq_or_ne a ∞ with (rfl | ha)
    ·
      simp 
    lift a to  ℝ≥0  using ha 
    rcases eq_or_ne a 0 with (rfl | ha)
    ·
      simp 
    rw [←coe_inv ha, to_nnreal_coe, to_nnreal_coe]

theorem to_nnreal_div (a b : ℝ≥0∞) : (a / b).toNnreal = a.to_nnreal / b.to_nnreal :=
  by 
    rw [div_eq_mul_inv, to_nnreal_mul, to_nnreal_inv, div_eq_mul_inv]

/-- `ennreal.to_real` as a `monoid_hom`. -/
def to_real_hom : ℝ≥0∞ →* ℝ :=
  (Nnreal.toRealHom :  ℝ≥0  →* ℝ).comp to_nnreal_hom

theorem to_real_mul : (a*b).toReal = a.to_real*b.to_real :=
  to_real_hom.map_mul a b

theorem to_real_pow (a : ℝ≥0∞) (n : ℕ) : (a ^ n).toReal = a.to_real ^ n :=
  to_real_hom.map_pow a n

theorem to_real_prod {ι : Type _} {s : Finset ι} {f : ι → ℝ≥0∞} : (∏i in s, f i).toReal = ∏i in s, (f i).toReal :=
  to_real_hom.map_prod _ _

theorem to_real_inv (a : ℝ≥0∞) : a⁻¹.toReal = a.to_real⁻¹ :=
  by 
    simpRw [Ennreal.toReal]
    normCast 
    exact to_nnreal_inv a

theorem to_real_div (a b : ℝ≥0∞) : (a / b).toReal = a.to_real / b.to_real :=
  by 
    rw [div_eq_mul_inv, to_real_mul, to_real_inv, div_eq_mul_inv]

theorem of_real_prod_of_nonneg {s : Finset α} {f : α → ℝ} (hf : ∀ i, i ∈ s → 0 ≤ f i) :
  Ennreal.ofReal (∏i in s, f i) = ∏i in s, Ennreal.ofReal (f i) :=
  by 
    simpRw [Ennreal.ofReal, ←coe_finset_prod, coe_eq_coe]
    exact Real.to_nnreal_prod_of_nonneg hf

@[simp]
theorem to_nnreal_bit0 {x : ℝ≥0∞} : (bit0 x).toNnreal = bit0 x.to_nnreal :=
  by 
    byCases' hx_top : x = ∞
    ·
      simp [hx_top, bit0_eq_top_iff.mpr rfl]
    exact to_nnreal_add hx_top hx_top

@[simp]
theorem to_nnreal_bit1 {x : ℝ≥0∞} (hx_top : x ≠ ∞) : (bit1 x).toNnreal = bit1 x.to_nnreal :=
  by 
    simp [bit1, bit1,
      to_nnreal_add
        (by 
          rwa [Ne.def, bit0_eq_top_iff])
        Ennreal.one_ne_top]

@[simp]
theorem to_real_bit0 {x : ℝ≥0∞} : (bit0 x).toReal = bit0 x.to_real :=
  by 
    simp [Ennreal.toReal]

@[simp]
theorem to_real_bit1 {x : ℝ≥0∞} (hx_top : x ≠ ∞) : (bit1 x).toReal = bit1 x.to_real :=
  by 
    simp [Ennreal.toReal, hx_top]

@[simp]
theorem of_real_bit0 {r : ℝ} (hr : 0 ≤ r) : Ennreal.ofReal (bit0 r) = bit0 (Ennreal.ofReal r) :=
  of_real_add hr hr

@[simp]
theorem of_real_bit1 {r : ℝ} (hr : 0 ≤ r) : Ennreal.ofReal (bit1 r) = bit1 (Ennreal.ofReal r) :=
  (of_real_add
        (by 
          simp [hr])
        zero_le_one).trans
    (by 
      simp [Real.to_nnreal_one, bit1, hr])

end Real

section infi

variable{ι : Sort _}{f g : ι → ℝ≥0∞}

theorem infi_add : (infi f+a) = ⨅i, f i+a :=
  le_antisymmₓ (le_infi$ fun i => add_le_add (infi_le _ _)$ le_reflₓ _)
    (tsub_le_iff_right.1$ le_infi$ fun i => tsub_le_iff_right.2$ infi_le _ _)

theorem supr_sub : (⨆i, f i) - a = ⨆i, f i - a :=
  le_antisymmₓ (tsub_le_iff_right.2$ supr_le$ fun i => tsub_le_iff_right.1$ le_supr _ i)
    (supr_le$ fun i => tsub_le_tsub (le_supr _ _) (le_reflₓ a))

theorem sub_infi : (a - ⨅i, f i) = ⨆i, a - f i :=
  by 
    refine' eq_of_forall_ge_iff$ fun c => _ 
    rw [tsub_le_iff_right, add_commₓ, infi_add]
    simp [tsub_le_iff_right, sub_eq_add_neg, add_commₓ]

theorem Inf_add {s : Set ℝ≥0∞} : (Inf s+a) = ⨅(b : _)(_ : b ∈ s), b+a :=
  by 
    simp [Inf_eq_infi, infi_add]

theorem add_infi {a : ℝ≥0∞} : (a+infi f) = ⨅b, a+f b :=
  by 
    rw [add_commₓ, infi_add] <;> simp [add_commₓ]

theorem infi_add_infi (h : ∀ i j, ∃ k, (f k+g k) ≤ f i+g j) : (infi f+infi g) = ⨅a, f a+g a :=
  suffices (⨅a, f a+g a) ≤ infi f+infi g from
    le_antisymmₓ (le_infi$ fun a => add_le_add (infi_le _ _) (infi_le _ _)) this 
  calc (⨅a, f a+g a) ≤ ⨅a a', f a+g a' :=
    le_infi$
      fun a =>
        le_infi$
          fun a' =>
            let ⟨k, h⟩ := h a a' 
            infi_le_of_le k h 
    _ = infi f+infi g :=
    by 
      simp [add_infi, infi_add]
    

theorem infi_sum {f : ι → α → ℝ≥0∞} {s : Finset α} [Nonempty ι]
  (h : ∀ (t : Finset α) (i j : ι), ∃ k, ∀ a (_ : a ∈ t), f k a ≤ f i a ∧ f k a ≤ f j a) :
  (⨅i, ∑a in s, f i a) = ∑a in s, ⨅i, f i a :=
  Finset.induction_on s
      (by 
        simp )$
    fun a s ha ih =>
      have  : ∀ (i j : ι), ∃ k : ι, (f k a+∑b in s, f k b) ≤ f i a+∑b in s, f j b :=
        fun i j =>
          let ⟨k, hk⟩ := h (insert a s) i j
          ⟨k,
            add_le_add (hk a (Finset.mem_insert_self _ _)).left$
              Finset.sum_le_sum$ fun a ha => (hk _$ Finset.mem_insert_of_mem ha).right⟩
      by 
        simp [ha, ih.symm, infi_add_infi this]

/-- If `x ≠ 0` and `x ≠ ∞`, then right multiplication by `x` maps infimum to infimum.
See also `ennreal.infi_mul` that assumes `[nonempty ι]` but does not require `x ≠ 0`. -/
theorem infi_mul_of_ne {ι} {f : ι → ℝ≥0∞} {x : ℝ≥0∞} (h0 : x ≠ 0) (h : x ≠ ∞) : (infi f*x) = ⨅i, f i*x :=
  le_antisymmₓ mul_right_mono.map_infi_le
    ((div_le_iff_le_mul (Or.inl h0)$ Or.inl h).mp$
      le_infi$ fun i => (div_le_iff_le_mul (Or.inl h0)$ Or.inl h).mpr$ infi_le _ _)

/-- If `x ≠ ∞`, then right multiplication by `x` maps infimum over a nonempty type to infimum. See
also `ennreal.infi_mul_of_ne` that assumes `x ≠ 0` but does not require `[nonempty ι]`. -/
theorem infi_mul {ι} [Nonempty ι] {f : ι → ℝ≥0∞} {x : ℝ≥0∞} (h : x ≠ ∞) : (infi f*x) = ⨅i, f i*x :=
  by 
    byCases' h0 : x = 0
    ·
      simp only [h0, mul_zero, infi_const]
    ·
      exact infi_mul_of_ne h0 h

/-- If `x ≠ ∞`, then left multiplication by `x` maps infimum over a nonempty type to infimum. See
also `ennreal.mul_infi_of_ne` that assumes `x ≠ 0` but does not require `[nonempty ι]`. -/
theorem mul_infi {ι} [Nonempty ι] {f : ι → ℝ≥0∞} {x : ℝ≥0∞} (h : x ≠ ∞) : (x*infi f) = ⨅i, x*f i :=
  by 
    simpa only [mul_commₓ] using infi_mul h

/-- If `x ≠ 0` and `x ≠ ∞`, then left multiplication by `x` maps infimum to infimum.
See also `ennreal.mul_infi` that assumes `[nonempty ι]` but does not require `x ≠ 0`. -/
theorem mul_infi_of_ne {ι} {f : ι → ℝ≥0∞} {x : ℝ≥0∞} (h0 : x ≠ 0) (h : x ≠ ∞) : (x*infi f) = ⨅i, x*f i :=
  by 
    simpa only [mul_commₓ] using infi_mul_of_ne h0 h

/-! `supr_mul`, `mul_supr` and variants are in `topology.instances.ennreal`. -/


end infi

section supr

@[simp]
theorem supr_eq_zero {ι : Sort _} {f : ι → ℝ≥0∞} : (⨆i, f i) = 0 ↔ ∀ i, f i = 0 :=
  supr_eq_bot

@[simp]
theorem supr_zero_eq_zero {ι : Sort _} : (⨆i : ι, (0 : ℝ≥0∞)) = 0 :=
  by 
    simp 

theorem sup_eq_zero {a b : ℝ≥0∞} : a⊔b = 0 ↔ a = 0 ∧ b = 0 :=
  sup_eq_bot_iff

theorem supr_coe_nat : (⨆n : ℕ, (n : ℝ≥0∞)) = ∞ :=
  (supr_eq_top _).2$ fun b hb => Ennreal.exists_nat_gt (lt_top_iff_ne_top.1 hb)

end supr

end Ennreal

