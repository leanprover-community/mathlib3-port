import Mathbin.Algebra.AddTorsor 
import Mathbin.Data.Set.Intervals.UnorderedInterval 
import Mathbin.LinearAlgebra.AffineSpace.Basic 
import Mathbin.LinearAlgebra.BilinearMap 
import Mathbin.LinearAlgebra.Pi 
import Mathbin.LinearAlgebra.Prod 
import Mathbin.Tactic.Abel

/-!
# Affine maps

This file defines affine maps.

## Main definitions

* `affine_map` is the type of affine maps between two affine spaces with the same ring `k`.  Various
  basic examples of affine maps are defined, including `const`, `id`, `line_map` and `homothety`.

## Notations

* `P1 →ᵃ[k] P2` is a notation for `affine_map k P1 P2`;
* `affine_space V P`: a localized notation for `add_torsor V P` defined in
  `linear_algebra.affine_space.basic`.

## Implementation notes

`out_param` is used in the definition of `[add_torsor V P]` to make `V` an implicit argument
(deduced from `P`) in most cases; `include V` is needed in many cases for `V`, and type classes
using it, to be added as implicit arguments to individual lemmas.  As for modules, `k` is an
explicit argument rather than implied by `P` or `V`.

This file only provides purely algebraic definitions and results. Those depending on analysis or
topology are defined elsewhere; see `analysis.normed_space.add_torsor` and
`topology.algebra.affine`.

## References

* https://en.wikipedia.org/wiki/Affine_space
* https://en.wikipedia.org/wiki/Principal_homogeneous_space
-/


open_locale Affine

/-- An `affine_map k P1 P2` (notation: `P1 →ᵃ[k] P2`) is a map from `P1` to `P2` that
induces a corresponding linear map from `V1` to `V2`. -/
structure
  AffineMap(k :
    Type
      _){V1 :
    Type
      _}(P1 :
    Type
      _){V2 :
    Type
      _}(P2 :
    Type
      _)[Ringₓ
      k][AddCommGroupₓ V1][Module k V1][affine_space V1 P1][AddCommGroupₓ V2][Module k V2][affine_space V2 P2] where
  
  toFun : P1 → P2 
  linear : V1 →ₗ[k] V2 
  map_vadd' : ∀ (p : P1) (v : V1), to_fun (v +ᵥ p) = linear v +ᵥ to_fun p

notation:25 P1 " →ᵃ[" k:25 "] " P2:0 => AffineMap k P1 P2

instance  (k : Type _) {V1 : Type _} (P1 : Type _) {V2 : Type _} (P2 : Type _) [Ringₓ k] [AddCommGroupₓ V1]
  [Module k V1] [affine_space V1 P1] [AddCommGroupₓ V2] [Module k V2] [affine_space V2 P2] :
  CoeFun (P1 →ᵃ[k] P2) fun _ => P1 → P2 :=
  ⟨AffineMap.toFun⟩

namespace LinearMap

variable{k :
    Type
      _}{V₁ :
    Type _}{V₂ : Type _}[Ringₓ k][AddCommGroupₓ V₁][Module k V₁][AddCommGroupₓ V₂][Module k V₂](f : V₁ →ₗ[k] V₂)

