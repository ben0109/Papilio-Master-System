open Syntax
open Parser

let deref_non_scalar_type_error p t =
	type_error p ("cannot deref non-scalar type "^(string_of_expr_type t))

let arith_type_error p ti tj =
	type_error p ("cannot mix type "^(string_of_expr_type ti)^" with type "^(string_of_expr_type tj))

type annotated_expr =
  AVar of pos*string*expr_type
| ACallF of pos*string*(annotated_expr list)*expr_type

| ASingleton of pos

| ATrue of pos
| AFalse of pos
| AOpComp of pos*op_comp*annotated_expr*annotated_expr*expr_type
| AOpLog of pos*op_log*annotated_expr*annotated_expr
| AOpNot of pos*annotated_expr

| AConst of pos*int*expr_type
| AOpArith of pos*op_binary*annotated_expr*annotated_expr*expr_type
| AOpNeg of pos*annotated_expr*expr_type

| AConstString of pos*string

| AAbsolute of pos*string*expr_type
| AArrayIndex of pos*annotated_expr*annotated_expr*expr_type
| ADeref of pos*annotated_expr*expr_type
| ARef of pos*annotated_expr*expr_type

| AConv of annotated_expr*expr_type*expr_type

type annotated_instr =
  AStore of pos*annotated_expr*annotated_expr
| ACallP of pos*string*(annotated_expr list)
| ACond of pos*annotated_expr*annotated_block*annotated_block
| AWhile of pos*annotated_expr*annotated_block
| ADoWhile of pos*annotated_block*annotated_expr
| ARepeat of pos*annotated_expr*annotated_block
| ABreak of pos*int
| AReturn of pos*annotated_expr

and annotated_block = annotated_instr list

type annotated_var_decl = pos*(string*expr_type)*(annotated_instr option)

type annotated_fun_body = (annotated_var_decl list)*annotated_block

type annotated_fun_decl = fun_prototype*annotated_fun_body

type annotated_program = (annotated_fun_decl list)*(var_decl list)


type typing_env = fun_prototype list*(var_descr list)*(var_descr list)




let rec get_type_of_annotated_expr = function
  ASingleton _		-> Void

| ATrue	_
| AFalse _
| AOpComp (_,_,_,_,_)
| AOpLog (_,_,_,_)
| AOpNot(_,_)		-> Bool

| AConstString(_,_)	-> Pointer Byte

| AConv (_,_,t)
| AVar (_,_,t)
| ACallF (_,_,_,t)
| AConst (_,_,t)
| AOpArith(_,_,_,_,t)
| AOpNeg(_,_,t)

| AArrayIndex (_,_,_,t)	
| ADeref (_,_,t)	-> t

| AAbsolute (_,_,t)
| ARef (_,_,t)		-> Pointer t

let rec get_location = function
  AConv(e,_,_)		-> get_location e

| AVar(p,_,_)
| ACallF(p,_,_,_)

| ASingleton p

| ATrue p
| AFalse p
| AOpComp(p,_,_,_,_)
| AOpLog(p,_,_,_)
| AOpNot(p,_)

| AConst(p,_,_)
| AOpArith(p,_,_,_,_)
| AOpNeg(p,_,_)

| AConstString(p,_)

| AAbsolute(p,_,_)
| ADeref(p,_,_)
| ARef(p,_,_)		-> p

