/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Chris Hughes

! This file was ported from Lean 3 source module ring_theory.adjoin_root
! leanprover-community/mathlib commit f7fc89d5d5ff1db2d1242c7bb0e9062ce47ef47c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Basic
import Mathbin.Data.Polynomial.FieldDivision
import Mathbin.FieldTheory.Minpoly.Basic
import Mathbin.RingTheory.Adjoin.Basic
import Mathbin.RingTheory.FinitePresentation
import Mathbin.RingTheory.FiniteType
import Mathbin.RingTheory.PowerBasis
import Mathbin.RingTheory.PrincipalIdealDomain

/-!
# Adjoining roots of polynomials

This file defines the commutative ring `adjoin_root f`, the ring R[X]/(f) obtained from a
commutative ring `R` and a polynomial `f : R[X]`. If furthermore `R` is a field and `f` is
irreducible, the field structure on `adjoin_root f` is constructed.

We suggest stating results on `is_adjoin_root` instead of `adjoin_root` to achieve higher
generality, since `is_adjoin_root` works for all different constructions of `R[α]`
including `adjoin_root f = R[X]/(f)` itself.

## Main definitions and results

The main definitions are in the `adjoin_root` namespace.

*  `mk f : R[X] →+* adjoin_root f`, the natural ring homomorphism.

*  `of f : R →+* adjoin_root f`, the natural ring homomorphism.

* `root f : adjoin_root f`, the image of X in R[X]/(f).

* `lift (i : R →+* S) (x : S) (h : f.eval₂ i x = 0) : (adjoin_root f) →+* S`, the ring
  homomorphism from R[X]/(f) to S extending `i : R →+* S` and sending `X` to `x`.

* `lift_hom (x : S) (hfx : aeval x f = 0) : adjoin_root f →ₐ[R] S`, the algebra
  homomorphism from R[X]/(f) to S extending `algebra_map R S` and sending `X` to `x`

* `equiv : (adjoin_root f →ₐ[F] E) ≃ {x // x ∈ (f.map (algebra_map F E)).roots}` a
  bijection between algebra homomorphisms from `adjoin_root` and roots of `f` in `S`

-/


noncomputable section

open Classical

open BigOperators Polynomial

universe u v w

variable {R : Type u} {S : Type v} {K : Type w}

open Polynomial Ideal

/-- Adjoin a root of a polynomial `f` to a commutative ring `R`. We define the new ring
as the quotient of `R[X]` by the principal ideal generated by `f`. -/
def AdjoinRoot [CommRing R] (f : R[X]) : Type u :=
  Polynomial R ⧸ (span {f} : Ideal R[X])
#align adjoin_root AdjoinRoot

namespace AdjoinRoot

section CommRing

variable [CommRing R] (f : R[X])

instance : CommRing (AdjoinRoot f) :=
  Ideal.Quotient.commRing _

instance : Inhabited (AdjoinRoot f) :=
  ⟨0⟩

instance : DecidableEq (AdjoinRoot f) :=
  Classical.decEq _

protected theorem nontrivial [IsDomain R] (h : degree f ≠ 0) : Nontrivial (AdjoinRoot f) :=
  Ideal.Quotient.nontrivial
    (by
      simp_rw [Ne.def, span_singleton_eq_top, Polynomial.isUnit_iff, not_exists, not_and]
      rintro x hx rfl
      exact h (degree_C hx.ne_zero))
#align adjoin_root.nontrivial AdjoinRoot.nontrivial

/-- Ring homomorphism from `R[x]` to `adjoin_root f` sending `X` to the `root`. -/
def mk : R[X] →+* AdjoinRoot f :=
  Ideal.Quotient.mk _
#align adjoin_root.mk AdjoinRoot.mk

@[elab_as_elim]
theorem induction_on {C : AdjoinRoot f → Prop} (x : AdjoinRoot f) (ih : ∀ p : R[X], C (mk f p)) :
    C x :=
  Quotient.inductionOn' x ih
#align adjoin_root.induction_on AdjoinRoot.induction_on

/-- Embedding of the original ring `R` into `adjoin_root f`. -/
def of : R →+* AdjoinRoot f :=
  (mk f).comp c
#align adjoin_root.of AdjoinRoot.of

instance [CommSemiring S] [Algebra S R] : Algebra S (AdjoinRoot f) :=
  Ideal.Quotient.algebra S

instance [CommSemiring S] [CommSemiring K] [SMul S K] [Algebra S R] [Algebra K R]
    [IsScalarTower S K R] : IsScalarTower S K (AdjoinRoot f) :=
  Submodule.Quotient.isScalarTower _ _

instance [CommSemiring S] [CommSemiring K] [Algebra S R] [Algebra K R] [SMulCommClass S K R] :
    SMulCommClass S K (AdjoinRoot f) :=
  Submodule.Quotient.sMulCommClass _ _

@[simp]
theorem algebraMap_eq : algebraMap R (AdjoinRoot f) = of f :=
  rfl
#align adjoin_root.algebra_map_eq AdjoinRoot.algebraMap_eq

variable (S)

theorem algebraMap_eq' [CommSemiring S] [Algebra S R] :
    algebraMap S (AdjoinRoot f) = (of f).comp (algebraMap S R) :=
  rfl
#align adjoin_root.algebra_map_eq' AdjoinRoot.algebraMap_eq'

variable {S}

theorem finiteType : Algebra.FiniteType R (AdjoinRoot f) :=
  (Algebra.FiniteType.polynomial R).ofSurjective _ (Ideal.Quotient.mkₐ_surjective R _)
#align adjoin_root.finite_type AdjoinRoot.finiteType

theorem finitePresentation : Algebra.FinitePresentation R (AdjoinRoot f) :=
  (Algebra.FinitePresentation.polynomial R).Quotient (Submodule.fg_span_singleton f)
#align adjoin_root.finite_presentation AdjoinRoot.finitePresentation

/-- The adjoined root. -/
def root : AdjoinRoot f :=
  mk f x
#align adjoin_root.root AdjoinRoot.root

variable {f}

instance hasCoeT : CoeTC R (AdjoinRoot f) :=
  ⟨of f⟩
#align adjoin_root.has_coe_t AdjoinRoot.hasCoeT

/-- Two `R`-`alg_hom` from `adjoin_root f` to the same `R`-algebra are the same iff
    they agree on `root f`. -/
@[ext]
theorem algHom_ext [Semiring S] [Algebra R S] {g₁ g₂ : AdjoinRoot f →ₐ[R] S}
    (h : g₁ (root f) = g₂ (root f)) : g₁ = g₂ :=
  Ideal.Quotient.algHom_ext R <| Polynomial.algHom_ext h
