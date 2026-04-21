#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <direct.h>
#include <ctype.h>
#include <windows.h>

void criar_executaveis_windows(){
    printf("Buildando executavel windows...\n");
    if (system("gcc -o run.exe run.c") != 0) {
        printf("Build windows falhou.\n");
        exit(1);
    }
    if (system("gcc -o editor.exe editor.c") != 0) {
        printf("Build windows falhou.\n");
        exit(1);
    }
}

void path_windows_para_linux(char * original_windows, char * buff_linux, size_t size_buff){
    char cmd[256];

    _fullpath(buff_linux, original_windows, size_buff);

    // converte path windows para path wsl (C:\Users → /mnt/c/Users)
    for (char *p = buff_linux; *p; ++p) {
        if (*p == '\\') *p = '/';
    }

    // builda cmd pra converter path
    snprintf(cmd, sizeof(cmd), "wsl wslpath -a \"%s\"", buff_linux);

    // abre um pipe pra ler o path convertido
    FILE *pipe = _popen(cmd, "r");
    fgets(buff_linux, size_buff, pipe);
    _pclose(pipe);

    // tira o enter no final, se houver
    buff_linux[strcspn(buff_linux, "\n")] = '\0';
}

void criar_executaveis_linux(){
    printf("Buildando executavel linux...\n");
    char wsl_path[256];
    char cmd[256];

    // builda
    path_windows_para_linux("run.c", wsl_path, 256);
    snprintf(cmd, sizeof(cmd), "wsl gcc -static -o run \"%s\" ", wsl_path);
    if (system(cmd) != 0) {
        printf("Build linux falhou.\n");
        exit(1);
    }

    path_windows_para_linux("editor.c", wsl_path, 256);
    snprintf(cmd, sizeof(cmd), "wsl gcc -static -o editor \"%s\" ", wsl_path);
    if (system(cmd) != 0) {
        printf("Build linux falhou.\n");
        exit(1);
    }
}

void build(const char * versao){
    char pasta[256];
    char cmd[256];

    snprintf(pasta, sizeof(pasta), "%s", versao);

    // cria o diretorio de versao
    if (_mkdir(pasta) != 0) {
        perror("mkdir falhou");
        exit(1);
    }

    // cria os subdiretorios de sistema operacional
    char subpasta[128];
    snprintf(subpasta, sizeof(subpasta), "%s//windows", pasta);
    _mkdir(subpasta);
    snprintf(subpasta, sizeof(subpasta), "%s//linux", pasta);
    _mkdir(subpasta);

    criar_executaveis_windows();
    criar_executaveis_linux();

    printf("Movendo arquivos...\n");

    // move os binarios linux pra subpasta linux
    snprintf(cmd, sizeof(cmd), "move /Y run %s\\%s\\Quatro", pasta, "linux");
    system(cmd);
    snprintf(cmd, sizeof(cmd), "move /Y editor \"%s\\%s\\Editor de Fases\"", pasta, "linux");
    system(cmd);
    

    // move os binarios windows pra subpasta windows
    snprintf(cmd, sizeof(cmd), "move /Y run.exe %s\\%s\\Quatro.exe", pasta, "windows");
    system(cmd);
    snprintf(cmd, sizeof(cmd), "move /Y editor.exe \"%s\\%s\\Editor de Fases.exe\"", pasta, "windows");
    system(cmd);

    char copy_cmd[512];

    // copia src
    snprintf(copy_cmd, sizeof(copy_cmd), "xcopy /E /I /Y src %s\\%s\\src", pasta, "linux");
    system(copy_cmd);
    snprintf(copy_cmd, sizeof(copy_cmd), "xcopy /E /I /Y src %s\\%s\\src", pasta, "windows");
    system(copy_cmd);

    // copia assets
    snprintf(copy_cmd, sizeof(copy_cmd), "xcopy /E /I /Y assets %s\\%s\\assets", pasta, "linux");
    system(copy_cmd);
    snprintf(copy_cmd, sizeof(copy_cmd), "xcopy /E /I /Y assets %s\\%s\\assets", pasta, "windows");
    system(copy_cmd);

    // renomeia o executavel do fpgrars
    char oldname[256];
    char newname[256];

    snprintf(oldname, sizeof(oldname), "%s\\linux\\src\\fpgrars-x86_64-unknown-linux-gnu--8-bit-display", pasta);
    snprintf(newname, sizeof(newname), "%s\\linux\\src\\fpgrars", pasta);
    rename(oldname, newname);

    snprintf(oldname, sizeof(oldname), "%s\\windows\\src\\fpgrars-x86_64-pc-windows-gnu--8-bit-display.exe", pasta);
    snprintf(newname, sizeof(newname), "%s\\windows\\src\\fpgrars.exe", pasta);
    rename(oldname, newname);

    // adiciona o readme 
    snprintf(copy_cmd, sizeof(copy_cmd), "copy /Y .\\linux\\readme.txt %s\\%s\\readme.txt", pasta, "linux");
    system(copy_cmd);


    char redundantfile[256]; 

    // deleta os FPGRARS redundantes (linux)
    snprintf(redundantfile, sizeof(redundantfile), "%s\\linux\\src\\fpgrars-x86_64-pc-windows-gnu--8-bit-display.exe", pasta);
    remove(redundantfile);
    snprintf(redundantfile, sizeof(redundantfile), "%s\\linux\\src\\fpgrars-x86_64-apple-darwin--8-bit-display", pasta);
    remove(redundantfile);
    snprintf(redundantfile, sizeof(redundantfile), "%s\\linux\\src\\fpgrars-overflow.exe", pasta);
    remove(redundantfile);

    // deleta os FPGRARS redundantes (windows)
    snprintf(redundantfile, sizeof(redundantfile), "%s\\windows\\src\\fpgrars-x86_64-unknown-linux-gnu--8-bit-display", pasta);
    remove(redundantfile);
    snprintf(redundantfile, sizeof(redundantfile), "%s\\windows\\src\\fpgrars-x86_64-apple-darwin--8-bit-display", pasta);
    remove(redundantfile);
    snprintf(redundantfile, sizeof(redundantfile), "%s\\windows\\src\\fpgrars-overflow.exe", pasta);
    remove(redundantfile);

    return;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Uso: build.exe <versao>\n");
        printf("Lembre-se de usar versionamento convencional (ex.: v0.1.2, v1.1.12, v0.2-alpha.1)\n");
        return 1;
    }

    build(argv[1]);

    printf("Build %s criada com sucesso.\n", argv[1]);
    return 0;
}
