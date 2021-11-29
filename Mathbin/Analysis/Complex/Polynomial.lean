import Mathbin.Analysis.SpecialFunctions.Pow 
import Mathbin.FieldTheory.IsAlgClosed.Basic 
import Mathbin.Topology.Algebra.Polynomial

/-!
# The fundamental theorem of algebra

This file proves that every nonconstant complex polynomial has a root.

As a consequence, the complex numbers are algebraically closed.
-/


open Complex Polynomial Metric Filter IsAbsoluteValue Set

open_locale Classical

namespace Complex

/-- **Fundamental theorem of algebra**: every non constant complex polynomial
  has a root -/
theorem exists_root {f : Polynomial ℂ} (hf : 0 < degree f) : ∃ z : ℂ, is_root f z :=
  let ⟨z₀, hz₀⟩ := f.exists_forall_norm_le 
  Exists.introₓ z₀$
    Classical.by_contradiction$
      fun hf0 =>
        have hfX : f - C (f.eval z₀) ≠ 0 := mt sub_eq_zero.1 fun h => not_le_of_gtₓ hf (h.symm ▸ degree_C_le)
        let n := root_multiplicity z₀ (f - C (f.eval z₀))
        let g := (f - C (f.eval z₀)) /ₘ (X - C z₀^n)
        have hg0 : g.eval z₀ ≠ 0 := eval_div_by_monic_pow_root_multiplicity_ne_zero _ hfX 
        have hg : (g*X - C z₀^n) = f - C (f.eval z₀) := div_by_monic_mul_pow_root_multiplicity_eq _ _ 
        have hn0 : 0 < n :=
          Nat.pos_of_ne_zeroₓ$
            fun hn0 =>
              by 
                simpa [g, hn0] using hg0 
        let ⟨δ', hδ'₁, hδ'₂⟩ := continuous_iff.1 (Polynomial.continuous g) z₀ (g.eval z₀).abs (Complex.abs_pos.2 hg0)
        let δ := min (min (δ' / 2) 1) ((f.eval z₀).abs / (g.eval z₀).abs / 2)
        have hf0' : 0 < (f.eval z₀).abs := Complex.abs_pos.2 hf0 
        have hg0' : 0 < abs (eval z₀ g) := Complex.abs_pos.2 hg0 
        have hfg0 : 0 < (f.eval z₀).abs / abs (eval z₀ g) := div_pos hf0' hg0' 
        have hδ0 : 0 < δ :=
          lt_minₓ
            (lt_minₓ (half_pos hδ'₁)
              (by 
                normNum))
            (half_pos hfg0)
        have hδ : ∀ (z : ℂ), abs (z - z₀) = δ → abs (g.eval z - g.eval z₀) < (g.eval z₀).abs :=
          fun z hz =>
            hδ'₂ z
              (by 
                rw [Complex.dist_eq, hz] <;>
                  exact ((min_le_leftₓ _ _).trans (min_le_leftₓ _ _)).trans_lt (half_lt_self hδ'₁))
        have hδ1 : δ ≤ 1 := le_transₓ (min_le_leftₓ _ _) (min_le_rightₓ _ _)
        let F : Polynomial ℂ := C (f.eval z₀)+C (g.eval z₀)*X - C z₀^n 
        let z' := (((((-f.eval z₀)*(g.eval z₀).abs)*δ^n) / (f.eval z₀).abs*g.eval z₀)^(n⁻¹ : ℂ))+z₀ 
        have hF₁ : F.eval z' = f.eval z₀ - ((f.eval z₀*(g.eval z₀).abs)*δ^n) / (f.eval z₀).abs :=
          by 
            simp only [F, cpow_nat_inv_pow _ hn0, div_eq_mul_inv, eval_pow, mul_assocₓ, mul_commₓ (g.eval z₀),
                mul_left_commₓ (g.eval z₀), mul_left_commₓ (g.eval z₀⁻¹), mul_inv₀, inv_mul_cancel hg0, eval_C,
                eval_add, eval_neg, sub_eq_add_neg, eval_mul, eval_X, add_neg_cancel_rightₓ, neg_mul_eq_neg_mul_symm,
                mul_oneₓ, div_eq_mul_inv] <;>
              simp only [mul_commₓ, mul_left_commₓ, mul_assocₓ]
        have hδs : ((g.eval z₀).abs*δ^n) / (f.eval z₀).abs < 1 :=
          (div_lt_one hf0').2$
            (lt_div_iff' hg0').1$
              calc (δ^n) ≤ (δ^1) := pow_le_pow_of_le_one (le_of_ltₓ hδ0) hδ1 hn0 
                _ = δ := pow_oneₓ _ 
                _ ≤ (f.eval z₀).abs / (g.eval z₀).abs / 2 := min_le_rightₓ _ _ 
                _ < _ := half_lt_self (div_pos hf0' hg0')
                
        have hF₂ : (F.eval z').abs = (f.eval z₀).abs - (g.eval z₀).abs*δ^n :=
          calc (F.eval z').abs = (f.eval z₀ - ((f.eval z₀*(g.eval z₀).abs)*δ^n) / (f.eval z₀).abs).abs :=
            congr_argₓ abs hF₁ 
            _ = abs (f.eval z₀)*Complex.abs (1 - ((g.eval z₀).abs*δ^n) / (f.eval z₀).abs : ℝ) :=
            by 
              rw [←Complex.abs_mul] <;>
                exact
                  congr_argₓ Complex.abs
                    (by 
                      simp [mul_addₓ, add_mulₓ, mul_assocₓ, div_eq_mul_inv, sub_eq_add_neg])
            _ = _ :=
            by 
              rw [Complex.abs_of_nonneg (sub_nonneg.2 (le_of_ltₓ hδs)), mul_sub,
                mul_div_cancel' _ (Ne.symm (ne_of_ltₓ hf0')), mul_oneₓ]
            
        have hef0 : (abs (eval z₀ g)*(eval z₀ f).abs) ≠ 0 :=
          mul_ne_zero (mt Complex.abs_eq_zero.1 hg0) (mt Complex.abs_eq_zero.1 hf0)
        have hz'z₀ : abs (z' - z₀) = δ :=
          by 
            simp [z', mul_assocₓ, mul_left_commₓ _ (_^n), mul_commₓ _ (_^n), mul_commₓ (eval z₀ f).abs,
              _root_.mul_div_cancel _ hef0, of_real_mul, neg_mul_eq_neg_mul_symm, neg_div,
              IsAbsoluteValue.abv_pow Complex.abs, Complex.abs_of_nonneg (le_of_ltₓ hδ0),
              Real.pow_nat_rpow_nat_inv (le_of_ltₓ hδ0) hn0]
        have hF₃ : (f.eval z' - F.eval z').abs < (g.eval z₀).abs*δ^n :=
          calc (f.eval z' - F.eval z').abs = (g.eval z' - g.eval z₀).abs*(z' - z₀).abs^n :=
            by 
              rw [←eq_sub_iff_add_eq.1 hg, ←IsAbsoluteValue.abv_pow Complex.abs, ←Complex.abs_mul, sub_mul] <;>
                simp [F, eval_pow, eval_add, eval_mul, eval_sub, eval_C, eval_X, eval_neg, add_sub_cancel,
                  sub_eq_add_neg, add_assocₓ]
            _ = (g.eval z' - g.eval z₀).abs*δ^n :=
            by 
              rw [hz'z₀]
            _ < _ := (mul_lt_mul_right (pow_pos hδ0 _)).2 (hδ _ hz'z₀)
            
        lt_irreflₓ (f.eval z₀).abs$
          calc (f.eval z₀).abs ≤ (f.eval z').abs := hz₀ _ 
            _ = (F.eval z'+f.eval z' - F.eval z').abs :=
            by 
              simp 
            _ ≤ (F.eval z').abs+(f.eval z' - F.eval z').abs := Complex.abs_add _ _ 
            _ < ((f.eval z₀).abs - (g.eval z₀).abs*δ^n)+(g.eval z₀).abs*δ^n :=
            add_lt_add_of_le_of_lt
              (by 
                rw [hF₂])
              hF₃ 
            _ = (f.eval z₀).abs := sub_add_cancel _ _
            

instance IsAlgClosed : IsAlgClosed ℂ :=
  IsAlgClosed.of_exists_root _$ fun p _ hp => Complex.exists_root$ degree_pos_of_irreducible hp

end Complex

