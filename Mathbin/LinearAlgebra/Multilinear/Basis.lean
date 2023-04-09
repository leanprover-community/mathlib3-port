/-
Copyright (c) 2021 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers

! This file was ported from Lean 3 source module linear_algebra.multilinear.basis
! leanprover-community/mathlib commit 19cb3751e5e9b3d97adb51023949c50c13b5fdfd
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Basis
import Mathbin.LinearAlgebra.Multilinear.Basic

/-!
# Multilinear maps in relation to bases.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves lemmas about the action of multilinear maps on basis vectors.

## TODO

 * Refactor the proofs in terms of bases of tensor products, once there is an equivalent of
   `basis.tensor_product` for `pi_tensor_product`.

-/


open MultilinearMap

variable {R : Type _} {ι : Type _} {n : ℕ} {M : Fin n → Type _} {M₂ : Type _} {M₃ : Type _}

variable [CommSemiring R] [AddCommMonoid M₂] [AddCommMonoid M₃] [∀ i, AddCommMonoid (M i)]

variable [∀ i, Module R (M i)] [Module R M₂] [Module R M₃]

/- warning: basis.ext_multilinear_fin -> Basis.ext_multilinear_fin is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {n : Nat} {M : (Fin n) -> Type.{u2}} {M₂ : Type.{u3}} [_inst_1 : CommSemiring.{u1} R] [_inst_2 : AddCommMonoid.{u3} M₂] [_inst_4 : forall (i : Fin n), AddCommMonoid.{u2} (M i)] [_inst_5 : forall (i : Fin n), Module.{u1, u2} R (M i) (CommSemiring.toSemiring.{u1} R _inst_1) (_inst_4 i)] [_inst_6 : Module.{u1, u3} R M₂ (CommSemiring.toSemiring.{u1} R _inst_1) _inst_2] {f : MultilinearMap.{u1, u2, u3, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6} {g : MultilinearMap.{u1, u2, u3, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6} {ι₁ : (Fin n) -> Type.{u4}} (e : forall (i : Fin n), Basis.{u4, u1, u2} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u1} R _inst_1) (_inst_4 i) (_inst_5 i)), (forall (v : forall (i : Fin n), ι₁ i), Eq.{succ u3} M₂ (coeFn.{max 1 (succ u2) (succ u3), max (succ u2) (succ u3)} (MultilinearMap.{u1, u2, u3, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6) (fun (f : MultilinearMap.{u1, u2, u3, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6) => (forall (i : Fin n), M i) -> M₂) (MultilinearMap.hasCoeToFun.{u1, u2, u3, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6) f (fun (i : Fin n) => coeFn.{max (succ u4) (succ u1) (succ u2), max (succ u4) (succ u2)} (Basis.{u4, u1, u2} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u1} R _inst_1) (_inst_4 i) (_inst_5 i)) (fun (_x : Basis.{u4, u1, u2} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u1} R _inst_1) (_inst_4 i) (_inst_5 i)) => (ι₁ i) -> (M i)) (FunLike.hasCoeToFun.{max (succ u4) (succ u1) (succ u2), succ u4, succ u2} (Basis.{u4, u1, u2} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u1} R _inst_1) (_inst_4 i) (_inst_5 i)) (ι₁ i) (fun (_x : ι₁ i) => M i) (Basis.funLike.{u4, u1, u2} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u1} R _inst_1) (_inst_4 i) (_inst_5 i))) (e i) (v i))) (coeFn.{max 1 (succ u2) (succ u3), max (succ u2) (succ u3)} (MultilinearMap.{u1, u2, u3, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6) (fun (f : MultilinearMap.{u1, u2, u3, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6) => (forall (i : Fin n), M i) -> M₂) (MultilinearMap.hasCoeToFun.{u1, u2, u3, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6) g (fun (i : Fin n) => coeFn.{max (succ u4) (succ u1) (succ u2), max (succ u4) (succ u2)} (Basis.{u4, u1, u2} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u1} R _inst_1) (_inst_4 i) (_inst_5 i)) (fun (_x : Basis.{u4, u1, u2} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u1} R _inst_1) (_inst_4 i) (_inst_5 i)) => (ι₁ i) -> (M i)) (FunLike.hasCoeToFun.{max (succ u4) (succ u1) (succ u2), succ u4, succ u2} (Basis.{u4, u1, u2} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u1} R _inst_1) (_inst_4 i) (_inst_5 i)) (ι₁ i) (fun (_x : ι₁ i) => M i) (Basis.funLike.{u4, u1, u2} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u1} R _inst_1) (_inst_4 i) (_inst_5 i))) (e i) (v i)))) -> (Eq.{max 1 (succ u2) (succ u3)} (MultilinearMap.{u1, u2, u3, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6) f g)
but is expected to have type
  forall {R : Type.{u4}} {n : Nat} {M : (Fin n) -> Type.{u3}} {M₂ : Type.{u2}} [_inst_1 : CommSemiring.{u4} R] [_inst_2 : AddCommMonoid.{u2} M₂] [_inst_4 : forall (i : Fin n), AddCommMonoid.{u3} (M i)] [_inst_5 : forall (i : Fin n), Module.{u4, u3} R (M i) (CommSemiring.toSemiring.{u4} R _inst_1) (_inst_4 i)] [_inst_6 : Module.{u4, u2} R M₂ (CommSemiring.toSemiring.{u4} R _inst_1) _inst_2] {f : MultilinearMap.{u4, u3, u2, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6} {g : MultilinearMap.{u4, u3, u2, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6} {ι₁ : (Fin n) -> Type.{u1}} (e : forall (i : Fin n), Basis.{u1, u4, u3} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u4} R _inst_1) (_inst_4 i) (_inst_5 i)), (forall (v : forall (i : Fin n), ι₁ i), Eq.{succ u2} ((fun (x._@.Mathlib.LinearAlgebra.Multilinear.Basic._hyg.419 : forall (i : Fin n), M i) => M₂) (fun (i : Fin n) => FunLike.coe.{max (max (succ u4) (succ u3)) (succ u1), succ u1, succ u3} (Basis.{u1, u4, u3} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u4} R _inst_1) (_inst_4 i) (_inst_5 i)) (ι₁ i) (fun (a : ι₁ i) => (fun (x._@.Mathlib.LinearAlgebra.Basis._hyg.548 : ι₁ i) => M i) a) (Basis.funLike.{u1, u4, u3} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u4} R _inst_1) (_inst_4 i) (_inst_5 i)) (e i) (v i))) (FunLike.coe.{max (succ u3) (succ u2), succ u3, succ u2} (MultilinearMap.{u4, u3, u2, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6) (forall (i : Fin n), M i) (fun (f : forall (i : Fin n), M i) => (fun (x._@.Mathlib.LinearAlgebra.Multilinear.Basic._hyg.419 : forall (i : Fin n), M i) => M₂) f) (MultilinearMap.instFunLikeMultilinearMapForAll.{u4, u3, u2, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6) f (fun (i : Fin n) => FunLike.coe.{max (max (succ u4) (succ u3)) (succ u1), succ u1, succ u3} (Basis.{u1, u4, u3} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u4} R _inst_1) (_inst_4 i) (_inst_5 i)) (ι₁ i) (fun (_x : ι₁ i) => (fun (x._@.Mathlib.LinearAlgebra.Basis._hyg.548 : ι₁ i) => M i) _x) (Basis.funLike.{u1, u4, u3} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u4} R _inst_1) (_inst_4 i) (_inst_5 i)) (e i) (v i))) (FunLike.coe.{max (succ u3) (succ u2), succ u3, succ u2} (MultilinearMap.{u4, u3, u2, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6) (forall (i : Fin n), M i) (fun (f : forall (i : Fin n), M i) => (fun (x._@.Mathlib.LinearAlgebra.Multilinear.Basic._hyg.419 : forall (i : Fin n), M i) => M₂) f) (MultilinearMap.instFunLikeMultilinearMapForAll.{u4, u3, u2, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6) g (fun (i : Fin n) => FunLike.coe.{max (max (succ u4) (succ u3)) (succ u1), succ u1, succ u3} (Basis.{u1, u4, u3} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u4} R _inst_1) (_inst_4 i) (_inst_5 i)) (ι₁ i) (fun (_x : ι₁ i) => (fun (x._@.Mathlib.LinearAlgebra.Basis._hyg.548 : ι₁ i) => M i) _x) (Basis.funLike.{u1, u4, u3} (ι₁ i) R (M i) (CommSemiring.toSemiring.{u4} R _inst_1) (_inst_4 i) (_inst_5 i)) (e i) (v i)))) -> (Eq.{max (succ u3) (succ u2)} (MultilinearMap.{u4, u3, u2, 0} R (Fin n) M M₂ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : Fin n) => _inst_4 i) _inst_2 (fun (i : Fin n) => _inst_5 i) _inst_6) f g)
