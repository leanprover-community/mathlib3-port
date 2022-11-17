/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import Mathbin.CategoryTheory.Category.Preorder
import Mathbin.CategoryTheory.EqToHom
import Mathbin.Topology.Category.TopCat.EpiMono
import Mathbin.Topology.Sets.Opens

/-!
# The category of open sets in a topological space.

We define `to_Top : opens X ⥤ Top` and
`map (f : X ⟶ Y) : opens Y ⥤ opens X`, given by taking preimages of open sets.

Unfortunately `opens` isn't (usefully) a functor `Top ⥤ Cat`.
(One can in fact define such a functor,
but using it results in unresolvable `eq.rec` terms in goals.)

Really it's a 2-functor from (spaces, continuous functions, equalities)
to (categories, functors, natural isomorphisms).
We don't attempt to set up the full theory here, but do provide the natural isomorphisms
`map_id : map (𝟙 X) ≅ 𝟭 (opens X)` and
`map_comp : map (f ≫ g) ≅ map g ⋙ map f`.

Beyond that, there's a collection of simp lemmas for working with these constructions.
-/


open CategoryTheory

open TopologicalSpace

open Opposite

universe u

namespace TopologicalSpace.Opens

variable {X Y Z : TopCat.{u}}

/-!
Since `opens X` has a partial order, it automatically receives a `category` instance.
Unfortunately, because we do not allow morphisms in `Prop`,
the morphisms `U ⟶ V` are not just proofs `U ≤ V`, but rather
`ulift (plift (U ≤ V))`.
-/


instance opensHomHasCoeToFun {U V : Opens X} : CoeFun (U ⟶ V) fun f => U → V :=
  ⟨fun f x => ⟨x, f.le x.2⟩⟩
#align topological_space.opens.opens_hom_has_coe_to_fun TopologicalSpace.Opens.opensHomHasCoeToFun

/-!
We now construct as morphisms various inclusions of open sets.
-/


-- This is tedious, but necessary because we decided not to allow Prop as morphisms in a category...
/-- The inclusion `U ⊓ V ⟶ U` as a morphism in the category of open sets.
-/
def infLeLeft (U V : Opens X) : U ⊓ V ⟶ U :=
  inf_le_left.Hom
#align topological_space.opens.inf_le_left TopologicalSpace.Opens.infLeLeft

/-- The inclusion `U ⊓ V ⟶ V` as a morphism in the category of open sets.
-/
def infLeRight (U V : Opens X) : U ⊓ V ⟶ V :=
  inf_le_right.Hom
#align topological_space.opens.inf_le_right TopologicalSpace.Opens.infLeRight

/-- The inclusion `U i ⟶ supr U` as a morphism in the category of open sets.
-/
def leSupr {ι : Type _} (U : ι → Opens X) (i : ι) : U i ⟶ supr U :=
  (le_supr U i).Hom
#align topological_space.opens.le_supr TopologicalSpace.Opens.leSupr

/-- The inclusion `⊥ ⟶ U` as a morphism in the category of open sets.
-/
def botLe (U : Opens X) : ⊥ ⟶ U :=
  bot_le.Hom
#align topological_space.opens.bot_le TopologicalSpace.Opens.botLe

/-- The inclusion `U ⟶ ⊤` as a morphism in the category of open sets.
-/
def leTop (U : Opens X) : U ⟶ ⊤ :=
  le_top.Hom
#align topological_space.opens.le_top TopologicalSpace.Opens.leTop

-- We do not mark this as a simp lemma because it breaks open `x`.
-- Nevertheless, it is useful in `sheaf_of_functions`.
theorem inf_le_left_apply (U V : Opens X) (x) : (infLeLeft U V) x = ⟨x.1, (@inf_le_left _ _ U V : _ ≤ _) x.2⟩ :=
  rfl
#align topological_space.opens.inf_le_left_apply TopologicalSpace.Opens.inf_le_left_apply

@[simp]
theorem inf_le_left_apply_mk (U V : Opens X) (x) (m) : (infLeLeft U V) ⟨x, m⟩ = ⟨x, (@inf_le_left _ _ U V : _ ≤ _) m⟩ :=
  rfl
#align topological_space.opens.inf_le_left_apply_mk TopologicalSpace.Opens.inf_le_left_apply_mk

