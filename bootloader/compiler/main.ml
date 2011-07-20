(*let channel = stdin*)

let optimize = ref true
let files = ref []

let noopt () = optimize := false
let add_file f = files := f :: !files

let eprint_pos (a,b,c,d) =
	if a=c
	then Printf.eprintf "line %d, %d-%d" a b d
	else Printf.eprintf "line %d,%d to line %d,%d" a b c d

let _ = Arg.parse
	[ ("-noopt",Arg.Unit noopt,"disables post-generation optimizations") ]
	add_file
	"compiles into z80 assembly"

let program =
	let rec loop = function
	  [] -> [],[],[]
	| f::files ->
		let channel = open_in f in
		let lexbuf = Lexing.from_channel channel in
		let p1,d1,v1 = Parser.program Lexer.token lexbuf in
		let p2,d2,v2 = loop files in
		(p1@p2),(d1@d2),(v1@v2)
	in
	loop !files


let process_and_print_code (code,strings) =
	let code  = if !optimize then Optimize.optimize code else code in
	Output.print_code code;
	print_endline "%end";
	print_string "%strings\n";
	Output.print_code strings;
	print_string "%end\n"

let process_var (_,(v,t),i) =
	let stack = [] in
	let prototype = "toplevel",(Syntax.Void,[]) in
	let output = Translate.translate_block stack prototype [] i in
	let s = Translate.size_of_type t in
	Printf.printf "%%var %s %d\n" v s;
	process_and_print_code output

let process_function f =
	let output = Translate.translate_fun_decl f in
	print_string "%code\n";
	print_string (";; "^(Syntax.string_of_prototype (fst f))^"\n");
	process_and_print_code output

let _ =
try
	let function_decls,global_var_decls = Typing.type_check_program program in

	List.iter process_var global_var_decls;
	List.iter process_function function_decls
with Syntax.Type_error (pos,msg) ->
	eprint_pos pos;
	prerr_string ", type error: ";
	prerr_string msg;
	prerr_newline();
	exit(1)

