/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro
-/
import Mathbin.Data.FunLike.Basic
import Mathbin.Logic.Embedding.Basic
import Mathbin.Order.RelClasses

#align_import order.rel_iso.basic from "leanprover-community/mathlib"@"f29120f82f6e24a6f6579896dfa2de6769fec962"

/-!
# Relation homomorphisms, embeddings, isomorphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines relation homomorphisms, embeddings, isomorphisms and order embeddings and
isomorphisms.

## Main declarations

* `rel_hom`: Relation homomorphism. A `rel_hom r s` is a function `f : α → β` such that
  `r a b → s (f a) (f b)`.
* `rel_embedding`: Relation embedding. A `rel_embedding r s` is an embedding `f : α ↪ β` such that
  `r a b ↔ s (f a) (f b)`.
* `rel_iso`: Relation isomorphism. A `rel_iso r s` is an equivalence `f : α ≃ β` such that
  `r a b ↔ s (f a) (f b)`.
* `sum_lex_congr`, `prod_lex_congr`: Creates a relation homomorphism between two `sum_lex` or two
  `prod_lex` from relation homomorphisms between their arguments.

## Notation

* `→r`: `rel_hom`
* `↪r`: `rel_embedding`
* `≃r`: `rel_iso`
-/


open Function

universe u v w

variable {α β γ δ : Type _} {r : α → α → Prop} {s : β → β → Prop} {t : γ → γ → Prop}
  {u : δ → δ → Prop}

#print RelHom /-
/-- A relation homomorphism with respect to a given pair of relations `r` and `s`
is a function `f : α → β` such that `r a b → s (f a) (f b)`. -/
@[nolint has_nonempty_instance]
structure RelHom {α β : Type _} (r : α → α → Prop) (s : β → β → Prop) where
  toFun : α → β
  map_rel' : ∀ {a b}, r a b → s (to_fun a) (to_fun b)
#align rel_hom RelHom
-/

infixl:25 " →r " => RelHom

section

#print RelHomClass /-
/-- `rel_hom_class F r s` asserts that `F` is a type of functions such that all `f : F`
satisfy `r a b → s (f a) (f b)`.

The relations `r` and `s` are `out_param`s since figuring them out from a goal is a higher-order
matching problem that Lean usually can't do unaided.
-/
class RelHomClass (F : Type _) {α β : outParam <| Type _} (r : outParam <| α → α → Prop)
    (s : outParam <| β → β → Prop) extends FunLike F α fun _ => β where
  map_rel : ∀ (f : F) {a b}, r a b → s (f a) (f b)
#align rel_hom_class RelHomClass
-/

export RelHomClass (map_rel)

-- The free parameters `r` and `s` are `out_param`s so this is not dangerous.
attribute [nolint dangerous_instance] RelHomClass.toFunLike

end

namespace RelHomClass

variable {F : Type _}

#print RelHomClass.isIrrefl /-
protected theorem isIrrefl [RelHomClass F r s] (f : F) : ∀ [IsIrrefl β s], IsIrrefl α r
  | ⟨H⟩ => ⟨fun a h => H _ (map_rel f h)⟩
#align rel_hom_class.is_irrefl RelHomClass.isIrrefl
-/

#print RelHomClass.isAsymm /-
protected theorem isAsymm [RelHomClass F r s] (f : F) : ∀ [IsAsymm β s], IsAsymm α r
  | ⟨H⟩ => ⟨fun a b h₁ h₂ => H _ _ (map_rel f h₁) (map_rel f h₂)⟩
#align rel_hom_class.is_asymm RelHomClass.isAsymm
-/

#print RelHomClass.acc /-
protected theorem acc [RelHomClass F r s] (f : F) (a : α) : Acc s (f a) → Acc r a :=
  by
  generalize h : f a = b; intro ac
  induction' ac with _ H IH generalizing a; subst h
  exact ⟨_, fun a' h => IH (f a') (map_rel f h) _ rfl⟩
#align rel_hom_class.acc RelHomClass.acc
-/

#print RelHomClass.wellFounded /-
protected theorem wellFounded [RelHomClass F r s] (f : F) : ∀ h : WellFounded s, WellFounded r
  | ⟨H⟩ => ⟨fun a => RelHomClass.acc f _ (H _)⟩
#align rel_hom_class.well_founded RelHomClass.wellFounded
-/

end RelHomClass

namespace RelHom

instance : RelHomClass (r →r s) r s where
  coe o := o.toFun
  coe_injective' f g h := by cases f; cases g; congr
  map_rel := map_rel'

/-- Auxiliary instance if `rel_hom_class.to_fun_like.to_has_coe_to_fun` isn't found -/
instance : CoeFun (r →r s) fun _ => α → β :=
  ⟨fun o => o.toFun⟩

initialize_simps_projections RelHom (toFun → apply)

#print RelHom.map_rel /-
protected theorem map_rel (f : r →r s) {a b} : r a b → s (f a) (f b) :=
  f.map_rel'
#align rel_hom.map_rel RelHom.map_rel
-/

@[simp]
theorem coeFn_mk (f : α → β) (o) : (@RelHom.mk _ _ r s f o : α → β) = f :=
  rfl
#align rel_hom.coe_fn_mk RelHom.coeFn_mk

#print RelHom.coe_fn_toFun /-
@[simp]
theorem coe_fn_toFun (f : r →r s) : (f.toFun : α → β) = f :=
  rfl
#align rel_hom.coe_fn_to_fun RelHom.coe_fn_toFun
-/

#print RelHom.coe_fn_injective /-
/-- The map `coe_fn : (r →r s) → (α → β)` is injective. -/
theorem coe_fn_injective : @Function.Injective (r →r s) (α → β) coeFn :=
  FunLike.coe_injective
#align rel_hom.coe_fn_injective RelHom.coe_fn_injective
-/

