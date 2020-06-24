%{
#include <stdio.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern char *yytext;
int yyerror();
int i = 0;
%}

%union{
    char *svalue;
}

%token TRESIGUAIS CONCEITO TITULO SUBTITULO INFO PARAGRAFO INITRIPLOS EXPRESSAO ERRO
%type <svalue> CONCEITO TITULO SUBTITULO INFO EXPRESSAO
%type <svalue> Documento Texto Excerto
%type <svalue> Triplos ListaTriplos Triplo Relacoes Relacao TipoRelacao Objetos TipoObjeto
%%

Caderno      : ListaPares
             ;

ListaPares   : ListaPares Par
             | Par
             ;

Par          : Documento Triplos                    {   printf("Documento:\n%s\nTriplos:\n%s\n", $1, $2);   }
             ;

Documento    : TRESIGUAIS CONCEITO TITULO Texto     { 
                                                        $$ = malloc(sizeof(char)*(strlen($2)+strlen($3)+strlen($4)+3));
                                                        sprintf($$, "%s\n%s\n%s\n", $2, $3, $4);
                                                    }
             ;

Texto        : Texto Excerto                        {
                                                        $$ = malloc(sizeof(char)*(strlen($1)+strlen($2)));
                                                        sprintf($$, "%s%s", $1, $2);
                                                    }
             | Excerto                              {   $$ = strdup($1);    }
             ;

Excerto      : SUBTITULO                            {
                                                        $$ = malloc(sizeof(char)*(strlen($1)+3));
                                                        sprintf($$, "\n-%s\n", $1);
                                                    }
             | INFO                                 {   $$ = strdup($1);    }
             | PARAGRAFO                            {   $$ = strdup("\n");    }
             ;

Triplos      : INITRIPLOS ListaTriplos              {   $$ = strdup($2);    }
             ;

ListaTriplos : ListaTriplos Triplo                  {
                                                        $$ = malloc(sizeof(char)*(strlen($1)+strlen($2)+1));
                                                        sprintf($$, "%s%s\n", $1, $2);
                                                    }
             | Triplo                               {
                                                        $$ = malloc(sizeof(char)*(strlen($1)+1));
                                                        sprintf($$, "%s\n", $1);
                                                    }
             ;

Triplo       : CONCEITO Relacoes '.'                {
                                                        $$ = malloc(sizeof(char)*(strlen($1)+strlen($2)+2));
                                                        sprintf($$, "%s\n%s\n", $1, $2);
                                                    }
             ;

Relacoes     : Relacoes ';' Relacao                 {
                                                        $$ = malloc(sizeof(char)*(strlen($1)+strlen($3)+3));
                                                        sprintf($$, "%s  %s\n", $1, $3);
                                                    }
             | Relacao                              {
                                                        $$ = malloc(sizeof(char)*(strlen($1)+3));
                                                        sprintf($$, "  %s\n", $1);
                                                    }
             ;

Relacao      : TipoRelacao Objetos                  {
                                                        $$ = malloc(sizeof(char)*(strlen($1)+strlen($2)+2));
                                                        sprintf($$, "%s %s\n", $1, $2);
                                                    }
             ;

TipoRelacao  : CONCEITO                             {   $$ = strdup($1);    }
             | EXPRESSAO                            {   $$ = strdup($1);    }
             ;         

Objetos      : Objetos ',' TipoObjeto               {
                                                        $$ = malloc(sizeof(char)*(strlen($1)+strlen($3)+3));
                                                        sprintf($$, "%s, %s", $1, $3);
                                                    }
             | TipoObjeto                           {   $$ = strdup($1);    }
             ;

TipoObjeto   : CONCEITO                             {   $$ = strdup($1);    }
             | EXPRESSAO                            {   $$ = strdup($1);    }
             ;

%%
int main(){
    yyparse();
    return 0;
}

int yyerror(){
    printf("Erro Sintático ou Léxico na linha: %d, com o texto: '%s'\n", yylineno, yytext);
    return 0;
}
