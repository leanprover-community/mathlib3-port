/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module algebra.order.hom.basic
! leanprover-community/mathlib commit 7ea604785a41a0681eac70c5a82372493dbefc68
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.GroupPower.Order

/-!
# Algebraic order homomorphism classes

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines hom classes for common properties at the intersection of order theory and algebra.

## Typeclasses

Basic typeclasses
* `nonneg_hom_class`: Homs are nonnegative: `∀ f a, 0 ≤ f a`
* `subadditive_hom_class`: Homs are subadditive: `∀ f a b, f (a + b) ≤ f a + f b`
* `submultiplicative_hom_class`: Homs are submultiplicative: `∀ f a b, f (a * b) ≤ f a * f b`
* `mul_le_add_hom_class`: `∀ f a b, f (a * b) ≤ f a + f b`
* `nonarchimedean_hom_class`: `∀ a b, f (a + b) ≤ max (f a) (f b)`

Group norms
* `add_group_seminorm_class`: Homs are nonnegative, subadditive, even and preserve zero.
* `group_seminorm_class`: Homs are nonnegative, respect `f (a * b) ≤ f a + f b`, `f a⁻¹ = f a` and
  preserve zero.
* `add_group_norm_class`: Homs are seminorms such that `f x = 0 → x = 0` for all `x`.
* `group_norm_class`: Homs are seminorms such that `f x = 0 → x = 1` for all `x`.

Ring norms
* `ring_seminorm_class`: Homs are submultiplicative group norms.
* `ring_norm_class`: Homs are ring seminorms that are also additive group norms.
* `mul_ring_seminorm_class`: Homs are ring seminorms that are multiplicative.
* `mul_ring_norm_class`: Homs are ring norms that are multiplicative.

## Notes

Typeclasses for seminorms are defined here while types of seminorms are defined in
`analysis.normed.group.seminorm` and `analysis.normed.ring.seminorm` because absolute values are
multiplicative ring norms but outside of this use we only consider real-valued seminorms.

## TODO

Finitary versions of the current lemmas.
-/


library_note "out-param inheritance"/--
Diamond inheritance cannot depend on `out_param`s in the following circumstances:
 * there are three classes `top`, `middle`, `bottom`
 * all of these classes have a parameter `(α : out_param _)`
 * all of these classes have an instance parameter `[root α]` that depends on this `out_param`
 * the `root` class has two child classes: `left` and `right`, these are siblings in the hierarchy
 * the instance `bottom.to_middle` takes a `[left α]` parameter
 * the instance `middle.to_top` takes a `[right α]` parameter
 * there is a `leaf` class that inherits from both `left` and `right`.
In that case, given instances `bottom α` and `leaf α`, Lean cannot synthesize a `top α` instance,
even though the hypotheses of the instances `bottom.to_middle` and `middle.to_top` are satisfied.

There are two workarounds:
* You could replace the bundled inheritance implemented by the instance `middle.to_top` with
  unbundled inheritance implemented by adding a `[top α]` parameter to the `middle` class. This is
  the preferred option since it is also more compatible with Lean 4, at the cost of being more work
  to implement and more verbose to use.
* You could weaken the `bottom.to_middle` instance by making it depend on a subclass of
  `middle.to_top`'s parameter, in this example replacing `[left α]` with `[leaf α]`.
-/


open Function

variable {ι F α β γ δ : Type _}

/-! ### Basics -/


#print NonnegHomClass /-
/-- `nonneg_hom_class F α β` states that `F` is a type of nonnegative morphisms. -/
class NonnegHomClass (F : Type _) (α β : outParam <| Type _) [Zero β] [LE β] extends
    FunLike F α fun _ => β where
  map_nonneg (f : F) : ∀ a, 0 ≤ f a
#align nonneg_hom_class NonnegHomClass
-/

#print SubadditiveHomClass /-
/-- `subadditive_hom_class F α β` states that `F` is a type of subadditive morphisms. -/
class SubadditiveHomClass (F : Type _) (α β : outParam <| Type _) [Add α] [Add β] [LE β] extends
    FunLike F α fun _ => β where
  map_add_le_add (f : F) : ∀ a b, f (a + b) ≤ f a + f b
#align subadditive_hom_class SubadditiveHomClass
-/

#print SubmultiplicativeHomClass /-
/-- `submultiplicative_hom_class F α β` states that `F` is a type of submultiplicative morphisms. -/
@[to_additive SubadditiveHomClass]
class SubmultiplicativeHomClass (F : Type _) (α β : outParam <| Type _) [Mul α] [Mul β]
    [LE β] extends FunLike F α fun _ => β where
  map_mul_le_mul (f : F) : ∀ a b, f (a * b) ≤ f a * f b
