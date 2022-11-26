/-
Copyright (c) 2022 Chris Birkbeck. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Birkbeck
-/
import Mathbin.NumberTheory.ModularForms.SlashActions

/-!
# Slash invariant forms

This file defines functions that are invariant under a `slash_action` which forms the basis for
defining `modular_form` and `cusp_form`. We prove several instances for such spaces, in particular
that they form a module.
-/


open Complex UpperHalfPlane

open UpperHalfPlane

noncomputable section

-- mathport name: «expr↑ₘ »
local prefix:1024 "↑ₘ" => @coe _ (Matrix (Fin 2) (Fin 2) _) _

-- mathport name: «exprGL( , )⁺»
local notation "GL(" n ", " R ")" "⁺" => Matrix.gLPos (Fin n) R

-- mathport name: «exprSL( , )»
local notation "SL(" n ", " R ")" => Matrix.SpecialLinearGroup (Fin n) R

section SlashInvariantForms

open ModularForm

variable (F : Type _) (Γ : outParam <| Subgroup SL(2, ℤ)) (k : outParam ℤ)

-- mathport name: «expr ∣[ , ]»
scoped[SlashInvariantForms] notation:73 f "∣[" k:0 "," A "]" => SlashAction.map ℂ k A f

/-- Functions `ℍ → ℂ` that are invariant under the `slash_action`. -/
structure SlashInvariantForm where
  toFun : ℍ → ℂ
  slash_action_eq' : ∀ γ : Γ, to_fun∣[k,γ] = to_fun
#align slash_invariant_form SlashInvariantForm

/-- `slash_invariant_form_class F Γ k` asserts `F` is a type of bundled functions that are invariant
under the `slash_action`. -/
class SlashInvariantFormClass extends FunLike F ℍ fun _ => ℂ where
  slash_action_eq : ∀ (f : F) (γ : Γ), (f : ℍ → ℂ)∣[k,γ] = f
#align slash_invariant_form_class SlashInvariantFormClass

attribute [nolint dangerous_instance] SlashInvariantFormClass.toFunLike

instance (priority := 100) SlashInvariantFormClass.slashInvariantForm :
    SlashInvariantFormClass (SlashInvariantForm Γ k) Γ k where
  coe := SlashInvariantForm.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  slash_action_eq := SlashInvariantForm.slash_action_eq'
#align slash_invariant_form_class.slash_invariant_form SlashInvariantFormClass.slashInvariantForm

variable {F Γ k}

instance : CoeFun (SlashInvariantForm Γ k) fun _ => ℍ → ℂ :=
  FunLike.hasCoeToFun

@[simp]
theorem slash_invariant_form_to_fun_eq_coe {f : SlashInvariantForm Γ k} : f.toFun = (f : ℍ → ℂ) :=
  rfl
#align slash_invariant_form_to_fun_eq_coe slash_invariant_form_to_fun_eq_coe

