import Mathbin.Data.Fin.Tuple 
import Mathbin.Data.List.Range 
import Mathbin.GroupTheory.GroupAction.Pi

/-!
# Matrix and vector notation

This file defines notation for vectors and matrices. Given `a b c d : α`,
the notation allows us to write `![a, b, c, d] : fin 4 → α`.
Nesting vectors gives a matrix, so `![![a, b], ![c, d]] : fin 2 → fin 2 → α`.
Later we will define `matrix m n α` to be `m → n → α`, so the type of `![![a, b], ![c, d]]`
can be written as `matrix (fin 2) (fin 2) α`.

## Main definitions

* `vec_empty` is the empty vector (or `0` by `n` matrix) `![]`
* `vec_cons` prepends an entry to a vector, so `![a, b]` is `vec_cons a (vec_cons b vec_empty)`

## Implementation notes

The `simp` lemmas require that one of the arguments is of the form `vec_cons _ _`.
This ensures `simp` works with entries only when (some) entries are already given.
In other words, this notation will only appear in the output of `simp` if it
already appears in the input.

## Notations

The main new notation is `![a, b]`, which gets expanded to `vec_cons a (vec_cons b vec_empty)`.

## Examples

Examples of usage can be found in the `test/matrix.lean` file.
-/


namespace Matrix

universe u

variable {α : Type u}

section MatrixNotation

/-- `![]` is the vector with no entries. -/
def vec_empty : Finₓ 0 → α :=
  finZeroElim

/-- `vec_cons h t` prepends an entry `h` to a vector `t`.

The inverse functions are `vec_head` and `vec_tail`.
The notation `![a, b, ...]` expands to `vec_cons a (vec_cons b ...)`.
-/
def vec_cons {n : ℕ} (h : α) (t : Finₓ n → α) : Finₓ n.succ → α :=
  Finₓ.cons h t

-- error in Data.Fin.VecNotation: ././Mathport/Syntax/Translate/Basic.lean:1104:9: unsupported: advanced notation (l:(foldr `, ` (h t, vec_cons h t) vec_empty `]`))
notation `![` l:(foldr `, ` (h t, vec_cons h t) vec_empty `]`) := l

/-- `vec_head v` gives the first entry of the vector `v` -/
def vec_head {n : ℕ} (v : Finₓ n.succ → α) : α :=
  v 0

/-- `vec_tail v` gives a vector consisting of all entries of `v` except the first -/
def vec_tail {n : ℕ} (v : Finₓ n.succ → α) : Finₓ n → α :=
  v ∘ Finₓ.succ

variable {m n : ℕ}

/-- Use `![...]` notation for displaying a vector `fin n → α`, for example:

```
#eval ![1, 2] + ![3, 4] -- ![4, 6]
```
-/
instance pi_fin.has_repr [HasRepr α] : HasRepr (Finₓ n → α) :=
  { repr := fun f => "![" ++ Stringₓ.intercalate ", " ((List.finRange n).map fun n => reprₓ (f n)) ++ "]" }

end MatrixNotation

variable {m n o : ℕ} {m' n' o' : Type _}

-- error in Data.Fin.VecNotation: ././Mathport/Syntax/Translate/Basic.lean:558:61: unsupported notation `«expr![ , ]»
theorem empty_eq (v : fin 0 → α) : «expr = »(v, «expr![ , ]»([])) := subsingleton.elim _ _

section Val

@[simp]
theorem head_fin_const (a : α) : (vec_head fun i : Finₓ (n+1) => a) = a :=
  rfl

@[simp]
theorem cons_val_zero (x : α) (u : Finₓ m → α) : vec_cons x u 0 = x :=
  rfl

theorem cons_val_zero' (h : 0 < m.succ) (x : α) (u : Finₓ m → α) : vec_cons x u ⟨0, h⟩ = x :=
  rfl

@[simp]
theorem cons_val_succ (x : α) (u : Finₓ m → α) (i : Finₓ m) : vec_cons x u i.succ = u i :=
  by 
    simp [vec_cons]

@[simp]
theorem cons_val_succ' {i : ℕ} (h : i.succ < m.succ) (x : α) (u : Finₓ m → α) :
  vec_cons x u ⟨i.succ, h⟩ = u ⟨i, Nat.lt_of_succ_lt_succₓ h⟩ :=
  by 
    simp only [vec_cons, Finₓ.cons, Finₓ.cases_succ']

@[simp]
theorem head_cons (x : α) (u : Finₓ m → α) : vec_head (vec_cons x u) = x :=
  rfl

@[simp]
theorem tail_cons (x : α) (u : Finₓ m → α) : vec_tail (vec_cons x u) = u :=
  by 
    ext 
    simp [vec_tail]

-- error in Data.Fin.VecNotation: ././Mathport/Syntax/Translate/Basic.lean:558:61: unsupported notation `«expr![ , ]»
@[simp]
theorem empty_val' {n' : Type*} (j : n') : «expr = »(λ i, («expr![ , ]»([]) : fin 0 → n' → α) i j, «expr![ , ]»([])) :=
empty_eq _

