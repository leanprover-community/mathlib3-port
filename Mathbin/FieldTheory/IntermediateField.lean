/-
Copyright (c) 2020 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen

! This file was ported from Lean 3 source module field_theory.intermediate_field
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.FieldTheory.Minpoly.Field
import Mathbin.FieldTheory.Subfield
import Mathbin.FieldTheory.Tower

/-!
# Intermediate fields

Let `L / K` be a field extension, given as an instance `algebra K L`.
This file defines the type of fields in between `K` and `L`, `intermediate_field K L`.
An `intermediate_field K L` is a subfield of `L` which contains (the image of) `K`,
i.e. it is a `subfield L` and a `subalgebra K L`.

## Main definitions

* `intermediate_field K L` : the type of intermediate fields between `K` and `L`.
* `subalgebra.to_intermediate_field`: turns a subalgebra closed under `⁻¹`
  into an intermediate field
* `subfield.to_intermediate_field`: turns a subfield containing the image of `K`
  into an intermediate field
* `intermediate_field.map`: map an intermediate field along an `alg_hom`
* `intermediate_field.restrict_scalars`: restrict the scalars of an intermediate field to a smaller
  field in a tower of fields.

## Implementation notes

Intermediate fields are defined with a structure extending `subfield` and `subalgebra`.
A `subalgebra` is closed under all operations except `⁻¹`,

## Tags
intermediate field, field extension
-/


open FiniteDimensional Polynomial

open BigOperators Polynomial

