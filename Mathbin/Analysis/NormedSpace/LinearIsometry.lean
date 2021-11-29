import Mathbin.Analysis.Normed.Group.Basic 
import Mathbin.Topology.Algebra.Module

/-!
# (Semi-)linear isometries

In this file we define `linear_isometry σ₁₂ E E₂` (notation: `E →ₛₗᵢ[σ₁₂] E₂`) to be a semilinear
isometric embedding of `E` into `E₂` and `linear_isometry_equiv` (notation: `E ≃ₛₗᵢ[σ₁₂] E₂`) to be
a semilinear isometric equivalence between `E` and `E₂`.  The notation for the associated purely
linear concepts is `E →ₗᵢ[R] E₂`, `E ≃ₗᵢ[R] E₂`, and `E →ₗᵢ⋆[R] E₂`, `E ≃ₗᵢ⋆[R] E₂` for
the star-linear versions.

We also prove some trivial lemmas and provide convenience constructors.

Since a lot of elementary properties don't require `∥x∥ = 0 → x = 0` we start setting up the
theory for `semi_normed_space` and we specialize to `normed_space` when needed.
-/


open Function Set

variable{R R₂ R₃ R₄ E E₂ E₃ E₄ F :
    Type
      _}[Semiringₓ
      R][Semiringₓ
      R₂][Semiringₓ
      R₃][Semiringₓ
      R₄]{σ₁₂ :
    R →+*
      R₂}{σ₂₁ :
    R₂ →+*
      R}{σ₁₃ :
    R →+*
      R₃}{σ₃₁ :
    R₃ →+*
      R}{σ₁₄ :
    R →+*
      R₄}{σ₄₁ :
    R₄ →+*
      R}{σ₂₃ :
    R₂ →+*
      R₃}{σ₃₂ :
    R₃ →+*
      R₂}{σ₂₄ :
    R₂ →+*
      R₄}{σ₄₂ :
    R₄ →+*
      R₂}{σ₃₄ :
    R₃ →+*
      R₄}{σ₄₃ :
    R₄ →+*
      R₃}[RingHomInvPair σ₁₂
      σ₂₁][RingHomInvPair σ₂₁
      σ₁₂][RingHomInvPair σ₁₃
      σ₃₁][RingHomInvPair σ₃₁
      σ₁₃][RingHomInvPair σ₂₃
      σ₃₂][RingHomInvPair σ₃₂
      σ₂₃][RingHomInvPair σ₁₄
      σ₄₁][RingHomInvPair σ₄₁
      σ₁₄][RingHomInvPair σ₂₄
      σ₄₂][RingHomInvPair σ₄₂
      σ₂₄][RingHomInvPair σ₃₄
      σ₄₃][RingHomInvPair σ₄₃
      σ₃₄][RingHomCompTriple σ₁₂ σ₂₃
      σ₁₃][RingHomCompTriple σ₁₂ σ₂₄
      σ₁₄][RingHomCompTriple σ₂₃ σ₃₄
      σ₂₄][RingHomCompTriple σ₁₃ σ₃₄
      σ₁₄][RingHomCompTriple σ₃₂ σ₂₁
      σ₃₁][RingHomCompTriple σ₄₂ σ₂₁
      σ₄₁][RingHomCompTriple σ₄₃ σ₃₂
      σ₄₂][RingHomCompTriple σ₄₃ σ₃₁
      σ₄₁][SemiNormedGroup
      E][SemiNormedGroup
      E₂][SemiNormedGroup
      E₃][SemiNormedGroup E₄][Module R E][Module R₂ E₂][Module R₃ E₃][Module R₄ E₄][NormedGroup F][Module R F]

/-- A `σ₁₂`-semilinear isometric embedding of a normed `R`-module into an `R₂`-module. -/
structure
  LinearIsometry(σ₁₂ : R →+* R₂)(E E₂ : Type _)[SemiNormedGroup E][SemiNormedGroup E₂][Module R E][Module R₂ E₂] extends
  E →ₛₗ[σ₁₂] E₂ where 
  norm_map' : ∀ x, ∥to_linear_map x∥ = ∥x∥

notation:25 E " →ₛₗᵢ[" σ₁₂:25 "] " E₂:0 => LinearIsometry σ₁₂ E E₂

