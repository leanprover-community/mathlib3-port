/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro, Yury Kudryashov
-/
import Mathbin.Order.LiminfLimsup
import Mathbin.Topology.Algebra.Order.Basic
import Mathbin.Order.Filter.Archimedean

/-!
# Lemmas about liminf and limsup in an order topology.
-/


open Filter

open TopologicalSpace Classical

universe u v

variable {α : Type u} {β : Type v}

section LiminfLimsup

section OrderClosedTopology

variable [SemilatticeSup α] [TopologicalSpace α] [OrderTopology α]

theorem is_bounded_le_nhds (a : α) : (𝓝 a).IsBounded (· ≤ ·) :=
  (is_top_or_exists_gt a).elim (fun h => ⟨a, eventually_of_forall h⟩) fun ⟨b, hb⟩ => ⟨b, ge_mem_nhds hb⟩

theorem Filter.Tendsto.is_bounded_under_le {f : Filter β} {u : β → α} {a : α} (h : Tendsto u f (𝓝 a)) :
    f.IsBoundedUnder (· ≤ ·) u :=
  (is_bounded_le_nhds a).mono h

theorem Filter.Tendsto.bdd_above_range_of_cofinite {u : β → α} {a : α} (h : Tendsto u cofinite (𝓝 a)) :
    BddAbove (Set.Range u) :=
  h.is_bounded_under_le.bdd_above_range_of_cofinite

theorem Filter.Tendsto.bdd_above_range {u : ℕ → α} {a : α} (h : Tendsto u atTop (𝓝 a)) : BddAbove (Set.Range u) :=
  h.is_bounded_under_le.bdd_above_range

theorem is_cobounded_ge_nhds (a : α) : (𝓝 a).IsCobounded (· ≥ ·) :=
  (is_bounded_le_nhds a).is_cobounded_flip

theorem Filter.Tendsto.is_cobounded_under_ge {f : Filter β} {u : β → α} {a : α} [NeBot f] (h : Tendsto u f (𝓝 a)) :
    f.IsCoboundedUnder (· ≥ ·) u :=
  h.is_bounded_under_le.is_cobounded_flip

theorem is_bounded_le_at_bot (α : Type _) [hα : Nonempty α] [Preorderₓ α] : (atBot : Filter α).IsBounded (· ≤ ·) :=
  is_bounded_iff.2 ⟨Set.Iic hα.some, mem_at_bot _, hα.some, fun x hx => hx⟩

theorem Filter.Tendsto.is_bounded_under_le_at_bot {α : Type _} [Nonempty α] [Preorderₓ α] {f : Filter β} {u : β → α}
    (h : Tendsto u f atBot) : f.IsBoundedUnder (· ≤ ·) u :=
  (is_bounded_le_at_bot α).mono h

theorem bdd_above_range_of_tendsto_at_top_at_bot {α : Type _} [Nonempty α] [SemilatticeSup α] {u : ℕ → α}
    (hx : Tendsto u atTop atBot) : BddAbove (Set.Range u) :=
  (Filter.Tendsto.is_bounded_under_le_at_bot hx).bdd_above_range

end OrderClosedTopology

section OrderClosedTopology

variable [SemilatticeInf α] [TopologicalSpace α] [OrderTopology α]

theorem is_bounded_ge_nhds (a : α) : (𝓝 a).IsBounded (· ≥ ·) :=
  @is_bounded_le_nhds αᵒᵈ _ _ _ a

theorem Filter.Tendsto.is_bounded_under_ge {f : Filter β} {u : β → α} {a : α} (h : Tendsto u f (𝓝 a)) :
    f.IsBoundedUnder (· ≥ ·) u :=
  (is_bounded_ge_nhds a).mono h

theorem Filter.Tendsto.bdd_below_range_of_cofinite {u : β → α} {a : α} (h : Tendsto u cofinite (𝓝 a)) :
    BddBelow (Set.Range u) :=
  h.is_bounded_under_ge.bdd_below_range_of_cofinite

