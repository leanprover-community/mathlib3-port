import Mathbin.GroupTheory.Congruence 
import Mathbin.LinearAlgebra.Multilinear.TensorProduct

/-!
# Tensor product of an indexed family of modules over commutative semirings

We define the tensor product of an indexed family `s : ι → Type*` of modules over commutative
semirings. We denote this space by `⨂[R] i, s i` and define it as `free_add_monoid (R × Π i, s i)`
quotiented by the appropriate equivalence relation. The treatment follows very closely that of the
binary tensor product in `linear_algebra/tensor_product.lean`.

## Main definitions

* `pi_tensor_product R s` with `R` a commutative semiring and `s : ι → Type*` is the tensor product
  of all the `s i`'s. This is denoted by `⨂[R] i, s i`.
* `tprod R f` with `f : Π i, s i` is the tensor product of the vectors `f i` over all `i : ι`.
  This is bundled as a multilinear map from `Π i, s i` to `⨂[R] i, s i`.
* `lift_add_hom` constructs an `add_monoid_hom` from `(⨂[R] i, s i)` to some space `F` from a
  function `φ : (R × Π i, s i) → F` with the appropriate properties.
* `lift φ` with `φ : multilinear_map R s E` is the corresponding linear map
  `(⨂[R] i, s i) →ₗ[R] E`. This is bundled as a linear equivalence.
* `pi_tensor_product.reindex e` re-indexes the components of `⨂[R] i : ι, M` along `e : ι ≃ ι₂`.
* `pi_tensor_product.tmul_equiv` equivalence between a `tensor_product` of `pi_tensor_product`s and
  a single `pi_tensor_product`.

## Notations

* `⨂[R] i, s i` is defined as localized notation in locale `tensor_product`
* `⨂ₜ[R] i, f i` with `f : Π i, f i` is defined globally as the tensor product of all the `f i`'s.

## Implementation notes

* We define it via `free_add_monoid (R × Π i, s i)` with the `R` representing a "hidden" tensor
  factor, rather than `free_add_monoid (Π i, s i)` to ensure that, if `ι` is an empty type,
  the space is isomorphic to the base ring `R`.
* We have not restricted the index type `ι` to be a `fintype`, as nothing we do here strictly
  requires it. However, problems may arise in the case where `ι` is infinite; use at your own
  caution.

## TODO

* Define tensor powers, symmetric subspace, etc.
* API for the various ways `ι` can be split into subsets; connect this with the binary
  tensor product.
* Include connection with holors.
* Port more of the API from the binary tensor product over to this case.

## Tags

multilinear, tensor, tensor product
-/


open Function

section Semiringₓ

variable{ι ι₂ ι₃ : Type _}[DecidableEq ι][DecidableEq ι₂][DecidableEq ι₃]

variable{R : Type _}[CommSemiringₓ R]

variable{R₁ R₂ : Type _}

variable{s : ι → Type _}[∀ i, AddCommMonoidₓ (s i)][∀ i, Module R (s i)]

variable{M : Type _}[AddCommMonoidₓ M][Module R M]

variable{E : Type _}[AddCommMonoidₓ E][Module R E]

variable{F : Type _}[AddCommMonoidₓ F]

namespace PiTensorProduct

include R

variable(R)(s)

