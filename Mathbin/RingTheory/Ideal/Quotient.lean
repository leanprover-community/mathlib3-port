import Mathbin.LinearAlgebra.Quotient 
import Mathbin.RingTheory.Ideal.Basic

/-!
# Ideal quotients

This file defines ideal quotients as a special case of submodule quotients and proves some basic
results about these quotients.

See `algebra.ring_quot` for quotients of non-commutative rings.

## Main definitions

 - `ideal.quotient`: the quotient of a commutative ring `R` by an ideal `I : ideal R`

## Main results

 - `ideal.quotient_inf_ring_equiv_pi_quotient`: the **Chinese Remainder Theorem**
-/


universe u v w

namespace Ideal

open Set

open_locale BigOperators

variable{R : Type u}[CommRingₓ R](I : Ideal R){a b : R}

variable{S : Type v}

/-- The quotient `R/I` of a ring `R` by an ideal `I`.

The ideal quotient of `I` is defined to equal the quotient of `I` as an `R`-submodule of `R`.
This definition is marked `reducible` so that typeclass instances can be shared between
`ideal.quotient I` and `submodule.quotient I`.
-/
@[reducible]
def Quotientₓ (I : Ideal R) :=
  I.quotient

namespace Quotientₓ

variable{I}{x y : R}

instance  (I : Ideal R) : HasOne I.quotient :=
  ⟨Submodule.Quotient.mk 1⟩

-- error in RingTheory.Ideal.Quotient: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
instance (I : ideal R) : has_mul I.quotient :=
⟨λ
 a
 b, «expr $ »(quotient.lift_on₂' a b (λ
   a
   b, submodule.quotient.mk «expr * »(a, b)), λ
  a₁
  a₂
  b₁
  b₂
  h₁
  h₂, «expr $ »(quot.sound, begin
     have [ident F] [] [":=", expr I.add_mem (I.mul_mem_left a₂ h₁) (I.mul_mem_right b₁ h₂)],
     have [] [":", expr «expr = »(«expr - »(«expr * »(a₁, a₂), «expr * »(b₁, b₂)), «expr + »(«expr * »(a₂, «expr - »(a₁, b₁)), «expr * »(«expr - »(a₂, b₂), b₁)))] [],
     { rw ["[", expr mul_sub, ",", expr sub_mul, ",", expr sub_add_sub_cancel, ",", expr mul_comm, ",", expr mul_comm b₁, "]"] [] },
     rw ["<-", expr this] ["at", ident F],
     change [expr «expr ∈ »(_, _)] [] [],
     convert [] [expr F] []
   end))⟩

