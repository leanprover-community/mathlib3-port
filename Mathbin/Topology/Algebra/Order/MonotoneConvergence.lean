/-
Copyright (c) 2021 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth, Yury Kudryashov
-/
import Mathbin.Topology.Order.Basic

/-!
# Bounded monotone sequences converge

In this file we prove a few theorems of the form “if the range of a monotone function `f : ι → α`
admits a least upper bound `a`, then `f x` tends to `a` as `x → ∞`”, as well as version of this
statement for (conditionally) complete lattices that use `⨆ x, f x` instead of `is_lub`.

These theorems work for linear orders with order topologies as well as their products (both in terms
of `prod` and in terms of function types). In order to reduce code duplication, we introduce two
typeclasses (one for the property formulated above and one for the dual property), prove theorems
assuming one of these typeclasses, and provide instances for linear orders and their products.

We also prove some "inverse" results: if `f n` is a monotone sequence and `a` is its limit,
then `f n ≤ a` for all `n`.

## Tags

monotone convergence
-/


open Filter Set Function

open Filter TopologicalSpace Classical

variable {α β : Type _}

/-- We say that `α` is a `Sup_convergence_class` if the following holds. Let `f : ι → α` be a
monotone function, let `a : α` be a least upper bound of `set.range f`. Then `f x` tends to `𝓝 a` as
`x → ∞` (formally, at the filter `filter.at_top`). We require this for `ι = (s : set α)`, `f = coe`
in the definition, then prove it for any `f` in `tendsto_at_top_is_lub`.

This property holds for linear orders with order topology as well as their products. -/
class SupConvergenceClass (α : Type _) [Preorder α] [TopologicalSpace α] : Prop where
  tendsto_coe_at_top_is_lub : ∀ (a : α) (s : Set α), IsLub s a → Tendsto (coe : s → α) atTop (𝓝 a)
#align Sup_convergence_class SupConvergenceClass

/-- We say that `α` is an `Inf_convergence_class` if the following holds. Let `f : ι → α` be a
monotone function, let `a : α` be a greatest lower bound of `set.range f`. Then `f x` tends to `𝓝 a`
as `x → -∞` (formally, at the filter `filter.at_bot`). We require this for `ι = (s : set α)`,
`f = coe` in the definition, then prove it for any `f` in `tendsto_at_bot_is_glb`.

This property holds for linear orders with order topology as well as their products. -/
class InfConvergenceClass (α : Type _) [Preorder α] [TopologicalSpace α] : Prop where
  tendsto_coe_at_bot_is_glb : ∀ (a : α) (s : Set α), IsGlb s a → Tendsto (coe : s → α) atBot (𝓝 a)
#align Inf_convergence_class InfConvergenceClass

instance OrderDual.Sup_convergence_class [Preorder α] [TopologicalSpace α] [InfConvergenceClass α] :
    SupConvergenceClass αᵒᵈ :=
  ⟨‹InfConvergenceClass α›.1⟩
#align order_dual.Sup_convergence_class OrderDual.Sup_convergence_class

instance OrderDual.Inf_convergence_class [Preorder α] [TopologicalSpace α] [SupConvergenceClass α] :
    InfConvergenceClass αᵒᵈ :=
  ⟨‹SupConvergenceClass α›.1⟩
#align order_dual.Inf_convergence_class OrderDual.Inf_convergence_class

-- see Note [lower instance priority]
instance (priority := 100) LinearOrder.Sup_convergence_class [TopologicalSpace α] [LinearOrder α]
    [OrderTopology α] : SupConvergenceClass α := by
  refine' ⟨fun a s ha => tendsto_order.2 ⟨fun b hb => _, fun b hb => _⟩⟩
  · rcases ha.exists_between hb with ⟨c, hcs, bc, bca⟩
    lift c to s using hcs
    refine' (eventually_ge_at_top c).mono fun x hx => bc.trans_le hx
  · exact eventually_of_forall fun x => (ha.1 x.2).trans_lt hb
#align linear_order.Sup_convergence_class LinearOrder.Sup_convergence_class

