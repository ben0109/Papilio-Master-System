type link_item =
  GlobalVar of (string*int*string)
| Code of string
| Strings of string

let split s =
	let is_space = function
	  ' '|'\t'|'\n' -> true
	| _ -> false
	in
	let n = String.length s in
	let rec loop_words words i =
		if i>=n 
		then List.rev words
		else if is_space s.[i]
		then loop_words words (i+1)
		else
			let rec loop_char l =
				if i+l>=n or is_space s.[i+l]
				then l
				else loop_char (l+1)
			in
			let len = loop_char 1 in
			let word = String.sub s i len in
			loop_words (word::words) (i+len+1)
	in
	loop_words [] 0

let read_code_lines is = 
	let rec loop is =
	try
		let l = input_line is in
		if l="%end"
		then []
		else l::(loop is)
	with End_of_file ->
		failwith "nonterminated function"
	in
	String.concat "\n" (loop is)

let read_object_file file =
	let rec read_item is =
		let decl = input_line is in
		let tokens = split decl in
		match tokens with
		  [] -> read_item is
		| ["%var";n;s] ->
			let lines = read_code_lines is in
			GlobalVar (n,int_of_string s,lines)
		| ["%code"] -> 
			let lines = read_code_lines is in
			Code lines
		| ["%strings"] -> 
			let lines = read_code_lines is in
			Strings lines
		| _ -> failwith ("syntax error: \""^decl^"\"")
	in
	let rec read_items is =
	try 
		let item = read_item is
		in item::(read_items is)
	with End_of_file ->
		[]
	in
	let is = open_in file in
	let items = read_items is in
	close_in is;
	List.rev items

let read_assembly_file file =
	let rec read_lines is =
		try let l = input_line is in l :: (read_lines is)
		with End_of_file -> []
	in
	let is = open_in file in
	let lines = read_lines is in
	close_in is;
	[Code (String.concat "\n" lines)]

let copy_file file =
	let rec read_lines is = try
		print_endline (input_line is);
		read_lines is
		with End_of_file -> ()
	in
	let is = open_in file in
	read_lines is;
	close_in is





let build_ram_map items =
	let ram_start = 0xc000 in

	let rec parse_items address = function
	  (GlobalVar (name,size,_))	->
		Printf.printf "org $%04x\n%s:\n" address name;
		address+size
	| _ ->
		address
	in
	let ram_end = List.fold_left
		parse_items
		ram_start
		items
	in
	ram_end

let build_global_var_init items =
	let rec parse_item = function
	  GlobalVar (_,_,code)	-> print_string (code^"\n")
	| _			-> ()
	in
	print_string "_global_var_init:\n";
	List.iter parse_item items;
	print_string "\tret\n"

let dump_code items =
	let rec parse_item = function
	  Code code	-> print_string (code^"\n")
	| _		-> ()
	in
	List.iter parse_item items

let dump_strings items =
	let rec parse_item = function
	  Strings code	-> print_string (code^"\n")
	| _		-> ()
	in
	List.iter parse_item items

let link startup_file items =
	ignore (build_ram_map items);
	copy_file startup_file;
	build_global_var_init items;
	dump_code items;
	dump_strings items



let startup_file = ref "startup.asm"

let objects = ref []
let add_object_file f =
	objects := (read_object_file f) :: !objects

let add_assembly_file f =
	objects := (read_assembly_file f) :: !objects

let _ = Arg.parse
		["-i",Arg.String add_assembly_file,"includes an assembly file";
		 "-s",Arg.Set_string startup_file,"sets the startup assembly file"]
		add_object_file
		"generate main assembly file";

	let items = List.flatten (List.rev !objects) in
	link !startup_file items

