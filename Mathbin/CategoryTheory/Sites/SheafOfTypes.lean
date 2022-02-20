/-
Copyright (c) 2020 Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta
-/
import Mathbin.CategoryTheory.Sites.Pretopology
import Mathbin.CategoryTheory.Limits.Shapes.Types
import Mathbin.CategoryTheory.FullSubcategory

/-!
# Sheaves of types on a Grothendieck topology

Defines the notion of a sheaf of types (usually called a sheaf of sets by mathematicians)
on a category equipped with a Grothendieck topology, as well as a range of equivalent
conditions useful in different situations.

First define what it means for a presheaf `P : Cᵒᵖ ⥤ Type v` to be a sheaf *for* a particular
presieve `R` on `X`:
* A *family of elements* `x` for `P` at `R` is an element `x_f` of `P Y` for every `f : Y ⟶ X` in
  `R`. See `family_of_elements`.
* The family `x` is *compatible* if, for any `f₁ : Y₁ ⟶ X` and `f₂ : Y₂ ⟶ X` both in `R`,
  and any `g₁ : Z ⟶ Y₁` and `g₂ : Z ⟶ Y₂` such that `g₁ ≫ f₁ = g₂ ≫ f₂`, the restriction of
  `x_f₁` along `g₁` agrees with the restriction of `x_f₂` along `g₂`.
  See `family_of_elements.compatible`.
* An *amalgamation* `t` for the family is an element of `P X` such that for every `f : Y ⟶ X` in
  `R`, the restriction of `t` on `f` is `x_f`.
  See `family_of_elements.is_amalgamation`.
We then say `P` is *separated* for `R` if every compatible family has at most one amalgamation,
and it is a *sheaf* for `R` if every compatible family has a unique amalgamation.
See `is_separated_for` and `is_sheaf_for`.

In the special case where `R` is a sieve, the compatibility condition can be simplified:
* The family `x` is *compatible* if, for any `f : Y ⟶ X` in `R` and `g : Z ⟶ Y`, the restriction of
  `x_f` along `g` agrees with `x_(g ≫ f)` (which is well defined since `g ≫ f` is in `R`).
See `family_of_elements.sieve_compatible` and `compatible_iff_sieve_compatible`.

In the special case where `C` has pullbacks, the compatibility condition can be simplified:
* The family `x` is *compatible* if, for any `f : Y ⟶ X` and `g : Z ⟶ X` both in `R`,
  the restriction of `x_f` along `π₁ : pullback f g ⟶ Y` agrees with the restriction of `x_g`
  along `π₂ : pullback f g ⟶ Z`.
See `family_of_elements.pullback_compatible` and `pullback_compatible_iff`.

Now given a Grothendieck topology `J`, `P` is a sheaf if it is a sheaf for every sieve in the
topology. See `is_sheaf`.

In the case where the topology is generated by a basis, it suffices to check `P` is a sheaf for
every presieve in the pretopology. See `is_sheaf_pretopology`.

We also provide equivalent conditions to satisfy alternate definitions given in the literature.

* Stacks: In `equalizer.presieve.sheaf_condition`, the sheaf condition at a presieve is shown to be
  equivalent to that of https://stacks.math.columbia.edu/tag/00VM (and combined with
  `is_sheaf_pretopology`, this shows the notions of `is_sheaf` are exactly equivalent.)

  The condition of https://stacks.math.columbia.edu/tag/00Z8 is virtually identical to the
  statement of `yoneda_condition_iff_sheaf_condition` (since the bijection described there carries
  the same information as the unique existence.)

* Maclane-Moerdijk [MM92]: Using `compatible_iff_sieve_compatible`, the definitions of `is_sheaf`
  are equivalent. There are also alternate definitions given:
  - Yoneda condition: Defined in `yoneda_sheaf_condition` and equivalence in
    `yoneda_condition_iff_sheaf_condition`.
  - Equalizer condition (Equation 3): Defined in the `equalizer.sieve` namespace, and equivalence
    in `equalizer.sieve.sheaf_condition`.
  - Matching family for presieves with pullback: `pullback_compatible_iff`.
  - Sheaf for a pretopology (Prop 1): `is_sheaf_pretopology` combined with the previous.
  - Sheaf for a pretopology as equalizer (Prop 1, bis): `equalizer.presieve.sheaf_condition`
    combined with the previous.

## Implementation

The sheaf condition is given as a proposition, rather than a subsingleton in `Type (max u₁ v)`.
This doesn't seem to make a big difference, other than making a couple of definitions noncomputable,
but it means that equivalent conditions can be given as `↔` statements rather than `≃` statements,
which can be convenient.

## References

* [MM92]: *Sheaves in geometry and logic*, Saunders MacLane, and Ieke Moerdijk:
  Chapter III, Section 4.
* [Elephant]: *Sketches of an Elephant*, P. T. Johnstone: C2.1.
* https://stacks.math.columbia.edu/tag/00VL (sheaves on a pretopology or site)
* https://stacks.math.columbia.edu/tag/00ZB (sheaves on a topology)

-/


universe w v₁ v₂ u₁ u₂

namespace CategoryTheory

open Opposite CategoryTheory Category Limits Sieve

namespace Presieve

variable {C : Type u₁} [Category.{v₁} C]

variable {P Q U : Cᵒᵖ ⥤ Type w}

variable {X Y : C} {S : Sieve X} {R : Presieve X}

variable (J J₂ : GrothendieckTopology C)

/-- A family of elements for a presheaf `P` given a collection of arrows `R` with fixed codomain `X`
consists of an element of `P Y` for every `f : Y ⟶ X` in `R`.
A presheaf is a sheaf (resp, separated) if every *compatible* family of elements has exactly one
(resp, at most one) amalgamation.

This data is referred to as a `family` in [MM92], Chapter III, Section 4. It is also a concrete
version of the elements of the middle object in https://stacks.math.columbia.edu/tag/00VM which is
more useful for direct calculations. It is also used implicitly in Definition C2.1.2 in [Elephant].
-/
def FamilyOfElements (P : Cᵒᵖ ⥤ Type w) (R : Presieve X) :=
  ∀ ⦃Y : C⦄ f : Y ⟶ X, R f → P.obj (op Y)

instance : Inhabited (FamilyOfElements P (⊥ : Presieve X)) :=
  ⟨fun Y f => False.elim⟩

/-- A family of elements for a presheaf on the presieve `R₂` can be restricted to a smaller presieve
`R₁`.
-/
def FamilyOfElements.restrict {R₁ R₂ : Presieve X} (h : R₁ ≤ R₂) : FamilyOfElements P R₂ → FamilyOfElements P R₁ :=
  fun x Y f hf => x f (h _ hf)

