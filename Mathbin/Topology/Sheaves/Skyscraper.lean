/-
Copyright (c) 2022 Jujian Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jujian Zhang, Junyan Xu
-/
import Mathbin.AlgebraicGeometry.SheafedSpace
import Mathbin.Topology.Sheaves.Punit
import Mathbin.Topology.Sheaves.Stalks
import Mathbin.CategoryTheory.Preadditive.Injective

/-!
# Skyscraper (pre)sheaves

A skyscraper (pre)sheaf `𝓕 : (pre)sheaf C X` is the (pre)sheaf with value `A` at point `p₀` that is
supported only at open sets contain `p₀`, i.e. `𝓕(U) = A` if `p₀ ∈ U` and `𝓕(U) = *` if `p₀ ∉ U`
where `*` is a terminal object of `C`. In terms of stalks, `𝓕` is supported at all specializations
of `p₀`, i.e. if `p₀ ⤳ x` then `𝓕ₓ ≅ A` and if `¬ p₀ ⤳ x` then `𝓕ₓ ≅ *`.

## Main definitions

* `skyscraper_presheaf`: `skyscraper_presheaf p₀ A` is the skyscraper presheaf at point `p₀` with
  value `A`.
* `skyscraper_sheaf`: the skyscraper presheaf satisfies the sheaf condition.

## Main statements

* `skyscraper_presheaf_stalk_of_specializes`: if `y ∈ closure {p₀}` then the stalk of
  `skyscraper_presheaf p₀ A` at `y` is `A`.
* `skyscraper_presheaf_stalk_of_not_specializes`: if `y ∉ closure {p₀}` then the stalk of
  `skyscraper_presheaf p₀ A` at `y` is `*` the terminal object.

TODO: generalize universe level when calculating stalks, after generalizing universe level of stalk.
-/


noncomputable section

open TopologicalSpace Top CategoryTheory CategoryTheory.Limits Opposite

universe u v w

variable {X : Top.{u}} (p₀ : X) [∀ U : Opens X, Decidable (p₀ ∈ U)]

section

variable {C : Type v} [Category.{w} C] [HasTerminal C] (A : C)

/-- A skyscraper presheaf is a presheaf supported at a single point: if `p₀ ∈ X` is a specified
point, then the skyscraper presheaf `𝓕` with value `A` is defined by `U ↦ A` if `p₀ ∈ U` and
`U ↦ *` if `p₀ ∉ A` where `*` is some terminal object.
-/
@[simps]
def skyscraperPresheaf : Presheaf C X where
  obj := fun U => if p₀ ∈ unop U then A else terminal C
  map := fun U V i =>
    if h : p₀ ∈ unop V then eq_to_hom <| by erw [if_pos h, if_pos (le_of_hom i.unop h)]
    else ((if_neg h).symm.rec terminalIsTerminal).from _
  map_id' := fun U =>
    (em (p₀ ∈ U.unop)).elim (fun h => dif_pos h) fun h => ((if_neg h).symm.rec terminalIsTerminal).hom_ext _ _
  map_comp' := fun U V W iVU iWV => by
    by_cases hW:p₀ ∈ unop W
    · have hV : p₀ ∈ unop V := le_of_hom iWV.unop hW
      simp only [dif_pos hW, dif_pos hV, eq_to_hom_trans]
      
    · rw [dif_neg hW]
      apply ((if_neg hW).symm.rec terminal_is_terminal).hom_ext
      

theorem skyscraper_presheaf_eq_pushforward [hd : ∀ U : Opens (Top.of PUnit.{u + 1}), Decidable (PUnit.unit ∈ U)] :
    skyscraperPresheaf p₀ A = ContinuousMap.const (Top.of PUnit) p₀ _* skyscraperPresheaf PUnit.unit A := by
  convert_to @skyscraperPresheaf X p₀ (fun U => hd <| (opens.map <| ContinuousMap.const _ p₀).obj U) C _ _ A = _ <;>
    first |congr |rfl

