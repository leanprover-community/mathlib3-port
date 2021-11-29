import Mathbin.Algebra.Category.Mon.Basic 
import Mathbin.CategoryTheory.Endomorphism

/-!
# Category instances for group, add_group, comm_group, and add_comm_group.

We introduce the bundled categories:
* `Group`
* `AddGroup`
* `CommGroup`
* `AddCommGroup`
along with the relevant forgetful functors between them, and to the bundled monoid categories.
-/


universe u v

open CategoryTheory

/-- The category of groups and group morphisms. -/
@[toAdditive AddGroupₓₓ]
def Groupₓₓ : Type (u + 1) :=
  bundled Groupₓ

/-- The category of additive groups and group morphisms -/
add_decl_doc AddGroupₓₓ

namespace Groupₓₓ

@[toAdditive]
instance  : bundled_hom.parent_projection Groupₓ.toMonoid :=
  ⟨⟩

-- error in Algebra.Category.Group.Basic: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler large_category
attribute [derive #["[", expr large_category, ",", expr concrete_category, "]"]] Group

attribute [toAdditive] Groupₓₓ.largeCategory Groupₓₓ.concreteCategory

@[toAdditive]
instance  : CoeSort Groupₓₓ (Type _) :=
  bundled.has_coe_to_sort

/-- Construct a bundled `Group` from the underlying type and typeclass. -/
@[toAdditive]
def of (X : Type u) [Groupₓ X] : Groupₓₓ :=
  bundled.of X

/-- Construct a bundled `AddGroup` from the underlying type and typeclass. -/
add_decl_doc AddGroupₓₓ.of

/-- Typecheck a `monoid_hom` as a morphism in `Group`. -/
@[toAdditive]
def of_hom {X Y : Type u} [Groupₓ X] [Groupₓ Y] (f : X →* Y) : of X ⟶ of Y :=
  f

/-- Typecheck a `add_monoid_hom` as a morphism in `AddGroup`. -/
add_decl_doc AddGroupₓₓ.ofHom

@[toAdditive]
instance  (G : Groupₓₓ) : Groupₓ G :=
  G.str

@[simp, toAdditive]
theorem coe_of (R : Type u) [Groupₓ R] : (Groupₓₓ.of R : Type u) = R :=
  rfl

@[toAdditive]
instance  : HasOne Groupₓₓ :=
  ⟨Groupₓₓ.of PUnit⟩

@[toAdditive]
instance  : Inhabited Groupₓₓ :=
  ⟨1⟩

@[toAdditive]
instance one.unique : Unique (1 : Groupₓₓ) :=
  { default := 1,
    uniq :=
      fun a =>
        by 
          cases a 
          rfl }

@[simp, toAdditive]
theorem one_apply (G H : Groupₓₓ) (g : G) : (1 : G ⟶ H) g = 1 :=
  rfl

@[ext, toAdditive]
theorem ext (G H : Groupₓₓ) (f₁ f₂ : G ⟶ H) (w : ∀ x, f₁ x = f₂ x) : f₁ = f₂ :=
  by 
    ext1 
    apply w

@[toAdditive has_forget_to_AddMon]
instance has_forget_to_Mon : has_forget₂ Groupₓₓ Mon :=
  bundled_hom.forget₂ _ _

end Groupₓₓ

/-- The category of commutative groups and group morphisms. -/
@[toAdditive AddCommGroupₓₓ]
def CommGroupₓₓ : Type (u + 1) :=
  bundled CommGroupₓ

/-- The category of additive commutative groups and group morphisms. -/
add_decl_doc AddCommGroupₓₓ

/-- `Ab` is an abbreviation for `AddCommGroup`, for the sake of mathematicians' sanity. -/
abbrev Ab :=
  AddCommGroupₓₓ

namespace CommGroupₓₓ

@[toAdditive]
instance  : bundled_hom.parent_projection CommGroupₓ.toGroup :=
  ⟨⟩

-- error in Algebra.Category.Group.Basic: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler large_category
attribute [derive #["[", expr large_category, ",", expr concrete_category, "]"]] CommGroup

attribute [toAdditive] CommGroupₓₓ.largeCategory CommGroupₓₓ.concreteCategory

@[toAdditive]
instance  : CoeSort CommGroupₓₓ (Type _) :=
  bundled.has_coe_to_sort

/-- Construct a bundled `CommGroup` from the underlying type and typeclass. -/
@[toAdditive]
def of (G : Type u) [CommGroupₓ G] : CommGroupₓₓ :=
  bundled.of G

/-- Construct a bundled `AddCommGroup` from the underlying type and typeclass. -/
add_decl_doc AddCommGroupₓₓ.of

/-- Typecheck a `monoid_hom` as a morphism in `CommGroup`. -/
@[toAdditive]
def of_hom {X Y : Type u} [CommGroupₓ X] [CommGroupₓ Y] (f : X →* Y) : of X ⟶ of Y :=
  f

/-- Typecheck a `add_monoid_hom` as a morphism in `AddCommGroup`. -/
add_decl_doc AddCommGroupₓₓ.ofHom

@[toAdditive]
instance comm_group_instance (G : CommGroupₓₓ) : CommGroupₓ G :=
  G.str

@[simp, toAdditive]
theorem coe_of (R : Type u) [CommGroupₓ R] : (CommGroupₓₓ.of R : Type u) = R :=
  rfl

@[toAdditive]
instance  : HasOne CommGroupₓₓ :=
  ⟨CommGroupₓₓ.of PUnit⟩

@[toAdditive]
instance  : Inhabited CommGroupₓₓ :=
  ⟨1⟩

@[toAdditive]
instance one.unique : Unique (1 : CommGroupₓₓ) :=
  { default := 1,
    uniq :=
      fun a =>
        by 
          cases a 
          rfl }

@[simp, toAdditive]
theorem one_apply (G H : CommGroupₓₓ) (g : G) : (1 : G ⟶ H) g = 1 :=
  rfl

@[ext, toAdditive]
theorem ext (G H : CommGroupₓₓ) (f₁ f₂ : G ⟶ H) (w : ∀ x, f₁ x = f₂ x) : f₁ = f₂ :=
  by 
    ext1 
    apply w

@[toAdditive has_forget_to_AddGroup]
instance has_forget_to_Group : has_forget₂ CommGroupₓₓ Groupₓₓ :=
  bundled_hom.forget₂ _ _

-- error in Algebra.Category.Group.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[to_additive #[ident has_forget_to_AddCommMon]] instance has_forget_to_CommMon : has_forget₂ CommGroup CommMon :=
induced_category.has_forget₂ (λ G : CommGroup, CommMon.of G)

end CommGroupₓₓ

@[toAdditive]
example  {R S : CommGroupₓₓ} (i : R ⟶ S) (r : R) (h : r = 1) : i r = 1 :=
  by 
    simp [h]

namespace AddCommGroupₓₓ

/-- Any element of an abelian group gives a unique morphism from `ℤ` sending
`1` to that element. -/
def as_hom {G : AddCommGroupₓₓ.{0}} (g : G) : AddCommGroupₓₓ.of ℤ ⟶ G :=
  zmultiplesHom G g

@[simp]
theorem as_hom_apply {G : AddCommGroupₓₓ.{0}} (g : G) (i : ℤ) : (as_hom g) i = i • g :=
  rfl

-- error in Algebra.Category.Group.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem as_hom_injective {G : AddCommGroup.{0}} : function.injective (@as_hom G) :=
λ
h
k
w, by convert [] [expr congr_arg (λ
  k : «expr ⟶ »(AddCommGroup.of exprℤ(), G), (k : exprℤ() → G) (1 : exprℤ())) w] []; simp [] [] [] [] [] []

@[ext]
theorem int_hom_ext {G : AddCommGroupₓₓ.{0}} (f g : AddCommGroupₓₓ.of ℤ ⟶ G) (w : f (1 : ℤ) = g (1 : ℤ)) : f = g :=
  AddMonoidHom.ext_int w

-- error in Algebra.Category.Group.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem injective_of_mono {G H : AddCommGroup.{0}} (f : «expr ⟶ »(G, H)) [mono f] : function.injective f :=
λ g₁ g₂ h, begin
  have [ident t0] [":", expr «expr = »(«expr ≫ »(as_hom g₁, f), «expr ≫ »(as_hom g₂, f))] [":=", expr begin
     ext [] [] [],
     simpa [] [] [] ["[", expr as_hom_apply, "]"] [] ["using", expr h]
   end],
  have [ident t1] [":", expr «expr = »(as_hom g₁, as_hom g₂)] [":=", expr (cancel_mono _).1 t0],
  apply [expr as_hom_injective t1]
end

end AddCommGroupₓₓ

variable{X Y : Type u}

/-- Build an isomorphism in the category `Group` from a `mul_equiv` between `group`s. -/
@[toAdditive AddEquiv.toAddGroupIso, simps]
def MulEquiv.toGroupIso [Groupₓ X] [Groupₓ Y] (e : X ≃* Y) : Groupₓₓ.of X ≅ Groupₓₓ.of Y :=
  { Hom := e.to_monoid_hom, inv := e.symm.to_monoid_hom }

/-- Build an isomorphism in the category `AddGroup` from an `add_equiv` between `add_group`s. -/
add_decl_doc AddEquiv.toAddGroupIso

/-- Build an isomorphism in the category `CommGroup` from a `mul_equiv` between `comm_group`s. -/
@[toAdditive AddEquiv.toAddCommGroupIso, simps]
def MulEquiv.toCommGroupIso [CommGroupₓ X] [CommGroupₓ Y] (e : X ≃* Y) : CommGroupₓₓ.of X ≅ CommGroupₓₓ.of Y :=
  { Hom := e.to_monoid_hom, inv := e.symm.to_monoid_hom }

/-- Build an isomorphism in the category `AddCommGroup` from a `add_equiv` between
`add_comm_group`s. -/
add_decl_doc AddEquiv.toAddCommGroupIso

namespace CategoryTheory.Iso

/-- Build a `mul_equiv` from an isomorphism in the category `Group`. -/
@[toAdditive AddGroup_iso_to_add_equiv "Build an `add_equiv` from an isomorphism in the category\n`AddGroup`.", simps]
def Group_iso_to_mul_equiv {X Y : Groupₓₓ} (i : X ≅ Y) : X ≃* Y :=
  i.hom.to_mul_equiv i.inv i.hom_inv_id i.inv_hom_id

/-- Build a `mul_equiv` from an isomorphism in the category `CommGroup`. -/
@[toAdditive AddCommGroup_iso_to_add_equiv "Build an `add_equiv` from an isomorphism\nin the category `AddCommGroup`.",
  simps]
def CommGroup_iso_to_mul_equiv {X Y : CommGroupₓₓ} (i : X ≅ Y) : X ≃* Y :=
  i.hom.to_mul_equiv i.inv i.hom_inv_id i.inv_hom_id

end CategoryTheory.Iso

/-- multiplicative equivalences between `group`s are the same as (isomorphic to) isomorphisms
in `Group` -/
@[toAdditive addEquivIsoAddGroupIso
      "additive equivalences between `add_group`s are the same\nas (isomorphic to) isomorphisms in `AddGroup`"]
def mulEquivIsoGroupIso {X Y : Type u} [Groupₓ X] [Groupₓ Y] : X ≃* Y ≅ Groupₓₓ.of X ≅ Groupₓₓ.of Y :=
  { Hom := fun e => e.to_Group_iso, inv := fun i => i.Group_iso_to_mul_equiv }

/-- multiplicative equivalences between `comm_group`s are the same as (isomorphic to) isomorphisms
in `CommGroup` -/
@[toAdditive addEquivIsoAddCommGroupIso
      "additive equivalences between `add_comm_group`s are\nthe same as (isomorphic to) isomorphisms in `AddCommGroup`"]
def mulEquivIsoCommGroupIso {X Y : Type u} [CommGroupₓ X] [CommGroupₓ Y] :
  X ≃* Y ≅ CommGroupₓₓ.of X ≅ CommGroupₓₓ.of Y :=
  { Hom := fun e => e.to_CommGroup_iso, inv := fun i => i.CommGroup_iso_to_mul_equiv }

namespace CategoryTheory.Aut

/-- The (bundled) group of automorphisms of a type is isomorphic to the (bundled) group
of permutations. -/
def iso_perm {α : Type u} : Groupₓₓ.of (Aut α) ≅ Groupₓₓ.of (Equiv.Perm α) :=
  { Hom :=
      ⟨fun g => g.to_equiv,
        by 
          tidy,
        by 
          tidy⟩,
    inv :=
      ⟨fun g => g.to_iso,
        by 
          tidy,
        by 
          tidy⟩ }

/-- The (unbundled) group of automorphisms of a type is `mul_equiv` to the (unbundled) group
of permutations. -/
def mul_equiv_perm {α : Type u} : Aut α ≃* Equiv.Perm α :=
  iso_perm.groupIsoToMulEquiv

end CategoryTheory.Aut

@[toAdditive]
instance Groupₓₓ.forget_reflects_isos : reflects_isomorphisms (forget Groupₓₓ.{u}) :=
  { reflects :=
      fun X Y f _ =>
        by 
          skip 
          let i := as_iso ((forget Groupₓₓ).map f)
          let e : X ≃* Y := { f, i.to_equiv with  }
          exact ⟨(is_iso.of_iso e.to_Group_iso).1⟩ }

@[toAdditive]
instance CommGroupₓₓ.forget_reflects_isos : reflects_isomorphisms (forget CommGroupₓₓ.{u}) :=
  { reflects :=
      fun X Y f _ =>
        by 
          skip 
          let i := as_iso ((forget CommGroupₓₓ).map f)
          let e : X ≃* Y := { f, i.to_equiv with  }
          exact ⟨(is_iso.of_iso e.to_CommGroup_iso).1⟩ }

