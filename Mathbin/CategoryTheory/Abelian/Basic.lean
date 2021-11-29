import Mathbin.CategoryTheory.Limits.Constructions.Pullbacks 
import Mathbin.CategoryTheory.Limits.Shapes.Biproducts 
import Mathbin.CategoryTheory.Limits.Shapes.Images 
import Mathbin.CategoryTheory.Abelian.NonPreadditive

/-!
# Abelian categories

This file contains the definition and basic properties of abelian categories.

There are many definitions of abelian category. Our definition is as follows:
A category is called abelian if it is preadditive,
has a finite products, kernels and cokernels,
and if every monomorphism and epimorphism is normal.

It should be noted that if we also assume coproducts, then preadditivity is
actually a consequence of the other properties, as we show in
`non_preadditive_abelian.lean`. However, this fact is of little practical
relevance, since essentially all interesting abelian categories come with a
preadditive structure. In this way, by requiring preadditivity, we allow the
user to pass in the preadditive structure the specific category they are
working with has natively.

## Main definitions

* `abelian` is the type class indicating that a category is abelian. It extends `preadditive`.
* `abelian.image f` is `kernel (cokernel.π f)`, and
* `abelian.coimage f` is `cokernel (kernel.ι f)`.

## Main results

* In an abelian category, mono + epi = iso.
* If `f : X ⟶ Y`, then the map `factor_thru_image f : X ⟶ image f` is an epimorphism, and the map
  `factor_thru_coimage f : coimage f ⟶ Y` is a monomorphism.
* Factoring through the image and coimage is a strong epi-mono factorisation. This means that
  * every abelian category has images. We instantiated this in such a way that `abelian.image f` is
    definitionally equal to `limits.image f`, and
  * there is a canonical isomorphism `coimage_iso_image : coimage f ≅ image f` such that
    `coimage.π f ≫ (coimage_iso_image f).hom ≫ image.ι f = f`. The lemma stating this is called
    `full_image_factorisation`.
* Every epimorphism is a cokernel of its kernel. Every monomorphism is a kernel of its cokernel.
* The pullback of an epimorphism is an epimorphism. The pushout of a monomorphism is a monomorphism.
  (This is not to be confused with the fact that the pullback of a monomorphism is a monomorphism,
  which is true in any category).

## Implementation notes

The typeclass `abelian` does not extend `non_preadditive_abelian`,
to avoid having to deal with comparing the two `has_zero_morphisms` instances
(one from `preadditive` in `abelian`, and the other a field of `non_preadditive_abelian`).
As a consequence, at the beginning of this file we trivially build
a `non_preadditive_abelian` instance from an `abelian` instance,
and use this to restate a number of theorems,
in each case just reusing the proof from `non_preadditive_abelian.lean`.

We don't show this yet, but abelian categories are finitely complete and finitely cocomplete.
However, the limits we can construct at this level of generality will most likely be less nice than
the ones that can be created in specific applications. For this reason, we adopt the following
convention:

* If the statement of a theorem involves limits, the existence of these limits should be made an
  explicit typeclass parameter.
* If a limit only appears in a proof, but not in the statement of a theorem, the limit should not
  be a typeclass parameter, but instead be created using `abelian.has_pullbacks` or a similar
  definition.

## References

* [F. Borceux, *Handbook of Categorical Algebra 2*][borceux-vol2]
* [P. Aluffi, *Algebra: Chaper 0*][aluffi2016]

-/


noncomputable theory

open CategoryTheory

open CategoryTheory.Preadditive

open CategoryTheory.Limits

universe v u

namespace CategoryTheory

variable{C : Type u}[category.{v} C]

variable(C)

/--
A (preadditive) category `C` is called abelian if it has all finite products,
all kernels and cokernels, and if every monomorphism is the kernel of some morphism
and every epimorphism is the cokernel of some morphism.

(This definition implies the existence of zero objects:
finite products give a terminal object, and in a preadditive category
any terminal object is a zero object.)
-/
class abelian extends preadditive C where 
  [HasFiniteProducts : has_finite_products C]
  [HasKernels : has_kernels C]
  [HasCokernels : has_cokernels C]
  NormalMono : ∀ {X Y : C} (f : X ⟶ Y) [mono f], normal_mono f 
  NormalEpi : ∀ {X Y : C} (f : X ⟶ Y) [epi f], normal_epi f

