import Mathbin.Topology.Separation 
import Mathbin.Topology.SubsetProperties 
import Mathbin.Topology.LocallyConstant.Basic

/-!

# Discrete quotients of a topological space.

This file defines the type of discrete quotients of a topological space,
denoted `discrete_quotient X`. To avoid quantifying over types, we model such
quotients as setoids whose equivalence classes are clopen.

## Definitions
1. `discrete_quotient X` is the type of discrete quotients of `X`.
  It is endowed with a coercion to `Type`, which is defined as the
  quotient associated to the setoid in question, and each such quotient
  is endowed with the discrete topology.
2. Given `S : discrete_quotient X`, the projection `X → S` is denoted
  `S.proj`.
3. When `X` is compact and `S : discrete_quotient X`, the space `S` is
  endowed with a `fintype` instance.

## Order structure
The type `discrete_quotient X` is endowed with an instance of a `semilattice_inf` with `order_top`.
The partial ordering `A ≤ B` mathematically means that `B.proj` factors through `A.proj`.
The top element `⊤` is the trivial quotient, meaning that every element of `X` is collapsed
to a point. Given `h : A ≤ B`, the map `A → B` is `discrete_quotient.of_le h`.
Whenever `X` is discrete, the type `discrete_quotient X` is also endowed with an instance of a
`semilattice_inf` with `order_bot`, where the bot element `⊥` is `X` itself.

Given `f : X → Y` and `h : continuous f`, we define a predicate `le_comap h A B` for
`A : discrete_quotient X` and `B : discrete_quotient Y`, asserting that `f` descends to `A → B`.
If `cond : le_comap h A B`, the function `A → B` is obtained by `discrete_quotient.map cond`.

## Theorems
The two main results proved in this file are:
1. `discrete_quotient.eq_of_proj_eq` which states that when `X` is compact, t2 and totally
  disconnected, any two elements of `X` agree if their projections in `Q` agree for all
  `Q : discrete_quotient X`.
2. `discrete_quotient.exists_of_compat` which states that when `X` is compact, then any
  system of elements of `Q` as `Q : discrete_quotient X` varies, which is compatible with
  respect to `discrete_quotient.of_le`, must arise from some element of `X`.

## Remarks
The constructions in this file will be used to show that any profinite space is a limit
of finite discrete spaces.
-/


variable(X : Type _)[TopologicalSpace X]

/-- The type of discrete quotients of a topological space. -/
@[ext]
structure DiscreteQuotient where 
  Rel : X → X → Prop 
  Equiv : Equivalenceₓ Rel 
  clopen : ∀ x, IsClopen (SetOf (Rel x))

namespace DiscreteQuotient

variable{X}(S : DiscreteQuotient X)

/-- Construct a discrete quotient from a clopen set. -/
def of_clopen {A : Set X} (h : IsClopen A) : DiscreteQuotient X :=
  { Rel := fun x y => x ∈ A ∧ y ∈ A ∨ x ∉ A ∧ y ∉ A,
    Equiv :=
      ⟨by 
          tauto!,
        by 
          tauto!,
        by 
          tauto!⟩,
    clopen :=
      by 
        intro x 
        byCases' hx : x ∈ A
        ·
          apply IsClopen.union
          ·
            convert h 
            ext 
            exact ⟨fun i => i.2, fun i => ⟨hx, i⟩⟩
          ·
            convert is_clopen_empty 
            tidy
        ·
          apply IsClopen.union
          ·
            convert is_clopen_empty 
            tidy
          ·
            convert IsClopen.compl h 
            ext 
            exact ⟨fun i => i.2, fun i => ⟨hx, i⟩⟩ }

theorem refl : ∀ (x : X), S.rel x x :=
  S.equiv.1

theorem symm : ∀ (x y : X), S.rel x y → S.rel y x :=
  S.equiv.2.1

theorem trans : ∀ (x y z : X), S.rel x y → S.rel y z → S.rel x z :=
  S.equiv.2.2

/-- The setoid whose quotient yields the discrete quotient. -/
def Setoidₓ : Setoidₓ X :=
  ⟨S.rel, S.equiv⟩

