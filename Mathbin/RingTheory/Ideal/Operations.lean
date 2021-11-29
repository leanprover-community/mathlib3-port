import Mathbin.Algebra.Algebra.Operations 
import Mathbin.RingTheory.NonZeroDivisors 
import Mathbin.Data.Nat.Choose.Sum 
import Mathbin.RingTheory.Coprime.Lemmas 
import Mathbin.Data.Equiv.Ring 
import Mathbin.RingTheory.Ideal.Quotient

/-!
# More operations on modules and ideals
-/


universe u v w x

open_locale BigOperators Pointwise

namespace Submodule

variable{R : Type u}{M : Type v}

section CommSemiringₓ

variable[CommSemiringₓ R][AddCommMonoidₓ M][Module R M]

open_locale Pointwise

instance has_scalar' : HasScalar (Ideal R) (Submodule R M) :=
  ⟨fun I N => ⨆r : I, (r : R) • N⟩

/-- `N.annihilator` is the ideal of all elements `r : R` such that `r • N = 0`. -/
def annihilator (N : Submodule R M) : Ideal R :=
  (LinearMap.lsmul R N).ker

variable{I J : Ideal R}{N P : Submodule R M}

theorem mem_annihilator {r} : r ∈ N.annihilator ↔ ∀ n (_ : n ∈ N), r • n = (0 : M) :=
  ⟨fun hr n hn => congr_argₓ Subtype.val (LinearMap.ext_iff.1 (LinearMap.mem_ker.1 hr) ⟨n, hn⟩),
    fun h => LinearMap.mem_ker.2$ LinearMap.ext$ fun n => Subtype.eq$ h n.1 n.2⟩

theorem mem_annihilator' {r} : r ∈ N.annihilator ↔ N ≤ comap (r • LinearMap.id) ⊥ :=
  mem_annihilator.trans ⟨fun H n hn => (mem_bot R).2$ H n hn, fun H n hn => (mem_bot R).1$ H hn⟩

theorem annihilator_bot : (⊥ : Submodule R M).annihilator = ⊤ :=
  (Ideal.eq_top_iff_one _).2$ mem_annihilator'.2 bot_le

-- error in RingTheory.Ideal.Operations: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem annihilator_eq_top_iff : «expr ↔ »(«expr = »(N.annihilator, «expr⊤»()), «expr = »(N, «expr⊥»())) :=
⟨λ
 H, «expr $ »(eq_bot_iff.2, λ
  (n : M)
  (hn), «expr $ »((mem_bot R).2, «expr ▸ »(one_smul R n, mem_annihilator.1 ((ideal.eq_top_iff_one _).1 H) n hn))), λ
 H, «expr ▸ »(H.symm, annihilator_bot)⟩

theorem annihilator_mono (h : N ≤ P) : P.annihilator ≤ N.annihilator :=
  fun r hrp => mem_annihilator.2$ fun n hn => mem_annihilator.1 hrp n$ h hn

theorem annihilator_supr (ι : Sort w) (f : ι → Submodule R M) : annihilator (⨆i, f i) = ⨅i, annihilator (f i) :=
  le_antisymmₓ (le_infi$ fun i => annihilator_mono$ le_supr _ _)
    fun r H =>
      mem_annihilator'.2$
        supr_le$
          fun i =>
            have  := (mem_infi _).1 H i 
            mem_annihilator'.1 this

theorem smul_mem_smul {r} {n} (hr : r ∈ I) (hn : n ∈ N) : r • n ∈ I • N :=
  (le_supr _ ⟨r, hr⟩ : _ ≤ I • N) ⟨n, hn, rfl⟩

theorem smul_le {P : Submodule R M} : I • N ≤ P ↔ ∀ r (_ : r ∈ I) n (_ : n ∈ N), r • n ∈ P :=
  ⟨fun H r hr n hn => H$ smul_mem_smul hr hn,
    fun H => supr_le$ fun r => map_le_iff_le_comap.2$ fun n hn => H r.1 r.2 n hn⟩

@[elab_as_eliminator]
theorem smul_induction_on {p : M → Prop} {x} (H : x ∈ I • N) (Hb : ∀ r (_ : r ∈ I) n (_ : n ∈ N), p (r • n)) (H0 : p 0)
  (H1 : ∀ x y, p x → p y → p (x+y)) (H2 : ∀ (c : R) n, p n → p (c • n)) : p x :=
  (@smul_le _ _ _ _ _ _ _ ⟨p, H0, H1, H2⟩).2 Hb H

theorem mem_smul_span_singleton {I : Ideal R} {m : M} {x : M} :
  x ∈ I • span R ({m} : Set M) ↔ ∃ (y : _)(_ : y ∈ I), y • m = x :=
  ⟨fun hx =>
      smul_induction_on hx
        (fun r hri n hnm =>
          let ⟨s, hs⟩ := mem_span_singleton.1 hnm
          ⟨r*s, I.mul_mem_right _ hri, hs ▸ mul_smul r s m⟩)
        ⟨0, I.zero_mem,
          by 
            rw [zero_smul]⟩
        (fun m1 m2 ⟨y1, hyi1, hy1⟩ ⟨y2, hyi2, hy2⟩ =>
          ⟨y1+y2, I.add_mem hyi1 hyi2,
            by 
              rw [add_smul, hy1, hy2]⟩)
        fun c r ⟨y, hyi, hy⟩ =>
          ⟨c*y, I.mul_mem_left _ hyi,
            by 
              rw [mul_smul, hy]⟩,
    fun ⟨y, hyi, hy⟩ => hy ▸ smul_mem_smul hyi (subset_span$ Set.mem_singleton m)⟩

theorem smul_le_right : I • N ≤ N :=
  smul_le.2$ fun r hr n => N.smul_mem r

theorem smul_mono (hij : I ≤ J) (hnp : N ≤ P) : I • N ≤ J • P :=
  smul_le.2$ fun r hr n hn => smul_mem_smul (hij hr) (hnp hn)

theorem smul_mono_left (h : I ≤ J) : I • N ≤ J • N :=
  smul_mono h (le_reflₓ N)

theorem smul_mono_right (h : N ≤ P) : I • N ≤ I • P :=
  smul_mono (le_reflₓ I) h

@[simp]
theorem annihilator_smul (N : Submodule R M) : annihilator N • N = ⊥ :=
  eq_bot_iff.2 (smul_le.2 fun r => mem_annihilator.1)

@[simp]
theorem annihilator_mul (I : Ideal R) : (annihilator I*I) = ⊥ :=
  annihilator_smul I

@[simp]
theorem mul_annihilator (I : Ideal R) : (I*annihilator I) = ⊥ :=
  by 
    rw [mul_commₓ, annihilator_mul]

variable(I J N P)

@[simp]
theorem smul_bot : I • (⊥ : Submodule R M) = ⊥ :=
  eq_bot_iff.2$ smul_le.2$ fun r hri s hsb => (Submodule.mem_bot R).2$ ((Submodule.mem_bot R).1 hsb).symm ▸ smul_zero r

@[simp]
theorem bot_smul : (⊥ : Ideal R) • N = ⊥ :=
  eq_bot_iff.2$
    smul_le.2$ fun r hrb s hsi => (Submodule.mem_bot R).2$ ((Submodule.mem_bot R).1 hrb).symm ▸ zero_smul _ s

@[simp]
theorem top_smul : (⊤ : Ideal R) • N = N :=
  le_antisymmₓ smul_le_right$ fun r hri => one_smul R r ▸ smul_mem_smul mem_top hri

theorem smul_sup : I • (N⊔P) = I • N⊔I • P :=
  le_antisymmₓ
    (smul_le.2$
      fun r hri m hmnp =>
        let ⟨n, hn, p, hp, hnpm⟩ := mem_sup.1 hmnp 
        mem_sup.2 ⟨_, smul_mem_smul hri hn, _, smul_mem_smul hri hp, hnpm ▸ (smul_add _ _ _).symm⟩)
    (sup_le (smul_mono_right le_sup_left) (smul_mono_right le_sup_right))

theorem sup_smul : (I⊔J) • N = I • N⊔J • N :=
  le_antisymmₓ
    (smul_le.2$
      fun r hrij n hn =>
        let ⟨ri, hri, rj, hrj, hrijr⟩ := mem_sup.1 hrij 
        mem_sup.2 ⟨_, smul_mem_smul hri hn, _, smul_mem_smul hrj hn, hrijr ▸ (add_smul _ _ _).symm⟩)
    (sup_le (smul_mono_left le_sup_left) (smul_mono_left le_sup_right))

protected theorem smul_assoc : (I • J) • N = I • J • N :=
  le_antisymmₓ
    (smul_le.2$
      fun rs hrsij t htn =>
        smul_induction_on hrsij
          (fun r hr s hs => (@smul_eq_mul R _ r s).symm ▸ smul_smul r s t ▸ smul_mem_smul hr (smul_mem_smul hs htn))
          ((zero_smul R t).symm ▸ Submodule.zero_mem _) (fun x y => (add_smul x y t).symm ▸ Submodule.add_mem _)
          fun r s h => (@smul_eq_mul R _ r s).symm ▸ smul_smul r s t ▸ Submodule.smul_mem _ _ h)
    (smul_le.2$
      fun r hr sn hsn =>
        suffices J • N ≤ Submodule.comap (r • LinearMap.id) ((I • J) • N) from this hsn 
        smul_le.2$
          fun s hs n hn => show r • s • n ∈ (I • J) • N from mul_smul r s n ▸ smul_mem_smul (smul_mem_smul hr hs) hn)

variable(S : Set R)(T : Set M)

theorem span_smul_span : Ideal.span S • span R T = span R (⋃(s : _)(_ : s ∈ S)(t : _)(_ : t ∈ T), {s • t}) :=
  le_antisymmₓ
      (smul_le.2$
        fun r hrS n hnT =>
          span_induction hrS
            (fun r hrS =>
              span_induction hnT (fun n hnT => subset_span$ Set.mem_bUnion hrS$ Set.mem_bUnion hnT$ Set.mem_singleton _)
                ((smul_zero r : r • 0 = (0 : M)).symm ▸ Submodule.zero_mem _)
                (fun x y => (smul_add r x y).symm ▸ Submodule.add_mem _)
                fun c m =>
                  by 
                    rw [smul_smul, mul_commₓ, mul_smul] <;> exact Submodule.smul_mem _ _)
            ((zero_smul R n).symm ▸ Submodule.zero_mem _) (fun r s => (add_smul r s n).symm ▸ Submodule.add_mem _)
            fun c r =>
              by 
                rw [smul_eq_mul, mul_smul] <;> exact Submodule.smul_mem _ _)$
    span_le.2$
      Set.bUnion_subset$
        fun r hrS =>
          Set.bUnion_subset$ fun n hnT => Set.singleton_subset_iff.2$ smul_mem_smul (subset_span hrS) (subset_span hnT)

