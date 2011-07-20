type pos = int*int*int*int



type expr_type =
  Void
| Bool
| Byte
| Word
| Pointer of expr_type
| Array of expr_type*(int option)

let is_scalar = function
  Array _	-> false
| _		-> true

let rec string_of_expr_type = function
  Void			-> "void"
| Bool			-> "bool"
| Byte			-> "byte"
| Word			-> "word"
| Pointer t		-> (string_of_expr_type t)^"*"
| Array (t,None)	-> (string_of_expr_type t)^"[]"
| Array (t,Some n)	-> (string_of_expr_type t)^"["^(string_of_int n)^"]"




exception Type_error of pos*string

let type_error p s = raise (Type_error (p,s))

let cannot_convert_error p expected actual =
	type_error p ("expression has type "^(string_of_expr_type actual)^" but an expression of type "^(string_of_expr_type expected)^" was expected")

let assert_type p expected actual = match (expected,actual) with
  a,b when a=b	-> ()
| Word, Byte	-> ()
| _		-> cannot_convert_error p expected actual

let assert_type_int p = function
  Word	-> ()
| Byte	-> ()
| _	-> type_error p "not an int"

let assert_type_ptr p = function
  Pointer _
| Array _	-> ()
| _		-> type_error p "not a pointer"

let conv_to_scalar = function
  Array (t,_)	-> Pointer t
| t		-> t

let rec unify_types p t1 t2 = match (conv_to_scalar t1,conv_to_scalar t2) with
  a,b when a=b			-> a
| Word,Byte			-> Word
| Byte,Word			-> Word
| Pointer a,Pointer b when a=b	-> Pointer a
| _				-> type_error p "incompatible types"

let rec unify_types_for_comparison p t1 t2 = match (conv_to_scalar t1,conv_to_scalar t2) with
  Byte,Byte			-> Byte
| Byte,Word			-> Word
| Word,Byte			-> Word
| Word,Word			-> Word
| Pointer a,Pointer b when a=b	-> Pointer a
| _				-> type_error p "wrong types for comparison"




type op_comp = EQ|NE|LT|LE|GT|GE
type op_log = LAnd | LOr
type op_binary = Add|Sub|And|Or|Xor|Adc|Sbc


type expr =
  Var of pos*string
| CallF of pos*string*(expr list)

| Singleton of pos

| True of pos
| False of pos
| OpComp of pos*op_comp*expr*expr
| OpLog of pos*op_log*expr*expr
| OpNot of pos*expr

| Const of pos*int
| OpArith of pos*op_binary*expr*expr
| OpNeg of pos*expr

| ConstString of pos*string

| Absolute of pos*string*expr_type
| ArrayIndex of pos*expr*expr
| Deref of pos*expr
| Ref of pos*expr

type instr =
  Store of pos*expr*expr
| CallP of pos*string*(expr list)
| Cond of pos*expr*block*block
| While of pos*expr*block
| DoWhile of pos*block*expr
| Repeat of pos*expr*block
| Break of pos*int
| Return of pos*expr

and block = instr list

type var_descr = string*expr_type

type param_decl = pos*var_descr

type var_decl = pos*(string*expr_type)*(int option)

type global_var_decl =
  Intern of var_decl
| Extern of pos*(string*expr_type)

type fun_prototype = string*(expr_type*(param_decl list))

type fun_body = (var_decl list)*block

type fun_decl = fun_prototype*fun_body

type program = (fun_prototype list)*(fun_decl list)*(global_var_decl list)



let var_descr_of_var_decl = function
  p,(n,t),_	-> n,t

let var_descr_of_global_var_decl = function
  Intern (_,v,_)
| Extern (_,v)		-> v

let var_descr_of_param_decl = snd

let string_of_param_decl (_,(n,t)) = (string_of_expr_type t)^" "^n

let string_of_param_decls l =
	"("^(String.concat ", " (List.map string_of_param_decl l))^")"

let rec string_of_prototype (name,(ret_type,params)) =
	(string_of_expr_type ret_type)
	^ " " ^ name
	^ (string_of_param_decls params)
