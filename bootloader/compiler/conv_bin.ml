let label = ref "binary"
let inc = ref false

let incbin file =
	print_string ("\nincbin \""^file^"\"\n")

let dump file =
	let is = open_in_bin file in
	let rec loop i =
	try
		let b = input_byte is in
		if (i mod 16)=0
		then print_string "\ndb "
		else print_string ",";
		Printf.printf "$%02x" b;
		loop (i+1)
	with End_of_file -> print_string "\n"
	in
	loop 0;
	close_in is	

let conv file =
	print_string "%code\n";
	print_string (!label^":");
	if !inc
	then incbin file
	else dump file;
	print_string "%end\n"

let _ =	Arg.parse
	[("-l",Arg.Set_string label,"sets the label name");
	 ("-i",Arg.Bool (fun s->inc:=s),"if true, use incbin")]
	conv
	"converts a binary file to an object file"

