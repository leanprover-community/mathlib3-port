import Mathbin.Order.Filter.Bases

/-!
# (Co)product of a family of filters

In this file we define two filters on `Π i, α i` and prove some basic properties of these filters.

* `filter.pi (f : Π i, filter (α i))` to be the maximal filter on `Π i, α i` such that
  `∀ i, filter.tendsto (function.eval i) (filter.pi f) (f i)`. It is defined as
  `Π i, filter.comap (function.eval i) (f i)`. This is a generalization of `filter.prod` to indexed
  products.

* `filter.Coprod (f : Π i, filter (α i))`: a generalization of `filter.coprod`; it is the supremum
  of `comap (eval i) (f i)`.
-/


open Set Function

open_locale Classical Filter

namespace Filter

variable{ι : Type _}{α : ι → Type _}{f f₁ f₂ : ∀ i, Filter (α i)}{s : ∀ i, Set (α i)}

section Pi

/-- The product of an indexed family of filters. -/
def pi (f : ∀ i, Filter (α i)) : Filter (∀ i, α i) :=
  ⨅i, comap (eval i) (f i)

theorem tendsto_eval_pi (f : ∀ i, Filter (α i)) (i : ι) : tendsto (eval i) (pi f) (f i) :=
  tendsto_infi' i tendsto_comap

theorem tendsto_pi {β : Type _} {m : β → ∀ i, α i} {l : Filter β} :
  tendsto m l (pi f) ↔ ∀ i, tendsto (fun x => m x i) l (f i) :=
  by 
    simp only [pi, tendsto_infi, tendsto_comap_iff]

theorem le_pi {g : Filter (∀ i, α i)} : g ≤ pi f ↔ ∀ i, tendsto (eval i) g (f i) :=
  tendsto_pi

@[mono]
theorem pi_mono (h : ∀ i, f₁ i ≤ f₂ i) : pi f₁ ≤ pi f₂ :=
  infi_le_infi$ fun i => comap_mono$ h i

theorem mem_pi_of_mem (i : ι) {s : Set (α i)} (hs : s ∈ f i) : eval i ⁻¹' s ∈ pi f :=
  mem_infi_of_mem i$ preimage_mem_comap hs

theorem pi_mem_pi {I : Set ι} (hI : finite I) (h : ∀ i (_ : i ∈ I), s i ∈ f i) : I.pi s ∈ pi f :=
  by 
    rw [pi_def, bInter_eq_Inter]
    refine' mem_infi_of_Inter hI (fun i => _) subset.rfl 
    exact preimage_mem_comap (h i i.2)

