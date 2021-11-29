import Mathbin.GroupTheory.Submonoid.Operations 
import Mathbin.Data.Equiv.MulAdd 
import Mathbin.Data.Setoid.Basic 
import Mathbin.Algebra.Group.Prod

/-!
# Congruence relations

This file defines congruence relations: equivalence relations that preserve a binary operation,
which in this case is multiplication or addition. The principal definition is a `structure`
extending a `setoid` (an equivalence relation), and the inductive definition of the smallest
congruence relation containing a binary relation is also given (see `con_gen`).

The file also proves basic properties of the quotient of a type by a congruence relation, and the
complete lattice of congruence relations on a type. We then establish an order-preserving bijection
between the set of congruence relations containing a congruence relation `c` and the set of
congruence relations on the quotient by `c`.

The second half of the file concerns congruence relations on monoids, in which case the
quotient by the congruence relation is also a monoid. There are results about the universal
property of quotients of monoids, and the isomorphism theorems for monoids.

## Implementation notes

The inductive definition of a congruence relation could be a nested inductive type, defined using
the equivalence closure of a binary relation `eqv_gen`, but the recursor generated does not work.
A nested inductive definition could conceivably shorten proofs, because they would allow invocation
of the corresponding lemmas about `eqv_gen`.

The lemmas `refl`, `symm` and `trans` are not tagged with `@[refl]`, `@[symm]`, and `@[trans]`
respectively as these tags do not work on a structure coerced to a binary relation.

There is a coercion from elements of a type to the element's equivalence class under a
congruence relation.

A congruence relation on a monoid `M` can be thought of as a submonoid of `M × M` for which
membership is an equivalence relation, but whilst this fact is established in the file, it is not
used, since this perspective adds more layers of definitional unfolding.

## Tags

congruence, congruence relation, quotient, quotient by congruence relation, monoid,
quotient monoid, isomorphism theorems
-/


variable(M : Type _){N : Type _}{P : Type _}

open Function Setoidₓ

/-- A congruence relation on a type with an addition is an equivalence relation which
    preserves addition. -/
structure AddCon[Add M] extends Setoidₓ M where 
  add' : ∀ {w x y z}, r w x → r y z → r (w+y) (x+z)

/-- A congruence relation on a type with a multiplication is an equivalence relation which
    preserves multiplication. -/
@[toAdditive AddCon]
structure Con[Mul M] extends Setoidₓ M where 
  mul' : ∀ {w x y z}, r w x → r y z → r (w*y) (x*z)

/-- The equivalence relation underlying an additive congruence relation. -/
add_decl_doc AddCon.toSetoid

/-- The equivalence relation underlying a multiplicative congruence relation. -/
add_decl_doc Con.toSetoid

variable{M}

/-- The inductively defined smallest additive congruence relation containing a given binary
    relation. -/
inductive AddConGen.Rel [Add M] (r : M → M → Prop) : M → M → Prop
  | of : ∀ x y, r x y → AddConGen.Rel x y
  | refl : ∀ x, AddConGen.Rel x x
  | symm : ∀ x y, AddConGen.Rel x y → AddConGen.Rel y x
  | trans : ∀ x y z, AddConGen.Rel x y → AddConGen.Rel y z → AddConGen.Rel x z
  | add : ∀ w x y z, AddConGen.Rel w x → AddConGen.Rel y z → AddConGen.Rel (w+y) (x+z)

/-- The inductively defined smallest multiplicative congruence relation containing a given binary
    relation. -/
@[toAdditive AddConGen.Rel]
inductive ConGen.Rel [Mul M] (r : M → M → Prop) : M → M → Prop
  | of : ∀ x y, r x y → ConGen.Rel x y
  | refl : ∀ x, ConGen.Rel x x
  | symm : ∀ x y, ConGen.Rel x y → ConGen.Rel y x
  | trans : ∀ x y z, ConGen.Rel x y → ConGen.Rel y z → ConGen.Rel x z
  | mul : ∀ w x y z, ConGen.Rel w x → ConGen.Rel y z → ConGen.Rel (w*y) (x*z)

/-- The inductively defined smallest multiplicative congruence relation containing a given binary
    relation. -/
@[toAdditive addConGen
      "The inductively defined smallest additive congruence relation containing\na given binary relation."]
def conGen [Mul M] (r : M → M → Prop) : Con M :=
  ⟨⟨ConGen.Rel r, ⟨ConGen.Rel.refl, ConGen.Rel.symm, ConGen.Rel.trans⟩⟩, ConGen.Rel.mul⟩

namespace Con

section 

variable[Mul M][Mul N][Mul P](c : Con M)

@[toAdditive]
instance  : Inhabited (Con M) :=
  ⟨conGen EmptyRelation⟩

/-- A coercion from a congruence relation to its underlying binary relation. -/
@[toAdditive "A coercion from an additive congruence relation to its underlying binary relation."]
instance  : CoeFun (Con M) fun _ => M → M → Prop :=
  ⟨fun c => fun x y => @Setoidₓ.R _ c.to_setoid x y⟩

@[simp, toAdditive]
theorem rel_eq_coe (c : Con M) : c.r = c :=
  rfl

/-- Congruence relations are reflexive. -/
@[toAdditive "Additive congruence relations are reflexive."]
protected theorem refl x : c x x :=
  c.to_setoid.refl' x

/-- Congruence relations are symmetric. -/
@[toAdditive "Additive congruence relations are symmetric."]
protected theorem symm : ∀ {x y}, c x y → c y x :=
  fun _ _ h => c.to_setoid.symm' h

/-- Congruence relations are transitive. -/
@[toAdditive "Additive congruence relations are transitive."]
protected theorem trans : ∀ {x y z}, c x y → c y z → c x z :=
  fun _ _ _ h => c.to_setoid.trans' h

/-- Multiplicative congruence relations preserve multiplication. -/
@[toAdditive "Additive congruence relations preserve addition."]
protected theorem mul : ∀ {w x y z}, c w x → c y z → c (w*y) (x*z) :=
  fun _ _ _ _ h1 h2 => c.mul' h1 h2

@[simp, toAdditive]
theorem rel_mk {s : Setoidₓ M} {h a b} : Con.mk s h a b ↔ r a b :=
  Iff.rfl

/-- Given a type `M` with a multiplication, a congruence relation `c` on `M`, and elements of `M`
    `x, y`, `(x, y) ∈ M × M` iff `x` is related to `y` by `c`. -/
@[toAdditive
      "Given a type `M` with an addition, `x, y ∈ M`, and an additive congruence relation\n`c` on `M`, `(x, y) ∈ M × M` iff `x` is related to `y` by `c`."]
instance  : HasMem (M × M) (Con M) :=
  ⟨fun x c => c x.1 x.2⟩

variable{c}

/-- The map sending a congruence relation to its underlying binary relation is injective. -/
@[toAdditive "The map sending an additive congruence relation to its underlying binary relation\nis injective."]
theorem ext' {c d : Con M} (H : c.r = d.r) : c = d :=
  by 
    rcases c with ⟨⟨⟩⟩
    rcases d with ⟨⟨⟩⟩
    cases H 
    congr

/-- Extensionality rule for congruence relations. -/
@[ext, toAdditive "Extensionality rule for additive congruence relations."]
theorem ext {c d : Con M} (H : ∀ x y, c x y ↔ d x y) : c = d :=
  ext'$
    by 
      ext <;> apply H

