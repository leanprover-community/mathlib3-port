import Mathbin.LinearAlgebra.Finsupp 
import Mathbin.Algebra.MonoidAlgebra.Basic 
import Mathbin.Algebra.DirectSum.Internal

/-!
# Internal grading of an `add_monoid_algebra`

In this file, we show that an `add_monoid_algebra` has an internal direct sum structure.

## Main results

* `add_monoid_algebra.grade R i`: the `i`th grade of an `add_monoid_algebra R ι`
* `add_monoid_algebra.equiv_grade`: the equivalence between an `add_monoid_algebra` and the direct
  sum of its grades.
* `add_monoid_algebra.grade.is_internal`: propositionally, the statement that
  `add_monoid_algebra.grade` defines an internal graded structure.
-/


noncomputable theory

namespace AddMonoidAlgebra

variable{ι : Type _}{R : Type _}

section 

variable(R)

/-- The submodule corresponding to each grade. -/
abbrev grade [CommSemiringₓ R] (i : ι) : Submodule R (AddMonoidAlgebra R ι) :=
  (Finsupp.lsingle i).range

end 

open_locale DirectSum

instance grade.graded_monoid [AddMonoidₓ ι] [CommSemiringₓ R] :
  SetLike.GradedMonoid (grade R : ι → Submodule R (AddMonoidAlgebra R ι)) :=
  { one_mem := ⟨1, rfl⟩,
    mul_mem :=
      fun i j _ _ =>
        by 
          rintro ⟨a, rfl⟩ ⟨b, rfl⟩
          exact ⟨_, single_mul_single.symm⟩ }

variable{R}[DecidableEq ι][AddMonoidₓ ι][CommSemiringₓ R]

-- error in Algebra.MonoidAlgebra.Grading: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The canonical grade decomposition. -/
def to_grades : «expr →ₐ[ ] »(add_monoid_algebra R ι, R, «expr⨁ , »((i : ι), grade R i)) :=
add_monoid_algebra.lift _ _ _ { to_fun := λ i, direct_sum.of (λ i : ι, grade R i) i.to_add ⟨_, 1, rfl⟩,
  map_one' := rfl,
  map_mul' := λ i j, begin
    rw ["[", expr direct_sum.of_mul_of, ",", expr to_add_mul, "]"] [],
    congr,
    refine [expr eq.trans _ single_mul_single.symm],
    rw [expr one_mul] [],
    refl
  end }

-- error in Algebra.MonoidAlgebra.Grading: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem to_grades_single
(i : ι)
(r : R) : «expr = »(to_grades (finsupp.single i r), direct_sum.of (λ
  i : ι, grade R i) i ⟨finsupp.single _ _, r, rfl⟩) :=
begin
  refine [expr (add_monoid_algebra.lift_single _ _ _).trans _],
  refine [expr (direct_sum.of_smul _ _ _ _).symm.trans _],
  dsimp [] [] [] [],
  congr' [1] [],
  ext [] [] [":", 1],
  refine [expr (finsupp.smul_single _ _ _).trans _],
  rw ["[", expr smul_eq_mul, ",", expr mul_one, "]"] [],
  refl
end

@[simp]
theorem to_grades_coe {i : ι} (x : grade R i) : to_grades («expr↑ » x) = DirectSum.of (fun i => grade R i) i x :=
  by 
    obtain ⟨-, x, rfl⟩ := x 
    exact to_grades_single _ _

/-- The canonical recombination of grades. -/
def of_grades : (⨁i : ι, grade R i) →ₐ[R] AddMonoidAlgebra R ι :=
  DirectSum.submoduleCoeAlgHom (grade R)

@[simp]
theorem of_grades_of (i : ι) (x : grade R i) : of_grades (DirectSum.of (fun i => grade R i) i x) = x :=
  DirectSum.submodule_coe_alg_hom_of (grade R) i x

@[simp]
theorem of_grades_comp_to_grades : of_grades.comp to_grades = AlgHom.id R (AddMonoidAlgebra R ι) :=
  by 
    ext : 2
    dsimp 
    rw [to_grades_single, of_grades_of, Subtype.coe_mk]

@[simp]
theorem of_grades_to_grades (x : AddMonoidAlgebra R ι) : of_grades x.to_grades = x :=
  AlgHom.congr_fun of_grades_comp_to_grades x

@[simp]
theorem to_grades_comp_of_grades : to_grades.comp of_grades = AlgHom.id R (⨁i : ι, grade R i) :=
  by 
    ext : 2
    dsimp [DirectSum.lof_eq_of]
    rw [of_grades_of, to_grades_coe]

@[simp]
theorem to_grades_of_grades (g : ⨁i : ι, grade R i) : (of_grades g).toGrades = g :=
  AlgHom.congr_fun to_grades_comp_of_grades g

/-- An `add_monoid_algebra R ι` is equivalent as an algebra to the direct sum of its grades.
-/
@[simps]
def equiv_grades : AddMonoidAlgebra R ι ≃ₐ[R] ⨁i : ι, grade R i :=
  AlgEquiv.ofAlgHom _ _ to_grades_comp_of_grades of_grades_comp_to_grades

/-- `add_monoid_algebra.grades` describe an internally graded algebra -/
theorem grade.is_internal : DirectSum.SubmoduleIsInternal (grade R : ι → Submodule R _) :=
  equiv_grades.symm.Bijective

end AddMonoidAlgebra