@[simp]
theorem le_supr_apply_mk {ι : Type _} (U : ι → Opens X) (i : ι) (x) (m) :
    (leSupr U i) ⟨x, m⟩ = ⟨x, (le_supr U i : _) m⟩ :=
  rfl
#align topological_space.opens.le_supr_apply_mk TopologicalSpace.Opens.le_supr_apply_mk

/-- The functor from open sets in `X` to `Top`,
realising each open set as a topological space itself.
-/
def toTop (X : TopCat.{u}) : Opens X ⥤ TopCat where
  obj U := ⟨U.val, inferInstance⟩
  map U V i := ⟨fun x => ⟨x.1, i.le x.2⟩, (Embedding.continuous_iff embedding_subtype_coe).2 continuous_induced_dom⟩
#align topological_space.opens.to_Top TopologicalSpace.Opens.toTop

@[simp]
theorem to_Top_map (X : TopCat.{u}) {U V : Opens X} {f : U ⟶ V} {x} {h} : ((toTop X).map f) ⟨x, h⟩ = ⟨x, f.le h⟩ :=
  rfl
#align topological_space.opens.to_Top_map TopologicalSpace.Opens.to_Top_map

/-- The inclusion map from an open subset to the whole space, as a morphism in `Top`.
-/
@[simps]
def inclusion {X : TopCat.{u}} (U : Opens X) : (toTop X).obj U ⟶ X where
  toFun := _
  continuous_to_fun := continuous_subtype_coe
#align topological_space.opens.inclusion TopologicalSpace.Opens.inclusion

theorem open_embedding {X : TopCat.{u}} (U : Opens X) : OpenEmbedding (inclusion U) :=
  IsOpen.open_embedding_subtype_coe U.2
#align topological_space.opens.open_embedding TopologicalSpace.Opens.open_embedding

/-- The inclusion of the top open subset (i.e. the whole space) is an isomorphism.
-/
def inclusionTopIso (X : TopCat.{u}) : (toTop X).obj ⊤ ≅ X where
  Hom := inclusion ⊤
  inv := ⟨fun x => ⟨x, trivial⟩, continuous_def.2 $ fun U ⟨S, hS, hSU⟩ => hSU ▸ hS⟩
#align topological_space.opens.inclusion_top_iso TopologicalSpace.Opens.inclusionTopIso

/-- `opens.map f` gives the functor from open sets in Y to open set in X,
    given by taking preimages under f. -/
def map (f : X ⟶ Y) : Opens Y ⥤ Opens X where
  obj U := ⟨f ⁻¹' U.val, U.property.preimage f.Continuous⟩
  map U V i := ⟨⟨fun x h => i.le h⟩⟩
#align topological_space.opens.map TopologicalSpace.Opens.map

theorem map_coe (f : X ⟶ Y) (U : Opens Y) : ↑((map f).obj U) = f ⁻¹' U :=
  rfl
#align topological_space.opens.map_coe TopologicalSpace.Opens.map_coe

@[simp]
theorem map_obj (f : X ⟶ Y) (U) (p) : (map f).obj ⟨U, p⟩ = ⟨f ⁻¹' U, p.preimage f.Continuous⟩ :=
  rfl
#align topological_space.opens.map_obj TopologicalSpace.Opens.map_obj

@[simp]
theorem map_id_obj (U : Opens X) : (map (𝟙 X)).obj U = U :=
  let ⟨_, _⟩ := U
  rfl
#align topological_space.opens.map_id_obj TopologicalSpace.Opens.map_id_obj

@[simp]
theorem map_id_obj' (U) (p) : (map (𝟙 X)).obj ⟨U, p⟩ = ⟨U, p⟩ :=
  rfl
#align topological_space.opens.map_id_obj' TopologicalSpace.Opens.map_id_obj'

@[simp]
theorem map_id_obj_unop (U : (Opens X)ᵒᵖ) : (map (𝟙 X)).obj (unop U) = unop U :=
  let ⟨_, _⟩ := U.unop
  rfl
#align topological_space.opens.map_id_obj_unop TopologicalSpace.Opens.map_id_obj_unop

