/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module algebra.monoid_algebra.grading
! leanprover-community/mathlib commit 9830a300340708eaa85d477c3fb96dd25f9468a5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Finsupp
import Mathbin.Algebra.MonoidAlgebra.Support
import Mathbin.Algebra.DirectSum.Internal
import Mathbin.RingTheory.GradedAlgebra.Basic

/-!
# Internal grading of an `add_monoid_algebra`

In this file, we show that an `add_monoid_algebra` has an internal direct sum structure.

## Main results

* `add_monoid_algebra.grade_by R f i`: the `i`th grade of an `add_monoid_algebra R M` given by the
  degree function `f`.
* `add_monoid_algebra.grade R i`: the `i`th grade of an `add_monoid_algebra R M` when the degree
  function is the identity.
* `add_monoid_algebra.grade_by.graded_algebra`: `add_monoid_algebra` is an algebra graded by
  `add_monoid_algebra.grade_by`.
* `add_monoid_algebra.grade.graded_algebra`: `add_monoid_algebra` is an algebra graded by
  `add_monoid_algebra.grade`.
* `add_monoid_algebra.grade_by.is_internal`: propositionally, the statement that
  `add_monoid_algebra.grade_by` defines an internal graded structure.
* `add_monoid_algebra.grade.is_internal`: propositionally, the statement that
  `add_monoid_algebra.grade` defines an internal graded structure when the degree function
  is the identity.
-/


noncomputable section

namespace AddMonoidAlgebra

variable {M : Type _} {ι : Type _} {R : Type _} [DecidableEq M]

section

variable (R) [CommSemiring R]

