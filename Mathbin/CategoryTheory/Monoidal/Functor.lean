import Mathbin.CategoryTheory.Monoidal.Category 
import Mathbin.CategoryTheory.Adjunction.Basic

/-!
# (Lax) monoidal functors

A lax monoidal functor `F` between monoidal categories `C` and `D`
is a functor between the underlying categories equipped with morphisms
* `ε : 𝟙_ D ⟶ F.obj (𝟙_ C)` (called the unit morphism)
* `μ X Y : (F.obj X) ⊗ (F.obj Y) ⟶ F.obj (X ⊗ Y)` (called the tensorator, or strength).
satisfying various axioms.

A monoidal functor is a lax monoidal functor for which `ε` and `μ` are isomorphisms.

We show that the composition of (lax) monoidal functors gives a (lax) monoidal functor.

See also `category_theory.monoidal.functorial` for a typeclass decorating an object-level
function with the additional data of a monoidal functor.
This is useful when stating that a pre-existing functor is monoidal.

See `category_theory.monoidal.natural_transformation` for monoidal natural transformations.

We show in `category_theory.monoidal.Mon_` that lax monoidal functors take monoid objects
to monoid objects.

## Future work
* Oplax monoidal functors.

## References

See https://stacks.math.columbia.edu/tag/0FFL.
-/


open CategoryTheory

universe v₁ v₂ v₃ u₁ u₂ u₃

open CategoryTheory.Category

open CategoryTheory.Functor

namespace CategoryTheory

section 

open MonoidalCategory

variable(C : Type u₁)[category.{v₁} C][monoidal_category.{v₁} C](D : Type u₂)[category.{v₂} D][monoidal_category.{v₂} D]

/-- A lax monoidal functor is a functor `F : C ⥤ D` between monoidal categories,
equipped with morphisms `ε : 𝟙 _D ⟶ F.obj (𝟙_ C)` and `μ X Y : F.obj X ⊗ F.obj Y ⟶ F.obj (X ⊗ Y)`,
satisfying the appropriate coherences. -/
structure lax_monoidal_functor extends C ⥤ D where 
  ε : 𝟙_ D ⟶ obj (𝟙_ C)
  μ : ∀ (X Y : C), obj X ⊗ obj Y ⟶ obj (X ⊗ Y)
  μ_natural' : ∀ {X Y X' Y' : C} (f : X ⟶ Y) (g : X' ⟶ Y'), (map f ⊗ map g) ≫ μ Y Y' = μ X X' ≫ map (f ⊗ g) :=  by 
  runTac 
    obviously 
  associativity' :
  ∀ (X Y Z : C),
    (μ X Y ⊗ 𝟙 (obj Z)) ≫ μ (X ⊗ Y) Z ≫ map (α_ X Y Z).Hom =
      (α_ (obj X) (obj Y) (obj Z)).Hom ≫ (𝟙 (obj X) ⊗ μ Y Z) ≫ μ X (Y ⊗ Z) :=
   by 
  runTac 
    obviously 
  left_unitality' : ∀ (X : C), (λ_ (obj X)).Hom = (ε ⊗ 𝟙 (obj X)) ≫ μ (𝟙_ C) X ≫ map (λ_ X).Hom :=  by 
  runTac 
    obviously 
  right_unitality' : ∀ (X : C), (ρ_ (obj X)).Hom = (𝟙 (obj X) ⊗ ε) ≫ μ X (𝟙_ C) ≫ map (ρ_ X).Hom :=  by 
  runTac 
    obviously

restate_axiom lax_monoidal_functor.μ_natural'

attribute [simp, reassoc] lax_monoidal_functor.μ_natural

restate_axiom lax_monoidal_functor.left_unitality'

attribute [simp] lax_monoidal_functor.left_unitality

restate_axiom lax_monoidal_functor.right_unitality'

attribute [simp] lax_monoidal_functor.right_unitality

restate_axiom lax_monoidal_functor.associativity'

attribute [simp, reassoc] lax_monoidal_functor.associativity

section 

variable{C D}

@[simp, reassoc]
theorem lax_monoidal_functor.left_unitality_inv (F : lax_monoidal_functor C D) (X : C) :
  (λ_ (F.obj X)).inv ≫ (F.ε ⊗ 𝟙 (F.obj X)) ≫ F.μ (𝟙_ C) X = F.map (λ_ X).inv :=
  by 
    rw [iso.inv_comp_eq, F.left_unitality, category.assoc, category.assoc, ←F.to_functor.map_comp, iso.hom_inv_id,
      F.to_functor.map_id, comp_id]

