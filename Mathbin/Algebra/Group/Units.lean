import Mathbin.Algebra.Group.Basic 
import Mathbin.Logic.Nontrivial

/-!
# Units (i.e., invertible elements) of a multiplicative monoid
-/


universe u

variable{α : Type u}

/-- Units of a monoid, bundled version. An element of a `monoid` is a unit if it has a two-sided
inverse. This version bundles the inverse element so that it can be computed. For a predicate
see `is_unit`. -/
structure Units(α : Type u)[Monoidₓ α] where 
  val : α 
  inv : α 
  val_inv : (val*inv) = 1
  inv_val : (inv*val) = 1

/-- Units of an add_monoid, bundled version. An element of an add_monoid is a unit if it has a
    two-sided additive inverse. This version bundles the inverse element so that it can be
    computed. For a predicate see `is_add_unit`. -/
structure AddUnits(α : Type u)[AddMonoidₓ α] where 
  val : α 
  neg : α 
  val_neg : (val+neg) = 0
  neg_val : (neg+val) = 0

attribute [toAdditive AddUnits] Units

section HasElem

@[toAdditive]
theorem unique_has_one {α : Type _} [Unique α] [HasOne α] : default α = 1 :=
  Unique.default_eq 1

end HasElem

namespace Units

variable[Monoidₓ α]

@[toAdditive]
instance  : Coe (Units α) α :=
  ⟨val⟩

@[toAdditive]
instance  : HasInv (Units α) :=
  ⟨fun u => ⟨u.2, u.1, u.4, u.3⟩⟩

/-- See Note [custom simps projection] -/
@[toAdditive " See Note [custom simps projection] "]
def simps.coe (u : Units α) : α :=
  u

/-- See Note [custom simps projection] -/
@[toAdditive " See Note [custom simps projection] "]
def simps.coe_inv (u : Units α) : α :=
  «expr↑ » (u⁻¹)

initialize_simps_projections Units (val → coe as_prefix, inv → coeInv as_prefix)

initialize_simps_projections AddUnits (val → coe as_prefix, neg → coeNeg as_prefix)

@[simp, toAdditive]
theorem coe_mk (a : α) b h₁ h₂ : «expr↑ » (Units.mk a b h₁ h₂) = a :=
  rfl

@[ext, toAdditive]
theorem ext : Function.Injective (coeₓ : Units α → α)
| ⟨v, i₁, vi₁, iv₁⟩, ⟨v', i₂, vi₂, iv₂⟩, e =>
  by 
    change v = v' at e <;> subst v' <;> congr <;> simpa only [iv₂, vi₁, one_mulₓ, mul_oneₓ] using mul_assocₓ i₂ v i₁

@[normCast, toAdditive]
theorem eq_iff {a b : Units α} : (a : α) = b ↔ a = b :=
  ext.eq_iff

@[toAdditive]
theorem ext_iff {a b : Units α} : a = b ↔ (a : α) = b :=
  eq_iff.symm

@[toAdditive]
instance  [DecidableEq α] : DecidableEq (Units α) :=
  fun a b => decidableOfIff' _ ext_iff

@[simp, toAdditive]
theorem mk_coe (u : Units α) y h₁ h₂ : mk (u : α) y h₁ h₂ = u :=
  ext rfl

/-- Copy a unit, adjusting definition equalities. -/
@[toAdditive "Copy an `add_unit`, adjusting definitional equalities.", simps]
def copy (u : Units α) (val : α) (hv : val = u) (inv : α) (hi : inv = «expr↑ » (u⁻¹)) : Units α :=
  { val, inv, inv_val := hv.symm ▸ hi.symm ▸ u.inv_val, val_inv := hv.symm ▸ hi.symm ▸ u.val_inv }

@[toAdditive]
theorem copy_eq (u : Units α) val hv inv hi : u.copy val hv inv hi = u :=
  ext hv

