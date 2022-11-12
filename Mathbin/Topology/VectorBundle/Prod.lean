/-
Copyright © 2022 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth, Floris van Doorn
-/
import Mathbin.Topology.VectorBundle.Basic

/-!
# Direct sum of two vector bundles

If `E₁ : B → Type*` and `E₂ : B → Type*` define two topological vector bundles over `R` with fiber
models `F₁` and `F₂`, we define the bundle of direct sums `E₁ ×ᵇ E₂ := λ x, E₁ x × E₂ x`.
We can endow `E₁ ×ᵇ E₂` with a topological vector bundle structure:
`bundle.prod.topological_vector_bundle`.

A similar construction (which is yet to be formalized) can be done for the vector bundle of
continuous linear maps from `E₁ x` to `E₂ x` with fiber a type synonym
`vector_bundle_continuous_linear_map R F₁ E₁ F₂ E₂ x := (E₁ x →L[R] E₂ x)` (and with the
topology inherited from the norm-topology on `F₁ →L[R] F₂`, without the need to define the strong
topology on continuous linear maps between general topological vector spaces).  Likewise for tensor
products of topological vector bundles, exterior algebras, and so on, where the topology can be
defined using a norm on the fiber model if this helps.

## Tags
Vector bundle
-/


noncomputable section

open Bundle Set

open Classical Bundle

variable (R 𝕜 : Type _) {B : Type _} (F : Type _) (E : B → Type _)

section Defs

variable (E₁ : B → Type _) (E₂ : B → Type _)

variable [TopologicalSpace (TotalSpace E₁)] [TopologicalSpace (TotalSpace E₂)]

/-- Equip the total space of the fibrewise product of two topological vector bundles `E₁`, `E₂` with
the induced topology from the diagonal embedding into `total_space E₁ × total_space E₂`. -/
instance TopologicalVectorBundle.Prod.topologicalSpace : TopologicalSpace (TotalSpace (E₁ ×ᵇ E₂)) :=
  TopologicalSpace.induced (fun p => ((⟨p.1, p.2.1⟩ : TotalSpace E₁), (⟨p.1, p.2.2⟩ : TotalSpace E₂)))
    (by infer_instance : TopologicalSpace (TotalSpace E₁ × TotalSpace E₂))
#align topological_vector_bundle.prod.topological_space TopologicalVectorBundle.Prod.topologicalSpace

/-- The diagonal map from the total space of the fibrewise product of two topological vector bundles
`E₁`, `E₂` into `total_space E₁ × total_space E₂` is `inducing`. -/
theorem TopologicalVectorBundle.Prod.inducing_diag :
    Inducing (fun p => (⟨p.1, p.2.1⟩, ⟨p.1, p.2.2⟩) : TotalSpace (E₁ ×ᵇ E₂) → TotalSpace E₁ × TotalSpace E₂) :=
  ⟨rfl⟩
#align topological_vector_bundle.prod.inducing_diag TopologicalVectorBundle.Prod.inducing_diag

end Defs

open TopologicalVectorBundle

variable [NontriviallyNormedField R] [TopologicalSpace B]

variable (F₁ : Type _) [NormedAddCommGroup F₁] [NormedSpace R F₁] (E₁ : B → Type _) [TopologicalSpace (TotalSpace E₁)]

variable (F₂ : Type _) [NormedAddCommGroup F₂] [NormedSpace R F₂] (E₂ : B → Type _) [TopologicalSpace (TotalSpace E₂)]

namespace Trivialization

variable (e₁ : Trivialization F₁ (π E₁)) (e₂ : Trivialization F₂ (π E₂))

include e₁ e₂

variable {R F₁ E₁ F₂ E₂}

/-- Given trivializations `e₁`, `e₂` for vector bundles `E₁`, `E₂` over a base `B`, the forward
function for the construction `topological_vector_bundle.trivialization.prod`, the induced
trivialization for the direct sum of `E₁` and `E₂`. -/
def Prod.toFun' : TotalSpace (E₁ ×ᵇ E₂) → B × F₁ × F₂ := fun p => ⟨p.1, (e₁ ⟨p.1, p.2.1⟩).2, (e₂ ⟨p.1, p.2.2⟩).2⟩
#align trivialization.prod.to_fun' Trivialization.Prod.toFun'

