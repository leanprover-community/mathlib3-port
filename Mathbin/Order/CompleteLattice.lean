import Mathbin.Order.Bounds 
import Mathbin.Data.Set.Bool 
import Mathbin.Data.Nat.Basic

/-!
# Theory of complete lattices

## Main definitions

* `Sup` and `Inf` are the supremum and the infimum of a set;
* `supr (f : ι → α)` and `infi (f : ι → α)` are indexed supremum and infimum of a function,
  defined as `Sup` and `Inf` of the range of this function;
* `class complete_lattice`: a bounded lattice such that `Sup s` is always the least upper boundary
  of `s` and `Inf s` is always the greatest lower boundary of `s`;
* `class complete_linear_order`: a linear ordered complete lattice.

## Naming conventions

We use `Sup`/`Inf`/`supr`/`infi` for the corresponding functions in the statement. Sometimes we
also use `bsupr`/`binfi` for "bounded" supremum or infimum, i.e. one of `⨆ i ∈ s, f i`,
`⨆ i (hi : p i), f i`, or more generally `⨆ i (hi : p i), f i hi`.

## Notation

* `⨆ i, f i` : `supr f`, the supremum of the range of `f`;
* `⨅ i, f i` : `infi f`, the infimum of the range of `f`.
-/


open Set

variable{α β β₂ : Type _}{ι ι₂ : Sort _}

/-- class for the `Sup` operator -/
class HasSupₓ(α : Type _) where 
  sup : Set α → α

/-- class for the `Inf` operator -/
class HasInfₓ(α : Type _) where 
  inf : Set α → α

export HasSupₓ(sup)

export HasInfₓ(inf)

/-- Supremum of a set -/
add_decl_doc HasSupₓ.sup

/-- Infimum of a set -/
add_decl_doc HasInfₓ.inf

/-- Indexed supremum -/
def supr [HasSupₓ α] {ι} (s : ι → α) : α :=
  Sup (range s)

/-- Indexed infimum -/
def infi [HasInfₓ α] {ι} (s : ι → α) : α :=
  Inf (range s)

instance (priority := 50)has_Inf_to_nonempty α [HasInfₓ α] : Nonempty α :=
  ⟨Inf ∅⟩

instance (priority := 50)has_Sup_to_nonempty α [HasSupₓ α] : Nonempty α :=
  ⟨Sup ∅⟩

notation3  "⨆" (...) ", " r:(scoped f => supr f) => r

notation3  "⨅" (...) ", " r:(scoped f => infi f) => r

instance  α [HasInfₓ α] : HasSupₓ (OrderDual α) :=
  ⟨(Inf : Set α → α)⟩

instance  α [HasSupₓ α] : HasInfₓ (OrderDual α) :=
  ⟨(Sup : Set α → α)⟩

