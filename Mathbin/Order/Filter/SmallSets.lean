/-
Copyright (c) 2022 Patrick Massot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot, Floris van Doorn, Yury Kudryashov

! This file was ported from Lean 3 source module order.filter.small_sets
! leanprover-community/mathlib commit 0a0ec35061ed9960bf0e7ffb0335f44447b58977
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Filter.Lift
import Mathbin.Order.Filter.AtTopBot

/-!
# The filter of small sets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the filter of small sets w.r.t. a filter `f`, which is the largest filter
containing all powersets of members of `f`.

`g` converges to `f.small_sets` if for all `s ∈ f`, eventually we have `g x ⊆ s`.

An example usage is that if `f : ι → E → ℝ` is a family of nonnegative functions with integral 1,
then saying that `λ i, support (f i)` tendsto `(𝓝 0).small_sets` is a way of saying that
`f` tends to the Dirac delta distribution.
-/


open Filter

open Filter Set

variable {α β : Type _} {ι : Sort _}

namespace Filter

variable {l l' la : Filter α} {lb : Filter β}

#print Filter.smallSets /-
/-- The filter `l.small_sets` is the largest filter containing all powersets of members of `l`. -/
def smallSets (l : Filter α) : Filter (Set α) :=
  l.lift' powerset
#align filter.small_sets Filter.smallSets
-/

#print Filter.smallSets_eq_generate /-
theorem smallSets_eq_generate {f : Filter α} : f.smallSets = generate (powerset '' f.sets) :=
  by
  simp_rw [generate_eq_binfi, small_sets, infᵢ_image]
  rfl
#align filter.small_sets_eq_generate Filter.smallSets_eq_generate
-/

/- warning: filter.has_basis.small_sets -> Filter.HasBasis.smallSets is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {ι : Sort.{u2}} {l : Filter.{u1} α} {p : ι -> Prop} {s : ι -> (Set.{u1} α)}, (Filter.HasBasis.{u1, u2} α ι l p s) -> (Filter.HasBasis.{u1, u2} (Set.{u1} α) ι (Filter.smallSets.{u1} α l) p (fun (i : ι) => Set.powerset.{u1} α (s i)))
but is expected to have type
  forall {α : Type.{u2}} {ι : Sort.{u1}} {l : Filter.{u2} α} {p : ι -> Prop} {s : ι -> (Set.{u2} α)}, (Filter.HasBasis.{u2, u1} α ι l p s) -> (Filter.HasBasis.{u2, u1} (Set.{u2} α) ι (Filter.smallSets.{u2} α l) p (fun (i : ι) => Set.powerset.{u2} α (s i)))
Case conversion may be inaccurate. Consider using '#align filter.has_basis.small_sets Filter.HasBasis.smallSetsₓ'. -/
theorem HasBasis.smallSets {p : ι → Prop} {s : ι → Set α} (h : HasBasis l p s) :
    HasBasis l.smallSets p fun i => 𝒫 s i :=
  h.lift' monotone_powerset
#align filter.has_basis.small_sets Filter.HasBasis.smallSets

#print Filter.hasBasis_smallSets /-
theorem hasBasis_smallSets (l : Filter α) :
    HasBasis l.smallSets (fun t : Set α => t ∈ l) powerset :=
  l.basis_sets.smallSets
#align filter.has_basis_small_sets Filter.hasBasis_smallSets
-/

#print Filter.tendsto_smallSets_iff /-
/-- `g` converges to `f.small_sets` if for all `s ∈ f`, eventually we have `g x ⊆ s`. -/
theorem tendsto_smallSets_iff {f : α → Set β} :
    Tendsto f la lb.smallSets ↔ ∀ t ∈ lb, ∀ᶠ x in la, f x ⊆ t :=
  (hasBasis_smallSets lb).tendsto_right_iff
#align filter.tendsto_small_sets_iff Filter.tendsto_smallSets_iff
-/

/- warning: filter.eventually_small_sets -> Filter.eventually_smallSets is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {l : Filter.{u1} α} {p : (Set.{u1} α) -> Prop}, Iff (Filter.Eventually.{u1} (Set.{u1} α) (fun (s : Set.{u1} α) => p s) (Filter.smallSets.{u1} α l)) (Exists.{succ u1} (Set.{u1} α) (fun (s : Set.{u1} α) => Exists.{0} (Membership.Mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (Filter.hasMem.{u1} α) s l) (fun (H : Membership.Mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (Filter.hasMem.{u1} α) s l) => forall (t : Set.{u1} α), (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) t s) -> (p t))))
but is expected to have type
  forall {α : Type.{u1}} {l : Filter.{u1} α} {p : (Set.{u1} α) -> Prop}, Iff (Filter.Eventually.{u1} (Set.{u1} α) (fun (s : Set.{u1} α) => p s) (Filter.smallSets.{u1} α l)) (Exists.{succ u1} (Set.{u1} α) (fun (s : Set.{u1} α) => And (Membership.mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (instMembershipSetFilter.{u1} α) s l) (forall (t : Set.{u1} α), (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) t s) -> (p t))))
