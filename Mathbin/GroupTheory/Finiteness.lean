/-
Copyright (c) 2021 Riccardo Brasca. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Riccardo Brasca
-/
import Mathbin.Data.Set.Finite
import Mathbin.Data.Finset.Default
import Mathbin.GroupTheory.QuotientGroup
import Mathbin.GroupTheory.Submonoid.Operations
import Mathbin.GroupTheory.Subgroup.Basic
import Mathbin.SetTheory.Cardinal.Finite

/-!
# Finitely generated monoids and groups

We define finitely generated monoids and groups. See also `submodule.fg` and `module.finite` for
finitely-generated modules.

## Main definition

* `submonoid.fg S`, `add_submonoid.fg S` : A submonoid `S` is finitely generated.
* `monoid.fg M`, `add_monoid.fg M` : A typeclass indicating a type `M` is finitely generated as a
monoid.
* `subgroup.fg S`, `add_subgroup.fg S` : A subgroup `S` is finitely generated.
* `group.fg M`, `add_group.fg M` : A typeclass indicating a type `M` is finitely generated as a
group.

-/


/-! ### Monoids and submonoids -/


open Pointwise

variable {M N : Type _} [Monoidₓ M] [AddMonoidₓ N]

section Submonoid

/-- A submonoid of `M` is finitely generated if it is the closure of a finite subset of `M`. -/
@[to_additive]
def Submonoid.Fg (P : Submonoid M) : Prop :=
  ∃ S : Finsetₓ M, Submonoid.closure ↑S = P

-- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:51:50: missing argument
-- ./././Mathport/Syntax/Translate/Command.lean:667:43: in add_decl_doc #[[ident add_submonoid.fg]]: ./././Mathport/Syntax/Translate/Tactic/Basic.lean:54:35: expecting parse arg
/-- An equivalent expression of `submonoid.fg` in terms of `set.finite` instead of `finset`. -/
@[to_additive "An equivalent expression of `add_submonoid.fg` in terms of `set.finite` instead of\n`finset`."]
theorem Submonoid.fg_iff (P : Submonoid M) : Submonoid.Fg P ↔ ∃ S : Set M, Submonoid.closure S = P ∧ S.Finite :=
  ⟨fun ⟨S, hS⟩ => ⟨S, hS, Finsetₓ.finite_to_set S⟩, fun ⟨S, hS, hf⟩ => ⟨Set.Finite.toFinset hf, by simp [hS]⟩⟩

theorem Submonoid.fg_iff_add_fg (P : Submonoid M) : P.Fg ↔ P.toAddSubmonoid.Fg :=
  ⟨fun h =>
    let ⟨S, hS, hf⟩ := (Submonoid.fg_iff _).1 h
    (AddSubmonoid.fg_iff _).mpr ⟨Additive.toMul ⁻¹' S, by simp [← Submonoid.to_add_submonoid_closure, hS], hf⟩,
    fun h =>
    let ⟨T, hT, hf⟩ := (AddSubmonoid.fg_iff _).1 h
    (Submonoid.fg_iff _).mpr ⟨Multiplicative.ofAdd ⁻¹' T, by simp [← AddSubmonoid.to_submonoid'_closure, hT], hf⟩⟩

theorem AddSubmonoid.fg_iff_mul_fg (P : AddSubmonoid N) : P.Fg ↔ P.toSubmonoid.Fg := by
  convert (Submonoid.fg_iff_add_fg P.to_submonoid).symm
  exact SetLike.ext' rfl

end Submonoid

section Monoidₓ

variable (M N)

/-- A monoid is finitely generated if it is finitely generated as a submonoid of itself. -/
class Monoidₓ.Fg : Prop where
  out : (⊤ : Submonoid M).Fg

/-- An additive monoid is finitely generated if it is finitely generated as an additive submonoid of
itself. -/
class AddMonoidₓ.Fg : Prop where
  out : (⊤ : AddSubmonoid N).Fg

attribute [to_additive] Monoidₓ.Fg

variable {M N}

theorem Monoidₓ.fg_def : Monoidₓ.Fg M ↔ (⊤ : Submonoid M).Fg :=
  ⟨fun h => h.1, fun h => ⟨h⟩⟩

theorem AddMonoidₓ.fg_def : AddMonoidₓ.Fg N ↔ (⊤ : AddSubmonoid N).Fg :=
  ⟨fun h => h.1, fun h => ⟨h⟩⟩

