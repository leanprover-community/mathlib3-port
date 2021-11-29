import Mathbin.CategoryTheory.FinCategory 
import Mathbin.CategoryTheory.Limits.Cones 
import Mathbin.CategoryTheory.Adjunction.Basic 
import Mathbin.CategoryTheory.Category.Preorder 
import Mathbin.Order.BoundedOrder

/-!
# Filtered categories

A category is filtered if every finite diagram admits a cocone.
We give a simple characterisation of this condition as
1. for every pair of objects there exists another object "to the right",
2. for every pair of parallel morphisms there exists a morphism to the right so the compositions
   are equal, and
3. there exists some object.

Filtered colimits are often better behaved than arbitrary colimits.
See `category_theory/limits/types` for some details.

Filtered categories are nice because colimits indexed by filtered categories tend to be
easier to describe than general colimits (and more often preserved by functors).

In this file we show that any functor from a finite category to a filtered category admits a cocone:
* `cocone_nonempty [fin_category J] [is_filtered C] (F : J ⥤ C) : nonempty (cocone F)`
More generally,
for any finite collection of objects and morphisms between them in a filtered category
(even if not closed under composition) there exists some object `Z` receiving maps from all of them,
so that all the triangles (one edge from the finite set, two from morphisms to `Z`) commute.
This formulation is often more useful in practice and is available via `sup_exists`,
which takes a finset of objects, and an indexed family (indexed by source and target)
of finsets of morphisms.

Furthermore, we give special support for two diagram categories: The `bowtie` and the `tulip`.
This is because these shapes show up in the proofs that forgetful functors of algebraic categories
(e.g. `Mon`, `CommRing`, ...) preserve filtered colimits.

All of the above API, except for the `bowtie` and the `tulip`, is also provided for cofiltered
categories.

## See also
In `category_theory.limits.filtered_colimit_commutes_finite_limit` we show that filtered colimits
commute with finite limits.

-/


universe v v₁ u u₁

namespace CategoryTheory

variable(C : Type u)[category.{v} C]

/--
A category `is_filtered_or_empty` if
1. for every pair of objects there exists another object "to the right", and
2. for every pair of parallel morphisms there exists a morphism to the right so the compositions
   are equal.
-/
class is_filtered_or_empty : Prop where 
  cocone_objs : ∀ (X Y : C), ∃ (Z : _)(f : X ⟶ Z)(g : Y ⟶ Z), True 
  cocone_maps : ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), ∃ (Z : _)(h : Y ⟶ Z), f ≫ h = g ≫ h

/--
A category `is_filtered` if
1. for every pair of objects there exists another object "to the right",
2. for every pair of parallel morphisms there exists a morphism to the right so the compositions
   are equal, and
3. there exists some object.

See https://stacks.math.columbia.edu/tag/002V. (They also define a diagram being filtered.)
-/
class is_filtered extends is_filtered_or_empty C : Prop where 
  [Nonempty : Nonempty C]

instance (priority := 100)is_filtered_or_empty_of_semilattice_sup (α : Type u) [SemilatticeSup α] :
  is_filtered_or_empty α :=
  { cocone_objs := fun X Y => ⟨X⊔Y, hom_of_le le_sup_left, hom_of_le le_sup_right, trivialₓ⟩,
    cocone_maps :=
      fun X Y f g =>
        ⟨Y, 𝟙 _,
          by 
            ext⟩ }

instance (priority := 100)is_filtered_of_semilattice_sup_nonempty (α : Type u) [SemilatticeSup α] [Nonempty α] :
  is_filtered α :=
  {  }

instance (priority := 100)is_filtered_or_empty_of_directed_order (α : Type u) [DirectedOrder α] :
  is_filtered_or_empty α :=
  { cocone_objs :=
      fun X Y =>
        let ⟨Z, h1, h2⟩ := DirectedOrder.directed X Y
        ⟨Z, hom_of_le h1, hom_of_le h2, trivialₓ⟩,
    cocone_maps :=
      fun X Y f g =>
        ⟨Y, 𝟙 _,
          by 
            simp ⟩ }

instance (priority := 100)is_filtered_of_directed_order_nonempty (α : Type u) [DirectedOrder α] [Nonempty α] :
  is_filtered α :=
  {  }

example  (α : Type u) [SemilatticeSup α] [OrderBot α] : is_filtered α :=
  by 
    infer_instance

example  (α : Type u) [SemilatticeSup α] [OrderTop α] : is_filtered α :=
  by 
    infer_instance

namespace IsFiltered

variable{C}[is_filtered C]

