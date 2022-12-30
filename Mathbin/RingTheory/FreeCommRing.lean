/-
Copyright (c) 2019 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Johan Commelin

! This file was ported from Lean 3 source module ring_theory.free_comm_ring
! leanprover-community/mathlib commit 09597669f02422ed388036273d8848119699c22f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.MvPolynomial.Equiv
import Mathbin.Data.MvPolynomial.CommRing
import Mathbin.Logic.Equiv.Functor
import Mathbin.RingTheory.FreeRing

/-!
# Free commutative rings

The theory of the free commutative ring generated by a type `α`.
It is isomorphic to the polynomial ring over ℤ with variables
in `α`

## Main definitions

* `free_comm_ring α`     : the free commutative ring on a type α
* `lift (f : α → R)` : the ring hom `free_comm_ring α →+* R` induced by functoriality from `f`.
* `map (f : α → β)`      : the ring hom `free_comm_ring α →*+ free_comm_ring β` induced by
                           functoriality from f.

## Main results

`free_comm_ring` has functorial properties (it is an adjoint to the forgetful functor).
In this file we have:

* `of : α → free_comm_ring α`
* `lift (f : α → R) : free_comm_ring α →+* R`
* `map (f : α → β) : free_comm_ring α →+* free_comm_ring β`

* `free_comm_ring_equiv_mv_polynomial_int : free_comm_ring α ≃+* mv_polynomial α ℤ` :
    `free_comm_ring α` is isomorphic to a polynomial ring.



## Implementation notes

`free_comm_ring α` is implemented not using `mv_polynomial` but
directly as the free abelian group on `multiset α`, the type
of monomials in this free commutative ring.

## Tags

free commutative ring, free ring
-/


noncomputable section

open Classical Polynomial

universe u v

variable (α : Type u)

/-- `free_comm_ring α` is the free commutative ring on the type `α`. -/
def FreeCommRing (α : Type u) : Type u :=
  FreeAbelianGroup <| Multiplicative <| Multiset α deriving CommRing, Inhabited
#align free_comm_ring FreeCommRing

namespace FreeCommRing

variable {α}

/-- The canonical map from `α` to the free commutative ring on `α`. -/
def of (x : α) : FreeCommRing α :=
  FreeAbelianGroup.of <| Multiplicative.ofAdd ({x} : Multiset α)
#align free_comm_ring.of FreeCommRing.of

theorem of_injective : Function.Injective (of : α → FreeCommRing α) :=
  FreeAbelianGroup.of_injective.comp fun x y =>
    (Multiset.coe_eq_coe.trans List.singleton_perm_singleton).mp
#align free_comm_ring.of_injective FreeCommRing.of_injective

@[elab_as_elim]
protected theorem induction_on {C : FreeCommRing α → Prop} (z : FreeCommRing α) (hn1 : C (-1))
    (hb : ∀ b, C (of b)) (ha : ∀ x y, C x → C y → C (x + y)) (hm : ∀ x y, C x → C y → C (x * y)) :
    C z :=
  have hn : ∀ x, C x → C (-x) := fun x ih => neg_one_mul x ▸ hm _ _ hn1 ih
  have h1 : C 1 := neg_neg (1 : FreeCommRing α) ▸ hn _ hn1
  FreeAbelianGroup.induction_on z (add_left_neg (1 : FreeCommRing α) ▸ ha _ _ hn1 h1)
    (fun m => (Multiset.induction_on m h1) fun a m ih => hm _ _ (hb a) ih) (fun m ih => hn _ ih) ha
#align free_comm_ring.induction_on FreeCommRing.induction_on

section lift

variable {R : Type v} [CommRing R] (f : α → R)

