import Mathbin.Order.BoundedOrder

/-!
# (Generalized) Boolean algebras

A Boolean algebra is a bounded distributive lattice with a complement operator. Boolean algebras
generalize the (classical) logic of propositions and the lattice of subsets of a set.

Generalized Boolean algebras may be less familiar, but they are essentially Boolean algebras which
do not necessarily have a top element (`⊤`) (and hence not all elements may have complements). One
example in mathlib is `finset α`, the type of all finite subsets of an arbitrary
(not-necessarily-finite) type `α`.

`generalized_boolean_algebra α` is defined to be a distributive lattice with bottom (`⊥`) admitting
a *relative* complement operator, written using "set difference" notation as `x \ y` (`sdiff x y`).
For convenience, the `boolean_algebra` type class is defined to extend `generalized_boolean_algebra`
so that it is also bundled with a `\` operator.

(A terminological point: `x \ y` is the complement of `y` relative to the interval `[⊥, x]`. We do
not yet have relative complements for arbitrary intervals, as we do not even have lattice
intervals.)

## Main declarations

* `has_compl`: a type class for the complement operator
* `generalized_boolean_algebra`: a type class for generalized Boolean algebras
* `boolean_algebra.core`: a type class with the minimal assumptions for a Boolean algebras
* `boolean_algebra`: the main type class for Boolean algebras; it extends both
  `generalized_boolean_algebra` and `boolean_algebra.core`. An instance of `boolean_algebra` can be
  obtained from one of `boolean_algebra.core` using `boolean_algebra.of_core`.
* `Prop.boolean_algebra`: the Boolean algebra instance on `Prop`

## Implementation notes

The `sup_inf_sdiff` and `inf_inf_sdiff` axioms for the relative complement operator in
`generalized_boolean_algebra` are taken from
[Wikipedia](https://en.wikipedia.org/wiki/Boolean_algebra_(structure)#Generalizations).

[Stone's paper introducing generalized Boolean algebras][Stone1935] does not define a relative
complement operator `a \ b` for all `a`, `b`. Instead, the postulates there amount to an assumption
that for all `a, b : α` where `a ≤ b`, the equations `x ⊔ a = b` and `x ⊓ a = ⊥` have a solution
`x`. `disjoint.sdiff_unique` proves that this `x` is in fact `b \ a`.

## Notations

* `xᶜ` is notation for `compl x`
* `x \ y` is notation for `sdiff x y`.

## References

* <https://en.wikipedia.org/wiki/Boolean_algebra_(structure)#Generalizations>
* [*Postulates for Boolean Algebras and Generalized Boolean Algebras*, M.H. Stone][Stone1935]
* [*Lattice Theory: Foundation*, George Grätzer][Gratzer2011]

## Tags

generalized Boolean algebras, Boolean algebras, lattices, sdiff, compl
-/


universe u v

variable{α : Type u}{w x y z : α}

/-!
### Generalized Boolean algebras

Some of the lemmas in this section are from:

* [*Lattice Theory: Foundation*, George Grätzer][Gratzer2011]
* <https://ncatlab.org/nlab/show/relative+complement>
* <https://people.math.gatech.edu/~mccuan/courses/4317/symmetricdifference.pdf>

-/


export HasSdiff(sdiff)

/-- A generalized Boolean algebra is a distributive lattice with `⊥` and a relative complement
operation `\` (called `sdiff`, after "set difference") satisfying `(a ⊓ b) ⊔ (a \ b) = a` and
`(a ⊓ b) ⊓ (a \ b) = b`, i.e. `a \ b` is the complement of `b` in `a`.

This is a generalization of Boolean algebras which applies to `finset α` for arbitrary
(not-necessarily-`fintype`) `α`. -/
class GeneralizedBooleanAlgebra(α : Type u) extends DistribLattice α, HasSdiff α, HasBot α where 
  sup_inf_sdiff : ∀ (a b : α), a⊓b⊔a \ b = a 
  inf_inf_sdiff : ∀ (a b : α), a⊓b⊓(a \ b) = ⊥

section GeneralizedBooleanAlgebra

variable[GeneralizedBooleanAlgebra α]

@[simp]
theorem sup_inf_sdiff (x y : α) : x⊓y⊔x \ y = x :=
  GeneralizedBooleanAlgebra.sup_inf_sdiff _ _

@[simp]
theorem inf_inf_sdiff (x y : α) : x⊓y⊓(x \ y) = ⊥ :=
  GeneralizedBooleanAlgebra.inf_inf_sdiff _ _

@[simp]
theorem sup_sdiff_inf (x y : α) : x \ y⊔x⊓y = x :=
  by 
    rw [sup_comm, sup_inf_sdiff]

@[simp]
theorem inf_sdiff_inf (x y : α) : x \ y⊓(x⊓y) = ⊥ :=
  by 
    rw [inf_comm, inf_inf_sdiff]

instance (priority := 100)GeneralizedBooleanAlgebra.toOrderBot : OrderBot α :=
  { GeneralizedBooleanAlgebra.toHasBot α with
    bot_le :=
      fun a =>
        by 
          rw [←inf_inf_sdiff a a, inf_assoc]
          exact inf_le_left }

theorem disjoint_inf_sdiff : Disjoint (x⊓y) (x \ y) :=
  (inf_inf_sdiff x y).le

theorem sdiff_unique (s : x⊓y⊔z = x) (i : x⊓y⊓z = ⊥) : x \ y = z :=
  by 
    convRHS at s => rw [←sup_inf_sdiff x y, sup_comm]
    rw [sup_comm] at s 
    convRHS at i => rw [←inf_inf_sdiff x y, inf_comm]
    rw [inf_comm] at i 
    exact (eq_of_inf_eq_sup_eq i s).symm

-- error in Order.BooleanAlgebra: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem sdiff_symm
(hy : «expr ≤ »(y, x))
(hz : «expr ≤ »(z, x))
(H : «expr = »(«expr \ »(x, y), z)) : «expr = »(«expr \ »(x, z), y) :=
have hyi : «expr = »(«expr ⊓ »(x, y), y) := inf_eq_right.2 hy,
have hzi : «expr = »(«expr ⊓ »(x, z), z) := inf_eq_right.2 hz,
eq_of_inf_eq_sup_eq (begin
   have [ident ixy] [] [":=", expr inf_inf_sdiff x y],
   rw ["[", expr H, ",", expr hyi, "]"] ["at", ident ixy],
   have [ident ixz] [] [":=", expr inf_inf_sdiff x z],
   rwa ["[", expr hzi, ",", expr inf_comm, ",", "<-", expr ixy, "]"] ["at", ident ixz]
 end) (begin
   have [ident sxz] [] [":=", expr sup_inf_sdiff x z],
   rw ["[", expr hzi, ",", expr sup_comm, "]"] ["at", ident sxz],
   rw [expr sxz] [],
   symmetry,
   have [ident sxy] [] [":=", expr sup_inf_sdiff x y],
   rwa ["[", expr H, ",", expr hyi, "]"] ["at", ident sxy]
 end)

theorem sdiff_le : x \ y ≤ x :=
  calc x \ y ≤ x⊓y⊔x \ y := le_sup_right 
    _ = x := sup_inf_sdiff x y
    

@[simp]
theorem bot_sdiff : ⊥ \ x = ⊥ :=
  le_bot_iff.1 sdiff_le

theorem inf_sdiff_right : x⊓(x \ y) = x \ y :=
  by 
    rw [inf_of_le_right (@sdiff_le _ x y _)]

theorem inf_sdiff_left : x \ y⊓x = x \ y :=
  by 
    rw [inf_comm, inf_sdiff_right]

@[simp]
theorem sdiff_self : x \ x = ⊥ :=
  by 
    rw [←inf_inf_sdiff, inf_idem, inf_of_le_right (@sdiff_le _ x x _)]

@[simp]
theorem sup_sdiff_self_right : x⊔y \ x = x⊔y :=
  calc x⊔y \ x = x⊔x⊓y⊔y \ x :=
    by 
      rw [sup_inf_self]
    _ = x⊔(y⊓x⊔y \ x) :=
    by 
      acRfl 
    _ = x⊔y :=
    by 
      rw [sup_inf_sdiff]
    

@[simp]
theorem sup_sdiff_self_left : y \ x⊔x = y⊔x :=
  by 
    rw [sup_comm, sup_sdiff_self_right, sup_comm]

theorem sup_sdiff_symm : x⊔y \ x = y⊔x \ y :=
  by 
    rw [sup_sdiff_self_right, sup_sdiff_self_right, sup_comm]

theorem sup_sdiff_cancel_right (h : x ≤ y) : x⊔y \ x = y :=
  by 
    convRHS => rw [←sup_inf_sdiff y x, inf_eq_right.2 h]

theorem sdiff_sup_cancel (h : y ≤ x) : x \ y⊔y = x :=
  by 
    rw [sup_comm, sup_sdiff_cancel_right h]

theorem sup_le_of_le_sdiff_left (h : y ≤ z \ x) (hxz : x ≤ z) : x⊔y ≤ z :=
  (sup_le_sup_left h x).trans (sup_sdiff_cancel_right hxz).le

theorem sup_le_of_le_sdiff_right (h : x ≤ z \ y) (hyz : y ≤ z) : x⊔y ≤ z :=
  (sup_le_sup_right h y).trans (sdiff_sup_cancel hyz).le

@[simp]
theorem sup_sdiff_left : x⊔x \ y = x :=
  by 
    rw [sup_eq_left]
    exact sdiff_le

theorem sup_sdiff_right : x \ y⊔x = x :=
  by 
    rw [sup_comm, sup_sdiff_left]

@[simp]
theorem sdiff_inf_sdiff : x \ y⊓(y \ x) = ⊥ :=
  Eq.symm$
    calc ⊥ = x⊓y⊓(x \ y) :=
      by 
        rw [inf_inf_sdiff]
      _ = x⊓(y⊓x⊔y \ x)⊓(x \ y) :=
      by 
        rw [sup_inf_sdiff]
      _ = (x⊓(y⊓x)⊔x⊓(y \ x))⊓(x \ y) :=
      by 
        rw [inf_sup_left]
      _ = (y⊓(x⊓x)⊔x⊓(y \ x))⊓(x \ y) :=
      by 
        acRfl 
      _ = (y⊓x⊔x⊓(y \ x))⊓(x \ y) :=
      by 
        rw [inf_idem]
      _ = x⊓y⊓(x \ y)⊔x⊓(y \ x)⊓(x \ y) :=
      by 
        rw [inf_sup_right, @inf_comm _ _ x y]
      _ = x⊓(y \ x)⊓(x \ y) :=
      by 
        rw [inf_inf_sdiff, bot_sup_eq]
      _ = x⊓(x \ y)⊓(y \ x) :=
      by 
        acRfl 
      _ = x \ y⊓(y \ x) :=
      by 
        rw [inf_sdiff_right]
      

theorem disjoint_sdiff_sdiff : Disjoint (x \ y) (y \ x) :=
  sdiff_inf_sdiff.le

theorem le_sup_sdiff : y ≤ x⊔y \ x :=
  by 
    rw [sup_sdiff_self_right]
    exact le_sup_right

theorem le_sdiff_sup : y ≤ y \ x⊔x :=
  by 
    rw [sup_comm]
    exact le_sup_sdiff

@[simp]
theorem inf_sdiff_self_right : x⊓(y \ x) = ⊥ :=
  calc x⊓(y \ x) = (x⊓y⊔x \ y)⊓(y \ x) :=
    by 
      rw [sup_inf_sdiff]
    _ = x⊓y⊓(y \ x)⊔x \ y⊓(y \ x) :=
    by 
      rw [inf_sup_right]
    _ = ⊥ :=
    by 
      rw [@inf_comm _ _ x y, inf_inf_sdiff, sdiff_inf_sdiff, bot_sup_eq]
    

@[simp]
theorem inf_sdiff_self_left : y \ x⊓x = ⊥ :=
  by 
    rw [inf_comm, inf_sdiff_self_right]

theorem disjoint_sdiff_self_left : Disjoint (y \ x) x :=
  inf_sdiff_self_left.le

theorem disjoint_sdiff_self_right : Disjoint x (y \ x) :=
  inf_sdiff_self_right.le

theorem Disjoint.disjoint_sdiff_left (h : Disjoint x y) : Disjoint (x \ z) y :=
  h.mono_left sdiff_le

theorem Disjoint.disjoint_sdiff_right (h : Disjoint x y) : Disjoint x (y \ z) :=
  h.mono_right sdiff_le

theorem Disjoint.sdiff_eq_of_sup_eq (hi : Disjoint x z) (hs : x⊔z = y) : y \ x = z :=
  have h : y⊓x = x := inf_eq_right.2$ le_sup_left.trans hs.le 
  sdiff_unique
    (by 
      rw [h, hs])
    (by 
      rw [h, hi.eq_bot])

theorem Disjoint.sup_sdiff_cancel_left (h : Disjoint x y) : (x⊔y) \ x = y :=
  h.sdiff_eq_of_sup_eq rfl

theorem Disjoint.sup_sdiff_cancel_right (h : Disjoint x y) : (x⊔y) \ y = x :=
  h.symm.sdiff_eq_of_sup_eq sup_comm

protected theorem Disjoint.sdiff_unique (hd : Disjoint x z) (hz : z ≤ y) (hs : y ≤ x⊔z) : y \ x = z :=
  sdiff_unique
    (by 
      rw [←inf_eq_right] at hs 
      rwa [sup_inf_right, inf_sup_right, @sup_comm _ _ x, inf_sup_self, inf_comm, @sup_comm _ _ z, hs, sup_eq_left])
    (by 
      rw [inf_assoc, hd.eq_bot, inf_bot_eq])

theorem disjoint_sdiff_iff_le (hz : z ≤ y) (hx : x ≤ y) : Disjoint z (y \ x) ↔ z ≤ x :=
  ⟨fun H =>
      le_of_inf_le_sup_le (le_transₓ H bot_le)
        (by 
          rw [sup_sdiff_cancel_right hx]
          refine' le_transₓ (sup_le_sup_left sdiff_le z) _ 
          rw [sup_eq_right.2 hz]),
    fun H => disjoint_sdiff_self_right.mono_left H⟩

theorem le_iff_disjoint_sdiff (hz : z ≤ y) (hx : x ≤ y) : z ≤ x ↔ Disjoint z (y \ x) :=
  (disjoint_sdiff_iff_le hz hx).symm

theorem inf_sdiff_eq_bot_iff (hz : z ≤ y) (hx : x ≤ y) : z⊓(y \ x) = ⊥ ↔ z ≤ x :=
  by 
    rw [←disjoint_iff]
    exact disjoint_sdiff_iff_le hz hx

theorem le_iff_eq_sup_sdiff (hz : z ≤ y) (hx : x ≤ y) : x ≤ z ↔ y = z⊔y \ x :=
  ⟨fun H =>
      by 
        apply le_antisymmₓ
        ·
          convLHS => rw [←sup_inf_sdiff y x]
          apply sup_le_sup_right 
          rwa [inf_eq_right.2 hx]
        ·
          apply le_transₓ
          ·
            apply sup_le_sup_right hz
          ·
            rw [sup_sdiff_left],
    fun H =>
      by 
        convLHS at H => rw [←sup_sdiff_cancel_right hx]
        refine' le_of_inf_le_sup_le _ H.le 
        rw [inf_sdiff_self_right]
        exact bot_le⟩

theorem sup_sdiff_cancel' (hx : x ≤ z) (hz : z ≤ y) : z⊔y \ x = y :=
  ((le_iff_eq_sup_sdiff hz (hx.trans hz)).1 hx).symm

theorem sdiff_sup : y \ (x⊔z) = y \ x⊓(y \ z) :=
  sdiff_unique
    (calc y⊓(x⊔z)⊔y \ x⊓(y \ z) = (y⊓(x⊔z)⊔y \ x)⊓(y⊓(x⊔z)⊔y \ z) :=
      by 
        rw [sup_inf_left]
      _ = (y⊓x⊔y⊓z⊔y \ x)⊓(y⊓x⊔y⊓z⊔y \ z) :=
      by 
        rw [@inf_sup_left _ _ y]
      _ = (y⊓z⊔(y⊓x⊔y \ x))⊓(y⊓x⊔(y⊓z⊔y \ z)) :=
      by 
        acRfl 
      _ = (y⊓z⊔y)⊓(y⊓x⊔y) :=
      by 
        rw [sup_inf_sdiff, sup_inf_sdiff]
      _ = (y⊔y⊓z)⊓(y⊔y⊓x) :=
      by 
        acRfl 
      _ = y :=
      by 
        rw [sup_inf_self, sup_inf_self, inf_idem]
      )
    (calc y⊓(x⊔z)⊓(y \ x⊓(y \ z)) = (y⊓x⊔y⊓z)⊓(y \ x⊓(y \ z)) :=
      by 
        rw [inf_sup_left]
      _ = y⊓x⊓(y \ x⊓(y \ z))⊔y⊓z⊓(y \ x⊓(y \ z)) :=
      by 
        rw [inf_sup_right]
      _ = y⊓x⊓(y \ x)⊓(y \ z)⊔y \ x⊓(y \ z⊓(y⊓z)) :=
      by 
        acRfl 
      _ = ⊥ :=
      by 
        rw [inf_inf_sdiff, bot_inf_eq, bot_sup_eq, @inf_comm _ _ (y \ z), inf_inf_sdiff, inf_bot_eq]
      )

theorem sdiff_inf : y \ (x⊓z) = y \ x⊔y \ z :=
  sdiff_unique
    (calc y⊓(x⊓z)⊔(y \ x⊔y \ z) = z⊓(y⊓x)⊔(y \ x⊔y \ z) :=
      by 
        acRfl 
      _ = (z⊔(y \ x⊔y \ z))⊓(y⊓x⊔(y \ x⊔y \ z)) :=
      by 
        rw [sup_inf_right]
      _ = (y \ x⊔(y \ z⊔z))⊓(y⊓x⊔(y \ x⊔y \ z)) :=
      by 
        acRfl 
      _ = (y⊔z)⊓(y⊓x⊔(y \ x⊔y \ z)) :=
      by 
        rw [sup_sdiff_self_left, ←sup_assoc, sup_sdiff_right]
      _ = (y⊔z)⊓y :=
      by 
        rw [←sup_assoc, sup_inf_sdiff, sup_sdiff_left]
      _ = y :=
      by 
        rw [inf_comm, inf_sup_self]
      )
    (calc y⊓(x⊓z)⊓(y \ x⊔y \ z) = y⊓(x⊓z)⊓(y \ x)⊔y⊓(x⊓z)⊓(y \ z) :=
      by 
        rw [inf_sup_left]
      _ = z⊓(y⊓x⊓(y \ x))⊔z⊓(y⊓x)⊓(y \ z) :=
      by 
        acRfl 
      _ = z⊓(y⊓x)⊓(y \ z) :=
      by 
        rw [inf_inf_sdiff, inf_bot_eq, bot_sup_eq]
      _ = x⊓(y⊓z⊓(y \ z)) :=
      by 
        acRfl 
      _ = ⊥ :=
      by 
        rw [inf_inf_sdiff, inf_bot_eq]
      )

@[simp]
theorem sdiff_inf_self_right : y \ (x⊓y) = y \ x :=
  by 
    rw [sdiff_inf, sdiff_self, sup_bot_eq]

@[simp]
theorem sdiff_inf_self_left : y \ (y⊓x) = y \ x :=
  by 
    rw [inf_comm, sdiff_inf_self_right]

theorem sdiff_eq_sdiff_iff_inf_eq_inf : y \ x = y \ z ↔ y⊓x = y⊓z :=
  ⟨fun h =>
      eq_of_inf_eq_sup_eq
        (by 
          rw [inf_inf_sdiff, h, inf_inf_sdiff])
        (by 
          rw [sup_inf_sdiff, h, sup_inf_sdiff]),
    fun h =>
      by 
        rw [←sdiff_inf_self_right, ←@sdiff_inf_self_right _ z y, inf_comm, h, inf_comm]⟩

theorem Disjoint.sdiff_eq_left (h : Disjoint x y) : x \ y = x :=
  by 
    convRHS => rw [←sup_inf_sdiff x y, h.eq_bot, bot_sup_eq]

theorem Disjoint.sdiff_eq_right (h : Disjoint x y) : y \ x = y :=
  h.symm.sdiff_eq_left

@[simp]
theorem sdiff_bot : x \ ⊥ = x :=
  disjoint_bot_right.sdiff_eq_left

theorem sdiff_eq_self_iff_disjoint : x \ y = x ↔ Disjoint y x :=
  calc x \ y = x ↔ x \ y = x \ ⊥ :=
    by 
      rw [sdiff_bot]
    _ ↔ x⊓y = x⊓⊥ := sdiff_eq_sdiff_iff_inf_eq_inf 
    _ ↔ Disjoint y x :=
    by 
      rw [inf_bot_eq, inf_comm, disjoint_iff]
    

theorem sdiff_eq_self_iff_disjoint' : x \ y = x ↔ Disjoint x y :=
  by 
    rw [sdiff_eq_self_iff_disjoint, Disjoint.comm]

theorem sdiff_lt (hx : y ≤ x) (hy : y ≠ ⊥) : x \ y < x :=
  by 
    refine' sdiff_le.lt_of_ne fun h => hy _ 
    rw [sdiff_eq_self_iff_disjoint', disjoint_iff] at h 
    rw [←h, inf_eq_right.mpr hx]

theorem sdiff_le_sdiff_left (h : z ≤ x) : w \ x ≤ w \ z :=
  le_of_inf_le_sup_le
    (calc w \ x⊓(w⊓z) ≤ w \ x⊓(w⊓x) := inf_le_inf le_rfl (inf_le_inf le_rfl h)
      _ = ⊥ :=
      by 
        rw [inf_comm, inf_inf_sdiff]
      _ ≤ w \ z⊓(w⊓z) := bot_le
      )
    (calc w \ x⊔w⊓z ≤ w \ x⊔w⊓x := sup_le_sup le_rfl (inf_le_inf le_rfl h)
      _ ≤ w :=
      by 
        rw [sup_comm, sup_inf_sdiff]
      _ = w \ z⊔w⊓z :=
      by 
        rw [sup_comm, sup_inf_sdiff]
      )

theorem sdiff_le_iff : y \ x ≤ z ↔ y ≤ x⊔z :=
  ⟨fun h =>
      le_of_inf_le_sup_le
        (le_of_eqₓ
          (calc y⊓(y \ x) = y \ x := inf_sdiff_right 
            _ = x⊓(y \ x)⊔z⊓(y \ x) :=
            by 
              rw [inf_eq_right.2 h, inf_sdiff_self_right, bot_sup_eq]
            _ = (x⊔z)⊓(y \ x) := inf_sup_right.symm
            ))
        (calc y⊔y \ x = y := sup_sdiff_left 
          _ ≤ y⊔(x⊔z) := le_sup_left 
          _ = y \ x⊔x⊔z :=
          by 
            rw [←sup_assoc, ←@sup_sdiff_self_left _ x y]
          _ = x⊔z⊔y \ x :=
          by 
            acRfl
          ),
    fun h =>
      le_of_inf_le_sup_le
        (calc y \ x⊓x = ⊥ := inf_sdiff_self_left 
          _ ≤ z⊓x := bot_le
          )
        (calc y \ x⊔x = y⊔x := sup_sdiff_self_left 
          _ ≤ x⊔z⊔x := sup_le_sup_right h x 
          _ ≤ z⊔x :=
          by 
            rw [sup_assoc, sup_comm, sup_assoc, sup_idem]
          )⟩

@[simp]
theorem sdiff_eq_bot_iff : y \ x = ⊥ ↔ y ≤ x :=
  by 
    rw [←le_bot_iff, sdiff_le_iff, sup_bot_eq]

theorem sdiff_le_comm : x \ y ≤ z ↔ x \ z ≤ y :=
  by 
    rw [sdiff_le_iff, sup_comm, sdiff_le_iff]

theorem sdiff_le_sdiff_right (h : w ≤ y) : w \ x ≤ y \ x :=
  le_of_inf_le_sup_le
    (calc w \ x⊓(w⊓x) = ⊥ :=
      by 
        rw [inf_comm, inf_inf_sdiff]
      _ ≤ y \ x⊓(w⊓x) := bot_le
      )
    (calc w \ x⊔w⊓x = w :=
      by 
        rw [sup_comm, sup_inf_sdiff]
      _ ≤ y⊓(y \ x)⊔w := le_sup_right 
      _ = y⊓(y \ x)⊔y⊓w :=
      by 
        rw [inf_eq_right.2 h]
      _ = y⊓(y \ x⊔w) :=
      by 
        rw [inf_sup_left]
      _ = (y \ x⊔y⊓x)⊓(y \ x⊔w) :=
      by 
        rw [@sup_comm _ _ (y \ x) (y⊓x), sup_inf_sdiff]
      _ = y \ x⊔y⊓x⊓w :=
      by 
        rw [←sup_inf_left]
      _ = y \ x⊔w⊓y⊓x :=
      by 
        acRfl 
      _ = y \ x⊔w⊓x :=
      by 
        rw [inf_eq_left.2 h]
      )

theorem sdiff_le_sdiff (h₁ : w ≤ y) (h₂ : z ≤ x) : w \ x ≤ y \ z :=
  calc w \ x ≤ w \ z := sdiff_le_sdiff_left h₂ 
    _ ≤ y \ z := sdiff_le_sdiff_right h₁
    

theorem sdiff_lt_sdiff_right (h : x < y) (hz : z ≤ x) : x \ z < y \ z :=
  (sdiff_le_sdiff_right h.le).lt_of_not_le$ fun h' => h.not_le$ le_sdiff_sup.trans$ sup_le_of_le_sdiff_right h' hz

theorem sup_inf_inf_sdiff : x⊓y⊓z⊔y \ z = x⊓y⊔y \ z :=
  calc x⊓y⊓z⊔y \ z = x⊓(y⊓z)⊔y \ z :=
    by 
      rw [inf_assoc]
    _ = (x⊔y \ z)⊓y :=
    by 
      rw [sup_inf_right, sup_inf_sdiff]
    _ = x⊓y⊔y \ z :=
    by 
      rw [inf_sup_right, inf_sdiff_left]
    

@[simp]
theorem inf_sdiff_sup_left : x \ z⊓(x⊔y) = x \ z :=
  by 
    rw [inf_sup_left, inf_sdiff_left, sup_inf_self]

@[simp]
theorem inf_sdiff_sup_right : x \ z⊓(y⊔x) = x \ z :=
  by 
    rw [sup_comm, inf_sdiff_sup_left]

theorem sdiff_sdiff_right : x \ (y \ z) = x \ y⊔x⊓y⊓z :=
  by 
    rw [sup_comm, inf_comm, ←inf_assoc, sup_inf_inf_sdiff]
    apply sdiff_unique
    ·
      calc x⊓(y \ z)⊔(z⊓x⊔x \ y) = (x⊔(z⊓x⊔x \ y))⊓(y \ z⊔(z⊓x⊔x \ y)) :=
        by 
          rw [sup_inf_right]_ = (x⊔x⊓z⊔x \ y)⊓(y \ z⊔(x⊓z⊔x \ y)) :=
        by 
          acRfl _ = x⊓(y \ z⊔x⊓z⊔x \ y) :=
        by 
          rw [sup_inf_self, sup_sdiff_left, ←sup_assoc]_ = x⊓(y \ z⊓(z⊔y)⊔x⊓(z⊔y)⊔x \ y) :=
        by 
          rw [sup_inf_left, sup_sdiff_self_left, inf_sup_right, @sup_comm _ _ y]_ = x⊓(y \ z⊔(x⊓z⊔x⊓y)⊔x \ y) :=
        by 
          rw [inf_sdiff_sup_right, @inf_sup_left _ _ x z y]_ = x⊓(y \ z⊔(x⊓z⊔(x⊓y⊔x \ y))) :=
        by 
          acRfl _ = x⊓(y \ z⊔(x⊔x⊓z)) :=
        by 
          rw [sup_inf_sdiff, @sup_comm _ _ (x⊓z)]_ = x :=
        by 
          rw [sup_inf_self, sup_comm, inf_sup_self]
    ·
      calc x⊓(y \ z)⊓(z⊓x⊔x \ y) = x⊓(y \ z)⊓(z⊓x)⊔x⊓(y \ z)⊓(x \ y) :=
        by 
          rw [inf_sup_left]_ = x⊓(y \ z⊓z⊓x)⊔x⊓(y \ z)⊓(x \ y) :=
        by 
          acRfl _ = x⊓(y \ z)⊓(x \ y) :=
        by 
          rw [inf_sdiff_self_left, bot_inf_eq, inf_bot_eq, bot_sup_eq]_ = x⊓(y \ z⊓y)⊓(x \ y) :=
        by 
          convLHS => rw [←inf_sdiff_left]_ = x⊓(y \ z⊓(y⊓(x \ y))) :=
        by 
          acRfl _ = ⊥ :=
        by 
          rw [inf_sdiff_self_right, inf_bot_eq, inf_bot_eq]

theorem sdiff_sdiff_right' : x \ (y \ z) = x \ y⊔x⊓z :=
  calc x \ (y \ z) = x \ y⊔x⊓y⊓z := sdiff_sdiff_right 
    _ = z⊓x⊓y⊔x \ y :=
    by 
      acRfl 
    _ = x \ y⊔x⊓z :=
    by 
      rw [sup_inf_inf_sdiff, sup_comm, inf_comm]
    

@[simp]
theorem sdiff_sdiff_right_self : x \ (x \ y) = x⊓y :=
  by 
    rw [sdiff_sdiff_right, inf_idem, sdiff_self, bot_sup_eq]

theorem sdiff_sdiff_eq_self (h : y ≤ x) : x \ (x \ y) = y :=
  by 
    rw [sdiff_sdiff_right_self, inf_of_le_right h]

theorem sdiff_sdiff_left : x \ y \ z = x \ (y⊔z) :=
  by 
    rw [sdiff_sup]
    apply sdiff_unique
    ·
      rw [←inf_sup_left, sup_sdiff_self_right, inf_sdiff_sup_right]
    ·
      rw [inf_assoc, @inf_comm _ _ z, inf_assoc, inf_sdiff_self_left, inf_bot_eq, inf_bot_eq]

theorem sdiff_sdiff_left' : x \ y \ z = x \ y⊓(x \ z) :=
  by 
    rw [sdiff_sdiff_left, sdiff_sup]

theorem sdiff_sdiff_comm : x \ y \ z = x \ z \ y :=
  by 
    rw [sdiff_sdiff_left, sup_comm, sdiff_sdiff_left]

@[simp]
theorem sdiff_idem : x \ y \ y = x \ y :=
  by 
    rw [sdiff_sdiff_left, sup_idem]

@[simp]
theorem sdiff_sdiff_self : x \ y \ x = ⊥ :=
  by 
    rw [sdiff_sdiff_comm, sdiff_self, bot_sdiff]

theorem sdiff_sdiff_sup_sdiff : z \ (x \ y⊔y \ x) = z⊓(z \ x⊔y)⊓(z \ y⊔x) :=
  calc z \ (x \ y⊔y \ x) = (z \ x⊔z⊓x⊓y)⊓(z \ y⊔z⊓y⊓x) :=
    by 
      rw [sdiff_sup, sdiff_sdiff_right, sdiff_sdiff_right]
    _ = z⊓(z \ x⊔y)⊓(z \ y⊔z⊓y⊓x) :=
    by 
      rw [sup_inf_left, sup_comm, sup_inf_sdiff]
    _ = z⊓(z \ x⊔y)⊓(z⊓(z \ y⊔x)) :=
    by 
      rw [sup_inf_left, @sup_comm _ _ (z \ y), sup_inf_sdiff]
    _ = z⊓z⊓(z \ x⊔y)⊓(z \ y⊔x) :=
    by 
      acRfl 
    _ = z⊓(z \ x⊔y)⊓(z \ y⊔x) :=
    by 
      rw [inf_idem]
    

theorem sdiff_sdiff_sup_sdiff' : z \ (x \ y⊔y \ x) = z⊓x⊓y⊔z \ x⊓(z \ y) :=
  calc z \ (x \ y⊔y \ x) = z \ (x \ y)⊓(z \ (y \ x)) := sdiff_sup 
    _ = (z \ x⊔z⊓x⊓y)⊓(z \ y⊔z⊓y⊓x) :=
    by 
      rw [sdiff_sdiff_right, sdiff_sdiff_right]
    _ = (z \ x⊔z⊓y⊓x)⊓(z \ y⊔z⊓y⊓x) :=
    by 
      acRfl 
    _ = z \ x⊓(z \ y)⊔z⊓y⊓x := sup_inf_right.symm 
    _ = z⊓x⊓y⊔z \ x⊓(z \ y) :=
    by 
      acRfl
    

theorem sup_sdiff : (x⊔y) \ z = x \ z⊔y \ z :=
  sdiff_unique
    (calc (x⊔y)⊓z⊔(x \ z⊔y \ z) = x⊓z⊔y⊓z⊔(x \ z⊔y \ z) :=
      by 
        rw [inf_sup_right]
      _ = x⊓z⊔x \ z⊔y \ z⊔y⊓z :=
      by 
        acRfl 
      _ = x⊔(y⊓z⊔y \ z) :=
      by 
        rw [sup_inf_sdiff, sup_assoc, @sup_comm _ _ (y \ z)]
      _ = x⊔y :=
      by 
        rw [sup_inf_sdiff]
      )
    (calc (x⊔y)⊓z⊓(x \ z⊔y \ z) = (x⊓z⊔y⊓z)⊓(x \ z⊔y \ z) :=
      by 
        rw [inf_sup_right]
      _ = (x⊓z⊔y⊓z)⊓(x \ z)⊔(x⊓z⊔y⊓z)⊓(y \ z) :=
      by 
        rw [@inf_sup_left _ _ (x⊓z⊔y⊓z)]
      _ = y⊓z⊓(x \ z)⊔(x⊓z⊔y⊓z)⊓(y \ z) :=
      by 
        rw [inf_sup_right, inf_inf_sdiff, bot_sup_eq]
      _ = (x⊓z⊔y⊓z)⊓(y \ z) :=
      by 
        rw [inf_assoc, inf_sdiff_self_right, inf_bot_eq, bot_sup_eq]
      _ = x⊓z⊓(y \ z) :=
      by 
        rw [inf_sup_right, inf_inf_sdiff, sup_bot_eq]
      _ = ⊥ :=
      by 
        rw [inf_assoc, inf_sdiff_self_right, inf_bot_eq]
      )

theorem sup_sdiff_right_self : (x⊔y) \ y = x \ y :=
  by 
    rw [sup_sdiff, sdiff_self, sup_bot_eq]

theorem sup_sdiff_left_self : (x⊔y) \ x = y \ x :=
  by 
    rw [sup_comm, sup_sdiff_right_self]

theorem inf_sdiff : x⊓y \ z = x \ z⊓(y \ z) :=
  sdiff_unique
    (calc x⊓y⊓z⊔x \ z⊓(y \ z) = (x⊓y⊓z⊔x \ z)⊓(x⊓y⊓z⊔y \ z) :=
      by 
        rw [sup_inf_left]
      _ = (x⊓y⊓(z⊔x)⊔x \ z)⊓(x⊓y⊓z⊔y \ z) :=
      by 
        rw [sup_inf_right, sup_sdiff_self_right, inf_sup_right, inf_sdiff_sup_right]
      _ = (y⊓(x⊓(x⊔z))⊔x \ z)⊓(x⊓y⊓z⊔y \ z) :=
      by 
        acRfl 
      _ = (y⊓x⊔x \ z)⊓(x⊓y⊔y \ z) :=
      by 
        rw [inf_sup_self, sup_inf_inf_sdiff]
      _ = x⊓y⊔x \ z⊓(y \ z) :=
      by 
        rw [@inf_comm _ _ y, sup_inf_left]
      _ = x⊓y := sup_eq_left.2 (inf_le_inf sdiff_le sdiff_le)
      )
    (calc x⊓y⊓z⊓(x \ z⊓(y \ z)) = x⊓y⊓(z⊓(x \ z))⊓(y \ z) :=
      by 
        acRfl 
      _ = ⊥ :=
      by 
        rw [inf_sdiff_self_right, inf_bot_eq, bot_inf_eq]
      )

theorem inf_sdiff_assoc : x⊓y \ z = x⊓(y \ z) :=
  sdiff_unique
    (calc x⊓y⊓z⊔x⊓(y \ z) = x⊓(y⊓z)⊔x⊓(y \ z) :=
      by 
        rw [inf_assoc]
      _ = x⊓(y⊓z⊔y \ z) := inf_sup_left.symm 
      _ = x⊓y :=
      by 
        rw [sup_inf_sdiff]
      )
    (calc x⊓y⊓z⊓(x⊓(y \ z)) = x⊓x⊓(y⊓z⊓(y \ z)) :=
      by 
        acRfl 
      _ = ⊥ :=
      by 
        rw [inf_inf_sdiff, inf_bot_eq]
      )

theorem sup_eq_sdiff_sup_sdiff_sup_inf : x⊔y = x \ y⊔y \ x⊔x⊓y :=
  Eq.symm$
    calc x \ y⊔y \ x⊔x⊓y = (x \ y⊔y \ x⊔x)⊓(x \ y⊔y \ x⊔y) :=
      by 
        rw [sup_inf_left]
      _ = (x \ y⊔x⊔y \ x)⊓(x \ y⊔(y \ x⊔y)) :=
      by 
        acRfl 
      _ = (x⊔y \ x)⊓(x \ y⊔y) :=
      by 
        rw [sup_sdiff_right, sup_sdiff_right]
      _ = x⊔y :=
      by 
        rw [sup_sdiff_self_right, sup_sdiff_self_left, inf_idem]
      

theorem sdiff_le_sdiff_of_sup_le_sup_left (h : z⊔x ≤ z⊔y) : x \ z ≤ y \ z :=
  by 
    rw [←sup_sdiff_left_self, ←@sup_sdiff_left_self _ _ y]
    exact sdiff_le_sdiff_right h

theorem sdiff_le_sdiff_of_sup_le_sup_right (h : x⊔z ≤ y⊔z) : x \ z ≤ y \ z :=
  by 
    rw [←sup_sdiff_right_self, ←@sup_sdiff_right_self _ y]
    exact sdiff_le_sdiff_right h

theorem sup_lt_of_lt_sdiff_left (h : y < z \ x) (hxz : x ≤ z) : x⊔y < z :=
  by 
    rw [←sup_sdiff_cancel_right hxz]
    refine' (sup_le_sup_left h.le _).lt_of_not_le fun h' => h.not_le _ 
    rw [←sdiff_idem]
    exact (sdiff_le_sdiff_of_sup_le_sup_left h').trans sdiff_le

theorem sup_lt_of_lt_sdiff_right (h : x < z \ y) (hyz : y ≤ z) : x⊔y < z :=
  by 
    rw [←sdiff_sup_cancel hyz]
    refine' (sup_le_sup_right h.le _).lt_of_not_le fun h' => h.not_le _ 
    rw [←sdiff_idem]
    exact (sdiff_le_sdiff_of_sup_le_sup_right h').trans sdiff_le

instance Pi.generalizedBooleanAlgebra {α : Type u} {β : Type v} [GeneralizedBooleanAlgebra β] :
  GeneralizedBooleanAlgebra (α → β) :=
  by 
    piInstance.1

end GeneralizedBooleanAlgebra

/-!
### Boolean algebras
-/


/-- Set / lattice complement -/
@[notationClass]
class HasCompl(α : Type _) where 
  Compl : α → α

export HasCompl(Compl)

-- error in Order.BooleanAlgebra: ././Mathport/Syntax/Translate/Basic.lean:265:9: unsupported: advanced prec syntax
postfix `ᶜ`:«expr + »(max, 1) := compl

/-- This class contains the core axioms of a Boolean algebra. The `boolean_algebra` class extends
both this class and `generalized_boolean_algebra`, see Note [forgetful inheritance].

Since `bounded_order`, `order_bot`, and `order_top` are mixins that require `has_le`
to be present at define-time, the `extends` mechanism does not work with them.
Instead, we extend using the underlying `has_bot` and `has_top` data typeclasses, and replicate the
order axioms of those classes here. A "forgetful" instance back to `bounded_order` is provided.
-/
class BooleanAlgebra.Core(α : Type u) extends DistribLattice α, HasCompl α, HasTop α, HasBot α where 
  inf_compl_le_bot : ∀ (x : α), x⊓«expr ᶜ» x ≤ ⊥
  top_le_sup_compl : ∀ (x : α), ⊤ ≤ x⊔«expr ᶜ» x 
  le_top : ∀ (a : α), a ≤ ⊤
  bot_le : ∀ (a : α), ⊥ ≤ a

instance (priority := 100)BooleanAlgebra.Core.toBoundedOrder [h : BooleanAlgebra.Core α] : BoundedOrder α :=
  { h with  }

section BooleanAlgebraCore

variable[BooleanAlgebra.Core α]

@[simp]
theorem inf_compl_eq_bot : x⊓«expr ᶜ» x = ⊥ :=
  bot_unique$ BooleanAlgebra.Core.inf_compl_le_bot x

@[simp]
theorem compl_inf_eq_bot : «expr ᶜ» x⊓x = ⊥ :=
  Eq.trans inf_comm inf_compl_eq_bot

@[simp]
theorem sup_compl_eq_top : x⊔«expr ᶜ» x = ⊤ :=
  top_unique$ BooleanAlgebra.Core.top_le_sup_compl x

@[simp]
theorem compl_sup_eq_top : «expr ᶜ» x⊔x = ⊤ :=
  Eq.trans sup_comm sup_compl_eq_top

theorem is_compl_compl : IsCompl x («expr ᶜ» x) :=
  IsCompl.of_eq inf_compl_eq_bot sup_compl_eq_top

theorem IsCompl.eq_compl (h : IsCompl x y) : x = «expr ᶜ» y :=
  h.left_unique is_compl_compl.symm

theorem IsCompl.compl_eq (h : IsCompl x y) : «expr ᶜ» x = y :=
  (h.right_unique is_compl_compl).symm

theorem eq_compl_iff_is_compl : x = «expr ᶜ» y ↔ IsCompl x y :=
  ⟨fun h =>
      by 
        rw [h]
        exact is_compl_compl.symm,
    IsCompl.eq_compl⟩

theorem compl_eq_iff_is_compl : «expr ᶜ» x = y ↔ IsCompl x y :=
  ⟨fun h =>
      by 
        rw [←h]
        exact is_compl_compl,
    IsCompl.compl_eq⟩

theorem disjoint_compl_right : Disjoint x («expr ᶜ» x) :=
  is_compl_compl.Disjoint

theorem disjoint_compl_left : Disjoint («expr ᶜ» x) x :=
  disjoint_compl_right.symm

theorem compl_unique (i : x⊓y = ⊥) (s : x⊔y = ⊤) : «expr ᶜ» x = y :=
  (IsCompl.of_eq i s).compl_eq

@[simp]
theorem compl_top : «expr ᶜ» ⊤ = (⊥ : α) :=
  is_compl_top_bot.compl_eq

@[simp]
theorem compl_bot : «expr ᶜ» ⊥ = (⊤ : α) :=
  is_compl_bot_top.compl_eq

@[simp]
theorem compl_compl (x : α) : «expr ᶜ» («expr ᶜ» x) = x :=
  is_compl_compl.symm.compl_eq

@[simp]
theorem compl_involutive : Function.Involutive (compl : α → α) :=
  compl_compl

theorem compl_bijective : Function.Bijective (compl : α → α) :=
  compl_involutive.Bijective

theorem compl_surjective : Function.Surjective (compl : α → α) :=
  compl_involutive.Surjective

theorem compl_injective : Function.Injective (compl : α → α) :=
  compl_involutive.Injective

@[simp]
theorem compl_inj_iff : «expr ᶜ» x = «expr ᶜ» y ↔ x = y :=
  compl_injective.eq_iff

theorem IsCompl.compl_eq_iff (h : IsCompl x y) : «expr ᶜ» z = y ↔ z = x :=
  h.compl_eq ▸ compl_inj_iff

@[simp]
theorem compl_eq_top : «expr ᶜ» x = ⊤ ↔ x = ⊥ :=
  is_compl_bot_top.compl_eq_iff

@[simp]
theorem compl_eq_bot : «expr ᶜ» x = ⊥ ↔ x = ⊤ :=
  is_compl_top_bot.compl_eq_iff

@[simp]
theorem compl_inf : «expr ᶜ» (x⊓y) = «expr ᶜ» x⊔«expr ᶜ» y :=
  (is_compl_compl.inf_sup is_compl_compl).compl_eq

@[simp]
theorem compl_sup : «expr ᶜ» (x⊔y) = «expr ᶜ» x⊓«expr ᶜ» y :=
  (is_compl_compl.sup_inf is_compl_compl).compl_eq

theorem compl_le_compl (h : y ≤ x) : «expr ᶜ» x ≤ «expr ᶜ» y :=
  is_compl_compl.Antitone is_compl_compl h

-- error in Order.BooleanAlgebra: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp] theorem compl_le_compl_iff_le : «expr ↔ »(«expr ≤ »(«expr ᶜ»(y), «expr ᶜ»(x)), «expr ≤ »(x, y)) :=
⟨assume
 h, by have [ident h] [] [":=", expr compl_le_compl h]; simp [] [] [] [] [] ["at", ident h]; assumption, compl_le_compl⟩

theorem le_compl_of_le_compl (h : y ≤ «expr ᶜ» x) : x ≤ «expr ᶜ» y :=
  by 
    simpa only [compl_compl] using compl_le_compl h

theorem compl_le_of_compl_le (h : «expr ᶜ» y ≤ x) : «expr ᶜ» x ≤ y :=
  by 
    simpa only [compl_compl] using compl_le_compl h

theorem le_compl_iff_le_compl : y ≤ «expr ᶜ» x ↔ x ≤ «expr ᶜ» y :=
  ⟨le_compl_of_le_compl, le_compl_of_le_compl⟩

theorem compl_le_iff_compl_le : «expr ᶜ» x ≤ y ↔ «expr ᶜ» y ≤ x :=
  ⟨compl_le_of_compl_le, compl_le_of_compl_le⟩

namespace BooleanAlgebra

instance (priority := 100) : IsComplemented α :=
  ⟨fun x => ⟨«expr ᶜ» x, is_compl_compl⟩⟩

end BooleanAlgebra

end BooleanAlgebraCore

/-- A Boolean algebra is a bounded distributive lattice with
a complement operator `ᶜ` such that `x ⊓ xᶜ = ⊥` and `x ⊔ xᶜ = ⊤`.
For convenience, it must also provide a set difference operation `\`
satisfying `x \ y = x ⊓ yᶜ`.

This is a generalization of (classical) logic of propositions, or
the powerset lattice. -/
class BooleanAlgebra(α : Type u) extends GeneralizedBooleanAlgebra α, BooleanAlgebra.Core α where 
  sdiff_eq : ∀ (x y : α), x \ y = x⊓«expr ᶜ» y

section OfCore

/-- Create a `has_sdiff` instance from a `boolean_algebra.core` instance, defining `x \ y` to
be `x ⊓ yᶜ`.

For some types, it may be more convenient to create the `boolean_algebra` instance by hand in order
to have a simpler `sdiff` operation.

See note [reducible non-instances]. -/
@[reducible]
def BooleanAlgebra.Core.sdiff [BooleanAlgebra.Core α] : HasSdiff α :=
  ⟨fun x y => x⊓«expr ᶜ» y⟩

attribute [local instance] BooleanAlgebra.Core.sdiff

theorem BooleanAlgebra.Core.sdiff_eq [BooleanAlgebra.Core α] (a b : α) : a \ b = a⊓«expr ᶜ» b :=
  rfl

/-- Create a `boolean_algebra` instance from a `boolean_algebra.core` instance, defining `x \ y` to
be `x ⊓ yᶜ`.

For some types, it may be more convenient to create the `boolean_algebra` instance by hand in order
to have a simpler `sdiff` operation. -/
def BooleanAlgebra.ofCore (B : BooleanAlgebra.Core α) : BooleanAlgebra α :=
  { B with sdiff := fun x y => x⊓«expr ᶜ» y, sdiff_eq := fun _ _ => rfl,
    sup_inf_sdiff :=
      fun a b =>
        by 
          rw [←inf_sup_left, sup_compl_eq_top, inf_top_eq],
    inf_inf_sdiff :=
      fun a b =>
        by 
          rw [inf_left_right_swap, BooleanAlgebra.Core.sdiff_eq, @inf_assoc _ _ _ _ b, compl_inf_eq_bot, inf_bot_eq,
            bot_inf_eq]
          congr }

end OfCore

section BooleanAlgebra

variable[BooleanAlgebra α]

theorem sdiff_eq : x \ y = x⊓«expr ᶜ» y :=
  BooleanAlgebra.sdiff_eq x y

theorem sdiff_compl : x \ «expr ᶜ» y = x⊓y :=
  by 
    rw [sdiff_eq, compl_compl]

theorem top_sdiff : ⊤ \ x = «expr ᶜ» x :=
  by 
    rw [sdiff_eq, top_inf_eq]

@[simp]
theorem sdiff_top : x \ ⊤ = ⊥ :=
  by 
    rw [sdiff_eq, compl_top, inf_bot_eq]

@[simp]
theorem sup_inf_inf_compl : x⊓y⊔x⊓«expr ᶜ» y = x :=
  by 
    rw [←sdiff_eq, sup_inf_sdiff _ _]

end BooleanAlgebra

instance Prop.booleanAlgebra : BooleanAlgebra Prop :=
  BooleanAlgebra.ofCore
    { Prop.distribLattice, Prop.boundedOrder with Compl := Not, inf_compl_le_bot := fun p ⟨Hp, Hpc⟩ => Hpc Hp,
      top_le_sup_compl := fun p H => Classical.em p }

instance Pi.hasSdiff {ι : Type u} {α : ι → Type v} [∀ i, HasSdiff (α i)] : HasSdiff (∀ i, α i) :=
  ⟨fun x y i => x i \ y i⟩

theorem Pi.sdiff_def {ι : Type u} {α : ι → Type v} [∀ i, HasSdiff (α i)] (x y : ∀ i, α i) :
  x \ y = fun i => x i \ y i :=
  rfl

@[simp]
theorem Pi.sdiff_apply {ι : Type u} {α : ι → Type v} [∀ i, HasSdiff (α i)] (x y : ∀ i, α i) (i : ι) :
  (x \ y) i = x i \ y i :=
  rfl

instance Pi.hasCompl {ι : Type u} {α : ι → Type v} [∀ i, HasCompl (α i)] : HasCompl (∀ i, α i) :=
  ⟨fun x i => «expr ᶜ» (x i)⟩

theorem Pi.compl_def {ι : Type u} {α : ι → Type v} [∀ i, HasCompl (α i)] (x : ∀ i, α i) :
  «expr ᶜ» x = fun i => «expr ᶜ» (x i) :=
  rfl

@[simp]
theorem Pi.compl_apply {ι : Type u} {α : ι → Type v} [∀ i, HasCompl (α i)] (x : ∀ i, α i) (i : ι) :
  («expr ᶜ» x) i = «expr ᶜ» (x i) :=
  rfl

instance Pi.booleanAlgebra {ι : Type u} {α : ι → Type v} [∀ i, BooleanAlgebra (α i)] : BooleanAlgebra (∀ i, α i) :=
  { Pi.hasSdiff, Pi.hasCompl, Pi.boundedOrder, Pi.distribLattice with sdiff_eq := fun x y => funext$ fun i => sdiff_eq,
    sup_inf_sdiff := fun x y => funext$ fun i => sup_inf_sdiff (x i) (y i),
    inf_inf_sdiff := fun x y => funext$ fun i => inf_inf_sdiff (x i) (y i),
    inf_compl_le_bot := fun _ _ => BooleanAlgebra.inf_compl_le_bot _,
    top_le_sup_compl := fun _ _ => BooleanAlgebra.top_le_sup_compl _ }

