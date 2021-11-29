import Mathbin.Algebra.Order.AbsoluteValue 
import Mathbin.Algebra.BigOperators.Basic

/-!
# Results about big operators with values in an ordered algebraic structure.

Mostly monotonicity results for the `∏` and `∑` operations.

-/


open_locale BigOperators

variable{ι α β M N G k R : Type _}

namespace Finset

section OrderedCommMonoid

variable[CommMonoidₓ M][OrderedCommMonoid N]

/-- Let `{x | p x}` be a subsemigroup of a commutative monoid `M`. Let `f : M → N` be a map
submultiplicative on `{x | p x}`, i.e., `p x → p y → f (x * y) ≤ f x * f y`. Let `g i`, `i ∈ s`, be
a nonempty finite family of elements of `M` such that `∀ i ∈ s, p (g i)`. Then
`f (∏ x in s, g x) ≤ ∏ x in s, f (g x)`. -/
@[toAdditive le_sum_nonempty_of_subadditive_on_pred]
theorem le_prod_nonempty_of_submultiplicative_on_pred (f : M → N) (p : M → Prop)
  (h_mul : ∀ x y, p x → p y → f (x*y) ≤ f x*f y) (hp_mul : ∀ x y, p x → p y → p (x*y)) (g : ι → M) (s : Finset ι)
  (hs_nonempty : s.nonempty) (hs : ∀ i (_ : i ∈ s), p (g i)) : f (∏i in s, g i) ≤ ∏i in s, f (g i) :=
  by 
    refine' le_transₓ (Multiset.le_prod_nonempty_of_submultiplicative_on_pred f p h_mul hp_mul _ _ _) _
    ·
      simp [hs_nonempty.ne_empty]
    ·
      exact multiset.forall_mem_map_iff.mpr hs 
    rw [Multiset.map_map]
    rfl

/-- Let `{x | p x}` be an additive subsemigroup of an additive commutative monoid `M`. Let
`f : M → N` be a map subadditive on `{x | p x}`, i.e., `p x → p y → f (x + y) ≤ f x + f y`. Let
`g i`, `i ∈ s`, be a nonempty finite family of elements of `M` such that `∀ i ∈ s, p (g i)`. Then
`f (∑ i in s, g i) ≤ ∑ i in s, f (g i)`. -/
add_decl_doc le_sum_nonempty_of_subadditive_on_pred

/-- If `f : M → N` is a submultiplicative function, `f (x * y) ≤ f x * f y` and `g i`, `i ∈ s`, is a
nonempty finite family of elements of `M`, then `f (∏ i in s, g i) ≤ ∏ i in s, f (g i)`. -/
@[toAdditive le_sum_nonempty_of_subadditive]
theorem le_prod_nonempty_of_submultiplicative (f : M → N) (h_mul : ∀ x y, f (x*y) ≤ f x*f y) {s : Finset ι}
  (hs : s.nonempty) (g : ι → M) : f (∏i in s, g i) ≤ ∏i in s, f (g i) :=
  le_prod_nonempty_of_submultiplicative_on_pred f (fun i => True) (fun x y _ _ => h_mul x y) (fun _ _ _ _ => trivialₓ) g
    s hs fun _ _ => trivialₓ

/-- If `f : M → N` is a subadditive function, `f (x + y) ≤ f x + f y` and `g i`, `i ∈ s`, is a
nonempty finite family of elements of `M`, then `f (∑ i in s, g i) ≤ ∑ i in s, f (g i)`. -/
add_decl_doc le_sum_nonempty_of_subadditive

/-- Let `{x | p x}` be a subsemigroup of a commutative monoid `M`. Let `f : M → N` be a map
such that `f 1 = 1` and `f` is submultiplicative on `{x | p x}`, i.e.,
`p x → p y → f (x * y) ≤ f x * f y`. Let `g i`, `i ∈ s`, be a finite family of elements of `M` such
that `∀ i ∈ s, p (g i)`. Then `f (∏ i in s, g i) ≤ ∏ i in s, f (g i)`. -/
@[toAdditive le_sum_of_subadditive_on_pred]
theorem le_prod_of_submultiplicative_on_pred (f : M → N) (p : M → Prop) (h_one : f 1 = 1)
  (h_mul : ∀ x y, p x → p y → f (x*y) ≤ f x*f y) (hp_mul : ∀ x y, p x → p y → p (x*y)) (g : ι → M) {s : Finset ι}
  (hs : ∀ i (_ : i ∈ s), p (g i)) : f (∏i in s, g i) ≤ ∏i in s, f (g i) :=
  by 
    rcases eq_empty_or_nonempty s with (rfl | hs_nonempty)
    ·
      simp [h_one]
    ·
      exact le_prod_nonempty_of_submultiplicative_on_pred f p h_mul hp_mul g s hs_nonempty hs

