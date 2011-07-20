open Syntax
open Assembly

let disjoint_reg rr r = match (rr,r) with
  AF,A	-> false
| BC,B	-> false
| BC,C	-> false
| DE,D	-> false
| DE,E	-> false
| HL,H	-> false
| HL,L	-> false
| _	-> true

let disjoint_address rr = function
  Reg8 a	-> disjoint_reg rr a
| Reg16 a	-> rr<>a
| Imm8 _
| Imm16 _
| Address _
| Absolute _
| Indirect _
| Indexed _	-> true

let disjoint_instr rr = function
| SCF
| CCF			-> true

| OP (_,a,b)
| LD (a,b)		-> (disjoint_address rr a) && (disjoint_address rr b)

| RL a
| RLC a
| RR a
| RRC a
| SLA a
| SRA a
| SLL a
| SRL a
| INC a
| DEC a			-> (disjoint_address rr a)

| CPL			-> (disjoint_reg rr A)

| PUSH a
| POP a			-> (rr<>a)

| EX_DE_HL		-> (rr<>DE) && (rr<>HL)

| _			-> false
	
let not = function
  CC_Z	-> CC_NZ
| CC_NZ	-> CC_Z
| CC_C	-> CC_NC
| CC_NC	-> CC_C
| CC_M	-> CC_P
| CC_P	-> CC_M

let rec optimize_pass = function

(* reload stored value *)

| (LD (a,b))::(LD (a',b'))::next when a=b' && a'=b ->
	true,(LD (a,b))::next
(*
| (ST16_i_const (r,c))::(LD16_i_const (r',c'))::next when r=r' && c=c' ->
	true,(ST16_i_const (r,c))::next
*)
(* load + transfer *)

| (LD (Reg8 a,Imm8 i))::(LD (Reg8 b,Reg8 c))::next when a=c->
	true,(LD (Reg8 b,Imm8 i))::next

| (LD (Reg16 a,Imm8 i))::(LD (Reg16 b,Reg16 c))::next when a=c->
	true,(LD (Reg16 b,Imm8 i))::next

| (LD (Reg8 L,Indexed i))::(LD (Reg8 H,Indexed j))::(LD(Reg16 BC,Reg16 HL))::next ->
	true,(LD (Reg8 C,Indexed i))::(LD (Reg8 B,Indexed j))::next

| (LD (Reg16 HL,Imm16 i))::(LD (Indexed l,Reg8 L))::(LD (Indexed h, Reg8 H))::next ->
	true,(LD (Indexed l,Imm8 (i land 0xff)))::(LD (Indexed h,Imm8 (i lsr 8)))::next

(* load l+h *)

| (LD (Reg8 L,Imm8 l))::(LD (Reg8 H,Imm8 h))::next ->
	true,(LD (Reg16 HL,Imm16 ((h*256)+l)))::next

| (LD (Reg8 L,l))::(LD (Reg8 H,h))::EX_DE_HL::next ->
	true,(LD (Reg8 E,l))::(LD (Reg8 D,h))::next

(* load + push/pop *)

| (LD (Reg8 A,n))::(PUSH AF)::(POP HL)::next ->
	true,(LD (Reg8 H,n))::next

| (LD (Reg16 a,n))::(PUSH b)::(POP c)::next when a=b->
	true,(LD (Reg16 c,n))::next

(* ld + store *)

| (LD (Reg16 HL,Address c))::(LD(Reg8 A,Indirect HL))::next ->
	true,(LD(Reg8 A,Absolute c))::next

| (LD (Reg16 HL,Address c))::(LD(Indirect HL,Reg8 A))::next ->
	true,(LD(Absolute c,Reg8 A))::next

| (LD (Reg16 HL,Address c))::(LD(Reg8 E,Indirect HL))::(INC(Reg16 HL))::(LD(Reg8 D,Indirect HL))::EX_DE_HL::next ->
	true,(LD (Reg16 HL,Absolute c))::next

| (LD (Reg16 HL,Address c))::(LD(Indirect HL,Reg8 E))::(INC(Reg16 HL))::(LD(Indirect HL,Reg8 D))::next ->
	true,(LD (Absolute c,Reg16 DE))::next

| EX_DE_HL::(LD (Reg16 HL,Address c))::(LD(Indirect HL,Reg8 E))::(INC(Reg16 HL))::(LD(Indirect HL,Reg8 D))::next ->
	true,(LD (Absolute c,Reg16 HL))::next

(* load const + bin op *)

| (LD (a,Imm8 n))::(OP(op,Reg8 A,b))::next when a==b ->
	true,(OP(op,Reg8 A,Imm8 n))::next

(* immediate jump *)

| (JX (_,l))::(Label l1)::next when l=l1 ->
	true,(Label l1)::next

| (JX (_,l))::(Label l1)::(Label l2)::next when l=l2 ->
	true,(Label l1)::(Label l2)::next

| (JX (_,l))::(Label l1)::(Label l2)::(Label l3)::next when l=l3 ->
	true,(Label l1)::(Label l2)::(Label l3)::next

(* obvious conditional jumps  in while (true) etc. *)

| (LD(Reg8 A,Imm8 i))::(OP(And,Reg8 A,Imm8 1))::(JX_cc (_,CC_NZ,l))::next when (i land 1)=0 ->
	true,next

| (LD(Reg8 A,Imm8 i))::(OP(And,Reg8 A,Imm8 1))::(JX_cc (b,CC_NZ,l))::next when (i land 1)=1 ->
	true,(JX (b,l))::next

| (LD(Reg8 A,Imm8 i))::(OP(And,Reg8 A,Imm8 1))::(JX_cc (_,CC_Z,l))::next when (i land 1)=1 ->
	true,next