#align adjoin_root.alg_hom_ext AdjoinRoot.algHom_ext

@[simp]
theorem mk_eq_mk {g h : R[X]} : mk f g = mk f h ↔ f ∣ g - h :=
  Ideal.Quotient.eq.trans Ideal.mem_span_singleton
#align adjoin_root.mk_eq_mk AdjoinRoot.mk_eq_mk

@[simp]
theorem mk_eq_zero {g : R[X]} : mk f g = 0 ↔ f ∣ g :=
  mk_eq_mk.trans <| by rw [sub_zero]
#align adjoin_root.mk_eq_zero AdjoinRoot.mk_eq_zero

@[simp]
theorem mk_self : mk f f = 0 :=
  Quotient.sound' <| quotientAddGroup.leftRel_apply.mpr (mem_span_singleton.2 <| by simp)
#align adjoin_root.mk_self AdjoinRoot.mk_self

@[simp]
theorem mk_c (x : R) : mk f (c x) = x :=
  rfl
#align adjoin_root.mk_C AdjoinRoot.mk_c

@[simp]
theorem mk_x : mk f x = root f :=
  rfl
#align adjoin_root.mk_X AdjoinRoot.mk_x

theorem mk_ne_zero_of_degree_lt (hf : Monic f) {g : R[X]} (h0 : g ≠ 0) (hd : degree g < degree f) :
    mk f g ≠ 0 :=
  mk_eq_zero.Not.2 <| hf.not_dvd_of_degree_lt h0 hd
#align adjoin_root.mk_ne_zero_of_degree_lt AdjoinRoot.mk_ne_zero_of_degree_lt

theorem mk_ne_zero_of_natDegree_lt (hf : Monic f) {g : R[X]} (h0 : g ≠ 0)
    (hd : natDegree g < natDegree f) : mk f g ≠ 0 :=
  mk_eq_zero.Not.2 <| hf.not_dvd_of_nat_degree_lt h0 hd
#align adjoin_root.mk_ne_zero_of_nat_degree_lt AdjoinRoot.mk_ne_zero_of_natDegree_lt

@[simp]
theorem aeval_eq (p : R[X]) : aeval (root f) p = mk f p :=
  Polynomial.induction_on p
    (fun x => by
      rw [aeval_C]
      rfl)
    (fun p q ihp ihq => by rw [AlgHom.map_add, RingHom.map_add, ihp, ihq]) fun n x ih =>
    by
    rw [AlgHom.map_mul, aeval_C, AlgHom.map_pow, aeval_X, RingHom.map_mul, mk_C, RingHom.map_pow,
      mk_X]
    rfl
#align adjoin_root.aeval_eq AdjoinRoot.aeval_eq

theorem adjoinRoot_eq_top : Algebra.adjoin R ({root f} : Set (AdjoinRoot f)) = ⊤ :=
  Algebra.eq_top_iff.2 fun x =>
    induction_on f x fun p =>
      (Algebra.adjoin_singleton_eq_range_aeval R (root f)).symm ▸ ⟨p, aeval_eq p⟩
#align adjoin_root.adjoin_root_eq_top AdjoinRoot.adjoinRoot_eq_top

@[simp]
theorem eval₂_root (f : R[X]) : f.eval₂ (of f) (root f) = 0 := by
  rw [← algebra_map_eq, ← aeval_def, aeval_eq, mk_self]
#align adjoin_root.eval₂_root AdjoinRoot.eval₂_root

theorem isRoot_root (f : R[X]) : IsRoot (f.map (of f)) (root f) := by
  rw [is_root, eval_map, eval₂_root]
#align adjoin_root.is_root_root AdjoinRoot.isRoot_root

theorem isAlgebraic_root (hf : f ≠ 0) : IsAlgebraic R (root f) :=
  ⟨f, hf, eval₂_root f⟩
#align adjoin_root.is_algebraic_root AdjoinRoot.isAlgebraic_root

theorem of.injective_of_degree_ne_zero [IsDomain R] (hf : f.degree ≠ 0) :
    Function.Injective (AdjoinRoot.of f) :=
  by
  rw [injective_iff_map_eq_zero]
  intro p hp
  rw [AdjoinRoot.of, RingHom.comp_apply, AdjoinRoot.mk_eq_zero] at hp
  by_cases h : f = 0
  · exact C_eq_zero.mp (eq_zero_of_zero_dvd (by rwa [h] at hp))
  · contrapose! hf with h_contra
    rw [← degree_C h_contra]
    apply le_antisymm (degree_le_of_dvd hp (by rwa [Ne.def, C_eq_zero])) _
    rwa [degree_C h_contra, zero_le_degree_iff]
#align adjoin_root.of.injective_of_degree_ne_zero AdjoinRoot.of.injective_of_degree_ne_zero

variable [CommRing S]

/-- Lift a ring homomorphism `i : R →+* S` to `adjoin_root f →+* S`. -/
def lift (i : R →+* S) (x : S) (h : f.eval₂ i x = 0) : AdjoinRoot f →+* S :=
  by
  apply Ideal.Quotient.lift _ (eval₂_ring_hom i x)
  intro g H
  rcases mem_span_singleton.1 H with ⟨y, hy⟩
  rw [hy, RingHom.map_mul, coe_eval₂_ring_hom, h, zero_mul]
#align adjoin_root.lift AdjoinRoot.lift

variable {i : R →+* S} {a : S} (h : f.eval₂ i a = 0)

@[simp]
theorem lift_mk (g : R[X]) : lift i a h (mk f g) = g.eval₂ i a :=
  Ideal.Quotient.lift_mk _ _ _
#align adjoin_root.lift_mk AdjoinRoot.lift_mk

@[simp]
theorem lift_root : lift i a h (root f) = a := by rw [root, lift_mk, eval₂_X]
#align adjoin_root.lift_root AdjoinRoot.lift_root

@[simp]
theorem lift_of {x : R} : lift i a h x = i x := by rw [← mk_C x, lift_mk, eval₂_C]
#align adjoin_root.lift_of AdjoinRoot.lift_of

@[simp]
theorem lift_comp_of : (lift i a h).comp (of f) = i :=
  RingHom.ext fun _ => @lift_of _ _ _ _ _ _ _ h _
#align adjoin_root.lift_comp_of AdjoinRoot.lift_comp_of

variable (f) [Algebra R S]

