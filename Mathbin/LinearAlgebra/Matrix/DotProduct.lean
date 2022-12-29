/-
Copyright (c) 2019 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Patrick Massot, Casper Putz, Anne Baanen

! This file was ported from Lean 3 source module linear_algebra.matrix.dot_product
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Matrix.Basic
import Mathbin.LinearAlgebra.StdBasis

/-!
# Dot product of two vectors

This file contains some results on the map `matrix.dot_product`, which maps two
vectors `v w : n → R` to the sum of the entrywise products `v i * w i`.

## Main results

* `matrix.dot_product_std_basis_one`: the dot product of `v` with the `i`th
  standard basis vector is `v i`
* `matrix.dot_product_eq_zero_iff`: if `v`'s' dot product with all `w` is zero,
  then `v` is zero

## Tags

matrix, reindex

-/


universe v w

namespace Matrix

variable {R : Type v} [Semiring R] {n : Type w} [Fintype n]

@[simp]
theorem dot_product_std_basis_eq_mul [DecidableEq n] (v : n → R) (c : R) (i : n) :
    dotProduct v (LinearMap.stdBasis R (fun _ => R) i c) = v i * c :=
  by
  rw [dot_product, Finset.sum_eq_single i, LinearMap.std_basis_same]
  exact fun _ _ hb => by rw [LinearMap.std_basis_ne _ _ _ _ hb, mul_zero]
  exact fun hi => False.elim (hi <| Finset.mem_univ _)
#align matrix.dot_product_std_basis_eq_mul Matrix.dot_product_std_basis_eq_mul

@[simp]
theorem dot_product_std_basis_one [DecidableEq n] (v : n → R) (i : n) :
    dotProduct v (LinearMap.stdBasis R (fun _ => R) i 1) = v i := by
  rw [dot_product_std_basis_eq_mul, mul_one]
#align matrix.dot_product_std_basis_one Matrix.dot_product_std_basis_one

theorem dot_product_eq (v w : n → R) (h : ∀ u, dotProduct v u = dotProduct w u) : v = w :=
  by
  funext x
  classical rw [← dot_product_std_basis_one v x, ← dot_product_std_basis_one w x, h]
#align matrix.dot_product_eq Matrix.dot_product_eq

theorem dot_product_eq_iff {v w : n → R} : (∀ u, dotProduct v u = dotProduct w u) ↔ v = w :=
  ⟨fun h => dot_product_eq v w h, fun h _ => h ▸ rfl⟩
#align matrix.dot_product_eq_iff Matrix.dot_product_eq_iff

theorem dot_product_eq_zero (v : n → R) (h : ∀ w, dotProduct v w = 0) : v = 0 :=
  (dot_product_eq _ _) fun u => (h u).symm ▸ (zero_dot_product u).symm
#align matrix.dot_product_eq_zero Matrix.dot_product_eq_zero

theorem dot_product_eq_zero_iff {v : n → R} : (∀ w, dotProduct v w = 0) ↔ v = 0 :=
  ⟨fun h => dot_product_eq_zero v h, fun h w => h.symm ▸ zero_dot_product w⟩
#align matrix.dot_product_eq_zero_iff Matrix.dot_product_eq_zero_iff

end Matrix

