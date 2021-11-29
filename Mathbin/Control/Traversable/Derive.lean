import Mathbin.Control.Traversable.Lemmas

namespace Tactic.Interactive

open Tactic List Monadₓ Functor

unsafe def with_prefix : Option Name → Name → Name
| none, n => n
| some p, n => p ++ n

/-- similar to `nested_traverse` but for `functor` -/
unsafe def nested_map (f v : expr) : expr → tactic expr
| t =>
  do 
    let t ← instantiate_mvars t 
    mcond (succeeds$ is_def_eq t v) (pure f)
        (if ¬v.occurs t.app_fn then
          do 
            let cl ← mk_app `` Functor [t.app_fn]
            let _inst ← mk_instance cl 
            let f' ← nested_map t.app_arg 
            mk_mapp `` Functor.map [t.app_fn, _inst, none, none, f']
        else fail f! "type {t } is not a functor with respect to variable {v}")

/-- similar to `traverse_field` but for `functor` -/
unsafe def map_field (n : Name) (cl f α β e : expr) : tactic expr :=
  do 
    let t ← infer_type e >>= whnf 
    if t.get_app_fn.const_name = n then fail "recursive types not supported" else
        if α =ₐ e then pure β else
          if α.occurs t then
            do 
              let f' ← nested_map f α t 
              pure$ f' e
          else is_def_eq t.app_fn cl >> mk_app `` comp.mk [e] <|> pure e

-- error in Control.Traversable.Derive: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- similar to `traverse_constructor` but for `functor` -/
meta
def map_constructor
(c n : name)
(f α β : expr)
(args₀ : list expr)
(args₁ : list «expr × »(bool, expr))
(rec_call : list expr) : tactic expr :=
do {
g ← target,
  (_, args') ← mmap_accuml (λ
   (x : list expr)
   (y : «expr × »(bool, expr)), if y.1 then pure (x.tail, x.head) else «expr <$> »(prod.mk rec_call, map_field n g.app_fn f α β y.2)) rec_call args₁,
  constr ← mk_const c,
  let r := constr.mk_app «expr ++ »(args₀, args'),
  return r }

-- error in Control.Traversable.Derive: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- derive the `map` definition of a `functor` -/ meta def mk_map (type : name) :=
do {
ls ← local_context,
  «expr[ , ]»([α, β, f, x]) ← tactic.intro_lst «expr[ , ]»([`α, `β, `f, `x]),
  et ← infer_type x,
  xs ← tactic.induction x,
  xs.mmap' (λ x : «expr × »(name, «expr × »(list expr, list «expr × »(name, expr))), do {
   let (c, args, _) := x,
     (args, rec_call) ← «expr $ »(args.mpartition, λ e, «expr <$> »(«expr ∘ »(bnot, β.occurs), infer_type e)),
     args₀ ← «expr $ »(args.mmap, λ a, do b ← «expr <$> »(et.occurs, infer_type a), pure (b, a)),
     «expr >>= »(map_constructor c type f α β «expr ++ »(ls, «expr[ , ]»([β])) args₀ rec_call, tactic.exact) }) }

unsafe def mk_mapp_aux' : expr → expr → List expr → tactic expr
| fn, expr.pi n bi d b, a :: as =>
  do 
    infer_type a >>= unify d 
    let fn ← head_beta (fn a)
    let t ← whnf (b.instantiate_var a)
    mk_mapp_aux' fn t as
| fn, _, _ => pure fn

unsafe def mk_mapp' (fn : expr) (args : List expr) : tactic expr :=
  do 
    let t ← infer_type fn >>= whnf 
    mk_mapp_aux' fn t args

