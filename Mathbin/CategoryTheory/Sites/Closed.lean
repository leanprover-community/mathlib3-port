import Mathbin.CategoryTheory.Sites.SheafOfTypes 
import Mathbin.Order.Closure

/-!
# Closed sieves

A natural closure operator on sieves is a closure operator on `sieve X` for each `X` which commutes
with pullback.
We show that a Grothendieck topology `J` induces a natural closure operator, and define what the
closed sieves are. The collection of `J`-closed sieves forms a presheaf which is a sheaf for `J`,
and further this presheaf can be used to determine the Grothendieck topology from the sheaf
predicate.
Finally we show that a natural closure operator on sieves induces a Grothendieck topology, and hence
that natural closure operators are in bijection with Grothendieck topologies.

## Main definitions

* `category_theory.grothendieck_topology.close`: Sends a sieve `S` on `X` to the set of arrows
  which it covers. This has all the usual properties of a closure operator, as well as commuting
  with pullback.
* `category_theory.grothendieck_topology.closure_operator`: The bundled `closure_operator` given
  by `category_theory.grothendieck_topology.close`.
* `category_theory.grothendieck_topology.closed`: A sieve `S` on `X` is closed for the topology `J`
   if it contains every arrow it covers.
* `category_theory.functor.closed_sieves`: The presheaf sending `X` to the collection of `J`-closed
  sieves on `X`. This is additionally shown to be a sheaf for `J`, and if this is a sheaf for a
  different topology `J'`, then `J' ≤ J`.
* `category_theory.grothendieck_topology.topology_of_closure_operator`: A closure operator on the
  set of sieves on every object which commutes with pullback additionally induces a Grothendieck
  topology, giving a bijection with `category_theory.grothendieck_topology.closure_operator`.


## Tags

closed sieve, closure, Grothendieck topology

## References

* [S. MacLane, I. Moerdijk, *Sheaves in Geometry and Logic*][MM92]
-/


universe v u

namespace CategoryTheory

variable{C : Type u}[category.{v} C]

variable(J₁ J₂ : grothendieck_topology C)

namespace GrothendieckTopology

