#include "stdint.h"
#include "stdbool.h"
#include "stddef.h"



int8_t current_task = 0;
int8_t last_priority_task = 0;
int8_t last_normal_task = 0;

uint16_t sched_next_task(void) {
  // Buscamos la próxima tarea con prioridad (comenzando en la ultima tarea con prioridad ejecutada)
    int8_t i;
    for (i = (last_priority_task + 1); (i % MAX_TASKS) != last_priority_task; i++) {
    // Si esta tarea está disponible la ejecutamos
        if (sched_tasks[i % MAX_TASKS].state == TASK_RUNNABLE & esPrioritaria(i)) {
            break;
        }
    }

    // Ajustamos i para que esté entre 0 y MAX_TASKS-1
    i = i % MAX_TASKS;

    // Si la tarea que encontramos es ejecutable y prioritaria y es distinta entonces vamos a correrla.
    if (sched_tasks[i].state == TASK_RUNNABLE & esPrioritaria(i) & current_task != i) {
        current_task = i;
        last_priority_task = i;
        return sched_tasks[i].selector;
    }

    
    //Si llegamos acá, no encontré ninguna prioritaria, tan solo repito el scheduler que ya teniamos.
    // empezando desde la ultima sin prioridad

    for (i = (last_normal_task + 1); (i % MAX_TASKS) != last_normal_task; i++) {
        // Si esta tarea está disponible la ejecutamos
        if (sched_tasks[i % MAX_TASKS].state == TASK_RUNNABLE) {
            break;
        }
    }

    // Ajustamos i para que esté entre 0 y MAX_TASKS-1
    i = i % MAX_TASKS;

    // Si la tarea que encontramos es ejecutable entonces vamos a correrla.
    if (sched_tasks[i].state == TASK_RUNNABLE) {
        current_task = i;
        last_normal_task = i;
        return sched_tasks[i].selector;
    }

    // En el peor de los casos no hay ninguna tarea viva. Usemos la idle como
    // selector.
    return GDT_IDX_TASK_IDLE << 3;
}


#define index_EAX 7
#define index_ECX 6
#define index_EDX 5
#define index_EBX 4
#define index_ESP 3
#define index_EBP 2
#define index_ESI 1
#define index_EDI 0

bool esPrioritaria(int8_t index_task){
    uint16_t selector = sched_task[index_task % MAX_TASKS].selector;
    uint16_t indice = selector >> 3;
    gdt_entry_t tss_desc = gdt[indice];

    uint32_t esp = tss_desc.base->esp;
    uint edx = esp[index_EDX];

    return edx == 0x00FAFAFA;
}
