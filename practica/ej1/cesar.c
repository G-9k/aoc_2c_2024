#include "common.h"

char* alfabeto = "ABCDEFGHIJKMNLOPQRSTUVWYZ";

char* cesar(char* s, int x){
    int longi = strlen(s);
    char* res = malloc((longi+1) * sizeof(char));

    for(int i = 0; i < longi; i++){
        char actual = s[i];
        int pos = obtenerNumero(actual);
        int indice = (pos+x) % 26;
        res[i] = alfabeto[indice];
    }

    res[longi] = 0;

    return res;
}

