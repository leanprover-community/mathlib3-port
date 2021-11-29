import Mathbin.Analysis.NormedSpace.ConformalLinearMap 
import Mathbin.Analysis.Calculus.Fderiv

/-!
# Conformal Maps

A continuous linear map between real normed spaces `X` and `Y` is `conformal_at` some point `x`
if it is real differentiable at that point and its differential `is_conformal_linear_map`.

## Main definitions

* `conformal_at`: the main definition of conformal maps
* `conformal`: maps that are conformal at every point
* `conformal_factor_at`: the conformal factor of a conformal map at some point

## Main results
* The conformality of the composition of two conformal maps, the identity map
  and multiplications by nonzero constants
* `conformal_at_iff_is_conformal_map_fderiv`: an equivalent definition of the conformality of a map

In `analysis.calculus.conformal.inner_product`:
* `conformal_at_iff`: an equivalent definition of the conformality of a map

In `geometry.euclidean.basic`:
* `conformal_at.preserves_angle`: if a map is conformal at `x`, then its differential
                                  preserves all angles at `x`

## Tags

conformal

## Warning

The definition of conformality in this file does NOT require the maps to be orientation-preserving.
Maps such as the complex conjugate are considered to be conformal.
-/


noncomputable theory

variable{X Y Z : Type _}[NormedGroup X][NormedGroup Y][NormedGroup Z][NormedSpace ℝ X][NormedSpace ℝ Y][NormedSpace ℝ Z]

section LocConformality

open LinearIsometry ContinuousLinearMap

/-- A map `f` is said to be conformal if it has a conformal differential `f'`. -/
def ConformalAt (f : X → Y) (x : X) :=
  ∃ f' : X →L[ℝ] Y, HasFderivAt f f' x ∧ IsConformalMap f'

theorem conformal_at_id (x : X) : ConformalAt id x :=
  ⟨id ℝ X, has_fderiv_at_id _, is_conformal_map_id⟩

-- error in Analysis.Calculus.Conformal.NormedSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem conformal_at_const_smul
{c : exprℝ()}
(h : «expr ≠ »(c, 0))
(x : X) : conformal_at (λ x' : X, «expr • »(c, x')) x :=
⟨«expr • »(c, continuous_linear_map.id exprℝ() X), (has_fderiv_at_id x).const_smul c, is_conformal_map_const_smul h⟩

/-- A function is a conformal map if and only if its differential is a conformal linear map-/
theorem conformal_at_iff_is_conformal_map_fderiv {f : X → Y} {x : X} :
  ConformalAt f x ↔ IsConformalMap (fderiv ℝ f x) :=
  by 
    split 
    ·
      rintro ⟨c, hf, hf'⟩
      rw [hf.fderiv]
      exact hf'
    ·
      intro H 
      byCases' h : DifferentiableAt ℝ f x
      ·
        exact ⟨fderiv ℝ f x, h.has_fderiv_at, H⟩
      ·
        cases' subsingleton_or_nontrivial X with w w <;> skip
        ·
          exact ⟨(0 : X →L[ℝ] Y), has_fderiv_at_of_subsingleton f x, is_conformal_map_of_subsingleton 0⟩
        ·
          exfalso 
          exact H.ne_zero (fderiv_zero_of_not_differentiable_at h)

namespace ConformalAt

theorem DifferentiableAt {f : X → Y} {x : X} (h : ConformalAt f x) : DifferentiableAt ℝ f x :=
  let ⟨_, h₁, _⟩ := h 
  h₁.differentiable_at

theorem congr {f g : X → Y} {x : X} {u : Set X} (hx : x ∈ u) (hu : IsOpen u) (hf : ConformalAt f x)
  (h : ∀ (x : X), x ∈ u → g x = f x) : ConformalAt g x :=
  let ⟨f', hfderiv, hf'⟩ := hf
  ⟨f', hfderiv.congr_of_eventually_eq ((hu.eventually_mem hx).mono h), hf'⟩

theorem comp {f : X → Y} {g : Y → Z} (x : X) (hg : ConformalAt g (f x)) (hf : ConformalAt f x) :
  ConformalAt (g ∘ f) x :=
  by 
    rcases hf with ⟨f', hf₁, cf⟩
    rcases hg with ⟨g', hg₁, cg⟩
    exact ⟨g'.comp f', hg₁.comp x hf₁, cg.comp cf⟩

theorem const_smul {f : X → Y} {x : X} {c : ℝ} (hc : c ≠ 0) (hf : ConformalAt f x) : ConformalAt (c • f) x :=
  (conformal_at_const_smul hc$ f x).comp x hf

end ConformalAt

end LocConformality

section GlobalConformality

/-- A map `f` is conformal if it's conformal at every point. -/
def Conformal (f : X → Y) :=
  ∀ (x : X), ConformalAt f x

theorem conformal_id : Conformal (id : X → X) :=
  fun x => conformal_at_id x

-- error in Analysis.Calculus.Conformal.NormedSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem conformal_const_smul {c : exprℝ()} (h : «expr ≠ »(c, 0)) : conformal (λ x : X, «expr • »(c, x)) :=
λ x, conformal_at_const_smul h x

namespace Conformal

theorem ConformalAt {f : X → Y} (h : Conformal f) (x : X) : ConformalAt f x :=
  h x

theorem Differentiable {f : X → Y} (h : Conformal f) : Differentiable ℝ f :=
  fun x => (h x).DifferentiableAt

theorem comp {f : X → Y} {g : Y → Z} (hf : Conformal f) (hg : Conformal g) : Conformal (g ∘ f) :=
  fun x => (hg$ f x).comp x (hf x)

theorem const_smul {f : X → Y} (hf : Conformal f) {c : ℝ} (hc : c ≠ 0) : Conformal (c • f) :=
  fun x => (hf x).const_smul hc

end Conformal

end GlobalConformality

