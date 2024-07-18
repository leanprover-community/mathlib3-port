/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Eric Wieser
-/
import Algebra.Algebra.Defs
import LinearAlgebra.Prod

#align_import algebra.triv_sq_zero_ext from "leanprover-community/mathlib"@"932872382355f00112641d305ba0619305dc8642"

/-!
# Trivial Square-Zero Extension

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Given a ring `R` together with an `(R, R)`-bimodule `M`, the trivial square-zero extension of `M`
over `R` is defined to be the `R`-algebra `R ⊕ M` with multiplication given by
`(r₁ + m₁) * (r₂ + m₂) = r₁ r₂ + r₁ m₂ + m₁ r₂`.

It is a square-zero extension because `M^2 = 0`.

Note that expressing this requires bimodules; we write these in general for a
not-necessarily-commutative `R` as:
```lean
variables {R M : Type*} [semiring R] [add_comm_monoid M]
variables [module R M] [module Rᵐᵒᵖ M] [smul_comm_class R Rᵐᵒᵖ M]
```
If we instead work with a commutative `R'` acting symmetrically on `M`, we write
```lean
variables {R' M : Type*} [comm_semiring R'] [add_comm_monoid M]
variables [module R' M] [module R'ᵐᵒᵖ M] [is_central_scalar R' M]
```
noting that in this context `is_central_scalar R' M` implies `smul_comm_class R' R'ᵐᵒᵖ M`.

Many of the later results in this file are only stated for the commutative `R'` for simplicity.

## Main definitions

* `triv_sq_zero_ext.inl`, `triv_sq_zero_ext.inr`: the canonical inclusions into
  `triv_sq_zero_ext R M`.
* `triv_sq_zero_ext.fst`, `triv_sq_zero_ext.snd`: the canonical projections from
  `triv_sq_zero_ext R M`.
* `triv_sq_zero_ext.algebra`: the associated `R`-algebra structure.
* `triv_sq_zero_ext.lift`: the universal property of the trivial square-zero extension; algebra
  morphisms `triv_sq_zero_ext R M →ₐ[R] A` are uniquely defined by linear maps `M →ₗ[R] A` for
  which the product of any two elements in the range is zero.

-/


universe u v w

#print TrivSqZeroExt /-
/-- "Trivial Square-Zero Extension".

Given a module `M` over a ring `R`, the trivial square-zero extension of `M` over `R` is defined
to be the `R`-algebra `R × M` with multiplication given by
`(r₁ + m₁) * (r₂ + m₂) = r₁ r₂ + r₁ m₂ + r₂ m₁`.

It is a square-zero extension because `M^2 = 0`.
-/
def TrivSqZeroExt (R : Type u) (M : Type v) :=
  R × M
#align triv_sq_zero_ext TrivSqZeroExt
-/

local notation "tsze" => TrivSqZeroExt

open scoped BigOperators

namespace TrivSqZeroExt

open MulOpposite (op)

section Basic

variable {R : Type u} {M : Type v}

#print TrivSqZeroExt.inl /-
/-- The canonical inclusion `R → triv_sq_zero_ext R M`. -/
def inl [Zero M] (r : R) : tsze R M :=
  (r, 0)
#align triv_sq_zero_ext.inl TrivSqZeroExt.inl
-/

#print TrivSqZeroExt.inr /-
/-- The canonical inclusion `M → triv_sq_zero_ext R M`. -/
def inr [Zero R] (m : M) : tsze R M :=
  (0, m)
#align triv_sq_zero_ext.inr TrivSqZeroExt.inr
-/

#print TrivSqZeroExt.fst /-
/-- The canonical projection `triv_sq_zero_ext R M → R`. -/
def fst (x : tsze R M) : R :=
  x.1
#align triv_sq_zero_ext.fst TrivSqZeroExt.fst
-/

#print TrivSqZeroExt.snd /-
/-- The canonical projection `triv_sq_zero_ext R M → M`. -/
def snd (x : tsze R M) : M :=
  x.2
#align triv_sq_zero_ext.snd TrivSqZeroExt.snd
-/

#print TrivSqZeroExt.fst_mk /-
@[simp]
theorem fst_mk (r : R) (m : M) : fst (r, m) = r :=
  rfl
#align triv_sq_zero_ext.fst_mk TrivSqZeroExt.fst_mk
-/

#print TrivSqZeroExt.snd_mk /-
@[simp]
theorem snd_mk (r : R) (m : M) : snd (r, m) = m :=
  rfl
#align triv_sq_zero_ext.snd_mk TrivSqZeroExt.snd_mk
-/

#print TrivSqZeroExt.ext /-
@[ext]
theorem ext {x y : tsze R M} (h1 : x.fst = y.fst) (h2 : x.snd = y.snd) : x = y :=
  Prod.ext h1 h2
#align triv_sq_zero_ext.ext TrivSqZeroExt.ext
-/

section

variable (M)

#print TrivSqZeroExt.fst_inl /-
@[simp]
theorem fst_inl [Zero M] (r : R) : (inl r : tsze R M).fst = r :=
  rfl
#align triv_sq_zero_ext.fst_inl TrivSqZeroExt.fst_inl
-/

#print TrivSqZeroExt.snd_inl /-
@[simp]
theorem snd_inl [Zero M] (r : R) : (inl r : tsze R M).snd = 0 :=
  rfl
#align triv_sq_zero_ext.snd_inl TrivSqZeroExt.snd_inl
-/

#print TrivSqZeroExt.fst_comp_inl /-
@[simp]
theorem fst_comp_inl [Zero M] : fst ∘ (inl : R → tsze R M) = id :=
  rfl
#align triv_sq_zero_ext.fst_comp_inl TrivSqZeroExt.fst_comp_inl
-/

#print TrivSqZeroExt.snd_comp_inl /-
@[simp]
theorem snd_comp_inl [Zero M] : snd ∘ (inl : R → tsze R M) = 0 :=
  rfl
#align triv_sq_zero_ext.snd_comp_inl TrivSqZeroExt.snd_comp_inl
-/

end

section

variable (R)

#print TrivSqZeroExt.fst_inr /-
@[simp]
theorem fst_inr [Zero R] (m : M) : (inr m : tsze R M).fst = 0 :=
  rfl
#align triv_sq_zero_ext.fst_inr TrivSqZeroExt.fst_inr
-/

