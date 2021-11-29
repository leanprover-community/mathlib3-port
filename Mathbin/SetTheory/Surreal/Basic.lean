import Mathbin.SetTheory.Pgame

/-!
# Surreal numbers

The basic theory of surreal numbers, built on top of the theory of combinatorial (pre-)games.

A pregame is `numeric` if all the Left options are strictly smaller than all the Right options, and
all those options are themselves numeric. In terms of combinatorial games, the numeric games have
"frozen"; you can only make your position worse by playing, and Left is some definite "number" of
moves ahead (or behind) Right.

A surreal number is an equivalence class of numeric pregames.

In fact, the surreals form a complete ordered field, containing a copy of the reals (and much else
besides!) but we do not yet have a complete development.

## Order properties
Surreal numbers inherit the relations `≤` and `<` from games, and these relations satisfy the axioms
of a partial order (recall that `x < y ↔ x ≤ y ∧ ¬ y ≤ x` did not hold for games).

## Algebraic operations
We show that the surreals form a linear ordered commutative group.

One can also map all the ordinals into the surreals!

### Multiplication of surreal numbers
The definition of multiplication for surreal numbers is surprisingly difficult and is currently
missing in the library. A sample proof can be found in Theorem 3.8 in the second reference below.
The difficulty lies in the length of the proof and the number of theorems that need to proven
simultaneously. This will make for a fun and challenging project.

