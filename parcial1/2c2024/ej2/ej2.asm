section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el filtro
ALIGN 16


	;maskAlpha: dq 0xFFFFFFFFFFFFFFFF, 0x00000000FFFFFFFF

	maskPixel1: dq 0x00000000FFFFFFFF, 0x0000000000000000
	maskPixel2: dq 0xFFFFFFFF00000000, 0x0000000000000000
	maskPixel3: dq 0x0000000000000000, 0x00000000FFFFFFFF
	maskPixel4: dq 0x0000000000000000, 0xFFFFFFFF00000000

	maskAlpha2: dq 0xFF000000FF000000, 0xFF000000FF000000

	maskShuffle: db 0xFF, 0xFF, 0xFF, 0xFF, 0x08, 0x09, 0x0A, 0x0B, 0x04, 0x05, 0x06, 0x07, 0x00, 0x01, 0x02, 0x03

    pixel1: dd 40, 0, 200, 255


section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 2A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2a
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 2B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2b
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 2C (opcional) como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2c
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
; provista.
;
; Parámetros:
;   - dst:    La imagen destino. Es RGBA (8 bits sin signo por canal).
;   - src:    La imagen origen. Es RGBA (8 bits sin signo por canal).
;   - width:  El ancho en píxeles de `dst`, `src` y `mask`.
;   - height: El alto en píxeles de `dst`, `src` y `mask`.
;   - amount: El nivel de intensidad a aplicar.
global ej2a
ej2a:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = rgba_t*  dst			(rdi)
	; r/m64 = rgba_t*  src			(rsi)
	; r/m32 = uint32_t width		(rdx)
	; r/m32 = uint32_t height		(rcx)
	; r/m8  = uint8_t  amount		(r8)

	push rbp
	mov rbp, rsp
	xor rax, rax

	mov eax, ecx
	mul edx
	mov r9d, edx
	shl r9, 32
	add r9, rax
	shr r9, 2		

