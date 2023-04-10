/-
Copyright (c) 2022 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module topology.metric_space.pi_nat
! leanprover-community/mathlib commit e1a7bdeb4fd826b7e71d130d34988f0a2d26a177
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.RingExp
import Mathbin.Topology.MetricSpace.HausdorffDistance

/-!
# Topological study of spaces `Π (n : ℕ), E n`

When `E n` are topological spaces, the space `Π (n : ℕ), E n` is naturally a topological space
(with the product topology). When `E n` are uniform spaces, it also inherits a uniform structure.
However, it does not inherit a canonical metric space structure of the `E n`. Nevertheless, one
can put a noncanonical metric space structure (or rather, several of them). This is done in this
file.

## Main definitions and results

One can define a combinatorial distance on `Π (n : ℕ), E n`, as follows:

* `pi_nat.cylinder x n` is the set of points `y` with `x i = y i` for `i < n`.
* `pi_nat.first_diff x y` is the first index at which `x i ≠ y i`.
* `pi_nat.dist x y` is equal to `(1/2) ^ (first_diff x y)`. It defines a distance
  on `Π (n : ℕ), E n`, compatible with the topology when the `E n` have the discrete topology.
* `pi_nat.metric_space`: the metric space structure, given by this distance. Not registered as an
  instance. This space is a complete metric space.
* `pi_nat.metric_space_of_discrete_uniformity`: the same metric space structure, but adjusting the
  uniformity defeqness when the `E n` already have the discrete uniformity. Not registered as an
  instance
* `pi_nat.metric_space_nat_nat`: the particular case of `ℕ → ℕ`, not registered as an instance.

These results are used to construct continuous functions on `Π n, E n`:

* `pi_nat.exists_retraction_of_is_closed`: given a nonempty closed subset `s` of `Π (n : ℕ), E n`,
  there exists a retraction onto `s`, i.e., a continuous map from the whole space to `s`
  restricting to the identity on `s`.
* `exists_nat_nat_continuous_surjective_of_complete_space`: given any nonempty complete metric
  space with second-countable topology, there exists a continuous surjection from `ℕ → ℕ` onto
  this space.

One can also put distances on `Π (i : ι), E i` when the spaces `E i` are metric spaces (not discrete
in general), and `ι` is countable.

* `pi_countable.dist` is the distance on `Π i, E i` given by
    `dist x y = ∑' i, min (1/2)^(encode i) (dist (x i) (y i))`.
* `pi_countable.metric_space` is the corresponding metric space structure, adjusted so that
  the uniformity is definitionally the product uniformity. Not registered as an instance.
-/


noncomputable section

open Classical Topology Filter

open TopologicalSpace Set Metric Filter Function

attribute [local simp] pow_le_pow_iff one_lt_two inv_le_inv

variable {E : ℕ → Type _}

namespace PiNat

/-! ### The first_diff function -/


#print PiNat.firstDiff /-
/-- In a product space `Π n, E n`, then `first_diff x y` is the first index at which `x` and `y`
differ. If `x = y`, then by convention we set `first_diff x x = 0`. -/
@[pp_nodot]
irreducible_def firstDiff (x y : ∀ n, E n) : ℕ :=
  if h : x ≠ y then Nat.find (ne_iff.1 h) else 0
#align pi_nat.first_diff PiNat.firstDiff
-/

#print PiNat.apply_firstDiff_ne /-
theorem apply_firstDiff_ne {x y : ∀ n, E n} (h : x ≠ y) : x (firstDiff x y) ≠ y (firstDiff x y) :=
  by
  rw [first_diff, dif_pos h]
  exact Nat.find_spec (ne_iff.1 h)
#align pi_nat.apply_first_diff_ne PiNat.apply_firstDiff_ne
-/

#print PiNat.apply_eq_of_lt_firstDiff /-
theorem apply_eq_of_lt_firstDiff {x y : ∀ n, E n} {n : ℕ} (hn : n < firstDiff x y) : x n = y n :=
  by
  rw [first_diff] at hn
  split_ifs  at hn
  · convert Nat.find_min (ne_iff.1 h) hn
    simp
  · exact (not_lt_zero' hn).elim
#align pi_nat.apply_eq_of_lt_first_diff PiNat.apply_eq_of_lt_firstDiff
-/

#print PiNat.firstDiff_comm /-
theorem firstDiff_comm (x y : ∀ n, E n) : firstDiff x y = firstDiff y x :=
  by
  rcases eq_or_ne x y with (rfl | hxy); · rfl
  rcases lt_trichotomy (first_diff x y) (first_diff y x) with (h | h | h)
  · exact (apply_first_diff_ne hxy (apply_eq_of_lt_first_diff h).symm).elim
  · exact h
  · exact (apply_first_diff_ne hxy.symm (apply_eq_of_lt_first_diff h).symm).elim
#align pi_nat.first_diff_comm PiNat.firstDiff_comm
-/

/- warning: pi_nat.min_first_diff_le -> PiNat.min_firstDiff_le is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (y : forall (n : Nat), E n) (z : forall (n : Nat), E n), (Ne.{succ u1} (forall (n : Nat), E n) x z) -> (LE.le.{0} Nat Nat.hasLe (LinearOrder.min.{0} Nat Nat.linearOrder (PiNat.firstDiff.{u1} (fun (n : Nat) => E n) x y) (PiNat.firstDiff.{u1} (fun (n : Nat) => E n) y z)) (PiNat.firstDiff.{u1} (fun (n : Nat) => E n) x z))
but is expected to have type
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (y : forall (n : Nat), E n) (z : forall (n : Nat), E n), (Ne.{succ u1} (forall (n : Nat), E n) x z) -> (LE.le.{0} Nat instLENat (Min.min.{0} Nat instMinNat (PiNat.firstDiff.{u1} (fun (n : Nat) => E n) x y) (PiNat.firstDiff.{u1} (fun (n : Nat) => E n) y z)) (PiNat.firstDiff.{u1} (fun (n : Nat) => E n) x z))
Case conversion may be inaccurate. Consider using '#align pi_nat.min_first_diff_le PiNat.min_firstDiff_leₓ'. -/
theorem min_firstDiff_le (x y z : ∀ n, E n) (h : x ≠ z) :
    min (firstDiff x y) (firstDiff y z) ≤ firstDiff x z :=
  by
  by_contra' H
  have : x (first_diff x z) = z (first_diff x z) :=
    calc
      x (first_diff x z) = y (first_diff x z) :=
        apply_eq_of_lt_first_diff (H.trans_le (min_le_left _ _))
      _ = z (first_diff x z) := apply_eq_of_lt_first_diff (H.trans_le (min_le_right _ _))
      
  exact (apply_first_diff_ne h this).elim
#align pi_nat.min_first_diff_le PiNat.min_firstDiff_le

/-! ### Cylinders -/


#print PiNat.cylinder /-
/-- In a product space `Π n, E n`, the cylinder set of length `n` around `x`, denoted
`cylinder x n`, is the set of sequences `y` that coincide with `x` on the first `n` symbols, i.e.,
such that `y i = x i` for all `i < n`.
-/
def cylinder (x : ∀ n, E n) (n : ℕ) : Set (∀ n, E n) :=
  { y | ∀ i, i < n → y i = x i }
#align pi_nat.cylinder PiNat.cylinder
-/

#print PiNat.cylinder_eq_pi /-
theorem cylinder_eq_pi (x : ∀ n, E n) (n : ℕ) :
    cylinder x n = Set.pi (Finset.range n : Set ℕ) fun i : ℕ => {x i} :=
  by
  ext y
  simp [cylinder]
#align pi_nat.cylinder_eq_pi PiNat.cylinder_eq_pi
-/

#print PiNat.cylinder_zero /-
@[simp]
theorem cylinder_zero (x : ∀ n, E n) : cylinder x 0 = univ := by simp [cylinder_eq_pi]
#align pi_nat.cylinder_zero PiNat.cylinder_zero
-/

#print PiNat.cylinder_anti /-
theorem cylinder_anti (x : ∀ n, E n) {m n : ℕ} (h : m ≤ n) : cylinder x n ⊆ cylinder x m :=
  fun y hy i hi => hy i (hi.trans_le h)
#align pi_nat.cylinder_anti PiNat.cylinder_anti
-/

#print PiNat.mem_cylinder_iff /-
@[simp]
theorem mem_cylinder_iff {x y : ∀ n, E n} {n : ℕ} : y ∈ cylinder x n ↔ ∀ i, i < n → y i = x i :=
  Iff.rfl
#align pi_nat.mem_cylinder_iff PiNat.mem_cylinder_iff
-/

#print PiNat.self_mem_cylinder /-
theorem self_mem_cylinder (x : ∀ n, E n) (n : ℕ) : x ∈ cylinder x n := by simp
#align pi_nat.self_mem_cylinder PiNat.self_mem_cylinder
-/

#print PiNat.mem_cylinder_iff_eq /-
theorem mem_cylinder_iff_eq {x y : ∀ n, E n} {n : ℕ} :
    y ∈ cylinder x n ↔ cylinder y n = cylinder x n :=
  by
  constructor
  · intro hy
    apply subset.antisymm
    · intro z hz i hi
      rw [← hy i hi]
      exact hz i hi
    · intro z hz i hi
      rw [hy i hi]
      exact hz i hi
  · intro h
    rw [← h]
    exact self_mem_cylinder _ _
#align pi_nat.mem_cylinder_iff_eq PiNat.mem_cylinder_iff_eq
-/

#print PiNat.mem_cylinder_comm /-
theorem mem_cylinder_comm (x y : ∀ n, E n) (n : ℕ) : y ∈ cylinder x n ↔ x ∈ cylinder y n := by
  simp [mem_cylinder_iff_eq, eq_comm]
#align pi_nat.mem_cylinder_comm PiNat.mem_cylinder_comm
-/

#print PiNat.mem_cylinder_iff_le_firstDiff /-
theorem mem_cylinder_iff_le_firstDiff {x y : ∀ n, E n} (hne : x ≠ y) (i : ℕ) :
    x ∈ cylinder y i ↔ i ≤ firstDiff x y := by
  constructor
  · intro h
    by_contra'
    exact apply_first_diff_ne hne (h _ this)
  · intro hi j hj
    exact apply_eq_of_lt_first_diff (hj.trans_le hi)
#align pi_nat.mem_cylinder_iff_le_first_diff PiNat.mem_cylinder_iff_le_firstDiff
-/

#print PiNat.mem_cylinder_firstDiff /-
theorem mem_cylinder_firstDiff (x y : ∀ n, E n) : x ∈ cylinder y (firstDiff x y) := fun i hi =>
  apply_eq_of_lt_firstDiff hi
#align pi_nat.mem_cylinder_first_diff PiNat.mem_cylinder_firstDiff
-/

#print PiNat.cylinder_eq_cylinder_of_le_firstDiff /-
theorem cylinder_eq_cylinder_of_le_firstDiff (x y : ∀ n, E n) {n : ℕ} (hn : n ≤ firstDiff x y) :
    cylinder x n = cylinder y n := by
  rw [← mem_cylinder_iff_eq]
  intro i hi
  exact apply_eq_of_lt_first_diff (hi.trans_le hn)
#align pi_nat.cylinder_eq_cylinder_of_le_first_diff PiNat.cylinder_eq_cylinder_of_le_firstDiff
-/

/- warning: pi_nat.Union_cylinder_update -> PiNat.unionᵢ_cylinder_update is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (n : Nat), Eq.{succ u1} (Set.{u1} (forall (n : Nat), E n)) (Set.unionᵢ.{u1, succ u1} (forall (n : Nat), E n) (E n) (fun (k : E n) => PiNat.cylinder.{u1} (fun (n : Nat) => E n) (Function.update.{1, succ u1} Nat (fun (n : Nat) => E n) (fun (a : Nat) (b : Nat) => Nat.decidableEq a b) x n k) (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x n)
but is expected to have type
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (n : Nat), Eq.{succ u1} (Set.{u1} (forall (n : Nat), E n)) (Set.unionᵢ.{u1, succ u1} (forall (n : Nat), E n) (E n) (fun (k : E n) => PiNat.cylinder.{u1} (fun (n : Nat) => E n) (Function.update.{1, succ u1} Nat (fun (n : Nat) => E n) (fun (a : Nat) (b : Nat) => instDecidableEqNat a b) x n k) (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x n)
Case conversion may be inaccurate. Consider using '#align pi_nat.Union_cylinder_update PiNat.unionᵢ_cylinder_updateₓ'. -/
theorem unionᵢ_cylinder_update (x : ∀ n, E n) (n : ℕ) :
    (⋃ k, cylinder (update x n k) (n + 1)) = cylinder x n :=
  by
  ext y
  simp only [mem_cylinder_iff, mem_Union]
  constructor
  · rintro ⟨k, hk⟩ i hi
    simpa [hi.ne] using hk i (Nat.lt_succ_of_lt hi)
  · intro H
    refine' ⟨y n, fun i hi => _⟩
    rcases Nat.lt_succ_iff_lt_or_eq.1 hi with (h'i | rfl)
    · simp [H i h'i, h'i.ne]
    · simp
#align pi_nat.Union_cylinder_update PiNat.unionᵢ_cylinder_update

/- warning: pi_nat.update_mem_cylinder -> PiNat.update_mem_cylinder is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (n : Nat) (y : E n), Membership.Mem.{u1, u1} (forall (a : Nat), E a) (Set.{u1} (forall (n : Nat), E n)) (Set.hasMem.{u1} (forall (n : Nat), E n)) (Function.update.{1, succ u1} Nat (fun (n : Nat) => E n) (fun (a : Nat) (b : Nat) => Nat.decidableEq a b) x n y) (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x n)
but is expected to have type
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (n : Nat) (y : E n), Membership.mem.{u1, u1} (forall (a : Nat), E a) (Set.{u1} (forall (n : Nat), E n)) (Set.instMembershipSet.{u1} (forall (n : Nat), E n)) (Function.update.{1, succ u1} Nat (fun (n : Nat) => E n) (fun (a : Nat) (b : Nat) => instDecidableEqNat a b) x n y) (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x n)
Case conversion may be inaccurate. Consider using '#align pi_nat.update_mem_cylinder PiNat.update_mem_cylinderₓ'. -/
theorem update_mem_cylinder (x : ∀ n, E n) (n : ℕ) (y : E n) : update x n y ∈ cylinder x n :=
  mem_cylinder_iff.2 fun i hi => by simp [hi.ne]
#align pi_nat.update_mem_cylinder PiNat.update_mem_cylinder

/-!
### A distance function on `Π n, E n`

We define a distance function on `Π n, E n`, given by `dist x y = (1/2)^n` where `n` is the first
index at which `x` and `y` differ. When each `E n` has the discrete topology, this distance will
define the right topology on the product space. We do not record a global `has_dist` instance nor
a `metric_space`instance, as other distances may be used on these spaces, but we register them as
local instances in this section.
-/


#print PiNat.dist /-
/-- The distance function on a product space `Π n, E n`, given by `dist x y = (1/2)^n` where `n` is
the first index at which `x` and `y` differ. -/
protected def dist : Dist (∀ n, E n) :=
  ⟨fun x y => if h : x ≠ y then (1 / 2 : ℝ) ^ firstDiff x y else 0⟩
#align pi_nat.has_dist PiNat.dist
-/

attribute [local instance] PiNat.dist

/- warning: pi_nat.dist_eq_of_ne -> PiNat.dist_eq_of_ne is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} {x : forall (n : Nat), E n} {y : forall (n : Nat), E n}, (Ne.{succ u1} (forall (n : Nat), E n) x y) -> (Eq.{1} Real (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.monoid)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (DivInvMonoid.toHasDiv.{0} Real (DivisionRing.toDivInvMonoid.{0} Real Real.divisionRing))) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))) (OfNat.ofNat.{0} Real 2 (OfNat.mk.{0} Real 2 (bit0.{0} Real Real.hasAdd (One.one.{0} Real Real.hasOne))))) (PiNat.firstDiff.{u1} (fun (n : Nat) => E n) x y)))
but is expected to have type
  forall {E : Nat -> Type.{u1}} {x : forall (n : Nat), E n} {y : forall (n : Nat), E n}, (Ne.{succ u1} (forall (n : Nat), E n) x y) -> (Eq.{1} Real (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.instMonoidReal)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (LinearOrderedField.toDiv.{0} Real Real.instLinearOrderedFieldReal)) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)) (OfNat.ofNat.{0} Real 2 (instOfNat.{0} Real 2 Real.natCast (instAtLeastTwoHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))))) (PiNat.firstDiff.{u1} (fun (n : Nat) => E n) x y)))
