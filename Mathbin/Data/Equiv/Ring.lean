import Mathbin.Data.Equiv.MulAdd 
import Mathbin.Algebra.Field.Basic 
import Mathbin.Algebra.Opposites 
import Mathbin.Algebra.BigOperators.Basic

/-!
# (Semi)ring equivs

In this file we define extension of `equiv` called `ring_equiv`, which is a datatype representing an
isomorphism of `semiring`s, `ring`s, `division_ring`s, or `field`s. We also introduce the
corresponding group of automorphisms `ring_aut`.

## Notations

* ``infix ` ≃+* `:25 := ring_equiv``

The extended equiv have coercions to functions, and the coercion is the canonical notation when
treating the isomorphism as maps.

## Implementation notes

The fields for `ring_equiv` now avoid the unbundled `is_mul_hom` and `is_add_hom`, as these are
deprecated.

Definition of multiplication in the groups of automorphisms agrees with function composition,
multiplication in `equiv.perm`, and multiplication in `category_theory.End`, not with
`category_theory.comp`.

## Tags

equiv, mul_equiv, add_equiv, ring_equiv, mul_aut, add_aut, ring_aut
-/


open_locale BigOperators

variable{R : Type _}{S : Type _}{S' : Type _}

/-- An equivalence between two (semi)rings that preserves the algebraic structure. -/
structure RingEquiv(R S : Type _)[Mul R][Add R][Mul S][Add S] extends R ≃ S, R ≃* S, R ≃+ S

infixl:25 " ≃+* " => RingEquiv

/-- The "plain" equivalence of types underlying an equivalence of (semi)rings. -/
add_decl_doc RingEquiv.toEquiv

/-- The equivalence of additive monoids underlying an equivalence of (semi)rings. -/
add_decl_doc RingEquiv.toAddEquiv

/-- The equivalence of multiplicative monoids underlying an equivalence of (semi)rings. -/
add_decl_doc RingEquiv.toMulEquiv

namespace RingEquiv

section Basic

variable[Mul R][Add R][Mul S][Add S][Mul S'][Add S']

instance  : CoeFun (R ≃+* S) fun _ => R → S :=
  ⟨RingEquiv.toFun⟩

@[simp]
theorem to_fun_eq_coe (f : R ≃+* S) : f.to_fun = f :=
  rfl

/-- A ring isomorphism preserves multiplication. -/
@[simp]
theorem map_mul (e : R ≃+* S) (x y : R) : e (x*y) = e x*e y :=
  e.map_mul' x y

/-- A ring isomorphism preserves addition. -/
@[simp]
theorem map_add (e : R ≃+* S) (x y : R) : e (x+y) = e x+e y :=
  e.map_add' x y

-- error in Data.Equiv.Ring: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Two ring isomorphisms agree if they are defined by the
    same underlying function. -/
@[ext #[]]
theorem ext {f g : «expr ≃+* »(R, S)} (h : ∀ x, «expr = »(f x, g x)) : «expr = »(f, g) :=
begin
  have [ident h₁] [":", expr «expr = »(f.to_equiv, g.to_equiv)] [":=", expr equiv.ext h],
  cases [expr f] [],
  cases [expr g] [],
  congr,
  { exact [expr funext h] },
  { exact [expr congr_arg equiv.inv_fun h₁] }
end

@[simp]
theorem coe_mk e e' h₁ h₂ h₃ h₄ : «expr⇑ » (⟨e, e', h₁, h₂, h₃, h₄⟩ : R ≃+* S) = e :=
  rfl

@[simp]
theorem mk_coe (e : R ≃+* S) e' h₁ h₂ h₃ h₄ : (⟨e, e', h₁, h₂, h₃, h₄⟩ : R ≃+* S) = e :=
  ext$ fun _ => rfl