/-- A helper to implement `lift`. This is essentially `free_comm_monoid.lift`, but this does not
currently exist. -/
private def lift_to_multiset : (α → R) ≃ (Multiplicative (Multiset α) →* R)
    where
  toFun f :=
    { toFun := fun s => (s.toAdd.map f).Prod
      map_mul' := fun x y =>
        calc
          _ = Multiset.prod (Multiset.map f x + Multiset.map f y) :=
            by
            congr 1
            exact Multiset.map_add _ _ _
          _ = _ := Multiset.prod_add _ _
          
      map_one' := rfl }
  invFun F x := F (Multiplicative.ofAdd ({x} : Multiset α))
  left_inv f := funext fun x => show (Multiset.map f {x}).Prod = _ by simp
  right_inv F :=
    MonoidHom.ext fun x =>
      let F' := F.toAdditive''
      let x' := x.toAdd
      show (Multiset.map (fun a => F' {a}) x').Sum = F' x'
        by
        rw [← Multiset.map_map, ← AddMonoidHom.map_multiset_sum]
        exact F.congr_arg (Multiset.sum_map_singleton x')
#align free_comm_ring.lift_to_multiset free_comm_ring.lift_to_multiset

/-- Lift a map `α → R` to a additive group homomorphism `free_comm_ring α → R`.
For a version producing a bundled homomorphism, see `lift_hom`. -/
def lift : (α → R) ≃ (FreeCommRing α →+* R) :=
  Equiv.trans liftToMultiset FreeAbelianGroup.liftMonoid
#align free_comm_ring.lift FreeCommRing.lift

@[simp]
theorem lift_of (x : α) : lift f (of x) = f x :=
  (FreeAbelianGroup.lift.of _ _).trans <| mul_one _
#align free_comm_ring.lift_of FreeCommRing.lift_of

@[simp]
theorem lift_comp_of (f : FreeCommRing α →+* R) : lift (f ∘ of) = f :=
  RingHom.ext fun x =>
    FreeCommRing.induction_on x (by rw [RingHom.map_neg, RingHom.map_one, f.map_neg, f.map_one])
      (lift_of _) (fun x y ihx ihy => by rw [RingHom.map_add, f.map_add, ihx, ihy])
      fun x y ihx ihy => by rw [RingHom.map_mul, f.map_mul, ihx, ihy]
#align free_comm_ring.lift_comp_of FreeCommRing.lift_comp_of

@[ext]
theorem hom_ext ⦃f g : FreeCommRing α →+* R⦄ (h : ∀ x, f (of x) = g (of x)) : f = g :=
  lift.symm.Injective (funext h)
#align free_comm_ring.hom_ext FreeCommRing.hom_ext

end lift

variable {β : Type v} (f : α → β)

/-- A map `f : α → β` produces a ring homomorphism `free_comm_ring α →+* free_comm_ring β`. -/
def map : FreeCommRing α →+* FreeCommRing β :=
  lift <| of ∘ f
#align free_comm_ring.map FreeCommRing.map

@[simp]
theorem map_of (x : α) : map f (of x) = of (f x) :=
  lift_of _ _
#align free_comm_ring.map_of FreeCommRing.map_of

/-- `is_supported x s` means that all monomials showing up in `x` have variables in `s`. -/
def IsSupported (x : FreeCommRing α) (s : Set α) : Prop :=
  x ∈ Subring.closure (of '' s)
#align free_comm_ring.is_supported FreeCommRing.IsSupported

section IsSupported

variable {x y : FreeCommRing α} {s t : Set α}

theorem is_supported_upwards (hs : IsSupported x s) (hst : s ⊆ t) : IsSupported x t :=
  Subring.closure_mono (Set.monotone_image hst) hs
#align free_comm_ring.is_supported_upwards FreeCommRing.is_supported_upwards

theorem is_supported_add (hxs : IsSupported x s) (hys : IsSupported y s) : IsSupported (x + y) s :=
  Subring.add_mem _ hxs hys
#align free_comm_ring.is_supported_add FreeCommRing.is_supported_add

theorem is_supported_neg (hxs : IsSupported x s) : IsSupported (-x) s :=
  Subring.neg_mem _ hxs
#align free_comm_ring.is_supported_neg FreeCommRing.is_supported_neg

theorem is_supported_sub (hxs : IsSupported x s) (hys : IsSupported y s) : IsSupported (x - y) s :=
  Subring.sub_mem _ hxs hys
#align free_comm_ring.is_supported_sub FreeCommRing.is_supported_sub

theorem is_supported_mul (hxs : IsSupported x s) (hys : IsSupported y s) : IsSupported (x * y) s :=
  Subring.mul_mem _ hxs hys
#align free_comm_ring.is_supported_mul FreeCommRing.is_supported_mul

theorem is_supported_zero : IsSupported 0 s :=
  Subring.zero_mem _
#align free_comm_ring.is_supported_zero FreeCommRing.is_supported_zero

theorem is_supported_one : IsSupported 1 s :=
  Subring.one_mem _
#align free_comm_ring.is_supported_one FreeCommRing.is_supported_one

theorem is_supported_int {i : ℤ} {s : Set α} : IsSupported (↑i) s :=
  Int.induction_on i is_supported_zero
    (fun i hi => by rw [Int.cast_add, Int.cast_one] <;> exact is_supported_add hi is_supported_one)
    fun i hi => by rw [Int.cast_sub, Int.cast_one] <;> exact is_supported_sub hi is_supported_one
#align free_comm_ring.is_supported_int FreeCommRing.is_supported_int

end IsSupported

/-- The restriction map from `free_comm_ring α` to `free_comm_ring s` where `s : set α`, defined
  by sending all variables not in `s` to zero. -/
def restriction (s : Set α) [DecidablePred (· ∈ s)] : FreeCommRing α →+* FreeCommRing s :=
  lift fun p => if H : p ∈ s then of (⟨p, H⟩ : s) else 0
#align free_comm_ring.restriction FreeCommRing.restriction

section Restriction

variable (s : Set α) [DecidablePred (· ∈ s)] (x y : FreeCommRing α)

@[simp]
theorem restriction_of (p) : restriction s (of p) = if H : p ∈ s then of ⟨p, H⟩ else 0 :=
  lift_of _ _
#align free_comm_ring.restriction_of FreeCommRing.restriction_of

end Restriction

theorem is_supported_of {p} {s : Set α} : IsSupported (of p) s ↔ p ∈ s :=
  suffices IsSupported (of p) s → p ∈ s from ⟨this, fun hps => Subring.subset_closure ⟨p, hps, rfl⟩⟩
  fun hps : IsSupported (of p) s =>
  by
  haveI := Classical.decPred s
  have :
    ∀ x,
      is_supported x s →
        ∃ n : ℤ, lift (fun a => if a ∈ s then (0 : ℤ[X]) else Polynomial.x) x = n :=
    by
    intro x hx
    refine' Subring.InClosure.rec_on hx _ _ _ _
    · use 1
      rw [RingHom.map_one]
      norm_cast
    · use -1
      rw [RingHom.map_neg, RingHom.map_one, Int.cast_neg, Int.cast_one]
    · rintro _ ⟨z, hzs, rfl⟩ _ _
      use 0
      rw [RingHom.map_mul, lift_of, if_pos hzs, zero_mul]
      norm_cast
    · rintro x y ⟨q, hq⟩ ⟨r, hr⟩
      refine' ⟨q + r, _⟩
      rw [RingHom.map_add, hq, hr]
      norm_cast
  specialize this (of p) hps
  rw [lift_of] at this
  split_ifs  at this
  · exact h
  exfalso
  apply Ne.symm Int.zero_ne_one
  rcases this with ⟨w, H⟩
  rw [← Polynomial.C_eq_int_cast] at H
  have : polynomial.X.coeff 1 = (Polynomial.c ↑w).coeff 1 := by rw [H]
  rwa [Polynomial.coeff_C, if_neg (one_ne_zero : 1 ≠ 0), Polynomial.coeff_X, if_pos rfl] at this
#align free_comm_ring.is_supported_of FreeCommRing.is_supported_of

theorem map_subtype_val_restriction {x} (s : Set α) [DecidablePred (· ∈ s)]
    (hxs : IsSupported x s) : map (Subtype.val : s → α) (restriction s x) = x :=
  by
  refine' Subring.InClosure.rec_on hxs _ _ _ _
  · rw [RingHom.map_one]
    rfl
  · rw [RingHom.map_neg, RingHom.map_neg, RingHom.map_one]
    rfl
  · rintro _ ⟨p, hps, rfl⟩ n ih
    rw [RingHom.map_mul, restriction_of, dif_pos hps, RingHom.map_mul, map_of, ih]
  · intro x y ihx ihy
    rw [RingHom.map_add, RingHom.map_add, ihx, ihy]
#align free_comm_ring.map_subtype_val_restriction FreeCommRing.map_subtype_val_restriction

theorem exists_finite_support (x : FreeCommRing α) : ∃ s : Set α, Set.Finite s ∧ IsSupported x s :=
  FreeCommRing.induction_on x ⟨∅, Set.finite_empty, is_supported_neg is_supported_one⟩
    (fun p => ⟨{p}, Set.finite_singleton p, is_supported_of.2 <| Set.mem_singleton _⟩)
    (fun x y ⟨s, hfs, hxs⟩ ⟨t, hft, hxt⟩ =>
      ⟨s ∪ t, hfs.union hft,
        is_supported_add (is_supported_upwards hxs <| Set.subset_union_left s t)
          (is_supported_upwards hxt <| Set.subset_union_right s t)⟩)
    fun x y ⟨s, hfs, hxs⟩ ⟨t, hft, hxt⟩ =>
    ⟨s ∪ t, hfs.union hft,
      is_supported_mul (is_supported_upwards hxs <| Set.subset_union_left s t)
        (is_supported_upwards hxt <| Set.subset_union_right s t)⟩
#align free_comm_ring.exists_finite_support FreeCommRing.exists_finite_support

theorem exists_finset_support (x : FreeCommRing α) : ∃ s : Finset α, IsSupported x ↑s :=
  let ⟨s, hfs, hxs⟩ := exists_finite_support x
  ⟨hfs.toFinset, by rwa [Set.Finite.coe_to_finset]⟩
#align free_comm_ring.exists_finset_support FreeCommRing.exists_finset_support

end FreeCommRing

namespace FreeRing

open Function

variable (α)

/-- The canonical ring homomorphism from the free ring generated by `α` to the free commutative ring
    generated by `α`. -/
def toFreeCommRing {α} : FreeRing α →+* FreeCommRing α :=
  FreeRing.lift FreeCommRing.of
#align free_ring.to_free_comm_ring FreeRing.toFreeCommRing

instance : Coe (FreeRing α) (FreeCommRing α) :=
  ⟨toFreeCommRing⟩

/-- The natural map `free_ring α → free_comm_ring α`, as a `ring_hom`. -/
def coeRingHom : FreeRing α →+* FreeCommRing α :=
  to_free_comm_ring
#align free_ring.coe_ring_hom FreeRing.coeRingHom

@[simp, norm_cast]
protected theorem coe_zero : ↑(0 : FreeRing α) = (0 : FreeCommRing α) :=
  rfl
#align free_ring.coe_zero FreeRing.coe_zero

@[simp, norm_cast]
protected theorem coe_one : ↑(1 : FreeRing α) = (1 : FreeCommRing α) :=
  rfl
#align free_ring.coe_one FreeRing.coe_one

variable {α}

@[simp]
protected theorem coe_of (a : α) : ↑(FreeRing.of a) = FreeCommRing.of a :=
  FreeRing.lift_of _ _
#align free_ring.coe_of FreeRing.coe_of

@[simp, norm_cast]
protected theorem coe_neg (x : FreeRing α) : ↑(-x) = -(x : FreeCommRing α) :=
  (FreeRing.lift _).map_neg _
#align free_ring.coe_neg FreeRing.coe_neg

@[simp, norm_cast]
protected theorem coe_add (x y : FreeRing α) : ↑(x + y) = (x : FreeCommRing α) + y :=
  (FreeRing.lift _).map_add _ _
#align free_ring.coe_add FreeRing.coe_add

@[simp, norm_cast]
protected theorem coe_sub (x y : FreeRing α) : ↑(x - y) = (x : FreeCommRing α) - y :=
  (FreeRing.lift _).map_sub _ _
#align free_ring.coe_sub FreeRing.coe_sub

@[simp, norm_cast]
protected theorem coe_mul (x y : FreeRing α) : ↑(x * y) = (x : FreeCommRing α) * y :=
  (FreeRing.lift _).map_mul _ _
#align free_ring.coe_mul FreeRing.coe_mul

variable (α)

protected theorem coe_surjective : Surjective (coe : FreeRing α → FreeCommRing α) := fun x =>
  by
  apply FreeCommRing.induction_on x
  · use -1
    rfl
  · intro x
    use FreeRing.of x
    rfl
  · rintro _ _ ⟨x, rfl⟩ ⟨y, rfl⟩
    use x + y
    exact (FreeRing.lift _).map_add _ _
  · rintro _ _ ⟨x, rfl⟩ ⟨y, rfl⟩
    use x * y
    exact (FreeRing.lift _).map_mul _ _
#align free_ring.coe_surjective FreeRing.coe_surjective

theorem coe_eq :
    (coe : FreeRing α → FreeCommRing α) =
      @Functor.map FreeAbelianGroup _ _ _ fun l : List α => (l : Multiset α) :=
  funext fun x =>
    (FreeAbelianGroup.lift.unique _ _) fun L =>
      by
      simp_rw [FreeAbelianGroup.lift.of, (· ∘ ·)]
      exact
        FreeMonoid.recOn L rfl fun hd tl ih =>
          by
          rw [(FreeMonoid.lift _).map_mul, FreeMonoid.lift_eval_of, ih]
          rfl
#align free_ring.coe_eq FreeRing.coe_eq

/-- If α has size at most 1 then the natural map from the free ring on `α` to the
    free commutative ring on `α` is an isomorphism of rings. -/
def subsingletonEquivFreeCommRing [Subsingleton α] : FreeRing α ≃+* FreeCommRing α :=
  RingEquiv.ofBijective (coeRingHom _)
    (by
      have :
        (coe_ring_hom _ : FreeRing α → FreeCommRing α) =
          Functor.mapEquiv FreeAbelianGroup (Multiset.subsingletonEquiv α) :=
        coe_eq α
      rw [this]
      apply Equiv.bijective)
#align free_ring.subsingleton_equiv_free_comm_ring FreeRing.subsingletonEquivFreeCommRing

instance [Subsingleton α] : CommRing (FreeRing α) :=
  { FreeRing.ring α with
    mul_comm := fun x y => by
      rw [← (subsingleton_equiv_free_comm_ring α).symm_apply_apply (y * x),
        (subsingleton_equiv_free_comm_ring α).map_mul, mul_comm, ←
        (subsingleton_equiv_free_comm_ring α).map_mul,
        (subsingleton_equiv_free_comm_ring α).symm_apply_apply] }

end FreeRing

/-- The free commutative ring on `α` is isomorphic to the polynomial ring over ℤ with
    variables in `α` -/
def freeCommRingEquivMvPolynomialInt : FreeCommRing α ≃+* MvPolynomial α ℤ :=
  RingEquiv.ofHomInv (FreeCommRing.lift <| (fun a => MvPolynomial.x a : α → MvPolynomial α ℤ))
    (MvPolynomial.eval₂Hom (Int.castRingHom (FreeCommRing α)) FreeCommRing.of)
    (by
      ext
      simp)
    (by ext <;> simp)
#align free_comm_ring_equiv_mv_polynomial_int freeCommRingEquivMvPolynomialInt

/-- The free commutative ring on the empty type is isomorphic to `ℤ`. -/
def freeCommRingPemptyEquivInt : FreeCommRing PEmpty.{u + 1} ≃+* ℤ :=
  RingEquiv.trans (freeCommRingEquivMvPolynomialInt _) (MvPolynomial.isEmptyRingEquiv _ PEmpty)
#align free_comm_ring_pempty_equiv_int freeCommRingPemptyEquivInt

/-- The free commutative ring on a type with one term is isomorphic to `ℤ[X]`. -/
def freeCommRingPunitEquivPolynomialInt : FreeCommRing PUnit.{u + 1} ≃+* ℤ[X] :=
  (freeCommRingEquivMvPolynomialInt _).trans (MvPolynomial.punitAlgEquiv ℤ).toRingEquiv
#align free_comm_ring_punit_equiv_polynomial_int freeCommRingPunitEquivPolynomialInt

open FreeRing

/-- The free ring on the empty type is isomorphic to `ℤ`. -/
def freeRingPemptyEquivInt : FreeRing PEmpty.{u + 1} ≃+* ℤ :=
  RingEquiv.trans (subsingletonEquivFreeCommRing _) freeCommRingPemptyEquivInt
#align free_ring_pempty_equiv_int freeRingPemptyEquivInt

/-- The free ring on a type with one term is isomorphic to `ℤ[X]`. -/
def freeRingPunitEquivPolynomialInt : FreeRing PUnit.{u + 1} ≃+* ℤ[X] :=
  RingEquiv.trans (subsingletonEquivFreeCommRing _) freeCommRingPunitEquivPolynomialInt
#align free_ring_punit_equiv_polynomial_int freeRingPunitEquivPolynomialInt