Case conversion may be inaccurate. Consider using '#align basis.ext_multilinear_fin Basis.ext_multilinear_finₓ'. -/
/-- Two multilinear maps indexed by `fin n` are equal if they are equal when all arguments are
basis vectors. -/
theorem Basis.ext_multilinear_fin {f g : MultilinearMap R M M₂} {ι₁ : Fin n → Type _}
    (e : ∀ i, Basis (ι₁ i) R (M i))
    (h : ∀ v : ∀ i, ι₁ i, (f fun i => e i (v i)) = g fun i => e i (v i)) : f = g :=
  by
  induction' n with m hm
  · ext x
    convert h finZeroElim
  · apply Function.LeftInverse.injective uncurry_curry_left
    refine' Basis.ext (e 0) _
    intro i
    apply hm (Fin.tail e)
    intro j
    convert h (Fin.cons i j)
    iterate 2 
      rw [curry_left_apply]
      congr 1 with x
      refine' Fin.cases rfl (fun x => _) x
      dsimp [Fin.tail]
      rw [Fin.cons_succ, Fin.cons_succ]
#align basis.ext_multilinear_fin Basis.ext_multilinear_fin

/- warning: basis.ext_multilinear -> Basis.ext_multilinear is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {ι : Type.{u2}} {M₂ : Type.{u3}} {M₃ : Type.{u4}} [_inst_1 : CommSemiring.{u1} R] [_inst_2 : AddCommMonoid.{u3} M₂] [_inst_3 : AddCommMonoid.{u4} M₃] [_inst_6 : Module.{u1, u3} R M₂ (CommSemiring.toSemiring.{u1} R _inst_1) _inst_2] [_inst_7 : Module.{u1, u4} R M₃ (CommSemiring.toSemiring.{u1} R _inst_1) _inst_3] [_inst_8 : Finite.{succ u2} ι] {f : MultilinearMap.{u1, u3, u4, u2} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7} {g : MultilinearMap.{u1, u3, u4, u2} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7} {ι₁ : Type.{u5}} (e : Basis.{u5, u1, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u1} R _inst_1) _inst_2 _inst_6), (forall (v : ι -> ι₁), Eq.{succ u4} M₃ (coeFn.{max (succ u2) (succ u3) (succ u4), max (max (succ u2) (succ u3)) (succ u4)} (MultilinearMap.{u1, u3, u4, u2} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7) (fun (f : MultilinearMap.{u1, u3, u4, u2} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7) => (ι -> M₂) -> M₃) (MultilinearMap.hasCoeToFun.{u1, u3, u4, u2} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7) f (fun (i : ι) => coeFn.{max (succ u5) (succ u1) (succ u3), max (succ u5) (succ u3)} (Basis.{u5, u1, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u1} R _inst_1) _inst_2 _inst_6) (fun (_x : Basis.{u5, u1, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u1} R _inst_1) _inst_2 _inst_6) => ι₁ -> M₂) (FunLike.hasCoeToFun.{max (succ u5) (succ u1) (succ u3), succ u5, succ u3} (Basis.{u5, u1, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u1} R _inst_1) _inst_2 _inst_6) ι₁ (fun (_x : ι₁) => M₂) (Basis.funLike.{u5, u1, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u1} R _inst_1) _inst_2 _inst_6)) e (v i))) (coeFn.{max (succ u2) (succ u3) (succ u4), max (max (succ u2) (succ u3)) (succ u4)} (MultilinearMap.{u1, u3, u4, u2} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7) (fun (f : MultilinearMap.{u1, u3, u4, u2} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7) => (ι -> M₂) -> M₃) (MultilinearMap.hasCoeToFun.{u1, u3, u4, u2} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7) g (fun (i : ι) => coeFn.{max (succ u5) (succ u1) (succ u3), max (succ u5) (succ u3)} (Basis.{u5, u1, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u1} R _inst_1) _inst_2 _inst_6) (fun (_x : Basis.{u5, u1, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u1} R _inst_1) _inst_2 _inst_6) => ι₁ -> M₂) (FunLike.hasCoeToFun.{max (succ u5) (succ u1) (succ u3), succ u5, succ u3} (Basis.{u5, u1, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u1} R _inst_1) _inst_2 _inst_6) ι₁ (fun (_x : ι₁) => M₂) (Basis.funLike.{u5, u1, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u1} R _inst_1) _inst_2 _inst_6)) e (v i)))) -> (Eq.{max (succ u2) (succ u3) (succ u4)} (MultilinearMap.{u1, u3, u4, u2} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u1} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7) f g)
but is expected to have type
  forall {R : Type.{u4}} {ι : Type.{u5}} {M₂ : Type.{u3}} {M₃ : Type.{u2}} [_inst_1 : CommSemiring.{u4} R] [_inst_2 : AddCommMonoid.{u3} M₂] [_inst_3 : AddCommMonoid.{u2} M₃] [_inst_6 : Module.{u4, u3} R M₂ (CommSemiring.toSemiring.{u4} R _inst_1) _inst_2] [_inst_7 : Module.{u4, u2} R M₃ (CommSemiring.toSemiring.{u4} R _inst_1) _inst_3] [_inst_8 : Finite.{succ u5} ι] {f : MultilinearMap.{u4, u3, u2, u5} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7} {g : MultilinearMap.{u4, u3, u2, u5} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7} {ι₁ : Type.{u1}} (e : Basis.{u1, u4, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u4} R _inst_1) _inst_2 _inst_6), (forall (v : ι -> ι₁), Eq.{succ u2} ((fun (x._@.Mathlib.LinearAlgebra.Multilinear.Basic._hyg.419 : ι -> M₂) => M₃) (fun (i : ι) => FunLike.coe.{max (max (succ u4) (succ u3)) (succ u1), succ u1, succ u3} (Basis.{u1, u4, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u4} R _inst_1) _inst_2 _inst_6) ι₁ (fun (a : ι₁) => (fun (x._@.Mathlib.LinearAlgebra.Basis._hyg.548 : ι₁) => M₂) a) (Basis.funLike.{u1, u4, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u4} R _inst_1) _inst_2 _inst_6) e (v i))) (FunLike.coe.{max (max (succ u5) (succ u3)) (succ u2), max (succ u5) (succ u3), succ u2} (MultilinearMap.{u4, u3, u2, u5} R ι (fun (x._@.Mathlib.LinearAlgebra.Multilinear.Basis._hyg.901 : ι) => M₂) M₃ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7) (ι -> M₂) (fun (f : ι -> M₂) => (fun (x._@.Mathlib.LinearAlgebra.Multilinear.Basic._hyg.419 : ι -> M₂) => M₃) f) (MultilinearMap.instFunLikeMultilinearMapForAll.{u4, u3, u2, u5} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7) f (fun (i : ι) => FunLike.coe.{max (max (succ u4) (succ u3)) (succ u1), succ u1, succ u3} (Basis.{u1, u4, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u4} R _inst_1) _inst_2 _inst_6) ι₁ (fun (_x : ι₁) => (fun (x._@.Mathlib.LinearAlgebra.Basis._hyg.548 : ι₁) => M₂) _x) (Basis.funLike.{u1, u4, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u4} R _inst_1) _inst_2 _inst_6) e (v i))) (FunLike.coe.{max (max (succ u5) (succ u3)) (succ u2), max (succ u5) (succ u3), succ u2} (MultilinearMap.{u4, u3, u2, u5} R ι (fun (x._@.Mathlib.LinearAlgebra.Multilinear.Basis._hyg.913 : ι) => M₂) M₃ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7) (ι -> M₂) (fun (f : ι -> M₂) => (fun (x._@.Mathlib.LinearAlgebra.Multilinear.Basic._hyg.419 : ι -> M₂) => M₃) f) (MultilinearMap.instFunLikeMultilinearMapForAll.{u4, u3, u2, u5} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7) g (fun (i : ι) => FunLike.coe.{max (max (succ u4) (succ u3)) (succ u1), succ u1, succ u3} (Basis.{u1, u4, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u4} R _inst_1) _inst_2 _inst_6) ι₁ (fun (_x : ι₁) => (fun (x._@.Mathlib.LinearAlgebra.Basis._hyg.548 : ι₁) => M₂) _x) (Basis.funLike.{u1, u4, u3} ι₁ R M₂ (CommSemiring.toSemiring.{u4} R _inst_1) _inst_2 _inst_6) e (v i)))) -> (Eq.{max (max (succ u5) (succ u3)) (succ u2)} (MultilinearMap.{u4, u3, u2, u5} R ι (fun (i : ι) => M₂) M₃ (CommSemiring.toSemiring.{u4} R _inst_1) (fun (i : ι) => _inst_2) _inst_3 (fun (i : ι) => _inst_6) _inst_7) f g)
Case conversion may be inaccurate. Consider using '#align basis.ext_multilinear Basis.ext_multilinearₓ'. -/
/-- Two multilinear maps indexed by a `fintype` are equal if they are equal when all arguments
are basis vectors. Unlike `basis.ext_multilinear_fin`, this only uses a single basis; a
dependently-typed version would still be true, but the proof would need a dependently-typed
version of `dom_dom_congr`. -/
theorem Basis.ext_multilinear [Finite ι] {f g : MultilinearMap R (fun i : ι => M₂) M₃} {ι₁ : Type _}
    (e : Basis ι₁ R M₂) (h : ∀ v : ι → ι₁, (f fun i => e (v i)) = g fun i => e (v i)) : f = g :=
  by
  cases nonempty_fintype ι
  exact
    (dom_dom_congr_eq_iff (Fintype.equivFin ι) f g).mp
      (Basis.ext_multilinear_fin (fun i => e) fun i => h (i ∘ _))
#align basis.ext_multilinear Basis.ext_multilinear

