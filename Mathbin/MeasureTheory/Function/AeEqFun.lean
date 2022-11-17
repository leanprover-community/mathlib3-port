/-
Copyright (c) 2019 Johannes Hölzl, Zhouhang Zhou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Zhouhang Zhou
-/
import Mathbin.MeasureTheory.Integral.Lebesgue
import Mathbin.Order.Filter.Germ
import Mathbin.Topology.ContinuousFunction.Algebra
import Mathbin.MeasureTheory.Function.StronglyMeasurable.Basic

/-!

# Almost everywhere equal functions

We build a space of equivalence classes of functions, where two functions are treated as identical
if they are almost everywhere equal. We form the set of equivalence classes under the relation of
being almost everywhere equal, which is sometimes known as the `L⁰` space.
To use this space as a basis for the `L^p` spaces and for the Bochner integral, we consider
equivalence classes of strongly measurable functions (or, equivalently, of almost everywhere
strongly measurable functions.)

See `l1_space.lean` for `L¹` space.

## Notation

* `α →ₘ[μ] β` is the type of `L⁰` space, where `α` is a measurable space, `β` is a topological
  space, and `μ` is a measure on `α`. `f : α →ₘ β` is a "function" in `L⁰`.
  In comments, `[f]` is also used to denote an `L⁰` function.

  `ₘ` can be typed as `\_m`. Sometimes it is shown as a box if font is missing.

## Main statements

* The linear structure of `L⁰` :
    Addition and scalar multiplication are defined on `L⁰` in the natural way, i.e.,
    `[f] + [g] := [f + g]`, `c • [f] := [c • f]`. So defined, `α →ₘ β` inherits the linear structure
    of `β`. For example, if `β` is a module, then `α →ₘ β` is a module over the same ring.

    See `mk_add_mk`,  `neg_mk`,     `mk_sub_mk`,  `smul_mk`,
        `add_to_fun`, `neg_to_fun`, `sub_to_fun`, `smul_to_fun`

* The order structure of `L⁰` :
    `≤` can be defined in a similar way: `[f] ≤ [g]` if `f a ≤ g a` for almost all `a` in domain.
    And `α →ₘ β` inherits the preorder and partial order of `β`.

    TODO: Define `sup` and `inf` on `L⁰` so that it forms a lattice. It seems that `β` must be a
    linear order, since otherwise `f ⊔ g` may not be a measurable function.

## Implementation notes

* `f.to_fun`     : To find a representative of `f : α →ₘ β`, use the coercion `(f : α → β)`, which
                 is implemented as `f.to_fun`.
                 For each operation `op` in `L⁰`, there is a lemma called `coe_fn_op`,
                 characterizing, say, `(f op g : α → β)`.
* `ae_eq_fun.mk` : To constructs an `L⁰` function `α →ₘ β` from an almost everywhere strongly
                 measurable function `f : α → β`, use `ae_eq_fun.mk`
* `comp`         : Use `comp g f` to get `[g ∘ f]` from `g : β → γ` and `[f] : α →ₘ γ` when `g` is
                 continuous. Use `comp_measurable` if `g` is only measurable (this requires the
                 target space to be second countable).