loop_ej2:
	movd xmm1, [rsi]	; guardo los 32 bits con los pixeles en un registro temporal
	pmovzxbd xmm1, xmm1
	movd xmm2, [rsi + 4]
	pmovzxbd xmm2, xmm2
	movd xmm3, [rsi + 8]	
	pmovzxbd xmm3, xmm3
	movd xmm4, [rsi + 12]	
	pmovzxbd xmm4, xmm4

	pxor xmm5, xmm5		; limpio el registro para usarlo
	pxor xmm6, xmm6

	push r12
	xor r12d, r12d
	add r12d, 255

	push rdi
	push rsi
	push rdx
	xor rdi, rdi
	xor rsi, rsi
	xor rdx, rdx

	mov rsi, r8				; cargo el amount "contraste"

	pxor xmm7, xmm7

	movdqu xmm7, [maskShuffle]
	pshufb xmm1, xmm7

	psrldq xmm1, 4
	movd edi, xmm1			; guardo en edi el valor que le debemos pasar a la función
	movd xmm6, r12d			; le cargamos el alpha (255)
	pslldq xmm6, 4			; shifteamos 4 bytes (32 bits) a la izquierda, luego de alpha va azul
	call f					; con f calculamos que valor debe ir en azul
	movd xmm5, eax			; lo colocamos en un registro xmm5 para hacerle un or
	por xmm6, xmm5
	pslldq xmm6, 4			; shifteamos 4 bytes para colocar verde
	psrldq xmm1, 4			; shifteo a la derecha para obtener el siguiente color
	movd edi, xmm1 
	call f
	movd xmm5, eax			
	por xmm6, xmm5			; colocamos verde en los 4 bytes menos significativos
	pslldq xmm6, 4			; shifteamos a la izquierda
	psrldq xmm1, 4			; shifteamos para calcular el rojo
	movd edi, xmm1 
	call f
	movd xmm5, eax
	por xmm6, xmm5			; añadimos el último color y lo mismo hacemos para xmm2, 3 y 4
	pxor xmm1, xmm1
	movdqu xmm1, xmm6
	pxor xmm6, xmm6

	pshufb xmm2, xmm7

	psrldq xmm2, 4
	movd edi, xmm2		
	movd xmm6, r12d		
	pslldq xmm6, 4	
	call f					
	movd xmm5, eax	
	por xmm6, xmm5
	pslldq xmm6, 4
	psrldq xmm2, 4
	movd edi, xmm2 
	call f
	movd xmm5, eax			
	por xmm6, xmm5
	pslldq xmm6, 4
	psrldq xmm2, 4
	movd edi, xmm2
	call f
	movd xmm5, eax
	por xmm6, xmm5
	pxor xmm2, xmm2
	movdqu xmm2, xmm6
	pxor xmm6, xmm6


	pshufb xmm3, xmm7

	psrldq xmm3, 4
	movd edi, xmm3		
	movd xmm6, r12d		
	pslldq xmm6, 4	
	call f					
	movd xmm5, eax	
	por xmm6, xmm5
	pslldq xmm6, 4
	psrldq xmm3, 4
	movd edi, xmm3 
	call f
	movd xmm5, eax			
	por xmm6, xmm5
	pslldq xmm6, 4
	psrldq xmm3, 4
	movd edi, xmm3 
	call f
	movd xmm5, eax
	por xmm6, xmm5
	pxor xmm3, xmm3
	movdqu xmm3, xmm6
	pxor xmm6, xmm6


	pshufb xmm4, xmm7

	psrldq xmm4, 4
	movd edi, xmm4		
	movd xmm6, r12d		
	pslldq xmm6, 4	
	call f					
	movd xmm5, eax	
	por xmm6, xmm5
	pslldq xmm6, 4
	psrldq xmm4, 4
	movd edi, xmm4 
	call f
	movd xmm5, eax			
	por xmm6, xmm5
	pslldq xmm6, 4
	psrldq xmm4, 4
	movd edi, xmm4 
	call f
	movd xmm5, eax
	por xmm6, xmm5
	pxor xmm4, xmm4
	movdqu xmm4, xmm6

	pop rdx
	pop rsi
	pop rdi
	pop r12

	packusdw xmm1, xmm1	; empaqueto de 32 a 16
	packusdw xmm2, xmm2
	packusdw xmm3, xmm3
	packusdw xmm4, xmm4

	packuswb xmm1, xmm1 ; empaqueto de 16 a 8 bits, como estaba originalmente
	packuswb xmm2, xmm2
	packuswb xmm3, xmm3
	packuswb xmm4, xmm4

	pxor xmm7, xmm7
	movdqu xmm7, [maskPixel1]
	pand xmm1, xmm7

	movdqu xmm7, [maskPixel2]
	pslldq xmm2, 4
	pand xmm2, xmm7

	movdqu xmm7, [maskPixel3]
	pslldq xmm3, 8
	pand xmm3, xmm7

	movdqu xmm7, [maskPixel4]
	pslldq xmm4, 12
	pand xmm4, xmm7

	por xmm1, xmm2
	por xmm1, xmm3
	por xmm1, xmm4

	movdqu [rdi], xmm1		; lo meto en destino

	add rsi, 16			; actualizo la posición para avanzar al siguiente pixel de origen
	add rdi, 16			; actualizo la posición para avanzar al siguiente pixel de destino

	dec r9				; decremento la cantidad de pixeles que me faltan hacer

	cmp r9, 0			; comparo si me faltan 0 pixeles para hacer
	jne loop_ej2		; sino, vuelo al loop.

	pop rbp
	ret

f:
	push rbp
	mov rbp, rsp
	xor rdx, rdx
	xor r11, r11
	mov r11, rdi

	sub r11, 128

	; xor rax, rax
	; mov rax, rsi	; muevo el contraste para multiplicar

	imul r11, rsi			

	; xor r11, r11

	; mov r11d, edx
	; shl r11, 32
	; add r11d, eax

	sar r11, 5 		; divido por 32

	add r11, 128

	cmp r11, 0
	jl zero

	cmp r11, 255
	jg dos55

	mov rax, r11

	pop rbp			; con saturación.
	ret


zero:
	
	xor rax, rax	; limpio el retorno, efectivamente devolviendo 0

	pop rbp
	ret

