#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_LINGUAS 30
#define VERSAO "1.1.0 - 26 setembro 2025"

// TODO: pular leading spaces no comeco

/*
tags,                   pt,                     en,                     de,                      ...
name,                   Portugues,              English                 Deutsch,                 ...
game_title,             QUATRO,                 QUATRO,                 QUATRO,                  ...
main_menu_1_option_1,   Jogar,                  Play,                   Spielen,                 ...
main_menu_1_option_2,   Configuracoes,          Settings,               Einstellungen,           ...
main_menu_1_option_3,   Creditos,               Credits,                Abspann,                 ...
main_menu_1_option_4,   Sair,                   Exit,                   Beenden,                 ...
settings_option_1,      Idioma,                 Language,               Sprache,                 ...
settings_option_2,      Volume,                 Volume,                 Lautstaerke,             ...
...                     ...,                    ...,                    ...,                     ...
*/

// VIRA

/*
.eqv PT 0
.eqv EN 1
.eqv DE 2
...

.data

qtd_de_linguas: .byte 3
lingua_atual:   .byte PT

offset:

.word

game_title:             0,    [en_offset]+0,    [de_offset]+0,    ...
main_menu_1_option_1:   7,    [en_offset]+7,    [de_offset]+7,    ...
main_menu_1_option_2:   13,   [en_offset]+12,   [de_offset]+14,   ...
main_menu_1_option_3:   27,   [en_offset]+21,   [de_offset]+28,   ...
main_menu_1_option_4:   36,   [en_offset]+29,   [de_offset]+36,   ...
settings_option_1:      41,   [en_offset]+34,   [de_offset]+44,   ...
settings_option_2:      48,   [en_offset]+43,   [de_offset]+52,   ...
...:                    55,   [en_offset]+50,   [de_offset]+64,   ...

# en_offset e de_offset sao meta-variables. devem ser substituidas pelos seus valores em tempo de compilacao.

str_block: .ascii "QUATRO\0Jogar\0Configuracoes\0Creditos\0Sair\0Idioma\0Volume\0[...]QUATRO\0Play\0Settings\0[etc]"

*/

void ler_entrada_csv(FILE *fd, char *buffer, size_t buflen);
size_t calcula_offsets(char * strblock, int nlinhas, int nlinguas, unsigned int offsets[nlinhas][nlinguas]);
void printa_offsets(FILE* entrada, FILE* saida, int nlinhas, int nlinguas, unsigned int offsets[nlinhas][nlinguas]);
int conta_linhas(FILE * fd);
int conta_linguas(FILE * fd);
int preenche_linguas(FILE * fd, char linguas[MAX_LINGUAS][6]);
char * cria_strblock(FILE * fd, int nlinhas, int nlinguas);

void ler_entrada_csv(FILE *fd, char *buffer, size_t buflen) {
    int c;
    size_t i = 0;
    int aspas = 0;

    c = fgetc(fd);
    if (c == '"') {
        aspas = 1;
    } else if (c != -1) {
        buffer[i++] = (char)c;
    }

    while ((c = fgetc(fd)) != -1) {
        if (aspas) {
            if (c == '"') {
                int proximo = fgetc(fd);
                if (proximo == '"') {
                    // duplas aspas viram aspas simples
                    if (i < buflen-1) buffer[i++] = '"';
                } else {
                    // fim do campo
                    if (proximo != -1) ungetc(proximo, fd);
                    break;
                }
            } else {
                if (i < buflen-1) {
                        if (c != '\n')
                                buffer[i++] = (char)c;
                        else{
                                buffer[i++] = '\\';
                                buffer[i++] = 'n';
                        }
                }
                
            }
        } else {
            if (c == ',' || c == '\n') {
                ungetc(c, fd);
                break;
            }
            if (i < buflen-1) buffer[i++] = (char)c;
        }
    }

    buffer[i] = '\0';
}