let rec find_in_list p msg vars v =
	let rec loop = function
	  []			-> type_error p (msg^v)
	| (v',t)::_ when v=v'	-> t
	| _::l			-> loop l
	in
	loop vars

let lookup_var locals globals p v =
	try let t = List.assoc v locals in AVar(p,v,t)
	with Not_found ->
	try let t = List.assoc v globals in ADeref(p,AAbsolute(p,v,t),t)
	with Not_found ->
		type_error p ("unbound variable "^v)

let lookup_function functions p f =
	let rec loop = function
	  []			-> type_error p ("unknown function "^f)
	| (f',t)::_ when f=f'	-> t
	| _::l			-> loop l
	in
	loop functions

let rec is_subtype expected actual = match expected,actual with
  a,b when a=b			-> true
| Bool,Byte
| Bool,Word
| Byte,Word			-> true
| Array (b,_),Pointer a		-> a=b 
| Array (a,_),Array (b,_)	-> a=b 
| _				-> false

let conv expr expected =
	let actual = get_type_of_annotated_expr expr in

	if actual=expected
	then expr

	else if is_subtype actual expected
	then AConv(expr, actual, expected)
	else cannot_convert_error (get_location expr) expected actual		
		

let rec annotate_expr (env:typing_env) expr expected_type =
	let conv_if_needed annotated_expr =
		match expected_type with
		  None -> annotated_expr
		| Some t -> conv annotated_expr t
	in
	let assert_expected p t =
		match expected_type with
		  None -> ()
		| Some t' -> assert_type p t' t
	in
	let functions,globals,locals = env in
	match expr with
	  Var (p,v) ->
		conv_if_needed (lookup_var locals globals p v)
	| CallF (p,name,params) ->
		let params',t = annotate_call env p name params in
		let call' = ACallF(p,name,params',t) in
		begin
		match expected_type with
		  None -> call'
		| Some t' -> conv call' t'
		end

	| Singleton p	-> assert_expected p Void; ASingleton p

	| True p	-> assert_expected p Bool; ATrue p
	| False	p	-> assert_expected p Bool; AFalse p
	| OpComp (p,op,i,j) ->
		assert_expected p Bool;
		let i' = annotate_expr env i None
		and j' = annotate_expr env j None in
		let ti = get_type_of_annotated_expr i'
		and tj = get_type_of_annotated_expr j' in
		let t = unify_types_for_comparison p ti tj in
		AOpComp(p,op,conv i' t,conv j' t,t)
	| OpLog (p,op,a,b) ->
		assert_expected p Bool;
		AOpLog(p,op,annotate_expr env a (Some Bool),annotate_expr env b (Some Bool))
	| OpNot (p,i) ->
		assert_expected p Bool;
		conv_if_needed (AOpNot(p,annotate_expr env i (Some Bool)))

	| Const (p,i) ->
		let t = match expected_type with
		  None when i<0x100	-> Byte
		| None when i<0x10000	-> Word
		| Some Byte		-> Byte
		| Some Word		-> Word
		| _ -> type_error p "type mismatch"
		in
		AConst(p,i,t)
	| OpArith (p,op,i,j) ->
		let i' = annotate_expr env i None
		and j' = annotate_expr env j None in
		let ti = get_type_of_annotated_expr i'
		and tj = get_type_of_annotated_expr j' in
		let i'',j'',t = match ti with
		  Byte
		| Word		->
			let t = unify_types p ti tj in
			conv i' t,conv j' t,t
		| Pointer _	-> i',(conv j' Word),ti
		| _		-> arith_type_error p ti tj
		in
		conv_if_needed (AOpArith(p,op,i'',j'',t))
	| OpNeg (p,i) ->
		let i' = annotate_expr env i None in
		let ti = get_type_of_annotated_expr i' in
		assert_type_int p ti;
		conv_if_needed (AOpNeg(p,i',ti))

	| Absolute (p,e,t) ->
		assert_expected p (Pointer t);
		AAbsolute (p,e,t)
	| ArrayIndex (p,e,f) ->
		let e' = annotate_expr env e None in
		let f' = annotate_expr env f (Some Word) in
		begin
		match get_type_of_annotated_expr e' with
		  Pointer t
		| Array (t,_)	-> conv_if_needed (AArrayIndex (p,e',f',t))
		| _ -> type_error p "not an array"
		end
	| Deref (p,e) ->
		let e' = annotate_expr env e None in
		begin
		match get_type_of_annotated_expr e' with
		  Pointer t		-> conv_if_needed (ADeref (p,e',t))
		| _ -> type_error p "not a pointer"
		end
	| Ref (p,e) ->
		let e' = annotate_expr env e None in
		let t = get_type_of_annotated_expr e' in
		conv_if_needed (ARef (p,e',t))

	| ConstString (p,s) -> AConstString (p,s)

and annotate_call env p name params = 
	let functions,_,_ = env in
	let t,params_decl = lookup_function functions p name in
	let param_types = List.map (fun (_,(_,t)) -> t) params_decl in
	if (List.length param_types)!=(List.length params)
	then type_error p "wrong number of parameters";
	let params' = List.map2 
		(fun expected_type param_value -> annotate_expr env param_value (Some expected_type))
		param_types
		params
	in
	params',t

let rec annotate_instr (env:typing_env) fun_type =
	function
	  Store (p,Var (p',v),e) ->
		let varv' = annotate_expr env (Var (p',v)) None in
		let t = get_type_of_annotated_expr varv' in
		AStore(p,varv', annotate_expr env e (Some t))
	| Store (p,Deref (p',e),f) ->
		let derefe' = annotate_expr env (Deref (p',e)) None in
		let t = get_type_of_annotated_expr derefe' in
		AStore(p,derefe',annotate_expr env f (Some t))
	| Store (p,ArrayIndex (p',e,f),g) ->
		let aindexef' = annotate_expr env (ArrayIndex (p',e,f)) None in
		let t = get_type_of_annotated_expr aindexef' in
		AStore(p,aindexef',annotate_expr env g (Some t))
	| Store (p,_,_) -> type_error p "wrong lhs"

	| CallP (p,name,params) ->
		let params',t = annotate_call env p name params in
		assert_type p Void t;
		ACallP(p,name,params')

	| Cond (p,b,t,f) ->
		ACond(p,annotate_expr env b (Some Bool),
			annotate_block env fun_type t,
			annotate_block env fun_type f)
	| While (p,c,b) ->
		AWhile (p,
			annotate_expr env c (Some Bool),
			annotate_block env fun_type b)
	| DoWhile (p,b,c) ->
		ADoWhile (p,
			annotate_block env fun_type b,
			annotate_expr env c (Some Bool))
	| Repeat (p,n,b) ->
		let n' = annotate_expr env n None in
		assert_type_int p (get_type_of_annotated_expr n');
		ARepeat(p,n',annotate_block env fun_type b)
	| Break (p,i) -> ABreak (p,i)
	| Return (p,e) ->
		AReturn (p,annotate_expr env e (Some fun_type))

and annotate_block env fun_type = List.map (annotate_instr env fun_type)


let annotate_global_var_decl env (p,(n,t),i) =
	let i' = match i with
	  None		-> []
	| Some v	-> match t with
		  t when is_scalar t	-> [AStore (p,ADeref(p,AAbsolute (p,n,t),t),AConst(p,v,t))]
		| _			-> type_error p ("cannot initialize "^n)
	in
	(p,(n,t),i')

let annotate_local_var_decl env (p,(n,t),i) =
	let i' = match i with
	  None		-> []
	| Some v	-> match t with
		  t when is_scalar t	-> [AStore (p,AVar (p,n,t),AConst(p,v,t))]
		| _			-> type_error p ("cannot initialize "^n)
	in
	(p,(n,t),i')
	
let annotate_fun_decl env (f:fun_decl) =
	let fun_prototype,(local_decl,code) = f in
	let name,(fun_type,param_decl) = fun_prototype
	in
	let prototypes,global_vars = env in
	let vars = (List.map var_descr_of_param_decl param_decl)
		 @ (List.map var_descr_of_var_decl local_decl)
	in
	let env' = prototypes,global_vars,vars in
	fun_prototype,
	(List.map (annotate_local_var_decl env') local_decl,
	 annotate_block env' fun_type code)

let type_check_program (prototypes,function_decls,global_var_decls) =
	(* todo : check for duplicate names *)
	let env = 
		prototypes@(List.map fst function_decls),
		(List.map var_descr_of_global_var_decl global_var_decls)
	in
	let intern_global_var_decls = List.flatten
		(List.map (function Intern v -> [v] | _ -> []) global_var_decls)
	in
	(List.map (annotate_fun_decl env) function_decls),
	(List.map (annotate_global_var_decl env) intern_global_var_decls)