variable{M' : Type w}[AddCommMonoidₓ M'][Module R M']

theorem map_smul'' (f : M →ₗ[R] M') : (I • N).map f = I • N.map f :=
  le_antisymmₓ
      (map_le_iff_le_comap.2$
        smul_le.2$
          fun r hr n hn =>
            show f (r • n) ∈ I • N.map f from (f.map_smul r n).symm ▸ smul_mem_smul hr (mem_map_of_mem hn))$
    smul_le.2$
      fun r hr n hn =>
        let ⟨p, hp, hfp⟩ := mem_map.1 hn 
        hfp ▸ f.map_smul r p ▸ mem_map_of_mem (smul_mem_smul hr hp)

end CommSemiringₓ

section CommRingₓ

variable[CommRingₓ R][AddCommGroupₓ M][Module R M]

variable{N N₁ N₂ P P₁ P₂ : Submodule R M}

/-- `N.colon P` is the ideal of all elements `r : R` such that `r • P ⊆ N`. -/
def colon (N P : Submodule R M) : Ideal R :=
  annihilator (P.map N.mkq)

theorem mem_colon {r} : r ∈ N.colon P ↔ ∀ p (_ : p ∈ P), r • p ∈ N :=
  mem_annihilator.trans
    ⟨fun H p hp => (quotient.mk_eq_zero N).1 (H (Quotientₓ.mk p) (mem_map_of_mem hp)),
      fun H m ⟨p, hp, hpm⟩ => hpm ▸ N.mkq.map_smul r p ▸ (quotient.mk_eq_zero N).2$ H p hp⟩

theorem mem_colon' {r} : r ∈ N.colon P ↔ P ≤ comap (r • LinearMap.id) N :=
  mem_colon

theorem colon_mono (hn : N₁ ≤ N₂) (hp : P₁ ≤ P₂) : N₁.colon P₂ ≤ N₂.colon P₁ :=
  fun r hrnp => mem_colon.2$ fun p₁ hp₁ => hn$ mem_colon.1 hrnp p₁$ hp hp₁

theorem infi_colon_supr (ι₁ : Sort w) (f : ι₁ → Submodule R M) (ι₂ : Sort x) (g : ι₂ → Submodule R M) :
  (⨅i, f i).colon (⨆j, g j) = ⨅i j, (f i).colon (g j) :=
  le_antisymmₓ (le_infi$ fun i => le_infi$ fun j => colon_mono (infi_le _ _) (le_supr _ _))
    fun r H =>
      mem_colon'.2$
        supr_le$
          fun j =>
            map_le_iff_le_comap.1$
              le_infi$
                fun i =>
                  map_le_iff_le_comap.2$
                    mem_colon'.1$
                      have  := (mem_infi _).1 H i 
                      have  := (mem_infi _).1 this j 
                      this

end CommRingₓ

end Submodule

namespace Ideal

section MulAndRadical

variable{R : Type u}{ι : Type _}[CommSemiringₓ R]

variable{I J K L : Ideal R}

instance  : Mul (Ideal R) :=
  ⟨· • ·⟩

@[simp]
theorem add_eq_sup : (I+J) = I⊔J :=
  rfl

@[simp]
theorem zero_eq_bot : (0 : Ideal R) = ⊥ :=
  rfl

@[simp]
theorem one_eq_top : (1 : Ideal R) = ⊤ :=
  by 
    erw [Submodule.one_eq_range, LinearMap.range_id]

theorem mul_mem_mul {r s} (hr : r ∈ I) (hs : s ∈ J) : (r*s) ∈ I*J :=
  Submodule.smul_mem_smul hr hs

theorem mul_mem_mul_rev {r s} (hr : r ∈ I) (hs : s ∈ J) : (s*r) ∈ I*J :=
  mul_commₓ r s ▸ mul_mem_mul hr hs

theorem pow_mem_pow {x : R} (hx : x ∈ I) (n : ℕ) : x ^ n ∈ I ^ n :=
  by 
    induction' n with n ih
    ·
      simp only [pow_zeroₓ, Ideal.one_eq_top]
    simpa only [pow_succₓ] using mul_mem_mul hx ih

theorem mul_le : (I*J) ≤ K ↔ ∀ r (_ : r ∈ I) s (_ : s ∈ J), (r*s) ∈ K :=
  Submodule.smul_le

theorem mul_le_left : (I*J) ≤ J :=
  Ideal.mul_le.2 fun r hr s => J.mul_mem_left _

theorem mul_le_right : (I*J) ≤ I :=
  Ideal.mul_le.2 fun r hr s hs => I.mul_mem_right _ hr

@[simp]
theorem sup_mul_right_self : (I⊔I*J) = I :=
  sup_eq_left.2 Ideal.mul_le_right

@[simp]
theorem sup_mul_left_self : (I⊔J*I) = I :=
  sup_eq_left.2 Ideal.mul_le_left

@[simp]
theorem mul_right_self_sup : (I*J)⊔I = I :=
  sup_eq_right.2 Ideal.mul_le_right

@[simp]
theorem mul_left_self_sup : (J*I)⊔I = I :=
  sup_eq_right.2 Ideal.mul_le_left

variable(I J K)

protected theorem mul_commₓ : (I*J) = J*I :=
  le_antisymmₓ (mul_le.2$ fun r hrI s hsJ => mul_mem_mul_rev hsJ hrI)
    (mul_le.2$ fun r hrJ s hsI => mul_mem_mul_rev hsI hrJ)

protected theorem mul_assocₓ : ((I*J)*K) = I*J*K :=
  Submodule.smul_assoc I J K

theorem span_mul_span (S T : Set R) : (span S*span T) = span (⋃(s : _)(_ : s ∈ S)(t : _)(_ : t ∈ T), {s*t}) :=
  Submodule.span_smul_span S T

variable{I J K}

theorem span_mul_span' (S T : Set R) : (span S*span T) = span (S*T) :=
  by 
    unfold span 
    rw [Submodule.span_mul_span]

theorem span_singleton_mul_span_singleton (r s : R) : (span {r}*span {s}) = (span {r*s} : Ideal R) :=
  by 
    unfold span 
    rw [Submodule.span_mul_span, Set.singleton_mul_singleton]

theorem span_singleton_pow (s : R) (n : ℕ) : span {s} ^ n = (span {s ^ n} : Ideal R) :=
  by 
    induction' n with n ih
    ·
      simp [Set.singleton_one]
    simp only [pow_succₓ, ih, span_singleton_mul_span_singleton]

theorem mem_mul_span_singleton {x y : R} {I : Ideal R} : (x ∈ I*span {y}) ↔ ∃ (z : _)(_ : z ∈ I), (z*y) = x :=
  Submodule.mem_smul_span_singleton

theorem mem_span_singleton_mul {x y : R} {I : Ideal R} : (x ∈ span {y}*I) ↔ ∃ (z : _)(_ : z ∈ I), (y*z) = x :=
  by 
    simp only [mul_commₓ, mem_mul_span_singleton]

theorem le_span_singleton_mul_iff {x : R} {I J : Ideal R} :
  (I ≤ span {x}*J) ↔ ∀ zI (_ : zI ∈ I), ∃ (zJ : _)(_ : zJ ∈ J), (x*zJ) = zI :=
  show (∀ {zI} (hzI : zI ∈ I), zI ∈ span {x}*J) ↔ ∀ zI (_ : zI ∈ I), ∃ (zJ : _)(_ : zJ ∈ J), (x*zJ) = zI by 
    simp only [mem_span_singleton_mul]

theorem span_singleton_mul_le_iff {x : R} {I J : Ideal R} : (span {x}*I) ≤ J ↔ ∀ z (_ : z ∈ I), (x*z) ∈ J :=
  by 
    simp only [mul_le, mem_span_singleton_mul, mem_span_singleton]
    split 
    ·
      intro h zI hzI 
      exact h x (dvd_refl x) zI hzI
    ·
      rintro h _ ⟨z, rfl⟩ zI hzI 
      rw [mul_commₓ x z, mul_assocₓ]
      exact J.mul_mem_left _ (h zI hzI)

theorem span_singleton_mul_le_span_singleton_mul {x y : R} {I J : Ideal R} :
  ((span {x}*I) ≤ span {y}*J) ↔ ∀ zI (_ : zI ∈ I), ∃ (zJ : _)(_ : zJ ∈ J), (x*zI) = y*zJ :=
  by 
    simp only [span_singleton_mul_le_iff, mem_span_singleton_mul, eq_comm]

theorem eq_span_singleton_mul {x : R} (I J : Ideal R) :
  (I = span {x}*J) ↔ (∀ zI (_ : zI ∈ I), ∃ (zJ : _)(_ : zJ ∈ J), (x*zJ) = zI) ∧ ∀ z (_ : z ∈ J), (x*z) ∈ I :=
  by 
    simp only [le_antisymm_iffₓ, le_span_singleton_mul_iff, span_singleton_mul_le_iff]

theorem span_singleton_mul_eq_span_singleton_mul {x y : R} (I J : Ideal R) :
  ((span {x}*I) = span {y}*J) ↔
    (∀ zI (_ : zI ∈ I), ∃ (zJ : _)(_ : zJ ∈ J), (x*zI) = y*zJ) ∧
      ∀ zJ (_ : zJ ∈ J), ∃ (zI : _)(_ : zI ∈ I), (x*zI) = y*zJ :=
  by 
    simp only [le_antisymm_iffₓ, span_singleton_mul_le_span_singleton_mul, eq_comm]

theorem prod_span {ι : Type _} (s : Finset ι) (I : ι → Set R) :
  (∏i in s, Ideal.span (I i)) = Ideal.span (∏i in s, I i) :=
  Submodule.prod_span s I

theorem prod_span_singleton {ι : Type _} (s : Finset ι) (I : ι → R) :
  (∏i in s, Ideal.span ({I i} : Set R)) = Ideal.span {∏i in s, I i} :=
  Submodule.prod_span_singleton s I

theorem finset_inf_span_singleton {ι : Type _} (s : Finset ι) (I : ι → R)
  (hI : Set.Pairwise («expr↑ » s) (IsCoprime on I)) :
  (s.inf$ fun i => Ideal.span ({I i} : Set R)) = Ideal.span {∏i in s, I i} :=
  by 
    ext x 
    simp only [Submodule.mem_finset_inf, Ideal.mem_span_singleton]
    exact ⟨Finset.prod_dvd_of_coprime hI, fun h i hi => (Finset.dvd_prod_of_mem _ hi).trans h⟩

theorem infi_span_singleton {ι : Type _} [Fintype ι] (I : ι → R) (hI : ∀ i j (hij : i ≠ j), IsCoprime (I i) (I j)) :
  (⨅i, Ideal.span ({I i} : Set R)) = Ideal.span {∏i, I i} :=
  by 
    rw [←Finset.inf_univ_eq_infi, finset_inf_span_singleton]
    rwa [Finset.coe_univ, Set.pairwise_univ]

theorem mul_le_inf : (I*J) ≤ I⊓J :=
  mul_le.2$ fun r hri s hsj => ⟨I.mul_mem_right s hri, J.mul_mem_left r hsj⟩

theorem multiset_prod_le_inf {s : Multiset (Ideal R)} : s.prod ≤ s.inf :=
  by 
    classical 
    refine' s.induction_on _ _
    ·
      rw [Multiset.inf_zero]
      exact le_top 
    intro a s ih 
    rw [Multiset.prod_cons, Multiset.inf_cons]
    exact le_transₓ mul_le_inf (inf_le_inf (le_reflₓ _) ih)

theorem prod_le_inf {s : Finset ι} {f : ι → Ideal R} : s.prod f ≤ s.inf f :=
  multiset_prod_le_inf

theorem mul_eq_inf_of_coprime (h : I⊔J = ⊤) : (I*J) = I⊓J :=
  le_antisymmₓ mul_le_inf$
    fun r ⟨hri, hrj⟩ =>
      let ⟨s, hsi, t, htj, hst⟩ := Submodule.mem_sup.1 ((eq_top_iff_one _).1 h)
      mul_oneₓ r ▸ hst ▸ (mul_addₓ r s t).symm ▸ Ideal.add_mem (I*J) (mul_mem_mul_rev hsi hrj) (mul_mem_mul hri htj)

variable(I)

@[simp]
theorem mul_bot : (I*⊥) = ⊥ :=
  Submodule.smul_bot I

@[simp]
theorem bot_mul : (⊥*I) = ⊥ :=
  Submodule.bot_smul I

@[simp]
theorem mul_top : (I*⊤) = I :=
  Ideal.mul_comm ⊤ I ▸ Submodule.top_smul I

@[simp]
theorem top_mul : (⊤*I) = I :=
  Submodule.top_smul I

variable{I}

theorem mul_mono (hik : I ≤ K) (hjl : J ≤ L) : (I*J) ≤ K*L :=
  Submodule.smul_mono hik hjl

theorem mul_mono_left (h : I ≤ J) : (I*K) ≤ J*K :=
  Submodule.smul_mono_left h

theorem mul_mono_right (h : J ≤ K) : (I*J) ≤ I*K :=
  Submodule.smul_mono_right h

variable(I J K)

theorem mul_sup : (I*J⊔K) = (I*J)⊔I*K :=
  Submodule.smul_sup I J K

theorem sup_mul : ((I⊔J)*K) = (I*K)⊔J*K :=
  Submodule.sup_smul I J K

variable{I J K}

theorem pow_le_pow {m n : ℕ} (h : m ≤ n) : I ^ n ≤ I ^ m :=
  by 
    cases' Nat.exists_eq_add_of_le h with k hk 
    rw [hk, pow_addₓ]
    exact le_transₓ mul_le_inf inf_le_left

theorem mul_eq_bot {R : Type _} [CommRingₓ R] [IsDomain R] {I J : Ideal R} : (I*J) = ⊥ ↔ I = ⊥ ∨ J = ⊥ :=
  ⟨fun hij =>
      or_iff_not_imp_left.mpr
        fun I_ne_bot =>
          J.eq_bot_iff.mpr
            fun j hj =>
              let ⟨i, hi, ne0⟩ := I.ne_bot_iff.mp I_ne_bot 
              Or.resolve_left (mul_eq_zero.mp ((I*J).eq_bot_iff.mp hij _ (mul_mem_mul hi hj))) ne0,
    fun h =>
      by 
        cases h <;> rw [←Ideal.mul_bot, h, Ideal.mul_comm]⟩

instance  {R : Type _} [CommRingₓ R] [IsDomain R] : NoZeroDivisors (Ideal R) :=
  { eq_zero_or_eq_zero_of_mul_eq_zero := fun I J => mul_eq_bot.1 }

/-- A product of ideals in an integral domain is zero if and only if one of the terms is zero. -/
theorem prod_eq_bot {R : Type _} [CommRingₓ R] [IsDomain R] {s : Multiset (Ideal R)} :
  s.prod = ⊥ ↔ ∃ (I : _)(_ : I ∈ s), I = ⊥ :=
  prod_zero_iff_exists_zero

/-- The radical of an ideal `I` consists of the elements `r` such that `r^n ∈ I` for some `n`. -/
def radical (I : Ideal R) : Ideal R :=
  { Carrier := { r | ∃ n : ℕ, r ^ n ∈ I }, zero_mem' := ⟨1, (pow_oneₓ (0 : R)).symm ▸ I.zero_mem⟩,
    add_mem' :=
      fun x y ⟨m, hxmi⟩ ⟨n, hyni⟩ =>
        ⟨m+n,
          (add_pow x y (m+n)).symm ▸ I.sum_mem$
            show ∀ c (_ : c ∈ Finset.range (Nat.succ (m+n))), (((x ^ c)*y ^ ((m+n) - c))*Nat.choose (m+n) c) ∈ I from
              fun c hc =>
                Or.cases_on (le_totalₓ c m)
                  (fun hcm =>
                    I.mul_mem_right _$
                      I.mul_mem_left _$
                        Nat.add_comm n m ▸
                          (add_tsub_assoc_of_le hcm n).symm ▸ (pow_addₓ y n (m - c)).symm ▸ I.mul_mem_right _ hyni)
                  fun hmc =>
                    I.mul_mem_right _$
                      I.mul_mem_right _$
                        add_tsub_cancel_of_le hmc ▸ (pow_addₓ x m (c - m)).symm ▸ I.mul_mem_right _ hxmi⟩,
    smul_mem' := fun r s ⟨n, hsni⟩ => ⟨n, (mul_powₓ r s n).symm ▸ I.mul_mem_left (r ^ n) hsni⟩ }

theorem le_radical : I ≤ radical I :=
  fun r hri => ⟨1, (pow_oneₓ r).symm ▸ hri⟩

variable(R)

theorem radical_top : (radical ⊤ : Ideal R) = ⊤ :=
  (eq_top_iff_one _).2 ⟨0, Submodule.mem_top⟩

variable{R}

theorem radical_mono (H : I ≤ J) : radical I ≤ radical J :=
  fun r ⟨n, hrni⟩ => ⟨n, H hrni⟩

variable(I)

@[simp]
theorem radical_idem : radical (radical I) = radical I :=
  le_antisymmₓ (fun r ⟨n, k, hrnki⟩ => ⟨n*k, (pow_mulₓ r n k).symm ▸ hrnki⟩) le_radical

variable{I}

theorem radical_le_radical_iff : radical I ≤ radical J ↔ I ≤ radical J :=
  ⟨fun h => le_transₓ le_radical h, fun h => radical_idem J ▸ radical_mono h⟩

theorem radical_eq_top : radical I = ⊤ ↔ I = ⊤ :=
  ⟨fun h =>
      (eq_top_iff_one _).2$
        let ⟨n, hn⟩ := (eq_top_iff_one _).1 h
        @one_pow R _ n ▸ hn,
    fun h => h.symm ▸ radical_top R⟩

theorem is_prime.radical (H : is_prime I) : radical I = I :=
  le_antisymmₓ (fun r ⟨n, hrni⟩ => H.mem_of_pow_mem n hrni) le_radical

variable(I J)

theorem radical_sup : radical (I⊔J) = radical (radical I⊔radical J) :=
  le_antisymmₓ (radical_mono$ sup_le_sup le_radical le_radical)$
    fun r ⟨n, hrnij⟩ =>
      let ⟨s, hs, t, ht, hst⟩ := Submodule.mem_sup.1 hrnij
      @radical_idem _ _ (I⊔J) ▸ ⟨n, hst ▸ Ideal.add_mem _ (radical_mono le_sup_left hs) (radical_mono le_sup_right ht)⟩

theorem radical_inf : radical (I⊓J) = radical I⊓radical J :=
  le_antisymmₓ (le_inf (radical_mono inf_le_left) (radical_mono inf_le_right))
    fun r ⟨⟨m, hrm⟩, ⟨n, hrn⟩⟩ =>
      ⟨m+n, (pow_addₓ r m n).symm ▸ I.mul_mem_right _ hrm, (pow_addₓ r m n).symm ▸ J.mul_mem_left _ hrn⟩

theorem radical_mul : radical (I*J) = radical I⊓radical J :=
  le_antisymmₓ (radical_inf I J ▸ radical_mono$ @mul_le_inf _ _ I J)
    fun r ⟨⟨m, hrm⟩, ⟨n, hrn⟩⟩ => ⟨m+n, (pow_addₓ r m n).symm ▸ mul_mem_mul hrm hrn⟩

variable{I J}

theorem is_prime.radical_le_iff (hj : is_prime J) : radical I ≤ J ↔ I ≤ J :=
  ⟨le_transₓ le_radical, fun hij r ⟨n, hrni⟩ => hj.mem_of_pow_mem n$ hij hrni⟩

theorem radical_eq_Inf (I : Ideal R) : radical I = Inf { J:Ideal R | I ≤ J ∧ is_prime J } :=
  le_antisymmₓ (le_Inf$ fun J hJ => hJ.2.radical_le_iff.2 hJ.1)$
    fun r hr =>
      Classical.by_contradiction$
        fun hri =>
          let ⟨m, (hrm : r ∉ radical m), him, hm⟩ :=
            Zorn.zorn_nonempty_partial_order₀ { K:Ideal R | r ∉ radical K }
              (fun c hc hcc y hyc =>
                ⟨Sup c,
                  fun ⟨n, hrnc⟩ =>
                    let ⟨y, hyc, hrny⟩ := (Submodule.mem_Sup_of_directed ⟨y, hyc⟩ hcc.directed_on).1 hrnc 
                    hc hyc ⟨n, hrny⟩,
                  fun z => le_Sup⟩)
              I hri 
          have  : ∀ x (_ : x ∉ m), r ∈ radical (m⊔span {x}) :=
            fun x hxm =>
              Classical.by_contradiction$
                fun hrmx =>
                  hxm$
                    hm (m⊔span {x}) hrmx le_sup_left ▸
                      (le_sup_right : _ ≤ m⊔span {x}) (subset_span$ Set.mem_singleton _)
          have  : is_prime m :=
            ⟨by 
                rintro rfl <;> rw [radical_top] at hrm <;> exact hrm trivialₓ,
              fun x y hxym =>
                or_iff_not_imp_left.2$
                  fun hxm =>
                    Classical.by_contradiction$
                      fun hym =>
                        let ⟨n, hrn⟩ := this _ hxm 
                        let ⟨p, hpm, q, hq, hpqrn⟩ := Submodule.mem_sup.1 hrn 
                        let ⟨c, hcxq⟩ := mem_span_singleton'.1 hq 
                        let ⟨k, hrk⟩ := this _ hym 
                        let ⟨f, hfm, g, hg, hfgrk⟩ := Submodule.mem_sup.1 hrk 
                        let ⟨d, hdyg⟩ := mem_span_singleton'.1 hg 
                        hrm
                          ⟨n+k,
                            by 
                              rw [pow_addₓ, ←hpqrn, ←hcxq, ←hfgrk, ←hdyg, add_mulₓ, mul_addₓ (c*x),
                                  mul_assocₓ c x (d*y), mul_left_commₓ x, ←mul_assocₓ] <;>
                                refine'
                                  m.add_mem (m.mul_mem_right _ hpm)
                                    (m.add_mem (m.mul_mem_left _ hfm) (m.mul_mem_left _ hxym))⟩⟩
          hrm$ this.radical.symm ▸ (Inf_le ⟨him, this⟩ : Inf { J:Ideal R | I ≤ J ∧ is_prime J } ≤ m) hr

@[simp]
theorem radical_bot_of_is_domain {R : Type u} [CommRingₓ R] [IsDomain R] : radical (⊥ : Ideal R) = ⊥ :=
  eq_bot_iff.2 fun x hx => hx.rec_on fun n hn => pow_eq_zero hn

instance  : CommSemiringₓ (Ideal R) :=
  Submodule.commSemiring

variable(R)

theorem top_pow (n : ℕ) : (⊤ ^ n : Ideal R) = ⊤ :=
  Nat.recOn n one_eq_top$
    fun n ih =>
      by 
        rw [pow_succₓ, ih, top_mul]

variable{R}

variable(I)

theorem radical_pow (n : ℕ) (H : n > 0) : radical (I ^ n) = radical I :=
  Nat.recOn n
    (Not.elim
      (by 
        decide))
    (fun n ih H =>
      Or.cases_on (lt_or_eq_of_leₓ$ Nat.le_of_lt_succₓ H)
        (fun H =>
          calc radical (I ^ n+1) = radical I⊓radical (I ^ n) :=
            by 
              rw [pow_succₓ]
              exact radical_mul _ _ 
            _ = radical I⊓radical I :=
            by 
              rw [ih H]
            _ = radical I := inf_idem
            )
        fun H => H ▸ (pow_oneₓ I).symm ▸ rfl)
    H

theorem is_prime.mul_le {I J P : Ideal R} (hp : is_prime P) : (I*J) ≤ P ↔ I ≤ P ∨ J ≤ P :=
  ⟨fun h =>
      or_iff_not_imp_left.2$
        fun hip j hj =>
          let ⟨i, hi, hip⟩ := Set.not_subset.1 hip
          (hp.mem_or_mem$ h$ mul_mem_mul hi hj).resolve_left hip,
    fun h => Or.cases_on h (le_transₓ$ le_transₓ mul_le_inf inf_le_left) (le_transₓ$ le_transₓ mul_le_inf inf_le_right)⟩

theorem is_prime.inf_le {I J P : Ideal R} (hp : is_prime P) : I⊓J ≤ P ↔ I ≤ P ∨ J ≤ P :=
  ⟨fun h => hp.mul_le.1$ le_transₓ mul_le_inf h,
    fun h => Or.cases_on h (le_transₓ inf_le_left) (le_transₓ inf_le_right)⟩

theorem is_prime.multiset_prod_le {s : Multiset (Ideal R)} {P : Ideal R} (hp : is_prime P) (hne : s ≠ 0) :
  s.prod ≤ P ↔ ∃ (I : _)(_ : I ∈ s), I ≤ P :=
  suffices s.prod ≤ P → ∃ (I : _)(_ : I ∈ s), I ≤ P from
    ⟨this, fun ⟨i, his, hip⟩ => le_transₓ multiset_prod_le_inf$ le_transₓ (Multiset.inf_le his) hip⟩
  by 
    classical 
    obtain ⟨b, hb⟩ : ∃ b, b ∈ s := Multiset.exists_mem_of_ne_zero hne 
    obtain ⟨t, rfl⟩ : ∃ t, s = b ::ₘ t 
    exact ⟨s.erase b, (Multiset.cons_erase hb).symm⟩
    refine' t.induction_on _ _
    ·
      simp only [exists_prop, ←Multiset.singleton_eq_cons, Multiset.prod_singleton, Multiset.mem_singleton,
        exists_eq_left, imp_self]
    intro a s ih h 
    rw [Multiset.cons_swap, Multiset.prod_cons, hp.mul_le] at h 
    rw [Multiset.cons_swap]
    cases h
    ·
      exact ⟨a, Multiset.mem_cons_self a _, h⟩
    obtain ⟨I, hI, ih⟩ : ∃ (I : _)(_ : I ∈ b ::ₘ s), I ≤ P := ih h 
    exact ⟨I, Multiset.mem_cons_of_mem hI, ih⟩

theorem is_prime.multiset_prod_map_le {s : Multiset ι} (f : ι → Ideal R) {P : Ideal R} (hp : is_prime P) (hne : s ≠ 0) :
  (s.map f).Prod ≤ P ↔ ∃ (i : _)(_ : i ∈ s), f i ≤ P :=
  by 
    rw [hp.multiset_prod_le (mt multiset.map_eq_zero.mp hne)]
    simpRw [exists_prop, Multiset.mem_map, exists_exists_and_eq_and]

theorem is_prime.prod_le {s : Finset ι} {f : ι → Ideal R} {P : Ideal R} (hp : is_prime P) (hne : s.nonempty) :
  s.prod f ≤ P ↔ ∃ (i : _)(_ : i ∈ s), f i ≤ P :=
  hp.multiset_prod_map_le f (mt Finset.val_eq_zero.mp hne.ne_empty)

theorem is_prime.inf_le' {s : Finset ι} {f : ι → Ideal R} {P : Ideal R} (hp : is_prime P) (hsne : s.nonempty) :
  s.inf f ≤ P ↔ ∃ (i : _)(_ : i ∈ s), f i ≤ P :=
  ⟨fun h => (hp.prod_le hsne).1$ le_transₓ prod_le_inf h, fun ⟨i, his, hip⟩ => le_transₓ (Finset.inf_le his) hip⟩

theorem subset_union {R : Type u} [CommRingₓ R] {I J K : Ideal R} : (I : Set R) ⊆ J ∪ K ↔ I ≤ J ∨ I ≤ K :=
  ⟨fun h =>
      or_iff_not_imp_left.2$
        fun hij s hsi =>
          let ⟨r, hri, hrj⟩ := Set.not_subset.1 hij 
          Classical.by_contradiction$
            fun hsk =>
              Or.cases_on (h$ I.add_mem hri hsi)
                (fun hj => hrj$ add_sub_cancel r s ▸ J.sub_mem hj ((h hsi).resolve_right hsk))
                fun hk => hsk$ add_sub_cancel' r s ▸ K.sub_mem hk ((h hri).resolve_left hrj),
    fun h =>
      Or.cases_on h (fun h => Set.Subset.trans h$ Set.subset_union_left J K)
        fun h => Set.Subset.trans h$ Set.subset_union_right J K⟩

-- error in RingTheory.Ideal.Operations: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem subset_union_prime'
{R : Type u}
[comm_ring R]
{s : finset ι}
{f : ι → ideal R}
{a b : ι}
(hp : ∀ i «expr ∈ » s, is_prime (f i))
{I : ideal R} : «expr ↔ »(«expr ⊆ »((I : set R), «expr ∪ »(«expr ∪ »(f a, f b), «expr⋃ , »((i «expr ∈ » («expr↑ »(s) : set ι)), f i))), «expr ∨ »(«expr ≤ »(I, f a), «expr ∨ »(«expr ≤ »(I, f b), «expr∃ , »((i «expr ∈ » s), «expr ≤ »(I, f i))))) :=
suffices «expr ⊆ »((I : set R), «expr ∪ »(«expr ∪ »(f a, f b), «expr⋃ , »((i «expr ∈ » («expr↑ »(s) : set ι)), f i))) → «expr ∨ »(«expr ≤ »(I, f a), «expr ∨ »(«expr ≤ »(I, f b), «expr∃ , »((i «expr ∈ » s), «expr ≤ »(I, f i)))), from ⟨this, λ
 h, «expr $ »(or.cases_on h (λ
   h, «expr $ »(set.subset.trans h, set.subset.trans (set.subset_union_left _ _) (set.subset_union_left _ _))), λ
  h, «expr $ »(or.cases_on h (λ
    h, «expr $ »(set.subset.trans h, set.subset.trans (set.subset_union_right _ _) (set.subset_union_left _ _))), λ
   ⟨i, his, hi⟩, by refine [expr «expr $ »(set.subset.trans hi, «expr $ »(set.subset.trans _, set.subset_union_right _ _))]; exact [expr set.subset_bUnion_of_mem (finset.mem_coe.2 his)]))⟩,
begin
  generalize [ident hn] [":"] [expr «expr = »(s.card, n)],
  intros [ident h],
  unfreezingI { induction [expr n] [] ["with", ident n, ident ih] ["generalizing", ident a, ident b, ident s] },
  { clear [ident hp],
    rw [expr finset.card_eq_zero] ["at", ident hn],
    subst [expr hn],
    rw ["[", expr finset.coe_empty, ",", expr set.bUnion_empty, ",", expr set.union_empty, ",", expr subset_union, "]"] ["at", ident h],
    simpa [] [] ["only"] ["[", expr exists_prop, ",", expr finset.not_mem_empty, ",", expr false_and, ",", expr exists_false, ",", expr or_false, "]"] [] [] },
  classical,
  replace [ident hn] [":", expr «expr∃ , »((i : ι)
    (t : finset ι), «expr ∧ »(«expr ∉ »(i, t), «expr ∧ »(«expr = »(insert i t, s), «expr = »(t.card, n))))] [":=", expr finset.card_eq_succ.1 hn],
  unfreezingI { rcases [expr hn, "with", "⟨", ident i, ",", ident t, ",", ident hit, ",", ident rfl, ",", ident hn, "⟩"] },
  replace [ident hp] [":", expr «expr ∧ »(is_prime (f i), ∀
    x «expr ∈ » t, is_prime (f x))] [":=", expr (t.forall_mem_insert _ _).1 hp],
  by_cases [expr Ht, ":", expr «expr∃ , »((j «expr ∈ » t), «expr ≤ »(f j, f i))],
  { obtain ["⟨", ident j, ",", ident hjt, ",", ident hfji, "⟩", ":", expr «expr∃ , »((j «expr ∈ » t), «expr ≤ »(f j, f i)), ":=", expr Ht],
    obtain ["⟨", ident u, ",", ident hju, ",", ident rfl, "⟩", ":", expr «expr∃ , »((u), «expr ∧ »(«expr ∉ »(j, u), «expr = »(insert j u, t)))],
    { exact [expr ⟨t.erase j, t.not_mem_erase j, finset.insert_erase hjt⟩] },
    have [ident hp'] [":", expr ∀ k «expr ∈ » insert i u, is_prime (f k)] [],
    { rw [expr finset.forall_mem_insert] ["at", ident hp, "⊢"],
      exact [expr ⟨hp.1, hp.2.2⟩] },
    have [ident hiu] [":", expr «expr ∉ »(i, u)] [":=", expr mt finset.mem_insert_of_mem hit],
    have [ident hn'] [":", expr «expr = »((insert i u).card, n)] [],
    { rwa [expr finset.card_insert_of_not_mem] ["at", ident hn, "⊢"],
      exacts ["[", expr hiu, ",", expr hju, "]"] },
    have [ident h'] [":", expr «expr ⊆ »((I : set R), «expr ∪ »(«expr ∪ »(f a, f b), «expr⋃ , »((k «expr ∈ » («expr↑ »(insert i u) : set ι)), f k)))] [],
    { rw [expr finset.coe_insert] ["at", ident h, "⊢"],
      rw [expr finset.coe_insert] ["at", ident h],
      simp [] [] ["only"] ["[", expr set.bUnion_insert, "]"] [] ["at", ident h, "⊢"],
      rw ["[", "<-", expr set.union_assoc «expr↑ »(f i), "]"] ["at", ident h],
      erw ["[", expr set.union_eq_self_of_subset_right hfji, "]"] ["at", ident h],
      exact [expr h] },
    specialize [expr @ih a b (insert i u) hp' hn' h'],
    refine [expr ih.imp id (or.imp id «expr $ »(exists_imp_exists, λ k, _))],
    simp [] [] ["only"] ["[", expr exists_prop, "]"] [] [],
    exact [expr and.imp (λ hk, finset.insert_subset_insert i (finset.subset_insert j u) hk) id] },
  by_cases [expr Ha, ":", expr «expr ≤ »(f a, f i)],
  { have [ident h'] [":", expr «expr ⊆ »((I : set R), «expr ∪ »(«expr ∪ »(f i, f b), «expr⋃ , »((j «expr ∈ » («expr↑ »(t) : set ι)), f j)))] [],
    { rw ["[", expr finset.coe_insert, ",", expr set.bUnion_insert, ",", "<-", expr set.union_assoc, ",", expr set.union_right_comm «expr↑ »(f a), "]"] ["at", ident h],
      erw ["[", expr set.union_eq_self_of_subset_left Ha, "]"] ["at", ident h],
      exact [expr h] },
    specialize [expr @ih i b t hp.2 hn h'],
    right,
    rcases [expr ih, "with", ident ih, "|", ident ih, "|", "⟨", ident k, ",", ident hkt, ",", ident ih, "⟩"],
    { exact [expr or.inr ⟨i, finset.mem_insert_self i t, ih⟩] },
    { exact [expr or.inl ih] },
    { exact [expr or.inr ⟨k, finset.mem_insert_of_mem hkt, ih⟩] } },
  by_cases [expr Hb, ":", expr «expr ≤ »(f b, f i)],
  { have [ident h'] [":", expr «expr ⊆ »((I : set R), «expr ∪ »(«expr ∪ »(f a, f i), «expr⋃ , »((j «expr ∈ » («expr↑ »(t) : set ι)), f j)))] [],
    { rw ["[", expr finset.coe_insert, ",", expr set.bUnion_insert, ",", "<-", expr set.union_assoc, ",", expr set.union_assoc «expr↑ »(f a), "]"] ["at", ident h],
      erw ["[", expr set.union_eq_self_of_subset_left Hb, "]"] ["at", ident h],
      exact [expr h] },
    specialize [expr @ih a i t hp.2 hn h'],
    rcases [expr ih, "with", ident ih, "|", ident ih, "|", "⟨", ident k, ",", ident hkt, ",", ident ih, "⟩"],
    { exact [expr or.inl ih] },
    { exact [expr or.inr (or.inr ⟨i, finset.mem_insert_self i t, ih⟩)] },
    { exact [expr or.inr (or.inr ⟨k, finset.mem_insert_of_mem hkt, ih⟩)] } },
  by_cases [expr Hi, ":", expr «expr ≤ »(I, f i)],
  { exact [expr or.inr (or.inr ⟨i, finset.mem_insert_self i t, Hi⟩)] },
  have [] [":", expr «expr¬ »(«expr ≤ »(«expr ⊓ »(«expr ⊓ »(«expr ⊓ »(I, f a), f b), t.inf f), f i))] [],
  { rcases [expr t.eq_empty_or_nonempty, "with", "(", ident rfl, "|", ident hsne, ")"],
    { rw ["[", expr finset.inf_empty, ",", expr inf_top_eq, ",", expr hp.1.inf_le, ",", expr hp.1.inf_le, ",", expr not_or_distrib, ",", expr not_or_distrib, "]"] [],
      exact [expr ⟨⟨Hi, Ha⟩, Hb⟩] },
    simp [] [] ["only"] ["[", expr hp.1.inf_le, ",", expr hp.1.inf_le' hsne, ",", expr not_or_distrib, "]"] [] [],
    exact [expr ⟨⟨⟨Hi, Ha⟩, Hb⟩, Ht⟩] },
  rcases [expr set.not_subset.1 this, "with", "⟨", ident r, ",", "⟨", "⟨", "⟨", ident hrI, ",", ident hra, "⟩", ",", ident hrb, "⟩", ",", ident hr, "⟩", ",", ident hri, "⟩"],
  by_cases [expr HI, ":", expr «expr ⊆ »((I : set R), «expr ∪ »(«expr ∪ »(f a, f b), «expr⋃ , »((j «expr ∈ » («expr↑ »(t) : set ι)), f j)))],
  { specialize [expr ih hp.2 hn HI],
    rcases [expr ih, "with", ident ih, "|", ident ih, "|", "⟨", ident k, ",", ident hkt, ",", ident ih, "⟩"],
    { left,
      exact [expr ih] },
    { right,
      left,
      exact [expr ih] },
    { right,
      right,
      exact [expr ⟨k, finset.mem_insert_of_mem hkt, ih⟩] } },
  exfalso,
  rcases [expr set.not_subset.1 HI, "with", "⟨", ident s, ",", ident hsI, ",", ident hs, "⟩"],
  rw ["[", expr finset.coe_insert, ",", expr set.bUnion_insert, "]"] ["at", ident h],
  have [ident hsi] [":", expr «expr ∈ »(s, f i)] [":=", expr ((h hsI).resolve_left (mt or.inl hs)).resolve_right (mt or.inr hs)],
  rcases [expr h (I.add_mem hrI hsI), "with", "⟨", ident ha, "|", ident hb, "⟩", "|", ident hi, "|", ident ht],
  { exact [expr hs «expr $ »(or.inl, «expr $ »(or.inl, «expr ▸ »(add_sub_cancel' r s, (f a).sub_mem ha hra)))] },
  { exact [expr hs «expr $ »(or.inl, «expr $ »(or.inr, «expr ▸ »(add_sub_cancel' r s, (f b).sub_mem hb hrb)))] },
  { exact [expr hri «expr ▸ »(add_sub_cancel r s, (f i).sub_mem hi hsi)] },
  { rw [expr set.mem_bUnion_iff] ["at", ident ht],
    rcases [expr ht, "with", "⟨", ident j, ",", ident hjt, ",", ident hj, "⟩"],
    simp [] [] ["only"] ["[", expr finset.inf_eq_infi, ",", expr set_like.mem_coe, ",", expr submodule.mem_infi, "]"] [] ["at", ident hr],
    exact [expr hs «expr $ »(or.inr, «expr $ »(set.mem_bUnion hjt, «expr $ »(«expr ▸ »(add_sub_cancel' r s, (f j).sub_mem hj), hr j hjt)))] }
end

-- error in RingTheory.Ideal.Operations: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Meta.solveByElim'
/-- Prime avoidance. Atiyah-Macdonald 1.11, Eisenbud 3.3, Stacks 00DS, Matsumura Ex.1.6. -/
theorem subset_union_prime
{R : Type u}
[comm_ring R]
{s : finset ι}
{f : ι → ideal R}
(a b : ι)
(hp : ∀ i «expr ∈ » s, «expr ≠ »(i, a) → «expr ≠ »(i, b) → is_prime (f i))
{I : ideal R} : «expr ↔ »(«expr ⊆ »((I : set R), «expr⋃ , »((i «expr ∈ » («expr↑ »(s) : set ι)), f i)), «expr∃ , »((i «expr ∈ » s), «expr ≤ »(I, f i))) :=
suffices «expr ⊆ »((I : set R), «expr⋃ , »((i «expr ∈ » («expr↑ »(s) : set ι)), f i)) → «expr∃ , »((i), «expr ∧ »(«expr ∈ »(i, s), «expr ≤ »(I, f i))), from ⟨λ
 h, «expr $ »(bex_def.2, this h), λ
 ⟨i, his, hi⟩, «expr $ »(set.subset.trans hi, «expr $ »(set.subset_bUnion_of_mem, show «expr ∈ »(i, («expr↑ »(s) : set ι)), from his))⟩,
assume h : «expr ⊆ »((I : set R), «expr⋃ , »((i «expr ∈ » («expr↑ »(s) : set ι)), f i)), begin
  classical,
  tactic.unfreeze_local_instances,
  by_cases [expr has, ":", expr «expr ∈ »(a, s)],
  { obtain ["⟨", ident t, ",", ident hat, ",", ident rfl, "⟩", ":", expr «expr∃ , »((t), «expr ∧ »(«expr ∉ »(a, t), «expr = »(insert a t, s))), ":=", expr ⟨s.erase a, finset.not_mem_erase a s, finset.insert_erase has⟩],
    by_cases [expr hbt, ":", expr «expr ∈ »(b, t)],
    { obtain ["⟨", ident u, ",", ident hbu, ",", ident rfl, "⟩", ":", expr «expr∃ , »((u), «expr ∧ »(«expr ∉ »(b, u), «expr = »(insert b u, t))), ":=", expr ⟨t.erase b, finset.not_mem_erase b t, finset.insert_erase hbt⟩],
      have [ident hp'] [":", expr ∀ i «expr ∈ » u, is_prime (f i)] [],
      { intros [ident i, ident hiu],
        refine [expr hp i (finset.mem_insert_of_mem (finset.mem_insert_of_mem hiu)) _ _]; rintro [ident rfl]; solve_by_elim [] ["only"] ["[", expr finset.mem_insert_of_mem, ",", "*", "]"] [] },
      rw ["[", expr finset.coe_insert, ",", expr finset.coe_insert, ",", expr set.bUnion_insert, ",", expr set.bUnion_insert, ",", "<-", expr set.union_assoc, ",", expr subset_union_prime' hp', ",", expr bex_def, "]"] ["at", ident h],
      rwa ["[", expr finset.exists_mem_insert, ",", expr finset.exists_mem_insert, "]"] [] },
    { have [ident hp'] [":", expr ∀ j «expr ∈ » t, is_prime (f j)] [],
      { intros [ident j, ident hj],
        refine [expr hp j (finset.mem_insert_of_mem hj) _ _]; rintro [ident rfl]; solve_by_elim [] ["only"] ["[", expr finset.mem_insert_of_mem, ",", "*", "]"] [] },
      rw ["[", expr finset.coe_insert, ",", expr set.bUnion_insert, ",", "<-", expr set.union_self (f a : set R), ",", expr subset_union_prime' hp', ",", "<-", expr or_assoc, ",", expr or_self, ",", expr bex_def, "]"] ["at", ident h],
      rwa [expr finset.exists_mem_insert] [] } },
  { by_cases [expr hbs, ":", expr «expr ∈ »(b, s)],
    { obtain ["⟨", ident t, ",", ident hbt, ",", ident rfl, "⟩", ":", expr «expr∃ , »((t), «expr ∧ »(«expr ∉ »(b, t), «expr = »(insert b t, s))), ":=", expr ⟨s.erase b, finset.not_mem_erase b s, finset.insert_erase hbs⟩],
      have [ident hp'] [":", expr ∀ j «expr ∈ » t, is_prime (f j)] [],
      { intros [ident j, ident hj],
        refine [expr hp j (finset.mem_insert_of_mem hj) _ _]; rintro [ident rfl]; solve_by_elim [] ["only"] ["[", expr finset.mem_insert_of_mem, ",", "*", "]"] [] },
      rw ["[", expr finset.coe_insert, ",", expr set.bUnion_insert, ",", "<-", expr set.union_self (f b : set R), ",", expr subset_union_prime' hp', ",", "<-", expr or_assoc, ",", expr or_self, ",", expr bex_def, "]"] ["at", ident h],
      rwa [expr finset.exists_mem_insert] [] },
    cases [expr s.eq_empty_or_nonempty] ["with", ident hse, ident hsne],
    { subst [expr hse],
      rw ["[", expr finset.coe_empty, ",", expr set.bUnion_empty, ",", expr set.subset_empty_iff, "]"] ["at", ident h],
      have [] [":", expr «expr ≠ »((I : set R), «expr∅»())] [":=", expr set.nonempty.ne_empty (set.nonempty_of_mem I.zero_mem)],
      exact [expr absurd h this] },
    { cases [expr hsne.bex] ["with", ident i, ident his],
      obtain ["⟨", ident t, ",", ident hit, ",", ident rfl, "⟩", ":", expr «expr∃ , »((t), «expr ∧ »(«expr ∉ »(i, t), «expr = »(insert i t, s))), ":=", expr ⟨s.erase i, finset.not_mem_erase i s, finset.insert_erase his⟩],
      have [ident hp'] [":", expr ∀ j «expr ∈ » t, is_prime (f j)] [],
      { intros [ident j, ident hj],
        refine [expr hp j (finset.mem_insert_of_mem hj) _ _]; rintro [ident rfl]; solve_by_elim [] ["only"] ["[", expr finset.mem_insert_of_mem, ",", "*", "]"] [] },
      rw ["[", expr finset.coe_insert, ",", expr set.bUnion_insert, ",", "<-", expr set.union_self (f i : set R), ",", expr subset_union_prime' hp', ",", "<-", expr or_assoc, ",", expr or_self, ",", expr bex_def, "]"] ["at", ident h],
      rwa [expr finset.exists_mem_insert] [] } }
end

section Dvd

/-- If `I` divides `J`, then `I` contains `J`.

In a Dedekind domain, to divide and contain are equivalent, see `ideal.dvd_iff_le`.
-/
theorem le_of_dvd {I J : Ideal R} : I ∣ J → J ≤ I
| ⟨K, h⟩ => h.symm ▸ le_transₓ mul_le_inf inf_le_left

theorem is_unit_iff {I : Ideal R} : IsUnit I ↔ I = ⊤ :=
  is_unit_iff_dvd_one.trans
    ((@one_eq_top R _).symm ▸
      ⟨fun h => eq_top_iff.mpr (Ideal.le_of_dvd h),
        fun h =>
          ⟨⊤,
            by 
              rw [mul_top, h]⟩⟩)

instance unique_units : Unique (Units (Ideal R)) :=
  { default := 1,
    uniq :=
      fun u =>
        Units.ext
          (show (u : Ideal R) = 1by 
            rw [is_unit_iff.mp u.is_unit, one_eq_top]) }

end Dvd

end MulAndRadical

section MapAndComap

variable{R : Type u}{S : Type v}

section Semiringₓ

variable[Semiringₓ R][Semiringₓ S]

variable(f : R →+* S)

variable{I J : Ideal R}{K L : Ideal S}

/-- `I.map f` is the span of the image of the ideal `I` under `f`, which may be bigger than
  the image itself. -/
def map (I : Ideal R) : Ideal S :=
  span (f '' I)

/-- `I.comap f` is the preimage of `I` under `f`. -/
def comap (I : Ideal S) : Ideal R :=
  { I.to_add_submonoid.comap (f : R →+ S) with Carrier := f ⁻¹' I,
    smul_mem' :=
      fun c x hx =>
        show f (c*x) ∈ I by 
          rw [f.map_mul]
          exact I.mul_mem_left _ hx }

variable{f}

theorem map_mono (h : I ≤ J) : map f I ≤ map f J :=
  span_mono$ Set.image_subset _ h

theorem mem_map_of_mem (f : R →+* S) {I : Ideal R} {x : R} (h : x ∈ I) : f x ∈ map f I :=
  subset_span ⟨x, h, rfl⟩

theorem apply_coe_mem_map (f : R →+* S) (I : Ideal R) (x : I) : f x ∈ I.map f :=
  mem_map_of_mem f x.prop

theorem map_le_iff_le_comap : map f I ≤ K ↔ I ≤ comap f K :=
  span_le.trans Set.image_subset_iff

@[simp]
theorem mem_comap {x} : x ∈ comap f K ↔ f x ∈ K :=
  Iff.rfl

theorem comap_mono (h : K ≤ L) : comap f K ≤ comap f L :=
  Set.preimage_mono fun x hx => h hx

variable(f)

theorem comap_ne_top (hK : K ≠ ⊤) : comap f K ≠ ⊤ :=
  (ne_top_iff_one _).2$
    by 
      rw [mem_comap, f.map_one] <;> exact (ne_top_iff_one _).1 hK

instance is_prime.comap [hK : K.is_prime] : (comap f K).IsPrime :=
  ⟨comap_ne_top _ hK.1,
    fun x y =>
      by 
        simp only [mem_comap, f.map_mul] <;> apply hK.2⟩

variable(I J K L)

theorem map_top : map f ⊤ = ⊤ :=
  (eq_top_iff_one _).2$ subset_span ⟨1, trivialₓ, f.map_one⟩

variable(f)

theorem gc_map_comap : GaloisConnection (Ideal.map f) (Ideal.comap f) :=
  fun I J => Ideal.map_le_iff_le_comap

@[simp]
theorem comap_id : I.comap (RingHom.id R) = I :=
  Ideal.ext$ fun _ => Iff.rfl

@[simp]
theorem map_id : I.map (RingHom.id R) = I :=
  (gc_map_comap (RingHom.id R)).l_unique GaloisConnection.id comap_id

theorem comap_comap {T : Type _} [Semiringₓ T] {I : Ideal T} (f : R →+* S) (g : S →+* T) :
  (I.comap g).comap f = I.comap (g.comp f) :=
  rfl

theorem map_map {T : Type _} [Semiringₓ T] {I : Ideal R} (f : R →+* S) (g : S →+* T) :
  (I.map f).map g = I.map (g.comp f) :=
  ((gc_map_comap f).compose (gc_map_comap g)).l_unique (gc_map_comap (g.comp f)) fun _ => comap_comap _ _

theorem map_span (f : R →+* S) (s : Set R) : map f (span s) = span (f '' s) :=
  symm$
    Submodule.span_eq_of_le _ (fun y ⟨x, hy, x_eq⟩ => x_eq ▸ mem_map_of_mem f (subset_span hy))
      (map_le_iff_le_comap.2$ span_le.2$ Set.image_subset_iff.1 subset_span)

variable{f I J K L}

theorem map_le_of_le_comap : I ≤ K.comap f → I.map f ≤ K :=
  (gc_map_comap f).l_le

theorem le_comap_of_map_le : I.map f ≤ K → I ≤ K.comap f :=
  (gc_map_comap f).le_u

theorem le_comap_map : I ≤ (I.map f).comap f :=
  (gc_map_comap f).le_u_l _

theorem map_comap_le : (K.comap f).map f ≤ K :=
  (gc_map_comap f).l_u_le _

@[simp]
theorem comap_top : (⊤ : Ideal S).comap f = ⊤ :=
  (gc_map_comap f).u_top

@[simp]
theorem comap_eq_top_iff {I : Ideal S} : I.comap f = ⊤ ↔ I = ⊤ :=
  ⟨fun h => I.eq_top_iff_one.mpr (f.map_one ▸ mem_comap.mp ((I.comap f).eq_top_iff_one.mp h)),
    fun h =>
      by 
        rw [h, comap_top]⟩

@[simp]
theorem map_bot : (⊥ : Ideal R).map f = ⊥ :=
  (gc_map_comap f).l_bot

variable(f I J K L)

@[simp]
theorem map_comap_map : ((I.map f).comap f).map f = I.map f :=
  (gc_map_comap f).l_u_l_eq_l I

@[simp]
theorem comap_map_comap : ((K.comap f).map f).comap f = K.comap f :=
  (gc_map_comap f).u_l_u_eq_u K

theorem map_sup : (I⊔J).map f = I.map f⊔J.map f :=
  (gc_map_comap f).l_sup

theorem comap_inf : comap f (K⊓L) = comap f K⊓comap f L :=
  rfl

variable{ι : Sort _}

theorem map_supr (K : ι → Ideal R) : (supr K).map f = ⨆i, (K i).map f :=
  (gc_map_comap f).l_supr

theorem comap_infi (K : ι → Ideal S) : (infi K).comap f = ⨅i, (K i).comap f :=
  (gc_map_comap f).u_infi

theorem map_Sup (s : Set (Ideal R)) : (Sup s).map f = ⨆(I : _)(_ : I ∈ s), (I : Ideal R).map f :=
  (gc_map_comap f).l_Sup

theorem comap_Inf (s : Set (Ideal S)) : (Inf s).comap f = ⨅(I : _)(_ : I ∈ s), (I : Ideal S).comap f :=
  (gc_map_comap f).u_Inf

theorem comap_Inf' (s : Set (Ideal S)) : (Inf s).comap f = ⨅(I : _)(_ : I ∈ comap f '' s), I :=
  trans (comap_Inf f s)
    (by 
      rw [infi_image])

theorem comap_is_prime [H : is_prime K] : is_prime (comap f K) :=
  ⟨comap_ne_top f H.ne_top,
    fun x y h =>
      H.mem_or_mem$
        by 
          rwa [mem_comap, RingHom.map_mul] at h⟩

variable{I J K L}

theorem map_inf_le : map f (I⊓J) ≤ map f I⊓map f J :=
  (gc_map_comap f).monotone_l.map_inf_le _ _

theorem le_comap_sup : comap f K⊔comap f L ≤ comap f (K⊔L) :=
  (gc_map_comap f).monotone_u.le_map_sup _ _

section Surjective

variable(hf : Function.Surjective f)

include hf

open Function

theorem map_comap_of_surjective (I : Ideal S) : map f (comap f I) = I :=
  le_antisymmₓ (map_le_iff_le_comap.2 (le_reflₓ _))
    fun s hsi =>
      let ⟨r, hfrs⟩ := hf s 
      hfrs ▸ (mem_map_of_mem f$ show f r ∈ I from hfrs.symm ▸ hsi)

/-- `map` and `comap` are adjoint, and the composition `map f ∘ comap f` is the
  identity -/
def gi_map_comap : GaloisInsertion (map f) (comap f) :=
  GaloisInsertion.monotoneIntro (gc_map_comap f).monotone_u (gc_map_comap f).monotone_l (fun _ => le_comap_map)
    (map_comap_of_surjective _ hf)

theorem map_surjective_of_surjective : surjective (map f) :=
  (gi_map_comap f hf).l_surjective

theorem comap_injective_of_surjective : injective (comap f) :=
  (gi_map_comap f hf).u_injective

theorem map_sup_comap_of_surjective (I J : Ideal S) : (I.comap f⊔J.comap f).map f = I⊔J :=
  (gi_map_comap f hf).l_sup_u _ _

theorem map_supr_comap_of_surjective (K : ι → Ideal S) : (⨆i, (K i).comap f).map f = supr K :=
  (gi_map_comap f hf).l_supr_u _

theorem map_inf_comap_of_surjective (I J : Ideal S) : (I.comap f⊓J.comap f).map f = I⊓J :=
  (gi_map_comap f hf).l_inf_u _ _

theorem map_infi_comap_of_surjective (K : ι → Ideal S) : (⨅i, (K i).comap f).map f = infi K :=
  (gi_map_comap f hf).l_infi_u _

theorem mem_image_of_mem_map_of_surjective {I : Ideal R} {y} (H : y ∈ map f I) : y ∈ f '' I :=
  Submodule.span_induction H (fun _ => id) ⟨0, I.zero_mem, f.map_zero⟩
    (fun y1 y2 ⟨x1, hx1i, hxy1⟩ ⟨x2, hx2i, hxy2⟩ => ⟨x1+x2, I.add_mem hx1i hx2i, hxy1 ▸ hxy2 ▸ f.map_add _ _⟩)
    fun c y ⟨x, hxi, hxy⟩ =>
      let ⟨d, hdc⟩ := hf c
      ⟨d • x, I.smul_mem _ hxi, hdc ▸ hxy ▸ f.map_mul _ _⟩

theorem mem_map_iff_of_surjective {I : Ideal R} {y} : y ∈ map f I ↔ ∃ x, x ∈ I ∧ f x = y :=
  ⟨fun h => (Set.mem_image _ _ _).2 (mem_image_of_mem_map_of_surjective f hf h),
    fun ⟨x, hx⟩ => hx.right ▸ mem_map_of_mem f hx.left⟩

theorem le_map_of_comap_le_of_surjective : comap f K ≤ I → K ≤ map f I :=
  fun h => map_comap_of_surjective f hf K ▸ map_mono h

end Surjective

section Injective

variable(hf : Function.Injective f)

include hf

theorem comap_bot_le_of_injective : comap f ⊥ ≤ I :=
  by 
    refine' le_transₓ (fun x hx => _) bot_le 
    rw [mem_comap, Submodule.mem_bot, ←RingHom.map_zero f] at hx 
    exact Eq.symm (hf hx) ▸ Submodule.zero_mem ⊥

end Injective

end Semiringₓ

section Ringₓ

variable[Ringₓ R][Ringₓ S](f : R →+* S){I : Ideal R}

section Surjective

variable(hf : Function.Surjective f)

include hf

theorem comap_map_of_surjective (I : Ideal R) : comap f (map f I) = I⊔comap f ⊥ :=
  le_antisymmₓ
    (fun r h =>
      let ⟨s, hsi, hfsr⟩ := mem_image_of_mem_map_of_surjective f hf h 
      Submodule.mem_sup.2
        ⟨s, hsi, r - s,
          (Submodule.mem_bot S).2$
            by 
              rw [f.map_sub, hfsr, sub_self],
          add_sub_cancel'_right s r⟩)
    (sup_le (map_le_iff_le_comap.1 (le_reflₓ _)) (comap_mono bot_le))

/-- Correspondence theorem -/
def rel_iso_of_surjective : Ideal S ≃o { p : Ideal R // comap f ⊥ ≤ p } :=
  { toFun := fun J => ⟨comap f J, comap_mono bot_le⟩, invFun := fun I => map f I.1,
    left_inv := fun J => map_comap_of_surjective f hf J,
    right_inv :=
      fun I =>
        Subtype.eq$
          show comap f (map f I.1) = I.1 from
            (comap_map_of_surjective f hf I).symm ▸ le_antisymmₓ (sup_le (le_reflₓ _) I.2) le_sup_left,
    map_rel_iff' :=
      fun I1 I2 =>
        ⟨fun H => map_comap_of_surjective f hf I1 ▸ map_comap_of_surjective f hf I2 ▸ map_mono H, comap_mono⟩ }

/-- The map on ideals induced by a surjective map preserves inclusion. -/
def order_embedding_of_surjective : Ideal S ↪o Ideal R :=
  (rel_iso_of_surjective f hf).toRelEmbedding.trans (Subtype.relEmbedding _ _)

theorem map_eq_top_or_is_maximal_of_surjective {I : Ideal R} (H : is_maximal I) : map f I = ⊤ ∨ is_maximal (map f I) :=
  by 
    refine' or_iff_not_imp_left.2 fun ne_top => ⟨⟨fun h => ne_top h, fun J hJ => _⟩⟩
    ·
      refine'
        (rel_iso_of_surjective f hf).Injective
          (Subtype.ext_iff.2 (Eq.trans (H.1.2 (comap f J) (lt_of_le_of_neₓ _ _)) comap_top.symm))
      ·
        exact map_le_iff_le_comap.1 (le_of_ltₓ hJ)
      ·
        exact fun h => hJ.right (le_map_of_comap_le_of_surjective f hf (le_of_eqₓ h.symm))

theorem comap_is_maximal_of_surjective {K : Ideal S} [H : is_maximal K] : is_maximal (comap f K) :=
  by 
    refine' ⟨⟨comap_ne_top _ H.1.1, fun J hJ => _⟩⟩
    suffices  : map f J = ⊤
    ·
      replace this := congr_argₓ (comap f) this 
      rw [comap_top, comap_map_of_surjective _ hf, eq_top_iff] at this 
      rw [eq_top_iff]
      exact le_transₓ this (sup_le (le_of_eqₓ rfl) (le_transₓ (comap_mono bot_le) (le_of_ltₓ hJ)))
    refine'
      H.1.2 (map f J)
        (lt_of_le_of_neₓ (le_map_of_comap_le_of_surjective _ hf (le_of_ltₓ hJ))
          fun h => ne_of_ltₓ hJ (trans (congr_argₓ (comap f) h) _))
    rw [comap_map_of_surjective _ hf, sup_eq_left]
    exact le_transₓ (comap_mono bot_le) (le_of_ltₓ hJ)

end Surjective

/-- If `f : R ≃+* S` is a ring isomorphism and `I : ideal R`, then `map f (map f.symm) = I`. -/
@[simp]
theorem map_of_equiv (I : Ideal R) (f : R ≃+* S) : (I.map (f : R →+* S)).map (f.symm : S →+* R) = I :=
  by 
    simp [←RingEquiv.to_ring_hom_eq_coe, map_map]

/-- If `f : R ≃+* S` is a ring isomorphism and `I : ideal R`, then `comap f.symm (comap f) = I`. -/
@[simp]
theorem comap_of_equiv (I : Ideal R) (f : R ≃+* S) : (I.comap (f.symm : S →+* R)).comap (f : R →+* S) = I :=
  by 
    simp [←RingEquiv.to_ring_hom_eq_coe, comap_comap]

/-- If `f : R ≃+* S` is a ring isomorphism and `I : ideal R`, then `map f I = comap f.symm I`. -/
theorem map_comap_of_equiv (I : Ideal R) (f : R ≃+* S) : I.map (f : R →+* S) = I.comap f.symm :=
  le_antisymmₓ (le_comap_of_map_le (map_of_equiv I f).le)
    (le_map_of_comap_le_of_surjective _ f.surjective (comap_of_equiv I f).le)

section Bijective

variable(hf : Function.Bijective f)

include hf

/-- Special case of the correspondence theorem for isomorphic rings -/
def rel_iso_of_bijective : Ideal S ≃o Ideal R :=
  { toFun := comap f, invFun := map f, left_inv := (rel_iso_of_surjective f hf.right).left_inv,
    right_inv :=
      fun J =>
        Subtype.ext_iff.1 ((rel_iso_of_surjective f hf.right).right_inv ⟨J, comap_bot_le_of_injective f hf.left⟩),
    map_rel_iff' := (rel_iso_of_surjective f hf.right).map_rel_iff' }

theorem comap_le_iff_le_map {I : Ideal R} {K : Ideal S} : comap f K ≤ I ↔ K ≤ map f I :=
  ⟨fun h => le_map_of_comap_le_of_surjective f hf.right h,
    fun h => (rel_iso_of_bijective f hf).right_inv I ▸ comap_mono h⟩

theorem map.is_maximal {I : Ideal R} (H : is_maximal I) : is_maximal (map f I) :=
  by 
    refine' or_iff_not_imp_left.1 (map_eq_top_or_is_maximal_of_surjective f hf.right H) fun h => H.1.1 _ <;>
      calc I = comap f (map f I) := ((rel_iso_of_bijective f hf).right_inv I).symm _ = comap f ⊤ :=
        by 
          rw [h]_ = ⊤ :=
        by 
          rw [comap_top]

end Bijective

theorem ring_equiv.bot_maximal_iff (e : R ≃+* S) : (⊥ : Ideal R).IsMaximal ↔ (⊥ : Ideal S).IsMaximal :=
  ⟨fun h => @map_bot _ _ _ _ e.to_ring_hom ▸ map.is_maximal e.to_ring_hom e.bijective h,
    fun h => @map_bot _ _ _ _ e.symm.to_ring_hom ▸ map.is_maximal e.symm.to_ring_hom e.symm.bijective h⟩

end Ringₓ

section CommRingₓ

variable[CommRingₓ R][CommRingₓ S]

variable(f : R →+* S)

variable{I J : Ideal R}{K L : Ideal S}

theorem mem_quotient_iff_mem (hIJ : I ≤ J) {x : R} : Quotientₓ.mk I x ∈ J.map (Quotientₓ.mk I) ↔ x ∈ J :=
  by 
    refine' Iff.trans (mem_map_iff_of_surjective _ quotient.mk_surjective) _ 
    split 
    ·
      rintro ⟨x, x_mem, x_eq⟩
      simpa using J.add_mem (hIJ (quotient.eq.mp x_eq.symm)) x_mem
    ·
      intro x_mem 
      exact ⟨x, x_mem, rfl⟩

variable(I J K L)

theorem map_mul : map f (I*J) = map f I*map f J :=
  le_antisymmₓ
    (map_le_iff_le_comap.2$
      mul_le.2$
        fun r hri s hsj =>
          show f (r*s) ∈ _ by 
            rw [f.map_mul] <;> exact mul_mem_mul (mem_map_of_mem f hri) (mem_map_of_mem f hsj))
    (trans_rel_right _ (span_mul_span _ _)$
      span_le.2$
        Set.bUnion_subset$
          fun i ⟨r, hri, hfri⟩ =>
            Set.bUnion_subset$
              fun j ⟨s, hsj, hfsj⟩ =>
                Set.singleton_subset_iff.2$
                  hfri ▸
                    hfsj ▸
                      by 
                        rw [←f.map_mul] <;> exact mem_map_of_mem f (mul_mem_mul hri hsj))

theorem comap_radical : comap f (radical K) = radical (comap f K) :=
  le_antisymmₓ (fun r ⟨n, hfrnk⟩ => ⟨n, show f (r ^ n) ∈ K from (f.map_pow r n).symm ▸ hfrnk⟩)
    fun r ⟨n, hfrnk⟩ => ⟨n, f.map_pow r n ▸ hfrnk⟩

@[simp]
theorem map_quotient_self : map (Quotientₓ.mk I) I = ⊥ :=
  eq_bot_iff.2$
    Ideal.map_le_iff_le_comap.2$ fun x hx => (Submodule.mem_bot I.quotient).2$ Ideal.Quotient.eq_zero_iff_mem.2 hx

variable{I J K L}

theorem map_radical_le : map f (radical I) ≤ radical (map f I) :=
  map_le_iff_le_comap.2$ fun r ⟨n, hrni⟩ => ⟨n, f.map_pow r n ▸ mem_map_of_mem f hrni⟩

theorem le_comap_mul : (comap f K*comap f L) ≤ comap f (K*L) :=
  map_le_iff_le_comap.1$
    (map_mul f (comap f K) (comap f L)).symm ▸
      mul_mono (map_le_iff_le_comap.2$ le_reflₓ _) (map_le_iff_le_comap.2$ le_reflₓ _)

end CommRingₓ

end MapAndComap

section IsPrimary

variable{R : Type u}[CommSemiringₓ R]

/-- A proper ideal `I` is primary iff `xy ∈ I` implies `x ∈ I` or `y ∈ radical I`. -/
def is_primary (I : Ideal R) : Prop :=
  I ≠ ⊤ ∧ ∀ {x y : R}, (x*y) ∈ I → x ∈ I ∨ y ∈ radical I

theorem is_primary.to_is_prime (I : Ideal R) (hi : is_prime I) : is_primary I :=
  ⟨hi.1, fun x y hxy => (hi.mem_or_mem hxy).imp id$ fun hyi => le_radical hyi⟩

theorem mem_radical_of_pow_mem {I : Ideal R} {x : R} {m : ℕ} (hx : x ^ m ∈ radical I) : x ∈ radical I :=
  radical_idem I ▸ ⟨m, hx⟩

theorem is_prime_radical {I : Ideal R} (hi : is_primary I) : is_prime (radical I) :=
  ⟨mt radical_eq_top.1 hi.1,
    fun x y ⟨m, hxy⟩ =>
      by 
        rw [mul_powₓ] at hxy 
        cases hi.2 hxy
        ·
          exact Or.inl ⟨m, h⟩
        ·
          exact Or.inr (mem_radical_of_pow_mem h)⟩

theorem is_primary_inf {I J : Ideal R} (hi : is_primary I) (hj : is_primary J) (hij : radical I = radical J) :
  is_primary (I⊓J) :=
  ⟨ne_of_ltₓ$ lt_of_le_of_ltₓ inf_le_left (lt_top_iff_ne_top.2 hi.1),
    fun x y ⟨hxyi, hxyj⟩ =>
      by 
        rw [radical_inf, hij, inf_idem]
        cases' hi.2 hxyi with hxi hyi 
        cases' hj.2 hxyj with hxj hyj
        ·
          exact Or.inl ⟨hxi, hxj⟩
        ·
          exact Or.inr hyj
        ·
          rw [hij] at hyi 
          exact Or.inr hyi⟩

end IsPrimary

end Ideal

namespace RingHom

variable{R : Type u}{S : Type v}

section Semiringₓ

variable[Semiringₓ R][Semiringₓ S](f : R →+* S)

/-- Kernel of a ring homomorphism as an ideal of the domain. -/
def ker : Ideal R :=
  Ideal.comap f ⊥

/-- An element is in the kernel if and only if it maps to zero.-/
theorem mem_ker {r} : r ∈ ker f ↔ f r = 0 :=
  by 
    rw [ker, Ideal.mem_comap, Submodule.mem_bot]

theorem ker_eq : (ker f : Set R) = Set.Preimage f {0} :=
  rfl

theorem ker_eq_comap_bot (f : R →+* S) : f.ker = Ideal.comap f ⊥ :=
  rfl

/-- If the target is not the zero ring, then one is not in the kernel.-/
theorem not_one_mem_ker [Nontrivial S] (f : R →+* S) : (1 : R) ∉ ker f :=
  by 
    rw [mem_ker, f.map_one]
    exact one_ne_zero

end Semiringₓ

section Ringₓ

variable[Ringₓ R][Semiringₓ S](f : R →+* S)

theorem injective_iff_ker_eq_bot : Function.Injective f ↔ ker f = ⊥ :=
  by 
    rw [SetLike.ext'_iff, ker_eq, Set.ext_iff]
    exact f.injective_iff'

theorem ker_eq_bot_iff_eq_zero : ker f = ⊥ ↔ ∀ x, f x = 0 → x = 0 :=
  by 
    rw [←f.injective_iff, injective_iff_ker_eq_bot]

@[simp]
theorem ker_coe_equiv (f : R ≃+* S) : ker (f : R →+* S) = ⊥ :=
  by 
    simpa only [←injective_iff_ker_eq_bot] using f.injective

end Ringₓ

section CommRingₓ

variable[CommRingₓ R][CommRingₓ S](f : R →+* S)

/-- The induced map from the quotient by the kernel to the codomain.

This is an isomorphism if `f` has a right inverse (`quotient_ker_equiv_of_right_inverse`) /
is surjective (`quotient_ker_equiv_of_surjective`).
-/
def ker_lift (f : R →+* S) : f.ker.quotient →+* S :=
  Ideal.Quotient.lift _ f$ fun r => f.mem_ker.mp

@[simp]
theorem ker_lift_mk (f : R →+* S) (r : R) : ker_lift f (Ideal.Quotient.mk f.ker r) = f r :=
  Ideal.Quotient.lift_mk _ _ _

-- error in RingTheory.Ideal.Operations: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The induced map from the quotient by the kernel is injective. -/
theorem ker_lift_injective (f : «expr →+* »(R, S)) : function.injective (ker_lift f) :=
assume
a
b, «expr $ »(quotient.induction_on₂' a b, assume
 (a b)
 (h : «expr = »(f a, f b)), «expr $ »(quotient.sound', show «expr ∈ »(«expr - »(a, b), ker f), by rw ["[", expr mem_ker, ",", expr map_sub, ",", expr h, ",", expr sub_self, "]"] []))

variable{f}

/-- The **first isomorphism theorem** for commutative rings, computable version. -/
def quotient_ker_equiv_of_right_inverse {g : S → R} (hf : Function.RightInverse g f) : f.ker.quotient ≃+* S :=
  { ker_lift f with toFun := ker_lift f, invFun := Ideal.Quotient.mk f.ker ∘ g,
    left_inv :=
      by 
        rintro ⟨x⟩
        apply ker_lift_injective 
        simp [hf (f x)],
    right_inv := hf }

@[simp]
theorem quotient_ker_equiv_of_right_inverse.apply {g : S → R} (hf : Function.RightInverse g f) (x : f.ker.quotient) :
  quotient_ker_equiv_of_right_inverse hf x = ker_lift f x :=
  rfl

@[simp]
theorem quotient_ker_equiv_of_right_inverse.symm.apply {g : S → R} (hf : Function.RightInverse g f) (x : S) :
  (quotient_ker_equiv_of_right_inverse hf).symm x = Ideal.Quotient.mk f.ker (g x) :=
  rfl

/-- The **first isomorphism theorem** for commutative rings. -/
noncomputable def quotient_ker_equiv_of_surjective (hf : Function.Surjective f) : f.ker.quotient ≃+* S :=
  quotient_ker_equiv_of_right_inverse (Classical.some_spec hf.has_right_inverse)

end CommRingₓ

/-- The kernel of a homomorphism to a domain is a prime ideal. -/
theorem ker_is_prime [Ringₓ R] [Ringₓ S] [IsDomain S] (f : R →+* S) : (ker f).IsPrime :=
  ⟨by 
      rw [Ne.def, Ideal.eq_top_iff_one]
      exact not_one_mem_ker f,
    fun x y =>
      by 
        simpa only [mem_ker, f.map_mul] using @eq_zero_or_eq_zero_of_mul_eq_zero S _ _ _ _ _⟩

-- error in RingTheory.Ideal.Operations: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The kernel of a homomorphism to a field is a maximal ideal. -/
theorem ker_is_maximal_of_surjective
{R K : Type*}
[ring R]
[field K]
(f : «expr →+* »(R, K))
(hf : function.surjective f) : f.ker.is_maximal :=
begin
  refine [expr ideal.is_maximal_iff.mpr ⟨λ
    h1, «expr $ »(@one_ne_zero K _ _, «expr ▸ »(f.map_one, f.mem_ker.mp h1)), λ J x hJ hxf hxJ, _⟩],
  obtain ["⟨", ident y, ",", ident hy, "⟩", ":=", expr hf «expr ⁻¹»(f x)],
  have [ident H] [":", expr «expr = »(1, «expr - »(«expr * »(y, x), «expr - »(«expr * »(y, x), 1)))] [":=", expr (sub_sub_cancel _ _).symm],
  rw [expr H] [],
  refine [expr J.sub_mem (J.mul_mem_left _ hxJ) (hJ _)],
  rw [expr f.mem_ker] [],
  simp [] [] ["only"] ["[", expr hy, ",", expr ring_hom.map_sub, ",", expr ring_hom.map_one, ",", expr ring_hom.map_mul, ",", expr inv_mul_cancel (mt f.mem_ker.mpr hxf), ",", expr sub_self, "]"] [] []
end

end RingHom

namespace Ideal

variable{R : Type _}{S : Type _}

section Semiringₓ

variable[Semiringₓ R][Semiringₓ S]

theorem map_eq_bot_iff_le_ker {I : Ideal R} (f : R →+* S) : I.map f = ⊥ ↔ I ≤ f.ker :=
  by 
    rw [RingHom.ker, eq_bot_iff, map_le_iff_le_comap]

theorem ker_le_comap {K : Ideal S} (f : R →+* S) : f.ker ≤ comap f K :=
  fun x hx => mem_comap.2 (((RingHom.mem_ker f).1 hx).symm ▸ K.zero_mem)

end Semiringₓ

section Ringₓ

variable[Ringₓ R][Ringₓ S]

-- error in RingTheory.Ideal.Operations: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem map_Inf
{A : set (ideal R)}
{f : «expr →+* »(R, S)}
(hf : function.surjective f) : ∀
J «expr ∈ » A, «expr ≤ »(ring_hom.ker f, J) → «expr = »(map f (Inf A), Inf «expr '' »(map f, A)) :=
begin
  refine [expr λ h, le_antisymm (le_Inf _) _],
  { intros [ident j, ident hj, ident y, ident hy],
    cases [expr (mem_map_iff_of_surjective f hf).1 hy] ["with", ident x, ident hx],
    cases [expr (set.mem_image _ _ _).mp hj] ["with", ident J, ident hJ],
    rw ["[", "<-", expr hJ.right, ",", "<-", expr hx.right, "]"] [],
    exact [expr mem_map_of_mem f (Inf_le_of_le hJ.left (le_of_eq rfl) hx.left)] },
  { intros [ident y, ident hy],
    cases [expr hf y] ["with", ident x, ident hx],
    refine [expr «expr ▸ »(hx, mem_map_of_mem f _)],
    have [] [":", expr ∀ I «expr ∈ » A, «expr ∈ »(y, map f I)] [],
    by simpa [] [] [] [] [] ["using", expr hy],
    rw ["[", expr submodule.mem_Inf, "]"] [],
    intros [ident J, ident hJ],
    rcases [expr (mem_map_iff_of_surjective f hf).1 (this J hJ), "with", "⟨", ident x', ",", ident hx', ",", ident rfl, "⟩"],
    have [] [":", expr «expr ∈ »(«expr - »(x, x'), J)] [],
    { apply [expr h J hJ],
      rw ["[", expr ring_hom.mem_ker, ",", expr ring_hom.map_sub, ",", expr hx, ",", expr sub_self, "]"] [] },
    simpa [] [] ["only"] ["[", expr sub_add_cancel, "]"] [] ["using", expr J.add_mem this hx'] }
end

-- error in RingTheory.Ideal.Operations: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem map_is_prime_of_surjective
{f : «expr →+* »(R, S)}
(hf : function.surjective f)
{I : ideal R}
[H : is_prime I]
(hk : «expr ≤ »(ring_hom.ker f, I)) : is_prime (map f I) :=
begin
  refine [expr ⟨λ h, H.ne_top (eq_top_iff.2 _), λ x y, _⟩],
  { replace [ident h] [] [":=", expr congr_arg (comap f) h],
    rw ["[", expr comap_map_of_surjective _ hf, ",", expr comap_top, "]"] ["at", ident h],
    exact [expr «expr ▸ »(h, sup_le (le_of_eq rfl) hk)] },
  { refine [expr λ hxy, (hf x).rec_on (λ a ha, (hf y).rec_on (λ b hb, _))],
    rw ["[", "<-", expr ha, ",", "<-", expr hb, ",", "<-", expr ring_hom.map_mul, ",", expr mem_map_iff_of_surjective _ hf, "]"] ["at", ident hxy],
    rcases [expr hxy, "with", "⟨", ident c, ",", ident hc, ",", ident hc', "⟩"],
    rw ["[", "<-", expr sub_eq_zero, ",", "<-", expr ring_hom.map_sub, "]"] ["at", ident hc'],
    have [] [":", expr «expr ∈ »(«expr * »(a, b), I)] [],
    { convert [] [expr I.sub_mem hc (hk (hc' : «expr ∈ »(«expr - »(c, «expr * »(a, b)), f.ker)))] [],
      abel [] [] [] },
    exact [expr (H.mem_or_mem this).imp (λ
      h, «expr ▸ »(ha, mem_map_of_mem f h)) (λ h, «expr ▸ »(hb, mem_map_of_mem f h))] }
end

theorem map_is_prime_of_equiv (f : R ≃+* S) {I : Ideal R} [is_prime I] : is_prime (map (f : R →+* S) I) :=
  map_is_prime_of_surjective f.surjective$
    by 
      simp 

end Ringₓ

section CommRingₓ

variable[CommRingₓ R][CommRingₓ S]

@[simp]
theorem mk_ker {I : Ideal R} : (Quotientₓ.mk I).ker = I :=
  by 
    ext <;> rw [RingHom.ker, mem_comap, Submodule.mem_bot, quotient.eq_zero_iff_mem]

theorem map_mk_eq_bot_of_le {I J : Ideal R} (h : I ≤ J) : I.map J = ⊥ :=
  by 
    rw [map_eq_bot_iff_le_ker, mk_ker]
    exact h

theorem ker_quotient_lift {S : Type v} [CommRingₓ S] {I : Ideal R} (f : R →+* S) (H : I ≤ f.ker) :
  (Ideal.Quotient.lift I f H).ker = f.ker.map I :=
  by 
    ext x 
    split 
    ·
      intro hx 
      obtain ⟨y, hy⟩ := quotient.mk_surjective x 
      rw [RingHom.mem_ker, ←hy, Ideal.Quotient.lift_mk, ←RingHom.mem_ker] at hx 
      rw [←hy, mem_map_iff_of_surjective I quotient.mk_surjective]
      exact ⟨y, hx, rfl⟩
    ·
      intro hx 
      rw [mem_map_iff_of_surjective I quotient.mk_surjective] at hx 
      obtain ⟨y, hy⟩ := hx 
      rw [RingHom.mem_ker, ←hy.right, Ideal.Quotient.lift_mk, ←RingHom.mem_ker f]
      exact hy.left

theorem map_eq_iff_sup_ker_eq_of_surjective {I J : Ideal R} (f : R →+* S) (hf : Function.Surjective f) :
  map f I = map f J ↔ I⊔f.ker = J⊔f.ker :=
  by 
    rw [←(comap_injective_of_surjective f hf).eq_iff, comap_map_of_surjective f hf, comap_map_of_surjective f hf,
      RingHom.ker_eq_comap_bot]

-- error in RingTheory.Ideal.Operations: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem map_radical_of_surjective
{f : «expr →+* »(R, S)}
(hf : function.surjective f)
{I : ideal R}
(h : «expr ≤ »(ring_hom.ker f, I)) : «expr = »(map f I.radical, (map f I).radical) :=
begin
  rw ["[", expr radical_eq_Inf, ",", expr radical_eq_Inf, "]"] [],
  have [] [":", expr ∀
   J «expr ∈ » {J : ideal R | «expr ∧ »(«expr ≤ »(I, J), J.is_prime)}, «expr ≤ »(f.ker, J)] [":=", expr λ
   J hJ, le_trans h hJ.left],
  convert [] [expr map_Inf hf this] [],
  refine [expr funext (λ j, propext ⟨_, _⟩)],
  { rintros ["⟨", ident hj, ",", ident hj', "⟩"],
    haveI [] [":", expr j.is_prime] [":=", expr hj'],
    exact [expr ⟨comap f j, ⟨⟨map_le_iff_le_comap.1 hj, comap_is_prime f j⟩, map_comap_of_surjective f hf j⟩⟩] },
  { rintro ["⟨", ident J, ",", "⟨", ident hJ, ",", ident hJ', "⟩", "⟩"],
    haveI [] [":", expr J.is_prime] [":=", expr hJ.right],
    refine [expr ⟨«expr ▸ »(hJ', map_mono hJ.left), «expr ▸ »(hJ', map_is_prime_of_surjective hf (le_trans h hJ.left))⟩] }
end

@[simp]
theorem bot_quotient_is_maximal_iff (I : Ideal R) : (⊥ : Ideal I.quotient).IsMaximal ↔ I.is_maximal :=
  ⟨fun hI => @mk_ker _ _ I ▸ @comap_is_maximal_of_surjective _ _ _ _ (Quotientₓ.mk I) quotient.mk_surjective ⊥ hI,
    fun hI => @bot_is_maximal _ (@Field.toDivisionRing _ (@quotient.field _ _ I hI))⟩

section QuotientAlgebra

variable(R₁ R₂ : Type _){A B : Type _}

variable[CommSemiringₓ R₁][CommSemiringₓ R₂][CommRingₓ A][CommRingₓ B]

variable[Algebra R₁ A][Algebra R₂ A][Algebra R₁ B]

/-- The `R₁`-algebra structure on `A/I` for an `R₁`-algebra `A` -/
instance  {I : Ideal A} : Algebra R₁ (Ideal.Quotient I) :=
  { RingHom.comp (Ideal.Quotient.mk I) (algebraMap R₁ A) with toFun := fun x => Ideal.Quotient.mk I (algebraMap R₁ A x),
    smul := · • ·,
    smul_def' :=
      fun r x =>
        Quotientₓ.induction_on' x$
          fun x => ((Quotientₓ.mk I).congr_arg$ Algebra.smul_def _ _).trans (RingHom.map_mul _ _ _),
    commutes' := fun _ _ => mul_commₓ _ _ }

instance  [HasScalar R₁ R₂] [IsScalarTower R₁ R₂ A] (I : Ideal A) : IsScalarTower R₁ R₂ (Ideal.Quotient I) :=
  by 
    infer_instance

/-- The canonical morphism `A →ₐ[R₁] I.quotient` as morphism of `R₁`-algebras, for `I` an ideal of
`A`, where `A` is an `R₁`-algebra. -/
def quotient.mkₐ (I : Ideal A) : A →ₐ[R₁] I.quotient :=
  ⟨fun a => Submodule.Quotient.mk a, rfl, fun _ _ => rfl, rfl, fun _ _ => rfl, fun _ => rfl⟩

theorem quotient.alg_map_eq (I : Ideal A) :
  algebraMap R₁ I.quotient = (algebraMap A I.quotient).comp (algebraMap R₁ A) :=
  rfl

theorem quotient.mkₐ_to_ring_hom (I : Ideal A) : (quotient.mkₐ R₁ I).toRingHom = Ideal.Quotient.mk I :=
  rfl

@[simp]
theorem quotient.mkₐ_eq_mk (I : Ideal A) : «expr⇑ » (quotient.mkₐ R₁ I) = Ideal.Quotient.mk I :=
  rfl

@[simp]
theorem quotient.algebra_map_eq (I : Ideal R) : algebraMap R I.quotient = I :=
  rfl

@[simp]
theorem quotient.mk_comp_algebra_map (I : Ideal A) :
  (Quotientₓ.mk I).comp (algebraMap R₁ A) = algebraMap R₁ I.quotient :=
  rfl

@[simp]
theorem quotient.mk_algebra_map (I : Ideal A) (x : R₁) :
  Quotientₓ.mk I (algebraMap R₁ A x) = algebraMap R₁ I.quotient x :=
  rfl

/-- The canonical morphism `A →ₐ[R₁] I.quotient` is surjective. -/
theorem quotient.mkₐ_surjective (I : Ideal A) : Function.Surjective (quotient.mkₐ R₁ I) :=
  surjective_quot_mk _

/-- The kernel of `A →ₐ[R₁] I.quotient` is `I`. -/
@[simp]
theorem quotient.mkₐ_ker (I : Ideal A) : (quotient.mkₐ R₁ I : A →+* I.quotient).ker = I :=
  Ideal.mk_ker

variable{R₁}

theorem ker_lift.map_smul (f : A →ₐ[R₁] B) (r : R₁) (x : f.to_ring_hom.ker.quotient) :
  f.to_ring_hom.ker_lift (r • x) = r • f.to_ring_hom.ker_lift x :=
  by 
    obtain ⟨a, rfl⟩ := quotient.mkₐ_surjective R₁ _ x 
    rw [←AlgHom.map_smul, quotient.mkₐ_eq_mk, RingHom.ker_lift_mk]
    exact f.map_smul _ _

/-- The induced algebras morphism from the quotient by the kernel to the codomain.

This is an isomorphism if `f` has a right inverse (`quotient_ker_alg_equiv_of_right_inverse`) /
is surjective (`quotient_ker_alg_equiv_of_surjective`).
-/
def ker_lift_alg (f : A →ₐ[R₁] B) : f.to_ring_hom.ker.quotient →ₐ[R₁] B :=
  AlgHom.mk' f.to_ring_hom.ker_lift fun _ _ => ker_lift.map_smul f _ _

@[simp]
theorem ker_lift_alg_mk (f : A →ₐ[R₁] B) (a : A) : ker_lift_alg f (Quotientₓ.mk f.to_ring_hom.ker a) = f a :=
  rfl

@[simp]
theorem ker_lift_alg_to_ring_hom (f : A →ₐ[R₁] B) : (ker_lift_alg f).toRingHom = RingHom.kerLift f :=
  rfl

/-- The induced algebra morphism from the quotient by the kernel is injective. -/
theorem ker_lift_alg_injective (f : A →ₐ[R₁] B) : Function.Injective (ker_lift_alg f) :=
  RingHom.ker_lift_injective f

/-- The **first isomorphism** theorem for algebras, computable version. -/
def quotient_ker_alg_equiv_of_right_inverse {f : A →ₐ[R₁] B} {g : B → A} (hf : Function.RightInverse g f) :
  f.to_ring_hom.ker.quotient ≃ₐ[R₁] B :=
  { RingHom.quotientKerEquivOfRightInverse fun x => show f.to_ring_hom (g x) = x from hf x, ker_lift_alg f with  }

@[simp]
theorem quotient_ker_alg_equiv_of_right_inverse.apply {f : A →ₐ[R₁] B} {g : B → A} (hf : Function.RightInverse g f)
  (x : f.to_ring_hom.ker.quotient) : quotient_ker_alg_equiv_of_right_inverse hf x = ker_lift_alg f x :=
  rfl

@[simp]
theorem quotient_ker_alg_equiv_of_right_inverse_symm.apply {f : A →ₐ[R₁] B} {g : B → A} (hf : Function.RightInverse g f)
  (x : B) : (quotient_ker_alg_equiv_of_right_inverse hf).symm x = quotient.mkₐ R₁ f.to_ring_hom.ker (g x) :=
  rfl

/-- The **first isomorphism theorem** for algebras. -/
noncomputable def quotient_ker_alg_equiv_of_surjective {f : A →ₐ[R₁] B} (hf : Function.Surjective f) :
  f.to_ring_hom.ker.quotient ≃ₐ[R₁] B :=
  quotient_ker_alg_equiv_of_right_inverse (Classical.some_spec hf.has_right_inverse)

/-- The ring hom `R/I →+* S/J` induced by a ring hom `f : R →+* S` with `I ≤ f⁻¹(J)` -/
def quotient_map {I : Ideal R} (J : Ideal S) (f : R →+* S) (hIJ : I ≤ J.comap f) : I.quotient →+* J.quotient :=
  Quotientₓ.lift I ((Quotientₓ.mk J).comp f)
    fun _ ha =>
      by 
        simpa [Function.comp_app, RingHom.coe_comp, quotient.eq_zero_iff_mem] using hIJ ha

@[simp]
theorem quotient_map_mk {J : Ideal R} {I : Ideal S} {f : R →+* S} {H : J ≤ I.comap f} {x : R} :
  quotient_map I f H (Quotientₓ.mk J x) = Quotientₓ.mk I (f x) :=
  Quotientₓ.lift_mk J _ _

@[simp]
theorem quotient_map_algebra_map {J : Ideal A} {I : Ideal S} {f : A →+* S} {H : J ≤ I.comap f} {x : R₁} :
  quotient_map I f H (algebraMap R₁ J.quotient x) = Quotientₓ.mk I (f (algebraMap _ _ x)) :=
  Quotientₓ.lift_mk J _ _

theorem quotient_map_comp_mk {J : Ideal R} {I : Ideal S} {f : R →+* S} (H : J ≤ I.comap f) :
  (quotient_map I f H).comp (Quotientₓ.mk J) = (Quotientₓ.mk I).comp f :=
  RingHom.ext
    fun x =>
      by 
        simp only [Function.comp_app, RingHom.coe_comp, Ideal.quotient_map_mk]

/-- The ring equiv `R/I ≃+* S/J` induced by a ring equiv `f : R ≃+** S`,  where `J = f(I)`. -/
@[simps]
def quotient_equiv (I : Ideal R) (J : Ideal S) (f : R ≃+* S) (hIJ : J = I.map (f : R →+* S)) :
  I.quotient ≃+* J.quotient :=
  { quotient_map J («expr↑ » f)
      (by 
        rw [hIJ]
        exact @le_comap_map _ S _ _ _ _) with
    invFun :=
      quotient_map I («expr↑ » f.symm)
        (by 
          rw [hIJ]
          exact le_of_eqₓ (map_comap_of_equiv I f)),
    left_inv :=
      by 
        rintro ⟨r⟩
        simp ,
    right_inv :=
      by 
        rintro ⟨s⟩
        simp  }

/-- `H` and `h` are kept as separate hypothesis since H is used in constructing the quotient map. -/
theorem quotient_map_injective' {J : Ideal R} {I : Ideal S} {f : R →+* S} {H : J ≤ I.comap f} (h : I.comap f ≤ J) :
  Function.Injective (quotient_map I f H) :=
  by 
    refine' (quotient_map I f H).injective_iff.2 fun a ha => _ 
    obtain ⟨r, rfl⟩ := quotient.mk_surjective a 
    rw [quotient_map_mk, quotient.eq_zero_iff_mem] at ha 
    exact quotient.eq_zero_iff_mem.mpr (h ha)

/-- If we take `J = I.comap f` then `quotient_map` is injective automatically. -/
theorem quotient_map_injective {I : Ideal S} {f : R →+* S} : Function.Injective (quotient_map I f le_rfl) :=
  quotient_map_injective' le_rfl

theorem quotient_map_surjective {J : Ideal R} {I : Ideal S} {f : R →+* S} {H : J ≤ I.comap f}
  (hf : Function.Surjective f) : Function.Surjective (quotient_map I f H) :=
  fun x =>
    let ⟨x, hx⟩ := quotient.mk_surjective x 
    let ⟨y, hy⟩ := hf x
    ⟨(Quotientₓ.mk J) y,
      by 
        simp [hx, hy]⟩

/-- Commutativity of a square is preserved when taking quotients by an ideal. -/
theorem comp_quotient_map_eq_of_comp_eq {R' S' : Type _} [CommRingₓ R'] [CommRingₓ S'] {f : R →+* S} {f' : R' →+* S'}
  {g : R →+* R'} {g' : S →+* S'} (hfg : f'.comp g = g'.comp f) (I : Ideal S') :
  (quotient_map I g' le_rfl).comp (quotient_map (I.comap g') f le_rfl) =
    (quotient_map I f' le_rfl).comp
      (quotient_map (I.comap f') g (le_of_eqₓ (trans (comap_comap f g') (hfg ▸ comap_comap g f')))) :=
  by 
    refine' RingHom.ext fun a => _ 
    obtain ⟨r, rfl⟩ := quotient.mk_surjective a 
    simp only [RingHom.comp_apply, quotient_map_mk]
    exact congr_argₓ (Quotientₓ.mk I) (trans (g'.comp_apply f r).symm (hfg ▸ f'.comp_apply g r))

/-- The algebra hom `A/I →+* B/J` induced by an algebra hom `f : A →ₐ[R₁] B` with `I ≤ f⁻¹(J)`. -/
def quotient_mapₐ {I : Ideal A} (J : Ideal B) (f : A →ₐ[R₁] B) (hIJ : I ≤ J.comap f) : I.quotient →ₐ[R₁] J.quotient :=
  { quotient_map J («expr↑ » f) hIJ with
    commutes' :=
      fun r =>
        by 
          simp  }

@[simp]
theorem quotient_map_mkₐ {I : Ideal A} (J : Ideal B) (f : A →ₐ[R₁] B) (H : I ≤ J.comap f) {x : A} :
  quotient_mapₐ J f H (Quotientₓ.mk I x) = quotient.mkₐ R₁ J (f x) :=
  rfl

theorem quotient_map_comp_mkₐ {I : Ideal A} (J : Ideal B) (f : A →ₐ[R₁] B) (H : I ≤ J.comap f) :
  (quotient_mapₐ J f H).comp (quotient.mkₐ R₁ I) = (quotient.mkₐ R₁ J).comp f :=
  AlgHom.ext
    fun x =>
      by 
        simp only [quotient_map_mkₐ, quotient.mkₐ_eq_mk, AlgHom.comp_apply]

/-- The algebra equiv `A/I ≃ₐ[R] B/J` induced by an algebra equiv `f : A ≃ₐ[R] B`,
where`J = f(I)`. -/
def quotient_equiv_alg (I : Ideal A) (J : Ideal B) (f : A ≃ₐ[R₁] B) (hIJ : J = I.map (f : A →+* B)) :
  I.quotient ≃ₐ[R₁] J.quotient :=
  { quotient_equiv I J (f : A ≃+* B) hIJ with
    commutes' :=
      fun r =>
        by 
          simp  }

instance (priority := 100)quotient_algebra {I : Ideal A} [Algebra R A] :
  Algebra (I.comap (algebraMap R A)).Quotient I.quotient :=
  (quotient_map I (algebraMap R A) (le_of_eqₓ rfl)).toAlgebra

theorem algebra_map_quotient_injective {I : Ideal A} [Algebra R A] :
  Function.Injective (algebraMap (I.comap (algebraMap R A)).Quotient I.quotient) :=
  by 
    rintro ⟨a⟩ ⟨b⟩ hab 
    replace hab := quotient.eq.mp hab 
    rw [←RingHom.map_sub] at hab 
    exact quotient.eq.mpr hab

end QuotientAlgebra

end CommRingₓ

end Ideal

namespace Submodule

variable{R : Type u}{M : Type v}

variable[CommSemiringₓ R][AddCommMonoidₓ M][Module R M]

instance module_submodule : Module (Ideal R) (Submodule R M) :=
  { smul_add := smul_sup, add_smul := sup_smul, mul_smul := Submodule.smul_assoc,
    one_smul :=
      by 
        simp ,
    zero_smul := bot_smul, smul_zero := smul_bot }

end Submodule

namespace RingHom

variable{A B C : Type _}[Ringₓ A][Ringₓ B][Ringₓ C]

variable(f : A →+* B)(f_inv : B → A)

/-- Auxiliary definition used to define `lift_of_right_inverse` -/
def lift_of_right_inverse_aux (hf : Function.RightInverse f_inv f) (g : A →+* C) (hg : f.ker ≤ g.ker) : B →+* C :=
  { AddMonoidHom.liftOfRightInverse f.to_add_monoid_hom f_inv hf ⟨g.to_add_monoid_hom, hg⟩ with
    toFun := fun b => g (f_inv b),
    map_one' :=
      by 
        rw [←g.map_one, ←sub_eq_zero, ←g.map_sub, ←g.mem_ker]
        apply hg 
        rw [f.mem_ker, f.map_sub, sub_eq_zero, f.map_one]
        exact hf 1,
    map_mul' :=
      by 
        intro x y 
        rw [←g.map_mul, ←sub_eq_zero, ←g.map_sub, ←g.mem_ker]
        apply hg 
        rw [f.mem_ker, f.map_sub, sub_eq_zero, f.map_mul]
        simp only [hf _] }

@[simp]
theorem lift_of_right_inverse_aux_comp_apply (hf : Function.RightInverse f_inv f) (g : A →+* C) (hg : f.ker ≤ g.ker)
  (a : A) : (f.lift_of_right_inverse_aux f_inv hf g hg) (f a) = g a :=
  f.to_add_monoid_hom.lift_of_right_inverse_comp_apply f_inv hf ⟨g.to_add_monoid_hom, hg⟩ a

/-- `lift_of_right_inverse f hf g hg` is the unique ring homomorphism `φ`

* such that `φ.comp f = g` (`ring_hom.lift_of_right_inverse_comp`),
* where `f : A →+* B` is has a right_inverse `f_inv` (`hf`),
* and `g : B →+* C` satisfies `hg : f.ker ≤ g.ker`.

See `ring_hom.eq_lift_of_right_inverse` for the uniqueness lemma.

```
   A .
   |  \
 f |   \ g
   |    \
   v     \⌟
   B ----> C
      ∃!φ
```
-/
def lift_of_right_inverse (hf : Function.RightInverse f_inv f) : { g : A →+* C // f.ker ≤ g.ker } ≃ (B →+* C) :=
  { toFun := fun g => f.lift_of_right_inverse_aux f_inv hf g.1 g.2,
    invFun :=
      fun φ =>
        ⟨φ.comp f,
          fun x hx =>
            (mem_ker _).mpr$
              by 
                simp [(mem_ker _).mp hx]⟩,
    left_inv :=
      fun g =>
        by 
          ext 
          simp only [comp_apply, lift_of_right_inverse_aux_comp_apply, Subtype.coe_mk, Subtype.val_eq_coe],
    right_inv :=
      fun φ =>
        by 
          ext b 
          simp [lift_of_right_inverse_aux, hf b] }

/-- A non-computable version of `ring_hom.lift_of_right_inverse` for when no computable right
inverse is available, that uses `function.surj_inv`. -/
@[simp]
noncomputable abbrev lift_of_surjective (hf : Function.Surjective f) : { g : A →+* C // f.ker ≤ g.ker } ≃ (B →+* C) :=
  f.lift_of_right_inverse (Function.surjInv hf) (Function.right_inverse_surj_inv hf)

theorem lift_of_right_inverse_comp_apply (hf : Function.RightInverse f_inv f) (g : { g : A →+* C // f.ker ≤ g.ker })
  (x : A) : (f.lift_of_right_inverse f_inv hf g) (f x) = g x :=
  f.lift_of_right_inverse_aux_comp_apply f_inv hf g.1 g.2 x

theorem lift_of_right_inverse_comp (hf : Function.RightInverse f_inv f) (g : { g : A →+* C // f.ker ≤ g.ker }) :
  (f.lift_of_right_inverse f_inv hf g).comp f = g :=
  RingHom.ext$ f.lift_of_right_inverse_comp_apply f_inv hf g

theorem eq_lift_of_right_inverse (hf : Function.RightInverse f_inv f) (g : A →+* C) (hg : f.ker ≤ g.ker) (h : B →+* C)
  (hh : h.comp f = g) : h = f.lift_of_right_inverse f_inv hf ⟨g, hg⟩ :=
  by 
    simpRw [←hh]
    exact ((f.lift_of_right_inverse f_inv hf).apply_symm_apply _).symm

end RingHom

namespace DoubleQuot

open Ideal

variable{R : Type u}[CommRingₓ R](I J : Ideal R)

/-- The obvious ring hom `R/I → R/(I ⊔ J)` -/
def quot_left_to_quot_sup : I.quotient →+* (I⊔J).Quotient :=
  Ideal.Quotient.factor I (I⊔J) le_sup_left

/-- The kernel of `quot_left_to_quot_sup` -/
theorem ker_quot_left_to_quot_sup : (quot_left_to_quot_sup I J).ker = J.map (Ideal.Quotient.mk I) :=
  by 
    simp only [mk_ker, sup_idem, sup_comm, quot_left_to_quot_sup, quotient.factor, ker_quotient_lift,
      map_eq_iff_sup_ker_eq_of_surjective I quotient.mk_surjective, ←sup_assoc]

/-- The ring homomorphism `(R/I)/J' -> R/(I ⊔ J)` induced by `quot_left_to_quot_sup` where `J'`
  is the image of `J` in `R/I`-/
def quot_quot_to_quot_sup : (J.map (Ideal.Quotient.mk I)).Quotient →+* (I⊔J).Quotient :=
  Ideal.Quotient.lift (Ideal.map (Ideal.Quotient.mk I) J) (quot_left_to_quot_sup I J)
    (ker_quot_left_to_quot_sup I J).symm.le

/-- The composite of the maps `R → (R/I)` and `(R/I) → (R/I)/J'` -/
def quot_quot_mk : R →+* (J.map I).Quotient :=
  (J.map I).comp I

/-- The kernel of `quot_quot_mk` -/
theorem ker_quot_quot_mk : (quot_quot_mk I J).ker = I⊔J :=
  by 
    rw [RingHom.ker_eq_comap_bot, quot_quot_mk, ←comap_comap, ←RingHom.ker, mk_ker,
      comap_map_of_surjective (Ideal.Quotient.mk I) quotient.mk_surjective, ←RingHom.ker, mk_ker, sup_comm]

/-- The ring homomorphism `R/(I ⊔ J) → (R/I)/J' `induced by `quot_quot_mk` -/
def lift_sup_quot_quot_mk (I J : Ideal R) : (I⊔J).Quotient →+* (J.map (Ideal.Quotient.mk I)).Quotient :=
  Ideal.Quotient.lift (I⊔J) (quot_quot_mk I J) (ker_quot_quot_mk I J).symm.le

/-- `quot_quot_to_quot_add` and `lift_sup_double_qot_mk` are inverse isomorphisms -/
def quot_quot_equiv_quot_sup : (J.map (Ideal.Quotient.mk I)).Quotient ≃+* (I⊔J).Quotient :=
  RingEquiv.ofHomInv (quot_quot_to_quot_sup I J) (lift_sup_quot_quot_mk I J)
    (by 
      ext z 
      rfl)
    (by 
      ext z 
      rfl)

@[simp]
theorem quot_quot_equiv_quot_sup_quot_quot_mk (x : R) :
  quot_quot_equiv_quot_sup I J (quot_quot_mk I J x) = Ideal.Quotient.mk (I⊔J) x :=
  rfl

@[simp]
theorem quot_quot_equiv_quot_sup_symm_quot_quot_mk (x : R) :
  (quot_quot_equiv_quot_sup I J).symm (Ideal.Quotient.mk (I⊔J) x) = quot_quot_mk I J x :=
  rfl

/-- The obvious isomorphism `(R/I)/J' → (R/J)/I' `   -/
def quot_quot_equiv_comm : (J.map I).Quotient ≃+* (I.map J).Quotient :=
  ((quot_quot_equiv_quot_sup I J).trans (quot_equiv_of_eq sup_comm)).trans (quot_quot_equiv_quot_sup J I).symm

@[simp]
theorem quot_quot_equiv_comm_quot_quot_mk (x : R) :
  quot_quot_equiv_comm I J (quot_quot_mk I J x) = quot_quot_mk J I x :=
  rfl

@[simp]
theorem quot_quot_equiv_comm_comp_quot_quot_mk :
  RingHom.comp («expr↑ » (quot_quot_equiv_comm I J)) (quot_quot_mk I J) = quot_quot_mk J I :=
  RingHom.ext$ quot_quot_equiv_comm_quot_quot_mk I J

@[simp]
theorem quot_quot_equiv_comm_symm : (quot_quot_equiv_comm I J).symm = quot_quot_equiv_comm J I :=
  rfl

end DoubleQuot

