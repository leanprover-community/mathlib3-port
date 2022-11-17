/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon, Patrick Massot
-/
import Mathbin.Tactic.PiInstances
import Mathbin.Algebra.Group.Pi
import Mathbin.Algebra.Hom.Ring

/-!
# Pi instances for ring

This file defines instances for ring, semiring and related structures on Pi Types
-/


namespace Pi

universe u v w

variable {I : Type u}

-- The indexing type
variable {f : I → Type v}

-- The family of types already equipped with instances
variable (x y : ∀ i, f i) (i : I)

instance distrib [∀ i, Distrib $ f i] : Distrib (∀ i : I, f i) := by
  refine_struct { add := (· + ·), mul := (· * ·).. } <;> pi_instance_derive_field
#align pi.distrib Pi.distrib

instance nonUnitalNonAssocSemiring [∀ i, NonUnitalNonAssocSemiring $ f i] : NonUnitalNonAssocSemiring (∀ i : I, f i) :=
  by refine_struct { zero := (0 : ∀ i, f i), add := (· + ·), mul := (· * ·).. } <;> pi_instance_derive_field
#align pi.non_unital_non_assoc_semiring Pi.nonUnitalNonAssocSemiring

instance nonUnitalSemiring [∀ i, NonUnitalSemiring $ f i] : NonUnitalSemiring (∀ i : I, f i) := by
  refine_struct { zero := (0 : ∀ i, f i), add := (· + ·), mul := (· * ·).. } <;> pi_instance_derive_field
#align pi.non_unital_semiring Pi.nonUnitalSemiring

instance nonAssocSemiring [∀ i, NonAssocSemiring $ f i] : NonAssocSemiring (∀ i : I, f i) := by
  refine_struct { zero := (0 : ∀ i, f i), one := 1, add := (· + ·), mul := (· * ·).. } <;> pi_instance_derive_field
#align pi.non_assoc_semiring Pi.nonAssocSemiring

instance semiring [∀ i, Semiring $ f i] : Semiring (∀ i : I, f i) := by
  refine_struct
      { zero := (0 : ∀ i, f i), one := 1, add := (· + ·), mul := (· * ·), nsmul := AddMonoid.nsmul,
        npow := Monoid.npow } <;>
    pi_instance_derive_field
#align pi.semiring Pi.semiring

instance nonUnitalCommSemiring [∀ i, NonUnitalCommSemiring $ f i] : NonUnitalCommSemiring (∀ i : I, f i) := by
  refine_struct { zero := (0 : ∀ i, f i), add := (· + ·), mul := (· * ·), nsmul := AddMonoid.nsmul } <;>
    pi_instance_derive_field
#align pi.non_unital_comm_semiring Pi.nonUnitalCommSemiring

instance commSemiring [∀ i, CommSemiring $ f i] : CommSemiring (∀ i : I, f i) := by
  refine_struct
      { zero := (0 : ∀ i, f i), one := 1, add := (· + ·), mul := (· * ·), nsmul := AddMonoid.nsmul,
        npow := Monoid.npow } <;>
    pi_instance_derive_field
#align pi.comm_semiring Pi.commSemiring

instance nonUnitalNonAssocRing [∀ i, NonUnitalNonAssocRing $ f i] : NonUnitalNonAssocRing (∀ i : I, f i) := by
  refine_struct
      { zero := (0 : ∀ i, f i), add := (· + ·), mul := (· * ·), neg := Neg.neg, nsmul := AddMonoid.nsmul,
        zsmul := SubNegMonoid.zsmul } <;>
    pi_instance_derive_field
#align pi.non_unital_non_assoc_ring Pi.nonUnitalNonAssocRing

instance nonUnitalRing [∀ i, NonUnitalRing $ f i] : NonUnitalRing (∀ i : I, f i) := by
  refine_struct
      { zero := (0 : ∀ i, f i), add := (· + ·), mul := (· * ·), neg := Neg.neg, nsmul := AddMonoid.nsmul,
        zsmul := SubNegMonoid.zsmul } <;>
    pi_instance_derive_field
