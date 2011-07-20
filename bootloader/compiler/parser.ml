type token =
  | TEof
  | TNum of (int)
  | TName of (string)
  | TString of (string)
  | TVoid
  | TBool
  | TByte
  | TWord
  | TTrue
  | TFalse
  | TLPar
  | TRPar
  | TLBra
  | TRBra
  | TLBracket
  | TRBracket
  | TEqual
  | TStar
  | TComma
  | TSemiColon
  | TExtern
  | TIf
  | TThen
  | TElse
  | TFor
  | TTo
  | TDo
  | TWhile
  | TRepeat
  | TBreak
  | TReturn
  | TPlus
  | TMinus
  | TAnd
  | TOr
  | TXor
  | TNot
  | TOpLog of (Syntax.op_log)
  | TOpComp of (Syntax.op_comp)

open Parsing;;
# 2 "parser.mly"
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
# 62 "parser.ml"
let yytransl_const = [|
  257 (* TEof *);
  261 (* TVoid *);
  262 (* TBool *);
  263 (* TByte *);
  264 (* TWord *);
  265 (* TTrue *);
  266 (* TFalse *);
  267 (* TLPar *);
  268 (* TRPar *);
  269 (* TLBra *);
  270 (* TRBra *);
  271 (* TLBracket *);
  272 (* TRBracket *);
  273 (* TEqual *);
  274 (* TStar *);
  275 (* TComma *);
  276 (* TSemiColon *);
  277 (* TExtern *);
  278 (* TIf *);
  279 (* TThen *);
  280 (* TElse *);
  281 (* TFor *);
  282 (* TTo *);
  283 (* TDo *);
  284 (* TWhile *);
  285 (* TRepeat *);
  286 (* TBreak *);
  287 (* TReturn *);
  288 (* TPlus *);
  289 (* TMinus *);
  290 (* TAnd *);
  291 (* TOr *);
  292 (* TXor *);
  293 (* TNot *);
    0|]

let yytransl_block = [|
  258 (* TNum *);
  259 (* TName *);
  260 (* TString *);
  294 (* TOpLog *);
  295 (* TOpComp *);
    0|]

let yylhs = "\255\255\
\002\000\002\000\002\000\002\000\002\000\002\000\002\000\003\000\
\003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
\003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
\003\000\003\000\003\000\010\000\010\000\011\000\011\000\004\000\
\004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
\004\000\004\000\012\000\012\000\005\000\006\000\013\000\013\000\
\014\000\014\000\015\000\008\000\007\000\007\000\016\000\016\000\
\017\000\009\000\001\000\001\000\001\000\001\000\001\000\000\000"

let yylen = "\002\000\
\001\000\001\000\001\000\001\000\002\000\003\000\004\000\003\000\
\001\000\004\000\001\000\001\000\003\000\003\000\002\000\001\000\
\003\000\003\000\003\000\003\000\003\000\002\000\005\000\002\000\
\002\000\004\000\001\000\000\000\001\000\001\000\003\000\004\000\
\005\000\007\000\005\000\005\000\007\000\005\000\003\000\002\000\
\003\000\002\000\000\000\002\000\003\000\002\000\000\000\001\000\
\001\000\003\000\002\000\004\000\002\000\004\000\000\000\002\000\
\004\000\002\000\001\000\003\000\002\000\004\000\002\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\059\000\001\000\002\000\003\000\004\000\000\000\
\064\000\000\000\000\000\000\000\000\000\000\000\000\000\051\000\
\000\000\005\000\063\000\055\000\000\000\058\000\061\000\000\000\
\000\000\053\000\000\000\000\000\006\000\000\000\060\000\000\000\
\049\000\000\000\000\000\000\000\062\000\007\000\016\000\000\000\
\027\000\011\000\012\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\056\000\000\000\000\000\046\000\052\000\000\000\054\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\040\000\042\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\044\000\057\000\050\000\000\000\000\000\000\000\000\000\
\000\000\008\000\000\000\000\000\000\000\000\000\000\000\039\000\
\041\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\045\000\
\000\000\000\000\000\000\026\000\032\000\033\000\000\000\010\000\
\023\000\000\000\000\000\036\000\038\000\000\000\000\000\034\000\
\037\000"

