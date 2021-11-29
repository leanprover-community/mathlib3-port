import Mathbin.CategoryTheory.Limits.HasLimits 
import Mathbin.CategoryTheory.Products.Basic 
import Mathbin.CategoryTheory.Currying

/-!
# A Fubini theorem for categorical limits

We prove that $lim_{J × K} G = lim_J (lim_K G(j, -))$ for a functor `G : J × K ⥤ C`,
when all the appropriate limits exist.

We begin working with a functor `F : J ⥤ K ⥤ C`. We'll write `G : J × K ⥤ C` for the associated
"uncurried" functor.

In the first part, given a coherent family `D` of limit cones over the functors `F.obj j`,
and a cone `c` over `G`, we construct a cone over the cone points of `D`.
We then show that if `c` is a limit cone, the constructed cone is also a limit cone.

In the second part, we state the Fubini theorem in the setting where limits are
provided by suitable `has_limit` classes.

We construct
`limit_uncurry_iso_limit_comp_lim F : limit (uncurry.obj F) ≅ limit (F ⋙ lim)`
and give simp lemmas characterising it.
For convenience, we also provide
`limit_iso_limit_curry_comp_lim G : limit G ≅ limit ((curry.obj G) ⋙ lim)`
in terms of the uncurried functor.

## Future work

The dual statement.
-/


universe v u

open CategoryTheory

namespace CategoryTheory.Limits

variable{J K : Type v}[small_category J][small_category K]

variable{C : Type u}[category.{v} C]

variable(F : J ⥤ K ⥤ C)

/--
A structure carrying a diagram of cones over the functors `F.obj j`.
-/
structure diagram_of_cones where 
  obj : ∀ (j : J), cone (F.obj j)
  map : ∀ {j j' : J} (f : j ⟶ j'), (cones.postcompose (F.map f)).obj (obj j) ⟶ obj j' 
  id : ∀ (j : J), (map (𝟙 j)).Hom = 𝟙 _ :=  by 
  runTac 
    obviously 
  comp : ∀ {j₁ j₂ j₃ : J} (f : j₁ ⟶ j₂) (g : j₂ ⟶ j₃), (map (f ≫ g)).Hom = (map f).Hom ≫ (map g).Hom :=  by 
  runTac 
    obviously

variable{F}