/-- derive the equations for a specific `map` definition -/
unsafe def derive_map_equations (pre : Option Name) (n : Name) (vs : List expr) (tgt : expr) : tactic Unit :=
  do 
    let e ← get_env
    ((e.constructors_of n).enumFrom 1).mmap'$
        fun ⟨i, c⟩ =>
          do 
            mk_meta_var tgt >>= set_goals ∘ pure 
            let vs ← intro_lst$ vs.map expr.local_pp_name 
            let [α, β, f] ← tactic.intro_lst [`α, `β, `f] >>= mmap instantiate_mvars 
            let c' ← mk_mapp c$ vs.map some ++ [α]
            let tgt' ← infer_type c' >>= pis vs 
            mk_meta_var tgt' >>= set_goals ∘ pure 
            let vs ← tactic.intro_lst$ vs.map expr.local_pp_name 
            let vs' ← tactic.intros 
            let c' ← mk_mapp c$ vs.map some ++ [α]
            let arg ← mk_mapp' c' vs' 
            let n_map ← mk_const (with_prefix pre n <.> "map")
            let call_map := fun x => mk_mapp' n_map (vs ++ [α, β, f, x])
            let lhs ← call_map arg 
            let args ←
              vs'.mmap$
                  fun a =>
                    do 
                      let t ← infer_type a 
                      pure ((expr.const_name (expr.get_app_fn t) = n : Bool), a)
            let rec_call := args.filter_map$ fun ⟨b, e⟩ => guardₓ b >> pure e 
            let rec_call ← rec_call.mmap call_map 
            let rhs ← map_constructor c n f α β (vs ++ [β]) args rec_call 
            Monadₓ.join$ unify <$> infer_type lhs <*> infer_type rhs 
            let eqn ← mk_app `` Eq [lhs, rhs]
            let ws := eqn.list_local_consts 
            let eqn ← pis ws.reverse eqn 
            let eqn ← instantiate_mvars eqn 
            let (_, pr) ← solve_aux eqn (tactic.intros >> refine (pquote.1 rfl))
            let eqn_n := (with_prefix pre n <.> "map" <.> "equations" <.> "_eqn").append_after i 
            let pr ← instantiate_mvars pr 
            add_decl$ declaration.thm eqn_n eqn.collect_univ_params eqn (pure pr)
            return ()
    set_goals []
    return ()

unsafe def derive_functor (pre : Option Name) : tactic Unit :=
  do 
    let vs ← local_context 
    let quote.1 (Functor (%%ₓf)) ← target 
    let env ← get_env 
    let n := f.get_app_fn.const_name 
    let d ← get_decl n 
    refine (pquote.1 { map := _, .. })
    let tgt ← target 
    extract_def (with_prefix pre n <.> "map") d.is_trusted$ mk_map n 
    when d.is_trusted$
        do 
          let tgt ← pis vs tgt 
          derive_map_equations pre n vs tgt

/-- `seq_apply_constructor f [x,y,z]` synthesizes `f <*> x <*> y <*> z` -/
private unsafe def seq_apply_constructor : expr → List (Sum expr expr) → tactic (List (tactic expr) × expr)
| e, Sum.inr x :: xs =>
  Prod.mapₓ (cons intro1) id <$> (to_expr (pquote.1 ((%%ₓe) <*> %%ₓx)) >>= flip seq_apply_constructor xs)
| e, Sum.inl x :: xs => Prod.mapₓ (cons$ pure x) id <$> seq_apply_constructor e xs
| e, [] => return ([], e)

/-- ``nested_traverse f α (list (array n (list α)))`` synthesizes the expression
`traverse (traverse (traverse f))`. `nested_traverse` assumes that `α` appears in
`(list (array n (list α)))` -/
unsafe def nested_traverse (f v : expr) : expr → tactic expr
| t =>
  do 
    let t ← instantiate_mvars t 
    mcond (succeeds$ is_def_eq t v) (pure f)
        (if ¬v.occurs t.app_fn then
          do 
            let cl ← mk_app `` Traversable [t.app_fn]
            let _inst ← mk_instance cl 
            let f' ← nested_traverse t.app_arg 
            mk_mapp `` Traversable.traverse [t.app_fn, _inst, none, none, none, none, f']
        else fail f! "type {t } is not traversable with respect to variable {v}")

/--
For a sum type `inductive foo (α : Type) | foo1 : list α → ℕ → foo | ...`
``traverse_field `foo appl_inst f `α `(x : list α)`` synthesizes
`traverse f x` as part of traversing `foo1`. -/
unsafe def traverse_field (n : Name) (appl_inst cl f v e : expr) : tactic (Sum expr expr) :=
  do 
    let t ← infer_type e >>= whnf 
    if t.get_app_fn.const_name = n then fail "recursive types not supported" else
        if v.occurs t then
          do 
            let f' ← nested_traverse f v t 
            pure$ Sum.inr$ f' e
        else is_def_eq t.app_fn cl >> Sum.inr <$> mk_app `` comp.mk [e] <|> pure (Sum.inl e)

-- error in Control.Traversable.Derive: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/--
For a sum type `inductive foo (α : Type) | foo1 : list α → ℕ → foo | ...`
``traverse_constructor `foo1 `foo appl_inst f `α `β [`(x : list α), `(y : ℕ)]``
synthesizes `foo1 <$> traverse f x <*> pure y.` -/
meta
def traverse_constructor
(c n : name)
(appl_inst f α β : expr)
(args₀ : list expr)
(args₁ : list «expr × »(bool, expr))
(rec_call : list expr) : tactic expr :=
do {
g ← target,
  args' ← mmap (traverse_field n appl_inst g.app_fn f α) args₀,
  (_, args') ← mmap_accuml (λ
   (x : list expr)
   (y : «expr × »(bool, _)), if y.1 then pure (x.tail, sum.inr x.head) else «expr <$> »(prod.mk x, traverse_field n appl_inst g.app_fn f α y.2)) rec_call args₁,
  constr ← mk_const c,
  v ← mk_mvar,
  constr' ← to_expr (``(@pure _ (%%appl_inst).to_has_pure _ (%%v))),
  (vars_intro, r) ← seq_apply_constructor constr' «expr ++ »(args₀.map sum.inl, args'),
  gs ← get_goals,
  set_goals «expr[ , ]»([v]),
  vs ← vars_intro.mmap id,
  tactic.exact (constr.mk_app vs),
  done,
  set_goals gs,
  return r }

