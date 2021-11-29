import Mathbin.Data.Equiv.Denumerable 
import Mathbin.Data.Finset.Sort

/-!
# Equivalences involving `list`-like types

This file defines some additional constructive equivalences using `encodable` and the pairing
function on `ℕ`.
-/


open Nat List

namespace Encodable

variable{α : Type _}

section List

variable[Encodable α]

/-- Explicit encoding function for `list α` -/
def encode_list : List α → ℕ
| [] => 0
| a :: l => succ (mkpair (encode a) (encode_list l))

/-- Explicit decoding function for `list α` -/
def decode_list : ℕ → Option (List α)
| 0 => some []
| succ v =>
  match unpair v, unpair_right_le v with 
  | (v₁, v₂), h =>
    have  : v₂ < succ v := lt_succ_of_le h
    ((· :: ·) <$> decode α v₁)<*>decode_list v₂

/-- If `α` is encodable, then so is `list α`. This uses the `mkpair` and `unpair` functions from
`data.nat.pairing`. -/
instance List : Encodable (List α) :=
  ⟨encode_list, decode_list,
    fun l =>
      by 
        induction' l with a l IH <;> simp [encode_list, decode_list, unpair_mkpair, encodek]⟩

@[simp]
theorem encode_list_nil : encode (@nil α) = 0 :=
  rfl

@[simp]
theorem encode_list_cons (a : α) (l : List α) : encode (a :: l) = succ (mkpair (encode a) (encode l)) :=
  rfl

@[simp]
theorem decode_list_zero : decode (List α) 0 = some [] :=
  show decode_list 0 = some []by 
    rw [decode_list]

@[simp]
theorem decode_list_succ (v : ℕ) :
  decode (List α) (succ v) = ((· :: ·) <$> decode α v.unpair.1)<*>decode (List α) v.unpair.2 :=
  show decode_list (succ v) = _ by 
    cases' e : unpair v with v₁ v₂ 
    simp [decode_list, e]
    rfl

theorem length_le_encode : ∀ (l : List α), length l ≤ encode l
| [] => _root_.zero_le _
| a :: l => succ_le_succ$ (length_le_encode l).trans (right_le_mkpair _ _)

end List

section Finset

variable[Encodable α]

private def enle : α → α → Prop :=
  encode ⁻¹'o (· ≤ ·)

private theorem enle.is_linear_order : IsLinearOrder α enle :=
  (RelEmbedding.preimage ⟨encode, encode_injective⟩ (· ≤ ·)).IsLinearOrder

private def decidable_enle (a b : α) : Decidable (enle a b) :=
  by 
    unfold enle Order.Preimage <;> infer_instance

attribute [local instance] enle.is_linear_order decidable_enle

/-- Explicit encoding function for `multiset α` -/
def encode_multiset (s : Multiset α) : ℕ :=
  encode (s.sort enle)

/-- Explicit decoding function for `multiset α` -/
def decode_multiset (n : ℕ) : Option (Multiset α) :=
  coeₓ <$> decode (List α) n

/-- If `α` is encodable, then so is `multiset α`. -/
instance Multiset : Encodable (Multiset α) :=
  ⟨encode_multiset, decode_multiset,
    fun s =>
      by 
        simp [encode_multiset, decode_multiset, encodek]⟩

end Finset

/-- A listable type with decidable equality is encodable. -/
def encodable_of_list [DecidableEq α] (l : List α) (H : ∀ x, x ∈ l) : Encodable α :=
  ⟨fun a => index_of a l, l.nth, fun a => index_of_nth (H _)⟩

-- error in Data.Equiv.List: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
def trunc_encodable_of_fintype (α : Type*) [decidable_eq α] [fintype α] : trunc (encodable α) :=
@@quot.rec_on_subsingleton _ (λ
 s : multiset α, ∀
 x : α, «expr ∈ »(x, s) → trunc (encodable α)) _ finset.univ.1 (λ
 l H, «expr $ »(trunc.mk, encodable_of_list l H)) finset.mem_univ

/-- A noncomputable way to arbitrarily choose an ordering on a finite type.
  It is not made into a global instance, since it involves an arbitrary choice.
  This can be locally made into an instance with `local attribute [instance] fintype.encodable`. -/
noncomputable def _root_.fintype.encodable (α : Type _) [Fintype α] : Encodable α :=
  by 
    classical 
    exact (Encodable.truncEncodableOfFintype α).out

/-- If `α` is encodable, then so is `vector α n`. -/
instance Vector [Encodable α] {n} : Encodable (Vector α n) :=
  Encodable.subtype