/-- Let `{x | p x}` be a subsemigroup of a commutative additive monoid `M`. Let `f : M → N` be a map
such that `f 0 = 0` and `f` is subadditive on `{x | p x}`, i.e. `p x → p y → f (x + y) ≤ f x + f y`.
Let `g i`, `i ∈ s`, be a finite family of elements of `M` such that `∀ i ∈ s, p (g i)`. Then
`f (∑ x in s, g x) ≤ ∑ x in s, f (g x)`. -/
add_decl_doc le_sum_of_subadditive_on_pred

/-- If `f : M → N` is a submultiplicative function, `f (x * y) ≤ f x * f y`, `f 1 = 1`, and `g i`,
`i ∈ s`, is a finite family of elements of `M`, then `f (∏ i in s, g i) ≤ ∏ i in s, f (g i)`. -/
@[toAdditive le_sum_of_subadditive]
theorem le_prod_of_submultiplicative (f : M → N) (h_one : f 1 = 1) (h_mul : ∀ x y, f (x*y) ≤ f x*f y) (s : Finset ι)
  (g : ι → M) : f (∏i in s, g i) ≤ ∏i in s, f (g i) :=
  by 
    refine' le_transₓ (Multiset.le_prod_of_submultiplicative f h_one h_mul _) _ 
    rw [Multiset.map_map]
    rfl

/-- If `f : M → N` is a subadditive function, `f (x + y) ≤ f x + f y`, `f 0 = 0`, and `g i`,
`i ∈ s`, is a finite family of elements of `M`, then `f (∑ i in s, g i) ≤ ∑ i in s, f (g i)`. -/
add_decl_doc le_sum_of_subadditive

variable{f g : ι → N}{s t : Finset ι}

/-- In an ordered commutative monoid, if each factor `f i` of one finite product is less than or
equal to the corresponding factor `g i` of another finite product, then
`∏ i in s, f i ≤ ∏ i in s, g i`. -/
@[toAdditive sum_le_sum]
theorem prod_le_prod'' (h : ∀ i (_ : i ∈ s), f i ≤ g i) : (∏i in s, f i) ≤ ∏i in s, g i :=
  by 
    classical 
    induction' s using Finset.induction_on with i s hi ihs h
    ·
      rfl
    ·
      simp only [prod_insert hi]
      exact mul_le_mul' (h _ (mem_insert_self _ _)) (ihs$ fun j hj => h j (mem_insert_of_mem hj))

/-- In an ordered additive commutative monoid, if each summand `f i` of one finite sum is less than
or equal to the corresponding summand `g i` of another finite sum, then
`∑ i in s, f i ≤ ∑ i in s, g i`. -/
add_decl_doc sum_le_sum

@[toAdditive sum_nonneg]
theorem one_le_prod' (h : ∀ i (_ : i ∈ s), 1 ≤ f i) : 1 ≤ ∏i in s, f i :=
  le_transₓ
    (by 
      rw [prod_const_one])
    (prod_le_prod'' h)

@[toAdditive sum_nonpos]
theorem prod_le_one' (h : ∀ i (_ : i ∈ s), f i ≤ 1) : (∏i in s, f i) ≤ 1 :=
  (prod_le_prod'' h).trans_eq
    (by 
      rw [prod_const_one])

@[toAdditive sum_le_sum_of_subset_of_nonneg]
theorem prod_le_prod_of_subset_of_one_le' (h : s ⊆ t) (hf : ∀ i (_ : i ∈ t), i ∉ s → 1 ≤ f i) :
  (∏i in s, f i) ≤ ∏i in t, f i :=
  by 
    classical <;>
      calc (∏i in s, f i) ≤ (∏i in t \ s, f i)*∏i in s, f i :=
        le_mul_of_one_le_left'$
          one_le_prod'$
            by 
              simpa only [mem_sdiff, and_imp]_ = ∏i in t \ s ∪ s, f i :=
        (prod_union sdiff_disjoint).symm _ = ∏i in t, f i :=
        by 
          rw [sdiff_union_of_subset h]

@[toAdditive sum_mono_set_of_nonneg]
theorem prod_mono_set_of_one_le' (hf : ∀ x, 1 ≤ f x) : Monotone fun s => ∏x in s, f x :=
  fun s t hst => prod_le_prod_of_subset_of_one_le' hst$ fun x _ _ => hf x

