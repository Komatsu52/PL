CC=gcc

processador : y.tab.o lex.yy.o
	$(CC) -o processador y.tab.o lex.yy.o -ll

y.tab.o : y.tab.c
	$(CC) -c y.tab.c

lex.yy.o : lex.yy.c
	$(CC) -c lex.yy.c

y.tab.c y.tab.h : caderno.y
	yacc -d caderno.y

lex.yy.c : caderno.l y.tab.h
	flex caderno.l

.PHONY: clean

clean:
		rm -f lex.yy.c lex.yy.o y.tab.c y.tab.o y.tab.h processador html/*
		rmdir html