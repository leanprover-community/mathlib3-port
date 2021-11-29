import Mathbin.MeasureTheory.Integral.Lebesgue

/-!
# The Giry monad

Let X be a measurable space. The collection of all measures on X again
forms a measurable space. This construction forms a monad on
measurable spaces and measurable functions, called the Giry monad.

Note that most sources use the term "Giry monad" for the restriction
to *probability* measures. Here we include all measures on X.

See also `measure_theory/category/Meas.lean`, containing an upgrade of the type-level
monad to an honest monad of the functor `Measure : Meas ⥤ Meas`.

## References

* <https://ncatlab.org/nlab/show/Giry+monad>

## Tags

giry monad
-/


noncomputable theory

open_locale Classical BigOperators Ennreal

open Classical Set Filter

variable{α β γ δ ε : Type _}

namespace MeasureTheory

namespace Measureₓ

variable[MeasurableSpace α][MeasurableSpace β]

/-- Measurability structure on `measure`: Measures are measurable w.r.t. all projections -/
instance  : MeasurableSpace (Measureₓ α) :=
  ⨆(s : Set α)(hs : MeasurableSet s), (borel ℝ≥0∞).comap fun μ => μ s

-- error in MeasureTheory.Measure.GiryMonad: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem measurable_coe {s : set α} (hs : measurable_set s) : measurable (λ μ : measure α, μ s) :=
«expr $ »(measurable.of_comap_le, «expr $ »(le_supr_of_le s, «expr $ »(le_supr_of_le hs, le_refl _)))

theorem measurable_of_measurable_coe (f : β → Measureₓ α)
  (h : ∀ (s : Set α) (hs : MeasurableSet s), Measurable fun b => f b s) : Measurable f :=
  Measurable.of_le_map$
    bsupr_le$
      fun s hs =>
        MeasurableSpace.comap_le_iff_le_map.2$
          by 
            rw [MeasurableSpace.map_comp] <;> exact h s hs

theorem measurable_measure {μ : α → Measureₓ β} :
  Measurable μ ↔ ∀ (s : Set β) (hs : MeasurableSet s), Measurable fun b => μ b s :=
  ⟨fun hμ s hs => (measurable_coe hs).comp hμ, measurable_of_measurable_coe μ⟩