notation:25 E " →ₗᵢ[" R:25 "] " E₂:0 => LinearIsometry (RingHom.id R) E E₂

notation:25 E " →ₗᵢ⋆[" R:25 "] " E₂:0 => LinearIsometry (@starRingAut R _ _ : R →+* R) E E₂

namespace LinearIsometry

variable(f : E →ₛₗᵢ[σ₁₂] E₂)(f₁ : F →ₛₗᵢ[σ₁₂] E₂)

instance  : CoeFun (E →ₛₗᵢ[σ₁₂] E₂) fun _ => E → E₂ :=
  ⟨fun f => f.to_fun⟩

@[simp]
theorem coe_to_linear_map : «expr⇑ » f.to_linear_map = f :=
  rfl

theorem to_linear_map_injective : injective (to_linear_map : (E →ₛₗᵢ[σ₁₂] E₂) → E →ₛₗ[σ₁₂] E₂)
| ⟨f, _⟩, ⟨g, _⟩, rfl => rfl

-- error in Analysis.NormedSpace.LinearIsometry: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem coe_fn_injective : injective (λ (f : «expr →ₛₗᵢ[ ] »(E, σ₁₂, E₂)) (x : E), f x) :=
linear_map.coe_injective.comp to_linear_map_injective

@[ext]
theorem ext {f g : E →ₛₗᵢ[σ₁₂] E₂} (h : ∀ x, f x = g x) : f = g :=
  coe_fn_injective$ funext h

@[simp]
theorem map_zero : f 0 = 0 :=
  f.to_linear_map.map_zero

@[simp]
theorem map_add (x y : E) : f (x+y) = f x+f y :=
  f.to_linear_map.map_add x y

@[simp]
theorem map_sub (x y : E) : f (x - y) = f x - f y :=
  f.to_linear_map.map_sub x y

@[simp]
theorem map_smulₛₗ (c : R) (x : E) : f (c • x) = σ₁₂ c • f x :=
  f.to_linear_map.map_smulₛₗ c x

@[simp]
theorem map_smul [Module R E₂] (f : E →ₗᵢ[R] E₂) (c : R) (x : E) : f (c • x) = c • f x :=
  f.to_linear_map.map_smul c x

@[simp]
theorem norm_map (x : E) : ∥f x∥ = ∥x∥ :=
  f.norm_map' x

@[simp]
theorem nnnorm_map (x : E) : nnnorm (f x) = nnnorm x :=
  Nnreal.eq$ f.norm_map x

protected theorem Isometry : Isometry f :=
  f.to_linear_map.to_add_monoid_hom.isometry_of_norm f.norm_map

@[simp]
theorem dist_map (x y : E) : dist (f x) (f y) = dist x y :=
  f.isometry.dist_eq x y

@[simp]
theorem edist_map (x y : E) : edist (f x) (f y) = edist x y :=
  f.isometry.edist_eq x y

protected theorem injective : injective f₁ :=
  f₁.isometry.injective

@[simp]
theorem map_eq_iff {x y : F} : f₁ x = f₁ y ↔ x = y :=
  f₁.injective.eq_iff

theorem map_ne {x y : F} (h : x ≠ y) : f₁ x ≠ f₁ y :=
  f₁.injective.ne h

protected theorem lipschitz : LipschitzWith 1 f :=
  f.isometry.lipschitz

protected theorem antilipschitz : AntilipschitzWith 1 f :=
  f.isometry.antilipschitz

@[continuity]
protected theorem Continuous : Continuous f :=
  f.isometry.continuous

theorem ediam_image (s : Set E) : Emetric.diam (f '' s) = Emetric.diam s :=
  f.isometry.ediam_image s

theorem ediam_range : Emetric.diam (range f) = Emetric.diam (univ : Set E) :=
  f.isometry.ediam_range

theorem diam_image (s : Set E) : Metric.diam (f '' s) = Metric.diam s :=
  f.isometry.diam_image s

theorem diam_range : Metric.diam (range f) = Metric.diam (univ : Set E) :=
  f.isometry.diam_range

/-- Interpret a linear isometry as a continuous linear map. -/
def to_continuous_linear_map : E →SL[σ₁₂] E₂ :=
  ⟨f.to_linear_map, f.continuous⟩

