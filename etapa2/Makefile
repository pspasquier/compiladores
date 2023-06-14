all: parser.y scanner.l
	bison -d parser.y
	flex scanner.l
	gcc -c lex.yy.c parser.tab.c
	gcc -o etapa2 main.c lex.yy.o parser.tab.o -lfl

clean:
	rm -rf lex.yy.c lex.yy.o parser.tab.h parser.tab.o parser.tab.c etapa2

tar:
	tar cvzf etapa2.tgz Makefile main.c parser.y scanner.l