attribute [instance] abelian.has_finite_products

attribute [instance] abelian.has_kernels abelian.has_cokernels

end CategoryTheory

open CategoryTheory

namespace CategoryTheory.Abelian

variable{C : Type u}[category.{v} C][abelian C]

/-- An abelian category has finite biproducts. -/
instance (priority := 100)has_finite_biproducts : has_finite_biproducts C :=
  limits.has_finite_biproducts.of_has_finite_products

instance (priority := 100)has_binary_biproducts : has_binary_biproducts C :=
  limits.has_binary_biproducts_of_finite_biproducts _

instance (priority := 100)has_zero_object : has_zero_object C :=
  has_zero_object_of_has_initial_object

section ToNonPreadditiveAbelian

/-- Every abelian category is, in particular, `non_preadditive_abelian`. -/
def non_preadditive_abelian : non_preadditive_abelian C :=
  { ‹abelian C› with  }

end ToNonPreadditiveAbelian

section Strong

attribute [local instance] abelian.normal_epi

/-- In an abelian category, every epimorphism is strong. -/
theorem strong_epi_of_epi {P Q : C} (f : P ⟶ Q) [epi f] : strong_epi f :=
  by 
    infer_instance

end Strong

section MonoEpiIso

variable{X Y : C}(f : X ⟶ Y)

attribute [local instance] strong_epi_of_epi

/-- In an abelian category, a monomorphism which is also an epimorphism is an isomorphism. -/
theorem is_iso_of_mono_of_epi [mono f] [epi f] : is_iso f :=
  is_iso_of_mono_of_strong_epi _

end MonoEpiIso

section Factor

attribute [local instance] non_preadditive_abelian

variable{P Q : C}(f : P ⟶ Q)

section 

theorem mono_of_zero_kernel (R : C)
  (l :
    is_limit
      (kernel_fork.of_ι (0 : R ⟶ P)
        (show 0 ≫ f = 0 by 
          simp ))) :
  mono f :=
  non_preadditive_abelian.mono_of_zero_kernel _ _ l

theorem mono_of_kernel_ι_eq_zero (h : kernel.ι f = 0) : mono f :=
  mono_of_kernel_zero h

theorem epi_of_zero_cokernel (R : C)
  (l :
    is_colimit
      (cokernel_cofork.of_π (0 : Q ⟶ R)
        (show f ≫ 0 = 0 by 
          simp ))) :
  epi f :=
  non_preadditive_abelian.epi_of_zero_cokernel _ _ l

theorem epi_of_cokernel_π_eq_zero (h : cokernel.π f = 0) : epi f :=
  by 
    apply epi_of_zero_cokernel _ (cokernel f)
    simpRw [←h]
    exact is_colimit.of_iso_colimit (colimit.is_colimit (parallel_pair f 0)) (iso_of_π _)

end 

namespace Images

/-- The kernel of the cokernel of `f` is called the image of `f`. -/
protected abbrev image : C :=
  kernel (cokernel.π f)

/-- The inclusion of the image into the codomain. -/
protected abbrev image.ι : images.image f ⟶ Q :=
  kernel.ι (cokernel.π f)

/-- There is a canonical epimorphism `p : P ⟶ image f` for every `f`. -/
protected abbrev factor_thru_image : P ⟶ images.image f :=
  kernel.lift (cokernel.π f) f$ cokernel.condition f

/-- `f` factors through its image via the canonical morphism `p`. -/
@[simp, reassoc]
protected theorem image.fac : images.factor_thru_image f ≫ image.ι f = f :=
  kernel.lift_ι _ _ _

/-- The map `p : P ⟶ image f` is an epimorphism -/
instance  : epi (images.factor_thru_image f) :=
  show epi (non_preadditive_abelian.factor_thru_image f)by 
    infer_instance

section 

variable{f}

theorem image_ι_comp_eq_zero {R : C} {g : Q ⟶ R} (h : f ≫ g = 0) : images.image.ι f ≫ g = 0 :=
  zero_of_epi_comp (images.factor_thru_image f)$
    by 
      simp [h]

