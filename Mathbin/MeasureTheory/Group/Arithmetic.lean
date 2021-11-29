import Mathbin.MeasureTheory.Measure.MeasureSpace

/-!
# Typeclasses for measurability of operations

In this file we define classes `has_measurable_mul` etc and prove dot-style lemmas
(`measurable.mul`, `ae_measurable.mul` etc). For binary operations we define two typeclasses:

- `has_measurable_mul` says that both left and right multiplication are measurable;
- `has_measurable_mul₂` says that `λ p : α × α, p.1 * p.2` is measurable,

and similarly for other binary operations. The reason for introducing these classes is that in case
of topological space `α` equipped with the Borel `σ`-algebra, instances for `has_measurable_mul₂`
etc require `α` to have a second countable topology.

We define separate classes for `has_measurable_div`/`has_measurable_sub`
because on some types (e.g., `ℕ`, `ℝ≥0∞`) division and/or subtraction are not defined as `a * b⁻¹` /
`a + (-b)`.

For instances relating, e.g., `has_continuous_mul` to `has_measurable_mul` see file
`measure_theory.borel_space`.

## Implementation notes

For the heuristics of `@[to_additive]` it is important that the type with a multiplication
(or another multiplicative operations) is the first (implicit) argument of all declarations.

## Tags

measurable function, arithmetic operator

## Todo

* Uniformize the treatment of `pow` and `smul`.
* Use `@[to_additive]` to send `has_measurable_pow` to `has_measurable_smul₂`.
* This might require changing the definition (swapping the arguments in the function that is
  in the conclusion of `measurable_smul`.)
-/


universe u v

open_locale BigOperators Pointwise

open MeasureTheory

/-!
### Binary operations: `(+)`, `(*)`, `(-)`, `(/)`
-/


/-- We say that a type `has_measurable_add` if `((+) c)` and `(+ c)` are measurable functions.
For a typeclass assuming measurability of `uncurry (+)` see `has_measurable_add₂`. -/
class HasMeasurableAdd(M : Type _)[MeasurableSpace M][Add M] : Prop where 
  measurable_const_add : ∀ (c : M), Measurable ((·+·) c)
  measurable_add_const : ∀ (c : M), Measurable (·+c)

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- We say that a type `has_measurable_add` if `uncurry (+)` is a measurable functions.
For a typeclass assuming measurability of `((+) c)` and `(+ c)` see `has_measurable_add`. -/
class has_measurable_add₂
(M : Type*)
[measurable_space M]
[has_add M] : exprProp() := (measurable_add : measurable (λ p : «expr × »(M, M), «expr + »(p.1, p.2)))

export HasMeasurableAdd₂(measurable_add)

export HasMeasurableAdd(measurable_const_add measurable_add_const)