@[simp, reassoc]
theorem lax_monoidal_functor.right_unitality_inv (F : lax_monoidal_functor C D) (X : C) :
  (ρ_ (F.obj X)).inv ≫ (𝟙 (F.obj X) ⊗ F.ε) ≫ F.μ X (𝟙_ C) = F.map (ρ_ X).inv :=
  by 
    rw [iso.inv_comp_eq, F.right_unitality, category.assoc, category.assoc, ←F.to_functor.map_comp, iso.hom_inv_id,
      F.to_functor.map_id, comp_id]

@[simp, reassoc]
theorem lax_monoidal_functor.associativity_inv (F : lax_monoidal_functor C D) (X Y Z : C) :
  (𝟙 (F.obj X) ⊗ F.μ Y Z) ≫ F.μ X (Y ⊗ Z) ≫ F.map (α_ X Y Z).inv =
    (α_ (F.obj X) (F.obj Y) (F.obj Z)).inv ≫ (F.μ X Y ⊗ 𝟙 (F.obj Z)) ≫ F.μ (X ⊗ Y) Z :=
  by 
    rw [iso.eq_inv_comp, ←F.associativity_assoc, ←F.to_functor.map_comp, iso.hom_inv_id, F.to_functor.map_id, comp_id]

end 

/--
A monoidal functor is a lax monoidal functor for which the tensorator and unitor as isomorphisms.

See https://stacks.math.columbia.edu/tag/0FFL.
-/
structure monoidal_functor extends lax_monoidal_functor.{v₁, v₂} C D where 
  ε_is_iso : is_iso ε :=  by 
  runTac 
    tactic.apply_instance 
  μ_is_iso : ∀ (X Y : C), is_iso (μ X Y) :=  by 
  runTac 
    tactic.apply_instance

attribute [instance] monoidal_functor.ε_is_iso monoidal_functor.μ_is_iso

variable{C D}

/--
The unit morphism of a (strong) monoidal functor as an isomorphism.
-/
noncomputable def monoidal_functor.ε_iso (F : monoidal_functor.{v₁, v₂} C D) : tensor_unit D ≅ F.obj (tensor_unit C) :=
  as_iso F.ε

/--
The tensorator of a (strong) monoidal functor as an isomorphism.
-/
noncomputable def monoidal_functor.μ_iso (F : monoidal_functor.{v₁, v₂} C D) (X Y : C) :
  F.obj X ⊗ F.obj Y ≅ F.obj (X ⊗ Y) :=
  as_iso (F.μ X Y)

end 

open MonoidalCategory

namespace LaxMonoidalFunctor

variable(C : Type u₁)[category.{v₁} C][monoidal_category.{v₁} C]

/-- The identity lax monoidal functor. -/
@[simps]
def id : lax_monoidal_functor.{v₁, v₁} C C :=
  { 𝟭 C with ε := 𝟙 _, μ := fun X Y => 𝟙 _ }

instance  : Inhabited (lax_monoidal_functor C C) :=
  ⟨id C⟩

end LaxMonoidalFunctor

namespace MonoidalFunctor

section 

variable{C : Type u₁}[category.{v₁} C][monoidal_category.{v₁} C]

variable{D : Type u₂}[category.{v₂} D][monoidal_category.{v₂} D]

