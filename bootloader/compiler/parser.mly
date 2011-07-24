%{
open Syntax
open Lexing

let get_pos() =
	let start_pos = Parsing.symbol_start_pos() in
	let end_pos = Parsing.symbol_end_pos() in
	start_pos.pos_lnum,
	start_pos.pos_cnum-start_pos.pos_bol,
	end_pos.pos_lnum,
	end_pos.pos_cnum-start_pos.pos_bol

let parse_error s =
	let start_pos = Parsing.symbol_start_pos() in
	let lnum = start_pos.pos_lnum
	and cnum = start_pos.pos_cnum-start_pos.pos_bol
	in
	Printf.eprintf "%s around line %d, char %d\n" s lnum cnum
%}

%token TEof
%token<int> TNum
%token<string> TName TString
%token TVoid TBool TByte TWord TTrue TFalse
%token TLPar TRPar TLBra TRBra TLBracket TRBracket
%token TEqual TStar TComma TSemiColon
%token TExtern TIf TThen TElse TFor TTo TDo TWhile TRepeat TBreak TReturn
%token TPlus TMinus TAnd TOr TXor TNot
%token<Syntax.op_log> TOpLog 
%token<Syntax.op_comp> TOpComp 

%left TOpArith TOpLog TOpComp

%start program
%type<Syntax.expr_type>		expr_type
%type<Syntax.expr>		expr
%type<Syntax.instr>		instr
%type<Syntax.block>		block
%type<Syntax.param_decl>	param_decl
%type<Syntax.var_decl>		var_decl
%type<Syntax.fun_prototype>	fun_prototype
%type<Syntax.fun_decl>		fun_decl
%type<Syntax.program>		program

%%

expr_type:
  TVoid						{ Void }
| TBool						{ Bool }
| TByte						{ Byte }
| TWord						{ Word }
| expr_type TStar				{ Pointer $1 }
| expr_type TLBracket TRBracket			{ Array($1,None) }
| expr_type TLBracket TNum TRBracket		{ Array($1,Some $3) }
;


expr:
  TLPar expr TRPar				{ $2 }
| TName						{ Var (get_pos(),$1) }
| TName TLPar expr_list TRPar			{ CallF(get_pos(),$1,$3) }

| TTrue						{ True (get_pos()) }
| TFalse					{ False (get_pos()) }
| expr TOpComp expr				{ OpComp(get_pos(),$2,$1,$3) }
| expr TOpLog expr				{ OpLog(get_pos(),$2,$1,$3) }
| TNot expr					{ OpNot(get_pos(),$2) }

| TNum						{ Const (get_pos(),$1) }
| expr TPlus expr				{ OpArith(get_pos(),Add,$1,$3) }
| expr TMinus expr				{ OpArith(get_pos(),Sub,$1,$3) }
| expr TAnd expr				{ OpArith(get_pos(),And,$1,$3) }
| expr TOr expr					{ OpArith(get_pos(),Or,$1,$3) }
| expr TXor expr				{ OpArith(get_pos(),Xor,$1,$3) }
| TMinus expr					{ OpNeg(get_pos(),$2) }

| TLPar expr_type TStar TRPar TName		{ Absolute(get_pos(),$5,$2) }
| TStar expr					{ Deref (get_pos(),$2) }
| TAnd expr					{ Ref (get_pos(),$2) }
| expr TLBracket expr TRBracket			{ ArrayIndex(get_pos(),$1,$3) }
| TString					{ ConstString (get_pos(),$1) }
;

expr_list:
  /* empty */					{ [] }
| expr_list1					{ List.rev $1 }
;

expr_list1:
  expr						{ [$1] }
| expr_list1 TComma expr			{ $3 :: $1 }
;

instr:
  expr TEqual expr TSemiColon			{ Store(get_pos(),$1,$3) }
| TName TLPar expr_list TRPar TSemiColon	{ CallP(get_pos(),$1,$3) }
| TIf TLPar expr TRPar block TElse block	{ Cond(get_pos(),$3,$5,$7) }
| TIf TLPar expr TRPar block			{ Cond(get_pos(),$3,$5,[]) }
| TWhile TLPar expr TRPar block			{ While(get_pos(),$3,$5) }
| TDo block TWhile TLPar expr TRPar TSemiColon	{ DoWhile(get_pos(),$2,$5) }
| TRepeat TLPar expr TRPar block		{ Repeat(get_pos(),$3,$5) }
| TBreak TNum TSemiColon			{ Break(get_pos(),$2) }
| TBreak TSemiColon				{ Break(get_pos(),1) }
| TReturn expr TSemiColon			{ Return(get_pos(),$2) }
| TReturn TSemiColon				{ let pos = get_pos() in
						  Return(pos,Singleton pos) }
;

instr_list:
  /* empty */					{ [] }
| instr instr_list				{ $1 :: $2 }
;

block:
TLBra instr_list TRBra				{ $2 }
;

param_decl:
  expr_type TName				{ get_pos(),($2,$1) }

param_decl_list:
  /* empty */					{ [] }
| param_decl_list1				{ List.rev $1 }
;

param_decl_list1:
  param_decl					{ [$1] }
| param_decl_list1 TComma param_decl 		{ $3 :: $1 }
;

type_and_name:
expr_type TName					{ $2,$1 }
;

fun_prototype:
type_and_name TLPar param_decl_list TRPar
		{ match $1 with
		  n,t when is_scalar t	-> n,(t,$3)
		| _			-> parse_error "wrong type for a function"; raise Parse_error }
;

var_decl:
  type_and_name TSemiColon			{ get_pos(),$1,None }
| type_and_name TEqual TNum TSemiColon		{ get_pos(),$1,Some $3 }
;

local_var_decl_list:
  /* empty */ 					{ [] }
| local_var_decl_list var_decl			{ $2 :: $1 }
;

fun_body:
TLBra local_var_decl_list instr_list TRBra	{ $2,$3 }
;

fun_decl:
fun_prototype fun_body				{ $1,$2 }
;


program:
  TEof						{ [],[],[] }
| fun_prototype TSemiColon program		{ let p,d,v = $3 in ($1::p),d,v }
| fun_decl program				{ let p,d,v = $2 in p,($1::d),v }
| TExtern type_and_name TSemiColon program	{ let p,d,v = $4 in p,d,(Extern (get_pos(),$2))::v }
| var_decl program				{ let p,d,v = $2 in p,d,(Intern $1)::v }
;

