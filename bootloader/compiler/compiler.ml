let counter = ref 0
let local_stack = ref []
let has_locals = ref true

let index_of name =
	let rec loop i = function
		  a::l when a=name -> i
		| _::l -> loop (i+1) l
		| [] -> failwith "not found"
	in
	loop 0 !local_stack

let verb t =
	print_string ("\t"^t^"\n")
	
let ld_hl n =
	print_string "\tld hl,$";
	Printf.printf "%04x\n" n

let ld_de n =
	print_string "\tld de,$";
	Printf.printf "%04x\n" n


let (++) a b s = let s' = a s in b s'

let new_label () =
	incr counter;
	"lbl"^(string_of_int !counter)

let def_label label s =
	print_string (label^":\n");
	s

let dup s =
	verb "push hl";
	s

let swap s =
	verb "ex (sp),hl";
	s

let pushi n s =
	verb "push hl";
	ld_hl n;
	s

let pop s =
	verb "pop hl";
	s

let load_global name s =
	verb "push hl";
	verb ("ld hl,("^name^")");
	s

let store_global name s =
	verb ("ld ("^name^"),hl");
	pop s

let load var s =
	let n = index_of var in
	let _2n = string_of_int (2*n) in
	let _2n1 = string_of_int (2*n+1) in
	verb "push hl";
	verb ("ld l,(ix+"^_2n^")");
	verb ("ld h,(ix+"^_2n1^")");
	s

let store var s =
	let n = index_of var in
	let _2n = string_of_int (2*n) in
	let _2n1 = string_of_int (2*n+1) in
	verb ("ld (ix+"^_2n^"),l");
	verb ("ld (ix+"^_2n1^"),h");
	pop s

let add s =
	verb "ex de,hl";
	verb "pop hl";
	verb "add hl,de";
	s

let sub s =
	verb "ex de,hl";
	verb "pop hl";
	verb "scf";
	verb "sbc hl,de";
	s

let addi n s =
	ld_de n;
	verb "add hl,de";
	s

let subi n s =
	ld_de n;
	verb "add hl,de";
	s

let call name nparams s =
	verb ("call "^name);
	for i=1 to nparams do
		verb "pop de";
	done;
	s

let calln name = call name 0









let begin_function name params locals =
	print_string (name^":\n");
	local_stack := "$ret"::params;
	has_locals := locals=[];
	if !has_locals then
		local_stack := "$ix" :: ((List.map (fun (a,_)->a) locals) @ (!local_stack));
	verb "ld sp,ix";
	List.iter
		(fun (_,v) ->
			begin match v with
				Some n -> ld_de n
				|_ -> ()
			end;
			verb "push de")
		locals

let end_function s =
	assert (s=[]);
	verb "ld sp,ix";
	verb "pop ix";
	verb "ret"

