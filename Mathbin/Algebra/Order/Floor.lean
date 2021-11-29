import Mathbin.Tactic.Abel 
import Mathbin.Tactic.Linarith.Default

/-!
# Floor and ceil

## Summary

We define the natural- and integer-valued floor and ceil functions on linearly ordered rings.

## Main Definitions

* `floor_semiring`: A linearly ordered semiring with natural-valued floor and ceil.
* `nat.floor a`: Greatest natural `n` such that `n ≤ a`. Equal to `0` if `a < 0`.
* `nat.ceil a`: Least natural `n` such that `a ≤ n`.

* `floor_ring`: A linearly ordered ring with integer-valued floor and ceil.
* `int.floor a`: Greatest integer `z` such that `z ≤ a`.
* `int.ceil a`: Least integer `z` such that `a ≤ z`.
* `int.fract a`: Fractional part of `a`, defined as `a - floor a`.

## Notations

* `⌊a⌋₊` is `nat.floor a`.
* `⌈a⌉₊` is `nat.ceil a`.
* `⌊a⌋` is `int.floor a`.
* `⌈a⌉` is `int.ceil a`.

The index `₊` in the notations for `nat.floor` and `nat.ceil` is used in analogy to the notation
for `nnnorm`.

## TODO

Some `nat.floor` and `nat.ceil` lemmas require `linear_ordered_ring α`.Is `has_ordered_sub` enough?

`linear_ordered_ring`/`linear_ordered_semiring` can be relaxed to `order_ring`/`order_semiring` in
many lemmas.

## Tags

rounding, floor, ceil
-/


open Set

variable{α : Type _}

/-! ### Floor semiring -/


/-- A `floor_semiring` is a linear ordered semiring over `α` with a function
`floor : α → ℕ` satisfying `∀ (n : ℕ) (x : α), n ≤ ⌊x⌋ ↔ (n : α) ≤ x)`. -/
class FloorSemiring(α)[OrderedSemiring α] where 
  floor : α → ℕ 
  ceil : α → ℕ 
  floor_of_neg {a : α} (ha : a < 0) : floor a = 0
  gc_floor {a : α} {n : ℕ} (ha : 0 ≤ a) : n ≤ floor a ↔ (n : α) ≤ a 
  gc_ceil : GaloisConnection ceil coeₓ

instance  : FloorSemiring ℕ :=
  { floor := id, ceil := id, floor_of_neg := fun a ha => (a.not_lt_zero ha).elim,
    gc_floor :=
      fun n a ha =>
        by 
          rw [Nat.cast_id]
          rfl,
    gc_ceil :=
      fun n a =>
        by 
          rw [Nat.cast_id]
          rfl }

namespace Nat

section LinearOrderedSemiring

variable[LinearOrderedSemiring α][FloorSemiring α]{a : α}{n : ℕ}

/-- `⌊a⌋₊` is the greatest natural `n` such that `n ≤ a`. If `a` is negative, then `⌊a⌋₊ = 0`. -/
def floor : α → ℕ :=
  FloorSemiring.floor

/-- `⌈a⌉₊` is the least natural `n` such that `a ≤ n` -/
def ceil : α → ℕ :=
  FloorSemiring.ceil

notation "⌊" a "⌋₊" => Nat.floor a

notation "⌈" a "⌉₊" => Nat.ceil a

theorem le_floor_iff (ha : 0 ≤ a) : n ≤ ⌊a⌋₊ ↔ (n : α) ≤ a :=
  FloorSemiring.gc_floor ha

theorem le_floor (h : (n : α) ≤ a) : n ≤ ⌊a⌋₊ :=
  (le_floor_iff$ n.cast_nonneg.trans h).2 h

theorem floor_lt (ha : 0 ≤ a) : ⌊a⌋₊ < n ↔ a < n :=
  lt_iff_lt_of_le_iff_le$ le_floor_iff ha