/-- The map sending a congruence relation to its underlying equivalence relation is injective. -/
@[toAdditive "The map sending an additive congruence relation to its underlying equivalence\nrelation is injective."]
theorem to_setoid_inj {c d : Con M} (H : c.to_setoid = d.to_setoid) : c = d :=
  ext$ ext_iff.1 H

/-- Iff version of extensionality rule for congruence relations. -/
@[toAdditive "Iff version of extensionality rule for additive congruence relations."]
theorem ext_iff {c d : Con M} : (∀ x y, c x y ↔ d x y) ↔ c = d :=
  ⟨ext, fun h _ _ => h ▸ Iff.rfl⟩

/-- Two congruence relations are equal iff their underlying binary relations are equal. -/
@[toAdditive "Two additive congruence relations are equal iff their underlying binary relations\nare equal."]
theorem ext'_iff {c d : Con M} : c.r = d.r ↔ c = d :=
  ⟨ext', fun h => h ▸ rfl⟩

/-- The kernel of a multiplication-preserving function as a congruence relation. -/
@[toAdditive "The kernel of an addition-preserving function as an additive congruence relation."]
def mul_ker (f : M → P) (h : ∀ x y, f (x*y) = f x*f y) : Con M :=
  { toSetoid := Setoidₓ.ker f,
    mul' :=
      fun _ _ _ _ h1 h2 =>
        by 
          dsimp [Setoidₓ.ker, on_fun]  at *
          rw [h, h1, h2, h] }

/-- Given types with multiplications `M, N`, the product of two congruence relations `c` on `M` and
    `d` on `N`: `(x₁, x₂), (y₁, y₂) ∈ M × N` are related by `c.prod d` iff `x₁` is related to `y₁`
    by `c` and `x₂` is related to `y₂` by `d`. -/
@[toAdditive Prod
      "Given types with additions `M, N`, the product of two congruence relations\n`c` on `M` and `d` on `N`: `(x₁, x₂), (y₁, y₂) ∈ M × N` are related by `c.prod d` iff `x₁`\nis related to `y₁` by `c` and `x₂` is related to `y₂` by `d`."]
