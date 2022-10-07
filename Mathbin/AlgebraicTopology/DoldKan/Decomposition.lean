/-
Copyright (c) 2022 Joël Riou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joël Riou
-/
import Mathbin.AlgebraicTopology.DoldKan.PInfty

/-!

# Decomposition of the Q endomorphisms

In this file, we obtain a lemma `decomposition_Q` which expresses
explicitly the projection `(Q q).f (n+1) : X _[n+1] ⟶ X _[n+1]`
(`X : simplicial_object C` with `C` a preadditive category) as
a sum of terms which are postcompositions with degeneracies.

(TODO @joelriou: when `C` is abelian, define the degenerate
subcomplex of the alternating face map complex of `X` and show
that it is a complement to the normalized Moore complex.)

Then, we introduce an ad hoc structure `morph_components X n Z` which
can be used in order to define morphisms `X _[n+1] ⟶ Z` using the
decomposition provided by `decomposition_Q`. This shall play a critical
role in the proof that the functor
`N₁ : simplicial_object C ⥤ karoubi (chain_complex C ℕ))`
reflects isomorphisms.

-/


open CategoryTheory CategoryTheory.Category CategoryTheory.Preadditive Opposite

open BigOperators Simplicial

noncomputable section

namespace AlgebraicTopology

namespace DoldKan

variable {C : Type _} [Category C] [Preadditive C] {X X' : SimplicialObject C}

/-- In each positive degree, this lemma decomposes the idempotent endomorphism
`Q q` as a sum of morphisms which are postcompositions with suitable degeneracies.
As `Q q` is the complement projection to `P q`, this implies that in the case of
simplicial abelian groups, any $(n+1)$-simplex $x$ can be decomposed as
$x = x' + \sum (i=0}^{q-1} σ_{n-i}(y_i)$ where $x'$ is in the image of `P q` and
the $y_i$ are in degree $n$. -/
theorem decomposition_Q (n q : ℕ) :
    ((q q).f (n + 1) : X _[n + 1] ⟶ X _[n + 1]) =
      ∑ i : Finₓ (n + 1) in Finsetₓ.filter (fun i : Finₓ (n + 1) => (i : ℕ) < q) Finsetₓ.univ,
        (p i).f (n + 1) ≫ X.δ i.rev.succ ≫ X.σ i.rev :=
  by
  induction' q with q hq
  · simp only [Q_eq_zero, HomologicalComplex.zero_f_apply, Nat.not_lt_zeroₓ, Finsetₓ.filter_false, Finsetₓ.sum_empty]
    
  · by_cases hqn:q + 1 ≤ n + 1
    swap
    · rw [Q_is_eventually_constant (show n + 1 ≤ q by linarith), hq]
      congr
      ext
      have hx := x.is_lt
      simp only [Nat.succ_eq_add_one]
      constructor <;> intro h <;> linarith
      
    · cases' Nat.Le.dest (nat.succ_le_succ_iff.mp hqn) with a ha
      rw [Q_eq, HomologicalComplex.sub_f_apply, HomologicalComplex.comp_f, hq]
      symm
      conv_rhs => rw [sub_eq_add_neg, add_commₓ]
      let q' : Finₓ (n + 1) := ⟨q, nat.succ_le_iff.mp hqn⟩
      convert Finsetₓ.sum_insert (_ : q' ∉ _)
      · ext i
        simp only [Finsetₓ.mem_insert, Finsetₓ.mem_filter, Finsetₓ.mem_univ, true_andₓ, Nat.lt_succ_iff_lt_or_eq,
          Finₓ.ext_iff]
        tauto
        
      · have hnaq' : n = a + q := by linarith
        simpa only [Finₓ.coe_mk, (higher_faces_vanish.of_P q n).comp_Hσ_eq hnaq', q'.rev_eq hnaq', neg_negₓ]
        
      · simp only [Finsetₓ.mem_filter, Finₓ.coe_mk, lt_self_iff_falseₓ, and_falseₓ, not_false_iff]
        
      
    

variable (X)

/-- The structure `morph_components` is an ad hoc structure that is used in
the proof that `N₁ : simplicial_object C ⥤ karoubi (chain_complex C ℕ))`
reflects isomorphisms. The fields are the data that are needed in order to
construct a morphism `X _[n+1] ⟶ Z` (see `φ`) using the decomposition of the
identity given by `decomposition_Q n (n+1)`. -/
@[ext, nolint has_nonempty_instance]
structure MorphComponents (n : ℕ) (Z : C) where
  a : X _[n + 1] ⟶ Z
  b : Finₓ (n + 1) → (X _[n] ⟶ Z)

namespace MorphComponents

variable {X} {n : ℕ} {Z Z' : C} (f : MorphComponents X n Z) (g : X' ⟶ X) (h : Z ⟶ Z')

/-- The morphism `X _[n+1] ⟶ Z ` associated to `f : morph_components X n Z`. -/
def φ {Z : C} (f : MorphComponents X n Z) : X _[n + 1] ⟶ Z :=
  pInfty.f (n + 1) ≫ f.a + ∑ i : Finₓ (n + 1), (p i).f (n + 1) ≫ X.δ i.rev.succ ≫ f.b i.rev

variable (X n)

/-- the canonical `morph_components` whose associated morphism is the identity
(see `F_id`) thanks to `decomposition_Q n (n+1)` -/
@[simps]
def id : MorphComponents X n (X _[n + 1]) where
  a := pInfty.f (n + 1)
  b := fun i => X.σ i

@[simp]
theorem id_φ : (id X n).φ = 𝟙 _ := by
  simp only [← P_add_Q_f (n + 1) (n + 1), φ]
  congr 1
  · simp only [id, P_infty_f, P_f_idem]
    
  · convert (decomposition_Q n (n + 1)).symm
    ext i
    simpa only [Finsetₓ.mem_univ, Finsetₓ.mem_filter, true_andₓ, true_iffₓ] using Finₓ.is_lt i
    

variable {X n}

/-- A `morph_components` can be postcomposed with a morphism. -/
@[simps]
def postComp : MorphComponents X n Z' where
  a := f.a ≫ h
  b := fun i => f.b i ≫ h

@[simp]
theorem post_comp_φ : (f.postComp h).φ = f.φ ≫ h := by
  unfold φ post_comp
  simp only [add_comp, sum_comp, assoc]

/-- A `morph_components` can be precomposed with a morphism of simplicial objects. -/
@[simps]
def preComp : MorphComponents X' n Z where
  a := g.app (op [n + 1]) ≫ f.a
  b := fun i => g.app (op [n]) ≫ f.b i

@[simp]
theorem pre_comp_φ : (f.preComp g).φ = g.app (op [n + 1]) ≫ f.φ := by
  unfold φ pre_comp
  simp only [P_infty_f, comp_add]
  congr 1
  · simp only [P_f_naturality_assoc]
    
  · simp only [comp_sum, P_f_naturality_assoc, simplicial_object.δ_naturality_assoc]
    

end MorphComponents

end DoldKan

end AlgebraicTopology

