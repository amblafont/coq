
(*i $Id$ i*)

(*i*)
open Pp
open Names
open Pcoq
(*i*)

(* Abstract syntax trees. *)

val dummy_loc : Coqast.loc
val loc : Coqast.t -> Coqast.loc

(* ast constructors with dummy location *)
val ope : string * Coqast.t list -> Coqast.t
val slam : string option * Coqast.t -> Coqast.t
val nvar : string -> Coqast.t
val ide : string -> Coqast.t
val num : int -> Coqast.t
val str : string -> Coqast.t
val path : string list -> string -> Coqast.t
val dynamic : Dyn.t -> Coqast.t

val set_loc : Coqast.loc -> Coqast.t -> Coqast.t

val path_section : Coqast.loc -> section_path -> Coqast.t
val section_path : string list -> string -> section_path


(* ast destructors *)
val num_of_ast : Coqast.t -> int
val id_of_ast : Coqast.t -> string
val nvar_of_ast : Coqast.t -> string

(* ast processing datatypes *)

(* patterns of ast *)
type pat =
  | Pquote of Coqast.t
  | Pmeta of string * tok_kind
  | Pnode of string * patlist
  | Pslam of string option * pat
  | Pmeta_slam of string * pat

and patlist =
  | Pcons of pat * patlist
  | Plmeta of string
  | Pnil

and tok_kind = Tnum | Tid | Tstr | Tpath | Tvar | Tany | Tlist

(* semantic actions of grammar rules *)
type act =
  | Aast of pat
  | Aastlist of patlist
  | Acase of act * (pat * act) list
  | Acaselist of act * (patlist * act) list

(* values associated to variables *)
type v =
  | Vast of Coqast.t
  | Vastlist of Coqast.t list

type env = (string * v) list

val coerce_to_var : string -> Coqast.t -> string

exception No_match of string

val isMeta : string -> bool

val print_ast : Coqast.t -> std_ppcmds
val print_astl : Coqast.t list -> std_ppcmds
val print_astpat : pat -> std_ppcmds
val print_astlpat : patlist -> std_ppcmds

(* Meta-syntax operations: matching and substitution *)

type entry_env = (string * entry_type) list

val grammar_type_error : Coqast.loc * string -> 'a
 
(* Converting and checking free meta-variables *)
val pat_sub : Coqast.loc -> env -> pat -> Coqast.t
val val_of_ast : entry_env -> Coqast.t -> pat
val vall_of_astl : entry_env -> Coqast.t list -> patlist

val alpha_eq : Coqast.t * Coqast.t -> bool
val alpha_eq_val : v * v -> bool

val occur_var_ast : string -> Coqast.t -> bool
val replace_var_ast : string -> string -> Coqast.t -> Coqast.t

val bind_env : env -> string -> v -> env
val ast_match : env -> pat -> Coqast.t -> env
val astl_match : env -> patlist -> Coqast.t list -> env
val first_match : ('a -> pat) -> env -> Coqast.t -> 'a list ->
  ('a * env) option
val first_matchl : ('a -> patlist) -> env -> Coqast.t list -> 'a list ->
  ('a * env) option

val to_pat : entry_env -> Coqast.t -> (pat * entry_env)

val eval_act : Coqast.loc -> env -> act -> v
val to_act_check_vars : entry_env -> entry_type -> Coqast.t -> act

(* Hash-consing *)
val hcons_ast: (string -> string) ->
  (Coqast.t -> Coqast.t) * (Coqast.loc -> Coqast.loc)

