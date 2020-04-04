#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include "mk.h"

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
int quantosTracos(char* string, int nDiretorias){
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
    char *res = malloc(strlen(s1) + strlen(s2) + 1);
    strcpy(res, s1);
    strcat(res, s2);
    return res;
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
