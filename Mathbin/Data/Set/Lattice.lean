import Mathbin.Data.Nat.Basic 
import Mathbin.Order.CompleteBooleanAlgebra 
import Mathbin.Order.Directed 
import Mathbin.Order.GaloisConnection

/-!
# The set lattice

This file provides usual set notation for unions and intersections, a `complete_lattice` instance
for `set α`, and some more set constructions.

## Main declarations

* `set.Union`: Union of an indexed family of sets.
* `set.Inter`: Intersection of an indexed family of sets.
* `set.sInter`: **s**et **Inter**. Intersection of sets belonging to a set of sets.
* `set.sUnion`: **s**et **Union**. Union of sets belonging to a set of sets. This is actually
  defined in core Lean.
* `set.sInter_eq_bInter`, `set.sUnion_eq_bInter`: Shows that `⋂₀ s = ⋂ x ∈ s, x` and
  `⋃₀ s = ⋃ x ∈ s, x`.
* `set.complete_boolean_algebra`: `set α` is a `complete_boolean_algebra` with `≤ = ⊆`, `< = ⊂`,
  `⊓ = ∩`, `⊔ = ∪`, `⨅ = ⋂`, `⨆ = ⋃` and `\` as the set difference. See `set.boolean_algebra`.
* `set.kern_image`: For a function `f : α → β`, `s.kern_image f` is the set of `y` such that
  `f ⁻¹ y ⊆ s`.
* `set.seq`: Union of the image of a set under a **seq**uence of functions. `seq s t` is the union
  of `f '' t` over all `f ∈ s`, where `t : set α` and `s : set (α → β)`.
* `set.Union_eq_sigma_of_disjoint`: Equivalence between `⋃ i, t i` and `Σ i, t i`, where `t` is an
  indexed family of disjoint sets.

## Notation

* `⋃`: `set.Union`
* `⋂`: `set.Inter`
* `⋃₀`: `set.sUnion`
* `⋂₀`: `set.sInter`
-/


open Function Tactic Set Auto

universe u

variable{α β γ : Type _}{ι ι' ι₂ : Sort _}

namespace Set

/-! ### Complete lattice and complete Boolean algebra instances -/


instance  : HasInfₓ (Set α) :=
  ⟨fun s => { a | ∀ t (_ : t ∈ s), a ∈ t }⟩

instance  : HasSupₓ (Set α) :=
  ⟨sUnion⟩

/-- Intersection of a set of sets. -/
def sInter (S : Set (Set α)) : Set α :=
  Inf S

prefix:110 "⋂₀" => sInter

@[simp]
theorem mem_sInter {x : α} {S : Set (Set α)} : x ∈ ⋂₀S ↔ ∀ t (_ : t ∈ S), x ∈ t :=
  Iff.rfl

/-- Indexed union of a family of sets -/
def Union (s : ι → Set β) : Set β :=
  supr s

/-- Indexed intersection of a family of sets -/
def Inter (s : ι → Set β) : Set β :=
  infi s

notation3  "⋃" (...) ", " r:(scoped f => Union f) => r

notation3  "⋂" (...) ", " r:(scoped f => Inter f) => r

@[simp]
theorem Sup_eq_sUnion (S : Set (Set α)) : Sup S = ⋃₀S :=
  rfl

@[simp]
theorem Inf_eq_sInter (S : Set (Set α)) : Inf S = ⋂₀S :=
  rfl

@[simp]
theorem supr_eq_Union (s : ι → Set α) : supr s = Union s :=
  rfl

@[simp]
theorem infi_eq_Inter (s : ι → Set α) : infi s = Inter s :=
  rfl

@[simp]
theorem mem_Union {x : β} {s : ι → Set β} : x ∈ Union s ↔ ∃ i, x ∈ s i :=
  ⟨fun ⟨t, ⟨⟨a, (t_eq : s a = t)⟩, (h : x ∈ t)⟩⟩ => ⟨a, t_eq.symm ▸ h⟩, fun ⟨a, h⟩ => ⟨s a, ⟨⟨a, rfl⟩, h⟩⟩⟩

-- error in Data.Set.Lattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp] theorem mem_Inter {x : β} {s : ι → set β} : «expr ↔ »(«expr ∈ »(x, Inter s), ∀ i, «expr ∈ »(x, s i)) :=
⟨λ
 (h : ∀ a «expr ∈ » {a : set β | «expr∃ , »((i), «expr = »(s i, a))}, «expr ∈ »(x, a))
 (a), h (s a) ⟨a, rfl⟩, λ (h t) ⟨a, (eq : «expr = »(s a, t))⟩, «expr ▸ »(eq, h a)⟩

theorem mem_sUnion {x : α} {S : Set (Set α)} : x ∈ ⋃₀S ↔ ∃ (t : _)(_ : t ∈ S), x ∈ t :=
  Iff.rfl

instance  : CompleteBooleanAlgebra (Set α) :=
  { Set.booleanAlgebra, Pi.completeLattice with sup := Sup, inf := Inf,
    le_Sup := fun s t t_in a a_in => ⟨t, ⟨t_in, a_in⟩⟩, Sup_le := fun s t h a ⟨t', ⟨t'_in, a_in⟩⟩ => h t' t'_in a_in,
    le_Inf := fun s t h a a_in t' t'_in => h t' t'_in a_in, Inf_le := fun s t t_in a h => h _ t_in,
    infi_sup_le_sup_Inf :=
      fun s S x =>
        Iff.mp$
          by 
            simp [forall_or_distrib_left],
    inf_Sup_le_supr_inf :=
      fun s S x =>
        Iff.mp$
          by 
            simp [exists_and_distrib_left] }

/-- `set.image` is monotone. See `set.image_image` for the statement in terms of `⊆`. -/
theorem monotone_image {f : α → β} : Monotone (image f) :=
  fun s t => image_subset _

theorem monotone_inter [Preorderₓ β] {f g : β → Set α} (hf : Monotone f) (hg : Monotone g) :
  Monotone fun x => f x ∩ g x :=
  fun b₁ b₂ h => inter_subset_inter (hf h) (hg h)

theorem monotone_union [Preorderₓ β] {f g : β → Set α} (hf : Monotone f) (hg : Monotone g) :
  Monotone fun x => f x ∪ g x :=
  fun b₁ b₂ h => union_subset_union (hf h) (hg h)

theorem monotone_set_of [Preorderₓ α] {p : α → β → Prop} (hp : ∀ b, Monotone fun a => p a b) :
  Monotone fun a => { b | p a b } :=
  fun a a' h b => hp b h

section GaloisConnection

variable{f : α → β}

protected theorem image_preimage : GaloisConnection (image f) (preimage f) :=
  fun a b => image_subset_iff

/-- `kern_image f s` is the set of `y` such that `f ⁻¹ y ⊆ s`. -/
def kern_image (f : α → β) (s : Set α) : Set β :=
  { y | ∀ ⦃x⦄, f x = y → x ∈ s }

-- error in Data.Set.Lattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
protected theorem preimage_kern_image : galois_connection (preimage f) (kern_image f) :=
λ
a
b, ⟨λ h x hx y hy, have «expr ∈ »(f y, a), from «expr ▸ »(hy.symm, hx),
 h this, λ (h x) (hx : «expr ∈ »(f x, a)), h hx rfl⟩

end GaloisConnection

/-! ### Union and intersection over an indexed family of sets -/


instance  : OrderTop (Set α) :=
  { top := univ,
    le_top :=
      by 
        simp  }

@[congr]
theorem Union_congr_Prop {p q : Prop} {f₁ : p → Set α} {f₂ : q → Set α} (pq : p ↔ q) (f : ∀ x, f₁ (pq.mpr x) = f₂ x) :
  Union f₁ = Union f₂ :=
  supr_congr_Prop pq f

@[congr]
theorem Inter_congr_Prop {p q : Prop} {f₁ : p → Set α} {f₂ : q → Set α} (pq : p ↔ q) (f : ∀ x, f₁ (pq.mpr x) = f₂ x) :
  Inter f₁ = Inter f₂ :=
  infi_congr_Prop pq f

theorem Union_eq_if {p : Prop} [Decidable p] (s : Set α) : (⋃h : p, s) = if p then s else ∅ :=
  supr_eq_if _

theorem Union_eq_dif {p : Prop} [Decidable p] (s : p → Set α) : (⋃h : p, s h) = if h : p then s h else ∅ :=
  supr_eq_dif _

theorem Inter_eq_if {p : Prop} [Decidable p] (s : Set α) : (⋂h : p, s) = if p then s else univ :=
  infi_eq_if _

theorem Infi_eq_dif {p : Prop} [Decidable p] (s : p → Set α) : (⋂h : p, s h) = if h : p then s h else univ :=
  infi_eq_dif _

-- error in Data.Set.Lattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem exists_set_mem_of_union_eq_top
{ι : Type*}
(t : set ι)
(s : ι → set β)
(w : «expr = »(«expr⋃ , »((i «expr ∈ » t), s i), «expr⊤»()))
(x : β) : «expr∃ , »((i «expr ∈ » t), «expr ∈ »(x, s i)) :=
begin
  have [ident p] [":", expr «expr ∈ »(x, «expr⊤»())] [":=", expr set.mem_univ x],
  simpa [] [] ["only"] ["[", "<-", expr w, ",", expr set.mem_Union, "]"] [] ["using", expr p]
end

theorem nonempty_of_union_eq_top_of_nonempty {ι : Type _} (t : Set ι) (s : ι → Set α) (H : Nonempty α)
  (w : (⋃(i : _)(_ : i ∈ t), s i) = ⊤) : t.nonempty :=
  by 
    obtain ⟨x, m, -⟩ := exists_set_mem_of_union_eq_top t s w H.some 
    exact ⟨x, m⟩

theorem set_of_exists (p : ι → β → Prop) : { x | ∃ i, p i x } = ⋃i, { x | p i x } :=
  ext$ fun i => mem_Union.symm

theorem set_of_forall (p : ι → β → Prop) : { x | ∀ i, p i x } = ⋂i, { x | p i x } :=
  ext$ fun i => mem_Inter.symm

theorem Union_subset {s : ι → Set β} {t : Set β} (h : ∀ i, s i ⊆ t) : (⋃i, s i) ⊆ t :=
  @supr_le (Set β) _ _ _ _ h

@[simp]
theorem Union_subset_iff {s : ι → Set β} {t : Set β} : (⋃i, s i) ⊆ t ↔ ∀ i, s i ⊆ t :=
  ⟨fun h i => subset.trans (le_supr s _) h, Union_subset⟩

theorem mem_Inter_of_mem {x : β} {s : ι → Set β} : (∀ i, x ∈ s i) → x ∈ ⋂i, s i :=
  mem_Inter.2

theorem subset_Inter {t : Set β} {s : ι → Set β} (h : ∀ i, t ⊆ s i) : t ⊆ ⋂i, s i :=
  @le_infi (Set β) _ _ _ _ h

@[simp]
theorem subset_Inter_iff {t : Set β} {s : ι → Set β} : (t ⊆ ⋂i, s i) ↔ ∀ i, t ⊆ s i :=
  @le_infi_iff (Set β) _ _ _ _

theorem subset_Union : ∀ (s : ι → Set β) (i : ι), s i ⊆ ⋃i, s i :=
  le_supr

/-- This rather trivial consequence of `subset_Union`is convenient with `apply`, and has `i`
explicit for this purpose. -/
theorem subset_subset_Union {A : Set β} {s : ι → Set β} (i : ι) (h : A ⊆ s i) : A ⊆ ⋃i : ι, s i :=
  h.trans (subset_Union s i)

theorem Inter_subset : ∀ (s : ι → Set β) (i : ι), (⋂i, s i) ⊆ s i :=
  infi_le

theorem Inter_subset_of_subset {s : ι → Set α} {t : Set α} (i : ι) (h : s i ⊆ t) : (⋂i, s i) ⊆ t :=
  Set.Subset.trans (Set.Inter_subset s i) h

theorem Inter_subset_Inter {s t : ι → Set α} (h : ∀ i, s i ⊆ t i) : (⋂i, s i) ⊆ ⋂i, t i :=
  Set.subset_Inter$ fun i => Set.Inter_subset_of_subset i (h i)

theorem Inter_subset_Inter2 {s : ι → Set α} {t : ι' → Set α} (h : ∀ j, ∃ i, s i ⊆ t j) : (⋂i, s i) ⊆ ⋂j, t j :=
  Set.subset_Inter$
    fun j =>
      let ⟨i, hi⟩ := h j 
      Inter_subset_of_subset i hi

theorem Inter_set_of (P : ι → α → Prop) : (⋂i, { x:α | P i x }) = { x:α | ∀ i, P i x } :=
  by 
    ext 
    simp 

theorem Union_congr {f : ι → Set α} {g : ι₂ → Set α} (h : ι → ι₂) (h1 : surjective h) (h2 : ∀ x, g (h x) = f x) :
  (⋃x, f x) = ⋃y, g y :=
  supr_congr h h1 h2

theorem Inter_congr {f : ι → Set α} {g : ι₂ → Set α} (h : ι → ι₂) (h1 : surjective h) (h2 : ∀ x, g (h x) = f x) :
  (⋂x, f x) = ⋂y, g y :=
  infi_congr h h1 h2

theorem Union_const [Nonempty ι] (s : Set β) : (⋃i : ι, s) = s :=
  supr_const

theorem Inter_const [Nonempty ι] (s : Set β) : (⋂i : ι, s) = s :=
  infi_const

@[simp]
theorem compl_Union (s : ι → Set β) : «expr ᶜ» (⋃i, s i) = ⋂i, «expr ᶜ» (s i) :=
  compl_supr

@[simp]
theorem compl_Inter (s : ι → Set β) : «expr ᶜ» (⋂i, s i) = ⋃i, «expr ᶜ» (s i) :=
  compl_infi

theorem Union_eq_compl_Inter_compl (s : ι → Set β) : (⋃i, s i) = «expr ᶜ» (⋂i, «expr ᶜ» (s i)) :=
  by 
    simp only [compl_Inter, compl_compl]

theorem Inter_eq_compl_Union_compl (s : ι → Set β) : (⋂i, s i) = «expr ᶜ» (⋃i, «expr ᶜ» (s i)) :=
  by 
    simp only [compl_Union, compl_compl]

theorem inter_Union (s : Set β) (t : ι → Set β) : (s ∩ ⋃i, t i) = ⋃i, s ∩ t i :=
  inf_supr_eq _ _

theorem Union_inter (s : Set β) (t : ι → Set β) : (⋃i, t i) ∩ s = ⋃i, t i ∩ s :=
  supr_inf_eq _ _

theorem Union_union_distrib (s : ι → Set β) (t : ι → Set β) : (⋃i, s i ∪ t i) = (⋃i, s i) ∪ ⋃i, t i :=
  supr_sup_eq

theorem Inter_inter_distrib (s : ι → Set β) (t : ι → Set β) : (⋂i, s i ∩ t i) = (⋂i, s i) ∩ ⋂i, t i :=
  infi_inf_eq

theorem union_Union [Nonempty ι] (s : Set β) (t : ι → Set β) : (s ∪ ⋃i, t i) = ⋃i, s ∪ t i :=
  sup_supr

theorem Union_union [Nonempty ι] (s : Set β) (t : ι → Set β) : (⋃i, t i) ∪ s = ⋃i, t i ∪ s :=
  supr_sup

theorem inter_Inter [Nonempty ι] (s : Set β) (t : ι → Set β) : (s ∩ ⋂i, t i) = ⋂i, s ∩ t i :=
  inf_infi

theorem Inter_inter [Nonempty ι] (s : Set β) (t : ι → Set β) : (⋂i, t i) ∩ s = ⋂i, t i ∩ s :=
  infi_inf

theorem union_Inter (s : Set β) (t : ι → Set β) : (s ∪ ⋂i, t i) = ⋂i, s ∪ t i :=
  sup_infi_eq _ _

theorem Union_diff (s : Set β) (t : ι → Set β) : (⋃i, t i) \ s = ⋃i, t i \ s :=
  Union_inter _ _

theorem diff_Union [Nonempty ι] (s : Set β) (t : ι → Set β) : (s \ ⋃i, t i) = ⋂i, s \ t i :=
  by 
    rw [diff_eq, compl_Union, inter_Inter] <;> rfl

theorem diff_Inter (s : Set β) (t : ι → Set β) : (s \ ⋂i, t i) = ⋃i, s \ t i :=
  by 
    rw [diff_eq, compl_Inter, inter_Union] <;> rfl

theorem directed_on_Union {r} {f : ι → Set α} (hd : Directed (· ⊆ ·) f) (h : ∀ x, DirectedOn r (f x)) :
  DirectedOn r (⋃x, f x) :=
  by 
    simp only [DirectedOn, exists_prop, mem_Union, exists_imp_distrib] <;>
      exact
        fun a₁ b₁ fb₁ a₂ b₂ fb₂ =>
          let ⟨z, zb₁, zb₂⟩ := hd b₁ b₂ 
          let ⟨x, xf, xa₁, xa₂⟩ := h z a₁ (zb₁ fb₁) a₂ (zb₂ fb₂)
          ⟨x, ⟨z, xf⟩, xa₁, xa₂⟩

theorem Union_inter_subset {ι α} {s t : ι → Set α} : (⋃i, s i ∩ t i) ⊆ (⋃i, s i) ∩ ⋃i, t i :=
  by 
    rintro x ⟨_, ⟨i, rfl⟩, xs, xt⟩
    exact ⟨⟨_, ⟨i, rfl⟩, xs⟩, _, ⟨i, rfl⟩, xt⟩

theorem Union_inter_of_monotone {ι α} [SemilatticeSup ι] {s t : ι → Set α} (hs : Monotone s) (ht : Monotone t) :
  (⋃i, s i ∩ t i) = (⋃i, s i) ∩ ⋃i, t i :=
  by 
    ext x 
    refine' ⟨fun hx => Union_inter_subset hx, _⟩
    rintro ⟨⟨_, ⟨i, rfl⟩, xs⟩, _, ⟨j, rfl⟩, xt⟩
    exact ⟨_, ⟨i⊔j, rfl⟩, hs le_sup_left xs, ht le_sup_right xt⟩

/-- An equality version of this lemma is `Union_Inter_of_monotone` in `data.set.finite`. -/
theorem Union_Inter_subset {ι ι' α} {s : ι → ι' → Set α} : (⋃j, ⋂i, s i j) ⊆ ⋂i, ⋃j, s i j :=
  by 
    rintro x ⟨_, ⟨i, rfl⟩, hx⟩ _ ⟨j, rfl⟩
    exact ⟨_, ⟨i, rfl⟩, hx _ ⟨j, rfl⟩⟩

theorem Union_option {ι} (s : Option ι → Set α) : (⋃o, s o) = s none ∪ ⋃i, s (some i) :=
  supr_option s

theorem Inter_option {ι} (s : Option ι → Set α) : (⋂o, s o) = s none ∩ ⋂i, s (some i) :=
  infi_option s

section 

variable(p : ι → Prop)[DecidablePred p]

theorem Union_dite (f : ∀ i, p i → Set α) (g : ∀ i, ¬p i → Set α) :
  (⋃i, if h : p i then f i h else g i h) = (⋃(i : _)(h : p i), f i h) ∪ ⋃(i : _)(h : ¬p i), g i h :=
  supr_dite _ _ _

theorem Union_ite (f g : ι → Set α) :
  (⋃i, if p i then f i else g i) = (⋃(i : _)(h : p i), f i) ∪ ⋃(i : _)(h : ¬p i), g i :=
  Union_dite _ _ _

theorem Inter_dite (f : ∀ i, p i → Set α) (g : ∀ i, ¬p i → Set α) :
  (⋂i, if h : p i then f i h else g i h) = (⋂(i : _)(h : p i), f i h) ∩ ⋂(i : _)(h : ¬p i), g i h :=
  infi_dite _ _ _

theorem Inter_ite (f g : ι → Set α) :
  (⋂i, if p i then f i else g i) = (⋂(i : _)(h : p i), f i) ∩ ⋂(i : _)(h : ¬p i), g i :=
  Inter_dite _ _ _

end 

-- error in Data.Set.Lattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem image_projection_prod
{ι : Type*}
{α : ι → Type*}
{v : ∀ i : ι, set (α i)}
(hv : (pi univ v).nonempty)
(i : ι) : «expr = »(«expr '' »(λ
  x : ∀ i : ι, α i, x i, «expr⋂ , »((k), «expr ⁻¹' »(λ x : ∀ j : ι, α j, x k, v k))), v i) :=
begin
  classical,
  apply [expr subset.antisymm],
  { simp [] [] [] ["[", expr Inter_subset, "]"] [] [] },
  { intros [ident y, ident y_in],
    simp [] [] ["only"] ["[", expr mem_image, ",", expr mem_Inter, ",", expr mem_preimage, "]"] [] [],
    rcases [expr hv, "with", "⟨", ident z, ",", ident hz, "⟩"],
    refine [expr ⟨function.update z i y, _, update_same i y z⟩],
    rw [expr @forall_update_iff ι α _ z i y (λ i t, «expr ∈ »(t, v i))] [],
    exact [expr ⟨y_in, λ j hj, by simpa [] [] [] [] [] ["using", expr hz j]⟩] }
end

/-! ### Unions and intersections indexed by `Prop` -/


@[simp]
theorem Inter_false {s : False → Set α} : Inter s = univ :=
  infi_false

@[simp]
theorem Union_false {s : False → Set α} : Union s = ∅ :=
  supr_false

@[simp]
theorem Inter_true {s : True → Set α} : Inter s = s trivialₓ :=
  infi_true

@[simp]
theorem Union_true {s : True → Set α} : Union s = s trivialₓ :=
  supr_true

@[simp]
theorem Inter_exists {p : ι → Prop} {f : Exists p → Set α} : (⋂x, f x) = ⋂(i : _)(h : p i), f ⟨i, h⟩ :=
  infi_exists

@[simp]
theorem Union_exists {p : ι → Prop} {f : Exists p → Set α} : (⋃x, f x) = ⋃(i : _)(h : p i), f ⟨i, h⟩ :=
  supr_exists

@[simp]
theorem Union_empty : (⋃i : ι, ∅ : Set α) = ∅ :=
  supr_bot

@[simp]
theorem Inter_univ : (⋂i : ι, univ : Set α) = univ :=
  infi_top

section 

variable{s : ι → Set α}

@[simp]
theorem Union_eq_empty : (⋃i, s i) = ∅ ↔ ∀ i, s i = ∅ :=
  supr_eq_bot

@[simp]
theorem Inter_eq_univ : (⋂i, s i) = univ ↔ ∀ i, s i = univ :=
  infi_eq_top

@[simp]
theorem nonempty_Union : (⋃i, s i).Nonempty ↔ ∃ i, (s i).Nonempty :=
  by 
    simp [←ne_empty_iff_nonempty]

theorem Union_nonempty_index (s : Set α) (t : s.nonempty → Set β) : (⋃h, t h) = ⋃(x : _)(_ : x ∈ s), t ⟨x, ‹_›⟩ :=
  supr_exists

end 

@[simp]
theorem Inter_Inter_eq_left {b : β} {s : ∀ (x : β), x = b → Set α} : (⋂(x : _)(h : x = b), s x h) = s b rfl :=
  infi_infi_eq_left

@[simp]
theorem Inter_Inter_eq_right {b : β} {s : ∀ (x : β), b = x → Set α} : (⋂(x : _)(h : b = x), s x h) = s b rfl :=
  infi_infi_eq_right

@[simp]
theorem Union_Union_eq_left {b : β} {s : ∀ (x : β), x = b → Set α} : (⋃(x : _)(h : x = b), s x h) = s b rfl :=
  supr_supr_eq_left

@[simp]
theorem Union_Union_eq_right {b : β} {s : ∀ (x : β), b = x → Set α} : (⋃(x : _)(h : b = x), s x h) = s b rfl :=
  supr_supr_eq_right

theorem Inter_or {p q : Prop} (s : p ∨ q → Set α) : (⋂h, s h) = (⋂h : p, s (Or.inl h)) ∩ ⋂h : q, s (Or.inr h) :=
  infi_or

theorem Union_or {p q : Prop} (s : p ∨ q → Set α) : (⋃h, s h) = (⋃i, s (Or.inl i)) ∪ ⋃j, s (Or.inr j) :=
  supr_or

theorem Union_and {p q : Prop} (s : p ∧ q → Set α) : (⋃h, s h) = ⋃hp hq, s ⟨hp, hq⟩ :=
  supr_and

theorem Inter_and {p q : Prop} (s : p ∧ q → Set α) : (⋂h, s h) = ⋂hp hq, s ⟨hp, hq⟩ :=
  infi_and

theorem Union_comm (s : ι → ι' → Set α) : (⋃i i', s i i') = ⋃i' i, s i i' :=
  supr_comm

theorem Inter_comm (s : ι → ι' → Set α) : (⋂i i', s i i') = ⋂i' i, s i i' :=
  infi_comm

@[simp]
theorem bUnion_and (p : ι → Prop) (q : ι → ι' → Prop) (s : ∀ x y, p x ∧ q x y → Set α) :
  (⋃(x : ι)(y : ι')(h : p x ∧ q x y), s x y h) = ⋃(x : ι)(hx : p x)(y : ι')(hy : q x y), s x y ⟨hx, hy⟩ :=
  by 
    simp only [Union_and, @Union_comm _ ι']

@[simp]
theorem bUnion_and' (p : ι' → Prop) (q : ι → ι' → Prop) (s : ∀ x y, p y ∧ q x y → Set α) :
  (⋃(x : ι)(y : ι')(h : p y ∧ q x y), s x y h) = ⋃(y : ι')(hy : p y)(x : ι)(hx : q x y), s x y ⟨hy, hx⟩ :=
  by 
    simp only [Union_and, @Union_comm _ ι]

@[simp]
theorem bInter_and (p : ι → Prop) (q : ι → ι' → Prop) (s : ∀ x y, p x ∧ q x y → Set α) :
  (⋂(x : ι)(y : ι')(h : p x ∧ q x y), s x y h) = ⋂(x : ι)(hx : p x)(y : ι')(hy : q x y), s x y ⟨hx, hy⟩ :=
  by 
    simp only [Inter_and, @Inter_comm _ ι']

@[simp]
theorem bInter_and' (p : ι' → Prop) (q : ι → ι' → Prop) (s : ∀ x y, p y ∧ q x y → Set α) :
  (⋂(x : ι)(y : ι')(h : p y ∧ q x y), s x y h) = ⋂(y : ι')(hy : p y)(x : ι)(hx : q x y), s x y ⟨hy, hx⟩ :=
  by 
    simp only [Inter_and, @Inter_comm _ ι]

@[simp]
theorem Union_Union_eq_or_left {b : β} {p : β → Prop} {s : ∀ (x : β), x = b ∨ p x → Set α} :
  (⋃x h, s x h) = s b (Or.inl rfl) ∪ ⋃(x : _)(h : p x), s x (Or.inr h) :=
  by 
    simp only [Union_or, Union_union_distrib, Union_Union_eq_left]

@[simp]
theorem Inter_Inter_eq_or_left {b : β} {p : β → Prop} {s : ∀ (x : β), x = b ∨ p x → Set α} :
  (⋂x h, s x h) = s b (Or.inl rfl) ∩ ⋂(x : _)(h : p x), s x (Or.inr h) :=
  by 
    simp only [Inter_or, Inter_inter_distrib, Inter_Inter_eq_left]

/-! ### Bounded unions and intersections -/


theorem mem_bUnion_iff {s : Set α} {t : α → Set β} {y : β} :
  (y ∈ ⋃(x : _)(_ : x ∈ s), t x) ↔ ∃ (x : _)(_ : x ∈ s), y ∈ t x :=
  by 
    simp 

theorem mem_bUnion_iff' {p : α → Prop} {t : α → Set β} {y : β} :
  (y ∈ ⋃(i : _)(h : p i), t i) ↔ ∃ (i : _)(h : p i), y ∈ t i :=
  mem_bUnion_iff

theorem mem_bInter_iff {s : Set α} {t : α → Set β} {y : β} :
  (y ∈ ⋂(x : _)(_ : x ∈ s), t x) ↔ ∀ x (_ : x ∈ s), y ∈ t x :=
  by 
    simp 

theorem mem_bUnion {s : Set α} {t : α → Set β} {x : α} {y : β} (xs : x ∈ s) (ytx : y ∈ t x) :
  y ∈ ⋃(x : _)(_ : x ∈ s), t x :=
  mem_bUnion_iff.2 ⟨x, ⟨xs, ytx⟩⟩

theorem mem_bInter {s : Set α} {t : α → Set β} {y : β} (h : ∀ x (_ : x ∈ s), y ∈ t x) : y ∈ ⋂(x : _)(_ : x ∈ s), t x :=
  mem_bInter_iff.2 h

theorem bUnion_subset {s : Set α} {t : Set β} {u : α → Set β} (h : ∀ x (_ : x ∈ s), u x ⊆ t) :
  (⋃(x : _)(_ : x ∈ s), u x) ⊆ t :=
  Union_subset$ fun x => Union_subset (h x)

theorem subset_bInter {s : Set α} {t : Set β} {u : α → Set β} (h : ∀ x (_ : x ∈ s), t ⊆ u x) :
  t ⊆ ⋂(x : _)(_ : x ∈ s), u x :=
  subset_Inter$ fun x => subset_Inter$ h x

theorem subset_bUnion_of_mem {s : Set α} {u : α → Set β} {x : α} (xs : x ∈ s) : u x ⊆ ⋃(x : _)(_ : x ∈ s), u x :=
  show u x ≤ ⨆(x : _)(_ : x ∈ s), u x from le_supr_of_le x$ le_supr _ xs

theorem bInter_subset_of_mem {s : Set α} {t : α → Set β} {x : α} (xs : x ∈ s) : (⋂(x : _)(_ : x ∈ s), t x) ⊆ t x :=
  show (⨅(x : _)(_ : x ∈ s), t x) ≤ t x from infi_le_of_le x$ infi_le _ xs

theorem bUnion_subset_bUnion_left {s s' : Set α} {t : α → Set β} (h : s ⊆ s') :
  (⋃(x : _)(_ : x ∈ s), t x) ⊆ ⋃(x : _)(_ : x ∈ s'), t x :=
  bUnion_subset fun x xs => subset_bUnion_of_mem (h xs)

theorem bInter_subset_bInter_left {s s' : Set α} {t : α → Set β} (h : s' ⊆ s) :
  (⋂(x : _)(_ : x ∈ s), t x) ⊆ ⋂(x : _)(_ : x ∈ s'), t x :=
  subset_bInter fun x xs => bInter_subset_of_mem (h xs)

theorem bUnion_subset_bUnion {γ : Type _} {s : Set α} {t : α → Set β} {s' : Set γ} {t' : γ → Set β}
  (h : ∀ x (_ : x ∈ s), ∃ (y : _)(_ : y ∈ s'), t x ⊆ t' y) : (⋃(x : _)(_ : x ∈ s), t x) ⊆ ⋃(y : _)(_ : y ∈ s'), t' y :=
  by 
    simp only [Union_subset_iff]
    rintro a a_in x ha 
    rcases h a a_in with ⟨c, c_in, hc⟩
    exact mem_bUnion c_in (hc ha)

theorem bInter_mono' {s s' : Set α} {t t' : α → Set β} (hs : s ⊆ s') (h : ∀ x (_ : x ∈ s), t x ⊆ t' x) :
  (⋂(x : _)(_ : x ∈ s'), t x) ⊆ ⋂(x : _)(_ : x ∈ s), t' x :=
  (bInter_subset_bInter_left hs).trans$ subset_bInter fun x xs => subset.trans (bInter_subset_of_mem xs) (h x xs)

theorem bInter_mono {s : Set α} {t t' : α → Set β} (h : ∀ x (_ : x ∈ s), t x ⊆ t' x) :
  (⋂(x : _)(_ : x ∈ s), t x) ⊆ ⋂(x : _)(_ : x ∈ s), t' x :=
  bInter_mono' (subset.refl s) h

theorem bInter_congr {s : Set α} {t1 t2 : α → Set β} (h : ∀ x (_ : x ∈ s), t1 x = t2 x) :
  (⋂(x : _)(_ : x ∈ s), t1 x) = ⋂(x : _)(_ : x ∈ s), t2 x :=
  subset.antisymm
    (bInter_mono
      fun x hx =>
        by 
          rw [h x hx])
    (bInter_mono
      fun x hx =>
        by 
          rw [h x hx])

theorem bUnion_mono {s : Set α} {t t' : α → Set β} (h : ∀ x (_ : x ∈ s), t x ⊆ t' x) :
  (⋃(x : _)(_ : x ∈ s), t x) ⊆ ⋃(x : _)(_ : x ∈ s), t' x :=
  bUnion_subset_bUnion fun x x_in => ⟨x, x_in, h x x_in⟩

theorem bUnion_congr {s : Set α} {t1 t2 : α → Set β} (h : ∀ x (_ : x ∈ s), t1 x = t2 x) :
  (⋃(x : _)(_ : x ∈ s), t1 x) = ⋃(x : _)(_ : x ∈ s), t2 x :=
  subset.antisymm
    (bUnion_mono
      fun x hx =>
        by 
          rw [h x hx])
    (bUnion_mono
      fun x hx =>
        by 
          rw [h x hx])

theorem bUnion_eq_Union (s : Set α) (t : ∀ x (_ : x ∈ s), Set β) : (⋃(x : _)(_ : x ∈ s), t x ‹_›) = ⋃x : s, t x x.2 :=
  supr_subtype'

theorem bInter_eq_Inter (s : Set α) (t : ∀ x (_ : x ∈ s), Set β) : (⋂(x : _)(_ : x ∈ s), t x ‹_›) = ⋂x : s, t x x.2 :=
  infi_subtype'

theorem Union_subtype (p : α → Prop) (s : { x // p x } → Set β) :
  (⋃x : { x // p x }, s x) = ⋃(x : _)(hx : p x), s ⟨x, hx⟩ :=
  supr_subtype

theorem Inter_subtype (p : α → Prop) (s : { x // p x } → Set β) :
  (⋂x : { x // p x }, s x) = ⋂(x : _)(hx : p x), s ⟨x, hx⟩ :=
  infi_subtype

theorem bInter_empty (u : α → Set β) : (⋂(x : _)(_ : x ∈ (∅ : Set α)), u x) = univ :=
  infi_emptyset

theorem bInter_univ (u : α → Set β) : (⋂(x : _)(_ : x ∈ @univ α), u x) = ⋂x, u x :=
  infi_univ

@[simp]
theorem bUnion_self (s : Set α) : (⋃(x : _)(_ : x ∈ s), s) = s :=
  subset.antisymm (bUnion_subset$ fun x hx => subset.refl s) fun x hx => mem_bUnion hx hx

@[simp]
theorem Union_nonempty_self (s : Set α) : (⋃h : s.nonempty, s) = s :=
  by 
    rw [Union_nonempty_index, bUnion_self]

theorem bInter_singleton (a : α) (s : α → Set β) : (⋂(x : _)(_ : x ∈ ({a} : Set α)), s x) = s a :=
  infi_singleton

theorem bInter_union (s t : Set α) (u : α → Set β) :
  (⋂(x : _)(_ : x ∈ s ∪ t), u x) = (⋂(x : _)(_ : x ∈ s), u x) ∩ ⋂(x : _)(_ : x ∈ t), u x :=
  infi_union

theorem bInter_insert (a : α) (s : Set α) (t : α → Set β) :
  (⋂(x : _)(_ : x ∈ insert a s), t x) = t a ∩ ⋂(x : _)(_ : x ∈ s), t x :=
  by 
    simp 

theorem bInter_pair (a b : α) (s : α → Set β) : (⋂(x : _)(_ : x ∈ ({a, b} : Set α)), s x) = s a ∩ s b :=
  by 
    rw [bInter_insert, bInter_singleton]

-- error in Data.Set.Lattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem bInter_inter
{ι α : Type*}
{s : set ι}
(hs : s.nonempty)
(f : ι → set α)
(t : set α) : «expr = »(«expr⋂ , »((i «expr ∈ » s), «expr ∩ »(f i, t)), «expr ∩ »(«expr⋂ , »((i «expr ∈ » s), f i), t)) :=
begin
  haveI [] [":", expr nonempty s] [":=", expr hs.to_subtype],
  simp [] [] [] ["[", expr bInter_eq_Inter, ",", "<-", expr Inter_inter, "]"] [] []
end

theorem inter_bInter {ι α : Type _} {s : Set ι} (hs : s.nonempty) (f : ι → Set α) (t : Set α) :
  (⋂(i : _)(_ : i ∈ s), t ∩ f i) = t ∩ ⋂(i : _)(_ : i ∈ s), f i :=
  by 
    rw [inter_comm, ←bInter_inter hs]
    simp [inter_comm]

theorem bUnion_empty (s : α → Set β) : (⋃(x : _)(_ : x ∈ (∅ : Set α)), s x) = ∅ :=
  supr_emptyset

theorem bUnion_univ (s : α → Set β) : (⋃(x : _)(_ : x ∈ @univ α), s x) = ⋃x, s x :=
  supr_univ

theorem bUnion_singleton (a : α) (s : α → Set β) : (⋃(x : _)(_ : x ∈ ({a} : Set α)), s x) = s a :=
  supr_singleton

@[simp]
theorem bUnion_of_singleton (s : Set α) : (⋃(x : _)(_ : x ∈ s), {x}) = s :=
  ext$
    by 
      simp 

theorem bUnion_union (s t : Set α) (u : α → Set β) :
  (⋃(x : _)(_ : x ∈ s ∪ t), u x) = (⋃(x : _)(_ : x ∈ s), u x) ∪ ⋃(x : _)(_ : x ∈ t), u x :=
  supr_union

@[simp]
theorem Union_coe_set {α β : Type _} (s : Set α) (f : α → Set β) : (⋃i : s, f i) = ⋃(i : _)(_ : i ∈ s), f i :=
  Union_subtype _ _

@[simp]
theorem Inter_coe_set {α β : Type _} (s : Set α) (f : α → Set β) : (⋂i : s, f i) = ⋂(i : _)(_ : i ∈ s), f i :=
  Inter_subtype _ _

theorem bUnion_insert (a : α) (s : Set α) (t : α → Set β) :
  (⋃(x : _)(_ : x ∈ insert a s), t x) = t a ∪ ⋃(x : _)(_ : x ∈ s), t x :=
  by 
    simp 

theorem bUnion_pair (a b : α) (s : α → Set β) : (⋃(x : _)(_ : x ∈ ({a, b} : Set α)), s x) = s a ∪ s b :=
  by 
    simp 

theorem compl_bUnion (s : Set α) (t : α → Set β) :
  «expr ᶜ» (⋃(i : _)(_ : i ∈ s), t i) = ⋂(i : _)(_ : i ∈ s), «expr ᶜ» (t i) :=
  by 
    simp 

theorem compl_bInter (s : Set α) (t : α → Set β) :
  «expr ᶜ» (⋂(i : _)(_ : i ∈ s), t i) = ⋃(i : _)(_ : i ∈ s), «expr ᶜ» (t i) :=
  by 
    simp 

theorem inter_bUnion (s : Set α) (t : α → Set β) (u : Set β) :
  (u ∩ ⋃(i : _)(_ : i ∈ s), t i) = ⋃(i : _)(_ : i ∈ s), u ∩ t i :=
  by 
    simp only [inter_Union]

theorem bUnion_inter (s : Set α) (t : α → Set β) (u : Set β) :
  (⋃(i : _)(_ : i ∈ s), t i) ∩ u = ⋃(i : _)(_ : i ∈ s), t i ∩ u :=
  by 
    simp only [@inter_comm _ _ u, inter_bUnion]

theorem mem_sUnion_of_mem {x : α} {t : Set α} {S : Set (Set α)} (hx : x ∈ t) (ht : t ∈ S) : x ∈ ⋃₀S :=
  ⟨t, ht, hx⟩

theorem not_mem_of_not_mem_sUnion {x : α} {t : Set α} {S : Set (Set α)} (hx : x ∉ ⋃₀S) (ht : t ∈ S) : x ∉ t :=
  fun h => hx ⟨t, ht, h⟩

theorem sInter_subset_of_mem {S : Set (Set α)} {t : Set α} (tS : t ∈ S) : ⋂₀S ⊆ t :=
  Inf_le tS

theorem subset_sUnion_of_mem {S : Set (Set α)} {t : Set α} (tS : t ∈ S) : t ⊆ ⋃₀S :=
  le_Sup tS

theorem subset_sUnion_of_subset {s : Set α} (t : Set (Set α)) (u : Set α) (h₁ : s ⊆ u) (h₂ : u ∈ t) : s ⊆ ⋃₀t :=
  subset.trans h₁ (subset_sUnion_of_mem h₂)

theorem sUnion_subset {S : Set (Set α)} {t : Set α} (h : ∀ t' (_ : t' ∈ S), t' ⊆ t) : ⋃₀S ⊆ t :=
  Sup_le h

@[simp]
theorem sUnion_subset_iff {s : Set (Set α)} {t : Set α} : ⋃₀s ⊆ t ↔ ∀ t' (_ : t' ∈ s), t' ⊆ t :=
  @Sup_le_iff (Set α) _ _ _

theorem subset_sInter {S : Set (Set α)} {t : Set α} (h : ∀ t' (_ : t' ∈ S), t ⊆ t') : t ⊆ ⋂₀S :=
  le_Inf h

@[simp]
theorem subset_sInter_iff {S : Set (Set α)} {t : Set α} : t ⊆ ⋂₀S ↔ ∀ t' (_ : t' ∈ S), t ⊆ t' :=
  @le_Inf_iff (Set α) _ _ _

theorem sUnion_subset_sUnion {S T : Set (Set α)} (h : S ⊆ T) : ⋃₀S ⊆ ⋃₀T :=
  sUnion_subset$ fun s hs => subset_sUnion_of_mem (h hs)

theorem sInter_subset_sInter {S T : Set (Set α)} (h : S ⊆ T) : ⋂₀T ⊆ ⋂₀S :=
  subset_sInter$ fun s hs => sInter_subset_of_mem (h hs)

@[simp]
theorem sUnion_empty : ⋃₀∅ = (∅ : Set α) :=
  Sup_empty

@[simp]
theorem sInter_empty : ⋂₀∅ = (univ : Set α) :=
  Inf_empty

@[simp]
theorem sUnion_singleton (s : Set α) : ⋃₀{s} = s :=
  Sup_singleton

@[simp]
theorem sInter_singleton (s : Set α) : ⋂₀{s} = s :=
  Inf_singleton

@[simp]
theorem sUnion_eq_empty {S : Set (Set α)} : ⋃₀S = ∅ ↔ ∀ s (_ : s ∈ S), s = ∅ :=
  Sup_eq_bot

@[simp]
theorem sInter_eq_univ {S : Set (Set α)} : ⋂₀S = univ ↔ ∀ s (_ : s ∈ S), s = univ :=
  Inf_eq_top

@[simp]
theorem nonempty_sUnion {S : Set (Set α)} : (⋃₀S).Nonempty ↔ ∃ (s : _)(_ : s ∈ S), Set.Nonempty s :=
  by 
    simp [←ne_empty_iff_nonempty]

theorem nonempty.of_sUnion {s : Set (Set α)} (h : (⋃₀s).Nonempty) : s.nonempty :=
  let ⟨s, hs, _⟩ := nonempty_sUnion.1 h
  ⟨s, hs⟩

theorem nonempty.of_sUnion_eq_univ [Nonempty α] {s : Set (Set α)} (h : ⋃₀s = univ) : s.nonempty :=
  nonempty.of_sUnion$ h.symm ▸ univ_nonempty

theorem sUnion_union (S T : Set (Set α)) : ⋃₀(S ∪ T) = ⋃₀S ∪ ⋃₀T :=
  Sup_union

theorem sInter_union (S T : Set (Set α)) : ⋂₀(S ∪ T) = ⋂₀S ∩ ⋂₀T :=
  Inf_union

theorem sInter_Union (s : ι → Set (Set α)) : (⋂₀⋃i, s i) = ⋂i, ⋂₀s i :=
  by 
    ext x 
    simp only [mem_Union, mem_Inter, mem_sInter, exists_imp_distrib]
    split  <;> tauto

@[simp]
theorem sUnion_insert (s : Set α) (T : Set (Set α)) : ⋃₀insert s T = s ∪ ⋃₀T :=
  Sup_insert

@[simp]
theorem sInter_insert (s : Set α) (T : Set (Set α)) : ⋂₀insert s T = s ∩ ⋂₀T :=
  Inf_insert

theorem sUnion_pair (s t : Set α) : ⋃₀{s, t} = s ∪ t :=
  Sup_pair

theorem sInter_pair (s t : Set α) : ⋂₀{s, t} = s ∩ t :=
  Inf_pair

@[simp]
theorem sUnion_image (f : α → Set β) (s : Set α) : ⋃₀(f '' s) = ⋃(x : _)(_ : x ∈ s), f x :=
  Sup_image

@[simp]
theorem sInter_image (f : α → Set β) (s : Set α) : ⋂₀(f '' s) = ⋂(x : _)(_ : x ∈ s), f x :=
  Inf_image

@[simp]
theorem sUnion_range (f : ι → Set β) : ⋃₀range f = ⋃x, f x :=
  rfl

@[simp]
theorem sInter_range (f : ι → Set β) : ⋂₀range f = ⋂x, f x :=
  rfl

theorem Union_eq_univ_iff {f : ι → Set α} : (⋃i, f i) = univ ↔ ∀ x, ∃ i, x ∈ f i :=
  by 
    simp only [eq_univ_iff_forall, mem_Union]

theorem bUnion_eq_univ_iff {f : α → Set β} {s : Set α} :
  (⋃(x : _)(_ : x ∈ s), f x) = univ ↔ ∀ y, ∃ (x : _)(_ : x ∈ s), y ∈ f x :=
  by 
    simp only [Union_eq_univ_iff, mem_Union]

theorem sUnion_eq_univ_iff {c : Set (Set α)} : ⋃₀c = univ ↔ ∀ a, ∃ (b : _)(_ : b ∈ c), a ∈ b :=
  by 
    simp only [eq_univ_iff_forall, mem_sUnion]

theorem Inter_eq_empty_iff {f : ι → Set α} : (⋂i, f i) = ∅ ↔ ∀ x, ∃ i, x ∉ f i :=
  by 
    simp [Set.eq_empty_iff_forall_not_mem]

theorem bInter_eq_empty_iff {f : α → Set β} {s : Set α} :
  (⋂(x : _)(_ : x ∈ s), f x) = ∅ ↔ ∀ y, ∃ (x : _)(_ : x ∈ s), y ∉ f x :=
  by 
    simp [Set.eq_empty_iff_forall_not_mem]

theorem sInter_eq_empty_iff {c : Set (Set α)} : ⋂₀c = ∅ ↔ ∀ a, ∃ (b : _)(_ : b ∈ c), a ∉ b :=
  by 
    simp [Set.eq_empty_iff_forall_not_mem]

@[simp]
theorem nonempty_Inter {f : ι → Set α} : (⋂i, f i).Nonempty ↔ ∃ x, ∀ i, x ∈ f i :=
  by 
    simp [←ne_empty_iff_nonempty, Inter_eq_empty_iff]

@[simp]
theorem nonempty_bInter {f : α → Set β} {s : Set α} :
  (⋂(x : _)(_ : x ∈ s), f x).Nonempty ↔ ∃ y, ∀ x (_ : x ∈ s), y ∈ f x :=
  by 
    simp [←ne_empty_iff_nonempty, Inter_eq_empty_iff]

@[simp]
theorem nonempty_sInter {c : Set (Set α)} : (⋂₀c).Nonempty ↔ ∃ a, ∀ b (_ : b ∈ c), a ∈ b :=
  by 
    simp [←ne_empty_iff_nonempty, sInter_eq_empty_iff]

theorem compl_sUnion (S : Set (Set α)) : «expr ᶜ» (⋃₀S) = ⋂₀(compl '' S) :=
  ext$
    fun x =>
      by 
        simp 

theorem sUnion_eq_compl_sInter_compl (S : Set (Set α)) : ⋃₀S = «expr ᶜ» (⋂₀(compl '' S)) :=
  by 
    rw [←compl_compl (⋃₀S), compl_sUnion]

theorem compl_sInter (S : Set (Set α)) : «expr ᶜ» (⋂₀S) = ⋃₀(compl '' S) :=
  by 
    rw [sUnion_eq_compl_sInter_compl, compl_compl_image]

theorem sInter_eq_compl_sUnion_compl (S : Set (Set α)) : ⋂₀S = «expr ᶜ» (⋃₀(compl '' S)) :=
  by 
    rw [←compl_compl (⋂₀S), compl_sInter]

theorem inter_empty_of_inter_sUnion_empty {s t : Set α} {S : Set (Set α)} (hs : t ∈ S) (h : s ∩ ⋃₀S = ∅) : s ∩ t = ∅ :=
  eq_empty_of_subset_empty$
    by 
      rw [←h] <;> exact inter_subset_inter_right _ (subset_sUnion_of_mem hs)

theorem range_sigma_eq_Union_range {γ : α → Type _} (f : Sigma γ → β) : range f = ⋃a, range fun b => f ⟨a, b⟩ :=
  Set.ext$
    by 
      simp 

-- error in Data.Set.Lattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem Union_eq_range_sigma
(s : α → set β) : «expr = »(«expr⋃ , »((i), s i), range (λ a : «exprΣ , »((i), s i), a.2)) :=
by simp [] [] [] ["[", expr set.ext_iff, "]"] [] []

theorem Union_image_preimage_sigma_mk_eq_self {ι : Type _} {σ : ι → Type _} (s : Set (Sigma σ)) :
  (⋃i, Sigma.mk i '' (Sigma.mk i ⁻¹' s)) = s :=
  by 
    ext x 
    simp only [mem_Union, mem_image, mem_preimage]
    split 
    ·
      rintro ⟨i, a, h, rfl⟩
      exact h
    ·
      intro h 
      cases' x with i a 
      exact ⟨i, a, h, rfl⟩

theorem sUnion_mono {s t : Set (Set α)} (h : s ⊆ t) : ⋃₀s ⊆ ⋃₀t :=
  sUnion_subset$ fun t' ht' => subset_sUnion_of_mem$ h ht'

theorem Union_subset_Union {s t : ι → Set α} (h : ∀ i, s i ⊆ t i) : (⋃i, s i) ⊆ ⋃i, t i :=
  @supr_le_supr (Set α) ι _ s t h

theorem Union_subset_Union2 {s : ι → Set α} {t : ι₂ → Set α} (h : ∀ i, ∃ j, s i ⊆ t j) : (⋃i, s i) ⊆ ⋃i, t i :=
  @supr_le_supr2 (Set α) ι ι₂ _ s t h

theorem Union_subset_Union_const {s : Set α} (h : ι → ι₂) : (⋃i : ι, s) ⊆ ⋃j : ι₂, s :=
  @supr_le_supr_const (Set α) ι ι₂ _ s h

@[simp]
theorem Union_of_singleton (α : Type _) : (⋃x, {x} : Set α) = univ :=
  Union_eq_univ_iff.2$ fun x => ⟨x, rfl⟩

@[simp]
theorem Union_of_singleton_coe (s : Set α) : (⋃i : s, {i} : Set α) = s :=
  by 
    simp 

theorem bUnion_subset_Union (s : Set α) (t : α → Set β) : (⋃(x : _)(_ : x ∈ s), t x) ⊆ ⋃x, t x :=
  Union_subset_Union$
    fun i =>
      Union_subset$
        fun h =>
          by 
            rfl

theorem sUnion_eq_bUnion {s : Set (Set α)} : ⋃₀s = ⋃(i : Set α)(h : i ∈ s), i :=
  by 
    rw [←sUnion_image, image_id']

theorem sInter_eq_bInter {s : Set (Set α)} : ⋂₀s = ⋂(i : Set α)(h : i ∈ s), i :=
  by 
    rw [←sInter_image, image_id']

theorem sUnion_eq_Union {s : Set (Set α)} : ⋃₀s = ⋃i : s, i :=
  by 
    simp only [←sUnion_range, Subtype.range_coe]

theorem sInter_eq_Inter {s : Set (Set α)} : ⋂₀s = ⋂i : s, i :=
  by 
    simp only [←sInter_range, Subtype.range_coe]

theorem union_eq_Union {s₁ s₂ : Set α} : s₁ ∪ s₂ = ⋃b : Bool, cond b s₁ s₂ :=
  sup_eq_supr s₁ s₂

theorem inter_eq_Inter {s₁ s₂ : Set α} : s₁ ∩ s₂ = ⋂b : Bool, cond b s₁ s₂ :=
  inf_eq_infi s₁ s₂

theorem sInter_union_sInter {S T : Set (Set α)} : ⋂₀S ∪ ⋂₀T = ⋂(p : _)(_ : p ∈ S.prod T), (p : Set α × Set α).1 ∪ p.2 :=
  Inf_sup_Inf

theorem sUnion_inter_sUnion {s t : Set (Set α)} : ⋃₀s ∩ ⋃₀t = ⋃(p : _)(_ : p ∈ s.prod t), (p : Set α × Set α).1 ∩ p.2 :=
  Sup_inf_Sup

theorem bUnion_Union (s : ι → Set α) (t : α → Set β) :
  (⋃(x : _)(_ : x ∈ ⋃i, s i), t x) = ⋃(i : _)(x : _)(_ : x ∈ s i), t x :=
  by 
    simp [@Union_comm _ ι]

/-- If `S` is a set of sets, and each `s ∈ S` can be represented as an intersection
of sets `T s hs`, then `⋂₀ S` is the intersection of the union of all `T s hs`. -/
theorem sInter_bUnion {S : Set (Set α)} {T : ∀ s (_ : s ∈ S), Set (Set α)} (hT : ∀ s (_ : s ∈ S), s = ⋂₀T s ‹s ∈ S›) :
  (⋂₀⋃(s : _)(_ : s ∈ S), T s ‹_›) = ⋂₀S :=
  by 
    ext 
    simp only [and_imp, exists_prop, Set.mem_sInter, Set.mem_Union, exists_imp_distrib]
    split 
    ·
      rintro H s sS 
      rw [hT s sS, mem_sInter]
      exact fun t => H t s sS
    ·
      rintro H t s sS tTs 
      suffices  : s ⊆ t 
      exact this (H s sS)
      rw [hT s sS, sInter_eq_bInter]
      exact bInter_subset_of_mem tTs

/-- If `S` is a set of sets, and each `s ∈ S` can be represented as an union
of sets `T s hs`, then `⋃₀ S` is the union of the union of all `T s hs`. -/
theorem sUnion_bUnion {S : Set (Set α)} {T : ∀ s (_ : s ∈ S), Set (Set α)} (hT : ∀ s (_ : s ∈ S), s = ⋃₀T s ‹_›) :
  (⋃₀⋃(s : _)(_ : s ∈ S), T s ‹_›) = ⋃₀S :=
  by 
    ext 
    simp only [exists_prop, Set.mem_Union, Set.mem_set_of_eq]
    split 
    ·
      rintro ⟨t, ⟨s, sS, tTs⟩, xt⟩
      refine' ⟨s, sS, _⟩
      rw [hT s sS]
      exact subset_sUnion_of_mem tTs xt
    ·
      rintro ⟨s, sS, xs⟩
      rw [hT s sS] at xs 
      rcases mem_sUnion.1 xs with ⟨t, tTs, xt⟩
      exact ⟨t, ⟨s, sS, tTs⟩, xt⟩

-- error in Data.Set.Lattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem Union_range_eq_sUnion
{α β : Type*}
(C : set (set α))
{f : ∀ s : C, β → s}
(hf : ∀ s : C, surjective (f s)) : «expr = »(«expr⋃ , »((y : β), range (λ s : C, (f s y).val)), «expr⋃₀ »(C)) :=
begin
  ext [] [ident x] [],
  split,
  { rintro ["⟨", ident s, ",", "⟨", ident y, ",", ident rfl, "⟩", ",", "⟨", ident s, ",", ident hs, "⟩", ",", ident rfl, "⟩"],
    refine [expr ⟨_, hs, _⟩],
    exact [expr (f ⟨s, hs⟩ y).2] },
  { rintro ["⟨", ident s, ",", ident hs, ",", ident hx, "⟩"],
    cases [expr hf ⟨s, hs⟩ ⟨x, hx⟩] ["with", ident y, ident hy],
    refine [expr ⟨_, ⟨y, rfl⟩, ⟨s, hs⟩, _⟩],
    exact [expr congr_arg subtype.val hy] }
end

-- error in Data.Set.Lattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem Union_range_eq_Union
{ι α β : Type*}
(C : ι → set α)
{f : ∀ x : ι, β → C x}
(hf : ∀ x : ι, surjective (f x)) : «expr = »(«expr⋃ , »((y : β), range (λ x : ι, (f x y).val)), «expr⋃ , »((x), C x)) :=
begin
  ext [] [ident x] [],
  rw ["[", expr mem_Union, ",", expr mem_Union, "]"] [],
  split,
  { rintro ["⟨", ident y, ",", ident i, ",", ident rfl, "⟩"],
    exact [expr ⟨i, (f i y).2⟩] },
  { rintro ["⟨", ident i, ",", ident hx, "⟩"],
    cases [expr hf i ⟨x, hx⟩] ["with", ident y, ident hy],
    exact [expr ⟨y, i, congr_arg subtype.val hy⟩] }
end

theorem union_distrib_Inter_right {ι : Type _} (s : ι → Set α) (t : Set α) : (⋂i, s i) ∪ t = ⋂i, s i ∪ t :=
  infi_sup_eq _ _

theorem union_distrib_Inter_left {ι : Type _} (s : ι → Set α) (t : Set α) : (t ∪ ⋂i, s i) = ⋂i, t ∪ s i :=
  sup_infi_eq _ _

theorem union_distrib_bInter_left {ι : Type _} (s : ι → Set α) (u : Set ι) (t : Set α) :
  (t ∪ ⋂(i : _)(_ : i ∈ u), s i) = ⋂(i : _)(_ : i ∈ u), t ∪ s i :=
  by 
    rw [bInter_eq_Inter, bInter_eq_Inter, union_distrib_Inter_left]

theorem union_distrib_bInter_right {ι : Type _} (s : ι → Set α) (u : Set ι) (t : Set α) :
  (⋂(i : _)(_ : i ∈ u), s i) ∪ t = ⋂(i : _)(_ : i ∈ u), s i ∪ t :=
  by 
    rw [bInter_eq_Inter, bInter_eq_Inter, union_distrib_Inter_right]

section Function

/-! ### `maps_to` -/


theorem maps_to_sUnion {S : Set (Set α)} {t : Set β} {f : α → β} (H : ∀ s (_ : s ∈ S), maps_to f s t) :
  maps_to f (⋃₀S) t :=
  fun x ⟨s, hs, hx⟩ => H s hs hx

theorem maps_to_Union {s : ι → Set α} {t : Set β} {f : α → β} (H : ∀ i, maps_to f (s i) t) : maps_to f (⋃i, s i) t :=
  maps_to_sUnion$ forall_range_iff.2 H

theorem maps_to_bUnion {p : ι → Prop} {s : ∀ (i : ι) (hi : p i), Set α} {t : Set β} {f : α → β}
  (H : ∀ i hi, maps_to f (s i hi) t) : maps_to f (⋃i hi, s i hi) t :=
  maps_to_Union$ fun i => maps_to_Union (H i)

theorem maps_to_Union_Union {s : ι → Set α} {t : ι → Set β} {f : α → β} (H : ∀ i, maps_to f (s i) (t i)) :
  maps_to f (⋃i, s i) (⋃i, t i) :=
  maps_to_Union$ fun i => (H i).mono (subset.refl _) (subset_Union t i)

theorem maps_to_bUnion_bUnion {p : ι → Prop} {s : ∀ i (hi : p i), Set α} {t : ∀ i (hi : p i), Set β} {f : α → β}
  (H : ∀ i hi, maps_to f (s i hi) (t i hi)) : maps_to f (⋃i hi, s i hi) (⋃i hi, t i hi) :=
  maps_to_Union_Union$ fun i => maps_to_Union_Union (H i)

theorem maps_to_sInter {s : Set α} {T : Set (Set β)} {f : α → β} (H : ∀ t (_ : t ∈ T), maps_to f s t) :
  maps_to f s (⋂₀T) :=
  fun x hx t ht => H t ht hx

theorem maps_to_Inter {s : Set α} {t : ι → Set β} {f : α → β} (H : ∀ i, maps_to f s (t i)) : maps_to f s (⋂i, t i) :=
  fun x hx => mem_Inter.2$ fun i => H i hx

theorem maps_to_bInter {p : ι → Prop} {s : Set α} {t : ∀ i (hi : p i), Set β} {f : α → β}
  (H : ∀ i hi, maps_to f s (t i hi)) : maps_to f s (⋂i hi, t i hi) :=
  maps_to_Inter$ fun i => maps_to_Inter (H i)

theorem maps_to_Inter_Inter {s : ι → Set α} {t : ι → Set β} {f : α → β} (H : ∀ i, maps_to f (s i) (t i)) :
  maps_to f (⋂i, s i) (⋂i, t i) :=
  maps_to_Inter$ fun i => (H i).mono (Inter_subset s i) (subset.refl _)

theorem maps_to_bInter_bInter {p : ι → Prop} {s : ∀ i (hi : p i), Set α} {t : ∀ i (hi : p i), Set β} {f : α → β}
  (H : ∀ i hi, maps_to f (s i hi) (t i hi)) : maps_to f (⋂i hi, s i hi) (⋂i hi, t i hi) :=
  maps_to_Inter_Inter$ fun i => maps_to_Inter_Inter (H i)

theorem image_Inter_subset (s : ι → Set α) (f : α → β) : (f '' ⋂i, s i) ⊆ ⋂i, f '' s i :=
  (maps_to_Inter_Inter$ fun i => maps_to_image f (s i)).image_subset

theorem image_bInter_subset {p : ι → Prop} (s : ∀ i (hi : p i), Set α) (f : α → β) :
  (f '' ⋂i hi, s i hi) ⊆ ⋂i hi, f '' s i hi :=
  (maps_to_bInter_bInter$ fun i hi => maps_to_image f (s i hi)).image_subset

theorem image_sInter_subset (S : Set (Set α)) (f : α → β) : f '' ⋂₀S ⊆ ⋂(s : _)(_ : s ∈ S), f '' s :=
  by 
    rw [sInter_eq_bInter]
    apply image_bInter_subset

/-! ### `inj_on` -/


theorem inj_on.image_Inter_eq [Nonempty ι] {s : ι → Set α} {f : α → β} (h : inj_on f (⋃i, s i)) :
  (f '' ⋂i, s i) = ⋂i, f '' s i :=
  by 
    inhabit ι 
    refine' subset.antisymm (image_Inter_subset s f) fun y hy => _ 
    simp only [mem_Inter, mem_image_iff_bex] at hy 
    choose x hx hy using hy 
    refine' ⟨x (default ι), mem_Inter.2$ fun i => _, hy _⟩
    suffices  : x (default ι) = x i
    ·
      rw [this]
      apply hx 
    replace hx : ∀ i, x i ∈ ⋃j, s j := fun i => (subset_Union _ _) (hx i)
    apply h (hx _) (hx _)
    simp only [hy]

-- error in Data.Set.Lattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem inj_on.image_bInter_eq
{p : ι → exprProp()}
{s : ∀ (i) (hi : p i), set α}
(hp : «expr∃ , »((i), p i))
{f : α → β}
(h : inj_on f «expr⋃ , »((i
   hi), s i hi)) : «expr = »(«expr '' »(f, «expr⋂ , »((i hi), s i hi)), «expr⋂ , »((i hi), «expr '' »(f, s i hi))) :=
begin
  simp [] [] ["only"] ["[", expr Inter, ",", expr infi_subtype', "]"] [] [],
  haveI [] [":", expr nonempty {i // p i}] [":=", expr nonempty_subtype.2 hp],
  apply [expr inj_on.image_Inter_eq],
  simpa [] [] ["only"] ["[", expr Union, ",", expr supr_subtype', "]"] [] ["using", expr h]
end

theorem inj_on_Union_of_directed {s : ι → Set α} (hs : Directed (· ⊆ ·) s) {f : α → β} (hf : ∀ i, inj_on f (s i)) :
  inj_on f (⋃i, s i) :=
  by 
    intro x hx y hy hxy 
    rcases mem_Union.1 hx with ⟨i, hx⟩
    rcases mem_Union.1 hy with ⟨j, hy⟩
    rcases hs i j with ⟨k, hi, hj⟩
    exact hf k (hi hx) (hj hy) hxy

/-! ### `surj_on` -/


theorem surj_on_sUnion {s : Set α} {T : Set (Set β)} {f : α → β} (H : ∀ t (_ : t ∈ T), surj_on f s t) :
  surj_on f s (⋃₀T) :=
  fun x ⟨t, ht, hx⟩ => H t ht hx

theorem surj_on_Union {s : Set α} {t : ι → Set β} {f : α → β} (H : ∀ i, surj_on f s (t i)) : surj_on f s (⋃i, t i) :=
  surj_on_sUnion$ forall_range_iff.2 H

theorem surj_on_Union_Union {s : ι → Set α} {t : ι → Set β} {f : α → β} (H : ∀ i, surj_on f (s i) (t i)) :
  surj_on f (⋃i, s i) (⋃i, t i) :=
  surj_on_Union$ fun i => (H i).mono (subset_Union _ _) (subset.refl _)

theorem surj_on_bUnion {p : ι → Prop} {s : Set α} {t : ∀ i (hi : p i), Set β} {f : α → β}
  (H : ∀ i hi, surj_on f s (t i hi)) : surj_on f s (⋃i hi, t i hi) :=
  surj_on_Union$ fun i => surj_on_Union (H i)

theorem surj_on_bUnion_bUnion {p : ι → Prop} {s : ∀ i (hi : p i), Set α} {t : ∀ i (hi : p i), Set β} {f : α → β}
  (H : ∀ i hi, surj_on f (s i hi) (t i hi)) : surj_on f (⋃i hi, s i hi) (⋃i hi, t i hi) :=
  surj_on_Union_Union$ fun i => surj_on_Union_Union (H i)

theorem surj_on_Inter [hi : Nonempty ι] {s : ι → Set α} {t : Set β} {f : α → β} (H : ∀ i, surj_on f (s i) t)
  (Hinj : inj_on f (⋃i, s i)) : surj_on f (⋂i, s i) t :=
  by 
    intro y hy 
    rw [Hinj.image_Inter_eq, mem_Inter]
    exact fun i => H i hy

theorem surj_on_Inter_Inter [hi : Nonempty ι] {s : ι → Set α} {t : ι → Set β} {f : α → β}
  (H : ∀ i, surj_on f (s i) (t i)) (Hinj : inj_on f (⋃i, s i)) : surj_on f (⋂i, s i) (⋂i, t i) :=
  surj_on_Inter (fun i => (H i).mono (subset.refl _) (Inter_subset _ _)) Hinj

/-! ### `bij_on` -/


theorem bij_on_Union {s : ι → Set α} {t : ι → Set β} {f : α → β} (H : ∀ i, bij_on f (s i) (t i))
  (Hinj : inj_on f (⋃i, s i)) : bij_on f (⋃i, s i) (⋃i, t i) :=
  ⟨maps_to_Union_Union$ fun i => (H i).MapsTo, Hinj, surj_on_Union_Union$ fun i => (H i).SurjOn⟩

theorem bij_on_Inter [hi : Nonempty ι] {s : ι → Set α} {t : ι → Set β} {f : α → β} (H : ∀ i, bij_on f (s i) (t i))
  (Hinj : inj_on f (⋃i, s i)) : bij_on f (⋂i, s i) (⋂i, t i) :=
  ⟨maps_to_Inter_Inter$ fun i => (H i).MapsTo, hi.elim$ fun i => (H i).InjOn.mono (Inter_subset _ _),
    surj_on_Inter_Inter (fun i => (H i).SurjOn) Hinj⟩

theorem bij_on_Union_of_directed {s : ι → Set α} (hs : Directed (· ⊆ ·) s) {t : ι → Set β} {f : α → β}
  (H : ∀ i, bij_on f (s i) (t i)) : bij_on f (⋃i, s i) (⋃i, t i) :=
  bij_on_Union H$ inj_on_Union_of_directed hs fun i => (H i).InjOn

theorem bij_on_Inter_of_directed [Nonempty ι] {s : ι → Set α} (hs : Directed (· ⊆ ·) s) {t : ι → Set β} {f : α → β}
  (H : ∀ i, bij_on f (s i) (t i)) : bij_on f (⋂i, s i) (⋂i, t i) :=
  bij_on_Inter H$ inj_on_Union_of_directed hs fun i => (H i).InjOn

end Function

/-! ### `image`, `preimage` -/


section Image

theorem image_Union {f : α → β} {s : ι → Set α} : (f '' ⋃i, s i) = ⋃i, f '' s i :=
  by 
    ext1 x 
    simp [image, ←exists_and_distrib_right, @exists_swap α]

theorem image_bUnion {f : α → β} {s : ι → Set α} {p : ι → Prop} :
  (f '' ⋃(i : _)(hi : p i), s i) = ⋃(i : _)(hi : p i), f '' s i :=
  by 
    simp only [image_Union]

theorem univ_subtype {p : α → Prop} : (univ : Set (Subtype p)) = ⋃(x : _)(h : p x), {⟨x, h⟩} :=
  Set.ext$
    fun ⟨x, h⟩ =>
      by 
        simp [h]

theorem range_eq_Union {ι} (f : ι → α) : range f = ⋃i, {f i} :=
  Set.ext$
    fun a =>
      by 
        simp [@eq_comm α a]

theorem image_eq_Union (f : α → β) (s : Set α) : f '' s = ⋃(i : _)(_ : i ∈ s), {f i} :=
  Set.ext$
    fun b =>
      by 
        simp [@eq_comm β b]

theorem bUnion_range {f : ι → α} {g : α → Set β} : (⋃(x : _)(_ : x ∈ range f), g x) = ⋃y, g (f y) :=
  supr_range

@[simp]
theorem Union_Union_eq' {f : ι → α} {g : α → Set β} : (⋃(x y : _)(h : f y = x), g x) = ⋃y, g (f y) :=
  by 
    simpa using bUnion_range

theorem bInter_range {f : ι → α} {g : α → Set β} : (⋂(x : _)(_ : x ∈ range f), g x) = ⋂y, g (f y) :=
  infi_range

@[simp]
theorem Inter_Inter_eq' {f : ι → α} {g : α → Set β} : (⋂(x y : _)(h : f y = x), g x) = ⋂y, g (f y) :=
  by 
    simpa using bInter_range

variable{s : Set γ}{f : γ → α}{g : α → Set β}

theorem bUnion_image : (⋃(x : _)(_ : x ∈ f '' s), g x) = ⋃(y : _)(_ : y ∈ s), g (f y) :=
  supr_image

theorem bInter_image : (⋂(x : _)(_ : x ∈ f '' s), g x) = ⋂(y : _)(_ : y ∈ s), g (f y) :=
  infi_image

end Image

section Preimage

theorem monotone_preimage {f : α → β} : Monotone (preimage f) :=
  fun a b h => preimage_mono h

@[simp]
theorem preimage_Union {ι : Sort _} {f : α → β} {s : ι → Set β} : (f ⁻¹' ⋃i, s i) = ⋃i, f ⁻¹' s i :=
  Set.ext$
    by 
      simp [preimage]

theorem preimage_bUnion {ι} {f : α → β} {s : Set ι} {t : ι → Set β} :
  (f ⁻¹' ⋃(i : _)(_ : i ∈ s), t i) = ⋃(i : _)(_ : i ∈ s), f ⁻¹' t i :=
  by 
    simp 

@[simp]
theorem preimage_sUnion {f : α → β} {s : Set (Set β)} : f ⁻¹' ⋃₀s = ⋃(t : _)(_ : t ∈ s), f ⁻¹' t :=
  Set.ext$
    by 
      simp [preimage]

theorem preimage_Inter {ι : Sort _} {s : ι → Set β} {f : α → β} : (f ⁻¹' ⋂i, s i) = ⋂i, f ⁻¹' s i :=
  by 
    ext <;> simp 

theorem preimage_bInter {s : γ → Set β} {t : Set γ} {f : α → β} :
  (f ⁻¹' ⋂(i : _)(_ : i ∈ t), s i) = ⋂(i : _)(_ : i ∈ t), f ⁻¹' s i :=
  by 
    ext <;> simp 

@[simp]
theorem bUnion_preimage_singleton (f : α → β) (s : Set β) : (⋃(y : _)(_ : y ∈ s), f ⁻¹' {y}) = f ⁻¹' s :=
  by 
    rw [←preimage_bUnion, bUnion_of_singleton]

theorem bUnion_range_preimage_singleton (f : α → β) : (⋃(y : _)(_ : y ∈ range f), f ⁻¹' {y}) = univ :=
  by 
    rw [bUnion_preimage_singleton, preimage_range]

end Preimage

section Prod

theorem monotone_prod [Preorderₓ α] {f : α → Set β} {g : α → Set γ} (hf : Monotone f) (hg : Monotone g) :
  Monotone fun x => (f x).Prod (g x) :=
  fun a b h => prod_mono (hf h) (hg h)

alias monotone_prod ← Monotone.set_prod

theorem prod_Union {ι} {s : Set α} {t : ι → Set β} : s.prod (⋃i, t i) = ⋃i, s.prod (t i) :=
  by 
    ext 
    simp 

theorem prod_bUnion {ι} {u : Set ι} {s : Set α} {t : ι → Set β} :
  s.prod (⋃(i : _)(_ : i ∈ u), t i) = ⋃(i : _)(_ : i ∈ u), s.prod (t i) :=
  by 
    simpRw [prod_Union]

theorem prod_sUnion {s : Set α} {C : Set (Set β)} : s.prod (⋃₀C) = ⋃₀((fun t => s.prod t) '' C) :=
  by 
    simp only [sUnion_eq_bUnion, prod_bUnion, bUnion_image]

theorem Union_prod_const {ι} {s : ι → Set α} {t : Set β} : (⋃i, s i).Prod t = ⋃i, (s i).Prod t :=
  by 
    ext 
    simp 

theorem bUnion_prod_const {ι} {u : Set ι} {s : ι → Set α} {t : Set β} :
  (⋃(i : _)(_ : i ∈ u), s i).Prod t = ⋃(i : _)(_ : i ∈ u), (s i).Prod t :=
  by 
    simpRw [Union_prod_const]

-- error in Data.Set.Lattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem sUnion_prod_const
{C : set (set α)}
{t : set β} : «expr = »(«expr⋃₀ »(C).prod t, «expr⋃₀ »(«expr '' »(λ s : set α, s.prod t, C))) :=
by { simp [] [] ["only"] ["[", expr sUnion_eq_bUnion, ",", expr bUnion_prod_const, ",", expr bUnion_image, "]"] [] [] }

theorem Union_prod {ι α β} (s : ι → Set α) (t : ι → Set β) :
  (⋃x : ι × ι, (s x.1).Prod (t x.2)) = (⋃i : ι, s i).Prod (⋃i : ι, t i) :=
  by 
    ext 
    simp 

theorem Union_prod_of_monotone [SemilatticeSup α] {s : α → Set β} {t : α → Set γ} (hs : Monotone s) (ht : Monotone t) :
  (⋃x, (s x).Prod (t x)) = (⋃x, s x).Prod (⋃x, t x) :=
  by 
    ext ⟨z, w⟩
    simp only [mem_prod, mem_Union, exists_imp_distrib, and_imp, iff_def]
    split 
    ·
      intro x hz hw 
      exact ⟨⟨x, hz⟩, x, hw⟩
    ·
      intro x hz x' hw 
      exact ⟨x⊔x', hs le_sup_left hz, ht le_sup_right hw⟩

end Prod

section Image2

variable(f : α → β → γ){s : Set α}{t : Set β}

theorem Union_image_left : (⋃(a : _)(_ : a ∈ s), f a '' t) = image2 f s t :=
  by 
    ext y 
    split  <;> simp only [mem_Union] <;> rintro ⟨a, ha, x, hx, ax⟩ <;> exact ⟨a, x, ha, hx, ax⟩

theorem Union_image_right : (⋃(b : _)(_ : b ∈ t), (fun a => f a b) '' s) = image2 f s t :=
  by 
    ext y 
    split  <;> simp only [mem_Union] <;> rintro ⟨a, b, c, d, e⟩
    exact ⟨c, a, d, b, e⟩
    exact ⟨b, d, a, c, e⟩

theorem image2_Union_left (s : ι → Set α) (t : Set β) : image2 f (⋃i, s i) t = ⋃i, image2 f (s i) t :=
  by 
    simp only [←image_prod, Union_prod_const, image_Union]

theorem image2_Union_right (s : Set α) (t : ι → Set β) : image2 f s (⋃i, t i) = ⋃i, image2 f s (t i) :=
  by 
    simp only [←image_prod, prod_Union, image_Union]

end Image2

section Seq

/-- Given a set `s` of functions `α → β` and `t : set α`, `seq s t` is the union of `f '' t` over
all `f ∈ s`. -/
def seq (s : Set (α → β)) (t : Set α) : Set β :=
  { b | ∃ (f : _)(_ : f ∈ s), ∃ (a : _)(_ : a ∈ t), (f : α → β) a = b }

theorem seq_def {s : Set (α → β)} {t : Set α} : seq s t = ⋃(f : _)(_ : f ∈ s), f '' t :=
  Set.ext$
    by 
      simp [seq]

@[simp]
theorem mem_seq_iff {s : Set (α → β)} {t : Set α} {b : β} :
  b ∈ seq s t ↔ ∃ (f : _)(_ : f ∈ s)(a : _)(_ : a ∈ t), (f : α → β) a = b :=
  Iff.rfl

theorem seq_subset {s : Set (α → β)} {t : Set α} {u : Set β} :
  seq s t ⊆ u ↔ ∀ f (_ : f ∈ s), ∀ a (_ : a ∈ t), (f : α → β) a ∈ u :=
  Iff.intro (fun h f hf a ha => h ⟨f, hf, a, ha, rfl⟩) fun h b ⟨f, hf, a, ha, Eq⟩ => Eq ▸ h f hf a ha

theorem seq_mono {s₀ s₁ : Set (α → β)} {t₀ t₁ : Set α} (hs : s₀ ⊆ s₁) (ht : t₀ ⊆ t₁) : seq s₀ t₀ ⊆ seq s₁ t₁ :=
  fun b ⟨f, hf, a, ha, Eq⟩ => ⟨f, hs hf, a, ht ha, Eq⟩

theorem singleton_seq {f : α → β} {t : Set α} : Set.Seq {f} t = f '' t :=
  Set.ext$
    by 
      simp 

-- error in Data.Set.Lattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem seq_singleton {s : set (α → β)} {a : α} : «expr = »(set.seq s {a}, «expr '' »(λ f : α → β, f a, s)) :=
«expr $ »(set.ext, by simp [] [] [] [] [] [])

theorem seq_seq {s : Set (β → γ)} {t : Set (α → β)} {u : Set α} : seq s (seq t u) = seq (seq (· ∘ · '' s) t) u :=
  by 
    refine' Set.ext fun c => Iff.intro _ _
    ·
      rintro ⟨f, hfs, b, ⟨g, hg, a, hau, rfl⟩, rfl⟩
      exact ⟨f ∘ g, ⟨(· ∘ ·) f, mem_image_of_mem _ hfs, g, hg, rfl⟩, a, hau, rfl⟩
    ·
      rintro ⟨fg, ⟨fc, ⟨f, hfs, rfl⟩, g, hgt, rfl⟩, a, ha, rfl⟩
      exact ⟨f, hfs, g a, ⟨g, hgt, a, ha, rfl⟩, rfl⟩

theorem image_seq {f : β → γ} {s : Set (α → β)} {t : Set α} : f '' seq s t = seq ((· ∘ ·) f '' s) t :=
  by 
    rw [←singleton_seq, ←singleton_seq, seq_seq, image_singleton]

theorem prod_eq_seq {s : Set α} {t : Set β} : s.prod t = (Prod.mk '' s).seq t :=
  by 
    ext ⟨a, b⟩
    split 
    ·
      rintro ⟨ha, hb⟩
      exact ⟨Prod.mk a, ⟨a, ha, rfl⟩, b, hb, rfl⟩
    ·
      rintro ⟨f, ⟨x, hx, rfl⟩, y, hy, eq⟩
      rw [←Eq]
      exact ⟨hx, hy⟩

theorem prod_image_seq_comm (s : Set α) (t : Set β) : (Prod.mk '' s).seq t = seq ((fun b a => (a, b)) '' t) s :=
  by 
    rw [←prod_eq_seq, ←image_swap_prod, prod_eq_seq, image_seq, ←image_comp, Prod.swap]

theorem image2_eq_seq (f : α → β → γ) (s : Set α) (t : Set β) : image2 f s t = seq (f '' s) t :=
  by 
    ext 
    simp 

end Seq

/-! ### `set` as a monad -/


-- error in Data.Set.Lattice: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
instance : monad set :=
{ pure := λ (α : Type u) (a), {a},
  bind := λ (α β : Type u) (s f), «expr⋃ , »((i «expr ∈ » s), f i),
  seq := λ α β : Type u, set.seq,
  map := λ α β : Type u, set.image }

section Monadₓ

variable{α' β' : Type u}{s : Set α'}{f : α' → Set β'}{g : Set (α' → β')}

@[simp]
theorem bind_def : s >>= f = ⋃(i : _)(_ : i ∈ s), f i :=
  rfl

@[simp]
theorem fmap_eq_image (f : α' → β') : f <$> s = f '' s :=
  rfl

@[simp]
theorem seq_eq_set_seq {α β : Type _} (s : Set (α → β)) (t : Set α) : s <*> t = s.seq t :=
  rfl

@[simp]
theorem pure_def (a : α) : (pure a : Set α) = {a} :=
  rfl

end Monadₓ

instance  : IsLawfulMonad Set :=
  { pure_bind :=
      fun α β x f =>
        by 
          simp ,
    bind_assoc :=
      fun α β γ s f g =>
        Set.ext$
          fun a =>
            by 
              simp [exists_and_distrib_right.symm, -exists_and_distrib_right, exists_and_distrib_left.symm,
                  -exists_and_distrib_left, and_assoc] <;>
                exact exists_swap,
    id_map := fun α => id_map,
    bind_pure_comp_eq_map :=
      fun α β f s =>
        Set.ext$
          by 
            simp [Set.Image, eq_comm],
    bind_map_eq_seq :=
      fun α β s t =>
        by 
          simp [seq_def] }

instance  : IsCommApplicative (Set : Type u → Type u) :=
  ⟨fun α β s t => prod_image_seq_comm s t⟩

section Pi

variable{π : α → Type _}

theorem pi_def (i : Set α) (s : ∀ a, Set (π a)) : pi i s = ⋂(a : _)(_ : a ∈ i), eval a ⁻¹' s a :=
  by 
    ext 
    simp 

theorem univ_pi_eq_Inter (t : ∀ i, Set (π i)) : pi univ t = ⋂i, eval i ⁻¹' t i :=
  by 
    simp only [pi_def, Inter_true, mem_univ]

theorem pi_diff_pi_subset (i : Set α) (s t : ∀ a, Set (π a)) :
  pi i s \ pi i t ⊆ ⋃(a : _)(_ : a ∈ i), eval a ⁻¹' (s a \ t a) :=
  by 
    refine' diff_subset_comm.2 fun x hx a ha => _ 
    simp only [mem_diff, mem_pi, mem_Union, not_exists, mem_preimage, not_and, not_not, eval_apply] at hx 
    exact hx.2 _ ha (hx.1 _ ha)

theorem Union_univ_pi (t : ∀ i, ι → Set (π i)) :
  (⋃x : α → ι, pi univ fun i => t i (x i)) = pi univ fun i => ⋃j : ι, t i j :=
  by 
    ext 
    simp [Classical.skolem]

end Pi

end Set

namespace Function

namespace Surjective

theorem Union_comp {f : ι → ι₂} (hf : surjective f) (g : ι₂ → Set α) : (⋃x, g (f x)) = ⋃y, g y :=
  hf.supr_comp g

theorem Inter_comp {f : ι → ι₂} (hf : surjective f) (g : ι₂ → Set α) : (⋂x, g (f x)) = ⋂y, g y :=
  hf.infi_comp g

end Surjective

end Function

/-!
### Disjoint sets

We define some lemmas in the `disjoint` namespace to be able to use projection notation.
-/


section Disjoint

variable{s t u : Set α}

namespace Disjoint

theorem union_left (hs : Disjoint s u) (ht : Disjoint t u) : Disjoint (s ∪ t) u :=
  hs.sup_left ht

theorem union_right (ht : Disjoint s t) (hu : Disjoint s u) : Disjoint s (t ∪ u) :=
  ht.sup_right hu

theorem inter_left (u : Set α) (h : Disjoint s t) : Disjoint (s ∩ u) t :=
  inf_left _ h

theorem inter_left' (u : Set α) (h : Disjoint s t) : Disjoint (u ∩ s) t :=
  inf_left' _ h

theorem inter_right (u : Set α) (h : Disjoint s t) : Disjoint s (t ∩ u) :=
  inf_right _ h

theorem inter_right' (u : Set α) (h : Disjoint s t) : Disjoint s (u ∩ t) :=
  inf_right' _ h

theorem subset_left_of_subset_union (h : s ⊆ t ∪ u) (hac : Disjoint s u) : s ⊆ t :=
  hac.left_le_of_le_sup_right h

theorem subset_right_of_subset_union (h : s ⊆ t ∪ u) (hab : Disjoint s t) : s ⊆ u :=
  hab.left_le_of_le_sup_left h

theorem preimage {α β} (f : α → β) {s t : Set β} (h : Disjoint s t) : Disjoint (f ⁻¹' s) (f ⁻¹' t) :=
  fun x hx => h hx

end Disjoint

namespace Set

protected theorem disjoint_iff : Disjoint s t ↔ s ∩ t ⊆ ∅ :=
  Iff.rfl

theorem disjoint_iff_inter_eq_empty : Disjoint s t ↔ s ∩ t = ∅ :=
  disjoint_iff

theorem not_disjoint_iff : ¬Disjoint s t ↔ ∃ x, x ∈ s ∧ x ∈ t :=
  not_forall.trans$ exists_congr$ fun x => not_not

theorem not_disjoint_iff_nonempty_inter {α : Type _} {s t : Set α} : ¬Disjoint s t ↔ (s ∩ t).Nonempty :=
  by 
    simp [Set.not_disjoint_iff, Set.nonempty_def]

theorem disjoint_left : Disjoint s t ↔ ∀ {a}, a ∈ s → a ∉ t :=
  show (∀ x, ¬x ∈ s ∩ t) ↔ _ from ⟨fun h a => not_and.1$ h a, fun h a => not_and.2$ h a⟩

theorem disjoint_right : Disjoint s t ↔ ∀ {a}, a ∈ t → a ∉ s :=
  by 
    rw [Disjoint.comm, disjoint_left]

theorem disjoint_of_subset_left (h : s ⊆ u) (d : Disjoint u t) : Disjoint s t :=
  d.mono_left h

theorem disjoint_of_subset_right (h : t ⊆ u) (d : Disjoint s u) : Disjoint s t :=
  d.mono_right h

theorem disjoint_of_subset {s t u v : Set α} (h1 : s ⊆ u) (h2 : t ⊆ v) (d : Disjoint u v) : Disjoint s t :=
  d.mono h1 h2

@[simp]
theorem disjoint_union_left : Disjoint (s ∪ t) u ↔ Disjoint s u ∧ Disjoint t u :=
  disjoint_sup_left

@[simp]
theorem disjoint_union_right : Disjoint s (t ∪ u) ↔ Disjoint s t ∧ Disjoint s u :=
  disjoint_sup_right

@[simp]
theorem disjoint_Union_left {ι : Sort _} {s : ι → Set α} : Disjoint (⋃i, s i) t ↔ ∀ i, Disjoint (s i) t :=
  supr_disjoint_iff

@[simp]
theorem disjoint_Union_right {ι : Sort _} {s : ι → Set α} : Disjoint t (⋃i, s i) ↔ ∀ i, Disjoint t (s i) :=
  disjoint_supr_iff

theorem disjoint_diff {a b : Set α} : Disjoint a (b \ a) :=
  disjoint_iff.2 (inter_diff_self _ _)

@[simp]
theorem disjoint_empty (s : Set α) : Disjoint s ∅ :=
  disjoint_bot_right

@[simp]
theorem empty_disjoint (s : Set α) : Disjoint ∅ s :=
  disjoint_bot_left

@[simp]
theorem univ_disjoint {s : Set α} : Disjoint univ s ↔ s = ∅ :=
  top_disjoint

@[simp]
theorem disjoint_univ {s : Set α} : Disjoint s univ ↔ s = ∅ :=
  disjoint_top

@[simp]
theorem disjoint_singleton_left {a : α} {s : Set α} : Disjoint {a} s ↔ a ∉ s :=
  by 
    simp [Set.disjoint_iff, subset_def] <;> exact Iff.rfl

@[simp]
theorem disjoint_singleton_right {a : α} {s : Set α} : Disjoint s {a} ↔ a ∉ s :=
  by 
    rw [Disjoint.comm] <;> exact disjoint_singleton_left

@[simp]
theorem disjoint_singleton {a b : α} : Disjoint ({a} : Set α) {b} ↔ a ≠ b :=
  by 
    rw [disjoint_singleton_left, mem_singleton_iff]

theorem disjoint_image_image {f : β → α} {g : γ → α} {s : Set β} {t : Set γ}
  (h : ∀ b (_ : b ∈ s), ∀ c (_ : c ∈ t), f b ≠ g c) : Disjoint (f '' s) (g '' t) :=
  by 
    rintro a ⟨⟨b, hb, eq⟩, c, hc, rfl⟩ <;> exact h b hb c hc Eq

theorem disjoint_image_of_injective {f : α → β} (hf : injective f) {s t : Set α} (hd : Disjoint s t) :
  Disjoint (f '' s) (f '' t) :=
  disjoint_image_image$ fun x hx y hy => hf.ne$ fun H => Set.disjoint_iff.1 hd ⟨hx, H.symm ▸ hy⟩

theorem disjoint_preimage {s t : Set β} (hd : Disjoint s t) (f : α → β) : Disjoint (f ⁻¹' s) (f ⁻¹' t) :=
  fun x hx => hd hx

theorem preimage_eq_empty {f : α → β} {s : Set β} (h : Disjoint s (range f)) : f ⁻¹' s = ∅ :=
  by 
    simpa using h.preimage f

theorem preimage_eq_empty_iff {f : α → β} {s : Set β} : Disjoint s (range f) ↔ f ⁻¹' s = ∅ :=
  ⟨preimage_eq_empty,
    fun h =>
      by 
        simp [eq_empty_iff_forall_not_mem, Set.disjoint_iff_inter_eq_empty] at h⊢
        finish⟩

theorem disjoint_iff_subset_compl_right : Disjoint s t ↔ s ⊆ «expr ᶜ» t :=
  disjoint_left

theorem disjoint_iff_subset_compl_left : Disjoint s t ↔ t ⊆ «expr ᶜ» s :=
  disjoint_right

end Set

end Disjoint

namespace Set

variable(t : α → Set β)

theorem subset_diff {s t u : Set α} : s ⊆ t \ u ↔ s ⊆ t ∧ Disjoint s u :=
  ⟨fun h => ⟨fun x hxs => (h hxs).1, fun x ⟨hxs, hxu⟩ => (h hxs).2 hxu⟩,
    fun ⟨h1, h2⟩ x hxs => ⟨h1 hxs, fun hxu => h2 ⟨hxs, hxu⟩⟩⟩

theorem bUnion_diff_bUnion_subset (s₁ s₂ : Set α) :
  ((⋃(x : _)(_ : x ∈ s₁), t x) \ ⋃(x : _)(_ : x ∈ s₂), t x) ⊆ ⋃(x : _)(_ : x ∈ s₁ \ s₂), t x :=
  by 
    simp only [diff_subset_iff, ←bUnion_union]
    apply bUnion_subset_bUnion_left 
    rw [union_diff_self]
    apply subset_union_right

/-- If `t` is an indexed family of sets, then there is a natural map from `Σ i, t i` to `⋃ i, t i`
sending `⟨i, x⟩` to `x`. -/
def sigma_to_Union (x : Σi, t i) : ⋃i, t i :=
  ⟨x.2, mem_Union.2 ⟨x.1, x.2.2⟩⟩

theorem sigma_to_Union_surjective : surjective (sigma_to_Union t)
| ⟨b, hb⟩ =>
  have  : ∃ a, b ∈ t a :=
    by 
      simpa using hb 
  let ⟨a, hb⟩ := this
  ⟨⟨a, b, hb⟩, rfl⟩

theorem sigma_to_Union_injective (h : ∀ i j, i ≠ j → Disjoint (t i) (t j)) : injective (sigma_to_Union t)
| ⟨a₁, b₁, h₁⟩, ⟨a₂, b₂, h₂⟩, Eq =>
  have b_eq : b₁ = b₂ := congr_argₓ Subtype.val Eq 
  have a_eq : a₁ = a₂ :=
    Classical.by_contradiction$
      fun ne =>
        have  : b₁ ∈ t a₁ ∩ t a₂ := ⟨h₁, b_eq.symm ▸ h₂⟩
        h _ _ Ne this 
  Sigma.eq a_eq$
    Subtype.eq$
      by 
        subst b_eq <;> subst a_eq

theorem sigma_to_Union_bijective (h : ∀ i j, i ≠ j → Disjoint (t i) (t j)) : bijective (sigma_to_Union t) :=
  ⟨sigma_to_Union_injective t h, sigma_to_Union_surjective t⟩

/-- Equivalence between a disjoint union and a dependent sum. -/
noncomputable def Union_eq_sigma_of_disjoint {t : α → Set β} (h : ∀ i j, i ≠ j → Disjoint (t i) (t j)) :
  (⋃i, t i) ≃ Σi, t i :=
  (Equiv.ofBijective _$ sigma_to_Union_bijective t h).symm

end Set