variable {e₁ e₂}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem Prod.continuous_to_fun :
    ContinuousOn (Prod.toFun' e₁ e₂) (@TotalSpace.proj B (E₁ ×ᵇ E₂) ⁻¹' (e₁.BaseSet ∩ e₂.BaseSet)) := by
  let f₁ : total_space (E₁ ×ᵇ E₂) → total_space E₁ × total_space E₂ := fun p =>
    ((⟨p.1, p.2.1⟩ : total_space E₁), (⟨p.1, p.2.2⟩ : total_space E₂))
  let f₂ : total_space E₁ × total_space E₂ → (B × F₁) × B × F₂ := fun p => ⟨e₁ p.1, e₂ p.2⟩
  let f₃ : (B × F₁) × B × F₂ → B × F₁ × F₂ := fun p => ⟨p.1.1, p.1.2, p.2.2⟩
  have hf₁ : Continuous f₁ := (prod.inducing_diag E₁ E₂).Continuous
  have hf₂ : ContinuousOn f₂ (e₁.source ×ˢ e₂.source) :=
    e₁.to_local_homeomorph.continuous_on.prod_map e₂.to_local_homeomorph.continuous_on
  have hf₃ : Continuous f₃ := (continuous_fst.comp continuous_fst).prod_mk (continuous_snd.prod_map continuous_snd)
  refine' ((hf₃.comp_continuous_on hf₂).comp hf₁.continuous_on _).congr _
  · rw [e₁.source_eq, e₂.source_eq]
    exact maps_to_preimage _ _
    
  rintro ⟨b, v₁, v₂⟩ ⟨hb₁, hb₂⟩
  simp only [prod.to_fun', Prod.mk.inj_iff, eq_self_iff_true, and_true_iff]
  rw [e₁.coe_fst]
  rw [e₁.source_eq, mem_preimage]
  exact hb₁
#align trivialization.prod.continuous_to_fun Trivialization.Prod.continuous_to_fun

variable (e₁ e₂) [∀ x, AddCommMonoid (E₁ x)] [∀ x, Module R (E₁ x)] [∀ x, AddCommMonoid (E₂ x)] [∀ x, Module R (E₂ x)]

/-- Given trivializations `e₁`, `e₂` for vector bundles `E₁`, `E₂` over a base `B`, the inverse
function for the construction `topological_vector_bundle.trivialization.prod`, the induced
trivialization for the direct sum of `E₁` and `E₂`. -/
def Prod.invFun' (p : B × F₁ × F₂) : TotalSpace (E₁ ×ᵇ E₂) :=
  ⟨p.1, e₁.symm p.1 p.2.1, e₂.symm p.1 p.2.2⟩
#align trivialization.prod.inv_fun' Trivialization.Prod.invFun'

variable {e₁ e₂}

theorem Prod.left_inv {x : TotalSpace (E₁ ×ᵇ E₂)}
    (h : x ∈ @TotalSpace.proj B (E₁ ×ᵇ E₂) ⁻¹' (e₁.BaseSet ∩ e₂.BaseSet)) :
    Prod.invFun' e₁ e₂ (Prod.toFun' e₁ e₂ x) = x := by
  obtain ⟨x, v₁, v₂⟩ := x
  obtain ⟨h₁ : x ∈ e₁.base_set, h₂ : x ∈ e₂.base_set⟩ := h
  simp only [prod.to_fun', prod.inv_fun', symm_apply_apply_mk, h₁, h₂]
#align trivialization.prod.left_inv Trivialization.Prod.left_inv

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem Prod.right_inv {x : B × F₁ × F₂} (h : x ∈ (e₁.BaseSet ∩ e₂.BaseSet) ×ˢ (Univ : Set (F₁ × F₂))) :
    Prod.toFun' e₁ e₂ (Prod.invFun' e₁ e₂ x) = x := by
  obtain ⟨x, w₁, w₂⟩ := x
  obtain ⟨⟨h₁ : x ∈ e₁.base_set, h₂ : x ∈ e₂.base_set⟩, -⟩ := h
  simp only [prod.to_fun', prod.inv_fun', apply_mk_symm, h₁, h₂]