/-- Units of a monoid form a group. -/
@[toAdditive]
instance  : Groupₓ (Units α) :=
  { mul :=
      fun u₁ u₂ =>
        ⟨u₁.val*u₂.val, u₂.inv*u₁.inv,
          by 
            rw [mul_assocₓ, ←mul_assocₓ u₂.val, val_inv, one_mulₓ, val_inv],
          by 
            rw [mul_assocₓ, ←mul_assocₓ u₁.inv, inv_val, one_mulₓ, inv_val]⟩,
    one := ⟨1, 1, one_mulₓ 1, one_mulₓ 1⟩, mul_one := fun u => ext$ mul_oneₓ u, one_mul := fun u => ext$ one_mulₓ u,
    mul_assoc := fun u₁ u₂ u₃ => ext$ mul_assocₓ u₁ u₂ u₃, inv := HasInv.inv, mul_left_inv := fun u => ext u.inv_val }

variable(a b : Units α){c : Units α}

@[simp, normCast, toAdditive]
theorem coe_mul : («expr↑ » (a*b) : α) = a*b :=
  rfl

@[simp, normCast, toAdditive]
theorem coe_one : ((1 : Units α) : α) = 1 :=
  rfl

@[simp, normCast, toAdditive]
theorem coe_eq_one {a : Units α} : (a : α) = 1 ↔ a = 1 :=
  by 
    rw [←Units.coe_one, eq_iff]

@[simp, toAdditive]
theorem inv_mk (x y : α) h₁ h₂ : mk x y h₁ h₂⁻¹ = mk y x h₂ h₁ :=
  rfl

@[simp, toAdditive]
theorem val_eq_coe : a.val = («expr↑ » a : α) :=
  rfl

@[simp, toAdditive]
theorem inv_eq_coe_inv : a.inv = ((a⁻¹ : Units α) : α) :=
  rfl

@[simp, toAdditive]
theorem inv_mul : («expr↑ » (a⁻¹)*a : α) = 1 :=
  inv_val _

@[simp, toAdditive]
theorem mul_inv : (a*«expr↑ » (a⁻¹) : α) = 1 :=
  val_inv _

@[toAdditive]
theorem inv_mul_of_eq {u : Units α} {a : α} (h : «expr↑ » u = a) : («expr↑ » (u⁻¹)*a) = 1 :=
  by 
    rw [←h, u.inv_mul]

@[toAdditive]
theorem mul_inv_of_eq {u : Units α} {a : α} (h : «expr↑ » u = a) : (a*«expr↑ » (u⁻¹)) = 1 :=
  by 
    rw [←h, u.mul_inv]

@[simp, toAdditive]
theorem mul_inv_cancel_left (a : Units α) (b : α) : ((a : α)*«expr↑ » (a⁻¹)*b) = b :=
  by 
    rw [←mul_assocₓ, mul_inv, one_mulₓ]

@[simp, toAdditive]
theorem inv_mul_cancel_leftₓ (a : Units α) (b : α) : ((«expr↑ » (a⁻¹) : α)*a*b) = b :=
  by 
    rw [←mul_assocₓ, inv_mul, one_mulₓ]

@[simp, toAdditive]
theorem mul_inv_cancel_rightₓ (a : α) (b : Units α) : ((a*b)*«expr↑ » (b⁻¹)) = a :=
  by 
    rw [mul_assocₓ, mul_inv, mul_oneₓ]

@[simp, toAdditive]
theorem inv_mul_cancel_right (a : α) (b : Units α) : ((a*«expr↑ » (b⁻¹))*b) = a :=
  by 
    rw [mul_assocₓ, inv_mul, mul_oneₓ]

@[toAdditive]
instance  : Inhabited (Units α) :=
  ⟨1⟩

@[toAdditive]
instance  {α} [CommMonoidₓ α] : CommGroupₓ (Units α) :=
  { Units.group with mul_comm := fun u₁ u₂ => ext$ mul_commₓ _ _ }

@[toAdditive]
instance  [HasRepr α] : HasRepr (Units α) :=
  ⟨reprₓ ∘ val⟩

