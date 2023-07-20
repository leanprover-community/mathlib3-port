/-
Copyright (c) 2021 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import Mathbin.Analysis.Convex.Function

#align_import analysis.convex.quasiconvex from "leanprover-community/mathlib"@"9a48a083b390d9b84a71efbdc4e8dfa26a687104"

/-!
# Quasiconvex and quasiconcave functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines quasiconvexity, quasiconcavity and quasilinearity of functions, which are
generalizations of unimodality and monotonicity. Convexity implies quasiconvexity, concavity implies
quasiconcavity, and monotonicity implies quasilinearity.

## Main declarations

* `quasiconvex_on 𝕜 s f`: Quasiconvexity of the function `f` on the set `s` with scalars `𝕜`. This
  means that, for all `r`, `{x ∈ s | f x ≤ r}` is `𝕜`-convex.
* `quasiconcave_on 𝕜 s f`: Quasiconcavity of the function `f` on the set `s` with scalars `𝕜`. This
  means that, for all `r`, `{x ∈ s | r ≤ f x}` is `𝕜`-convex.
* `quasilinear_on 𝕜 s f`: Quasilinearity of the function `f` on the set `s` with scalars `𝕜`. This
  means that `f` is both quasiconvex and quasiconcave.

## References

* https://en.wikipedia.org/wiki/Quasiconvex_function
-/


open Function OrderDual Set

variable {𝕜 E F β : Type _}

section OrderedSemiring

variable [OrderedSemiring 𝕜]

section AddCommMonoid

variable [AddCommMonoid E] [AddCommMonoid F]

section OrderedAddCommMonoid

variable (𝕜) [OrderedAddCommMonoid β] [SMul 𝕜 E] (s : Set E) (f : E → β)

#print QuasiconvexOn /-
/-- A function is quasiconvex if all its sublevels are convex.
This means that, for all `r`, `{x ∈ s | f x ≤ r}` is `𝕜`-convex. -/
def QuasiconvexOn : Prop :=
  ∀ r, Convex 𝕜 ({x ∈ s | f x ≤ r})
#align quasiconvex_on QuasiconvexOn
-/

#print QuasiconcaveOn /-
/-- A function is quasiconcave if all its superlevels are convex.
This means that, for all `r`, `{x ∈ s | r ≤ f x}` is `𝕜`-convex. -/
def QuasiconcaveOn : Prop :=
  ∀ r, Convex 𝕜 ({x ∈ s | r ≤ f x})
#align quasiconcave_on QuasiconcaveOn
-/

#print QuasilinearOn /-
/-- A function is quasilinear if it is both quasiconvex and quasiconcave.
This means that, for all `r`,
the sets `{x ∈ s | f x ≤ r}` and `{x ∈ s | r ≤ f x}` are `𝕜`-convex. -/
def QuasilinearOn : Prop :=
  QuasiconvexOn 𝕜 s f ∧ QuasiconcaveOn 𝕜 s f
#align quasilinear_on QuasilinearOn
-/

variable {𝕜 s f}

#print QuasiconvexOn.dual /-
theorem QuasiconvexOn.dual : QuasiconvexOn 𝕜 s f → QuasiconcaveOn 𝕜 s (toDual ∘ f) :=
  id
#align quasiconvex_on.dual QuasiconvexOn.dual
-/

#print QuasiconcaveOn.dual /-
theorem QuasiconcaveOn.dual : QuasiconcaveOn 𝕜 s f → QuasiconvexOn 𝕜 s (toDual ∘ f) :=
  id
#align quasiconcave_on.dual QuasiconcaveOn.dual
-/

#print QuasilinearOn.dual /-
theorem QuasilinearOn.dual : QuasilinearOn 𝕜 s f → QuasilinearOn 𝕜 s (toDual ∘ f) :=
  And.symm
#align quasilinear_on.dual QuasilinearOn.dual
-/

#print Convex.quasiconvexOn_of_convex_le /-
theorem Convex.quasiconvexOn_of_convex_le (hs : Convex 𝕜 s) (h : ∀ r, Convex 𝕜 {x | f x ≤ r}) :
    QuasiconvexOn 𝕜 s f := fun r => hs.inter (h r)
#align convex.quasiconvex_on_of_convex_le Convex.quasiconvexOn_of_convex_le
-/

