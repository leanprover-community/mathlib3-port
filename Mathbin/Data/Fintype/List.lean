import Mathbin.Data.Fintype.Basic 
import Mathbin.Data.List.Perm

/-!

# Fintype instance for nodup lists

The subtype of `{l : list α // l.nodup}` over a `[fintype α]`
admits a `fintype` instance.

## Implementation details
To construct the `fintype` instance, a function lifting a `multiset α`
to the `finset (list α)` that can construct it is provided.
This function is applied to the `finset.powerset` of `finset.univ`.

In general, a `decidable_eq` instance is not necessary to define this function,
but a proof of `(list.permutations l).nodup` is required to avoid it,
which is a TODO.

-/


variable{α : Type _}[DecidableEq α]

open List

namespace Multiset

-- error in Data.Fintype.List: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/--
The `finset` of `l : list α` that, given `m : multiset α`, have the property `⟦l⟧ = m`.
-/ def lists : multiset α → finset (list α) :=
λ
s, quotient.lift_on s (λ
 l, l.permutations.to_finset) (λ (l l') (h : «expr ~ »(l, l')), begin
   ext [] [ident sl] [],
   simp [] [] ["only"] ["[", expr mem_permutations, ",", expr list.mem_to_finset, "]"] [] [],
   exact [expr ⟨λ hs, hs.trans h, λ hs, hs.trans h.symm⟩]
 end)

@[simp]
theorem lists_coe (l : List α) : lists (l : Multiset α) = l.permutations.to_finset :=
  rfl

@[simp]
theorem mem_lists_iff (s : Multiset α) (l : List α) : l ∈ lists s ↔ s = «expr⟦ ⟧» l :=
  by 
    induction s using Quotientₓ.induction_on 
    simpa using perm_comm

end Multiset

instance fintypeNodupList [Fintype α] : Fintype { l : List α // l.nodup } :=
  Fintype.subtype ((Finset.univ : Finset α).Powerset.bUnion fun s => s.val.lists)
    fun l =>
      by 
        suffices  : (∃ a : Finset α, a.val = «expr↑ » l) ↔ l.nodup
        ·
          simpa 
        split 
        ·
          rintro ⟨s, hs⟩
          simpa [←Multiset.coe_nodup, ←hs] using s.nodup
        ·
          intro hl 
          refine' ⟨⟨«expr↑ » l, hl⟩, _⟩
          simp 

