/-
Copyright (c) 2020 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module topology.algebra.module.multilinear
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Algebra.Module.Basic
import Mathbin.LinearAlgebra.Multilinear.Basic

/-!
# Continuous multilinear maps

We define continuous multilinear maps as maps from `Π(i : ι), M₁ i` to `M₂` which are multilinear
and continuous, by extending the space of multilinear maps with a continuity assumption.
Here, `M₁ i` and `M₂` are modules over a ring `R`, and `ι` is an arbitrary type, and all these
spaces are also topological spaces.

## Main definitions

* `continuous_multilinear_map R M₁ M₂` is the space of continuous multilinear maps from
  `Π(i : ι), M₁ i` to `M₂`. We show that it is an `R`-module.

## Implementation notes

We mostly follow the API of multilinear maps.

## Notation

We introduce the notation `M [×n]→L[R] M'` for the space of continuous `n`-multilinear maps from
`M^n` to `M'`. This is a particular case of the general notion (where we allow varying dependent
types as the arguments of our continuous multilinear maps), but arguably the most important one,
especially when defining iterated derivatives.
-/


open Function Fin Set

open BigOperators

universe u v w w₁ w₁' w₂ w₃ w₄

variable {R : Type u} {ι : Type v} {n : ℕ} {M : Fin n.succ → Type w} {M₁ : ι → Type w₁}
  {M₁' : ι → Type w₁'} {M₂ : Type w₂} {M₃ : Type w₃} {M₄ : Type w₄} [DecidableEq ι]

/-- Continuous multilinear maps over the ring `R`, from `Πi, M₁ i` to `M₂` where `M₁ i` and `M₂`
are modules over `R` with a topological structure. In applications, there will be compatibility
conditions between the algebraic and the topological structures, but this is not needed for the
definition. -/
structure ContinuousMultilinearMap (R : Type u) {ι : Type v} (M₁ : ι → Type w₁) (M₂ : Type w₂)
  [DecidableEq ι] [Semiring R] [∀ i, AddCommMonoid (M₁ i)] [AddCommMonoid M₂] [∀ i, Module R (M₁ i)]
  [Module R M₂] [∀ i, TopologicalSpace (M₁ i)] [TopologicalSpace M₂] extends
  MultilinearMap R M₁ M₂ where
  cont : Continuous to_fun
#align continuous_multilinear_map ContinuousMultilinearMap

-- mathport name: «expr [× ]→L[ ] »
notation:25 M "[×" n "]→L[" R "] " M' => ContinuousMultilinearMap R (fun i : Fin n => M) M'

namespace ContinuousMultilinearMap

section Semiring

