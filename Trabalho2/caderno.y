%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

extern FILE *yyin;
extern int yylineno;
extern char *yytext;
extern int yylex();
int yyerror();

int flag = 0;
int htmls_size = 0;
int htmls_inserted = 0;
char **htmls = NULL;
char **refers = NULL;
char **imagens = NULL;
char *imagem = NULL;

int existsHTML(char *file);
void createHTML(char *file, char *title);
int posHTML(char *file);
void endHTMLS();
void orderHTMLS();
int compareStrings(char *str1, char *str2);
char toCapital(char c);
%}

%union{
    char *svalue;
}

%token TRESIGUAIS CONCEITO TITULO SUBTITULO INFO PARAGRAFO INITRIPLOS EXPRESSAO ERRO
%type <svalue> CONCEITO TITULO SUBTITULO INFO EXPRESSAO
%type <svalue> Texto Excerto 
%type <svalue> Relacoes Relacao TipoRelacao Objetos TipoObjeto
%%

Caderno      : ListaPares 							{
														if(!(existsHTML("indice")))
															createHTML("indice", "Índice");

        												endHTMLS();

														orderHTMLS();

														char *aux, c = 'A';
														asprintf(&aux, "html/indice.html");

														FILE *fp = fopen(aux, "a");
														for(int i = 0; i < htmls_inserted; i++){
															if(c != toCapital(htmls[i][0])){
																c = toCapital(htmls[i][0]);
																if(i == 0)
																	fprintf(fp, "<h2>%c</h2>\n<ul>\n", c);
																else
																	fprintf(fp, "</ul>\n<h2>%c</h2>\n<ul>\n", c);
															}

															aux = strdup(htmls[i]);
															for(int i = 0; i < strlen(aux); i++)
																if(aux[i] == '_')
																	aux[i] = ' ';

															fprintf(fp, "<li><a href='%s.html'>%s</a></li>\n", htmls[i], aux);
														}
														fprintf(fp, "</ul>\n</body>\n</html>");
        												fclose(fp);
    												}
             ;

ListaPares   : ListaPares Par
             | Par
             ;

Par          : Documento Triplos
             ;

