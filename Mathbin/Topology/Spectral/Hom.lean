/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import Mathbin.Topology.ContinuousFunction.Basic

/-!
# Spectral maps

This file defines spectral maps. A map is spectral when it's continuous and the preimage of a
compact open set is compact open.

## Main declarations

* `is_spectral_map`: Predicate for a map to be spectral.
* `spectral_map`: Bundled spectral maps.
* `spectral_map_class`: Typeclass for a type to be a type of spectral maps.

## TODO

Once we have `spectral_space`, `is_spectral_map` should move to `topology.spectral.basic`.
-/


open Function OrderDual

variable {F α β γ δ : Type _}

section Unbundled

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ] {f : α → β} {s : Set β}

/-- A function between topological spaces is spectral if it is continuous and the preimage of every
compact open set is compact open. -/
structure IsSpectralMap (f : α → β) extends Continuous f : Prop where
  is_compact_preimage_of_is_open ⦃s : Set β⦄ : IsOpen s → IsCompact s → IsCompact (f ⁻¹' s)
#align is_spectral_map IsSpectralMap

theorem IsCompact.preimage_of_is_open (hf : IsSpectralMap f) (h₀ : IsCompact s) (h₁ : IsOpen s) : IsCompact (f ⁻¹' s) :=
  hf.is_compact_preimage_of_is_open h₁ h₀
#align is_compact.preimage_of_is_open IsCompact.preimage_of_is_open

theorem IsSpectralMap.continuous {f : α → β} (hf : IsSpectralMap f) : Continuous f :=
  hf.to_continuous
#align is_spectral_map.continuous IsSpectralMap.continuous

theorem is_spectral_map_id : IsSpectralMap (@id α) :=
  ⟨continuous_id, fun s _ => id⟩
#align is_spectral_map_id is_spectral_map_id

theorem IsSpectralMap.comp {f : β → γ} {g : α → β} (hf : IsSpectralMap f) (hg : IsSpectralMap g) :
    IsSpectralMap (f ∘ g) :=
  ⟨hf.Continuous.comp hg.Continuous, fun s hs₀ hs₁ =>
    (hs₁.preimage_of_is_open hf hs₀).preimage_of_is_open hg (hs₀.Preimage hf.Continuous)⟩
#align is_spectral_map.comp IsSpectralMap.comp

end Unbundled

/-- The type of spectral maps from `α` to `β`. -/
structure SpectralMap (α β : Type _) [TopologicalSpace α] [TopologicalSpace β] where
  toFun : α → β
  spectral' : IsSpectralMap to_fun
#align spectral_map SpectralMap

section

/-- `spectral_map_class F α β` states that `F` is a type of spectral maps.

You should extend this class when you extend `spectral_map`. -/
class SpectralMapClass (F : Type _) (α β : outParam <| Type _) [TopologicalSpace α] [TopologicalSpace β] extends
  FunLike F α fun _ => β where
  map_spectral (f : F) : IsSpectralMap f
#align spectral_map_class SpectralMapClass

end

export SpectralMapClass (map_spectral)

attribute [simp] map_spectral

-- See note [lower instance priority]
instance (priority := 100) SpectralMapClass.toContinuousMapClass [TopologicalSpace α] [TopologicalSpace β]
    [SpectralMapClass F α β] : ContinuousMapClass F α β :=
  { ‹SpectralMapClass F α β› with map_continuous := fun f => (map_spectral f).Continuous }
#align spectral_map_class.to_continuous_map_class SpectralMapClass.toContinuousMapClass

instance [TopologicalSpace α] [TopologicalSpace β] [SpectralMapClass F α β] : CoeTC F (SpectralMap α β) :=
  ⟨fun f => ⟨_, map_spectral f⟩⟩

/-! ### Spectral maps -/


namespace SpectralMap

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ] [TopologicalSpace δ]

/-- Reinterpret a `spectral_map` as a `continuous_map`. -/
def toContinuousMap (f : SpectralMap α β) : ContinuousMap α β :=
  ⟨_, f.spectral'.Continuous⟩
#align spectral_map.to_continuous_map SpectralMap.toContinuousMap

instance : SpectralMapClass (SpectralMap α β) α β where
  coe := SpectralMap.toFun
  coe_injective' f g h := by
    cases f
    cases g
    congr
  map_spectral f := f.spectral'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (SpectralMap α β) fun _ => α → β :=
  FunLike.hasCoeToFun

@[simp]
theorem to_fun_eq_coe {f : SpectralMap α β} : f.toFun = (f : α → β) :=
  rfl
#align spectral_map.to_fun_eq_coe SpectralMap.to_fun_eq_coe

@[ext.1]
theorem ext {f g : SpectralMap α β} (h : ∀ a, f a = g a) : f = g :=
  FunLike.ext f g h
#align spectral_map.ext SpectralMap.ext

/-- Copy of a `spectral_map` with a new `to_fun` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (f : SpectralMap α β) (f' : α → β) (h : f' = f) : SpectralMap α β :=
  ⟨f', h.symm.subst f.spectral'⟩
#align spectral_map.copy SpectralMap.copy

@[simp]
theorem coe_copy (f : SpectralMap α β) (f' : α → β) (h : f' = f) : ⇑(f.copy f' h) = f' :=
  rfl
#align spectral_map.coe_copy SpectralMap.coe_copy

theorem copy_eq (f : SpectralMap α β) (f' : α → β) (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align spectral_map.copy_eq SpectralMap.copy_eq

variable (α)

/-- `id` as a `spectral_map`. -/
protected def id : SpectralMap α α :=
  ⟨id, is_spectral_map_id⟩
#align spectral_map.id SpectralMap.id

instance : Inhabited (SpectralMap α α) :=
  ⟨SpectralMap.id α⟩

@[simp]
theorem coe_id : ⇑(SpectralMap.id α) = id :=
  rfl
#align spectral_map.coe_id SpectralMap.coe_id

variable {α}

@[simp]
theorem id_apply (a : α) : SpectralMap.id α a = a :=
  rfl
#align spectral_map.id_apply SpectralMap.id_apply

/-- Composition of `spectral_map`s as a `spectral_map`. -/
def comp (f : SpectralMap β γ) (g : SpectralMap α β) : SpectralMap α γ :=
  ⟨f.toContinuousMap.comp g.toContinuousMap, f.spectral'.comp g.spectral'⟩
#align spectral_map.comp SpectralMap.comp

@[simp]
theorem coe_comp (f : SpectralMap β γ) (g : SpectralMap α β) : (f.comp g : α → γ) = f ∘ g :=
  rfl
#align spectral_map.coe_comp SpectralMap.coe_comp

@[simp]
theorem comp_apply (f : SpectralMap β γ) (g : SpectralMap α β) (a : α) : (f.comp g) a = f (g a) :=
  rfl
#align spectral_map.comp_apply SpectralMap.comp_apply

@[simp]
theorem coe_comp_continuous_map (f : SpectralMap β γ) (g : SpectralMap α β) :
    (f.comp g : ContinuousMap α γ) = (f : ContinuousMap β γ).comp g :=
  rfl
#align spectral_map.coe_comp_continuous_map SpectralMap.coe_comp_continuous_map

@[simp]
theorem comp_assoc (f : SpectralMap γ δ) (g : SpectralMap β γ) (h : SpectralMap α β) :
    (f.comp g).comp h = f.comp (g.comp h) :=
  rfl
#align spectral_map.comp_assoc SpectralMap.comp_assoc

@[simp]
theorem comp_id (f : SpectralMap α β) : f.comp (SpectralMap.id α) = f :=
  ext fun a => rfl
#align spectral_map.comp_id SpectralMap.comp_id

@[simp]
theorem id_comp (f : SpectralMap α β) : (SpectralMap.id β).comp f = f :=
  ext fun a => rfl
#align spectral_map.id_comp SpectralMap.id_comp

theorem cancel_right {g₁ g₂ : SpectralMap β γ} {f : SpectralMap α β} (hf : Surjective f) :
    g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => ext <| hf.forall.2 <| FunLike.ext_iff.1 h, congr_arg _⟩
#align spectral_map.cancel_right SpectralMap.cancel_right

theorem cancel_left {g : SpectralMap β γ} {f₁ f₂ : SpectralMap α β} (hg : Injective g) :
    g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => ext fun a => hg <| by rw [← comp_apply, h, comp_apply], congr_arg _⟩
#align spectral_map.cancel_left SpectralMap.cancel_left

end SpectralMap

