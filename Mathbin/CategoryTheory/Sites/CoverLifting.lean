import Mathbin.CategoryTheory.Sites.Sheaf 
import Mathbin.CategoryTheory.Limits.KanExtension 
import Mathbin.CategoryTheory.Sites.CoverPreserving

/-!
# Cover-lifting functors between sites.

We define cover-lifting functors between sites as functors that pull covering sieves back to
covering sieves. This concept is also known as *cocontinuous functors* or
*cover-reflecting functors*, but we have chosen this name following [MM92] in order to avoid
potential naming collision or confusion with the general definition of cocontinuous functors
between categories as functors preserving small colimits.

The definition given here seems stronger than the definition found elsewhere,
but they are actually equivalent via `category_theory.grothendieck_topology.superset_covering`.
(The precise statement is not formalized, but follows from it quite trivially).

## Main definitions

* `category_theory.sites.cover_lifting`: a functor between sites is cover-lifting if it
  pulls back covering sieves to covering sieves
* `category_theory.sites.copullback`: A cover-lifting functor `G : (C, J) ⥤ (D, K)` induces a
  morphism of sites in the same direction as the functor.

## Main results
* `category_theory.sites.Ran_is_sheaf_of_cover_lifting`: If `G : C ⥤ D` is cover_lifting, then
  `Ran G.op` (`ₚu`) as a functor `(Cᵒᵖ ⥤ A) ⥤ (Dᵒᵖ ⥤ A)` of presheaves maps sheaves to sheaves.
* `category_theory.pullback_copullback_adjunction`: If `G : (C, J) ⥤ (D, K)` is cover-lifting,
  cover-preserving, and compatible-preserving, then `pullback G` and `copullback G` are adjoint.

## References

* [Elephant]: *Sketches of an Elephant*, P. T. Johnstone: C2.3.
* [S. MacLane, I. Moerdijk, *Sheaves in Geometry and Logic*][MM92]
* https://stacks.math.columbia.edu/tag/00XI

-/


universe v u

noncomputable theory

open CategoryTheory

open Opposite

open CategoryTheory.Presieve.FamilyOfElements

open CategoryTheory.Presieve

open CategoryTheory.Limits

namespace CategoryTheory

section CoverLifting

variable{C : Type _}[category C]{D : Type _}[category D]{E : Type _}[category E]

variable(J : grothendieck_topology C)(K : grothendieck_topology D)

variable{L : grothendieck_topology E}

/--
A functor `G : (C, J) ⥤ (D, K)` between sites is called to have the cover-lifting property
if for all covering sieves `R` in `D`, `R.pullback G` is a covering sieve in `C`.
-/
@[nolint has_inhabited_instance]
structure cover_lifting(G : C ⥤ D) : Prop where 
  cover_lift : ∀ {U : C} {S : sieve (G.obj U)} (hS : S ∈ K (G.obj U)), S.functor_pullback G ∈ J U

/-- The identity functor on a site is cover-lifting. -/
theorem id_cover_lifting : cover_lifting J J (𝟭 _) :=
  ⟨fun _ _ h =>
      by 
        simpa using h⟩

variable{J K}

/-- The composition of two cover-lifting functors are cover-lifting -/
theorem comp_cover_lifting {F : C ⥤ D} (hu : cover_lifting J K F) {G : D ⥤ E} (hv : cover_lifting K L G) :
  cover_lifting J L (F ⋙ G) :=
  ⟨fun _ S h => hu.cover_lift (hv.cover_lift h)⟩

end CoverLifting

/-!
We will now prove that `Ran G.op` (`ₚu`) maps sheaves to sheaves if `G` is cover-lifting. This can
be found in https://stacks.math.columbia.edu/tag/00XK. However, the proof given here uses the
amalgamation definition of sheaves, and thus does not require that `C` or `D` has categorical
pullbacks.

For the following proof sketch, `⊆` denotes the homs on `C` and `D` as in the topological analogy.
By definition, the presheaf `𝒢 : Dᵒᵖ ⥤ A` is a sheaf if for every sieve `S` of `U : D`, and every
compatible family of morphisms `X ⟶ 𝒢(V)` for each `V ⊆ U : S` with a fixed source `X`,
we can glue them into a morphism `X ⟶ 𝒢(U)`.

