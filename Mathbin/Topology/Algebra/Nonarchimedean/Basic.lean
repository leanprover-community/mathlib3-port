import Mathbin.Topology.Algebra.Ring 
import Mathbin.Topology.Algebra.OpenSubgroup 
import Mathbin.Data.Set.Basic 
import Mathbin.GroupTheory.Subgroup.Basic

/-!
# Nonarchimedean Topology

In this file we set up the theory of nonarchimedean topological groups and rings.

A nonarchimedean group is a topological group whose topology admits a basis of
open neighborhoods of the identity element in the group consisting of open subgroups.
A nonarchimedean ring is a topological ring whose underlying topological (additive)
group is nonarchimedean.

## Definitions

- `nonarchimedean_add_group`: nonarchimedean additive group.
- `nonarchimedean_group`: nonarchimedean multiplicative group.
- `nonarchimedean_ring`: nonarchimedean ring.

-/


open_locale Pointwise

/-- An topological additive group is nonarchimedean if every neighborhood of 0
  contains an open subgroup. -/
class NonarchimedeanAddGroup(G : Type _)[AddGroupₓ G][TopologicalSpace G] extends TopologicalAddGroup G : Prop where 
  is_nonarchimedean : ∀ U (_ : U ∈ nhds (0 : G)), ∃ V : OpenAddSubgroup G, (V : Set G) ⊆ U

/-- A topological group is nonarchimedean if every neighborhood of 1 contains an open subgroup. -/
@[toAdditive]
class NonarchimedeanGroup(G : Type _)[Groupₓ G][TopologicalSpace G] extends TopologicalGroup G : Prop where 
  is_nonarchimedean : ∀ U (_ : U ∈ nhds (1 : G)), ∃ V : OpenSubgroup G, (V : Set G) ⊆ U

/-- An topological ring is nonarchimedean if its underlying topological additive
  group is nonarchimedean. -/
class NonarchimedeanRing(R : Type _)[Ringₓ R][TopologicalSpace R] extends TopologicalRing R : Prop where 
  is_nonarchimedean : ∀ U (_ : U ∈ nhds (0 : R)), ∃ V : OpenAddSubgroup R, (V : Set R) ⊆ U

/-- Every nonarchimedean ring is naturally a nonarchimedean additive group. -/
instance (priority := 100)NonarchimedeanRing.to_nonarchimedean_add_group (R : Type _) [Ringₓ R] [TopologicalSpace R]
  [t : NonarchimedeanRing R] : NonarchimedeanAddGroup R :=
  { t with  }

namespace NonarchimedeanGroup

variable{G : Type _}[Groupₓ G][TopologicalSpace G][NonarchimedeanGroup G]

variable{H : Type _}[Groupₓ H][TopologicalSpace H][TopologicalGroup H]

variable{K : Type _}[Groupₓ K][TopologicalSpace K][NonarchimedeanGroup K]

/-- If a topological group embeds into a nonarchimedean group, then it
  is nonarchimedean. -/