dos55:

	xor rax, rax
	add rax, 255

	pop rbp
	ret


; Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
; provista.
;
; Parámetros:
;   - dst:    La imagen destino. Es RGBA (8 bits sin signo por canal).
;   - src:    La imagen origen. Es RGBA (8 bits sin signo por canal).
;   - width:  El ancho en píxeles de `dst`, `src` y `mask`.
;   - height: El alto en píxeles de `dst`, `src` y `mask`.
;   - amount: El nivel de intensidad a aplicar.
;   - mask:   Una máscara que regula por cada píxel si el filtro debe o no ser
;             aplicado. Los valores de esta máscara son siempre 0 o 255.
global ej2b
ej2b:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = rgba_t*  dst			(rdi)
	; r/m64 = rgba_t*  src			(rsi)
	; r/m32 = uint32_t width		(rdx)
	; r/m32 = uint32_t height		(rcx)
	; r/m8  = uint8_t  amount		(r8)
	; r/m64 = uint8_t* mask			(r9)

	push rbp
	mov rbp, rsp
	xor rax, rax

	mov eax, ecx
	mul edx
	mov r10d, edx
	shl r10, 32
	add r10, rax
	shr r10, 2		

loop_ej2b:
	movd xmm1, [rsi]	; guardo los 32 bits con los pixeles en un registro temporal
	pmovzxbd xmm1, xmm1
	movd xmm2, [rsi + 4]
	pmovzxbd xmm2, xmm2
	movd xmm3, [rsi + 8]	
	pmovzxbd xmm3, xmm3
	movd xmm4, [rsi + 12]	
	pmovzxbd xmm4, xmm4

	pxor xmm5, xmm5		; limpio el registro para usarlo
	pxor xmm6, xmm6

	push r12
	push r13
	xor r12d, r12d
	add r12d, 255

	push rdi
	push rsi
	push rdx
	xor rdi, rdi
	xor rsi, rsi
	xor rdx, rdx

	mov rsi, r8				; cargo el amount "contraste"

	pxor xmm7, xmm7

	xor r13, r13
	mov r13b, [r9]
	cmp r13b, 0				; si es igual a 0 debo ignorar el filtro
	je p2

	movdqu xmm7, [maskShuffle]
	pshufb xmm1, xmm7

	psrldq xmm1, 4
	movd edi, xmm1			; guardo en edi el valor que le debemos pasar a la función
	movd xmm6, r12d			; le cargamos el alpha (255)
	pslldq xmm6, 4			; shifteamos 4 bytes (32 bits) a la izquierda, luego de alpha va azul
	call f					; con f calculamos que valor debe ir en azul
	movd xmm5, eax			; lo colocamos en un registro xmm5 para hacerle un or
	por xmm6, xmm5
	pslldq xmm6, 4			; shifteamos 4 bytes para colocar verde
	psrldq xmm1, 4			; shifteo a la derecha para obtener el siguiente color
	movd edi, xmm1 
	call f
	movd xmm5, eax			
	por xmm6, xmm5			; colocamos verde en los 4 bytes menos significativos
	pslldq xmm6, 4			; shifteamos a la izquierda
	psrldq xmm1, 4			; shifteamos para calcular el rojo
	movd edi, xmm1 
	call f
	movd xmm5, eax
	por xmm6, xmm5			; añadimos el último color y lo mismo hacemos para xmm2, 3 y 4
	pxor xmm1, xmm1
	movdqu xmm1, xmm6
	pxor xmm6, xmm6


p2:

	xor r13, r13
	mov r13b, [r9+1]
	cmp r13b, 0
	je p3

	pshufb xmm2, xmm7

	psrldq xmm2, 4
	movd edi, xmm2		
	movd xmm6, r12d		
	pslldq xmm6, 4	
	call f					
	movd xmm5, eax	
	por xmm6, xmm5
	pslldq xmm6, 4
	psrldq xmm2, 4
	movd edi, xmm2 
	call f
	movd xmm5, eax			
	por xmm6, xmm5
	pslldq xmm6, 4
	psrldq xmm2, 4
	movd edi, xmm2
	call f
	movd xmm5, eax
	por xmm6, xmm5
	pxor xmm2, xmm2
	movdqu xmm2, xmm6
	pxor xmm6, xmm6