@[simp]
theorem op_map_id_obj (U : (Opens X)ᵒᵖ) : (map (𝟙 X)).op.obj U = U := by simp
#align topological_space.opens.op_map_id_obj TopologicalSpace.Opens.op_map_id_obj

/-- The inclusion `U ⟶ (map f).obj ⊤` as a morphism in the category of open sets.
-/
def leMapTop (f : X ⟶ Y) (U : Opens X) : U ⟶ (map f).obj ⊤ :=
  leTop U
#align topological_space.opens.le_map_top TopologicalSpace.Opens.leMapTop

@[simp]
theorem map_comp_obj (f : X ⟶ Y) (g : Y ⟶ Z) (U) : (map (f ≫ g)).obj U = (map f).obj ((map g).obj U) :=
  rfl
#align topological_space.opens.map_comp_obj TopologicalSpace.Opens.map_comp_obj

@[simp]
theorem map_comp_obj' (f : X ⟶ Y) (g : Y ⟶ Z) (U) (p) : (map (f ≫ g)).obj ⟨U, p⟩ = (map f).obj ((map g).obj ⟨U, p⟩) :=
  rfl
#align topological_space.opens.map_comp_obj' TopologicalSpace.Opens.map_comp_obj'

@[simp]
theorem map_comp_map (f : X ⟶ Y) (g : Y ⟶ Z) {U V} (i : U ⟶ V) : (map (f ≫ g)).map i = (map f).map ((map g).map i) :=
  rfl
#align topological_space.opens.map_comp_map TopologicalSpace.Opens.map_comp_map

@[simp]
theorem map_comp_obj_unop (f : X ⟶ Y) (g : Y ⟶ Z) (U) :
    (map (f ≫ g)).obj (unop U) = (map f).obj ((map g).obj (unop U)) :=
  rfl
#align topological_space.opens.map_comp_obj_unop TopologicalSpace.Opens.map_comp_obj_unop

@[simp]
theorem op_map_comp_obj (f : X ⟶ Y) (g : Y ⟶ Z) (U) : (map (f ≫ g)).op.obj U = (map f).op.obj ((map g).op.obj U) :=
  rfl
#align topological_space.opens.op_map_comp_obj TopologicalSpace.Opens.op_map_comp_obj

theorem map_supr (f : X ⟶ Y) {ι : Type _} (U : ι → Opens Y) : (map f).obj (supr U) = supr ((map f).obj ∘ U) := by
  apply Subtype.eq
  rw [supr_def, supr_def, map_obj]
  dsimp
  rw [Set.preimage_Union]
  rfl
#align topological_space.opens.map_supr TopologicalSpace.Opens.map_supr

section

variable (X)

/-- The functor `opens X ⥤ opens X` given by taking preimages under the identity function
is naturally isomorphic to the identity functor.
-/
@[simps]
def mapId : map (𝟙 X) ≅ 𝟭 (Opens X) where
  Hom := { app := fun U => eqToHom (map_id_obj U) }
  inv := { app := fun U => eqToHom (map_id_obj U).symm }
#align topological_space.opens.map_id TopologicalSpace.Opens.mapId

theorem map_id_eq : map (𝟙 X) = 𝟭 (Opens X) := by
  unfold map
  congr
  ext
  rfl
  ext
#align topological_space.opens.map_id_eq TopologicalSpace.Opens.map_id_eq

end

/-- The natural isomorphism between taking preimages under `f ≫ g`, and the composite
of taking preimages under `g`, then preimages under `f`.
-/
@[simps]
def mapComp (f : X ⟶ Y) (g : Y ⟶ Z) : map (f ≫ g) ≅ map g ⋙ map f where
  Hom := { app := fun U => eqToHom (map_comp_obj f g U) }
  inv := { app := fun U => eqToHom (map_comp_obj f g U).symm }
#align topological_space.opens.map_comp TopologicalSpace.Opens.mapComp

theorem map_comp_eq (f : X ⟶ Y) (g : Y ⟶ Z) : map (f ≫ g) = map g ⋙ map f :=
  rfl
#align topological_space.opens.map_comp_eq TopologicalSpace.Opens.map_comp_eq