#align pi.non_unital_ring Pi.nonUnitalRing

instance nonAssocRing [∀ i, NonAssocRing $ f i] : NonAssocRing (∀ i : I, f i) := by
  refine_struct
      { zero := (0 : ∀ i, f i), add := (· + ·), mul := (· * ·), neg := Neg.neg, nsmul := AddMonoid.nsmul,
        zsmul := SubNegMonoid.zsmul } <;>
    pi_instance_derive_field
#align pi.non_assoc_ring Pi.nonAssocRing

instance ring [∀ i, Ring $ f i] : Ring (∀ i : I, f i) := by
  refine_struct
      { zero := (0 : ∀ i, f i), one := 1, add := (· + ·), mul := (· * ·), neg := Neg.neg, nsmul := AddMonoid.nsmul,
        zsmul := SubNegMonoid.zsmul, npow := Monoid.npow } <;>
    pi_instance_derive_field
#align pi.ring Pi.ring

instance nonUnitalCommRing [∀ i, NonUnitalCommRing $ f i] : NonUnitalCommRing (∀ i : I, f i) := by
  refine_struct
      { zero := (0 : ∀ i, f i), add := (· + ·), mul := (· * ·), neg := Neg.neg, nsmul := AddMonoid.nsmul,
        zsmul := SubNegMonoid.zsmul } <;>
    pi_instance_derive_field
#align pi.non_unital_comm_ring Pi.nonUnitalCommRing

instance commRing [∀ i, CommRing $ f i] : CommRing (∀ i : I, f i) := by
  refine_struct
      { zero := (0 : ∀ i, f i), one := 1, add := (· + ·), mul := (· * ·), neg := Neg.neg, nsmul := AddMonoid.nsmul,
        zsmul := SubNegMonoid.zsmul, npow := Monoid.npow } <;>
    pi_instance_derive_field
#align pi.comm_ring Pi.commRing

/-- A family of non-unital ring homomorphisms `f a : γ →ₙ+* β a` defines a non-unital ring
homomorphism `pi.non_unital_ring_hom f : γ →+* Π a, β a` given by
`pi.non_unital_ring_hom f x b = f b x`. -/
@[simps]
protected def nonUnitalRingHom {γ : Type w} [∀ i, NonUnitalNonAssocSemiring (f i)] [NonUnitalNonAssocSemiring γ]
    (g : ∀ i, γ →ₙ+* f i) : γ →ₙ+* ∀ i, f i where
  toFun x b := g b x
  map_add' x y := funext $ fun z => map_add (g z) x y
  map_mul' x y := funext $ fun z => map_mul (g z) x y
  map_zero' := funext $ fun z => map_zero (g z)
#align pi.non_unital_ring_hom Pi.nonUnitalRingHom

theorem non_unital_ring_hom_injective {γ : Type w} [Nonempty I] [∀ i, NonUnitalNonAssocSemiring (f i)]
    [NonUnitalNonAssocSemiring γ] (g : ∀ i, γ →ₙ+* f i) (hg : ∀ i, Function.Injective (g i)) :
    Function.Injective (Pi.nonUnitalRingHom g) := fun x y h =>
  let ⟨i⟩ := ‹Nonempty I›
  hg i ((Function.funext_iff.mp h : _) i)
#align pi.non_unital_ring_hom_injective Pi.non_unital_ring_hom_injective

/-- A family of ring homomorphisms `f a : γ →+* β a` defines a ring homomorphism
`pi.ring_hom f : γ →+* Π a, β a` given by `pi.ring_hom f x b = f b x`. -/
@[simps]
protected def ringHom {γ : Type w} [∀ i, NonAssocSemiring (f i)] [NonAssocSemiring γ] (g : ∀ i, γ →+* f i) :
    γ →+* ∀ i, f i where
  toFun x b := g b x
  map_add' x y := funext $ fun z => (g z).map_add x y
  map_mul' x y := funext $ fun z => (g z).map_mul x y
  map_one' := funext $ fun z => (g z).map_one
  map_zero' := funext $ fun z => (g z).map_zero
