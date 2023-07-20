/-
Copyright (c) 2020 Frédéric Dupuis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Frédéric Dupuis
-/
import Mathbin.Algebra.Module.Pi
import Mathbin.Algebra.Module.Prod
import Mathbin.Algebra.Order.Monoid.Prod
import Mathbin.Algebra.Order.Pi
import Mathbin.Data.Set.Pointwise.Smul
import Mathbin.Tactic.Positivity

#align_import algebra.order.smul from "leanprover-community/mathlib"@"e04043d6bf7264a3c84bc69711dc354958ca4516"

/-!
# Ordered scalar product

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define

* `ordered_smul R M` : an ordered additive commutative monoid `M` is an `ordered_smul`
  over an `ordered_semiring` `R` if the scalar product respects the order relation on the
  monoid and on the ring. There is a correspondence between this structure and convex cones,
  which is proven in `analysis/convex/cone.lean`.

## Implementation notes

* We choose to define `ordered_smul` as a `Prop`-valued mixin, so that it can be
  used for actions, modules, and algebras
  (the axioms for an "ordered algebra" are exactly that the algebra is ordered as a module).
* To get ordered modules and ordered vector spaces, it suffices to replace the
  `order_add_comm_monoid` and the `ordered_semiring` as desired.

## References

* https://en.wikipedia.org/wiki/Ordered_module

## Tags

ordered module, ordered scalar, ordered smul, ordered action, ordered vector space
-/


open scoped Pointwise

#print OrderedSMul /-
/-- The ordered scalar product property is when an ordered additive commutative monoid
with a partial order has a scalar multiplication which is compatible with the order.
-/
@[protect_proj]
class OrderedSMul (R M : Type _) [OrderedSemiring R] [OrderedAddCommMonoid M] [SMulWithZero R M] :
    Prop where
  smul_lt_smul_of_pos : ∀ {a b : M}, ∀ {c : R}, a < b → 0 < c → c • a < c • b
  lt_of_smul_lt_smul_of_pos : ∀ {a b : M}, ∀ {c : R}, c • a < c • b → 0 < c → a < b
#align ordered_smul OrderedSMul
-/

variable {ι 𝕜 R M N : Type _}

namespace OrderDual

instance [Zero R] [AddZeroClass M] [h : SMulWithZero R M] : SMulWithZero R Mᵒᵈ :=
  { instSMulOrderDual with
    zero_smul := fun m => OrderDual.rec (zero_smul _) m
    smul_zero := fun r => OrderDual.rec smul_zero r }

instance [Monoid R] [MulAction R M] : MulAction R Mᵒᵈ :=
  { instSMulOrderDual with
    one_smul := fun m => OrderDual.rec (one_smul _) m
    mul_smul := fun r => OrderDual.rec mul_smul r }

instance [MonoidWithZero R] [AddMonoid M] [MulActionWithZero R M] : MulActionWithZero R Mᵒᵈ :=
  { OrderDual.mulAction, OrderDual.smulWithZero with }