-- error in Control.Traversable.Derive: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- derive the `traverse` definition of a `traversable` instance -/ meta def mk_traverse (type : name) :=
do {
do {
  ls ← local_context,
    «expr[ , ]»([m, appl_inst, α, β, f, x]) ← tactic.intro_lst «expr[ , ]»([`m, `appl_inst, `α, `β, `f, `x]),
    et ← infer_type x,
    reset_instance_cache,
    xs ← tactic.induction x,
    xs.mmap' (λ x : «expr × »(name, «expr × »(list expr, list «expr × »(name, expr))), do {
     let (c, args, _) := x,
       (args, rec_call) ← «expr $ »(args.mpartition, λ e, «expr <$> »(«expr ∘ »(bnot, β.occurs), infer_type e)),
       args₀ ← «expr $ »(args.mmap, λ a, do b ← «expr <$> »(et.occurs, infer_type a), pure (b, a)),
       «expr >>= »(traverse_constructor c type appl_inst f α β «expr ++ »(ls, «expr[ , ]»([β])) args₀ rec_call, tactic.exact) }) } }

open Applicativeₓ

/-- derive the equations for a specific `traverse` definition -/
unsafe def derive_traverse_equations (pre : Option Name) (n : Name) (vs : List expr) (tgt : expr) : tactic Unit :=
  do 
    let e ← get_env
    ((e.constructors_of n).enumFrom 1).mmap'$
        fun ⟨i, c⟩ =>
          do 
            mk_meta_var tgt >>= set_goals ∘ pure 
            let vs ← intro_lst$ vs.map expr.local_pp_name 
            let [m, appl_inst, α, β, f] ← tactic.intro_lst [`m, `appl_inst, `α, `β, `f] >>= mmap instantiate_mvars 
            let c' ← mk_mapp c$ vs.map some ++ [α]
            let tgt' ← infer_type c' >>= pis vs 
            mk_meta_var tgt' >>= set_goals ∘ pure 
            let vs ← tactic.intro_lst$ vs.map expr.local_pp_name 
            let c' ← mk_mapp c$ vs.map some ++ [α]
            let vs' ← tactic.intros 
            let arg ← mk_mapp' c' vs' 
            let n_map ← mk_const (with_prefix pre n <.> "traverse")
            let call_traverse := fun x => mk_mapp' n_map (vs ++ [m, appl_inst, α, β, f, x])
            let lhs ← call_traverse arg 
            let args ←
              vs'.mmap$
                  fun a =>
                    do 
                      let t ← infer_type a 
                      pure ((expr.const_name (expr.get_app_fn t) = n : Bool), a)
            let rec_call := args.filter_map$ fun ⟨b, e⟩ => guardₓ b >> pure e 
            let rec_call ← rec_call.mmap call_traverse 
            let rhs ← traverse_constructor c n appl_inst f α β (vs ++ [β]) args rec_call 
            Monadₓ.join$ unify <$> infer_type lhs <*> infer_type rhs 
            let eqn ← mk_app `` Eq [lhs, rhs]
            let ws := eqn.list_local_consts 
            let eqn ← pis ws.reverse eqn 
            let eqn ← instantiate_mvars eqn 
            let (_, pr) ← solve_aux eqn (tactic.intros >> refine (pquote.1 rfl))
            let eqn_n := (with_prefix pre n <.> "traverse" <.> "equations" <.> "_eqn").append_after i 
            let pr ← instantiate_mvars pr 
            add_decl$ declaration.thm eqn_n eqn.collect_univ_params eqn (pure pr)
            return ()
    set_goals []
    return ()

unsafe def derive_traverse (pre : Option Name) : tactic Unit :=
  do 
    let vs ← local_context 
    let quote.1 (Traversable (%%ₓf)) ← target 
    let env ← get_env 
    let n := f.get_app_fn.const_name 
    let d ← get_decl n 
    constructor 
    let tgt ← target 
    extract_def (with_prefix pre n <.> "traverse") d.is_trusted$ mk_traverse n 
    when d.is_trusted$
        do 
          let tgt ← pis vs tgt 
          derive_traverse_equations pre n vs tgt

unsafe def mk_one_instance (n : Name) (cls : Name) (tac : tactic Unit) (namesp : Option Name)
  (mk_inst : Name → expr → tactic expr := fun n arg => mk_app n [arg]) : tactic Unit :=
  do 
    let decl ← get_decl n 
    let cls_decl ← get_decl cls 
    let env ← get_env 
    guardₓ (env.is_inductive n) <|> fail f! "failed to derive '{cls }', '{n }' is not an inductive type"
    let ls := decl.univ_params.map$ fun n => level.param n 
    let tgt : expr := expr.const n ls 
    let ⟨params, _⟩ ← open_pis (decl.type.instantiate_univ_params (decl.univ_params.zip ls))
    let params := params.init 
    let tgt := tgt.mk_app params 
    let tgt ← mk_inst cls tgt 
    let tgt ←
      params.enum.mfoldr
          (fun ⟨i, param⟩ tgt =>
            do 
              let tgt ←
                (do 
                      guardₓ$ i < env.inductive_num_params n 
                      let param_cls ← mk_app cls [param]
                      pure$ expr.pi `a BinderInfo.inst_implicit param_cls tgt) <|>
                    pure tgt 
              pure$ tgt.bind_pi param)
          tgt
    () <$ mk_instance tgt <|>
        do 
          let (_, val) ←
            tactic.solve_aux tgt
                do 
                  tactic.intros >> tac 
          let val ← instantiate_mvars val 
          let trusted := decl.is_trusted ∧ cls_decl.is_trusted 
          let inst_n := with_prefix namesp n ++ cls 
          add_decl (declaration.defn inst_n decl.univ_params tgt val ReducibilityHints.abbrev trusted)
          set_basic_attribute `instance inst_n namesp.is_none

open Interactive

unsafe def get_equations_of (n : Name) : tactic (List pexpr) :=
  do 
    let e ← get_env 
    let pre := n <.> "equations"
    let x := e.fold []$ fun d xs => if pre.is_prefix_of d.to_name then d.to_name :: xs else xs 
    x.mmap resolve_name

unsafe def derive_lawful_functor (pre : Option Name) : tactic Unit :=
  do 
    let quote.1 (@IsLawfulFunctor (%%ₓf) (%%ₓd)) ← target 
    refine (pquote.1 { .. })
    let n := f.get_app_fn.const_name 
    let rules := fun r => [simp_arg_type.expr r, simp_arg_type.all_hyps]
    let goal := loc.ns [none]
    solve1
        do 
          let vs ← tactic.intros 
          try$ dunfold [`` Functor.map] (loc.ns [none])
          dunfold [with_prefix pre n <.> "map", `` id] (loc.ns [none])
          () <$ tactic.induction vs.ilast; simp none none ff (rules (pquote.1 Functor.map_id)) [] goal 
    focus1
        do 
          let vs ← tactic.intros 
          try$ dunfold [`` Functor.map] (loc.ns [none])
          dunfold [with_prefix pre n <.> "map", `` id] (loc.ns [none])
          () <$ tactic.induction vs.ilast; simp none none ff (rules (pquote.1 Functor.map_comp_map)) [] goal 
    return ()

unsafe def simp_functor (rs : List simp_arg_type := []) : tactic Unit :=
  simp none none ff rs [`functor_norm] (loc.ns [none])