end 

instance mono_factor_thru_image [mono f] : mono (images.factor_thru_image f) :=
  mono_of_mono_fac$ image.fac f

instance is_iso_factor_thru_image [mono f] : is_iso (images.factor_thru_image f) :=
  is_iso_of_mono_of_epi _

/-- Factoring through the image is a strong epi-mono factorisation. -/
@[simps]
def image_strong_epi_mono_factorisation : strong_epi_mono_factorisation f :=
  { i := images.image f, m := image.ι f,
    m_mono :=
      by 
        infer_instance,
    e := images.factor_thru_image f, e_strong_epi := strong_epi_of_epi _ }

end Images

namespace Coimages

/-- The cokernel of the kernel of `f` is called the coimage of `f`. -/
protected abbrev coimage : C :=
  cokernel (kernel.ι f)

/-- The projection onto the coimage. -/
protected abbrev coimage.π : P ⟶ coimages.coimage f :=
  cokernel.π (kernel.ι f)

/-- There is a canonical monomorphism `i : coimage f ⟶ Q`. -/
protected abbrev factor_thru_coimage : coimages.coimage f ⟶ Q :=
  cokernel.desc (kernel.ι f) f$ kernel.condition f

/-- `f` factors through its coimage via the canonical morphism `p`. -/
protected theorem coimage.fac : coimage.π f ≫ coimages.factor_thru_coimage f = f :=
  cokernel.π_desc _ _ _

/-- The canonical morphism `i : coimage f ⟶ Q` is a monomorphism -/
instance  : mono (coimages.factor_thru_coimage f) :=
  show mono (non_preadditive_abelian.factor_thru_coimage f)by 
    infer_instance

section 

variable{f}

theorem comp_coimage_π_eq_zero {R : C} {g : Q ⟶ R} (h : f ≫ g = 0) : f ≫ coimages.coimage.π g = 0 :=
  zero_of_comp_mono (coimages.factor_thru_coimage g)$
    by 
      simp [h]

end 

instance epi_factor_thru_coimage [epi f] : epi (coimages.factor_thru_coimage f) :=
  epi_of_epi_fac$ coimage.fac f

instance is_iso_factor_thru_coimage [epi f] : is_iso (coimages.factor_thru_coimage f) :=
  is_iso_of_mono_of_epi _

/-- Factoring through the coimage is a strong epi-mono factorisation. -/
@[simps]
def coimage_strong_epi_mono_factorisation : strong_epi_mono_factorisation f :=
  { i := coimages.coimage f, m := coimages.factor_thru_coimage f,
    m_mono :=
      by 
        infer_instance,
    e := coimage.π f, e_strong_epi := strong_epi_of_epi _ }

end Coimages

end Factor

section HasStrongEpiMonoFactorisations

/-- An abelian category has strong epi-mono factorisations. -/
instance (priority := 100) : has_strong_epi_mono_factorisations C :=
  has_strong_epi_mono_factorisations.mk$ fun X Y f => images.image_strong_epi_mono_factorisation f

example  : has_images C :=
  by 
    infer_instance

example  : has_image_maps C :=
  by 
    infer_instance

end HasStrongEpiMonoFactorisations

section Images

variable{X Y : C}(f : X ⟶ Y)

/-- There is a canonical isomorphism between the coimage and the image of a morphism. -/
abbrev coimage_iso_image : coimages.coimage f ≅ images.image f :=
  is_image.iso_ext (coimages.coimage_strong_epi_mono_factorisation f).toMonoIsImage
    (images.image_strong_epi_mono_factorisation f).toMonoIsImage

/-- There is a canonical isomorphism between the abelian image and the categorical image of a
    morphism. -/
abbrev image_iso_image : images.image f ≅ image f :=
  is_image.iso_ext (images.image_strong_epi_mono_factorisation f).toMonoIsImage (image.is_image f)

/-- There is a canonical isomorphism between the abelian coimage and the categorical image of a
    morphism. -/
abbrev coimage_iso_image' : coimages.coimage f ≅ image f :=
  is_image.iso_ext (coimages.coimage_strong_epi_mono_factorisation f).toMonoIsImage (image.is_image f)