let yydgoto = "\002\000\
\009\000\010\000\055\000\056\000\071\000\033\000\011\000\012\000\
\013\000\094\000\095\000\058\000\034\000\035\000\014\000\030\000\
\022\000"

let yysindex = "\013\000\
\131\000\000\000\000\000\000\000\000\000\000\000\000\000\193\255\
\000\000\084\255\131\000\248\254\131\000\006\255\007\255\000\000\
\002\255\000\000\000\000\000\000\131\000\000\000\000\000\193\255\
\044\255\000\000\131\000\034\255\000\000\051\255\000\000\179\255\
\000\000\039\255\055\255\043\255\000\000\000\000\000\000\082\255\
\000\000\000\000\000\000\159\255\205\255\083\255\062\255\089\255\
\093\255\001\255\169\255\205\255\205\255\205\255\049\000\123\255\
\000\000\072\255\075\255\000\000\000\000\193\255\000\000\205\255\
\095\255\004\255\222\255\104\255\205\255\123\255\085\255\205\255\
\205\255\092\255\000\000\000\000\057\000\104\255\104\255\104\255\
\205\255\205\255\205\255\205\255\205\255\205\255\205\255\205\255\
\205\255\000\000\000\000\000\000\104\255\110\255\116\255\205\255\
\111\255\000\000\238\255\132\255\138\255\247\255\007\000\000\000\
\000\000\032\255\079\000\104\255\104\255\104\255\104\255\104\255\
\000\255\000\255\135\255\205\255\146\255\172\255\062\255\000\000\
\205\255\062\255\062\255\000\000\000\000\000\000\104\255\000\000\
\000\000\157\255\016\000\000\000\000\000\062\255\163\255\000\000\
\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\173\255\
\000\000\000\000\000\000\000\000\000\000\174\255\000\000\000\000\
\000\000\000\000\183\255\000\000\000\000\000\000\000\000\087\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\174\255\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\192\255\
\213\255\000\000\000\000\201\255\000\000\174\255\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\224\255\051\000\089\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\250\254\000\000\198\255\192\255\
\113\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\137\000\143\000\149\000\155\000\161\000\
\091\255\041\000\112\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\064\255\000\000\
\000\000\087\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000"

let yygindex = "\000\000\
\163\000\243\255\212\255\000\000\025\000\124\000\175\000\000\000\
\000\000\095\000\000\000\216\255\000\000\000\000\250\255\000\000\
\000\000"