#align pi.ring_hom Pi.ringHom

theorem ring_hom_injective {γ : Type w} [Nonempty I] [∀ i, NonAssocSemiring (f i)] [NonAssocSemiring γ]
    (g : ∀ i, γ →+* f i) (hg : ∀ i, Function.Injective (g i)) : Function.Injective (Pi.ringHom g) := fun x y h =>
  let ⟨i⟩ := ‹Nonempty I›
  hg i ((Function.funext_iff.mp h : _) i)
#align pi.ring_hom_injective Pi.ring_hom_injective

end Pi

section NonUnitalRingHom

universe u v

variable {I : Type u}

/-- Evaluation of functions into an indexed collection of non-unital rings at a point is a
non-unital ring homomorphism. This is `function.eval` as a `non_unital_ring_hom`. -/
@[simps]
def Pi.evalNonUnitalRingHom (f : I → Type v) [∀ i, NonUnitalNonAssocSemiring (f i)] (i : I) : (∀ i, f i) →ₙ+* f i :=
  { Pi.evalMulHom f i, Pi.evalAddMonoidHom f i with }
#align pi.eval_non_unital_ring_hom Pi.evalNonUnitalRingHom

/-- `function.const` as a `non_unital_ring_hom`. -/
@[simps]
def Pi.constNonUnitalRingHom (α β : Type _) [NonUnitalNonAssocSemiring β] : β →ₙ+* α → β :=
  { Pi.nonUnitalRingHom fun _ => NonUnitalRingHom.id β with toFun := Function.const _ }
#align pi.const_non_unital_ring_hom Pi.constNonUnitalRingHom

/-- Non-unital ring homomorphism between the function spaces `I → α` and `I → β`, induced by a
non-unital ring homomorphism `f` between `α` and `β`. -/
@[simps]
protected def NonUnitalRingHom.compLeft {α β : Type _} [NonUnitalNonAssocSemiring α] [NonUnitalNonAssocSemiring β]
    (f : α →ₙ+* β) (I : Type _) : (I → α) →ₙ+* I → β :=
  { f.toMulHom.compLeft I, f.toAddMonoidHom.compLeft I with toFun := fun h => f ∘ h }
#align non_unital_ring_hom.comp_left NonUnitalRingHom.compLeft

end NonUnitalRingHom

section RingHom

universe u v

variable {I : Type u}

/-- Evaluation of functions into an indexed collection of rings at a point is a ring
homomorphism. This is `function.eval` as a `ring_hom`. -/
@[simps]
def Pi.evalRingHom (f : I → Type v) [∀ i, NonAssocSemiring (f i)] (i : I) : (∀ i, f i) →+* f i :=
  { Pi.evalMonoidHom f i, Pi.evalAddMonoidHom f i with }
#align pi.eval_ring_hom Pi.evalRingHom

/-- `function.const` as a `ring_hom`. -/
@[simps]
def Pi.constRingHom (α β : Type _) [NonAssocSemiring β] : β →+* α → β :=
  { Pi.ringHom fun _ => RingHom.id β with toFun := Function.const _ }
#align pi.const_ring_hom Pi.constRingHom

/-- Ring homomorphism between the function spaces `I → α` and `I → β`, induced by a ring
homomorphism `f` between `α` and `β`. -/
@[simps]
protected def RingHom.compLeft {α β : Type _} [NonAssocSemiring α] [NonAssocSemiring β] (f : α →+* β) (I : Type _) :
    (I → α) →+* I → β :=
  { f.toMonoidHom.compLeft I, f.toAddMonoidHom.compLeft I with toFun := fun h => f ∘ h }
#align ring_hom.comp_left RingHom.compLeft

end RingHom

