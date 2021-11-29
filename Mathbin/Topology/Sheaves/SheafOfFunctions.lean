import Mathbin.CategoryTheory.Limits.Shapes.Types 
import Mathbin.Topology.Sheaves.PresheafOfFunctions 
import Mathbin.Topology.Sheaves.SheafCondition.UniqueGluing

/-!
# Sheaf conditions for presheaves of (continuous) functions.

We show that
* `Top.presheaf.to_Type_is_sheaf`: not-necessarily-continuous functions into a type form a sheaf
* `Top.presheaf.to_Types_is_sheaf`: in fact, these may be dependent functions into a type family

For
* `Top.sheaf_to_Top`: continuous functions into a topological space form a sheaf
please see `topology/sheaves/local_predicate.lean`, where we set up a general framework
for constructing sub(pre)sheaves of the sheaf of dependent functions.

## Future work
Obviously there's more to do:
* sections of a fiber bundle
* various classes of smooth and structure preserving functions
* functions into spaces with algebraic structure, which the sections inherit
-/


open CategoryTheory

open CategoryTheory.Limits

open TopologicalSpace

open TopologicalSpace.Opens

universe u

noncomputable theory

variable(X : Top.{u})

open Top

namespace Top.Presheaf

-- error in Topology.Sheaves.SheafOfFunctions: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/--
We show that the presheaf of functions to a type `T`
(no continuity assumptions, just plain functions)
form a sheaf.

In fact, the proof is identical when we do this for dependent functions to a type family `T`,
so we do the more general case.
-/ theorem to_Types_is_sheaf (T : X → Type u) : (presheaf_to_Types X T).is_sheaf :=
«expr $ »(is_sheaf_of_is_sheaf_unique_gluing_types _, λ ι U sf hsf, begin
   choose [] [ident index] [ident index_spec] ["using", expr λ x : supr U, opens.mem_supr.mp x.2],
   let [ident s] [":", expr ∀ x : supr U, T x] [":=", expr λ x, sf (index x) ⟨x.1, index_spec x⟩],
   refine [expr ⟨s, _, _⟩],
   { intro [ident i],
     ext [] [ident x] [],
     convert [] [expr congr_fun (hsf (index ⟨x, _⟩) i) ⟨x, ⟨index_spec ⟨x.1, _⟩, x.2⟩⟩] [],
     ext [] [] [],
     refl },
   { intros [ident t, ident ht],
     ext [] [ident x] [],
     convert [] [expr congr_fun (ht (index x)) ⟨x.1, index_spec x⟩] [],
     ext [] [] [],
     refl }
 end)

/--
The presheaf of not-necessarily-continuous functions to
a target type `T` satsifies the sheaf condition.
-/
theorem to_Type_is_sheaf (T : Type u) : (presheaf_to_Type X T).IsSheaf :=
  to_Types_is_sheaf X fun _ => T

end Top.Presheaf

namespace Top

/--
The sheaf of not-necessarily-continuous functions on `X` with values in type family
`T : X → Type u`.
-/
def sheaf_to_Types (T : X → Type u) : sheaf (Type u) X :=
  ⟨presheaf_to_Types X T, presheaf.to_Types_is_sheaf _ _⟩

/--
The sheaf of not-necessarily-continuous functions on `X` with values in a type `T`.
-/
def sheaf_to_Type (T : Type u) : sheaf (Type u) X :=
  ⟨presheaf_to_Type X T, presheaf.to_Type_is_sheaf _ _⟩

end Top

