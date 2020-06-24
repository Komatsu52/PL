%{
#include "y.tab.h"
%}

CHARS   \xc3[\x80-\xbf]

%%

\n\n/[^#@:=]						{
										//printf("Paragrafo\n");
										return PARAGRAFO;
									}

[.,;]								{
										//printf("Pontuacao - '%c'\n", yytext[0]);
										return yytext[0];
									}

^===							 	{
										//printf("Iguais\n");
										return TRESIGUAIS;
									}

^@triplos:\n				 		{
										//printf("Triplos\n");
										return INITRIPLOS;
									}

([a-zA-Z\-_]|{CHARS})+				{
										yylval.svalue = strdup(yytext);
										//printf("Expressao - '%s'\n", yylval.svalue);
										return EXPRESSAO;
									}

:([a-zA-Z\-_]|{CHARS})+				{
										yylval.svalue = strdup(yytext+1);
										//printf("Conceito - '%s'\n", yylval.svalue);
										return CONCEITO;
									}

^@tit:[ ]*[^\n]+\n					{
										int i = 5;
										while(yytext[i] == ' ')
											i++;
										yytext[yyleng-1] = '\0';
										yylval.svalue = strdup(yytext+i);
										//printf("Titulo - '%s'\n", yylval.svalue);
										return TITULO;
									}

^#[ ]*[^\n]+\n 						{
										int i = 1;
										while(yytext[i] == ' ')
											i++;
										yytext[yyleng-1] = '\0';
										yylval.svalue = strdup(yytext+i);
										//printf("Subtitulo - '%s'\n", yylval.svalue);
										return SUBTITULO;
									}

\"[^\n"]+\"							{
										yytext[0] = '\0';
										yytext[yyleng-1] = '\0';
										yylval.svalue = strdup(yytext+1);
										//printf("Expressao - '%s'\n", yylval.svalue);
										return EXPRESSAO;
									}

^[^ :=\n#@][^:=\n#@]*				{
										if(yytext[yyleng-2] == '\n'){
											yytext[yyleng-2] = yytext[yyleng-1];
											yytext[yyleng-1] = '\0';
										}
										yylval.svalue = strdup(yytext);
										//printf("Info - '%s'\n", yylval.svalue);
										return INFO;
									}

[ \t\n\r] 							;

.   								{
										//printf("Deu merda\n");
										return ERRO;
									}
