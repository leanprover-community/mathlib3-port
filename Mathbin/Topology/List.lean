/-
Copyright (c) 2019 Reid Barton. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl
-/
import Topology.Constructions
import Topology.Algebra.Monoid

#align_import topology.list from "leanprover-community/mathlib"@"e97cf15cd1aec9bd5c193b2ffac5a6dc9118912b"

/-!
# Topology on lists and vectors

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

-/


open TopologicalSpace Set Filter

open scoped Topology Filter

variable {α : Type _} {β : Type _} [TopologicalSpace α] [TopologicalSpace β]

instance : TopologicalSpace (List α) :=
  TopologicalSpace.mkOfNhds (traverse nhds)

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print nhds_list /-
theorem nhds_list (as : List α) : 𝓝 as = traverse 𝓝 as :=
  by
  refine' nhds_mk_of_nhds _ _ _ _
  · intro l; induction l
    case nil => exact le_rfl
    case cons a l
      ih =>
      suffices List.cons <$> pure a <*> pure l ≤ List.cons <$> 𝓝 a <*> traverse 𝓝 l by
        simpa only [functor_norm] using this
      exact Filter.seq_mono (Filter.map_mono <| pure_le_nhds a) ih
  · intro l s hs
    rcases(mem_traverse_iff _ _).1 hs with ⟨u, hu, hus⟩; clear as hs
    have : ∃ v : List (Set α), l.forall₂ (fun a s => IsOpen s ∧ a ∈ s) v ∧ sequence v ⊆ s :=
      by
      induction hu generalizing s
      case nil hs this => exists ; simpa only [List.forall₂_nil_left_iff, exists_eq_left]
      case cons a s as ss ht h ih t
        hts =>
        rcases mem_nhds_iff.1 ht with ⟨u, hut, hu⟩
        rcases ih _ subset.rfl with ⟨v, hv, hvss⟩
        exact
          ⟨u::v, List.Forall₂.cons hu hv,
            subset.trans (Set.seq_mono (Set.image_subset _ hut) hvss) hts⟩
    rcases this with ⟨v, hv, hvs⟩
    refine' ⟨sequence v, mem_traverse _ _ _, hvs, _⟩
    · exact hv.imp fun a s ⟨hs, ha⟩ => IsOpen.mem_nhds hs ha
    · intro u hu
      have hu := (List.mem_traverse _ _).1 hu
      have : List.Forall₂ (fun a s => IsOpen s ∧ a ∈ s) u v :=
        by
        refine' List.Forall₂.flip _
        replace hv := hv.flip
        simp only [List.forall₂_and_left, flip] at hv ⊢
        exact ⟨hv.1, hu.flip⟩
      refine' mem_of_superset _ hvs
      exact mem_traverse _ _ (this.imp fun a s ⟨hs, ha⟩ => IsOpen.mem_nhds hs ha)
#align nhds_list nhds_list
-/

#print nhds_nil /-
@[simp]
theorem nhds_nil : 𝓝 ([] : List α) = pure [] := by
  rw [nhds_list, List.traverse_nil _] <;> infer_instance
#align nhds_nil nhds_nil
-/

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print nhds_cons /-
theorem nhds_cons (a : α) (l : List α) : 𝓝 (a::l) = List.cons <$> 𝓝 a <*> 𝓝 l := by
  rw [nhds_list, List.traverse_cons _, ← nhds_list] <;> infer_instance
#align nhds_cons nhds_cons
-/

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print List.tendsto_cons /-
theorem List.tendsto_cons {a : α} {l : List α} :
    Tendsto (fun p : α × List α => List.cons p.1 p.2) (𝓝 a ×ᶠ 𝓝 l) (𝓝 (a::l)) := by
  rw [nhds_cons, tendsto, Filter.map_prod] <;> exact le_rfl
#align list.tendsto_cons List.tendsto_cons
-/

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Filter.Tendsto.cons /-
theorem Filter.Tendsto.cons {α : Type _} {f : α → β} {g : α → List β} {a : Filter α} {b : β}
    {l : List β} (hf : Tendsto f a (𝓝 b)) (hg : Tendsto g a (𝓝 l)) :
    Tendsto (fun a => List.cons (f a) (g a)) a (𝓝 (b::l)) :=
  List.tendsto_cons.comp (Tendsto.prod_mk hf hg)
#align filter.tendsto.cons Filter.Tendsto.cons
-/

