%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <sys/types.h>
	#include <unistd.h>
	#include <fcntl.h>

	char *nome = NULL, *email = NULL, *autor = NULL, *file = NULL;
	char **ficheiros = NULL, **diretorias = NULL;
	int nFicheiros = 0, maxFicheiros = 1, nDiretorias = 0, maxDiretorias = 1;

	void criarDiretoria(char* path);
	void criarFicheiro(char* path);
	void duplicaBuffers(char* buffer);
	char* criarPath(char* string, int tracos, int espacos, int flag);
	int quantosTracos(char* string);
	int quantosEspacos(char* string, int tracos);
	char* concatenar(const char *s1, const char *s2);
%}
%option noyywrap
%x Meta Tree Make FileName FileNoName

EMAIL		[^\n\t\r@ ]+@([a-z]+\.)+[a-z]+
EXT			([^.\n\t\r ]\.)*([^.\n\t\r ])+
FILE		[^\/|?<>*:""\n\t\r]+

%%
									BEGIN 0;

([ \n\t\r]|#[^\n]*)					;

===\ meta							BEGIN Meta;

===\ tree 							BEGIN Tree;

==\ \{%name%\}\.{EXT}\n 			{
										int i;
										yytext[yyleng-1] = '\0';
										for(i = yyleng - 1; yytext[i] != '.'; i--);
										file = concatenar(nome, yytext + i);
										BEGIN FileName;
									}

==\ {FILE}(\.{EXT})?\n 				{
										yytext[yyleng-1] = '\0';
										file = strdup(yytext + 3);
										BEGIN FileNoName;
									}

<Meta>email:\ {EMAIL}\n 			{
										yytext[yyleng-1] = '\0';
										email = strdup(yytext+7);
										if(autor != NULL)
											BEGIN 0;
									}

<Meta>author:\ [^\n\t\r]+\n			{
										yytext[yyleng-1] = '\0';
										autor = strdup(yytext+8);
										if(email != NULL)
											BEGIN 0;
									}

<Tree>[-]*[ ]*\{%name%\}\/\n		{
										if(nDiretorias == 0)
											diretorias = malloc(maxDiretorias*sizeof(char*));

										if(nDiretorias == maxDiretorias)
											duplicaBuffers("diretorias");

										yytext[yyleng-1] = '\0';

										int tracos = quantosTracos(yytext);
										if(tracos != -1){
											int espacos = quantosEspacos(yytext, tracos);
											char* aux = criarPath(nome, tracos, espacos, 1);
											criarDiretoria(aux);

											diretorias[nDiretorias] = malloc((strlen(nome) + 1) * sizeof(char));
											sprintf(diretorias[nDiretorias], "%s/", nome);
											nDiretorias++;
										}
									}

<Tree>[-]+[ ]*\{%name%\}\.{EXT}\n	{
										if(nFicheiros == 0)
											ficheiros = malloc(maxFicheiros*sizeof(char*));

										if(nFicheiros == maxFicheiros)
											duplicaBuffers("ficheiros");

										yytext[yyleng-1] = '\0';

										int tracos = quantosTracos(yytext);
										if(tracos != -1){
											int espacos = quantosEspacos(yytext, tracos);
											char* aux = criarPath(nome, tracos, espacos, 1);

											int i;
											for(i = yyleng - 1; yytext[i] != '.'; i--);
											aux = concatenar(aux, yytext + i);
											criarFicheiro(aux);

											ficheiros[nFicheiros] = malloc((strlen(aux)) * sizeof(char));
											sprintf(ficheiros[nFicheiros], "%s", aux);
											nFicheiros++;
										}
									}

<Tree>[-]*[ ]*{FILE}\/\n			{
										if(nDiretorias == 0)
											diretorias = malloc(maxDiretorias*sizeof(char*));

										if(nDiretorias == maxDiretorias)
											duplicaBuffers("diretorias");

										yytext[yyleng-1] = '\0';

										int tracos = quantosTracos(yytext);
										if(tracos != -1){
											int espacos = quantosEspacos(yytext, tracos);
											char* aux = criarPath(yytext, tracos, espacos, 0);
											criarDiretoria(aux);

											diretorias[nDiretorias] = malloc((strlen(yytext) + tracos + espacos) * sizeof(char));
											sprintf(diretorias[nDiretorias], "%s", yytext + tracos + espacos);
											nDiretorias++;
										}
									}

<Tree>[-]+[ ]*{FILE}(\.{EXT})?\n	{
										if(nFicheiros == 0)
											ficheiros = malloc(maxFicheiros*sizeof(char*));

										if(nFicheiros == maxFicheiros)
											duplicaBuffers("ficheiros");

										yytext[yyleng-1] = '\0';

										int tracos = quantosTracos(yytext);
										if(tracos != -1){
											int espacos = quantosEspacos(yytext, tracos);
											char* aux = criarPath(yytext, tracos, espacos, 0);
											criarFicheiro(aux);

											ficheiros[nFicheiros] = malloc((strlen(aux)) * sizeof(char));
											sprintf(ficheiros[nFicheiros], "%s", aux);
											nFicheiros++;
										}
									}

<Tree>=								BEGIN 0;

<FileName>=							{
										free(file);
										BEGIN 0;
									}

<FileName>[^=]*						{
										printf("Entrei no name %s\n", file);
										printf("%s\n\n", yytext);
									}

<FileNoName>=						{
										free(file);
										BEGIN 0;
									}

<FileNoName>[^=]*					{
										printf("Entrei no no name %s\n", file);
										printf("%s\n\n", yytext);
									}

<*>.|\n|\r|\t						;

%%

/*
	Funcao que determina a quantidade de espacos que aparecem no inicio de uma linha
*/
int quantosEspacos(char* string, int tracos){
	int i, j = 0;

	for(i = tracos; string[i] != '\0' && string[i] == ' '; i++, j++);
	
	return j;
}

/*
	Funcao que determina a quantidade de tracos que aparecem no inicio de uma linha
*/
int quantosTracos(char* string){
	int i;

	for(i = 0; string[i] != '\0' && string[i] == '-'; i++);

	if(i > nDiretorias)
		return -1;

	else
		return i;
}

/*
	Funcao que concatena duas strings, devolvendo o produto desta acao
*/
char* concatenar(const char *s1, const char *s2){
    char *result = malloc(strlen(s1) + strlen(s2) + 1);
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

/*
	Funcao que determina o path de um dado ficheiro, a partir do número de tracos que ocorrem no inicio da linha

	string - Linha a analisar. Esta poderá estar processada (apenas o nome que deve ocorrer no path) ou por processar;
	tracos - Nº de tracos que ocorrem no inicio da linha por processar
			 (no caso da linha esta processada, representa no numero de tracos que apareciam antes do processamento);
	espacos - Nº de espacos que aparecem a seguir a uma linha;
	flag   - Indica-nos se a string se encontra processada (1) ou por processar (0).
*/
char* criarPath(char* string, int tracos, int espacos, int flag){
	char *path = "\0";
	int k;

	if(flag == 0){
		for(k = 0; k < tracos; k++){
			path = concatenar(path, diretorias[k]);
		}

		for(k = nDiretorias; k > tracos; k--)
			free(diretorias[k-1]);

		nDiretorias = tracos;

		path = concatenar(path, string + tracos + espacos);
	}
	else if(flag == 1){
		for(k = 0; k < tracos; k++){
			path = concatenar(path, diretorias[k]);
		}

		for(k = nDiretorias; k > tracos; k--)
			free(diretorias[k-1]);

		nDiretorias = tracos;

		path = concatenar(path, string);
	}

	return path;
}

/*
	Funcao que, dado um path, executa o comando para criar a diretoria correspondente
*/
void criarDiretoria(char* path){
	char* aux = malloc((strlen(path) + 6) * sizeof(char));
	sprintf(aux, "mkdir %s", path);
	system(aux);										
	free(aux);
}

/*
	Funcao que, dado um path, executa o comando para criar o ficheiro correspondente
*/
void criarFicheiro(char* path){
	char* aux = malloc((strlen(path) + 6) * sizeof(char));
	sprintf(aux, "touch %s", path);
	system(aux);										
	free(aux);
}

/*
	Funcao que duplica o tamanho de um buffer usado como variavel global

	buffer - Serve para dizer qual o tipo de buffer a aumentar, se o buffer das diretorias ou o buffer dos ficheiros.
*/
void duplicaBuffers(char* buffer){
	char** aux = NULL;

	if(!strcmp(buffer, "ficheiros")){
		aux = malloc(maxFicheiros*sizeof(char*));
		int i;	

		for(i = 0; i < maxFicheiros; i++)
			aux[i] = strdup(ficheiros[i]);

		free(ficheiros);

		maxFicheiros += maxFicheiros;
		ficheiros = malloc(maxFicheiros*sizeof(char*));

		for(i = 0; i < nFicheiros; i++)
			ficheiros[i] = strdup(aux[i]);

		free(aux);
	}
	else if(!strcmp(buffer, "diretorias")){
		aux = malloc(maxDiretorias*sizeof(char*));
		int i;	

		for(i = 0; i < maxDiretorias; i++)
			aux[i] = strdup(diretorias[i]);

		free(diretorias);

		maxDiretorias += maxDiretorias;
		diretorias = malloc(maxDiretorias*sizeof(char*));

		for(i = 0; i < nDiretorias; i++)
			diretorias[i] = strdup(aux[i]);

		free(aux);
	}
}

int main(int argc, char* argv[]){
	
	if(argc < 3){
		printf("Número de argumentos insuficiente.\n");
		return 1;
	}

	nome = strdup(argv[1]);

	int fd = open(argv[2], O_RDONLY, 0666);
	if(fd < 0){
		printf("Erro na abertura do ficheiro %s.\n", argv[2]);
		return 1;
	}
	
	dup2(fd, STDIN_FILENO);

	if(close(fd) < 0)
		printf("Erro a fechar o ficheiro %s.\n", argv[2]);

	yylex();
	/*
	printf("%s\n", nome);
	printf("%s\n", email);
	printf("%s\n", autor);
	for(int i = 0; i < nFicheiros; i++)
		printf("ficheiro: %s\n", ficheiros[i]);

	for(int i = 0; i < nDiretorias; i++)
		printf("diretoria: %s\n", diretorias[i]);
	*/
	return 0;
}