theorem Filter.Tendsto.bdd_below_range {u : ℕ → α} {a : α} (h : Tendsto u atTop (𝓝 a)) : BddBelow (Set.Range u) :=
  h.is_bounded_under_ge.bdd_below_range

theorem is_cobounded_le_nhds (a : α) : (𝓝 a).IsCobounded (· ≤ ·) :=
  (is_bounded_ge_nhds a).is_cobounded_flip

theorem Filter.Tendsto.is_cobounded_under_le {f : Filter β} {u : β → α} {a : α} [NeBot f] (h : Tendsto u f (𝓝 a)) :
    f.IsCoboundedUnder (· ≤ ·) u :=
  h.is_bounded_under_ge.is_cobounded_flip

theorem is_bounded_ge_at_top (α : Type _) [hα : Nonempty α] [Preorderₓ α] : (atTop : Filter α).IsBounded (· ≥ ·) :=
  is_bounded_le_at_bot αᵒᵈ

theorem Filter.Tendsto.is_bounded_under_ge_at_top {α : Type _} [Nonempty α] [Preorderₓ α] {f : Filter β} {u : β → α}
    (h : Tendsto u f atTop) : f.IsBoundedUnder (· ≥ ·) u :=
  (is_bounded_ge_at_top α).mono h

theorem bdd_below_range_of_tendsto_at_top_at_top {α : Type _} [Nonempty α] [SemilatticeInf α] {u : ℕ → α}
    (hx : Tendsto u atTop atTop) : BddBelow (Set.Range u) :=
  (Filter.Tendsto.is_bounded_under_ge_at_top hx).bdd_below_range

end OrderClosedTopology

section ConditionallyCompleteLinearOrder

variable [ConditionallyCompleteLinearOrder α]

theorem lt_mem_sets_of_Limsup_lt {f : Filter α} {b} (h : f.IsBounded (· ≤ ·)) (l : f.limsup < b) : ∀ᶠ a in f, a < b :=
  let ⟨c, (h : ∀ᶠ a in f, a ≤ c), hcb⟩ := exists_lt_of_cInf_lt h l
  (mem_of_superset h) fun a hac => lt_of_le_of_ltₓ hac hcb

theorem gt_mem_sets_of_Liminf_gt : ∀ {f : Filter α} {b}, f.IsBounded (· ≥ ·) → b < f.liminf → ∀ᶠ a in f, b < a :=
  @lt_mem_sets_of_Limsup_lt αᵒᵈ _

variable [TopologicalSpace α] [OrderTopology α]

/-- If the liminf and the limsup of a filter coincide, then this filter converges to
their common value, at least if the filter is eventually bounded above and below. -/
theorem le_nhds_of_Limsup_eq_Liminf {f : Filter α} {a : α} (hl : f.IsBounded (· ≤ ·)) (hg : f.IsBounded (· ≥ ·))
    (hs : f.limsup = a) (hi : f.liminf = a) : f ≤ 𝓝 a :=
  tendsto_order.2 <|
    And.intro (fun b hb => gt_mem_sets_of_Liminf_gt hg <| hi.symm ▸ hb) fun b hb =>
      lt_mem_sets_of_Limsup_lt hl <| hs.symm ▸ hb

theorem Limsup_nhds (a : α) : limsup (𝓝 a) = a :=
  cInf_eq_of_forall_ge_of_forall_gt_exists_lt (is_bounded_le_nhds a)
    (fun a' (h : { n : α | n ≤ a' } ∈ 𝓝 a) => show a ≤ a' from @mem_of_mem_nhds α _ a _ h) fun b (hba : a < b) =>
    show ∃ (c : _)(h : { n : α | n ≤ c } ∈ 𝓝 a), c < b from
      match dense_or_discreteₓ a b with
      | Or.inl ⟨c, hac, hcb⟩ => ⟨c, ge_mem_nhds hac, hcb⟩
      | Or.inr ⟨_, h⟩ => ⟨a, (𝓝 a).sets_of_superset (gt_mem_nhds hba) h, hba⟩