/-- The submodule corresponding to each grade given by the degree function `f`. -/
abbrev gradeBy (f : M → ι) (i : ι) : Submodule R (AddMonoidAlgebra R M) :=
  { carrier := { a | ∀ m, m ∈ a.support → f m = i }
    zero_mem' := Set.empty_subset _
    add_mem' := fun a b ha hb m h =>
      Or.rec_on (Finset.mem_union.mp (Finsupp.support_add h)) (ha m) (hb m)
    smul_mem' := fun a m h => Set.Subset.trans Finsupp.support_smul h }
#align add_monoid_algebra.grade_by AddMonoidAlgebra.gradeBy

/-- The submodule corresponding to each grade. -/
abbrev grade (m : M) : Submodule R (AddMonoidAlgebra R M) :=
  gradeBy R id m
#align add_monoid_algebra.grade AddMonoidAlgebra.grade

theorem grade_by_id : gradeBy R (id : M → M) = grade R := by rfl
#align add_monoid_algebra.grade_by_id AddMonoidAlgebra.grade_by_id

theorem mem_grade_by_iff (f : M → ι) (i : ι) (a : AddMonoidAlgebra R M) :
    a ∈ gradeBy R f i ↔ (a.support : Set M) ⊆ f ⁻¹' {i} := by rfl
#align add_monoid_algebra.mem_grade_by_iff AddMonoidAlgebra.mem_grade_by_iff

theorem mem_grade_iff (m : M) (a : AddMonoidAlgebra R M) : a ∈ grade R m ↔ a.support ⊆ {m} :=
  by
  rw [← Finset.coe_subset, Finset.coe_singleton]
  rfl
#align add_monoid_algebra.mem_grade_iff AddMonoidAlgebra.mem_grade_iff

theorem mem_grade_iff' (m : M) (a : AddMonoidAlgebra R M) :
    a ∈ grade R m ↔
      a ∈ ((Finsupp.lsingle m : R →ₗ[R] M →₀ R).range : Submodule R (AddMonoidAlgebra R M)) :=
  by
  rw [mem_grade_iff, Finsupp.support_subset_singleton']
  apply exists_congr
  intro r
  constructor <;> exact Eq.symm
#align add_monoid_algebra.mem_grade_iff' AddMonoidAlgebra.mem_grade_iff'

theorem grade_eq_lsingle_range (m : M) : grade R m = (Finsupp.lsingle m : R →ₗ[R] M →₀ R).range :=
  Submodule.ext (mem_grade_iff' R m)
#align add_monoid_algebra.grade_eq_lsingle_range AddMonoidAlgebra.grade_eq_lsingle_range

theorem single_mem_grade_by {R} [CommSemiring R] (f : M → ι) (m : M) (r : R) :
    Finsupp.single m r ∈ gradeBy R f (f m) :=
  by
  intro x hx
  rw [finset.mem_singleton.mp (Finsupp.support_single_subset hx)]
#align add_monoid_algebra.single_mem_grade_by AddMonoidAlgebra.single_mem_grade_by

theorem single_mem_grade {R} [CommSemiring R] (i : M) (r : R) : Finsupp.single i r ∈ grade R i :=
  single_mem_grade_by _ _ _
#align add_monoid_algebra.single_mem_grade AddMonoidAlgebra.single_mem_grade

end

open DirectSum

instance gradeBy.graded_monoid [AddMonoid M] [AddMonoid ι] [CommSemiring R] (f : M →+ ι) :
    SetLike.GradedMonoid (gradeBy R f : ι → Submodule R (AddMonoidAlgebra R M))
    where
  one_mem m h := by
    rw [one_def] at h
    by_cases H : (1 : R) = (0 : R)
    · rw [H, Finsupp.single_zero] at h
      exfalso
      exact h
    · rw [Finsupp.support_single_ne_zero _ H, Finset.mem_singleton] at h
      rw [h, AddMonoidHom.map_zero]
  mul_mem i j a b ha hb c hc := by
    set h := support_mul a b hc
    simp only [Finset.mem_bUnion] at h
    rcases h with ⟨ma, ⟨hma, ⟨mb, ⟨hmb, hmc⟩⟩⟩⟩
    rw [← ha ma hma, ← hb mb hmb, finset.mem_singleton.mp hmc]
    apply AddMonoidHom.map_add
#align add_monoid_algebra.grade_by.graded_monoid AddMonoidAlgebra.gradeBy.graded_monoid

instance grade.graded_monoid [AddMonoid M] [CommSemiring R] :
    SetLike.GradedMonoid (grade R : M → Submodule R (AddMonoidAlgebra R M)) := by
  apply grade_by.graded_monoid (AddMonoidHom.id _)
#align add_monoid_algebra.grade.graded_monoid AddMonoidAlgebra.grade.graded_monoid

variable {R} [AddMonoid M] [DecidableEq ι] [AddMonoid ι] [CommSemiring R] (f : M →+ ι)

/-- Auxiliary definition; the canonical grade decomposition, used to provide
`direct_sum.decompose`. -/
def decomposeAux : AddMonoidAlgebra R M →ₐ[R] ⨁ i : ι, gradeBy R f i :=
  AddMonoidAlgebra.lift R M _
    { toFun := fun m =>
        DirectSum.of (fun i : ι => gradeBy R f i) (f m.toAdd)
          ⟨Finsupp.single m.toAdd 1, single_mem_grade_by _ _ _⟩
      map_one' :=
        DirectSum.of_eq_of_graded_monoid_eq
          (by
            congr 2 <;> try ext <;>
              simp only [Submodule.mem_to_add_submonoid, toAdd_one, AddMonoidHom.map_zero])
      map_mul' := fun i j => by
        symm
        convert DirectSum.of_mul_of _ _
        apply DirectSum.of_eq_of_graded_monoid_eq
        congr 2
        · rw [toAdd_mul, AddMonoidHom.map_add]
        · ext
          simp only [Submodule.mem_to_add_submonoid, AddMonoidHom.map_add, toAdd_mul]
        · exact Eq.trans (by rw [one_mul, toAdd_mul]) single_mul_single.symm }
#align add_monoid_algebra.decompose_aux AddMonoidAlgebra.decomposeAux

theorem decompose_aux_single (m : M) (r : R) :
    decomposeAux f (Finsupp.single m r) =
      DirectSum.of (fun i : ι => gradeBy R f i) (f m)
        ⟨Finsupp.single m r, single_mem_grade_by _ _ _⟩ :=
  by
  refine' (lift_single _ _ _).trans _
  refine' (DirectSum.of_smul _ _ _ _).symm.trans _
  apply DirectSum.of_eq_of_graded_monoid_eq
  refine' Sigma.subtype_ext rfl _
  refine' (Finsupp.smul_single' _ _ _).trans _
  rw [mul_one]
  rfl
#align add_monoid_algebra.decompose_aux_single AddMonoidAlgebra.decompose_aux_single

theorem decompose_aux_coe {i : ι} (x : gradeBy R f i) :
    decomposeAux f ↑x = DirectSum.of (fun i => gradeBy R f i) i x :=
  by
  obtain ⟨x, hx⟩ := x
  revert hx
  refine' Finsupp.induction x _ _
  · intro hx
    symm
    exact AddMonoidHom.map_zero _
  · intro m b y hmy hb ih hmby
    have : Disjoint (Finsupp.single m b).support y.support := by
      simpa only [Finsupp.support_single_ne_zero _ hb, Finset.disjoint_singleton_left]
    rw [mem_grade_by_iff, Finsupp.support_add_eq this, Finset.coe_union, Set.union_subset_iff] at
      hmby
    cases' hmby with h1 h2
    have : f m = i := by
      rwa [Finsupp.support_single_ne_zero _ hb, Finset.coe_singleton, Set.singleton_subset_iff] at
        h1
    subst this
    simp only [AlgHom.map_add, Submodule.coe_mk, decompose_aux_single f m]
    let ih' := ih h2
    dsimp at ih'
    rw [ih', ← AddMonoidHom.map_add]
    apply DirectSum.of_eq_of_graded_monoid_eq
    congr 2
#align add_monoid_algebra.decompose_aux_coe AddMonoidAlgebra.decompose_aux_coe

instance gradeBy.gradedAlgebra : GradedAlgebra (gradeBy R f) :=
  GradedAlgebra.ofAlgHom _ (decomposeAux f)
    (by
      ext : 2
      dsimp
      rw [decompose_aux_single, DirectSum.coe_alg_hom_of, Subtype.coe_mk])
    fun i x => by convert (decompose_aux_coe f x : _)
#align add_monoid_algebra.grade_by.graded_algebra AddMonoidAlgebra.gradeBy.gradedAlgebra

-- Lean can't find this later without us repeating it
instance gradeBy.decomposition : DirectSum.Decomposition (gradeBy R f) := by infer_instance
#align add_monoid_algebra.grade_by.decomposition AddMonoidAlgebra.gradeBy.decomposition

@[simp]
theorem decompose_aux_eq_decompose :
    ⇑(decomposeAux f : AddMonoidAlgebra R M →ₐ[R] ⨁ i : ι, gradeBy R f i) =
      DirectSum.decompose (gradeBy R f) :=
  rfl
#align add_monoid_algebra.decompose_aux_eq_decompose AddMonoidAlgebra.decompose_aux_eq_decompose

@[simp]
theorem GradesBy.decompose_single (m : M) (r : R) :
    DirectSum.decompose (gradeBy R f) (Finsupp.single m r) =
      DirectSum.of (fun i : ι => gradeBy R f i) (f m)
        ⟨Finsupp.single m r, single_mem_grade_by _ _ _⟩ :=
  decompose_aux_single _ _ _
#align add_monoid_algebra.grades_by.decompose_single AddMonoidAlgebra.GradesBy.decompose_single

instance grade.gradedAlgebra : GradedAlgebra (grade R : ι → Submodule _ _) :=
  AddMonoidAlgebra.gradeBy.gradedAlgebra (AddMonoidHom.id _)
#align add_monoid_algebra.grade.graded_algebra AddMonoidAlgebra.grade.gradedAlgebra

-- Lean can't find this later without us repeating it
instance grade.decomposition : DirectSum.Decomposition (grade R : ι → Submodule _ _) := by
  infer_instance
#align add_monoid_algebra.grade.decomposition AddMonoidAlgebra.grade.decomposition

@[simp]
theorem grade.decompose_single (i : ι) (r : R) :
    DirectSum.decompose (grade R : ι → Submodule _ _) (Finsupp.single i r) =
      DirectSum.of (fun i : ι => grade R i) i ⟨Finsupp.single i r, single_mem_grade _ _⟩ :=
  decompose_aux_single _ _ _
#align add_monoid_algebra.grade.decompose_single AddMonoidAlgebra.grade.decompose_single

/-- `add_monoid_algebra.gradesby` describe an internally graded algebra -/
theorem gradeBy.is_internal : DirectSum.IsInternal (gradeBy R f) :=
  DirectSum.Decomposition.is_internal _
#align add_monoid_algebra.grade_by.is_internal AddMonoidAlgebra.gradeBy.is_internal

/-- `add_monoid_algebra.grades` describe an internally graded algebra -/
theorem grade.is_internal : DirectSum.IsInternal (grade R : ι → Submodule R _) :=
  DirectSum.Decomposition.is_internal _
#align add_monoid_algebra.grade.is_internal AddMonoidAlgebra.grade.is_internal

end AddMonoidAlgebra

