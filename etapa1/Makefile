etapa1: scanner.l
	flex scanner.l
	gcc main.c lex.yy.c -o etapa1 -lfl

clean:
	rm -rf lex.yy.c etapa1

tar:
	tar cvzf etapa1.tgz Makefile main.c scanner.l tokens.h
