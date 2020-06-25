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

Par          : Documento Triplos                    {   printf("Documento:\n\n%s\nTriplos:\n%s\n", $1, $2);   }
             ;

Documento    : TRESIGUAIS CONCEITO TITULO Texto     {   asprintf(&$$, "Conceito: %s\nTitulo: %s\nTexto:\n%s\n", $2, $3, $4);   }
             ;

Texto        : Texto Excerto                        {   asprintf(&$$, "%s%s", $1, $2);   }
             | Excerto                              {   $$ = strdup($1);    }
             ;

Excerto      : SUBTITULO                            {   asprintf(&$$, "\n-%s\n", $1);    }
             | INFO                                 {   $$ = strdup($1);    }
             | PARAGRAFO                            {   $$ = strdup("\nPARAGRAFO\n");    }
             ;

Triplos      : INITRIPLOS ListaTriplos              {   $$ = strdup($2);    }
             ;

ListaTriplos : ListaTriplos Triplo                  {   asprintf(&$$, "%s\n\n%s", $1, $2);    }
             | Triplo                               {   asprintf(&$$, "%s", $1);    }
             ;

Triplo       : CONCEITO Relacoes '.'                {   asprintf(&$$, "%s\n%s", $1, $2);    }
             ;

Relacoes     : Relacoes ';' Relacao                 {   asprintf(&$$, "%s\n  %s", $1, $3);    }
             | Relacao                              {   asprintf(&$$, "  %s", $1);    }
             ;

Relacao      : TipoRelacao Objetos                  {   asprintf(&$$, "%s %s", $1, $2);    }
             ;

TipoRelacao  : CONCEITO                             {   $$ = strdup($1);    }
             | EXPRESSAO                            {   $$ = strdup($1);    }
             ;         

Objetos      : Objetos ',' TipoObjeto               {   asprintf(&$$, "%s, %s", $1, $3);    }
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
