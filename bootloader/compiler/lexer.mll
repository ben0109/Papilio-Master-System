{
open Syntax
open Parser
open Lexing

let incr_lineno lexbuf =
	let pos = lexbuf.lex_curr_p in
	lexbuf.lex_curr_p <- { pos with
		pos_lnum = pos.pos_lnum + 1;
		pos_bol = pos.pos_cnum;
	}

let from_hex inum =
	let rec loop v = function
	  i when i=String.length inum -> v
	| i -> let d = match inum.[i] with
		  '0' -> 0
		| '1' -> 1
		| '2' -> 2
		| '3' -> 3
		| '4' -> 4
		| '5' -> 5
		| '6' -> 6
		| '7' -> 7
		| '8' -> 8
		| '9' -> 9
		| 'a' -> 10
		| 'b' -> 11
		| 'c' -> 12
		| 'd' -> 13
		| 'e' -> 14
		| 'f' -> 15
		| 'A' -> 10
		| 'B' -> 11
		| 'C' -> 12
		| 'D' -> 13
		| 'E' -> 14
		| 'F' -> 15
		| _   -> failwith "wrong number"
		in
		loop (v*16 + d) (i+1)
	in loop 0 0
}

let digit = ['0'-'9']
let id = ['a'-'z'] ['a'-'z' '_' '0'-'9']*

rule token = parse
  | "0x"(['0'-'9' 'a'-'f' 'A'-'F']+ as s)
			{ TNum (from_hex s) }
  | digit+ as s		{ TNum (int_of_string s) }
  | '"'([^'"']+ as s)'"'{ TString s }

  | "void"		{ TVoid }
  | "bool"		{ TBool }
  | "byte"		{ TByte }
  | "word"		{ TWord }
  | "true"		{ TTrue }
  | "false"		{ TFalse }

  | "extern"		{ TExtern }
  | "if"		{ TIf }
  | "then"		{ TThen }
  | "else"		{ TElse }
  | "for"		{ TFor }
  | "to"		{ TTo }
  | "do"		{ TDo }
  | "while"		{ TWhile }
  | "repeat"		{ TRepeat }
  | "break"		{ TBreak }
  | "return"		{ TReturn }

  | id as name		{ TName name }
  | "&&"		{ TOpLog LAnd }
  | "||"		{ TOpLog LOr  }

  | "=="		{ TOpComp EQ }
  | "!="		{ TOpComp NE }
  | "<="		{ TOpComp LE }
  | ">="		{ TOpComp GE }
  | "<"			{ TOpComp LT }
  | ">"			{ TOpComp GT }

  | "+"			{ TPlus }
  | "-"			{ TMinus }
  | "&"			{ TAnd }
  | "|"			{ TOr  }
  | "^"			{ TXor }
  | "!"			{ TNot }

  | '('			{ TLPar }
  | ')'			{ TRPar }
  | '['			{ TLBracket }
  | ']'			{ TRBracket }
  | '{'			{ TLBra }
  | '}'			{ TRBra }
  | '*'			{ TStar }
  | '$'			{ TAnd }
  | '='			{ TEqual }
  | ';'			{ TSemiColon }
  | ','			{ TComma }

  | "//" [^ '\n']*	{ token lexbuf }	(* eat up one-line comments *)
  | [' ' '\t']		{ token lexbuf }	(* eat up whitespace *)
  | ['\n']		{ incr_lineno lexbuf; token lexbuf }
  | eof			{ TEof }
  | _ as c		{ failwith ("Unrecognized character: "^(String.make 1 c)) }

{
}

