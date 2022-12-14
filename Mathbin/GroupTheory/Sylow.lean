/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Thomas Browning
-/
import Mathbin.Data.Nat.Factorization.Basic
import Mathbin.Data.SetLike.Fintype
import Mathbin.GroupTheory.GroupAction.ConjAct
import Mathbin.GroupTheory.PGroup
import Mathbin.GroupTheory.NoncommPiCoprod
import Mathbin.Order.Atoms.Finite

/-!
# Sylow theorems

The Sylow theorems are the following results for every finite group `G` and every prime number `p`.

* There exists a Sylow `p`-subgroup of `G`.
* All Sylow `p`-subgroups of `G` are conjugate to each other.
* Let `nₚ` be the number of Sylow `p`-subgroups of `G`, then `nₚ` divides the index of the Sylow
  `p`-subgroup, `nₚ ≡ 1 [MOD p]`, and `nₚ` is equal to the index of the normalizer of the Sylow
  `p`-subgroup in `G`.

## Main definitions

* `sylow p G` : The type of Sylow `p`-subgroups of `G`.

## Main statements

* `exists_subgroup_card_pow_prime`: A generalization of Sylow's first theorem:
  For every prime power `pⁿ` dividing the cardinality of `G`,
  there exists a subgroup of `G` of order `pⁿ`.
* `is_p_group.exists_le_sylow`: A generalization of Sylow's first theorem:
  Every `p`-subgroup is contained in a Sylow `p`-subgroup.
* `sylow.card_eq_multiplicity`: The cardinality of a Sylow group is `p ^ n`
 where `n` is the multiplicity of `p` in the group order.
* `sylow_conjugate`: A generalization of Sylow's second theorem:
  If the number of Sylow `p`-subgroups is finite, then all Sylow `p`-subgroups are conjugate.
* `card_sylow_modeq_one`: A generalization of Sylow's third theorem:
  If the number of Sylow `p`-subgroups is finite, then it is congruent to `1` modulo `p`.
-/


open Fintype MulAction Subgroup

section InfiniteSylow

variable (p : ℕ) (G : Type _) [Group G]

/-- A Sylow `p`-subgroup is a maximal `p`-subgroup. -/
structure Sylow extends Subgroup G where
  is_p_group' : IsPGroup p to_subgroup
  is_maximal' : ∀ {Q : Subgroup G}, IsPGroup p Q → to_subgroup ≤ Q → Q = to_subgroup
#align sylow Sylow

variable {p} {G}

namespace Sylow

instance : Coe (Sylow p G) (Subgroup G) :=
  ⟨Sylow.toSubgroup⟩

@[simp]
theorem to_subgroup_eq_coe {P : Sylow p G} : P.toSubgroup = ↑P :=
  rfl
#align sylow.to_subgroup_eq_coe Sylow.to_subgroup_eq_coe

@[ext]
theorem ext {P Q : Sylow p G} (h : (P : Subgroup G) = Q) : P = Q := by cases P <;> cases Q <;> congr
#align sylow.ext Sylow.ext

theorem ext_iff {P Q : Sylow p G} : P = Q ↔ (P : Subgroup G) = Q :=
  ⟨congr_arg coe, ext⟩
#align sylow.ext_iff Sylow.ext_iff

instance : SetLike (Sylow p G) G where 
  coe := coe
  coe_injective' P Q h := ext (SetLike.coe_injective h)

instance : SubgroupClass (Sylow p G)
      G where 
  mul_mem s _ _ := s.mul_mem'
  one_mem s := s.one_mem'
  inv_mem s _ := s.inv_mem'

variable (P : Sylow p G)

/-- The action by a Sylow subgroup is the action by the underlying group. -/
instance mulActionLeft {α : Type _} [MulAction G α] : MulAction P α :=
  Subgroup.mulAction ↑P
#align sylow.mul_action_left Sylow.mulActionLeft

variable {K : Type _} [Group K] (ϕ : K →* G) {N : Subgroup G}

/-- The preimage of a Sylow subgroup under a p-group-kernel homomorphism is a Sylow subgroup. -/
def comapOfKerIsPGroup (hϕ : IsPGroup p ϕ.ker) (h : ↑P ≤ ϕ.range) : Sylow p K :=
  { P.1.comap ϕ with 
    is_p_group' := P.2.comap_of_ker_is_p_group ϕ hϕ
    is_maximal' := fun Q hQ hle => by
      rw [← P.3 (hQ.map ϕ) (le_trans (ge_of_eq (map_comap_eq_self h)) (map_mono hle))]
      exact (comap_map_eq_self ((P.1.ker_le_comap ϕ).trans hle)).symm }
#align sylow.comap_of_ker_is_p_group Sylow.comapOfKerIsPGroup

@[simp]
theorem coe_comap_of_ker_is_p_group (hϕ : IsPGroup p ϕ.ker) (h : ↑P ≤ ϕ.range) :
    ↑(P.comap_of_ker_is_p_group ϕ hϕ h) = Subgroup.comap ϕ ↑P :=
  rfl
#align sylow.coe_comap_of_ker_is_p_group Sylow.coe_comap_of_ker_is_p_group

/-- The preimage of a Sylow subgroup under an injective homomorphism is a Sylow subgroup. -/
def comapOfInjective (hϕ : Function.Injective ϕ) (h : ↑P ≤ ϕ.range) : Sylow p K :=
  P.comap_of_ker_is_p_group ϕ (IsPGroup.ker_is_p_group_of_injective hϕ) h
#align sylow.comap_of_injective Sylow.comapOfInjective

@[simp]
theorem coe_comap_of_injective (hϕ : Function.Injective ϕ) (h : ↑P ≤ ϕ.range) :
    ↑(P.comap_of_injective ϕ hϕ h) = Subgroup.comap ϕ ↑P :=
  rfl
#align sylow.coe_comap_of_injective Sylow.coe_comap_of_injective

/-- A sylow subgroup of G is also a sylow subgroup of a subgroup of G. -/
protected def subtype (h : ↑P ≤ N) : Sylow p N :=
  P.comap_of_injective N.Subtype Subtype.coe_injective (by rwa [subtype_range])
#align sylow.subtype Sylow.subtype

@[simp]
theorem coe_subtype (h : ↑P ≤ N) : ↑(P.Subtype h) = subgroupOf (↑P) N :=
  rfl
#align sylow.coe_subtype Sylow.coe_subtype

theorem subtype_injective {P Q : Sylow p G} {hP : ↑P ≤ N} {hQ : ↑Q ≤ N}
    (h : P.Subtype hP = Q.Subtype hQ) : P = Q := by
  rw [SetLike.ext_iff] at h⊢
  exact fun g => ⟨fun hg => (h ⟨g, hP hg⟩).mp hg, fun hg => (h ⟨g, hQ hg⟩).mpr hg⟩
#align sylow.subtype_injective Sylow.subtype_injective

end Sylow

/-- A generalization of **Sylow's first theorem**.
  Every `p`-subgroup is contained in a Sylow `p`-subgroup. -/
