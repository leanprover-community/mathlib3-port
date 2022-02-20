/-
Copyright (c) 2020 Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta, Scott Morrison
-/
import Mathbin.CategoryTheory.Limits.Shapes.Equalizers
import Mathbin.CategoryTheory.Limits.Shapes.FiniteProducts
import Mathbin.CategoryTheory.Limits.Preserves.Shapes.Products
import Mathbin.CategoryTheory.Limits.Preserves.Shapes.Equalizers
import Mathbin.CategoryTheory.Limits.Preserves.Finite

/-!
# Constructing limits from products and equalizers.

If a category has all products, and all equalizers, then it has all limits.
Similarly, if it has all finite products, and all equalizers, then it has all finite limits.

If a functor preserves all products and equalizers, then it preserves all limits.
Similarly, if it preserves all finite products and equalizers, then it preserves all finite limits.

# TODO

Provide the dual results.
Show the analogous results for functors which reflect or create (co)limits.
-/


open CategoryTheory

open Opposite

namespace CategoryTheory.Limits

universe v u u₂

variable {C : Type u} [Category.{v} C]

variable {J : Type v} [SmallCategory J]

-- We hide the "implementation details" inside a namespace
namespace HasLimitOfHasProductsOfHasEqualizers

variable {F : J ⥤ C} {c₁ : Fan F.obj} {c₂ : Fan fun f : Σ p : J × J, p.1 ⟶ p.2 => F.obj f.1.2} (s t : c₁.x ⟶ c₂.x)
  (hs : ∀ f : Σ p : J × J, p.1 ⟶ p.2, s ≫ c₂.π.app f = c₁.π.app f.1.1 ≫ F.map f.2)
  (ht : ∀ f : Σ p : J × J, p.1 ⟶ p.2, t ≫ c₂.π.app f = c₁.π.app f.1.2) (i : Fork s t)

include hs ht

/-- (Implementation) Given the appropriate product and equalizer cones, build the cone for `F` which is
limiting if the given cones are also.
-/
@[simps]
def buildLimit : Cone F where
  x := i.x
  π :=
    { app := fun j => i.ι ≫ c₁.π.app _,
      naturality' := fun j₁ j₂ f => by
        dsimp
        rw [category.id_comp, category.assoc, ← hs ⟨⟨_, _⟩, f⟩, i.condition_assoc, ht] }

variable {i}

/-- (Implementation) Show the cone constructed in `build_limit` is limiting, provided the cones used in
its construction are.
-/
def buildIsLimit (t₁ : IsLimit c₁) (t₂ : IsLimit c₂) (hi : IsLimit i) : IsLimit (buildLimit s t hs ht i) where
  lift := fun q => by
    refine' hi.lift (fork.of_ι _ _)
    · refine' t₁.lift (fan.mk _ fun j => _)
      apply q.π.app j
      
    · apply t₂.hom_ext
      simp [hs, ht]
      
  uniq' := fun q m w =>
    hi.hom_ext
      (i.equalizer_ext
        (t₁.hom_ext
          (by
            simpa using w)))

end HasLimitOfHasProductsOfHasEqualizers

open HasLimitOfHasProductsOfHasEqualizers

/-- Given the existence of the appropriate (possibly finite) products and equalizers, we know a limit of
`F` exists.
(This assumes the existence of all equalizers, which is technically stronger than needed.)
-/
theorem has_limit_of_equalizer_and_product (F : J ⥤ C) [HasLimit (Discrete.functor F.obj)]
    [HasLimit (Discrete.functor fun f : Σ p : J × J, p.1 ⟶ p.2 => F.obj f.1.2)] [HasEqualizers C] : HasLimit F :=
  HasLimit.mk
    { Cone := _,
      IsLimit :=
        buildIsLimit (Pi.lift fun f => limit.π _ _ ≫ F.map f.2) (Pi.lift fun f => limit.π _ f.1.2)
          (by
            simp )
          (by
            simp )
          (limit.isLimit _) (limit.isLimit _) (limit.isLimit _) }

