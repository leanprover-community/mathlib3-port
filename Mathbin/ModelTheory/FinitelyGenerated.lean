/-
Copyright (c) 2022 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson

! This file was ported from Lean 3 source module model_theory.finitely_generated
! leanprover-community/mathlib commit 986c4d5761f938b2e1c43c01f001b6d9d88c2055
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.ModelTheory.Substructures

/-!
# Finitely Generated First-Order Structures
This file defines what it means for a first-order (sub)structure to be finitely or countably
generated, similarly to other finitely-generated objects in the algebra library.

## Main Definitions
* `first_order.language.substructure.fg` indicates that a substructure is finitely generated.
* `first_order.language.Structure.fg` indicates that a structure is finitely generated.
* `first_order.language.substructure.cg` indicates that a substructure is countably generated.
* `first_order.language.Structure.cg` indicates that a structure is countably generated.


## TODO
Develop a more unified definition of finite generation using the theory of closure operators, or use
this definition of finite generation to define the others.

-/


open FirstOrder

open Set

namespace FirstOrder

namespace Language

open StructureCat

variable {L : Language} {M : Type _} [L.StructureCat M]

namespace Substructure

/-- A substructure of `M` is finitely generated if it is the closure of a finite subset of `M`. -/
def Fg (N : L.Substructure M) : Prop :=
  ∃ S : Finset M, closure L ↑S = N
#align first_order.language.substructure.fg FirstOrder.Language.Substructure.Fg

theorem fg_def {N : L.Substructure M} : N.Fg ↔ ∃ S : Set M, S.Finite ∧ closure L S = N :=
  ⟨fun ⟨t, h⟩ => ⟨_, Finset.finite_to_set t, h⟩,
    by
    rintro ⟨t', h, rfl⟩
    rcases finite.exists_finset_coe h with ⟨t, rfl⟩
    exact ⟨t, rfl⟩⟩
#align first_order.language.substructure.fg_def FirstOrder.Language.Substructure.fg_def

theorem fg_iff_exists_fin_generating_family {N : L.Substructure M} :
    N.Fg ↔ ∃ (n : ℕ)(s : Fin n → M), closure L (range s) = N :=
  by
  rw [fg_def]
  constructor
  · rintro ⟨S, Sfin, hS⟩
    obtain ⟨n, f, rfl⟩ := Sfin.fin_embedding
    exact ⟨n, f, hS⟩
  · rintro ⟨n, s, hs⟩
    refine' ⟨range s, finite_range s, hs⟩
#align
  first_order.language.substructure.fg_iff_exists_fin_generating_family FirstOrder.Language.Substructure.fg_iff_exists_fin_generating_family

theorem fg_bot : (⊥ : L.Substructure M).Fg :=
  ⟨∅, by rw [Finset.coe_empty, closure_empty]⟩
#align first_order.language.substructure.fg_bot FirstOrder.Language.Substructure.fg_bot

theorem fg_closure {s : Set M} (hs : s.Finite) : Fg (closure L s) :=
  ⟨hs.toFinset, by rw [hs.coe_to_finset]⟩
#align first_order.language.substructure.fg_closure FirstOrder.Language.Substructure.fg_closure

theorem fg_closure_singleton (x : M) : Fg (closure L ({x} : Set M)) :=
  fg_closure (finite_singleton x)
#align
  first_order.language.substructure.fg_closure_singleton FirstOrder.Language.Substructure.fg_closure_singleton

theorem Fg.sup {N₁ N₂ : L.Substructure M} (hN₁ : N₁.Fg) (hN₂ : N₂.Fg) : (N₁ ⊔ N₂).Fg :=
  let ⟨t₁, ht₁⟩ := fg_def.1 hN₁
  let ⟨t₂, ht₂⟩ := fg_def.1 hN₂
  fg_def.2 ⟨t₁ ∪ t₂, ht₁.1.union ht₂.1, by rw [closure_union, ht₁.2, ht₂.2]⟩
#align first_order.language.substructure.fg.sup FirstOrder.Language.Substructure.Fg.sup