/-- An equivalent expression of `monoid.fg` in terms of `set.finite` instead of `finset`. -/
@[to_additive "An equivalent expression of `add_monoid.fg` in terms of `set.finite` instead of\n`finset`."]
theorem Monoidₓ.fg_iff : Monoidₓ.Fg M ↔ ∃ S : Set M, Submonoid.closure S = (⊤ : Submonoid M) ∧ S.Finite :=
  ⟨fun h => (Submonoid.fg_iff ⊤).1 h.out, fun h => ⟨(Submonoid.fg_iff ⊤).2 h⟩⟩

theorem Monoidₓ.fg_iff_add_fg : Monoidₓ.Fg M ↔ AddMonoidₓ.Fg (Additive M) :=
  ⟨fun h => ⟨(Submonoid.fg_iff_add_fg ⊤).1 h.out⟩, fun h => ⟨(Submonoid.fg_iff_add_fg ⊤).2 h.out⟩⟩

theorem AddMonoidₓ.fg_iff_mul_fg : AddMonoidₓ.Fg N ↔ Monoidₓ.Fg (Multiplicative N) :=
  ⟨fun h => ⟨(AddSubmonoid.fg_iff_mul_fg ⊤).1 h.out⟩, fun h => ⟨(AddSubmonoid.fg_iff_mul_fg ⊤).2 h.out⟩⟩

instance AddMonoidₓ.fg_of_monoid_fg [Monoidₓ.Fg M] : AddMonoidₓ.Fg (Additive M) :=
  Monoidₓ.fg_iff_add_fg.1 ‹_›

instance Monoidₓ.fg_of_add_monoid_fg [AddMonoidₓ.Fg N] : Monoidₓ.Fg (Multiplicative N) :=
  AddMonoidₓ.fg_iff_mul_fg.1 ‹_›

@[to_additive]
instance (priority := 100) Monoidₓ.fg_of_finite [Finite M] : Monoidₓ.Fg M := by
  cases nonempty_fintype M
  exact ⟨⟨Finsetₓ.univ, by rw [Finsetₓ.coe_univ] <;> exact Submonoid.closure_univ⟩⟩

end Monoidₓ