variable [Semiring R] [∀ i, AddCommMonoid (M i)] [∀ i, AddCommMonoid (M₁ i)]
  [∀ i, AddCommMonoid (M₁' i)] [AddCommMonoid M₂] [AddCommMonoid M₃] [AddCommMonoid M₄]
  [∀ i, Module R (M i)] [∀ i, Module R (M₁ i)] [∀ i, Module R (M₁' i)] [Module R M₂] [Module R M₃]
  [Module R M₄] [∀ i, TopologicalSpace (M i)] [∀ i, TopologicalSpace (M₁ i)]
  [∀ i, TopologicalSpace (M₁' i)] [TopologicalSpace M₂] [TopologicalSpace M₃] [TopologicalSpace M₄]
  (f f' : ContinuousMultilinearMap R M₁ M₂)

instance : CoeFun (ContinuousMultilinearMap R M₁ M₂) fun _ => (∀ i, M₁ i) → M₂ :=
  ⟨fun f => f.toFun⟩

/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
  because it is a composition of multiple projections. -/
def Simps.apply (L₁ : ContinuousMultilinearMap R M₁ M₂) (v : ∀ i, M₁ i) : M₂ :=
  L₁ v
#align continuous_multilinear_map.simps.apply ContinuousMultilinearMap.Simps.apply

initialize_simps_projections ContinuousMultilinearMap (-toMultilinearMap,
  to_multilinear_map_to_fun → apply)

@[continuity]
theorem coe_continuous : Continuous (f : (∀ i, M₁ i) → M₂) :=
  f.cont
#align continuous_multilinear_map.coe_continuous ContinuousMultilinearMap.coe_continuous

@[simp]
theorem coe_coe : (f.toMultilinearMap : (∀ i, M₁ i) → M₂) = f :=
  rfl
#align continuous_multilinear_map.coe_coe ContinuousMultilinearMap.coe_coe

theorem to_multilinear_map_inj :
    Function.Injective
      (ContinuousMultilinearMap.toMultilinearMap :
        ContinuousMultilinearMap R M₁ M₂ → MultilinearMap R M₁ M₂)
  | ⟨f, hf⟩, ⟨g, hg⟩, rfl => rfl
#align
  continuous_multilinear_map.to_multilinear_map_inj ContinuousMultilinearMap.to_multilinear_map_inj

@[ext]
theorem ext {f f' : ContinuousMultilinearMap R M₁ M₂} (H : ∀ x, f x = f' x) : f = f' :=
  to_multilinear_map_inj <| MultilinearMap.ext H
#align continuous_multilinear_map.ext ContinuousMultilinearMap.ext

theorem ext_iff {f f' : ContinuousMultilinearMap R M₁ M₂} : f = f' ↔ ∀ x, f x = f' x := by
  rw [← to_multilinear_map_inj.eq_iff, MultilinearMap.ext_iff] <;> rfl
#align continuous_multilinear_map.ext_iff ContinuousMultilinearMap.ext_iff

@[simp]
theorem map_add (m : ∀ i, M₁ i) (i : ι) (x y : M₁ i) :
    f (update m i (x + y)) = f (update m i x) + f (update m i y) :=
  f.map_add' m i x y
#align continuous_multilinear_map.map_add ContinuousMultilinearMap.map_add

@[simp]
theorem map_smul (m : ∀ i, M₁ i) (i : ι) (c : R) (x : M₁ i) :
    f (update m i (c • x)) = c • f (update m i x) :=
  f.map_smul' m i c x
#align continuous_multilinear_map.map_smul ContinuousMultilinearMap.map_smul

theorem map_coord_zero {m : ∀ i, M₁ i} (i : ι) (h : m i = 0) : f m = 0 :=
  f.toMultilinearMap.map_coord_zero i h
#align continuous_multilinear_map.map_coord_zero ContinuousMultilinearMap.map_coord_zero

@[simp]
theorem map_zero [Nonempty ι] : f 0 = 0 :=
  f.toMultilinearMap.map_zero
#align continuous_multilinear_map.map_zero ContinuousMultilinearMap.map_zero

instance : Zero (ContinuousMultilinearMap R M₁ M₂) :=
  ⟨{ (0 : MultilinearMap R M₁ M₂) with cont := continuous_const }⟩

instance : Inhabited (ContinuousMultilinearMap R M₁ M₂) :=
  ⟨0⟩

@[simp]
theorem zero_apply (m : ∀ i, M₁ i) : (0 : ContinuousMultilinearMap R M₁ M₂) m = 0 :=
  rfl
#align continuous_multilinear_map.zero_apply ContinuousMultilinearMap.zero_apply

@[simp]
theorem to_multilinear_map_zero : (0 : ContinuousMultilinearMap R M₁ M₂).toMultilinearMap = 0 :=
  rfl
#align
  continuous_multilinear_map.to_multilinear_map_zero ContinuousMultilinearMap.to_multilinear_map_zero

section SMul

variable {R' R'' A : Type _} [Monoid R'] [Monoid R''] [Semiring A] [∀ i, Module A (M₁ i)]
  [Module A M₂] [DistribMulAction R' M₂] [HasContinuousConstSmul R' M₂] [SMulCommClass A R' M₂]
  [DistribMulAction R'' M₂] [HasContinuousConstSmul R'' M₂] [SMulCommClass A R'' M₂]

instance : SMul R' (ContinuousMultilinearMap A M₁ M₂) :=
  ⟨fun c f => { c • f.toMultilinearMap with cont := f.cont.const_smul c }⟩

@[simp]
theorem smul_apply (f : ContinuousMultilinearMap A M₁ M₂) (c : R') (m : ∀ i, M₁ i) :
    (c • f) m = c • f m :=
  rfl
#align continuous_multilinear_map.smul_apply ContinuousMultilinearMap.smul_apply

@[simp]
theorem to_multilinear_map_smul (c : R') (f : ContinuousMultilinearMap A M₁ M₂) :
    (c • f).toMultilinearMap = c • f.toMultilinearMap :=
  rfl
#align
  continuous_multilinear_map.to_multilinear_map_smul ContinuousMultilinearMap.to_multilinear_map_smul

instance [SMulCommClass R' R'' M₂] : SMulCommClass R' R'' (ContinuousMultilinearMap A M₁ M₂) :=
  ⟨fun c₁ c₂ f => ext fun x => smul_comm _ _ _⟩

instance [SMul R' R''] [IsScalarTower R' R'' M₂] :
    IsScalarTower R' R'' (ContinuousMultilinearMap A M₁ M₂) :=
  ⟨fun c₁ c₂ f => ext fun x => smul_assoc _ _ _⟩

instance [DistribMulAction R'ᵐᵒᵖ M₂] [IsCentralScalar R' M₂] :
    IsCentralScalar R' (ContinuousMultilinearMap A M₁ M₂) :=
  ⟨fun c₁ f => ext fun x => op_smul_eq_smul _ _⟩

instance : MulAction R' (ContinuousMultilinearMap A M₁ M₂) :=
  Function.Injective.mulAction toMultilinearMap to_multilinear_map_inj fun _ _ => rfl

end SMul

section HasContinuousAdd

variable [HasContinuousAdd M₂]

instance : Add (ContinuousMultilinearMap R M₁ M₂) :=
  ⟨fun f f' => ⟨f.toMultilinearMap + f'.toMultilinearMap, f.cont.add f'.cont⟩⟩

@[simp]
theorem add_apply (m : ∀ i, M₁ i) : (f + f') m = f m + f' m :=
  rfl
#align continuous_multilinear_map.add_apply ContinuousMultilinearMap.add_apply

@[simp]
theorem to_multilinear_map_add (f g : ContinuousMultilinearMap R M₁ M₂) :
    (f + g).toMultilinearMap = f.toMultilinearMap + g.toMultilinearMap :=
  rfl
#align
  continuous_multilinear_map.to_multilinear_map_add ContinuousMultilinearMap.to_multilinear_map_add

instance addCommMonoid : AddCommMonoid (ContinuousMultilinearMap R M₁ M₂) :=
  to_multilinear_map_inj.AddCommMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl
#align continuous_multilinear_map.add_comm_monoid ContinuousMultilinearMap.addCommMonoid

/-- Evaluation of a `continuous_multilinear_map` at a vector as an `add_monoid_hom`. -/
def applyAddHom (m : ∀ i, M₁ i) : ContinuousMultilinearMap R M₁ M₂ →+ M₂ :=
  ⟨fun f => f m, rfl, fun _ _ => rfl⟩
#align continuous_multilinear_map.apply_add_hom ContinuousMultilinearMap.applyAddHom

@[simp]
theorem sum_apply {α : Type _} (f : α → ContinuousMultilinearMap R M₁ M₂) (m : ∀ i, M₁ i)
    {s : Finset α} : (∑ a in s, f a) m = ∑ a in s, f a m :=
  (applyAddHom m).map_sum f s
#align continuous_multilinear_map.sum_apply ContinuousMultilinearMap.sum_apply

end HasContinuousAdd

/-- If `f` is a continuous multilinear map, then `f.to_continuous_linear_map m i` is the continuous
linear map obtained by fixing all coordinates but `i` equal to those of `m`, and varying the
`i`-th coordinate. -/
def toContinuousLinearMap (m : ∀ i, M₁ i) (i : ι) : M₁ i →L[R] M₂ :=
  { f.toMultilinearMap.toLinearMap m i with
    cont := f.cont.comp (continuous_const.update i continuous_id) }
#align
  continuous_multilinear_map.to_continuous_linear_map ContinuousMultilinearMap.toContinuousLinearMap

/-- The cartesian product of two continuous multilinear maps, as a continuous multilinear map. -/
def prod (f : ContinuousMultilinearMap R M₁ M₂) (g : ContinuousMultilinearMap R M₁ M₃) :
    ContinuousMultilinearMap R M₁ (M₂ × M₃) :=
  { f.toMultilinearMap.Prod g.toMultilinearMap with cont := f.cont.prod_mk g.cont }
#align continuous_multilinear_map.prod ContinuousMultilinearMap.prod

@[simp]
theorem prod_apply (f : ContinuousMultilinearMap R M₁ M₂) (g : ContinuousMultilinearMap R M₁ M₃)
    (m : ∀ i, M₁ i) : (f.Prod g) m = (f m, g m) :=
  rfl
#align continuous_multilinear_map.prod_apply ContinuousMultilinearMap.prod_apply

/-- Combine a family of continuous multilinear maps with the same domain and codomains `M' i` into a
continuous multilinear map taking values in the space of functions `Π i, M' i`. -/
def pi {ι' : Type _} {M' : ι' → Type _} [∀ i, AddCommMonoid (M' i)] [∀ i, TopologicalSpace (M' i)]
    [∀ i, Module R (M' i)] (f : ∀ i, ContinuousMultilinearMap R M₁ (M' i)) :
    ContinuousMultilinearMap R M₁ (∀ i, M' i)
    where
  cont := continuous_pi fun i => (f i).coe_continuous
  toMultilinearMap := MultilinearMap.pi fun i => (f i).toMultilinearMap
#align continuous_multilinear_map.pi ContinuousMultilinearMap.pi

@[simp]
theorem coe_pi {ι' : Type _} {M' : ι' → Type _} [∀ i, AddCommMonoid (M' i)]
    [∀ i, TopologicalSpace (M' i)] [∀ i, Module R (M' i)]
    (f : ∀ i, ContinuousMultilinearMap R M₁ (M' i)) : ⇑(pi f) = fun m j => f j m :=
  rfl
#align continuous_multilinear_map.coe_pi ContinuousMultilinearMap.coe_pi

theorem pi_apply {ι' : Type _} {M' : ι' → Type _} [∀ i, AddCommMonoid (M' i)]
    [∀ i, TopologicalSpace (M' i)] [∀ i, Module R (M' i)]
    (f : ∀ i, ContinuousMultilinearMap R M₁ (M' i)) (m : ∀ i, M₁ i) (j : ι') : pi f m j = f j m :=
  rfl
#align continuous_multilinear_map.pi_apply ContinuousMultilinearMap.pi_apply

section

variable (R M₂)

/-- The evaluation map from `ι → M₂` to `M₂` is multilinear at a given `i` when `ι` is subsingleton.
-/
@[simps toMultilinearMap apply]
def ofSubsingleton [Subsingleton ι] (i' : ι) : ContinuousMultilinearMap R (fun _ : ι => M₂) M₂
    where
  toMultilinearMap := MultilinearMap.ofSubsingleton R _ i'
  cont := continuous_apply _
#align continuous_multilinear_map.of_subsingleton ContinuousMultilinearMap.ofSubsingleton

variable (M₁) {M₂}

/-- The constant map is multilinear when `ι` is empty. -/
@[simps toMultilinearMap apply]
def constOfIsEmpty [IsEmpty ι] (m : M₂) : ContinuousMultilinearMap R M₁ M₂
    where
  toMultilinearMap := MultilinearMap.constOfIsEmpty R _ m
  cont := continuous_const
#align continuous_multilinear_map.const_of_is_empty ContinuousMultilinearMap.constOfIsEmpty

end

/-- If `g` is continuous multilinear and `f` is a collection of continuous linear maps,
then `g (f₁ m₁, ..., fₙ mₙ)` is again a continuous multilinear map, that we call
`g.comp_continuous_linear_map f`. -/
def compContinuousLinearMap (g : ContinuousMultilinearMap R M₁' M₄)
    (f : ∀ i : ι, M₁ i →L[R] M₁' i) : ContinuousMultilinearMap R M₁ M₄ :=
  { g.toMultilinearMap.compLinearMap fun i => (f i).toLinearMap with
    cont := g.cont.comp <| continuous_pi fun j => (f j).cont.comp <| continuous_apply _ }
#align
  continuous_multilinear_map.comp_continuous_linear_map ContinuousMultilinearMap.compContinuousLinearMap

@[simp]
theorem comp_continuous_linear_map_apply (g : ContinuousMultilinearMap R M₁' M₄)
    (f : ∀ i : ι, M₁ i →L[R] M₁' i) (m : ∀ i, M₁ i) :
    g.compContinuousLinearMap f m = g fun i => f i <| m i :=
  rfl
#align
  continuous_multilinear_map.comp_continuous_linear_map_apply ContinuousMultilinearMap.comp_continuous_linear_map_apply

/-- Composing a continuous multilinear map with a continuous linear map gives again a
continuous multilinear map. -/
def ContinuousLinearMap.compContinuousMultilinearMap (g : M₂ →L[R] M₃)
    (f : ContinuousMultilinearMap R M₁ M₂) : ContinuousMultilinearMap R M₁ M₃ :=
  { g.toLinearMap.compMultilinearMap f.toMultilinearMap with cont := g.cont.comp f.cont }
#align
  continuous_linear_map.comp_continuous_multilinear_map ContinuousLinearMap.compContinuousMultilinearMap

@[simp]
theorem ContinuousLinearMap.comp_continuous_multilinear_map_coe (g : M₂ →L[R] M₃)
    (f : ContinuousMultilinearMap R M₁ M₂) :
    (g.compContinuousMultilinearMap f : (∀ i, M₁ i) → M₃) =
      (g : M₂ → M₃) ∘ (f : (∀ i, M₁ i) → M₂) :=
  by
  ext m
  rfl
#align
  continuous_linear_map.comp_continuous_multilinear_map_coe ContinuousLinearMap.comp_continuous_multilinear_map_coe

/-- `continuous_multilinear_map.pi` as an `equiv`. -/
@[simps]
def piEquiv {ι' : Type _} {M' : ι' → Type _} [∀ i, AddCommMonoid (M' i)]
    [∀ i, TopologicalSpace (M' i)] [∀ i, Module R (M' i)] :
    (∀ i, ContinuousMultilinearMap R M₁ (M' i)) ≃ ContinuousMultilinearMap R M₁ (∀ i, M' i)
    where
  toFun := ContinuousMultilinearMap.pi
  invFun f i := (ContinuousLinearMap.proj i : _ →L[R] M' i).compContinuousMultilinearMap f
  left_inv f := by
    ext
    rfl
  right_inv f := by
    ext
    rfl
#align continuous_multilinear_map.pi_equiv ContinuousMultilinearMap.piEquiv

/-- In the specific case of continuous multilinear maps on spaces indexed by `fin (n+1)`, where one
can build an element of `Π(i : fin (n+1)), M i` using `cons`, one can express directly the
additivity of a multilinear map along the first variable. -/
theorem cons_add (f : ContinuousMultilinearMap R M M₂) (m : ∀ i : Fin n, M i.succ) (x y : M 0) :
    f (cons (x + y) m) = f (cons x m) + f (cons y m) :=
  f.toMultilinearMap.cons_add m x y
#align continuous_multilinear_map.cons_add ContinuousMultilinearMap.cons_add

/-- In the specific case of continuous multilinear maps on spaces indexed by `fin (n+1)`, where one
can build an element of `Π(i : fin (n+1)), M i` using `cons`, one can express directly the
multiplicativity of a multilinear map along the first variable. -/
theorem cons_smul (f : ContinuousMultilinearMap R M M₂) (m : ∀ i : Fin n, M i.succ) (c : R)
    (x : M 0) : f (cons (c • x) m) = c • f (cons x m) :=
  f.toMultilinearMap.cons_smul m c x
#align continuous_multilinear_map.cons_smul ContinuousMultilinearMap.cons_smul

theorem map_piecewise_add (m m' : ∀ i, M₁ i) (t : Finset ι) :
    f (t.piecewise (m + m') m') = ∑ s in t.powerset, f (s.piecewise m m') :=
  f.toMultilinearMap.map_piecewise_add _ _ _
#align continuous_multilinear_map.map_piecewise_add ContinuousMultilinearMap.map_piecewise_add

/-- Additivity of a continuous multilinear map along all coordinates at the same time,
writing `f (m + m')` as the sum  of `f (s.piecewise m m')` over all sets `s`. -/
theorem map_add_univ [Fintype ι] (m m' : ∀ i, M₁ i) :
    f (m + m') = ∑ s : Finset ι, f (s.piecewise m m') :=
  f.toMultilinearMap.map_add_univ _ _
#align continuous_multilinear_map.map_add_univ ContinuousMultilinearMap.map_add_univ

section ApplySum

open Fintype Finset

variable {α : ι → Type _} [Fintype ι] (g : ∀ i, α i → M₁ i) (A : ∀ i, Finset (α i))

/-- If `f` is continuous multilinear, then `f (Σ_{j₁ ∈ A₁} g₁ j₁, ..., Σ_{jₙ ∈ Aₙ} gₙ jₙ)` is the
sum of `f (g₁ (r 1), ..., gₙ (r n))` where `r` ranges over all functions with `r 1 ∈ A₁`, ...,
`r n ∈ Aₙ`. This follows from multilinearity by expanding successively with respect to each
coordinate. -/
theorem map_sum_finset : (f fun i => ∑ j in A i, g i j) = ∑ r in piFinset A, f fun i => g i (r i) :=
  f.toMultilinearMap.map_sum_finset _ _
#align continuous_multilinear_map.map_sum_finset ContinuousMultilinearMap.map_sum_finset

/-- If `f` is continuous multilinear, then `f (Σ_{j₁} g₁ j₁, ..., Σ_{jₙ} gₙ jₙ)` is the sum of
`f (g₁ (r 1), ..., gₙ (r n))` where `r` ranges over all functions `r`. This follows from
multilinearity by expanding successively with respect to each coordinate. -/
theorem map_sum [∀ i, Fintype (α i)] :
    (f fun i => ∑ j, g i j) = ∑ r : ∀ i, α i, f fun i => g i (r i) :=
  f.toMultilinearMap.map_sum _
#align continuous_multilinear_map.map_sum ContinuousMultilinearMap.map_sum

end ApplySum

section RestrictScalar

variable (R) {A : Type _} [Semiring A] [SMul R A] [∀ i : ι, Module A (M₁ i)] [Module A M₂]
  [∀ i, IsScalarTower R A (M₁ i)] [IsScalarTower R A M₂]

/-- Reinterpret an `A`-multilinear map as an `R`-multilinear map, if `A` is an algebra over `R`
and their actions on all involved modules agree with the action of `R` on `A`. -/
def restrictScalars (f : ContinuousMultilinearMap A M₁ M₂) : ContinuousMultilinearMap R M₁ M₂
    where
  toMultilinearMap := f.toMultilinearMap.restrictScalars R
  cont := f.cont
#align continuous_multilinear_map.restrict_scalars ContinuousMultilinearMap.restrictScalars

@[simp]
theorem coe_restrict_scalars (f : ContinuousMultilinearMap A M₁ M₂) : ⇑(f.restrictScalars R) = f :=
  rfl
#align continuous_multilinear_map.coe_restrict_scalars ContinuousMultilinearMap.coe_restrict_scalars

end RestrictScalar

end Semiring

section Ring

variable [Ring R] [∀ i, AddCommGroup (M₁ i)] [AddCommGroup M₂] [∀ i, Module R (M₁ i)] [Module R M₂]
  [∀ i, TopologicalSpace (M₁ i)] [TopologicalSpace M₂] (f f' : ContinuousMultilinearMap R M₁ M₂)

@[simp]
theorem map_sub (m : ∀ i, M₁ i) (i : ι) (x y : M₁ i) :
    f (update m i (x - y)) = f (update m i x) - f (update m i y) :=
  f.toMultilinearMap.map_sub _ _ _ _
#align continuous_multilinear_map.map_sub ContinuousMultilinearMap.map_sub

section TopologicalAddGroup

variable [TopologicalAddGroup M₂]

instance : Neg (ContinuousMultilinearMap R M₁ M₂) :=
  ⟨fun f => { -f.toMultilinearMap with cont := f.cont.neg }⟩

@[simp]
theorem neg_apply (m : ∀ i, M₁ i) : (-f) m = -f m :=
  rfl
#align continuous_multilinear_map.neg_apply ContinuousMultilinearMap.neg_apply

instance : Sub (ContinuousMultilinearMap R M₁ M₂) :=
  ⟨fun f g => { f.toMultilinearMap - g.toMultilinearMap with cont := f.cont.sub g.cont }⟩

@[simp]
theorem sub_apply (m : ∀ i, M₁ i) : (f - f') m = f m - f' m :=
  rfl
#align continuous_multilinear_map.sub_apply ContinuousMultilinearMap.sub_apply

instance : AddCommGroup (ContinuousMultilinearMap R M₁ M₂) :=
  to_multilinear_map_inj.AddCommGroup _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ _ => rfl

end TopologicalAddGroup

end Ring

section CommSemiring

variable [CommSemiring R] [∀ i, AddCommMonoid (M₁ i)] [AddCommMonoid M₂] [∀ i, Module R (M₁ i)]
  [Module R M₂] [∀ i, TopologicalSpace (M₁ i)] [TopologicalSpace M₂]
  (f : ContinuousMultilinearMap R M₁ M₂)

theorem map_piecewise_smul (c : ι → R) (m : ∀ i, M₁ i) (s : Finset ι) :
    f (s.piecewise (fun i => c i • m i) m) = (∏ i in s, c i) • f m :=
  f.toMultilinearMap.map_piecewise_smul _ _ _
#align continuous_multilinear_map.map_piecewise_smul ContinuousMultilinearMap.map_piecewise_smul

/-- Multiplicativity of a continuous multilinear map along all coordinates at the same time,
writing `f (λ i, c i • m i)` as `(∏ i, c i) • f m`. -/
theorem map_smul_univ [Fintype ι] (c : ι → R) (m : ∀ i, M₁ i) :
    (f fun i => c i • m i) = (∏ i, c i) • f m :=
  f.toMultilinearMap.map_smul_univ _ _
#align continuous_multilinear_map.map_smul_univ ContinuousMultilinearMap.map_smul_univ

end CommSemiring

section DistribMulAction

variable {R' R'' A : Type _} [Monoid R'] [Monoid R''] [Semiring A] [∀ i, AddCommMonoid (M₁ i)]
  [AddCommMonoid M₂] [∀ i, TopologicalSpace (M₁ i)] [TopologicalSpace M₂] [∀ i, Module A (M₁ i)]
  [Module A M₂] [DistribMulAction R' M₂] [HasContinuousConstSmul R' M₂] [SMulCommClass A R' M₂]
  [DistribMulAction R'' M₂] [HasContinuousConstSmul R'' M₂] [SMulCommClass A R'' M₂]

instance [HasContinuousAdd M₂] : DistribMulAction R' (ContinuousMultilinearMap A M₁ M₂) :=
  Function.Injective.distribMulAction
    ⟨toMultilinearMap, to_multilinear_map_zero, to_multilinear_map_add⟩ to_multilinear_map_inj
    fun _ _ => rfl

end DistribMulAction

section Module

variable {R' A : Type _} [Semiring R'] [Semiring A] [∀ i, AddCommMonoid (M₁ i)] [AddCommMonoid M₂]
  [∀ i, TopologicalSpace (M₁ i)] [TopologicalSpace M₂] [HasContinuousAdd M₂] [∀ i, Module A (M₁ i)]
  [Module A M₂] [Module R' M₂] [HasContinuousConstSmul R' M₂] [SMulCommClass A R' M₂]

/-- The space of continuous multilinear maps over an algebra over `R` is a module over `R`, for the
pointwise addition and scalar multiplication. -/
instance : Module R' (ContinuousMultilinearMap A M₁ M₂) :=
  Function.Injective.module _ ⟨toMultilinearMap, to_multilinear_map_zero, to_multilinear_map_add⟩
    to_multilinear_map_inj fun _ _ => rfl

/-- Linear map version of the map `to_multilinear_map` associating to a continuous multilinear map
the corresponding multilinear map. -/
@[simps]
def toMultilinearMapLinear : ContinuousMultilinearMap A M₁ M₂ →ₗ[R'] MultilinearMap A M₁ M₂
    where
  toFun := toMultilinearMap
  map_add' := to_multilinear_map_add
  map_smul' := to_multilinear_map_smul
#align
  continuous_multilinear_map.to_multilinear_map_linear ContinuousMultilinearMap.toMultilinearMapLinear

/-- `continuous_multilinear_map.pi` as a `linear_equiv`. -/
@[simps (config := { simpRhs := true })]
def piLinearEquiv {ι' : Type _} {M' : ι' → Type _} [∀ i, AddCommMonoid (M' i)]
    [∀ i, TopologicalSpace (M' i)] [∀ i, HasContinuousAdd (M' i)] [∀ i, Module R' (M' i)]
    [∀ i, Module A (M' i)] [∀ i, SMulCommClass A R' (M' i)]
    [∀ i, HasContinuousConstSmul R' (M' i)] :
    (∀ i, ContinuousMultilinearMap A M₁ (M' i)) ≃ₗ[R'] ContinuousMultilinearMap A M₁ (∀ i, M' i) :=
  { piEquiv with
    map_add' := fun x y => rfl
    map_smul' := fun c x => rfl }
#align continuous_multilinear_map.pi_linear_equiv ContinuousMultilinearMap.piLinearEquiv

end Module

section CommAlgebra

variable (R ι) (A : Type _) [Fintype ι] [CommSemiring R] [CommSemiring A] [Algebra R A]
  [TopologicalSpace A] [HasContinuousMul A]

/-- The continuous multilinear map on `A^ι`, where `A` is a normed commutative algebra
over `𝕜`, associating to `m` the product of all the `m i`.

See also `continuous_multilinear_map.mk_pi_algebra_fin`. -/
protected def mkPiAlgebra : ContinuousMultilinearMap R (fun i : ι => A) A
    where
  cont := (continuous_finset_prod _) fun i hi => continuous_apply _
  toMultilinearMap := MultilinearMap.mkPiAlgebra R ι A
#align continuous_multilinear_map.mk_pi_algebra ContinuousMultilinearMap.mkPiAlgebra

@[simp]
theorem mk_pi_algebra_apply (m : ι → A) : ContinuousMultilinearMap.mkPiAlgebra R ι A m = ∏ i, m i :=
  rfl
#align continuous_multilinear_map.mk_pi_algebra_apply ContinuousMultilinearMap.mk_pi_algebra_apply

end CommAlgebra

section Algebra

variable (R n) (A : Type _) [CommSemiring R] [Semiring A] [Algebra R A] [TopologicalSpace A]
  [HasContinuousMul A]

/-- The continuous multilinear map on `A^n`, where `A` is a normed algebra over `𝕜`, associating to
`m` the product of all the `m i`.

See also: `continuous_multilinear_map.mk_pi_algebra`. -/
protected def mkPiAlgebraFin : A[×n]→L[R] A
    where
  cont := by
    change Continuous fun m => (List.ofFn m).Prod
    simp_rw [List.of_fn_eq_map]
    exact continuous_list_prod _ fun i hi => continuous_apply _
  toMultilinearMap := MultilinearMap.mkPiAlgebraFin R n A
#align continuous_multilinear_map.mk_pi_algebra_fin ContinuousMultilinearMap.mkPiAlgebraFin

variable {R n A}

@[simp]
theorem mk_pi_algebra_fin_apply (m : Fin n → A) :
    ContinuousMultilinearMap.mkPiAlgebraFin R n A m = (List.ofFn m).Prod :=
  rfl
#align
  continuous_multilinear_map.mk_pi_algebra_fin_apply ContinuousMultilinearMap.mk_pi_algebra_fin_apply

end Algebra

section SmulRight

variable [CommSemiring R] [∀ i, AddCommMonoid (M₁ i)] [AddCommMonoid M₂] [∀ i, Module R (M₁ i)]
  [Module R M₂] [TopologicalSpace R] [∀ i, TopologicalSpace (M₁ i)] [TopologicalSpace M₂]
  [HasContinuousSmul R M₂] (f : ContinuousMultilinearMap R M₁ R) (z : M₂)

/-- Given a continuous `R`-multilinear map `f` taking values in `R`, `f.smul_right z` is the
continuous multilinear map sending `m` to `f m • z`. -/
@[simps toMultilinearMap apply]
def smulRight : ContinuousMultilinearMap R M₁ M₂
    where
  toMultilinearMap := f.toMultilinearMap.smul_right z
  cont := f.cont.smul continuous_const
#align continuous_multilinear_map.smul_right ContinuousMultilinearMap.smulRight

end SmulRight

end ContinuousMultilinearMap

