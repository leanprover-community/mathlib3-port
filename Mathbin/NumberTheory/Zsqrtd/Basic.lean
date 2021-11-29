import Mathbin.Algebra.Associated 
import Mathbin.Tactic.Ring

/-! # ℤ[√d]

The ring of integers adjoined with a square root of `d : ℤ`.

After defining the norm, we show that it is a linearly ordered commutative ring,
as well as an integral domain.

We provide the universal property, that ring homomorphisms `ℤ√d →+* R` correspond
to choices of square roots of `d` in `R`.

-/


/-- The ring of integers adjoined with a square root of `d`.
  These have the form `a + b √d` where `a b : ℤ`. The components
  are called `re` and `im` by analogy to the negative `d` case. -/
structure Zsqrtd(d : ℤ) where 
  re : ℤ 
  im : ℤ

prefix:100 "ℤ√" => Zsqrtd

namespace Zsqrtd

section 

parameter {d : ℤ}

instance  : DecidableEq (ℤ√d) :=
  by 
    runTac 
      tactic.mk_dec_eq_instance

theorem ext : ∀ {z w : ℤ√d}, z = w ↔ z.re = w.re ∧ z.im = w.im
| ⟨x, y⟩, ⟨x', y'⟩ =>
  ⟨fun h =>
      by 
        injection h <;> split  <;> assumption,
    fun ⟨h₁, h₂⟩ =>
      by 
        congr <;> assumption⟩

/-- Convert an integer to a `ℤ√d` -/
def of_int (n : ℤ) : ℤ√d :=
  ⟨n, 0⟩

theorem of_int_re (n : ℤ) : (of_int n).re = n :=
  rfl

theorem of_int_im (n : ℤ) : (of_int n).im = 0 :=
  rfl

/-- The zero of the ring -/
def zero : ℤ√d :=
  of_int 0

instance  : HasZero (ℤ√d) :=
  ⟨Zsqrtd.zero⟩

@[simp]
theorem zero_re : (0 : ℤ√d).re = 0 :=
  rfl

@[simp]
theorem zero_im : (0 : ℤ√d).im = 0 :=
  rfl

instance  : Inhabited (ℤ√d) :=
  ⟨0⟩

/-- The one of the ring -/
def one : ℤ√d :=
  of_int 1

instance  : HasOne (ℤ√d) :=
  ⟨Zsqrtd.one⟩

@[simp]
theorem one_re : (1 : ℤ√d).re = 1 :=
  rfl

@[simp]
theorem one_im : (1 : ℤ√d).im = 0 :=
  rfl

/-- The representative of `√d` in the ring -/
def sqrtd : ℤ√d :=
  ⟨0, 1⟩

@[simp]
theorem sqrtd_re : (sqrtd : ℤ√d).re = 0 :=
  rfl

@[simp]
theorem sqrtd_im : (sqrtd : ℤ√d).im = 1 :=
  rfl

/-- Addition of elements of `ℤ√d` -/
def add : ℤ√d → ℤ√d → ℤ√d
| ⟨x, y⟩, ⟨x', y'⟩ => ⟨x+x', y+y'⟩

instance  : Add (ℤ√d) :=
  ⟨Zsqrtd.add⟩

@[simp]
theorem add_def (x y x' y' : ℤ) : (⟨x, y⟩+⟨x', y'⟩ : ℤ√d) = ⟨x+x', y+y'⟩ :=
  rfl

@[simp]
theorem add_re : ∀ (z w : ℤ√d), (z+w).re = z.re+w.re
| ⟨x, y⟩, ⟨x', y'⟩ => rfl

@[simp]
theorem add_im : ∀ (z w : ℤ√d), (z+w).im = z.im+w.im
| ⟨x, y⟩, ⟨x', y'⟩ => rfl

@[simp]
theorem bit0_re z : (bit0 z : ℤ√d).re = bit0 z.re :=
  add_re _ _

@[simp]
theorem bit0_im z : (bit0 z : ℤ√d).im = bit0 z.im :=
  add_im _ _

@[simp]
theorem bit1_re z : (bit1 z : ℤ√d).re = bit1 z.re :=
  by 
    simp [bit1]

@[simp]
theorem bit1_im z : (bit1 z : ℤ√d).im = bit0 z.im :=
  by 
    simp [bit1]

/-- Negation in `ℤ√d` -/
def neg : ℤ√d → ℤ√d
| ⟨x, y⟩ => ⟨-x, -y⟩

instance  : Neg (ℤ√d) :=
  ⟨Zsqrtd.neg⟩

@[simp]
theorem neg_re : ∀ (z : ℤ√d), (-z).re = -z.re
| ⟨x, y⟩ => rfl

@[simp]
theorem neg_im : ∀ (z : ℤ√d), (-z).im = -z.im
| ⟨x, y⟩ => rfl

