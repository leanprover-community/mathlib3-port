/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module group_theory.free_abelian_group
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Group.Pi
import Mathbin.GroupTheory.FreeGroup
import Mathbin.GroupTheory.Abelianization
import Mathbin.Algebra.Module.Basic

/-!
# Free abelian groups

The free abelian group on a type `α`, defined as the abelianisation of
the free group on `α`.

The free abelian group on `α` can be abstractly defined as the left adjoint of the
forgetful functor from abelian groups to types. Alternatively, one could define
it as the functions `α → ℤ` which send all but finitely many `(a : α)` to `0`,
under pointwise addition. In this file, it is defined as the abelianisation
of the free group on `α`. All the constructions and theorems required to show
the adjointness of the construction and the forgetful functor are proved in this
file, but the category-theoretic adjunction statement is in
`algebra.category.Group.adjunctions` .

## Main definitions

Here we use the following variables: `(α β : Type*) (A : Type*) [add_comm_group A]`

* `free_abelian_group α` : the free abelian group on a type `α`. As an abelian
group it is `α →₀ ℤ`, the functions from `α` to `ℤ` such that all but finitely
many elements get mapped to zero, however this is not how it is implemented.

* `lift f : free_abelian_group α →+ A` : the group homomorphism induced
  by the map `f : α → A`.

* `map (f : α → β) : free_abelian_group α →+ free_abelian_group β` : functoriality
    of `free_abelian_group`

* `instance [monoid α] : semigroup (free_abelian_group α)`

* `instance [comm_monoid α] : comm_ring (free_abelian_group α)`

It has been suggested that we would be better off refactoring this file
and using `finsupp` instead.

## Implementation issues

The definition is `def free_abelian_group : Type u :=
additive $ abelianization $ free_group α`

Chris Hughes has suggested that this all be rewritten in terms of `finsupp`.
Johan Commelin has written all the API relating the definition to `finsupp`
in the lean-liquid repo.

The lemmas `map_pure`, `map_of`, `map_zero`, `map_add`, `map_neg` and `map_sub`
are proved about the `functor.map` `<$>` construction, and need `α` and `β` to
be in the same universe. But
`free_abelian_group.map (f : α → β)` is defined to be the `add_group`
homomorphism `free_abelian_group α →+ free_abelian_group β` (with `α` and `β` now
allowed to be in different universes), so `(map f).map_add`
etc can be used to prove that `free_abelian_group.map` preserves addition. The
functions `map_id`, `map_id_apply`, `map_comp`, `map_comp_apply` and `map_of_apply`
are about `free_abelian_group.map`.

-/


universe u v

variable (α : Type u)

/-- The free abelian group on a type. -/
def FreeAbelianGroup : Type u :=
  Additive <| Abelianization <| FreeGroup α
#align free_abelian_group FreeAbelianGroup

instance : AddCommGroup (FreeAbelianGroup α) :=
  @Additive.addCommGroup _ <| Abelianization.commGroup _

instance : Inhabited (FreeAbelianGroup α) :=
  ⟨0⟩

variable {α}

namespace FreeAbelianGroup

/-- The canonical map from α to `free_abelian_group α` -/
def of (x : α) : FreeAbelianGroup α :=
  Abelianization.of <| FreeGroup.of x
#align free_abelian_group.of FreeAbelianGroup.of

/-- The map `free_abelian_group α →+ A` induced by a map of types `α → A`. -/
def lift {β : Type v} [AddCommGroup β] : (α → β) ≃ (FreeAbelianGroup α →+ β) :=
  (@FreeGroup.lift _ (Multiplicative β) _).trans <|
    (@Abelianization.lift _ _ (Multiplicative β) _).trans MonoidHom.toAdditive
#align free_abelian_group.lift FreeAbelianGroup.lift

namespace lift

variable {β : Type v} [AddCommGroup β] (f : α → β)

open FreeAbelianGroup

@[simp]
protected theorem of (x : α) : lift f (of x) = f x :=
  by
  convert @Abelianization.lift.of (FreeGroup α) _ (Multiplicative β) _ _ _
  convert free_group.lift.of.symm
#align free_abelian_group.lift.of FreeAbelianGroup.lift.of