#print Convex.quasiconcaveOn_of_convex_ge /-
theorem Convex.quasiconcaveOn_of_convex_ge (hs : Convex 𝕜 s) (h : ∀ r, Convex 𝕜 {x | r ≤ f x}) :
    QuasiconcaveOn 𝕜 s f :=
  @Convex.quasiconvexOn_of_convex_le 𝕜 E βᵒᵈ _ _ _ _ _ _ hs h
#align convex.quasiconcave_on_of_convex_ge Convex.quasiconcaveOn_of_convex_ge
-/

#print QuasiconvexOn.convex /-
theorem QuasiconvexOn.convex [IsDirected β (· ≤ ·)] (hf : QuasiconvexOn 𝕜 s f) : Convex 𝕜 s :=
  fun x hx y hy a b ha hb hab =>
  let ⟨z, hxz, hyz⟩ := exists_ge_ge (f x) (f y)
  (hf _ ⟨hx, hxz⟩ ⟨hy, hyz⟩ ha hb hab).1
#align quasiconvex_on.convex QuasiconvexOn.convex
-/

#print QuasiconcaveOn.convex /-
theorem QuasiconcaveOn.convex [IsDirected β (· ≥ ·)] (hf : QuasiconcaveOn 𝕜 s f) : Convex 𝕜 s :=
  hf.dual.Convex
#align quasiconcave_on.convex QuasiconcaveOn.convex
-/

end OrderedAddCommMonoid

section LinearOrderedAddCommMonoid

variable [LinearOrderedAddCommMonoid β]

section SMul

variable [SMul 𝕜 E] {s : Set E} {f g : E → β}

#print QuasiconvexOn.sup /-
theorem QuasiconvexOn.sup (hf : QuasiconvexOn 𝕜 s f) (hg : QuasiconvexOn 𝕜 s g) :
    QuasiconvexOn 𝕜 s (f ⊔ g) := by
  intro r
  simp_rw [Pi.sup_def, sup_le_iff, Set.sep_and]
  exact (hf r).inter (hg r)
#align quasiconvex_on.sup QuasiconvexOn.sup
-/

#print QuasiconcaveOn.inf /-
theorem QuasiconcaveOn.inf (hf : QuasiconcaveOn 𝕜 s f) (hg : QuasiconcaveOn 𝕜 s g) :
    QuasiconcaveOn 𝕜 s (f ⊓ g) :=
  hf.dual.sup hg
#align quasiconcave_on.inf QuasiconcaveOn.inf
-/

#print quasiconvexOn_iff_le_max /-
theorem quasiconvexOn_iff_le_max :
    QuasiconvexOn 𝕜 s f ↔
      Convex 𝕜 s ∧
        ∀ ⦃x⦄,
          x ∈ s →
            ∀ ⦃y⦄,
              y ∈ s →
                ∀ ⦃a b : 𝕜⦄, 0 ≤ a → 0 ≤ b → a + b = 1 → f (a • x + b • y) ≤ max (f x) (f y) :=
  ⟨fun hf =>
    ⟨hf.Convex, fun x hx y hy a b ha hb hab =>
      (hf _ ⟨hx, le_max_left _ _⟩ ⟨hy, le_max_right _ _⟩ ha hb hab).2⟩,
    fun hf r x hx y hy a b ha hb hab =>
    ⟨hf.1 hx.1 hy.1 ha hb hab, (hf.2 hx.1 hy.1 ha hb hab).trans <| max_le hx.2 hy.2⟩⟩
#align quasiconvex_on_iff_le_max quasiconvexOn_iff_le_max
-/

#print quasiconcaveOn_iff_min_le /-
theorem quasiconcaveOn_iff_min_le :
    QuasiconcaveOn 𝕜 s f ↔
      Convex 𝕜 s ∧
        ∀ ⦃x⦄,
          x ∈ s →
            ∀ ⦃y⦄,
              y ∈ s →
                ∀ ⦃a b : 𝕜⦄, 0 ≤ a → 0 ≤ b → a + b = 1 → min (f x) (f y) ≤ f (a • x + b • y) :=
  @quasiconvexOn_iff_le_max 𝕜 E βᵒᵈ _ _ _ _ _ _
#align quasiconcave_on_iff_min_le quasiconcaveOn_iff_min_le
-/

