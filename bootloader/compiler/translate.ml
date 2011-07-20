open Syntax
open Typing
open Assembly

type stack_elt = string*(expr_type*int)

let rec size_of_type = function
  Void			-> 0
| Bool			-> 1
| Byte			-> 1
| Word			-> 2
| Pointer _		-> 2
| Array (t,Some n)	-> n*size_of_type t
| Array (t,None)	-> failwith "cannot compute size of type"

let find_var stack v =
	try List.assoc v stack
	with Not_found -> failwith ("unbound name "^v)

let get_address n = [PUSH IX;POP HL;_LD16_i(DE,n);_ADD_HL_DE;PUSH HL]

let read_var p n = function
  Void		-> []
| Bool
| Byte		-> [_LD8_IX (A,n);PUSH AF]
| Word
| Pointer _	-> [_LD8_IX (L,n);_LD8_IX (H,n+1);PUSH HL]
| Array _ as t	-> get_address n

let read_ptr p = function
  Void		-> []
| Bool
| Byte		-> [_LD8_HL A;PUSH AF]
| Word
| Pointer _	-> [_LD8_HL E;_INC16 HL;_LD8_HL D;EX_DE_HL;PUSH HL]
| Array _ as t	-> [PUSH HL]

let store_var p n = function
  Void		-> []
| Bool
| Byte		-> [POP AF;_ST8_IX (A,n)]
| Word
| Pointer _	-> [POP HL;_ST8_IX (L,n);_ST8_IX (H,n+1)]
| Array _ as t	-> deref_non_scalar_type_error p t

let store_ptr p = function
  Void		-> []
| Bool
| Byte		-> [POP HL;POP AF;_ST8_HL A]
| Word
| Pointer _	-> [POP HL;POP DE;_ST8_HL E;_INC16 HL;_ST8_HL D]
| Array _ as t	-> deref_non_scalar_type_error p t

let compute_array_address p = function
  _		-> [POP DE;POP HL;OP(Add,Reg16 HL,Reg16 DE);PUSH HL]

let push p = function
  Void		-> []
| Bool
| Byte		-> [PUSH AF]
| Word
| Pointer _	-> [PUSH HL]
| Array _ as t	-> deref_non_scalar_type_error p t

let pop p = function
  Void		-> []
| Bool
| Byte		-> [POP AF]
| Word
| Pointer _	-> [POP HL]
| Array _ as t	-> deref_non_scalar_type_error p t

let translate_cc = function
  EQ	-> [PUSH AF;POP HL;_RL L;_RL L;_RL A]
| NE	-> [PUSH AF;POP HL;_RL L;_RL L;CCF;_RL A]
| LT	-> [PUSH AF;POP HL;_LD8(A,L)]
| GE	-> [PUSH AF;POP HL;_LD8(A,L);CPL]
| _	-> failwith "cannot translate comparison"

let counter = ref 0
let get_label fun_name =
	incr counter;
	"_"^fun_name^"_"^(string_of_int !counter)