theorem IsPGroup.exists_le_sylow {P : Subgroup G} (hP : IsPGroup p P) : ∃ Q : Sylow p G, P ≤ Q :=
  Exists.elim
    (zorn_nonempty_partial_order₀ { Q : Subgroup G | IsPGroup p Q }
      (fun c hc1 hc2 Q hQ =>
        ⟨{  carrier := ⋃ R : c, R
            one_mem' := ⟨Q, ⟨⟨Q, hQ⟩, rfl⟩, Q.one_mem⟩
            inv_mem' := fun g ⟨_, ⟨R, rfl⟩, hg⟩ => ⟨R, ⟨R, rfl⟩, R.1.inv_mem hg⟩
            mul_mem' := fun g h ⟨_, ⟨R, rfl⟩, hg⟩ ⟨_, ⟨S, rfl⟩, hh⟩ =>
              (hc2.Total R.2 S.2).elim (fun T => ⟨S, ⟨S, rfl⟩, S.1.mul_mem (T hg) hh⟩) fun T =>
                ⟨R, ⟨R, rfl⟩, R.1.mul_mem hg (T hh)⟩ },
          fun ⟨g, _, ⟨S, rfl⟩, hg⟩ => by
          refine' Exists.imp (fun k hk => _) (hc1 S.2 ⟨g, hg⟩)
          rwa [Subtype.ext_iff, coe_pow] at hk⊢, fun M hM g hg => ⟨M, ⟨⟨M, hM⟩, rfl⟩, hg⟩⟩)
      P hP)
    fun Q ⟨hQ1, hQ2, hQ3⟩ => ⟨⟨Q, hQ1, hQ3⟩, hQ2⟩
#align is_p_group.exists_le_sylow IsPGroup.exists_le_sylow

instance Sylow.nonempty : Nonempty (Sylow p G) :=
  nonempty_of_exists IsPGroup.of_bot.exists_le_sylow
#align sylow.nonempty Sylow.nonempty

noncomputable instance Sylow.inhabited : Inhabited (Sylow p G) :=
  Classical.inhabited_of_nonempty Sylow.nonempty
#align sylow.inhabited Sylow.inhabited

theorem Sylow.exists_comap_eq_of_ker_is_p_group {H : Type _} [Group H] (P : Sylow p H) {f : H →* G}
    (hf : IsPGroup p f.ker) : ∃ Q : Sylow p G, (Q : Subgroup G).comap f = P :=
  Exists.imp (fun Q hQ => P.3 (Q.2.comap_of_ker_is_p_group f hf) (map_le_iff_le_comap.mp hQ))
    (P.2.map f).exists_le_sylow
#align sylow.exists_comap_eq_of_ker_is_p_group Sylow.exists_comap_eq_of_ker_is_p_group

theorem Sylow.exists_comap_eq_of_injective {H : Type _} [Group H] (P : Sylow p H) {f : H →* G}
    (hf : Function.Injective f) : ∃ Q : Sylow p G, (Q : Subgroup G).comap f = P :=
  P.exists_comap_eq_of_ker_is_p_group (IsPGroup.ker_is_p_group_of_injective hf)
#align sylow.exists_comap_eq_of_injective Sylow.exists_comap_eq_of_injective

theorem Sylow.exists_comap_subtype_eq {H : Subgroup G} (P : Sylow p H) :
    ∃ Q : Sylow p G, (Q : Subgroup G).comap H.Subtype = P :=
  P.exists_comap_eq_of_injective Subtype.coe_injective
#align sylow.exists_comap_subtype_eq Sylow.exists_comap_subtype_eq

/-- If the kernel of `f : H →* G` is a `p`-group,
  then `fintype (sylow p G)` implies `fintype (sylow p H)`. -/
noncomputable def Sylow.fintypeOfKerIsPGroup {H : Type _} [Group H] {f : H →* G}
    (hf : IsPGroup p f.ker) [Fintype (Sylow p G)] : Fintype (Sylow p H) :=
  let h_exists := fun P : Sylow p H => P.exists_comap_eq_of_ker_is_p_group hf
  let g : Sylow p H → Sylow p G := fun P => Classical.choose (h_exists P)
  let hg : ∀ P : Sylow p H, (g P).1.comap f = P := fun P => Classical.choose_spec (h_exists P)
  Fintype.ofInjective g fun P Q h => Sylow.ext (by simp only [← hg, h])
#align sylow.fintype_of_ker_is_p_group Sylow.fintypeOfKerIsPGroup

/-- If `f : H →* G` is injective, then `fintype (sylow p G)` implies `fintype (sylow p H)`. -/
noncomputable def Sylow.fintypeOfInjective {H : Type _} [Group H] {f : H →* G}
    (hf : Function.Injective f) [Fintype (Sylow p G)] : Fintype (Sylow p H) :=
  Sylow.fintypeOfKerIsPGroup (IsPGroup.ker_is_p_group_of_injective hf)
#align sylow.fintype_of_injective Sylow.fintypeOfInjective

/-- If `H` is a subgroup of `G`, then `fintype (sylow p G)` implies `fintype (sylow p H)`. -/
noncomputable instance (H : Subgroup G) [Fintype (Sylow p G)] : Fintype (Sylow p H) :=
  Sylow.fintypeOfInjective H.subtype_injective

/-- If `H` is a subgroup of `G`, then `finite (sylow p G)` implies `finite (sylow p H)`. -/
instance (H : Subgroup G) [Finite (Sylow p G)] : Finite (Sylow p H) := by
  cases nonempty_fintype (Sylow p G)
  infer_instance

open Pointwise

/-- `subgroup.pointwise_mul_action` preserves Sylow subgroups. -/
instance Sylow.pointwiseMulAction {α : Type _} [Group α] [MulDistribMulAction α G] :
    MulAction α
      (Sylow p
        G) where 
  smul g P :=
    ⟨g • P, P.2.map _, fun Q hQ hS =>
      inv_smul_eq_iff.mp
        (P.3 (hQ.map _) fun s hs =>
          (congr_arg (· ∈ g⁻¹ • Q) (inv_smul_smul g s)).mp
            (smul_mem_pointwise_smul (g • s) g⁻¹ Q (hS (smul_mem_pointwise_smul s g P hs))))⟩
  one_smul P := Sylow.ext (one_smul α P)
  mul_smul g h P := Sylow.ext (mul_smul g h P)
#align sylow.pointwise_mul_action Sylow.pointwiseMulAction

theorem Sylow.pointwise_smul_def {α : Type _} [Group α] [MulDistribMulAction α G] {g : α}
    {P : Sylow p G} : ↑(g • P) = g • (P : Subgroup G) :=
  rfl
#align sylow.pointwise_smul_def Sylow.pointwise_smul_def

instance Sylow.mulAction : MulAction G (Sylow p G) :=
  compHom _ MulAut.conj
#align sylow.mul_action Sylow.mulAction

