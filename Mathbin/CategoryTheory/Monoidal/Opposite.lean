import Mathbin.CategoryTheory.Monoidal.Category

/-!
# Monoidal opposites

We write `Cᵐᵒᵖ` for the monoidal opposite of a monoidal category `C`.
-/


universe v₁ v₂ u₁ u₂

variable {C : Type u₁}

namespace CategoryTheory

open CategoryTheory.MonoidalCategory

/-- A type synonym for the monoidal opposite. Use the notation `Cᴹᵒᵖ`. -/
@[nolint has_inhabited_instance]
def monoidal_opposite (C : Type u₁) :=
  C

namespace MonoidalOpposite

-- error in CategoryTheory.Monoidal.Opposite: ././Mathport/Syntax/Translate/Basic.lean:265:9: unsupported: advanced prec syntax
notation C `ᴹᵒᵖ`:std.prec.max_plus := monoidal_opposite C

/-- Think of an object of `C` as an object of `Cᴹᵒᵖ`. -/
@[pp_nodot]
def mop (X : C) : «expr ᴹᵒᵖ» C :=
  X

/-- Think of an object of `Cᴹᵒᵖ` as an object of `C`. -/
@[pp_nodot]
def unmop (X : «expr ᴹᵒᵖ» C) : C :=
  X

theorem op_injective : Function.Injective (mop : C → «expr ᴹᵒᵖ» C) :=
  fun _ _ => id

theorem unop_injective : Function.Injective (unmop : «expr ᴹᵒᵖ» C → C) :=
  fun _ _ => id

@[simp]
theorem op_inj_iff (x y : C) : mop x = mop y ↔ x = y :=
  Iff.rfl

@[simp]
theorem unop_inj_iff (x y : «expr ᴹᵒᵖ» C) : unmop x = unmop y ↔ x = y :=
  Iff.rfl

@[simp]
theorem mop_unmop (X : «expr ᴹᵒᵖ» C) : mop (unmop X) = X :=
  rfl

@[simp]
theorem unmop_mop (X : C) : unmop (mop X) = X :=
  rfl

instance monoidal_opposite_category [I : category.{v₁} C] : category («expr ᴹᵒᵖ» C) :=
  { Hom := fun X Y => unmop X ⟶ unmop Y, id := fun X => 𝟙 (unmop X), comp := fun X Y Z f g => f ≫ g }

end MonoidalOpposite

end CategoryTheory

open CategoryTheory

open CategoryTheory.MonoidalOpposite

variable [category.{v₁} C]

/-- The monoidal opposite of a morphism `f : X ⟶ Y` is just `f`, thought of as `mop X ⟶ mop Y`. -/
def Quiver.Hom.mop {X Y : C} (f : X ⟶ Y) : @Quiver.Hom («expr ᴹᵒᵖ» C) _ (mop X) (mop Y) :=
  f

/-- We can think of a morphism `f : mop X ⟶ mop Y` as a morphism `X ⟶ Y`. -/
def Quiver.Hom.unmop {X Y : «expr ᴹᵒᵖ» C} (f : X ⟶ Y) : unmop X ⟶ unmop Y :=
  f

namespace CategoryTheory

theorem mop_inj {X Y : C} : Function.Injective (Quiver.Hom.mop : (X ⟶ Y) → (mop X ⟶ mop Y)) :=
  fun _ _ H => congr_argₓ Quiver.Hom.unmop H

theorem unmop_inj {X Y : «expr ᴹᵒᵖ» C} : Function.Injective (Quiver.Hom.unmop : (X ⟶ Y) → (unmop X ⟶ unmop Y)) :=
  fun _ _ H => congr_argₓ Quiver.Hom.mop H

@[simp]
theorem unmop_mop {X Y : C} {f : X ⟶ Y} : f.mop.unmop = f :=
  rfl

@[simp]
theorem mop_unmop {X Y : «expr ᴹᵒᵖ» C} {f : X ⟶ Y} : f.unmop.mop = f :=
  rfl

@[simp]
theorem mop_comp {X Y Z : C} {f : X ⟶ Y} {g : Y ⟶ Z} : (f ≫ g).mop = f.mop ≫ g.mop :=
  rfl

@[simp]
theorem mop_id {X : C} : (𝟙 X).mop = 𝟙 (mop X) :=
  rfl

