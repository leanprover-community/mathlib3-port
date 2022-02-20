/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Chris Hughes
-/
import Mathbin.Data.Polynomial.FieldDivision
import Mathbin.LinearAlgebra.FiniteDimensional
import Mathbin.RingTheory.Adjoin.Basic
import Mathbin.RingTheory.PowerBasis
import Mathbin.RingTheory.PrincipalIdealDomain

/-!
# Adjoining roots of polynomials

This file defines the commutative ring `adjoin_root f`, the ring R[X]/(f) obtained from a
commutative ring `R` and a polynomial `f : R[X]`. If furthermore `R` is a field and `f` is
irreducible, the field structure on `adjoin_root f` is constructed.

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

open_locale Classical

open_locale BigOperators Polynomial

universe u v w

variable {R : Type u} {S : Type v} {K : Type w}

open Polynomial Ideal

/-- Adjoin a root of a polynomial `f` to a commutative ring `R`. We define the new ring
as the quotient of `polynomial R` by the principal ideal generated by `f`. -/
def AdjoinRoot [CommRingₓ R] (f : R[X]) : Type u :=
  Polynomial R ⧸ (span {f} : Ideal R[X])

namespace AdjoinRoot

section CommRingₓ

variable [CommRingₓ R] (f : R[X])

instance : CommRingₓ (AdjoinRoot f) :=
  Ideal.Quotient.commRing _

instance : Inhabited (AdjoinRoot f) :=
  ⟨0⟩

instance : DecidableEq (AdjoinRoot f) :=
  Classical.decEq _

/-- Ring homomorphism from `R[x]` to `adjoin_root f` sending `X` to the `root`. -/
def mk : R[X] →+* AdjoinRoot f :=
  Ideal.Quotient.mk _

@[elab_as_eliminator]
theorem induction_on {C : AdjoinRoot f → Prop} (x : AdjoinRoot f) (ih : ∀ p : R[X], C (mk f p)) : C x :=
  Quotientₓ.induction_on' x ih

/-- Embedding of the original ring `R` into `adjoin_root f`. -/
def of : R →+* AdjoinRoot f :=
  (mk f).comp c

instance [CommSemiringₓ S] [Algebra S R] : Algebra S (AdjoinRoot f) :=
  Ideal.Quotient.algebra S

instance [CommSemiringₓ S] [CommSemiringₓ K] [HasScalar S K] [Algebra S R] [Algebra K R] [IsScalarTower S K R] :
    IsScalarTower S K (AdjoinRoot f) :=
  Submodule.Quotient.is_scalar_tower _ _

instance [CommSemiringₓ S] [CommSemiringₓ K] [Algebra S R] [Algebra K R] [SmulCommClass S K R] :
    SmulCommClass S K (AdjoinRoot f) :=
  Submodule.Quotient.smul_comm_class _ _

@[simp]
theorem algebra_map_eq : algebraMap R (AdjoinRoot f) = of f :=
  rfl

variable (S)

theorem algebra_map_eq' [CommSemiringₓ S] [Algebra S R] : algebraMap S (AdjoinRoot f) = (of f).comp (algebraMap S R) :=
  rfl

variable {S}

/-- The adjoined root. -/
def root : AdjoinRoot f :=
  mk f x

variable {f}

instance AdjoinRoot.hasCoeT : CoeTₓ R (AdjoinRoot f) :=
  ⟨of f⟩

@[simp]
theorem mk_eq_mk {g h : R[X]} : mk f g = mk f h ↔ f ∣ g - h :=
  Ideal.Quotient.eq.trans Ideal.mem_span_singleton

@[simp]
theorem mk_self : mk f f = 0 :=
  Quotientₓ.sound'
    (mem_span_singleton.2 <| by
      simp )

@[simp]
theorem mk_C (x : R) : mk f (c x) = x :=
  rfl

@[simp]
theorem mk_X : mk f x = root f :=
  rfl

@[simp]
theorem aeval_eq (p : R[X]) : aeval (root f) p = mk f p :=
  Polynomial.induction_on p
    (fun x => by
      rw [aeval_C]
      rfl)
    (fun p q ihp ihq => by
      rw [AlgHom.map_add, RingHom.map_add, ihp, ihq])
    fun n x ih => by
    rw [AlgHom.map_mul, aeval_C, AlgHom.map_pow, aeval_X, RingHom.map_mul, mk_C, RingHom.map_pow, mk_X]
    rfl