Case conversion may be inaccurate. Consider using '#align pi_nat.dist_eq_of_ne PiNat.dist_eq_of_neₓ'. -/
theorem dist_eq_of_ne {x y : ∀ n, E n} (h : x ≠ y) : dist x y = (1 / 2 : ℝ) ^ firstDiff x y := by
  simp [dist, h]
#align pi_nat.dist_eq_of_ne PiNat.dist_eq_of_ne

/- warning: pi_nat.dist_self -> PiNat.dist_self is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n), Eq.{1} Real (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x x) (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))
but is expected to have type
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n), Eq.{1} Real (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x x) (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))
Case conversion may be inaccurate. Consider using '#align pi_nat.dist_self PiNat.dist_selfₓ'. -/
protected theorem dist_self (x : ∀ n, E n) : dist x x = 0 := by simp [dist]
#align pi_nat.dist_self PiNat.dist_self

#print PiNat.dist_comm /-
protected theorem dist_comm (x y : ∀ n, E n) : dist x y = dist y x := by
  simp [dist, @eq_comm _ x y, first_diff_comm]
#align pi_nat.dist_comm PiNat.dist_comm
-/

/- warning: pi_nat.dist_nonneg -> PiNat.dist_nonneg is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (y : forall (n : Nat), E n), LE.le.{0} Real Real.hasLe (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y)
but is expected to have type
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (y : forall (n : Nat), E n), LE.le.{0} Real Real.instLEReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y)
Case conversion may be inaccurate. Consider using '#align pi_nat.dist_nonneg PiNat.dist_nonnegₓ'. -/
protected theorem dist_nonneg (x y : ∀ n, E n) : 0 ≤ dist x y :=
  by
  rcases eq_or_ne x y with (rfl | h)
  · simp [dist]
  · simp [dist, h]
#align pi_nat.dist_nonneg PiNat.dist_nonneg

/- warning: pi_nat.dist_triangle_nonarch -> PiNat.dist_triangle_nonarch is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (y : forall (n : Nat), E n) (z : forall (n : Nat), E n), LE.le.{0} Real Real.hasLe (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x z) (LinearOrder.max.{0} Real Real.linearOrder (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y) (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) y z))
but is expected to have type
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (y : forall (n : Nat), E n) (z : forall (n : Nat), E n), LE.le.{0} Real Real.instLEReal (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x z) (Max.max.{0} Real (LinearOrderedRing.toMax.{0} Real Real.instLinearOrderedRingReal) (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y) (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) y z))
Case conversion may be inaccurate. Consider using '#align pi_nat.dist_triangle_nonarch PiNat.dist_triangle_nonarchₓ'. -/
theorem dist_triangle_nonarch (x y z : ∀ n, E n) : dist x z ≤ max (dist x y) (dist y z) :=
  by
  rcases eq_or_ne x z with (rfl | hxz)
  · simp [PiNat.dist_self x, PiNat.dist_nonneg]
  rcases eq_or_ne x y with (rfl | hxy)
  · simp
  rcases eq_or_ne y z with (rfl | hyz)
  · simp
  simp only [dist_eq_of_ne, hxz, hxy, hyz, inv_le_inv, one_div, inv_pow, zero_lt_bit0, Ne.def,
    not_false_iff, le_max_iff, zero_lt_one, pow_le_pow_iff, one_lt_two, pow_pos,
    min_le_iff.1 (min_first_diff_le x y z hxz)]
#align pi_nat.dist_triangle_nonarch PiNat.dist_triangle_nonarch

/- warning: pi_nat.dist_triangle -> PiNat.dist_triangle is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (y : forall (n : Nat), E n) (z : forall (n : Nat), E n), LE.le.{0} Real Real.hasLe (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x z) (HAdd.hAdd.{0, 0, 0} Real Real Real (instHAdd.{0} Real Real.hasAdd) (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y) (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) y z))
but is expected to have type
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (y : forall (n : Nat), E n) (z : forall (n : Nat), E n), LE.le.{0} Real Real.instLEReal (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x z) (HAdd.hAdd.{0, 0, 0} Real Real Real (instHAdd.{0} Real Real.instAddReal) (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y) (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) y z))
Case conversion may be inaccurate. Consider using '#align pi_nat.dist_triangle PiNat.dist_triangleₓ'. -/
protected theorem dist_triangle (x y z : ∀ n, E n) : dist x z ≤ dist x y + dist y z :=
  calc
    dist x z ≤ max (dist x y) (dist y z) := dist_triangle_nonarch x y z
    _ ≤ dist x y + dist y z := max_le_add_of_nonneg (PiNat.dist_nonneg _ _) (PiNat.dist_nonneg _ _)
    
#align pi_nat.dist_triangle PiNat.dist_triangle

/- warning: pi_nat.eq_of_dist_eq_zero -> PiNat.eq_of_dist_eq_zero is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (y : forall (n : Nat), E n), (Eq.{1} Real (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y) (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))) -> (Eq.{succ u1} (forall (n : Nat), E n) x y)
but is expected to have type
  forall {E : Nat -> Type.{u1}} (x : forall (n : Nat), E n) (y : forall (n : Nat), E n), (Eq.{1} Real (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y) (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))) -> (Eq.{succ u1} (forall (n : Nat), E n) x y)
Case conversion may be inaccurate. Consider using '#align pi_nat.eq_of_dist_eq_zero PiNat.eq_of_dist_eq_zeroₓ'. -/
protected theorem eq_of_dist_eq_zero (x y : ∀ n, E n) (hxy : dist x y = 0) : x = y :=
  by
  rcases eq_or_ne x y with (rfl | h); · rfl
  simp [dist_eq_of_ne h] at hxy
  exact (two_ne_zero (pow_eq_zero hxy)).elim
#align pi_nat.eq_of_dist_eq_zero PiNat.eq_of_dist_eq_zero

/- warning: pi_nat.mem_cylinder_iff_dist_le -> PiNat.mem_cylinder_iff_dist_le is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} {x : forall (n : Nat), E n} {y : forall (n : Nat), E n} {n : Nat}, Iff (Membership.Mem.{u1, u1} (forall (n : Nat), E n) (Set.{u1} (forall (n : Nat), E n)) (Set.hasMem.{u1} (forall (n : Nat), E n)) y (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x n)) (LE.le.{0} Real Real.hasLe (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) y x) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.monoid)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (DivInvMonoid.toHasDiv.{0} Real (DivisionRing.toDivInvMonoid.{0} Real Real.divisionRing))) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))) (OfNat.ofNat.{0} Real 2 (OfNat.mk.{0} Real 2 (bit0.{0} Real Real.hasAdd (One.one.{0} Real Real.hasOne))))) n))
but is expected to have type
  forall {E : Nat -> Type.{u1}} {x : forall (n : Nat), E n} {y : forall (n : Nat), E n} {n : Nat}, Iff (Membership.mem.{u1, u1} (forall (n : Nat), E n) (Set.{u1} (forall (n : Nat), E n)) (Set.instMembershipSet.{u1} (forall (n : Nat), E n)) y (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x n)) (LE.le.{0} Real Real.instLEReal (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) y x) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.instMonoidReal)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (LinearOrderedField.toDiv.{0} Real Real.instLinearOrderedFieldReal)) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)) (OfNat.ofNat.{0} Real 2 (instOfNat.{0} Real 2 Real.natCast (instAtLeastTwoHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))))) n))
Case conversion may be inaccurate. Consider using '#align pi_nat.mem_cylinder_iff_dist_le PiNat.mem_cylinder_iff_dist_leₓ'. -/
theorem mem_cylinder_iff_dist_le {x y : ∀ n, E n} {n : ℕ} :
    y ∈ cylinder x n ↔ dist y x ≤ (1 / 2) ^ n :=
  by
  rcases eq_or_ne y x with (rfl | hne)
  · simp [PiNat.dist_self]
  suffices (∀ i : ℕ, i < n → y i = x i) ↔ n ≤ first_diff y x by simpa [dist_eq_of_ne hne]
  constructor
  · intro hy
    by_contra' H
    exact apply_first_diff_ne hne (hy _ H)
  · intro h i hi
    exact apply_eq_of_lt_first_diff (hi.trans_le h)
