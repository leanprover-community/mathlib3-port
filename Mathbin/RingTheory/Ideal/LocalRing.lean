import Mathbin.Algebra.Algebra.Basic 
import Mathbin.Algebra.Category.CommRing.Basic 
import Mathbin.RingTheory.Ideal.Operations

/-!

# Local rings

Define local rings as commutative rings having a unique maximal ideal.

## Main definitions

* `local_ring`: A predicate on commutative rings, stating that every element `a` is either a unit
  or `1 - a` is a unit. This is shown to be equivalent to the condition that there exists a unique
  maximal ideal.
* `local_ring.maximal_ideal`: The unique maximal ideal for a local rings. Its carrier set is the set
  of non units.
* `is_local_ring_hom`: A predicate on semiring homomorphisms, requiring that it maps nonunits
  to nonunits. For local rings, this means that the image of the unique maximal ideal is again
  contained in the unique maximal ideal.
* `local_ring.residue_field`: The quotient of a local ring by its maximal ideal.

-/


universe u v w

/-- A commutative ring is local if it has a unique maximal ideal. Note that
  `local_ring` is a predicate. -/
class LocalRing(R : Type u)[CommRingₓ R] extends Nontrivial R : Prop where 
  is_local : ∀ (a : R), IsUnit a ∨ IsUnit (1 - a)

namespace LocalRing

variable{R : Type u}[CommRingₓ R][LocalRing R]

theorem is_unit_or_is_unit_one_sub_self (a : R) : IsUnit a ∨ IsUnit (1 - a) :=
  is_local a

theorem is_unit_of_mem_nonunits_one_sub_self (a : R) (h : 1 - a ∈ Nonunits R) : IsUnit a :=
  or_iff_not_imp_right.1 (is_local a) h

theorem is_unit_one_sub_self_of_mem_nonunits (a : R) (h : a ∈ Nonunits R) : IsUnit (1 - a) :=
  or_iff_not_imp_left.1 (is_local a) h

theorem nonunits_add {x y} (hx : x ∈ Nonunits R) (hy : y ∈ Nonunits R) : (x+y) ∈ Nonunits R :=
  by 
    rintro ⟨u, hu⟩
    apply hy 
    suffices  : IsUnit ((«expr↑ » (u⁻¹) : R)*y)
    ·
      rcases this with ⟨s, hs⟩
      use u*s 
      convert congr_argₓ (fun z => (u : R)*z) hs 
      rw [←mul_assocₓ]
      simp 
    rw
      [show («expr↑ » (u⁻¹)*y) = 1 - «expr↑ » (u⁻¹)*x by 
        rw [eq_sub_iff_add_eq]
        replace hu := congr_argₓ (fun z => («expr↑ » (u⁻¹) : R)*z) hu.symm 
        simpa [mul_addₓ, add_commₓ] using hu]
    apply is_unit_one_sub_self_of_mem_nonunits 
    exact mul_mem_nonunits_right hx

variable(R)

/-- The ideal of elements that are not units. -/
def maximal_ideal : Ideal R :=
  { Carrier := Nonunits R, zero_mem' := zero_mem_nonunits.2$ zero_ne_one,
    add_mem' := fun x y hx hy => nonunits_add hx hy, smul_mem' := fun a x => mul_mem_nonunits_right }

instance maximal_ideal.is_maximal : (maximal_ideal R).IsMaximal :=
  by 
    rw [Ideal.is_maximal_iff]
    split 
    ·
      intro h 
      apply h 
      exact is_unit_one
    ·
      intro I x hI hx H 
      erw [not_not] at hx 
      rcases hx with ⟨u, rfl⟩
      simpa using I.mul_mem_left («expr↑ » (u⁻¹)) H

theorem maximal_ideal_unique : ∃!I : Ideal R, I.is_maximal :=
  ⟨maximal_ideal R, maximal_ideal.is_maximal R,
    fun I hI => hI.eq_of_le (maximal_ideal.is_maximal R).1.1$ fun x hx => hI.1.1 ∘ I.eq_top_of_is_unit_mem hx⟩

variable{R}

theorem eq_maximal_ideal {I : Ideal R} (hI : I.is_maximal) : I = maximal_ideal R :=
  unique_of_exists_unique (maximal_ideal_unique R) hI$ maximal_ideal.is_maximal R

theorem le_maximal_ideal {J : Ideal R} (hJ : J ≠ ⊤) : J ≤ maximal_ideal R :=
  by 
    rcases Ideal.exists_le_maximal J hJ with ⟨M, hM1, hM2⟩
    rwa [←eq_maximal_ideal hM1]

@[simp]
theorem mem_maximal_ideal x : x ∈ maximal_ideal R ↔ x ∈ Nonunits R :=
  Iff.rfl

end LocalRing

variable{R : Type u}{S : Type v}{T : Type w}