-- error in MeasureTheory.Measure.GiryMonad: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem measurable_map (f : α → β) (hf : measurable f) : measurable (λ μ : measure α, map f μ) :=
«expr $ »(measurable_of_measurable_coe _, assume
 s
 hs, suffices measurable (λ
  μ : measure α, μ «expr ⁻¹' »(f, s)), by simpa [] [] [] ["[", expr map_apply, ",", expr hs, ",", expr hf, "]"] [] [],
 measurable_coe (hf hs))

theorem measurable_dirac : Measurable (measure.dirac : α → Measureₓ α) :=
  measurable_of_measurable_coe _$
    fun s hs =>
      by 
        simp only [dirac_apply', hs]
        exact measurable_one.indicator hs

-- error in MeasureTheory.Measure.GiryMonad: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem measurable_lintegral
{f : α → «exprℝ≥0∞»()}
(hf : measurable f) : measurable (λ μ : measure α, «expr∫⁻ , ∂ »((x), f x, μ)) :=
begin
  simp [] [] ["only"] ["[", expr lintegral_eq_supr_eapprox_lintegral, ",", expr hf, ",", expr simple_func.lintegral, "]"] [] [],
  refine [expr measurable_supr (λ n, finset.measurable_sum _ (λ i _, _))],
  refine [expr measurable.const_mul _ _],
  exact [expr measurable_coe ((simple_func.eapprox f n).measurable_set_preimage _)]
end

/-- Monadic join on `measure` in the category of measurable spaces and measurable
functions. -/
def join (m : Measureₓ (Measureₓ α)) : Measureₓ α :=
  measure.of_measurable (fun s hs => ∫⁻μ, μ s ∂m)
    (by 
      simp )
    (by 
      intro f hf h 
      simp [measure_Union h hf]
      apply lintegral_tsum 
      intro i 
      exact measurable_coe (hf i))

@[simp]
theorem join_apply {m : Measureₓ (Measureₓ α)} : ∀ {s : Set α}, MeasurableSet s → join m s = ∫⁻μ, μ s ∂m :=
  measure.of_measurable_apply

@[simp]
theorem join_zero : (0 : Measureₓ (Measureₓ α)).join = 0 :=
  by 
    ext1 s hs 
    simp [hs]

theorem measurable_join : Measurable (join : Measureₓ (Measureₓ α) → Measureₓ α) :=
  measurable_of_measurable_coe _$
    fun s hs =>
      by 
        simp only [join_apply hs] <;> exact measurable_lintegral (measurable_coe hs)

-- error in MeasureTheory.Measure.GiryMonad: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem lintegral_join
{m : measure (measure α)}
{f : α → «exprℝ≥0∞»()}
(hf : measurable f) : «expr = »(«expr∫⁻ , ∂ »((x), f x, join m), «expr∫⁻ , ∂ »((μ), «expr∫⁻ , ∂ »((x), f x, μ), m)) :=
begin
  rw ["[", expr lintegral_eq_supr_eapprox_lintegral hf, "]"] [],
  have [] [":", expr ∀
   n
   x, «expr = »(join m «expr ⁻¹' »(«expr⇑ »(simple_func.eapprox (λ
       a : α, f a) n), {x}), «expr∫⁻ , ∂ »((μ), μ «expr ⁻¹' »(«expr⇑ »(simple_func.eapprox (λ
        a : α, f a) n), {x}), m))] [":=", expr assume n x, join_apply (simple_func.measurable_set_preimage _ _)],
  simp [] [] ["only"] ["[", expr simple_func.lintegral, ",", expr this, "]"] [] [],
  transitivity [],
  have [] [":", expr ∀
   (s : exprℕ() → finset «exprℝ≥0∞»())
   (f : exprℕ() → «exprℝ≥0∞»() → measure α → «exprℝ≥0∞»())
   (hf : ∀ n r, measurable (f n r))
   (hm : monotone (λ
     n
     μ, «expr∑ in , »((r), s n, «expr * »(r, f n r μ)))), «expr = »(«expr⨆ , »((n : exprℕ()), «expr∑ in , »((r), s n, «expr * »(r, «expr∫⁻ , ∂ »((μ), f n r μ, m)))), «expr∫⁻ , ∂ »((μ), «expr⨆ , »((n : exprℕ()), «expr∑ in , »((r), s n, «expr * »(r, f n r μ))), m))] [],
  { assume [binders (s f hf hm)],
    symmetry,
    transitivity [],
    apply [expr lintegral_supr],
    { assume [binders (n)],
      exact [expr finset.measurable_sum _ (assume r _, (hf _ _).const_mul _)] },
    { exact [expr hm] },
    congr,
    funext [ident n],
    transitivity [],
    apply [expr lintegral_finset_sum],
    { assume [binders (r _)],
      exact [expr (hf _ _).const_mul _] },
    congr,
    funext [ident r],
    apply [expr lintegral_const_mul],
    exact [expr hf _ _] },
  specialize [expr this (λ n, simple_func.range (simple_func.eapprox f n))],
  specialize [expr this (λ n r μ, μ «expr ⁻¹' »(«expr⇑ »(simple_func.eapprox (λ a : α, f a) n), {r}))],
  refine [expr this _ _]; clear [ident this],
  { assume [binders (n r)],
    apply [expr measurable_coe],
    exact [expr simple_func.measurable_set_preimage _ _] },
  { change [expr monotone (λ n μ, (simple_func.eapprox f n).lintegral μ)] [] [],
    assume [binders (n m h μ)],
    refine [expr simple_func.lintegral_mono _ (le_refl _)],
    apply [expr simple_func.monotone_eapprox],
    assumption },
  congr,
  funext [ident μ],
  symmetry,
  apply [expr lintegral_eq_supr_eapprox_lintegral],
  exact [expr hf]
end

/-- Monadic bind on `measure`, only works in the category of measurable spaces and measurable
functions. When the function `f` is not measurable the result is not well defined. -/
def bind (m : Measureₓ α) (f : α → Measureₓ β) : Measureₓ β :=
  join (map f m)

@[simp]
theorem bind_zero_left (f : α → Measureₓ β) : bind 0 f = 0 :=
  by 
    simp [bind]

@[simp]
theorem bind_zero_right (m : Measureₓ α) : bind m (0 : α → Measureₓ β) = 0 :=
  by 
    ext1 s hs 
    simp only [bind, hs, join_apply, coe_zero, Pi.zero_apply]
    rw [lintegral_map (measurable_coe hs) measurable_zero]
    simp 

@[simp]
theorem bind_zero_right' (m : Measureₓ α) : bind m (fun _ => 0 : α → Measureₓ β) = 0 :=
  bind_zero_right m

@[simp]
theorem bind_apply {m : Measureₓ α} {f : α → Measureₓ β} {s : Set β} (hs : MeasurableSet s) (hf : Measurable f) :
  bind m f s = ∫⁻a, f a s ∂m :=
  by 
    rw [bind, join_apply hs, lintegral_map (measurable_coe hs) hf]

theorem measurable_bind' {g : α → Measureₓ β} (hg : Measurable g) : Measurable fun m => bind m g :=
  measurable_join.comp (measurable_map _ hg)

theorem lintegral_bind {m : Measureₓ α} {μ : α → Measureₓ β} {f : β → ℝ≥0∞} (hμ : Measurable μ) (hf : Measurable f) :
  (∫⁻x, f x ∂bind m μ) = ∫⁻a, ∫⁻x, f x ∂μ a ∂m :=
  (lintegral_join hf).trans (lintegral_map (measurable_lintegral hf) hμ)

theorem bind_bind {γ} [MeasurableSpace γ] {m : Measureₓ α} {f : α → Measureₓ β} {g : β → Measureₓ γ} (hf : Measurable f)
  (hg : Measurable g) : bind (bind m f) g = bind m fun a => bind (f a) g :=
  measure.ext$
    fun s hs =>
      by 
        rw [bind_apply hs hg, bind_apply hs ((measurable_bind' hg).comp hf), lintegral_bind hf]
        ·
          congr 
          funext a 
          exact (bind_apply hs hg).symm 
        exact (measurable_coe hs).comp hg

theorem bind_dirac {f : α → Measureₓ β} (hf : Measurable f) (a : α) : bind (dirac a) f = f a :=
  measure.ext$
    fun s hs =>
      by 
        rw [bind_apply hs hf, lintegral_dirac' a ((measurable_coe hs).comp hf)]

theorem dirac_bind {m : Measureₓ α} : bind m dirac = m :=
  measure.ext$
    fun s hs =>
      by 
        simp [bind_apply hs measurable_dirac, dirac_apply' _ hs, lintegral_indicator 1 hs]

theorem join_eq_bind (μ : Measureₓ (Measureₓ α)) : join μ = bind μ id :=
  by 
    rw [bind, map_id]

theorem join_map_map {f : α → β} (hf : Measurable f) (μ : Measureₓ (Measureₓ α)) :
  join (map (map f) μ) = map f (join μ) :=
  measure.ext$
    fun s hs =>
      by 
        rw [join_apply hs, map_apply hf hs, join_apply, lintegral_map (measurable_coe hs) (measurable_map f hf)]
        ·
          congr 
          funext ν 
          exact map_apply hf hs 
        exact hf hs

theorem join_map_join (μ : Measureₓ (Measureₓ (Measureₓ α))) : join (map join μ) = join (join μ) :=
  by 
    show bind μ join = join (join μ)
    rw [join_eq_bind, join_eq_bind, bind_bind measurable_id measurable_id]
    apply congr_argₓ (bind μ)
    funext ν 
    exact join_eq_bind ν

theorem join_map_dirac (μ : Measureₓ α) : join (map dirac μ) = μ :=
  dirac_bind

theorem join_dirac (μ : Measureₓ α) : join (dirac μ) = μ :=
  Eq.trans (join_eq_bind (dirac μ)) (bind_dirac measurable_id _)

end Measureₓ

end MeasureTheory