@[simp, toAdditive]
theorem mul_right_injₓ (a : Units α) {b c : α} : (((a : α)*b) = a*c) ↔ b = c :=
  ⟨fun h =>
      by 
        simpa only [inv_mul_cancel_leftₓ] using congr_argₓ ((·*·) («expr↑ » (a⁻¹ : Units α))) h,
    congr_argₓ _⟩

@[simp, toAdditive]
theorem mul_left_injₓ (a : Units α) {b c : α} : ((b*a) = c*a) ↔ b = c :=
  ⟨fun h =>
      by 
        simpa only [mul_inv_cancel_rightₓ] using congr_argₓ (·*«expr↑ » (a⁻¹ : Units α)) h,
    congr_argₓ _⟩

@[toAdditive]
theorem eq_mul_inv_iff_mul_eq {a b : α} : (a = b*«expr↑ » (c⁻¹)) ↔ (a*c) = b :=
  ⟨fun h =>
      by 
        rw [h, inv_mul_cancel_right],
    fun h =>
      by 
        rw [←h, mul_inv_cancel_rightₓ]⟩

@[toAdditive]
theorem eq_inv_mul_iff_mul_eq {a c : α} : (a = «expr↑ » (b⁻¹)*c) ↔ («expr↑ » b*a) = c :=
  ⟨fun h =>
      by 
        rw [h, mul_inv_cancel_left],
    fun h =>
      by 
        rw [←h, inv_mul_cancel_leftₓ]⟩

@[toAdditive]
theorem inv_mul_eq_iff_eq_mul {b c : α} : («expr↑ » (a⁻¹)*b) = c ↔ b = a*c :=
  ⟨fun h =>
      by 
        rw [←h, mul_inv_cancel_left],
    fun h =>
      by 
        rw [h, inv_mul_cancel_leftₓ]⟩

@[toAdditive]
theorem mul_inv_eq_iff_eq_mul {a c : α} : (a*«expr↑ » (b⁻¹)) = c ↔ a = c*b :=
  ⟨fun h =>
      by 
        rw [←h, inv_mul_cancel_right],
    fun h =>
      by 
        rw [h, mul_inv_cancel_rightₓ]⟩

theorem inv_eq_of_mul_eq_oneₓ {u : Units α} {a : α} (h : («expr↑ » u*a) = 1) : «expr↑ » (u⁻¹) = a :=
  calc «expr↑ » (u⁻¹) = «expr↑ » (u⁻¹)*1 :=
    by 
      rw [mul_oneₓ]
    _ = («expr↑ » (u⁻¹)*«expr↑ » u)*a :=
    by 
      rw [←h, ←mul_assocₓ]
    _ = a :=
    by 
      rw [u.inv_mul, one_mulₓ]
    

theorem inv_unique {u₁ u₂ : Units α} (h : («expr↑ » u₁ : α) = «expr↑ » u₂) : («expr↑ » (u₁⁻¹) : α) = «expr↑ » (u₂⁻¹) :=
  inv_eq_of_mul_eq_oneₓ$
    by 
      rw [h, u₂.mul_inv]

end Units

/-- For `a, b` in a `comm_monoid` such that `a * b = 1`, makes a unit out of `a`. -/
@[toAdditive "For `a, b` in an `add_comm_monoid` such that `a + b = 0`, makes an add_unit\nout of `a`."]
def Units.mkOfMulEqOne [CommMonoidₓ α] (a b : α) (hab : (a*b) = 1) : Units α :=
  ⟨a, b, hab, (mul_commₓ b a).trans hab⟩

@[simp, toAdditive]
theorem Units.coe_mk_of_mul_eq_one [CommMonoidₓ α] {a b : α} (h : (a*b) = 1) : (Units.mkOfMulEqOne a b h : α) = a :=
  rfl

section Monoidₓ

variable[Monoidₓ α]{a b c : α}

/-- Partial division. It is defined when the
  second argument is invertible, and unlike the division operator
  in `division_ring` it is not totalized at zero. -/
def divp (a : α) u : α :=
  a*(u⁻¹ : Units α)

