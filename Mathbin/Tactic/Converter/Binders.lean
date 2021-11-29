import Mathbin.Order.CompleteLattice

namespace OldConv

open Tactic Monadₓ

unsafe instance  : MonadFail old_conv :=
  { old_conv.monad with fail := fun α s => (fun r e => tactic.fail (to_fmt s) : old_conv α) }

unsafe instance  : HasMonadLift tactic old_conv :=
  ⟨fun α => lift_tactic⟩

unsafe instance  (α : Type) : Coe (tactic α) (old_conv α) :=
  ⟨monad_lift⟩

unsafe def current_relation : old_conv Name :=
  fun r lhs => return ⟨r, lhs, none⟩

unsafe def head_beta : old_conv Unit :=
  fun r e =>
    do 
      let n ← tactic.head_beta e 
      return ⟨(), n, none⟩

unsafe def congr_argₓ : old_conv Unit → old_conv Unit :=
  congr_core (return ())

unsafe def congr_funₓ : old_conv Unit → old_conv Unit :=
  fun c => congr_core c (return ())

unsafe def congr_rule (congr : expr) (cs : List (List expr → old_conv Unit)) : old_conv Unit :=
  fun r lhs =>
    do 
      let meta_rhs ← infer_type lhs >>= mk_meta_var 
      let t ← mk_app r [lhs, meta_rhs]
      let ((), meta_pr) ←
        solve_aux t
            do 
              apply congr 
              focus$
                  cs.map$
                    fun c =>
                      do 
                        let xs ← intros 
                        conversion (head_beta >> c xs)
              done 
      let rhs ← instantiate_mvars meta_rhs 
      let pr ← instantiate_mvars meta_pr 
      return ⟨(), rhs, some pr⟩

unsafe def congr_binder (congr : Name) (cs : expr → old_conv Unit) : old_conv Unit :=
  do 
    let e ← mk_const congr 
    congr_rule e
        [fun bs =>
            do 
              let [b] ← return bs 
              cs b]

unsafe def funext' : (expr → old_conv Unit) → old_conv Unit :=
  congr_binder `` _root_.funext

unsafe def propext' {α : Type} (c : old_conv α) : old_conv α :=
  fun r lhs =>
    (do 
        guardₓ (r = `iff)
        c r lhs) <|>
      do 
        guardₓ (r = `eq)
        let ⟨res, rhs, pr⟩ ← c `iff lhs 
        match pr with 
          | some pr => return ⟨res, rhs, (expr.const `propext [] : expr) lhs rhs pr⟩
          | none => return ⟨res, rhs, none⟩

unsafe def apply (pr : expr) : old_conv Unit :=
  fun r e =>
    do 
      let sl ← simp_lemmas.mk.add pr 
      apply_lemmas sl r e

unsafe def applyc (n : Name) : old_conv Unit :=
  fun r e =>
    do 
      let sl ← simp_lemmas.mk.add_simp n 
      apply_lemmas sl r e

unsafe def apply' (n : Name) : old_conv Unit :=
  do 
    let e ← mk_const n 
    congr_rule e []

end OldConv

open Expr Tactic OldConv

unsafe structure binder_eq_elim where 
  match_binder : expr → tactic (expr × expr)
  adapt_rel : old_conv Unit → old_conv Unit 
  apply_comm : old_conv Unit 
  apply_congr : (expr → old_conv Unit) → old_conv Unit 
  apply_elim_eq : old_conv Unit

unsafe def binder_eq_elim.check_eq (b : binder_eq_elim) (x : expr) : expr → tactic Unit
| quote.1 (@Eq (%%ₓβ) (%%ₓl) (%%ₓr)) => guardₓ (l = x ∧ ¬x.occurs r ∨ r = x ∧ ¬x.occurs l)
| _ => fail "no match"

unsafe def binder_eq_elim.pull (b : binder_eq_elim) (x : expr) : old_conv Unit :=
  do 
    let (β, f) ← lhs >>= lift_tactic ∘ b.match_binder 
    guardₓ ¬x.occurs β <|>
        b.check_eq x β <|>
          do 
            b.apply_congr$ fun x => binder_eq_elim.pull 
            b.apply_comm

unsafe def binder_eq_elim.push (b : binder_eq_elim) : old_conv Unit :=
  b.apply_elim_eq <|>
    (do 
        b.apply_comm 
        b.apply_congr$ fun x => binder_eq_elim.push) <|>
      do 
        b.apply_congr$ b.pull 
        binder_eq_elim.push

unsafe def binder_eq_elim.check (b : binder_eq_elim) (x : expr) : expr → tactic Unit
| e =>
  do 
    let (β, f) ← b.match_binder e 
    b.check_eq x β <|>
        do 
          let lam n bi d bd ← return f 
          let x ← mk_local' n bi d 
          binder_eq_elim.check$ bd.instantiate_var x