## References
* [Conway, *On numbers and games*][conway2001]
* [Schleicher, Stoll, *An introduction to Conway's games and numbers*][schleicher_stoll]
-/


universe u

local infixl:0 " ≈ " => Pgame.Equiv

namespace Pgame

/-- A pre-game is numeric if everything in the L set is less than everything in the R set,
and all the elements of L and R are also numeric. -/
def numeric : Pgame → Prop
| ⟨l, r, L, R⟩ => (∀ i j, L i < R j) ∧ (∀ i, numeric (L i)) ∧ ∀ i, numeric (R i)

theorem numeric.move_left {x : Pgame} (o : numeric x) (i : x.left_moves) : numeric (x.move_left i) :=
  by 
    cases' x with xl xr xL xR 
    exact o.2.1 i

theorem numeric.move_right {x : Pgame} (o : numeric x) (j : x.right_moves) : numeric (x.move_right j) :=
  by 
    cases' x with xl xr xL xR 
    exact o.2.2 j

@[elab_as_eliminator]
theorem numeric_rec {C : Pgame → Prop}
  (H :
    ∀ l r (L : l → Pgame) (R : r → Pgame),
      (∀ i j, L i < R j) →
        (∀ i, numeric (L i)) → (∀ i, numeric (R i)) → (∀ i, C (L i)) → (∀ i, C (R i)) → C ⟨l, r, L, R⟩) :
  ∀ x, numeric x → C x
| ⟨l, r, L, R⟩, ⟨h, hl, hr⟩ => H _ _ _ _ h hl hr (fun i => numeric_rec _ (hl i)) fun i => numeric_rec _ (hr i)

theorem lt_asymmₓ {x y : Pgame} (ox : numeric x) (oy : numeric y) : x < y → ¬y < x :=
  by 
    refine' numeric_rec (fun xl xr xL xR hx oxl oxr IHxl IHxr => _) x ox y oy 
    refine' numeric_rec fun yl yr yL yR hy oyl oyr IHyl IHyr => _ 
    rw [mk_lt_mk, mk_lt_mk]
    rintro (⟨i, h₁⟩ | ⟨j, h₁⟩) (⟨i, h₂⟩ | ⟨j, h₂⟩)
    ·
      exact IHxl _ _ (oyl _) (lt_of_le_mk h₁) (lt_of_le_mk h₂)
    ·
      exact not_ltₓ.2 (le_transₓ h₂ h₁) (hy _ _)
    ·
      exact not_ltₓ.2 (le_transₓ h₁ h₂) (hx _ _)
    ·
      exact IHxr _ _ (oyr _) (lt_of_mk_le h₁) (lt_of_mk_le h₂)

theorem le_of_ltₓ {x y : Pgame} (ox : numeric x) (oy : numeric y) (h : x < y) : x ≤ y :=
  not_ltₓ.1 (lt_asymmₓ ox oy h)

/-- On numeric pre-games, `<` and `≤` satisfy the axioms of a partial order (even though they
don't on all pre-games). -/
theorem lt_iff_le_not_leₓ {x y : Pgame} (ox : numeric x) (oy : numeric y) : x < y ↔ x ≤ y ∧ ¬y ≤ x :=
  ⟨fun h => ⟨le_of_ltₓ ox oy h, not_leₓ.2 h⟩, fun h => not_leₓ.1 h.2⟩

theorem numeric_zero : numeric 0 :=
  ⟨by 
      rintro ⟨⟩ ⟨⟩,
    ⟨by 
        rintro ⟨⟩,
      by 
        rintro ⟨⟩⟩⟩

theorem numeric_one : numeric 1 :=
  ⟨by 
      rintro ⟨⟩ ⟨⟩,
    ⟨fun x => numeric_zero,
      by 
        rintro ⟨⟩⟩⟩

theorem numeric_neg : ∀ {x : Pgame} (o : numeric x), numeric (-x)
| ⟨l, r, L, R⟩, o =>
  ⟨fun j i => lt_iff_neg_gt.1 (o.1 i j), ⟨fun j => numeric_neg (o.2.2 j), fun i => numeric_neg (o.2.1 i)⟩⟩

@[nolint unused_arguments]
theorem numeric.move_left_lt {x : Pgame.{u}} (o : numeric x) (i : x.left_moves) : x.move_left i < x :=
  by 
    rw [lt_def_le]
    left 
    use i

theorem numeric.move_left_le {x : Pgame} (o : numeric x) (i : x.left_moves) : x.move_left i ≤ x :=
  le_of_ltₓ (o.move_left i) o (o.move_left_lt i)

@[nolint unused_arguments]
theorem numeric.lt_move_right {x : Pgame} (o : numeric x) (j : x.right_moves) : x < x.move_right j :=
  by 
    rw [lt_def_le]
    right 
    use j

theorem numeric.le_move_right {x : Pgame} (o : numeric x) (j : x.right_moves) : x ≤ x.move_right j :=
  le_of_ltₓ o (o.move_right j) (o.lt_move_right j)

theorem add_lt_add {w x y z : Pgame.{u}} (oy : numeric y) (oz : numeric z) (hwx : w < x) (hyz : y < z) : (w+y) < x+z :=
  by 
    rw [lt_def_le] at *
    rcases hwx with (⟨ix, hix⟩ | ⟨jw, hjw⟩) <;> rcases hyz with (⟨iz, hiz⟩ | ⟨jy, hjy⟩)
    ·
      left 
      use (left_moves_add x z).symm (Sum.inl ix)
      simp only [add_move_left_inl]
      calc (w+y) ≤ move_left x ix+y := add_le_add_right hix _ ≤ move_left x ix+move_left z iz :=
        add_le_add_left hiz _ ≤ move_left x ix+z := add_le_add_left (oz.move_left_le iz)
    ·
      left 
      use (left_moves_add x z).symm (Sum.inl ix)
      simp only [add_move_left_inl]
      calc (w+y) ≤ move_left x ix+y := add_le_add_right hix _ ≤ move_left x ix+move_right y jy :=
        add_le_add_left (oy.le_move_right jy)_ ≤ move_left x ix+z := add_le_add_left hjy
    ·
      right 
      use (right_moves_add w y).symm (Sum.inl jw)
      simp only [add_move_right_inl]
      calc (move_right w jw+y) ≤ x+y := add_le_add_right hjw _ ≤ x+move_left z iz := add_le_add_left hiz _ ≤ x+z :=
        add_le_add_left (oz.move_left_le iz)
    ·
      right 
      use (right_moves_add w y).symm (Sum.inl jw)
      simp only [add_move_right_inl]
      calc (move_right w jw+y) ≤ x+y := add_le_add_right hjw _ ≤ x+move_right y jy :=
        add_le_add_left (oy.le_move_right jy)_ ≤ x+z := add_le_add_left hjy

theorem numeric_add : ∀ {x y : Pgame} (ox : numeric x) (oy : numeric y), numeric (x+y)
| ⟨xl, xr, xL, xR⟩, ⟨yl, yr, yL, yR⟩, ox, oy =>
  ⟨by 
      rintro (ix | iy) (jx | jy)
      ·
        show (xL ix+⟨yl, yr, yL, yR⟩) < xR jx+⟨yl, yr, yL, yR⟩
        exact add_lt_add_right (ox.1 ix jx)
      ·
        show (xL ix+⟨yl, yr, yL, yR⟩) < ⟨xl, xr, xL, xR⟩+yR jy 
        exact add_lt_add oy (oy.move_right jy) (ox.move_left_lt _) (oy.lt_move_right _)
      ·
        exact add_lt_add (oy.move_left iy) oy (ox.lt_move_right _) (oy.move_left_lt _)
      ·
        exact @add_lt_add_left ⟨xl, xr, xL, xR⟩ _ _ (oy.1 iy jy),
    by 
      split 
      ·
        rintro (ix | iy)
        ·
          apply numeric_add (ox.move_left ix) oy
        ·
          apply numeric_add ox (oy.move_left iy)
      ·
        rintro (jx | jy)
        ·
          apply numeric_add (ox.move_right jx) oy
        ·
          apply numeric_add ox (oy.move_right jy)⟩

/-- Pre-games defined by natural numbers are numeric. -/
theorem numeric_nat : ∀ (n : ℕ), numeric n
| 0 => numeric_zero
| n+1 => numeric_add (numeric_nat n) numeric_one

/-- The pre-game omega is numeric. -/
theorem numeric_omega : numeric omega :=
  ⟨by 
      rintro ⟨⟩ ⟨⟩,
    fun i => numeric_nat i.down,
    by 
      rintro ⟨⟩⟩

/-- The pre-game `half` is numeric. -/
theorem numeric_half : numeric half :=
  by 
    split 
    ·
      rintro ⟨⟩ ⟨⟩
      exact zero_lt_one 
    split  <;> rintro ⟨⟩
    ·
      exact numeric_zero
    ·
      exact numeric_one

theorem half_add_half_equiv_one : (half+half) ≈ 1 :=
  by 
    split  <;> rw [le_def] <;> split 
    ·
      rintro (⟨⟨⟩⟩ | ⟨⟨⟩⟩)
      ·
        right 
        use Sum.inr PUnit.unit 
        calc
          ((half+half).moveLeft (Sum.inl PUnit.unit)).moveRight (Sum.inr PUnit.unit) =
            (half.move_left PUnit.unit+half).moveRight (Sum.inr PUnit.unit) :=
          by 
            fsplit _ = (0+half).moveRight (Sum.inr PUnit.unit) :=
          by 
            fsplit _ ≈ 1 :=
          zero_add_equiv 1_ ≤ 1 := Pgame.le_refl 1
      ·
        right 
        use Sum.inl PUnit.unit 
        calc
          ((half+half).moveLeft (Sum.inr PUnit.unit)).moveRight (Sum.inl PUnit.unit) =
            (half+half.move_left PUnit.unit).moveRight (Sum.inl PUnit.unit) :=
          by 
            fsplit _ = (half+0).moveRight (Sum.inl PUnit.unit) :=
          by 
            fsplit _ ≈ 1 :=
          add_zero_equiv 1_ ≤ 1 := Pgame.le_refl 1
    ·
      rintro ⟨⟩
    ·
      rintro ⟨⟩
      left 
      use Sum.inl PUnit.unit 
      calc 0 ≤ half := le_of_ltₓ numeric_zero numeric_half zero_lt_half _ ≈ 0+half :=
        (zero_add_equiv half).symm _ = (half+half).moveLeft (Sum.inl PUnit.unit) :=
        by 
          fsplit
    ·
      rintro (⟨⟨⟩⟩ | ⟨⟨⟩⟩) <;> left
      ·
        exact ⟨Sum.inr PUnit.unit, le_of_le_of_equiv (Pgame.le_refl _) (add_zero_equiv _).symm⟩
      ·
        exact ⟨Sum.inl PUnit.unit, le_of_le_of_equiv (Pgame.le_refl _) (zero_add_equiv _).symm⟩

end Pgame

/-- The equivalence on numeric pre-games. -/
def Surreal.Equiv (x y : { x // Pgame.Numeric x }) : Prop :=
  x.1.Equiv y.1

instance Surreal.setoid : Setoidₓ { x // Pgame.Numeric x } :=
  ⟨fun x y => x.1.Equiv y.1, fun x => Pgame.equiv_refl _, fun x y => Pgame.equiv_symm, fun x y z => Pgame.equiv_trans⟩

/-- The type of surreal numbers. These are the numeric pre-games quotiented
by the equivalence relation `x ≈ y ↔ x ≤ y ∧ y ≤ x`. In the quotient,
the order becomes a total order. -/
def Surreal :=
  Quotientₓ Surreal.setoid

namespace Surreal

open Pgame

/-- Construct a surreal number from a numeric pre-game. -/
def mk (x : Pgame) (h : x.numeric) : Surreal :=
  Quotientₓ.mk ⟨x, h⟩

instance  : HasZero Surreal :=
  { zero := «expr⟦ ⟧» ⟨0, numeric_zero⟩ }

instance  : HasOne Surreal :=
  { one := «expr⟦ ⟧» ⟨1, numeric_one⟩ }

instance  : Inhabited Surreal :=
  ⟨0⟩

-- error in SetTheory.Surreal.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Lift an equivalence-respecting function on pre-games to surreals. -/
def lift
{α}
(f : ∀ x, numeric x → α)
(H : ∀ {x y} (hx : numeric x) (hy : numeric y), x.equiv y → «expr = »(f x hx, f y hy)) : surreal → α :=
quotient.lift (λ x : {x // numeric x}, f x.1 x.2) (λ x y, H x.2 y.2)

/-- Lift a binary equivalence-respecting function on pre-games to surreals. -/
def lift₂ {α} (f : ∀ x y, numeric x → numeric y → α)
  (H :
    ∀ {x₁ y₁ x₂ y₂} (ox₁ : numeric x₁) (oy₁ : numeric y₁) (ox₂ : numeric x₂) (oy₂ : numeric y₂),
      x₁.equiv x₂ → y₁.equiv y₂ → f x₁ y₁ ox₁ oy₁ = f x₂ y₂ ox₂ oy₂) :
  Surreal → Surreal → α :=
  lift (fun x ox => lift (fun y oy => f x y ox oy) fun y₁ y₂ oy₁ oy₂ h => H _ _ _ _ (equiv_refl _) h)
    fun x₁ x₂ ox₁ ox₂ h =>
      funext$
        Quotientₓ.ind$
          by 
            exact fun ⟨y, oy⟩ => H _ _ _ _ h (equiv_refl _)

/-- The relation `x ≤ y` on surreals. -/
def le : Surreal → Surreal → Prop :=
  lift₂ (fun x y _ _ => x ≤ y) fun x₁ y₁ x₂ y₂ _ _ _ _ hx hy => propext (le_congr hx hy)

/-- The relation `x < y` on surreals. -/
def lt : Surreal → Surreal → Prop :=
  lift₂ (fun x y _ _ => x < y) fun x₁ y₁ x₂ y₂ _ _ _ _ hx hy => propext (lt_congr hx hy)

theorem not_leₓ : ∀ {x y : Surreal}, ¬le x y ↔ lt y x :=
  by 
    rintro ⟨⟨x, ox⟩⟩ ⟨⟨y, oy⟩⟩ <;> exact not_leₓ

-- error in SetTheory.Surreal.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Addition on surreals is inherited from pre-game addition:
the sum of `x = {xL | xR}` and `y = {yL | yR}` is `{xL + y, x + yL | xR + y, x + yR}`. -/
def add : surreal → surreal → surreal :=
surreal.lift₂ (λ
 (x y : pgame)
 (ox)
 (oy), «expr⟦ ⟧»(⟨«expr + »(x, y), numeric_add ox oy⟩)) (λ
 x₁ y₁ x₂ y₂ _ _ _ _ hx hy, quotient.sound (pgame.add_congr hx hy))

/-- Negation for surreal numbers is inherited from pre-game negation:
the negation of `{L | R}` is `{-R | -L}`. -/
def neg : Surreal → Surreal :=
  Surreal.lift (fun x ox => «expr⟦ ⟧» ⟨-x, Pgame.numeric_neg ox⟩) fun _ _ _ _ a => Quotientₓ.sound (Pgame.neg_congr a)

instance  : LE Surreal :=
  ⟨le⟩

instance  : LT Surreal :=
  ⟨lt⟩

instance  : Add Surreal :=
  ⟨add⟩

instance  : Neg Surreal :=
  ⟨neg⟩

instance  : OrderedAddCommGroup Surreal :=
  { add := ·+·,
    add_assoc :=
      by 
        rintro ⟨_⟩ ⟨_⟩ ⟨_⟩
        exact Quotientₓ.sound add_assoc_equiv,
    zero := 0,
    zero_add :=
      by 
        rintro ⟨_⟩
        exact Quotientₓ.sound (Pgame.zero_add_equiv _),
    add_zero :=
      by 
        rintro ⟨_⟩
        exact Quotientₓ.sound (Pgame.add_zero_equiv _),
    neg := Neg.neg,
    add_left_neg :=
      by 
        rintro ⟨_⟩
        exact Quotientₓ.sound Pgame.add_left_neg_equiv,
    add_comm :=
      by 
        rintro ⟨_⟩ ⟨_⟩
        exact Quotientₓ.sound Pgame.add_comm_equiv,
    le := · ≤ ·, lt := · < ·,
    le_refl :=
      by 
        rintro ⟨_⟩
        rfl,
    le_trans :=
      by 
        rintro ⟨_⟩ ⟨_⟩ ⟨_⟩
        exact Pgame.le_trans,
    lt_iff_le_not_le :=
      by 
        rintro ⟨_, ox⟩ ⟨_, oy⟩
        exact Pgame.lt_iff_le_not_le ox oy,
    le_antisymm :=
      by 
        rintro ⟨_⟩ ⟨_⟩ h₁ h₂ 
        exact Quotientₓ.sound ⟨h₁, h₂⟩,
    add_le_add_left :=
      by 
        rintro ⟨_⟩ ⟨_⟩ hx ⟨_⟩
        exact Pgame.add_le_add_left hx }

noncomputable instance  : LinearOrderedAddCommGroup Surreal :=
  { Surreal.orderedAddCommGroup with
    le_total :=
      by 
        rintro ⟨⟨x, ox⟩⟩ ⟨⟨y, oy⟩⟩ <;>
          classical <;> exact or_iff_not_imp_left.2 fun h => le_of_ltₓ oy ox (Pgame.not_le.1 h),
    decidableLe := Classical.decRel _ }

end Surreal