unsafe def traversable_law_starter (rs : List simp_arg_type) :=
  do 
    let vs ← tactic.intros 
    resetI 
    dunfold [`` Traversable.traverse, `` Functor.map] (loc.ns [none])
    () <$ tactic.induction vs.ilast; simp_functor rs

-- error in Control.Traversable.Derive: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
meta def derive_lawful_traversable (pre : option name) : tactic unit :=
do {
`(@is_lawful_traversable (%%f) (%%d)) ← target,
  let n := f.get_app_fn.const_name,
  eqns ← get_equations_of «expr <.> »(with_prefix pre n, "traverse"),
  eqns' ← get_equations_of «expr <.> »(with_prefix pre n, "map"),
  let def_eqns := «expr ++ »(«expr ++ »(eqns.map simp_arg_type.expr, eqns'.map simp_arg_type.expr), «expr[ , ]»([simp_arg_type.all_hyps])),
  let comp_def := «expr[ , ]»([simp_arg_type.expr (``(function.comp))]),
  let tr_map := list.map simp_arg_type.expr «expr[ , ]»([``(traversable.traverse_eq_map_id')]),
  let natur := λ η : expr, «expr[ , ]»([simp_arg_type.expr (``(traversable.naturality_pf (%%η)))]),
  let goal := loc.ns «expr[ , ]»([none]),
  «expr ; »(«expr ; »(constructor, «expr[ , ]»([«expr ; »(traversable_law_starter def_eqns, refl), «expr ; »(traversable_law_starter def_eqns, «expr <|> »(refl, simp_functor «expr ++ »(def_eqns, comp_def))), «expr ; »(traversable_law_starter def_eqns, «expr <|> »(refl, simp none none tt tr_map «expr[ , ]»([]) goal)), «expr ; »(traversable_law_starter def_eqns, «expr <|> »(refl, do {
        η ← «expr <|> »(get_local (`η), do
           t ← «expr >>= »(«expr >>= »(mk_const (``is_lawful_traversable.naturality), infer_type), pp),
             fail «exprformat! »(format_macro "expecting an `applicative_transformation` called `η` in\nnaturality : {t}" [[expr t]])),
          simp none none tt (natur η) «expr[ , ]»([]) goal }))])), refl),
  return () }

