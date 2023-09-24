/-
Copyright (c) 2021 Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta
-/
import CategoryTheory.Monoidal.Braided
import CategoryTheory.Monoidal.Transport
import CategoryTheory.Skeletal

#align_import category_theory.monoidal.skeleton from "leanprover-community/mathlib"@"6b31d1eebd64eab86d5bd9936bfaada6ca8b5842"

/-!
# The monoid on the skeleton of a monoidal category

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The skeleton of a monoidal category is a monoid.
-/


namespace CategoryTheory

open MonoidalCategory

universe v u

variable {C : Type u} [Category.{v} C] [MonoidalCategory C]

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.monoidOfSkeletalMonoidal /-
/-- If `C` is monoidal and skeletal, it is a monoid.
See note [reducible non-instances]. -/
@[reducible]
def monoidOfSkeletalMonoidal (hC : Skeletal C) : Monoid C
    where
  mul X Y := (X ⊗ Y : C)
  one := (𝟙_ C : C)
  one_mul X := hC ⟨λ_ X⟩
  mul_one X := hC ⟨ρ_ X⟩
  mul_assoc X Y Z := hC ⟨α_ X Y Z⟩
#align category_theory.monoid_of_skeletal_monoidal CategoryTheory.monoidOfSkeletalMonoidal
-/

#print CategoryTheory.commMonoidOfSkeletalBraided /-
/-- If `C` is braided and skeletal, it is a commutative monoid. -/
def commMonoidOfSkeletalBraided [BraidedCategory C] (hC : Skeletal C) : CommMonoid C :=
  { monoidOfSkeletalMonoidal hC with mul_comm := fun X Y => hC ⟨β_ X Y⟩ }
#align category_theory.comm_monoid_of_skeletal_braided CategoryTheory.commMonoidOfSkeletalBraided
-/

/-- The skeleton of a monoidal category has a monoidal structure itself, induced by the equivalence.
-/
noncomputable instance : MonoidalCategory (Skeleton C) :=
  Monoidal.transport (skeletonEquivalence C).symm

/--
The skeleton of a monoidal category can be viewed as a monoid, where the multiplication is given by
the tensor product, and satisfies the monoid axioms since it is a skeleton.
-/
noncomputable instance : Monoid (Skeleton C) :=
  monoidOfSkeletalMonoidal (skeletonIsSkeleton _).skel

-- TODO: Transfer the braided structure to the skeleton of C along the equivalence, and show that
-- the skeleton is a commutative monoid.
end CategoryTheory