#align submultiplicative_hom_class SubmultiplicativeHomClass
#align subadditive_hom_class SubadditiveHomClass
-/

#print MulLEAddHomClass /-
/-- `mul_le_add_hom_class F α β` states that `F` is a type of subadditive morphisms. -/
@[to_additive SubadditiveHomClass]
class MulLEAddHomClass (F : Type _) (α β : outParam <| Type _) [Mul α] [Add β] [LE β] extends
    FunLike F α fun _ => β where
  map_mul_le_add (f : F) : ∀ a b, f (a * b) ≤ f a + f b
#align mul_le_add_hom_class MulLEAddHomClass
#align subadditive_hom_class SubadditiveHomClass
-/

#print NonarchimedeanHomClass /-
/-- `nonarchimedean_hom_class F α β` states that `F` is a type of non-archimedean morphisms. -/
class NonarchimedeanHomClass (F : Type _) (α β : outParam <| Type _) [Add α] [LinearOrder β] extends
    FunLike F α fun _ => β where
  map_add_le_max (f : F) : ∀ a b, f (a + b) ≤ max (f a) (f b)
#align nonarchimedean_hom_class NonarchimedeanHomClass
-/

export NonnegHomClass (map_nonneg)

export SubadditiveHomClass (map_add_le_add)

export SubmultiplicativeHomClass (map_mul_le_mul)

export MulLEAddHomClass (map_mul_le_add)

export NonarchimedeanHomClass (map_add_le_max)

attribute [simp] map_nonneg