/-- Reinterpret a linear map as an affine map. -/
def to_affine_map : V₁ →ᵃ[k] V₂ :=
  { toFun := f, linear := f, map_vadd' := fun p v => f.map_add v p }

@[simp]
theorem coe_to_affine_map : «expr⇑ » f.to_affine_map = f :=
  rfl

@[simp]
theorem to_affine_map_linear : f.to_affine_map.linear = f :=
  rfl

end LinearMap

namespace AffineMap

variable{k :
    Type
      _}{V1 :
    Type
      _}{P1 :
    Type
      _}{V2 :
    Type
      _}{P2 :
    Type
      _}{V3 :
    Type
      _}{P3 :
    Type
      _}{V4 :
    Type
      _}{P4 :
    Type
      _}[Ringₓ
      k][AddCommGroupₓ
      V1][Module k
      V1][affine_space V1
      P1][AddCommGroupₓ
      V2][Module k
      V2][affine_space V2
      P2][AddCommGroupₓ V3][Module k V3][affine_space V3 P3][AddCommGroupₓ V4][Module k V4][affine_space V4 P4]

include V1 V2

/-- Constructing an affine map and coercing back to a function
produces the same map. -/
@[simp]
theorem coe_mk (f : P1 → P2) linear add : ((mk f linear add : P1 →ᵃ[k] P2) : P1 → P2) = f :=
  rfl

/-- `to_fun` is the same as the result of coercing to a function. -/
@[simp]
theorem to_fun_eq_coe (f : P1 →ᵃ[k] P2) : f.to_fun = «expr⇑ » f :=
  rfl

/-- An affine map on the result of adding a vector to a point produces
the same result as the linear map applied to that vector, added to the
affine map applied to that point. -/
@[simp]
theorem map_vadd (f : P1 →ᵃ[k] P2) (p : P1) (v : V1) : f (v +ᵥ p) = f.linear v +ᵥ f p :=
  f.map_vadd' p v

/-- The linear map on the result of subtracting two points is the
result of subtracting the result of the affine map on those two
points. -/
@[simp]
theorem linear_map_vsub (f : P1 →ᵃ[k] P2) (p1 p2 : P1) : f.linear (p1 -ᵥ p2) = f p1 -ᵥ f p2 :=
  by 
    convRHS => rw [←vsub_vadd p1 p2, map_vadd, vadd_vsub]

-- error in LinearAlgebra.AffineSpace.AffineMap: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Two affine maps are equal if they coerce to the same function. -/
@[ext #[]]
theorem ext {f g : «expr →ᵃ[ ] »(P1, k, P2)} (h : ∀ p, «expr = »(f p, g p)) : «expr = »(f, g) :=
begin
  rcases [expr f, "with", "⟨", ident f, ",", ident f_linear, ",", ident f_add, "⟩"],
  rcases [expr g, "with", "⟨", ident g, ",", ident g_linear, ",", ident g_add, "⟩"],
  have [] [":", expr «expr = »(f, g)] [":=", expr funext h],
  subst [expr g],
  congr' [] ["with", ident v],
  cases [expr (add_torsor.nonempty : nonempty P1)] ["with", ident p],
  apply [expr vadd_right_cancel (f p)],
  erw ["[", "<-", expr f_add, ",", "<-", expr g_add, "]"] []
end

theorem ext_iff {f g : P1 →ᵃ[k] P2} : f = g ↔ ∀ p, f p = g p :=
  ⟨fun h p => h ▸ rfl, ext⟩

theorem coe_fn_injective : @Function.Injective (P1 →ᵃ[k] P2) (P1 → P2) coeFn :=
  fun f g H => ext$ congr_funₓ H

protected theorem congr_argₓ (f : P1 →ᵃ[k] P2) {x y : P1} (h : x = y) : f x = f y :=
  congr_argₓ _ h

protected theorem congr_funₓ {f g : P1 →ᵃ[k] P2} (h : f = g) (x : P1) : f x = g x :=
  h ▸ rfl

variable(k P1)

/-- Constant function as an `affine_map`. -/
def const (p : P2) : P1 →ᵃ[k] P2 :=
  { toFun := Function.const P1 p, linear := 0,
    map_vadd' :=
      fun p v =>
        by 
          simp  }

@[simp]
theorem coe_const (p : P2) : «expr⇑ » (const k P1 p) = Function.const P1 p :=
  rfl

@[simp]
theorem const_linear (p : P2) : (const k P1 p).linear = 0 :=
  rfl

variable{k P1}

theorem linear_eq_zero_iff_exists_const (f : P1 →ᵃ[k] P2) : f.linear = 0 ↔ ∃ q, f = const k P1 q :=
  by 
    refine' ⟨fun h => _, fun h => _⟩
    ·
      inhabit P1 
      use f (default P1)
      ext 
      rw [coe_const, Function.const_applyₓ, ←@vsub_eq_zero_iff_eq V2, ←f.linear_map_vsub, h, LinearMap.zero_apply]
    ·
      rcases h with ⟨q, rfl⟩
      exact const_linear k P1 q

instance Nonempty : Nonempty (P1 →ᵃ[k] P2) :=
  (AddTorsor.nonempty : Nonempty P2).elim$ fun p => ⟨const k P1 p⟩

/-- Construct an affine map by verifying the relation between the map and its linear part at one
base point. Namely, this function takes a map `f : P₁ → P₂`, a linear map `f' : V₁ →ₗ[k] V₂`, and
a point `p` such that for any other point `p'` we have `f p' = f' (p' -ᵥ p) +ᵥ f p`. -/
def mk' (f : P1 → P2) (f' : V1 →ₗ[k] V2) (p : P1) (h : ∀ (p' : P1), f p' = f' (p' -ᵥ p) +ᵥ f p) : P1 →ᵃ[k] P2 :=
  { toFun := f, linear := f',
    map_vadd' :=
      fun p' v =>
        by 
          rw [h, h p', vadd_vsub_assoc, f'.map_add, vadd_vadd] }

@[simp]
theorem coe_mk' (f : P1 → P2) (f' : V1 →ₗ[k] V2) p h : «expr⇑ » (mk' f f' p h) = f :=
  rfl