protected theorem congr_argₓ {f : R ≃+* S} : ∀ {x x' : R}, x = x' → f x = f x'
| _, _, rfl => rfl

protected theorem congr_funₓ {f g : R ≃+* S} (h : f = g) (x : R) : f x = g x :=
  h ▸ rfl

theorem ext_iff {f g : R ≃+* S} : f = g ↔ ∀ x, f x = g x :=
  ⟨fun h x => h ▸ rfl, ext⟩

instance has_coe_to_mul_equiv : Coe (R ≃+* S) (R ≃* S) :=
  ⟨RingEquiv.toMulEquiv⟩

instance has_coe_to_add_equiv : Coe (R ≃+* S) (R ≃+ S) :=
  ⟨RingEquiv.toAddEquiv⟩

@[simp]
theorem to_add_equiv_eq_coe (f : R ≃+* S) : f.to_add_equiv = «expr↑ » f :=
  rfl

@[simp]
theorem to_mul_equiv_eq_coe (f : R ≃+* S) : f.to_mul_equiv = «expr↑ » f :=
  rfl

@[simp, normCast]
theorem coe_to_mul_equiv (f : R ≃+* S) : «expr⇑ » (f : R ≃* S) = f :=
  rfl

@[simp, normCast]
theorem coe_to_add_equiv (f : R ≃+* S) : «expr⇑ » (f : R ≃+ S) = f :=
  rfl

/-- The `ring_equiv` between two semirings with a unique element. -/
def ring_equiv_of_unique_of_unique {M N} [Unique M] [Unique N] [Add M] [Mul M] [Add N] [Mul N] : M ≃+* N :=
  { AddEquiv.addEquivOfUniqueOfUnique, MulEquiv.mulEquivOfUniqueOfUnique with  }

instance  {M N} [Unique M] [Unique N] [Add M] [Mul M] [Add N] [Mul N] : Unique (M ≃+* N) :=
  { default := ring_equiv_of_unique_of_unique, uniq := fun _ => ext$ fun x => Subsingleton.elimₓ _ _ }

variable(R)

/-- The identity map is a ring isomorphism. -/
@[refl]
protected def refl : R ≃+* R :=
  { MulEquiv.refl R, AddEquiv.refl R with  }

@[simp]
theorem refl_apply (x : R) : RingEquiv.refl R x = x :=
  rfl

@[simp]
theorem coe_add_equiv_refl : (RingEquiv.refl R : R ≃+ R) = AddEquiv.refl R :=
  rfl

@[simp]
theorem coe_mul_equiv_refl : (RingEquiv.refl R : R ≃* R) = MulEquiv.refl R :=
  rfl

instance  : Inhabited (R ≃+* R) :=
  ⟨RingEquiv.refl R⟩

variable{R}

/-- The inverse of a ring isomorphism is a ring isomorphism. -/
@[symm]
protected def symm (e : R ≃+* S) : S ≃+* R :=
  { e.to_mul_equiv.symm, e.to_add_equiv.symm with  }

/-- See Note [custom simps projection] -/
def simps.symm_apply (e : R ≃+* S) : S → R :=
  e.symm

initialize_simps_projections RingEquiv (toFun → apply, invFun → symmApply)

@[simp]
theorem symm_symm (e : R ≃+* S) : e.symm.symm = e :=
  ext$ fun x => rfl

theorem symm_bijective : Function.Bijective (RingEquiv.symm : R ≃+* S → S ≃+* R) :=
  Equiv.bijective ⟨RingEquiv.symm, RingEquiv.symm, symm_symm, symm_symm⟩

@[simp]
theorem mk_coe' (e : R ≃+* S) f h₁ h₂ h₃ h₄ : (RingEquiv.mk f («expr⇑ » e) h₁ h₂ h₃ h₄ : S ≃+* R) = e.symm :=
  symm_bijective.Injective$ ext$ fun x => rfl

@[simp]
theorem symm_mk (f : R → S) g h₁ h₂ h₃ h₄ :
  (mk f g h₁ h₂ h₃ h₄).symm = { (mk f g h₁ h₂ h₃ h₄).symm with toFun := g, invFun := f } :=
  rfl

/-- Transitivity of `ring_equiv`. -/
@[trans]
protected def trans (e₁ : R ≃+* S) (e₂ : S ≃+* S') : R ≃+* S' :=
  { e₁.to_mul_equiv.trans e₂.to_mul_equiv, e₁.to_add_equiv.trans e₂.to_add_equiv with  }

@[simp]
theorem trans_apply (e₁ : R ≃+* S) (e₂ : S ≃+* S') (a : R) : e₁.trans e₂ a = e₂ (e₁ a) :=
  rfl

protected theorem bijective (e : R ≃+* S) : Function.Bijective e :=
  e.to_equiv.bijective

protected theorem injective (e : R ≃+* S) : Function.Injective e :=
  e.to_equiv.injective

protected theorem surjective (e : R ≃+* S) : Function.Surjective e :=
  e.to_equiv.surjective

@[simp]
theorem apply_symm_apply (e : R ≃+* S) : ∀ x, e (e.symm x) = x :=
  e.to_equiv.apply_symm_apply

@[simp]
theorem symm_apply_apply (e : R ≃+* S) : ∀ x, e.symm (e x) = x :=
  e.to_equiv.symm_apply_apply

theorem image_eq_preimage (e : R ≃+* S) (s : Set R) : e '' s = e.symm ⁻¹' s :=
  e.to_equiv.image_eq_preimage s

end Basic

section Opposite

open MulOpposite

/-- A ring iso `α ≃+* β` can equivalently be viewed as a ring iso `αᵐᵒᵖ ≃+* βᵐᵒᵖ`. -/
@[simps]
protected def op {α β} [Add α] [Mul α] [Add β] [Mul β] : α ≃+* β ≃ («expr ᵐᵒᵖ» α ≃+* «expr ᵐᵒᵖ» β) :=
  { toFun := fun f => { f.to_add_equiv.op, f.to_mul_equiv.op with  },
    invFun := fun f => { AddEquiv.op.symm f.to_add_equiv, MulEquiv.op.symm f.to_mul_equiv with  },
    left_inv :=
      fun f =>
        by 
          ext 
          rfl,
    right_inv :=
      fun f =>
        by 
          ext 
          rfl }

/-- The 'unopposite' of a ring iso `αᵐᵒᵖ ≃+* βᵐᵒᵖ`. Inverse to `ring_equiv.op`. -/
@[simp]
protected def unop {α β} [Add α] [Mul α] [Add β] [Mul β] : «expr ᵐᵒᵖ» α ≃+* «expr ᵐᵒᵖ» β ≃ (α ≃+* β) :=
  RingEquiv.op.symm

section CommSemiringₓ

variable(R)[CommSemiringₓ R]

/-- A commutative ring is isomorphic to its opposite. -/
def to_opposite : R ≃+* «expr ᵐᵒᵖ» R :=
  { MulOpposite.opEquiv with map_add' := fun x y => rfl, map_mul' := fun x y => mul_commₓ (op y) (op x) }

@[simp]
theorem to_opposite_apply (r : R) : to_opposite R r = op r :=
  rfl

@[simp]
theorem to_opposite_symm_apply (r : «expr ᵐᵒᵖ» R) : (to_opposite R).symm r = unop r :=
  rfl

end CommSemiringₓ

end Opposite

section NonUnitalSemiring

variable[NonUnitalNonAssocSemiring R][NonUnitalNonAssocSemiring S](f : R ≃+* S)(x y : R)

/-- A ring isomorphism sends zero to zero. -/
@[simp]
theorem map_zero : f 0 = 0 :=
  (f : R ≃+ S).map_zero

variable{x}

@[simp]
theorem map_eq_zero_iff : f x = 0 ↔ x = 0 :=
  (f : R ≃+ S).map_eq_zero_iff

theorem map_ne_zero_iff : f x ≠ 0 ↔ x ≠ 0 :=
  (f : R ≃+ S).map_ne_zero_iff

end NonUnitalSemiring

section Semiringₓ

variable[NonAssocSemiring R][NonAssocSemiring S](f : R ≃+* S)(x y : R)

/-- A ring isomorphism sends one to one. -/
@[simp]
theorem map_one : f 1 = 1 :=
  (f : R ≃* S).map_one

variable{x}

@[simp]
theorem map_eq_one_iff : f x = 1 ↔ x = 1 :=
  (f : R ≃* S).map_eq_one_iff

theorem map_ne_one_iff : f x ≠ 1 ↔ x ≠ 1 :=
  (f : R ≃* S).map_ne_one_iff

/-- Produce a ring isomorphism from a bijective ring homomorphism. -/
noncomputable def of_bijective (f : R →+* S) (hf : Function.Bijective f) : R ≃+* S :=
  { Equiv.ofBijective f hf, f with  }

@[simp]
theorem coe_of_bijective (f : R →+* S) (hf : Function.Bijective f) : (of_bijective f hf : R → S) = f :=
  rfl

theorem of_bijective_apply (f : R →+* S) (hf : Function.Bijective f) (x : R) : of_bijective f hf x = f x :=
  rfl

end Semiringₓ

section 

variable[Ringₓ R][Ringₓ S](f : R ≃+* S)(x y : R)

@[simp]
theorem map_neg : f (-x) = -f x :=
  (f : R ≃+ S).map_neg x

@[simp]
theorem map_sub : f (x - y) = f x - f y :=
  (f : R ≃+ S).map_sub x y

@[simp]
theorem map_neg_one : f (-1) = -1 :=
  f.map_one ▸ f.map_neg 1

end 

section SemiringHom

variable[NonAssocSemiring R][NonAssocSemiring S][NonAssocSemiring S']

/-- Reinterpret a ring equivalence as a ring homomorphism. -/
def to_ring_hom (e : R ≃+* S) : R →+* S :=
  { e.to_mul_equiv.to_monoid_hom, e.to_add_equiv.to_add_monoid_hom with  }

theorem to_ring_hom_injective : Function.Injective (to_ring_hom : R ≃+* S → R →+* S) :=
  fun f g h => RingEquiv.ext (RingHom.ext_iff.1 h)

instance has_coe_to_ring_hom : Coe (R ≃+* S) (R →+* S) :=
  ⟨RingEquiv.toRingHom⟩

theorem to_ring_hom_eq_coe (f : R ≃+* S) : f.to_ring_hom = «expr↑ » f :=
  rfl

@[simp, normCast]
theorem coe_to_ring_hom (f : R ≃+* S) : «expr⇑ » (f : R →+* S) = f :=
  rfl

theorem coe_ring_hom_inj_iff {R S : Type _} [NonAssocSemiring R] [NonAssocSemiring S] (f g : R ≃+* S) :
  f = g ↔ (f : R →+* S) = g :=
  ⟨congr_argₓ _, fun h => ext$ RingHom.ext_iff.mp h⟩

/-- Reinterpret a ring equivalence as a monoid homomorphism. -/
abbrev to_monoid_hom (e : R ≃+* S) : R →* S :=
  e.to_ring_hom.to_monoid_hom

/-- Reinterpret a ring equivalence as an `add_monoid` homomorphism. -/
abbrev to_add_monoid_hom (e : R ≃+* S) : R →+ S :=
  e.to_ring_hom.to_add_monoid_hom

/-- The two paths coercion can take to an `add_monoid_hom` are equivalent -/
theorem to_add_monoid_hom_commutes (f : R ≃+* S) : (f : R →+* S).toAddMonoidHom = (f : R ≃+ S).toAddMonoidHom :=
  rfl

/-- The two paths coercion can take to an `monoid_hom` are equivalent -/
theorem to_monoid_hom_commutes (f : R ≃+* S) : (f : R →+* S).toMonoidHom = (f : R ≃* S).toMonoidHom :=
  rfl

/-- The two paths coercion can take to an `equiv` are equivalent -/
theorem to_equiv_commutes (f : R ≃+* S) : (f : R ≃+ S).toEquiv = (f : R ≃* S).toEquiv :=
  rfl

@[simp]
theorem to_ring_hom_refl : (RingEquiv.refl R).toRingHom = RingHom.id R :=
  rfl

@[simp]
theorem to_monoid_hom_refl : (RingEquiv.refl R).toMonoidHom = MonoidHom.id R :=
  rfl

@[simp]
theorem to_add_monoid_hom_refl : (RingEquiv.refl R).toAddMonoidHom = AddMonoidHom.id R :=
  rfl

@[simp]
theorem to_ring_hom_apply_symm_to_ring_hom_apply (e : R ≃+* S) : ∀ (y : S), e.to_ring_hom (e.symm.to_ring_hom y) = y :=
  e.to_equiv.apply_symm_apply

@[simp]
theorem symm_to_ring_hom_apply_to_ring_hom_apply (e : R ≃+* S) : ∀ (x : R), e.symm.to_ring_hom (e.to_ring_hom x) = x :=
  Equiv.symm_apply_apply e.to_equiv

@[simp]
theorem to_ring_hom_trans (e₁ : R ≃+* S) (e₂ : S ≃+* S') :
  (e₁.trans e₂).toRingHom = e₂.to_ring_hom.comp e₁.to_ring_hom :=
  rfl

@[simp]
theorem to_ring_hom_comp_symm_to_ring_hom (e : R ≃+* S) : e.to_ring_hom.comp e.symm.to_ring_hom = RingHom.id _ :=
  by 
    ext 
    simp 

@[simp]
theorem symm_to_ring_hom_comp_to_ring_hom (e : R ≃+* S) : e.symm.to_ring_hom.comp e.to_ring_hom = RingHom.id _ :=
  by 
    ext 
    simp 

/--
Construct an equivalence of rings from homomorphisms in both directions, which are inverses.
-/
def of_hom_inv (hom : R →+* S) (inv : S →+* R) (hom_inv_id : inv.comp hom = RingHom.id R)
  (inv_hom_id : hom.comp inv = RingHom.id S) : R ≃+* S :=
  { hom with invFun := inv, left_inv := fun x => RingHom.congr_fun hom_inv_id x,
    right_inv := fun x => RingHom.congr_fun inv_hom_id x }

@[simp]
theorem of_hom_inv_apply (hom : R →+* S) (inv : S →+* R) hom_inv_id inv_hom_id (r : R) :
  (of_hom_inv hom inv hom_inv_id inv_hom_id) r = hom r :=
  rfl

@[simp]
theorem of_hom_inv_symm_apply (hom : R →+* S) (inv : S →+* R) hom_inv_id inv_hom_id (s : S) :
  (of_hom_inv hom inv hom_inv_id inv_hom_id).symm s = inv s :=
  rfl

end SemiringHom

section BigOperators

theorem map_list_prod [Semiringₓ R] [Semiringₓ S] (f : R ≃+* S) (l : List R) : f l.prod = (l.map f).Prod :=
  f.to_ring_hom.map_list_prod l

theorem map_list_sum [NonAssocSemiring R] [NonAssocSemiring S] (f : R ≃+* S) (l : List R) : f l.sum = (l.map f).Sum :=
  f.to_ring_hom.map_list_sum l

/-- An isomorphism into the opposite ring acts on the product by acting on the reversed elements -/
theorem unop_map_list_prod [Semiringₓ R] [Semiringₓ S] (f : R ≃+* «expr ᵐᵒᵖ» S) (l : List R) :
  MulOpposite.unop (f l.prod) = (l.map (MulOpposite.unop ∘ f)).reverse.Prod :=
  f.to_ring_hom.unop_map_list_prod l

theorem map_multiset_prod [CommSemiringₓ R] [CommSemiringₓ S] (f : R ≃+* S) (s : Multiset R) :
  f s.prod = (s.map f).Prod :=
  f.to_ring_hom.map_multiset_prod s

theorem map_multiset_sum [NonAssocSemiring R] [NonAssocSemiring S] (f : R ≃+* S) (s : Multiset R) :
  f s.sum = (s.map f).Sum :=
  f.to_ring_hom.map_multiset_sum s

theorem map_prod {α : Type _} [CommSemiringₓ R] [CommSemiringₓ S] (g : R ≃+* S) (f : α → R) (s : Finset α) :
  g (∏x in s, f x) = ∏x in s, g (f x) :=
  g.to_ring_hom.map_prod f s

theorem map_sum {α : Type _} [NonAssocSemiring R] [NonAssocSemiring S] (g : R ≃+* S) (f : α → R) (s : Finset α) :
  g (∑x in s, f x) = ∑x in s, g (f x) :=
  g.to_ring_hom.map_sum f s

end BigOperators

section DivisionRing

variable{K K' : Type _}[DivisionRing K][DivisionRing K'](g : K ≃+* K')(x y : K)

theorem map_inv : g (x⁻¹) = g x⁻¹ :=
  g.to_ring_hom.map_inv x

theorem map_div : g (x / y) = g x / g y :=
  g.to_ring_hom.map_div x y

end DivisionRing

section GroupPower

variable[Semiringₓ R][Semiringₓ S]

@[simp]
theorem map_pow (f : R ≃+* S) a : ∀ (n : ℕ), f (a ^ n) = f a ^ n :=
  f.to_ring_hom.map_pow a

end GroupPower

end RingEquiv

namespace MulEquiv

/-- Gives a `ring_equiv` from a `mul_equiv` preserving addition.-/
def to_ring_equiv {R : Type _} {S : Type _} [Add R] [Add S] [Mul R] [Mul S] (h : R ≃* S)
  (H : ∀ (x y : R), h (x+y) = h x+h y) : R ≃+* S :=
  { h.to_equiv, h, AddEquiv.mk' h.to_equiv H with  }

end MulEquiv

namespace RingEquiv

variable[Add R][Add S][Mul R][Mul S]

@[simp]
theorem self_trans_symm (e : R ≃+* S) : e.trans e.symm = RingEquiv.refl R :=
  ext e.3

@[simp]
theorem symm_trans_self (e : R ≃+* S) : e.symm.trans e = RingEquiv.refl S :=
  ext e.4

/-- If two rings are isomorphic, and the second is a domain, then so is the first. -/
protected theorem IsDomain {A : Type _} (B : Type _) [Ringₓ A] [Ringₓ B] [IsDomain B] (e : A ≃+* B) : IsDomain A :=
  { eq_zero_or_eq_zero_of_mul_eq_zero :=
      fun x y hxy =>
        have  : (e x*e y) = 0 :=
          by 
            rw [←e.map_mul, hxy, e.map_zero]
        by 
          simpa using eq_zero_or_eq_zero_of_mul_eq_zero this,
    exists_pair_ne := ⟨e.symm 0, e.symm 1, e.symm.injective.ne zero_ne_one⟩ }

end RingEquiv

