open Syntax
open Assembly





let string_of_op_arith = function
  Add -> "add"
| Sub -> "sub"
| And -> "and"
| Or  -> "or "
| Xor -> "xor"
| Adc -> "adc"
| Sbc -> "sbc"

let string_of_reg8 = function
  A -> "a"
| B -> "b"
| C -> "c"
| D -> "d"
| E -> "e"
| H -> "h"
| L -> "l"

let string_of_reg16 = function
  AF -> "af"
| BC -> "bc"
| DE -> "de"
| HL -> "hl"
| SP -> "sp"
| IX -> "ix"
| IY -> "iy"

let string_of_address = function
  Reg8 a	-> string_of_reg8 a
| Reg16 a	-> string_of_reg16 a
| Imm8 i	-> Printf.sprintf "$%02x" (i land 0xff)
| Imm16 i	-> Printf.sprintf "$%04x" (i land 0xffff)
| Address s	-> s
| Absolute s	-> "("^s^")"
| Indirect a	-> "("^(string_of_reg16 a)^")"
| Indexed i	-> Printf.sprintf "(ix+$%02x)" i

let string_of_cc = function
  CC_Z  -> "z"
| CC_NZ -> "nz"
| CC_C  -> "c"
| CC_NC -> "nc"
| CC_P  -> "p"
| CC_M  -> "m"

let print_z80_instr i =
ignore (
	match i with
	  Label l		-> Printf.printf "%s:" l
	| DB_string s		-> Printf.printf "\tdb \"%s\",0" s
	| LD (a,b)		-> Printf.printf "\tld %s,%s" (string_of_address a)(string_of_address b)

	| OP (op,Reg8 A,b)	-> Printf.printf "\t%s %s" (string_of_op_arith op) (string_of_address b)
	| OP (op,a,b)		-> Printf.printf "\t%s %s,%s" (string_of_op_arith op) (string_of_address a) (string_of_address b)
	| RL r			-> Printf.printf "\trl %s" (string_of_address r)
	| RLC r			-> Printf.printf "\trlc %s" (string_of_address r)
	| RR r			-> Printf.printf "\trr %s" (string_of_address r)
	| RRC r			-> Printf.printf "\trrc %s" (string_of_address r)
	| SLA r			-> Printf.printf "\tsla %s" (string_of_address r)
	| SRA r			-> Printf.printf "\tsra %s" (string_of_address r)
	| SLL r			-> Printf.printf "\tsll %s" (string_of_address r)
	| SRL r			-> Printf.printf "\tsrl %s" (string_of_address r)
	| CPL			-> Printf.printf "\tcpl"

	| INC r			-> Printf.printf "\tinc %s" (string_of_address r)
	| DEC r			-> Printf.printf "\tdec %s" (string_of_address r)

	| EX_DE_HL		-> print_string "\tex de,hl"
	| PUSH rr		-> Printf.printf "\tpush %s" (string_of_reg16 rr)
	| POP rr		-> Printf.printf "\tpop %s" (string_of_reg16 rr)
	| SCF			-> print_string "\tscf"
	| CCF			-> print_string "\tccf"
	| CALL name		-> Printf.printf "\tcall %s" name
	| RET			-> print_string "\tret"
	| DJNZ l		-> Printf.printf "\tdjnz %s" l
	| JX (true,l)		-> Printf.printf "\tjr %s" l
	| JX_cc (true,cc,l)	-> Printf.printf "\tjr %s,%s" (string_of_cc cc) l
	| JX (false,l)		-> Printf.printf "\tjp %s" l
	| JX_cc (false,cc,l)	-> Printf.printf "\tjp %s,%s" (string_of_cc cc) l
);
print_newline()

let print_code = List.iter print_z80_instr