protected theorem unique (g : FreeAbelianGroup α →+ β) (hg : ∀ x, g (of x) = f x) {x} :
    g x = lift f x :=
  AddMonoidHom.congr_fun (lift.symm_apply_eq.mp (funext hg : g ∘ of = f)) _
#align free_abelian_group.lift.unique FreeAbelianGroup.lift.unique

/-- See note [partially-applied ext lemmas]. -/
@[ext]
protected theorem ext (g h : FreeAbelianGroup α →+ β) (H : ∀ x, g (of x) = h (of x)) : g = h :=
  lift.symm.Injective <| funext H
#align free_abelian_group.lift.ext FreeAbelianGroup.lift.ext

theorem map_hom {α β γ} [AddCommGroup β] [AddCommGroup γ] (a : FreeAbelianGroup α) (f : α → β)
    (g : β →+ γ) : g (lift f a) = lift (g ∘ f) a :=
  by
  suffices : (g.comp (lift f)) a = lift (g ∘ f) a
  exact this
  apply @lift.unique
  intro a
  show g ((lift f) (of a)) = g (f a)
  simp only [(· ∘ ·), lift.of]
#align free_abelian_group.lift.map_hom FreeAbelianGroup.lift.map_hom

end lift

section

open Classical

theorem of_injective : Function.Injective (of : α → FreeAbelianGroup α) := fun x y hoxy =>
  by_contradiction fun hxy : x ≠ y =>
    let f : FreeAbelianGroup α →+ ℤ := lift fun z => if x = z then (1 : ℤ) else 0
    have hfx1 : f (of x) = 1 := (lift.of _ _).trans <| if_pos rfl
    have hfy1 : f (of y) = 1 := hoxy ▸ hfx1
    have hfy0 : f (of y) = 0 := (lift.of _ _).trans <| if_neg hxy
    one_ne_zero <| hfy1.symm.trans hfy0
#align free_abelian_group.of_injective FreeAbelianGroup.of_injective

end

attribute [local instance] QuotientGroup.leftRel

@[elab_as_elim]
protected theorem induction_on {C : FreeAbelianGroup α → Prop} (z : FreeAbelianGroup α) (C0 : C 0)
    (C1 : ∀ x, C <| of x) (Cn : ∀ x, C (of x) → C (-of x)) (Cp : ∀ x y, C x → C y → C (x + y)) :
    C z :=
  (Quotient.inductionOn' z) fun x =>
    (Quot.induction_on x) fun L =>
      (List.recOn L C0) fun ⟨x, b⟩ tl ih =>
        Bool.recOn b (Cp _ _ (Cn _ (C1 x)) ih) (Cp _ _ (C1 x) ih)
#align free_abelian_group.induction_on FreeAbelianGroup.induction_on

theorem lift.add' {α β} [AddCommGroup β] (a : FreeAbelianGroup α) (f g : α → β) :
    lift (f + g) a = lift f a + lift g a :=
  by
  refine' FreeAbelianGroup.induction_on a _ _ _ _
  · simp only [(lift _).map_zero, zero_add]
  · intro x
    simp only [lift.of, Pi.add_apply]
  · intro x h
    simp only [map_neg, lift.of, Pi.add_apply, neg_add]
  · intro x y hx hy
    simp only [(lift _).map_add, hx, hy, add_add_add_comm]
#align free_abelian_group.lift.add' FreeAbelianGroup.lift.add'

/-- If `g : free_abelian_group X` and `A` is an abelian group then `lift_add_group_hom g`
is the additive group homomorphism sending a function `X → A` to the term of type `A`
corresponding to the evaluation of the induced map `free_abelian_group X → A` at `g`. -/
@[simps]
def liftAddGroupHom {α} (β) [AddCommGroup β] (a : FreeAbelianGroup α) : (α → β) →+ β :=
  AddMonoidHom.mk' (fun f => lift f a) (lift.add' a)
#align free_abelian_group.lift_add_group_hom FreeAbelianGroup.liftAddGroupHom

theorem lift_neg' {β} [AddCommGroup β] (f : α → β) : lift (-f) = -lift f :=
  AddMonoidHom.ext fun _ => (liftAddGroupHom _ _ : (α → β) →+ β).map_neg _
#align free_abelian_group.lift_neg' FreeAbelianGroup.lift_neg'