/-- Multiplication in `ℤ√d` -/
def mul : ℤ√d → ℤ√d → ℤ√d
| ⟨x, y⟩, ⟨x', y'⟩ => ⟨(x*x')+(d*y)*y', (x*y')+y*x'⟩

instance  : Mul (ℤ√d) :=
  ⟨Zsqrtd.mul⟩

@[simp]
theorem mul_re : ∀ (z w : ℤ√d), (z*w).re = (z.re*w.re)+(d*z.im)*w.im
| ⟨x, y⟩, ⟨x', y'⟩ => rfl

@[simp]
theorem mul_im : ∀ (z w : ℤ√d), (z*w).im = (z.re*w.im)+z.im*w.re
| ⟨x, y⟩, ⟨x', y'⟩ => rfl

instance  : CommRingₓ (ℤ√d) :=
  by 
    refineStruct
        { add := ·+·, zero := (0 : ℤ√d), neg := Neg.neg, mul := ·*·, sub := fun a b => a+-b, one := 1,
          npow := @npowRec (ℤ√d) ⟨1⟩ ⟨·*·⟩, nsmul := @nsmulRec (ℤ√d) ⟨0⟩ ⟨·+·⟩,
          zsmul := @zsmulRec (ℤ√d) ⟨0⟩ ⟨·+·⟩ ⟨Zsqrtd.neg⟩ } <;>
      intros  <;>
        try 
            rfl <;>
          simp [ext, add_mulₓ, mul_addₓ, add_commₓ, add_left_commₓ, mul_commₓ, mul_left_commₓ]

instance  : AddCommMonoidₓ (ℤ√d) :=
  by 
    infer_instance

instance  : AddMonoidₓ (ℤ√d) :=
  by 
    infer_instance

instance  : Monoidₓ (ℤ√d) :=
  by 
    infer_instance

instance  : CommMonoidₓ (ℤ√d) :=
  by 
    infer_instance

instance  : CommSemigroupₓ (ℤ√d) :=
  by 
    infer_instance

instance  : Semigroupₓ (ℤ√d) :=
  by 
    infer_instance

instance  : AddCommSemigroupₓ (ℤ√d) :=
  by 
    infer_instance

instance  : AddSemigroupₓ (ℤ√d) :=
  by 
    infer_instance

instance  : CommSemiringₓ (ℤ√d) :=
  by 
    infer_instance

instance  : Semiringₓ (ℤ√d) :=
  by 
    infer_instance

instance  : Ringₓ (ℤ√d) :=
  by 
    infer_instance

instance  : Distrib (ℤ√d) :=
  by 
    infer_instance

/-- Conjugation in `ℤ√d`. The conjugate of `a + b √d` is `a - b √d`. -/
def conj : ℤ√d → ℤ√d
| ⟨x, y⟩ => ⟨x, -y⟩

@[simp]
theorem conj_re : ∀ (z : ℤ√d), (conj z).re = z.re
| ⟨x, y⟩ => rfl

@[simp]
theorem conj_im : ∀ (z : ℤ√d), (conj z).im = -z.im
| ⟨x, y⟩ => rfl

/-- `conj` as an `add_monoid_hom`. -/
def conj_hom : ℤ√d →+ ℤ√d :=
  { toFun := conj, map_add' := fun ⟨a, ai⟩ ⟨b, bi⟩ => ext.mpr ⟨rfl, neg_add _ _⟩, map_zero' := ext.mpr ⟨rfl, neg_zero⟩ }

@[simp]
theorem conj_zero : conj (0 : ℤ√d) = 0 :=
  conj_hom.map_zero

@[simp]
theorem conj_one : conj (1 : ℤ√d) = 1 :=
  by 
    simp only [Zsqrtd.ext, Zsqrtd.conj_re, Zsqrtd.conj_im, Zsqrtd.one_im, neg_zero, eq_self_iff_true, and_selfₓ]

@[simp]
theorem conj_neg (x : ℤ√d) : (-x).conj = -x.conj :=
  conj_hom.map_neg x

@[simp]
theorem conj_add (x y : ℤ√d) : (x+y).conj = x.conj+y.conj :=
  conj_hom.map_add x y

@[simp]
theorem conj_sub (x y : ℤ√d) : (x - y).conj = x.conj - y.conj :=
  conj_hom.map_sub x y

@[simp]
theorem conj_conj {d : ℤ} (x : ℤ√d) : x.conj.conj = x :=
  by 
    simp only [ext, true_andₓ, conj_re, eq_self_iff_true, neg_negₓ, conj_im]

instance  : Nontrivial (ℤ√d) :=
  ⟨⟨0, 1,
      by 
        decide⟩⟩

@[simp]
theorem coe_nat_re (n : ℕ) : (n : ℤ√d).re = n :=
  by 
    induction n <;> simp 

@[simp]
theorem coe_nat_im (n : ℕ) : (n : ℤ√d).im = 0 :=
  by 
    induction n <;> simp 

theorem coe_nat_val (n : ℕ) : (n : ℤ√d) = ⟨n, 0⟩ :=
  by 
    simp [ext]

@[simp]
theorem coe_int_re (n : ℤ) : (n : ℤ√d).re = n :=
  by 
    cases n <;> simp [Int.of_nat_eq_coe, Int.neg_succ_of_nat_eq]

@[simp]
theorem coe_int_im (n : ℤ) : (n : ℤ√d).im = 0 :=
  by 
    cases n <;> simp 

theorem coe_int_val (n : ℤ) : (n : ℤ√d) = ⟨n, 0⟩ :=
  by 
    simp [ext]

instance  : CharZero (ℤ√d) :=
  { cast_injective :=
      fun m n =>
        by 
          simp [ext] }

@[simp]
theorem of_int_eq_coe (n : ℤ) : (of_int n : ℤ√d) = n :=
  by 
    simp [ext, of_int_re, of_int_im]

@[simp]
theorem smul_val (n x y : ℤ) : ((n : ℤ√d)*⟨x, y⟩) = ⟨n*x, n*y⟩ :=
  by 
    simp [ext]

@[simp]
theorem muld_val (x y : ℤ) : (sqrtd*⟨x, y⟩) = ⟨d*y, x⟩ :=
  by 
    simp [ext]

@[simp]
theorem dmuld : (sqrtd*sqrtd) = d :=
  by 
    simp [ext]

@[simp]
theorem smuld_val (n x y : ℤ) : ((sqrtd*(n : ℤ√d))*⟨x, y⟩) = ⟨(d*n)*y, n*x⟩ :=
  by 
    simp [ext]

theorem decompose {x y : ℤ} : (⟨x, y⟩ : ℤ√d) = x+sqrtd*y :=
  by 
    simp [ext]

theorem mul_conj {x y : ℤ} : (⟨x, y⟩*conj ⟨x, y⟩ : ℤ√d) = (x*x) - (d*y)*y :=
  by 
    simp [ext, sub_eq_add_neg, mul_commₓ]

theorem conj_mul {a b : ℤ√d} : conj (a*b) = conj a*conj b :=
  by 
    simp [ext]
    ring

protected theorem coe_int_add (m n : ℤ) : («expr↑ » (m+n) : ℤ√d) = «expr↑ » m+«expr↑ » n :=
  (Int.castRingHom _).map_add _ _

protected theorem coe_int_sub (m n : ℤ) : («expr↑ » (m - n) : ℤ√d) = «expr↑ » m - «expr↑ » n :=
  (Int.castRingHom _).map_sub _ _

protected theorem coe_int_mul (m n : ℤ) : («expr↑ » (m*n) : ℤ√d) = «expr↑ » m*«expr↑ » n :=
  (Int.castRingHom _).map_mul _ _

protected theorem coe_int_inj {m n : ℤ} (h : («expr↑ » m : ℤ√d) = «expr↑ » n) : m = n :=
  by 
    simpa using congr_argₓ re h

theorem coe_int_dvd_iff {d : ℤ} (z : ℤ) (a : ℤ√d) : «expr↑ » z ∣ a ↔ z ∣ a.re ∧ z ∣ a.im :=
  by 
    split 
    ·
      rintro ⟨x, rfl⟩
      simp only [add_zeroₓ, coe_int_re, zero_mul, mul_im, dvd_mul_right, and_selfₓ, mul_re, mul_zero, coe_int_im]
    ·
      rintro ⟨⟨r, hr⟩, ⟨i, hi⟩⟩
      use ⟨r, i⟩
      rw [smul_val, ext]
      exact ⟨hr, hi⟩

/-- Read `sq_le a c b d` as `a √c ≤ b √d` -/
def sq_le (a c b d : ℕ) : Prop :=
  ((c*a)*a) ≤ (d*b)*b

theorem sq_le_of_le {c d x y z w : ℕ} (xz : z ≤ x) (yw : y ≤ w) (xy : sq_le x c y d) : sq_le z c w d :=
  le_transₓ (mul_le_mul (Nat.mul_le_mul_leftₓ _ xz) xz (Nat.zero_leₓ _) (Nat.zero_leₓ _))$
    le_transₓ xy (mul_le_mul (Nat.mul_le_mul_leftₓ _ yw) yw (Nat.zero_leₓ _) (Nat.zero_leₓ _))

theorem sq_le_add_mixed {c d x y z w : ℕ} (xy : sq_le x c y d) (zw : sq_le z c w d) : (c*x*z) ≤ d*y*w :=
  Nat.mul_self_le_mul_self_iff.2$
    by 
      simpa [mul_commₓ, mul_left_commₓ] using mul_le_mul xy zw (Nat.zero_leₓ _) (Nat.zero_leₓ _)

-- error in NumberTheory.Zsqrtd.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem sq_le_add
{c d x y z w : exprℕ()}
(xy : sq_le x c y d)
(zw : sq_le z c w d) : sq_le «expr + »(x, z) c «expr + »(y, w) d :=
begin
  have [ident xz] [] [":=", expr sq_le_add_mixed xy zw],
  simp [] [] [] ["[", expr sq_le, ",", expr mul_assoc, "]"] [] ["at", ident xy, ident zw],
  simp [] [] [] ["[", expr sq_le, ",", expr mul_add, ",", expr mul_comm, ",", expr mul_left_comm, ",", expr add_le_add, ",", "*", "]"] [] []
end

-- error in NumberTheory.Zsqrtd.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem sq_le_cancel
{c d x y z w : exprℕ()}
(zw : sq_le y d x c)
(h : sq_le «expr + »(x, z) c «expr + »(y, w) d) : sq_le z c w d :=
begin
  apply [expr le_of_not_gt],
  intro [ident l],
  refine [expr not_le_of_gt _ h],
  simp [] [] [] ["[", expr sq_le, ",", expr mul_add, ",", expr mul_comm, ",", expr mul_left_comm, ",", expr add_assoc, "]"] [] [],
  have [ident hm] [] [":=", expr sq_le_add_mixed zw (le_of_lt l)],
  simp [] [] [] ["[", expr sq_le, ",", expr mul_assoc, "]"] [] ["at", ident l, ident zw],
  exact [expr lt_of_le_of_lt (add_le_add_right zw _) (add_lt_add_left (add_lt_add_of_le_of_lt hm (add_lt_add_of_le_of_lt hm l)) _)]
end

theorem sq_le_smul {c d x y : ℕ} (n : ℕ) (xy : sq_le x c y d) : sq_le (n*x) c (n*y) d :=
  by 
    simpa [sq_le, mul_left_commₓ, mul_assocₓ] using Nat.mul_le_mul_leftₓ (n*n) xy

-- error in NumberTheory.Zsqrtd.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem sq_le_mul
{d
 x
 y
 z
 w : exprℕ()} : «expr ∧ »(sq_le x 1 y d → sq_le z 1 w d → sq_le «expr + »(«expr * »(x, w), «expr * »(y, z)) d «expr + »(«expr * »(x, z), «expr * »(«expr * »(d, y), w)) 1, «expr ∧ »(sq_le x 1 y d → sq_le w d z 1 → sq_le «expr + »(«expr * »(x, z), «expr * »(«expr * »(d, y), w)) 1 «expr + »(«expr * »(x, w), «expr * »(y, z)) d, «expr ∧ »(sq_le y d x 1 → sq_le z 1 w d → sq_le «expr + »(«expr * »(x, z), «expr * »(«expr * »(d, y), w)) 1 «expr + »(«expr * »(x, w), «expr * »(y, z)) d, sq_le y d x 1 → sq_le w d z 1 → sq_le «expr + »(«expr * »(x, w), «expr * »(y, z)) d «expr + »(«expr * »(x, z), «expr * »(«expr * »(d, y), w)) 1))) :=
by refine [expr ⟨_, _, _, _⟩]; { intros [ident xy, ident zw],
  have [] [] [":=", expr int.mul_nonneg (sub_nonneg_of_le (int.coe_nat_le_coe_nat_of_le xy)) (sub_nonneg_of_le (int.coe_nat_le_coe_nat_of_le zw))],
  refine [expr int.le_of_coe_nat_le_coe_nat (le_of_sub_nonneg _)],
  convert [] [expr this] [],
  simp [] [] ["only"] ["[", expr one_mul, ",", expr int.coe_nat_add, ",", expr int.coe_nat_mul, "]"] [] [],
  ring [] }

/-- "Generalized" `nonneg`. `nonnegg c d x y` means `a √c + b √d ≥ 0`;
  we are interested in the case `c = 1` but this is more symmetric -/
def nonnegg (c d : ℕ) : ℤ → ℤ → Prop
| (a : ℕ), (b : ℕ) => True
| (a : ℕ), -[1+ b] => sq_le (b+1) c a d
| -[1+ a], (b : ℕ) => sq_le (a+1) d b c
| -[1+ a], -[1+ b] => False

theorem nonnegg_comm {c d : ℕ} {x y : ℤ} : nonnegg c d x y = nonnegg d c y x :=
  by 
    induction x <;> induction y <;> rfl

theorem nonnegg_neg_pos {c d} : ∀ {a b : ℕ}, nonnegg c d (-a) b ↔ sq_le a d b c
| 0, b =>
  ⟨by 
      simp [sq_le, Nat.zero_leₓ],
    fun a => trivialₓ⟩
| a+1, b =>
  by 
    rw [←Int.neg_succ_of_nat_coe] <;> rfl

theorem nonnegg_pos_neg {c d} {a b : ℕ} : nonnegg c d a (-b) ↔ sq_le b c a d :=
  by 
    rw [nonnegg_comm] <;> exact nonnegg_neg_pos

theorem nonnegg_cases_right {c d} {a : ℕ} : ∀ {b : ℤ}, (∀ (x : ℕ), b = -x → sq_le x c a d) → nonnegg c d a b
| (b : Nat), h => trivialₓ
| -[1+ b], h => h (b+1) rfl

theorem nonnegg_cases_left {c d} {b : ℕ} {a : ℤ} (h : ∀ (x : ℕ), a = -x → sq_le x d b c) : nonnegg c d a b :=
  cast nonnegg_comm (nonnegg_cases_right h)

section Norm

def norm (n : ℤ√d) : ℤ :=
  (n.re*n.re) - (d*n.im)*n.im

theorem norm_def (n : ℤ√d) : n.norm = (n.re*n.re) - (d*n.im)*n.im :=
  rfl

@[simp]
theorem norm_zero : norm 0 = 0 :=
  by 
    simp [norm]

@[simp]
theorem norm_one : norm 1 = 1 :=
  by 
    simp [norm]

@[simp]
theorem norm_int_cast (n : ℤ) : norm n = n*n :=
  by 
    simp [norm]

@[simp]
theorem norm_nat_cast (n : ℕ) : norm n = n*n :=
  norm_int_cast n

@[simp]
theorem norm_mul (n m : ℤ√d) : norm (n*m) = norm n*norm m :=
  by 
    simp only [norm, mul_im, mul_re]
    ring

/-- `norm` as a `monoid_hom`. -/
def norm_monoid_hom : ℤ√d →* ℤ :=
  { toFun := norm, map_mul' := norm_mul, map_one' := norm_one }

theorem norm_eq_mul_conj (n : ℤ√d) : (norm n : ℤ√d) = n*n.conj :=
  by 
    cases n <;> simp [norm, conj, Zsqrtd.ext, mul_commₓ, sub_eq_add_neg]

@[simp]
theorem norm_neg (x : ℤ√d) : (-x).norm = x.norm :=
  coe_int_inj$
    by 
      simp only [norm_eq_mul_conj, conj_neg, neg_mul_eq_neg_mul_symm, mul_neg_eq_neg_mul_symm, neg_negₓ]

@[simp]
theorem norm_conj (x : ℤ√d) : x.conj.norm = x.norm :=
  coe_int_inj$
    by 
      simp only [norm_eq_mul_conj, conj_conj, mul_commₓ]

theorem norm_nonneg (hd : d ≤ 0) (n : ℤ√d) : 0 ≤ n.norm :=
  add_nonneg (mul_self_nonneg _)
    (by 
      rw [mul_assocₓ, neg_mul_eq_neg_mul] <;> exact mul_nonneg (neg_nonneg.2 hd) (mul_self_nonneg _))

-- error in NumberTheory.Zsqrtd.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem norm_eq_one_iff {x : «exprℤ√ »(d)} : «expr ↔ »(«expr = »(x.norm.nat_abs, 1), is_unit x) :=
⟨λ
 h, «expr $ »(is_unit_iff_dvd_one.2, (le_total 0 (norm x)).cases_on (λ
   hx, show «expr ∣ »(x, 1), from ⟨x.conj, by rwa ["[", "<-", expr int.coe_nat_inj', ",", expr int.nat_abs_of_nonneg hx, ",", "<-", expr @int.cast_inj «exprℤ√ »(d) _ _, ",", expr norm_eq_mul_conj, ",", expr eq_comm, "]"] ["at", ident h]⟩) (λ
   hx, show «expr ∣ »(x, 1), from ⟨«expr- »(x.conj), by rwa ["[", "<-", expr int.coe_nat_inj', ",", expr int.of_nat_nat_abs_of_nonpos hx, ",", "<-", expr @int.cast_inj «exprℤ√ »(d) _ _, ",", expr int.cast_neg, ",", expr norm_eq_mul_conj, ",", expr neg_mul_eq_mul_neg, ",", expr eq_comm, "]"] ["at", ident h]⟩)), λ
 h, let ⟨y, hy⟩ := is_unit_iff_dvd_one.1 h in
 begin
   have [] [] [":=", expr congr_arg «expr ∘ »(int.nat_abs, norm) hy],
   rw ["[", expr function.comp_app, ",", expr function.comp_app, ",", expr norm_mul, ",", expr int.nat_abs_mul, ",", expr norm_one, ",", expr int.nat_abs_one, ",", expr eq_comm, ",", expr nat.mul_eq_one_iff, "]"] ["at", ident this],
   exact [expr this.1]
 end⟩

theorem is_unit_iff_norm_is_unit {d : ℤ} (z : ℤ√d) : IsUnit z ↔ IsUnit z.norm :=
  by 
    rw [Int.is_unit_iff_nat_abs_eq, norm_eq_one_iff]

theorem norm_eq_one_iff' {d : ℤ} (hd : d ≤ 0) (z : ℤ√d) : z.norm = 1 ↔ IsUnit z :=
  by 
    rw [←norm_eq_one_iff, ←Int.coe_nat_inj', Int.nat_abs_of_nonneg (norm_nonneg hd z), Int.coe_nat_one]

-- error in NumberTheory.Zsqrtd.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem norm_eq_zero_iff
{d : exprℤ()}
(hd : «expr < »(d, 0))
(z : «exprℤ√ »(d)) : «expr ↔ »(«expr = »(z.norm, 0), «expr = »(z, 0)) :=
begin
  split,
  { intro [ident h],
    rw ["[", expr ext, ",", expr zero_re, ",", expr zero_im, "]"] [],
    rw ["[", expr norm_def, ",", expr sub_eq_add_neg, ",", expr mul_assoc, "]"] ["at", ident h],
    have [ident left] [] [":=", expr mul_self_nonneg z.re],
    have [ident right] [] [":=", expr neg_nonneg.mpr (mul_nonpos_of_nonpos_of_nonneg hd.le (mul_self_nonneg z.im))],
    obtain ["⟨", ident ha, ",", ident hb, "⟩", ":=", expr (add_eq_zero_iff' left right).mp h],
    split; apply [expr eq_zero_of_mul_self_eq_zero],
    { exact [expr ha] },
    { rw ["[", expr neg_eq_zero, ",", expr mul_eq_zero, "]"] ["at", ident hb],
      exact [expr hb.resolve_left hd.ne] } },
  { rintro [ident rfl],
    exact [expr norm_zero] }
end

theorem norm_eq_of_associated {d : ℤ} (hd : d ≤ 0) {x y : ℤ√d} (h : Associated x y) : x.norm = y.norm :=
  by 
    obtain ⟨u, rfl⟩ := h 
    rw [norm_mul, (norm_eq_one_iff' hd _).mpr u.is_unit, mul_oneₓ]

end Norm

end 

section 

parameter {d : ℕ}

/-- Nonnegativity of an element of `ℤ√d`. -/
def nonneg : ℤ√d → Prop
| ⟨a, b⟩ => nonnegg d 1 a b

protected def le (a b : ℤ√d) : Prop :=
  nonneg (b - a)

instance  : LE (ℤ√d) :=
  ⟨Zsqrtd.Le⟩

protected def lt (a b : ℤ√d) : Prop :=
  ¬b ≤ a

instance  : LT (ℤ√d) :=
  ⟨Zsqrtd.Lt⟩

instance decidable_nonnegg c d a b : Decidable (nonnegg c d a b) :=
  by 
    cases a <;>
      cases b <;>
        repeat' 
            rw [Int.of_nat_eq_coe] <;>
          unfold nonnegg sq_le <;> infer_instance

instance decidable_nonneg : ∀ (a : ℤ√d), Decidable (nonneg a)
| ⟨a, b⟩ => Zsqrtd.decidableNonnegg _ _ _ _

instance decidable_le (a b : ℤ√d) : Decidable (a ≤ b) :=
  decidable_nonneg _

theorem nonneg_cases : ∀ {a : ℤ√d}, nonneg a → ∃ x y : ℕ, a = ⟨x, y⟩ ∨ a = ⟨x, -y⟩ ∨ a = ⟨-x, y⟩
| ⟨(x : ℕ), (y : ℕ)⟩, h => ⟨x, y, Or.inl rfl⟩
| ⟨(x : ℕ), -[1+ y]⟩, h => ⟨x, y+1, Or.inr$ Or.inl rfl⟩
| ⟨-[1+ x], (y : ℕ)⟩, h => ⟨x+1, y, Or.inr$ Or.inr rfl⟩
| ⟨-[1+ x], -[1+ y]⟩, h => False.elim h

theorem nonneg_add_lem {x y z w : ℕ} (xy : nonneg ⟨x, -y⟩) (zw : nonneg ⟨-z, w⟩) : nonneg (⟨x, -y⟩+⟨-z, w⟩) :=
  have  : nonneg ⟨Int.subNatNat x z, Int.subNatNat w y⟩ :=
    Int.sub_nat_nat_elim x z (fun m n i => sq_le y d m 1 → sq_le n 1 w d → nonneg ⟨i, Int.subNatNat w y⟩)
      (fun j k =>
        Int.sub_nat_nat_elim w y (fun m n i => sq_le n d (k+j) 1 → sq_le k 1 m d → nonneg ⟨Int.ofNat j, i⟩)
          (fun m n xy zw => trivialₓ) fun m n xy zw => sq_le_cancel zw xy)
      (fun j k =>
        Int.sub_nat_nat_elim w y (fun m n i => sq_le n d k 1 → sq_le ((k+j)+1) 1 m d → nonneg ⟨-[1+ j], i⟩)
          (fun m n xy zw => sq_le_cancel xy zw)
          fun m n xy zw =>
            let t := Nat.le_transₓ zw (sq_le_of_le (Nat.le_add_rightₓ n (m+1)) (le_reflₓ _) xy)
            have  : ((k+j)+1) ≤ k :=
              Nat.mul_self_le_mul_self_iff.2
                (by 
                  repeat' 
                      rw [one_mulₓ] at t <;>
                    exact t)
            absurd this (not_le_of_gtₓ$ Nat.succ_le_succₓ$ Nat.le_add_rightₓ _ _))
      (nonnegg_pos_neg.1 xy) (nonnegg_neg_pos.1 zw)
  show nonneg ⟨_, _⟩by 
    rw [neg_add_eq_sub] <;> rwa [Int.sub_nat_nat_eq_coe, Int.sub_nat_nat_eq_coe] at this

theorem nonneg_add {a b : ℤ√d} (ha : nonneg a) (hb : nonneg b) : nonneg (a+b) :=
  by 
    rcases nonneg_cases ha with ⟨x, y, rfl | rfl | rfl⟩ <;>
      rcases nonneg_cases hb with ⟨z, w, rfl | rfl | rfl⟩ <;> dsimp [add, nonneg]  at ha hb⊢
    ·
      trivial
    ·
      refine' nonnegg_cases_right fun i h => sq_le_of_le _ _ (nonnegg_pos_neg.1 hb)
      ·
        exact
          Int.coe_nat_le.1
            (le_of_neg_le_neg
              (@Int.Le.intro _ _ y
                (by 
                  simp [add_commₓ])))
      ·
        apply Nat.le_add_leftₓ
    ·
      refine' nonnegg_cases_left fun i h => sq_le_of_le _ _ (nonnegg_neg_pos.1 hb)
      ·
        exact
          Int.coe_nat_le.1
            (le_of_neg_le_neg
              (@Int.Le.intro _ _ x
                (by 
                  simp [add_commₓ])))
      ·
        apply Nat.le_add_leftₓ
    ·
      refine' nonnegg_cases_right fun i h => sq_le_of_le _ _ (nonnegg_pos_neg.1 ha)
      ·
        exact
          Int.coe_nat_le.1
            (le_of_neg_le_neg
              (@Int.Le.intro _ _ w
                (by 
                  simp )))
      ·
        apply Nat.le_add_rightₓ
    ·
      simpa [add_commₓ] using nonnegg_pos_neg.2 (sq_le_add (nonnegg_pos_neg.1 ha) (nonnegg_pos_neg.1 hb))
    ·
      exact nonneg_add_lem ha hb
    ·
      refine' nonnegg_cases_left fun i h => sq_le_of_le _ _ (nonnegg_neg_pos.1 ha)
      ·
        exact Int.coe_nat_le.1 (le_of_neg_le_neg (Int.Le.intro h))
      ·
        apply Nat.le_add_rightₓ
    ·
      rw [add_commₓ, add_commₓ («expr↑ » y)]
      exact nonneg_add_lem hb ha
    ·
      simpa [add_commₓ] using nonnegg_neg_pos.2 (sq_le_add (nonnegg_neg_pos.1 ha) (nonnegg_neg_pos.1 hb))

theorem le_reflₓ (a : ℤ√d) : a ≤ a :=
  show nonneg (a - a)by 
    simp 

protected theorem le_transₓ {a b c : ℤ√d} (ab : a ≤ b) (bc : b ≤ c) : a ≤ c :=
  have  : nonneg ((b - a)+c - b) := nonneg_add ab bc 
  by 
    simpa [sub_add_sub_cancel']

theorem nonneg_iff_zero_le {a : ℤ√d} : nonneg a ↔ 0 ≤ a :=
  show _ ↔ nonneg _ by 
    simp 

theorem le_of_le_le {x y z w : ℤ} (xz : x ≤ z) (yw : y ≤ w) : (⟨x, y⟩ : ℤ√d) ≤ ⟨z, w⟩ :=
  show nonneg ⟨z - x, w - y⟩ from
    match z - x, w - y, Int.Le.dest_sub xz, Int.Le.dest_sub yw with 
    | _, _, ⟨a, rfl⟩, ⟨b, rfl⟩ => trivialₓ

-- error in NumberTheory.Zsqrtd.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem le_arch (a : «exprℤ√ »(d)) : «expr∃ , »((n : exprℕ()), «expr ≤ »(a, n)) :=
let ⟨x, y, (h : «expr ≤ »(a, ⟨x, y⟩))⟩ := show «expr∃ , »((x
      y : exprℕ()), nonneg «expr + »(⟨x, y⟩, «expr- »(a))), from match «expr- »(a) with
    | ⟨int.of_nat x, int.of_nat y⟩ := ⟨0, 0, trivial⟩
    | ⟨int.of_nat x, «expr-[1+ ]»(y)⟩ := ⟨0, «expr + »(y, 1), by simp [] [] [] ["[", expr int.neg_succ_of_nat_coe, ",", expr add_assoc, "]"] [] []⟩
    | ⟨«expr-[1+ ]»(x), int.of_nat y⟩ := ⟨«expr + »(x, 1), 0, by simp [] [] [] ["[", expr int.neg_succ_of_nat_coe, ",", expr add_assoc, "]"] [] []⟩
    | ⟨«expr-[1+ ]»(x), «expr-[1+ ]»(y)⟩ := ⟨«expr + »(x, 1), «expr + »(y, 1), by simp [] [] [] ["[", expr int.neg_succ_of_nat_coe, ",", expr add_assoc, "]"] [] []⟩
    end in
begin
  refine [expr ⟨«expr + »(x, «expr * »(d, y)), zsqrtd.le_trans h _⟩],
  rw ["[", "<-", expr int.cast_coe_nat, ",", "<-", expr of_int_eq_coe, "]"] [],
  change [expr nonneg ⟨«expr - »(«expr + »(«expr↑ »(x), «expr * »(d, y)), «expr↑ »(x)), «expr - »(0, «expr↑ »(y))⟩] [] [],
  cases [expr y] ["with", ident y],
  { simp [] [] [] [] [] [] },
  have [ident h] [":", expr ∀
   y, sq_le y d «expr * »(d, y) 1] [":=", expr λ
   y, by simpa [] [] [] ["[", expr sq_le, ",", expr mul_comm, ",", expr mul_left_comm, "]"] [] ["using", expr nat.mul_le_mul_right «expr * »(y, y) (nat.le_mul_self d)]],
  rw ["[", expr show «expr = »(«expr - »(«expr + »((x : exprℤ()), «expr * »(d, nat.succ y)), x), «expr * »(d, nat.succ y)), by simp [] [] [] [] [] [], "]"] [],
  exact [expr h «expr + »(y, 1)]
end

protected theorem nonneg_total : ∀ (a : ℤ√d), nonneg a ∨ nonneg (-a)
| ⟨(x : ℕ), (y : ℕ)⟩ => Or.inl trivialₓ
| ⟨-[1+ x], -[1+ y]⟩ => Or.inr trivialₓ
| ⟨0, -[1+ y]⟩ => Or.inr trivialₓ
| ⟨-[1+ x], 0⟩ => Or.inr trivialₓ
| ⟨(x+1 : ℕ), -[1+ y]⟩ => Nat.le_totalₓ
| ⟨-[1+ x], (y+1 : ℕ)⟩ => Nat.le_totalₓ

protected theorem le_totalₓ (a b : ℤ√d) : a ≤ b ∨ b ≤ a :=
  let t := nonneg_total (b - a)
  by 
    rw [show -(b - a) = a - b from neg_sub b a] at t <;> exact t

instance  : Preorderₓ (ℤ√d) :=
  { le := Zsqrtd.Le, le_refl := Zsqrtd.le_refl, le_trans := @Zsqrtd.le_trans, lt := Zsqrtd.Lt,
    lt_iff_le_not_le := fun a b => (and_iff_right_of_imp (Zsqrtd.le_total _ _).resolve_left).symm }

protected theorem add_le_add_left (a b : ℤ√d) (ab : a ≤ b) (c : ℤ√d) : (c+a) ≤ c+b :=
  show nonneg _ by 
    rw [add_sub_add_left_eq_sub] <;> exact ab

protected theorem le_of_add_le_add_left (a b c : ℤ√d) (h : (c+a) ≤ c+b) : a ≤ b :=
  by 
    simpa using Zsqrtd.add_le_add_left _ _ h (-c)

protected theorem add_lt_add_left (a b : ℤ√d) (h : a < b) c : (c+a) < c+b :=
  fun h' => h (Zsqrtd.le_of_add_le_add_left _ _ _ h')

theorem nonneg_smul {a : ℤ√d} {n : ℕ} (ha : nonneg a) : nonneg (n*a) :=
  by 
    rw [←Int.cast_coe_nat] <;>
      exact
        match a, nonneg_cases ha, ha with 
        | _, ⟨x, y, Or.inl rfl⟩, ha =>
          by 
            rw [smul_val] <;> trivial
        | _, ⟨x, y, Or.inr$ Or.inl rfl⟩, ha =>
          by 
            rw [smul_val] <;> simpa using nonnegg_pos_neg.2 (sq_le_smul n$ nonnegg_pos_neg.1 ha)
        | _, ⟨x, y, Or.inr$ Or.inr rfl⟩, ha =>
          by 
            rw [smul_val] <;> simpa using nonnegg_neg_pos.2 (sq_le_smul n$ nonnegg_neg_pos.1 ha)

theorem nonneg_muld {a : ℤ√d} (ha : nonneg a) : nonneg (sqrtd*a) :=
  by 
    refine'
      match a, nonneg_cases ha, ha with 
      | _, ⟨x, y, Or.inl rfl⟩, ha => trivialₓ
      | _, ⟨x, y, Or.inr$ Or.inl rfl⟩, ha =>
        by 
          simp  <;>
            apply nonnegg_neg_pos.2 <;>
              simpa [sq_le, mul_commₓ, mul_left_commₓ] using Nat.mul_le_mul_leftₓ d (nonnegg_pos_neg.1 ha)
      | _, ⟨x, y, Or.inr$ Or.inr rfl⟩, ha =>
        by 
          simp  <;>
            apply nonnegg_pos_neg.2 <;>
              simpa [sq_le, mul_commₓ, mul_left_commₓ] using Nat.mul_le_mul_leftₓ d (nonnegg_neg_pos.1 ha)

theorem nonneg_mul_lem {x y : ℕ} {a : ℤ√d} (ha : nonneg a) : nonneg (⟨x, y⟩*a) :=
  have  : (⟨x, y⟩*a : ℤ√d) = (x*a)+sqrtd*y*a :=
    by 
      rw [decompose, right_distrib, mul_assocₓ] <;> rfl 
  by 
    rw [this] <;> exact nonneg_add (nonneg_smul ha) (nonneg_muld$ nonneg_smul ha)

theorem nonneg_mul {a b : ℤ√d} (ha : nonneg a) (hb : nonneg b) : nonneg (a*b) :=
  match a, b, nonneg_cases ha, nonneg_cases hb, ha, hb with 
  | _, _, ⟨x, y, Or.inl rfl⟩, ⟨z, w, Or.inl rfl⟩, ha, hb => trivialₓ
  | _, _, ⟨x, y, Or.inl rfl⟩, ⟨z, w, Or.inr$ Or.inr rfl⟩, ha, hb => nonneg_mul_lem hb
  | _, _, ⟨x, y, Or.inl rfl⟩, ⟨z, w, Or.inr$ Or.inl rfl⟩, ha, hb => nonneg_mul_lem hb
  | _, _, ⟨x, y, Or.inr$ Or.inr rfl⟩, ⟨z, w, Or.inl rfl⟩, ha, hb =>
    by 
      rw [mul_commₓ] <;> exact nonneg_mul_lem ha
  | _, _, ⟨x, y, Or.inr$ Or.inl rfl⟩, ⟨z, w, Or.inl rfl⟩, ha, hb =>
    by 
      rw [mul_commₓ] <;> exact nonneg_mul_lem ha
  | _, _, ⟨x, y, Or.inr$ Or.inr rfl⟩, ⟨z, w, Or.inr$ Or.inr rfl⟩, ha, hb =>
    by 
      rw
          [calc (⟨-x, y⟩*⟨-z, w⟩ : ℤ√d) = ⟨_, _⟩ := rfl 
            _ = ⟨(x*z)+(d*y)*w, -(x*w)+y*z⟩ :=
            by 
              simp [add_commₓ]
            ] <;>
        exact nonnegg_pos_neg.2 (sq_le_mul.left (nonnegg_neg_pos.1 ha) (nonnegg_neg_pos.1 hb))
  | _, _, ⟨x, y, Or.inr$ Or.inr rfl⟩, ⟨z, w, Or.inr$ Or.inl rfl⟩, ha, hb =>
    by 
      rw
          [calc (⟨-x, y⟩*⟨z, -w⟩ : ℤ√d) = ⟨_, _⟩ := rfl 
            _ = ⟨-(x*z)+(d*y)*w, (x*w)+y*z⟩ :=
            by 
              simp [add_commₓ]
            ] <;>
        exact nonnegg_neg_pos.2 (sq_le_mul.right.left (nonnegg_neg_pos.1 ha) (nonnegg_pos_neg.1 hb))
  | _, _, ⟨x, y, Or.inr$ Or.inl rfl⟩, ⟨z, w, Or.inr$ Or.inr rfl⟩, ha, hb =>
    by 
      rw
          [calc (⟨x, -y⟩*⟨-z, w⟩ : ℤ√d) = ⟨_, _⟩ := rfl 
            _ = ⟨-(x*z)+(d*y)*w, (x*w)+y*z⟩ :=
            by 
              simp [add_commₓ]
            ] <;>
        exact nonnegg_neg_pos.2 (sq_le_mul.right.right.left (nonnegg_pos_neg.1 ha) (nonnegg_neg_pos.1 hb))
  | _, _, ⟨x, y, Or.inr$ Or.inl rfl⟩, ⟨z, w, Or.inr$ Or.inl rfl⟩, ha, hb =>
    by 
      rw
          [calc (⟨x, -y⟩*⟨z, -w⟩ : ℤ√d) = ⟨_, _⟩ := rfl 
            _ = ⟨(x*z)+(d*y)*w, -(x*w)+y*z⟩ :=
            by 
              simp [add_commₓ]
            ] <;>
        exact nonnegg_pos_neg.2 (sq_le_mul.right.right.right (nonnegg_pos_neg.1 ha) (nonnegg_pos_neg.1 hb))

protected theorem mul_nonneg (a b : ℤ√d) : 0 ≤ a → 0 ≤ b → 0 ≤ a*b :=
  by 
    repeat' 
        rw [←nonneg_iff_zero_le] <;>
      exact nonneg_mul

theorem not_sq_le_succ c d y (h : 0 < c) : ¬sq_le (y+1) c 0 d :=
  not_le_of_gtₓ$ mul_pos (mul_pos h$ Nat.succ_posₓ _)$ Nat.succ_posₓ _

/-- A nonsquare is a natural number that is not equal to the square of an
  integer. This is implemented as a typeclass because it's a necessary condition
  for much of the Pell equation theory. -/
class nonsquare(x : ℕ) : Prop where 
  ns{} : ∀ (n : ℕ), x ≠ n*n

parameter [dnsq : nonsquare d]

include dnsq

theorem d_pos : 0 < d :=
  lt_of_le_of_neₓ (Nat.zero_leₓ _)$ Ne.symm$ nonsquare.ns d 0

-- error in NumberTheory.Zsqrtd.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem divides_sq_eq_zero
{x y}
(h : «expr = »(«expr * »(x, x), «expr * »(«expr * »(d, y), y))) : «expr ∧ »(«expr = »(x, 0), «expr = »(y, 0)) :=
let g := x.gcd y in
or.elim g.eq_zero_or_pos (λ
 H, ⟨nat.eq_zero_of_gcd_eq_zero_left H, nat.eq_zero_of_gcd_eq_zero_right H⟩) (λ
 gpos, «expr $ »(false.elim, let ⟨m, n, co, (hx : «expr = »(x, «expr * »(m, g))), (hy : «expr = »(y, «expr * »(n, g)))⟩ := nat.exists_coprime gpos in
  begin
    rw ["[", expr hx, ",", expr hy, "]"] ["at", ident h],
    have [] [":", expr «expr = »(«expr * »(m, m), «expr * »(d, «expr * »(n, n)))] [":=", expr nat.eq_of_mul_eq_mul_left (mul_pos gpos gpos) (by simpa [] [] [] ["[", expr mul_comm, ",", expr mul_left_comm, "]"] [] ["using", expr h])],
    have [ident co2] [] [":=", expr let co1 := co.mul_right co in co1.mul co1],
    exact [expr nonsquare.ns d m «expr $ »(nat.dvd_antisymm (by rw [expr this] []; apply [expr dvd_mul_right]), «expr $ »(co2.dvd_of_dvd_mul_right, by simp [] [] [] ["[", expr this, "]"] [] []))]
  end))

theorem divides_sq_eq_zero_z {x y : ℤ} (h : (x*x) = (d*y)*y) : x = 0 ∧ y = 0 :=
  by 
    rw [mul_assocₓ, ←Int.nat_abs_mul_self, ←Int.nat_abs_mul_self, ←Int.coe_nat_mul, ←mul_assocₓ] at h <;>
      exact
        let ⟨h1, h2⟩ := divides_sq_eq_zero (Int.coe_nat_inj h)
        ⟨Int.eq_zero_of_nat_abs_eq_zero h1, Int.eq_zero_of_nat_abs_eq_zero h2⟩

-- error in NumberTheory.Zsqrtd.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem not_divides_sq
(x
 y) : «expr ≠ »(«expr * »(«expr + »(x, 1), «expr + »(x, 1)), «expr * »(«expr * »(d, «expr + »(y, 1)), «expr + »(y, 1))) :=
λ e, by have [ident t] [] [":=", expr (divides_sq_eq_zero e).left]; contradiction

theorem nonneg_antisymm : ∀ {a : ℤ√d}, nonneg a → nonneg (-a) → a = 0
| ⟨0, 0⟩, xy, yx => rfl
| ⟨-[1+ x], -[1+ y]⟩, xy, yx => False.elim xy
| ⟨(x+1 : Nat), (y+1 : Nat)⟩, xy, yx => False.elim yx
| ⟨-[1+ x], 0⟩, xy, yx =>
  absurd xy
    (not_sq_le_succ _ _ _
      (by 
        decide))
| ⟨(x+1 : Nat), 0⟩, xy, yx =>
  absurd yx
    (not_sq_le_succ _ _ _
      (by 
        decide))
| ⟨0, -[1+ y]⟩, xy, yx => absurd xy (not_sq_le_succ _ _ _ d_pos)
| ⟨0, (y+1 : Nat)⟩, _, yx => absurd yx (not_sq_le_succ _ _ _ d_pos)
| ⟨(x+1 : Nat), -[1+ y]⟩, (xy : sq_le _ _ _ _), (yx : sq_le _ _ _ _) =>
  let t := le_antisymmₓ yx xy 
  by 
    rw [one_mulₓ] at t <;> exact absurd t (not_divides_sq _ _)
| ⟨-[1+ x], (y+1 : Nat)⟩, (xy : sq_le _ _ _ _), (yx : sq_le _ _ _ _) =>
  let t := le_antisymmₓ xy yx 
  by 
    rw [one_mulₓ] at t <;> exact absurd t (not_divides_sq _ _)

theorem le_antisymmₓ {a b : ℤ√d} (ab : a ≤ b) (ba : b ≤ a) : a = b :=
  eq_of_sub_eq_zero$
    nonneg_antisymm ba
      (by 
        rw [neg_sub] <;> exact ab)

instance  : LinearOrderₓ (ℤ√d) :=
  { Zsqrtd.preorder with le_antisymm := @Zsqrtd.le_antisymm, le_total := Zsqrtd.le_total,
    decidableLe := Zsqrtd.decidableLe }

protected theorem eq_zero_or_eq_zero_of_mul_eq_zero : ∀ {a b : ℤ√d}, (a*b) = 0 → a = 0 ∨ b = 0
| ⟨x, y⟩, ⟨z, w⟩, h =>
  by 
    injection h with h1 h2 <;>
      exact
        have h1 : (x*z) = -(d*y)*w := eq_neg_of_add_eq_zero h1 
        have h2 : (x*w) = -y*z := eq_neg_of_add_eq_zero h2 
        have fin : ((x*x) = (d*y)*y) → (⟨x, y⟩ : ℤ√d) = 0 :=
          fun e =>
            match x, y, divides_sq_eq_zero_z e with 
            | _, _, ⟨rfl, rfl⟩ => rfl 
        if z0 : z = 0 then
          if w0 : w = 0 then
            Or.inr
              (match z, w, z0, w0 with 
              | _, _, rfl, rfl => rfl)
          else
            Or.inl$
              Finₓ$
                mul_right_cancel₀ w0$
                  calc ((x*x)*w) = (-y)*x*z :=
                    by 
                      simp [h2, mul_assocₓ, mul_left_commₓ]
                    _ = ((d*y)*y)*w :=
                    by 
                      simp [h1, mul_assocₓ, mul_left_commₓ]
                    
        else
          Or.inl$
            Finₓ$
              mul_right_cancel₀ z0$
                calc ((x*x)*z) = (d*-y)*x*w :=
                  by 
                    simp [h1, mul_assocₓ, mul_left_commₓ]
                  _ = ((d*y)*y)*z :=
                  by 
                    simp [h2, mul_assocₓ, mul_left_commₓ]
                  

instance  : IsDomain (ℤ√d) :=
  { Zsqrtd.commRing, Zsqrtd.nontrivial with
    eq_zero_or_eq_zero_of_mul_eq_zero := @Zsqrtd.eq_zero_or_eq_zero_of_mul_eq_zero }

protected theorem mul_pos (a b : ℤ√d) (a0 : 0 < a) (b0 : 0 < b) : 0 < a*b :=
  fun ab =>
    Or.elim (eq_zero_or_eq_zero_of_mul_eq_zero (le_antisymmₓ ab (mul_nonneg _ _ (le_of_ltₓ a0) (le_of_ltₓ b0))))
      (fun e => ne_of_gtₓ a0 e) fun e => ne_of_gtₓ b0 e

instance  : LinearOrderedCommRing (ℤ√d) :=
  { Zsqrtd.commRing, Zsqrtd.linearOrder, Zsqrtd.nontrivial with add_le_add_left := @Zsqrtd.add_le_add_left,
    mul_pos := @Zsqrtd.mul_pos,
    zero_le_one :=
      by 
        decide }

instance  : LinearOrderedRing (ℤ√d) :=
  by 
    infer_instance

instance  : OrderedRing (ℤ√d) :=
  by 
    infer_instance

end 

-- error in NumberTheory.Zsqrtd.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem norm_eq_zero
{d : exprℤ()}
(h_nonsquare : ∀ n : exprℤ(), «expr ≠ »(d, «expr * »(n, n)))
(a : «exprℤ√ »(d)) : «expr ↔ »(«expr = »(norm a, 0), «expr = »(a, 0)) :=
begin
  refine [expr ⟨λ ha, ext.mpr _, λ h, by rw ["[", expr h, ",", expr norm_zero, "]"] []⟩],
  delta [ident norm] ["at", ident ha],
  rw [expr sub_eq_zero] ["at", ident ha],
  by_cases [expr h, ":", expr «expr ≤ »(0, d)],
  { obtain ["⟨", ident d', ",", ident rfl, "⟩", ":=", expr int.eq_coe_of_zero_le h],
    haveI [] [":", expr nonsquare d'] [":=", expr ⟨λ n h, «expr $ »(h_nonsquare n, by exact_mod_cast [expr h])⟩],
    exact [expr divides_sq_eq_zero_z ha] },
  { push_neg ["at", ident h],
    suffices [] [":", expr «expr = »(«expr * »(a.re, a.re), 0)],
    { rw [expr eq_zero_of_mul_self_eq_zero this] ["at", ident ha, "⊢"],
      simpa [] [] ["only"] ["[", expr true_and, ",", expr or_self_right, ",", expr zero_re, ",", expr zero_im, ",", expr eq_self_iff_true, ",", expr zero_eq_mul, ",", expr mul_zero, ",", expr mul_eq_zero, ",", expr h.ne, ",", expr false_or, ",", expr or_self, "]"] [] ["using", expr ha] },
    apply [expr _root_.le_antisymm _ (mul_self_nonneg _)],
    rw ["[", expr ha, ",", expr mul_assoc, "]"] [],
    exact [expr mul_nonpos_of_nonpos_of_nonneg h.le (mul_self_nonneg _)] }
end

variable{R : Type}[CommRingₓ R]

@[ext]
theorem hom_ext {d : ℤ} (f g : ℤ√d →+* R) (h : f sqrtd = g sqrtd) : f = g :=
  by 
    ext ⟨x_re, x_im⟩
    simp [decompose, h]

-- error in NumberTheory.Zsqrtd.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The unique `ring_hom` from `ℤ√d` to a ring `R`, constructed by replacing `√d` with the provided
root. Conversely, this associates to every mapping `ℤ√d →+* R` a value of `√d` in `R`. -/
@[simps #[]]
def lift {d : exprℤ()} : «expr ≃ »({r : R // «expr = »(«expr * »(r, r), «expr↑ »(d))}, «expr →+* »(«exprℤ√ »(d), R)) :=
{ to_fun := λ
  r, { to_fun := λ a, «expr + »(a.1, «expr * »(a.2, (r : R))),
    map_zero' := by simp [] [] [] [] [] [],
    map_add' := λ a b, by { simp [] [] [] [] [] [],
      ring [] },
    map_one' := by simp [] [] [] [] [] [],
    map_mul' := λ
    a
    b, by { have [] [":", expr «expr = »(«expr * »((«expr + »(a.re, «expr * »(a.im, r)) : R), «expr + »(b.re, «expr * »(b.im, r))), «expr + »(«expr + »(«expr * »(a.re, b.re), «expr * »(«expr + »(«expr * »(a.re, b.im), «expr * »(a.im, b.re)), r)), «expr * »(«expr * »(a.im, b.im), «expr * »(r, r))))] [":=", expr by ring []],
      simp [] [] [] ["[", expr this, ",", expr r.prop, "]"] [] [],
      ring [] } },
  inv_fun := λ
  f, ⟨f sqrtd, by rw ["[", "<-", expr f.map_mul, ",", expr dmuld, ",", expr ring_hom.map_int_cast, "]"] []⟩,
  left_inv := λ r, by { ext [] [] [],
    simp [] [] [] [] [] [] },
  right_inv := λ f, by { ext [] [] [],
    simp [] [] [] [] [] [] } }

-- error in NumberTheory.Zsqrtd.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- `lift r` is injective if `d` is non-square, and R has characteristic zero (that is, the map from
`ℤ` into `R` is injective). -/
theorem lift_injective
[char_zero R]
{d : exprℤ()}
(r : {r : R // «expr = »(«expr * »(r, r), «expr↑ »(d))})
(hd : ∀ n : exprℤ(), «expr ≠ »(d, «expr * »(n, n))) : function.injective (lift r) :=
«expr $ »((lift r).injective_iff.mpr, λ a ha, begin
   have [ident h_inj] [":", expr function.injective (coe : exprℤ() → R)] [":=", expr int.cast_injective],
   suffices [] [":", expr «expr = »(lift r a.norm, 0)],
   { simp [] [] ["only"] ["[", expr coe_int_re, ",", expr add_zero, ",", expr lift_apply_apply, ",", expr coe_int_im, ",", expr int.cast_zero, ",", expr zero_mul, "]"] [] ["at", ident this],
     rwa ["[", "<-", expr int.cast_zero, ",", expr h_inj.eq_iff, ",", expr norm_eq_zero hd, "]"] ["at", ident this] },
   rw ["[", expr norm_eq_mul_conj, ",", expr ring_hom.map_mul, ",", expr ha, ",", expr zero_mul, "]"] []
 end)

end Zsqrtd

