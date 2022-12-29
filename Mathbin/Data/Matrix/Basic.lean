/-
Copyright (c) 2018 Ellen Arlt. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ellen Arlt, Blair Shi, Sean Leather, Mario Carneiro, Johan Commelin, Lu-Ming Zhang

! This file was ported from Lean 3 source module data.matrix.basic
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Pi
import Mathbin.Algebra.BigOperators.Pi
import Mathbin.Algebra.BigOperators.Ring
import Mathbin.Algebra.BigOperators.RingEquiv
import Mathbin.Algebra.Module.LinearMap
import Mathbin.Algebra.Module.Pi
import Mathbin.Algebra.Star.BigOperators
import Mathbin.Algebra.Star.Module
import Mathbin.Algebra.Star.Pi
import Mathbin.Data.Fintype.BigOperators

/-!
# Matrices

This file defines basic properties of matrices.

Matrices with rows indexed by `m`, columns indexed by `n`, and entries of type `α` are represented
with `matrix m n α`. For the typical approach of counting rows and columns,
`matrix (fin m) (fin n) α` can be used.

## Notation

The locale `matrix` gives the following notation:

* `⬝ᵥ` for `matrix.dot_product`
* `⬝` for `matrix.mul`
* `ᵀ` for `matrix.transpose`
* `ᴴ` for `matrix.conj_transpose`

## Implementation notes

For convenience, `matrix m n α` is defined as `m → n → α`, as this allows elements of the matrix
to be accessed with `A i j`. However, it is not advisable to _construct_ matrices using terms of the
form `λ i j, _` or even `(λ i j, _ : matrix m n α)`, as these are not recognized by lean as having
the right type. Instead, `matrix.of` should be used.

## TODO

Under various conditions, multiplication of infinite matrices makes sense.
These have not yet been implemented.
-/


universe u u' v w

open BigOperators