@[simp]
theorem cons_head_tail (u : Finₓ m.succ → α) : vec_cons (vec_head u) (vec_tail u) = u :=
  Finₓ.cons_self_tail _

@[simp]
theorem range_cons (x : α) (u : Finₓ n → α) : Set.Range (vec_cons x u) = {x} ∪ Set.Range u :=
  Set.ext$
    fun y =>
      by 
        simp [Finₓ.exists_fin_succ, eq_comm]

@[simp]
theorem range_empty (u : Finₓ 0 → α) : Set.Range u = ∅ :=
  Set.range_eq_empty _

@[simp]
theorem vec_cons_const (a : α) : (vec_cons a fun k : Finₓ n => a) = fun _ => a :=
  funext$ Finₓ.forall_fin_succ.2 ⟨rfl, cons_val_succ _ _⟩

-- error in Data.Fin.VecNotation: ././Mathport/Syntax/Translate/Basic.lean:558:61: unsupported notation `«expr![ , ]»
theorem vec_single_eq_const (a : α) : «expr = »(«expr![ , ]»([a]), λ _, a) := «expr $ »(funext, unique.forall_iff.2 rfl)

/-- `![a, b, ...] 1` is equal to `b`.

  The simplifier needs a special lemma for length `≥ 2`, in addition to
  `cons_val_succ`, because `1 : fin 1 = 0 : fin 1`.
-/
@[simp]
theorem cons_val_one (x : α) (u : Finₓ m.succ → α) : vec_cons x u 1 = vec_head u :=
  by 
    rw [←Finₓ.succ_zero_eq_one, cons_val_succ]
    rfl

@[simp]
theorem cons_val_fin_one (x : α) (u : Finₓ 0 → α) (i : Finₓ 1) : vec_cons x u i = x :=
  by 
    refine' Finₓ.forall_fin_one.2 _ i 
    rfl

theorem cons_fin_one (x : α) (u : Finₓ 0 → α) : vec_cons x u = fun _ => x :=
  funext (cons_val_fin_one x u)

/-! ### Numeral (`bit0` and `bit1`) indices
The following definitions and `simp` lemmas are to allow any
numeral-indexed element of a vector given with matrix notation to
be extracted by `simp` (even when the numeral is larger than the
number of elements in the vector, which is taken modulo that number
of elements by virtue of the semantics of `bit0` and `bit1` and of
addition on `fin n`).
-/


-- error in Data.Fin.VecNotation: ././Mathport/Syntax/Translate/Basic.lean:558:61: unsupported notation `«expr![ , ]»
@[simp] theorem empty_append (v : fin n → α) : «expr = »(fin.append (zero_add _).symm «expr![ , ]»([]) v, v) :=
by { ext [] [] [],
  simp [] [] [] ["[", expr fin.append, "]"] [] [] }

