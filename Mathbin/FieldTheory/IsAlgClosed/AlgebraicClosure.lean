/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module field_theory.is_alg_closed.algebraic_closure
! leanprover-community/mathlib commit 6a5a6494968741677358457a806f487c7e293d39
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.DirectLimit
import Mathbin.FieldTheory.IsAlgClosed.Basic
import Mathbin.FieldTheory.SplittingField

/-!
# Algebraic Closure

In this file we construct the algebraic closure of a field

## Main Definitions

- `algebraic_closure k` is an algebraic closure of `k` (in the same universe).
  It is constructed by taking the polynomial ring generated by indeterminates `x_f`
  corresponding to monic irreducible polynomials `f` with coefficients in `k`, and quotienting
  out by a maximal ideal containing every `f(x_f)`, and then repeating this step countably
  many times. See Exercise 1.13 in Atiyah--Macdonald.

## Tags

algebraic closure, algebraically closed
-/


universe u v w

noncomputable section

open Classical BigOperators Polynomial

open Polynomial

variable (k : Type u) [Field k]

namespace AlgebraicClosure

open MvPolynomial

/-- The subtype of monic irreducible polynomials -/
@[reducible]
def MonicIrreducible : Type u :=
  { f : k[X] // Monic f ∧ Irreducible f }
#align algebraic_closure.monic_irreducible AlgebraicClosure.MonicIrreducible

/-- Sends a monic irreducible polynomial `f` to `f(x_f)` where `x_f` is a formal indeterminate. -/
def evalXSelf (f : MonicIrreducible k) : MvPolynomial (MonicIrreducible k) k :=
  Polynomial.eval₂ MvPolynomial.c (x f) f
#align algebraic_closure.eval_X_self AlgebraicClosure.evalXSelf

/-- The span of `f(x_f)` across monic irreducible polynomials `f` where `x_f` is an
indeterminate. -/
def spanEval : Ideal (MvPolynomial (MonicIrreducible k) k) :=
  Ideal.span <| Set.range <| evalXSelf k
#align algebraic_closure.span_eval AlgebraicClosure.spanEval

/-- Given a finset of monic irreducible polynomials, construct an algebra homomorphism to the
splitting field of the product of the polynomials sending each indeterminate `x_f` represented by
the polynomial `f` in the finset to a root of `f`. -/
def toSplittingField (s : Finset (MonicIrreducible k)) :
    MvPolynomial (MonicIrreducible k) k →ₐ[k] SplittingField (∏ x in s, x : k[X]) :=
  MvPolynomial.aeval fun f =>
    if hf : f ∈ s then
      rootOfSplits _
        ((splits_prod_iff _ fun (j : MonicIrreducible k) _ => j.2.2.NeZero).1
          (SplittingField.splits _) f hf)
        (mt isUnit_iff_degree_eq_zero.2 f.2.2.not_unit)
    else 37
#align algebraic_closure.to_splitting_field AlgebraicClosure.toSplittingField

theorem toSplittingField_evalXSelf {s : Finset (MonicIrreducible k)} {f} (hf : f ∈ s) :
    toSplittingField k s (evalXSelf k f) = 0 :=
  by
  rw [to_splitting_field, eval_X_self, ← AlgHom.coe_toRingHom, hom_eval₂, AlgHom.coe_toRingHom,
    MvPolynomial.aeval_x, dif_pos hf, ← algebra_map_eq, AlgHom.comp_algebraMap]
  exact map_root_of_splits _ _ _
#align algebraic_closure.to_splitting_field_eval_X_self AlgebraicClosure.toSplittingField_evalXSelf

theorem spanEval_ne_top : spanEval k ≠ ⊤ :=
  by
  rw [Ideal.ne_top_iff_one, span_eval, Ideal.span, ← Set.image_univ,
    Finsupp.mem_span_image_iff_total]
  rintro ⟨v, _, hv⟩
  replace hv := congr_arg (to_splitting_field k v.support) hv
  rw [AlgHom.map_one, Finsupp.total_apply, Finsupp.sum, AlgHom.map_sum, Finset.sum_eq_zero] at hv
  · exact zero_ne_one hv
  intro j hj
  rw [smul_eq_mul, AlgHom.map_mul, to_splitting_field_eval_X_self k hj, MulZeroClass.mul_zero]
#align algebraic_closure.span_eval_ne_top AlgebraicClosure.spanEval_ne_top

/-- A random maximal ideal that contains `span_eval k` -/
def maxIdeal : Ideal (MvPolynomial (MonicIrreducible k) k) :=
  Classical.choose <| Ideal.exists_le_maximal _ <| spanEval_ne_top k
#align algebraic_closure.max_ideal AlgebraicClosure.maxIdeal

instance maxIdeal.isMaximal : (maxIdeal k).IsMaximal :=
  (Classical.choose_spec <| Ideal.exists_le_maximal _ <| spanEval_ne_top k).1
#align algebraic_closure.max_ideal.is_maximal AlgebraicClosure.maxIdeal.isMaximal

theorem le_maxIdeal : spanEval k ≤ maxIdeal k :=
  (Classical.choose_spec <| Ideal.exists_le_maximal _ <| spanEval_ne_top k).2
#align algebraic_closure.le_max_ideal AlgebraicClosure.le_maxIdeal

/-- The first step of constructing `algebraic_closure`: adjoin a root of all monic polynomials -/
def AdjoinMonic : Type u :=
  MvPolynomial (MonicIrreducible k) k ⧸ maxIdeal k
#align algebraic_closure.adjoin_monic AlgebraicClosure.AdjoinMonic

instance AdjoinMonic.field : Field (AdjoinMonic k) :=
  Ideal.Quotient.field _
#align algebraic_closure.adjoin_monic.field AlgebraicClosure.AdjoinMonic.field

instance AdjoinMonic.inhabited : Inhabited (AdjoinMonic k) :=
  ⟨37⟩
#align algebraic_closure.adjoin_monic.inhabited AlgebraicClosure.AdjoinMonic.inhabited

/-- The canonical ring homomorphism to `adjoin_monic k`. -/
def toAdjoinMonic : k →+* AdjoinMonic k :=
  (Ideal.Quotient.mk _).comp c
#align algebraic_closure.to_adjoin_monic AlgebraicClosure.toAdjoinMonic

instance AdjoinMonic.algebra : Algebra k (AdjoinMonic k) :=
  (toAdjoinMonic k).toAlgebra
#align algebraic_closure.adjoin_monic.algebra AlgebraicClosure.AdjoinMonic.algebra

theorem AdjoinMonic.algebraMap : algebraMap k (AdjoinMonic k) = (Ideal.Quotient.mk _).comp c :=
  rfl
#align algebraic_closure.adjoin_monic.algebra_map AlgebraicClosure.AdjoinMonic.algebraMap

theorem AdjoinMonic.isIntegral (z : AdjoinMonic k) : IsIntegral k z :=
  let ⟨p, hp⟩ := Ideal.Quotient.mk_surjective z
  hp ▸
    MvPolynomial.induction_on p (fun x => isIntegral_algebraMap) (fun p q => isIntegral_add)
      fun p f ih =>
      @isIntegral_mul _ _ _ _ _ _ (Ideal.Quotient.mk _ _) ih
        ⟨f, f.2.1,
          by
          erw [adjoin_monic.algebra_map, ← hom_eval₂, Ideal.Quotient.eq_zero_iff_mem]
          exact le_max_ideal k (Ideal.subset_span ⟨f, rfl⟩)⟩
#align algebraic_closure.adjoin_monic.is_integral AlgebraicClosure.AdjoinMonic.isIntegral

theorem AdjoinMonic.exists_root {f : k[X]} (hfm : f.Monic) (hfi : Irreducible f) :
    ∃ x : AdjoinMonic k, f.eval₂ (toAdjoinMonic k) x = 0 :=
  ⟨Ideal.Quotient.mk _ <| x (⟨f, hfm, hfi⟩ : MonicIrreducible k),
    by
    rw [to_adjoin_monic, ← hom_eval₂, Ideal.Quotient.eq_zero_iff_mem]
    exact le_max_ideal k (Ideal.subset_span <| ⟨_, rfl⟩)⟩
#align algebraic_closure.adjoin_monic.exists_root AlgebraicClosure.AdjoinMonic.exists_root

/-- The `n`th step of constructing `algebraic_closure`, together with its `field` instance. -/
def stepAux (n : ℕ) : Σα : Type u, Field α :=
  Nat.recOn n ⟨k, inferInstance⟩ fun n ih => ⟨@AdjoinMonic ih.1 ih.2, @AdjoinMonic.field ih.1 ih.2⟩
#align algebraic_closure.step_aux AlgebraicClosure.stepAux

/-- The `n`th step of constructing `algebraic_closure`. -/
def Step (n : ℕ) : Type u :=
  (stepAux k n).1
#align algebraic_closure.step AlgebraicClosure.Step

instance Step.field (n : ℕ) : Field (Step k n) :=
  (stepAux k n).2
#align algebraic_closure.step.field AlgebraicClosure.Step.field

instance Step.inhabited (n) : Inhabited (Step k n) :=
  ⟨37⟩
#align algebraic_closure.step.inhabited AlgebraicClosure.Step.inhabited

/-- The canonical inclusion to the `0`th step. -/
def toStepZero : k →+* Step k 0 :=
  RingHom.id k
#align algebraic_closure.to_step_zero AlgebraicClosure.toStepZero

/-- The canonical ring homomorphism to the next step. -/
def toStepSucc (n : ℕ) : Step k n →+* Step k (n + 1) :=
  @toAdjoinMonic (Step k n) (Step.field k n)
#align algebraic_closure.to_step_succ AlgebraicClosure.toStepSucc

instance Step.algebraSucc (n) : Algebra (Step k n) (Step k (n + 1)) :=
  (toStepSucc k n).toAlgebra
#align algebraic_closure.step.algebra_succ AlgebraicClosure.Step.algebraSucc

theorem toStepSucc.exists_root {n} {f : Polynomial (Step k n)} (hfm : f.Monic)
    (hfi : Irreducible f) : ∃ x : Step k (n + 1), f.eval₂ (toStepSucc k n) x = 0 :=
  @AdjoinMonic.exists_root _ (Step.field k n) _ hfm hfi
#align algebraic_closure.to_step_succ.exists_root AlgebraicClosure.toStepSucc.exists_root

/-- The canonical ring homomorphism to a step with a greater index. -/
def toStepOfLe (m n : ℕ) (h : m ≤ n) : Step k m →+* Step k n
    where
  toFun := Nat.leRecOn h fun n => toStepSucc k n
  map_one' := by
    induction' h with n h ih; · exact Nat.leRecOn_self 1
    rw [Nat.leRecOn_succ h, ih, RingHom.map_one]
  map_mul' x y := by
    induction' h with n h ih; · simp_rw [Nat.leRecOn_self]
    simp_rw [Nat.leRecOn_succ h, ih, RingHom.map_mul]
  map_zero' := by
    induction' h with n h ih; · exact Nat.leRecOn_self 0
    rw [Nat.leRecOn_succ h, ih, RingHom.map_zero]
  map_add' x y := by
    induction' h with n h ih; · simp_rw [Nat.leRecOn_self]
    simp_rw [Nat.leRecOn_succ h, ih, RingHom.map_add]
#align algebraic_closure.to_step_of_le AlgebraicClosure.toStepOfLe

@[simp]
theorem coe_toStepOfLe (m n : ℕ) (h : m ≤ n) :
    (toStepOfLe k m n h : Step k m → Step k n) = Nat.leRecOn h fun n => toStepSucc k n :=
  rfl
#align algebraic_closure.coe_to_step_of_le AlgebraicClosure.coe_toStepOfLe

instance Step.algebra (n) : Algebra k (Step k n) :=
  (toStepOfLe k 0 n n.zero_le).toAlgebra
#align algebraic_closure.step.algebra AlgebraicClosure.Step.algebra

instance Step.scalar_tower (n) : IsScalarTower k (Step k n) (Step k (n + 1)) :=
  IsScalarTower.of_algebraMap_eq fun z =>
    @Nat.leRecOn_succ (Step k) 0 n n.zero_le (n + 1).zero_le (fun n => toStepSucc k n) z
#align algebraic_closure.step.scalar_tower AlgebraicClosure.Step.scalar_tower

theorem Step.isIntegral (n) : ∀ z : Step k n, IsIntegral k z :=
  Nat.recOn n (fun z => isIntegral_algebraMap) fun n ih z =>
    isIntegral_trans ih _ (AdjoinMonic.isIntegral (Step k n) z : _)
#align algebraic_closure.step.is_integral AlgebraicClosure.Step.isIntegral

instance toStepOfLe.directedSystem : DirectedSystem (Step k) fun i j h => toStepOfLe k i j h :=
  ⟨fun i x h => Nat.leRecOn_self x, fun i₁ i₂ i₃ h₁₂ h₂₃ x => (Nat.leRecOn_trans h₁₂ h₂₃ x).symm⟩
#align algebraic_closure.to_step_of_le.directed_system AlgebraicClosure.toStepOfLe.directedSystem

end AlgebraicClosure

/-- The canonical algebraic closure of a field, the direct limit of adding roots to the field for
each polynomial over the field. -/
def AlgebraicClosure : Type u :=
  Ring.DirectLimit (AlgebraicClosure.Step k) fun i j h => AlgebraicClosure.toStepOfLe k i j h
#align algebraic_closure AlgebraicClosure

namespace AlgebraicClosure

instance : Field (AlgebraicClosure k) :=
  Field.DirectLimit.field _ _

instance : Inhabited (AlgebraicClosure k) :=
  ⟨37⟩

/-- The canonical ring embedding from the `n`th step to the algebraic closure. -/
def ofStep (n : ℕ) : Step k n →+* AlgebraicClosure k :=
  Ring.DirectLimit.of _ _ _
#align algebraic_closure.of_step AlgebraicClosure.ofStep

instance algebraOfStep (n) : Algebra (Step k n) (AlgebraicClosure k) :=
  (ofStep k n).toAlgebra
#align algebraic_closure.algebra_of_step AlgebraicClosure.algebraOfStep

theorem ofStep_succ (n : ℕ) : (ofStep k (n + 1)).comp (toStepSucc k n) = ofStep k n :=
  RingHom.ext fun x =>
    show Ring.DirectLimit.of (Step k) (fun i j h => toStepOfLe k i j h) _ _ = _
      by
      convert Ring.DirectLimit.of_f n.le_succ x
      ext x
      exact (Nat.leRecOn_succ' x).symm
#align algebraic_closure.of_step_succ AlgebraicClosure.ofStep_succ

theorem exists_ofStep (z : AlgebraicClosure k) : ∃ n x, ofStep k n x = z :=
  Ring.DirectLimit.exists_of z
#align algebraic_closure.exists_of_step AlgebraicClosure.exists_ofStep

-- slow
theorem exists_root {f : Polynomial (AlgebraicClosure k)} (hfm : f.Monic) (hfi : Irreducible f) :
    ∃ x : AlgebraicClosure k, f.eval x = 0 :=
  by
  have : ∃ n p, Polynomial.map (of_step k n) p = f := by
    convert Ring.DirectLimit.Polynomial.exists_of f
  obtain ⟨n, p, rfl⟩ := this
  rw [monic_map_iff] at hfm
  have := hfm.irreducible_of_irreducible_map (of_step k n) p hfi
  obtain ⟨x, hx⟩ := to_step_succ.exists_root k hfm this
  refine' ⟨of_step k (n + 1) x, _⟩
  rw [← of_step_succ k n, eval_map, ← hom_eval₂, hx, RingHom.map_zero]
#align algebraic_closure.exists_root AlgebraicClosure.exists_root

instance : IsAlgClosed (AlgebraicClosure k) :=
  IsAlgClosed.of_exists_root _ fun f => exists_root k

instance {R : Type _} [CommSemiring R] [alg : Algebra R k] : Algebra R (AlgebraicClosure k) :=
  ((ofStep k 0).comp (@algebraMap _ _ _ _ alg)).toAlgebra

theorem algebraMap_def {R : Type _} [CommSemiring R] [alg : Algebra R k] :
    algebraMap R (AlgebraicClosure k) = (ofStep k 0 : k →+* _).comp (@algebraMap _ _ _ _ alg) :=
  rfl
#align algebraic_closure.algebra_map_def AlgebraicClosure.algebraMap_def

instance {R S : Type _} [CommSemiring R] [CommSemiring S] [Algebra R S] [Algebra S k] [Algebra R k]
    [IsScalarTower R S k] : IsScalarTower R S (AlgebraicClosure k) :=
  IsScalarTower.of_algebraMap_eq fun x =>
    RingHom.congr_arg _ (IsScalarTower.algebraMap_apply R S k x : _)

/-- Canonical algebra embedding from the `n`th step to the algebraic closure. -/
def ofStepHom (n) : Step k n →ₐ[k] AlgebraicClosure k :=
  { ofStep k n with commutes' := fun x => Ring.DirectLimit.of_f n.zero_le x }
#align algebraic_closure.of_step_hom AlgebraicClosure.ofStepHom

theorem isAlgebraic : Algebra.IsAlgebraic k (AlgebraicClosure k) := fun z =>
  isAlgebraic_iff_isIntegral.2 <|
    let ⟨n, x, hx⟩ := exists_ofStep k z
    hx ▸ map_isIntegral (ofStepHom k n) (Step.isIntegral k n x)
#align algebraic_closure.is_algebraic AlgebraicClosure.isAlgebraic

instance : IsAlgClosure k (AlgebraicClosure k) :=
  ⟨AlgebraicClosure.isAlgClosed k, isAlgebraic k⟩

end AlgebraicClosure