@[to_additive]
theorem Submonoid.Fg.map {M' : Type _} [Monoidₓ M'] {P : Submonoid M} (h : P.Fg) (e : M →* M') : (P.map e).Fg := by
  classical
  obtain ⟨s, rfl⟩ := h
  exact ⟨s.image e, by rw [Finsetₓ.coe_image, MonoidHom.map_mclosure]⟩

@[to_additive]
theorem Submonoid.Fg.map_injective {M' : Type _} [Monoidₓ M'] {P : Submonoid M} (e : M →* M')
    (he : Function.Injective e) (h : (P.map e).Fg) : P.Fg := by
  obtain ⟨s, hs⟩ := h
  use s.preimage e (he.inj_on _)
  apply Submonoid.map_injective_of_injective he
  rw [← hs, e.map_mclosure, Finsetₓ.coe_preimage]
  congr
  rw [Set.image_preimage_eq_iff, ← e.coe_mrange, ← Submonoid.closure_le, hs, e.mrange_eq_map]
  exact Submonoid.monotone_map le_top

@[simp, to_additive]
theorem Monoidₓ.fg_iff_submonoid_fg (N : Submonoid M) : Monoidₓ.Fg N ↔ N.Fg := by
  conv_rhs => rw [← N.range_subtype, MonoidHom.mrange_eq_map]
  exact ⟨fun h => h.out.map N.subtype, fun h => ⟨h.map_injective N.subtype Subtype.coe_injective⟩⟩

@[to_additive]
theorem Monoidₓ.fg_of_surjective {M' : Type _} [Monoidₓ M'] [Monoidₓ.Fg M] (f : M →* M') (hf : Function.Surjective f) :
    Monoidₓ.Fg M' := by
  classical
  obtain ⟨s, hs⟩ := monoid.fg_def.mp ‹_›
  use s.image f
  rwa [Finsetₓ.coe_image, ← MonoidHom.map_mclosure, hs, ← MonoidHom.mrange_eq_map, MonoidHom.mrange_top_iff_surjective]

@[to_additive]
instance Monoidₓ.fg_range {M' : Type _} [Monoidₓ M'] [Monoidₓ.Fg M] (f : M →* M') : Monoidₓ.Fg f.mrange :=
  Monoidₓ.fg_of_surjective f.mrangeRestrict f.mrange_restrict_surjective

@[to_additive AddSubmonoid.multiples_fg]
theorem Submonoid.powers_fg (r : M) : (Submonoid.powers r).Fg :=
  ⟨{r}, (Finsetₓ.coe_singleton r).symm ▸ (Submonoid.powers_eq_closure r).symm⟩

@[to_additive AddMonoidₓ.multiples_fg]
instance Monoidₓ.powers_fg (r : M) : Monoidₓ.Fg (Submonoid.powers r) :=
  (Monoidₓ.fg_iff_submonoid_fg _).mpr (Submonoid.powers_fg r)

@[to_additive]
instance Monoidₓ.closure_finset_fg (s : Finsetₓ M) : Monoidₓ.Fg (Submonoid.closure (s : Set M)) := by
  refine' ⟨⟨s.preimage coe (subtype.coe_injective.inj_on _), _⟩⟩
  rw [Finsetₓ.coe_preimage, Submonoid.closure_closure_coe_preimage]

@[to_additive]
instance Monoidₓ.closure_finite_fg (s : Set M) [Finite s] : Monoidₓ.Fg (Submonoid.closure s) :=
  haveI := Fintypeₓ.ofFinite s
  s.coe_to_finset ▸ Monoidₓ.closure_finset_fg s.to_finset

/-! ### Groups and subgroups -/


variable {G H : Type _} [Groupₓ G] [AddGroupₓ H]

section Subgroup

/-- A subgroup of `G` is finitely generated if it is the closure of a finite subset of `G`. -/
@[to_additive]
def Subgroup.Fg (P : Subgroup G) : Prop :=
  ∃ S : Finsetₓ G, Subgroup.closure ↑S = P

-- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:51:50: missing argument
-- ./././Mathport/Syntax/Translate/Command.lean:667:43: in add_decl_doc #[[ident add_subgroup.fg]]: ./././Mathport/Syntax/Translate/Tactic/Basic.lean:54:35: expecting parse arg
/-- An equivalent expression of `subgroup.fg` in terms of `set.finite` instead of `finset`. -/
@[to_additive "An equivalent expression of `add_subgroup.fg` in terms of `set.finite` instead of\n`finset`."]
theorem Subgroup.fg_iff (P : Subgroup G) : Subgroup.Fg P ↔ ∃ S : Set G, Subgroup.closure S = P ∧ S.Finite :=
  ⟨fun ⟨S, hS⟩ => ⟨S, hS, Finsetₓ.finite_to_set S⟩, fun ⟨S, hS, hf⟩ => ⟨Set.Finite.toFinset hf, by simp [hS]⟩⟩

/-- A subgroup is finitely generated if and only if it is finitely generated as a submonoid. -/
@[to_additive AddSubgroup.FgIffAddSubmonoid.fg
      "An additive subgroup is finitely generated if\nand only if it is finitely generated as an additive submonoid."]
theorem Subgroup.fg_iff_submonoid_fg (P : Subgroup G) : P.Fg ↔ P.toSubmonoid.Fg := by
  constructor
  · rintro ⟨S, rfl⟩
    rw [Submonoid.fg_iff]
    refine' ⟨S ∪ S⁻¹, _, S.finite_to_set.union S.finite_to_set.inv⟩
    exact (Subgroup.closure_to_submonoid _).symm
    
  · rintro ⟨S, hS⟩
    refine' ⟨S, le_antisymmₓ _ _⟩
    · rw [Subgroup.closure_le, ← Subgroup.coe_to_submonoid, ← hS]
      exact Submonoid.subset_closure
      
    · rw [← Subgroup.to_submonoid_le, ← hS, Submonoid.closure_le]
      exact Subgroup.subset_closure
      
    

theorem Subgroup.fg_iff_add_fg (P : Subgroup G) : P.Fg ↔ P.toAddSubgroup.Fg := by
  rw [Subgroup.fg_iff_submonoid_fg, AddSubgroup.FgIffAddSubmonoid.fg]
  exact (Subgroup.toSubmonoid P).fg_iff_add_fg

theorem AddSubgroup.fg_iff_mul_fg (P : AddSubgroup H) : P.Fg ↔ P.toSubgroup.Fg := by
  rw [AddSubgroup.FgIffAddSubmonoid.fg, Subgroup.fg_iff_submonoid_fg]
  exact AddSubmonoid.fg_iff_mul_fg (AddSubgroup.toAddSubmonoid P)

end Subgroup

section Groupₓ

variable (G H)

/-- A group is finitely generated if it is finitely generated as a submonoid of itself. -/
class Groupₓ.Fg : Prop where
  out : (⊤ : Subgroup G).Fg

/-- An additive group is finitely generated if it is finitely generated as an additive submonoid of
itself. -/
class AddGroupₓ.Fg : Prop where
  out : (⊤ : AddSubgroup H).Fg

attribute [to_additive] Groupₓ.Fg

variable {G H}

theorem Groupₓ.fg_def : Groupₓ.Fg G ↔ (⊤ : Subgroup G).Fg :=
  ⟨fun h => h.1, fun h => ⟨h⟩⟩

theorem AddGroupₓ.fg_def : AddGroupₓ.Fg H ↔ (⊤ : AddSubgroup H).Fg :=
  ⟨fun h => h.1, fun h => ⟨h⟩⟩

/-- An equivalent expression of `group.fg` in terms of `set.finite` instead of `finset`. -/
@[to_additive "An equivalent expression of `add_group.fg` in terms of `set.finite` instead of\n`finset`."]
theorem Groupₓ.fg_iff : Groupₓ.Fg G ↔ ∃ S : Set G, Subgroup.closure S = (⊤ : Subgroup G) ∧ S.Finite :=
  ⟨fun h => (Subgroup.fg_iff ⊤).1 h.out, fun h => ⟨(Subgroup.fg_iff ⊤).2 h⟩⟩

@[to_additive]
theorem Groupₓ.fg_iff' : Groupₓ.Fg G ↔ ∃ (n : _)(S : Finsetₓ G), S.card = n ∧ Subgroup.closure (S : Set G) = ⊤ :=
  Groupₓ.fg_def.trans ⟨fun ⟨S, hS⟩ => ⟨S.card, S, rfl, hS⟩, fun ⟨n, S, hn, hS⟩ => ⟨S, hS⟩⟩

/-- A group is finitely generated if and only if it is finitely generated as a monoid. -/
@[to_additive AddGroupₓ.FgIffAddMonoid.fg
      "An additive group is finitely generated if and only\nif it is finitely generated as an additive monoid."]
theorem Groupₓ.FgIffMonoid.fg : Groupₓ.Fg G ↔ Monoidₓ.Fg G :=
  ⟨fun h => Monoidₓ.fg_def.2 <| (Subgroup.fg_iff_submonoid_fg ⊤).1 (Groupₓ.fg_def.1 h), fun h =>
    Groupₓ.fg_def.2 <| (Subgroup.fg_iff_submonoid_fg ⊤).2 (Monoidₓ.fg_def.1 h)⟩

theorem GroupFg.iff_add_fg : Groupₓ.Fg G ↔ AddGroupₓ.Fg (Additive G) :=
  ⟨fun h => ⟨(Subgroup.fg_iff_add_fg ⊤).1 h.out⟩, fun h => ⟨(Subgroup.fg_iff_add_fg ⊤).2 h.out⟩⟩

theorem AddGroupₓ.fg_iff_mul_fg : AddGroupₓ.Fg H ↔ Groupₓ.Fg (Multiplicative H) :=
  ⟨fun h => ⟨(AddSubgroup.fg_iff_mul_fg ⊤).1 h.out⟩, fun h => ⟨(AddSubgroup.fg_iff_mul_fg ⊤).2 h.out⟩⟩

instance AddGroupₓ.fg_of_group_fg [Groupₓ.Fg G] : AddGroupₓ.Fg (Additive G) :=
  GroupFg.iff_add_fg.1 ‹_›

instance Groupₓ.fg_of_mul_group_fg [AddGroupₓ.Fg H] : Groupₓ.Fg (Multiplicative H) :=
  AddGroupₓ.fg_iff_mul_fg.1 ‹_›

@[to_additive]
instance (priority := 100) Groupₓ.fg_of_finite [Finite G] : Groupₓ.Fg G := by
  cases nonempty_fintype G
  exact ⟨⟨Finsetₓ.univ, by rw [Finsetₓ.coe_univ] <;> exact Subgroup.closure_univ⟩⟩

@[to_additive]
theorem Groupₓ.fg_of_surjective {G' : Type _} [Groupₓ G'] [hG : Groupₓ.Fg G] {f : G →* G'}
    (hf : Function.Surjective f) : Groupₓ.Fg G' :=
  Groupₓ.FgIffMonoid.fg.mpr <| @Monoidₓ.fg_of_surjective G _ G' _ (Groupₓ.FgIffMonoid.fg.mp hG) f hf

@[to_additive]
instance Groupₓ.fg_range {G' : Type _} [Groupₓ G'] [Groupₓ.Fg G] (f : G →* G') : Groupₓ.Fg f.range :=
  Groupₓ.fg_of_surjective f.range_restrict_surjective

@[to_additive]
instance Groupₓ.closure_finset_fg (s : Finsetₓ G) : Groupₓ.Fg (Subgroup.closure (s : Set G)) := by
  refine' ⟨⟨s.preimage coe (subtype.coe_injective.inj_on _), _⟩⟩
  rw [Finsetₓ.coe_preimage, ← Subgroup.coe_subtype, Subgroup.closure_preimage_eq_top]

@[to_additive]
instance Groupₓ.closure_finite_fg (s : Set G) [Finite s] : Groupₓ.Fg (Subgroup.closure s) :=
  haveI := Fintypeₓ.ofFinite s
  s.coe_to_finset ▸ Groupₓ.closure_finset_fg s.to_finset

variable (G)

/-- The minimum number of generators of a group. -/
@[to_additive "The minimum number of generators of an additive group"]
noncomputable def Groupₓ.rank [h : Groupₓ.Fg G] :=
  @Nat.findₓ _ (Classical.decPred _) (Groupₓ.fg_iff'.mp h)

@[to_additive]
theorem Groupₓ.rank_spec [h : Groupₓ.Fg G] :
    ∃ S : Finsetₓ G, S.card = Groupₓ.rank G ∧ Subgroup.closure (S : Set G) = ⊤ :=
  @Nat.find_specₓ _ (Classical.decPred _) (Groupₓ.fg_iff'.mp h)

@[to_additive]
theorem Groupₓ.rank_le [h : Groupₓ.Fg G] {S : Finsetₓ G} (hS : Subgroup.closure (S : Set G) = ⊤) :
    Groupₓ.rank G ≤ S.card :=
  @Nat.find_le _ _ (Classical.decPred _) (Groupₓ.fg_iff'.mp h) ⟨S, rfl, hS⟩

variable {G} {G' : Type _} [Groupₓ G']

@[to_additive]
theorem Groupₓ.rank_le_of_surjective [Groupₓ.Fg G] [Groupₓ.Fg G'] (f : G →* G') (hf : Function.Surjective f) :
    Groupₓ.rank G' ≤ Groupₓ.rank G := by
  classical
  obtain ⟨S, hS1, hS2⟩ := Groupₓ.rank_spec G
  trans (S.image f).card
  · apply Groupₓ.rank_le
    rw [Finsetₓ.coe_image, ← MonoidHom.map_closure, hS2, Subgroup.map_top_of_surjective f hf]
    
  · exact finset.card_image_le.trans_eq hS1
    

@[to_additive]
theorem Groupₓ.rank_range_le [Groupₓ.Fg G] {f : G →* G'} : Groupₓ.rank f.range ≤ Groupₓ.rank G :=
  Groupₓ.rank_le_of_surjective f.range_restrict f.range_restrict_surjective

@[to_additive]
theorem Groupₓ.rank_congr [Groupₓ.Fg G] [Groupₓ.Fg G'] (f : G ≃* G') : Groupₓ.rank G = Groupₓ.rank G' :=
  le_antisymmₓ (Groupₓ.rank_le_of_surjective f.symm f.symm.Surjective) (Groupₓ.rank_le_of_surjective f f.Surjective)

end Groupₓ

namespace Subgroup

@[to_additive]
theorem rank_congr {H K : Subgroup G} [Groupₓ.Fg H] [Groupₓ.Fg K] (h : H = K) : Groupₓ.rank H = Groupₓ.rank K := by
  subst h

@[to_additive]
theorem rank_closure_finset_le_card (s : Finsetₓ G) : Groupₓ.rank (closure (s : Set G)) ≤ s.card := by
  classical
  let t : Finsetₓ (closure (s : Set G)) := s.preimage coe (subtype.coe_injective.inj_on _)
  have ht : closure (t : Set (closure (s : Set G))) = ⊤ := by
    rw [Finsetₓ.coe_preimage]
    exact closure_preimage_eq_top s
  apply (Groupₓ.rank_le (closure (s : Set G)) ht).trans
  rw [← Finsetₓ.card_image_of_inj_on, Finsetₓ.image_preimage]
  · apply Finsetₓ.card_filter_le
    
  · apply subtype.coe_injective.inj_on
    

@[to_additive]
theorem rank_closure_finite_le_nat_card (s : Set G) [Finite s] : Groupₓ.rank (closure s) ≤ Nat.card s := by
  haveI := Fintypeₓ.ofFinite s
  rw [Nat.card_eq_fintype_card, ← s.to_finset_card, ← rank_congr (congr_arg _ s.coe_to_finset)]
  exact rank_closure_finset_le_card s.to_finset

end Subgroup

section QuotientGroup

@[to_additive]
instance QuotientGroup.fg [Groupₓ.Fg G] (N : Subgroup G) [Subgroup.Normal N] : Groupₓ.Fg <| G ⧸ N :=
  Groupₓ.fg_of_surjective <| QuotientGroup.mk'_surjective N

end QuotientGroup