theorem Sylow.smul_def {g : G} {P : Sylow p G} : g • P = MulAut.conj g • P :=
  rfl
#align sylow.smul_def Sylow.smul_def

theorem Sylow.coe_subgroup_smul {g : G} {P : Sylow p G} :
    ↑(g • P) = MulAut.conj g • (P : Subgroup G) :=
  rfl
#align sylow.coe_subgroup_smul Sylow.coe_subgroup_smul

theorem Sylow.coe_smul {g : G} {P : Sylow p G} : ↑(g • P) = MulAut.conj g • (P : Set G) :=
  rfl
#align sylow.coe_smul Sylow.coe_smul

theorem Sylow.smul_le {P : Sylow p G} {H : Subgroup G} (hP : ↑P ≤ H) (h : H) : ↑(h • P) ≤ H :=
  Subgroup.conj_smul_le_of_le hP h
#align sylow.smul_le Sylow.smul_le

theorem Sylow.smul_subtype {P : Sylow p G} {H : Subgroup G} (hP : ↑P ≤ H) (h : H) :
    h • P.Subtype hP = (h • P).Subtype (Sylow.smul_le hP h) :=
  Sylow.ext (Subgroup.conj_smul_subgroup_of hP h)
#align sylow.smul_subtype Sylow.smul_subtype

theorem Sylow.smul_eq_iff_mem_normalizer {g : G} {P : Sylow p G} :
    g • P = P ↔ g ∈ (P : Subgroup G).normalizer := by
  rw [eq_comm, SetLike.ext_iff, ← inv_mem_iff, mem_normalizer_iff, inv_inv]
  exact
    forall_congr' fun h =>
      iff_congr Iff.rfl
        ⟨fun ⟨a, b, c⟩ =>
          (congr_arg _ c).mp
            ((congr_arg (· ∈ P.1) (MulAut.inv_apply_self G (MulAut.conj g) a)).mpr b),
          fun hh => ⟨(MulAut.conj g)⁻¹ h, hh, MulAut.apply_inv_self G (MulAut.conj g) h⟩⟩
#align sylow.smul_eq_iff_mem_normalizer Sylow.smul_eq_iff_mem_normalizer

theorem Sylow.smul_eq_of_normal {g : G} {P : Sylow p G} [h : (P : Subgroup G).Normal] : g • P = P :=
  by simp only [Sylow.smul_eq_iff_mem_normalizer, normalizer_eq_top.mpr h, mem_top]
#align sylow.smul_eq_of_normal Sylow.smul_eq_of_normal

theorem Subgroup.sylow_mem_fixed_points_iff (H : Subgroup G) {P : Sylow p G} :
    P ∈ fixedPoints H (Sylow p G) ↔ H ≤ (P : Subgroup G).normalizer := by
  simp_rw [SetLike.le_def, ← Sylow.smul_eq_iff_mem_normalizer] <;> exact Subtype.forall
#align subgroup.sylow_mem_fixed_points_iff Subgroup.sylow_mem_fixed_points_iff

