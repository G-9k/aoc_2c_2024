# Ejercicio 1

Datos a tener en cuenta:

- 5 tareas en ejecución de nivel 3.
- Los resultados de las tareas se devuelven en eax cuando terminan.
- La sexta tarea es de nivel 0.
- Debemos tener una syscall para que las tareas que terminan su ejecución puedan cederle su tiempo a la de nivel 0 para que procese el resultado.
- La tarea original no será ejecutada hastas que la de nivel 0 haya concluido.

Cosas que asumo:

- Todas las tareas tienen su lugar en la gdt, es decir su TSS existe.



Resolución

La syscall debe ser invocada por cualquiera de las tareas de nivel 3, entonces defino en idt.c la nueva entrada para la interrupción.

```c
void idt_init() {
    //...
    IDT_ENTRY3(99);
    //...
}
```

Ahora defino el handler de la interrución:

```nasm
global _isr99
_isr99:
    pushad
    str bx                          ; consigo el task segment
    push bx
    call obtenerIDTask              ; con eso obtengo su ID
    add esp, 4
    push ax
    call sched_disable_task         ; con el ID lo deshabilito
    call llame6                     ; con el ID puedo setear en un array de 5 posiciones que un flag para indicar que he llamado a la tarea 6 y estoy esperando a que procese la información que le envié
    add esp, 4
    call conseguirSelectorNV0       ; hay una sola tarea de nv0, consigo su selector
    jmp ax:0                        ; con el selector hago un jmp far

    popad
    iret
```

Las funciones siguientes y las declaraciones del nuevo array estarán en sched.c
La cantidad maxima de tareas posible es 35, porque en nuestro tp tenemos 35 espacios en la gdt, los primeros 5 espacios ya están tomados por el gdt nulo, y el descriptor nulo, los de codigo y datos de nivel 0 y 3, y el de video. Luego el espacio 11 y 12 tambien estan ocupados por la tarea inicial y la idle. Entonces, si ignoramos las tareas cuyo selector en la gdt es 11 o 12, entonces la unica tarea de nivel 0 es la sexta tarea a la que debemos llamar.

```c
#define MAX_TASK 35

typedef struct registro_t{
    bool llame6;
    bool usado;
    int8_t idTask;
    int32_t eax;
}

registro_t array [5] = {0};

int8_t obtenerIDTask(int16_t selec){
    for(int i = 0; i < MAX_TASKS; i++){
        if(sched_task[i].selector == selec) return i;
    }
}

int16_t conseguirSelectorNV0(){
    for(int i = 0; i < MAX_TASK; i++){
        uint16_t selector = sched_task[i].selector;
        uint8_t nv = selector & 0x0002;
        uint16_t idx = selector >> 3;
        if(idx != 11 && idx != 12 && nv == 0){
            return selector;
        }
    }
}

void llame6(int8_t id){
    for(int i = 0; i < 5; i++){
        if(!(array[i].usado) || array[i].id == id){
            array[i].llame6 = True;         // como el array empieza en 0 y los id
            array[i].idTask = id;           // no están seteados, uso otro bool para
            array[i].usado = True;          // saber si están ocupados o no
            break;                          // si fue ocupado, entonces tiene el id
        }                           // seteado y puedo modificar llame6, los otros
    }                           // nunca cambian luego del primer seteo
}

void tarea6(){
    for(int i = 0; i < 5; i++){
        if(array[i].llame6){
            // si me llamó, debo conseguir el valor en eax
            int8_t id = array[i].id;
            int16_t selector = sched_tasks[id].selector;
            int16_t index = selector >> 3;
            tss_t* tssTask = gdt[index].base;
            uint32_t* esp = tssTask.esp;
            uint32_t eax = esp[7];
            array[i].eax = eax;             // lo guardo porque si, despues si llama devuelta se sobreescribe
            array[i].llame6 = False;        // porque ya atendí la llamada
            sched_enable_task[id];          // y por eso la habilito nuevamente
        }
    }
}
```

Entiendo que funciona de la misma forma.