/-- Produce an algebra homomorphism `adjoin_root f →ₐ[R] S` sending `root f` to
a root of `f` in `S`. -/
def liftHom (x : S) (hfx : aeval x f = 0) : AdjoinRoot f →ₐ[R] S :=
  { lift (algebraMap R S) x hfx with
    commutes' := fun r => show lift _ _ hfx r = _ from lift_of hfx }
#align adjoin_root.lift_hom AdjoinRoot.liftHom

@[simp]
theorem coe_liftHom (x : S) (hfx : aeval x f = 0) :
    (liftHom f x hfx : AdjoinRoot f →+* S) = lift (algebraMap R S) x hfx :=
  rfl
#align adjoin_root.coe_lift_hom AdjoinRoot.coe_liftHom

@[simp]
theorem aeval_algHom_eq_zero (ϕ : AdjoinRoot f →ₐ[R] S) : aeval (ϕ (root f)) f = 0 :=
  by
  have h : ϕ.to_ring_hom.comp (of f) = algebraMap R S := ring_hom.ext_iff.mpr ϕ.commutes
  rw [aeval_def, ← h, ← RingHom.map_zero ϕ.to_ring_hom, ← eval₂_root f, hom_eval₂]
  rfl
#align adjoin_root.aeval_alg_hom_eq_zero AdjoinRoot.aeval_algHom_eq_zero

@[simp]
theorem liftHom_eq_algHom (f : R[X]) (ϕ : AdjoinRoot f →ₐ[R] S) :
    liftHom f (ϕ (root f)) (aeval_algHom_eq_zero f ϕ) = ϕ :=
  by
  suffices ϕ.equalizer (lift_hom f (ϕ (root f)) (aeval_alg_hom_eq_zero f ϕ)) = ⊤ by
    exact (AlgHom.ext fun x => (set_like.ext_iff.mp this x).mpr Algebra.mem_top).symm
  rw [eq_top_iff, ← adjoin_root_eq_top, Algebra.adjoin_le_iff, Set.singleton_subset_iff]
  exact (@lift_root _ _ _ _ _ _ _ (aeval_alg_hom_eq_zero f ϕ)).symm
#align adjoin_root.lift_hom_eq_alg_hom AdjoinRoot.liftHom_eq_algHom

variable (hfx : aeval a f = 0)

@[simp]
theorem liftHom_mk {g : R[X]} : liftHom f a hfx (mk f g) = aeval a g :=
  lift_mk hfx g
#align adjoin_root.lift_hom_mk AdjoinRoot.liftHom_mk

@[simp]
theorem liftHom_root : liftHom f a hfx (root f) = a :=
  lift_root hfx
#align adjoin_root.lift_hom_root AdjoinRoot.liftHom_root

@[simp]
theorem liftHom_of {x : R} : liftHom f a hfx (of f x) = algebraMap _ _ x :=
  lift_of hfx
#align adjoin_root.lift_hom_of AdjoinRoot.liftHom_of

section AdjoinInv

@[simp]
theorem root_is_inv (r : R) : of _ r * root (c r * X - 1) = 1 := by
  convert sub_eq_zero.1 ((eval₂_sub _).symm.trans <| eval₂_root <| C r * X - 1) <;>
    simp only [eval₂_mul, eval₂_C, eval₂_X, eval₂_one]
#align adjoin_root.root_is_inv AdjoinRoot.root_is_inv

theorem algHom_subsingleton {S : Type _} [CommRing S] [Algebra R S] {r : R} :
    Subsingleton (AdjoinRoot (c r * X - 1) →ₐ[R] S) :=
  ⟨fun f g =>
    algHom_ext
      (@inv_unique _ _ (algebraMap R S r) _ _
        (by rw [← f.commutes, ← f.map_mul, algebra_map_eq, root_is_inv, map_one])
        (by rw [← g.commutes, ← g.map_mul, algebra_map_eq, root_is_inv, map_one]))⟩
#align adjoin_root.alg_hom_subsingleton AdjoinRoot.algHom_subsingleton

end AdjoinInv

section Prime

variable {f}

theorem isDomain_of_prime (hf : Prime f) : IsDomain (AdjoinRoot f) :=
  (Ideal.Quotient.isDomain_iff_prime (span {f} : Ideal R[X])).mpr <|
    (Ideal.span_singleton_prime hf.NeZero).mpr hf
#align adjoin_root.is_domain_of_prime AdjoinRoot.isDomain_of_prime

theorem noZeroSMulDivisors_of_prime_of_degree_ne_zero [IsDomain R] (hf : Prime f)
    (hf' : f.degree ≠ 0) : NoZeroSMulDivisors R (AdjoinRoot f) :=
  haveI := is_domain_of_prime hf
  no_zero_smul_divisors.iff_algebra_map_injective.mpr (of.injective_of_degree_ne_zero hf')
#align adjoin_root.no_zero_smul_divisors_of_prime_of_degree_ne_zero AdjoinRoot.noZeroSMulDivisors_of_prime_of_degree_ne_zero

end Prime

end CommRing

section Irreducible

variable [Field K] {f : K[X]}

instance span_maximal_of_irreducible [Fact (Irreducible f)] : (span {f}).IsMaximal :=
  PrincipalIdealRing.isMaximal_of_irreducible <| Fact.out _
#align adjoin_root.span_maximal_of_irreducible AdjoinRoot.span_maximal_of_irreducible

noncomputable instance field [Fact (Irreducible f)] : Field (AdjoinRoot f) :=
  { AdjoinRoot.commRing f, Ideal.Quotient.field (span {f} : Ideal K[X]) with }
#align adjoin_root.field AdjoinRoot.field

theorem coe_injective (h : degree f ≠ 0) : Function.Injective (coe : K → AdjoinRoot f) :=
  have := AdjoinRoot.nontrivial f h
  (of f).Injective
#align adjoin_root.coe_injective AdjoinRoot.coe_injective

theorem coe_injective' [Fact (Irreducible f)] : Function.Injective (coe : K → AdjoinRoot f) :=
  (of f).Injective
#align adjoin_root.coe_injective' AdjoinRoot.coe_injective'

variable (f)

theorem mul_div_root_cancel [Fact (Irreducible f)] :
    (X - c (root f)) * (f.map (of f) / (X - c (root f))) = f.map (of f) :=
  mul_div_eq_iff_isRoot.2 <| isRoot_root _
#align adjoin_root.mul_div_root_cancel AdjoinRoot.mul_div_root_cancel

end Irreducible

section IsNoetherianRing

instance [CommRing R] [IsNoetherianRing R] {f : R[X]} : IsNoetherianRing (AdjoinRoot f) :=
  Ideal.Quotient.isNoetherianRing _

end IsNoetherianRing

section PowerBasis

variable [CommRing R] {g : R[X]}

theorem isIntegral_root' (hg : g.Monic) : IsIntegral R (root g) :=
  ⟨g, hg, eval₂_root g⟩
#align adjoin_root.is_integral_root' AdjoinRoot.isIntegral_root'

/-- `adjoin_root.mod_by_monic_hom` sends the equivalence class of `f` mod `g` to `f %ₘ g`.

This is a well-defined right inverse to `adjoin_root.mk`, see `adjoin_root.mk_left_inverse`. -/
def modByMonicHom (hg : g.Monic) : AdjoinRoot g →ₗ[R] R[X] :=
  (Submodule.liftq _ (Polynomial.modByMonicHom g)
        fun f (hf : f ∈ (Ideal.span {g}).restrictScalars R) =>
        (mem_ker_mod_by_monic hg).mpr (Ideal.mem_span_singleton.mp hf)).comp <|
    (Submodule.Quotient.restrictScalarsEquiv R (Ideal.span {g} : Ideal R[X])).symm.toLinearMap
#align adjoin_root.mod_by_monic_hom AdjoinRoot.modByMonicHom

@[simp]
theorem modByMonicHom_mk (hg : g.Monic) (f : R[X]) : modByMonicHom hg (mk g f) = f %ₘ g :=
  rfl
#align adjoin_root.mod_by_monic_hom_mk AdjoinRoot.modByMonicHom_mk

theorem mk_leftInverse (hg : g.Monic) : Function.LeftInverse (mk g) (modByMonicHom hg) := fun f =>
  induction_on g f fun f =>
    by
    rw [mod_by_monic_hom_mk hg, mk_eq_mk, mod_by_monic_eq_sub_mul_div _ hg, sub_sub_cancel_left,
      dvd_neg]
    apply dvd_mul_right
#align adjoin_root.mk_left_inverse AdjoinRoot.mk_leftInverse

theorem mk_surjective (hg : g.Monic) : Function.Surjective (mk g) :=
  (mk_leftInverse hg).Surjective
#align adjoin_root.mk_surjective AdjoinRoot.mk_surjective

/-- The elements `1, root g, ..., root g ^ (d - 1)` form a basis for `adjoin_root g`,
where `g` is a monic polynomial of degree `d`. -/
def powerBasisAux' (hg : g.Monic) : Basis (Fin g.natDegree) R (AdjoinRoot g) :=
  Basis.ofEquivFun
    { toFun := fun f i => (modByMonicHom hg f).coeff i
      invFun := fun c => mk g <| ∑ i : Fin g.natDegree, monomial i (c i)
      map_add' := fun f₁ f₂ =>
        funext fun i => by simp only [(mod_by_monic_hom hg).map_add, coeff_add, Pi.add_apply]
      map_smul' := fun f₁ f₂ =>
        funext fun i => by
          simp only [(mod_by_monic_hom hg).map_smul, coeff_smul, Pi.smul_apply, RingHom.id_apply]
      left_inv := fun f =>
        induction_on g f fun f =>
          Eq.symm <|
            mk_eq_mk.mpr <|
              by
              simp only [mod_by_monic_hom_mk, sum_mod_by_monic_coeff hg degree_le_nat_degree]
              rw [mod_by_monic_eq_sub_mul_div _ hg, sub_sub_cancel]
              exact dvd_mul_right _ _
      right_inv := fun x =>
        funext fun i => by
          nontriviality R
          simp only [mod_by_monic_hom_mk]
          rw [(mod_by_monic_eq_self_iff hg).mpr, finset_sum_coeff]
          · simp_rw [coeff_monomial, Fin.val_eq_val, Finset.sum_ite_eq', if_pos (Finset.mem_univ _)]
          · simp_rw [← C_mul_X_pow_eq_monomial]
            exact (degree_eq_nat_degree <| hg.ne_zero).symm ▸ degree_sum_fin_lt _ }
#align adjoin_root.power_basis_aux' AdjoinRoot.powerBasisAux'

/-- This lemma could be autogenerated by `@[simps]` but unfortunately that would require
unfolding that causes a timeout. -/
@[simp]
theorem powerBasisAux'_repr_symm_apply (hg : g.Monic) (c : Fin g.natDegree →₀ R) :
    (powerBasisAux' hg).repr.symm c = mk g (∑ i : Fin _, monomial i (c i)) :=
  rfl
#align adjoin_root.power_basis_aux'_repr_symm_apply AdjoinRoot.powerBasisAux'_repr_symm_apply

/-- This lemma could be autogenerated by `@[simps]` but unfortunately that would require
unfolding that causes a timeout. -/
@[simp]
theorem powerBasisAux'_repr_apply_to_fun (hg : g.Monic) (f : AdjoinRoot g) (i : Fin g.natDegree) :
    (powerBasisAux' hg).repr f i = (modByMonicHom hg f).coeff ↑i :=
  rfl
#align adjoin_root.power_basis_aux'_repr_apply_to_fun AdjoinRoot.powerBasisAux'_repr_apply_to_fun

/-- The power basis `1, root g, ..., root g ^ (d - 1)` for `adjoin_root g`,
where `g` is a monic polynomial of degree `d`. -/
@[simps]
def powerBasis' (hg : g.Monic) : PowerBasis R (AdjoinRoot g)
    where
  gen := root g
  dim := g.natDegree
  Basis := powerBasisAux' hg
  basis_eq_pow i :=
    by
    simp only [power_basis_aux', Basis.coe_ofEquivFun, LinearEquiv.coe_symm_mk]
    rw [Finset.sum_eq_single i]
    · rw [Function.update_same, monomial_one_right_eq_X_pow, (mk g).map_pow, mk_X]
    · intro j _ hj
      rw [← monomial_zero_right _]
      convert congr_arg _ (Function.update_noteq hj _ _)
    -- Fix `decidable_eq` mismatch
    · intros
      have := Finset.mem_univ i
      contradiction
#align adjoin_root.power_basis' AdjoinRoot.powerBasis'

variable [Field K] {f : K[X]}

theorem isIntegral_root (hf : f ≠ 0) : IsIntegral K (root f) :=
  isAlgebraic_iff_isIntegral.mp (isAlgebraic_root hf)
#align adjoin_root.is_integral_root AdjoinRoot.isIntegral_root

theorem minpoly_root (hf : f ≠ 0) : minpoly K (root f) = f * c f.leadingCoeff⁻¹ :=
  by
  have f'_monic : monic _ := monic_mul_leading_coeff_inv hf
  refine' (minpoly.unique K _ f'_monic _ _).symm
  · rw [AlgHom.map_mul, aeval_eq, mk_self, zero_mul]
  intro q q_monic q_aeval
  have commutes : (lift (algebraMap K (AdjoinRoot f)) (root f) q_aeval).comp (mk q) = mk f :=
    by
    ext
    · simp only [RingHom.comp_apply, mk_C, lift_of]
      rfl
    · simp only [RingHom.comp_apply, mk_X, lift_root]
  rw [degree_eq_nat_degree f'_monic.ne_zero, degree_eq_nat_degree q_monic.ne_zero,
    WithBot.coe_le_coe, nat_degree_mul hf, nat_degree_C, add_zero]
  apply nat_degree_le_of_dvd
  · have : mk f q = 0 := by rw [← commutes, RingHom.comp_apply, mk_self, RingHom.map_zero]
    rwa [← Ideal.mem_span_singleton, ← Ideal.Quotient.eq_zero_iff_mem]
  · exact q_monic.ne_zero
  · rwa [Ne.def, C_eq_zero, inv_eq_zero, leading_coeff_eq_zero]
#align adjoin_root.minpoly_root AdjoinRoot.minpoly_root

/-- The elements `1, root f, ..., root f ^ (d - 1)` form a basis for `adjoin_root f`,
where `f` is an irreducible polynomial over a field of degree `d`. -/
def powerBasisAux (hf : f ≠ 0) : Basis (Fin f.natDegree) K (AdjoinRoot f) :=
  by
  set f' := f * C f.leading_coeff⁻¹ with f'_def
  have deg_f' : f'.nat_degree = f.nat_degree :=
    by
    rw [nat_degree_mul hf, nat_degree_C, add_zero]
    · rwa [Ne.def, C_eq_zero, inv_eq_zero, leading_coeff_eq_zero]
  have minpoly_eq : minpoly K (root f) = f' := minpoly_root hf
  apply @Basis.mk _ _ _ fun i : Fin f.nat_degree => root f ^ i.val
  · rw [← deg_f', ← minpoly_eq]
    exact linearIndependent_pow (root f)
  · rintro y -
    rw [← deg_f', ← minpoly_eq]
    apply (is_integral_root hf).mem_span_pow
    obtain ⟨g⟩ := y
    use g
    rw [aeval_eq]
    rfl
#align adjoin_root.power_basis_aux AdjoinRoot.powerBasisAux

/-- The power basis `1, root f, ..., root f ^ (d - 1)` for `adjoin_root f`,
where `f` is an irreducible polynomial over a field of degree `d`. -/
@[simps]
def powerBasis (hf : f ≠ 0) : PowerBasis K (AdjoinRoot f)
    where
  gen := root f
  dim := f.natDegree
  Basis := powerBasisAux hf
  basis_eq_pow := Basis.mk_apply _ _
#align adjoin_root.power_basis AdjoinRoot.powerBasis

theorem minpoly_powerBasis_gen (hf : f ≠ 0) :
    minpoly K (powerBasis hf).gen = f * c f.leadingCoeff⁻¹ := by
  rw [power_basis_gen, minpoly_root hf]
#align adjoin_root.minpoly_power_basis_gen AdjoinRoot.minpoly_powerBasis_gen

theorem minpoly_powerBasis_gen_of_monic (hf : f.Monic) (hf' : f ≠ 0 := hf.NeZero) :
    minpoly K (powerBasis hf').gen = f := by
  rw [minpoly_power_basis_gen hf', hf.leading_coeff, inv_one, C.map_one, mul_one]
#align adjoin_root.minpoly_power_basis_gen_of_monic AdjoinRoot.minpoly_powerBasis_gen_of_monic

end PowerBasis

section Equiv

section minpoly

variable [CommRing R] [CommRing S] [Algebra R S] (x : S) (R)

open Algebra Polynomial

/-- The surjective algebra morphism `R[X]/(minpoly R x) → R[x]`.
If `R` is a GCD domain and `x` is integral, this is an isomorphism,
see `adjoin_root.minpoly.equiv_adjoin`. -/
@[simps]
def Minpoly.toAdjoin : AdjoinRoot (minpoly R x) →ₐ[R] adjoin R ({x} : Set S) :=
  liftHom _ ⟨x, self_mem_adjoin_singleton R x⟩
    (by simp [← Subalgebra.coe_eq_zero, aeval_subalgebra_coe])
#align adjoin_root.minpoly.to_adjoin AdjoinRoot.Minpoly.toAdjoin

variable {R x}

theorem Minpoly.toAdjoin_apply' (a : AdjoinRoot (minpoly R x)) :
    Minpoly.toAdjoin R x a =
      liftHom (minpoly R x) (⟨x, self_mem_adjoin_singleton R x⟩ : adjoin R ({x} : Set S))
        (by simp [← Subalgebra.coe_eq_zero, aeval_subalgebra_coe]) a :=
  rfl
#align adjoin_root.minpoly.to_adjoin_apply' AdjoinRoot.Minpoly.toAdjoin_apply'

theorem Minpoly.toAdjoin.apply_x :
    Minpoly.toAdjoin R x (mk (minpoly R x) x) = ⟨x, self_mem_adjoin_singleton R x⟩ := by simp
#align adjoin_root.minpoly.to_adjoin.apply_X AdjoinRoot.Minpoly.toAdjoin.apply_x

variable (R x)

theorem Minpoly.toAdjoin.surjective : Function.Surjective (Minpoly.toAdjoin R x) :=
  by
  rw [← range_top_iff_surjective, _root_.eq_top_iff, ← adjoin_adjoin_coe_preimage]
  refine' adjoin_le _
  simp only [AlgHom.coe_range, Set.mem_range]
  rintro ⟨y₁, y₂⟩ h
  refine' ⟨mk (minpoly R x) X, by simpa using h.symm⟩
#align adjoin_root.minpoly.to_adjoin.surjective AdjoinRoot.Minpoly.toAdjoin.surjective

end minpoly

section Equiv'

variable [CommRing R] [CommRing S] [Algebra R S]

variable (g : R[X]) (pb : PowerBasis R S)

/-- If `S` is an extension of `R` with power basis `pb` and `g` is a monic polynomial over `R`
such that `pb.gen` has a minimal polynomial `g`, then `S` is isomorphic to `adjoin_root g`.

Compare `power_basis.equiv_of_root`, which would require
`h₂ : aeval pb.gen (minpoly R (root g)) = 0`; that minimal polynomial is not
guaranteed to be identical to `g`. -/
@[simps (config := { fullyApplied := false })]
def equiv' (h₁ : aeval (root g) (minpoly R pb.gen) = 0) (h₂ : aeval pb.gen g = 0) :
    AdjoinRoot g ≃ₐ[R] S :=
  {
    AdjoinRoot.liftHom g pb.gen
      h₂ with
    toFun := AdjoinRoot.liftHom g pb.gen h₂
    invFun := pb.lift (root g) h₁
    left_inv := fun x => induction_on g x fun f => by rw [lift_hom_mk, pb.lift_aeval, aeval_eq]
    right_inv := fun x => by
      nontriviality S
      obtain ⟨f, hf, rfl⟩ := pb.exists_eq_aeval x
      rw [pb.lift_aeval, aeval_eq, lift_hom_mk] }
#align adjoin_root.equiv' AdjoinRoot.equiv'

@[simp]
theorem equiv'_toAlgHom (h₁ : aeval (root g) (minpoly R pb.gen) = 0) (h₂ : aeval pb.gen g = 0) :
    (equiv' g pb h₁ h₂).toAlgHom = AdjoinRoot.liftHom g pb.gen h₂ :=
  rfl
#align adjoin_root.equiv'_to_alg_hom AdjoinRoot.equiv'_toAlgHom

@[simp]
theorem equiv'_symm_toAlgHom (h₁ : aeval (root g) (minpoly R pb.gen) = 0)
    (h₂ : aeval pb.gen g = 0) : (equiv' g pb h₁ h₂).symm.toAlgHom = pb.lift (root g) h₁ :=
  rfl
#align adjoin_root.equiv'_symm_to_alg_hom AdjoinRoot.equiv'_symm_toAlgHom

end Equiv'

section Field

variable (K) (L F : Type _) [Field F] [Field K] [Field L] [Algebra F K] [Algebra F L]

variable (pb : PowerBasis F K)

/-- If `L` is a field extension of `F` and `f` is a polynomial over `F` then the set
of maps from `F[x]/(f)` into `L` is in bijection with the set of roots of `f` in `L`. -/
def equiv (f : F[X]) (hf : f ≠ 0) :
    (AdjoinRoot f →ₐ[F] L) ≃ { x // x ∈ (f.map (algebraMap F L)).roots } :=
  (powerBasis hf).liftEquiv'.trans
    ((Equiv.refl _).subtypeEquiv fun x =>
      by
      rw [power_basis_gen, minpoly_root hf, Polynomial.map_mul, roots_mul, Polynomial.map_c,
        roots_C, add_zero, Equiv.refl_apply]
      rw [← Polynomial.map_mul]; exact map_monic_ne_zero (monic_mul_leading_coeff_inv hf))
#align adjoin_root.equiv AdjoinRoot.equiv

end Field

end Equiv

section

open Ideal DoubleQuot Polynomial

variable [CommRing R] (I : Ideal R) (f : R[X])

/-- The natural isomorphism `R[α]/(I[α]) ≅ R[α]/((I[x] ⊔ (f)) / (f))` for `α` a root of
`f : R[X]` and `I : ideal R`.

See `adjoin_root.quot_map_of_equiv` for the isomorphism with `(R/I)[X] / (f mod I)`. -/
def quotMapOfEquivQuotMapCMapSpanMk :
    AdjoinRoot f ⧸ I.map (of f) ≃+* AdjoinRoot f ⧸ (I.map (c : R →+* R[X])).map (span {f}) :=
  Ideal.quotEquivOfEq (by rw [of, AdjoinRoot.mk, Ideal.map_map])
#align adjoin_root.quot_map_of_equiv_quot_map_C_map_span_mk AdjoinRoot.quotMapOfEquivQuotMapCMapSpanMk

@[simp]
theorem quotMapOfEquivQuotMapCMapSpanMk_mk (x : AdjoinRoot f) :
    quotMapOfEquivQuotMapCMapSpanMk I f (Ideal.Quotient.mk (I.map (of f)) x) =
      Ideal.Quotient.mk _ x :=
  rfl
#align adjoin_root.quot_map_of_equiv_quot_map_C_map_span_mk_mk AdjoinRoot.quotMapOfEquivQuotMapCMapSpanMk_mk

--this lemma should have the simp tag but this causes a lint issue
theorem quotMapOfEquivQuotMapCMapSpanMk_symm_mk (x : AdjoinRoot f) :
    (quotMapOfEquivQuotMapCMapSpanMk I f).symm
        (Ideal.Quotient.mk ((I.map (c : R →+* R[X])).map (span {f})) x) =
      Ideal.Quotient.mk (I.map (of f)) x :=
  by rw [quot_map_of_equiv_quot_map_C_map_span_mk, Ideal.quotEquivOfEq_symm, quot_equiv_of_eq_mk]
#align adjoin_root.quot_map_of_equiv_quot_map_C_map_span_mk_symm_mk AdjoinRoot.quotMapOfEquivQuotMapCMapSpanMk_symm_mk

/-- The natural isomorphism `R[α]/((I[x] ⊔ (f)) / (f)) ≅ (R[x]/I[x])/((f) ⊔ I[x] / I[x])`
  for `α` a root of `f : R[X]` and `I : ideal R`-/
def quotMapCMapSpanMkEquivQuotMapCQuotMapSpanMk :
    AdjoinRoot f ⧸ (I.map (c : R →+* R[X])).map (span ({f} : Set R[X])) ≃+*
      (R[X] ⧸ I.map (c : R →+* R[X])) ⧸ (span ({f} : Set R[X])).map (I.map (c : R →+* R[X])) :=
  quotQuotEquivComm (Ideal.span ({f} : Set R[X])) (I.map (c : R →+* R[X]))
#align adjoin_root.quot_map_C_map_span_mk_equiv_quot_map_C_quot_map_span_mk AdjoinRoot.quotMapCMapSpanMkEquivQuotMapCQuotMapSpanMk

@[simp]
theorem quotMapCMapSpanMkEquivQuotMapCQuotMapSpanMk_mk (p : R[X]) :
    quotMapCMapSpanMkEquivQuotMapCQuotMapSpanMk I f (Ideal.Quotient.mk _ (mk f p)) =
      quotQuotMk (I.map c) (span {f}) p :=
  rfl
#align adjoin_root.quot_map_C_map_span_mk_equiv_quot_map_C_quot_map_span_mk_mk AdjoinRoot.quotMapCMapSpanMkEquivQuotMapCQuotMapSpanMk_mk

@[simp]
theorem quotMapCMapSpanMkEquivQuotMapCQuotMapSpanMk_symm_quotQuotMk (p : R[X]) :
    (quotMapCMapSpanMkEquivQuotMapCQuotMapSpanMk I f).symm (quotQuotMk (I.map c) (span {f}) p) =
      Ideal.Quotient.mk _ (mk f p) :=
  rfl
#align adjoin_root.quot_map_C_map_span_mk_equiv_quot_map_C_quot_map_span_mk_symm_quot_quot_mk AdjoinRoot.quotMapCMapSpanMkEquivQuotMapCQuotMapSpanMk_symm_quotQuotMk

/-- The natural isomorphism `(R/I)[x]/(f mod I) ≅ (R[x]/I*R[x])/(f mod I[x])` where
  `f : R[X]` and `I : ideal R`-/
def Polynomial.quotQuotEquivComm :
    (R ⧸ I)[X] ⧸ span ({f.map I} : Set (Polynomial (R ⧸ I))) ≃+*
      (R[X] ⧸ map c I) ⧸ span ({(Ideal.Quotient.mk (I C)) f} : Set (R[X] ⧸ map c I)) :=
  quotientEquiv (span ({f.map I} : Set (Polynomial (R ⧸ I))))
    (span {Ideal.Quotient.mk (I.map Polynomial.c) f}) (polynomialQuotientEquivQuotientPolynomial I)
    (by
      rw [map_span, Set.image_singleton, RingEquiv.coe_toRingHom,
        polynomial_quotient_equiv_quotient_polynomial_map_mk I f])
#align adjoin_root.polynomial.quot_quot_equiv_comm AdjoinRoot.Polynomial.quotQuotEquivComm

@[simp]
theorem Polynomial.quotQuotEquivComm_mk (p : R[X]) :
    (Polynomial.quotQuotEquivComm I f) (Ideal.Quotient.mk _ (p.map I)) =
      Ideal.Quotient.mk _ (Ideal.Quotient.mk _ p) :=
  by
  simp only [polynomial.quot_quot_equiv_comm, quotient_equiv_mk,
    polynomial_quotient_equiv_quotient_polynomial_map_mk]
#align adjoin_root.polynomial.quot_quot_equiv_comm_mk AdjoinRoot.Polynomial.quotQuotEquivComm_mk

@[simp]
theorem Polynomial.quotQuotEquivComm_symm_mk_mk (p : R[X]) :
    (Polynomial.quotQuotEquivComm I f).symm (Ideal.Quotient.mk _ (Ideal.Quotient.mk _ p)) =
      Ideal.Quotient.mk _ (p.map I) :=
  by
  simp only [polynomial.quot_quot_equiv_comm, quotient_equiv_symm_mk,
    polynomial_quotient_equiv_quotient_polynomial_symm_mk]
#align adjoin_root.polynomial.quot_quot_equiv_comm_symm_mk_mk AdjoinRoot.Polynomial.quotQuotEquivComm_symm_mk_mk

/-- The natural isomorphism `R[α]/I[α] ≅ (R/I)[X]/(f mod I)` for `α` a root of `f : R[X]`
  and `I : ideal R`.-/
def quotAdjoinRootEquivQuotPolynomialQuot :
    AdjoinRoot f ⧸ I.map (of f) ≃+* (R ⧸ I)[X] ⧸ span ({f.map I} : Set (R ⧸ I)[X]) :=
  (quotMapOfEquivQuotMapCMapSpanMk I f).trans
    ((quotMapCMapSpanMkEquivQuotMapCQuotMapSpanMk I f).trans
      ((Ideal.quotEquivOfEq
            (show
              (span ({f} : Set R[X])).map (I.map (c : R →+* R[X])) =
                span ({(Ideal.Quotient.mk (I Polynomial.c)) f} : Set (R[X] ⧸ map c I))
              by rw [map_span, Set.image_singleton])).trans
        (Polynomial.quotQuotEquivComm I f).symm))
#align adjoin_root.quot_adjoin_root_equiv_quot_polynomial_quot AdjoinRoot.quotAdjoinRootEquivQuotPolynomialQuot

@[simp]
theorem quotAdjoinRootEquivQuotPolynomialQuot_mk_of (p : R[X]) :
    quotAdjoinRootEquivQuotPolynomialQuot I f (Ideal.Quotient.mk (I.map (of f)) (mk f p)) =
      Ideal.Quotient.mk (span ({f.map I} : Set (R ⧸ I)[X])) (p.map I) :=
  by
  rw [quot_adjoin_root_equiv_quot_polynomial_quot, RingEquiv.trans_apply, RingEquiv.trans_apply,
    RingEquiv.trans_apply, quot_map_of_equiv_quot_map_C_map_span_mk_mk,
    quot_map_C_map_span_mk_equiv_quot_map_C_quot_map_span_mk_mk, quot_quot_mk, RingHom.comp_apply,
    quot_equiv_of_eq_mk, polynomial.quot_quot_equiv_comm_symm_mk_mk]
#align adjoin_root.quot_adjoin_root_equiv_quot_polynomial_quot_mk_of AdjoinRoot.quotAdjoinRootEquivQuotPolynomialQuot_mk_of

@[simp]
theorem quotAdjoinRootEquivQuotPolynomialQuot_symm_mk_mk (p : R[X]) :
    (quotAdjoinRootEquivQuotPolynomialQuot I f).symm
        (Ideal.Quotient.mk (span ({f.map I} : Set (R ⧸ I)[X])) (p.map I)) =
      Ideal.Quotient.mk (I.map (of f)) (mk f p) :=
  by
  rw [quot_adjoin_root_equiv_quot_polynomial_quot, RingEquiv.symm_trans_apply,
    RingEquiv.symm_trans_apply, RingEquiv.symm_trans_apply, RingEquiv.symm_symm,
    polynomial.quot_quot_equiv_comm_mk, Ideal.quotEquivOfEq_symm, Ideal.quotEquivOfEq_mk, ←
    RingHom.comp_apply, ← DoubleQuot.quotQuotMk,
    quot_map_C_map_span_mk_equiv_quot_map_C_quot_map_span_mk_symm_quot_quot_mk,
    quot_map_of_equiv_quot_map_C_map_span_mk_symm_mk]
#align adjoin_root.quot_adjoin_root_equiv_quot_polynomial_quot_symm_mk_mk AdjoinRoot.quotAdjoinRootEquivQuotPolynomialQuot_symm_mk_mk

/-- Promote `adjoin_root.quot_adjoin_root_equiv_quot_polynomial_quot` to an alg_equiv.  -/
@[simps apply symm_apply]
noncomputable def quotEquivQuotMap (f : R[X]) (I : Ideal R) :
    (AdjoinRoot f ⧸ Ideal.map (of f) I) ≃ₐ[R]
      (R ⧸ I)[X] ⧸ Ideal.span ({Polynomial.map I f} : Set (R ⧸ I)[X]) :=
  AlgEquiv.ofRingEquiv
    (show ∀ x, (quotAdjoinRootEquivQuotPolynomialQuot I f) (algebraMap R _ x) = algebraMap R _ x
      from fun x =>
      by
      have :
        algebraMap R (AdjoinRoot f ⧸ Ideal.map (of f) I) x =
          Ideal.Quotient.mk (Ideal.map (AdjoinRoot.of f) I) ((mk f) (C x)) :=
        rfl
      simpa only [this, quot_adjoin_root_equiv_quot_polynomial_quot_mk_of, map_C] )
#align adjoin_root.quot_equiv_quot_map AdjoinRoot.quotEquivQuotMap

@[simp]
theorem quotEquivQuotMap_apply_mk (f g : R[X]) (I : Ideal R) :
    AdjoinRoot.quotEquivQuotMap f I (Ideal.Quotient.mk _ (AdjoinRoot.mk f g)) =
      Ideal.Quotient.mk _ (g.map I) :=
  by rw [AdjoinRoot.quotEquivQuotMap_apply, AdjoinRoot.quotAdjoinRootEquivQuotPolynomialQuot_mk_of]
#align adjoin_root.quot_equiv_quot_map_apply_mk AdjoinRoot.quotEquivQuotMap_apply_mk

@[simp]
theorem quotEquivQuotMap_symm_apply_mk (f g : R[X]) (I : Ideal R) :
    (AdjoinRoot.quotEquivQuotMap f I).symm (Ideal.Quotient.mk _ (map (Ideal.Quotient.mk I) g)) =
      Ideal.Quotient.mk _ (AdjoinRoot.mk f g) :=
  by
  rw [AdjoinRoot.quotEquivQuotMap_symm_apply,
    AdjoinRoot.quotAdjoinRootEquivQuotPolynomialQuot_symm_mk_mk]
#align adjoin_root.quot_equiv_quot_map_symm_apply_mk AdjoinRoot.quotEquivQuotMap_symm_apply_mk

end

end AdjoinRoot

namespace PowerBasis

open AdjoinRoot AlgEquiv

variable [CommRing R] [CommRing S] [Algebra R S]

/-- Let `α` have minimal polynomial `f` over `R` and `I` be an ideal of `R`,
then `R[α] / (I) = (R[x] / (f)) / pS = (R/p)[x] / (f mod p)`. -/
@[simps apply symm_apply]
noncomputable def quotientEquivQuotientMinpolyMap (pb : PowerBasis R S) (I : Ideal R) :
    (S ⧸ I.map (algebraMap R S)) ≃ₐ[R]
      Polynomial (R ⧸ I) ⧸ Ideal.span ({(minpoly R pb).map I} : Set (Polynomial (R ⧸ I))) :=
  (ofRingEquiv
        (show
          ∀ x,
            (Ideal.quotientEquiv _ (Ideal.map (AdjoinRoot.of (minpoly R pb.gen)) I)
                  (AdjoinRoot.equiv' (minpoly R pb.gen) pb
                        (by rw [AdjoinRoot.aeval_eq, AdjoinRoot.mk_self])
                        (minpoly.aeval _ _)).symm.toRingEquiv
                  (by
                    rw [Ideal.map_map, AlgEquiv.toRingEquiv_eq_coe, ← AlgEquiv.coe_ringHom_commutes,
                      ← AdjoinRoot.algebraMap_eq, AlgHom.comp_algebraMap]))
                (algebraMap R (S ⧸ I.map (algebraMap R S)) x) =
              algebraMap R _ x
          from fun x => by
          rw [← Ideal.Quotient.mk_algebraMap, Ideal.quotientEquiv_apply, RingHom.toFun_eq_coe,
            Ideal.quotientMap_mk, AlgEquiv.toRingEquiv_eq_coe, RingEquiv.coe_toRingHom,
            AlgEquiv.coe_ringEquiv, AlgEquiv.commutes, quotient.mk_algebra_map])).trans
    (AdjoinRoot.quotEquivQuotMap _ _)
#align power_basis.quotient_equiv_quotient_minpoly_map PowerBasis.quotientEquivQuotientMinpolyMap

@[simp]
theorem quotientEquivQuotientMinpolyMap_apply_mk (pb : PowerBasis R S) (I : Ideal R) (g : R[X]) :
    pb.quotientEquivQuotientMinpolyMap I (Ideal.Quotient.mk _ (aeval pb.gen g)) =
      Ideal.Quotient.mk _ (g.map I) :=
  by
  rw [PowerBasis.quotientEquivQuotientMinpolyMap, AlgEquiv.trans_apply, AlgEquiv.ofRingEquiv_apply,
    quotient_equiv_mk, AlgEquiv.coe_ring_equiv', AdjoinRoot.equiv'_symm_apply,
    PowerBasis.lift_aeval, AdjoinRoot.aeval_eq, AdjoinRoot.quotEquivQuotMap_apply_mk]
#align power_basis.quotient_equiv_quotient_minpoly_map_apply_mk PowerBasis.quotientEquivQuotientMinpolyMap_apply_mk

@[simp]
theorem quotientEquivQuotientMinpolyMap_symm_apply_mk (pb : PowerBasis R S) (I : Ideal R)
    (g : R[X]) :
    (pb.quotientEquivQuotientMinpolyMap I).symm (Ideal.Quotient.mk _ (g.map I)) =
      Ideal.Quotient.mk _ (aeval pb.gen g) :=
  by
  simp only [quotient_equiv_quotient_minpoly_map, to_ring_equiv_eq_coe, symm_trans_apply,
    quot_equiv_quot_map_symm_apply_mk, of_ring_equiv_symm_apply, quotient_equiv_symm_mk,
    to_ring_equiv_symm, RingEquiv.symm_symm, AdjoinRoot.equiv'_apply, coe_ring_equiv, lift_hom_mk,
    symm_to_ring_equiv]
#align power_basis.quotient_equiv_quotient_minpoly_map_symm_apply_mk PowerBasis.quotientEquivQuotientMinpolyMap_symm_apply_mk

end PowerBasis