Case conversion may be inaccurate. Consider using '#align filter.eventually_small_sets Filter.eventually_smallSetsₓ'. -/
/- ./././Mathport/Syntax/Translate/Basic.lean:628:2: warning: expanding binder collection (t «expr ⊆ » s) -/
theorem eventually_smallSets {p : Set α → Prop} :
    (∀ᶠ s in l.smallSets, p s) ↔ ∃ s ∈ l, ∀ (t) (_ : t ⊆ s), p t :=
  eventually_lift'_iff monotone_powerset
#align filter.eventually_small_sets Filter.eventually_smallSets

/- warning: filter.eventually_small_sets' -> Filter.eventually_small_sets' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {l : Filter.{u1} α} {p : (Set.{u1} α) -> Prop}, (forall {{s : Set.{u1} α}} {{t : Set.{u1} α}}, (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s t) -> (p t) -> (p s)) -> (Iff (Filter.Eventually.{u1} (Set.{u1} α) (fun (s : Set.{u1} α) => p s) (Filter.smallSets.{u1} α l)) (Exists.{succ u1} (Set.{u1} α) (fun (s : Set.{u1} α) => Exists.{0} (Membership.Mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (Filter.hasMem.{u1} α) s l) (fun (H : Membership.Mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (Filter.hasMem.{u1} α) s l) => p s))))
but is expected to have type
  forall {α : Type.{u1}} {l : Filter.{u1} α} {p : (Set.{u1} α) -> Prop}, (forall {{s : Set.{u1} α}} {{t : Set.{u1} α}}, (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) s t) -> (p t) -> (p s)) -> (Iff (Filter.Eventually.{u1} (Set.{u1} α) (fun (s : Set.{u1} α) => p s) (Filter.smallSets.{u1} α l)) (Exists.{succ u1} (Set.{u1} α) (fun (s : Set.{u1} α) => And (Membership.mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (instMembershipSetFilter.{u1} α) s l) (p s))))
Case conversion may be inaccurate. Consider using '#align filter.eventually_small_sets' Filter.eventually_small_sets'ₓ'. -/
theorem eventually_small_sets' {p : Set α → Prop} (hp : ∀ ⦃s t⦄, s ⊆ t → p t → p s) :
    (∀ᶠ s in l.smallSets, p s) ↔ ∃ s ∈ l, p s :=
  eventually_smallSets.trans <|
    exists₂_congr fun s hsf => ⟨fun H => H s Subset.rfl, fun hs t ht => hp ht hs⟩
#align filter.eventually_small_sets' Filter.eventually_small_sets'