infixl:70 " /ₚ " => divp

@[simp]
theorem divp_self (u : Units α) : (u : α) /ₚ u = 1 :=
  Units.mul_inv _

@[simp]
theorem divp_one (a : α) : a /ₚ 1 = a :=
  mul_oneₓ _

theorem divp_assoc (a b : α) (u : Units α) : (a*b) /ₚ u = a*b /ₚ u :=
  mul_assocₓ _ _ _

@[simp]
theorem divp_inv (u : Units α) : a /ₚ u⁻¹ = a*u :=
  rfl

@[simp]
theorem divp_mul_cancel (a : α) (u : Units α) : ((a /ₚ u)*u) = a :=
  (mul_assocₓ _ _ _).trans$
    by 
      rw [Units.inv_mul, mul_oneₓ]

@[simp]
theorem mul_divp_cancel (a : α) (u : Units α) : (a*u) /ₚ u = a :=
  (mul_assocₓ _ _ _).trans$
    by 
      rw [Units.mul_inv, mul_oneₓ]

@[simp]
theorem divp_left_inj (u : Units α) {a b : α} : a /ₚ u = b /ₚ u ↔ a = b :=
  Units.mul_left_inj _

theorem divp_divp_eq_divp_mul (x : α) (u₁ u₂ : Units α) : x /ₚ u₁ /ₚ u₂ = x /ₚ u₂*u₁ :=
  by 
    simp only [divp, mul_inv_rev, Units.coe_mul, mul_assocₓ]

theorem divp_eq_iff_mul_eq {x : α} {u : Units α} {y : α} : x /ₚ u = y ↔ (y*u) = x :=
  u.mul_left_inj.symm.trans$
    by 
      rw [divp_mul_cancel] <;> exact ⟨Eq.symm, Eq.symm⟩

theorem divp_eq_one_iff_eq {a : α} {u : Units α} : a /ₚ u = 1 ↔ a = u :=
  (Units.mul_left_inj u).symm.trans$
    by 
      rw [divp_mul_cancel, one_mulₓ]

@[simp]
theorem one_divp (u : Units α) : 1 /ₚ u = «expr↑ » (u⁻¹) :=
  one_mulₓ _

end Monoidₓ

section CommMonoidₓ

variable[CommMonoidₓ α]

theorem divp_eq_divp_iff {x y : α} {ux uy : Units α} : x /ₚ ux = y /ₚ uy ↔ (x*uy) = y*ux :=
  by 
    rw [divp_eq_iff_mul_eq, mul_commₓ, ←divp_assoc, divp_eq_iff_mul_eq, mul_commₓ y ux]

theorem divp_mul_divp (x y : α) (ux uy : Units α) : ((x /ₚ ux)*y /ₚ uy) = (x*y) /ₚ ux*uy :=
  by 
    rw [←divp_divp_eq_divp_mul, divp_assoc, mul_commₓ x, divp_assoc, mul_commₓ]

end CommMonoidₓ

/-!
# `is_unit` predicate

In this file we define the `is_unit` predicate on a `monoid`, and
prove a few basic properties. For the bundled version see `units`. See
also `prime`, `associated`, and `irreducible` in `algebra/associated`.

-/


section IsUnit

variable{M : Type _}{N : Type _}

/-- An element `a : M` of a monoid is a unit if it has a two-sided inverse.
The actual definition says that `a` is equal to some `u : units M`, where
`units M` is a bundled version of `is_unit`. -/
@[toAdditive IsAddUnit
      "An element `a : M` of an add_monoid is an `add_unit` if it has\na two-sided additive inverse. The actual definition says that `a` is equal to some\n`u : add_units M`, where `add_units M` is a bundled version of `is_add_unit`."]
def IsUnit [Monoidₓ M] (a : M) : Prop :=
  ∃ u : Units M, (u : M) = a

@[nontriviality]
theorem is_unit_of_subsingleton [Monoidₓ M] [Subsingleton M] (a : M) : IsUnit a :=
  ⟨⟨a, a, Subsingleton.elimₓ _ _, Subsingleton.elimₓ _ _⟩, rfl⟩