#print TrivSqZeroExt.snd_inr /-
@[simp]
theorem snd_inr [Zero R] (m : M) : (inr m : tsze R M).snd = m :=
  rfl
#align triv_sq_zero_ext.snd_inr TrivSqZeroExt.snd_inr
-/

#print TrivSqZeroExt.fst_comp_inr /-
@[simp]
theorem fst_comp_inr [Zero R] : fst ∘ (inr : M → tsze R M) = 0 :=
  rfl
#align triv_sq_zero_ext.fst_comp_inr TrivSqZeroExt.fst_comp_inr
-/

#print TrivSqZeroExt.snd_comp_inr /-
@[simp]
theorem snd_comp_inr [Zero R] : snd ∘ (inr : M → tsze R M) = id :=
  rfl
#align triv_sq_zero_ext.snd_comp_inr TrivSqZeroExt.snd_comp_inr
-/

end

#print TrivSqZeroExt.inl_injective /-
theorem inl_injective [Zero M] : Function.Injective (inl : R → tsze R M) :=
  Function.LeftInverse.injective <| fst_inl _
#align triv_sq_zero_ext.inl_injective TrivSqZeroExt.inl_injective
-/

#print TrivSqZeroExt.inr_injective /-
theorem inr_injective [Zero R] : Function.Injective (inr : M → tsze R M) :=
  Function.LeftInverse.injective <| snd_inr _
#align triv_sq_zero_ext.inr_injective TrivSqZeroExt.inr_injective
-/

end Basic

/-! ### Structures inherited from `prod`

Additive operators and scalar multiplication operate elementwise. -/


section Additive

variable {T : Type _} {S : Type _} {R : Type u} {M : Type v}

instance [Inhabited R] [Inhabited M] : Inhabited (tsze R M) :=
  Prod.inhabited

instance [Zero R] [Zero M] : Zero (tsze R M) :=
  Prod.hasZero

instance [Add R] [Add M] : Add (tsze R M) :=
  Prod.hasAdd

instance [Sub R] [Sub M] : Sub (tsze R M) :=
  Prod.hasSub

instance [Neg R] [Neg M] : Neg (tsze R M) :=
  Prod.hasNeg

instance [AddSemigroup R] [AddSemigroup M] : AddSemigroup (tsze R M) :=
  Prod.addSemigroup

instance [AddZeroClass R] [AddZeroClass M] : AddZeroClass (tsze R M) :=
  Prod.addZeroClass

instance [AddMonoid R] [AddMonoid M] : AddMonoid (tsze R M) :=
  Prod.addMonoid

instance [AddGroup R] [AddGroup M] : AddGroup (tsze R M) :=
  Prod.addGroup

instance [AddCommSemigroup R] [AddCommSemigroup M] : AddCommSemigroup (tsze R M) :=
  Prod.addCommSemigroup

instance [AddCommMonoid R] [AddCommMonoid M] : AddCommMonoid (tsze R M) :=
  Prod.addCommMonoid

instance [AddCommGroup R] [AddCommGroup M] : AddCommGroup (tsze R M) :=
  Prod.addCommGroup

instance [SMul S R] [SMul S M] : SMul S (tsze R M) :=
  Prod.smul

instance [SMul T R] [SMul T M] [SMul S R] [SMul S M] [SMul T S] [IsScalarTower T S R]
    [IsScalarTower T S M] : IsScalarTower T S (tsze R M) :=
  Prod.isScalarTower

instance [SMul T R] [SMul T M] [SMul S R] [SMul S M] [SMulCommClass T S R] [SMulCommClass T S M] :
    SMulCommClass T S (tsze R M) :=
  Prod.sMulCommClass

instance [SMul S R] [SMul S M] [SMul Sᵐᵒᵖ R] [SMul Sᵐᵒᵖ M] [IsCentralScalar S R]
    [IsCentralScalar S M] : IsCentralScalar S (tsze R M) :=
  Prod.isCentralScalar

instance [Monoid S] [MulAction S R] [MulAction S M] : MulAction S (tsze R M) :=
  Prod.mulAction

instance [Monoid S] [AddMonoid R] [AddMonoid M] [DistribMulAction S R] [DistribMulAction S M] :
    DistribMulAction S (tsze R M) :=
  Prod.distribMulAction

instance [Semiring S] [AddCommMonoid R] [AddCommMonoid M] [Module S R] [Module S M] :
    Module S (tsze R M) :=
  Prod.instModule

#print TrivSqZeroExt.fst_zero /-
@[simp]
theorem fst_zero [Zero R] [Zero M] : (0 : tsze R M).fst = 0 :=
  rfl
#align triv_sq_zero_ext.fst_zero TrivSqZeroExt.fst_zero
-/

#print TrivSqZeroExt.snd_zero /-
@[simp]
theorem snd_zero [Zero R] [Zero M] : (0 : tsze R M).snd = 0 :=
  rfl
#align triv_sq_zero_ext.snd_zero TrivSqZeroExt.snd_zero
-/

#print TrivSqZeroExt.fst_add /-
@[simp]
theorem fst_add [Add R] [Add M] (x₁ x₂ : tsze R M) : (x₁ + x₂).fst = x₁.fst + x₂.fst :=
  rfl
#align triv_sq_zero_ext.fst_add TrivSqZeroExt.fst_add
-/

#print TrivSqZeroExt.snd_add /-
@[simp]
theorem snd_add [Add R] [Add M] (x₁ x₂ : tsze R M) : (x₁ + x₂).snd = x₁.snd + x₂.snd :=
  rfl
#align triv_sq_zero_ext.snd_add TrivSqZeroExt.snd_add
-/

#print TrivSqZeroExt.fst_neg /-
@[simp]
theorem fst_neg [Neg R] [Neg M] (x : tsze R M) : (-x).fst = -x.fst :=
  rfl
#align triv_sq_zero_ext.fst_neg TrivSqZeroExt.fst_neg
-/

#print TrivSqZeroExt.snd_neg /-
@[simp]
theorem snd_neg [Neg R] [Neg M] (x : tsze R M) : (-x).snd = -x.snd :=
  rfl
#align triv_sq_zero_ext.snd_neg TrivSqZeroExt.snd_neg
-/

#print TrivSqZeroExt.fst_sub /-
@[simp]
theorem fst_sub [Sub R] [Sub M] (x₁ x₂ : tsze R M) : (x₁ - x₂).fst = x₁.fst - x₂.fst :=
  rfl