/-- Taking skyscraper presheaf at a point is functorial: `c ↦ skyscraper p₀ c` defines a functor by
sending every `f : a ⟶ b` to the natural transformation `α` defined as: `α(U) = f : a ⟶ b` if
`p₀ ∈ U` and the unique morphism to a terminal object in `C` if `p₀ ∉ U`.
-/
@[simps]
def SkyscraperPresheafFunctor.map' {a b : C} (f : a ⟶ b) : skyscraperPresheaf p₀ a ⟶ skyscraperPresheaf p₀ b where
  app := fun U =>
    if h : p₀ ∈ U.unop then eqToHom (if_pos h) ≫ f ≫ eqToHom (if_pos h).symm
    else ((if_neg h).symm.rec terminalIsTerminal).from _
  naturality' := fun U V i => by
    simp only [skyscraper_presheaf_map]
    by_cases hV:p₀ ∈ V.unop
    · have hU : p₀ ∈ U.unop := le_of_hom i.unop hV
      split_ifs
      simpa only [eq_to_hom_trans_assoc, category.assoc, eq_to_hom_trans]
      
    · apply ((if_neg hV).symm.rec terminal_is_terminal).hom_ext
      

theorem SkyscraperPresheafFunctor.map'_id {a : C} : SkyscraperPresheafFunctor.map' p₀ (𝟙 a) = 𝟙 _ := by
  ext1
  ext1
  simp only [SkyscraperPresheafFunctor.map'_app, nat_trans.id_app]
  split_ifs
  · simp only [category.id_comp, category.comp_id, eq_to_hom_trans, eq_to_hom_refl]
    
  · apply ((if_neg h).symm.rec terminal_is_terminal).hom_ext
    

theorem SkyscraperPresheafFunctor.map'_comp {a b c : C} (f : a ⟶ b) (g : b ⟶ c) :
    SkyscraperPresheafFunctor.map' p₀ (f ≫ g) =
      SkyscraperPresheafFunctor.map' p₀ f ≫ SkyscraperPresheafFunctor.map' p₀ g :=
  by
  ext1
  ext1
  simp only [SkyscraperPresheafFunctor.map'_app, nat_trans.comp_app]
  split_ifs
  · simp only [category.assoc, eq_to_hom_trans_assoc, eq_to_hom_refl, category.id_comp]
    
  · apply ((if_neg h).symm.rec terminal_is_terminal).hom_ext
    

/-- Taking skyscraper presheaf at a point is functorial: `c ↦ skyscraper p₀ c` defines a functor by
sending every `f : a ⟶ b` to the natural transformation `α` defined as: `α(U) = f : a ⟶ b` if
`p₀ ∈ U` and the unique morphism to a terminal object in `C` if `p₀ ∉ U`.
-/
@[simps]
def skyscraperPresheafFunctor : C ⥤ Presheaf C X where
  obj := skyscraperPresheaf p₀
  map := fun _ _ => SkyscraperPresheafFunctor.map' p₀
  map_id' := fun _ => SkyscraperPresheafFunctor.map'_id p₀
  map_comp' := fun _ _ _ => SkyscraperPresheafFunctor.map'_comp p₀

end

section

-- In this section, we calculate the stalks for skyscraper presheaves.
-- We need to restrict universe level.
variable {C : Type v} [Category.{u} C] (A : C) [HasTerminal C]

/-- The cocone at `A` for the stalk functor of `skyscraper_presheaf p₀ A` when `y ∈ closure {p₀}`
-/
@[simps]
def skyscraperPresheafCoconeOfSpecializes {y : X} (h : p₀ ⤳ y) :
    Cocone ((OpenNhds.inclusion y).op ⋙ skyscraperPresheaf p₀ A) where
  x := A
  ι :=
    { app := fun U => eq_to_hom <| if_pos <| h.mem_open U.unop.1.2 U.unop.2,
      naturality' := fun U V inc => by
        change dite _ _ _ ≫ _ = _
        rw [dif_pos]
        · erw [category.comp_id, eq_to_hom_trans]
          rfl
          
        · exact h.mem_open V.unop.1.2 V.unop.2
           }

/-- The cocone at `A` for the stalk functor of `skyscraper_presheaf p₀ A` when `y ∈ closure {p₀}` is a
colimit
-/
noncomputable def skyscraperPresheafCoconeIsColimitOfSpecializes {y : X} (h : p₀ ⤳ y) :
    IsColimit (skyscraperPresheafCoconeOfSpecializes p₀ A h) where
  desc := fun c => eqToHom (if_pos trivialₓ).symm ≫ c.ι.app (op ⊤)
  fac' := fun c U => by
    rw [← c.w (hom_of_le <| (le_top : unop U ≤ _)).op]
    change _ ≫ _ ≫ dite _ _ _ ≫ _ = _
    rw [dif_pos]
    · simpa only [skyscraper_presheaf_cocone_of_specializes_ι_app, eq_to_hom_trans_assoc, eq_to_hom_refl,
        category.id_comp]
      
    · exact h.mem_open U.unop.1.2 U.unop.2
      
  uniq' := fun c f h => by
    rw [← h, skyscraper_presheaf_cocone_of_specializes_ι_app, eq_to_hom_trans_assoc, eq_to_hom_refl, category.id_comp]

/-- If `y ∈ closure {p₀}`, then the stalk of `skyscraper_presheaf p₀ A` at `y` is `A`.
-/
noncomputable def skyscraperPresheafStalkOfSpecializes [HasColimits C] {y : X} (h : p₀ ⤳ y) :
    (skyscraperPresheaf p₀ A).stalk y ≅ A :=
  colimit.isoColimitCocone ⟨_, skyscraperPresheafCoconeIsColimitOfSpecializes p₀ A h⟩

/-- The cocone at `*` for the stalk functor of `skyscraper_presheaf p₀ A` when `y ∉ closure {p₀}`
-/
@[simps]
def skyscraperPresheafCocone (y : X) : Cocone ((OpenNhds.inclusion y).op ⋙ skyscraperPresheaf p₀ A) where
  x := terminal C
  ι := { app := fun U => terminal.from _, naturality' := fun U V inc => terminalIsTerminal.hom_ext _ _ }

/-- The cocone at `*` for the stalk functor of `skyscraper_presheaf p₀ A` when `y ∉ closure {p₀}` is a
colimit
-/
noncomputable def skyscraperPresheafCoconeIsColimitOfNotSpecializes {y : X} (h : ¬p₀ ⤳ y) :
    IsColimit (skyscraperPresheafCocone p₀ A y) :=
  let h1 : ∃ U : OpenNhds y, p₀ ∉ U.1 :=
    let ⟨U, ho, h₀, hy⟩ := not_specializes_iff_exists_open.mp h
    ⟨⟨⟨U, ho⟩, h₀⟩, hy⟩
  { desc := fun c => eqToHom (if_neg h1.some_spec).symm ≫ c.ι.app (op h1.some),
    fac' := fun c U => by
      change _ = c.ι.app (op U.unop)
      simp only [← c.w (hom_of_le <| @inf_le_left _ _ h1.some U.unop).op, ←
        c.w (hom_of_le <| @inf_le_right _ _ h1.some U.unop).op, ← category.assoc]
      congr 1
      refine' ((if_neg _).symm.rec terminal_is_terminal).hom_ext _ _
      exact fun h => h1.some_spec h.1,
    uniq' := fun c f H => by
      rw [← category.id_comp f, ← H, ← category.assoc]
      congr 1
      apply terminal_is_terminal.hom_ext }

/-- If `y ∉ closure {p₀}`, then the stalk of `skyscraper_presheaf p₀ A` at `y` is isomorphic to a
terminal object.
-/
noncomputable def skyscraperPresheafStalkOfNotSpecializes [HasColimits C] {y : X} (h : ¬p₀ ⤳ y) :
    (skyscraperPresheaf p₀ A).stalk y ≅ terminal C :=
  colimit.isoColimitCocone ⟨_, skyscraperPresheafCoconeIsColimitOfNotSpecializes _ A h⟩

/-- If `y ∉ closure {p₀}`, then the stalk of `skyscraper_presheaf p₀ A` at `y` is a terminal object
-/
def skyscraperPresheafStalkOfNotSpecializesIsTerminal [HasColimits C] {y : X} (h : ¬p₀ ⤳ y) :
    IsTerminal ((skyscraperPresheaf p₀ A).stalk y) :=
  IsTerminal.ofIso terminalIsTerminal <| (skyscraperPresheafStalkOfNotSpecializes _ _ h).symm

theorem skyscraper_presheaf_is_sheaf [HasProducts.{u} C] : (skyscraperPresheaf p₀ A).IsSheaf := by
  classical <;>
    exact
      (presheaf.is_sheaf_iso_iff (eq_to_iso <| skyscraper_presheaf_eq_pushforward p₀ A)).mpr
        (sheaf.pushforward_sheaf_of_sheaf _
          (presheaf.is_sheaf_on_punit_of_is_terminal _
            (by
              dsimp
              rw [if_neg]
              exact terminal_is_terminal
              exact Set.not_mem_empty PUnit.unit)))

/-- The skyscraper presheaf supported at `p₀` with value `A` is the sheaf that assigns `A` to all opens
`U` that contain `p₀` and assigns `*` otherwise.
-/
def skyscraperSheaf [HasProducts.{u} C] : Sheaf C X :=
  ⟨skyscraperPresheaf p₀ A, skyscraper_presheaf_is_sheaf _ _⟩

/-- Taking skyscraper sheaf at a point is functorial: `c ↦ skyscraper p₀ c` defines a functor by
sending every `f : a ⟶ b` to the natural transformation `α` defined as: `α(U) = f : a ⟶ b` if
`p₀ ∈ U` and the unique morphism to a terminal object in `C` if `p₀ ∉ U`.
-/
def skyscraperSheafFunctor [HasProducts.{u} C] : C ⥤ Sheaf C X where
  obj := fun c => skyscraperSheaf p₀ c
  map := fun a b f => Sheaf.hom.mk <| (skyscraperPresheafFunctor p₀).map f
  map_id' := fun c => Sheaf.Hom.ext _ _ <| (skyscraperPresheafFunctor p₀).map_id _
  map_comp' := fun _ _ _ f g => Sheaf.Hom.ext _ _ <| (skyscraperPresheafFunctor p₀).map_comp _ _

namespace StalkSkyscraperPresheafAdjunctionAuxs

variable [HasColimits C]

/-- If `f : 𝓕.stalk p₀ ⟶ c`, then a natural transformation `𝓕 ⟶ skyscraper_presheaf p₀ c` can be
defined by: `𝓕.germ p₀ ≫ f : 𝓕(U) ⟶ c` if `p₀ ∈ U` and the unique morphism to a terminal object
if `p₀ ∉ U`.
-/
@[simps]
def toSkyscraperPresheaf {𝓕 : Presheaf C X} {c : C} (f : 𝓕.stalk p₀ ⟶ c) : 𝓕 ⟶ skyscraperPresheaf p₀ c where
  app := fun U =>
    if h : p₀ ∈ U.unop then 𝓕.germ ⟨p₀, h⟩ ≫ f ≫ eqToHom (if_pos h).symm
    else ((if_neg h).symm.rec terminalIsTerminal).from _
  naturality' := fun U V inc => by
    dsimp
    by_cases hV:p₀ ∈ V.unop
    · have hU : p₀ ∈ U.unop := le_of_hom inc.unop hV
      split_ifs
      erw [← category.assoc, 𝓕.germ_res inc.unop, category.assoc, category.assoc, eq_to_hom_trans]
      rfl
      
    · split_ifs
      apply ((if_neg hV).symm.rec terminal_is_terminal).hom_ext
      

/-- If `f : 𝓕 ⟶ skyscraper_presheaf p₀ c` is a natural transformation, then there is a morphism
`𝓕.stalk p₀ ⟶ c` defined as the morphism from colimit to cocone at `c`.
-/
def fromStalk {𝓕 : Presheaf C X} {c : C} (f : 𝓕 ⟶ skyscraperPresheaf p₀ c) : 𝓕.stalk p₀ ⟶ c :=
  let χ : Cocone ((OpenNhds.inclusion p₀).op ⋙ 𝓕) :=
    Cocone.mk c <|
      { app := fun U => f.app (op U.unop.1) ≫ eqToHom (if_pos U.unop.2),
        naturality' := fun U V inc => by
          dsimp
          erw [category.comp_id, ← category.assoc, comp_eq_to_hom_iff, category.assoc, eq_to_hom_trans, f.naturality,
            skyscraper_presheaf_map]
          have hV : p₀ ∈ (open_nhds.inclusion p₀).obj V.unop := V.unop.2
          split_ifs
          simpa only [comp_eq_to_hom_iff, category.assoc, eq_to_hom_trans, eq_to_hom_refl, category.comp_id] }
  colimit.desc _ χ

theorem to_skyscraper_from_stalk {𝓕 : Presheaf C X} {c : C} (f : 𝓕 ⟶ skyscraperPresheaf p₀ c) :
    toSkyscraperPresheaf p₀ (fromStalk _ f) = f :=
  NatTrans.ext _ _ <|
    funext fun U =>
      ((em (p₀ ∈ U.unop)).elim fun h => by
          dsimp
          split_ifs
          erw [← category.assoc, colimit.ι_desc, category.assoc, eq_to_hom_trans, eq_to_hom_refl, category.comp_id]
          rfl)
        fun h => by
        dsimp
        split_ifs
        apply ((if_neg h).symm.rec terminal_is_terminal).hom_ext

theorem from_stalk_to_skyscraper {𝓕 : Presheaf C X} {c : C} (f : 𝓕.stalk p₀ ⟶ c) :
    fromStalk p₀ (toSkyscraperPresheaf _ f) = f :=
  colimit.hom_ext fun U => by
    erw [colimit.ι_desc]
    dsimp
    rw [dif_pos U.unop.2]
    rw [category.assoc, category.assoc, eq_to_hom_trans, eq_to_hom_refl, category.comp_id, presheaf.germ]
    congr 3
    apply_fun Opposite.unop using unop_injective
    rw [unop_op]
    ext
    rfl

/-- The unit in `presheaf.stalk ⊣ skyscraper_presheaf_functor`
-/
@[simps]
protected def unit : 𝟭 (Presheaf C X) ⟶ Presheaf.stalkFunctor C p₀ ⋙ skyscraperPresheafFunctor p₀ where
  app := fun 𝓕 => toSkyscraperPresheaf _ <| 𝟙 _
  naturality' := fun 𝓕 𝓖 f => by
    ext U
    dsimp
    split_ifs
    · simp only [category.id_comp, ← category.assoc]
      rw [comp_eq_to_hom_iff]
      simp only [category.assoc, eq_to_hom_trans, eq_to_hom_refl, category.comp_id]
      erw [colimit.ι_map]
      rfl
      
    · apply ((if_neg h).symm.rec terminal_is_terminal).hom_ext
      

/-- The counit in `presheaf.stalk ⊣ skyscraper_presheaf_functor`
-/
@[simps]
protected def counit : skyscraperPresheafFunctor p₀ ⋙ (Presheaf.stalkFunctor C p₀ : Presheaf C X ⥤ C) ⟶ 𝟭 C where
  app := fun c => (skyscraperPresheafStalkOfSpecializes p₀ c specializes_rfl).Hom
  naturality' := fun x y f =>
    colimit.hom_ext fun U => by
      erw [← category.assoc, colimit.ι_map, colimit.iso_colimit_cocone_ι_hom_assoc,
        skyscraper_presheaf_cocone_of_specializes_ι_app, category.assoc, colimit.ι_desc, whiskering_left_obj_map,
        whisker_left_app, SkyscraperPresheafFunctor.map'_app, dif_pos U.unop.2,
        skyscraper_presheaf_cocone_of_specializes_ι_app, comp_eq_to_hom_iff, category.assoc, eq_to_hom_comp_iff, ←
        category.assoc, eq_to_hom_trans, eq_to_hom_refl, category.id_comp, comp_eq_to_hom_iff, category.assoc,
        eq_to_hom_trans, eq_to_hom_refl, category.comp_id, CategoryTheory.Functor.id_map]

end StalkSkyscraperPresheafAdjunctionAuxs

section

open StalkSkyscraperPresheafAdjunctionAuxs

/-- `skyscraper_presheaf_functor` is the right adjoint of `presheaf.stalk_functor`
-/
def skyscraperPresheafStalkAdjunction [HasColimits C] :
    (Presheaf.stalkFunctor C p₀ : Presheaf C X ⥤ C) ⊣ skyscraperPresheafFunctor p₀ where
  homEquiv := fun c 𝓕 =>
    { toFun := toSkyscraperPresheaf _, invFun := fromStalk _, left_inv := from_stalk_to_skyscraper _,
      right_inv := to_skyscraper_from_stalk _ }
  Unit := StalkSkyscraperPresheafAdjunctionAuxs.unit _
  counit := StalkSkyscraperPresheafAdjunctionAuxs.counit _
  hom_equiv_unit' := fun 𝓕 c α => by
    ext U
    simp only [Equivₓ.coe_fn_mk, to_skyscraper_presheaf_app, nat_trans.comp_app, SkyscraperPresheafFunctor.map'_app,
      skyscraper_presheaf_functor_map, unit_app]
    split_ifs
    · erw [category.id_comp, ← category.assoc, comp_eq_to_hom_iff, category.assoc, category.assoc, category.assoc,
        category.assoc, eq_to_hom_trans, eq_to_hom_refl, category.comp_id, ← category.assoc _ _ α, eq_to_hom_trans,
        eq_to_hom_refl, category.id_comp]
      
    · apply ((if_neg h).symm.rec terminal_is_terminal).hom_ext
      
  hom_equiv_counit' := fun 𝓕 c α => by
    ext U
    simp only [Equivₓ.coe_fn_symm_mk, counit_app]
    erw [colimit.ι_desc, ← category.assoc, colimit.ι_map, whisker_left_app, category.assoc, colimit.ι_desc]
    rfl

instance [HasColimits C] : IsRightAdjoint (skyscraperPresheafFunctor p₀ : C ⥤ Presheaf C X) :=
  ⟨_, skyscraperPresheafStalkAdjunction _⟩

instance [HasColimits C] : IsLeftAdjoint (Presheaf.stalkFunctor C p₀) :=
  ⟨_, skyscraperPresheafStalkAdjunction _⟩

/-- Taking stalks of a sheaf is the left adjoint functor to `skyscraper_sheaf_functor`
-/
def stalkSkyscraperSheafAdjunction [HasColimits C] [HasProducts.{u} C] :
    Sheaf.forget C X ⋙ Presheaf.stalkFunctor _ p₀ ⊣ skyscraperSheafFunctor p₀ where
  homEquiv := fun 𝓕 c =>
    ⟨fun f => ⟨toSkyscraperPresheaf p₀ f⟩, fun g => fromStalk p₀ g.1, from_stalk_to_skyscraper p₀, fun g => by
      ext1
      apply to_skyscraper_from_stalk⟩
  Unit :=
    { app := fun 𝓕 => ⟨(StalkSkyscraperPresheafAdjunctionAuxs.unit p₀).app 𝓕.1⟩,
      naturality' := fun 𝓐 𝓑 ⟨f⟩ => by
        ext1
        apply (StalkSkyscraperPresheafAdjunctionAuxs.unit p₀).naturality }
  counit := StalkSkyscraperPresheafAdjunctionAuxs.counit p₀
  hom_equiv_unit' := fun 𝓐 c f => by
    ext1
    exact (skyscraperPresheafStalkAdjunction p₀).hom_equiv_unit
  hom_equiv_counit' := fun 𝓐 c f => (skyscraperPresheafStalkAdjunction p₀).hom_equiv_counit

instance [HasColimits C] [HasProducts.{u} C] : IsRightAdjoint (skyscraperSheafFunctor p₀ : C ⥤ Sheaf C X) :=
  ⟨_, stalkSkyscraperSheafAdjunction _⟩

end

end