/-- A family of elements for the arrow set `R` is *compatible* if for any `f₁ : Y₁ ⟶ X` and
`f₂ : Y₂ ⟶ X` in `R`, and any `g₁ : Z ⟶ Y₁` and `g₂ : Z ⟶ Y₂`, if the square `g₁ ≫ f₁ = g₂ ≫ f₂`
commutes then the elements of `P Z` obtained by restricting the element of `P Y₁` along `g₁` and
restricting the element of `P Y₂` along `g₂` are the same.

In special cases, this condition can be simplified, see `pullback_compatible_iff` and
`compatible_iff_sieve_compatible`.

This is referred to as a "compatible family" in Definition C2.1.2 of [Elephant], and on nlab:
https://ncatlab.org/nlab/show/sheaf#GeneralDefinitionInComponents
-/
def FamilyOfElements.Compatible (x : FamilyOfElements P R) : Prop :=
  ∀ ⦃Y₁ Y₂ Z⦄ g₁ : Z ⟶ Y₁ g₂ : Z ⟶ Y₂ ⦃f₁ : Y₁ ⟶ X⦄ ⦃f₂ : Y₂ ⟶ X⦄ h₁ : R f₁ h₂ : R f₂,
    g₁ ≫ f₁ = g₂ ≫ f₂ → P.map g₁.op (x f₁ h₁) = P.map g₂.op (x f₂ h₂)

/-- If the category `C` has pullbacks, this is an alternative condition for a family of elements to be
compatible: For any `f : Y ⟶ X` and `g : Z ⟶ X` in the presieve `R`, the restriction of the
given elements for `f` and `g` to the pullback agree.
This is equivalent to being compatible (provided `C` has pullbacks), shown in
`pullback_compatible_iff`.

This is the definition for a "matching" family given in [MM92], Chapter III, Section 4,
Equation (5). Viewing the type `family_of_elements` as the middle object of the fork in
https://stacks.math.columbia.edu/tag/00VM, this condition expresses that `pr₀* (x) = pr₁* (x)`,
using the notation defined there.
-/
def FamilyOfElements.PullbackCompatible (x : FamilyOfElements P R) [HasPullbacks C] : Prop :=
  ∀ ⦃Y₁ Y₂⦄ ⦃f₁ : Y₁ ⟶ X⦄ ⦃f₂ : Y₂ ⟶ X⦄ h₁ : R f₁ h₂ : R f₂,
    P.map (pullback.fst : pullback f₁ f₂ ⟶ _).op (x f₁ h₁) = P.map pullback.snd.op (x f₂ h₂)

theorem pullback_compatible_iff (x : FamilyOfElements P R) [HasPullbacks C] : x.Compatible ↔ x.PullbackCompatible := by
  constructor
  · intro t Y₁ Y₂ f₁ f₂ hf₁ hf₂
    apply t
    apply pullback.condition
    
  · intro t Y₁ Y₂ Z g₁ g₂ f₁ f₂ hf₁ hf₂ comm
    rw [← pullback.lift_fst _ _ comm, op_comp, functor_to_types.map_comp_apply, t hf₁ hf₂, ←
      functor_to_types.map_comp_apply, ← op_comp, pullback.lift_snd]
    

/-- The restriction of a compatible family is compatible. -/
theorem FamilyOfElements.Compatible.restrict {R₁ R₂ : Presieve X} (h : R₁ ≤ R₂) {x : FamilyOfElements P R₂} :
    x.Compatible → (x.restrict h).Compatible := fun q Y₁ Y₂ Z g₁ g₂ f₁ f₂ h₁ h₂ comm => q g₁ g₂ (h _ h₁) (h _ h₂) comm

/-- Extend a family of elements to the sieve generated by an arrow set.
This is the construction described as "easy" in Lemma C2.1.3 of [Elephant].
-/
noncomputable def FamilyOfElements.sieveExtend (x : FamilyOfElements P R) : FamilyOfElements P (generate R) :=
  fun Z f hf => P.map hf.some_spec.some.op (x _ hf.some_spec.some_spec.some_spec.1)

/-- The extension of a compatible family to the generated sieve is compatible. -/
theorem FamilyOfElements.Compatible.sieve_extend {x : FamilyOfElements P R} (hx : x.Compatible) :
    x.sieveExtend.Compatible := by
  intro _ _ _ _ _ _ _ h₁ h₂ comm
  iterate 2 
    erw [← functor_to_types.map_comp_apply]
    rw [← op_comp]
  apply hx
  simp [comm, h₁.some_spec.some_spec.some_spec.2, h₂.some_spec.some_spec.some_spec.2]

/-- The extension of a family agrees with the original family. -/
theorem extend_agrees {x : FamilyOfElements P R} (t : x.Compatible) {f : Y ⟶ X} (hf : R f) :
    x.sieveExtend f (le_generate R Y hf) = x f hf := by
  have h := (le_generate R Y hf).some_spec
  unfold family_of_elements.sieve_extend
  rw [t h.some (𝟙 _) _ hf _]
  · simp
    
  · rw [id_comp]
    exact h.some_spec.some_spec.2
    

/-- The restriction of an extension is the original. -/
@[simp]
theorem restrict_extend {x : FamilyOfElements P R} (t : x.Compatible) : x.sieveExtend.restrict (le_generate R) = x := by
  ext Y f hf
  exact extend_agrees t hf

/-- If the arrow set for a family of elements is actually a sieve (i.e. it is downward closed) then the
consistency condition can be simplified.
This is an equivalent condition, see `compatible_iff_sieve_compatible`.

This is the notion of "matching" given for families on sieves given in [MM92], Chapter III,
Section 4, Equation 1, and nlab: https://ncatlab.org/nlab/show/matching+family.
See also the discussion before Lemma C2.1.4 of [Elephant].
-/
def FamilyOfElements.SieveCompatible (x : FamilyOfElements P S) : Prop :=
  ∀ ⦃Y Z⦄ f : Y ⟶ X g : Z ⟶ Y hf, x (g ≫ f) (S.downward_closed hf g) = P.map g.op (x f hf)

theorem compatible_iff_sieve_compatible (x : FamilyOfElements P S) : x.Compatible ↔ x.SieveCompatible := by
  constructor
  · intro h Y Z f g hf
    simpa using h (𝟙 _) g (S.downward_closed hf g) hf (id_comp _)
    
  · intro h Y₁ Y₂ Z g₁ g₂ f₁ f₂ h₁ h₂ k
    simp_rw [← h f₁ g₁ h₁, k, h f₂ g₂ h₂]
    