@[simp]
theorem mk'_linear (f : P1 → P2) (f' : V1 →ₗ[k] V2) p h : (mk' f f' p h).linear = f' :=
  rfl

/-- The set of affine maps to a vector space is an additive commutative group. -/
instance  : AddCommGroupₓ (P1 →ᵃ[k] V2) :=
  { zero := ⟨0, 0, fun p v => (zero_vadd _ _).symm⟩,
    add :=
      fun f g =>
        ⟨f+g, f.linear+g.linear,
          fun p v =>
            by 
              simp [add_add_add_commₓ]⟩,
    sub :=
      fun f g =>
        ⟨f - g, f.linear - g.linear,
          fun p v =>
            by 
              simp [sub_add_comm]⟩,
    sub_eq_add_neg := fun f g => ext$ fun p => sub_eq_add_neg _ _,
    neg :=
      fun f =>
        ⟨-f, -f.linear,
          fun p v =>
            by 
              simp [add_commₓ]⟩,
    add_assoc := fun f₁ f₂ f₃ => ext$ fun p => add_assocₓ _ _ _, zero_add := fun f => ext$ fun p => zero_addₓ (f p),
    add_zero := fun f => ext$ fun p => add_zeroₓ (f p), add_comm := fun f g => ext$ fun p => add_commₓ (f p) (g p),
    add_left_neg := fun f => ext$ fun p => add_left_negₓ (f p) }

@[simp, normCast]
theorem coe_zero : «expr⇑ » (0 : P1 →ᵃ[k] V2) = 0 :=
  rfl

@[simp]
theorem zero_linear : (0 : P1 →ᵃ[k] V2).linear = 0 :=
  rfl

@[simp, normCast]
theorem coe_add (f g : P1 →ᵃ[k] V2) : «expr⇑ » (f+g) = f+g :=
  rfl

@[simp, normCast]
theorem coe_neg (f : P1 →ᵃ[k] V2) : «expr⇑ » (-f) = -f :=
  rfl

@[simp, normCast]
theorem coe_sub (f g : P1 →ᵃ[k] V2) : «expr⇑ » (f - g) = f - g :=
  rfl

@[simp]
theorem add_linear (f g : P1 →ᵃ[k] V2) : (f+g).linear = f.linear+g.linear :=
  rfl

@[simp]
theorem sub_linear (f g : P1 →ᵃ[k] V2) : (f - g).linear = f.linear - g.linear :=
  rfl

@[simp]
theorem neg_linear (f : P1 →ᵃ[k] V2) : (-f).linear = -f.linear :=
  rfl