/-- Any category with products and equalizers has all limits.

See https://stacks.math.columbia.edu/tag/002N.
-/
theorem limits_from_equalizers_and_products [HasProducts C] [HasEqualizers C] : HasLimits C :=
  { HasLimitsOfShape := fun J 𝒥 => { HasLimit := fun F => has_limit_of_equalizer_and_product F } }

/-- Any category with finite products and equalizers has all finite limits.

See https://stacks.math.columbia.edu/tag/002O.
-/
theorem finite_limits_from_equalizers_and_finite_products [HasFiniteProducts C] [HasEqualizers C] : HasFiniteLimits C :=
  ⟨fun J _ _ => { HasLimit := fun F => has_limit_of_equalizer_and_product F }⟩

variable {D : Type u₂} [Category.{v} D]

noncomputable section

section

variable [HasLimitsOfShape (Discrete.{v} J) C] [HasLimitsOfShape (Discrete.{v} (Σ p : J × J, p.1 ⟶ p.2)) C]
  [HasEqualizers C]

variable (G : C ⥤ D) [PreservesLimitsOfShape WalkingParallelPair.{v} G] [PreservesLimitsOfShape (Discrete.{v} J) G]
  [PreservesLimitsOfShape (Discrete.{v} (Σ p : J × J, p.1 ⟶ p.2)) G]

/-- If a functor preserves equalizers and the appropriate products, it preserves limits. -/
def preservesLimitOfPreservesEqualizersAndProduct : PreservesLimitsOfShape J G where
  PreservesLimit := fun K => by
    let P := ∏ K.obj
    let Q := ∏ fun f : Σ p : J × J, p.fst ⟶ p.snd => K.obj f.1.2
    let s : P ⟶ Q := pi.lift fun f => limit.π _ _ ≫ K.map f.2
    let t : P ⟶ Q := pi.lift fun f => limit.π _ f.1.2
    let I := equalizer s t
    let i : I ⟶ P := equalizer.ι s t
    apply
      preserves_limit_of_preserves_limit_cone
        (build_is_limit s t
          (by
            simp )
          (by
            simp )
          (limit.is_limit _) (limit.is_limit _) (limit.is_limit _))
    refine' is_limit.of_iso_limit (build_is_limit _ _ _ _ _ _ _) _
    · exact fan.mk _ fun j => G.map (pi.π _ j)
      
    · exact fan.mk (G.obj Q) fun f => G.map (pi.π _ f)
      
    · apply G.map s
      
    · apply G.map t
      
    · intro f
      dsimp
      simp only [← G.map_comp, limit.lift_π, fan.mk_π_app]
      
    · intro f
      dsimp
      simp only [← G.map_comp, limit.lift_π, fan.mk_π_app]
      
    · apply fork.of_ι (G.map i) _
      simp only [← G.map_comp, equalizer.condition]
      
    · apply is_limit_of_has_product_of_preserves_limit
      
    · apply is_limit_of_has_product_of_preserves_limit
      
    · apply is_limit_fork_map_of_is_limit
      apply equalizer_is_equalizer
      
    refine' cones.ext (iso.refl _) _
    intro j
    dsimp
    simp

-- See note [dsimp, simp].
end

/-- If G preserves equalizers and finite products, it preserves finite limits. -/
def preservesFiniteLimitsOfPreservesEqualizersAndFiniteProducts [HasEqualizers C] [HasFiniteProducts C] (G : C ⥤ D)
    [PreservesLimitsOfShape WalkingParallelPair.{v} G] [∀ J [Fintype J], PreservesLimitsOfShape (Discrete.{v} J) G] :
    PreservesFiniteLimits G :=
  ⟨fun _ _ _ => preserves_limit_of_preserves_equalizers_and_product G⟩

/-- If G preserves equalizers and products, it preserves all limits. -/
def preservesLimitsOfPreservesEqualizersAndProducts [HasEqualizers C] [HasProducts C] (G : C ⥤ D)
    [PreservesLimitsOfShape WalkingParallelPair.{v} G] [∀ J, PreservesLimitsOfShape (Discrete.{v} J) G] :
    PreservesLimits G where
  PreservesLimitsOfShape := fun J 𝒥 => preserves_limit_of_preserves_equalizers_and_product G