@[simp]
theorem cons_append (ho : (o+1) = (m+1)+n) (x : α) (u : Finₓ m → α) (v : Finₓ n → α) :
  Finₓ.append ho (vec_cons x u) v =
    vec_cons x
      (Finₓ.append
        (by 
          rwa [add_assocₓ, add_commₓ 1, ←add_assocₓ, add_right_cancel_iffₓ] at ho)
        u v) :=
  by 
    ext i 
    simpRw [Finₓ.append]
    splitIfs with h
    ·
      rcases i with ⟨⟨⟩ | i, hi⟩
      ·
        simp 
      ·
        simp only [Nat.succ_eq_add_one, add_lt_add_iff_right, Finₓ.coe_mk] at h 
        simp [h]
    ·
      rcases i with ⟨⟨⟩ | i, hi⟩
      ·
        simpa using h
      ·
        rw [not_ltₓ, Finₓ.coe_mk, Nat.succ_eq_add_one, add_le_add_iff_right] at h 
        simp [h]

/-- `vec_alt0 v` gives a vector with half the length of `v`, with
only alternate elements (even-numbered). -/
def vec_alt0 (hm : m = n+n) (v : Finₓ m → α) (k : Finₓ n) : α :=
  v ⟨(k : ℕ)+k, hm.symm ▸ add_lt_add k.property k.property⟩

/-- `vec_alt1 v` gives a vector with half the length of `v`, with
only alternate elements (odd-numbered). -/
def vec_alt1 (hm : m = n+n) (v : Finₓ m → α) (k : Finₓ n) : α :=
  v ⟨((k : ℕ)+k)+1, hm.symm ▸ Nat.add_succ_lt_add k.property k.property⟩

theorem vec_alt0_append (v : Finₓ n → α) : vec_alt0 rfl (Finₓ.append rfl v v) = v ∘ bit0 :=
  by 
    ext i 
    simpRw [Function.comp, bit0, vec_alt0, Finₓ.append]
    splitIfs with h <;> congr
    ·
      rw [Finₓ.coe_mk] at h 
      simp only [Finₓ.ext_iff, Finₓ.coe_add, Finₓ.coe_mk]
      exact (Nat.mod_eq_of_ltₓ h).symm
    ·
      rw [Finₓ.coe_mk, not_ltₓ] at h 
      simp only [Finₓ.ext_iff, Finₓ.coe_add, Finₓ.coe_mk, Nat.mod_eq_sub_modₓ h]
      refine' (Nat.mod_eq_of_ltₓ _).symm 
      rw [tsub_lt_iff_left h]
      exact add_lt_add i.property i.property

theorem vec_alt1_append (v : Finₓ (n+1) → α) : vec_alt1 rfl (Finₓ.append rfl v v) = v ∘ bit1 :=
  by 
    ext i 
    simpRw [Function.comp, vec_alt1, Finₓ.append]
    cases n
    ·
      simp 
      congr
    ·
      splitIfs with h <;> simpRw [bit1, bit0] <;> congr
      ·
        simp only [Finₓ.ext_iff, Finₓ.coe_add, Finₓ.coe_mk]
        rw [Finₓ.coe_mk] at h 
        rw [Finₓ.coe_one]
        rw [Nat.mod_eq_of_ltₓ (Nat.lt_of_succ_ltₓ h)]
        rw [Nat.mod_eq_of_ltₓ h]
      ·
        rw [Finₓ.coe_mk, not_ltₓ] at h 
        simp only [Finₓ.ext_iff, Finₓ.coe_add, Finₓ.coe_mk, Nat.mod_add_modₓ, Finₓ.coe_one, Nat.mod_eq_sub_modₓ h]
        refine' (Nat.mod_eq_of_ltₓ _).symm 
        rw [tsub_lt_iff_left h]
        exact Nat.add_succ_lt_add i.property i.property

@[simp]
theorem vec_head_vec_alt0 (hm : (m+2) = (n+1)+n+1) (v : Finₓ (m+2) → α) : vec_head (vec_alt0 hm v) = v 0 :=
  rfl

@[simp]
theorem vec_head_vec_alt1 (hm : (m+2) = (n+1)+n+1) (v : Finₓ (m+2) → α) : vec_head (vec_alt1 hm v) = v 1 :=
  by 
    simp [vec_head, vec_alt1]

@[simp]
theorem cons_vec_bit0_eq_alt0 (x : α) (u : Finₓ n → α) (i : Finₓ (n+1)) :
  vec_cons x u (bit0 i) = vec_alt0 rfl (Finₓ.append rfl (vec_cons x u) (vec_cons x u)) i :=
  by 
    rw [vec_alt0_append]