@[to_additive]
theorem le_map_mul_map_div [Group α] [CommSemigroup β] [LE β] [SubmultiplicativeHomClass F α β]
    (f : F) (a b : α) : f a ≤ f b * f (a / b) := by
  simpa only [mul_comm, div_mul_cancel'] using map_mul_le_mul f (a / b) b
#align le_map_mul_map_div le_map_mul_map_div
#align le_map_add_map_sub le_map_add_map_sub

@[to_additive]
theorem le_map_add_map_div [Group α] [AddCommSemigroup β] [LE β] [MulLEAddHomClass F α β] (f : F)
    (a b : α) : f a ≤ f b + f (a / b) := by
  simpa only [add_comm, div_mul_cancel'] using map_mul_le_add f (a / b) b
#align le_map_add_map_div le_map_add_map_div
#align le_map_add_map_sub le_map_add_map_sub

@[to_additive]
theorem le_map_div_mul_map_div [Group α] [CommSemigroup β] [LE β] [SubmultiplicativeHomClass F α β]
    (f : F) (a b c : α) : f (a / c) ≤ f (a / b) * f (b / c) := by
  simpa only [div_mul_div_cancel'] using map_mul_le_mul f (a / b) (b / c)
#align le_map_div_mul_map_div le_map_div_mul_map_div
#align le_map_sub_add_map_sub le_map_sub_add_map_sub

@[to_additive]
theorem le_map_div_add_map_div [Group α] [AddCommSemigroup β] [LE β] [MulLEAddHomClass F α β]
    (f : F) (a b c : α) : f (a / c) ≤ f (a / b) + f (b / c) := by
  simpa only [div_mul_div_cancel'] using map_mul_le_add f (a / b) (b / c)
#align le_map_div_add_map_div le_map_div_add_map_div
#align le_map_sub_add_map_sub le_map_sub_add_map_sub

/-! ### Group (semi)norms -/


#print AddGroupSeminormClass /-
/-- `add_group_seminorm_class F α` states that `F` is a type of `β`-valued seminorms on the additive
group `α`.

You should extend this class when you extend `add_group_seminorm`. -/
class AddGroupSeminormClass (F : Type _) (α β : outParam <| Type _) [AddGroup α]
    [OrderedAddCommMonoid β] extends SubadditiveHomClass F α β where
  map_zero (f : F) : f 0 = 0
  map_neg_eq_map (f : F) (a : α) : f (-a) = f a
#align add_group_seminorm_class AddGroupSeminormClass
-/

#print GroupSeminormClass /-
/-- `group_seminorm_class F α` states that `F` is a type of `β`-valued seminorms on the group `α`.

You should extend this class when you extend `group_seminorm`. -/
@[to_additive]
class GroupSeminormClass (F : Type _) (α β : outParam <| Type _) [Group α]
    [OrderedAddCommMonoid β] extends MulLEAddHomClass F α β where
  map_one_eq_zero (f : F) : f 1 = 0
  map_inv_eq_map (f : F) (a : α) : f a⁻¹ = f a
#align group_seminorm_class GroupSeminormClass
#align add_group_seminorm_class AddGroupSeminormClass
-/

#print AddGroupNormClass /-
/-- `add_group_norm_class F α` states that `F` is a type of `β`-valued norms on the additive group
`α`.

You should extend this class when you extend `add_group_norm`. -/
class AddGroupNormClass (F : Type _) (α β : outParam <| Type _) [AddGroup α]
    [OrderedAddCommMonoid β] extends AddGroupSeminormClass F α β where
  eq_zero_of_map_eq_zero (f : F) {a : α} : f a = 0 → a = 0
#align add_group_norm_class AddGroupNormClass
-/

#print GroupNormClass /-
/-- `group_norm_class F α` states that `F` is a type of `β`-valued norms on the group `α`.

You should extend this class when you extend `group_norm`. -/
@[to_additive]
class GroupNormClass (F : Type _) (α β : outParam <| Type _) [Group α]
    [OrderedAddCommMonoid β] extends GroupSeminormClass F α β where
  eq_one_of_map_eq_zero (f : F) {a : α} : f a = 0 → a = 1
#align group_norm_class GroupNormClass
#align add_group_norm_class AddGroupNormClass
-/

export AddGroupSeminormClass (map_neg_eq_map)

export GroupSeminormClass (map_one_eq_zero map_inv_eq_map)

export AddGroupNormClass (eq_zero_of_map_eq_zero)

export GroupNormClass (eq_one_of_map_eq_zero)

attribute [simp, to_additive map_zero] map_one_eq_zero

attribute [simp] map_neg_eq_map

attribute [simp, to_additive] map_inv_eq_map

attribute [to_additive] GroupSeminormClass.toMulLeAddHomClass

attribute [to_additive] GroupNormClass.toGroupSeminormClass

-- See note [lower instance priority]
instance (priority := 100) AddGroupSeminormClass.toZeroHomClass [AddGroup α]
    [OrderedAddCommMonoid β] [AddGroupSeminormClass F α β] : ZeroHomClass F α β :=
  { ‹AddGroupSeminormClass F α β› with }
#align add_group_seminorm_class.to_zero_hom_class AddGroupSeminormClass.toZeroHomClass

section GroupSeminormClass

variable [Group α] [OrderedAddCommMonoid β] [GroupSeminormClass F α β] (f : F) (x y : α)

include α β

@[to_additive]
theorem map_div_le_add : f (x / y) ≤ f x + f y := by rw [div_eq_mul_inv, ← map_inv_eq_map f y];
  exact map_mul_le_add _ _ _
#align map_div_le_add map_div_le_add
#align map_sub_le_add map_sub_le_add

@[to_additive]
theorem map_div_rev : f (x / y) = f (y / x) := by rw [← inv_div, map_inv_eq_map]
#align map_div_rev map_div_rev
#align map_sub_rev map_sub_rev

@[to_additive]
theorem le_map_add_map_div' : f x ≤ f y + f (y / x) := by
  simpa only [add_comm, map_div_rev, div_mul_cancel'] using map_mul_le_add f (x / y) y
#align le_map_add_map_div' le_map_add_map_div'
#align le_map_add_map_sub' le_map_add_map_sub'

end GroupSeminormClass

example [OrderedAddCommGroup β] : OrderedAddCommMonoid β :=
  inferInstance

@[to_additive]
theorem abs_sub_map_le_div [Group α] [LinearOrderedAddCommGroup β] [GroupSeminormClass F α β]
    (f : F) (x y : α) : |f x - f y| ≤ f (x / y) :=
  by
  rw [abs_sub_le_iff, sub_le_iff_le_add', sub_le_iff_le_add']
  exact ⟨le_map_add_map_div _ _ _, le_map_add_map_div' _ _ _⟩
#align abs_sub_map_le_div abs_sub_map_le_div
#align abs_sub_map_le_sub abs_sub_map_le_sub

-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) GroupSeminormClass.toNonnegHomClass [Group α]
    [LinearOrderedAddCommMonoid β] [GroupSeminormClass F α β] : NonnegHomClass F α β :=
  { ‹GroupSeminormClass F α β› with
    map_nonneg := fun f a =>
      (nsmul_nonneg_iff two_ne_zero).1 <| by rw [two_nsmul, ← map_one_eq_zero f, ← div_self' a];
        exact map_div_le_add _ _ _ }
#align group_seminorm_class.to_nonneg_hom_class GroupSeminormClass.toNonnegHomClass
#align add_group_seminorm_class.to_nonneg_hom_class AddGroupSeminormClass.toNonnegHomClass

section GroupNormClass

variable [Group α] [OrderedAddCommMonoid β] [GroupNormClass F α β] (f : F) {x : α}

include α β

@[simp, to_additive]
theorem map_eq_zero_iff_eq_one : f x = 0 ↔ x = 1 :=
  ⟨eq_one_of_map_eq_zero _, by rintro rfl; exact map_one_eq_zero _⟩
#align map_eq_zero_iff_eq_one map_eq_zero_iff_eq_one
#align map_eq_zero_iff_eq_zero map_eq_zero_iff_eq_zero

@[to_additive]
theorem map_ne_zero_iff_ne_one : f x ≠ 0 ↔ x ≠ 1 :=
  (map_eq_zero_iff_eq_one _).Not
#align map_ne_zero_iff_ne_one map_ne_zero_iff_ne_one
#align map_ne_zero_iff_ne_zero map_ne_zero_iff_ne_zero

end GroupNormClass

@[to_additive]
theorem map_pos_of_ne_one [Group α] [LinearOrderedAddCommMonoid β] [GroupNormClass F α β] (f : F)
    {x : α} (hx : x ≠ 1) : 0 < f x :=
  (map_nonneg _ _).lt_of_ne <| ((map_ne_zero_iff_ne_one _).2 hx).symm
#align map_pos_of_ne_one map_pos_of_ne_one
#align map_pos_of_ne_zero map_pos_of_ne_zero

/-! ### Ring (semi)norms -/


#print RingSeminormClass /-
/-- `ring_seminorm_class F α` states that `F` is a type of `β`-valued seminorms on the ring `α`.

You should extend this class when you extend `ring_seminorm`. -/
class RingSeminormClass (F : Type _) (α β : outParam <| Type _) [NonUnitalNonAssocRing α]
    [OrderedSemiring β] extends AddGroupSeminormClass F α β, SubmultiplicativeHomClass F α β
#align ring_seminorm_class RingSeminormClass
-/

#print RingNormClass /-
/-- `ring_norm_class F α` states that `F` is a type of `β`-valued norms on the ring `α`.

You should extend this class when you extend `ring_norm`. -/
class RingNormClass (F : Type _) (α β : outParam <| Type _) [NonUnitalNonAssocRing α]
    [OrderedSemiring β] extends RingSeminormClass F α β, AddGroupNormClass F α β
#align ring_norm_class RingNormClass
-/

#print MulRingSeminormClass /-
/-- `mul_ring_seminorm_class F α` states that `F` is a type of `β`-valued multiplicative seminorms
on the ring `α`.

You should extend this class when you extend `mul_ring_seminorm`. -/
class MulRingSeminormClass (F : Type _) (α β : outParam <| Type _) [NonAssocRing α]
    [OrderedSemiring β] extends AddGroupSeminormClass F α β, MonoidWithZeroHomClass F α β
#align mul_ring_seminorm_class MulRingSeminormClass
-/

#print MulRingNormClass /-
/-- `mul_ring_norm_class F α` states that `F` is a type of `β`-valued multiplicative norms on the
ring `α`.

You should extend this class when you extend `mul_ring_norm`. -/
class MulRingNormClass (F : Type _) (α β : outParam <| Type _) [NonAssocRing α]
    [OrderedSemiring β] extends MulRingSeminormClass F α β, AddGroupNormClass F α β
#align mul_ring_norm_class MulRingNormClass
-/

-- See note [out-param inheritance]
-- See note [lower instance priority]
instance (priority := 100) RingSeminormClass.toNonnegHomClass [NonUnitalNonAssocRing α]
    [LinearOrderedSemiring β] [RingSeminormClass F α β] : NonnegHomClass F α β :=
  AddGroupSeminormClass.toNonnegHomClass
#align ring_seminorm_class.to_nonneg_hom_class RingSeminormClass.toNonnegHomClass

#print MulRingSeminormClass.toRingSeminormClass /-
-- See note [lower instance priority]
instance (priority := 100) MulRingSeminormClass.toRingSeminormClass [NonAssocRing α]
    [OrderedSemiring β] [MulRingSeminormClass F α β] : RingSeminormClass F α β :=
  { ‹MulRingSeminormClass F α β› with map_mul_le_mul := fun f a b => (map_mul _ _ _).le }
#align mul_ring_seminorm_class.to_ring_seminorm_class MulRingSeminormClass.toRingSeminormClass
-/

#print MulRingNormClass.toRingNormClass /-
-- See note [lower instance priority]
instance (priority := 100) MulRingNormClass.toRingNormClass [NonAssocRing α] [OrderedSemiring β]
    [MulRingNormClass F α β] : RingNormClass F α β :=
  { ‹MulRingNormClass F α β›, MulRingSeminormClass.toRingSeminormClass with }
#align mul_ring_norm_class.to_ring_norm_class MulRingNormClass.toRingNormClass
-/