let yytablesize = 437
let yytable = "\067\000\
\068\000\015\000\074\000\028\000\020\000\030\000\077\000\078\000\
\079\000\080\000\032\000\021\000\030\000\001\000\081\000\090\000\
\024\000\029\000\017\000\093\000\075\000\097\000\025\000\059\000\
\099\000\026\000\027\000\102\000\103\000\100\000\066\000\083\000\
\084\000\085\000\086\000\087\000\106\000\107\000\108\000\109\000\
\110\000\111\000\112\000\113\000\114\000\036\000\081\000\124\000\
\032\000\038\000\061\000\093\000\039\000\040\000\041\000\004\000\
\005\000\006\000\007\000\042\000\043\000\044\000\063\000\083\000\
\084\000\085\000\086\000\087\000\045\000\088\000\089\000\127\000\
\046\000\062\000\070\000\031\000\131\000\047\000\048\000\049\000\
\050\000\051\000\031\000\052\000\053\000\091\000\016\000\054\000\
\035\000\035\000\035\000\025\000\064\000\069\000\026\000\035\000\
\035\000\035\000\017\000\072\000\035\000\018\000\014\000\073\000\
\035\000\096\000\014\000\014\000\035\000\014\000\014\000\104\000\
\101\000\035\000\035\000\035\000\035\000\035\000\081\000\035\000\
\035\000\115\000\118\000\035\000\039\000\040\000\041\000\005\000\
\014\000\014\000\005\000\042\000\043\000\044\000\116\000\083\000\
\084\000\085\000\086\000\087\000\045\000\088\000\089\000\130\000\
\046\000\120\000\132\000\133\000\121\000\047\000\048\000\049\000\
\050\000\051\000\126\000\052\000\053\000\128\000\136\000\054\000\
\039\000\065\000\041\000\004\000\005\000\006\000\007\000\042\000\
\043\000\044\000\039\000\065\000\041\000\019\000\129\000\023\000\
\045\000\042\000\043\000\044\000\134\000\060\000\137\000\031\000\
\047\000\092\000\045\000\043\000\076\000\037\000\117\000\052\000\
\053\000\017\000\048\000\054\000\018\000\004\000\005\000\006\000\
\007\000\052\000\053\000\028\000\057\000\054\000\039\000\065\000\
\041\000\029\000\000\000\000\000\024\000\042\000\043\000\044\000\
\024\000\024\000\000\000\024\000\024\000\000\000\045\000\000\000\
\009\000\000\000\000\000\009\000\009\000\009\000\000\000\009\000\
\009\000\098\000\000\000\022\000\081\000\052\000\053\000\022\000\
\022\000\054\000\022\000\022\000\009\000\009\000\009\000\009\000\
\009\000\119\000\009\000\009\000\081\000\083\000\084\000\085\000\
\086\000\087\000\122\000\088\000\089\000\081\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\083\000\084\000\085\000\
\086\000\087\000\123\000\088\000\089\000\081\000\083\000\084\000\
\085\000\086\000\087\000\135\000\088\000\089\000\081\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\083\000\084\000\
\085\000\086\000\087\000\000\000\088\000\089\000\000\000\083\000\
\084\000\085\000\086\000\087\000\013\000\088\000\089\000\000\000\
\013\000\013\000\000\000\013\000\013\000\000\000\025\000\081\000\
\000\000\082\000\025\000\025\000\000\000\025\000\025\000\081\000\
\000\000\000\000\000\000\000\000\105\000\000\000\013\000\013\000\
\083\000\084\000\085\000\086\000\087\000\000\000\088\000\089\000\
\083\000\084\000\085\000\086\000\087\000\081\000\088\000\089\000\
\000\000\000\000\125\000\000\000\015\000\009\000\000\000\009\000\
\015\000\015\000\000\000\015\000\015\000\000\000\083\000\084\000\
\085\000\086\000\087\000\000\000\088\000\089\000\009\000\009\000\
\009\000\009\000\009\000\000\000\009\000\009\000\010\000\000\000\
\010\000\000\000\000\000\003\000\000\000\000\000\000\000\004\000\
\005\000\006\000\007\000\000\000\000\000\000\000\000\000\010\000\
\010\000\010\000\010\000\010\000\017\000\010\000\010\000\008\000\
\017\000\017\000\018\000\017\000\017\000\000\000\018\000\018\000\
\019\000\018\000\018\000\000\000\019\000\019\000\020\000\019\000\
\019\000\000\000\020\000\020\000\021\000\020\000\020\000\000\000\
\021\000\021\000\000\000\021\000\021\000"