Since the presheaf `𝒢 := (Ran G.op).obj ℱ.val` is defined via `𝒢(U) = lim_{G(V) ⊆ U} ℱ(V)`, for
gluing the family `x` into a `X ⟶ 𝒢(U)`, it suffices to provide a `X ⟶ ℱ(Y)` for each
`G(Y) ⊆ U`. This can be done since `{ Y' ⊆ Y : G(Y') ⊆ U ∈ S}` is a covering sieve for `Y` on
`C` (by the cover-lifting property of `G`). Thus the morphisms `X ⟶ 𝒢(G(Y')) ⟶ ℱ(Y')` can be
glued into a morphism `X ⟶ ℱ(Y)`. This is done in `get_sections`.

In `glued_limit_cone`, we verify these obtained sections are indeed compatible, and thus we obtain
A `X ⟶ 𝒢(U)`. The remaining work is to verify that this is indeed the amalgamation and is unique.
-/


variable{C D : Type u}[category.{u} C][category.{u} D]

variable{A : Type v}[category.{u} A][has_limits A]

variable{J : grothendieck_topology C}{K : grothendieck_topology D}

namespace RanIsSheafOfCoverLifting

variable{G : C ⥤ D}(hu : cover_lifting J K G)(ℱ : Sheaf J A)

variable{X : A}{U : D}(S : sieve U)(hS : S ∈ K U)

variable(x : S.arrows.family_of_elements ((Ran G.op).obj ℱ.val ⋙ coyoneda.obj (op X)))

variable(hx : x.compatible)

/-- The family of morphisms `X ⟶ 𝒢(G(Y')) ⟶ ℱ(Y')` defined on `{ Y' ⊆ Y : G(Y') ⊆ U ∈ S}`. -/
def pulledback_family (Y : structured_arrow (op U) G.op) :=
  ((x.pullback Y.hom.unop).FunctorPullback G).compPresheafMap
    (show _ ⟶ _ from whisker_right ((Ran.adjunction A G.op).counit.app ℱ.val) (coyoneda.obj (op X)))

@[simp]
theorem pulledback_family_apply (Y : structured_arrow (op U) G.op) {W} {f : W ⟶ _} Hf :
  pulledback_family ℱ S x Y f Hf =
    x (G.map f ≫ Y.hom.unop) Hf ≫ ((Ran.adjunction A G.op).counit.app ℱ.val).app (op W) :=
  rfl

variable{x}{S}

include hu hS hx

