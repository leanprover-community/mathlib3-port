import Mathbin.Algebra.RingQuot 
import Mathbin.LinearAlgebra.TensorAlgebra 
import Mathbin.LinearAlgebra.Alternating 
import Mathbin.GroupTheory.Perm.Sign

/-!
# Exterior Algebras

We construct the exterior algebra of a module `M` over a commutative semiring `R`.

## Notation

The exterior algebra of the `R`-module `M` is denoted as `exterior_algebra R M`.
It is endowed with the structure of an `R`-algebra.

Given a linear morphism `f : M → A` from a module `M` to another `R`-algebra `A`, such that
`cond : ∀ m : M, f m * f m = 0`, there is a (unique) lift of `f` to an `R`-algebra morphism,
which is denoted `exterior_algebra.lift R f cond`.

The canonical linear map `M → exterior_algebra R M` is denoted `exterior_algebra.ι R`.

## Theorems

The main theorems proved ensure that `exterior_algebra R M` satisfies the universal property
of the exterior algebra.
1. `ι_comp_lift` is  fact that the composition of `ι R` with `lift R f cond` agrees with `f`.
2. `lift_unique` ensures the uniqueness of `lift R f cond` with respect to 1.

## Definitions

* `ι_multi` is the `alternating_map` corresponding to the wedge product of `ι R m` terms.

## Implementation details

The exterior algebra of `M` is constructed as a quotient of the tensor algebra, as follows.
1. We define a relation `exterior_algebra.rel R M` on `tensor_algebra R M`.
   This is the smallest relation which identifies squares of elements of `M` with `0`.
2. The exterior algebra is the quotient of the tensor algebra by this relation.

-/


universe u1 u2 u3

variable(R : Type u1)[CommSemiringₓ R]

variable(M : Type u2)[AddCommMonoidₓ M][Module R M]

namespace ExteriorAlgebra

open TensorAlgebra

/-- `rel` relates each `ι m * ι m`, for `m : M`, with `0`.

The exterior algebra of `M` is defined as the quotient modulo this relation.
-/
inductive rel : TensorAlgebra R M → TensorAlgebra R M → Prop
  | of (m : M) : rel (ι R m*ι R m) 0

end ExteriorAlgebra