@[toAdditive sum_le_univ_sum_of_nonneg]
theorem prod_le_univ_prod_of_one_le' [Fintype ι] {s : Finset ι} (w : ∀ x, 1 ≤ f x) : (∏x in s, f x) ≤ ∏x, f x :=
  prod_le_prod_of_subset_of_one_le' (subset_univ s) fun a _ _ => w a

-- error in Algebra.BigOperators.Order: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[to_additive #[ident sum_eq_zero_iff_of_nonneg]]
theorem prod_eq_one_iff_of_one_le' : ∀
i «expr ∈ » s, «expr ≤ »(1, f i) → «expr ↔ »(«expr = »(«expr∏ in , »((i), s, f i), 1), ∀
 i «expr ∈ » s, «expr = »(f i, 1)) :=
begin
  classical,
  apply [expr finset.induction_on s],
  exact [expr λ _, ⟨λ _ _, false.elim, λ _, rfl⟩],
  assume [binders (a s ha ih H)],
  have [] [":", expr ∀ i «expr ∈ » s, «expr ≤ »(1, f i)] [],
  from [expr λ _, «expr ∘ »(H _, mem_insert_of_mem)],
  rw ["[", expr prod_insert ha, ",", expr mul_eq_one_iff' «expr $ »(H _, mem_insert_self _ _) (one_le_prod' this), ",", expr forall_mem_insert, ",", expr ih this, "]"] []
end

@[toAdditive sum_eq_zero_iff_of_nonneg]
theorem prod_eq_one_iff_of_le_one' : (∀ i (_ : i ∈ s), f i ≤ 1) → ((∏i in s, f i) = 1 ↔ ∀ i (_ : i ∈ s), f i = 1) :=
  @prod_eq_one_iff_of_one_le' _ (OrderDual N) _ _ _

@[toAdditive single_le_sum]
theorem single_le_prod' (hf : ∀ i (_ : i ∈ s), 1 ≤ f i) {a} (h : a ∈ s) : f a ≤ ∏x in s, f x :=
  calc f a = ∏i in {a}, f i := prod_singleton.symm 
    _ ≤ ∏i in s, f i := prod_le_prod_of_subset_of_one_le' (singleton_subset_iff.2 h)$ fun i hi _ => hf i hi
    

@[toAdditive]
theorem prod_le_of_forall_le (s : Finset ι) (f : ι → N) (n : N) (h : ∀ x (_ : x ∈ s), f x ≤ n) :
  s.prod f ≤ n ^ s.card :=
  by 
    refine' (Multiset.prod_le_of_forall_le (s.val.map f) n _).trans _
    ·
      simpa using h
    ·
      simpa

@[toAdditive]
theorem le_prod_of_forall_le (s : Finset ι) (f : ι → N) (n : N) (h : ∀ x (_ : x ∈ s), n ≤ f x) :
  n ^ s.card ≤ s.prod f :=
  @Finset.prod_le_of_forall_le _ (OrderDual N) _ _ _ _ h

theorem card_bUnion_le_card_mul [DecidableEq β] (s : Finset ι) (f : ι → Finset β) (n : ℕ)
  (h : ∀ a (_ : a ∈ s), (f a).card ≤ n) : (s.bUnion f).card ≤ s.card*n :=
  card_bUnion_le.trans$ sum_le_of_forall_le _ _ _ h

variable{ι' : Type _}[DecidableEq ι']