/--
Note that we rarely use `complete_semilattice_Sup`
(in fact, any such object is always a `complete_lattice`, so it's usually best to start there).

Nevertheless it is sometimes a useful intermediate step in constructions.
-/
@[ancestor PartialOrderₓ HasSupₓ]
class CompleteSemilatticeSup(α : Type _) extends PartialOrderₓ α, HasSupₓ α where 
  le_Sup : ∀ s, ∀ a (_ : a ∈ s), a ≤ Sup s 
  Sup_le : ∀ s a, (∀ b (_ : b ∈ s), b ≤ a) → Sup s ≤ a

section 

variable[CompleteSemilatticeSup α]{s t : Set α}{a b : α}

@[ematch]
theorem le_Sup : a ∈ s → a ≤ Sup s :=
  CompleteSemilatticeSup.le_Sup s a

theorem Sup_le : (∀ b (_ : b ∈ s), b ≤ a) → Sup s ≤ a :=
  CompleteSemilatticeSup.Sup_le s a

theorem is_lub_Sup (s : Set α) : IsLub s (Sup s) :=
  ⟨fun x => le_Sup, fun x => Sup_le⟩

theorem IsLub.Sup_eq (h : IsLub s a) : Sup s = a :=
  (is_lub_Sup s).unique h

theorem le_Sup_of_le (hb : b ∈ s) (h : a ≤ b) : a ≤ Sup s :=
  le_transₓ h (le_Sup hb)

theorem Sup_le_Sup (h : s ⊆ t) : Sup s ≤ Sup t :=
  (is_lub_Sup s).mono (is_lub_Sup t) h

@[simp]
theorem Sup_le_iff : Sup s ≤ a ↔ ∀ b (_ : b ∈ s), b ≤ a :=
  is_lub_le_iff (is_lub_Sup s)

theorem le_Sup_iff : a ≤ Sup s ↔ ∀ b, (∀ x (_ : x ∈ s), x ≤ b) → a ≤ b :=
  ⟨fun h b hb => le_transₓ h (Sup_le hb), fun hb => hb _ fun x => le_Sup⟩

-- error in Order.CompleteLattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Meta.solveByElim'
theorem Sup_le_Sup_of_forall_exists_le
(h : ∀ x «expr ∈ » s, «expr∃ , »((y «expr ∈ » t), «expr ≤ »(x, y))) : «expr ≤ »(Sup s, Sup t) :=
le_of_forall_le' (begin
   simp [] [] ["only"] ["[", expr Sup_le_iff, "]"] [] [],
   introv [ident h₀, ident h₁],
   rcases [expr h _ h₁, "with", "⟨", ident y, ",", ident hy, ",", ident hy', "⟩"],
   solve_by_elim [] [] ["[", expr le_trans hy', "]"] []
 end)

theorem Sup_singleton {a : α} : Sup {a} = a :=
  is_lub_singleton.Sup_eq

end 

/--
Note that we rarely use `complete_semilattice_Inf`
(in fact, any such object is always a `complete_lattice`, so it's usually best to start there).

Nevertheless it is sometimes a useful intermediate step in constructions.
-/
@[ancestor PartialOrderₓ HasInfₓ]
class CompleteSemilatticeInf(α : Type _) extends PartialOrderₓ α, HasInfₓ α where 
  Inf_le : ∀ s, ∀ a (_ : a ∈ s), Inf s ≤ a 
  le_Inf : ∀ s a, (∀ b (_ : b ∈ s), a ≤ b) → a ≤ Inf s

section 

variable[CompleteSemilatticeInf α]{s t : Set α}{a b : α}

@[ematch]
theorem Inf_le : a ∈ s → Inf s ≤ a :=
  CompleteSemilatticeInf.Inf_le s a

theorem le_Inf : (∀ b (_ : b ∈ s), a ≤ b) → a ≤ Inf s :=
  CompleteSemilatticeInf.le_Inf s a

theorem is_glb_Inf (s : Set α) : IsGlb s (Inf s) :=
  ⟨fun a => Inf_le, fun a => le_Inf⟩

theorem IsGlb.Inf_eq (h : IsGlb s a) : Inf s = a :=
  (is_glb_Inf s).unique h

theorem Inf_le_of_le (hb : b ∈ s) (h : b ≤ a) : Inf s ≤ a :=
  le_transₓ (Inf_le hb) h

theorem Inf_le_Inf (h : s ⊆ t) : Inf t ≤ Inf s :=
  (is_glb_Inf s).mono (is_glb_Inf t) h

@[simp]
theorem le_Inf_iff : a ≤ Inf s ↔ ∀ b (_ : b ∈ s), a ≤ b :=
  le_is_glb_iff (is_glb_Inf s)

theorem Inf_le_iff : Inf s ≤ a ↔ ∀ b, (∀ x (_ : x ∈ s), b ≤ x) → b ≤ a :=
  ⟨fun h b hb => le_transₓ (le_Inf hb) h, fun hb => hb _ fun x => Inf_le⟩

-- error in Order.CompleteLattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Meta.solveByElim'
theorem Inf_le_Inf_of_forall_exists_le
(h : ∀ x «expr ∈ » s, «expr∃ , »((y «expr ∈ » t), «expr ≤ »(y, x))) : «expr ≤ »(Inf t, Inf s) :=
le_of_forall_le (begin
   simp [] [] ["only"] ["[", expr le_Inf_iff, "]"] [] [],
   introv [ident h₀, ident h₁],
   rcases [expr h _ h₁, "with", "⟨", ident y, ",", ident hy, ",", ident hy', "⟩"],
   solve_by_elim [] [] ["[", expr le_trans _ hy', "]"] []
 end)

theorem Inf_singleton {a : α} : Inf {a} = a :=
  is_glb_singleton.Inf_eq

end 

/-- A complete lattice is a bounded lattice which
  has suprema and infima for every subset. -/
@[protectProj, ancestor Lattice CompleteSemilatticeSup CompleteSemilatticeInf HasTop HasBot]
class CompleteLattice(α : Type _) extends Lattice α, CompleteSemilatticeSup α, CompleteSemilatticeInf α, HasTop α,
  HasBot α where 
  le_top : ∀ (x : α), x ≤ ⊤
  bot_le : ∀ (x : α), ⊥ ≤ x

instance (priority := 100)CompleteLattice.toBoundedOrder [h : CompleteLattice α] : BoundedOrder α :=
  { h with  }

/-- Create a `complete_lattice` from a `partial_order` and `Inf` function
that returns the greatest lower bound of a set. Usually this constructor provides
poor definitional equalities.  If other fields are known explicitly, they should be
provided; for example, if `inf` is known explicitly, construct the `complete_lattice`
instance as
```
instance : complete_lattice my_T :=
{ inf := better_inf,
  le_inf := ...,
  inf_le_right := ...,
  inf_le_left := ...
  -- don't care to fix sup, Sup, bot, top
  ..complete_lattice_of_Inf my_T _ }
```
-/
def completeLatticeOfInf (α : Type _) [H1 : PartialOrderₓ α] [H2 : HasInfₓ α]
  (is_glb_Inf : ∀ (s : Set α), IsGlb s (Inf s)) : CompleteLattice α :=
  { H1, H2 with bot := Inf univ, bot_le := fun x => (is_glb_Inf univ).1 trivialₓ, top := Inf ∅,
    le_top :=
      fun a =>
        (is_glb_Inf ∅).2$
          by 
            simp ,
    sup := fun a b => Inf { x | a ≤ x ∧ b ≤ x }, inf := fun a b => Inf {a, b},
    le_inf :=
      fun a b c hab hac =>
        by 
          apply (is_glb_Inf _).2
          simp ,
    inf_le_right := fun a b => (is_glb_Inf _).1$ mem_insert_of_mem _$ mem_singleton _,
    inf_le_left := fun a b => (is_glb_Inf _).1$ mem_insert _ _,
    sup_le :=
      fun a b c hac hbc =>
        (is_glb_Inf _).1$
          by 
            simp ,
    le_sup_left := fun a b => (is_glb_Inf _).2$ fun x => And.left,
    le_sup_right := fun a b => (is_glb_Inf _).2$ fun x => And.right, le_Inf := fun s a ha => (is_glb_Inf s).2 ha,
    Inf_le := fun s a ha => (is_glb_Inf s).1 ha, sup := fun s => Inf (UpperBounds s),
    le_Sup := fun s a ha => (is_glb_Inf (UpperBounds s)).2$ fun b hb => hb ha,
    Sup_le := fun s a ha => (is_glb_Inf (UpperBounds s)).1 ha }

/--
Any `complete_semilattice_Inf` is in fact a `complete_lattice`.

Note that this construction has bad definitional properties:
see the doc-string on `complete_lattice_of_Inf`.
-/
def completeLatticeOfCompleteSemilatticeInf (α : Type _) [CompleteSemilatticeInf α] : CompleteLattice α :=
  completeLatticeOfInf α fun s => is_glb_Inf s

/-- Create a `complete_lattice` from a `partial_order` and `Sup` function
that returns the least upper bound of a set. Usually this constructor provides
poor definitional equalities.  If other fields are known explicitly, they should be
provided; for example, if `inf` is known explicitly, construct the `complete_lattice`
instance as
```
instance : complete_lattice my_T :=
{ inf := better_inf,
  le_inf := ...,
  inf_le_right := ...,
  inf_le_left := ...
  -- don't care to fix sup, Inf, bot, top
  ..complete_lattice_of_Sup my_T _ }
```
-/
def completeLatticeOfSup (α : Type _) [H1 : PartialOrderₓ α] [H2 : HasSupₓ α]
  (is_lub_Sup : ∀ (s : Set α), IsLub s (Sup s)) : CompleteLattice α :=
  { H1, H2 with top := Sup univ, le_top := fun x => (is_lub_Sup univ).1 trivialₓ, bot := Sup ∅,
    bot_le :=
      fun x =>
        (is_lub_Sup ∅).2$
          by 
            simp ,
    sup := fun a b => Sup {a, b},
    sup_le :=
      fun a b c hac hbc =>
        (is_lub_Sup _).2
          (by 
            simp ),
    le_sup_left := fun a b => (is_lub_Sup _).1$ mem_insert _ _,
    le_sup_right := fun a b => (is_lub_Sup _).1$ mem_insert_of_mem _$ mem_singleton _,
    inf := fun a b => Sup { x | x ≤ a ∧ x ≤ b },
    le_inf :=
      fun a b c hab hac =>
        (is_lub_Sup _).1$
          by 
            simp ,
    inf_le_left := fun a b => (is_lub_Sup _).2 fun x => And.left,
    inf_le_right := fun a b => (is_lub_Sup _).2 fun x => And.right, inf := fun s => Sup (LowerBounds s),
    Sup_le := fun s a ha => (is_lub_Sup s).2 ha, le_Sup := fun s a ha => (is_lub_Sup s).1 ha,
    Inf_le := fun s a ha => (is_lub_Sup (LowerBounds s)).2 fun b hb => hb ha,
    le_Inf := fun s a ha => (is_lub_Sup (LowerBounds s)).1 ha }

/--
Any `complete_semilattice_Sup` is in fact a `complete_lattice`.

Note that this construction has bad definitional properties:
see the doc-string on `complete_lattice_of_Sup`.
-/
def completeLatticeOfCompleteSemilatticeSup (α : Type _) [CompleteSemilatticeSup α] : CompleteLattice α :=
  completeLatticeOfSup α fun s => is_lub_Sup s

/-- A complete linear order is a linear order whose lattice structure is complete. -/
class CompleteLinearOrder(α : Type _) extends CompleteLattice α, LinearOrderₓ α

namespace OrderDual

variable(α)

instance  [CompleteLattice α] : CompleteLattice (OrderDual α) :=
  { OrderDual.lattice α, OrderDual.hasSupₓ α, OrderDual.hasInfₓ α, OrderDual.boundedOrder α with
    le_Sup := @CompleteLattice.Inf_le α _, Sup_le := @CompleteLattice.le_Inf α _, Inf_le := @CompleteLattice.le_Sup α _,
    le_Inf := @CompleteLattice.Sup_le α _ }

instance  [CompleteLinearOrder α] : CompleteLinearOrder (OrderDual α) :=
  { OrderDual.completeLattice α, OrderDual.linearOrder α with  }

end OrderDual

section 

variable[CompleteLattice α]{s t : Set α}{a b : α}

theorem Inf_le_Sup (hs : s.nonempty) : Inf s ≤ Sup s :=
  is_glb_le_is_lub (is_glb_Inf s) (is_lub_Sup s) hs

theorem Sup_union {s t : Set α} : Sup (s ∪ t) = Sup s⊔Sup t :=
  ((is_lub_Sup s).union (is_lub_Sup t)).Sup_eq

theorem Sup_inter_le {s t : Set α} : Sup (s ∩ t) ≤ Sup s⊓Sup t :=
  by 
    finish

theorem Inf_union {s t : Set α} : Inf (s ∪ t) = Inf s⊓Inf t :=
  ((is_glb_Inf s).union (is_glb_Inf t)).Inf_eq

theorem le_Inf_inter {s t : Set α} : Inf s⊔Inf t ≤ Inf (s ∩ t) :=
  @Sup_inter_le (OrderDual α) _ _ _

@[simp]
theorem Sup_empty : Sup ∅ = (⊥ : α) :=
  (@is_lub_empty α _ _).Sup_eq

@[simp]
theorem Inf_empty : Inf ∅ = (⊤ : α) :=
  (@is_glb_empty α _ _).Inf_eq

@[simp]
theorem Sup_univ : Sup univ = (⊤ : α) :=
  (@is_lub_univ α _ _).Sup_eq

@[simp]
theorem Inf_univ : Inf univ = (⊥ : α) :=
  (@is_glb_univ α _ _).Inf_eq

@[simp]
theorem Sup_insert {a : α} {s : Set α} : Sup (insert a s) = a⊔Sup s :=
  ((is_lub_Sup s).insert a).Sup_eq

@[simp]
theorem Inf_insert {a : α} {s : Set α} : Inf (insert a s) = a⊓Inf s :=
  ((is_glb_Inf s).insert a).Inf_eq

theorem Sup_le_Sup_of_subset_insert_bot (h : s ⊆ insert ⊥ t) : Sup s ≤ Sup t :=
  le_transₓ (Sup_le_Sup h) (le_of_eqₓ (trans Sup_insert bot_sup_eq))

theorem Inf_le_Inf_of_subset_insert_top (h : s ⊆ insert ⊤ t) : Inf t ≤ Inf s :=
  le_transₓ (le_of_eqₓ (trans top_inf_eq.symm Inf_insert.symm)) (Inf_le_Inf h)

theorem Sup_pair {a b : α} : Sup {a, b} = a⊔b :=
  (@is_lub_pair α _ a b).Sup_eq

theorem Inf_pair {a b : α} : Inf {a, b} = a⊓b :=
  (@is_glb_pair α _ a b).Inf_eq

@[simp]
theorem Inf_eq_top : Inf s = ⊤ ↔ ∀ a (_ : a ∈ s), a = ⊤ :=
  Iff.intro (fun h a ha => top_unique$ h ▸ Inf_le ha) fun h => top_unique$ le_Inf$ fun a ha => top_le_iff.2$ h a ha

theorem eq_singleton_top_of_Inf_eq_top_of_nonempty {s : Set α} (h_inf : Inf s = ⊤) (hne : s.nonempty) : s = {⊤} :=
  by 
    rw [Set.eq_singleton_iff_nonempty_unique_mem]
    rw [Inf_eq_top] at h_inf 
    exact ⟨hne, h_inf⟩

@[simp]
theorem Sup_eq_bot : Sup s = ⊥ ↔ ∀ a (_ : a ∈ s), a = ⊥ :=
  @Inf_eq_top (OrderDual α) _ _

theorem eq_singleton_bot_of_Sup_eq_bot_of_nonempty {s : Set α} (h_sup : Sup s = ⊥) (hne : s.nonempty) : s = {⊥} :=
  by 
    rw [Set.eq_singleton_iff_nonempty_unique_mem]
    rw [Sup_eq_bot] at h_sup 
    exact ⟨hne, h_sup⟩

/--Introduction rule to prove that `b` is the supremum of `s`: it suffices to check that `b`
is larger than all elements of `s`, and that this is not the case of any `w<b`.
See `cSup_eq_of_forall_le_of_forall_lt_exists_gt` for a version in conditionally complete
lattices. -/
theorem Sup_eq_of_forall_le_of_forall_lt_exists_gt (_ : ∀ a (_ : a ∈ s), a ≤ b)
  (H : ∀ w, w < b → ∃ (a : _)(_ : a ∈ s), w < a) : Sup s = b :=
  have  : Sup s < b ∨ Sup s = b := lt_or_eq_of_leₓ (Sup_le ‹∀ a (_ : a ∈ s), a ≤ b›)
  have  : ¬Sup s < b :=
    fun this : Sup s < b =>
      let ⟨a, _, _⟩ := H (Sup s) ‹Sup s < b›
      have  : Sup s < Sup s := lt_of_lt_of_leₓ ‹Sup s < a› (le_Sup ‹a ∈ s›)
      show False by 
        finish [lt_irreflₓ (Sup s)]
  show Sup s = b by 
    finish

/--Introduction rule to prove that `b` is the infimum of `s`: it suffices to check that `b`
is smaller than all elements of `s`, and that this is not the case of any `w>b`.
See `cInf_eq_of_forall_ge_of_forall_gt_exists_lt` for a version in conditionally complete
lattices. -/
theorem Inf_eq_of_forall_ge_of_forall_gt_exists_lt (_ : ∀ a (_ : a ∈ s), b ≤ a)
  (H : ∀ w, b < w → ∃ (a : _)(_ : a ∈ s), a < w) : Inf s = b :=
  @Sup_eq_of_forall_le_of_forall_lt_exists_gt (OrderDual α) _ _ ‹_› ‹_› ‹_›

end 

section CompleteLinearOrder

variable[CompleteLinearOrder α]{s t : Set α}{a b : α}

theorem Inf_lt_iff : Inf s < b ↔ ∃ (a : _)(_ : a ∈ s), a < b :=
  is_glb_lt_iff (is_glb_Inf s)

theorem lt_Sup_iff : b < Sup s ↔ ∃ (a : _)(_ : a ∈ s), b < a :=
  lt_is_lub_iff (is_lub_Sup s)

-- error in Order.CompleteLattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem Sup_eq_top : «expr ↔ »(«expr = »(Sup s, «expr⊤»()), ∀
 b «expr < » «expr⊤»(), «expr∃ , »((a «expr ∈ » s), «expr < »(b, a))) :=
iff.intro (assume
 (h : «expr = »(Sup s, «expr⊤»()))
 (b
  hb), by rwa ["[", "<-", expr h, ",", expr lt_Sup_iff, "]"] ["at", ident hb]) (assume
 h, «expr $ »(top_unique, «expr $ »(le_of_not_gt, assume h', let ⟨a, ha, h⟩ := h _ h' in
   «expr $ »(lt_irrefl a, lt_of_le_of_lt (le_Sup ha) h))))

theorem Inf_eq_bot : Inf s = ⊥ ↔ ∀ b (_ : b > ⊥), ∃ (a : _)(_ : a ∈ s), a < b :=
  @Sup_eq_top (OrderDual α) _ _

theorem lt_supr_iff {f : ι → α} : a < supr f ↔ ∃ i, a < f i :=
  lt_Sup_iff.trans exists_range_iff

theorem infi_lt_iff {f : ι → α} : infi f < a ↔ ∃ i, f i < a :=
  Inf_lt_iff.trans exists_range_iff

end CompleteLinearOrder

section 

variable[CompleteLattice α]{s t : ι → α}{a b : α}

theorem le_supr (s : ι → α) (i : ι) : s i ≤ supr s :=
  le_Sup ⟨i, rfl⟩

@[ematch]
theorem le_supr' (s : ι → α) (i : ι) : s i ≤ supr s :=
  le_Sup ⟨i, rfl⟩

theorem is_lub_supr : IsLub (range s) (⨆j, s j) :=
  is_lub_Sup _

theorem IsLub.supr_eq (h : IsLub (range s) a) : (⨆j, s j) = a :=
  h.Sup_eq

theorem is_glb_infi : IsGlb (range s) (⨅j, s j) :=
  is_glb_Inf _

theorem IsGlb.infi_eq (h : IsGlb (range s) a) : (⨅j, s j) = a :=
  h.Inf_eq

theorem le_supr_of_le (i : ι) (h : a ≤ s i) : a ≤ supr s :=
  le_transₓ h (le_supr _ i)

theorem le_bsupr {p : ι → Prop} {f : ∀ i (h : p i), α} (i : ι) (hi : p i) : f i hi ≤ ⨆i hi, f i hi :=
  le_supr_of_le i$ le_supr (f i) hi

theorem le_bsupr_of_le {p : ι → Prop} {f : ∀ i (h : p i), α} (i : ι) (hi : p i) (h : a ≤ f i hi) : a ≤ ⨆i hi, f i hi :=
  le_transₓ h (le_bsupr i hi)

theorem supr_le (h : ∀ i, s i ≤ a) : supr s ≤ a :=
  Sup_le$ fun b ⟨i, Eq⟩ => Eq ▸ h i

theorem bsupr_le {p : ι → Prop} {f : ∀ i (h : p i), α} (h : ∀ i hi, f i hi ≤ a) : (⨆(i : _)(hi : p i), f i hi) ≤ a :=
  supr_le$ fun i => supr_le$ h i

theorem bsupr_le_supr (p : ι → Prop) (f : ι → α) : (⨆(i : _)(H : p i), f i) ≤ ⨆i, f i :=
  bsupr_le fun i hi => le_supr f i

theorem supr_le_supr (h : ∀ i, s i ≤ t i) : supr s ≤ supr t :=
  supr_le$ fun i => le_supr_of_le i (h i)

theorem supr_le_supr2 {t : ι₂ → α} (h : ∀ i, ∃ j, s i ≤ t j) : supr s ≤ supr t :=
  supr_le$ fun j => Exists.elim (h j) le_supr_of_le

theorem bsupr_le_bsupr {p : ι → Prop} {f g : ∀ i (hi : p i), α} (h : ∀ i hi, f i hi ≤ g i hi) :
  (⨆i hi, f i hi) ≤ ⨆i hi, g i hi :=
  bsupr_le$ fun i hi => le_transₓ (h i hi) (le_bsupr i hi)

theorem supr_le_supr_const (h : ι → ι₂) : (⨆i : ι, a) ≤ ⨆j : ι₂, a :=
  supr_le$ le_supr _ ∘ h

theorem bsupr_le_bsupr' {p q : ι → Prop} (hpq : ∀ i, p i → q i) {f : ι → α} :
  (⨆(i : _)(hpi : p i), f i) ≤ ⨆(i : _)(hqi : q i), f i :=
  supr_le_supr$ fun i => supr_le_supr_const (hpq i)

@[simp]
theorem supr_le_iff : supr s ≤ a ↔ ∀ i, s i ≤ a :=
  (is_lub_le_iff is_lub_supr).trans forall_range_iff

theorem supr_lt_iff : supr s < a ↔ ∃ (b : _)(_ : b < a), ∀ i, s i ≤ b :=
  ⟨fun h => ⟨supr s, h, fun i => le_supr s i⟩, fun ⟨b, hba, hsb⟩ => (supr_le hsb).trans_lt hba⟩

theorem Sup_eq_supr {s : Set α} : Sup s = ⨆(a : _)(_ : a ∈ s), a :=
  le_antisymmₓ (Sup_le$ fun b h => le_supr_of_le b$ le_supr _ h) (supr_le$ fun b => supr_le$ fun h => le_Sup h)

theorem Sup_eq_supr' {α} [HasSupₓ α] (s : Set α) : Sup s = ⨆x : s, (x : α) :=
  by 
    rw [supr, Subtype.range_coe]

theorem Sup_sUnion {s : Set (Set α)} : Sup (⋃₀s) = ⨆(t : _)(_ : t ∈ s), Sup t :=
  by 
    apply le_antisymmₓ
    ·
      apply Sup_le fun b hb => _ 
      rcases hb with ⟨t, ts, bt⟩
      apply le_transₓ _ (le_supr _ t)
      exact le_transₓ (le_Sup bt) (le_supr _ ts)
    ·
      apply supr_le fun t => _ 
      exact supr_le fun ts => Sup_le_Sup fun x xt => ⟨t, ts, xt⟩

theorem le_supr_iff : a ≤ supr s ↔ ∀ b, (∀ i, s i ≤ b) → a ≤ b :=
  ⟨fun h b hb => le_transₓ h (supr_le hb), fun h => h _$ fun i => le_supr s i⟩

theorem Monotone.le_map_supr [CompleteLattice β] {f : α → β} (hf : Monotone f) : (⨆i, f (s i)) ≤ f (supr s) :=
  supr_le$ fun i => hf$ le_supr _ _

theorem Monotone.le_map_supr2 [CompleteLattice β] {f : α → β} (hf : Monotone f) {ι' : ι → Sort _} (s : ∀ i, ι' i → α) :
  (⨆(i : _)(h : ι' i), f (s i h)) ≤ f (⨆(i : _)(h : ι' i), s i h) :=
  calc (⨆i h, f (s i h)) ≤ ⨆i, f (⨆h, s i h) := supr_le_supr$ fun i => hf.le_map_supr 
    _ ≤ f (⨆(i : _)(h : ι' i), s i h) := hf.le_map_supr
    

theorem Monotone.le_map_Sup [CompleteLattice β] {s : Set α} {f : α → β} (hf : Monotone f) :
  (⨆(a : _)(_ : a ∈ s), f a) ≤ f (Sup s) :=
  by 
    rw [Sup_eq_supr] <;> exact hf.le_map_supr2 _

theorem supr_comp_le {ι' : Sort _} (f : ι' → α) (g : ι → ι') : (⨆x, f (g x)) ≤ ⨆y, f y :=
  supr_le_supr2$ fun x => ⟨_, le_reflₓ _⟩

theorem Monotone.supr_comp_eq [Preorderₓ β] {f : β → α} (hf : Monotone f) {s : ι → β} (hs : ∀ x, ∃ i, x ≤ s i) :
  (⨆x, f (s x)) = ⨆y, f y :=
  le_antisymmₓ (supr_comp_le _ _) (supr_le_supr2$ fun x => (hs x).imp$ fun i hi => hf hi)

theorem Function.Surjective.supr_comp {α : Type _} [HasSupₓ α] {f : ι → ι₂} (hf : Function.Surjective f) (g : ι₂ → α) :
  (⨆x, g (f x)) = ⨆y, g y :=
  by 
    simp only [supr, hf.range_comp]

theorem supr_congr {α : Type _} [HasSupₓ α] {f : ι → α} {g : ι₂ → α} (h : ι → ι₂) (h1 : Function.Surjective h)
  (h2 : ∀ x, g (h x) = f x) : (⨆x, f x) = ⨆y, g y :=
  by 
    convert h1.supr_comp g 
    exact (funext h2).symm

-- error in Order.CompleteLattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[congr]
theorem supr_congr_Prop
{α : Type*}
[has_Sup α]
{p q : exprProp()}
{f₁ : p → α}
{f₂ : q → α}
(pq : «expr ↔ »(p, q))
(f : ∀ x, «expr = »(f₁ (pq.mpr x), f₂ x)) : «expr = »(supr f₁, supr f₂) :=
begin
  have [] [] [":=", expr propext pq],
  subst [expr this],
  congr' [] ["with", ident x],
  apply [expr f]
end

theorem infi_le (s : ι → α) (i : ι) : infi s ≤ s i :=
  Inf_le ⟨i, rfl⟩

@[ematch]
theorem infi_le' (s : ι → α) (i : ι) : infi s ≤ s i :=
  Inf_le ⟨i, rfl⟩

theorem infi_le_of_le (i : ι) (h : s i ≤ a) : infi s ≤ a :=
  le_transₓ (infi_le _ i) h

theorem binfi_le {p : ι → Prop} {f : ∀ i (hi : p i), α} (i : ι) (hi : p i) : (⨅i hi, f i hi) ≤ f i hi :=
  infi_le_of_le i$ infi_le (f i) hi

theorem binfi_le_of_le {p : ι → Prop} {f : ∀ i (hi : p i), α} (i : ι) (hi : p i) (h : f i hi ≤ a) :
  (⨅i hi, f i hi) ≤ a :=
  le_transₓ (binfi_le i hi) h

theorem le_infi (h : ∀ i, a ≤ s i) : a ≤ infi s :=
  le_Inf$ fun b ⟨i, Eq⟩ => Eq ▸ h i

theorem le_binfi {p : ι → Prop} {f : ∀ i (h : p i), α} (h : ∀ i hi, a ≤ f i hi) : a ≤ ⨅i hi, f i hi :=
  le_infi$ fun i => le_infi$ h i

theorem infi_le_binfi (p : ι → Prop) (f : ι → α) : (⨅i, f i) ≤ ⨅(i : _)(H : p i), f i :=
  le_binfi fun i hi => infi_le f i

theorem infi_le_infi (h : ∀ i, s i ≤ t i) : infi s ≤ infi t :=
  le_infi$ fun i => infi_le_of_le i (h i)

theorem infi_le_infi2 {t : ι₂ → α} (h : ∀ j, ∃ i, s i ≤ t j) : infi s ≤ infi t :=
  le_infi$ fun j => Exists.elim (h j) infi_le_of_le

theorem binfi_le_binfi {p : ι → Prop} {f g : ∀ i (h : p i), α} (h : ∀ i hi, f i hi ≤ g i hi) :
  (⨅i hi, f i hi) ≤ ⨅i hi, g i hi :=
  le_binfi$ fun i hi => le_transₓ (binfi_le i hi) (h i hi)

theorem infi_le_infi_const (h : ι₂ → ι) : (⨅i : ι, a) ≤ ⨅j : ι₂, a :=
  le_infi$ infi_le _ ∘ h

@[simp]
theorem le_infi_iff : a ≤ infi s ↔ ∀ i, a ≤ s i :=
  ⟨fun this : a ≤ infi s => fun i => le_transₓ this (infi_le _ _), le_infi⟩

theorem Inf_eq_infi {s : Set α} : Inf s = ⨅(a : _)(_ : a ∈ s), a :=
  @Sup_eq_supr (OrderDual α) _ _

theorem Inf_eq_infi' {α} [HasInfₓ α] (s : Set α) : Inf s = ⨅a : s, a :=
  @Sup_eq_supr' (OrderDual α) _ _

theorem Monotone.map_infi_le [CompleteLattice β] {f : α → β} (hf : Monotone f) : f (infi s) ≤ ⨅i, f (s i) :=
  le_infi$ fun i => hf$ infi_le _ _

theorem Monotone.map_infi2_le [CompleteLattice β] {f : α → β} (hf : Monotone f) {ι' : ι → Sort _} (s : ∀ i, ι' i → α) :
  f (⨅(i : _)(h : ι' i), s i h) ≤ ⨅(i : _)(h : ι' i), f (s i h) :=
  @Monotone.le_map_supr2 (OrderDual α) (OrderDual β) _ _ _ f hf.dual _ _

theorem Monotone.map_Inf_le [CompleteLattice β] {s : Set α} {f : α → β} (hf : Monotone f) :
  f (Inf s) ≤ ⨅(a : _)(_ : a ∈ s), f a :=
  by 
    rw [Inf_eq_infi] <;> exact hf.map_infi2_le _

theorem le_infi_comp {ι' : Sort _} (f : ι' → α) (g : ι → ι') : (⨅y, f y) ≤ ⨅x, f (g x) :=
  infi_le_infi2$ fun x => ⟨_, le_reflₓ _⟩

theorem Monotone.infi_comp_eq [Preorderₓ β] {f : β → α} (hf : Monotone f) {s : ι → β} (hs : ∀ x, ∃ i, s i ≤ x) :
  (⨅x, f (s x)) = ⨅y, f y :=
  le_antisymmₓ (infi_le_infi2$ fun x => (hs x).imp$ fun i hi => hf hi) (le_infi_comp _ _)

theorem Function.Surjective.infi_comp {α : Type _} [HasInfₓ α] {f : ι → ι₂} (hf : Function.Surjective f) (g : ι₂ → α) :
  (⨅x, g (f x)) = ⨅y, g y :=
  @Function.Surjective.supr_comp _ _ (OrderDual α) _ f hf g

theorem infi_congr {α : Type _} [HasInfₓ α] {f : ι → α} {g : ι₂ → α} (h : ι → ι₂) (h1 : Function.Surjective h)
  (h2 : ∀ x, g (h x) = f x) : (⨅x, f x) = ⨅y, g y :=
  @supr_congr _ _ (OrderDual α) _ _ _ h h1 h2

@[congr]
theorem infi_congr_Prop {α : Type _} [HasInfₓ α] {p q : Prop} {f₁ : p → α} {f₂ : q → α} (pq : p ↔ q)
  (f : ∀ x, f₁ (pq.mpr x) = f₂ x) : infi f₁ = infi f₂ :=
  @supr_congr_Prop (OrderDual α) _ p q f₁ f₂ pq f

theorem supr_const_le {x : α} : (⨆h : ι, x) ≤ x :=
  supr_le fun _ => le_rfl

theorem le_infi_const {x : α} : x ≤ ⨅h : ι, x :=
  le_infi fun _ => le_rfl

theorem infi_const [Nonempty ι] {a : α} : (⨅b : ι, a) = a :=
  by 
    rw [infi, range_const, Inf_singleton]

theorem supr_const [Nonempty ι] {a : α} : (⨆b : ι, a) = a :=
  @infi_const (OrderDual α) _ _ _ _

@[simp]
theorem infi_top : (⨅i : ι, ⊤ : α) = ⊤ :=
  top_unique$ le_infi$ fun i => le_reflₓ _

@[simp]
theorem supr_bot : (⨆i : ι, ⊥ : α) = ⊥ :=
  @infi_top (OrderDual α) _ _

@[simp]
theorem infi_eq_top : infi s = ⊤ ↔ ∀ i, s i = ⊤ :=
  Inf_eq_top.trans forall_range_iff

@[simp]
theorem supr_eq_bot : supr s = ⊥ ↔ ∀ i, s i = ⊥ :=
  Sup_eq_bot.trans forall_range_iff

@[simp]
theorem infi_pos {p : Prop} {f : p → α} (hp : p) : (⨅h : p, f h) = f hp :=
  le_antisymmₓ (infi_le _ _) (le_infi$ fun h => le_reflₓ _)

@[simp]
theorem infi_neg {p : Prop} {f : p → α} (hp : ¬p) : (⨅h : p, f h) = ⊤ :=
  le_antisymmₓ le_top$ le_infi$ fun h => (hp h).elim

@[simp]
theorem supr_pos {p : Prop} {f : p → α} (hp : p) : (⨆h : p, f h) = f hp :=
  le_antisymmₓ (supr_le$ fun h => le_reflₓ _) (le_supr _ _)

@[simp]
theorem supr_neg {p : Prop} {f : p → α} (hp : ¬p) : (⨆h : p, f h) = ⊥ :=
  le_antisymmₓ (supr_le$ fun h => (hp h).elim) bot_le

/--Introduction rule to prove that `b` is the supremum of `f`: it suffices to check that `b`
is larger than `f i` for all `i`, and that this is not the case of any `w<b`.
See `csupr_eq_of_forall_le_of_forall_lt_exists_gt` for a version in conditionally complete
lattices. -/
theorem supr_eq_of_forall_le_of_forall_lt_exists_gt {f : ι → α} (h₁ : ∀ i, f i ≤ b) (h₂ : ∀ w, w < b → ∃ i, w < f i) :
  (⨆i : ι, f i) = b :=
  Sup_eq_of_forall_le_of_forall_lt_exists_gt (forall_range_iff.mpr h₁) fun w hw => exists_range_iff.mpr$ h₂ w hw

/--Introduction rule to prove that `b` is the infimum of `f`: it suffices to check that `b`
is smaller than `f i` for all `i`, and that this is not the case of any `w>b`.
See `cinfi_eq_of_forall_ge_of_forall_gt_exists_lt` for a version in conditionally complete
lattices. -/
theorem infi_eq_of_forall_ge_of_forall_gt_exists_lt {f : ι → α} (h₁ : ∀ i, b ≤ f i) (h₂ : ∀ w, b < w → ∃ i, f i < w) :
  (⨅i : ι, f i) = b :=
  @supr_eq_of_forall_le_of_forall_lt_exists_gt (OrderDual α) _ _ _ ‹_› ‹_› ‹_›

theorem supr_eq_dif {p : Prop} [Decidable p] (a : p → α) : (⨆h : p, a h) = if h : p then a h else ⊥ :=
  by 
    byCases' p <;> simp [h]

theorem supr_eq_if {p : Prop} [Decidable p] (a : α) : (⨆h : p, a) = if p then a else ⊥ :=
  supr_eq_dif fun _ => a

theorem infi_eq_dif {p : Prop} [Decidable p] (a : p → α) : (⨅h : p, a h) = if h : p then a h else ⊤ :=
  @supr_eq_dif (OrderDual α) _ _ _ _

theorem infi_eq_if {p : Prop} [Decidable p] (a : α) : (⨅h : p, a) = if p then a else ⊤ :=
  infi_eq_dif fun _ => a

theorem infi_comm {f : ι → ι₂ → α} : (⨅i, ⨅j, f i j) = ⨅j, ⨅i, f i j :=
  le_antisymmₓ (le_infi$ fun i => le_infi$ fun j => infi_le_of_le j$ infi_le _ i)
    (le_infi$ fun j => le_infi$ fun i => infi_le_of_le i$ infi_le _ j)

theorem supr_comm {f : ι → ι₂ → α} : (⨆i, ⨆j, f i j) = ⨆j, ⨆i, f i j :=
  @infi_comm (OrderDual α) _ _ _ _

@[simp]
theorem infi_infi_eq_left {b : β} {f : ∀ (x : β), x = b → α} : (⨅x, ⨅h : x = b, f x h) = f b rfl :=
  le_antisymmₓ (infi_le_of_le b$ infi_le _ rfl)
    (le_infi$
      fun b' =>
        le_infi$
          fun eq =>
            match b', Eq with 
            | _, rfl => le_reflₓ _)

@[simp]
theorem infi_infi_eq_right {b : β} {f : ∀ (x : β), b = x → α} : (⨅x, ⨅h : b = x, f x h) = f b rfl :=
  le_antisymmₓ (infi_le_of_le b$ infi_le _ rfl)
    (le_infi$
      fun b' =>
        le_infi$
          fun eq =>
            match b', Eq with 
            | _, rfl => le_reflₓ _)

@[simp]
theorem supr_supr_eq_left {b : β} {f : ∀ (x : β), x = b → α} : (⨆x, ⨆h : x = b, f x h) = f b rfl :=
  @infi_infi_eq_left (OrderDual α) _ _ _ _

@[simp]
theorem supr_supr_eq_right {b : β} {f : ∀ (x : β), b = x → α} : (⨆x, ⨆h : b = x, f x h) = f b rfl :=
  @infi_infi_eq_right (OrderDual α) _ _ _ _

attribute [ematch] le_reflₓ

theorem infi_subtype {p : ι → Prop} {f : Subtype p → α} : (⨅x, f x) = ⨅(i : _)(h : p i), f ⟨i, h⟩ :=
  le_antisymmₓ (le_infi$ fun i => le_infi$ fun this : p i => infi_le _ _)
    (le_infi$ fun ⟨i, h⟩ => infi_le_of_le i$ infi_le _ _)

theorem infi_subtype' {p : ι → Prop} {f : ∀ i, p i → α} : (⨅(i : _)(h : p i), f i h) = ⨅x : Subtype p, f x x.property :=
  (@infi_subtype _ _ _ p fun x => f x.val x.property).symm

theorem infi_subtype'' {ι} (s : Set ι) (f : ι → α) : (⨅i : s, f i) = ⨅(t : ι)(H : t ∈ s), f t :=
  infi_subtype

theorem infi_inf_eq {f g : ι → α} : (⨅x, f x⊓g x) = (⨅x, f x)⊓⨅x, g x :=
  le_antisymmₓ (le_inf (le_infi$ fun i => infi_le_of_le i inf_le_left) (le_infi$ fun i => infi_le_of_le i inf_le_right))
    (le_infi$ fun i => le_inf (inf_le_of_left_le$ infi_le _ _) (inf_le_of_right_le$ infi_le _ _))

theorem infi_inf [h : Nonempty ι] {f : ι → α} {a : α} : (⨅x, f x)⊓a = ⨅x, f x⊓a :=
  by 
    rw [infi_inf_eq, infi_const]

theorem inf_infi [Nonempty ι] {f : ι → α} {a : α} : (a⊓⨅x, f x) = ⨅x, a⊓f x :=
  by 
    rw [inf_comm, infi_inf] <;> simp [inf_comm]

-- error in Order.CompleteLattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem binfi_inf
{p : ι → exprProp()}
{f : ∀ (i) (hi : p i), α}
{a : α}
(h : «expr∃ , »((i), p i)) : «expr = »(«expr ⊓ »(«expr⨅ , »((i)
   (h : p i), f i h), a), «expr⨅ , »((i) (h : p i), «expr ⊓ »(f i h, a))) :=
by haveI [] [":", expr nonempty {i // p i}] [":=", expr let ⟨i, hi⟩ := h in
 ⟨⟨i, hi⟩⟩]; rw ["[", expr infi_subtype', ",", expr infi_subtype', ",", expr infi_inf, "]"] []

theorem inf_binfi {p : ι → Prop} {f : ∀ i (hi : p i), α} {a : α} (h : ∃ i, p i) :
  (a⊓⨅(i : _)(h : p i), f i h) = ⨅(i : _)(h : p i), a⊓f i h :=
  by 
    simpa only [inf_comm] using binfi_inf h

theorem supr_sup_eq {f g : ι → α} : (⨆x, f x⊔g x) = (⨆x, f x)⊔⨆x, g x :=
  @infi_inf_eq (OrderDual α) ι _ _ _

theorem supr_sup [h : Nonempty ι] {f : ι → α} {a : α} : (⨆x, f x)⊔a = ⨆x, f x⊔a :=
  @infi_inf (OrderDual α) _ _ _ _ _

theorem sup_supr [Nonempty ι] {f : ι → α} {a : α} : (a⊔⨆x, f x) = ⨆x, a⊔f x :=
  @inf_infi (OrderDual α) _ _ _ _ _

/-! ### `supr` and `infi` under `Prop` -/


@[simp]
theorem infi_false {s : False → α} : infi s = ⊤ :=
  le_antisymmₓ le_top (le_infi$ fun i => False.elim i)

@[simp]
theorem supr_false {s : False → α} : supr s = ⊥ :=
  le_antisymmₓ (supr_le$ fun i => False.elim i) bot_le

theorem infi_true {s : True → α} : infi s = s trivialₓ :=
  infi_pos trivialₓ

theorem supr_true {s : True → α} : supr s = s trivialₓ :=
  supr_pos trivialₓ

@[simp]
theorem infi_exists {p : ι → Prop} {f : Exists p → α} : (⨅x, f x) = ⨅i, ⨅h : p i, f ⟨i, h⟩ :=
  le_antisymmₓ (le_infi$ fun i => le_infi$ fun this : p i => infi_le _ _)
    (le_infi$ fun ⟨i, h⟩ => infi_le_of_le i$ infi_le _ _)

@[simp]
theorem supr_exists {p : ι → Prop} {f : Exists p → α} : (⨆x, f x) = ⨆i, ⨆h : p i, f ⟨i, h⟩ :=
  @infi_exists (OrderDual α) _ _ _ _

theorem infi_and {p q : Prop} {s : p ∧ q → α} : infi s = ⨅h₁ h₂, s ⟨h₁, h₂⟩ :=
  le_antisymmₓ (le_infi$ fun i => le_infi$ fun j => infi_le _ _) (le_infi$ fun ⟨i, h⟩ => infi_le_of_le i$ infi_le _ _)

/-- The symmetric case of `infi_and`, useful for rewriting into a infimum over a conjunction -/
theorem infi_and' {p q : Prop} {s : p → q → α} : (⨅(h₁ : p)(h₂ : q), s h₁ h₂) = ⨅h : p ∧ q, s h.1 h.2 :=
  by 
    symm 
    exact infi_and

theorem supr_and {p q : Prop} {s : p ∧ q → α} : supr s = ⨆h₁ h₂, s ⟨h₁, h₂⟩ :=
  @infi_and (OrderDual α) _ _ _ _

/-- The symmetric case of `supr_and`, useful for rewriting into a supremum over a conjunction -/
theorem supr_and' {p q : Prop} {s : p → q → α} : (⨆(h₁ : p)(h₂ : q), s h₁ h₂) = ⨆h : p ∧ q, s h.1 h.2 :=
  by 
    symm 
    exact supr_and

theorem infi_or {p q : Prop} {s : p ∨ q → α} : infi s = (⨅h : p, s (Or.inl h))⊓⨅h : q, s (Or.inr h) :=
  le_antisymmₓ (le_inf (infi_le_infi2$ fun j => ⟨_, le_reflₓ _⟩) (infi_le_infi2$ fun j => ⟨_, le_reflₓ _⟩))
    (le_infi$
      fun i =>
        match i with 
        | Or.inl i => inf_le_of_left_le$ infi_le _ _
        | Or.inr j => inf_le_of_right_le$ infi_le _ _)

theorem supr_or {p q : Prop} {s : p ∨ q → α} : (⨆x, s x) = (⨆i, s (Or.inl i))⊔⨆j, s (Or.inr j) :=
  @infi_or (OrderDual α) _ _ _ _

section 

variable(p : ι → Prop)[DecidablePred p]

theorem supr_dite (f : ∀ i, p i → α) (g : ∀ i, ¬p i → α) :
  (⨆i, if h : p i then f i h else g i h) = (⨆(i : _)(h : p i), f i h)⊔⨆(i : _)(h : ¬p i), g i h :=
  by 
    rw [←supr_sup_eq]
    congr 1 with i 
    splitIfs with h <;> simp [h]

theorem supr_ite (f g : ι → α) : (⨆i, if p i then f i else g i) = (⨆(i : _)(h : p i), f i)⊔⨆(i : _)(h : ¬p i), g i :=
  supr_dite _ _ _

theorem infi_dite (f : ∀ i, p i → α) (g : ∀ i, ¬p i → α) :
  (⨅i, if h : p i then f i h else g i h) = (⨅(i : _)(h : p i), f i h)⊓⨅(i : _)(h : ¬p i), g i h :=
  supr_dite p (show ∀ i, p i → OrderDual α from f) g

theorem infi_ite (f g : ι → α) : (⨅i, if p i then f i else g i) = (⨅(i : _)(h : p i), f i)⊓⨅(i : _)(h : ¬p i), g i :=
  infi_dite _ _ _

end 

theorem Sup_range {α : Type _} [HasSupₓ α] {f : ι → α} : Sup (range f) = supr f :=
  rfl

theorem Inf_range {α : Type _} [HasInfₓ α] {f : ι → α} : Inf (range f) = infi f :=
  rfl

theorem supr_range' {α} [HasSupₓ α] (g : β → α) (f : ι → β) : (⨆b : range f, g b) = ⨆i, g (f i) :=
  by 
    rw [supr, supr, ←image_eq_range, ←range_comp]

theorem infi_range' {α} [HasInfₓ α] (g : β → α) (f : ι → β) : (⨅b : range f, g b) = ⨅i, g (f i) :=
  @supr_range' _ _ (OrderDual α) _ _ _

theorem infi_range {g : β → α} {f : ι → β} : (⨅(b : _)(_ : b ∈ range f), g b) = ⨅i, g (f i) :=
  by 
    rw [←infi_subtype'', infi_range']

theorem supr_range {g : β → α} {f : ι → β} : (⨆(b : _)(_ : b ∈ range f), g b) = ⨆i, g (f i) :=
  @infi_range (OrderDual α) _ _ _ _ _

theorem Inf_image' {α} [HasInfₓ α] {s : Set β} {f : β → α} : Inf (f '' s) = ⨅a : s, f a :=
  by 
    rw [infi, image_eq_range]

theorem Sup_image' {α} [HasSupₓ α] {s : Set β} {f : β → α} : Sup (f '' s) = ⨆a : s, f a :=
  @Inf_image' _ (OrderDual α) _ _ _

theorem Inf_image {s : Set β} {f : β → α} : Inf (f '' s) = ⨅(a : _)(_ : a ∈ s), f a :=
  by 
    rw [←infi_subtype'', Inf_image']

theorem Sup_image {s : Set β} {f : β → α} : Sup (f '' s) = ⨆(a : _)(_ : a ∈ s), f a :=
  @Inf_image (OrderDual α) _ _ _ _

theorem infi_emptyset {f : β → α} : (⨅(x : _)(_ : x ∈ (∅ : Set β)), f x) = ⊤ :=
  by 
    simp 

theorem supr_emptyset {f : β → α} : (⨆(x : _)(_ : x ∈ (∅ : Set β)), f x) = ⊥ :=
  by 
    simp 

theorem infi_univ {f : β → α} : (⨅(x : _)(_ : x ∈ (univ : Set β)), f x) = ⨅x, f x :=
  by 
    simp 

theorem supr_univ {f : β → α} : (⨆(x : _)(_ : x ∈ (univ : Set β)), f x) = ⨆x, f x :=
  by 
    simp 

theorem infi_union {f : β → α} {s t : Set β} :
  (⨅(x : _)(_ : x ∈ s ∪ t), f x) = (⨅(x : _)(_ : x ∈ s), f x)⊓⨅(x : _)(_ : x ∈ t), f x :=
  by 
    simp only [←infi_inf_eq, infi_or]

theorem infi_split (f : β → α) (p : β → Prop) : (⨅i, f i) = (⨅(i : _)(h : p i), f i)⊓⨅(i : _)(h : ¬p i), f i :=
  by 
    simpa [Classical.em] using @infi_union _ _ _ f { i | p i } { i | ¬p i }

theorem infi_split_single (f : β → α) (i₀ : β) : (⨅i, f i) = f i₀⊓⨅(i : _)(h : i ≠ i₀), f i :=
  by 
    convert infi_split _ _ <;> simp 

theorem infi_le_infi_of_subset {f : β → α} {s t : Set β} (h : s ⊆ t) :
  (⨅(x : _)(_ : x ∈ t), f x) ≤ ⨅(x : _)(_ : x ∈ s), f x :=
  by 
    rw [(union_eq_self_of_subset_left h).symm, infi_union] <;> exact inf_le_left

theorem supr_union {f : β → α} {s t : Set β} :
  (⨆(x : _)(_ : x ∈ s ∪ t), f x) = (⨆(x : _)(_ : x ∈ s), f x)⊔⨆(x : _)(_ : x ∈ t), f x :=
  @infi_union (OrderDual α) _ _ _ _ _

theorem supr_split (f : β → α) (p : β → Prop) : (⨆i, f i) = (⨆(i : _)(h : p i), f i)⊔⨆(i : _)(h : ¬p i), f i :=
  @infi_split (OrderDual α) _ _ _ _

theorem supr_split_single (f : β → α) (i₀ : β) : (⨆i, f i) = f i₀⊔⨆(i : _)(h : i ≠ i₀), f i :=
  @infi_split_single (OrderDual α) _ _ _ _

theorem supr_le_supr_of_subset {f : β → α} {s t : Set β} (h : s ⊆ t) :
  (⨆(x : _)(_ : x ∈ s), f x) ≤ ⨆(x : _)(_ : x ∈ t), f x :=
  @infi_le_infi_of_subset (OrderDual α) _ _ _ _ _ h

-- error in Order.CompleteLattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem infi_insert
{f : β → α}
{s : set β}
{b : β} : «expr = »(«expr⨅ , »((x «expr ∈ » insert b s), f x), «expr ⊓ »(f b, «expr⨅ , »((x «expr ∈ » s), f x))) :=
«expr $ »(eq.trans infi_union, congr_arg (λ x : α, «expr ⊓ »(x, «expr⨅ , »((x «expr ∈ » s), f x))) infi_infi_eq_left)

-- error in Order.CompleteLattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem supr_insert
{f : β → α}
{s : set β}
{b : β} : «expr = »(«expr⨆ , »((x «expr ∈ » insert b s), f x), «expr ⊔ »(f b, «expr⨆ , »((x «expr ∈ » s), f x))) :=
«expr $ »(eq.trans supr_union, congr_arg (λ x : α, «expr ⊔ »(x, «expr⨆ , »((x «expr ∈ » s), f x))) supr_supr_eq_left)

theorem infi_singleton {f : β → α} {b : β} : (⨅(x : _)(_ : x ∈ (singleton b : Set β)), f x) = f b :=
  by 
    simp 

theorem infi_pair {f : β → α} {a b : β} : (⨅(x : _)(_ : x ∈ ({a, b} : Set β)), f x) = f a⊓f b :=
  by 
    rw [infi_insert, infi_singleton]

theorem supr_singleton {f : β → α} {b : β} : (⨆(x : _)(_ : x ∈ (singleton b : Set β)), f x) = f b :=
  @infi_singleton (OrderDual α) _ _ _ _

theorem supr_pair {f : β → α} {a b : β} : (⨆(x : _)(_ : x ∈ ({a, b} : Set β)), f x) = f a⊔f b :=
  by 
    rw [supr_insert, supr_singleton]

theorem infi_image {γ} {f : β → γ} {g : γ → α} {t : Set β} :
  (⨅(c : _)(_ : c ∈ f '' t), g c) = ⨅(b : _)(_ : b ∈ t), g (f b) :=
  by 
    rw [←Inf_image, ←Inf_image, ←image_comp]

theorem supr_image {γ} {f : β → γ} {g : γ → α} {t : Set β} :
  (⨆(c : _)(_ : c ∈ f '' t), g c) = ⨆(b : _)(_ : b ∈ t), g (f b) :=
  @infi_image (OrderDual α) _ _ _ _ _ _

/-!
### `supr` and `infi` under `Type`
-/


theorem supr_of_empty' {α ι} [HasSupₓ α] [IsEmpty ι] (f : ι → α) : supr f = Sup (∅ : Set α) :=
  congr_argₓ Sup (range_eq_empty f)

theorem supr_of_empty [IsEmpty ι] (f : ι → α) : supr f = ⊥ :=
  (supr_of_empty' f).trans Sup_empty

theorem infi_of_empty' {α ι} [HasInfₓ α] [IsEmpty ι] (f : ι → α) : infi f = Inf (∅ : Set α) :=
  congr_argₓ Inf (range_eq_empty f)

theorem infi_of_empty [IsEmpty ι] (f : ι → α) : infi f = ⊤ :=
  @supr_of_empty (OrderDual α) _ _ _ f

theorem supr_bool_eq {f : Bool → α} : (⨆b : Bool, f b) = f tt⊔f ff :=
  by 
    rw [supr, Bool.range_eq, Sup_pair, sup_comm]

theorem infi_bool_eq {f : Bool → α} : (⨅b : Bool, f b) = f tt⊓f ff :=
  @supr_bool_eq (OrderDual α) _ _

theorem sup_eq_supr (x y : α) : x⊔y = ⨆b : Bool, cond b x y :=
  by 
    rw [supr_bool_eq, Bool.cond_tt, Bool.cond_ff]

theorem inf_eq_infi (x y : α) : x⊓y = ⨅b : Bool, cond b x y :=
  @sup_eq_supr (OrderDual α) _ _ _

theorem is_glb_binfi {s : Set β} {f : β → α} : IsGlb (f '' s) (⨅(x : _)(_ : x ∈ s), f x) :=
  by 
    simpa only [range_comp, Subtype.range_coe, infi_subtype'] using @is_glb_infi α s _ (f ∘ coeₓ)

theorem supr_subtype {p : ι → Prop} {f : Subtype p → α} : (⨆x, f x) = ⨆(i : _)(h : p i), f ⟨i, h⟩ :=
  @infi_subtype (OrderDual α) _ _ _ _

theorem supr_subtype' {p : ι → Prop} {f : ∀ i, p i → α} : (⨆(i : _)(h : p i), f i h) = ⨆x : Subtype p, f x x.property :=
  (@supr_subtype _ _ _ p fun x => f x.val x.property).symm

theorem supr_subtype'' {ι} (s : Set ι) (f : ι → α) : (⨆i : s, f i) = ⨆(t : ι)(H : t ∈ s), f t :=
  supr_subtype

theorem is_lub_bsupr {s : Set β} {f : β → α} : IsLub (f '' s) (⨆(x : _)(_ : x ∈ s), f x) :=
  by 
    simpa only [range_comp, Subtype.range_coe, supr_subtype'] using @is_lub_supr α s _ (f ∘ coeₓ)

theorem infi_sigma {p : β → Type _} {f : Sigma p → α} : (⨅x, f x) = ⨅(i : _)(h : p i), f ⟨i, h⟩ :=
  eq_of_forall_le_iff$
    fun c =>
      by 
        simp only [le_infi_iff, Sigma.forall]

theorem supr_sigma {p : β → Type _} {f : Sigma p → α} : (⨆x, f x) = ⨆(i : _)(h : p i), f ⟨i, h⟩ :=
  @infi_sigma (OrderDual α) _ _ _ _

theorem infi_prod {γ : Type _} {f : β × γ → α} : (⨅x, f x) = ⨅i j, f (i, j) :=
  eq_of_forall_le_iff$
    fun c =>
      by 
        simp only [le_infi_iff, Prod.forall]

theorem supr_prod {γ : Type _} {f : β × γ → α} : (⨆x, f x) = ⨆i j, f (i, j) :=
  @infi_prod (OrderDual α) _ _ _ _

theorem infi_sum {γ : Type _} {f : Sum β γ → α} : (⨅x, f x) = (⨅i, f (Sum.inl i))⊓⨅j, f (Sum.inr j) :=
  eq_of_forall_le_iff$
    fun c =>
      by 
        simp only [le_inf_iff, le_infi_iff, Sum.forall]

theorem supr_sum {γ : Type _} {f : Sum β γ → α} : (⨆x, f x) = (⨆i, f (Sum.inl i))⊔⨆j, f (Sum.inr j) :=
  @infi_sum (OrderDual α) _ _ _ _

theorem supr_option (f : Option β → α) : (⨆o, f o) = f none⊔⨆b, f (Option.some b) :=
  eq_of_forall_ge_iff$
    fun c =>
      by 
        simp only [supr_le_iff, sup_le_iff, Option.forall]

theorem infi_option (f : Option β → α) : (⨅o, f o) = f none⊓⨅b, f (Option.some b) :=
  @supr_option (OrderDual α) _ _ _

/-- A version of `supr_option` useful for rewriting right-to-left. -/
theorem supr_option_elim (a : α) (f : β → α) : (⨆o : Option β, o.elim a f) = a⊔⨆b, f b :=
  by 
    simp [supr_option]

/-- A version of `infi_option` useful for rewriting right-to-left. -/
theorem infi_option_elim (a : α) (f : β → α) : (⨅o : Option β, o.elim a f) = a⊓⨅b, f b :=
  @supr_option_elim (OrderDual α) _ _ _ _

/-- When taking the supremum of `f : ι → α`, the elements of `ι` on which `f` gives `⊥` can be
dropped, without changing the result. -/
theorem supr_ne_bot_subtype (f : ι → α) : (⨆i : { i // f i ≠ ⊥ }, f i) = ⨆i, f i :=
  by 
    byCases' htriv : ∀ i, f i = ⊥
    ·
      simp only [htriv, supr_bot]
    refine' le_antisymmₓ (supr_comp_le f _) (supr_le_supr2 _)
    intro i 
    byCases' hi : f i = ⊥
    ·
      rw [hi]
      obtain ⟨i₀, hi₀⟩ := not_forall.mp htriv 
      exact ⟨⟨i₀, hi₀⟩, bot_le⟩
    ·
      exact ⟨⟨i, hi⟩, rfl.le⟩

/-- When taking the infimum of `f : ι → α`, the elements of `ι` on which `f` gives `⊤` can be
dropped, without changing the result. -/
theorem infi_ne_top_subtype (f : ι → α) : (⨅i : { i // f i ≠ ⊤ }, f i) = ⨅i, f i :=
  @supr_ne_bot_subtype (OrderDual α) ι _ f

/-!
### `supr` and `infi` under `ℕ`
-/


theorem supr_ge_eq_supr_nat_add {u : ℕ → α} (n : ℕ) : (⨆(i : _)(_ : i ≥ n), u i) = ⨆i, u (i+n) :=
  by 
    apply le_antisymmₓ <;> simp only [supr_le_iff]
    ·
      exact
        fun i hi =>
          le_Sup
            ⟨i - n,
              by 
                dsimp only 
                rw [tsub_add_cancel_of_le hi]⟩
    ·
      exact fun i => le_Sup ⟨i+n, supr_pos (Nat.le_add_leftₓ _ _)⟩

theorem infi_ge_eq_infi_nat_add {u : ℕ → α} (n : ℕ) : (⨅(i : _)(_ : i ≥ n), u i) = ⨅i, u (i+n) :=
  @supr_ge_eq_supr_nat_add (OrderDual α) _ _ _

theorem Monotone.supr_nat_add {f : ℕ → α} (hf : Monotone f) (k : ℕ) : (⨆n, f (n+k)) = ⨆n, f n :=
  le_antisymmₓ (supr_le fun i => (le_reflₓ _).trans (le_supr _ (i+k)))
    (supr_le_supr fun i => hf (Nat.le_add_rightₓ i k))

-- error in Order.CompleteLattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem supr_infi_ge_nat_add
(f : exprℕ() → α)
(k : exprℕ()) : «expr = »(«expr⨆ , »((n), «expr⨅ , »((i «expr ≥ » n), f «expr + »(i, k))), «expr⨆ , »((n), «expr⨅ , »((i «expr ≥ » n), f i))) :=
begin
  have [ident hf] [":", expr monotone (λ n, «expr⨅ , »((i «expr ≥ » n), f i))] [],
  from [expr λ n m hnm, le_infi (λ i, (infi_le _ i).trans (le_infi (λ h, infi_le _ (hnm.trans h))))],
  rw ["<-", expr monotone.supr_nat_add hf k] [],
  { simp_rw ["[", expr infi_ge_eq_infi_nat_add, ",", "<-", expr nat.add_assoc, "]"] [] }
end

theorem sup_supr_nat_succ (u : ℕ → α) : (u 0⊔⨆i, u (i+1)) = ⨆i, u i :=
  by 
    refine' eq_of_forall_ge_iff fun c => _ 
    simp only [sup_le_iff, supr_le_iff]
    refine' ⟨fun h => _, fun h => ⟨h _, fun i => h _⟩⟩
    rintro (_ | i)
    exacts[h.1, h.2 i]

theorem inf_infi_nat_succ (u : ℕ → α) : (u 0⊓⨅i, u (i+1)) = ⨅i, u i :=
  @sup_supr_nat_succ (OrderDual α) _ u

end 

section CompleteLinearOrder

variable[CompleteLinearOrder α]

theorem supr_eq_top (f : ι → α) : supr f = ⊤ ↔ ∀ b (_ : b < ⊤), ∃ i, b < f i :=
  by 
    simp only [←Sup_range, Sup_eq_top, Set.exists_range_iff]

theorem infi_eq_bot (f : ι → α) : infi f = ⊥ ↔ ∀ b (_ : b > ⊥), ∃ i, f i < b :=
  by 
    simp only [←Inf_range, Inf_eq_bot, Set.exists_range_iff]

end CompleteLinearOrder

/-!
### Instances
-/


instance Prop.completeLattice : CompleteLattice Prop :=
  { Prop.boundedOrder, Prop.distribLattice with sup := fun s => ∃ (a : _)(_ : a ∈ s), a,
    le_Sup := fun s a h p => ⟨a, h, p⟩, Sup_le := fun s a h ⟨b, h', p⟩ => h b h' p,
    inf := fun s => ∀ (a : Prop), a ∈ s → a, Inf_le := fun s a h p => p a h, le_Inf := fun s a h p b hb => h b hb p }

@[simp]
theorem Inf_Prop_eq {s : Set Prop} : Inf s = ∀ p (_ : p ∈ s), p :=
  rfl

@[simp]
theorem Sup_Prop_eq {s : Set Prop} : Sup s = ∃ (p : _)(_ : p ∈ s), p :=
  rfl

@[simp]
theorem infi_Prop_eq {ι : Sort _} {p : ι → Prop} : (⨅i, p i) = ∀ i, p i :=
  le_antisymmₓ (fun h i => h _ ⟨i, rfl⟩) fun h p ⟨i, Eq⟩ => Eq ▸ h i

@[simp]
theorem supr_Prop_eq {ι : Sort _} {p : ι → Prop} : (⨆i, p i) = ∃ i, p i :=
  le_antisymmₓ (fun ⟨q, ⟨i, (Eq : p i = q)⟩, hq⟩ => ⟨i, Eq.symm ▸ hq⟩) fun ⟨i, hi⟩ => ⟨p i, ⟨i, rfl⟩, hi⟩

instance Pi.hasSupₓ {α : Type _} {β : α → Type _} [∀ i, HasSupₓ (β i)] : HasSupₓ (∀ i, β i) :=
  ⟨fun s i => ⨆f : s, (f : ∀ i, β i) i⟩

instance Pi.hasInfₓ {α : Type _} {β : α → Type _} [∀ i, HasInfₓ (β i)] : HasInfₓ (∀ i, β i) :=
  ⟨fun s i => ⨅f : s, (f : ∀ i, β i) i⟩

-- error in Order.CompleteLattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
instance pi.complete_lattice {α : Type*} {β : α → Type*} [∀ i, complete_lattice (β i)] : complete_lattice (∀ i, β i) :=
{ Sup := Sup,
  Inf := Inf,
  le_Sup := λ s f hf i, le_supr (λ f : s, (f : ∀ i, β i) i) ⟨f, hf⟩,
  Inf_le := λ s f hf i, infi_le (λ f : s, (f : ∀ i, β i) i) ⟨f, hf⟩,
  Sup_le := λ s f hf i, «expr $ »(supr_le, λ g, hf g g.2 i),
  le_Inf := λ s f hf i, «expr $ »(le_infi, λ g, hf g g.2 i),
  ..pi.bounded_order,
  ..pi.lattice }

theorem Inf_apply {α : Type _} {β : α → Type _} [∀ i, HasInfₓ (β i)] {s : Set (∀ a, β a)} {a : α} :
  (Inf s) a = ⨅f : s, (f : ∀ a, β a) a :=
  rfl

-- error in Order.CompleteLattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem infi_apply
{α : Type*}
{β : α → Type*}
{ι : Sort*}
[∀ i, has_Inf (β i)]
{f : ι → ∀ a, β a}
{a : α} : «expr = »(«expr⨅ , »((i), f i) a, «expr⨅ , »((i), f i a)) :=
by rw ["[", expr infi, ",", expr Inf_apply, ",", expr infi, ",", expr infi, ",", "<-", expr image_eq_range (λ
  f : ∀ i, β i, f a) (range f), ",", "<-", expr range_comp, "]"] []

theorem Sup_apply {α : Type _} {β : α → Type _} [∀ i, HasSupₓ (β i)] {s : Set (∀ a, β a)} {a : α} :
  (Sup s) a = ⨆f : s, (f : ∀ a, β a) a :=
  rfl

theorem unary_relation_Sup_iff {α : Type _} (s : Set (α → Prop)) {a : α} : Sup s a ↔ ∃ r : α → Prop, r ∈ s ∧ r a :=
  by 
    change (∃ _, _) ↔ _ 
    simp [-eq_iff_iff]

theorem binary_relation_Sup_iff {α β : Type _} (s : Set (α → β → Prop)) {a : α} {b : β} :
  Sup s a b ↔ ∃ r : α → β → Prop, r ∈ s ∧ r a b :=
  by 
    change (∃ _, _) ↔ _ 
    simp [-eq_iff_iff]

@[simp]
theorem supr_apply {α : Type _} {β : α → Type _} {ι : Sort _} [∀ i, HasSupₓ (β i)] {f : ι → ∀ a, β a} {a : α} :
  (⨆i, f i) a = ⨆i, f i a :=
  @infi_apply α (fun i => OrderDual (β i)) _ _ f a

section CompleteLattice

variable[Preorderₓ α][CompleteLattice β]

theorem monotone_Sup_of_monotone {s : Set (α → β)} (m_s : ∀ f (_ : f ∈ s), Monotone f) : Monotone (Sup s) :=
  fun x y h => supr_le$ fun f => le_supr_of_le f$ m_s f f.2 h

theorem monotone_Inf_of_monotone {s : Set (α → β)} (m_s : ∀ f (_ : f ∈ s), Monotone f) : Monotone (Inf s) :=
  fun x y h => le_infi$ fun f => infi_le_of_le f$ m_s f f.2 h

end CompleteLattice

namespace Prod

variable(α β)

instance  [HasInfₓ α] [HasInfₓ β] : HasInfₓ (α × β) :=
  ⟨fun s => (Inf (Prod.fst '' s), Inf (Prod.snd '' s))⟩

instance  [HasSupₓ α] [HasSupₓ β] : HasSupₓ (α × β) :=
  ⟨fun s => (Sup (Prod.fst '' s), Sup (Prod.snd '' s))⟩

instance  [CompleteLattice α] [CompleteLattice β] : CompleteLattice (α × β) :=
  { Prod.lattice α β, Prod.boundedOrder α β, Prod.hasSupₓ α β, Prod.hasInfₓ α β with
    le_Sup := fun s p hab => ⟨le_Sup$ mem_image_of_mem _ hab, le_Sup$ mem_image_of_mem _ hab⟩,
    Sup_le :=
      fun s p h =>
        ⟨Sup_le$ ball_image_of_ball$ fun p hp => (h p hp).1, Sup_le$ ball_image_of_ball$ fun p hp => (h p hp).2⟩,
    Inf_le := fun s p hab => ⟨Inf_le$ mem_image_of_mem _ hab, Inf_le$ mem_image_of_mem _ hab⟩,
    le_Inf :=
      fun s p h =>
        ⟨le_Inf$ ball_image_of_ball$ fun p hp => (h p hp).1, le_Inf$ ball_image_of_ball$ fun p hp => (h p hp).2⟩ }

end Prod

section CompleteLattice

variable[CompleteLattice α]{a : α}{s : Set α}

/-- This is a weaker version of `sup_Inf_eq` -/
theorem sup_Inf_le_infi_sup : a⊔Inf s ≤ ⨅(b : _)(_ : b ∈ s), a⊔b :=
  le_infi$ fun i => le_infi$ fun h => sup_le_sup_left (Inf_le h) _

/-- This is a weaker version of `Inf_sup_eq` -/
theorem Inf_sup_le_infi_sup : Inf s⊔a ≤ ⨅(b : _)(_ : b ∈ s), b⊔a :=
  le_infi$ fun i => le_infi$ fun h => sup_le_sup_right (Inf_le h) _

/-- This is a weaker version of `inf_Sup_eq` -/
theorem supr_inf_le_inf_Sup : (⨆(b : _)(_ : b ∈ s), a⊓b) ≤ a⊓Sup s :=
  supr_le$ fun i => supr_le$ fun h => inf_le_inf_left _ (le_Sup h)

/-- This is a weaker version of `Sup_inf_eq` -/
theorem supr_inf_le_Sup_inf : (⨆(b : _)(_ : b ∈ s), b⊓a) ≤ Sup s⊓a :=
  supr_le$ fun i => supr_le$ fun h => inf_le_inf_right _ (le_Sup h)

theorem disjoint_Sup_left {a : Set α} {b : α} (d : Disjoint (Sup a) b) {i} (hi : i ∈ a) : Disjoint i b :=
  (supr_le_iff.mp (supr_le_iff.mp (supr_inf_le_Sup_inf.trans (d : _)) i : _) hi : _)

theorem disjoint_Sup_right {a : Set α} {b : α} (d : Disjoint b (Sup a)) {i} (hi : i ∈ a) : Disjoint b i :=
  (supr_le_iff.mp (supr_le_iff.mp (supr_inf_le_inf_Sup.trans (d : _)) i : _) hi : _)

end CompleteLattice

namespace CompleteLattice

variable[CompleteLattice α]

/-- An independent set of elements in a complete lattice is one in which every element is disjoint
  from the `Sup` of the rest. -/
def set_independent (s : Set α) : Prop :=
  ∀ ⦃a⦄, a ∈ s → Disjoint a (Sup (s \ {a}))

variable{s : Set α}(hs : set_independent s)

@[simp]
theorem set_independent_empty : set_independent (∅ : Set α) :=
  fun x hx => (Set.not_mem_empty x hx).elim

theorem set_independent.mono {t : Set α} (hst : t ⊆ s) : set_independent t :=
  fun a ha => (hs (hst ha)).mono_right (Sup_le_Sup (diff_subset_diff_left hst))

/-- If the elements of a set are independent, then any pair within that set is disjoint. -/
theorem set_independent.disjoint {x y : α} (hx : x ∈ s) (hy : y ∈ s) (h : x ≠ y) : Disjoint x y :=
  disjoint_Sup_right (hs hx)
    ((mem_diff y).mpr
      ⟨hy,
        by 
          simp [h.symm]⟩)

include hs

-- error in Order.CompleteLattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If the elements of a set are independent, then any element is disjoint from the `Sup` of some
subset of the rest. -/
theorem set_independent.disjoint_Sup
{x : α}
{y : set α}
(hx : «expr ∈ »(x, s))
(hy : «expr ⊆ »(y, s))
(hxy : «expr ∉ »(x, y)) : disjoint x (Sup y) :=
begin
  have [] [] [":=", expr «expr $ »(hs.mono, insert_subset.mpr ⟨hx, hy⟩) (mem_insert x _)],
  rw ["[", expr insert_diff_of_mem _ (mem_singleton _), ",", expr diff_singleton_eq_self hxy, "]"] ["at", ident this],
  exact [expr this]
end

omit hs

/-- An independent indexed family of elements in a complete lattice is one in which every element
  is disjoint from the `supr` of the rest.

  Example: an indexed family of non-zero elements in a
  vector space is linearly independent iff the indexed family of subspaces they generate is
  independent in this sense.

  Example: an indexed family of submodules of a module is independent in this sense if
  and only the natural map from the direct sum of the submodules to the module is injective. -/
def independent {ι : Sort _} {α : Type _} [CompleteLattice α] (t : ι → α) : Prop :=
  ∀ (i : ι), Disjoint (t i) (⨆(j : _)(_ : j ≠ i), t j)

theorem set_independent_iff {α : Type _} [CompleteLattice α] (s : Set α) :
  set_independent s ↔ independent (coeₓ : s → α) :=
  by 
    simpRw [independent, set_independent, SetCoe.forall, Sup_eq_supr]
    apply forall_congrₓ 
    intro a 
    apply forall_congrₓ 
    intro ha 
    congr 2
    convert supr_subtype.symm 
    simp [supr_and]

variable{t : ι → α}(ht : independent t)

theorem independent_def : independent t ↔ ∀ (i : ι), Disjoint (t i) (⨆(j : _)(_ : j ≠ i), t j) :=
  Iff.rfl

theorem independent_def' {ι : Type _} {t : ι → α} : independent t ↔ ∀ i, Disjoint (t i) (Sup (t '' { j | j ≠ i })) :=
  by 
    simpRw [Sup_image]
    rfl

theorem independent_def'' {ι : Type _} {t : ι → α} :
  independent t ↔ ∀ i, Disjoint (t i) (Sup { a | ∃ (j : _)(_ : j ≠ i), t j = a }) :=
  by 
    rw [independent_def']
    tidy

@[simp]
theorem independent_empty (t : Empty → α) : independent t :=
  fun.

@[simp]
theorem independent_pempty (t : Pempty → α) : independent t :=
  fun.

/-- If the elements of a set are independent, then any pair within that set is disjoint. -/
theorem independent.disjoint {x y : ι} (h : x ≠ y) : Disjoint (t x) (t y) :=
  disjoint_Sup_right (ht x)
    ⟨y,
      by 
        simp [h.symm]⟩

theorem independent.mono {ι : Type _} {α : Type _} [CompleteLattice α] {s t : ι → α} (hs : independent s)
  (hst : t ≤ s) : independent t :=
  fun i => (hs i).mono (hst i) (supr_le_supr$ fun j => supr_le_supr$ fun _ => hst j)

/-- Composing an independent indexed family with an injective function on the index results in
another indepedendent indexed family. -/
theorem independent.comp {ι ι' : Sort _} {α : Type _} [CompleteLattice α] {s : ι → α} (hs : independent s) (f : ι' → ι)
  (hf : Function.Injective f) : independent (s ∘ f) :=
  fun i =>
    (hs (f i)).mono_right
      (by 
        refine' (supr_le_supr$ fun i => _).trans (supr_comp_le _ f)
        exact supr_le_supr_const hf.ne)

/-- Composing an indepedent indexed family with an order isomorphism on the elements results in
another indepedendent indexed family. -/
theorem independent.map_order_iso {ι : Sort _} {α β : Type _} [CompleteLattice α] [CompleteLattice β] (f : α ≃o β)
  {a : ι → α} (ha : independent a) : independent (f ∘ a) :=
  fun i => ((ha i).map_order_iso f).mono_right (f.monotone.le_map_supr2 _)

@[simp]
theorem independent_map_order_iso_iff {ι : Sort _} {α β : Type _} [CompleteLattice α] [CompleteLattice β] (f : α ≃o β)
  {a : ι → α} : independent (f ∘ a) ↔ independent a :=
  ⟨fun h =>
      have hf : f.symm ∘ f ∘ a = a := congr_argₓ (· ∘ a) f.left_inv.comp_eq_id 
      hf ▸ h.map_order_iso f.symm,
    fun h => h.map_order_iso f⟩

/-- If the elements of a set are independent, then any element is disjoint from the `supr` of some
subset of the rest. -/
theorem independent.disjoint_bsupr {ι : Type _} {α : Type _} [CompleteLattice α] {t : ι → α} (ht : independent t)
  {x : ι} {y : Set ι} (hx : x ∉ y) : Disjoint (t x) (⨆(i : _)(_ : i ∈ y), t i) :=
  Disjoint.mono_right (bsupr_le_bsupr'$ fun i hi => (ne_of_mem_of_not_mem hi hx : _)) (ht x)

end CompleteLattice

