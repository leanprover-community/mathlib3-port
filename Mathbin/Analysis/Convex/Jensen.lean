import Mathbin.Analysis.Convex.Combination 
import Mathbin.Analysis.Convex.Function

/-!
# Jensen's inequality and maximum principle for convex functions

In this file, we prove the finite Jensen inequality and the finite maximum principle for convex
functions. The integral versions are to be found in `analysis.convex.integral`.

## Main declarations

Jensen's inequalities:
* `convex_on.map_center_mass_le`, `convex_on.map_sum_le`: Convex Jensen's inequality. The image of a
  convex combination of points under a convex function is less than the convex combination of the
  images.
* `concave_on.le_map_center_mass`, `concave_on.le_map_sum`: Concave Jensen's inequality.

As corollaries, we get:
* `convex_on.exists_ge_of_mem_convex_hull `: Maximum principle for convex functions.
* `concave_on.exists_le_of_mem_convex_hull`: Minimum principle for concave functions.
-/


open Finset LinearMap Set

open_locale BigOperators Classical Convex Pointwise

variable{𝕜 E F β ι : Type _}

/-! ### Jensen's inequality -/


section Jensen

variable[LinearOrderedField
      𝕜][AddCommGroupₓ
      E][OrderedAddCommGroup
      β][Module 𝕜 E][Module 𝕜 β][OrderedSmul 𝕜 β]{s : Set E}{f : E → β}{t : Finset ι}{w : ι → 𝕜}{p : ι → E}