section Monad

variable {β : Type u}

instance : Monad FreeAbelianGroup.{u} where
  pure α := of
  bind α β x f := lift f x

@[elab_as_elim]
protected theorem induction_on' {C : FreeAbelianGroup α → Prop} (z : FreeAbelianGroup α) (C0 : C 0)
    (C1 : ∀ x, C <| pure x) (Cn : ∀ x, C (pure x) → C (-pure x))
    (Cp : ∀ x y, C x → C y → C (x + y)) : C z :=
  FreeAbelianGroup.induction_on z C0 C1 Cn Cp
#align free_abelian_group.induction_on' FreeAbelianGroup.induction_on'

@[simp]
theorem map_pure (f : α → β) (x : α) : f <$> (pure x : FreeAbelianGroup α) = pure (f x) :=
  rfl
#align free_abelian_group.map_pure FreeAbelianGroup.map_pure

@[simp]
protected theorem map_zero (f : α → β) : f <$> (0 : FreeAbelianGroup α) = 0 :=
  (lift (of ∘ f)).map_zero
#align free_abelian_group.map_zero FreeAbelianGroup.map_zero

@[simp]
protected theorem map_add (f : α → β) (x y : FreeAbelianGroup α) :
    f <$> (x + y) = f <$> x + f <$> y :=
  (lift _).map_add _ _
#align free_abelian_group.map_add FreeAbelianGroup.map_add

@[simp]
protected theorem map_neg (f : α → β) (x : FreeAbelianGroup α) : f <$> (-x) = -f <$> x :=
  map_neg (lift <| of ∘ f) _
#align free_abelian_group.map_neg FreeAbelianGroup.map_neg

@[simp]
protected theorem map_sub (f : α → β) (x y : FreeAbelianGroup α) :
    f <$> (x - y) = f <$> x - f <$> y :=
  map_sub (lift <| of ∘ f) _ _
#align free_abelian_group.map_sub FreeAbelianGroup.map_sub

@[simp]
theorem map_of (f : α → β) (y : α) : f <$> of y = of (f y) :=
  rfl
#align free_abelian_group.map_of FreeAbelianGroup.map_of

@[simp]
theorem pure_bind (f : α → FreeAbelianGroup β) (x) : pure x >>= f = f x :=
  lift.of _ _
#align free_abelian_group.pure_bind FreeAbelianGroup.pure_bind

@[simp]
theorem zero_bind (f : α → FreeAbelianGroup β) : 0 >>= f = 0 :=
  (lift f).map_zero
#align free_abelian_group.zero_bind FreeAbelianGroup.zero_bind

@[simp]
theorem add_bind (f : α → FreeAbelianGroup β) (x y : FreeAbelianGroup α) :
    x + y >>= f = (x >>= f) + (y >>= f) :=
  (lift _).map_add _ _
#align free_abelian_group.add_bind FreeAbelianGroup.add_bind

@[simp]
theorem neg_bind (f : α → FreeAbelianGroup β) (x : FreeAbelianGroup α) : -x >>= f = -(x >>= f) :=
  map_neg (lift f) _
#align free_abelian_group.neg_bind FreeAbelianGroup.neg_bind

@[simp]
theorem sub_bind (f : α → FreeAbelianGroup β) (x y : FreeAbelianGroup α) :
    x - y >>= f = (x >>= f) - (y >>= f) :=
  map_sub (lift f) _ _
#align free_abelian_group.sub_bind FreeAbelianGroup.sub_bind

@[simp]
theorem pure_seq (f : α → β) (x : FreeAbelianGroup α) : pure f <*> x = f <$> x :=
  pure_bind _ _
#align free_abelian_group.pure_seq FreeAbelianGroup.pure_seq

@[simp]
theorem zero_seq (x : FreeAbelianGroup α) : (0 : FreeAbelianGroup (α → β)) <*> x = 0 :=
  zero_bind _
#align free_abelian_group.zero_seq FreeAbelianGroup.zero_seq

@[simp]
theorem add_seq (f g : FreeAbelianGroup (α → β)) (x : FreeAbelianGroup α) :
    f + g <*> x = (f <*> x) + (g <*> x) :=
  add_bind _ _ _