#align triv_sq_zero_ext.fst_sub TrivSqZeroExt.fst_sub
-/

#print TrivSqZeroExt.snd_sub /-
@[simp]
theorem snd_sub [Sub R] [Sub M] (x₁ x₂ : tsze R M) : (x₁ - x₂).snd = x₁.snd - x₂.snd :=
  rfl
#align triv_sq_zero_ext.snd_sub TrivSqZeroExt.snd_sub
-/

#print TrivSqZeroExt.fst_smul /-
@[simp]
theorem fst_smul [SMul S R] [SMul S M] (s : S) (x : tsze R M) : (s • x).fst = s • x.fst :=
  rfl
#align triv_sq_zero_ext.fst_smul TrivSqZeroExt.fst_smul
-/

#print TrivSqZeroExt.snd_smul /-
@[simp]
theorem snd_smul [SMul S R] [SMul S M] (s : S) (x : tsze R M) : (s • x).snd = s • x.snd :=
  rfl
#align triv_sq_zero_ext.snd_smul TrivSqZeroExt.snd_smul
-/

#print TrivSqZeroExt.fst_sum /-
theorem fst_sum {ι} [AddCommMonoid R] [AddCommMonoid M] (s : Finset ι) (f : ι → tsze R M) :
    (∑ i in s, f i).fst = ∑ i in s, (f i).fst :=
  Prod.fst_sum
#align triv_sq_zero_ext.fst_sum TrivSqZeroExt.fst_sum
-/

#print TrivSqZeroExt.snd_sum /-
theorem snd_sum {ι} [AddCommMonoid R] [AddCommMonoid M] (s : Finset ι) (f : ι → tsze R M) :
    (∑ i in s, f i).snd = ∑ i in s, (f i).snd :=
  Prod.snd_sum
#align triv_sq_zero_ext.snd_sum TrivSqZeroExt.snd_sum
-/

section

variable (M)

#print TrivSqZeroExt.inl_zero /-
@[simp]
theorem inl_zero [Zero R] [Zero M] : (inl 0 : tsze R M) = 0 :=
  rfl
#align triv_sq_zero_ext.inl_zero TrivSqZeroExt.inl_zero
-/

#print TrivSqZeroExt.inl_add /-
@[simp]
theorem inl_add [Add R] [AddZeroClass M] (r₁ r₂ : R) :
    (inl (r₁ + r₂) : tsze R M) = inl r₁ + inl r₂ :=
  ext rfl (add_zero 0).symm
#align triv_sq_zero_ext.inl_add TrivSqZeroExt.inl_add
-/

#print TrivSqZeroExt.inl_neg /-
@[simp]
theorem inl_neg [Neg R] [SubNegZeroMonoid M] (r : R) : (inl (-r) : tsze R M) = -inl r :=
  ext rfl neg_zero.symm
#align triv_sq_zero_ext.inl_neg TrivSqZeroExt.inl_neg
-/

#print TrivSqZeroExt.inl_sub /-
@[simp]
theorem inl_sub [Sub R] [SubNegZeroMonoid M] (r₁ r₂ : R) :
    (inl (r₁ - r₂) : tsze R M) = inl r₁ - inl r₂ :=
  ext rfl (sub_zero _).symm
#align triv_sq_zero_ext.inl_sub TrivSqZeroExt.inl_sub
-/

#print TrivSqZeroExt.inl_smul /-
@[simp]
theorem inl_smul [Monoid S] [AddMonoid M] [SMul S R] [DistribMulAction S M] (s : S) (r : R) :
    (inl (s • r) : tsze R M) = s • inl r :=
  ext rfl (smul_zero s).symm
#align triv_sq_zero_ext.inl_smul TrivSqZeroExt.inl_smul
-/

#print TrivSqZeroExt.inl_sum /-
theorem inl_sum {ι} [AddCommMonoid R] [AddCommMonoid M] (s : Finset ι) (f : ι → R) :
    (inl (∑ i in s, f i) : tsze R M) = ∑ i in s, inl (f i) :=
  (LinearMap.inl ℕ _ _).map_sum
#align triv_sq_zero_ext.inl_sum TrivSqZeroExt.inl_sum
-/

end

section

variable (R)

#print TrivSqZeroExt.inr_zero /-
@[simp]
theorem inr_zero [Zero R] [Zero M] : (inr 0 : tsze R M) = 0 :=
  rfl
#align triv_sq_zero_ext.inr_zero TrivSqZeroExt.inr_zero
-/

#print TrivSqZeroExt.inr_add /-
@[simp]
theorem inr_add [AddZeroClass R] [AddZeroClass M] (m₁ m₂ : M) :
    (inr (m₁ + m₂) : tsze R M) = inr m₁ + inr m₂ :=
  ext (add_zero 0).symm rfl
#align triv_sq_zero_ext.inr_add TrivSqZeroExt.inr_add
-/

#print TrivSqZeroExt.inr_neg /-
@[simp]
theorem inr_neg [SubNegZeroMonoid R] [Neg M] (m : M) : (inr (-m) : tsze R M) = -inr m :=
  ext neg_zero.symm rfl
#align triv_sq_zero_ext.inr_neg TrivSqZeroExt.inr_neg
-/

#print TrivSqZeroExt.inr_sub /-
@[simp]
theorem inr_sub [SubNegZeroMonoid R] [Sub M] (m₁ m₂ : M) :
    (inr (m₁ - m₂) : tsze R M) = inr m₁ - inr m₂ :=
  ext (sub_zero _).symm rfl
#align triv_sq_zero_ext.inr_sub TrivSqZeroExt.inr_sub
-/

#print TrivSqZeroExt.inr_smul /-
@[simp]
theorem inr_smul [Zero R] [Zero S] [SMulWithZero S R] [SMul S M] (r : S) (m : M) :
    (inr (r • m) : tsze R M) = r • inr m :=
  ext (smul_zero _).symm rfl
#align triv_sq_zero_ext.inr_smul TrivSqZeroExt.inr_smul
-/

#print TrivSqZeroExt.inr_sum /-
theorem inr_sum {ι} [AddCommMonoid R] [AddCommMonoid M] (s : Finset ι) (f : ι → M) :
    (inr (∑ i in s, f i) : tsze R M) = ∑ i in s, inr (f i) :=
  (LinearMap.inr ℕ _ _).map_sum