/-- The relation on `free_add_monoid (R × Π i, s i)` that generates a congruence whose quotient is
the tensor product. -/
inductive eqv : FreeAddMonoid (R × ∀ i, s i) → FreeAddMonoid (R × ∀ i, s i) → Prop
  | of_zero : ∀ (r : R) (f : ∀ i, s i) (i : ι) (hf : f i = 0), eqv (FreeAddMonoid.of (r, f)) 0
  | of_zero_scalar : ∀ (f : ∀ i, s i), eqv (FreeAddMonoid.of (0, f)) 0
  | of_add :
  ∀ (r : R) (f : ∀ i, s i) (i : ι) (m₁ m₂ : s i),
    eqv (FreeAddMonoid.of (r, update f i m₁)+FreeAddMonoid.of (r, update f i m₂))
      (FreeAddMonoid.of (r, update f i (m₁+m₂)))
  | of_add_scalar :
  ∀ (r r' : R) (f : ∀ i, s i), eqv (FreeAddMonoid.of (r, f)+FreeAddMonoid.of (r', f)) (FreeAddMonoid.of (r+r', f))
  | of_smul :
  ∀ (r : R) (f : ∀ i, s i) (i : ι) (r' : R),
    eqv (FreeAddMonoid.of (r, update f i (r' • f i))) (FreeAddMonoid.of (r'*r, f))
  | add_commₓ : ∀ x y, eqv (x+y) (y+x)

end PiTensorProduct

variable(R)(s)

/-- `pi_tensor_product R s` with `R` a commutative semiring and `s : ι → Type*` is the tensor
  product of all the `s i`'s. This is denoted by `⨂[R] i, s i`. -/
def PiTensorProduct : Type _ :=
  (addConGen (PiTensorProduct.Eqv R s)).Quotient

variable{R}

localized [TensorProduct] notation3 :100 "⨂[" R "] " (...) ", " r:(scoped f => PiTensorProduct R f) => r

open_locale TensorProduct

namespace PiTensorProduct

section Module

instance  : AddCommMonoidₓ (⨂[R] i, s i) :=
  { (addConGen (PiTensorProduct.Eqv R s)).AddMonoid with
    add_comm :=
      fun x y => AddCon.induction_on₂ x y$ fun x y => Quotientₓ.sound'$ AddConGen.Rel.of _ _$ eqv.add_comm _ _ }

instance  : Inhabited (⨂[R] i, s i) :=
  ⟨0⟩

variable(R){s}

/-- `tprod_coeff R r f` with `r : R` and `f : Π i, s i` is the tensor product of the vectors `f i`
over all `i : ι`, multiplied by the coefficient `r`. Note that this is meant as an auxiliary
definition for this file alone, and that one should use `tprod` defined below for most purposes. -/
def tprod_coeff (r : R) (f : ∀ i, s i) : ⨂[R] i, s i :=
  AddCon.mk' _$ FreeAddMonoid.of (r, f)

variable{R}

theorem zero_tprod_coeff (f : ∀ i, s i) : tprod_coeff R 0 f = 0 :=
  Quotientₓ.sound'$ AddConGen.Rel.of _ _$ eqv.of_zero_scalar _

theorem zero_tprod_coeff' (z : R) (f : ∀ i, s i) (i : ι) (hf : f i = 0) : tprod_coeff R z f = 0 :=
  Quotientₓ.sound'$ AddConGen.Rel.of _ _$ eqv.of_zero _ _ i hf

theorem add_tprod_coeff (z : R) (f : ∀ i, s i) (i : ι) (m₁ m₂ : s i) :
  (tprod_coeff R z (update f i m₁)+tprod_coeff R z (update f i m₂)) = tprod_coeff R z (update f i (m₁+m₂)) :=
  Quotientₓ.sound'$ AddConGen.Rel.of _ _ (eqv.of_add z f i m₁ m₂)

theorem add_tprod_coeff' (z₁ z₂ : R) (f : ∀ i, s i) :
  (tprod_coeff R z₁ f+tprod_coeff R z₂ f) = tprod_coeff R (z₁+z₂) f :=
  Quotientₓ.sound'$ AddConGen.Rel.of _ _ (eqv.of_add_scalar z₁ z₂ f)

theorem smul_tprod_coeff_aux (z : R) (f : ∀ i, s i) (i : ι) (r : R) :
  tprod_coeff R z (update f i (r • f i)) = tprod_coeff R (r*z) f :=
  Quotientₓ.sound'$ AddConGen.Rel.of _ _$ eqv.of_smul _ _ _ _

-- error in LinearAlgebra.PiTensorProduct: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem smul_tprod_coeff
(z : R)
(f : ∀ i, s i)
(i : ι)
(r : R₁)
[has_scalar R₁ R]
[is_scalar_tower R₁ R R]
[has_scalar R₁ (s i)]
[is_scalar_tower R₁ R (s i)] : «expr = »(tprod_coeff R z (update f i «expr • »(r, f i)), tprod_coeff R «expr • »(r, z) f) :=
begin
  have [ident h₁] [":", expr «expr = »(«expr • »(r, z), «expr * »(«expr • »(r, (1 : R)), z))] [":=", expr by rw ["[", expr smul_mul_assoc, ",", expr one_mul, "]"] []],
  have [ident h₂] [":", expr «expr = »(«expr • »(r, f i), «expr • »(«expr • »(r, (1 : R)), f i))] [":=", expr (smul_one_smul _ _ _).symm],
  rw ["[", expr h₁, ",", expr h₂, "]"] [],
  exact [expr smul_tprod_coeff_aux z f i _]
end

/-- Construct an `add_monoid_hom` from `(⨂[R] i, s i)` to some space `F` from a function
`φ : (R × Π i, s i) → F` with the appropriate properties. -/
def lift_add_hom (φ : (R × ∀ i, s i) → F) (C0 : ∀ (r : R) (f : ∀ i, s i) (i : ι) (hf : f i = 0), φ (r, f) = 0)
  (C0' : ∀ (f : ∀ i, s i), φ (0, f) = 0)
  (C_add :
    ∀ (r : R) (f : ∀ i, s i) (i : ι) (m₁ m₂ : s i),
      (φ (r, update f i m₁)+φ (r, update f i m₂)) = φ (r, update f i (m₁+m₂)))
  (C_add_scalar : ∀ (r r' : R) (f : ∀ i, s i), (φ (r, f)+φ (r', f)) = φ (r+r', f))
  (C_smul : ∀ (r : R) (f : ∀ i, s i) (i : ι) (r' : R), φ (r, update f i (r' • f i)) = φ (r'*r, f)) :
  (⨂[R] i, s i) →+ F :=
  (addConGen (PiTensorProduct.Eqv R s)).lift (FreeAddMonoid.lift φ)$
    AddCon.add_con_gen_le$
      fun x y hxy =>
        match x, y, hxy with 
        | _, _, eqv.of_zero r' f i hf =>
          (AddCon.ker_rel _).2$
            by 
              simp [FreeAddMonoid.lift_eval_of, C0 r' f i hf]
        | _, _, eqv.of_zero_scalar f =>
          (AddCon.ker_rel _).2$
            by 
              simp [FreeAddMonoid.lift_eval_of, C0']
        | _, _, eqv.of_add z f i m₁ m₂ =>
          (AddCon.ker_rel _).2$
            by 
              simp [FreeAddMonoid.lift_eval_of, C_add]
        | _, _, eqv.of_add_scalar z₁ z₂ f =>
          (AddCon.ker_rel _).2$
            by 
              simp [FreeAddMonoid.lift_eval_of, C_add_scalar]
        | _, _, eqv.of_smul z f i r' =>
          (AddCon.ker_rel _).2$
            by 
              simp [FreeAddMonoid.lift_eval_of, C_smul]
        | _, _, eqv.add_comm x y =>
          (AddCon.ker_rel _).2$
            by 
              simpRw [AddMonoidHom.map_add, add_commₓ]

-- error in LinearAlgebra.PiTensorProduct: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[elab_as_eliminator]
protected
theorem induction_on'
{C : «expr⨂[ ] , »(R, (i), s i) → exprProp()}
(z : «expr⨂[ ] , »(R, (i), s i))
(C1 : ∀ {r : R} {f : ∀ i, s i}, C (tprod_coeff R r f))
(Cp : ∀ {x y}, C x → C y → C «expr + »(x, y)) : C z :=
begin
  have [ident C0] [":", expr C 0] [],
  { have [ident h₁] [] [":=", expr @C1 0 0],
    rwa ["[", expr zero_tprod_coeff, "]"] ["at", ident h₁] },
  refine [expr add_con.induction_on z (λ x, free_add_monoid.rec_on x C0 _)],
  simp_rw [expr add_con.coe_add] [],
  refine [expr λ f y ih, Cp _ ih],
  convert [] [expr @C1 f.1 f.2] [],
  simp [] [] ["only"] ["[", expr prod.mk.eta, "]"] [] []
end

section DistribMulAction

variable[Monoidₓ R₁][DistribMulAction R₁ R][SmulCommClass R₁ R R]

variable[Monoidₓ R₂][DistribMulAction R₂ R][SmulCommClass R₂ R R]

-- error in LinearAlgebra.PiTensorProduct: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
instance has_scalar' : has_scalar R₁ «expr⨂[ ] , »(R, (i), s i) :=
⟨λ
 r, lift_add_hom (λ
  f : «expr × »(R, ∀
   i, s i), tprod_coeff R «expr • »(r, f.1) f.2) (λ
  r'
  f
  i
  hf, by simp_rw ["[", expr zero_tprod_coeff' _ f i hf, "]"] []) (λ
  f, by simp [] [] [] ["[", expr zero_tprod_coeff, "]"] [] []) (λ
  r'
  f
  i
  m₁
  m₂, by simp [] [] [] ["[", expr add_tprod_coeff, "]"] [] []) (λ
  r'
  r''
  f, by simp [] [] [] ["[", expr add_tprod_coeff', ",", expr mul_add, "]"] [] []) (λ
  z f i r', by simp [] [] [] ["[", expr smul_tprod_coeff, ",", expr mul_smul_comm, "]"] [] [])⟩

instance  : HasScalar R (⨂[R] i, s i) :=
  PiTensorProduct.hasScalar'

theorem smul_tprod_coeff' (r : R₁) (z : R) (f : ∀ i, s i) : r • tprod_coeff R z f = tprod_coeff R (r • z) f :=
  rfl

protected theorem smul_add (r : R₁) (x y : ⨂[R] i, s i) : (r • x+y) = (r • x)+r • y :=
  AddMonoidHom.map_add _ _ _

instance distrib_mul_action' : DistribMulAction R₁ (⨂[R] i, s i) :=
  { smul := · • ·, smul_add := fun r x y => AddMonoidHom.map_add _ _ _,
    mul_smul :=
      fun r r' x =>
        PiTensorProduct.induction_on' x
          (fun r'' f =>
            by 
              simp [smul_tprod_coeff', smul_smul])
          fun x y ihx ihy =>
            by 
              simpRw [PiTensorProduct.smul_add, ihx, ihy],
    one_smul :=
      fun x =>
        PiTensorProduct.induction_on' x
          (fun f =>
            by 
              simp [smul_tprod_coeff' _ _])
          fun z y ihz ihy =>
            by 
              simpRw [PiTensorProduct.smul_add, ihz, ihy],
    smul_zero := fun r => AddMonoidHom.map_zero _ }

instance smul_comm_class' [SmulCommClass R₁ R₂ R] : SmulCommClass R₁ R₂ (⨂[R] i, s i) :=
  ⟨fun r' r'' x =>
      PiTensorProduct.induction_on' x
        (fun xr xf =>
          by 
            simp only [smul_tprod_coeff', smul_comm])
        fun z y ihz ihy =>
          by 
            simpRw [PiTensorProduct.smul_add, ihz, ihy]⟩

instance is_scalar_tower' [HasScalar R₁ R₂] [IsScalarTower R₁ R₂ R] : IsScalarTower R₁ R₂ (⨂[R] i, s i) :=
  ⟨fun r' r'' x =>
      PiTensorProduct.induction_on' x
        (fun xr xf =>
          by 
            simp only [smul_tprod_coeff', smul_assoc])
        fun z y ihz ihy =>
          by 
            simpRw [PiTensorProduct.smul_add, ihz, ihy]⟩

end DistribMulAction

instance module' [Semiringₓ R₁] [Module R₁ R] [SmulCommClass R₁ R R] : Module R₁ (⨂[R] i, s i) :=
  { PiTensorProduct.distribMulAction' with smul := · • ·,
    add_smul :=
      fun r r' x =>
        PiTensorProduct.induction_on' x
          (fun r f =>
            by 
              simp [smul_tprod_coeff' _ _, add_smul, add_tprod_coeff'])
          fun x y ihx ihy =>
            by 
              simp [PiTensorProduct.smul_add, ihx, ihy, add_add_add_commₓ],
    zero_smul :=
      fun x =>
        PiTensorProduct.induction_on' x
          (fun r f =>
            by 
              simpRw [smul_tprod_coeff' _ _, zero_smul]
              exact zero_tprod_coeff _)
          fun x y ihx ihy =>
            by 
              rw [PiTensorProduct.smul_add, ihx, ihy, add_zeroₓ] }

instance  : Module R (⨂[R] i, s i) :=
  PiTensorProduct.module'

instance  : SmulCommClass R R (⨂[R] i, s i) :=
  PiTensorProduct.smul_comm_class'

instance  : IsScalarTower R R (⨂[R] i, s i) :=
  PiTensorProduct.is_scalar_tower'

variable{R}

variable(R)

/-- The canonical `multilinear_map R s (⨂[R] i, s i)`. -/
def tprod : MultilinearMap R s (⨂[R] i, s i) :=
  { toFun := tprod_coeff R 1, map_add' := fun f i x y => (add_tprod_coeff (1 : R) f i x y).symm,
    map_smul' :=
      fun f i r x =>
        by 
          simpRw [smul_tprod_coeff', ←smul_tprod_coeff (1 : R) _ i, update_idem, update_same] }

variable{R}

notation3 :100 "⨂ₜ[" R "] " (...) ", " r:(scoped f => tprod R f) => r

-- error in LinearAlgebra.PiTensorProduct: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem tprod_coeff_eq_smul_tprod (z : R) (f : ∀ i, s i) : «expr = »(tprod_coeff R z f, «expr • »(z, tprod R f)) :=
begin
  have [] [":", expr «expr = »(z, «expr • »(z, (1 : R)))] [":=", expr by simp [] [] ["only"] ["[", expr mul_one, ",", expr algebra.id.smul_eq_mul, "]"] [] []],
  conv_lhs [] [] { rw [expr this] },
  rw ["<-", expr smul_tprod_coeff'] [],
  refl
end

@[elab_as_eliminator]
protected theorem induction_on {C : (⨂[R] i, s i) → Prop} (z : ⨂[R] i, s i)
  (C1 : ∀ {r : R} {f : ∀ i, s i}, C (r • tprod R f)) (Cp : ∀ {x y}, C x → C y → C (x+y)) : C z :=
  by 
    simpRw [←tprod_coeff_eq_smul_tprod]  at C1 
    exact PiTensorProduct.induction_on' z @C1 @Cp

@[ext]
theorem ext {φ₁ φ₂ : (⨂[R] i, s i) →ₗ[R] E}
  (H : φ₁.comp_multilinear_map (tprod R) = φ₂.comp_multilinear_map (tprod R)) : φ₁ = φ₂ :=
  by 
    refine' LinearMap.ext _ 
    refine'
      fun z =>
        PiTensorProduct.induction_on' z _
          fun x y hx hy =>
            by 
              rw [φ₁.map_add, φ₂.map_add, hx, hy]
    ·
      intro r f 
      rw [tprod_coeff_eq_smul_tprod, φ₁.map_smul, φ₂.map_smul]
      apply _root_.congr_arg 
      exact MultilinearMap.congr_fun H f

end Module

section Multilinear

open MultilinearMap

variable{s}

-- error in LinearAlgebra.PiTensorProduct: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Auxiliary function to constructing a linear map `(⨂[R] i, s i) → E` given a
`multilinear map R s E` with the property that its composition with the canonical
`multilinear_map R s (⨂[R] i, s i)` is the given multilinear map. -/
def lift_aux (φ : multilinear_map R s E) : «expr →+ »(«expr⨂[ ] , »(R, (i), s i), E) :=
lift_add_hom (λ
 p : «expr × »(R, ∀
  i, s i), «expr • »(p.1, φ p.2)) (λ
 z
 f
 i
 hf, by rw ["[", expr map_coord_zero φ i hf, ",", expr smul_zero, "]"] []) (λ
 f, by rw ["[", expr zero_smul, "]"] []) (λ
 z
 f
 i
 m₁
 m₂, by rw ["[", "<-", expr smul_add, ",", expr φ.map_add, "]"] []) (λ
 z₁
 z₂
 f, by rw ["[", "<-", expr add_smul, "]"] []) (λ
 z f i r, by simp [] [] [] ["[", expr φ.map_smul, ",", expr smul_smul, ",", expr mul_comm, "]"] [] [])

theorem lift_aux_tprod (φ : MultilinearMap R s E) (f : ∀ i, s i) : lift_aux φ (tprod R f) = φ f :=
  by 
    simp only [lift_aux, lift_add_hom, tprod, MultilinearMap.coe_mk, tprod_coeff, FreeAddMonoid.lift_eval_of, one_smul,
      AddCon.lift_mk']

theorem lift_aux_tprod_coeff (φ : MultilinearMap R s E) (z : R) (f : ∀ i, s i) :
  lift_aux φ (tprod_coeff R z f) = z • φ f :=
  by 
    simp [lift_aux, lift_add_hom, tprod_coeff, FreeAddMonoid.lift_eval_of]

theorem lift_aux.smul {φ : MultilinearMap R s E} (r : R) (x : ⨂[R] i, s i) : lift_aux φ (r • x) = r • lift_aux φ x :=
  by 
    refine' PiTensorProduct.induction_on' x _ _
    ·
      intro z f 
      rw [smul_tprod_coeff' r z f, lift_aux_tprod_coeff, lift_aux_tprod_coeff, smul_assoc]
    ·
      intro z y ihz ihy 
      rw [smul_add, (lift_aux φ).map_add, ihz, ihy, (lift_aux φ).map_add, smul_add]

/-- Constructing a linear map `(⨂[R] i, s i) → E` given a `multilinear_map R s E` with the
property that its composition with the canonical `multilinear_map R s E` is
the given multilinear map `φ`. -/
def lift : MultilinearMap R s E ≃ₗ[R] (⨂[R] i, s i) →ₗ[R] E :=
  { toFun := fun φ => { lift_aux φ with map_smul' := lift_aux.smul },
    invFun := fun φ' => φ'.comp_multilinear_map (tprod R),
    left_inv :=
      fun φ =>
        by 
          ext 
          simp [lift_aux_tprod, LinearMap.compMultilinearMap],
    right_inv :=
      fun φ =>
        by 
          ext 
          simp [lift_aux_tprod],
    map_add' :=
      fun φ₁ φ₂ =>
        by 
          ext 
          simp [lift_aux_tprod],
    map_smul' :=
      fun r φ₂ =>
        by 
          ext 
          simp [lift_aux_tprod] }

variable{φ : MultilinearMap R s E}

@[simp]
theorem lift.tprod (f : ∀ i, s i) : lift φ (tprod R f) = φ f :=
  lift_aux_tprod φ f

theorem lift.unique' {φ' : (⨂[R] i, s i) →ₗ[R] E} (H : φ'.comp_multilinear_map (tprod R) = φ) : φ' = lift φ :=
  ext$ H.symm ▸ (lift.symm_apply_apply φ).symm

theorem lift.unique {φ' : (⨂[R] i, s i) →ₗ[R] E} (H : ∀ f, φ' (tprod R f) = φ f) : φ' = lift φ :=
  lift.unique' (MultilinearMap.ext H)

@[simp]
theorem lift_symm (φ' : (⨂[R] i, s i) →ₗ[R] E) : lift.symm φ' = φ'.comp_multilinear_map (tprod R) :=
  rfl

@[simp]
theorem lift_tprod : lift (tprod R : MultilinearMap R s _) = LinearMap.id :=
  Eq.symm$ lift.unique' rfl

section 

variable(R M)

/-- Re-index the components of the tensor power by `e`.

For simplicity, this is defined only for homogeneously- (rather than dependently-) typed components.
-/
def reindex (e : ι ≃ ι₂) : (⨂[R] i : ι, M) ≃ₗ[R] ⨂[R] i : ι₂, M :=
  LinearEquiv.ofLinear (lift (dom_dom_congr e.symm (tprod R : MultilinearMap R _ (⨂[R] i : ι₂, M))))
    (lift (dom_dom_congr e (tprod R : MultilinearMap R _ (⨂[R] i : ι, M))))
    (by 
      ext 
      simp only [LinearMap.comp_apply, LinearMap.id_apply, lift_tprod, LinearMap.comp_multilinear_map_apply, lift.tprod,
        dom_dom_congr_apply, Equiv.apply_symm_apply])
    (by 
      ext 
      simp only [LinearMap.comp_apply, LinearMap.id_apply, lift_tprod, LinearMap.comp_multilinear_map_apply, lift.tprod,
        dom_dom_congr_apply, Equiv.symm_apply_apply])

end 

@[simp]
theorem reindex_tprod (e : ι ≃ ι₂) (f : ∀ i, M) : reindex R M e (tprod R f) = tprod R fun i => f (e.symm i) :=
  lift.tprod f

@[simp]
theorem reindex_comp_tprod (e : ι ≃ ι₂) :
  (reindex R M e : (⨂[R] i : ι, M) →ₗ[R] ⨂[R] i : ι₂, M).compMultilinearMap (tprod R) =
    (tprod R : MultilinearMap R (fun i => M) _).domDomCongr e.symm :=
  MultilinearMap.ext$ reindex_tprod e

-- error in LinearAlgebra.PiTensorProduct: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem lift_comp_reindex
(e : «expr ≃ »(ι, ι₂))
(φ : multilinear_map R (λ
  _ : ι₂, M) E) : «expr = »(«expr ∘ₗ »(lift φ, «expr↑ »(reindex R M e)), lift (φ.dom_dom_congr e.symm)) :=
by { ext [] [] [],
  simp [] [] [] [] [] [] }

@[simp]
theorem lift_reindex (e : ι ≃ ι₂) (φ : MultilinearMap R (fun _ => M) E) (x : ⨂[R] i, M) :
  lift φ (reindex R M e x) = lift (φ.dom_dom_congr e.symm) x :=
  LinearMap.congr_fun (lift_comp_reindex e φ) x

@[simp]
theorem reindex_trans (e : ι ≃ ι₂) (e' : ι₂ ≃ ι₃) : (reindex R M e).trans (reindex R M e') = reindex R M (e.trans e') :=
  by 
    apply LinearEquiv.to_linear_map_injective 
    ext f 
    simp only [LinearEquiv.trans_apply, LinearEquiv.coe_coe, reindex_tprod, LinearMap.coe_comp_multilinear_map,
      Function.comp_app, MultilinearMap.dom_dom_congr_apply, reindex_comp_tprod]
    congr

@[simp]
theorem reindex_reindex (e : ι ≃ ι₂) (e' : ι₂ ≃ ι₃) (x : ⨂[R] i, M) :
  reindex R M e' (reindex R M e x) = reindex R M (e.trans e') x :=
  LinearEquiv.congr_fun (reindex_trans e e' : _ = reindex R M (e.trans e')) x

@[simp]
theorem reindex_symm (e : ι ≃ ι₂) : (reindex R M e).symm = reindex R M e.symm :=
  rfl

@[simp]
theorem reindex_refl : reindex R M (Equiv.refl ι) = LinearEquiv.refl R _ :=
  by 
    apply LinearEquiv.to_linear_map_injective 
    ext1 
    rw [reindex_comp_tprod, LinearEquiv.refl_to_linear_map, Equiv.refl_symm]
    rfl

variable(ι)

-- error in LinearAlgebra.PiTensorProduct: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The tensor product over an empty index type `ι` is isomorphic to the base ring. -/
@[simps #[ident symm_apply]]
def is_empty_equiv [is_empty ι] : «expr ≃ₗ[ ] »(«expr⨂[ ] , »(R, (i : ι), M), R, R) :=
{ to_fun := lift (const_of_is_empty R 1),
  inv_fun := λ r, «expr • »(r, tprod R (@is_empty_elim _ _ _)),
  left_inv := λ x, by { apply [expr x.induction_on],
    { intros [ident r, ident f],
      have [] [] [":=", expr subsingleton.elim f is_empty_elim],
      simp [] [] [] ["[", expr this, "]"] [] [] },
    { simp [] [] ["only"] [] [] [],
      intros [ident x, ident y, ident hx, ident hy],
      simp [] [] [] ["[", expr add_smul, ",", expr hx, ",", expr hy, "]"] [] [] } },
  right_inv := λ
  t, by simp [] [] ["only"] ["[", expr mul_one, ",", expr algebra.id.smul_eq_mul, ",", expr const_of_is_empty_apply, ",", expr linear_map.map_smul, ",", expr pi_tensor_product.lift.tprod, "]"] [] [],
  map_add' := linear_map.map_add _,
  map_smul' := linear_map.map_smul _ }

@[simp]
theorem is_empty_equiv_apply_tprod [IsEmpty ι] (f : ι → M) : is_empty_equiv ι (tprod R f) = 1 :=
  lift.tprod _

variable{ι}

-- error in LinearAlgebra.PiTensorProduct: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The tensor product over an single index is isomorphic to the module -/
@[simps #[ident symm_apply]]
def subsingleton_equiv [subsingleton ι] (i₀ : ι) : «expr ≃ₗ[ ] »(«expr⨂[ ] , »(R, (i : ι), M), R, M) :=
{ to_fun := lift (multilinear_map.of_subsingleton R M i₀),
  inv_fun := λ m, tprod R (λ v, m),
  left_inv := λ x, by { dsimp ["only"] [] [] [],
    have [] [":", expr ∀ (f : ι → M) (z : M), «expr = »(λ i : ι, z, update f i₀ z)] [],
    { intros [ident f, ident z],
      ext [] [ident i] [],
      rw ["[", expr subsingleton.elim i i₀, ",", expr function.update_same, "]"] [] },
    apply [expr x.induction_on],
    { intros [ident r, ident f],
      simp [] [] ["only"] ["[", expr linear_map.map_smul, ",", expr lift.tprod, ",", expr of_subsingleton_apply, ",", expr function.eval, ",", expr this f, ",", expr map_smul, ",", expr update_eq_self, "]"] [] [] },
    { intros [ident x, ident y, ident hx, ident hy],
      simp [] [] ["only"] ["[", expr linear_map.map_add, ",", expr this 0 «expr + »(_, _), ",", expr map_add, ",", "<-", expr this 0 (lift _ _), ",", expr hx, ",", expr hy, "]"] [] [] } },
  right_inv := λ
  t, by simp [] [] ["only"] ["[", expr of_subsingleton_apply, ",", expr lift.tprod, ",", expr function.eval_apply, "]"] [] [],
  map_add' := linear_map.map_add _,
  map_smul' := linear_map.map_smul _ }

@[simp]
theorem subsingleton_equiv_apply_tprod [Subsingleton ι] (i : ι) (f : ι → M) : subsingleton_equiv i (tprod R f) = f i :=
  lift.tprod _

section Tmul

/-- Collapse a `tensor_product` of `pi_tensor_product`s. -/
private def tmul : ((⨂[R] i : ι, M) ⊗[R] ⨂[R] i : ι₂, M) →ₗ[R] ⨂[R] i : Sum ι ι₂, M :=
  TensorProduct.lift
    { toFun := fun a => PiTensorProduct.lift$ PiTensorProduct.lift (MultilinearMap.currySumEquiv R _ _ M _ (tprod R)) a,
      map_add' :=
        fun a b =>
          by 
            simp only [LinearEquiv.map_add, LinearMap.map_add],
      map_smul' :=
        fun r a =>
          by 
            simp only [LinearEquiv.map_smul, LinearMap.map_smul, RingHom.id_apply] }

private theorem tmul_apply (a : ι → M) (b : ι₂ → M) :
  tmul ((⨂ₜ[R] i, a i) ⊗ₜ[R] ⨂ₜ[R] i, b i) = ⨂ₜ[R] i, Sum.elim a b i :=
  by 
    erw [TensorProduct.lift.tmul, PiTensorProduct.lift.tprod, PiTensorProduct.lift.tprod]
    rfl

/-- Expand `pi_tensor_product` into a `tensor_product` of two factors. -/
private def tmul_symm : (⨂[R] i : Sum ι ι₂, M) →ₗ[R] (⨂[R] i : ι, M) ⊗[R] ⨂[R] i : ι₂, M :=
  PiTensorProduct.lift$
    by 
      apply MultilinearMap.domCoprod <;> [exact tprod R, exact tprod R]

private theorem tmul_symm_apply (a : Sum ι ι₂ → M) :
  tmul_symm (⨂ₜ[R] i, a i) = (⨂ₜ[R] i, a (Sum.inl i)) ⊗ₜ[R] ⨂ₜ[R] i, a (Sum.inr i) :=
  PiTensorProduct.lift.tprod _

variable(R M)

attribute [local ext] TensorProduct.ext

/-- Equivalence between a `tensor_product` of `pi_tensor_product`s and a single
`pi_tensor_product` indexed by a `sum` type.

For simplicity, this is defined only for homogeneously- (rather than dependently-) typed components.
-/
def tmul_equiv : ((⨂[R] i : ι, M) ⊗[R] ⨂[R] i : ι₂, M) ≃ₗ[R] ⨂[R] i : Sum ι ι₂, M :=
  LinearEquiv.ofLinear tmul tmul_symm
    (by 
      ext x 
      show tmul (tmul_symm (tprod R x)) = tprod R x 
      simp only [tmul_symm_apply, tmul_apply, Sum.elim_comp_inl_inr])
    (by 
      ext x y 
      show tmul_symm (tmul (tprod R x ⊗ₜ[R] tprod R y)) = tprod R x ⊗ₜ[R] tprod R y 
      simp only [tmul_apply, tmul_symm_apply, Sum.elim_inl, Sum.elim_inr])

@[simp]
theorem tmul_equiv_apply (a : ι → M) (b : ι₂ → M) :
  tmul_equiv R M ((⨂ₜ[R] i, a i) ⊗ₜ[R] ⨂ₜ[R] i, b i) = ⨂ₜ[R] i, Sum.elim a b i :=
  tmul_apply a b

@[simp]
theorem tmul_equiv_symm_apply (a : Sum ι ι₂ → M) :
  (tmul_equiv R M).symm (⨂ₜ[R] i, a i) = (⨂ₜ[R] i, a (Sum.inl i)) ⊗ₜ[R] ⨂ₜ[R] i, a (Sum.inr i) :=
  tmul_symm_apply a

end Tmul

end Multilinear

end PiTensorProduct

end Semiringₓ

section Ringₓ

namespace PiTensorProduct

open PiTensorProduct

open_locale TensorProduct

variable{ι : Type _}[DecidableEq ι]{R : Type _}[CommRingₓ R]

variable{s : ι → Type _}[∀ i, AddCommGroupₓ (s i)][∀ i, Module R (s i)]

instance  : AddCommGroupₓ (⨂[R] i, s i) :=
  Module.addCommMonoidToAddCommGroup R

end PiTensorProduct

end Ringₓ