size_t calcula_offsets(char * strblock, int nlinhas, int nlinguas, unsigned int offsets[nlinhas][nlinguas]){
        unsigned int pos_strblock = 0;
        unsigned int contador_de_offset = 0;
        offsets[0][0] = 0;              // eh a primeira posicao

        for (int j = 0; j < nlinguas; j++){ 
                for (int i = 0; i < nlinhas; i++){
                        if (i == 0 && j == 0) continue;
                        while(1){

                                if (strblock[pos_strblock] == 0){
                                        // fizemos besteira
                                        // sai
                                        offsets[i][j] = contador_de_offset;
                                        return 0;
                                }

                                // nao devemos contar backspaces, pois elas servem pra escapar no codigo
                                // ex.: '\n' eh um caractere soh.
                                if (strblock[pos_strblock] != '\\'){
                                        contador_de_offset++;
                                        pos_strblock++;
                                        continue;
                                }

                                if(strblock[pos_strblock+1] == '\\'){
                                        // pula o contra-barra
                                        pos_strblock+=2;
                                        contador_de_offset++;
                                        continue;
                                }

                                if (strblock[pos_strblock+1] != '0'){
                                        pos_strblock++;
                                        continue;
                                };

                                // se chegamos ateh aqui, entao encontramos um "\0"

                                // pula o 0
                                pos_strblock+=2;
                                offsets[i][j] = ++contador_de_offset;
                                break;  // vai pro proximo offset
                        }
                }
        }

        return contador_de_offset;      // o offset do ultimo elemento da matriz
}

void printa_offsets(FILE* entrada, FILE* saida, int nlinhas, int nlinguas, unsigned int offsets[nlinhas][nlinguas]){
        rewind(entrada);
        int c;
        char buffer[1000];

        for (int i = 0; i < nlinhas; i++){
                
                // pega a tag (primeira coluna)
                ler_entrada_csv(entrada, buffer, 1000);

                // adiciona : no final da string
                int buflen = strlen(buffer);
                buffer[buflen] = ':' ;
                buffer[buflen+1] = '\0';
                
                // depois pula uma linha (joga fora os caracteres ateh ler uma quebra de linha)
                while ((c = fgetc(entrada)) != -1 && c != '\n');
                
                fprintf(saida, "%-40s .word ", buffer);
                for (int j = 0; j < nlinguas; j++){
                      fprintf(saida, "%8u, ", offsets[i][j]);  
                }
                fputc('\n', saida);
        }
        
}

int conta_linhas(FILE * fd){
        int ch; int linhas=0;

        if (fd == NULL) return -1;
        rewind(fd);

        linhas++; // se o arquivo existe, hah pelo menos uma linha

        do{
                ch = fgetc(fd);
                if(ch == '\n')
                        linhas++;
        }while(ch != -1);

        if (ferror(fd)){
                printf("Erro na leitura do arquivo.\n");
                exit(1);
        }
        return linhas;
}

int conta_linguas(FILE * fd){
        if (fd == NULL) return -1;

        rewind(fd);
        char buffer[1001];
        fgets(buffer, 1000, fd);

        char * token = strtok(buffer, ",");            //"tags"

        int linguas = 0;
        while(1){
                token = strtok(NULL, ",");
                if (token == NULL) break;
                linguas++;
        }
        return linguas;
}

// eh extremamente redundante considerando que conta_linguas poderia fazer isso, mas vou tentar manter isso single-principle
int preenche_linguas(FILE * fd, char linguas[MAX_LINGUAS][6]){
        if (fd == NULL) return -1;
        rewind(fd);

        char buffer[1001];
        ler_entrada_csv(fd, buffer, sizeof(buffer));    // descarta "tags"
        fgetc(fd);                                        // descarta o delimitante

        int idx = 0;
        while(1){
                ler_entrada_csv(fd, buffer, sizeof(buffer));                
                strncpy(linguas[idx], buffer, 5);       // copia cada lingua ah lista
                linguas[idx][5] = '\0';                 // termina com '\0'
                if (fgetc(fd) == '\n') break;           // quebra de linha
                idx++;
        }

        return idx; //quantidade de linguas
}