theorem lt_of_floor_lt (h : ⌊a⌋₊ < n) : a < n :=
  lt_of_not_ge'$ fun h' => (le_floor h').not_lt h

theorem floor_le (ha : 0 ≤ a) : (⌊a⌋₊ : α) ≤ a :=
  (le_floor_iff ha).1 le_rfl

theorem lt_succ_floor (a : α) : a < ⌊a⌋₊.succ :=
  lt_of_floor_lt$ Nat.lt_succ_selfₓ _

theorem lt_floor_add_one (a : α) : a < ⌊a⌋₊+1 :=
  lt_succ_floor a

@[simp]
theorem floor_coe (n : ℕ) : ⌊(n : α)⌋₊ = n :=
  eq_of_forall_le_iff$
    fun a =>
      by 
        rw [le_floor_iff, Nat.cast_le]
        exact n.cast_nonneg

@[simp]
theorem floor_zero : ⌊(0 : α)⌋₊ = 0 :=
  floor_coe 0

@[simp]
theorem floor_one : ⌊(1 : α)⌋₊ = 1 :=
  by 
    rw [←Nat.cast_one, floor_coe]

theorem floor_of_nonpos (ha : a ≤ 0) : ⌊a⌋₊ = 0 :=
  ha.lt_or_eq.elim FloorSemiring.floor_of_neg$
    by 
      rintro rfl 
      exact floor_zero

theorem floor_mono : Monotone (floor : α → ℕ) :=
  fun a b h =>
    by 
      obtain ha | ha := le_totalₓ a 0
      ·
        rw [floor_of_nonpos ha]
        exact Nat.zero_leₓ _
      ·
        exact le_floor ((floor_le ha).trans h)

theorem le_floor_iff' (hn : n ≠ 0) : n ≤ ⌊a⌋₊ ↔ (n : α) ≤ a :=
  by 
    obtain ha | ha := le_totalₓ a 0
    ·
      rw [floor_of_nonpos ha]
      exact iff_of_false (Nat.pos_of_ne_zeroₓ hn).not_le (not_le_of_lt$ ha.trans_lt$ cast_pos.2$ Nat.pos_of_ne_zeroₓ hn)
    ·
      exact le_floor_iff ha

theorem floor_lt' (hn : n ≠ 0) : ⌊a⌋₊ < n ↔ a < n :=
  lt_iff_lt_of_le_iff_le$ le_floor_iff' hn

theorem floor_pos : 0 < ⌊a⌋₊ ↔ 1 ≤ a :=
  by 
    convert le_floor_iff' Nat.one_ne_zero 
    exact cast_one.symm

theorem pos_of_floor_pos (h : 0 < ⌊a⌋₊) : 0 < a :=
  (le_or_ltₓ a 0).resolve_left
    fun ha =>
      lt_irreflₓ 0$
        by 
          rwa [floor_of_nonpos ha] at h

theorem lt_of_lt_floor (h : n < ⌊a⌋₊) : «expr↑ » n < a :=
  (Nat.cast_lt.2 h).trans_le$ floor_le (pos_of_floor_pos$ (Nat.zero_leₓ n).trans_lt h).le

@[simp]
theorem floor_eq_zero : ⌊a⌋₊ = 0 ↔ a < 1 :=
  by 
    rw [←lt_one_iff, ←@cast_one α]
    exact floor_lt' Nat.one_ne_zero

theorem floor_eq_iff (ha : 0 ≤ a) : ⌊a⌋₊ = n ↔ «expr↑ » n ≤ a ∧ a < «expr↑ » n+1 :=
  by 
    rw [←le_floor_iff ha, ←Nat.cast_one, ←Nat.cast_add, ←floor_lt ha, Nat.lt_add_one_iff, le_antisymm_iffₓ, And.comm]

theorem floor_eq_iff' (hn : n ≠ 0) : ⌊a⌋₊ = n ↔ «expr↑ » n ≤ a ∧ a < «expr↑ » n+1 :=
  by 
    rw [←le_floor_iff' hn, ←Nat.cast_one, ←Nat.cast_add, ←floor_lt' (Nat.add_one_ne_zero n), Nat.lt_add_one_iff,
      le_antisymm_iffₓ, And.comm]

theorem floor_eq_on_Ico (n : ℕ) : ∀ a (_ : a ∈ (Set.Ico n (n+1) : Set α)), ⌊a⌋₊ = n :=
  fun a ⟨h₀, h₁⟩ => (floor_eq_iff$ n.cast_nonneg.trans h₀).mpr ⟨h₀, h₁⟩

theorem floor_eq_on_Ico' (n : ℕ) : ∀ a (_ : a ∈ (Set.Ico n (n+1) : Set α)), (⌊a⌋₊ : α) = n :=
  fun x hx =>
    by 
      exactModCast floor_eq_on_Ico n x hx

@[simp]
theorem preimage_floor_zero : (floor : α → ℕ) ⁻¹' {0} = Iio 1 :=
  ext$ fun a => floor_eq_zero

theorem preimage_floor_of_ne_zero {n : ℕ} (hn : n ≠ 0) : (floor : α → ℕ) ⁻¹' {n} = Ico n (n+1) :=
  ext$ fun a => floor_eq_iff' hn

/-! #### Ceil -/


theorem gc_ceil_coe : GaloisConnection (ceil : α → ℕ) coeₓ :=
  FloorSemiring.gc_ceil

@[simp]
theorem ceil_le : ⌈a⌉₊ ≤ n ↔ a ≤ n :=
  gc_ceil_coe _ _

theorem lt_ceil : n < ⌈a⌉₊ ↔ (n : α) < a :=
  lt_iff_lt_of_le_iff_le ceil_le

theorem le_ceil (a : α) : a ≤ ⌈a⌉₊ :=
  ceil_le.1 le_rfl

theorem ceil_mono : Monotone (ceil : α → ℕ) :=
  gc_ceil_coe.monotone_l

@[simp]
theorem ceil_coe (n : ℕ) : ⌈(n : α)⌉₊ = n :=
  eq_of_forall_ge_iff$ fun a => ceil_le.trans Nat.cast_le

@[simp]
theorem ceil_zero : ⌈(0 : α)⌉₊ = 0 :=
  ceil_coe 0

@[simp]
theorem ceil_eq_zero : ⌈a⌉₊ = 0 ↔ a ≤ 0 :=
  le_zero_iff.symm.trans ceil_le

theorem lt_of_ceil_lt (h : ⌈a⌉₊ < n) : a < n :=
  (le_ceil a).trans_lt (Nat.cast_lt.2 h)

theorem le_of_ceil_le (h : ⌈a⌉₊ ≤ n) : a ≤ n :=
  (le_ceil a).trans (Nat.cast_le.2 h)

theorem floor_lt_ceil_of_lt_of_pos {a b : α} (h : a < b) (h' : 0 < b) : ⌊a⌋₊ < ⌈b⌉₊ :=
  by 
    rcases le_or_ltₓ 0 a with (ha | ha)
    ·
      rw [floor_lt ha]
      exact h.trans_le (le_ceil _)
    ·
      rwa [floor_of_nonpos ha.le, lt_ceil]

theorem ceil_eq_iff (hn : n ≠ 0) : ⌈a⌉₊ = n ↔ «expr↑ » (n - 1) < a ∧ a ≤ n :=
  by 
    rw [←ceil_le, ←not_leₓ, ←ceil_le, not_leₓ, tsub_lt_iff_right (Nat.add_one_le_iff.2 (pos_iff_ne_zero.2 hn)),
      Nat.lt_add_one_iff, le_antisymm_iffₓ, And.comm]

@[simp]
theorem preimage_ceil_zero : (Nat.ceil : α → ℕ) ⁻¹' {0} = Iic 0 :=
  ext$ fun x => ceil_eq_zero

theorem preimage_ceil_of_ne_zero (hn : n ≠ 0) : (Nat.ceil : α → ℕ) ⁻¹' {n} = Ioc («expr↑ » (n - 1)) n :=
  ext$ fun x => ceil_eq_iff hn

end LinearOrderedSemiring

section LinearOrderedRing

variable[LinearOrderedRing α][FloorSemiring α]{a : α}{n : ℕ}

theorem floor_add_nat (ha : 0 ≤ a) (n : ℕ) : ⌊a+n⌋₊ = ⌊a⌋₊+n :=
  eq_of_forall_le_iff$
    fun b =>
      by 
        rw [le_floor_iff (add_nonneg ha n.cast_nonneg), ←sub_le_iff_le_add]
        obtain hb | hb := le_totalₓ n b
        ·
          rw [←cast_sub hb, ←tsub_le_iff_right]
          exact (le_floor_iff ha).symm
        ·
          exact iff_of_true ((sub_nonpos_of_le$ cast_le.2 hb).trans ha) (le_add_left hb)

theorem floor_add_one (ha : 0 ≤ a) : ⌊a+1⌋₊ = ⌊a⌋₊+1 :=
  by 
    convert floor_add_nat ha 1 
    exact cast_one.symm

theorem sub_one_lt_floor (a : α) : a - 1 < ⌊a⌋₊ :=
  sub_lt_iff_lt_add.2$ lt_floor_add_one a

theorem ceil_add_nat (ha : 0 ≤ a) (n : ℕ) : ⌈a+n⌉₊ = ⌈a⌉₊+n :=
  eq_of_forall_ge_iff$
    fun b =>
      by 
        rw [←not_ltₓ, ←not_ltₓ, not_iff_not]
        rw [lt_ceil]
        obtain hb | hb := le_or_ltₓ n b
        ·
          rw [←tsub_lt_iff_right hb, ←sub_lt_iff_lt_add, ←cast_sub hb]
          exact lt_ceil.symm
        ·
          exact iff_of_true (lt_add_of_nonneg_of_lt ha$ cast_lt.2 hb) (lt_add_left _ _ _ hb)

theorem ceil_add_one (ha : 0 ≤ a) : ⌈a+1⌉₊ = ⌈a⌉₊+1 :=
  by 
    convert ceil_add_nat ha 1 
    exact cast_one.symm

theorem ceil_lt_add_one (ha : 0 ≤ a) : (⌈a⌉₊ : α) < a+1 :=
  lt_ceil.1$ (Nat.lt_succ_selfₓ _).trans_le (ceil_add_one ha).Ge

end LinearOrderedRing

end Nat

-- error in Algebra.Order.Floor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- There exists at most one `floor_semiring` structure on a linear ordered semiring. -/
theorem subsingleton_floor_semiring {α} [linear_ordered_semiring α] : subsingleton (floor_semiring α) :=
begin
  refine [expr ⟨λ H₁ H₂, _⟩],
  have [] [":", expr «expr = »(H₁.ceil, H₂.ceil)] [],
  from [expr funext (λ a, «expr $ »(H₁.gc_ceil.l_unique H₂.gc_ceil, λ n, rfl))],
  have [] [":", expr «expr = »(H₁.floor, H₂.floor)] [],
  { ext [] [ident a] [],
    cases [expr lt_or_le a 0] [],
    { rw ["[", expr H₁.floor_of_neg, ",", expr H₂.floor_of_neg, "]"] []; exact [expr h] },
    { refine [expr eq_of_forall_le_iff (λ n, _)],
      rw ["[", expr H₁.gc_floor, ",", expr H₂.gc_floor, "]"] []; exact [expr h] } },
  cases [expr H₁] [],
  cases [expr H₂] [],
  congr; assumption
end

/-! ### Floor rings -/


/--
A `floor_ring` is a linear ordered ring over `α` with a function
`floor : α → ℤ` satisfying `∀ (z : ℤ) (a : α), z ≤ floor a ↔ (z : α) ≤ a)`.
-/
class FloorRing(α)[LinearOrderedRing α] where 
  floor : α → ℤ 
  ceil : α → ℤ 
  gc_coe_floor : GaloisConnection coeₓ floor 
  gc_ceil_coe : GaloisConnection ceil coeₓ

instance  : FloorRing ℤ :=
  { floor := id, ceil := id,
    gc_coe_floor :=
      fun a b =>
        by 
          rw [Int.cast_id]
          rfl,
    gc_ceil_coe :=
      fun a b =>
        by 
          rw [Int.cast_id]
          rfl }

/-- A `floor_ring` constructor from the `floor` function alone. -/
def FloorRing.ofFloor α [LinearOrderedRing α] (floor : α → ℤ) (gc_coe_floor : GaloisConnection coeₓ floor) :
  FloorRing α :=
  { floor, ceil := fun a => -floor (-a), gc_coe_floor,
    gc_ceil_coe :=
      fun a z =>
        by 
          rw [neg_le, ←gc_coe_floor, Int.cast_neg, neg_le_neg_iff] }

/-- A `floor_ring` constructor from the `ceil` function alone. -/
def FloorRing.ofCeil α [LinearOrderedRing α] (ceil : α → ℤ) (gc_ceil_coe : GaloisConnection ceil coeₓ) : FloorRing α :=
  { floor := fun a => -ceil (-a), ceil,
    gc_coe_floor :=
      fun a z =>
        by 
          rw [le_neg, gc_ceil_coe, Int.cast_neg, neg_le_neg_iff],
    gc_ceil_coe }

namespace Int

variable[LinearOrderedRing α][FloorRing α]{z : ℤ}{a : α}

/-- `int.floor a` is the greatest integer `z` such that `z ≤ a`. It is denoted with `⌊a⌋`. -/
def floor : α → ℤ :=
  FloorRing.floor

/-- `int.ceil a` is the smallest integer `z` such that `a ≤ z`. It is denoted with `⌈a⌉`. -/
def ceil : α → ℤ :=
  FloorRing.ceil

/-- `int.fract a`, the fractional part of `a`, is `a` minus its floor. -/
def fract (a : α) : α :=
  a - floor a

notation "⌊" a "⌋" => Int.floor a

notation "⌈" a "⌉" => Int.ceil a

@[simp]
theorem floor_ring_floor_eq : @FloorRing.floor = @Int.floor :=
  rfl

@[simp]
theorem floor_ring_ceil_eq : @FloorRing.ceil = @Int.ceil :=
  rfl

/-! #### Floor -/


theorem gc_coe_floor : GaloisConnection (coeₓ : ℤ → α) floor :=
  FloorRing.gc_coe_floor

theorem le_floor : z ≤ ⌊a⌋ ↔ (z : α) ≤ a :=
  (gc_coe_floor z a).symm

theorem floor_lt : ⌊a⌋ < z ↔ a < z :=
  lt_iff_lt_of_le_iff_le le_floor

theorem floor_le (a : α) : (⌊a⌋ : α) ≤ a :=
  gc_coe_floor.l_u_le a

theorem floor_nonneg : 0 ≤ ⌊a⌋ ↔ 0 ≤ a :=
  le_floor

theorem floor_nonpos (ha : a ≤ 0) : ⌊a⌋ ≤ 0 :=
  by 
    rw [←@cast_le α]
    exact (floor_le a).trans ha

theorem lt_succ_floor (a : α) : a < ⌊a⌋.succ :=
  floor_lt.1$ Int.lt_succ_self _

theorem lt_floor_add_one (a : α) : a < ⌊a⌋+1 :=
  by 
    simpa only [Int.succ, Int.cast_add, Int.cast_one] using lt_succ_floor a

theorem sub_one_lt_floor (a : α) : a - 1 < ⌊a⌋ :=
  sub_lt_iff_lt_add.2 (lt_floor_add_one a)

@[simp]
theorem floor_coe (z : ℤ) : ⌊(z : α)⌋ = z :=
  eq_of_forall_le_iff$
    fun a =>
      by 
        rw [le_floor, Int.cast_le]

@[simp]
theorem floor_zero : ⌊(0 : α)⌋ = 0 :=
  floor_coe 0

@[simp]
theorem floor_one : ⌊(1 : α)⌋ = 1 :=
  by 
    rw [←Int.cast_one, floor_coe]

@[mono]
theorem floor_mono : Monotone (floor : α → ℤ) :=
  gc_coe_floor.monotone_u

theorem floor_pos : 0 < ⌊a⌋ ↔ 1 ≤ a :=
  by 
    convert le_floor 
    exact cast_one.symm

@[simp]
theorem floor_add_int (a : α) (z : ℤ) : ⌊a+z⌋ = ⌊a⌋+z :=
  eq_of_forall_le_iff$
    fun a =>
      by 
        rw [le_floor, ←sub_le_iff_le_add, ←sub_le_iff_le_add, le_floor, Int.cast_sub]

theorem floor_add_one (a : α) : ⌊a+1⌋ = ⌊a⌋+1 :=
  by 
    convert floor_add_int a 1 
    exact cast_one.symm

@[simp]
theorem floor_int_add (z : ℤ) (a : α) : ⌊«expr↑ » z+a⌋ = z+⌊a⌋ :=
  by 
    simpa only [add_commₓ] using floor_add_int a z

@[simp]
theorem floor_add_nat (a : α) (n : ℕ) : ⌊a+n⌋ = ⌊a⌋+n :=
  floor_add_int a n

@[simp]
theorem floor_nat_add (n : ℕ) (a : α) : ⌊«expr↑ » n+a⌋ = n+⌊a⌋ :=
  floor_int_add n a

@[simp]
theorem floor_sub_int (a : α) (z : ℤ) : ⌊a - z⌋ = ⌊a⌋ - z :=
  Eq.trans
    (by 
      rw [Int.cast_neg, sub_eq_add_neg])
    (floor_add_int _ _)

@[simp]
theorem floor_sub_nat (a : α) (n : ℕ) : ⌊a - n⌋ = ⌊a⌋ - n :=
  floor_sub_int a n

-- error in Algebra.Order.Floor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem abs_sub_lt_one_of_floor_eq_floor
{α : Type*}
[linear_ordered_comm_ring α]
[floor_ring α]
{a b : α}
(h : «expr = »(«expr⌊ ⌋»(a), «expr⌊ ⌋»(b))) : «expr < »(«expr| |»(«expr - »(a, b)), 1) :=
begin
  have [] [":", expr «expr < »(a, «expr + »(«expr⌊ ⌋»(a), 1))] [":=", expr lt_floor_add_one a],
  have [] [":", expr «expr < »(b, «expr + »(«expr⌊ ⌋»(b), 1))] [":=", expr lt_floor_add_one b],
  have [] [":", expr «expr = »((«expr⌊ ⌋»(a) : α), «expr⌊ ⌋»(b))] [":=", expr int.cast_inj.2 h],
  have [] [":", expr «expr ≤ »((«expr⌊ ⌋»(a) : α), a)] [":=", expr floor_le a],
  have [] [":", expr «expr ≤ »((«expr⌊ ⌋»(b) : α), b)] [":=", expr floor_le b],
  exact [expr abs_sub_lt_iff.2 ⟨by linarith [] [] [], by linarith [] [] []⟩]
end

theorem floor_eq_iff : ⌊a⌋ = z ↔ «expr↑ » z ≤ a ∧ a < z+1 :=
  by 
    rw [le_antisymm_iffₓ, le_floor, ←Int.lt_add_one_iff, floor_lt, Int.cast_add, Int.cast_one, And.comm]

theorem floor_eq_on_Ico (n : ℤ) : ∀ a (_ : a ∈ Set.Ico (n : α) (n+1)), ⌊a⌋ = n :=
  fun a ⟨h₀, h₁⟩ => floor_eq_iff.mpr ⟨h₀, h₁⟩

theorem floor_eq_on_Ico' (n : ℤ) : ∀ a (_ : a ∈ Set.Ico (n : α) (n+1)), (⌊a⌋ : α) = n :=
  fun a ha => congr_argₓ _$ floor_eq_on_Ico n a ha

@[simp]
theorem preimage_floor_singleton (m : ℤ) : (floor : α → ℤ) ⁻¹' {m} = Ico m (m+1) :=
  ext$ fun x => floor_eq_iff

/-! #### Fractional part -/


@[simp]
theorem self_sub_floor (a : α) : a - ⌊a⌋ = fract a :=
  rfl

@[simp]
theorem floor_add_fract (a : α) : ((⌊a⌋ : α)+fract a) = a :=
  add_sub_cancel'_right _ _

@[simp]
theorem fract_add_floor (a : α) : (fract a+⌊a⌋) = a :=
  sub_add_cancel _ _

@[simp]
theorem fract_add_int (a : α) (m : ℤ) : fract (a+m) = fract a :=
  by 
    rw [fract]
    simp 

@[simp]
theorem fract_sub_int (a : α) (m : ℤ) : fract (a - m) = fract a :=
  by 
    rw [fract]
    simp 

@[simp]
theorem fract_int_add (m : ℤ) (a : α) : fract («expr↑ » m+a) = fract a :=
  by 
    rw [add_commₓ, fract_add_int]

@[simp]
theorem self_sub_fract (a : α) : a - fract a = ⌊a⌋ :=
  sub_sub_cancel _ _

@[simp]
theorem fract_sub_self (a : α) : fract a - a = -⌊a⌋ :=
  sub_sub_cancel_left _ _

theorem fract_nonneg (a : α) : 0 ≤ fract a :=
  sub_nonneg.2$ floor_le _

theorem fract_lt_one (a : α) : fract a < 1 :=
  sub_lt.1$ sub_one_lt_floor _

@[simp]
theorem fract_zero : fract (0 : α) = 0 :=
  by 
    rw [fract, floor_zero, cast_zero, sub_self]

@[simp]
theorem fract_coe (z : ℤ) : fract (z : α) = 0 :=
  by 
    unfold fract 
    rw [floor_coe]
    exact sub_self _

@[simp]
theorem fract_floor (a : α) : fract (⌊a⌋ : α) = 0 :=
  fract_coe _

@[simp]
theorem floor_fract (a : α) : ⌊fract a⌋ = 0 :=
  floor_eq_iff.2
    ⟨fract_nonneg _,
      by 
        rw [Int.cast_zero, zero_addₓ]
        exact fract_lt_one a⟩

theorem fract_eq_iff {a b : α} : fract a = b ↔ 0 ≤ b ∧ b < 1 ∧ ∃ z : ℤ, a - b = z :=
  ⟨fun h =>
      by 
        rw [←h]
        exact ⟨fract_nonneg _, fract_lt_one _, ⟨⌊a⌋, sub_sub_cancel _ _⟩⟩,
    by 
      rintro ⟨h₀, h₁, z, hz⟩
      show a - ⌊a⌋ = b 
      apply Eq.symm 
      rw [eq_sub_iff_add_eq, add_commₓ, ←eq_sub_iff_add_eq]
      rw [hz, Int.cast_inj, floor_eq_iff, ←hz]
      clear hz 
      split  <;> simpa [sub_eq_add_neg, add_assocₓ]⟩

theorem fract_eq_fract {a b : α} : fract a = fract b ↔ ∃ z : ℤ, a - b = z :=
  ⟨fun h =>
      ⟨⌊a⌋ - ⌊b⌋,
        by 
          unfold fract  at h 
          rw [Int.cast_sub, sub_eq_sub_iff_sub_eq_sub.1 h]⟩,
    by 
      rintro ⟨z, hz⟩
      refine' fract_eq_iff.2 ⟨fract_nonneg _, fract_lt_one _, z+⌊b⌋, _⟩
      rw [eq_add_of_sub_eq hz, add_commₓ, Int.cast_add]
      exact add_sub_sub_cancel _ _ _⟩

@[simp]
theorem fract_eq_self {a : α} : fract a = a ↔ 0 ≤ a ∧ a < 1 :=
  fract_eq_iff.trans$ And.assoc.symm.trans$ and_iff_left ⟨0, sub_self a⟩

@[simp]
theorem fract_fract (a : α) : fract (fract a) = fract a :=
  fract_eq_self.2 ⟨fract_nonneg _, fract_lt_one _⟩

theorem fract_add (a b : α) : ∃ z : ℤ, fract (a+b) - fract a - fract b = z :=
  ⟨(⌊a⌋+⌊b⌋) - ⌊a+b⌋,
    by 
      unfold fract 
      simp [sub_eq_add_neg]
      abel⟩

theorem fract_mul_nat (a : α) (b : ℕ) : ∃ z : ℤ, (fract a*b) - fract (a*b) = z :=
  by 
    induction' b with c hc 
    use 0
    simp 
    rcases hc with ⟨z, hz⟩
    rw [Nat.succ_eq_add_one, Nat.cast_add, mul_addₓ, mul_addₓ, Nat.cast_one, mul_oneₓ, mul_oneₓ]
    rcases fract_add (a*c) a with ⟨y, hy⟩
    use z - y 
    rw [Int.cast_sub, ←hz, ←hy]
    abel

theorem preimage_fract (s : Set α) : fract ⁻¹' s = ⋃m : ℤ, (fun x => x - m) ⁻¹' (s ∩ Ico (0 : α) 1) :=
  by 
    ext x 
    simp only [mem_preimage, mem_Union, mem_inter_eq]
    refine' ⟨fun h => ⟨⌊x⌋, h, fract_nonneg x, fract_lt_one x⟩, _⟩
    rintro ⟨m, hms, hm0, hm1⟩
    obtain rfl : ⌊x⌋ = m 
    exact floor_eq_iff.2 ⟨sub_nonneg.1 hm0, sub_lt_iff_lt_add'.1 hm1⟩
    exact hms

theorem image_fract (s : Set α) : fract '' s = ⋃m : ℤ, (fun x => x - m) '' s ∩ Ico 0 1 :=
  by 
    ext x 
    simp only [mem_image, mem_inter_eq, mem_Union]
    split 
    ·
      rintro ⟨y, hy, rfl⟩
      exact ⟨⌊y⌋, ⟨y, hy, rfl⟩, fract_nonneg y, fract_lt_one y⟩
    ·
      rintro ⟨m, ⟨y, hys, rfl⟩, h0, h1⟩
      obtain rfl : ⌊y⌋ = m 
      exact floor_eq_iff.2 ⟨sub_nonneg.1 h0, sub_lt_iff_lt_add'.1 h1⟩
      exact ⟨y, hys, rfl⟩

/-! #### Ceil -/


theorem gc_ceil_coe : GaloisConnection ceil (coeₓ : ℤ → α) :=
  FloorRing.gc_ceil_coe

theorem ceil_le : ⌈a⌉ ≤ z ↔ a ≤ z :=
  gc_ceil_coe a z

theorem floor_neg : ⌊-a⌋ = -⌈a⌉ :=
  eq_of_forall_le_iff
    fun z =>
      by 
        rw [le_neg, ceil_le, le_floor, Int.cast_neg, le_neg]

theorem ceil_neg : ⌈-a⌉ = -⌊a⌋ :=
  eq_of_forall_ge_iff
    fun z =>
      by 
        rw [neg_le, ceil_le, le_floor, Int.cast_neg, neg_le]

theorem lt_ceil : z < ⌈a⌉ ↔ (z : α) < a :=
  lt_iff_lt_of_le_iff_le ceil_le

theorem ceil_le_floor_add_one (a : α) : ⌈a⌉ ≤ ⌊a⌋+1 :=
  by 
    rw [ceil_le, Int.cast_add, Int.cast_one]
    exact (lt_floor_add_one a).le

theorem le_ceil (a : α) : a ≤ ⌈a⌉ :=
  gc_ceil_coe.le_u_l a

@[simp]
theorem ceil_coe (z : ℤ) : ⌈(z : α)⌉ = z :=
  eq_of_forall_ge_iff$
    fun a =>
      by 
        rw [ceil_le, Int.cast_le]

theorem ceil_mono : Monotone (ceil : α → ℤ) :=
  gc_ceil_coe.monotone_l

@[simp]
theorem ceil_add_int (a : α) (z : ℤ) : ⌈a+z⌉ = ⌈a⌉+z :=
  by 
    rw [←neg_inj, neg_add', ←floor_neg, ←floor_neg, neg_add', floor_sub_int]

@[simp]
theorem ceil_add_one (a : α) : ⌈a+1⌉ = ⌈a⌉+1 :=
  by 
    convert ceil_add_int a (1 : ℤ)
    exact cast_one.symm

@[simp]
theorem ceil_sub_int (a : α) (z : ℤ) : ⌈a - z⌉ = ⌈a⌉ - z :=
  Eq.trans
    (by 
      rw [Int.cast_neg, sub_eq_add_neg])
    (ceil_add_int _ _)

@[simp]
theorem ceil_sub_one (a : α) : ⌈a - 1⌉ = ⌈a⌉ - 1 :=
  by 
    rw [eq_sub_iff_add_eq, ←ceil_add_one, sub_add_cancel]

theorem ceil_lt_add_one (a : α) : (⌈a⌉ : α) < a+1 :=
  by 
    rw [←lt_ceil, ←Int.cast_one, ceil_add_int]
    apply lt_add_one

theorem ceil_pos : 0 < ⌈a⌉ ↔ 0 < a :=
  lt_ceil

@[simp]
theorem ceil_zero : ⌈(0 : α)⌉ = 0 :=
  ceil_coe 0

theorem ceil_nonneg (ha : 0 ≤ a) : 0 ≤ ⌈a⌉ :=
  by 
    exactModCast ha.trans (le_ceil a)

theorem ceil_eq_iff : ⌈a⌉ = z ↔ «expr↑ » z - 1 < a ∧ a ≤ z :=
  by 
    rw [←ceil_le, ←Int.cast_one, ←Int.cast_sub, ←lt_ceil, Int.sub_one_lt_iff, le_antisymm_iffₓ, And.comm]

theorem ceil_eq_on_Ioc (z : ℤ) : ∀ a (_ : a ∈ Set.Ioc (z - 1 : α) z), ⌈a⌉ = z :=
  fun a ⟨h₀, h₁⟩ => ceil_eq_iff.mpr ⟨h₀, h₁⟩

theorem ceil_eq_on_Ioc' (z : ℤ) : ∀ a (_ : a ∈ Set.Ioc (z - 1 : α) z), (⌈a⌉ : α) = z :=
  fun a ha =>
    by 
      exactModCast ceil_eq_on_Ioc z a ha

theorem floor_lt_ceil_of_lt {a b : α} (h : a < b) : ⌊a⌋ < ⌈b⌉ :=
  cast_lt.1$ (floor_le a).trans_lt$ h.trans_le$ le_ceil b

@[simp]
theorem preimage_ceil_singleton (m : ℤ) : (ceil : α → ℤ) ⁻¹' {m} = Ioc (m - 1) m :=
  ext$ fun x => ceil_eq_iff

/-! #### A floor ring as a floor semiring -/


instance (priority := 100)_root_.floor_ring.to_floor_semiring : FloorSemiring α :=
  { floor := fun a => ⌊a⌋.toNat, ceil := fun a => ⌈a⌉.toNat,
    floor_of_neg := fun a ha => Int.to_nat_of_nonpos (Int.floor_nonpos ha.le),
    gc_floor :=
      fun a n ha =>
        by 
          rw [Int.le_to_nat_iff (Int.floor_nonneg.2 ha), Int.le_floor]
          rfl,
    gc_ceil :=
      fun a n =>
        by 
          rw [Int.to_nat_le, Int.ceil_le]
          rfl }

theorem floor_to_nat (a : α) : ⌊a⌋.toNat = ⌊a⌋₊ :=
  rfl

theorem ceil_to_nat (a : α) : ⌈a⌉.toNat = ⌈a⌉₊ :=
  rfl

/-! #### Intervals -/


@[simp]
theorem preimage_Ioo {a b : α} : (coeₓ : ℤ → α) ⁻¹' Set.Ioo a b = Set.Ioo ⌊a⌋ ⌈b⌉ :=
  by 
    ext 
    simp [floor_lt, lt_ceil]

@[simp]
theorem preimage_Ico {a b : α} : (coeₓ : ℤ → α) ⁻¹' Set.Ico a b = Set.Ico ⌈a⌉ ⌈b⌉ :=
  by 
    ext 
    simp [ceil_le, lt_ceil]

@[simp]
theorem preimage_Ioc {a b : α} : (coeₓ : ℤ → α) ⁻¹' Set.Ioc a b = Set.Ioc ⌊a⌋ ⌊b⌋ :=
  by 
    ext 
    simp [floor_lt, le_floor]

@[simp]
theorem preimage_Icc {a b : α} : (coeₓ : ℤ → α) ⁻¹' Set.Icc a b = Set.Icc ⌈a⌉ ⌊b⌋ :=
  by 
    ext 
    simp [ceil_le, le_floor]

@[simp]
theorem preimage_Ioi : (coeₓ : ℤ → α) ⁻¹' Set.Ioi a = Set.Ioi ⌊a⌋ :=
  by 
    ext 
    simp [floor_lt]

@[simp]
theorem preimage_Ici : (coeₓ : ℤ → α) ⁻¹' Set.Ici a = Set.Ici ⌈a⌉ :=
  by 
    ext 
    simp [ceil_le]

@[simp]
theorem preimage_Iio : (coeₓ : ℤ → α) ⁻¹' Set.Iio a = Set.Iio ⌈a⌉ :=
  by 
    ext 
    simp [lt_ceil]

@[simp]
theorem preimage_Iic : (coeₓ : ℤ → α) ⁻¹' Set.Iic a = Set.Iic ⌊a⌋ :=
  by 
    ext 
    simp [le_floor]

end Int

-- error in Algebra.Order.Floor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- There exists at most one `floor_ring` structure on a given linear ordered ring. -/
theorem subsingleton_floor_ring {α} [linear_ordered_ring α] : subsingleton (floor_ring α) :=
begin
  refine [expr ⟨λ H₁ H₂, _⟩],
  have [] [":", expr «expr = »(H₁.floor, H₂.floor)] [":=", expr funext (λ
    a, «expr $ »(H₁.gc_coe_floor.u_unique H₂.gc_coe_floor, λ _, rfl))],
  have [] [":", expr «expr = »(H₁.ceil, H₂.ceil)] [":=", expr funext (λ
    a, «expr $ »(H₁.gc_ceil_coe.l_unique H₂.gc_ceil_coe, λ _, rfl))],
  cases [expr H₁] [],
  cases [expr H₂] [],
  congr; assumption
end

