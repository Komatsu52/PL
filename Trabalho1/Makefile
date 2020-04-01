CC=gcc

mkfromtemplate : lex.yy.o
		$(CC) -o mkfromtemplate lex.yy.o -ll

lex.yy.o : lex.yy.c
		$(CC) -Wall -c lex.yy.c

lex.yy.c : mkfromtemplate.l
		flex mkfromtemplate.l

.PHONY: clean

clean:
		rm -f lex.yy.c lex.yy.o mkfromtemplate