protected def Prod (c : Con M) (d : Con N) : Con (M × N) :=
  { c.to_setoid.prod d.to_setoid with mul' := fun _ _ _ _ h1 h2 => ⟨c.mul h1.1 h2.1, d.mul h1.2 h2.2⟩ }

/-- The product of an indexed collection of congruence relations. -/
@[toAdditive "The product of an indexed collection of additive congruence relations."]
def pi {ι : Type _} {f : ι → Type _} [∀ i, Mul (f i)] (C : ∀ i, Con (f i)) : Con (∀ i, f i) :=
  { @piSetoid _ _$ fun i => (C i).toSetoid with mul' := fun _ _ _ _ h1 h2 i => (C i).mul (h1 i) (h2 i) }

variable(c)

/-- Defining the quotient by a congruence relation of a type with a multiplication. -/
@[toAdditive "Defining the quotient by an additive congruence relation of a type with\nan addition."]
protected def Quotientₓ :=
  Quotientₓ$ c.to_setoid

/-- Coercion from a type with a multiplication to its quotient by a congruence relation.

See Note [use has_coe_t]. -/
@[toAdditive "Coercion from a type with an addition to its quotient by an additive congruence\nrelation"]
instance (priority := 0) : CoeTₓ M c.quotient :=
  ⟨@Quotientₓ.mk _ c.to_setoid⟩

/-- The quotient by a decidable congruence relation has decidable equality. -/
@[toAdditive "The quotient by a decidable additive congruence relation has decidable equality."]
instance (priority := 500) [d : ∀ a b, Decidable (c a b)] : DecidableEq c.quotient :=
  @Quotientₓ.decidableEq M c.to_setoid d

@[simp, toAdditive]
theorem quot_mk_eq_coe {M : Type _} [Mul M] (c : Con M) (x : M) : Quot.mk c x = (x : c.quotient) :=
  rfl

/-- The function on the quotient by a congruence relation `c` induced by a function that is
    constant on `c`'s equivalence classes. -/
@[elab_as_eliminator,
  toAdditive
      "The function on the quotient by a congruence relation `c`\ninduced by a function that is constant on `c`'s equivalence classes."]
protected def lift_on {β} {c : Con M} (q : c.quotient) (f : M → β) (h : ∀ a b, c a b → f a = f b) : β :=
  Quotientₓ.liftOn' q f h

/-- The binary function on the quotient by a congruence relation `c` induced by a binary function
    that is constant on `c`'s equivalence classes. -/
@[elab_as_eliminator,
  toAdditive
      "The binary function on the quotient by a congruence relation `c`\ninduced by a binary function that is constant on `c`'s equivalence classes."]
protected def lift_on₂ {β} {c : Con M} (q r : c.quotient) (f : M → M → β)
  (h : ∀ a₁ a₂ b₁ b₂, c a₁ b₁ → c a₂ b₂ → f a₁ a₂ = f b₁ b₂) : β :=
  Quotientₓ.liftOn₂' q r f h

/-- A version of `quotient.hrec_on₂'` for quotients by `con`. -/
@[toAdditive "A version of `quotient.hrec_on₂'` for quotients by `add_con`."]
protected def hrec_on₂ {cM : Con M} {cN : Con N} {φ : cM.quotient → cN.quotient → Sort _} (a : cM.quotient)
  (b : cN.quotient) (f : ∀ (x : M) (y : N), φ x y) (h : ∀ x y x' y', cM x x' → cN y y' → HEq (f x y) (f x' y')) :
  φ a b :=
  Quotientₓ.hrecOn₂' a b f h

@[simp, toAdditive]
theorem hrec_on₂_coe {cM : Con M} {cN : Con N} {φ : cM.quotient → cN.quotient → Sort _} (a : M) (b : N)
  (f : ∀ (x : M) (y : N), φ x y) (h : ∀ x y x' y', cM x x' → cN y y' → HEq (f x y) (f x' y')) :
  Con.hrecOn₂ («expr↑ » a) («expr↑ » b) f h = f a b :=
  rfl

variable{c}

/-- The inductive principle used to prove propositions about the elements of a quotient by a
    congruence relation. -/
@[elab_as_eliminator,
  toAdditive
      "The inductive principle used to prove propositions about\nthe elements of a quotient by an additive congruence relation."]
protected theorem induction_on {C : c.quotient → Prop} (q : c.quotient) (H : ∀ (x : M), C x) : C q :=
  Quotientₓ.induction_on' q H

/-- A version of `con.induction_on` for predicates which take two arguments. -/
@[elab_as_eliminator, toAdditive "A version of `add_con.induction_on` for predicates which take\ntwo arguments."]
protected theorem induction_on₂ {d : Con N} {C : c.quotient → d.quotient → Prop} (p : c.quotient) (q : d.quotient)
  (H : ∀ (x : M) (y : N), C x y) : C p q :=
  Quotientₓ.induction_on₂' p q H

variable(c)

/-- Two elements are related by a congruence relation `c` iff they are represented by the same
    element of the quotient by `c`. -/
@[simp,
  toAdditive
      "Two elements are related by an additive congruence relation `c` iff they\nare represented by the same element of the quotient by `c`."]
protected theorem Eq {a b : M} : (a : c.quotient) = b ↔ c a b :=
  Quotientₓ.eq'

/-- The multiplication induced on the quotient by a congruence relation on a type with a
    multiplication. -/
@[toAdditive "The addition induced on the quotient by an additive congruence relation on a type\nwith an addition."]
instance Mul : Mul c.quotient :=
  ⟨fun x y => (Quotientₓ.liftOn₂' x y fun w z => ((w*z : M) : c.quotient))$ fun _ _ _ _ h1 h2 => c.eq.2$ c.mul h1 h2⟩

/-- The kernel of the quotient map induced by a congruence relation `c` equals `c`. -/
@[simp, toAdditive "The kernel of the quotient map induced by an additive congruence relation\n`c` equals `c`."]
theorem mul_ker_mk_eq : (mul_ker (coeₓ : M → c.quotient) fun x y => rfl) = c :=
  ext$ fun x y => Quotientₓ.eq'

variable{c}

/-- The coercion to the quotient of a congruence relation commutes with multiplication (by
    definition). -/
@[simp,
  toAdditive "The coercion to the quotient of an additive congruence relation commutes with\naddition (by definition)."]
theorem coe_mul (x y : M) : («expr↑ » (x*y) : c.quotient) = «expr↑ » x*«expr↑ » y :=
  rfl

/-- Definition of the function on the quotient by a congruence relation `c` induced by a function
    that is constant on `c`'s equivalence classes. -/
@[simp,
  toAdditive
      "Definition of the function on the quotient by an additive congruence\nrelation `c` induced by a function that is constant on `c`'s equivalence classes."]
protected theorem lift_on_coe {β} (c : Con M) (f : M → β) (h : ∀ a b, c a b → f a = f b) (x : M) :
  Con.liftOn (x : c.quotient) f h = f x :=
  rfl

/-- Makes an isomorphism of quotients by two congruence relations, given that the relations are
    equal. -/
@[toAdditive
      "Makes an additive isomorphism of quotients by two additive congruence relations,\ngiven that the relations are equal."]
protected def congr {c d : Con M} (h : c = d) : c.quotient ≃* d.quotient :=
  { Quotientₓ.congr (Equiv.refl M)$
      by 
        apply ext_iff.2 h with
    map_mul' :=
      fun x y =>
        by 
          rcases x with ⟨⟩ <;> rcases y with ⟨⟩ <;> rfl }

/-- For congruence relations `c, d` on a type `M` with a multiplication, `c ≤ d` iff `∀ x y ∈ M`,
    `x` is related to `y` by `d` if `x` is related to `y` by `c`. -/
@[toAdditive
      "For additive congruence relations `c, d` on a type `M` with an addition, `c ≤ d` iff\n`∀ x y ∈ M`, `x` is related to `y` by `d` if `x` is related to `y` by `c`."]
instance  : LE (Con M) :=
  ⟨fun c d => ∀ ⦃x y⦄, c x y → d x y⟩

/-- Definition of `≤` for congruence relations. -/
@[toAdditive "Definition of `≤` for additive congruence relations."]
theorem le_def {c d : Con M} : c ≤ d ↔ ∀ {x y}, c x y → d x y :=
  Iff.rfl

/-- The infimum of a set of congruence relations on a given type with a multiplication. -/
@[toAdditive "The infimum of a set of additive congruence relations on a given type with\nan addition."]
instance  : HasInfₓ (Con M) :=
  ⟨fun S =>
      ⟨⟨fun x y => ∀ (c : Con M), c ∈ S → c x y,
          ⟨fun x c hc => c.refl x, fun _ _ h c hc => c.symm$ h c hc,
            fun _ _ _ h1 h2 c hc => c.trans (h1 c hc)$ h2 c hc⟩⟩,
        fun _ _ _ _ h1 h2 c hc => c.mul (h1 c hc)$ h2 c hc⟩⟩

/-- The infimum of a set of congruence relations is the same as the infimum of the set's image
    under the map to the underlying equivalence relation. -/
@[toAdditive
      "The infimum of a set of additive congruence relations is the same as the infimum of\nthe set's image under the map to the underlying equivalence relation."]
theorem Inf_to_setoid (S : Set (Con M)) : (Inf S).toSetoid = Inf (to_setoid '' S) :=
  Setoidₓ.ext'$
    fun x y =>
      ⟨fun h r ⟨c, hS, hr⟩ =>
          by 
            rw [←hr] <;> exact h c hS,
        fun h c hS => h c.to_setoid ⟨c, hS, rfl⟩⟩

/-- The infimum of a set of congruence relations is the same as the infimum of the set's image
    under the map to the underlying binary relation. -/
@[toAdditive
      "The infimum of a set of additive congruence relations is the same as the infimum\nof the set's image under the map to the underlying binary relation."]
theorem Inf_def (S : Set (Con M)) : «expr⇑ » (Inf S) = Inf (@Set.Image (Con M) (M → M → Prop) coeFn S) :=
  by 
    ext 
    simp only [Inf_image, infi_apply, infi_Prop_eq]
    rfl

@[toAdditive]
instance  : PartialOrderₓ (Con M) :=
  { le := · ≤ ·, lt := fun c d => c ≤ d ∧ ¬d ≤ c, le_refl := fun c _ _ => id,
    le_trans := fun c1 c2 c3 h1 h2 x y h => h2$ h1 h, lt_iff_le_not_le := fun _ _ => Iff.rfl,
    le_antisymm := fun c d hc hd => ext$ fun x y => ⟨fun h => hc h, fun h => hd h⟩ }

/-- The complete lattice of congruence relations on a given type with a multiplication. -/
@[toAdditive "The complete lattice of additive congruence relations on a given type with\nan addition."]
instance  : CompleteLattice (Con M) :=
  { completeLatticeOfInf (Con M)$
      fun s => ⟨fun r hr x y h => (h : ∀ r (_ : r ∈ s), (r : Con M) x y) r hr, fun r hr x y h r' hr' => hr hr' h⟩ with
    inf := fun c d => ⟨c.to_setoid⊓d.to_setoid, fun _ _ _ _ h1 h2 => ⟨c.mul h1.1 h2.1, d.mul h1.2 h2.2⟩⟩,
    inf_le_left := fun _ _ _ _ h => h.1, inf_le_right := fun _ _ _ _ h => h.2,
    le_inf := fun _ _ _ hb hc _ _ h => ⟨hb h, hc h⟩,
    top :=
      { Setoidₓ.completeLattice.top with
        mul' :=
          by 
            tauto },
    le_top := fun _ _ _ h => trivialₓ,
    bot := { Setoidₓ.completeLattice.bot with mul' := fun _ _ _ _ h1 h2 => h1 ▸ h2 ▸ rfl },
    bot_le := fun c x y h => h ▸ c.refl x }

/-- The infimum of two congruence relations equals the infimum of the underlying binary
    operations. -/
@[toAdditive
      "The infimum of two additive congruence relations equals the infimum of the\nunderlying binary operations."]
theorem inf_def {c d : Con M} : (c⊓d).R = c.r⊓d.r :=
  rfl

/-- Definition of the infimum of two congruence relations. -/
@[toAdditive "Definition of the infimum of two additive congruence relations."]
theorem inf_iff_and {c d : Con M} {x y} : (c⊓d) x y ↔ c x y ∧ d x y :=
  Iff.rfl

/-- The inductively defined smallest congruence relation containing a binary relation `r` equals
    the infimum of the set of congruence relations containing `r`. -/
@[toAdditive add_con_gen_eq
      "The inductively defined smallest additive congruence relation\ncontaining a binary relation `r` equals the infimum of the set of additive congruence relations\ncontaining `r`."]
theorem con_gen_eq (r : M → M → Prop) : conGen r = Inf { s:Con M | ∀ x y, r x y → s x y } :=
  le_antisymmₓ
    (fun x y H =>
      (ConGen.Rel.rec_on H (fun _ _ h _ hs => hs _ _ h) (Con.refl _) (fun _ _ _ => Con.symm _)
          fun _ _ _ _ _ => Con.trans _)$
        fun w x y z _ _ h1 h2 c hc => c.mul (h1 c hc)$ h2 c hc)
    (Inf_le fun _ _ => ConGen.Rel.of _ _)

/-- The smallest congruence relation containing a binary relation `r` is contained in any
    congruence relation containing `r`. -/
@[toAdditive add_con_gen_le
      "The smallest additive congruence relation containing a binary\nrelation `r` is contained in any additive congruence relation containing `r`."]
theorem con_gen_le {r : M → M → Prop} {c : Con M} (h : ∀ x y, r x y → @Setoidₓ.R _ c.to_setoid x y) : conGen r ≤ c :=
  by 
    rw [con_gen_eq] <;> exact Inf_le h

/-- Given binary relations `r, s` with `r` contained in `s`, the smallest congruence relation
    containing `s` contains the smallest congruence relation containing `r`. -/
@[toAdditive add_con_gen_mono
      "Given binary relations `r, s` with `r` contained in `s`, the\nsmallest additive congruence relation containing `s` contains the smallest additive congruence\nrelation containing `r`."]
theorem con_gen_mono {r s : M → M → Prop} (h : ∀ x y, r x y → s x y) : conGen r ≤ conGen s :=
  con_gen_le$ fun x y hr => ConGen.Rel.of _ _$ h x y hr

/-- Congruence relations equal the smallest congruence relation in which they are contained. -/
@[simp,
  toAdditive add_con_gen_of_add_con
      "Additive congruence relations equal the smallest\nadditive congruence relation in which they are contained."]
theorem con_gen_of_con (c : Con M) : conGen c = c :=
  le_antisymmₓ
    (by 
      rw [con_gen_eq] <;> exact Inf_le fun _ _ => id)
    ConGen.Rel.of

/-- The map sending a binary relation to the smallest congruence relation in which it is
    contained is idempotent. -/
@[simp,
  toAdditive add_con_gen_idem
      "The map sending a binary relation to the smallest additive\ncongruence relation in which it is contained is idempotent."]
theorem con_gen_idem (r : M → M → Prop) : conGen (conGen r) = conGen r :=
  con_gen_of_con _

/-- The supremum of congruence relations `c, d` equals the smallest congruence relation containing
    the binary relation '`x` is related to `y` by `c` or `d`'. -/
@[toAdditive sup_eq_add_con_gen
      "The supremum of additive congruence relations `c, d` equals the\nsmallest additive congruence relation containing the binary relation '`x` is related to `y`\nby `c` or `d`'."]
theorem sup_eq_con_gen (c d : Con M) : c⊔d = conGen fun x y => c x y ∨ d x y :=
  by 
    rw [con_gen_eq]
    apply congr_argₓ Inf 
    simp only [le_def, or_imp_distrib, ←forall_and_distrib]

/-- The supremum of two congruence relations equals the smallest congruence relation containing
    the supremum of the underlying binary operations. -/
@[toAdditive
      "The supremum of two additive congruence relations equals the smallest additive\ncongruence relation containing the supremum of the underlying binary operations."]
theorem sup_def {c d : Con M} : c⊔d = conGen (c.r⊔d.r) :=
  by 
    rw [sup_eq_con_gen] <;> rfl

/-- The supremum of a set of congruence relations `S` equals the smallest congruence relation
    containing the binary relation 'there exists `c ∈ S` such that `x` is related to `y` by
    `c`'. -/
@[toAdditive Sup_eq_add_con_gen
      "The supremum of a set of additive congruence relations `S` equals\nthe smallest additive congruence relation containing the binary relation 'there exists `c ∈ S`\nsuch that `x` is related to `y` by `c`'."]
theorem Sup_eq_con_gen (S : Set (Con M)) : Sup S = conGen fun x y => ∃ c : Con M, c ∈ S ∧ c x y :=
  by 
    rw [con_gen_eq]
    apply congr_argₓ Inf 
    ext 
    exact ⟨fun h _ _ ⟨r, hr⟩ => h hr.1 hr.2, fun h r hS _ _ hr => h _ _ ⟨r, hS, hr⟩⟩

/-- The supremum of a set of congruence relations is the same as the smallest congruence relation
    containing the supremum of the set's image under the map to the underlying binary relation. -/
@[toAdditive
      "The supremum of a set of additive congruence relations is the same as the smallest\nadditive congruence relation containing the supremum of the set's image under the map to the\nunderlying binary relation."]
theorem Sup_def {S : Set (Con M)} : Sup S = conGen (Sup (@Set.Image (Con M) (M → M → Prop) coeFn S)) :=
  by 
    rw [Sup_eq_con_gen, Sup_image]
    congr with x y 
    simp only [Sup_image, supr_apply, supr_Prop_eq, exists_prop, rel_eq_coe]

variable(M)

/-- There is a Galois insertion of congruence relations on a type with a multiplication `M` into
    binary relations on `M`. -/
@[toAdditive
      "There is a Galois insertion of additive congruence relations on a type with\nan addition `M` into binary relations on `M`."]
protected noncomputable def gi : @GaloisInsertion (M → M → Prop) (Con M) _ _ conGen coeFn :=
  { choice := fun r h => conGen r,
    gc := fun r c => ⟨fun H _ _ h => H$ ConGen.Rel.of _ _ h, fun H => con_gen_of_con c ▸ con_gen_mono H⟩,
    le_l_u := fun x => (con_gen_of_con x).symm ▸ le_reflₓ x, choice_eq := fun _ _ => rfl }

variable{M}(c)

/-- Given a function `f`, the smallest congruence relation containing the binary relation on `f`'s
    image defined by '`x ≈ y` iff the elements of `f⁻¹(x)` are related to the elements of `f⁻¹(y)`
    by a congruence relation `c`.' -/
@[toAdditive
      "Given a function `f`, the smallest additive congruence relation containing the\nbinary relation on `f`'s image defined by '`x ≈ y` iff the elements of `f⁻¹(x)` are related to the\nelements of `f⁻¹(y)` by an additive congruence relation `c`.'"]
def map_gen (f : M → N) : Con N :=
  conGen$ fun x y => ∃ a b, f a = x ∧ f b = y ∧ c a b

/-- Given a surjective multiplicative-preserving function `f` whose kernel is contained in a
    congruence relation `c`, the congruence relation on `f`'s codomain defined by '`x ≈ y` iff the
    elements of `f⁻¹(x)` are related to the elements of `f⁻¹(y)` by `c`.' -/
@[toAdditive
      "Given a surjective addition-preserving function `f` whose kernel is contained in\nan additive congruence relation `c`, the additive congruence relation on `f`'s codomain defined\nby '`x ≈ y` iff the elements of `f⁻¹(x)` are related to the elements of `f⁻¹(y)` by `c`.'"]
def map_of_surjective (f : M → N) (H : ∀ x y, f (x*y) = f x*f y) (h : mul_ker f H ≤ c) (hf : surjective f) : Con N :=
  { c.to_setoid.map_of_surjective f h hf with
    mul' :=
      fun w x y z ⟨a, b, hw, hx, h1⟩ ⟨p, q, hy, hz, h2⟩ =>
        ⟨a*p, b*q,
          by 
            rw [H, hw, hy],
          by 
            rw [H, hx, hz],
          c.mul h1 h2⟩ }

/-- A specialization of 'the smallest congruence relation containing a congruence relation `c`
    equals `c`'. -/
@[toAdditive
      "A specialization of 'the smallest additive congruence relation containing\nan additive congruence relation `c` equals `c`'."]
theorem map_of_surjective_eq_map_gen {c : Con M} {f : M → N} (H : ∀ x y, f (x*y) = f x*f y) (h : mul_ker f H ≤ c)
  (hf : surjective f) : c.map_gen f = c.map_of_surjective f H h hf :=
  by 
    rw [←con_gen_of_con (c.map_of_surjective f H h hf)] <;> rfl

/-- Given types with multiplications `M, N` and a congruence relation `c` on `N`, a
    multiplication-preserving map `f : M → N` induces a congruence relation on `f`'s domain
    defined by '`x ≈ y` iff `f(x)` is related to `f(y)` by `c`.' -/
@[toAdditive
      "Given types with additions `M, N` and an additive congruence relation `c` on `N`,\nan addition-preserving map `f : M → N` induces an additive congruence relation on `f`'s domain\ndefined by '`x ≈ y` iff `f(x)` is related to `f(y)` by `c`.' "]
def comap (f : M → N) (H : ∀ x y, f (x*y) = f x*f y) (c : Con N) : Con M :=
  { c.to_setoid.comap f with
    mul' :=
      fun w x y z h1 h2 =>
        show c (f (w*y)) (f (x*z))by 
          rw [H, H] <;> exact c.mul h1 h2 }

@[simp, toAdditive]
theorem comap_rel {f : M → N} (H : ∀ x y, f (x*y) = f x*f y) {c : Con N} {x y : M} : comap f H c x y ↔ c (f x) (f y) :=
  Iff.rfl

section 

open _Root_.Quotient

/-- Given a congruence relation `c` on a type `M` with a multiplication, the order-preserving
    bijection between the set of congruence relations containing `c` and the congruence relations
    on the quotient of `M` by `c`. -/
@[toAdditive
      "Given an additive congruence relation `c` on a type `M` with an addition,\nthe order-preserving bijection between the set of additive congruence relations containing `c` and\nthe additive congruence relations on the quotient of `M` by `c`."]
def correspondence : { d // c ≤ d } ≃o Con c.quotient :=
  { toFun :=
      fun d =>
        d.1.mapOfSurjective coeₓ _
            (by 
              rw [mul_ker_mk_eq] <;> exact d.2)$
          @exists_rep _ c.to_setoid,
    invFun :=
      fun d =>
        ⟨comap (coeₓ : M → c.quotient) (fun x y => rfl) d,
          fun _ _ h =>
            show d _ _ by 
              rw [c.eq.2 h] <;> exact d.refl _⟩,
    left_inv :=
      fun d =>
        Subtype.ext_iff_val.2$
          ext$
            fun _ _ =>
              ⟨fun h =>
                  let ⟨a, b, hx, hy, H⟩ := h 
                  d.1.trans (d.1.symm$ d.2$ c.eq.1 hx)$ d.1.trans H$ d.2$ c.eq.1 hy,
                fun h => ⟨_, _, rfl, rfl, h⟩⟩,
    right_inv :=
      fun d =>
        let Hm : (mul_ker (coeₓ : M → c.quotient) fun x y => rfl) ≤ comap (coeₓ : M → c.quotient) (fun x y => rfl) d :=
          fun x y h =>
            show d _ _ by 
              rw [mul_ker_mk_eq] at h <;> exact c.eq.2 h ▸ d.refl _ 
        ext$
          fun x y =>
            ⟨fun h =>
                let ⟨a, b, hx, hy, H⟩ := h 
                hx ▸ hy ▸ H,
              Con.induction_on₂ x y$ fun w z h => ⟨w, z, rfl, rfl, h⟩⟩,
    map_rel_iff' :=
      fun s t =>
        ⟨fun h _ _ hs =>
            let ⟨a, b, hx, hy, ht⟩ := h ⟨_, _, rfl, rfl, hs⟩
            t.1.trans (t.1.symm$ t.2$ eq_rel.1 hx)$ t.1.trans ht$ t.2$ eq_rel.1 hy,
          fun h _ _ hs =>
            let ⟨a, b, hx, hy, Hs⟩ := hs
            ⟨a, b, hx, hy, h Hs⟩⟩ }

end 

end 

section MulOneClass

variable{M}[MulOneClass M][MulOneClass N][MulOneClass P](c : Con M)

/-- The quotient of a monoid by a congruence relation is a monoid. -/
@[toAdditive "The quotient of an `add_monoid` by an additive congruence relation is\nan `add_monoid`."]
instance MulOneClass : MulOneClass c.quotient :=
  { one := ((1 : M) : c.quotient), mul := ·*·,
    mul_one := fun x => Quotientₓ.induction_on' x$ fun _ => congr_argₓ coeₓ$ mul_oneₓ _,
    one_mul := fun x => Quotientₓ.induction_on' x$ fun _ => congr_argₓ coeₓ$ one_mulₓ _ }

variable{c}

/-- The 1 of the quotient of a monoid by a congruence relation is the equivalence class of the
    monoid's 1. -/
@[simp,
  toAdditive
      "The 0 of the quotient of an `add_monoid` by an additive congruence relation\nis the equivalence class of the `add_monoid`'s 0."]
theorem coe_one : ((1 : M) : c.quotient) = 1 :=
  rfl

variable(M c)

/-- The submonoid of `M × M` defined by a congruence relation on a monoid `M`. -/
@[toAdditive "The `add_submonoid` of `M × M` defined by an additive congruence\nrelation on an `add_monoid` `M`."]
protected def Submonoid : Submonoid (M × M) :=
  { Carrier := { x | c x.1 x.2 }, one_mem' := c.iseqv.1 1, mul_mem' := fun _ _ => c.mul }

variable{M c}

/-- The congruence relation on a monoid `M` from a submonoid of `M × M` for which membership
    is an equivalence relation. -/
@[toAdditive
      "The additive congruence relation on an `add_monoid` `M` from\nan `add_submonoid` of `M × M` for which membership is an equivalence relation."]
def of_submonoid (N : Submonoid (M × M)) (H : Equivalenceₓ fun x y => (x, y) ∈ N) : Con M :=
  { R := fun x y => (x, y) ∈ N, iseqv := H, mul' := fun _ _ _ _ => N.mul_mem }

/-- Coercion from a congruence relation `c` on a monoid `M` to the submonoid of `M × M` whose
    elements are `(x, y)` such that `x` is related to `y` by `c`. -/
@[toAdditive
      "Coercion from a congruence relation `c` on an `add_monoid` `M`\nto the `add_submonoid` of `M × M` whose elements are `(x, y)` such that `x`\nis related to `y` by `c`."]
instance to_submonoid : Coe (Con M) (Submonoid (M × M)) :=
  ⟨fun c => c.submonoid M⟩

@[toAdditive]
theorem mem_coe {c : Con M} {x y} : (x, y) ∈ («expr↑ » c : Submonoid (M × M)) ↔ (x, y) ∈ c :=
  Iff.rfl

@[toAdditive]
theorem to_submonoid_inj (c d : Con M) (H : (c : Submonoid (M × M)) = d) : c = d :=
  ext$
    fun x y =>
      show (x, y) ∈ (c : Submonoid (M × M)) ↔ (x, y) ∈ «expr↑ » d by 
        rw [H]

@[toAdditive]
theorem le_iff {c d : Con M} : c ≤ d ↔ (c : Submonoid (M × M)) ≤ d :=
  ⟨fun h x H => h H, fun h x y hc => h$ show (x, y) ∈ c from hc⟩

/-- The kernel of a monoid homomorphism as a congruence relation. -/
@[toAdditive "The kernel of an `add_monoid` homomorphism as an additive congruence relation."]
def ker (f : M →* P) : Con M :=
  mul_ker f f.3

/-- The definition of the congruence relation defined by a monoid homomorphism's kernel. -/
@[simp,
  toAdditive "The definition of the additive congruence relation defined by an `add_monoid`\nhomomorphism's kernel."]
theorem ker_rel (f : M →* P) {x y} : ker f x y ↔ f x = f y :=
  Iff.rfl

/-- There exists an element of the quotient of a monoid by a congruence relation (namely 1). -/
@[toAdditive "There exists an element of the quotient of an `add_monoid` by a congruence relation\n(namely 0)."]
instance Quotientₓ.inhabited : Inhabited c.quotient :=
  ⟨((1 : M) : c.quotient)⟩

variable(c)

/-- The natural homomorphism from a monoid to its quotient by a congruence relation. -/
@[toAdditive "The natural homomorphism from an `add_monoid` to its quotient by an additive\ncongruence relation."]
def mk' : M →* c.quotient :=
  ⟨coeₓ, rfl, fun _ _ => rfl⟩

variable(x y : M)

/-- The kernel of the natural homomorphism from a monoid to its quotient by a congruence
    relation `c` equals `c`. -/
@[simp,
  toAdditive
      "The kernel of the natural homomorphism from an `add_monoid` to its quotient by\nan additive congruence relation `c` equals `c`."]
theorem mk'_ker : ker c.mk' = c :=
  ext$ fun _ _ => c.eq

variable{c}

/-- The natural homomorphism from a monoid to its quotient by a congruence relation is
    surjective. -/
@[toAdditive "The natural homomorphism from an `add_monoid` to its quotient by a congruence\nrelation is surjective."]
theorem mk'_surjective : surjective c.mk' :=
  Quotientₓ.surjective_quotient_mk'

@[simp, toAdditive]
theorem coe_mk' : (c.mk' : M → c.quotient) = coeₓ :=
  rfl

/-- The elements related to `x ∈ M`, `M` a monoid, by the kernel of a monoid homomorphism are
    those in the preimage of `f(x)` under `f`. -/
@[toAdditive
      "The elements related to `x ∈ M`, `M` an `add_monoid`, by the kernel of\nan `add_monoid` homomorphism are those in the preimage of `f(x)` under `f`. "]
theorem ker_apply_eq_preimage {f : M →* P} x : (ker f) x = f ⁻¹' {f x} :=
  Set.ext$
    fun x =>
      ⟨fun h => Set.mem_preimage.2$ Set.mem_singleton_iff.2 h.symm,
        fun h => (Set.mem_singleton_iff.1$ Set.mem_preimage.1 h).symm⟩

/-- Given a monoid homomorphism `f : N → M` and a congruence relation `c` on `M`, the congruence
    relation induced on `N` by `f` equals the kernel of `c`'s quotient homomorphism composed with
    `f`. -/
@[toAdditive
      "Given an `add_monoid` homomorphism `f : N → M` and an additive congruence relation\n`c` on `M`, the additive congruence relation induced on `N` by `f` equals the kernel of `c`'s\nquotient homomorphism composed with `f`."]
theorem comap_eq {f : N →* M} : comap f f.map_mul c = ker (c.mk'.comp f) :=
  ext$
    fun x y =>
      show c _ _ ↔ c.mk' _ = c.mk' _ by 
        rw [←c.eq] <;> rfl

variable(c)(f : M →* P)

/-- The homomorphism on the quotient of a monoid by a congruence relation `c` induced by a
    homomorphism constant on `c`'s equivalence classes. -/
@[toAdditive
      "The homomorphism on the quotient of an `add_monoid` by an additive congruence\nrelation `c` induced by a homomorphism constant on `c`'s equivalence classes."]
def lift (H : c ≤ ker f) : c.quotient →* P :=
  { toFun := fun x => Con.liftOn x f$ fun _ _ h => H h,
    map_one' :=
      by 
        rw [←f.map_one] <;> rfl,
    map_mul' := fun x y => Con.induction_on₂ x y$ fun m n => f.map_mul m n ▸ rfl }

variable{c f}

/-- The diagram describing the universal property for quotients of monoids commutes. -/
@[toAdditive "The diagram describing the universal property for quotients of `add_monoid`s\ncommutes."]
theorem lift_mk' (H : c ≤ ker f) x : c.lift f H (c.mk' x) = f x :=
  rfl

/-- The diagram describing the universal property for quotients of monoids commutes. -/
@[simp, toAdditive "The diagram describing the universal property for quotients of `add_monoid`s\ncommutes."]
theorem lift_coe (H : c ≤ ker f) (x : M) : c.lift f H x = f x :=
  rfl

/-- The diagram describing the universal property for quotients of monoids commutes. -/
@[simp, toAdditive "The diagram describing the universal property for quotients of `add_monoid`s\ncommutes."]
theorem lift_comp_mk' (H : c ≤ ker f) : (c.lift f H).comp c.mk' = f :=
  by 
    ext <;> rfl

/-- Given a homomorphism `f` from the quotient of a monoid by a congruence relation, `f` equals the
    homomorphism on the quotient induced by `f` composed with the natural map from the monoid to
    the quotient. -/
@[simp,
  toAdditive
      "Given a homomorphism `f` from the quotient of an `add_monoid` by an additive\ncongruence relation, `f` equals the homomorphism on the quotient induced by `f` composed with the\nnatural map from the `add_monoid` to the quotient."]
theorem lift_apply_mk' (f : c.quotient →* P) :
  (c.lift (f.comp c.mk')
      fun x y h =>
        show f («expr↑ » x) = f («expr↑ » y)by 
          rw [c.eq.2 h]) =
    f :=
  by 
    ext <;> rcases x with ⟨⟩ <;> rfl

/-- Homomorphisms on the quotient of a monoid by a congruence relation are equal if they
    are equal on elements that are coercions from the monoid. -/
@[toAdditive
      "Homomorphisms on the quotient of an `add_monoid` by an additive congruence relation\nare equal if they are equal on elements that are coercions from the `add_monoid`."]
theorem lift_funext (f g : c.quotient →* P) (h : ∀ (a : M), f a = g a) : f = g :=
  by 
    rw [←lift_apply_mk' f, ←lift_apply_mk' g]
    congr 1 
    exact MonoidHom.ext_iff.2 h

/-- The uniqueness part of the universal property for quotients of monoids. -/
@[toAdditive "The uniqueness part of the universal property for quotients of `add_monoid`s."]
theorem lift_unique (H : c ≤ ker f) (g : c.quotient →* P) (Hg : g.comp c.mk' = f) : g = c.lift f H :=
  lift_funext g (c.lift f H)$
    fun x =>
      by 
        subst f 
        rfl

/-- Given a congruence relation `c` on a monoid and a homomorphism `f` constant on `c`'s
    equivalence classes, `f` has the same image as the homomorphism that `f` induces on the
    quotient. -/
@[toAdditive
      "Given an additive congruence relation `c` on an `add_monoid` and a homomorphism `f`\nconstant on `c`'s equivalence classes, `f` has the same image as the homomorphism that `f` induces\non the quotient."]
theorem lift_range (H : c ≤ ker f) : (c.lift f H).mrange = f.mrange :=
  Submonoid.ext$
    fun x =>
      ⟨by 
          rintro ⟨⟨y⟩, hy⟩ <;> exact ⟨y, hy⟩,
        fun ⟨y, hy⟩ => ⟨«expr↑ » y, hy⟩⟩

/-- Surjective monoid homomorphisms constant on a congruence relation `c`'s equivalence classes
    induce a surjective homomorphism on `c`'s quotient. -/
@[toAdditive
      "Surjective `add_monoid` homomorphisms constant on an additive congruence\nrelation `c`'s equivalence classes induce a surjective homomorphism on `c`'s quotient."]
theorem lift_surjective_of_surjective (h : c ≤ ker f) (hf : surjective f) : surjective (c.lift f h) :=
  fun y => Exists.elim (hf y)$ fun w hw => ⟨w, (lift_mk' h w).symm ▸ hw⟩

variable(c f)

/-- Given a monoid homomorphism `f` from `M` to `P`, the kernel of `f` is the unique congruence
    relation on `M` whose induced map from the quotient of `M` to `P` is injective. -/
@[toAdditive
      "Given an `add_monoid` homomorphism `f` from `M` to `P`, the kernel of `f`\nis the unique additive congruence relation on `M` whose induced map from the quotient of `M`\nto `P` is injective."]
theorem ker_eq_lift_of_injective (H : c ≤ ker f) (h : injective (c.lift f H)) : ker f = c :=
  to_setoid_inj$ ker_eq_lift_of_injective f H h

variable{c}

/-- The homomorphism induced on the quotient of a monoid by the kernel of a monoid homomorphism. -/
@[toAdditive
      "The homomorphism induced on the quotient of an `add_monoid` by the kernel\nof an `add_monoid` homomorphism."]
def ker_lift : (ker f).Quotient →* P :=
  (ker f).lift f$ fun _ _ => id

variable{f}

/-- The diagram described by the universal property for quotients of monoids, when the congruence
    relation is the kernel of the homomorphism, commutes. -/
@[simp,
  toAdditive
      "The diagram described by the universal property for quotients\nof `add_monoid`s, when the additive congruence relation is the kernel of the homomorphism,\ncommutes."]
theorem ker_lift_mk (x : M) : ker_lift f x = f x :=
  rfl

/-- Given a monoid homomorphism `f`, the induced homomorphism on the quotient by `f`'s kernel has
    the same image as `f`. -/
@[simp,
  toAdditive
      "Given an `add_monoid` homomorphism `f`, the induced homomorphism\non the quotient by `f`'s kernel has the same image as `f`."]
theorem ker_lift_range_eq : (ker_lift f).mrange = f.mrange :=
  lift_range$ fun _ _ => id

/-- A monoid homomorphism `f` induces an injective homomorphism on the quotient by `f`'s kernel. -/
@[toAdditive "An `add_monoid` homomorphism `f` induces an injective homomorphism on the quotient\nby `f`'s kernel."]
theorem ker_lift_injective (f : M →* P) : injective (ker_lift f) :=
  fun x y => Quotientₓ.induction_on₂' x y$ fun _ _ => (ker f).Eq.2

/-- Given congruence relations `c, d` on a monoid such that `d` contains `c`, `d`'s quotient
    map induces a homomorphism from the quotient by `c` to the quotient by `d`. -/
@[toAdditive
      "Given additive congruence relations `c, d` on an `add_monoid` such that `d`\ncontains `c`, `d`'s quotient map induces a homomorphism from the quotient by `c` to the quotient\nby `d`."]
def map (c d : Con M) (h : c ≤ d) : c.quotient →* d.quotient :=
  c.lift d.mk'$ fun x y hc => show (ker d.mk') x y from (mk'_ker d).symm ▸ h hc

/-- Given congruence relations `c, d` on a monoid such that `d` contains `c`, the definition of
    the homomorphism from the quotient by `c` to the quotient by `d` induced by `d`'s quotient
    map. -/
@[toAdditive
      "Given additive congruence relations `c, d` on an `add_monoid` such that `d`\ncontains `c`, the definition of the homomorphism from the quotient by `c` to the quotient by `d`\ninduced by `d`'s quotient map."]
theorem map_apply {c d : Con M} (h : c ≤ d) x : c.map d h x = c.lift d.mk' (fun x y hc => d.eq.2$ h hc) x :=
  rfl

variable(c)

/-- The first isomorphism theorem for monoids. -/
@[toAdditive "The first isomorphism theorem for `add_monoid`s."]
noncomputable def quotient_ker_equiv_range (f : M →* P) : (ker f).Quotient ≃* f.mrange :=
  { Equiv.ofBijective
        ((@MulEquiv.toMonoidHom (ker_lift f).mrange _ _ _$ MulEquiv.submonoidCongr ker_lift_range_eq).comp
          (ker_lift f).mrangeRestrict)$
      (Equiv.bijective _).comp
        ⟨fun x y h =>
            ker_lift_injective f$
              by 
                rcases x with ⟨⟩ <;> rcases y with ⟨⟩ <;> injections,
          fun ⟨w, z, hz⟩ =>
            ⟨z,
              by 
                rcases hz with ⟨⟩ <;> rcases _x with ⟨⟩ <;> rfl⟩⟩ with
    map_mul' := MonoidHom.map_mul _ }

/-- The first isomorphism theorem for monoids in the case of a homomorphism with right inverse. -/
@[toAdditive "The first isomorphism theorem for `add_monoid`s in the case of a homomorphism\nwith right inverse.",
  simps]
def quotient_ker_equiv_of_right_inverse (f : M →* P) (g : P → M) (hf : Function.RightInverse g f) :
  (ker f).Quotient ≃* P :=
  { ker_lift f with toFun := ker_lift f, invFun := coeₓ ∘ g,
    left_inv :=
      fun x =>
        ker_lift_injective _
          (by 
            rw [Function.comp_app, ker_lift_mk, hf]),
    right_inv := hf }

/-- The first isomorphism theorem for monoids in the case of a surjective homomorphism.

For a `computable` version, see `con.quotient_ker_equiv_of_right_inverse`.
-/
@[toAdditive
      "The first isomorphism theorem for `add_monoid`s in the case of a surjective\nhomomorphism.\n\nFor a `computable` version, see `add_con.quotient_ker_equiv_of_right_inverse`.\n"]
noncomputable def quotient_ker_equiv_of_surjective (f : M →* P) (hf : surjective f) : (ker f).Quotient ≃* P :=
  quotient_ker_equiv_of_right_inverse _ _ hf.has_right_inverse.some_spec

/-- The second isomorphism theorem for monoids. -/
@[toAdditive "The second isomorphism theorem for `add_monoid`s."]
noncomputable def comap_quotient_equiv (f : N →* M) : (comap f f.map_mul c).Quotient ≃* (c.mk'.comp f).mrange :=
  (Con.congr comap_eq).trans$ quotient_ker_equiv_range$ c.mk'.comp f

/-- The third isomorphism theorem for monoids. -/
@[toAdditive "The third isomorphism theorem for `add_monoid`s."]
def quotient_quotient_equiv_quotient (c d : Con M) (h : c ≤ d) : (ker (c.map d h)).Quotient ≃* d.quotient :=
  { quotient_quotient_equiv_quotient c.to_setoid d.to_setoid h with
    map_mul' :=
      fun x y =>
        Con.induction_on₂ x y$
          fun w z =>
            Con.induction_on₂ w z$
              fun a b =>
                show _ = d.mk' a*d.mk' b by 
                  rw [←d.mk'.map_mul] <;> rfl }

end MulOneClass

section Monoids

/-- The quotient of a monoid by a congruence relation is a monoid. -/
@[toAdditive "The quotient of an `add_monoid` by an additive congruence relation is\nan `add_monoid`."]
instance Monoidₓ {M : Type _} [Monoidₓ M] (c : Con M) : Monoidₓ c.quotient :=
  { c.mul_one_class with one := ((1 : M) : c.quotient), mul := ·*·,
    mul_assoc := fun x y z => Quotientₓ.induction_on₃' x y z$ fun _ _ _ => congr_argₓ coeₓ$ mul_assocₓ _ _ _ }

/-- The quotient of a `comm_monoid` by a congruence relation is a `comm_monoid`. -/
@[toAdditive "The quotient of an `add_comm_monoid` by an additive congruence\nrelation is an `add_comm_monoid`."]
instance CommMonoidₓ {M : Type _} [CommMonoidₓ M] (c : Con M) : CommMonoidₓ c.quotient :=
  { c.monoid with
    mul_comm :=
      fun x y =>
        Con.induction_on₂ x y$
          fun w z =>
            by 
              rw [←coe_mul, ←coe_mul, mul_commₓ] }

end Monoids

section Groups

variable{M}[Groupₓ M][Groupₓ N][Groupₓ P](c : Con M)

/-- Multiplicative congruence relations preserve inversion. -/
@[toAdditive "Additive congruence relations preserve negation."]
protected theorem inv : ∀ {w x}, c w x → c (w⁻¹) (x⁻¹) :=
  fun x y h =>
    by 
      simpa using c.symm (c.mul (c.mul (c.refl (x⁻¹)) h) (c.refl (y⁻¹)))

/-- The inversion induced on the quotient by a congruence relation on a type with a
    inversion. -/
@[toAdditive "The negation induced on the quotient by an additive congruence relation on a type\nwith an negation."]
instance HasInv : HasInv c.quotient :=
  ⟨fun x => (Quotientₓ.liftOn' x fun w => ((w⁻¹ : M) : c.quotient))$ fun x y h => c.eq.2$ c.inv h⟩

/-- The quotient of a group by a congruence relation is a group. -/
@[toAdditive "The quotient of an `add_group` by an additive congruence relation is\nan `add_group`."]
instance Groupₓ : Groupₓ c.quotient :=
  { Con.monoid c with inv := fun x => x⁻¹,
    mul_left_inv :=
      fun x => show (x⁻¹*x) = 1 from Quotientₓ.induction_on' x$ fun _ => congr_argₓ coeₓ$ mul_left_invₓ _ }

end Groups

section Units

variable{α : Type _}[Monoidₓ M]{c : Con M}

-- error in GroupTheory.Congruence: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- In order to define a function `units (con.quotient c) → α` on the units of `con.quotient c`,
where `c : con M` is a multiplicative congruence on a monoid, it suffices to define a function `f`
that takes elements `x y : M` with proofs of `c (x * y) 1` and `c (y * x) 1`, and returns an element
of `α` provided that `f x y _ _ = f x' y' _ _` whenever `c x x'` and `c y y'`. -/
@[to_additive #[ident lift_on_add_units]]
def lift_on_units
(u : units c.quotient)
(f : ∀ x y : M, c «expr * »(x, y) 1 → c «expr * »(y, x) 1 → α)
(Hf : ∀ x y hxy hyx x' y' hxy' hyx', c x x' → c y y' → «expr = »(f x y hxy hyx, f x' y' hxy' hyx')) : α :=
begin
  refine [expr @con.hrec_on₂ M M _ _ c c (λ
    x
    y, «expr = »(«expr * »(x, y), 1) → «expr = »(«expr * »(y, x), 1) → α) (u : c.quotient) («expr↑ »(«expr ⁻¹»(u)) : c.quotient) (λ
    (x y : M)
    (hxy : «expr = »((«expr * »(x, y) : c.quotient), 1))
    (hyx : «expr = »((«expr * »(y, x) : c.quotient), 1)), f x y (c.eq.1 hxy) (c.eq.1 hyx)) (λ
    x y x' y' hx hy, _) u.3 u.4],
  ext1 [] [],
  { rw ["[", expr c.eq.2 hx, ",", expr c.eq.2 hy, "]"] [] },
  rintro [ident Hxy, ident Hxy', "-"],
  ext1 [] [],
  { rw ["[", expr c.eq.2 hx, ",", expr c.eq.2 hy, "]"] [] },
  rintro [ident Hyx, ident Hyx', "-"],
  exact [expr heq_of_eq (Hf _ _ _ _ _ _ _ _ hx hy)]
end

/-- In order to define a function `units (con.quotient c) → α` on the units of `con.quotient c`,
where `c : con M` is a multiplicative congruence on a monoid, it suffices to define a function `f`
that takes elements `x y : M` with proofs of `c (x * y) 1` and `c (y * x) 1`, and returns an element
of `α` provided that `f x y _ _ = f x' y' _ _` whenever `c x x'` and `c y y'`. -/
add_decl_doc AddCon.liftOnAddUnits

@[simp, toAdditive]
theorem lift_on_units_mk (f : ∀ (x y : M), c (x*y) 1 → c (y*x) 1 → α)
  (Hf : ∀ x y hxy hyx x' y' hxy' hyx', c x x' → c y y' → f x y hxy hyx = f x' y' hxy' hyx') (x y : M) hxy hyx :
  lift_on_units ⟨(x : c.quotient), y, hxy, hyx⟩ f Hf = f x y (c.eq.1 hxy) (c.eq.1 hyx) :=
  rfl

@[elab_as_eliminator, toAdditive induction_on_add_units]
theorem induction_on_units {p : Units c.quotient → Prop} (u : Units c.quotient)
  (H : ∀ (x y : M) (hxy : c (x*y) 1) (hyx : c (y*x) 1), p ⟨x, y, c.eq.2 hxy, c.eq.2 hyx⟩) : p u :=
  by 
    rcases u with ⟨⟨x⟩, ⟨y⟩, h₁, h₂⟩
    exact H x y (c.eq.1 h₁) (c.eq.1 h₂)

end Units

end Con