theorem local_of_nonunits_ideal [CommRingₓ R] (hnze : (0 : R) ≠ 1)
  (h : ∀ x y (_ : x ∈ Nonunits R) (_ : y ∈ Nonunits R), (x+y) ∈ Nonunits R) : LocalRing R :=
  { exists_pair_ne := ⟨0, 1, hnze⟩,
    is_local :=
      fun x =>
        or_iff_not_imp_left.mpr$
          fun hx =>
            by 
              byContra H 
              apply h _ _ hx H 
              simp [-sub_eq_add_neg, add_sub_cancel'_right] }

-- error in RingTheory.Ideal.LocalRing: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem local_of_unique_max_ideal [comm_ring R] (h : «expr∃! , »((I : ideal R), I.is_maximal)) : local_ring R :=
«expr $ »(local_of_nonunits_ideal (let ⟨I, Imax, _⟩ := h in
  λ
  H : «expr = »(0, 1), «expr $ »(Imax.1.1, «expr $ »(I.eq_top_iff_one.2, «expr ▸ »(H, I.zero_mem)))), λ
 x y hx hy H, let ⟨I, Imax, Iuniq⟩ := h in
 let ⟨Ix, Ixmax, Hx⟩ := exists_max_ideal_of_mem_nonunits hx in
 let ⟨Iy, Iymax, Hy⟩ := exists_max_ideal_of_mem_nonunits hy in
 have xmemI : «expr ∈ »(x, I), from «expr ▸ »(Iuniq Ix Ixmax, Hx),
 have ymemI : «expr ∈ »(y, I), from «expr ▸ »(Iuniq Iy Iymax, Hy),
 «expr $ »(Imax.1.1, I.eq_top_of_is_unit_mem (I.add_mem xmemI ymemI) H))

theorem local_of_unique_nonzero_prime (R : Type u) [CommRingₓ R] (h : ∃!P : Ideal R, P ≠ ⊥ ∧ Ideal.IsPrime P) :
  LocalRing R :=
  local_of_unique_max_ideal
    (by 
      rcases h with ⟨P, ⟨hPnonzero, hPnot_top, _⟩, hPunique⟩
      refine' ⟨P, ⟨⟨hPnot_top, _⟩⟩, fun M hM => hPunique _ ⟨_, Ideal.IsMaximal.is_prime hM⟩⟩
      ·
        refine' Ideal.maximal_of_no_maximal fun M hPM hM => ne_of_ltₓ hPM _ 
        exact (hPunique _ ⟨ne_bot_of_gt hPM, Ideal.IsMaximal.is_prime hM⟩).symm
      ·
        rintro rfl 
        exact hPnot_top (hM.1.2 P (bot_lt_iff_ne_bot.2 hPnonzero)))

theorem local_of_surjective [CommRingₓ R] [LocalRing R] [CommRingₓ S] [Nontrivial S] (f : R →+* S)
  (hf : Function.Surjective f) : LocalRing S :=
  { ‹Nontrivial S› with
    is_local :=
      by 
        intro b 
        obtain ⟨a, rfl⟩ := hf b 
        apply (LocalRing.is_unit_or_is_unit_one_sub_self a).imp f.is_unit_map _ 
        rw [←f.map_one, ←f.map_sub]
        apply f.is_unit_map }

/-- A local ring homomorphism is a homomorphism between local rings
  such that the image of the maximal ideal of the source is contained within
  the maximal ideal of the target. -/
class IsLocalRingHom[Semiringₓ R][Semiringₓ S](f : R →+* S) : Prop where 
  map_nonunit : ∀ a, IsUnit (f a) → IsUnit a

instance is_local_ring_hom_id (R : Type _) [Semiringₓ R] : IsLocalRingHom (RingHom.id R) :=
  { map_nonunit := fun a => id }

@[simp]
theorem is_unit_map_iff [Semiringₓ R] [Semiringₓ S] (f : R →+* S) [IsLocalRingHom f] a : IsUnit (f a) ↔ IsUnit a :=
  ⟨IsLocalRingHom.map_nonunit a, f.is_unit_map⟩

instance is_local_ring_hom_comp [Semiringₓ R] [Semiringₓ S] [Semiringₓ T] (g : S →+* T) (f : R →+* S) [IsLocalRingHom g]
  [IsLocalRingHom f] : IsLocalRingHom (g.comp f) :=
  { map_nonunit := fun a => IsLocalRingHom.map_nonunit a ∘ IsLocalRingHom.map_nonunit (f a) }

instance is_local_ring_hom_equiv [Semiringₓ R] [Semiringₓ S] (f : R ≃+* S) : IsLocalRingHom f.to_ring_hom :=
  { map_nonunit :=
      fun a ha =>
        by 
          convert f.symm.to_ring_hom.is_unit_map ha 
          rw [RingEquiv.symm_to_ring_hom_apply_to_ring_hom_apply] }

@[simp]
theorem is_unit_of_map_unit [Semiringₓ R] [Semiringₓ S] (f : R →+* S) [IsLocalRingHom f] a (h : IsUnit (f a)) :
  IsUnit a :=
  IsLocalRingHom.map_nonunit a h

theorem of_irreducible_map [Semiringₓ R] [Semiringₓ S] (f : R →+* S) [h : IsLocalRingHom f] {x : R}
  (hfx : Irreducible (f x)) : Irreducible x :=
  ⟨fun h => hfx.not_unit$ IsUnit.map f.to_monoid_hom h,
    fun p q hx =>
      let ⟨H⟩ := h 
      Or.imp (H p) (H q)$ hfx.is_unit_or_is_unit$ f.map_mul p q ▸ congr_argₓ f hx⟩

section 

open CategoryTheory

theorem is_local_ring_hom_of_iso {R S : CommRingₓₓ} (f : R ≅ S) : IsLocalRingHom f.hom :=
  { map_nonunit :=
      fun a ha =>
        by 
          convert f.inv.is_unit_map ha 
          rw [CategoryTheory.coe_hom_inv_id] }

instance (priority := 100)is_local_ring_hom_of_is_iso {R S : CommRingₓₓ} (f : R ⟶ S) [is_iso f] : IsLocalRingHom f :=
  is_local_ring_hom_of_iso (as_iso f)

end 

section 

open LocalRing

variable[CommRingₓ R][LocalRing R][CommRingₓ S][LocalRing S]

variable(f : R →+* S)[IsLocalRingHom f]

theorem map_nonunit (a : R) (h : a ∈ maximal_ideal R) : f a ∈ maximal_ideal S :=
  fun H => h$ is_unit_of_map_unit f a H

end 

namespace LocalRing

variable[CommRingₓ R][LocalRing R][CommRingₓ S][LocalRing S]

/--
A ring homomorphism between local rings is a local ring hom iff it reflects units,
i.e. any preimage of a unit is still a unit. https://stacks.math.columbia.edu/tag/07BJ
-/
theorem local_hom_tfae (f : R →+* S) :
  tfae
    [IsLocalRingHom f, f '' (maximal_ideal R).1 ⊆ maximal_ideal S, (maximal_ideal R).map f ≤ maximal_ideal S,
      maximal_ideal R ≤ (maximal_ideal S).comap f, (maximal_ideal S).comap f = maximal_ideal R] :=
  by 
    tfaeHave 1 → 2
    rintro _ _ ⟨a, ha, rfl⟩
    skip 
    exact map_nonunit f a ha 
    tfaeHave 2 → 4 
    exact Set.image_subset_iff.1
    tfaeHave 3 ↔ 4 
    exact Ideal.map_le_iff_le_comap 
    tfaeHave 4 → 1
    intro h 
    fsplit 
    exact fun x => not_imp_not.1 (@h x)
    tfaeHave 1 → 5
    intro 
    skip 
    ext 
    exact not_iff_not.2 (is_unit_map_iff f x)
    tfaeHave 5 → 4 
    exact fun h => le_of_eqₓ h.symm 
    tfaeFinish

variable(R)

/-- The residue field of a local ring is the quotient of the ring by its maximal ideal. -/
def residue_field :=
  (maximal_ideal R).Quotient

noncomputable instance residue_field.field : Field (residue_field R) :=
  Ideal.Quotient.field (maximal_ideal R)

noncomputable instance  : Inhabited (residue_field R) :=
  ⟨37⟩

/-- The quotient map from a local ring to its residue field. -/
def residue : R →+* residue_field R :=
  Ideal.Quotient.mk _

noncomputable instance residue_field.algebra : Algebra R (residue_field R) :=
  (residue R).toAlgebra

namespace ResidueField

variable{R S}

/-- The map on residue fields induced by a local homomorphism between local rings -/
noncomputable def map (f : R →+* S) [IsLocalRingHom f] : residue_field R →+* residue_field S :=
  Ideal.Quotient.lift (maximal_ideal R) ((Ideal.Quotient.mk _).comp f)$
    fun a ha =>
      by 
        erw [Ideal.Quotient.eq_zero_iff_mem]
        exact map_nonunit f a ha

end ResidueField

variable{R}

theorem ker_eq_maximal_ideal {K : Type _} [Field K] (φ : R →+* K) (hφ : Function.Surjective φ) :
  φ.ker = maximal_ideal R :=
  LocalRing.eq_maximal_ideal$ φ.ker_is_maximal_of_surjective hφ

end LocalRing

namespace Field

variable[Field R]

open_locale Classical

instance (priority := 100) : LocalRing R :=
  { is_local :=
      fun a =>
        if h : a = 0 then
          Or.inr
            (by 
              rw [h, sub_zero] <;> exact is_unit_one)
        else Or.inl$ IsUnit.mk0 a h }

end Field