let yycheck = "\044\000\
\045\000\008\000\002\001\002\001\013\001\012\001\051\000\052\000\
\053\000\054\000\024\000\020\001\019\001\001\000\015\001\056\000\
\011\001\016\001\015\001\064\000\020\001\018\001\017\001\030\000\
\069\000\020\001\020\001\072\000\073\000\070\000\044\000\032\001\
\033\001\034\001\035\001\036\001\081\000\082\000\083\000\084\000\
\085\000\086\000\087\000\088\000\089\000\002\001\015\001\016\001\
\062\000\016\001\012\001\096\000\002\001\003\001\004\001\005\001\
\006\001\007\001\008\001\009\001\010\001\011\001\020\001\032\001\
\033\001\034\001\035\001\036\001\018\001\038\001\039\001\116\000\
\022\001\019\001\013\001\012\001\121\000\027\001\028\001\029\001\
\030\001\031\001\019\001\033\001\034\001\014\001\003\001\037\001\
\002\001\003\001\004\001\017\001\011\001\011\001\020\001\009\001\
\010\001\011\001\015\001\011\001\014\001\018\001\012\001\011\001\
\018\001\011\001\016\001\017\001\022\001\019\001\020\001\020\001\
\028\001\027\001\028\001\029\001\030\001\031\001\015\001\033\001\
\034\001\012\001\012\001\037\001\002\001\003\001\004\001\015\001\
\038\001\039\001\018\001\009\001\010\001\011\001\019\001\032\001\
\033\001\034\001\035\001\036\001\018\001\038\001\039\001\119\000\
\022\001\014\001\122\000\123\000\011\001\027\001\028\001\029\001\
\030\001\031\001\020\001\033\001\034\001\012\001\134\000\037\001\
\002\001\003\001\004\001\005\001\006\001\007\001\008\001\009\001\
\010\001\011\001\002\001\003\001\004\001\011\000\003\001\013\000\
\018\001\009\001\010\001\011\001\024\001\003\001\020\001\021\000\
\012\001\062\000\018\001\014\001\020\001\027\000\096\000\033\001\
\034\001\015\001\012\001\037\001\018\001\005\001\006\001\007\001\
\008\001\033\001\034\001\012\001\030\000\037\001\002\001\003\001\
\004\001\012\001\255\255\255\255\012\001\009\001\010\001\011\001\
\016\001\017\001\255\255\019\001\020\001\255\255\018\001\255\255\
\012\001\255\255\255\255\015\001\016\001\017\001\255\255\019\001\
\020\001\012\001\255\255\012\001\015\001\033\001\034\001\016\001\
\017\001\037\001\019\001\020\001\032\001\033\001\034\001\035\001\
\036\001\012\001\038\001\039\001\015\001\032\001\033\001\034\001\
\035\001\036\001\012\001\038\001\039\001\015\001\255\255\255\255\
\255\255\255\255\255\255\255\255\255\255\032\001\033\001\034\001\
\035\001\036\001\012\001\038\001\039\001\015\001\032\001\033\001\
\034\001\035\001\036\001\012\001\038\001\039\001\015\001\255\255\
\255\255\255\255\255\255\255\255\255\255\255\255\032\001\033\001\
\034\001\035\001\036\001\255\255\038\001\039\001\255\255\032\001\
\033\001\034\001\035\001\036\001\012\001\038\001\039\001\255\255\
\016\001\017\001\255\255\019\001\020\001\255\255\012\001\015\001\
\255\255\017\001\016\001\017\001\255\255\019\001\020\001\015\001\
\255\255\255\255\255\255\255\255\020\001\255\255\038\001\039\001\
\032\001\033\001\034\001\035\001\036\001\255\255\038\001\039\001\
\032\001\033\001\034\001\035\001\036\001\015\001\038\001\039\001\
\255\255\255\255\020\001\255\255\012\001\015\001\255\255\017\001\
\016\001\017\001\255\255\019\001\020\001\255\255\032\001\033\001\
\034\001\035\001\036\001\255\255\038\001\039\001\032\001\033\001\
\034\001\035\001\036\001\255\255\038\001\039\001\015\001\255\255\
\017\001\255\255\255\255\001\001\255\255\255\255\255\255\005\001\
\006\001\007\001\008\001\255\255\255\255\255\255\255\255\032\001\
\033\001\034\001\035\001\036\001\012\001\038\001\039\001\021\001\
\016\001\017\001\012\001\019\001\020\001\255\255\016\001\017\001\
\012\001\019\001\020\001\255\255\016\001\017\001\012\001\019\001\
\020\001\255\255\016\001\017\001\012\001\019\001\020\001\255\255\
\016\001\017\001\255\255\019\001\020\001"

