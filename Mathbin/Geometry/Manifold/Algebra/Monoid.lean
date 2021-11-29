import Mathbin.Geometry.Manifold.TimesContMdiffMap

/-!
# Smooth monoid
A smooth monoid is a monoid that is also a smooth manifold, in which multiplication is a smooth map
of the product manifold `G` × `G` into `G`.

In this file we define the basic structures to talk about smooth monoids: `has_smooth_mul` and its
additive counterpart `has_smooth_add`. These structures are general enough to also talk about smooth
semigroups.
-/


open_locale Manifold

/--
1. All smooth algebraic structures on `G` are `Prop`-valued classes that extend
`smooth_manifold_with_corners I G`. This way we save users from adding both
`[smooth_manifold_with_corners I G]` and `[has_smooth_mul I G]` to the assumptions. While many API
lemmas hold true without the `smooth_manifold_with_corners I G` assumption, we're not aware of a
mathematically interesting monoid on a topological manifold such that (a) the space is not a
`smooth_manifold_with_corners`; (b) the multiplication is smooth at `(a, b)` in the charts
`ext_chart_at I a`, `ext_chart_at I b`, `ext_chart_at I (a * b)`.

2. Because of `model_prod` we can't assume, e.g., that a `lie_group` is modelled on `𝓘(𝕜, E)`. So,
we formulate the definitions and lemmas for any model.

3. While smoothness of an operation implies its continuity, lemmas like
`has_continuous_mul_of_smooth` can't be instances becausen otherwise Lean would have to search for
`has_smooth_mul I G` with unknown `𝕜`, `E`, `H`, and `I : model_with_corners 𝕜 E H`. If users needs
`[has_continuous_mul G]` in a proof about a smooth monoid, then they need to either add
`[has_continuous_mul G]` as an assumption (worse) or use `haveI` in the proof (better). -/
library_note "Design choices about smooth algebraic structures"

