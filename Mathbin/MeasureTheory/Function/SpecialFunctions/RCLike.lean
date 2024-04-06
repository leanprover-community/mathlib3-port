/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov
-/
import MeasureTheory.Function.SpecialFunctions.Basic
import Analysis.RCLike.Lemmas

#align_import measure_theory.function.special_functions.is_R_or_C from "leanprover-community/mathlib"@"38df578a6450a8c5142b3727e3ae894c2300cae0"

/-!
# Measurability of the basic `is_R_or_C` functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

-/


noncomputable section

open scoped NNReal ENNReal

namespace RCLike

variable {𝕜 : Type _} [RCLike 𝕜]

#print RCLike.measurable_re /-
@[measurability]
theorem measurable_re : Measurable (re : 𝕜 → ℝ) :=
  continuous_re.Measurable
#align is_R_or_C.measurable_re RCLike.measurable_re
-/

#print RCLike.measurable_im /-
@[measurability]
theorem measurable_im : Measurable (im : 𝕜 → ℝ) :=
  continuous_im.Measurable
#align is_R_or_C.measurable_im RCLike.measurable_im
-/

end RCLike

section IsROrCComposition

variable {α 𝕜 : Type _} [RCLike 𝕜] {m : MeasurableSpace α} {f : α → 𝕜} {μ : MeasureTheory.Measure α}

#print Measurable.re /-
@[measurability]
theorem Measurable.re (hf : Measurable f) : Measurable fun x => RCLike.re (f x) :=
  RCLike.measurable_re.comp hf
#align measurable.re Measurable.re
-/

#print AEMeasurable.re /-
@[measurability]
theorem AEMeasurable.re (hf : AEMeasurable f μ) : AEMeasurable (fun x => RCLike.re (f x)) μ :=
  RCLike.measurable_re.comp_aemeasurable hf
#align ae_measurable.re AEMeasurable.re
-/

#print Measurable.im /-
@[measurability]
theorem Measurable.im (hf : Measurable f) : Measurable fun x => RCLike.im (f x) :=
  RCLike.measurable_im.comp hf
#align measurable.im Measurable.im
-/

#print AEMeasurable.im /-
@[measurability]
theorem AEMeasurable.im (hf : AEMeasurable f μ) : AEMeasurable (fun x => RCLike.im (f x)) μ :=
  RCLike.measurable_im.comp_aemeasurable hf
#align ae_measurable.im AEMeasurable.im
-/

end IsROrCComposition

section

variable {α 𝕜 : Type _} [RCLike 𝕜] [MeasurableSpace α] {f : α → 𝕜} {μ : MeasureTheory.Measure α}

#print RCLike.measurable_ofReal /-
@[measurability]
theorem RCLike.measurable_ofReal : Measurable (coe : ℝ → 𝕜) :=
  RCLike.continuous_ofReal.Measurable
#align is_R_or_C.measurable_of_real RCLike.measurable_ofReal
-/

#print measurable_of_re_im /-
theorem measurable_of_re_im (hre : Measurable fun x => RCLike.re (f x))
    (him : Measurable fun x => RCLike.im (f x)) : Measurable f :=
  by
  convert
    (is_R_or_C.measurable_of_real.comp hre).add
      ((is_R_or_C.measurable_of_real.comp him).mul_const RCLike.i)
  · ext1 x
    exact (RCLike.re_add_im _).symm
  all_goals infer_instance
#align measurable_of_re_im measurable_of_re_im
-/

#print aemeasurable_of_re_im /-
theorem aemeasurable_of_re_im (hre : AEMeasurable (fun x => RCLike.re (f x)) μ)
    (him : AEMeasurable (fun x => RCLike.im (f x)) μ) : AEMeasurable f μ :=
  by
  convert
    (is_R_or_C.measurable_of_real.comp_ae_measurable hre).add
      ((is_R_or_C.measurable_of_real.comp_ae_measurable him).mul_const RCLike.i)
  · ext1 x
    exact (RCLike.re_add_im _).symm
  all_goals infer_instance
#align ae_measurable_of_re_im aemeasurable_of_re_im
-/

end

