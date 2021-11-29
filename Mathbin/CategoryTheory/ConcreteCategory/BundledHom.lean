import Mathbin.CategoryTheory.ConcreteCategory.Basic 
import Mathbin.CategoryTheory.ConcreteCategory.Bundled

/-!
# Category instances for algebraic structures that use bundled homs.

Many algebraic structures in Lean initially used unbundled homs (e.g. a bare function between types,
along with an `is_monoid_hom` typeclass), but the general trend is towards using bundled homs.

This file provides a basic infrastructure to define concrete categories using bundled homs, and
define forgetful functors between them.
-/


universe u

namespace CategoryTheory

variable{c : Type u → Type u}(hom : ∀ ⦃α β : Type u⦄ (Iα : c α) (Iβ : c β), Type u)

/-- Class for bundled homs. Note that the arguments order follows that of lemmas for `monoid_hom`.
This way we can use `⟨@monoid_hom.to_fun, @monoid_hom.id ...⟩` in an instance. -/
structure bundled_hom where 
  toFun : ∀ {α β : Type u} (Iα : c α) (Iβ : c β), hom Iα Iβ → α → β 
  id : ∀ {α : Type u} (I : c α), hom I I 
  comp : ∀ {α β γ : Type u} (Iα : c α) (Iβ : c β) (Iγ : c γ), hom Iβ Iγ → hom Iα Iβ → hom Iα Iγ 
  hom_ext : ∀ {α β : Type u} (Iα : c α) (Iβ : c β), Function.Injective (to_fun Iα Iβ) :=  by 
  runTac 
    obviously 
  id_to_fun : ∀ {α : Type u} (I : c α), to_fun I I (id I) = _root_.id :=  by 
  runTac 
    obviously 
  comp_to_fun :
  ∀ {α β γ : Type u} (Iα : c α) (Iβ : c β) (Iγ : c γ) (f : hom Iα Iβ) (g : hom Iβ Iγ),
    to_fun Iα Iγ (comp Iα Iβ Iγ g f) = to_fun Iβ Iγ g ∘ to_fun Iα Iβ f :=
   by 
  runTac 
    obviously

attribute [class] bundled_hom

attribute [simp] bundled_hom.id_to_fun bundled_hom.comp_to_fun

namespace BundledHom

variable[𝒞 : bundled_hom hom]

include 𝒞

/-- Every `@bundled_hom c _` defines a category with objects in `bundled c`.

This instance generates the type-class problem `bundled_hom ?m` (which is why this is marked as
`[nolint]`). Currently that is not a problem, as there are almost no instances of `bundled_hom`. -/
@[nolint dangerous_instance]
instance category : category (bundled c) :=
  by 
    refine'
        { Hom := fun X Y => @hom X Y X.str Y.str, id := fun X => @bundled_hom.id c hom 𝒞 X X.str,
          comp := fun X Y Z f g => @bundled_hom.comp c hom 𝒞 X Y Z X.str Y.str Z.str g f, comp_id' := _, id_comp' := _,
          assoc' := _ } <;>
      intros  <;> apply 𝒞.hom_ext <;> simp only [𝒞.id_to_fun, 𝒞.comp_to_fun, Function.left_id, Function.right_id]

/-- A category given by `bundled_hom` is a concrete category.

This instance generates the type-class problem `bundled_hom ?m` (which is why this is marked as
`[nolint]`). Currently that is not a problem, as there are almost no instances of `bundled_hom`. -/
@[nolint dangerous_instance]
instance  : concrete_category.{u} (bundled c) :=
  { forget :=
      { obj := fun X => X, map := fun X Y f => 𝒞.to_fun X.str Y.str f, map_id' := fun X => 𝒞.id_to_fun X.str,
        map_comp' :=
          by 
            intros  <;> erw [𝒞.comp_to_fun] <;> rfl },
    forget_faithful :=
      { map_injective' :=
          by 
            intros  <;> apply 𝒞.hom_ext } }

variable{hom}

attribute [local instance] concrete_category.has_coe_to_fun

/-- A version of `has_forget₂.mk'` for categories defined using `@bundled_hom`. -/
def mk_has_forget₂ {d : Type u → Type u} {hom_d : ∀ ⦃α β : Type u⦄ (Iα : d α) (Iβ : d β), Type u} [bundled_hom hom_d]
  (obj : ∀ ⦃α⦄, c α → d α) (map : ∀ {X Y : bundled c}, (X ⟶ Y) → (bundled.map obj X ⟶ bundled.map obj Y))
  (h_map : ∀ {X Y : bundled c} (f : X ⟶ Y), (map f : X → Y) = f) : has_forget₂ (bundled c) (bundled d) :=
  has_forget₂.mk' (bundled.map @obj) (fun _ => rfl) (@map)
    (by 
      intros  <;> apply heq_of_eq <;> apply h_map)

variable{d : Type u → Type u}

variable(hom)

section 

omit 𝒞

/--
The `hom` corresponding to first forgetting along `F`, then taking the `hom` associated to `c`.

For typical usage, see the construction of `CommMon` from `Mon`.
-/
@[reducible]
def map_hom (F : ∀ {α}, d α → c α) : ∀ ⦃α β : Type u⦄ (Iα : d α) (Iβ : d β), Type u :=
  fun α β iα iβ => hom (F iα) (F iβ)

end 

/--
Construct the `bundled_hom` induced by a map between type classes.
This is useful for building categories such as `CommMon` from `Mon`.
-/
def map (F : ∀ {α}, d α → c α) : bundled_hom (map_hom hom @F) :=
  { toFun := fun α β iα iβ f => 𝒞.to_fun (F iα) (F iβ) f, id := fun α iα => 𝒞.id (F iα),
    comp := fun α β γ iα iβ iγ f g => 𝒞.comp (F iα) (F iβ) (F iγ) f g,
    hom_ext := fun α β iα iβ f g h => 𝒞.hom_ext (F iα) (F iβ) h }

section 

omit 𝒞

/--
We use the empty `parent_projection` class to label functions like `comm_monoid.to_monoid`,
which we would like to use to automatically construct `bundled_hom` instances from.

Once we've set up `Mon` as the category of bundled monoids,
this allows us to set up `CommMon` by defining an instance
```instance : parent_projection (comm_monoid.to_monoid) := ⟨⟩```
-/
class parent_projection(F : ∀ {α}, d α → c α)

end 

@[nolint unused_arguments]
instance bundled_hom_of_parent_projection (F : ∀ {α}, d α → c α) [parent_projection @F] :
  bundled_hom (map_hom hom @F) :=
  map hom @F

instance forget₂ (F : ∀ {α}, d α → c α) [parent_projection @F] : has_forget₂ (bundled d) (bundled c) :=
  { forget₂ := { obj := fun X => ⟨X, F X.2⟩, map := fun X Y f => f } }

instance forget₂_full (F : ∀ {α}, d α → c α) [parent_projection @F] : full (forget₂ (bundled d) (bundled c)) :=
  { Preimage := fun X Y f => f }

end BundledHom

end CategoryTheory

