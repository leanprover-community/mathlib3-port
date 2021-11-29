import Mathbin.CategoryTheory.Currying 
import Mathbin.CategoryTheory.Limits.Over 
import Mathbin.CategoryTheory.Limits.Shapes.Images 
import Mathbin.CategoryTheory.Adjunction.Reflective

/-!
# Monomorphisms over a fixed object

As preparation for defining `subobject X`, we set up the theory for
`mono_over X := {f : over X // mono f.hom}`.

Here `mono_over X` is a thin category (a pair of objects has at most one morphism between them),
so we can think of it as a preorder. However as it is not skeletal, it is not yet a partial order.

`subobject X` will be defined as the skeletalization of `mono_over X`.

We provide
* `def pullback [has_pullbacks C] (f : X ⟶ Y) : mono_over Y ⥤ mono_over X`
* `def map (f : X ⟶ Y) [mono f] : mono_over X ⥤ mono_over Y`
* `def «exists» [has_images C] (f : X ⟶ Y) : mono_over X ⥤ mono_over Y`
and prove their basic properties and relationships.

## Notes

This development originally appeared in Bhavik Mehta's "Topos theory for Lean" repository,
and was ported to mathlib by Scott Morrison.

-/


universe v₁ v₂ u₁ u₂

noncomputable theory

namespace CategoryTheory

open CategoryTheory CategoryTheory.Category CategoryTheory.Limits

variable{C : Type u₁}[category.{v₁} C]{X Y Z : C}

variable{D : Type u₂}[category.{v₂} D]

-- error in CategoryTheory.Subobject.MonoOver: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler category
/--
The category of monomorphisms into `X` as a full subcategory of the over category.
This isn't skeletal, so it's not a partial order.