/-- We say that a type `has_measurable_mul` if `((*) c)` and `(* c)` are measurable functions.
For a typeclass assuming measurability of `uncurry (*)` see `has_measurable_mul₂`. -/
@[toAdditive]
class HasMeasurableMul(M : Type _)[MeasurableSpace M][Mul M] : Prop where 
  measurable_const_mul : ∀ (c : M), Measurable ((·*·) c)
  measurable_mul_const : ∀ (c : M), Measurable (·*c)

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- We say that a type `has_measurable_mul` if `uncurry (*)` is a measurable functions.
For a typeclass assuming measurability of `((*) c)` and `(* c)` see `has_measurable_mul`. -/
@[to_additive #[ident has_measurable_add₂]]
class has_measurable_mul₂
(M : Type*)
[measurable_space M]
[has_mul M] : exprProp() := (measurable_mul : measurable (λ p : «expr × »(M, M), «expr * »(p.1, p.2)))

export HasMeasurableMul₂(measurable_mul)

export HasMeasurableMul(measurable_const_mul measurable_mul_const)

section Mul

variable{M α : Type _}[MeasurableSpace M][Mul M][MeasurableSpace α]

@[toAdditive, measurability]
theorem Measurable.const_mul [HasMeasurableMul M] {f : α → M} (hf : Measurable f) (c : M) : Measurable fun x => c*f x :=
  (measurable_const_mul c).comp hf

@[toAdditive, measurability]
theorem AeMeasurable.const_mul [HasMeasurableMul M] {f : α → M} {μ : Measureₓ α} (hf : AeMeasurable f μ) (c : M) :
  AeMeasurable (fun x => c*f x) μ :=
  (HasMeasurableMul.measurable_const_mul c).comp_ae_measurable hf

@[toAdditive, measurability]
theorem Measurable.mul_const [HasMeasurableMul M] {f : α → M} (hf : Measurable f) (c : M) : Measurable fun x => f x*c :=
  (measurable_mul_const c).comp hf

@[toAdditive, measurability]
theorem AeMeasurable.mul_const [HasMeasurableMul M] {f : α → M} {μ : Measureₓ α} (hf : AeMeasurable f μ) (c : M) :
  AeMeasurable (fun x => f x*c) μ :=
  (measurable_mul_const c).comp_ae_measurable hf

@[toAdditive, measurability]
theorem Measurable.mul' [HasMeasurableMul₂ M] {f g : α → M} (hf : Measurable f) (hg : Measurable g) :
  Measurable (f*g) :=
  measurable_mul.comp (hf.prod_mk hg)

@[toAdditive, measurability]
theorem Measurable.mul [HasMeasurableMul₂ M] {f g : α → M} (hf : Measurable f) (hg : Measurable g) :
  Measurable fun a => f a*g a :=
  measurable_mul.comp (hf.prod_mk hg)

@[toAdditive, measurability]
theorem AeMeasurable.mul' [HasMeasurableMul₂ M] {μ : Measureₓ α} {f g : α → M} (hf : AeMeasurable f μ)
  (hg : AeMeasurable g μ) : AeMeasurable (f*g) μ :=
  measurable_mul.comp_ae_measurable (hf.prod_mk hg)

@[toAdditive, measurability]
theorem AeMeasurable.mul [HasMeasurableMul₂ M] {μ : Measureₓ α} {f g : α → M} (hf : AeMeasurable f μ)
  (hg : AeMeasurable g μ) : AeMeasurable (fun a => f a*g a) μ :=
  measurable_mul.comp_ae_measurable (hf.prod_mk hg)

@[toAdditive]
instance (priority := 100)HasMeasurableMul₂.to_has_measurable_mul [HasMeasurableMul₂ M] : HasMeasurableMul M :=
  ⟨fun c => measurable_const.mul measurable_id, fun c => measurable_id.mul measurable_const⟩

attribute [measurability] Measurable.add' Measurable.add AeMeasurable.add AeMeasurable.add' Measurable.const_add
  AeMeasurable.const_add Measurable.add_const AeMeasurable.add_const

end Mul

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- This class assumes that the map `β × γ → β` given by `(x, y) ↦ x ^ y` is measurable. -/
class has_measurable_pow
(β γ : Type*)
[measurable_space β]
[measurable_space γ]
[has_pow β γ] := (measurable_pow : measurable (λ p : «expr × »(β, γ), «expr ^ »(p.1, p.2)))

export HasMeasurablePow(measurable_pow)

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
instance has_measurable_mul.has_measurable_pow
(M : Type*)
[monoid M]
[measurable_space M]
[has_measurable_mul₂ M] : has_measurable_pow M exprℕ() :=
⟨begin
   haveI [] [":", expr measurable_singleton_class exprℕ()] [":=", expr ⟨λ _, trivial⟩],
   refine [expr measurable_from_prod_encodable (λ n, _)],
   induction [expr n] [] ["with", ident n, ident ih] [],
   { simp [] [] [] ["[", expr pow_zero, ",", expr measurable_one, "]"] [] [] },
   { simp [] [] ["only"] ["[", expr pow_succ, "]"] [] [],
     exact [expr measurable_id.mul ih] }
 end⟩

section Pow

variable{β γ α : Type _}[MeasurableSpace β][MeasurableSpace γ][Pow β γ][HasMeasurablePow β γ][MeasurableSpace α]

@[measurability]
theorem Measurable.pow {f : α → β} {g : α → γ} (hf : Measurable f) (hg : Measurable g) :
  Measurable fun x => f x ^ g x :=
  measurable_pow.comp (hf.prod_mk hg)

@[measurability]
theorem AeMeasurable.pow {μ : Measureₓ α} {f : α → β} {g : α → γ} (hf : AeMeasurable f μ) (hg : AeMeasurable g μ) :
  AeMeasurable (fun x => f x ^ g x) μ :=
  measurable_pow.comp_ae_measurable (hf.prod_mk hg)

@[measurability]
theorem Measurable.pow_const {f : α → β} (hf : Measurable f) (c : γ) : Measurable fun x => f x ^ c :=
  hf.pow measurable_const

@[measurability]
theorem AeMeasurable.pow_const {μ : Measureₓ α} {f : α → β} (hf : AeMeasurable f μ) (c : γ) :
  AeMeasurable (fun x => f x ^ c) μ :=
  hf.pow ae_measurable_const

@[measurability]
theorem Measurable.const_pow {f : α → γ} (hf : Measurable f) (c : β) : Measurable fun x => c ^ f x :=
  measurable_const.pow hf

@[measurability]
theorem AeMeasurable.const_pow {μ : Measureₓ α} {f : α → γ} (hf : AeMeasurable f μ) (c : β) :
  AeMeasurable (fun x => c ^ f x) μ :=
  ae_measurable_const.pow hf

end Pow

/-- We say that a type `has_measurable_sub` if `(λ x, c - x)` and `(λ x, x - c)` are measurable
functions. For a typeclass assuming measurability of `uncurry (-)` see `has_measurable_sub₂`. -/
class HasMeasurableSub(G : Type _)[MeasurableSpace G][Sub G] : Prop where 
  measurable_const_sub : ∀ (c : G), Measurable fun x => c - x 
  measurable_sub_const : ∀ (c : G), Measurable fun x => x - c

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- We say that a type `has_measurable_sub` if `uncurry (-)` is a measurable functions.
For a typeclass assuming measurability of `((-) c)` and `(- c)` see `has_measurable_sub`. -/
class has_measurable_sub₂
(G : Type*)
[measurable_space G]
[has_sub G] : exprProp() := (measurable_sub : measurable (λ p : «expr × »(G, G), «expr - »(p.1, p.2)))

export HasMeasurableSub₂(measurable_sub)

/-- We say that a type `has_measurable_div` if `((/) c)` and `(/ c)` are measurable functions.
For a typeclass assuming measurability of `uncurry (/)` see `has_measurable_div₂`. -/
@[toAdditive]
class HasMeasurableDiv(G₀ : Type _)[MeasurableSpace G₀][Div G₀] : Prop where 
  measurable_const_div : ∀ (c : G₀), Measurable ((· / ·) c)
  measurable_div_const : ∀ (c : G₀), Measurable (· / c)

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- We say that a type `has_measurable_div` if `uncurry (/)` is a measurable functions.
For a typeclass assuming measurability of `((/) c)` and `(/ c)` see `has_measurable_div`. -/
@[to_additive #[ident has_measurable_sub₂]]
class has_measurable_div₂
(G₀ : Type*)
[measurable_space G₀]
[has_div G₀] : exprProp() := (measurable_div : measurable (λ p : «expr × »(G₀, G₀), «expr / »(p.1, p.2)))

export HasMeasurableDiv₂(measurable_div)

section Div

variable{G α : Type _}[MeasurableSpace G][Div G][MeasurableSpace α]

@[toAdditive, measurability]
theorem Measurable.const_div [HasMeasurableDiv G] {f : α → G} (hf : Measurable f) (c : G) :
  Measurable fun x => c / f x :=
  (HasMeasurableDiv.measurable_const_div c).comp hf

@[toAdditive, measurability]
theorem AeMeasurable.const_div [HasMeasurableDiv G] {f : α → G} {μ : Measureₓ α} (hf : AeMeasurable f μ) (c : G) :
  AeMeasurable (fun x => c / f x) μ :=
  (HasMeasurableDiv.measurable_const_div c).comp_ae_measurable hf

@[toAdditive, measurability]
theorem Measurable.div_const [HasMeasurableDiv G] {f : α → G} (hf : Measurable f) (c : G) :
  Measurable fun x => f x / c :=
  (HasMeasurableDiv.measurable_div_const c).comp hf

@[toAdditive, measurability]
theorem AeMeasurable.div_const [HasMeasurableDiv G] {f : α → G} {μ : Measureₓ α} (hf : AeMeasurable f μ) (c : G) :
  AeMeasurable (fun x => f x / c) μ :=
  (HasMeasurableDiv.measurable_div_const c).comp_ae_measurable hf

@[toAdditive, measurability]
theorem Measurable.div' [HasMeasurableDiv₂ G] {f g : α → G} (hf : Measurable f) (hg : Measurable g) :
  Measurable (f / g) :=
  measurable_div.comp (hf.prod_mk hg)

@[toAdditive, measurability]
theorem Measurable.div [HasMeasurableDiv₂ G] {f g : α → G} (hf : Measurable f) (hg : Measurable g) :
  Measurable fun a => f a / g a :=
  measurable_div.comp (hf.prod_mk hg)

@[toAdditive, measurability]
theorem AeMeasurable.div' [HasMeasurableDiv₂ G] {f g : α → G} {μ : Measureₓ α} (hf : AeMeasurable f μ)
  (hg : AeMeasurable g μ) : AeMeasurable (f / g) μ :=
  measurable_div.comp_ae_measurable (hf.prod_mk hg)

@[toAdditive, measurability]
theorem AeMeasurable.div [HasMeasurableDiv₂ G] {f g : α → G} {μ : Measureₓ α} (hf : AeMeasurable f μ)
  (hg : AeMeasurable g μ) : AeMeasurable (fun a => f a / g a) μ :=
  measurable_div.comp_ae_measurable (hf.prod_mk hg)

@[toAdditive]
instance (priority := 100)HasMeasurableDiv₂.to_has_measurable_div [HasMeasurableDiv₂ G] : HasMeasurableDiv G :=
  ⟨fun c => measurable_const.div measurable_id, fun c => measurable_id.div measurable_const⟩

attribute [measurability] Measurable.sub Measurable.sub' AeMeasurable.sub AeMeasurable.sub' Measurable.const_sub
  AeMeasurable.const_sub Measurable.sub_const AeMeasurable.sub_const

@[measurability]
theorem measurable_set_eq_fun {E} [MeasurableSpace E] [AddGroupₓ E] [MeasurableSingletonClass E] [HasMeasurableSub₂ E]
  {f g : α → E} (hf : Measurable f) (hg : Measurable g) : MeasurableSet { x | f x = g x } :=
  by 
    suffices h_set_eq : { x:α | f x = g x } = { x | (f - g) x = (0 : E) }
    ·
      rw [h_set_eq]
      exact (hf.sub hg) measurable_set_eq 
    ext 
    simpRw [Set.mem_set_of_eq, Pi.sub_apply, sub_eq_zero]

theorem ae_eq_trim_of_measurable {α E} {m m0 : MeasurableSpace α} {μ : Measureₓ α} [MeasurableSpace E] [AddGroupₓ E]
  [MeasurableSingletonClass E] [HasMeasurableSub₂ E] (hm : m ≤ m0) {f g : α → E} (hf : @Measurable _ _ m _ f)
  (hg : @Measurable _ _ m _ g) (hfg : f =ᵐ[μ] g) : f =ᶠ[@measure.ae α m (μ.trim hm)] g :=
  by 
    rwa [Filter.EventuallyEq, ae_iff, trim_measurable_set_eq hm _]
    exact @MeasurableSet.compl α _ m (@measurable_set_eq_fun α m E _ _ _ _ _ _ hf hg)

end Div

/-- We say that a type `has_measurable_neg` if `x ↦ -x` is a measurable function. -/
class HasMeasurableNeg(G : Type _)[Neg G][MeasurableSpace G] : Prop where 
  measurable_neg : Measurable (Neg.neg : G → G)

/-- We say that a type `has_measurable_inv` if `x ↦ x⁻¹` is a measurable function. -/
@[toAdditive]
class HasMeasurableInv(G : Type _)[HasInv G][MeasurableSpace G] : Prop where 
  measurable_inv : Measurable (HasInv.inv : G → G)

export HasMeasurableInv(measurable_inv)

export HasMeasurableNeg(measurable_neg)

@[toAdditive]
instance (priority := 100)has_measurable_div_of_mul_inv (G : Type _) [MeasurableSpace G] [DivInvMonoidₓ G]
  [HasMeasurableMul G] [HasMeasurableInv G] : HasMeasurableDiv G :=
  { measurable_const_div :=
      fun c =>
        by 
          convert measurable_inv.const_mul c 
          ext1 
          apply div_eq_mul_inv,
    measurable_div_const :=
      fun c =>
        by 
          convert measurable_id.mul_const (c⁻¹)
          ext1 
          apply div_eq_mul_inv }

section Inv

variable{G α : Type _}[HasInv G][MeasurableSpace G][HasMeasurableInv G][MeasurableSpace α]

@[toAdditive, measurability]
theorem Measurable.inv {f : α → G} (hf : Measurable f) : Measurable fun x => f x⁻¹ :=
  measurable_inv.comp hf

@[toAdditive, measurability]
theorem AeMeasurable.inv {f : α → G} {μ : Measureₓ α} (hf : AeMeasurable f μ) : AeMeasurable (fun x => f x⁻¹) μ :=
  measurable_inv.comp_ae_measurable hf

attribute [measurability] Measurable.neg AeMeasurable.neg

@[toAdditive]
theorem MeasurableSet.inv {s : Set G} (hs : MeasurableSet s) : MeasurableSet (s⁻¹) :=
  measurable_inv hs

@[simp, toAdditive]
theorem measurable_inv_iff {G : Type _} [Groupₓ G] [MeasurableSpace G] [HasMeasurableInv G] {f : α → G} :
  (Measurable fun x => f x⁻¹) ↔ Measurable f :=
  ⟨fun h =>
      by 
        simpa only [inv_invₓ] using h.inv,
    fun h => h.inv⟩

@[simp, toAdditive]
theorem ae_measurable_inv_iff {G : Type _} [Groupₓ G] [MeasurableSpace G] [HasMeasurableInv G] {f : α → G}
  {μ : Measureₓ α} : AeMeasurable (fun x => f x⁻¹) μ ↔ AeMeasurable f μ :=
  ⟨fun h =>
      by 
        simpa only [inv_invₓ] using h.inv,
    fun h => h.inv⟩

@[simp]
theorem measurable_inv_iff₀ {G₀ : Type _} [GroupWithZeroₓ G₀] [MeasurableSpace G₀] [HasMeasurableInv G₀] {f : α → G₀} :
  (Measurable fun x => f x⁻¹) ↔ Measurable f :=
  ⟨fun h =>
      by 
        simpa only [inv_inv₀] using h.inv,
    fun h => h.inv⟩

@[simp]
theorem ae_measurable_inv_iff₀ {G₀ : Type _} [GroupWithZeroₓ G₀] [MeasurableSpace G₀] [HasMeasurableInv G₀] {f : α → G₀}
  {μ : Measureₓ α} : AeMeasurable (fun x => f x⁻¹) μ ↔ AeMeasurable f μ :=
  ⟨fun h =>
      by 
        simpa only [inv_inv₀] using h.inv,
    fun h => h.inv⟩

end Inv

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
private
theorem has_measurable_zpow_aux
(G : Type u)
[div_inv_monoid G]
[measurable_space G]
[has_measurable_mul₂ G]
[has_measurable_inv G]
(k : exprℕ()) : measurable (λ x : G, «expr ^ »(x, «expr-[1+ ]»(k))) :=
begin
  simp_rw ["[", expr zpow_neg_succ_of_nat, "]"] [],
  exact [expr (measurable_id.pow_const «expr + »(k, 1)).inv]
end

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
instance has_measurable_zpow
(G : Type u)
[div_inv_monoid G]
[measurable_space G]
[has_measurable_mul₂ G]
[has_measurable_inv G] : has_measurable_pow G exprℤ() :=
begin
  letI [] [":", expr measurable_singleton_class exprℤ()] [":=", expr ⟨λ _, trivial⟩],
  constructor,
  refine [expr measurable_from_prod_encodable (λ n, _)],
  dsimp [] [] [] [],
  apply [expr int.cases_on n],
  { simpa [] [] [] [] [] ["using", expr measurable_id.pow_const] },
  { exact [expr has_measurable_zpow_aux G] }
end

@[toAdditive]
instance (priority := 100)has_measurable_div₂_of_mul_inv (G : Type _) [MeasurableSpace G] [DivInvMonoidₓ G]
  [HasMeasurableMul₂ G] [HasMeasurableInv G] : HasMeasurableDiv₂ G :=
  ⟨by 
      simp only [div_eq_mul_inv]
      exact measurable_fst.mul measurable_snd.inv⟩

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- We say that the action of `M` on `α` `has_measurable_vadd` if for each `c` the map `x ↦ c +ᵥ x`
is a measurable function and for each `x` the map `c ↦ c +ᵥ x` is a measurable function. -/
class has_measurable_vadd
(M α : Type*)
[has_vadd M α]
[measurable_space M]
[measurable_space α] : exprProp() :=
  (measurable_const_vadd : ∀ c : M, measurable (((«expr +ᵥ »)) c : α → α))
  (measurable_vadd_const : ∀ x : α, measurable (λ c : M, «expr +ᵥ »(c, x)))

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- We say that the action of `M` on `α` `has_measurable_smul` if for each `c` the map `x ↦ c • x`
is a measurable function and for each `x` the map `c ↦ c • x` is a measurable function. -/
@[to_additive #[]]
class has_measurable_smul
(M α : Type*)
[has_scalar M α]
[measurable_space M]
[measurable_space α] : exprProp() :=
  (measurable_const_smul : ∀ c : M, measurable (((«expr • »)) c : α → α))
  (measurable_smul_const : ∀ x : α, measurable (λ c : M, «expr • »(c, x)))

/-- We say that the action of `M` on `α` `has_measurable_vadd₂` if the map
`(c, x) ↦ c +ᵥ x` is a measurable function. -/
class HasMeasurableVadd₂(M α : Type _)[HasVadd M α][MeasurableSpace M][MeasurableSpace α] : Prop where 
  measurable_vadd : Measurable (Function.uncurry (· +ᵥ ·) : M × α → α)

/-- We say that the action of `M` on `α` `has_measurable_smul₂` if the map
`(c, x) ↦ c • x` is a measurable function. -/
@[toAdditive HasMeasurableVadd₂]
class HasMeasurableSmul₂(M α : Type _)[HasScalar M α][MeasurableSpace M][MeasurableSpace α] : Prop where 
  measurable_smul : Measurable (Function.uncurry (· • ·) : M × α → α)

export HasMeasurableSmul(measurable_const_smul measurable_smul_const)

export HasMeasurableSmul₂(measurable_smul)

export HasMeasurableVadd(measurable_const_vadd measurable_vadd_const)

export HasMeasurableVadd₂(measurable_vadd)

@[toAdditive]
instance has_measurable_smul_of_mul (M : Type _) [Mul M] [MeasurableSpace M] [HasMeasurableMul M] :
  HasMeasurableSmul M M :=
  ⟨measurable_id.const_mul, measurable_id.mul_const⟩

@[toAdditive]
instance has_measurable_smul₂_of_mul (M : Type _) [Mul M] [MeasurableSpace M] [HasMeasurableMul₂ M] :
  HasMeasurableSmul₂ M M :=
  ⟨measurable_mul⟩

section Smul

variable{M β α : Type _}[MeasurableSpace M][MeasurableSpace β][HasScalar M β][MeasurableSpace α]

@[measurability, toAdditive]
theorem Measurable.smul [HasMeasurableSmul₂ M β] {f : α → M} {g : α → β} (hf : Measurable f) (hg : Measurable g) :
  Measurable fun x => f x • g x :=
  measurable_smul.comp (hf.prod_mk hg)

@[measurability, toAdditive]
theorem AeMeasurable.smul [HasMeasurableSmul₂ M β] {f : α → M} {g : α → β} {μ : Measureₓ α} (hf : AeMeasurable f μ)
  (hg : AeMeasurable g μ) : AeMeasurable (fun x => f x • g x) μ :=
  HasMeasurableSmul₂.measurable_smul.comp_ae_measurable (hf.prod_mk hg)

@[toAdditive]
instance (priority := 100)HasMeasurableSmul₂.to_has_measurable_smul [HasMeasurableSmul₂ M β] : HasMeasurableSmul M β :=
  ⟨fun c => measurable_const.smul measurable_id, fun y => measurable_id.smul measurable_const⟩

variable[HasMeasurableSmul M β]{μ : Measureₓ α}

@[measurability, toAdditive]
theorem Measurable.smul_const {f : α → M} (hf : Measurable f) (y : β) : Measurable fun x => f x • y :=
  (HasMeasurableSmul.measurable_smul_const y).comp hf

@[measurability, toAdditive]
theorem AeMeasurable.smul_const {f : α → M} (hf : AeMeasurable f μ) (y : β) : AeMeasurable (fun x => f x • y) μ :=
  (HasMeasurableSmul.measurable_smul_const y).comp_ae_measurable hf

@[measurability, toAdditive]
theorem Measurable.const_smul' {f : α → β} (hf : Measurable f) (c : M) : Measurable fun x => c • f x :=
  (HasMeasurableSmul.measurable_const_smul c).comp hf

@[measurability, toAdditive]
theorem Measurable.const_smul {f : α → β} (hf : Measurable f) (c : M) : Measurable (c • f) :=
  hf.const_smul' c

@[measurability, toAdditive]
theorem AeMeasurable.const_smul' {f : α → β} (hf : AeMeasurable f μ) (c : M) : AeMeasurable (fun x => c • f x) μ :=
  (HasMeasurableSmul.measurable_const_smul c).comp_ae_measurable hf

@[measurability, toAdditive]
theorem AeMeasurable.const_smul {f : α → β} (hf : AeMeasurable f μ) (c : M) : AeMeasurable (c • f) μ :=
  hf.const_smul' c

end Smul

section MulAction

variable{M β α :
    Type
      _}[MeasurableSpace
      M][MeasurableSpace
      β][Monoidₓ M][MulAction M β][HasMeasurableSmul M β][MeasurableSpace α]{f : α → β}{μ : Measureₓ α}

variable{G : Type _}[Groupₓ G][MeasurableSpace G][MulAction G β][HasMeasurableSmul G β]

@[toAdditive]
theorem measurable_const_smul_iff (c : G) : (Measurable fun x => c • f x) ↔ Measurable f :=
  ⟨fun h =>
      by 
        simpa only [inv_smul_smul] using h.const_smul' (c⁻¹),
    fun h => h.const_smul c⟩

@[toAdditive]
theorem ae_measurable_const_smul_iff (c : G) : AeMeasurable (fun x => c • f x) μ ↔ AeMeasurable f μ :=
  ⟨fun h =>
      by 
        simpa only [inv_smul_smul] using h.const_smul' (c⁻¹),
    fun h => h.const_smul c⟩

@[toAdditive]
instance  : MeasurableSpace (Units M) :=
  MeasurableSpace.comap (coeₓ : Units M → M) ‹_›

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[to_additive #[]] instance units.has_measurable_smul : has_measurable_smul (units M) β :=
{ measurable_const_smul := λ c, (measurable_const_smul (c : M) : _),
  measurable_smul_const := λ
  x, (measurable_smul_const x : measurable (λ c : M, «expr • »(c, x))).comp measurable_space.le_map_comap }

@[toAdditive]
theorem IsUnit.measurable_const_smul_iff {c : M} (hc : IsUnit c) : (Measurable fun x => c • f x) ↔ Measurable f :=
  let ⟨u, hu⟩ := hc 
  hu ▸ measurable_const_smul_iff u

@[toAdditive]
theorem IsUnit.ae_measurable_const_smul_iff {c : M} (hc : IsUnit c) :
  AeMeasurable (fun x => c • f x) μ ↔ AeMeasurable f μ :=
  let ⟨u, hu⟩ := hc 
  hu ▸ ae_measurable_const_smul_iff u

variable{G₀ : Type _}[GroupWithZeroₓ G₀][MeasurableSpace G₀][MulAction G₀ β][HasMeasurableSmul G₀ β]

theorem measurable_const_smul_iff₀ {c : G₀} (hc : c ≠ 0) : (Measurable fun x => c • f x) ↔ Measurable f :=
  (IsUnit.mk0 c hc).measurable_const_smul_iff

theorem ae_measurable_const_smul_iff₀ {c : G₀} (hc : c ≠ 0) : AeMeasurable (fun x => c • f x) μ ↔ AeMeasurable f μ :=
  (IsUnit.mk0 c hc).ae_measurable_const_smul_iff

end MulAction

/-!
### Opposite monoid
-/


section Opposite

open MulOpposite

instance  {α : Type _} [h : MeasurableSpace α] : MeasurableSpace («expr ᵐᵒᵖ» α) :=
  MeasurableSpace.map op h

theorem measurable_op {α : Type _} [MeasurableSpace α] : Measurable (op : α → «expr ᵐᵒᵖ» α) :=
  fun s => id

theorem measurable_unop {α : Type _} [MeasurableSpace α] : Measurable (unop : «expr ᵐᵒᵖ» α → α) :=
  fun s => id

instance  {M : Type _} [Mul M] [MeasurableSpace M] [HasMeasurableMul M] : HasMeasurableMul («expr ᵐᵒᵖ» M) :=
  ⟨fun c => measurable_op.comp (measurable_unop.mul_const _), fun c => measurable_op.comp (measurable_unop.const_mul _)⟩

instance  {M : Type _} [Mul M] [MeasurableSpace M] [HasMeasurableMul₂ M] : HasMeasurableMul₂ («expr ᵐᵒᵖ» M) :=
  ⟨measurable_op.comp ((measurable_unop.comp measurable_snd).mul (measurable_unop.comp measurable_fst))⟩

instance has_measurable_smul_opposite_of_mul {M : Type _} [Mul M] [MeasurableSpace M] [HasMeasurableMul M] :
  HasMeasurableSmul («expr ᵐᵒᵖ» M) M :=
  ⟨fun c => measurable_mul_const (unop c), fun x => measurable_unop.const_mul x⟩

instance has_measurable_smul₂_opposite_of_mul {M : Type _} [Mul M] [MeasurableSpace M] [HasMeasurableMul₂ M] :
  HasMeasurableSmul₂ («expr ᵐᵒᵖ» M) M :=
  ⟨measurable_snd.mul (measurable_unop.comp measurable_fst)⟩

end Opposite

/-!
### Big operators: `∏` and `∑`
-/


section Monoidₓ

variable{M α : Type _}[Monoidₓ M][MeasurableSpace M][HasMeasurableMul₂ M][MeasurableSpace α]

@[toAdditive, measurability]
theorem List.measurable_prod' (l : List (α → M)) (hl : ∀ f (_ : f ∈ l), Measurable f) : Measurable l.prod :=
  by 
    induction' l with f l ihl
    ·
      exact measurable_one 
    rw [List.forall_mem_consₓ] at hl 
    rw [List.prod_cons]
    exact hl.1.mul (ihl hl.2)

@[toAdditive, measurability]
theorem List.ae_measurable_prod' {μ : Measureₓ α} (l : List (α → M)) (hl : ∀ f (_ : f ∈ l), AeMeasurable f μ) :
  AeMeasurable l.prod μ :=
  by 
    induction' l with f l ihl
    ·
      exact ae_measurable_one 
    rw [List.forall_mem_consₓ] at hl 
    rw [List.prod_cons]
    exact hl.1.mul (ihl hl.2)

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[to_additive #[], measurability #[]]
theorem list.measurable_prod
(l : list (α → M))
(hl : ∀ f «expr ∈ » l, measurable f) : measurable (λ x, (l.map (λ f : α → M, f x)).prod) :=
by simpa [] [] ["only"] ["[", "<-", expr pi.list_prod_apply, "]"] [] ["using", expr l.measurable_prod' hl]

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[to_additive #[], measurability #[]]
theorem list.ae_measurable_prod
{μ : measure α}
(l : list (α → M))
(hl : ∀ f «expr ∈ » l, ae_measurable f μ) : ae_measurable (λ x, (l.map (λ f : α → M, f x)).prod) μ :=
by simpa [] [] ["only"] ["[", "<-", expr pi.list_prod_apply, "]"] [] ["using", expr l.ae_measurable_prod' hl]

end Monoidₓ

section CommMonoidₓ

variable{M ι α : Type _}[CommMonoidₓ M][MeasurableSpace M][HasMeasurableMul₂ M][MeasurableSpace α]

@[toAdditive, measurability]
theorem Multiset.measurable_prod' (l : Multiset (α → M)) (hl : ∀ f (_ : f ∈ l), Measurable f) : Measurable l.prod :=
  by 
    rcases l with ⟨l⟩
    simpa using
      l.measurable_prod'
        (by 
          simpa using hl)

@[toAdditive, measurability]
theorem Multiset.ae_measurable_prod' {μ : Measureₓ α} (l : Multiset (α → M)) (hl : ∀ f (_ : f ∈ l), AeMeasurable f μ) :
  AeMeasurable l.prod μ :=
  by 
    rcases l with ⟨l⟩
    simpa using
      l.ae_measurable_prod'
        (by 
          simpa using hl)

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[to_additive #[], measurability #[]]
theorem multiset.measurable_prod
(s : multiset (α → M))
(hs : ∀ f «expr ∈ » s, measurable f) : measurable (λ x, (s.map (λ f : α → M, f x)).prod) :=
by simpa [] [] ["only"] ["[", "<-", expr pi.multiset_prod_apply, "]"] [] ["using", expr s.measurable_prod' hs]

-- error in MeasureTheory.Group.Arithmetic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[to_additive #[], measurability #[]]
theorem multiset.ae_measurable_prod
{μ : measure α}
(s : multiset (α → M))
(hs : ∀ f «expr ∈ » s, ae_measurable f μ) : ae_measurable (λ x, (s.map (λ f : α → M, f x)).prod) μ :=
by simpa [] [] ["only"] ["[", "<-", expr pi.multiset_prod_apply, "]"] [] ["using", expr s.ae_measurable_prod' hs]

@[toAdditive, measurability]
theorem Finset.measurable_prod' {f : ι → α → M} (s : Finset ι) (hf : ∀ i (_ : i ∈ s), Measurable (f i)) :
  Measurable (∏i in s, f i) :=
  Finset.prod_induction _ _ (fun _ _ => Measurable.mul) (@measurable_one M _ _ _ _) hf

@[toAdditive, measurability]
theorem Finset.measurable_prod {f : ι → α → M} (s : Finset ι) (hf : ∀ i (_ : i ∈ s), Measurable (f i)) :
  Measurable fun a => ∏i in s, f i a :=
  by 
    simpa only [←Finset.prod_apply] using s.measurable_prod' hf

@[toAdditive, measurability]
theorem Finset.ae_measurable_prod' {μ : Measureₓ α} {f : ι → α → M} (s : Finset ι)
  (hf : ∀ i (_ : i ∈ s), AeMeasurable (f i) μ) : AeMeasurable (∏i in s, f i) μ :=
  Multiset.ae_measurable_prod' _$
    fun g hg =>
      let ⟨i, hi, hg⟩ := Multiset.mem_map.1 hg 
      hg ▸ hf _ hi

@[toAdditive, measurability]
theorem Finset.ae_measurable_prod {f : ι → α → M} {μ : Measureₓ α} (s : Finset ι)
  (hf : ∀ i (_ : i ∈ s), AeMeasurable (f i) μ) : AeMeasurable (fun a => ∏i in s, f i a) μ :=
  by 
    simpa only [←Finset.prod_apply] using s.ae_measurable_prod' hf

end CommMonoidₓ

attribute [measurability] List.measurable_sum' List.ae_measurable_sum' List.measurable_sum List.ae_measurable_sum
  Multiset.measurable_sum' Multiset.ae_measurable_sum' Multiset.measurable_sum Multiset.ae_measurable_sum
  Finset.measurable_sum' Finset.ae_measurable_sum' Finset.measurable_sum Finset.ae_measurable_sum