-- see Note [lower instance priority]
instance (priority := 100) LinearOrder.Inf_convergence_class [TopologicalSpace α] [LinearOrder α]
    [OrderTopology α] : InfConvergenceClass α :=
  show InfConvergenceClass αᵒᵈᵒᵈ from OrderDual.Inf_convergence_class
#align linear_order.Inf_convergence_class LinearOrder.Inf_convergence_class

section

variable {ι : Type _} [Preorder ι] [TopologicalSpace α]

section IsLub

variable [Preorder α] [SupConvergenceClass α] {f : ι → α} {a : α}

theorem tendsto_at_top_is_lub (h_mono : Monotone f) (ha : IsLub (Set.range f) a) :
    Tendsto f atTop (𝓝 a) := by
  suffices : tendsto (range_factorization f) at_top at_top
  exact (SupConvergenceClass.tendsto_coe_at_top_is_lub _ _ ha).comp this
  exact h_mono.range_factorization.tendsto_at_top_at_top fun b => b.2.imp fun a ha => ha.ge
#align tendsto_at_top_is_lub tendsto_at_top_is_lub

theorem tendsto_at_bot_is_lub (h_anti : Antitone f) (ha : IsLub (Set.range f) a) :
    Tendsto f atBot (𝓝 a) := by convert tendsto_at_top_is_lub h_anti.dual_left ha
#align tendsto_at_bot_is_lub tendsto_at_bot_is_lub

end IsLub

section IsGlb

variable [Preorder α] [InfConvergenceClass α] {f : ι → α} {a : α}

theorem tendsto_at_bot_is_glb (h_mono : Monotone f) (ha : IsGlb (Set.range f) a) :
    Tendsto f atBot (𝓝 a) := by convert tendsto_at_top_is_lub h_mono.dual ha.dual
#align tendsto_at_bot_is_glb tendsto_at_bot_is_glb

theorem tendsto_at_top_is_glb (h_anti : Antitone f) (ha : IsGlb (Set.range f) a) :
    Tendsto f atTop (𝓝 a) := by convert tendsto_at_bot_is_lub h_anti.dual ha.dual
#align tendsto_at_top_is_glb tendsto_at_top_is_glb

end IsGlb

section Csupr

variable [ConditionallyCompleteLattice α] [SupConvergenceClass α] {f : ι → α} {a : α}

theorem tendsto_at_top_csupr (h_mono : Monotone f) (hbdd : BddAbove <| range f) :
    Tendsto f atTop (𝓝 (⨆ i, f i)) := by
  cases isEmpty_or_nonempty ι
  exacts[tendsto_of_is_empty, tendsto_at_top_is_lub h_mono (is_lub_csupr hbdd)]
#align tendsto_at_top_csupr tendsto_at_top_csupr

theorem tendsto_at_bot_csupr (h_anti : Antitone f) (hbdd : BddAbove <| range f) :
    Tendsto f atBot (𝓝 (⨆ i, f i)) := by convert tendsto_at_top_csupr h_anti.dual hbdd.dual
#align tendsto_at_bot_csupr tendsto_at_bot_csupr

end Csupr

section Cinfi

variable [ConditionallyCompleteLattice α] [InfConvergenceClass α] {f : ι → α} {a : α}

theorem tendsto_at_bot_cinfi (h_mono : Monotone f) (hbdd : BddBelow <| range f) :
    Tendsto f atBot (𝓝 (⨅ i, f i)) := by convert tendsto_at_top_csupr h_mono.dual hbdd.dual
#align tendsto_at_bot_cinfi tendsto_at_bot_cinfi

theorem tendsto_at_top_cinfi (h_anti : Antitone f) (hbdd : BddBelow <| range f) :
    Tendsto f atTop (𝓝 (⨅ i, f i)) := by convert tendsto_at_bot_csupr h_anti.dual hbdd.dual
#align tendsto_at_top_cinfi tendsto_at_top_cinfi

end Cinfi

section supr

variable [CompleteLattice α] [SupConvergenceClass α] {f : ι → α} {a : α}

theorem tendsto_at_top_supr (h_mono : Monotone f) : Tendsto f atTop (𝓝 (⨆ i, f i)) :=
  tendsto_at_top_csupr h_mono (OrderTop.bdd_above _)