#align pi_nat.mem_cylinder_iff_dist_le PiNat.mem_cylinder_iff_dist_le

/- warning: pi_nat.apply_eq_of_dist_lt -> PiNat.apply_eq_of_dist_lt is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} {x : forall (n : Nat), E n} {y : forall (n : Nat), E n} {n : Nat}, (LT.lt.{0} Real Real.hasLt (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.monoid)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (DivInvMonoid.toHasDiv.{0} Real (DivisionRing.toDivInvMonoid.{0} Real Real.divisionRing))) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))) (OfNat.ofNat.{0} Real 2 (OfNat.mk.{0} Real 2 (bit0.{0} Real Real.hasAdd (One.one.{0} Real Real.hasOne))))) n)) -> (forall {i : Nat}, (LE.le.{0} Nat Nat.hasLe i n) -> (Eq.{succ u1} (E i) (x i) (y i)))
but is expected to have type
  forall {E : Nat -> Type.{u1}} {x : forall (n : Nat), E n} {y : forall (n : Nat), E n} {n : Nat}, (LT.lt.{0} Real Real.instLTReal (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.instMonoidReal)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (LinearOrderedField.toDiv.{0} Real Real.instLinearOrderedFieldReal)) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)) (OfNat.ofNat.{0} Real 2 (instOfNat.{0} Real 2 Real.natCast (instAtLeastTwoHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))))) n)) -> (forall {i : Nat}, (LE.le.{0} Nat instLENat i n) -> (Eq.{succ u1} (E i) (x i) (y i)))
Case conversion may be inaccurate. Consider using '#align pi_nat.apply_eq_of_dist_lt PiNat.apply_eq_of_dist_ltₓ'. -/
theorem apply_eq_of_dist_lt {x y : ∀ n, E n} {n : ℕ} (h : dist x y < (1 / 2) ^ n) {i : ℕ}
    (hi : i ≤ n) : x i = y i :=
  by
  rcases eq_or_ne x y with (rfl | hne)
  · rfl
  have : n < first_diff x y := by
    simpa [dist_eq_of_ne hne, inv_lt_inv, pow_lt_pow_iff, one_lt_two] using h
  exact apply_eq_of_lt_first_diff (hi.trans_lt this)
#align pi_nat.apply_eq_of_dist_lt PiNat.apply_eq_of_dist_lt

/- warning: pi_nat.lipschitz_with_one_iff_forall_dist_image_le_of_mem_cylinder -> PiNat.lipschitz_with_one_iff_forall_dist_image_le_of_mem_cylinder is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} {α : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u2} α] {f : (forall (n : Nat), E n) -> α}, Iff (forall (x : forall (n : Nat), E n) (y : forall (n : Nat), E n), LE.le.{0} Real Real.hasLe (Dist.dist.{u2} α (PseudoMetricSpace.toHasDist.{u2} α _inst_1) (f x) (f y)) (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y)) (forall (x : forall (n : Nat), E n) (y : forall (n : Nat), E n) (n : Nat), (Membership.Mem.{u1, u1} (forall (n : Nat), E n) (Set.{u1} (forall (n : Nat), E n)) (Set.hasMem.{u1} (forall (n : Nat), E n)) y (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x n)) -> (LE.le.{0} Real Real.hasLe (Dist.dist.{u2} α (PseudoMetricSpace.toHasDist.{u2} α _inst_1) (f x) (f y)) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.monoid)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (DivInvMonoid.toHasDiv.{0} Real (DivisionRing.toDivInvMonoid.{0} Real Real.divisionRing))) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))) (OfNat.ofNat.{0} Real 2 (OfNat.mk.{0} Real 2 (bit0.{0} Real Real.hasAdd (One.one.{0} Real Real.hasOne))))) n)))
but is expected to have type
  forall {E : Nat -> Type.{u1}} {α : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u2} α] {f : (forall (n : Nat), E n) -> α}, Iff (forall (x : forall (n : Nat), E n) (y : forall (n : Nat), E n), LE.le.{0} Real Real.instLEReal (Dist.dist.{u2} α (PseudoMetricSpace.toDist.{u2} α _inst_1) (f x) (f y)) (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y)) (forall (x : forall (n : Nat), E n) (y : forall (n : Nat), E n) (n : Nat), (Membership.mem.{u1, u1} (forall (n : Nat), E n) (Set.{u1} (forall (n : Nat), E n)) (Set.instMembershipSet.{u1} (forall (n : Nat), E n)) y (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x n)) -> (LE.le.{0} Real Real.instLEReal (Dist.dist.{u2} α (PseudoMetricSpace.toDist.{u2} α _inst_1) (f x) (f y)) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.instMonoidReal)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (LinearOrderedField.toDiv.{0} Real Real.instLinearOrderedFieldReal)) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)) (OfNat.ofNat.{0} Real 2 (instOfNat.{0} Real 2 Real.natCast (instAtLeastTwoHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))))) n)))
Case conversion may be inaccurate. Consider using '#align pi_nat.lipschitz_with_one_iff_forall_dist_image_le_of_mem_cylinder PiNat.lipschitz_with_one_iff_forall_dist_image_le_of_mem_cylinderₓ'. -/
/-- A function to a pseudo-metric-space is `1`-Lipschitz if and only if points in the same cylinder
of length `n` are sent to points within distance `(1/2)^n`.
Not expressed using `lipschitz_with` as we don't have a metric space structure -/
theorem lipschitz_with_one_iff_forall_dist_image_le_of_mem_cylinder {α : Type _}
    [PseudoMetricSpace α] {f : (∀ n, E n) → α} :
    (∀ x y : ∀ n, E n, dist (f x) (f y) ≤ dist x y) ↔
      ∀ x y n, y ∈ cylinder x n → dist (f x) (f y) ≤ (1 / 2) ^ n :=
  by
  constructor
  · intro H x y n hxy
    apply (H x y).trans
    rw [PiNat.dist_comm]
    exact mem_cylinder_iff_dist_le.1 hxy
  · intro H x y
    rcases eq_or_ne x y with (rfl | hne)
    · simp [PiNat.dist_nonneg]
    rw [dist_eq_of_ne hne]
    apply H x y (first_diff x y)
    rw [first_diff_comm]
    exact mem_cylinder_first_diff _ _
#align pi_nat.lipschitz_with_one_iff_forall_dist_image_le_of_mem_cylinder PiNat.lipschitz_with_one_iff_forall_dist_image_le_of_mem_cylinder

variable (E) [∀ n, TopologicalSpace (E n)] [∀ n, DiscreteTopology (E n)]

#print PiNat.isTopologicalBasis_cylinders /-
theorem isTopologicalBasis_cylinders :
    IsTopologicalBasis { s : Set (∀ n, E n) | ∃ (x : ∀ n, E n)(n : ℕ), s = cylinder x n } :=
  by
  apply is_topological_basis_of_open_of_nhds
  · rintro u ⟨x, n, rfl⟩
    rw [cylinder_eq_pi]
    exact isOpen_set_pi (Finset.range n).finite_toSet fun a ha => isOpen_discrete _
  · intro x u hx u_open
    obtain ⟨v, ⟨U, F, hUF, rfl⟩, xU, Uu⟩ :
      ∃ (v : Set (∀ i : ℕ, E i))(H :
        v ∈
          { S : Set (∀ i : ℕ, E i) |
            ∃ (U : ∀ i : ℕ, Set (E i))(F : Finset ℕ),
              (∀ i : ℕ, i ∈ F → U i ∈ { s : Set (E i) | IsOpen s }) ∧ S = (F : Set ℕ).pi U }),
        x ∈ v ∧ v ⊆ u :=
      (isTopologicalBasis_pi fun n : ℕ => is_topological_basis_opens).exists_subset_of_mem_open hx
        u_open
    rcases Finset.bddAbove F with ⟨n, hn⟩
    refine' ⟨cylinder x (n + 1), ⟨x, n + 1, rfl⟩, self_mem_cylinder _ _, subset.trans _ Uu⟩
    intro y hy
    suffices ∀ i : ℕ, i ∈ F → y i ∈ U i by simpa
    intro i hi
    have : y i = x i := mem_cylinder_iff.1 hy i ((hn hi).trans_lt (lt_add_one n))
    rw [this]
    simp only [Set.mem_pi, Finset.mem_coe] at xU
    exact xU i hi
#align pi_nat.is_topological_basis_cylinders PiNat.isTopologicalBasis_cylinders
-/

variable {E}

/- warning: pi_nat.is_open_iff_dist -> PiNat.isOpen_iff_dist is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} [_inst_1 : forall (n : Nat), TopologicalSpace.{u1} (E n)] [_inst_2 : forall (n : Nat), DiscreteTopology.{u1} (E n) (_inst_1 n)] (s : Set.{u1} (forall (n : Nat), E n)), Iff (IsOpen.{u1} (forall (n : Nat), E n) (Pi.topologicalSpace.{0, u1} Nat (fun (n : Nat) => E n) (fun (a : Nat) => _inst_1 a)) s) (forall (x : forall (n : Nat), E n), (Membership.Mem.{u1, u1} (forall (n : Nat), E n) (Set.{u1} (forall (n : Nat), E n)) (Set.hasMem.{u1} (forall (n : Nat), E n)) x s) -> (Exists.{1} Real (fun (ε : Real) => Exists.{0} (GT.gt.{0} Real Real.hasLt ε (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))) (fun (H : GT.gt.{0} Real Real.hasLt ε (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))) => forall (y : forall (n : Nat), E n), (LT.lt.{0} Real Real.hasLt (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y) ε) -> (Membership.Mem.{u1, u1} (forall (n : Nat), E n) (Set.{u1} (forall (n : Nat), E n)) (Set.hasMem.{u1} (forall (n : Nat), E n)) y s)))))
but is expected to have type
  forall {E : Nat -> Type.{u1}} [_inst_1 : forall (n : Nat), TopologicalSpace.{u1} (E n)] [_inst_2 : forall (n : Nat), DiscreteTopology.{u1} (E n) (_inst_1 n)] (s : Set.{u1} (forall (n : Nat), E n)), Iff (IsOpen.{u1} (forall (n : Nat), E n) (Pi.topologicalSpace.{0, u1} Nat (fun (n : Nat) => E n) (fun (a : Nat) => _inst_1 a)) s) (forall (x : forall (n : Nat), E n), (Membership.mem.{u1, u1} (forall (n : Nat), E n) (Set.{u1} (forall (n : Nat), E n)) (Set.instMembershipSet.{u1} (forall (n : Nat), E n)) x s) -> (Exists.{1} Real (fun (ε : Real) => And (GT.gt.{0} Real Real.instLTReal ε (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))) (forall (y : forall (n : Nat), E n), (LT.lt.{0} Real Real.instLTReal (Dist.dist.{u1} (forall (n : Nat), E n) (PiNat.dist.{u1} (fun (n : Nat) => E n)) x y) ε) -> (Membership.mem.{u1, u1} (forall (n : Nat), E n) (Set.{u1} (forall (n : Nat), E n)) (Set.instMembershipSet.{u1} (forall (n : Nat), E n)) y s)))))
