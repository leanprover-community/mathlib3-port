import Mathbin.CategoryTheory.Currying 
import Mathbin.CategoryTheory.Limits.Preserves.Limits

/-!
# (Co)limits in functor categories.

We show that if `D` has limits, then the functor category `C ⥤ D` also has limits
(`category_theory.limits.functor_category_has_limits`),
and the evaluation functors preserve limits
(`category_theory.limits.evaluation_preserves_limits`)
(and similarly for colimits).

We also show that `F : D ⥤ K ⥤ C` preserves (co)limits if it does so for each `k : K`
(`category_theory.limits.preserves_limits_of_evaluation` and
`category_theory.limits.preserves_colimits_of_evaluation`).
-/


open CategoryTheory CategoryTheory.Category

namespace CategoryTheory.Limits

universe v v₂ u u₂

variable{C : Type u}[category.{v} C]{D : Type u₂}[category.{v} D]

variable{J K : Type v}[small_category J][category.{v₂} K]

@[simp, reassoc]
theorem limit.lift_π_app (H : J ⥤ K ⥤ C) [has_limit H] (c : cone H) (j : J) (k : K) :
  (limit.lift H c).app k ≫ (limit.π H j).app k = (c.π.app j).app k :=
  congr_app (limit.lift_π c j) k

@[simp, reassoc]
theorem colimit.ι_desc_app (H : J ⥤ K ⥤ C) [has_colimit H] (c : cocone H) (j : J) (k : K) :
  (colimit.ι H j).app k ≫ (colimit.desc H c).app k = (c.ι.app j).app k :=
  congr_app (colimit.ι_desc c j) k

/--
The evaluation functors jointly reflect limits: that is, to show a cone is a limit of `F`
it suffices to show that each evaluation cone is a limit. In other words, to prove a cone is
limiting you can show it's pointwise limiting.
-/
def evaluation_jointly_reflects_limits {F : J ⥤ K ⥤ C} (c : cone F)
  (t : ∀ (k : K), is_limit (((evaluation K C).obj k).mapCone c)) : is_limit c :=
  { lift :=
      fun s =>
        { app := fun k => (t k).lift ⟨s.X.obj k, whisker_right s.π ((evaluation K C).obj k)⟩,
          naturality' :=
            fun X Y f =>
              (t Y).hom_ext$
                fun j =>
                  by 
                    rw [assoc, (t Y).fac _ j]
                    simpa using ((t X).fac_assoc ⟨s.X.obj X, whisker_right s.π ((evaluation K C).obj X)⟩ j _).symm },
    fac' := fun s j => nat_trans.ext _ _$ funext$ fun k => (t k).fac _ j,
    uniq' :=
      fun s m w =>
        nat_trans.ext _ _$
          funext$
            fun x =>
              (t x).hom_ext$
                fun j =>
                  (congr_app (w j) x).trans ((t x).fac ⟨s.X.obj _, whisker_right s.π ((evaluation K C).obj _)⟩ j).symm }