theorem adjoin_root_eq_top : Algebra.adjoin R ({root f} : Set (AdjoinRoot f)) = ⊤ :=
  Algebra.eq_top_iff.2 fun x =>
    (induction_on f x) fun p => (Algebra.adjoin_singleton_eq_range_aeval R (root f)).symm ▸ ⟨p, aeval_eq p⟩

@[simp]
theorem eval₂_root (f : R[X]) : f.eval₂ (of f) (root f) = 0 := by
  rw [← algebra_map_eq, ← aeval_def, aeval_eq, mk_self]

theorem is_root_root (f : R[X]) : IsRoot (f.map (of f)) (root f) := by
  rw [is_root, eval_map, eval₂_root]

theorem is_algebraic_root (hf : f ≠ 0) : IsAlgebraic R (root f) :=
  ⟨f, hf, eval₂_root f⟩

variable [CommRingₓ S]

/-- Lift a ring homomorphism `i : R →+* S` to `adjoin_root f →+* S`. -/
def lift (i : R →+* S) (x : S) (h : f.eval₂ i x = 0) : AdjoinRoot f →+* S := by
  apply Ideal.Quotient.lift _ (eval₂_ring_hom i x)
  intro g H
  rcases mem_span_singleton.1 H with ⟨y, hy⟩
  rw [hy, RingHom.map_mul, coe_eval₂_ring_hom, h, zero_mul]

variable {i : R →+* S} {a : S} (h : f.eval₂ i a = 0)

@[simp]
theorem lift_mk (g : R[X]) : lift i a h (mk f g) = g.eval₂ i a :=
  Ideal.Quotient.lift_mk _ _ _

@[simp]
theorem lift_root : lift i a h (root f) = a := by
  rw [root, lift_mk, eval₂_X]

@[simp]
theorem lift_of {x : R} : lift i a h x = i x := by
  rw [← mk_C x, lift_mk, eval₂_C]

@[simp]
theorem lift_comp_of : (lift i a h).comp (of f) = i :=
  RingHom.ext fun _ => @lift_of _ _ _ _ _ _ _ h _

variable (f) [Algebra R S]