Case conversion may be inaccurate. Consider using '#align pi_nat.is_open_iff_dist PiNat.isOpen_iff_distₓ'. -/
theorem isOpen_iff_dist (s : Set (∀ n, E n)) :
    IsOpen s ↔ ∀ x ∈ s, ∃ ε > 0, ∀ y, dist x y < ε → y ∈ s :=
  by
  constructor
  · intro hs x hx
    obtain ⟨v, ⟨y, n, rfl⟩, h'x, h's⟩ :
      ∃ (v : Set (∀ n : ℕ, E n))(H : v ∈ { s | ∃ (x : ∀ n : ℕ, E n)(n : ℕ), s = cylinder x n }),
        x ∈ v ∧ v ⊆ s :=
      (is_topological_basis_cylinders E).exists_subset_of_mem_open hx hs
    rw [← mem_cylinder_iff_eq.1 h'x] at h's
    exact
      ⟨(1 / 2 : ℝ) ^ n, by simp, fun y hy => h's fun i hi => (apply_eq_of_dist_lt hy hi.le).symm⟩
  · intro h
    apply (is_topological_basis_cylinders E).isOpen_iff.2 fun x hx => _
    rcases h x hx with ⟨ε, εpos, hε⟩
    obtain ⟨n, hn⟩ : ∃ n : ℕ, (1 / 2 : ℝ) ^ n < ε := exists_pow_lt_of_lt_one εpos one_half_lt_one
    refine' ⟨cylinder x n, ⟨x, n, rfl⟩, self_mem_cylinder x n, fun y hy => hε y _⟩
    rw [PiNat.dist_comm]
    exact (mem_cylinder_iff_dist_le.1 hy).trans_lt hn
#align pi_nat.is_open_iff_dist PiNat.isOpen_iff_dist

#print PiNat.metricSpace /-
/-- Metric space structure on `Π (n : ℕ), E n` when the spaces `E n` have the discrete topology,
where the distance is given by `dist x y = (1/2)^n`, where `n` is the smallest index where `x` and
`y` differ. Not registered as a global instance by default.
Warning: this definition makes sure that the topology is defeq to the original product topology,
but it does not take care of a possible uniformity. If the `E n` have a uniform structure, then
there will be two non-defeq uniform structures on `Π n, E n`, the product one and the one coming
from the metric structure. In this case, use `metric_space_of_discrete_uniformity` instead. -/
protected def metricSpace : MetricSpace (∀ n, E n) :=
  MetricSpace.ofDistTopology dist PiNat.dist_self PiNat.dist_comm PiNat.dist_triangle
    isOpen_iff_dist PiNat.eq_of_dist_eq_zero
#align pi_nat.metric_space PiNat.metricSpace
-/

#print PiNat.metricSpaceOfDiscreteUniformity /-
/-- Metric space structure on `Π (n : ℕ), E n` when the spaces `E n` have the discrete uniformity,
where the distance is given by `dist x y = (1/2)^n`, where `n` is the smallest index where `x` and
`y` differ. Not registered as a global instance by default. -/
protected def metricSpaceOfDiscreteUniformity {E : ℕ → Type _} [∀ n, UniformSpace (E n)]
    (h : ∀ n, uniformity (E n) = 𝓟 idRel) : MetricSpace (∀ n, E n) :=
  haveI : ∀ n, DiscreteTopology (E n) := fun n => discreteTopology_of_discrete_uniformity (h n)
  { dist_triangle := PiNat.dist_triangle
    dist_comm := PiNat.dist_comm
    dist_self := PiNat.dist_self
    eq_of_dist_eq_zero := PiNat.eq_of_dist_eq_zero
    toUniformSpace := Pi.uniformSpace _
    uniformity_dist :=
      by
      simp [Pi.uniformity, comap_infi, gt_iff_lt, preimage_set_of_eq, comap_principal,
        PseudoMetricSpace.uniformity_dist, h, idRel]
      apply le_antisymm
      · simp only [le_infᵢ_iff, le_principal_iff]
        intro ε εpos
        obtain ⟨n, hn⟩ : ∃ n, (1 / 2 : ℝ) ^ n < ε := exists_pow_lt_of_lt_one εpos (by norm_num)
        apply
          @mem_infi_of_Inter _ _ _ _ _ (Finset.range n).finite_toSet fun i =>
            { p : (∀ n : ℕ, E n) × ∀ n : ℕ, E n | p.fst i = p.snd i }
        · simp only [mem_principal, set_of_subset_set_of, imp_self, imp_true_iff]
        · rintro ⟨x, y⟩ hxy
          simp only [Finset.mem_coe, Finset.mem_range, Inter_coe_set, mem_Inter, mem_set_of_eq] at
            hxy
          apply lt_of_le_of_lt _ hn
          rw [← mem_cylinder_iff_dist_le, mem_cylinder_iff]
          exact hxy
      · simp only [le_infᵢ_iff, le_principal_iff]
        intro n
        refine' mem_infi_of_mem ((1 / 2) ^ n) _
        refine' mem_infi_of_mem (by positivity) _
        simp only [mem_principal, set_of_subset_set_of, Prod.forall]
        intro x y hxy
        exact apply_eq_of_dist_lt hxy le_rfl }
#align pi_nat.metric_space_of_discrete_uniformity PiNat.metricSpaceOfDiscreteUniformity
-/

#print PiNat.metricSpaceNatNat /-
/-- Metric space structure on `ℕ → ℕ` where the distance is given by `dist x y = (1/2)^n`,
where `n` is the smallest index where `x` and `y` differ.
Not registered as a global instance by default. -/
def metricSpaceNatNat : MetricSpace (ℕ → ℕ) :=
  PiNat.metricSpaceOfDiscreteUniformity fun n => rfl
#align pi_nat.metric_space_nat_nat PiNat.metricSpaceNatNat
-/

attribute [local instance] PiNat.metricSpace

#print PiNat.completeSpace /-
protected theorem completeSpace : CompleteSpace (∀ n, E n) :=
  by
  refine' Metric.complete_of_convergent_controlled_sequences (fun n => (1 / 2) ^ n) (by simp) _
  intro u hu
  refine' ⟨fun n => u n n, tendsto_pi_nhds.2 fun i => _⟩
  refine' tendsto_const_nhds.congr' _
  filter_upwards [Filter.Ici_mem_atTop i]with n hn
  exact apply_eq_of_dist_lt (hu i i n le_rfl hn) le_rfl
#align pi_nat.complete_space PiNat.completeSpace
-/

/-!
### Retractions inside product spaces

We show that, in a space `Π (n : ℕ), E n` where each `E n` is discrete, there is a retraction on
any closed nonempty subset `s`, i.e., a continuous map `f` from the whole space to `s` restricting
to the identity on `s`. The map `f` is defined as follows. For `x ∈ s`, let `f x = x`. Otherwise,
consider the longest prefix `w` that `x` shares with an element of `s`, and let `f x = z_w`
where `z_w` is an element of `s` starting with `w`.
-/


/- warning: pi_nat.exists_disjoint_cylinder -> PiNat.exists_disjoint_cylinder is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} [_inst_1 : forall (n : Nat), TopologicalSpace.{u1} (E n)] [_inst_2 : forall (n : Nat), DiscreteTopology.{u1} (E n) (_inst_1 n)] {s : Set.{u1} (forall (n : Nat), E n)}, (IsClosed.{u1} (forall (n : Nat), E n) (Pi.topologicalSpace.{0, u1} Nat (fun (n : Nat) => E n) (fun (a : Nat) => _inst_1 a)) s) -> (forall {x : forall (n : Nat), E n}, (Not (Membership.Mem.{u1, u1} (forall (n : Nat), E n) (Set.{u1} (forall (n : Nat), E n)) (Set.hasMem.{u1} (forall (n : Nat), E n)) x s)) -> (Exists.{1} Nat (fun (n : Nat) => Disjoint.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (forall (n : Nat), E n)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (Set.completeBooleanAlgebra.{u1} (forall (n : Nat), E n))))))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} (Set.{u1} (forall (n : Nat), E n)) (BooleanAlgebra.toGeneralizedBooleanAlgebra.{u1} (Set.{u1} (forall (n : Nat), E n)) (Set.booleanAlgebra.{u1} (forall (n : Nat), E n)))) s (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x n))))
but is expected to have type
  forall {E : Nat -> Type.{u1}} [_inst_1 : forall (n : Nat), TopologicalSpace.{u1} (E n)] [_inst_2 : forall (n : Nat), DiscreteTopology.{u1} (E n) (_inst_1 n)] {s : Set.{u1} (forall (n : Nat), E n)}, (IsClosed.{u1} (forall (n : Nat), E n) (Pi.topologicalSpace.{0, u1} Nat (fun (n : Nat) => E n) (fun (a : Nat) => _inst_1 a)) s) -> (forall {x : forall (n : Nat), E n}, (Not (Membership.mem.{u1, u1} (forall (n : Nat), E n) (Set.{u1} (forall (n : Nat), E n)) (Set.instMembershipSet.{u1} (forall (n : Nat), E n)) x s)) -> (Exists.{1} Nat (fun (n : Nat) => Disjoint.{u1} (Set.{u1} (forall (n : Nat), E n)) (OmegaCompletePartialOrder.toPartialOrder.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteLattice.instOmegaCompletePartialOrder.{u1} (Set.{u1} (forall (n : Nat), E n)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (Set.instCompleteBooleanAlgebraSet.{u1} (forall (n : Nat), E n))))))) (BoundedOrder.toOrderBot.{u1} (Set.{u1} (forall (n : Nat), E n)) (Preorder.toLE.{u1} (Set.{u1} (forall (n : Nat), E n)) (PartialOrder.toPreorder.{u1} (Set.{u1} (forall (n : Nat), E n)) (OmegaCompletePartialOrder.toPartialOrder.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteLattice.instOmegaCompletePartialOrder.{u1} (Set.{u1} (forall (n : Nat), E n)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (Set.instCompleteBooleanAlgebraSet.{u1} (forall (n : Nat), E n))))))))) (CompleteLattice.toBoundedOrder.{u1} (Set.{u1} (forall (n : Nat), E n)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (Set.instCompleteBooleanAlgebraSet.{u1} (forall (n : Nat), E n))))))) s (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x n))))
Case conversion may be inaccurate. Consider using '#align pi_nat.exists_disjoint_cylinder PiNat.exists_disjoint_cylinderₓ'. -/
theorem exists_disjoint_cylinder {s : Set (∀ n, E n)} (hs : IsClosed s) {x : ∀ n, E n}
    (hx : x ∉ s) : ∃ n, Disjoint s (cylinder x n) :=
  by
  rcases eq_empty_or_nonempty s with (rfl | hne)
  · exact ⟨0, by simp⟩
  have A : 0 < inf_dist x s := (hs.not_mem_iff_inf_dist_pos hne).1 hx
  obtain ⟨n, hn⟩ : ∃ n, (1 / 2 : ℝ) ^ n < inf_dist x s := exists_pow_lt_of_lt_one A one_half_lt_one
  refine' ⟨n, _⟩
  apply disjoint_left.2 fun y ys hy => _
  apply lt_irrefl (inf_dist x s)
  calc
    inf_dist x s ≤ dist x y := inf_dist_le_dist_of_mem ys
    _ ≤ (1 / 2) ^ n := by
      rw [mem_cylinder_comm] at hy
      exact mem_cylinder_iff_dist_le.1 hy
    _ < inf_dist x s := hn
    
#align pi_nat.exists_disjoint_cylinder PiNat.exists_disjoint_cylinder

#print PiNat.shortestPrefixDiff /-
/-- Given a point `x` in a product space `Π (n : ℕ), E n`, and `s` a subset of this space, then
`shortest_prefix_diff x s` if the smallest `n` for which there is no element of `s` having the same
prefix of length `n` as `x`. If there is no such `n`, then use `0` by convention. -/
def shortestPrefixDiff {E : ℕ → Type _} (x : ∀ n, E n) (s : Set (∀ n, E n)) : ℕ :=
  if h : ∃ n, Disjoint s (cylinder x n) then Nat.find h else 0
#align pi_nat.shortest_prefix_diff PiNat.shortestPrefixDiff
-/

#print PiNat.firstDiff_lt_shortestPrefixDiff /-
theorem firstDiff_lt_shortestPrefixDiff {s : Set (∀ n, E n)} (hs : IsClosed s) {x y : ∀ n, E n}
    (hx : x ∉ s) (hy : y ∈ s) : firstDiff x y < shortestPrefixDiff x s :=
  by
  have A := exists_disjoint_cylinder hs hx
  rw [shortest_prefix_diff, dif_pos A]
  have B := Nat.find_spec A
  contrapose! B
  rw [not_disjoint_iff_nonempty_inter]
  refine' ⟨y, hy, _⟩
  rw [mem_cylinder_comm]
  exact cylinder_anti y B (mem_cylinder_first_diff x y)
#align pi_nat.first_diff_lt_shortest_prefix_diff PiNat.firstDiff_lt_shortestPrefixDiff
-/

#print PiNat.shortestPrefixDiff_pos /-
theorem shortestPrefixDiff_pos {s : Set (∀ n, E n)} (hs : IsClosed s) (hne : s.Nonempty)
    {x : ∀ n, E n} (hx : x ∉ s) : 0 < shortestPrefixDiff x s :=
  by
  rcases hne with ⟨y, hy⟩
  exact (zero_le _).trans_lt (first_diff_lt_shortest_prefix_diff hs hx hy)
#align pi_nat.shortest_prefix_diff_pos PiNat.shortestPrefixDiff_pos
-/