theorem mem_pi {s : Set (∀ i, α i)} :
  s ∈ pi f ↔ ∃ I : Set ι, finite I ∧ ∃ t : ∀ i, Set (α i), (∀ i, t i ∈ f i) ∧ I.pi t ⊆ s :=
  by 
    split 
    ·
      simp only [pi, mem_infi', mem_comap, pi_def]
      rintro ⟨I, If, V, hVf, hVI, rfl, -⟩
      choose t htf htV using hVf 
      exact ⟨I, If, t, htf, bInter_mono fun i _ => htV i⟩
    ·
      rintro ⟨I, If, t, htf, hts⟩
      exact mem_of_superset (pi_mem_pi If$ fun i _ => htf i) hts

theorem mem_pi' {s : Set (∀ i, α i)} :
  s ∈ pi f ↔ ∃ I : Finset ι, ∃ t : ∀ i, Set (α i), (∀ i, t i ∈ f i) ∧ Set.Pi («expr↑ » I) t ⊆ s :=
  mem_pi.trans exists_finite_iff_finset

-- error in Order.Filter.Pi: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem mem_of_pi_mem_pi
[∀ i, ne_bot (f i)]
{I : set ι}
(h : «expr ∈ »(I.pi s, pi f))
{i : ι}
(hi : «expr ∈ »(i, I)) : «expr ∈ »(s i, f i) :=
begin
  rcases [expr mem_pi.1 h, "with", "⟨", ident I', ",", ident I'f, ",", ident t, ",", ident htf, ",", ident hts, "⟩"],
  refine [expr mem_of_superset (htf i) (λ x hx, _)],
  have [] [":", expr ∀ i, (t i).nonempty] [],
  from [expr λ i, nonempty_of_mem (htf i)],
  choose [] [ident g] [ident hg] [],
  have [] [":", expr «expr ∈ »(update g i x, I'.pi t)] [],
  { intros [ident j, ident hj],
    rcases [expr eq_or_ne j i, "with", "(", ident rfl, "|", ident hne, ")"]; simp [] [] [] ["*"] [] [] },
  simpa [] [] [] [] [] ["using", expr hts this i hi]
end

@[simp]
theorem pi_mem_pi_iff [∀ i, ne_bot (f i)] {I : Set ι} (hI : finite I) : I.pi s ∈ pi f ↔ ∀ i (_ : i ∈ I), s i ∈ f i :=
  ⟨fun h i hi => mem_of_pi_mem_pi h hi, pi_mem_pi hI⟩

-- error in Order.Filter.Pi: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem pi_inf_principal_univ_pi_eq_bot : «expr ↔ »(«expr = »(«expr ⊓ »(pi f, expr𝓟() (set.pi univ s)), «expr⊥»()), «expr∃ , »((i), «expr = »(«expr ⊓ »(f i, expr𝓟() (s i)), «expr⊥»()))) :=
begin
  split,
  { simp [] [] ["only"] ["[", expr inf_principal_eq_bot, ",", expr mem_pi, "]"] [] [],
    contrapose ["!"] [],
    rintros ["(", ident hsf, ":", expr ∀
     i, «expr∃ᶠ in , »((x), f i, «expr ∈ »(x, s i)), ")", ident I, ident If, ident t, ident htf, ident hts],
    have [] [":", expr ∀ i, «expr ∩ »(s i, t i).nonempty] [],
    from [expr λ i, ((hsf i).and_eventually (htf i)).exists],
    choose [] [ident x] [ident hxs, ident hxt] [],
    exact [expr hts (λ i hi, hxt i) (mem_univ_pi.2 hxs)] },
  { simp [] [] ["only"] ["[", expr inf_principal_eq_bot, "]"] [] [],
    rintro ["⟨", ident i, ",", ident hi, "⟩"],
    filter_upwards ["[", expr mem_pi_of_mem i hi, "]"] [],
    exact [expr λ x, mt (λ h, h i trivial)] }
end

@[simp]
theorem pi_inf_principal_pi_eq_bot [∀ i, ne_bot (f i)] {I : Set ι} :
  pi f⊓𝓟 (Set.Pi I s) = ⊥ ↔ ∃ (i : _)(_ : i ∈ I), f i⊓𝓟 (s i) = ⊥ :=
  by 
    rw [←univ_pi_piecewise I, pi_inf_principal_univ_pi_eq_bot]
    refine' exists_congr fun i => _ 
    byCases' hi : i ∈ I <;> simp [hi, (‹∀ i, ne_bot (f i)› i).Ne]

@[simp]
theorem pi_inf_principal_univ_pi_ne_bot : ne_bot (pi f⊓𝓟 (Set.Pi univ s)) ↔ ∀ i, ne_bot (f i⊓𝓟 (s i)) :=
  by 
    simp [ne_bot_iff]

@[simp]
theorem pi_inf_principal_pi_ne_bot [∀ i, ne_bot (f i)] {I : Set ι} :
  ne_bot (pi f⊓𝓟 (I.pi s)) ↔ ∀ i (_ : i ∈ I), ne_bot (f i⊓𝓟 (s i)) :=
  by 
    simp [ne_bot_iff]

instance pi_inf_principal_pi.ne_bot [h : ∀ i, ne_bot (f i⊓𝓟 (s i))] {I : Set ι} : ne_bot (pi f⊓𝓟 (I.pi s)) :=
  (pi_inf_principal_univ_pi_ne_bot.2 ‹_›).mono$ inf_le_inf_left _$ principal_mono.2$ fun x hx i hi => hx i trivialₓ

@[simp]
theorem pi_eq_bot : pi f = ⊥ ↔ ∃ i, f i = ⊥ :=
  by 
    simpa using @pi_inf_principal_univ_pi_eq_bot ι α f fun _ => univ

@[simp]
theorem pi_ne_bot : ne_bot (pi f) ↔ ∀ i, ne_bot (f i) :=
  by 
    simp [ne_bot_iff]

instance  [∀ i, ne_bot (f i)] : ne_bot (pi f) :=
  pi_ne_bot.2 ‹_›

end Pi

/-! ### `n`-ary coproducts of filters -/


section Coprod

/-- Coproduct of filters. -/
protected def Coprod (f : ∀ i, Filter (α i)) : Filter (∀ i, α i) :=
  ⨆i : ι, comap (eval i) (f i)

theorem mem_Coprod_iff {s : Set (∀ i, α i)} :
  s ∈ Filter.coprodₓ f ↔ ∀ (i : ι), ∃ (t₁ : _)(_ : t₁ ∈ f i), eval i ⁻¹' t₁ ⊆ s :=
  by 
    simp [Filter.coprodₓ]

theorem compl_mem_Coprod_iff {s : Set (∀ i, α i)} :
  «expr ᶜ» s ∈ Filter.coprodₓ f ↔ ∃ t : ∀ i, Set (α i), (∀ i, «expr ᶜ» (t i) ∈ f i) ∧ s ⊆ Set.Pi univ fun i => t i :=
  by 
    rw [(surjective_pi_map fun i => @compl_surjective (Set (α i)) _).exists]
    simpRw [mem_Coprod_iff, Classical.skolem, exists_prop, @subset_compl_comm _ _ s, ←preimage_compl, ←subset_Inter_iff,
      ←univ_pi_eq_Inter, compl_compl]

theorem Coprod_ne_bot_iff' : ne_bot (Filter.coprodₓ f) ↔ (∀ i, Nonempty (α i)) ∧ ∃ d, ne_bot (f d) :=
  by 
    simp only [Filter.coprodₓ, supr_ne_bot, ←exists_and_distrib_left, ←comap_eval_ne_bot_iff']

@[simp]
theorem Coprod_ne_bot_iff [∀ i, Nonempty (α i)] : ne_bot (Filter.coprodₓ f) ↔ ∃ d, ne_bot (f d) :=
  by 
    simp [Coprod_ne_bot_iff']

theorem ne_bot.Coprod [∀ i, Nonempty (α i)] {i : ι} (h : ne_bot (f i)) : ne_bot (Filter.coprodₓ f) :=
  Coprod_ne_bot_iff.2 ⟨i, h⟩

@[instance]
theorem Coprod_ne_bot [∀ i, Nonempty (α i)] [Nonempty ι] (f : ∀ i, Filter (α i)) [H : ∀ i, ne_bot (f i)] :
  ne_bot (Filter.coprodₓ f) :=
  (H (Classical.arbitrary ι)).coprod

@[mono]
theorem Coprod_mono (hf : ∀ i, f₁ i ≤ f₂ i) : Filter.coprodₓ f₁ ≤ Filter.coprodₓ f₂ :=
  supr_le_supr$ fun i => comap_mono (hf i)

variable{β : ι → Type _}{m : ∀ i, α i → β i}

-- error in Order.Filter.Pi: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem map_pi_map_Coprod_le : «expr ≤ »(map (λ
  k : ∀ i, α i, λ i, m i (k i)) (filter.Coprod f), filter.Coprod (λ i, map (m i) (f i))) :=
begin
  simp [] [] ["only"] ["[", expr le_def, ",", expr mem_map, ",", expr mem_Coprod_iff, "]"] [] [],
  intros [ident s, ident h, ident i],
  obtain ["⟨", ident t, ",", ident H, ",", ident hH, "⟩", ":=", expr h i],
  exact [expr ⟨{x : α i | «expr ∈ »(m i x, t)}, H, λ x hx, hH hx⟩]
end

-- error in Order.Filter.Pi: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem tendsto.pi_map_Coprod
{g : ∀ i, filter (β i)}
(h : ∀ i, tendsto (m i) (f i) (g i)) : tendsto (λ k : ∀ i, α i, λ i, m i (k i)) (filter.Coprod f) (filter.Coprod g) :=
map_pi_map_Coprod_le.trans (Coprod_mono h)

end Coprod

end Filter