theorem FamilyOfElements.Compatible.to_sieve_compatible {x : FamilyOfElements P S} (t : x.Compatible) :
    x.SieveCompatible :=
  (compatible_iff_sieve_compatible x).1 t

/-- Given a family of elements `x` for the sieve `S` generated by a presieve `R`, if `x` is restricted
to `R` and then extended back up to `S`, the resulting extension equals `x`.
-/
@[simp]
theorem extend_restrict {x : FamilyOfElements P (generate R)} (t : x.Compatible) :
    (x.restrict (le_generate R)).sieveExtend = x := by
  rw [compatible_iff_sieve_compatible] at t
  ext _ _ h
  apply (t _ _ _).symm.trans
  congr
  exact h.some_spec.some_spec.some_spec.2

/-- Two compatible families on the sieve generated by a presieve `R` are equal if and only if they are
equal when restricted to `R`.
-/
theorem restrict_inj {x₁ x₂ : FamilyOfElements P (generate R)} (t₁ : x₁.Compatible) (t₂ : x₂.Compatible) :
    x₁.restrict (le_generate R) = x₂.restrict (le_generate R) → x₁ = x₂ := fun h => by
  rw [← extend_restrict t₁, ← extend_restrict t₂]
  congr
  exact h

/-- Compatible families of elements for a presheaf of types `P` and a presieve `R`
    are in 1-1 correspondence with compatible families for the same presheaf and
    the sieve generated by `R`, through extension and restriction. -/