@[toAdditive NonarchimedeanAddGroup.nonarchimedean_of_emb]
theorem nonarchimedean_of_emb (f : G →* H) (emb : OpenEmbedding f) : NonarchimedeanGroup H :=
  { is_nonarchimedean :=
      fun U hU =>
        have h₁ : f ⁻¹' U ∈ nhds (1 : G) :=
          by 
            apply emb.continuous.tendsto 
            rwa [f.map_one]
        let ⟨V, hV⟩ := is_nonarchimedean (f ⁻¹' U) h₁
        ⟨{ Subgroup.map f V with is_open' := emb.is_open_map _ V.is_open }, Set.image_subset_iff.2 hV⟩ }

/-- An open neighborhood of the identity in the cartesian product of two nonarchimedean groups
  contains the cartesian product of an open neighborhood in each group. -/
@[toAdditive NonarchimedeanAddGroup.prod_subset]
theorem prod_subset {U} (hU : U ∈ nhds (1 : G × K)) :
  ∃ (V : OpenSubgroup G)(W : OpenSubgroup K), (V : Set G).Prod (W : Set K) ⊆ U :=
  by 
    erw [nhds_prod_eq, Filter.mem_prod_iff] at hU 
    rcases hU with ⟨U₁, hU₁, U₂, hU₂, h⟩
    cases' is_nonarchimedean _ hU₁ with V hV 
    cases' is_nonarchimedean _ hU₂ with W hW 
    use V 
    use W 
    rw [Set.prod_subset_iff]
    intro x hX y hY 
    exact Set.Subset.trans (Set.prod_mono hV hW) h (Set.mem_sep hX hY)

/-- An open neighborhood of the identity in the cartesian square of a nonarchimedean group
  contains the cartesian square of an open neighborhood in the group. -/
@[toAdditive NonarchimedeanAddGroup.prod_self_subset]
theorem prod_self_subset {U} (hU : U ∈ nhds (1 : G × G)) : ∃ V : OpenSubgroup G, (V : Set G).Prod (V : Set G) ⊆ U :=
  let ⟨V, W, h⟩ := prod_subset hU
  ⟨V⊓W,
    by 
      refine' Set.Subset.trans (Set.prod_mono _ _) ‹_› <;> simp ⟩

/-- The cartesian product of two nonarchimedean groups is nonarchimedean. -/
@[toAdditive]
instance  : NonarchimedeanGroup (G × K) :=
  { is_nonarchimedean :=
      fun U hU =>
        let ⟨V, W, h⟩ := prod_subset hU
        ⟨V.prod W, ‹_›⟩ }

end NonarchimedeanGroup

namespace NonarchimedeanRing

open NonarchimedeanRing

open NonarchimedeanAddGroup

variable{R S : Type _}

variable[Ringₓ R][TopologicalSpace R][NonarchimedeanRing R]

variable[Ringₓ S][TopologicalSpace S][NonarchimedeanRing S]

/-- The cartesian product of two nonarchimedean rings is nonarchimedean. -/
instance  : NonarchimedeanRing (R × S) :=
  { is_nonarchimedean := NonarchimedeanAddGroup.is_nonarchimedean }

/-- Given an open subgroup `U` and an element `r` of a nonarchimedean ring, there is an open
  subgroup `V` such that `r • V` is contained in `U`. -/
theorem left_mul_subset (U : OpenAddSubgroup R) (r : R) : ∃ V : OpenAddSubgroup R, r • (V : Set R) ⊆ U :=
  ⟨U.comap (AddMonoidHom.mulLeft r) (continuous_mul_left r), (U : Set R).image_preimage_subset _⟩

-- error in Topology.Algebra.Nonarchimedean.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- An open subgroup of a nonarchimedean ring contains the square of another one. -/
theorem mul_subset
(U : open_add_subgroup R) : «expr∃ , »((V : open_add_subgroup R), «expr ⊆ »(«expr * »((V : set R), V), U)) :=
let ⟨V, H⟩ := prod_self_subset (is_open.mem_nhds (is_open.preimage continuous_mul U.is_open) (begin
        simpa [] [] ["only"] ["[", expr set.mem_preimage, ",", expr open_add_subgroup.mem_coe, ",", expr prod.snd_zero, ",", expr mul_zero, "]"] [] ["using", expr U.zero_mem]
      end)) in
begin
  use [expr V],
  rintros [ident v, "⟨", ident a, ",", ident b, ",", ident ha, ",", ident hb, ",", ident hv, "⟩"],
  have [ident hy] [] [":=", expr H (set.mk_mem_prod ha hb)],
  simp [] [] ["only"] ["[", expr set.mem_preimage, ",", expr open_add_subgroup.mem_coe, "]"] [] ["at", ident hy],
  rwa [expr hv] ["at", ident hy]
end

end NonarchimedeanRing