-- We could make `f g` implicit here, but it's nice to be able to see when
-- they are the identity (often!)
/-- If two continuous maps `f g : X ⟶ Y` are equal,
then the functors `opens Y ⥤ opens X` they induce are isomorphic.
-/
def mapIso (f g : X ⟶ Y) (h : f = g) : map f ≅ map g :=
  NatIso.ofComponents (fun U => eqToIso (congr_fun (congr_arg Functor.obj (congr_arg map h)) U)) (by obviously)
#align topological_space.opens.map_iso TopologicalSpace.Opens.mapIso

theorem map_eq (f g : X ⟶ Y) (h : f = g) : map f = map g := by
  unfold map
  congr
  ext
  rw [h]
  rw [h]
  assumption'
#align topological_space.opens.map_eq TopologicalSpace.Opens.map_eq

@[simp]
theorem map_iso_refl (f : X ⟶ Y) (h) : mapIso f f h = Iso.refl (map _) :=
  rfl
#align topological_space.opens.map_iso_refl TopologicalSpace.Opens.map_iso_refl

@[simp]
theorem map_iso_hom_app (f g : X ⟶ Y) (h : f = g) (U : Opens Y) :
    (mapIso f g h).Hom.app U = eqToHom (congr_fun (congr_arg Functor.obj (congr_arg map h)) U) :=
  rfl
#align topological_space.opens.map_iso_hom_app TopologicalSpace.Opens.map_iso_hom_app

@[simp]
theorem map_iso_inv_app (f g : X ⟶ Y) (h : f = g) (U : Opens Y) :
    (mapIso f g h).inv.app U = eqToHom (congr_fun (congr_arg Functor.obj (congr_arg map h.symm)) U) :=
  rfl
#align topological_space.opens.map_iso_inv_app TopologicalSpace.Opens.map_iso_inv_app

/-- A homeomorphism of spaces gives an equivalence of categories of open sets. -/
@[simps]
def mapMapIso {X Y : TopCat.{u}} (H : X ≅ Y) : Opens Y ≌ Opens X where
  Functor := map H.Hom
  inverse := map H.inv
  unitIso :=
    NatIso.ofComponents (fun U => eqToIso (by simp [map, Set.preimage_preimage]))
      (by
        intro _ _ _
        simp)
  counitIso :=
    NatIso.ofComponents (fun U => eqToIso (by simp [map, Set.preimage_preimage]))
      (by
        intro _ _ _
        simp)
#align topological_space.opens.map_map_iso TopologicalSpace.Opens.mapMapIso

end TopologicalSpace.Opens

/-- An open map `f : X ⟶ Y` induces a functor `opens X ⥤ opens Y`.
-/
@[simps]
def IsOpenMap.functor {X Y : TopCat} {f : X ⟶ Y} (hf : IsOpenMap f) : Opens X ⥤ Opens Y where
  obj U := ⟨f '' U, hf U U.2⟩
  map U V h := ⟨⟨Set.image_subset _ h.down.down⟩⟩
#align is_open_map.functor IsOpenMap.functor

/-- An open map `f : X ⟶ Y` induces an adjunction between `opens X` and `opens Y`.
-/
def IsOpenMap.adjunction {X Y : TopCat} {f : X ⟶ Y} (hf : IsOpenMap f) :
    Adjunction hf.Functor (TopologicalSpace.Opens.map f) :=
  Adjunction.mkOfUnitCounit
    { Unit := { app := fun U => hom_of_le $ fun x hxU => ⟨x, hxU, rfl⟩ },
      counit := { app := fun V => hom_of_le $ fun y ⟨x, hfxV, hxy⟩ => hxy ▸ hfxV } }
#align is_open_map.adjunction IsOpenMap.adjunction

instance IsOpenMap.functorFullOfMono {X Y : TopCat} {f : X ⟶ Y} (hf : IsOpenMap f) [H : Mono f] :
    Full hf.Functor where preimage U V i :=
    homOfLe fun x hx => by
      obtain ⟨y, hy, eq⟩ := i.le ⟨x, hx, rfl⟩
      exact (TopCat.mono_iff_injective f).mp H Eq ▸ hy
#align is_open_map.functor_full_of_mono IsOpenMap.functorFullOfMono

instance IsOpenMap.functor_faithful {X Y : TopCat} {f : X ⟶ Y} (hf : IsOpenMap f) : Faithful hf.Functor where
#align is_open_map.functor_faithful IsOpenMap.functor_faithful