/-- Produce an algebra homomorphism `adjoin_root f →ₐ[R] S` sending `root f` to
a root of `f` in `S`. -/
def liftHom (x : S) (hfx : aeval x f = 0) : AdjoinRoot f →ₐ[R] S :=
  { lift (algebraMap R S) x hfx with commutes' := fun r => show lift _ _ hfx r = _ from lift_of hfx }

@[simp]
theorem coe_lift_hom (x : S) (hfx : aeval x f = 0) :
    (liftHom f x hfx : AdjoinRoot f →+* S) = lift (algebraMap R S) x hfx :=
  rfl

@[simp]
theorem aeval_alg_hom_eq_zero (ϕ : AdjoinRoot f →ₐ[R] S) : aeval (ϕ (root f)) f = 0 := by
  have h : ϕ.to_ring_hom.comp (of f) = algebraMap R S := ring_hom.ext_iff.mpr ϕ.commutes
  rw [aeval_def, ← h, ← RingHom.map_zero ϕ.to_ring_hom, ← eval₂_root f, hom_eval₂]
  rfl

@[simp]
theorem lift_hom_eq_alg_hom (f : R[X]) (ϕ : AdjoinRoot f →ₐ[R] S) :
    liftHom f (ϕ (root f)) (aeval_alg_hom_eq_zero f ϕ) = ϕ := by
  suffices ϕ.equalizer (lift_hom f (ϕ (root f)) (aeval_alg_hom_eq_zero f ϕ)) = ⊤ by
    exact (AlgHom.ext fun x => (set_like.ext_iff.mp this x).mpr Algebra.mem_top).symm
  rw [eq_top_iff, ← adjoin_root_eq_top, Algebra.adjoin_le_iff, Set.singleton_subset_iff]
  exact (@lift_root _ _ _ _ _ _ _ (aeval_alg_hom_eq_zero f ϕ)).symm

variable (hfx : aeval a f = 0)

@[simp]
theorem lift_hom_mk {g : R[X]} : liftHom f a hfx (mk f g) = aeval a g :=
  lift_mk hfx g

@[simp]
theorem lift_hom_root : liftHom f a hfx (root f) = a :=
  lift_root hfx

@[simp]
theorem lift_hom_of {x : R} : liftHom f a hfx (of f x) = algebraMap _ _ x :=
  lift_of hfx

end CommRingₓ

section Irreducible

variable [Field K] {f : K[X]} [Irreducible f]

instance is_maximal_span : IsMaximal (span {f} : Ideal K[X]) :=
  PrincipalIdealRing.is_maximal_of_irreducible ‹Irreducible f›

noncomputable instance field : Field (AdjoinRoot f) :=
  { AdjoinRoot.commRing f, Ideal.Quotient.field (span {f} : Ideal K[X]) with }

theorem coe_injective : Function.Injective (coe : K → AdjoinRoot f) :=
  (of f).Injective

variable (f)

theorem mul_div_root_cancel :
    ((X - c (root f)) * (f.map (of f) / (X - c (root f))) : Polynomial (AdjoinRoot f)) = f.map (of f) :=
  mul_div_eq_iff_is_root.2 <| is_root_root _

end Irreducible

section PowerBasis

variable [CommRingₓ R] {g : R[X]}

theorem is_integral_root' (hg : g.Monic) : IsIntegral R (root g) :=
  ⟨g, hg, eval₂_root g⟩

/-- `adjoin_root.mod_by_monic_hom` sends the equivalence class of `f` mod `g` to `f %ₘ g`.

This is a well-defined right inverse to `adjoin_root.mk`, see `adjoin_root.mk_left_inverse`. -/
def modByMonicHom [Nontrivial R] (hg : g.Monic) : AdjoinRoot g →ₗ[R] R[X] :=
  (Submodule.liftq _ (Polynomial.modByMonicHom hg) fun hf : f ∈ (Ideal.span {g}).restrictScalars R =>
        (mem_ker_mod_by_monic hg).mpr (Ideal.mem_span_singleton.mp hf)).comp <|
    (Submodule.Quotient.restrictScalarsEquiv R (Ideal.span {g} : Ideal R[X])).symm.toLinearMap

@[simp]
theorem mod_by_monic_hom_mk [Nontrivial R] (hg : g.Monic) (f : R[X]) : modByMonicHom hg (mk g f) = f %ₘ g :=
  rfl

theorem mk_left_inverse [Nontrivial R] (hg : g.Monic) : Function.LeftInverse (mk g) (modByMonicHom hg) := fun f =>
  (induction_on g f) fun f => by
    rw [mod_by_monic_hom_mk hg, mk_eq_mk, mod_by_monic_eq_sub_mul_div _ hg, sub_sub_cancel_left, dvd_neg]
    apply dvd_mul_right

theorem mk_surjective [Nontrivial R] (hg : g.Monic) : Function.Surjective (mk g) :=
  (mk_left_inverse hg).Surjective

/-- The elements `1, root g, ..., root g ^ (d - 1)` form a basis for `adjoin_root g`,
where `g` is a monic polynomial of degree `d`. -/
@[simps]
def powerBasisAux' [Nontrivial R] (hg : g.Monic) : Basis (Finₓ g.natDegree) R (AdjoinRoot g) :=
  Basis.ofEquivFun
    { toFun := fun f i => (modByMonicHom hg f).coeff i,
      invFun := fun c => mk g <| ∑ i : Finₓ g.natDegree, monomial i (c i),
      map_add' := fun f₁ f₂ =>
        funext fun i => by
          simp only [(mod_by_monic_hom hg).map_add, coeff_add, Pi.add_apply],
      map_smul' := fun f₁ f₂ =>
        funext fun i => by
          simp only [(mod_by_monic_hom hg).map_smul, coeff_smul, Pi.smul_apply, RingHom.id_apply],
      left_inv := fun f =>
        induction_on g f fun f =>
          Eq.symm <|
            mk_eq_mk.mpr <| by
              simp only [mod_by_monic_hom_mk, sum_mod_by_monic_coeff hg degree_le_nat_degree]
              rw [mod_by_monic_eq_sub_mul_div _ hg, sub_sub_cancel]
              exact dvd_mul_right _ _,
      right_inv := fun x =>
        funext fun i => by
          simp only [mod_by_monic_hom_mk]
          rw [(mod_by_monic_eq_self_iff hg).mpr, finset_sum_coeff, Finset.sum_eq_single i] <;>
            try
              simp only [coeff_monomial, eq_self_iff_true, if_true]
          · intro j _ hj
            exact if_neg (fin.coe_injective.ne hj)
            
          · intros
            have := Finset.mem_univ i
            contradiction
            
          · refine' (degree_sum_le _ _).trans_lt ((Finset.sup_lt_iff _).mpr fun j _ => _)
            · exact bot_lt_iff_ne_bot.mpr (mt degree_eq_bot.mp hg.ne_zero)
              
            · refine' (degree_monomial_le _ _).trans_lt _
              rw [degree_eq_nat_degree hg.ne_zero, WithBot.coe_lt_coe]
              exact j.2
              
             }

/-- The power basis `1, root g, ..., root g ^ (d - 1)` for `adjoin_root g`,
where `g` is a monic polynomial of degree `d`. -/
@[simps]
def powerBasis' [Nontrivial R] (hg : g.Monic) : PowerBasis R (AdjoinRoot g) where
  gen := root g
  dim := g.natDegree
  Basis := powerBasisAux' hg
  basis_eq_pow := fun i => by
    simp only [power_basis_aux', Basis.coe_of_equiv_fun, LinearEquiv.coe_symm_mk]
    rw [Finset.sum_eq_single i]
    · rw [Function.update_same, monomial_one_right_eq_X_pow, (mk g).map_pow, mk_X]
      
    · intro j _ hj
      rw [← monomial_zero_right _]
      convert congr_argₓ _ (Function.update_noteq hj _ _)
      
    -- Fix `decidable_eq` mismatch
    · intros
      have := Finset.mem_univ i
      contradiction
      

variable [Field K] {f : K[X]}

theorem is_integral_root (hf : f ≠ 0) : IsIntegral K (root f) :=
  is_algebraic_iff_is_integral.mp (is_algebraic_root hf)

theorem minpoly_root (hf : f ≠ 0) : minpoly K (root f) = f * c f.leadingCoeff⁻¹ := by
  have f'_monic : monic _ := monic_mul_leading_coeff_inv hf
  refine' (minpoly.unique K _ f'_monic _ _).symm
  · rw [AlgHom.map_mul, aeval_eq, mk_self, zero_mul]
    
  intro q q_monic q_aeval
  have commutes : (lift (algebraMap K (AdjoinRoot f)) (root f) q_aeval).comp (mk q) = mk f := by
    ext
    · simp only [RingHom.comp_apply, mk_C, lift_of]
      rfl
      
    · simp only [RingHom.comp_apply, mk_X, lift_root]
      
  rw [degree_eq_nat_degree f'_monic.ne_zero, degree_eq_nat_degree q_monic.ne_zero, WithBot.coe_le_coe,
    nat_degree_mul hf, nat_degree_C, add_zeroₓ]
  apply nat_degree_le_of_dvd
  · have : mk f q = 0 := by
      rw [← commutes, RingHom.comp_apply, mk_self, RingHom.map_zero]
    rwa [← Ideal.mem_span_singleton, ← Ideal.Quotient.eq_zero_iff_mem]
    
  · exact q_monic.ne_zero
    
  · rwa [Ne.def, C_eq_zero, inv_eq_zero, leading_coeff_eq_zero]
    

/-- The elements `1, root f, ..., root f ^ (d - 1)` form a basis for `adjoin_root f`,
where `f` is an irreducible polynomial over a field of degree `d`. -/
def powerBasisAux (hf : f ≠ 0) : Basis (Finₓ f.natDegree) K (AdjoinRoot f) := by
  set f' := f * C f.leading_coeff⁻¹ with f'_def
  have deg_f' : f'.nat_degree = f.nat_degree := by
    rw [nat_degree_mul hf, nat_degree_C, add_zeroₓ]
    · rwa [Ne.def, C_eq_zero, inv_eq_zero, leading_coeff_eq_zero]
      
  have minpoly_eq : minpoly K (root f) = f' := minpoly_root hf
  apply @Basis.mk _ _ _ fun i : Finₓ f.nat_degree => root f ^ i.val
  · rw [← deg_f', ← minpoly_eq]
    exact (is_integral_root hf).linear_independent_pow
    
  · rw [_root_.eq_top_iff]
    rintro y -
    rw [← deg_f', ← minpoly_eq]
    apply (is_integral_root hf).mem_span_pow
    obtain ⟨g⟩ := y
    use g
    rw [aeval_eq]
    rfl
    

/-- The power basis `1, root f, ..., root f ^ (d - 1)` for `adjoin_root f`,
where `f` is an irreducible polynomial over a field of degree `d`. -/
@[simps]
def powerBasis (hf : f ≠ 0) : PowerBasis K (AdjoinRoot f) where
  gen := root f
  dim := f.natDegree
  Basis := powerBasisAux hf
  basis_eq_pow := Basis.mk_apply _ _

theorem minpoly_power_basis_gen (hf : f ≠ 0) : minpoly K (powerBasis hf).gen = f * c f.leadingCoeff⁻¹ := by
  rw [power_basis_gen, minpoly_root hf]

theorem minpoly_power_basis_gen_of_monic (hf : f.Monic) (hf' : f ≠ 0 := hf.ne_zero) :
    minpoly K (powerBasis hf').gen = f := by
  rw [minpoly_power_basis_gen hf', hf.leading_coeff, inv_one, C.map_one, mul_oneₓ]

end PowerBasis

section Equivₓ

section IsDomain

variable [CommRingₓ R] [IsDomain R] [CommRingₓ S] [IsDomain S] [Algebra R S]

variable (g : R[X]) (pb : PowerBasis R S)

/-- If `S` is an extension of `R` with power basis `pb` and `g` is a monic polynomial over `R`
such that `pb.gen` has a minimal polynomial `g`, then `S` is isomorphic to `adjoin_root g`.

Compare `power_basis.equiv_of_root`, which would require
`h₂ : aeval pb.gen (minpoly R (root g)) = 0`; that minimal polynomial is not
guaranteed to be identical to `g`. -/
@[simps (config := { fullyApplied := false })]
def equiv' (h₁ : aeval (root g) (minpoly R pb.gen) = 0) (h₂ : aeval pb.gen g = 0) : AdjoinRoot g ≃ₐ[R] S :=
  { AdjoinRoot.liftHom g pb.gen h₂ with toFun := AdjoinRoot.liftHom g pb.gen h₂, invFun := pb.lift (root g) h₁,
    left_inv := fun x =>
      (induction_on g x) fun f => by
        rw [lift_hom_mk, pb.lift_aeval, aeval_eq],
    right_inv := fun x => by
      obtain ⟨f, hf, rfl⟩ := pb.exists_eq_aeval x
      rw [pb.lift_aeval, aeval_eq, lift_hom_mk] }

@[simp]
theorem equiv'_to_alg_hom (h₁ : aeval (root g) (minpoly R pb.gen) = 0) (h₂ : aeval pb.gen g = 0) :
    (equiv' g pb h₁ h₂).toAlgHom = AdjoinRoot.liftHom g pb.gen h₂ :=
  rfl

@[simp]
theorem equiv'_symm_to_alg_hom (h₁ : aeval (root g) (minpoly R pb.gen) = 0) (h₂ : aeval pb.gen g = 0) :
    (equiv' g pb h₁ h₂).symm.toAlgHom = pb.lift (root g) h₁ :=
  rfl

end IsDomain

section Field

variable (K) (L F : Type _) [Field F] [Field K] [Field L] [Algebra F K] [Algebra F L]

variable (pb : PowerBasis F K)

/-- If `L` is a field extension of `F` and `f` is a polynomial over `F` then the set
of maps from `F[x]/(f)` into `L` is in bijection with the set of roots of `f` in `L`. -/
def equiv (f : F[X]) (hf : f ≠ 0) : (AdjoinRoot f →ₐ[F] L) ≃ { x // x ∈ (f.map (algebraMap F L)).roots } :=
  (powerBasis hf).liftEquiv'.trans
    ((Equivₓ.refl _).subtypeEquiv fun x => by
      rw [power_basis_gen, minpoly_root hf, Polynomial.map_mul, roots_mul, Polynomial.map_C, roots_C, add_zeroₓ,
        Equivₓ.refl_apply]
      · rw [← Polynomial.map_mul]
        exact map_monic_ne_zero (monic_mul_leading_coeff_inv hf)
        )

end Field

end Equivₓ

end AdjoinRoot