* `comp₂`        : Use `comp₂ g f₁ f₂ to get `[λ a, g (f₁ a) (f₂ a)]`.
                 For example, `[f + g]` is `comp₂ (+)`


## Tags

function space, almost everywhere equal, `L⁰`, ae_eq_fun

-/


noncomputable section

open Classical Ennreal TopologicalSpace

open Set Filter TopologicalSpace Ennreal Emetric MeasureTheory Function

variable {α β γ δ : Type _} [MeasurableSpace α] {μ ν : Measure α}

namespace MeasureTheory

section MeasurableSpace

variable [TopologicalSpace β]

variable (β)

/-- The equivalence relation of being almost everywhere equal for almost everywhere strongly
measurable functions. -/
def Measure.aeEqSetoid (μ : Measure α) : Setoid { f : α → β // AeStronglyMeasurable f μ } :=
  ⟨fun f g => (f : α → β) =ᵐ[μ] g, fun f => ae_eq_refl f, fun f g => ae_eq_symm, fun f g h => ae_eq_trans⟩
#align measure_theory.measure.ae_eq_setoid MeasureTheory.Measure.aeEqSetoid

variable (α)

/-- The space of equivalence classes of almost everywhere strongly measurable functions, where two
    strongly measurable functions are equivalent if they agree almost everywhere, i.e.,
    they differ on a set of measure `0`.  -/
def AeEqFun (μ : Measure α) : Type _ :=
  Quotient (μ.aeEqSetoid β)
#align measure_theory.ae_eq_fun MeasureTheory.AeEqFun

variable {α β}

-- mathport name: «expr →ₘ[ ] »
notation:25 α " →ₘ[" μ "] " β => AeEqFun α β μ

end MeasurableSpace

namespace AeEqFun

variable [TopologicalSpace β] [TopologicalSpace γ] [TopologicalSpace δ]

/-- Construct the equivalence class `[f]` of an almost everywhere measurable function `f`, based
    on the equivalence relation of being almost everywhere equal. -/
def mk {β : Type _} [TopologicalSpace β] (f : α → β) (hf : AeStronglyMeasurable f μ) : α →ₘ[μ] β :=
  Quotient.mk' ⟨f, hf⟩
#align measure_theory.ae_eq_fun.mk MeasureTheory.AeEqFun.mk

/-- A measurable representative of an `ae_eq_fun` [f] -/
instance : CoeFun (α →ₘ[μ] β) fun _ => α → β :=
  ⟨fun f => AeStronglyMeasurable.mk _ (Quotient.out' f : { f : α → β // AeStronglyMeasurable f μ }).2⟩

protected theorem stronglyMeasurable (f : α →ₘ[μ] β) : StronglyMeasurable f :=
  AeStronglyMeasurable.stronglyMeasurableMk _
#align measure_theory.ae_eq_fun.strongly_measurable MeasureTheory.AeEqFun.stronglyMeasurable

protected theorem aeStronglyMeasurable (f : α →ₘ[μ] β) : AeStronglyMeasurable f μ :=
  f.StronglyMeasurable.AeStronglyMeasurable
#align measure_theory.ae_eq_fun.ae_strongly_measurable MeasureTheory.AeEqFun.aeStronglyMeasurable

protected theorem measurable [PseudoMetrizableSpace β] [MeasurableSpace β] [BorelSpace β] (f : α →ₘ[μ] β) :
    Measurable f :=
  AeStronglyMeasurable.measurableMk _
#align measure_theory.ae_eq_fun.measurable MeasureTheory.AeEqFun.measurable

protected theorem aeMeasurable [PseudoMetrizableSpace β] [MeasurableSpace β] [BorelSpace β] (f : α →ₘ[μ] β) :
    AeMeasurable f μ :=
  f.Measurable.AeMeasurable
#align measure_theory.ae_eq_fun.ae_measurable MeasureTheory.AeEqFun.aeMeasurable

@[simp]
theorem quot_mk_eq_mk (f : α → β) (hf) : (Quot.mk (@Setoid.r _ $ μ.aeEqSetoid β) ⟨f, hf⟩ : α →ₘ[μ] β) = mk f hf :=
  rfl
#align measure_theory.ae_eq_fun.quot_mk_eq_mk MeasureTheory.AeEqFun.quot_mk_eq_mk

@[simp]
theorem mk_eq_mk {f g : α → β} {hf hg} : (mk f hf : α →ₘ[μ] β) = mk g hg ↔ f =ᵐ[μ] g :=
  Quotient.eq'
#align measure_theory.ae_eq_fun.mk_eq_mk MeasureTheory.AeEqFun.mk_eq_mk

@[simp]
theorem mk_coe_fn (f : α →ₘ[μ] β) : mk f f.AeStronglyMeasurable = f := by
  conv_rhs => rw [← Quotient.out_eq' f]
  set g : { f : α → β // ae_strongly_measurable f μ } := Quotient.out' f with hg
  have : g = ⟨g.1, g.2⟩ := Subtype.eq rfl
  rw [this, ← mk, mk_eq_mk]
  exact (ae_strongly_measurable.ae_eq_mk _).symm
#align measure_theory.ae_eq_fun.mk_coe_fn MeasureTheory.AeEqFun.mk_coe_fn

@[ext.1]
theorem ext {f g : α →ₘ[μ] β} (h : f =ᵐ[μ] g) : f = g := by rwa [← f.mk_coe_fn, ← g.mk_coe_fn, mk_eq_mk]
#align measure_theory.ae_eq_fun.ext MeasureTheory.AeEqFun.ext

theorem ext_iff {f g : α →ₘ[μ] β} : f = g ↔ f =ᵐ[μ] g :=
  ⟨fun h => by rw [h], fun h => ext h⟩
#align measure_theory.ae_eq_fun.ext_iff MeasureTheory.AeEqFun.ext_iff

theorem coe_fn_mk (f : α → β) (hf) : (mk f hf : α →ₘ[μ] β) =ᵐ[μ] f := by
  apply (ae_strongly_measurable.ae_eq_mk _).symm.trans
  exact @Quotient.mk_out' _ (μ.ae_eq_setoid β) (⟨f, hf⟩ : { f // ae_strongly_measurable f μ })
#align measure_theory.ae_eq_fun.coe_fn_mk MeasureTheory.AeEqFun.coe_fn_mk

@[elab_as_elim]
theorem inductionOn (f : α →ₘ[μ] β) {p : (α →ₘ[μ] β) → Prop} (H : ∀ f hf, p (mk f hf)) : p f :=
  Quotient.inductionOn' f $ Subtype.forall.2 H
#align measure_theory.ae_eq_fun.induction_on MeasureTheory.AeEqFun.inductionOn

@[elab_as_elim]
theorem inductionOn₂ {α' β' : Type _} [MeasurableSpace α'] [TopologicalSpace β'] {μ' : Measure α'} (f : α →ₘ[μ] β)
    (f' : α' →ₘ[μ'] β') {p : (α →ₘ[μ] β) → (α' →ₘ[μ'] β') → Prop} (H : ∀ f hf f' hf', p (mk f hf) (mk f' hf')) :
    p f f' :=
  inductionOn f $ fun f hf => inductionOn f' $ H f hf
#align measure_theory.ae_eq_fun.induction_on₂ MeasureTheory.AeEqFun.inductionOn₂

@[elab_as_elim]
theorem inductionOn₃ {α' β' : Type _} [MeasurableSpace α'] [TopologicalSpace β'] {μ' : Measure α'} {α'' β'' : Type _}
    [MeasurableSpace α''] [TopologicalSpace β''] {μ'' : Measure α''} (f : α →ₘ[μ] β) (f' : α' →ₘ[μ'] β')
    (f'' : α'' →ₘ[μ''] β'') {p : (α →ₘ[μ] β) → (α' →ₘ[μ'] β') → (α'' →ₘ[μ''] β'') → Prop}
    (H : ∀ f hf f' hf' f'' hf'', p (mk f hf) (mk f' hf') (mk f'' hf'')) : p f f' f'' :=
  inductionOn f $ fun f hf => inductionOn₂ f' f'' $ H f hf
#align measure_theory.ae_eq_fun.induction_on₃ MeasureTheory.AeEqFun.inductionOn₃

/-- Given a continuous function `g : β → γ`, and an almost everywhere equal function `[f] : α →ₘ β`,
    return the equivalence class of `g ∘ f`, i.e., the almost everywhere equal function
    `[g ∘ f] : α →ₘ γ`. -/
def comp (g : β → γ) (hg : Continuous g) (f : α →ₘ[μ] β) : α →ₘ[μ] γ :=
  (Quotient.liftOn' f fun f => mk (g ∘ (f : α → β)) (hg.compAeStronglyMeasurable f.2)) $ fun f f' H =>
    mk_eq_mk.2 $ H.fun_comp g
#align measure_theory.ae_eq_fun.comp MeasureTheory.AeEqFun.comp

@[simp]
theorem comp_mk (g : β → γ) (hg : Continuous g) (f : α → β) (hf) :
    comp g hg (mk f hf : α →ₘ[μ] β) = mk (g ∘ f) (hg.compAeStronglyMeasurable hf) :=
  rfl
#align measure_theory.ae_eq_fun.comp_mk MeasureTheory.AeEqFun.comp_mk

theorem comp_eq_mk (g : β → γ) (hg : Continuous g) (f : α →ₘ[μ] β) :
    comp g hg f = mk (g ∘ f) (hg.compAeStronglyMeasurable f.AeStronglyMeasurable) := by
  rw [← comp_mk g hg f f.ae_strongly_measurable, mk_coe_fn]
#align measure_theory.ae_eq_fun.comp_eq_mk MeasureTheory.AeEqFun.comp_eq_mk

theorem coe_fn_comp (g : β → γ) (hg : Continuous g) (f : α →ₘ[μ] β) : comp g hg f =ᵐ[μ] g ∘ f := by
  rw [comp_eq_mk]
  apply coe_fn_mk
#align measure_theory.ae_eq_fun.coe_fn_comp MeasureTheory.AeEqFun.coe_fn_comp

section CompMeasurable

variable [MeasurableSpace β] [PseudoMetrizableSpace β] [BorelSpace β] [MeasurableSpace γ] [PseudoMetrizableSpace γ]
  [OpensMeasurableSpace γ] [SecondCountableTopology γ]

/-- Given a measurable function `g : β → γ`, and an almost everywhere equal function `[f] : α →ₘ β`,
    return the equivalence class of `g ∘ f`, i.e., the almost everywhere equal function
    `[g ∘ f] : α →ₘ γ`. This requires that `γ` has a second countable topology. -/
def compMeasurable (g : β → γ) (hg : Measurable g) (f : α →ₘ[μ] β) : α →ₘ[μ] γ :=
  (Quotient.liftOn' f fun f' => mk (g ∘ (f' : α → β)) (hg.compAeMeasurable f'.2.AeMeasurable).AeStronglyMeasurable) $
    fun f f' H => mk_eq_mk.2 $ H.fun_comp g
#align measure_theory.ae_eq_fun.comp_measurable MeasureTheory.AeEqFun.compMeasurable

@[simp]
theorem comp_measurable_mk (g : β → γ) (hg : Measurable g) (f : α → β) (hf : AeStronglyMeasurable f μ) :
    compMeasurable g hg (mk f hf : α →ₘ[μ] β) = mk (g ∘ f) (hg.compAeMeasurable hf.AeMeasurable).AeStronglyMeasurable :=
  rfl
#align measure_theory.ae_eq_fun.comp_measurable_mk MeasureTheory.AeEqFun.comp_measurable_mk

theorem comp_measurable_eq_mk (g : β → γ) (hg : Measurable g) (f : α →ₘ[μ] β) :
    compMeasurable g hg f = mk (g ∘ f) (hg.compAeMeasurable f.AeMeasurable).AeStronglyMeasurable := by
  rw [← comp_measurable_mk g hg f f.ae_strongly_measurable, mk_coe_fn]
#align measure_theory.ae_eq_fun.comp_measurable_eq_mk MeasureTheory.AeEqFun.comp_measurable_eq_mk

theorem coe_fn_comp_measurable (g : β → γ) (hg : Measurable g) (f : α →ₘ[μ] β) : compMeasurable g hg f =ᵐ[μ] g ∘ f := by
  rw [comp_measurable_eq_mk]
  apply coe_fn_mk
#align measure_theory.ae_eq_fun.coe_fn_comp_measurable MeasureTheory.AeEqFun.coe_fn_comp_measurable

end CompMeasurable

/-- The class of `x ↦ (f x, g x)`. -/
def pair (f : α →ₘ[μ] β) (g : α →ₘ[μ] γ) : α →ₘ[μ] β × γ :=
  (Quotient.liftOn₂' f g fun f g => mk (fun x => (f.1 x, g.1 x)) (f.2.prod_mk g.2)) $ fun f g f' g' Hf Hg =>
    mk_eq_mk.2 $ Hf.prod_mk Hg
#align measure_theory.ae_eq_fun.pair MeasureTheory.AeEqFun.pair

@[simp]
theorem pair_mk_mk (f : α → β) (hf) (g : α → γ) (hg) :
    (mk f hf : α →ₘ[μ] β).pair (mk g hg) = mk (fun x => (f x, g x)) (hf.prod_mk hg) :=
  rfl
#align measure_theory.ae_eq_fun.pair_mk_mk MeasureTheory.AeEqFun.pair_mk_mk

theorem pair_eq_mk (f : α →ₘ[μ] β) (g : α →ₘ[μ] γ) :
    f.pair g = mk (fun x => (f x, g x)) (f.AeStronglyMeasurable.prod_mk g.AeStronglyMeasurable) := by
  simp only [← pair_mk_mk, mk_coe_fn]
#align measure_theory.ae_eq_fun.pair_eq_mk MeasureTheory.AeEqFun.pair_eq_mk

theorem coe_fn_pair (f : α →ₘ[μ] β) (g : α →ₘ[μ] γ) : f.pair g =ᵐ[μ] fun x => (f x, g x) := by
  rw [pair_eq_mk]
  apply coe_fn_mk
#align measure_theory.ae_eq_fun.coe_fn_pair MeasureTheory.AeEqFun.coe_fn_pair

/-- Given a continuous function `g : β → γ → δ`, and almost everywhere equal functions
    `[f₁] : α →ₘ β` and `[f₂] : α →ₘ γ`, return the equivalence class of the function
    `λ a, g (f₁ a) (f₂ a)`, i.e., the almost everywhere equal function
    `[λ a, g (f₁ a) (f₂ a)] : α →ₘ γ` -/
def comp₂ (g : β → γ → δ) (hg : Continuous (uncurry g)) (f₁ : α →ₘ[μ] β) (f₂ : α →ₘ[μ] γ) : α →ₘ[μ] δ :=
  comp _ hg (f₁.pair f₂)
#align measure_theory.ae_eq_fun.comp₂ MeasureTheory.AeEqFun.comp₂

@[simp]
theorem comp₂_mk_mk (g : β → γ → δ) (hg : Continuous (uncurry g)) (f₁ : α → β) (f₂ : α → γ) (hf₁ hf₂) :
    comp₂ g hg (mk f₁ hf₁ : α →ₘ[μ] β) (mk f₂ hf₂) =
      mk (fun a => g (f₁ a) (f₂ a)) (hg.compAeStronglyMeasurable (hf₁.prod_mk hf₂)) :=
  rfl
#align measure_theory.ae_eq_fun.comp₂_mk_mk MeasureTheory.AeEqFun.comp₂_mk_mk

theorem comp₂_eq_pair (g : β → γ → δ) (hg : Continuous (uncurry g)) (f₁ : α →ₘ[μ] β) (f₂ : α →ₘ[μ] γ) :
    comp₂ g hg f₁ f₂ = comp _ hg (f₁.pair f₂) :=
  rfl
#align measure_theory.ae_eq_fun.comp₂_eq_pair MeasureTheory.AeEqFun.comp₂_eq_pair

theorem comp₂_eq_mk (g : β → γ → δ) (hg : Continuous (uncurry g)) (f₁ : α →ₘ[μ] β) (f₂ : α →ₘ[μ] γ) :
    comp₂ g hg f₁ f₂ =
      mk (fun a => g (f₁ a) (f₂ a))
        (hg.compAeStronglyMeasurable (f₁.AeStronglyMeasurable.prod_mk f₂.AeStronglyMeasurable)) :=
  by rw [comp₂_eq_pair, pair_eq_mk, comp_mk] <;> rfl
#align measure_theory.ae_eq_fun.comp₂_eq_mk MeasureTheory.AeEqFun.comp₂_eq_mk

theorem coe_fn_comp₂ (g : β → γ → δ) (hg : Continuous (uncurry g)) (f₁ : α →ₘ[μ] β) (f₂ : α →ₘ[μ] γ) :
    comp₂ g hg f₁ f₂ =ᵐ[μ] fun a => g (f₁ a) (f₂ a) := by
  rw [comp₂_eq_mk]
  apply coe_fn_mk
#align measure_theory.ae_eq_fun.coe_fn_comp₂ MeasureTheory.AeEqFun.coe_fn_comp₂

section

variable [MeasurableSpace β] [PseudoMetrizableSpace β] [BorelSpace β] [SecondCountableTopology β] [MeasurableSpace γ]
  [PseudoMetrizableSpace γ] [BorelSpace γ] [SecondCountableTopology γ] [MeasurableSpace δ] [PseudoMetrizableSpace δ]
  [OpensMeasurableSpace δ] [SecondCountableTopology δ]

/-- Given a measurable function `g : β → γ → δ`, and almost everywhere equal functions
    `[f₁] : α →ₘ β` and `[f₂] : α →ₘ γ`, return the equivalence class of the function
    `λ a, g (f₁ a) (f₂ a)`, i.e., the almost everywhere equal function
    `[λ a, g (f₁ a) (f₂ a)] : α →ₘ γ`. This requires `δ` to have second-countable topology. -/
def comp₂Measurable (g : β → γ → δ) (hg : Measurable (uncurry g)) (f₁ : α →ₘ[μ] β) (f₂ : α →ₘ[μ] γ) : α →ₘ[μ] δ :=
  compMeasurable _ hg (f₁.pair f₂)
#align measure_theory.ae_eq_fun.comp₂_measurable MeasureTheory.AeEqFun.comp₂Measurable

@[simp]
theorem comp₂_measurable_mk_mk (g : β → γ → δ) (hg : Measurable (uncurry g)) (f₁ : α → β) (f₂ : α → γ) (hf₁ hf₂) :
    comp₂Measurable g hg (mk f₁ hf₁ : α →ₘ[μ] β) (mk f₂ hf₂) =
      mk (fun a => g (f₁ a) (f₂ a))
        (hg.compAeMeasurable (hf₁.AeMeasurable.prod_mk hf₂.AeMeasurable)).AeStronglyMeasurable :=
  rfl
#align measure_theory.ae_eq_fun.comp₂_measurable_mk_mk MeasureTheory.AeEqFun.comp₂_measurable_mk_mk

theorem comp₂_measurable_eq_pair (g : β → γ → δ) (hg : Measurable (uncurry g)) (f₁ : α →ₘ[μ] β) (f₂ : α →ₘ[μ] γ) :
    comp₂Measurable g hg f₁ f₂ = compMeasurable _ hg (f₁.pair f₂) :=
  rfl
#align measure_theory.ae_eq_fun.comp₂_measurable_eq_pair MeasureTheory.AeEqFun.comp₂_measurable_eq_pair

theorem comp₂_measurable_eq_mk (g : β → γ → δ) (hg : Measurable (uncurry g)) (f₁ : α →ₘ[μ] β) (f₂ : α →ₘ[μ] γ) :
    comp₂Measurable g hg f₁ f₂ =
      mk (fun a => g (f₁ a) (f₂ a))
        (hg.compAeMeasurable (f₁.AeMeasurable.prod_mk f₂.AeMeasurable)).AeStronglyMeasurable :=
  by rw [comp₂_measurable_eq_pair, pair_eq_mk, comp_measurable_mk] <;> rfl
#align measure_theory.ae_eq_fun.comp₂_measurable_eq_mk MeasureTheory.AeEqFun.comp₂_measurable_eq_mk

theorem coe_fn_comp₂_measurable (g : β → γ → δ) (hg : Measurable (uncurry g)) (f₁ : α →ₘ[μ] β) (f₂ : α →ₘ[μ] γ) :
    comp₂Measurable g hg f₁ f₂ =ᵐ[μ] fun a => g (f₁ a) (f₂ a) := by
  rw [comp₂_measurable_eq_mk]
  apply coe_fn_mk
#align measure_theory.ae_eq_fun.coe_fn_comp₂_measurable MeasureTheory.AeEqFun.coe_fn_comp₂_measurable

end

/-- Interpret `f : α →ₘ[μ] β` as a germ at `μ.ae` forgetting that `f` is almost everywhere
    strongly measurable. -/
def toGerm (f : α →ₘ[μ] β) : Germ μ.ae β :=
  (Quotient.liftOn' f fun f => ((f : α → β) : Germ μ.ae β)) $ fun f g H => Germ.coe_eq.2 H
#align measure_theory.ae_eq_fun.to_germ MeasureTheory.AeEqFun.toGerm

@[simp]
theorem mk_to_germ (f : α → β) (hf) : (mk f hf : α →ₘ[μ] β).toGerm = f :=
  rfl
#align measure_theory.ae_eq_fun.mk_to_germ MeasureTheory.AeEqFun.mk_to_germ

theorem to_germ_eq (f : α →ₘ[μ] β) : f.toGerm = (f : α → β) := by rw [← mk_to_germ, mk_coe_fn]
#align measure_theory.ae_eq_fun.to_germ_eq MeasureTheory.AeEqFun.to_germ_eq

theorem to_germ_injective : Injective (toGerm : (α →ₘ[μ] β) → Germ μ.ae β) := fun f g H =>
  ext $ Germ.coe_eq.1 $ by rwa [← to_germ_eq, ← to_germ_eq]
#align measure_theory.ae_eq_fun.to_germ_injective MeasureTheory.AeEqFun.to_germ_injective

theorem comp_to_germ (g : β → γ) (hg : Continuous g) (f : α →ₘ[μ] β) : (comp g hg f).toGerm = f.toGerm.map g :=
  inductionOn f $ fun f hf => by simp
#align measure_theory.ae_eq_fun.comp_to_germ MeasureTheory.AeEqFun.comp_to_germ

theorem comp_measurable_to_germ [MeasurableSpace β] [BorelSpace β] [PseudoMetrizableSpace β] [PseudoMetrizableSpace γ]
    [SecondCountableTopology γ] [MeasurableSpace γ] [OpensMeasurableSpace γ] (g : β → γ) (hg : Measurable g)
    (f : α →ₘ[μ] β) : (compMeasurable g hg f).toGerm = f.toGerm.map g :=
  inductionOn f $ fun f hf => by simp
#align measure_theory.ae_eq_fun.comp_measurable_to_germ MeasureTheory.AeEqFun.comp_measurable_to_germ

theorem comp₂_to_germ (g : β → γ → δ) (hg : Continuous (uncurry g)) (f₁ : α →ₘ[μ] β) (f₂ : α →ₘ[μ] γ) :
    (comp₂ g hg f₁ f₂).toGerm = f₁.toGerm.map₂ g f₂.toGerm :=
  inductionOn₂ f₁ f₂ $ fun f₁ hf₁ f₂ hf₂ => by simp
#align measure_theory.ae_eq_fun.comp₂_to_germ MeasureTheory.AeEqFun.comp₂_to_germ

theorem comp₂_measurable_to_germ [PseudoMetrizableSpace β] [SecondCountableTopology β] [MeasurableSpace β]
    [BorelSpace β] [PseudoMetrizableSpace γ] [SecondCountableTopology γ] [MeasurableSpace γ] [BorelSpace γ]
    [PseudoMetrizableSpace δ] [SecondCountableTopology δ] [MeasurableSpace δ] [OpensMeasurableSpace δ] (g : β → γ → δ)
    (hg : Measurable (uncurry g)) (f₁ : α →ₘ[μ] β) (f₂ : α →ₘ[μ] γ) :
    (comp₂Measurable g hg f₁ f₂).toGerm = f₁.toGerm.map₂ g f₂.toGerm :=
  inductionOn₂ f₁ f₂ $ fun f₁ hf₁ f₂ hf₂ => by simp
#align measure_theory.ae_eq_fun.comp₂_measurable_to_germ MeasureTheory.AeEqFun.comp₂_measurable_to_germ

/-- Given a predicate `p` and an equivalence class `[f]`, return true if `p` holds of `f a`
    for almost all `a` -/
def LiftPred (p : β → Prop) (f : α →ₘ[μ] β) : Prop :=
  f.toGerm.lift_pred p
#align measure_theory.ae_eq_fun.lift_pred MeasureTheory.AeEqFun.LiftPred

/-- Given a relation `r` and equivalence class `[f]` and `[g]`, return true if `r` holds of
    `(f a, g a)` for almost all `a` -/
def LiftRel (r : β → γ → Prop) (f : α →ₘ[μ] β) (g : α →ₘ[μ] γ) : Prop :=
  f.toGerm.LiftRel r g.toGerm
#align measure_theory.ae_eq_fun.lift_rel MeasureTheory.AeEqFun.LiftRel

theorem lift_rel_mk_mk {r : β → γ → Prop} {f : α → β} {g : α → γ} {hf hg} :
    LiftRel r (mk f hf : α →ₘ[μ] β) (mk g hg) ↔ ∀ᵐ a ∂μ, r (f a) (g a) :=
  Iff.rfl
#align measure_theory.ae_eq_fun.lift_rel_mk_mk MeasureTheory.AeEqFun.lift_rel_mk_mk

theorem lift_rel_iff_coe_fn {r : β → γ → Prop} {f : α →ₘ[μ] β} {g : α →ₘ[μ] γ} :
    LiftRel r f g ↔ ∀ᵐ a ∂μ, r (f a) (g a) := by rw [← lift_rel_mk_mk, mk_coe_fn, mk_coe_fn]
#align measure_theory.ae_eq_fun.lift_rel_iff_coe_fn MeasureTheory.AeEqFun.lift_rel_iff_coe_fn

section Order

instance [Preorder β] : Preorder (α →ₘ[μ] β) :=
  Preorder.lift toGerm

@[simp]
theorem mk_le_mk [Preorder β] {f g : α → β} (hf hg) : (mk f hf : α →ₘ[μ] β) ≤ mk g hg ↔ f ≤ᵐ[μ] g :=
  Iff.rfl
#align measure_theory.ae_eq_fun.mk_le_mk MeasureTheory.AeEqFun.mk_le_mk

@[simp, norm_cast]
theorem coe_fn_le [Preorder β] {f g : α →ₘ[μ] β} : (f : α → β) ≤ᵐ[μ] g ↔ f ≤ g :=
  lift_rel_iff_coe_fn.symm
#align measure_theory.ae_eq_fun.coe_fn_le MeasureTheory.AeEqFun.coe_fn_le

instance [PartialOrder β] : PartialOrder (α →ₘ[μ] β) :=
  PartialOrder.lift toGerm to_germ_injective

section Lattice

section Sup

variable [SemilatticeSup β] [HasContinuousSup β]

instance : HasSup (α →ₘ[μ] β) where sup f g := AeEqFun.comp₂ (· ⊔ ·) continuous_sup f g

theorem coe_fn_sup (f g : α →ₘ[μ] β) : ⇑(f ⊔ g) =ᵐ[μ] fun x => f x ⊔ g x :=
  coe_fn_comp₂ _ _ _ _
#align measure_theory.ae_eq_fun.coe_fn_sup MeasureTheory.AeEqFun.coe_fn_sup

protected theorem le_sup_left (f g : α →ₘ[μ] β) : f ≤ f ⊔ g := by
  rw [← coe_fn_le]
  filter_upwards [coe_fn_sup f g] with _ ha
  rw [ha]
  exact le_sup_left
#align measure_theory.ae_eq_fun.le_sup_left MeasureTheory.AeEqFun.le_sup_left

protected theorem le_sup_right (f g : α →ₘ[μ] β) : g ≤ f ⊔ g := by
  rw [← coe_fn_le]
  filter_upwards [coe_fn_sup f g] with _ ha
  rw [ha]
  exact le_sup_right
#align measure_theory.ae_eq_fun.le_sup_right MeasureTheory.AeEqFun.le_sup_right

protected theorem sup_le (f g f' : α →ₘ[μ] β) (hf : f ≤ f') (hg : g ≤ f') : f ⊔ g ≤ f' := by
  rw [← coe_fn_le] at hf hg⊢
  filter_upwards [hf, hg, coe_fn_sup f g] with _ haf hag ha_sup
  rw [ha_sup]
  exact sup_le haf hag
#align measure_theory.ae_eq_fun.sup_le MeasureTheory.AeEqFun.sup_le

end Sup

section Inf

variable [SemilatticeInf β] [HasContinuousInf β]

instance : HasInf (α →ₘ[μ] β) where inf f g := AeEqFun.comp₂ (· ⊓ ·) continuous_inf f g

theorem coe_fn_inf (f g : α →ₘ[μ] β) : ⇑(f ⊓ g) =ᵐ[μ] fun x => f x ⊓ g x :=
  coe_fn_comp₂ _ _ _ _
#align measure_theory.ae_eq_fun.coe_fn_inf MeasureTheory.AeEqFun.coe_fn_inf

protected theorem inf_le_left (f g : α →ₘ[μ] β) : f ⊓ g ≤ f := by
  rw [← coe_fn_le]
  filter_upwards [coe_fn_inf f g] with _ ha
  rw [ha]
  exact inf_le_left
#align measure_theory.ae_eq_fun.inf_le_left MeasureTheory.AeEqFun.inf_le_left

protected theorem inf_le_right (f g : α →ₘ[μ] β) : f ⊓ g ≤ g := by
  rw [← coe_fn_le]
  filter_upwards [coe_fn_inf f g] with _ ha
  rw [ha]
  exact inf_le_right
#align measure_theory.ae_eq_fun.inf_le_right MeasureTheory.AeEqFun.inf_le_right

protected theorem le_inf (f' f g : α →ₘ[μ] β) (hf : f' ≤ f) (hg : f' ≤ g) : f' ≤ f ⊓ g := by
  rw [← coe_fn_le] at hf hg⊢
  filter_upwards [hf, hg, coe_fn_inf f g] with _ haf hag ha_inf
  rw [ha_inf]
  exact le_inf haf hag
#align measure_theory.ae_eq_fun.le_inf MeasureTheory.AeEqFun.le_inf

end Inf

instance [Lattice β] [TopologicalLattice β] : Lattice (α →ₘ[μ] β) :=
  { AeEqFun.partialOrder with sup := HasSup.sup, le_sup_left := AeEqFun.le_sup_left,
    le_sup_right := AeEqFun.le_sup_right, sup_le := AeEqFun.sup_le, inf := HasInf.inf,
    inf_le_left := AeEqFun.inf_le_left, inf_le_right := AeEqFun.inf_le_right, le_inf := AeEqFun.le_inf }

end Lattice

end Order

variable (α)

/-- The equivalence class of a constant function: `[λ a:α, b]`, based on the equivalence relation of
    being almost everywhere equal -/
def const (b : β) : α →ₘ[μ] β :=
  mk (fun a : α => b) aeStronglyMeasurableConst
#align measure_theory.ae_eq_fun.const MeasureTheory.AeEqFun.const

theorem coe_fn_const (b : β) : (const α b : α →ₘ[μ] β) =ᵐ[μ] Function.const α b :=
  coe_fn_mk _ _
#align measure_theory.ae_eq_fun.coe_fn_const MeasureTheory.AeEqFun.coe_fn_const

variable {α}

instance [Inhabited β] : Inhabited (α →ₘ[μ] β) :=
  ⟨const α default⟩

@[to_additive]
instance [One β] : One (α →ₘ[μ] β) :=
  ⟨const α 1⟩

@[to_additive]
theorem one_def [One β] : (1 : α →ₘ[μ] β) = mk (fun a : α => 1) aeStronglyMeasurableConst :=
  rfl
#align measure_theory.ae_eq_fun.one_def MeasureTheory.AeEqFun.one_def

@[to_additive]
theorem coe_fn_one [One β] : ⇑(1 : α →ₘ[μ] β) =ᵐ[μ] 1 :=
  coe_fn_const _ _
#align measure_theory.ae_eq_fun.coe_fn_one MeasureTheory.AeEqFun.coe_fn_one

@[simp, to_additive]
theorem one_to_germ [One β] : (1 : α →ₘ[μ] β).toGerm = 1 :=
  rfl
#align measure_theory.ae_eq_fun.one_to_germ MeasureTheory.AeEqFun.one_to_germ

-- Note we set up the scalar actions before the `monoid` structures in case we want to
-- try to override the `nsmul` or `zsmul` fields in future.
section HasSmul

variable {𝕜 𝕜' : Type _}

variable [HasSmul 𝕜 γ] [HasContinuousConstSmul 𝕜 γ]

variable [HasSmul 𝕜' γ] [HasContinuousConstSmul 𝕜' γ]

instance : HasSmul 𝕜 (α →ₘ[μ] γ) :=
  ⟨fun c f => comp ((· • ·) c) (continuous_id.const_smul c) f⟩

@[simp]
theorem smul_mk (c : 𝕜) (f : α → γ) (hf : AeStronglyMeasurable f μ) :
    c • (mk f hf : α →ₘ[μ] γ) = mk (c • f) (hf.const_smul _) :=
  rfl
#align measure_theory.ae_eq_fun.smul_mk MeasureTheory.AeEqFun.smul_mk

theorem coe_fn_smul (c : 𝕜) (f : α →ₘ[μ] γ) : ⇑(c • f) =ᵐ[μ] c • f :=
  coe_fn_comp _ _ _
#align measure_theory.ae_eq_fun.coe_fn_smul MeasureTheory.AeEqFun.coe_fn_smul

theorem smul_to_germ (c : 𝕜) (f : α →ₘ[μ] γ) : (c • f).toGerm = c • f.toGerm :=
  comp_to_germ _ _ _
#align measure_theory.ae_eq_fun.smul_to_germ MeasureTheory.AeEqFun.smul_to_germ

instance [SmulCommClass 𝕜 𝕜' γ] : SmulCommClass 𝕜 𝕜' (α →ₘ[μ] γ) :=
  ⟨fun a b f => inductionOn f $ fun f hf => by simp_rw [smul_mk, smul_comm]⟩

instance [HasSmul 𝕜 𝕜'] [IsScalarTower 𝕜 𝕜' γ] : IsScalarTower 𝕜 𝕜' (α →ₘ[μ] γ) :=
  ⟨fun a b f => inductionOn f $ fun f hf => by simp_rw [smul_mk, smul_assoc]⟩

instance [HasSmul 𝕜ᵐᵒᵖ γ] [IsCentralScalar 𝕜 γ] : IsCentralScalar 𝕜 (α →ₘ[μ] γ) :=
  ⟨fun a f => inductionOn f $ fun f hf => by simp_rw [smul_mk, op_smul_eq_smul]⟩

end HasSmul

section Mul

variable [Mul γ] [HasContinuousMul γ]

@[to_additive]
instance : Mul (α →ₘ[μ] γ) :=
  ⟨comp₂ (· * ·) continuous_mul⟩

@[simp, to_additive]
theorem mk_mul_mk (f g : α → γ) (hf : AeStronglyMeasurable f μ) (hg : AeStronglyMeasurable g μ) :
    (mk f hf : α →ₘ[μ] γ) * mk g hg = mk (f * g) (hf.mul hg) :=
  rfl
#align measure_theory.ae_eq_fun.mk_mul_mk MeasureTheory.AeEqFun.mk_mul_mk

@[to_additive]
theorem coe_fn_mul (f g : α →ₘ[μ] γ) : ⇑(f * g) =ᵐ[μ] f * g :=
  coe_fn_comp₂ _ _ _ _
#align measure_theory.ae_eq_fun.coe_fn_mul MeasureTheory.AeEqFun.coe_fn_mul

@[simp, to_additive]
theorem mul_to_germ (f g : α →ₘ[μ] γ) : (f * g).toGerm = f.toGerm * g.toGerm :=
  comp₂_to_germ _ _ _ _
#align measure_theory.ae_eq_fun.mul_to_germ MeasureTheory.AeEqFun.mul_to_germ

end Mul

instance [AddMonoid γ] [HasContinuousAdd γ] : AddMonoid (α →ₘ[μ] γ) :=
  to_germ_injective.AddMonoid toGerm zero_to_germ add_to_germ fun _ _ => smul_to_germ _ _

instance [AddCommMonoid γ] [HasContinuousAdd γ] : AddCommMonoid (α →ₘ[μ] γ) :=
  to_germ_injective.AddCommMonoid toGerm zero_to_germ add_to_germ fun _ _ => smul_to_germ _ _

section Monoid

variable [Monoid γ] [HasContinuousMul γ]

instance : Pow (α →ₘ[μ] γ) ℕ :=
  ⟨fun f n => comp _ (continuous_pow n) f⟩

@[simp]
theorem mk_pow (f : α → γ) (hf) (n : ℕ) :
    (mk f hf : α →ₘ[μ] γ) ^ n = mk (f ^ n) ((continuous_pow n).compAeStronglyMeasurable hf) :=
  rfl
#align measure_theory.ae_eq_fun.mk_pow MeasureTheory.AeEqFun.mk_pow

theorem coe_fn_pow (f : α →ₘ[μ] γ) (n : ℕ) : ⇑(f ^ n) =ᵐ[μ] f ^ n :=
  coe_fn_comp _ _ _
#align measure_theory.ae_eq_fun.coe_fn_pow MeasureTheory.AeEqFun.coe_fn_pow

@[simp]
theorem pow_to_germ (f : α →ₘ[μ] γ) (n : ℕ) : (f ^ n).toGerm = f.toGerm ^ n :=
  comp_to_germ _ _ _
#align measure_theory.ae_eq_fun.pow_to_germ MeasureTheory.AeEqFun.pow_to_germ

@[to_additive]
instance : Monoid (α →ₘ[μ] γ) :=
  to_germ_injective.Monoid toGerm one_to_germ mul_to_germ pow_to_germ

/-- `ae_eq_fun.to_germ` as a `monoid_hom`. -/
@[to_additive "`ae_eq_fun.to_germ` as an `add_monoid_hom`.", simps]
def toGermMonoidHom : (α →ₘ[μ] γ) →* μ.ae.Germ γ where
  toFun := toGerm
  map_one' := one_to_germ
  map_mul' := mul_to_germ
#align measure_theory.ae_eq_fun.to_germ_monoid_hom MeasureTheory.AeEqFun.toGermMonoidHom

end Monoid

@[to_additive]
instance [CommMonoid γ] [HasContinuousMul γ] : CommMonoid (α →ₘ[μ] γ) :=
  to_germ_injective.CommMonoid toGerm one_to_germ mul_to_germ pow_to_germ

section Group

variable [Group γ] [TopologicalGroup γ]

section Inv

@[to_additive]
instance : Inv (α →ₘ[μ] γ) :=
  ⟨comp Inv.inv continuous_inv⟩

@[simp, to_additive]
theorem inv_mk (f : α → γ) (hf) : (mk f hf : α →ₘ[μ] γ)⁻¹ = mk f⁻¹ hf.inv :=
  rfl
#align measure_theory.ae_eq_fun.inv_mk MeasureTheory.AeEqFun.inv_mk

@[to_additive]
theorem coe_fn_inv (f : α →ₘ[μ] γ) : ⇑f⁻¹ =ᵐ[μ] f⁻¹ :=
  coe_fn_comp _ _ _
#align measure_theory.ae_eq_fun.coe_fn_inv MeasureTheory.AeEqFun.coe_fn_inv

@[to_additive]
theorem inv_to_germ (f : α →ₘ[μ] γ) : f⁻¹.toGerm = f.toGerm⁻¹ :=
  comp_to_germ _ _ _
#align measure_theory.ae_eq_fun.inv_to_germ MeasureTheory.AeEqFun.inv_to_germ

end Inv

section Div

@[to_additive]
instance : Div (α →ₘ[μ] γ) :=
  ⟨comp₂ Div.div continuous_div'⟩

@[simp, to_additive]
theorem mk_div (f g : α → γ) (hf : AeStronglyMeasurable f μ) (hg : AeStronglyMeasurable g μ) :
    mk (f / g) (hf.div hg) = (mk f hf : α →ₘ[μ] γ) / mk g hg :=
  rfl
#align measure_theory.ae_eq_fun.mk_div MeasureTheory.AeEqFun.mk_div

@[to_additive]
theorem coe_fn_div (f g : α →ₘ[μ] γ) : ⇑(f / g) =ᵐ[μ] f / g :=
  coe_fn_comp₂ _ _ _ _
#align measure_theory.ae_eq_fun.coe_fn_div MeasureTheory.AeEqFun.coe_fn_div

@[to_additive]
theorem div_to_germ (f g : α →ₘ[μ] γ) : (f / g).toGerm = f.toGerm / g.toGerm :=
  comp₂_to_germ _ _ _ _
#align measure_theory.ae_eq_fun.div_to_germ MeasureTheory.AeEqFun.div_to_germ

end Div

section Zpow

instance hasIntPow : Pow (α →ₘ[μ] γ) ℤ :=
  ⟨fun f n => comp _ (continuous_zpow n) f⟩
#align measure_theory.ae_eq_fun.has_int_pow MeasureTheory.AeEqFun.hasIntPow

@[simp]
theorem mk_zpow (f : α → γ) (hf) (n : ℤ) :
    (mk f hf : α →ₘ[μ] γ) ^ n = mk (f ^ n) ((continuous_zpow n).compAeStronglyMeasurable hf) :=
  rfl
#align measure_theory.ae_eq_fun.mk_zpow MeasureTheory.AeEqFun.mk_zpow

theorem coe_fn_zpow (f : α →ₘ[μ] γ) (n : ℤ) : ⇑(f ^ n) =ᵐ[μ] f ^ n :=
  coe_fn_comp _ _ _
#align measure_theory.ae_eq_fun.coe_fn_zpow MeasureTheory.AeEqFun.coe_fn_zpow

@[simp]
theorem zpow_to_germ (f : α →ₘ[μ] γ) (n : ℤ) : (f ^ n).toGerm = f.toGerm ^ n :=
  comp_to_germ _ _ _
#align measure_theory.ae_eq_fun.zpow_to_germ MeasureTheory.AeEqFun.zpow_to_germ

end Zpow

end Group

instance [AddGroup γ] [TopologicalAddGroup γ] : AddGroup (α →ₘ[μ] γ) :=
  to_germ_injective.AddGroup toGerm zero_to_germ add_to_germ neg_to_germ sub_to_germ (fun _ _ => smul_to_germ _ _)
    fun _ _ => smul_to_germ _ _

instance [AddCommGroup γ] [TopologicalAddGroup γ] : AddCommGroup (α →ₘ[μ] γ) :=
  to_germ_injective.AddCommGroup toGerm zero_to_germ add_to_germ neg_to_germ sub_to_germ (fun _ _ => smul_to_germ _ _)
    fun _ _ => smul_to_germ _ _

@[to_additive]
instance [Group γ] [TopologicalGroup γ] : Group (α →ₘ[μ] γ) :=
  to_germ_injective.Group _ one_to_germ mul_to_germ inv_to_germ div_to_germ pow_to_germ zpow_to_germ

@[to_additive]
instance [CommGroup γ] [TopologicalGroup γ] : CommGroup (α →ₘ[μ] γ) :=
  to_germ_injective.CommGroup _ one_to_germ mul_to_germ inv_to_germ div_to_germ pow_to_germ zpow_to_germ

section Module

variable {𝕜 : Type _}

instance [Monoid 𝕜] [MulAction 𝕜 γ] [HasContinuousConstSmul 𝕜 γ] : MulAction 𝕜 (α →ₘ[μ] γ) :=
  to_germ_injective.MulAction toGerm smul_to_germ

instance [Monoid 𝕜] [AddMonoid γ] [HasContinuousAdd γ] [DistribMulAction 𝕜 γ] [HasContinuousConstSmul 𝕜 γ] :
    DistribMulAction 𝕜 (α →ₘ[μ] γ) :=
  to_germ_injective.DistribMulAction (toGermAddMonoidHom : (α →ₘ[μ] γ) →+ _) fun c : 𝕜 => smul_to_germ c

instance [Semiring 𝕜] [AddCommMonoid γ] [HasContinuousAdd γ] [Module 𝕜 γ] [HasContinuousConstSmul 𝕜 γ] :
    Module 𝕜 (α →ₘ[μ] γ) :=
  to_germ_injective.Module 𝕜 (toGermAddMonoidHom : (α →ₘ[μ] γ) →+ _) smul_to_germ

end Module

open Ennreal

/-- For `f : α → ℝ≥0∞`, define `∫ [f]` to be `∫ f` -/
def lintegral (f : α →ₘ[μ] ℝ≥0∞) : ℝ≥0∞ :=
  Quotient.liftOn' f (fun f => ∫⁻ a, (f : α → ℝ≥0∞) a ∂μ) fun f g => lintegral_congr_ae
#align measure_theory.ae_eq_fun.lintegral MeasureTheory.AeEqFun.lintegral

@[simp]
theorem lintegral_mk (f : α → ℝ≥0∞) (hf) : (mk f hf : α →ₘ[μ] ℝ≥0∞).lintegral = ∫⁻ a, f a ∂μ :=
  rfl
#align measure_theory.ae_eq_fun.lintegral_mk MeasureTheory.AeEqFun.lintegral_mk

theorem lintegral_coe_fn (f : α →ₘ[μ] ℝ≥0∞) : (∫⁻ a, f a ∂μ) = f.lintegral := by rw [← lintegral_mk, mk_coe_fn]
#align measure_theory.ae_eq_fun.lintegral_coe_fn MeasureTheory.AeEqFun.lintegral_coe_fn

@[simp]
theorem lintegral_zero : lintegral (0 : α →ₘ[μ] ℝ≥0∞) = 0 :=
  lintegral_zero
#align measure_theory.ae_eq_fun.lintegral_zero MeasureTheory.AeEqFun.lintegral_zero

@[simp]
theorem lintegral_eq_zero_iff {f : α →ₘ[μ] ℝ≥0∞} : lintegral f = 0 ↔ f = 0 :=
  inductionOn f $ fun f hf => (lintegral_eq_zero_iff' hf.AeMeasurable).trans mk_eq_mk.symm
#align measure_theory.ae_eq_fun.lintegral_eq_zero_iff MeasureTheory.AeEqFun.lintegral_eq_zero_iff

theorem lintegral_add (f g : α →ₘ[μ] ℝ≥0∞) : lintegral (f + g) = lintegral f + lintegral g :=
  inductionOn₂ f g $ fun f hf g hg => by simp [lintegral_add_left' hf.ae_measurable]
#align measure_theory.ae_eq_fun.lintegral_add MeasureTheory.AeEqFun.lintegral_add

theorem lintegral_mono {f g : α →ₘ[μ] ℝ≥0∞} : f ≤ g → lintegral f ≤ lintegral g :=
  inductionOn₂ f g $ fun f hf g hg hfg => lintegral_mono_ae hfg
#align measure_theory.ae_eq_fun.lintegral_mono MeasureTheory.AeEqFun.lintegral_mono

section Abs

theorem coe_fn_abs {β} [TopologicalSpace β] [Lattice β] [TopologicalLattice β] [AddGroup β] [TopologicalAddGroup β]
    (f : α →ₘ[μ] β) : ⇑|f| =ᵐ[μ] fun x => |f x| := by
  simp_rw [abs_eq_sup_neg]
  filter_upwards [ae_eq_fun.coe_fn_sup f (-f), ae_eq_fun.coe_fn_neg f] with x hx_sup hx_neg
  rw [hx_sup, hx_neg, Pi.neg_apply]
#align measure_theory.ae_eq_fun.coe_fn_abs MeasureTheory.AeEqFun.coe_fn_abs

end Abs

section PosPart

variable [LinearOrder γ] [OrderClosedTopology γ] [Zero γ]

/-- Positive part of an `ae_eq_fun`. -/
def posPart (f : α →ₘ[μ] γ) : α →ₘ[μ] γ :=
  comp (fun x => max x 0) (continuous_id.max continuous_const) f
#align measure_theory.ae_eq_fun.pos_part MeasureTheory.AeEqFun.posPart

@[simp]
theorem pos_part_mk (f : α → γ) (hf) :
    posPart (mk f hf : α →ₘ[μ] γ) =
      mk (fun x => max (f x) 0) ((continuous_id.max continuous_const).compAeStronglyMeasurable hf) :=
  rfl
#align measure_theory.ae_eq_fun.pos_part_mk MeasureTheory.AeEqFun.pos_part_mk

theorem coe_fn_pos_part (f : α →ₘ[μ] γ) : ⇑(posPart f) =ᵐ[μ] fun a => max (f a) 0 :=
  coe_fn_comp _ _ _
#align measure_theory.ae_eq_fun.coe_fn_pos_part MeasureTheory.AeEqFun.coe_fn_pos_part

end PosPart

end AeEqFun

end MeasureTheory

namespace ContinuousMap

open MeasureTheory

variable [TopologicalSpace α] [BorelSpace α] (μ)

variable [TopologicalSpace β] [SecondCountableTopologyEither α β] [PseudoMetrizableSpace β]

/-- The equivalence class of `μ`-almost-everywhere measurable functions associated to a continuous
map. -/
def toAeEqFun (f : C(α, β)) : α →ₘ[μ] β :=
  AeEqFun.mk f f.Continuous.AeStronglyMeasurable
#align continuous_map.to_ae_eq_fun ContinuousMap.toAeEqFun

theorem coe_fn_to_ae_eq_fun (f : C(α, β)) : f.toAeEqFun μ =ᵐ[μ] f :=
  AeEqFun.coe_fn_mk f _
#align continuous_map.coe_fn_to_ae_eq_fun ContinuousMap.coe_fn_to_ae_eq_fun

variable [Group β] [TopologicalGroup β]

/-- The `mul_hom` from the group of continuous maps from `α` to `β` to the group of equivalence
classes of `μ`-almost-everywhere measurable functions. -/
@[to_additive
      "The `add_hom` from the group of continuous maps from `α` to `β` to the group of\nequivalence classes of `μ`-almost-everywhere measurable functions."]
def toAeEqFunMulHom : C(α, β) →* α →ₘ[μ] β where
  toFun := ContinuousMap.toAeEqFun μ
  map_one' := rfl
  map_mul' f g := AeEqFun.mk_mul_mk _ _ f.Continuous.AeStronglyMeasurable g.Continuous.AeStronglyMeasurable
#align continuous_map.to_ae_eq_fun_mul_hom ContinuousMap.toAeEqFunMulHom

variable {𝕜 : Type _} [Semiring 𝕜]

variable [TopologicalSpace γ] [PseudoMetrizableSpace γ] [AddCommGroup γ] [Module 𝕜 γ] [TopologicalAddGroup γ]
  [HasContinuousConstSmul 𝕜 γ] [SecondCountableTopologyEither α γ]

/-- The linear map from the group of continuous maps from `α` to `β` to the group of equivalence
classes of `μ`-almost-everywhere measurable functions. -/
def toAeEqFunLinearMap : C(α, γ) →ₗ[𝕜] α →ₘ[μ] γ :=
  { toAeEqFunAddHom μ with map_smul' := fun c f => AeEqFun.smul_mk c f f.Continuous.AeStronglyMeasurable }
#align continuous_map.to_ae_eq_fun_linear_map ContinuousMap.toAeEqFunLinearMap

end ContinuousMap

/- ./././Mathport/Syntax/Translate/Command.lean:702:14: unsupported user command assert_not_exists -/
-- Guard against import creep