/--
`max j j'` is an arbitrary choice of object to the right of both `j` and `j'`,
whose existence is ensured by `is_filtered`.
-/
noncomputable def max (j j' : C) : C :=
  (is_filtered_or_empty.cocone_objs j j').some

/--
`left_to_max j j'` is an arbitrarily choice of morphism from `j` to `max j j'`,
whose existence is ensured by `is_filtered`.
-/
noncomputable def left_to_max (j j' : C) : j ⟶ max j j' :=
  (is_filtered_or_empty.cocone_objs j j').some_spec.some

/--
`right_to_max j j'` is an arbitrarily choice of morphism from `j'` to `max j j'`,
whose existence is ensured by `is_filtered`.
-/
noncomputable def right_to_max (j j' : C) : j' ⟶ max j j' :=
  (is_filtered_or_empty.cocone_objs j j').some_spec.some_spec.some

/--
`coeq f f'`, for morphisms `f f' : j ⟶ j'`, is an arbitrary choice of object
which admits a morphism `coeq_hom f f' : j' ⟶ coeq f f'` such that
`coeq_condition : f ≫ coeq_hom f f' = f' ≫ coeq_hom f f'`.
Its existence is ensured by `is_filtered`.
-/
noncomputable def coeq {j j' : C} (f f' : j ⟶ j') : C :=
  (is_filtered_or_empty.cocone_maps f f').some

/--
`coeq_hom f f'`, for morphisms `f f' : j ⟶ j'`, is an arbitrary choice of morphism
`coeq_hom f f' : j' ⟶ coeq f f'` such that
`coeq_condition : f ≫ coeq_hom f f' = f' ≫ coeq_hom f f'`.
Its existence is ensured by `is_filtered`.
-/
noncomputable def coeq_hom {j j' : C} (f f' : j ⟶ j') : j' ⟶ coeq f f' :=
  (is_filtered_or_empty.cocone_maps f f').some_spec.some

/--
`coeq_condition f f'`, for morphisms `f f' : j ⟶ j'`, is the proof that
`f ≫ coeq_hom f f' = f' ≫ coeq_hom f f'`.
-/
@[simp, reassoc]
theorem coeq_condition {j j' : C} (f f' : j ⟶ j') : f ≫ coeq_hom f f' = f' ≫ coeq_hom f f' :=
  (is_filtered_or_empty.cocone_maps f f').some_spec.some_spec

open CategoryTheory.Limits

/--
Any finite collection of objects in a filtered category has an object "to the right".
-/
theorem sup_objs_exists (O : Finset C) : ∃ S : C, ∀ {X}, X ∈ O → _root_.nonempty (X ⟶ S) :=
  by 
    classical 
    apply Finset.induction_on O
    ·
      exact
        ⟨is_filtered.nonempty.some,
          by 
            rintro - ⟨⟩⟩
    ·
      rintro X O' nm ⟨S', w'⟩
      use max X S' 
      rintro Y mY 
      obtain rfl | h := eq_or_ne Y X
      ·
        exact ⟨left_to_max _ _⟩
      ·
        exact ⟨(w' (Finset.mem_of_mem_insert_of_ne mY h)).some ≫ right_to_max _ _⟩

variable(O : Finset C)(H : Finset (Σ'(X Y : C)(mX : X ∈ O)(mY : Y ∈ O), X ⟶ Y))

/--
Given any `finset` of objects `{X, ...}` and
indexed collection of `finset`s of morphisms `{f, ...}` in `C`,
there exists an object `S`, with a morphism `T X : X ⟶ S` from each `X`,
such that the triangles commute: `f ≫ T Y = T X`, for `f : X ⟶ Y` in the `finset`.
-/
theorem sup_exists :
  ∃ (S : C)(T : ∀ {X : C}, X ∈ O → (X ⟶ S)),
    ∀ {X Y : C} (mX : X ∈ O) (mY : Y ∈ O) {f : X ⟶ Y},
      (⟨X, Y, mX, mY, f⟩ : Σ'(X Y : C)(mX : X ∈ O)(mY : Y ∈ O), X ⟶ Y) ∈ H → f ≫ T mY = T mX :=
  by 
    classical 
    apply Finset.induction_on H
    ·
      obtain ⟨S, f⟩ := sup_objs_exists O 
      refine' ⟨S, fun X mX => (f mX).some, _⟩
      rintro - - - - - ⟨⟩
    ·
      rintro ⟨X, Y, mX, mY, f⟩ H' nmf ⟨S', T', w'⟩
      refine' ⟨coeq (f ≫ T' mY) (T' mX), fun Z mZ => T' mZ ≫ coeq_hom (f ≫ T' mY) (T' mX), _⟩
      intro X' Y' mX' mY' f' mf' 
      rw [←category.assoc]
      byCases' h : X = X' ∧ Y = Y'
      ·
        rcases h with ⟨rfl, rfl⟩
        byCases' hf : f = f'
        ·
          subst hf 
          apply coeq_condition
        ·
          rw
            [@w' _ _ mX mY f'
              (by 
                simpa [hf ∘ Eq.symm] using mf')]
      ·
        rw
          [@w' _ _ mX' mY' f'
            (by 
              finish)]

/--
An arbitrary choice of object "to the right"
of a finite collection of objects `O` and morphisms `H`,
making all the triangles commute.
-/
noncomputable def sup : C :=
  (sup_exists O H).some

/--
The morphisms to `sup O H`.
-/
noncomputable def to_sup {X : C} (m : X ∈ O) : X ⟶ sup O H :=
  (sup_exists O H).some_spec.some m

/--
The triangles of consisting of a morphism in `H` and the maps to `sup O H` commute.
-/
theorem to_sup_commutes {X Y : C} (mX : X ∈ O) (mY : Y ∈ O) {f : X ⟶ Y}
  (mf : (⟨X, Y, mX, mY, f⟩ : Σ'(X Y : C)(mX : X ∈ O)(mY : Y ∈ O), X ⟶ Y) ∈ H) : f ≫ to_sup O H mY = to_sup O H mX :=
  (sup_exists O H).some_spec.some_spec mX mY mf

variable{J : Type v}[small_category J][fin_category J]

-- error in CategoryTheory.Filtered: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/--
If we have `is_filtered C`, then for any functor `F : J ⥤ C` with `fin_category J`,
there exists a cocone over `F`.
-/ theorem cocone_nonempty (F : «expr ⥤ »(J, C)) : _root_.nonempty (cocone F) :=
begin
  classical,
  let [ident O] [] [":=", expr finset.univ.image F.obj],
  let [ident H] [":", expr finset «exprΣ' , »((X Y : C)
    (mX : «expr ∈ »(X, O))
    (mY : «expr ∈ »(Y, O)), «expr ⟶ »(X, Y))] [":=", expr finset.univ.bUnion (λ
    X : J, finset.univ.bUnion (λ
     Y : J, finset.univ.image (λ
      f : «expr ⟶ »(X, Y), ⟨F.obj X, F.obj Y, by simp [] [] [] [] [] [], by simp [] [] [] [] [] [], F.map f⟩)))],
  obtain ["⟨", ident Z, ",", ident f, ",", ident w, "⟩", ":=", expr sup_exists O H],
  refine [expr ⟨⟨Z, ⟨λ X, f (by simp [] [] [] [] [] []), _⟩⟩⟩],
  intros [ident j, ident j', ident g],
  dsimp [] [] [] [],
  simp [] [] ["only"] ["[", expr category.comp_id, "]"] [] [],
  apply [expr w],
  simp [] [] ["only"] ["[", expr finset.mem_univ, ",", expr finset.mem_bUnion, ",", expr exists_and_distrib_left, ",", expr exists_prop_of_true, ",", expr finset.mem_image, "]"] [] [],
  exact [expr ⟨j, rfl, j', g, by simp [] [] [] [] [] []⟩]
end

/--
An arbitrary choice of cocone over `F : J ⥤ C`, for `fin_category J` and `is_filtered C`.
-/
noncomputable def cocone (F : J ⥤ C) : cocone F :=
  (cocone_nonempty F).some

variable{D : Type u₁}[category.{v₁} D]

/--
If `C` is filtered, and we have a functor `R : C ⥤ D` with a left adjoint, then `D` is filtered.
-/
theorem of_right_adjoint {L : D ⥤ C} {R : C ⥤ D} (h : L ⊣ R) : is_filtered D :=
  { cocone_objs := fun X Y => ⟨_, h.hom_equiv _ _ (left_to_max _ _), h.hom_equiv _ _ (right_to_max _ _), ⟨⟩⟩,
    cocone_maps :=
      fun X Y f g =>
        ⟨_, h.hom_equiv _ _ (coeq_hom _ _),
          by 
            rw [←h.hom_equiv_naturality_left, ←h.hom_equiv_naturality_left, coeq_condition]⟩,
    Nonempty := is_filtered.nonempty.map R.obj }

/-- If `C` is filtered, and we have a right adjoint functor `R : C ⥤ D`, then `D` is filtered. -/
theorem of_is_right_adjoint (R : C ⥤ D) [is_right_adjoint R] : is_filtered D :=
  of_right_adjoint (adjunction.of_right_adjoint R)

/-- Being filtered is preserved by equivalence of categories. -/
theorem of_equivalence (h : C ≌ D) : is_filtered D :=
  of_right_adjoint h.symm.to_adjunction

section SpecialShapes

/--
`max₃ j₁ j₂ j₃` is an arbitrary choice of object to the right of `j₁`, `j₂` and `j₃`,
whose existence is ensured by `is_filtered`.
-/
noncomputable def max₃ (j₁ j₂ j₃ : C) : C :=
  max (max j₁ j₂) j₃

/--
`first_to_max₃ j₁ j₂ j₃` is an arbitrarily choice of morphism from `j₁` to `max₃ j₁ j₂ j₃`,
whose existence is ensured by `is_filtered`.
-/
noncomputable def first_to_max₃ (j₁ j₂ j₃ : C) : j₁ ⟶ max₃ j₁ j₂ j₃ :=
  left_to_max j₁ j₂ ≫ left_to_max (max j₁ j₂) j₃

/--
`second_to_max₃ j₁ j₂ j₃` is an arbitrarily choice of morphism from `j₂` to `max₃ j₁ j₂ j₃`,
whose existence is ensured by `is_filtered`.
-/
noncomputable def second_to_max₃ (j₁ j₂ j₃ : C) : j₂ ⟶ max₃ j₁ j₂ j₃ :=
  right_to_max j₁ j₂ ≫ left_to_max (max j₁ j₂) j₃

/--
`third_to_max₃ j₁ j₂ j₃` is an arbitrarily choice of morphism from `j₃` to `max₃ j₁ j₂ j₃`,
whose existence is ensured by `is_filtered`.
-/
noncomputable def third_to_max₃ (j₁ j₂ j₃ : C) : j₃ ⟶ max₃ j₁ j₂ j₃ :=
  right_to_max (max j₁ j₂) j₃

/--
`coeq₃ f g h`, for morphisms `f g h : j₁ ⟶ j₂`, is an arbitrary choice of object
which admits a morphism `coeq₃_hom f g h : j₂ ⟶ coeq₃ f g h` such that
`coeq₃_condition₁`, `coeq₃_condition₂` and `coeq₃_condition₃` are satisfied.
Its existence is ensured by `is_filtered`.
-/
noncomputable def coeq₃ {j₁ j₂ : C} (f g h : j₁ ⟶ j₂) : C :=
  coeq (coeq_hom f g ≫ left_to_max (coeq f g) (coeq g h)) (coeq_hom g h ≫ right_to_max (coeq f g) (coeq g h))

/--
`coeq₃_hom f g h`, for morphisms `f g h : j₁ ⟶ j₂`, is an arbitrary choice of morphism
`j₂ ⟶ coeq₃ f g h` such that `coeq₃_condition₁`, `coeq₃_condition₂` and `coeq₃_condition₃`
are satisfied. Its existence is ensured by `is_filtered`.
-/
noncomputable def coeq₃_hom {j₁ j₂ : C} (f g h : j₁ ⟶ j₂) : j₂ ⟶ coeq₃ f g h :=
  coeq_hom f g ≫
    left_to_max (coeq f g) (coeq g h) ≫
      coeq_hom (coeq_hom f g ≫ left_to_max (coeq f g) (coeq g h)) (coeq_hom g h ≫ right_to_max (coeq f g) (coeq g h))

theorem coeq₃_condition₁ {j₁ j₂ : C} (f g h : j₁ ⟶ j₂) : f ≫ coeq₃_hom f g h = g ≫ coeq₃_hom f g h :=
  by 
    dsimp [coeq₃_hom]
    sliceLHS 1 2 => rw [coeq_condition f g]
    simp only [category.assoc]

theorem coeq₃_condition₂ {j₁ j₂ : C} (f g h : j₁ ⟶ j₂) : g ≫ coeq₃_hom f g h = h ≫ coeq₃_hom f g h :=
  by 
    dsimp [coeq₃_hom]
    sliceLHS 2 4 => rw [←category.assoc, coeq_condition _ _]
    sliceRHS 2 4 => rw [←category.assoc, coeq_condition _ _]
    sliceLHS 1 3 => rw [←category.assoc, coeq_condition _ _]
    simp only [category.assoc]

theorem coeq₃_condition₃ {j₁ j₂ : C} (f g h : j₁ ⟶ j₂) : f ≫ coeq₃_hom f g h = h ≫ coeq₃_hom f g h :=
  Eq.trans (coeq₃_condition₁ f g h) (coeq₃_condition₂ f g h)

/--
Given a "bowtie" of morphisms
```
 j₁   j₂
 |\  /|
 | \/ |
 | /\ |
 |/  \∣
 vv  vv
 k₁  k₂
```
in a filtered category, we can construct an object `s` and two morphisms from `k₁` and `k₂` to `s`,
making the resulting squares commute.
-/
theorem bowtie {j₁ j₂ k₁ k₂ : C} (f₁ : j₁ ⟶ k₁) (g₁ : j₁ ⟶ k₂) (f₂ : j₂ ⟶ k₁) (g₂ : j₂ ⟶ k₂) :
  ∃ (s : C)(α : k₁ ⟶ s)(β : k₂ ⟶ s), f₁ ≫ α = g₁ ≫ β ∧ f₂ ≫ α = g₂ ≫ β :=
  by 
    let sa := max k₁ k₂ 
    let sb := coeq (f₁ ≫ left_to_max _ _) (g₁ ≫ right_to_max _ _)
    let sc := coeq (f₂ ≫ left_to_max _ _) (g₂ ≫ right_to_max _ _)
    let sd := max sb sc 
    let s := coeq ((coeq_hom _ _ : sa ⟶ sb) ≫ left_to_max _ _) ((coeq_hom _ _ : sa ⟶ sc) ≫ right_to_max _ _)
    use s 
    fsplit 
    exact left_to_max k₁ k₂ ≫ coeq_hom _ _ ≫ left_to_max sb sc ≫ coeq_hom _ _ 
    fsplit 
    exact right_to_max k₁ k₂ ≫ coeq_hom _ _ ≫ right_to_max sb sc ≫ coeq_hom _ _ 
    fsplit
    ·
      sliceLHS 1 3 => rw [←category.assoc, coeq_condition]
      sliceLHS 3 5 => rw [←category.assoc, coeq_condition]
      simp only [category.assoc]
    ·
      sliceLHS 3 5 => rw [←category.assoc, coeq_condition]
      sliceLHS 1 3 => rw [←category.assoc, coeq_condition]
      simp only [category.assoc]

/--
Given a "tulip" of morphisms
```
 j₁    j₂    j₃
 |\   / \   / |
 | \ /   \ /  |
 |  vv    vv  |
 \  k₁    k₂ /
  \         /
   \       /
    \     /
     \   /
      v v
       l
```
in a filtered category, we can construct an object `s` and three morphisms from `k₁`, `k₂` and `l`
to `s`, making the resulting sqaures commute.
-/
theorem tulip {j₁ j₂ j₃ k₁ k₂ l : C} (f₁ : j₁ ⟶ k₁) (f₂ : j₂ ⟶ k₁) (f₃ : j₂ ⟶ k₂) (f₄ : j₃ ⟶ k₂) (g₁ : j₁ ⟶ l)
  (g₂ : j₃ ⟶ l) : ∃ (s : C)(α : k₁ ⟶ s)(β : l ⟶ s)(γ : k₂ ⟶ s), f₁ ≫ α = g₁ ≫ β ∧ f₂ ≫ α = f₃ ≫ γ ∧ f₄ ≫ γ = g₂ ≫ β :=
  by 
    let sa := max₃ k₁ l k₂ 
    let sb := coeq (f₁ ≫ first_to_max₃ k₁ l k₂) (g₁ ≫ second_to_max₃ k₁ l k₂)
    let sc := coeq (f₂ ≫ first_to_max₃ k₁ l k₂) (f₃ ≫ third_to_max₃ k₁ l k₂)
    let sd := coeq (f₄ ≫ third_to_max₃ k₁ l k₂) (g₂ ≫ second_to_max₃ k₁ l k₂)
    let se := max₃ sb sc sd 
    let sf :=
      coeq₃ (coeq_hom _ _ ≫ first_to_max₃ sb sc sd) (coeq_hom _ _ ≫ second_to_max₃ sb sc sd)
        (coeq_hom _ _ ≫ third_to_max₃ sb sc sd)
    use sf 
    use first_to_max₃ k₁ l k₂ ≫ coeq_hom _ _ ≫ first_to_max₃ sb sc sd ≫ coeq₃_hom _ _ _ 
    use second_to_max₃ k₁ l k₂ ≫ coeq_hom _ _ ≫ second_to_max₃ sb sc sd ≫ coeq₃_hom _ _ _ 
    use third_to_max₃ k₁ l k₂ ≫ coeq_hom _ _ ≫ third_to_max₃ sb sc sd ≫ coeq₃_hom _ _ _ 
    fsplit 
    sliceLHS 1 3 => rw [←category.assoc, coeq_condition]
    sliceLHS 3 6 => rw [←category.assoc, coeq₃_condition₁]
    simp only [category.assoc]
    fsplit 
    sliceLHS 3 6 => rw [←category.assoc, coeq₃_condition₁]
    sliceLHS 1 3 => rw [←category.assoc, coeq_condition]
    sliceRHS 3 6 => rw [←category.assoc, ←coeq₃_condition₂]
    simp only [category.assoc]
    sliceRHS 3 6 => rw [←category.assoc, coeq₃_condition₂]
    sliceRHS 1 3 => rw [←category.assoc, ←coeq_condition]
    simp only [category.assoc]

end SpecialShapes

end IsFiltered

/--
A category `is_cofiltered_or_empty` if
1. for every pair of objects there exists another object "to the left", and
2. for every pair of parallel morphisms there exists a morphism to the left so the compositions
   are equal.
-/
class is_cofiltered_or_empty : Prop where 
  cocone_objs : ∀ (X Y : C), ∃ (W : _)(f : W ⟶ X)(g : W ⟶ Y), True 
  cocone_maps : ∀ ⦃X Y : C⦄ (f g : X ⟶ Y), ∃ (W : _)(h : W ⟶ X), h ≫ f = h ≫ g

/--
A category `is_cofiltered` if
1. for every pair of objects there exists another object "to the left",
2. for every pair of parallel morphisms there exists a morphism to the left so the compositions
   are equal, and
3. there exists some object.

See https://stacks.math.columbia.edu/tag/04AZ.
-/
class is_cofiltered extends is_cofiltered_or_empty C : Prop where 
  [Nonempty : Nonempty C]

instance (priority := 100)is_cofiltered_or_empty_of_semilattice_inf (α : Type u) [SemilatticeInf α] :
  is_cofiltered_or_empty α :=
  { cocone_objs := fun X Y => ⟨X⊓Y, hom_of_le inf_le_left, hom_of_le inf_le_right, trivialₓ⟩,
    cocone_maps :=
      fun X Y f g =>
        ⟨X, 𝟙 _,
          by 
            ext⟩ }

instance (priority := 100)is_cofiltered_of_semilattice_inf_nonempty (α : Type u) [SemilatticeInf α] [Nonempty α] :
  is_cofiltered α :=
  {  }

example  (α : Type u) [SemilatticeInf α] [OrderBot α] : is_cofiltered α :=
  by 
    infer_instance

example  (α : Type u) [SemilatticeInf α] [OrderTop α] : is_cofiltered α :=
  by 
    infer_instance

namespace IsCofiltered

variable{C}[is_cofiltered C]

/--
`min j j'` is an arbitrary choice of object to the left of both `j` and `j'`,
whose existence is ensured by `is_cofiltered`.
-/
noncomputable def min (j j' : C) : C :=
  (is_cofiltered_or_empty.cocone_objs j j').some

/--
`min_to_left j j'` is an arbitrarily choice of morphism from `min j j'` to `j`,
whose existence is ensured by `is_cofiltered`.
-/
noncomputable def min_to_left (j j' : C) : min j j' ⟶ j :=
  (is_cofiltered_or_empty.cocone_objs j j').some_spec.some

/--
`min_to_right j j'` is an arbitrarily choice of morphism from `min j j'` to `j'`,
whose existence is ensured by `is_cofiltered`.
-/
noncomputable def min_to_right (j j' : C) : min j j' ⟶ j' :=
  (is_cofiltered_or_empty.cocone_objs j j').some_spec.some_spec.some

/--
`eq f f'`, for morphisms `f f' : j ⟶ j'`, is an arbitrary choice of object
which admits a morphism `eq_hom f f' : eq f f' ⟶ j` such that
`eq_condition : eq_hom f f' ≫ f = eq_hom f f' ≫ f'`.
Its existence is ensured by `is_cofiltered`.
-/
noncomputable def Eq {j j' : C} (f f' : j ⟶ j') : C :=
  (is_cofiltered_or_empty.cocone_maps f f').some

/--
`eq_hom f f'`, for morphisms `f f' : j ⟶ j'`, is an arbitrary choice of morphism
`eq_hom f f' : eq f f' ⟶ j` such that
`eq_condition : eq_hom f f' ≫ f = eq_hom f f' ≫ f'`.
Its existence is ensured by `is_cofiltered`.
-/
noncomputable def eq_hom {j j' : C} (f f' : j ⟶ j') : Eq f f' ⟶ j :=
  (is_cofiltered_or_empty.cocone_maps f f').some_spec.some

/--
`eq_condition f f'`, for morphisms `f f' : j ⟶ j'`, is the proof that
`eq_hom f f' ≫ f = eq_hom f f' ≫ f'`.
-/
@[simp, reassoc]
theorem eq_condition {j j' : C} (f f' : j ⟶ j') : eq_hom f f' ≫ f = eq_hom f f' ≫ f' :=
  (is_cofiltered_or_empty.cocone_maps f f').some_spec.some_spec

open CategoryTheory.Limits

/--
Any finite collection of objects in a cofiltered category has an object "to the left".
-/
theorem inf_objs_exists (O : Finset C) : ∃ S : C, ∀ {X}, X ∈ O → _root_.nonempty (S ⟶ X) :=
  by 
    classical 
    apply Finset.induction_on O
    ·
      exact
        ⟨is_cofiltered.nonempty.some,
          by 
            rintro - ⟨⟩⟩
    ·
      rintro X O' nm ⟨S', w'⟩
      use min X S' 
      rintro Y mY 
      obtain rfl | h := eq_or_ne Y X
      ·
        exact ⟨min_to_left _ _⟩
      ·
        exact ⟨min_to_right _ _ ≫ (w' (Finset.mem_of_mem_insert_of_ne mY h)).some⟩

variable(O : Finset C)(H : Finset (Σ'(X Y : C)(mX : X ∈ O)(mY : Y ∈ O), X ⟶ Y))

/--
Given any `finset` of objects `{X, ...}` and
indexed collection of `finset`s of morphisms `{f, ...}` in `C`,
there exists an object `S`, with a morphism `T X : S ⟶ X` from each `X`,
such that the triangles commute: `T X ≫ f = T Y`, for `f : X ⟶ Y` in the `finset`.
-/
theorem inf_exists :
  ∃ (S : C)(T : ∀ {X : C}, X ∈ O → (S ⟶ X)),
    ∀ {X Y : C} (mX : X ∈ O) (mY : Y ∈ O) {f : X ⟶ Y},
      (⟨X, Y, mX, mY, f⟩ : Σ'(X Y : C)(mX : X ∈ O)(mY : Y ∈ O), X ⟶ Y) ∈ H → T mX ≫ f = T mY :=
  by 
    classical 
    apply Finset.induction_on H
    ·
      obtain ⟨S, f⟩ := inf_objs_exists O 
      refine' ⟨S, fun X mX => (f mX).some, _⟩
      rintro - - - - - ⟨⟩
    ·
      rintro ⟨X, Y, mX, mY, f⟩ H' nmf ⟨S', T', w'⟩
      refine' ⟨Eq (T' mX ≫ f) (T' mY), fun Z mZ => eq_hom (T' mX ≫ f) (T' mY) ≫ T' mZ, _⟩
      intro X' Y' mX' mY' f' mf' 
      rw [category.assoc]
      byCases' h : X = X' ∧ Y = Y'
      ·
        rcases h with ⟨rfl, rfl⟩
        byCases' hf : f = f'
        ·
          subst hf 
          apply eq_condition
        ·
          rw
            [@w' _ _ mX mY f'
              (by 
                simpa [hf ∘ Eq.symm] using mf')]
      ·
        rw
          [@w' _ _ mX' mY' f'
            (by 
              finish)]

/--
An arbitrary choice of object "to the left"
of a finite collection of objects `O` and morphisms `H`,
making all the triangles commute.
-/
noncomputable def inf : C :=
  (inf_exists O H).some

/--
The morphisms from `inf O H`.
-/
noncomputable def inf_to {X : C} (m : X ∈ O) : inf O H ⟶ X :=
  (inf_exists O H).some_spec.some m

/--
The triangles consisting of a morphism in `H` and the maps from `inf O H` commute.
-/
theorem inf_to_commutes {X Y : C} (mX : X ∈ O) (mY : Y ∈ O) {f : X ⟶ Y}
  (mf : (⟨X, Y, mX, mY, f⟩ : Σ'(X Y : C)(mX : X ∈ O)(mY : Y ∈ O), X ⟶ Y) ∈ H) : inf_to O H mX ≫ f = inf_to O H mY :=
  (inf_exists O H).some_spec.some_spec mX mY mf

variable{J : Type v}[small_category J][fin_category J]

-- error in CategoryTheory.Filtered: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/--
If we have `is_cofiltered C`, then for any functor `F : J ⥤ C` with `fin_category J`,
there exists a cone over `F`.
-/ theorem cone_nonempty (F : «expr ⥤ »(J, C)) : _root_.nonempty (cone F) :=
begin
  classical,
  let [ident O] [] [":=", expr finset.univ.image F.obj],
  let [ident H] [":", expr finset «exprΣ' , »((X Y : C)
    (mX : «expr ∈ »(X, O))
    (mY : «expr ∈ »(Y, O)), «expr ⟶ »(X, Y))] [":=", expr finset.univ.bUnion (λ
    X : J, finset.univ.bUnion (λ
     Y : J, finset.univ.image (λ
      f : «expr ⟶ »(X, Y), ⟨F.obj X, F.obj Y, by simp [] [] [] [] [] [], by simp [] [] [] [] [] [], F.map f⟩)))],
  obtain ["⟨", ident Z, ",", ident f, ",", ident w, "⟩", ":=", expr inf_exists O H],
  refine [expr ⟨⟨Z, ⟨λ X, f (by simp [] [] [] [] [] []), _⟩⟩⟩],
  intros [ident j, ident j', ident g],
  dsimp [] [] [] [],
  simp [] [] ["only"] ["[", expr category.id_comp, "]"] [] [],
  symmetry,
  apply [expr w],
  simp [] [] ["only"] ["[", expr finset.mem_univ, ",", expr finset.mem_bUnion, ",", expr exists_and_distrib_left, ",", expr exists_prop_of_true, ",", expr finset.mem_image, "]"] [] [],
  exact [expr ⟨j, rfl, j', g, by simp [] [] [] [] [] []⟩]
end

/--
An arbitrary choice of cone over `F : J ⥤ C`, for `fin_category J` and `is_cofiltered C`.
-/
noncomputable def cone (F : J ⥤ C) : cone F :=
  (cone_nonempty F).some

variable{D : Type u₁}[category.{v₁} D]

/--
If `C` is cofiltered, and we have a functor `L : C ⥤ D` with a right adjoint,
then `D` is cofiltered.
-/
theorem of_left_adjoint {L : C ⥤ D} {R : D ⥤ C} (h : L ⊣ R) : is_cofiltered D :=
  { cocone_objs :=
      fun X Y =>
        ⟨L.obj (min (R.obj X) (R.obj Y)), (h.hom_equiv _ X).symm (min_to_left _ _),
          (h.hom_equiv _ Y).symm (min_to_right _ _), ⟨⟩⟩,
    cocone_maps :=
      fun X Y f g =>
        ⟨L.obj (Eq (R.map f) (R.map g)), (h.hom_equiv _ _).symm (eq_hom _ _),
          by 
            rw [←h.hom_equiv_naturality_right_symm, ←h.hom_equiv_naturality_right_symm, eq_condition]⟩,
    Nonempty := is_cofiltered.nonempty.map L.obj }

/-- If `C` is cofiltered, and we have a left adjoint functor `L : C ⥤ D`, then `D` is cofiltered. -/
theorem of_is_left_adjoint (L : C ⥤ D) [is_left_adjoint L] : is_cofiltered D :=
  of_left_adjoint (adjunction.of_left_adjoint L)

/-- Being cofiltered is preserved by equivalence of categories. -/
theorem of_equivalence (h : C ≌ D) : is_cofiltered D :=
  of_left_adjoint h.to_adjunction

end IsCofiltered

section Opposite

open Opposite

instance is_cofiltered_op_of_is_filtered [is_filtered C] : is_cofiltered («expr ᵒᵖ» C) :=
  { cocone_objs :=
      fun X Y =>
        ⟨op (is_filtered.max X.unop Y.unop), (is_filtered.left_to_max _ _).op, (is_filtered.right_to_max _ _).op,
          trivialₓ⟩,
    cocone_maps :=
      fun X Y f g =>
        ⟨op (is_filtered.coeq f.unop g.unop), (is_filtered.coeq_hom _ _).op,
          by 
            rw
              [show f = f.unop.op by 
                simp ,
              show g = g.unop.op by 
                simp ,
              ←op_comp, ←op_comp]
            congr 1 
            exact is_filtered.coeq_condition f.unop g.unop⟩,
    Nonempty := ⟨op is_filtered.nonempty.some⟩ }

instance is_filtered_op_of_is_cofiltered [is_cofiltered C] : is_filtered («expr ᵒᵖ» C) :=
  { cocone_objs :=
      fun X Y =>
        ⟨op (is_cofiltered.min X.unop Y.unop), (is_cofiltered.min_to_left X.unop Y.unop).op,
          (is_cofiltered.min_to_right X.unop Y.unop).op, trivialₓ⟩,
    cocone_maps :=
      fun X Y f g =>
        ⟨op (is_cofiltered.eq f.unop g.unop), (is_cofiltered.eq_hom f.unop g.unop).op,
          by 
            rw
              [show f = f.unop.op by 
                simp ,
              show g = g.unop.op by 
                simp ,
              ←op_comp, ←op_comp]
            congr 1 
            exact is_cofiltered.eq_condition f.unop g.unop⟩,
    Nonempty := ⟨op is_cofiltered.nonempty.some⟩ }

end Opposite

end CategoryTheory