/--
Given a functor `F` and a collection of limit cones for each diagram `X ↦ F X k`, we can stitch
them together to give a cone for the diagram `F`.
`combined_is_limit` shows that the new cone is limiting, and `eval_combined` shows it is
(essentially) made up of the original cones.
-/
@[simps]
def combine_cones (F : J ⥤ K ⥤ C) (c : ∀ (k : K), limit_cone (F.flip.obj k)) : cone F :=
  { x :=
      { obj := fun k => (c k).Cone.x, map := fun k₁ k₂ f => (c k₂).IsLimit.lift ⟨_, (c k₁).Cone.π ≫ F.flip.map f⟩,
        map_id' :=
          fun k =>
            (c k).IsLimit.hom_ext
              fun j =>
                by 
                  dsimp 
                  simp ,
        map_comp' :=
          fun k₁ k₂ k₃ f₁ f₂ =>
            (c k₃).IsLimit.hom_ext
              fun j =>
                by 
                  simp  },
    π :=
      { app := fun j => { app := fun k => (c k).Cone.π.app j },
        naturality' := fun j₁ j₂ g => nat_trans.ext _ _$ funext$ fun k => (c k).Cone.π.naturality g } }

/-- The stitched together cones each project down to the original given cones (up to iso). -/
def evaluate_combined_cones (F : J ⥤ K ⥤ C) (c : ∀ (k : K), limit_cone (F.flip.obj k)) (k : K) :
  ((evaluation K C).obj k).mapCone (combine_cones F c) ≅ (c k).Cone :=
  cones.ext (iso.refl _)
    (by 
      tidy)

/-- Stitching together limiting cones gives a limiting cone. -/
def combined_is_limit (F : J ⥤ K ⥤ C) (c : ∀ (k : K), limit_cone (F.flip.obj k)) : is_limit (combine_cones F c) :=
  evaluation_jointly_reflects_limits _ fun k => (c k).IsLimit.ofIsoLimit (evaluate_combined_cones F c k).symm

/--
The evaluation functors jointly reflect colimits: that is, to show a cocone is a colimit of `F`
it suffices to show that each evaluation cocone is a colimit. In other words, to prove a cocone is
colimiting you can show it's pointwise colimiting.
-/
def evaluation_jointly_reflects_colimits {F : J ⥤ K ⥤ C} (c : cocone F)
  (t : ∀ (k : K), is_colimit (((evaluation K C).obj k).mapCocone c)) : is_colimit c :=
  { desc :=
      fun s =>
        { app := fun k => (t k).desc ⟨s.X.obj k, whisker_right s.ι ((evaluation K C).obj k)⟩,
          naturality' :=
            fun X Y f =>
              (t X).hom_ext$
                fun j =>
                  by 
                    rw [(t X).fac_assoc _ j]
                    erw [←(c.ι.app j).naturality_assoc f]
                    erw [(t Y).fac ⟨s.X.obj _, whisker_right s.ι _⟩ j]
                    dsimp 
                    simp  },
    fac' := fun s j => nat_trans.ext _ _$ funext$ fun k => (t k).fac _ j,
    uniq' :=
      fun s m w =>
        nat_trans.ext _ _$
          funext$
            fun x =>
              (t x).hom_ext$
                fun j =>
                  (congr_app (w j) x).trans ((t x).fac ⟨s.X.obj _, whisker_right s.ι ((evaluation K C).obj _)⟩ j).symm }

/--
Given a functor `F` and a collection of colimit cocones for each diagram `X ↦ F X k`, we can stitch
them together to give a cocone for the diagram `F`.
`combined_is_colimit` shows that the new cocone is colimiting, and `eval_combined` shows it is
(essentially) made up of the original cocones.
-/
@[simps]
def combine_cocones (F : J ⥤ K ⥤ C) (c : ∀ (k : K), colimit_cocone (F.flip.obj k)) : cocone F :=
  { x :=
      { obj := fun k => (c k).Cocone.x, map := fun k₁ k₂ f => (c k₁).IsColimit.desc ⟨_, F.flip.map f ≫ (c k₂).Cocone.ι⟩,
        map_id' :=
          fun k =>
            (c k).IsColimit.hom_ext
              fun j =>
                by 
                  dsimp 
                  simp ,
        map_comp' :=
          fun k₁ k₂ k₃ f₁ f₂ =>
            (c k₁).IsColimit.hom_ext
              fun j =>
                by 
                  simp  },
    ι :=
      { app := fun j => { app := fun k => (c k).Cocone.ι.app j },
        naturality' := fun j₁ j₂ g => nat_trans.ext _ _$ funext$ fun k => (c k).Cocone.ι.naturality g } }

/-- The stitched together cocones each project down to the original given cocones (up to iso). -/
def evaluate_combined_cocones (F : J ⥤ K ⥤ C) (c : ∀ (k : K), colimit_cocone (F.flip.obj k)) (k : K) :
  ((evaluation K C).obj k).mapCocone (combine_cocones F c) ≅ (c k).Cocone :=
  cocones.ext (iso.refl _)
    (by 
      tidy)

/-- Stitching together colimiting cocones gives a colimiting cocone. -/
def combined_is_colimit (F : J ⥤ K ⥤ C) (c : ∀ (k : K), colimit_cocone (F.flip.obj k)) :
  is_colimit (combine_cocones F c) :=
  evaluation_jointly_reflects_colimits _ fun k => (c k).IsColimit.ofIsoColimit (evaluate_combined_cocones F c k).symm

noncomputable theory

instance functor_category_has_limits_of_shape [has_limits_of_shape J C] : has_limits_of_shape J (K ⥤ C) :=
  { HasLimit :=
      fun F => has_limit.mk { Cone := combine_cones F fun k => get_limit_cone _, IsLimit := combined_is_limit _ _ } }

instance functor_category_has_colimits_of_shape [has_colimits_of_shape J C] : has_colimits_of_shape J (K ⥤ C) :=
  { HasColimit :=
      fun F =>
        has_colimit.mk
          { Cocone := combine_cocones _ fun k => get_colimit_cocone _, IsColimit := combined_is_colimit _ _ } }

instance functor_category_has_limits [has_limits C] : has_limits (K ⥤ C) :=
  {  }

instance functor_category_has_colimits [has_colimits C] : has_colimits (K ⥤ C) :=
  {  }

instance evaluation_preserves_limits_of_shape [has_limits_of_shape J C] (k : K) :
  preserves_limits_of_shape J ((evaluation K C).obj k) :=
  { PreservesLimit :=
      fun F =>
        preserves_limit_of_preserves_limit_cone (combined_is_limit _ _)$
          is_limit.of_iso_limit (limit.is_limit _) (evaluate_combined_cones F _ k).symm }

/--
If `F : J ⥤ K ⥤ C` is a functor into a functor category which has a limit,
then the evaluation of that limit at `k` is the limit of the evaluations of `F.obj j` at `k`.
-/
def limit_obj_iso_limit_comp_evaluation [has_limits_of_shape J C] (F : J ⥤ K ⥤ C) (k : K) :
  (limit F).obj k ≅ limit (F ⋙ (evaluation K C).obj k) :=
  preserves_limit_iso ((evaluation K C).obj k) F

@[simp, reassoc]
theorem limit_obj_iso_limit_comp_evaluation_hom_π [has_limits_of_shape J C] (F : J ⥤ K ⥤ C) (j : J) (k : K) :
  (limit_obj_iso_limit_comp_evaluation F k).Hom ≫ limit.π (F ⋙ (evaluation K C).obj k) j = (limit.π F j).app k :=
  by 
    dsimp [limit_obj_iso_limit_comp_evaluation]
    simp 

@[simp, reassoc]
theorem limit_obj_iso_limit_comp_evaluation_inv_π_app [has_limits_of_shape J C] (F : J ⥤ K ⥤ C) (j : J) (k : K) :
  (limit_obj_iso_limit_comp_evaluation F k).inv ≫ (limit.π F j).app k = limit.π (F ⋙ (evaluation K C).obj k) j :=
  by 
    dsimp [limit_obj_iso_limit_comp_evaluation]
    rw [iso.inv_comp_eq]
    simp 

@[ext]
theorem limit_obj_ext {H : J ⥤ K ⥤ C} [has_limits_of_shape J C] {k : K} {W : C} {f g : W ⟶ (limit H).obj k}
  (w : ∀ j, f ≫ (limits.limit.π H j).app k = g ≫ (limits.limit.π H j).app k) : f = g :=
  by 
    apply (cancel_mono (limit_obj_iso_limit_comp_evaluation H k).Hom).1 
    ext 
    simpa using w j

instance evaluation_preserves_colimits_of_shape [has_colimits_of_shape J C] (k : K) :
  preserves_colimits_of_shape J ((evaluation K C).obj k) :=
  { PreservesColimit :=
      fun F =>
        preserves_colimit_of_preserves_colimit_cocone (combined_is_colimit _ _)$
          is_colimit.of_iso_colimit (colimit.is_colimit _) (evaluate_combined_cocones F _ k).symm }

/--
If `F : J ⥤ K ⥤ C` is a functor into a functor category which has a colimit,
then the evaluation of that colimit at `k` is the colimit of the evaluations of `F.obj j` at `k`.
-/
def colimit_obj_iso_colimit_comp_evaluation [has_colimits_of_shape J C] (F : J ⥤ K ⥤ C) (k : K) :
  (colimit F).obj k ≅ colimit (F ⋙ (evaluation K C).obj k) :=
  preserves_colimit_iso ((evaluation K C).obj k) F

@[simp, reassoc]
theorem colimit_obj_iso_colimit_comp_evaluation_ι_inv [has_colimits_of_shape J C] (F : J ⥤ K ⥤ C) (j : J) (k : K) :
  colimit.ι (F ⋙ (evaluation K C).obj k) j ≫ (colimit_obj_iso_colimit_comp_evaluation F k).inv =
    (colimit.ι F j).app k :=
  by 
    dsimp [colimit_obj_iso_colimit_comp_evaluation]
    simp 

@[simp, reassoc]
theorem colimit_obj_iso_colimit_comp_evaluation_ι_app_hom [has_colimits_of_shape J C] (F : J ⥤ K ⥤ C) (j : J) (k : K) :
  (colimit.ι F j).app k ≫ (colimit_obj_iso_colimit_comp_evaluation F k).Hom =
    colimit.ι (F ⋙ (evaluation K C).obj k) j :=
  by 
    dsimp [colimit_obj_iso_colimit_comp_evaluation]
    rw [←iso.eq_comp_inv]
    simp 

@[ext]
theorem colimit_obj_ext {H : J ⥤ K ⥤ C} [has_colimits_of_shape J C] {k : K} {W : C} {f g : (colimit H).obj k ⟶ W}
  (w : ∀ j, (colimit.ι H j).app k ≫ f = (colimit.ι H j).app k ≫ g) : f = g :=
  by 
    apply (cancel_epi (colimit_obj_iso_colimit_comp_evaluation H k).inv).1 
    ext 
    simpa using w j

instance evaluation_preserves_limits [has_limits C] (k : K) : preserves_limits ((evaluation K C).obj k) :=
  { PreservesLimitsOfShape :=
      fun J 𝒥 =>
        by 
          skip <;> infer_instance }

-- error in CategoryTheory.Limits.FunctorCategory: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- `F : D ⥤ K ⥤ C` preserves the limit of some `G : J ⥤ D` if it does for each `k : K`. -/
def preserves_limit_of_evaluation
(F : «expr ⥤ »(D, «expr ⥤ »(K, C)))
(G : «expr ⥤ »(J, D))
(H : ∀ k : K, preserves_limit G («expr ⋙ »(F, (evaluation K C).obj k) : «expr ⥤ »(D, C))) : preserves_limit G F :=
⟨λ c hc, begin
   apply [expr evaluation_jointly_reflects_limits],
   intro [ident X],
   haveI [] [] [":=", expr H X],
   change [expr is_limit («expr ⋙ »(F, (evaluation K C).obj X).map_cone c)] [] [],
   exact [expr preserves_limit.preserves hc]
 end⟩

/-- `F : D ⥤ K ⥤ C` preserves limits of shape `J` if it does for each `k : K`. -/
def preserves_limits_of_shape_of_evaluation (F : D ⥤ K ⥤ C) (J : Type v) [small_category J]
  (H : ∀ (k : K), preserves_limits_of_shape J (F ⋙ (evaluation K C).obj k)) : preserves_limits_of_shape J F :=
  ⟨fun G => preserves_limit_of_evaluation F G fun k => preserves_limits_of_shape.preserves_limit⟩

/-- `F : D ⥤ K ⥤ C` preserves all limits if it does for each `k : K`. -/
def preserves_limits_of_evaluation (F : D ⥤ K ⥤ C) (H : ∀ (k : K), preserves_limits (F ⋙ (evaluation K C).obj k)) :
  preserves_limits F :=
  ⟨fun L hL =>
      by 
        exact preserves_limits_of_shape_of_evaluation F L fun k => preserves_limits.preserves_limits_of_shape⟩

instance evaluation_preserves_colimits [has_colimits C] (k : K) : preserves_colimits ((evaluation K C).obj k) :=
  { PreservesColimitsOfShape :=
      fun J 𝒥 =>
        by 
          skip <;> infer_instance }

-- error in CategoryTheory.Limits.FunctorCategory: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- `F : D ⥤ K ⥤ C` preserves the colimit of some `G : J ⥤ D` if it does for each `k : K`. -/
def preserves_colimit_of_evaluation
(F : «expr ⥤ »(D, «expr ⥤ »(K, C)))
(G : «expr ⥤ »(J, D))
(H : ∀ k, preserves_colimit G «expr ⋙ »(F, (evaluation K C).obj k)) : preserves_colimit G F :=
⟨λ c hc, begin
   apply [expr evaluation_jointly_reflects_colimits],
   intro [ident X],
   haveI [] [] [":=", expr H X],
   change [expr is_colimit («expr ⋙ »(F, (evaluation K C).obj X).map_cocone c)] [] [],
   exact [expr preserves_colimit.preserves hc]
 end⟩

/-- `F : D ⥤ K ⥤ C` preserves all colimits of shape `J` if it does for each `k : K`. -/
def preserves_colimits_of_shape_of_evaluation (F : D ⥤ K ⥤ C) (J : Type v) [small_category J]
  (H : ∀ (k : K), preserves_colimits_of_shape J (F ⋙ (evaluation K C).obj k)) : preserves_colimits_of_shape J F :=
  ⟨fun G => preserves_colimit_of_evaluation F G fun k => preserves_colimits_of_shape.preserves_colimit⟩

/-- `F : D ⥤ K ⥤ C` preserves all colimits if it does for each `k : K`. -/
def preserves_colimits_of_evaluation (F : D ⥤ K ⥤ C) (H : ∀ (k : K), preserves_colimits (F ⋙ (evaluation K C).obj k)) :
  preserves_colimits F :=
  ⟨fun L hL =>
      by 
        exact preserves_colimits_of_shape_of_evaluation F L fun k => preserves_colimits.preserves_colimits_of_shape⟩

open CategoryTheory.prod

/--
For a functor `G : J ⥤ K ⥤ C`, its limit `K ⥤ C` is given by `(G' : K ⥤ J ⥤ C) ⋙ lim`.
Note that this does not require `K` to be small.
-/
@[simps]
def limit_iso_swap_comp_lim [has_limits_of_shape J C] (G : J ⥤ K ⥤ C) [has_limit G] :
  limit G ≅ curry.obj (swap K J ⋙ uncurry.obj G) ⋙ lim :=
  nat_iso.of_components
    (fun Y =>
      limit_obj_iso_limit_comp_evaluation G Y ≪≫
        lim.mapIso
          (eq_to_iso
            (by 
              apply functor.hext
              ·
                intro X 
                simp 
              ·
                intro X₁ X₂ f 
                dsimp only [swap]
                simp )))
    (by 
      intro Y₁ Y₂ f 
      ext1 x 
      dsimp only [swap]
      simp only [limit_obj_iso_limit_comp_evaluation_hom_π_assoc, category.comp_id,
        limit_obj_iso_limit_comp_evaluation_hom_π, eq_to_iso.hom, curry.obj_map_app, nat_trans.naturality,
        category.id_comp, eq_to_hom_refl, functor.comp_map, eq_to_hom_app, lim_map_π_assoc, lim_map_π, category.assoc,
        uncurry.obj_map, lim_map_eq_lim_map, iso.trans_hom, nat_trans.id_app, CategoryTheory.Functor.map_id,
        functor.map_iso_hom]
      erw [category.id_comp])

/--
For a functor `G : J ⥤ K ⥤ C`, its colimit `K ⥤ C` is given by `(G' : K ⥤ J ⥤ C) ⋙ colim`.
Note that this does not require `K` to be small.
-/
@[simps]
def colimit_iso_swap_comp_colim [has_colimits_of_shape J C] (G : J ⥤ K ⥤ C) [has_colimit G] :
  colimit G ≅ curry.obj (swap K J ⋙ uncurry.obj G) ⋙ colim :=
  nat_iso.of_components
    (fun Y =>
      colimit_obj_iso_colimit_comp_evaluation G Y ≪≫
        colim.mapIso
          (eq_to_iso
            (by 
              apply functor.hext
              ·
                intro X 
                simp 
              ·
                intro X Y f 
                dsimp only [swap]
                simp )))
    (by 
      intro Y₁ Y₂ f 
      ext1 x 
      rw [←(colimit.ι G x).naturality_assoc f]
      dsimp only [swap]
      simp only [eq_to_iso.hom, colimit_obj_iso_colimit_comp_evaluation_ι_app_hom_assoc, curry.obj_map_app,
        colimit.ι_map, category.id_comp, eq_to_hom_refl, iso.trans_hom, functor.comp_map, eq_to_hom_app,
        colimit.ι_map_assoc, functor.map_iso_hom, category.assoc, uncurry.obj_map, nat_trans.id_app,
        CategoryTheory.Functor.map_id]
      erw [category.id_comp])

end CategoryTheory.Limits

