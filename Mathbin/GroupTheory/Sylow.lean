import Mathbin.Data.SetLike.Fintype 
import Mathbin.GroupTheory.GroupAction.ConjAct 
import Mathbin.GroupTheory.PGroup

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
* `sylow_conjugate`: A generalization of Sylow's second theorem:
  If the number of Sylow `p`-subgroups is finite, then all Sylow `p`-subgroups are conjugate.
* `card_sylow_modeq_one`: A generalization of Sylow's third theorem:
  If the number of Sylow `p`-subgroups is finite, then it is congruent to `1` modulo `p`.
-/


open Fintype MulAction Subgroup

section InfiniteSylow

variable(p : ℕ)(G : Type _)[Groupₓ G]

/-- A Sylow `p`-subgroup is a maximal `p`-subgroup. -/
structure Sylow extends Subgroup G where 
  is_p_group' : IsPGroup p to_subgroup 
  is_maximal' : ∀ {Q : Subgroup G}, IsPGroup p Q → to_subgroup ≤ Q → Q = to_subgroup

variable{p}{G}

namespace Sylow

instance  : Coe (Sylow p G) (Subgroup G) :=
  ⟨Sylow.toSubgroup⟩

@[simp]
theorem to_subgroup_eq_coe {P : Sylow p G} : P.to_subgroup = «expr↑ » P :=
  rfl

@[ext]
theorem ext {P Q : Sylow p G} (h : (P : Subgroup G) = Q) : P = Q :=
  by 
    cases P <;> cases Q <;> congr

theorem ext_iff {P Q : Sylow p G} : P = Q ↔ (P : Subgroup G) = Q :=
  ⟨congr_argₓ coeₓ, ext⟩