namespace List

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print List.tendsto_cons_iff /-
theorem tendsto_cons_iff {β : Type _} {f : List α → β} {b : Filter β} {a : α} {l : List α} :
    Tendsto f (𝓝 (a::l)) b ↔ Tendsto (fun p : α × List α => f (p.1::p.2)) (𝓝 a ×ᶠ 𝓝 l) b :=
  by
  have : 𝓝 (a::l) = (𝓝 a ×ᶠ 𝓝 l).map fun p : α × List α => p.1::p.2 :=
    by
    simp only [nhds_cons, Filter.prod_eq, (Filter.map_def _ _).symm,
      (Filter.seq_eq_filter_seq _ _).symm]
    simp [-Filter.seq_eq_filter_seq, -Filter.map_def, (· ∘ ·), functor_norm]
  rw [this, Filter.tendsto_map'_iff]
#align list.tendsto_cons_iff List.tendsto_cons_iff
-/

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print List.continuous_cons /-
theorem continuous_cons : Continuous fun x : α × List α => (x.1::x.2 : List α) :=
  continuous_iff_continuousAt.mpr fun ⟨x, y⟩ => continuousAt_fst.cons continuousAt_snd
#align list.continuous_cons List.continuous_cons
-/

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print List.tendsto_nhds /-
theorem tendsto_nhds {β : Type _} {f : List α → β} {r : List α → Filter β}
    (h_nil : Tendsto f (pure []) (r []))
    (h_cons :
      ∀ l a,
        Tendsto f (𝓝 l) (r l) →
          Tendsto (fun p : α × List α => f (p.1::p.2)) (𝓝 a ×ᶠ 𝓝 l) (r (a::l))) :
    ∀ l, Tendsto f (𝓝 l) (r l)
  | [] => by rwa [nhds_nil]
  | a::l => by rw [tendsto_cons_iff] <;> exact h_cons l a (tendsto_nhds l)
#align list.tendsto_nhds List.tendsto_nhds
-/

#print List.continuousAt_length /-
theorem continuousAt_length : ∀ l : List α, ContinuousAt List.length l :=
  by
  simp only [ContinuousAt, nhds_discrete]
  refine' tendsto_nhds _ _
  · exact tendsto_pure_pure _ _
  · intro l a ih
    dsimp only [List.length]
    refine' tendsto.comp (tendsto_pure_pure (fun x => x + 1) _) _
    refine' tendsto.comp ih tendsto_snd
#align list.continuous_at_length List.continuousAt_length
-/

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print List.tendsto_insertNth' /-
theorem tendsto_insertNth' {a : α} :
    ∀ {n : ℕ} {l : List α},
      Tendsto (fun p : α × List α => insertNth n p.1 p.2) (𝓝 a ×ᶠ 𝓝 l) (𝓝 (insertNth n a l))
  | 0, l => tendsto_cons
  | n + 1, [] => by simp
  | n + 1, a'::l =>
    by
    have :
      𝓝 a ×ᶠ 𝓝 (a'::l) = (𝓝 a ×ᶠ (𝓝 a' ×ᶠ 𝓝 l)).map fun p : α × α × List α => (p.1, p.2.1::p.2.2) :=
      by
      simp only [nhds_cons, Filter.prod_eq, ← Filter.map_def, ← Filter.seq_eq_filter_seq]
      simp [-Filter.seq_eq_filter_seq, -Filter.map_def, (· ∘ ·), functor_norm]
    rw [this, tendsto_map'_iff]
    exact
      (tendsto_fst.comp tendsto_snd).cons
        ((@tendsto_insert_nth' n l).comp <| tendsto_fst.prod_mk <| tendsto_snd.comp tendsto_snd)
#align list.tendsto_insert_nth' List.tendsto_insertNth'
-/

#print List.tendsto_insertNth /-
theorem tendsto_insertNth {β} {n : ℕ} {a : α} {l : List α} {f : β → α} {g : β → List α}
    {b : Filter β} (hf : Tendsto f b (𝓝 a)) (hg : Tendsto g b (𝓝 l)) :
    Tendsto (fun b : β => insertNth n (f b) (g b)) b (𝓝 (insertNth n a l)) :=
  tendsto_insertNth'.comp (Tendsto.prod_mk hf hg)
#align list.tendsto_insert_nth List.tendsto_insertNth
-/

#print List.continuous_insertNth /-
theorem continuous_insertNth {n : ℕ} : Continuous fun p : α × List α => insertNth n p.1 p.2 :=
  continuous_iff_continuousAt.mpr fun ⟨a, l⟩ => by
    rw [ContinuousAt, nhds_prod_eq] <;> exact tendsto_insert_nth'
#align list.continuous_insert_nth List.continuous_insertNth
-/

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print List.tendsto_eraseIdx /-
theorem tendsto_eraseIdx :
    ∀ {n : ℕ} {l : List α}, Tendsto (fun l => eraseIdx l n) (𝓝 l) (𝓝 (eraseIdx l n))
  | _, [] => by rw [nhds_nil] <;> exact tendsto_pure_nhds _ _
  | 0, a::l => by rw [tendsto_cons_iff] <;> exact tendsto_snd
  | n + 1, a::l => by
    rw [tendsto_cons_iff]
    dsimp [remove_nth]
    exact tendsto_fst.cons ((@tendsto_remove_nth n l).comp tendsto_snd)
#align list.tendsto_remove_nth List.tendsto_eraseIdx
-/

#print List.continuous_eraseIdx /-
theorem continuous_eraseIdx {n : ℕ} : Continuous fun l : List α => eraseIdx l n :=
  continuous_iff_continuousAt.mpr fun a => tendsto_eraseIdx
#align list.continuous_remove_nth List.continuous_eraseIdx
-/

#print List.tendsto_prod /-
@[to_additive]
theorem tendsto_prod [Monoid α] [ContinuousMul α] {l : List α} :
    Tendsto List.prod (𝓝 l) (𝓝 l.Prod) :=
  by
  induction' l with x l ih
  · simp (config := { contextual := true }) [nhds_nil, mem_of_mem_nhds, tendsto_pure_left]
  simp_rw [tendsto_cons_iff, prod_cons]
  have := continuous_iff_continuous_at.mp continuous_mul (x, l.prod)
  rw [ContinuousAt, nhds_prod_eq] at this
  exact this.comp (tendsto_id.prod_map ih)
#align list.tendsto_prod List.tendsto_prod
#align list.tendsto_sum List.tendsto_sum
-/

#print List.continuous_prod /-
@[to_additive]
theorem continuous_prod [Monoid α] [ContinuousMul α] : Continuous (prod : List α → α) :=
  continuous_iff_continuousAt.mpr fun l => tendsto_prod
#align list.continuous_prod List.continuous_prod
#align list.continuous_sum List.continuous_sum
-/

end List

namespace Mathlib.Vector

open List

instance (n : ℕ) : TopologicalSpace (Mathlib.Vector α n) := by
  unfold Mathlib.Vector <;> infer_instance

#print Vector.tendsto_cons /-
theorem tendsto_cons {n : ℕ} {a : α} {l : Mathlib.Vector α n} :
    Tendsto (fun p : α × Mathlib.Vector α n => p.1 ::ᵥ p.2) (𝓝 a ×ᶠ 𝓝 l) (𝓝 (a ::ᵥ l)) :=
  by
  simp [tendsto_subtype_rng, ← Subtype.val_eq_coe, cons_val]
  exact tendsto_fst.cons (tendsto.comp continuousAt_subtype_val tendsto_snd)
#align vector.tendsto_cons Vector.tendsto_cons
-/

#print Vector.tendsto_insertNth /-
theorem tendsto_insertNth {n : ℕ} {i : Fin (n + 1)} {a : α} :
    ∀ {l : Mathlib.Vector α n},
      Tendsto (fun p : α × Mathlib.Vector α n => Mathlib.Vector.insertNth p.1 i p.2) (𝓝 a ×ᶠ 𝓝 l)
        (𝓝 (Mathlib.Vector.insertNth a i l))
  | ⟨l, hl⟩ => by
    rw [insert_nth, tendsto_subtype_rng]
    simp [insert_nth_val]
    exact List.tendsto_insertNth tendsto_fst (tendsto.comp continuousAt_subtype_val tendsto_snd : _)
#align vector.tendsto_insert_nth Vector.tendsto_insertNth
-/

#print Vector.continuous_insertNth' /-
theorem continuous_insertNth' {n : ℕ} {i : Fin (n + 1)} :
    Continuous fun p : α × Mathlib.Vector α n => Mathlib.Vector.insertNth p.1 i p.2 :=
  continuous_iff_continuousAt.mpr fun ⟨a, l⟩ => by
    rw [ContinuousAt, nhds_prod_eq] <;> exact tendsto_insert_nth
#align vector.continuous_insert_nth' Vector.continuous_insertNth'
-/

#print Vector.continuous_insertNth /-
theorem continuous_insertNth {n : ℕ} {i : Fin (n + 1)} {f : β → α} {g : β → Mathlib.Vector α n}
    (hf : Continuous f) (hg : Continuous g) :
    Continuous fun b => Mathlib.Vector.insertNth (f b) i (g b) :=
  continuous_insertNth'.comp (hf.prod_mk hg : _)
#align vector.continuous_insert_nth Vector.continuous_insertNth
-/

#print Vector.continuousAt_eraseIdx /-
theorem continuousAt_eraseIdx {n : ℕ} {i : Fin (n + 1)} :
    ∀ {l : Mathlib.Vector α (n + 1)}, ContinuousAt (Mathlib.Vector.eraseIdx i) l
  | ⟨l, hl⟩ =>--  ∀{l:vector α (n+1)}, tendsto (remove_nth i) (𝓝 l) (𝓝 (remove_nth i l))
  --| ⟨l, hl⟩ :=
  by
    rw [ContinuousAt, remove_nth, tendsto_subtype_rng]
    simp only [← Subtype.val_eq_coe, Mathlib.Vector.eraseIdx_val]
    exact tendsto.comp List.tendsto_eraseIdx continuousAt_subtype_val
#align vector.continuous_at_remove_nth Vector.continuousAt_eraseIdx
-/

#print Vector.continuous_eraseIdx /-
theorem continuous_eraseIdx {n : ℕ} {i : Fin (n + 1)} :
    Continuous (Mathlib.Vector.eraseIdx i : Mathlib.Vector α (n + 1) → Mathlib.Vector α n) :=
  continuous_iff_continuousAt.mpr fun ⟨a, l⟩ => continuousAt_eraseIdx
#align vector.continuous_remove_nth Vector.continuous_eraseIdx
-/

end Mathlib.Vector