@[toAdditive sum_fiberwise_le_sum_of_sum_fiber_nonneg]
theorem prod_fiberwise_le_prod_of_one_le_prod_fiber' {t : Finset ι'} {g : ι → ι'} {f : ι → N}
  (h : ∀ y (_ : y ∉ t), (1 : N) ≤ ∏x in s.filter fun x => g x = y, f x) :
  (∏y in t, ∏x in s.filter fun x => g x = y, f x) ≤ ∏x in s, f x :=
  calc (∏y in t, ∏x in s.filter fun x => g x = y, f x) ≤ ∏y in t ∪ s.image g, ∏x in s.filter fun x => g x = y, f x :=
    prod_le_prod_of_subset_of_one_le' (subset_union_left _ _)$ fun y hyts => h y 
    _ = ∏x in s, f x := prod_fiberwise_of_maps_to (fun x hx => mem_union.2$ Or.inr$ mem_image_of_mem _ hx) _
    

@[toAdditive sum_le_sum_fiberwise_of_sum_fiber_nonpos]
theorem prod_le_prod_fiberwise_of_prod_fiber_le_one' {t : Finset ι'} {g : ι → ι'} {f : ι → N}
  (h : ∀ y (_ : y ∉ t), (∏x in s.filter fun x => g x = y, f x) ≤ 1) :
  (∏x in s, f x) ≤ ∏y in t, ∏x in s.filter fun x => g x = y, f x :=
  @prod_fiberwise_le_prod_of_one_le_prod_fiber' _ (OrderDual N) _ _ _ _ _ _ _ h

end OrderedCommMonoid

theorem abs_sum_le_sum_abs {G : Type _} [LinearOrderedAddCommGroup G] (f : ι → G) (s : Finset ι) :
  |∑i in s, f i| ≤ ∑i in s, |f i| :=
  le_sum_of_subadditive _ abs_zero abs_add s f

theorem abs_prod {R : Type _} [LinearOrderedCommRing R] {f : ι → R} {s : Finset ι} : |∏x in s, f x| = ∏x in s, |f x| :=
  (absHom.toMonoidHom : R →* R).map_prod _ _

section Pigeonhole

variable[DecidableEq β]

theorem card_le_mul_card_image_of_maps_to {f : α → β} {s : Finset α} {t : Finset β} (Hf : ∀ a (_ : a ∈ s), f a ∈ t)
  (n : ℕ) (hn : ∀ a (_ : a ∈ t), (s.filter fun x => f x = a).card ≤ n) : s.card ≤ n*t.card :=
  calc s.card = ∑a in t, (s.filter fun x => f x = a).card := card_eq_sum_card_fiberwise Hf 
    _ ≤ ∑_ in t, n := sum_le_sum hn 
    _ = _ :=
    by 
      simp [mul_commₓ]
    

theorem card_le_mul_card_image {f : α → β} (s : Finset α) (n : ℕ)
  (hn : ∀ a (_ : a ∈ s.image f), (s.filter fun x => f x = a).card ≤ n) : s.card ≤ n*(s.image f).card :=
  card_le_mul_card_image_of_maps_to (fun x => mem_image_of_mem _) n hn

theorem mul_card_image_le_card_of_maps_to {f : α → β} {s : Finset α} {t : Finset β} (Hf : ∀ a (_ : a ∈ s), f a ∈ t)
  (n : ℕ) (hn : ∀ a (_ : a ∈ t), n ≤ (s.filter fun x => f x = a).card) : (n*t.card) ≤ s.card :=
  calc (n*t.card) = ∑_ in t, n :=
    by 
      simp [mul_commₓ]
    _ ≤ ∑a in t, (s.filter fun x => f x = a).card := sum_le_sum hn 
    _ = s.card :=
    by 
      rw [←card_eq_sum_card_fiberwise Hf]
    

theorem mul_card_image_le_card {f : α → β} (s : Finset α) (n : ℕ)
  (hn : ∀ a (_ : a ∈ s.image f), n ≤ (s.filter fun x => f x = a).card) : (n*(s.image f).card) ≤ s.card :=
  mul_card_image_le_card_of_maps_to (fun x => mem_image_of_mem _) n hn

end Pigeonhole

section DoubleCounting

variable[DecidableEq α]{s : Finset α}{B : Finset (Finset α)}{n : ℕ}

/-- If every element belongs to at most `n` finsets, then the sum of their sizes is at most `n`
times how many they are. -/
theorem sum_card_inter_le (h : ∀ a (_ : a ∈ s), (B.filter$ (· ∈ ·) a).card ≤ n) : (∑t in B, (s ∩ t).card) ≤ s.card*n :=
  by 
    refine' le_transₓ _ (s.sum_le_of_forall_le _ _ h)
    simpRw [←filter_mem_eq_inter, card_eq_sum_ones, sum_filter]
    exact sum_comm.le

/-- If every element belongs to at most `n` finsets, then the sum of their sizes is at most `n`
times how many they are. -/
theorem sum_card_le [Fintype α] (h : ∀ a, (B.filter$ (· ∈ ·) a).card ≤ n) : (∑s in B, s.card) ≤ Fintype.card α*n :=
  calc (∑s in B, s.card) = ∑s in B, (univ ∩ s).card :=
    by 
      simpRw [univ_inter]
    _ ≤ Fintype.card α*n := sum_card_inter_le fun a _ => h a
    

/-- If every element belongs to at least `n` finsets, then the sum of their sizes is at least `n`
times how many they are. -/
theorem le_sum_card_inter (h : ∀ a (_ : a ∈ s), n ≤ (B.filter$ (· ∈ ·) a).card) : (s.card*n) ≤ ∑t in B, (s ∩ t).card :=
  by 
    apply (s.le_sum_of_forall_le _ _ h).trans 
    simpRw [←filter_mem_eq_inter, card_eq_sum_ones, sum_filter]
    exact sum_comm.le

/-- If every element belongs to at least `n` finsets, then the sum of their sizes is at least `n`
times how many they are. -/
theorem le_sum_card [Fintype α] (h : ∀ a, n ≤ (B.filter$ (· ∈ ·) a).card) : (Fintype.card α*n) ≤ ∑s in B, s.card :=
  calc (Fintype.card α*n) ≤ ∑s in B, (univ ∩ s).card := le_sum_card_inter fun a _ => h a 
    _ = ∑s in B, s.card :=
    by 
      simpRw [univ_inter]
    

/-- If every element belongs to exactly `n` finsets, then the sum of their sizes is `n` times how
many they are. -/
theorem sum_card_inter (h : ∀ a (_ : a ∈ s), (B.filter$ (· ∈ ·) a).card = n) : (∑t in B, (s ∩ t).card) = s.card*n :=
  (sum_card_inter_le$ fun a ha => (h a ha).le).antisymm (le_sum_card_inter$ fun a ha => (h a ha).Ge)

/-- If every element belongs to exactly `n` finsets, then the sum of their sizes is `n` times how
many they are. -/
theorem sum_card [Fintype α] (h : ∀ a, (B.filter$ (· ∈ ·) a).card = n) : (∑s in B, s.card) = Fintype.card α*n :=
  by 
    simpRw [Fintype.card, ←sum_card_inter fun a _ => h a, univ_inter]

end DoubleCounting

section CanonicallyOrderedMonoid

variable[CanonicallyOrderedMonoid M]{f : ι → M}{s t : Finset ι}

@[simp, toAdditive sum_eq_zero_iff]
theorem prod_eq_one_iff' : (∏x in s, f x) = 1 ↔ ∀ x (_ : x ∈ s), f x = 1 :=
  prod_eq_one_iff_of_one_le'$ fun x hx => one_le (f x)

@[toAdditive sum_le_sum_of_subset]
theorem prod_le_prod_of_subset' (h : s ⊆ t) : (∏x in s, f x) ≤ ∏x in t, f x :=
  prod_le_prod_of_subset_of_one_le' h$ fun x h₁ h₂ => one_le _

@[toAdditive sum_mono_set]
theorem prod_mono_set' (f : ι → M) : Monotone fun s => ∏x in s, f x :=
  fun s₁ s₂ hs => prod_le_prod_of_subset' hs

@[toAdditive sum_le_sum_of_ne_zero]
theorem prod_le_prod_of_ne_one' (h : ∀ x (_ : x ∈ s), f x ≠ 1 → x ∈ t) : (∏x in s, f x) ≤ ∏x in t, f x :=
  by 
    classical <;>
      calc (∏x in s, f x) = (∏x in s.filter fun x => f x = 1, f x)*∏x in s.filter fun x => f x ≠ 1, f x :=
        by 
          rw [←prod_union, filter_union_filter_neg_eq] <;>
            exact disjoint_filter.2 fun _ _ h n_h => n_h h _ ≤ ∏x in t, f x :=
        mul_le_of_le_one_of_le
          (prod_le_one'$
            by 
              simp only [mem_filter, and_imp] <;> exact fun _ _ => le_of_eqₓ)
          (prod_le_prod_of_subset'$
            by 
              simpa only [subset_iff, mem_filter, and_imp])

end CanonicallyOrderedMonoid

section OrderedCancelCommMonoid

variable[OrderedCancelCommMonoid M]{f g : ι → M}{s t : Finset ι}

@[toAdditive sum_lt_sum]
theorem prod_lt_prod' (Hle : ∀ i (_ : i ∈ s), f i ≤ g i) (Hlt : ∃ (i : _)(_ : i ∈ s), f i < g i) :
  (∏i in s, f i) < ∏i in s, g i :=
  by 
    classical 
    rcases Hlt with ⟨i, hi, hlt⟩
    rw [←insert_erase hi, prod_insert (not_mem_erase _ _), prod_insert (not_mem_erase _ _)]
    exact mul_lt_mul_of_lt_of_le hlt (prod_le_prod''$ fun j hj => Hle j$ mem_of_mem_erase hj)

@[toAdditive sum_lt_sum_of_nonempty]
theorem prod_lt_prod_of_nonempty' (hs : s.nonempty) (Hlt : ∀ i (_ : i ∈ s), f i < g i) :
  (∏i in s, f i) < ∏i in s, g i :=
  by 
    apply prod_lt_prod'
    ·
      intro i hi 
      apply le_of_ltₓ (Hlt i hi)
    cases' hs with i hi 
    exact ⟨i, hi, Hlt i hi⟩

@[toAdditive sum_lt_sum_of_subset]
theorem prod_lt_prod_of_subset' (h : s ⊆ t) {i : ι} (ht : i ∈ t) (hs : i ∉ s) (hlt : 1 < f i)
  (hle : ∀ j (_ : j ∈ t), j ∉ s → 1 ≤ f j) : (∏j in s, f j) < ∏j in t, f j :=
  by 
    classical <;>
      calc (∏j in s, f j) < ∏j in insert i s, f j :=
        by 
          rw [prod_insert hs]
          exact lt_mul_of_one_lt_left' (∏j in s, f j) hlt _ ≤ ∏j in t, f j :=
        by 
          apply prod_le_prod_of_subset_of_one_le'
          ·
            simp [Finset.insert_subset, h, ht]
          ·
            intro x hx h'x 
            simp only [mem_insert, not_or_distrib] at h'x 
            exact hle x hx h'x.2

@[toAdditive single_lt_sum]
theorem single_lt_prod' {i j : ι} (hij : j ≠ i) (hi : i ∈ s) (hj : j ∈ s) (hlt : 1 < f j)
  (hle : ∀ k (_ : k ∈ s), k ≠ i → 1 ≤ f k) : f i < ∏k in s, f k :=
  calc f i = ∏k in {i}, f k := prod_singleton.symm 
    _ < ∏k in s, f k :=
    prod_lt_prod_of_subset' (singleton_subset_iff.2 hi) hj (mt mem_singleton.1 hij) hlt$
      fun k hks hki => hle k hks (mt mem_singleton.2 hki)
    

end OrderedCancelCommMonoid

section LinearOrderedCancelCommMonoid

variable[LinearOrderedCancelCommMonoid M]{f g : ι → M}{s t : Finset ι}

@[toAdditive exists_lt_of_sum_lt]
theorem exists_lt_of_prod_lt' (Hlt : (∏i in s, f i) < ∏i in s, g i) : ∃ (i : _)(_ : i ∈ s), f i < g i :=
  by 
    contrapose! Hlt with Hle 
    exact prod_le_prod'' Hle

@[toAdditive exists_le_of_sum_le]
theorem exists_le_of_prod_le' (hs : s.nonempty) (Hle : (∏i in s, f i) ≤ ∏i in s, g i) :
  ∃ (i : _)(_ : i ∈ s), f i ≤ g i :=
  by 
    contrapose! Hle with Hlt 
    exact prod_lt_prod_of_nonempty' hs Hlt

@[toAdditive exists_pos_of_sum_zero_of_exists_nonzero]
theorem exists_one_lt_of_prod_one_of_exists_ne_one' (f : ι → M) (h₁ : (∏i in s, f i) = 1)
  (h₂ : ∃ (i : _)(_ : i ∈ s), f i ≠ 1) : ∃ (i : _)(_ : i ∈ s), 1 < f i :=
  by 
    contrapose! h₁ 
    obtain ⟨i, m, i_ne⟩ : ∃ (i : _)(_ : i ∈ s), f i ≠ 1 := h₂ 
    apply ne_of_ltₓ 
    calc (∏j in s, f j) < ∏j in s, 1 := prod_lt_prod' h₁ ⟨i, m, (h₁ i m).lt_of_ne i_ne⟩_ = 1 := prod_const_one

end LinearOrderedCancelCommMonoid

section OrderedCommSemiring

variable[OrderedCommSemiring R]{f g : ι → R}{s t : Finset ι}

open_locale Classical

theorem prod_nonneg (h0 : ∀ i (_ : i ∈ s), 0 ≤ f i) : 0 ≤ ∏i in s, f i :=
  prod_induction f (fun i => 0 ≤ i) (fun _ _ ha hb => mul_nonneg ha hb) zero_le_one h0

theorem prod_pos [Nontrivial R] (h0 : ∀ i (_ : i ∈ s), 0 < f i) : 0 < ∏i in s, f i :=
  prod_induction f (fun x => 0 < x) (fun _ _ ha hb => mul_pos ha hb) zero_lt_one h0

/-- If all `f i`, `i ∈ s`, are nonnegative and each `f i` is less than or equal to `g i`, then the
product of `f i` is less than or equal to the product of `g i`. See also `finset.prod_le_prod''` for
the case of an ordered commutative multiplicative monoid. -/
theorem prod_le_prod (h0 : ∀ i (_ : i ∈ s), 0 ≤ f i) (h1 : ∀ i (_ : i ∈ s), f i ≤ g i) :
  (∏i in s, f i) ≤ ∏i in s, g i :=
  by 
    induction' s using Finset.induction with a s has ih h
    ·
      simp 
    ·
      simp only [prod_insert has]
      apply mul_le_mul
      ·
        exact h1 a (mem_insert_self a s)
      ·
        apply ih (fun x H => h0 _ _) fun x H => h1 _ _ <;> exact mem_insert_of_mem H
      ·
        apply prod_nonneg fun x H => h0 x (mem_insert_of_mem H)
      ·
        apply le_transₓ (h0 a (mem_insert_self a s)) (h1 a (mem_insert_self a s))

/-- If each `f i`, `i ∈ s` belongs to `[0, 1]`, then their product is less than or equal to one.
See also `finset.prod_le_one'` for the case of an ordered commutative multiplicative monoid. -/
theorem prod_le_one (h0 : ∀ i (_ : i ∈ s), 0 ≤ f i) (h1 : ∀ i (_ : i ∈ s), f i ≤ 1) : (∏i in s, f i) ≤ 1 :=
  by 
    convert ← prod_le_prod h0 h1 
    exact Finset.prod_const_one

-- error in Algebra.BigOperators.Order: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `g, h ≤ f` and `g i + h i ≤ f i`, then the product of `f` over `s` is at least the
  sum of the products of `g` and `h`. This is the version for `ordered_comm_semiring`. -/
theorem prod_add_prod_le
{i : ι}
{f g h : ι → R}
(hi : «expr ∈ »(i, s))
(h2i : «expr ≤ »(«expr + »(g i, h i), f i))
(hgf : ∀ j «expr ∈ » s, «expr ≠ »(j, i) → «expr ≤ »(g j, f j))
(hhf : ∀ j «expr ∈ » s, «expr ≠ »(j, i) → «expr ≤ »(h j, f j))
(hg : ∀ i «expr ∈ » s, «expr ≤ »(0, g i))
(hh : ∀
 i «expr ∈ » s, «expr ≤ »(0, h i)) : «expr ≤ »(«expr + »(«expr∏ in , »((i), s, g i), «expr∏ in , »((i), s, h i)), «expr∏ in , »((i), s, f i)) :=
begin
  simp_rw ["[", expr prod_eq_mul_prod_diff_singleton hi, "]"] [],
  refine [expr le_trans _ (mul_le_mul_of_nonneg_right h2i _)],
  { rw ["[", expr right_distrib, "]"] [],
    apply [expr add_le_add]; apply [expr mul_le_mul_of_nonneg_left]; try { apply_assumption; assumption }; apply [expr prod_le_prod]; simp [] [] [] ["*"] [] [] { contextual := tt } },
  { apply [expr prod_nonneg],
    simp [] [] ["only"] ["[", expr and_imp, ",", expr mem_sdiff, ",", expr mem_singleton, "]"] [] [],
    intros [ident j, ident h1j, ident h2j],
    exact [expr le_trans (hg j h1j) (hgf j h1j h2j)] }
end

end OrderedCommSemiring

section CanonicallyOrderedCommSemiring

variable[CanonicallyOrderedCommSemiring R]{f g h : ι → R}{s : Finset ι}{i : ι}

theorem prod_le_prod' (h : ∀ i (_ : i ∈ s), f i ≤ g i) : (∏i in s, f i) ≤ ∏i in s, g i :=
  by 
    classical 
    induction' s using Finset.induction with a s has ih h
    ·
      simp 
    ·
      rw [Finset.prod_insert has, Finset.prod_insert has]
      apply mul_le_mul'
      ·
        exact h _ (Finset.mem_insert_self a s)
      ·
        exact ih fun i hi => h _ (Finset.mem_insert_of_mem hi)

/-- If `g, h ≤ f` and `g i + h i ≤ f i`, then the product of `f` over `s` is at least the
  sum of the products of `g` and `h`. This is the version for `canonically_ordered_comm_semiring`.
-/
theorem prod_add_prod_le' (hi : i ∈ s) (h2i : (g i+h i) ≤ f i) (hgf : ∀ j (_ : j ∈ s), j ≠ i → g j ≤ f j)
  (hhf : ∀ j (_ : j ∈ s), j ≠ i → h j ≤ f j) : ((∏i in s, g i)+∏i in s, h i) ≤ ∏i in s, f i :=
  by 
    classical 
    simpRw [prod_eq_mul_prod_diff_singleton hi]
    refine' le_transₓ _ (mul_le_mul_right' h2i _)
    rw [right_distrib]
    apply add_le_add <;>
      apply mul_le_mul_left' <;>
        apply prod_le_prod' <;>
          simp only [and_imp, mem_sdiff, mem_singleton] <;> intros  <;> applyAssumption <;> assumption

