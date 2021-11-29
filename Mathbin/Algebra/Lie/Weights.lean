import Mathbin.Algebra.Lie.Nilpotent 
import Mathbin.Algebra.Lie.TensorProduct 
import Mathbin.Algebra.Lie.Character 
import Mathbin.Algebra.Lie.CartanSubalgebra 
import Mathbin.LinearAlgebra.Eigenspace 
import Mathbin.RingTheory.TensorProduct

/-!
# Weights and roots of Lie modules and Lie algebras

Just as a key tool when studying the behaviour of a linear operator is to decompose the space on
which it acts into a sum of (generalised) eigenspaces, a key tool when studying a representation `M`
of Lie algebra `L` is to decompose `M` into a sum of simultaneous eigenspaces of `x` as `x` ranges
over `L`. These simultaneous generalised eigenspaces are known as the weight spaces of `M`.

When `L` is nilpotent, it follows from the binomial theorem that weight spaces are Lie submodules.
Even when `L` is not nilpotent, it may be useful to study its representations by restricting them
to a nilpotent subalgebra (e.g., a Cartan subalgebra). In the particular case when we view `L` as a
module over itself via the adjoint action, the weight spaces of `L` restricted to a nilpotent
subalgebra are known as root spaces.

Basic definitions and properties of the above ideas are provided in this file.

## Main definitions

  * `lie_module.weight_space`
  * `lie_module.is_weight`
  * `lie_algebra.root_space`
  * `lie_algebra.is_root`
  * `lie_algebra.root_space_weight_space_product`
  * `lie_algebra.root_space_product`

## References

* [N. Bourbaki, *Lie Groups and Lie Algebras, Chapters 7--9*](bourbaki1975b)

## Tags

lie character, eigenvalue, eigenspace, weight, weight vector, root, root vector
-/


universe u v w w₁ w₂ w₃

variable{R : Type u}{L : Type v}[CommRingₓ R][LieRing L][LieAlgebra R L]

variable(H : LieSubalgebra R L)[LieAlgebra.IsNilpotent R H]

variable(M : Type w)[AddCommGroupₓ M][Module R M][LieRingModule L M][LieModule R L M]

namespace LieModule

open LieAlgebra

open TensorProduct

open TensorProduct.LieModule

open_locale BigOperators

open_locale TensorProduct

/-- Given a Lie module `M` over a Lie algebra `L`, the pre-weight space of `M` with respect to a
map `χ : L → R` is the simultaneous generalized eigenspace of the action of all `x : L` on `M`,
with eigenvalues `χ x`.

See also `lie_module.weight_space`. -/
def pre_weight_space (χ : L → R) : Submodule R M :=
  ⨅x : L, (to_endomorphism R L M x).maximalGeneralizedEigenspace (χ x)

theorem mem_pre_weight_space (χ : L → R) (m : M) :
  m ∈ pre_weight_space M χ ↔ ∀ x, ∃ k : ℕ, (to_endomorphism R L M x - χ x • 1^k) m = 0 :=
  by 
    simp [pre_weight_space, -LinearMap.pow_apply]

variable(L)

-- error in Algebra.Lie.Weights: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- See also `bourbaki1975b` Chapter VII §1.1, Proposition 2 (ii). -/
protected
theorem weight_vector_multiplication
(M₁ : Type w₁)
(M₂ : Type w₂)
(M₃ : Type w₃)
[add_comm_group M₁]
[module R M₁]
[lie_ring_module L M₁]
[lie_module R L M₁]
[add_comm_group M₂]
[module R M₂]
[lie_ring_module L M₂]
[lie_module R L M₂]
[add_comm_group M₃]
[module R M₃]
[lie_ring_module L M₃]
[lie_module R L M₃]
(g : «expr →ₗ⁅ , ⁆ »(«expr ⊗[ ] »(M₁, R, M₂), R, L, M₃))
(χ₁
 χ₂ : L → R) : «expr ≤ »(((g : «expr →ₗ[ ] »(«expr ⊗[ ] »(M₁, R, M₂), R, M₃)).comp (map_incl (pre_weight_space M₁ χ₁) (pre_weight_space M₂ χ₂))).range, pre_weight_space M₃ «expr + »(χ₁, χ₂)) :=
