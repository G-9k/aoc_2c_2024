# Ejercicio 1

Datos a tener en cuenta:

- 5 tareas en ejecución de nivel 3.
- Los resultados de las tareas se devuelven en eax cuando terminan.
- La sexta tarea es de nivel 0.
- Debemos tener una syscall para que las tareas que terminan su ejecución puedan cederle su tiempo a la de nivel 0 para que procese el resultado.
- La tarea original no será ejecutada hastas que la de nivel 0 haya concluido.

Cosas que asumo:

- Todas las tareas tienen su lugar en la gdt, es decir su TSS existe.
- En el tp, en el archivo tss.c, solo podemos crear tss para tareas de usuario, asumo que también existe la forma de crear tareas de nivel 0 para la tarea 6.
- Todas las tareas existen en el array de sched_task, es decir, fueron inicializadas.
- El límite de tareas en el tp es de 4, eso lo puedo modificar para que sea 6.


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

section .data
task6_offtset: dd 0x00000000
task6_selector: dw 0x0000

global _isr99
_isr99:
    pushad
    call obtenerIDTask              ; con eso obtengo su ID
    push ax
    call sched_disable_task         ; con el ID lo deshabilito
    call llame6                     ; con el ID puedo setear en un array de 5 posiciones que un flag para indicar que he llamado a la tarea 6 y estoy esperando a que procese la información que le envié
    add esp, 4
    call conseguirSelectorNV0       ; hay una sola tarea de nv0, consigo su selector
    mov word [task6_selector], ax
    jmp far [task6_offtset]         ; con el selector hago un jmp far

    popad
    iret
```

Las funciones siguientes y las declaraciones del nuevo array estarán en sched.c
La cantidad maxima de tareas posible es 35, porque en nuestro tp tenemos 35 espacios en la gdt, pero como nos fijamos dentro del array que mantiene sched.c, ahí solo existen 6 tareas iniciadas, 5 de nivel user, 1 de nivel kernel.

```c
#define MAX_TASK 6

typedef struct registro_t{
    bool llame6;
    bool usado;
    int8_t idTask;
    int32_t eax;
}

registro_t array [5] = {0};

int8_t obtenerIDTask(){
    return current_task                     // hay una variable definida en sched.c que mantiene esa información
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


void llame6Simple(int8_t id){
    array[id].llame6 = True;       // esto me permite que mi struct borre el usado y el id
}

void tarea6(){
    while(true){
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
}
// esta tarea no deja de ejecutarse nunca, el scheduler la saca para darle la ejecución a otra.
```

Entiendo que funciona de la misma forma.

# Ejercicio 2

En el ejercicio 2, dado el cr3 de la tarea que desactiva el guardado de la página en memoria y la dirección fisica de la página, debo determinar si la página debo guardarla o no. Se me ocurre que puedo chequear en mi cr3 si la página fisica que me pasan existe, para eso debo recorrer todo el directorio de páginas. Haciendo un for loop en el directorio, y por cada PD_ENTRY valida hacer un for loop en el page table y así chequear si consigo la física, si la consigo debo revisar si el bit dirty está encendido, si lo está, devuelvo 1, sino o si luego de recorrer todas las páginas validas del directorio no lo encontré, retorno 0.