#align free_abelian_group.add_seq FreeAbelianGroup.add_seq

@[simp]
theorem neg_seq (f : FreeAbelianGroup (α → β)) (x : FreeAbelianGroup α) : -f <*> x = -(f <*> x) :=
  neg_bind _ _
#align free_abelian_group.neg_seq FreeAbelianGroup.neg_seq

@[simp]
theorem sub_seq (f g : FreeAbelianGroup (α → β)) (x : FreeAbelianGroup α) :
    f - g <*> x = (f <*> x) - (g <*> x) :=
  sub_bind _ _ _
#align free_abelian_group.sub_seq FreeAbelianGroup.sub_seq

/-- If `f : free_abelian_group (α → β)`, then `f <*>` is an additive morphism
`free_abelian_group α →+ free_abelian_group β`. -/
def seqAddGroupHom (f : FreeAbelianGroup (α → β)) : FreeAbelianGroup α →+ FreeAbelianGroup β :=
  AddMonoidHom.mk' ((· <*> ·) f) fun x y =>
    show lift (· <$> (x + y)) _ = _
      by
      simp only [FreeAbelianGroup.map_add]
      exact lift.add' f _ _
#align free_abelian_group.seq_add_group_hom FreeAbelianGroup.seqAddGroupHom

@[simp]
theorem seq_zero (f : FreeAbelianGroup (α → β)) : f <*> 0 = 0 :=
  (seqAddGroupHom f).map_zero
#align free_abelian_group.seq_zero FreeAbelianGroup.seq_zero

@[simp]
theorem seq_add (f : FreeAbelianGroup (α → β)) (x y : FreeAbelianGroup α) :
    f <*> x + y = (f <*> x) + (f <*> y) :=
  (seqAddGroupHom f).map_add x y
#align free_abelian_group.seq_add FreeAbelianGroup.seq_add

@[simp]
theorem seq_neg (f : FreeAbelianGroup (α → β)) (x : FreeAbelianGroup α) : f <*> -x = -(f <*> x) :=
  (seqAddGroupHom f).map_neg x
#align free_abelian_group.seq_neg FreeAbelianGroup.seq_neg

@[simp]
theorem seq_sub (f : FreeAbelianGroup (α → β)) (x y : FreeAbelianGroup α) :
    f <*> x - y = (f <*> x) - (f <*> y) :=
  (seqAddGroupHom f).map_sub x y
#align free_abelian_group.seq_sub FreeAbelianGroup.seq_sub

instance : LawfulMonad FreeAbelianGroup.{u}
    where
  id_map α x :=
    FreeAbelianGroup.induction_on' x (FreeAbelianGroup.map_zero id) (map_pure id)
      (fun x ih => by rw [FreeAbelianGroup.map_neg, ih]) fun x y ihx ihy => by
      rw [FreeAbelianGroup.map_add, ihx, ihy]
  pure_bind α β x f := pure_bind f x
  bind_assoc α β γ x f g :=
    FreeAbelianGroup.induction_on' x (by iterate 3 rw [zero_bind])
      (fun x => by iterate 2 rw [pure_bind]) (fun x ih => by iterate 3 rw [neg_bind] <;> rw [ih])
      fun x y ihx ihy => by iterate 3 rw [add_bind] <;> rw [ihx, ihy]

instance : CommApplicative FreeAbelianGroup.{u}
    where commutative_prod α β x y :=
    FreeAbelianGroup.induction_on' x (by rw [FreeAbelianGroup.map_zero, zero_seq, seq_zero])
      (fun p => by
        rw [map_pure, pure_seq] <;>
          exact
            FreeAbelianGroup.induction_on' y
              (by rw [FreeAbelianGroup.map_zero, FreeAbelianGroup.map_zero, zero_seq])
              (fun q => by rw [map_pure, map_pure, pure_seq, map_pure])
              (fun q ih => by rw [FreeAbelianGroup.map_neg, FreeAbelianGroup.map_neg, neg_seq, ih])
              fun y₁ y₂ ih1 ih2 => by
              rw [FreeAbelianGroup.map_add, FreeAbelianGroup.map_add, add_seq, ih1, ih2])
      (fun p ih => by rw [FreeAbelianGroup.map_neg, neg_seq, seq_neg, ih]) fun x₁ x₂ ih1 ih2 => by
      rw [FreeAbelianGroup.map_add, add_seq, seq_add, ih1, ih2]