instance  : CoeSort (DiscreteQuotient X) (Type _) :=
  ⟨fun S => Quotientₓ S.setoid⟩

instance  : TopologicalSpace S :=
  ⊥

/-- The projection from `X` to the given discrete quotient. -/
def proj : X → S :=
  Quotientₓ.mk'

theorem proj_surjective : Function.Surjective S.proj :=
  Quotientₓ.surjective_quotient_mk'

theorem fiber_eq (x : X) : S.proj ⁻¹' {S.proj x} = SetOf (S.rel x) :=
  by 
    ext1 y 
    simp only [Set.mem_preimage, Set.mem_singleton_iff, Quotientₓ.eq', DiscreteQuotient.proj.equations._eqn_1,
      Set.mem_set_of_eq]
    exact ⟨fun h => S.symm _ _ h, fun h => S.symm _ _ h⟩

theorem proj_is_locally_constant : IsLocallyConstant S.proj :=
  by 
    rw [(IsLocallyConstant.tfae S.proj).out 0 3]
    intro x 
    rcases S.proj_surjective x with ⟨x, rfl⟩
    simp [fiber_eq, (S.clopen x).1]

theorem proj_continuous : Continuous S.proj :=
  IsLocallyConstant.continuous$ proj_is_locally_constant _

theorem fiber_closed (A : Set S) : IsClosed (S.proj ⁻¹' A) :=
  IsClosed.preimage S.proj_continuous ⟨trivialₓ⟩

theorem fiber_open (A : Set S) : IsOpen (S.proj ⁻¹' A) :=
  IsOpen.preimage S.proj_continuous trivialₓ

theorem fiber_clopen (A : Set S) : IsClopen (S.proj ⁻¹' A) :=
  ⟨fiber_open _ _, fiber_closed _ _⟩

instance  : PartialOrderₓ (DiscreteQuotient X) :=
  { le := fun A B => ∀ (x y : X), A.rel x y → B.rel x y,
    le_refl :=
      fun a =>
        by 
          tauto,
    le_trans :=
      fun a b c h1 h2 =>
        by 
          tauto,
    le_antisymm :=
      fun a b h1 h2 =>
        by 
          ext 
          tauto }

instance  : OrderTop (DiscreteQuotient X) :=
  { top :=
      ⟨fun a b => True,
        ⟨by 
            tauto,
          by 
            tauto,
          by 
            tauto⟩,
        fun _ => is_clopen_univ⟩,
    le_top :=
      fun a =>
        by 
          tauto }

instance  : SemilatticeInf (DiscreteQuotient X) :=
  { DiscreteQuotient.partialOrder with
    inf :=
      fun A B =>
        { Rel := fun x y => A.rel x y ∧ B.rel x y,
          Equiv :=
            ⟨fun a => ⟨A.refl _, B.refl _⟩, fun a b h => ⟨A.symm _ _ h.1, B.symm _ _ h.2⟩,
              fun a b c h1 h2 => ⟨A.trans _ _ _ h1.1 h2.1, B.trans _ _ _ h1.2 h2.2⟩⟩,
          clopen := fun x => IsClopen.inter (A.clopen _) (B.clopen _) },
    inf_le_left :=
      fun a b =>
        by 
          tauto,
    inf_le_right :=
      fun a b =>
        by 
          tauto,
    le_inf :=
      fun a b c h1 h2 =>
        by 
          tauto }

instance  : Inhabited (DiscreteQuotient X) :=
  ⟨⊤⟩

section Comap

variable{Y : Type _}[TopologicalSpace Y]{f : Y → X}(cont : Continuous f)

/-- Comap a discrete quotient along a continuous map. -/
def comap : DiscreteQuotient Y :=
  { Rel := fun a b => S.rel (f a) (f b),
    Equiv := ⟨fun a => S.refl _, fun a b h => S.symm _ _ h, fun a b c h1 h2 => S.trans _ _ _ h1 h2⟩,
    clopen := fun y => ⟨IsOpen.preimage cont (S.clopen _).1, IsClosed.preimage cont (S.clopen _).2⟩ }

@[simp]
theorem comap_id : S.comap (continuous_id : Continuous (id : X → X)) = S :=
  by 
    ext 
    rfl

@[simp]
theorem comap_comp {Z : Type _} [TopologicalSpace Z] {g : Z → Y} (cont' : Continuous g) :
  S.comap (Continuous.comp cont cont') = (S.comap cont).comap cont' :=
  by 
    ext 
    rfl

theorem comap_mono {A B : DiscreteQuotient X} (h : A ≤ B) : A.comap cont ≤ B.comap cont :=
  by 
    tauto

end Comap

section OfLe

/-- The map induced by a refinement of a discrete quotient. -/
def of_le {A B : DiscreteQuotient X} (h : A ≤ B) : A → B :=
  fun a => Quotientₓ.liftOn' a (fun x => B.proj x) fun a b i => Quotientₓ.sound' (h _ _ i)

@[simp]
theorem of_le_refl {A : DiscreteQuotient X} : of_le (le_reflₓ A) = id :=
  by 
    ext ⟨⟩
    rfl

theorem of_le_refl_apply {A : DiscreteQuotient X} (a : A) : of_le (le_reflₓ A) a = a :=
  by 
    simp 

@[simp]
theorem of_le_comp {A B C : DiscreteQuotient X} (h1 : A ≤ B) (h2 : B ≤ C) :
  of_le (le_transₓ h1 h2) = (of_le h2 ∘ of_le h1) :=
  by 
    ext ⟨⟩
    rfl

theorem of_le_comp_apply {A B C : DiscreteQuotient X} (h1 : A ≤ B) (h2 : B ≤ C) (a : A) :
  of_le (le_transₓ h1 h2) a = of_le h2 (of_le h1 a) :=
  by 
    simp 

theorem of_le_continuous {A B : DiscreteQuotient X} (h : A ≤ B) : Continuous (of_le h) :=
  continuous_of_discrete_topology

@[simp]
theorem of_le_proj {A B : DiscreteQuotient X} (h : A ≤ B) : (of_le h ∘ A.proj) = B.proj :=
  by 
    ext 
    exact Quotientₓ.sound' (B.refl _)

@[simp]
theorem of_le_proj_apply {A B : DiscreteQuotient X} (h : A ≤ B) (x : X) : of_le h (A.proj x) = B.proj x :=
  by 
    change (of_le h ∘ A.proj) x = _ 
    simp 

end OfLe

/--
When X is discrete, there is a `order_bot` instance on `discrete_quotient X`
-/
instance  [DiscreteTopology X] : OrderBot (DiscreteQuotient X) :=
  { bot := { Rel := · = ·, Equiv := eq_equivalence, clopen := fun x => is_clopen_discrete _ },
    bot_le :=
      by 
        rintro S a b (h : a = b)
        rw [h]
        exact S.refl _ }

theorem proj_bot_injective [DiscreteTopology X] : Function.Injective (⊥ : DiscreteQuotient X).proj :=
  fun a b h => Quotientₓ.exact' h

theorem proj_bot_bijective [DiscreteTopology X] : Function.Bijective (⊥ : DiscreteQuotient X).proj :=
  ⟨proj_bot_injective, proj_surjective _⟩

section Map

variable{Y : Type _}[TopologicalSpace Y]{f : Y → X}(cont : Continuous f)(A : DiscreteQuotient Y)(B : DiscreteQuotient X)

/--
Given `cont : continuous f`, `le_comap cont A B` is defined as `A ≤ B.comap f`.
Mathematically this means that `f` descends to a morphism `A → B`.
-/
def le_comap : Prop :=
  A ≤ B.comap cont

variable{cont A B}

theorem le_comap_id (A : DiscreteQuotient X) : le_comap continuous_id A A :=
  by 
    tauto

theorem le_comap_comp {Z : Type _} [TopologicalSpace Z] {g : Z → Y} {cont' : Continuous g} {C : DiscreteQuotient Z} :
  le_comap cont' C A → le_comap cont A B → le_comap (Continuous.comp cont cont') C B :=
  by 
    tauto

theorem le_comap_trans {C : DiscreteQuotient X} : le_comap cont A B → B ≤ C → le_comap cont A C :=
  fun h1 h2 => le_transₓ h1$ comap_mono _ h2

/-- Map a discrete quotient along a continuous map. -/
def map (cond : le_comap cont A B) : A → B :=
  Quotientₓ.map' f cond

theorem map_continuous (cond : le_comap cont A B) : Continuous (map cond) :=
  continuous_of_discrete_topology

@[simp]
theorem map_proj (cond : le_comap cont A B) : (map cond ∘ A.proj) = (B.proj ∘ f) :=
  rfl

@[simp]
theorem map_proj_apply (cond : le_comap cont A B) (y : Y) : map cond (A.proj y) = B.proj (f y) :=
  rfl

@[simp]
theorem map_id : map (le_comap_id A) = id :=
  by 
    ext ⟨⟩
    rfl

@[simp]
theorem map_comp {Z : Type _} [TopologicalSpace Z] {g : Z → Y} {cont' : Continuous g} {C : DiscreteQuotient Z}
  (h1 : le_comap cont' C A) (h2 : le_comap cont A B) : map (le_comap_comp h1 h2) = (map h2 ∘ map h1) :=
  by 
    ext ⟨⟩
    rfl

@[simp]
theorem of_le_map {C : DiscreteQuotient X} (cond : le_comap cont A B) (h : B ≤ C) :
  map (le_comap_trans cond h) = (of_le h ∘ map cond) :=
  by 
    ext ⟨⟩
    rfl

@[simp]
theorem of_le_map_apply {C : DiscreteQuotient X} (cond : le_comap cont A B) (h : B ≤ C) (a : A) :
  map (le_comap_trans cond h) a = of_le h (map cond a) :=
  by 
    rcases a with ⟨⟩
    rfl

@[simp]
theorem map_of_le {C : DiscreteQuotient Y} (cond : le_comap cont A B) (h : C ≤ A) :
  map (le_transₓ h cond) = (map cond ∘ of_le h) :=
  by 
    ext ⟨⟩
    rfl

@[simp]
theorem map_of_le_apply {C : DiscreteQuotient Y} (cond : le_comap cont A B) (h : C ≤ A) (c : C) :
  map (le_transₓ h cond) c = map cond (of_le h c) :=
  by 
    rcases c with ⟨⟩
    rfl

end Map

theorem eq_of_proj_eq [T2Space X] [CompactSpace X] [disc : TotallyDisconnectedSpace X] {x y : X} :
  (∀ (Q : DiscreteQuotient X), Q.proj x = Q.proj y) → x = y :=
  by 
    intro h 
    change x ∈ ({y} : Set X)
    rw [totally_disconnected_space_iff_connected_component_singleton] at disc 
    rw [←disc y, connected_component_eq_Inter_clopen]
    rintro U ⟨⟨U, hU1, hU2⟩, rfl⟩
    replace h : _ ∨ _ := Quotientₓ.exact' (h (of_clopen hU1))
    tauto

theorem fiber_le_of_le {A B : DiscreteQuotient X} (h : A ≤ B) (a : A) : A.proj ⁻¹' {a} ≤ B.proj ⁻¹' {of_le h a} :=
  by 
    induction a 
    erw [fiber_eq, fiber_eq]
    tidy

-- error in Topology.DiscreteQuotient: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem exists_of_compat
[compact_space X]
(Qs : ∀ Q : discrete_quotient X, Q)
(compat : ∀
 (A B : discrete_quotient X)
 (h : «expr ≤ »(A, B)), «expr = »(of_le h (Qs _), Qs _)) : «expr∃ , »((x : X), ∀
 Q : discrete_quotient X, «expr = »(Q.proj x, Qs _)) :=
begin
  obtain ["⟨", ident x, ",", ident hx, "⟩", ":=", expr is_compact.nonempty_Inter_of_directed_nonempty_compact_closed (λ
    Q : discrete_quotient X, «expr ⁻¹' »(Q.proj, {Qs _})) (λ
    A B, _) (λ i, _) (λ i, (fiber_closed _ _).is_compact) (λ i, fiber_closed _ _)],
  { refine [expr ⟨x, λ Q, _⟩],
    specialize [expr hx _ ⟨Q, rfl⟩],
    dsimp [] [] [] ["at", ident hx],
    rcases [expr proj_surjective _ (Qs Q), "with", "⟨", ident y, ",", ident hy, "⟩"],
    rw ["<-", expr hy] ["at", "*"],
    rw [expr fiber_eq] ["at", ident hx],
    exact [expr quotient.sound' (Q.symm y x hx)] },
  { refine [expr ⟨«expr ⊓ »(A, B), λ a ha, _, λ a ha, _⟩],
    { dsimp ["only"] [] [] [],
      erw ["<-", expr compat «expr ⊓ »(A, B) A inf_le_left] [],
      exact [expr fiber_le_of_le _ _ ha] },
    { dsimp ["only"] [] [] [],
      erw ["<-", expr compat «expr ⊓ »(A, B) B inf_le_right] [],
      exact [expr fiber_le_of_le _ _ ha] } },
  { obtain ["⟨", ident x, ",", ident hx, "⟩", ":=", expr i.proj_surjective (Qs i)],
    refine [expr ⟨x, _⟩],
    dsimp ["only"] [] [] [],
    rw ["[", "<-", expr hx, ",", expr fiber_eq, "]"] [],
    apply [expr i.refl] }
end

-- error in Topology.DiscreteQuotient: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
noncomputable instance [compact_space X] : fintype S :=
begin
  have [ident cond] [":", expr is_compact («expr⊤»() : set X)] [":=", expr compact_univ],
  rw [expr is_compact_iff_finite_subcover] ["at", ident cond],
  have [ident h] [] [":=", expr @cond S (λ
    s, «expr ⁻¹' »(S.proj, {s})) (λ
    s, fiber_open _ _) (λ x hx, ⟨«expr ⁻¹' »(S.proj, {S.proj x}), ⟨S.proj x, rfl⟩, rfl⟩)],
  let [ident T] [] [":=", expr classical.some h],
  have [ident hT] [] [":=", expr classical.some_spec h],
  refine [expr ⟨T, λ s, _⟩],
  rcases [expr S.proj_surjective s, "with", "⟨", ident x, ",", ident rfl, "⟩"],
  rcases [expr hT (by tauto [] : «expr ∈ »(x, «expr⊤»())), "with", "⟨", ident j, ",", "⟨", ident j, ",", ident rfl, "⟩", ",", ident h1, ",", "⟨", ident hj, ",", ident rfl, "⟩", ",", ident h2, "⟩"],
  dsimp ["only"] [] [] ["at", ident h2],
  suffices [] [":", expr «expr = »(S.proj x, j)],
  by rwa [expr this] [],
  rcases [expr j, "with", "⟨", ident j, "⟩"],
  apply [expr quotient.sound'],
  erw [expr fiber_eq] ["at", ident h2],
  exact [expr S.symm _ _ h2]
end

end DiscreteQuotient

namespace LocallyConstant

variable{X}{α : Type _}(f : LocallyConstant X α)

/-- Any locally constant function induces a discrete quotient. -/
def DiscreteQuotient : DiscreteQuotient X :=
  { Rel := fun a b => f b = f a,
    Equiv :=
      ⟨by 
          tauto,
        by 
          tauto,
        fun a b c h1 h2 =>
          by 
            rw [h2, h1]⟩,
    clopen := fun x => f.is_locally_constant.is_clopen_fiber _ }

/-- The function from the discrete quotient associated to a locally constant function. -/
def lift : f.discrete_quotient → α :=
  fun a => Quotientₓ.liftOn' a f fun a b h => h.symm

theorem lift_is_locally_constant : _root_.is_locally_constant f.lift :=
  fun A => trivialₓ

/-- A locally constant version of `locally_constant.lift`. -/
def locally_constant_lift : LocallyConstant f.discrete_quotient α :=
  ⟨f.lift, f.lift_is_locally_constant⟩

@[simp]
theorem lift_eq_coe : f.lift = f.locally_constant_lift :=
  rfl

@[simp]
theorem factors : (f.locally_constant_lift ∘ f.discrete_quotient.proj) = f :=
  by 
    ext 
    rfl

end LocallyConstant