#print RelHom.ext /-
@[ext]
theorem ext ⦃f g : r →r s⦄ (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext f g h
#align rel_hom.ext RelHom.ext
-/

#print RelHom.ext_iff /-
theorem ext_iff {f g : r →r s} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align rel_hom.ext_iff RelHom.ext_iff
-/

#print RelHom.id /-
/-- Identity map is a relation homomorphism. -/
@[refl, simps]
protected def id (r : α → α → Prop) : r →r r :=
  ⟨fun x => x, fun a b x => x⟩
#align rel_hom.id RelHom.id
-/

#print RelHom.comp /-
/-- Composition of two relation homomorphisms is a relation homomorphism. -/
@[trans, simps]
protected def comp (g : s →r t) (f : r →r s) : r →r t :=
  ⟨fun x => g (f x), fun a b h => g.2 (f.2 h)⟩
#align rel_hom.comp RelHom.comp
-/

#print RelHom.swap /-
/-- A relation homomorphism is also a relation homomorphism between dual relations. -/
protected def swap (f : r →r s) : swap r →r swap s :=
  ⟨f, fun a b => f.map_rel⟩
#align rel_hom.swap RelHom.swap
-/

#print RelHom.preimage /-
/-- A function is a relation homomorphism from the preimage relation of `s` to `s`. -/
def preimage (f : α → β) (s : β → β → Prop) : f ⁻¹'o s →r s :=
  ⟨f, fun a b => id⟩
#align rel_hom.preimage RelHom.preimage
-/

end RelHom

#print injective_of_increasing /-
/-- An increasing function is injective -/
theorem injective_of_increasing (r : α → α → Prop) (s : β → β → Prop) [IsTrichotomous α r]
    [IsIrrefl β s] (f : α → β) (hf : ∀ {x y}, r x y → s (f x) (f y)) : Injective f :=
  by
  intro x y hxy
  rcases trichotomous_of r x y with (h | h | h)
  have := hf h; rw [hxy] at this ; exfalso; exact irrefl_of s (f y) this
  exact h
  have := hf h; rw [hxy] at this ; exfalso; exact irrefl_of s (f y) this
#align injective_of_increasing injective_of_increasing
-/

#print RelHom.injective_of_increasing /-
/-- An increasing function is injective -/
theorem RelHom.injective_of_increasing [IsTrichotomous α r] [IsIrrefl β s] (f : r →r s) :
    Injective f :=
  injective_of_increasing r s f fun x y => f.map_rel
#align rel_hom.injective_of_increasing RelHom.injective_of_increasing
-/

#print Surjective.wellFounded_iff /-
-- TODO: define a `rel_iff_class` so we don't have to do all the `convert` trickery?
theorem Surjective.wellFounded_iff {f : α → β} (hf : Surjective f)
    (o : ∀ {a b}, r a b ↔ s (f a) (f b)) : WellFounded r ↔ WellFounded s :=
  Iff.intro
    (by
      refine' RelHomClass.wellFounded (RelHom.mk _ _ : s →r r)
      · exact Classical.choose hf.has_right_inverse
      intro a b h; apply o.2; convert h
      iterate 2 apply Classical.choose_spec hf.has_right_inverse)
    (RelHomClass.wellFounded (⟨f, fun _ _ => o.1⟩ : r →r s))
#align surjective.well_founded_iff Surjective.wellFounded_iff
-/

#print RelEmbedding /-
/-- A relation embedding with respect to a given pair of relations `r` and `s`
is an embedding `f : α ↪ β` such that `r a b ↔ s (f a) (f b)`. -/
structure RelEmbedding {α β : Type _} (r : α → α → Prop) (s : β → β → Prop) extends α ↪ β where
  map_rel_iff' : ∀ {a b}, s (to_embedding a) (to_embedding b) ↔ r a b
#align rel_embedding RelEmbedding
-/

infixl:25 " ↪r " => RelEmbedding

#print Subtype.relEmbedding /-
/-- The induced relation on a subtype is an embedding under the natural inclusion. -/
def Subtype.relEmbedding {X : Type _} (r : X → X → Prop) (p : X → Prop) :
    (Subtype.val : Subtype p → X) ⁻¹'o r ↪r r :=
  ⟨Embedding.subtype p, fun x y => Iff.rfl⟩
#align subtype.rel_embedding Subtype.relEmbedding
-/

#print preimage_equivalence /-
theorem preimage_equivalence {α β} (f : α → β) {s : β → β → Prop} (hs : Equivalence s) :
    Equivalence (f ⁻¹'o s) :=
  ⟨fun a => hs.1 _, fun a b h => hs.2.1 h, fun a b c h₁ h₂ => hs.2.2 h₁ h₂⟩
#align preimage_equivalence preimage_equivalence
-/

namespace RelEmbedding

#print RelEmbedding.toRelHom /-
/-- A relation embedding is also a relation homomorphism -/
def toRelHom (f : r ↪r s) : r →r s
    where
  toFun := f.toEmbedding.toFun
  map_rel' x y := (map_rel_iff' f).mpr
#align rel_embedding.to_rel_hom RelEmbedding.toRelHom
-/

instance : Coe (r ↪r s) (r →r s) :=
  ⟨toRelHom⟩

-- see Note [function coercion]
instance : CoeFun (r ↪r s) fun _ => α → β :=
  ⟨fun o => o.toEmbedding⟩

-- TODO: define and instantiate a `rel_embedding_class` when `embedding_like` is defined
instance : RelHomClass (r ↪r s) r s where
  coe := coeFn
  coe_injective' f g h := by rcases f with ⟨⟨⟩⟩; rcases g with ⟨⟨⟩⟩; congr
  map_rel f a b := Iff.mpr (map_rel_iff' f)

#print RelEmbedding.Simps.apply /-
/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
because it is a composition of multiple projections. -/
def Simps.apply (h : r ↪r s) : α → β :=
  h
#align rel_embedding.simps.apply RelEmbedding.Simps.apply
-/

initialize_simps_projections RelEmbedding (to_embedding_to_fun → apply, -toEmbedding)

@[simp]
theorem toRelHom_eq_coe (f : r ↪r s) : f.toRelHom = f :=
  rfl
#align rel_embedding.to_rel_hom_eq_coe RelEmbedding.toRelHom_eq_coe

@[simp]
theorem coe_coeFn (f : r ↪r s) : ((f : r →r s) : α → β) = f :=
  rfl
#align rel_embedding.coe_coe_fn RelEmbedding.coe_coeFn

#print RelEmbedding.injective /-
theorem injective (f : r ↪r s) : Injective f :=
  f.inj'
#align rel_embedding.injective RelEmbedding.injective
-/

#print RelEmbedding.inj /-
@[simp]
theorem inj (f : r ↪r s) {a b} : f a = f b ↔ a = b :=
  f.Injective.eq_iff
#align rel_embedding.inj RelEmbedding.inj
-/

#print RelEmbedding.map_rel_iff /-
theorem map_rel_iff (f : r ↪r s) {a b} : s (f a) (f b) ↔ r a b :=
  f.map_rel_iff'
#align rel_embedding.map_rel_iff RelEmbedding.map_rel_iff
-/

#print RelEmbedding.coe_mk /-
@[simp]
theorem coe_mk (f : α ↪ β) (o) : (@RelEmbedding.mk _ _ r s f o : α → β) = f :=
  rfl
#align rel_embedding.coe_fn_mk RelEmbedding.coe_mk
-/

#print RelEmbedding.coe_toEmbedding /-
@[simp]
theorem coe_toEmbedding (f : r ↪r s) : (f.toEmbedding : α → β) = f :=
  rfl
#align rel_embedding.coe_fn_to_embedding RelEmbedding.coe_toEmbedding
-/

#print RelEmbedding.coe_fn_injective /-
/-- The map `coe_fn : (r ↪r s) → (α → β)` is injective. -/
theorem coe_fn_injective : @Function.Injective (r ↪r s) (α → β) coeFn :=
  FunLike.coe_injective
#align rel_embedding.coe_fn_injective RelEmbedding.coe_fn_injective
-/

#print RelEmbedding.ext /-
@[ext]
theorem ext ⦃f g : r ↪r s⦄ (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext _ _ h
#align rel_embedding.ext RelEmbedding.ext
-/

#print RelEmbedding.ext_iff /-
theorem ext_iff {f g : r ↪r s} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align rel_embedding.ext_iff RelEmbedding.ext_iff
-/

#print RelEmbedding.refl /-
/-- Identity map is a relation embedding. -/
@[refl, simps]
protected def refl (r : α → α → Prop) : r ↪r r :=
  ⟨Embedding.refl _, fun a b => Iff.rfl⟩
#align rel_embedding.refl RelEmbedding.refl
-/

#print RelEmbedding.trans /-
/-- Composition of two relation embeddings is a relation embedding. -/
@[trans]
protected def trans (f : r ↪r s) (g : s ↪r t) : r ↪r t :=
  ⟨f.1.trans g.1, fun a b => by simp [f.map_rel_iff, g.map_rel_iff]⟩
#align rel_embedding.trans RelEmbedding.trans
-/

instance (r : α → α → Prop) : Inhabited (r ↪r r) :=
  ⟨RelEmbedding.refl _⟩

#print RelEmbedding.trans_apply /-
theorem trans_apply (f : r ↪r s) (g : s ↪r t) (a : α) : (f.trans g) a = g (f a) :=
  rfl
#align rel_embedding.trans_apply RelEmbedding.trans_apply
-/

#print RelEmbedding.coe_trans /-
@[simp]
theorem coe_trans (f : r ↪r s) (g : s ↪r t) : ⇑(f.trans g) = g ∘ f :=
  rfl
#align rel_embedding.coe_trans RelEmbedding.coe_trans
-/

#print RelEmbedding.swap /-
/-- A relation embedding is also a relation embedding between dual relations. -/
protected def swap (f : r ↪r s) : swap r ↪r swap s :=
  ⟨f.toEmbedding, fun a b => f.map_rel_iff⟩
#align rel_embedding.swap RelEmbedding.swap
-/

#print RelEmbedding.preimage /-
/-- If `f` is injective, then it is a relation embedding from the
  preimage relation of `s` to `s`. -/
def preimage (f : α ↪ β) (s : β → β → Prop) : f ⁻¹'o s ↪r s :=
  ⟨f, fun a b => Iff.rfl⟩
#align rel_embedding.preimage RelEmbedding.preimage
-/

#print RelEmbedding.eq_preimage /-
theorem eq_preimage (f : r ↪r s) : r = f ⁻¹'o s := by ext a b; exact f.map_rel_iff.symm
#align rel_embedding.eq_preimage RelEmbedding.eq_preimage
-/

#print RelEmbedding.isIrrefl /-
protected theorem isIrrefl (f : r ↪r s) [IsIrrefl β s] : IsIrrefl α r :=
  ⟨fun a => mt f.map_rel_iff.2 (irrefl (f a))⟩
#align rel_embedding.is_irrefl RelEmbedding.isIrrefl
-/

#print RelEmbedding.isRefl /-
protected theorem isRefl (f : r ↪r s) [IsRefl β s] : IsRefl α r :=
  ⟨fun a => f.map_rel_iff.1 <| refl _⟩
#align rel_embedding.is_refl RelEmbedding.isRefl
-/

#print RelEmbedding.isSymm /-
protected theorem isSymm (f : r ↪r s) [IsSymm β s] : IsSymm α r :=
  ⟨fun a b => imp_imp_imp f.map_rel_iff.2 f.map_rel_iff.1 symm⟩
#align rel_embedding.is_symm RelEmbedding.isSymm
-/

#print RelEmbedding.isAsymm /-
protected theorem isAsymm (f : r ↪r s) [IsAsymm β s] : IsAsymm α r :=
  ⟨fun a b h₁ h₂ => asymm (f.map_rel_iff.2 h₁) (f.map_rel_iff.2 h₂)⟩
#align rel_embedding.is_asymm RelEmbedding.isAsymm
-/

#print RelEmbedding.isAntisymm /-
protected theorem isAntisymm : ∀ (f : r ↪r s) [IsAntisymm β s], IsAntisymm α r
  | ⟨f, o⟩, ⟨H⟩ => ⟨fun a b h₁ h₂ => f.inj' (H _ _ (o.2 h₁) (o.2 h₂))⟩
#align rel_embedding.is_antisymm RelEmbedding.isAntisymm
-/

#print RelEmbedding.isTrans /-
protected theorem isTrans : ∀ (f : r ↪r s) [IsTrans β s], IsTrans α r
  | ⟨f, o⟩, ⟨H⟩ => ⟨fun a b c h₁ h₂ => o.1 (H _ _ _ (o.2 h₁) (o.2 h₂))⟩
#align rel_embedding.is_trans RelEmbedding.isTrans
-/

#print RelEmbedding.isTotal /-
protected theorem isTotal : ∀ (f : r ↪r s) [IsTotal β s], IsTotal α r
  | ⟨f, o⟩, ⟨H⟩ => ⟨fun a b => (or_congr o o).1 (H _ _)⟩
#align rel_embedding.is_total RelEmbedding.isTotal
-/

#print RelEmbedding.isPreorder /-
protected theorem isPreorder : ∀ (f : r ↪r s) [IsPreorder β s], IsPreorder α r
  | f, H => { f.is_refl, f.is_trans with }
#align rel_embedding.is_preorder RelEmbedding.isPreorder
-/

#print RelEmbedding.isPartialOrder /-
protected theorem isPartialOrder : ∀ (f : r ↪r s) [IsPartialOrder β s], IsPartialOrder α r
  | f, H => { f.is_preorder, f.is_antisymm with }
#align rel_embedding.is_partial_order RelEmbedding.isPartialOrder
-/

#print RelEmbedding.isLinearOrder /-
protected theorem isLinearOrder : ∀ (f : r ↪r s) [IsLinearOrder β s], IsLinearOrder α r
  | f, H => { f.is_partial_order, f.is_total with }
#align rel_embedding.is_linear_order RelEmbedding.isLinearOrder
-/

#print RelEmbedding.isStrictOrder /-
protected theorem isStrictOrder : ∀ (f : r ↪r s) [IsStrictOrder β s], IsStrictOrder α r
  | f, H => { f.is_irrefl, f.is_trans with }
#align rel_embedding.is_strict_order RelEmbedding.isStrictOrder
-/

#print RelEmbedding.isTrichotomous /-
protected theorem isTrichotomous : ∀ (f : r ↪r s) [IsTrichotomous β s], IsTrichotomous α r
  | ⟨f, o⟩, ⟨H⟩ => ⟨fun a b => (or_congr o (or_congr f.inj'.eq_iff o)).1 (H _ _)⟩
#align rel_embedding.is_trichotomous RelEmbedding.isTrichotomous
-/

#print RelEmbedding.isStrictTotalOrder /-
protected theorem isStrictTotalOrder :
    ∀ (f : r ↪r s) [IsStrictTotalOrder β s], IsStrictTotalOrder α r
  | f, H => { f.is_trichotomous, f.is_strict_order with }
#align rel_embedding.is_strict_total_order RelEmbedding.isStrictTotalOrder
-/

#print RelEmbedding.acc /-
protected theorem acc (f : r ↪r s) (a : α) : Acc s (f a) → Acc r a :=
  by
  generalize h : f a = b; intro ac
  induction' ac with _ H IH generalizing a; subst h
  exact ⟨_, fun a' h => IH (f a') (f.map_rel_iff.2 h) _ rfl⟩
#align rel_embedding.acc RelEmbedding.acc
-/

#print RelEmbedding.wellFounded /-
protected theorem wellFounded : ∀ (f : r ↪r s) (h : WellFounded s), WellFounded r
  | f, ⟨H⟩ => ⟨fun a => f.Acc _ (H _)⟩
#align rel_embedding.well_founded RelEmbedding.wellFounded
-/

#print RelEmbedding.isWellFounded /-
protected theorem isWellFounded (f : r ↪r s) [IsWellFounded β s] : IsWellFounded α r :=
  ⟨f.WellFounded IsWellFounded.wf⟩
#align rel_embedding.is_well_founded RelEmbedding.isWellFounded
-/

#print RelEmbedding.isWellOrder /-
protected theorem isWellOrder : ∀ (f : r ↪r s) [IsWellOrder β s], IsWellOrder α r
  | f, H => { f.is_strict_total_order with wf := f.well_founded H.wf }
#align rel_embedding.is_well_order RelEmbedding.isWellOrder
-/

end RelEmbedding

#print Subtype.wellFoundedLT /-
instance Subtype.wellFoundedLT [LT α] [WellFoundedLT α] (p : α → Prop) :
    WellFoundedLT (Subtype p) :=
  (Subtype.relEmbedding (· < ·) p).IsWellFounded
#align subtype.well_founded_lt Subtype.wellFoundedLT
-/

#print Subtype.wellFoundedGT /-
instance Subtype.wellFoundedGT [LT α] [WellFoundedGT α] (p : α → Prop) :
    WellFoundedGT (Subtype p) :=
  (Subtype.relEmbedding (· > ·) p).IsWellFounded
#align subtype.well_founded_gt Subtype.wellFoundedGT
-/

#print Quotient.mkRelHom /-
/-- `quotient.mk` as a relation homomorphism between the relation and the lift of a relation. -/
@[simps]
def Quotient.mkRelHom [Setoid α] {r : α → α → Prop} (H) : r →r Quotient.lift₂ r H :=
  ⟨@Quotient.mk' α _, fun _ _ => id⟩
#align quotient.mk_rel_hom Quotient.mkRelHom
-/

#print Quotient.outRelEmbedding /-
/-- `quotient.out` as a relation embedding between the lift of a relation and the relation. -/
@[simps]
noncomputable def Quotient.outRelEmbedding [Setoid α] {r : α → α → Prop} (H) :
    Quotient.lift₂ r H ↪r r :=
  ⟨Embedding.quotientOut α,
    by
    refine' fun x y => Quotient.induction_on₂ x y fun a b => _
    apply iff_iff_eq.2 (H _ _ _ _ _ _) <;> apply Quotient.mk_out⟩
#align quotient.out_rel_embedding Quotient.outRelEmbedding
-/

/- warning: quotient.out'_rel_embedding clashes with rel_embedding.quotient.out'_rel_embedding -> Quotient.out'RelEmbedding
Case conversion may be inaccurate. Consider using '#align quotient.out'_rel_embedding Quotient.out'RelEmbeddingₓ'. -/
#print Quotient.out'RelEmbedding /-
/-- `quotient.out'` as a relation embedding between the lift of a relation and the relation. -/
@[simps]
noncomputable def Quotient.out'RelEmbedding {s : Setoid α} {r : α → α → Prop} (H) :
    (fun a b => Quotient.liftOn₂' a b r H) ↪r r :=
  { Quotient.outRelEmbedding _ with toFun := Quotient.out' }
#align quotient.out'_rel_embedding Quotient.out'RelEmbedding
-/

#print acc_lift₂_iff /-
@[simp]
theorem acc_lift₂_iff [Setoid α] {r : α → α → Prop} {H} {a} :
    Acc (Quotient.lift₂ r H) ⟦a⟧ ↔ Acc r a :=
  by
  constructor
  · exact RelHomClass.acc (Quotient.mkRelHom H) a
  · intro ac
    induction' ac with _ H IH; dsimp at IH 
    refine' ⟨_, fun q h => _⟩
    obtain ⟨a', rfl⟩ := q.exists_rep
    exact IH a' h
#align acc_lift₂_iff acc_lift₂_iff
-/

#print acc_liftOn₂'_iff /-
@[simp]
theorem acc_liftOn₂'_iff {s : Setoid α} {r : α → α → Prop} {H} {a} :
    Acc (fun x y => Quotient.liftOn₂' x y r H) (Quotient.mk'' a : Quotient s) ↔ Acc r a :=
  acc_lift₂_iff
#align acc_lift_on₂'_iff acc_liftOn₂'_iff
-/

#print wellFounded_lift₂_iff /-
/-- A relation is well founded iff its lift to a quotient is. -/
theorem wellFounded_lift₂_iff [Setoid α] {r : α → α → Prop} {H} :
    WellFounded (Quotient.lift₂ r H) ↔ WellFounded r :=
  by
  constructor
  · exact RelHomClass.wellFounded (Quotient.mkRelHom H)
  · refine' fun wf => ⟨fun q => _⟩
    obtain ⟨a, rfl⟩ := q.exists_rep
    exact acc_lift₂_iff.2 (wf.apply a)
#align well_founded_lift₂_iff wellFounded_lift₂_iff
-/

alias wellFounded_lift₂_iff ↔ WellFounded.of_quotient_lift₂ WellFounded.quotient_lift₂
#align well_founded.of_quotient_lift₂ WellFounded.of_quotient_lift₂
#align well_founded.quotient_lift₂ WellFounded.quotient_lift₂

#print wellFounded_liftOn₂'_iff /-
@[simp]
theorem wellFounded_liftOn₂'_iff {s : Setoid α} {r : α → α → Prop} {H} :
    (WellFounded fun x y : Quotient s => Quotient.liftOn₂' x y r H) ↔ WellFounded r :=
  wellFounded_lift₂_iff
#align well_founded_lift_on₂'_iff wellFounded_liftOn₂'_iff
-/

alias wellFounded_liftOn₂'_iff ↔ WellFounded.of_quotient_liftOn₂' WellFounded.quotient_liftOn₂'
#align well_founded.of_quotient_lift_on₂' WellFounded.of_quotient_liftOn₂'
#align well_founded.quotient_lift_on₂' WellFounded.quotient_liftOn₂'

namespace RelEmbedding

#print RelEmbedding.ofMapRelIff /-
/--
To define an relation embedding from an antisymmetric relation `r` to a reflexive relation `s` it
suffices to give a function together with a proof that it satisfies `s (f a) (f b) ↔ r a b`.
-/
def ofMapRelIff (f : α → β) [IsAntisymm α r] [IsRefl β s] (hf : ∀ a b, s (f a) (f b) ↔ r a b) :
    r ↪r s where
  toFun := f
  inj' x y h := antisymm ((hf _ _).1 (h ▸ refl _)) ((hf _ _).1 (h ▸ refl _))
  map_rel_iff' := hf
#align rel_embedding.of_map_rel_iff RelEmbedding.ofMapRelIff
-/

#print RelEmbedding.ofMapRelIff_coe /-
@[simp]
theorem ofMapRelIff_coe (f : α → β) [IsAntisymm α r] [IsRefl β s]
    (hf : ∀ a b, s (f a) (f b) ↔ r a b) : ⇑(ofMapRelIff f hf : r ↪r s) = f :=
  rfl
#align rel_embedding.of_map_rel_iff_coe RelEmbedding.ofMapRelIff_coe
-/

#print RelEmbedding.ofMonotone /-
/-- It suffices to prove `f` is monotone between strict relations
  to show it is a relation embedding. -/
def ofMonotone [IsTrichotomous α r] [IsAsymm β s] (f : α → β) (H : ∀ a b, r a b → s (f a) (f b)) :
    r ↪r s := by
  haveI := @IsAsymm.isIrrefl β s _
  refine' ⟨⟨f, fun a b e => _⟩, fun a b => ⟨fun h => _, H _ _⟩⟩
  ·
    refine' ((@trichotomous _ r _ a b).resolve_left _).resolve_right _ <;>
      exact fun h => @irrefl _ s _ _ (by simpa [e] using H _ _ h)
  · refine' (@trichotomous _ r _ a b).resolve_right (Or.ndrec (fun e => _) fun h' => _)
    · subst e; exact irrefl _ h
    · exact asymm (H _ _ h') h
#align rel_embedding.of_monotone RelEmbedding.ofMonotone
-/

#print RelEmbedding.ofMonotone_coe /-
@[simp]
theorem ofMonotone_coe [IsTrichotomous α r] [IsAsymm β s] (f : α → β) (H) :
    (@ofMonotone _ _ r s _ _ f H : α → β) = f :=
  rfl
#align rel_embedding.of_monotone_coe RelEmbedding.ofMonotone_coe
-/

#print RelEmbedding.ofIsEmpty /-
/-- A relation embedding from an empty type. -/
def ofIsEmpty (r : α → α → Prop) (s : β → β → Prop) [IsEmpty α] : r ↪r s :=
  ⟨Embedding.ofIsEmpty, isEmptyElim⟩
#align rel_embedding.of_is_empty RelEmbedding.ofIsEmpty
-/

#print RelEmbedding.sumLiftRelInl /-
/-- `sum.inl` as a relation embedding into `sum.lift_rel r s`. -/
@[simps]
def sumLiftRelInl (r : α → α → Prop) (s : β → β → Prop) : r ↪r Sum.LiftRel r s
    where
  toFun := Sum.inl
  inj' := Sum.inl_injective
  map_rel_iff' a b := Sum.liftRel_inl_inl
#align rel_embedding.sum_lift_rel_inl RelEmbedding.sumLiftRelInl
-/

#print RelEmbedding.sumLiftRelInr /-
/-- `sum.inr` as a relation embedding into `sum.lift_rel r s`. -/
@[simps]
def sumLiftRelInr (r : α → α → Prop) (s : β → β → Prop) : s ↪r Sum.LiftRel r s
    where
  toFun := Sum.inr
  inj' := Sum.inr_injective
  map_rel_iff' a b := Sum.liftRel_inr_inr
#align rel_embedding.sum_lift_rel_inr RelEmbedding.sumLiftRelInr
-/

#print RelEmbedding.sumLiftRelMap /-
/-- `sum.map` as a relation embedding between `sum.lift_rel` relations. -/
@[simps]
def sumLiftRelMap (f : r ↪r s) (g : t ↪r u) : Sum.LiftRel r t ↪r Sum.LiftRel s u
    where
  toFun := Sum.map f g
  inj' := f.Injective.sum_map g.Injective
  map_rel_iff' := by rintro (a | b) (c | d) <;> simp [f.map_rel_iff, g.map_rel_iff]
#align rel_embedding.sum_lift_rel_map RelEmbedding.sumLiftRelMap
-/

#print RelEmbedding.sumLexInl /-
/-- `sum.inl` as a relation embedding into `sum.lex r s`. -/
@[simps]
def sumLexInl (r : α → α → Prop) (s : β → β → Prop) : r ↪r Sum.Lex r s
    where
  toFun := Sum.inl
  inj' := Sum.inl_injective
  map_rel_iff' a b := Sum.lex_inl_inl
#align rel_embedding.sum_lex_inl RelEmbedding.sumLexInl
-/

#print RelEmbedding.sumLexInr /-
/-- `sum.inr` as a relation embedding into `sum.lex r s`. -/
@[simps]
def sumLexInr (r : α → α → Prop) (s : β → β → Prop) : s ↪r Sum.Lex r s
    where
  toFun := Sum.inr
  inj' := Sum.inr_injective
  map_rel_iff' a b := Sum.lex_inr_inr
#align rel_embedding.sum_lex_inr RelEmbedding.sumLexInr
-/

#print RelEmbedding.sumLexMap /-
/-- `sum.map` as a relation embedding between `sum.lex` relations. -/
@[simps]
def sumLexMap (f : r ↪r s) (g : t ↪r u) : Sum.Lex r t ↪r Sum.Lex s u
    where
  toFun := Sum.map f g
  inj' := f.Injective.sum_map g.Injective
  map_rel_iff' := by rintro (a | b) (c | d) <;> simp [f.map_rel_iff, g.map_rel_iff]
#align rel_embedding.sum_lex_map RelEmbedding.sumLexMap
-/

#print RelEmbedding.prodLexMkLeft /-
/-- `λ b, prod.mk a b` as a relation embedding. -/
@[simps]
def prodLexMkLeft (s : β → β → Prop) {a : α} (h : ¬r a a) : s ↪r Prod.Lex r s
    where
  toFun := Prod.mk a
  inj' := Prod.mk.inj_left a
  map_rel_iff' b₁ b₂ := by simp [Prod.lex_def, h]
#align rel_embedding.prod_lex_mk_left RelEmbedding.prodLexMkLeft
-/

#print RelEmbedding.prodLexMkRight /-
/-- `λ a, prod.mk a b` as a relation embedding. -/
@[simps]
def prodLexMkRight (r : α → α → Prop) {b : β} (h : ¬s b b) : r ↪r Prod.Lex r s
    where
  toFun a := (a, b)
  inj' := Prod.mk.inj_right b
  map_rel_iff' a₁ a₂ := by simp [Prod.lex_def, h]
#align rel_embedding.prod_lex_mk_right RelEmbedding.prodLexMkRight
-/

#print RelEmbedding.prodLexMap /-
/-- `prod.map` as a relation embedding. -/
@[simps]
def prodLexMap (f : r ↪r s) (g : t ↪r u) : Prod.Lex r t ↪r Prod.Lex s u
    where
  toFun := Prod.map f g
  inj' := f.Injective.Prod_map g.Injective
  map_rel_iff' a b := by simp [Prod.lex_def, f.map_rel_iff, g.map_rel_iff]
#align rel_embedding.prod_lex_map RelEmbedding.prodLexMap
-/

end RelEmbedding

#print RelIso /-
/-- A relation isomorphism is an equivalence that is also a relation embedding. -/
structure RelIso {α β : Type _} (r : α → α → Prop) (s : β → β → Prop) extends α ≃ β where
  map_rel_iff' : ∀ {a b}, s (to_equiv a) (to_equiv b) ↔ r a b
#align rel_iso RelIso
-/

infixl:25 " ≃r " => RelIso

namespace RelIso

#print RelIso.toRelEmbedding /-
/-- Convert an `rel_iso` to an `rel_embedding`. This function is also available as a coercion
but often it is easier to write `f.to_rel_embedding` than to write explicitly `r` and `s`
in the target type. -/
def toRelEmbedding (f : r ≃r s) : r ↪r s :=
  ⟨f.toEquiv.toEmbedding, fun _ _ => f.map_rel_iff'⟩
#align rel_iso.to_rel_embedding RelIso.toRelEmbedding
-/

#print RelIso.toEquiv_injective /-
theorem toEquiv_injective : Injective (toEquiv : r ≃r s → α ≃ β)
  | ⟨e₁, o₁⟩, ⟨e₂, o₂⟩, h => by congr; exact h
#align rel_iso.to_equiv_injective RelIso.toEquiv_injective
-/

instance : Coe (r ≃r s) (r ↪r s) :=
  ⟨toRelEmbedding⟩

-- see Note [function coercion]
instance : CoeFun (r ≃r s) fun _ => α → β :=
  ⟨fun f => f⟩

-- TODO: define and instantiate a `rel_iso_class` when `equiv_like` is defined
instance : RelHomClass (r ≃r s) r s where
  coe := coeFn
  coe_injective' := Equiv.coe_fn_injective.comp toEquiv_injective
  map_rel f a b := Iff.mpr (map_rel_iff' f)

@[simp]
theorem toRelEmbedding_eq_coe (f : r ≃r s) : f.toRelEmbedding = f :=
  rfl
#align rel_iso.to_rel_embedding_eq_coe RelIso.toRelEmbedding_eq_coe

@[simp]
theorem coe_coeFn (f : r ≃r s) : ((f : r ↪r s) : α → β) = f :=
  rfl
#align rel_iso.coe_coe_fn RelIso.coe_coeFn

#print RelIso.map_rel_iff /-
theorem map_rel_iff (f : r ≃r s) {a b} : s (f a) (f b) ↔ r a b :=
  f.map_rel_iff'
#align rel_iso.map_rel_iff RelIso.map_rel_iff
-/

#print RelIso.coe_fn_mk /-
@[simp]
theorem coe_fn_mk (f : α ≃ β) (o : ∀ ⦃a b⦄, s (f a) (f b) ↔ r a b) : (RelIso.mk f o : α → β) = f :=
  rfl
#align rel_iso.coe_fn_mk RelIso.coe_fn_mk
-/

#print RelIso.coe_fn_toEquiv /-
@[simp]
theorem coe_fn_toEquiv (f : r ≃r s) : (f.toEquiv : α → β) = f :=
  rfl
#align rel_iso.coe_fn_to_equiv RelIso.coe_fn_toEquiv
-/

#print RelIso.coe_fn_injective /-
/-- The map `coe_fn : (r ≃r s) → (α → β)` is injective. Lean fails to parse
`function.injective (λ e : r ≃r s, (e : α → β))`, so we use a trick to say the same. -/
theorem coe_fn_injective : @Function.Injective (r ≃r s) (α → β) coeFn :=
  FunLike.coe_injective
#align rel_iso.coe_fn_injective RelIso.coe_fn_injective
-/

#print RelIso.ext /-
@[ext]
theorem ext ⦃f g : r ≃r s⦄ (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext f g h
#align rel_iso.ext RelIso.ext
-/

#print RelIso.ext_iff /-
theorem ext_iff {f g : r ≃r s} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align rel_iso.ext_iff RelIso.ext_iff
-/

#print RelIso.symm /-
/-- Inverse map of a relation isomorphism is a relation isomorphism. -/
@[symm]
protected def symm (f : r ≃r s) : s ≃r r :=
  ⟨f.toEquiv.symm, fun a b => by erw [← f.map_rel_iff, f.1.apply_symm_apply, f.1.apply_symm_apply]⟩
#align rel_iso.symm RelIso.symm
-/

#print RelIso.Simps.apply /-
/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
  because it is a composition of multiple projections. -/
def Simps.apply (h : r ≃r s) : α → β :=
  h
#align rel_iso.simps.apply RelIso.Simps.apply
-/

#print RelIso.Simps.symm_apply /-
/-- See Note [custom simps projection]. -/
def Simps.symm_apply (h : r ≃r s) : β → α :=
  h.symm
#align rel_iso.simps.symm_apply RelIso.Simps.symm_apply
-/

initialize_simps_projections RelIso (to_equiv_to_fun → apply, to_equiv_inv_fun → symm_apply,
  -toEquiv)

#print RelIso.refl /-
/-- Identity map is a relation isomorphism. -/
@[refl, simps apply]
protected def refl (r : α → α → Prop) : r ≃r r :=
  ⟨Equiv.refl _, fun a b => Iff.rfl⟩
#align rel_iso.refl RelIso.refl
-/

#print RelIso.trans /-
/-- Composition of two relation isomorphisms is a relation isomorphism. -/
@[trans, simps apply]
protected def trans (f₁ : r ≃r s) (f₂ : s ≃r t) : r ≃r t :=
  ⟨f₁.toEquiv.trans f₂.toEquiv, fun a b => f₂.map_rel_iff.trans f₁.map_rel_iff⟩
#align rel_iso.trans RelIso.trans
-/

instance (r : α → α → Prop) : Inhabited (r ≃r r) :=
  ⟨RelIso.refl _⟩

#print RelIso.default_def /-
@[simp]
theorem default_def (r : α → α → Prop) : default = RelIso.refl r :=
  rfl
#align rel_iso.default_def RelIso.default_def
-/

#print RelIso.cast /-
/-- A relation isomorphism between equal relations on equal types. -/
@[simps toEquiv apply]
protected def cast {α β : Type u} {r : α → α → Prop} {s : β → β → Prop} (h₁ : α = β)
    (h₂ : HEq r s) : r ≃r s :=
  ⟨Equiv.cast h₁, fun a b => by subst h₁; rw [eq_of_hEq h₂]; rfl⟩
#align rel_iso.cast RelIso.cast
-/

#print RelIso.cast_symm /-
@[simp]
protected theorem cast_symm {α β : Type u} {r : α → α → Prop} {s : β → β → Prop} (h₁ : α = β)
    (h₂ : HEq r s) : (RelIso.cast h₁ h₂).symm = RelIso.cast h₁.symm h₂.symm :=
  rfl
#align rel_iso.cast_symm RelIso.cast_symm
-/

#print RelIso.cast_refl /-
@[simp]
protected theorem cast_refl {α : Type u} {r : α → α → Prop} (h₁ : α = α := rfl)
    (h₂ : HEq r r := HEq.rfl) : RelIso.cast h₁ h₂ = RelIso.refl r :=
  rfl
#align rel_iso.cast_refl RelIso.cast_refl
-/

#print RelIso.cast_trans /-
@[simp]
protected theorem cast_trans {α β γ : Type u} {r : α → α → Prop} {s : β → β → Prop}
    {t : γ → γ → Prop} (h₁ : α = β) (h₁' : β = γ) (h₂ : HEq r s) (h₂' : HEq s t) :
    (RelIso.cast h₁ h₂).trans (RelIso.cast h₁' h₂') = RelIso.cast (h₁.trans h₁') (h₂.trans h₂') :=
  ext fun x => by subst h₁; rfl
#align rel_iso.cast_trans RelIso.cast_trans
-/

#print RelIso.swap /-
/-- a relation isomorphism is also a relation isomorphism between dual relations. -/
protected def swap (f : r ≃r s) : swap r ≃r swap s :=
  ⟨f.toEquiv, fun _ _ => f.map_rel_iff⟩
#align rel_iso.swap RelIso.swap
-/

#print RelIso.coe_fn_symm_mk /-
@[simp]
theorem coe_fn_symm_mk (f o) : ((@RelIso.mk _ _ r s f o).symm : β → α) = f.symm :=
  rfl
#align rel_iso.coe_fn_symm_mk RelIso.coe_fn_symm_mk
-/

#print RelIso.apply_symm_apply /-
@[simp]
theorem apply_symm_apply (e : r ≃r s) (x : β) : e (e.symm x) = x :=
  e.toEquiv.apply_symm_apply x
#align rel_iso.apply_symm_apply RelIso.apply_symm_apply
-/

#print RelIso.symm_apply_apply /-
@[simp]
theorem symm_apply_apply (e : r ≃r s) (x : α) : e.symm (e x) = x :=
  e.toEquiv.symm_apply_apply x
#align rel_iso.symm_apply_apply RelIso.symm_apply_apply
-/

#print RelIso.rel_symm_apply /-
theorem rel_symm_apply (e : r ≃r s) {x y} : r x (e.symm y) ↔ s (e x) y := by
  rw [← e.map_rel_iff, e.apply_symm_apply]
#align rel_iso.rel_symm_apply RelIso.rel_symm_apply
-/

#print RelIso.symm_apply_rel /-
theorem symm_apply_rel (e : r ≃r s) {x y} : r (e.symm x) y ↔ s x (e y) := by
  rw [← e.map_rel_iff, e.apply_symm_apply]
#align rel_iso.symm_apply_rel RelIso.symm_apply_rel
-/

#print RelIso.bijective /-
protected theorem bijective (e : r ≃r s) : Bijective e :=
  e.toEquiv.Bijective
#align rel_iso.bijective RelIso.bijective
-/

#print RelIso.injective /-
protected theorem injective (e : r ≃r s) : Injective e :=
  e.toEquiv.Injective
#align rel_iso.injective RelIso.injective
-/

#print RelIso.surjective /-
protected theorem surjective (e : r ≃r s) : Surjective e :=
  e.toEquiv.Surjective
#align rel_iso.surjective RelIso.surjective
-/

#print RelIso.eq_iff_eq /-
@[simp]
theorem eq_iff_eq (f : r ≃r s) {a b} : f a = f b ↔ a = b :=
  f.Injective.eq_iff
#align rel_iso.eq_iff_eq RelIso.eq_iff_eq
-/

#print RelIso.preimage /-
/-- Any equivalence lifts to a relation isomorphism between `s` and its preimage. -/
protected def preimage (f : α ≃ β) (s : β → β → Prop) : f ⁻¹'o s ≃r s :=
  ⟨f, fun a b => Iff.rfl⟩
#align rel_iso.preimage RelIso.preimage
-/

#print RelIso.IsWellOrder.preimage /-
instance IsWellOrder.preimage {α : Type u} (r : α → α → Prop) [IsWellOrder α r] (f : β ≃ α) :
    IsWellOrder β (f ⁻¹'o r) :=
  @RelEmbedding.isWellOrder _ _ (f ⁻¹'o r) r (RelIso.preimage f r) _
#align rel_iso.is_well_order.preimage RelIso.IsWellOrder.preimage
-/

#print RelIso.IsWellOrder.ulift /-
instance IsWellOrder.ulift {α : Type u} (r : α → α → Prop) [IsWellOrder α r] :
    IsWellOrder (ULift α) (ULift.down ⁻¹'o r) :=
  IsWellOrder.preimage r Equiv.ulift
#align rel_iso.is_well_order.ulift RelIso.IsWellOrder.ulift
-/

#print RelIso.ofSurjective /-
/-- A surjective relation embedding is a relation isomorphism. -/
@[simps apply]
noncomputable def ofSurjective (f : r ↪r s) (H : Surjective f) : r ≃r s :=
  ⟨Equiv.ofBijective f ⟨f.Injective, H⟩, fun a b => f.map_rel_iff⟩
#align rel_iso.of_surjective RelIso.ofSurjective
-/

#print RelIso.sumLexCongr /-
/-- Given relation isomorphisms `r₁ ≃r s₁` and `r₂ ≃r s₂`, construct a relation isomorphism for the
lexicographic orders on the sum.
-/
def sumLexCongr {α₁ α₂ β₁ β₂ r₁ r₂ s₁ s₂} (e₁ : @RelIso α₁ β₁ r₁ s₁) (e₂ : @RelIso α₂ β₂ r₂ s₂) :
    Sum.Lex r₁ r₂ ≃r Sum.Lex s₁ s₂ :=
  ⟨Equiv.sumCongr e₁.toEquiv e₂.toEquiv, fun a b => by
    cases' e₁ with f hf <;> cases' e₂ with g hg <;> cases a <;> cases b <;> simp [hf, hg]⟩
#align rel_iso.sum_lex_congr RelIso.sumLexCongr
-/

#print RelIso.prodLexCongr /-
/-- Given relation isomorphisms `r₁ ≃r s₁` and `r₂ ≃r s₂`, construct a relation isomorphism for the
lexicographic orders on the product.
-/
def prodLexCongr {α₁ α₂ β₁ β₂ r₁ r₂ s₁ s₂} (e₁ : @RelIso α₁ β₁ r₁ s₁) (e₂ : @RelIso α₂ β₂ r₂ s₂) :
    Prod.Lex r₁ r₂ ≃r Prod.Lex s₁ s₂ :=
  ⟨Equiv.prodCongr e₁.toEquiv e₂.toEquiv, fun a b => by
    simp [Prod.lex_def, e₁.map_rel_iff, e₂.map_rel_iff]⟩
#align rel_iso.prod_lex_congr RelIso.prodLexCongr
-/

#print RelIso.relIsoOfIsEmpty /-
/-- Two relations on empty types are isomorphic. -/
def relIsoOfIsEmpty (r : α → α → Prop) (s : β → β → Prop) [IsEmpty α] [IsEmpty β] : r ≃r s :=
  ⟨Equiv.equivOfIsEmpty α β, isEmptyElim⟩
#align rel_iso.rel_iso_of_is_empty RelIso.relIsoOfIsEmpty
-/

#print RelIso.relIsoOfUniqueOfIrrefl /-
/-- Two irreflexive relations on a unique type are isomorphic. -/
def relIsoOfUniqueOfIrrefl (r : α → α → Prop) (s : β → β → Prop) [IsIrrefl α r] [IsIrrefl β s]
    [Unique α] [Unique β] : r ≃r s :=
  ⟨Equiv.equivOfUnique α β, fun x y => by
    simp [not_rel_of_subsingleton r, not_rel_of_subsingleton s]⟩
#align rel_iso.rel_iso_of_unique_of_irrefl RelIso.relIsoOfUniqueOfIrrefl
-/

#print RelIso.relIsoOfUniqueOfRefl /-
/-- Two reflexive relations on a unique type are isomorphic. -/
def relIsoOfUniqueOfRefl (r : α → α → Prop) (s : β → β → Prop) [IsRefl α r] [IsRefl β s] [Unique α]
    [Unique β] : r ≃r s :=
  ⟨Equiv.equivOfUnique α β, fun x y => by simp [rel_of_subsingleton r, rel_of_subsingleton s]⟩
#align rel_iso.rel_iso_of_unique_of_refl RelIso.relIsoOfUniqueOfRefl
-/

end RelIso

