#include <stdlib.h>

#ifdef _WIN32
    #include <direct.h>
    #define chdir _chdir
#else
    #include <unistd.h>
#endif

int main(){
    chdir("src");
    #ifdef _WIN32
        system("fpgrars.exe editor_de_fases\\main.s");
    #else
        system("fpgrars editor_de_fases/main.s");
    #endif

    return 0;
}