Documento    : TRESIGUAIS CONCEITO TITULO Texto     {
														if(!(existsHTML($2)))
															createHTML($2, $3);

														char *aux;
														asprintf(&aux, "html/%s.html", $2);

														FILE *fp = fopen(aux, "a");
														if(flag == 0)
        													fprintf(fp, "%s\n", $4);
        												else{
        													fprintf(fp, "%s</p>\n", $4);
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

Triplos      : INITRIPLOS ListaTriplos
             ;

ListaTriplos : ListaTriplos Triplo
             | Triplo
             ;

Triplo       : CONCEITO Relacoes '.'                {
														if(!(existsHTML($1)))
															createHTML($1, NULL);

														int pos = posHTML($1);
														if(refers[pos] != NULL){
        													char *aux = strdup(refers[pos]);
        													asprintf(&(refers[pos]), "%s\n%s", aux, $2);
        												}
        												else
        													asprintf(&(refers[pos]), "%s", $2);

        												if(imagem != NULL){
        													if(imagens[pos] != NULL){
        														char *aux = strdup(imagens[pos]);
        														asprintf(&(imagens[pos]), "%s\n%s", aux, imagem);
        													}
        													else
        														imagens[pos] = strdup(imagem);

        													imagem = NULL;
        												}
    												}
             ;

Relacoes     : Relacoes ';' Relacao                 {   
														if((strcmp("imagem", $1) != 0) && (strcmp("imagem", $3) != 0))
															asprintf(&$$, "%s\n<li>%s</li>", $1, $3);
														else if(strcmp("imagem", $1) != 0)
															asprintf(&$$, "%s", $1);
														else if(strcmp("imagem", $3) != 0)
															asprintf(&$$, "<li>%s</li>", $3);
													}
             | Relacao                              {   
														if(strcmp("imagem", $1) != 0)
             												asprintf(&$$, "<li>%s</li>", $1);    
             										}
             ;

Relacao      : TipoRelacao Objetos                  {   
														if(!(strcmp($1, "img"))){
															if(imagem != NULL){
        														char *aux = strdup(imagem);
        														asprintf(&(imagem), "%s\n<p><img src='../%s'/></p>", aux, $2);
        													}
															else
																asprintf(&imagem, "<p><img src='../%s'/></p>", $2);

															$$ = strdup("imagem");
														}
														else
															asprintf(&$$, "%s %s", $1, $2);
													}
             ;

TipoRelacao  : CONCEITO                             {   
														for(int i = 0; i < strlen($1); i++)
															if($1[i] == '_')
																$1[i] = ' ';
														$$ = strdup($1);
													}
             | EXPRESSAO                            {   $$ = strdup($1);    }
             ;         

Objetos      : Objetos ',' TipoObjeto               {   asprintf(&$$, "%s, %s", $1, $3);    }
             | TipoObjeto                           {   $$ = strdup($1);    }
             ;

TipoObjeto   : CONCEITO                             {   
														char *aux = strdup($1);
														for(int i = 0; i < strlen(aux); i++)
															if(aux[i] == '_')
																aux[i] = ' ';

														if(!(existsHTML($1)))
															createHTML($1, aux);

														asprintf(&$$, "<a href='%s.html'>%s</a>", $1, aux);
													}
             | EXPRESSAO                            {   $$ = strdup($1);    }
             ;

%%
int existsHTML(char *file){

	for(int i = 0; i < htmls_inserted; i++){
		if(!(strcmp(htmls[i], file)))
			return 1;
	}

	return 0;
}

void createHTML(char *file, char *title){
	char *aux, *aux2;
	asprintf(&aux, "html/%s.html", file);

	if(title != NULL)
		aux2 = strdup(title);
	else
		aux2 = strdup(file);

	FILE *fp = fopen(aux, "w");
	fprintf(fp, "<!DOCTYPE html>\n<html>\n<head>\n<meta charset='utf-8'/>\n<title>%s</title>\n</head>\n<body>\n<h1>%s</h1>\n", file, aux2);
    fclose(fp);

    if(htmls_size == 0){
    	htmls_size = 1;
    	htmls = malloc(sizeof(char*) * htmls_size);
    	refers = malloc(sizeof(char*) * htmls_size);
    	imagens = malloc(sizeof(char*) * htmls_size);
    }

    else if(htmls_inserted == htmls_size){
    	char **inserted = malloc(sizeof(char*) * htmls_size);
    	char **refersAux = malloc(sizeof(char*) * htmls_size);
    	char **imagensAux = malloc(sizeof(char*) * htmls_size);

    	for(int i = 0; i < htmls_size; i++){
    		inserted[i] = strdup(htmls[i]);

    		if(refers[i] != NULL)
    			refersAux[i] = strdup(refers[i]);
    		else
    			refersAux[i] = NULL;

    		if(imagens[i] != NULL)
    			imagensAux[i] = strdup(imagens[i]);
    		else
    			imagensAux[i] = NULL;
    	}

    	free(htmls);
    	free(refers);
    	free(imagens);

    	htmls_size += htmls_size;
    	htmls = malloc(sizeof(char*) * htmls_size);
    	refers = malloc(sizeof(char*) * htmls_size);
    	imagens = malloc(sizeof(char*) * htmls_size);

    	for(int i = 0; i < htmls_inserted; i++){
    		htmls[i] = strdup(inserted[i]);

    		if(refersAux[i] != NULL)
    			refers[i] = strdup(refersAux[i]);
    		else
    			refers[i] = NULL;

    		if(imagensAux[i] != NULL)
    			imagens[i] = strdup(imagensAux[i]);
    		else
    			imagens[i] = NULL;
    	}

    	free(inserted);
    	free(refersAux);
    	free(imagensAux);
    }

    if(strcmp("indice", file) != 0){
    	htmls[htmls_inserted] = strdup(file);
    	refers[htmls_inserted] = NULL;
    	imagens[htmls_inserted++] = NULL;
    }
}

int posHTML(char *file){
	for(int i = 0; i < htmls_size; i++)
		if(!(strcmp(file, htmls[i])))
			return i;

	return -1;
}

void endHTMLS(){
	char *aux;

	for(int i = 0; i < htmls_inserted; i++){
		asprintf(&aux, "html/%s.html", htmls[i]);
	
		FILE *fp = fopen(aux, "a");
		if(refers[i] != NULL)
			fprintf(fp, "<h2>Referências</h2>\n<ul>\n%s\n</ul>\n", refers[i]);

		if(imagens[i] != NULL)
			fprintf(fp, "<h2>Imagens</h2>\n%s\n", imagens[i]);

		fprintf(fp, "</body>\n</html>");

    	fclose(fp);
	}
	free(refers);
	free(imagens);
}

void orderHTMLS(){
	char **aux = malloc(sizeof(char*) * htmls_inserted);
	for(int i = 0; i < htmls_inserted; i++)
		aux[i] = NULL;
	int quantos = 0;
	char *html = NULL;

	for(int i = 0; i < htmls_inserted; i++){
		html = strdup(htmls[i]);
		for(int j = 0; j < quantos+1; j++){
			if(aux[j] == NULL){
				aux[j] = strdup(html);
				quantos++;
				break;
			}
			else if(compareStrings(html, aux[j]) < 0){
				char *aux2 = strdup(aux[j]);
				aux[j] = strdup(html);
				html = strdup(aux2);
			}
		}
	}

	for(int i = 0; i < htmls_inserted; i++)
		htmls[i] = strdup(aux[i]);
}

int compareStrings(char *str1, char *str2){
	for(int i = 0; i < strlen(str1) && i < strlen(str2); i++)
		if(toCapital(str1[i]) != toCapital(str2[i]))
			return (toCapital(str1[i]) - toCapital(str2[i]));

	return 0;
}

char toCapital(char c){
	if(c >= 'a' && c <= 'z')
		return (c - 32);
	else
		return c;
}

int main(int argc, char *argv[]){
	if(argc < 2){
		printf("Número de argumentos insuficiente\n");
		return 1;
	}

	yyin = fopen(argv[1], "r");
	system("mkdir html");
    yyparse();
    fclose(yyin);

    return 0;
}

int yyerror(){
    printf("Erro Sintático ou Léxico na linha: %d, com o texto: '%s'\n", yylineno, yytext);
    return 0;
}