/-!
We now dualize the above constructions, resorting to copy-paste.
-/


-- We hide the "implementation details" inside a namespace
namespace HasColimitOfHasCoproductsOfHasCoequalizers

variable {F : J ⥤ C} {c₁ : Cofan fun f : Σ p : J × J, p.1 ⟶ p.2 => F.obj f.1.1} {c₂ : Cofan F.obj} (s t : c₁.x ⟶ c₂.x)
  (hs : ∀ f : Σ p : J × J, p.1 ⟶ p.2, c₁.ι.app f ≫ s = F.map f.2 ≫ c₂.ι.app f.1.2)
  (ht : ∀ f : Σ p : J × J, p.1 ⟶ p.2, c₁.ι.app f ≫ t = c₂.ι.app f.1.1) (i : Cofork s t)

include hs ht

/-- (Implementation) Given the appropriate coproduct and coequalizer cocones,
build the cocone for `F` which is colimiting if the given cocones are also.
-/
@[simps]
def buildColimit : Cocone F where
  x := i.x
  ι :=
    { app := fun j => c₂.ι.app _ ≫ i.π,
      naturality' := fun j₁ j₂ f => by
        dsimp
        rw [category.comp_id, ← reassoc_of (hs ⟨⟨_, _⟩, f⟩), i.condition, ← category.assoc, ht] }

variable {i}

/-- (Implementation) Show the cocone constructed in `build_colimit` is colimiting,
provided the cocones used in its construction are.
-/
def buildIsColimit (t₁ : IsColimit c₁) (t₂ : IsColimit c₂) (hi : IsColimit i) :
    IsColimit (buildColimit s t hs ht i) where
  desc := fun q => by
    refine' hi.desc (cofork.of_π _ _)
    · refine' t₂.desc (cofan.mk _ fun j => _)
      apply q.ι.app j
      
    · apply t₁.hom_ext
      simp [reassoc_of hs, reassoc_of ht]
      
  uniq' := fun q m w =>
    hi.hom_ext
      (i.coequalizer_ext
        (t₂.hom_ext
          (by
            simpa using w)))

end HasColimitOfHasCoproductsOfHasCoequalizers

open HasColimitOfHasCoproductsOfHasCoequalizers

/-- Given the existence of the appropriate (possibly finite) coproducts and coequalizers,
we know a colimit of `F` exists.
(This assumes the existence of all coequalizers, which is technically stronger than needed.)
-/
theorem has_colimit_of_coequalizer_and_coproduct (F : J ⥤ C) [HasColimit (Discrete.functor F.obj)]
    [HasColimit (Discrete.functor fun f : Σ p : J × J, p.1 ⟶ p.2 => F.obj f.1.1)] [HasCoequalizers C] : HasColimit F :=
  HasColimit.mk
    { Cocone := _,
      IsColimit :=
        buildIsColimit (Sigma.desc fun f => F.map f.2 ≫ colimit.ι (Discrete.functor F.obj) f.1.2)
          (Sigma.desc fun f => colimit.ι (Discrete.functor F.obj) f.1.1)
          (by
            simp )
          (by
            simp )
          (colimit.isColimit _) (colimit.isColimit _) (colimit.isColimit _) }

/-- Any category with coproducts and coequalizers has all colimits.

See https://stacks.math.columbia.edu/tag/002P.
-/
theorem colimits_from_coequalizers_and_coproducts [HasCoproducts C] [HasCoequalizers C] : HasColimits C :=
  { HasColimitsOfShape := fun J 𝒥 => { HasColimit := fun F => has_colimit_of_coequalizer_and_coproduct F } }

/-- Any category with finite coproducts and coequalizers has all finite colimits.