/-- The `J`-closure of a sieve is the collection of arrows which it covers. -/
@[simps]
def close {X : C} (S : sieve X) : sieve X :=
  { Arrows := fun Y f => J₁.covers S f, downward_closed' := fun Y Z f hS => J₁.arrow_stable _ _ hS }

/-- Any sieve is smaller than its closure. -/
theorem le_close {X : C} (S : sieve X) : S ≤ J₁.close S :=
  fun Y g hg => J₁.covering_of_eq_top (S.pullback_eq_top_of_mem hg)

/--
A sieve is closed for the Grothendieck topology if it contains every arrow it covers.
In the case of the usual topology on a topological space, this means that the open cover contains
every open set which it covers.

Note this has no relation to a closed subset of a topological space.
-/
def is_closed {X : C} (S : sieve X) : Prop :=
  ∀ ⦃Y : C⦄ (f : Y ⟶ X), J₁.covers S f → S f

/-- If `S` is `J₁`-closed, then `S` covers exactly the arrows it contains. -/
theorem covers_iff_mem_of_closed {X : C} {S : sieve X} (h : J₁.is_closed S) {Y : C} (f : Y ⟶ X) : J₁.covers S f ↔ S f :=
  ⟨h _, J₁.arrow_max _ _⟩

/-- Being `J`-closed is stable under pullback. -/
theorem is_closed_pullback {X Y : C} (f : Y ⟶ X) (S : sieve X) : J₁.is_closed S → J₁.is_closed (S.pullback f) :=
  fun hS Z g hg =>
    hS (g ≫ f)
      (by 
        rwa [J₁.covers_iff, sieve.pullback_comp])

/--
The closure of a sieve `S` is the largest closed sieve which contains `S` (justifying the name
"closure").
-/
theorem le_close_of_is_closed {X : C} {S T : sieve X} (h : S ≤ T) (hT : J₁.is_closed T) : J₁.close S ≤ T :=
  fun Y f hf => hT _ (J₁.superset_covering (sieve.pullback_monotone f h) hf)

/-- The closure of a sieve is closed. -/
theorem close_is_closed {X : C} (S : sieve X) : J₁.is_closed (J₁.close S) :=
  fun Y g hg => J₁.arrow_trans g _ S hg fun Z h hS => hS

/-- The sieve `S` is closed iff its closure is equal to itself. -/
theorem is_closed_iff_close_eq_self {X : C} (S : sieve X) : J₁.is_closed S ↔ J₁.close S = S :=
  by 
    split 
    ·
      intro h 
      apply le_antisymmₓ
      ·
        intro Y f hf 
        rw [←J₁.covers_iff_mem_of_closed h]
        apply hf
      ·
        apply J₁.le_close
    ·
      intro e 
      rw [←e]
      apply J₁.close_is_closed

theorem close_eq_self_of_is_closed {X : C} {S : sieve X} (hS : J₁.is_closed S) : J₁.close S = S :=
  (J₁.is_closed_iff_close_eq_self S).1 hS

/-- Closing under `J` is stable under pullback. -/
theorem pullback_close {X Y : C} (f : Y ⟶ X) (S : sieve X) : J₁.close (S.pullback f) = (J₁.close S).pullback f :=
  by 
    apply le_antisymmₓ
    ·
      refine' J₁.le_close_of_is_closed (sieve.pullback_monotone _ (J₁.le_close S)) _ 
      apply J₁.is_closed_pullback _ _ (J₁.close_is_closed _)
    ·
      intro Z g hg 
      change _ ∈ J₁ _ 
      rw [←sieve.pullback_comp]
      apply hg

@[mono]
theorem monotone_close {X : C} : Monotone (J₁.close : sieve X → sieve X) :=
  fun S₁ S₂ h => J₁.le_close_of_is_closed (h.trans (J₁.le_close _)) (J₁.close_is_closed S₂)

@[simp]
theorem close_close {X : C} (S : sieve X) : J₁.close (J₁.close S) = J₁.close S :=
  le_antisymmₓ (J₁.le_close_of_is_closed (le_reflₓ _) (J₁.close_is_closed S)) (J₁.monotone_close (J₁.le_close _))

/--
The sieve `S` is in the topology iff its closure is the maximal sieve. This shows that the closure
operator determines the topology.
-/
theorem close_eq_top_iff_mem {X : C} (S : sieve X) : J₁.close S = ⊤ ↔ S ∈ J₁ X :=
  by 
    split 
    ·
      intro h 
      apply J₁.transitive (J₁.top_mem X)
      intro Y f hf 
      change J₁.close S f 
      rwa [h]
    ·
      intro hS 
      rw [eq_top_iff]
      intro Y f hf 
      apply J₁.pullback_stable _ hS

/-- A Grothendieck topology induces a natural family of closure operators on sieves. -/
@[simps (config := { rhsMd := semireducible })]
def ClosureOperator (X : C) : ClosureOperator (sieve X) :=
  ClosureOperator.mk' J₁.close
    (fun S₁ S₂ h => J₁.le_close_of_is_closed (h.trans (J₁.le_close _)) (J₁.close_is_closed S₂)) J₁.le_close
    fun S => J₁.le_close_of_is_closed (le_reflₓ _) (J₁.close_is_closed S)

@[simp]
theorem closed_iff_closed {X : C} (S : sieve X) : S ∈ (J₁.closure_operator X).closed ↔ J₁.is_closed S :=
  (J₁.is_closed_iff_close_eq_self S).symm

end GrothendieckTopology

/--
The presheaf sending each object to the set of `J`-closed sieves on it. This presheaf is a `J`-sheaf
(and will turn out to be a subobject classifier for the category of `J`-sheaves).
-/
@[simps]
def functor.closed_sieves : «expr ᵒᵖ» C ⥤ Type max v u :=
  { obj := fun X => { S : sieve X.unop // J₁.is_closed S },
    map := fun X Y f S => ⟨S.1.pullback f.unop, J₁.is_closed_pullback f.unop _ S.2⟩ }

-- error in CategoryTheory.Sites.Closed: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
The presheaf of `J`-closed sieves is a `J`-sheaf.
The proof of this is adapted from [MM92], Chatper III, Section 7, Lemma 1.
-/ theorem classifier_is_sheaf : presieve.is_sheaf J₁ (functor.closed_sieves J₁) :=
begin
  intros [ident X, ident S, ident hS],
  rw ["<-", expr presieve.is_separated_for_and_exists_is_amalgamation_iff_sheaf_for] [],
  refine [expr ⟨_, _⟩],
  { rintro [ident x, "⟨", ident M, ",", ident hM, "⟩", "⟨", ident N, ",", ident hN, "⟩", ident hM₂, ident hN₂],
    ext [] [] [],
    dsimp ["only"] ["[", expr subtype.coe_mk, "]"] [] [],
    rw ["[", "<-", expr J₁.covers_iff_mem_of_closed hM, ",", "<-", expr J₁.covers_iff_mem_of_closed hN, "]"] [],
    have [ident q] [":", expr ∀ {{Z : C}} (g : «expr ⟶ »(Z, X)) (hg : S g), «expr = »(M.pullback g, N.pullback g)] [],
    { intros [ident Z, ident g, ident hg],
      apply [expr congr_arg subtype.val ((hM₂ g hg).trans (hN₂ g hg).symm)] },
    have [ident MSNS] [":", expr «expr = »(«expr ⊓ »(M, S), «expr ⊓ »(N, S))] [],
    { ext [] [ident Z, ident g] [],
      rw ["[", expr sieve.inter_apply, ",", expr sieve.inter_apply, ",", expr and_comm (N g), ",", expr and_comm, "]"] [],
      apply [expr and_congr_right],
      intro [ident hg],
      rw ["[", expr sieve.pullback_eq_top_iff_mem, ",", expr sieve.pullback_eq_top_iff_mem, ",", expr q g hg, "]"] [] },
    split,
    { intro [ident hf],
      rw [expr J₁.covers_iff] [],
      apply [expr J₁.superset_covering (sieve.pullback_monotone f inf_le_left)],
      rw ["<-", expr MSNS] [],
      apply [expr J₁.arrow_intersect f M S hf (J₁.pullback_stable _ hS)] },
    { intro [ident hf],
      rw [expr J₁.covers_iff] [],
      apply [expr J₁.superset_covering (sieve.pullback_monotone f inf_le_left)],
      rw [expr MSNS] [],
      apply [expr J₁.arrow_intersect f N S hf (J₁.pullback_stable _ hS)] } },
  { intros [ident x, ident hx],
    rw [expr presieve.compatible_iff_sieve_compatible] ["at", ident hx],
    let [ident M] [] [":=", expr sieve.bind S (λ Y f hf, (x f hf).1)],
    have [] [":", expr ∀ {{Y}} (f : «expr ⟶ »(Y, X)) (hf : S f), «expr = »(M.pullback f, (x f hf).1)] [],
    { intros [ident Y, ident f, ident hf],
      apply [expr le_antisymm],
      { rintro [ident Z, ident u, "⟨", ident W, ",", ident g, ",", ident f', ",", ident hf', ",", "(", ident hg, ":", expr (x f' hf').1 _, ")", ",", ident c, "⟩"],
        rw ["[", expr sieve.pullback_eq_top_iff_mem, ",", "<-", expr show «expr = »((x «expr ≫ »(u, f) _).1, (x f hf).1.pullback u), from congr_arg subtype.val (hx f u hf), "]"] [],
        simp_rw ["<-", expr c] [],
        rw [expr show «expr = »((x «expr ≫ »(g, f') _).1, _), from congr_arg subtype.val (hx f' g hf')] [],
        apply [expr sieve.pullback_eq_top_of_mem _ hg] },
      { apply [expr sieve.le_pullback_bind S (λ Y f hf, (x f hf).1)] } },
    refine [expr ⟨⟨_, J₁.close_is_closed M⟩, _⟩],
    { intros [ident Y, ident f, ident hf],
      ext1 [] [],
      dsimp [] [] [] [],
      rw ["[", "<-", expr J₁.pullback_close, ",", expr this _ hf, "]"] [],
      apply [expr le_antisymm (J₁.le_close_of_is_closed (le_refl _) (x f hf).2) (J₁.le_close _)] } }
end

-- error in CategoryTheory.Sites.Closed: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
If presheaf of `J₁`-closed sieves is a `J₂`-sheaf then `J₁ ≤ J₂`. Note the converse is true by
`classifier_is_sheaf` and `is_sheaf_of_le`.
-/
theorem le_topology_of_closed_sieves_is_sheaf
{J₁ J₂ : grothendieck_topology C}
(h : presieve.is_sheaf J₁ (functor.closed_sieves J₂)) : «expr ≤ »(J₁, J₂) :=
λ X S hS, begin
  rw ["<-", expr J₂.close_eq_top_iff_mem] [],
  have [] [":", expr J₂.is_closed («expr⊤»() : sieve X)] [],
  { intros [ident Y, ident f, ident hf],
    trivial },
  suffices [] [":", expr «expr = »((⟨J₂.close S, J₂.close_is_closed S⟩ : subtype _), ⟨«expr⊤»(), this⟩)],
  { rw [expr subtype.ext_iff] ["at", ident this],
    exact [expr this] },
  apply [expr (h S hS).is_separated_for.ext],
  { intros [ident Y, ident f, ident hf],
    ext1 [] [],
    dsimp [] [] [] [],
    rw ["[", expr sieve.pullback_top, ",", "<-", expr J₂.pullback_close, ",", expr S.pullback_eq_top_of_mem hf, ",", expr J₂.close_eq_top_iff_mem, "]"] [],
    apply [expr J₂.top_mem] }
end

/-- If being a sheaf for `J₁` is equivalent to being a sheaf for `J₂`, then `J₁ = J₂`. -/
theorem topology_eq_iff_same_sheaves {J₁ J₂ : grothendieck_topology C} :
  J₁ = J₂ ↔ ∀ (P : «expr ᵒᵖ» C ⥤ Type max v u), presieve.is_sheaf J₁ P ↔ presieve.is_sheaf J₂ P :=
  by 
    split 
    ·
      rintro rfl 
      intro P 
      rfl
    ·
      intro h 
      apply le_antisymmₓ
      ·
        apply le_topology_of_closed_sieves_is_sheaf 
        rw [h]
        apply classifier_is_sheaf
      ·
        apply le_topology_of_closed_sieves_is_sheaf 
        rw [←h]
        apply classifier_is_sheaf

/--
A closure (increasing, inflationary and idempotent) operation on sieves that commutes with pullback
induces a Grothendieck topology.
In fact, such operations are in bijection with Grothendieck topologies.
-/
@[simps]
def topology_of_closure_operator (c : ∀ (X : C), ClosureOperator (sieve X))
  (hc : ∀ ⦃X Y : C⦄ (f : Y ⟶ X) (S : sieve X), c _ (S.pullback f) = (c _ S).pullback f) : grothendieck_topology C :=
  { Sieves := fun X => { S | c X S = ⊤ }, top_mem' := fun X => top_unique ((c X).le_closure _),
    pullback_stable' :=
      fun X Y S f hS =>
        by 
          rw [Set.mem_set_of_eq] at hS 
          rw [Set.mem_set_of_eq, hc, hS, sieve.pullback_top],
    transitive' :=
      fun X S hS R hR =>
        by 
          rw [Set.mem_set_of_eq] at hS 
          rw [Set.mem_set_of_eq, ←(c X).idempotent, eq_top_iff, ←hS]
          apply (c X).Monotone fun Y f hf => _ 
          rw [sieve.pullback_eq_top_iff_mem, ←hc]
          apply hR hf }

/--
The topology given by the closure operator `J.close` on a Grothendieck topology is the same as `J`.
-/
theorem topology_of_closure_operator_self :
  (topology_of_closure_operator J₁.closure_operator fun X Y => J₁.pullback_close) = J₁ :=
  by 
    ext X S 
    apply grothendieck_topology.close_eq_top_iff_mem

theorem topology_of_closure_operator_close (c : ∀ (X : C), ClosureOperator (sieve X))
  (pb : ∀ ⦃X Y : C⦄ (f : Y ⟶ X) (S : sieve X), c Y (S.pullback f) = (c X S).pullback f) (X : C) (S : sieve X) :
  (topology_of_closure_operator c pb).close S = c X S :=
  by 
    ext 
    change c _ (sieve.pullback f S) = ⊤ ↔ c _ S f 
    rw [pb, sieve.pullback_eq_top_iff_mem]

end CategoryTheory