-- error in CategoryTheory.Sites.CoverLifting: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Given a `G(Y) ⊆ U`, we can find a unique section `X ⟶ ℱ(Y)` that agrees with `x`. -/
def get_section (Y : structured_arrow (op U) G.op) : «expr ⟶ »(X, ℱ.val.obj Y.right) :=
begin
  let [ident hom_sh] [] [":=", expr whisker_right ((Ran.adjunction A G.op).counit.app ℱ.val) (coyoneda.obj (op X))],
  have [ident S'] [] [":=", expr K.pullback_stable Y.hom.unop hS],
  have [ident hs'] [] [":=", expr ((hx.pullback Y.3.unop).functor_pullback G).comp_presheaf_map hom_sh],
  exact [expr (ℱ.2 X _ (hu.cover_lift S')).amalgamate _ hs']
end

theorem get_section_is_amalgamation (Y : structured_arrow (op U) G.op) :
  (pulledback_family ℱ S x Y).IsAmalgamation (get_section hu ℱ hS hx Y) :=
  is_sheaf_for.is_amalgamation _ _

theorem get_section_is_unique (Y : structured_arrow (op U) G.op) {y}
  (H : (pulledback_family ℱ S x Y).IsAmalgamation y) : y = get_section hu ℱ hS hx Y :=
  by 
    apply is_sheaf_for.is_separated_for _ (pulledback_family ℱ S x Y)
    ·
      exact H
    ·
      apply get_section_is_amalgamation
    ·
      exact ℱ.2 X _ (hu.cover_lift (K.pullback_stable Y.hom.unop hS))

-- error in CategoryTheory.Sites.CoverLifting: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem get_section_commute
{Y Z : structured_arrow (op U) G.op}
(f : «expr ⟶ »(Y, Z)) : «expr = »(«expr ≫ »(get_section hu ℱ hS hx Y, ℱ.val.map f.right), get_section hu ℱ hS hx Z) :=
begin
  apply [expr get_section_is_unique],
  intros [ident V', ident fV', ident hV'],
  have [ident eq] [":", expr «expr = »(Z.hom, «expr ≫ »(Y.hom, (G.map f.right.unop).op))] [],
  { convert [] [expr f.w] [],
    erw [expr category.id_comp] [] },
  rw [expr eq] ["at", ident hV'],
  convert [] [expr get_section_is_amalgamation hu ℱ hS hx Y «expr ≫ »(fV', f.right.unop) _] ["using", 1],
  { tidy [] },
  { simp [] [] ["only"] ["[", expr eq, ",", expr quiver.hom.unop_op, ",", expr pulledback_family_apply, ",", expr functor.map_comp, ",", expr unop_comp, ",", expr category.assoc, "]"] [] [] },
  { change [expr S «expr ≫ »(G.map _, Y.hom.unop)] [] [],
    simpa [] [] ["only"] ["[", expr functor.map_comp, ",", expr category.assoc, "]"] [] ["using", expr hV'] }
end

/-- The limit cone in order to glue the sections obtained via `get_section`. -/
def glued_limit_cone : limits.cone (Ran.diagram G.op ℱ.val (op U)) :=
  { x,
    π :=
      { app := fun Y => get_section hu ℱ hS hx Y,
        naturality' :=
          fun Y Z f =>
            by 
              tidy } }

@[simp]
theorem glued_limit_cone_π_app W : (glued_limit_cone hu ℱ hS hx).π.app W = get_section hu ℱ hS hx W :=
  rfl

/-- The section obtained by passing `glued_limit_cone` into `category_theory.limits.limit.lift`. -/
def glued_section : X ⟶ ((Ran G.op).obj ℱ.val).obj (op U) :=
  limit.lift _ (glued_limit_cone hu ℱ hS hx)

-- error in CategoryTheory.Sites.CoverLifting: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
A helper lemma for the following two lemmas. Basically stating that if the section `y : X ⟶ 𝒢(V)`
coincides with `x` on `G(V')` for all `G(V') ⊆ V ∈ S`, then `X ⟶ 𝒢(V) ⟶ ℱ(W)` is indeed the
section obtained in `get_sections`. That said, this is littered with some more categorical jargon
in order to be applied in the following lemmas easier.
-/
theorem helper
{V}
(f : «expr ⟶ »(V, U))
(y : «expr ⟶ »(X, ((Ran G.op).obj ℱ.val).obj (op V)))
(W)
(H : ∀
 {V'}
 {fV : «expr ⟶ »(G.obj V', V)}
 (hV), «expr = »(«expr ≫ »(y, ((Ran G.op).obj ℱ.val).map fV.op), x «expr ≫ »(fV, f) hV)) : «expr = »(«expr ≫ »(y, limit.π (Ran.diagram G.op ℱ.val (op V)) W), (glued_limit_cone hu ℱ hS hx).π.app ((structured_arrow.map f.op).obj W)) :=
begin
  dsimp ["only"] ["[", expr glued_limit_cone_π_app, "]"] [] [],
  apply [expr get_section_is_unique hu ℱ hS hx ((structured_arrow.map f.op).obj W)],
  intros [ident V', ident fV', ident hV'],
  dsimp ["only"] ["[", expr Ran.adjunction, ",", expr Ran.equiv, ",", expr pulledback_family_apply, "]"] [] [],
  erw ["[", expr adjunction.adjunction_of_equiv_right_counit_app, "]"] [],
  have [] [":", expr «expr = »(«expr ≫ »(y, ((Ran G.op).obj ℱ.val).map «expr ≫ »(G.map fV', W.hom.unop).op), x «expr ≫ »(G.map fV', «expr ≫ »(W.hom.unop, f)) (by simpa [] [] ["only"] [] [] ["using", expr hV']))] [],
  { convert [] [expr H (show S «expr ≫ »(«expr ≫ »(G.map fV', W.hom.unop), f), by simpa [] [] ["only"] ["[", expr category.assoc, "]"] [] ["using", expr hV'])] ["using", 2],
    simp [] [] ["only"] ["[", expr category.assoc, "]"] [] [] },
  simp [] [] ["only"] ["[", expr quiver.hom.unop_op, ",", expr equiv.symm_symm, ",", expr structured_arrow.map_obj_hom, ",", expr unop_comp, ",", expr equiv.coe_fn_mk, ",", expr functor.comp_map, ",", expr coyoneda_obj_map, ",", expr category.assoc, ",", "<-", expr this, ",", expr op_comp, ",", expr Ran_obj_map, ",", expr nat_trans.id_app, "]"] [] [],
  erw ["[", expr category.id_comp, ",", expr limit.pre_π, "]"] [],
  congr,
  convert [] [expr limit.w (Ran.diagram G.op ℱ.val (op V)) (structured_arrow.hom_mk' W fV'.op)] [],
  rw [expr structured_arrow.map_mk] [],
  erw [expr category.comp_id] [],
  simp [] [] ["only"] ["[", expr quiver.hom.unop_op, ",", expr functor.op_map, ",", expr quiver.hom.op_unop, "]"] [] []
end

/-- Verify that the `glued_section` is an amalgamation of `x`. -/
theorem glued_section_is_amalgamation : x.is_amalgamation (glued_section hu ℱ hS hx) :=
  by 
    intro V fV hV 
    ext W 
    simp only [functor.comp_map, limit.lift_pre, coyoneda_obj_map, Ran_obj_map, glued_section]
    erw [limit.lift_π]
    symm 
    convert helper hu ℱ hS hx _ (x fV hV) _ _ using 1
    intro V' fV' hV' 
    convert
      hx fV' (𝟙 _) hV hV'
        (by 
          rw [category.id_comp])
    simp only [op_id, functor_to_types.map_id_apply]

/-- Verify that the amalgamation is indeed unique. -/
theorem glued_section_is_unique y (hy : x.is_amalgamation y) : y = glued_section hu ℱ hS hx :=
  by 
    unfold glued_section limit.lift 
    ext W 
    erw [limit.lift_π]
    convert helper hu ℱ hS hx (𝟙 _) y W _
    ·
      simp only [op_id, structured_arrow.map_id]
    ·
      intro V' fV' hV' 
      convert
        hy fV'
          (by 
            simpa only [category.comp_id] using hV')
      erw [category.comp_id]

end RanIsSheafOfCoverLifting

/--
If `G` is cover_lifting, then `Ran G.op` pushes sheaves to sheaves.

This result is basically https://stacks.math.columbia.edu/tag/00XK,
but without the condition that `C` or `D` has pullbacks.
-/
theorem Ran_is_sheaf_of_cover_lifting {G : C ⥤ D} (hG : cover_lifting J K G) (ℱ : Sheaf J A) :
  presheaf.is_sheaf K ((Ran G.op).obj ℱ.val) :=
  by 
    intro X U S hS x hx 
    split 
    swap
    ·
      apply Ran_is_sheaf_of_cover_lifting.glued_section hG ℱ hS hx 
    split 
    ·
      apply Ran_is_sheaf_of_cover_lifting.glued_section_is_amalgamation
    ·
      apply Ran_is_sheaf_of_cover_lifting.glued_section_is_unique

variable(A)

/-- A cover-lifting functor induces a morphism of sites in the same direction as the functor. -/
def sites.copullback {G : C ⥤ D} (hG : cover_lifting J K G) : Sheaf J A ⥤ Sheaf K A :=
  { obj := fun ℱ => ⟨(Ran G.op).obj ℱ.val, Ran_is_sheaf_of_cover_lifting hG ℱ⟩, map := fun _ _ f => (Ran G.op).map f,
    map_id' := fun ℱ => (Ran G.op).map_id ℱ.val, map_comp' := fun _ _ _ f g => (Ran G.op).map_comp f g }

/--
Given a functor between sites that is cover-preserving, cover-lifting, and compatible-preserving,
the pullback and copullback along `G` are adjoint to each other
-/
@[simps]
noncomputable def sites.pullback_copullback_adjunction {G : C ⥤ D} (Hp : cover_preserving J K G)
  (Hl : cover_lifting J K G) (Hc : compatible_preserving K G) : sites.pullback A Hc Hp ⊣ sites.copullback A Hl :=
  { homEquiv := fun X Y => (Ran.adjunction A G.op).homEquiv X.val Y.val,
    Unit :=
      { app := fun X => (Ran.adjunction A G.op).Unit.app X.val,
        naturality' := fun _ _ f => (Ran.adjunction A G.op).Unit.naturality f },
    counit :=
      { app := fun X => (Ran.adjunction A G.op).counit.app X.val,
        naturality' := fun _ _ f => (Ran.adjunction A G.op).counit.naturality f },
    hom_equiv_unit' := fun X Y f => (Ran.adjunction A G.op).hom_equiv_unit,
    hom_equiv_counit' := fun X Y f => (Ran.adjunction A G.op).hom_equiv_counit }

end CategoryTheory

