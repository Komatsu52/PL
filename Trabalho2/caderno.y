%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

extern int yylex();
extern FILE *yyin;
extern int yylineno;
extern char *yytext;

int yyerror();
int flag = 0;
char *file = NULL;
char *header = "<!DOCTYPE html>\n<html>\n<head>\n<meta charset='utf-8'/><link rel='stylesheet' href='style.css'/>\n";
%}

%union{
    char *svalue;
}

%token TRESIGUAIS CONCEITO TITULO SUBTITULO INFO PARAGRAFO INITRIPLOS EXPRESSAO ERRO
%type <svalue> CONCEITO TITULO SUBTITULO INFO EXPRESSAO
%type <svalue> Documento Texto Excerto 
%type <svalue> Triplos ListaTriplos Triplo Relacoes Relacao TipoRelacao Objetos TipoObjeto ListaPares Par
%%

Caderno      : ListaPares 							{
														char *aux;
														asprintf(&aux, "html/%s.html", file);
														FILE *fp = fopen(aux, "w");
														fprintf(fp, "%s<title>%s</title>\n</head>\n<body>\n%s\n</body>\n</html>", header, file, $1);
        												fclose(fp);
    												}
             ;

ListaPares   : ListaPares Par 						{   asprintf(&$$, "%s%s", $1, $2);    }
             | Par 									{   $$ = strdup($1);    }
             ;

Par          : Documento Triplos 					{   $$ = strdup($2);    }
             ;

Documento    : TRESIGUAIS CONCEITO TITULO Texto     {
														char *aux;
														asprintf(&aux, "html/%s.html", $2);
														FILE *fp = fopen(aux, "w");
														if(flag == 0)
        													fprintf(fp, "%s<title>%s</title>\n</head>\n<body>\n<h1>%s</h1>\n%s\n</body>\n</html>", header, $3, $3, $4);
        												else{
        													fprintf(fp, "%s<title>%s</title>\n</head>\n<body>\n<h1>%s</h1>\n%s</p>\n</body>\n</html>",header, $3, $3, $4);
        													flag = 0;
        												}
        												fclose(fp);
    												}
    		 ;
        

Texto        : Texto Excerto                        {   asprintf(&$$, "%s%s", $1, $2);   }
             | Excerto                              {   $$ = strdup($1);    }
             ;

Excerto      : SUBTITULO                            {   
														if(flag == 0)
															asprintf(&$$, "<h2>%s</h2>\n", $1);
														else{
															asprintf(&$$, "</p>\n<h2>%s</h2>\n", $1);
															flag = 0;
														}
													}
             | INFO                                 {   
             											if(flag == 0){
             												asprintf(&$$, "<p>%s", $1);
             												flag = 1;
             											}
             											else
             												asprintf(&$$, "%s", $1);
             										}
             | PARAGRAFO                            {   
             											if(flag == 1){
             												asprintf(&$$, "</p>\n");
             												flag = 0;
             											}
             										}
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

Relacao      : TipoRelacao Objetos                  {   
														if(!(strcmp($1, "img")))
															asprintf(&$$, "<img src='../%s'/>", $2);  
														else
															asprintf(&$$, "%s %s", $1, $2);    
													}
             ;

TipoRelacao  : CONCEITO                             {   $$ = strdup($1);    }
             | EXPRESSAO                            {   $$ = strdup($1);    }
             ;         

Objetos      : Objetos ',' TipoObjeto               {   asprintf(&$$, "%s, %s", $1, $3);    }
             | TipoObjeto                           {   $$ = strdup($1);    }
             ;

TipoObjeto   : CONCEITO                             {   asprintf(&$$, "<a href='%s.html'>%s</a>", $1, $1);    }
             | EXPRESSAO                            {   $$ = strdup($1);    }
             ;

%%
int main(int argc, char *argv[]){
	if(argc < 3){
		printf("Número de argumentos insuficiente\n");
		return 1;
	}

	yyin = fopen(argv[1], "r");
	file = strdup(argv[2]);
	system("mkdir html");
    yyparse();
    fclose(yyin);

    return 0;
}

int yyerror(){
    printf("Erro Sintático ou Léxico na linha: %d, com o texto: '%s'\n", yylineno, yytext);
    return 0;
}
