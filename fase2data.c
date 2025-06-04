#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// cada caractere vira um quadrado 10 por 10

void printar_linha_como_quadrado(FILE* data ,unsigned char * linha, int tamanho){

    
    for (int i = 0; i < 10; i++)
    // printa linha (x10) dez vezes

        for (int j = 0; j < tamanho; j++){
            for (int k = 0; k < 10; k++){
                fprintf(data, "%d,", linha[j]);
            }
        }
    fprintf(data, "\n");
}

void char2value(unsigned char * array, int tamanho){
    for (int i = 0; i < tamanho; i++){

        switch(array[i]){
            case '-':   // parede
            case '|':   // parede
                array[i] = 255;
                break;
            case 'C':   // comeco da fase
                array[i] = 99;
                break;
            case 'F':   // fim da fase
                array[i] = 100;
                break;
            case 'B':   // bloco quebravel
                array[i] = 250;
                break;
            case 'P':   // power-up 1
                array[i] = 241;
                break;
            case 'p':   // power-up 2
                array[i] = 242;
                break;
            case 'E':   // elevador
                array[i] = 50;
                break;
            case 'f':   // fonte da juventude
                array[i] = 42;
                break;
            default:    // tipos de inimigo
                array[i] -= 48;
        }
    }
}

int lvl2data(const char * nome, FILE* lvl, FILE* data){

    // primeiro a altura e largura
    int altura, largura;
    fscanf(lvl, "%d %d\n", &altura, &largura);

    fprintf(data, "%s: .word %d, %d\n.byte ", nome, altura*10, largura*10);

    unsigned char linha[256]; 

    while (fgets(linha, sizeof(linha), lvl)) {
    // pular comentarios
    if (linha[0] == '#')
        continue;

    // tira comentarios inline
    char *comment = strchr(linha, '#');
    if (comment) *comment = '\0'; 

    // converte char em valores pro arquivo .data
    char2value(linha, largura);

    printar_linha_como_quadrado(data, linha, largura);
}


};

int main(int argc, char** argv){

    if(argc!=2){
        printf("Uso: %s file.lvl \nConverte um arquivo .lvl em uma fase .data para ser usada no RARS\n",argv[0]);
        exit(1);
    }

    FILE *mapa_data, *mapa_lvl;

    mapa_lvl = fopen(argv[1], "r");

    if (mapa_lvl == NULL){
        printf("Arquivo nao encontrado.\n");
    }

    char nome[30];
    memset(nome, '\0', 30 * sizeof( char ));

	strncpy(nome, argv[1], strlen(argv[1]) - 4); // tira a extensão .lvl do arquivo.

    char data_nome[30];
    sprintf(data_nome,"%s.data",nome);
    mapa_data = fopen(data_nome,"w");
    
    lvl2data(nome, mapa_lvl, mapa_data);

    fclose(mapa_lvl);
    fclose(mapa_data);
}