begin
  intros [ident m₃],
  simp [] [] ["only"] ["[", expr lie_module_hom.coe_to_linear_map, ",", expr pi.add_apply, ",", expr function.comp_app, ",", expr mem_pre_weight_space, ",", expr linear_map.coe_comp, ",", expr tensor_product.map_incl, ",", expr exists_imp_distrib, ",", expr linear_map.mem_range, "]"] [] [],
  rintros [ident t, ident rfl, ident x],
  let [ident F] [":", expr module.End R M₃] [":=", expr «expr - »(to_endomorphism R L M₃ x, «expr • »(«expr + »(χ₁ x, χ₂ x), 1))],
  change [expr «expr∃ , »((k), «expr = »(«expr ^ »(F, k) (g _), 0))] [] [],
  apply [expr t.induction_on],
  { use [expr 0],
    simp [] [] ["only"] ["[", expr linear_map.map_zero, ",", expr lie_module_hom.map_zero, "]"] [] [] },
  swap,
  { rintros [ident t₁, ident t₂, "⟨", ident k₁, ",", ident hk₁, "⟩", "⟨", ident k₂, ",", ident hk₂, "⟩"],
    use [expr max k₁ k₂],
    simp [] [] ["only"] ["[", expr lie_module_hom.map_add, ",", expr linear_map.map_add, ",", expr linear_map.pow_map_zero_of_le (le_max_left k₁ k₂) hk₁, ",", expr linear_map.pow_map_zero_of_le (le_max_right k₁ k₂) hk₂, ",", expr add_zero, "]"] [] [] },
  rintros ["⟨", ident m₁, ",", ident hm₁, "⟩", "⟨", ident m₂, ",", ident hm₂, "⟩"],
  change [expr «expr∃ , »((k), «expr = »(«expr ^ »(F, k) ((g : «expr →ₗ[ ] »(«expr ⊗[ ] »(M₁, R, M₂), R, M₃)) «expr ⊗ₜ »(m₁, m₂)), 0))] [] [],
  let [ident f₁] [":", expr module.End R «expr ⊗[ ] »(M₁, R, M₂)] [":=", expr «expr - »(to_endomorphism R L M₁ x, «expr • »(χ₁ x, 1)).rtensor M₂],
  let [ident f₂] [":", expr module.End R «expr ⊗[ ] »(M₁, R, M₂)] [":=", expr «expr - »(to_endomorphism R L M₂ x, «expr • »(χ₂ x, 1)).ltensor M₁],
  have [ident h_comm_square] [":", expr «expr = »(«expr ∘ₗ »(F, «expr↑ »(g)), (g : «expr →ₗ[ ] »(«expr ⊗[ ] »(M₁, R, M₂), R, M₃)).comp «expr + »(f₁, f₂))] [],
  { ext [] [ident m₁, ident m₂] [],
    simp [] [] ["only"] ["[", "<-", expr g.map_lie x «expr ⊗ₜ »(m₁, m₂), ",", expr add_smul, ",", expr sub_tmul, ",", expr tmul_sub, ",", expr smul_tmul, ",", expr lie_tmul_right, ",", expr tmul_smul, ",", expr to_endomorphism_apply_apply, ",", expr lie_module_hom.map_smul, ",", expr linear_map.one_apply, ",", expr lie_module_hom.coe_to_linear_map, ",", expr linear_map.smul_apply, ",", expr function.comp_app, ",", expr linear_map.coe_comp, ",", expr linear_map.rtensor_tmul, ",", expr lie_module_hom.map_add, ",", expr linear_map.add_apply, ",", expr lie_module_hom.map_sub, ",", expr linear_map.sub_apply, ",", expr linear_map.ltensor_tmul, ",", expr algebra_tensor_module.curry_apply, ",", expr curry_apply, ",", expr linear_map.to_fun_eq_coe, ",", expr linear_map.coe_restrict_scalars_eq_coe, "]"] [] [],
    abel [] [] [] },
  suffices [] [":", expr «expr∃ , »((k), «expr = »(«expr ^ »(«expr + »(f₁, f₂), k) «expr ⊗ₜ »(m₁, m₂), 0))],
  { obtain ["⟨", ident k, ",", ident hk, "⟩", ":=", expr this],
    use [expr k],
    rw ["[", "<-", expr linear_map.comp_apply, ",", expr linear_map.commute_pow_left_of_commute h_comm_square, ",", expr linear_map.comp_apply, ",", expr hk, ",", expr linear_map.map_zero, "]"] [] },
  simp [] [] ["only"] ["[", expr mem_pre_weight_space, "]"] [] ["at", ident hm₁, ident hm₂],
  obtain ["⟨", ident k₁, ",", ident hk₁, "⟩", ":=", expr hm₁ x],
  obtain ["⟨", ident k₂, ",", ident hk₂, "⟩", ":=", expr hm₂ x],
  have [ident hf₁] [":", expr «expr = »(«expr ^ »(f₁, k₁) «expr ⊗ₜ »(m₁, m₂), 0)] [],
  { simp [] [] ["only"] ["[", expr hk₁, ",", expr zero_tmul, ",", expr linear_map.rtensor_tmul, ",", expr linear_map.rtensor_pow, "]"] [] [] },
  have [ident hf₂] [":", expr «expr = »(«expr ^ »(f₂, k₂) «expr ⊗ₜ »(m₁, m₂), 0)] [],
  { simp [] [] ["only"] ["[", expr hk₂, ",", expr tmul_zero, ",", expr linear_map.ltensor_tmul, ",", expr linear_map.ltensor_pow, "]"] [] [] },
  use [expr «expr - »(«expr + »(k₁, k₂), 1)],
  have [ident hf_comm] [":", expr commute f₁ f₂] [],
  { ext [] [ident m₁, ident m₂] [],
    simp [] [] ["only"] ["[", expr linear_map.mul_apply, ",", expr linear_map.rtensor_tmul, ",", expr linear_map.ltensor_tmul, ",", expr algebra_tensor_module.curry_apply, ",", expr linear_map.to_fun_eq_coe, ",", expr linear_map.ltensor_tmul, ",", expr curry_apply, ",", expr linear_map.coe_restrict_scalars_eq_coe, "]"] [] [] },
  rw [expr hf_comm.add_pow'] [],
  simp [] [] ["only"] ["[", expr tensor_product.map_incl, ",", expr submodule.subtype_apply, ",", expr finset.sum_apply, ",", expr submodule.coe_mk, ",", expr linear_map.coe_fn_sum, ",", expr tensor_product.map_tmul, ",", expr linear_map.smul_apply, "]"] [] [],
  apply [expr finset.sum_eq_zero],
  rintros ["⟨", ident i, ",", ident j, "⟩", ident hij],
  suffices [] [":", expr «expr = »(«expr * »(«expr ^ »(f₁, i), «expr ^ »(f₂, j)) «expr ⊗ₜ »(m₁, m₂), 0)],
  { rw [expr this] [],
    apply [expr smul_zero] },
  cases [expr nat.le_or_le_of_add_eq_add_pred (finset.nat.mem_antidiagonal.mp hij)] ["with", ident hi, ident hj],
  { rw ["[", expr (hf_comm.pow_pow i j).eq, ",", expr linear_map.mul_apply, ",", expr linear_map.pow_map_zero_of_le hi hf₁, ",", expr linear_map.map_zero, "]"] [] },
  { rw ["[", expr linear_map.mul_apply, ",", expr linear_map.pow_map_zero_of_le hj hf₂, ",", expr linear_map.map_zero, "]"] [] }
end

variable{L M}

theorem lie_mem_pre_weight_space_of_mem_pre_weight_space {χ₁ χ₂ : L → R} {x : L} {m : M}
  (hx : x ∈ pre_weight_space L χ₁) (hm : m ∈ pre_weight_space M χ₂) : ⁅x,m⁆ ∈ pre_weight_space M (χ₁+χ₂) :=
  by 
    apply LieModule.weight_vector_multiplication L L M M (to_module_hom R L M) χ₁ χ₂ 
    simp only [LieModuleHom.coe_to_linear_map, Function.comp_app, LinearMap.coe_comp, TensorProduct.mapIncl,
      LinearMap.mem_range]
    use ⟨x, hx⟩ ⊗ₜ ⟨m, hm⟩
    simp only [Submodule.subtype_apply, to_module_hom_apply, TensorProduct.map_tmul]
    rfl

variable(M)

/-- If a Lie algebra is nilpotent, then pre-weight spaces are Lie submodules. -/
def weight_space [LieAlgebra.IsNilpotent R L] (χ : L → R) : LieSubmodule R L M :=
  { pre_weight_space M χ with
    lie_mem :=
      fun x m hm =>
        by 
          rw [←zero_addₓ χ]
          refine' lie_mem_pre_weight_space_of_mem_pre_weight_space _ hm 
          suffices  : pre_weight_space L (0 : L → R) = ⊤
          ·
            simp only [this, Submodule.mem_top]
          exact LieAlgebra.infi_max_gen_zero_eigenspace_eq_top_of_nilpotent R L }

theorem mem_weight_space [LieAlgebra.IsNilpotent R L] (χ : L → R) (m : M) :
  m ∈ weight_space M χ ↔ m ∈ pre_weight_space M χ :=
  Iff.rfl

/-- See also the more useful form `lie_module.zero_weight_space_eq_top_of_nilpotent`. -/
@[simp]
theorem zero_weight_space_eq_top_of_nilpotent' [LieAlgebra.IsNilpotent R L] [IsNilpotent R L M] :
  weight_space M (0 : L → R) = ⊤ :=
  by 
    rw [←LieSubmodule.coe_to_submodule_eq_iff, LieSubmodule.top_coe_submodule]
    exact infi_max_gen_zero_eigenspace_eq_top_of_nilpotent R L M

theorem coe_weight_space_of_top [LieAlgebra.IsNilpotent R L] (χ : L → R) :
  (weight_space M (χ ∘ (⊤ : LieSubalgebra R L).incl) : Submodule R M) = weight_space M χ :=
  by 
    ext m 
    simp only [weight_space, LieSubmodule.coe_to_submodule_mk, LieSubalgebra.coe_bracket_of_module, Function.comp_app,
      mem_pre_weight_space]
    split  <;> intro h x
    ·
      obtain ⟨k, hk⟩ := h ⟨x, Set.mem_univ x⟩
      use k 
      exact hk
    ·
      obtain ⟨k, hk⟩ := h x 
      use k 
      exact hk

-- error in Algebra.Lie.Weights: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem zero_weight_space_eq_top_of_nilpotent
[lie_algebra.is_nilpotent R L]
[is_nilpotent R L M] : «expr = »(weight_space M (0 : («expr⊤»() : lie_subalgebra R L) → R), «expr⊤»()) :=
begin
  have [ident h₀] [":", expr «expr = »(«expr ∘ »((0 : L → R), («expr⊤»() : lie_subalgebra R L).incl), 0)] [],
  { ext [] [] [],
    refl },
  rw ["[", "<-", expr lie_submodule.coe_to_submodule_eq_iff, ",", expr lie_submodule.top_coe_submodule, ",", "<-", expr h₀, ",", expr coe_weight_space_of_top, ",", "<-", expr infi_max_gen_zero_eigenspace_eq_top_of_nilpotent R L M, "]"] [],
  refl
end

/-- Given a Lie module `M` of a Lie algebra `L`, a weight of `M` with respect to a nilpotent
subalgebra `H ⊆ L` is a Lie character whose corresponding weight space is non-empty. -/
def is_weight (χ : lie_character R H) : Prop :=
  weight_space M χ ≠ ⊥

/-- For a non-trivial nilpotent Lie module over a nilpotent Lie algebra, the zero character is a
weight with respect to the `⊤` Lie subalgebra. -/
theorem is_weight_zero_of_nilpotent [Nontrivial M] [LieAlgebra.IsNilpotent R L] [IsNilpotent R L M] :
  is_weight (⊤ : LieSubalgebra R L) M 0 :=
  by 
    rw [is_weight, LieHom.coe_zero, zero_weight_space_eq_top_of_nilpotent]
    exact top_ne_bot

end LieModule

namespace LieAlgebra

open_locale TensorProduct

open TensorProduct.LieModule

open LieModule

/-- Given a nilpotent Lie subalgebra `H ⊆ L`, the root space of a map `χ : H → R` is the weight
space of `L` regarded as a module of `H` via the adjoint action. -/
abbrev root_space (χ : H → R) : LieSubmodule R H L :=
  weight_space L χ

@[simp]
theorem zero_root_space_eq_top_of_nilpotent [h : IsNilpotent R L] : root_space (⊤ : LieSubalgebra R L) 0 = ⊤ :=
  zero_weight_space_eq_top_of_nilpotent L

/-- A root of a Lie algebra `L` with respect to a nilpotent subalgebra `H ⊆ L` is a weight of `L`,
regarded as a module of `H` via the adjoint action. -/
abbrev is_root :=
  is_weight H L

-- error in Algebra.Lie.Weights: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem root_space_comap_eq_weight_space (χ : H → R) : «expr = »((root_space H χ).comap H.incl', weight_space H χ) :=
begin
  ext [] [ident x] [],
  let [ident f] [":", expr H → module.End R L] [":=", expr λ y, «expr - »(to_endomorphism R H L y, «expr • »(χ y, 1))],
  let [ident g] [":", expr H → module.End R H] [":=", expr λ y, «expr - »(to_endomorphism R H H y, «expr • »(χ y, 1))],
  suffices [] [":", expr «expr ↔ »(∀
    y : H, «expr∃ , »((k : exprℕ()), «expr = »(«expr ^ »(f y, k).comp (H.incl : «expr →ₗ[ ] »(H, R, L)) x, 0)), ∀
    y : H, «expr∃ , »((k : exprℕ()), «expr = »((H.incl : «expr →ₗ[ ] »(H, R, L)).comp «expr ^ »(g y, k) x, 0)))],
  { simp [] [] ["only"] ["[", expr lie_hom.coe_to_linear_map, ",", expr lie_subalgebra.coe_incl, ",", expr function.comp_app, ",", expr linear_map.coe_comp, ",", expr submodule.coe_eq_zero, "]"] [] ["at", ident this],
    simp [] [] ["only"] ["[", expr mem_weight_space, ",", expr mem_pre_weight_space, ",", expr lie_subalgebra.coe_incl', ",", expr lie_submodule.mem_comap, ",", expr this, "]"] [] [] },
  have [ident hfg] [":", expr ∀
   y : H, «expr = »((f y).comp (H.incl : «expr →ₗ[ ] »(H, R, L)), (H.incl : «expr →ₗ[ ] »(H, R, L)).comp (g y))] [],
  { rintros ["⟨", ident y, ",", ident hy, "⟩"],
    ext [] ["⟨", ident z, ",", ident hz, "⟩"] [],
    simp [] [] ["only"] ["[", expr submodule.coe_sub, ",", expr to_endomorphism_apply_apply, ",", expr lie_hom.coe_to_linear_map, ",", expr linear_map.one_apply, ",", expr lie_subalgebra.coe_incl, ",", expr lie_subalgebra.coe_bracket_of_module, ",", expr lie_subalgebra.coe_bracket, ",", expr linear_map.smul_apply, ",", expr function.comp_app, ",", expr submodule.coe_smul_of_tower, ",", expr linear_map.coe_comp, ",", expr linear_map.sub_apply, "]"] [] [] },
  simp_rw ["[", expr linear_map.commute_pow_left_of_commute (hfg _), "]"] []
end

variable{H M}

theorem lie_mem_weight_space_of_mem_weight_space {χ₁ χ₂ : H → R} {x : L} {m : M} (hx : x ∈ root_space H χ₁)
  (hm : m ∈ weight_space M χ₂) : ⁅x,m⁆ ∈ weight_space M (χ₁+χ₂) :=
  by 
    apply LieModule.weight_vector_multiplication H L M M ((to_module_hom R L M).restrictLie H) χ₁ χ₂ 
    simp only [LieModuleHom.coe_to_linear_map, Function.comp_app, LinearMap.coe_comp, TensorProduct.mapIncl,
      LinearMap.mem_range]
    use ⟨x, hx⟩ ⊗ₜ ⟨m, hm⟩
    simp only [Submodule.subtype_apply, to_module_hom_apply, Submodule.coe_mk, LieModuleHom.coe_restrict_lie,
      TensorProduct.map_tmul]

variable(R L H M)

/--
Auxiliary definition for `root_space_weight_space_product`,
which is close to the deterministic timeout limit.
-/
def root_space_weight_space_product_aux {χ₁ χ₂ χ₃ : H → R} (hχ : (χ₁+χ₂) = χ₃) :
  root_space H χ₁ →ₗ[R] weight_space M χ₂ →ₗ[R] weight_space M χ₃ :=
  { toFun :=
      fun x =>
        { toFun := fun m => ⟨⁅(x : L),(m : M)⁆, hχ ▸ lie_mem_weight_space_of_mem_weight_space x.property m.property⟩,
          map_add' :=
            fun m n =>
              by 
                simp only [LieSubmodule.coe_add, lie_add]
                rfl,
          map_smul' :=
            fun t m =>
              by 
                convLHS => congr rw [LieSubmodule.coe_smul, lie_smul]
                rfl },
    map_add' :=
      fun x y =>
        by 
          ext m <;>
            rw [LinearMap.add_apply, LinearMap.coe_mk, LinearMap.coe_mk, LinearMap.coe_mk, Subtype.coe_mk,
              LieSubmodule.coe_add, LieSubmodule.coe_add, add_lie, Subtype.coe_mk, Subtype.coe_mk],
    map_smul' :=
      fun t x =>
        by 
          simp only [RingHom.id_apply]
          ext m 
          rw [LinearMap.smul_apply, LinearMap.coe_mk, LinearMap.coe_mk, Subtype.coe_mk, LieSubmodule.coe_smul, smul_lie,
            LieSubmodule.coe_smul, Subtype.coe_mk] }

/-- Given a nilpotent Lie subalgebra `H ⊆ L` together with `χ₁ χ₂ : H → R`, there is a natural
`R`-bilinear product of root vectors and weight vectors, compatible with the actions of `H`. -/
def root_space_weight_space_product (χ₁ χ₂ χ₃ : H → R) (hχ : (χ₁+χ₂) = χ₃) :
  root_space H χ₁ ⊗[R] weight_space M χ₂ →ₗ⁅R,H⁆ weight_space M χ₃ :=
  lift_lie R H (root_space H χ₁) (weight_space M χ₂) (weight_space M χ₃)
    { toLinearMap := root_space_weight_space_product_aux R L H M hχ,
      map_lie' :=
        fun x y =>
          by 
            ext m <;>
              rw [root_space_weight_space_product_aux, LieHom.lie_apply, LieSubmodule.coe_sub, LinearMap.coe_mk,
                LinearMap.coe_mk, Subtype.coe_mk, Subtype.coe_mk, LieSubmodule.coe_bracket, LieSubmodule.coe_bracket,
                Subtype.coe_mk, LieSubalgebra.coe_bracket_of_module, LieSubalgebra.coe_bracket_of_module,
                LieSubmodule.coe_bracket, LieSubalgebra.coe_bracket_of_module, lie_lie] }

@[simp]
theorem coe_root_space_weight_space_product_tmul (χ₁ χ₂ χ₃ : H → R) (hχ : (χ₁+χ₂) = χ₃) (x : root_space H χ₁)
  (m : weight_space M χ₂) : (root_space_weight_space_product R L H M χ₁ χ₂ χ₃ hχ (x ⊗ₜ m) : M) = ⁅(x : L),(m : M)⁆ :=
  by 
    simp only [root_space_weight_space_product, root_space_weight_space_product_aux, lift_apply,
      LieModuleHom.coe_to_linear_map, coe_lift_lie_eq_lift_coe, Submodule.coe_mk, LinearMap.coe_mk, LieModuleHom.coe_mk]

/-- Given a nilpotent Lie subalgebra `H ⊆ L` together with `χ₁ χ₂ : H → R`, there is a natural
`R`-bilinear product of root vectors, compatible with the actions of `H`. -/
def root_space_product (χ₁ χ₂ χ₃ : H → R) (hχ : (χ₁+χ₂) = χ₃) :
  root_space H χ₁ ⊗[R] root_space H χ₂ →ₗ⁅R,H⁆ root_space H χ₃ :=
  root_space_weight_space_product R L H L χ₁ χ₂ χ₃ hχ

@[simp]
theorem root_space_product_def : root_space_product R L H = root_space_weight_space_product R L H L :=
  rfl

theorem root_space_product_tmul (χ₁ χ₂ χ₃ : H → R) (hχ : (χ₁+χ₂) = χ₃) (x : root_space H χ₁) (y : root_space H χ₂) :
  (root_space_product R L H χ₁ χ₂ χ₃ hχ (x ⊗ₜ y) : L) = ⁅(x : L),(y : L)⁆ :=
  by 
    simp only [root_space_product_def, coe_root_space_weight_space_product_tmul]

/-- Given a nilpotent Lie subalgebra `H ⊆ L`, the root space of the zero map `0 : H → R` is a Lie
subalgebra of `L`. -/
def zero_root_subalgebra : LieSubalgebra R L :=
  { (root_space H 0 : Submodule R L) with
    lie_mem' :=
      fun x y hx hy =>
        by 
          let xy : root_space H 0 ⊗[R] root_space H 0 := ⟨x, hx⟩ ⊗ₜ ⟨y, hy⟩
          suffices  : (root_space_product R L H 0 0 0 (add_zeroₓ 0) xy : L) ∈ root_space H 0
          ·
            rwa [root_space_product_tmul, Subtype.coe_mk, Subtype.coe_mk] at this 
          exact (root_space_product R L H 0 0 0 (add_zeroₓ 0) xy).property }

@[simp]
theorem coe_zero_root_subalgebra : (zero_root_subalgebra R L H : Submodule R L) = root_space H 0 :=
  rfl

theorem mem_zero_root_subalgebra (x : L) :
  x ∈ zero_root_subalgebra R L H ↔ ∀ (y : H), ∃ k : ℕ, (to_endomorphism R H L y^k) x = 0 :=
  by 
    simp only [zero_root_subalgebra, mem_weight_space, mem_pre_weight_space, Pi.zero_apply, sub_zero, SetLike.mem_coe,
      zero_smul, LieSubmodule.mem_coe_submodule, Submodule.mem_carrier, LieSubalgebra.mem_mk_iff]

-- error in Algebra.Lie.Weights: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem to_lie_submodule_le_root_space_zero : «expr ≤ »(H.to_lie_submodule, root_space H 0) :=
begin
  intros [ident x, ident hx],
  simp [] [] ["only"] ["[", expr lie_subalgebra.mem_to_lie_submodule, "]"] [] ["at", ident hx],
  simp [] [] ["only"] ["[", expr mem_weight_space, ",", expr mem_pre_weight_space, ",", expr pi.zero_apply, ",", expr sub_zero, ",", expr zero_smul, "]"] [] [],
  intros [ident y],
  unfreezingI { obtain ["⟨", ident k, ",", ident hk, "⟩", ":=", expr (infer_instance : is_nilpotent R H)] },
  use [expr k],
  let [ident f] [":", expr module.End R H] [":=", expr to_endomorphism R H H y],
  let [ident g] [":", expr module.End R L] [":=", expr to_endomorphism R H L y],
  have [ident hfg] [":", expr «expr = »(g.comp (H : submodule R L).subtype, (H : submodule R L).subtype.comp f)] [],
  { ext [] [ident z] [],
    simp [] [] ["only"] ["[", expr to_endomorphism_apply_apply, ",", expr submodule.subtype_apply, ",", expr lie_subalgebra.coe_bracket_of_module, ",", expr lie_subalgebra.coe_bracket, ",", expr function.comp_app, ",", expr linear_map.coe_comp, "]"] [] [] },
  change [expr «expr = »(«expr ^ »(g, k).comp (H : submodule R L).subtype ⟨x, hx⟩, 0)] [] [],
  rw [expr linear_map.commute_pow_left_of_commute hfg k] [],
  have [ident h] [] [":=", expr iterate_to_endomorphism_mem_lower_central_series R H H y ⟨x, hx⟩ k],
  rw ["[", expr hk, ",", expr lie_submodule.mem_bot, "]"] ["at", ident h],
  simp [] [] ["only"] ["[", expr submodule.subtype_apply, ",", expr function.comp_app, ",", expr linear_map.pow_apply, ",", expr linear_map.coe_comp, ",", expr submodule.coe_eq_zero, "]"] [] [],
  exact [expr h]
end

theorem le_zero_root_subalgebra : H ≤ zero_root_subalgebra R L H :=
  by 
    rw [←LieSubalgebra.coe_submodule_le_coe_submodule, ←H.coe_to_lie_submodule, coe_zero_root_subalgebra,
      LieSubmodule.coe_submodule_le_coe_submodule]
    exact to_lie_submodule_le_root_space_zero R L H

@[simp]
theorem zero_root_subalgebra_normalizer_eq_self :
  (zero_root_subalgebra R L H).normalizer = zero_root_subalgebra R L H :=
  by 
    refine' le_antisymmₓ _ (LieSubalgebra.le_normalizer _)
    intro x hx 
    rw [LieSubalgebra.mem_normalizer_iff] at hx 
    rw [mem_zero_root_subalgebra]
    rintro ⟨y, hy⟩
    specialize hx y (le_zero_root_subalgebra R L H hy)
    rw [mem_zero_root_subalgebra] at hx 
    obtain ⟨k, hk⟩ := hx ⟨y, hy⟩
    rw [←lie_skew, LinearMap.map_neg, neg_eq_zero] at hk 
    use k+1
    rw [LinearMap.iterate_succ, LinearMap.coe_comp, Function.comp_app, to_endomorphism_apply_apply,
      LieSubalgebra.coe_bracket_of_module, Submodule.coe_mk, hk]

/-- In finite dimensions over a field (and possibly more generally) Engel's theorem shows that
the converse of this is also true, i.e.,
`zero_root_subalgebra R L H = H ↔ lie_subalgebra.is_cartan_subalgebra H`. -/
theorem zero_root_subalgebra_is_cartan_of_eq (h : zero_root_subalgebra R L H = H) :
  LieSubalgebra.IsCartanSubalgebra H :=
  { nilpotent := inferInstance,
    self_normalizing :=
      by 
        rw [←h]
        exact zero_root_subalgebra_normalizer_eq_self R L H }

end LieAlgebra

namespace LieModule

open LieAlgebra

variable{R L H}

-- error in Algebra.Lie.Weights: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- A priori, weight spaces are Lie submodules over the Lie subalgebra `H` used to define them.
However they are naturally Lie submodules over the (in general larger) Lie subalgebra
`zero_root_subalgebra R L H`. Even though it is often the case that
`zero_root_subalgebra R L H = H`, it is likely to be useful to have the flexibility not to have
to invoke this equality (as well as to work more generally). -/
def weight_space' (χ : H → R) : lie_submodule R (zero_root_subalgebra R L H) M :=
{ lie_mem := λ x m hm, by { have [ident hx] [":", expr «expr ∈ »((x : L), root_space H 0)] [],
    { rw ["[", "<-", expr lie_submodule.mem_coe_submodule, ",", "<-", expr coe_zero_root_subalgebra, "]"] [],
      exact [expr x.property] },
    rw ["<-", expr zero_add χ] [],
    exact [expr lie_mem_weight_space_of_mem_weight_space hx hm] },
  ..(weight_space M χ : submodule R M) }

@[simp]
theorem coe_weight_space' (χ : H → R) : (weight_space' M χ : Submodule R M) = weight_space M χ :=
  rfl

end LieModule

