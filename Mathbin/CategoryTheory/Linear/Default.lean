import Mathbin.CategoryTheory.Preadditive.Default 
import Mathbin.Algebra.Module.LinearMap 
import Mathbin.Algebra.Invertible 
import Mathbin.LinearAlgebra.Basic 
import Mathbin.Algebra.Algebra.Basic

/-!
# Linear categories

An `R`-linear category is a category in which `X ⟶ Y` is an `R`-module in such a way that
composition of morphisms is `R`-linear in both variables.

## Implementation

Corresponding to the fact that we need to have an `add_comm_group X` structure in place
to talk about a `module R X` structure,
we need `preadditive C` as a prerequisite typeclass for `linear R C`.
This makes for longer signatures than would be ideal.

## Future work

It would be nice to have a usable framework of enriched categories in which this just became
a category enriched in `Module R`.

-/


universe w v u

open CategoryTheory.Limits

open LinearMap

namespace CategoryTheory

/-- A category is called `R`-linear if `P ⟶ Q` is an `R`-module such that composition is
    `R`-linear in both variables. -/
class linear(R : Type w)[Semiringₓ R](C : Type u)[category.{v} C][preadditive C] where 
  homModule : ∀ (X Y : C), Module R (X ⟶ Y) :=  by 
  runTac 
    tactic.apply_instance 
  smul_comp' : ∀ (X Y Z : C) (r : R) (f : X ⟶ Y) (g : Y ⟶ Z), (r • f) ≫ g = r • f ≫ g :=  by 
  runTac 
    obviously 
  comp_smul' : ∀ (X Y Z : C) (f : X ⟶ Y) (r : R) (g : Y ⟶ Z), f ≫ (r • g) = r • f ≫ g :=  by 
  runTac 
    obviously

attribute [instance] linear.hom_module

restate_axiom linear.smul_comp'

restate_axiom linear.comp_smul'

attribute [simp, reassoc] linear.smul_comp

attribute [reassoc, simp] linear.comp_smul

end CategoryTheory

open CategoryTheory

namespace CategoryTheory.Linear

variable{C : Type u}[category.{v} C][preadditive C]

instance preadditive_nat_linear : linear ℕ C :=
  { smul_comp' := fun X Y Z r f g => (preadditive.right_comp X g).map_nsmul f r,
    comp_smul' := fun X Y Z f r g => (preadditive.left_comp Z f).map_nsmul g r }

instance preadditive_int_linear : linear ℤ C :=
  { smul_comp' := fun X Y Z r f g => (preadditive.right_comp X g).map_zsmul f r,
    comp_smul' := fun X Y Z f r g => (preadditive.left_comp Z f).map_zsmul g r }

section End

variable{R : Type w}[CommRingₓ R][linear R C]

instance  (X : C) : Module R (End X) :=
  by 
    dsimp [End]
    infer_instance

instance  (X : C) : Algebra R (End X) :=
  Algebra.ofModule (fun r f g => comp_smul _ _ _ _ _ _) fun r f g => smul_comp _ _ _ _ _ _

end End

section 

variable{R : Type w}[Semiringₓ R][linear R C]

section InducedCategory

universe u'

variable{C}{D : Type u'}(F : D → C)

instance induced_category.category : linear.{w, v} R (induced_category C F) :=
  { homModule := fun X Y => @linear.hom_module R _ C _ _ _ (F X) (F Y),
    smul_comp' := fun P Q R f f' g => smul_comp' _ _ _ _ _ _, comp_smul' := fun P Q R f g g' => comp_smul' _ _ _ _ _ _ }

end InducedCategory

variable(R)

/-- Composition by a fixed left argument as an `R`-linear map. -/
@[simps]
def left_comp {X Y : C} (Z : C) (f : X ⟶ Y) : (Y ⟶ Z) →ₗ[R] X ⟶ Z :=
  { toFun := fun g => f ≫ g,
    map_add' :=
      by 
        simp ,
    map_smul' :=
      by 
        simp  }

/-- Composition by a fixed right argument as an `R`-linear map. -/
@[simps]
def right_comp (X : C) {Y Z : C} (g : Y ⟶ Z) : (X ⟶ Y) →ₗ[R] X ⟶ Z :=
  { toFun := fun f => f ≫ g,
    map_add' :=
      by 
        simp ,
    map_smul' :=
      by 
        simp  }

instance  {X Y : C} (f : X ⟶ Y) [epi f] (r : R) [Invertible r] : epi (r • f) :=
  ⟨fun R g g' H =>
      by 
        rw [smul_comp, smul_comp, ←comp_smul, ←comp_smul, cancel_epi] at H 
        simpa [smul_smul] using congr_argₓ (fun f => ⅟ r • f) H⟩

instance  {X Y : C} (f : X ⟶ Y) [mono f] (r : R) [Invertible r] : mono (r • f) :=
  ⟨fun R g g' H =>
      by 
        rw [comp_smul, comp_smul, ←smul_comp, ←smul_comp, cancel_mono] at H 
        simpa [smul_smul] using congr_argₓ (fun f => ⅟ r • f) H⟩

end 

section 

variable{S : Type w}[CommSemiringₓ S][linear S C]

/-- Composition as a bilinear map. -/
@[simps]
def comp (X Y Z : C) : (X ⟶ Y) →ₗ[S] (Y ⟶ Z) →ₗ[S] X ⟶ Z :=
  { toFun := fun f => left_comp S Z f,
    map_add' :=
      by 
        intros 
        ext 
        simp ,
    map_smul' :=
      by 
        intros 
        ext 
        simp  }

end 

end CategoryTheory.Linear