/-- `matrix m n R` is the type of matrices with entries in `R`, whose rows are indexed by `m`
and whose columns are indexed by `n`. -/
def Matrix (m : Type u) (n : Type u') (α : Type v) : Type max u u' v :=
  m → n → α
#align matrix Matrix

variable {l m n o : Type _} {m' : o → Type _} {n' : o → Type _}

variable {R : Type _} {S : Type _} {α : Type v} {β : Type w} {γ : Type _}

namespace Matrix

section Ext

variable {M N : Matrix m n α}

theorem ext_iff : (∀ i j, M i j = N i j) ↔ M = N :=
  ⟨fun h => funext fun i => funext <| h i, fun h => by simp [h]⟩
#align matrix.ext_iff Matrix.ext_iff

@[ext]
theorem ext : (∀ i j, M i j = N i j) → M = N :=
  ext_iff.mp
#align matrix.ext Matrix.ext

end Ext

/-- Cast a function into a matrix.

The two sides of the equivalence are definitionally equal types. We want to use an explicit cast
to distinguish the types because `matrix` has different instances to pi types (such as `pi.has_mul`,
which performs elementwise multiplication, vs `matrix.has_mul`).

If you are defining a matrix, in terms of its entries, either use `of (λ i j, _)`, or use pattern
matching in a definition as `| i j := _` (which can only be unfolded when fully-applied). The
purpose of this approach is to ensure that terms of the form `(λ i j, _) * (λ i j, _)` do not
appear, as the type of `*` can be misleading.
-/
def of : (m → n → α) ≃ Matrix m n α :=
  Equiv.refl _
#align matrix.of Matrix.of

@[simp]
theorem of_apply (f : m → n → α) (i j) : of f i j = f i j :=
  rfl
#align matrix.of_apply Matrix.of_apply

@[simp]
theorem of_symm_apply (f : Matrix m n α) (i j) : of.symm f i j = f i j :=
  rfl
#align matrix.of_symm_apply Matrix.of_symm_apply

/-- `M.map f` is the matrix obtained by applying `f` to each entry of the matrix `M`.

This is available in bundled forms as:
* `add_monoid_hom.map_matrix`
* `linear_map.map_matrix`
* `ring_hom.map_matrix`
* `alg_hom.map_matrix`
* `equiv.map_matrix`
* `add_equiv.map_matrix`
* `linear_equiv.map_matrix`
* `ring_equiv.map_matrix`
* `alg_equiv.map_matrix`
-/
def map (M : Matrix m n α) (f : α → β) : Matrix m n β :=
  of fun i j => f (M i j)
#align matrix.map Matrix.map

@[simp]
theorem map_apply {M : Matrix m n α} {f : α → β} {i : m} {j : n} : M.map f i j = f (M i j) :=
  rfl
#align matrix.map_apply Matrix.map_apply

@[simp]
theorem map_id (M : Matrix m n α) : M.map id = M :=
  by
  ext
  rfl
#align matrix.map_id Matrix.map_id

@[simp]
theorem map_map {M : Matrix m n α} {β γ : Type _} {f : α → β} {g : β → γ} :
    (M.map f).map g = M.map (g ∘ f) := by
  ext
  rfl
#align matrix.map_map Matrix.map_map

theorem map_injective {f : α → β} (hf : Function.Injective f) :
    Function.Injective fun M : Matrix m n α => M.map f := fun M N h =>
  ext fun i j => hf <| ext_iff.mpr h i j
#align matrix.map_injective Matrix.map_injective

/- warning: matrix.transpose -> Matrix.transpose is a dubious translation:
lean 3 declaration is
  forall {m : Type.{u2}} {n : Type.{u3}} {α : Type.{u1}}, (Matrix.{u2, u3, u1} m n α) -> (Matrix.{u3, u2, u1} n m α)
but is expected to have type
  forall {m : Type.{u1}} {n : Type.{u2}} {α : Type.{u3}}, (Matrix.{u1, u2, u3} m n α) -> (Matrix.{u2, u1, u3} n m α)
Case conversion may be inaccurate. Consider using '#align matrix.transpose Matrix.transposeₓ'. -/
/-- The transpose of a matrix. -/
def transpose (M : Matrix m n α) : Matrix n m α
  | x, y => M y x
#align matrix.transpose Matrix.transpose

-- mathport name: matrix.transpose
scoped postfix:1024 "ᵀ" => Matrix.transpose

/-- The conjugate transpose of a matrix defined in term of `star`. -/
def conjTranspose [HasStar α] (M : Matrix m n α) : Matrix n m α :=
  M.transpose.map star
#align matrix.conj_transpose Matrix.conjTranspose

-- mathport name: matrix.conj_transpose
scoped postfix:1024 "ᴴ" => Matrix.conjTranspose

/- warning: matrix.col -> Matrix.col is a dubious translation:
lean 3 declaration is
  forall {m : Type.{u2}} {α : Type.{u1}}, (m -> α) -> (Matrix.{u2, 0, u1} m Unit α)
but is expected to have type
  forall {m : Type.{u1}} {α : Type.{u2}}, (m -> α) -> (Matrix.{u1, 0, u2} m Unit α)
Case conversion may be inaccurate. Consider using '#align matrix.col Matrix.colₓ'. -/
/-- `matrix.col u` is the column matrix whose entries are given by `u`. -/
def col (w : m → α) : Matrix m Unit α
  | x, y => w x
#align matrix.col Matrix.col

/- warning: matrix.row -> Matrix.row is a dubious translation:
lean 3 declaration is
  forall {n : Type.{u2}} {α : Type.{u1}}, (n -> α) -> (Matrix.{0, u2, u1} Unit n α)
but is expected to have type
  forall {n : Type.{u1}} {α : Type.{u2}}, (n -> α) -> (Matrix.{0, u1, u2} Unit n α)
Case conversion may be inaccurate. Consider using '#align matrix.row Matrix.rowₓ'. -/
/-- `matrix.row u` is the row matrix whose entries are given by `u`. -/
def row (v : n → α) : Matrix Unit n α
  | x, y => v y
#align matrix.row Matrix.row

instance [Inhabited α] : Inhabited (Matrix m n α) :=
  Pi.inhabited _

instance [Add α] : Add (Matrix m n α) :=
  Pi.instAdd

instance [AddSemigroup α] : AddSemigroup (Matrix m n α) :=
  Pi.addSemigroup

instance [AddCommSemigroup α] : AddCommSemigroup (Matrix m n α) :=
  Pi.addCommSemigroup

instance [Zero α] : Zero (Matrix m n α) :=
  Pi.instZero

instance [AddZeroClass α] : AddZeroClass (Matrix m n α) :=
  Pi.addZeroClass

instance [AddMonoid α] : AddMonoid (Matrix m n α) :=
  Pi.addMonoid

instance [AddCommMonoid α] : AddCommMonoid (Matrix m n α) :=
  Pi.addCommMonoid

instance [Neg α] : Neg (Matrix m n α) :=
  Pi.instNeg

instance [Sub α] : Sub (Matrix m n α) :=
  Pi.instSub

instance [AddGroup α] : AddGroup (Matrix m n α) :=
  Pi.addGroup

instance [AddCommGroup α] : AddCommGroup (Matrix m n α) :=
  Pi.addCommGroup

instance [Unique α] : Unique (Matrix m n α) :=
  Pi.unique

instance [Subsingleton α] : Subsingleton (Matrix m n α) :=
  Pi.subsingleton

instance [Nonempty m] [Nonempty n] [Nontrivial α] : Nontrivial (Matrix m n α) :=
  Function.nontrivial

instance [HasSmul R α] : HasSmul R (Matrix m n α) :=
  Pi.instSMul

instance [HasSmul R α] [HasSmul S α] [SMulCommClass R S α] : SMulCommClass R S (Matrix m n α) :=
  Pi.smulCommClass

instance [HasSmul R S] [HasSmul R α] [HasSmul S α] [IsScalarTower R S α] :
    IsScalarTower R S (Matrix m n α) :=
  Pi.isScalarTower

instance [HasSmul R α] [HasSmul Rᵐᵒᵖ α] [IsCentralScalar R α] : IsCentralScalar R (Matrix m n α) :=
  Pi.is_central_scalar

instance [Monoid R] [MulAction R α] : MulAction R (Matrix m n α) :=
  Pi.mulAction _

instance [Monoid R] [AddMonoid α] [DistribMulAction R α] : DistribMulAction R (Matrix m n α) :=
  Pi.distribMulAction _

instance [Semiring R] [AddCommMonoid α] [Module R α] : Module R (Matrix m n α) :=
  Pi.module _ _ _

/-! simp-normal form pulls `of` to the outside. -/


@[simp]
theorem of_zero [Zero α] : of (0 : m → n → α) = 0 :=
  rfl
#align matrix.of_zero Matrix.of_zero

@[simp]
theorem of_add_of [Add α] (f g : m → n → α) : of f + of g = of (f + g) :=
  rfl
#align matrix.of_add_of Matrix.of_add_of

@[simp]
theorem of_sub_of [Sub α] (f g : m → n → α) : of f - of g = of (f - g) :=
  rfl
#align matrix.of_sub_of Matrix.of_sub_of

@[simp]
theorem neg_of [Neg α] (f : m → n → α) : -of f = of (-f) :=
  rfl
#align matrix.neg_of Matrix.neg_of

@[simp]
theorem smul_of [HasSmul R α] (r : R) (f : m → n → α) : r • of f = of (r • f) :=
  rfl
#align matrix.smul_of Matrix.smul_of

@[simp]
protected theorem map_zero [Zero α] [Zero β] (f : α → β) (h : f 0 = 0) :
    (0 : Matrix m n α).map f = 0 := by
  ext
  simp [h]
#align matrix.map_zero Matrix.map_zero

protected theorem map_add [Add α] [Add β] (f : α → β) (hf : ∀ a₁ a₂, f (a₁ + a₂) = f a₁ + f a₂)
    (M N : Matrix m n α) : (M + N).map f = M.map f + N.map f :=
  ext fun _ _ => hf _ _
#align matrix.map_add Matrix.map_add

protected theorem map_sub [Sub α] [Sub β] (f : α → β) (hf : ∀ a₁ a₂, f (a₁ - a₂) = f a₁ - f a₂)
    (M N : Matrix m n α) : (M - N).map f = M.map f - N.map f :=
  ext fun _ _ => hf _ _
#align matrix.map_sub Matrix.map_sub

theorem map_smul [HasSmul R α] [HasSmul R β] (f : α → β) (r : R) (hf : ∀ a, f (r • a) = r • f a)
    (M : Matrix m n α) : (r • M).map f = r • M.map f :=
  ext fun _ _ => hf _
#align matrix.map_smul Matrix.map_smul

/-- The scalar action via `has_mul.to_has_smul` is transformed by the same map as the elements
of the matrix, when `f` preserves multiplication. -/
theorem map_smul' [Mul α] [Mul β] (f : α → β) (r : α) (A : Matrix n n α)
    (hf : ∀ a₁ a₂, f (a₁ * a₂) = f a₁ * f a₂) : (r • A).map f = f r • A.map f :=
  ext fun _ _ => hf _ _
#align matrix.map_smul' Matrix.map_smul'

/-- The scalar action via `has_mul.to_has_opposite_smul` is transformed by the same map as the
elements of the matrix, when `f` preserves multiplication. -/
theorem map_op_smul' [Mul α] [Mul β] (f : α → β) (r : α) (A : Matrix n n α)
    (hf : ∀ a₁ a₂, f (a₁ * a₂) = f a₁ * f a₂) :
    (MulOpposite.op r • A).map f = MulOpposite.op (f r) • A.map f :=
  ext fun _ _ => hf _ _
#align matrix.map_op_smul' Matrix.map_op_smul'

theorem IsSMulRegular.matrix [HasSmul R S] {k : R} (hk : IsSMulRegular S k) :
    IsSMulRegular (Matrix m n S) k :=
  IsSMulRegular.pi fun _ => IsSMulRegular.pi fun _ => hk
#align is_smul_regular.matrix IsSMulRegular.matrix

theorem IsLeftRegular.matrix [Mul α] {k : α} (hk : IsLeftRegular k) :
    IsSMulRegular (Matrix m n α) k :=
  hk.IsSmulRegular.Matrix
#align is_left_regular.matrix IsLeftRegular.matrix

instance subsingleton_of_empty_left [IsEmpty m] : Subsingleton (Matrix m n α) :=
  ⟨fun M N => by
    ext
    exact isEmptyElim i⟩
#align matrix.subsingleton_of_empty_left Matrix.subsingleton_of_empty_left

instance subsingleton_of_empty_right [IsEmpty n] : Subsingleton (Matrix m n α) :=
  ⟨fun M N => by
    ext
    exact isEmptyElim j⟩
#align matrix.subsingleton_of_empty_right Matrix.subsingleton_of_empty_right

end Matrix

open Matrix

namespace Matrix

section Diagonal

variable [DecidableEq n]

/- warning: matrix.diagonal -> Matrix.diagonal is a dubious translation:
lean 3 declaration is
  forall {n : Type.{u2}} {α : Type.{u1}} [_inst_1 : DecidableEq.{succ u2} n] [_inst_2 : Zero.{u1} α], (n -> α) -> (Matrix.{u2, u2, u1} n n α)
but is expected to have type
  forall {n : Type.{u1}} {α : Type.{u2}} [_inst_1 : DecidableEq.{succ u1} n] [_inst_2 : Zero.{u2} α], (n -> α) -> (Matrix.{u1, u1, u2} n n α)
Case conversion may be inaccurate. Consider using '#align matrix.diagonal Matrix.diagonalₓ'. -/
/-- `diagonal d` is the square matrix such that `(diagonal d) i i = d i` and `(diagonal d) i j = 0`
if `i ≠ j`.

Note that bundled versions exist as:
* `matrix.diagonal_add_monoid_hom`
* `matrix.diagonal_linear_map`
* `matrix.diagonal_ring_hom`
* `matrix.diagonal_alg_hom`
-/
def diagonal [Zero α] (d : n → α) : Matrix n n α
  | i, j => if i = j then d i else 0
#align matrix.diagonal Matrix.diagonal

@[simp]
theorem diagonal_apply_eq [Zero α] (d : n → α) (i : n) : (diagonal d) i i = d i := by
  simp [diagonal]
#align matrix.diagonal_apply_eq Matrix.diagonal_apply_eq

@[simp]
theorem diagonal_apply_ne [Zero α] (d : n → α) {i j : n} (h : i ≠ j) : (diagonal d) i j = 0 := by
  simp [diagonal, h]
#align matrix.diagonal_apply_ne Matrix.diagonal_apply_ne

theorem diagonal_apply_ne' [Zero α] (d : n → α) {i j : n} (h : j ≠ i) : (diagonal d) i j = 0 :=
  diagonal_apply_ne d h.symm
#align matrix.diagonal_apply_ne' Matrix.diagonal_apply_ne'

@[simp]
theorem diagonal_eq_diagonal_iff [Zero α] {d₁ d₂ : n → α} :
    diagonal d₁ = diagonal d₂ ↔ ∀ i, d₁ i = d₂ i :=
  ⟨fun h i => by simpa using congr_arg (fun m : Matrix n n α => m i i) h, fun h => by
    rw [show d₁ = d₂ from funext h]⟩
#align matrix.diagonal_eq_diagonal_iff Matrix.diagonal_eq_diagonal_iff

theorem diagonal_injective [Zero α] : Function.Injective (diagonal : (n → α) → Matrix n n α) :=
  fun d₁ d₂ h => funext fun i => by simpa using matrix.ext_iff.mpr h i i
#align matrix.diagonal_injective Matrix.diagonal_injective

@[simp]
theorem diagonal_zero [Zero α] : (diagonal fun _ => 0 : Matrix n n α) = 0 :=
  by
  ext
  simp [diagonal]
#align matrix.diagonal_zero Matrix.diagonal_zero

@[simp]
theorem diagonal_transpose [Zero α] (v : n → α) : (diagonal v)ᵀ = diagonal v :=
  by
  ext (i j)
  by_cases h : i = j
  · simp [h, transpose]
  · simp [h, transpose, diagonal_apply_ne' _ h]
#align matrix.diagonal_transpose Matrix.diagonal_transpose

@[simp]
theorem diagonal_add [AddZeroClass α] (d₁ d₂ : n → α) :
    diagonal d₁ + diagonal d₂ = diagonal fun i => d₁ i + d₂ i := by
  ext (i j) <;> by_cases h : i = j <;> simp [h]
#align matrix.diagonal_add Matrix.diagonal_add

@[simp]
theorem diagonal_smul [Monoid R] [AddMonoid α] [DistribMulAction R α] (r : R) (d : n → α) :
    diagonal (r • d) = r • diagonal d := by ext (i j) <;> by_cases h : i = j <;> simp [h]
#align matrix.diagonal_smul Matrix.diagonal_smul

variable (n α)

/-- `matrix.diagonal` as an `add_monoid_hom`. -/
@[simps]
def diagonalAddMonoidHom [AddZeroClass α] : (n → α) →+ Matrix n n α
    where
  toFun := diagonal
  map_zero' := diagonal_zero
  map_add' x y := (diagonal_add x y).symm
#align matrix.diagonal_add_monoid_hom Matrix.diagonalAddMonoidHom

variable (R)

/-- `matrix.diagonal` as a `linear_map`. -/
@[simps]
def diagonalLinearMap [Semiring R] [AddCommMonoid α] [Module R α] : (n → α) →ₗ[R] Matrix n n α :=
  { diagonalAddMonoidHom n α with map_smul' := diagonal_smul }
#align matrix.diagonal_linear_map Matrix.diagonalLinearMap

variable {n α R}

@[simp]
theorem diagonal_map [Zero α] [Zero β] {f : α → β} (h : f 0 = 0) {d : n → α} :
    (diagonal d).map f = diagonal fun m => f (d m) :=
  by
  ext
  simp only [diagonal, map_apply]
  split_ifs <;> simp [h]
#align matrix.diagonal_map Matrix.diagonal_map

@[simp]
theorem diagonal_conj_transpose [AddMonoid α] [StarAddMonoid α] (v : n → α) :
    (diagonal v)ᴴ = diagonal (star v) :=
  by
  rw [conj_transpose, diagonal_transpose, diagonal_map (star_zero _)]
  rfl
#align matrix.diagonal_conj_transpose Matrix.diagonal_conj_transpose

section One

variable [Zero α] [One α]

instance : One (Matrix n n α) :=
  ⟨diagonal fun _ => 1⟩

@[simp]
theorem diagonal_one : (diagonal fun _ => 1 : Matrix n n α) = 1 :=
  rfl
#align matrix.diagonal_one Matrix.diagonal_one

theorem one_apply {i j} : (1 : Matrix n n α) i j = if i = j then 1 else 0 :=
  rfl
#align matrix.one_apply Matrix.one_apply

@[simp]
theorem one_apply_eq (i) : (1 : Matrix n n α) i i = 1 :=
  diagonal_apply_eq _ i
#align matrix.one_apply_eq Matrix.one_apply_eq

@[simp]
theorem one_apply_ne {i j} : i ≠ j → (1 : Matrix n n α) i j = 0 :=
  diagonal_apply_ne _
#align matrix.one_apply_ne Matrix.one_apply_ne

theorem one_apply_ne' {i j} : j ≠ i → (1 : Matrix n n α) i j = 0 :=
  diagonal_apply_ne' _
#align matrix.one_apply_ne' Matrix.one_apply_ne'

@[simp]
theorem map_one [Zero β] [One β] (f : α → β) (h₀ : f 0 = 0) (h₁ : f 1 = 1) :
    (1 : Matrix n n α).map f = (1 : Matrix n n β) :=
  by
  ext
  simp only [one_apply, map_apply]
  split_ifs <;> simp [h₀, h₁]
#align matrix.map_one Matrix.map_one

theorem one_eq_pi_single {i j} : (1 : Matrix n n α) i j = Pi.single i 1 j := by
  simp only [one_apply, Pi.single_apply, eq_comm] <;> congr
#align matrix.one_eq_pi_single Matrix.one_eq_pi_single

-- deal with decidable_eq
end One

section Numeral

@[simp]
theorem bit0_apply [Add α] (M : Matrix m m α) (i : m) (j : m) : (bit0 M) i j = bit0 (M i j) :=
  rfl
#align matrix.bit0_apply Matrix.bit0_apply

variable [AddZeroClass α] [One α]

theorem bit1_apply (M : Matrix n n α) (i : n) (j : n) :
    (bit1 M) i j = if i = j then bit1 (M i j) else bit0 (M i j) := by
  dsimp [bit1] <;> by_cases h : i = j <;> simp [h]
#align matrix.bit1_apply Matrix.bit1_apply

@[simp]
theorem bit1_apply_eq (M : Matrix n n α) (i : n) : (bit1 M) i i = bit1 (M i i) := by
  simp [bit1_apply]
#align matrix.bit1_apply_eq Matrix.bit1_apply_eq

@[simp]
theorem bit1_apply_ne (M : Matrix n n α) {i j : n} (h : i ≠ j) : (bit1 M) i j = bit0 (M i j) := by
  simp [bit1_apply, h]
#align matrix.bit1_apply_ne Matrix.bit1_apply_ne

end Numeral

end Diagonal

section Diag

/-- The diagonal of a square matrix. -/
@[simp]
def diag (A : Matrix n n α) (i : n) : α :=
  A i i
#align matrix.diag Matrix.diag

@[simp]
theorem diag_diagonal [DecidableEq n] [Zero α] (a : n → α) : diag (diagonal a) = a :=
  funext <| @diagonal_apply_eq _ _ _ _ a
#align matrix.diag_diagonal Matrix.diag_diagonal

@[simp]
theorem diag_transpose (A : Matrix n n α) : diag Aᵀ = diag A :=
  rfl
#align matrix.diag_transpose Matrix.diag_transpose

@[simp]
theorem diag_zero [Zero α] : diag (0 : Matrix n n α) = 0 :=
  rfl
#align matrix.diag_zero Matrix.diag_zero

@[simp]
theorem diag_add [Add α] (A B : Matrix n n α) : diag (A + B) = diag A + diag B :=
  rfl
#align matrix.diag_add Matrix.diag_add

@[simp]
theorem diag_sub [Sub α] (A B : Matrix n n α) : diag (A - B) = diag A - diag B :=
  rfl
#align matrix.diag_sub Matrix.diag_sub

@[simp]
theorem diag_neg [Neg α] (A : Matrix n n α) : diag (-A) = -diag A :=
  rfl
#align matrix.diag_neg Matrix.diag_neg

@[simp]
theorem diag_smul [HasSmul R α] (r : R) (A : Matrix n n α) : diag (r • A) = r • diag A :=
  rfl
#align matrix.diag_smul Matrix.diag_smul

@[simp]
theorem diag_one [DecidableEq n] [Zero α] [One α] : diag (1 : Matrix n n α) = 1 :=
  diag_diagonal _
#align matrix.diag_one Matrix.diag_one

variable (n α)

/-- `matrix.diag` as an `add_monoid_hom`. -/
@[simps]
def diagAddMonoidHom [AddZeroClass α] : Matrix n n α →+ n → α
    where
  toFun := diag
  map_zero' := diag_zero
  map_add' := diag_add
#align matrix.diag_add_monoid_hom Matrix.diagAddMonoidHom

variable (R)

/-- `matrix.diag` as a `linear_map`. -/
@[simps]
def diagLinearMap [Semiring R] [AddCommMonoid α] [Module R α] : Matrix n n α →ₗ[R] n → α :=
  { diagAddMonoidHom n α with map_smul' := diag_smul }
#align matrix.diag_linear_map Matrix.diagLinearMap

variable {n α R}

theorem diag_map {f : α → β} {A : Matrix n n α} : diag (A.map f) = f ∘ diag A :=
  rfl
#align matrix.diag_map Matrix.diag_map

@[simp]
theorem diag_conj_transpose [AddMonoid α] [StarAddMonoid α] (A : Matrix n n α) :
    diag Aᴴ = star (diag A) :=
  rfl
#align matrix.diag_conj_transpose Matrix.diag_conj_transpose

@[simp]
theorem diag_list_sum [AddMonoid α] (l : List (Matrix n n α)) : diag l.Sum = (l.map diag).Sum :=
  map_list_sum (diagAddMonoidHom n α) l
#align matrix.diag_list_sum Matrix.diag_list_sum

@[simp]
theorem diag_multiset_sum [AddCommMonoid α] (s : Multiset (Matrix n n α)) :
    diag s.Sum = (s.map diag).Sum :=
  map_multiset_sum (diagAddMonoidHom n α) s
#align matrix.diag_multiset_sum Matrix.diag_multiset_sum

@[simp]
theorem diag_sum {ι} [AddCommMonoid α] (s : Finset ι) (f : ι → Matrix n n α) :
    diag (∑ i in s, f i) = ∑ i in s, diag (f i) :=
  map_sum (diagAddMonoidHom n α) f s
#align matrix.diag_sum Matrix.diag_sum

end Diag

section DotProduct

variable [Fintype m] [Fintype n]

/-- `dot_product v w` is the sum of the entrywise products `v i * w i` -/
def dotProduct [Mul α] [AddCommMonoid α] (v w : m → α) : α :=
  ∑ i, v i * w i
#align matrix.dot_product Matrix.dotProduct

-- mathport name: matrix.dot_product
/- The precedence of 72 comes immediately after ` • ` for `has_smul.smul`,
   so that `r₁ • a ⬝ᵥ r₂ • b` is parsed as `(r₁ • a) ⬝ᵥ (r₂ • b)` here. -/
scoped infixl:72 " ⬝ᵥ " => Matrix.dotProduct

theorem dot_product_assoc [NonUnitalSemiring α] (u : m → α) (w : n → α) (v : Matrix m n α) :
    (fun j => u ⬝ᵥ fun i => v i j) ⬝ᵥ w = u ⬝ᵥ fun i => v i ⬝ᵥ w := by
  simpa [dot_product, Finset.mul_sum, Finset.sum_mul, mul_assoc] using Finset.sum_comm
#align matrix.dot_product_assoc Matrix.dot_product_assoc

theorem dot_product_comm [AddCommMonoid α] [CommSemigroup α] (v w : m → α) : v ⬝ᵥ w = w ⬝ᵥ v := by
  simp_rw [dot_product, mul_comm]
#align matrix.dot_product_comm Matrix.dot_product_comm

@[simp]
theorem dot_product_punit [AddCommMonoid α] [Mul α] (v w : PUnit → α) : v ⬝ᵥ w = v ⟨⟩ * w ⟨⟩ := by
  simp [dot_product]
#align matrix.dot_product_punit Matrix.dot_product_punit

section NonUnitalNonAssocSemiring

variable [NonUnitalNonAssocSemiring α] (u v w : m → α) (x y : n → α)

@[simp]
theorem dot_product_zero : v ⬝ᵥ 0 = 0 := by simp [dot_product]
#align matrix.dot_product_zero Matrix.dot_product_zero

@[simp]
theorem dot_product_zero' : (v ⬝ᵥ fun _ => 0) = 0 :=
  dot_product_zero v
#align matrix.dot_product_zero' Matrix.dot_product_zero'

@[simp]
theorem zero_dot_product : 0 ⬝ᵥ v = 0 := by simp [dot_product]
#align matrix.zero_dot_product Matrix.zero_dot_product

@[simp]
theorem zero_dot_product' : (fun _ => (0 : α)) ⬝ᵥ v = 0 :=
  zero_dot_product v
#align matrix.zero_dot_product' Matrix.zero_dot_product'

@[simp]
theorem add_dot_product : (u + v) ⬝ᵥ w = u ⬝ᵥ w + v ⬝ᵥ w := by
  simp [dot_product, add_mul, Finset.sum_add_distrib]
#align matrix.add_dot_product Matrix.add_dot_product

@[simp]
theorem dot_product_add : u ⬝ᵥ (v + w) = u ⬝ᵥ v + u ⬝ᵥ w := by
  simp [dot_product, mul_add, Finset.sum_add_distrib]
#align matrix.dot_product_add Matrix.dot_product_add

@[simp]
theorem sum_elim_dot_product_sum_elim : Sum.elim u x ⬝ᵥ Sum.elim v y = u ⬝ᵥ v + x ⬝ᵥ y := by
  simp [dot_product]
#align matrix.sum_elim_dot_product_sum_elim Matrix.sum_elim_dot_product_sum_elim

end NonUnitalNonAssocSemiring

section NonUnitalNonAssocSemiringDecidable

variable [DecidableEq m] [NonUnitalNonAssocSemiring α] (u v w : m → α)

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (j «expr ≠ » i) -/
@[simp]
theorem diagonal_dot_product (i : m) : diagonal v i ⬝ᵥ w = v i * w i :=
  by
  have : ∀ (j) (_ : j ≠ i), diagonal v i j * w j = 0 := fun j hij => by
    simp [diagonal_apply_ne' _ hij]
  convert Finset.sum_eq_single i (fun j _ => this j) _ using 1 <;> simp
#align matrix.diagonal_dot_product Matrix.diagonal_dot_product

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (j «expr ≠ » i) -/
@[simp]
theorem dot_product_diagonal (i : m) : v ⬝ᵥ diagonal w i = v i * w i :=
  by
  have : ∀ (j) (_ : j ≠ i), v j * diagonal w i j = 0 := fun j hij => by
    simp [diagonal_apply_ne' _ hij]
  convert Finset.sum_eq_single i (fun j _ => this j) _ using 1 <;> simp
#align matrix.dot_product_diagonal Matrix.dot_product_diagonal

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (j «expr ≠ » i) -/
@[simp]
theorem dot_product_diagonal' (i : m) : (v ⬝ᵥ fun j => diagonal w j i) = v i * w i :=
  by
  have : ∀ (j) (_ : j ≠ i), v j * diagonal w j i = 0 := fun j hij => by
    simp [diagonal_apply_ne _ hij]
  convert Finset.sum_eq_single i (fun j _ => this j) _ using 1 <;> simp
#align matrix.dot_product_diagonal' Matrix.dot_product_diagonal'

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (j «expr ≠ » i) -/
@[simp]
theorem single_dot_product (x : α) (i : m) : Pi.single i x ⬝ᵥ v = x * v i :=
  by
  have : ∀ (j) (_ : j ≠ i), Pi.single i x j * v j = 0 := fun j hij => by
    simp [Pi.single_eq_of_ne hij]
  convert Finset.sum_eq_single i (fun j _ => this j) _ using 1 <;> simp
#align matrix.single_dot_product Matrix.single_dot_product

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (j «expr ≠ » i) -/
@[simp]
theorem dot_product_single (x : α) (i : m) : v ⬝ᵥ Pi.single i x = v i * x :=
  by
  have : ∀ (j) (_ : j ≠ i), v j * Pi.single i x j = 0 := fun j hij => by
    simp [Pi.single_eq_of_ne hij]
  convert Finset.sum_eq_single i (fun j _ => this j) _ using 1 <;> simp
#align matrix.dot_product_single Matrix.dot_product_single

end NonUnitalNonAssocSemiringDecidable

section NonUnitalNonAssocRing

variable [NonUnitalNonAssocRing α] (u v w : m → α)

@[simp]
theorem neg_dot_product : -v ⬝ᵥ w = -(v ⬝ᵥ w) := by simp [dot_product]
#align matrix.neg_dot_product Matrix.neg_dot_product

@[simp]
theorem dot_product_neg : v ⬝ᵥ -w = -(v ⬝ᵥ w) := by simp [dot_product]
#align matrix.dot_product_neg Matrix.dot_product_neg

@[simp]
theorem sub_dot_product : (u - v) ⬝ᵥ w = u ⬝ᵥ w - v ⬝ᵥ w := by simp [sub_eq_add_neg]
#align matrix.sub_dot_product Matrix.sub_dot_product

@[simp]
theorem dot_product_sub : u ⬝ᵥ (v - w) = u ⬝ᵥ v - u ⬝ᵥ w := by simp [sub_eq_add_neg]
#align matrix.dot_product_sub Matrix.dot_product_sub

end NonUnitalNonAssocRing

section DistribMulAction

variable [Monoid R] [Mul α] [AddCommMonoid α] [DistribMulAction R α]

@[simp]
theorem smul_dot_product [IsScalarTower R α α] (x : R) (v w : m → α) : x • v ⬝ᵥ w = x • (v ⬝ᵥ w) :=
  by simp [dot_product, Finset.smul_sum, smul_mul_assoc]
#align matrix.smul_dot_product Matrix.smul_dot_product

@[simp]
theorem dot_product_smul [SMulCommClass R α α] (x : R) (v w : m → α) : v ⬝ᵥ x • w = x • (v ⬝ᵥ w) :=
  by simp [dot_product, Finset.smul_sum, mul_smul_comm]
#align matrix.dot_product_smul Matrix.dot_product_smul

end DistribMulAction

section StarRing

variable [NonUnitalSemiring α] [StarRing α] (v w : m → α)

theorem star_dot_product_star : star v ⬝ᵥ star w = star (w ⬝ᵥ v) := by simp [dot_product]
#align matrix.star_dot_product_star Matrix.star_dot_product_star

theorem star_dot_product : star v ⬝ᵥ w = star (star w ⬝ᵥ v) := by simp [dot_product]
#align matrix.star_dot_product Matrix.star_dot_product

theorem dot_product_star : v ⬝ᵥ star w = star (w ⬝ᵥ star v) := by simp [dot_product]
#align matrix.dot_product_star Matrix.dot_product_star

end StarRing

end DotProduct

open Matrix

/-- `M ⬝ N` is the usual product of matrices `M` and `N`, i.e. we have that
`(M ⬝ N) i k` is the dot product of the `i`-th row of `M` by the `k`-th column of `N`.
This is currently only defined when `m` is finite. -/
protected def mul [Fintype m] [Mul α] [AddCommMonoid α] (M : Matrix l m α) (N : Matrix m n α) :
    Matrix l n α := fun i k => (fun j => M i j) ⬝ᵥ fun j => N j k
#align matrix.mul Matrix.mul

-- mathport name: matrix.mul
scoped infixl:75 " ⬝ " => Matrix.mul

theorem mul_apply [Fintype m] [Mul α] [AddCommMonoid α] {M : Matrix l m α} {N : Matrix m n α}
    {i k} : (M ⬝ N) i k = ∑ j, M i j * N j k :=
  rfl
#align matrix.mul_apply Matrix.mul_apply

instance [Fintype n] [Mul α] [AddCommMonoid α] : Mul (Matrix n n α) :=
  ⟨Matrix.mul⟩

@[simp]
theorem mul_eq_mul [Fintype n] [Mul α] [AddCommMonoid α] (M N : Matrix n n α) : M * N = M ⬝ N :=
  rfl
#align matrix.mul_eq_mul Matrix.mul_eq_mul

theorem mul_apply' [Fintype m] [Mul α] [AddCommMonoid α] {M : Matrix l m α} {N : Matrix m n α}
    {i k} : (M ⬝ N) i k = (fun j => M i j) ⬝ᵥ fun j => N j k :=
  rfl
#align matrix.mul_apply' Matrix.mul_apply'

@[simp]
theorem diagonal_neg [DecidableEq n] [AddGroup α] (d : n → α) :
    -diagonal d = diagonal fun i => -d i :=
  ((diagonalAddMonoidHom n α).map_neg d).symm
#align matrix.diagonal_neg Matrix.diagonal_neg

theorem sum_apply [AddCommMonoid α] (i : m) (j : n) (s : Finset β) (g : β → Matrix m n α) :
    (∑ c in s, g c) i j = ∑ c in s, g c i j :=
  (congr_fun (s.sum_apply i g) j).trans (s.sum_apply j _)
#align matrix.sum_apply Matrix.sum_apply

theorem two_mul_expl {R : Type _} [CommRing R] (A B : Matrix (Fin 2) (Fin 2) R) :
    (A * B) 0 0 = A 0 0 * B 0 0 + A 0 1 * B 1 0 ∧
      (A * B) 0 1 = A 0 0 * B 0 1 + A 0 1 * B 1 1 ∧
        (A * B) 1 0 = A 1 0 * B 0 0 + A 1 1 * B 1 0 ∧ (A * B) 1 1 = A 1 0 * B 0 1 + A 1 1 * B 1 1 :=
  by
  constructor; on_goal 2 => constructor; on_goal 3 => constructor
  all_goals
    simp only [Matrix.mul_eq_mul]
    rw [Matrix.mul_apply, Finset.sum_fin_eq_sum_range, Finset.sum_range_succ, Finset.sum_range_succ]
    simp
#align matrix.two_mul_expl Matrix.two_mul_expl

section AddCommMonoid

variable [AddCommMonoid α] [Mul α]

@[simp]
theorem smul_mul [Fintype n] [Monoid R] [DistribMulAction R α] [IsScalarTower R α α] (a : R)
    (M : Matrix m n α) (N : Matrix n l α) : (a • M) ⬝ N = a • M ⬝ N :=
  by
  ext
  apply smul_dot_product
#align matrix.smul_mul Matrix.smul_mul

@[simp]
theorem mul_smul [Fintype n] [Monoid R] [DistribMulAction R α] [SMulCommClass R α α]
    (M : Matrix m n α) (a : R) (N : Matrix n l α) : M ⬝ (a • N) = a • M ⬝ N :=
  by
  ext
  apply dot_product_smul
#align matrix.mul_smul Matrix.mul_smul

end AddCommMonoid

section NonUnitalNonAssocSemiring

variable [NonUnitalNonAssocSemiring α]

@[simp]
protected theorem mul_zero [Fintype n] (M : Matrix m n α) : M ⬝ (0 : Matrix n o α) = 0 :=
  by
  ext (i j)
  apply dot_product_zero
#align matrix.mul_zero Matrix.mul_zero

@[simp]
protected theorem zero_mul [Fintype m] (M : Matrix m n α) : (0 : Matrix l m α) ⬝ M = 0 :=
  by
  ext (i j)
  apply zero_dot_product
#align matrix.zero_mul Matrix.zero_mul

protected theorem mul_add [Fintype n] (L : Matrix m n α) (M N : Matrix n o α) :
    L ⬝ (M + N) = L ⬝ M + L ⬝ N := by
  ext (i j)
  apply dot_product_add
#align matrix.mul_add Matrix.mul_add

protected theorem add_mul [Fintype m] (L M : Matrix l m α) (N : Matrix m n α) :
    (L + M) ⬝ N = L ⬝ N + M ⬝ N := by
  ext (i j)
  apply add_dot_product
#align matrix.add_mul Matrix.add_mul

instance [Fintype n] : NonUnitalNonAssocSemiring (Matrix n n α) :=
  { Matrix.addCommMonoid with
    mul := (· * ·)
    add := (· + ·)
    zero := 0
    mul_zero := Matrix.mul_zero
    zero_mul := Matrix.zero_mul
    left_distrib := Matrix.mul_add
    right_distrib := Matrix.add_mul }

@[simp]
theorem diagonal_mul [Fintype m] [DecidableEq m] (d : m → α) (M : Matrix m n α) (i j) :
    (diagonal d).mul M i j = d i * M i j :=
  diagonal_dot_product _ _ _
#align matrix.diagonal_mul Matrix.diagonal_mul

@[simp]
theorem mul_diagonal [Fintype n] [DecidableEq n] (d : n → α) (M : Matrix m n α) (i j) :
    (M ⬝ diagonal d) i j = M i j * d j :=
  by
  rw [← diagonal_transpose]
  apply dot_product_diagonal
#align matrix.mul_diagonal Matrix.mul_diagonal

@[simp]
theorem diagonal_mul_diagonal [Fintype n] [DecidableEq n] (d₁ d₂ : n → α) :
    diagonal d₁ ⬝ diagonal d₂ = diagonal fun i => d₁ i * d₂ i := by
  ext (i j) <;> by_cases i = j <;> simp [h]
#align matrix.diagonal_mul_diagonal Matrix.diagonal_mul_diagonal

theorem diagonal_mul_diagonal' [Fintype n] [DecidableEq n] (d₁ d₂ : n → α) :
    diagonal d₁ * diagonal d₂ = diagonal fun i => d₁ i * d₂ i :=
  diagonal_mul_diagonal _ _
#align matrix.diagonal_mul_diagonal' Matrix.diagonal_mul_diagonal'

theorem smul_eq_diagonal_mul [Fintype m] [DecidableEq m] (M : Matrix m n α) (a : α) :
    a • M = (diagonal fun _ => a) ⬝ M := by
  ext
  simp
#align matrix.smul_eq_diagonal_mul Matrix.smul_eq_diagonal_mul

@[simp]
theorem diag_col_mul_row (a b : n → α) : diag (col a ⬝ row b) = a * b :=
  by
  ext
  simp [Matrix.mul_apply, col, row]
#align matrix.diag_col_mul_row Matrix.diag_col_mul_row

/-- Left multiplication by a matrix, as an `add_monoid_hom` from matrices to matrices. -/
@[simps]
def addMonoidHomMulLeft [Fintype m] (M : Matrix l m α) : Matrix m n α →+ Matrix l n α
    where
  toFun x := M ⬝ x
  map_zero' := Matrix.mul_zero _
  map_add' := Matrix.mul_add _
#align matrix.add_monoid_hom_mul_left Matrix.addMonoidHomMulLeft

/-- Right multiplication by a matrix, as an `add_monoid_hom` from matrices to matrices. -/
@[simps]
def addMonoidHomMulRight [Fintype m] (M : Matrix m n α) : Matrix l m α →+ Matrix l n α
    where
  toFun x := x ⬝ M
  map_zero' := Matrix.zero_mul _
  map_add' _ _ := Matrix.add_mul _ _ _
#align matrix.add_monoid_hom_mul_right Matrix.addMonoidHomMulRight

protected theorem sum_mul [Fintype m] (s : Finset β) (f : β → Matrix l m α) (M : Matrix m n α) :
    (∑ a in s, f a) ⬝ M = ∑ a in s, f a ⬝ M :=
  (addMonoidHomMulRight M : Matrix l m α →+ _).map_sum f s
#align matrix.sum_mul Matrix.sum_mul

protected theorem mul_sum [Fintype m] (s : Finset β) (f : β → Matrix m n α) (M : Matrix l m α) :
    (M ⬝ ∑ a in s, f a) = ∑ a in s, M ⬝ f a :=
  (addMonoidHomMulLeft M : Matrix m n α →+ _).map_sum f s
#align matrix.mul_sum Matrix.mul_sum

/-- This instance enables use with `smul_mul_assoc`. -/
instance Semiring.is_scalar_tower [Fintype n] [Monoid R] [DistribMulAction R α]
    [IsScalarTower R α α] : IsScalarTower R (Matrix n n α) (Matrix n n α) :=
  ⟨fun r m n => Matrix.smul_mul r m n⟩
#align matrix.semiring.is_scalar_tower Matrix.Semiring.is_scalar_tower

/-- This instance enables use with `mul_smul_comm`. -/
instance Semiring.smul_comm_class [Fintype n] [Monoid R] [DistribMulAction R α]
    [SMulCommClass R α α] : SMulCommClass R (Matrix n n α) (Matrix n n α) :=
  ⟨fun r m n => (Matrix.mul_smul m r n).symm⟩
#align matrix.semiring.smul_comm_class Matrix.Semiring.smul_comm_class

end NonUnitalNonAssocSemiring

section NonAssocSemiring

variable [NonAssocSemiring α]

@[simp]
protected theorem one_mul [Fintype m] [DecidableEq m] (M : Matrix m n α) :
    (1 : Matrix m m α) ⬝ M = M := by ext (i j) <;> rw [← diagonal_one, diagonal_mul, one_mul]
#align matrix.one_mul Matrix.one_mul

@[simp]
protected theorem mul_one [Fintype n] [DecidableEq n] (M : Matrix m n α) :
    M ⬝ (1 : Matrix n n α) = M := by ext (i j) <;> rw [← diagonal_one, mul_diagonal, mul_one]
#align matrix.mul_one Matrix.mul_one

instance [Fintype n] [DecidableEq n] : NonAssocSemiring (Matrix n n α) :=
  { Matrix.nonUnitalNonAssocSemiring with
    one := 1
    one_mul := Matrix.one_mul
    mul_one := Matrix.mul_one
    natCast := fun n => diagonal fun _ => n
    nat_cast_zero := by ext <;> simp [Nat.cast]
    nat_cast_succ := fun n => by ext <;> by_cases i = j <;> simp [Nat.cast, *] }

@[simp]
theorem map_mul [Fintype n] {L : Matrix m n α} {M : Matrix n o α} [NonAssocSemiring β]
    {f : α →+* β} : (L ⬝ M).map f = L.map f ⬝ M.map f :=
  by
  ext
  simp [mul_apply, RingHom.map_sum]
#align matrix.map_mul Matrix.map_mul

variable (α n)

/-- `matrix.diagonal` as a `ring_hom`. -/
@[simps]
def diagonalRingHom [Fintype n] [DecidableEq n] : (n → α) →+* Matrix n n α :=
  { diagonalAddMonoidHom n α with
    toFun := diagonal
    map_one' := diagonal_one
    map_mul' := fun _ _ => (diagonal_mul_diagonal' _ _).symm }
#align matrix.diagonal_ring_hom Matrix.diagonalRingHom

end NonAssocSemiring

section NonUnitalSemiring

variable [NonUnitalSemiring α] [Fintype m] [Fintype n]

protected theorem mul_assoc (L : Matrix l m α) (M : Matrix m n α) (N : Matrix n o α) :
    L ⬝ M ⬝ N = L ⬝ (M ⬝ N) := by
  ext
  apply dot_product_assoc
#align matrix.mul_assoc Matrix.mul_assoc

instance : NonUnitalSemiring (Matrix n n α) :=
  { Matrix.nonUnitalNonAssocSemiring with mul_assoc := Matrix.mul_assoc }

end NonUnitalSemiring

section Semiring

variable [Semiring α]

instance [Fintype n] [DecidableEq n] : Semiring (Matrix n n α) :=
  { Matrix.nonUnitalSemiring, Matrix.nonAssocSemiring with }

end Semiring

section NonUnitalNonAssocRing

variable [NonUnitalNonAssocRing α] [Fintype n]

@[simp]
protected theorem neg_mul (M : Matrix m n α) (N : Matrix n o α) : (-M) ⬝ N = -M ⬝ N :=
  by
  ext
  apply neg_dot_product
#align matrix.neg_mul Matrix.neg_mul

@[simp]
protected theorem mul_neg (M : Matrix m n α) (N : Matrix n o α) : M ⬝ (-N) = -M ⬝ N :=
  by
  ext
  apply dot_product_neg
#align matrix.mul_neg Matrix.mul_neg

protected theorem sub_mul (M M' : Matrix m n α) (N : Matrix n o α) :
    (M - M') ⬝ N = M ⬝ N - M' ⬝ N := by
  rw [sub_eq_add_neg, Matrix.add_mul, Matrix.neg_mul, sub_eq_add_neg]
#align matrix.sub_mul Matrix.sub_mul

protected theorem mul_sub (M : Matrix m n α) (N N' : Matrix n o α) :
    M ⬝ (N - N') = M ⬝ N - M ⬝ N' := by
  rw [sub_eq_add_neg, Matrix.mul_add, Matrix.mul_neg, sub_eq_add_neg]
#align matrix.mul_sub Matrix.mul_sub

instance : NonUnitalNonAssocRing (Matrix n n α) :=
  { Matrix.nonUnitalNonAssocSemiring, Matrix.addCommGroup with }

end NonUnitalNonAssocRing

instance [Fintype n] [NonUnitalRing α] : NonUnitalRing (Matrix n n α) :=
  { Matrix.nonUnitalSemiring, Matrix.addCommGroup with }

instance [Fintype n] [DecidableEq n] [NonAssocRing α] : NonAssocRing (Matrix n n α) :=
  { Matrix.nonAssocSemiring, Matrix.addCommGroup with }

instance [Fintype n] [DecidableEq n] [Ring α] : Ring (Matrix n n α) :=
  { Matrix.semiring, Matrix.addCommGroup with }

section Semiring

variable [Semiring α]

theorem diagonal_pow [Fintype n] [DecidableEq n] (v : n → α) (k : ℕ) :
    diagonal v ^ k = diagonal (v ^ k) :=
  (map_pow (diagonalRingHom n α) v k).symm
#align matrix.diagonal_pow Matrix.diagonal_pow

@[simp]
theorem mul_mul_left [Fintype n] (M : Matrix m n α) (N : Matrix n o α) (a : α) :
    (of fun i j => a * M i j) ⬝ N = a • M ⬝ N :=
  smul_mul a M N
#align matrix.mul_mul_left Matrix.mul_mul_left

/-- The ring homomorphism `α →+* matrix n n α`
sending `a` to the diagonal matrix with `a` on the diagonal.
-/
def scalar (n : Type u) [DecidableEq n] [Fintype n] : α →+* Matrix n n α :=
  {
    (smulAddHom α _).flip (1 :
        Matrix n n α) with
    toFun := fun a => a • 1
    map_one' := by simp
    map_mul' := by
      intros
      ext
      simp [mul_assoc] }
#align matrix.scalar Matrix.scalar

section Scalar

variable [DecidableEq n] [Fintype n]

@[simp]
theorem coe_scalar : (scalar n : α → Matrix n n α) = fun a => a • 1 :=
  rfl
#align matrix.coe_scalar Matrix.coe_scalar

theorem scalar_apply_eq (a : α) (i : n) : scalar n a i i = a := by
  simp only [coe_scalar, smul_eq_mul, mul_one, one_apply_eq, Pi.smul_apply]
#align matrix.scalar_apply_eq Matrix.scalar_apply_eq

theorem scalar_apply_ne (a : α) (i j : n) (h : i ≠ j) : scalar n a i j = 0 := by
  simp only [h, coe_scalar, one_apply_ne, Ne.def, not_false_iff, Pi.smul_apply, smul_zero]
#align matrix.scalar_apply_ne Matrix.scalar_apply_ne

theorem scalar_inj [Nonempty n] {r s : α} : scalar n r = scalar n s ↔ r = s :=
  by
  constructor
  · intro h
    inhabit n
    rw [← scalar_apply_eq r (Inhabited.default n), ← scalar_apply_eq s (Inhabited.default n), h]
  · rintro rfl
    rfl
#align matrix.scalar_inj Matrix.scalar_inj

end Scalar

end Semiring

section CommSemiring

variable [CommSemiring α] [Fintype n]

theorem smul_eq_mul_diagonal [DecidableEq n] (M : Matrix m n α) (a : α) :
    a • M = M ⬝ diagonal fun _ => a := by
  ext
  simp [mul_comm]
#align matrix.smul_eq_mul_diagonal Matrix.smul_eq_mul_diagonal

@[simp]
theorem mul_mul_right (M : Matrix m n α) (N : Matrix n o α) (a : α) :
    (M ⬝ of fun i j => a * N i j) = a • M ⬝ N :=
  mul_smul M a N
#align matrix.mul_mul_right Matrix.mul_mul_right

theorem scalar.commute [DecidableEq n] (r : α) (M : Matrix n n α) : Commute (scalar n r) M := by
  simp [Commute, SemiconjBy]
#align matrix.scalar.commute Matrix.scalar.commute

end CommSemiring

section Algebra

variable [Fintype n] [DecidableEq n]

variable [CommSemiring R] [Semiring α] [Semiring β] [Algebra R α] [Algebra R β]

instance : Algebra R (Matrix n n α) :=
  {
    (Matrix.scalar n).comp
      (algebraMap R
        α) with
    commutes' := fun r x => by ext;
      simp [Matrix.scalar, Matrix.mul_apply, Matrix.one_apply, Algebra.commutes, smul_ite]
    smul_def' := fun r x => by ext; simp [Matrix.scalar, Algebra.smul_def r] }

theorem algebra_map_matrix_apply {r : R} {i j : n} :
    algebraMap R (Matrix n n α) r i j = if i = j then algebraMap R α r else 0 :=
  by
  dsimp [algebraMap, Algebra.toRingHom, Matrix.scalar]
  split_ifs with h <;> simp [h, Matrix.one_apply_ne]
#align matrix.algebra_map_matrix_apply Matrix.algebra_map_matrix_apply

theorem algebra_map_eq_diagonal (r : R) :
    algebraMap R (Matrix n n α) r = diagonal (algebraMap R (n → α) r) :=
  Matrix.ext fun i j => algebra_map_matrix_apply
#align matrix.algebra_map_eq_diagonal Matrix.algebra_map_eq_diagonal

@[simp]
theorem algebra_map_eq_smul (r : R) : algebraMap R (Matrix n n R) r = r • (1 : Matrix n n R) :=
  rfl
#align matrix.algebra_map_eq_smul Matrix.algebra_map_eq_smul

theorem algebra_map_eq_diagonal_ring_hom :
    algebraMap R (Matrix n n α) = (diagonalRingHom n α).comp (algebraMap R _) :=
  RingHom.ext algebra_map_eq_diagonal
#align matrix.algebra_map_eq_diagonal_ring_hom Matrix.algebra_map_eq_diagonal_ring_hom

@[simp]
theorem map_algebra_map (r : R) (f : α → β) (hf : f 0 = 0)
    (hf₂ : f (algebraMap R α r) = algebraMap R β r) :
    (algebraMap R (Matrix n n α) r).map f = algebraMap R (Matrix n n β) r :=
  by
  rw [algebra_map_eq_diagonal, algebra_map_eq_diagonal, diagonal_map hf]
  congr 1 with x
  simp only [hf₂, Pi.algebra_map_apply]
#align matrix.map_algebra_map Matrix.map_algebra_map

variable (R)

/-- `matrix.diagonal` as an `alg_hom`. -/
@[simps]
def diagonalAlgHom : (n → α) →ₐ[R] Matrix n n α :=
  { diagonalRingHom n α with
    toFun := diagonal
    commutes' := fun r => (algebra_map_eq_diagonal r).symm }
#align matrix.diagonal_alg_hom Matrix.diagonalAlgHom

end Algebra

end Matrix

/-!
### Bundled versions of `matrix.map`
-/


namespace Equiv

/-- The `equiv` between spaces of matrices induced by an `equiv` between their
coefficients. This is `matrix.map` as an `equiv`. -/
@[simps apply]
def mapMatrix (f : α ≃ β) : Matrix m n α ≃ Matrix m n β
    where
  toFun M := M.map f
  invFun M := M.map f.symm
  left_inv M := Matrix.ext fun _ _ => f.symm_apply_apply _
  right_inv M := Matrix.ext fun _ _ => f.apply_symm_apply _
#align equiv.map_matrix Equiv.mapMatrix

@[simp]
theorem map_matrix_refl : (Equiv.refl α).mapMatrix = Equiv.refl (Matrix m n α) :=
  rfl
#align equiv.map_matrix_refl Equiv.map_matrix_refl

@[simp]
theorem map_matrix_symm (f : α ≃ β) : f.mapMatrix.symm = (f.symm.mapMatrix : Matrix m n β ≃ _) :=
  rfl
#align equiv.map_matrix_symm Equiv.map_matrix_symm

@[simp]
theorem map_matrix_trans (f : α ≃ β) (g : β ≃ γ) :
    f.mapMatrix.trans g.mapMatrix = ((f.trans g).mapMatrix : Matrix m n α ≃ _) :=
  rfl
#align equiv.map_matrix_trans Equiv.map_matrix_trans

end Equiv

namespace AddMonoidHom

variable [AddZeroClass α] [AddZeroClass β] [AddZeroClass γ]

/-- The `add_monoid_hom` between spaces of matrices induced by an `add_monoid_hom` between their
coefficients. This is `matrix.map` as an `add_monoid_hom`. -/
@[simps]
def mapMatrix (f : α →+ β) : Matrix m n α →+ Matrix m n β
    where
  toFun M := M.map f
  map_zero' := Matrix.map_zero f f.map_zero
  map_add' := Matrix.map_add f f.map_add
#align add_monoid_hom.map_matrix AddMonoidHom.mapMatrix

@[simp]
theorem map_matrix_id : (AddMonoidHom.id α).mapMatrix = AddMonoidHom.id (Matrix m n α) :=
  rfl
#align add_monoid_hom.map_matrix_id AddMonoidHom.map_matrix_id

@[simp]
theorem map_matrix_comp (f : β →+ γ) (g : α →+ β) :
    f.mapMatrix.comp g.mapMatrix = ((f.comp g).mapMatrix : Matrix m n α →+ _) :=
  rfl
#align add_monoid_hom.map_matrix_comp AddMonoidHom.map_matrix_comp

end AddMonoidHom

namespace AddEquiv

variable [Add α] [Add β] [Add γ]

/-- The `add_equiv` between spaces of matrices induced by an `add_equiv` between their
coefficients. This is `matrix.map` as an `add_equiv`. -/
@[simps apply]
def mapMatrix (f : α ≃+ β) : Matrix m n α ≃+ Matrix m n β :=
  { f.toEquiv.mapMatrix with
    toFun := fun M => M.map f
    invFun := fun M => M.map f.symm
    map_add' := Matrix.map_add f f.map_add }
#align add_equiv.map_matrix AddEquiv.mapMatrix

@[simp]
theorem map_matrix_refl : (AddEquiv.refl α).mapMatrix = AddEquiv.refl (Matrix m n α) :=
  rfl
#align add_equiv.map_matrix_refl AddEquiv.map_matrix_refl

@[simp]
theorem map_matrix_symm (f : α ≃+ β) : f.mapMatrix.symm = (f.symm.mapMatrix : Matrix m n β ≃+ _) :=
  rfl
#align add_equiv.map_matrix_symm AddEquiv.map_matrix_symm

@[simp]
theorem map_matrix_trans (f : α ≃+ β) (g : β ≃+ γ) :
    f.mapMatrix.trans g.mapMatrix = ((f.trans g).mapMatrix : Matrix m n α ≃+ _) :=
  rfl
#align add_equiv.map_matrix_trans AddEquiv.map_matrix_trans

end AddEquiv

namespace LinearMap

variable [Semiring R] [AddCommMonoid α] [AddCommMonoid β] [AddCommMonoid γ]

variable [Module R α] [Module R β] [Module R γ]

/-- The `linear_map` between spaces of matrices induced by a `linear_map` between their
coefficients. This is `matrix.map` as a `linear_map`. -/
@[simps]
def mapMatrix (f : α →ₗ[R] β) : Matrix m n α →ₗ[R] Matrix m n β
    where
  toFun M := M.map f
  map_add' := Matrix.map_add f f.map_add
  map_smul' r := Matrix.map_smul f r (f.map_smul r)
#align linear_map.map_matrix LinearMap.mapMatrix

@[simp]
theorem map_matrix_id : LinearMap.id.mapMatrix = (LinearMap.id : Matrix m n α →ₗ[R] _) :=
  rfl
#align linear_map.map_matrix_id LinearMap.map_matrix_id

@[simp]
theorem map_matrix_comp (f : β →ₗ[R] γ) (g : α →ₗ[R] β) :
    f.mapMatrix.comp g.mapMatrix = ((f.comp g).mapMatrix : Matrix m n α →ₗ[R] _) :=
  rfl
#align linear_map.map_matrix_comp LinearMap.map_matrix_comp

end LinearMap

namespace LinearEquiv

variable [Semiring R] [AddCommMonoid α] [AddCommMonoid β] [AddCommMonoid γ]

variable [Module R α] [Module R β] [Module R γ]

/-- The `linear_equiv` between spaces of matrices induced by an `linear_equiv` between their
coefficients. This is `matrix.map` as an `linear_equiv`. -/
@[simps apply]
def mapMatrix (f : α ≃ₗ[R] β) : Matrix m n α ≃ₗ[R] Matrix m n β :=
  { f.toEquiv.mapMatrix,
    f.toLinearMap.mapMatrix with
    toFun := fun M => M.map f
    invFun := fun M => M.map f.symm }
#align linear_equiv.map_matrix LinearEquiv.mapMatrix

@[simp]
theorem map_matrix_refl : (LinearEquiv.refl R α).mapMatrix = LinearEquiv.refl R (Matrix m n α) :=
  rfl
#align linear_equiv.map_matrix_refl LinearEquiv.map_matrix_refl

@[simp]
theorem map_matrix_symm (f : α ≃ₗ[R] β) :
    f.mapMatrix.symm = (f.symm.mapMatrix : Matrix m n β ≃ₗ[R] _) :=
  rfl
#align linear_equiv.map_matrix_symm LinearEquiv.map_matrix_symm

@[simp]
theorem map_matrix_trans (f : α ≃ₗ[R] β) (g : β ≃ₗ[R] γ) :
    f.mapMatrix.trans g.mapMatrix = ((f.trans g).mapMatrix : Matrix m n α ≃ₗ[R] _) :=
  rfl
#align linear_equiv.map_matrix_trans LinearEquiv.map_matrix_trans

end LinearEquiv

namespace RingHom

variable [Fintype m] [DecidableEq m]

variable [NonAssocSemiring α] [NonAssocSemiring β] [NonAssocSemiring γ]

/-- The `ring_hom` between spaces of square matrices induced by a `ring_hom` between their
coefficients. This is `matrix.map` as a `ring_hom`. -/
@[simps]
def mapMatrix (f : α →+* β) : Matrix m m α →+* Matrix m m β :=
  { f.toAddMonoidHom.mapMatrix with
    toFun := fun M => M.map f
    map_one' := by simp
    map_mul' := fun L M => Matrix.map_mul }
#align ring_hom.map_matrix RingHom.mapMatrix

@[simp]
theorem map_matrix_id : (RingHom.id α).mapMatrix = RingHom.id (Matrix m m α) :=
  rfl
#align ring_hom.map_matrix_id RingHom.map_matrix_id

@[simp]
theorem map_matrix_comp (f : β →+* γ) (g : α →+* β) :
    f.mapMatrix.comp g.mapMatrix = ((f.comp g).mapMatrix : Matrix m m α →+* _) :=
  rfl
#align ring_hom.map_matrix_comp RingHom.map_matrix_comp

end RingHom

namespace RingEquiv

variable [Fintype m] [DecidableEq m]

variable [NonAssocSemiring α] [NonAssocSemiring β] [NonAssocSemiring γ]

/-- The `ring_equiv` between spaces of square matrices induced by a `ring_equiv` between their
coefficients. This is `matrix.map` as a `ring_equiv`. -/
@[simps apply]
def mapMatrix (f : α ≃+* β) : Matrix m m α ≃+* Matrix m m β :=
  { f.toRingHom.mapMatrix,
    f.toAddEquiv.mapMatrix with
    toFun := fun M => M.map f
    invFun := fun M => M.map f.symm }
#align ring_equiv.map_matrix RingEquiv.mapMatrix

@[simp]
theorem map_matrix_refl : (RingEquiv.refl α).mapMatrix = RingEquiv.refl (Matrix m m α) :=
  rfl
#align ring_equiv.map_matrix_refl RingEquiv.map_matrix_refl

@[simp]
theorem map_matrix_symm (f : α ≃+* β) :
    f.mapMatrix.symm = (f.symm.mapMatrix : Matrix m m β ≃+* _) :=
  rfl
#align ring_equiv.map_matrix_symm RingEquiv.map_matrix_symm

@[simp]
theorem map_matrix_trans (f : α ≃+* β) (g : β ≃+* γ) :
    f.mapMatrix.trans g.mapMatrix = ((f.trans g).mapMatrix : Matrix m m α ≃+* _) :=
  rfl
#align ring_equiv.map_matrix_trans RingEquiv.map_matrix_trans

end RingEquiv

namespace AlgHom

variable [Fintype m] [DecidableEq m]

variable [CommSemiring R] [Semiring α] [Semiring β] [Semiring γ]

variable [Algebra R α] [Algebra R β] [Algebra R γ]

/-- The `alg_hom` between spaces of square matrices induced by a `alg_hom` between their
coefficients. This is `matrix.map` as a `alg_hom`. -/
@[simps]
def mapMatrix (f : α →ₐ[R] β) : Matrix m m α →ₐ[R] Matrix m m β :=
  { f.toRingHom.mapMatrix with
    toFun := fun M => M.map f
    commutes' := fun r => Matrix.map_algebra_map r f f.map_zero (f.commutes r) }
#align alg_hom.map_matrix AlgHom.mapMatrix

@[simp]
theorem map_matrix_id : (AlgHom.id R α).mapMatrix = AlgHom.id R (Matrix m m α) :=
  rfl
#align alg_hom.map_matrix_id AlgHom.map_matrix_id

@[simp]
theorem map_matrix_comp (f : β →ₐ[R] γ) (g : α →ₐ[R] β) :
    f.mapMatrix.comp g.mapMatrix = ((f.comp g).mapMatrix : Matrix m m α →ₐ[R] _) :=
  rfl
#align alg_hom.map_matrix_comp AlgHom.map_matrix_comp

end AlgHom

namespace AlgEquiv

variable [Fintype m] [DecidableEq m]

variable [CommSemiring R] [Semiring α] [Semiring β] [Semiring γ]

variable [Algebra R α] [Algebra R β] [Algebra R γ]

/-- The `alg_equiv` between spaces of square matrices induced by a `alg_equiv` between their
coefficients. This is `matrix.map` as a `alg_equiv`. -/
@[simps apply]
def mapMatrix (f : α ≃ₐ[R] β) : Matrix m m α ≃ₐ[R] Matrix m m β :=
  { f.toAlgHom.mapMatrix,
    f.toRingEquiv.mapMatrix with
    toFun := fun M => M.map f
    invFun := fun M => M.map f.symm }
#align alg_equiv.map_matrix AlgEquiv.mapMatrix

@[simp]
theorem map_matrix_refl : AlgEquiv.refl.mapMatrix = (AlgEquiv.refl : Matrix m m α ≃ₐ[R] _) :=
  rfl
#align alg_equiv.map_matrix_refl AlgEquiv.map_matrix_refl

@[simp]
theorem map_matrix_symm (f : α ≃ₐ[R] β) :
    f.mapMatrix.symm = (f.symm.mapMatrix : Matrix m m β ≃ₐ[R] _) :=
  rfl
#align alg_equiv.map_matrix_symm AlgEquiv.map_matrix_symm

@[simp]
theorem map_matrix_trans (f : α ≃ₐ[R] β) (g : β ≃ₐ[R] γ) :
    f.mapMatrix.trans g.mapMatrix = ((f.trans g).mapMatrix : Matrix m m α ≃ₐ[R] _) :=
  rfl
#align alg_equiv.map_matrix_trans AlgEquiv.map_matrix_trans

end AlgEquiv

open Matrix

namespace Matrix

/- warning: matrix.vec_mul_vec -> Matrix.vecMulVec is a dubious translation:
lean 3 declaration is
  forall {m : Type.{u2}} {n : Type.{u3}} {α : Type.{u1}} [_inst_1 : Mul.{u1} α], (m -> α) -> (n -> α) -> (Matrix.{u2, u3, u1} m n α)
but is expected to have type
  forall {m : Type.{u1}} {n : Type.{u2}} {α : Type.{u3}} [_inst_1 : Mul.{u3} α], (m -> α) -> (n -> α) -> (Matrix.{u1, u2, u3} m n α)
Case conversion may be inaccurate. Consider using '#align matrix.vec_mul_vec Matrix.vecMulVecₓ'. -/
/-- For two vectors `w` and `v`, `vec_mul_vec w v i j` is defined to be `w i * v j`.
    Put another way, `vec_mul_vec w v` is exactly `col w ⬝ row v`. -/
def vecMulVec [Mul α] (w : m → α) (v : n → α) : Matrix m n α
  | x, y => w x * v y
#align matrix.vec_mul_vec Matrix.vecMulVec

theorem vec_mul_vec_eq [Mul α] [AddCommMonoid α] (w : m → α) (v : n → α) :
    vecMulVec w v = col w ⬝ row v := by
  ext (i j)
  simp only [vec_mul_vec, mul_apply, Fintype.univ_punit, Finset.sum_singleton]
  rfl
#align matrix.vec_mul_vec_eq Matrix.vec_mul_vec_eq

section NonUnitalNonAssocSemiring

variable [NonUnitalNonAssocSemiring α]

/- warning: matrix.mul_vec -> Matrix.mulVec is a dubious translation:
lean 3 declaration is
  forall {m : Type.{u2}} {n : Type.{u3}} {α : Type.{u1}} [_inst_1 : NonUnitalNonAssocSemiring.{u1} α] [_inst_2 : Fintype.{u3} n], (Matrix.{u2, u3, u1} m n α) -> (n -> α) -> m -> α
but is expected to have type
  forall {m : Type.{u1}} {n : Type.{u2}} {α : Type.{u3}} [_inst_1 : NonUnitalNonAssocSemiring.{u3} α] [_inst_2 : Fintype.{u2} n], (Matrix.{u1, u2, u3} m n α) -> (n -> α) -> m -> α
Case conversion may be inaccurate. Consider using '#align matrix.mul_vec Matrix.mulVecₓ'. -/
/-- `mul_vec M v` is the matrix-vector product of `M` and `v`, where `v` is seen as a column matrix.
    Put another way, `mul_vec M v` is the vector whose entries
    are those of `M ⬝ col v` (see `col_mul_vec`). -/
def mulVec [Fintype n] (M : Matrix m n α) (v : n → α) : m → α
  | i => (fun j => M i j) ⬝ᵥ v
#align matrix.mul_vec Matrix.mulVec

/- warning: matrix.vec_mul -> Matrix.vecMul is a dubious translation:
lean 3 declaration is
  forall {m : Type.{u2}} {n : Type.{u3}} {α : Type.{u1}} [_inst_1 : NonUnitalNonAssocSemiring.{u1} α] [_inst_2 : Fintype.{u2} m], (m -> α) -> (Matrix.{u2, u3, u1} m n α) -> n -> α
but is expected to have type
  forall {m : Type.{u1}} {n : Type.{u2}} {α : Type.{u3}} [_inst_1 : NonUnitalNonAssocSemiring.{u3} α] [_inst_2 : Fintype.{u1} m], (m -> α) -> (Matrix.{u1, u2, u3} m n α) -> n -> α
Case conversion may be inaccurate. Consider using '#align matrix.vec_mul Matrix.vecMulₓ'. -/
/-- `vec_mul v M` is the vector-matrix product of `v` and `M`, where `v` is seen as a row matrix.
    Put another way, `vec_mul v M` is the vector whose entries
    are those of `row v ⬝ M` (see `row_vec_mul`). -/
def vecMul [Fintype m] (v : m → α) (M : Matrix m n α) : n → α
  | j => v ⬝ᵥ fun i => M i j
#align matrix.vec_mul Matrix.vecMul

/-- Left multiplication by a matrix, as an `add_monoid_hom` from vectors to vectors. -/
@[simps]
def mulVec.addMonoidHomLeft [Fintype n] (v : n → α) : Matrix m n α →+ m → α
    where
  toFun M := mulVec M v
  map_zero' := by ext <;> simp [mul_vec] <;> rfl
  map_add' x y := by
    ext m
    apply add_dot_product
#align matrix.mul_vec.add_monoid_hom_left Matrix.mulVec.addMonoidHomLeft

theorem mul_vec_diagonal [Fintype m] [DecidableEq m] (v w : m → α) (x : m) :
    mulVec (diagonal v) w x = v x * w x :=
  diagonal_dot_product v w x
#align matrix.mul_vec_diagonal Matrix.mul_vec_diagonal

theorem vec_mul_diagonal [Fintype m] [DecidableEq m] (v w : m → α) (x : m) :
    vecMul v (diagonal w) x = v x * w x :=
  dot_product_diagonal' v w x
#align matrix.vec_mul_diagonal Matrix.vec_mul_diagonal

/-- Associate the dot product of `mul_vec` to the left. -/
theorem dot_product_mul_vec [Fintype n] [Fintype m] [NonUnitalSemiring R] (v : m → R)
    (A : Matrix m n R) (w : n → R) : v ⬝ᵥ mulVec A w = vecMul v A ⬝ᵥ w := by
  simp only [dot_product, vec_mul, mul_vec, Finset.mul_sum, Finset.sum_mul, mul_assoc] <;>
    exact Finset.sum_comm
#align matrix.dot_product_mul_vec Matrix.dot_product_mul_vec

@[simp]
theorem mul_vec_zero [Fintype n] (A : Matrix m n α) : mulVec A 0 = 0 :=
  by
  ext
  simp [mul_vec]
#align matrix.mul_vec_zero Matrix.mul_vec_zero

@[simp]
theorem zero_vec_mul [Fintype m] (A : Matrix m n α) : vecMul 0 A = 0 :=
  by
  ext
  simp [vec_mul]
#align matrix.zero_vec_mul Matrix.zero_vec_mul

@[simp]
theorem zero_mul_vec [Fintype n] (v : n → α) : mulVec (0 : Matrix m n α) v = 0 :=
  by
  ext
  simp [mul_vec]
#align matrix.zero_mul_vec Matrix.zero_mul_vec

@[simp]
theorem vec_mul_zero [Fintype m] (v : m → α) : vecMul v (0 : Matrix m n α) = 0 :=
  by
  ext
  simp [vec_mul]
#align matrix.vec_mul_zero Matrix.vec_mul_zero

theorem smul_mul_vec_assoc [Fintype n] [Monoid R] [DistribMulAction R α] [IsScalarTower R α α]
    (a : R) (A : Matrix m n α) (b : n → α) : (a • A).mulVec b = a • A.mulVec b :=
  by
  ext
  apply smul_dot_product
#align matrix.smul_mul_vec_assoc Matrix.smul_mul_vec_assoc

theorem mul_vec_add [Fintype n] (A : Matrix m n α) (x y : n → α) :
    A.mulVec (x + y) = A.mulVec x + A.mulVec y :=
  by
  ext
  apply dot_product_add
#align matrix.mul_vec_add Matrix.mul_vec_add

theorem add_mul_vec [Fintype n] (A B : Matrix m n α) (x : n → α) :
    (A + B).mulVec x = A.mulVec x + B.mulVec x :=
  by
  ext
  apply add_dot_product
#align matrix.add_mul_vec Matrix.add_mul_vec

theorem vec_mul_add [Fintype m] (A B : Matrix m n α) (x : m → α) :
    vecMul x (A + B) = vecMul x A + vecMul x B :=
  by
  ext
  apply dot_product_add
#align matrix.vec_mul_add Matrix.vec_mul_add

theorem add_vec_mul [Fintype m] (A : Matrix m n α) (x y : m → α) :
    vecMul (x + y) A = vecMul x A + vecMul y A :=
  by
  ext
  apply add_dot_product
#align matrix.add_vec_mul Matrix.add_vec_mul

theorem vec_mul_smul [Fintype n] [Monoid R] [NonUnitalNonAssocSemiring S] [DistribMulAction R S]
    [IsScalarTower R S S] (M : Matrix n m S) (b : R) (v : n → S) :
    M.vecMul (b • v) = b • M.vecMul v := by
  ext i
  simp only [vec_mul, dot_product, Finset.smul_sum, Pi.smul_apply, smul_mul_assoc]
#align matrix.vec_mul_smul Matrix.vec_mul_smul

theorem mul_vec_smul [Fintype n] [Monoid R] [NonUnitalNonAssocSemiring S] [DistribMulAction R S]
    [SMulCommClass R S S] (M : Matrix m n S) (b : R) (v : n → S) :
    M.mulVec (b • v) = b • M.mulVec v := by
  ext i
  simp only [mul_vec, dot_product, Finset.smul_sum, Pi.smul_apply, mul_smul_comm]
#align matrix.mul_vec_smul Matrix.mul_vec_smul

@[simp]
theorem mul_vec_single [Fintype n] [DecidableEq n] [NonUnitalNonAssocSemiring R] (M : Matrix m n R)
    (j : n) (x : R) : M.mulVec (Pi.single j x) = fun i => M i j * x :=
  funext fun i => dot_product_single _ _ _
#align matrix.mul_vec_single Matrix.mul_vec_single

@[simp]
theorem single_vec_mul [Fintype m] [DecidableEq m] [NonUnitalNonAssocSemiring R] (M : Matrix m n R)
    (i : m) (x : R) : vecMul (Pi.single i x) M = fun j => x * M i j :=
  funext fun i => single_dot_product _ _ _
#align matrix.single_vec_mul Matrix.single_vec_mul

@[simp]
theorem diagonal_mul_vec_single [Fintype n] [DecidableEq n] [NonUnitalNonAssocSemiring R]
    (v : n → R) (j : n) (x : R) : (diagonal v).mulVec (Pi.single j x) = Pi.single j (v j * x) :=
  by
  ext i
  rw [mul_vec_diagonal]
  exact Pi.apply_single (fun i x => v i * x) (fun i => mul_zero _) j x i
#align matrix.diagonal_mul_vec_single Matrix.diagonal_mul_vec_single

@[simp]
theorem single_vec_mul_diagonal [Fintype n] [DecidableEq n] [NonUnitalNonAssocSemiring R]
    (v : n → R) (j : n) (x : R) : vecMul (Pi.single j x) (diagonal v) = Pi.single j (x * v j) :=
  by
  ext i
  rw [vec_mul_diagonal]
  exact Pi.apply_single (fun i x => x * v i) (fun i => zero_mul _) j x i
#align matrix.single_vec_mul_diagonal Matrix.single_vec_mul_diagonal

end NonUnitalNonAssocSemiring

section NonUnitalSemiring

variable [NonUnitalSemiring α]

@[simp]
theorem vec_mul_vec_mul [Fintype n] [Fintype m] (v : m → α) (M : Matrix m n α) (N : Matrix n o α) :
    vecMul (vecMul v M) N = vecMul v (M ⬝ N) := by
  ext
  apply dot_product_assoc
#align matrix.vec_mul_vec_mul Matrix.vec_mul_vec_mul

@[simp]
theorem mul_vec_mul_vec [Fintype n] [Fintype o] (v : o → α) (M : Matrix m n α) (N : Matrix n o α) :
    mulVec M (mulVec N v) = mulVec (M ⬝ N) v := by
  ext
  symm
  apply dot_product_assoc
#align matrix.mul_vec_mul_vec Matrix.mul_vec_mul_vec

theorem star_mul_vec [Fintype n] [StarRing α] (M : Matrix m n α) (v : n → α) :
    star (M.mulVec v) = vecMul (star v) Mᴴ :=
  funext fun i => (star_dot_product_star _ _).symm
#align matrix.star_mul_vec Matrix.star_mul_vec

theorem star_vec_mul [Fintype m] [StarRing α] (M : Matrix m n α) (v : m → α) :
    star (M.vecMul v) = Mᴴ.mulVec (star v) :=
  funext fun i => (star_dot_product_star _ _).symm
#align matrix.star_vec_mul Matrix.star_vec_mul

theorem mul_vec_conj_transpose [Fintype m] [StarRing α] (A : Matrix m n α) (x : m → α) :
    mulVec Aᴴ x = star (vecMul (star x) A) :=
  funext fun i => star_dot_product _ _
#align matrix.mul_vec_conj_transpose Matrix.mul_vec_conj_transpose

theorem vec_mul_conj_transpose [Fintype n] [StarRing α] (A : Matrix m n α) (x : n → α) :
    vecMul x Aᴴ = star (mulVec A (star x)) :=
  funext fun i => dot_product_star _ _
#align matrix.vec_mul_conj_transpose Matrix.vec_mul_conj_transpose

theorem mul_mul_apply [Fintype n] (A B C : Matrix n n α) (i j : n) :
    (A ⬝ B ⬝ C) i j = A i ⬝ᵥ B.mulVec (Cᵀ j) :=
  by
  rw [Matrix.mul_assoc]
  simpa only [mul_apply, dot_product, mul_vec]
#align matrix.mul_mul_apply Matrix.mul_mul_apply

end NonUnitalSemiring

section NonAssocSemiring

variable [Fintype m] [DecidableEq m] [NonAssocSemiring α]

@[simp]
theorem one_mul_vec (v : m → α) : mulVec 1 v = v :=
  by
  ext
  rw [← diagonal_one, mul_vec_diagonal, one_mul]
#align matrix.one_mul_vec Matrix.one_mul_vec

@[simp]
theorem vec_mul_one (v : m → α) : vecMul v 1 = v :=
  by
  ext
  rw [← diagonal_one, vec_mul_diagonal, mul_one]
#align matrix.vec_mul_one Matrix.vec_mul_one

end NonAssocSemiring

section NonUnitalNonAssocRing

variable [NonUnitalNonAssocRing α]

theorem neg_vec_mul [Fintype m] (v : m → α) (A : Matrix m n α) : vecMul (-v) A = -vecMul v A :=
  by
  ext
  apply neg_dot_product
#align matrix.neg_vec_mul Matrix.neg_vec_mul

theorem vec_mul_neg [Fintype m] (v : m → α) (A : Matrix m n α) : vecMul v (-A) = -vecMul v A :=
  by
  ext
  apply dot_product_neg
#align matrix.vec_mul_neg Matrix.vec_mul_neg

theorem neg_mul_vec [Fintype n] (v : n → α) (A : Matrix m n α) : mulVec (-A) v = -mulVec A v :=
  by
  ext
  apply neg_dot_product
#align matrix.neg_mul_vec Matrix.neg_mul_vec

theorem mul_vec_neg [Fintype n] (v : n → α) (A : Matrix m n α) : mulVec A (-v) = -mulVec A v :=
  by
  ext
  apply dot_product_neg
#align matrix.mul_vec_neg Matrix.mul_vec_neg

theorem sub_mul_vec [Fintype n] (A B : Matrix m n α) (x : n → α) :
    mulVec (A - B) x = mulVec A x - mulVec B x := by simp [sub_eq_add_neg, add_mul_vec, neg_mul_vec]
#align matrix.sub_mul_vec Matrix.sub_mul_vec

theorem vec_mul_sub [Fintype m] (A B : Matrix m n α) (x : m → α) :
    vecMul x (A - B) = vecMul x A - vecMul x B := by simp [sub_eq_add_neg, vec_mul_add, vec_mul_neg]
#align matrix.vec_mul_sub Matrix.vec_mul_sub

end NonUnitalNonAssocRing

section NonUnitalCommSemiring

variable [NonUnitalCommSemiring α]

theorem mul_vec_transpose [Fintype m] (A : Matrix m n α) (x : m → α) : mulVec Aᵀ x = vecMul x A :=
  by
  ext
  apply dot_product_comm
#align matrix.mul_vec_transpose Matrix.mul_vec_transpose

theorem vec_mul_transpose [Fintype n] (A : Matrix m n α) (x : n → α) : vecMul x Aᵀ = mulVec A x :=
  by
  ext
  apply dot_product_comm
#align matrix.vec_mul_transpose Matrix.vec_mul_transpose

theorem mul_vec_vec_mul [Fintype n] [Fintype o] (A : Matrix m n α) (B : Matrix o n α) (x : o → α) :
    mulVec A (vecMul x B) = mulVec (A ⬝ Bᵀ) x := by rw [← mul_vec_mul_vec, mul_vec_transpose]
#align matrix.mul_vec_vec_mul Matrix.mul_vec_vec_mul

theorem vec_mul_mul_vec [Fintype m] [Fintype n] (A : Matrix m n α) (B : Matrix m o α) (x : n → α) :
    vecMul (mulVec A x) B = vecMul x (Aᵀ ⬝ B) := by rw [← vec_mul_vec_mul, vec_mul_transpose]
#align matrix.vec_mul_mul_vec Matrix.vec_mul_mul_vec

end NonUnitalCommSemiring

section CommSemiring

variable [CommSemiring α]

theorem mul_vec_smul_assoc [Fintype n] (A : Matrix m n α) (b : n → α) (a : α) :
    A.mulVec (a • b) = a • A.mulVec b := by
  ext
  apply dot_product_smul
#align matrix.mul_vec_smul_assoc Matrix.mul_vec_smul_assoc

end CommSemiring

section Transpose

open Matrix

/-- Tell `simp` what the entries are in a transposed matrix.

  Compare with `mul_apply`, `diagonal_apply_eq`, etc.
-/
@[simp]
theorem transpose_apply (M : Matrix m n α) (i j) : M.transpose j i = M i j :=
  rfl
#align matrix.transpose_apply Matrix.transpose_apply

@[simp]
theorem transpose_transpose (M : Matrix m n α) : Mᵀᵀ = M := by ext <;> rfl
#align matrix.transpose_transpose Matrix.transpose_transpose

@[simp]
theorem transpose_zero [Zero α] : (0 : Matrix m n α)ᵀ = 0 := by ext (i j) <;> rfl
#align matrix.transpose_zero Matrix.transpose_zero

@[simp]
theorem transpose_one [DecidableEq n] [Zero α] [One α] : (1 : Matrix n n α)ᵀ = 1 :=
  by
  ext (i j)
  unfold One.one transpose
  by_cases i = j
  · simp only [h, diagonal_apply_eq]
  · simp only [diagonal_apply_ne _ h, diagonal_apply_ne' _ h]
#align matrix.transpose_one Matrix.transpose_one

@[simp]
theorem transpose_add [Add α] (M : Matrix m n α) (N : Matrix m n α) : (M + N)ᵀ = Mᵀ + Nᵀ :=
  by
  ext (i j)
  simp
#align matrix.transpose_add Matrix.transpose_add

@[simp]
theorem transpose_sub [Sub α] (M : Matrix m n α) (N : Matrix m n α) : (M - N)ᵀ = Mᵀ - Nᵀ :=
  by
  ext (i j)
  simp
#align matrix.transpose_sub Matrix.transpose_sub

@[simp]
theorem transpose_mul [AddCommMonoid α] [CommSemigroup α] [Fintype n] (M : Matrix m n α)
    (N : Matrix n l α) : (M ⬝ N)ᵀ = Nᵀ ⬝ Mᵀ :=
  by
  ext (i j)
  apply dot_product_comm
#align matrix.transpose_mul Matrix.transpose_mul

@[simp]
theorem transpose_smul {R : Type _} [HasSmul R α] (c : R) (M : Matrix m n α) : (c • M)ᵀ = c • Mᵀ :=
  by
  ext (i j)
  rfl
#align matrix.transpose_smul Matrix.transpose_smul

@[simp]
theorem transpose_neg [Neg α] (M : Matrix m n α) : (-M)ᵀ = -Mᵀ := by ext (i j) <;> rfl
#align matrix.transpose_neg Matrix.transpose_neg

theorem transpose_map {f : α → β} {M : Matrix m n α} : Mᵀ.map f = (M.map f)ᵀ :=
  by
  ext
  rfl
#align matrix.transpose_map Matrix.transpose_map

variable (m n α)

/-- `matrix.transpose` as an `add_equiv` -/
@[simps apply]
def transposeAddEquiv [Add α] : Matrix m n α ≃+ Matrix n m α
    where
  toFun := transpose
  invFun := transpose
  left_inv := transpose_transpose
  right_inv := transpose_transpose
  map_add' := transpose_add
#align matrix.transpose_add_equiv Matrix.transposeAddEquiv

@[simp]
theorem transpose_add_equiv_symm [Add α] :
    (transposeAddEquiv m n α).symm = transposeAddEquiv n m α :=
  rfl
#align matrix.transpose_add_equiv_symm Matrix.transpose_add_equiv_symm

variable {m n α}

theorem transpose_list_sum [AddMonoid α] (l : List (Matrix m n α)) :
    l.Sumᵀ = (l.map transpose).Sum :=
  (transposeAddEquiv m n α).toAddMonoidHom.map_list_sum l
#align matrix.transpose_list_sum Matrix.transpose_list_sum

theorem transpose_multiset_sum [AddCommMonoid α] (s : Multiset (Matrix m n α)) :
    s.Sumᵀ = (s.map transpose).Sum :=
  (transposeAddEquiv m n α).toAddMonoidHom.map_multiset_sum s
#align matrix.transpose_multiset_sum Matrix.transpose_multiset_sum

theorem transpose_sum [AddCommMonoid α] {ι : Type _} (s : Finset ι) (M : ι → Matrix m n α) :
    (∑ i in s, M i)ᵀ = ∑ i in s, (M i)ᵀ :=
  (transposeAddEquiv m n α).toAddMonoidHom.map_sum _ s
#align matrix.transpose_sum Matrix.transpose_sum

variable (m n R α)

/-- `matrix.transpose` as a `linear_map` -/
@[simps apply]
def transposeLinearEquiv [Semiring R] [AddCommMonoid α] [Module R α] :
    Matrix m n α ≃ₗ[R] Matrix n m α :=
  { transposeAddEquiv m n α with map_smul' := transpose_smul }
#align matrix.transpose_linear_equiv Matrix.transposeLinearEquiv

@[simp]
theorem transpose_linear_equiv_symm [Semiring R] [AddCommMonoid α] [Module R α] :
    (transposeLinearEquiv m n R α).symm = transposeLinearEquiv n m R α :=
  rfl
#align matrix.transpose_linear_equiv_symm Matrix.transpose_linear_equiv_symm

variable {m n R α}

variable (m α)

/-- `matrix.transpose` as a `ring_equiv` to the opposite ring -/
@[simps]
def transposeRingEquiv [AddCommMonoid α] [CommSemigroup α] [Fintype m] :
    Matrix m m α ≃+* (Matrix m m α)ᵐᵒᵖ :=
  {
    (transposeAddEquiv m m α).trans
      MulOpposite.opAddEquiv with
    toFun := fun M => MulOpposite.op Mᵀ
    invFun := fun M => M.unopᵀ
    map_mul' := fun M N =>
      (congr_arg MulOpposite.op (transpose_mul M N)).trans (MulOpposite.op_mul _ _) }
#align matrix.transpose_ring_equiv Matrix.transposeRingEquiv

variable {m α}

@[simp]
theorem transpose_pow [CommSemiring α] [Fintype m] [DecidableEq m] (M : Matrix m m α) (k : ℕ) :
    (M ^ k)ᵀ = Mᵀ ^ k :=
  MulOpposite.op_injective <| map_pow (transposeRingEquiv m α) M k
#align matrix.transpose_pow Matrix.transpose_pow

theorem transpose_list_prod [CommSemiring α] [Fintype m] [DecidableEq m] (l : List (Matrix m m α)) :
    l.Prodᵀ = (l.map transpose).reverse.Prod :=
  (transposeRingEquiv m α).unop_map_list_prod l
#align matrix.transpose_list_prod Matrix.transpose_list_prod

variable (R m α)

/-- `matrix.transpose` as an `alg_equiv` to the opposite ring -/
@[simps]
def transposeAlgEquiv [CommSemiring R] [CommSemiring α] [Fintype m] [DecidableEq m] [Algebra R α] :
    Matrix m m α ≃ₐ[R] (Matrix m m α)ᵐᵒᵖ :=
  { (transposeAddEquiv m m α).trans MulOpposite.opAddEquiv,
    transposeRingEquiv m α with
    toFun := fun M => MulOpposite.op Mᵀ
    commutes' := fun r => by
      simp only [algebra_map_eq_diagonal, diagonal_transpose, MulOpposite.algebra_map_apply] }
#align matrix.transpose_alg_equiv Matrix.transposeAlgEquiv

variable {R m α}

end Transpose

section ConjTranspose

open Matrix

/-- Tell `simp` what the entries are in a conjugate transposed matrix.

  Compare with `mul_apply`, `diagonal_apply_eq`, etc.
-/
@[simp]
theorem conj_transpose_apply [HasStar α] (M : Matrix m n α) (i j) :
    M.conjTranspose j i = star (M i j) :=
  rfl
#align matrix.conj_transpose_apply Matrix.conj_transpose_apply

@[simp]
theorem conj_transpose_conj_transpose [HasInvolutiveStar α] (M : Matrix m n α) : Mᴴᴴ = M :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_conj_transpose Matrix.conj_transpose_conj_transpose

@[simp]
theorem conj_transpose_zero [AddMonoid α] [StarAddMonoid α] : (0 : Matrix m n α)ᴴ = 0 :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_zero Matrix.conj_transpose_zero

@[simp]
theorem conj_transpose_one [DecidableEq n] [Semiring α] [StarRing α] : (1 : Matrix n n α)ᴴ = 1 := by
  simp [conj_transpose]
#align matrix.conj_transpose_one Matrix.conj_transpose_one

@[simp]
theorem conj_transpose_add [AddMonoid α] [StarAddMonoid α] (M N : Matrix m n α) :
    (M + N)ᴴ = Mᴴ + Nᴴ :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_add Matrix.conj_transpose_add

@[simp]
theorem conj_transpose_sub [AddGroup α] [StarAddMonoid α] (M N : Matrix m n α) :
    (M - N)ᴴ = Mᴴ - Nᴴ :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_sub Matrix.conj_transpose_sub

/-- Note that `star_module` is quite a strong requirement; as such we also provide the following
variants which this lemma would not apply to:
* `matrix.conj_transpose_smul_non_comm`
* `matrix.conj_transpose_nsmul`
* `matrix.conj_transpose_zsmul`
* `matrix.conj_transpose_nat_cast_smul`
* `matrix.conj_transpose_int_cast_smul`
* `matrix.conj_transpose_inv_nat_cast_smul`
* `matrix.conj_transpose_inv_int_cast_smul`
* `matrix.conj_transpose_rat_smul`
* `matrix.conj_transpose_rat_cast_smul`
-/
@[simp]
theorem conj_transpose_smul [HasStar R] [HasStar α] [HasSmul R α] [StarModule R α] (c : R)
    (M : Matrix m n α) : (c • M)ᴴ = star c • Mᴴ :=
  Matrix.ext fun i j => star_smul _ _
#align matrix.conj_transpose_smul Matrix.conj_transpose_smul

@[simp]
theorem conj_transpose_smul_non_comm [HasStar R] [HasStar α] [HasSmul R α] [HasSmul Rᵐᵒᵖ α] (c : R)
    (M : Matrix m n α) (h : ∀ (r : R) (a : α), star (r • a) = MulOpposite.op (star r) • star a) :
    (c • M)ᴴ = MulOpposite.op (star c) • Mᴴ :=
  Matrix.ext <| by simp [h]
#align matrix.conj_transpose_smul_non_comm Matrix.conj_transpose_smul_non_comm

@[simp]
theorem conj_transpose_smul_self [Semigroup α] [StarSemigroup α] (c : α) (M : Matrix m n α) :
    (c • M)ᴴ = MulOpposite.op (star c) • Mᴴ :=
  conj_transpose_smul_non_comm c M star_mul
#align matrix.conj_transpose_smul_self Matrix.conj_transpose_smul_self

@[simp]
theorem conj_transpose_nsmul [AddMonoid α] [StarAddMonoid α] (c : ℕ) (M : Matrix m n α) :
    (c • M)ᴴ = c • Mᴴ :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_nsmul Matrix.conj_transpose_nsmul

@[simp]
theorem conj_transpose_zsmul [AddGroup α] [StarAddMonoid α] (c : ℤ) (M : Matrix m n α) :
    (c • M)ᴴ = c • Mᴴ :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_zsmul Matrix.conj_transpose_zsmul

@[simp]
theorem conj_transpose_nat_cast_smul [Semiring R] [AddCommMonoid α] [StarAddMonoid α] [Module R α]
    (c : ℕ) (M : Matrix m n α) : ((c : R) • M)ᴴ = (c : R) • Mᴴ :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_nat_cast_smul Matrix.conj_transpose_nat_cast_smul

@[simp]
theorem conj_transpose_int_cast_smul [Ring R] [AddCommGroup α] [StarAddMonoid α] [Module R α]
    (c : ℤ) (M : Matrix m n α) : ((c : R) • M)ᴴ = (c : R) • Mᴴ :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_int_cast_smul Matrix.conj_transpose_int_cast_smul

@[simp]
theorem conj_transpose_inv_nat_cast_smul [DivisionRing R] [AddCommGroup α] [StarAddMonoid α]
    [Module R α] (c : ℕ) (M : Matrix m n α) : ((c : R)⁻¹ • M)ᴴ = (c : R)⁻¹ • Mᴴ :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_inv_nat_cast_smul Matrix.conj_transpose_inv_nat_cast_smul

@[simp]
theorem conj_transpose_inv_int_cast_smul [DivisionRing R] [AddCommGroup α] [StarAddMonoid α]
    [Module R α] (c : ℤ) (M : Matrix m n α) : ((c : R)⁻¹ • M)ᴴ = (c : R)⁻¹ • Mᴴ :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_inv_int_cast_smul Matrix.conj_transpose_inv_int_cast_smul

@[simp]
theorem conj_transpose_rat_cast_smul [DivisionRing R] [AddCommGroup α] [StarAddMonoid α]
    [Module R α] (c : ℚ) (M : Matrix m n α) : ((c : R) • M)ᴴ = (c : R) • Mᴴ :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_rat_cast_smul Matrix.conj_transpose_rat_cast_smul

@[simp]
theorem conj_transpose_rat_smul [AddCommGroup α] [StarAddMonoid α] [Module ℚ α] (c : ℚ)
    (M : Matrix m n α) : (c • M)ᴴ = c • Mᴴ :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_rat_smul Matrix.conj_transpose_rat_smul

@[simp]
theorem conj_transpose_mul [Fintype n] [NonUnitalSemiring α] [StarRing α] (M : Matrix m n α)
    (N : Matrix n l α) : (M ⬝ N)ᴴ = Nᴴ ⬝ Mᴴ :=
  Matrix.ext <| by simp [mul_apply]
#align matrix.conj_transpose_mul Matrix.conj_transpose_mul

@[simp]
theorem conj_transpose_neg [AddGroup α] [StarAddMonoid α] (M : Matrix m n α) : (-M)ᴴ = -Mᴴ :=
  Matrix.ext <| by simp
#align matrix.conj_transpose_neg Matrix.conj_transpose_neg

theorem conj_transpose_map [HasStar α] [HasStar β] {A : Matrix m n α} (f : α → β)
    (hf : Function.Semiconj f star star) : Aᴴ.map f = (A.map f)ᴴ :=
  Matrix.ext fun i j => hf _
#align matrix.conj_transpose_map Matrix.conj_transpose_map

variable (m n α)

/-- `matrix.conj_transpose` as an `add_equiv` -/
@[simps apply]
def conjTransposeAddEquiv [AddMonoid α] [StarAddMonoid α] : Matrix m n α ≃+ Matrix n m α
    where
  toFun := conjTranspose
  invFun := conjTranspose
  left_inv := conj_transpose_conj_transpose
  right_inv := conj_transpose_conj_transpose
  map_add' := conj_transpose_add
#align matrix.conj_transpose_add_equiv Matrix.conjTransposeAddEquiv

@[simp]
theorem conj_transpose_add_equiv_symm [AddMonoid α] [StarAddMonoid α] :
    (conjTransposeAddEquiv m n α).symm = conjTransposeAddEquiv n m α :=
  rfl
#align matrix.conj_transpose_add_equiv_symm Matrix.conj_transpose_add_equiv_symm

variable {m n α}

theorem conj_transpose_list_sum [AddMonoid α] [StarAddMonoid α] (l : List (Matrix m n α)) :
    l.Sumᴴ = (l.map conjTranspose).Sum :=
  (conjTransposeAddEquiv m n α).toAddMonoidHom.map_list_sum l
#align matrix.conj_transpose_list_sum Matrix.conj_transpose_list_sum

theorem conj_transpose_multiset_sum [AddCommMonoid α] [StarAddMonoid α]
    (s : Multiset (Matrix m n α)) : s.Sumᴴ = (s.map conjTranspose).Sum :=
  (conjTransposeAddEquiv m n α).toAddMonoidHom.map_multiset_sum s
#align matrix.conj_transpose_multiset_sum Matrix.conj_transpose_multiset_sum

theorem conj_transpose_sum [AddCommMonoid α] [StarAddMonoid α] {ι : Type _} (s : Finset ι)
    (M : ι → Matrix m n α) : (∑ i in s, M i)ᴴ = ∑ i in s, (M i)ᴴ :=
  (conjTransposeAddEquiv m n α).toAddMonoidHom.map_sum _ s
#align matrix.conj_transpose_sum Matrix.conj_transpose_sum

variable (m n R α)

/-- `matrix.conj_transpose` as a `linear_map` -/
@[simps apply]
def conjTransposeLinearEquiv [CommSemiring R] [StarRing R] [AddCommMonoid α] [StarAddMonoid α]
    [Module R α] [StarModule R α] : Matrix m n α ≃ₗ⋆[R] Matrix n m α :=
  { conjTransposeAddEquiv m n α with map_smul' := conj_transpose_smul }
#align matrix.conj_transpose_linear_equiv Matrix.conjTransposeLinearEquiv

@[simp]
theorem conj_transpose_linear_equiv_symm [CommSemiring R] [StarRing R] [AddCommMonoid α]
    [StarAddMonoid α] [Module R α] [StarModule R α] :
    (conjTransposeLinearEquiv m n R α).symm = conjTransposeLinearEquiv n m R α :=
  rfl
#align matrix.conj_transpose_linear_equiv_symm Matrix.conj_transpose_linear_equiv_symm

variable {m n R α}

variable (m α)

/-- `matrix.conj_transpose` as a `ring_equiv` to the opposite ring -/
@[simps]
def conjTransposeRingEquiv [Semiring α] [StarRing α] [Fintype m] :
    Matrix m m α ≃+* (Matrix m m α)ᵐᵒᵖ :=
  {
    (conjTransposeAddEquiv m m α).trans
      MulOpposite.opAddEquiv with
    toFun := fun M => MulOpposite.op Mᴴ
    invFun := fun M => M.unopᴴ
    map_mul' := fun M N =>
      (congr_arg MulOpposite.op (conj_transpose_mul M N)).trans (MulOpposite.op_mul _ _) }
#align matrix.conj_transpose_ring_equiv Matrix.conjTransposeRingEquiv

variable {m α}

@[simp]
theorem conj_transpose_pow [Semiring α] [StarRing α] [Fintype m] [DecidableEq m] (M : Matrix m m α)
    (k : ℕ) : (M ^ k)ᴴ = Mᴴ ^ k :=
  MulOpposite.op_injective <| map_pow (conjTransposeRingEquiv m α) M k
#align matrix.conj_transpose_pow Matrix.conj_transpose_pow

theorem conj_transpose_list_prod [Semiring α] [StarRing α] [Fintype m] [DecidableEq m]
    (l : List (Matrix m m α)) : l.Prodᴴ = (l.map conjTranspose).reverse.Prod :=
  (conjTransposeRingEquiv m α).unop_map_list_prod l
#align matrix.conj_transpose_list_prod Matrix.conj_transpose_list_prod

end ConjTranspose

section Star

/-- When `α` has a star operation, square matrices `matrix n n α` have a star
operation equal to `matrix.conj_transpose`. -/
instance [HasStar α] : HasStar (Matrix n n α) where star := conjTranspose

theorem star_eq_conj_transpose [HasStar α] (M : Matrix m m α) : star M = Mᴴ :=
  rfl
#align matrix.star_eq_conj_transpose Matrix.star_eq_conj_transpose

@[simp]
theorem star_apply [HasStar α] (M : Matrix n n α) (i j) : (star M) i j = star (M j i) :=
  rfl
#align matrix.star_apply Matrix.star_apply

instance [HasInvolutiveStar α] : HasInvolutiveStar (Matrix n n α)
    where star_involutive := conj_transpose_conj_transpose

/-- When `α` is a `*`-additive monoid, `matrix.has_star` is also a `*`-additive monoid. -/
instance [AddMonoid α] [StarAddMonoid α] : StarAddMonoid (Matrix n n α)
    where star_add := conj_transpose_add

/-- When `α` is a `*`-(semi)ring, `matrix.has_star` is also a `*`-(semi)ring. -/
instance [Fintype n] [Semiring α] [StarRing α] : StarRing (Matrix n n α)
    where
  star_add := conj_transpose_add
  star_mul := conj_transpose_mul

/-- A version of `star_mul` for `⬝` instead of `*`. -/
theorem star_mul [Fintype n] [NonUnitalSemiring α] [StarRing α] (M N : Matrix n n α) :
    star (M ⬝ N) = star N ⬝ star M :=
  conj_transpose_mul _ _
#align matrix.star_mul Matrix.star_mul

end Star

/-- Given maps `(r_reindex : l → m)` and  `(c_reindex : o → n)` reindexing the rows and columns of
a matrix `M : matrix m n α`, the matrix `M.submatrix r_reindex c_reindex : matrix l o α` is defined
by `(M.submatrix r_reindex c_reindex) i j = M (r_reindex i) (c_reindex j)` for `(i,j) : l × o`.
Note that the total number of row and columns does not have to be preserved. -/
def submatrix (A : Matrix m n α) (r_reindex : l → m) (c_reindex : o → n) : Matrix l o α :=
  of fun i j => A (r_reindex i) (c_reindex j)
#align matrix.submatrix Matrix.submatrix

@[simp]
theorem submatrix_apply (A : Matrix m n α) (r_reindex : l → m) (c_reindex : o → n) (i j) :
    A.submatrix r_reindex c_reindex i j = A (r_reindex i) (c_reindex j) :=
  rfl
#align matrix.submatrix_apply Matrix.submatrix_apply

@[simp]
theorem submatrix_id_id (A : Matrix m n α) : A.submatrix id id = A :=
  ext fun _ _ => rfl
#align matrix.submatrix_id_id Matrix.submatrix_id_id

@[simp]
theorem submatrix_submatrix {l₂ o₂ : Type _} (A : Matrix m n α) (r₁ : l → m) (c₁ : o → n)
    (r₂ : l₂ → l) (c₂ : o₂ → o) :
    (A.submatrix r₁ c₁).submatrix r₂ c₂ = A.submatrix (r₁ ∘ r₂) (c₁ ∘ c₂) :=
  ext fun _ _ => rfl
#align matrix.submatrix_submatrix Matrix.submatrix_submatrix

@[simp]
theorem transpose_submatrix (A : Matrix m n α) (r_reindex : l → m) (c_reindex : o → n) :
    (A.submatrix r_reindex c_reindex)ᵀ = Aᵀ.submatrix c_reindex r_reindex :=
  ext fun _ _ => rfl
#align matrix.transpose_submatrix Matrix.transpose_submatrix

@[simp]
theorem conj_transpose_submatrix [HasStar α] (A : Matrix m n α) (r_reindex : l → m)
    (c_reindex : o → n) : (A.submatrix r_reindex c_reindex)ᴴ = Aᴴ.submatrix c_reindex r_reindex :=
  ext fun _ _ => rfl
#align matrix.conj_transpose_submatrix Matrix.conj_transpose_submatrix

theorem submatrix_add [Add α] (A B : Matrix m n α) :
    ((A + B).submatrix : (l → m) → (o → n) → Matrix l o α) = A.submatrix + B.submatrix :=
  rfl
#align matrix.submatrix_add Matrix.submatrix_add

theorem submatrix_neg [Neg α] (A : Matrix m n α) :
    ((-A).submatrix : (l → m) → (o → n) → Matrix l o α) = -A.submatrix :=
  rfl
#align matrix.submatrix_neg Matrix.submatrix_neg

theorem submatrix_sub [Sub α] (A B : Matrix m n α) :
    ((A - B).submatrix : (l → m) → (o → n) → Matrix l o α) = A.submatrix - B.submatrix :=
  rfl
#align matrix.submatrix_sub Matrix.submatrix_sub

@[simp]
theorem submatrix_zero [Zero α] :
    ((0 : Matrix m n α).submatrix : (l → m) → (o → n) → Matrix l o α) = 0 :=
  rfl
#align matrix.submatrix_zero Matrix.submatrix_zero

theorem submatrix_smul {R : Type _} [HasSmul R α] (r : R) (A : Matrix m n α) :
    ((r • A : Matrix m n α).submatrix : (l → m) → (o → n) → Matrix l o α) = r • A.submatrix :=
  rfl
#align matrix.submatrix_smul Matrix.submatrix_smul

theorem submatrix_map (f : α → β) (e₁ : l → m) (e₂ : o → n) (A : Matrix m n α) :
    (A.map f).submatrix e₁ e₂ = (A.submatrix e₁ e₂).map f :=
  rfl
#align matrix.submatrix_map Matrix.submatrix_map

/-- Given a `(m × m)` diagonal matrix defined by a map `d : m → α`, if the reindexing map `e` is
  injective, then the resulting matrix is again diagonal. -/
theorem submatrix_diagonal [Zero α] [DecidableEq m] [DecidableEq l] (d : m → α) (e : l → m)
    (he : Function.Injective e) : (diagonal d).submatrix e e = diagonal (d ∘ e) :=
  ext fun i j => by
    rw [submatrix_apply]
    by_cases h : i = j
    · rw [h, diagonal_apply_eq, diagonal_apply_eq]
    · rw [diagonal_apply_ne _ h, diagonal_apply_ne _ (he.ne h)]
#align matrix.submatrix_diagonal Matrix.submatrix_diagonal

theorem submatrix_one [Zero α] [One α] [DecidableEq m] [DecidableEq l] (e : l → m)
    (he : Function.Injective e) : (1 : Matrix m m α).submatrix e e = 1 :=
  submatrix_diagonal _ e he
#align matrix.submatrix_one Matrix.submatrix_one

theorem submatrix_mul [Fintype n] [Fintype o] [Mul α] [AddCommMonoid α] {p q : Type _}
    (M : Matrix m n α) (N : Matrix n p α) (e₁ : l → m) (e₂ : o → n) (e₃ : q → p)
    (he₂ : Function.Bijective e₂) :
    (M ⬝ N).submatrix e₁ e₃ = M.submatrix e₁ e₂ ⬝ N.submatrix e₂ e₃ :=
  ext fun _ _ => (he₂.sum_comp _).symm
#align matrix.submatrix_mul Matrix.submatrix_mul

theorem diag_submatrix (A : Matrix m m α) (e : l → m) : diag (A.submatrix e e) = A.diag ∘ e :=
  rfl
#align matrix.diag_submatrix Matrix.diag_submatrix

/-! `simp` lemmas for `matrix.submatrix`s interaction with `matrix.diagonal`, `1`, and `matrix.mul`
for when the mappings are bundled. -/


@[simp]
theorem submatrix_diagonal_embedding [Zero α] [DecidableEq m] [DecidableEq l] (d : m → α)
    (e : l ↪ m) : (diagonal d).submatrix e e = diagonal (d ∘ e) :=
  submatrix_diagonal d e e.Injective
#align matrix.submatrix_diagonal_embedding Matrix.submatrix_diagonal_embedding

@[simp]
theorem submatrix_diagonal_equiv [Zero α] [DecidableEq m] [DecidableEq l] (d : m → α) (e : l ≃ m) :
    (diagonal d).submatrix e e = diagonal (d ∘ e) :=
  submatrix_diagonal d e e.Injective
#align matrix.submatrix_diagonal_equiv Matrix.submatrix_diagonal_equiv

@[simp]
theorem submatrix_one_embedding [Zero α] [One α] [DecidableEq m] [DecidableEq l] (e : l ↪ m) :
    (1 : Matrix m m α).submatrix e e = 1 :=
  submatrix_one e e.Injective
#align matrix.submatrix_one_embedding Matrix.submatrix_one_embedding

@[simp]
theorem submatrix_one_equiv [Zero α] [One α] [DecidableEq m] [DecidableEq l] (e : l ≃ m) :
    (1 : Matrix m m α).submatrix e e = 1 :=
  submatrix_one e e.Injective
#align matrix.submatrix_one_equiv Matrix.submatrix_one_equiv

@[simp]
theorem submatrix_mul_equiv [Fintype n] [Fintype o] [AddCommMonoid α] [Mul α] {p q : Type _}
    (M : Matrix m n α) (N : Matrix n p α) (e₁ : l → m) (e₂ : o ≃ n) (e₃ : q → p) :
    M.submatrix e₁ e₂ ⬝ N.submatrix e₂ e₃ = (M ⬝ N).submatrix e₁ e₃ :=
  (submatrix_mul M N e₁ e₂ e₃ e₂.Bijective).symm
#align matrix.submatrix_mul_equiv Matrix.submatrix_mul_equiv

theorem mul_submatrix_one [Fintype n] [Fintype o] [NonAssocSemiring α] [DecidableEq o] (e₁ : n ≃ o)
    (e₂ : l → o) (M : Matrix m n α) :
    M ⬝ (1 : Matrix o o α).submatrix e₁ e₂ = submatrix M id (e₁.symm ∘ e₂) :=
  by
  let A := M.submatrix id e₁.symm
  have : M = A.submatrix id e₁ := by
    simp only [submatrix_submatrix, Function.comp.right_id, submatrix_id_id, Equiv.symm_comp_self]
  rw [this, submatrix_mul_equiv]
  simp only [Matrix.mul_one, submatrix_submatrix, Function.comp.right_id, submatrix_id_id,
    Equiv.symm_comp_self]
#align matrix.mul_submatrix_one Matrix.mul_submatrix_one

theorem one_submatrix_mul [Fintype m] [Fintype o] [NonAssocSemiring α] [DecidableEq o] (e₁ : l → o)
    (e₂ : m ≃ o) (M : Matrix m n α) :
    ((1 : Matrix o o α).submatrix e₁ e₂).mul M = submatrix M (e₂.symm ∘ e₁) id :=
  by
  let A := M.submatrix e₂.symm id
  have : M = A.submatrix e₂ id := by
    simp only [submatrix_submatrix, Function.comp.right_id, submatrix_id_id, Equiv.symm_comp_self]
  rw [this, submatrix_mul_equiv]
  simp only [Matrix.one_mul, submatrix_submatrix, Function.comp.right_id, submatrix_id_id,
    Equiv.symm_comp_self]
#align matrix.one_submatrix_mul Matrix.one_submatrix_mul

/-- The natural map that reindexes a matrix's rows and columns with equivalent types is an
equivalence. -/
def reindex (eₘ : m ≃ l) (eₙ : n ≃ o) : Matrix m n α ≃ Matrix l o α
    where
  toFun M := M.submatrix eₘ.symm eₙ.symm
  invFun M := M.submatrix eₘ eₙ
  left_inv M := by simp
  right_inv M := by simp
#align matrix.reindex Matrix.reindex

@[simp]
theorem reindex_apply (eₘ : m ≃ l) (eₙ : n ≃ o) (M : Matrix m n α) :
    reindex eₘ eₙ M = M.submatrix eₘ.symm eₙ.symm :=
  rfl
#align matrix.reindex_apply Matrix.reindex_apply

@[simp]
theorem reindex_refl_refl (A : Matrix m n α) : reindex (Equiv.refl _) (Equiv.refl _) A = A :=
  A.submatrix_id_id
#align matrix.reindex_refl_refl Matrix.reindex_refl_refl

@[simp]
theorem reindex_symm (eₘ : m ≃ l) (eₙ : n ≃ o) :
    (reindex eₘ eₙ).symm = (reindex eₘ.symm eₙ.symm : Matrix l o α ≃ _) :=
  rfl
#align matrix.reindex_symm Matrix.reindex_symm

@[simp]
theorem reindex_trans {l₂ o₂ : Type _} (eₘ : m ≃ l) (eₙ : n ≃ o) (eₘ₂ : l ≃ l₂) (eₙ₂ : o ≃ o₂) :
    (reindex eₘ eₙ).trans (reindex eₘ₂ eₙ₂) =
      (reindex (eₘ.trans eₘ₂) (eₙ.trans eₙ₂) : Matrix m n α ≃ _) :=
  Equiv.ext fun A => (A.submatrix_submatrix eₘ.symm eₙ.symm eₘ₂.symm eₙ₂.symm : _)
#align matrix.reindex_trans Matrix.reindex_trans

theorem transpose_reindex (eₘ : m ≃ l) (eₙ : n ≃ o) (M : Matrix m n α) :
    (reindex eₘ eₙ M)ᵀ = reindex eₙ eₘ Mᵀ :=
  rfl
#align matrix.transpose_reindex Matrix.transpose_reindex

theorem conj_transpose_reindex [HasStar α] (eₘ : m ≃ l) (eₙ : n ≃ o) (M : Matrix m n α) :
    (reindex eₘ eₙ M)ᴴ = reindex eₙ eₘ Mᴴ :=
  rfl
#align matrix.conj_transpose_reindex Matrix.conj_transpose_reindex

@[simp]
theorem submatrix_mul_transpose_submatrix [Fintype m] [Fintype n] [AddCommMonoid α] [Mul α]
    (e : m ≃ n) (M : Matrix m n α) : M.submatrix id e ⬝ Mᵀ.submatrix e id = M ⬝ Mᵀ := by
  rw [submatrix_mul_equiv, submatrix_id_id]
#align matrix.submatrix_mul_transpose_submatrix Matrix.submatrix_mul_transpose_submatrix

/-- The left `n × l` part of a `n × (l+r)` matrix. -/
@[reducible]
def subLeft {m l r : Nat} (A : Matrix (Fin m) (Fin (l + r)) α) : Matrix (Fin m) (Fin l) α :=
  submatrix A id (Fin.castAdd r)
#align matrix.sub_left Matrix.subLeft

/-- The right `n × r` part of a `n × (l+r)` matrix. -/
@[reducible]
def subRight {m l r : Nat} (A : Matrix (Fin m) (Fin (l + r)) α) : Matrix (Fin m) (Fin r) α :=
  submatrix A id (Fin.natAdd l)
#align matrix.sub_right Matrix.subRight

/-- The top `u × n` part of a `(u+d) × n` matrix. -/
@[reducible]
def subUp {d u n : Nat} (A : Matrix (Fin (u + d)) (Fin n) α) : Matrix (Fin u) (Fin n) α :=
  submatrix A (Fin.castAdd d) id
#align matrix.sub_up Matrix.subUp

/-- The bottom `d × n` part of a `(u+d) × n` matrix. -/
@[reducible]
def subDown {d u n : Nat} (A : Matrix (Fin (u + d)) (Fin n) α) : Matrix (Fin d) (Fin n) α :=
  submatrix A (Fin.natAdd u) id
#align matrix.sub_down Matrix.subDown

/-- The top-right `u × r` part of a `(u+d) × (l+r)` matrix. -/
@[reducible]
def subUpRight {d u l r : Nat} (A : Matrix (Fin (u + d)) (Fin (l + r)) α) :
    Matrix (Fin u) (Fin r) α :=
  subUp (subRight A)
#align matrix.sub_up_right Matrix.subUpRight

/-- The bottom-right `d × r` part of a `(u+d) × (l+r)` matrix. -/
@[reducible]
def subDownRight {d u l r : Nat} (A : Matrix (Fin (u + d)) (Fin (l + r)) α) :
    Matrix (Fin d) (Fin r) α :=
  subDown (subRight A)
#align matrix.sub_down_right Matrix.subDownRight

/-- The top-left `u × l` part of a `(u+d) × (l+r)` matrix. -/
@[reducible]
def subUpLeft {d u l r : Nat} (A : Matrix (Fin (u + d)) (Fin (l + r)) α) :
    Matrix (Fin u) (Fin l) α :=
  subUp (subLeft A)
#align matrix.sub_up_left Matrix.subUpLeft

/-- The bottom-left `d × l` part of a `(u+d) × (l+r)` matrix. -/
@[reducible]
def subDownLeft {d u l r : Nat} (A : Matrix (Fin (u + d)) (Fin (l + r)) α) :
    Matrix (Fin d) (Fin l) α :=
  subDown (subLeft A)
#align matrix.sub_down_left Matrix.subDownLeft

section RowCol

/-!
### `row_col` section

Simplification lemmas for `matrix.row` and `matrix.col`.
-/


open Matrix

@[simp]
theorem col_add [Add α] (v w : m → α) : col (v + w) = col v + col w :=
  by
  ext
  rfl
#align matrix.col_add Matrix.col_add

@[simp]
theorem col_smul [HasSmul R α] (x : R) (v : m → α) : col (x • v) = x • col v :=
  by
  ext
  rfl
#align matrix.col_smul Matrix.col_smul

@[simp]
theorem row_add [Add α] (v w : m → α) : row (v + w) = row v + row w :=
  by
  ext
  rfl
#align matrix.row_add Matrix.row_add

@[simp]
theorem row_smul [HasSmul R α] (x : R) (v : m → α) : row (x • v) = x • row v :=
  by
  ext
  rfl
#align matrix.row_smul Matrix.row_smul

@[simp]
theorem col_apply (v : m → α) (i j) : Matrix.col v i j = v i :=
  rfl
#align matrix.col_apply Matrix.col_apply

@[simp]
theorem row_apply (v : m → α) (i j) : Matrix.row v i j = v j :=
  rfl
#align matrix.row_apply Matrix.row_apply

@[simp]
theorem transpose_col (v : m → α) : (Matrix.col v)ᵀ = Matrix.row v :=
  by
  ext
  rfl
#align matrix.transpose_col Matrix.transpose_col

@[simp]
theorem transpose_row (v : m → α) : (Matrix.row v)ᵀ = Matrix.col v :=
  by
  ext
  rfl
#align matrix.transpose_row Matrix.transpose_row

@[simp]
theorem conj_transpose_col [HasStar α] (v : m → α) : (col v)ᴴ = row (star v) :=
  by
  ext
  rfl
#align matrix.conj_transpose_col Matrix.conj_transpose_col

@[simp]
theorem conj_transpose_row [HasStar α] (v : m → α) : (row v)ᴴ = col (star v) :=
  by
  ext
  rfl
#align matrix.conj_transpose_row Matrix.conj_transpose_row

theorem row_vec_mul [Fintype m] [NonUnitalNonAssocSemiring α] (M : Matrix m n α) (v : m → α) :
    Matrix.row (Matrix.vecMul v M) = Matrix.row v ⬝ M :=
  by
  ext
  rfl
#align matrix.row_vec_mul Matrix.row_vec_mul

theorem col_vec_mul [Fintype m] [NonUnitalNonAssocSemiring α] (M : Matrix m n α) (v : m → α) :
    Matrix.col (Matrix.vecMul v M) = (Matrix.row v ⬝ M)ᵀ :=
  by
  ext
  rfl
#align matrix.col_vec_mul Matrix.col_vec_mul

theorem col_mul_vec [Fintype n] [NonUnitalNonAssocSemiring α] (M : Matrix m n α) (v : n → α) :
    Matrix.col (Matrix.mulVec M v) = M ⬝ Matrix.col v :=
  by
  ext
  rfl
#align matrix.col_mul_vec Matrix.col_mul_vec

theorem row_mul_vec [Fintype n] [NonUnitalNonAssocSemiring α] (M : Matrix m n α) (v : n → α) :
    Matrix.row (Matrix.mulVec M v) = (M ⬝ Matrix.col v)ᵀ :=
  by
  ext
  rfl
#align matrix.row_mul_vec Matrix.row_mul_vec

@[simp]
theorem row_mul_col_apply [Fintype m] [Mul α] [AddCommMonoid α] (v w : m → α) (i j) :
    (row v ⬝ col w) i j = v ⬝ᵥ w :=
  rfl
#align matrix.row_mul_col_apply Matrix.row_mul_col_apply

end RowCol

section Update

/-- Update, i.e. replace the `i`th row of matrix `A` with the values in `b`. -/
def updateRow [DecidableEq m] (M : Matrix m n α) (i : m) (b : n → α) : Matrix m n α :=
  Function.update M i b
#align matrix.update_row Matrix.updateRow

/-- Update, i.e. replace the `j`th column of matrix `A` with the values in `b`. -/
def updateColumn [DecidableEq n] (M : Matrix m n α) (j : n) (b : m → α) : Matrix m n α := fun i =>
  Function.update (M i) j (b i)
#align matrix.update_column Matrix.updateColumn

variable {M : Matrix m n α} {i : m} {j : n} {b : n → α} {c : m → α}

@[simp]
theorem update_row_self [DecidableEq m] : updateRow M i b i = b :=
  Function.update_same i b M
#align matrix.update_row_self Matrix.update_row_self

@[simp]
theorem update_column_self [DecidableEq n] : updateColumn M j c i j = c i :=
  Function.update_same j (c i) (M i)
#align matrix.update_column_self Matrix.update_column_self

@[simp]
theorem update_row_ne [DecidableEq m] {i' : m} (i_ne : i' ≠ i) : updateRow M i b i' = M i' :=
  Function.update_noteq i_ne b M
#align matrix.update_row_ne Matrix.update_row_ne

@[simp]
theorem update_column_ne [DecidableEq n] {j' : n} (j_ne : j' ≠ j) :
    updateColumn M j c i j' = M i j' :=
  Function.update_noteq j_ne (c i) (M i)
#align matrix.update_column_ne Matrix.update_column_ne

theorem update_row_apply [DecidableEq m] {i' : m} :
    updateRow M i b i' j = if i' = i then b j else M i' j :=
  by
  by_cases i' = i
  · rw [h, update_row_self, if_pos rfl]
  · rwa [update_row_ne h, if_neg h]
#align matrix.update_row_apply Matrix.update_row_apply

theorem update_column_apply [DecidableEq n] {j' : n} :
    updateColumn M j c i j' = if j' = j then c i else M i j' :=
  by
  by_cases j' = j
  · rw [h, update_column_self, if_pos rfl]
  · rwa [update_column_ne h, if_neg h]
#align matrix.update_column_apply Matrix.update_column_apply

@[simp]
theorem update_column_subsingleton [Subsingleton n] (A : Matrix m n R) (i : n) (b : m → R) :
    A.updateColumn i b = (col b).submatrix id (Function.const n ()) :=
  by
  ext (x y)
  simp [update_column_apply, Subsingleton.elim i y]
#align matrix.update_column_subsingleton Matrix.update_column_subsingleton

@[simp]
theorem update_row_subsingleton [Subsingleton m] (A : Matrix m n R) (i : m) (b : n → R) :
    A.updateRow i b = (row b).submatrix (Function.const m ()) id :=
  by
  ext (x y)
  simp [update_column_apply, Subsingleton.elim i x]
#align matrix.update_row_subsingleton Matrix.update_row_subsingleton

theorem map_update_row [DecidableEq m] (f : α → β) :
    map (updateRow M i b) f = updateRow (M.map f) i (f ∘ b) :=
  by
  ext (i' j')
  rw [update_row_apply, map_apply, map_apply, update_row_apply]
  exact apply_ite f _ _ _
#align matrix.map_update_row Matrix.map_update_row

theorem map_update_column [DecidableEq n] (f : α → β) :
    map (updateColumn M j c) f = updateColumn (M.map f) j (f ∘ c) :=
  by
  ext (i' j')
  rw [update_column_apply, map_apply, map_apply, update_column_apply]
  exact apply_ite f _ _ _
#align matrix.map_update_column Matrix.map_update_column

theorem update_row_transpose [DecidableEq n] : updateRow Mᵀ j c = (updateColumn M j c)ᵀ :=
  by
  ext (i' j)
  rw [transpose_apply, update_row_apply, update_column_apply]
  rfl
#align matrix.update_row_transpose Matrix.update_row_transpose

theorem update_column_transpose [DecidableEq m] : updateColumn Mᵀ i b = (updateRow M i b)ᵀ :=
  by
  ext (i' j)
  rw [transpose_apply, update_row_apply, update_column_apply]
  rfl
#align matrix.update_column_transpose Matrix.update_column_transpose

theorem update_row_conj_transpose [DecidableEq n] [HasStar α] :
    updateRow Mᴴ j (star c) = (updateColumn M j c)ᴴ :=
  by
  rw [conj_transpose, conj_transpose, transpose_map, transpose_map, update_row_transpose,
    map_update_column]
  rfl
#align matrix.update_row_conj_transpose Matrix.update_row_conj_transpose

theorem update_column_conj_transpose [DecidableEq m] [HasStar α] :
    updateColumn Mᴴ i (star b) = (updateRow M i b)ᴴ :=
  by
  rw [conj_transpose, conj_transpose, transpose_map, transpose_map, update_column_transpose,
    map_update_row]
  rfl
#align matrix.update_column_conj_transpose Matrix.update_column_conj_transpose

@[simp]
theorem update_row_eq_self [DecidableEq m] (A : Matrix m n α) (i : m) : A.updateRow i (A i) = A :=
  Function.update_eq_self i A
#align matrix.update_row_eq_self Matrix.update_row_eq_self

@[simp]
theorem update_column_eq_self [DecidableEq n] (A : Matrix m n α) (i : n) :
    (A.updateColumn i fun j => A j i) = A :=
  funext fun j => Function.update_eq_self i (A j)
#align matrix.update_column_eq_self Matrix.update_column_eq_self

theorem diagonal_update_column_single [DecidableEq n] [Zero α] (v : n → α) (i : n) (x : α) :
    (diagonal v).updateColumn i (Pi.single i x) = diagonal (Function.update v i x) :=
  by
  ext (j k)
  obtain rfl | hjk := eq_or_ne j k
  · rw [diagonal_apply_eq]
    obtain rfl | hji := eq_or_ne j i
    · rw [update_column_self, Pi.single_eq_same, Function.update_same]
    · rw [update_column_ne hji, diagonal_apply_eq, Function.update_noteq hji]
  · rw [diagonal_apply_ne _ hjk]
    obtain rfl | hki := eq_or_ne k i
    · rw [update_column_self, Pi.single_eq_of_ne hjk]
    · rw [update_column_ne hki, diagonal_apply_ne _ hjk]
#align matrix.diagonal_update_column_single Matrix.diagonal_update_column_single

theorem diagonal_update_row_single [DecidableEq n] [Zero α] (v : n → α) (i : n) (x : α) :
    (diagonal v).updateRow i (Pi.single i x) = diagonal (Function.update v i x) := by
  rw [← diagonal_transpose, update_row_transpose, diagonal_update_column_single, diagonal_transpose]
#align matrix.diagonal_update_row_single Matrix.diagonal_update_row_single

end Update

end Matrix

namespace RingHom

variable [Fintype n] [NonAssocSemiring α] [NonAssocSemiring β]

theorem map_matrix_mul (M : Matrix m n α) (N : Matrix n o α) (i : m) (j : o) (f : α →+* β) :
    f (Matrix.mul M N i j) = Matrix.mul (M.map f) (N.map f) i j := by
  simp [Matrix.mul_apply, RingHom.map_sum]
#align ring_hom.map_matrix_mul RingHom.map_matrix_mul

theorem map_dot_product [NonAssocSemiring R] [NonAssocSemiring S] (f : R →+* S) (v w : n → R) :
    f (v ⬝ᵥ w) = f ∘ v ⬝ᵥ f ∘ w := by simp only [Matrix.dotProduct, f.map_sum, f.map_mul]
#align ring_hom.map_dot_product RingHom.map_dot_product

theorem map_vec_mul [NonAssocSemiring R] [NonAssocSemiring S] (f : R →+* S) (M : Matrix n m R)
    (v : n → R) (i : m) : f (M.vecMul v i) = (M.map f).vecMul (f ∘ v) i := by
  simp only [Matrix.vecMul, Matrix.map_apply, RingHom.map_dot_product]
#align ring_hom.map_vec_mul RingHom.map_vec_mul

theorem map_mul_vec [NonAssocSemiring R] [NonAssocSemiring S] (f : R →+* S) (M : Matrix m n R)
    (v : n → R) (i : m) : f (M.mulVec v i) = (M.map f).mulVec (f ∘ v) i := by
  simp only [Matrix.mulVec, Matrix.map_apply, RingHom.map_dot_product]
#align ring_hom.map_mul_vec RingHom.map_mul_vec

end RingHom

