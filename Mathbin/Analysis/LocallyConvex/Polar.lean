/-
Copyright (c) 2022 Moritz Doll. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Moritz Doll, Kalle Kytölä
-/
import Mathbin.Analysis.Normed.Field.Basic
import Mathbin.Analysis.Convex.Basic
import Mathbin.LinearAlgebra.SesquilinearForm
import Mathbin.Topology.Algebra.Module.WeakDual

/-!
# Polar set

In this file we define the polar set. There are different notions of the polar, we will define the
*absolute polar*. The advantage over the real polar is that we can define the absolute polar for
any bilinear form `B : E →ₗ[𝕜] F →ₗ[𝕜] 𝕜`, where `𝕜` is a normed commutative ring and
`E` and `F` are modules over `𝕜`.

## Main definitions

* `linear_map.polar`: The polar of a bilinear form `B : E →ₗ[𝕜] F →ₗ[𝕜] 𝕜`.

## Main statements

* `linear_map.polar_eq_Inter`: The polar as an intersection.
* `linear_map.subset_bipolar`: The polar is a subset of the bipolar.
* `linear_map.polar_weak_closed`: The polar is closed in the weak topology induced by `B.flip`.

## References

* [H. H. Schaefer, *Topological Vector Spaces*][schaefer1966]

## Tags

polar
-/


variable {𝕜 E F : Type _}

namespace LinearMap

section NormedRing

variable [NormedCommRing 𝕜] [AddCommMonoid E] [AddCommMonoid F]

variable [Module 𝕜 E] [Module 𝕜 F]

variable (B : E →ₗ[𝕜] F →ₗ[𝕜] 𝕜)

/-- The (absolute) polar of `s : set E` is given by the set of all `y : F` such that `∥B x y∥ ≤ 1`
for all `x ∈ s`.-/
def polar (s : Set E) : Set F :=
  { y : F | ∀ x ∈ s, ∥B x y∥ ≤ 1 }
#align linear_map.polar LinearMap.polar

theorem polar_mem_iff (s : Set E) (y : F) : y ∈ B.polar s ↔ ∀ x ∈ s, ∥B x y∥ ≤ 1 :=
  Iff.rfl
#align linear_map.polar_mem_iff LinearMap.polar_mem_iff

theorem polar_mem (s : Set E) (y : F) (hy : y ∈ B.polar s) : ∀ x ∈ s, ∥B x y∥ ≤ 1 :=
  hy
#align linear_map.polar_mem LinearMap.polar_mem

@[simp]
theorem zero_mem_polar (s : Set E) : (0 : F) ∈ B.polar s := fun _ _ => by simp only [map_zero, norm_zero, zero_le_one]
#align linear_map.zero_mem_polar LinearMap.zero_mem_polar

theorem polar_eq_Inter {s : Set E} : B.polar s = ⋂ x ∈ s, { y : F | ∥B x y∥ ≤ 1 } := by
  ext
  simp only [polar_mem_iff, Set.mem_Inter, Set.mem_set_of_eq]
#align linear_map.polar_eq_Inter LinearMap.polar_eq_Inter

/-- The map `B.polar : set E → set F` forms an order-reversing Galois connection with
`B.flip.polar : set F → set E`. We use `order_dual.to_dual` and `order_dual.of_dual` to express
that `polar` is order-reversing. -/
theorem polar_gc : GaloisConnection (OrderDual.toDual ∘ B.polar) (B.flip.polar ∘ OrderDual.ofDual) := fun s t =>
  ⟨fun h _ hx _ hy => h hy _ hx, fun h _ hx _ hy => h hy _ hx⟩
#align linear_map.polar_gc LinearMap.polar_gc

@[simp]
theorem polar_Union {ι} {s : ι → Set E} : B.polar (⋃ i, s i) = ⋂ i, B.polar (s i) :=
  B.polar_gc.l_supr
#align linear_map.polar_Union LinearMap.polar_Union

@[simp]
theorem polar_union {s t : Set E} : B.polar (s ∪ t) = B.polar s ∩ B.polar t :=
  B.polar_gc.l_sup
#align linear_map.polar_union LinearMap.polar_union

theorem polar_antitone : Antitone (B.polar : Set E → Set F) :=
  B.polar_gc.monotone_l
#align linear_map.polar_antitone LinearMap.polar_antitone

@[simp]
theorem polar_empty : B.polar ∅ = Set.univ :=
  B.polar_gc.l_bot
#align linear_map.polar_empty LinearMap.polar_empty

@[simp]
theorem polar_zero : B.polar ({0} : Set E) = Set.univ := by
  refine' set.eq_univ_iff_forall.mpr fun y x hx => _
  rw [set.mem_singleton_iff.mp hx, map_zero, LinearMap.zero_apply, norm_zero]
  exact zero_le_one
#align linear_map.polar_zero LinearMap.polar_zero

theorem subset_bipolar (s : Set E) : s ⊆ B.flip.polar (B.polar s) := fun x hx y hy => by
  rw [B.flip_apply]
  exact hy x hx
#align linear_map.subset_bipolar LinearMap.subset_bipolar

@[simp]
theorem tripolar_eq_polar (s : Set E) : B.polar (B.flip.polar (B.polar s)) = B.polar s := by
  refine' (B.polar_antitone (B.subset_bipolar s)).antisymm _
  convert subset_bipolar B.flip (B.polar s)
  exact B.flip_flip.symm
#align linear_map.tripolar_eq_polar LinearMap.tripolar_eq_polar

/-- The polar set is closed in the weak topology induced by `B.flip`. -/
theorem polarWeakClosed (s : Set E) : @IsClosed _ (WeakBilin.topologicalSpace B.flip) (B.polar s) := by
  rw [polar_eq_Inter]
  refine' isClosedInter fun x => isClosedInter fun _ => _
  exact isClosedLe (WeakBilin.eval_continuous B.flip x).norm continuous_const
#align linear_map.polar_weak_closed LinearMap.polarWeakClosed

end NormedRing

section NontriviallyNormedField

variable [NontriviallyNormedField 𝕜] [AddCommMonoid E] [AddCommMonoid F]

variable [Module 𝕜 E] [Module 𝕜 F]

variable (B : E →ₗ[𝕜] F →ₗ[𝕜] 𝕜)

theorem polar_univ (h : SeparatingRight B) : B.polar Set.univ = {(0 : F)} := by
  rw [Set.eq_singleton_iff_unique_mem]
  refine' ⟨by simp only [zero_mem_polar], fun y hy => h _ fun x => _⟩
  refine' norm_le_zero_iff.mp (le_of_forall_le_of_dense fun ε hε => _)
  rcases NormedField.exists_norm_lt 𝕜 hε with ⟨c, hc, hcε⟩
  calc
    ∥B x y∥ = ∥c∥ * ∥B (c⁻¹ • x) y∥ := by
      rw [B.map_smul, LinearMap.smul_apply, Algebra.id.smul_eq_mul, norm_mul, norm_inv, mul_inv_cancel_left₀ hc.ne']
    _ ≤ ε * 1 := mul_le_mul hcε.le (hy _ trivial) (norm_nonneg _) hε.le
    _ = ε := mul_one _
    
#align linear_map.polar_univ LinearMap.polar_univ

end NontriviallyNormedField

end LinearMap