theorem Fg.map {N : Type _} [L.StructureCat N] (f : M →[L] N) {s : L.Substructure M} (hs : s.Fg) :
    (s.map f).Fg :=
  let ⟨t, ht⟩ := fg_def.1 hs
  fg_def.2 ⟨f '' t, ht.1.image _, by rw [closure_image, ht.2]⟩
#align first_order.language.substructure.fg.map FirstOrder.Language.Substructure.Fg.map

theorem Fg.of_map_embedding {N : Type _} [L.StructureCat N] (f : M ↪[L] N) {s : L.Substructure M}
    (hs : (s.map f.toHom).Fg) : s.Fg :=
  by
  rcases hs with ⟨t, h⟩
  rw [fg_def]
  refine' ⟨f ⁻¹' t, t.finite_to_set.preimage (f.injective.inj_on _), _⟩
  have hf : Function.Injective f.to_hom := f.injective
  refine' map_injective_of_injective hf _
  rw [← h, map_closure, embedding.coe_to_hom, image_preimage_eq_of_subset]
  intro x hx
  have h' := subset_closure hx
  rw [h] at h'
  exact hom.map_le_range h'
#align
  first_order.language.substructure.fg.of_map_embedding FirstOrder.Language.Substructure.Fg.of_map_embedding

/-- A substructure of `M` is countably generated if it is the closure of a countable subset of `M`.
-/
def Cg (N : L.Substructure M) : Prop :=
  ∃ S : Set M, S.Countable ∧ closure L S = N
#align first_order.language.substructure.cg FirstOrder.Language.Substructure.Cg

theorem cg_def {N : L.Substructure M} : N.Cg ↔ ∃ S : Set M, S.Countable ∧ closure L S = N :=
  Iff.refl _
#align first_order.language.substructure.cg_def FirstOrder.Language.Substructure.cg_def

theorem Fg.cg {N : L.Substructure M} (h : N.Fg) : N.Cg :=
  by
  obtain ⟨s, hf, rfl⟩ := fg_def.1 h
  refine' ⟨s, hf.countable, rfl⟩
#align first_order.language.substructure.fg.cg FirstOrder.Language.Substructure.Fg.cg

