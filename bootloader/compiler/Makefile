OBJECTS = syntax.cmo lexer.cmo parser.cmo typing.cmo assembly.cmo translate.cmo optimize.cmo output.cmo main.cmo

all: compiler linker conv_bin

compiler: $(OBJECTS)
	ocamlc -g -o compiler $(OBJECTS)

linker: linker.ml
	ocamlc -o linker linker.ml

conv_bin: conv_bin.ml
	ocamlc -o conv_bin conv_bin.ml

%.cmo: %.ml
	ocamlc -c $<

%.cmi: %.mli
	ocamlc -c $<

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