@[simp]
theorem cons_vec_bit1_eq_alt1 (x : α) (u : Finₓ n → α) (i : Finₓ (n+1)) :
  vec_cons x u (bit1 i) = vec_alt1 rfl (Finₓ.append rfl (vec_cons x u) (vec_cons x u)) i :=
  by 
    rw [vec_alt1_append]

@[simp]
theorem cons_vec_alt0 (h : ((m+1)+1) = (n+1)+n+1) (x y : α) (u : Finₓ m → α) :
  vec_alt0 h (vec_cons x (vec_cons y u)) =
    vec_cons x
      (vec_alt0
        (by 
          rwa [add_assocₓ n, add_commₓ 1, ←add_assocₓ, ←add_assocₓ, add_right_cancel_iffₓ, add_right_cancel_iffₓ] at h)
        u) :=
  by 
    ext i 
    simpRw [vec_alt0]
    rcases i with ⟨⟨⟩ | i, hi⟩
    ·
      rfl
    ·
      simp [vec_alt0, Nat.add_succ, Nat.succ_add]

-- error in Data.Fin.VecNotation: ././Mathport/Syntax/Translate/Basic.lean:558:61: unsupported notation `«expr![ , ]»
@[simp] theorem empty_vec_alt0 (α) {h} : «expr = »(vec_alt0 h («expr![ , ]»([]) : fin 0 → α), «expr![ , ]»([])) :=
by simp [] [] [] [] [] []

@[simp]
theorem cons_vec_alt1 (h : ((m+1)+1) = (n+1)+n+1) (x y : α) (u : Finₓ m → α) :
  vec_alt1 h (vec_cons x (vec_cons y u)) =
    vec_cons y
      (vec_alt1
        (by 
          rwa [add_assocₓ n, add_commₓ 1, ←add_assocₓ, ←add_assocₓ, add_right_cancel_iffₓ, add_right_cancel_iffₓ] at h)
        u) :=
  by 
    ext i 
    simpRw [vec_alt1]
    rcases i with ⟨⟨⟩ | i, hi⟩
    ·
      rfl
    ·
      simp [vec_alt1, Nat.add_succ, Nat.succ_add]

-- error in Data.Fin.VecNotation: ././Mathport/Syntax/Translate/Basic.lean:558:61: unsupported notation `«expr![ , ]»
@[simp] theorem empty_vec_alt1 (α) {h} : «expr = »(vec_alt1 h («expr![ , ]»([]) : fin 0 → α), «expr![ , ]»([])) :=
by simp [] [] [] [] [] []

end Val

section Smul

variable [Semiringₓ α]

-- error in Data.Fin.VecNotation: ././Mathport/Syntax/Translate/Basic.lean:558:61: unsupported notation `«expr![ , ]»
@[simp] theorem smul_empty (x : α) (v : fin 0 → α) : «expr = »(«expr • »(x, v), «expr![ , ]»([])) := empty_eq _

@[simp]
theorem smul_cons (x y : α) (v : Finₓ n → α) : x • vec_cons y v = vec_cons (x*y) (x • v) :=
  by 
    ext i 
    refine' Finₓ.cases _ _ i <;> simp 

end Smul

section Add

variable [Add α]

-- error in Data.Fin.VecNotation: ././Mathport/Syntax/Translate/Basic.lean:558:61: unsupported notation `«expr![ , ]»
@[simp] theorem empty_add_empty (v w : fin 0 → α) : «expr = »(«expr + »(v, w), «expr![ , ]»([])) := empty_eq _

@[simp]
theorem cons_add (x : α) (v : Finₓ n → α) (w : Finₓ n.succ → α) :
  (vec_cons x v+w) = vec_cons (x+vec_head w) (v+vec_tail w) :=
  by 
    ext i 
    refine' Finₓ.cases _ _ i <;> simp [vec_head, vec_tail]

@[simp]
theorem add_cons (v : Finₓ n.succ → α) (y : α) (w : Finₓ n → α) :
  (v+vec_cons y w) = vec_cons (vec_head v+y) (vec_tail v+w) :=
  by 
    ext i 
    refine' Finₓ.cases _ _ i <;> simp [vec_head, vec_tail]