theorem cg_iff_empty_or_exists_nat_generating_family {N : L.Substructure M} :
    N.Cg ↔ ↑N = (∅ : Set M) ∨ ∃ s : ℕ → M, closure L (range s) = N :=
  by
  rw [cg_def]
  constructor
  · rintro ⟨S, Scount, hS⟩
    cases' eq_empty_or_nonempty ↑N with h h
    · exact Or.intro_left _ h
    obtain ⟨f, h'⟩ :=
      (Scount.union (Set.countable_singleton h.some)).exists_eq_range
        (singleton_nonempty h.some).inr
    refine' Or.intro_right _ ⟨f, _⟩
    rw [← h', closure_union, hS, sup_eq_left, closure_le]
    exact singleton_subset_iff.2 h.some_mem
  · intro h
    cases' h with h h
    · refine' ⟨∅, countable_empty, closure_eq_of_le (empty_subset _) _⟩
      rw [← SetLike.coe_subset_coe, h]
      exact empty_subset _
    · obtain ⟨f, rfl⟩ := h
      exact ⟨range f, countable_range _, rfl⟩
#align
  first_order.language.substructure.cg_iff_empty_or_exists_nat_generating_family FirstOrder.Language.Substructure.cg_iff_empty_or_exists_nat_generating_family

theorem cg_bot : (⊥ : L.Substructure M).Cg :=
  fg_bot.Cg
#align first_order.language.substructure.cg_bot FirstOrder.Language.Substructure.cg_bot

theorem cg_closure {s : Set M} (hs : s.Countable) : Cg (closure L s) :=
  ⟨s, hs, rfl⟩
#align first_order.language.substructure.cg_closure FirstOrder.Language.Substructure.cg_closure

theorem cg_closure_singleton (x : M) : Cg (closure L ({x} : Set M)) :=
  (fg_closure_singleton x).Cg
#align
  first_order.language.substructure.cg_closure_singleton FirstOrder.Language.Substructure.cg_closure_singleton

theorem Cg.sup {N₁ N₂ : L.Substructure M} (hN₁ : N₁.Cg) (hN₂ : N₂.Cg) : (N₁ ⊔ N₂).Cg :=
  let ⟨t₁, ht₁⟩ := cg_def.1 hN₁
  let ⟨t₂, ht₂⟩ := cg_def.1 hN₂
  cg_def.2 ⟨t₁ ∪ t₂, ht₁.1.union ht₂.1, by rw [closure_union, ht₁.2, ht₂.2]⟩
#align first_order.language.substructure.cg.sup FirstOrder.Language.Substructure.Cg.sup

theorem Cg.map {N : Type _} [L.StructureCat N] (f : M →[L] N) {s : L.Substructure M} (hs : s.Cg) :
    (s.map f).Cg :=
  let ⟨t, ht⟩ := cg_def.1 hs
  cg_def.2 ⟨f '' t, ht.1.image _, by rw [closure_image, ht.2]⟩
#align first_order.language.substructure.cg.map FirstOrder.Language.Substructure.Cg.map

theorem Cg.of_map_embedding {N : Type _} [L.StructureCat N] (f : M ↪[L] N) {s : L.Substructure M}
    (hs : (s.map f.toHom).Cg) : s.Cg :=
  by
  rcases hs with ⟨t, h1, h2⟩
  rw [cg_def]
  refine' ⟨f ⁻¹' t, h1.preimage f.injective, _⟩
  have hf : Function.Injective f.to_hom := f.injective
  refine' map_injective_of_injective hf _
  rw [← h2, map_closure, embedding.coe_to_hom, image_preimage_eq_of_subset]
  intro x hx
  have h' := subset_closure hx
  rw [h2] at h'
  exact hom.map_le_range h'
#align
  first_order.language.substructure.cg.of_map_embedding FirstOrder.Language.Substructure.Cg.of_map_embedding

theorem cg_iff_countable [Countable (Σl, L.Functions l)] {s : L.Substructure M} :
    s.Cg ↔ Countable s :=
  by
  refine' ⟨_, fun h => ⟨s, h.to_set, s.closure_eq⟩⟩
  rintro ⟨s, h, rfl⟩
  exact h.substructure_closure L
#align
  first_order.language.substructure.cg_iff_countable FirstOrder.Language.Substructure.cg_iff_countable

end Substructure

open Substructure

namespace StructureCat

variable (L) (M)

/-- A structure is finitely generated if it is the closure of a finite subset. -/
class Fg : Prop where
  out : (⊤ : L.Substructure M).Fg
#align first_order.language.Structure.fg FirstOrder.Language.StructureCat.Fg

/-- A structure is countably generated if it is the closure of a countable subset. -/
class Cg : Prop where
  out : (⊤ : L.Substructure M).Cg
#align first_order.language.Structure.cg FirstOrder.Language.StructureCat.Cg

variable {L M}

theorem fg_def : Fg L M ↔ (⊤ : L.Substructure M).Fg :=
  ⟨fun h => h.1, fun h => ⟨h⟩⟩
#align first_order.language.Structure.fg_def FirstOrder.Language.StructureCat.fg_def

/-- An equivalent expression of `Structure.fg` in terms of `set.finite` instead of `finset`. -/
theorem fg_iff : Fg L M ↔ ∃ S : Set M, S.Finite ∧ closure L S = (⊤ : L.Substructure M) := by
  rw [fg_def, substructure.fg_def]
#align first_order.language.Structure.fg_iff FirstOrder.Language.StructureCat.fg_iff

theorem Fg.range {N : Type _} [L.StructureCat N] (h : Fg L M) (f : M →[L] N) : f.range.Fg :=
  by
  rw [hom.range_eq_map]
  exact (fg_def.1 h).map f
#align first_order.language.Structure.fg.range FirstOrder.Language.StructureCat.Fg.range

theorem Fg.map_of_surjective {N : Type _} [L.StructureCat N] (h : Fg L M) (f : M →[L] N)
    (hs : Function.Surjective f) : Fg L N :=
  by
  rw [← hom.range_eq_top] at hs
  rw [fg_def, ← hs]
  exact h.range f
#align
  first_order.language.Structure.fg.map_of_surjective FirstOrder.Language.StructureCat.Fg.map_of_surjective

theorem cg_def : Cg L M ↔ (⊤ : L.Substructure M).Cg :=
  ⟨fun h => h.1, fun h => ⟨h⟩⟩
#align first_order.language.Structure.cg_def FirstOrder.Language.StructureCat.cg_def

/-- An equivalent expression of `Structure.cg`. -/
theorem cg_iff : Cg L M ↔ ∃ S : Set M, S.Countable ∧ closure L S = (⊤ : L.Substructure M) := by
  rw [cg_def, substructure.cg_def]
#align first_order.language.Structure.cg_iff FirstOrder.Language.StructureCat.cg_iff

theorem Cg.range {N : Type _} [L.StructureCat N] (h : Cg L M) (f : M →[L] N) : f.range.Cg :=
  by
  rw [hom.range_eq_map]
  exact (cg_def.1 h).map f
#align first_order.language.Structure.cg.range FirstOrder.Language.StructureCat.Cg.range

theorem Cg.map_of_surjective {N : Type _} [L.StructureCat N] (h : Cg L M) (f : M →[L] N)
    (hs : Function.Surjective f) : Cg L N :=
  by
  rw [← hom.range_eq_top] at hs
  rw [cg_def, ← hs]
  exact h.range f
#align
  first_order.language.Structure.cg.map_of_surjective FirstOrder.Language.StructureCat.Cg.map_of_surjective

theorem cg_iff_countable [Countable (Σl, L.Functions l)] : Cg L M ↔ Countable M := by
  rw [cg_def, cg_iff_countable, top_equiv.to_equiv.countable_iff]
#align
  first_order.language.Structure.cg_iff_countable FirstOrder.Language.StructureCat.cg_iff_countable

theorem Fg.cg (h : Fg L M) : Cg L M :=
  cg_def.2 (fg_def.1 h).Cg
#align first_order.language.Structure.fg.cg FirstOrder.Language.StructureCat.Fg.cg

instance (priority := 100) cg_of_fg [h : Fg L M] : Cg L M :=
  h.Cg
#align first_order.language.Structure.cg_of_fg FirstOrder.Language.StructureCat.cg_of_fg

end StructureCat

theorem Equiv.fg_iff {N : Type _} [L.StructureCat N] (f : M ≃[L] N) :
    StructureCat.Fg L M ↔ StructureCat.Fg L N :=
  ⟨fun h => h.mapOfSurjective f.toHom f.toEquiv.Surjective, fun h =>
    h.mapOfSurjective f.symm.toHom f.toEquiv.symm.Surjective⟩
#align first_order.language.equiv.fg_iff FirstOrder.Language.Equiv.fg_iff

theorem Substructure.fg_iff_Structure_fg (S : L.Substructure M) : S.Fg ↔ StructureCat.Fg L S :=
  by
  rw [Structure.fg_def]
  refine' ⟨fun h => fg.of_map_embedding S.subtype _, fun h => _⟩
  · rw [← hom.range_eq_map, range_subtype]
    exact h
  · have h := h.map S.subtype.to_hom
    rw [← hom.range_eq_map, range_subtype] at h
    exact h
#align
  first_order.language.substructure.fg_iff_Structure_fg FirstOrder.Language.Substructure.fg_iff_Structure_fg

theorem Equiv.cg_iff {N : Type _} [L.StructureCat N] (f : M ≃[L] N) :
    StructureCat.Cg L M ↔ StructureCat.Cg L N :=
  ⟨fun h => h.mapOfSurjective f.toHom f.toEquiv.Surjective, fun h =>
    h.mapOfSurjective f.symm.toHom f.toEquiv.symm.Surjective⟩
#align first_order.language.equiv.cg_iff FirstOrder.Language.Equiv.cg_iff

theorem Substructure.cg_iff_Structure_cg (S : L.Substructure M) : S.Cg ↔ StructureCat.Cg L S :=
  by
  rw [Structure.cg_def]
  refine' ⟨fun h => cg.of_map_embedding S.subtype _, fun h => _⟩
  · rw [← hom.range_eq_map, range_subtype]
    exact h
  · have h := h.map S.subtype.to_hom
    rw [← hom.range_eq_map, range_subtype] at h
    exact h
#align
  first_order.language.substructure.cg_iff_Structure_cg FirstOrder.Language.Substructure.cg_iff_Structure_cg

end Language

end FirstOrder