theorem full_image_factorisation : coimages.coimage.π f ≫ (coimage_iso_image f).Hom ≫ images.image.ι f = f :=
  by 
    rw [limits.is_image.iso_ext_hom, ←images.image_strong_epi_mono_factorisation_to_mono_factorisation_m,
      is_image.lift_fac, coimages.coimage_strong_epi_mono_factorisation_to_mono_factorisation_m, coimages.coimage.fac]

end Images

section CokernelOfKernel

variable{X Y : C}{f : X ⟶ Y}

attribute [local instance] non_preadditive_abelian

/-- In an abelian category, an epi is the cokernel of its kernel. More precisely:
    If `f` is an epimorphism and `s` is some limit kernel cone on `f`, then `f` is a cokernel
    of `fork.ι s`. -/
def epi_is_cokernel_of_kernel [epi f] (s : fork f 0) (h : is_limit s) :
  is_colimit (cokernel_cofork.of_π f (kernel_fork.condition s)) :=
  non_preadditive_abelian.epi_is_cokernel_of_kernel s h

/-- In an abelian category, a mono is the kernel of its cokernel. More precisely:
    If `f` is a monomorphism and `s` is some colimit cokernel cocone on `f`, then `f` is a kernel
    of `cofork.π s`. -/
def mono_is_kernel_of_cokernel [mono f] (s : cofork f 0) (h : is_colimit s) :
  is_limit (kernel_fork.of_ι f (cokernel_cofork.condition s)) :=
  non_preadditive_abelian.mono_is_kernel_of_cokernel s h

end CokernelOfKernel

section 

instance (priority := 100)has_equalizers : has_equalizers C :=
  preadditive.has_equalizers_of_has_kernels

/-- Any abelian category has pullbacks -/
instance (priority := 100)has_pullbacks : has_pullbacks C :=
  has_pullbacks_of_has_binary_products_of_has_equalizers C

end 

section 

instance (priority := 100)has_coequalizers : has_coequalizers C :=
  preadditive.has_coequalizers_of_has_cokernels

/-- Any abelian category has pushouts -/
instance (priority := 100)has_pushouts : has_pushouts C :=
  has_pushouts_of_has_binary_coproducts_of_has_coequalizers C

end 

namespace PullbackToBiproductIsKernel

variable[limits.has_pullbacks C]{X Y Z : C}(f : X ⟶ Z)(g : Y ⟶ Z)

/-! This section contains a slightly technical result about pullbacks and biproducts.
    We will need it in the proof that the pullback of an epimorphism is an epimorpism. -/


/-- The canonical map `pullback f g ⟶ X ⊞ Y` -/
abbrev pullback_to_biproduct : pullback f g ⟶ X ⊞ Y :=
  biprod.lift pullback.fst pullback.snd

/-- The canonical map `pullback f g ⟶ X ⊞ Y` induces a kernel cone on the map
    `biproduct X Y ⟶ Z` induced by `f` and `g`. A slightly more intuitive way to think of
    this may be that it induces an equalizer fork on the maps induced by `(f, 0)` and
    `(0, g)`. -/
abbrev pullback_to_biproduct_fork : kernel_fork (biprod.desc f (-g)) :=
  kernel_fork.of_ι (pullback_to_biproduct f g)$
    by 
      rw [biprod.lift_desc, comp_neg, pullback.condition, add_right_negₓ]

/-- The canonical map `pullback f g ⟶ X ⊞ Y` is a kernel of the map induced by
    `(f, -g)`. -/
def is_limit_pullback_to_biproduct : is_limit (pullback_to_biproduct_fork f g) :=
  fork.is_limit.mk _
    (fun s =>
      pullback.lift (fork.ι s ≫ biprod.fst) (fork.ι s ≫ biprod.snd)$
        sub_eq_zero.1$
          by 
            rw [category.assoc, category.assoc, ←comp_sub, sub_eq_add_neg, ←comp_neg, ←biprod.desc_eq,
              kernel_fork.condition s])
    (fun s =>
      by 
        ext <;> rw [fork.ι_of_ι, category.assoc]
        ·
          rw [biprod.lift_fst, pullback.lift_fst]
        ·
          rw [biprod.lift_snd, pullback.lift_snd])
    fun s m h =>
      by 
        ext <;> simp [fork.ι_eq_app_zero, ←h walking_parallel_pair.zero]