See https://stacks.math.columbia.edu/tag/002Q.
-/
theorem finite_colimits_from_coequalizers_and_finite_coproducts [HasFiniteCoproducts C] [HasCoequalizers C] :
    HasFiniteColimits C :=
  ⟨fun J _ _ => { HasColimit := fun F => has_colimit_of_coequalizer_and_coproduct F }⟩

noncomputable section

section

variable [HasColimitsOfShape (Discrete.{v} J) C] [HasColimitsOfShape (Discrete.{v} (Σ p : J × J, p.1 ⟶ p.2)) C]
  [HasCoequalizers C]

variable (G : C ⥤ D) [PreservesColimitsOfShape WalkingParallelPair.{v} G] [PreservesColimitsOfShape (Discrete.{v} J) G]
  [PreservesColimitsOfShape (Discrete.{v} (Σ p : J × J, p.1 ⟶ p.2)) G]

/-- If a functor preserves coequalizers and the appropriate coproducts, it preserves colimits. -/
def preservesColimitOfPreservesCoequalizersAndCoproduct : PreservesColimitsOfShape J G where
  PreservesColimit := fun K => by
    let P := ∐ K.obj
    let Q := ∐ fun f : Σ p : J × J, p.fst ⟶ p.snd => K.obj f.1.1
    let s : Q ⟶ P := sigma.desc fun f => K.map f.2 ≫ colimit.ι (discrete.functor K.obj) _
    let t : Q ⟶ P := sigma.desc fun f => colimit.ι (discrete.functor K.obj) f.1.1
    let I := coequalizer s t
    let i : P ⟶ I := coequalizer.π s t
    apply
      preserves_colimit_of_preserves_colimit_cocone
        (build_is_colimit s t
          (by
            simp )
          (by
            simp )
          (colimit.is_colimit _) (colimit.is_colimit _) (colimit.is_colimit _))
    refine' is_colimit.of_iso_colimit (build_is_colimit _ _ _ _ _ _ _) _
    · exact cofan.mk (G.obj Q) fun j => G.map (sigma.ι _ j)
      
    · exact cofan.mk _ fun f => G.map (sigma.ι _ f)
      
    · apply G.map s
      
    · apply G.map t
      
    · intro f
      dsimp
      simp only [← G.map_comp, colimit.ι_desc, cofan.mk_ι_app]
      
    · intro f
      dsimp
      simp only [← G.map_comp, colimit.ι_desc, cofan.mk_ι_app]
      
    · apply cofork.of_π (G.map i) _
      simp only [← G.map_comp, coequalizer.condition]
      
    · apply is_colimit_of_has_coproduct_of_preserves_colimit
      
    · apply is_colimit_of_has_coproduct_of_preserves_colimit
      
    · apply is_colimit_cofork_map_of_is_colimit
      apply coequalizer_is_coequalizer
      
    refine' cocones.ext (iso.refl _) _
    intro j
    dsimp
    simp

-- See note [dsimp, simp].
end

/-- If G preserves coequalizers and finite coproducts, it preserves finite colimits. -/
def preservesFiniteColimitsOfPreservesCoequalizersAndFiniteCoproducts [HasCoequalizers C] [HasFiniteCoproducts C]
    (G : C ⥤ D) [PreservesColimitsOfShape WalkingParallelPair.{v} G]
    [∀ J [Fintype J], PreservesColimitsOfShape (Discrete.{v} J) G] : PreservesFiniteColimits G :=
  ⟨fun _ _ _ => preserves_colimit_of_preserves_coequalizers_and_coproduct G⟩

/-- If G preserves coequalizers and coproducts, it preserves all colimits. -/
def preservesColimitsOfPreservesCoequalizersAndCoproducts [HasCoequalizers C] [HasCoproducts C] (G : C ⥤ D)
    [PreservesColimitsOfShape WalkingParallelPair.{v} G] [∀ J, PreservesColimitsOfShape (Discrete.{v} J) G] :
    PreservesColimits G where
  PreservesColimitsOfShape := fun J 𝒥 => preserves_colimit_of_preserves_coequalizers_and_coproduct G

end CategoryTheory.Limits

