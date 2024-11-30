global cooler_cesar
extern strlen
extern malloc
extern obtenerNumero

section .data

    alfabeto db "ABCDEFGHIJKMNLOPQRSTUVWYZ",0
    lenAlfa equ $ - alfabeto

section .text
cooler_cesar:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    push rdi        ; Guardo los valores originales por argumento en la pila
    push rsi        ; porque son volatiles. La función strlen puede modificarlos.

    call strlen     ; en rdi ya tengo el string cuya longitud quiero calcular.

    mov r12, rax    ; el resultado lo retorna en rax, lo guardo en r12.
    mov rdi, r12
    add rdi, 1      ; le sumamos 1 para tener en cuenta el null.

    call malloc     ; pido memoria

    mov r13, rax    ; en r13 tenemos el puntero al string resultado.

    pop rsi
    pop rdi
    xor r14, r14    ; en r14 tengo 0, sera mi int i = 0

    mov r15, 26     ; tengo el divisor para el modulo
    mov r9, alfabeto

for_loop:
    cmp r14, r12            ; acá hago la comparación i < len
    jg end                  ; si es mayor, salgo del loop

    xor r8, r8
    mov r8b, [rdi + r14]    ; acá guardo el i-ésimo caracter en r8
    
    push rdi                ; guardo registros volátiles antes de llamar a función
    push rsi
    push r8
    push r9
    mov rdi, r8
    
    call obtenerNumero

    pop r9
    pop r8                  ; restauro los registros volátiles.
    pop rsi
    pop rdi

    add rax, rsi            ; en rsi tengo el X que debo sumarle al número
    mov rdx, rax            ; despues lo muevo en 2 registros separados para
    shr rdx, 32             ; hacer división

    div r15d                 ; divido por 26, en edx se encuentra el resto.

    shl rdx, 32
    shr rdx, 32
    mov cl, [r9 + rdx]

    mov [r13+r14], cl
    add r14, 1
    jmp for_loop

end:

    mov byte [r13+r12], 0
    mov rax, r13

    pop r15
    pop r14
    pop r13
    pop r12

    pop rbp
    ret