end PullbackToBiproductIsKernel

namespace BiproductToPushoutIsCokernel

variable[limits.has_pushouts C]{W X Y Z : C}(f : X ⟶ Y)(g : X ⟶ Z)

/-- The canonical map `Y ⊞ Z ⟶ pushout f g` -/
abbrev biproduct_to_pushout : Y ⊞ Z ⟶ pushout f g :=
  biprod.desc pushout.inl pushout.inr

/-- The canonical map `Y ⊞ Z ⟶ pushout f g` induces a cokernel cofork on the map
    `X ⟶ Y ⊞ Z` induced by `f` and `-g`. -/
abbrev biproduct_to_pushout_cofork : cokernel_cofork (biprod.lift f (-g)) :=
  cokernel_cofork.of_π (biproduct_to_pushout f g)$
    by 
      rw [biprod.lift_desc, neg_comp, pushout.condition, add_right_negₓ]

/-- The cofork induced by the canonical map `Y ⊞ Z ⟶ pushout f g` is in fact a colimit cokernel
    cofork. -/
def is_colimit_biproduct_to_pushout : is_colimit (biproduct_to_pushout_cofork f g) :=
  cofork.is_colimit.mk _
    (fun s =>
      pushout.desc (biprod.inl ≫ cofork.π s) (biprod.inr ≫ cofork.π s)$
        sub_eq_zero.1$
          by 
            rw [←category.assoc, ←category.assoc, ←sub_comp, sub_eq_add_neg, ←neg_comp, ←biprod.lift_eq,
              cofork.condition s, zero_comp])
    (fun s =>
      by 
        ext <;> simp )
    fun s m h =>
      by 
        ext <;> simp [cofork.π_eq_app_one, ←h walking_parallel_pair.one]

end BiproductToPushoutIsCokernel

section EpiPullback

variable[limits.has_pullbacks C]{W X Y Z : C}(f : X ⟶ Z)(g : Y ⟶ Z)

-- error in CategoryTheory.Abelian.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- In an abelian category, the pullback of an epimorphism is an epimorphism.
    Proof from [aluffi2016, IX.2.3], cf. [borceux-vol2, 1.7.6] -/