theorem IsPGroup.inf_normalizer_sylow {P : Subgroup G} (hP : IsPGroup p P) (Q : Sylow p G) :
    P ⊓ (Q : Subgroup G).normalizer = P ⊓ Q :=
  le_antisymm
    (le_inf inf_le_left
      (sup_eq_right.mp
        (Q.3 (hP.to_inf_left.to_sup_of_normal_right' Q.2 inf_le_right) le_sup_right)))
    (inf_le_inf_left P le_normalizer)
#align is_p_group.inf_normalizer_sylow IsPGroup.inf_normalizer_sylow

theorem IsPGroup.sylow_mem_fixed_points_iff {P : Subgroup G} (hP : IsPGroup p P) {Q : Sylow p G} :
    Q ∈ fixedPoints P (Sylow p G) ↔ P ≤ Q := by
  rw [P.sylow_mem_fixed_points_iff, ← inf_eq_left, hP.inf_normalizer_sylow, inf_eq_left]
#align is_p_group.sylow_mem_fixed_points_iff IsPGroup.sylow_mem_fixed_points_iff

/-- A generalization of **Sylow's second theorem**.
  If the number of Sylow `p`-subgroups is finite, then all Sylow `p`-subgroups are conjugate. -/
instance [hp : Fact p.Prime] [Finite (Sylow p G)] : IsPretransitive G (Sylow p G) :=
  ⟨fun P Q => by
    classical 
      cases nonempty_fintype (Sylow p G)
      have H := fun {R : Sylow p G} {S : orbit G P} =>
        calc
          S ∈ fixed_points R (orbit G P) ↔ S.1 ∈ fixed_points R (Sylow p G) :=
            forall_congr' fun a => Subtype.ext_iff
          _ ↔ R.1 ≤ S := R.2.sylow_mem_fixed_points_iff
          _ ↔ S.1.1 = R := ⟨fun h => R.3 S.1.2 h, ge_of_eq⟩
          
      suffices Set.Nonempty (fixed_points Q (orbit G P)) by
        exact Exists.elim this fun R hR => (congr_arg _ (Sylow.ext (H.mp hR))).mp R.2
      apply Q.2.nonempty_fixed_point_of_prime_not_dvd_card
      refine' fun h => hp.out.not_dvd_one (nat.modeq_zero_iff_dvd.mp _)
      calc
        1 = card (fixed_points P (orbit G P)) := _
        _ ≡ card (orbit G P) [MOD p] := (P.2.card_modeq_card_fixed_points (orbit G P)).symm
        _ ≡ 0 [MOD p] := nat.modeq_zero_iff_dvd.mpr h
        
      rw [← Set.card_singleton (⟨P, mem_orbit_self P⟩ : orbit G P)]
      refine' card_congr' (congr_arg _ (Eq.symm _))
      rw [Set.eq_singleton_iff_unique_mem]
      exact ⟨H.mpr rfl, fun R h => Subtype.ext (Sylow.ext (H.mp h))⟩⟩

variable (p) (G)

/-- A generalization of **Sylow's third theorem**.
  If the number of Sylow `p`-subgroups is finite, then it is congruent to `1` modulo `p`. -/
theorem card_sylow_modeq_one [Fact p.Prime] [Fintype (Sylow p G)] : card (Sylow p G) ≡ 1 [MOD p] :=
  by 
  refine' sylow.nonempty.elim fun P : Sylow p G => _
  have : fixed_points P.1 (Sylow p G) = {P} :=
    Set.ext fun Q : Sylow p G =>
      calc
        Q ∈ fixed_points P (Sylow p G) ↔ P.1 ≤ Q := P.2.sylow_mem_fixed_points_iff
        _ ↔ Q.1 = P.1 := ⟨P.3 Q.2, ge_of_eq⟩
        _ ↔ Q ∈ {P} := sylow.ext_iff.symm.trans set.mem_singleton_iff.symm
        
  have : Fintype (fixed_points P.1 (Sylow p G)) := by
    rw [this]
    infer_instance
  have : card (fixed_points P.1 (Sylow p G)) = 1 := by simp [this]
  exact (P.2.card_modeq_card_fixed_points (Sylow p G)).trans (by rw [this])
#align card_sylow_modeq_one card_sylow_modeq_one

theorem not_dvd_card_sylow [hp : Fact p.Prime] [Fintype (Sylow p G)] : ¬p ∣ card (Sylow p G) :=
  fun h =>
  hp.1.ne_one
    (Nat.dvd_one.mp
      ((Nat.modeq_iff_dvd' zero_le_one).mp
        ((Nat.modeq_zero_iff_dvd.mpr h).symm.trans (card_sylow_modeq_one p G))))
#align not_dvd_card_sylow not_dvd_card_sylow

variable {p} {G}

/-- Sylow subgroups are isomorphic -/
def Sylow.equivSmul (P : Sylow p G) (g : G) : P ≃* (g • P : Sylow p G) :=
  equivSmul (MulAut.conj g) ↑P
#align sylow.equiv_smul Sylow.equivSmul

/-- Sylow subgroups are isomorphic -/
noncomputable def Sylow.equiv [Fact p.Prime] [Finite (Sylow p G)] (P Q : Sylow p G) : P ≃* Q := by
  rw [← Classical.choose_spec (exists_smul_eq G P Q)]
  exact P.equiv_smul (Classical.choose (exists_smul_eq G P Q))
#align sylow.equiv Sylow.equiv

@[simp]
theorem Sylow.orbit_eq_top [Fact p.Prime] [Finite (Sylow p G)] (P : Sylow p G) : orbit G P = ⊤ :=
  top_le_iff.mp fun Q hQ => exists_smul_eq G P Q
#align sylow.orbit_eq_top Sylow.orbit_eq_top

theorem Sylow.stabilizer_eq_normalizer (P : Sylow p G) :
    stabilizer G P = (P : Subgroup G).normalizer :=
  ext fun g => Sylow.smul_eq_iff_mem_normalizer
#align sylow.stabilizer_eq_normalizer Sylow.stabilizer_eq_normalizer

theorem Sylow.conj_eq_normalizer_conj_of_mem_centralizer [Fact p.Prime] [Finite (Sylow p G)]
    (P : Sylow p G) (x g : G) (hx : x ∈ (P : Subgroup G).centralizer)
    (hy : g⁻¹ * x * g ∈ (P : Subgroup G).centralizer) :
    ∃ n ∈ (P : Subgroup G).normalizer, g⁻¹ * x * g = n⁻¹ * x * n := by
  have h1 : ↑P ≤ (zpowers x).centralizer := by rwa [le_centralizer_iff, zpowers_le]
  have h2 : ↑(g • P) ≤ (zpowers x).centralizer := by
    rw [le_centralizer_iff, zpowers_le]
    rintro - ⟨z, hz, rfl⟩
    specialize hy z hz
    rwa [← mul_assoc, ← eq_mul_inv_iff_mul_eq, mul_assoc, mul_assoc, mul_assoc, ← mul_assoc,
      eq_inv_mul_iff_mul_eq, ← mul_assoc, ← mul_assoc] at hy
  obtain ⟨h, hh⟩ := exists_smul_eq (zpowers x).centralizer ((g • P).Subtype h2) (P.subtype h1)
  simp_rw [Sylow.smul_subtype, smul_def, smul_smul] at hh
  refine' ⟨h * g, sylow.smul_eq_iff_mem_normalizer.mp (Sylow.subtype_injective hh), _⟩
  rw [← mul_assoc, Commute.right_comm (h.prop x (mem_zpowers x)), mul_inv_rev, inv_mul_cancel_right]
#align
  sylow.conj_eq_normalizer_conj_of_mem_centralizer Sylow.conj_eq_normalizer_conj_of_mem_centralizer

theorem Sylow.conj_eq_normalizer_conj_of_mem [Fact p.Prime] [Finite (Sylow p G)] (P : Sylow p G)
    [hP : (P : Subgroup G).IsCommutative] (x g : G) (hx : x ∈ P) (hy : g⁻¹ * x * g ∈ P) :
    ∃ n ∈ (P : Subgroup G).normalizer, g⁻¹ * x * g = n⁻¹ * x * n :=
  P.conj_eq_normalizer_conj_of_mem_centralizer x g (le_centralizer P hx) (le_centralizer P hy)
#align sylow.conj_eq_normalizer_conj_of_mem Sylow.conj_eq_normalizer_conj_of_mem

/-- Sylow `p`-subgroups are in bijection with cosets of the normalizer of a Sylow `p`-subgroup -/
noncomputable def Sylow.equivQuotientNormalizer [Fact p.Prime] [Fintype (Sylow p G)]
    (P : Sylow p G) : Sylow p G ≃ G ⧸ (P : Subgroup G).normalizer :=
  calc
    Sylow p G ≃ (⊤ : Set (Sylow p G)) := (Equiv.Set.univ (Sylow p G)).symm
    _ ≃ orbit G P := by rw [P.orbit_eq_top]
    _ ≃ G ⧸ stabilizer G P := orbitEquivQuotientStabilizer G P
    _ ≃ G ⧸ (P : Subgroup G).normalizer := by rw [P.stabilizer_eq_normalizer]
    
#align sylow.equiv_quotient_normalizer Sylow.equivQuotientNormalizer

noncomputable instance [Fact p.Prime] [Fintype (Sylow p G)] (P : Sylow p G) :
    Fintype (G ⧸ (P : Subgroup G).normalizer) :=
  ofEquiv (Sylow p G) P.equivQuotientNormalizer

theorem card_sylow_eq_card_quotient_normalizer [Fact p.Prime] [Fintype (Sylow p G)]
    (P : Sylow p G) : card (Sylow p G) = card (G ⧸ (P : Subgroup G).normalizer) :=
  card_congr P.equivQuotientNormalizer
#align card_sylow_eq_card_quotient_normalizer card_sylow_eq_card_quotient_normalizer

theorem card_sylow_eq_index_normalizer [Fact p.Prime] [Fintype (Sylow p G)] (P : Sylow p G) :
    card (Sylow p G) = (P : Subgroup G).normalizer.index :=
  (card_sylow_eq_card_quotient_normalizer P).trans (P : Subgroup G).normalizer.index_eq_card.symm
#align card_sylow_eq_index_normalizer card_sylow_eq_index_normalizer

theorem card_sylow_dvd_index [Fact p.Prime] [Fintype (Sylow p G)] (P : Sylow p G) :
    card (Sylow p G) ∣ (P : Subgroup G).index :=
  ((congr_arg _ (card_sylow_eq_index_normalizer P)).mp dvd_rfl).trans
    (index_dvd_of_le le_normalizer)
#align card_sylow_dvd_index card_sylow_dvd_index

theorem not_dvd_index_sylow' [hp : Fact p.Prime] (P : Sylow p G) [(P : Subgroup G).Normal]
    [FiniteIndex (P : Subgroup G)] : ¬p ∣ (P : Subgroup G).index := by
  intro h
  haveI := (P : Subgroup G).fintypeQuotientOfFiniteIndex
  rw [index_eq_card] at h
  obtain ⟨x, hx⟩ := exists_prime_order_of_dvd_card p h
  have h := IsPGroup.of_card ((order_eq_card_zpowers.symm.trans hx).trans (pow_one p).symm)
  let Q := (zpowers x).comap (QuotientGroup.mk' (P : Subgroup G))
  have hQ : IsPGroup p Q := by 
    apply h.comap_of_ker_is_p_group
    rw [QuotientGroup.ker_mk]
    exact P.2
  replace hp := mt order_of_eq_one_iff.mpr (ne_of_eq_of_ne hx hp.1.ne_one)
  rw [← zpowers_eq_bot, ← Ne, ← bot_lt_iff_ne_bot, ←
    comap_lt_comap_of_surjective (QuotientGroup.mk'_surjective _), MonoidHom.comap_bot,
    QuotientGroup.ker_mk] at hp
  exact hp.ne' (P.3 hQ hp.le)
#align not_dvd_index_sylow' not_dvd_index_sylow'

theorem not_dvd_index_sylow [hp : Fact p.Prime] [Finite (Sylow p G)] (P : Sylow p G)
    (hP : relindex ↑P (P : Subgroup G).normalizer ≠ 0) : ¬p ∣ (P : Subgroup G).index := by
  cases nonempty_fintype (Sylow p G)
  rw [← relindex_mul_index le_normalizer, ← card_sylow_eq_index_normalizer]
  haveI : (P.subtype le_normalizer : Subgroup (P : Subgroup G).normalizer).Normal :=
    Subgroup.normal_in_normalizer
  haveI : finite_index ↑(P.subtype le_normalizer) := ⟨hP⟩
  replace hP := not_dvd_index_sylow' (P.subtype le_normalizer)
  exact hp.1.not_dvd_mul hP (not_dvd_card_sylow p G)
#align not_dvd_index_sylow not_dvd_index_sylow

/-- **Frattini's Argument**: If `N` is a normal subgroup of `G`, and if `P` is a Sylow `p`-subgroup
  of `N`, then `N_G(P) ⊔ N = G`. -/
theorem Sylow.normalizer_sup_eq_top {p : ℕ} [Fact p.Prime] {N : Subgroup G} [N.Normal]
    [Finite (Sylow p N)] (P : Sylow p N) : ((↑P : Subgroup N).map N.Subtype).normalizer ⊔ N = ⊤ :=
  by 
  refine' top_le_iff.mp fun g hg => _
  obtain ⟨n, hn⟩ := exists_smul_eq N ((MulAut.conjNormal g : MulAut N) • P) P
  rw [← inv_mul_cancel_left (↑n) g, sup_comm]
  apply mul_mem_sup (N.inv_mem n.2)
  rw [Sylow.smul_def, ← mul_smul, ← MulAut.conj_normal_coe, ← mul_aut.conj_normal.map_mul,
    Sylow.ext_iff, Sylow.pointwise_smul_def, pointwise_smul_def] at hn
  refine' fun x =>
    (mem_map_iff_mem
            (show Function.Injective (MulAut.conj (↑n * g)).toMonoidHom from
              (MulAut.conj (↑n * g)).Injective)).symm.trans
      _
  rw [map_map, ← congr_arg (map N.subtype) hn, map_map]
  rfl
#align sylow.normalizer_sup_eq_top Sylow.normalizer_sup_eq_top

/-- **Frattini's Argument**: If `N` is a normal subgroup of `G`, and if `P` is a Sylow `p`-subgroup
  of `N`, then `N_G(P) ⊔ N = G`. -/
theorem Sylow.normalizer_sup_eq_top' {p : ℕ} [Fact p.Prime] {N : Subgroup G} [N.Normal]
    [Finite (Sylow p N)] (P : Sylow p G) (hP : ↑P ≤ N) : (P : Subgroup G).normalizer ⊔ N = ⊤ := by
  rw [← Sylow.normalizer_sup_eq_top (P.subtype hP), P.coe_subtype, subgroup_of_map_subtype,
    inf_of_le_left hP]
#align sylow.normalizer_sup_eq_top' Sylow.normalizer_sup_eq_top'

end InfiniteSylow

open Equiv Equiv.Perm Finset Function List QuotientGroup

open BigOperators

universe u v w

variable {G : Type u} {α : Type v} {β : Type w} [Group G]

attribute [local instance] Subtype.fintype setFintype Classical.propDecidable

theorem QuotientGroup.card_preimage_mk [Fintype G] (s : Subgroup G) (t : Set (G ⧸ s)) :
    Fintype.card (QuotientGroup.mk ⁻¹' t) = Fintype.card s * Fintype.card t := by
  rw [← Fintype.card_prod, Fintype.card_congr (preimage_mk_equiv_subgroup_times_set _ _)]
#align quotient_group.card_preimage_mk QuotientGroup.card_preimage_mk

namespace Sylow

open Subgroup Submonoid MulAction

theorem mem_fixed_points_mul_left_cosets_iff_mem_normalizer {H : Subgroup G} [Finite ↥(H : Set G)]
    {x : G} : (x : G ⧸ H) ∈ fixedPoints H (G ⧸ H) ↔ x ∈ normalizer H :=
  ⟨fun hx =>
    have ha : ∀ {y : G ⧸ H}, y ∈ orbit H (x : G ⧸ H) → y = x := fun _ =>
      (mem_fixed_points' _).1 hx _
    inv_mem_iff.1
      (mem_normalizer_fintype fun n (hn : n ∈ H) =>
        have : (n⁻¹ * x)⁻¹ * x ∈ H := QuotientGroup.eq.1 (ha (mem_orbit _ ⟨n⁻¹, H.inv_mem hn⟩))
        show _ ∈ H by 
          rw [mul_inv_rev, inv_inv] at this
          convert this
          rw [inv_inv]),
    fun hx : ∀ n : G, n ∈ H ↔ x * n * x⁻¹ ∈ H =>
    (mem_fixed_points' _).2 fun y =>
      (Quotient.inductionOn' y) fun y hy =>
        QuotientGroup.eq.2
          (let ⟨⟨b, hb₁⟩, hb₂⟩ := hy
          have hb₂ : (b * x)⁻¹ * y ∈ H := QuotientGroup.eq.1 hb₂
          inv_mem_iff.1 <|
            (hx _).2 <|
              (mul_mem_cancel_left (inv_mem hb₁)).1 <| by
                rw [hx] at hb₂ <;> simpa [mul_inv_rev, mul_assoc] using hb₂)⟩
#align
  sylow.mem_fixed_points_mul_left_cosets_iff_mem_normalizer Sylow.mem_fixed_points_mul_left_cosets_iff_mem_normalizer

/-- The fixed points of the action of `H` on its cosets correspond to `normalizer H / H`. -/
def fixedPointsMulLeftCosetsEquivQuotient (H : Subgroup G) [Finite (H : Set G)] :
    MulAction.fixedPoints H (G ⧸ H) ≃
      normalizer H ⧸ Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H :=
  @subtypeQuotientEquivQuotientSubtype G (normalizer H : Set G) (id _) (id _) (fixedPoints _ _)
    (fun a => (@mem_fixed_points_mul_left_cosets_iff_mem_normalizer _ _ _ ‹_› _).symm)
    (by 
      intros
      rw [setoidHasEquiv]
      simp only [left_rel_apply]
      rfl)
#align sylow.fixed_points_mul_left_cosets_equiv_quotient Sylow.fixedPointsMulLeftCosetsEquivQuotient

/-- If `H` is a `p`-subgroup of `G`, then the index of `H` inside its normalizer is congruent
  mod `p` to the index of `H`.  -/
theorem card_quotient_normalizer_modeq_card_quotient [Fintype G] {p : ℕ} {n : ℕ} [hp : Fact p.Prime]
    {H : Subgroup G} (hH : Fintype.card H = p ^ n) :
    card (normalizer H ⧸ Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H) ≡
      card (G ⧸ H) [MOD p] :=
  by 
  rw [← Fintype.card_congr (fixed_points_mul_left_cosets_equiv_quotient H)]
  exact ((IsPGroup.of_card hH).card_modeq_card_fixed_points _).symm
#align
  sylow.card_quotient_normalizer_modeq_card_quotient Sylow.card_quotient_normalizer_modeq_card_quotient

/-- If `H` is a subgroup of `G` of cardinality `p ^ n`, then the cardinality of the
  normalizer of `H` is congruent mod `p ^ (n + 1)` to the cardinality of `G`.  -/
theorem card_normalizer_modeq_card [Fintype G] {p : ℕ} {n : ℕ} [hp : Fact p.Prime] {H : Subgroup G}
    (hH : Fintype.card H = p ^ n) : card (normalizer H) ≡ card G [MOD p ^ (n + 1)] := by
  have : H.subgroupOf (normalizer H) ≃ H := (subgroupOfEquivOfLe le_normalizer).toEquiv
  rw [card_eq_card_quotient_mul_card_subgroup H,
    card_eq_card_quotient_mul_card_subgroup (H.subgroup_of (normalizer H)), Fintype.card_congr this,
    hH, pow_succ]
  exact (card_quotient_normalizer_modeq_card_quotient hH).mul_right' _
#align sylow.card_normalizer_modeq_card Sylow.card_normalizer_modeq_card

/-- If `H` is a `p`-subgroup but not a Sylow `p`-subgroup, then `p` divides the
  index of `H` inside its normalizer. -/
theorem prime_dvd_card_quotient_normalizer [Fintype G] {p : ℕ} {n : ℕ} [hp : Fact p.Prime]
    (hdvd : p ^ (n + 1) ∣ card G) {H : Subgroup G} (hH : Fintype.card H = p ^ n) :
    p ∣ card (normalizer H ⧸ Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H) :=
  let ⟨s, hs⟩ := exists_eq_mul_left_of_dvd hdvd
  have hcard : card (G ⧸ H) = s * p :=
    (mul_left_inj' (show card H ≠ 0 from Fintype.card_ne_zero)).1
      (by
        rwa [← card_eq_card_quotient_mul_card_subgroup H, hH, hs, pow_succ', mul_assoc, mul_comm p])
  have hm :
    s * p % p =
      card (normalizer H ⧸ Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H) % p :=
    hcard ▸ (card_quotient_normalizer_modeq_card_quotient hH).symm
  Nat.dvd_of_mod_eq_zero (by rwa [Nat.mod_eq_zero_of_dvd (dvd_mul_left _ _), eq_comm] at hm)
#align sylow.prime_dvd_card_quotient_normalizer Sylow.prime_dvd_card_quotient_normalizer

/-- If `H` is a `p`-subgroup but not a Sylow `p`-subgroup of cardinality `p ^ n`,
  then `p ^ (n + 1)` divides the cardinality of the normalizer of `H`. -/
theorem prime_pow_dvd_card_normalizer [Fintype G] {p : ℕ} {n : ℕ} [hp : Fact p.Prime]
    (hdvd : p ^ (n + 1) ∣ card G) {H : Subgroup G} (hH : Fintype.card H = p ^ n) :
    p ^ (n + 1) ∣ card (normalizer H) :=
  Nat.modeq_zero_iff_dvd.1 ((card_normalizer_modeq_card hH).trans hdvd.modeq_zero_nat)
#align sylow.prime_pow_dvd_card_normalizer Sylow.prime_pow_dvd_card_normalizer

/-- If `H` is a subgroup of `G` of cardinality `p ^ n`,
  then `H` is contained in a subgroup of cardinality `p ^ (n + 1)`
  if `p ^ (n + 1)` divides the cardinality of `G` -/
theorem exists_subgroup_card_pow_succ [Fintype G] {p : ℕ} {n : ℕ} [hp : Fact p.Prime]
    (hdvd : p ^ (n + 1) ∣ card G) {H : Subgroup G} (hH : Fintype.card H = p ^ n) :
    ∃ K : Subgroup G, Fintype.card K = p ^ (n + 1) ∧ H ≤ K :=
  let ⟨s, hs⟩ := exists_eq_mul_left_of_dvd hdvd
  have hcard : card (G ⧸ H) = s * p :=
    (mul_left_inj' (show card H ≠ 0 from Fintype.card_ne_zero)).1
      (by
        rwa [← card_eq_card_quotient_mul_card_subgroup H, hH, hs, pow_succ', mul_assoc, mul_comm p])
  have hm : s * p % p = card (normalizer H ⧸ H.subgroupOf H.normalizer) % p :=
    card_congr (fixedPointsMulLeftCosetsEquivQuotient H) ▸
      hcard ▸ (IsPGroup.of_card hH).card_modeq_card_fixed_points _
  have hm' : p ∣ card (normalizer H ⧸ H.subgroupOf H.normalizer) :=
    Nat.dvd_of_mod_eq_zero (by rwa [Nat.mod_eq_zero_of_dvd (dvd_mul_left _ _), eq_comm] at hm)
  let ⟨x, hx⟩ := @exists_prime_order_of_dvd_card _ (QuotientGroup.Quotient.group _) _ _ hp hm'
  have hequiv : H ≃ H.subgroupOf H.normalizer := (subgroupOfEquivOfLe le_normalizer).symm.toEquiv
  ⟨Subgroup.map (normalizer H).Subtype
      (Subgroup.comap (mk' (H.subgroupOf H.normalizer)) (zpowers x)),
    by
    show
      card
          ↥(map H.normalizer.subtype
              (comap (mk' (H.subgroup_of H.normalizer)) (Subgroup.zpowers x))) =
        p ^ (n + 1)
    suffices
      card
          ↥(Subtype.val ''
              (Subgroup.comap (mk' (H.subgroup_of H.normalizer)) (zpowers x) : Set ↥H.normalizer)) =
        p ^ (n + 1)
      by convert this using 2
    rw [Set.card_image_of_injective
        (Subgroup.comap (mk' (H.subgroup_of H.normalizer)) (zpowers x) : Set H.normalizer)
        Subtype.val_injective,
      pow_succ', ← hH, Fintype.card_congr hequiv, ← hx, order_eq_card_zpowers, ← Fintype.card_prod]
    exact @Fintype.card_congr _ _ (id _) (id _) (preimage_mk_equiv_subgroup_times_set _ _), by
    intro y hy
    simp only [exists_prop, Subgroup.coe_subtype, mk'_apply, Subgroup.mem_map, Subgroup.mem_comap]
    refine' ⟨⟨y, le_normalizer hy⟩, ⟨0, _⟩, rfl⟩
    rw [zpow_zero, eq_comm, QuotientGroup.eq_one_iff]
    simpa using hy⟩
#align sylow.exists_subgroup_card_pow_succ Sylow.exists_subgroup_card_pow_succ

/-- If `H` is a subgroup of `G` of cardinality `p ^ n`,
  then `H` is contained in a subgroup of cardinality `p ^ m`
  if `n ≤ m` and `p ^ m` divides the cardinality of `G` -/
theorem exists_subgroup_card_pow_prime_le [Fintype G] (p : ℕ) :
    ∀ {n m : ℕ} [hp : Fact p.Prime] (hdvd : p ^ m ∣ card G) (H : Subgroup G) (hH : card H = p ^ n)
      (hnm : n ≤ m), ∃ K : Subgroup G, card K = p ^ m ∧ H ≤ K
  | n, m => fun hp hdvd H hH hnm =>
    (lt_or_eq_of_le hnm).elim
      (fun hnm : n < m =>
        have h0m : 0 < m := lt_of_le_of_lt n.zero_le hnm
        have wf : m - 1 < m := Nat.sub_lt h0m zero_lt_one
        have hnm1 : n ≤ m - 1 := le_tsub_of_add_le_right hnm
        let ⟨K, hK⟩ :=
          @exists_subgroup_card_pow_prime_le n (m - 1) hp
            (Nat.pow_dvd_of_le_of_pow_dvd tsub_le_self hdvd) H hH hnm1
        have hdvd' : p ^ (m - 1 + 1) ∣ card G := by rwa [tsub_add_cancel_of_le h0m.nat_succ_le]
        let ⟨K', hK'⟩ := @exists_subgroup_card_pow_succ _ _ _ _ _ hp hdvd' K hK.1
        ⟨K', by rw [hK'.1, tsub_add_cancel_of_le h0m.nat_succ_le], le_trans hK.2 hK'.2⟩)
      fun hnm : n = m => ⟨H, by simp [hH, hnm]⟩
#align sylow.exists_subgroup_card_pow_prime_le Sylow.exists_subgroup_card_pow_prime_le

/-- A generalisation of **Sylow's first theorem**. If `p ^ n` divides
  the cardinality of `G`, then there is a subgroup of cardinality `p ^ n` -/
theorem exists_subgroup_card_pow_prime [Fintype G] (p : ℕ) {n : ℕ} [Fact p.Prime]
    (hdvd : p ^ n ∣ card G) : ∃ K : Subgroup G, Fintype.card K = p ^ n :=
  let ⟨K, hK⟩ := exists_subgroup_card_pow_prime_le p hdvd ⊥ (by simp) n.zero_le
  ⟨K, hK.1⟩
#align sylow.exists_subgroup_card_pow_prime Sylow.exists_subgroup_card_pow_prime

theorem pow_dvd_card_of_pow_dvd_card [Fintype G] {p n : ℕ} [hp : Fact p.Prime] (P : Sylow p G)
    (hdvd : p ^ n ∣ card G) : p ^ n ∣ card P :=
  (hp.1.coprime_pow_of_not_dvd
          (not_dvd_index_sylow P index_ne_zero_of_finite)).symm.dvd_of_dvd_mul_left
    ((index_mul_card P.1).symm ▸ hdvd)
#align sylow.pow_dvd_card_of_pow_dvd_card Sylow.pow_dvd_card_of_pow_dvd_card

theorem dvd_card_of_dvd_card [Fintype G] {p : ℕ} [Fact p.Prime] (P : Sylow p G)
    (hdvd : p ∣ card G) : p ∣ card P := by
  rw [← pow_one p] at hdvd
  have key := P.pow_dvd_card_of_pow_dvd_card hdvd
  rwa [pow_one] at key
#align sylow.dvd_card_of_dvd_card Sylow.dvd_card_of_dvd_card

/-- Sylow subgroups are Hall subgroups. -/
theorem card_coprime_index [Fintype G] {p : ℕ} [hp : Fact p.Prime] (P : Sylow p G) :
    (card P).Coprime (index (P : Subgroup G)) :=
  let ⟨n, hn⟩ := IsPGroup.iff_card.mp P.2
  hn.symm ▸ (hp.1.coprime_pow_of_not_dvd (not_dvd_index_sylow P index_ne_zero_of_finite)).symm
#align sylow.card_coprime_index Sylow.card_coprime_index

theorem ne_bot_of_dvd_card [Fintype G] {p : ℕ} [hp : Fact p.Prime] (P : Sylow p G)
    (hdvd : p ∣ card G) : (P : Subgroup G) ≠ ⊥ := by
  refine' fun h => hp.out.not_dvd_one _
  have key : p ∣ card (P : Subgroup G) := P.dvd_card_of_dvd_card hdvd
  rwa [h, card_bot] at key
#align sylow.ne_bot_of_dvd_card Sylow.ne_bot_of_dvd_card

/-- The cardinality of a Sylow group is `p ^ n`
 where `n` is the multiplicity of `p` in the group order. -/
theorem card_eq_multiplicity [Fintype G] {p : ℕ} [hp : Fact p.Prime] (P : Sylow p G) :
    card P = p ^ Nat.factorization (card G) p := by
  obtain ⟨n, heq : card P = _⟩ := is_p_group.iff_card.mp P.is_p_group'
  refine' Nat.dvd_antisymm _ (P.pow_dvd_card_of_pow_dvd_card (Nat.ord_proj_dvd _ p))
  rw [HEq, ← hp.out.pow_dvd_iff_dvd_ord_proj (show card G ≠ 0 from card_ne_zero), ← HEq]
  exact P.1.card_subgroup_dvd_card
#align sylow.card_eq_multiplicity Sylow.card_eq_multiplicity

theorem subsingleton_of_normal {p : ℕ} [Fact p.Prime] [Finite (Sylow p G)] (P : Sylow p G)
    (h : (P : Subgroup G).Normal) : Subsingleton (Sylow p G) := by
  apply Subsingleton.intro
  intro Q R
  obtain ⟨x, h1⟩ := exists_smul_eq G P Q
  obtain ⟨x, h2⟩ := exists_smul_eq G P R
  rw [Sylow.smul_eq_of_normal] at h1 h2
  rw [← h1, ← h2]
#align sylow.subsingleton_of_normal Sylow.subsingleton_of_normal

section Pointwise

open Pointwise

theorem characteristic_of_normal {p : ℕ} [Fact p.Prime] [Finite (Sylow p G)] (P : Sylow p G)
    (h : (P : Subgroup G).Normal) : (P : Subgroup G).Characteristic := by
  haveI := Sylow.subsingleton_of_normal P h
  rw [characteristic_iff_map_eq]
  intro Φ
  show (Φ • P).toSubgroup = P.to_subgroup
  congr
#align sylow.characteristic_of_normal Sylow.characteristic_of_normal

end Pointwise

theorem normal_of_normalizer_normal {p : ℕ} [Fact p.Prime] [Finite (Sylow p G)] (P : Sylow p G)
    (hn : (↑P : Subgroup G).normalizer.Normal) : (↑P : Subgroup G).Normal := by
  rw [← normalizer_eq_top, ← normalizer_sup_eq_top' P le_normalizer, sup_idem]
#align sylow.normal_of_normalizer_normal Sylow.normal_of_normalizer_normal

@[simp]
theorem normalizer_normalizer {p : ℕ} [Fact p.Prime] [Finite (Sylow p G)] (P : Sylow p G) :
    (↑P : Subgroup G).normalizer.normalizer = (↑P : Subgroup G).normalizer := by
  have := normal_of_normalizer_normal (P.subtype (le_normalizer.trans le_normalizer))
  simp_rw [← normalizer_eq_top, coeSubtype, ← subgroup_of_normalizer_eq le_normalizer, ←
    subgroup_of_normalizer_eq le_rfl, subgroup_of_self] at this
  rw [← subtype_range (P : Subgroup G).normalizer.normalizer, MonoidHom.range_eq_map, ← this rfl]
  exact map_comap_eq_self (le_normalizer.trans (ge_of_eq (subtype_range _)))
#align sylow.normalizer_normalizer Sylow.normalizer_normalizer

theorem normal_of_all_max_subgroups_normal [Finite G]
    (hnc : ∀ H : Subgroup G, IsCoatom H → H.Normal) {p : ℕ} [Fact p.Prime] [Finite (Sylow p G)]
    (P : Sylow p G) : (↑P : Subgroup G).Normal :=
  normalizer_eq_top.mp
    (by 
      rcases eq_top_or_exists_le_coatom (↑P : Subgroup G).normalizer with (heq | ⟨K, hK, hNK⟩)
      · exact HEq
      · haveI := hnc _ hK
        have hPK : ↑P ≤ K := le_trans le_normalizer hNK
        refine' (hK.1 _).elim
        rw [← sup_of_le_right hNK, P.normalizer_sup_eq_top' hPK])
#align sylow.normal_of_all_max_subgroups_normal Sylow.normal_of_all_max_subgroups_normal

theorem normal_of_normalizer_condition (hnc : NormalizerCondition G) {p : ℕ} [Fact p.Prime]
    [Finite (Sylow p G)] (P : Sylow p G) : (↑P : Subgroup G).Normal :=
  normalizer_eq_top.mp <|
    normalizer_condition_iff_only_full_group_self_normalizing.mp hnc _ <| normalizer_normalizer _
#align sylow.normal_of_normalizer_condition Sylow.normal_of_normalizer_condition

open BigOperators

/-- If all its sylow groups are normal, then a finite group is isomorphic to the direct product
of these sylow groups.
-/
noncomputable def directProductOfNormal [Fintype G]
    (hn : ∀ {p : ℕ} [Fact p.Prime] (P : Sylow p G), (↑P : Subgroup G).Normal) :
    (∀ p : (card G).factorization.support, ∀ P : Sylow p G, (↑P : Subgroup G)) ≃* G := by
  set ps := (Fintype.card G).factorization.support
  -- “The” sylow group for p
  let P : ∀ p, Sylow p G := default
  have hcomm : Pairwise fun p₁ p₂ : ps => ∀ x y : G, x ∈ P p₁ → y ∈ P p₂ → Commute x y := by
    rintro ⟨p₁, hp₁⟩ ⟨p₂, hp₂⟩ hne
    haveI hp₁' := Fact.mk (Nat.prime_of_mem_factorization hp₁)
    haveI hp₂' := Fact.mk (Nat.prime_of_mem_factorization hp₂)
    have hne' : p₁ ≠ p₂ := by simpa using hne
    apply Subgroup.commute_of_normal_of_disjoint _ _ (hn (P p₁)) (hn (P p₂))
    apply IsPGroup.disjoint_of_ne p₁ p₂ hne' _ _ (P p₁).is_p_group' (P p₂).is_p_group'
  refine' MulEquiv.trans _ _
  -- There is only one sylow group for each p, so the inner product is trivial
  show (∀ p : ps, ∀ P : Sylow p G, P) ≃* ∀ p : ps, P p
  · -- here we need to help the elaborator with an explicit instantiation
    apply @MulEquiv.piCongrRight ps (fun p => ∀ P : Sylow p G, P) (fun p => P p) _ _
    rintro ⟨p, hp⟩
    haveI hp' := Fact.mk (Nat.prime_of_mem_factorization hp)
    haveI := subsingleton_of_normal _ (hn (P p))
    change (∀ P : Sylow p G, P) ≃* P p
    exact MulEquiv.piSubsingleton _ _
  show (∀ p : ps, P p) ≃* G
  apply MulEquiv.ofBijective (Subgroup.noncommPiCoprod hcomm)
  apply (bijective_iff_injective_and_card _).mpr
  constructor
  show injective _
  · apply Subgroup.injective_noncomm_pi_coprod_of_independent
    apply independent_of_coprime_order hcomm
    rintro ⟨p₁, hp₁⟩ ⟨p₂, hp₂⟩ hne
    haveI hp₁' := Fact.mk (Nat.prime_of_mem_factorization hp₁)
    haveI hp₂' := Fact.mk (Nat.prime_of_mem_factorization hp₂)
    have hne' : p₁ ≠ p₂ := by simpa using hne
    apply IsPGroup.coprime_card_of_ne p₁ p₂ hne' _ _ (P p₁).is_p_group' (P p₂).is_p_group'
  show card (∀ p : ps, P p) = card G
  ·
    calc
      card (∀ p : ps, P p) = ∏ p : ps, card ↥(P p) := Fintype.card_pi
      _ = ∏ p : ps, p.1 ^ (card G).factorization p.1 := by
        congr 1 with ⟨p, hp⟩
        exact @card_eq_multiplicity _ _ _ p ⟨Nat.prime_of_mem_factorization hp⟩ (P p)
      _ = ∏ p in ps, p ^ (card G).factorization p :=
        Finset.prod_finset_coe (fun p => p ^ (card G).factorization p) _
      _ = (card G).factorization.Prod pow := rfl
      _ = card G := Nat.factorization_prod_pow_eq_self Fintype.card_ne_zero
      
#align sylow.direct_product_of_normal Sylow.directProductOfNormal

end Sylow

