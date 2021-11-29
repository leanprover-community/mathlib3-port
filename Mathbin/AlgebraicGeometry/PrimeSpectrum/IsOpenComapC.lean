import Mathbin.AlgebraicGeometry.PrimeSpectrum.Basic 
import Mathbin.RingTheory.Polynomial.Basic

/-!
The morphism `Spec R[x] --> Spec R` induced by the natural inclusion `R --> R[x]` is an open map.

The main result is the first part of the statement of Lemma 00FB in the Stacks Project.

https://stacks.math.columbia.edu/tag/00FB
-/


open Ideal Polynomial PrimeSpectrum Set

namespace AlgebraicGeometry

namespace Polynomial

variable{R : Type _}[CommRingₓ R]{f : Polynomial R}

/-- Given a polynomial `f ∈ R[x]`, `image_of_Df` is the subset of `Spec R` where at least one
of the coefficients of `f` does not vanish.  Lemma `image_of_Df_eq_comap_C_compl_zero_locus`
proves that `image_of_Df` is the image of `(zero_locus {f})ᶜ` under the morphism
`comap C : Spec R[x] → Spec R`. -/
def image_of_Df f : Set (PrimeSpectrum R) :=
  { p:PrimeSpectrum R | ∃ i : ℕ, coeff f i ∉ p.as_ideal }

-- error in AlgebraicGeometry.PrimeSpectrum.IsOpenComapC: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem is_open_image_of_Df : is_open (image_of_Df f) :=
begin
  rw ["[", expr image_of_Df, ",", expr set_of_exists (λ
    (i)
    (x : prime_spectrum R), «expr ∉ »(coeff f i, x.val)), "]"] [],
  exact [expr is_open_Union (λ i, is_open_basic_open)]
end

/-- If a point of `Spec R[x]` is not contained in the vanishing set of `f`, then its image in
`Spec R` is contained in the open set where at least one of the coefficients of `f` is non-zero.
This lemma is a reformulation of `exists_coeff_not_mem_C_inverse`. -/
theorem comap_C_mem_image_of_Df {I : PrimeSpectrum (Polynomial R)}
  (H : I ∈ «expr ᶜ» (zero_locus {f} : Set (PrimeSpectrum (Polynomial R)))) :
  PrimeSpectrum.comap (Polynomial.c : R →+* Polynomial R) I ∈ image_of_Df f :=
  exists_coeff_not_mem_C_inverse (mem_compl_zero_locus_iff_not_mem.mp H)

/-- The open set `image_of_Df f` coincides with the image of `basic_open f` under the
morphism `C⁺ : Spec R[x] → Spec R`. -/
theorem image_of_Df_eq_comap_C_compl_zero_locus :
  image_of_Df f = PrimeSpectrum.comap (C : R →+* Polynomial R) '' «expr ᶜ» (zero_locus {f}) :=
  by 
    refine' ext fun x => ⟨fun hx => ⟨⟨map C x.val, is_prime_map_C_of_is_prime x.property⟩, ⟨_, _⟩⟩, _⟩
    ·
      rw [mem_compl_eq, mem_zero_locus, singleton_subset_iff]
      cases' hx with i hi 
      exact fun a => hi (mem_map_C_iff.mp a i)
    ·
      refine' Subtype.ext (ext fun x => ⟨fun h => _, fun h => subset_span (mem_image_of_mem C.1 h)⟩)
      rw [←@coeff_C_zero R x _]
      exact mem_map_C_iff.mp h 0
    ·
      rintro ⟨xli, complement, rfl⟩
      exact comap_C_mem_image_of_Df complement

/--  The morphism `C⁺ : Spec R[x] → Spec R` is open.
Stacks Project "Lemma 00FB", first part.

https://stacks.math.columbia.edu/tag/00FB
-/
theorem is_open_map_comap_C : IsOpenMap (PrimeSpectrum.comap (C : R →+* Polynomial R)) :=
  by 
    rintro U ⟨s, z⟩
    rw [←compl_compl U, ←z, ←Union_of_singleton_coe s, zero_locus_Union, compl_Inter, image_Union]
    simpRw [←image_of_Df_eq_comap_C_compl_zero_locus]
    exact is_open_Union fun f => is_open_image_of_Df

end Polynomial

end AlgebraicGeometry

