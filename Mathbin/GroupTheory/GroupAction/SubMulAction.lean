import Mathbin.Algebra.GroupActionHom 
import Mathbin.Algebra.Module.Basic 
import Mathbin.Data.SetLike.Basic 
import Mathbin.GroupTheory.GroupAction.Basic

/-!

# Sets invariant to a `mul_action`

In this file we define `sub_mul_action R M`; a subset of a `mul_action R M` which is closed with
respect to scalar multiplication.

For most uses, typically `submodule R M` is more powerful.

## Main definitions

* `sub_mul_action.mul_action` - the `mul_action R M` transferred to the subtype.
* `sub_mul_action.mul_action'` - the `mul_action S M` transferred to the subtype when
  `is_scalar_tower S R M`.
* `sub_mul_action.is_scalar_tower` - the `is_scalar_tower S R M` transferred to the subtype.

## Tags

submodule, mul_action
-/


open Function

universe u u' u'' v

variable{S : Type u'}{T : Type u''}{R : Type u}{M : Type v}

/-- A sub_mul_action is a set which is closed under scalar multiplication.  -/
structure SubMulAction(R : Type u)(M : Type v)[HasScalar R M] : Type v where 
  Carrier : Set M 
  smul_mem' : ∀ (c : R) {x : M}, x ∈ carrier → c • x ∈ carrier

namespace SubMulAction

variable[HasScalar R M]

instance  : SetLike (SubMulAction R M) M :=
  ⟨SubMulAction.Carrier,
    fun p q h =>
      by 
        cases p <;> cases q <;> congr⟩

@[simp]
theorem mem_carrier {p : SubMulAction R M} {x : M} : x ∈ p.carrier ↔ x ∈ (p : Set M) :=
  Iff.rfl

@[ext]
theorem ext {p q : SubMulAction R M} (h : ∀ x, x ∈ p ↔ x ∈ q) : p = q :=
  SetLike.ext h

/-- Copy of a sub_mul_action with a new `carrier` equal to the old one. Useful to fix definitional
equalities.-/
protected def copy (p : SubMulAction R M) (s : Set M) (hs : s = «expr↑ » p) : SubMulAction R M :=
  { Carrier := s, smul_mem' := hs.symm ▸ p.smul_mem' }

@[simp]
theorem coe_copy (p : SubMulAction R M) (s : Set M) (hs : s = «expr↑ » p) : (p.copy s hs : Set M) = s :=
  rfl

theorem copy_eq (p : SubMulAction R M) (s : Set M) (hs : s = «expr↑ » p) : p.copy s hs = p :=
  SetLike.coe_injective hs

instance  : HasBot (SubMulAction R M) :=
  ⟨{ Carrier := ∅, smul_mem' := fun c => Set.not_mem_empty }⟩

instance  : Inhabited (SubMulAction R M) :=
  ⟨⊥⟩

end SubMulAction

namespace SubMulAction

section HasScalar

variable[HasScalar R M]

variable(p : SubMulAction R M)

variable{r : R}{x : M}

theorem smul_mem (r : R) (h : x ∈ p) : r • x ∈ p :=
  p.smul_mem' r h

instance  : HasScalar R p :=
  { smul := fun c x => ⟨c • x.1, smul_mem _ c x.2⟩ }

variable{p}

@[simp, normCast]
theorem coe_smul (r : R) (x : p) : ((r • x : p) : M) = r • «expr↑ » x :=
  rfl

@[simp, normCast]
theorem coe_mk (x : M) (hx : x ∈ p) : ((⟨x, hx⟩ : p) : M) = x :=
  rfl

variable(p)

/-- Embedding of a submodule `p` to the ambient space `M`. -/
protected def Subtype : p →[R] M :=
  by 
    refine' { toFun := coeₓ, .. } <;> simp [coe_smul]

@[simp]
theorem subtype_apply (x : p) : p.subtype x = x :=
  rfl

theorem subtype_eq_val : (SubMulAction.subtype p : p → M) = Subtype.val :=
  rfl

end HasScalar

section MulAction

variable[Monoidₓ R][MulAction R M]

section 

variable[HasScalar S R][HasScalar S M][IsScalarTower S R M]

variable(p : SubMulAction R M)

theorem smul_of_tower_mem (s : S) {x : M} (h : x ∈ p) : s • x ∈ p :=
  by 
    rw [←one_smul R x, ←smul_assoc]
    exact p.smul_mem _ h

instance has_scalar' : HasScalar S p :=
  { smul := fun c x => ⟨c • x.1, smul_of_tower_mem _ c x.2⟩ }

instance  : IsScalarTower S R p :=
  { smul_assoc := fun s r x => Subtype.ext$ smul_assoc s r («expr↑ » x) }

@[simp, normCast]
theorem coe_smul_of_tower (s : S) (x : p) : ((s • x : p) : M) = s • «expr↑ » x :=
  rfl

@[simp]
theorem smul_mem_iff' {G} [Groupₓ G] [HasScalar G R] [MulAction G M] [IsScalarTower G R M] (g : G) {x : M} :
  g • x ∈ p ↔ x ∈ p :=
  ⟨fun h => inv_smul_smul g x ▸ p.smul_of_tower_mem (g⁻¹) h, p.smul_of_tower_mem g⟩

end 

section 

variable[Monoidₓ S][HasScalar S R][MulAction S M][IsScalarTower S R M]

variable(p : SubMulAction R M)

/-- If the scalar product forms a `mul_action`, then the subset inherits this action -/
instance mul_action' : MulAction S p :=
  { smul := · • ·, one_smul := fun x => Subtype.ext$ one_smul _ x,
    mul_smul := fun c₁ c₂ x => Subtype.ext$ mul_smul c₁ c₂ x }

instance  : MulAction R p :=
  p.mul_action'

end 

end MulAction

section Module

variable[Semiringₓ R][AddCommMonoidₓ M]

variable[Module R M]

variable(p : SubMulAction R M)

theorem zero_mem (h : (p : Set M).Nonempty) : (0 : M) ∈ p :=
  let ⟨x, hx⟩ := h 
  zero_smul R (x : M) ▸ p.smul_mem 0 hx

/-- If the scalar product forms a `module`, and the `sub_mul_action` is not `⊥`, then the
subset inherits the zero. -/
instance  [n_empty : Nonempty p] : HasZero p :=
  { zero := ⟨0, n_empty.elim$ fun x => p.zero_mem ⟨x, x.prop⟩⟩ }

end Module

section AddCommGroupₓ

variable[Ringₓ R][AddCommGroupₓ M]

variable[Module R M]

variable(p p' : SubMulAction R M)

variable{r : R}{x y : M}

theorem neg_mem (hx : x ∈ p) : -x ∈ p :=
  by 
    rw [←neg_one_smul R]
    exact p.smul_mem _ hx

@[simp]
theorem neg_mem_iff : -x ∈ p ↔ x ∈ p :=
  ⟨fun h =>
      by 
        rw [←neg_negₓ x]
        exact neg_mem _ h,
    neg_mem _⟩

instance  : Neg p :=
  ⟨fun x => ⟨-x.1, neg_mem _ x.2⟩⟩

@[simp, normCast]
theorem coe_neg (x : p) : ((-x : p) : M) = -x :=
  rfl

end AddCommGroupₓ

end SubMulAction

namespace SubMulAction

variable[DivisionRing S][Semiringₓ R][MulAction R M]

variable[HasScalar S R][MulAction S M][IsScalarTower S R M]

variable(p : SubMulAction R M){s : S}{x y : M}

theorem smul_mem_iff (s0 : s ≠ 0) : s • x ∈ p ↔ x ∈ p :=
  p.smul_mem_iff' (Units.mk0 s s0)

end SubMulAction

