/-
Copyright (c) 2022 Chris Birkbeck. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Birkbeck

! This file was ported from Lean 3 source module number_theory.modular_forms.slash_invariant_forms
! leanprover-community/mathlib commit d101e93197bb5f6ea89bd7ba386b7f7dff1f3903
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
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
    SlashInvariantFormClass (SlashInvariantForm Γ k) Γ k
    where
  coe := SlashInvariantForm.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  slash_action_eq := SlashInvariantForm.slash_action_eq'
#align slash_invariant_form_class.slash_invariant_form SlashInvariantFormClass.slashInvariantForm

variable {F Γ k}

instance : CoeFun (SlashInvariantForm Γ k) fun _ => ℍ → ℂ :=
  FunLike.hasCoeToFun

@[simp]
theorem slashInvariantForm_toFun_eq_coe {f : SlashInvariantForm Γ k} : f.toFun = (f : ℍ → ℂ) :=
  rfl
#align slash_invariant_form_to_fun_eq_coe slashInvariantForm_toFun_eq_coe

@[ext]
theorem slashInvariantForm_ext {f g : SlashInvariantForm Γ k} (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext f g h
#align slash_invariant_form_ext slashInvariantForm_ext

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
instance (priority := 100) SlashInvariantFormClass.coeToFun [SlashInvariantFormClass F Γ k] :
    CoeFun F fun _ => ℍ → ℂ :=
  FunLike.hasCoeToFun
#align slash_invariant_form.slash_invariant_form_class.coe_to_fun SlashInvariantForm.SlashInvariantFormClass.coeToFun

@[simp]
theorem slash_action_eqn [SlashInvariantFormClass F Γ k] (f : F) (γ : Γ) :
    SlashAction.map ℂ k γ ⇑f = ⇑f :=
  SlashInvariantFormClass.slash_action_eq f γ
#align slash_invariant_form.slash_action_eqn SlashInvariantForm.slash_action_eqn

theorem slash_action_eqn' (k : ℤ) (Γ : Subgroup SL(2, ℤ)) [SlashInvariantFormClass F Γ k] (f : F)
    (γ : Γ) (z : ℍ) : f (γ • z) = ((↑ₘγ 1 0 : ℂ) * z + (↑ₘγ 1 1 : ℂ)) ^ k * f z :=
  by
  rw [← ModularForm.slash_action_eq'_iff]
  simp
#align slash_invariant_form.slash_action_eqn' SlashInvariantForm.slash_action_eqn'

instance [SlashInvariantFormClass F Γ k] : CoeTC F (SlashInvariantForm Γ k) :=
  ⟨fun f =>
    { toFun := f
      slash_action_eq' := slash_action_eqn f }⟩

@[simp]
theorem SlashInvariantFormClass.coe_coe [SlashInvariantFormClass F Γ k] (f : F) :
    ((f : SlashInvariantForm Γ k) : ℍ → ℂ) = f :=
  rfl
#align slash_invariant_form.slash_invariant_form_class.coe_coe SlashInvariantForm.SlashInvariantFormClass.coe_coe

instance hasAdd : Add (SlashInvariantForm Γ k) :=
  ⟨fun f g =>
    { toFun := f + g
      slash_action_eq' := fun γ => by convert SlashAction.add_action k γ (f : ℍ → ℂ) g <;> simp }⟩
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
  ⟨{  toFun := 0
      slash_action_eq' := SlashAction.zero_slash _ }⟩
#align slash_invariant_form.has_zero SlashInvariantForm.hasZero

@[simp]
theorem coe_zero : ⇑(0 : SlashInvariantForm Γ k) = (0 : ℍ → ℂ) :=
  rfl
#align slash_invariant_form.coe_zero SlashInvariantForm.coe_zero

section

variable {α : Type _} [SMul α ℂ] [IsScalarTower α ℂ ℂ]

instance hasSmul : SMul α (SlashInvariantForm Γ k) :=
  ⟨fun c f =>
    { toFun := c • f
      slash_action_eq' := fun γ => by
        rw [← smul_one_smul ℂ c ⇑f, SlashAction.smul_action k γ ⇑f, slash_action_eqn] }⟩
#align slash_invariant_form.has_smul SlashInvariantForm.hasSmul

@[simp]
theorem coe_smul (f : SlashInvariantForm Γ k) (n : α) : ⇑(n • f) = n • f :=
  rfl
#align slash_invariant_form.coe_smul SlashInvariantForm.coe_smul

@[simp]
theorem smul_apply (f : SlashInvariantForm Γ k) (n : α) (z : ℍ) : (n • f) z = n • f z :=
  rfl
#align slash_invariant_form.smul_apply SlashInvariantForm.smul_apply

end

instance hasNeg : Neg (SlashInvariantForm Γ k) :=
  ⟨fun f =>
    { toFun := -f
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
  FunLike.coe_injective.AddCommGroup _ rfl coe_add coe_neg coe_sub coe_smul coe_smul

/-- Additive coercion from `slash_invariant_form` to `ℍ → ℂ`.-/
def coeHom : SlashInvariantForm Γ k →+ ℍ → ℂ
    where
  toFun f := f
  map_zero' := rfl
  map_add' _ _ := rfl
#align slash_invariant_form.coe_hom SlashInvariantForm.coeHom

theorem coeHom_injective : Function.Injective (@coeHom Γ k) :=
  FunLike.coe_injective
#align slash_invariant_form.coe_hom_injective SlashInvariantForm.coeHom_injective

instance : Module ℂ (SlashInvariantForm Γ k) :=
  coeHom_injective.Module ℂ coeHom fun _ _ => rfl

instance : One (SlashInvariantForm Γ 0) :=
  ⟨{  toFun := 1
      slash_action_eq' := fun A => ModularForm.is_invariant_one A }⟩

@[simp]
theorem one_coe_eq_one : ((1 : SlashInvariantForm Γ 0) : ℍ → ℂ) = 1 :=
  rfl
#align slash_invariant_form.one_coe_eq_one SlashInvariantForm.one_coe_eq_one

instance : Inhabited (SlashInvariantForm Γ k) :=
  ⟨0⟩

end SlashInvariantForm