#align triv_sq_zero_ext.inr_sum TrivSqZeroExt.inr_sum
-/

end

#print TrivSqZeroExt.inl_fst_add_inr_snd_eq /-
theorem inl_fst_add_inr_snd_eq [AddZeroClass R] [AddZeroClass M] (x : tsze R M) :
    inl x.fst + inr x.snd = x :=
  ext (add_zero x.1) (zero_add x.2)
#align triv_sq_zero_ext.inl_fst_add_inr_snd_eq TrivSqZeroExt.inl_fst_add_inr_snd_eq
-/

#print TrivSqZeroExt.ind /-
/-- To show a property hold on all `triv_sq_zero_ext R M` it suffices to show it holds
on terms of the form `inl r + inr m`.

This can be used as `induction x using triv_sq_zero_ext.ind`. -/
theorem ind {R M} [AddZeroClass R] [AddZeroClass M] {P : TrivSqZeroExt R M → Prop}
    (h : ∀ r m, P (inl r + inr m)) (x) : P x :=
  inl_fst_add_inr_snd_eq x ▸ h x.1 x.2
#align triv_sq_zero_ext.ind TrivSqZeroExt.ind
-/

#print TrivSqZeroExt.linearMap_ext /-
/-- This cannot be marked `@[ext]` as it ends up being used instead of `linear_map.prod_ext` when
working with `R × M`. -/
theorem linearMap_ext {N} [Semiring S] [AddCommMonoid R] [AddCommMonoid M] [AddCommMonoid N]
    [Module S R] [Module S M] [Module S N] ⦃f g : tsze R M →ₗ[S] N⦄
    (hl : ∀ r, f (inl r) = g (inl r)) (hr : ∀ m, f (inr m) = g (inr m)) : f = g :=
  LinearMap.prod_ext (LinearMap.ext hl) (LinearMap.ext hr)
#align triv_sq_zero_ext.linear_map_ext TrivSqZeroExt.linearMap_ext
-/

variable (R M)

#print TrivSqZeroExt.inrHom /-
/-- The canonical `R`-linear inclusion `M → triv_sq_zero_ext R M`. -/
@[simps apply]
def inrHom [Semiring R] [AddCommMonoid M] [Module R M] : M →ₗ[R] tsze R M :=
  { LinearMap.inr R R M with toFun := inr }
#align triv_sq_zero_ext.inr_hom TrivSqZeroExt.inrHom
-/

#print TrivSqZeroExt.sndHom /-
/-- The canonical `R`-linear projection `triv_sq_zero_ext R M → M`. -/
@[simps apply]
def sndHom [Semiring R] [AddCommMonoid M] [Module R M] : tsze R M →ₗ[R] M :=
  { LinearMap.snd _ _ _ with toFun := snd }
#align triv_sq_zero_ext.snd_hom TrivSqZeroExt.sndHom
-/

end Additive

/-! ### Multiplicative structure -/


section Mul

variable {R : Type u} {M : Type v}

instance [One R] [Zero M] : One (tsze R M) :=
  ⟨(1, 0)⟩

instance [Mul R] [Add M] [SMul R M] [SMul Rᵐᵒᵖ M] : Mul (tsze R M) :=
  ⟨fun x y => (x.1 * y.1, x.1 • y.2 + op y.1 • x.2)⟩

#print TrivSqZeroExt.fst_one /-
@[simp]
theorem fst_one [One R] [Zero M] : (1 : tsze R M).fst = 1 :=
  rfl
#align triv_sq_zero_ext.fst_one TrivSqZeroExt.fst_one
-/

#print TrivSqZeroExt.snd_one /-
@[simp]
theorem snd_one [One R] [Zero M] : (1 : tsze R M).snd = 0 :=
  rfl
#align triv_sq_zero_ext.snd_one TrivSqZeroExt.snd_one
-/

#print TrivSqZeroExt.fst_mul /-
@[simp]
theorem fst_mul [Mul R] [Add M] [SMul R M] [SMul Rᵐᵒᵖ M] (x₁ x₂ : tsze R M) :
    (x₁ * x₂).fst = x₁.fst * x₂.fst :=
  rfl
#align triv_sq_zero_ext.fst_mul TrivSqZeroExt.fst_mul
-/

#print TrivSqZeroExt.snd_mul /-
@[simp]
theorem snd_mul [Mul R] [Add M] [SMul R M] [SMul Rᵐᵒᵖ M] (x₁ x₂ : tsze R M) :
    (x₁ * x₂).snd = x₁.fst • x₂.snd + op x₂.fst • x₁.snd :=
  rfl
#align triv_sq_zero_ext.snd_mul TrivSqZeroExt.snd_mul
-/

section

variable (M)

#print TrivSqZeroExt.inl_one /-
@[simp]
theorem inl_one [One R] [Zero M] : (inl 1 : tsze R M) = 1 :=
  rfl
#align triv_sq_zero_ext.inl_one TrivSqZeroExt.inl_one
-/

#print TrivSqZeroExt.inl_mul /-
@[simp]
theorem inl_mul [Monoid R] [AddMonoid M] [DistribMulAction R M] [DistribMulAction Rᵐᵒᵖ M]
    (r₁ r₂ : R) : (inl (r₁ * r₂) : tsze R M) = inl r₁ * inl r₂ :=
  ext rfl <| show (0 : M) = r₁ • 0 + op r₂ • 0 by rw [smul_zero, zero_add, smul_zero]
#align triv_sq_zero_ext.inl_mul TrivSqZeroExt.inl_mul
-/

#print TrivSqZeroExt.inl_mul_inl /-
theorem inl_mul_inl [Monoid R] [AddMonoid M] [DistribMulAction R M] [DistribMulAction Rᵐᵒᵖ M]
    (r₁ r₂ : R) : (inl r₁ * inl r₂ : tsze R M) = inl (r₁ * r₂) :=
  (inl_mul M r₁ r₂).symm
#align triv_sq_zero_ext.inl_mul_inl TrivSqZeroExt.inl_mul_inl
-/

end

section

variable (R)

#print TrivSqZeroExt.inr_mul_inr /-
@[simp]
theorem inr_mul_inr [Semiring R] [AddCommMonoid M] [Module R M] [Module Rᵐᵒᵖ M] (m₁ m₂ : M) :
    (inr m₁ * inr m₂ : tsze R M) = 0 :=
  ext (MulZeroClass.mul_zero _) <|
    show (0 : R) • m₂ + (0 : Rᵐᵒᵖ) • m₁ = 0 by rw [zero_smul, zero_add, zero_smul]
