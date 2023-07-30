all: parser.y scanner.l
	bison -d parser.y
	flex scanner.l
	gcc -c lex.yy.c parser.tab.c ast.c table.c
	gcc -g -Wall -o etapa4 main.c ast.o table.o lex.yy.o parser.tab.o -lfl

clean:
	rm -rf lex.yy.c lex.yy.o parser.tab.h parser.tab.o parser.tab.c ast.o table.o etapa3 etapa4

tar:
	tar cvzf etapa4.tgz Makefile main.c parser.y scanner.l ast.c ast.h table.c table.h output2dot.sh
