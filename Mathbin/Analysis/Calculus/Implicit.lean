/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.calculus.implicit
! leanprover-community/mathlib commit bbeb185db4ccee8ed07dc48449414ebfa39cb821
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Inverse
import Mathbin.Analysis.NormedSpace.Complemented

/-!
# Implicit function theorem

We prove three versions of the implicit function theorem. First we define a structure
`implicit_function_data` that holds arguments for the most general version of the implicit function
theorem, see `implicit_function_data.implicit_function`
and `implicit_function_data.to_implicit_function`. This version allows a user to choose
a specific implicit function but provides only a little convenience over the inverse function
theorem.

Then we define `implicit_function_of_complemented`: implicit function defined by `f (g z y) = z`,
where `f : E → F` is a function strictly differentiable at `a` such that its derivative `f'`
is surjective and has a `complemented` kernel.

Finally, if the codomain of `f` is a finite dimensional space, then we can automatically prove
that the kernel of `f'` is complemented, hence the only assumptions are `has_strict_fderiv_at`
and `f'.range = ⊤`. This version is named `implicit_function`.

## TODO

* Add a version for a function `f : E × F → G` such that $$\frac{\partial f}{\partial y}$$ is
  invertible.
* Add a version for `f : 𝕜 × 𝕜 → 𝕜` proving `has_strict_deriv_at` and `deriv φ = ...`.
* Prove that in a real vector space the implicit function has the same smoothness as the original
  one.
* If the original function is differentiable in a neighborhood, then the implicit function is
  differentiable in a neighborhood as well. Current setup only proves differentiability at one
  point for the implicit function constructed in this file (as opposed to an unspecified implicit
  function). One of the ways to overcome this difficulty is to use uniqueness of the implicit
  function in the general version of the theorem. Another way is to prove that *any* implicit
  function satisfying some predicate is strictly differentiable.

## Tags

implicit function, inverse function
-/


noncomputable section

open TopologicalSpace

open Filter

open ContinuousLinearMap (fst snd smul_right ker_prod)

open ContinuousLinearEquiv (ofBijective)

open LinearMap (ker range)

/-!
### General version

Consider two functions `f : E → F` and `g : E → G` and a point `a` such that

* both functions are strictly differentiable at `a`;
* the derivatives are surjective;
* the kernels of the derivatives are complementary subspaces of `E`.

Note that the map `x ↦ (f x, g x)` has a bijective derivative, hence it is a local homeomorphism
between `E` and `F × G`. We use this fact to define a function `φ : F → G → E`
(see `implicit_function_data.implicit_function`) such that for `(y, z)` close enough to `(f a, g a)`
we have `f (φ y z) = y` and `g (φ y z) = z`.

We also prove a formula for $$\frac{\partial\varphi}{\partial z}.$$

Though this statement is almost symmetric with respect to `F`, `G`, we interpret it in the following
way. Consider a family of surfaces `{x | f x = y}`, `y ∈ 𝓝 (f a)`. Each of these surfaces is
parametrized by `φ y`.

There are many ways to choose a (differentiable) function `φ` such that `f (φ y z) = y` but the
extra condition `g (φ y z) = z` allows a user to select one of these functions. If we imagine
that the level surfaces `f = const` form a local horizontal foliation, then the choice of
`g` fixes a transverse foliation `g = const`, and `φ` is the inverse function of the projection
of `{x | f x = y}` along this transverse foliation.

This version of the theorem is used to prove the other versions and can be used if a user
needs to have a complete control over the choice of the implicit function.
-/


/-- Data for the general version of the implicit function theorem. It holds two functions
`f : E → F` and `g : E → G` (named `left_fun` and `right_fun`) and a point `a` (named `pt`)
such that