#align tendsto_at_top_supr tendsto_at_top_supr

theorem tendsto_at_bot_supr (h_anti : Antitone f) : Tendsto f atBot (𝓝 (⨆ i, f i)) :=
  tendsto_at_bot_csupr h_anti (OrderTop.bdd_above _)
#align tendsto_at_bot_supr tendsto_at_bot_supr

end supr

section infi

variable [CompleteLattice α] [InfConvergenceClass α] {f : ι → α} {a : α}

theorem tendsto_at_bot_infi (h_mono : Monotone f) : Tendsto f atBot (𝓝 (⨅ i, f i)) :=
  tendsto_at_bot_cinfi h_mono (OrderBot.bdd_below _)
#align tendsto_at_bot_infi tendsto_at_bot_infi

theorem tendsto_at_top_infi (h_anti : Antitone f) : Tendsto f atTop (𝓝 (⨅ i, f i)) :=
  tendsto_at_top_cinfi h_anti (OrderBot.bdd_below _)
#align tendsto_at_top_infi tendsto_at_top_infi

end infi

end

instance [Preorder α] [Preorder β] [TopologicalSpace α] [TopologicalSpace β] [SupConvergenceClass α]
    [SupConvergenceClass β] : SupConvergenceClass (α × β) := by
  constructor
  rintro ⟨a, b⟩ s h
  rw [is_lub_prod, ← range_restrict, ← range_restrict] at h
  have A : tendsto (fun x : s => (x : α × β).1) at_top (𝓝 a) :=
    tendsto_at_top_is_lub (monotone_fst.restrict s) h.1
  have B : tendsto (fun x : s => (x : α × β).2) at_top (𝓝 b) :=
    tendsto_at_top_is_lub (monotone_snd.restrict s) h.2
  convert A.prod_mk_nhds B
  ext1 ⟨⟨x, y⟩, h⟩
  rfl

instance [Preorder α] [Preorder β] [TopologicalSpace α] [TopologicalSpace β] [InfConvergenceClass α]
    [InfConvergenceClass β] : InfConvergenceClass (α × β) :=
  show InfConvergenceClass (αᵒᵈ × βᵒᵈ)ᵒᵈ from OrderDual.Inf_convergence_class

instance {ι : Type _} {α : ι → Type _} [∀ i, Preorder (α i)] [∀ i, TopologicalSpace (α i)]
    [∀ i, SupConvergenceClass (α i)] : SupConvergenceClass (∀ i, α i) := by
  refine' ⟨fun f s h => _⟩
  simp only [is_lub_pi, ← range_restrict] at h
  exact tendsto_pi_nhds.2 fun i => tendsto_at_top_is_lub ((monotone_eval _).restrict _) (h i)

instance {ι : Type _} {α : ι → Type _} [∀ i, Preorder (α i)] [∀ i, TopologicalSpace (α i)]
    [∀ i, InfConvergenceClass (α i)] : InfConvergenceClass (∀ i, α i) :=
  show InfConvergenceClass (∀ i, (α i)ᵒᵈ)ᵒᵈ from OrderDual.Inf_convergence_class

instance Pi.Sup_convergence_class' {ι : Type _} [Preorder α] [TopologicalSpace α]
    [SupConvergenceClass α] : SupConvergenceClass (ι → α) :=
  Pi.Sup_convergence_class
#align pi.Sup_convergence_class' Pi.Sup_convergence_class'

instance Pi.Inf_convergence_class' {ι : Type _} [Preorder α] [TopologicalSpace α]
    [InfConvergenceClass α] : InfConvergenceClass (ι → α) :=
  Pi.Inf_convergence_class
#align pi.Inf_convergence_class' Pi.Inf_convergence_class'

theorem tendsto_of_monotone {ι α : Type _} [Preorder ι] [TopologicalSpace α]
    [ConditionallyCompleteLinearOrder α] [OrderTopology α] {f : ι → α} (h_mono : Monotone f) :
    Tendsto f atTop atTop ∨ ∃ l, Tendsto f atTop (𝓝 l) :=
  if H : BddAbove (range f) then Or.inr ⟨_, tendsto_at_top_csupr h_mono H⟩
  else Or.inl <| tendsto_at_top_at_top_of_monotone' h_mono H