theorem Liminf_nhds : ∀ a : α, liminf (𝓝 a) = a :=
  @Limsup_nhds αᵒᵈ _ _ _

/-- If a filter is converging, its limsup coincides with its limit. -/
theorem Liminf_eq_of_le_nhds {f : Filter α} {a : α} [NeBot f] (h : f ≤ 𝓝 a) : f.liminf = a :=
  have hb_ge : IsBounded (· ≥ ·) f := (is_bounded_ge_nhds a).mono h
  have hb_le : IsBounded (· ≤ ·) f := (is_bounded_le_nhds a).mono h
  le_antisymmₓ
    (calc
      f.liminf ≤ f.limsup := Liminf_le_Limsup hb_le hb_ge
      _ ≤ (𝓝 a).limsup := Limsup_le_Limsup_of_le h hb_ge.is_cobounded_flip (is_bounded_le_nhds a)
      _ = a := Limsup_nhds a
      )
    (calc
      a = (𝓝 a).liminf := (Liminf_nhds a).symm
      _ ≤ f.liminf := Liminf_le_Liminf_of_le h (is_bounded_ge_nhds a) hb_le.is_cobounded_flip
      )

/-- If a filter is converging, its liminf coincides with its limit. -/
theorem Limsup_eq_of_le_nhds : ∀ {f : Filter α} {a : α} [NeBot f], f ≤ 𝓝 a → f.limsup = a :=
  @Liminf_eq_of_le_nhds αᵒᵈ _ _ _

/-- If a function has a limit, then its limsup coincides with its limit. -/
theorem Filter.Tendsto.limsup_eq {f : Filter β} {u : β → α} {a : α} [NeBot f] (h : Tendsto u f (𝓝 a)) :
    limsupₓ f u = a :=
  Limsup_eq_of_le_nhds h

/-- If a function has a limit, then its liminf coincides with its limit. -/
theorem Filter.Tendsto.liminf_eq {f : Filter β} {u : β → α} {a : α} [NeBot f] (h : Tendsto u f (𝓝 a)) :
    liminfₓ f u = a :=
  Liminf_eq_of_le_nhds h

-- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:62:18: unsupported non-interactive tactic is_bounded_default
-- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:62:18: unsupported non-interactive tactic is_bounded_default
/-- If the liminf and the limsup of a function coincide, then the limit of the function
exists and has the same value -/
theorem tendsto_of_liminf_eq_limsup {f : Filter β} {u : β → α} {a : α} (hinf : liminfₓ f u = a) (hsup : limsupₓ f u = a)
    (h : f.IsBoundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (h' : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default) :
    Tendsto u f (𝓝 a) :=
  le_nhds_of_Limsup_eq_Liminf h h' hsup hinf

-- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:62:18: unsupported non-interactive tactic is_bounded_default
-- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:62:18: unsupported non-interactive tactic is_bounded_default
/-- If a number `a` is less than or equal to the `liminf` of a function `f` at some filter
and is greater than or equal to the `limsup` of `f`, then `f` tends to `a` along this filter. -/
theorem tendsto_of_le_liminf_of_limsup_le {f : Filter β} {u : β → α} {a : α} (hinf : a ≤ liminfₓ f u)
    (hsup : limsupₓ f u ≤ a)
    (h : f.IsBoundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (h' : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default) :
    Tendsto u f (𝓝 a) :=
  if hf : f = ⊥ then hf.symm ▸ tendsto_bot
  else
    haveI : ne_bot f := ⟨hf⟩
    tendsto_of_liminf_eq_limsup (le_antisymmₓ (le_transₓ (liminf_le_limsup h h') hsup) hinf)
      (le_antisymmₓ hsup (le_transₓ hinf (liminf_le_limsup h h'))) h h'

-- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:62:18: unsupported non-interactive tactic is_bounded_default
-- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:62:18: unsupported non-interactive tactic is_bounded_default
/-- Assume that, for any `a < b`, a sequence can not be infinitely many times below `a` and
above `b`. If it is also ultimately bounded above and below, then it has to converge. This even
works if `a` and `b` are restricted to a dense subset.
-/
theorem tendsto_of_no_upcrossings [DenselyOrdered α] {f : Filter β} {u : β → α} {s : Set α} (hs : Dense s)
    (H : ∀ a ∈ s, ∀ b ∈ s, a < b → ¬((∃ᶠ n in f, u n < a) ∧ ∃ᶠ n in f, b < u n))
    (h : f.IsBoundedUnder (· ≤ ·) u := by
      run_tac
        is_bounded_default)
    (h' : f.IsBoundedUnder (· ≥ ·) u := by
      run_tac
        is_bounded_default) :
    ∃ c : α, Tendsto u f (𝓝 c) := by
  by_cases hbot:f = ⊥
  · rw [hbot]
    exact ⟨Inf ∅, tendsto_bot⟩
    
  haveI : ne_bot f := ⟨hbot⟩
  refine' ⟨limsup f u, _⟩
  apply tendsto_of_le_liminf_of_limsup_le _ le_rflₓ h h'
  by_contra' hlt
  obtain ⟨a, ⟨⟨la, au⟩, as⟩⟩ : ∃ a, (f.liminf u < a ∧ a < f.limsup u) ∧ a ∈ s :=
    dense_iff_inter_open.1 hs (Set.Ioo (f.liminf u) (f.limsup u)) is_open_Ioo (Set.nonempty_Ioo.2 hlt)
  obtain ⟨b, ⟨⟨ab, bu⟩, bs⟩⟩ : ∃ b, (a < b ∧ b < f.limsup u) ∧ b ∈ s :=
    dense_iff_inter_open.1 hs (Set.Ioo a (f.limsup u)) is_open_Ioo (Set.nonempty_Ioo.2 au)
  have A : ∃ᶠ n in f, u n < a := frequently_lt_of_liminf_lt (is_bounded.is_cobounded_ge h) la
  have B : ∃ᶠ n in f, b < u n := frequently_lt_of_lt_limsup (is_bounded.is_cobounded_le h') bu
  exact H a as b bs ab ⟨A, B⟩

end ConditionallyCompleteLinearOrder

end LiminfLimsup

section Monotoneₓ

variable {ι R S : Type _} {F : Filter ι} [NeBot F] [CompleteLinearOrder R] [TopologicalSpace R] [OrderTopology R]
  [CompleteLinearOrder S] [TopologicalSpace S] [OrderTopology S]

/-- An antitone function between complete linear ordered spaces sends a `filter.Limsup`
to the `filter.liminf` of the image if it is continuous at the `Limsup`. -/
theorem Antitoneₓ.map_Limsup_of_continuous_at {F : Filter R} [NeBot F] {f : R → S} (f_decr : Antitoneₓ f)
    (f_cont : ContinuousAt f F.limsup) : f F.limsup = F.liminf f := by
  apply le_antisymmₓ
  · have A : { a : R | ∀ᶠ n : R in F, n ≤ a }.Nonempty := ⟨⊤, by simp⟩
    rw [Limsup, f_decr.map_Inf_of_continuous_at' f_cont A]
    apply le_of_forall_ltₓ
    intro c hc
    simp only [liminf, Liminf, lt_Sup_iff, eventually_map, Set.mem_set_of_eq, exists_propₓ, Set.mem_image,
      exists_exists_and_eq_and] at hc⊢
    rcases hc with ⟨d, hd, h'd⟩
    refine' ⟨f d, _, h'd⟩
    filter_upwards [hd] with x hx using f_decr hx
    
  · rcases eq_or_lt_of_leₓ (bot_le : ⊥ ≤ F.Limsup) with (h | Limsup_ne_bot)
    · rw [← h]
      apply liminf_le_of_frequently_le
      apply frequently_of_forall
      intro x
      exact f_decr bot_le
      
    by_cases h':∃ c, c < F.Limsup ∧ Set.Ioo c F.Limsup = ∅
    · rcases h' with ⟨c, c_lt, hc⟩
      have B : ∃ᶠ n in F, F.Limsup ≤ n := by
        apply
          (frequently_lt_of_lt_Limsup
              (by
                run_tac
                  is_bounded_default)
              c_lt).mono
        intro x hx
        by_contra'
        have : (Set.Ioo c F.Limsup).Nonempty := ⟨x, ⟨hx, this⟩⟩
        simpa [hc]
      apply liminf_le_of_frequently_le
      exact B.mono fun x hx => f_decr hx
      
    by_contra' H
    obtain ⟨l, l_lt, h'l⟩ : ∃ l < F.Limsup, Set.Ioc l F.Limsup ⊆ { x : R | f x < F.liminf f }
    exact exists_Ioc_subset_of_mem_nhds ((tendsto_order.1 f_cont.tendsto).2 _ H) ⟨⊥, Limsup_ne_bot⟩
    obtain ⟨m, l_m, m_lt⟩ : (Set.Ioo l F.Limsup).Nonempty := by
      contrapose! h'
      refine' ⟨l, l_lt, by rwa [Set.not_nonempty_iff_eq_empty] at h'⟩
    have B : F.liminf f ≤ f m := by
      apply liminf_le_of_frequently_le
      apply
        (frequently_lt_of_lt_Limsup
            (by
              run_tac
                is_bounded_default)
            m_lt).mono
      intro x hx
      exact f_decr hx.le
    have I : f m < F.liminf f := h'l ⟨l_m, m_lt.le⟩
    exact lt_irreflₓ _ (B.trans_lt I)
    

/-- A continuous antitone function between complete linear ordered spaces sends a `filter.limsup`
to the `filter.liminf` of the images. -/
theorem Antitoneₓ.map_limsup_of_continuous_at {f : R → S} (f_decr : Antitoneₓ f) (a : ι → R)
    (f_cont : ContinuousAt f (F.limsup a)) : f (F.limsup a) = F.liminf (f ∘ a) :=
  f_decr.map_Limsup_of_continuous_at f_cont

/-- An antitone function between complete linear ordered spaces sends a `filter.Liminf`
to the `filter.limsup` of the image if it is continuous at the `Liminf`. -/
theorem Antitoneₓ.map_Liminf_of_continuous_at {F : Filter R} [NeBot F] {f : R → S} (f_decr : Antitoneₓ f)
    (f_cont : ContinuousAt f F.liminf) : f F.liminf = F.limsup f :=
  @Antitoneₓ.map_Limsup_of_continuous_at (OrderDual R) (OrderDual S) _ _ _ _ _ _ _ _ f f_decr.dual f_cont

/-- A continuous antitone function between complete linear ordered spaces sends a `filter.liminf`
to the `filter.limsup` of the images. -/
theorem Antitoneₓ.map_liminf_of_continuous_at {f : R → S} (f_decr : Antitoneₓ f) (a : ι → R)
    (f_cont : ContinuousAt f (F.liminf a)) : f (F.liminf a) = F.limsup (f ∘ a) :=
  f_decr.map_Liminf_of_continuous_at f_cont

/-- A monotone function between complete linear ordered spaces sends a `filter.Limsup`
to the `filter.limsup` of the image if it is continuous at the `Limsup`. -/
theorem Monotoneₓ.map_Limsup_of_continuous_at {F : Filter R} [NeBot F] {f : R → S} (f_incr : Monotoneₓ f)
    (f_cont : ContinuousAt f F.limsup) : f F.limsup = F.limsup f :=
  @Antitoneₓ.map_Limsup_of_continuous_at R (OrderDual S) _ _ _ _ _ _ _ _ f f_incr f_cont

/-- A continuous monotone function between complete linear ordered spaces sends a `filter.limsup`
to the `filter.limsup` of the images. -/
theorem Monotoneₓ.map_limsup_of_continuous_at {f : R → S} (f_incr : Monotoneₓ f) (a : ι → R)
    (f_cont : ContinuousAt f (F.limsup a)) : f (F.limsup a) = F.limsup (f ∘ a) :=
  f_incr.map_Limsup_of_continuous_at f_cont

/-- A monotone function between complete linear ordered spaces sends a `filter.Liminf`
to the `filter.liminf` of the image if it is continuous at the `Liminf`. -/
theorem Monotoneₓ.map_Liminf_of_continuous_at {F : Filter R} [NeBot F] {f : R → S} (f_incr : Monotoneₓ f)
    (f_cont : ContinuousAt f F.liminf) : f F.liminf = F.liminf f :=
  @Antitoneₓ.map_Liminf_of_continuous_at R (OrderDual S) _ _ _ _ _ _ _ _ f f_incr f_cont

/-- A continuous monotone function between complete linear ordered spaces sends a `filter.liminf`
to the `filter.liminf` of the images. -/
theorem Monotoneₓ.map_liminf_of_continuous_at {f : R → S} (f_incr : Monotoneₓ f) (a : ι → R)
    (f_cont : ContinuousAt f (F.liminf a)) : f (F.liminf a) = F.liminf (f ∘ a) :=
  f_incr.map_Liminf_of_continuous_at f_cont

end Monotoneₓ

section Indicator

open BigOperators

theorem limsup_eq_tendsto_sum_indicator_nat_at_top (s : ℕ → Set α) :
    limsupₓ atTop s =
      { ω | Tendsto (fun n => ∑ k in Finsetₓ.range n, (s (k + 1)).indicator (1 : α → ℕ) ω) atTop atTop } :=
  by
  ext ω
  simp only [limsup_eq_infi_supr_of_nat, ge_iff_leₓ, Set.supr_eq_Union, Set.infi_eq_Inter, Set.mem_Inter, Set.mem_Union,
    exists_propₓ]
  constructor
  · intro hω
    refine'
      tendsto_at_top_at_top_of_monotone'
        (fun n m hnm =>
          Finsetₓ.sum_mono_set_of_nonneg (fun i => Set.indicator_nonneg (fun _ _ => zero_le_one) _)
            (Finsetₓ.range_mono hnm))
        _
    rintro ⟨i, h⟩
    simp only [mem_upper_bounds, Set.mem_range, forall_exists_index, forall_apply_eq_imp_iff'] at h
    induction' i with k hk
    · obtain ⟨j, hj₁, hj₂⟩ := hω 1
      refine'
        not_ltₓ.2 (h <| j + 1) (lt_of_le_of_ltₓ (finset.sum_const_zero.symm : 0 = ∑ k in Finsetₓ.range (j + 1), 0).le _)
      refine'
        Finsetₓ.sum_lt_sum (fun m _ => Set.indicator_nonneg (fun _ _ => zero_le_one) _)
          ⟨j - 1, Finsetₓ.mem_range.2 (lt_of_le_of_ltₓ (Nat.sub_leₓ _ _) j.lt_succ_self), _⟩
      rw [Nat.sub_add_cancelₓ hj₁, Set.indicator_of_mem hj₂]
      exact zero_lt_one
      
    · rw [imp_false] at hk
      push_neg  at hk
      obtain ⟨i, hi⟩ := hk
      obtain ⟨j, hj₁, hj₂⟩ := hω (i + 1)
      replace hi : (∑ k in Finsetₓ.range i, (s (k + 1)).indicator 1 ω) = k + 1 := le_antisymmₓ (h i) hi
      refine' not_ltₓ.2 (h <| j + 1) _
      rw [← Finsetₓ.sum_range_add_sum_Ico _ (i.le_succ.trans (hj₁.trans j.le_succ)), hi]
      refine' lt_add_of_pos_right _ _
      rw [(finset.sum_const_zero.symm : 0 = ∑ k in Finsetₓ.ico i (j + 1), 0)]
      refine'
        Finsetₓ.sum_lt_sum (fun m _ => Set.indicator_nonneg (fun _ _ => zero_le_one) _)
          ⟨j - 1,
            Finsetₓ.mem_Ico.2
              ⟨(Nat.le_sub_iff_right (le_transₓ ((le_add_iff_nonneg_left _).2 zero_le') hj₁)).2 hj₁,
                lt_of_le_of_ltₓ (Nat.sub_leₓ _ _) j.lt_succ_self⟩,
            _⟩
      rw [Nat.sub_add_cancelₓ (le_transₓ ((le_add_iff_nonneg_left _).2 zero_le') hj₁), Set.indicator_of_mem hj₂]
      exact zero_lt_one
      
    
  · rintro hω i
    rw [Set.mem_set_of_eq, tendsto_at_top_at_top] at hω
    by_contra hcon
    push_neg  at hcon
    obtain ⟨j, h⟩ := hω (i + 1)
    have : (∑ k in Finsetₓ.range j, (s (k + 1)).indicator 1 ω) ≤ i := by
      have hle : ∀ j ≤ i, (∑ k in Finsetₓ.range j, (s (k + 1)).indicator 1 ω) ≤ i := by
        refine' fun j hij => (Finsetₓ.sum_le_card_nsmul _ _ _ _ : _ ≤ (Finsetₓ.range j).card • 1).trans _
        · exact fun m hm => Set.indicator_apply_le' (fun _ => le_rflₓ) fun _ => zero_le_one
          
        · simpa only [Finsetₓ.card_range, smul_eq_mul, mul_oneₓ]
          
      by_cases hij:j < i
      · exact hle _ hij.le
        
      · rw [← Finsetₓ.sum_range_add_sum_Ico _ (not_ltₓ.1 hij)]
        suffices (∑ k in Finsetₓ.ico i j, (s (k + 1)).indicator 1 ω) = 0 by
          rw [this, add_zeroₓ]
          exact hle _ le_rflₓ
        rw [Finsetₓ.sum_eq_zero fun m hm => _]
        exact Set.indicator_of_not_mem (hcon _ <| (Finsetₓ.mem_Ico.1 hm).1.trans m.le_succ) _
        
    exact not_leₓ.2 (lt_of_lt_of_leₓ i.lt_succ_self <| h _ le_rflₓ) this
    

theorem limsup_eq_tendsto_sum_indicator_at_top (R : Type _) [OrderedSemiring R] [Nontrivial R] [Archimedean R]
    (s : ℕ → Set α) :
    limsupₓ atTop s =
      { ω | Tendsto (fun n => ∑ k in Finsetₓ.range n, (s (k + 1)).indicator (1 : α → R) ω) atTop atTop } :=
  by
  rw [limsup_eq_tendsto_sum_indicator_nat_at_top s]
  ext ω
  simp only [Set.mem_set_of_eq]
  rw [(_ :
      (fun n => ∑ k in Finsetₓ.range n, (s (k + 1)).indicator (1 : α → R) ω) = fun n =>
        ↑(∑ k in Finsetₓ.range n, (s (k + 1)).indicator (1 : α → ℕ) ω))]
  · exact tendsto_coe_nat_at_top_iff.symm
    
  · ext n
    simp only [Set.indicatorₓ, Pi.one_apply, Finsetₓ.sum_boole, Nat.cast_id]
    

end Indicator