variable (K L L' : Type _) [Field K] [Field L] [Field L'] [Algebra K L] [Algebra K L']

/-- `S : intermediate_field K L` is a subset of `L` such that there is a field
tower `L / S / K`. -/
structure IntermediateField extends Subalgebra K L where
  neg_mem' : ∀ x ∈ carrier, -x ∈ carrier
  inv_mem' : ∀ x ∈ carrier, x⁻¹ ∈ carrier
#align intermediate_field IntermediateField

/-- Reinterpret an `intermediate_field` as a `subalgebra`. -/
add_decl_doc IntermediateField.toSubalgebra

variable {K L L'} (S : IntermediateField K L)

namespace IntermediateField

/-- Reinterpret an `intermediate_field` as a `subfield`. -/
def toSubfield : Subfield L :=
  { S.toSubalgebra, S with }
#align intermediate_field.to_subfield IntermediateField.toSubfield

instance : SetLike (IntermediateField K L) L :=
  ⟨fun S => S.toSubalgebra.carrier, by
    rintro ⟨⟨⟩⟩ ⟨⟨⟩⟩ ⟨h⟩
    congr ⟩

instance : SubfieldClass (IntermediateField K L) L
    where
  add_mem s _ _ := s.add_mem'
  zero_mem s := s.zero_mem'
  neg_mem := neg_mem'
  mul_mem s _ _ := s.mul_mem'
  one_mem s := s.one_mem'
  inv_mem := inv_mem'

@[simp]
theorem mem_carrier {s : IntermediateField K L} {x : L} : x ∈ s.carrier ↔ x ∈ s :=
  Iff.rfl
#align intermediate_field.mem_carrier IntermediateField.mem_carrier

/-- Two intermediate fields are equal if they have the same elements. -/
@[ext]
theorem ext {S T : IntermediateField K L} (h : ∀ x, x ∈ S ↔ x ∈ T) : S = T :=
  SetLike.ext h
#align intermediate_field.ext IntermediateField.ext

@[simp]
theorem coe_to_subalgebra : (S.toSubalgebra : Set L) = S :=
  rfl
#align intermediate_field.coe_to_subalgebra IntermediateField.coe_to_subalgebra

@[simp]
theorem coe_to_subfield : (S.toSubfield : Set L) = S :=
  rfl
#align intermediate_field.coe_to_subfield IntermediateField.coe_to_subfield

@[simp]
theorem mem_mk (s : Set L) (hK : ∀ x, algebraMap K L x ∈ s) (ho hm hz ha hn hi) (x : L) :
    x ∈ IntermediateField.mk (Subalgebra.mk s ho hm hz ha hK) hn hi ↔ x ∈ s :=
  Iff.rfl
#align intermediate_field.mem_mk IntermediateField.mem_mk

@[simp]
theorem mem_to_subalgebra (s : IntermediateField K L) (x : L) : x ∈ s.toSubalgebra ↔ x ∈ s :=
  Iff.rfl
#align intermediate_field.mem_to_subalgebra IntermediateField.mem_to_subalgebra

@[simp]
theorem mem_to_subfield (s : IntermediateField K L) (x : L) : x ∈ s.toSubfield ↔ x ∈ s :=
  Iff.rfl
#align intermediate_field.mem_to_subfield IntermediateField.mem_to_subfield

/-- Copy of an intermediate field with a new `carrier` equal to the old one. Useful to fix
definitional equalities. -/
protected def copy (S : IntermediateField K L) (s : Set L) (hs : s = ↑S) : IntermediateField K L
    where
  toSubalgebra := S.toSubalgebra.copy s (hs : s = S.toSubalgebra.carrier)
  neg_mem' :=
    have hs' : (S.toSubalgebra.copy s hs).carrier = S.toSubalgebra.carrier := hs
    hs'.symm ▸ S.neg_mem'
  inv_mem' :=
    have hs' : (S.toSubalgebra.copy s hs).carrier = S.toSubalgebra.carrier := hs
    hs'.symm ▸ S.inv_mem'
#align intermediate_field.copy IntermediateField.copy

@[simp]
theorem coe_copy (S : IntermediateField K L) (s : Set L) (hs : s = ↑S) :
    (S.copy s hs : Set L) = s :=
  rfl
#align intermediate_field.coe_copy IntermediateField.coe_copy

theorem copy_eq (S : IntermediateField K L) (s : Set L) (hs : s = ↑S) : S.copy s hs = S :=
  SetLike.coe_injective hs
#align intermediate_field.copy_eq IntermediateField.copy_eq

section InheritedLemmas

/-! ### Lemmas inherited from more general structures

The declarations in this section derive from the fact that an `intermediate_field` is also a
subalgebra or subfield. Their use should be replaceable with the corresponding lemma from a
subobject class.
-/


/-- An intermediate field contains the image of the smaller field. -/
theorem algebra_map_mem (x : K) : algebraMap K L x ∈ S :=
  S.algebra_map_mem' x
#align intermediate_field.algebra_map_mem IntermediateField.algebra_map_mem

/-- An intermediate field is closed under scalar multiplication. -/
theorem smul_mem {y : L} : y ∈ S → ∀ {x : K}, x • y ∈ S :=
  S.toSubalgebra.smul_mem
#align intermediate_field.smul_mem IntermediateField.smul_mem

/-- An intermediate field contains the ring's 1. -/
protected theorem one_mem : (1 : L) ∈ S :=
  one_mem S
#align intermediate_field.one_mem IntermediateField.one_mem

/-- An intermediate field contains the ring's 0. -/
protected theorem zero_mem : (0 : L) ∈ S :=
  zero_mem S
#align intermediate_field.zero_mem IntermediateField.zero_mem

/-- An intermediate field is closed under multiplication. -/
protected theorem mul_mem {x y : L} : x ∈ S → y ∈ S → x * y ∈ S :=
  mul_mem
#align intermediate_field.mul_mem IntermediateField.mul_mem

/-- An intermediate field is closed under addition. -/
protected theorem add_mem {x y : L} : x ∈ S → y ∈ S → x + y ∈ S :=
  add_mem
#align intermediate_field.add_mem IntermediateField.add_mem

/-- An intermediate field is closed under subtraction -/
protected theorem sub_mem {x y : L} : x ∈ S → y ∈ S → x - y ∈ S :=
  sub_mem
#align intermediate_field.sub_mem IntermediateField.sub_mem

/-- An intermediate field is closed under negation. -/
protected theorem neg_mem {x : L} : x ∈ S → -x ∈ S :=
  neg_mem
#align intermediate_field.neg_mem IntermediateField.neg_mem

/-- An intermediate field is closed under inverses. -/
protected theorem inv_mem {x : L} : x ∈ S → x⁻¹ ∈ S :=
  inv_mem
#align intermediate_field.inv_mem IntermediateField.inv_mem

/-- An intermediate field is closed under division. -/
protected theorem div_mem {x y : L} : x ∈ S → y ∈ S → x / y ∈ S :=
  div_mem
#align intermediate_field.div_mem IntermediateField.div_mem

/-- Product of a list of elements in an intermediate_field is in the intermediate_field. -/
protected theorem list_prod_mem {l : List L} : (∀ x ∈ l, x ∈ S) → l.Prod ∈ S :=
  list_prod_mem
#align intermediate_field.list_prod_mem IntermediateField.list_prod_mem

/-- Sum of a list of elements in an intermediate field is in the intermediate_field. -/
protected theorem list_sum_mem {l : List L} : (∀ x ∈ l, x ∈ S) → l.Sum ∈ S :=
  list_sum_mem
#align intermediate_field.list_sum_mem IntermediateField.list_sum_mem

/-- Product of a multiset of elements in an intermediate field is in the intermediate_field. -/
protected theorem multiset_prod_mem (m : Multiset L) : (∀ a ∈ m, a ∈ S) → m.Prod ∈ S :=
  multiset_prod_mem m
#align intermediate_field.multiset_prod_mem IntermediateField.multiset_prod_mem

/-- Sum of a multiset of elements in a `intermediate_field` is in the `intermediate_field`. -/
protected theorem multiset_sum_mem (m : Multiset L) : (∀ a ∈ m, a ∈ S) → m.Sum ∈ S :=
  multiset_sum_mem m
#align intermediate_field.multiset_sum_mem IntermediateField.multiset_sum_mem

/-- Product of elements of an intermediate field indexed by a `finset` is in the intermediate_field.
-/
protected theorem prod_mem {ι : Type _} {t : Finset ι} {f : ι → L} (h : ∀ c ∈ t, f c ∈ S) :
    (∏ i in t, f i) ∈ S :=
  prod_mem h
#align intermediate_field.prod_mem IntermediateField.prod_mem

/-- Sum of elements in a `intermediate_field` indexed by a `finset` is in the `intermediate_field`.
-/
protected theorem sum_mem {ι : Type _} {t : Finset ι} {f : ι → L} (h : ∀ c ∈ t, f c ∈ S) :
    (∑ i in t, f i) ∈ S :=
  sum_mem h
#align intermediate_field.sum_mem IntermediateField.sum_mem

protected theorem pow_mem {x : L} (hx : x ∈ S) (n : ℤ) : x ^ n ∈ S :=
  zpow_mem hx n
#align intermediate_field.pow_mem IntermediateField.pow_mem

protected theorem zsmul_mem {x : L} (hx : x ∈ S) (n : ℤ) : n • x ∈ S :=
  zsmul_mem hx n
#align intermediate_field.zsmul_mem IntermediateField.zsmul_mem

protected theorem coe_int_mem (n : ℤ) : (n : L) ∈ S :=
  coe_int_mem S n
#align intermediate_field.coe_int_mem IntermediateField.coe_int_mem

protected theorem coe_add (x y : S) : (↑(x + y) : L) = ↑x + ↑y :=
  rfl
#align intermediate_field.coe_add IntermediateField.coe_add

protected theorem coe_neg (x : S) : (↑(-x) : L) = -↑x :=
  rfl
#align intermediate_field.coe_neg IntermediateField.coe_neg

protected theorem coe_mul (x y : S) : (↑(x * y) : L) = ↑x * ↑y :=
  rfl
#align intermediate_field.coe_mul IntermediateField.coe_mul

protected theorem coe_inv (x : S) : (↑x⁻¹ : L) = (↑x)⁻¹ :=
  rfl
#align intermediate_field.coe_inv IntermediateField.coe_inv

protected theorem coe_zero : ((0 : S) : L) = 0 :=
  rfl
#align intermediate_field.coe_zero IntermediateField.coe_zero

protected theorem coe_one : ((1 : S) : L) = 1 :=
  rfl
#align intermediate_field.coe_one IntermediateField.coe_one

protected theorem coe_pow (x : S) (n : ℕ) : (↑(x ^ n) : L) = ↑x ^ n :=
  SubmonoidClass.coe_pow x n
#align intermediate_field.coe_pow IntermediateField.coe_pow

end InheritedLemmas

theorem coe_nat_mem (n : ℕ) : (n : L) ∈ S := by simpa using coe_int_mem S n
#align intermediate_field.coe_nat_mem IntermediateField.coe_nat_mem

end IntermediateField

/-- Turn a subalgebra closed under inverses into an intermediate field -/
def Subalgebra.toIntermediateField (S : Subalgebra K L) (inv_mem : ∀ x ∈ S, x⁻¹ ∈ S) :
    IntermediateField K L :=
  { S with
    neg_mem' := fun x => S.neg_mem
    inv_mem' := inv_mem }
#align subalgebra.to_intermediate_field Subalgebra.toIntermediateField

@[simp]
theorem to_subalgebra_to_intermediate_field (S : Subalgebra K L) (inv_mem : ∀ x ∈ S, x⁻¹ ∈ S) :
    (S.toIntermediateField inv_mem).toSubalgebra = S :=
  by
  ext
  rfl
#align to_subalgebra_to_intermediate_field to_subalgebra_to_intermediate_field

@[simp]
theorem to_intermediate_field_to_subalgebra (S : IntermediateField K L) :
    (S.toSubalgebra.toIntermediateField fun x => S.inv_mem) = S :=
  by
  ext
  rfl
#align to_intermediate_field_to_subalgebra to_intermediate_field_to_subalgebra

/-- Turn a subalgebra satisfying `is_field` into an intermediate_field -/
def Subalgebra.toIntermediateField' (S : Subalgebra K L) (hS : IsField S) : IntermediateField K L :=
  S.toIntermediateField fun x hx => by
    by_cases hx0 : x = 0
    · rw [hx0, inv_zero]
      exact S.zero_mem
    letI hS' := hS.to_field
    obtain ⟨y, hy⟩ := hS.mul_inv_cancel (show (⟨x, hx⟩ : S) ≠ 0 from Subtype.ne_of_val_ne hx0)
    rw [Subtype.ext_iff, S.coe_mul, S.coe_one, Subtype.coe_mk, mul_eq_one_iff_inv_eq₀ hx0] at hy
    exact hy.symm ▸ y.2
#align subalgebra.to_intermediate_field' Subalgebra.toIntermediateField'

@[simp]
theorem to_subalgebra_to_intermediate_field' (S : Subalgebra K L) (hS : IsField S) :
    (S.toIntermediateField' hS).toSubalgebra = S :=
  by
  ext
  rfl
#align to_subalgebra_to_intermediate_field' to_subalgebra_to_intermediate_field'

@[simp]
theorem to_intermediate_field'_to_subalgebra (S : IntermediateField K L) :
    S.toSubalgebra.toIntermediateField' (Field.toIsField S) = S :=
  by
  ext
  rfl
#align to_intermediate_field'_to_subalgebra to_intermediate_field'_to_subalgebra

/-- Turn a subfield of `L` containing the image of `K` into an intermediate field -/
def Subfield.toIntermediateField (S : Subfield L) (algebra_map_mem : ∀ x, algebraMap K L x ∈ S) :
    IntermediateField K L :=
  { S with algebra_map_mem' := algebra_map_mem }
#align subfield.to_intermediate_field Subfield.toIntermediateField

namespace IntermediateField

/-- An intermediate field inherits a field structure -/
instance toField : Field S :=
  S.toSubfield.toField
#align intermediate_field.to_field IntermediateField.toField

@[simp, norm_cast]
theorem coe_sum {ι : Type _} [Fintype ι] (f : ι → S) : (↑(∑ i, f i) : L) = ∑ i, (f i : L) := by
  classical
    induction' Finset.univ using Finset.induction_on with i s hi H
    · simp
    · rw [Finset.sum_insert hi, AddMemClass.coe_add, H, Finset.sum_insert hi]
#align intermediate_field.coe_sum IntermediateField.coe_sum

@[simp, norm_cast]
theorem coe_prod {ι : Type _} [Fintype ι] (f : ι → S) : (↑(∏ i, f i) : L) = ∏ i, (f i : L) := by
  classical
    induction' Finset.univ using Finset.induction_on with i s hi H
    · simp
    · rw [Finset.prod_insert hi, MulMemClass.coe_mul, H, Finset.prod_insert hi]
#align intermediate_field.coe_prod IntermediateField.coe_prod

/-! `intermediate_field`s inherit structure from their `subalgebra` coercions. -/


instance module' {R} [Semiring R] [SMul R K] [Module R L] [IsScalarTower R K L] : Module R S :=
  S.toSubalgebra.module'
#align intermediate_field.module' IntermediateField.module'

instance module : Module K S :=
  S.toSubalgebra.Module
#align intermediate_field.module IntermediateField.module

instance is_scalar_tower {R} [Semiring R] [SMul R K] [Module R L] [IsScalarTower R K L] :
    IsScalarTower R K S :=
  S.toSubalgebra.IsScalarTower
#align intermediate_field.is_scalar_tower IntermediateField.is_scalar_tower

@[simp]
theorem coe_smul {R} [Semiring R] [SMul R K] [Module R L] [IsScalarTower R K L] (r : R) (x : S) :
    ↑(r • x) = (r • x : L) :=
  rfl
#align intermediate_field.coe_smul IntermediateField.coe_smul

instance algebra' {K'} [CommSemiring K'] [SMul K' K] [Algebra K' L] [IsScalarTower K' K L] :
    Algebra K' S :=
  S.toSubalgebra.algebra'
#align intermediate_field.algebra' IntermediateField.algebra'

instance algebra : Algebra K S :=
  S.toSubalgebra.Algebra
#align intermediate_field.algebra IntermediateField.algebra

instance toAlgebra {R : Type _} [Semiring R] [Algebra L R] : Algebra S R :=
  S.toSubalgebra.toAlgebra
#align intermediate_field.to_algebra IntermediateField.toAlgebra

instance is_scalar_tower_bot {R : Type _} [Semiring R] [Algebra L R] : IsScalarTower S L R :=
  IsScalarTower.subalgebra _ _ _ S.toSubalgebra
#align intermediate_field.is_scalar_tower_bot IntermediateField.is_scalar_tower_bot

instance is_scalar_tower_mid {R : Type _} [Semiring R] [Algebra L R] [Algebra K R]
    [IsScalarTower K L R] : IsScalarTower K S R :=
  IsScalarTower.subalgebra' _ _ _ S.toSubalgebra
#align intermediate_field.is_scalar_tower_mid IntermediateField.is_scalar_tower_mid

/-- Specialize `is_scalar_tower_mid` to the common case where the top field is `L` -/
instance is_scalar_tower_mid' : IsScalarTower K S L :=
  S.is_scalar_tower_mid
#align intermediate_field.is_scalar_tower_mid' IntermediateField.is_scalar_tower_mid'

/-- If `f : L →+* L'` fixes `K`, `S.map f` is the intermediate field between `L'` and `K`
such that `x ∈ S ↔ f x ∈ S.map f`. -/
def map (f : L →ₐ[K] L') (S : IntermediateField K L) : IntermediateField K L' :=
  {
    S.toSubalgebra.map
      f with
    inv_mem' := by
      rintro _ ⟨x, hx, rfl⟩
      exact ⟨x⁻¹, S.inv_mem hx, map_inv₀ f x⟩
    neg_mem' := fun x hx => (S.toSubalgebra.map f).neg_mem hx }
#align intermediate_field.map IntermediateField.map

@[simp]
theorem coe_map (f : L →ₐ[K] L') : (S.map f : Set L') = f '' S :=
  rfl
#align intermediate_field.coe_map IntermediateField.coe_map

theorem map_map {K L₁ L₂ L₃ : Type _} [Field K] [Field L₁] [Algebra K L₁] [Field L₂] [Algebra K L₂]
    [Field L₃] [Algebra K L₃] (E : IntermediateField K L₁) (f : L₁ →ₐ[K] L₂) (g : L₂ →ₐ[K] L₃) :
    (E.map f).map g = E.map (g.comp f) :=
  SetLike.coe_injective <| Set.image_image _ _ _
#align intermediate_field.map_map IntermediateField.map_map

/-- Given an equivalence `e : L ≃ₐ[K] L'` of `K`-field extensions and an intermediate
field `E` of `L/K`, `intermediate_field_equiv_map e E` is the induced equivalence
between `E` and `E.map e` -/
def intermediateFieldMap (e : L ≃ₐ[K] L') (E : IntermediateField K L) : E ≃ₐ[K] E.map e.toAlgHom :=
  e.subalgebraMap E.toSubalgebra
#align intermediate_field.intermediate_field_map IntermediateField.intermediateFieldMap

/- We manually add these two simp lemmas because `@[simps]` before `intermediate_field_map`
  led to a timeout. -/
@[simp]
theorem intermediate_field_map_apply_coe (e : L ≃ₐ[K] L') (E : IntermediateField K L) (a : E) :
    ↑(intermediateFieldMap e E a) = e a :=
  rfl
#align
  intermediate_field.intermediate_field_map_apply_coe IntermediateField.intermediate_field_map_apply_coe

@[simp]
theorem intermediate_field_map_symm_apply_coe (e : L ≃ₐ[K] L') (E : IntermediateField K L)
    (a : E.map e.toAlgHom) : ↑((intermediateFieldMap e E).symm a) = e.symm a :=
  rfl
#align
  intermediate_field.intermediate_field_map_symm_apply_coe IntermediateField.intermediate_field_map_symm_apply_coe

end IntermediateField

namespace AlgHom

variable (f : L →ₐ[K] L')

/-- The range of an algebra homomorphism, as an intermediate field. -/
@[simps toSubalgebra]
def fieldRange : IntermediateField K L' :=
  { f.range, (f : L →+* L').fieldRange with }
#align alg_hom.field_range AlgHom.fieldRange

@[simp]
theorem coe_field_range : ↑f.fieldRange = Set.range f :=
  rfl
#align alg_hom.coe_field_range AlgHom.coe_field_range

@[simp]
theorem field_range_to_subfield : f.fieldRange.toSubfield = (f : L →+* L').fieldRange :=
  rfl
#align alg_hom.field_range_to_subfield AlgHom.field_range_to_subfield

variable {f}

@[simp]
theorem mem_field_range {y : L'} : y ∈ f.fieldRange ↔ ∃ x, f x = y :=
  Iff.rfl
#align alg_hom.mem_field_range AlgHom.mem_field_range

end AlgHom

namespace IntermediateField

/-- The embedding from an intermediate field of `L / K` to `L`. -/
def val : S →ₐ[K] L :=
  S.toSubalgebra.val
#align intermediate_field.val IntermediateField.val

@[simp]
theorem coe_val : ⇑S.val = coe :=
  rfl
#align intermediate_field.coe_val IntermediateField.coe_val

@[simp]
theorem val_mk {x : L} (hx : x ∈ S) : S.val ⟨x, hx⟩ = x :=
  rfl
#align intermediate_field.val_mk IntermediateField.val_mk

theorem range_val : S.val.range = S.toSubalgebra :=
  S.toSubalgebra.range_val
#align intermediate_field.range_val IntermediateField.range_val

theorem aeval_coe {R : Type _} [CommRing R] [Algebra R K] [Algebra R L] [IsScalarTower R K L]
    (x : S) (P : R[X]) : aeval (x : L) P = aeval x P :=
  by
  refine' Polynomial.induction_on' P (fun f g hf hg => _) fun n r => _
  · rw [aeval_add, aeval_add, AddMemClass.coe_add, hf, hg]
  · simp only [MulMemClass.coe_mul, aeval_monomial, SubmonoidClass.coe_pow, mul_eq_mul_right_iff]
    left
    rfl
#align intermediate_field.aeval_coe IntermediateField.aeval_coe

theorem coe_is_integral_iff {R : Type _} [CommRing R] [Algebra R K] [Algebra R L]
    [IsScalarTower R K L] {x : S} : IsIntegral R (x : L) ↔ IsIntegral R x :=
  by
  refine' ⟨fun h => _, fun h => _⟩
  · obtain ⟨P, hPmo, hProot⟩ := h
    refine' ⟨P, hPmo, (injective_iff_map_eq_zero _).1 (algebraMap (↥S) L).Injective _ _⟩
    letI : IsScalarTower R S L := IsScalarTower.of_algebra_map_eq (congr_fun rfl)
    rwa [eval₂_eq_eval_map, ← eval₂_at_apply, eval₂_eq_eval_map, Polynomial.map_map, ←
      IsScalarTower.algebra_map_eq, ← eval₂_eq_eval_map]
  · obtain ⟨P, hPmo, hProot⟩ := h
    refine' ⟨P, hPmo, _⟩
    rw [← aeval_def, aeval_coe, aeval_def, hProot, ZeroMemClass.coe_zero]
#align intermediate_field.coe_is_integral_iff IntermediateField.coe_is_integral_iff

/-- The map `E → F` when `E` is an intermediate field contained in the intermediate field `F`.

This is the intermediate field version of `subalgebra.inclusion`. -/
def inclusion {E F : IntermediateField K L} (hEF : E ≤ F) : E →ₐ[K] F :=
  Subalgebra.inclusion hEF
#align intermediate_field.inclusion IntermediateField.inclusion

theorem inclusion_injective {E F : IntermediateField K L} (hEF : E ≤ F) :
    Function.Injective (inclusion hEF) :=
  Subalgebra.inclusion_injective hEF
#align intermediate_field.inclusion_injective IntermediateField.inclusion_injective

@[simp]
theorem inclusion_self {E : IntermediateField K L} : inclusion (le_refl E) = AlgHom.id K E :=
  Subalgebra.inclusion_self
#align intermediate_field.inclusion_self IntermediateField.inclusion_self

@[simp]
theorem inclusion_inclusion {E F G : IntermediateField K L} (hEF : E ≤ F) (hFG : F ≤ G) (x : E) :
    inclusion hFG (inclusion hEF x) = inclusion (le_trans hEF hFG) x :=
  Subalgebra.inclusion_inclusion hEF hFG x
#align intermediate_field.inclusion_inclusion IntermediateField.inclusion_inclusion

@[simp]
theorem coe_inclusion {E F : IntermediateField K L} (hEF : E ≤ F) (e : E) :
    (inclusion hEF e : L) = e :=
  rfl
#align intermediate_field.coe_inclusion IntermediateField.coe_inclusion

variable {S}

theorem to_subalgebra_injective {S S' : IntermediateField K L}
    (h : S.toSubalgebra = S'.toSubalgebra) : S = S' :=
  by
  ext
  rw [← mem_to_subalgebra, ← mem_to_subalgebra, h]
#align intermediate_field.to_subalgebra_injective IntermediateField.to_subalgebra_injective

variable (S)

theorem set_range_subset : Set.range (algebraMap K L) ⊆ S :=
  S.toSubalgebra.range_subset
#align intermediate_field.set_range_subset IntermediateField.set_range_subset

theorem field_range_le : (algebraMap K L).fieldRange ≤ S.toSubfield := fun x hx =>
  S.toSubalgebra.range_subset (by rwa [Set.mem_range, ← RingHom.mem_field_range])
#align intermediate_field.field_range_le IntermediateField.field_range_le

@[simp]
theorem to_subalgebra_le_to_subalgebra {S S' : IntermediateField K L} :
    S.toSubalgebra ≤ S'.toSubalgebra ↔ S ≤ S' :=
  Iff.rfl
#align
  intermediate_field.to_subalgebra_le_to_subalgebra IntermediateField.to_subalgebra_le_to_subalgebra

@[simp]
theorem to_subalgebra_lt_to_subalgebra {S S' : IntermediateField K L} :
    S.toSubalgebra < S'.toSubalgebra ↔ S < S' :=
  Iff.rfl
#align
  intermediate_field.to_subalgebra_lt_to_subalgebra IntermediateField.to_subalgebra_lt_to_subalgebra

variable {S}

section Tower

/-- Lift an intermediate_field of an intermediate_field -/
def lift {F : IntermediateField K L} (E : IntermediateField K F) : IntermediateField K L :=
  E.map (val F)
#align intermediate_field.lift IntermediateField.lift

instance hasLift {F : IntermediateField K L} :
    HasLiftT (IntermediateField K F) (IntermediateField K L) :=
  ⟨lift⟩
#align intermediate_field.has_lift IntermediateField.hasLift

section RestrictScalars

variable (K) [Algebra L' L] [IsScalarTower K L' L]

/-- Given a tower `L / ↥E / L' / K` of field extensions, where `E` is an `L'`-intermediate field of
`L`, reinterpret `E` as a `K`-intermediate field of `L`. -/
def restrictScalars (E : IntermediateField L' L) : IntermediateField K L :=
  { E.toSubfield, E.toSubalgebra.restrictScalars K with carrier := E.carrier }
#align intermediate_field.restrict_scalars IntermediateField.restrictScalars

@[simp]
theorem coe_restrict_scalars {E : IntermediateField L' L} :
    (restrictScalars K E : Set L) = (E : Set L) :=
  rfl
#align intermediate_field.coe_restrict_scalars IntermediateField.coe_restrict_scalars

@[simp]
theorem restrict_scalars_to_subalgebra {E : IntermediateField L' L} :
    (E.restrictScalars K).toSubalgebra = E.toSubalgebra.restrictScalars K :=
  SetLike.coe_injective rfl
#align
  intermediate_field.restrict_scalars_to_subalgebra IntermediateField.restrict_scalars_to_subalgebra

@[simp]
theorem restrict_scalars_to_subfield {E : IntermediateField L' L} :
    (E.restrictScalars K).toSubfield = E.toSubfield :=
  SetLike.coe_injective rfl
#align
  intermediate_field.restrict_scalars_to_subfield IntermediateField.restrict_scalars_to_subfield

@[simp]
theorem mem_restrict_scalars {E : IntermediateField L' L} {x : L} :
    x ∈ restrictScalars K E ↔ x ∈ E :=
  Iff.rfl
#align intermediate_field.mem_restrict_scalars IntermediateField.mem_restrict_scalars

theorem restrict_scalars_injective :
    Function.Injective (restrictScalars K : IntermediateField L' L → IntermediateField K L) :=
  fun U V H => ext fun x => by rw [← mem_restrict_scalars K, H, mem_restrict_scalars]
#align intermediate_field.restrict_scalars_injective IntermediateField.restrict_scalars_injective

end RestrictScalars

/-- This was formerly an instance called `lift2_alg`, but an instance above already provides it. -/
example {F : IntermediateField K L} {E : IntermediateField F L} : Algebra K E := by infer_instance

end Tower

section FiniteDimensional

variable (F E : IntermediateField K L)

instance finite_dimensional_left [FiniteDimensional K L] : FiniteDimensional K F :=
  left K F L
#align intermediate_field.finite_dimensional_left IntermediateField.finite_dimensional_left

instance finite_dimensional_right [FiniteDimensional K L] : FiniteDimensional F L :=
  right K F L
#align intermediate_field.finite_dimensional_right IntermediateField.finite_dimensional_right

@[simp]
theorem dim_eq_dim_subalgebra : Module.rank K F.toSubalgebra = Module.rank K F :=
  rfl
#align intermediate_field.dim_eq_dim_subalgebra IntermediateField.dim_eq_dim_subalgebra

@[simp]
theorem finrank_eq_finrank_subalgebra : finrank K F.toSubalgebra = finrank K F :=
  rfl
#align
  intermediate_field.finrank_eq_finrank_subalgebra IntermediateField.finrank_eq_finrank_subalgebra

variable {F} {E}

@[simp]
theorem to_subalgebra_eq_iff : F.toSubalgebra = E.toSubalgebra ↔ F = E :=
  by
  rw [SetLike.ext_iff, SetLike.ext'_iff, Set.ext_iff]
  rfl
#align intermediate_field.to_subalgebra_eq_iff IntermediateField.to_subalgebra_eq_iff

theorem eq_of_le_of_finrank_le [FiniteDimensional K L] (h_le : F ≤ E)
    (h_finrank : finrank K E ≤ finrank K F) : F = E :=
  to_subalgebra_injective <|
    Subalgebra.toSubmodule.Injective <| eq_of_le_of_finrank_le h_le h_finrank
#align intermediate_field.eq_of_le_of_finrank_le IntermediateField.eq_of_le_of_finrank_le

theorem eq_of_le_of_finrank_eq [FiniteDimensional K L] (h_le : F ≤ E)
    (h_finrank : finrank K F = finrank K E) : F = E :=
  eq_of_le_of_finrank_le h_le h_finrank.ge
#align intermediate_field.eq_of_le_of_finrank_eq IntermediateField.eq_of_le_of_finrank_eq

theorem eq_of_le_of_finrank_le' [FiniteDimensional K L] (h_le : F ≤ E)
    (h_finrank : finrank F L ≤ finrank E L) : F = E :=
  by
  apply eq_of_le_of_finrank_le h_le
  have h1 := finrank_mul_finrank K F L
  have h2 := finrank_mul_finrank K E L
  have h3 : 0 < finrank E L := finrank_pos
  nlinarith
#align intermediate_field.eq_of_le_of_finrank_le' IntermediateField.eq_of_le_of_finrank_le'

theorem eq_of_le_of_finrank_eq' [FiniteDimensional K L] (h_le : F ≤ E)
    (h_finrank : finrank F L = finrank E L) : F = E :=
  eq_of_le_of_finrank_le' h_le h_finrank.le
#align intermediate_field.eq_of_le_of_finrank_eq' IntermediateField.eq_of_le_of_finrank_eq'

end FiniteDimensional

theorem is_algebraic_iff {x : S} : IsAlgebraic K x ↔ IsAlgebraic K (x : L) :=
  (is_algebraic_algebra_map_iff (algebraMap S L).Injective).symm
#align intermediate_field.is_algebraic_iff IntermediateField.is_algebraic_iff

theorem is_integral_iff {x : S} : IsIntegral K x ↔ IsIntegral K (x : L) := by
  rw [← is_algebraic_iff_is_integral, is_algebraic_iff, is_algebraic_iff_is_integral]
#align intermediate_field.is_integral_iff IntermediateField.is_integral_iff

theorem minpoly_eq (x : S) : minpoly K x = minpoly K (x : L) :=
  by
  by_cases hx : IsIntegral K x
  · exact minpoly.eq_of_algebra_map_eq (algebraMap S L).Injective hx rfl
  · exact (minpoly.eq_zero hx).trans (minpoly.eq_zero (mt is_integral_iff.mpr hx)).symm
#align intermediate_field.minpoly_eq IntermediateField.minpoly_eq

end IntermediateField

/-- If `L/K` is algebraic, the `K`-subalgebras of `L` are all fields.  -/
def subalgebraEquivIntermediateField (alg : Algebra.IsAlgebraic K L) :
    Subalgebra K L ≃o IntermediateField K L
    where
  toFun S := S.toIntermediateField fun x hx => S.inv_mem_of_algebraic (alg (⟨x, hx⟩ : S))
  invFun S := S.toSubalgebra
  left_inv S := to_subalgebra_to_intermediate_field _ _
  right_inv := to_intermediate_field_to_subalgebra
  map_rel_iff' S S' := Iff.rfl
#align subalgebra_equiv_intermediate_field subalgebraEquivIntermediateField

@[simp]
theorem mem_subalgebra_equiv_intermediate_field (alg : Algebra.IsAlgebraic K L) {S : Subalgebra K L}
    {x : L} : x ∈ subalgebraEquivIntermediateField alg S ↔ x ∈ S :=
  Iff.rfl
#align mem_subalgebra_equiv_intermediate_field mem_subalgebra_equiv_intermediate_field

@[simp]
theorem mem_subalgebra_equiv_intermediate_field_symm (alg : Algebra.IsAlgebraic K L)
    {S : IntermediateField K L} {x : L} :
    x ∈ (subalgebraEquivIntermediateField alg).symm S ↔ x ∈ S :=
  Iff.rfl
#align mem_subalgebra_equiv_intermediate_field_symm mem_subalgebra_equiv_intermediate_field_symm

