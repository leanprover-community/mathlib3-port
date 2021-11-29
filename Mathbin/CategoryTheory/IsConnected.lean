import Mathbin.Data.List.Chain 
import Mathbin.CategoryTheory.Punit 
import Mathbin.CategoryTheory.Groupoid

/-!
# Connected category

Define a connected category as a _nonempty_ category for which every functor
to a discrete category is isomorphic to the constant functor.

NB. Some authors include the empty category as connected, we do not.
We instead are interested in categories with exactly one 'connected
component'.

We give some equivalent definitions:
- A nonempty category for which every functor to a discrete category is
  constant on objects.
  See `any_functor_const_on_obj` and `connected.of_any_functor_const_on_obj`.
- A nonempty category for which every function `F` for which the presence of a
  morphism `f : j₁ ⟶ j₂` implies `F j₁ = F j₂` must be constant everywhere.
  See `constant_of_preserves_morphisms` and `connected.of_constant_of_preserves_morphisms`.
- A nonempty category for which any subset of its elements containing the
  default and closed under morphisms is everything.
  See `induct_on_objects` and `connected.of_induct`.
- A nonempty category for which every object is related under the reflexive
  transitive closure of the relation "there is a morphism in some direction
  from `j₁` to `j₂`".
  See `connected_zigzag` and `zigzag_connected`.
- A nonempty category for which for any two objects there is a sequence of
  morphisms (some reversed) from one to the other.
  See `exists_zigzag'` and `connected_of_zigzag`.

We also prove the result that the functor given by `(X × -)` preserves any
connected limit. That is, any limit of shape `J` where `J` is a connected
category is preserved by the functor `(X × -)`. This appears in `category_theory.limits.connected`.
-/


universe v₁ v₂ u₁ u₂

noncomputable theory

open CategoryTheory.Category

open Opposite

namespace CategoryTheory

/--
A possibly empty category for which every functor to a discrete category is constant.
-/
class is_preconnected(J : Type u₁)[category.{v₁} J] : Prop where 
  iso_constant : ∀ {α : Type u₁} (F : J ⥤ discrete α) (j : J), Nonempty (F ≅ (Functor.Const J).obj (F.obj j))

/--
We define a connected category as a _nonempty_ category for which every
functor to a discrete category is constant.

NB. Some authors include the empty category as connected, we do not.
We instead are interested in categories with exactly one 'connected
component'.

This allows us to show that the functor X ⨯ - preserves connected limits.

See https://stacks.math.columbia.edu/tag/002S
-/
class is_connected(J : Type u₁)[category.{v₁} J] extends is_preconnected J : Prop where 
  [is_nonempty : Nonempty J]

attribute [instance] is_connected.is_nonempty

variable{J : Type u₁}[category.{v₁} J]

variable{K : Type u₂}[category.{v₂} K]

/--
If `J` is connected, any functor `F : J ⥤ discrete α` is isomorphic to
the constant functor with value `F.obj j` (for any choice of `j`).
-/
def iso_constant [is_preconnected J] {α : Type u₁} (F : J ⥤ discrete α) (j : J) : F ≅ (Functor.Const J).obj (F.obj j) :=
  (is_preconnected.iso_constant F j).some

