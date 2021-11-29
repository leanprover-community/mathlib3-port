import Mathbin.CategoryTheory.Functor

/-!
# Unbundled functors, as a typeclass decorating the object-level function.
-/


namespace CategoryTheory

universe v v₁ v₂ v₃ u u₁ u₂ u₃

variable{C : Type u₁}[category.{v₁} C]{D : Type u₂}[category.{v₂} D]

/-- A unbundled functor. -/
class functorial(F : C → D) : Type max v₁ v₂ u₁ u₂ where 
  map : ∀ {X Y : C}, (X ⟶ Y) → (F X ⟶ F Y)
  map_id' : ∀ (X : C), map (𝟙 X) = 𝟙 (F X) :=  by 
  runTac 
    obviously 
  map_comp' : ∀ {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z), map (f ≫ g) = map f ≫ map g :=  by 
  runTac 
    obviously

/--
If `F : C → D` (just a function) has `[functorial F]`,
we can write `map F f : F X ⟶ F Y` for the action of `F` on a morphism `f : X ⟶ Y`.
-/
def map (F : C → D) [functorial.{v₁, v₂} F] {X Y : C} (f : X ⟶ Y) : F X ⟶ F Y :=
  functorial.map.{v₁, v₂} f

@[simp]
theorem map_as_map {F : C → D} [functorial.{v₁, v₂} F] {X Y : C} {f : X ⟶ Y} : functorial.map.{v₁, v₂} f = map F f :=
  rfl

@[simp]
theorem functorial.map_id {F : C → D} [functorial.{v₁, v₂} F] {X : C} : map F (𝟙 X) = 𝟙 (F X) :=
  functorial.map_id' X

@[simp]
theorem functorial.map_comp {F : C → D} [functorial.{v₁, v₂} F] {X Y Z : C} {f : X ⟶ Y} {g : Y ⟶ Z} :
  map F (f ≫ g) = map F f ≫ map F g :=
  functorial.map_comp' f g

namespace Functor

/--
Bundle a functorial function as a functor.
-/
def of (F : C → D) [I : functorial.{v₁, v₂} F] : C ⥤ D :=
  { I with obj := F }

end Functor

instance  (F : C ⥤ D) : functorial.{v₁, v₂} F.obj :=
  { F with  }

@[simp]
theorem map_functorial_obj (F : C ⥤ D) {X Y : C} (f : X ⟶ Y) : map F.obj f = F.map f :=
  rfl

instance functorial_id : functorial.{v₁, v₁} (id : C → C) :=
  { map := fun X Y f => f }

section 

variable{E : Type u₃}[category.{v₃} E]

/--
`G ∘ F` is a functorial if both `F` and `G` are.
-/
def functorial_comp (F : C → D) [functorial.{v₁, v₂} F] (G : D → E) [functorial.{v₂, v₃} G] :
  functorial.{v₁, v₃} (G ∘ F) :=
  { functor.of F ⋙ functor.of G with  }

end 

end CategoryTheory

