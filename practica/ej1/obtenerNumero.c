#include "common.h"

int obtenerNumero(char c){
    for(int i = 0; i < 25; i++){
        char cheq = alfabeto[i];
        if(cheq == c) return i;
    }
    return -1;
}