#print quasilinearOn_iff_mem_uIcc /-
theorem quasilinearOn_iff_mem_uIcc :
    QuasilinearOn 𝕜 s f ↔
      Convex 𝕜 s ∧
        ∀ ⦃x⦄,
          x ∈ s →
            ∀ ⦃y⦄,
              y ∈ s →
                ∀ ⦃a b : 𝕜⦄, 0 ≤ a → 0 ≤ b → a + b = 1 → f (a • x + b • y) ∈ uIcc (f x) (f y) :=
  by
  rw [QuasilinearOn, quasiconvexOn_iff_le_max, quasiconcaveOn_iff_min_le, and_and_and_comm,
    and_self_iff]
  apply and_congr_right'
  simp_rw [← forall_and, ← Icc_min_max, mem_Icc, and_comm']
#align quasilinear_on_iff_mem_uIcc quasilinearOn_iff_mem_uIcc
-/

#print QuasiconvexOn.convex_lt /-
theorem QuasiconvexOn.convex_lt (hf : QuasiconvexOn 𝕜 s f) (r : β) : Convex 𝕜 ({x ∈ s | f x < r}) :=
  by
  refine' fun x hx y hy a b ha hb hab => _
  have h := hf _ ⟨hx.1, le_max_left _ _⟩ ⟨hy.1, le_max_right _ _⟩ ha hb hab
  exact ⟨h.1, h.2.trans_lt <| max_lt hx.2 hy.2⟩
#align quasiconvex_on.convex_lt QuasiconvexOn.convex_lt
-/

#print QuasiconcaveOn.convex_gt /-
theorem QuasiconcaveOn.convex_gt (hf : QuasiconcaveOn 𝕜 s f) (r : β) :
    Convex 𝕜 ({x ∈ s | r < f x}) :=
  hf.dual.convex_lt r
#align quasiconcave_on.convex_gt QuasiconcaveOn.convex_gt
-/

end SMul

section OrderedSMul

variable [SMul 𝕜 E] [Module 𝕜 β] [OrderedSMul 𝕜 β] {s : Set E} {f : E → β}

#print ConvexOn.quasiconvexOn /-
theorem ConvexOn.quasiconvexOn (hf : ConvexOn 𝕜 s f) : QuasiconvexOn 𝕜 s f :=
  hf.convex_le
#align convex_on.quasiconvex_on ConvexOn.quasiconvexOn
-/

#print ConcaveOn.quasiconcaveOn /-
theorem ConcaveOn.quasiconcaveOn (hf : ConcaveOn 𝕜 s f) : QuasiconcaveOn 𝕜 s f :=
  hf.convex_ge
#align concave_on.quasiconcave_on ConcaveOn.quasiconcaveOn
-/

end OrderedSMul

end LinearOrderedAddCommMonoid

end AddCommMonoid

section LinearOrderedAddCommMonoid

variable [LinearOrderedAddCommMonoid E] [OrderedAddCommMonoid β] [Module 𝕜 E] [OrderedSMul 𝕜 E]
  {s : Set E} {f : E → β}

#print MonotoneOn.quasiconvexOn /-
theorem MonotoneOn.quasiconvexOn (hf : MonotoneOn f s) (hs : Convex 𝕜 s) : QuasiconvexOn 𝕜 s f :=
  hf.convex_le hs
#align monotone_on.quasiconvex_on MonotoneOn.quasiconvexOn
-/

#print MonotoneOn.quasiconcaveOn /-
theorem MonotoneOn.quasiconcaveOn (hf : MonotoneOn f s) (hs : Convex 𝕜 s) : QuasiconcaveOn 𝕜 s f :=
  hf.convex_ge hs
#align monotone_on.quasiconcave_on MonotoneOn.quasiconcaveOn
-/

#print MonotoneOn.quasilinearOn /-
theorem MonotoneOn.quasilinearOn (hf : MonotoneOn f s) (hs : Convex 𝕜 s) : QuasilinearOn 𝕜 s f :=
  ⟨hf.QuasiconvexOn hs, hf.QuasiconcaveOn hs⟩
#align monotone_on.quasilinear_on MonotoneOn.quasilinearOn
-/

#print AntitoneOn.quasiconvexOn /-
theorem AntitoneOn.quasiconvexOn (hf : AntitoneOn f s) (hs : Convex 𝕜 s) : QuasiconvexOn 𝕜 s f :=
  hf.convex_le hs
#align antitone_on.quasiconvex_on AntitoneOn.quasiconvexOn
-/

#print AntitoneOn.quasiconcaveOn /-
theorem AntitoneOn.quasiconcaveOn (hf : AntitoneOn f s) (hs : Convex 𝕜 s) : QuasiconcaveOn 𝕜 s f :=
  hf.convex_ge hs
#align antitone_on.quasiconcave_on AntitoneOn.quasiconcaveOn
-/

#print AntitoneOn.quasilinearOn /-
theorem AntitoneOn.quasilinearOn (hf : AntitoneOn f s) (hs : Convex 𝕜 s) : QuasilinearOn 𝕜 s f :=
  ⟨hf.QuasiconvexOn hs, hf.QuasiconcaveOn hs⟩
#align antitone_on.quasilinear_on AntitoneOn.quasilinearOn
-/

#print Monotone.quasiconvexOn /-
theorem Monotone.quasiconvexOn (hf : Monotone f) : QuasiconvexOn 𝕜 univ f :=
  (hf.MonotoneOn _).QuasiconvexOn convex_univ
#align monotone.quasiconvex_on Monotone.quasiconvexOn
-/

#print Monotone.quasiconcaveOn /-
theorem Monotone.quasiconcaveOn (hf : Monotone f) : QuasiconcaveOn 𝕜 univ f :=
  (hf.MonotoneOn _).QuasiconcaveOn convex_univ
#align monotone.quasiconcave_on Monotone.quasiconcaveOn
-/

#print Monotone.quasilinearOn /-
theorem Monotone.quasilinearOn (hf : Monotone f) : QuasilinearOn 𝕜 univ f :=
  ⟨hf.QuasiconvexOn, hf.QuasiconcaveOn⟩
#align monotone.quasilinear_on Monotone.quasilinearOn
-/

#print Antitone.quasiconvexOn /-
theorem Antitone.quasiconvexOn (hf : Antitone f) : QuasiconvexOn 𝕜 univ f :=
  (hf.AntitoneOn _).QuasiconvexOn convex_univ
#align antitone.quasiconvex_on Antitone.quasiconvexOn
-/

#print Antitone.quasiconcaveOn /-
theorem Antitone.quasiconcaveOn (hf : Antitone f) : QuasiconcaveOn 𝕜 univ f :=
  (hf.AntitoneOn _).QuasiconcaveOn convex_univ
#align antitone.quasiconcave_on Antitone.quasiconcaveOn
-/

#print Antitone.quasilinearOn /-
theorem Antitone.quasilinearOn (hf : Antitone f) : QuasilinearOn 𝕜 univ f :=
  ⟨hf.QuasiconvexOn, hf.QuasiconcaveOn⟩
#align antitone.quasilinear_on Antitone.quasilinearOn
-/

end LinearOrderedAddCommMonoid

end OrderedSemiring

section LinearOrderedField

variable [LinearOrderedField 𝕜] [LinearOrderedAddCommMonoid β] {s : Set 𝕜} {f : 𝕜 → β}

#print QuasilinearOn.monotoneOn_or_antitoneOn /-
theorem QuasilinearOn.monotoneOn_or_antitoneOn (hf : QuasilinearOn 𝕜 s f) :
    MonotoneOn f s ∨ AntitoneOn f s :=
  by
  simp_rw [monotone_on_or_antitone_on_iff_uIcc, ← segment_eq_uIcc]
  rintro a ha b hb c hc h
  refine' ⟨((hf.2 _).segment_subset _ _ h).2, ((hf.1 _).segment_subset _ _ h).2⟩ <;> simp [*]
#align quasilinear_on.monotone_on_or_antitone_on QuasilinearOn.monotoneOn_or_antitoneOn
-/

#print quasilinearOn_iff_monotoneOn_or_antitoneOn /-
theorem quasilinearOn_iff_monotoneOn_or_antitoneOn (hs : Convex 𝕜 s) :
    QuasilinearOn 𝕜 s f ↔ MonotoneOn f s ∨ AntitoneOn f s :=
  ⟨fun h => h.monotoneOn_or_antitoneOn, fun h =>
    h.elim (fun h => h.QuasilinearOn hs) fun h => h.QuasilinearOn hs⟩
#align quasilinear_on_iff_monotone_on_or_antitone_on quasilinearOn_iff_monotoneOn_or_antitoneOn
-/

end LinearOrderedField