end Monad

universe w

variable {β : Type v} {γ : Type w}

/-- The additive group homomorphism `free_abelian_group α →+ free_abelian_group β` induced from a
  map `α → β` -/
def map (f : α → β) : FreeAbelianGroup α →+ FreeAbelianGroup β :=
  lift (of ∘ f)
#align free_abelian_group.map FreeAbelianGroup.map

theorem lift_comp {α} {β} {γ} [AddCommGroup γ] (f : α → β) (g : β → γ) (x : FreeAbelianGroup α) :
    lift (g ∘ f) x = lift g (map f x) :=
  by
  apply FreeAbelianGroup.induction_on x
  · exact AddMonoidHom.map_zero _
  · intro y
    rfl
  · intro x h
    simp only [h, AddMonoidHom.map_neg]
  · intro x y h₁ h₂
    simp only [h₁, h₂, AddMonoidHom.map_add]
#align free_abelian_group.lift_comp FreeAbelianGroup.lift_comp

theorem map_id : map id = AddMonoidHom.id (FreeAbelianGroup α) :=
  Eq.symm <|
    (lift.ext _ _) fun x => (lift.unique of (AddMonoidHom.id _)) fun y => AddMonoidHom.id_apply _ _
#align free_abelian_group.map_id FreeAbelianGroup.map_id

theorem map_id_apply (x : FreeAbelianGroup α) : map id x = x :=
  by
  rw [map_id]
  rfl
#align free_abelian_group.map_id_apply FreeAbelianGroup.map_id_apply

theorem map_comp {f : α → β} {g : β → γ} : map (g ∘ f) = (map g).comp (map f) :=
  Eq.symm <| (lift.ext _ _) fun x => Eq.symm <| lift_comp _ _ _
#align free_abelian_group.map_comp FreeAbelianGroup.map_comp

theorem map_comp_apply {f : α → β} {g : β → γ} (x : FreeAbelianGroup α) :
    map (g ∘ f) x = (map g) ((map f) x) := by
  rw [map_comp]
  rfl
#align free_abelian_group.map_comp_apply FreeAbelianGroup.map_comp_apply

-- version of map_of which uses `map`
@[simp]
theorem map_of_apply {f : α → β} (a : α) : map f (of a) = of (f a) :=
  rfl
#align free_abelian_group.map_of_apply FreeAbelianGroup.map_of_apply

variable (α)

section Mul

variable [Mul α]

instance : Mul (FreeAbelianGroup α) :=
  ⟨fun x => lift fun x₂ => lift (fun x₁ => of <| x₁ * x₂) x⟩

variable {α}

theorem mul_def (x y : FreeAbelianGroup α) :
    x * y = lift (fun x₂ => lift (fun x₁ => of (x₁ * x₂)) x) y :=
  rfl
#align free_abelian_group.mul_def FreeAbelianGroup.mul_def

@[simp]
theorem of_mul_of (x y : α) : of x * of y = of (x * y) :=
  rfl
#align free_abelian_group.of_mul_of FreeAbelianGroup.of_mul_of

theorem of_mul (x y : α) : of (x * y) = of x * of y :=
  rfl
#align free_abelian_group.of_mul FreeAbelianGroup.of_mul