#print PiNat.longestPrefix /-
/-- Given a point `x` in a product space `Π (n : ℕ), E n`, and `s` a subset of this space, then
`longest_prefix x s` if the largest `n` for which there is an element of `s` having the same
prefix of length `n` as `x`. If there is no such `n`, use `0` by convention. -/
def longestPrefix {E : ℕ → Type _} (x : ∀ n, E n) (s : Set (∀ n, E n)) : ℕ :=
  shortestPrefixDiff x s - 1
#align pi_nat.longest_prefix PiNat.longestPrefix
-/

#print PiNat.firstDiff_le_longestPrefix /-
theorem firstDiff_le_longestPrefix {s : Set (∀ n, E n)} (hs : IsClosed s) {x y : ∀ n, E n}
    (hx : x ∉ s) (hy : y ∈ s) : firstDiff x y ≤ longestPrefix x s :=
  by
  rw [longest_prefix, le_tsub_iff_right]
  · exact first_diff_lt_shortest_prefix_diff hs hx hy
  · exact shortest_prefix_diff_pos hs ⟨y, hy⟩ hx
#align pi_nat.first_diff_le_longest_prefix PiNat.firstDiff_le_longestPrefix
-/

/- warning: pi_nat.inter_cylinder_longest_prefix_nonempty -> PiNat.inter_cylinder_longestPrefix_nonempty is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} [_inst_1 : forall (n : Nat), TopologicalSpace.{u1} (E n)] [_inst_2 : forall (n : Nat), DiscreteTopology.{u1} (E n) (_inst_1 n)] {s : Set.{u1} (forall (n : Nat), E n)}, (IsClosed.{u1} (forall (n : Nat), E n) (Pi.topologicalSpace.{0, u1} Nat (fun (n : Nat) => E n) (fun (a : Nat) => _inst_1 a)) s) -> (Set.Nonempty.{u1} (forall (n : Nat), E n) s) -> (forall (x : forall (n : Nat), E n), Set.Nonempty.{u1} (forall (n : Nat), E n) (Inter.inter.{u1} (Set.{u1} (forall (n : Nat), E n)) (Set.hasInter.{u1} (forall (n : Nat), E n)) s (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x (PiNat.longestPrefix.{u1} (fun (n : Nat) => E n) x s))))
but is expected to have type
  forall {E : Nat -> Type.{u1}} [_inst_1 : forall (n : Nat), TopologicalSpace.{u1} (E n)] [_inst_2 : forall (n : Nat), DiscreteTopology.{u1} (E n) (_inst_1 n)] {s : Set.{u1} (forall (n : Nat), E n)}, (IsClosed.{u1} (forall (n : Nat), E n) (Pi.topologicalSpace.{0, u1} Nat (fun (n : Nat) => E n) (fun (a : Nat) => _inst_1 a)) s) -> (Set.Nonempty.{u1} (forall (n : Nat), E n) s) -> (forall (x : forall (n : Nat), E n), Set.Nonempty.{u1} (forall (n : Nat), E n) (Inter.inter.{u1} (Set.{u1} (forall (n : Nat), E n)) (Set.instInterSet.{u1} (forall (n : Nat), E n)) s (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x (PiNat.longestPrefix.{u1} (fun (n : Nat) => E n) x s))))
Case conversion may be inaccurate. Consider using '#align pi_nat.inter_cylinder_longest_prefix_nonempty PiNat.inter_cylinder_longestPrefix_nonemptyₓ'. -/
theorem inter_cylinder_longestPrefix_nonempty {s : Set (∀ n, E n)} (hs : IsClosed s)
    (hne : s.Nonempty) (x : ∀ n, E n) : (s ∩ cylinder x (longestPrefix x s)).Nonempty :=
  by
  by_cases hx : x ∈ s
  · exact ⟨x, hx, self_mem_cylinder _ _⟩
  have A := exists_disjoint_cylinder hs hx
  have B : longest_prefix x s < shortest_prefix_diff x s :=
    Nat.pred_lt (shortest_prefix_diff_pos hs hne hx).ne'
  rw [longest_prefix, shortest_prefix_diff, dif_pos A] at B⊢
  obtain ⟨y, ys, hy⟩ : ∃ y : ∀ n : ℕ, E n, y ∈ s ∧ x ∈ cylinder y (Nat.find A - 1) :=
    by
    have := Nat.find_min A B
    push_neg  at this
    simp_rw [not_disjoint_iff, mem_cylinder_comm] at this
    exact this
  refine' ⟨y, ys, _⟩
  rw [mem_cylinder_iff_eq] at hy⊢
  rw [hy]
#align pi_nat.inter_cylinder_longest_prefix_nonempty PiNat.inter_cylinder_longestPrefix_nonempty

/- warning: pi_nat.disjoint_cylinder_of_longest_prefix_lt -> PiNat.disjoint_cylinder_of_longestPrefix_lt is a dubious translation:
lean 3 declaration is
  forall {E : Nat -> Type.{u1}} [_inst_1 : forall (n : Nat), TopologicalSpace.{u1} (E n)] [_inst_2 : forall (n : Nat), DiscreteTopology.{u1} (E n) (_inst_1 n)] {s : Set.{u1} (forall (n : Nat), E n)}, (IsClosed.{u1} (forall (n : Nat), E n) (Pi.topologicalSpace.{0, u1} Nat (fun (n : Nat) => E n) (fun (a : Nat) => _inst_1 a)) s) -> (forall {x : forall (n : Nat), E n}, (Not (Membership.Mem.{u1, u1} (forall (n : Nat), E n) (Set.{u1} (forall (n : Nat), E n)) (Set.hasMem.{u1} (forall (n : Nat), E n)) x s)) -> (forall {n : Nat}, (LT.lt.{0} Nat Nat.hasLt (PiNat.longestPrefix.{u1} (fun (n : Nat) => E n) x s) n) -> (Disjoint.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (forall (n : Nat), E n)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (Set.completeBooleanAlgebra.{u1} (forall (n : Nat), E n))))))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} (Set.{u1} (forall (n : Nat), E n)) (BooleanAlgebra.toGeneralizedBooleanAlgebra.{u1} (Set.{u1} (forall (n : Nat), E n)) (Set.booleanAlgebra.{u1} (forall (n : Nat), E n)))) s (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x n))))
but is expected to have type
  forall {E : Nat -> Type.{u1}} [_inst_1 : forall (n : Nat), TopologicalSpace.{u1} (E n)] [_inst_2 : forall (n : Nat), DiscreteTopology.{u1} (E n) (_inst_1 n)] {s : Set.{u1} (forall (n : Nat), E n)}, (IsClosed.{u1} (forall (n : Nat), E n) (Pi.topologicalSpace.{0, u1} Nat (fun (n : Nat) => E n) (fun (a : Nat) => _inst_1 a)) s) -> (forall {x : forall (n : Nat), E n}, (Not (Membership.mem.{u1, u1} (forall (n : Nat), E n) (Set.{u1} (forall (n : Nat), E n)) (Set.instMembershipSet.{u1} (forall (n : Nat), E n)) x s)) -> (forall {n : Nat}, (LT.lt.{0} Nat instLTNat (PiNat.longestPrefix.{u1} (fun (n : Nat) => E n) x s) n) -> (Disjoint.{u1} (Set.{u1} (forall (n : Nat), E n)) (OmegaCompletePartialOrder.toPartialOrder.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteLattice.instOmegaCompletePartialOrder.{u1} (Set.{u1} (forall (n : Nat), E n)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (Set.instCompleteBooleanAlgebraSet.{u1} (forall (n : Nat), E n))))))) (BoundedOrder.toOrderBot.{u1} (Set.{u1} (forall (n : Nat), E n)) (Preorder.toLE.{u1} (Set.{u1} (forall (n : Nat), E n)) (PartialOrder.toPreorder.{u1} (Set.{u1} (forall (n : Nat), E n)) (OmegaCompletePartialOrder.toPartialOrder.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteLattice.instOmegaCompletePartialOrder.{u1} (Set.{u1} (forall (n : Nat), E n)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (Set.instCompleteBooleanAlgebraSet.{u1} (forall (n : Nat), E n))))))))) (CompleteLattice.toBoundedOrder.{u1} (Set.{u1} (forall (n : Nat), E n)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (forall (n : Nat), E n)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (forall (n : Nat), E n)) (Set.instCompleteBooleanAlgebraSet.{u1} (forall (n : Nat), E n))))))) s (PiNat.cylinder.{u1} (fun (n : Nat) => E n) x n))))
Case conversion may be inaccurate. Consider using '#align pi_nat.disjoint_cylinder_of_longest_prefix_lt PiNat.disjoint_cylinder_of_longestPrefix_ltₓ'. -/
theorem disjoint_cylinder_of_longestPrefix_lt {s : Set (∀ n, E n)} (hs : IsClosed s) {x : ∀ n, E n}
    (hx : x ∉ s) {n : ℕ} (hn : longestPrefix x s < n) : Disjoint s (cylinder x n) :=
  by
  rcases eq_empty_or_nonempty s with (h's | hne); · simp [h's]
  contrapose! hn
  rcases not_disjoint_iff_nonempty_inter.1 hn with ⟨y, ys, hy⟩
  apply le_trans _ (first_diff_le_longest_prefix hs hx ys)
  apply (mem_cylinder_iff_le_first_diff (ne_of_mem_of_not_mem ys hx).symm _).1
  rwa [mem_cylinder_comm]
#align pi_nat.disjoint_cylinder_of_longest_prefix_lt PiNat.disjoint_cylinder_of_longestPrefix_lt