p3:

	xor r13, r13
	mov r13b, [r9+2]
	cmp r13b, 0
	je p4

	pshufb xmm3, xmm7

	psrldq xmm3, 4
	movd edi, xmm3		
	movd xmm6, r12d		
	pslldq xmm6, 4	
	call f					
	movd xmm5, eax	
	por xmm6, xmm5
	pslldq xmm6, 4
	psrldq xmm3, 4
	movd edi, xmm3 
	call f
	movd xmm5, eax			
	por xmm6, xmm5
	pslldq xmm6, 4
	psrldq xmm3, 4
	movd edi, xmm3 
	call f
	movd xmm5, eax
	por xmm6, xmm5
	pxor xmm3, xmm3
	movdqu xmm3, xmm6
	pxor xmm6, xmm6

p4:

	xor r13, r13
	mov r13b, [r9+3]
	cmp r13b, 0
	je end2b

	pshufb xmm4, xmm7

	psrldq xmm4, 4
	movd edi, xmm4		
	movd xmm6, r12d		
	pslldq xmm6, 4	
	call f					
	movd xmm5, eax	
	por xmm6, xmm5
	pslldq xmm6, 4
	psrldq xmm4, 4
	movd edi, xmm4 
	call f
	movd xmm5, eax			
	por xmm6, xmm5
	pslldq xmm6, 4
	psrldq xmm4, 4
	movd edi, xmm4 
	call f
	movd xmm5, eax
	por xmm6, xmm5
	pxor xmm4, xmm4
	movdqu xmm4, xmm6

end2b:

	pop rdx
	pop rsi
	pop rdi

	packusdw xmm1, xmm1	; empaqueto de 32 a 16
	packusdw xmm2, xmm2
	packusdw xmm3, xmm3
	packusdw xmm4, xmm4

	packuswb xmm1, xmm1 ; empaqueto de 16 a 8 bits, como estaba originalmente
	packuswb xmm2, xmm2
	packuswb xmm3, xmm3
	packuswb xmm4, xmm4

	pxor xmm7, xmm7
	movdqu xmm7, [maskPixel1]
	pand xmm1, xmm7

	movdqu xmm7, [maskPixel2]
	pslldq xmm2, 4
	pand xmm2, xmm7

	movdqu xmm7, [maskPixel3]
	pslldq xmm3, 8
	pand xmm3, xmm7

	movdqu xmm7, [maskPixel4]
	pslldq xmm4, 12
	pand xmm4, xmm7

	por xmm1, xmm2
	por xmm1, xmm3
	por xmm1, xmm4

	movdqu [rdi], xmm1		; lo meto en destino

	add rsi, 16			; actualizo la posición para avanzar al siguiente pixel de origen
	add rdi, 16			; actualizo la posición para avanzar al siguiente pixel de destino
	add r9, 4

	dec r10				; decremento la cantidad de pixeles que me faltan hacer
	pop r13
	pop r12

	cmp r10, 0			; comparo si me faltan 0 pixeles para hacer
	jne loop_ej2b		; sino, vuelo al loop.

	pop rbp

	ret

; [IMPLEMENTACIÓN OPCIONAL]
; El enunciado sólo solicita "la idea" de este ejercicio.
;
; Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
; provista.
;
; Parámetros:
;   - dst:     La imagen destino. Es RGBA (8 bits sin signo por canal).
;   - src:     La imagen origen. Es RGBA (8 bits sin signo por canal).
;   - width:   El ancho en píxeles de `dst`, `src` y `mask`.
;   - height:  El alto en píxeles de `dst`, `src` y `mask`.
;   - control: Una imagen que que regula el nivel de intensidad del filtro en
;              cada píxel. Es en escala de grises a 8 bits por canal.
global ej2c
ej2c:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = rgba_t*  dst
	; r/m64 = rgba_t*  src
	; r/m32 = uint32_t width
	; r/m32 = uint32_t height
	; r/m64 = uint8_t* control

	ret
