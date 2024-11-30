#include "common.h"

int main(){
    char* result = cooler_cesar("HOLA", 17);
    char* result2 = cesar("HOLA", 17);
    printf("%s \n", result);
    printf("%s \n", result2);

    free(result);
    free(result2);

    return 0;
}


