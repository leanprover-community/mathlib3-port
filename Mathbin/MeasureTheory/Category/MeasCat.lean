/-
Copyright (c) 2018 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module measure_theory.category.Meas
! leanprover-community/mathlib commit 26f081a2fb920140ed5bc5cc5344e84bcc7cb2b2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Measure.GiryMonad
import Mathbin.CategoryTheory.ConcreteCategory.UnbundledHom
import Mathbin.CategoryTheory.Monad.Algebra
import Mathbin.Topology.Category.TopCat.Basic

/-!
# The category of measurable spaces

Measurable spaces and measurable functions form a (concrete) category `Meas`.

## Main definitions

* `Measure : Meas ⥤ Meas`: the functor which sends a measurable space `X`
to the space of measures on `X`; it is a monad (the "Giry monad").

* `Borel : Top ⥤ Meas`: sends a topological space `X` to `X` equipped with the
`σ`-algebra of Borel sets (the `σ`-algebra generated by the open subsets of `X`).

## Tags

measurable space, giry monad, borel
-/


noncomputable section

open CategoryTheory MeasureTheory

open Ennreal

universe u v

/-- The category of measurable spaces and measurable functions. -/
def MeasCat : Type (u + 1) :=
  Bundled MeasurableSpace
#align Meas MeasCat

namespace MeasCat

instance : CoeSort MeasCat (Type _) :=
  bundled.has_coe_to_sort

instance (X : MeasCat) : MeasurableSpace X :=
  X.str

/-- Construct a bundled `Meas` from the underlying type and the typeclass. -/
def of (α : Type u) [MeasurableSpace α] : MeasCat :=
  ⟨α⟩
#align Meas.of MeasCat.of

@[simp]
theorem coe_of (X : Type u) [MeasurableSpace X] : (of X : Type u) = X :=
  rfl
#align Meas.coe_of MeasCat.coe_of

instance unbundledHom : UnbundledHom @Measurable :=
  ⟨@measurable_id, @Measurable.comp⟩
#align Meas.unbundled_hom MeasCat.unbundledHom

deriving instance LargeCategory, ConcreteCategory for MeasCat

instance : Inhabited MeasCat :=
  ⟨MeasCat.of Empty⟩

/-- `Measure X` is the measurable space of measures over the measurable space `X`. It is the
weakest measurable space, s.t. λμ, μ s is measurable for all measurable sets `s` in `X`. An
important purpose is to assign a monadic structure on it, the Giry monad. In the Giry monad,
the pure values are the Dirac measure, and the bind operation maps to the integral:
`(μ >>= ν) s = ∫ x. (ν x) s dμ`.

In probability theory, the `Meas`-morphisms `X → Prob X` are (sub-)Markov kernels (here `Prob` is
the restriction of `Measure` to (sub-)probability space.)
-/
def measure : MeasCat ⥤ MeasCat
    where
  obj X := ⟨@MeasureTheory.Measure X.1 X.2⟩
  map X Y f := ⟨Measure.map (f : X → Y), Measure.measurable_map f f.2⟩
  map_id' := fun ⟨α, I⟩ => Subtype.eq <| funext fun μ => @Measure.map_id α I μ
  map_comp' := fun X Y Z ⟨f, hf⟩ ⟨g, hg⟩ =>
    Subtype.eq <| funext fun μ => (Measure.map_map hg hf).symm
#align Meas.Measure MeasCat.measure

/-- The Giry monad, i.e. the monadic structure associated with `Measure`. -/
def giry : CategoryTheory.Monad MeasCat
    where
  toFunctor := measure
  η' :=
    { app := fun X => ⟨@Measure.dirac X.1 X.2, Measure.measurable_dirac⟩
      naturality' := fun X Y ⟨f, hf⟩ =>
        Subtype.eq <| funext fun a => (Measure.map_dirac hf a).symm }
  μ' :=
    { app := fun X => ⟨@Measure.join X.1 X.2, Measure.measurable_join⟩
      naturality' := fun X Y ⟨f, hf⟩ => Subtype.eq <| funext fun μ => Measure.join_map_map hf μ }
  assoc' α := Subtype.eq <| funext fun μ => @Measure.join_map_join _ _ _
  left_unit' α := Subtype.eq <| funext fun μ => @Measure.join_dirac _ _ _
  right_unit' α := Subtype.eq <| funext fun μ => @Measure.join_map_dirac _ _ _
#align Meas.Giry MeasCat.giry

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:75:38: in apply_rules #[["[", expr measurable_id, ",", expr measure.measurable_lintegral, "]"], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error -/
/-- An example for an algebra on `Measure`: the nonnegative Lebesgue integral is a hom, behaving
nicely under the monad operations. -/
def integral : giry.Algebra where
  A := MeasCat.of ℝ≥0∞
  a := ⟨fun m : Measure ℝ≥0∞ => ∫⁻ x, x ∂m, Measure.measurable_lintegral measurable_id⟩
  unit' := Subtype.eq <| funext fun r : ℝ≥0∞ => lintegral_dirac' _ measurable_id
  assoc' :=
    Subtype.eq <|
      funext fun μ : Measure (Measure ℝ≥0∞) =>
        show (∫⁻ x, x ∂μ.join) = ∫⁻ x, x ∂Measure.map (fun m : Measure ℝ≥0∞ => ∫⁻ x, x ∂m) μ by
          rw [measure.lintegral_join, lintegral_map] <;>
            trace
              "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:75:38: in apply_rules #[[\"[\", expr measurable_id, \",\", expr measure.measurable_lintegral, \"]\"], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error"
#align Meas.Integral MeasCat.integral

end MeasCat

instance TopCat.hasForgetToMeas : HasForget₂ TopCat.{u} MeasCat.{u} :=
  BundledHom.mkHasForget₂ borel (fun X Y f => ⟨f.1, f.2.borel_measurable⟩) (by intros <;> rfl)
#align Top.has_forget_to_Meas TopCat.hasForgetToMeas

/- warning: Borel clashes with borel -> borel
warning: Borel -> borel is a dubious translation:
lean 3 declaration is
  CategoryTheory.Functor.{u1, u1, succ u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1} MeasCat.{u1} MeasCat.largeCategory.{u1}
but is expected to have type
  forall (α : Type.{u1}) [_inst_1 : TopologicalSpace.{u1} α], MeasurableSpace.{u1} α
Case conversion may be inaccurate. Consider using '#align Borel borelₓ'. -/
/-- The Borel functor, the canonical embedding of topological spaces into measurable spaces. -/
@[reducible]
def borel : TopCat.{u} ⥤ MeasCat.{u} :=
  forget₂ TopCat.{u} MeasCat.{u}
#align Borel borel