let yynames_const = "\
  TEof\000\
  TVoid\000\
  TBool\000\
  TByte\000\
  TWord\000\
  TTrue\000\
  TFalse\000\
  TLPar\000\
  TRPar\000\
  TLBra\000\
  TRBra\000\
  TLBracket\000\
  TRBracket\000\
  TEqual\000\
  TStar\000\
  TComma\000\
  TSemiColon\000\
  TExtern\000\
  TIf\000\
  TThen\000\
  TElse\000\
  TFor\000\
  TTo\000\
  TDo\000\
  TWhile\000\
  TRepeat\000\
  TBreak\000\
  TReturn\000\
  TPlus\000\
  TMinus\000\
  TAnd\000\
  TOr\000\
  TXor\000\
  TNot\000\
  "

let yynames_block = "\
  TNum\000\
  TName\000\
  TString\000\
  TOpLog\000\
  TOpComp\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    Obj.repr(
# 48 "parser.mly"
             ( Void )
# 364 "parser.ml"
               : Syntax.expr_type))
; (fun __caml_parser_env ->
    Obj.repr(
# 49 "parser.mly"
             ( Bool )
# 370 "parser.ml"
               : Syntax.expr_type))
; (fun __caml_parser_env ->
    Obj.repr(
# 50 "parser.mly"
             ( Byte )
# 376 "parser.ml"
               : Syntax.expr_type))