/--
Extract the functor `J ⥤ C` consisting of the cone points and the maps between them,
from a `diagram_of_cones`.
-/
@[simps]
def diagram_of_cones.cone_points (D : diagram_of_cones F) : J ⥤ C :=
  { obj := fun j => (D.obj j).x, map := fun j j' f => (D.map f).Hom, map_id' := fun j => D.id j,
    map_comp' := fun j₁ j₂ j₃ f g => D.comp f g }

-- error in CategoryTheory.Limits.Fubini: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
Given a diagram `D` of limit cones over the `F.obj j`, and a cone over `uncurry.obj F`,
we can construct a cone over the diagram consisting of the cone points from `D`.
-/
@[simps #[]]
def cone_of_cone_uncurry
{D : diagram_of_cones F}
(Q : ∀ j, is_limit (D.obj j))
(c : cone (uncurry.obj F)) : cone D.cone_points :=
{ X := c.X,
  π := { app := λ
    j, (Q j).lift { X := c.X,
      π := { app := λ k, c.π.app (j, k),
        naturality' := λ k k' f, begin
          dsimp [] [] [] [],
          simp [] [] ["only"] ["[", expr category.id_comp, "]"] [] [],
          have [] [] [":=", expr @nat_trans.naturality _ _ _ _ _ _ c.π (j, k) (j, k') («expr𝟙»() j, f)],
          dsimp [] [] [] ["at", ident this],
          simp [] [] ["only"] ["[", expr category.id_comp, ",", expr category_theory.functor.map_id, ",", expr nat_trans.id_app, "]"] [] ["at", ident this],
          exact [expr this]
        end } },
    naturality' := λ
    j
    j'
    f, (Q j').hom_ext (begin
       dsimp [] [] [] [],
       intro [ident k],
       simp [] [] ["only"] ["[", expr limits.cone_morphism.w, ",", expr limits.cones.postcompose_obj_π, ",", expr limits.is_limit.fac_assoc, ",", expr limits.is_limit.fac, ",", expr nat_trans.comp_app, ",", expr category.id_comp, ",", expr category.assoc, "]"] [] [],
       have [] [] [":=", expr @nat_trans.naturality _ _ _ _ _ _ c.π (j, k) (j', k) (f, «expr𝟙»() k)],
       dsimp [] [] [] ["at", ident this],
       simp [] [] ["only"] ["[", expr category.id_comp, ",", expr category.comp_id, ",", expr category_theory.functor.map_id, ",", expr nat_trans.id_app, "]"] [] ["at", ident this],
       exact [expr this]
     end) } }

-- error in CategoryTheory.Limits.Fubini: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
`cone_of_cone_uncurry Q c` is a limit cone when `c` is a limit cone.`
-/
def cone_of_cone_uncurry_is_limit
{D : diagram_of_cones F}
(Q : ∀ j, is_limit (D.obj j))
{c : cone (uncurry.obj F)}
(P : is_limit c) : is_limit (cone_of_cone_uncurry Q c) :=
{ lift := λ
  s, P.lift { X := s.X,
    π := { app := λ p, «expr ≫ »(s.π.app p.1, (D.obj p.1).π.app p.2),
      naturality' := λ p p' f, begin
        dsimp [] [] [] [],
        simp [] [] ["only"] ["[", expr category.id_comp, ",", expr category.assoc, "]"] [] [],
        rcases [expr p, "with", "⟨", ident j, ",", ident k, "⟩"],
        rcases [expr p', "with", "⟨", ident j', ",", ident k', "⟩"],
        rcases [expr f, "with", "⟨", ident fj, ",", ident fk, "⟩"],
        dsimp [] [] [] [],
        slice_rhs [3] [4] { rw ["<-", expr nat_trans.naturality] },
        slice_rhs [2] [3] { rw ["<-", expr (D.obj j).π.naturality] },
        simp [] [] ["only"] ["[", expr functor.const.obj_map, ",", expr category.id_comp, ",", expr category.assoc, "]"] [] [],
        have [ident w] [] [":=", expr (D.map fj).w k'],
        dsimp [] [] [] ["at", ident w],
        rw ["<-", expr w] [],
        have [ident n] [] [":=", expr s.π.naturality fj],
        dsimp [] [] [] ["at", ident n],
        simp [] [] ["only"] ["[", expr category.id_comp, "]"] [] ["at", ident n],
        rw [expr n] [],
        simp [] [] [] [] [] []
      end } },
  fac' := λ s j, begin
    apply [expr (Q j).hom_ext],
    intro [ident k],
    simp [] [] [] [] [] []
  end,
  uniq' := λ s m w, begin
    refine [expr P.uniq { X := s.X, π := _ } m _],
    rintro ["⟨", ident j, ",", ident k, "⟩"],
    dsimp [] [] [] [],
    rw ["[", "<-", expr w j, "]"] [],
    simp [] [] [] [] [] []
  end }

section 

variable(F)

variable[has_limits_of_shape K C]

/--
Given a functor `F : J ⥤ K ⥤ C`, with all needed limits,
we can construct a diagram consisting of the limit cone over each functor `F.obj j`,
and the universal cone morphisms between these.
-/
@[simps]
noncomputable def diagram_of_cones.mk_of_has_limits : diagram_of_cones F :=
  { obj := fun j => limit.cone (F.obj j), map := fun j j' f => { Hom := lim.map (F.map f) } }

noncomputable instance diagram_of_cones_inhabited : Inhabited (diagram_of_cones F) :=
  ⟨diagram_of_cones.mk_of_has_limits F⟩

@[simp]
theorem diagram_of_cones.mk_of_has_limits_cone_points : (diagram_of_cones.mk_of_has_limits F).conePoints = F ⋙ lim :=
  rfl

variable[has_limit (uncurry.obj F)]

variable[has_limit (F ⋙ lim)]

-- error in CategoryTheory.Limits.Fubini: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
The Fubini theorem for a functor `F : J ⥤ K ⥤ C`,
showing that the limit of `uncurry.obj F` can be computed as
the limit of the limits of the functors `F.obj j`.
-/ noncomputable def limit_uncurry_iso_limit_comp_lim : «expr ≅ »(limit (uncurry.obj F), limit «expr ⋙ »(F, lim)) :=
begin
  let [ident c] [] [":=", expr limit.cone (uncurry.obj F)],
  let [ident P] [":", expr is_limit c] [":=", expr limit.is_limit _],
  let [ident G] [] [":=", expr diagram_of_cones.mk_of_has_limits F],
  let [ident Q] [":", expr ∀ j, is_limit (G.obj j)] [":=", expr λ j, limit.is_limit _],
  have [ident Q'] [] [":=", expr cone_of_cone_uncurry_is_limit Q P],
  have [ident Q''] [] [":=", expr limit.is_limit «expr ⋙ »(F, lim)],
  exact [expr is_limit.cone_point_unique_up_to_iso Q' Q'']
end

@[simp]
theorem limit_uncurry_iso_limit_comp_lim_hom_π_π {j} {k} :
  (limit_uncurry_iso_limit_comp_lim F).Hom ≫ limit.π _ j ≫ limit.π _ k = limit.π _ (j, k) :=
  by 
    dsimp [limit_uncurry_iso_limit_comp_lim, is_limit.cone_point_unique_up_to_iso, is_limit.unique_up_to_iso]
    simp 

@[simp]
theorem limit_uncurry_iso_limit_comp_lim_inv_π {j} {k} :
  (limit_uncurry_iso_limit_comp_lim F).inv ≫ limit.π _ (j, k) = limit.π _ j ≫ limit.π _ k :=
  by 
    rw [←cancel_epi (limit_uncurry_iso_limit_comp_lim F).Hom]
    simp 

end 

section 

variable(G : J × K ⥤ C)

section 

variable[has_limits_of_shape K C]

variable[has_limit G]

variable[has_limit (curry.obj G ⋙ lim)]

-- error in CategoryTheory.Limits.Fubini: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
The Fubini theorem for a functor `G : J × K ⥤ C`,
showing that the limit of `G` can be computed as
the limit of the limits of the functors `G.obj (j, _)`.
-/ noncomputable def limit_iso_limit_curry_comp_lim : «expr ≅ »(limit G, limit «expr ⋙ »(curry.obj G, lim)) :=
begin
  have [ident i] [":", expr «expr ≅ »(G, uncurry.obj ((@curry J _ K _ C _).obj G))] [":=", expr currying.symm.unit_iso.app G],
  haveI [] [":", expr limits.has_limit (uncurry.obj ((@curry J _ K _ C _).obj G))] [":=", expr has_limit_of_iso i],
  transitivity [expr limit (uncurry.obj ((@curry J _ K _ C _).obj G))],
  apply [expr has_limit.iso_of_nat_iso i],
  exact [expr limit_uncurry_iso_limit_comp_lim ((@curry J _ K _ C _).obj G)]
end

@[simp, reassoc]
theorem limit_iso_limit_curry_comp_lim_hom_π_π {j} {k} :
  (limit_iso_limit_curry_comp_lim G).Hom ≫ limit.π _ j ≫ limit.π _ k = limit.π _ (j, k) :=
  by 
    simp [limit_iso_limit_curry_comp_lim, is_limit.cone_point_unique_up_to_iso, is_limit.unique_up_to_iso]

@[simp, reassoc]
theorem limit_iso_limit_curry_comp_lim_inv_π {j} {k} :
  (limit_iso_limit_curry_comp_lim G).inv ≫ limit.π _ (j, k) = limit.π _ j ≫ limit.π _ k :=
  by 
    rw [←cancel_epi (limit_iso_limit_curry_comp_lim G).Hom]
    simp 

end 

section 

variable[has_limits C]

open CategoryTheory.prod

/--
A variant of the Fubini theorem for a functor `G : J × K ⥤ C`,
showing that $\lim_k \lim_j G(j,k) ≅ \lim_j \lim_k G(j,k)$.
-/
noncomputable def limit_curry_swap_comp_lim_iso_limit_curry_comp_lim :
  limit (curry.obj (swap K J ⋙ G) ⋙ lim) ≅ limit (curry.obj G ⋙ lim) :=
  calc limit (curry.obj (swap K J ⋙ G) ⋙ lim) ≅ limit (swap K J ⋙ G) := (limit_iso_limit_curry_comp_lim _).symm 
    _ ≅ limit G := has_limit.iso_of_equivalence (braiding K J) (iso.refl _)
    _ ≅ limit (curry.obj G ⋙ lim) := limit_iso_limit_curry_comp_lim _
    

@[simp]
theorem limit_curry_swap_comp_lim_iso_limit_curry_comp_lim_hom_π_π {j} {k} :
  (limit_curry_swap_comp_lim_iso_limit_curry_comp_lim G).Hom ≫ limit.π _ j ≫ limit.π _ k = limit.π _ k ≫ limit.π _ j :=
  by 
    dsimp [limit_curry_swap_comp_lim_iso_limit_curry_comp_lim]
    simp only [iso.refl_hom, braiding_counit_iso_hom_app, limits.has_limit.iso_of_equivalence_hom_π, iso.refl_inv,
      limit_iso_limit_curry_comp_lim_hom_π_π, eq_to_iso_refl, category.assoc]
    erw [nat_trans.id_app]
    dsimp 
    simp 

@[simp]
theorem limit_curry_swap_comp_lim_iso_limit_curry_comp_lim_inv_π_π {j} {k} :
  (limit_curry_swap_comp_lim_iso_limit_curry_comp_lim G).inv ≫ limit.π _ k ≫ limit.π _ j = limit.π _ j ≫ limit.π _ k :=
  by 
    dsimp [limit_curry_swap_comp_lim_iso_limit_curry_comp_lim]
    simp only [iso.refl_hom, braiding_counit_iso_hom_app, limits.has_limit.iso_of_equivalence_inv_π, iso.refl_inv,
      limit_iso_limit_curry_comp_lim_hom_π_π, eq_to_iso_refl, category.assoc]
    erw [nat_trans.id_app]
    dsimp 
    simp 

end 

end 

end CategoryTheory.Limits