unsafe def binder_eq_elim.old_conv (b : binder_eq_elim) : old_conv Unit :=
  do 
    let (β, f) ← lhs >>= lift_tactic ∘ b.match_binder 
    let lam n bi d bd ← return f 
    let x ← mk_local' n bi d 
    b.check x (bd.instantiate_var x)
    b.adapt_rel b.push

theorem exists_elim_eq_left.{u, v} {α : Sort u} (a : α) (p : ∀ (a' : α), a' = a → Prop) :
  (∃ (a' : α)(h : a' = a), p a' h) ↔ p a rfl :=
  ⟨fun ⟨a', ⟨h, p_h⟩⟩ =>
      match a', h, p_h with 
      | _, rfl, h => h,
    fun h => ⟨a, rfl, h⟩⟩

theorem exists_elim_eq_right.{u, v} {α : Sort u} (a : α) (p : ∀ (a' : α), a = a' → Prop) :
  (∃ (a' : α)(h : a = a'), p a' h) ↔ p a rfl :=
  ⟨fun ⟨a', ⟨h, p_h⟩⟩ =>
      match a', h, p_h with 
      | _, rfl, h => h,
    fun h => ⟨a, rfl, h⟩⟩

unsafe def exists_eq_elim : binder_eq_elim :=
  { match_binder :=
      fun e =>
        do 
          let quote.1 (@Exists (%%ₓβ) (%%ₓf)) ← return e 
          return (β, f),
    adapt_rel := propext', apply_comm := applyc `` exists_comm, apply_congr := congr_binder `` exists_congr,
    apply_elim_eq := apply' `` exists_elim_eq_left <|> apply' `` exists_elim_eq_right }

theorem forall_comm.{u, v} {α : Sort u} {β : Sort v} (p : α → β → Prop) : (∀ a b, p a b) ↔ ∀ b a, p a b :=
  ⟨fun h b a => h a b, fun h b a => h a b⟩

theorem forall_elim_eq_left.{u, v} {α : Sort u} (a : α) (p : ∀ (a' : α), a' = a → Prop) :
  (∀ (a' : α) (h : a' = a), p a' h) ↔ p a rfl :=
  ⟨fun h => h a rfl,
    fun h a' h_eq =>
      match a', h_eq with 
      | _, rfl => h⟩

theorem forall_elim_eq_right.{u, v} {α : Sort u} (a : α) (p : ∀ (a' : α), a = a' → Prop) :
  (∀ (a' : α) (h : a = a'), p a' h) ↔ p a rfl :=
  ⟨fun h => h a rfl,
    fun h a' h_eq =>
      match a', h_eq with 
      | _, rfl => h⟩

unsafe def forall_eq_elim : binder_eq_elim :=
  { match_binder :=
      fun e =>
        do 
          let expr.pi n bi d bd ← return e 
          return (d, expr.lam n bi d bd),
    adapt_rel := propext', apply_comm := applyc `` forall_comm, apply_congr := congr_binder `` forall_congrₓ,
    apply_elim_eq := apply' `` forall_elim_eq_left <|> apply' `` forall_elim_eq_right }

unsafe def supr_eq_elim : binder_eq_elim :=
  { match_binder :=
      fun e =>
        do 
          let quote.1 (@supr (%%ₓα) (%%ₓcl) (%%ₓβ) (%%ₓf)) ← return e 
          return (β, f),
    adapt_rel :=
      fun c =>
        do 
          let r ← current_relation 
          guardₓ (r = `eq)
          c,
    apply_comm := applyc `` supr_comm, apply_congr := congr_argₓ ∘ funext',
    apply_elim_eq := applyc `` supr_supr_eq_left <|> applyc `` supr_supr_eq_right }

unsafe def infi_eq_elim : binder_eq_elim :=
  { match_binder :=
      fun e =>
        do 
          let quote.1 (@infi (%%ₓα) (%%ₓcl) (%%ₓβ) (%%ₓf)) ← return e 
          return (β, f),
    adapt_rel :=
      fun c =>
        do 
          let r ← current_relation 
          guardₓ (r = `eq)
          c,
    apply_comm := applyc `` infi_comm, apply_congr := congr_argₓ ∘ funext',
    apply_elim_eq := applyc `` infi_infi_eq_left <|> applyc `` infi_infi_eq_right }

universe u v w w₂

variable{α : Type u}{β : Type v}{ι : Sort w}{ι₂ : Sort w₂}{s t : Set α}{a : α}

section 

variable[CompleteLattice α]

example  {s : Set β} {f : β → α} : Inf (Set.Image f s) = ⨅(a : _)(_ : a ∈ s), f a :=
  by 
    simp [Inf_eq_infi, infi_and]
    runTac 
      conversion infi_eq_elim.old_conv

example  {s : Set β} {f : β → α} : Sup (Set.Image f s) = ⨆(a : _)(_ : a ∈ s), f a :=
  by 
    simp [Sup_eq_supr, supr_and]
    runTac 
      conversion supr_eq_elim.old_conv

end 