#print PiNat.cylinder_longestPrefix_eq_of_longestPrefix_lt_firstDiff /-
/-- If two points `x, y` coincide up to length `n`, and the longest common prefix of `x` with `s`
is strictly shorter than `n`, then the longest common prefix of `y` with `s` is the same, and both
cylinders of this length based at `x` and `y` coincide. -/
theorem cylinder_longestPrefix_eq_of_longestPrefix_lt_firstDiff {x y : ∀ n, E n}
    {s : Set (∀ n, E n)} (hs : IsClosed s) (hne : s.Nonempty)
    (H : longestPrefix x s < firstDiff x y) (xs : x ∉ s) (ys : y ∉ s) :
    cylinder x (longestPrefix x s) = cylinder y (longestPrefix y s) :=
  by
  have l_eq : longest_prefix y s = longest_prefix x s :=
    by
    rcases lt_trichotomy (longest_prefix y s) (longest_prefix x s) with (L | L | L)
    · have Ax : (s ∩ cylinder x (longest_prefix x s)).Nonempty :=
        inter_cylinder_longest_prefix_nonempty hs hne x
      have Z := disjoint_cylinder_of_longest_prefix_lt hs ys L
      rw [first_diff_comm] at H
      rw [cylinder_eq_cylinder_of_le_first_diff _ _ H.le] at Z
      exact (Ax.not_disjoint Z).elim
    · exact L
    · have Ay : (s ∩ cylinder y (longest_prefix y s)).Nonempty :=
        inter_cylinder_longest_prefix_nonempty hs hne y
      have A'y : (s ∩ cylinder y (longest_prefix x s).succ).Nonempty :=
        Ay.mono (inter_subset_inter_right s (cylinder_anti _ L))
      have Z := disjoint_cylinder_of_longest_prefix_lt hs xs (Nat.lt_succ_self _)
      rw [cylinder_eq_cylinder_of_le_first_diff _ _ H] at Z
      exact (A'y.not_disjoint Z).elim
  rw [l_eq, ← mem_cylinder_iff_eq]
  exact cylinder_anti y H.le (mem_cylinder_first_diff x y)
#align pi_nat.cylinder_longest_prefix_eq_of_longest_prefix_lt_first_diff PiNat.cylinder_longestPrefix_eq_of_longestPrefix_lt_firstDiff
-/

#print PiNat.exists_lipschitz_retraction_of_isClosed /-
/-- Given a closed nonempty subset `s` of `Π (n : ℕ), E n`, there exists a Lipschitz retraction
onto this set, i.e., a Lipschitz map with range equal to `s`, equal to the identity on `s`. -/
theorem exists_lipschitz_retraction_of_isClosed {s : Set (∀ n, E n)} (hs : IsClosed s)
    (hne : s.Nonempty) :
    ∃ f : (∀ n, E n) → ∀ n, E n, (∀ x ∈ s, f x = x) ∧ range f = s ∧ LipschitzWith 1 f :=
  by
  /- The map `f` is defined as follows. For `x ∈ s`, let `f x = x`. Otherwise, consider the longest
    prefix `w` that `x` shares with an element of `s`, and let `f x = z_w` where `z_w` is an element
    of `s` starting with `w`. All the desired properties are clear, except the fact that `f`
    is `1`-Lipschitz: if two points `x, y` belong to a common cylinder of length `n`, one should show
    that their images also belong to a common cylinder of length `n`. This is a case analysis:
    * if both `x, y ∈ s`, then this is clear.
    * if `x ∈ s` but `y ∉ s`, then the longest prefix `w` of `y` shared by an element of `s` is of
    length at least `n` (because of `x`), and then `f y` starts with `w` and therefore stays in the
    same length `n` cylinder.
    * if `x ∉ s`, `y ∉ s`, let `w` be the longest prefix of `x` shared by an element of `s`. If its
    length is `< n`, then it is also the longest prefix of `y`, and we get `f x = f y = z_w`.
    Otherwise, `f x` remains in the same `n`-cylinder as `x`. Similarly for `y`. Finally, `f x` and
    `f y` are again in the same `n`-cylinder, as desired. -/
  set f := fun x => if x ∈ s then x else (inter_cylinder_longest_prefix_nonempty hs hne x).some with
    hf
  have fs : ∀ x ∈ s, f x = x := fun x xs => by simp [xs]
  refine' ⟨f, fs, _, _⟩
  -- check that the range of `f` is `s`.
  · apply subset.antisymm
    · rintro x ⟨y, rfl⟩
      by_cases hy : y ∈ s
      · rwa [fs y hy]
      simpa [hf, if_neg hy] using (inter_cylinder_longest_prefix_nonempty hs hne y).choose_spec.1
    · intro x hx
      rw [← fs x hx]
      exact mem_range_self _
  -- check that `f` is `1`-Lipschitz, by a case analysis.
  · apply LipschitzWith.mk_one fun x y => _
    -- exclude the trivial cases where `x = y`, or `f x = f y`.
    rcases eq_or_ne x y with (rfl | hxy)
    · simp
    rcases eq_or_ne (f x) (f y) with (h' | hfxfy)
    · simp [h', dist_nonneg]
    have I2 : cylinder x (first_diff x y) = cylinder y (first_diff x y) :=
      by
      rw [← mem_cylinder_iff_eq]
      apply mem_cylinder_first_diff
    suffices first_diff x y ≤ first_diff (f x) (f y) by
      simpa [dist_eq_of_ne hxy, dist_eq_of_ne hfxfy]
    -- case where `x ∈ s`
    by_cases xs : x ∈ s
    · rw [fs x xs] at hfxfy⊢
      -- case where `y ∈ s`, trivial
      by_cases ys : y ∈ s
      · rw [fs y ys]
      -- case where `y ∉ s`
      have A : (s ∩ cylinder y (longest_prefix y s)).Nonempty :=
        inter_cylinder_longest_prefix_nonempty hs hne y
      have fy : f y = A.some := by simp_rw [hf, if_neg ys]
      have I : cylinder A.some (first_diff x y) = cylinder y (first_diff x y) :=
        by
        rw [← mem_cylinder_iff_eq, first_diff_comm]
        apply cylinder_anti y _ A.some_spec.2
        exact first_diff_le_longest_prefix hs ys xs
      rwa [← fy, ← I2, ← mem_cylinder_iff_eq, mem_cylinder_iff_le_first_diff hfxfy.symm,
        first_diff_comm _ x] at I
    -- case where `x ∉ s`
    · by_cases ys : y ∈ s
      -- case where `y ∈ s` (similar to the above)
      · have A : (s ∩ cylinder x (longest_prefix x s)).Nonempty :=
          inter_cylinder_longest_prefix_nonempty hs hne x
        have fx : f x = A.some := by simp_rw [hf, if_neg xs]
        have I : cylinder A.some (first_diff x y) = cylinder x (first_diff x y) :=
          by
          rw [← mem_cylinder_iff_eq]
          apply cylinder_anti x _ A.some_spec.2
          apply first_diff_le_longest_prefix hs xs ys
        rw [fs y ys] at hfxfy⊢
        rwa [← fx, I2, ← mem_cylinder_iff_eq, mem_cylinder_iff_le_first_diff hfxfy] at I
      -- case where `y ∉ s`
      · have Ax : (s ∩ cylinder x (longest_prefix x s)).Nonempty :=
          inter_cylinder_longest_prefix_nonempty hs hne x
        have fx : f x = Ax.some := by simp_rw [hf, if_neg xs]
        have Ay : (s ∩ cylinder y (longest_prefix y s)).Nonempty :=
          inter_cylinder_longest_prefix_nonempty hs hne y
        have fy : f y = Ay.some := by simp_rw [hf, if_neg ys]
        -- case where the common prefix to `x` and `s`, or `y` and `s`, is shorter than the
        -- common part to `x` and `y` -- then `f x = f y`.
        by_cases H : longest_prefix x s < first_diff x y ∨ longest_prefix y s < first_diff x y
        · have : cylinder x (longest_prefix x s) = cylinder y (longest_prefix y s) :=
            by
            cases H
            · exact cylinder_longest_prefix_eq_of_longest_prefix_lt_first_diff hs hne H xs ys
            · symm
              rw [first_diff_comm] at H
              exact cylinder_longest_prefix_eq_of_longest_prefix_lt_first_diff hs hne H ys xs
          rw [fx, fy] at hfxfy
          apply (hfxfy _).elim
          congr
        -- case where the common prefix to `x` and `s` is long, as well as the common prefix to
        -- `y` and `s`. Then all points remain in the same cylinders.
        · push_neg  at H
          have I1 : cylinder Ax.some (first_diff x y) = cylinder x (first_diff x y) :=
            by
            rw [← mem_cylinder_iff_eq]
            exact cylinder_anti x H.1 Ax.some_spec.2
          have I3 : cylinder y (first_diff x y) = cylinder Ay.some (first_diff x y) :=
            by
            rw [eq_comm, ← mem_cylinder_iff_eq]
            exact cylinder_anti y H.2 Ay.some_spec.2
          have : cylinder Ax.some (first_diff x y) = cylinder Ay.some (first_diff x y) := by
            rw [I1, I2, I3]
          rw [← fx, ← fy, ← mem_cylinder_iff_eq, mem_cylinder_iff_le_first_diff hfxfy] at this
          exact this
#align pi_nat.exists_lipschitz_retraction_of_is_closed PiNat.exists_lipschitz_retraction_of_isClosed
-/

#print PiNat.exists_retraction_of_isClosed /-
/-- Given a closed nonempty subset `s` of `Π (n : ℕ), E n`, there exists a retraction onto this
set, i.e., a continuous map with range equal to `s`, equal to the identity on `s`. -/
theorem exists_retraction_of_isClosed {s : Set (∀ n, E n)} (hs : IsClosed s) (hne : s.Nonempty) :
    ∃ f : (∀ n, E n) → ∀ n, E n, (∀ x ∈ s, f x = x) ∧ range f = s ∧ Continuous f :=
  by
  rcases exists_lipschitz_retraction_of_is_closed hs hne with ⟨f, fs, frange, hf⟩
  exact ⟨f, fs, frange, hf.continuous⟩
#align pi_nat.exists_retraction_of_is_closed PiNat.exists_retraction_of_isClosed
-/

#print PiNat.exists_retraction_subtype_of_isClosed /-
theorem exists_retraction_subtype_of_isClosed {s : Set (∀ n, E n)} (hs : IsClosed s)
    (hne : s.Nonempty) : ∃ f : (∀ n, E n) → s, (∀ x : s, f x = x) ∧ Surjective f ∧ Continuous f :=
  by
  obtain ⟨f, fs, f_range, f_cont⟩ :
    ∃ f : (∀ n, E n) → ∀ n, E n, (∀ x ∈ s, f x = x) ∧ range f = s ∧ Continuous f :=
    exists_retraction_of_is_closed hs hne
  have A : ∀ x, f x ∈ s := by simp [← f_range]
  have B : ∀ x : s, cod_restrict f s A x = x :=
    by
    intro x
    apply subtype.coe_injective.eq_iff.1
    simpa only using fs x.val x.property
  exact ⟨cod_restrict f s A, B, fun x => ⟨x, B x⟩, f_cont.subtype_mk _⟩
#align pi_nat.exists_retraction_subtype_of_is_closed PiNat.exists_retraction_subtype_of_isClosed
-/

end PiNat

open PiNat

/- warning: exists_nat_nat_continuous_surjective_of_complete_space -> exists_nat_nat_continuous_surjective_of_completeSpace is a dubious translation:
lean 3 declaration is
  forall (α : Type.{u1}) [_inst_1 : MetricSpace.{u1} α] [_inst_2 : CompleteSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))] [_inst_3 : TopologicalSpace.SecondCountableTopology.{u1} α (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)))] [_inst_4 : Nonempty.{succ u1} α], Exists.{succ u1} ((Nat -> Nat) -> α) (fun (f : (Nat -> Nat) -> α) => And (Continuous.{0, u1} (Nat -> Nat) α (Pi.topologicalSpace.{0, 0} Nat (fun (ᾰ : Nat) => Nat) (fun (a : Nat) => Nat.topologicalSpace)) (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))) f) (Function.Surjective.{1, succ u1} (Nat -> Nat) α f))
but is expected to have type
  forall (α : Type.{u1}) [_inst_1 : MetricSpace.{u1} α] [_inst_2 : CompleteSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))] [_inst_3 : TopologicalSpace.SecondCountableTopology.{u1} α (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)))] [_inst_4 : Nonempty.{succ u1} α], Exists.{succ u1} ((Nat -> Nat) -> α) (fun (f : (Nat -> Nat) -> α) => And (Continuous.{0, u1} (Nat -> Nat) α (Pi.topologicalSpace.{0, 0} Nat (fun (ᾰ : Nat) => Nat) (fun (a : Nat) => instTopologicalSpaceNat)) (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))) f) (Function.Surjective.{1, succ u1} (Nat -> Nat) α f))