; (fun __caml_parser_env ->
    Obj.repr(
# 51 "parser.mly"
             ( Word )
# 382 "parser.ml"
               : Syntax.expr_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Syntax.expr_type) in
    Obj.repr(
# 52 "parser.mly"
                     ( Pointer _1 )
# 389 "parser.ml"
               : Syntax.expr_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Syntax.expr_type) in
    Obj.repr(
# 53 "parser.mly"
                                  ( Array(_1,None) )
# 396 "parser.ml"
               : Syntax.expr_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Syntax.expr_type) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : int) in
    Obj.repr(
# 54 "parser.mly"
                                      ( Array(_1,Some _3) )
# 404 "parser.ml"
               : Syntax.expr_type))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Syntax.expr) in
    Obj.repr(
# 59 "parser.mly"
                      ( _2 )
# 411 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 60 "parser.mly"
             ( Var (get_pos(),_1) )
# 418 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'expr_list) in
    Obj.repr(
# 61 "parser.mly"
                                ( CallF(get_pos(),_1,_3) )
# 426 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 63 "parser.mly"
             ( True (get_pos()) )
# 432 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 64 "parser.mly"
             ( False (get_pos()) )
# 438 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Syntax.expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Syntax.op_comp) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 65 "parser.mly"
                       ( OpComp(get_pos(),_2,_1,_3) )
# 447 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Syntax.expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Syntax.op_log) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 66 "parser.mly"
                      ( OpLog(get_pos(),_2,_1,_3) )
# 456 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 67 "parser.mly"
                ( OpNot(get_pos(),_2) )
# 463 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 69 "parser.mly"
            ( Const (get_pos(),_1) )
# 470 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Syntax.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 70 "parser.mly"
                     ( OpArith(get_pos(),Add,_1,_3) )
# 478 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Syntax.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 71 "parser.mly"
                      ( OpArith(get_pos(),Sub,_1,_3) )
# 486 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Syntax.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 72 "parser.mly"
                    ( OpArith(get_pos(),And,_1,_3) )
# 494 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Syntax.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 73 "parser.mly"
                    ( OpArith(get_pos(),Or,_1,_3) )
# 502 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Syntax.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 74 "parser.mly"
                    ( OpArith(get_pos(),Xor,_1,_3) )
# 510 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 75 "parser.mly"
                  ( OpNeg(get_pos(),_2) )
# 517 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : Syntax.expr_type) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 77 "parser.mly"
                                     ( Absolute(get_pos(),_5,_2) )
# 525 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 78 "parser.mly"
                 ( Deref (get_pos(),_2) )
# 532 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 79 "parser.mly"
                ( Ref (get_pos(),_2) )
# 539 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Syntax.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : Syntax.expr) in
    Obj.repr(
# 80 "parser.mly"
                                  ( ArrayIndex(get_pos(),_1,_3) )
# 547 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 81 "parser.mly"
              ( ConstString (get_pos(),_1) )
# 554 "parser.ml"
               : Syntax.expr))
; (fun __caml_parser_env ->
    Obj.repr(
# 85 "parser.mly"
                  ( [] )
# 560 "parser.ml"
               : 'expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr_list1) in
    Obj.repr(
# 86 "parser.mly"
                 ( List.rev _1 )
# 567 "parser.ml"
               : 'expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 90 "parser.mly"
            ( [_1] )
# 574 "parser.ml"
               : 'expr_list1))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr_list1) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Syntax.expr) in
    Obj.repr(
# 91 "parser.mly"
                           ( _3 :: _1 )
# 582 "parser.ml"
               : 'expr_list1))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : Syntax.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : Syntax.expr) in
    Obj.repr(
# 95 "parser.mly"
                                ( Store(get_pos(),_1,_3) )
# 590 "parser.ml"
               : Syntax.instr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'expr_list) in
    Obj.repr(
# 96 "parser.mly"
                                         ( CallP(get_pos(),_1,_3) )
# 598 "parser.ml"
               : Syntax.instr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 4 : Syntax.expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : Syntax.block) in
    let _7 = (Parsing.peek_val __caml_parser_env 0 : Syntax.block) in
    Obj.repr(
# 97 "parser.mly"
                                         ( Cond(get_pos(),_3,_5,_7) )
# 607 "parser.ml"
               : Syntax.instr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : Syntax.expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : Syntax.block) in
    Obj.repr(
# 98 "parser.mly"
                               ( Cond(get_pos(),_3,_5,[]) )
# 615 "parser.ml"
               : Syntax.instr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : Syntax.expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : Syntax.block) in
    Obj.repr(
# 99 "parser.mly"
                                  ( While(get_pos(),_3,_5) )
# 623 "parser.ml"
               : Syntax.instr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : Syntax.block) in
    let _5 = (Parsing.peek_val __caml_parser_env 2 : Syntax.expr) in
    Obj.repr(
# 100 "parser.mly"
                                               ( DoWhile(get_pos(),_2,_5) )
# 631 "parser.ml"
               : Syntax.instr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 2 : Syntax.expr) in
    let _5 = (Parsing.peek_val __caml_parser_env 0 : Syntax.block) in
    Obj.repr(
# 101 "parser.mly"
                                  ( Repeat(get_pos(),_3,_5) )
# 639 "parser.ml"
               : Syntax.instr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : int) in
    Obj.repr(
# 102 "parser.mly"
                           ( Break(get_pos(),_2) )
# 646 "parser.ml"
               : Syntax.instr))
; (fun __caml_parser_env ->
    Obj.repr(
# 103 "parser.mly"
                       ( Break(get_pos(),1) )
# 652 "parser.ml"
               : Syntax.instr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Syntax.expr) in
    Obj.repr(
# 104 "parser.mly"
                            ( Return(get_pos(),_2) )
# 659 "parser.ml"
               : Syntax.instr))
; (fun __caml_parser_env ->
    Obj.repr(
# 105 "parser.mly"
                        ( let pos = get_pos() in
						  Return(pos,Singleton pos) )
# 666 "parser.ml"
               : Syntax.instr))
; (fun __caml_parser_env ->
    Obj.repr(
# 110 "parser.mly"
                  ( [] )
# 672 "parser.ml"
               : 'instr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Syntax.instr) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'instr_list) in
    Obj.repr(
# 111 "parser.mly"
                      ( _1 :: _2 )
# 680 "parser.ml"
               : 'instr_list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'instr_list) in
    Obj.repr(
# 115 "parser.mly"
                          ( _2 )
# 687 "parser.ml"
               : Syntax.block))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Syntax.expr_type) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 119 "parser.mly"
                     ( get_pos(),(_2,_1) )
# 695 "parser.ml"
               : Syntax.param_decl))
; (fun __caml_parser_env ->
    Obj.repr(
# 122 "parser.mly"
                  ( [] )
# 701 "parser.ml"
               : 'param_decl_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'param_decl_list1) in
    Obj.repr(
# 123 "parser.mly"
                      ( List.rev _1 )
# 708 "parser.ml"
               : 'param_decl_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Syntax.param_decl) in
    Obj.repr(
# 127 "parser.mly"
                 ( [_1] )
# 715 "parser.ml"
               : 'param_decl_list1))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'param_decl_list1) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Syntax.param_decl) in
    Obj.repr(
# 128 "parser.mly"
                                       ( _3 :: _1 )
# 723 "parser.ml"
               : 'param_decl_list1))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Syntax.expr_type) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 132 "parser.mly"
                    ( _2,_1 )
# 731 "parser.ml"
               : 'type_and_name))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'type_and_name) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'param_decl_list) in
    Obj.repr(
# 137 "parser.mly"
  ( match _1 with
		  n,t when is_scalar t	-> n,(t,_3)
		| _			-> parse_error "wrong type for a function"; raise Parse_error )
# 741 "parser.ml"
               : Syntax.fun_prototype))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'type_and_name) in
    Obj.repr(
# 143 "parser.mly"
                             ( get_pos(),_1,None )
# 748 "parser.ml"
               : Syntax.var_decl))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'type_and_name) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : int) in
    Obj.repr(
# 144 "parser.mly"
                                        ( get_pos(),_1,Some _3 )
# 756 "parser.ml"
               : Syntax.var_decl))