#align triv_sq_zero_ext.inr_mul_inr TrivSqZeroExt.inr_mul_inr
-/

end

#print TrivSqZeroExt.inl_mul_inr /-
theorem inl_mul_inr [Semiring R] [AddCommMonoid M] [Module R M] [Module Rᵐᵒᵖ M] (r : R) (m : M) :
    (inl r * inr m : tsze R M) = inr (r • m) :=
  ext (MulZeroClass.mul_zero r) <| show r • m + (0 : Rᵐᵒᵖ) • 0 = r • m by rw [smul_zero, add_zero]
#align triv_sq_zero_ext.inl_mul_inr TrivSqZeroExt.inl_mul_inr
-/

#print TrivSqZeroExt.inr_mul_inl /-
theorem inr_mul_inl [Semiring R] [AddCommMonoid M] [Module R M] [Module Rᵐᵒᵖ M] (r : R) (m : M) :
    (inr m * inl r : tsze R M) = inr (op r • m) :=
  ext (MulZeroClass.zero_mul r) <|
    show (0 : R) • 0 + op r • m = op r • m by rw [smul_zero, zero_add]
#align triv_sq_zero_ext.inr_mul_inl TrivSqZeroExt.inr_mul_inl
-/

instance [Monoid R] [AddMonoid M] [DistribMulAction R M] [DistribMulAction Rᵐᵒᵖ M] :
    MulOneClass (tsze R M) :=
  { TrivSqZeroExt.hasOne,
    TrivSqZeroExt.hasMul with
    one_mul := fun x =>
      ext (one_mul x.1) <|
        show (1 : R) • x.2 + op x.1 • 0 = x.2 by rw [one_smul, smul_zero, add_zero]
    mul_one := fun x =>
      ext (mul_one x.1) <|
        show (x.1 • 0 : M) + (1 : Rᵐᵒᵖ) • x.2 = x.2 by rw [smul_zero, zero_add, one_smul] }

instance [AddMonoidWithOne R] [AddMonoid M] : AddMonoidWithOne (tsze R M) :=
  { TrivSqZeroExt.addMonoid,
    TrivSqZeroExt.hasOne with
    natCast := fun n => inl n
    natCast_zero := by simp [Nat.cast]
    natCast_succ := fun _ => by ext <;> simp [Nat.cast] }

#print TrivSqZeroExt.fst_natCast /-
@[simp]
theorem fst_natCast [AddMonoidWithOne R] [AddMonoid M] (n : ℕ) : (n : tsze R M).fst = n :=
  rfl
#align triv_sq_zero_ext.fst_nat_cast TrivSqZeroExt.fst_natCast
-/

#print TrivSqZeroExt.snd_natCast /-
@[simp]
theorem snd_natCast [AddMonoidWithOne R] [AddMonoid M] (n : ℕ) : (n : tsze R M).snd = 0 :=
  rfl
#align triv_sq_zero_ext.snd_nat_cast TrivSqZeroExt.snd_natCast
-/

#print TrivSqZeroExt.inl_natCast /-
@[simp]
theorem inl_natCast [AddMonoidWithOne R] [AddMonoid M] (n : ℕ) : (inl n : tsze R M) = n :=
  rfl
#align triv_sq_zero_ext.inl_nat_cast TrivSqZeroExt.inl_natCast
-/

instance [AddGroupWithOne R] [AddGroup M] : AddGroupWithOne (tsze R M) :=
  { TrivSqZeroExt.addGroup,
    TrivSqZeroExt.addMonoidWithOne with
    intCast := fun z => inl z
    intCast_ofNat := fun n => ext (Int.cast_natCast _) rfl
    intCast_negSucc := fun n => ext (Int.cast_negSucc _) neg_zero.symm }

#print TrivSqZeroExt.fst_intCast /-
@[simp]
theorem fst_intCast [AddGroupWithOne R] [AddGroup M] (z : ℤ) : (z : tsze R M).fst = z :=
  rfl
#align triv_sq_zero_ext.fst_int_cast TrivSqZeroExt.fst_intCast
-/

#print TrivSqZeroExt.snd_intCast /-
@[simp]
theorem snd_intCast [AddGroupWithOne R] [AddGroup M] (z : ℤ) : (z : tsze R M).snd = 0 :=
  rfl
#align triv_sq_zero_ext.snd_int_cast TrivSqZeroExt.snd_intCast
-/

#print TrivSqZeroExt.inl_intCast /-
@[simp]
theorem inl_intCast [AddGroupWithOne R] [AddGroup M] (z : ℤ) : (inl z : tsze R M) = z :=
  rfl
#align triv_sq_zero_ext.inl_int_cast TrivSqZeroExt.inl_intCast
-/

instance [Semiring R] [AddCommMonoid M] [Module R M] [Module Rᵐᵒᵖ M] :
    NonAssocSemiring (tsze R M) :=
  { TrivSqZeroExt.addMonoidWithOne, TrivSqZeroExt.mulOneClass,
    TrivSqZeroExt.addCommMonoid with
    zero_mul := fun x =>
      ext (MulZeroClass.zero_mul x.1) <|
        show (0 : R) • x.2 + op x.1 • 0 = 0 by rw [zero_smul, zero_add, smul_zero]
    mul_zero := fun x =>
      ext (MulZeroClass.mul_zero x.1) <|
        show (x.1 • 0 : M) + (0 : Rᵐᵒᵖ) • x.2 = 0 by rw [smul_zero, zero_add, zero_smul]
    left_distrib := fun x₁ x₂ x₃ =>
      ext (mul_add x₁.1 x₂.1 x₃.1) <|
        show
          x₁.1 • (x₂.2 + x₃.2) + (op x₂.1 + op x₃.1) • x₁.2 =
            x₁.1 • x₂.2 + op x₂.1 • x₁.2 + (x₁.1 • x₃.2 + op x₃.1 • x₁.2)
          by simp_rw [smul_add, add_smul, add_add_add_comm]
    right_distrib := fun x₁ x₂ x₃ =>
      ext (add_mul x₁.1 x₂.1 x₃.1) <|
        show
          (x₁.1 + x₂.1) • x₃.2 + op x₃.1 • (x₁.2 + x₂.2) =
            x₁.1 • x₃.2 + op x₃.1 • x₁.2 + (x₂.1 • x₃.2 + op x₃.1 • x₂.2)
          by simp_rw [add_smul, smul_add, add_add_add_comm] }