@[simp]
theorem coe_to_continuous_linear_map : «expr⇑ » f.to_continuous_linear_map = f :=
  rfl

@[simp]
theorem comp_continuous_iff {α : Type _} [TopologicalSpace α] {g : α → E} : Continuous (f ∘ g) ↔ Continuous g :=
  f.isometry.comp_continuous_iff

/-- The identity linear isometry. -/
def id : E →ₗᵢ[R] E :=
  ⟨LinearMap.id, fun x => rfl⟩

@[simp]
theorem coe_id : ((id : E →ₗᵢ[R] E) : E → E) = _root_.id :=
  rfl

@[simp]
theorem id_apply (x : E) : (id : E →ₗᵢ[R] E) x = x :=
  rfl

@[simp]
theorem id_to_linear_map : (id.toLinearMap : E →ₗ[R] E) = LinearMap.id :=
  rfl

instance  : Inhabited (E →ₗᵢ[R] E) :=
  ⟨id⟩

/-- Composition of linear isometries. -/
def comp (g : E₂ →ₛₗᵢ[σ₂₃] E₃) (f : E →ₛₗᵢ[σ₁₂] E₂) : E →ₛₗᵢ[σ₁₃] E₃ :=
  ⟨g.to_linear_map.comp f.to_linear_map, fun x => (g.norm_map _).trans (f.norm_map _)⟩

include σ₁₃

@[simp]
theorem coe_comp (g : E₂ →ₛₗᵢ[σ₂₃] E₃) (f : E →ₛₗᵢ[σ₁₂] E₂) : «expr⇑ » (g.comp f) = (g ∘ f) :=
  rfl

omit σ₁₃

@[simp]
theorem id_comp : (id : E₂ →ₗᵢ[R₂] E₂).comp f = f :=
  ext$ fun x => rfl

@[simp]
theorem comp_id : f.comp id = f :=
  ext$ fun x => rfl

include σ₁₃ σ₂₄ σ₁₄

theorem comp_assoc (f : E₃ →ₛₗᵢ[σ₃₄] E₄) (g : E₂ →ₛₗᵢ[σ₂₃] E₃) (h : E →ₛₗᵢ[σ₁₂] E₂) :
  (f.comp g).comp h = f.comp (g.comp h) :=
  rfl

omit σ₁₃ σ₂₄ σ₁₄

instance  : Monoidₓ (E →ₗᵢ[R] E) :=
  { one := id, mul := comp, mul_assoc := comp_assoc, one_mul := id_comp, mul_one := comp_id }

@[simp]
theorem coe_one : ((1 : E →ₗᵢ[R] E) : E → E) = _root_.id :=
  rfl

@[simp]
theorem coe_mul (f g : E →ₗᵢ[R] E) : «expr⇑ » (f*g) = (f ∘ g) :=
  rfl

end LinearIsometry

/-- Construct a `linear_isometry` from a `linear_map` satisfying `isometry`. -/
def LinearMap.toLinearIsometry (f : E →ₛₗ[σ₁₂] E₂) (hf : Isometry f) : E →ₛₗᵢ[σ₁₂] E₂ :=
  { f with
    norm_map' :=
      by 
        simpRw [←dist_zero_right, ←f.map_zero]
        exact fun x => hf.dist_eq x _ }

namespace Submodule

variable{R' : Type _}[Ringₓ R'][Module R' E](p : Submodule R' E)