instance : Distrib (FreeAbelianGroup α) :=
  { FreeAbelianGroup.hasMul _ with
    add := (· + ·)
    left_distrib := fun x y z => (lift _).map_add _ _
    right_distrib := fun x y z => by simp only [(· * ·), map_add, ← Pi.add_def, lift.add'] }

instance : NonUnitalNonAssocRing (FreeAbelianGroup α) :=
  { FreeAbelianGroup.distrib,
    FreeAbelianGroup.addCommGroup
      _ with
    zero_mul := fun a => by
      have h : 0 * a + 0 * a = 0 * a := by simp [← add_mul]
      simpa using h
    mul_zero := fun a => rfl }

end Mul

instance [One α] : One (FreeAbelianGroup α) :=
  ⟨of 1⟩

instance [Semigroup α] : NonUnitalRing (FreeAbelianGroup α) :=
  {
    FreeAbelianGroup.nonUnitalNonAssocRing with
    mul := (· * ·)
    mul_assoc := fun x y z =>
      by
      refine'
        FreeAbelianGroup.induction_on z (by simp) (fun L3 => _) (fun L3 ih => _)
          fun z₁ z₂ ih₁ ih₂ => _
      · refine'
          FreeAbelianGroup.induction_on y (by simp) (fun L2 => _) (fun L2 ih => _)
            fun y₁ y₂ ih₁ ih₂ => _
        · refine'
            FreeAbelianGroup.induction_on x (by simp) (fun L1 => _) (fun L1 ih => _)
              fun x₁ x₂ ih₁ ih₂ => _
          · rw [of_mul_of, of_mul_of, of_mul_of, of_mul_of, mul_assoc]
          · rw [neg_mul, neg_mul, neg_mul, ih]
          · rw [add_mul, add_mul, add_mul, ih₁, ih₂]
        · rw [neg_mul, mul_neg, mul_neg, neg_mul, ih]
        · rw [add_mul, mul_add, mul_add, add_mul, ih₁, ih₂]
      · rw [mul_neg, mul_neg, mul_neg, ih]
      · rw [mul_add, mul_add, mul_add, ih₁, ih₂] }

section Monoid

variable {R : Type _} [Monoid α] [Ring R]

instance : Ring (FreeAbelianGroup α) :=
  { FreeAbelianGroup.nonUnitalRing _,
    FreeAbelianGroup.hasOne _ with
    mul := (· * ·)
    mul_one := fun x => by
      unfold Mul.mul Semigroup.mul One.one
      rw [lift.of]
      refine'
        FreeAbelianGroup.induction_on x rfl (fun L => _) (fun L ih => _) fun x1 x2 ih1 ih2 => _
      · erw [lift.of]
        congr 1
        exact mul_one L
      · rw [map_neg, ih]
      · rw [map_add, ih1, ih2]
    one_mul := fun x => by
      unfold Mul.mul Semigroup.mul One.one
      refine' FreeAbelianGroup.induction_on x rfl _ _ _
      · intro L
        rw [lift.of, lift.of]
        congr 1
        exact one_mul L
      · intro L ih
        rw [map_neg, ih]
      · intro x1 x2 ih1 ih2
        rw [map_add, ih1, ih2] }

variable {α}

/-- `free_abelian_group.of` is a `monoid_hom` when `α` is a `monoid`. -/
def ofMulHom : α →* FreeAbelianGroup α where
  toFun := of
  map_one' := rfl
  map_mul' := of_mul
#align free_abelian_group.of_mul_hom FreeAbelianGroup.ofMulHom

@[simp]
theorem of_mul_hom_coe : (ofMulHom : α → FreeAbelianGroup α) = of :=
  rfl
#align free_abelian_group.of_mul_hom_coe FreeAbelianGroup.of_mul_hom_coe

/-- If `f` preserves multiplication, then so does `lift f`. -/
def liftMonoid : (α →* R) ≃ (FreeAbelianGroup α →+* R)
    where
  toFun f :=
    { lift f with
      toFun := lift f
      map_one' := (lift.of f _).trans f.map_one
      map_mul' := fun x y =>
        by
        refine' FreeAbelianGroup.induction_on y (mul_zero _).symm (fun L2 => _) (fun L2 ih => _) _
        · refine' FreeAbelianGroup.induction_on x (zero_mul _).symm (fun L1 => _) (fun L1 ih => _) _
          · simp_rw [of_mul_of, lift.of]
            exact f.map_mul _ _
          · simp_rw [neg_mul, map_neg, neg_mul]
            exact congr_arg Neg.neg ih
          · intro x1 x2 ih1 ih2
            simp only [add_mul, map_add, ih1, ih2]
        · rw [mul_neg, map_neg, map_neg, mul_neg, ih]
        · intro y1 y2 ih1 ih2
          rw [mul_add, map_add, map_add, mul_add, ih1, ih2] }
  invFun F := MonoidHom.comp (↑F) ofMulHom
  left_inv f := MonoidHom.ext <| lift.of _
  right_inv F :=
    RingHom.coe_addMonoidHom_injective <| lift.apply_symm_apply (↑F : FreeAbelianGroup α →+ R)
#align free_abelian_group.lift_monoid FreeAbelianGroup.liftMonoid

@[simp]
theorem lift_monoid_coe_add_monoid_hom (f : α →* R) : ↑(liftMonoid f) = lift f :=
  rfl
#align
  free_abelian_group.lift_monoid_coe_add_monoid_hom FreeAbelianGroup.lift_monoid_coe_add_monoid_hom

@[simp]
theorem lift_monoid_coe (f : α →* R) : ⇑(liftMonoid f) = lift f :=
  rfl
#align free_abelian_group.lift_monoid_coe FreeAbelianGroup.lift_monoid_coe

@[simp]
theorem lift_monoid_symm_coe (f : FreeAbelianGroup α →+* R) : ⇑(liftMonoid.symm f) = lift.symm ↑f :=
  rfl
#align free_abelian_group.lift_monoid_symm_coe FreeAbelianGroup.lift_monoid_symm_coe

theorem one_def : (1 : FreeAbelianGroup α) = of 1 :=
  rfl
#align free_abelian_group.one_def FreeAbelianGroup.one_def

theorem of_one : (of 1 : FreeAbelianGroup α) = 1 :=
  rfl
#align free_abelian_group.of_one FreeAbelianGroup.of_one

end Monoid

instance [CommMonoid α] : CommRing (FreeAbelianGroup α) :=
  { FreeAbelianGroup.ring α with
    mul_comm := fun x y =>
      by
      refine' FreeAbelianGroup.induction_on x (zero_mul y) _ _ _
      · intro s
        refine' FreeAbelianGroup.induction_on y (zero_mul _).symm _ _ _
        · intro t
          unfold Mul.mul Semigroup.mul Ring.mul
          iterate 4 rw [lift.of]
          congr 1
          exact mul_comm _ _
        · intro t ih
          rw [mul_neg, ih, neg_mul_eq_neg_mul]
        · intro y1 y2 ih1 ih2
          rw [mul_add, add_mul, ih1, ih2]
      · intro s ih
        rw [neg_mul, ih, neg_mul_eq_mul_neg]
      · intro x1 x2 ih1 ih2
        rw [add_mul, mul_add, ih1, ih2] }

instance pemptyUnique : Unique (FreeAbelianGroup PEmpty)
    where
  default := 0
  uniq x :=
    FreeAbelianGroup.induction_on x rfl (fun x => PEmpty.elim x) (fun x => PEmpty.elim x)
      (by
        rintro - - rfl rfl
        simp)
#align free_abelian_group.pempty_unique FreeAbelianGroup.pemptyUnique

/-- The free abelian group on a type with one term is isomorphic to `ℤ`. -/
def punitEquiv (T : Type _) [Unique T] : FreeAbelianGroup T ≃+ ℤ
    where
  toFun := FreeAbelianGroup.lift fun _ => (1 : ℤ)
  invFun n := n • of Inhabited.default
  left_inv z :=
    FreeAbelianGroup.induction_on z (by simp only [zero_smul, AddMonoidHom.map_zero])
      (Unique.forall_iff.2 <| by simp only [one_smul, lift.of]) (Unique.forall_iff.2 <| by simp)
      fun x y hx hy => by
      simp only [AddMonoidHom.map_add, add_smul] at *
      rw [hx, hy]
  right_inv n := by
    rw [AddMonoidHom.map_zsmul, lift.of]
    exact zsmul_int_one n
  map_add' := AddMonoidHom.map_add _
#align free_abelian_group.punit_equiv FreeAbelianGroup.punitEquiv

/-- Isomorphic types have isomorphic free abelian groups. -/
def equivOfEquiv {α β : Type _} (f : α ≃ β) : FreeAbelianGroup α ≃+ FreeAbelianGroup β
    where
  toFun := map f
  invFun := map f.symm
  left_inv := by
    intro x
    rw [← map_comp_apply, Equiv.symm_comp_self, map_id]
    rfl
  right_inv := by
    intro x
    rw [← map_comp_apply, Equiv.self_comp_symm, map_id]
    rfl
  map_add' := AddMonoidHom.map_add _
#align free_abelian_group.equiv_of_equiv FreeAbelianGroup.equivOfEquiv

end FreeAbelianGroup