#align trivialization.prod.right_inv Trivialization.Prod.right_inv

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem Prod.continuous_inv_fun : ContinuousOn (Prod.invFun' e₁ e₂) ((e₁.BaseSet ∩ e₂.BaseSet) ×ˢ univ) := by
  rw [(prod.inducing_diag E₁ E₂).continuous_on_iff]
  have H₁ : Continuous fun p : B × F₁ × F₂ => ((p.1, p.2.1), (p.1, p.2.2)) :=
    (continuous_id.prod_map continuous_fst).prod_mk (continuous_id.prod_map continuous_snd)
  refine' (e₁.continuous_on_symm.prod_map e₂.continuous_on_symm).comp H₁.continuous_on _
  exact fun x h => ⟨⟨h.1.1, mem_univ _⟩, ⟨h.1.2, mem_univ _⟩⟩
#align trivialization.prod.continuous_inv_fun Trivialization.Prod.continuous_inv_fun

variable (e₁ e₂ R)

variable [∀ x : B, TopologicalSpace (E₁ x)] [∀ x : B, TopologicalSpace (E₂ x)] [TopologicalVectorBundle R F₁ E₁]
  [TopologicalVectorBundle R F₂ E₂]

include R

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- Given trivializations `e₁`, `e₂` for vector bundles `E₁`, `E₂` over a base `B`, the induced
trivialization for the direct sum of `E₁` and `E₂`, whose base set is `e₁.base_set ∩ e₂.base_set`.
-/
@[nolint unused_arguments]
def prod : Trivialization (F₁ × F₂) (π (E₁ ×ᵇ E₂)) where
  toFun := Prod.toFun' e₁ e₂
  invFun := Prod.invFun' e₁ e₂
  Source := @TotalSpace.proj B (E₁ ×ᵇ E₂) ⁻¹' (e₁.BaseSet ∩ e₂.BaseSet)
  Target := (e₁.BaseSet ∩ e₂.BaseSet) ×ˢ Set.Univ
  map_source' x h := ⟨h, Set.mem_univ _⟩
  map_target' x h := h.1
  left_inv' x := Prod.left_inv
  right_inv' x := Prod.right_inv
  open_source := by
    refine' (e₁.open_base_set.inter e₂.open_base_set).Preimage _
    have : Continuous (@total_space.proj B E₁) := continuous_proj R B F₁
    exact this.comp (prod.inducing_diag E₁ E₂).Continuous.fst
  open_target := (e₁.open_base_set.inter e₂.open_base_set).Prod is_open_univ
  continuous_to_fun := Prod.continuous_to_fun
  continuous_inv_fun := Prod.continuous_inv_fun
  BaseSet := e₁.BaseSet ∩ e₂.BaseSet
  open_base_set := e₁.open_base_set.inter e₂.open_base_set
  source_eq := rfl
  target_eq := rfl
  proj_to_fun x h := rfl
#align trivialization.prod Trivialization.prod

omit R

instance prod.is_linear [e₁.is_linear R] [e₂.is_linear R] :
    (e₁.Prod R e₂).is_linear
      R where linear := fun x ⟨h₁, h₂⟩ => (((e₁.linear R h₁).mk' _).prod_map ((e₂.linear R h₂).mk' _)).is_linear
#align trivialization.prod.is_linear Trivialization.prod.is_linear

@[simp]
theorem base_set_prod : (prod R e₁ e₂).BaseSet = e₁.BaseSet ∩ e₂.BaseSet :=
  rfl
#align trivialization.base_set_prod Trivialization.base_set_prod

variable {e₁ e₂}

variable (R)

theorem prod_apply [e₁.is_linear R] [e₂.is_linear R] {x : B} (hx₁ : x ∈ e₁.BaseSet) (hx₂ : x ∈ e₂.BaseSet) (v₁ : E₁ x)
    (v₂ : E₂ x) :
    prod R e₁ e₂ ⟨x, (v₁, v₂)⟩ = ⟨x, e₁.continuousLinearEquivAt R x hx₁ v₁, e₂.continuousLinearEquivAt R x hx₂ v₂⟩ :=
  rfl
#align trivialization.prod_apply Trivialization.prod_apply

variable {R}

theorem prod_symm_apply (x : B) (w₁ : F₁) (w₂ : F₂) :
    (prod R e₁ e₂).toLocalEquiv.symm (x, w₁, w₂) = ⟨x, e₁.symm x w₁, e₂.symm x w₂⟩ :=
  rfl
#align trivialization.prod_symm_apply Trivialization.prod_symm_apply

end Trivialization

open Trivialization

variable [∀ x, AddCommMonoid (E₁ x)] [∀ x, Module R (E₁ x)] [∀ x, AddCommMonoid (E₂ x)] [∀ x, Module R (E₂ x)]

variable [∀ x : B, TopologicalSpace (E₁ x)] [∀ x : B, TopologicalSpace (E₂ x)] [TopologicalVectorBundle R F₁ E₁]
  [TopologicalVectorBundle R F₂ E₂]

/-- The product of two vector bundles is a vector bundle. -/
instance _root_.bundle.prod.topological_vector_bundle : TopologicalVectorBundle R (F₁ × F₂) (E₁ ×ᵇ E₂) where
  total_space_mk_inducing b := by
    rw [(prod.inducing_diag E₁ E₂).inducing_iff]
    exact (total_space_mk_inducing R F₁ E₁ b).prod_mk (total_space_mk_inducing R F₂ E₂ b)
  TrivializationAtlas :=
    { e |
      ∃ (e₁ : Trivialization F₁ (π E₁))(e₂ : Trivialization F₂ (π E₂))(_ : MemTrivializationAtlas R e₁)(_ :
        MemTrivializationAtlas R e₂), e = Trivialization.prod R e₁ e₂ }
  trivialization_linear' := by
    rintro _ ⟨e₁, e₂, he₁, he₂, rfl⟩
    skip
    infer_instance
  trivializationAt b := (trivializationAt R F₁ E₁ b).Prod R (trivializationAt R F₂ E₂ b)
  mem_base_set_trivialization_at b :=
    ⟨mem_base_set_trivialization_at R F₁ E₁ b, mem_base_set_trivialization_at R F₂ E₂ b⟩
  trivialization_mem_atlas b :=
    ⟨trivializationAt R F₁ E₁ b, trivializationAt R F₂ E₂ b, by infer_instance, by infer_instance, rfl⟩
  continuous_on_coord_change' := by
    rintro _ _ ⟨e₁, e₂, he₁, he₂, rfl⟩ ⟨e₁', e₂', he₁', he₂', rfl⟩
    skip
    refine'
        (((continuous_on_coord_change R e₁ e₁').mono _).prodMapL R ((continuous_on_coord_change R e₂ e₂').mono _)).congr
          _ <;>
      dsimp only [base_set_prod, mfld_simps]
    · mfld_set_tac
      
    · mfld_set_tac
      
    · rintro b hb
      rw [ContinuousLinearMap.ext_iff]
      rintro ⟨v₁, v₂⟩
      show
        (e₁.prod R e₂).coordChangeL R (e₁'.prod R e₂') b (v₁, v₂) =
          (e₁.coord_changeL R e₁' b v₁, e₂.coord_changeL R e₂' b v₂)
      rw [e₁.coord_changeL_apply e₁', e₂.coord_changeL_apply e₂', (e₁.prod R e₂).coord_changeL_apply']
      exacts[rfl, hb, ⟨hb.1.2, hb.2.2⟩, ⟨hb.1.1, hb.2.1⟩]
      
#align _root_.bundle.prod.topological_vector_bundle _root_.bundle.prod.topological_vector_bundle

instance _root_.bundle.prod.mem_trivialization_atlas {e₁ : Trivialization F₁ (π E₁)} {e₂ : Trivialization F₂ (π E₂)}
    [MemTrivializationAtlas R e₁] [MemTrivializationAtlas R e₂] :
    MemTrivializationAtlas R
      (e₁.Prod R e₂ :
        Trivialization (F₁ × F₂) (π (E₁ ×ᵇ E₂))) where out := ⟨e₁, e₂, by infer_instance, by infer_instance, rfl⟩
#align _root_.bundle.prod.mem_trivialization_atlas _root_.bundle.prod.mem_trivialization_atlas

variable {R F₁ E₁ F₂ E₂}

@[simp]
theorem Trivialization.continuous_linear_equiv_at_prod {e₁ : Trivialization F₁ (π E₁)} {e₂ : Trivialization F₂ (π E₂)}
    [e₁.is_linear R] [e₂.is_linear R] {x : B} (hx₁ : x ∈ e₁.BaseSet) (hx₂ : x ∈ e₂.BaseSet) :
    (e₁.Prod R e₂).continuousLinearEquivAt R x ⟨hx₁, hx₂⟩ =
      (e₁.continuousLinearEquivAt R x hx₁).Prod (e₂.continuousLinearEquivAt R x hx₂) :=
  by
  ext1
  funext v
  obtain ⟨v₁, v₂⟩ := v
  rw [(e₁.prod R e₂).continuous_linear_equiv_at_apply R, Trivialization.prod]
  exact (congr_arg Prod.snd (prod_apply R hx₁ hx₂ v₁ v₂) : _)
#align trivialization.continuous_linear_equiv_at_prod Trivialization.continuous_linear_equiv_at_prod