-- error in Geometry.Manifold.Algebra.Monoid: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Basic hypothesis to talk about a smooth (Lie) additive monoid or a smooth additive
semigroup. A smooth additive monoid over `α`, for example, is obtained by requiring both the
instances `add_monoid α` and `has_smooth_add α`. -/
@[ancestor #[ident smooth_manifold_with_corners]]
class has_smooth_add
{𝕜 : Type*}
[nondiscrete_normed_field 𝕜]
{H : Type*}
[topological_space H]
{E : Type*}
[normed_group E]
[normed_space 𝕜 E]
(I : model_with_corners 𝕜 E H)
(G : Type*)
[has_add G]
[topological_space G]
[charted_space H G]extends smooth_manifold_with_corners I G : exprProp() :=
  (smooth_add : smooth (I.prod I) I (λ p : «expr × »(G, G), «expr + »(p.1, p.2)))

-- error in Geometry.Manifold.Algebra.Monoid: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Basic hypothesis to talk about a smooth (Lie) monoid or a smooth semigroup.
A smooth monoid over `G`, for example, is obtained by requiring both the instances `monoid G`
and `has_smooth_mul I G`. -/
@[ancestor #[ident smooth_manifold_with_corners], to_additive #[]]
class has_smooth_mul
{𝕜 : Type*}
[nondiscrete_normed_field 𝕜]
{H : Type*}
[topological_space H]
{E : Type*}
[normed_group E]
[normed_space 𝕜 E]
(I : model_with_corners 𝕜 E H)
(G : Type*)
[has_mul G]
[topological_space G]
[charted_space H G]extends smooth_manifold_with_corners I G : exprProp() :=
  (smooth_mul : smooth (I.prod I) I (λ p : «expr × »(G, G), «expr * »(p.1, p.2)))

section HasSmoothMul

variable{𝕜 :
    Type
      _}[NondiscreteNormedField
      𝕜]{H :
    Type
      _}[TopologicalSpace
      H]{E :
    Type
      _}[NormedGroup
      E][NormedSpace 𝕜
      E]{I :
    ModelWithCorners 𝕜 E
      H}{G :
    Type
      _}[Mul
      G][TopologicalSpace
      G][ChartedSpace H
      G][HasSmoothMul I
      G]{E' :
    Type
      _}[NormedGroup
      E'][NormedSpace 𝕜
      E']{H' :
    Type _}[TopologicalSpace H']{I' : ModelWithCorners 𝕜 E' H'}{M : Type _}[TopologicalSpace M][ChartedSpace H' M]

section 

variable(I)

-- error in Geometry.Manifold.Algebra.Monoid: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[to_additive #[]] theorem smooth_mul : smooth (I.prod I) I (λ p : «expr × »(G, G), «expr * »(p.1, p.2)) :=
has_smooth_mul.smooth_mul

/-- If the multiplication is smooth, then it is continuous. This is not an instance for technical
reasons, see note [Design choices about smooth algebraic structures]. -/
@[toAdditive
      "If the addition is smooth, then it is continuous. This is not an instance for technical reasons,\nsee note [Design choices about smooth algebraic structures]."]
theorem has_continuous_mul_of_smooth : HasContinuousMul G :=
  ⟨(smooth_mul I).Continuous⟩

end 

@[toAdditive]
theorem Smooth.mul {f : M → G} {g : M → G} (hf : Smooth I' I f) (hg : Smooth I' I g) : Smooth I' I (f*g) :=
  (smooth_mul I).comp (hf.prod_mk hg)

-- error in Geometry.Manifold.Algebra.Monoid: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[to_additive #[]] theorem smooth_mul_left {a : G} : smooth I I (λ b : G, «expr * »(a, b)) := smooth_const.mul smooth_id

-- error in Geometry.Manifold.Algebra.Monoid: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[to_additive #[]] theorem smooth_mul_right {a : G} : smooth I I (λ b : G, «expr * »(b, a)) :=
smooth_id.mul smooth_const

@[toAdditive]
theorem SmoothOn.mul {f : M → G} {g : M → G} {s : Set M} (hf : SmoothOn I' I f s) (hg : SmoothOn I' I g s) :
  SmoothOn I' I (f*g) s :=
  ((smooth_mul I).comp_smooth_on (hf.prod_mk hg) : _)

variable(I)(g h : G)

/-- Left multiplication by `g`. It is meant to mimic the usual notation in Lie groups.
Lemmas involving `smooth_left_mul` with the notation `𝑳` usually use `L` instead of `𝑳` in the
names. -/
def smoothLeftMul : C^∞⟮I, G; I, G⟯ :=
  ⟨leftMul g, smooth_mul_left⟩

/-- Right multiplication by `g`. It is meant to mimic the usual notation in Lie groups.
Lemmas involving `smooth_right_mul` with the notation `𝑹` usually use `R` instead of `𝑹` in the
names. -/
def smoothRightMul : C^∞⟮I, G; I, G⟯ :=
  ⟨rightMul g, smooth_mul_right⟩

localized [LieGroup] notation "𝑳" => smoothLeftMul

localized [LieGroup] notation "𝑹" => smoothRightMul

open_locale LieGroup

@[simp]
theorem L_apply : (𝑳 I g) h = g*h :=
  rfl

@[simp]
theorem R_apply : (𝑹 I g) h = h*g :=
  rfl

@[simp]
theorem L_mul {G : Type _} [Semigroupₓ G] [TopologicalSpace G] [ChartedSpace H G] [HasSmoothMul I G] (g h : G) :
  𝑳 I (g*h) = (𝑳 I g).comp (𝑳 I h) :=
  by 
    ext 
    simp only [TimesContMdiffMap.comp_apply, L_apply, mul_assocₓ]

@[simp]
theorem R_mul {G : Type _} [Semigroupₓ G] [TopologicalSpace G] [ChartedSpace H G] [HasSmoothMul I G] (g h : G) :
  𝑹 I (g*h) = (𝑹 I h).comp (𝑹 I g) :=
  by 
    ext 
    simp only [TimesContMdiffMap.comp_apply, R_apply, mul_assocₓ]

section 

variable{G' : Type _}[Monoidₓ G'][TopologicalSpace G'][ChartedSpace H G'][HasSmoothMul I G'](g' : G')

theorem smooth_left_mul_one : (𝑳 I g') 1 = g' :=
  mul_oneₓ g'

theorem smooth_right_mul_one : (𝑹 I g') 1 = g' :=
  one_mulₓ g'

end 

@[toAdditive]
instance HasSmoothMul.prod {𝕜 : Type _} [NondiscreteNormedField 𝕜] {E : Type _} [NormedGroup E] [NormedSpace 𝕜 E]
  {H : Type _} [TopologicalSpace H] (I : ModelWithCorners 𝕜 E H) (G : Type _) [TopologicalSpace G] [ChartedSpace H G]
  [Mul G] [HasSmoothMul I G] {E' : Type _} [NormedGroup E'] [NormedSpace 𝕜 E'] {H' : Type _} [TopologicalSpace H']
  (I' : ModelWithCorners 𝕜 E' H') (G' : Type _) [TopologicalSpace G'] [ChartedSpace H' G'] [Mul G']
  [HasSmoothMul I' G'] : HasSmoothMul (I.prod I') (G × G') :=
  { SmoothManifoldWithCorners.prod G G' with
    smooth_mul :=
      ((smooth_fst.comp smooth_fst).Smooth.mul (smooth_fst.comp smooth_snd)).prod_mk
        ((smooth_snd.comp smooth_fst).Smooth.mul (smooth_snd.comp smooth_snd)) }

end HasSmoothMul

section Monoidₓ

variable{𝕜 :
    Type
      _}[NondiscreteNormedField
      𝕜]{H :
    Type
      _}[TopologicalSpace
      H]{E :
    Type
      _}[NormedGroup
      E][NormedSpace 𝕜
      E]{I :
    ModelWithCorners 𝕜 E
      H}{G :
    Type
      _}[Monoidₓ
      G][TopologicalSpace
      G][ChartedSpace H
      G][HasSmoothMul I
      G]{H' :
    Type
      _}[TopologicalSpace
      H']{E' :
    Type
      _}[NormedGroup
      E'][NormedSpace 𝕜
      E']{I' :
    ModelWithCorners 𝕜 E' H'}{G' : Type _}[Monoidₓ G'][TopologicalSpace G'][ChartedSpace H' G'][HasSmoothMul I' G']

-- error in Geometry.Manifold.Algebra.Monoid: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem smooth_pow : ∀ n : exprℕ(), smooth I I (λ a : G, «expr ^ »(a, n))
| 0 := by { simp [] [] ["only"] ["[", expr pow_zero, "]"] [] [],
  exact [expr smooth_const] }
| «expr + »(k, 1) := by simpa [] [] [] ["[", expr pow_succ, "]"] [] ["using", expr smooth_id.mul (smooth_pow _)]

/-- Morphism of additive smooth monoids. -/
structure
  SmoothAddMonoidMorphism(I :
    ModelWithCorners 𝕜 E
      H)(I' :
    ModelWithCorners 𝕜 E'
      H')(G :
    Type
      _)[TopologicalSpace
      G][ChartedSpace H
      G][AddMonoidₓ
      G][HasSmoothAdd I
      G](G' : Type _)[TopologicalSpace G'][ChartedSpace H' G'][AddMonoidₓ G'][HasSmoothAdd I' G'] extends
  G →+ G' where 
  smooth_to_fun : Smooth I I' to_fun

/-- Morphism of smooth monoids. -/
@[toAdditive]
structure
  SmoothMonoidMorphism(I :
    ModelWithCorners 𝕜 E
      H)(I' :
    ModelWithCorners 𝕜 E'
      H')(G :
    Type
      _)[TopologicalSpace
      G][ChartedSpace H
      G][Monoidₓ
      G][HasSmoothMul I G](G' : Type _)[TopologicalSpace G'][ChartedSpace H' G'][Monoidₓ G'][HasSmoothMul I' G'] extends
  G →* G' where 
  smooth_to_fun : Smooth I I' to_fun

@[toAdditive]
instance  : HasOne (SmoothMonoidMorphism I I' G G') :=
  ⟨{ smooth_to_fun := smooth_const, toMonoidHom := 1 }⟩

@[toAdditive]
instance  : Inhabited (SmoothMonoidMorphism I I' G G') :=
  ⟨1⟩

@[toAdditive]
instance  : CoeFun (SmoothMonoidMorphism I I' G G') fun _ => G → G' :=
  ⟨fun a => a.to_fun⟩

end Monoidₓ

section CommMonoidₓ

open_locale BigOperators

variable{𝕜 :
    Type
      _}[NondiscreteNormedField
      𝕜]{H :
    Type
      _}[TopologicalSpace
      H]{E :
    Type
      _}[NormedGroup
      E][NormedSpace 𝕜
      E]{I :
    ModelWithCorners 𝕜 E
      H}{G :
    Type
      _}[CommMonoidₓ
      G][TopologicalSpace
      G][ChartedSpace H
      G][HasSmoothMul I
      G]{E' :
    Type
      _}[NormedGroup
      E'][NormedSpace 𝕜
      E']{H' :
    Type _}[TopologicalSpace H']{I' : ModelWithCorners 𝕜 E' H'}{M : Type _}[TopologicalSpace M][ChartedSpace H' M]

@[toAdditive]
theorem smooth_finset_prod' {ι} {s : Finset ι} {f : ι → M → G} (h : ∀ i (_ : i ∈ s), Smooth I' I (f i)) :
  Smooth I' I (∏i in s, f i) :=
  Finset.prod_induction _ _ (fun f g hf hg => hf.mul hg) (@smooth_const _ _ _ _ _ _ _ I' _ _ _ _ _ _ _ _ I _ _ _ 1) h

@[toAdditive]
theorem smooth_finset_prod {ι} {s : Finset ι} {f : ι → M → G} (h : ∀ i (_ : i ∈ s), Smooth I' I (f i)) :
  Smooth I' I fun x => ∏i in s, f i x :=
  by 
    simp only [←Finset.prod_apply]
    exact smooth_finset_prod' h

open Function Filter

-- error in Geometry.Manifold.Algebra.Monoid: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[to_additive #[]]
theorem smooth_finprod
{ι}
{f : ι → M → G}
(h : ∀ i, smooth I' I (f i))
(hfin : locally_finite (λ i, mul_support (f i))) : smooth I' I (λ x, «expr∏ᶠ , »((i), f i x)) :=
begin
  intro [ident x],
  rcases [expr hfin x, "with", "⟨", ident U, ",", ident hxU, ",", ident hUf, "⟩"],
  have [] [":", expr smooth_at I' I (λ x, «expr∏ in , »((i), hUf.to_finset, f i x)) x] [],
  from [expr smooth_finset_prod (λ i hi, h i) x],
  refine [expr this.congr_of_eventually_eq «expr $ »(mem_of_superset hxU, λ y hy, _)],
  refine [expr finprod_eq_prod_of_mul_support_subset _ (λ i hi, _)],
  rw ["[", expr hUf.coe_to_finset, "]"] [],
  exact [expr ⟨y, hi, hy⟩]
end

@[toAdditive]
theorem smooth_finprod_cond {ι} {f : ι → M → G} {p : ι → Prop} (hc : ∀ i, p i → Smooth I' I (f i))
  (hf : LocallyFinite fun i => mul_support (f i)) : Smooth I' I fun x => ∏ᶠ(i : _)(hi : p i), f i x :=
  by 
    simp only [←finprod_subtype_eq_finprod_cond]
    exact smooth_finprod (fun i => hc i i.2) (hf.comp_injective Subtype.coe_injective)

end CommMonoidₓ