end CanonicallyOrderedCommSemiring

end Finset

namespace Fintype

variable[Fintype ι]

-- error in Algebra.BigOperators.Order: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[to_additive #[ident sum_mono], mono #[]]
theorem prod_mono' [ordered_comm_monoid M] : monotone (λ f : ι → M, «expr∏ , »((i), f i)) :=
λ f g hfg, «expr $ »(finset.prod_le_prod'', λ x _, hfg x)

attribute [mono] sum_mono

-- error in Algebra.BigOperators.Order: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[to_additive #[ident sum_strict_mono]]
theorem prod_strict_mono' [ordered_cancel_comm_monoid M] : strict_mono (λ f : ι → M, «expr∏ , »((x), f x)) :=
λ f g hfg, let ⟨hle, i, hlt⟩ := pi.lt_def.mp hfg in
finset.prod_lt_prod' (λ i _, hle i) ⟨i, finset.mem_univ i, hlt⟩

end Fintype

namespace WithTop

open Finset

/-- A product of finite numbers is still finite -/
theorem prod_lt_top [CanonicallyOrderedCommSemiring R] [Nontrivial R] [DecidableEq R] {s : Finset ι} {f : ι → WithTop R}
  (h : ∀ i (_ : i ∈ s), f i ≠ ⊤) : (∏i in s, f i) < ⊤ :=
  prod_induction f (fun a => a < ⊤) (fun a b h₁ h₂ => mul_lt_top h₁.ne h₂.ne) (coe_lt_top 1)$
    fun a ha => lt_top_iff_ne_top.2 (h a ha)

/-- A sum of finite numbers is still finite -/
theorem sum_lt_top [OrderedAddCommMonoid M] {s : Finset ι} {f : ι → WithTop M} (h : ∀ i (_ : i ∈ s), f i ≠ ⊤) :
  (∑i in s, f i) < ⊤ :=
  sum_induction f (fun a => a < ⊤) (fun a b h₁ h₂ => add_lt_top.2 ⟨h₁, h₂⟩) zero_lt_top$
    fun i hi => lt_top_iff_ne_top.2 (h i hi)

/-- A sum of numbers is infinite iff one of them is infinite -/
theorem sum_eq_top_iff [OrderedAddCommMonoid M] {s : Finset ι} {f : ι → WithTop M} :
  (∑i in s, f i) = ⊤ ↔ ∃ (i : _)(_ : i ∈ s), f i = ⊤ :=
  by 
    classical 
    split 
    ·
      contrapose! 
      exact fun h => (sum_lt_top$ fun i hi => h i hi).Ne
    ·
      rintro ⟨i, his, hi⟩
      rw [sum_eq_add_sum_diff_singleton his, hi, top_add]

/-- A sum of finite numbers is still finite -/
theorem sum_lt_top_iff [OrderedAddCommMonoid M] {s : Finset ι} {f : ι → WithTop M} :
  (∑i in s, f i) < ⊤ ↔ ∀ i (_ : i ∈ s), f i < ⊤ :=
  by 
    simp only [lt_top_iff_ne_top, Ne.def, sum_eq_top_iff, not_exists]

end WithTop

section AbsoluteValue

variable{S : Type _}

-- error in Algebra.BigOperators.Order: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem absolute_value.sum_le
[semiring R]
[ordered_semiring S]
(abv : absolute_value R S)
(s : finset ι)
(f : ι → R) : «expr ≤ »(abv «expr∑ in , »((i), s, f i), «expr∑ in , »((i), s, abv (f i))) :=
begin
  letI [] [] [":=", expr classical.dec_eq ι],
  refine [expr finset.induction_on s _ (λ i s hi ih, _)],
  { simp [] [] [] [] [] [] },
  { simp [] [] ["only"] ["[", expr finset.sum_insert hi, "]"] [] [],
    exact [expr (abv.add_le _ _).trans (add_le_add (le_refl _) ih)] }
end

theorem IsAbsoluteValue.abv_sum [Semiringₓ R] [OrderedSemiring S] (abv : R → S) [IsAbsoluteValue abv] (f : ι → R)
  (s : Finset ι) : abv (∑i in s, f i) ≤ ∑i in s, abv (f i) :=
  (IsAbsoluteValue.toAbsoluteValue abv).sum_le _ _

theorem AbsoluteValue.map_prod [CommSemiringₓ R] [Nontrivial R] [LinearOrderedCommRing S] (abv : AbsoluteValue R S)
  (f : ι → R) (s : Finset ι) : abv (∏i in s, f i) = ∏i in s, abv (f i) :=
  abv.to_monoid_hom.map_prod f s

theorem IsAbsoluteValue.map_prod [CommSemiringₓ R] [Nontrivial R] [LinearOrderedCommRing S] (abv : R → S)
  [IsAbsoluteValue abv] (f : ι → R) (s : Finset ι) : abv (∏i in s, f i) = ∏i in s, abv (f i) :=
  (IsAbsoluteValue.toAbsoluteValue abv).map_prod _ _

end AbsoluteValue

