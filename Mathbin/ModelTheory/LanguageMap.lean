/-
Copyright (c) 2021 Aaron Anderson, Jesse Michael Han, Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson, Jesse Michael Han, Floris van Doorn

! This file was ported from Lean 3 source module model_theory.language_map
! leanprover-community/mathlib commit 09597669f02422ed388036273d8848119699c22f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.ModelTheory.Basic

/-!
# Language Maps
Maps between first-order languages in the style of the
[Flypitch project](https://flypitch.github.io/), as well as several important maps between
structures.

## Main Definitions
* A `first_order.language.Lhom`, denoted `L →ᴸ L'`, is a map between languages, sending the symbols
  of one to symbols of the same kind and arity in the other.
* A `first_order.language.Lequiv`, denoted `L ≃ᴸ L'`, is an invertible language homomorphism.
* `first_order.language.with_constants` is defined so that if `M` is an `L.Structure` and
  `A : set M`, `L.with_constants A`, denoted `L[[A]]`, is a language which adds constant symbols for
  elements of `A` to `L`.

## References
For the Flypitch project:
- [J. Han, F. van Doorn, *A formal proof of the independence of the continuum hypothesis*]
[flypitch_cpp]
- [J. Han, F. van Doorn, *A formalization of forcing and the unprovability of
the continuum hypothesis*][flypitch_itp]

-/


universe u v u' v' w w'

namespace FirstOrder

namespace Language

open StructureCat Cardinal

open Cardinal

variable (L : Language.{u, v}) (L' : Language.{u', v'}) {M : Type w} [L.StructureCat M]

/-- A language homomorphism maps the symbols of one language to symbols of another. -/
structure LhomCat where
  onFunction : ∀ ⦃n⦄, L.Functions n → L'.Functions n
  onRelation : ∀ ⦃n⦄, L.Relations n → L'.Relations n
#align first_order.language.Lhom FirstOrder.Language.LhomCat

-- mathport name: «expr →ᴸ »
infixl:10 " →ᴸ " => LhomCat

-- \^L
variable {L L'}

namespace LhomCat

/-- Defines a map between languages defined with `language.mk₂`. -/
protected def mk₂ {c f₁ f₂ : Type u} {r₁ r₂ : Type v} (φ₀ : c → L'.Constants)
    (φ₁ : f₁ → L'.Functions 1) (φ₂ : f₂ → L'.Functions 2) (φ₁' : r₁ → L'.Relations 1)
    (φ₂' : r₂ → L'.Relations 2) : Language.mk₂ c f₁ f₂ r₁ r₂ →ᴸ L' :=
  ⟨fun n =>
    Nat.casesOn n φ₀ fun n => Nat.casesOn n φ₁ fun n => Nat.casesOn n φ₂ fun _ => PEmpty.elim,
    fun n =>
    Nat.casesOn n PEmpty.elim fun n =>
      Nat.casesOn n φ₁' fun n => Nat.casesOn n φ₂' fun _ => PEmpty.elim⟩
#align first_order.language.Lhom.mk₂ FirstOrder.Language.LhomCat.mk₂

variable (ϕ : L →ᴸ L')

/-- Pulls a structure back along a language map. -/
def reduct (M : Type _) [L'.StructureCat M] : L.StructureCat M
    where
  funMap n f xs := funMap (ϕ.onFunction f) xs
  rel_map n r xs := RelMap (ϕ.onRelation r) xs
#align first_order.language.Lhom.reduct FirstOrder.Language.LhomCat.reduct

/-- The identity language homomorphism. -/
@[simps]
protected def id (L : Language) : L →ᴸ L :=
  ⟨fun n => id, fun n => id⟩
#align first_order.language.Lhom.id FirstOrder.Language.LhomCat.id

instance : Inhabited (L →ᴸ L) :=
  ⟨LhomCat.id L⟩

/-- The inclusion of the left factor into the sum of two languages. -/
@[simps]
protected def sumInl : L →ᴸ L.Sum L' :=
  ⟨fun n => Sum.inl, fun n => Sum.inl⟩
#align first_order.language.Lhom.sum_inl FirstOrder.Language.LhomCat.sumInl

/-- The inclusion of the right factor into the sum of two languages. -/
@[simps]
protected def sumInr : L' →ᴸ L.Sum L' :=
  ⟨fun n => Sum.inr, fun n => Sum.inr⟩
#align first_order.language.Lhom.sum_inr FirstOrder.Language.LhomCat.sumInr

variable (L L')

/-- The inclusion of an empty language into any other language. -/
@[simps]
protected def ofIsEmpty [L.IsAlgebraic] [L.IsRelational] : L →ᴸ L' :=
  ⟨fun n => (IsRelational.empty_functions n).elim, fun n => (IsAlgebraic.empty_relations n).elim⟩
#align first_order.language.Lhom.of_is_empty FirstOrder.Language.LhomCat.ofIsEmpty

variable {L L'} {L'' : Language}

@[ext]
protected theorem funext {F G : L →ᴸ L'} (h_fun : F.onFunction = G.onFunction)
    (h_rel : F.onRelation = G.onRelation) : F = G :=
  by
  cases' F with Ff Fr
  cases' G with Gf Gr
  simp only [*]
  exact And.intro h_fun h_rel
#align first_order.language.Lhom.funext FirstOrder.Language.LhomCat.funext

instance [L.IsAlgebraic] [L.IsRelational] : Unique (L →ᴸ L') :=
  ⟨⟨LhomCat.ofIsEmpty L L'⟩, fun _ =>
    LhomCat.funext (Subsingleton.elim _ _) (Subsingleton.elim _ _)⟩

theorem mk₂_funext {c f₁ f₂ : Type u} {r₁ r₂ : Type v} {F G : Language.mk₂ c f₁ f₂ r₁ r₂ →ᴸ L'}
    (h0 : ∀ c : (Language.mk₂ c f₁ f₂ r₁ r₂).Constants, F.onFunction c = G.onFunction c)
    (h1 : ∀ f : (Language.mk₂ c f₁ f₂ r₁ r₂).Functions 1, F.onFunction f = G.onFunction f)
    (h2 : ∀ f : (Language.mk₂ c f₁ f₂ r₁ r₂).Functions 2, F.onFunction f = G.onFunction f)
    (h1' : ∀ r : (Language.mk₂ c f₁ f₂ r₁ r₂).Relations 1, F.onRelation r = G.onRelation r)
    (h2' : ∀ r : (Language.mk₂ c f₁ f₂ r₁ r₂).Relations 2, F.onRelation r = G.onRelation r) :
    F = G :=
  LhomCat.funext
    (funext fun n =>
      Nat.casesOn n (funext h0) fun n =>
        Nat.casesOn n (funext h1) fun n =>
          Nat.casesOn n (funext h2) fun n => funext fun f => PEmpty.elim f)
    (funext fun n =>
      Nat.casesOn n (funext fun r => PEmpty.elim r) fun n =>
        Nat.casesOn n (funext h1') fun n =>
          Nat.casesOn n (funext h2') fun n => funext fun r => PEmpty.elim r)
#align first_order.language.Lhom.mk₂_funext FirstOrder.Language.LhomCat.mk₂_funext

/-- The composition of two language homomorphisms. -/
@[simps]
def comp (g : L' →ᴸ L'') (f : L →ᴸ L') : L →ᴸ L'' :=
  ⟨fun n F => g.1 (f.1 F), fun _ R => g.2 (f.2 R)⟩
#align first_order.language.Lhom.comp FirstOrder.Language.LhomCat.comp

-- mathport name: Lhom.comp
local infixl:60 " ∘ " => LhomCat.comp

@[simp]
theorem id_comp (F : L →ᴸ L') : LhomCat.id L' ∘ F = F :=
  by
  cases F
  rfl
#align first_order.language.Lhom.id_comp FirstOrder.Language.LhomCat.id_comp

@[simp]
theorem comp_id (F : L →ᴸ L') : F ∘ LhomCat.id L = F :=
  by
  cases F
  rfl
#align first_order.language.Lhom.comp_id FirstOrder.Language.LhomCat.comp_id

theorem comp_assoc {L3 : Language} (F : L'' →ᴸ L3) (G : L' →ᴸ L'') (H : L →ᴸ L') :
    F ∘ G ∘ H = F ∘ (G ∘ H) :=
  rfl
#align first_order.language.Lhom.comp_assoc FirstOrder.Language.LhomCat.comp_assoc

section SumElim

variable (ψ : L'' →ᴸ L')

/-- A language map defined on two factors of a sum. -/
@[simps]
protected def sumElim : L.Sum L'' →ᴸ L'
    where
  onFunction n := Sum.elim (fun f => ϕ.onFunction f) fun f => ψ.onFunction f
  onRelation n := Sum.elim (fun f => ϕ.onRelation f) fun f => ψ.onRelation f
#align first_order.language.Lhom.sum_elim FirstOrder.Language.LhomCat.sumElim

theorem sum_elim_comp_inl (ψ : L'' →ᴸ L') : ϕ.sum_elim ψ ∘ Lhom.sum_inl = ϕ :=
  LhomCat.funext (funext fun _ => rfl) (funext fun _ => rfl)
#align first_order.language.Lhom.sum_elim_comp_inl FirstOrder.Language.LhomCat.sum_elim_comp_inl

theorem sum_elim_comp_inr (ψ : L'' →ᴸ L') : ϕ.sum_elim ψ ∘ Lhom.sum_inr = ψ :=
  LhomCat.funext (funext fun _ => rfl) (funext fun _ => rfl)
#align first_order.language.Lhom.sum_elim_comp_inr FirstOrder.Language.LhomCat.sum_elim_comp_inr

theorem sum_elim_inl_inr : LhomCat.sumInl.sum_elim LhomCat.sumInr = LhomCat.id (L.Sum L') :=
  LhomCat.funext (funext fun _ => Sum.elim_inl_inr) (funext fun _ => Sum.elim_inl_inr)
#align first_order.language.Lhom.sum_elim_inl_inr FirstOrder.Language.LhomCat.sum_elim_inl_inr

theorem comp_sum_elim {L3 : Language} (θ : L' →ᴸ L3) :
    θ ∘ ϕ.sum_elim ψ = (θ ∘ ϕ).sum_elim (θ ∘ ψ) :=
  LhomCat.funext (funext fun n => Sum.comp_elim _ _ _) (funext fun n => Sum.comp_elim _ _ _)
#align first_order.language.Lhom.comp_sum_elim FirstOrder.Language.LhomCat.comp_sum_elim

end SumElim

section SumMap

variable {L₁ L₂ : Language} (ψ : L₁ →ᴸ L₂)

/-- The map between two sum-languages induced by maps on the two factors. -/
@[simps]
def sumMap : L.Sum L₁ →ᴸ L'.Sum L₂
    where
  onFunction n := Sum.map (fun f => ϕ.onFunction f) fun f => ψ.onFunction f
  onRelation n := Sum.map (fun f => ϕ.onRelation f) fun f => ψ.onRelation f
#align first_order.language.Lhom.sum_map FirstOrder.Language.LhomCat.sumMap

@[simp]
theorem sum_map_comp_inl : ϕ.sum_map ψ ∘ Lhom.sum_inl = Lhom.sum_inl ∘ ϕ :=
  LhomCat.funext (funext fun _ => rfl) (funext fun _ => rfl)
#align first_order.language.Lhom.sum_map_comp_inl FirstOrder.Language.LhomCat.sum_map_comp_inl

@[simp]
theorem sum_map_comp_inr : ϕ.sum_map ψ ∘ Lhom.sum_inr = Lhom.sum_inr ∘ ψ :=
  LhomCat.funext (funext fun _ => rfl) (funext fun _ => rfl)
#align first_order.language.Lhom.sum_map_comp_inr FirstOrder.Language.LhomCat.sum_map_comp_inr

end SumMap

/-- A language homomorphism is injective when all the maps between symbol types are. -/
protected structure Injective : Prop where
  onFunction {n} : Function.Injective fun f : L.Functions n => onFunction ϕ f
  onRelation {n} : Function.Injective fun R : L.Relations n => onRelation ϕ R
#align first_order.language.Lhom.injective FirstOrder.Language.LhomCat.Injective

/-- Pulls a `L`-structure along a language map `ϕ : L →ᴸ L'`, and then expands it
  to an `L'`-structure arbitrarily. -/
noncomputable def defaultExpansion (ϕ : L →ᴸ L')
    [∀ (n) (f : L'.Functions n), Decidable (f ∈ Set.range fun f : L.Functions n => onFunction ϕ f)]
    [∀ (n) (r : L'.Relations n), Decidable (r ∈ Set.range fun r : L.Relations n => onRelation ϕ r)]
    (M : Type _) [Inhabited M] [L.StructureCat M] : L'.StructureCat M
    where
  funMap n f xs :=
    if h' : f ∈ Set.range fun f : L.Functions n => onFunction ϕ f then funMap h'.some xs
    else default
  rel_map n r xs :=
    if h' : r ∈ Set.range fun r : L.Relations n => onRelation ϕ r then RelMap h'.some xs
    else default
#align first_order.language.Lhom.default_expansion FirstOrder.Language.LhomCat.defaultExpansion

/-- A language homomorphism is an expansion on a structure if it commutes with the interpretation of
all symbols on that structure. -/
class IsExpansionOn (M : Type _) [L.StructureCat M] [L'.StructureCat M] : Prop where
  map_on_function :
    ∀ {n} (f : L.Functions n) (x : Fin n → M), funMap (ϕ.onFunction f) x = funMap f x
  map_on_relation :
    ∀ {n} (R : L.Relations n) (x : Fin n → M), RelMap (ϕ.onRelation R) x = RelMap R x
#align first_order.language.Lhom.is_expansion_on FirstOrder.Language.LhomCat.IsExpansionOn

@[simp]
theorem map_on_function {M : Type _} [L.StructureCat M] [L'.StructureCat M] [ϕ.IsExpansionOn M] {n}
    (f : L.Functions n) (x : Fin n → M) : funMap (ϕ.onFunction f) x = funMap f x :=
  IsExpansionOn.map_on_function f x
#align first_order.language.Lhom.map_on_function FirstOrder.Language.LhomCat.map_on_function

@[simp]
theorem map_on_relation {M : Type _} [L.StructureCat M] [L'.StructureCat M] [ϕ.IsExpansionOn M] {n}
    (R : L.Relations n) (x : Fin n → M) : RelMap (ϕ.onRelation R) x = RelMap R x :=
  IsExpansionOn.map_on_relation R x
#align first_order.language.Lhom.map_on_relation FirstOrder.Language.LhomCat.map_on_relation

instance id_is_expansion_on (M : Type _) [L.StructureCat M] : IsExpansionOn (LhomCat.id L) M :=
  ⟨fun _ _ _ => rfl, fun _ _ _ => rfl⟩
#align first_order.language.Lhom.id_is_expansion_on FirstOrder.Language.LhomCat.id_is_expansion_on

instance of_is_empty_is_expansion_on (M : Type _) [L.StructureCat M] [L'.StructureCat M]
    [L.IsAlgebraic] [L.IsRelational] : IsExpansionOn (LhomCat.ofIsEmpty L L') M :=
  ⟨fun n => (IsRelational.empty_functions n).elim, fun n => (IsAlgebraic.empty_relations n).elim⟩
#align
  first_order.language.Lhom.of_is_empty_is_expansion_on FirstOrder.Language.LhomCat.of_is_empty_is_expansion_on

instance sum_elim_is_expansion_on {L'' : Language} (ψ : L'' →ᴸ L') (M : Type _) [L.StructureCat M]
    [L'.StructureCat M] [L''.StructureCat M] [ϕ.IsExpansionOn M] [ψ.IsExpansionOn M] :
    (ϕ.sum_elim ψ).IsExpansionOn M :=
  ⟨fun _ f _ => Sum.casesOn f (by simp) (by simp), fun _ R _ => Sum.casesOn R (by simp) (by simp)⟩
#align
  first_order.language.Lhom.sum_elim_is_expansion_on FirstOrder.Language.LhomCat.sum_elim_is_expansion_on

instance sum_map_is_expansion_on {L₁ L₂ : Language} (ψ : L₁ →ᴸ L₂) (M : Type _) [L.StructureCat M]
    [L'.StructureCat M] [L₁.StructureCat M] [L₂.StructureCat M] [ϕ.IsExpansionOn M]
    [ψ.IsExpansionOn M] : (ϕ.sum_map ψ).IsExpansionOn M :=
  ⟨fun _ f _ => Sum.casesOn f (by simp) (by simp), fun _ R _ => Sum.casesOn R (by simp) (by simp)⟩
#align
  first_order.language.Lhom.sum_map_is_expansion_on FirstOrder.Language.LhomCat.sum_map_is_expansion_on

instance sum_inl_is_expansion_on (M : Type _) [L.StructureCat M] [L'.StructureCat M] :
    (LhomCat.sumInl : L →ᴸ L.Sum L').IsExpansionOn M :=
  ⟨fun _ f _ => rfl, fun _ R _ => rfl⟩
#align
  first_order.language.Lhom.sum_inl_is_expansion_on FirstOrder.Language.LhomCat.sum_inl_is_expansion_on

instance sum_inr_is_expansion_on (M : Type _) [L.StructureCat M] [L'.StructureCat M] :
    (LhomCat.sumInr : L' →ᴸ L.Sum L').IsExpansionOn M :=
  ⟨fun _ f _ => rfl, fun _ R _ => rfl⟩
#align
  first_order.language.Lhom.sum_inr_is_expansion_on FirstOrder.Language.LhomCat.sum_inr_is_expansion_on

@[simp]
theorem fun_map_sum_inl [(L.Sum L').StructureCat M]
    [(LhomCat.sumInl : L →ᴸ L.Sum L').IsExpansionOn M] {n} {f : L.Functions n} {x : Fin n → M} :
    @funMap (L.Sum L') M _ n (Sum.inl f) x = funMap f x :=
  (LhomCat.sumInl : L →ᴸ L.Sum L').map_on_function f x
#align first_order.language.Lhom.fun_map_sum_inl FirstOrder.Language.LhomCat.fun_map_sum_inl

@[simp]
theorem fun_map_sum_inr [(L'.Sum L).StructureCat M]
    [(LhomCat.sumInr : L →ᴸ L'.Sum L).IsExpansionOn M] {n} {f : L.Functions n} {x : Fin n → M} :
    @funMap (L'.Sum L) M _ n (Sum.inr f) x = funMap f x :=
  (LhomCat.sumInr : L →ᴸ L'.Sum L).map_on_function f x
#align first_order.language.Lhom.fun_map_sum_inr FirstOrder.Language.LhomCat.fun_map_sum_inr

theorem sum_inl_injective : (LhomCat.sumInl : L →ᴸ L.Sum L').Injective :=
  ⟨fun n => Sum.inl_injective, fun n => Sum.inl_injective⟩
#align first_order.language.Lhom.sum_inl_injective FirstOrder.Language.LhomCat.sum_inl_injective

theorem sum_inr_injective : (LhomCat.sumInr : L' →ᴸ L.Sum L').Injective :=
  ⟨fun n => Sum.inr_injective, fun n => Sum.inr_injective⟩
#align first_order.language.Lhom.sum_inr_injective FirstOrder.Language.LhomCat.sum_inr_injective

instance (priority := 100) is_expansion_on_reduct (ϕ : L →ᴸ L') (M : Type _) [L'.StructureCat M] :
    @IsExpansionOn L L' ϕ M (ϕ.reduct M) _ :=
  letI := ϕ.reduct M
  ⟨fun _ f _ => rfl, fun _ R _ => rfl⟩
#align
  first_order.language.Lhom.is_expansion_on_reduct FirstOrder.Language.LhomCat.is_expansion_on_reduct

theorem Injective.is_expansion_on_default {ϕ : L →ᴸ L'}
    [∀ (n) (f : L'.Functions n), Decidable (f ∈ Set.range fun f : L.Functions n => onFunction ϕ f)]
    [∀ (n) (r : L'.Relations n), Decidable (r ∈ Set.range fun r : L.Relations n => onRelation ϕ r)]
    (h : ϕ.Injective) (M : Type _) [Inhabited M] [L.StructureCat M] :
    @IsExpansionOn L L' ϕ M _ (ϕ.defaultExpansion M) :=
  by
  letI := ϕ.default_expansion M
  refine' ⟨fun n f xs => _, fun n r xs => _⟩
  · have hf : ϕ.on_function f ∈ Set.range fun f : L.functions n => ϕ.on_function f := ⟨f, rfl⟩
    refine' (dif_pos hf).trans _
    rw [h.on_function hf.some_spec]
  · have hr : ϕ.on_relation r ∈ Set.range fun r : L.relations n => ϕ.on_relation r := ⟨r, rfl⟩
    refine' (dif_pos hr).trans _
    rw [h.on_relation hr.some_spec]
#align
  first_order.language.Lhom.injective.is_expansion_on_default FirstOrder.Language.LhomCat.Injective.is_expansion_on_default

end LhomCat

/-- A language equivalence maps the symbols of one language to symbols of another bijectively. -/
structure LequivCat (L L' : Language) where
  toLhom : L →ᴸ L'
  invLhom : L' →ᴸ L
  left_inv : inv_Lhom.comp to_Lhom = LhomCat.id L
  right_inv : to_Lhom.comp inv_Lhom = LhomCat.id L'
#align first_order.language.Lequiv FirstOrder.Language.LequivCat

-- mathport name: «expr ≃ᴸ »
infixl:10 " ≃ᴸ " => LequivCat

-- \^L
namespace LequivCat

variable (L)

/-- The identity equivalence from a first-order language to itself. -/
@[simps]
protected def refl : L ≃ᴸ L :=
  ⟨LhomCat.id L, LhomCat.id L, LhomCat.id_comp _, LhomCat.id_comp _⟩
#align first_order.language.Lequiv.refl FirstOrder.Language.LequivCat.refl

variable {L}

instance : Inhabited (L ≃ᴸ L) :=
  ⟨LequivCat.refl L⟩

variable {L'' : Language} (e' : L' ≃ᴸ L'') (e : L ≃ᴸ L')

/-- The inverse of an equivalence of first-order languages. -/
@[simps]
protected def symm : L' ≃ᴸ L :=
  ⟨e.invLhom, e.toLhom, e.right_inv, e.left_inv⟩
#align first_order.language.Lequiv.symm FirstOrder.Language.LequivCat.symm

/-- The composition of equivalences of first-order languages. -/
@[simps, trans]
protected def trans (e : L ≃ᴸ L') (e' : L' ≃ᴸ L'') : L ≃ᴸ L'' :=
  ⟨e'.toLhom.comp e.toLhom, e.invLhom.comp e'.invLhom, by
    rw [Lhom.comp_assoc, ← Lhom.comp_assoc e'.inv_Lhom, e'.left_inv, Lhom.id_comp, e.left_inv], by
    rw [Lhom.comp_assoc, ← Lhom.comp_assoc e.to_Lhom, e.right_inv, Lhom.id_comp, e'.right_inv]⟩
#align first_order.language.Lequiv.trans FirstOrder.Language.LequivCat.trans

end LequivCat

section ConstantsOn

variable (α : Type u')

/-- A language with constants indexed by a type. -/
@[simp]
def constantsOn : Language.{u', 0} :=
  Language.mk₂ α PEmpty PEmpty PEmpty PEmpty
#align first_order.language.constants_on FirstOrder.Language.constantsOn

variable {α}

theorem constants_on_constants : (constantsOn α).Constants = α :=
  rfl
#align first_order.language.constants_on_constants FirstOrder.Language.constants_on_constants

instance is_algebraic_constants_on : IsAlgebraic (constantsOn α) :=
  language.is_algebraic_mk₂
#align first_order.language.is_algebraic_constants_on FirstOrder.Language.is_algebraic_constants_on

instance is_relational_constants_on [ie : IsEmpty α] : IsRelational (constantsOn α) :=
  language.is_relational_mk₂
#align
  first_order.language.is_relational_constants_on FirstOrder.Language.is_relational_constants_on

instance is_empty_functions_constants_on_succ {n : ℕ} :
    IsEmpty ((constantsOn α).Functions (n + 1)) :=
  Nat.casesOn n PEmpty.is_empty fun n => Nat.casesOn n PEmpty.is_empty fun _ => PEmpty.is_empty
#align
  first_order.language.is_empty_functions_constants_on_succ FirstOrder.Language.is_empty_functions_constants_on_succ

theorem card_constants_on : (constantsOn α).card = (#α) := by simp
#align first_order.language.card_constants_on FirstOrder.Language.card_constants_on

/-- Gives a `constants_on α` structure to a type by assigning each constant a value. -/
def constantsOn.structure (f : α → M) : (constantsOn α).StructureCat M :=
  StructureCat.mk₂ f PEmpty.elim PEmpty.elim PEmpty.elim PEmpty.elim
#align first_order.language.constants_on.Structure FirstOrder.Language.constantsOn.structure

variable {β : Type v'}

/-- A map between index types induces a map between constant languages. -/
def LhomCat.constantsOnMap (f : α → β) : constantsOn α →ᴸ constantsOn β :=
  LhomCat.mk₂ f PEmpty.elim PEmpty.elim PEmpty.elim PEmpty.elim
#align first_order.language.Lhom.constants_on_map FirstOrder.Language.LhomCat.constantsOnMap

theorem constants_on_map_is_expansion_on {f : α → β} {fα : α → M} {fβ : β → M} (h : fβ ∘ f = fα) :
    @LhomCat.IsExpansionOn _ _ (LhomCat.constantsOnMap f) M (constantsOn.structure fα)
      (constantsOn.structure fβ) :=
  by
  letI := constants_on.Structure fα
  letI := constants_on.Structure fβ
  exact
    ⟨fun n => Nat.casesOn n (fun F x => (congr_fun h F : _)) fun n F => isEmptyElim F, fun _ R =>
      isEmptyElim R⟩
#align
  first_order.language.constants_on_map_is_expansion_on FirstOrder.Language.constants_on_map_is_expansion_on

end ConstantsOn

section WithConstants

variable (L)

section

variable (α : Type w')

/-- Extends a language with a constant for each element of a parameter set in `M`. -/
def withConstants : Language.{max u w', v} :=
  L.Sum (constantsOn α)
#align first_order.language.with_constants FirstOrder.Language.withConstants

-- mathport name: language.with_constants
scoped[FirstOrder] notation:95 L "[[" α "]]" => L.withConstants α

@[simp]
theorem card_with_constants :
    L[[α]].card = Cardinal.lift.{w'} L.card + Cardinal.lift.{max u v} (#α) := by
  rw [with_constants, card_sum, card_constants_on]
#align first_order.language.card_with_constants FirstOrder.Language.card_with_constants

/-- The language map adding constants.  -/
@[simps]
def lhomWithConstants : L →ᴸ L[[α]] :=
  Lhom.sum_inl
#align first_order.language.Lhom_with_constants FirstOrder.Language.lhomWithConstants

theorem Lhom_with_constants_injective : (L.lhomWithConstants α).Injective :=
  Lhom.sum_inl_injective
#align
  first_order.language.Lhom_with_constants_injective FirstOrder.Language.Lhom_with_constants_injective

variable {α}

/-- The constant symbol indexed by a particular element. -/
protected def con (a : α) : L[[α]].Constants :=
  Sum.inr a
#align first_order.language.con FirstOrder.Language.con

variable {L} (α)

/-- Adds constants to a language map.  -/
def LhomCat.addConstants {L' : Language} (φ : L →ᴸ L') : L[[α]] →ᴸ L'[[α]] :=
  φ.sum_map (LhomCat.id _)
#align first_order.language.Lhom.add_constants FirstOrder.Language.LhomCat.addConstants

instance paramsStructure (A : Set α) : (constantsOn A).StructureCat α :=
  constantsOn.structure coe
#align first_order.language.params_Structure FirstOrder.Language.paramsStructure

variable (L) (α)

/-- The language map removing an empty constant set.  -/
@[simps]
def LequivCat.addEmptyConstants [ie : IsEmpty α] : L ≃ᴸ L[[α]]
    where
  toLhom := lhomWithConstants L α
  invLhom := LhomCat.sumElim (LhomCat.id L) (LhomCat.ofIsEmpty (constantsOn α) L)
  left_inv := by rw [Lhom_with_constants, Lhom.sum_elim_comp_inl]
  right_inv := by
    simp only [Lhom.comp_sum_elim, Lhom_with_constants, Lhom.comp_id]
    exact trans (congr rfl (Subsingleton.elim _ _)) Lhom.sum_elim_inl_inr
#align
  first_order.language.Lequiv.add_empty_constants FirstOrder.Language.LequivCat.addEmptyConstants

variable {α} {β : Type _}

@[simp]
theorem with_constants_fun_map_sum_inl [L[[α]].StructureCat M]
    [(lhomWithConstants L α).IsExpansionOn M] {n} {f : L.Functions n} {x : Fin n → M} :
    @funMap (L[[α]]) M _ n (Sum.inl f) x = funMap f x :=
  (lhomWithConstants L α).map_on_function f x
#align
  first_order.language.with_constants_fun_map_sum_inl FirstOrder.Language.with_constants_fun_map_sum_inl

@[simp]
theorem with_constants_rel_map_sum_inl [L[[α]].StructureCat M]
    [(lhomWithConstants L α).IsExpansionOn M] {n} {R : L.Relations n} {x : Fin n → M} :
    @RelMap (L[[α]]) M _ n (Sum.inl R) x = RelMap R x :=
  (lhomWithConstants L α).map_on_relation R x
#align
  first_order.language.with_constants_rel_map_sum_inl FirstOrder.Language.with_constants_rel_map_sum_inl

/-- The language map extending the constant set.  -/
def lhomWithConstantsMap (f : α → β) : L[[α]] →ᴸ L[[β]] :=
  LhomCat.sumMap (LhomCat.id L) (LhomCat.constantsOnMap f)
#align first_order.language.Lhom_with_constants_map FirstOrder.Language.lhomWithConstantsMap

@[simp]
theorem LhomCat.map_constants_comp_sum_inl {f : α → β} :
    (L.lhomWithConstantsMap f).comp LhomCat.sumInl = L.lhomWithConstants β := by ext (n f R) <;> rfl
#align
  first_order.language.Lhom.map_constants_comp_sum_inl FirstOrder.Language.LhomCat.map_constants_comp_sum_inl

end

open FirstOrder

instance constantsOnSelfStructure : (constantsOn M).StructureCat M :=
  constantsOn.structure id
#align first_order.language.constants_on_self_Structure FirstOrder.Language.constantsOnSelfStructure

instance withConstantsSelfStructure : L[[M]].StructureCat M :=
  Language.sumStructure _ _ M
#align
  first_order.language.with_constants_self_Structure FirstOrder.Language.withConstantsSelfStructure

instance with_constants_self_expansion : (lhomWithConstants L M).IsExpansionOn M :=
  ⟨fun _ _ _ => rfl, fun _ _ _ => rfl⟩
#align
  first_order.language.with_constants_self_expansion FirstOrder.Language.with_constants_self_expansion

variable (α : Type _) [(constantsOn α).StructureCat M]

instance withConstantsStructure : L[[α]].StructureCat M :=
  Language.sumStructure _ _ _
#align first_order.language.with_constants_Structure FirstOrder.Language.withConstantsStructure

instance with_constants_expansion : (L.lhomWithConstants α).IsExpansionOn M :=
  ⟨fun _ _ _ => rfl, fun _ _ _ => rfl⟩
#align first_order.language.with_constants_expansion FirstOrder.Language.with_constants_expansion

instance add_empty_constants_is_expansion_on' :
    (LequivCat.addEmptyConstants L (∅ : Set M)).toLhom.IsExpansionOn M :=
  L.with_constants_expansion _
#align
  first_order.language.add_empty_constants_is_expansion_on' FirstOrder.Language.add_empty_constants_is_expansion_on'

instance add_empty_constants_symm_is_expansion_on :
    (LequivCat.addEmptyConstants L (∅ : Set M)).symm.toLhom.IsExpansionOn M :=
  LhomCat.sum_elim_is_expansion_on _ _ _
#align
  first_order.language.add_empty_constants_symm_is_expansion_on FirstOrder.Language.add_empty_constants_symm_is_expansion_on

instance add_constants_expansion {L' : Language} [L'.StructureCat M] (φ : L →ᴸ L')
    [φ.IsExpansionOn M] : (φ.addConstants α).IsExpansionOn M :=
  LhomCat.sum_map_is_expansion_on _ _ M
#align first_order.language.add_constants_expansion FirstOrder.Language.add_constants_expansion

@[simp]
theorem with_constants_fun_map_sum_inr {a : α} {x : Fin 0 → M} :
    @funMap (L[[α]]) M _ 0 (Sum.inr a : L[[α]].Functions 0) x = L.con a :=
  by
  rw [Unique.eq_default x]
  exact (Lhom.sum_inr : constants_on α →ᴸ L.sum _).map_on_function _ _
#align
  first_order.language.with_constants_fun_map_sum_inr FirstOrder.Language.with_constants_fun_map_sum_inr

variable {α} (A : Set M)

@[simp]
theorem coe_con {a : A} : (L.con a : M) = a :=
  rfl
#align first_order.language.coe_con FirstOrder.Language.coe_con

variable {A} {B : Set M} (h : A ⊆ B)

instance constants_on_map_inclusion_is_expansion_on :
    (LhomCat.constantsOnMap (Set.inclusion h)).IsExpansionOn M :=
  constants_on_map_is_expansion_on rfl
#align
  first_order.language.constants_on_map_inclusion_is_expansion_on FirstOrder.Language.constants_on_map_inclusion_is_expansion_on

instance map_constants_inclusion_is_expansion_on :
    (L.lhomWithConstantsMap (Set.inclusion h)).IsExpansionOn M :=
  LhomCat.sum_map_is_expansion_on _ _ _
#align
  first_order.language.map_constants_inclusion_is_expansion_on FirstOrder.Language.map_constants_inclusion_is_expansion_on

end WithConstants

end Language

end FirstOrder

