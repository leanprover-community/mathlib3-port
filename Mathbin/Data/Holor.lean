import Mathbin.Algebra.Module.Pi 
import Mathbin.Algebra.BigOperators.Basic

/-!
# Basic properties of holors

Holors are indexed collections of tensor coefficients. Confusingly,
they are often called tensors in physics and in the neural network
community.

A holor is simply a multidimensional array of values. The size of a
holor is specified by a `list ℕ`, whose length is called the dimension
of the holor.

The tensor product of `x₁ : holor α ds₁` and `x₂ : holor α ds₂` is the
holor given by `(x₁ ⊗ x₂) (i₁ ++ i₂) = x₁ i₁ * x₂ i₂`. A holor is "of
rank at most 1" if it is a tensor product of one-dimensional holors.
The CP rank of a holor `x` is the smallest N such that `x` is the sum
of N holors of rank at most 1.

Based on the tensor library found in <https://www.isa-afp.org/entries/Deep_Learning.html>

## References

* <https://en.wikipedia.org/wiki/Tensor_rank_decomposition>
-/


universe u

open List

open_locale BigOperators

/-- `holor_index ds` is the type of valid index tuples used to identify an entry of a holor
of dimensions `ds`. -/
def HolorIndex (ds : List ℕ) : Type :=
  { is : List ℕ // forall₂ (· < ·) is ds }

namespace HolorIndex

variable{ds₁ ds₂ ds₃ : List ℕ}

def take : ∀ {ds₁ : List ℕ}, HolorIndex (ds₁ ++ ds₂) → HolorIndex ds₁
| ds, is => ⟨List.takeₓ (length ds) is.1, forall₂_take_append is.1 ds ds₂ is.2⟩

def drop : ∀ {ds₁ : List ℕ}, HolorIndex (ds₁ ++ ds₂) → HolorIndex ds₂
| ds, is => ⟨List.dropₓ (length ds) is.1, forall₂_drop_append is.1 ds ds₂ is.2⟩

theorem cast_type (is : List ℕ) (eq : ds₁ = ds₂) (h : forall₂ (· < ·) is ds₁) :
  (cast (congr_argₓ HolorIndex Eq) ⟨is, h⟩).val = is :=
  by 
    subst eq <;> rfl

def assoc_right : HolorIndex (ds₁ ++ ds₂ ++ ds₃) → HolorIndex (ds₁ ++ (ds₂ ++ ds₃)) :=
  cast (congr_argₓ HolorIndex (append_assoc ds₁ ds₂ ds₃))

def assoc_left : HolorIndex (ds₁ ++ (ds₂ ++ ds₃)) → HolorIndex (ds₁ ++ ds₂ ++ ds₃) :=
  cast (congr_argₓ HolorIndex (append_assoc ds₁ ds₂ ds₃).symm)

theorem take_take : ∀ (t : HolorIndex (ds₁ ++ ds₂ ++ ds₃)), t.assoc_right.take = t.take.take
| ⟨is, h⟩ =>
  Subtype.eq$
    by 
      simp [assoc_right, take, cast_type, List.take_take, Nat.le_add_rightₓ, min_eq_leftₓ]

theorem drop_take : ∀ (t : HolorIndex (ds₁ ++ ds₂ ++ ds₃)), t.assoc_right.drop.take = t.take.drop
| ⟨is, h⟩ =>
  Subtype.eq
    (by 
      simp [assoc_right, take, drop, cast_type, List.drop_take])

theorem drop_drop : ∀ (t : HolorIndex (ds₁ ++ ds₂ ++ ds₃)), t.assoc_right.drop.drop = t.drop
| ⟨is, h⟩ =>
  Subtype.eq
    (by 
      simp [add_commₓ, assoc_right, drop, cast_type, List.drop_drop])

end HolorIndex

/-- Holor (indexed collections of tensor coefficients) -/
def Holor (α : Type u) (ds : List ℕ) :=
  HolorIndex ds → α

namespace Holor

variable{α : Type}{d : ℕ}{ds : List ℕ}{ds₁ : List ℕ}{ds₂ : List ℕ}{ds₃ : List ℕ}

instance  [Inhabited α] : Inhabited (Holor α ds) :=
  ⟨fun t => default α⟩

instance  [HasZero α] : HasZero (Holor α ds) :=
  ⟨fun t => 0⟩

instance  [Add α] : Add (Holor α ds) :=
  ⟨fun x y t => x t+y t⟩

instance  [Neg α] : Neg (Holor α ds) :=
  ⟨fun a t => -a t⟩

instance  [AddSemigroupₓ α] : AddSemigroupₓ (Holor α ds) :=
  by 
    refineStruct { add := ·+·, .. } <;>
      runTac 
        tactic.pi_instance_derive_field

instance  [AddCommSemigroupₓ α] : AddCommSemigroupₓ (Holor α ds) :=
  by 
    refineStruct { add := ·+·, .. } <;>
      runTac 
        tactic.pi_instance_derive_field

instance  [AddMonoidₓ α] : AddMonoidₓ (Holor α ds) :=
  by 
    refineStruct { zero := (0 : Holor α ds), add := ·+·, nsmul := fun n x i => n • x i } <;>
      runTac 
        tactic.pi_instance_derive_field

instance  [AddCommMonoidₓ α] : AddCommMonoidₓ (Holor α ds) :=
  by 
    refineStruct { zero := (0 : Holor α ds), add := ·+·, nsmul := AddMonoidₓ.nsmul } <;>
      runTac 
        tactic.pi_instance_derive_field

instance  [AddGroupₓ α] : AddGroupₓ (Holor α ds) :=
  by 
    refineStruct { zero := (0 : Holor α ds), add := ·+·, nsmul := AddMonoidₓ.nsmul, zsmul := fun n x i => n • x i } <;>
      runTac 
        tactic.pi_instance_derive_field

instance  [AddCommGroupₓ α] : AddCommGroupₓ (Holor α ds) :=
  by 
    refineStruct { zero := (0 : Holor α ds), add := ·+·, nsmul := AddMonoidₓ.nsmul, zsmul := SubNegMonoidₓ.zsmul } <;>
      runTac 
        tactic.pi_instance_derive_field

instance  [Mul α] : HasScalar α (Holor α ds) :=
  ⟨fun a x => fun t => a*x t⟩

instance  [Semiringₓ α] : Module α (Holor α ds) :=
  Pi.module _ _ _

/-- The tensor product of two holors. -/
def mul [s : Mul α] (x : Holor α ds₁) (y : Holor α ds₂) : Holor α (ds₁ ++ ds₂) :=
  fun t => x t.take*y t.drop

local infixl:70 " ⊗ " => mul

theorem cast_type (eq : ds₁ = ds₂) (a : Holor α ds₁) :
  cast (congr_argₓ (Holor α) Eq) a = fun t => a (cast (congr_argₓ HolorIndex Eq.symm) t) :=
  by 
    subst eq <;> rfl

def assoc_right : Holor α (ds₁ ++ ds₂ ++ ds₃) → Holor α (ds₁ ++ (ds₂ ++ ds₃)) :=
  cast (congr_argₓ (Holor α) (append_assoc ds₁ ds₂ ds₃))

def assoc_left : Holor α (ds₁ ++ (ds₂ ++ ds₃)) → Holor α (ds₁ ++ ds₂ ++ ds₃) :=
  cast (congr_argₓ (Holor α) (append_assoc ds₁ ds₂ ds₃).symm)

-- error in Data.Holor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem mul_assoc0
[semigroup α]
(x : holor α ds₁)
(y : holor α ds₂)
(z : holor α ds₃) : «expr = »(«expr ⊗ »(«expr ⊗ »(x, y), z), «expr ⊗ »(x, «expr ⊗ »(y, z)).assoc_left) :=
funext (assume t : holor_index «expr ++ »(«expr ++ »(ds₁, ds₂), ds₃), begin
   rw [expr assoc_left] [],
   unfold [ident mul] [],
   rw [expr mul_assoc] [],
   rw ["[", "<-", expr holor_index.take_take, ",", "<-", expr holor_index.drop_take, ",", "<-", expr holor_index.drop_drop, "]"] [],
   rw [expr cast_type] [],
   refl,
   rw [expr append_assoc] []
 end)

theorem mul_assocₓ [Semigroupₓ α] (x : Holor α ds₁) (y : Holor α ds₂) (z : Holor α ds₃) :
  HEq (mul (mul x y) z) (mul x (mul y z)) :=
  by 
    simp [cast_heq, mul_assoc0, assoc_left]

theorem mul_left_distrib [Distrib α] (x : Holor α ds₁) (y : Holor α ds₂) (z : Holor α ds₂) :
  (x ⊗ y+z) = (x ⊗ y)+x ⊗ z :=
  funext fun t => left_distrib (x (HolorIndex.take t)) (y (HolorIndex.drop t)) (z (HolorIndex.drop t))

theorem mul_right_distrib [Distrib α] (x : Holor α ds₁) (y : Holor α ds₁) (z : Holor α ds₂) :
  (x+y) ⊗ z = (x ⊗ z)+y ⊗ z :=
  funext$ fun t => add_mulₓ (x (HolorIndex.take t)) (y (HolorIndex.take t)) (z (HolorIndex.drop t))

@[simp]
theorem zero_mul {α : Type} [Ringₓ α] (x : Holor α ds₂) : (0 : Holor α ds₁) ⊗ x = 0 :=
  funext fun t => zero_mul (x (HolorIndex.drop t))

@[simp]
theorem mul_zero {α : Type} [Ringₓ α] (x : Holor α ds₁) : x ⊗ (0 : Holor α ds₂) = 0 :=
  funext fun t => mul_zero (x (HolorIndex.take t))

theorem mul_scalar_mul [Monoidₓ α] (x : Holor α []) (y : Holor α ds) : x ⊗ y = x ⟨[], forall₂.nil⟩ • y :=
  by 
    simp [mul, HasScalar.smul, HolorIndex.take, HolorIndex.drop]

-- error in Data.Holor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- A slice is a subholor consisting of all entries with initial index i. -/
def slice (x : holor α [«expr :: »/«expr :: »/«expr :: »](d, ds)) (i : exprℕ()) (h : «expr < »(i, d)) : holor α ds :=
λ is : holor_index ds, x ⟨[«expr :: »/«expr :: »/«expr :: »](i, is.1), forall₂.cons h is.2⟩

/-- The 1-dimensional "unit" holor with 1 in the `j`th position. -/
def unit_vec [Monoidₓ α] [AddMonoidₓ α] (d : ℕ) (j : ℕ) : Holor α [d] :=
  fun ti => if ti.1 = [j] then 1 else 0

theorem holor_index_cons_decomp (p : HolorIndex (d :: ds) → Prop) :
  ∀ (t : HolorIndex (d :: ds)),
    (∀ i is,
        ∀ (h : t.1 = i :: is),
          p
            ⟨i :: is,
              by 
                rw [←h]
                exact t.2⟩) →
      p t
| ⟨[], hforall₂⟩, hp => absurd (forall₂_nil_left_iff.1 hforall₂) (cons_ne_nil d ds)
| ⟨i :: is, hforall₂⟩, hp => hp i is rfl

-- error in Data.Holor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Two holors are equal if all their slices are equal. -/
theorem slice_eq
(x : holor α [«expr :: »/«expr :: »/«expr :: »](d, ds))
(y : holor α [«expr :: »/«expr :: »/«expr :: »](d, ds))
(h : «expr = »(slice x, slice y)) : «expr = »(x, y) :=
«expr $ »(funext, λ
 t : holor_index [«expr :: »/«expr :: »/«expr :: »](d, ds), «expr $ »(holor_index_cons_decomp (λ
   t, «expr = »(x t, y t)) t, λ
  i
  is
  hiis, have hiisdds : forall₂ ((«expr < »)) [«expr :: »/«expr :: »/«expr :: »](i, is) [«expr :: »/«expr :: »/«expr :: »](d, ds), begin
    rw ["[", "<-", expr hiis, "]"] [],
    exact [expr t.2]
  end,
  have hid : «expr < »(i, d), from (forall₂_cons.1 hiisdds).1,
  have hisds : forall₂ ((«expr < »)) is ds, from (forall₂_cons.1 hiisdds).2,
  calc
    «expr = »(x ⟨[«expr :: »/«expr :: »/«expr :: »](i, is), _⟩, slice x i hid ⟨is, hisds⟩) : congr_arg (λ
     t, x t) (subtype.eq rfl)
    «expr = »(..., slice y i hid ⟨is, hisds⟩) : by rw [expr h] []
    «expr = »(..., y ⟨[«expr :: »/«expr :: »/«expr :: »](i, is), _⟩) : congr_arg (λ t, y t) (subtype.eq rfl)))

-- error in Data.Holor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem slice_unit_vec_mul
[ring α]
{i : exprℕ()}
{j : exprℕ()}
(hid : «expr < »(i, d))
(x : holor α ds) : «expr = »(slice «expr ⊗ »(unit_vec d j, x) i hid, if «expr = »(i, j) then x else 0) :=
«expr $ »(funext, λ
 t : holor_index ds, if h : «expr = »(i, j) then by simp [] [] [] ["[", expr slice, ",", expr mul, ",", expr holor_index.take, ",", expr unit_vec, ",", expr holor_index.drop, ",", expr h, "]"] [] [] else by simp [] [] [] ["[", expr slice, ",", expr mul, ",", expr holor_index.take, ",", expr unit_vec, ",", expr holor_index.drop, ",", expr h, "]"] [] []; refl)

theorem slice_add [Add α] (i : ℕ) (hid : i < d) (x : Holor α (d :: ds)) (y : Holor α (d :: ds)) :
  (slice x i hid+slice y i hid) = slice (x+y) i hid :=
  funext
    fun t =>
      by 
        simp [slice, ·+·]

theorem slice_zero [HasZero α] (i : ℕ) (hid : i < d) : slice (0 : Holor α (d :: ds)) i hid = 0 :=
  rfl

-- error in Data.Holor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem slice_sum
[add_comm_monoid α]
{β : Type}
(i : exprℕ())
(hid : «expr < »(i, d))
(s : finset β)
(f : β → holor α [«expr :: »/«expr :: »/«expr :: »](d, ds)) : «expr = »(«expr∑ in , »((x), s, slice (f x) i hid), slice «expr∑ in , »((x), s, f x) i hid) :=
begin
  letI [] [] [":=", expr classical.dec_eq β],
  refine [expr finset.induction_on s _ _],
  { simp [] [] [] ["[", expr slice_zero, "]"] [] [] },
  { intros ["_", "_", ident h_not_in, ident ih],
    rw ["[", expr finset.sum_insert h_not_in, ",", expr ih, ",", expr slice_add, ",", expr finset.sum_insert h_not_in, "]"] [] }
end

-- error in Data.Holor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The original holor can be recovered from its slices by multiplying with unit vectors and
summing up. -/
@[simp]
theorem sum_unit_vec_mul_slice
[ring α]
(x : holor α [«expr :: »/«expr :: »/«expr :: »](d, ds)) : «expr = »(«expr∑ in , »((i), (finset.range d).attach, «expr ⊗ »(unit_vec d i, slice x i (nat.succ_le_of_lt (finset.mem_range.1 i.prop)))), x) :=
begin
  apply [expr slice_eq _ _ _],
  ext [] [ident i, ident hid] [],
  rw ["[", "<-", expr slice_sum, "]"] [],
  simp [] [] ["only"] ["[", expr slice_unit_vec_mul hid, "]"] [] [],
  rw [expr finset.sum_eq_single «expr $ »(subtype.mk i, finset.mem_range.2 hid)] [],
  { simp [] [] [] [] [] [] },
  { assume [binders
     (b : {x // «expr ∈ »(x, finset.range d)})
     (hb : «expr ∈ »(b, (finset.range d).attach))
     (hbi : «expr ≠ »(b, ⟨i, _⟩))],
    have [ident hbi'] [":", expr «expr ≠ »(i, b)] [],
    { simpa [] [] ["only"] ["[", expr ne.def, ",", expr subtype.ext_iff, ",", expr subtype.coe_mk, "]"] [] ["using", expr hbi.symm] },
    simp [] [] [] ["[", expr hbi', "]"] [] [] },
  { assume [binders (hid' : «expr ∉ »(subtype.mk i _, finset.attach (finset.range d)))],
    exfalso,
    exact [expr absurd (finset.mem_attach _ _) hid'] }
end

/-- `cprank_max1 x` means `x` has CP rank at most 1, that is,
  it is the tensor product of 1-dimensional holors. -/
inductive cprank_max1 [Mul α] : ∀ {ds}, Holor α ds → Prop
  | nil (x : Holor α []) : cprank_max1 x
  | cons {d} {ds} (x : Holor α [d]) (y : Holor α ds) : cprank_max1 y → cprank_max1 (x ⊗ y)

/-- `cprank_max N x` means `x` has CP rank at most `N`, that is,
  it can be written as the sum of N holors of rank at most 1. -/
inductive cprank_max [Mul α] [AddMonoidₓ α] : ℕ → ∀ {ds}, Holor α ds → Prop
  | zero {ds} : cprank_max 0 (0 : Holor α ds)
  | succ n {ds} (x : Holor α ds) (y : Holor α ds) : cprank_max1 x → cprank_max n y → cprank_max (n+1) (x+y)

theorem cprank_max_nil [Monoidₓ α] [AddMonoidₓ α] (x : Holor α nil) : cprank_max 1 x :=
  have h := cprank_max.succ 0 x 0 (cprank_max1.nil x) cprank_max.zero 
  by 
    rwa [add_zeroₓ x, zero_addₓ] at h

theorem cprank_max_1 [Monoidₓ α] [AddMonoidₓ α] {x : Holor α ds} (h : cprank_max1 x) : cprank_max 1 x :=
  have h' := cprank_max.succ 0 x 0 h cprank_max.zero 
  by 
    rwa [zero_addₓ, add_zeroₓ] at h'

theorem cprank_max_add [Monoidₓ α] [AddMonoidₓ α] :
  ∀ {m : ℕ} {n : ℕ} {x : Holor α ds} {y : Holor α ds}, cprank_max m x → cprank_max n y → cprank_max (m+n) (x+y)
| 0, n, x, y, cprank_max.zero, hy =>
  by 
    simp [hy]
| m+1, n, _, y, cprank_max.succ k x₁ x₂ hx₁ hx₂, hy =>
  by 
    simp only [add_commₓ, add_assocₓ]
    apply cprank_max.succ
    ·
      assumption
    ·
      exact cprank_max_add hx₂ hy

theorem cprank_max_mul [Ringₓ α] : ∀ (n : ℕ) (x : Holor α [d]) (y : Holor α ds), cprank_max n y → cprank_max n (x ⊗ y)
| 0, x, _, cprank_max.zero =>
  by 
    simp [mul_zero x, cprank_max.zero]
| n+1, x, _, cprank_max.succ k y₁ y₂ hy₁ hy₂ =>
  by 
    rw [mul_left_distrib]
    rw [Nat.add_comm]
    apply cprank_max_add
    ·
      exact cprank_max_1 (cprank_max1.cons _ _ hy₁)
    ·
      exact cprank_max_mul k x y₂ hy₂

-- error in Data.Holor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem cprank_max_sum
[ring α]
{β}
{n : exprℕ()}
(s : finset β)
(f : β → holor α ds) : ∀
x «expr ∈ » s, cprank_max n (f x) → cprank_max «expr * »(s.card, n) «expr∑ in , »((x), s, f x) :=
by letI [] [] [":=", expr classical.dec_eq β]; exact [expr finset.induction_on s (by simp [] [] [] ["[", expr cprank_max.zero, "]"] [] []) (begin
    assume [binders (x s) (h_x_notin_s : «expr ∉ »(x, s)) (ih h_cprank)],
    simp [] [] ["only"] ["[", expr finset.sum_insert h_x_notin_s, ",", expr finset.card_insert_of_not_mem h_x_notin_s, "]"] [] [],
    rw [expr nat.right_distrib] [],
    simp [] [] ["only"] ["[", expr nat.one_mul, ",", expr nat.add_comm, "]"] [] [],
    have [ident ih'] [":", expr cprank_max «expr * »(finset.card s, n) «expr∑ in , »((x), s, f x)] [],
    { apply [expr ih],
      assume [binders (x : β) (h_x_in_s : «expr ∈ »(x, s))],
      simp [] [] ["only"] ["[", expr h_cprank, ",", expr finset.mem_insert_of_mem, ",", expr h_x_in_s, "]"] [] [] },
    exact [expr cprank_max_add (h_cprank x (finset.mem_insert_self x s)) ih']
  end)]

theorem cprank_max_upper_bound [Ringₓ α] : ∀ {ds}, ∀ (x : Holor α ds), cprank_max ds.prod x
| [], x => cprank_max_nil x
| d :: ds, x =>
  have h_summands :
    ∀ (i : { x // x ∈ Finset.range d }), cprank_max ds.prod (unit_vec d i.1 ⊗ slice x i.1 (mem_range.1 i.2)) :=
    fun i => cprank_max_mul _ _ _ (cprank_max_upper_bound (slice x i.1 (mem_range.1 i.2)))
  have h_dds_prod : (List.cons d ds).Prod = Finset.card (Finset.range d)*Prod ds :=
    by 
      simp [Finset.card_range]
  have  :
    cprank_max (Finset.card (Finset.attach (Finset.range d))*Prod ds)
      (∑i in Finset.attach (Finset.range d), unit_vec d i.val ⊗ slice x i.val (mem_range.1 i.2)) :=
    cprank_max_sum (Finset.range d).attach _ fun i _ => h_summands i 
  have h_cprank_max_sum :
    cprank_max (Finset.card (Finset.range d)*Prod ds)
      (∑i in Finset.attach (Finset.range d), unit_vec d i.val ⊗ slice x i.val (mem_range.1 i.2)) :=
    by 
      rwa [Finset.card_attach] at this 
  by 
    rw [←sum_unit_vec_mul_slice x]
    rw [h_dds_prod]
    exact h_cprank_max_sum

/-- The CP rank of a holor `x`: the smallest N such that
  `x` can be written as the sum of N holors of rank at most 1. -/
noncomputable def cprank [Ringₓ α] (x : Holor α ds) : Nat :=
  @Nat.findₓ (fun n => cprank_max n x) (Classical.decPred _) ⟨ds.prod, cprank_max_upper_bound x⟩

-- error in Data.Holor: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem cprank_upper_bound [ring α] : ∀ {ds}, ∀ x : holor α ds, «expr ≤ »(cprank x, ds.prod) :=
λ
(ds)
(x : holor α ds), by letI [] [] [":=", expr classical.dec_pred (λ
  n : exprℕ(), cprank_max n x)]; exact [expr nat.find_min' ⟨ds.prod, show λ
  n, cprank_max n x ds.prod, from cprank_max_upper_bound x⟩ (cprank_max_upper_bound x)]

end Holor