#align tendsto_of_monotone tendsto_of_monotone

theorem tendsto_iff_tendsto_subseq_of_monotone {ι₁ ι₂ α : Type _} [SemilatticeSup ι₁] [Preorder ι₂]
    [Nonempty ι₁] [TopologicalSpace α] [ConditionallyCompleteLinearOrder α] [OrderTopology α]
    [NoMaxOrder α] {f : ι₂ → α} {φ : ι₁ → ι₂} {l : α} (hf : Monotone f)
    (hg : Tendsto φ atTop atTop) : Tendsto f atTop (𝓝 l) ↔ Tendsto (f ∘ φ) atTop (𝓝 l) := by
  constructor <;> intro h
  · exact h.comp hg
  · rcases tendsto_of_monotone hf with (h' | ⟨l', hl'⟩)
    · exact (not_tendsto_at_top_of_tendsto_nhds h (h'.comp hg)).elim
    · rwa [tendsto_nhds_unique h (hl'.comp hg)]
#align tendsto_iff_tendsto_subseq_of_monotone tendsto_iff_tendsto_subseq_of_monotone

/-! The next family of results, such as `is_lub_of_tendsto_at_top` and `supr_eq_of_tendsto`, are
converses to the standard fact that bounded monotone functions converge. They state, that if a
monotone function `f` tends to `a` along `filter.at_top`, then that value `a` is a least upper bound
for the range of `f`.

Related theorems above (`is_lub.is_lub_of_tendsto`, `is_glb.is_glb_of_tendsto` etc) cover the case
when `f x` tends to `a` as `x` tends to some point `b` in the domain. -/


theorem Monotone.ge_of_tendsto [TopologicalSpace α] [Preorder α] [OrderClosedTopology α]
    [SemilatticeSup β] {f : β → α} {a : α} (hf : Monotone f) (ha : Tendsto f atTop (𝓝 a)) (b : β) :
    f b ≤ a :=
  haveI : Nonempty β := Nonempty.intro b
  ge_of_tendsto ha ((eventually_ge_at_top b).mono fun _ hxy => hf hxy)
#align monotone.ge_of_tendsto Monotone.ge_of_tendsto

theorem Monotone.le_of_tendsto [TopologicalSpace α] [Preorder α] [OrderClosedTopology α]
    [SemilatticeInf β] {f : β → α} {a : α} (hf : Monotone f) (ha : Tendsto f atBot (𝓝 a)) (b : β) :
    a ≤ f b :=
  hf.dual.ge_of_tendsto ha b
#align monotone.le_of_tendsto Monotone.le_of_tendsto

theorem Antitone.le_of_tendsto [TopologicalSpace α] [Preorder α] [OrderClosedTopology α]
    [SemilatticeSup β] {f : β → α} {a : α} (hf : Antitone f) (ha : Tendsto f atTop (𝓝 a)) (b : β) :
    a ≤ f b :=
  hf.dual_right.ge_of_tendsto ha b
#align antitone.le_of_tendsto Antitone.le_of_tendsto

theorem Antitone.ge_of_tendsto [TopologicalSpace α] [Preorder α] [OrderClosedTopology α]
    [SemilatticeInf β] {f : β → α} {a : α} (hf : Antitone f) (ha : Tendsto f atBot (𝓝 a)) (b : β) :
    f b ≤ a :=
  hf.dual_right.le_of_tendsto ha b
#align antitone.ge_of_tendsto Antitone.ge_of_tendsto

theorem is_lub_of_tendsto_at_top [TopologicalSpace α] [Preorder α] [OrderClosedTopology α]
    [Nonempty β] [SemilatticeSup β] {f : β → α} {a : α} (hf : Monotone f)
    (ha : Tendsto f atTop (𝓝 a)) : IsLub (Set.range f) a := by
  constructor
  · rintro _ ⟨b, rfl⟩
    exact hf.ge_of_tendsto ha b
  · exact fun _ hb => le_of_tendsto' ha fun x => hb (Set.mem_range_self x)
#align is_lub_of_tendsto_at_top is_lub_of_tendsto_at_top

theorem is_glb_of_tendsto_at_bot [TopologicalSpace α] [Preorder α] [OrderClosedTopology α]
    [Nonempty β] [SemilatticeInf β] {f : β → α} {a : α} (hf : Monotone f)
    (ha : Tendsto f atBot (𝓝 a)) : IsGlb (Set.range f) a :=
  @is_lub_of_tendsto_at_top αᵒᵈ βᵒᵈ _ _ _ _ _ _ _ hf.dual ha
#align is_glb_of_tendsto_at_bot is_glb_of_tendsto_at_bot

theorem is_lub_of_tendsto_at_bot [TopologicalSpace α] [Preorder α] [OrderClosedTopology α]
    [Nonempty β] [SemilatticeInf β] {f : β → α} {a : α} (hf : Antitone f)
    (ha : Tendsto f atBot (𝓝 a)) : IsLub (Set.range f) a :=
  @is_lub_of_tendsto_at_top α βᵒᵈ _ _ _ _ _ _ _ hf.dual_left ha
#align is_lub_of_tendsto_at_bot is_lub_of_tendsto_at_bot

theorem is_glb_of_tendsto_at_top [TopologicalSpace α] [Preorder α] [OrderClosedTopology α]
    [Nonempty β] [SemilatticeSup β] {f : β → α} {a : α} (hf : Antitone f)
    (ha : Tendsto f atTop (𝓝 a)) : IsGlb (Set.range f) a :=
  @is_glb_of_tendsto_at_bot α βᵒᵈ _ _ _ _ _ _ _ hf.dual_left ha
#align is_glb_of_tendsto_at_top is_glb_of_tendsto_at_top

theorem supr_eq_of_tendsto {α β} [TopologicalSpace α] [CompleteLinearOrder α] [OrderTopology α]
    [Nonempty β] [SemilatticeSup β] {f : β → α} {a : α} (hf : Monotone f) :
    Tendsto f atTop (𝓝 a) → supr f = a :=
  tendsto_nhds_unique (tendsto_at_top_supr hf)
#align supr_eq_of_tendsto supr_eq_of_tendsto

theorem infi_eq_of_tendsto {α} [TopologicalSpace α] [CompleteLinearOrder α] [OrderTopology α]
    [Nonempty β] [SemilatticeSup β] {f : β → α} {a : α} (hf : Antitone f) :
    Tendsto f atTop (𝓝 a) → infi f = a :=
  tendsto_nhds_unique (tendsto_at_top_infi hf)
#align infi_eq_of_tendsto infi_eq_of_tendsto

theorem supr_eq_supr_subseq_of_monotone {ι₁ ι₂ α : Type _} [Preorder ι₂] [CompleteLattice α]
    {l : Filter ι₁} [l.ne_bot] {f : ι₂ → α} {φ : ι₁ → ι₂} (hf : Monotone f)
    (hφ : Tendsto φ l atTop) : (⨆ i, f i) = ⨆ i, f (φ i) :=
  le_antisymm
    (supr_mono' fun i =>
      Exists.imp (fun j (hj : i ≤ φ j) => hf hj) (hφ.Eventually <| eventually_ge_at_top i).exists)
    (supr_mono' fun i => ⟨φ i, le_rfl⟩)
#align supr_eq_supr_subseq_of_monotone supr_eq_supr_subseq_of_monotone

theorem infi_eq_infi_subseq_of_monotone {ι₁ ι₂ α : Type _} [Preorder ι₂] [CompleteLattice α]
    {l : Filter ι₁} [l.ne_bot] {f : ι₂ → α} {φ : ι₁ → ι₂} (hf : Monotone f)
    (hφ : Tendsto φ l atBot) : (⨅ i, f i) = ⨅ i, f (φ i) :=
  supr_eq_supr_subseq_of_monotone hf.dual hφ
#align infi_eq_infi_subseq_of_monotone infi_eq_infi_subseq_of_monotone