Case conversion may be inaccurate. Consider using '#align exists_nat_nat_continuous_surjective_of_complete_space exists_nat_nat_continuous_surjective_of_completeSpaceₓ'. -/
/-- Any nonempty complete second countable metric space is the continuous image of the
fundamental space `ℕ → ℕ`. For a version of this theorem in the context of Polish spaces, see
`exists_nat_nat_continuous_surjective_of_polish_space`. -/
theorem exists_nat_nat_continuous_surjective_of_completeSpace (α : Type _) [MetricSpace α]
    [CompleteSpace α] [SecondCountableTopology α] [Nonempty α] :
    ∃ f : (ℕ → ℕ) → α, Continuous f ∧ Surjective f :=
  by
  /- First, we define a surjective map from a closed subset `s` of `ℕ → ℕ`. Then, we compose
    this map with a retraction of `ℕ → ℕ` onto `s` to obtain the desired map.
    Let us consider a dense sequence `u` in `α`. Then `s` is the set of sequences `xₙ` such that the
    balls `closed_ball (u xₙ) (1/2^n)` have a nonempty intersection. This set is closed, and we define
    `f x` there to be the unique point in the intersection. This function is continuous and surjective
    by design. -/
  letI : MetricSpace (ℕ → ℕ) := PiNat.metricSpaceNatNat
  have I0 : (0 : ℝ) < 1 / 2 := by norm_num
  have I1 : (1 / 2 : ℝ) < 1 := by norm_num
  rcases exists_dense_seq α with ⟨u, hu⟩
  let s : Set (ℕ → ℕ) := { x | (⋂ n : ℕ, closed_ball (u (x n)) ((1 / 2) ^ n)).Nonempty }
  let g : s → α := fun x => x.2.some
  have A : ∀ (x : s) (n : ℕ), dist (g x) (u ((x : ℕ → ℕ) n)) ≤ (1 / 2) ^ n := fun x n =>
    (mem_Inter.1 x.2.some_mem n : _)
  have g_cont : Continuous g :=
    by
    apply continuous_iff_continuousAt.2 fun y => _
    apply continuousAt_of_locally_lipschitz zero_lt_one 4 fun x hxy => _
    rcases eq_or_ne x y with (rfl | hne)
    · simp
    have hne' : x.1 ≠ y.1 := subtype.coe_injective.ne hne
    have dist' : dist x y = dist x.1 y.1 := rfl
    let n := first_diff x.1 y.1 - 1
    have diff_pos : 0 < first_diff x.1 y.1 :=
      by
      by_contra' h
      apply apply_first_diff_ne hne'
      rw [le_zero_iff.1 h]
      apply apply_eq_of_dist_lt _ le_rfl
      rw [pow_zero]
      exact hxy
    have hn : first_diff x.1 y.1 = n + 1 := (Nat.succ_pred_eq_of_pos diff_pos).symm
    rw [dist', dist_eq_of_ne hne', hn]
    have B : x.1 n = y.1 n := mem_cylinder_first_diff x.1 y.1 n (Nat.pred_lt diff_pos.ne')
    calc
      dist (g x) (g y) ≤ dist (g x) (u (x.1 n)) + dist (g y) (u (x.1 n)) :=
        dist_triangle_right _ _ _
      _ = dist (g x) (u (x.1 n)) + dist (g y) (u (y.1 n)) := by rw [← B]
      _ ≤ (1 / 2) ^ n + (1 / 2) ^ n := (add_le_add (A x n) (A y n))
      _ = 4 * (1 / 2) ^ (n + 1) := by ring
      
  have g_surj : surjective g := by
    intro y
    have : ∀ n : ℕ, ∃ j, y ∈ closed_ball (u j) ((1 / 2) ^ n) :=
      by
      intro n
      rcases hu.exists_dist_lt y (by simp : (0 : ℝ) < (1 / 2) ^ n) with ⟨j, hj⟩
      exact ⟨j, hj.le⟩
    choose x hx using this
    have I : (⋂ n : ℕ, closed_ball (u (x n)) ((1 / 2) ^ n)).Nonempty := ⟨y, mem_Inter.2 hx⟩
    refine' ⟨⟨x, I⟩, _⟩
    refine' dist_le_zero.1 _
    have J : ∀ n : ℕ, dist (g ⟨x, I⟩) y ≤ (1 / 2) ^ n + (1 / 2) ^ n := fun n =>
      calc
        dist (g ⟨x, I⟩) y ≤ dist (g ⟨x, I⟩) (u (x n)) + dist y (u (x n)) :=
          dist_triangle_right _ _ _
        _ ≤ (1 / 2) ^ n + (1 / 2) ^ n := add_le_add (A ⟨x, I⟩ n) (hx n)
        
    have L : tendsto (fun n : ℕ => (1 / 2 : ℝ) ^ n + (1 / 2) ^ n) at_top (𝓝 (0 + 0)) :=
      (tendsto_pow_atTop_nhds_0_of_lt_1 I0.le I1).add (tendsto_pow_atTop_nhds_0_of_lt_1 I0.le I1)
    rw [add_zero] at L
    exact ge_of_tendsto' L J
  have s_closed : IsClosed s :=
    by
    refine' is_closed_iff_cluster_pt.mpr _
    intro x hx
    have L : tendsto (fun n : ℕ => diam (closed_ball (u (x n)) ((1 / 2) ^ n))) at_top (𝓝 0) :=
      by
      have : tendsto (fun n : ℕ => (2 : ℝ) * (1 / 2) ^ n) at_top (𝓝 (2 * 0)) :=
        (tendsto_pow_atTop_nhds_0_of_lt_1 I0.le I1).const_mul _
      rw [MulZeroClass.mul_zero] at this
      exact
        squeeze_zero (fun n => diam_nonneg) (fun n => diam_closed_ball (pow_nonneg I0.le _)) this
    refine'
      nonempty_Inter_of_nonempty_bInter (fun n => is_closed_ball) (fun n => bounded_closed_ball) _ L
    intro N
    obtain ⟨y, hxy, ys⟩ : ∃ y, y ∈ ball x ((1 / 2) ^ N) ∩ s :=
      clusterPt_principal_iff.1 hx _ (ball_mem_nhds x (pow_pos I0 N))
    have E :
      (⋂ (n : ℕ) (H : n ≤ N), closed_ball (u (x n)) ((1 / 2) ^ n)) =
        ⋂ (n : ℕ) (H : n ≤ N), closed_ball (u (y n)) ((1 / 2) ^ n) :=
      by
      congr
      ext1 n
      congr
      ext1 hn
      have : x n = y n := apply_eq_of_dist_lt (mem_ball'.1 hxy) hn
      rw [this]
    rw [E]
    apply nonempty.mono _ ys
    apply Inter_subset_Inter₂
  obtain ⟨f, -, f_surj, f_cont⟩ :
    ∃ f : (ℕ → ℕ) → s, (∀ x : s, f x = x) ∧ surjective f ∧ Continuous f :=
    by
    apply exists_retraction_subtype_of_is_closed s_closed
    simpa only [nonempty_coe_sort] using g_surj.nonempty
  exact ⟨g ∘ f, g_cont.comp f_cont, g_surj.comp f_surj⟩
#align exists_nat_nat_continuous_surjective_of_complete_space exists_nat_nat_continuous_surjective_of_completeSpace

namespace PiCountable

/-!
### Products of (possibly non-discrete) metric spaces
-/


variable {ι : Type _} [Encodable ι] {F : ι → Type _} [∀ i, MetricSpace (F i)]

open Encodable

#print PiCountable.dist /-
/-- Given a countable family of metric spaces, one may put a distance on their product `Π i, E i`.
It is highly non-canonical, though, and therefore not registered as a global instance.
The distance we use here is `dist x y = ∑' i, min (1/2)^(encode i) (dist (x i) (y i))`. -/
protected def dist : Dist (∀ i, F i) :=
  ⟨fun x y => ∑' i : ι, min ((1 / 2) ^ encode i) (dist (x i) (y i))⟩
#align pi_countable.has_dist PiCountable.dist
-/

attribute [local instance] PiCountable.dist

/- warning: pi_countable.dist_eq_tsum -> PiCountable.dist_eq_tsum is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Encodable.{u1} ι] {F : ι -> Type.{u2}} [_inst_2 : forall (i : ι), MetricSpace.{u2} (F i)] (x : forall (i : ι), F i) (y : forall (i : ι), F i), Eq.{1} Real (Dist.dist.{max u1 u2} (forall (i : ι), F i) (PiCountable.dist.{u1, u2} ι _inst_1 (fun (i : ι) => F i) (fun (i : ι) => _inst_2 i)) x y) (tsum.{0, u1} Real Real.addCommMonoid (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) ι (fun (i : ι) => LinearOrder.min.{0} Real Real.linearOrder (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.monoid)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (DivInvMonoid.toHasDiv.{0} Real (DivisionRing.toDivInvMonoid.{0} Real Real.divisionRing))) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))) (OfNat.ofNat.{0} Real 2 (OfNat.mk.{0} Real 2 (bit0.{0} Real Real.hasAdd (One.one.{0} Real Real.hasOne))))) (Encodable.encode.{u1} ι _inst_1 i)) (Dist.dist.{u2} (F i) (PseudoMetricSpace.toHasDist.{u2} (F i) (MetricSpace.toPseudoMetricSpace.{u2} (F i) (_inst_2 i))) (x i) (y i))))
but is expected to have type
  forall {ι : Type.{u2}} [_inst_1 : Encodable.{u2} ι] {F : ι -> Type.{u1}} [_inst_2 : forall (i : ι), MetricSpace.{u1} (F i)] (x : forall (i : ι), F i) (y : forall (i : ι), F i), Eq.{1} Real (Dist.dist.{max u2 u1} (forall (i : ι), F i) (PiCountable.dist.{u2, u1} ι _inst_1 (fun (i : ι) => F i) (fun (i : ι) => _inst_2 i)) x y) (tsum.{0, u2} Real Real.instAddCommMonoidReal (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) ι (fun (i : ι) => Min.min.{0} Real (LinearOrderedRing.toMin.{0} Real Real.instLinearOrderedRingReal) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.instMonoidReal)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (LinearOrderedField.toDiv.{0} Real Real.instLinearOrderedFieldReal)) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)) (OfNat.ofNat.{0} Real 2 (instOfNat.{0} Real 2 Real.natCast (instAtLeastTwoHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))))) (Encodable.encode.{u2} ι _inst_1 i)) (Dist.dist.{u1} (F i) (PseudoMetricSpace.toDist.{u1} (F i) (MetricSpace.toPseudoMetricSpace.{u1} (F i) (_inst_2 i))) (x i) (y i))))
Case conversion may be inaccurate. Consider using '#align pi_countable.dist_eq_tsum PiCountable.dist_eq_tsumₓ'. -/
theorem dist_eq_tsum (x y : ∀ i, F i) :
    dist x y = ∑' i : ι, min ((1 / 2) ^ encode i) (dist (x i) (y i)) :=
  rfl
#align pi_countable.dist_eq_tsum PiCountable.dist_eq_tsum

/- warning: pi_countable.dist_summable -> PiCountable.dist_summable is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Encodable.{u1} ι] {F : ι -> Type.{u2}} [_inst_2 : forall (i : ι), MetricSpace.{u2} (F i)] (x : forall (i : ι), F i) (y : forall (i : ι), F i), Summable.{0, u1} Real ι Real.addCommMonoid (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (fun (i : ι) => LinearOrder.min.{0} Real Real.linearOrder (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.monoid)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (DivInvMonoid.toHasDiv.{0} Real (DivisionRing.toDivInvMonoid.{0} Real Real.divisionRing))) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))) (OfNat.ofNat.{0} Real 2 (OfNat.mk.{0} Real 2 (bit0.{0} Real Real.hasAdd (One.one.{0} Real Real.hasOne))))) (Encodable.encode.{u1} ι _inst_1 i)) (Dist.dist.{u2} (F i) (PseudoMetricSpace.toHasDist.{u2} (F i) (MetricSpace.toPseudoMetricSpace.{u2} (F i) (_inst_2 i))) (x i) (y i)))
but is expected to have type
  forall {ι : Type.{u2}} [_inst_1 : Encodable.{u2} ι] {F : ι -> Type.{u1}} [_inst_2 : forall (i : ι), MetricSpace.{u1} (F i)] (x : forall (i : ι), F i) (y : forall (i : ι), F i), Summable.{0, u2} Real ι Real.instAddCommMonoidReal (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (fun (i : ι) => Min.min.{0} Real (LinearOrderedRing.toMin.{0} Real Real.instLinearOrderedRingReal) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.instMonoidReal)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (LinearOrderedField.toDiv.{0} Real Real.instLinearOrderedFieldReal)) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)) (OfNat.ofNat.{0} Real 2 (instOfNat.{0} Real 2 Real.natCast (instAtLeastTwoHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))))) (Encodable.encode.{u2} ι _inst_1 i)) (Dist.dist.{u1} (F i) (PseudoMetricSpace.toDist.{u1} (F i) (MetricSpace.toPseudoMetricSpace.{u1} (F i) (_inst_2 i))) (x i) (y i)))
Case conversion may be inaccurate. Consider using '#align pi_countable.dist_summable PiCountable.dist_summableₓ'. -/
theorem dist_summable (x y : ∀ i, F i) :
    Summable fun i : ι => min ((1 / 2) ^ encode i) (dist (x i) (y i)) :=
  by
  refine'
    summable_of_nonneg_of_le (fun i => _) (fun i => min_le_left _ _) summable_geometric_two_encode
  exact le_min (pow_nonneg (by norm_num) _) dist_nonneg
#align pi_countable.dist_summable PiCountable.dist_summable

