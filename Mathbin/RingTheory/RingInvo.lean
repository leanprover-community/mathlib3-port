import Mathbin.Data.Equiv.Ring 
import Mathbin.Algebra.Ring.Opposite

/-!
# Ring involutions

This file defines a ring involution as a structure extending `R ≃+* Rᵐᵒᵖ`,
with the additional fact `f.involution : (f (f x).unop).unop = x`.

## Notations

We provide a coercion to a function `R → Rᵐᵒᵖ`.

## References

* <https://en.wikipedia.org/wiki/Involution_(mathematics)#Ring_theory>

## Tags

Ring involution
-/


variable (R : Type _)

/-- A ring involution -/
structure RingInvo [Semiringₓ R] extends R ≃+* «expr ᵐᵒᵖ» R where 
  involution' : ∀ x, (to_fun (to_fun x).unop).unop = x

namespace RingInvo

variable {R} [Semiringₓ R]

/-- Construct a ring involution from a ring homomorphism. -/
def mk' (f : R →+* «expr ᵐᵒᵖ» R) (involution : ∀ r, (f (f r).unop).unop = r) : RingInvo R :=
  { f with invFun := fun r => (f r.unop).unop, left_inv := fun r => involution r,
    right_inv := fun r => MulOpposite.unop_injective$ involution _, involution' := involution }

instance : CoeFun (RingInvo R) fun _ => R → «expr ᵐᵒᵖ» R :=
  ⟨fun f => f.to_ring_equiv.to_fun⟩

@[simp]
theorem to_fun_eq_coe (f : RingInvo R) : f.to_fun = f :=
  rfl

@[simp]
theorem involution (f : RingInvo R) (x : R) : (f (f x).unop).unop = x :=
  f.involution' x

instance has_coe_to_ring_equiv : Coe (RingInvo R) (R ≃+* «expr ᵐᵒᵖ» R) :=
  ⟨RingInvo.toRingEquiv⟩

@[normCast]
theorem coe_ring_equiv (f : RingInvo R) (a : R) : (f : R ≃+* «expr ᵐᵒᵖ» R) a = f a :=
  rfl

@[simp]
theorem map_eq_zero_iff (f : RingInvo R) {x : R} : f x = 0 ↔ x = 0 :=
  f.to_ring_equiv.map_eq_zero_iff

end RingInvo

open RingInvo

section CommRingₓ

variable [CommRingₓ R]

/-- The identity function of a `comm_ring` is a ring involution. -/
protected def RingInvo.id : RingInvo R :=
  { RingEquiv.toOpposite R with involution' := fun r => rfl }

instance : Inhabited (RingInvo R) :=
  ⟨RingInvo.id _⟩

end CommRingₓ

