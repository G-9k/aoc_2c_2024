
#include "stdint.h"
#include "stdbool.h"
#include "stddef.h"

typedef uint32_t vaddr_t; // direccion virtual.
typedef uint32_t paddr_t; // direccion fisica.

#define DST_VIRT_PAGE 0xA00000
#define SRC_VIRT_PAGE 0xB00000

#define MMU_P (1 << 0)
#define MMU_W (1 << 1)
#define MMU_U (1 << 2)

int spy(uint16_t selector, uint32_t* src, uint32_t* dst){
    uint32_t cr3_a_espiar = obtenerCr3(selector);
    uint32_t cr3_actual = rcr3();
    paddr_t dire_a_espiar = obtenerDireccionFisica(cr3_a_espiar, src);

    if(dire_a_espiar == 0) return 1;        // si la dirección a espiar no existe devuelvo 0

    mmu_map_page(cr3_actual, SRC_VIRT_PAGE, src, MMU_P | MMU_W);
    uint32_t copia = *((uint32_t*)((SRC_VIRT_PAGE & 0xFFFFF000) | VIRT_PAGE_OFFSET(SRC_VIRT_PAGE)));
    
    dst[0] = copia;
    mmu_unmap_page(cr3_actual, SRC_VIRT_PAGE);
    return 0;
}

uint32_t obtenerCr3(uint16_t selector){
    uint16_t indice = selector >> 3;

    uint32_t baseTSS = gdt[indice].base;

    return baseTSS->cr3;
}

paddr_t obtenerDireccionFisica(uint32_t cr3, uint32_t* srcVirt){

    pd_entry_t* pd = (cr3 & 0xFFFFF000)
    uint32_t offserDir = srcVirt >> 22

    pd_entry_t PDE = pd[offsetDir];

    if((PDE.attr & 0x001) == 0){
        return 0;                   // la tabla no está, no hay dirección fisica
    }

    pt_entry_t* pt = PDE.pt << 12
    uint32_t offsetPT = (srcVirt << 10) >> 22

    PT_ENTRY PTE = pt[offsetPT];

    if((PTE.attr & 0x001) == 0){
        return 0;                   // la página no está, no hay dirección fisica
    }

    return ((PTE.page << 12) | (srcVirt & 0x00000FFF))

}