/- warning: pi_countable.min_dist_le_dist_pi -> PiCountable.min_dist_le_dist_pi is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Encodable.{u1} ι] {F : ι -> Type.{u2}} [_inst_2 : forall (i : ι), MetricSpace.{u2} (F i)] (x : forall (i : ι), F i) (y : forall (i : ι), F i) (i : ι), LE.le.{0} Real Real.hasLe (LinearOrder.min.{0} Real Real.linearOrder (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.monoid)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (DivInvMonoid.toHasDiv.{0} Real (DivisionRing.toDivInvMonoid.{0} Real Real.divisionRing))) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))) (OfNat.ofNat.{0} Real 2 (OfNat.mk.{0} Real 2 (bit0.{0} Real Real.hasAdd (One.one.{0} Real Real.hasOne))))) (Encodable.encode.{u1} ι _inst_1 i)) (Dist.dist.{u2} (F i) (PseudoMetricSpace.toHasDist.{u2} (F i) (MetricSpace.toPseudoMetricSpace.{u2} (F i) (_inst_2 i))) (x i) (y i))) (Dist.dist.{max u1 u2} (forall (i : ι), F i) (PiCountable.dist.{u1, u2} ι _inst_1 (fun (i : ι) => F i) (fun (i : ι) => _inst_2 i)) x y)
but is expected to have type
  forall {ι : Type.{u2}} [_inst_1 : Encodable.{u2} ι] {F : ι -> Type.{u1}} [_inst_2 : forall (i : ι), MetricSpace.{u1} (F i)] (x : forall (i : ι), F i) (y : forall (i : ι), F i) (i : ι), LE.le.{0} Real Real.instLEReal (Min.min.{0} Real (LinearOrderedRing.toMin.{0} Real Real.instLinearOrderedRingReal) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.instMonoidReal)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (LinearOrderedField.toDiv.{0} Real Real.instLinearOrderedFieldReal)) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)) (OfNat.ofNat.{0} Real 2 (instOfNat.{0} Real 2 Real.natCast (instAtLeastTwoHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))))) (Encodable.encode.{u2} ι _inst_1 i)) (Dist.dist.{u1} (F i) (PseudoMetricSpace.toDist.{u1} (F i) (MetricSpace.toPseudoMetricSpace.{u1} (F i) (_inst_2 i))) (x i) (y i))) (Dist.dist.{max u2 u1} (forall (i : ι), F i) (PiCountable.dist.{u2, u1} ι _inst_1 (fun (i : ι) => F i) (fun (i : ι) => _inst_2 i)) x y)
Case conversion may be inaccurate. Consider using '#align pi_countable.min_dist_le_dist_pi PiCountable.min_dist_le_dist_piₓ'. -/
theorem min_dist_le_dist_pi (x y : ∀ i, F i) (i : ι) :
    min ((1 / 2) ^ encode i) (dist (x i) (y i)) ≤ dist x y :=
  le_tsum (dist_summable x y) i fun j hj => le_min (by simp) dist_nonneg
#align pi_countable.min_dist_le_dist_pi PiCountable.min_dist_le_dist_pi

/- warning: pi_countable.dist_le_dist_pi_of_dist_lt -> PiCountable.dist_le_dist_pi_of_dist_lt is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Encodable.{u1} ι] {F : ι -> Type.{u2}} [_inst_2 : forall (i : ι), MetricSpace.{u2} (F i)] {x : forall (i : ι), F i} {y : forall (i : ι), F i} {i : ι}, (LT.lt.{0} Real Real.hasLt (Dist.dist.{max u1 u2} (forall (i : ι), F i) (PiCountable.dist.{u1, u2} ι _inst_1 (fun (i : ι) => F i) (fun (i : ι) => _inst_2 i)) x y) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.monoid)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (DivInvMonoid.toHasDiv.{0} Real (DivisionRing.toDivInvMonoid.{0} Real Real.divisionRing))) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))) (OfNat.ofNat.{0} Real 2 (OfNat.mk.{0} Real 2 (bit0.{0} Real Real.hasAdd (One.one.{0} Real Real.hasOne))))) (Encodable.encode.{u1} ι _inst_1 i))) -> (LE.le.{0} Real Real.hasLe (Dist.dist.{u2} (F i) (PseudoMetricSpace.toHasDist.{u2} (F i) (MetricSpace.toPseudoMetricSpace.{u2} (F i) (_inst_2 i))) (x i) (y i)) (Dist.dist.{max u1 u2} (forall (i : ι), F i) (PiCountable.dist.{u1, u2} ι _inst_1 (fun (i : ι) => F i) (fun (i : ι) => _inst_2 i)) x y))
but is expected to have type
  forall {ι : Type.{u2}} [_inst_1 : Encodable.{u2} ι] {F : ι -> Type.{u1}} [_inst_2 : forall (i : ι), MetricSpace.{u1} (F i)] {x : forall (i : ι), F i} {y : forall (i : ι), F i} {i : ι}, (LT.lt.{0} Real Real.instLTReal (Dist.dist.{max u2 u1} (forall (i : ι), F i) (PiCountable.dist.{u2, u1} ι _inst_1 (fun (i : ι) => F i) (fun (i : ι) => _inst_2 i)) x y) (HPow.hPow.{0, 0, 0} Real Nat Real (instHPow.{0, 0} Real Nat (Monoid.Pow.{0} Real Real.instMonoidReal)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (LinearOrderedField.toDiv.{0} Real Real.instLinearOrderedFieldReal)) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)) (OfNat.ofNat.{0} Real 2 (instOfNat.{0} Real 2 Real.natCast (instAtLeastTwoHAddNatInstHAddInstAddNatOfNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))))) (Encodable.encode.{u2} ι _inst_1 i))) -> (LE.le.{0} Real Real.instLEReal (Dist.dist.{u1} (F i) (PseudoMetricSpace.toDist.{u1} (F i) (MetricSpace.toPseudoMetricSpace.{u1} (F i) (_inst_2 i))) (x i) (y i)) (Dist.dist.{max u2 u1} (forall (i : ι), F i) (PiCountable.dist.{u2, u1} ι _inst_1 (fun (i : ι) => F i) (fun (i : ι) => _inst_2 i)) x y))
Case conversion may be inaccurate. Consider using '#align pi_countable.dist_le_dist_pi_of_dist_lt PiCountable.dist_le_dist_pi_of_dist_ltₓ'. -/
theorem dist_le_dist_pi_of_dist_lt {x y : ∀ i, F i} {i : ι} (h : dist x y < (1 / 2) ^ encode i) :
    dist (x i) (y i) ≤ dist x y := by
  simpa only [not_le.2 h, false_or_iff] using min_le_iff.1 (min_dist_le_dist_pi x y i)
#align pi_countable.dist_le_dist_pi_of_dist_lt PiCountable.dist_le_dist_pi_of_dist_lt

open BigOperators Topology

open Filter

open NNReal

variable (E)

#print PiCountable.metricSpace /-
/-- Given a countable family of metric spaces, one may put a distance on their product `Π i, E i`,
defining the right topology and uniform structure. It is highly non-canonical, though, and therefore
not registered as a global instance.
The distance we use here is `dist x y = ∑' n, min (1/2)^(encode i) (dist (x n) (y n))`. -/
protected def metricSpace : MetricSpace (∀ i, F i)
    where
  dist_self x := by simp [dist_eq_tsum]
  dist_comm x y := by simp [dist_eq_tsum, dist_comm]
  dist_triangle x y z :=
    by
    have I :
      ∀ i,
        min ((1 / 2) ^ encode i) (dist (x i) (z i)) ≤
          min ((1 / 2) ^ encode i) (dist (x i) (y i)) +
            min ((1 / 2) ^ encode i) (dist (y i) (z i)) :=
      fun i =>
      calc
        min ((1 / 2) ^ encode i) (dist (x i) (z i)) ≤
            min ((1 / 2) ^ encode i) (dist (x i) (y i) + dist (y i) (z i)) :=
          min_le_min le_rfl (dist_triangle _ _ _)
        _ =
            min ((1 / 2) ^ encode i)
              (min ((1 / 2) ^ encode i) (dist (x i) (y i)) +
                min ((1 / 2) ^ encode i) (dist (y i) (z i))) :=
          by
          convert congr_arg (coe : ℝ≥0 → ℝ)
                (min_add_distrib ((1 / 2 : ℝ≥0) ^ encode i) (nndist (x i) (y i))
                  (nndist (y i) (z i))) <;>
            simp
        _ ≤
            min ((1 / 2) ^ encode i) (dist (x i) (y i)) +
              min ((1 / 2) ^ encode i) (dist (y i) (z i)) :=
          min_le_right _ _
        
    calc
      dist x z ≤
          ∑' i,
            min ((1 / 2) ^ encode i) (dist (x i) (y i)) +
              min ((1 / 2) ^ encode i) (dist (y i) (z i)) :=
        tsum_le_tsum I (dist_summable x z) ((dist_summable x y).add (dist_summable y z))
      _ = dist x y + dist y z := tsum_add (dist_summable x y) (dist_summable y z)
      
  eq_of_dist_eq_zero := by
    intro x y hxy
    ext1 n
    rw [← dist_le_zero, ← hxy]
    apply dist_le_dist_pi_of_dist_lt
    rw [hxy]
    simp
  toUniformSpace := Pi.uniformSpace _
  uniformity_dist := by
    have I0 : (0 : ℝ) ≤ 1 / 2 := by norm_num
    have I1 : (1 / 2 : ℝ) < 1 := by norm_num
    simp only [Pi.uniformity, comap_infi, gt_iff_lt, preimage_set_of_eq, comap_principal,
      PseudoMetricSpace.uniformity_dist]
    apply le_antisymm
    · simp only [le_infᵢ_iff, le_principal_iff]
      intro ε εpos
      obtain ⟨K, hK⟩ :
        ∃ K : Finset ι, (∑' i : { j // j ∉ K }, (1 / 2 : ℝ) ^ encode (i : ι)) < ε / 2 :=
        ((tendsto_order.1 (tendsto_tsum_compl_atTop_zero fun i : ι => (1 / 2 : ℝ) ^ encode i)).2 _
            (half_pos εpos)).exists
      obtain ⟨δ, δpos, hδ⟩ : ∃ (δ : ℝ)(δpos : 0 < δ), (K.card : ℝ) * δ ≤ ε / 2 :=
        by
        rcases Nat.eq_zero_or_pos K.card with (hK | hK)
        ·
          exact
            ⟨1, zero_lt_one, by
              simpa only [hK, Nat.cast_zero, MulZeroClass.zero_mul] using (half_pos εpos).le⟩
        · have Kpos : 0 < (K.card : ℝ) := Nat.cast_pos.2 hK
          refine' ⟨ε / 2 / (K.card : ℝ), div_pos (half_pos εpos) Kpos, le_of_eq _⟩
          field_simp [Kpos.ne']
          ring
      apply
        @mem_infi_of_Inter _ _ _ _ _ K.finite_to_set fun i =>
          { p : (∀ i : ι, F i) × ∀ i : ι, F i | dist (p.fst i) (p.snd i) < δ }
      · rintro ⟨i, hi⟩
        refine' mem_infi_of_mem δ (mem_infi_of_mem δpos _)
        simp only [Prod.forall, imp_self, mem_principal]
      · rintro ⟨x, y⟩ hxy
        simp only [mem_Inter, mem_set_of_eq, SetCoe.forall, Finset.mem_range, Finset.mem_coe] at hxy
        calc
          dist x y = ∑' i : ι, min ((1 / 2) ^ encode i) (dist (x i) (y i)) := rfl
          _ =
              (∑ i in K, min ((1 / 2) ^ encode i) (dist (x i) (y i))) +
                ∑' i : (↑K : Set ι)ᶜ, min ((1 / 2) ^ encode (i : ι)) (dist (x i) (y i)) :=
            (sum_add_tsum_compl (dist_summable _ _)).symm
          _ ≤ (∑ i in K, dist (x i) (y i)) + ∑' i : (↑K : Set ι)ᶜ, (1 / 2) ^ encode (i : ι) :=
            by
            refine' add_le_add (Finset.sum_le_sum fun i hi => min_le_right _ _) _
            refine' tsum_le_tsum (fun i => min_le_left _ _) _ _
            · apply Summable.subtype (dist_summable x y) ((↑K : Set ι)ᶜ)
            · apply Summable.subtype summable_geometric_two_encode ((↑K : Set ι)ᶜ)
          _ < (∑ i in K, δ) + ε / 2 :=
            by
            apply add_lt_add_of_le_of_lt _ hK
            apply Finset.sum_le_sum fun i hi => _
            apply (hxy i _).le
            simpa using hi
          _ ≤ ε / 2 + ε / 2 :=
            (add_le_add_right (by simpa only [Finset.sum_const, nsmul_eq_mul] using hδ) _)
          _ = ε := add_halves _
          
    · simp only [le_infᵢ_iff, le_principal_iff]
      intro i ε εpos
      refine' mem_infi_of_mem (min ((1 / 2) ^ encode i) ε) _
      have : 0 < min ((1 / 2) ^ encode i) ε := lt_min (by simp) εpos
      refine' mem_infi_of_mem this _
      simp only [and_imp, Prod.forall, set_of_subset_set_of, lt_min_iff, mem_principal]
      intro x y hn hε
      calc
        dist (x i) (y i) ≤ dist x y := dist_le_dist_pi_of_dist_lt hn
        _ < ε := hε
        
#align pi_countable.metric_space PiCountable.metricSpace
-/

end PiCountable