Later we define `subobject X` as the quotient of this by isomorphisms.
-/ @[derive #["[", expr category, "]"]] def mono_over (X : C) :=
{f : over X // mono f.hom}

namespace MonoOver

/-- Construct a `mono_over X`. -/
@[simps]
def mk' {X A : C} (f : A ⟶ X) [hf : mono f] : mono_over X :=
  { val := over.mk f, property := hf }

/-- The inclusion from monomorphisms over X to morphisms over X. -/
def forget (X : C) : mono_over X ⥤ over X :=
  full_subcategory_inclusion _

instance  : Coe (mono_over X) C :=
  { coe := fun Y => Y.val.left }

@[simp]
theorem forget_obj_left {f} : ((forget X).obj f).left = (f : C) :=
  rfl

@[simp]
theorem mk'_coe' {X A : C} (f : A ⟶ X) [hf : mono f] : (mk' f : C) = A :=
  rfl

/-- Convenience notation for the underlying arrow of a monomorphism over X. -/
abbrev arrow (f : mono_over X) : (f : C) ⟶ X :=
  ((forget X).obj f).Hom

@[simp]
theorem mk'_arrow {X A : C} (f : A ⟶ X) [hf : mono f] : (mk' f).arrow = f :=
  rfl

@[simp]
theorem forget_obj_hom {f} : ((forget X).obj f).Hom = f.arrow :=
  rfl

instance  : full (forget X) :=
  full_subcategory.full _

instance  : faithful (forget X) :=
  full_subcategory.faithful _

instance mono (f : mono_over X) : mono f.arrow :=
  f.property

/-- The category of monomorphisms over X is a thin category,
which makes defining its skeleton easy. -/
instance is_thin {X : C} (f g : mono_over X) : Subsingleton (f ⟶ g) :=
  ⟨by 
      intro h₁ h₂ 
      ext1 
      erw [←cancel_mono g.arrow, over.w h₁, over.w h₂]⟩

@[reassoc]
theorem w {f g : mono_over X} (k : f ⟶ g) : k.left ≫ g.arrow = f.arrow :=
  over.w _

/-- Convenience constructor for a morphism in monomorphisms over `X`. -/
abbrev hom_mk {f g : mono_over X} (h : f.val.left ⟶ g.val.left) (w : h ≫ g.arrow = f.arrow) : f ⟶ g :=
  over.hom_mk h w

/-- Convenience constructor for an isomorphism in monomorphisms over `X`. -/
@[simps]
def iso_mk {f g : mono_over X} (h : f.val.left ≅ g.val.left) (w : h.hom ≫ g.arrow = f.arrow) : f ≅ g :=
  { Hom := hom_mk h.hom w,
    inv :=
      hom_mk h.inv
        (by 
          rw [h.inv_comp_eq, w]) }

/-- If `f : mono_over X`, then `mk' f.arrow` is of course just `f`, but not definitionally, so we
    package it as an isomorphism. -/
@[simp]
def mk'_arrow_iso {X : C} (f : mono_over X) : mk' f.arrow ≅ f :=
  iso_mk (iso.refl _)
    (by 
      simp )

/--
Lift a functor between over categories to a functor between `mono_over` categories,
given suitable evidence that morphisms are taken to monomorphisms.
-/
@[simps]
def lift {Y : D} (F : over Y ⥤ over X) (h : ∀ (f : mono_over Y), mono (F.obj ((mono_over.forget Y).obj f)).Hom) :
  mono_over Y ⥤ mono_over X :=
  { obj := fun f => ⟨_, h f⟩, map := fun _ _ k => (mono_over.forget X).Preimage ((mono_over.forget Y ⋙ F).map k) }

/--
Isomorphic functors `over Y ⥤ over X` lift to isomorphic functors `mono_over Y ⥤ mono_over X`.
-/
def lift_iso {Y : D} {F₁ F₂ : over Y ⥤ over X} h₁ h₂ (i : F₁ ≅ F₂) : lift F₁ h₁ ≅ lift F₂ h₂ :=
  fully_faithful_cancel_right (mono_over.forget X) (iso_whisker_left (mono_over.forget Y) i)

/-- `mono_over.lift` commutes with composition of functors. -/
def lift_comp {X Z : C} {Y : D} (F : over X ⥤ over Y) (G : over Y ⥤ over Z) h₁ h₂ :
  lift F h₁ ⋙ lift G h₂ ≅ lift (F ⋙ G) fun f => h₂ ⟨_, h₁ f⟩ :=
  fully_faithful_cancel_right (mono_over.forget _) (iso.refl _)

/-- `mono_over.lift` preserves the identity functor. -/
def lift_id : (lift (𝟭 (over X)) fun f => f.2) ≅ 𝟭 _ :=
  fully_faithful_cancel_right (mono_over.forget _) (iso.refl _)

@[simp]
theorem lift_comm (F : over Y ⥤ over X) (h : ∀ (f : mono_over Y), mono (F.obj ((mono_over.forget Y).obj f)).Hom) :
  lift F h ⋙ mono_over.forget X = mono_over.forget Y ⋙ F :=
  rfl

@[simp]
theorem lift_obj_arrow {Y : D} (F : over Y ⥤ over X)
  (h : ∀ (f : mono_over Y), mono (F.obj ((mono_over.forget Y).obj f)).Hom) (f : mono_over Y) :
  ((lift F h).obj f).arrow = (F.obj ((forget Y).obj f)).Hom :=
  rfl

/--
Monomorphisms over an object `f : over A` in an over category
are equivalent to monomorphisms over the source of `f`.
-/
def slice {A : C} {f : over A} h₁ h₂ : mono_over f ≌ mono_over f.left :=
  { Functor := mono_over.lift f.iterated_slice_equiv.functor h₁,
    inverse := mono_over.lift f.iterated_slice_equiv.inverse h₂,
    unitIso :=
      mono_over.lift_id.symm ≪≫
        mono_over.lift_iso _ _ f.iterated_slice_equiv.unit_iso ≪≫ (mono_over.lift_comp _ _ _ _).symm,
    counitIso :=
      mono_over.lift_comp _ _ _ _ ≪≫ mono_over.lift_iso _ _ f.iterated_slice_equiv.counit_iso ≪≫ mono_over.lift_id }

section Pullback

variable[has_pullbacks C]

/-- When `C` has pullbacks, a morphism `f : X ⟶ Y` induces a functor `mono_over Y ⥤ mono_over X`,
by pulling back a monomorphism along `f`. -/
def pullback (f : X ⟶ Y) : mono_over Y ⥤ mono_over X :=
  mono_over.lift (over.pullback f)
    (by 
      intro g 
      apply @pullback.snd_of_mono _ _ _ _ _ _ _ _ _ 
      change mono g.arrow 
      infer_instance)

/-- pullback commutes with composition (up to a natural isomorphism) -/
def pullback_comp (f : X ⟶ Y) (g : Y ⟶ Z) : pullback (f ≫ g) ≅ pullback g ⋙ pullback f :=
  lift_iso _ _ (over.pullback_comp _ _) ≪≫ (lift_comp _ _ _ _).symm

/-- pullback preserves the identity (up to a natural isomorphism) -/
def pullback_id : pullback (𝟙 X) ≅ 𝟭 _ :=
  lift_iso _ _ over.pullback_id ≪≫ lift_id

@[simp]
theorem pullback_obj_left (f : X ⟶ Y) (g : mono_over Y) : ((pullback f).obj g : C) = limits.pullback g.arrow f :=
  rfl

@[simp]
theorem pullback_obj_arrow (f : X ⟶ Y) (g : mono_over Y) : ((pullback f).obj g).arrow = pullback.snd :=
  rfl

end Pullback

section Map

attribute [instance] mono_comp

/--
We can map monomorphisms over `X` to monomorphisms over `Y`
by post-composition with a monomorphism `f : X ⟶ Y`.
-/
def map (f : X ⟶ Y) [mono f] : mono_over X ⥤ mono_over Y :=
  lift (over.map f)
    fun g =>
      by 
        apply mono_comp g.arrow f

/-- `mono_over.map` commutes with composition (up to a natural isomorphism). -/
def map_comp (f : X ⟶ Y) (g : Y ⟶ Z) [mono f] [mono g] : map (f ≫ g) ≅ map f ⋙ map g :=
  lift_iso _ _ (over.map_comp _ _) ≪≫ (lift_comp _ _ _ _).symm

/-- `mono_over.map` preserves the identity (up to a natural isomorphism). -/
def map_id : map (𝟙 X) ≅ 𝟭 _ :=
  lift_iso _ _ over.map_id ≪≫ lift_id

@[simp]
theorem map_obj_left (f : X ⟶ Y) [mono f] (g : mono_over X) : ((map f).obj g : C) = g.val.left :=
  rfl

@[simp]
theorem map_obj_arrow (f : X ⟶ Y) [mono f] (g : mono_over X) : ((map f).obj g).arrow = g.arrow ≫ f :=
  rfl

instance full_map (f : X ⟶ Y) [mono f] : full (map f) :=
  { Preimage :=
      fun g h e =>
        by 
          refine' hom_mk e.left _ 
          rw [←cancel_mono f, assoc]
          apply w e }

instance faithful_map (f : X ⟶ Y) [mono f] : faithful (map f) :=
  {  }

/--
Isomorphic objects have equivalent `mono_over` categories.
-/
@[simps]
def map_iso {A B : C} (e : A ≅ B) : mono_over A ≌ mono_over B :=
  { Functor := map e.hom, inverse := map e.inv,
    unitIso :=
      ((map_comp _ _).symm ≪≫
          eq_to_iso
              (by 
                simp ) ≪≫
            map_id).symm,
    counitIso :=
      (map_comp _ _).symm ≪≫
        eq_to_iso
            (by 
              simp ) ≪≫
          map_id }

section 

variable(X)

/-- An equivalence of categories `e` between `C` and `D` induces an equivalence between
    `mono_over X` and `mono_over (e.functor.obj X)` whenever `X` is an object of `C`. -/
@[simps]
def congr (e : C ≌ D) : mono_over X ≌ mono_over (e.functor.obj X) :=
  { Functor :=
      lift (over.post e.functor)$
        fun f =>
          by 
            dsimp 
            infer_instance,
    inverse :=
      (lift (over.post e.inverse)$
          fun f =>
            by 
              dsimp 
              infer_instance) ⋙
        (map_iso (e.unit_iso.symm.app X)).Functor,
    unitIso :=
      nat_iso.of_components
        (fun Y =>
          iso_mk (e.unit_iso.app Y)
            (by 
              tidy))
        (by 
          tidy),
    counitIso :=
      nat_iso.of_components
        (fun Y =>
          iso_mk (e.counit_iso.app Y)
            (by 
              tidy))
        (by 
          tidy) }

end 

section 

variable[has_pullbacks C]

/-- `map f` is left adjoint to `pullback f` when `f` is a monomorphism -/
def map_pullback_adj (f : X ⟶ Y) [mono f] : map f ⊣ pullback f :=
  adjunction.restrict_fully_faithful (forget X) (forget Y) (over.map_pullback_adj f) (iso.refl _) (iso.refl _)

/-- `mono_over.map f` followed by `mono_over.pullback f` is the identity. -/
def pullback_map_self (f : X ⟶ Y) [mono f] : map f ⋙ pullback f ≅ 𝟭 _ :=
  (as_iso (mono_over.map_pullback_adj f).Unit).symm

end 

end Map

section Image

variable(f : X ⟶ Y)[has_image f]

/--
The `mono_over Y` for the image inclusion for a morphism `f : X ⟶ Y`.
-/
def image_mono_over (f : X ⟶ Y) [has_image f] : mono_over Y :=
  mono_over.mk' (image.ι f)

@[simp]
theorem image_mono_over_arrow (f : X ⟶ Y) [has_image f] : (image_mono_over f).arrow = image.ι f :=
  rfl

end Image

section Image

variable[has_images C]

/--
Taking the image of a morphism gives a functor `over X ⥤ mono_over X`.
-/
@[simps]
def image : over X ⥤ mono_over X :=
  { obj := fun f => image_mono_over f.hom,
    map :=
      fun f g k =>
        by 
          apply (forget X).Preimage _ 
          apply over.hom_mk _ _ 
          refine' image.lift { i := image _, m := image.ι g.hom, e := k.left ≫ factor_thru_image g.hom }
          apply image.lift_fac }

/--
`mono_over.image : over X ⥤ mono_over X` is left adjoint to
`mono_over.forget : mono_over X ⥤ over X`
-/
def image_forget_adj : image ⊣ forget X :=
  adjunction.mk_of_hom_equiv
    { homEquiv :=
        fun f g =>
          { toFun :=
              fun k =>
                by 
                  apply over.hom_mk (factor_thru_image f.hom ≫ k.left) _ 
                  change (factor_thru_image f.hom ≫ k.left) ≫ _ = f.hom 
                  rw [assoc, over.w k]
                  apply image.fac,
            invFun :=
              fun k =>
                by 
                  refine' over.hom_mk _ _ 
                  refine' image.lift { i := g.val.left, m := g.arrow, e := k.left, fac' := over.w k }
                  apply image.lift_fac,
            left_inv := fun k => Subsingleton.elimₓ _ _,
            right_inv :=
              fun k =>
                by 
                  ext1 
                  change factor_thru_image _ ≫ image.lift _ = _ 
                  rw [←cancel_mono g.arrow, assoc, image.lift_fac, image.fac f.hom]
                  exact (over.w k).symm } }

instance  : is_right_adjoint (forget X) :=
  { left := image, adj := image_forget_adj }

instance reflective : reflective (forget X) :=
  {  }

/--
Forgetting that a monomorphism over `X` is a monomorphism, then taking its image,
is the identity functor.
-/
def forget_image : forget X ⋙ image ≅ 𝟭 (mono_over X) :=
  as_iso (adjunction.counit image_forget_adj)

end Image

section Exists

variable[has_images C]

/--
In the case where `f` is not a monomorphism but `C` has images,
we can still take the "forward map" under it, which agrees with `mono_over.map f`.
-/
def exists (f : X ⟶ Y) : mono_over X ⥤ mono_over Y :=
  forget _ ⋙ over.map f ⋙ image

instance faithful_exists (f : X ⟶ Y) : faithful (exists f) :=
  {  }

/--
When `f : X ⟶ Y` is a monomorphism, `exists f` agrees with `map f`.
-/
def exists_iso_map (f : X ⟶ Y) [mono f] : exists f ≅ map f :=
  nat_iso.of_components
    (by 
      intro Z 
      suffices  : (forget _).obj ((exists f).obj Z) ≅ (forget _).obj ((map f).obj Z)
      apply preimage_iso this 
      apply over.iso_mk _ _ 
      apply image_mono_iso_source (Z.arrow ≫ f)
      apply image_mono_iso_source_hom_self)
    (by 
      intro Z₁ Z₂ g 
      ext1 
      change
        image.lift ⟨_, _, _, _⟩ ≫ (image_mono_iso_source (Z₂.arrow ≫ f)).Hom =
          (image_mono_iso_source (Z₁.arrow ≫ f)).Hom ≫ g.left 
      rw [←cancel_mono (Z₂.arrow ≫ f), assoc, assoc, w_assoc g, image_mono_iso_source_hom_self,
        image_mono_iso_source_hom_self]
      apply image.lift_fac)

/-- `exists` is adjoint to `pullback` when images exist -/
def exists_pullback_adj (f : X ⟶ Y) [has_pullbacks C] : exists f ⊣ pullback f :=
  adjunction.restrict_fully_faithful (forget X) (𝟭 _) ((over.map_pullback_adj f).comp _ _ image_forget_adj) (iso.refl _)
    (iso.refl _)

end Exists

end MonoOver

end CategoryTheory

