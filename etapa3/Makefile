all: parser.y scanner.l
	bison -d parser.y
	flex scanner.l
	gcc -c lex.yy.c parser.tab.c asd.c
	gcc -g -Wall -o etapa3 main.c asd.o lex.yy.o parser.tab.o -lfl

clean:
	rm -rf lex.yy.c lex.yy.o parser.tab.h parser.tab.o parser.tab.c asd.o etapa3