instance  [Monoidₓ M] [Subsingleton M] : Unique (Units M) :=
  { default := 1, uniq := fun a => Units.coe_eq_one.mp$ Subsingleton.elimₓ (a : M) 1 }

@[simp, toAdditive is_add_unit_add_unit]
protected theorem Units.is_unit [Monoidₓ M] (u : Units M) : IsUnit (u : M) :=
  ⟨u, rfl⟩

@[simp, toAdditive is_add_unit_zero]
theorem is_unit_one [Monoidₓ M] : IsUnit (1 : M) :=
  ⟨1, rfl⟩

@[toAdditive is_add_unit_of_add_eq_zero]
theorem is_unit_of_mul_eq_one [CommMonoidₓ M] (a b : M) (h : (a*b) = 1) : IsUnit a :=
  ⟨Units.mkOfMulEqOne a b h, rfl⟩

@[toAdditive IsAddUnit.exists_neg]
theorem IsUnit.exists_right_inv [Monoidₓ M] {a : M} (h : IsUnit a) : ∃ b, (a*b) = 1 :=
  by 
    rcases h with ⟨⟨a, b, hab, _⟩, rfl⟩
    exact ⟨b, hab⟩

@[toAdditive IsAddUnit.exists_neg']
theorem IsUnit.exists_left_inv [Monoidₓ M] {a : M} (h : IsUnit a) : ∃ b, (b*a) = 1 :=
  by 
    rcases h with ⟨⟨a, b, _, hba⟩, rfl⟩
    exact ⟨b, hba⟩

@[toAdditive is_add_unit_iff_exists_neg]
theorem is_unit_iff_exists_inv [CommMonoidₓ M] {a : M} : IsUnit a ↔ ∃ b, (a*b) = 1 :=
  ⟨fun h => h.exists_right_inv, fun ⟨b, hab⟩ => is_unit_of_mul_eq_one _ b hab⟩

@[toAdditive is_add_unit_iff_exists_neg']
theorem is_unit_iff_exists_inv' [CommMonoidₓ M] {a : M} : IsUnit a ↔ ∃ b, (b*a) = 1 :=
  by 
    simp [is_unit_iff_exists_inv, mul_commₓ]

@[toAdditive]
theorem IsUnit.mul [Monoidₓ M] {x y : M} : IsUnit x → IsUnit y → IsUnit (x*y) :=
  by 
    rintro ⟨x, rfl⟩ ⟨y, rfl⟩
    exact ⟨x*y, Units.coe_mul _ _⟩

/-- Multiplication by a `u : units M` on the right doesn't affect `is_unit`. -/
@[simp,
  toAdditive is_add_unit_add_add_units "Addition of a `u : add_units M` on the right doesn't\naffect `is_add_unit`."]
theorem Units.is_unit_mul_units [Monoidₓ M] (a : M) (u : Units M) : IsUnit (a*u) ↔ IsUnit a :=
  Iff.intro
    (fun ⟨v, hv⟩ =>
      have  : IsUnit ((a*«expr↑ » u)*«expr↑ » (u⁻¹)) :=
        by 
          exists v*u⁻¹ <;> rw [←hv, Units.coe_mul]
      by 
        rwa [mul_assocₓ, Units.mul_inv, mul_oneₓ] at this)
    fun v => v.mul u.is_unit

/-- Multiplication by a `u : units M` on the left doesn't affect `is_unit`. -/
@[simp,
  toAdditive is_add_unit_add_units_add "Addition of a `u : add_units M` on the left doesn't\naffect `is_add_unit`."]
theorem Units.is_unit_units_mul {M : Type _} [Monoidₓ M] (u : Units M) (a : M) : IsUnit («expr↑ » u*a) ↔ IsUnit a :=
  Iff.intro
    (fun ⟨v, hv⟩ =>
      have  : IsUnit («expr↑ » (u⁻¹)*«expr↑ » u*a) :=
        by 
          exists u⁻¹*v <;> rw [←hv, Units.coe_mul]
      by 
        rwa [←mul_assocₓ, Units.inv_mul, one_mulₓ] at this)
    u.is_unit.mul

@[toAdditive is_add_unit_of_add_is_add_unit_left]
theorem is_unit_of_mul_is_unit_left [CommMonoidₓ M] {x y : M} (hu : IsUnit (x*y)) : IsUnit x :=
  let ⟨z, hz⟩ := is_unit_iff_exists_inv.1 hu 
  is_unit_iff_exists_inv.2
    ⟨y*z,
      by 
        rwa [←mul_assocₓ]⟩

@[toAdditive]
theorem is_unit_of_mul_is_unit_right [CommMonoidₓ M] {x y : M} (hu : IsUnit (x*y)) : IsUnit y :=
  @is_unit_of_mul_is_unit_left _ _ y x$
    by 
      rwa [mul_commₓ]

@[simp]
theorem IsUnit.mul_iff [CommMonoidₓ M] {x y : M} : IsUnit (x*y) ↔ IsUnit x ∧ IsUnit y :=
  ⟨fun h => ⟨is_unit_of_mul_is_unit_left h, is_unit_of_mul_is_unit_right h⟩, fun h => IsUnit.mul h.1 h.2⟩

@[toAdditive]
theorem IsUnit.mul_right_inj [Monoidₓ M] {a b c : M} (ha : IsUnit a) : ((a*b) = a*c) ↔ b = c :=
  by 
    cases' ha with a ha <;> rw [←ha, Units.mul_right_inj]

@[toAdditive]
theorem IsUnit.mul_left_inj [Monoidₓ M] {a b c : M} (ha : IsUnit a) : ((b*a) = c*a) ↔ b = c :=
  by 
    cases' ha with a ha <;> rw [←ha, Units.mul_left_inj]

/-- The element of the group of units, corresponding to an element of a monoid which is a unit. -/
noncomputable def IsUnit.unit [Monoidₓ M] {a : M} (h : IsUnit a) : Units M :=
  (Classical.some h).copy a (Classical.some_spec h).symm _ rfl

theorem IsUnit.unit_spec [Monoidₓ M] {a : M} (h : IsUnit a) : «expr↑ » h.unit = a :=
  rfl

theorem IsUnit.coe_inv_mul [Monoidₓ M] {a : M} (h : IsUnit a) : («expr↑ » (h.unit⁻¹)*a) = 1 :=
  Units.mul_inv _

theorem IsUnit.mul_coe_inv [Monoidₓ M] {a : M} (h : IsUnit a) : (a*«expr↑ » (h.unit⁻¹)) = 1 :=
  by 
    convert Units.mul_inv _ 
    simp [h.unit_spec]

end IsUnit

section NoncomputableDefs

variable{M : Type _}

/-- Constructs a `group` structure on a `monoid` consisting only of units. -/
noncomputable def groupOfIsUnit [hM : Monoidₓ M] (h : ∀ (a : M), IsUnit a) : Groupₓ M :=
  { hM with inv := fun a => «expr↑ » ((h a).Unit⁻¹),
    mul_left_inv :=
      fun a =>
        by 
          change («expr↑ » ((h a).Unit⁻¹)*a) = 1
          rw [Units.inv_mul_eq_iff_eq_mul, (h a).unit_spec, mul_oneₓ] }

/-- Constructs a `comm_group` structure on a `comm_monoid` consisting only of units. -/
noncomputable def commGroupOfIsUnit [hM : CommMonoidₓ M] (h : ∀ (a : M), IsUnit a) : CommGroupₓ M :=
  { hM with inv := fun a => «expr↑ » ((h a).Unit⁻¹),
    mul_left_inv :=
      fun a =>
        by 
          change («expr↑ » ((h a).Unit⁻¹)*a) = 1
          rw [Units.inv_mul_eq_iff_eq_mul, (h a).unit_spec, mul_oneₓ] }

end NoncomputableDefs