/- warning: filter.frequently_small_sets -> Filter.frequently_smallSets is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {l : Filter.{u1} α} {p : (Set.{u1} α) -> Prop}, Iff (Filter.Frequently.{u1} (Set.{u1} α) (fun (s : Set.{u1} α) => p s) (Filter.smallSets.{u1} α l)) (forall (t : Set.{u1} α), (Membership.Mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (Filter.hasMem.{u1} α) t l) -> (Exists.{succ u1} (Set.{u1} α) (fun (s : Set.{u1} α) => Exists.{0} (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s t) (fun (H : HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s t) => p s))))
but is expected to have type
  forall {α : Type.{u1}} {l : Filter.{u1} α} {p : (Set.{u1} α) -> Prop}, Iff (Filter.Frequently.{u1} (Set.{u1} α) (fun (s : Set.{u1} α) => p s) (Filter.smallSets.{u1} α l)) (forall (t : Set.{u1} α), (Membership.mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (instMembershipSetFilter.{u1} α) t l) -> (Exists.{succ u1} (Set.{u1} α) (fun (s : Set.{u1} α) => And (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) s t) (p s))))
Case conversion may be inaccurate. Consider using '#align filter.frequently_small_sets Filter.frequently_smallSetsₓ'. -/
/- ./././Mathport/Syntax/Translate/Basic.lean:628:2: warning: expanding binder collection (s «expr ⊆ » t) -/
theorem frequently_smallSets {p : Set α → Prop} :
    (∃ᶠ s in l.smallSets, p s) ↔ ∀ t ∈ l, ∃ (s : _)(_ : s ⊆ t), p s :=
  l.hasBasis_smallSets.frequently_iff
#align filter.frequently_small_sets Filter.frequently_smallSets

#print Filter.frequently_smallSets_mem /-
theorem frequently_smallSets_mem (l : Filter α) : ∃ᶠ s in l.smallSets, s ∈ l :=
  frequently_smallSets.2 fun t ht => ⟨t, Subset.rfl, ht⟩
#align filter.frequently_small_sets_mem Filter.frequently_smallSets_mem
-/

#print Filter.HasAntitoneBasis.tendsto_smallSets /-
theorem HasAntitoneBasis.tendsto_smallSets {ι} [Preorder ι] {s : ι → Set α}
    (hl : l.HasAntitoneBasis s) : Tendsto s atTop l.smallSets :=
  tendsto_smallSets_iff.2 fun t ht => hl.eventually_subset ht
#align filter.has_antitone_basis.tendsto_small_sets Filter.HasAntitoneBasis.tendsto_smallSets
-/

/- warning: filter.monotone_small_sets -> Filter.monotone_smallSets is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}}, Monotone.{u1, u1} (Filter.{u1} α) (Filter.{u1} (Set.{u1} α)) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.partialOrder.{u1} α)) (PartialOrder.toPreorder.{u1} (Filter.{u1} (Set.{u1} α)) (Filter.partialOrder.{u1} (Set.{u1} α))) (Filter.smallSets.{u1} α)
but is expected to have type
  forall {α : Type.{u1}}, Monotone.{u1, u1} (Filter.{u1} α) (Filter.{u1} (Set.{u1} α)) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.instPartialOrderFilter.{u1} α)) (PartialOrder.toPreorder.{u1} (Filter.{u1} (Set.{u1} α)) (Filter.instPartialOrderFilter.{u1} (Set.{u1} α))) (Filter.smallSets.{u1} α)
Case conversion may be inaccurate. Consider using '#align filter.monotone_small_sets Filter.monotone_smallSetsₓ'. -/
@[mono]
theorem monotone_smallSets : Monotone (@smallSets α) :=
  monotone_lift' monotone_id monotone_const
#align filter.monotone_small_sets Filter.monotone_smallSets

/- warning: filter.small_sets_bot -> Filter.smallSets_bot is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}}, Eq.{succ u1} (Filter.{u1} (Set.{u1} α)) (Filter.smallSets.{u1} α (Bot.bot.{u1} (Filter.{u1} α) (CompleteLattice.toHasBot.{u1} (Filter.{u1} α) (Filter.completeLattice.{u1} α)))) (Pure.pure.{u1, u1} Filter.{u1} Filter.hasPure.{u1} (Set.{u1} α) (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.hasEmptyc.{u1} α)))
but is expected to have type
  forall {α : Type.{u1}}, Eq.{succ u1} (Filter.{u1} (Set.{u1} α)) (Filter.smallSets.{u1} α (Bot.bot.{u1} (Filter.{u1} α) (CompleteLattice.toBot.{u1} (Filter.{u1} α) (Filter.instCompleteLatticeFilter.{u1} α)))) (Pure.pure.{u1, u1} Filter.{u1} Filter.instPureFilter.{u1} (Set.{u1} α) (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.instEmptyCollectionSet.{u1} α)))
