%{
#include "y.tab.h"
%}

ACENTUADOS   \xc3[\x80-\xbf]

%%

\n\n/[^#@:=]						return PARAGRAFO;

[.,;]								return yytext[0];

^===							 	return TRESIGUAIS;

^@meta:\n							return INIMETA;

^@triplos:\n				 		return INITRIPLOS;

([a-zA-Z\-_]|{ACENTUADOS})+			{
										yylval.svalue = strdup(yytext);
										return EXPRESSAO;
									}

:([a-zA-Z\-_]|{ACENTUADOS})+		{
										yylval.svalue = strdup(yytext+1);
										return CONCEITO;
									}

^@tit:[ ]*[^\n]+\n					{
										int i = 5;
										while(yytext[i] == ' ')
											i++;
										yytext[yyleng-1] = '\0';
										yylval.svalue = strdup(yytext+i);
										return TITULO;
									}

^#[ ]*[^\n]+\n 						{
										int i = 1;
										while(yytext[i] == ' ')
											i++;
										yytext[yyleng-1] = '\0';
										yylval.svalue = strdup(yytext+i);
										return SUBTITULO;
									}

\"[^\n"]+\"							{
										yytext[yyleng-1] = '\0';
										yylval.svalue = strdup(yytext+1);
										return EXPRESSAO;
									}

^[^ :=#@\n][^\n]*/[\n]				{
										yylval.svalue = strdup(yytext);
										return INFO;
									}

[ \t\n\r] 							;

.   								return ERRO;
