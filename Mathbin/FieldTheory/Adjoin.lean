/-
Copyright (c) 2020 Thomas Browning, Patrick Lutz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Thomas Browning, Patrick Lutz
-/
import Mathbin.FieldTheory.IntermediateField
import Mathbin.FieldTheory.Separable
import Mathbin.FieldTheory.SplittingField
import Mathbin.RingTheory.TensorProduct

/-!
# Adjoining Elements to Fields

In this file we introduce the notion of adjoining elements to fields.
This isn't quite the same as adjoining elements to rings.
For example, `algebra.adjoin K {x}` might not include `x⁻¹`.

## Main results

- `adjoin_adjoin_left`: adjoining S and then T is the same as adjoining `S ∪ T`.
- `bot_eq_top_of_dim_adjoin_eq_one`: if `F⟮x⟯` has dimension `1` over `F` for every `x`
  in `E` then `F = E`

## Notation

 - `F⟮α⟯`: adjoin a single element `α` to `F`.
-/


open FiniteDimensional Polynomial

open Classical Polynomial

namespace IntermediateField

section AdjoinDef

variable (F : Type _) [Field F] {E : Type _} [Field E] [Algebra F E] (S : Set E)

/-- `adjoin F S` extends a field `F` by adjoining a set `S ⊆ E`. -/
def adjoin : IntermediateField F E :=
  { Subfield.closure (Set.range (algebraMap F E) ∪ S) with
    algebra_map_mem' := fun x => Subfield.subset_closure (Or.inl (Set.mem_range_self x)) }
#align intermediate_field.adjoin IntermediateField.adjoin

end AdjoinDef

section Lattice

variable {F : Type _} [Field F] {E : Type _} [Field E] [Algebra F E]

@[simp]
theorem adjoin_le_iff {S : Set E} {T : IntermediateField F E} : adjoin F S ≤ T ↔ S ≤ T :=
  ⟨fun H => le_trans (le_trans (Set.subset_union_right _ _) Subfield.subset_closure) H, fun H =>
    (@Subfield.closure_le E _ (Set.range (algebraMap F E) ∪ S) T.toSubfield).mpr
      (Set.union_subset (IntermediateField.set_range_subset T) H)⟩
#align intermediate_field.adjoin_le_iff IntermediateField.adjoin_le_iff

theorem gc : GaloisConnection (adjoin F : Set E → IntermediateField F E) coe := fun _ _ => adjoin_le_iff
#align intermediate_field.gc IntermediateField.gc

/-- Galois insertion between `adjoin` and `coe`. -/
def gi : GaloisInsertion (adjoin F : Set E → IntermediateField F E) coe where
  choice s hs := (adjoin F s).copy s <| le_antisymm (gc.le_u_l s) hs
  gc := IntermediateField.gc
  le_l_u S := (IntermediateField.gc (S : Set E) (adjoin F S)).1 <| le_rfl
  choice_eq _ _ := copy_eq _ _ _
#align intermediate_field.gi IntermediateField.gi

instance : CompleteLattice (IntermediateField F E) :=
  GaloisInsertion.liftCompleteLattice IntermediateField.gi

instance : Inhabited (IntermediateField F E) :=
  ⟨⊤⟩

theorem coe_bot : ↑(⊥ : IntermediateField F E) = Set.range (algebraMap F E) := by
  change ↑(Subfield.closure (Set.range (algebraMap F E) ∪ ∅)) = Set.range (algebraMap F E)
  simp [← Set.image_univ, ← RingHom.map_field_closure]
#align intermediate_field.coe_bot IntermediateField.coe_bot

theorem mem_bot {x : E} : x ∈ (⊥ : IntermediateField F E) ↔ x ∈ Set.range (algebraMap F E) :=
  Set.ext_iff.mp coe_bot x
#align intermediate_field.mem_bot IntermediateField.mem_bot

@[simp]
theorem bot_to_subalgebra : (⊥ : IntermediateField F E).toSubalgebra = ⊥ := by
  ext
  rw [mem_to_subalgebra, Algebra.mem_bot, mem_bot]
#align intermediate_field.bot_to_subalgebra IntermediateField.bot_to_subalgebra

@[simp]
theorem coe_top : ↑(⊤ : IntermediateField F E) = (Set.univ : Set E) :=
  rfl
#align intermediate_field.coe_top IntermediateField.coe_top

@[simp]
theorem mem_top {x : E} : x ∈ (⊤ : IntermediateField F E) :=
  trivial
#align intermediate_field.mem_top IntermediateField.mem_top

@[simp]
theorem top_to_subalgebra : (⊤ : IntermediateField F E).toSubalgebra = ⊤ :=
  rfl
#align intermediate_field.top_to_subalgebra IntermediateField.top_to_subalgebra

@[simp]
theorem top_to_subfield : (⊤ : IntermediateField F E).toSubfield = ⊤ :=
  rfl
#align intermediate_field.top_to_subfield IntermediateField.top_to_subfield

@[simp, norm_cast]
theorem coe_inf (S T : IntermediateField F E) : (↑(S ⊓ T) : Set E) = S ∩ T :=
  rfl
#align intermediate_field.coe_inf IntermediateField.coe_inf

@[simp]
theorem mem_inf {S T : IntermediateField F E} {x : E} : x ∈ S ⊓ T ↔ x ∈ S ∧ x ∈ T :=
  Iff.rfl
#align intermediate_field.mem_inf IntermediateField.mem_inf

@[simp]
theorem inf_to_subalgebra (S T : IntermediateField F E) : (S ⊓ T).toSubalgebra = S.toSubalgebra ⊓ T.toSubalgebra :=
  rfl
#align intermediate_field.inf_to_subalgebra IntermediateField.inf_to_subalgebra

@[simp]
theorem inf_to_subfield (S T : IntermediateField F E) : (S ⊓ T).toSubfield = S.toSubfield ⊓ T.toSubfield :=
  rfl
#align intermediate_field.inf_to_subfield IntermediateField.inf_to_subfield

@[simp, norm_cast]
theorem coe_Inf (S : Set (IntermediateField F E)) : (↑(inf S) : Set E) = inf (coe '' S) :=
  rfl
#align intermediate_field.coe_Inf IntermediateField.coe_Inf

@[simp]
theorem Inf_to_subalgebra (S : Set (IntermediateField F E)) : (inf S).toSubalgebra = inf (to_subalgebra '' S) :=
  SetLike.coe_injective <| by simp [Set.sUnion_image]
#align intermediate_field.Inf_to_subalgebra IntermediateField.Inf_to_subalgebra

@[simp]
theorem Inf_to_subfield (S : Set (IntermediateField F E)) : (inf S).toSubfield = inf (to_subfield '' S) :=
  SetLike.coe_injective <| by simp [Set.sUnion_image]
#align intermediate_field.Inf_to_subfield IntermediateField.Inf_to_subfield

@[simp, norm_cast]
theorem coe_infi {ι : Sort _} (S : ι → IntermediateField F E) : (↑(infi S) : Set E) = ⋂ i, S i := by simp [infi]
#align intermediate_field.coe_infi IntermediateField.coe_infi

@[simp]
theorem infi_to_subalgebra {ι : Sort _} (S : ι → IntermediateField F E) :
    (infi S).toSubalgebra = ⨅ i, (S i).toSubalgebra :=
  SetLike.coe_injective <| by simp [infi]
#align intermediate_field.infi_to_subalgebra IntermediateField.infi_to_subalgebra

@[simp]
theorem infi_to_subfield {ι : Sort _} (S : ι → IntermediateField F E) : (infi S).toSubfield = ⨅ i, (S i).toSubfield :=
  SetLike.coe_injective <| by simp [infi]
#align intermediate_field.infi_to_subfield IntermediateField.infi_to_subfield

/-- Construct an algebra isomorphism from an equality of intermediate fields -/
@[simps apply]
def equivOfEq {S T : IntermediateField F E} (h : S = T) : S ≃ₐ[F] T := by
  refine' { toFun := fun x => ⟨x, _⟩, invFun := fun x => ⟨x, _⟩.. } <;> tidy
#align intermediate_field.equiv_of_eq IntermediateField.equivOfEq

@[simp]
theorem equiv_of_eq_symm {S T : IntermediateField F E} (h : S = T) : (equivOfEq h).symm = equivOfEq h.symm :=
  rfl
#align intermediate_field.equiv_of_eq_symm IntermediateField.equiv_of_eq_symm

@[simp]
theorem equiv_of_eq_rfl (S : IntermediateField F E) : equivOfEq (rfl : S = S) = AlgEquiv.refl := by
  ext
  rfl
#align intermediate_field.equiv_of_eq_rfl IntermediateField.equiv_of_eq_rfl

@[simp]
theorem equiv_of_eq_trans {S T U : IntermediateField F E} (hST : S = T) (hTU : T = U) :
    (equivOfEq hST).trans (equivOfEq hTU) = equivOfEq (trans hST hTU) :=
  rfl
#align intermediate_field.equiv_of_eq_trans IntermediateField.equiv_of_eq_trans

variable (F E)

/-- The bottom intermediate_field is isomorphic to the field. -/
noncomputable def botEquiv : (⊥ : IntermediateField F E) ≃ₐ[F] F :=
  (Subalgebra.equivOfEq _ _ bot_to_subalgebra).trans (Algebra.botEquiv F E)
#align intermediate_field.bot_equiv IntermediateField.botEquiv

variable {F E}

@[simp]
theorem bot_equiv_def (x : F) : botEquiv F E (algebraMap F (⊥ : IntermediateField F E) x) = x :=
  AlgEquiv.commutes (botEquiv F E) x
#align intermediate_field.bot_equiv_def IntermediateField.bot_equiv_def

@[simp]
theorem bot_equiv_symm (x : F) : (botEquiv F E).symm x = algebraMap F _ x :=
  rfl
#align intermediate_field.bot_equiv_symm IntermediateField.bot_equiv_symm

noncomputable instance algebraOverBot : Algebra (⊥ : IntermediateField F E) F :=
  (IntermediateField.botEquiv F E).toAlgHom.toRingHom.toAlgebra
#align intermediate_field.algebra_over_bot IntermediateField.algebraOverBot

theorem coe_algebra_map_over_bot :
    (algebraMap (⊥ : IntermediateField F E) F : (⊥ : IntermediateField F E) → F) = IntermediateField.botEquiv F E :=
  rfl
#align intermediate_field.coe_algebra_map_over_bot IntermediateField.coe_algebra_map_over_bot

instance is_scalar_tower_over_bot : IsScalarTower (⊥ : IntermediateField F E) F E :=
  IsScalarTower.of_algebra_map_eq
    (by
      intro x
      obtain ⟨y, rfl⟩ := (bot_equiv F E).symm.Surjective x
      rw [coe_algebra_map_over_bot, (bot_equiv F E).apply_symm_apply, bot_equiv_symm,
        IsScalarTower.algebra_map_apply F (⊥ : IntermediateField F E) E])
#align intermediate_field.is_scalar_tower_over_bot IntermediateField.is_scalar_tower_over_bot

/-- The top intermediate_field is isomorphic to the field.

This is the intermediate field version of `subalgebra.top_equiv`. -/
@[simps apply]
def topEquiv : (⊤ : IntermediateField F E) ≃ₐ[F] E :=
  (Subalgebra.equivOfEq _ _ top_to_subalgebra).trans Subalgebra.topEquiv
#align intermediate_field.top_equiv IntermediateField.topEquiv

@[simp]
theorem top_equiv_symm_apply_coe (a : E) : ↑(topEquiv.symm a : (⊤ : IntermediateField F E)) = a :=
  rfl
#align intermediate_field.top_equiv_symm_apply_coe IntermediateField.top_equiv_symm_apply_coe

@[simp]
theorem restrict_scalars_bot_eq_self (K : IntermediateField F E) : (⊥ : IntermediateField K E).restrictScalars _ = K :=
  by
  ext
  rw [mem_restrict_scalars, mem_bot]
  exact set.ext_iff.mp Subtype.range_coe x
#align intermediate_field.restrict_scalars_bot_eq_self IntermediateField.restrict_scalars_bot_eq_self

@[simp]
theorem restrict_scalars_top {K : Type _} [Field K] [Algebra K E] [Algebra K F] [IsScalarTower K F E] :
    (⊤ : IntermediateField F E).restrictScalars K = ⊤ :=
  rfl
#align intermediate_field.restrict_scalars_top IntermediateField.restrict_scalars_top

theorem _root_.alg_hom.field_range_eq_map {K : Type _} [Field K] [Algebra F K] (f : E →ₐ[F] K) :
    f.fieldRange = IntermediateField.map f ⊤ :=
  SetLike.ext' Set.image_univ.symm
#align intermediate_field._root_.alg_hom.field_range_eq_map intermediate_field._root_.alg_hom.field_range_eq_map

theorem _root_.alg_hom.map_field_range {K L : Type _} [Field K] [Field L] [Algebra F K] [Algebra F L] (f : E →ₐ[F] K)
    (g : K →ₐ[F] L) : f.fieldRange.map g = (g.comp f).fieldRange :=
  SetLike.ext' (Set.range_comp g f).symm
#align intermediate_field._root_.alg_hom.map_field_range intermediate_field._root_.alg_hom.map_field_range

end Lattice

section AdjoinDef

variable (F : Type _) [Field F] {E : Type _} [Field E] [Algebra F E] (S : Set E)

theorem adjoin_eq_range_algebra_map_adjoin : (adjoin F S : Set E) = Set.range (algebraMap (adjoin F S) E) :=
  Subtype.range_coe.symm
#align intermediate_field.adjoin_eq_range_algebra_map_adjoin IntermediateField.adjoin_eq_range_algebra_map_adjoin

theorem adjoin.algebra_map_mem (x : F) : algebraMap F E x ∈ adjoin F S :=
  IntermediateField.algebra_map_mem (adjoin F S) x
#align intermediate_field.adjoin.algebra_map_mem IntermediateField.adjoin.algebra_map_mem

theorem adjoin.range_algebra_map_subset : Set.range (algebraMap F E) ⊆ adjoin F S := by
  intro x hx
  cases' hx with f hf
  rw [← hf]
  exact adjoin.algebra_map_mem F S f
#align intermediate_field.adjoin.range_algebra_map_subset IntermediateField.adjoin.range_algebra_map_subset

instance adjoin.fieldCoe : CoeTC F (adjoin F S) where coe x := ⟨algebraMap F E x, adjoin.algebra_map_mem F S x⟩
#align intermediate_field.adjoin.field_coe IntermediateField.adjoin.fieldCoe

theorem subset_adjoin : S ⊆ adjoin F S := fun x hx => Subfield.subset_closure (Or.inr hx)
#align intermediate_field.subset_adjoin IntermediateField.subset_adjoin

instance adjoin.setCoe : CoeTC S (adjoin F S) where coe x := ⟨x, subset_adjoin F S (Subtype.mem x)⟩
#align intermediate_field.adjoin.set_coe IntermediateField.adjoin.setCoe

@[mono]
theorem adjoin.mono (T : Set E) (h : S ⊆ T) : adjoin F S ≤ adjoin F T :=
  GaloisConnection.monotone_l gc h
#align intermediate_field.adjoin.mono IntermediateField.adjoin.mono

theorem adjoin_contains_field_as_subfield (F : Subfield E) : (F : Set E) ⊆ adjoin F S := fun x hx =>
  adjoin.algebra_map_mem F S ⟨x, hx⟩
#align intermediate_field.adjoin_contains_field_as_subfield IntermediateField.adjoin_contains_field_as_subfield

theorem subset_adjoin_of_subset_left {F : Subfield E} {T : Set E} (HT : T ⊆ F) : T ⊆ adjoin F S := fun x hx =>
  (adjoin F S).algebra_map_mem ⟨x, HT hx⟩
#align intermediate_field.subset_adjoin_of_subset_left IntermediateField.subset_adjoin_of_subset_left

theorem subset_adjoin_of_subset_right {T : Set E} (H : T ⊆ S) : T ⊆ adjoin F S := fun x hx => subset_adjoin F S (H hx)
#align intermediate_field.subset_adjoin_of_subset_right IntermediateField.subset_adjoin_of_subset_right

@[simp]
theorem adjoin_empty (F E : Type _) [Field F] [Field E] [Algebra F E] : adjoin F (∅ : Set E) = ⊥ :=
  eq_bot_iff.mpr (adjoin_le_iff.mpr (Set.empty_subset _))
#align intermediate_field.adjoin_empty IntermediateField.adjoin_empty

@[simp]
theorem adjoin_univ (F E : Type _) [Field F] [Field E] [Algebra F E] : adjoin F (Set.univ : Set E) = ⊤ :=
  eq_top_iff.mpr <| subset_adjoin _ _
#align intermediate_field.adjoin_univ IntermediateField.adjoin_univ

/-- If `K` is a field with `F ⊆ K` and `S ⊆ K` then `adjoin F S ≤ K`. -/
theorem adjoin_le_subfield {K : Subfield E} (HF : Set.range (algebraMap F E) ⊆ K) (HS : S ⊆ K) :
    (adjoin F S).toSubfield ≤ K := by
  apply subfield.closure_le.mpr
  rw [Set.union_subset_iff]
  exact ⟨HF, HS⟩
#align intermediate_field.adjoin_le_subfield IntermediateField.adjoin_le_subfield

theorem adjoin_subset_adjoin_iff {F' : Type _} [Field F'] [Algebra F' E] {S S' : Set E} :
    (adjoin F S : Set E) ⊆ adjoin F' S' ↔ Set.range (algebraMap F E) ⊆ adjoin F' S' ∧ S ⊆ adjoin F' S' :=
  ⟨fun h => ⟨trans (adjoin.range_algebra_map_subset _ _) h, trans (subset_adjoin _ _) h⟩, fun ⟨hF, hS⟩ =>
    Subfield.closure_le.mpr (Set.union_subset hF hS)⟩
#align intermediate_field.adjoin_subset_adjoin_iff IntermediateField.adjoin_subset_adjoin_iff

/-- `F[S][T] = F[S ∪ T]` -/
theorem adjoin_adjoin_left (T : Set E) : (adjoin (adjoin F S) T).restrictScalars _ = adjoin F (S ∪ T) := by
  rw [SetLike.ext'_iff]
  change ↑(adjoin (adjoin F S) T) = _
  apply Set.eq_of_subset_of_subset <;> rw [adjoin_subset_adjoin_iff] <;> constructor
  · rintro _ ⟨⟨x, hx⟩, rfl⟩
    exact adjoin.mono _ _ _ (Set.subset_union_left _ _) hx
    
  · exact subset_adjoin_of_subset_right _ _ (Set.subset_union_right _ _)
    
  · exact subset_adjoin_of_subset_left _ (adjoin.range_algebra_map_subset _ _)
    
  · exact Set.union_subset (subset_adjoin_of_subset_left _ (subset_adjoin _ _)) (subset_adjoin _ _)
    
#align intermediate_field.adjoin_adjoin_left IntermediateField.adjoin_adjoin_left

@[simp]
theorem adjoin_insert_adjoin (x : E) : adjoin F (insert x (adjoin F S : Set E)) = adjoin F (insert x S) :=
  le_antisymm
    (adjoin_le_iff.mpr
      (Set.insert_subset.mpr
        ⟨subset_adjoin _ _ (Set.mem_insert _ _),
          adjoin_le_iff.mpr (subset_adjoin_of_subset_right _ _ (Set.subset_insert _ _))⟩))
    (adjoin.mono _ _ _ (Set.insert_subset_insert (subset_adjoin _ _)))
#align intermediate_field.adjoin_insert_adjoin IntermediateField.adjoin_insert_adjoin

/-- `F[S][T] = F[T][S]` -/
theorem adjoin_adjoin_comm (T : Set E) :
    (adjoin (adjoin F S) T).restrictScalars F = (adjoin (adjoin F T) S).restrictScalars F := by
  rw [adjoin_adjoin_left, adjoin_adjoin_left, Set.union_comm]
#align intermediate_field.adjoin_adjoin_comm IntermediateField.adjoin_adjoin_comm

theorem adjoin_map {E' : Type _} [Field E'] [Algebra F E'] (f : E →ₐ[F] E') : (adjoin F S).map f = adjoin F (f '' S) :=
  by
  ext x
  show
    x ∈ (Subfield.closure (Set.range (algebraMap F E) ∪ S)).map (f : E →+* E') ↔
      x ∈ Subfield.closure (Set.range (algebraMap F E') ∪ f '' S)
  rw [RingHom.map_field_closure, Set.image_union, ← Set.range_comp, ← RingHom.coe_comp, f.comp_algebra_map]
  rfl
#align intermediate_field.adjoin_map IntermediateField.adjoin_map

theorem algebra_adjoin_le_adjoin : Algebra.adjoin F S ≤ (adjoin F S).toSubalgebra :=
  Algebra.adjoin_le (subset_adjoin _ _)
#align intermediate_field.algebra_adjoin_le_adjoin IntermediateField.algebra_adjoin_le_adjoin

theorem adjoin_eq_algebra_adjoin (inv_mem : ∀ x ∈ Algebra.adjoin F S, x⁻¹ ∈ Algebra.adjoin F S) :
    (adjoin F S).toSubalgebra = Algebra.adjoin F S :=
  le_antisymm
    (show
      adjoin F S ≤ { Algebra.adjoin F S with neg_mem' := fun x => (Algebra.adjoin F S).neg_mem, inv_mem' := inv_mem }
      from adjoin_le_iff.mpr Algebra.subset_adjoin)
    (algebra_adjoin_le_adjoin _ _)
#align intermediate_field.adjoin_eq_algebra_adjoin IntermediateField.adjoin_eq_algebra_adjoin

theorem eq_adjoin_of_eq_algebra_adjoin (K : IntermediateField F E) (h : K.toSubalgebra = Algebra.adjoin F S) :
    K = adjoin F S := by
  apply to_subalgebra_injective
  rw [h]
  refine' (adjoin_eq_algebra_adjoin _ _ _).symm
  intro x
  convert K.inv_mem
  rw [← h]
  rfl
#align intermediate_field.eq_adjoin_of_eq_algebra_adjoin IntermediateField.eq_adjoin_of_eq_algebra_adjoin

@[elab_as_elim]
theorem adjoinInduction {s : Set E} {p : E → Prop} {x} (h : x ∈ adjoin F s) (Hs : ∀ x ∈ s, p x)
    (Hmap : ∀ x, p (algebraMap F E x)) (Hadd : ∀ x y, p x → p y → p (x + y)) (Hneg : ∀ x, p x → p (-x))
    (Hinv : ∀ x, p x → p x⁻¹) (Hmul : ∀ x y, p x → p y → p (x * y)) : p x :=
  Subfield.closureInduction h (fun x hx => Or.cases_on hx (fun ⟨x, hx⟩ => hx ▸ Hmap x) (Hs x))
    ((algebraMap F E).map_one ▸ Hmap 1) Hadd Hneg Hinv Hmul
#align intermediate_field.adjoin_induction IntermediateField.adjoinInduction

--this definition of notation is courtesy of Kyle Miller on zulip
/-- Variation on `set.insert` to enable good notation for adjoining elements to fields.
Used to preferentially use `singleton` rather than `insert` when adjoining one element.
-/
class Insert {α : Type _} (s : Set α) where
  insert : α → Set α
#align intermediate_field.insert IntermediateField.Insert

instance (priority := 1000) insertEmpty {α : Type _} :
    Insert (∅ : Set α) where insert x := @singleton _ _ Set.hasSingleton x
#align intermediate_field.insert_empty IntermediateField.insertEmpty

instance (priority := 900) insertNonempty {α : Type _} (s : Set α) : Insert s where insert x := Insert.insert x s
#align intermediate_field.insert_nonempty IntermediateField.insertNonempty

-- mathport name: «expr ⟮ ,⟯»
notation3:max K"⟮"(l", "* => foldr (h t => Insert.insert t h) ∅)"⟯" => adjoin K l

section AdjoinSimple

variable (α : E)

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem mem_adjoin_simple_self : α ∈ F⟮⟯ :=
  subset_adjoin F {α} (Set.mem_singleton α)
#align intermediate_field.mem_adjoin_simple_self IntermediateField.mem_adjoin_simple_self

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- generator of `F⟮α⟯` -/
def AdjoinSimple.gen : F⟮⟯ :=
  ⟨α, mem_adjoin_simple_self F α⟩
#align intermediate_field.adjoin_simple.gen IntermediateField.AdjoinSimple.gen

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
@[simp]
theorem AdjoinSimple.algebra_map_gen : algebraMap F⟮⟯ E (AdjoinSimple.gen F α) = α :=
  rfl
#align intermediate_field.adjoin_simple.algebra_map_gen IntermediateField.AdjoinSimple.algebra_map_gen

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
@[simp]
theorem AdjoinSimple.is_integral_gen : IsIntegral F (AdjoinSimple.gen F α) ↔ IsIntegral F α := by
  conv_rhs => rw [← adjoin_simple.algebra_map_gen F α]
  rw [is_integral_algebra_map_iff (algebraMap F⟮⟯ E).Injective]
  infer_instance
#align intermediate_field.adjoin_simple.is_integral_gen IntermediateField.AdjoinSimple.is_integral_gen

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem adjoin_simple_adjoin_simple (β : E) : F⟮⟯⟮⟯.restrictScalars F = F⟮⟯ :=
  adjoin_adjoin_left _ _ _
#align intermediate_field.adjoin_simple_adjoin_simple IntermediateField.adjoin_simple_adjoin_simple

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem adjoin_simple_comm (β : E) : F⟮⟯⟮⟯.restrictScalars F = F⟮⟯⟮⟯.restrictScalars F :=
  adjoin_adjoin_comm _ _ _
#align intermediate_field.adjoin_simple_comm IntermediateField.adjoin_simple_comm

variable {F} {α}

theorem adjoin_algebraic_to_subalgebra {S : Set E} (hS : ∀ x ∈ S, IsAlgebraic F x) :
    (IntermediateField.adjoin F S).toSubalgebra = Algebra.adjoin F S := by
  simp only [is_algebraic_iff_is_integral] at hS
  have : Algebra.IsIntegral F (Algebra.adjoin F S) := by
    rwa [← le_integral_closure_iff_is_integral, Algebra.adjoin_le_iff]
  have := isFieldOfIsIntegralOfIsField' this (Field.toIsField F)
  rw [← ((Algebra.adjoin F S).toIntermediateField' this).eq_adjoin_of_eq_algebra_adjoin F S] <;> rfl
#align intermediate_field.adjoin_algebraic_to_subalgebra IntermediateField.adjoin_algebraic_to_subalgebra

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem adjoin_simple_to_subalgebra_of_integral (hα : IsIntegral F α) : F⟮⟯.toSubalgebra = Algebra.adjoin F {α} := by
  apply adjoin_algebraic_to_subalgebra
  rintro x (rfl : x = α)
  rwa [is_algebraic_iff_is_integral]
#align
  intermediate_field.adjoin_simple_to_subalgebra_of_integral IntermediateField.adjoin_simple_to_subalgebra_of_integral

theorem is_splitting_field_iff {p : F[X]} {K : IntermediateField F E} :
    p.IsSplittingField F K ↔ p.Splits (algebraMap F K) ∧ K = adjoin F (p.rootSet E) := by
  suffices _ → (Algebra.adjoin F (p.root_set K) = ⊤ ↔ K = adjoin F (p.root_set E)) by
    exact ⟨fun h => ⟨h.1, (this h.1).mp h.2⟩, fun h => ⟨h.1, (this h.1).mpr h.2⟩⟩
  simp_rw [SetLike.ext_iff, ← mem_to_subalgebra, ← SetLike.ext_iff]
  rw [← K.range_val, adjoin_algebraic_to_subalgebra fun x => isAlgebraicOfMemRootSet]
  exact fun hp => (adjoin_root_set_eq_range hp K.val).symm.trans eq_comm
#align intermediate_field.is_splitting_field_iff IntermediateField.is_splitting_field_iff

theorem adjoinRootSetIsSplittingField {p : F[X]} (hp : p.Splits (algebraMap F E)) :
    p.IsSplittingField F (adjoin F (p.rootSet E)) :=
  is_splitting_field_iff.mpr ⟨splitsOfSplits hp fun x hx => subset_adjoin F (p.rootSet E) hx, rfl⟩
#align intermediate_field.adjoin_root_set_is_splitting_field IntermediateField.adjoinRootSetIsSplittingField

open BigOperators

/-- A compositum of splitting fields is a splitting field -/
theorem isSplittingFieldSupr {ι : Type _} {t : ι → IntermediateField F E} {p : ι → F[X]} {s : Finset ι}
    (h0 : (∏ i in s, p i) ≠ 0) (h : ∀ i ∈ s, (p i).IsSplittingField F (t i)) :
    (∏ i in s, p i).IsSplittingField F (⨆ i ∈ s, t i : IntermediateField F E) := by
  let K : IntermediateField F E := ⨆ i ∈ s, t i
  have hK : ∀ i ∈ s, t i ≤ K := fun i hi => le_supr_of_le i (le_supr (fun _ => t i) hi)
  simp only [is_splitting_field_iff] at h⊢
  refine'
    ⟨splits_prod (algebraMap F K) fun i hi =>
        Polynomial.splitsCompOfSplits (algebraMap F (t i)) (inclusion (hK i hi)).toRingHom (h i hi).1,
      _⟩
  simp only [root_set_prod p s h0, ← Set.supr_eq_Union, (@gc F _ E _ _).l_supr₂]
  exact supr_congr fun i => supr_congr fun hi => (h i hi).2
#align intermediate_field.is_splitting_field_supr IntermediateField.isSplittingFieldSupr

open Set CompleteLattice

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
@[simp]
theorem adjoin_simple_le_iff {K : IntermediateField F E} : F⟮⟯ ≤ K ↔ α ∈ K :=
  adjoin_le_iff.trans singleton_subset_iff
#align intermediate_field.adjoin_simple_le_iff IntermediateField.adjoin_simple_le_iff

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- Adjoining a single element is compact in the lattice of intermediate fields. -/
theorem adjoinSimpleIsCompactElement (x : E) : IsCompactElement F⟮⟯ := by
  rw [is_compact_element_iff_le_of_directed_Sup_le]
  rintro s ⟨F₀, hF₀⟩ hs hx
  simp only [adjoin_simple_le_iff] at hx⊢
  let F : IntermediateField F E :=
    { carrier := ⋃ E ∈ s, ↑E,
      add_mem' := by
        rintro x₁ x₂ ⟨-, ⟨F₁, rfl⟩, ⟨-, ⟨hF₁, rfl⟩, hx₁⟩⟩ ⟨-, ⟨F₂, rfl⟩, ⟨-, ⟨hF₂, rfl⟩, hx₂⟩⟩
        obtain ⟨F₃, hF₃, h₁₃, h₂₃⟩ := hs F₁ hF₁ F₂ hF₂
        exact mem_Union_of_mem F₃ (mem_Union_of_mem hF₃ (F₃.add_mem (h₁₃ hx₁) (h₂₃ hx₂))),
      neg_mem' := by
        rintro x ⟨-, ⟨E, rfl⟩, ⟨-, ⟨hE, rfl⟩, hx⟩⟩
        exact mem_Union_of_mem E (mem_Union_of_mem hE (E.neg_mem hx)),
      mul_mem' := by
        rintro x₁ x₂ ⟨-, ⟨F₁, rfl⟩, ⟨-, ⟨hF₁, rfl⟩, hx₁⟩⟩ ⟨-, ⟨F₂, rfl⟩, ⟨-, ⟨hF₂, rfl⟩, hx₂⟩⟩
        obtain ⟨F₃, hF₃, h₁₃, h₂₃⟩ := hs F₁ hF₁ F₂ hF₂
        exact mem_Union_of_mem F₃ (mem_Union_of_mem hF₃ (F₃.mul_mem (h₁₃ hx₁) (h₂₃ hx₂))),
      inv_mem' := by
        rintro x ⟨-, ⟨E, rfl⟩, ⟨-, ⟨hE, rfl⟩, hx⟩⟩
        exact mem_Union_of_mem E (mem_Union_of_mem hE (E.inv_mem hx)),
      algebra_map_mem' := fun x => mem_Union_of_mem F₀ (mem_Union_of_mem hF₀ (F₀.algebra_map_mem x)) }
  have key : Sup s ≤ F := Sup_le fun E hE => subset_Union_of_subset E (subset_Union _ hE)
  obtain ⟨-, ⟨E, rfl⟩, -, ⟨hE, rfl⟩, hx⟩ := key hx
  exact ⟨E, hE, hx⟩
#align intermediate_field.adjoin_simple_is_compact_element IntermediateField.adjoinSimpleIsCompactElement

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- Adjoining a finite subset is compact in the lattice of intermediate fields. -/
theorem adjoinFinsetIsCompactElement (S : Finset E) : IsCompactElement (adjoin F S : IntermediateField F E) := by
  have key : adjoin F ↑S = ⨆ x ∈ S, F⟮⟯ :=
    le_antisymm
      (adjoin_le_iff.mpr fun x hx =>
        set_like.mem_coe.mpr (adjoin_simple_le_iff.mp (le_supr_of_le x (le_supr_of_le hx le_rfl))))
      (supr_le fun x => supr_le fun hx => adjoin_simple_le_iff.mpr (subset_adjoin F S hx))
  rw [key, ← Finset.sup_eq_supr]
  exact finset_sup_compact_of_compact S fun x hx => adjoin_simple_is_compact_element x
#align intermediate_field.adjoin_finset_is_compact_element IntermediateField.adjoinFinsetIsCompactElement

/-- Adjoining a finite subset is compact in the lattice of intermediate fields. -/
theorem adjoinFiniteIsCompactElement {S : Set E} (h : S.Finite) : IsCompactElement (adjoin F S) :=
  Finite.coe_to_finset h ▸ adjoinFinsetIsCompactElement h.toFinset
#align intermediate_field.adjoin_finite_is_compact_element IntermediateField.adjoinFiniteIsCompactElement

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- The lattice of intermediate fields is compactly generated. -/
instance : IsCompactlyGenerated (IntermediateField F E) :=
  ⟨fun s =>
    ⟨(fun x => F⟮⟯) '' s,
      ⟨by rintro t ⟨x, hx, rfl⟩ <;> exact adjoin_simple_is_compact_element x,
        Sup_image.trans
          (le_antisymm (supr_le fun i => supr_le fun hi => adjoin_simple_le_iff.mpr hi) fun x hx =>
            adjoin_simple_le_iff.mp (le_supr_of_le x (le_supr_of_le hx le_rfl)))⟩⟩⟩

theorem exists_finset_of_mem_supr {ι : Type _} {f : ι → IntermediateField F E} {x : E} (hx : x ∈ ⨆ i, f i) :
    ∃ s : Finset ι, x ∈ ⨆ i ∈ s, f i := by
  have := (adjoin_simple_is_compact_element x).exists_finset_of_le_supr (IntermediateField F E) f
  simp only [adjoin_simple_le_iff] at this
  exact this hx
#align intermediate_field.exists_finset_of_mem_supr IntermediateField.exists_finset_of_mem_supr

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem exists_finset_of_mem_supr' {ι : Type _} {f : ι → IntermediateField F E} {x : E} (hx : x ∈ ⨆ i, f i) :
    ∃ s : Finset (Σi, f i), x ∈ ⨆ i ∈ s, F⟮⟯ :=
  exists_finset_of_mem_supr
    (SetLike.le_def.mp
      (supr_le fun i x h => SetLike.le_def.mp (le_supr_of_le ⟨i, x, h⟩ le_rfl) (mem_adjoin_simple_self F x)) hx)
#align intermediate_field.exists_finset_of_mem_supr' IntermediateField.exists_finset_of_mem_supr'

theorem exists_finset_of_mem_supr'' {ι : Type _} {f : ι → IntermediateField F E} (h : ∀ i, Algebra.IsAlgebraic F (f i))
    {x : E} (hx : x ∈ ⨆ i, f i) : ∃ s : Finset (Σi, f i), x ∈ ⨆ i ∈ s, adjoin F ((minpoly F (i.2 : _)).rootSet E) := by
  refine'
    exists_finset_of_mem_supr
      (set_like.le_def.mp
        (supr_le fun i x hx => set_like.le_def.mp (le_supr_of_le ⟨i, x, hx⟩ le_rfl) (subset_adjoin F _ _)) hx)
  rw [IntermediateField.minpoly_eq, Subtype.coe_mk, Polynomial.mem_root_set, minpoly.aeval]
  exact minpoly.ne_zero (is_integral_iff.mp (is_algebraic_iff_is_integral.mp (h i ⟨x, hx⟩)))
#align intermediate_field.exists_finset_of_mem_supr'' IntermediateField.exists_finset_of_mem_supr''

end AdjoinSimple

end AdjoinDef

section AdjoinIntermediateFieldLattice

variable {F : Type _} [Field F] {E : Type _} [Field E] [Algebra F E] {α : E} {S : Set E}

@[simp]
theorem adjoin_eq_bot_iff : adjoin F S = ⊥ ↔ S ⊆ (⊥ : IntermediateField F E) := by
  rw [eq_bot_iff, adjoin_le_iff]
  rfl
#align intermediate_field.adjoin_eq_bot_iff IntermediateField.adjoin_eq_bot_iff

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
@[simp]
theorem adjoin_simple_eq_bot_iff : F⟮⟯ = ⊥ ↔ α ∈ (⊥ : IntermediateField F E) := by
  rw [adjoin_eq_bot_iff]
  exact Set.singleton_subset_iff
#align intermediate_field.adjoin_simple_eq_bot_iff IntermediateField.adjoin_simple_eq_bot_iff

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
@[simp]
theorem adjoin_zero : F⟮⟯ = ⊥ :=
  adjoin_simple_eq_bot_iff.mpr (zero_mem ⊥)
#align intermediate_field.adjoin_zero IntermediateField.adjoin_zero

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
@[simp]
theorem adjoin_one : F⟮⟯ = ⊥ :=
  adjoin_simple_eq_bot_iff.mpr (one_mem ⊥)
#align intermediate_field.adjoin_one IntermediateField.adjoin_one

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
@[simp]
theorem adjoin_int (n : ℤ) : F⟮⟯ = ⊥ :=
  adjoin_simple_eq_bot_iff.mpr (coe_int_mem ⊥ n)
#align intermediate_field.adjoin_int IntermediateField.adjoin_int

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
@[simp]
theorem adjoin_nat (n : ℕ) : F⟮⟯ = ⊥ :=
  adjoin_simple_eq_bot_iff.mpr (coe_nat_mem ⊥ n)
#align intermediate_field.adjoin_nat IntermediateField.adjoin_nat

section AdjoinDim

open FiniteDimensional Module

variable {K L : IntermediateField F E}

@[simp]
theorem dim_eq_one_iff : Module.rank F K = 1 ↔ K = ⊥ := by
  rw [← to_subalgebra_eq_iff, ← dim_eq_dim_subalgebra, Subalgebra.dim_eq_one_iff, bot_to_subalgebra]
#align intermediate_field.dim_eq_one_iff IntermediateField.dim_eq_one_iff

@[simp]
theorem finrank_eq_one_iff : finrank F K = 1 ↔ K = ⊥ := by
  rw [← to_subalgebra_eq_iff, ← finrank_eq_finrank_subalgebra, Subalgebra.finrank_eq_one_iff, bot_to_subalgebra]
#align intermediate_field.finrank_eq_one_iff IntermediateField.finrank_eq_one_iff

@[simp]
theorem dim_bot : Module.rank F (⊥ : IntermediateField F E) = 1 := by rw [dim_eq_one_iff]
#align intermediate_field.dim_bot IntermediateField.dim_bot

@[simp]
theorem finrank_bot : finrank F (⊥ : IntermediateField F E) = 1 := by rw [finrank_eq_one_iff]
#align intermediate_field.finrank_bot IntermediateField.finrank_bot

theorem dim_adjoin_eq_one_iff : Module.rank F (adjoin F S) = 1 ↔ S ⊆ (⊥ : IntermediateField F E) :=
  Iff.trans dim_eq_one_iff adjoin_eq_bot_iff
#align intermediate_field.dim_adjoin_eq_one_iff IntermediateField.dim_adjoin_eq_one_iff

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem dim_adjoin_simple_eq_one_iff : Module.rank F F⟮⟯ = 1 ↔ α ∈ (⊥ : IntermediateField F E) := by
  rw [dim_adjoin_eq_one_iff]
  exact Set.singleton_subset_iff
#align intermediate_field.dim_adjoin_simple_eq_one_iff IntermediateField.dim_adjoin_simple_eq_one_iff

theorem finrank_adjoin_eq_one_iff : finrank F (adjoin F S) = 1 ↔ S ⊆ (⊥ : IntermediateField F E) :=
  Iff.trans finrank_eq_one_iff adjoin_eq_bot_iff
#align intermediate_field.finrank_adjoin_eq_one_iff IntermediateField.finrank_adjoin_eq_one_iff

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem finrank_adjoin_simple_eq_one_iff : finrank F F⟮⟯ = 1 ↔ α ∈ (⊥ : IntermediateField F E) := by
  rw [finrank_adjoin_eq_one_iff]
  exact Set.singleton_subset_iff
#align intermediate_field.finrank_adjoin_simple_eq_one_iff IntermediateField.finrank_adjoin_simple_eq_one_iff

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- If `F⟮x⟯` has dimension `1` over `F` for every `x ∈ E` then `F = E`. -/
theorem bot_eq_top_of_dim_adjoin_eq_one (h : ∀ x : E, Module.rank F F⟮⟯ = 1) : (⊥ : IntermediateField F E) = ⊤ := by
  ext
  rw [iff_true_right IntermediateField.mem_top]
  exact dim_adjoin_simple_eq_one_iff.mp (h x)
#align intermediate_field.bot_eq_top_of_dim_adjoin_eq_one IntermediateField.bot_eq_top_of_dim_adjoin_eq_one

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem bot_eq_top_of_finrank_adjoin_eq_one (h : ∀ x : E, finrank F F⟮⟯ = 1) : (⊥ : IntermediateField F E) = ⊤ := by
  ext
  rw [iff_true_right IntermediateField.mem_top]
  exact finrank_adjoin_simple_eq_one_iff.mp (h x)
#align intermediate_field.bot_eq_top_of_finrank_adjoin_eq_one IntermediateField.bot_eq_top_of_finrank_adjoin_eq_one

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem subsingleton_of_dim_adjoin_eq_one (h : ∀ x : E, Module.rank F F⟮⟯ = 1) : Subsingleton (IntermediateField F E) :=
  subsingleton_of_bot_eq_top (bot_eq_top_of_dim_adjoin_eq_one h)
#align intermediate_field.subsingleton_of_dim_adjoin_eq_one IntermediateField.subsingleton_of_dim_adjoin_eq_one

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem subsingleton_of_finrank_adjoin_eq_one (h : ∀ x : E, finrank F F⟮⟯ = 1) : Subsingleton (IntermediateField F E) :=
  subsingleton_of_bot_eq_top (bot_eq_top_of_finrank_adjoin_eq_one h)
#align intermediate_field.subsingleton_of_finrank_adjoin_eq_one IntermediateField.subsingleton_of_finrank_adjoin_eq_one

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- If `F⟮x⟯` has dimension `≤1` over `F` for every `x ∈ E` then `F = E`. -/
theorem bot_eq_top_of_finrank_adjoin_le_one [FiniteDimensional F E] (h : ∀ x : E, finrank F F⟮⟯ ≤ 1) :
    (⊥ : IntermediateField F E) = ⊤ := by
  apply bot_eq_top_of_finrank_adjoin_eq_one
  exact fun x => by linarith [h x, show 0 < finrank F F⟮⟯ from finrank_pos]
#align intermediate_field.bot_eq_top_of_finrank_adjoin_le_one IntermediateField.bot_eq_top_of_finrank_adjoin_le_one

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem subsingleton_of_finrank_adjoin_le_one [FiniteDimensional F E] (h : ∀ x : E, finrank F F⟮⟯ ≤ 1) :
    Subsingleton (IntermediateField F E) :=
  subsingleton_of_bot_eq_top (bot_eq_top_of_finrank_adjoin_le_one h)
#align intermediate_field.subsingleton_of_finrank_adjoin_le_one IntermediateField.subsingleton_of_finrank_adjoin_le_one

end AdjoinDim

end AdjoinIntermediateFieldLattice

section AdjoinIntegralElement

variable {F : Type _} [Field F] {E : Type _} [Field E] [Algebra F E] {α : E}

variable {K : Type _} [Field K] [Algebra F K]

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem minpoly_gen {α : E} (h : IsIntegral F α) : minpoly F (AdjoinSimple.gen F α) = minpoly F α := by
  rw [← adjoin_simple.algebra_map_gen F α] at h
  have inj := (algebraMap F⟮⟯ E).Injective
  exact
    minpoly.eq_of_algebra_map_eq inj ((is_integral_algebra_map_iff inj).mp h) (adjoin_simple.algebra_map_gen _ _).symm
#align intermediate_field.minpoly_gen IntermediateField.minpoly_gen

variable (F)

theorem aeval_gen_minpoly (α : E) : aeval (AdjoinSimple.gen F α) (minpoly F α) = 0 := by
  ext
  convert minpoly.aeval F α
  conv in aeval α => rw [← adjoin_simple.algebra_map_gen F α]
  exact (aeval_algebra_map_apply E (adjoin_simple.gen F α) _).symm
#align intermediate_field.aeval_gen_minpoly IntermediateField.aeval_gen_minpoly

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- algebra isomorphism between `adjoin_root` and `F⟮α⟯` -/
noncomputable def adjoinRootEquivAdjoin (h : IsIntegral F α) : AdjoinRoot (minpoly F α) ≃ₐ[F] F⟮⟯ :=
  AlgEquiv.ofBijective (AdjoinRoot.liftHom (minpoly F α) (AdjoinSimple.gen F α) (aeval_gen_minpoly F α))
    (by
      set f := AdjoinRoot.lift _ _ (aeval_gen_minpoly F α : _)
      haveI := Fact.mk (minpoly.irreducible h)
      constructor
      · exact RingHom.injective f
        
      · suffices F⟮⟯.toSubfield ≤ RingHom.fieldRange (F⟮⟯.toSubfield.Subtype.comp f) by
          exact fun x => Exists.cases_on (this (Subtype.mem x)) fun y hy => ⟨y, Subtype.ext hy⟩
        exact
          subfield.closure_le.mpr
            (Set.union_subset
              (fun x hx =>
                Exists.cases_on hx fun y hy =>
                  ⟨y, by
                    rw [RingHom.comp_apply, AdjoinRoot.lift_of]
                    exact hy⟩)
              (set.singleton_subset_iff.mpr
                ⟨AdjoinRoot.root (minpoly F α), by
                  rw [RingHom.comp_apply, AdjoinRoot.lift_root]
                  rfl⟩))
        )
#align intermediate_field.adjoin_root_equiv_adjoin IntermediateField.adjoinRootEquivAdjoin

theorem adjoin_root_equiv_adjoin_apply_root (h : IsIntegral F α) :
    adjoinRootEquivAdjoin F h (AdjoinRoot.root (minpoly F α)) = AdjoinSimple.gen F α :=
  AdjoinRoot.lift_root (aeval_gen_minpoly F α)
#align intermediate_field.adjoin_root_equiv_adjoin_apply_root IntermediateField.adjoin_root_equiv_adjoin_apply_root

section PowerBasis

variable {L : Type _} [Field L] [Algebra K L]

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- The elements `1, x, ..., x ^ (d - 1)` form a basis for `K⟮x⟯`,
where `d` is the degree of the minimal polynomial of `x`. -/
noncomputable def powerBasisAux {x : L} (hx : IsIntegral K x) : Basis (Fin (minpoly K x).natDegree) K K⟮⟯ :=
  (AdjoinRoot.powerBasis (minpoly.ne_zero hx)).Basis.map (adjoinRootEquivAdjoin K hx).toLinearEquiv
#align intermediate_field.power_basis_aux IntermediateField.powerBasisAux

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- The power basis `1, x, ..., x ^ (d - 1)` for `K⟮x⟯`,
where `d` is the degree of the minimal polynomial of `x`. -/
@[simps]
noncomputable def adjoin.powerBasis {x : L} (hx : IsIntegral K x) : PowerBasis K K⟮⟯ where
  gen := AdjoinSimple.gen K x
  dim := (minpoly K x).natDegree
  Basis := powerBasisAux hx
  basis_eq_pow i := by
    rw [power_basis_aux, Basis.map_apply, PowerBasis.basis_eq_pow, AlgEquiv.to_linear_equiv_apply, AlgEquiv.map_pow,
      AdjoinRoot.power_basis_gen, adjoin_root_equiv_adjoin_apply_root]
#align intermediate_field.adjoin.power_basis IntermediateField.adjoin.powerBasis

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem adjoin.finiteDimensional {x : L} (hx : IsIntegral K x) : FiniteDimensional K K⟮⟯ :=
  PowerBasis.finiteDimensional (adjoin.powerBasis hx)
#align intermediate_field.adjoin.finite_dimensional IntermediateField.adjoin.finiteDimensional

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem adjoin.finrank {x : L} (hx : IsIntegral K x) : FiniteDimensional.finrank K K⟮⟯ = (minpoly K x).natDegree := by
  rw [PowerBasis.finrank (adjoin.power_basis hx : _)]
  rfl
#align intermediate_field.adjoin.finrank IntermediateField.adjoin.finrank

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem _root_.minpoly.nat_degree_le {x : L} [FiniteDimensional K L] (hx : IsIntegral K x) :
    (minpoly K x).natDegree ≤ finrank K L :=
  le_of_eq_of_le (IntermediateField.adjoin.finrank hx).symm K⟮⟯.toSubmodule.finrank_le
#align intermediate_field._root_.minpoly.nat_degree_le intermediate_field._root_.minpoly.nat_degree_le

theorem _root_.minpoly.degree_le {x : L} [FiniteDimensional K L] (hx : IsIntegral K x) :
    (minpoly K x).degree ≤ finrank K L :=
  degree_le_of_nat_degree_le (minpoly.nat_degree_le hx)
#align intermediate_field._root_.minpoly.degree_le intermediate_field._root_.minpoly.degree_le

end PowerBasis

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- Algebra homomorphism `F⟮α⟯ →ₐ[F] K` are in bijection with the set of roots
of `minpoly α` in `K`. -/
noncomputable def algHomAdjoinIntegralEquiv (h : IsIntegral F α) :
    (F⟮⟯ →ₐ[F] K) ≃ { x // x ∈ ((minpoly F α).map (algebraMap F K)).roots } :=
  (adjoin.powerBasis h).liftEquiv'.trans
    ((Equiv.refl _).subtypeEquiv fun x => by rw [adjoin.power_basis_gen, minpoly_gen h, Equiv.refl_apply])
#align intermediate_field.alg_hom_adjoin_integral_equiv IntermediateField.algHomAdjoinIntegralEquiv

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- Fintype of algebra homomorphism `F⟮α⟯ →ₐ[F] K` -/
noncomputable def fintypeOfAlgHomAdjoinIntegral (h : IsIntegral F α) : Fintype (F⟮⟯ →ₐ[F] K) :=
  PowerBasis.AlgHom.fintype (adjoin.powerBasis h)
#align intermediate_field.fintype_of_alg_hom_adjoin_integral IntermediateField.fintypeOfAlgHomAdjoinIntegral

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem card_alg_hom_adjoin_integral (h : IsIntegral F α) (h_sep : (minpoly F α).Separable)
    (h_splits : (minpoly F α).Splits (algebraMap F K)) :
    @Fintype.card (F⟮⟯ →ₐ[F] K) (fintypeOfAlgHomAdjoinIntegral F h) = (minpoly F α).natDegree := by
  rw [AlgHom.card_of_power_basis] <;>
    simp only [adjoin.power_basis_dim, adjoin.power_basis_gen, minpoly_gen h, h_sep, h_splits]
#align intermediate_field.card_alg_hom_adjoin_integral IntermediateField.card_alg_hom_adjoin_integral

end AdjoinIntegralElement

section Induction

variable {F : Type _} [Field F] {E : Type _} [Field E] [Algebra F E]

/-- An intermediate field `S` is finitely generated if there exists `t : finset E` such that
`intermediate_field.adjoin F t = S`. -/
def Fg (S : IntermediateField F E) : Prop :=
  ∃ t : Finset E, adjoin F ↑t = S
#align intermediate_field.fg IntermediateField.Fg

theorem fgAdjoinFinset (t : Finset E) : (adjoin F (↑t : Set E)).Fg :=
  ⟨t, rfl⟩
#align intermediate_field.fg_adjoin_finset IntermediateField.fgAdjoinFinset

theorem fg_def {S : IntermediateField F E} : S.Fg ↔ ∃ t : Set E, Set.Finite t ∧ adjoin F t = S :=
  Iff.symm Set.exists_finite_iff_finset
#align intermediate_field.fg_def IntermediateField.fg_def

theorem fgBot : (⊥ : IntermediateField F E).Fg :=
  ⟨∅, adjoin_empty F E⟩
#align intermediate_field.fg_bot IntermediateField.fgBot

theorem fgOfFgToSubalgebra (S : IntermediateField F E) (h : S.toSubalgebra.Fg) : S.Fg := by
  cases' h with t ht
  exact ⟨t, (eq_adjoin_of_eq_algebra_adjoin _ _ _ ht.symm).symm⟩
#align intermediate_field.fg_of_fg_to_subalgebra IntermediateField.fgOfFgToSubalgebra

theorem fgOfNoetherian (S : IntermediateField F E) [IsNoetherian F E] : S.Fg :=
  S.fgOfFgToSubalgebra S.toSubalgebra.fgOfNoetherian
#align intermediate_field.fg_of_noetherian IntermediateField.fgOfNoetherian

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem inductionOnAdjoinFinset (S : Finset E) (P : IntermediateField F E → Prop) (base : P ⊥)
    (ih : ∀ (K : IntermediateField F E), ∀ x ∈ S, P K → P (K⟮⟯.restrictScalars F)) : P (adjoin F ↑S) := by
  apply Finset.induction_on' S
  · exact base
    
  · intro a s h1 _ _ h4
    rw [Finset.coe_insert, Set.insert_eq, Set.union_comm, ← adjoin_adjoin_left]
    exact ih (adjoin F s) a h1 h4
    
#align intermediate_field.induction_on_adjoin_finset IntermediateField.inductionOnAdjoinFinset

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem inductionOnAdjoinFg (P : IntermediateField F E → Prop) (base : P ⊥)
    (ih : ∀ (K : IntermediateField F E) (x : E), P K → P (K⟮⟯.restrictScalars F)) (K : IntermediateField F E)
    (hK : K.Fg) : P K := by
  obtain ⟨S, rfl⟩ := hK
  exact induction_on_adjoin_finset S P base fun K x _ hK => ih K x hK
#align intermediate_field.induction_on_adjoin_fg IntermediateField.inductionOnAdjoinFg

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem inductionOnAdjoin [fd : FiniteDimensional F E] (P : IntermediateField F E → Prop) (base : P ⊥)
    (ih : ∀ (K : IntermediateField F E) (x : E), P K → P (K⟮⟯.restrictScalars F)) (K : IntermediateField F E) : P K :=
  letI : IsNoetherian F E := IsNoetherian.iff_fg.2 inferInstance
  induction_on_adjoin_fg P base ih K K.fg_of_noetherian
#align intermediate_field.induction_on_adjoin IntermediateField.inductionOnAdjoin

end Induction

section AlgHomMkAdjoinSplits

variable (F E K : Type _) [Field F] [Field E] [Field K] [Algebra F E] [Algebra F K] {S : Set E}

/-- Lifts `L → K` of `F → K` -/
def Lifts :=
  ΣL : IntermediateField F E, L →ₐ[F] K
#align intermediate_field.lifts IntermediateField.Lifts

variable {F E K}

instance : PartialOrder (Lifts F E K) where
  le x y := x.1 ≤ y.1 ∧ ∀ (s : x.1) (t : y.1), (s : E) = t → x.2 s = y.2 t
  le_refl x := ⟨le_refl x.1, fun s t hst => congr_arg x.2 (Subtype.ext hst)⟩
  le_trans x y z hxy hyz :=
    ⟨le_trans hxy.1 hyz.1, fun s u hsu => Eq.trans (hxy.2 s ⟨s, hxy.1 s.Mem⟩ rfl) (hyz.2 ⟨s, hxy.1 s.Mem⟩ u hsu)⟩
  le_antisymm := by
    rintro ⟨x1, x2⟩ ⟨y1, y2⟩ ⟨hxy1, hxy2⟩ ⟨hyx1, hyx2⟩
    obtain rfl : x1 = y1 := le_antisymm hxy1 hyx1
    congr
    exact AlgHom.ext fun s => hxy2 s s rfl

noncomputable instance : OrderBot (Lifts F E K) where
  bot := ⟨⊥, (Algebra.ofId F K).comp (botEquiv F E).toAlgHom⟩
  bot_le x :=
    ⟨bot_le, fun s t hst => by
      cases' intermediate_field.mem_bot.mp s.mem with u hu
      rw [show s = (algebraMap F _) u from Subtype.ext hu.symm, AlgHom.commutes]
      rw [show t = (algebraMap F _) u from Subtype.ext (Eq.trans hu hst).symm, AlgHom.commutes]⟩

noncomputable instance : Inhabited (Lifts F E K) :=
  ⟨⊥⟩

theorem Lifts.eq_of_le {x y : Lifts F E K} (hxy : x ≤ y) (s : x.1) : x.2 s = y.2 ⟨s, hxy.1 s.Mem⟩ :=
  hxy.2 s ⟨s, hxy.1 s.Mem⟩ rfl
#align intermediate_field.lifts.eq_of_le IntermediateField.Lifts.eq_of_le

theorem Lifts.exists_max_two {c : Set (Lifts F E K)} {x y : Lifts F E K} (hc : IsChain (· ≤ ·) c)
    (hx : x ∈ Insert.insert ⊥ c) (hy : y ∈ Insert.insert ⊥ c) :
    ∃ z : Lifts F E K, z ∈ Insert.insert ⊥ c ∧ x ≤ z ∧ y ≤ z := by
  cases' (hc.insert fun _ _ _ => Or.inl bot_le).Total hx hy with hxy hyx
  · exact ⟨y, hy, hxy, le_refl y⟩
    
  · exact ⟨x, hx, le_refl x, hyx⟩
    
#align intermediate_field.lifts.exists_max_two IntermediateField.Lifts.exists_max_two

theorem Lifts.exists_max_three {c : Set (Lifts F E K)} {x y z : Lifts F E K} (hc : IsChain (· ≤ ·) c)
    (hx : x ∈ Insert.insert ⊥ c) (hy : y ∈ Insert.insert ⊥ c) (hz : z ∈ Insert.insert ⊥ c) :
    ∃ w : Lifts F E K, w ∈ Insert.insert ⊥ c ∧ x ≤ w ∧ y ≤ w ∧ z ≤ w := by
  obtain ⟨v, hv, hxv, hyv⟩ := lifts.exists_max_two hc hx hy
  obtain ⟨w, hw, hzw, hvw⟩ := lifts.exists_max_two hc hz hv
  exact ⟨w, hw, le_trans hxv hvw, le_trans hyv hvw, hzw⟩
#align intermediate_field.lifts.exists_max_three IntermediateField.Lifts.exists_max_three

/-- An upper bound on a chain of lifts -/
def Lifts.upperBoundIntermediateField {c : Set (Lifts F E K)} (hc : IsChain (· ≤ ·) c) : IntermediateField F E where
  carrier s := ∃ x : Lifts F E K, x ∈ Insert.insert ⊥ c ∧ (s ∈ x.1 : Prop)
  zero_mem' := ⟨⊥, Set.mem_insert ⊥ c, zero_mem ⊥⟩
  one_mem' := ⟨⊥, Set.mem_insert ⊥ c, one_mem ⊥⟩
  neg_mem' := by
    rintro _ ⟨x, y, h⟩
    exact ⟨x, ⟨y, x.1.neg_mem h⟩⟩
  inv_mem' := by
    rintro _ ⟨x, y, h⟩
    exact ⟨x, ⟨y, x.1.inv_mem h⟩⟩
  add_mem' := by
    rintro _ _ ⟨x, hx, ha⟩ ⟨y, hy, hb⟩
    obtain ⟨z, hz, hxz, hyz⟩ := lifts.exists_max_two hc hx hy
    exact ⟨z, hz, z.1.add_mem (hxz.1 ha) (hyz.1 hb)⟩
  mul_mem' := by
    rintro _ _ ⟨x, hx, ha⟩ ⟨y, hy, hb⟩
    obtain ⟨z, hz, hxz, hyz⟩ := lifts.exists_max_two hc hx hy
    exact ⟨z, hz, z.1.mul_mem (hxz.1 ha) (hyz.1 hb)⟩
  algebra_map_mem' s := ⟨⊥, Set.mem_insert ⊥ c, algebra_map_mem ⊥ s⟩
#align intermediate_field.lifts.upper_bound_intermediate_field IntermediateField.Lifts.upperBoundIntermediateField

/-- The lift on the upper bound on a chain of lifts -/
noncomputable def Lifts.upperBoundAlgHom {c : Set (Lifts F E K)} (hc : IsChain (· ≤ ·) c) :
    Lifts.upperBoundIntermediateField hc →ₐ[F] K where
  toFun s := (Classical.choose s.Mem).2 ⟨s, (Classical.choose_spec s.Mem).2⟩
  map_zero' := AlgHom.map_zero _
  map_one' := AlgHom.map_one _
  map_add' s t := by
    obtain ⟨w, hw, hxw, hyw, hzw⟩ :=
      lifts.exists_max_three hc (Classical.choose_spec s.mem).1 (Classical.choose_spec t.mem).1
        (Classical.choose_spec (s + t).Mem).1
    rw [lifts.eq_of_le hxw, lifts.eq_of_le hyw, lifts.eq_of_le hzw, ← w.2.map_add]
    rfl
  map_mul' s t := by
    obtain ⟨w, hw, hxw, hyw, hzw⟩ :=
      lifts.exists_max_three hc (Classical.choose_spec s.mem).1 (Classical.choose_spec t.mem).1
        (Classical.choose_spec (s * t).Mem).1
    rw [lifts.eq_of_le hxw, lifts.eq_of_le hyw, lifts.eq_of_le hzw, ← w.2.map_mul]
    rfl
  commutes' _ := AlgHom.commutes _ _
#align intermediate_field.lifts.upper_bound_alg_hom IntermediateField.Lifts.upperBoundAlgHom

/-- An upper bound on a chain of lifts -/
noncomputable def Lifts.upperBound {c : Set (Lifts F E K)} (hc : IsChain (· ≤ ·) c) : Lifts F E K :=
  ⟨Lifts.upperBoundIntermediateField hc, Lifts.upperBoundAlgHom hc⟩
#align intermediate_field.lifts.upper_bound IntermediateField.Lifts.upperBound

theorem Lifts.exists_upper_bound (c : Set (Lifts F E K)) (hc : IsChain (· ≤ ·) c) : ∃ ub, ∀ a ∈ c, a ≤ ub :=
  ⟨Lifts.upperBound hc, by
    intro x hx
    constructor
    · exact fun s hs => ⟨x, Set.mem_insert_of_mem ⊥ hx, hs⟩
      
    · intro s t hst
      change x.2 s = (Classical.choose t.mem).2 ⟨t, (Classical.choose_spec t.mem).2⟩
      obtain ⟨z, hz, hxz, hyz⟩ := lifts.exists_max_two hc (Set.mem_insert_of_mem ⊥ hx) (Classical.choose_spec t.mem).1
      rw [lifts.eq_of_le hxz, lifts.eq_of_le hyz]
      exact congr_arg z.2 (Subtype.ext hst)
      ⟩
#align intermediate_field.lifts.exists_upper_bound IntermediateField.Lifts.exists_upper_bound

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- Extend a lift `x : lifts F E K` to an element `s : E` whose conjugates are all in `K` -/
noncomputable def Lifts.liftOfSplits (x : Lifts F E K) {s : E} (h1 : IsIntegral F s)
    (h2 : (minpoly F s).Splits (algebraMap F K)) : Lifts F E K :=
  let h3 : IsIntegral x.1 s := isIntegralOfIsScalarTower h1
  let key : (minpoly x.1 s).Splits x.2.toRingHom :=
    splitsOfSplitsOfDvd _ (map_ne_zero (minpoly.ne_zero h1))
      ((splits_map_iff _ _).mpr
        (by
          convert h2
          exact RingHom.ext fun y => x.2.commutes y))
      (minpoly.dvd_map_of_is_scalar_tower _ _ _)
  ⟨x.1⟮⟯.restrictScalars F,
    (@algHomEquivSigma F x.1 (x.1⟮⟯.restrictScalars F) K _ _ _ _ _ _ _ (IntermediateField.algebra x.1⟮⟯)
          (IsScalarTower.of_algebra_map_eq fun _ => rfl)).invFun
      ⟨x.2,
        (@algHomAdjoinIntegralEquiv x.1 _ E _ _ s K _ x.2.toRingHom.toAlgebra h3).invFun
          ⟨rootOfSplits x.2.toRingHom key (ne_of_gt (minpoly.degree_pos h3)), by
            simp_rw [mem_roots (map_ne_zero (minpoly.ne_zero h3)), is_root, ← eval₂_eq_eval_map]
            exact map_root_of_splits x.2.toRingHom key (ne_of_gt (minpoly.degree_pos h3))⟩⟩⟩
#align intermediate_field.lifts.lift_of_splits IntermediateField.Lifts.liftOfSplits

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
theorem Lifts.le_lifts_of_splits (x : Lifts F E K) {s : E} (h1 : IsIntegral F s)
    (h2 : (minpoly F s).Splits (algebraMap F K)) : x ≤ x.lift_of_splits h1 h2 :=
  ⟨fun z hz => algebra_map_mem x.1⟮⟯ ⟨z, hz⟩, fun t u htu =>
    Eq.symm
      (by
        rw [← show algebraMap x.1 x.1⟮⟯ t = u from Subtype.ext htu]
        letI : Algebra x.1 K := x.2.toRingHom.toAlgebra
        exact AlgHom.commutes _ t)⟩
#align intermediate_field.lifts.le_lifts_of_splits IntermediateField.Lifts.le_lifts_of_splits

theorem Lifts.mem_lifts_of_splits (x : Lifts F E K) {s : E} (h1 : IsIntegral F s)
    (h2 : (minpoly F s).Splits (algebraMap F K)) : s ∈ (x.lift_of_splits h1 h2).1 :=
  mem_adjoin_simple_self x.1 s
#align intermediate_field.lifts.mem_lifts_of_splits IntermediateField.Lifts.mem_lifts_of_splits

theorem Lifts.exists_lift_of_splits (x : Lifts F E K) {s : E} (h1 : IsIntegral F s)
    (h2 : (minpoly F s).Splits (algebraMap F K)) : ∃ y, x ≤ y ∧ s ∈ y.1 :=
  ⟨x.lift_of_splits h1 h2, x.le_lifts_of_splits h1 h2, x.mem_lifts_of_splits h1 h2⟩
#align intermediate_field.lifts.exists_lift_of_splits IntermediateField.Lifts.exists_lift_of_splits

theorem alg_hom_mk_adjoin_splits (hK : ∀ s ∈ S, IsIntegral F (s : E) ∧ (minpoly F s).Splits (algebraMap F K)) :
    Nonempty (adjoin F S →ₐ[F] K) := by
  obtain ⟨x : lifts F E K, hx⟩ := zorn_partial_order lifts.exists_upper_bound
  refine'
    ⟨AlgHom.mk (fun s => x.2 ⟨s, adjoin_le_iff.mpr (fun s hs => _) s.Mem⟩) x.2.map_one
        (fun s t => x.2.map_mul ⟨s, _⟩ ⟨t, _⟩) x.2.map_zero (fun s t => x.2.map_add ⟨s, _⟩ ⟨t, _⟩) x.2.commutes⟩
  rcases x.exists_lift_of_splits (hK s hs).1 (hK s hs).2 with ⟨y, h1, h2⟩
  rwa [hx y h1] at h2
#align intermediate_field.alg_hom_mk_adjoin_splits IntermediateField.alg_hom_mk_adjoin_splits

theorem alg_hom_mk_adjoin_splits' (hS : adjoin F S = ⊤)
    (hK : ∀ x ∈ S, IsIntegral F (x : E) ∧ (minpoly F x).Splits (algebraMap F K)) : Nonempty (E →ₐ[F] K) := by
  cases' alg_hom_mk_adjoin_splits hK with ϕ
  rw [hS] at ϕ
  exact ⟨ϕ.comp top_equiv.symm.to_alg_hom⟩
#align intermediate_field.alg_hom_mk_adjoin_splits' IntermediateField.alg_hom_mk_adjoin_splits'

end AlgHomMkAdjoinSplits

section Supremum

variable {K L : Type _} [Field K] [Field L] [Algebra K L] (E1 E2 : IntermediateField K L)

theorem le_sup_to_subalgebra : E1.toSubalgebra ⊔ E2.toSubalgebra ≤ (E1 ⊔ E2).toSubalgebra :=
  sup_le (show E1 ≤ E1 ⊔ E2 from le_sup_left) (show E2 ≤ E1 ⊔ E2 from le_sup_right)
#align intermediate_field.le_sup_to_subalgebra IntermediateField.le_sup_to_subalgebra

theorem sup_to_subalgebra [h1 : FiniteDimensional K E1] [h2 : FiniteDimensional K E2] :
    (E1 ⊔ E2).toSubalgebra = E1.toSubalgebra ⊔ E2.toSubalgebra := by
  let S1 := E1.to_subalgebra
  let S2 := E2.to_subalgebra
  refine'
    le_antisymm
      (show _ ≤ (S1 ⊔ S2).toIntermediateField _ from
        sup_le (show S1 ≤ _ from le_sup_left) (show S2 ≤ _ from le_sup_right))
      (le_sup_to_subalgebra E1 E2)
  suffices IsField ↥(S1 ⊔ S2) by
    intro x hx
    by_cases hx':(⟨x, hx⟩ : S1 ⊔ S2) = 0
    · rw [← Subtype.coe_mk x hx, hx', Subalgebra.coe_zero, inv_zero]
      exact (S1 ⊔ S2).zero_mem
      
    · obtain ⟨y, h⟩ := this.mul_inv_cancel hx'
      exact (congr_arg (· ∈ S1 ⊔ S2) <| eq_inv_of_mul_eq_one_right <| subtype.ext_iff.mp h).mp y.2
      
  exact
    isFieldOfIsIntegralOfIsField'
      (is_integral_sup.mpr ⟨Algebra.isIntegralOfFinite K E1, Algebra.isIntegralOfFinite K E2⟩) (Field.toIsField K)
#align intermediate_field.sup_to_subalgebra IntermediateField.sup_to_subalgebra

instance finiteDimensionalSup [h1 : FiniteDimensional K E1] [h2 : FiniteDimensional K E2] :
    FiniteDimensional K ↥(E1 ⊔ E2) := by
  let g := Algebra.TensorProduct.productMap E1.val E2.val
  suffices g.range = (E1 ⊔ E2).toSubalgebra by
    have h : FiniteDimensional K g.range.to_submodule := g.to_linear_map.finite_dimensional_range
    rwa [this] at h
  rw [Algebra.TensorProduct.product_map_range, E1.range_val, E2.range_val, sup_to_subalgebra]
#align intermediate_field.finite_dimensional_sup IntermediateField.finiteDimensionalSup

instance finiteDimensionalSuprOfFinite {ι : Type _} {t : ι → IntermediateField K L} [h : Finite ι]
    [∀ i, FiniteDimensional K (t i)] : FiniteDimensional K (⨆ i, t i : IntermediateField K L) := by
  rw [← supr_univ]
  let P : Set ι → Prop := fun s => FiniteDimensional K (⨆ i ∈ s, t i : IntermediateField K L)
  change P Set.univ
  apply Set.Finite.induction_on
  · exact Set.finite_univ
    
  all_goals dsimp only [P]
  · rw [supr_emptyset]
    exact (bot_equiv K L).symm.toLinearEquiv.FiniteDimensional
    
  · intro _ s _ _ hs
    rw [supr_insert]
    exact IntermediateField.finiteDimensionalSup _ _
    
#align intermediate_field.finite_dimensional_supr_of_finite IntermediateField.finiteDimensionalSuprOfFinite

instance finiteDimensionalSuprOfFinset {ι : Type _} {f : ι → IntermediateField K L} {s : Finset ι}
    [h : ∀ i ∈ s, FiniteDimensional K (f i)] : FiniteDimensional K (⨆ i ∈ s, f i : IntermediateField K L) := by
  haveI : ∀ i : { i // i ∈ s }, FiniteDimensional K (f i) := fun i => h i i.2
  have : (⨆ i ∈ s, f i) = ⨆ i : { i // i ∈ s }, f i :=
    le_antisymm (supr_le fun i => supr_le fun h => le_supr (fun i : { i // i ∈ s } => f i) ⟨i, h⟩)
      (supr_le fun i => le_supr_of_le i (le_supr_of_le i.2 le_rfl))
  exact this.symm ▸ IntermediateField.finiteDimensionalSuprOfFinite
#align intermediate_field.finite_dimensional_supr_of_finset IntermediateField.finiteDimensionalSuprOfFinset

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- A compositum of algebraic extensions is algebraic -/
theorem isAlgebraicSupr {ι : Type _} {f : ι → IntermediateField K L} (h : ∀ i, Algebra.IsAlgebraic K (f i)) :
    Algebra.IsAlgebraic K (⨆ i, f i : IntermediateField K L) := by
  rintro ⟨x, hx⟩
  obtain ⟨s, hx⟩ := exists_finset_of_mem_supr' hx
  rw [is_algebraic_iff, Subtype.coe_mk, ← Subtype.coe_mk x hx, ← is_algebraic_iff]
  haveI : ∀ i : Σi, f i, FiniteDimensional K K⟮⟯ := fun ⟨i, x⟩ =>
    adjoin.finite_dimensional (is_integral_iff.1 (is_algebraic_iff_is_integral.1 (h i x)))
  apply Algebra.isAlgebraicOfFinite
#align intermediate_field.is_algebraic_supr IntermediateField.isAlgebraicSupr

end Supremum

end IntermediateField

section PowerBasis

variable {K L : Type _} [Field K] [Field L] [Algebra K L]

namespace PowerBasis

open IntermediateField

/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:192:11: unsupported (impossible) -/
/-- `pb.equiv_adjoin_simple` is the equivalence between `K⟮pb.gen⟯` and `L` itself. -/
noncomputable def equivAdjoinSimple (pb : PowerBasis K L) : K⟮⟯ ≃ₐ[K] L :=
  (adjoin.powerBasis pb.isIntegralGen).equivOfMinpoly pb
    (minpoly.eq_of_algebra_map_eq (algebraMap K⟮⟯ L).Injective (adjoin.powerBasis pb.isIntegralGen).isIntegralGen
      (by rw [adjoin.power_basis_gen, adjoin_simple.algebra_map_gen]))
#align power_basis.equiv_adjoin_simple PowerBasis.equivAdjoinSimple

@[simp]
theorem equiv_adjoin_simple_aeval (pb : PowerBasis K L) (f : K[X]) :
    pb.equivAdjoinSimple (aeval (AdjoinSimple.gen K pb.gen) f) = aeval pb.gen f :=
  equiv_of_minpoly_aeval _ pb _ f
#align power_basis.equiv_adjoin_simple_aeval PowerBasis.equiv_adjoin_simple_aeval

@[simp]
theorem equiv_adjoin_simple_gen (pb : PowerBasis K L) : pb.equivAdjoinSimple (AdjoinSimple.gen K pb.gen) = pb.gen :=
  equiv_of_minpoly_gen _ pb _
#align power_basis.equiv_adjoin_simple_gen PowerBasis.equiv_adjoin_simple_gen

@[simp]
theorem equiv_adjoin_simple_symm_aeval (pb : PowerBasis K L) (f : K[X]) :
    pb.equivAdjoinSimple.symm (aeval pb.gen f) = aeval (AdjoinSimple.gen K pb.gen) f := by
  rw [equiv_adjoin_simple, equiv_of_minpoly_symm, equiv_of_minpoly_aeval, adjoin.power_basis_gen]
#align power_basis.equiv_adjoin_simple_symm_aeval PowerBasis.equiv_adjoin_simple_symm_aeval

@[simp]
theorem equiv_adjoin_simple_symm_gen (pb : PowerBasis K L) :
    pb.equivAdjoinSimple.symm pb.gen = AdjoinSimple.gen K pb.gen := by
  rw [equiv_adjoin_simple, equiv_of_minpoly_symm, equiv_of_minpoly_gen, adjoin.power_basis_gen]
#align power_basis.equiv_adjoin_simple_symm_gen PowerBasis.equiv_adjoin_simple_symm_gen

end PowerBasis

end PowerBasis