instance [Ring R] [AddCommGroup M] [Module R M] [Module Rᵐᵒᵖ M] : NonAssocRing (tsze R M) :=
  { TrivSqZeroExt.addGroupWithOne, TrivSqZeroExt.nonAssocSemiring with }

/-- In the general non-commutative case, the power operator is

$$\begin{align}
(r + m)^n &= r^n + r^{n-1}m + r^{n-2}mr + \cdots + rmr^{n-2} + mr^{n-1} \\
          & =r^n + \sum_{i = 0}^{n - 1} r^{(n - 1) - i} m r^{i}
\end{align}$$

In the commutative case this becomes the simpler $(r + m)^n = r^n + nr^{n-1}m$.
-/
instance [Monoid R] [AddMonoid M] [DistribMulAction R M] [DistribMulAction Rᵐᵒᵖ M] :
    Pow (tsze R M) ℕ :=
  ⟨fun x n =>
    ⟨x.fst ^ n, ((List.range n).map fun i => x.fst ^ (n.pred - i) • op (x.fst ^ i) • x.snd).Sum⟩⟩

#print TrivSqZeroExt.fst_pow /-
@[simp]
theorem fst_pow [Monoid R] [AddMonoid M] [DistribMulAction R M] [DistribMulAction Rᵐᵒᵖ M]
    (x : tsze R M) (n : ℕ) : fst (x ^ n) = x.fst ^ n :=
  rfl
#align triv_sq_zero_ext.fst_pow TrivSqZeroExt.fst_pow
-/

#print TrivSqZeroExt.snd_pow_eq_sum /-
theorem snd_pow_eq_sum [Monoid R] [AddMonoid M] [DistribMulAction R M] [DistribMulAction Rᵐᵒᵖ M]
    (x : tsze R M) (n : ℕ) :
    snd (x ^ n) = ((List.range n).map fun i => x.fst ^ (n.pred - i) • op (x.fst ^ i) • x.snd).Sum :=
  rfl
#align triv_sq_zero_ext.snd_pow_eq_sum TrivSqZeroExt.snd_pow_eq_sum
-/

#print TrivSqZeroExt.snd_pow_of_smul_comm /-
theorem snd_pow_of_smul_comm [Monoid R] [AddMonoid M] [DistribMulAction R M]
    [DistribMulAction Rᵐᵒᵖ M] [SMulCommClass R Rᵐᵒᵖ M] (x : tsze R M) (n : ℕ)
    (h : op x.fst • x.snd = x.fst • x.snd) : snd (x ^ n) = n • x.fst ^ n.pred • x.snd :=
  by
  have : ∀ n : ℕ, op (x.fst ^ n) • x.snd = x.fst ^ n • x.snd :=
    by
    intro n
    induction' n with n ih
    · simp
    ·
      rw [pow_succ, MulOpposite.op_mul, mul_smul, mul_smul, ← h, smul_comm (_ : R) (op x.fst) x.snd,
        ih]
  simp_rw [snd_pow_eq_sum, this, smul_smul, ← pow_add]
  cases n
  · rw [Nat.pred_zero, pow_zero, List.range_zero, zero_smul, List.map_nil, List.sum_nil]
  simp_rw [Nat.pred_succ]
  refine' (List.sum_eq_card_nsmul _ (x.fst ^ n • x.snd) _).trans _
  · rintro m hm
    simp_rw [List.mem_map, List.mem_range] at hm
    obtain ⟨i, hi, rfl⟩ := hm
    rw [tsub_add_cancel_of_le (nat.lt_succ_iff.mp hi)]
  · rw [List.length_map, List.length_range]
#align triv_sq_zero_ext.snd_pow_of_smul_comm TrivSqZeroExt.snd_pow_of_smul_comm
-/

#print TrivSqZeroExt.snd_pow /-
@[simp]
theorem snd_pow [CommMonoid R] [AddMonoid M] [DistribMulAction R M] [DistribMulAction Rᵐᵒᵖ M]
    [IsCentralScalar R M] (x : tsze R M) (n : ℕ) : snd (x ^ n) = n • x.fst ^ n.pred • x.snd :=
  snd_pow_of_smul_comm _ _ (op_smul_eq_smul _ _)
#align triv_sq_zero_ext.snd_pow TrivSqZeroExt.snd_pow
-/

#print TrivSqZeroExt.inl_pow /-
@[simp]
theorem inl_pow [Monoid R] [AddMonoid M] [DistribMulAction R M] [DistribMulAction Rᵐᵒᵖ M] (r : R)
    (n : ℕ) : (inl r ^ n : tsze R M) = inl (r ^ n) :=
  ext rfl <| by simp [snd_pow_eq_sum]
#align triv_sq_zero_ext.inl_pow TrivSqZeroExt.inl_pow
-/