* both functions are strictly differentiable at `a`;
* the derivatives are surjective;
* the kernels of the derivatives are complementary subspaces of `E`. -/
@[nolint has_nonempty_instance]
structure ImplicitFunctionData (𝕜 : Type _) [NontriviallyNormedField 𝕜] (E : Type _)
  [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E] (F : Type _) [NormedAddCommGroup F]
  [NormedSpace 𝕜 F] [CompleteSpace F] (G : Type _) [NormedAddCommGroup G] [NormedSpace 𝕜 G]
  [CompleteSpace G] where
  leftFun : E → F
  leftDeriv : E →L[𝕜] F
  rightFun : E → G
  rightDeriv : E →L[𝕜] G
  pt : E
  leftHasDeriv : HasStrictFderivAt left_fun left_deriv pt
  rightHasDeriv : HasStrictFderivAt right_fun right_deriv pt
  left_range : range left_deriv = ⊤
  right_range : range right_deriv = ⊤
  is_compl_ker : IsCompl (ker left_deriv) (ker right_deriv)
#align implicit_function_data ImplicitFunctionData

namespace ImplicitFunctionData

variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] {E : Type _} [NormedAddCommGroup E]
  [NormedSpace 𝕜 E] [CompleteSpace E] {F : Type _} [NormedAddCommGroup F] [NormedSpace 𝕜 F]
  [CompleteSpace F] {G : Type _} [NormedAddCommGroup G] [NormedSpace 𝕜 G] [CompleteSpace G]
  (φ : ImplicitFunctionData 𝕜 E F G)

/-- The function given by `x ↦ (left_fun x, right_fun x)`. -/
def prodFun (x : E) : F × G :=
  (φ.leftFun x, φ.rightFun x)
#align implicit_function_data.prod_fun ImplicitFunctionData.prodFun

@[simp]
theorem prod_fun_apply (x : E) : φ.prodFun x = (φ.leftFun x, φ.rightFun x) :=
  rfl
#align implicit_function_data.prod_fun_apply ImplicitFunctionData.prod_fun_apply

protected theorem hasStrictFderivAt :
    HasStrictFderivAt φ.prodFun
      (φ.leftDeriv.equivProdOfSurjectiveOfIsCompl φ.rightDeriv φ.left_range φ.right_range
          φ.is_compl_ker :
        E →L[𝕜] F × G)
      φ.pt :=
  φ.leftHasDeriv.Prod φ.rightHasDeriv
#align implicit_function_data.has_strict_fderiv_at ImplicitFunctionData.hasStrictFderivAt

/-- Implicit function theorem. If `f : E → F` and `g : E → G` are two maps strictly differentiable
at `a`, their derivatives `f'`, `g'` are surjective, and the kernels of these derivatives are
complementary subspaces of `E`, then `x ↦ (f x, g x)` defines a local homeomorphism between
`E` and `F × G`. In particular, `{x | f x = f a}` is locally homeomorphic to `G`. -/
def toLocalHomeomorph : LocalHomeomorph E (F × G) :=
  φ.HasStrictFderivAt.toLocalHomeomorph _
#align implicit_function_data.to_local_homeomorph ImplicitFunctionData.toLocalHomeomorph

/-- Implicit function theorem. If `f : E → F` and `g : E → G` are two maps strictly differentiable
at `a`, their derivatives `f'`, `g'` are surjective, and the kernels of these derivatives are
complementary subspaces of `E`, then `implicit_function_of_is_compl_ker` is the unique (germ of a)
map `φ : F → G → E` such that `f (φ y z) = y` and `g (φ y z) = z`. -/
def implicitFunction : F → G → E :=
  Function.curry <| φ.toLocalHomeomorph.symm
#align implicit_function_data.implicit_function ImplicitFunctionData.implicitFunction

@[simp]
theorem to_local_homeomorph_coe : ⇑φ.toLocalHomeomorph = φ.prodFun :=
  rfl
#align implicit_function_data.to_local_homeomorph_coe ImplicitFunctionData.to_local_homeomorph_coe

theorem to_local_homeomorph_apply (x : E) : φ.toLocalHomeomorph x = (φ.leftFun x, φ.rightFun x) :=
  rfl
#align
  implicit_function_data.to_local_homeomorph_apply ImplicitFunctionData.to_local_homeomorph_apply

theorem pt_mem_to_local_homeomorph_source : φ.pt ∈ φ.toLocalHomeomorph.source :=
  φ.HasStrictFderivAt.mem_to_local_homeomorph_source