/-- If `α` is encodable, then so is `fin n → α`. -/
instance fin_arrow [Encodable α] {n} : Encodable (Finₓ n → α) :=
  of_equiv _ (Equiv.vectorEquivFin _ _).symm

instance fin_pi n (π : Finₓ n → Type _) [∀ i, Encodable (π i)] : Encodable (∀ i, π i) :=
  of_equiv _ (Equiv.piEquivSubtypeSigma (Finₓ n) π)

/-- If `α` is encodable, then so is `array n α`. -/
instance Arrayₓ [Encodable α] {n} : Encodable (Arrayₓ n α) :=
  of_equiv _ (Equiv.arrayEquivFin _ _)

-- error in Data.Equiv.List: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `α` is encodable, then so is `finset α`. -/ instance finset [encodable α] : encodable (finset α) :=
by haveI [] [] [":=", expr decidable_eq_of_encodable α]; exact [expr of_equiv {s : multiset α // s.nodup} ⟨λ
  ⟨a, b⟩, ⟨a, b⟩, λ ⟨a, b⟩, ⟨a, b⟩, λ ⟨a, b⟩, rfl, λ ⟨a, b⟩, rfl⟩]

def fintype_arrow (α : Type _) (β : Type _) [DecidableEq α] [Fintype α] [Encodable β] : Trunc (Encodable (α → β)) :=
  (Fintype.truncEquivFin α).map$
    fun f => Encodable.ofEquiv (Finₓ (Fintype.card α) → β)$ Equiv.arrowCongr f (Equiv.refl _)

def fintype_pi (α : Type _) (π : α → Type _) [DecidableEq α] [Fintype α] [∀ a, Encodable (π a)] :
  Trunc (Encodable (∀ a, π a)) :=
  (Encodable.truncEncodableOfFintype α).bind$
    fun a =>
      (@fintype_arrow α (Σa, π a) _ _ (@Encodable.sigma _ _ a _)).bind$
        fun f => Trunc.mk$ @Encodable.ofEquiv _ _ (@Encodable.subtype _ _ f _) (Equiv.piEquivSubtypeSigma α π)

/-- The elements of a `fintype` as a sorted list. -/
def sorted_univ α [Fintype α] [Encodable α] : List α :=
  Finset.univ.sort (Encodable.encode' α ⁻¹'o (· ≤ ·))

@[simp]
theorem mem_sorted_univ {α} [Fintype α] [Encodable α] (x : α) : x ∈ sorted_univ α :=
  (Finset.mem_sort _).2 (Finset.mem_univ _)

@[simp]
theorem length_sorted_univ α [Fintype α] [Encodable α] : (sorted_univ α).length = Fintype.card α :=
  Finset.length_sort _

@[simp]
theorem sorted_univ_nodup α [Fintype α] [Encodable α] : (sorted_univ α).Nodup :=
  Finset.sort_nodup _ _

@[simp]
theorem sorted_univ_to_finset α [Fintype α] [Encodable α] [DecidableEq α] : (sorted_univ α).toFinset = Finset.univ :=
  Finset.sort_to_finset _ _

-- error in Data.Equiv.List: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- An encodable `fintype` is equivalent to the same size `fin`. -/
def fintype_equiv_fin {α} [fintype α] [encodable α] : «expr ≃ »(α, fin (fintype.card α)) :=
begin
  haveI [] [":", expr decidable_eq α] [":=", expr encodable.decidable_eq_of_encodable _],
  transitivity [],
  { exact [expr ((sorted_univ_nodup α).nth_le_equiv_of_forall_mem_list _ mem_sorted_univ).symm] },
  exact [expr equiv.cast (congr_arg _ (length_sorted_univ α))]
end

/-- If `α` and `β` are encodable and `α` is a fintype, then `α → β` is encodable as well. -/
instance fintype_arrow_of_encodable {α β : Type _} [Encodable α] [Fintype α] [Encodable β] : Encodable (α → β) :=
  of_equiv (Finₓ (Fintype.card α) → β)$ Equiv.arrowCongr fintype_equiv_fin (Equiv.refl _)

end Encodable

namespace Denumerable

variable{α : Type _}{β : Type _}[Denumerable α][Denumerable β]

open Encodable

section List

-- error in Data.Equiv.List: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem denumerable_list_aux : ∀ n : exprℕ(), «expr∃ , »((a «expr ∈ » @decode_list α _ n), «expr = »(encode_list a, n))
| 0 := by rw [expr decode_list] []; exact [expr ⟨_, rfl, rfl⟩]
| succ v := begin
  cases [expr e, ":", expr unpair v] ["with", ident v₁, ident v₂],
  have [ident h] [] [":=", expr unpair_right_le v],
  rw [expr e] ["at", ident h],
  rcases [expr have «expr < »(v₂, succ v), from lt_succ_of_le h,
   denumerable_list_aux v₂, "with", "⟨", ident a, ",", ident h₁, ",", ident h₂, "⟩"],
  rw [expr option.mem_def] ["at", ident h₁],
  use [expr [«expr :: »/«expr :: »/«expr :: »](of_nat α v₁, a)],
  simp [] [] [] ["[", expr decode_list, ",", expr e, ",", expr h₂, ",", expr h₁, ",", expr encode_list, ",", expr mkpair_unpair' e, "]"] [] []
end

/-- If `α` is denumerable, then so is `list α`. -/
instance denumerable_list : Denumerable (List α) :=
  ⟨denumerable_list_aux⟩

@[simp]
theorem list_of_nat_zero : of_nat (List α) 0 = [] :=
  by 
    rw [←@encode_list_nil α, of_nat_encode]

@[simp]
theorem list_of_nat_succ (v : ℕ) : of_nat (List α) (succ v) = of_nat α v.unpair.1 :: of_nat (List α) v.unpair.2 :=
  of_nat_of_decode$
    show decode_list (succ v) = _ by 
      cases' e : unpair v with v₁ v₂ 
      simp [decode_list, e]
      rw [show decode_list v₂ = decode (List α) v₂ from rfl, decode_eq_of_nat] <;> rfl

end List

section Multiset

/-- Outputs the list of differences of the input list, that is
`lower [a₁, a₂, ...] n = [a₁ - n, a₂ - a₁, ...]` -/
def lower : List ℕ → ℕ → List ℕ
| [], n => []
| m :: l, n => (m - n) :: lower l m

/-- Outputs the list of partial sums of the input list, that is
`raise [a₁, a₂, ...] n = [n + a₁, n + a₁ + a₂, ...]` -/
def raise : List ℕ → ℕ → List ℕ
| [], n => []
| m :: l, n => (m+n) :: raise l (m+n)

theorem lower_raise : ∀ l n, lower (raise l n) n = l
| [], n => rfl
| m :: l, n =>
  by 
    rw [raise, lower, add_tsub_cancel_right, lower_raise]

theorem raise_lower : ∀ {l n}, List.Sorted (· ≤ ·) (n :: l) → raise (lower l n) n = l
| [], n, h => rfl
| m :: l, n, h =>
  have  : n ≤ m := List.rel_of_sorted_cons h _ (l.mem_cons_self _)
  by 
    simp [raise, lower, tsub_add_cancel_of_le this, raise_lower (List.sorted_of_sorted_cons h)]

theorem raise_chain : ∀ l n, List.Chain (· ≤ ·) n (raise l n)
| [], n => List.Chain.nil
| m :: l, n => List.Chain.cons (Nat.le_add_leftₓ _ _) (raise_chain _ _)

/-- `raise l n` is an non-decreasing sequence. -/
theorem raise_sorted : ∀ l n, List.Sorted (· ≤ ·) (raise l n)
| [], n => List.sorted_nil
| m :: l, n => (List.chain_iff_pairwise (@le_transₓ _ _)).1 (raise_chain _ _)

-- error in Data.Equiv.List: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `α` is denumerable, then so is `multiset α`. Warning: this is *not* the same encoding as used
in `encodable.multiset`. -/ instance multiset : denumerable (multiset α) :=
mk' ⟨λ
 s : multiset α, «expr $ »(encode, lower ((s.map encode).sort ((«expr ≤ »))) 0), λ
 n, multiset.map (of_nat α) (raise (of_nat (list exprℕ()) n) 0), λ
 s, by have [] [] [":=", expr raise_lower (list.sorted_cons.2 ⟨λ
    n
    _, zero_le n, (s.map encode).sort_sorted _⟩)]; simp [] [] [] ["[", "-", ident multiset.coe_map, ",", expr this, "]"] [] [], λ
 n, by simp [] [] [] ["[", "-", ident multiset.coe_map, ",", expr list.merge_sort_eq_self _ (raise_sorted _ _), ",", expr lower_raise, "]"] [] []⟩

end Multiset

section Finset

/-- Outputs the list of differences minus one of the input list, that is
`lower' [a₁, a₂, a₃, ...] n = [a₁ - n, a₂ - a₁ - 1, a₃ - a₂ - 1, ...]`. -/
def lower' : List ℕ → ℕ → List ℕ
| [], n => []
| m :: l, n => (m - n) :: lower' l (m+1)

/-- Outputs the list of partial sums plus one of the input list, that is
`raise [a₁, a₂, a₃, ...] n = [n + a₁, n + a₁ + a₂ + 1, n + a₁ + a₂ + a₃ + 2, ...]`. Adding one each
time ensures the elements are distinct. -/
def raise' : List ℕ → ℕ → List ℕ
| [], n => []
| m :: l, n => (m+n) :: raise' l ((m+n)+1)

theorem lower_raise' : ∀ l n, lower' (raise' l n) n = l
| [], n => rfl
| m :: l, n =>
  by 
    simp [raise', lower', add_tsub_cancel_right, lower_raise']

theorem raise_lower' : ∀ {l n}, (∀ m (_ : m ∈ l), n ≤ m) → List.Sorted (· < ·) l → raise' (lower' l n) n = l
| [], n, h₁, h₂ => rfl
| m :: l, n, h₁, h₂ =>
  have  : n ≤ m := h₁ _ (l.mem_cons_self _)
  by 
    simp [raise', lower', tsub_add_cancel_of_le this,
      raise_lower' (List.rel_of_sorted_cons h₂ : ∀ a (_ : a ∈ l), m < a) (List.sorted_of_sorted_cons h₂)]

theorem raise'_chain : ∀ l {m n}, m < n → List.Chain (· < ·) m (raise' l n)
| [], m, n, h => List.Chain.nil
| a :: l, m, n, h => List.Chain.cons (lt_of_lt_of_leₓ h (Nat.le_add_leftₓ _ _)) (raise'_chain _ (lt_succ_self _))

/-- `raise' l n` is a strictly increasing sequence. -/
theorem raise'_sorted : ∀ l n, List.Sorted (· < ·) (raise' l n)
| [], n => List.sorted_nil
| m :: l, n => (List.chain_iff_pairwise (@lt_transₓ _ _)).1 (raise'_chain _ (lt_succ_self _))

/-- Makes `raise' l n` into a finset. Elements are distinct thanks to `raise'_sorted`. -/
def raise'_finset (l : List ℕ) (n : ℕ) : Finset ℕ :=
  ⟨raise' l n, (raise'_sorted _ _).imp (@ne_of_ltₓ _ _)⟩

-- error in Data.Equiv.List: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- If `α` is denumerable, then so is `finset α`. Warning: this is *not* the same encoding as used
in `encodable.finset`. -/ instance finset : denumerable (finset α) :=
mk' ⟨λ
 s : finset α, «expr $ »(encode, lower' ((s.map (eqv α).to_embedding).sort ((«expr ≤ »))) 0), λ
 n, finset.map (eqv α).symm.to_embedding (raise'_finset (of_nat (list exprℕ()) n) 0), λ
 s, «expr $ »(finset.eq_of_veq, by simp [] [] [] ["[", "-", ident multiset.coe_map, ",", expr raise'_finset, ",", expr raise_lower' (λ
    n
    _, zero_le n) (finset.sort_sorted_lt _), "]"] [] []), λ
 n, by simp [] [] [] ["[", "-", ident multiset.coe_map, ",", expr finset.map, ",", expr raise'_finset, ",", expr finset.sort, ",", expr list.merge_sort_eq_self ((«expr ≤ »)) ((raise'_sorted _ _).imp (@le_of_lt _ _)), ",", expr lower_raise', "]"] [] []⟩

end Finset

end Denumerable

namespace Equiv

/-- The type lists on unit is canonically equivalent to the natural numbers. -/
def list_unit_equiv : List Unit ≃ ℕ :=
  { toFun := List.length, invFun := List.repeat (),
    left_inv :=
      fun u =>
        List.length_injective
          (by 
            simp ),
    right_inv := fun n => List.length_repeat () n }

/-- `list ℕ` is equivalent to `ℕ`. -/
def list_nat_equiv_nat : List ℕ ≃ ℕ :=
  Denumerable.eqv _

/-- If `α` is equivalent to `ℕ`, then `list α` is equivalent to `α`. -/
def list_equiv_self_of_equiv_nat {α : Type} (e : α ≃ ℕ) : List α ≃ α :=
  calc List α ≃ List ℕ := list_equiv_of_equiv e 
    _ ≃ ℕ := list_nat_equiv_nat 
    _ ≃ α := e.symm
    

end Equiv

