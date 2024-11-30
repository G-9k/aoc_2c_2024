
; PushAD Order
%define offset_EAX 28
%define offset_ECX 24
%define offset_EDX 20
%define offset_EBX 16
%define offset_ESP 12
%define offset_EBP 8
%define offset_ESI 4
%define offset_EDI 0

global _isr98
_isr98:
    pushad

    push ESI    ; al pushear argumentos, primero
    push EDI    ; va el último, ya que el primero
    push AX     ; que sale es el último ingresado
    call spy

    add ESP, 12     ; acomodo la pila

    mov [esp + offset_EAX], EAX    
    ; importante que en EAX devuelvo algo que no quiero que popad me lo pise.
    ; por eso modifico el EAX que está directo en la pila asi el popad lo devuelve.
    popad
    iret