#align
  implicit_function_data.pt_mem_to_local_homeomorph_source ImplicitFunctionData.pt_mem_to_local_homeomorph_source

theorem map_pt_mem_to_local_homeomorph_target :
    (φ.leftFun φ.pt, φ.rightFun φ.pt) ∈ φ.toLocalHomeomorph.target :=
  φ.toLocalHomeomorph.map_source <| φ.pt_mem_to_local_homeomorph_source
#align
  implicit_function_data.map_pt_mem_to_local_homeomorph_target ImplicitFunctionData.map_pt_mem_to_local_homeomorph_target

theorem prod_map_implicit_function :
    ∀ᶠ p : F × G in 𝓝 (φ.prodFun φ.pt), φ.prodFun (φ.implicitFunction p.1 p.2) = p :=
  φ.HasStrictFderivAt.eventually_right_inverse.mono fun ⟨z, y⟩ h => h
#align
  implicit_function_data.prod_map_implicit_function ImplicitFunctionData.prod_map_implicit_function

theorem left_map_implicit_function :
    ∀ᶠ p : F × G in 𝓝 (φ.prodFun φ.pt), φ.leftFun (φ.implicitFunction p.1 p.2) = p.1 :=
  φ.prod_map_implicit_function.mono fun z => congr_arg Prod.fst
#align
  implicit_function_data.left_map_implicit_function ImplicitFunctionData.left_map_implicit_function

theorem right_map_implicit_function :
    ∀ᶠ p : F × G in 𝓝 (φ.prodFun φ.pt), φ.rightFun (φ.implicitFunction p.1 p.2) = p.2 :=
  φ.prod_map_implicit_function.mono fun z => congr_arg Prod.snd
#align
  implicit_function_data.right_map_implicit_function ImplicitFunctionData.right_map_implicit_function

theorem implicit_function_apply_image :
    ∀ᶠ x in 𝓝 φ.pt, φ.implicitFunction (φ.leftFun x) (φ.rightFun x) = x :=
  φ.HasStrictFderivAt.eventually_left_inverse
#align
  implicit_function_data.implicit_function_apply_image ImplicitFunctionData.implicit_function_apply_image

theorem map_nhds_eq : map φ.leftFun (𝓝 φ.pt) = 𝓝 (φ.leftFun φ.pt) :=
  show map (Prod.fst ∘ φ.prodFun) (𝓝 φ.pt) = 𝓝 (φ.prodFun φ.pt).1 by
    rw [← map_map, φ.has_strict_fderiv_at.map_nhds_eq_of_equiv, map_fst_nhds]
#align implicit_function_data.map_nhds_eq ImplicitFunctionData.map_nhds_eq