instance epi_pullback_of_epi_f [epi f] : epi (pullback.snd : «expr ⟶ »(pullback f g, Y)) :=
«expr $ »(epi_of_cancel_zero _, λ R e h, begin
   let [ident u] [] [":=", expr biprod.desc (0 : «expr ⟶ »(X, R)) e],
   have [ident hu] [":", expr «expr = »(«expr ≫ »(pullback_to_biproduct_is_kernel.pullback_to_biproduct f g, u), 0)] [":=", expr by simpa [] [] [] [] [] []],
   have [] [] [":=", expr epi_is_cokernel_of_kernel _ (pullback_to_biproduct_is_kernel.is_limit_pullback_to_biproduct f g)],
   obtain ["⟨", ident d, ",", ident hd, "⟩", ":=", expr cokernel_cofork.is_colimit.desc' this u hu],
   change [expr «expr ⟶ »(Z, R)] [] ["at", ident d],
   change [expr «expr = »(«expr ≫ »(biprod.desc f «expr- »(g), d), u)] [] ["at", ident hd],
   have [] [":", expr «expr = »(«expr ≫ »(f, d), 0)] [],
   calc
     «expr = »(«expr ≫ »(f, d), «expr ≫ »(«expr ≫ »(biprod.inl, biprod.desc f «expr- »(g)), d)) : by rw [expr biprod.inl_desc] []
     «expr = »(..., «expr ≫ »(biprod.inl, u)) : by rw ["[", expr category.assoc, ",", expr hd, "]"] []
     «expr = »(..., 0) : biprod.inl_desc _ _,
   have [] [":", expr «expr = »(d, 0)] [":=", expr (cancel_epi f).1 (by simpa [] [] [] [] [] [])],
   calc
     «expr = »(e, «expr ≫ »(biprod.inr, u)) : by rw [expr biprod.inr_desc] []
     «expr = »(..., «expr ≫ »(biprod.inr, «expr ≫ »(biprod.desc f «expr- »(g), d))) : by rw ["<-", expr hd] []
     «expr = »(..., «expr ≫ »(biprod.inr, «expr ≫ »(biprod.desc f «expr- »(g), 0))) : by rw [expr this] []
     «expr = »(..., «expr ≫ »(«expr ≫ »(biprod.inr, biprod.desc f «expr- »(g)), 0)) : by rw ["<-", expr category.assoc] []
     «expr = »(..., 0) : has_zero_morphisms.comp_zero _ _
 end)

-- error in CategoryTheory.Abelian.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- In an abelian category, the pullback of an epimorphism is an epimorphism. -/
instance epi_pullback_of_epi_g [epi g] : epi (pullback.fst : «expr ⟶ »(pullback f g, X)) :=
«expr $ »(epi_of_cancel_zero _, λ R e h, begin
   let [ident u] [] [":=", expr biprod.desc e (0 : «expr ⟶ »(Y, R))],
   have [ident hu] [":", expr «expr = »(«expr ≫ »(pullback_to_biproduct_is_kernel.pullback_to_biproduct f g, u), 0)] [":=", expr by simpa [] [] [] [] [] []],
   have [] [] [":=", expr epi_is_cokernel_of_kernel _ (pullback_to_biproduct_is_kernel.is_limit_pullback_to_biproduct f g)],
   obtain ["⟨", ident d, ",", ident hd, "⟩", ":=", expr cokernel_cofork.is_colimit.desc' this u hu],
   change [expr «expr ⟶ »(Z, R)] [] ["at", ident d],
   change [expr «expr = »(«expr ≫ »(biprod.desc f «expr- »(g), d), u)] [] ["at", ident hd],
   have [] [":", expr «expr = »(«expr ≫ »(«expr- »(g), d), 0)] [],
   calc
     «expr = »(«expr ≫ »(«expr- »(g), d), «expr ≫ »(«expr ≫ »(biprod.inr, biprod.desc f «expr- »(g)), d)) : by rw [expr biprod.inr_desc] []
     «expr = »(..., «expr ≫ »(biprod.inr, u)) : by rw ["[", expr category.assoc, ",", expr hd, "]"] []
     «expr = »(..., 0) : biprod.inr_desc _ _,
   have [] [":", expr «expr = »(d, 0)] [":=", expr (cancel_epi «expr- »(g)).1 (by simpa [] [] [] [] [] [])],
   calc
     «expr = »(e, «expr ≫ »(biprod.inl, u)) : by rw [expr biprod.inl_desc] []
     «expr = »(..., «expr ≫ »(biprod.inl, «expr ≫ »(biprod.desc f «expr- »(g), d))) : by rw ["<-", expr hd] []
     «expr = »(..., «expr ≫ »(biprod.inl, «expr ≫ »(biprod.desc f «expr- »(g), 0))) : by rw [expr this] []
     «expr = »(..., «expr ≫ »(«expr ≫ »(biprod.inl, biprod.desc f «expr- »(g)), 0)) : by rw ["<-", expr category.assoc] []
     «expr = »(..., 0) : has_zero_morphisms.comp_zero _ _
 end)

theorem epi_snd_of_is_limit [epi f] {s : pullback_cone f g} (hs : is_limit s) : epi s.snd :=
  by 
    convert epi_of_epi_fac (is_limit.cone_point_unique_up_to_iso_hom_comp (limit.is_limit _) hs _)
    ·
      rfl
    ·
      exact abelian.epi_pullback_of_epi_f _ _

theorem epi_fst_of_is_limit [epi g] {s : pullback_cone f g} (hs : is_limit s) : epi s.fst :=
  by 
    convert epi_of_epi_fac (is_limit.cone_point_unique_up_to_iso_hom_comp (limit.is_limit _) hs _)
    ·
      rfl
    ·
      exact abelian.epi_pullback_of_epi_g _ _

/-- Suppose `f` and `g` are two morphisms with a common codomain and suppose we have written `g` as
    an epimorphism followed by a monomorphism. If `f` factors through the mono part of this
    factorization, then any pullback of `g` along `f` is an epimorphism. -/
theorem epi_fst_of_factor_thru_epi_mono_factorization (g₁ : Y ⟶ W) [epi g₁] (g₂ : W ⟶ Z) [mono g₂] (hg : g₁ ≫ g₂ = g)
  (f' : X ⟶ W) (hf : f' ≫ g₂ = f) (t : pullback_cone f g) (ht : is_limit t) : epi t.fst :=
  by 
    apply epi_fst_of_is_limit _ _ (pullback_cone.is_limit_of_factors f g g₂ f' g₁ hf hg t ht)

end EpiPullback

section MonoPushout

variable[limits.has_pushouts C]{W X Y Z : C}(f : X ⟶ Y)(g : X ⟶ Z)

-- error in CategoryTheory.Abelian.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
instance mono_pushout_of_mono_f [mono f] : mono (pushout.inr : «expr ⟶ »(Z, pushout f g)) :=
«expr $ »(mono_of_cancel_zero _, λ R e h, begin
   let [ident u] [] [":=", expr biprod.lift (0 : «expr ⟶ »(R, Y)) e],
   have [ident hu] [":", expr «expr = »(«expr ≫ »(u, biproduct_to_pushout_is_cokernel.biproduct_to_pushout f g), 0)] [":=", expr by simpa [] [] [] [] [] []],
   have [] [] [":=", expr mono_is_kernel_of_cokernel _ (biproduct_to_pushout_is_cokernel.is_colimit_biproduct_to_pushout f g)],
   obtain ["⟨", ident d, ",", ident hd, "⟩", ":=", expr kernel_fork.is_limit.lift' this u hu],
   change [expr «expr ⟶ »(R, X)] [] ["at", ident d],
   change [expr «expr = »(«expr ≫ »(d, biprod.lift f «expr- »(g)), u)] [] ["at", ident hd],
   have [] [":", expr «expr = »(«expr ≫ »(d, f), 0)] [],
   calc
     «expr = »(«expr ≫ »(d, f), «expr ≫ »(d, «expr ≫ »(biprod.lift f «expr- »(g), biprod.fst))) : by rw [expr biprod.lift_fst] []
     «expr = »(..., «expr ≫ »(u, biprod.fst)) : by rw ["[", "<-", expr category.assoc, ",", expr hd, "]"] []
     «expr = »(..., 0) : biprod.lift_fst _ _,
   have [] [":", expr «expr = »(d, 0)] [":=", expr (cancel_mono f).1 (by simpa [] [] [] [] [] [])],
   calc
     «expr = »(e, «expr ≫ »(u, biprod.snd)) : by rw [expr biprod.lift_snd] []
     «expr = »(..., «expr ≫ »(«expr ≫ »(d, biprod.lift f «expr- »(g)), biprod.snd)) : by rw ["<-", expr hd] []
     «expr = »(..., «expr ≫ »(«expr ≫ »(0, biprod.lift f «expr- »(g)), biprod.snd)) : by rw [expr this] []
     «expr = »(..., «expr ≫ »(0, «expr ≫ »(biprod.lift f «expr- »(g), biprod.snd))) : by rw [expr category.assoc] []
     «expr = »(..., 0) : zero_comp
 end)

-- error in CategoryTheory.Abelian.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
instance mono_pushout_of_mono_g [mono g] : mono (pushout.inl : «expr ⟶ »(Y, pushout f g)) :=
«expr $ »(mono_of_cancel_zero _, λ R e h, begin
   let [ident u] [] [":=", expr biprod.lift e (0 : «expr ⟶ »(R, Z))],
   have [ident hu] [":", expr «expr = »(«expr ≫ »(u, biproduct_to_pushout_is_cokernel.biproduct_to_pushout f g), 0)] [":=", expr by simpa [] [] [] [] [] []],
   have [] [] [":=", expr mono_is_kernel_of_cokernel _ (biproduct_to_pushout_is_cokernel.is_colimit_biproduct_to_pushout f g)],
   obtain ["⟨", ident d, ",", ident hd, "⟩", ":=", expr kernel_fork.is_limit.lift' this u hu],
   change [expr «expr ⟶ »(R, X)] [] ["at", ident d],
   change [expr «expr = »(«expr ≫ »(d, biprod.lift f «expr- »(g)), u)] [] ["at", ident hd],
   have [] [":", expr «expr = »(«expr ≫ »(d, «expr- »(g)), 0)] [],
   calc
     «expr = »(«expr ≫ »(d, «expr- »(g)), «expr ≫ »(d, «expr ≫ »(biprod.lift f «expr- »(g), biprod.snd))) : by rw [expr biprod.lift_snd] []
     «expr = »(..., «expr ≫ »(u, biprod.snd)) : by rw ["[", "<-", expr category.assoc, ",", expr hd, "]"] []
     «expr = »(..., 0) : biprod.lift_snd _ _,
   have [] [":", expr «expr = »(d, 0)] [":=", expr (cancel_mono «expr- »(g)).1 (by simpa [] [] [] [] [] [])],
   calc
     «expr = »(e, «expr ≫ »(u, biprod.fst)) : by rw [expr biprod.lift_fst] []
     «expr = »(..., «expr ≫ »(«expr ≫ »(d, biprod.lift f «expr- »(g)), biprod.fst)) : by rw ["<-", expr hd] []
     «expr = »(..., «expr ≫ »(«expr ≫ »(0, biprod.lift f «expr- »(g)), biprod.fst)) : by rw [expr this] []
     «expr = »(..., «expr ≫ »(0, «expr ≫ »(biprod.lift f «expr- »(g), biprod.fst))) : by rw [expr category.assoc] []
     «expr = »(..., 0) : zero_comp
 end)

theorem mono_inr_of_is_colimit [mono f] {s : pushout_cocone f g} (hs : is_colimit s) : mono s.inr :=
  by 
    convert mono_of_mono_fac (is_colimit.comp_cocone_point_unique_up_to_iso_hom hs (colimit.is_colimit _) _)
    ·
      rfl
    ·
      exact abelian.mono_pushout_of_mono_f _ _

theorem mono_inl_of_is_colimit [mono g] {s : pushout_cocone f g} (hs : is_colimit s) : mono s.inl :=
  by 
    convert mono_of_mono_fac (is_colimit.comp_cocone_point_unique_up_to_iso_hom hs (colimit.is_colimit _) _)
    ·
      rfl
    ·
      exact abelian.mono_pushout_of_mono_g _ _

/-- Suppose `f` and `g` are two morphisms with a common domain and suppose we have written `g` as
    an epimorphism followed by a monomorphism. If `f` factors through the epi part of this
    factorization, then any pushout of `g` along `f` is a monomorphism. -/
theorem mono_inl_of_factor_thru_epi_mono_factorization (f : X ⟶ Y) (g : X ⟶ Z) (g₁ : X ⟶ W) [epi g₁] (g₂ : W ⟶ Z)
  [mono g₂] (hg : g₁ ≫ g₂ = g) (f' : W ⟶ Y) (hf : g₁ ≫ f' = f) (t : pushout_cocone f g) (ht : is_colimit t) :
  mono t.inl :=
  by 
    apply mono_inl_of_is_colimit _ _ (pushout_cocone.is_colimit_of_factors _ _ _ _ _ hf hg t ht)

end MonoPushout

end CategoryTheory.Abelian

namespace CategoryTheory.NonPreadditiveAbelian

variable(C : Type u)[category.{v} C][non_preadditive_abelian C]

/-- Every non_preadditive_abelian category can be promoted to an abelian category. -/
def abelian : abelian C :=
  { non_preadditive_abelian.preadditive with
    HasFiniteProducts :=
      by 
        infer_instance,
    HasKernels :=
      by 
        convert
          (by 
            infer_instance :
          limits.has_kernels C),
    HasCokernels :=
      by 
        convert
          (by 
            infer_instance :
          limits.has_cokernels C),
    NormalMono :=
      by 
        intros 
        convert normal_mono f,
    NormalEpi :=
      by 
        intros 
        convert normal_epi f }

end CategoryTheory.NonPreadditiveAbelian