-- error in LinearAlgebra.ExteriorAlgebra: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler inhabited
/--
The exterior algebra of an `R`-module `M`.
-/ @[derive #["[", expr inhabited, ",", expr semiring, ",", expr algebra R, "]"]] def exterior_algebra :=
ring_quot (exterior_algebra.rel R M)

namespace ExteriorAlgebra

variable{M}

instance  {S : Type u3} [CommRingₓ S] [Module S M] : Ringₓ (ExteriorAlgebra S M) :=
  RingQuot.ring (ExteriorAlgebra.Rel S M)

/--
The canonical linear map `M →ₗ[R] exterior_algebra R M`.
-/
def ι : M →ₗ[R] ExteriorAlgebra R M :=
  (RingQuot.mkAlgHom R _).toLinearMap.comp (TensorAlgebra.ι R)

variable{R}

/-- As well as being linear, `ι m` squares to zero -/
@[simp]
theorem ι_sq_zero (m : M) : (ι R m*ι R m) = 0 :=
  by 
    erw [←AlgHom.map_mul, RingQuot.mk_alg_hom_rel R (rel.of m), AlgHom.map_zero _]

variable{A : Type _}[Semiringₓ A][Algebra R A]

@[simp]
theorem comp_ι_sq_zero (g : ExteriorAlgebra R M →ₐ[R] A) (m : M) : (g (ι R m)*g (ι R m)) = 0 :=
  by 
    rw [←AlgHom.map_mul, ι_sq_zero, AlgHom.map_zero]

variable(R)

-- error in LinearAlgebra.ExteriorAlgebra: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/--
Given a linear map `f : M →ₗ[R] A` into an `R`-algebra `A`, which satisfies the condition:
`cond : ∀ m : M, f m * f m = 0`, this is the canonical lift of `f` to a morphism of `R`-algebras
from `exterior_algebra R M` to `A`.
-/
@[simps #[ident symm_apply]]
def lift : «expr ≃ »({f : «expr →ₗ[ ] »(M, R, A) // ∀
 m, «expr = »(«expr * »(f m, f m), 0)}, «expr →ₐ[ ] »(exterior_algebra R M, R, A)) :=
{ to_fun := λ
  f, ring_quot.lift_alg_hom R ⟨tensor_algebra.lift R (f : «expr →ₗ[ ] »(M, R, A)), λ
   (x y)
   (h : rel R M x y), by { induction [expr h] [] [] [],
     rw ["[", expr alg_hom.map_zero, ",", expr alg_hom.map_mul, ",", expr tensor_algebra.lift_ι_apply, ",", expr f.prop, "]"] [] }⟩,
  inv_fun := λ
  F, ⟨F.to_linear_map.comp (ι R), λ
   m, by rw ["[", expr linear_map.comp_apply, ",", expr alg_hom.to_linear_map_apply, ",", expr comp_ι_sq_zero, "]"] []⟩,
  left_inv := λ f, by { ext [] [] [],
    simp [] [] [] ["[", expr ι, "]"] [] [] },
  right_inv := λ F, by { ext [] [] [],
    simp [] [] [] ["[", expr ι, "]"] [] [] } }

@[simp]
theorem ι_comp_lift (f : M →ₗ[R] A) (cond : ∀ m, (f m*f m) = 0) : (lift R ⟨f, cond⟩).toLinearMap.comp (ι R) = f :=
  Subtype.mk_eq_mk.mp$ (lift R).symm_apply_apply ⟨f, cond⟩

@[simp]
theorem lift_ι_apply (f : M →ₗ[R] A) (cond : ∀ m, (f m*f m) = 0) x : lift R ⟨f, cond⟩ (ι R x) = f x :=
  (LinearMap.ext_iff.mp$ ι_comp_lift R f cond) x

@[simp]
theorem lift_unique (f : M →ₗ[R] A) (cond : ∀ m, (f m*f m) = 0) (g : ExteriorAlgebra R M →ₐ[R] A) :
  g.to_linear_map.comp (ι R) = f ↔ g = lift R ⟨f, cond⟩ :=
  by 
    convert (lift R).symm_apply_eq 
    rw [lift_symm_apply]
    simp only 

attribute [irreducible] ι lift

variable{R M}

@[simp]
theorem lift_comp_ι (g : ExteriorAlgebra R M →ₐ[R] A) : lift R ⟨g.to_linear_map.comp (ι R), comp_ι_sq_zero _⟩ = g :=
  by 
    convert (lift R).apply_symm_apply g 
    rw [lift_symm_apply]
    rfl

/-- See note [partially-applied ext lemmas]. -/
@[ext]
theorem hom_ext {f g : ExteriorAlgebra R M →ₐ[R] A} (h : f.to_linear_map.comp (ι R) = g.to_linear_map.comp (ι R)) :
  f = g :=
  by 
    apply (lift R).symm.Injective 
    rw [lift_symm_apply, lift_symm_apply]
    simp only [h]

-- error in LinearAlgebra.ExteriorAlgebra: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `C` holds for the `algebra_map` of `r : R` into `exterior_algebra R M`, the `ι` of `x : M`,
and is preserved under addition and muliplication, then it holds for all of `exterior_algebra R M`.
-/
@[elab_as_eliminator]
theorem induction
{C : exterior_algebra R M → exprProp()}
(h_grade0 : ∀ r, C (algebra_map R (exterior_algebra R M) r))
(h_grade1 : ∀ x, C (ι R x))
(h_mul : ∀ a b, C a → C b → C «expr * »(a, b))
(h_add : ∀ a b, C a → C b → C «expr + »(a, b))
(a : exterior_algebra R M) : C a :=
begin
  let [ident s] [":", expr subalgebra R (exterior_algebra R M)] [":=", expr { carrier := C,
     mul_mem' := h_mul,
     add_mem' := h_add,
     algebra_map_mem' := h_grade0 }],
  let [ident of] [":", expr {f : «expr →ₗ[ ] »(M, R, s) // ∀
   m, «expr = »(«expr * »(f m, f m), 0)}] [":=", expr ⟨(ι R).cod_restrict s.to_submodule h_grade1, λ
    m, «expr $ »(subtype.eq, ι_sq_zero m)⟩],
  have [ident of_id] [":", expr «expr = »(alg_hom.id R (exterior_algebra R M), s.val.comp (lift R of))] [],
  { ext [] [] [],
    simp [] [] [] ["[", expr of, "]"] [] [] },
  convert [] [expr subtype.prop (lift R of a)] [],
  exact [expr alg_hom.congr_fun of_id a]
end

/-- The left-inverse of `algebra_map`. -/
def algebra_map_inv : ExteriorAlgebra R M →ₐ[R] R :=
  ExteriorAlgebra.lift R
    ⟨(0 : M →ₗ[R] R),
      fun m =>
        by 
          simp ⟩

variable(M)

theorem algebra_map_left_inverse : Function.LeftInverse algebra_map_inv (algebraMap R$ ExteriorAlgebra R M) :=
  fun x =>
    by 
      simp [algebra_map_inv]

@[simp]
theorem algebra_map_inj (x y : R) :
  algebraMap R (ExteriorAlgebra R M) x = algebraMap R (ExteriorAlgebra R M) y ↔ x = y :=
  (algebra_map_left_inverse M).Injective.eq_iff

@[simp]
theorem algebra_map_eq_zero_iff (x : R) : algebraMap R (ExteriorAlgebra R M) x = 0 ↔ x = 0 :=
  by 
    rw [←algebra_map_inj M x 0, RingHom.map_zero]

@[simp]
theorem algebra_map_eq_one_iff (x : R) : algebraMap R (ExteriorAlgebra R M) x = 1 ↔ x = 1 :=
  by 
    rw [←algebra_map_inj M x 1, RingHom.map_one]

variable{M}

/-- The canonical map from `exterior_algebra R M` into `triv_sq_zero_ext R M` that sends
`exterior_algebra.ι` to `triv_sq_zero_ext.inr`. -/
def to_triv_sq_zero_ext : ExteriorAlgebra R M →ₐ[R] TrivSqZeroExt R M :=
  lift R ⟨TrivSqZeroExt.inrHom R M, fun m => TrivSqZeroExt.inr_mul_inr R _ m m⟩

@[simp]
theorem to_triv_sq_zero_ext_ι (x : M) : to_triv_sq_zero_ext (ι R x) = TrivSqZeroExt.inr x :=
  lift_ι_apply _ _ _ _

/-- The left-inverse of `ι`.

As an implementation detail, we implement this using `triv_sq_zero_ext` which has a suitable
algebra structure. -/
def ι_inv : ExteriorAlgebra R M →ₗ[R] M :=
  (TrivSqZeroExt.sndHom R M).comp to_triv_sq_zero_ext.toLinearMap

theorem ι_left_inverse : Function.LeftInverse ι_inv (ι R : M → ExteriorAlgebra R M) :=
  fun x =>
    by 
      simp [ι_inv]

variable(R)

@[simp]
theorem ι_inj (x y : M) : ι R x = ι R y ↔ x = y :=
  ι_left_inverse.Injective.eq_iff

variable{R}

@[simp]
theorem ι_eq_zero_iff (x : M) : ι R x = 0 ↔ x = 0 :=
  by 
    rw [←ι_inj R x 0, LinearMap.map_zero]

-- error in LinearAlgebra.ExteriorAlgebra: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem ι_eq_algebra_map_iff
(x : M)
(r : R) : «expr ↔ »(«expr = »(ι R x, algebra_map R _ r), «expr ∧ »(«expr = »(x, 0), «expr = »(r, 0))) :=
begin
  refine [expr ⟨λ h, _, _⟩],
  { have [ident hf0] [":", expr «expr = »(to_triv_sq_zero_ext (ι R x), (0, x))] [],
    from [expr to_triv_sq_zero_ext_ι _],
    rw ["[", expr h, ",", expr alg_hom.commutes, "]"] ["at", ident hf0],
    have [] [":", expr «expr ∧ »(«expr = »(r, 0), «expr = »(0, x))] [":=", expr prod.ext_iff.1 hf0],
    exact [expr this.symm.imp_left eq.symm] },
  { rintro ["⟨", ident rfl, ",", ident rfl, "⟩"],
    rw ["[", expr linear_map.map_zero, ",", expr ring_hom.map_zero, "]"] [] }
end

@[simp]
theorem ι_ne_one [Nontrivial R] (x : M) : ι R x ≠ 1 :=
  by 
    rw [←(algebraMap R (ExteriorAlgebra R M)).map_one, Ne.def, ι_eq_algebra_map_iff]
    exact one_ne_zero ∘ And.right

/-- The generators of the exterior algebra are disjoint from its scalars. -/
theorem ι_range_disjoint_one : Disjoint (ι R).range (1 : Submodule R (ExteriorAlgebra R M)) :=
  by 
    rw [Submodule.disjoint_def]
    rintro _ ⟨x, hx⟩ ⟨r, rfl : algebraMap _ _ _ = _⟩
    rw [ι_eq_algebra_map_iff x] at hx 
    rw [hx.2, RingHom.map_zero]

@[simp]
theorem ι_add_mul_swap (x y : M) : ((ι R x*ι R y)+ι R y*ι R x) = 0 :=
  calc _ = ι R (x+y)*ι R (x+y) :=
    by 
      simp [mul_addₓ, add_mulₓ]
    _ = _ := ι_sq_zero _
    

theorem ι_mul_prod_list {n : ℕ} (f : Finₓ n → M) (i : Finₓ n) : ((ι R$ f i)*(List.ofFn$ fun i => ι R$ f i).Prod) = 0 :=
  by 
    induction' n with n hn
    ·
      exact i.elim0
    ·
      rw [List.of_fn_succ, List.prod_cons, ←mul_assocₓ]
      byCases' h : i = 0
      ·
        rw [h, ι_sq_zero, zero_mul]
      ·
        replace hn := congr_argₓ ((·*·)$ ι R$ f 0) (hn (fun i => f$ Finₓ.succ i) (i.pred h))
        simp only  at hn 
        rw [Finₓ.succ_pred, ←mul_assocₓ, mul_zero] at hn 
        refine' (eq_zero_iff_eq_zero_of_add_eq_zero _).mp hn 
        rw [←add_mulₓ, ι_add_mul_swap, zero_mul]

variable(R)

/-- The product of `n` terms of the form `ι R m` is an alternating map.

This is a special case of `multilinear_map.mk_pi_algebra_fin` -/
def ι_multi (n : ℕ) : AlternatingMap R M (ExteriorAlgebra R M) (Finₓ n) :=
  let F := (MultilinearMap.mkPiAlgebraFin R n (ExteriorAlgebra R M)).compLinearMap fun i => ι R
  { F with
    map_eq_zero_of_eq' :=
      fun f x y hfxy hxy =>
        by 
          rw [MultilinearMap.comp_linear_map_apply, MultilinearMap.mk_pi_algebra_fin_apply]
          wlog h : x < y := lt_or_gt_of_neₓ hxy using x y 
          clear hxy 
          induction' n with n hn generalizing x y
          ·
            exact x.elim0
          ·
            rw [List.of_fn_succ, List.prod_cons]
            byCases' hx : x = 0
            ·
              rw [hx] at hfxy h 
              rw [hfxy, ←Finₓ.succ_pred y (ne_of_ltₓ h).symm]
              exact ι_mul_prod_list (f ∘ Finₓ.succ) _
            ·
              convert mul_zero _ 
              refine'
                hn (fun i => f$ Finₓ.succ i) (x.pred hx) (y.pred (ne_of_ltₓ$ lt_of_le_of_ltₓ x.zero_le h).symm)
                  (fin.pred_lt_pred_iff.mpr h) _ 
              simp only [Finₓ.succ_pred]
              exact hfxy,
    toFun := F }

variable{R}

theorem ι_multi_apply {n : ℕ} (v : Finₓ n → M) : ι_multi R n v = (List.ofFn$ fun i => ι R (v i)).Prod :=
  rfl

end ExteriorAlgebra

namespace TensorAlgebra

variable{R M}

/-- The canonical image of the `tensor_algebra` in the `exterior_algebra`, which maps
`tensor_algebra.ι R x` to `exterior_algebra.ι R x`. -/
def to_exterior : TensorAlgebra R M →ₐ[R] ExteriorAlgebra R M :=
  TensorAlgebra.lift R (ExteriorAlgebra.ι R)

@[simp]
theorem to_exterior_ι (m : M) : (TensorAlgebra.ι R m).toExterior = ExteriorAlgebra.ι R m :=
  by 
    simp [to_exterior]

end TensorAlgebra