instance [MonoidWithZero R] [AddMonoid M] [DistribMulAction R M] : DistribMulAction R Mᵒᵈ
    where
  smul_add k a := OrderDual.rec (fun a' b => OrderDual.rec (smul_add _ _) b) a
  smul_zero r := OrderDual.rec (@smul_zero _ M _ _) r

instance [OrderedSemiring R] [OrderedAddCommMonoid M] [SMulWithZero R M] [OrderedSMul R M] :
    OrderedSMul R Mᵒᵈ
    where
  smul_lt_smul_of_pos a b := @OrderedSMul.smul_lt_smul_of_pos R M _ _ _ _ b a
  lt_of_smul_lt_smul_of_pos a b := @OrderedSMul.lt_of_smul_lt_smul_of_pos R M _ _ _ _ b a

end OrderDual

section OrderedSMul

variable [OrderedSemiring R] [OrderedAddCommMonoid M] [SMulWithZero R M] [OrderedSMul R M]
  {s : Set M} {a b : M} {c : R}

#print smul_lt_smul_of_pos /-
theorem smul_lt_smul_of_pos : a < b → 0 < c → c • a < c • b :=
  OrderedSMul.smul_lt_smul_of_pos
#align smul_lt_smul_of_pos smul_lt_smul_of_pos
-/

#print smul_le_smul_of_nonneg /-
theorem smul_le_smul_of_nonneg (h₁ : a ≤ b) (h₂ : 0 ≤ c) : c • a ≤ c • b :=
  by
  rcases h₁.eq_or_lt with (rfl | hab)
  · rfl
  · rcases h₂.eq_or_lt with (rfl | hc)
    · rw [zero_smul, zero_smul]
    · exact (smul_lt_smul_of_pos hab hc).le
#align smul_le_smul_of_nonneg smul_le_smul_of_nonneg
-/

#print smul_nonneg /-
theorem smul_nonneg (hc : 0 ≤ c) (ha : 0 ≤ a) : 0 ≤ c • a :=
  calc
    (0 : M) = c • (0 : M) := (smul_zero c).symm
    _ ≤ c • a := smul_le_smul_of_nonneg ha hc
#align smul_nonneg smul_nonneg
-/

#print smul_nonpos_of_nonneg_of_nonpos /-
theorem smul_nonpos_of_nonneg_of_nonpos (hc : 0 ≤ c) (ha : a ≤ 0) : c • a ≤ 0 :=
  @smul_nonneg R Mᵒᵈ _ _ _ _ _ _ hc ha
#align smul_nonpos_of_nonneg_of_nonpos smul_nonpos_of_nonneg_of_nonpos
-/

#print eq_of_smul_eq_smul_of_pos_of_le /-
theorem eq_of_smul_eq_smul_of_pos_of_le (h₁ : c • a = c • b) (hc : 0 < c) (hle : a ≤ b) : a = b :=
  hle.lt_or_eq.resolve_left fun hlt => (smul_lt_smul_of_pos hlt hc).Ne h₁
#align eq_of_smul_eq_smul_of_pos_of_le eq_of_smul_eq_smul_of_pos_of_le
-/

#print lt_of_smul_lt_smul_of_nonneg /-
theorem lt_of_smul_lt_smul_of_nonneg (h : c • a < c • b) (hc : 0 ≤ c) : a < b :=
  hc.eq_or_lt.elim
    (fun hc => False.elim <| lt_irrefl (0 : M) <| by rwa [← hc, zero_smul, zero_smul] at h )
    (OrderedSMul.lt_of_smul_lt_smul_of_pos h)
#align lt_of_smul_lt_smul_of_nonneg lt_of_smul_lt_smul_of_nonneg
-/

#print smul_lt_smul_iff_of_pos /-
theorem smul_lt_smul_iff_of_pos (hc : 0 < c) : c • a < c • b ↔ a < b :=
  ⟨fun h => lt_of_smul_lt_smul_of_nonneg h hc.le, fun h => smul_lt_smul_of_pos h hc⟩
#align smul_lt_smul_iff_of_pos smul_lt_smul_iff_of_pos
-/

#print smul_pos_iff_of_pos /-
theorem smul_pos_iff_of_pos (hc : 0 < c) : 0 < c • a ↔ 0 < a :=
  calc
    0 < c • a ↔ c • 0 < c • a := by rw [smul_zero]
    _ ↔ 0 < a := smul_lt_smul_iff_of_pos hc
#align smul_pos_iff_of_pos smul_pos_iff_of_pos
-/

alias smul_pos_iff_of_pos ↔ _ smul_pos
#align smul_pos smul_pos

#print monotone_smul_left /-
theorem monotone_smul_left (hc : 0 ≤ c) : Monotone (SMul.smul c : M → M) := fun a b h =>
  smul_le_smul_of_nonneg h hc
#align monotone_smul_left monotone_smul_left
-/

#print strictMono_smul_left /-
theorem strictMono_smul_left (hc : 0 < c) : StrictMono (SMul.smul c : M → M) := fun a b h =>
  smul_lt_smul_of_pos h hc
#align strict_mono_smul_left strictMono_smul_left
-/

#print smul_lowerBounds_subset_lowerBounds_smul /-
theorem smul_lowerBounds_subset_lowerBounds_smul (hc : 0 ≤ c) :
    c • lowerBounds s ⊆ lowerBounds (c • s) :=
  (monotone_smul_left hc).image_lowerBounds_subset_lowerBounds_image
#align smul_lower_bounds_subset_lower_bounds_smul smul_lowerBounds_subset_lowerBounds_smul
-/

#print smul_upperBounds_subset_upperBounds_smul /-
theorem smul_upperBounds_subset_upperBounds_smul (hc : 0 ≤ c) :
    c • upperBounds s ⊆ upperBounds (c • s) :=
  (monotone_smul_left hc).image_upperBounds_subset_upperBounds_image
#align smul_upper_bounds_subset_upper_bounds_smul smul_upperBounds_subset_upperBounds_smul
-/

#print BddBelow.smul_of_nonneg /-
theorem BddBelow.smul_of_nonneg (hs : BddBelow s) (hc : 0 ≤ c) : BddBelow (c • s) :=
  (monotone_smul_left hc).map_bddBelow hs
#align bdd_below.smul_of_nonneg BddBelow.smul_of_nonneg
-/

#print BddAbove.smul_of_nonneg /-
theorem BddAbove.smul_of_nonneg (hs : BddAbove s) (hc : 0 ≤ c) : BddAbove (c • s) :=
  (monotone_smul_left hc).map_bddAbove hs
#align bdd_above.smul_of_nonneg BddAbove.smul_of_nonneg
-/

end OrderedSMul

#print OrderedSMul.mk'' /-
/-- To prove that a linear ordered monoid is an ordered module, it suffices to verify only the first
axiom of `ordered_smul`. -/
theorem OrderedSMul.mk'' [OrderedSemiring 𝕜] [LinearOrderedAddCommMonoid M] [SMulWithZero 𝕜 M]
    (h : ∀ ⦃c : 𝕜⦄, 0 < c → StrictMono fun a : M => c • a) : OrderedSMul 𝕜 M :=
  { smul_lt_smul_of_pos := fun a b c hab hc => h hc hab
    lt_of_smul_lt_smul_of_pos := fun a b c hab hc => (h hc).lt_iff_lt.1 hab }
#align ordered_smul.mk'' OrderedSMul.mk''
-/

#print Nat.orderedSMul /-
instance Nat.orderedSMul [LinearOrderedCancelAddCommMonoid M] : OrderedSMul ℕ M :=
  OrderedSMul.mk'' fun n hn a b hab => by
    cases n
    · cases hn
    induction' n with n ih
    · simp only [one_nsmul, hab]
    · simp only [succ_nsmul _ n.succ, add_lt_add hab (ih n.succ_pos)]
#align nat.ordered_smul Nat.orderedSMul
-/

#print Int.orderedSMul /-
instance Int.orderedSMul [LinearOrderedAddCommGroup M] : OrderedSMul ℤ M :=
  OrderedSMul.mk'' fun n hn => by
    cases n
    · simp only [Int.ofNat_eq_coe, Int.coe_nat_pos, coe_nat_zsmul] at hn ⊢
      exact strictMono_smul_left hn
    · cases (Int.negSucc_not_pos _).1 hn
#align int.ordered_smul Int.orderedSMul
-/

#print LinearOrderedSemiring.toOrderedSMul /-
-- TODO: `linear_ordered_field M → ordered_smul ℚ M`
instance LinearOrderedSemiring.toOrderedSMul {R : Type _} [LinearOrderedSemiring R] :
    OrderedSMul R R :=
  OrderedSMul.mk'' fun c => strictMono_mul_left_of_pos
#align linear_ordered_semiring.to_ordered_smul LinearOrderedSemiring.toOrderedSMul
-/

section LinearOrderedSemifield

variable [LinearOrderedSemifield 𝕜] [OrderedAddCommMonoid M] [OrderedAddCommMonoid N]
  [MulActionWithZero 𝕜 M] [MulActionWithZero 𝕜 N]

#print OrderedSMul.mk' /-
/-- To prove that a vector space over a linear ordered field is ordered, it suffices to verify only
the first axiom of `ordered_smul`. -/
theorem OrderedSMul.mk' (h : ∀ ⦃a b : M⦄ ⦃c : 𝕜⦄, a < b → 0 < c → c • a ≤ c • b) :
    OrderedSMul 𝕜 M :=
  by
  have hlt' : ∀ ⦃a b : M⦄ ⦃c : 𝕜⦄, a < b → 0 < c → c • a < c • b :=
    by
    refine' fun a b c hab hc => (h hab hc).lt_of_ne _
    rw [Ne.def, hc.ne'.is_unit.smul_left_cancel]
    exact hab.ne
  refine' { smul_lt_smul_of_pos := hlt' .. }
  intro a b c hab hc
  obtain ⟨c, rfl⟩ := hc.ne'.is_unit
  rw [← inv_smul_smul c a, ← inv_smul_smul c b]
  refine' hlt' hab (pos_of_mul_pos_right _ hc.le)
  simp only [c.mul_inv, zero_lt_one]
#align ordered_smul.mk' OrderedSMul.mk'
-/

instance [OrderedSMul 𝕜 M] [OrderedSMul 𝕜 N] : OrderedSMul 𝕜 (M × N) :=
  OrderedSMul.mk' fun a b c h hc =>
    ⟨smul_le_smul_of_nonneg h.1.1 hc.le, smul_le_smul_of_nonneg h.1.2 hc.le⟩

#print Pi.orderedSMul /-
instance Pi.orderedSMul {M : ι → Type _} [∀ i, OrderedAddCommMonoid (M i)]
    [∀ i, MulActionWithZero 𝕜 (M i)] [∀ i, OrderedSMul 𝕜 (M i)] : OrderedSMul 𝕜 (∀ i, M i) :=
  OrderedSMul.mk' fun v u c h hc i => smul_le_smul_of_nonneg (h.le i) hc.le
#align pi.ordered_smul Pi.orderedSMul
-/

#print Pi.orderedSMul' /-
/- Sometimes Lean fails to apply the dependent version to non-dependent functions, so we define
another instance. -/
instance Pi.orderedSMul' [OrderedSMul 𝕜 M] : OrderedSMul 𝕜 (ι → M) :=
  Pi.orderedSMul
#align pi.ordered_smul' Pi.orderedSMul'
-/

#print Pi.orderedSMul'' /-
-- Sometimes Lean fails to unify the module with the scalars, so we define another instance.
instance Pi.orderedSMul'' : OrderedSMul 𝕜 (ι → 𝕜) :=
  @Pi.orderedSMul' ι 𝕜 𝕜 _ _ _ _
#align pi.ordered_smul'' Pi.orderedSMul''
-/

variable [OrderedSMul 𝕜 M] {s : Set M} {a b : M} {c : 𝕜}

#print smul_le_smul_iff_of_pos /-
theorem smul_le_smul_iff_of_pos (hc : 0 < c) : c • a ≤ c • b ↔ a ≤ b :=
  ⟨fun h =>
    inv_smul_smul₀ hc.ne' a ▸
      inv_smul_smul₀ hc.ne' b ▸ smul_le_smul_of_nonneg h (inv_nonneg.2 hc.le),
    fun h => smul_le_smul_of_nonneg h hc.le⟩
#align smul_le_smul_iff_of_pos smul_le_smul_iff_of_pos
-/

#print inv_smul_le_iff /-
theorem inv_smul_le_iff (h : 0 < c) : c⁻¹ • a ≤ b ↔ a ≤ c • b := by
  rw [← smul_le_smul_iff_of_pos h, smul_inv_smul₀ h.ne']; infer_instance
#align inv_smul_le_iff inv_smul_le_iff
-/

#print inv_smul_lt_iff /-
theorem inv_smul_lt_iff (h : 0 < c) : c⁻¹ • a < b ↔ a < c • b := by
  rw [← smul_lt_smul_iff_of_pos h, smul_inv_smul₀ h.ne']; infer_instance
#align inv_smul_lt_iff inv_smul_lt_iff
-/

#print le_inv_smul_iff /-
theorem le_inv_smul_iff (h : 0 < c) : a ≤ c⁻¹ • b ↔ c • a ≤ b := by
  rw [← smul_le_smul_iff_of_pos h, smul_inv_smul₀ h.ne']; infer_instance
#align le_inv_smul_iff le_inv_smul_iff
-/

#print lt_inv_smul_iff /-
theorem lt_inv_smul_iff (h : 0 < c) : a < c⁻¹ • b ↔ c • a < b := by
  rw [← smul_lt_smul_iff_of_pos h, smul_inv_smul₀ h.ne']; infer_instance
#align lt_inv_smul_iff lt_inv_smul_iff
-/

variable (M)

#print OrderIso.smulLeft /-
/-- Left scalar multiplication as an order isomorphism. -/
@[simps]
def OrderIso.smulLeft (hc : 0 < c) : M ≃o M
    where
  toFun b := c • b
  invFun b := c⁻¹ • b
  left_inv := inv_smul_smul₀ hc.ne'
  right_inv := smul_inv_smul₀ hc.ne'
  map_rel_iff' b₁ b₂ := smul_le_smul_iff_of_pos hc
#align order_iso.smul_left OrderIso.smulLeft
-/

variable {M}

#print lowerBounds_smul_of_pos /-
@[simp]
theorem lowerBounds_smul_of_pos (hc : 0 < c) : lowerBounds (c • s) = c • lowerBounds s :=
  (OrderIso.smulLeft _ hc).lowerBounds_image
#align lower_bounds_smul_of_pos lowerBounds_smul_of_pos
-/

#print upperBounds_smul_of_pos /-
@[simp]
theorem upperBounds_smul_of_pos (hc : 0 < c) : upperBounds (c • s) = c • upperBounds s :=
  (OrderIso.smulLeft _ hc).upperBounds_image
#align upper_bounds_smul_of_pos upperBounds_smul_of_pos
-/

#print bddBelow_smul_iff_of_pos /-
@[simp]
theorem bddBelow_smul_iff_of_pos (hc : 0 < c) : BddBelow (c • s) ↔ BddBelow s :=
  (OrderIso.smulLeft _ hc).bddBelow_image
#align bdd_below_smul_iff_of_pos bddBelow_smul_iff_of_pos
-/

#print bddAbove_smul_iff_of_pos /-
@[simp]
theorem bddAbove_smul_iff_of_pos (hc : 0 < c) : BddAbove (c • s) ↔ BddAbove s :=
  (OrderIso.smulLeft _ hc).bddAbove_image
#align bdd_above_smul_iff_of_pos bddAbove_smul_iff_of_pos
-/

end LinearOrderedSemifield

namespace Tactic

section OrderedSMul

variable [OrderedSemiring R] [OrderedAddCommMonoid M] [SMulWithZero R M] [OrderedSMul R M] {a : R}
  {b : M}

private theorem smul_nonneg_of_pos_of_nonneg (ha : 0 < a) (hb : 0 ≤ b) : 0 ≤ a • b :=
  smul_nonneg ha.le hb

private theorem smul_nonneg_of_nonneg_of_pos (ha : 0 ≤ a) (hb : 0 < b) : 0 ≤ a • b :=
  smul_nonneg ha hb.le

end OrderedSMul

section NoZeroSMulDivisors

variable [Zero R] [Zero M] [SMul R M] [NoZeroSMulDivisors R M] {a : R} {b : M}

private theorem smul_ne_zero_of_pos_of_ne_zero [Preorder R] (ha : 0 < a) (hb : b ≠ 0) : a • b ≠ 0 :=
  smul_ne_zero ha.ne' hb

private theorem smul_ne_zero_of_ne_zero_of_pos [Preorder M] (ha : a ≠ 0) (hb : 0 < b) : a • b ≠ 0 :=
  smul_ne_zero ha hb.ne'

end NoZeroSMulDivisors

open Positivity

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      Extension for the `positivity` tactic: scalar multiplication is nonnegative/positive/nonzero if
      both sides are. -/
    @[ positivity ]
    unsafe
  def
    positivity_smul
    : expr → tactic strictness
    |
        e @ q( $ ( a ) • $ ( b ) )
        =>
        do
          let strictness_a ← core a
            let strictness_b ← core b
            match
              strictness_a , strictness_b
              with
              | positive pa , positive pb => positive <$> mk_app ` ` smul_pos [ pa , pb ]
                |
                  positive pa , nonnegative pb
                  =>
                  nonnegative <$> mk_app ` ` smul_nonneg_of_pos_of_nonneg [ pa , pb ]
                |
                  nonnegative pa , positive pb
                  =>
                  nonnegative <$> mk_app ` ` smul_nonneg_of_nonneg_of_pos [ pa , pb ]
                |
                  nonnegative pa , nonnegative pb
                  =>
                  nonnegative <$> mk_app ` ` smul_nonneg [ pa , pb ]
                |
                  positive pa , nonzero pb
                  =>
                  nonzero <$> to_expr ` `( smul_ne_zero_of_pos_of_ne_zero $ ( pa ) $ ( pb ) )
                |
                  nonzero pa , positive pb
                  =>
                  nonzero <$> to_expr ` `( smul_ne_zero_of_ne_zero_of_pos $ ( pa ) $ ( pb ) )
                |
                  nonzero pa , nonzero pb
                  =>
                  nonzero <$> to_expr ` `( smul_ne_zero $ ( pa ) $ ( pb ) )
                | sa @ _ , sb @ _ => positivity_fail e a b sa sb
      | e => pp e >>= fail ∘ format.bracket "The expression `" "` isn't of the form `a • b`"
#align tactic.positivity_smul tactic.positivity_smul

end Tactic