@[simp]
theorem head_add (a b : Finₓ n.succ → α) : vec_head (a+b) = vec_head a+vec_head b :=
  rfl

@[simp]
theorem tail_add (a b : Finₓ n.succ → α) : vec_tail (a+b) = vec_tail a+vec_tail b :=
  rfl

end Add

section Sub

variable [Sub α]

-- error in Data.Fin.VecNotation: ././Mathport/Syntax/Translate/Basic.lean:558:61: unsupported notation `«expr![ , ]»
@[simp] theorem empty_sub_empty (v w : fin 0 → α) : «expr = »(«expr - »(v, w), «expr![ , ]»([])) := empty_eq _

@[simp]
theorem cons_sub (x : α) (v : Finₓ n → α) (w : Finₓ n.succ → α) :
  vec_cons x v - w = vec_cons (x - vec_head w) (v - vec_tail w) :=
  by 
    ext i 
    refine' Finₓ.cases _ _ i <;> simp [vec_head, vec_tail]

@[simp]
theorem sub_cons (v : Finₓ n.succ → α) (y : α) (w : Finₓ n → α) :
  v - vec_cons y w = vec_cons (vec_head v - y) (vec_tail v - w) :=
  by 
    ext i 
    refine' Finₓ.cases _ _ i <;> simp [vec_head, vec_tail]

@[simp]
theorem head_sub (a b : Finₓ n.succ → α) : vec_head (a - b) = vec_head a - vec_head b :=
  rfl

@[simp]
theorem tail_sub (a b : Finₓ n.succ → α) : vec_tail (a - b) = vec_tail a - vec_tail b :=
  rfl

end Sub

section Zero

variable [HasZero α]

-- error in Data.Fin.VecNotation: ././Mathport/Syntax/Translate/Basic.lean:558:61: unsupported notation `«expr![ , ]»
@[simp] theorem zero_empty : «expr = »((0 : fin 0 → α), «expr![ , ]»([])) := empty_eq _

@[simp]
theorem cons_zero_zero : vec_cons (0 : α) (0 : Finₓ n → α) = 0 :=
  by 
    ext i j 
    refine' Finₓ.cases _ _ i
    ·
      rfl 
    simp 

@[simp]
theorem head_zero : vec_head (0 : Finₓ n.succ → α) = 0 :=
  rfl

@[simp]
theorem tail_zero : vec_tail (0 : Finₓ n.succ → α) = 0 :=
  rfl

@[simp]
theorem cons_eq_zero_iff {v : Finₓ n → α} {x : α} : vec_cons x v = 0 ↔ x = 0 ∧ v = 0 :=
  ⟨fun h =>
      ⟨congr_funₓ h 0,
        by 
          convert congr_argₓ vec_tail h 
          simp ⟩,
    fun ⟨hx, hv⟩ =>
      by 
        simp [hx, hv]⟩

open_locale Classical

theorem cons_nonzero_iff {v : Finₓ n → α} {x : α} : vec_cons x v ≠ 0 ↔ x ≠ 0 ∨ v ≠ 0 :=
  ⟨fun h => not_and_distrib.mp (h ∘ cons_eq_zero_iff.mpr), fun h => mt cons_eq_zero_iff.mp (not_and_distrib.mpr h)⟩

end Zero

section Neg

variable [Neg α]

-- error in Data.Fin.VecNotation: ././Mathport/Syntax/Translate/Basic.lean:558:61: unsupported notation `«expr![ , ]»
@[simp] theorem neg_empty (v : fin 0 → α) : «expr = »(«expr- »(v), «expr![ , ]»([])) := empty_eq _

@[simp]
theorem neg_cons (x : α) (v : Finₓ n → α) : -vec_cons x v = vec_cons (-x) (-v) :=
  by 
    ext i 
    refine' Finₓ.cases _ _ i <;> simp 

@[simp]
theorem head_neg (a : Finₓ n.succ → α) : vec_head (-a) = -vec_head a :=
  rfl

@[simp]
theorem tail_neg (a : Finₓ n.succ → α) : vec_tail (-a) = -vec_tail a :=
  rfl

end Neg

end Matrix