instance  (I : Ideal R) : CommRingₓ I.quotient :=
  { Submodule.Quotient.addCommGroup I with mul := ·*·, one := 1,
    mul_assoc :=
      fun a b c => Quotientₓ.induction_on₃' a b c$ fun a b c => congr_argₓ Submodule.Quotient.mk (mul_assocₓ a b c),
    mul_comm := fun a b => Quotientₓ.induction_on₂' a b$ fun a b => congr_argₓ Submodule.Quotient.mk (mul_commₓ a b),
    one_mul := fun a => Quotientₓ.induction_on' a$ fun a => congr_argₓ Submodule.Quotient.mk (one_mulₓ a),
    mul_one := fun a => Quotientₓ.induction_on' a$ fun a => congr_argₓ Submodule.Quotient.mk (mul_oneₓ a),
    left_distrib :=
      fun a b c => Quotientₓ.induction_on₃' a b c$ fun a b c => congr_argₓ Submodule.Quotient.mk (left_distrib a b c),
    right_distrib :=
      fun a b c => Quotientₓ.induction_on₃' a b c$ fun a b c => congr_argₓ Submodule.Quotient.mk (right_distrib a b c) }

/-- The ring homomorphism from a ring `R` to a quotient ring `R/I`. -/
def mk (I : Ideal R) : R →+* I.quotient :=
  ⟨fun a => Submodule.Quotient.mk a, rfl, fun _ _ => rfl, rfl, fun _ _ => rfl⟩

@[ext]
theorem ring_hom_ext [NonAssocSemiring S] ⦃f g : I.quotient →+* S⦄ (h : f.comp (mk I) = g.comp (mk I)) : f = g :=
  RingHom.ext$ fun x => Quotientₓ.induction_on' x$ (RingHom.congr_fun h : _)

instance  : Inhabited (Quotientₓ I) :=
  ⟨mk I 37⟩

protected theorem Eq : mk I x = mk I y ↔ x - y ∈ I :=
  Submodule.Quotient.eq I

@[simp]
theorem mk_eq_mk (x : R) : (Submodule.Quotient.mk x : Quotientₓ I) = mk I x :=
  rfl

theorem eq_zero_iff_mem {I : Ideal R} : mk I a = 0 ↔ a ∈ I :=
  by 
    conv  => toRHS rw [←sub_zero a] <;> exact Quotientₓ.eq'

theorem zero_eq_one_iff {I : Ideal R} : (0 : I.quotient) = 1 ↔ I = ⊤ :=
  eq_comm.trans$ eq_zero_iff_mem.trans (eq_top_iff_one _).symm

theorem zero_ne_one_iff {I : Ideal R} : (0 : I.quotient) ≠ 1 ↔ I ≠ ⊤ :=
  not_congr zero_eq_one_iff

protected theorem Nontrivial {I : Ideal R} (hI : I ≠ ⊤) : Nontrivial I.quotient :=
  ⟨⟨0, 1, zero_ne_one_iff.2 hI⟩⟩

theorem mk_surjective : Function.Surjective (mk I) :=
  fun y => Quotientₓ.induction_on' y fun x => Exists.introₓ x rfl

/-- If `I` is an ideal of a commutative ring `R`, if `q : R → R/I` is the quotient map, and if
`s ⊆ R` is a subset, then `q⁻¹(q(s)) = ⋃ᵢ(i + s)`, the union running over all `i ∈ I`. -/
theorem quotient_ring_saturate (I : Ideal R) (s : Set R) : mk I ⁻¹' (mk I '' s) = ⋃x : I, (fun y => x.1+y) '' s :=
  by 
    ext x 
    simp only [mem_preimage, mem_image, mem_Union, Ideal.Quotient.eq]
    exact
      ⟨fun ⟨a, a_in, h⟩ =>
          ⟨⟨_, I.neg_mem h⟩, a, a_in,
            by 
              simp ⟩,
        fun ⟨⟨i, hi⟩, a, ha, Eq⟩ =>
          ⟨a, ha,
            by 
              rw [←Eq, sub_add_eq_sub_sub_swap, sub_self, zero_sub] <;> exact I.neg_mem hi⟩⟩

instance  (I : Ideal R) [hI : I.is_prime] : IsDomain I.quotient :=
  { quotient.nontrivial hI.1 with
    eq_zero_or_eq_zero_of_mul_eq_zero :=
      fun a b =>
        Quotientₓ.induction_on₂' a b$
          fun a b hab =>
            (hI.mem_or_mem (eq_zero_iff_mem.1 hab)).elim (Or.inl ∘ eq_zero_iff_mem.2) (Or.inr ∘ eq_zero_iff_mem.2) }

theorem is_domain_iff_prime (I : Ideal R) : IsDomain I.quotient ↔ I.is_prime :=
  ⟨fun ⟨h1, h2⟩ =>
      ⟨zero_ne_one_iff.1$ @zero_ne_one _ _ ⟨h2⟩,
        fun x y h =>
          by 
            simp only [←eq_zero_iff_mem, (mk I).map_mul] at h⊢
            exact h1 h⟩,
    fun h =>
      by 
        skip 
        infer_instance⟩

theorem exists_inv {I : Ideal R} [hI : I.is_maximal] : ∀ {a : I.quotient}, a ≠ 0 → ∃ b : I.quotient, (a*b) = 1 :=
  by 
    rintro ⟨a⟩ h 
    rcases hI.exists_inv (mt eq_zero_iff_mem.2 h) with ⟨b, c, hc, abc⟩
    rw [mul_commₓ] at abc 
    refine' ⟨mk _ b, Quot.sound _⟩
    rw [←eq_sub_iff_add_eq'] at abc 
    rw [abc, ←neg_mem_iff, neg_sub] at hc 
    convert hc

open_locale Classical

-- error in RingTheory.Ideal.Quotient: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- quotient by maximal ideal is a field. def rather than instance, since users will have
computable inverses in some applications.
See note [reducible non-instances]. -/
@[reducible]
protected
noncomputable
def field (I : ideal R) [hI : I.is_maximal] : field I.quotient :=
{ inv := λ a, if ha : «expr = »(a, 0) then 0 else classical.some (exists_inv ha),
  mul_inv_cancel := λ
  (a)
  (ha : «expr ≠ »(a, 0)), show «expr = »(«expr * »(a, dite _ _ _), _), by rw [expr dif_neg ha] []; exact [expr classical.some_spec (exists_inv ha)],
  inv_zero := dif_pos rfl,
  ..quotient.comm_ring I,
  ..quotient.is_domain I }

/-- If the quotient by an ideal is a field, then the ideal is maximal. -/
theorem maximal_of_is_field (I : Ideal R) (hqf : IsField I.quotient) : I.is_maximal :=
  by 
    apply Ideal.is_maximal_iff.2
    split 
    ·
      intro h 
      rcases hqf.exists_pair_ne with ⟨⟨x⟩, ⟨y⟩, hxy⟩
      exact hxy (Ideal.Quotient.eq.2 (mul_oneₓ (x - y) ▸ I.mul_mem_left _ h))
    ·
      intro J x hIJ hxnI hxJ 
      rcases hqf.mul_inv_cancel (mt Ideal.Quotient.eq_zero_iff_mem.1 hxnI) with ⟨⟨y⟩, hy⟩
      rw [←zero_addₓ (1 : R), ←sub_self (x*y), sub_add]
      refine' J.sub_mem (J.mul_mem_right _ hxJ) (hIJ (Ideal.Quotient.eq.1 hy))

/-- The quotient of a ring by an ideal is a field iff the ideal is maximal. -/
theorem maximal_ideal_iff_is_field_quotient (I : Ideal R) : I.is_maximal ↔ IsField I.quotient :=
  ⟨fun h => @Field.to_is_field I.quotient (@Ideal.Quotient.field _ _ I h), fun h => maximal_of_is_field I h⟩

variable[CommRingₓ S]

-- error in RingTheory.Ideal.Quotient: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Given a ring homomorphism `f : R →+* S` sending all elements of an ideal to zero,
lift it to the quotient by this ideal. -/
def lift
(I : ideal R)
(f : «expr →+* »(R, S))
(H : ∀ a : R, «expr ∈ »(a, I) → «expr = »(f a, 0)) : «expr →+* »(quotient I, S) :=
{ to_fun := λ
  x, «expr $ »(quotient.lift_on' x f, λ
   (a b)
   (h : «expr ∈ »(_, _)), «expr $ »(eq_of_sub_eq_zero, by rw ["[", "<-", expr f.map_sub, ",", expr H _ h, "]"] [])),
  map_one' := f.map_one,
  map_zero' := f.map_zero,
  map_add' := λ a₁ a₂, quotient.induction_on₂' a₁ a₂ f.map_add,
  map_mul' := λ a₁ a₂, quotient.induction_on₂' a₁ a₂ f.map_mul }

@[simp]
theorem lift_mk (I : Ideal R) (f : R →+* S) (H : ∀ (a : R), a ∈ I → f a = 0) : lift I f H (mk I a) = f a :=
  rfl

/-- The ring homomorphism from the quotient by a smaller ideal to the quotient by a larger ideal.

This is the `ideal.quotient` version of `quot.factor` -/
def factor (S T : Ideal R) (H : S ≤ T) : S.quotient →+* T.quotient :=
  Ideal.Quotient.lift S T fun x hx => eq_zero_iff_mem.2 (H hx)

@[simp]
theorem factor_mk (S T : Ideal R) (H : S ≤ T) (x : R) : factor S T H (mk S x) = mk T x :=
  rfl

@[simp]
theorem factor_comp_mk (S T : Ideal R) (H : S ≤ T) : (factor S T H).comp (mk S) = mk T :=
  by 
    ext x 
    rw [RingHom.comp_apply, factor_mk]

end Quotientₓ

/-- Quotienting by equal ideals gives equivalent rings.

See also `submodule.quot_equiv_of_eq`.
-/
def quot_equiv_of_eq {R : Type _} [CommRingₓ R] {I J : Ideal R} (h : I = J) : I.quotient ≃+* J.quotient :=
  { Submodule.quotEquivOfEq I J h with
    map_mul' :=
      by 
        rintro ⟨x⟩ ⟨y⟩
        rfl }

@[simp]
theorem quot_equiv_of_eq_mk {R : Type _} [CommRingₓ R] {I J : Ideal R} (h : I = J) (x : R) :
  quot_equiv_of_eq h (Ideal.Quotient.mk I x) = Ideal.Quotient.mk J x :=
  rfl

section Pi

variable(ι : Type v)

/-- `R^n/I^n` is a `R/I`-module. -/
instance module_pi : Module I.quotient (I.pi ι).Quotient :=
  { smul :=
      fun c m =>
        Quotientₓ.liftOn₂' c m (fun r m => Submodule.Quotient.mk$ r • m)
          (by 
            intro c₁ m₁ c₂ m₂ hc hm 
            apply Ideal.Quotient.eq.2
            intro i 
            exact I.mul_sub_mul_mem hc (hm i)),
    one_smul :=
      by 
        rintro ⟨a⟩
        change Ideal.Quotient.mk _ _ = Ideal.Quotient.mk _ _ 
        congr with i 
        exact one_mulₓ (a i),
    mul_smul :=
      by 
        rintro ⟨a⟩ ⟨b⟩ ⟨c⟩
        change Ideal.Quotient.mk _ _ = Ideal.Quotient.mk _ _ 
        simp only [· • ·]
        congr with i 
        exact mul_assocₓ a b (c i),
    smul_add :=
      by 
        rintro ⟨a⟩ ⟨b⟩ ⟨c⟩
        change Ideal.Quotient.mk _ _ = Ideal.Quotient.mk _ _ 
        congr with i 
        exact mul_addₓ a (b i) (c i),
    smul_zero :=
      by 
        rintro ⟨a⟩
        change Ideal.Quotient.mk _ _ = Ideal.Quotient.mk _ _ 
        congr with i 
        exact mul_zero a,
    add_smul :=
      by 
        rintro ⟨a⟩ ⟨b⟩ ⟨c⟩
        change Ideal.Quotient.mk _ _ = Ideal.Quotient.mk _ _ 
        congr with i 
        exact add_mulₓ a b (c i),
    zero_smul :=
      by 
        rintro ⟨a⟩
        change Ideal.Quotient.mk _ _ = Ideal.Quotient.mk _ _ 
        congr with i 
        exact zero_mul (a i) }

/-- `R^n/I^n` is isomorphic to `(R/I)^n` as an `R/I`-module. -/
noncomputable def pi_quot_equiv : (I.pi ι).Quotient ≃ₗ[I.quotient] ι → I.quotient :=
  { toFun :=
      fun x =>
        (Quotientₓ.liftOn' x fun f i => Ideal.Quotient.mk I (f i))$
          fun a b hab => funext fun i => Ideal.Quotient.eq.2 (hab i),
    map_add' :=
      by 
        rintro ⟨_⟩ ⟨_⟩
        rfl,
    map_smul' :=
      by 
        rintro ⟨_⟩ ⟨_⟩
        rfl,
    invFun := fun x => Ideal.Quotient.mk (I.pi ι)$ fun i => Quotientₓ.out' (x i),
    left_inv :=
      by 
        rintro ⟨x⟩
        exact Ideal.Quotient.eq.2 fun i => Ideal.Quotient.eq.1 (Quotientₓ.out_eq' _),
    right_inv :=
      by 
        intro x 
        ext i 
        obtain ⟨r, hr⟩ := @Quot.exists_rep _ _ (x i)
        simpRw [←hr]
        convert Quotientₓ.out_eq' _ }

/-- If `f : R^n → R^m` is an `R`-linear map and `I ⊆ R` is an ideal, then the image of `I^n` is
    contained in `I^m`. -/
theorem map_pi {ι} [Fintype ι] {ι' : Type w} (x : ι → R) (hi : ∀ i, x i ∈ I) (f : (ι → R) →ₗ[R] ι' → R) (i : ι') :
  f x i ∈ I :=
  by 
    rw [pi_eq_sum_univ x]
    simp only [Finset.sum_apply, smul_eq_mul, LinearMap.map_sum, Pi.smul_apply, LinearMap.map_smul]
    exact I.sum_mem fun j hj => I.mul_mem_right _ (hi j)

end Pi

section ChineseRemainder

variable{ι : Type v}

-- error in RingTheory.Ideal.Quotient: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem exists_sub_one_mem_and_mem
(s : finset ι)
{f : ι → ideal R}
(hf : ∀ i «expr ∈ » s, ∀ j «expr ∈ » s, «expr ≠ »(i, j) → «expr = »(«expr ⊔ »(f i, f j), «expr⊤»()))
(i : ι)
(his : «expr ∈ »(i, s)) : «expr∃ , »((r : R), «expr ∧ »(«expr ∈ »(«expr - »(r, 1), f i), ∀
  j «expr ∈ » s, «expr ≠ »(j, i) → «expr ∈ »(r, f j))) :=
begin
  have [] [":", expr ∀
   j «expr ∈ » s, «expr ≠ »(j, i) → «expr∃ , »((r : R), «expr∃ , »((H : «expr ∈ »(«expr - »(r, 1), f i)), «expr ∈ »(r, f j)))] [],
  { intros [ident j, ident hjs, ident hji],
    specialize [expr hf i his j hjs hji.symm],
    rw ["[", expr eq_top_iff_one, ",", expr submodule.mem_sup, "]"] ["at", ident hf],
    rcases [expr hf, "with", "⟨", ident r, ",", ident hri, ",", ident s, ",", ident hsj, ",", ident hrs, "⟩"],
    refine [expr ⟨«expr - »(1, r), _, _⟩],
    { rw ["[", expr sub_right_comm, ",", expr sub_self, ",", expr zero_sub, "]"] [],
      exact [expr (f i).neg_mem hri] },
    { rw ["[", "<-", expr hrs, ",", expr add_sub_cancel', "]"] [],
      exact [expr hsj] } },
  classical,
  have [] [":", expr «expr∃ , »((g : ι → R), «expr ∧ »(∀
     j, «expr ∈ »(«expr - »(g j, 1), f i), ∀ j «expr ∈ » s, «expr ≠ »(j, i) → «expr ∈ »(g j, f j)))] [],
  { choose [] [ident g] [ident hg1, ident hg2] [],
    refine [expr ⟨λ j, if H : «expr ∧ »(«expr ∈ »(j, s), «expr ≠ »(j, i)) then g j H.1 H.2 else 1, λ j, _, λ j, _⟩],
    { split_ifs [] ["with", ident h],
      { apply [expr hg1] },
      rw [expr sub_self] [],
      exact [expr (f i).zero_mem] },
    { intros [ident hjs, ident hji],
      rw [expr dif_pos] [],
      { apply [expr hg2] },
      exact [expr ⟨hjs, hji⟩] } },
  rcases [expr this, "with", "⟨", ident g, ",", ident hgi, ",", ident hgj, "⟩"],
  use [expr «expr∏ in , »((x), s.erase i, g x)],
  split,
  { rw ["[", "<-", expr quotient.eq, ",", expr ring_hom.map_one, ",", expr ring_hom.map_prod, "]"] [],
    apply [expr finset.prod_eq_one],
    intros [],
    rw ["[", "<-", expr ring_hom.map_one, ",", expr quotient.eq, "]"] [],
    apply [expr hgi] },
  intros [ident j, ident hjs, ident hji],
  rw ["[", "<-", expr quotient.eq_zero_iff_mem, ",", expr ring_hom.map_prod, "]"] [],
  refine [expr finset.prod_eq_zero (finset.mem_erase_of_ne_of_mem hji hjs) _],
  rw [expr quotient.eq_zero_iff_mem] [],
  exact [expr hgj j hjs hji]
end

-- error in RingTheory.Ideal.Quotient: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem exists_sub_mem
[fintype ι]
{f : ι → ideal R}
(hf : ∀ i j, «expr ≠ »(i, j) → «expr = »(«expr ⊔ »(f i, f j), «expr⊤»()))
(g : ι → R) : «expr∃ , »((r : R), ∀ i, «expr ∈ »(«expr - »(r, g i), f i)) :=
begin
  have [] [":", expr «expr∃ , »((φ : ι → R), «expr ∧ »(∀
     i, «expr ∈ »(«expr - »(φ i, 1), f i), ∀ i j, «expr ≠ »(i, j) → «expr ∈ »(φ i, f j)))] [],
  { have [] [] [":=", expr exists_sub_one_mem_and_mem (finset.univ : finset ι) (λ i _ j _ hij, hf i j hij)],
    choose [] [ident φ] [ident hφ] [],
    existsi [expr λ i, φ i (finset.mem_univ i)],
    exact [expr ⟨λ i, (hφ i _).1, λ i j hij, (hφ i _).2 j (finset.mem_univ j) hij.symm⟩] },
  rcases [expr this, "with", "⟨", ident φ, ",", ident hφ1, ",", ident hφ2, "⟩"],
  use [expr «expr∑ , »((i), «expr * »(g i, φ i))],
  intros [ident i],
  rw ["[", "<-", expr quotient.eq, ",", expr ring_hom.map_sum, "]"] [],
  refine [expr eq.trans (finset.sum_eq_single i _ _) _],
  { intros [ident j, "_", ident hji],
    rw [expr quotient.eq_zero_iff_mem] [],
    exact [expr (f i).mul_mem_left _ (hφ2 j i hji)] },
  { intros [ident hi],
    exact [expr «expr $ »(hi, finset.mem_univ i).elim] },
  specialize [expr hφ1 i],
  rw ["[", "<-", expr quotient.eq, ",", expr ring_hom.map_one, "]"] ["at", ident hφ1],
  rw ["[", expr ring_hom.map_mul, ",", expr hφ1, ",", expr mul_one, "]"] []
end

-- error in RingTheory.Ideal.Quotient: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The homomorphism from `R/(⋂ i, f i)` to `∏ i, (R / f i)` featured in the Chinese
  Remainder Theorem. It is bijective if the ideals `f i` are comaximal. -/
def quotient_inf_to_pi_quotient (f : ι → ideal R) : «expr →+* »(«expr⨅ , »((i), f i).quotient, ∀ i, (f i).quotient) :=
«expr $ »(quotient.lift «expr⨅ , »((i), f i) (pi.ring_hom (λ i : ι, (quotient.mk (f i) : _))), λ r hr, begin
   rw [expr submodule.mem_infi] ["at", ident hr],
   ext [] [ident i] [],
   exact [expr quotient.eq_zero_iff_mem.2 (hr i)]
 end)

theorem quotient_inf_to_pi_quotient_bijective [Fintype ι] {f : ι → Ideal R} (hf : ∀ i j, i ≠ j → f i⊔f j = ⊤) :
  Function.Bijective (quotient_inf_to_pi_quotient f) :=
  ⟨fun x y =>
      Quotientₓ.induction_on₂' x y$
        fun r s hrs =>
          Quotientₓ.eq.2$
            (Submodule.mem_infi _).2$
              fun i =>
                Quotientₓ.eq.1$
                  show quotient_inf_to_pi_quotient f (Quotientₓ.mk' r) i = _ by 
                    rw [hrs] <;> rfl,
    fun g =>
      let ⟨r, hr⟩ := exists_sub_mem hf fun i => Quotientₓ.out' (g i)
      ⟨Quotientₓ.mk _ r, funext$ fun i => Quotientₓ.out_eq' (g i) ▸ Quotientₓ.eq.2 (hr i)⟩⟩

/-- Chinese Remainder Theorem. Eisenbud Ex.2.6. Similar to Atiyah-Macdonald 1.10 and Stacks 00DT -/
noncomputable def quotient_inf_ring_equiv_pi_quotient [Fintype ι] (f : ι → Ideal R) (hf : ∀ i j, i ≠ j → f i⊔f j = ⊤) :
  (⨅i, f i).Quotient ≃+* ∀ i, (f i).Quotient :=
  { Equiv.ofBijective _ (quotient_inf_to_pi_quotient_bijective hf), quotient_inf_to_pi_quotient f with  }

end ChineseRemainder

end Ideal

