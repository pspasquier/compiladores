all: parser.y scanner.l
	bison -d parser.y
	flex scanner.l
	gcc -c lex.yy.c parser.tab.c ast.c
	gcc -g -Wall -o etapa3 main.c ast.o lex.yy.o parser.tab.o -lfl

clean:
	rm -rf lex.yy.c lex.yy.o parser.tab.h parser.tab.o parser.tab.c ast.o etapa3

tar:
	tar cvzf etapa3.tgz Makefile main.c parser.y scanner.l ast.c ast.h output2dot.sh
