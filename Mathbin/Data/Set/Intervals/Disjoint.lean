import Mathbin.Data.Set.Lattice

/-!
# Extra lemmas about intervals

This file contains lemmas about intervals that cannot be included into `data.set.intervals.basic`
because this would create an `import` cycle. Namely, lemmas in this file can use definitions
from `data.set.lattice`, including `disjoint`.
-/


universe u

variable{α : Type u}

open order_dual(toDual)

namespace Set

section Preorderₓ

variable[Preorderₓ α]{a b c : α}

@[simp]
theorem Iic_disjoint_Ioi (h : a ≤ b) : Disjoint (Iic a) (Ioi b) :=
  fun x ⟨ha, hb⟩ => not_le_of_lt (h.trans_lt hb) ha

@[simp]
theorem Iic_disjoint_Ioc (h : a ≤ b) : Disjoint (Iic a) (Ioc b c) :=
  (Iic_disjoint_Ioi h).mono (le_reflₓ _) fun _ => And.left

@[simp]
theorem Ioc_disjoint_Ioc_same {a b c : α} : Disjoint (Ioc a b) (Ioc b c) :=
  (Iic_disjoint_Ioc (le_reflₓ b)).mono (fun _ => And.right) (le_reflₓ _)

@[simp]
theorem Ico_disjoint_Ico_same {a b c : α} : Disjoint (Ico a b) (Ico b c) :=
  fun x hx => not_le_of_lt hx.1.2 hx.2.1

@[simp]
theorem Ici_disjoint_Iic : Disjoint (Ici a) (Iic b) ↔ ¬a ≤ b :=
  by 
    rw [Set.disjoint_iff_inter_eq_empty, Ici_inter_Iic, Icc_eq_empty_iff]

@[simp]
theorem Iic_disjoint_Ici : Disjoint (Iic a) (Ici b) ↔ ¬b ≤ a :=
  Disjoint.comm.trans Ici_disjoint_Iic

end Preorderₓ

section LinearOrderₓ

variable[LinearOrderₓ α]{a₁ a₂ b₁ b₂ : α}

@[simp]
theorem Ico_disjoint_Ico : Disjoint (Ico a₁ a₂) (Ico b₁ b₂) ↔ min a₂ b₂ ≤ max a₁ b₁ :=
  by 
    simpRw [Set.disjoint_iff_inter_eq_empty, Ico_inter_Ico, Ico_eq_empty_iff, inf_eq_min, sup_eq_max, not_ltₓ]

@[simp]
theorem Ioc_disjoint_Ioc : Disjoint (Ioc a₁ a₂) (Ioc b₁ b₂) ↔ min a₂ b₂ ≤ max a₁ b₁ :=
  have h : _ ↔ min (to_dual a₁) (to_dual b₁) ≤ max (to_dual a₂) (to_dual b₂) := Ico_disjoint_Ico 
  by 
    simpa only [dual_Ico] using h

/-- If two half-open intervals are disjoint and the endpoint of one lies in the other,
  then it must be equal to the endpoint of the other. -/
theorem eq_of_Ico_disjoint {x₁ x₂ y₁ y₂ : α} (h : Disjoint (Ico x₁ x₂) (Ico y₁ y₂)) (hx : x₁ < x₂)
  (h2 : x₂ ∈ Ico y₁ y₂) : y₁ = x₂ :=
  by 
    rw [Ico_disjoint_Ico, min_eq_leftₓ (le_of_ltₓ h2.2), le_max_iff] at h 
    apply le_antisymmₓ h2.1 
    exact h.elim (fun h => absurd hx (not_lt_of_le h)) id

@[simp]
theorem Union_Ico_eq_Iio_self_iff {ι : Sort _} {f : ι → α} {a : α} :
  (⋃i, Ico (f i) a) = Iio a ↔ ∀ x (_ : x < a), ∃ i, f i ≤ x :=
  by 
    simp [←Ici_inter_Iio, ←Union_inter, subset_def]

@[simp]
theorem Union_Ioc_eq_Ioi_self_iff {ι : Sort _} {f : ι → α} {a : α} :
  (⋃i, Ioc a (f i)) = Ioi a ↔ ∀ x, a < x → ∃ i, x ≤ f i :=
  by 
    simp [←Ioi_inter_Iic, ←inter_Union, subset_def]

@[simp]
theorem bUnion_Ico_eq_Iio_self_iff {ι : Sort _} {p : ι → Prop} {f : ∀ i, p i → α} {a : α} :
  (⋃(i : _)(hi : p i), Ico (f i hi) a) = Iio a ↔ ∀ x (_ : x < a), ∃ i hi, f i hi ≤ x :=
  by 
    simp [←Ici_inter_Iio, ←Union_inter, subset_def]

@[simp]
theorem bUnion_Ioc_eq_Ioi_self_iff {ι : Sort _} {p : ι → Prop} {f : ∀ i, p i → α} {a : α} :
  (⋃(i : _)(hi : p i), Ioc a (f i hi)) = Ioi a ↔ ∀ x, a < x → ∃ i hi, x ≤ f i hi :=
  by 
    simp [←Ioi_inter_Iic, ←inter_Union, subset_def]

end LinearOrderₓ

end Set