let rec translate_expr stack fun_name expr =
	match expr with
	  AConv (e,t,t') ->
		let conv = match t,t' with
		  a,b when a=b	-> []
		| Bool,Word
		| Byte,Word	-> [POP AF;_LD8(L,A);_LD8_i(H,0);PUSH HL]
		| _		-> []
		in
		let c,l = translate_expr stack fun_name e in
		c@conv,l

	| AVar (p,v,t)	->
		let n = find_var stack v in 
		read_var p n t,[]
	| ACallF (p,name,params,t) ->
		translate_call stack fun_name p name params t

	| ASingleton p	-> [],[]

	| ATrue p	-> [_LD8_i (A,1);PUSH AF],[]
	| AFalse p	-> [_OP_A_r (Xor,A);PUSH AF],[]
	| AOpComp (p,op,i,j,t) ->
		let op',i',j' = match op with
		  LE -> GE,j,i
		| GT -> LT,j,i
		| _  -> op,i,j
		in
		let comp = match t with
		  Byte  	-> [POP HL;POP AF;_OP_A_r(Sub,H)]
		| Word
		| Pointer _	-> [POP DE;POP HL;SCF;CCF;_SBC_HL_DE]
		| _		-> failwith "cannot compare type"
		in
		let ci,li = translate_expr stack fun_name i'
		and cj,lj = translate_expr stack fun_name j' in
		let code = ci@cj@comp@(translate_cc op')@[PUSH AF]
		and labels = li@lj in
		code,labels

	| AOpLog (p,op,i,j) ->
		let ci,li = translate_expr stack fun_name i
		and cj,lj = translate_expr stack fun_name j in
		let op_arith = match op with
		  LAnd	-> And
		| LOr	-> Or
		in
		let code = ci@cj@[POP HL;POP AF;_OP_A_r(op_arith,L);PUSH AF]
		and labels = li@lj in
		code,labels
	| AOpNot (p,i) ->
		let ci,li = translate_expr stack fun_name i in
		ci@[POP AF;CPL;PUSH AF],li

	| AConst (p,i,t) -> 
		begin
		match t with
		  Byte		-> [_LD8_i (A,i);PUSH AF],[]
		| Word
		| Pointer _	-> [_LD16_i (HL,i);PUSH HL],[]
		| _		-> failwith "wrong constant type"
		end
	| AOpNeg (p,i,t) ->
		let ci,li = translate_expr stack fun_name i in
		let alu = match t with
		  Byte		-> [POP AF;NEG;PUSH AF]
		| _		-> failwith "cannot operate on type"
		in
		ci@alu,li
	| AOpArith (p,op,i,j,t) ->
		let ci,li = translate_expr stack fun_name i
		and cj,lj = translate_expr stack fun_name j in
		let alu = match t with
		  Byte		-> [POP HL;POP AF;_OP_A_r(op,H);PUSH AF]
		| Word
		| Pointer _	-> 
			begin
			match op with
			  Add -> [POP DE;POP HL;_ADD_HL_DE;PUSH HL]
			| Sub -> [POP DE;POP HL;SCF;CCF;_SBC_HL_DE;PUSH HL]
			| _ -> [POP DE;POP HL;
				_LD8 (A,L);_OP_A_r (op,E);_LD8 (L,A);
				_LD8 (A,H);_OP_A_r (op,D);_LD8 (H,A);
				PUSH HL]
			end
		| _		-> failwith "cannot operate on type"
		in
		let code = ci@cj@alu
		and labels = li@lj in
		code,labels

	| AConstString (p,s) ->
		let lbl = get_label fun_name in
		[_LD16_const (HL,lbl);PUSH HL],[Label lbl;DB_string s]

	| AAbsolute (p,name,t)	->
		[_LD16_const (HL,name);PUSH HL],[]
	| AArrayIndex (p,e,f,t)	->
		let ce,le = translate_expr stack fun_name e
		and cf,lf = translate_expr stack fun_name f in
		let code = ce@cf@(compute_array_address p t) in
		code@(pop p (Pointer t))@(read_ptr p t),le@lf
	| ADeref (p,e,t)	->
		let c,labels = translate_expr stack fun_name e in
		let code = c@(pop p (Pointer t))@(read_ptr p t) in
		code,labels
	| ARef (p,e,t)		->
		begin
		match e with
		  AVar(_,v,_)		-> let n = find_var stack v in get_address n,[]
		| ADeref(_,v,_)		-> translate_expr stack fun_name v
		| AArrayIndex(_,e,f,t)	->
			let ce,le = translate_expr stack fun_name e
			and cf,lf = translate_expr stack fun_name f in
			ce@cf@(compute_array_address p t),le@lf
		| _			-> failwith "not a referencable value"
		end

and translate_call stack fun_name p name params t =
	let lcode,llabels = List.split (List.map (translate_expr stack fun_name) params) in
	let code = List.flatten lcode
	and labels = List.flatten llabels in
	let pop_params = List.map (fun _->POP DE) params
	in
	code@[CALL name]@pop_params@(push p t), labels

let build_break loops i = 
	let rec loop i code = function
	  (lbl,Some rr)::loops when i=1 -> (JX (true,lbl))::(POP rr)::code
	| (lbl,None)   ::loops when i=1 -> (JX (true,lbl))::code
	| (lbl,Some rr)::loops		-> loop (i-1) ((POP rr)::code) loops
	| (lbl,None)   ::loops		-> loop (i-1) code loops
	| []				-> failwith "not enough loops"
	in
	List.rev(loop i [] loops)

let build_return loops lbl =
	let rec loop code = function
	| (_,Some rr)::loops	-> loop ((POP rr)::code) loops
	| (_,None)   ::loops	-> loop code loops
	| []			-> (JX (false,lbl))::code
	in
	List.rev (loop [] loops)

let rec translate_instr stack fun_prototype loops =
	let fun_name,(fun_type,_) = fun_prototype in
	function
	  AStore (p,AVar (p',v,t),e) ->
		let n = find_var stack v in 
		let c,l = translate_expr stack fun_name e in
		c@(store_var p n t), l
	| AStore (p,AArrayIndex (p',e,f,t),g) ->
		let cg,lg = translate_expr stack fun_name g
		and cf,lf = translate_expr stack fun_name f
		and ce,le = translate_expr stack fun_name e in
		let code = cg@cf@ce@[POP DE;POP HL;OP(Add,Reg16 HL,Reg16 DE);PUSH HL]@(store_ptr p t)
		and labels = lf@le in
		code,labels
	| AStore (p,ADeref (p',e,t),f) ->
		let cf,lf = translate_expr stack fun_name f
		and ce,le = translate_expr stack fun_name e in
		let code = cf@ce@(store_ptr p t)
		and labels = lf@le in
		code,labels
	| AStore (p,_,_) -> failwith "forbidden store"
	| ACallP (p,name,params) ->
		translate_call stack fun_name p name params Void
	| ACond (p,b,t,f) ->
		let lbl_else = get_label fun_name
		and lbl_endif = get_label fun_name in
		let cb,lb = translate_expr stack fun_name b
		and ct,lt = translate_block stack fun_prototype loops t
		and cf,lf = translate_block stack fun_prototype loops f in
		let code = 
			cb
			@ [POP AF;_OP_A_i(And,1);JX_cc(true,CC_Z,lbl_else)]
			@ ct
			@ [JX(true,lbl_endif);Label lbl_else]
			@ cf
			@ [Label lbl_endif]
		and labels = lb@lf@lt in
		code,labels

	| AWhile (p,c,b) ->
		let lbl_start = get_label fun_name
		and lbl_end = get_label fun_name
		in
		let loops' = (lbl_end,None)::loops in
		let cc,lc = translate_expr stack fun_name c
		and cb,lb = translate_block stack fun_prototype loops' b in
		let code = [Label lbl_start]
			@ cc
			@ [POP AF;_OP_A_i(And,1);JX_cc(false,CC_Z,lbl_end)]
			@ cb
			@ [JX (false,lbl_start); Label lbl_end]
		and labels = lc@lb in
		code,labels

	| ADoWhile (p,b,c) ->
		let lbl_start = get_label fun_name
		and lbl_end = get_label fun_name
		in
		let loops' = (lbl_end,None)::loops in
		let cc,lc = translate_expr stack fun_name c
		and cb,lb = translate_block stack fun_prototype loops' b in
		let code = [Label lbl_start]
			@ cb
			@ cc
			@ [POP AF;_OP_A_i(And,1);JX_cc(false,CC_NZ,lbl_start)]
			@ [Label lbl_end]
		and labels = lc@lb in
		code,labels

	| ARepeat (p,n,b) ->
		let lbl_start = get_label fun_name
		and lbl_end = get_label fun_name
		in
		let loops' = (lbl_end,Some BC)::loops in
		let t = get_type_of_annotated_expr n in
		let load_counter,loop_counter = match t with
		  Byte	-> [POP BC],[DJNZ lbl_start]
		| Word	-> [POP BC],[_DEC16 BC;_LD8(A,B);_OP_A_r(Or,C);JX_cc(true,CC_NZ,lbl_start)]
		| _	-> failwith "unexpected error in repeat"
		in
		let cn,ln = translate_expr stack fun_name n
		and cb,lb = translate_block stack fun_prototype loops' b in
		let code = [PUSH BC]@cn
			@ load_counter
			@ [Label lbl_start]
			@ cb
			@ loop_counter
			@ [POP BC;Label lbl_end]
		and labels = ln@lb in
		code,labels

	| ABreak (p,i) ->
		build_break loops i, []
		
	| AReturn (p,e) ->
		let ce,le = translate_expr stack fun_name e in
		let code = ce
			@ (pop p fun_type)
			@ (build_return loops ("_"^fun_name^"_end"))
		in code,le

and translate_block stack fun_prototype loops block =
	let lcode,llabels = List.split (List.map (translate_instr stack fun_prototype loops) block) in
	List.flatten lcode, List.flatten llabels





let build_stack params nsaved locals =
	let rec loop_locals offset = function
	  []		-> offset,[]
	| (_,(n,t),_)::l->
		let s = size_of_type t in
		let offset',l' = loop_locals (offset+s) l in
		offset',(n,offset) :: l'
	in
	let rec loop_params offset = function
	  []		-> []
	| (_,(n,t))::l	->
		let o = match t with
		  Bool
		| Byte	-> 1
		| _	-> 0
		in
		(n,offset+o) :: (loop_params (offset+2) l) 
	in
	let offset_locals = 0 in
	let offset_saved,locals = loop_locals offset_locals locals in
	let offset_params = offset_saved+2*nsaved in
	let params = loop_params offset_params (List.rev params) in
	offset_saved,locals@params

let local_var_init stack fun_prototype = function
  _,_,b	-> translate_block stack fun_prototype [] b


let translate_fun_decl fun_decl =
	let fun_prototype,(local_decl,code) = fun_decl in
	let fun_name,(_,param_decl) = fun_prototype in

	let has_locals = local_decl<>[] in
	let nsaved = if has_locals then 3 else 2 in

	let var_space,stack = build_stack param_decl nsaved local_decl in

	let lcvars,llvars = List.split (List.map (local_var_init stack fun_prototype) local_decl) in
	let cvars = List.flatten lcvars
	and lvars = List.flatten llvars in

	let code,labels = translate_block stack fun_prototype [] code in

	[Label fun_name]
	@ [PUSH IX]
	@ (if has_locals
	   then [PUSH IY;_LD16_i(IY,0);_ADD16 (IY,SP)]
		@ [_LD16_i(IX,-var_space);_ADD16 (IX,SP);_LD16(SP,IX)]
	   else [_LD16_i(IX,0);_ADD16 (IX,SP)])
	@ cvars
	@ code
	@ [Label ("_"^fun_name^"_end")]
	@ (if has_locals
	   then [_LD16 (SP,IY);POP IY]
	   else [])
	@ [POP IX;RET],
	lvars@labels