| (LD(Reg8 A,Imm8 i))::(OP(And,Reg8 A,Imm8 1))::(JX_cc (b,CC_Z,l))::next when (i land 1)=0 ->
	true,(JX (b,l))::next

(* compute flag + conditional jump *)

| (OP(And,Reg8 A,Imm8 i))::(OP(And,Reg8 A,Reg8 A))::next ->
	true,(OP(And,Reg8 A,Imm8 i))::next

| (PUSH AF)::(POP HL)::(RL (Reg8 L))::(RL (Reg8 L))::(RL (Reg8 A))::(OP(And,Reg8 A,Imm8 1))::(JX_cc(b,CC_Z,l))::next ->
	true,(JX_cc(b,CC_NZ,l))::next

| (PUSH AF)::(POP HL)::(RL (Reg8 L))::(RL (Reg8 L))::CCF::(RL (Reg8 A))::(OP(And,Reg8 A,Imm8 1))::(JX_cc(b,CC_Z,l))::next ->
	true,(JX_cc(b,CC_Z,l))::next

| (PUSH AF)::(POP HL)::(RL (Reg8 L))::(RL (Reg8 L))::(RL (Reg8 A))::(OP(And,Reg8 A,Imm8 1))::(JX_cc(b,CC_NZ,l))::next ->
	true,(JX_cc(b,CC_Z,l))::next

| (PUSH AF)::(POP HL)::(RL (Reg8 L))::(RL (Reg8 L))::CCF::(RL (Reg8 A))::(OP(And,Reg8 A,Imm8 1))::(JX_cc(b,CC_NZ,l))::next ->
	true,(JX_cc(b,CC_NZ,l))::next

| (PUSH AF)::(POP HL)::(LD (Reg8 A,Reg8 L))::(OP(And,Reg8 A, Imm8 1))::(JX_cc(b,CC_NZ,l))::next ->
	true,(JX_cc(b,CC_C,l))::next

| (PUSH AF)::(POP HL)::(LD (Reg8 A,Reg8 L))::(OP(And,Reg8 A, Imm8 1))::(JX_cc(b,CC_Z,l))::next ->
	true,(JX_cc(b,CC_NC,l))::next

| (PUSH AF)::(POP HL)::(LD (Reg8 A,Reg8 L))::CPL::(OP(And,Reg8 A, Imm8 1))::(JX_cc(b,CC_NZ,l))::next ->
	true,(JX_cc(b,CC_NC,l))::next

| (PUSH AF)::(POP HL)::(LD (Reg8 A,Reg8 L))::CPL::(OP(And,Reg8 A, Imm8 1))::(JX_cc(b,CC_Z,l))::next ->
	true,(JX_cc(b,CC_C,l))::next

(* optimize jumps *)

| (JX_cc(_,cc,l))::(JX (b,l'))::(Label l'')::next when l=l'' ->
	true,(JX_cc(b,not cc,l'))::next
| (JX_cc(_,cc,l))::(JX (b,l'))::(Label l'')::next when l=l'' ->
	true,(JX_cc(b,not cc,l'))::next


(* compare with zero *)
(*
| (LD(Reg8 A,Imm8 0))::next ->
	true,(OP(Xor,Reg8 A,Reg8 A))::next
*)
| (OP(Sub,Reg8 A,Imm8 0))::(JX_cc(b,CC_Z,l))::next ->
	true,(OP(And,Reg8 A,Reg8 A))::(JX_cc(b,CC_Z,l))::next

| (OP(Sub,Reg8 A,Imm8 0))::(JX_cc(b,CC_NZ,l))::next ->
	true,(OP(And,Reg8 A,Reg8 A))::(JX_cc(b,CC_NZ,l))::next

(* inc/dec *)

| (OP(Add,a,Imm8 1))::next ->
	true,(INC a)::next

| (OP(Sub,a,Imm8 1))::next ->
	true,(DEC a)::next

| (LD (Reg16 DE,Imm16 1))::OP(Add,Reg16 HL,Reg16 DE)::next ->
	true,(INC (Reg16 HL))::next

| (LD(Reg8 A,i))::(INC (Reg8 A))::LD(j,Reg8 A)::next when i=j ->
	true,(INC i)::next

| (LD(Reg8 A,i))::(DEC (Reg8 A))::LD(j,Reg8 A)::next when i=j ->
	true,(DEC i)::next

(* op with imm *)

| (LD(Reg8 H,Imm8 i))::(OP(op,Reg8 A,Reg8 H))::next ->
	true, (OP(op,Reg8 A,Imm8 i))::next

(* simplify push/pop *)

| (PUSH ra)::(POP rb)::next when ra=rb ->
	true,next

| (POP ra)::(PUSH rb)::next when ra=rb ->
	true,next

| (PUSH HL)::(POP DE)::next ->
	true,EX_DE_HL::next

| (PUSH DE)::(POP HL)::next ->
	true,EX_DE_HL::next

| (PUSH AF)::(POP BC)::next ->
	true,(LD (Reg8 B,Reg8 A))::next

(* move POPs to front when possible i.e. no reordering of stack and no register mess *)

| (POP ra)::(POP rb)::next ->
	let b,next' = optimize_pass ((POP rb)::next) in
	b,((POP ra)::next')

| (PUSH ra)::(POP rb)::next ->
	let b,next' = optimize_pass ((POP rb)::next) in
	b,((PUSH ra)::next')

| i::(POP rr)::next when disjoint_instr rr i ->
	true,(POP rr)::i::next

| [] -> false,[]
| x::l -> let b,l' = optimize_pass l in b,(x::l')

let rec optimize_loop code = 
	let r,code' = optimize_pass code in
	if r
	then optimize_loop code'
	else code'

let optimize code =
	optimize_loop code