char * cria_strblock(FILE * fd, int nlinhas, int nlinguas){

        // pega o tamanho do arquivo
        fseek(fd, 0, SEEK_END);
        size_t size_entrada = ftell(fd) + 1;

        char * strblock = calloc(size_entrada, 1);

        char buffer[1000];
        int linha_atual, caractere_atual;
        size_t strblock_idx_atual = 0;

        // coloca os offsets por lingua
        for (int i = 0; i < nlinguas; i++){
                rewind(fd);
                linha_atual = 0;

                // pega a primeira entrada da coluna da lingua (sem considerar a primeira coluna, que sao as tags)
                for(int j = 0; j <= i+1; j++){ // pega a entrada da coluna da lingua
                        ler_entrada_csv(fd, buffer, sizeof(buffer));
                        int delim = fgetc(fd);

                        if (delim == '\n') ungetc('\n', fd); // se terminar com enter, bota ele de volta no lugar
                        // eh necessario fazer isso para sabermos quando a linha acaba
                }
                        
                // copia 1 por 1 a entrada no buffer para strblock
                int j;
                for (j = 0; buffer[j] != '\0'; j++){
                        // escapa caracteres especiais
                        if (buffer[j] == '\"' || buffer[j] == '\''){
                                if (buffer[j+1] == buffer[j]){
                                        strblock[strblock_idx_atual] = '\\';
                                        strblock_idx_atual++;
                                } else continue;
                        }
                

                        strblock[strblock_idx_atual] = buffer[j];
                        strblock_idx_atual++;
                }

                // adiciona um \0 no final
                strblock[strblock_idx_atual] = '\\';
                strblock_idx_atual++;
                strblock[strblock_idx_atual] = '0';
                strblock_idx_atual++;

                while(linha_atual < nlinhas){
                        caractere_atual = fgetc(fd);
                        if (caractere_atual == '\n'){
                                linha_atual++;
                                for(int j = 0; j <= i+1; j++){ // pega a entrada da coluna da lingua
                                        ler_entrada_csv(fd, buffer, sizeof(buffer));
                                        int delim = fgetc(fd);

                                        if (delim == '\n') ungetc('\n', fd); // se terminar com enter, bota ele de volta no lugar
                                        // eh necessario fazer isso para sabermos quando a linha acaba
                                }
                                        
                                // enquanto o ultimo caractere escrito nao for \0,
                                // copia 1 por 1 a entrada no buffer para strblock
                                int j;
                                for (j = 0; buffer[j] != '\0'; j++){
                                        // escapa caracteres especiais
                                        if (buffer[j] == '\"' || buffer[j] == '\''){
                                                strblock[strblock_idx_atual] = '\\';
                                                strblock_idx_atual++;
                                        }

                                        strblock[strblock_idx_atual] = buffer[j];
                                        strblock_idx_atual++;
                                }

                                // adiciona um \0 no final
                                strblock[strblock_idx_atual] = '\\';
                                strblock_idx_atual++;
                                strblock[strblock_idx_atual] = '0';
                                strblock_idx_atual++;

                        } else if (caractere_atual == -1) {
                                if (ferror(fd)) {
                                        printf("Erro na leitura do arquivo.\n");
                                        exit(1);
                                }
                                break;
                        }
                }
        }

        return strblock;
        
}

int main(int argc, char *argv[]){
        if(argc!=3){
                printf("Uso: %s input.csv output.s \nTransforma um arquivo de localizacao CSV em um assembly source code\n",argv[0]);
                exit(1);
        }

        FILE * entrada = fopen(argv[1], "r");
        FILE * saida =   fopen(argv[2], "w");

        int nlinhas, nlinguas;
        char linguas[MAX_LINGUAS][6];
        nlinhas = conta_linhas(entrada);
        nlinguas = conta_linguas(entrada);

        preenche_linguas(entrada, linguas);
        char * strblock = cria_strblock(entrada, nlinhas, nlinguas);

        unsigned int offsets[nlinhas][nlinguas];        calcula_offsets(strblock, nlinhas, nlinguas, offsets);

        for (int i = 0; i < nlinguas; i++)
                fprintf(saida, ".eqv %s %d\n", linguas[i], i);
        
        fprintf(saida, "\n\n.data\n\n");
        fprintf(saida, "qtd_de_linguas: .byte %d\n", nlinguas);
        fprintf(saida, "lingua_atual:   .byte %s\n", linguas[0]);
        fprintf(saida, "\n");

        fprintf(saida, "offset: \n");
        printa_offsets(entrada, saida, nlinhas, nlinguas, offsets);
        fprintf(saida, "\n");

        fprintf(saida, "strblock: .ascii \"%s\" ", strblock);
        fprintf(saida, "\n\n");
        fprintf(saida, "# VERSAO DA BUILDTOOL CSV2ASM: %s\n", VERSAO);

        free(strblock);
        fclose(entrada); 
        fclose(saida);

        return 0;
}
