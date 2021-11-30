import Mathbin.Algebra.GroupPower.Basic 
import Mathbin.Algebra.Ring.Opposite 
import Mathbin.GroupTheory.GroupAction.Opposite

/-!
# Introduce `smul_with_zero`

In analogy with the usual monoid action on a Type `M`, we introduce an action of a
`monoid_with_zero` on a Type with `0`.

In particular, for Types `R` and `M`, both containing `0`, we define `smul_with_zero R M` to
be the typeclass where the products `r • 0` and `0 • m` vanish for all `r : R` and all `m : M`.

Moreover, in the case in which `R` is a `monoid_with_zero`, we introduce the typeclass
`mul_action_with_zero R M`, mimicking group actions and having an absorbing `0` in `R`.
Thus, the action is required to be compatible with

* the unit of the monoid, acting as the identity;
* the zero of the monoid_with_zero, acting as zero;
* associativity of the monoid.

We also add an `instance`:

* any `monoid_with_zero` has a `mul_action_with_zero R R` acting on itself.
-/


variable {R R' M M' : Type _}

section HasZero

variable (R M)

/--  `smul_with_zero` is a class consisting of a Type `R` with `0 ∈ R` and a scalar multiplication
of `R` on a Type `M` with `0`, such that the equality `r • m = 0` holds if at least one among `r`
or `m` equals `0`. -/
class SmulWithZero [HasZero R] [HasZero M] extends HasScalar R M where 
  smul_zero : ∀ r : R, r • (0 : M) = 0
  zero_smul : ∀ m : M, (0 : R) • m = 0

instance MulZeroClass.toSmulWithZero [MulZeroClass R] : SmulWithZero R R :=
  { smul := ·*·, smul_zero := mul_zero, zero_smul := zero_mul }

/-- Like `mul_zero_class.to_smul_with_zero`, but multiplies on the right. -/
instance MulZeroClass.toOppositeSmulWithZero [MulZeroClass R] : SmulWithZero («expr ᵐᵒᵖ» R) R :=
  { smul := · • ·, smul_zero := fun r => zero_mul _, zero_smul := mul_zero }

instance AddMonoidₓ.toSmulWithZero [AddMonoidₓ M] : SmulWithZero ℕ M :=
  { smul_zero := nsmul_zero, zero_smul := zero_nsmul }

variable (R) {M} [HasZero R] [HasZero M] [SmulWithZero R M]

@[simp]
theorem zero_smul (m : M) : (0 : R) • m = 0 :=
  SmulWithZero.zero_smul m

variable {R} (M)

/-- Note that this lemma has different typeclass assumptions to `smul_zero`. -/
@[simp]
theorem smul_zero' (r : R) : r • (0 : M) = 0 :=
  SmulWithZero.smul_zero r

variable {R M} [HasZero R'] [HasZero M'] [HasScalar R M']

/-- Pullback a `smul_with_zero` structure along an injective zero-preserving homomorphism.
See note [reducible non-instances]. -/
@[reducible]
protected def Function.Injective.smulWithZero (f : ZeroHom M' M) (hf : Function.Injective f)
  (smul : ∀ a : R b, f (a • b) = a • f b) : SmulWithZero R M' :=
  { smul := · • ·,
    zero_smul :=
      fun a =>
        hf$
          by 
            simp [smul],
    smul_zero :=
      fun a =>
        hf$
          by 
            simp [smul] }

/-- Pushforward a `smul_with_zero` structure along a surjective zero-preserving homomorphism.
See note [reducible non-instances]. -/
@[reducible]
protected def Function.Surjective.smulWithZero (f : ZeroHom M M') (hf : Function.Surjective f)
  (smul : ∀ a : R b, f (a • b) = a • f b) : SmulWithZero R M' :=
  { smul := · • ·,
    zero_smul :=
      fun m =>
        by 
          rcases hf m with ⟨x, rfl⟩
          simp [←smul],
    smul_zero :=
      fun c =>
        by 
          simp only [←f.map_zero, ←smul, smul_zero'] }

variable (M)

/-- Compose a `smul_with_zero` with a `zero_hom`, with action `f r' • m` -/
def SmulWithZero.compHom (f : ZeroHom R' R) : SmulWithZero R' M :=
  { smul := (· • ·) ∘ f,
    smul_zero :=
      fun m =>
        by 
          simp ,
    zero_smul :=
      fun m =>
        by 
          simp  }

end HasZero

section MonoidWithZeroₓ

variable [MonoidWithZeroₓ R] [MonoidWithZeroₓ R'] [HasZero M]

variable (R M)

/--  An action of a monoid with zero `R` on a Type `M`, also with `0`, extends `mul_action` and
is compatible with `0` (both in `R` and in `M`), with `1 ∈ R`, and with associativity of
multiplication on the monoid `M`. -/
class MulActionWithZero extends MulAction R M where 
  smul_zero : ∀ r : R, r • (0 : M) = 0
  zero_smul : ∀ m : M, (0 : R) • m = 0

instance (priority := 100) MulActionWithZero.toSmulWithZero [m : MulActionWithZero R M] : SmulWithZero R M :=
  { m with  }

/-- See also `semiring.to_module` -/
instance MonoidWithZeroₓ.toMulActionWithZero : MulActionWithZero R R :=
  { MulZeroClass.toSmulWithZero R, Monoidₓ.toMulAction R with  }

/-- Like `monoid_with_zero.to_mul_action_with_zero`, but multiplies on the right. See also
`semiring.to_opposite_module` -/
instance MonoidWithZeroₓ.toOppositeMulActionWithZero : MulActionWithZero («expr ᵐᵒᵖ» R) R :=
  { MulZeroClass.toOppositeSmulWithZero R, Monoidₓ.toOppositeMulAction R with  }

variable {R M} [MulActionWithZero R M] [HasZero M'] [HasScalar R M']

/-- Pullback a `mul_action_with_zero` structure along an injective zero-preserving homomorphism.
See note [reducible non-instances]. -/
@[reducible]
protected def Function.Injective.mulActionWithZero (f : ZeroHom M' M) (hf : Function.Injective f)
  (smul : ∀ a : R b, f (a • b) = a • f b) : MulActionWithZero R M' :=
  { hf.mul_action f smul, hf.smul_with_zero f smul with  }

/-- Pushforward a `mul_action_with_zero` structure along a surjective zero-preserving homomorphism.
See note [reducible non-instances]. -/
@[reducible]
protected def Function.Surjective.mulActionWithZero (f : ZeroHom M M') (hf : Function.Surjective f)
  (smul : ∀ a : R b, f (a • b) = a • f b) : MulActionWithZero R M' :=
  { hf.mul_action f smul, hf.smul_with_zero f smul with  }

variable (M)

/-- Compose a `mul_action_with_zero` with a `monoid_with_zero_hom`, with action `f r' • m` -/
def MulActionWithZero.compHom (f : MonoidWithZeroHom R' R) : MulActionWithZero R' M :=
  { SmulWithZero.compHom M f.to_zero_hom with smul := (· • ·) ∘ f,
    mul_smul :=
      fun r s m =>
        by 
          simp [mul_smul],
    one_smul :=
      fun m =>
        by 
          simp  }

end MonoidWithZeroₓ