@[simps]
noncomputable def compatibleEquivGenerateSieveCompatible :
    { x : FamilyOfElements P R // x.Compatible } ≃ { x : FamilyOfElements P (generate R) // x.Compatible } where
  toFun := fun x => ⟨x.1.sieveExtend, x.2.sieveExtend⟩
  invFun := fun x => ⟨x.1.restrict (le_generate R), x.2.restrict _⟩
  left_inv := fun x => Subtype.ext (restrict_extend x.2)
  right_inv := fun x => Subtype.ext (extend_restrict x.2)

theorem FamilyOfElements.comp_of_compatible (S : Sieve X) {x : FamilyOfElements P S} (t : x.Compatible) {f : Y ⟶ X}
    (hf : S f) {Z} (g : Z ⟶ Y) : x (g ≫ f) (S.downward_closed hf g) = P.map g.op (x f hf) := by
  simpa using t (𝟙 _) g (S.downward_closed hf g) hf (id_comp _)

section FunctorPullback

variable {D : Type u₂} [Category.{v₂} D] (F : D ⥤ C) {Z : D}

variable {T : Presieve (F.obj Z)} {x : FamilyOfElements P T}

/-- Given a family of elements of a sieve `S` on `F(X)`, we can realize it as a family of elements of
`S.functor_pullback F`.
-/
def FamilyOfElements.functorPullback (x : FamilyOfElements P T) : FamilyOfElements (F.op ⋙ P) (T.FunctorPullback F) :=
  fun Y f hf => x (F.map f) hf

theorem FamilyOfElements.Compatible.functor_pullback (h : x.Compatible) : (x.FunctorPullback F).Compatible := by
  intro Z₁ Z₂ W g₁ g₂ f₁ f₂ h₁ h₂ eq
  exact
    h (F.map g₁) (F.map g₂) h₁ h₂
      (by
        simp only [← F.map_comp, Eq])

end FunctorPullback

/-- Given a family of elements of a sieve `S` on `X` whose values factors through `F`, we can
realize it as a family of elements of `S.functor_pushforward F`. Since the preimage is obtained by
choice, this is not well-defined generally.
-/
noncomputable def FamilyOfElements.functorPushforward {D : Type u₂} [Category.{v₂} D] (F : D ⥤ C) {X : D}
    {T : Presieve X} (x : FamilyOfElements (F.op ⋙ P) T) : FamilyOfElements P (T.FunctorPushforward F) := fun Y f h =>
  by
  obtain ⟨Z, g, h, h₁, _⟩ := get_functor_pushforward_structure h
  exact P.map h.op (x g h₁)

section Pullback

/-- Given a family of elements of a sieve `S` on `X`, and a map `Y ⟶ X`, we can obtain a
family of elements of `S.pullback f` by taking the same elements.
-/
def FamilyOfElements.pullback (f : Y ⟶ X) (x : FamilyOfElements P S) : FamilyOfElements P (S.pullback f) :=
  fun _ g hg => x (g ≫ f) hg

theorem FamilyOfElements.Compatible.pullback (f : Y ⟶ X) {x : FamilyOfElements P S} (h : x.Compatible) :
    (x.pullback f).Compatible := by
  simp only [compatible_iff_sieve_compatible] at h⊢
  intro W Z f₁ f₂ hf
  unfold family_of_elements.pullback
  rw [← h (f₁ ≫ f) f₂ hf]
  simp only [assoc]

end Pullback

/-- Given a morphism of presheaves `f : P ⟶ Q`, we can take a family of elements valued in `P` to a
family of elements valued in `Q` by composing with `f`.
-/
def FamilyOfElements.compPresheafMap (f : P ⟶ Q) (x : FamilyOfElements P R) : FamilyOfElements Q R := fun Y g hg =>
  f.app (op Y) (x g hg)

@[simp]
theorem FamilyOfElements.comp_presheaf_map_id (x : FamilyOfElements P R) : x.compPresheafMap (𝟙 P) = x :=
  rfl

@[simp]
theorem FamilyOfElements.comp_prersheaf_map_comp (x : FamilyOfElements P R) (f : P ⟶ Q) (g : Q ⟶ U) :
    (x.compPresheafMap f).compPresheafMap g = x.compPresheafMap (f ≫ g) :=
  rfl

theorem FamilyOfElements.Compatible.comp_presheaf_map (f : P ⟶ Q) {x : FamilyOfElements P R} (h : x.Compatible) :
    (x.compPresheafMap f).Compatible := by
  intro Z₁ Z₂ W g₁ g₂ f₁ f₂ h₁ h₂ eq
  unfold family_of_elements.comp_presheaf_map
  rwa [← functor_to_types.naturality, ← functor_to_types.naturality, h]

/-- The given element `t` of `P.obj (op X)` is an *amalgamation* for the family of elements `x` if every
restriction `P.map f.op t = x_f` for every arrow `f` in the presieve `R`.

This is the definition given in  https://ncatlab.org/nlab/show/sheaf#GeneralDefinitionInComponents,
and https://ncatlab.org/nlab/show/matching+family, as well as [MM92], Chapter III, Section 4,
equation (2).
-/
def FamilyOfElements.IsAmalgamation (x : FamilyOfElements P R) (t : P.obj (op X)) : Prop :=
  ∀ ⦃Y : C⦄ f : Y ⟶ X h : R f, P.map f.op t = x f h

theorem FamilyOfElements.IsAmalgamation.comp_presheaf_map {x : FamilyOfElements P R} {t} (f : P ⟶ Q)
    (h : x.IsAmalgamation t) : (x.compPresheafMap f).IsAmalgamation (f.app (op X) t) := by
  intro Y g hg
  dsimp [family_of_elements.comp_presheaf_map]
  change (f.app _ ≫ Q.map _) _ = _
  simp [← f.naturality, h g hg]

theorem is_compatible_of_exists_amalgamation (x : FamilyOfElements P R) (h : ∃ t, x.IsAmalgamation t) : x.Compatible :=
  by
  cases' h with t ht
  intro Y₁ Y₂ Z g₁ g₂ f₁ f₂ h₁ h₂ comm
  rw [← ht _ h₁, ← ht _ h₂, ← functor_to_types.map_comp_apply, ← op_comp, comm]
  simp

theorem is_amalgamation_restrict {R₁ R₂ : Presieve X} (h : R₁ ≤ R₂) (x : FamilyOfElements P R₂) (t : P.obj (op X))
    (ht : x.IsAmalgamation t) : (x.restrict h).IsAmalgamation t := fun Y f hf => ht f (h Y hf)

theorem is_amalgamation_sieve_extend {R : Presieve X} (x : FamilyOfElements P R) (t : P.obj (op X))
    (ht : x.IsAmalgamation t) : x.sieveExtend.IsAmalgamation t := by
  intro Y f hf
  dsimp [family_of_elements.sieve_extend]
  rw [← ht _, ← functor_to_types.map_comp_apply, ← op_comp, hf.some_spec.some_spec.some_spec.2]

/-- A presheaf is separated for a presieve if there is at most one amalgamation. -/
def IsSeparatedFor (P : Cᵒᵖ ⥤ Type w) (R : Presieve X) : Prop :=
  ∀ x : FamilyOfElements P R t₁ t₂, x.IsAmalgamation t₁ → x.IsAmalgamation t₂ → t₁ = t₂

theorem IsSeparatedFor.ext {R : Presieve X} (hR : IsSeparatedFor P R) {t₁ t₂ : P.obj (op X)}
    (h : ∀ ⦃Y⦄ ⦃f : Y ⟶ X⦄ hf : R f, P.map f.op t₁ = P.map f.op t₂) : t₁ = t₂ :=
  hR (fun Y f hf => P.map f.op t₂) t₁ t₂ (fun Y f hf => h hf) fun Y f hf => rfl

theorem is_separated_for_iff_generate : IsSeparatedFor P R ↔ IsSeparatedFor P (generate R) := by
  constructor
  · intro h x t₁ t₂ ht₁ ht₂
    apply h (x.restrict (le_generate R)) t₁ t₂ _ _
    · exact is_amalgamation_restrict _ x t₁ ht₁
      
    · exact is_amalgamation_restrict _ x t₂ ht₂
      
    
  · intro h x t₁ t₂ ht₁ ht₂
    apply h x.sieve_extend
    · exact is_amalgamation_sieve_extend x t₁ ht₁
      
    · exact is_amalgamation_sieve_extend x t₂ ht₂
      
    

theorem is_separated_for_top (P : Cᵒᵖ ⥤ Type w) : IsSeparatedFor P (⊤ : Presieve X) := fun x t₁ t₂ h₁ h₂ => by
  have q₁ :=
    h₁ (𝟙 X)
      (by
        simp )
  have q₂ :=
    h₂ (𝟙 X)
      (by
        simp )
  simp only [op_id, functor_to_types.map_id_apply] at q₁ q₂
  rw [q₁, q₂]

/-- We define `P` to be a sheaf for the presieve `R` if every compatible family has a unique
amalgamation.

This is the definition of a sheaf for the given presieve given in C2.1.2 of [Elephant], and
https://ncatlab.org/nlab/show/sheaf#GeneralDefinitionInComponents.
Using `compatible_iff_sieve_compatible`,
this is equivalent to the definition of a sheaf in [MM92], Chapter III, Section 4.
-/
def IsSheafFor (P : Cᵒᵖ ⥤ Type w) (R : Presieve X) : Prop :=
  ∀ x : FamilyOfElements P R, x.Compatible → ∃! t, x.IsAmalgamation t

/-- This is an equivalent condition to be a sheaf, which is useful for the abstraction to local
operators on elementary toposes. However this definition is defined only for sieves, not presieves.
The equivalence between this and `is_sheaf_for` is given in `yoneda_condition_iff_sheaf_condition`.
This version is also useful to establish that being a sheaf is preserved under isomorphism of
presheaves.

See the discussion before Equation (3) of [MM92], Chapter III, Section 4. See also C2.1.4 of
[Elephant]. This is also a direct reformulation of https://stacks.math.columbia.edu/tag/00Z8.
-/
def YonedaSheafCondition (P : Cᵒᵖ ⥤ Type v₁) (S : Sieve X) : Prop :=
  ∀ f : S.Functor ⟶ P, ∃! g, S.functorInclusion ≫ g = f

/-- (Implementation). This is a (primarily internal) equivalence between natural transformations
and compatible families.

Cf the discussion after Lemma 7.47.10 in https://stacks.math.columbia.edu/tag/00YW. See also
the proof of C2.1.4 of [Elephant], and the discussion in [MM92], Chapter III, Section 4.
-/
-- TODO: We can generalize the universe parameter v₁ above by composing with
-- appropriate `ulift_functor`s.
def natTransEquivCompatibleFamily {P : Cᵒᵖ ⥤ Type v₁} :
    (S.Functor ⟶ P) ≃ { x : FamilyOfElements P S // x.Compatible } where
  toFun := fun α => by
    refine' ⟨fun Y f hf => _, _⟩
    · apply α.app (op Y) ⟨_, hf⟩
      
    · rw [compatible_iff_sieve_compatible]
      intro Y Z f g hf
      dsimp
      rw [← functor_to_types.naturality _ _ α g.op]
      rfl
      
  invFun := fun t =>
    { app := fun Y f => t.1 _ f.2,
      naturality' := fun Y Z g => by
        ext ⟨f, hf⟩
        apply t.2.to_sieve_compatible _ }
  left_inv := fun α => by
    ext X ⟨_, _⟩
    rfl
  right_inv := by
    rintro ⟨x, hx⟩
    rfl

/-- (Implementation). A lemma useful to prove `yoneda_condition_iff_sheaf_condition`. -/
theorem extension_iff_amalgamation {P : Cᵒᵖ ⥤ Type v₁} (x : S.Functor ⟶ P) (g : yoneda.obj X ⟶ P) :
    S.functorInclusion ≫ g = x ↔ (natTransEquivCompatibleFamily x).1.IsAmalgamation (yonedaEquiv g) := by
  change _ ↔ ∀ ⦃Y : C⦄ f : Y ⟶ X h : S f, P.map f.op (yoneda_equiv g) = x.app (op Y) ⟨f, h⟩
  constructor
  · rintro rfl Y f hf
    rw [yoneda_equiv_naturality]
    dsimp
    simp
    
  -- See note [dsimp, simp].
  · intro h
    ext Y ⟨f, hf⟩
    have : _ = x.app Y _ := h f hf
    rw [yoneda_equiv_naturality] at this
    rw [← this]
    dsimp
    simp
    

/-- The yoneda version of the sheaf condition is equivalent to the sheaf condition.

C2.1.4 of [Elephant].
-/
-- See note [dsimp, simp].
theorem is_sheaf_for_iff_yoneda_sheaf_condition {P : Cᵒᵖ ⥤ Type v₁} : IsSheafFor P S ↔ YonedaSheafCondition P S := by
  rw [is_sheaf_for, yoneda_sheaf_condition]
  simp_rw [extension_iff_amalgamation]
  rw [Equivₓ.forall_congr_left' nat_trans_equiv_compatible_family]
  rw [Subtype.forall]
  apply ball_congr
  intro x hx
  rw [Equivₓ.exists_unique_congr_left _]
  simp

/-- If `P` is a sheaf for the sieve `S` on `X`, a natural transformation from `S` (viewed as a functor)
to `P` can be (uniquely) extended to all of `yoneda.obj X`.

      f
   S  →  P
   ↓  ↗
   yX

-/
noncomputable def IsSheafFor.extend {P : Cᵒᵖ ⥤ Type v₁} (h : IsSheafFor P S) (f : S.Functor ⟶ P) : yoneda.obj X ⟶ P :=
  (is_sheaf_for_iff_yoneda_sheaf_condition.1 h f).exists.some

/-- Show that the extension of `f : S.functor ⟶ P` to all of `yoneda.obj X` is in fact an extension, ie
that the triangle below commutes, provided `P` is a sheaf for `S`

      f
   S  →  P
   ↓  ↗
   yX

-/
@[simp, reassoc]
theorem IsSheafFor.functor_inclusion_comp_extend {P : Cᵒᵖ ⥤ Type v₁} (h : IsSheafFor P S) (f : S.Functor ⟶ P) :
    S.functorInclusion ≫ h.extend f = f :=
  (is_sheaf_for_iff_yoneda_sheaf_condition.1 h f).exists.some_spec

/-- The extension of `f` to `yoneda.obj X` is unique. -/
theorem IsSheafFor.unique_extend {P : Cᵒᵖ ⥤ Type v₁} (h : IsSheafFor P S) {f : S.Functor ⟶ P} (t : yoneda.obj X ⟶ P)
    (ht : S.functorInclusion ≫ t = f) : t = h.extend f :=
  (is_sheaf_for_iff_yoneda_sheaf_condition.1 h f).unique ht (h.functor_inclusion_comp_extend f)

/-- If `P` is a sheaf for the sieve `S` on `X`, then if two natural transformations from `yoneda.obj X`
to `P` agree when restricted to the subfunctor given by `S`, they are equal.
-/
theorem IsSheafFor.hom_ext {P : Cᵒᵖ ⥤ Type v₁} (h : IsSheafFor P S) (t₁ t₂ : yoneda.obj X ⟶ P)
    (ht : S.functorInclusion ≫ t₁ = S.functorInclusion ≫ t₂) : t₁ = t₂ :=
  (h.unique_extend t₁ ht).trans (h.unique_extend t₂ rfl).symm

/-- `P` is a sheaf for `R` iff it is separated for `R` and there exists an amalgamation. -/
theorem is_separated_for_and_exists_is_amalgamation_iff_sheaf_for :
    (IsSeparatedFor P R ∧ ∀ x : FamilyOfElements P R, x.Compatible → ∃ t, x.IsAmalgamation t) ↔ IsSheafFor P R := by
  rw [is_separated_for, ← forall_and_distrib]
  apply forall_congrₓ
  intro x
  constructor
  · intro z hx
    exact exists_unique_of_exists_of_unique (z.2 hx) z.1
    
  · intro h
    refine' ⟨_, exists_of_exists_unique ∘ h⟩
    intro t₁ t₂ ht₁ ht₂
    apply (h _).unique ht₁ ht₂
    exact is_compatible_of_exists_amalgamation x ⟨_, ht₂⟩
    

/-- If `P` is separated for `R` and every family has an amalgamation, then `P` is a sheaf for `R`.
-/
theorem IsSeparatedFor.is_sheaf_for (t : IsSeparatedFor P R) :
    (∀ x : FamilyOfElements P R, x.Compatible → ∃ t, x.IsAmalgamation t) → IsSheafFor P R := by
  rw [← is_separated_for_and_exists_is_amalgamation_iff_sheaf_for]
  exact And.intro t

/-- If `P` is a sheaf for `R`, it is separated for `R`. -/
theorem IsSheafFor.is_separated_for : IsSheafFor P R → IsSeparatedFor P R := fun q =>
  (is_separated_for_and_exists_is_amalgamation_iff_sheaf_for.2 q).1

/-- Get the amalgamation of the given compatible family, provided we have a sheaf. -/
noncomputable def IsSheafFor.amalgamate (t : IsSheafFor P R) (x : FamilyOfElements P R) (hx : x.Compatible) :
    P.obj (op X) :=
  (t x hx).exists.some

theorem IsSheafFor.is_amalgamation (t : IsSheafFor P R) {x : FamilyOfElements P R} (hx : x.Compatible) :
    x.IsAmalgamation (t.amalgamate x hx) :=
  (t x hx).exists.some_spec

@[simp]
theorem IsSheafFor.valid_glue (t : IsSheafFor P R) {x : FamilyOfElements P R} (hx : x.Compatible) (f : Y ⟶ X)
    (Hf : R f) : P.map f.op (t.amalgamate x hx) = x f Hf :=
  t.IsAmalgamation hx f Hf

/-- C2.1.3 in [Elephant] -/
theorem is_sheaf_for_iff_generate (R : Presieve X) : IsSheafFor P R ↔ IsSheafFor P (generate R) := by
  rw [← is_separated_for_and_exists_is_amalgamation_iff_sheaf_for]
  rw [← is_separated_for_and_exists_is_amalgamation_iff_sheaf_for]
  rw [← is_separated_for_iff_generate]
  apply and_congr (Iff.refl _)
  constructor
  · intro q x hx
    apply exists_imp_exists _ (q _ (hx.restrict (le_generate R)))
    intro t ht
    simpa [hx] using is_amalgamation_sieve_extend _ _ ht
    
  · intro q x hx
    apply exists_imp_exists _ (q _ hx.sieve_extend)
    intro t ht
    simpa [hx] using is_amalgamation_restrict (le_generate R) _ _ ht
    

/-- Every presheaf is a sheaf for the family {𝟙 X}.

[Elephant] C2.1.5(i)
-/
theorem is_sheaf_for_singleton_iso (P : Cᵒᵖ ⥤ Type w) : IsSheafFor P (Presieve.Singleton (𝟙 X)) := by
  intro x hx
  refine' ⟨x _ (presieve.singleton_self _), _, _⟩
  · rintro _ _ ⟨rfl, rfl⟩
    simp
    
  · intro t ht
    simpa using ht _ (presieve.singleton_self _)
    

/-- Every presheaf is a sheaf for the maximal sieve.

[Elephant] C2.1.5(ii)
-/
theorem is_sheaf_for_top_sieve (P : Cᵒᵖ ⥤ Type w) : IsSheafFor P ((⊤ : Sieve X) : Presieve X) := by
  rw [← generate_of_singleton_split_epi (𝟙 X)]
  rw [← is_sheaf_for_iff_generate]
  apply is_sheaf_for_singleton_iso

/-- If `P` is a sheaf for `S`, and it is iso to `P'`, then `P'` is a sheaf for `S`. This shows that
"being a sheaf for a presieve" is a mathematical or hygenic property.
-/
theorem is_sheaf_for_iso {P' : Cᵒᵖ ⥤ Type w} (i : P ≅ P') : IsSheafFor P R → IsSheafFor P' R := by
  intro h x hx
  let x' := x.comp_presheaf_map i.inv
  have : x'.compatible := family_of_elements.compatible.comp_presheaf_map i.inv hx
  obtain ⟨t, ht1, ht2⟩ := h x' this
  use i.hom.app _ t
  fconstructor
  · convert family_of_elements.is_amalgamation.comp_presheaf_map i.hom ht1
    dsimp [x']
    simp
    
  · intro y hy
    rw
      [show y = (i.inv.app (op X) ≫ i.hom.app (op X)) y by
        simp ]
    simp [ht2 (i.inv.app _ y) (family_of_elements.is_amalgamation.comp_presheaf_map i.inv hy)]
    

/-- If a presieve `R` on `X` has a subsieve `S` such that:

* `P` is a sheaf for `S`.
* For every `f` in `R`, `P` is separated for the pullback of `S` along `f`,

then `P` is a sheaf for `R`.

This is closely related to [Elephant] C2.1.6(i).
-/
theorem is_sheaf_for_subsieve_aux (P : Cᵒᵖ ⥤ Type w) {S : Sieve X} {R : Presieve X} (h : (S : Presieve X) ≤ R)
    (hS : IsSheafFor P S) (trans : ∀ ⦃Y⦄ ⦃f : Y ⟶ X⦄, R f → IsSeparatedFor P (S.pullback f)) : IsSheafFor P R := by
  rw [← is_separated_for_and_exists_is_amalgamation_iff_sheaf_for]
  constructor
  · intro x t₁ t₂ ht₁ ht₂
    exact hS.is_separated_for _ _ _ (is_amalgamation_restrict h x t₁ ht₁) (is_amalgamation_restrict h x t₂ ht₂)
    
  · intro x hx
    use hS.amalgamate _ (hx.restrict h)
    intro W j hj
    apply (trans hj).ext
    intro Y f hf
    rw [← functor_to_types.map_comp_apply, ← op_comp, hS.valid_glue (hx.restrict h) _ hf, family_of_elements.restrict, ←
      hx (𝟙 _) f _ _ (id_comp _)]
    simp
    

/-- If `P` is a sheaf for every pullback of the sieve `S`, then `P` is a sheaf for any presieve which
contains `S`.
This is closely related to [Elephant] C2.1.6.
-/
theorem is_sheaf_for_subsieve (P : Cᵒᵖ ⥤ Type w) {S : Sieve X} {R : Presieve X} (h : (S : Presieve X) ≤ R)
    (trans : ∀ ⦃Y⦄ f : Y ⟶ X, IsSheafFor P (S.pullback f)) : IsSheafFor P R :=
  is_sheaf_for_subsieve_aux P h
    (by
      simpa using trans (𝟙 _))
    fun Y f hf => (trans f).IsSeparatedFor

/-- A presheaf is separated for a topology if it is separated for every sieve in the topology. -/
def IsSeparated (P : Cᵒᵖ ⥤ Type w) : Prop :=
  ∀ {X} S : Sieve X, S ∈ J X → IsSeparatedFor P S

/-- A presheaf is a sheaf for a topology if it is a sheaf for every sieve in the topology.

If the given topology is given by a pretopology, `is_sheaf_for_pretopology` shows it suffices to
check the sheaf condition at presieves in the pretopology.
-/
def IsSheaf (P : Cᵒᵖ ⥤ Type w) : Prop :=
  ∀ ⦃X⦄ S : Sieve X, S ∈ J X → IsSheafFor P S

theorem IsSheaf.is_sheaf_for {P : Cᵒᵖ ⥤ Type w} (hp : IsSheaf J P) (R : Presieve X) (hr : generate R ∈ J X) :
    IsSheafFor P R :=
  (is_sheaf_for_iff_generate R).2 <| hp _ hr

theorem is_sheaf_of_le (P : Cᵒᵖ ⥤ Type w) {J₁ J₂ : GrothendieckTopology C} : J₁ ≤ J₂ → IsSheaf J₂ P → IsSheaf J₁ P :=
  fun h t X S hS => t S (h _ hS)

theorem is_separated_of_is_sheaf (P : Cᵒᵖ ⥤ Type w) (h : IsSheaf J P) : IsSeparated J P := fun X S hS =>
  (h S hS).IsSeparatedFor

/-- The property of being a sheaf is preserved by isomorphism. -/
theorem is_sheaf_iso {P' : Cᵒᵖ ⥤ Type w} (i : P ≅ P') (h : IsSheaf J P) : IsSheaf J P' := fun X S hS =>
  is_sheaf_for_iso i (h S hS)

theorem is_sheaf_of_yoneda {P : Cᵒᵖ ⥤ Type v₁} (h : ∀ {X} S : Sieve X, S ∈ J X → YonedaSheafCondition P S) :
    IsSheaf J P := fun X S hS => is_sheaf_for_iff_yoneda_sheaf_condition.2 (h _ hS)

/-- For a topology generated by a basis, it suffices to check the sheaf condition on the basis
presieves only.
-/
theorem is_sheaf_pretopology [HasPullbacks C] (K : Pretopology C) :
    IsSheaf (K.toGrothendieck C) P ↔ ∀ {X : C} R : Presieve X, R ∈ K X → IsSheafFor P R := by
  constructor
  · intro PJ X R hR
    rw [is_sheaf_for_iff_generate]
    apply PJ (sieve.generate R) ⟨_, hR, le_generate R⟩
    
  · rintro PK X S ⟨R, hR, RS⟩
    have gRS : ⇑generate R ≤ S := by
      apply gi_generate.gc.monotone_u
      rwa [sets_iff_generate]
    apply is_sheaf_for_subsieve P gRS _
    intro Y f
    rw [← pullback_arrows_comm, ← is_sheaf_for_iff_generate]
    exact PK (pullback_arrows f R) (K.pullbacks f R hR)
    

/-- Any presheaf is a sheaf for the bottom (trivial) grothendieck topology. -/
theorem is_sheaf_bot : IsSheaf (⊥ : GrothendieckTopology C) P := fun X => by
  simp [is_sheaf_for_top_sieve]

end Presieve

namespace Equalizer

variable {C : Type u₁} [Category.{v₁} C] (P : Cᵒᵖ ⥤ Type max v₁ u₁) {X : C} (R : Presieve X) (S : Sieve X)

noncomputable section

/-- The middle object of the fork diagram given in Equation (3) of [MM92], as well as the fork diagram
of https://stacks.math.columbia.edu/tag/00VM.
-/
def FirstObj : Type max v₁ u₁ :=
  ∏ fun f : Σ Y, { f : Y ⟶ X // R f } => P.obj (op f.1)

/-- Show that `first_obj` is isomorphic to `family_of_elements`. -/
@[simps]
def firstObjEqFamily : FirstObj P R ≅ R.FamilyOfElements P where
  Hom := fun t Y f hf => Pi.π (fun f : Σ Y, { f : Y ⟶ X // R f } => P.obj (op f.1)) ⟨_, _, hf⟩ t
  inv := Pi.lift fun f x => x _ f.2.2
  hom_inv_id' := by
    ext ⟨Y, f, hf⟩ p
    simpa
  inv_hom_id' := by
    ext x Y f hf
    apply limits.types.limit.lift_π_apply

instance : Inhabited (FirstObj P (⊥ : Presieve X)) :=
  (firstObjEqFamily P _).toEquiv.Inhabited

/-- The left morphism of the fork diagram given in Equation (3) of [MM92], as well as the fork diagram
of https://stacks.math.columbia.edu/tag/00VM.
-/
def forkMap : P.obj (op X) ⟶ FirstObj P R :=
  Pi.lift fun f => P.map f.2.1.op

/-!
This section establishes the equivalence between the sheaf condition of Equation (3) [MM92] and
the definition of `is_sheaf_for`.
-/


namespace Sieve

-- ././Mathport/Syntax/Translate/Basic.lean:746:6: warning: expanding binder group (Y Z)
/-- The rightmost object of the fork diagram of Equation (3) [MM92], which contains the data used
to check a family is compatible.
-/
def SecondObj : Type max v₁ u₁ :=
  ∏ fun f : Σ (Y) (Z) (g : Z ⟶ Y), { f' : Y ⟶ X // S f' } => P.obj (op f.2.1)

/-- The map `p` of Equations (3,4) [MM92]. -/
def firstMap : FirstObj P S ⟶ SecondObj P S :=
  Pi.lift fun fg => Pi.π _ (⟨_, _, S.downward_closed fg.2.2.2.2 fg.2.2.1⟩ : Σ Y, { f : Y ⟶ X // S f })

instance : Inhabited (SecondObj P (⊥ : Sieve X)) :=
  ⟨firstMap _ _ default⟩

/-- The map `a` of Equations (3,4) [MM92]. -/
def secondMap : FirstObj P S ⟶ SecondObj P S :=
  Pi.lift fun fg => Pi.π _ ⟨_, fg.2.2.2⟩ ≫ P.map fg.2.2.1.op

theorem w : forkMap P S ≫ firstMap P S = forkMap P S ≫ secondMap P S := by
  apply limit.hom_ext
  rintro ⟨Y, Z, g, f, hf⟩
  simp [first_map, second_map, fork_map]

/-- The family of elements given by `x : first_obj P S` is compatible iff `first_map` and `second_map`
map it to the same point.
-/
theorem compatible_iff (x : FirstObj P S) :
    ((firstObjEqFamily P S).Hom x).Compatible ↔ firstMap P S x = secondMap P S x := by
  rw [presieve.compatible_iff_sieve_compatible]
  constructor
  · intro t
    ext ⟨Y, Z, g, f, hf⟩
    simpa [first_map, second_map] using t _ g hf
    
  · intro t Y Z f g hf
    rw [types.limit_ext_iff] at t
    simpa [first_map, second_map] using t ⟨Y, Z, g, f, hf⟩
    

/-- `P` is a sheaf for `S`, iff the fork given by `w` is an equalizer. -/
theorem equalizer_sheaf_condition : Presieve.IsSheafFor P S ↔ Nonempty (IsLimit (Fork.ofι _ (w P S))) := by
  rw [types.type_equalizer_iff_unique, ← Equivₓ.forall_congr_left (first_obj_eq_family P S).toEquiv.symm]
  simp_rw [← compatible_iff]
  simp only [inv_hom_id_apply, iso.to_equiv_symm_fun]
  apply ball_congr
  intro x tx
  apply exists_unique_congr
  intro t
  rw [← iso.to_equiv_symm_fun]
  rw [Equivₓ.eq_symm_apply]
  constructor
  · intro q
    ext Y f hf
    simpa [first_obj_eq_family, fork_map] using q _ _
    
  · intro q Y f hf
    rw [← q]
    simp [first_obj_eq_family, fork_map]
    

end Sieve

/-!
This section establishes the equivalence between the sheaf condition of
https://stacks.math.columbia.edu/tag/00VM and the definition of `is_sheaf_for`.
-/


namespace Presieve

variable [HasPullbacks C]

/-- The rightmost object of the fork diagram of https://stacks.math.columbia.edu/tag/00VM, which
contains the data used to check a family of elements for a presieve is compatible.
-/
def SecondObj : Type max v₁ u₁ :=
  ∏ fun fg : (Σ Y, { f : Y ⟶ X // R f }) × Σ Z, { g : Z ⟶ X // R g } => P.obj (op (pullback fg.1.2.1 fg.2.2.1))

/-- The map `pr₀*` of https://stacks.math.columbia.edu/tag/00VL. -/
def firstMap : FirstObj P R ⟶ SecondObj P R :=
  Pi.lift fun fg => Pi.π _ _ ≫ P.map pullback.fst.op

instance : Inhabited (SecondObj P (⊥ : Presieve X)) :=
  ⟨firstMap _ _ default⟩

/-- The map `pr₁*` of https://stacks.math.columbia.edu/tag/00VL. -/
def secondMap : FirstObj P R ⟶ SecondObj P R :=
  Pi.lift fun fg => Pi.π _ _ ≫ P.map pullback.snd.op

theorem w : forkMap P R ≫ firstMap P R = forkMap P R ≫ secondMap P R := by
  apply limit.hom_ext
  rintro ⟨⟨Y, f, hf⟩, ⟨Z, g, hg⟩⟩
  simp only [first_map, second_map, fork_map]
  simp only [limit.lift_π, limit.lift_π_assoc, assoc, fan.mk_π_app, Subtype.coe_mk, Subtype.val_eq_coe]
  rw [← P.map_comp, ← op_comp, pullback.condition]
  simp

/-- The family of elements given by `x : first_obj P S` is compatible iff `first_map` and `second_map`
map it to the same point.
-/
theorem compatible_iff (x : FirstObj P R) :
    ((firstObjEqFamily P R).Hom x).Compatible ↔ firstMap P R x = secondMap P R x := by
  rw [presieve.pullback_compatible_iff]
  constructor
  · intro t
    ext ⟨⟨Y, f, hf⟩, Z, g, hg⟩
    simpa [first_map, second_map] using t hf hg
    
  · intro t Y Z f g hf hg
    rw [types.limit_ext_iff] at t
    simpa [first_map, second_map] using t ⟨⟨Y, f, hf⟩, Z, g, hg⟩
    

/-- `P` is a sheaf for `R`, iff the fork given by `w` is an equalizer.
See https://stacks.math.columbia.edu/tag/00VM.
-/
theorem sheaf_condition : R.IsSheafFor P ↔ Nonempty (IsLimit (Fork.ofι _ (w P R))) := by
  rw [types.type_equalizer_iff_unique]
  erw [← Equivₓ.forall_congr_left (first_obj_eq_family P R).toEquiv.symm]
  simp_rw [← compatible_iff, ← iso.to_equiv_fun, Equivₓ.apply_symm_apply]
  apply ball_congr
  intro x hx
  apply exists_unique_congr
  intro t
  rw [Equivₓ.eq_symm_apply]
  constructor
  · intro q
    ext Y f hf
    simpa [fork_map] using q _ _
    
  · intro q Y f hf
    rw [← q]
    simp [fork_map]
    

end Presieve

end Equalizer

variable {C : Type u₁} [Category.{v₁} C]

variable (J : GrothendieckTopology C)

/-- The category of sheaves on a grothendieck topology. -/
structure SheafOfTypes (J : GrothendieckTopology C) : Type max u₁ v₁ (w + 1) where
  val : Cᵒᵖ ⥤ Type w
  cond : Presieve.IsSheaf J val

namespace SheafOfTypes

variable {J}

/-- Morphisms between sheaves of types are just morphisms between the underlying presheaves. -/
@[ext]
structure Hom (X Y : SheafOfTypes J) where
  val : X.val ⟶ Y.val

@[simps]
instance : Category (SheafOfTypes J) where
  Hom := Hom
  id := fun X => ⟨𝟙 _⟩
  comp := fun X Y Z f g => ⟨f.val ≫ g.val⟩
  id_comp' := fun X Y f => Hom.ext _ _ <| id_comp _
  comp_id' := fun X Y f => Hom.ext _ _ <| comp_id _
  assoc' := fun X Y Z W f g h => Hom.ext _ _ <| assoc _ _ _

-- Let's make the inhabited linter happy...
instance (X : SheafOfTypes J) : Inhabited (Hom X X) :=
  ⟨𝟙 X⟩

end SheafOfTypes

/-- The inclusion functor from sheaves to presheaves. -/
@[simps]
def sheafOfTypesToPresheaf : SheafOfTypes J ⥤ Cᵒᵖ ⥤ Type w where
  obj := SheafOfTypes.val
  map := fun X Y f => f.val
  map_id' := fun X => rfl
  map_comp' := fun X Y Z f g => rfl

instance : Full (sheafOfTypesToPresheaf J) where
  Preimage := fun X Y f => ⟨f⟩

instance : Faithful (sheafOfTypesToPresheaf J) :=
  {  }

/-- The category of sheaves on the bottom (trivial) grothendieck topology is equivalent to the category
of presheaves.
-/
@[simps]
def sheafOfTypesBotEquiv : SheafOfTypes (⊥ : GrothendieckTopology C) ≌ Cᵒᵖ ⥤ Type w where
  Functor := sheafOfTypesToPresheaf _
  inverse := { obj := fun P => ⟨P, Presieve.is_sheaf_bot⟩, map := fun P₁ P₂ f => (sheafOfTypesToPresheaf _).Preimage f }
  unitIso := { Hom := { app := fun _ => ⟨𝟙 _⟩ }, inv := { app := fun _ => ⟨𝟙 _⟩ } }
  counitIso := Iso.refl _

instance : Inhabited (SheafOfTypes (⊥ : GrothendieckTopology C)) :=
  ⟨sheafOfTypesBotEquiv.inverse.obj ((Functor.const _).obj PUnit)⟩

end CategoryTheory

