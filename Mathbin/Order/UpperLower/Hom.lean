/-
Copyright (c) 2022 Yaël Dillies, Sara Rousta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module order.upper_lower.hom
! leanprover-community/mathlib commit b6da1a0b3e7cd83b1f744c49ce48ef8c6307d2f6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.UpperLower.Basic
import Mathbin.Order.Hom.CompleteLattice

/-!
# `upper_set.Ici` etc as `sup`/`Sup`/`inf`/`Inf`-homomorphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define `upper_set.Ici_sup_hom` etc. These functions are `upper_set.Ici` and
`lower_set.Iic` bundled as `sup_hom`s, `inf_hom`s, `Sup_hom`s, or `Inf_hom`s.
-/


variable {α : Type _}

open OrderDual

namespace UpperSet

section SemilatticeSup

variable [SemilatticeSup α]

/- warning: upper_set.Ici_sup_hom -> UpperSet.iciSupHom is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : SemilatticeSup.{u1} α], SupHom.{u1, u1} α (UpperSet.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))) (SemilatticeSup.toHasSup.{u1} α _inst_1) (UpperSet.hasSup.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : SemilatticeSup.{u1} α], SupHom.{u1, u1} α (UpperSet.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))) (SemilatticeSup.toSup.{u1} α _inst_1) (UpperSet.instSupUpperSet.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))))
Case conversion may be inaccurate. Consider using '#align upper_set.Ici_sup_hom UpperSet.iciSupHomₓ'. -/
/-- `upper_set.Ici` as a `sup_hom`. -/
def iciSupHom : SupHom α (UpperSet α) :=
  ⟨Ici, Ici_sup⟩
#align upper_set.Ici_sup_hom UpperSet.iciSupHom

#print UpperSet.coe_iciSupHom /-
@[simp]
theorem coe_iciSupHom : (iciSupHom : α → UpperSet α) = Ici :=
  rfl
#align upper_set.coe_Ici_sup_hom UpperSet.coe_iciSupHom
-/

#print UpperSet.iciSupHom_apply /-
@[simp]
theorem iciSupHom_apply (a : α) : iciSupHom a = Ici a :=
  rfl
#align upper_set.Ici_sup_hom_apply UpperSet.iciSupHom_apply
-/

end SemilatticeSup

variable [CompleteLattice α]

/-- `upper_set.Ici` as a `Sup_hom`. -/
def icisSupHom : sSupHom α (UpperSet α) :=
  ⟨Ici, fun s => (Ici_sSup s).trans sSup_image.symm⟩
#align upper_set.Ici_Sup_hom UpperSet.icisSupHomₓ

@[simp]
theorem coe_icisSupHom : (icisSupHom : α → UpperSet α) = Ici :=
  rfl
#align upper_set.coe_Ici_Sup_hom UpperSet.coe_icisSupHomₓ

@[simp]
theorem icisSupHom_apply (a : α) : icisSupHom a = Ici a :=
  rfl
#align upper_set.Ici_Sup_hom_apply UpperSet.icisSupHom_applyₓ

end UpperSet

namespace LowerSet

section SemilatticeInf

variable [SemilatticeInf α]

/- warning: lower_set.Iic_inf_hom -> LowerSet.iicInfHom is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : SemilatticeInf.{u1} α], InfHom.{u1, u1} α (LowerSet.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))) (SemilatticeInf.toHasInf.{u1} α _inst_1) (LowerSet.hasInf.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : SemilatticeInf.{u1} α], InfHom.{u1, u1} α (LowerSet.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))) (SemilatticeInf.toInf.{u1} α _inst_1) (LowerSet.instInfLowerSet.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))))
Case conversion may be inaccurate. Consider using '#align lower_set.Iic_inf_hom LowerSet.iicInfHomₓ'. -/
/-- `lower_set.Iic` as an `inf_hom`. -/
def iicInfHom : InfHom α (LowerSet α) :=
  ⟨Iic, Iic_inf⟩
#align lower_set.Iic_inf_hom LowerSet.iicInfHom

#print LowerSet.coe_iicInfHom /-
@[simp]
theorem coe_iicInfHom : (iicInfHom : α → LowerSet α) = Iic :=
  rfl
#align lower_set.coe_Iic_inf_hom LowerSet.coe_iicInfHom
-/

#print LowerSet.iicInfHom_apply /-
@[simp]
theorem iicInfHom_apply (a : α) : iicInfHom a = Iic a :=
  rfl
#align lower_set.Iic_inf_hom_apply LowerSet.iicInfHom_apply
-/

end SemilatticeInf

variable [CompleteLattice α]

/-- `lower_set.Iic` as an `Inf_hom`. -/
def iicsInfHom : sInfHom α (LowerSet α) :=
  ⟨Iic, fun s => (Iic_sInf s).trans sInf_image.symm⟩
#align lower_set.Iic_Inf_hom LowerSet.iicsInfHomₓ

@[simp]
theorem coe_iicsInfHom : (iicsInfHom : α → LowerSet α) = Iic :=
  rfl
#align lower_set.coe_Iic_Inf_hom LowerSet.coe_iicsInfHomₓ

@[simp]
theorem iicsInfHom_apply (a : α) : iicsInfHom a = Iic a :=
  rfl
#align lower_set.Iic_Inf_hom_apply LowerSet.iicsInfHom_applyₓ

end LowerSet