/-- The space of affine maps from `P1` to `P2` is an affine space over the space of affine maps
from `P1` to the vector space `V2` corresponding to `P2`. -/
instance  : affine_space (P1 →ᵃ[k] V2) (P1 →ᵃ[k] P2) :=
  { vadd :=
      fun f g =>
        ⟨fun p => f p +ᵥ g p, f.linear+g.linear,
          fun p v =>
            by 
              simp [vadd_vadd, add_right_commₓ]⟩,
    zero_vadd := fun f => ext$ fun p => zero_vadd _ (f p),
    add_vadd := fun f₁ f₂ f₃ => ext$ fun p => add_vadd (f₁ p) (f₂ p) (f₃ p),
    vsub :=
      fun f g =>
        ⟨fun p => f p -ᵥ g p, f.linear - g.linear,
          fun p v =>
            by 
              simp [vsub_vadd_eq_vsub_sub, vadd_vsub_assoc, add_sub, sub_add_eq_add_sub]⟩,
    vsub_vadd' := fun f g => ext$ fun p => vsub_vadd (f p) (g p),
    vadd_vsub' := fun f g => ext$ fun p => vadd_vsub (f p) (g p) }

@[simp]
theorem vadd_apply (f : P1 →ᵃ[k] V2) (g : P1 →ᵃ[k] P2) (p : P1) : (f +ᵥ g) p = f p +ᵥ g p :=
  rfl

@[simp]
theorem vsub_apply (f g : P1 →ᵃ[k] P2) (p : P1) : (f -ᵥ g : P1 →ᵃ[k] V2) p = f p -ᵥ g p :=
  rfl

/-- `prod.fst` as an `affine_map`. -/
def fst : P1 × P2 →ᵃ[k] P1 :=
  { toFun := Prod.fst, linear := LinearMap.fst k V1 V2, map_vadd' := fun _ _ => rfl }

@[simp]
theorem coe_fst : «expr⇑ » (fst : P1 × P2 →ᵃ[k] P1) = Prod.fst :=
  rfl

@[simp]
theorem fst_linear : (fst : P1 × P2 →ᵃ[k] P1).linear = LinearMap.fst k V1 V2 :=
  rfl

/-- `prod.snd` as an `affine_map`. -/
def snd : P1 × P2 →ᵃ[k] P2 :=
  { toFun := Prod.snd, linear := LinearMap.snd k V1 V2, map_vadd' := fun _ _ => rfl }

@[simp]
theorem coe_snd : «expr⇑ » (snd : P1 × P2 →ᵃ[k] P2) = Prod.snd :=
  rfl

@[simp]
theorem snd_linear : (snd : P1 × P2 →ᵃ[k] P2).linear = LinearMap.snd k V1 V2 :=
  rfl

variable(k P1)

omit V2

/-- Identity map as an affine map. -/
def id : P1 →ᵃ[k] P1 :=
  { toFun := id, linear := LinearMap.id, map_vadd' := fun p v => rfl }

/-- The identity affine map acts as the identity. -/
@[simp]
theorem coe_id : «expr⇑ » (id k P1) = _root_.id :=
  rfl

@[simp]
theorem id_linear : (id k P1).linear = LinearMap.id :=
  rfl

variable{P1}

/-- The identity affine map acts as the identity. -/
theorem id_apply (p : P1) : id k P1 p = p :=
  rfl

variable{k P1}

instance  : Inhabited (P1 →ᵃ[k] P1) :=
  ⟨id k P1⟩

include V2 V3

/-- Composition of affine maps. -/
def comp (f : P2 →ᵃ[k] P3) (g : P1 →ᵃ[k] P2) : P1 →ᵃ[k] P3 :=
  { toFun := f ∘ g, linear := f.linear.comp g.linear,
    map_vadd' :=
      by 
        intro p v 
        rw [Function.comp_app, g.map_vadd, f.map_vadd]
        rfl }

/-- Composition of affine maps acts as applying the two functions. -/
@[simp]
theorem coe_comp (f : P2 →ᵃ[k] P3) (g : P1 →ᵃ[k] P2) : «expr⇑ » (f.comp g) = f ∘ g :=
  rfl

/-- Composition of affine maps acts as applying the two functions. -/
theorem comp_apply (f : P2 →ᵃ[k] P3) (g : P1 →ᵃ[k] P2) (p : P1) : f.comp g p = f (g p) :=
  rfl

omit V3

@[simp]
theorem comp_id (f : P1 →ᵃ[k] P2) : f.comp (id k P1) = f :=
  ext$ fun p => rfl

@[simp]
theorem id_comp (f : P1 →ᵃ[k] P2) : (id k P2).comp f = f :=
  ext$ fun p => rfl

include V3 V4

theorem comp_assoc (f₃₄ : P3 →ᵃ[k] P4) (f₂₃ : P2 →ᵃ[k] P3) (f₁₂ : P1 →ᵃ[k] P2) :
  (f₃₄.comp f₂₃).comp f₁₂ = f₃₄.comp (f₂₃.comp f₁₂) :=
  rfl

omit V2 V3 V4

instance  : Monoidₓ (P1 →ᵃ[k] P1) :=
  { one := id k P1, mul := comp, one_mul := id_comp, mul_one := comp_id, mul_assoc := comp_assoc }

@[simp]
theorem coe_mul (f g : P1 →ᵃ[k] P1) : «expr⇑ » (f*g) = f ∘ g :=
  rfl

@[simp]
theorem coe_one : «expr⇑ » (1 : P1 →ᵃ[k] P1) = _root_.id :=
  rfl

include V2

-- error in LinearAlgebra.AffineSpace.AffineMap: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem injective_iff_linear_injective
(f : «expr →ᵃ[ ] »(P1, k, P2)) : «expr ↔ »(function.injective f.linear, function.injective f) :=
begin
  obtain ["⟨", ident p, "⟩", ":=", expr (infer_instance : nonempty P1)],
  have [ident h] [":", expr «expr = »(«expr⇑ »(f.linear), «expr ∘ »((equiv.vadd_const (f p)).symm, «expr ∘ »(f, equiv.vadd_const p)))] [],
  { ext [] [ident v] [],
    simp [] [] [] ["[", expr f.map_vadd, ",", expr vadd_vsub_assoc, "]"] [] [] },
  rw ["[", expr h, ",", expr equiv.comp_injective, ",", expr equiv.injective_comp, "]"] []
end

-- error in LinearAlgebra.AffineSpace.AffineMap: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem surjective_iff_linear_surjective
(f : «expr →ᵃ[ ] »(P1, k, P2)) : «expr ↔ »(function.surjective f.linear, function.surjective f) :=
begin
  obtain ["⟨", ident p, "⟩", ":=", expr (infer_instance : nonempty P1)],
  have [ident h] [":", expr «expr = »(«expr⇑ »(f.linear), «expr ∘ »((equiv.vadd_const (f p)).symm, «expr ∘ »(f, equiv.vadd_const p)))] [],
  { ext [] [ident v] [],
    simp [] [] [] ["[", expr f.map_vadd, ",", expr vadd_vsub_assoc, "]"] [] [] },
  rw ["[", expr h, ",", expr equiv.comp_surjective, ",", expr equiv.surjective_comp, "]"] []
end

theorem image_vsub_image {s t : Set P1} (f : P1 →ᵃ[k] P2) : f '' s -ᵥ f '' t = f.linear '' (s -ᵥ t) :=
  by 
    ext v 
    simp only [Set.mem_vsub, Set.mem_image, exists_exists_and_eq_and, exists_and_distrib_left, ←f.linear_map_vsub]
    split 
    ·
      rintro ⟨x, hx, y, hy, hv⟩
      exact ⟨x -ᵥ y, ⟨x, hx, y, hy, rfl⟩, hv⟩
    ·
      rintro ⟨-, ⟨x, hx, y, hy, rfl⟩, rfl⟩
      exact ⟨x, hx, y, hy, rfl⟩

omit V2

/-! ### Definition of `affine_map.line_map` and lemmas about it -/


/-- The affine map from `k` to `P1` sending `0` to `p₀` and `1` to `p₁`. -/
def line_map (p₀ p₁ : P1) : k →ᵃ[k] P1 :=
  ((LinearMap.id : k →ₗ[k] k).smulRight (p₁ -ᵥ p₀)).toAffineMap +ᵥ const k k p₀

theorem coe_line_map (p₀ p₁ : P1) : (line_map p₀ p₁ : k → P1) = fun c => c • (p₁ -ᵥ p₀) +ᵥ p₀ :=
  rfl

theorem line_map_apply (p₀ p₁ : P1) (c : k) : line_map p₀ p₁ c = c • (p₁ -ᵥ p₀) +ᵥ p₀ :=
  rfl

theorem line_map_apply_module' (p₀ p₁ : V1) (c : k) : line_map p₀ p₁ c = (c • (p₁ - p₀))+p₀ :=
  rfl

theorem line_map_apply_module (p₀ p₁ : V1) (c : k) : line_map p₀ p₁ c = ((1 - c) • p₀)+c • p₁ :=
  by 
    simp [line_map_apply_module', smul_sub, sub_smul] <;> abel

omit V1

theorem line_map_apply_ring' (a b c : k) : line_map a b c = (c*b - a)+a :=
  rfl

theorem line_map_apply_ring (a b c : k) : line_map a b c = ((1 - c)*a)+c*b :=
  line_map_apply_module a b c

include V1

theorem line_map_vadd_apply (p : P1) (v : V1) (c : k) : line_map p (v +ᵥ p) c = c • v +ᵥ p :=
  by 
    rw [line_map_apply, vadd_vsub]

@[simp]
theorem line_map_linear (p₀ p₁ : P1) : (line_map p₀ p₁ : k →ᵃ[k] P1).linear = LinearMap.id.smulRight (p₁ -ᵥ p₀) :=
  add_zeroₓ _

theorem line_map_same_apply (p : P1) (c : k) : line_map p p c = p :=
  by 
    simp [line_map_apply]

@[simp]
theorem line_map_same (p : P1) : line_map p p = const k k p :=
  ext$ line_map_same_apply p

@[simp]
theorem line_map_apply_zero (p₀ p₁ : P1) : line_map p₀ p₁ (0 : k) = p₀ :=
  by 
    simp [line_map_apply]

@[simp]
theorem line_map_apply_one (p₀ p₁ : P1) : line_map p₀ p₁ (1 : k) = p₁ :=
  by 
    simp [line_map_apply]

include V2

@[simp]
theorem apply_line_map (f : P1 →ᵃ[k] P2) (p₀ p₁ : P1) (c : k) : f (line_map p₀ p₁ c) = line_map (f p₀) (f p₁) c :=
  by 
    simp [line_map_apply]

@[simp]
theorem comp_line_map (f : P1 →ᵃ[k] P2) (p₀ p₁ : P1) : f.comp (line_map p₀ p₁) = line_map (f p₀) (f p₁) :=
  ext$ f.apply_line_map p₀ p₁

@[simp]
theorem fst_line_map (p₀ p₁ : P1 × P2) (c : k) : (line_map p₀ p₁ c).1 = line_map p₀.1 p₁.1 c :=
  fst.apply_line_map p₀ p₁ c

@[simp]
theorem snd_line_map (p₀ p₁ : P1 × P2) (c : k) : (line_map p₀ p₁ c).2 = line_map p₀.2 p₁.2 c :=
  snd.apply_line_map p₀ p₁ c

omit V2

theorem line_map_symm (p₀ p₁ : P1) : line_map p₀ p₁ = (line_map p₁ p₀).comp (line_map (1 : k) (0 : k)) :=
  by 
    rw [comp_line_map]
    simp 

theorem line_map_apply_one_sub (p₀ p₁ : P1) (c : k) : line_map p₀ p₁ (1 - c) = line_map p₁ p₀ c :=
  by 
    rw [line_map_symm p₀, comp_apply]
    congr 
    simp [line_map_apply]

@[simp]
theorem line_map_vsub_left (p₀ p₁ : P1) (c : k) : line_map p₀ p₁ c -ᵥ p₀ = c • (p₁ -ᵥ p₀) :=
  vadd_vsub _ _

@[simp]
theorem left_vsub_line_map (p₀ p₁ : P1) (c : k) : p₀ -ᵥ line_map p₀ p₁ c = c • (p₀ -ᵥ p₁) :=
  by 
    rw [←neg_vsub_eq_vsub_rev, line_map_vsub_left, ←smul_neg, neg_vsub_eq_vsub_rev]

@[simp]
theorem line_map_vsub_right (p₀ p₁ : P1) (c : k) : line_map p₀ p₁ c -ᵥ p₁ = (1 - c) • (p₀ -ᵥ p₁) :=
  by 
    rw [←line_map_apply_one_sub, line_map_vsub_left]

@[simp]
theorem right_vsub_line_map (p₀ p₁ : P1) (c : k) : p₁ -ᵥ line_map p₀ p₁ c = (1 - c) • (p₁ -ᵥ p₀) :=
  by 
    rw [←line_map_apply_one_sub, left_vsub_line_map]

theorem line_map_vadd_line_map (v₁ v₂ : V1) (p₁ p₂ : P1) (c : k) :
  line_map v₁ v₂ c +ᵥ line_map p₁ p₂ c = line_map (v₁ +ᵥ p₁) (v₂ +ᵥ p₂) c :=
  ((fst : V1 × P1 →ᵃ[k] V1) +ᵥ snd).apply_line_map (v₁, p₁) (v₂, p₂) c

-- error in LinearAlgebra.AffineSpace.AffineMap: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem line_map_vsub_line_map
(p₁ p₂ p₃ p₄ : P1)
(c : k) : «expr = »(«expr -ᵥ »(line_map p₁ p₂ c, line_map p₃ p₄ c), line_map «expr -ᵥ »(p₁, p₃) «expr -ᵥ »(p₂, p₄) c) :=
by letI [] [":", expr expraffine_space() «expr × »(V1, V1) «expr × »(P1, P1)] [":=", expr prod.add_torsor]; exact [expr «expr -ᵥ »((fst : «expr →ᵃ[ ] »(«expr × »(P1, P1), k, P1)), (snd : «expr →ᵃ[ ] »(«expr × »(P1, P1), k, P1))).apply_line_map (_, _) (_, _) c]

-- error in LinearAlgebra.AffineSpace.AffineMap: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Decomposition of an affine map in the special case when the point space and vector space
are the same. -/
theorem decomp (f : «expr →ᵃ[ ] »(V1, k, V2)) : «expr = »((f : V1 → V2), «expr + »(f.linear, λ z, f 0)) :=
begin
  ext [] [ident x] [],
  calc
    «expr = »(f x, «expr +ᵥ »(f.linear x, f 0)) : by simp [] [] [] ["[", "<-", expr f.map_vadd, "]"] [] []
    «expr = »(..., «expr + »(f.linear.to_fun, λ z : V1, f 0) x) : by simp [] [] [] [] [] []
end

/-- Decomposition of an affine map in the special case when the point space and vector space
are the same. -/
theorem decomp' (f : V1 →ᵃ[k] V2) : (f.linear : V1 → V2) = f - fun z => f 0 :=
  by 
    rw [decomp] <;> simp only [LinearMap.map_zero, Pi.add_apply, add_sub_cancel, zero_addₓ]

omit V1

-- error in LinearAlgebra.AffineSpace.AffineMap: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem image_interval
{k : Type*}
[linear_ordered_field k]
(f : «expr →ᵃ[ ] »(k, k, k))
(a b : k) : «expr = »(«expr '' »(f, set.interval a b), set.interval (f a) (f b)) :=
begin
  have [] [":", expr «expr = »(«expr⇑ »(f), «expr ∘ »(λ
     x, «expr + »(x, f 0), λ x, «expr * »(x, «expr - »(f 1, f 0))))] [],
  { ext [] [ident x] [],
    change [expr «expr = »(f x, «expr +ᵥ »(«expr • »(x, «expr -ᵥ »(f 1, f 0)), f 0))] [] [],
    rw ["[", "<-", expr f.linear_map_vsub, ",", "<-", expr f.linear.map_smul, ",", "<-", expr f.map_vadd, "]"] [],
    simp [] [] ["only"] ["[", expr vsub_eq_sub, ",", expr add_zero, ",", expr mul_one, ",", expr vadd_eq_add, ",", expr sub_zero, ",", expr smul_eq_mul, "]"] [] [] },
  rw ["[", expr this, ",", expr set.image_comp, "]"] [],
  simp [] [] ["only"] ["[", expr set.image_add_const_interval, ",", expr set.image_mul_const_interval, "]"] [] []
end

section 

variable{ι :
    Type
      _}{V :
    ∀ (i : ι), Type _}{P : ∀ (i : ι), Type _}[∀ i, AddCommGroupₓ (V i)][∀ i, Module k (V i)][∀ i, AddTorsor (V i) (P i)]

include V

/-- Evaluation at a point as an affine map. -/
def proj (i : ι) : (∀ (i : ι), P i) →ᵃ[k] P i :=
  { toFun := fun f => f i, linear := @LinearMap.proj k ι _ V _ _ i, map_vadd' := fun p v => rfl }

@[simp]
theorem proj_apply (i : ι) (f : ∀ i, P i) : @proj k _ ι V P _ _ _ i f = f i :=
  rfl

@[simp]
theorem proj_linear (i : ι) : (@proj k _ ι V P _ _ _ i).linear = @LinearMap.proj k ι _ V _ _ i :=
  rfl

theorem pi_line_map_apply (f g : ∀ i, P i) (c : k) (i : ι) : line_map f g c i = line_map (f i) (g i) c :=
  (proj i : (∀ i, P i) →ᵃ[k] P i).apply_line_map f g c

end 

end AffineMap

namespace AffineMap

variable{k :
    Type
      _}{V1 :
    Type
      _}{P1 :
    Type _}{V2 : Type _}[CommRingₓ k][AddCommGroupₓ V1][Module k V1][affine_space V1 P1][AddCommGroupₓ V2][Module k V2]

include V1

/-- If `k` is a commutative ring, then the set of affine maps with codomain in a `k`-module
is a `k`-module. -/
instance  : Module k (P1 →ᵃ[k] V2) :=
  { smul :=
      fun c f =>
        ⟨c • f, c • f.linear,
          fun p v =>
            by 
              simp [smul_add]⟩,
    one_smul := fun f => ext$ fun p => one_smul _ _, mul_smul := fun c₁ c₂ f => ext$ fun p => mul_smul _ _ _,
    smul_add := fun c f g => ext$ fun p => smul_add _ _ _, smul_zero := fun c => ext$ fun p => smul_zero _,
    add_smul := fun c₁ c₂ f => ext$ fun p => add_smul _ _ _, zero_smul := fun f => ext$ fun p => zero_smul _ _ }

@[simp]
theorem coe_smul (c : k) (f : P1 →ᵃ[k] V2) : «expr⇑ » (c • f) = c • f :=
  rfl

@[simp]
theorem smul_linear (t : k) (f : P1 →ᵃ[k] V2) : (t • f).linear = t • f.linear :=
  rfl

/-- The space of affine maps between two modules is linearly equivalent to the product of the
domain with the space of linear maps, by taking the value of the affine map at `(0 : V1)` and the
linear part. -/
@[simps]
def to_const_prod_linear_map : (V1 →ᵃ[k] V2) ≃ₗ[k] V2 × (V1 →ₗ[k] V2) :=
  { toFun := fun f => ⟨f 0, f.linear⟩, invFun := fun p => p.2.toAffineMap+const k V1 p.1,
    left_inv :=
      fun f =>
        by 
          ext 
          rw [f.decomp]
          simp ,
    right_inv :=
      by 
        rintro ⟨v, f⟩
        ext <;> simp ,
    map_add' :=
      by 
        simp ,
    map_smul' :=
      by 
        simp  }

/-- `homothety c r` is the homothety (also known as dilation) about `c` with scale factor `r`. -/
def homothety (c : P1) (r : k) : P1 →ᵃ[k] P1 :=
  r • (id k P1 -ᵥ const k P1 c) +ᵥ const k P1 c

theorem homothety_def (c : P1) (r : k) : homothety c r = r • (id k P1 -ᵥ const k P1 c) +ᵥ const k P1 c :=
  rfl

theorem homothety_apply (c : P1) (r : k) (p : P1) : homothety c r p = r • (p -ᵥ c : V1) +ᵥ c :=
  rfl

theorem homothety_eq_line_map (c : P1) (r : k) (p : P1) : homothety c r p = line_map c p r :=
  rfl

@[simp]
theorem homothety_one (c : P1) : homothety c (1 : k) = id k P1 :=
  by 
    ext p 
    simp [homothety_apply]

@[simp]
theorem homothety_apply_same (c : P1) (r : k) : homothety c r c = c :=
  line_map_same_apply c r

theorem homothety_mul (c : P1) (r₁ r₂ : k) : homothety c (r₁*r₂) = (homothety c r₁).comp (homothety c r₂) :=
  by 
    ext p 
    simp [homothety_apply, mul_smul]

@[simp]
theorem homothety_zero (c : P1) : homothety c (0 : k) = const k P1 c :=
  by 
    ext p 
    simp [homothety_apply]

@[simp]
theorem homothety_add (c : P1) (r₁ r₂ : k) : homothety c (r₁+r₂) = r₁ • (id k P1 -ᵥ const k P1 c) +ᵥ homothety c r₂ :=
  by 
    simp only [homothety_def, add_smul, vadd_vadd]

/-- `homothety` as a multiplicative monoid homomorphism. -/
def homothety_hom (c : P1) : k →* P1 →ᵃ[k] P1 :=
  ⟨homothety c, homothety_one c, homothety_mul c⟩

@[simp]
theorem coe_homothety_hom (c : P1) : «expr⇑ » (homothety_hom c : k →* _) = homothety c :=
  rfl

/-- `homothety` as an affine map. -/
def homothety_affine (c : P1) : k →ᵃ[k] P1 →ᵃ[k] P1 :=
  ⟨homothety c, (LinearMap.lsmul k _).flip (id k P1 -ᵥ const k P1 c), Function.swap (homothety_add c)⟩

@[simp]
theorem coe_homothety_affine (c : P1) : «expr⇑ » (homothety_affine c : k →ᵃ[k] _) = homothety c :=
  rfl

end AffineMap