instance  : SetLike (Sylow p G) G :=
  { coe := coeₓ, coe_injective' := fun P Q h => ext (SetLike.coe_injective h) }

end Sylow

/-- A generalization of **Sylow's first theorem**.
  Every `p`-subgroup is contained in a Sylow `p`-subgroup. -/
theorem IsPGroup.exists_le_sylow {P : Subgroup G} (hP : IsPGroup p P) : ∃ Q : Sylow p G, P ≤ Q :=
  Exists.elim
    (Zorn.zorn_nonempty_partial_order₀ { Q:Subgroup G | IsPGroup p Q }
      (fun c hc1 hc2 Q hQ =>
        ⟨{ Carrier := ⋃R : c, R, one_mem' := ⟨Q, ⟨⟨Q, hQ⟩, rfl⟩, Q.one_mem⟩,
            inv_mem' := fun g ⟨_, ⟨R, rfl⟩, hg⟩ => ⟨R, ⟨R, rfl⟩, R.1.inv_mem hg⟩,
            mul_mem' :=
              fun g h ⟨_, ⟨R, rfl⟩, hg⟩ ⟨_, ⟨S, rfl⟩, hh⟩ =>
                (hc2.total_of_refl R.2 S.2).elim (fun T => ⟨S, ⟨S, rfl⟩, S.1.mul_mem (T hg) hh⟩)
                  fun T => ⟨R, ⟨R, rfl⟩, R.1.mul_mem hg (T hh)⟩ },
          fun ⟨g, _, ⟨S, rfl⟩, hg⟩ =>
            by 
              refine' exists_imp_exists (fun k hk => _) (hc1 S.2 ⟨g, hg⟩)
              rwa [Subtype.ext_iff, coe_pow] at hk⊢,
          fun M hM g hg => ⟨M, ⟨⟨M, hM⟩, rfl⟩, hg⟩⟩)
      P hP)
    fun Q ⟨hQ1, hQ2, hQ3⟩ => ⟨⟨Q, hQ1, hQ3⟩, hQ2⟩

instance Sylow.nonempty : Nonempty (Sylow p G) :=
  nonempty_of_exists IsPGroup.of_bot.exists_le_sylow

noncomputable instance Sylow.inhabited : Inhabited (Sylow p G) :=
  Classical.inhabitedOfNonempty Sylow.nonempty

open_locale Pointwise

/-- `subgroup.pointwise_mul_action` preserves Sylow subgroups. -/
instance Sylow.pointwiseMulAction {α : Type _} [Groupₓ α] [MulDistribMulAction α G] : MulAction α (Sylow p G) :=
  { smul :=
      fun g P =>
        ⟨g • P, P.2.map _,
          fun Q hQ hS =>
            inv_smul_eq_iff.mp
              (P.3 (hQ.map _)
                fun s hs =>
                  (congr_argₓ (· ∈ g⁻¹ • Q) (inv_smul_smul g s)).mp
                    (smul_mem_pointwise_smul (g • s) (g⁻¹) Q (hS (smul_mem_pointwise_smul s g P hs))))⟩,
    one_smul := fun P => Sylow.ext (one_smul α P), mul_smul := fun g h P => Sylow.ext (mul_smul g h P) }

theorem Sylow.pointwise_smul_def {α : Type _} [Groupₓ α] [MulDistribMulAction α G] {g : α} {P : Sylow p G} :
  «expr↑ » (g • P) = g • (P : Subgroup G) :=
  rfl

instance Sylow.mulAction : MulAction G (Sylow p G) :=
  comp_hom _ MulAut.conj

theorem Sylow.smul_def {g : G} {P : Sylow p G} : g • P = MulAut.conj g • P :=
  rfl

theorem Sylow.coe_subgroup_smul {g : G} {P : Sylow p G} : «expr↑ » (g • P) = MulAut.conj g • (P : Subgroup G) :=
  rfl

theorem Sylow.coe_smul {g : G} {P : Sylow p G} : «expr↑ » (g • P) = MulAut.conj g • (P : Set G) :=
  rfl

theorem Sylow.smul_eq_iff_mem_normalizer {g : G} {P : Sylow p G} : g • P = P ↔ g ∈ P.1.normalizer :=
  by 
    rw [eq_comm, SetLike.ext_iff, ←inv_mem_iff, mem_normalizer_iff, inv_invₓ]
    exact
      forall_congrₓ
        fun h =>
          iff_congr Iff.rfl
            ⟨fun ⟨a, b, c⟩ =>
                (congr_argₓ _ c).mp ((congr_argₓ (· ∈ P.1) (MulAut.inv_apply_self G (MulAut.conj g) a)).mpr b),
              fun hh => ⟨(MulAut.conj g⁻¹) h, hh, MulAut.apply_inv_self G (MulAut.conj g) h⟩⟩

theorem Subgroup.sylow_mem_fixed_points_iff (H : Subgroup G) {P : Sylow p G} :
  P ∈ fixed_points H (Sylow p G) ↔ H ≤ P.1.normalizer :=
  by 
    simpRw [SetLike.le_def, ←Sylow.smul_eq_iff_mem_normalizer] <;> exact Subtype.forall

theorem IsPGroup.inf_normalizer_sylow {P : Subgroup G} (hP : IsPGroup p P) (Q : Sylow p G) : P⊓Q.1.normalizer = P⊓Q :=
  le_antisymmₓ
    (le_inf inf_le_left (sup_eq_right.mp (Q.3 (hP.to_inf_left.to_sup_of_normal_right' Q.2 inf_le_right) le_sup_right)))
    (inf_le_inf_left P le_normalizer)

theorem IsPGroup.sylow_mem_fixed_points_iff {P : Subgroup G} (hP : IsPGroup p P) {Q : Sylow p G} :
  Q ∈ fixed_points P (Sylow p G) ↔ P ≤ Q :=
  by 
    rw [P.sylow_mem_fixed_points_iff, ←inf_eq_left, hP.inf_normalizer_sylow, inf_eq_left]

-- error in GroupTheory.Sylow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- A generalization of **Sylow's second theorem**.
  If the number of Sylow `p`-subgroups is finite, then all Sylow `p`-subgroups are conjugate. -/
instance [hp : fact p.prime] [fintype (sylow p G)] : is_pretransitive G (sylow p G) :=
⟨λ P Q, by { classical,
   have [ident H] [] [":=", expr λ {R : sylow p G} {S : orbit G P}, calc
      «expr ↔ »(«expr ∈ »(S, fixed_points R (orbit G P)), «expr ∈ »(S.1, fixed_points R (sylow p G))) : forall_congr (λ
       a, subtype.ext_iff)
      «expr ↔ »(..., «expr ≤ »(R.1, S)) : R.2.sylow_mem_fixed_points_iff
      «expr ↔ »(..., «expr = »(S.1.1, R)) : ⟨λ h, R.3 S.1.2 h, ge_of_eq⟩],
   suffices [] [":", expr set.nonempty (fixed_points Q (orbit G P))],
   { exact [expr exists.elim this (λ R hR, (congr_arg _ (sylow.ext (H.mp hR))).mp R.2)] },
   apply [expr Q.2.nonempty_fixed_point_of_prime_not_dvd_card],
   refine [expr λ h, hp.out.not_dvd_one (nat.modeq_zero_iff_dvd.mp _)],
   calc
     «expr = »(1, card (fixed_points P (orbit G P))) : _
     «expr ≡ [MOD ]»(..., card (orbit G P), p) : (P.2.card_modeq_card_fixed_points (orbit G P)).symm
     «expr ≡ [MOD ]»(..., 0, p) : nat.modeq_zero_iff_dvd.mpr h,
   convert [] [expr (set.card_singleton (⟨P, mem_orbit_self P⟩ : orbit G P)).symm] [],
   exact [expr set.eq_singleton_iff_unique_mem.mpr ⟨H.mpr rfl, λ R h, subtype.ext (sylow.ext (H.mp h))⟩] }⟩

variable(p)(G)

-- error in GroupTheory.Sylow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- A generalization of **Sylow's third theorem**.
  If the number of Sylow `p`-subgroups is finite, then it is congruent to `1` modulo `p`. -/
theorem card_sylow_modeq_one [fact p.prime] [fintype (sylow p G)] : «expr ≡ [MOD ]»(card (sylow p G), 1, p) :=
begin
  refine [expr sylow.nonempty.elim (λ P : sylow p G, _)],
  have [] [] [":=", expr set.ext (λ Q : sylow p G, calc
      «expr ↔ »(«expr ∈ »(Q, fixed_points P (sylow p G)), «expr ≤ »(P.1, Q)) : P.2.sylow_mem_fixed_points_iff
      «expr ↔ »(..., «expr = »(Q.1, P.1)) : ⟨P.3 Q.2, ge_of_eq⟩
      «expr ↔ »(..., «expr ∈ »(Q, {P})) : sylow.ext_iff.symm.trans set.mem_singleton_iff.symm)],
  haveI [] [":", expr fintype (fixed_points P.1 (sylow p G))] [":=", expr by convert [] [expr set.fintype_singleton P] []],
  have [] [":", expr «expr = »(card (fixed_points P.1 (sylow p G)), 1)] [":=", expr by convert [] [expr set.card_singleton P] []],
  exact [expr (P.2.card_modeq_card_fixed_points (sylow p G)).trans (by rw [expr this] [])]
end

variable{p}{G}

/-- Sylow subgroups are isomorphic -/
def Sylow.equivSmul (P : Sylow p G) (g : G) : P ≃* (g • P : Sylow p G) :=
  equiv_smul (MulAut.conj g) P.1

/-- Sylow subgroups are isomorphic -/
noncomputable def Sylow.equiv [Fact p.prime] [Fintype (Sylow p G)] (P Q : Sylow p G) : P ≃* Q :=
  by 
    rw [←Classical.some_spec (exists_smul_eq G P Q)]
    exact P.equiv_smul (Classical.some (exists_smul_eq G P Q))

@[simp]
theorem Sylow.orbit_eq_top [Fact p.prime] [Fintype (Sylow p G)] (P : Sylow p G) : orbit G P = ⊤ :=
  top_le_iff.mp fun Q hQ => exists_smul_eq G P Q

theorem Sylow.stabilizer_eq_normalizer (P : Sylow p G) : stabilizer G P = P.1.normalizer :=
  ext fun g => Sylow.smul_eq_iff_mem_normalizer

/-- Sylow `p`-subgroups are in bijection with cosets of the normalizer of a Sylow `p`-subgroup -/
noncomputable def Sylow.equivQuotientNormalizer [Fact p.prime] [Fintype (Sylow p G)] (P : Sylow p G) :
  Sylow p G ≃ QuotientGroup.Quotient P.1.normalizer :=
  calc Sylow p G ≃ (⊤ : Set (Sylow p G)) := (Equiv.Set.univ (Sylow p G)).symm 
    _ ≃ orbit G P :=
    by 
      rw [P.orbit_eq_top]
    _ ≃ QuotientGroup.Quotient (stabilizer G P) := orbit_equiv_quotient_stabilizer G P 
    _ ≃ QuotientGroup.Quotient P.1.normalizer :=
    by 
      rw [P.stabilizer_eq_normalizer]
    

noncomputable instance  [Fact p.prime] [Fintype (Sylow p G)] (P : Sylow p G) :
  Fintype (QuotientGroup.Quotient P.1.normalizer) :=
  of_equiv (Sylow p G) P.equiv_quotient_normalizer

theorem card_sylow_eq_card_quotient_normalizer [Fact p.prime] [Fintype (Sylow p G)] (P : Sylow p G) :
  card (Sylow p G) = card (QuotientGroup.Quotient P.1.normalizer) :=
  card_congr P.equiv_quotient_normalizer

theorem card_sylow_eq_index_normalizer [Fact p.prime] [Fintype (Sylow p G)] (P : Sylow p G) :
  card (Sylow p G) = P.1.normalizer.index :=
  (card_sylow_eq_card_quotient_normalizer P).trans P.1.normalizer.index_eq_card.symm

theorem card_sylow_dvd_index [Fact p.prime] [Fintype (Sylow p G)] (P : Sylow p G) : card (Sylow p G) ∣ P.1.index :=
  ((congr_argₓ _ (card_sylow_eq_index_normalizer P)).mp dvd_rfl).trans (index_dvd_of_le le_normalizer)

/-- Frattini's Argument: If `N` is a normal subgroup of `G`, and if `P` is a Sylow `p`-subgroup
  of `N`, then `N_G(P) ⊔ N = G`. -/
theorem Sylow.normalizer_sup_eq_top {p : ℕ} [Fact p.prime] {N : Subgroup G} [N.normal] [Fintype (Sylow p N)]
  (P : Sylow p N) : ((«expr↑ » P : Subgroup N).map N.subtype).normalizer⊔N = ⊤ :=
  by 
    refine' top_le_iff.mp fun g hg => _ 
    obtain ⟨n, hn⟩ := exists_smul_eq N ((MulAut.conjNormal g : MulAut N) • P) P 
    rw [←inv_mul_cancel_leftₓ («expr↑ » n) g, sup_comm]
    apply mul_mem_sup (N.inv_mem n.2)
    rw [Sylow.smul_def, ←mul_smul, ←MulAut.conj_normal_coe, ←mul_aut.conj_normal.map_mul, Sylow.ext_iff,
      Sylow.pointwise_smul_def, pointwise_smul_def] at hn 
    refine'
      fun x =>
        (mem_map_iff_mem
                (show Function.Injective (MulAut.conj («expr↑ » n*g)).toMonoidHom from
                  (MulAut.conj («expr↑ » n*g)).Injective)).symm.trans
          _ 
    rw [map_map, ←congr_argₓ (map N.subtype) hn, map_map]
    rfl

end InfiniteSylow

open Equiv Equiv.Perm Finset Function List QuotientGroup

open_locale BigOperators

universe u v w

variable{G : Type u}{α : Type v}{β : Type w}[Groupₓ G]

attribute [local instance] Subtype.fintype setFintype Classical.propDecidable

theorem QuotientGroup.card_preimage_mk [Fintype G] (s : Subgroup G) (t : Set (Quotientₓ s)) :
  Fintype.card (QuotientGroup.mk ⁻¹' t) = Fintype.card s*Fintype.card t :=
  by 
    rw [←Fintype.card_prod, Fintype.card_congr (preimage_mk_equiv_subgroup_times_set _ _)]

namespace Sylow

open Subgroup Submonoid MulAction

-- error in GroupTheory.Sylow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem mem_fixed_points_mul_left_cosets_iff_mem_normalizer
{H : subgroup G}
[fintype ((H : set G) : Type u)]
{x : G} : «expr ↔ »(«expr ∈ »((x : quotient H), fixed_points H (quotient H)), «expr ∈ »(x, normalizer H)) :=
⟨λ
 hx, have ha : ∀
 {y : quotient H}, «expr ∈ »(y, orbit H (x : quotient H)) → «expr = »(y, x), from λ _, (mem_fixed_points' _).1 hx _,
 (inv_mem_iff _).1 (@mem_normalizer_fintype _ _ _ _inst_2 _ (λ
   (n)
   (hn : «expr ∈ »(n, H)), have «expr ∈ »(«expr * »(«expr ⁻¹»(«expr * »(«expr ⁻¹»(n), x)), x), H) := quotient_group.eq.1 (ha (mem_orbit _ ⟨«expr ⁻¹»(n), H.inv_mem hn⟩)),
   show «expr ∈ »(_, H), by { rw ["[", expr mul_inv_rev, ",", expr inv_inv, "]"] ["at", ident this],
     convert [] [expr this] [],
     rw [expr inv_inv] [] })), λ
 hx : ∀
 n : G, «expr ↔ »(«expr ∈ »(n, H), «expr ∈ »(«expr * »(«expr * »(x, n), «expr ⁻¹»(x)), H)), «expr $ »((mem_fixed_points' _).2, λ
  y, «expr $ »(quotient.induction_on' y, λ
   y
   hy, quotient_group.eq.2 (let ⟨⟨b, hb₁⟩, hb₂⟩ := hy in
    have hb₂ : «expr ∈ »(«expr * »(«expr ⁻¹»(«expr * »(b, x)), y), H) := quotient_group.eq.1 hb₂,
    «expr $ »((inv_mem_iff H).1, «expr $ »((hx _).2, «expr $ »((mul_mem_cancel_left H (H.inv_mem hb₁)).1, by rw [expr hx] ["at", ident hb₂]; simpa [] [] [] ["[", expr mul_inv_rev, ",", expr mul_assoc, "]"] [] ["using", expr hb₂]))))))⟩

def fixed_points_mul_left_cosets_equiv_quotient (H : Subgroup G) [Fintype (H : Set G)] :
  MulAction.FixedPoints H (Quotientₓ H) ≃ Quotientₓ (Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H) :=
  @subtype_quotient_equiv_quotient_subtype G (normalizer H : Set G) (id _) (id _) (fixed_points _ _)
    (fun a => (@mem_fixed_points_mul_left_cosets_iff_mem_normalizer _ _ _ _inst_2 _).symm)
    (by 
      intros  <;> rfl)

/-- If `H` is a `p`-subgroup of `G`, then the index of `H` inside its normalizer is congruent
  mod `p` to the index of `H`.  -/
theorem card_quotient_normalizer_modeq_card_quotient [Fintype G] {p : ℕ} {n : ℕ} [hp : Fact p.prime] {H : Subgroup G}
  (hH : Fintype.card H = (p^n)) :
  card (Quotientₓ (Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H)) ≡ card (Quotientₓ H) [MOD p] :=
  by 
    rw [←Fintype.card_congr (fixed_points_mul_left_cosets_equiv_quotient H)]
    exact ((IsPGroup.of_card hH).card_modeq_card_fixed_points _).symm

/-- If `H` is a subgroup of `G` of cardinality `p ^ n`, then the cardinality of the
  normalizer of `H` is congruent mod `p ^ (n + 1)` to the cardinality of `G`.  -/
theorem card_normalizer_modeq_card [Fintype G] {p : ℕ} {n : ℕ} [hp : Fact p.prime] {H : Subgroup G}
  (hH : Fintype.card H = (p^n)) : card (normalizer H) ≡ card G [MOD p^n+1] :=
  have  : Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H ≃ H :=
    Set.BijOn.equiv (normalizer H).Subtype
      ⟨fun _ => id, fun _ _ _ _ h => Subtype.val_injective h, fun x hx => ⟨⟨x, le_normalizer hx⟩, hx, rfl⟩⟩
  by 
    rw [card_eq_card_quotient_mul_card_subgroup H,
      card_eq_card_quotient_mul_card_subgroup (Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H),
      Fintype.card_congr this, hH, pow_succₓ]
    exact (card_quotient_normalizer_modeq_card_quotient hH).mul_right' _

/-- If `H` is a `p`-subgroup but not a Sylow `p`-subgroup, then `p` divides the
  index of `H` inside its normalizer. -/
theorem prime_dvd_card_quotient_normalizer [Fintype G] {p : ℕ} {n : ℕ} [hp : Fact p.prime] (hdvd : (p^n+1) ∣ card G)
  {H : Subgroup G} (hH : Fintype.card H = (p^n)) :
  p ∣ card (Quotientₓ (Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H)) :=
  let ⟨s, hs⟩ := exists_eq_mul_left_of_dvd hdvd 
  have hcard : card (Quotientₓ H) = s*p :=
    (Nat.mul_left_inj (show card H > 0 from Fintype.card_pos_iff.2 ⟨⟨1, H.one_mem⟩⟩)).1
      (by 
        rwa [←card_eq_card_quotient_mul_card_subgroup H, hH, hs, pow_succ'ₓ, mul_assocₓ, mul_commₓ p])
  have hm : (s*p) % p = card (Quotientₓ (Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H)) % p :=
    hcard ▸ (card_quotient_normalizer_modeq_card_quotient hH).symm 
  Nat.dvd_of_mod_eq_zeroₓ
    (by 
      rwa [Nat.mod_eq_zero_of_dvdₓ (dvd_mul_left _ _), eq_comm] at hm)

/-- If `H` is a `p`-subgroup but not a Sylow `p`-subgroup of cardinality `p ^ n`,
  then `p ^ (n + 1)` divides the cardinality of the normalizer of `H`. -/
theorem prime_pow_dvd_card_normalizer [Fintype G] {p : ℕ} {n : ℕ} [hp : Fact p.prime] (hdvd : (p^n+1) ∣ card G)
  {H : Subgroup G} (hH : Fintype.card H = (p^n)) : (p^n+1) ∣ card (normalizer H) :=
  Nat.modeq_zero_iff_dvd.1 ((card_normalizer_modeq_card hH).trans hdvd.modeq_zero_nat)

/-- If `H` is a subgroup of `G` of cardinality `p ^ n`,
  then `H` is contained in a subgroup of cardinality `p ^ (n + 1)`
  if `p ^ (n + 1)` divides the cardinality of `G` -/
theorem exists_subgroup_card_pow_succ [Fintype G] {p : ℕ} {n : ℕ} [hp : Fact p.prime] (hdvd : (p^n+1) ∣ card G)
  {H : Subgroup G} (hH : Fintype.card H = (p^n)) : ∃ K : Subgroup G, Fintype.card K = (p^n+1) ∧ H ≤ K :=
  let ⟨s, hs⟩ := exists_eq_mul_left_of_dvd hdvd 
  have hcard : card (Quotientₓ H) = s*p :=
    (Nat.mul_left_inj (show card H > 0 from Fintype.card_pos_iff.2 ⟨⟨1, H.one_mem⟩⟩)).1
      (by 
        rwa [←card_eq_card_quotient_mul_card_subgroup H, hH, hs, pow_succ'ₓ, mul_assocₓ, mul_commₓ p])
  have hm : (s*p) % p = card (Quotientₓ (Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H)) % p :=
    card_congr (fixed_points_mul_left_cosets_equiv_quotient H) ▸
      hcard ▸ (IsPGroup.of_card hH).card_modeq_card_fixed_points _ 
  have hm' : p ∣ card (Quotientₓ (Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H)) :=
    Nat.dvd_of_mod_eq_zeroₓ
      (by 
        rwa [Nat.mod_eq_zero_of_dvdₓ (dvd_mul_left _ _), eq_comm] at hm)
  let ⟨x, hx⟩ := @exists_prime_order_of_dvd_card _ (QuotientGroup.Quotient.group _) _ _ hp hm' 
  have hequiv : H ≃ Subgroup.comap ((normalizer H).Subtype : normalizer H →* G) H :=
    ⟨fun a => ⟨⟨a.1, le_normalizer a.2⟩, a.2⟩, fun a => ⟨a.1.1, a.2⟩, fun ⟨_, _⟩ => rfl, fun ⟨⟨_, _⟩, _⟩ => rfl⟩
  ⟨Subgroup.map (normalizer H).Subtype (Subgroup.comap (QuotientGroup.mk' (comap H.normalizer.subtype H)) (zpowers x)),
    by 
      show
        card («expr↥ » (map H.normalizer.subtype (comap (mk' (comap H.normalizer.subtype H)) (Subgroup.zpowers x)))) =
          (p^n+1)
      suffices  :
        card
            («expr↥ »
              (Subtype.val ''
                (Subgroup.comap (mk' (comap H.normalizer.subtype H)) (zpowers x) : Set («expr↥ » H.normalizer)))) =
          (p^n+1)
      ·
        convert this using 2
      rw
        [Set.card_image_of_injective
          (Subgroup.comap (mk' (comap H.normalizer.subtype H)) (zpowers x) : Set H.normalizer) Subtype.val_injective,
        pow_succ'ₓ, ←hH, Fintype.card_congr hequiv, ←hx, order_eq_card_zpowers, ←Fintype.card_prod]
      exact @Fintype.card_congr _ _ (id _) (id _) (preimage_mk_equiv_subgroup_times_set _ _),
    by 
      intro y hy 
      simp only [exists_prop, Subgroup.coe_subtype, mk'_apply, Subgroup.mem_map, Subgroup.mem_comap]
      refine' ⟨⟨y, le_normalizer hy⟩, ⟨0, _⟩, rfl⟩
      rw [zpow_zero, eq_comm, QuotientGroup.eq_one_iff]
      simpa using hy⟩

-- error in GroupTheory.Sylow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- If `H` is a subgroup of `G` of cardinality `p ^ n`,
  then `H` is contained in a subgroup of cardinality `p ^ m`
  if `n ≤ m` and `p ^ m` divides the cardinality of `G` -/
theorem exists_subgroup_card_pow_prime_le
[fintype G]
(p : exprℕ()) : ∀
{n m : exprℕ()}
[hp : fact p.prime]
(hdvd : «expr ∣ »(«expr ^ »(p, m), card G))
(H : subgroup G)
(hH : «expr = »(card H, «expr ^ »(p, n)))
(hnm : «expr ≤ »(n, m)), «expr∃ , »((K : subgroup G), «expr ∧ »(«expr = »(card K, «expr ^ »(p, m)), «expr ≤ »(H, K)))
| n, m := λ
hp
hdvd
H
hH
hnm, (lt_or_eq_of_le hnm).elim (λ hnm : «expr < »(n, m), have h0m : «expr < »(0, m), from lt_of_le_of_lt n.zero_le hnm,
 have wf : «expr < »(«expr - »(m, 1), m), from nat.sub_lt h0m zero_lt_one,
 have hnm1 : «expr ≤ »(n, «expr - »(m, 1)), from le_tsub_of_add_le_right hnm,
 let ⟨K, hK⟩ := @exists_subgroup_card_pow_prime_le n «expr - »(m, 1) hp (nat.pow_dvd_of_le_of_pow_dvd tsub_le_self hdvd) H hH hnm1 in
 have hdvd' : «expr ∣ »(«expr ^ »(p, «expr + »(«expr - »(m, 1), 1)), card G), by rwa ["[", expr tsub_add_cancel_of_le h0m.nat_succ_le, "]"] [],
 let ⟨K', hK'⟩ := @exists_subgroup_card_pow_succ _ _ _ _ _ hp hdvd' K hK.1 in
 ⟨K', by rw ["[", expr hK'.1, ",", expr tsub_add_cancel_of_le h0m.nat_succ_le, "]"] [], le_trans hK.2 hK'.2⟩) (λ
 hnm : «expr = »(n, m), ⟨H, by simp [] [] [] ["[", expr hH, ",", expr hnm, "]"] [] []⟩)

/-- A generalisation of **Sylow's first theorem**. If `p ^ n` divides
  the cardinality of `G`, then there is a subgroup of cardinality `p ^ n` -/
theorem exists_subgroup_card_pow_prime [Fintype G] (p : ℕ) {n : ℕ} [Fact p.prime] (hdvd : (p^n) ∣ card G) :
  ∃ K : Subgroup G, Fintype.card K = (p^n) :=
  let ⟨K, hK⟩ :=
    exists_subgroup_card_pow_prime_le p hdvd ⊥
      (by 
        simp )
      n.zero_le
  ⟨K, hK.1⟩

theorem pow_dvd_card_of_pow_dvd_card [Fintype G] {p n : ℕ} [Fact p.prime] (P : Sylow p G) (hdvd : (p^n) ∣ card G) :
  (p^n) ∣ card P :=
  by 
    obtain ⟨Q, hQ⟩ := exists_subgroup_card_pow_prime p hdvd 
    obtain ⟨R, hR⟩ := (IsPGroup.of_card hQ).exists_le_sylow 
    obtain ⟨g, rfl⟩ := exists_smul_eq G R P 
    calc (p^n) = card Q := hQ.symm _ ∣ card R := card_dvd_of_le hR _ = card (g • R) :=
      card_congr (R.equiv_smul g).toEquiv

-- error in GroupTheory.Sylow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem dvd_card_of_dvd_card
[fintype G]
{p : exprℕ()}
[fact p.prime]
(P : sylow p G)
(hdvd : «expr ∣ »(p, card G)) : «expr ∣ »(p, card P) :=
begin
  rw ["<-", expr pow_one p] ["at", ident hdvd],
  have [ident key] [] [":=", expr P.pow_dvd_card_of_pow_dvd_card hdvd],
  rwa [expr pow_one] ["at", ident key]
end

-- error in GroupTheory.Sylow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem ne_bot_of_dvd_card
[fintype G]
{p : exprℕ()}
[hp : fact p.prime]
(P : sylow p G)
(hdvd : «expr ∣ »(p, card G)) : «expr ≠ »((P : subgroup G), «expr⊥»()) :=
begin
  refine [expr λ h, hp.out.not_dvd_one _],
  have [ident key] [":", expr «expr ∣ »(p, card (P : subgroup G))] [":=", expr P.dvd_card_of_dvd_card hdvd],
  rwa ["[", expr h, ",", expr card_bot, "]"] ["at", ident key]
end

end Sylow

