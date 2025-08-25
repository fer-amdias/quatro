#include <stdlib.h>

int main(){
    #ifdef _WIN32
        system("src\\fpgrars.exe src\\main.s");
    #else
        system("src/fpgrars src/main.s");
    #endif

    return 0;
}