instance [Monoid R] [AddMonoid M] [DistribMulAction R M] [DistribMulAction Rᵐᵒᵖ M]
    [SMulCommClass R Rᵐᵒᵖ M] : Monoid (tsze R M) :=
  {
    TrivSqZeroExt.mulOneClass with
    mul_assoc := fun x y z =>
      ext (mul_assoc x.1 y.1 z.1) <|
        show
          (x.1 * y.1) • z.2 + op z.1 • (x.1 • y.2 + op y.1 • x.2) =
            x.1 • (y.1 • z.2 + op z.1 • y.2) + (op z.1 * op y.1) • x.2
          by simp_rw [smul_add, ← mul_smul, add_assoc, smul_comm]
    npow := fun n x => x ^ n
    npow_zero := fun x => ext (pow_zero x.fst) (by simp [snd_pow_eq_sum])
    npow_succ := fun n x =>
      ext (pow_succ' _ _)
        (by
          simp_rw [snd_mul, snd_pow_eq_sum, Nat.pred_succ]
          cases n
          · simp [List.range_succ]
          simp_rw [Nat.pred_succ]
          rw [List.range_succ, List.map_append, List.sum_append, List.map_singleton,
            List.sum_singleton, Nat.sub_self, pow_zero, one_smul, List.smul_sum, List.map_map,
            Function.comp, fst_pow]
          simp_rw [smul_smul, ← pow_succ', Nat.succ_eq_add_one]
          congr 2
          refine' List.map_congr_left fun i hi => _
          rw [List.mem_range, Nat.lt_succ_iff] at hi
          rw [Nat.sub_add_comm hi]) }

#print TrivSqZeroExt.fst_list_prod /-
theorem fst_list_prod [Monoid R] [AddMonoid M] [DistribMulAction R M] [DistribMulAction Rᵐᵒᵖ M]
    [SMulCommClass R Rᵐᵒᵖ M] (l : List (tsze R M)) : l.Prod.fst = (l.map fst).Prod :=
  map_list_prod (⟨fst, fst_one, fst_mul⟩ : tsze R M →* R) _
#align triv_sq_zero_ext.fst_list_prod TrivSqZeroExt.fst_list_prod
-/

instance [Semiring R] [AddCommMonoid M] [Module R M] [Module Rᵐᵒᵖ M] [SMulCommClass R Rᵐᵒᵖ M] :
    Semiring (tsze R M) :=
  { TrivSqZeroExt.monoid, TrivSqZeroExt.nonAssocSemiring with }

#print TrivSqZeroExt.snd_list_prod /-
/-- The second element of a product $\prod_{i=0}^n (r_i + m_i)$ is a sum of terms of the form
$r_0\cdots r_{i-1}m_ir_{i+1}\cdots r_n$. -/
theorem snd_list_prod [Semiring R] [AddCommMonoid M] [Module R M] [Module Rᵐᵒᵖ M]
    [SMulCommClass R Rᵐᵒᵖ M] (l : List (tsze R M)) :
    l.Prod.snd =
      (l.enum.map fun x : ℕ × tsze R M =>
          ((l.map fst).take x.1).Prod • op ((l.map fst).drop x.1.succ).Prod • x.snd.snd).Sum :=
  by
  induction' l with x xs ih
  · simp
  · rw [List.enum_cons, ← List.map_fst_add_enum_eq_enumFrom]
    simp_rw [List.map_cons, List.map_map, Function.comp, Prod.map_snd, Prod.map_fst, id,
      List.take_zero, List.take_cons, List.prod_nil, List.prod_cons, snd_mul, one_smul, List.drop,
      mul_smul, List.sum_cons, fst_list_prod, ih, List.smul_sum, List.map_map]
    exact add_comm _ _
#align triv_sq_zero_ext.snd_list_prod TrivSqZeroExt.snd_list_prod
-/

instance [Ring R] [AddCommGroup M] [Module R M] [Module Rᵐᵒᵖ M] [SMulCommClass R Rᵐᵒᵖ M] :
    Ring (tsze R M) :=
  { TrivSqZeroExt.semiring, TrivSqZeroExt.nonAssocRing with }

instance [CommMonoid R] [AddCommMonoid M] [DistribMulAction R M] [DistribMulAction Rᵐᵒᵖ M]
    [IsCentralScalar R M] : CommMonoid (tsze R M) :=
  { TrivSqZeroExt.monoid with
    mul_comm := fun x₁ x₂ =>
      ext (mul_comm x₁.1 x₂.1) <|
        show x₁.1 • x₂.2 + op x₂.1 • x₁.2 = x₂.1 • x₁.2 + op x₁.1 • x₂.2 by
          rw [op_smul_eq_smul, op_smul_eq_smul, add_comm] }

instance [CommSemiring R] [AddCommMonoid M] [Module R M] [Module Rᵐᵒᵖ M] [IsCentralScalar R M] :
    CommSemiring (tsze R M) :=
  { TrivSqZeroExt.commMonoid, TrivSqZeroExt.nonAssocSemiring with }

instance [CommRing R] [AddCommGroup M] [Module R M] [Module Rᵐᵒᵖ M] [IsCentralScalar R M] :
    CommRing (tsze R M) :=
  { TrivSqZeroExt.nonAssocRing, TrivSqZeroExt.commSemiring with }

variable (R M)

#print TrivSqZeroExt.inlHom /-
/-- The canonical inclusion of rings `R → triv_sq_zero_ext R M`. -/
@[simps apply]
def inlHom [Semiring R] [AddCommMonoid M] [Module R M] [Module Rᵐᵒᵖ M] : R →+* tsze R M
    where
  toFun := inl
  map_one' := inl_one M
  map_mul' := inl_mul M
  map_zero' := inl_zero M
  map_add' := inl_add M
#align triv_sq_zero_ext.inl_hom TrivSqZeroExt.inlHom
-/

end Mul

section Algebra

variable (S : Type _) (R R' : Type u) (M : Type v)

variable [CommSemiring S] [Semiring R] [CommSemiring R'] [AddCommMonoid M]

variable [Algebra S R] [Algebra S R'] [Module S M]

variable [Module R M] [Module Rᵐᵒᵖ M] [SMulCommClass R Rᵐᵒᵖ M]

variable [IsScalarTower S R M] [IsScalarTower S Rᵐᵒᵖ M]

variable [Module R' M] [Module R'ᵐᵒᵖ M] [IsCentralScalar R' M] [IsScalarTower S R' M]

#print TrivSqZeroExt.algebra' /-
instance algebra' : Algebra S (tsze R M) :=
  {
    (TrivSqZeroExt.inlHom R M).comp
      (algebraMap S R) with
    smul := (· • ·)
    commutes' := fun s x =>
      ext (Algebra.commutes _ _) <|
        show algebraMap S R s • x.snd + op x.fst • 0 = x.fst • 0 + op (algebraMap S R s) • x.snd
          by
          rw [smul_zero, smul_zero, add_zero, zero_add]
          rw [Algebra.algebraMap_eq_smul_one, MulOpposite.op_smul, MulOpposite.op_one, smul_assoc,
            one_smul, smul_assoc, one_smul]
    smul_def' := fun r x =>
      ext (Algebra.smul_def _ _) <|
        show r • x.2 = algebraMap S R r • x.2 + op x.1 • 0 by
          rw [smul_zero, add_zero, algebraMap_smul] }
#align triv_sq_zero_ext.algebra' TrivSqZeroExt.algebra'
-/

-- shortcut instance for the common case
instance : Algebra R' (tsze R' M) :=
  TrivSqZeroExt.algebra' _ _ _

#print TrivSqZeroExt.algebraMap_eq_inl /-
theorem algebraMap_eq_inl : ⇑(algebraMap R' (tsze R' M)) = inl :=
  rfl
#align triv_sq_zero_ext.algebra_map_eq_inl TrivSqZeroExt.algebraMap_eq_inl
-/

#print TrivSqZeroExt.algebraMap_eq_inlHom /-
theorem algebraMap_eq_inlHom : algebraMap R' (tsze R' M) = inlHom R' M :=
  rfl
#align triv_sq_zero_ext.algebra_map_eq_inl_hom TrivSqZeroExt.algebraMap_eq_inlHom
-/

#print TrivSqZeroExt.algebraMap_eq_inl' /-
theorem algebraMap_eq_inl' (s : S) : algebraMap S (tsze R M) s = inl (algebraMap S R s) :=
  rfl
#align triv_sq_zero_ext.algebra_map_eq_inl' TrivSqZeroExt.algebraMap_eq_inl'
-/

#print TrivSqZeroExt.fstHom /-
/-- The canonical `R`-algebra projection `triv_sq_zero_ext R M → R`. -/
@[simps]
def fstHom : tsze R M →ₐ[S] R where
  toFun := fst
  map_one' := fst_one
  map_mul' := fst_mul
  map_zero' := fst_zero
  map_add' := fst_add
  commutes' r := fst_inl M _
#align triv_sq_zero_ext.fst_hom TrivSqZeroExt.fstHom
-/

variable {R R' S M}

#print TrivSqZeroExt.algHom_ext /-
theorem algHom_ext {A} [Semiring A] [Algebra R' A] ⦃f g : tsze R' M →ₐ[R'] A⦄
    (h : ∀ m, f (inr m) = g (inr m)) : f = g :=
  AlgHom.toLinearMap_injective <|
    linearMap_ext (fun r => (f.commutes _).trans (g.commutes _).symm) h
#align triv_sq_zero_ext.alg_hom_ext TrivSqZeroExt.algHom_ext
-/

#print TrivSqZeroExt.algHom_ext' /-
@[ext]
theorem algHom_ext' {A} [Semiring A] [Algebra R' A] ⦃f g : tsze R' M →ₐ[R'] A⦄
    (h : f.toLinearMap.comp (inrHom R' M) = g.toLinearMap.comp (inrHom R' M)) : f = g :=
  algHom_ext <| LinearMap.congr_fun h
#align triv_sq_zero_ext.alg_hom_ext' TrivSqZeroExt.algHom_ext'
-/

variable {A : Type _} [Semiring A] [Algebra R' A]

#print TrivSqZeroExt.lift /-
/-- There is an alg_hom from the trivial square zero extension to any `R`-algebra with a submodule
whose products are all zero.

See `triv_sq_zero_ext.lift` for this as an equiv. -/
def lift (f : M →ₗ[R'] A) (hf : ∀ x y, f x * f y = 0) : tsze R' M →ₐ[R'] A :=
  AlgHom.ofLinearMap
    ((Algebra.linearMap _ _).comp (fstHom R' R' M).toLinearMap + f.comp (sndHom R' M))
    (show algebraMap R' _ 1 + f (0 : M) = 1 by rw [map_zero, map_one, add_zero])
    (TrivSqZeroExt.ind fun r₁ m₁ =>
      TrivSqZeroExt.ind fun r₂ m₂ => by
        dsimp
        simp only [add_zero, zero_add, add_mul, mul_add, smul_mul_smul, hf, smul_zero,
          op_smul_eq_smul]
        rw [← RingHom.map_mul, LinearMap.map_add, ← Algebra.commutes _ (f _), ← Algebra.smul_def, ←
          Algebra.smul_def, add_right_comm, add_assoc, LinearMap.map_smul, LinearMap.map_smul])
#align triv_sq_zero_ext.lift_aux TrivSqZeroExt.lift
-/

#print TrivSqZeroExt.lift_apply_inr /-
@[simp]
theorem lift_apply_inr (f : M →ₗ[R'] A) (hf : ∀ x y, f x * f y = 0) (m : M) :
    lift f hf (inr m) = f m :=
  show algebraMap R' A 0 + f m = f m by rw [RingHom.map_zero, zero_add]
#align triv_sq_zero_ext.lift_aux_apply_inr TrivSqZeroExt.lift_apply_inr
-/

#print TrivSqZeroExt.lift_comp_inrHom /-
@[simp]
theorem lift_comp_inrHom (f : M →ₗ[R'] A) (hf : ∀ x y, f x * f y = 0) :
    (lift f hf).toLinearMap.comp (inrHom R' M) = f :=
  LinearMap.ext <| lift_apply_inr f hf
#align triv_sq_zero_ext.lift_aux_comp_inr_hom TrivSqZeroExt.lift_comp_inrHom
-/

-- When applied to `inr` itself, `lift_aux` is the identity.
@[simp]
theorem lift_inlAlgHom_inrHom : lift (inrHom R' M) (inr_mul_inr R') = AlgHom.id R' (tsze R' M) :=
  algHom_ext' <| lift_comp_inrHom _ _
#align triv_sq_zero_ext.lift_aux_inr_hom TrivSqZeroExt.lift_inlAlgHom_inrHomₓ

#print TrivSqZeroExt.liftEquiv /-
/-- A universal property of the trivial square-zero extension, providing a unique
`triv_sq_zero_ext R M →ₐ[R] A` for every linear map `M →ₗ[R] A` whose range has no non-zero
products.

This isomorphism is named to match the very similar `complex.lift`. -/
@[simps]
def liftEquiv : { f : M →ₗ[R'] A // ∀ x y, f x * f y = 0 } ≃ (tsze R' M →ₐ[R'] A)
    where
  toFun f := lift f f.IProp
  invFun F :=
    ⟨F.toLinearMap.comp (inrHom R' M), fun x y =>
      (F.map_hMul _ _).symm.trans <| (F.congr_arg <| inr_mul_inr _ _ _).trans F.map_zero⟩
  left_inv f := Subtype.ext <| lift_comp_inrHom _ _
  right_inv F := algHom_ext' <| lift_comp_inrHom _ _
#align triv_sq_zero_ext.lift TrivSqZeroExt.liftEquiv
-/

attribute [nolint simp_nf] lift_symm_apply_coe

end Algebra

end TrivSqZeroExt