/--
If J is connected, any functor to a discrete category is constant on objects.
The converse is given in `is_connected.of_any_functor_const_on_obj`.
-/
theorem any_functor_const_on_obj [is_preconnected J] {α : Type u₁} (F : J ⥤ discrete α) (j j' : J) :
  F.obj j = F.obj j' :=
  ((iso_constant F j').Hom.app j).down.1

/--
If any functor to a discrete category is constant on objects, J is connected.
The converse of `any_functor_const_on_obj`.
-/
theorem is_connected.of_any_functor_const_on_obj [Nonempty J]
  (h : ∀ {α : Type u₁} (F : J ⥤ discrete α), ∀ (j j' : J), F.obj j = F.obj j') : is_connected J :=
  { iso_constant :=
      fun α F j' => ⟨nat_iso.of_components (fun j => eq_to_iso (h F j j')) fun _ _ _ => Subsingleton.elimₓ _ _⟩ }

/--
If `J` is connected, then given any function `F` such that the presence of a
morphism `j₁ ⟶ j₂` implies `F j₁ = F j₂`, we have that `F` is constant.
This can be thought of as a local-to-global property.

The converse is shown in `is_connected.of_constant_of_preserves_morphisms`
-/
theorem constant_of_preserves_morphisms [is_preconnected J] {α : Type u₁} (F : J → α)
  (h : ∀ (j₁ j₂ : J) (f : j₁ ⟶ j₂), F j₁ = F j₂) (j j' : J) : F j = F j' :=
  any_functor_const_on_obj { obj := F, map := fun _ _ f => eq_to_hom (h _ _ f) } j j'

/--
`J` is connected if: given any function `F : J → α` which is constant for any
`j₁, j₂` for which there is a morphism `j₁ ⟶ j₂`, then `F` is constant.
This can be thought of as a local-to-global property.

The converse of `constant_of_preserves_morphisms`.
-/
theorem is_connected.of_constant_of_preserves_morphisms [Nonempty J]
  (h : ∀ {α : Type u₁} (F : J → α), (∀ {j₁ j₂ : J} (f : j₁ ⟶ j₂), F j₁ = F j₂) → ∀ (j j' : J), F j = F j') :
  is_connected J :=
  is_connected.of_any_functor_const_on_obj fun _ F => h F.obj fun _ _ f => (F.map f).down.1

/--
An inductive-like property for the objects of a connected category.
If the set `p` is nonempty, and `p` is closed under morphisms of `J`,
then `p` contains all of `J`.

The converse is given in `is_connected.of_induct`.
-/
theorem induct_on_objects [is_preconnected J] (p : Set J) {j₀ : J} (h0 : j₀ ∈ p)
  (h1 : ∀ {j₁ j₂ : J} (f : j₁ ⟶ j₂), j₁ ∈ p ↔ j₂ ∈ p) (j : J) : j ∈ p :=
  by 
    injection constant_of_preserves_morphisms (fun k => Ulift.up (k ∈ p)) (fun j₁ j₂ f => _) j j₀ with i 
    rwa [i]
    dsimp 
    exact congr_argₓ Ulift.up (propext (h1 f))

-- error in CategoryTheory.IsConnected: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
If any maximal connected component containing some element j₀ of J is all of J, then J is connected.

The converse of `induct_on_objects`.
-/
theorem is_connected.of_induct
[nonempty J]
{j₀ : J}
(h : ∀
 p : set J, «expr ∈ »(j₀, p) → ∀
 {j₁ j₂ : J}
 (f : «expr ⟶ »(j₁, j₂)), «expr ↔ »(«expr ∈ »(j₁, p), «expr ∈ »(j₂, p)) → ∀ j : J, «expr ∈ »(j, p)) : is_connected J :=
is_connected.of_constant_of_preserves_morphisms (λ α F a, begin
   have [ident w] [] [":=", expr h {j | «expr = »(F j, F j₀)} rfl (λ
     _ _ f, by simp [] [] [] ["[", expr a f, "]"] [] [])],
   dsimp [] [] [] ["at", ident w],
   intros [ident j, ident j'],
   rw ["[", expr w j, ",", expr w j', "]"] []
 end)

/--
Another induction principle for `is_preconnected J`:
given a type family `Z : J → Sort*` and
a rule for transporting in *both* directions along a morphism in `J`,
we can transport an `x : Z j₀` to a point in `Z j` for any `j`.
-/
theorem is_preconnected_induction [is_preconnected J] (Z : J → Sort _) (h₁ : ∀ {j₁ j₂ : J} (f : j₁ ⟶ j₂), Z j₁ → Z j₂)
  (h₂ : ∀ {j₁ j₂ : J} (f : j₁ ⟶ j₂), Z j₂ → Z j₁) {j₀ : J} (x : Z j₀) (j : J) : Nonempty (Z j) :=
  (induct_on_objects { j | Nonempty (Z j) } ⟨x⟩
    (fun j₁ j₂ f =>
      ⟨by 
          rintro ⟨y⟩
          exact ⟨h₁ f y⟩,
        by 
          rintro ⟨y⟩
          exact ⟨h₂ f y⟩⟩)
    j :
  _)

/-- If `J` and `K` are equivalent, then if `J` is preconnected then `K` is as well. -/
theorem is_preconnected_of_equivalent {K : Type u₁} [category.{v₂} K] [is_preconnected J] (e : J ≌ K) :
  is_preconnected K :=
  { iso_constant :=
      fun α F k =>
        ⟨calc F ≅ e.inverse ⋙ e.functor ⋙ F := (e.inv_fun_id_assoc F).symm 
            _ ≅ e.inverse ⋙ (Functor.Const J).obj ((e.functor ⋙ F).obj (e.inverse.obj k)) :=
            iso_whisker_left e.inverse (iso_constant (e.functor ⋙ F) (e.inverse.obj k))
            _ ≅ e.inverse ⋙ (Functor.Const J).obj (F.obj k) :=
            iso_whisker_left _ ((F ⋙ Functor.Const J).mapIso (e.counit_iso.app k))
            _ ≅ (Functor.Const K).obj (F.obj k) :=
            nat_iso.of_components (fun X => iso.refl _)
              (by 
                simp )
            ⟩ }

/-- If `J` and `K` are equivalent, then if `J` is connected then `K` is as well. -/
theorem is_connected_of_equivalent {K : Type u₁} [category.{v₂} K] (e : J ≌ K) [is_connected J] : is_connected K :=
  { is_nonempty :=
      Nonempty.map e.functor.obj
        (by 
          infer_instance),
    to_is_preconnected := is_preconnected_of_equivalent e }

/-- If `J` is preconnected, then `Jᵒᵖ` is preconnected as well. -/
instance is_preconnected_op [is_preconnected J] : is_preconnected («expr ᵒᵖ» J) :=
  { iso_constant :=
      fun α F X =>
        ⟨nat_iso.of_components
            (fun Y =>
              (Nonempty.some$ is_preconnected.iso_constant (F.right_op ⋙ (discrete.opposite α).Functor) (unop X)).app
                (unop Y))
            fun Y Z f => Subsingleton.elimₓ _ _⟩ }

/-- If `J` is connected, then `Jᵒᵖ` is connected as well. -/
instance is_connected_op [is_connected J] : is_connected («expr ᵒᵖ» J) :=
  { is_nonempty := Nonempty.intro (op (Classical.arbitrary J)) }

theorem is_preconnected_of_is_preconnected_op [is_preconnected («expr ᵒᵖ» J)] : is_preconnected J :=
  is_preconnected_of_equivalent (op_op_equivalence J)

theorem is_connected_of_is_connected_op [is_connected («expr ᵒᵖ» J)] : is_connected J :=
  is_connected_of_equivalent (op_op_equivalence J)

/-- j₁ and j₂ are related by `zag` if there is a morphism between them. -/
@[reducible]
def zag (j₁ j₂ : J) : Prop :=
  Nonempty (j₁ ⟶ j₂) ∨ Nonempty (j₂ ⟶ j₁)

theorem zag_symmetric : Symmetric (@zag J _) :=
  fun j₂ j₁ h => h.swap

/--
`j₁` and `j₂` are related by `zigzag` if there is a chain of
morphisms from `j₁` to `j₂`, with backward morphisms allowed.
-/
@[reducible]
def zigzag : J → J → Prop :=
  Relation.ReflTransGen zag

theorem zigzag_symmetric : Symmetric (@zigzag J _) :=
  Relation.ReflTransGen.symmetric zag_symmetric

theorem zigzag_equivalence : _root_.equivalence (@zigzag J _) :=
  mk_equivalence _ Relation.reflexive_refl_trans_gen zigzag_symmetric Relation.transitive_refl_trans_gen

/--
The setoid given by the equivalence relation `zigzag`. A quotient for this
setoid is a connected component of the category.
-/
def zigzag.setoid (J : Type u₂) [category.{v₁} J] : Setoidₓ J :=
  { R := zigzag, iseqv := zigzag_equivalence }

/--
If there is a zigzag from `j₁` to `j₂`, then there is a zigzag from `F j₁` to
`F j₂` as long as `F` is a functor.
-/
theorem zigzag_obj_of_zigzag (F : J ⥤ K) {j₁ j₂ : J} (h : zigzag j₁ j₂) : zigzag (F.obj j₁) (F.obj j₂) :=
  h.lift _$ fun j k => Or.imp (Nonempty.map fun f => F.map f) (Nonempty.map fun f => F.map f)

theorem zag_of_zag_obj (F : J ⥤ K) [full F] {j₁ j₂ : J} (h : zag (F.obj j₁) (F.obj j₂)) : zag j₁ j₂ :=
  Or.imp (Nonempty.map F.preimage) (Nonempty.map F.preimage) h

-- error in CategoryTheory.IsConnected: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Any equivalence relation containing (⟶) holds for all pairs of a connected category. -/
theorem equiv_relation
[is_connected J]
(r : J → J → exprProp())
(hr : _root_.equivalence r)
(h : ∀ {j₁ j₂ : J} (f : «expr ⟶ »(j₁, j₂)), r j₁ j₂) : ∀ j₁ j₂ : J, r j₁ j₂ :=
begin
  have [ident z] [":", expr ∀
   j : J, r (classical.arbitrary J) j] [":=", expr induct_on_objects (λ
    k, r (classical.arbitrary J) k) (hr.1 (classical.arbitrary J)) (λ
    _ _ f, ⟨λ t, hr.2.2 t (h f), λ t, hr.2.2 t (hr.2.1 (h f))⟩)],
  intros [],
  apply [expr hr.2.2 (hr.2.1 (z _)) (z _)]
end

/-- In a connected category, any two objects are related by `zigzag`. -/
theorem is_connected_zigzag [is_connected J] (j₁ j₂ : J) : zigzag j₁ j₂ :=
  equiv_relation _ zigzag_equivalence (fun _ _ f => Relation.ReflTransGen.single (Or.inl (Nonempty.intro f))) _ _

-- error in CategoryTheory.IsConnected: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
If any two objects in an nonempty category are related by `zigzag`, the category is connected.
-/ theorem zigzag_is_connected [nonempty J] (h : ∀ j₁ j₂ : J, zigzag j₁ j₂) : is_connected J :=
begin
  apply [expr is_connected.of_induct],
  intros [ident p, ident hp, ident hjp, ident j],
  have [] [":", expr ∀ j₁ j₂ : J, zigzag j₁ j₂ → «expr ↔ »(«expr ∈ »(j₁, p), «expr ∈ »(j₂, p))] [],
  { introv [ident k],
    induction [expr k] [] ["with", "_", "_", ident rt_zag, ident zag] [],
    { refl },
    { rw [expr k_ih] [],
      rcases [expr zag, "with", "⟨", "⟨", "_", "⟩", "⟩", "|", "⟨", "⟨", "_", "⟩", "⟩"],
      apply [expr hjp zag],
      apply [expr (hjp zag).symm] } },
  rwa [expr this j (classical.arbitrary J) (h _ _)] []
end

theorem exists_zigzag' [is_connected J] (j₁ j₂ : J) :
  ∃ l, List.Chain zag j₁ l ∧ List.last (j₁ :: l) (List.cons_ne_nil _ _) = j₂ :=
  List.exists_chain_of_relation_refl_trans_gen (is_connected_zigzag _ _)

/--
If any two objects in an nonempty category are linked by a sequence of (potentially reversed)
morphisms, then J is connected.

The converse of `exists_zigzag'`.
-/
theorem is_connected_of_zigzag [Nonempty J]
  (h : ∀ (j₁ j₂ : J), ∃ l, List.Chain zag j₁ l ∧ List.last (j₁ :: l) (List.cons_ne_nil _ _) = j₂) : is_connected J :=
  by 
    apply zigzag_is_connected 
    intro j₁ j₂ 
    rcases h j₁ j₂ with ⟨l, hl₁, hl₂⟩
    apply List.relation_refl_trans_gen_of_exists_chain l hl₁ hl₂

/-- If `discrete α` is connected, then `α` is (type-)equivalent to `punit`. -/
def discrete_is_connected_equiv_punit {α : Type u₁} [is_connected (discrete α)] : α ≃ PUnit :=
  discrete.equiv_of_equivalence
    { Functor := functor.star α, inverse := discrete.functor fun _ => Classical.arbitrary _,
      unitIso :=
        by 
          exact iso_constant _ (Classical.arbitrary _),
      counitIso := functor.punit_ext _ _ }

variable{C : Type u₂}[category.{u₁} C]

-- error in CategoryTheory.IsConnected: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
For objects `X Y : C`, any natural transformation `α : const X ⟶ const Y` from a connected
category must be constant.
This is the key property of connected categories which we use to establish properties about limits.
-/
theorem nat_trans_from_is_connected
[is_preconnected J]
{X Y : C}
(α : «expr ⟶ »((functor.const J).obj X, (functor.const J).obj Y)) : ∀
j j' : J, «expr = »(α.app j, (α.app j' : «expr ⟶ »(X, Y))) :=
@constant_of_preserves_morphisms _ _ _ «expr ⟶ »(X, Y) (λ
 j, α.app j) (λ _ _ f, by { have [] [] [":=", expr α.naturality f],
   erw ["[", expr id_comp, ",", expr comp_id, "]"] ["at", ident this],
   exact [expr this.symm] })

instance  [is_connected J] : full (Functor.Const J : C ⥤ J ⥤ C) :=
  { Preimage := fun X Y f => f.app (Classical.arbitrary J),
    witness' :=
      fun X Y f =>
        by 
          ext j 
          apply nat_trans_from_is_connected f (Classical.arbitrary J) j }

instance nonempty_hom_of_connected_groupoid {G} [groupoid G] [is_connected G] : ∀ (x y : G), Nonempty (x ⟶ y) :=
  by 
    refine' equiv_relation _ _ fun j₁ j₂ => Nonempty.intro 
    exact ⟨fun j => ⟨𝟙 _⟩, fun j₁ j₂ => Nonempty.map fun f => inv f, fun _ _ _ => Nonempty.map2 (· ≫ ·)⟩

end CategoryTheory