-- error in Analysis.Convex.Jensen: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Convex **Jensen's inequality**, `finset.center_mass` version. -/
theorem convex_on.map_center_mass_le
(hf : convex_on 𝕜 s f)
(h₀ : ∀ i «expr ∈ » t, «expr ≤ »(0, w i))
(h₁ : «expr < »(0, «expr∑ in , »((i), t, w i)))
(hmem : ∀ i «expr ∈ » t, «expr ∈ »(p i, s)) : «expr ≤ »(f (t.center_mass w p), t.center_mass w «expr ∘ »(f, p)) :=
begin
  have [ident hmem'] [":", expr ∀
   i «expr ∈ » t, «expr ∈ »((p i, «expr ∘ »(f, p) i), {p : «expr × »(E, β) | «expr ∧ »(«expr ∈ »(p.1, s), «expr ≤ »(f p.1, p.2))})] [],
  from [expr λ i hi, ⟨hmem i hi, le_rfl⟩],
  convert [] [expr (hf.convex_epigraph.center_mass_mem h₀ h₁ hmem').2] []; simp [] [] ["only"] ["[", expr center_mass, ",", expr function.comp, ",", expr prod.smul_fst, ",", expr prod.fst_sum, ",", expr prod.smul_snd, ",", expr prod.snd_sum, "]"] [] []
end

/-- Concave **Jensen's inequality**, `finset.center_mass` version. -/
theorem ConcaveOn.le_map_center_mass (hf : ConcaveOn 𝕜 s f) (h₀ : ∀ i (_ : i ∈ t), 0 ≤ w i) (h₁ : 0 < ∑i in t, w i)
  (hmem : ∀ i (_ : i ∈ t), p i ∈ s) : t.center_mass w (f ∘ p) ≤ f (t.center_mass w p) :=
  @ConvexOn.map_center_mass_le 𝕜 E (OrderDual β) _ _ _ _ _ _ _ _ _ _ _ _ hf h₀ h₁ hmem

/-- Convex **Jensen's inequality**, `finset.sum` version. -/
theorem ConvexOn.map_sum_le (hf : ConvexOn 𝕜 s f) (h₀ : ∀ i (_ : i ∈ t), 0 ≤ w i) (h₁ : (∑i in t, w i) = 1)
  (hmem : ∀ i (_ : i ∈ t), p i ∈ s) : f (∑i in t, w i • p i) ≤ ∑i in t, w i • f (p i) :=
  by 
    simpa only [center_mass, h₁, inv_one, one_smul] using hf.map_center_mass_le h₀ (h₁.symm ▸ zero_lt_one) hmem

/-- Concave **Jensen's inequality**, `finset.sum` version. -/
theorem ConcaveOn.le_map_sum (hf : ConcaveOn 𝕜 s f) (h₀ : ∀ i (_ : i ∈ t), 0 ≤ w i) (h₁ : (∑i in t, w i) = 1)
  (hmem : ∀ i (_ : i ∈ t), p i ∈ s) : (∑i in t, w i • f (p i)) ≤ f (∑i in t, w i • p i) :=
  @ConvexOn.map_sum_le 𝕜 E (OrderDual β) _ _ _ _ _ _ _ _ _ _ _ _ hf h₀ h₁ hmem

end Jensen

/-! ### Maximum principle -/


section MaximumPrinciple

variable[LinearOrderedField
      𝕜][AddCommGroupₓ
      E][LinearOrderedAddCommGroup
      β][Module 𝕜 E][Module 𝕜 β][OrderedSmul 𝕜 β]{s : Set E}{f : E → β}{t : Finset ι}{w : ι → 𝕜}{p : ι → E}

-- error in Analysis.Convex.Jensen: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If a function `f` is convex on `s`, then the value it takes at some center of mass of points of
`s` is less than the value it takes on one of those points. -/
theorem convex_on.exists_ge_of_center_mass
(h : convex_on 𝕜 s f)
(hw₀ : ∀ i «expr ∈ » t, «expr ≤ »(0, w i))
(hw₁ : «expr < »(0, «expr∑ in , »((i), t, w i)))
(hp : ∀ i «expr ∈ » t, «expr ∈ »(p i, s)) : «expr∃ , »((i «expr ∈ » t), «expr ≤ »(f (t.center_mass w p), f (p i))) :=
begin
  set [] [ident y] [] [":="] [expr t.center_mass w p] [],
  suffices [ident h] [":", expr «expr∃ , »((i «expr ∈ » t.filter (λ
      i, «expr ≠ »(w i, 0))), «expr ≤ »(«expr • »(w i, f y), «expr • »(w i, «expr ∘ »(f, p) i)))],
  { obtain ["⟨", ident i, ",", ident hi, ",", ident hfi, "⟩", ":=", expr h],
    rw [expr mem_filter] ["at", ident hi],
    exact [expr ⟨i, hi.1, «expr $ »(smul_le_smul_iff_of_pos, (hw₀ i hi.1).lt_of_ne hi.2.symm).1 hfi⟩] },
  have [ident hw'] [":", expr «expr < »((0 : 𝕜), «expr∑ in , »((i), filter (λ
      i, «expr ≠ »(w i, 0)) t, w i))] [":=", expr by rwa [expr sum_filter_ne_zero] []],
  refine [expr exists_le_of_sum_le (nonempty_of_sum_ne_zero hw'.ne') _],
  rw ["[", "<-", expr sum_smul, ",", "<-", expr smul_le_smul_iff_of_pos (inv_pos.2 hw'), ",", expr inv_smul_smul₀ hw'.ne', ",", "<-", expr finset.center_mass, ",", expr finset.center_mass_filter_ne_zero, "]"] [],
  exact [expr h.map_center_mass_le hw₀ hw₁ hp],
  apply_instance
end

/-- If a function `f` is concave on `s`, then the value it takes at some center of mass of points of
`s` is greater than the value it takes on one of those points. -/
theorem ConcaveOn.exists_le_of_center_mass (h : ConcaveOn 𝕜 s f) (hw₀ : ∀ i (_ : i ∈ t), 0 ≤ w i)
  (hw₁ : 0 < ∑i in t, w i) (hp : ∀ i (_ : i ∈ t), p i ∈ s) : ∃ (i : _)(_ : i ∈ t), f (p i) ≤ f (t.center_mass w p) :=
  @ConvexOn.exists_ge_of_center_mass 𝕜 E (OrderDual β) _ _ _ _ _ _ _ _ _ _ _ _ h hw₀ hw₁ hp

/-- Maximum principle for convex functions. If a function `f` is convex on the convex hull of `s`,
then the eventual maximum of `f` on `convex_hull 𝕜 s` lies in `s`. -/
theorem ConvexOn.exists_ge_of_mem_convex_hull (hf : ConvexOn 𝕜 (convexHull 𝕜 s) f) {x} (hx : x ∈ convexHull 𝕜 s) :
  ∃ (y : _)(_ : y ∈ s), f x ≤ f y :=
  by 
    rw [_root_.convex_hull_eq] at hx 
    obtain ⟨α, t, w, p, hw₀, hw₁, hp, rfl⟩ := hx 
    rcases hf.exists_ge_of_center_mass hw₀ (hw₁.symm ▸ zero_lt_one) fun i hi => subset_convex_hull 𝕜 s (hp i hi) with
      ⟨i, hit, Hi⟩
    exact ⟨p i, hp i hit, Hi⟩

/-- Minimum principle for concave functions. If a function `f` is concave on the convex hull of `s`,
then the eventual minimum of `f` on `convex_hull 𝕜 s` lies in `s`. -/
theorem ConcaveOn.exists_le_of_mem_convex_hull (hf : ConcaveOn 𝕜 (convexHull 𝕜 s) f) {x} (hx : x ∈ convexHull 𝕜 s) :
  ∃ (y : _)(_ : y ∈ s), f y ≤ f x :=
  @ConvexOn.exists_ge_of_mem_convex_hull 𝕜 E (OrderDual β) _ _ _ _ _ _ _ _ hf _ hx

end MaximumPrinciple