theorem map_tensor (F : monoidal_functor.{v₁, v₂} C D) {X Y X' Y' : C} (f : X ⟶ Y) (g : X' ⟶ Y') :
  F.map (f ⊗ g) = inv (F.μ X X') ≫ (F.map f ⊗ F.map g) ≫ F.μ Y Y' :=
  by 
    simp 

theorem map_left_unitor (F : monoidal_functor.{v₁, v₂} C D) (X : C) :
  F.map (λ_ X).Hom = inv (F.μ (𝟙_ C) X) ≫ (inv F.ε ⊗ 𝟙 (F.obj X)) ≫ (λ_ (F.obj X)).Hom :=
  by 
    simp only [lax_monoidal_functor.left_unitality]
    sliceRHS 2 3 => rw [←comp_tensor_id]simp 
    simp 

theorem map_right_unitor (F : monoidal_functor.{v₁, v₂} C D) (X : C) :
  F.map (ρ_ X).Hom = inv (F.μ X (𝟙_ C)) ≫ (𝟙 (F.obj X) ⊗ inv F.ε) ≫ (ρ_ (F.obj X)).Hom :=
  by 
    simp only [lax_monoidal_functor.right_unitality]
    sliceRHS 2 3 => rw [←id_tensor_comp]simp 
    simp 

/-- The tensorator as a natural isomorphism. -/
noncomputable def μ_nat_iso (F : monoidal_functor.{v₁, v₂} C D) :
  functor.prod F.to_functor F.to_functor ⋙ tensor D ≅ tensor C ⋙ F.to_functor :=
  nat_iso.of_components
    (by 
      intros 
      apply F.μ_iso)
    (by 
      intros 
      apply F.to_lax_monoidal_functor.μ_natural)

end 

section 

variable(C : Type u₁)[category.{v₁} C][monoidal_category.{v₁} C]

/-- The identity monoidal functor. -/
@[simps]
def id : monoidal_functor.{v₁, v₁} C C :=
  { 𝟭 C with ε := 𝟙 _, μ := fun X Y => 𝟙 _ }

instance  : Inhabited (monoidal_functor C C) :=
  ⟨id C⟩

end 

end MonoidalFunctor

variable{C : Type u₁}[category.{v₁} C][monoidal_category.{v₁} C]

variable{D : Type u₂}[category.{v₂} D][monoidal_category.{v₂} D]

variable{E : Type u₃}[category.{v₃} E][monoidal_category.{v₃} E]

namespace LaxMonoidalFunctor

variable(F : lax_monoidal_functor.{v₁, v₂} C D)(G : lax_monoidal_functor.{v₂, v₃} D E)

/-- The composition of two lax monoidal functors is again lax monoidal. -/
@[simps]
def comp : lax_monoidal_functor.{v₁, v₃} C E :=
  { F.to_functor ⋙ G.to_functor with ε := G.ε ≫ G.map F.ε, μ := fun X Y => G.μ (F.obj X) (F.obj Y) ≫ G.map (F.μ X Y),
    μ_natural' :=
      fun _ _ _ _ f g =>
        by 
          simp only [functor.comp_map, assoc]
          rw [←category.assoc, lax_monoidal_functor.μ_natural, category.assoc, ←map_comp, ←map_comp,
            ←lax_monoidal_functor.μ_natural],
    associativity' :=
      fun X Y Z =>
        by 
          dsimp 
          rw [id_tensor_comp]
          sliceRHS 3 4 => rw [←G.to_functor.map_id, G.μ_natural]
          sliceRHS 1 3 => rw [←G.associativity]
          rw [comp_tensor_id]
          sliceLHS 2 3 => rw [←G.to_functor.map_id, G.μ_natural]
          rw [category.assoc, category.assoc, category.assoc, category.assoc, category.assoc, ←G.to_functor.map_comp,
            ←G.to_functor.map_comp, ←G.to_functor.map_comp, ←G.to_functor.map_comp, F.associativity],
    left_unitality' :=
      fun X =>
        by 
          dsimp 
          rw [G.left_unitality, comp_tensor_id, category.assoc, category.assoc]
          apply congr_argₓ 
          rw [F.left_unitality, map_comp, ←nat_trans.id_app, ←category.assoc, ←lax_monoidal_functor.μ_natural,
            nat_trans.id_app, map_id, ←category.assoc, map_comp],
    right_unitality' :=
      fun X =>
        by 
          dsimp 
          rw [G.right_unitality, id_tensor_comp, category.assoc, category.assoc]
          apply congr_argₓ 
          rw [F.right_unitality, map_comp, ←nat_trans.id_app, ←category.assoc, ←lax_monoidal_functor.μ_natural,
            nat_trans.id_app, map_id, ←category.assoc, map_comp] }

infixr:80 " ⊗⋙ " => comp

end LaxMonoidalFunctor

namespace MonoidalFunctor

variable(F : monoidal_functor.{v₁, v₂} C D)(G : monoidal_functor.{v₂, v₃} D E)

/-- The composition of two monoidal functors is again monoidal. -/
@[simps]
def comp : monoidal_functor.{v₁, v₃} C E :=
  { F.to_lax_monoidal_functor.comp G.to_lax_monoidal_functor with
    ε_is_iso :=
      by 
        dsimp 
        infer_instance,
    μ_is_iso :=
      by 
        dsimp 
        infer_instance }

infixr:80 " ⊗⋙ " => comp

end MonoidalFunctor

/--
If we have a right adjoint functor `G` to a monoidal functor `F`, then `G` has a lax monoidal
structure as well.
-/
@[simps]
noncomputable def monoidal_adjoint (F : monoidal_functor C D) {G : D ⥤ C} (h : F.to_functor ⊣ G) :
  lax_monoidal_functor D C :=
  { toFunctor := G, ε := h.hom_equiv _ _ (inv F.ε),
    μ := fun X Y => h.hom_equiv _ (X ⊗ Y) (inv (F.μ (G.obj X) (G.obj Y)) ≫ (h.counit.app X ⊗ h.counit.app Y)),
    μ_natural' :=
      fun X Y X' Y' f g =>
        by 
          rw [←h.hom_equiv_naturality_left, ←h.hom_equiv_naturality_right, Equiv.apply_eq_iff_eq, assoc,
            is_iso.eq_inv_comp, ←F.to_lax_monoidal_functor.μ_natural_assoc, is_iso.hom_inv_id_assoc, ←tensor_comp,
            adjunction.counit_naturality, adjunction.counit_naturality, tensor_comp],
    associativity' :=
      fun X Y Z =>
        by 
          rw [←h.hom_equiv_naturality_right, ←h.hom_equiv_naturality_left, ←h.hom_equiv_naturality_left,
            ←h.hom_equiv_naturality_left, Equiv.apply_eq_iff_eq,
            ←cancel_epi (F.to_lax_monoidal_functor.μ (G.obj X ⊗ G.obj Y) (G.obj Z)),
            ←cancel_epi (F.to_lax_monoidal_functor.μ (G.obj X) (G.obj Y) ⊗ 𝟙 (F.obj (G.obj Z))),
            F.to_lax_monoidal_functor.associativity_assoc (G.obj X) (G.obj Y) (G.obj Z),
            ←F.to_lax_monoidal_functor.μ_natural_assoc, assoc, is_iso.hom_inv_id_assoc,
            ←F.to_lax_monoidal_functor.μ_natural_assoc, is_iso.hom_inv_id_assoc, ←tensor_comp, ←tensor_comp, id_comp,
            Functor.map_id, Functor.map_id, id_comp, ←tensor_comp_assoc, ←tensor_comp_assoc, id_comp, id_comp,
            h.hom_equiv_unit, h.hom_equiv_unit, functor.map_comp, assoc, assoc, h.counit_naturality,
            h.left_triangle_components_assoc, is_iso.hom_inv_id_assoc, functor.map_comp, assoc, h.counit_naturality,
            h.left_triangle_components_assoc, is_iso.hom_inv_id_assoc]
          exact associator_naturality (h.counit.app X) (h.counit.app Y) (h.counit.app Z),
    left_unitality' :=
      fun X =>
        by 
          rw [←h.hom_equiv_naturality_right, ←h.hom_equiv_naturality_left, ←Equiv.symm_apply_eq, h.hom_equiv_counit,
            F.map_left_unitor, h.hom_equiv_unit, assoc, assoc, assoc, F.map_tensor, assoc, assoc,
            is_iso.hom_inv_id_assoc, ←tensor_comp_assoc, Functor.map_id, id_comp, functor.map_comp, assoc,
            h.counit_naturality, h.left_triangle_components_assoc, ←left_unitor_naturality, ←tensor_comp_assoc, id_comp,
            comp_id],
    right_unitality' :=
      fun X =>
        by 
          rw [←h.hom_equiv_naturality_right, ←h.hom_equiv_naturality_left, ←Equiv.symm_apply_eq, h.hom_equiv_counit,
            F.map_right_unitor, assoc, assoc, ←right_unitor_naturality, ←tensor_comp_assoc, comp_id, id_comp,
            h.hom_equiv_unit, F.map_tensor, assoc, assoc, assoc, is_iso.hom_inv_id_assoc, functor.map_comp,
            Functor.map_id, ←tensor_comp_assoc, assoc, h.counit_naturality, h.left_triangle_components_assoc, id_comp] }

/-- If a monoidal functor `F` is an equivalence of categories then its inverse is also monoidal. -/
noncomputable def monoidal_inverse (F : monoidal_functor C D) [is_equivalence F.to_functor] : monoidal_functor D C :=
  { toLaxMonoidalFunctor := monoidal_adjoint F (as_equivalence _).toAdjunction,
    ε_is_iso :=
      by 
        dsimp [equivalence.to_adjunction]
        infer_instance,
    μ_is_iso :=
      fun X Y =>
        by 
          dsimp [equivalence.to_adjunction]
          infer_instance }

@[simp]
theorem monoidal_inverse_to_functor (F : monoidal_functor C D) [is_equivalence F.to_functor] :
  (monoidal_inverse F).toFunctor = F.to_functor.inv :=
  rfl

end CategoryTheory