; (fun __caml_parser_env ->
    Obj.repr(
# 148 "parser.mly"
                   ( [] )
# 762 "parser.ml"
               : 'local_var_decl_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'local_var_decl_list) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Syntax.var_decl) in
    Obj.repr(
# 149 "parser.mly"
                                 ( _2 :: _1 )
# 770 "parser.ml"
               : 'local_var_decl_list))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'local_var_decl_list) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'instr_list) in
    Obj.repr(
# 153 "parser.mly"
                                           ( _2,_3 )
# 778 "parser.ml"
               : 'fun_body))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Syntax.fun_prototype) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'fun_body) in
    Obj.repr(
# 157 "parser.mly"
                          ( _1,_2 )
# 786 "parser.ml"
               : Syntax.fun_decl))
; (fun __caml_parser_env ->
    Obj.repr(
# 162 "parser.mly"
            ( [],[],[] )
# 792 "parser.ml"
               : Syntax.program))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Syntax.fun_prototype) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Syntax.program) in
    Obj.repr(
# 163 "parser.mly"
                                    ( let p,d,v = _3 in (_1::p),d,v )
# 800 "parser.ml"
               : Syntax.program))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Syntax.fun_decl) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Syntax.program) in
    Obj.repr(
# 164 "parser.mly"
                      ( let p,d,v = _2 in p,(_1::d),v )
# 808 "parser.ml"
               : Syntax.program))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'type_and_name) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : Syntax.program) in
    Obj.repr(
# 165 "parser.mly"
                                           ( let p,d,v = _4 in p,d,(Extern (get_pos(),_2))::v )
# 816 "parser.ml"
               : Syntax.program))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Syntax.var_decl) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Syntax.program) in
    Obj.repr(
# 166 "parser.mly"
                      ( let p,d,v = _2 in p,d,(Intern _1)::v )
# 824 "parser.ml"
               : Syntax.program))
(* Entry program *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let program (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Syntax.program)
