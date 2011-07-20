OBJECTS = syntax.cmo lexer.cmo parser.cmo typing.cmo assembly.cmo translate.cmo optimize.cmo output.cmo main.cmo


bootstrap.sms: bootstrap.asm bootloader.asm $(depends)
	z80asm -o $@ bootstrap.asm

bootloader.asm: linker bootloader.mco
	./linker bootloader.mco > bootloader.asm

bootloader.mco: compiler bootloader.mc
	./compiler bootloader.mc > bootloader.mco

compiler: $(OBJECTS)
	ocamlc -g -o compiler $(OBJECTS)

linker: linker.ml
	ocamlc -o linker linker.ml

%.cmo: %.ml
	ocamlc -g -c $<

%.cmi: %.mli
	ocamlc -g -c $<

%.ml %.mli: %.mly
	ocamlyacc $<

clean:
	rm *.cmo *.cmi

main.cmo main.cmi: lexer.cmi parser.cmi typing.cmi translate.cmi optimize.cmi output.cmi
typing.cmo typing.cmi: syntax.cmi
assembly.cmo assembly.cmi: syntax.cmi
translate.cmi translate.cmo: syntax.cmi typing.cmi assembly.cmi
optimize.cmo optimize.cmi: assembly.cmi
output.cmo output.cmi: assembly.cmi

parser.cmo: parser.cmi
parser.cmo parser.cmi: syntax.cmi

lexer.ml: lexer.mll parser.cmi
	ocamllex -o $@ $<

