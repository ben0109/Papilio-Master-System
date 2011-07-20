open Syntax

type reg8 = A|B|C|D|E|H|L
type reg16 = AF|BC|DE|HL|SP|IX|IY
type cc = CC_Z|CC_NZ|CC_C|CC_NC|CC_P|CC_M

type address =
  Reg8 of reg8
| Reg16 of reg16
| Imm8 of int
| Imm16 of int
| Address of string
| Indirect of reg16
| Absolute of string
| Indexed of int

type z80_instr =
	  Label of string
	| DB_string of string

	| LD of address*address

	| OP of op_binary*address*address
	| RL of address
	| RLC of address
	| RR of address
	| RRC of address
	| SLA of address
	| SRA of address
	| SLL of address
	| SRL of address
	| NEG
	| CPL

	| INC of address
	| DEC of address

	| EX_DE_HL
	| PUSH of reg16
	| POP of reg16

	| SCF | CCF
	| CALL of string
	| RET
	| DJNZ of string
	| JX of bool*string
	| JX_cc of bool*cc*string


let _LD8 (a,b) = LD (Reg8 a,Reg8 b)
let _LD8_i (a,i) = LD (Reg8 a,Imm8 i)
let _LD8_IX (a,i) = LD (Reg8 a,Indexed i)
let _ST8_IX (a,i) = LD (Indexed i,Reg8 a)
let _ST8_IX_i (i,j) = LD (Indexed i,Imm8 j)
let _LD8_HL a = LD (Reg8 a,Indirect HL)
let _ST8_HL a = LD (Indirect HL,Reg8 a)
let _LD_A_i_const s = LD (Reg8 A,Absolute s)
let _ST_A_i_const s = LD (Absolute s,Reg8 A)

let _LD16 (a,b) = LD (Reg16 a,Reg16 b)
let _LD16_i (a,i) = LD (Reg16 a,Imm16 i)
let _LD16_const (a,s) = LD (Reg16 a,Address s)
let _LD16_i_const (a,s) = LD (Reg16 a,Absolute s)
let _ST16_i_const (a,s) = LD (Absolute s,Reg16 a)

let _OP_A_i (op,i)	= OP(op,Reg8 A,Imm8 i)
let _OP_A_r (op,b)	= OP(op,Reg8 A,Reg8 b)
let _RL a	= RL  (Reg8 a)
let _RLC a	= RLC (Reg8 a)
let _RR a	= RR  (Reg8 a)
let _RRC a	= RRC (Reg8 a)
let _SLA a	= SLA (Reg8 a)
let _SRA a	= SRA (Reg8 a)
let _SLL a	= SLL (Reg8 a)
let _SRL a	= SRL (Reg8 a)
let _ADD_HL_DE	= OP(Add,Reg16 HL,Reg16 DE)
let _SBC_HL_DE	= OP(Sbc,Reg16 HL,Reg16 DE)
let _ADD16 (a,b)= OP(Add,Reg16 a,Reg16 b)

let _INC8 a	= INC(Reg8 a)
let _INC16 a	= INC(Reg16 a)
let _INC8_IX i	= INC(Indexed i)
let _DEC8 a	= DEC(Reg8 a)
let _DEC16 a	= DEC(Reg16 a)
let _DEC8_IX i	= DEC(Indexed i)