/-- `submodule.subtype` as a `linear_isometry`. -/
def subtypeₗᵢ : p →ₗᵢ[R'] E :=
  ⟨p.subtype, fun x => rfl⟩

@[simp]
theorem coe_subtypeₗᵢ : «expr⇑ » p.subtypeₗᵢ = p.subtype :=
  rfl

@[simp]
theorem subtypeₗᵢ_to_linear_map : p.subtypeₗᵢ.to_linear_map = p.subtype :=
  rfl

/-- `submodule.subtype` as a `continuous_linear_map`. -/
def subtypeL : p →L[R'] E :=
  p.subtypeₗᵢ.to_continuous_linear_map

@[simp]
theorem coe_subtypeL : (p.subtypeL : p →ₗ[R'] E) = p.subtype :=
  rfl

@[simp]
theorem coe_subtypeL' : «expr⇑ » p.subtypeL = p.subtype :=
  rfl

@[simp]
theorem range_subtypeL : p.subtypeL.range = p :=
  range_subtype _

@[simp]
theorem ker_subtypeL : p.subtypeL.ker = ⊥ :=
  ker_subtype _

end Submodule

/-- A semilinear isometric equivalence between two normed vector spaces. -/
structure
  LinearIsometryEquiv(σ₁₂ :
    R →+*
      R₂){σ₂₁ :
    R₂ →+*
      R}[RingHomInvPair σ₁₂
      σ₂₁][RingHomInvPair σ₂₁
      σ₁₂](E E₂ : Type _)[SemiNormedGroup E][SemiNormedGroup E₂][Module R E][Module R₂ E₂] extends
  E ≃ₛₗ[σ₁₂] E₂ where 
  norm_map' : ∀ x, ∥to_linear_equiv x∥ = ∥x∥

notation:25 E " ≃ₛₗᵢ[" σ₁₂:25 "] " E₂:0 => LinearIsometryEquiv σ₁₂ E E₂

notation:25 E " ≃ₗᵢ[" R:25 "] " E₂:0 => LinearIsometryEquiv (RingHom.id R) E E₂

notation:25 E " ≃ₗᵢ⋆[" R:25 "] " E₂:0 => LinearIsometryEquiv (@starRingAut R _ _ : R →+* R) E E₂

namespace LinearIsometryEquiv

variable(e : E ≃ₛₗᵢ[σ₁₂] E₂)

include σ₂₁

instance  : CoeFun (E ≃ₛₗᵢ[σ₁₂] E₂) fun _ => E → E₂ :=
  ⟨fun f => f.to_fun⟩

@[simp]
theorem coe_mk (e : E ≃ₛₗ[σ₁₂] E₂) (he : ∀ x, ∥e x∥ = ∥x∥) : «expr⇑ » (mk e he) = e :=
  rfl

@[simp]
theorem coe_to_linear_equiv (e : E ≃ₛₗᵢ[σ₁₂] E₂) : «expr⇑ » e.to_linear_equiv = e :=
  rfl

theorem to_linear_equiv_injective : injective (to_linear_equiv : (E ≃ₛₗᵢ[σ₁₂] E₂) → E ≃ₛₗ[σ₁₂] E₂)
| ⟨e, _⟩, ⟨_, _⟩, rfl => rfl

@[ext]
theorem ext {e e' : E ≃ₛₗᵢ[σ₁₂] E₂} (h : ∀ x, e x = e' x) : e = e' :=
  to_linear_equiv_injective$ LinearEquiv.ext h

/-- Construct a `linear_isometry_equiv` from a `linear_equiv` and two inequalities:
`∀ x, ∥e x∥ ≤ ∥x∥` and `∀ y, ∥e.symm y∥ ≤ ∥y∥`. -/
def of_bounds (e : E ≃ₛₗ[σ₁₂] E₂) (h₁ : ∀ x, ∥e x∥ ≤ ∥x∥) (h₂ : ∀ y, ∥e.symm y∥ ≤ ∥y∥) : E ≃ₛₗᵢ[σ₁₂] E₂ :=
  ⟨e,
    fun x =>
      le_antisymmₓ (h₁ x)$
        by 
          simpa only [e.symm_apply_apply] using h₂ (e x)⟩

@[simp]
theorem norm_map (x : E) : ∥e x∥ = ∥x∥ :=
  e.norm_map' x

/-- Reinterpret a `linear_isometry_equiv` as a `linear_isometry`. -/
def to_linear_isometry : E →ₛₗᵢ[σ₁₂] E₂ :=
  ⟨e.1, e.2⟩

@[simp]
theorem coe_to_linear_isometry : «expr⇑ » e.to_linear_isometry = e :=
  rfl

protected theorem Isometry : Isometry e :=
  e.to_linear_isometry.isometry

/-- Reinterpret a `linear_isometry_equiv` as an `isometric`. -/
def to_isometric : E ≃ᵢ E₂ :=
  ⟨e.to_linear_equiv.to_equiv, e.isometry⟩

@[simp]
theorem coe_to_isometric : «expr⇑ » e.to_isometric = e :=
  rfl

theorem range_eq_univ (e : E ≃ₛₗᵢ[σ₁₂] E₂) : Set.Range e = Set.Univ :=
  by 
    rw [←coe_to_isometric]
    exact Isometric.range_eq_univ _

/-- Reinterpret a `linear_isometry_equiv` as an `homeomorph`. -/
def to_homeomorph : E ≃ₜ E₂ :=
  e.to_isometric.to_homeomorph

@[simp]
theorem coe_to_homeomorph : «expr⇑ » e.to_homeomorph = e :=
  rfl

protected theorem Continuous : Continuous e :=
  e.isometry.continuous

protected theorem ContinuousAt {x} : ContinuousAt e x :=
  e.continuous.continuous_at

protected theorem ContinuousOn {s} : ContinuousOn e s :=
  e.continuous.continuous_on

protected theorem ContinuousWithinAt {s x} : ContinuousWithinAt e s x :=
  e.continuous.continuous_within_at

/-- Interpret a `linear_isometry_equiv` as a continuous linear equiv. -/
def to_continuous_linear_equiv : E ≃SL[σ₁₂] E₂ :=
  { e.to_linear_isometry.to_continuous_linear_map, e.to_homeomorph with  }

@[simp]
theorem coe_to_continuous_linear_equiv : «expr⇑ » e.to_continuous_linear_equiv = e :=
  rfl

omit σ₂₁

variable(R E)

/-- Identity map as a `linear_isometry_equiv`. -/
def refl : E ≃ₗᵢ[R] E :=
  ⟨LinearEquiv.refl R E, fun x => rfl⟩

variable{R E}

instance  : Inhabited (E ≃ₗᵢ[R] E) :=
  ⟨refl R E⟩

@[simp]
theorem coe_refl : «expr⇑ » (refl R E) = id :=
  rfl

/-- The inverse `linear_isometry_equiv`. -/
def symm : E₂ ≃ₛₗᵢ[σ₂₁] E :=
  ⟨e.to_linear_equiv.symm, fun x => (e.norm_map _).symm.trans$ congr_argₓ norm$ e.to_linear_equiv.apply_symm_apply x⟩

@[simp]
theorem apply_symm_apply (x : E₂) : e (e.symm x) = x :=
  e.to_linear_equiv.apply_symm_apply x

@[simp]
theorem symm_apply_apply (x : E) : e.symm (e x) = x :=
  e.to_linear_equiv.symm_apply_apply x

@[simp]
theorem map_eq_zero_iff {x : E} : e x = 0 ↔ x = 0 :=
  e.to_linear_equiv.map_eq_zero_iff

@[simp]
theorem symm_symm : e.symm.symm = e :=
  ext$ fun x => rfl

@[simp]
theorem to_linear_equiv_symm : e.to_linear_equiv.symm = e.symm.to_linear_equiv :=
  rfl

@[simp]
theorem to_isometric_symm : e.to_isometric.symm = e.symm.to_isometric :=
  rfl

@[simp]
theorem to_homeomorph_symm : e.to_homeomorph.symm = e.symm.to_homeomorph :=
  rfl

include σ₃₁ σ₃₂

/-- Composition of `linear_isometry_equiv`s as a `linear_isometry_equiv`. -/
def trans (e' : E₂ ≃ₛₗᵢ[σ₂₃] E₃) : E ≃ₛₗᵢ[σ₁₃] E₃ :=
  ⟨e.to_linear_equiv.trans e'.to_linear_equiv, fun x => (e'.norm_map _).trans (e.norm_map _)⟩

include σ₁₃ σ₂₁

@[simp]
theorem coeTransₓ (e₁ : E ≃ₛₗᵢ[σ₁₂] E₂) (e₂ : E₂ ≃ₛₗᵢ[σ₂₃] E₃) : «expr⇑ » (e₁.trans e₂) = (e₂ ∘ e₁) :=
  rfl

omit σ₁₃ σ₂₁ σ₃₁ σ₃₂

@[simp]
theorem trans_refl : e.trans (refl R₂ E₂) = e :=
  ext$ fun x => rfl

@[simp]
theorem refl_trans : (refl R E).trans e = e :=
  ext$ fun x => rfl

@[simp]
theorem self_trans_symm : e.trans e.symm = refl R E :=
  ext e.symm_apply_apply

@[simp]
theorem symm_trans_self : e.symm.trans e = refl R₂ E₂ :=
  ext e.apply_symm_apply

@[simp]
theorem symm_comp_self : (e.symm ∘ e) = id :=
  funext e.symm_apply_apply

@[simp]
theorem self_comp_symm : (e ∘ e.symm) = id :=
  e.symm.symm_comp_self

include σ₁₃ σ₂₁ σ₃₂ σ₃₁

@[simp]
theorem coe_symm_trans (e₁ : E ≃ₛₗᵢ[σ₁₂] E₂) (e₂ : E₂ ≃ₛₗᵢ[σ₂₃] E₃) :
  «expr⇑ » (e₁.trans e₂).symm = (e₁.symm ∘ e₂.symm) :=
  rfl

include σ₁₄ σ₄₁ σ₄₂ σ₄₃ σ₂₄

theorem trans_assoc (eEE₂ : E ≃ₛₗᵢ[σ₁₂] E₂) (eE₂E₃ : E₂ ≃ₛₗᵢ[σ₂₃] E₃) (eE₃E₄ : E₃ ≃ₛₗᵢ[σ₃₄] E₄) :
  eEE₂.trans (eE₂E₃.trans eE₃E₄) = (eEE₂.trans eE₂E₃).trans eE₃E₄ :=
  rfl

omit σ₂₁ σ₃₁ σ₄₁ σ₃₂ σ₄₂ σ₄₃ σ₁₃ σ₂₄ σ₁₄

instance  : Groupₓ (E ≃ₗᵢ[R] E) :=
  { mul := fun e₁ e₂ => e₂.trans e₁, one := refl _ _, inv := symm, one_mul := trans_refl, mul_one := refl_trans,
    mul_assoc := fun _ _ _ => trans_assoc _ _ _, mul_left_inv := self_trans_symm }

@[simp]
theorem coe_one : «expr⇑ » (1 : E ≃ₗᵢ[R] E) = id :=
  rfl

@[simp]
theorem coe_mul (e e' : E ≃ₗᵢ[R] E) : «expr⇑ » (e*e') = (e ∘ e') :=
  rfl

@[simp]
theorem coe_inv (e : E ≃ₗᵢ[R] E) : «expr⇑ » (e⁻¹) = e.symm :=
  rfl

include σ₂₁

/-- Reinterpret a `linear_isometry_equiv` as a `continuous_linear_equiv`. -/
instance  : CoeTₓ (E ≃ₛₗᵢ[σ₁₂] E₂) (E ≃SL[σ₁₂] E₂) :=
  ⟨fun e => ⟨e.to_linear_equiv, e.continuous, e.to_isometric.symm.continuous⟩⟩

instance  : CoeTₓ (E ≃ₛₗᵢ[σ₁₂] E₂) (E →SL[σ₁₂] E₂) :=
  ⟨fun e => «expr↑ » (e : E ≃SL[σ₁₂] E₂)⟩

@[simp]
theorem coe_coe : «expr⇑ » (e : E ≃SL[σ₁₂] E₂) = e :=
  rfl

@[simp]
theorem coe_coe' : ((e : E ≃SL[σ₁₂] E₂) : E →SL[σ₁₂] E₂) = e :=
  rfl

@[simp]
theorem coe_coe'' : «expr⇑ » (e : E →SL[σ₁₂] E₂) = e :=
  rfl

omit σ₂₁

@[simp]
theorem map_zero : e 0 = 0 :=
  e.1.map_zero

@[simp]
theorem map_add (x y : E) : e (x+y) = e x+e y :=
  e.1.map_add x y

@[simp]
theorem map_sub (x y : E) : e (x - y) = e x - e y :=
  e.1.map_sub x y

@[simp]
theorem map_smulₛₗ (c : R) (x : E) : e (c • x) = σ₁₂ c • e x :=
  e.1.map_smulₛₗ c x

@[simp]
theorem map_smul [Module R E₂] {e : E ≃ₗᵢ[R] E₂} (c : R) (x : E) : e (c • x) = c • e x :=
  e.1.map_smul c x

@[simp]
theorem nnnorm_map (x : E) : nnnorm (e x) = nnnorm x :=
  e.to_linear_isometry.nnnorm_map x

@[simp]
theorem dist_map (x y : E) : dist (e x) (e y) = dist x y :=
  e.to_linear_isometry.dist_map x y

@[simp]
theorem edist_map (x y : E) : edist (e x) (e y) = edist x y :=
  e.to_linear_isometry.edist_map x y

protected theorem bijective : bijective e :=
  e.1.Bijective

protected theorem injective : injective e :=
  e.1.Injective

protected theorem surjective : surjective e :=
  e.1.Surjective

@[simp]
theorem map_eq_iff {x y : E} : e x = e y ↔ x = y :=
  e.injective.eq_iff

theorem map_ne {x y : E} (h : x ≠ y) : e x ≠ e y :=
  e.injective.ne h

protected theorem lipschitz : LipschitzWith 1 e :=
  e.isometry.lipschitz

protected theorem antilipschitz : AntilipschitzWith 1 e :=
  e.isometry.antilipschitz

@[simp]
theorem ediam_image (s : Set E) : Emetric.diam (e '' s) = Emetric.diam s :=
  e.isometry.ediam_image s

@[simp]
theorem diam_image (s : Set E) : Metric.diam (e '' s) = Metric.diam s :=
  e.isometry.diam_image s

variable{α : Type _}[TopologicalSpace α]

@[simp]
theorem comp_continuous_on_iff {f : α → E} {s : Set α} : ContinuousOn (e ∘ f) s ↔ ContinuousOn f s :=
  e.isometry.comp_continuous_on_iff

@[simp]
theorem comp_continuous_iff {f : α → E} : Continuous (e ∘ f) ↔ Continuous f :=
  e.isometry.comp_continuous_iff

include σ₂₁

/-- Construct a linear isometry equiv from a surjective linear isometry. -/
noncomputable def of_surjective (f : F →ₛₗᵢ[σ₁₂] E₂) (hfr : Function.Surjective f) : F ≃ₛₗᵢ[σ₁₂] E₂ :=
  { LinearEquiv.ofBijective f.to_linear_map f.injective hfr with norm_map' := f.norm_map }

omit σ₂₁

variable(R)

/-- The negation operation on a normed space `E`, considered as a linear isometry equivalence. -/
def neg : E ≃ₗᵢ[R] E :=
  { LinearEquiv.neg R with norm_map' := norm_neg }

variable{R}

@[simp]
theorem coe_neg : (neg R : E → E) = fun x => -x :=
  rfl

@[simp]
theorem symm_neg : (neg R : E ≃ₗᵢ[R] E).symm = neg R :=
  rfl

variable(R E E₂ E₃)

/-- The natural equivalence `(E × E₂) × E₃ ≃ E × (E₂ × E₃)` is a linear isometry. -/
noncomputable def prod_assoc [Module R E₂] [Module R E₃] : (E × E₂) × E₃ ≃ₗᵢ[R] E × E₂ × E₃ :=
  { Equiv.prodAssoc E E₂ E₃ with toFun := Equiv.prodAssoc E E₂ E₃, invFun := (Equiv.prodAssoc E E₂ E₃).symm,
    map_add' :=
      by 
        simp ,
    map_smul' :=
      by 
        simp ,
    norm_map' :=
      by 
        rintro ⟨⟨e, f⟩, g⟩
        simp only [LinearEquiv.coe_mk, Equiv.prod_assoc_apply, Prod.semi_norm_def, max_assocₓ] }

@[simp]
theorem coe_prod_assoc [Module R E₂] [Module R E₃] :
  (prod_assoc R E E₂ E₃ : (E × E₂) × E₃ → E × E₂ × E₃) = Equiv.prodAssoc E E₂ E₃ :=
  rfl

@[simp]
theorem coe_prod_assoc_symm [Module R E₂] [Module R E₃] :
  ((prod_assoc R E E₂ E₃).symm : E × E₂ × E₃ → (E × E₂) × E₃) = (Equiv.prodAssoc E E₂ E₃).symm :=
  rfl

end LinearIsometryEquiv