theorem implicitFunctionHasStrictFderivAt (g'inv : G →L[𝕜] E)
    (hg'inv : φ.rightDeriv.comp g'inv = ContinuousLinearMap.id 𝕜 G)
    (hg'invf : φ.leftDeriv.comp g'inv = 0) :
    HasStrictFderivAt (φ.implicitFunction (φ.leftFun φ.pt)) g'inv (φ.rightFun φ.pt) := by
  have := φ.has_strict_fderiv_at.to_local_inverse
  simp only [prod_fun] at this
  convert this.comp (φ.right_fun φ.pt) ((hasStrictFderivAtConst _ _).Prod (hasStrictFderivAtId _))
  simp only [ContinuousLinearMap.ext_iff, ContinuousLinearMap.coe_comp', Function.comp_apply] at
    hg'inv hg'invf⊢
  simp [ContinuousLinearEquiv.eq_symm_apply, *]
#align
  implicit_function_data.implicit_function_has_strict_fderiv_at ImplicitFunctionData.implicitFunctionHasStrictFderivAt

end ImplicitFunctionData

namespace HasStrictFderivAt

section Complemented

/-!
### Case of a complemented kernel

In this section we prove the following version of the implicit function theorem. Consider a map
`f : E → F` and a point `a : E` such that `f` is strictly differentiable at `a`, its derivative `f'`
is surjective and the kernel of `f'` is a complemented subspace of `E` (i.e., it has a closed
complementary subspace). Then there exists a function `φ : F → ker f' → E` such that for `(y, z)`
close to `(f a, 0)` we have `f (φ y z) = y` and the derivative of `φ (f a)` at zero is the
embedding `ker f' → E`.

Note that a map with these properties is not unique. E.g., different choices of a subspace
complementary to `ker f'` lead to different maps `φ`.
-/


variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] {E : Type _} [NormedAddCommGroup E]
  [NormedSpace 𝕜 E] [CompleteSpace E] {F : Type _} [NormedAddCommGroup F] [NormedSpace 𝕜 F]
  [CompleteSpace F] {f : E → F} {f' : E →L[𝕜] F} {a : E}

section Defs

variable (f f')

/-- Data used to apply the generic implicit function theorem to the case of a strictly
differentiable map such that its derivative is surjective and has a complemented kernel. -/
@[simp]
def implicitFunctionDataOfComplemented (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤)
    (hker : (ker f').ClosedComplemented) :
    ImplicitFunctionData 𝕜 E F (ker f') where 
  leftFun := f
  leftDeriv := f'
  rightFun x := Classical.choose hker (x - a)
  rightDeriv := Classical.choose hker
  pt := a
  leftHasDeriv := hf
  rightHasDeriv :=
    (Classical.choose hker).HasStrictFderivAt.comp a ((hasStrictFderivAtId a).sub_const a)
  left_range := hf'
  right_range := LinearMap.range_eq_of_proj (Classical.choose_spec hker)
  is_compl_ker := LinearMap.is_compl_of_proj (Classical.choose_spec hker)
#align
  has_strict_fderiv_at.implicit_function_data_of_complemented HasStrictFderivAt.implicitFunctionDataOfComplemented

/-- A local homeomorphism between `E` and `F × f'.ker` sending level surfaces of `f`
to vertical subspaces. -/
def implicitToLocalHomeomorphOfComplemented (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤)
    (hker : (ker f').ClosedComplemented) : LocalHomeomorph E (F × ker f') :=
  (implicitFunctionDataOfComplemented f f' hf hf' hker).toLocalHomeomorph
#align
  has_strict_fderiv_at.implicit_to_local_homeomorph_of_complemented HasStrictFderivAt.implicitToLocalHomeomorphOfComplemented

/-- Implicit function `g` defined by `f (g z y) = z`. -/
def implicitFunctionOfComplemented (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤)
    (hker : (ker f').ClosedComplemented) : F → ker f' → E :=
  (implicitFunctionDataOfComplemented f f' hf hf' hker).implicitFunction
#align
  has_strict_fderiv_at.implicit_function_of_complemented HasStrictFderivAt.implicitFunctionOfComplemented

end Defs

@[simp]
theorem implicit_to_local_homeomorph_of_complemented_fst (hf : HasStrictFderivAt f f' a)
    (hf' : range f' = ⊤) (hker : (ker f').ClosedComplemented) (x : E) :
    (hf.implicitToLocalHomeomorphOfComplemented f f' hf' hker x).fst = f x :=
  rfl
#align
  has_strict_fderiv_at.implicit_to_local_homeomorph_of_complemented_fst HasStrictFderivAt.implicit_to_local_homeomorph_of_complemented_fst

theorem implicit_to_local_homeomorph_of_complemented_apply (hf : HasStrictFderivAt f f' a)
    (hf' : range f' = ⊤) (hker : (ker f').ClosedComplemented) (y : E) :
    hf.implicitToLocalHomeomorphOfComplemented f f' hf' hker y =
      (f y, Classical.choose hker (y - a)) :=
  rfl
#align
  has_strict_fderiv_at.implicit_to_local_homeomorph_of_complemented_apply HasStrictFderivAt.implicit_to_local_homeomorph_of_complemented_apply

@[simp]
theorem implicit_to_local_homeomorph_of_complemented_apply_ker (hf : HasStrictFderivAt f f' a)
    (hf' : range f' = ⊤) (hker : (ker f').ClosedComplemented) (y : ker f') :
    hf.implicitToLocalHomeomorphOfComplemented f f' hf' hker (y + a) = (f (y + a), y) := by
  simp only [implicit_to_local_homeomorph_of_complemented_apply, add_sub_cancel,
    Classical.choose_spec hker]
#align
  has_strict_fderiv_at.implicit_to_local_homeomorph_of_complemented_apply_ker HasStrictFderivAt.implicit_to_local_homeomorph_of_complemented_apply_ker

@[simp]
theorem implicit_to_local_homeomorph_of_complemented_self (hf : HasStrictFderivAt f f' a)
    (hf' : range f' = ⊤) (hker : (ker f').ClosedComplemented) :
    hf.implicitToLocalHomeomorphOfComplemented f f' hf' hker a = (f a, 0) := by
  simp [hf.implicit_to_local_homeomorph_of_complemented_apply]
#align
  has_strict_fderiv_at.implicit_to_local_homeomorph_of_complemented_self HasStrictFderivAt.implicit_to_local_homeomorph_of_complemented_self

theorem mem_implicit_to_local_homeomorph_of_complemented_source (hf : HasStrictFderivAt f f' a)
    (hf' : range f' = ⊤) (hker : (ker f').ClosedComplemented) :
    a ∈ (hf.implicitToLocalHomeomorphOfComplemented f f' hf' hker).source :=
  mem_to_local_homeomorph_source _
#align
  has_strict_fderiv_at.mem_implicit_to_local_homeomorph_of_complemented_source HasStrictFderivAt.mem_implicit_to_local_homeomorph_of_complemented_source

theorem mem_implicit_to_local_homeomorph_of_complemented_target (hf : HasStrictFderivAt f f' a)
    (hf' : range f' = ⊤) (hker : (ker f').ClosedComplemented) :
    (f a, (0 : ker f')) ∈ (hf.implicitToLocalHomeomorphOfComplemented f f' hf' hker).target := by
  simpa only [implicit_to_local_homeomorph_of_complemented_self] using
    (hf.implicit_to_local_homeomorph_of_complemented f f' hf' hker).map_source <|
      hf.mem_implicit_to_local_homeomorph_of_complemented_source hf' hker
#align
  has_strict_fderiv_at.mem_implicit_to_local_homeomorph_of_complemented_target HasStrictFderivAt.mem_implicit_to_local_homeomorph_of_complemented_target

/-- `implicit_function_of_complemented` sends `(z, y)` to a point in `f ⁻¹' z`. -/
theorem map_implicit_function_of_complemented_eq (hf : HasStrictFderivAt f f' a)
    (hf' : range f' = ⊤) (hker : (ker f').ClosedComplemented) :
    ∀ᶠ p : F × ker f' in 𝓝 (f a, 0),
      f (hf.implicitFunctionOfComplemented f f' hf' hker p.1 p.2) = p.1 :=
  ((hf.implicitToLocalHomeomorphOfComplemented f f' hf' hker).eventually_right_inverse <|
        hf.mem_implicit_to_local_homeomorph_of_complemented_target hf' hker).mono
    fun ⟨z, y⟩ h => congr_arg Prod.fst h
#align
  has_strict_fderiv_at.map_implicit_function_of_complemented_eq HasStrictFderivAt.map_implicit_function_of_complemented_eq

/-- Any point in some neighborhood of `a` can be represented as `implicit_function`
of some point. -/
theorem eq_implicit_function_of_complemented (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤)
    (hker : (ker f').ClosedComplemented) :
    ∀ᶠ x in 𝓝 a,
      hf.implicitFunctionOfComplemented f f' hf' hker (f x)
          (hf.implicitToLocalHomeomorphOfComplemented f f' hf' hker x).snd =
        x :=
  (implicitFunctionDataOfComplemented f f' hf hf' hker).implicit_function_apply_image
#align
  has_strict_fderiv_at.eq_implicit_function_of_complemented HasStrictFderivAt.eq_implicit_function_of_complemented

@[simp]
theorem implicit_function_of_complemented_apply_image (hf : HasStrictFderivAt f f' a)
    (hf' : range f' = ⊤) (hker : (ker f').ClosedComplemented) :
    hf.implicitFunctionOfComplemented f f' hf' hker (f a) 0 = a := by
  convert
    (hf.implicit_to_local_homeomorph_of_complemented f f' hf' hker).left_inv
      (hf.mem_implicit_to_local_homeomorph_of_complemented_source hf' hker)
  exact congr_arg Prod.snd (hf.implicit_to_local_homeomorph_of_complemented_self hf' hker).symm
#align
  has_strict_fderiv_at.implicit_function_of_complemented_apply_image HasStrictFderivAt.implicit_function_of_complemented_apply_image

theorem toImplicitFunctionOfComplemented (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤)
    (hker : (ker f').ClosedComplemented) :
    HasStrictFderivAt (hf.implicitFunctionOfComplemented f f' hf' hker (f a)) (ker f').subtypeL 0 :=
  by
  convert
    (implicit_function_data_of_complemented f f' hf hf' hker).implicitFunctionHasStrictFderivAt
      (ker f').subtypeL _ _
  swap
  · ext
    simp only [Classical.choose_spec hker, implicit_function_data_of_complemented,
      ContinuousLinearMap.coe_comp', Submodule.coe_subtypeL', Submodule.coe_subtype,
      Function.comp_apply, ContinuousLinearMap.coe_id', id.def]
  swap
  · ext
    simp only [ContinuousLinearMap.coe_comp', Submodule.coe_subtypeL', Submodule.coe_subtype,
      Function.comp_apply, LinearMap.map_coe_ker, ContinuousLinearMap.zero_apply]
  simp only [implicit_function_data_of_complemented, map_sub, sub_self]
#align
  has_strict_fderiv_at.to_implicit_function_of_complemented HasStrictFderivAt.toImplicitFunctionOfComplemented

end Complemented

/-!
### Finite dimensional case

In this section we prove the following version of the implicit function theorem. Consider a map
`f : E → F` from a Banach normed space to a finite dimensional space.
Take a point `a : E` such that `f` is strictly differentiable at `a` and its derivative `f'`
is surjective. Then there exists a function `φ : F → ker f' → E` such that for `(y, z)`
close to `(f a, 0)` we have `f (φ y z) = y` and the derivative of `φ (f a)` at zero is the
embedding `ker f' → E`.

This version deduces that `ker f'` is a complemented subspace from the fact that `F` is a finite
dimensional space, then applies the previous version.

Note that a map with these properties is not unique. E.g., different choices of a subspace
complementary to `ker f'` lead to different maps `φ`.
-/


section FiniteDimensional

variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] [CompleteSpace 𝕜] {E : Type _}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E] {F : Type _} [NormedAddCommGroup F]
  [NormedSpace 𝕜 F] [FiniteDimensional 𝕜 F] (f : E → F) (f' : E →L[𝕜] F) {a : E}

/-- Given a map `f : E → F` to a finite dimensional space with a surjective derivative `f'`,
returns a local homeomorphism between `E` and `F × ker f'`. -/
def implicitToLocalHomeomorph (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤) :
    LocalHomeomorph E (F × ker f') :=
  haveI := FiniteDimensional.complete 𝕜 F
  hf.implicit_to_local_homeomorph_of_complemented f f' hf'
    f'.ker_closed_complemented_of_finite_dimensional_range
#align has_strict_fderiv_at.implicit_to_local_homeomorph HasStrictFderivAt.implicitToLocalHomeomorph

/-- Implicit function `g` defined by `f (g z y) = z`. -/
def implicitFunction (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤) : F → ker f' → E :=
  Function.curry <| (hf.implicitToLocalHomeomorph f f' hf').symm
#align has_strict_fderiv_at.implicit_function HasStrictFderivAt.implicitFunction

variable {f f'}

@[simp]
theorem implicit_to_local_homeomorph_fst (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤)
    (x : E) : (hf.implicitToLocalHomeomorph f f' hf' x).fst = f x :=
  rfl
#align
  has_strict_fderiv_at.implicit_to_local_homeomorph_fst HasStrictFderivAt.implicit_to_local_homeomorph_fst

@[simp]
theorem implicit_to_local_homeomorph_apply_ker (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤)
    (y : ker f') : hf.implicitToLocalHomeomorph f f' hf' (y + a) = (f (y + a), y) := by
  apply implicit_to_local_homeomorph_of_complemented_apply_ker
#align
  has_strict_fderiv_at.implicit_to_local_homeomorph_apply_ker HasStrictFderivAt.implicit_to_local_homeomorph_apply_ker

@[simp]
theorem implicit_to_local_homeomorph_self (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤) :
    hf.implicitToLocalHomeomorph f f' hf' a = (f a, 0) := by
  apply implicit_to_local_homeomorph_of_complemented_self
#align
  has_strict_fderiv_at.implicit_to_local_homeomorph_self HasStrictFderivAt.implicit_to_local_homeomorph_self

theorem mem_implicit_to_local_homeomorph_source (hf : HasStrictFderivAt f f' a)
    (hf' : range f' = ⊤) : a ∈ (hf.implicitToLocalHomeomorph f f' hf').source :=
  mem_to_local_homeomorph_source _
#align
  has_strict_fderiv_at.mem_implicit_to_local_homeomorph_source HasStrictFderivAt.mem_implicit_to_local_homeomorph_source

theorem mem_implicit_to_local_homeomorph_target (hf : HasStrictFderivAt f f' a)
    (hf' : range f' = ⊤) : (f a, (0 : ker f')) ∈ (hf.implicitToLocalHomeomorph f f' hf').target :=
  by apply mem_implicit_to_local_homeomorph_of_complemented_target
#align
  has_strict_fderiv_at.mem_implicit_to_local_homeomorph_target HasStrictFderivAt.mem_implicit_to_local_homeomorph_target

theorem tendsto_implicit_function (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤) {α : Type _}
    {l : Filter α} {g₁ : α → F} {g₂ : α → ker f'} (h₁ : Tendsto g₁ l (𝓝 <| f a))
    (h₂ : Tendsto g₂ l (𝓝 0)) :
    Tendsto (fun t => hf.implicitFunction f f' hf' (g₁ t) (g₂ t)) l (𝓝 a) := by
  refine'
    ((hf.implicit_to_local_homeomorph f f' hf').tendsto_symm
          (hf.mem_implicit_to_local_homeomorph_source hf')).comp
      _
  rw [implicit_to_local_homeomorph_self]
  exact h₁.prod_mk_nhds h₂
#align has_strict_fderiv_at.tendsto_implicit_function HasStrictFderivAt.tendsto_implicit_function

alias tendsto_implicit_function ← _root_.filter.tendsto.implicit_function

/-- `implicit_function` sends `(z, y)` to a point in `f ⁻¹' z`. -/
theorem map_implicit_function_eq (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤) :
    ∀ᶠ p : F × ker f' in 𝓝 (f a, 0), f (hf.implicitFunction f f' hf' p.1 p.2) = p.1 := by
  apply map_implicit_function_of_complemented_eq
#align has_strict_fderiv_at.map_implicit_function_eq HasStrictFderivAt.map_implicit_function_eq

@[simp]
theorem implicit_function_apply_image (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤) :
    hf.implicitFunction f f' hf' (f a) 0 = a := by
  apply implicit_function_of_complemented_apply_image
#align
  has_strict_fderiv_at.implicit_function_apply_image HasStrictFderivAt.implicit_function_apply_image

/-- Any point in some neighborhood of `a` can be represented as `implicit_function`
of some point. -/
theorem eq_implicit_function (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤) :
    ∀ᶠ x in 𝓝 a,
      hf.implicitFunction f f' hf' (f x) (hf.implicitToLocalHomeomorph f f' hf' x).snd = x :=
  by apply eq_implicit_function_of_complemented
#align has_strict_fderiv_at.eq_implicit_function HasStrictFderivAt.eq_implicit_function

theorem toImplicitFunction (hf : HasStrictFderivAt f f' a) (hf' : range f' = ⊤) :
    HasStrictFderivAt (hf.implicitFunction f f' hf' (f a)) (ker f').subtypeL 0 := by
  apply to_implicit_function_of_complemented
#align has_strict_fderiv_at.to_implicit_function HasStrictFderivAt.toImplicitFunction

end FiniteDimensional

end HasStrictFderivAt