open Function

unsafe def guard_class (cls : Name) (hdl : derive_handler) : derive_handler :=
  fun p n => if p.is_constant_of cls then hdl p n else pure ff

-- error in Control.Traversable.Derive: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
meta
def higher_order_derive_handler
(cls : name)
(tac : tactic unit)
(deps : list derive_handler := «expr[ , ]»([]))
(namesp : option name)
(mk_inst : name → expr → tactic expr := λ n arg, mk_app n «expr[ , ]»([arg])) : derive_handler :=
λ p n, do {
mmap' (λ f : derive_handler, f p n) deps,
  mk_one_instance n cls tac namesp mk_inst,
  pure tt }

unsafe def functor_derive_handler' (nspace : Option Name := none) : derive_handler :=
  higher_order_derive_handler `` Functor (derive_functor nspace) [] nspace

@[derive_handler]
unsafe def functor_derive_handler : derive_handler :=
  guard_class `` Functor functor_derive_handler'

unsafe def traversable_derive_handler' (nspace : Option Name := none) : derive_handler :=
  higher_order_derive_handler `` Traversable (derive_traverse nspace) [functor_derive_handler' nspace] nspace

@[derive_handler]
unsafe def traversable_derive_handler : derive_handler :=
  guard_class `` Traversable traversable_derive_handler'

unsafe def lawful_functor_derive_handler' (nspace : Option Name := none) : derive_handler :=
  higher_order_derive_handler `` IsLawfulFunctor (derive_lawful_functor nspace) [traversable_derive_handler' nspace]
    nspace fun n arg => mk_mapp n [arg, none]

@[derive_handler]
unsafe def lawful_functor_derive_handler : derive_handler :=
  guard_class `` IsLawfulFunctor lawful_functor_derive_handler'

unsafe def lawful_traversable_derive_handler' (nspace : Option Name := none) : derive_handler :=
  higher_order_derive_handler `` IsLawfulTraversable (derive_lawful_traversable nspace)
    [traversable_derive_handler' nspace, lawful_functor_derive_handler' nspace] nspace
    fun n arg => mk_mapp n [arg, none]

@[derive_handler]
unsafe def lawful_traversable_derive_handler : derive_handler :=
  guard_class `` IsLawfulTraversable lawful_traversable_derive_handler'

end Tactic.Interactive

