CC=gcc

mkfromtemplate : lex.yy.o mk.o
		$(CC) -o mkfromtemplate mk.o lex.yy.o -ll

lex.yy.o : lex.yy.c
		$(CC) -c lex.yy.c

lex.yy.c : mkfromtemplate.l
		flex mkfromtemplate.l

mk.o : mk.c		
		$(CC) -Wall -c mk.c

.PHONY: clean

clean:
		rm -f lex.yy.c lex.yy.o mkfromtemplate mk.o