@[simp]
theorem unmop_comp {X Y Z : «expr ᴹᵒᵖ» C} {f : X ⟶ Y} {g : Y ⟶ Z} : (f ≫ g).unmop = f.unmop ≫ g.unmop :=
  rfl

@[simp]
theorem unmop_id {X : «expr ᴹᵒᵖ» C} : (𝟙 X).unmop = 𝟙 (unmop X) :=
  rfl

@[simp]
theorem unmop_id_mop {X : C} : (𝟙 (mop X)).unmop = 𝟙 X :=
  rfl

@[simp]
theorem mop_id_unmop {X : «expr ᴹᵒᵖ» C} : (𝟙 (unmop X)).mop = 𝟙 X :=
  rfl

namespace Iso

variable {X Y : C}

/-- An isomorphism in `C` gives an isomorphism in `Cᴹᵒᵖ`. -/
@[simps]
def mop (f : X ≅ Y) : mop X ≅ mop Y :=
  { Hom := f.hom.mop, inv := f.inv.mop, hom_inv_id' := unmop_inj f.hom_inv_id, inv_hom_id' := unmop_inj f.inv_hom_id }

end Iso

variable [monoidal_category.{v₁} C]

open Opposite MonoidalCategory

instance monoidal_category_op : monoidal_category («expr ᵒᵖ» C) :=
  { tensorObj := fun X Y => op (unop X ⊗ unop Y), tensorHom := fun X₁ Y₁ X₂ Y₂ f g => (f.unop ⊗ g.unop).op,
    tensorUnit := op (𝟙_ C), associator := fun X Y Z => (α_ (unop X) (unop Y) (unop Z)).symm.op,
    leftUnitor := fun X => (λ_ (unop X)).symm.op, rightUnitor := fun X => (ρ_ (unop X)).symm.op,
    associator_naturality' :=
      by 
        intros 
        apply Quiver.Hom.unop_inj 
        simp [associator_inv_naturality],
    left_unitor_naturality' :=
      by 
        intros 
        apply Quiver.Hom.unop_inj 
        simp [left_unitor_inv_naturality],
    right_unitor_naturality' :=
      by 
        intros 
        apply Quiver.Hom.unop_inj 
        simp [right_unitor_inv_naturality],
    triangle' :=
      by 
        intros 
        apply Quiver.Hom.unop_inj 
        dsimp 
        simp ,
    pentagon' :=
      by 
        intros 
        apply Quiver.Hom.unop_inj 
        dsimp 
        simp [pentagon_inv] }

theorem op_tensor_obj (X Y : «expr ᵒᵖ» C) : X ⊗ Y = op (unop X ⊗ unop Y) :=
  rfl

theorem op_tensor_unit : 𝟙_ («expr ᵒᵖ» C) = op (𝟙_ C) :=
  rfl

instance monoidal_category_mop : monoidal_category («expr ᴹᵒᵖ» C) :=
  { tensorObj := fun X Y => mop (unmop Y ⊗ unmop X), tensorHom := fun X₁ Y₁ X₂ Y₂ f g => (g.unmop ⊗ f.unmop).mop,
    tensorUnit := mop (𝟙_ C), associator := fun X Y Z => (α_ (unmop Z) (unmop Y) (unmop X)).symm.mop,
    leftUnitor := fun X => (ρ_ (unmop X)).mop, rightUnitor := fun X => (λ_ (unmop X)).mop,
    associator_naturality' :=
      by 
        intros 
        apply unmop_inj 
        simp [associator_inv_naturality],
    left_unitor_naturality' :=
      by 
        intros 
        apply unmop_inj 
        simp [right_unitor_naturality],
    right_unitor_naturality' :=
      by 
        intros 
        apply unmop_inj 
        simp [left_unitor_naturality],
    triangle' :=
      by 
        intros 
        apply unmop_inj 
        dsimp 
        simp ,
    pentagon' :=
      by 
        intros 
        apply unmop_inj 
        dsimp 
        simp [pentagon_inv] }

theorem mop_tensor_obj (X Y : «expr ᴹᵒᵖ» C) : X ⊗ Y = mop (unmop Y ⊗ unmop X) :=
  rfl

theorem mop_tensor_unit : 𝟙_ («expr ᴹᵒᵖ» C) = mop (𝟙_ C) :=
  rfl

end CategoryTheory