@[ext.1]
theorem slash_invariant_form_ext {f g : SlashInvariantForm Γ k} (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext f g h
#align slash_invariant_form_ext slash_invariant_form_ext

/-- Copy of a `slash_invariant_form` with a new `to_fun` equal to the old one.
Useful to fix definitional equalities. -/
protected def SlashInvariantForm.copy (f : SlashInvariantForm Γ k) (f' : ℍ → ℂ) (h : f' = ⇑f) :
    SlashInvariantForm Γ k where
  toFun := f'
  slash_action_eq' := h.symm ▸ f.slash_action_eq'
#align slash_invariant_form.copy SlashInvariantForm.copy

end SlashInvariantForms

namespace SlashInvariantForm

open SlashInvariantForm

variable {F : Type _} {Γ : outParam <| Subgroup SL(2, ℤ)} {k : outParam ℤ}

@[nolint dangerous_instance]
instance (priority := 100) SlashInvariantFormClass.coeToFun [SlashInvariantFormClass F Γ k] : CoeFun F fun _ => ℍ → ℂ :=
  FunLike.hasCoeToFun
#align slash_invariant_form.slash_invariant_form_class.coe_to_fun SlashInvariantForm.SlashInvariantFormClass.coeToFun

@[simp]
theorem slash_action_eqn [SlashInvariantFormClass F Γ k] (f : F) (γ : Γ) : SlashAction.map ℂ k γ ⇑f = ⇑f :=
  SlashInvariantFormClass.slash_action_eq f γ
#align slash_invariant_form.slash_action_eqn SlashInvariantForm.slash_action_eqn

theorem slash_action_eqn' (k : ℤ) (Γ : Subgroup SL(2, ℤ)) [SlashInvariantFormClass F Γ k] (f : F) (γ : Γ) (z : ℍ) :
    f (γ • z) = ((↑ₘγ 1 0 : ℂ) * z + (↑ₘγ 1 1 : ℂ)) ^ k * f z := by
  rw [← ModularForm.slash_action_eq'_iff]
  simp
#align slash_invariant_form.slash_action_eqn' SlashInvariantForm.slash_action_eqn'

instance [SlashInvariantFormClass F Γ k] : CoeTC F (SlashInvariantForm Γ k) :=
  ⟨fun f => { toFun := f, slash_action_eq' := slash_action_eqn f }⟩

@[simp]
theorem SlashInvariantFormClass.coe_coe [SlashInvariantFormClass F Γ k] (f : F) :
    ((f : SlashInvariantForm Γ k) : ℍ → ℂ) = f :=
  rfl
#align slash_invariant_form.slash_invariant_form_class.coe_coe SlashInvariantForm.SlashInvariantFormClass.coe_coe

instance hasAdd : Add (SlashInvariantForm Γ k) :=
  ⟨fun f g =>
    { toFun := f + g, slash_action_eq' := fun γ => by convert SlashAction.add_action k γ (f : ℍ → ℂ) g <;> simp }⟩
#align slash_invariant_form.has_add SlashInvariantForm.hasAdd

@[simp]
theorem coe_add (f g : SlashInvariantForm Γ k) : ⇑(f + g) = f + g :=
  rfl
#align slash_invariant_form.coe_add SlashInvariantForm.coe_add

@[simp]
theorem add_apply (f g : SlashInvariantForm Γ k) (z : ℍ) : (f + g) z = f z + g z :=
  rfl
#align slash_invariant_form.add_apply SlashInvariantForm.add_apply

instance hasZero : Zero (SlashInvariantForm Γ k) :=
  ⟨{ toFun := 0, slash_action_eq' := SlashAction.mul_zero _ }⟩
#align slash_invariant_form.has_zero SlashInvariantForm.hasZero

@[simp]
theorem coe_zero : ⇑(0 : SlashInvariantForm Γ k) = (0 : ℍ → ℂ) :=
  rfl
#align slash_invariant_form.coe_zero SlashInvariantForm.coe_zero

instance hasCsmul : HasSmul ℂ (SlashInvariantForm Γ k) :=
  ⟨fun c f =>
    { toFun := c • f,
      slash_action_eq' := by
        intro γ
        convert SlashAction.smul_action k γ (⇑f) c
        exact (f.slash_action_eq' γ).symm }⟩
#align slash_invariant_form.has_csmul SlashInvariantForm.hasCsmul

@[simp]
theorem coe_csmul (f : SlashInvariantForm Γ k) (n : ℂ) : ⇑(n • f) = n • f :=
  rfl
#align slash_invariant_form.coe_csmul SlashInvariantForm.coe_csmul

@[simp]
theorem csmul_apply (f : SlashInvariantForm Γ k) (n : ℂ) (z : ℍ) : (n • f) z = n • f z :=
  rfl
#align slash_invariant_form.csmul_apply SlashInvariantForm.csmul_apply

instance hasNsmul : HasSmul ℕ (SlashInvariantForm Γ k) :=
  ⟨fun c f => ((c : ℂ) • f).copy (c • f) (nsmul_eq_smul_cast _ _ _)⟩
#align slash_invariant_form.has_nsmul SlashInvariantForm.hasNsmul

@[simp]
theorem coe_nsmul (f : SlashInvariantForm Γ k) (n : ℕ) : ⇑(n • f) = n • f :=
  rfl
#align slash_invariant_form.coe_nsmul SlashInvariantForm.coe_nsmul

@[simp]
theorem nsmul_apply (f : SlashInvariantForm Γ k) (n : ℕ) (z : ℍ) : (n • f) z = n • f z :=
  rfl
#align slash_invariant_form.nsmul_apply SlashInvariantForm.nsmul_apply

instance hasZsmul : HasSmul ℤ (SlashInvariantForm Γ k) :=
  ⟨fun c f => ((c : ℂ) • f).copy (c • f) (zsmul_eq_smul_cast _ _ _)⟩
#align slash_invariant_form.has_zsmul SlashInvariantForm.hasZsmul

@[simp]
theorem coe_zsmul (f : SlashInvariantForm Γ k) (n : ℤ) : ⇑(n • f) = n • f :=
  rfl
#align slash_invariant_form.coe_zsmul SlashInvariantForm.coe_zsmul

@[simp]
theorem zsmul_apply (f : SlashInvariantForm Γ k) (n : ℤ) (z : ℍ) : (n • f) z = n • f z :=
  rfl
#align slash_invariant_form.zsmul_apply SlashInvariantForm.zsmul_apply

instance hasNeg : Neg (SlashInvariantForm Γ k) :=
  ⟨fun f =>
    { toFun := -f,
      slash_action_eq' := fun γ => by
        simpa [ModularForm.subgroup_slash, ModularForm.neg_slash] using f.slash_action_eq' γ }⟩
#align slash_invariant_form.has_neg SlashInvariantForm.hasNeg

@[simp]
theorem coe_neg (f : SlashInvariantForm Γ k) : ⇑(-f) = -f :=
  rfl
#align slash_invariant_form.coe_neg SlashInvariantForm.coe_neg

@[simp]
theorem neg_apply (f : SlashInvariantForm Γ k) (z : ℍ) : (-f) z = -f z :=
  rfl
#align slash_invariant_form.neg_apply SlashInvariantForm.neg_apply

instance hasSub : Sub (SlashInvariantForm Γ k) :=
  ⟨fun f g => f + -g⟩
#align slash_invariant_form.has_sub SlashInvariantForm.hasSub

@[simp]
theorem coe_sub (f g : SlashInvariantForm Γ k) : ⇑(f - g) = f - g :=
  rfl
#align slash_invariant_form.coe_sub SlashInvariantForm.coe_sub

@[simp]
theorem sub_apply (f g : SlashInvariantForm Γ k) (z : ℍ) : (f - g) z = f z - g z :=
  rfl
#align slash_invariant_form.sub_apply SlashInvariantForm.sub_apply

instance : AddCommGroup (SlashInvariantForm Γ k) :=
  FunLike.coe_injective.AddCommGroup _ rfl coe_add coe_neg coe_sub coe_nsmul coe_zsmul

/-- Additive coercion from `slash_invariant_form` to `ℍ → ℂ`.-/
def coeHom : SlashInvariantForm Γ k →+ ℍ → ℂ where
  toFun f := f
  map_zero' := rfl
  map_add' _ _ := rfl
#align slash_invariant_form.coe_hom SlashInvariantForm.coeHom

theorem coe_hom_injective : Function.Injective (@coeHom Γ k) :=
  FunLike.coe_injective
#align slash_invariant_form.coe_hom_injective SlashInvariantForm.coe_hom_injective

instance : Module ℂ (SlashInvariantForm Γ k) :=
  coe_hom_injective.Module ℂ coeHom fun _ _ => rfl

instance : One (SlashInvariantForm Γ 0) :=
  ⟨{ toFun := 1, slash_action_eq' := fun A => ModularForm.is_invariant_one A }⟩

instance : Inhabited (SlashInvariantForm Γ k) :=
  ⟨0⟩

end SlashInvariantForm

