#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void char2value(unsigned char * array, int tamanho){
    for (int i = 0; i < tamanho; i++){

        switch(array[i]){
            case ' ':   // nada
            case '0':   // nada
                array[i] = 0;
                break;
            case '-':   // parede
            case '|':   // parede
                array[i] = 1;
                break;
            case 'C':   // comeco da fase
                array[i] = 2;
                break;
            case 'F':   // fim da fase
                array[i] = 3;
                break;
            case 'B':   // bloco quebravel
                array[i] = 4;
                break;
            case 'P':   // power-up 1
                array[i] = 5;
                break;
            case 'p':   // power-up 2
                array[i] = 6;
                break;
            case 'E':   // elevador
                array[i] = 7;
                break;
            case 'S':
            case 's':   // scroll
                array[i] = 8;
                break;
            case 'Z':   // especial -- uso depende do capitulo
                array[i] = 9;
                break;
            default:    // tipos de npc
                array[i] -= 39; // a tabela ascii comeca com 49 = '1', 50 = '2', etc; entao os npcs vao comecar a contar a partir do 10
        }
    }
}

int lvl2data(const char * nome, FILE* lvl, FILE* data){

    // primeiro a altura e largura
    int altura, largura;
    fscanf(lvl, "%d %d\n", &altura, &largura);

    fprintf(data, "%s: .word %d, %d\n.byte ", nome, altura, largura);

    unsigned char linha[256]; 

    short scroll = 0; // assume-se que nao hah scroll

    for (int i = 0; i < altura; i++) {
        fgets(linha, sizeof(linha), lvl);
        // pular comentarios
        if (linha[0] == '#'){
            i--;
            continue;
        }
            

        // tira comentarios inline
        char *comment = strchr(linha, '#');
        if (comment) *comment = '\0'; 

        // converte char em valores pro arquivo .data
        char2value(linha, largura);

        // imprime caractere por caractere
        for (int i = 0; i < largura; i++){
            fprintf(data, "%d, ", linha[i]);
        }
        fputc('\n', data);
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
        return 404; // hehe
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

    printf("Arquivo convertido com sucesso: %s.data\n", nome);
}