namespace TopologicalSpace.Opens

open TopologicalSpace

@[simp]
theorem open_embedding_obj_top {X : TopCat} (U : Opens X) : U.OpenEmbedding.IsOpenMap.Functor.obj ⊤ = U := by
  ext1
  exact set.image_univ.trans Subtype.range_coe
#align topological_space.opens.open_embedding_obj_top TopologicalSpace.Opens.open_embedding_obj_top

@[simp]
theorem inclusion_map_eq_top {X : TopCat} (U : Opens X) : (Opens.map U.inclusion).obj U = ⊤ := by
  ext1
  exact Subtype.coe_preimage_self _
#align topological_space.opens.inclusion_map_eq_top TopologicalSpace.Opens.inclusion_map_eq_top

@[simp]
theorem adjunction_counit_app_self {X : TopCat} (U : Opens X) :
    U.OpenEmbedding.IsOpenMap.Adjunction.counit.app U = eqToHom (by simp) := by ext
#align topological_space.opens.adjunction_counit_app_self TopologicalSpace.Opens.adjunction_counit_app_self

theorem inclusion_top_functor (X : TopCat) :
    (@Opens.open_embedding X ⊤).IsOpenMap.Functor = map (inclusionTopIso X).inv := by
  apply functor.hext
  intro
  abstract obj_eq 
  ext
  exact ⟨fun ⟨⟨_, _⟩, h, rfl⟩ => h, fun h => ⟨⟨x, trivial⟩, h, rfl⟩⟩
  intros
  apply Subsingleton.helim
  congr 1
  iterate 2 apply inclusion_top_functor.obj_eq
#align topological_space.opens.inclusion_top_functor TopologicalSpace.Opens.inclusion_top_functor

theorem functor_obj_map_obj {X Y : TopCat} {f : X ⟶ Y} (hf : IsOpenMap f) (U : Opens Y) :
    hf.Functor.obj ((Opens.map f).obj U) = hf.Functor.obj ⊤ ⊓ U := by
  ext
  constructor
  · rintro ⟨x, hx, rfl⟩
    exact ⟨⟨x, trivial, rfl⟩, hx⟩
    
  · rintro ⟨⟨x, -, rfl⟩, hx⟩
    exact ⟨x, hx, rfl⟩
    
#align topological_space.opens.functor_obj_map_obj TopologicalSpace.Opens.functor_obj_map_obj

@[simp]
theorem functor_map_eq_inf {X : TopCat} (U V : Opens X) :
    U.OpenEmbedding.IsOpenMap.Functor.obj ((Opens.map U.inclusion).obj V) = V ⊓ U := by
  ext1
  refine' set.image_preimage_eq_inter_range.trans _
  simpa
#align topological_space.opens.functor_map_eq_inf TopologicalSpace.Opens.functor_map_eq_inf

theorem map_functor_eq' {X U : TopCat} (f : U ⟶ X) (hf : OpenEmbedding f) (V) :
    ((Opens.map f).obj $ hf.IsOpenMap.Functor.obj V) = V :=
  opens.ext $ Set.preimage_image_eq _ hf.inj
#align topological_space.opens.map_functor_eq' TopologicalSpace.Opens.map_functor_eq'

@[simp]
theorem map_functor_eq {X : TopCat} {U : Opens X} (V : Opens U) :
    ((Opens.map U.inclusion).obj $ U.OpenEmbedding.IsOpenMap.Functor.obj V) = V :=
  TopologicalSpace.Opens.map_functor_eq' _ U.OpenEmbedding V
#align topological_space.opens.map_functor_eq TopologicalSpace.Opens.map_functor_eq

@[simp]
theorem adjunction_counit_map_functor {X : TopCat} {U : Opens X} (V : Opens U) :
    U.OpenEmbedding.IsOpenMap.Adjunction.counit.app (U.OpenEmbedding.IsOpenMap.Functor.obj V) =
      eqToHom
        (by
          conv_rhs => rw [← V.map_functor_eq]
          rfl) :=
  by ext
#align topological_space.opens.adjunction_counit_map_functor TopologicalSpace.Opens.adjunction_counit_map_functor

end TopologicalSpace.Opens