Case conversion may be inaccurate. Consider using '#align filter.small_sets_bot Filter.smallSets_botₓ'. -/
@[simp]
theorem smallSets_bot : (⊥ : Filter α).smallSets = pure ∅ := by
  rw [small_sets, lift'_bot monotone_powerset, powerset_empty, principal_singleton]
#align filter.small_sets_bot Filter.smallSets_bot

/- warning: filter.small_sets_top -> Filter.smallSets_top is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}}, Eq.{succ u1} (Filter.{u1} (Set.{u1} α)) (Filter.smallSets.{u1} α (Top.top.{u1} (Filter.{u1} α) (Filter.hasTop.{u1} α))) (Top.top.{u1} (Filter.{u1} (Set.{u1} α)) (Filter.hasTop.{u1} (Set.{u1} α)))
but is expected to have type
  forall {α : Type.{u1}}, Eq.{succ u1} (Filter.{u1} (Set.{u1} α)) (Filter.smallSets.{u1} α (Top.top.{u1} (Filter.{u1} α) (Filter.instTopFilter.{u1} α))) (Top.top.{u1} (Filter.{u1} (Set.{u1} α)) (Filter.instTopFilter.{u1} (Set.{u1} α)))
Case conversion may be inaccurate. Consider using '#align filter.small_sets_top Filter.smallSets_topₓ'. -/
@[simp]
theorem smallSets_top : (⊤ : Filter α).smallSets = ⊤ := by
  rw [small_sets, lift'_top, powerset_univ, principal_univ]
#align filter.small_sets_top Filter.smallSets_top

#print Filter.smallSets_principal /-
@[simp]
theorem smallSets_principal (s : Set α) : (𝓟 s).smallSets = 𝓟 (𝒫 s) :=
  lift'_principal monotone_powerset
#align filter.small_sets_principal Filter.smallSets_principal
-/

#print Filter.smallSets_comap /-
theorem smallSets_comap (l : Filter β) (f : α → β) :
    (comap f l).smallSets = l.lift' (powerset ∘ preimage f) :=
  comap_lift'_eq2 monotone_powerset
#align filter.small_sets_comap Filter.smallSets_comap
-/

#print Filter.comap_smallSets /-
theorem comap_smallSets (l : Filter β) (f : α → Set β) :
    comap f l.smallSets = l.lift' (preimage f ∘ powerset) :=
  comap_lift'_eq
#align filter.comap_small_sets Filter.comap_smallSets
-/

/- warning: filter.small_sets_infi -> Filter.smallSets_infᵢ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {ι : Sort.{u2}} {f : ι -> (Filter.{u1} α)}, Eq.{succ u1} (Filter.{u1} (Set.{u1} α)) (Filter.smallSets.{u1} α (infᵢ.{u1, u2} (Filter.{u1} α) (ConditionallyCompleteLattice.toHasInf.{u1} (Filter.{u1} α) (CompleteLattice.toConditionallyCompleteLattice.{u1} (Filter.{u1} α) (Filter.completeLattice.{u1} α))) ι f)) (infᵢ.{u1, u2} (Filter.{u1} (Set.{u1} α)) (ConditionallyCompleteLattice.toHasInf.{u1} (Filter.{u1} (Set.{u1} α)) (CompleteLattice.toConditionallyCompleteLattice.{u1} (Filter.{u1} (Set.{u1} α)) (Filter.completeLattice.{u1} (Set.{u1} α)))) ι (fun (i : ι) => Filter.smallSets.{u1} α (f i)))
but is expected to have type
  forall {α : Type.{u2}} {ι : Sort.{u1}} {f : ι -> (Filter.{u2} α)}, Eq.{succ u2} (Filter.{u2} (Set.{u2} α)) (Filter.smallSets.{u2} α (infᵢ.{u2, u1} (Filter.{u2} α) (ConditionallyCompleteLattice.toInfSet.{u2} (Filter.{u2} α) (CompleteLattice.toConditionallyCompleteLattice.{u2} (Filter.{u2} α) (Filter.instCompleteLatticeFilter.{u2} α))) ι f)) (infᵢ.{u2, u1} (Filter.{u2} (Set.{u2} α)) (ConditionallyCompleteLattice.toInfSet.{u2} (Filter.{u2} (Set.{u2} α)) (CompleteLattice.toConditionallyCompleteLattice.{u2} (Filter.{u2} (Set.{u2} α)) (Filter.instCompleteLatticeFilter.{u2} (Set.{u2} α)))) ι (fun (i : ι) => Filter.smallSets.{u2} α (f i)))
Case conversion may be inaccurate. Consider using '#align filter.small_sets_infi Filter.smallSets_infᵢₓ'. -/
theorem smallSets_infᵢ {f : ι → Filter α} : (infᵢ f).smallSets = ⨅ i, (f i).smallSets :=
  lift'_infᵢ_of_map_univ powerset_inter powerset_univ
#align filter.small_sets_infi Filter.smallSets_infᵢ

/- warning: filter.small_sets_inf -> Filter.smallSets_inf is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (l₁ : Filter.{u1} α) (l₂ : Filter.{u1} α), Eq.{succ u1} (Filter.{u1} (Set.{u1} α)) (Filter.smallSets.{u1} α (HasInf.inf.{u1} (Filter.{u1} α) (Filter.hasInf.{u1} α) l₁ l₂)) (HasInf.inf.{u1} (Filter.{u1} (Set.{u1} α)) (Filter.hasInf.{u1} (Set.{u1} α)) (Filter.smallSets.{u1} α l₁) (Filter.smallSets.{u1} α l₂))
but is expected to have type
  forall {α : Type.{u1}} (l₁ : Filter.{u1} α) (l₂ : Filter.{u1} α), Eq.{succ u1} (Filter.{u1} (Set.{u1} α)) (Filter.smallSets.{u1} α (HasInf.inf.{u1} (Filter.{u1} α) (Filter.instHasInfFilter.{u1} α) l₁ l₂)) (HasInf.inf.{u1} (Filter.{u1} (Set.{u1} α)) (Filter.instHasInfFilter.{u1} (Set.{u1} α)) (Filter.smallSets.{u1} α l₁) (Filter.smallSets.{u1} α l₂))
Case conversion may be inaccurate. Consider using '#align filter.small_sets_inf Filter.smallSets_infₓ'. -/
theorem smallSets_inf (l₁ l₂ : Filter α) : (l₁ ⊓ l₂).smallSets = l₁.smallSets ⊓ l₂.smallSets :=
  lift'_inf _ _ powerset_inter
#align filter.small_sets_inf Filter.smallSets_inf

#print Filter.smallSets_neBot /-
instance smallSets_neBot (l : Filter α) : NeBot l.smallSets :=
  (lift'_neBot_iff monotone_powerset).2 fun _ _ => powerset_nonempty
#align filter.small_sets_ne_bot Filter.smallSets_neBot
-/

#print Filter.Tendsto.smallSets_mono /-
theorem Tendsto.smallSets_mono {s t : α → Set β} (ht : Tendsto t la lb.smallSets)
    (hst : ∀ᶠ x in la, s x ⊆ t x) : Tendsto s la lb.smallSets :=
  by
  rw [tendsto_small_sets_iff] at ht⊢
  exact fun u hu => (ht u hu).mp (hst.mono fun a hst ht => subset.trans hst ht)
#align filter.tendsto.small_sets_mono Filter.Tendsto.smallSets_mono
-/

#print Filter.Tendsto.of_smallSets /-
/-- Generalized **squeeze theorem** (also known as **sandwich theorem**). If `s : α → set β` is a
family of sets that tends to `filter.small_sets lb` along `la` and `f : α → β` is a function such
that `f x ∈ s x` eventually along `la`, then `f` tends to `lb` along `la`.

If `s x` is the closed interval `[g x, h x]` for some functions `g`, `h` that tend to the same limit
`𝓝 y`, then we obtain the standard squeeze theorem, see
`tendsto_of_tendsto_of_tendsto_of_le_of_le'`. -/
theorem Tendsto.of_smallSets {s : α → Set β} {f : α → β} (hs : Tendsto s la lb.smallSets)
    (hf : ∀ᶠ x in la, f x ∈ s x) : Tendsto f la lb := fun t ht =>
  hf.mp <| (tendsto_smallSets_iff.mp hs t ht).mono fun x h₁ h₂ => h₁ h₂
#align filter.tendsto.of_small_sets Filter.Tendsto.of_smallSets
-/

/- warning: filter.eventually_small_sets_eventually -> Filter.eventually_smallSets_eventually is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {l : Filter.{u1} α} {l' : Filter.{u1} α} {p : α -> Prop}, Iff (Filter.Eventually.{u1} (Set.{u1} α) (fun (s : Set.{u1} α) => Filter.Eventually.{u1} α (fun (x : α) => (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) -> (p x)) l') (Filter.smallSets.{u1} α l)) (Filter.Eventually.{u1} α (fun (x : α) => p x) (HasInf.inf.{u1} (Filter.{u1} α) (Filter.hasInf.{u1} α) l l'))
but is expected to have type
  forall {α : Type.{u1}} {l : Filter.{u1} α} {l' : Filter.{u1} α} {p : α -> Prop}, Iff (Filter.Eventually.{u1} (Set.{u1} α) (fun (s : Set.{u1} α) => Filter.Eventually.{u1} α (fun (x : α) => (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) -> (p x)) l') (Filter.smallSets.{u1} α l)) (Filter.Eventually.{u1} α (fun (x : α) => p x) (HasInf.inf.{u1} (Filter.{u1} α) (Filter.instHasInfFilter.{u1} α) l l'))
Case conversion may be inaccurate. Consider using '#align filter.eventually_small_sets_eventually Filter.eventually_smallSets_eventuallyₓ'. -/
@[simp]
theorem eventually_smallSets_eventually {p : α → Prop} :
    (∀ᶠ s in l.smallSets, ∀ᶠ x in l', x ∈ s → p x) ↔ ∀ᶠ x in l ⊓ l', p x :=
  calc
    _ ↔ ∃ s ∈ l, ∀ᶠ x in l', x ∈ s → p x :=
      eventually_small_sets' fun s t hst ht => ht.mono fun x hx hs => hx (hst hs)
    _ ↔ ∃ s ∈ l, ∃ t ∈ l', ∀ x, x ∈ t → x ∈ s → p x := by simp only [eventually_iff_exists_mem]
    _ ↔ ∀ᶠ x in l ⊓ l', p x := by simp only [eventually_inf, and_comm', mem_inter_iff, ← and_imp]
    
#align filter.eventually_small_sets_eventually Filter.eventually_smallSets_eventually

#print Filter.eventually_smallSets_forall /-
@[simp]
theorem eventually_smallSets_forall {p : α → Prop} :
    (∀ᶠ s in l.smallSets, ∀ x ∈ s, p x) ↔ ∀ᶠ x in l, p x := by
  simpa only [inf_top_eq, eventually_top] using @eventually_small_sets_eventually α l ⊤ p
#align filter.eventually_small_sets_forall Filter.eventually_smallSets_forall
-/

alias eventually_small_sets_forall ↔ eventually.of_small_sets eventually.small_sets
#align filter.eventually.of_small_sets Filter.Eventually.of_smallSets
#align filter.eventually.small_sets Filter.Eventually.smallSets

#print Filter.eventually_smallSets_subset /-
@[simp]
theorem eventually_smallSets_subset {s : Set α} : (∀ᶠ t in l.smallSets, t ⊆ s) ↔ s ∈ l :=
  eventually_smallSets_forall
#align filter.eventually_small_sets_subset Filter.eventually_smallSets_subset
-/

end Filter

